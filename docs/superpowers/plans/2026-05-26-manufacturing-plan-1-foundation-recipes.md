# Manufacturing Service — Plan 1: Foundation + Facility + Recipe Management

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `service-manufacturing` repository and implement facility CRUD and full recipe management (CRUD, versioning, template library) as the foundation for production planning and batch execution in Plans 2 and 3.

**Architecture:** Single Go service (`apps/default`) following the Frame blueprint pattern identical to `service-commerce`. Connect RPC for all APIs. Three-layer architecture: handlers → business → repository. Facility replaces shop as the resource-level entity. Recipes are versioned process templates with embedded BOMs.

**Tech Stack:** Go 1.26, Frame v1.97.6, Connect RPC, PostgreSQL, GORM, Ory Keto (ReBAC), testcontainers, buf.build for proto.

**Spec:** See `docs/superpowers/specs/2026-05-26-recipe-driven-manufacturing-design.md` in `service-commerce` for the full design.

**Scope of this plan:** Foundation scaffolding, facility CRUD, recipe CRUD with versioning and template cloning. Production plans, batches, inventory, and integration are in Plans 2 and 3.

---

## File Structure

```text
service-manufacturing/
├── apps/
│   └── default/
│       ├── cmd/main.go
│       ├── config/config.go
│       ├── service/
│       │   ├── authz/
│       │   │   ├── constants.go
│       │   │   ├── interfaces.go
│       │   │   ├── role_mapping.go
│       │   │   └── middleware.go
│       │   ├── business/
│       │   │   ├── constants.go
│       │   │   ├── facilities.go
│       │   │   └── recipes.go
│       │   ├── handlers/
│       │   │   └── manufacturing.go
│       │   ├── models/
│       │   │   └── models.go
│       │   └── repository/
│       │       ├── interfaces.go
│       │       ├── migrate.go
│       │       ├── facilities.go
│       │       └── recipes.go
│       └── tests/
│           ├── base_testsuite.go
│           ├── testketo/keto.go
│           ├── facility_test.go
│           └── recipe_test.go
├── proto/
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   ├── buf.lock
│   └── manufacturing/v1/manufacturing.proto
├── opl/
│   └── manufacturing/
├── pkg/
│   └── errorutil/errorutil.go
├── go.mod
├── go.sum
├── Makefile
├── .gitignore
└── .golangci.yaml
```

---

## Task 1: Initialize Repository and Go Module

**Files:**
- Create: `go.mod`
- Create: `Makefile`
- Create: `.gitignore`
- Create: `.golangci.yaml`

- [ ] **Step 1: Create repository and initialize Go module**

```bash
mkdir -p ~/code/antinvestor/service-manufacturing
cd ~/code/antinvestor/service-manufacturing
git init
go mod init github.com/antinvestor/service-manufacturing
```

- [ ] **Step 2: Create .gitignore**

Create `.gitignore`:

```gitignore
cmd
.tmp/
*.exe
*.test
*.out
vendor/
.idea/
.vscode/
```

- [ ] **Step 3: Create Makefile**

Create `Makefile`:

```makefile
SERVICE_NAME := manufacturing
APP_DIRS     := apps/default

ifeq (,$(wildcard .tmp/Makefile.common))
  $(shell mkdir -p .tmp && curl -sSfL https://raw.githubusercontent.com/antinvestor/common/main/Makefile.common -o .tmp/Makefile.common)
endif

include .tmp/Makefile.common
```

- [ ] **Step 4: Copy golangci.yaml from service-commerce**

```bash
cp ~/code/antinvestor/service-commerce/.golangci.yaml .golangci.yaml
```

- [ ] **Step 5: Create directory structure**

```bash
mkdir -p apps/default/cmd
mkdir -p apps/default/config
mkdir -p apps/default/service/{authz,business,handlers,models,repository,events}
mkdir -p apps/default/tests/testketo
mkdir -p apps/default/migrations/0001
mkdir -p proto/manufacturing/v1
mkdir -p opl/manufacturing
mkdir -p pkg/errorutil
mkdir -p sdk
```

- [ ] **Step 6: Commit scaffold**

```bash
git add -A
git commit -m "chore: scaffold service-manufacturing repository"
```

---

## Task 2: Proto Definition — Facility and Recipe APIs

**Files:**
- Create: `proto/buf.yaml`
- Create: `proto/buf.gen.yaml`
- Create: `proto/manufacturing/v1/manufacturing.proto`

- [ ] **Step 1: Create buf.yaml**

Create `proto/buf.yaml`:

```yaml
version: v2
modules:
  - path: manufacturing
    name: buf.build/antinvestor/manufacturing
deps:
  - buf.build/antinvestor/common
  - buf.build/bufbuild/protovalidate
  - buf.build/gnostic/gnostic
lint:
  use:
    - STANDARD
breaking:
  use:
    - FILE
```

- [ ] **Step 2: Create buf.gen.yaml**

Create `proto/buf.gen.yaml`:

```yaml
version: v2
plugins:
  - remote: buf.build/protocolbuffers/go
    out: gen/go
    opt: paths=source_relative
  - remote: buf.build/connectrpc/go
    out: gen/go
    opt: paths=source_relative
managed:
  enabled: true
  override:
    - file_option: go_package_prefix
      value: github.com/antinvestor/apis/go
```

- [ ] **Step 3: Create manufacturing.proto**

Create `proto/manufacturing/v1/manufacturing.proto`:

```protobuf
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

syntax = "proto3";

package manufacturing.v1;

import "buf/validate/validate.proto";
import "common/v1/common.proto";
import "common/v1/permissions.proto";
import "gnostic/openapi/v3/annotations.proto";
import "google/protobuf/field_mask.proto";
import "google/protobuf/struct.proto";
import "google/protobuf/timestamp.proto";

option go_package = "github.com/antinvestor/apis/go/manufacturing/v1;manufacturingv1";
option java_multiple_files = true;
option java_package = "manufacturingv1";
option (gnostic.openapi.v3.document) = {
  info: {
    title: "Manufacturing API"
    version: "v1.0.0"
    description: "The Manufacturing API provides recipe management, production planning, batch execution, and inventory management for manufacturing facilities."
    contact: {
      name: "Ant Investor Ltd"
      url: "https://github.com/antinvestor/service-manufacturing"
      email: "info@antinvestor.com"
    }
    license: {
      name: "Apache License"
      url: "https://github.com/antinvestor/apis/blob/master/LICENSE"
    }
  }
  components: {
    security_schemes: {
      additional_properties: [
        {
          name: "BearerAuth"
          value: {
            security_scheme: {
              type: "http"
              scheme: "bearer"
              bearer_format: "JWT"
            }
          }
        }
      ]
    }
  }
};

service ManufacturingService {
  option (common.v1.service_permissions) = {
    namespace: "service_manufacturing"
    permissions: [
      "facility_view",
      "facility_create",
      "facility_update",
      "recipe_view",
      "recipe_manage",
      "plan_view",
      "plan_manage",
      "plan_validate",
      "batch_view",
      "batch_operate",
      "batch_complete",
      "batch_override",
      "inventory_view",
      "inventory_manage",
      "inventory_adjust"
    ]
    role_bindings: [
      {
        role: ROLE_OWNER
        permissions: [
          "facility_view", "facility_create", "facility_update",
          "recipe_view", "recipe_manage",
          "plan_view", "plan_manage", "plan_validate",
          "batch_view", "batch_operate", "batch_complete", "batch_override",
          "inventory_view", "inventory_manage", "inventory_adjust"
        ]
      },
      {
        role: ROLE_ADMIN
        permissions: [
          "facility_view", "facility_create", "facility_update",
          "recipe_view", "recipe_manage",
          "plan_view", "plan_manage", "plan_validate",
          "batch_view", "batch_operate", "batch_complete", "batch_override",
          "inventory_view", "inventory_manage", "inventory_adjust"
        ]
      },
      {
        role: ROLE_OPERATOR
        permissions: [
          "facility_view",
          "recipe_view",
          "plan_view",
          "batch_view", "batch_operate",
          "inventory_view"
        ]
      },
      {
        role: ROLE_VIEWER
        permissions: [
          "facility_view",
          "recipe_view",
          "plan_view",
          "batch_view",
          "inventory_view"
        ]
      },
      {
        role: ROLE_SERVICE
        permissions: [
          "facility_view", "facility_create", "facility_update",
          "recipe_view", "recipe_manage",
          "plan_view", "plan_manage", "plan_validate",
          "batch_view", "batch_operate", "batch_complete", "batch_override",
          "inventory_view", "inventory_manage", "inventory_adjust"
        ]
      }
    ]
  };

  // ---- Facility ----

  rpc CreateFacility(CreateFacilityRequest) returns (CreateFacilityResponse) {
    option (common.v1.method_permissions) = { permissions: ["facility_create"] };
  }
  rpc GetFacility(GetFacilityRequest) returns (GetFacilityResponse) {
    option (common.v1.method_permissions) = { permissions: ["facility_view"] };
  }
  rpc UpdateFacility(UpdateFacilityRequest) returns (UpdateFacilityResponse) {
    option (common.v1.method_permissions) = { permissions: ["facility_update"] };
  }
  rpc ListFacilities(ListFacilitiesRequest) returns (ListFacilitiesResponse) {
    option (common.v1.method_permissions) = { permissions: ["facility_view"] };
  }

  // ---- Recipe ----

  rpc CreateRecipe(CreateRecipeRequest) returns (CreateRecipeResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_manage"] };
  }
  rpc GetRecipe(GetRecipeRequest) returns (GetRecipeResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_view"] };
  }
  rpc ListRecipes(ListRecipesRequest) returns (ListRecipesResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_view"] };
  }
  rpc UpdateRecipeDraft(UpdateRecipeDraftRequest) returns (UpdateRecipeDraftResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_manage"] };
  }
  rpc PublishRecipeVersion(PublishRecipeVersionRequest) returns (PublishRecipeVersionResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_manage"] };
  }
  rpc GetRecipeVersion(GetRecipeVersionRequest) returns (GetRecipeVersionResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_view"] };
  }
  rpc ListRecipeVersions(ListRecipeVersionsRequest) returns (ListRecipeVersionsResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_view"] };
  }

  // ---- Recipe Templates ----

  rpc ListRecipeTemplates(ListRecipeTemplatesRequest) returns (ListRecipeTemplatesResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_view"] };
  }
  rpc CloneRecipeTemplate(CloneRecipeTemplateRequest) returns (CloneRecipeTemplateResponse) {
    option (common.v1.method_permissions) = { permissions: ["recipe_manage"] };
  }
}

// ---- Facility Messages ----

enum FacilityStatus {
  FACILITY_STATUS_UNSPECIFIED = 0;
  FACILITY_STATUS_ACTIVE = 1;
  FACILITY_STATUS_INACTIVE = 2;
}

message Facility {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string name = 2;
  string description = 3;
  string location = 4;
  FacilityStatus status = 5;
  google.protobuf.Struct properties = 6;
  google.protobuf.Timestamp created_at = 10;
}

message CreateFacilityRequest {
  string name = 1;
  string description = 2;
  string location = 3;
}

message CreateFacilityResponse {
  Facility facility = 1;
}

message GetFacilityRequest {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
}

message GetFacilityResponse {
  Facility facility = 1;
}

message UpdateFacilityRequest {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  google.protobuf.FieldMask update_mask = 2;
  string name = 3;
  string description = 4;
  string location = 5;
  FacilityStatus status = 6;
  google.protobuf.Struct properties = 7;
}

message UpdateFacilityResponse {
  Facility facility = 1;
}

message ListFacilitiesRequest {
  common.v1.SearchRequest search = 1;
}

message ListFacilitiesResponse {
  repeated Facility facilities = 1;
  string next_page = 2;
}

// ---- Recipe Messages ----

enum RecipeStatus {
  RECIPE_STATUS_UNSPECIFIED = 0;
  RECIPE_STATUS_DRAFT = 1;
  RECIPE_STATUS_ACTIVE = 2;
  RECIPE_STATUS_ARCHIVED = 3;
}

enum RecipeVersionStatus {
  RECIPE_VERSION_STATUS_UNSPECIFIED = 0;
  RECIPE_VERSION_STATUS_DRAFT = 1;
  RECIPE_VERSION_STATUS_PUBLISHED = 2;
  RECIPE_VERSION_STATUS_SUPERSEDED = 3;
}

message Recipe {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string facility_id = 2;
  string name = 3;
  string description = 4;
  string product_item_id = 5;
  double output_quantity = 6;
  string output_unit = 7;
  RecipeStatus status = 8;
  string active_version_id = 9;
  string template_source_id = 10;
  google.protobuf.Timestamp created_at = 15;
}

message RecipeVersion {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string recipe_id = 2;
  int32 version_number = 3;
  RecipeVersionStatus status = 4;
  string created_by = 5;
  google.protobuf.Timestamp published_at = 6;
  string notes = 7;
  repeated RecipeStep steps = 10;
  repeated RecipeMaterial materials = 11;
  google.protobuf.Timestamp created_at = 15;
}

message RecipeStep {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  int32 sequence = 2;
  string name = 3;
  string description = 4;
  int32 expected_duration_minutes = 5;
  int32 max_duration_minutes = 6;
  bool is_checkpoint = 7;
  repeated ReadingSpec required_readings = 8;
  repeated AlarmRule alarm_rules = 9;
}

message ReadingSpec {
  string reading_type = 1;
  string unit = 2;
  double min_value = 3;
  double max_value = 4;
  bool is_required = 5;
}

message AlarmRule {
  string trigger = 1;
  string reading_type = 2;
  string severity = 3;
  string message = 4;
  bool requires_acknowledgement = 5;
}

message RecipeMaterial {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string inventory_item_id = 2;
  string name = 3;
  double quantity = 4;
  string unit = 5;
  bool is_optional = 6;
  double tolerance_percent = 7;
}

message CreateRecipeRequest {
  string facility_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string name = 2;
  string description = 3;
  string product_item_id = 4;
  double output_quantity = 5;
  string output_unit = 6;
}

message CreateRecipeResponse {
  Recipe recipe = 1;
  RecipeVersion draft_version = 2;
}

message GetRecipeRequest {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
}

message GetRecipeResponse {
  Recipe recipe = 1;
}

message ListRecipesRequest {
  string facility_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  common.v1.SearchRequest search = 2;
}

message ListRecipesResponse {
  repeated Recipe recipes = 1;
  string next_page = 2;
}

message RecipeStepInput {
  int32 sequence = 1;
  string name = 2;
  string description = 3;
  int32 expected_duration_minutes = 4;
  int32 max_duration_minutes = 5;
  bool is_checkpoint = 6;
  repeated ReadingSpec required_readings = 7;
  repeated AlarmRule alarm_rules = 8;
}

message RecipeMaterialInput {
  string inventory_item_id = 1;
  string name = 2;
  double quantity = 3;
  string unit = 4;
  bool is_optional = 5;
  double tolerance_percent = 6;
}

message UpdateRecipeDraftRequest {
  string recipe_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string name = 2;
  string description = 3;
  double output_quantity = 4;
  string output_unit = 5;
  repeated RecipeStepInput steps = 10;
  repeated RecipeMaterialInput materials = 11;
}

message UpdateRecipeDraftResponse {
  RecipeVersion draft_version = 1;
}

message PublishRecipeVersionRequest {
  string recipe_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string notes = 2;
}

message PublishRecipeVersionResponse {
  RecipeVersion published_version = 1;
  RecipeVersion new_draft_version = 2;
}

message GetRecipeVersionRequest {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
}

message GetRecipeVersionResponse {
  RecipeVersion version = 1;
}

message ListRecipeVersionsRequest {
  string recipe_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
}

message ListRecipeVersionsResponse {
  repeated RecipeVersion versions = 1;
}

// ---- Recipe Template Messages ----

message RecipeTemplate {
  string id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string name = 2;
  string description = 3;
  string category = 4;
  RecipeTemplateStatus status = 5;
  google.protobuf.Timestamp created_at = 10;
}

enum RecipeTemplateStatus {
  RECIPE_TEMPLATE_STATUS_UNSPECIFIED = 0;
  RECIPE_TEMPLATE_STATUS_ACTIVE = 1;
  RECIPE_TEMPLATE_STATUS_DEPRECATED = 2;
}

message ListRecipeTemplatesRequest {
  string category = 1;
  common.v1.SearchRequest search = 2;
}

message ListRecipeTemplatesResponse {
  repeated RecipeTemplate templates = 1;
  string next_page = 2;
}

message CloneRecipeTemplateRequest {
  string template_id = 1 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string facility_id = 2 [
    (buf.validate.field).string.min_len = 3,
    (buf.validate.field).string.max_len = 40,
    (buf.validate.field).string.pattern = "[0-9a-z_-]{3,40}"
  ];
  string name = 3;
}

message CloneRecipeTemplateResponse {
  Recipe recipe = 1;
  RecipeVersion draft_version = 2;
}
```

