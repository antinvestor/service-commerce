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

// fakeWorkflowClient stands in for the trustage orchestrator.
type fakeWorkflowClient struct {
	existing  map[string]workflowv1.WorkflowStatus
	created   []*workflowv1.CreateWorkflowRequest
	activated []string
}

func (f *fakeWorkflowClient) ListWorkflows(
	_ context.Context,
	req *connect.Request[workflowv1.ListWorkflowsRequest],
) (*connect.Response[workflowv1.ListWorkflowsResponse], error) {
	resp := &workflowv1.ListWorkflowsResponse{}
	if status, ok := f.existing[req.Msg.GetName()]; ok {
		resp.SetItems([]*workflowv1.WorkflowDefinition{
			workflowv1.WorkflowDefinition_builder{
				Id:     "wf-" + req.Msg.GetName(),
				Name:   req.Msg.GetName(),
				Status: status,
			}.Build(),
		})
	}
	return connect.NewResponse(resp), nil
}

func (f *fakeWorkflowClient) CreateWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.CreateWorkflowRequest],
) (*connect.Response[workflowv1.CreateWorkflowResponse], error) {
	f.created = append(f.created, req.Msg)
	name := req.Msg.GetDsl().GetFields()["name"].GetStringValue()
	return connect.NewResponse(&workflowv1.CreateWorkflowResponse{
		Workflow: workflowv1.WorkflowDefinition_builder{Id: "new-" + name, Name: name}.Build(),
	}), nil
}

func (f *fakeWorkflowClient) ActivateWorkflow(
	_ context.Context,
	req *connect.Request[workflowv1.ActivateWorkflowRequest],
) (*connect.Response[workflowv1.ActivateWorkflowResponse], error) {
	f.activated = append(f.activated, req.Msg.GetId())
	return connect.NewResponse(&workflowv1.ActivateWorkflowResponse{}), nil
}

// The shipped workflow files must parse and register, with the commerce URI
// substituted, and an already-registered name must be left alone.
func TestSyncFromDir_RegistersShippedWorkflows(t *testing.T) {
	dir, err := filepath.Abs("../../../../workflows")
	require.NoError(t, err)

	cli := &fakeWorkflowClient{existing: map[string]workflowv1.WorkflowStatus{
		"commerce.end_of_day_ledger": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE,
	}}
	err = workflows.SyncFromDir(context.Background(), cli, dir, workflows.Env{CommerceURI: "https://commerce.test/"})
	require.NoError(t, err)

	require.Len(t, cli.created, 1)
	require.Len(t, cli.activated, 1)
	created := cli.created[0].GetDsl()
	require.Equal(t, "commerce.reconcile_payments", created.GetFields()["name"].GetStringValue())

	raw, err := protojson.Marshal(created)
	require.NoError(t, err)
	require.Contains(t, string(raw), "https://commerce.test/commerce.v1.CommerceService/ReconcilePayments")
	require.NotContains(t, string(raw), "${COMMERCE_URI}")
}

func TestSyncFromDir_ArchivedWorkflowIsRecreated(t *testing.T) {
	dir := t.TempDir()
	doc := `{"version":"1.0","name":"commerce.test","schedule":{"cron":"0 1 * * *","active":true},
	"steps":[{"id":"s","type":"call","call":{"action":"http.request","input":{"url":"${COMMERCE_URI}/x","method":"POST"}}}]}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "test.json"), []byte(doc), 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "notes.md"), []byte("ignored"), 0o600))

	cli := &fakeWorkflowClient{existing: map[string]workflowv1.WorkflowStatus{
		"commerce.test": workflowv1.WorkflowStatus_WORKFLOW_STATUS_ARCHIVED,
	}}
	require.NoError(t, workflows.SyncFromDir(context.Background(), cli, dir, workflows.Env{CommerceURI: "http://c"}))
	require.Len(t, cli.created, 1)
	raw, _ := protojson.Marshal(cli.created[0].GetDsl())
	require.Contains(t, string(raw), "http://c/x")
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
