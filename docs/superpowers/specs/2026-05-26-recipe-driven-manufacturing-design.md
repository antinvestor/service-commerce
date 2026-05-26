# Recipe-Driven Manufacturing Backend Design

## 1. Overview

This spec defines the recipe management, production planning, and guided operator
execution system for the manufacturing backend. Recipes are versioned process
templates with embedded bills of materials that drive both automated planning
(material forecasts, batch scheduling, stock validation) and step-by-step operator
guidance during production.

### Scope

- Recipe CRUD with versioning and a starter template library
- Production planning with split-batch support and multi-SKU packing specs
- Cascading material requirements computation
- Guided batch execution with checkpoint enforcement and alarm rules
- Material confirmation and packing execution at completion
- Integration points between service-commerce and service-manufacturing

### Out of Scope

- Full ERP/MRP engine
- Automated sensor integration (readings are operator-entered)
- Route optimization for deliveries
- Demand forecasting from sales data (future phase)

## 2. Architecture Topology

### Repository: `service-manufacturing`

```text
service-manufacturing/
├── apps/
│   └── default/
│       ├── cmd/main.go
│       ├── config/config.go
│       ├── service/
│       │   ├── handlers/
│       │   ├── business/
│       │   ├── repository/
│       │   ├── models/
│       │   └── events/
│       ├── migrations/
│       └── tests/
├── proto/
│   └── manufacturing/v1/manufacturing.proto
├── opl/
│   └── manufacturing/
├── pkg/
│   ├── inventoryclient/
│   └── notificationclient/
└── sdk/
```

The production app lives at `apps/default` following the same pattern as
service-commerce. All manufacturing concerns (recipes, plans, batches, inventory)
live in a single application.

### Facility vs Shop

A Facility is the manufacturing-side entity representing a production site (factory,
kitchen, dairy plant). It is independent from commerce shops. Recipes, plans,
batches, and inventory are scoped to a facility.

The connection between commerce and manufacturing is through inventory items — a
shop sells product variants whose stock originates from a facility's production
output. The link is via SKU or an explicit inventory_item_id on the ProductVariant.

## 3. Domain Model

### 3.1 Facility

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `name` | string | e.g. "Nairobi Dairy Plant" |
| `description` | string | |
| `location` | string | address or geolocation reference |
| `status` | enum | ACTIVE, INACTIVE |
| `properties` | jsonb | extensible metadata |

### 3.2 Recipe

Top-level entity representing a production recipe for a specific product.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `facility_id` | string | FK → facility that owns this recipe |
| `name` | string | e.g. "Vanilla Yoghurt 500ml" |
| `description` | string | human-readable summary |
| `product_item_id` | string | link to the finished good in inventory |
| `output_quantity` | decimal | standard output per batch (e.g. 100) |
| `output_unit` | string | e.g. "liters", "kg", "units" |
| `status` | enum | DRAFT, ACTIVE, ARCHIVED |
| `active_version_id` | string | FK → currently published RecipeVersion |
| `template_source_id` | string | nullable — if cloned from a RecipeTemplate |

### 3.3 RecipeVersion

Immutable snapshot of a recipe. Once published, it cannot be modified.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `recipe_id` | string | FK → parent Recipe |
| `version_number` | int | monotonically increasing per recipe |
| `status` | enum | DRAFT, PUBLISHED, SUPERSEDED |
| `created_by` | string | profile_id of author |
| `published_at` | timestamp | null until published |
| `notes` | string | changelog / reason for new version |

Version state machine: `DRAFT → PUBLISHED → SUPERSEDED`

Rules:
- A recipe has exactly one DRAFT version at any time.
- Publishing a DRAFT makes it PUBLISHED, updates the recipe's active_version_id,
  moves the previous PUBLISHED version to SUPERSEDED, and auto-creates a new DRAFT
  (copied from the just-published version).
