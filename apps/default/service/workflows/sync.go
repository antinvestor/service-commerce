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

// Package workflows registers commerce's scheduled automations with the
// trustage orchestrator from the setup job. Each workflow is a DSL document
// under the workflows directory; the sync creates and activates any whose
// name is not yet registered, so re-running the job is idempotent.
package workflows

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	workflowv1 "buf.build/gen/go/antinvestor/workflow/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/setup"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/types/known/structpb"
)

// SetupStepName is the setup-plan step that registers workflows.
const SetupStepName = "trustage-workflows"

// Client is the slice of the trustage workflow API the sync uses.
type Client interface {
	ListWorkflows(
		context.Context,
		*connect.Request[workflowv1.ListWorkflowsRequest],
	) (*connect.Response[workflowv1.ListWorkflowsResponse], error)
	CreateWorkflow(
		context.Context,
		*connect.Request[workflowv1.CreateWorkflowRequest],
	) (*connect.Response[workflowv1.CreateWorkflowResponse], error)
	ActivateWorkflow(
		context.Context,
		*connect.Request[workflowv1.ActivateWorkflowRequest],
	) (*connect.Response[workflowv1.ActivateWorkflowResponse], error)
}

// Env values substituted into the DSL before registration, so one set of
// files serves every environment.
type Env struct {
	// CommerceURI is the base URL trustage calls back into.
	CommerceURI string
}

// RegisterSync adds the workflow sync to the service's setup plan. With no
// client (trustage not configured) the step logs and succeeds.
func RegisterSync(svc *frame.Service, cli Client, dir string, env Env) {
	svc.Setup().Register(setup.Func{
		StepName: SetupStepName,
		Fn: func(ctx context.Context) error {
			if cli == nil {
				util.Log(ctx).Info("trustage workflow sync skipped: no endpoint configured")
				return nil
			}
			return SyncFromDir(ctx, cli, dir, env)
		},
	})
}

// SyncFromDir registers every *.json workflow in dir that trustage does not
// already know by name.
func SyncFromDir(ctx context.Context, cli Client, dir string, env Env) error {
	log := util.Log(ctx).WithField("dir", dir)

	entries, err := os.ReadDir(dir)
	if err != nil {
		if os.IsNotExist(err) {
			log.Warn("workflows directory does not exist; nothing to sync")
			return nil
		}
		return fmt.Errorf("read workflows dir: %w", err)
	}

	created := 0
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".json") {
			continue
		}
		path := filepath.Join(dir, entry.Name())
		didCreate, syncErr := syncOne(ctx, cli, path, env)
		if syncErr != nil {
			return fmt.Errorf("sync %s: %w", entry.Name(), syncErr)
		}
		if didCreate {
			created++
		}
	}
	log.WithField("created", created).Info("trustage workflows synced")
	return nil
}

func syncOne(ctx context.Context, cli Client, path string, env Env) (bool, error) {
	dsl, name, err := loadDSL(path, env)
	if err != nil {
		return false, err
	}

	existing, err := cli.ListWorkflows(ctx, connect.NewRequest(
		workflowv1.ListWorkflowsRequest_builder{Name: name}.Build(),
	))
	if err != nil {
		return false, fmt.Errorf("list workflows: %w", err)
	}
	for _, wf := range existing.Msg.GetItems() {
		if wf.GetName() == name && wf.GetStatus() != workflowv1.WorkflowStatus_WORKFLOW_STATUS_ARCHIVED {
			return false, nil
		}
	}

	createResp, err := cli.CreateWorkflow(ctx, connect.NewRequest(
		workflowv1.CreateWorkflowRequest_builder{Dsl: dsl}.Build(),
	))
	if err != nil {
		return false, fmt.Errorf("create workflow: %w", err)
	}
	id := createResp.Msg.GetWorkflow().GetId()
	if _, err = cli.ActivateWorkflow(ctx, connect.NewRequest(
		workflowv1.ActivateWorkflowRequest_builder{Id: id}.Build(),
	)); err != nil {
		return false, fmt.Errorf("activate workflow %s: %w", id, err)
	}
	util.Log(ctx).WithFields(map[string]any{"workflow": name, "id": id}).Info("trustage workflow created")
	return true, nil
}

// loadDSL reads a workflow document, substitutes environment placeholders,
// and returns it with its name.
func loadDSL(path string, env Env) (*structpb.Struct, string, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, "", fmt.Errorf("read %s: %w", path, err)
	}
	text := strings.ReplaceAll(string(raw), "${COMMERCE_URI}", strings.TrimRight(env.CommerceURI, "/"))

	dsl := &structpb.Struct{}
	if err = protojson.Unmarshal([]byte(text), dsl); err != nil {
		return nil, "", fmt.Errorf("parse %s: %w", path, err)
	}
	name := dsl.GetFields()["name"].GetStringValue()
	if name == "" {
		return nil, "", fmt.Errorf("%s: workflow name is required", path)
	}
	return dsl, name, nil
}
