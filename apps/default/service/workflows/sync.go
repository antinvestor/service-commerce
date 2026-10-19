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
// trustage orchestrator from the setup job, the same way the notification
// templates are registered: declared once (the DSL documents embedded from
// the repository's workflows directory), synced idempotently on every
// deploy, warn-only unless Required.
//
// Trustage's CreateWorkflow is idempotent by name: an identical live version
// comes back as-is and a changed document becomes the next version, which the
// sync activates (retiring the previous one and arming its schedules).
// Active commerce workflows that are no longer shipped are archived, so
// deleting a document stops its schedule.
package workflows

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"path"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	workflowv1 "buf.build/gen/go/antinvestor/workflow/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/setup"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/types/known/structpb"
)

// SetupStepName is the setup-plan step that registers workflows. Like the
// notification step it is not setup.NameBootstrap, since frame keeps one
// step per name.
const SetupStepName = "trustage-workflows"

// NamePrefix scopes the workflows commerce owns in trustage. Every document
// must use it, and only workflows carrying it are ever archived.
const NamePrefix = "commerce."

const (
	uriPlaceholder = "${COMMERCE_URI}"
	listPageSize   = 100
)

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
	ListWorkflows(
		context.Context,
		*connect.Request[workflowv1.ListWorkflowsRequest],
	) (*connect.Response[workflowv1.ListWorkflowsResponse], error)
	ArchiveWorkflow(
		context.Context,
		*connect.Request[workflowv1.ArchiveWorkflowRequest],
	) (*connect.Response[workflowv1.ArchiveWorkflowResponse], error)
}

// Env values substituted into the DSL before registration, so one set of
// documents serves every environment.
type Env struct {
	// CommerceURI is the base URL trustage calls back into.
	CommerceURI string
}

// SyncOption tunes RegisterSync.
type SyncOption func(*syncOptions)

type syncOptions struct {
	required bool
}

// Required makes a failed sync fail the setup job. The default is warn-only
// (logged at ERROR, plan continues) so a trustage outage never blocks a
// rollout; the documents converge on the next deploy.
func Required() SyncOption {
	return func(o *syncOptions) { o.required = true }
}

// RegisterSync adds the workflow sync to the service's setup plan. With no
// client (trustage not configured) the step logs and succeeds. The documents
// are validated before anything is sent, so a malformed document never
// half-registers a set.
func RegisterSync(svc *frame.Service, cli Client, defs fs.FS, env Env, opts ...SyncOption) {
	o := syncOptions{}
	for _, opt := range opts {
		opt(&o)
	}
	svc.Setup().Register(setup.Func{
		StepName: SetupStepName,
		Fn: func(ctx context.Context) error {
			log := util.Log(ctx)
			if cli == nil {
				log.Info("trustage workflow sync skipped: no endpoint configured")
				return nil
			}
			err := Sync(ctx, cli, defs, env)
			if err == nil || o.required {
				return err
			}
			log.WithError(err).Error("trustage workflow sync failed; continuing")
			return nil
		},
	})
}

// Document is one validated workflow definition ready to submit.
type Document struct {
	// File is the document's file name; Name the workflow name it defines.
	File string
	Name string
	DSL  *structpb.Struct
}

// Sync registers every document in defs with trustage, activates versions
// that are not yet live, and archives active commerce workflows that are no
// longer shipped.
func Sync(ctx context.Context, cli Client, defs fs.FS, env Env) error {
	docs, err := Load(defs, env)
	if err != nil {
		return err
	}

	shipped := make(map[string]bool, len(docs))
	activated := 0
	for _, doc := range docs {
		didActivate, syncErr := syncOne(ctx, cli, doc)
		if syncErr != nil {
			return fmt.Errorf("sync %s: %w", doc.File, syncErr)
		}
		shipped[doc.Name] = true
		if didActivate {
			activated++
		}
	}

	archived, err := archiveRetired(ctx, cli, shipped)
	if err != nil {
		return err
	}
	util.Log(ctx).WithFields(map[string]any{
		"workflows": len(docs), "activated": activated, "archived": archived,
	}).Info("trustage workflows synced")
	return nil
}