- Active batches are unaffected by new versions — they pin to recipe_version_id at
  start time.

### 3.4 RecipeStep

Ordered process step within a recipe version.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `recipe_version_id` | string | FK → parent RecipeVersion |
| `sequence` | int | execution order (1, 2, 3...) |
| `name` | string | e.g. "Heating", "Incubation Hold" |
| `description` | string | operator-facing instructions |
| `expected_duration_minutes` | int | nullable — expected time |
| `max_duration_minutes` | int | nullable — alarm if exceeded |
| `is_checkpoint` | bool | must be explicitly completed before next step |
| `required_readings` | jsonb | array of reading specs |
| `alarm_rules` | jsonb | array of alarm rule definitions |

Reading spec schema:

```json
[
  {
    "reading_type": "temperature",
    "unit": "celsius",
    "min_value": 42.0,
    "max_value": 46.0,
    "is_required": true
  }
]
```

Alarm rule schema:

```json
[
  {
    "trigger": "reading_out_of_range",
    "reading_type": "temperature",
    "severity": "warning",
    "message": "Temperature outside acceptable range",
    "requires_acknowledgement": true
  },
  {
    "trigger": "duration_exceeded",
    "severity": "critical",
    "message": "Step duration exceeded maximum",
    "requires_acknowledgement": true
  }
]
```

### 3.5 RecipeMaterial

BOM line within a recipe version.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `recipe_version_id` | string | FK → parent RecipeVersion |
| `inventory_item_id` | string | FK → inventory item (raw material or packaging) |
| `name` | string | display name (denormalized) |
| `quantity` | decimal | required quantity per batch |
| `unit` | string | e.g. "liters", "kg", "pieces" |
| `is_optional` | bool | optional vs required |
| `tolerance_percent` | decimal | acceptable deviation (e.g. 5%) |

The recipe carries a default BOM that drives auto-planning. Operators confirm and
adjust actual quantities during execution.

### 3.6 RecipeTemplate

System-provided starter templates for common products.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `name` | string | e.g. "Plain Yoghurt" |
| `description` | string | |
| `category` | string | e.g. "dairy", "bakery" |
| `template_data` | jsonb | full recipe definition (steps + materials) |
| `status` | enum | ACTIVE, DEPRECATED |

Templates are global (not per-facility). Operators clone a template into a
facility-scoped recipe and customize it. The `template_source_id` on Recipe records
provenance but creates no ongoing dependency.

Template data structure:

```json
{
  "output_quantity": 100,
  "output_unit": "liters",
  "steps": [
    {
      "sequence": 1,
      "name": "Milk Receiving Check",
      "description": "Verify milk quality and temperature on arrival",
      "expected_duration_minutes": 10,
      "is_checkpoint": true,
      "required_readings": [
        {"reading_type": "temperature", "unit": "celsius", "min_value": 2, "max_value": 6}
      ],
      "alarm_rules": [
        {"trigger": "reading_out_of_range", "reading_type": "temperature", "severity": "critical"}
      ]
    }
  ],
  "materials": [
    {
      "name": "Whole Milk",
      "quantity": 80,
      "unit": "liters",
      "is_optional": false,
      "tolerance_percent": 5
    }
  ]
}
```

## 4. Production Planning Model

### 4.1 Problem Statement

Real-world production requires split-batch support. A single base batch (e.g. 100L
yoghurt base) can be split into multiple finished products (60L strawberry, 40L
vanilla), each packed into multiple SKU sizes (500ml, 250ml, 150ml cups). All of
this must be plannable upfront before production starts.

### 4.2 ProductionPlan

