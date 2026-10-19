// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package workflows_test

import (
	"context"
	"errors"
	"testing"
	"testing/fstest"

	workflowv1 "buf.build/gen/go/antinvestor/workflow/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/encoding/protojson"

	"github.com/antinvestor/service-commerce/apps/default/service/workflows"
	workflowdefs "github.com/antinvestor/service-commerce/workflows"
)

// fakeWorkflowClient stands in for the trustage orchestrator. CreateWorkflow
// mirrors trustage: a name in live returns that (already active) version, any
// other name yields a fresh draft that still needs activating. active lists
// what ListWorkflows reports as active.
type fakeWorkflowClient struct {
	live      map[string]workflowv1.WorkflowStatus
	active    []*workflowv1.WorkflowDefinition
	createErr error
	created   []*workflowv1.CreateWorkflowRequest
	activated []string
	archived  []string
}

func (f *fakeWorkflowClient) CreateWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.CreateWorkflowRequest],
) (*connect.Response[workflowv1.CreateWorkflowResponse], error) {
	if f.createErr != nil {
		return nil, f.createErr
	}
	f.created = append(f.created, req.Msg)
	name := req.Msg.GetDsl().GetFields()["name"].GetStringValue()
	status := workflowv1.WorkflowStatus_WORKFLOW_STATUS_DRAFT
	if live, ok := f.live[name]; ok {
		status = live
	}
	return connect.NewResponse(&workflowv1.CreateWorkflowResponse{
		Workflow: workflowv1.WorkflowDefinition_builder{Id: "new-" + name, Name: name, Status: status}.Build(),
	}), nil
}

func (f *fakeWorkflowClient) ActivateWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.ActivateWorkflowRequest],
) (*connect.Response[workflowv1.ActivateWorkflowResponse], error) {
	f.activated = append(f.activated, req.Msg.GetId())
	return connect.NewResponse(&workflowv1.ActivateWorkflowResponse{}), nil
}

func (f *fakeWorkflowClient) ListWorkflows(
	_ context.Context,
	_ *connect.Request[workflowv1.ListWorkflowsRequest],
) (*connect.Response[workflowv1.ListWorkflowsResponse], error) {
	return connect.NewResponse(&workflowv1.ListWorkflowsResponse{Items: f.active}), nil
}

func (f *fakeWorkflowClient) ArchiveWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.ArchiveWorkflowRequest],
) (*connect.Response[workflowv1.ArchiveWorkflowResponse], error) {
	f.archived = append(f.archived, req.Msg.GetId())
	return connect.NewResponse(&workflowv1.ArchiveWorkflowResponse{}), nil
}

const testDoc = `{"version":"1.0","name":"commerce.test","schedules":[{"name":"n","cron_expr":"0 1 * * *"}],
"steps":[{"id":"s","type":"call","call":{"action":"http.request","input":{"url":"${COMMERCE_URI}/x","method":"POST"}}}]}`

func docs(files map[string]string) fstest.MapFS {
	fsys := fstest.MapFS{}
	for name, body := range files {
		fsys[name] = &fstest.MapFile{Data: []byte(body)}
	}
	return fsys
}

// The embedded workflow documents must parse, carry a cron schedule, and be
// submitted with the commerce URI substituted. Every submission goes to
// trustage (it is idempotent by name); only a version that is not already
// active gets activated.
func TestSync_RegistersShippedWorkflows(t *testing.T) {
	cli := &fakeWorkflowClient{live: map[string]workflowv1.WorkflowStatus{
		"commerce.end_of_day_ledger": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE,
	}}
	err := workflows.Sync(context.Background(), cli, workflowdefs.Definitions(),
		workflows.Env{CommerceURI: "https://commerce.test/"})
	require.NoError(t, err)

	require.Len(t, cli.created, 2)
	require.Equal(t, []string{"new-commerce.reconcile_payments"}, cli.activated)
	for _, req := range cli.created {
		raw, marshalErr := protojson.Marshal(req.GetDsl())
		require.NoError(t, marshalErr)
		require.NotContains(t, string(raw), "${")
		require.Contains(t, string(raw), "https://commerce.test/commerce.v1.CommerceService/")
	}
}

