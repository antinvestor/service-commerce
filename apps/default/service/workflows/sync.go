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
// under the workflows directory. Trustage's CreateWorkflow is idempotent by
// name: an identical live version is returned as-is and a changed document
// becomes the next version, so re-running the job converges every workflow
// on the shipped document and activates it (which retires older versions and
// arms its schedules).
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

// SyncFromDir submits every *.json workflow in dir to trustage and makes sure
// the resulting version is active.
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

	activated := 0
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".json") {
			continue
		}
		path := filepath.Join(dir, entry.Name())
		didActivate, syncErr := syncOne(ctx, cli, path, env)
		if syncErr != nil {
			return fmt.Errorf("sync %s: %w", entry.Name(), syncErr)
		}
		if didActivate {
			activated++
		}
	}
	log.WithField("activated", activated).Info("trustage workflows synced")
	return nil
}

func syncOne(ctx context.Context, cli Client, path string, env Env) (bool, error) {
	dsl, name, err := loadDSL(path, env)
	if err != nil {
		return false, err
	}

	createResp, err := cli.CreateWorkflow(ctx, connect.NewRequest(
		workflowv1.CreateWorkflowRequest_builder{Dsl: dsl}.Build(),
	))
	if err != nil {
		return false, fmt.Errorf("create workflow: %w", err)
	}
	wf := createResp.Msg.GetWorkflow()
	log := util.Log(ctx).WithFields(map[string]any{
		"workflow": name,
		"id":       wf.GetId(),
		"version":  wf.GetVersion(),
	})
	if wf.GetStatus() == workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE {
		log.Debug("trustage workflow unchanged")
		return false, nil
	}

	if _, err = cli.ActivateWorkflow(ctx, connect.NewRequest(
		workflowv1.ActivateWorkflowRequest_builder{Id: wf.GetId()}.Build(),
	)); err != nil {
		return false, fmt.Errorf("activate workflow %s: %w", wf.GetId(), err)
	}
	log.Info("trustage workflow activated")
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
	// Trustage only fires what is listed under "schedules" (cron_expr per
	// entry); a scheduled automation without one would register, activate and
	// then never run, so refuse it here where the mistake is cheap.
	schedules := dsl.GetFields()["schedules"].GetListValue().GetValues()
	if len(schedules) == 0 {
		return nil, "", fmt.Errorf("%s: at least one entry under \"schedules\" is required", path)
	}
	for i, sched := range schedules {
		if sched.GetStructValue().GetFields()["cron_expr"].GetStringValue() == "" {
			return nil, "", fmt.Errorf("%s: schedules[%d] needs a cron_expr", path, i)
		}
	}
	return dsl, name, nil
}