Represents a planned production run.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `facility_id` | string | FK → facility |
| `name` | string | e.g. "Monday AM Yoghurt Run" |
| `planned_date` | date | when production is scheduled |
| `planned_start_time` | timestamp | optional — shift scheduling |
| `base_recipe_id` | string | nullable — recipe for the shared base |
| `base_recipe_version_id` | string | nullable — pinned version at planning time |
| `base_output_quantity` | decimal | total base output (e.g. 100) |
| `base_output_unit` | string | e.g. "liters" |
| `process_loss_percent` | decimal | expected loss between base and plan lines |
| `status` | enum | DRAFT, VALIDATED, SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED |
| `validated_at` | timestamp | null until material check passes |
| `validated_by` | string | who confirmed feasibility |

### 4.3 ProductionPlanLine

One output product from the plan. Each line references its own recipe for downstream
processing.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `plan_id` | string | FK → parent plan |
| `sequence` | int | execution order |
| `recipe_id` | string | FK → recipe for this product |
| `recipe_version_id` | string | pinned version |
| `finished_product_id` | string | FK → inventory item / catalog product |
| `input_quantity` | decimal | how much base goes into this line |
| `input_unit` | string | must match base output unit |
| `expected_output_quantity` | decimal | expected yield after processing |
| `expected_output_unit` | string | |
| `assigned_operator_id` | string | nullable — responsible operator |
| `status` | enum | PENDING, IN_PROGRESS, COMPLETED, CANCELLED |

### 4.4 PlanLinePackingSpec

Defines how a plan line's output is packed into specific SKUs.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `plan_line_id` | string | FK → parent plan line |
| `product_variant_id` | string | FK → the specific SKU |
| `container_size` | decimal | e.g. 0.5 (liters) |
| `container_unit` | string | e.g. "liters" |
| `planned_count` | int | number of containers to fill |
| `is_remainder` | bool | if true, absorbs whatever is left |
| `actual_count` | int | nullable — filled during execution |
| `packaging_item_id` | string | FK → inventory item for the container |

At most one packing spec per plan line can have `is_remainder = true`. The remainder
count is computed as `floor(remaining_volume / container_size)`.

### 4.5 Example Mapping

Plan: "Monday AM Yoghurt Run"
- base_recipe: "Yoghurt Base" recipe
- base_output_quantity: 100L
- process_loss_percent: 0

Plan Line 1: Strawberry
- recipe: "Strawberry Yoghurt Flavoring"
- input_quantity: 60L
- expected_output_quantity: 59L

| SKU | Container | Count | Remainder |
|---|---|---|---|
| Strawberry 500ml | 0.5L | 20 | no |
| Strawberry 250ml | 0.25L | 40 | no |
| Strawberry 150ml | 0.15L | computed | yes |

Remainder: (59L - 10L - 10L) / 0.15L = 260 cups

Plan Line 2: Vanilla
- recipe: "Vanilla Yoghurt Flavoring"
- input_quantity: 40L
- expected_output_quantity: 39.5L

| SKU | Container | Count | Remainder |
|---|---|---|---|
| Vanilla 500ml | 0.5L | 10 | no |
| Vanilla 250ml | 0.25L | computed | yes |

Remainder: (39.5L - 5L) / 0.25L = 138 cups

### 4.6 Plan Validation Rules

1. Allocation balance: `sum(plan_line.input_quantity) <= base_output_quantity × (1 - process_loss_percent / 100)`. The effective available quantity is the base output minus expected process loss. Plan lines must not exceed this.
2. Packing coverage: sum of `(planned_count × container_size)` across non-remainder specs must not exceed expected_output_quantity per line.
3. At most one remainder spec per plan line.
4. Recipe compatibility: each plan line's recipe must be compatible with the base recipe's output type.

### 4.7 Plan Validation Flow

```
1. Operator creates plan (DRAFT)
2. Operator adds plan lines + packing specs
3. Operator requests validation:
   a. Scale base recipe BOM to base_output_quantity
   b. For each plan line:
      - Scale line recipe BOM to input_quantity
      - Calculate remainder packing counts
      - Compute packaging material needs
   c. Aggregate all material requirements
   d. Check each against current inventory stock
   e. Flag shortages
4. No critical shortages → plan moves to VALIDATED
5. Shortages exist → plan stays DRAFT with shortage report
   - Operator adjusts quantities, swaps specs, or overrides
6. VALIDATED → SCHEDULED (locks the plan for execution)
```