// A changed document yields a new (draft) version from trustage, which the
// sync activates; a re-run with the same document is a no-op.
func TestSync_ChangedDocumentIsActivatedOnce(t *testing.T) {
	fsys := docs(map[string]string{"test.json": testDoc, "notes.md": "ignored"})
	cli := &fakeWorkflowClient{}
	require.NoError(t, workflows.Sync(context.Background(), cli, fsys, workflows.Env{CommerceURI: "http://c"}))
	require.Len(t, cli.created, 1)
	require.Equal(t, []string{"new-commerce.test"}, cli.activated)
	raw, _ := protojson.Marshal(cli.created[0].GetDsl())
	require.Contains(t, string(raw), "http://c/x")

	cli.live = map[string]workflowv1.WorkflowStatus{"commerce.test": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE}
	require.NoError(t, workflows.Sync(context.Background(), cli, fsys, workflows.Env{CommerceURI: "http://c"}))
	require.Len(t, cli.created, 2)
	require.Len(t, cli.activated, 1)
}

// Deleting a document stops its schedule: the active version is archived.
// Other services' workflows are never touched.
func TestSync_ArchivesRetiredCommerceWorkflowsOnly(t *testing.T) {
	cli := &fakeWorkflowClient{active: []*workflowv1.WorkflowDefinition{
		workflowv1.WorkflowDefinition_builder{Id: "w1", Name: "commerce.test"}.Build(),
		workflowv1.WorkflowDefinition_builder{Id: "w2", Name: "commerce.retired"}.Build(),
		workflowv1.WorkflowDefinition_builder{Id: "w3", Name: "imports.nightly"}.Build(),
	}}
	fsys := docs(map[string]string{"test.json": testDoc})
	require.NoError(t, workflows.Sync(context.Background(), cli, fsys, workflows.Env{CommerceURI: "http://c"}))
	require.Equal(t, []string{"w2"}, cli.archived)
}

func TestLoad_RejectsInvalidDocuments(t *testing.T) {
	env := workflows.Env{CommerceURI: "http://c"}
	for name, tc := range map[string]struct {
		files map[string]string
		env   workflows.Env
		want  string
	}{
		"no schedules": {map[string]string{"a.json": `{"name":"commerce.a","steps":[]}`}, env, "schedules"},
		"no cron": {
			map[string]string{"a.json": `{"name":"commerce.a","schedules":[{"name":"n"}],"steps":[]}`},
			env, "cron_expr",
		},
		"unnamed":          {map[string]string{"a.json": `{"steps":[]}`}, env, "must start with"},
		"foreign prefix":   {map[string]string{"a.json": `{"name":"imports.a"}`}, env, "must start with"},
		"no commerce uri":  {map[string]string{"test.json": testDoc}, workflows.Env{}, "COMMERCE_SERVICE_URI"},
		"not json":         {map[string]string{"a.json": `{`}, env, "parse"},
		"duplicate name":   {map[string]string{"a.json": testDoc, "b.json": testDoc}, env, "both define"},
		"unknown variable": {map[string]string{"a.json": `{"name":"commerce.a","schedules":[{"cron_expr":"* * * * *"}],"u":"${OTHER}"}`}, env, "placeholder"},
	} {
		t.Run(name, func(t *testing.T) {
			_, err := workflows.Load(docs(tc.files), tc.env)
			require.ErrorContains(t, err, tc.want)
		})
	}
}

func TestSync_ValidatesEverythingBeforeSubmitting(t *testing.T) {
	cli := &fakeWorkflowClient{}
	fsys := docs(map[string]string{"a.json": testDoc, "b.json": `{"name":"commerce.b"}`})
	require.Error(t, workflows.Sync(context.Background(), cli, fsys, workflows.Env{CommerceURI: "http://c"}))
	require.Empty(t, cli.created, "a bad document must not half-register the set")
}

func TestSync_ReportsTrustageFailure(t *testing.T) {
	cli := &fakeWorkflowClient{createErr: errors.New("unavailable")}
	err := workflows.Sync(context.Background(), cli, docs(map[string]string{"test.json": testDoc}),
		workflows.Env{CommerceURI: "http://c"})
	require.ErrorContains(t, err, "unavailable")
}