// Load reads and validates every *.json document in defs with the
// environment substituted. It refuses to produce callback URLs without a
// commerce address, which would register workflows that can never succeed.
func Load(defs fs.FS, env Env) ([]Document, error) {
	base := strings.TrimRight(strings.TrimSpace(env.CommerceURI), "/")
	if base == "" {
		return nil, errors.New("COMMERCE_SERVICE_URI is required to register trustage workflows")
	}
	files, err := fs.Glob(defs, "*.json")
	if err != nil {
		return nil, fmt.Errorf("list workflow documents: %w", err)
	}
	docs := make([]Document, 0, len(files))
	seen := map[string]string{}
	for _, file := range files {
		doc, loadErr := loadOne(defs, file, base)
		if loadErr != nil {
			return nil, loadErr
		}
		if other, dup := seen[doc.Name]; dup {
			return nil, fmt.Errorf("%s and %s both define workflow %s", other, file, doc.Name)
		}
		seen[doc.Name] = file
		docs = append(docs, doc)
	}
	return docs, nil
}

func loadOne(defs fs.FS, file, base string) (Document, error) {
	raw, err := fs.ReadFile(defs, file)
	if err != nil {
		return Document{}, fmt.Errorf("read %s: %w", file, err)
	}
	text := strings.ReplaceAll(string(raw), uriPlaceholder, base)

	dsl := &structpb.Struct{}
	if err = protojson.Unmarshal([]byte(text), dsl); err != nil {
		return Document{}, fmt.Errorf("parse %s: %w", file, err)
	}
	name := dsl.GetFields()["name"].GetStringValue()
	if !strings.HasPrefix(name, NamePrefix) || len(name) == len(NamePrefix) {
		return Document{}, fmt.Errorf("%s: workflow name must start with %q", file, NamePrefix)
	}
	// Trustage only fires what is listed under "schedules" (cron_expr per
	// entry); a scheduled automation without one would register, activate and
	// then never run, so refuse it here where the mistake is cheap.
	schedules := dsl.GetFields()["schedules"].GetListValue().GetValues()
	if len(schedules) == 0 {
		return Document{}, fmt.Errorf("%s: at least one entry under \"schedules\" is required", file)
	}
	for i, sched := range schedules {
		if sched.GetStructValue().GetFields()["cron_expr"].GetStringValue() == "" {
			return Document{}, fmt.Errorf("%s: schedules[%d] needs a cron_expr", file, i)
		}
	}
	if strings.Contains(text, "${") {
		return Document{}, fmt.Errorf("%s: unresolved placeholder", file)
	}
	return Document{File: path.Base(file), Name: name, DSL: dsl}, nil
}

func syncOne(ctx context.Context, cli Client, doc Document) (bool, error) {
	createResp, err := cli.CreateWorkflow(ctx, connect.NewRequest(
		workflowv1.CreateWorkflowRequest_builder{Dsl: doc.DSL}.Build(),
	))
	if err != nil {
		return false, fmt.Errorf("create workflow: %w", err)
	}
	wf := createResp.Msg.GetWorkflow()
	log := util.Log(ctx).WithFields(map[string]any{
		"workflow": doc.Name, "id": wf.GetId(), "version": wf.GetVersion(),
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

// archiveRetired archives active commerce workflows whose document is gone.
func archiveRetired(ctx context.Context, cli Client, shipped map[string]bool) (int, error) {
	archived := 0
	var cursor *commonv1.PageCursor
	for {
		search := commonv1.SearchRequest_builder{
			Cursor: commonv1.PageCursor_builder{Limit: listPageSize, Page: cursor.GetPage()}.Build(),
		}.Build()
		resp, err := cli.ListWorkflows(ctx, connect.NewRequest(workflowv1.ListWorkflowsRequest_builder{
			Status: workflowv1.WorkflowStatus_WORKFLOW_STATUS_ACTIVE,
			Search: search,
		}.Build()))
		if err != nil {
			return archived, fmt.Errorf("list active workflows: %w", err)
		}
		for _, wf := range resp.Msg.GetItems() {
			if !strings.HasPrefix(wf.GetName(), NamePrefix) || shipped[wf.GetName()] {
				continue
			}
			if _, err = cli.ArchiveWorkflow(ctx, connect.NewRequest(
				workflowv1.ArchiveWorkflowRequest_builder{Id: wf.GetId()}.Build(),
			)); err != nil {
				return archived, fmt.Errorf("archive retired workflow %s: %w", wf.GetName(), err)
			}
			util.Log(ctx).WithField("workflow", wf.GetName()).Info("retired trustage workflow archived")
			archived++
		}
		cursor = resp.Msg.GetNextCursor()
		if cursor.GetPage() == "" || len(resp.Msg.GetItems()) == 0 {
			return archived, nil
		}
	}
}