## 5. Cascading Material Requirements

### 5.1 MaterialRequirement

Computed and stored per plan for visibility and validation.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `plan_id` | string | FK → production plan |
| `inventory_item_id` | string | FK → the material needed |
| `item_name` | string | denormalized |
| `required_quantity` | decimal | total needed |
| `unit` | string | |
| `available_quantity` | decimal | stock on hand at computation time |
| `incoming_quantity` | decimal | reserved/incoming stock if trackable |
| `shortage_quantity` | decimal | max(0, required - available - incoming) |
| `source` | enum | BASE_RECIPE, LINE_RECIPE, PACKAGING |
| `plan_line_id` | string | nullable — null for base recipe materials |
| `computed_at` | timestamp | when this snapshot was taken |

### 5.2 Computation Layers

Layer 1 — Base recipe materials: scaled from the base recipe BOM to
base_output_quantity.

Layer 2 — Plan line recipe materials: scaled from each line's recipe BOM to the
line's input_quantity.

Layer 3 — Packaging materials: computed from packing specs (planned_count ×
packaging per container, including remainder calculations).

Requirements from all layers are aggregated per inventory item. The system checks
each against current facility stock and flags shortages.

## 6. Batch Execution

### 6.1 Batch

Runtime execution record created from a plan line or directly from a recipe.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `facility_id` | string | FK → facility |
| `plan_id` | string | nullable — null for ad-hoc batches |
| `plan_line_id` | string | nullable |
| `recipe_id` | string | FK → recipe being followed |
| `recipe_version_id` | string | FK → pinned recipe version (immutable) |
| `batch_number` | string | human-readable identifier |
| `status` | enum | CREATED, STARTED, PAUSED, COMPLETING, COMPLETED, ABORTED |
| `current_step_id` | string | nullable — FK → active RecipeStep |
| `current_step_sequence` | int | for quick display |
| `total_steps` | int | denormalized from recipe version |
| `input_quantity` | decimal | actual input |
| `input_unit` | string | |
| `output_quantity` | decimal | nullable — filled at completion |
| `output_unit` | string | |
| `started_at` | timestamp | |
| `completed_at` | timestamp | |
| `operator_id` | string | primary operator |

### 6.2 BatchStepExecution

Runtime state for each step in a batch.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK → parent batch |
| `recipe_step_id` | string | FK → recipe step definition |
| `sequence` | int | mirrors RecipeStep.sequence |
| `status` | enum | PENDING, ACTIVE, COMPLETED, SKIPPED |
| `started_at` | timestamp | null until operator enters step |
| `completed_at` | timestamp | null until completed |
| `completed_by` | string | operator who marked it done |
| `notes` | string | operator notes |
| `duration_minutes` | int | computed |

### 6.3 Execution Flow

```
Batch CREATED
  → System creates BatchStepExecution for each recipe step (all PENDING)

Operator taps "Start Batch"
  → Batch status → STARTED
  → Step 1 status → ACTIVE, started_at = now
  → current_step_id → step 1

Operator works through each step:
  → Records readings (temperature, pH, etc.)
  → System validates readings against recipe thresholds
  → If out of range → alarm created automatically
  → Operator taps "Complete Step"
     → If step.is_checkpoint:
        → System checks all required readings are present
        → System checks no unacknowledged blocking alarms
        → If checks pass → step COMPLETED, next step → ACTIVE
        → If checks fail → step stays ACTIVE, operator sees what's missing
     → If not checkpoint:
        → Step COMPLETED, next step → ACTIVE

Last step completed:
  → Batch status → COMPLETING
  → System prompts operator to confirm:
    - Actual output quantity
    - Actual material consumption (pre-filled, adjustable)
    - Spoilage/loss quantity
  → Operator confirms
  → Batch status → COMPLETED
  → Stock movements created (CONSUME for inputs, PRODUCE for outputs)
  → Packing specs from plan line become actionable
```