- [ ] **Step 4: Run buf lint**

```bash
cd proto && buf lint
```

Expected: no errors.

- [ ] **Step 5: Push proto to BSR**

```bash
cd proto && buf push manufacturing
```

Expected: module pushed to `buf.build/antinvestor/manufacturing`.

- [ ] **Step 6: Add generated proto dependencies to go.mod**

```bash
cd ~/code/antinvestor/service-manufacturing
go get buf.build/gen/go/antinvestor/manufacturing/connectrpc/go@latest
go get buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go@latest
go get buf.build/gen/go/antinvestor/common/protocolbuffers/go@latest
go get connectrpc.com/connect@latest
go get github.com/pitabwire/frame@v1.97.6
go get github.com/pitabwire/util@latest
go get github.com/antinvestor/common@latest
go get github.com/stretchr/testify@latest
go get google.golang.org/protobuf@latest
go get gorm.io/gorm@latest
```

- [ ] **Step 7: Commit proto**

```bash
git add -A
git commit -m "feat: add manufacturing proto with facility and recipe APIs"
```

---

## Task 3: Models

**Files:**
- Create: `apps/default/service/models/models.go`

- [ ] **Step 1: Create models file**

Create `apps/default/service/models/models.go`:

```go
package models

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/data"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"
)

// JSONBSlice stores a typed slice as JSONB in PostgreSQL.
type JSONBSlice[T any] []T

func (s *JSONBSlice[T]) Value() (driver.Value, error) {
	if s == nil || *s == nil {
		return "[]", nil
	}
	return json.Marshal(*s)
}

func (s *JSONBSlice[T]) Scan(value any) error {
	if value == nil {
		*s = nil
		return nil
	}
	b, ok := value.([]byte)
	if !ok {
		return fmt.Errorf("JSONBSlice.Scan: expected []byte, got %T", value)
	}
	return json.Unmarshal(b, s)
}

func (*JSONBSlice[T]) GormDataType() string { return "jsonb" }

func (*JSONBSlice[T]) GormDBDataType(db *gorm.DB, _ *schema.Field) string {
	switch db.Dialector.Name() {
	case "postgres":
		return "JSONB"
	default:
		return "JSON"
	}
}

// ReadingSpecJSON is the JSON-serializable reading spec for recipe steps.
type ReadingSpecJSON struct {
	ReadingType string  `json:"reading_type"`
	Unit        string  `json:"unit"`
	MinValue    float64 `json:"min_value"`
	MaxValue    float64 `json:"max_value"`
	IsRequired  bool    `json:"is_required"`
}

// AlarmRuleJSON is the JSON-serializable alarm rule for recipe steps.
type AlarmRuleJSON struct {
	Trigger                 string `json:"trigger"`
	ReadingType             string `json:"reading_type"`
	Severity                string `json:"severity"`
	Message                 string `json:"message"`
	RequiresAcknowledgement bool   `json:"requires_acknowledgement"`
}

// TemplateDataJSON is the JSON structure for recipe template data.
type TemplateDataJSON struct {
	OutputQuantity float64                `json:"output_quantity"`
	OutputUnit     string                 `json:"output_unit"`
	Steps          []TemplateStepJSON     `json:"steps"`
	Materials      []TemplateMaterialJSON `json:"materials"`
}

// TemplateStepJSON is a step within template data.
type TemplateStepJSON struct {
	Sequence                int               `json:"sequence"`
	Name                    string            `json:"name"`
	Description             string            `json:"description"`
	ExpectedDurationMinutes int               `json:"expected_duration_minutes"`
	MaxDurationMinutes      int               `json:"max_duration_minutes"`
	IsCheckpoint            bool              `json:"is_checkpoint"`
	RequiredReadings        []ReadingSpecJSON  `json:"required_readings"`
	AlarmRules              []AlarmRuleJSON    `json:"alarm_rules"`
}

// TemplateMaterialJSON is a material within template data.
type TemplateMaterialJSON struct {
	Name             string  `json:"name"`
	Quantity         float64 `json:"quantity"`
	Unit             string  `json:"unit"`
	IsOptional       bool    `json:"is_optional"`
	TolerancePercent float64 `json:"tolerance_percent"`
}

// ---- Facility ----

type Facility struct {
	data.BaseModel
	Name        string `gorm:"type:varchar(255)"`
	Description string `gorm:"type:text"`
	Location    string `gorm:"type:varchar(500)"`
	Status      int32  `gorm:"default:1"`
	Properties  data.JSONMap
}

func (f *Facility) ToAPI() *manufacturingv1.Facility {
	return &manufacturingv1.Facility{
		Id:          f.ID,
		Name:        f.Name,
		Description: f.Description,
		Location:    f.Location,
		Status:      manufacturingv1.FacilityStatus(f.Status),
		Properties:  f.Properties.ToProtoStruct(),
		CreatedAt:   timestamppb.New(f.CreatedAt),
	}
}

// ---- Recipe ----

type Recipe struct {
	data.BaseModel
	FacilityID       string `gorm:"type:varchar(50);index:idx_recipe_facility_id"`
	Name             string `gorm:"type:varchar(255)"`
	Description      string `gorm:"type:text"`
	ProductItemID    string `gorm:"type:varchar(50)"`
	OutputQuantity   float64
	OutputUnit       string `gorm:"type:varchar(50)"`
	Status           int32  `gorm:"default:1"`
	ActiveVersionID  string `gorm:"type:varchar(50)"`
	TemplateSourceID string `gorm:"type:varchar(50)"`
}

func (r *Recipe) ToAPI() *manufacturingv1.Recipe {
	return &manufacturingv1.Recipe{
		Id:               r.ID,
		FacilityId:       r.FacilityID,
		Name:             r.Name,
		Description:      r.Description,
		ProductItemId:    r.ProductItemID,
		OutputQuantity:   r.OutputQuantity,
		OutputUnit:       r.OutputUnit,
		Status:           manufacturingv1.RecipeStatus(r.Status),
		ActiveVersionId:  r.ActiveVersionID,
		TemplateSourceId: r.TemplateSourceID,
		CreatedAt:        timestamppb.New(r.CreatedAt),
	}
}

// ---- RecipeVersion ----

type RecipeVersion struct {
	data.BaseModel
	RecipeID      string `gorm:"type:varchar(50);index:idx_recipe_version_recipe_id"`
	VersionNumber int32
	Status        int32  `gorm:"default:1"`
	CreatedBy     string `gorm:"type:varchar(50)"`
	PublishedAt   *data.NullableTime
	Notes         string `gorm:"type:text"`

	Steps     []*RecipeStep     `gorm:"foreignKey:RecipeVersionID"`
	Materials []*RecipeMaterial `gorm:"foreignKey:RecipeVersionID"`
}

func (rv *RecipeVersion) ToAPI() *manufacturingv1.RecipeVersion {
	v := &manufacturingv1.RecipeVersion{
		Id:            rv.ID,
		RecipeId:      rv.RecipeID,
		VersionNumber: rv.VersionNumber,
		Status:        manufacturingv1.RecipeVersionStatus(rv.Status),
		CreatedBy:     rv.CreatedBy,
		Notes:         rv.Notes,
		CreatedAt:     timestamppb.New(rv.CreatedAt),
	}
	if rv.PublishedAt != nil && rv.PublishedAt.Valid {
		v.PublishedAt = timestamppb.New(rv.PublishedAt.Time)
	}
	for _, s := range rv.Steps {
		v.Steps = append(v.Steps, s.ToAPI())
	}
	for _, m := range rv.Materials {
		v.Materials = append(v.Materials, m.ToAPI())
	}
	return v
}

// ---- RecipeStep ----

type RecipeStep struct {
	data.BaseModel
	RecipeVersionID         string `gorm:"type:varchar(50);index:idx_recipe_step_version_id"`
	Sequence                int32
	Name                    string `gorm:"type:varchar(255)"`
	Description             string `gorm:"type:text"`
	ExpectedDurationMinutes int32
	MaxDurationMinutes      int32
	IsCheckpoint            bool
	RequiredReadings        JSONBSlice[ReadingSpecJSON]
	AlarmRules              JSONBSlice[AlarmRuleJSON]
}

func (rs *RecipeStep) ToAPI() *manufacturingv1.RecipeStep {
	step := &manufacturingv1.RecipeStep{
		Id:                      rs.ID,
		Sequence:                rs.Sequence,
		Name:                    rs.Name,
		Description:             rs.Description,
		ExpectedDurationMinutes: rs.ExpectedDurationMinutes,
		MaxDurationMinutes:      rs.MaxDurationMinutes,
		IsCheckpoint:            rs.IsCheckpoint,
	}
	for _, r := range rs.RequiredReadings {
		step.RequiredReadings = append(step.RequiredReadings, &manufacturingv1.ReadingSpec{
			ReadingType: r.ReadingType,
			Unit:        r.Unit,
			MinValue:    r.MinValue,
			MaxValue:    r.MaxValue,
			IsRequired:  r.IsRequired,
		})
	}
	for _, a := range rs.AlarmRules {
		step.AlarmRules = append(step.AlarmRules, &manufacturingv1.AlarmRule{
			Trigger:                 a.Trigger,
			ReadingType:             a.ReadingType,
			Severity:                a.Severity,
			Message:                 a.Message,
			RequiresAcknowledgement: a.RequiresAcknowledgement,
		})
	}
	return step
}

// ---- RecipeMaterial ----

type RecipeMaterial struct {
	data.BaseModel
	RecipeVersionID  string `gorm:"type:varchar(50);index:idx_recipe_material_version_id"`
	InventoryItemID  string `gorm:"type:varchar(50)"`
	Name             string `gorm:"type:varchar(255)"`
	Quantity         float64
	Unit             string `gorm:"type:varchar(50)"`
	IsOptional       bool
	TolerancePercent float64
}

func (rm *RecipeMaterial) ToAPI() *manufacturingv1.RecipeMaterial {
	return &manufacturingv1.RecipeMaterial{
		Id:               rm.ID,
		InventoryItemId:  rm.InventoryItemID,
		Name:             rm.Name,
		Quantity:         rm.Quantity,
		Unit:             rm.Unit,
		IsOptional:       rm.IsOptional,
		TolerancePercent: rm.TolerancePercent,
	}
}

// ---- RecipeTemplate ----

type RecipeTemplate struct {
	data.BaseModel
	Name         string `gorm:"type:varchar(255)"`
	Description  string `gorm:"type:text"`
	Category     string `gorm:"type:varchar(100);index:idx_template_category"`
	TemplateData JSONBSlice[TemplateDataJSON]
	Status       int32 `gorm:"default:1"`
}

func (rt *RecipeTemplate) ToAPI() *manufacturingv1.RecipeTemplate {
	return &manufacturingv1.RecipeTemplate{
		Id:          rt.ID,
		Name:        rt.Name,
		Description: rt.Description,
		Category:    rt.Category,
		Status:      manufacturingv1.RecipeTemplateStatus(rt.Status),
		CreatedAt:   timestamppb.New(rt.CreatedAt),
	}
}

func (rt *RecipeTemplate) GetData() *TemplateDataJSON {
	if len(rt.TemplateData) == 0 {
		return nil
	}
	return &rt.TemplateData[0]
}
```

