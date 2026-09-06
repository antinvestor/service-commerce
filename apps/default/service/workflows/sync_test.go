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
	"os"
	"path/filepath"
	"testing"

	workflowv1 "buf.build/gen/go/antinvestor/workflow/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/encoding/protojson"

	"github.com/antinvestor/service-commerce/apps/default/service/workflows"
)

// fakeWorkflowClient stands in for the trustage orchestrator. CreateWorkflow
// mirrors trustage: a name in live returns that (already active) version, any
// other name yields a fresh draft that still needs activating.
type fakeWorkflowClient struct {
	live      map[string]workflowv1.WorkflowStatus
	created   []*workflowv1.CreateWorkflowRequest
	activated []string
}

func (f *fakeWorkflowClient) CreateWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.CreateWorkflowRequest],
) (*connect.Response[workflowv1.CreateWorkflowResponse], error) {
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

// The shipped workflow files must parse, carry a cron schedule, and be
// submitted with the commerce URI substituted. Every submission goes to
// trustage (it is idempotent by name); only a version that is not already
// active gets activated.
func TestSyncFromDir_RegistersShippedWorkflows(t *testing.T) {
	dir, err := filepath.Abs("../../../../workflows")
	require.NoError(t, err)

	cli := &fakeWorkflowClient{live: map[string]workflowv1.WorkflowStatus{
		"commerce.end_of_day_ledger": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE,
	}}
	err = workflows.SyncFromDir(context.Background(), cli, dir, workflows.Env{CommerceURI: "https://commerce.test/"})
	require.NoError(t, err)

	require.Len(t, cli.created, 2)
	require.Equal(t, []string{"new-commerce.reconcile_payments"}, cli.activated)

	for _, req := range cli.created {
		dsl := req.GetDsl()
		schedules := dsl.GetFields()["schedules"].GetListValue().GetValues()
		require.NotEmpty(t, schedules, dsl.GetFields()["name"].GetStringValue())
		raw, marshalErr := protojson.Marshal(dsl)
		require.NoError(t, marshalErr)
		require.NotContains(t, string(raw), "${COMMERCE_URI}")
		require.Contains(t, string(raw), "https://commerce.test/commerce.v1.CommerceService/")
	}
}

// A changed document yields a new (draft) version from trustage, which the
// sync activates; a re-run with the same document is a no-op.
func TestSyncFromDir_ChangedDocumentIsActivatedOnce(t *testing.T) {
	dir := t.TempDir()
	doc := `{"version":"1.0","name":"commerce.test","schedules":[{"name":"n","cron_expr":"0 1 * * *"}],
	"steps":[{"id":"s","type":"call","call":{"action":"http.request","input":{"url":"${COMMERCE_URI}/x","method":"POST"}}}]}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "test.json"), []byte(doc), 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "notes.md"), []byte("ignored"), 0o600))

	cli := &fakeWorkflowClient{}
	require.NoError(t, workflows.SyncFromDir(context.Background(), cli, dir, workflows.Env{CommerceURI: "http://c"}))
	require.Len(t, cli.created, 1)
	require.Equal(t, []string{"new-commerce.test"}, cli.activated)
	raw, _ := protojson.Marshal(cli.created[0].GetDsl())
	require.Contains(t, string(raw), "http://c/x")

	cli.live = map[string]workflowv1.WorkflowStatus{"commerce.test": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE}
	require.NoError(t, workflows.SyncFromDir(context.Background(), cli, dir, workflows.Env{CommerceURI: "http://c"}))
	require.Len(t, cli.created, 2)
	require.Len(t, cli.activated, 1)
}

func TestSyncFromDir_RejectsWorkflowWithoutSchedule(t *testing.T) {
	dir := t.TempDir()
	for name, doc := range map[string]string{
		"none.json":   `{"version":"1.0","name":"commerce.none","steps":[]}`,
		"nocron.json": `{"version":"1.0","name":"commerce.nocron","schedules":[{"name":"n"}],"steps":[]}`,
	} {
		require.NoError(t, os.WriteFile(filepath.Join(dir, name), []byte(doc), 0o600))
	}
	err := workflows.SyncFromDir(context.Background(), &fakeWorkflowClient{}, dir, workflows.Env{})
	require.Error(t, err)
	require.Contains(t, err.Error(), "schedules")
}

func TestSyncFromDir_MissingDirIsNotAnError(t *testing.T) {
	cli := &fakeWorkflowClient{}
	require.NoError(
		t,
		workflows.SyncFromDir(context.Background(), cli, filepath.Join(t.TempDir(), "nope"), workflows.Env{}),
	)
	require.Empty(t, cli.created)
}

func TestSyncFromDir_RejectsUnnamedWorkflow(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "bad.json"), []byte(`{"version":"1.0","steps":[]}`), 0o600))
	err := workflows.SyncFromDir(context.Background(), &fakeWorkflowClient{}, dir, workflows.Env{})
	require.Error(t, err)
}