### 6.4 BatchMaterialUsage

Actual materials consumed during a batch.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK → parent batch |
| `recipe_material_id` | string | FK → recipe BOM line |
| `inventory_item_id` | string | FK → inventory item |
| `planned_quantity` | decimal | from recipe BOM (scaled) |
| `actual_quantity` | decimal | operator-confirmed |
| `unit` | string | |
| `variance_quantity` | decimal | computed: actual - planned |
| `variance_reason` | string | nullable — explains significant variance |

### 6.5 PackingExecution

Tracks actual packing against the plan's packing specs.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK → batch |
| `packing_spec_id` | string | FK → PlanLinePackingSpec |
| `product_variant_id` | string | FK → the SKU being packed |
| `planned_count` | int | from packing spec (or computed remainder) |
| `actual_count` | int | what was actually packed |
| `spoiled_count` | int | containers damaged/wasted |
| `operator_id` | string | who did the packing |
| `completed_at` | timestamp | |

When packing completes, the system creates stock-in movements for each SKU packed.

## 7. API Surface

All APIs live in `ManufacturingService` in
`proto/manufacturing/v1/manufacturing.proto`.

### 7.1 Facility Management

| RPC | Description |
|---|---|
| `CreateFacility` | Register a new production facility |
| `GetFacility` | Get facility details |
| `UpdateFacility` | Update facility metadata |
| `ListFacilities` | List facilities |

### 7.2 Recipe Management

| RPC | Description |
|---|---|
| `CreateRecipe` | Create a new recipe (auto-creates v1 DRAFT) |
| `GetRecipe` | Get recipe with active version summary |
| `ListRecipes` | List recipes for a facility |
| `UpdateRecipeDraft` | Edit the current DRAFT version (steps + materials) |
| `PublishRecipeVersion` | Publish DRAFT → PUBLISHED, creates new DRAFT |
| `GetRecipeVersion` | Get a specific version with full steps + materials |
| `ListRecipeVersions` | Version history for a recipe |
| `CloneRecipeTemplate` | Clone a system template into a facility recipe |
| `ListRecipeTemplates` | Browse the template library |

UpdateRecipeDraft accepts the full recipe definition (steps + materials) for the
current DRAFT version as a replace-all operation:

```protobuf
message UpdateRecipeDraftRequest {
  string recipe_id = 1;
  string name = 2;
  string description = 3;
  double output_quantity = 4;
  string output_unit = 5;
  repeated RecipeStepInput steps = 10;
  repeated RecipeMaterialInput materials = 11;
}
```

### 7.3 Production Planning

| RPC | Description |
|---|---|
| `CreateProductionPlan` | Create a new plan in DRAFT |
| `GetProductionPlan` | Get plan with lines and packing specs |
| `ListProductionPlans` | List plans for a facility |
| `UpdateProductionPlan` | Update plan metadata |
| `AddPlanLine` | Add an output line to the plan |
| `UpdatePlanLine` | Modify a plan line |
| `RemovePlanLine` | Remove a plan line |
| `SetPackingSpecs` | Set packing specs for a plan line (replace-all) |
| `ValidatePlan` | Compute material requirements, check stock |
| `SchedulePlan` | Move VALIDATED → SCHEDULED |
| `CancelPlan` | Cancel a plan (if no batches started) |

### 7.4 Batch Execution