- [ ] **Step 2: Verify models compile**

```bash
go build ./apps/default/service/models/...
```

Expected: success.

- [ ] **Step 3: Commit models**

```bash
git add apps/default/service/models/
git commit -m "feat: add manufacturing domain models"
```

---

## Task 4: Migration and Repository Interfaces

**Files:**
- Create: `apps/default/service/repository/interfaces.go`
- Create: `apps/default/service/repository/migrate.go`

- [ ] **Step 1: Create repository interfaces**

Create `apps/default/service/repository/interfaces.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
)

type FacilityRepository interface {
	datastore.BaseRepository[*models.Facility]
	List(ctx context.Context, limit, offset int) ([]*models.Facility, error)
}

type RecipeRepository interface {
	datastore.BaseRepository[*models.Recipe]
	ListByFacilityID(ctx context.Context, facilityID string, limit, offset int) ([]*models.Recipe, error)
}

type RecipeVersionRepository interface {
	datastore.BaseRepository[*models.RecipeVersion]
	GetDraftByRecipeID(ctx context.Context, recipeID string) (*models.RecipeVersion, error)
	GetWithChildren(ctx context.Context, id string) (*models.RecipeVersion, error)
	ListByRecipeID(ctx context.Context, recipeID string) ([]*models.RecipeVersion, error)
	GetPublishedByRecipeID(ctx context.Context, recipeID string) (*models.RecipeVersion, error)
}

type RecipeStepRepository interface {
	datastore.BaseRepository[*models.RecipeStep]
	ListByVersionID(ctx context.Context, versionID string) ([]*models.RecipeStep, error)
	DeleteByVersionID(ctx context.Context, versionID string) error
}

type RecipeMaterialRepository interface {
	datastore.BaseRepository[*models.RecipeMaterial]
	ListByVersionID(ctx context.Context, versionID string) ([]*models.RecipeMaterial, error)
	DeleteByVersionID(ctx context.Context, versionID string) error
}

type RecipeTemplateRepository interface {
	datastore.BaseRepository[*models.RecipeTemplate]
	ListByCategory(ctx context.Context, category string, limit, offset int) ([]*models.RecipeTemplate, error)
	List(ctx context.Context, limit, offset int) ([]*models.RecipeTemplate, error)
}
```

- [ ] **Step 2: Create migration file**

Create `apps/default/service/repository/migrate.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)

	return dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.Facility{},
		&models.Recipe{},
		&models.RecipeVersion{},
		&models.RecipeStep{},
		&models.RecipeMaterial{},
		&models.RecipeTemplate{},
	)
}
```

- [ ] **Step 3: Verify compilation**

```bash
go build ./apps/default/service/repository/...
```

Expected: success.

- [ ] **Step 4: Commit**

```bash
git add apps/default/service/repository/interfaces.go apps/default/service/repository/migrate.go
git commit -m "feat: add repository interfaces and migration"
```

---

## Task 5: Facility Repository

**Files:**
- Create: `apps/default/service/repository/facilities.go`

- [ ] **Step 1: Implement facility repository**

Create `apps/default/service/repository/facilities.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
)

type facilityRepository struct {
	datastore.BaseRepository[*models.Facility]
}

func NewFacilityRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) FacilityRepository {
	return &facilityRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Facility](
			ctx, dbPool, workMan, func() *models.Facility { return &models.Facility{} },
		),
	}
}

func (r *facilityRepository) List(ctx context.Context, limit, offset int) ([]*models.Facility, error) {
	var facilities []*models.Facility
	err := r.Pool().DB(ctx, true).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&facilities).Error
	return facilities, err
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/default/service/repository/...
```

- [ ] **Step 3: Commit**

```bash
git add apps/default/service/repository/facilities.go
git commit -m "feat: add facility repository"
```

---

## Task 6: Recipe Repositories

**Files:**
- Create: `apps/default/service/repository/recipes.go`

- [ ] **Step 1: Implement recipe repositories**

Create `apps/default/service/repository/recipes.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
)

// ---- Recipe ----

type recipeRepository struct {
	datastore.BaseRepository[*models.Recipe]
}

func NewRecipeRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RecipeRepository {
	return &recipeRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Recipe](
			ctx, dbPool, workMan, func() *models.Recipe { return &models.Recipe{} },
		),
	}
}

func (r *recipeRepository) ListByFacilityID(ctx context.Context, facilityID string, limit, offset int) ([]*models.Recipe, error) {
	var recipes []*models.Recipe
	err := r.Pool().DB(ctx, true).
		Where("facility_id = ?", facilityID).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&recipes).Error
	return recipes, err
}

// ---- RecipeVersion ----

type recipeVersionRepository struct {
	datastore.BaseRepository[*models.RecipeVersion]
}

func NewRecipeVersionRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RecipeVersionRepository {
	return &recipeVersionRepository{
		BaseRepository: datastore.NewBaseRepository[*models.RecipeVersion](
			ctx, dbPool, workMan, func() *models.RecipeVersion { return &models.RecipeVersion{} },
		),
	}
}

func (r *recipeVersionRepository) GetDraftByRecipeID(ctx context.Context, recipeID string) (*models.RecipeVersion, error) {
	version := &models.RecipeVersion{}
	err := r.Pool().DB(ctx, true).
		Where("recipe_id = ? AND status = ?", recipeID, int32(1)). // DRAFT = 1
		Preload("Steps", func(db *pool.GormDB) *pool.GormDB { return db.Order("sequence ASC") }).
		Preload("Materials").
		First(version).Error
	return version, err
}

func (r *recipeVersionRepository) GetWithChildren(ctx context.Context, id string) (*models.RecipeVersion, error) {
	version := &models.RecipeVersion{}
	err := r.Pool().DB(ctx, true).
		Preload("Steps", func(db *pool.GormDB) *pool.GormDB { return db.Order("sequence ASC") }).
		Preload("Materials").
		First(version, "id = ?", id).Error
	return version, err
}

func (r *recipeVersionRepository) ListByRecipeID(ctx context.Context, recipeID string) ([]*models.RecipeVersion, error) {
	var versions []*models.RecipeVersion
	err := r.Pool().DB(ctx, true).
		Where("recipe_id = ?", recipeID).
		Order("version_number DESC").
		Find(&versions).Error
	return versions, err
}

func (r *recipeVersionRepository) GetPublishedByRecipeID(ctx context.Context, recipeID string) (*models.RecipeVersion, error) {
	version := &models.RecipeVersion{}
	err := r.Pool().DB(ctx, true).
		Where("recipe_id = ? AND status = ?", recipeID, int32(2)). // PUBLISHED = 2
		Preload("Steps", func(db *pool.GormDB) *pool.GormDB { return db.Order("sequence ASC") }).
		Preload("Materials").
		First(version).Error
	return version, err
}

// ---- RecipeStep ----

type recipeStepRepository struct {
	datastore.BaseRepository[*models.RecipeStep]
}

func NewRecipeStepRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RecipeStepRepository {
	return &recipeStepRepository{
		BaseRepository: datastore.NewBaseRepository[*models.RecipeStep](
			ctx, dbPool, workMan, func() *models.RecipeStep { return &models.RecipeStep{} },
		),
	}
}

func (r *recipeStepRepository) ListByVersionID(ctx context.Context, versionID string) ([]*models.RecipeStep, error) {
	var steps []*models.RecipeStep
	err := r.Pool().DB(ctx, true).
		Where("recipe_version_id = ?", versionID).
		Order("sequence ASC").
		Find(&steps).Error
	return steps, err
}

func (r *recipeStepRepository) DeleteByVersionID(ctx context.Context, versionID string) error {
	return r.Pool().DB(ctx, false).
		Where("recipe_version_id = ?", versionID).
		Delete(&models.RecipeStep{}).Error
}

// ---- RecipeMaterial ----

type recipeMaterialRepository struct {
	datastore.BaseRepository[*models.RecipeMaterial]
}

func NewRecipeMaterialRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RecipeMaterialRepository {
	return &recipeMaterialRepository{
		BaseRepository: datastore.NewBaseRepository[*models.RecipeMaterial](
			ctx, dbPool, workMan, func() *models.RecipeMaterial { return &models.RecipeMaterial{} },
		),
	}
}

func (r *recipeMaterialRepository) ListByVersionID(ctx context.Context, versionID string) ([]*models.RecipeMaterial, error) {
	var materials []*models.RecipeMaterial
	err := r.Pool().DB(ctx, true).
		Where("recipe_version_id = ?", versionID).
		Find(&materials).Error
	return materials, err
}

func (r *recipeMaterialRepository) DeleteByVersionID(ctx context.Context, versionID string) error {
	return r.Pool().DB(ctx, false).
		Where("recipe_version_id = ?", versionID).
		Delete(&models.RecipeMaterial{}).Error
}

// ---- RecipeTemplate ----

type recipeTemplateRepository struct {
	datastore.BaseRepository[*models.RecipeTemplate]
}

func NewRecipeTemplateRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RecipeTemplateRepository {
	return &recipeTemplateRepository{
		BaseRepository: datastore.NewBaseRepository[*models.RecipeTemplate](
			ctx, dbPool, workMan, func() *models.RecipeTemplate { return &models.RecipeTemplate{} },
		),
	}
}

func (r *recipeTemplateRepository) ListByCategory(ctx context.Context, category string, limit, offset int) ([]*models.RecipeTemplate, error) {
	var templates []*models.RecipeTemplate
	err := r.Pool().DB(ctx, true).
		Where("category = ? AND status = ?", category, int32(1)).
		Limit(limit).
		Offset(offset).
		Find(&templates).Error
	return templates, err
}

func (r *recipeTemplateRepository) List(ctx context.Context, limit, offset int) ([]*models.RecipeTemplate, error) {
	var templates []*models.RecipeTemplate
	err := r.Pool().DB(ctx, true).
		Where("status = ?", int32(1)).
		Order("category ASC, name ASC").
		Limit(limit).
		Offset(offset).
		Find(&templates).Error
	return templates, err
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/default/service/repository/...
```

- [ ] **Step 3: Commit**

```bash
git add apps/default/service/repository/recipes.go
git commit -m "feat: add recipe repositories"
```

---

## Task 7: Error Utilities and Config

**Files:**
- Create: `pkg/errorutil/errorutil.go`
- Create: `apps/default/config/config.go`

- [ ] **Step 1: Create error utility**

Create `pkg/errorutil/errorutil.go`:

```go
package errorutil

import (
	"errors"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
)

func CleanErr(err error) *connect.Error {
	if err == nil {
		return nil
	}

	var cerr *connect.Error
	if errors.As(err, &cerr) {
		return cerr
	}

	return data.ErrorConvertToAPI(err)
}
```