| RPC | Description |
|---|---|
| `CreateBatch` | Create from plan line or ad-hoc from recipe |
| `GetBatch` | Get batch with current step state |
| `ListBatches` | List batches for a facility |
| `StartBatch` | Start execution, activates first step |
| `CompleteStep` | Mark current step done, advance to next |
| `SkipStep` | Skip a non-checkpoint step (with reason) |
| `PauseBatch` | Pause execution |
| `ResumeBatch` | Resume from pause |
| `RecordReading` | Record a process reading for current step |
| `RecordBatchNote` | Add an operator note |
| `ConfirmMaterialUsage` | Confirm actual consumption at completion |
| `RecordPackingResult` | Record actual packing counts per spec |
| `CompleteBatch` | Finalize batch, create stock movements |
| `AbortBatch` | Abort a batch (with reason) |

### 7.5 Alarms

| RPC | Description |
|---|---|
| `ListBatchAlarms` | List alarms for a batch |
| `AcknowledgeAlarm` | Acknowledge an alarm |

### 7.6 Material Requirements

| RPC | Description |
|---|---|
| `GetPlanMaterialRequirements` | Get computed requirements |
| `RefreshMaterialRequirements` | Recompute after stock changes |

### 7.7 Permissions

```
namespace: "service_manufacturing"
permissions:
  - facility_view
  - facility_create
  - facility_update
  - recipe_view
  - recipe_manage
  - plan_view
  - plan_manage
  - plan_validate
  - batch_view
  - batch_operate
  - batch_complete
  - batch_override
  - inventory_view
  - inventory_manage
  - inventory_adjust
```

Role families:
- facility_admin: all permissions
- production_manager: recipe, plan, batch, inventory (all)
- operator: batch_view, batch_operate, plan_view, recipe_view, inventory_view
- inventory_clerk: inventory_view, inventory_manage
- viewer: all *_view permissions

batch_override is a separate auditable permission for overriding alarm blocks and
skipping checkpoint steps.

## 8. Integration Between Commerce and Manufacturing

### 8.1 Separate Services, No Shared Database

Commerce and manufacturing are separate services. They integrate through typed
Connect RPC clients.

### 8.2 Product to Inventory Item Linkage

Commerce sells ProductVariant (SKU). Manufacturing produces into InventoryItem (same
SKU, stocked at a facility). The link is via SKU or an explicit inventory_item_id on
the ProductVariant.

### 8.3 Stock-Backed Selling Flow

```
1. Commerce: CreateOrder → calls Manufacturing: ReserveStock (sync RPC)
2. Manufacturing: reserves stock from facility inventory
3. Commerce: persists order only after reservation succeeds
4. Commerce: on fulfilment → calls Manufacturing: CommitReservation
5. Manufacturing: decrements actual stock
```

### 8.4 Production Output to Sellable Stock

```
1. Manufacturing: CompleteBatch → creates PRODUCE stock movements
2. Manufacturing: RecordPackingResult → creates stock-in per SKU
3. Commerce: stock quantities update via async event or periodic sync
```

### 8.5 Event-Based Integration

Manufacturing publishes outbox events:
- stock.produced — new stock available
- stock.low — below threshold
- stock.expired — lot expired

Commerce publishes:
- order.created — feeds demand visibility

## 9. Robustness

### Risk 1: Recipe version edited while batches are running

Batches pin to recipe_version_id at creation time. Publishing a new version has zero
effect on in-flight batches.

### Risk 2: Plan validation passes but stock consumed before batch starts

Validation is a snapshot (computed_at timestamp). Batch start re-validates critical
materials. Shortages produce a warning; proceeding requires batch_override permission.
Plans can optionally create soft reservations at scheduling time.

### Risk 3: Operator skips checkpoint steps or ignores alarms

Checkpoint steps block progression until all required readings are present and all
critical alarms are acknowledged. Skipping requires batch_override permission and
creates an audit entry. CompleteBatch enforces all checkpoints are COMPLETED unless
overridden.

### Risk 4: Split allocation doesn't add up