- [ ] **Step 2: Create config**

Create `apps/default/config/config.go`:

```go
package config

import (
	"github.com/pitabwire/frame/config"
)

type ManufacturingConfig struct {
	config.ConfigurationDefault
}
```

- [ ] **Step 3: Commit**

```bash
git add pkg/errorutil/errorutil.go apps/default/config/config.go
git commit -m "feat: add error utilities and config"
```

---

## Task 8: Business Constants and Facility Business

**Files:**
- Create: `apps/default/service/business/constants.go`
- Create: `apps/default/service/business/facilities.go`

- [ ] **Step 1: Create business constants**

Create `apps/default/service/business/constants.go`:

```go
package business

const (
	fieldName        = "name"
	fieldDescription = "description"
	fieldLocation    = "location"
	fieldStatus      = "status"
	fieldProperties  = "properties"
)
```

- [ ] **Step 2: Create facility business**

Create `apps/default/service/business/facilities.go`:

```go
package business

import (
	"context"
	"errors"
	"strings"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
)

type FacilityBusiness interface {
	CreateFacility(ctx context.Context, req *manufacturingv1.CreateFacilityRequest) (*manufacturingv1.Facility, error)
	GetFacility(ctx context.Context, id string) (*manufacturingv1.Facility, error)
	UpdateFacility(ctx context.Context, req *manufacturingv1.UpdateFacilityRequest) (*manufacturingv1.Facility, error)
	ListFacilities(ctx context.Context, req *manufacturingv1.ListFacilitiesRequest) ([]*manufacturingv1.Facility, error)
}

func NewFacilityBusiness(_ context.Context, facilityRepo repository.FacilityRepository) FacilityBusiness {
	return &facilityBusiness{facilityRepo: facilityRepo}
}

type facilityBusiness struct {
	facilityRepo repository.FacilityRepository
}

func (fb *facilityBusiness) CreateFacility(ctx context.Context, req *manufacturingv1.CreateFacilityRequest) (*manufacturingv1.Facility, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("facility name is required"))
	}

	facility := &models.Facility{
		Name:        name,
		Description: req.GetDescription(),
		Location:    req.GetLocation(),
		Status:      int32(manufacturingv1.FacilityStatus_FACILITY_STATUS_ACTIVE),
		Properties:  data.JSONMap{},
	}

	if err := fb.facilityRepo.Create(ctx, facility); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	return facility.ToAPI(), nil
}

func (fb *facilityBusiness) GetFacility(ctx context.Context, id string) (*manufacturingv1.Facility, error) {
	facility, err := fb.facilityRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return facility.ToAPI(), nil
}

func (fb *facilityBusiness) UpdateFacility(ctx context.Context, req *manufacturingv1.UpdateFacilityRequest) (*manufacturingv1.Facility, error) {
	facility, err := fb.facilityRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	fields := req.GetUpdateMask().GetPaths()
	if len(fields) == 0 {
		fields = []string{fieldName, fieldDescription, fieldLocation, fieldStatus, fieldProperties}
	}

	updateColumns := make([]string, 0, len(fields))
	for _, field := range fields {
		switch field {
		case fieldName:
			if req.GetName() != "" {
				facility.Name = req.GetName()
				updateColumns = append(updateColumns, fieldName)
			}
		case fieldDescription:
			facility.Description = req.GetDescription()
			updateColumns = append(updateColumns, fieldDescription)
		case fieldLocation:
			if req.GetLocation() != "" {
				facility.Location = req.GetLocation()
				updateColumns = append(updateColumns, fieldLocation)
			}
		case fieldStatus:
			if req.GetStatus() != manufacturingv1.FacilityStatus_FACILITY_STATUS_UNSPECIFIED {
				facility.Status = int32(req.GetStatus())
				updateColumns = append(updateColumns, fieldStatus)
			}
		case fieldProperties:
			if req.GetProperties() != nil {
				props := data.JSONMap{}
				facility.Properties = props.FromProtoStruct(req.GetProperties())
				updateColumns = append(updateColumns, fieldProperties)
			}
		}
	}

	if len(updateColumns) > 0 {
		if _, updateErr := fb.facilityRepo.Update(ctx, facility, updateColumns...); updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	return facility.ToAPI(), nil
}

func (fb *facilityBusiness) ListFacilities(ctx context.Context, req *manufacturingv1.ListFacilitiesRequest) ([]*manufacturingv1.Facility, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	facilities, err := fb.facilityRepo.List(ctx, limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*manufacturingv1.Facility, 0, len(facilities))
	for _, f := range facilities {
		result = append(result, f.ToAPI())
	}
	return result, nil
}
```

- [ ] **Step 3: Verify compilation**

```bash
go build ./apps/default/service/business/...
```

- [ ] **Step 4: Commit**

```bash
git add apps/default/service/business/
git commit -m "feat: add facility business layer"
```

---

## Task 9: Recipe Business — Core CRUD and Versioning

This is the most complex business layer. It handles recipe creation (with auto-draft version), draft editing (replace-all steps and materials), publishing (immutable snapshot + new draft), and template cloning.

**Files:**
- Create: `apps/default/service/business/recipes.go`

- [ ] **Step 1: Create recipe business**

Create `apps/default/service/business/recipes.go`:

```go
package business

import (
	"context"
	"errors"
	"strings"
	"time"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/security"

	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
)

type RecipeBusiness interface {
	CreateRecipe(ctx context.Context, req *manufacturingv1.CreateRecipeRequest) (*manufacturingv1.Recipe, *manufacturingv1.RecipeVersion, error)
	GetRecipe(ctx context.Context, id string) (*manufacturingv1.Recipe, error)
	ListRecipes(ctx context.Context, req *manufacturingv1.ListRecipesRequest) ([]*manufacturingv1.Recipe, error)
	UpdateRecipeDraft(ctx context.Context, req *manufacturingv1.UpdateRecipeDraftRequest) (*manufacturingv1.RecipeVersion, error)
	PublishRecipeVersion(ctx context.Context, req *manufacturingv1.PublishRecipeVersionRequest) (*manufacturingv1.RecipeVersion, *manufacturingv1.RecipeVersion, error)
	GetRecipeVersion(ctx context.Context, id string) (*manufacturingv1.RecipeVersion, error)
	ListRecipeVersions(ctx context.Context, recipeID string) ([]*manufacturingv1.RecipeVersion, error)
	ListRecipeTemplates(ctx context.Context, req *manufacturingv1.ListRecipeTemplatesRequest) ([]*manufacturingv1.RecipeTemplate, error)
	CloneRecipeTemplate(ctx context.Context, req *manufacturingv1.CloneRecipeTemplateRequest) (*manufacturingv1.Recipe, *manufacturingv1.RecipeVersion, error)
}

func NewRecipeBusiness(
	_ context.Context,
	recipeRepo repository.RecipeRepository,
	versionRepo repository.RecipeVersionRepository,
	stepRepo repository.RecipeStepRepository,
	materialRepo repository.RecipeMaterialRepository,
	templateRepo repository.RecipeTemplateRepository,
	facilityRepo repository.FacilityRepository,
) RecipeBusiness {
	return &recipeBusiness{
		recipeRepo:   recipeRepo,
		versionRepo:  versionRepo,
		stepRepo:     stepRepo,
		materialRepo: materialRepo,
		templateRepo: templateRepo,
		facilityRepo: facilityRepo,
	}
}

type recipeBusiness struct {
	recipeRepo   repository.RecipeRepository
	versionRepo  repository.RecipeVersionRepository
	stepRepo     repository.RecipeStepRepository
	materialRepo repository.RecipeMaterialRepository
	templateRepo repository.RecipeTemplateRepository
	facilityRepo repository.FacilityRepository
}

func (rb *recipeBusiness) CreateRecipe(
	ctx context.Context,
	req *manufacturingv1.CreateRecipeRequest,
) (*manufacturingv1.Recipe, *manufacturingv1.RecipeVersion, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, nil, connect.NewError(connect.CodeInvalidArgument, errors.New("recipe name is required"))
	}

	if _, err := rb.facilityRepo.GetByID(ctx, req.GetFacilityId()); err != nil {
		return nil, nil, connect.NewError(connect.CodeNotFound, errors.New("facility not found"))
	}

	recipe := &models.Recipe{
		FacilityID:     req.GetFacilityId(),
		Name:           name,
		Description:    req.GetDescription(),
		ProductItemID:  req.GetProductItemId(),
		OutputQuantity: req.GetOutputQuantity(),
		OutputUnit:     req.GetOutputUnit(),
		Status:         int32(manufacturingv1.RecipeStatus_RECIPE_STATUS_DRAFT),
	}

	if err := rb.recipeRepo.Create(ctx, recipe); err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}

	draft, err := rb.createDraftVersion(ctx, recipe.GetID(), 1)
	if err != nil {
		return nil, nil, err
	}

	recipe.ActiveVersionID = draft.GetID()
	if _, updateErr := rb.recipeRepo.Update(ctx, recipe, "active_version_id"); updateErr != nil {
		return nil, nil, data.ErrorConvertToAPI(updateErr)
	}

	return recipe.ToAPI(), draft.ToAPI(), nil
}

func (rb *recipeBusiness) GetRecipe(ctx context.Context, id string) (*manufacturingv1.Recipe, error) {
	recipe, err := rb.recipeRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return recipe.ToAPI(), nil
}

func (rb *recipeBusiness) ListRecipes(
	ctx context.Context,
	req *manufacturingv1.ListRecipesRequest,
) ([]*manufacturingv1.Recipe, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	recipes, err := rb.recipeRepo.ListByFacilityID(ctx, req.GetFacilityId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*manufacturingv1.Recipe, 0, len(recipes))
	for _, r := range recipes {
		result = append(result, r.ToAPI())
	}
	return result, nil
}

func (rb *recipeBusiness) UpdateRecipeDraft(
	ctx context.Context,
	req *manufacturingv1.UpdateRecipeDraftRequest,
) (*manufacturingv1.RecipeVersion, error) {
	recipe, err := rb.recipeRepo.GetByID(ctx, req.GetRecipeId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	draft, err := rb.versionRepo.GetDraftByRecipeID(ctx, recipe.GetID())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("no draft version found"))
	}

	// Update recipe-level fields if provided
	recipeUpdated := false
	if req.GetName() != "" {
		recipe.Name = req.GetName()
		recipeUpdated = true
	}
	if req.GetDescription() != "" {
		recipe.Description = req.GetDescription()
		recipeUpdated = true
	}
	if req.GetOutputQuantity() > 0 {
		recipe.OutputQuantity = req.GetOutputQuantity()
		recipeUpdated = true
	}
	if req.GetOutputUnit() != "" {
		recipe.OutputUnit = req.GetOutputUnit()
		recipeUpdated = true
	}
	if recipeUpdated {
		if _, updateErr := rb.recipeRepo.Update(ctx, recipe,
			fieldName, fieldDescription, "output_quantity", "output_unit"); updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	// Replace steps: delete existing, create new
	if len(req.GetSteps()) > 0 {
		if delErr := rb.stepRepo.DeleteByVersionID(ctx, draft.GetID()); delErr != nil {
			return nil, data.ErrorConvertToAPI(delErr)
		}
		for _, stepInput := range req.GetSteps() {
			step := &models.RecipeStep{
				RecipeVersionID:         draft.GetID(),
				Sequence:                stepInput.GetSequence(),
				Name:                    stepInput.GetName(),
				Description:             stepInput.GetDescription(),
				ExpectedDurationMinutes: stepInput.GetExpectedDurationMinutes(),
				MaxDurationMinutes:      stepInput.GetMaxDurationMinutes(),
				IsCheckpoint:            stepInput.GetIsCheckpoint(),
				RequiredReadings:        readingSpecsFromProto(stepInput.GetRequiredReadings()),
				AlarmRules:              alarmRulesFromProto(stepInput.GetAlarmRules()),
			}
			if createErr := rb.stepRepo.Create(ctx, step); createErr != nil {
				return nil, data.ErrorConvertToAPI(createErr)
			}
		}
	}

	// Replace materials: delete existing, create new
	if len(req.GetMaterials()) > 0 {
		if delErr := rb.materialRepo.DeleteByVersionID(ctx, draft.GetID()); delErr != nil {
			return nil, data.ErrorConvertToAPI(delErr)
		}
		for _, matInput := range req.GetMaterials() {
			material := &models.RecipeMaterial{
				RecipeVersionID:  draft.GetID(),
				InventoryItemID:  matInput.GetInventoryItemId(),
				Name:             matInput.GetName(),
				Quantity:         matInput.GetQuantity(),
				Unit:             matInput.GetUnit(),
				IsOptional:       matInput.GetIsOptional(),
				TolerancePercent: matInput.GetTolerancePercent(),
			}
			if createErr := rb.materialRepo.Create(ctx, material); createErr != nil {
				return nil, data.ErrorConvertToAPI(createErr)
			}
		}
	}

	// Reload draft with children
	updated, err := rb.versionRepo.GetWithChildren(ctx, draft.GetID())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return updated.ToAPI(), nil
}

func (rb *recipeBusiness) PublishRecipeVersion(
	ctx context.Context,
	req *manufacturingv1.PublishRecipeVersionRequest,
) (*manufacturingv1.RecipeVersion, *manufacturingv1.RecipeVersion, error) {
	recipe, err := rb.recipeRepo.GetByID(ctx, req.GetRecipeId())
	if err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}

	draft, err := rb.versionRepo.GetDraftByRecipeID(ctx, recipe.GetID())
	if err != nil {
		return nil, nil, connect.NewError(connect.CodeNotFound, errors.New("no draft version to publish"))
	}

	// Supersede any existing published version
	existingPublished, pubErr := rb.versionRepo.GetPublishedByRecipeID(ctx, recipe.GetID())
	if pubErr == nil && existingPublished != nil {
		existingPublished.Status = int32(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_SUPERSEDED)
		if _, updateErr := rb.versionRepo.Update(ctx, existingPublished, fieldStatus); updateErr != nil {
			return nil, nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	// Publish the draft
	now := time.Now()
	draft.Status = int32(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_PUBLISHED)
	draft.PublishedAt = &data.NullableTime{Time: now, Valid: true}
	draft.Notes = req.GetNotes()
	if _, updateErr := rb.versionRepo.Update(ctx, draft, fieldStatus, "published_at", "notes"); updateErr != nil {
		return nil, nil, data.ErrorConvertToAPI(updateErr)
	}

	// Update recipe to ACTIVE with new active_version_id
	recipe.Status = int32(manufacturingv1.RecipeStatus_RECIPE_STATUS_ACTIVE)
	recipe.ActiveVersionID = draft.GetID()
	if _, updateErr := rb.recipeRepo.Update(ctx, recipe, fieldStatus, "active_version_id"); updateErr != nil {
		return nil, nil, data.ErrorConvertToAPI(updateErr)
	}

	// Create new draft version (copy of published)
	newDraft, copyErr := rb.createDraftVersionFromPublished(ctx, recipe.GetID(), draft)
	if copyErr != nil {
		return nil, nil, copyErr
	}

	// Reload published with children
	published, reloadErr := rb.versionRepo.GetWithChildren(ctx, draft.GetID())
	if reloadErr != nil {
		return nil, nil, data.ErrorConvertToAPI(reloadErr)
	}

	return published.ToAPI(), newDraft.ToAPI(), nil
}

func (rb *recipeBusiness) GetRecipeVersion(ctx context.Context, id string) (*manufacturingv1.RecipeVersion, error) {
	version, err := rb.versionRepo.GetWithChildren(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return version.ToAPI(), nil
}

func (rb *recipeBusiness) ListRecipeVersions(ctx context.Context, recipeID string) ([]*manufacturingv1.RecipeVersion, error) {
	versions, err := rb.versionRepo.ListByRecipeID(ctx, recipeID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*manufacturingv1.RecipeVersion, 0, len(versions))
	for _, v := range versions {
		result = append(result, v.ToAPI())
	}
	return result, nil
}

func (rb *recipeBusiness) ListRecipeTemplates(
	ctx context.Context,
	req *manufacturingv1.ListRecipeTemplatesRequest,
) ([]*manufacturingv1.RecipeTemplate, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	var templates []*models.RecipeTemplate
	var err error
	if req.GetCategory() != "" {
		templates, err = rb.templateRepo.ListByCategory(ctx, req.GetCategory(), limit, offset)
	} else {
		templates, err = rb.templateRepo.List(ctx, limit, offset)
	}
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*manufacturingv1.RecipeTemplate, 0, len(templates))
	for _, t := range templates {
		result = append(result, t.ToAPI())
	}
	return result, nil
}

func (rb *recipeBusiness) CloneRecipeTemplate(
	ctx context.Context,
	req *manufacturingv1.CloneRecipeTemplateRequest,
) (*manufacturingv1.Recipe, *manufacturingv1.RecipeVersion, error) {
	if _, err := rb.facilityRepo.GetByID(ctx, req.GetFacilityId()); err != nil {
		return nil, nil, connect.NewError(connect.CodeNotFound, errors.New("facility not found"))
	}

	template, err := rb.templateRepo.GetByID(ctx, req.GetTemplateId())
	if err != nil {
		return nil, nil, connect.NewError(connect.CodeNotFound, errors.New("template not found"))
	}

	templateData := template.GetData()
	if templateData == nil {
		return nil, nil, connect.NewError(connect.CodeInternal, errors.New("template has no data"))
	}

	name := strings.TrimSpace(req.GetName())
	if name == "" {
		name = template.Name
	}

	recipe := &models.Recipe{
		FacilityID:       req.GetFacilityId(),
		Name:             name,
		Description:      template.Description,
		OutputQuantity:   templateData.OutputQuantity,
		OutputUnit:       templateData.OutputUnit,
		Status:           int32(manufacturingv1.RecipeStatus_RECIPE_STATUS_DRAFT),
		TemplateSourceID: template.GetID(),
	}

	if err := rb.recipeRepo.Create(ctx, recipe); err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}

	draft, err := rb.createDraftVersion(ctx, recipe.GetID(), 1)
	if err != nil {
		return nil, nil, err
	}

	// Populate steps from template
	for _, stepData := range templateData.Steps {
		step := &models.RecipeStep{
			RecipeVersionID:         draft.GetID(),
			Sequence:                int32(stepData.Sequence),
			Name:                    stepData.Name,
			Description:             stepData.Description,
			ExpectedDurationMinutes: int32(stepData.ExpectedDurationMinutes),
			MaxDurationMinutes:      int32(stepData.MaxDurationMinutes),
			IsCheckpoint:            stepData.IsCheckpoint,
			RequiredReadings:        models.JSONBSlice[models.ReadingSpecJSON](stepData.RequiredReadings),
			AlarmRules:              models.JSONBSlice[models.AlarmRuleJSON](stepData.AlarmRules),
		}
		if createErr := rb.stepRepo.Create(ctx, step); createErr != nil {
			return nil, nil, data.ErrorConvertToAPI(createErr)
		}
	}

	// Populate materials from template
	for _, matData := range templateData.Materials {
		material := &models.RecipeMaterial{
			RecipeVersionID:  draft.GetID(),
			Name:             matData.Name,
			Quantity:         matData.Quantity,
			Unit:             matData.Unit,
			IsOptional:       matData.IsOptional,
			TolerancePercent: matData.TolerancePercent,
		}
		if createErr := rb.materialRepo.Create(ctx, material); createErr != nil {
			return nil, nil, data.ErrorConvertToAPI(createErr)
		}
	}

	recipe.ActiveVersionID = draft.GetID()
	if _, updateErr := rb.recipeRepo.Update(ctx, recipe, "active_version_id"); updateErr != nil {
		return nil, nil, data.ErrorConvertToAPI(updateErr)
	}

	// Reload draft with children
	draftFull, err := rb.versionRepo.GetWithChildren(ctx, draft.GetID())
	if err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}

	return recipe.ToAPI(), draftFull.ToAPI(), nil
}

// ---- Internal helpers ----

func (rb *recipeBusiness) createDraftVersion(ctx context.Context, recipeID string, versionNumber int32) (*models.RecipeVersion, error) {
	createdBy := ""
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if sub, err := claims.GetSubject(); err == nil {
			createdBy = sub
		}
	}

	version := &models.RecipeVersion{
		RecipeID:      recipeID,
		VersionNumber: versionNumber,
		Status:        int32(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_DRAFT),
		CreatedBy:     createdBy,
	}

	if err := rb.versionRepo.Create(ctx, version); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return version, nil
}

func (rb *recipeBusiness) createDraftVersionFromPublished(ctx context.Context, recipeID string, published *models.RecipeVersion) (*models.RecipeVersion, error) {
	newDraft, err := rb.createDraftVersion(ctx, recipeID, published.VersionNumber+1)
	if err != nil {
		return nil, err
	}

	// Copy steps from published version
	steps, stepsErr := rb.stepRepo.ListByVersionID(ctx, published.GetID())
	if stepsErr != nil {
		return nil, data.ErrorConvertToAPI(stepsErr)
	}
	for _, s := range steps {
		copy := &models.RecipeStep{
			RecipeVersionID:         newDraft.GetID(),
			Sequence:                s.Sequence,
			Name:                    s.Name,
			Description:             s.Description,
			ExpectedDurationMinutes: s.ExpectedDurationMinutes,
			MaxDurationMinutes:      s.MaxDurationMinutes,
			IsCheckpoint:            s.IsCheckpoint,
			RequiredReadings:        s.RequiredReadings,
			AlarmRules:              s.AlarmRules,
		}
		if createErr := rb.stepRepo.Create(ctx, copy); createErr != nil {
			return nil, data.ErrorConvertToAPI(createErr)
		}
	}

	// Copy materials from published version
	materials, matsErr := rb.materialRepo.ListByVersionID(ctx, published.GetID())
	if matsErr != nil {
		return nil, data.ErrorConvertToAPI(matsErr)
	}
	for _, m := range materials {
		copy := &models.RecipeMaterial{
			RecipeVersionID:  newDraft.GetID(),
			InventoryItemID:  m.InventoryItemID,
			Name:             m.Name,
			Quantity:         m.Quantity,
			Unit:             m.Unit,
			IsOptional:       m.IsOptional,
			TolerancePercent: m.TolerancePercent,
		}
		if createErr := rb.materialRepo.Create(ctx, copy); createErr != nil {
			return nil, data.ErrorConvertToAPI(createErr)
		}
	}

	return newDraft, nil
}

func readingSpecsFromProto(specs []*manufacturingv1.ReadingSpec) models.JSONBSlice[models.ReadingSpecJSON] {
	if len(specs) == 0 {
		return nil
	}
	result := make(models.JSONBSlice[models.ReadingSpecJSON], len(specs))
	for i, s := range specs {
		result[i] = models.ReadingSpecJSON{
			ReadingType: s.GetReadingType(),
			Unit:        s.GetUnit(),
			MinValue:    s.GetMinValue(),
			MaxValue:    s.GetMaxValue(),
			IsRequired:  s.GetIsRequired(),
		}
	}
	return result
}

func alarmRulesFromProto(rules []*manufacturingv1.AlarmRule) models.JSONBSlice[models.AlarmRuleJSON] {
	if len(rules) == 0 {
		return nil
	}
	result := make(models.JSONBSlice[models.AlarmRuleJSON], len(rules))
	for i, r := range rules {
		result[i] = models.AlarmRuleJSON{
			Trigger:                 r.GetTrigger(),
			ReadingType:             r.GetReadingType(),
			Severity:                r.GetSeverity(),
			Message:                 r.GetMessage(),
			RequiresAcknowledgement: r.GetRequiresAcknowledgement(),
		}
	}
	return result
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/default/service/business/...
```

- [ ] **Step 3: Commit**

```bash
git add apps/default/service/business/recipes.go
git commit -m "feat: add recipe business layer with versioning and template cloning"
```

---

## Task 10: Authorization Layer

**Files:**
- Create: `apps/default/service/authz/constants.go`
- Create: `apps/default/service/authz/interfaces.go`
- Create: `apps/default/service/authz/role_mapping.go`
- Create: `apps/default/service/authz/middleware.go`

- [ ] **Step 1: Create authz constants**

Create `apps/default/service/authz/constants.go`:

```go
package authz

import "slices"

const (
	NamespaceManufacturing = "service_manufacturing"
	NamespaceTenancyAccess = "tenancy_access"
	NamespaceProfile       = "profile_user"
	NamespaceFacility      = "manufacturing_facility"
)

const (
	PermissionFacilityCreate = "facility_create"
)

const (
	PermissionFacilityView    = "facility_view"
	PermissionFacilityUpdate  = "facility_update"
	PermissionRecipeView      = "recipe_view"
	PermissionRecipeManage    = "recipe_manage"
	PermissionPlanView        = "plan_view"
	PermissionPlanManage      = "plan_manage"
	PermissionPlanValidate    = "plan_validate"
	PermissionBatchView       = "batch_view"
	PermissionBatchOperate    = "batch_operate"
	PermissionBatchComplete   = "batch_complete"
	PermissionBatchOverride   = "batch_override"
	PermissionInventoryView   = "inventory_view"
	PermissionInventoryManage = "inventory_manage"
	PermissionInventoryAdjust = "inventory_adjust"
)

const (
	RoleOwner    = "owner"
	RoleAdmin    = "admin"
	RoleOperator = "operator"
	RoleViewer   = "viewer"
	RoleMember   = "member"
	RoleService  = "service"
)

func RoleToRelation(role string) string {
	switch role {
	case RoleOwner:
		return RoleOwner
	case RoleAdmin:
		return RoleAdmin
	case RoleOperator:
		return RoleOperator
	case RoleViewer:
		return RoleViewer
	default:
		return RoleViewer
	}
}

func ValidRoles() []string {
	return []string{RoleOwner, RoleAdmin, RoleOperator, RoleViewer}
}

func IsValidRole(role string) bool {
	return slices.Contains(ValidRoles(), role)
}
```

- [ ] **Step 2: Create authz interfaces**

Create `apps/default/service/authz/interfaces.go`:

```go
package authz

import "context"

type Middleware interface {
	CanFacilityView(ctx context.Context, facilityID string) error
	CanFacilityUpdate(ctx context.Context, facilityID string) error
	CanRecipeView(ctx context.Context, facilityID string) error
	CanRecipeManage(ctx context.Context, facilityID string) error

	AddFacilityMember(ctx context.Context, facilityID string, profileID string, role string) error
	RemoveFacilityMember(ctx context.Context, facilityID string, profileID string) error
}
```

- [ ] **Step 3: Create role mapping**

Create `apps/default/service/authz/role_mapping.go`:

```go
package authz

import "github.com/pitabwire/frame/security"

func BuildAccessTuple(tenancyPath, profileID string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceTenancyAccess, ID: tenancyPath},
		Relation: RoleMember,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	}
}
```

- [ ] **Step 4: Create authz middleware**

Create `apps/default/service/authz/middleware.go`:

```go
package authz

import (
	"context"
	"fmt"

	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	"github.com/pitabwire/util"
)

type middleware struct {
	service security.Authorizer
}

func NewMiddleware(service security.Authorizer) Middleware {
	return &middleware{service: service}
}

func (m *middleware) CanFacilityView(ctx context.Context, facilityID string) error {
	return m.checkFacilityPermission(ctx, facilityID, PermissionFacilityView)
}

func (m *middleware) CanFacilityUpdate(ctx context.Context, facilityID string) error {
	return m.checkFacilityPermission(ctx, facilityID, PermissionFacilityUpdate)
}

func (m *middleware) CanRecipeView(ctx context.Context, facilityID string) error {
	return m.checkFacilityPermission(ctx, facilityID, PermissionRecipeView)
}

func (m *middleware) CanRecipeManage(ctx context.Context, facilityID string) error {
	return m.checkFacilityPermission(ctx, facilityID, PermissionRecipeManage)
}

func (m *middleware) AddFacilityMember(ctx context.Context, facilityID, profileID, role string) error {
	relation := RoleToRelation(role)
	util.Log(ctx).WithFields(map[string]any{
		"facility_id": facilityID,
		"profile_id":  profileID,
		"role":        role,
	}).Debug("AddFacilityMember writing tuple")
	return m.service.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceFacility, ID: facilityID},
		Relation: relation,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	})
}

func (m *middleware) RemoveFacilityMember(ctx context.Context, facilityID, profileID string) error {
	tuples := make([]security.RelationTuple, len(ValidRoles()))
	for i, role := range ValidRoles() {
		tuples[i] = security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceFacility, ID: facilityID},
			Relation: role,
			Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
		}
	}
	return m.service.DeleteTuples(ctx, tuples)
}

func (m *middleware) checkFacilityPermission(ctx context.Context, facilityID, permission string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return authorizer.ErrInvalidSubject
	}

	subjectID, err := claims.GetSubject()
	if err != nil || subjectID == "" {
		return authorizer.ErrInvalidSubject
	}

	req := security.CheckRequest{
		Object:     security.ObjectRef{Namespace: NamespaceFacility, ID: facilityID},
		Permission: permission,
		Subject:    security.SubjectRef{Namespace: NamespaceProfile, ID: subjectID},
	}

	result, checkErr := m.service.Check(ctx, req)
	if checkErr != nil {
		return fmt.Errorf("authorization check failed: %w", checkErr)
	}

	if !result.Allowed {
		return authorizer.NewPermissionDeniedError(req.Object, permission, req.Subject, result.Reason)
	}

	return nil
}
```

- [ ] **Step 5: Verify compilation**

```bash
go build ./apps/default/service/authz/...
```

- [ ] **Step 6: Commit**

```bash
git add apps/default/service/authz/
git commit -m "feat: add authorization layer for manufacturing service"
```

---

## Task 11: Handler and Main Bootstrap

**Files:**
- Create: `apps/default/service/handlers/manufacturing.go`
- Create: `apps/default/cmd/main.go`

- [ ] **Step 1: Create manufacturing handler**

Create `apps/default/service/handlers/manufacturing.go`:

```go
package handlers

import (
	"context"

	"buf.build/gen/go/antinvestor/manufacturing/connectrpc/go/v1/manufacturingv1connect"
	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"

	"github.com/antinvestor/service-manufacturing/apps/default/service/authz"
	"github.com/antinvestor/service-manufacturing/apps/default/service/business"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
	"github.com/antinvestor/service-manufacturing/pkg/errorutil"
)

type ManufacturingServer struct {
	authz            authz.Middleware
	facilityBusiness business.FacilityBusiness
	recipeBusiness   business.RecipeBusiness

	manufacturingv1connect.UnimplementedManufacturingServiceHandler
}

func NewManufacturingServer(ctx context.Context, svc *frame.Service, authzMiddleware authz.Middleware) *ManufacturingServer {
	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
	recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
	versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
	stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
	materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
	templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

	return &ManufacturingServer{
		authz:            authzMiddleware,
		facilityBusiness: business.NewFacilityBusiness(ctx, facilityRepo),
		recipeBusiness: business.NewRecipeBusiness(
			ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo,
		),
	}
}

// ---- Facility ----

func (ms *ManufacturingServer) CreateFacility(
	ctx context.Context,
	req *connect.Request[manufacturingv1.CreateFacilityRequest],
) (*connect.Response[manufacturingv1.CreateFacilityResponse], error) {
	facility, err := ms.facilityBusiness.CreateFacility(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}

	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if profileID, subErr := claims.GetSubject(); subErr == nil && profileID != "" {
			_ = ms.authz.AddFacilityMember(ctx, facility.GetId(), profileID, authz.RoleOwner)
		}
	}

	return connect.NewResponse(&manufacturingv1.CreateFacilityResponse{Facility: facility}), nil
}

func (ms *ManufacturingServer) GetFacility(
	ctx context.Context,
	req *connect.Request[manufacturingv1.GetFacilityRequest],
) (*connect.Response[manufacturingv1.GetFacilityResponse], error) {
	if err := ms.authz.CanFacilityView(ctx, req.Msg.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	facility, err := ms.facilityBusiness.GetFacility(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.GetFacilityResponse{Facility: facility}), nil
}

func (ms *ManufacturingServer) UpdateFacility(
	ctx context.Context,
	req *connect.Request[manufacturingv1.UpdateFacilityRequest],
) (*connect.Response[manufacturingv1.UpdateFacilityResponse], error) {
	if err := ms.authz.CanFacilityUpdate(ctx, req.Msg.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	facility, err := ms.facilityBusiness.UpdateFacility(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.UpdateFacilityResponse{Facility: facility}), nil
}

func (ms *ManufacturingServer) ListFacilities(
	ctx context.Context,
	req *connect.Request[manufacturingv1.ListFacilitiesRequest],
) (*connect.Response[manufacturingv1.ListFacilitiesResponse], error) {
	facilities, err := ms.facilityBusiness.ListFacilities(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.ListFacilitiesResponse{Facilities: facilities}), nil
}

// ---- Recipe ----

func (ms *ManufacturingServer) CreateRecipe(
	ctx context.Context,
	req *connect.Request[manufacturingv1.CreateRecipeRequest],
) (*connect.Response[manufacturingv1.CreateRecipeResponse], error) {
	if err := ms.authz.CanRecipeManage(ctx, req.Msg.GetFacilityId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	recipe, draft, err := ms.recipeBusiness.CreateRecipe(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.CreateRecipeResponse{Recipe: recipe, DraftVersion: draft}), nil
}

func (ms *ManufacturingServer) GetRecipe(
	ctx context.Context,
	req *connect.Request[manufacturingv1.GetRecipeRequest],
) (*connect.Response[manufacturingv1.GetRecipeResponse], error) {
	recipe, err := ms.recipeBusiness.GetRecipe(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.GetRecipeResponse{Recipe: recipe}), nil
}

func (ms *ManufacturingServer) ListRecipes(
	ctx context.Context,
	req *connect.Request[manufacturingv1.ListRecipesRequest],
) (*connect.Response[manufacturingv1.ListRecipesResponse], error) {
	if err := ms.authz.CanRecipeView(ctx, req.Msg.GetFacilityId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	recipes, err := ms.recipeBusiness.ListRecipes(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.ListRecipesResponse{Recipes: recipes}), nil
}

func (ms *ManufacturingServer) UpdateRecipeDraft(
	ctx context.Context,
	req *connect.Request[manufacturingv1.UpdateRecipeDraftRequest],
) (*connect.Response[manufacturingv1.UpdateRecipeDraftResponse], error) {
	draft, err := ms.recipeBusiness.UpdateRecipeDraft(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.UpdateRecipeDraftResponse{DraftVersion: draft}), nil
}

func (ms *ManufacturingServer) PublishRecipeVersion(
	ctx context.Context,
	req *connect.Request[manufacturingv1.PublishRecipeVersionRequest],
) (*connect.Response[manufacturingv1.PublishRecipeVersionResponse], error) {
	published, newDraft, err := ms.recipeBusiness.PublishRecipeVersion(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.PublishRecipeVersionResponse{
		PublishedVersion: published,
		NewDraftVersion:  newDraft,
	}), nil
}

func (ms *ManufacturingServer) GetRecipeVersion(
	ctx context.Context,
	req *connect.Request[manufacturingv1.GetRecipeVersionRequest],
) (*connect.Response[manufacturingv1.GetRecipeVersionResponse], error) {
	version, err := ms.recipeBusiness.GetRecipeVersion(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.GetRecipeVersionResponse{Version: version}), nil
}

func (ms *ManufacturingServer) ListRecipeVersions(
	ctx context.Context,
	req *connect.Request[manufacturingv1.ListRecipeVersionsRequest],
) (*connect.Response[manufacturingv1.ListRecipeVersionsResponse], error) {
	versions, err := ms.recipeBusiness.ListRecipeVersions(ctx, req.Msg.GetRecipeId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.ListRecipeVersionsResponse{Versions: versions}), nil
}

func (ms *ManufacturingServer) ListRecipeTemplates(
	ctx context.Context,
	req *connect.Request[manufacturingv1.ListRecipeTemplatesRequest],
) (*connect.Response[manufacturingv1.ListRecipeTemplatesResponse], error) {
	templates, err := ms.recipeBusiness.ListRecipeTemplates(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.ListRecipeTemplatesResponse{Templates: templates}), nil
}

func (ms *ManufacturingServer) CloneRecipeTemplate(
	ctx context.Context,
	req *connect.Request[manufacturingv1.CloneRecipeTemplateRequest],
) (*connect.Response[manufacturingv1.CloneRecipeTemplateResponse], error) {
	if err := ms.authz.CanRecipeManage(ctx, req.Msg.GetFacilityId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	recipe, draft, err := ms.recipeBusiness.CloneRecipeTemplate(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&manufacturingv1.CloneRecipeTemplateResponse{Recipe: recipe, DraftVersion: draft}), nil
}
```

- [ ] **Step 2: Create main.go**

Create `apps/default/cmd/main.go`:

```go
package main

import (
	"context"
	"net/http"

	"buf.build/gen/go/antinvestor/manufacturing/connectrpc/go/v1/manufacturingv1connect"
	manufacturingpb "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/permissions"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/security/interceptors/connect"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-manufacturing/apps/default/config"
	"github.com/antinvestor/service-manufacturing/apps/default/service/authz"
	"github.com/antinvestor/service-manufacturing/apps/default/service/handlers"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
)

func main() {
	ctx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.ManufacturingConfig](ctx)
	if err != nil {
		util.Log(ctx).WithError(err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_manufacturing"
	}

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)
	defer svc.Stop(ctx)
	log := svc.Log(ctx)

	dbManager := svc.DatastoreManager()

	if handleDatabaseMigration(ctx, dbManager, cfg) {
		return
	}

	connectHandler := setupConnectServer(ctx, svc)

	sd := manufacturingpb.File_v1_manufacturing_proto.Services().ByName("ManufacturingService")
	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
	}

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.ManufacturingConfig,
) bool {
	if cfg.DoDatabaseMigrate() {
		err := repository.Migrate(ctx, dbManager, cfg.GetDatabaseMigrationPath())
		if err != nil {
			util.Log(ctx).WithError(err).Fatal("main -- Could not migrate successfully")
		}
		return true
	}
	return false
}

func setupConnectServer(ctx context.Context, svc *frame.Service) http.Handler {
	securityMan := svc.SecurityManager()
	auth := securityMan.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := manufacturingpb.File_v1_manufacturing_proto.Services().ByName("ManufacturingService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, securityMan.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	authzMiddleware := authz.NewMiddleware(securityMan.GetAuthorizer(ctx))
	implementation := handlers.NewManufacturingServer(ctx, svc, authzMiddleware)

	_, serverHandler := manufacturingv1connect.NewManufacturingServiceHandler(
		implementation, connect.WithInterceptors(defaultInterceptorList...))

	mux := http.NewServeMux()
	mux.Handle("/", serverHandler)

	return mux
}
```