ValidatePlan enforces: `sum(plan_line.input_quantity) <= base_output_quantity × (1 - process_loss_percent / 100)`. Plan lines must not exceed the effective available quantity (base output minus expected process loss). Validation returns a specific error identifying the gap.

### Risk 5: Packing remainder produces fractional cups

Remainder count uses floor division. The leftover fraction is reported as expected
process loss. Actual counts are captured during packing execution.

### Risk 6: Ad-hoc batches bypass planning

Ad-hoc batches are supported (plan_id is nullable). They still follow the recipe's
steps and BOM, confirm material usage at completion, and create stock movements. They
lack pre-computed material requirements and packing specs.

### Risk 7: Template library updates vs facility recipes

Templates are a starting point, not a live link. template_source_id records
provenance but creates no ongoing dependency. Safety-critical template updates are
communicated through the notification service.

### Risk 8: Concurrent step completion on the same batch

Step completion uses optimistic locking. Only the first completion succeeds. The
batch's current_step_id is the authoritative single-writer pointer.

### Risk 9: Batch completion fails midway through stock movements

CompleteBatch wraps all stock movements in a single database transaction. Failure
rolls back the entire completion. Batch stays in COMPLETING status for retry.
Idempotency key prevents duplicate movements.

## 10. Observability

### Business Metrics

| Metric | Type |
|---|---|
| `recipe_version_published_total` | counter |
| `plan_validated_total` | counter |
| `plan_validation_shortage_total` | counter |
| `batch_started_total` | counter |
| `batch_completed_total` | counter |
| `batch_aborted_total` | counter |
| `batch_duration_seconds` | histogram |
| `step_duration_seconds` | histogram |
| `reading_out_of_range_total` | counter |
| `alarm_created_total` | counter |
| `alarm_acknowledgement_latency_seconds` | histogram |
| `material_variance_percent` | histogram |
| `packing_variance_percent` | histogram |
| `batch_override_total` | counter |

### Structured Log Events

Critical actions that must appear in structured logs:
- Recipe version published (who, what changed)
- Plan validated (shortages found or not)
- Batch started / completed / aborted
- Checkpoint step overridden (who, reason)
- Alarm acknowledged (who, how long it was open)
- Material variance exceeding tolerance

## 11. Database Tables

### Manufacturing Tables

- `facilities`
- `recipes`
- `recipe_versions`
- `recipe_steps`
- `recipe_materials`
- `recipe_templates`
- `production_plans`
- `production_plan_lines`
- `plan_line_packing_specs`
- `material_requirements`
- `batches`
- `batch_step_executions`
- `batch_material_usages`
- `packing_executions`
- `batch_readings`
- `batch_alarms`
- `inventory_items`
- `stock_locations`
- `stock_lots`
- `stock_movements`
- `stock_reservations`
- `stock_balances`
- `outbox_events`

### Indexing Priorities

- recipes by facility_id, status
- recipe_versions by recipe_id, status
- recipe_steps by recipe_version_id, sequence
- recipe_materials by recipe_version_id
- production_plans by facility_id, planned_date, status
- production_plan_lines by plan_id, sequence
- plan_line_packing_specs by plan_line_id
- material_requirements by plan_id, inventory_item_id
- batches by facility_id, plan_id, status, started_at
- batch_step_executions by batch_id, sequence
- batch_material_usages by batch_id
- packing_executions by batch_id
- batch_readings by batch_id, recipe_step_id
- batch_alarms by batch_id, status

## 12. Mandatory Standards

All code in service-manufacturing must comply with the golang-patterns skill:

- Frame blueprint for service scaffolding
- Connect RPC for all APIs
- Three-layer architecture: handlers → business → repository
- All models embed data.BaseModel
- All CRUD repositories use datastore.BaseRepository
- All logging uses util.Log(ctx)
- All tracing and metrics use Frame/OpenTelemetry integrations
- All permissions declared in proto
- All Connect servers use tenancy and function access interceptors
- No direct infrastructure access outside Frame abstractions