- [ ] **Step 3: Verify compilation**

```bash
go build ./apps/default/...
```

- [ ] **Step 4: Commit**

```bash
git add apps/default/service/handlers/manufacturing.go apps/default/cmd/main.go
git commit -m "feat: add manufacturing handler and main bootstrap"
```

---

## Task 12: Test Suite Setup

**Files:**
- Create: `apps/default/tests/base_testsuite.go`
- Create: `apps/default/tests/testketo/keto.go`

- [ ] **Step 1: Create test keto setup**

Create `apps/default/tests/testketo/keto.go` following the pattern from service-commerce. The OPL namespaces should define `service_manufacturing` (tenant-level) and `manufacturing_facility` (resource-level) with the same role hierarchy pattern:

- `service_manufacturing`: relations `owner`, `admin`, `member`, `service`, grants for `facility_create`
- `manufacturing_facility`: relations `owner`, `admin`, `operator`, `viewer`, permits for `facility_view`, `facility_update`, `recipe_view`, `recipe_manage`, `plan_view`, `plan_manage`, `plan_validate`, `batch_view`, `batch_operate`, `batch_complete`, `batch_override`, `inventory_view`, `inventory_manage`, `inventory_adjust`

Follow the exact same container setup pattern as service-commerce's `testketo/keto.go` — a migration container that loads the OPL, then a serve container.

- [ ] **Step 2: Create base test suite**

Create `apps/default/tests/base_testsuite.go`:

```go
package tests

import (
	"context"
	"fmt"
	"net/url"
	"testing"

	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	aconfig "github.com/antinvestor/service-manufacturing/apps/default/config"
	"github.com/antinvestor/service-manufacturing/apps/default/service/authz"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
	"github.com/antinvestor/service-manufacturing/apps/default/tests/testketo"
)

const (
	PostgresqlDBImage         = "postgres:latest"
	DefaultRandomStringLength = 8
)

type ManufacturingBaseTestSuite struct {
	frametests.FrameBaseTestSuite
	AuthzMiddleware authz.Middleware
	ketoReadURI     string
	ketoWriteURI    string
}

func initResources(_ context.Context) []definition.TestResource {
	pg := testpostgres.NewWithOpts("service_manufacturing", definition.WithUserName("ant"))
	keto := testketo.NewWithOpts(
		definition.WithDependancies(pg),
		definition.WithEnableLogging(true),
	)
	return []definition.TestResource{pg, keto}
}

func (bs *ManufacturingBaseTestSuite) SetupSuite() {
	bs.InitResourceFunc = initResources
	bs.FrameBaseTestSuite.SetupSuite()

	ctx := bs.T().Context()

	var ketoDep definition.DependancyConn
	for _, res := range bs.Resources() {
		if res.Name() == testketo.ImageName {
			ketoDep = res
			break
		}
	}
	bs.Require().NotNil(ketoDep, "keto dependency should be available")

	writeURL, err := url.Parse(string(ketoDep.GetDS(ctx)))
	bs.Require().NoError(err)
	bs.ketoWriteURI = writeURL.Host

	readPort, err := ketoDep.PortMapping(ctx, "4466/tcp")
	bs.Require().NoError(err)
	bs.ketoReadURI = fmt.Sprintf("%s:%s", writeURL.Hostname(), readPort)
}

func (bs *ManufacturingBaseTestSuite) CreateService(
	t *testing.T,
	depOpts *definition.DependencyOption,
) (context.Context, *frame.Service) {
	t.Setenv("OTEL_TRACES_EXPORTER", "none")

	cfg, err := config.FromEnv[aconfig.ManufacturingConfig]()
	require.NoError(t, err)

	cfg.LogLevel = "debug"
	cfg.RunServiceSecurely = false
	cfg.ServerPort = ""
	cfg.DatabaseMigrate = true
	cfg.DatabaseTraceQueries = true
	cfg.DatabaseMaxOpenConnections = 1
	cfg.DatabaseMaxIdleConnections = 0

	res := depOpts.ByIsDatabase(t.Context())
	testDS, cleanup, err0 := res.GetRandomisedDS(t.Context(), depOpts.Prefix())
	require.NoError(t, err0)

	t.Cleanup(func() {
		cleanup(t.Context())
	})

	cfg.DatabasePrimaryURL = []string{testDS.String()}
	cfg.DatabaseReplicaURL = []string{}
	cfg.AuthorizationServiceReadURI = bs.ketoReadURI
	cfg.AuthorizationServiceWriteURI = bs.ketoWriteURI

	ctx, svc := frame.NewServiceWithContext(t.Context(), frame.WithName("manufacturing tests"),
		frame.WithConfig(&cfg),
		frame.WithDatastore(pool.WithTraceConfig(&cfg)),
		frametests.WithNoopDriver())

	sm := svc.SecurityManager()
	bs.AuthzMiddleware = authz.NewMiddleware(sm.GetAuthorizer(ctx))

	svc.Init(ctx)

	err = repository.Migrate(ctx, svc.DatastoreManager(), "../../migrations/0001")
	require.NoError(t, err)
	svc.DatastoreManager().RemovePool(ctx, datastore.DefaultMigrationPoolName)

	err = svc.Run(ctx, "")
	require.NoError(t, err)

	t.Cleanup(func() {
		bgCtx := context.Background()
		svc.Stop(bgCtx)
		svc.DatastoreManager().Close(bgCtx)
	})

	return ctx, svc
}

func (bs *ManufacturingBaseTestSuite) TearDownSuite() {
	bs.FrameBaseTestSuite.TearDownSuite()
}

func (bs *ManufacturingBaseTestSuite) WithTestDependancies(
	t *testing.T,
	testFn func(t *testing.T, dep *definition.DependencyOption),
) {
	options := []*definition.DependencyOption{
		definition.NewDependancyOption(
			"default",
			util.RandomAlphaNumericString(DefaultRandomStringLength),
			bs.Resources(),
		),
	}
	frametests.WithTestDependencies(t, options, testFn)
}

func (bs *ManufacturingBaseTestSuite) WithAuthClaims(
	ctx context.Context,
	tenantID, partitionID, profileID string,
) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    tenantID,
		PartitionID: partitionID,
		AccessID:    util.IDString(),
		ContactID:   profileID,
		SessionID:   util.IDString(),
		DeviceID:    "test-device",
	}
	claims.Subject = profileID
	return claims.ClaimsToContext(ctx)
}

func (bs *ManufacturingBaseTestSuite) SeedTenantAccess(
	ctx context.Context,
	svc *frame.Service,
	tenantID, partitionID, profileID string,
) {
	auth := svc.SecurityManager().GetAuthorizer(ctx)
	tenancyPath := fmt.Sprintf("%s/%s", tenantID, partitionID)
	err := auth.WriteTuple(ctx, authz.BuildAccessTuple(tenancyPath, profileID))
	bs.Require().NoError(err, "failed to seed tenant access")
}

func (bs *ManufacturingBaseTestSuite) SeedFacilityRole(
	ctx context.Context,
	svc *frame.Service,
	facilityID, profileID, role string,
) {
	auth := svc.SecurityManager().GetAuthorizer(ctx)
	err := auth.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: authz.NamespaceFacility, ID: facilityID},
		Relation: role,
		Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: profileID},
	})
	bs.Require().NoError(err, "failed to seed facility role")
}
```

- [ ] **Step 3: Verify compilation**

```bash
go build ./apps/default/tests/...
```

- [ ] **Step 4: Commit**

```bash
git add apps/default/tests/
git commit -m "feat: add test suite base and keto setup"
```

---

## Task 13: Facility Integration Tests

**Files:**
- Create: `apps/default/tests/facility_test.go`

- [ ] **Step 1: Write facility integration tests**

Create `apps/default/tests/facility_test.go`:

```go
package tests

import (
	"testing"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-manufacturing/apps/default/service/authz"
	"github.com/antinvestor/service-manufacturing/apps/default/service/business"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
)

type FacilityTestSuite struct {
	ManufacturingBaseTestSuite
}

func TestFacilitySuite(t *testing.T) {
	suite.Run(t, new(FacilityTestSuite))
}

func (s *FacilityTestSuite) TestCreateFacility() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		req := &manufacturingv1.CreateFacilityRequest{
			Name:        "Test Dairy Plant",
			Description: "A test facility",
			Location:    "Nairobi",
		}

		facility, err := fb.CreateFacility(ctx, req)
		s.Require().NoError(err)
		s.Require().NotEmpty(facility.GetId())
		s.Equal("Test Dairy Plant", facility.GetName())
		s.Equal("A test facility", facility.GetDescription())
		s.Equal("Nairobi", facility.GetLocation())
		s.Equal(manufacturingv1.FacilityStatus_FACILITY_STATUS_ACTIVE, facility.GetStatus())
	})
}

func (s *FacilityTestSuite) TestCreateFacility_EmptyName() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		req := &manufacturingv1.CreateFacilityRequest{Name: ""}
		_, err := fb.CreateFacility(ctx, req)
		s.Require().Error(err)
	})
}

func (s *FacilityTestSuite) TestGetFacility() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		created, err := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{
			Name: "Lookup Test", Location: "Mombasa",
		})
		s.Require().NoError(err)

		fetched, err := fb.GetFacility(ctx, created.GetId())
		s.Require().NoError(err)
		s.Equal(created.GetId(), fetched.GetId())
		s.Equal("Lookup Test", fetched.GetName())
	})
}

func (s *FacilityTestSuite) TestUpdateFacility() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		created, err := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{
			Name: "Original Name",
		})
		s.Require().NoError(err)

		updated, err := fb.UpdateFacility(ctx, &manufacturingv1.UpdateFacilityRequest{
			Id:   created.GetId(),
			Name: "Updated Name",
		})
		s.Require().NoError(err)
		s.Equal("Updated Name", updated.GetName())
	})
}

func (s *FacilityTestSuite) TestListFacilities() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		_, _ = fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Facility A"})
		_, _ = fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Facility B"})

		facilities, err := fb.ListFacilities(ctx, &manufacturingv1.ListFacilitiesRequest{})
		s.Require().NoError(err)
		s.GreaterOrEqual(len(facilities), 2)
	})
}

func (s *FacilityTestSuite) TestFacilityAuthz_OwnerCanView() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		tenantID := util.IDString()
		partitionID := util.IDString()
		profileID := util.IDString()

		s.SeedTenantAccess(ctx, svc, tenantID, partitionID, profileID)
		ctx = s.WithAuthClaims(ctx, tenantID, partitionID, profileID)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		fb := business.NewFacilityBusiness(ctx, facilityRepo)

		created, err := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{
			Name: "Auth Test Facility",
		})
		s.Require().NoError(err)

		s.SeedFacilityRole(ctx, svc, created.GetId(), profileID, authz.RoleOwner)

		err = s.AuthzMiddleware.CanFacilityView(ctx, created.GetId())
		s.Require().NoError(err)
	})
}
```

- [ ] **Step 2: Run facility tests**

```bash
go test -v -race -count=1 ./apps/default/tests/ -run TestFacilitySuite -timeout 120s
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add apps/default/tests/facility_test.go
git commit -m "test: add facility integration tests"
```

---

## Task 14: Recipe Integration Tests

**Files:**
- Create: `apps/default/tests/recipe_test.go`

- [ ] **Step 1: Write recipe integration tests**

Create `apps/default/tests/recipe_test.go`:

```go
package tests

import (
	"testing"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-manufacturing/apps/default/service/business"
	"github.com/antinvestor/service-manufacturing/apps/default/service/models"
	"github.com/antinvestor/service-manufacturing/apps/default/service/repository"
)

type RecipeTestSuite struct {
	ManufacturingBaseTestSuite
}

func TestRecipeSuite(t *testing.T) {
	suite.Run(t, new(RecipeTestSuite))
}

func (s *RecipeTestSuite) createTestFacility(
	fb business.FacilityBusiness,
	ctx interface{ Value(any) any },
) *manufacturingv1.Facility {
	f, err := fb.CreateFacility(ctx.(interface {
		Value(any) any
		Deadline() (interface{}, bool)
		Done() <-chan struct{}
		Err() error
	}).(interface {
		Value(any) any
		Deadline() (interface{}, bool)
		Done() <-chan struct{}
		Err() error
	}), &manufacturingv1.CreateFacilityRequest{Name: "Test Facility"})
	s.Require().NoError(err)
	return f
}

func (s *RecipeTestSuite) setupBusiness(t *testing.T, dep *definition.DependencyOption) (
	interface {
		Value(any) any
		Deadline() (interface{}, bool)
		Done() <-chan struct{}
		Err() error
	},
	business.FacilityBusiness,
	business.RecipeBusiness,
) {
	ctx, svc := s.CreateService(t, dep)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
	recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
	versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
	stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
	materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
	templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

	fb := business.NewFacilityBusiness(ctx, facilityRepo)
	rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

	return ctx, fb, rb
}

func (s *RecipeTestSuite) TestCreateRecipe_CreatesWithDraftVersion() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
		versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
		stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
		materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
		templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

		fb := business.NewFacilityBusiness(ctx, facilityRepo)
		rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

		facility, _ := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Plant"})

		recipe, draft, err := rb.CreateRecipe(ctx, &manufacturingv1.CreateRecipeRequest{
			FacilityId:     facility.GetId(),
			Name:           "Vanilla Yoghurt",
			Description:    "Standard vanilla yoghurt recipe",
			OutputQuantity: 100,
			OutputUnit:     "liters",
		})

		s.Require().NoError(err)
		s.NotEmpty(recipe.GetId())
		s.Equal("Vanilla Yoghurt", recipe.GetName())
		s.Equal(manufacturingv1.RecipeStatus_RECIPE_STATUS_DRAFT, recipe.GetStatus())
		s.NotEmpty(draft.GetId())
		s.Equal(int32(1), draft.GetVersionNumber())
		s.Equal(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_DRAFT, draft.GetStatus())
		s.Equal(draft.GetId(), recipe.GetActiveVersionId())
	})
}

func (s *RecipeTestSuite) TestUpdateRecipeDraft_ReplacesStepsAndMaterials() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
		versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
		stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
		materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
		templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

		fb := business.NewFacilityBusiness(ctx, facilityRepo)
		rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

		facility, _ := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Plant"})
		recipe, _, _ := rb.CreateRecipe(ctx, &manufacturingv1.CreateRecipeRequest{
			FacilityId:     facility.GetId(),
			Name:           "Yoghurt",
			OutputQuantity: 100,
			OutputUnit:     "liters",
		})

		updatedDraft, err := rb.UpdateRecipeDraft(ctx, &manufacturingv1.UpdateRecipeDraftRequest{
			RecipeId: recipe.GetId(),
			Steps: []*manufacturingv1.RecipeStepInput{
				{
					Sequence:                1,
					Name:                    "Milk Receiving",
					Description:             "Check milk temperature on arrival",
					ExpectedDurationMinutes: 10,
					IsCheckpoint:            true,
					RequiredReadings: []*manufacturingv1.ReadingSpec{
						{ReadingType: "temperature", Unit: "celsius", MinValue: 2, MaxValue: 6, IsRequired: true},
					},
				},
				{
					Sequence:                2,
					Name:                    "Heating",
					Description:             "Heat milk to 85C",
					ExpectedDurationMinutes: 15,
					MaxDurationMinutes:      20,
					IsCheckpoint:            true,
					RequiredReadings: []*manufacturingv1.ReadingSpec{
						{ReadingType: "temperature", Unit: "celsius", MinValue: 83, MaxValue: 87, IsRequired: true},
					},
					AlarmRules: []*manufacturingv1.AlarmRule{
						{Trigger: "reading_out_of_range", ReadingType: "temperature", Severity: "warning", Message: "Temp outside range"},
					},
				},
			},
			Materials: []*manufacturingv1.RecipeMaterialInput{
				{Name: "Whole Milk", Quantity: 80, Unit: "liters", IsOptional: false, TolerancePercent: 5},
				{Name: "Sugar", Quantity: 5, Unit: "kg", IsOptional: false, TolerancePercent: 10},
			},
		})

		s.Require().NoError(err)
		s.Len(updatedDraft.GetSteps(), 2)
		s.Equal("Milk Receiving", updatedDraft.GetSteps()[0].GetName())
		s.Equal("Heating", updatedDraft.GetSteps()[1].GetName())
		s.True(updatedDraft.GetSteps()[0].GetIsCheckpoint())
		s.Len(updatedDraft.GetSteps()[0].GetRequiredReadings(), 1)
		s.Len(updatedDraft.GetSteps()[1].GetAlarmRules(), 1)
		s.Len(updatedDraft.GetMaterials(), 2)
		s.Equal("Whole Milk", updatedDraft.GetMaterials()[0].GetName())
	})
}

func (s *RecipeTestSuite) TestPublishRecipeVersion_CreatesImmutableSnapshotAndNewDraft() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
		versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
		stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
		materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
		templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

		fb := business.NewFacilityBusiness(ctx, facilityRepo)
		rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

		facility, _ := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Plant"})
		recipe, _, _ := rb.CreateRecipe(ctx, &manufacturingv1.CreateRecipeRequest{
			FacilityId: facility.GetId(), Name: "Yoghurt", OutputQuantity: 100, OutputUnit: "liters",
		})

		// Add steps to draft
		_, _ = rb.UpdateRecipeDraft(ctx, &manufacturingv1.UpdateRecipeDraftRequest{
			RecipeId: recipe.GetId(),
			Steps: []*manufacturingv1.RecipeStepInput{
				{Sequence: 1, Name: "Step 1", IsCheckpoint: true},
			},
			Materials: []*manufacturingv1.RecipeMaterialInput{
				{Name: "Milk", Quantity: 80, Unit: "liters"},
			},
		})

		// Publish
		published, newDraft, err := rb.PublishRecipeVersion(ctx, &manufacturingv1.PublishRecipeVersionRequest{
			RecipeId: recipe.GetId(),
			Notes:    "First release",
		})

		s.Require().NoError(err)

		// Published version
		s.Equal(int32(1), published.GetVersionNumber())
		s.Equal(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_PUBLISHED, published.GetStatus())
		s.NotNil(published.GetPublishedAt())
		s.Equal("First release", published.GetNotes())
		s.Len(published.GetSteps(), 1)
		s.Len(published.GetMaterials(), 1)

		// New draft
		s.Equal(int32(2), newDraft.GetVersionNumber())
		s.Equal(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_DRAFT, newDraft.GetStatus())

		// Recipe status should now be ACTIVE
		updatedRecipe, _ := rb.GetRecipe(ctx, recipe.GetId())
		s.Equal(manufacturingv1.RecipeStatus_RECIPE_STATUS_ACTIVE, updatedRecipe.GetStatus())
		s.Equal(published.GetId(), updatedRecipe.GetActiveVersionId())
	})
}

func (s *RecipeTestSuite) TestPublishTwice_SupersedesPreviousVersion() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
		versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
		stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
		materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
		templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

		fb := business.NewFacilityBusiness(ctx, facilityRepo)
		rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

		facility, _ := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Plant"})
		recipe, _, _ := rb.CreateRecipe(ctx, &manufacturingv1.CreateRecipeRequest{
			FacilityId: facility.GetId(), Name: "Yoghurt", OutputQuantity: 100, OutputUnit: "liters",
		})

		// Add steps and publish v1
		_, _ = rb.UpdateRecipeDraft(ctx, &manufacturingv1.UpdateRecipeDraftRequest{
			RecipeId: recipe.GetId(),
			Steps:    []*manufacturingv1.RecipeStepInput{{Sequence: 1, Name: "Step A"}},
		})
		v1, _, _ := rb.PublishRecipeVersion(ctx, &manufacturingv1.PublishRecipeVersionRequest{
			RecipeId: recipe.GetId(), Notes: "v1",
		})

		// Modify draft and publish v2
		_, _ = rb.UpdateRecipeDraft(ctx, &manufacturingv1.UpdateRecipeDraftRequest{
			RecipeId: recipe.GetId(),
			Steps:    []*manufacturingv1.RecipeStepInput{{Sequence: 1, Name: "Step B"}},
		})
		v2, _, _ := rb.PublishRecipeVersion(ctx, &manufacturingv1.PublishRecipeVersionRequest{
			RecipeId: recipe.GetId(), Notes: "v2",
		})

		// Verify v1 is now superseded
		v1Reloaded, err := rb.GetRecipeVersion(ctx, v1.GetId())
		s.Require().NoError(err)
		s.Equal(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_SUPERSEDED, v1Reloaded.GetStatus())

		// Verify v2 is published
		s.Equal(manufacturingv1.RecipeVersionStatus_RECIPE_VERSION_STATUS_PUBLISHED, v2.GetStatus())

		// Verify recipe points to v2
		updatedRecipe, _ := rb.GetRecipe(ctx, recipe.GetId())
		s.Equal(v2.GetId(), updatedRecipe.GetActiveVersionId())

		// List versions — should have 3: v1 superseded, v2 published, v3 draft
		versions, err := rb.ListRecipeVersions(ctx, recipe.GetId())
		s.Require().NoError(err)
		s.Len(versions, 3)
	})
}

func (s *RecipeTestSuite) TestCloneRecipeTemplate() {
	s.WithTestDependancies(s.T(), func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)

		workMan := svc.WorkManager()
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

		facilityRepo := repository.NewFacilityRepository(ctx, dbPool, workMan)
		recipeRepo := repository.NewRecipeRepository(ctx, dbPool, workMan)
		versionRepo := repository.NewRecipeVersionRepository(ctx, dbPool, workMan)
		stepRepo := repository.NewRecipeStepRepository(ctx, dbPool, workMan)
		materialRepo := repository.NewRecipeMaterialRepository(ctx, dbPool, workMan)
		templateRepo := repository.NewRecipeTemplateRepository(ctx, dbPool, workMan)

		fb := business.NewFacilityBusiness(ctx, facilityRepo)
		rb := business.NewRecipeBusiness(ctx, recipeRepo, versionRepo, stepRepo, materialRepo, templateRepo, facilityRepo)

		facility, _ := fb.CreateFacility(ctx, &manufacturingv1.CreateFacilityRequest{Name: "Plant"})

		// Seed a template directly in the DB
		template := &models.RecipeTemplate{
			Name:        "Plain Yoghurt Template",
			Description: "Standard plain yoghurt process",
			Category:    "dairy",
			Status:      int32(manufacturingv1.RecipeTemplateStatus_RECIPE_TEMPLATE_STATUS_ACTIVE),
			TemplateData: models.JSONBSlice[models.TemplateDataJSON]{
				{
					OutputQuantity: 100,
					OutputUnit:     "liters",
					Steps: []models.TemplateStepJSON{
						{Sequence: 1, Name: "Milk Check", IsCheckpoint: true, ExpectedDurationMinutes: 5},
						{Sequence: 2, Name: "Heating", IsCheckpoint: true, ExpectedDurationMinutes: 15},
					},
					Materials: []models.TemplateMaterialJSON{
						{Name: "Whole Milk", Quantity: 80, Unit: "liters", TolerancePercent: 5},
						{Name: "Starter Culture", Quantity: 2, Unit: "liters", IsOptional: false},
					},
				},
			},
		}
		err := templateRepo.Create(ctx, template)
		s.Require().NoError(err)

		// Clone it
		recipe, draft, err := rb.CloneRecipeTemplate(ctx, &manufacturingv1.CloneRecipeTemplateRequest{
			TemplateId: template.GetID(),
			FacilityId: facility.GetId(),
			Name:       "My Custom Yoghurt",
		})

		s.Require().NoError(err)
		s.Equal("My Custom Yoghurt", recipe.GetName())
		s.Equal(template.GetID(), recipe.GetTemplateSourceId())
		s.Equal(manufacturingv1.RecipeStatus_RECIPE_STATUS_DRAFT, recipe.GetStatus())
		s.Len(draft.GetSteps(), 2)
		s.Equal("Milk Check", draft.GetSteps()[0].GetName())
		s.Len(draft.GetMaterials(), 2)
		s.Equal("Whole Milk", draft.GetMaterials()[0].GetName())
	})
}
```

- [ ] **Step 2: Run recipe tests**

```bash
go test -v -race -count=1 ./apps/default/tests/ -run TestRecipeSuite -timeout 120s
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add apps/default/tests/recipe_test.go
git commit -m "test: add recipe integration tests covering CRUD, versioning, and template cloning"
```

---

## Task 15: Run Full Test Suite and Final Verification

- [ ] **Step 1: Run all tests**

```bash
go test -v -race -count=1 ./... -timeout 180s
```

Expected: all tests PASS.

- [ ] **Step 2: Run linter**

```bash
make lint
```

Expected: no errors.

- [ ] **Step 3: Run build**

```bash
go build ./...
```

Expected: success.

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: verify all tests pass and lint clean"
```

---

## Follow-Up Plans

**Plan 2: Inventory + Production Planning + Material Requirements** will add:
- Inventory items, stock locations, stock lots, stock movements, stock balances
- Production plans, plan lines, packing specs
- Material requirements computation (the three-layer cascade)
- Plan validation flow

**Plan 3: Batch Execution + Packing + Integration** will add:
- Batch lifecycle (create, start, pause, resume, complete, abort)
- Step execution tracking
- Reading capture and alarm triggering
- Material confirmation and packing execution
- Stock movement creation on batch completion
- Commerce ↔ Manufacturing integration events
