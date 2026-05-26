# Backend Architecture

## 1. System Goals and Assumptions

This backend must satisfy four constraints at the same time:

1. It must be simple enough for a small yoghurt producer to adopt quickly.
2. It must remain operationally safe as more modules and frontend clients are added.
3. It must scale from a single outlet to multi-location, multi-team, high-volume operations.
4. It must follow the mandatory Go conventions in the local `golang-patterns` skill.

Assumptions:

- Backend stack is Go + Frame + Connect RPC + PostgreSQL + NATS + Valkey.
- `service-profile`, `service-fintech/identity`, `service-payment`,
  `service-files`, `service-notification`, and `service-profile/geolocation`
  are reused rather than duplicated.
- Domain applications must remain separate applications that can be run and
  tested independently.
- Sales belongs to the commerce domain.
- Inventory and production belong to a separate operations domain.

## 2. Core Design Principles

1. Keep business truth in small bounded contexts with explicit ownership.
2. Keep transactional write paths synchronous when correctness depends on them.
3. Use append-only journals for stock and financial allocations where auditability matters.
4. Keep async processing out of the critical sale and batch-completion path.
5. Keep deployment flexible without collapsing domain boundaries.
6. Prefer evolutionary scale: start small, split only where ownership or load proves it necessary.

## 3. Repository and Application Topology

The platform should be built as two domain repositories with independently
runnable applications inside each repository.

### 3.1 Commerce Repository

Repository: `service-commerce`

Applications:

- `apps/catalog`
- `apps/customers`
- `apps/sales`

Responsibilities:

- sellable product catalog
- commercial customer records
- customer locations and delivery points
- sales and sale items
- returns
- receipts and receivable allocations
- salesperson assignments and performance views

### 3.2 Operations Repository

Repository: `service-operations`

Applications:

- `apps/inventory`
- `apps/production`

Responsibilities:

- inventory items
- stock locations
- stock lots
- stock movement journal
- stock balance projections
- stock reservations
- production batches
- production plans
- production process templates
- batch process events and readings
- operator alarms
- batch inputs and outputs
- spoilage
- expiry
- material requirements forecasts
- costing snapshots

### 3.3 Why Applications Are Split This Way

This split keeps every major business domain independently testable and
deployable while avoiding a large number of tiny services. Each application is
its own Frame app and its own binary. Shared domain code lives in `pkg/`
inside the owning repository.

For small deployments, the applications can share the same infrastructure
cluster and PostgreSQL instance. For larger deployments, they can be scaled and
released independently without redesigning the domain boundaries.

## 4. Mandatory Go/Frame Standards

All applications in both repositories must comply with the `golang-patterns`
skill:

- Use Frame blueprint for new services and apps.
- Use Connect RPC for all service APIs.
- Use three-layer architecture:
  `handlers -> business -> repository`.
- All models embed `data.BaseModel`.
- All CRUD repositories use `datastore.BaseRepository`.
- All logging uses `util.Log(ctx)`.
- All tracing and metrics use Frame/OpenTelemetry integrations.
- All service and method permissions are declared in proto.
- All Connect servers use tenancy and function access interceptors.
- All async execution follows the Frame decision tree:
  workerpool for bounded local concurrency, events for fast internal async,
  queue for cross-service or durable work.

No application may access PostgreSQL, NATS, or Valkey directly outside Frame
abstractions.

## 5. Plane Decomposition

### 5.1 Interaction Plane

Applications expose Connect RPC APIs only.

Commerce:

- CatalogService
- CustomerService
- SalesService

Operations:

- InventoryService
- ProductionService

The Flutter frontend can call these services directly or through a future BFF.

### 5.2 Control Plane

Control responsibilities:

- configuration loading
- auth and authz
- idempotency enforcement
- domain policy selection
- deployment profile selection

Each application owns its configuration and service lifecycle.

### 5.3 Execution Plane

Business logic lives in business packages and owns:

- sale validation
- stock reservation orchestration
- production planning
- material requirements forecasting
- process step progression
- process alarm evaluation
- batch completion
- FEFO lot allocation
- receipt allocation
- customer balance calculation
- pricing, discount, and override policies

### 5.4 Data Plane

Data ownership is explicit:

- Commerce owns commercial records.
- Operations owns stock and production records.
- Profile owns profile/contact/address master records.
- Identity owns workforce/team/org structure.
- Payment owns rail processing records.

### 5.5 Integration Plane

Cross-service integrations:

- Commerce -> Operations for stock-backed selling
- Commerce -> Profile for customer identity references
- Commerce -> Identity for salesperson and org references
- Commerce -> Payment for external payment execution
- Commerce -> Notification for reminders
- Operations -> Notification for low stock and expiry alerts
- Operations -> Notification for production process alarms and operator prompts
- Both -> Files for attachments
- Both -> Geolocation later for route-aware workflows

## 6. Domain Ownership

### 6.1 Catalog Application

Owns:

- products
- product variants
- commercial packaging metadata
- visibility and selling state

Notes:

- catalog remains in commerce because it defines what can be sold
- raw materials do not belong here

### 6.2 Customers Application

Owns:

- commercial customer accounts
- customer type
- assigned salesperson
- credit policy
- payment terms
- customer notes
- customer locations

It must not duplicate the identity master from `service-profile`.

The customer record in commerce references:

- `profile_id`
- one or more profile address records when available
- optional geolocation identifiers

### 6.3 Sales Application

Owns:

- sales
- sale items
- returns
- discounts and reasons
- receipts
- receipt allocations
- receivable and balance projections
- salesperson performance views

### 6.4 Inventory Application

Owns:

- inventory items
- stock locations
- stock lots
- stock movements
- stock reservations
- current balance projections

This is the source of truth for what exists physically.

### 6.5 Production Application

Owns:

- production batches
- production plans
- process templates
- process checkpoints and events
- process readings such as temperature, hold time, and packing start
- operator alarms and acknowledgements
- input consumption
- output creation
- spoilage
- expiry
- material requirements forecasts
- costing snapshots

This is the source of truth for what was manufactured and from which inputs.

The production application is intentionally not a full MES. It captures only
the production facts that drive execution, traceability, alarms, and material
foresight.

## 7. Customer and Location Model

Customer capture must support both identity and operational delivery needs.

### 7.1 Customer Master Pattern

Commerce customer record:

- `id`
- `profile_id`
- `customer_type`
- `assigned_salesperson_member_id`
- `credit_limit`
- `payment_terms_days`
- `status`
- `notes`

The identity details come from `service-profile`:

- legal or display name
- contacts
- canonical addresses

### 7.2 Customer Locations

Commerce must own customer locations because sales and delivery behavior
depends on them.

`customer_locations` fields:

- `id`
- `customer_id`
- `profile_address_id`
- `name`
- `location_type`
  - billing
  - delivery
  - branch
  - warehouse
  - kiosk
  - route_stop
- `contact_name`
- `contact_phone`
- `latitude`
- `longitude`
- `geo_area_id`
- `landmark`
- `delivery_instructions`
- `service_window_start`
- `service_window_end`
- `is_default_billing`
- `is_default_delivery`
- `state`

This allows:

- one customer with many outlets
- delivery-specific routing later
- branch-level sales analysis
- field-sales stop tracking

## 8. Data Model

### 8.1 Commerce Tables

- `products`
- `product_variants`
- `customer_accounts`
- `customer_locations`
- `customer_assignments`
- `customer_notes`
- `sales`
- `sale_items`
- `sale_returns`
- `receipts`
- `receipt_allocations`
- `customer_balance_projections`
- `outbox_events`

### 8.2 Operations Tables

- `inventory_items`
- `stock_locations`
- `stock_lots`
- `stock_movements`
- `stock_reservations`
- `stock_balances`
- `production_plans`
- `production_plan_lines`
- `production_batches`
- `production_process_templates`
- `production_process_steps`
- `batch_process_events`
- `batch_process_readings`
- `batch_operator_alarms`
- `batch_inputs`
- `batch_outputs`
- `material_requirement_snapshots`
- `cost_snapshots`
- `outbox_events`

### 8.3 Journal and Projection Pattern

Source-of-truth journals:

- `stock_movements`
- `receipts`
- `receipt_allocations`

Fast read projections:

- `stock_balances`
- `customer_balance_projections`

The journals are append-only. Projections are recalculated transactionally on
write and repairable by replay jobs when necessary.

## 9. Application APIs

### 9.1 CatalogService

Core RPCs:

- `ProductSave`
- `ProductGet`
- `ProductSearch`
- `VariantSave`
- `VariantGet`
- `VariantSearch`
- `VariantArchive`

### 9.2 CustomerService

Core RPCs:

- `CustomerSave`
- `CustomerGet`
- `CustomerSearch`
- `CustomerLocationSave`
- `CustomerLocationGet`
- `CustomerLocationSearch`
- `CustomerAssignmentSave`
- `CustomerBalanceGet`
- `CustomerNoteSave`

### 9.3 SalesService

Core RPCs:

- `CreateSale`
- `GetSale`
- `SearchSales`
- `CancelSale`
- `ReturnSale`
- `RecordReceipt`
- `AllocateReceipt`
- `ReverseReceipt`
- `SalesSummary`
- `SalespersonSummary`

### 9.4 InventoryService

Core RPCs:

- `InventoryItemSave`
- `InventoryItemGet`
- `InventoryItemSearch`
- `LocationSave`
- `LocationGet`
- `LocationSearch`
- `RecordStockIn`
- `RecordAdjustment`
- `TransferStock`
- `ReserveStock`
- `CommitReservation`
- `ReleaseReservation`
- `GetStockBalance`
- `SearchStockMovements`
- `ExpiryReport`

### 9.5 ProductionService

Core RPCs:

- `ProductionPlanSave`
- `ProductionPlanGet`
- `ProductionPlanSearch`
- `MaterialRequirementsForecast`
- `CreateBatch`
- `GetBatch`
- `SearchBatches`
- `StartBatch`
- `RecordBatchProcessEvent`
- `RecordBatchProcessReading`
- `TriggerBatchAlarm`
- `AcknowledgeBatchAlarm`
- `CompleteBatch`
- `RecordSpoilage`
- `ProductionSummary`
- `YieldReport`

## 10. Production Planning and Process Control

### 10.1 Planning Model

Production planning must support short-horizon operational planning without
introducing a full ERP or MRP engine.

Core planning entities:

- `production_plans`
- `production_plan_lines`

Each plan line defines:

- planned production date/time
- finished good to produce
- target location
- planned quantity
- preferred batch size
- optional responsible team or operator
- planning status

Plans are used for:

- planned capacity visibility
- raw material requirement forecasts
- packaging requirement forecasts
- operator workload planning
- future expiry and finished-stock outlook

### 10.2 Material Foresight

The production application must support material foresight from planned output.

This is not a full generic MRP engine. It is a controlled planning calculation
for the owned production catalog.

Required capabilities:

- maintain per-finished-good production standards
- compute raw material requirements from planned batches
- compute packaging requirements from planned batches
- compare planned demand against available and incoming stock
- identify shortages by item and date
- identify infeasible planned output before execution starts

### 10.3 Process Templates

Production must support simple process templates per product family or batch
type.

Examples of steps:

- milk receiving check
- heating started
- starter culture added
- mixing completed
- incubation hold started
- incubation hold ended
- flavouring started
- packing started
- packing completed
- cold-room transfer completed

Templates define:

- ordered process steps
- optional required readings
- acceptable reading ranges
- expected duration windows
- alarm rules

### 10.4 Process Event Capture

The system must capture execution along the way, not only at completion.

`batch_process_events` should capture:

- batch started
- step entered
- step completed
- pause
- resume
- operator note
- packing started
- packing completed

### 10.5 Process Readings

The system must capture readings that matter operationally and for traceability.

Examples:

- temperature
- pH
- volume
- elapsed hold time
- packed quantity so far

Reading fields:

- `batch_id`
- `step_id`
- `reading_type`
- `value_decimal`
- `value_unit`
- `recorded_at`
- `operator_member_id`
- `source`

### 10.6 Operator Alarms

Production must support lightweight alarms, not a heavy automation system.

Alarm triggers include:

- packing start due
- temperature outside threshold
- hold duration exceeded
- insufficient packaging for planned output
- insufficient raw materials before scheduled batch start
- batch delayed beyond allowed window

Alarm actions:

- create alarm record
- mark severity
- notify operator or supervisor through notification service
- require acknowledgement where configured

This supports operational prompting such as notifying the operator when packing
should start and warning when planned output cannot be produced with current
stock.

## 11. Critical Execution Flows

### 11.1 Direct Sale

1. `SalesService.CreateSale` validates customer, location, pricing, and discount policy.
2. Sales calls Inventory synchronously to reserve or commit stock from the selected location.
3. Inventory allocates stock by FEFO where expiry applies.
4. Sales persists sale and sale items only after stock succeeds.
5. If payment is present, sales persists a local receipt immediately.
6. External rail execution is linked to the receipt but is not required for the receipt record to exist.

### 11.2 Van or Field Sale

1. Inventory transfers stock from warehouse to salesperson location.
2. Sales records sale from salesperson location.
3. Inventory decrements that location.
4. Unsold stock returns as a transfer back to warehouse.
5. Reports compare issued, sold, returned, spoiled.

### 11.3 Planned Batch Start

1. Production plan line is selected for execution.
2. Production validates capacity window and required material forecast.
3. Production creates a batch from the plan or links an existing draft batch.
4. Production records `batch started` process event.
5. If critical shortages or blocking alarms exist, the start is blocked or requires override.

### 11.4 Batch Completion

1. Production validates batch state and required inputs.
2. Inventory balance rows are locked.
3. Production validates required process checkpoints for the configured template.
4. Production validates blocking alarms have been acknowledged or explicitly overridden.
5. Input consumption creates `CONSUME` stock movements.
6. Finished goods create output lot and `PRODUCE` movement.
7. Losses create `SPOIL` movement.
8. Balance projections and cost snapshots update in the same transaction.

### 11.5 Receipt Allocation

1. Sales creates local receipt.
2. Sales allocates receipt to outstanding sales.
3. Customer balance projection updates.
4. Reconciliation with external provider occurs asynchronously where applicable.

## 12. Failure and Recovery Behavior

### 12.1 Idempotency

Every mutating RPC must accept an `idempotency_key`.

Required on:

- stock-in
- stock adjustment
- transfer
- batch start
- process event capture
- process reading capture
- batch completion
- sale creation
- receipt recording
- return posting

### 12.2 Transaction Boundaries

Each application writes only to its own database.

Cross-application correctness uses:

- synchronous RPC between owners for critical approval/commit steps
- local transaction per owner
- outbox events for non-critical side effects

### 12.3 Projection Repair

Each repository must provide replay or rebuild commands for:

- stock balances
- customer balances
- material requirement snapshots

These run independently and do not block normal traffic.

## 13. Concurrency and Scalability

### 13.1 Concurrency Model

- row-level locking for stock balances and lots
- deterministic FEFO lot allocation
- reservation-first selling for high-contention stock
- single-active transition for blocking process steps per batch
- no async stock decrement for sale confirmation

### 13.2 Small Company Profile

Deploy:

- catalog
- customers
- sales
- inventory
- production

All on a shared PostgreSQL cluster and shared NATS instance.

### 13.3 Growth Profile

- scale sales separately from production
- add read replicas for reporting
- partition large journal tables by month

### 13.4 Large Company Profile

- independent autoscaling per application
- dedicated worker queues for reconciliation and exports
- separate reporting stores only if read pressure proves it necessary

The same domain boundaries remain valid across all three profiles.

## 14. Security Model

Each application must declare its own permission namespace in proto.

Suggested namespaces:

- `service_catalog`
- `service_customers`
- `service_sales`
- `service_inventory`
- `service_production`

Suggested role families:

- owner_admin
- production_manager
- sales_manager
- salesperson
- cashier_accountant

Sensitive overrides:

- expired stock sale override
- stock adjustment override
- discount override
- receipt reversal
- batch finalization override
- process alarm override

## 15. Observability

Every application must emit:

- request traces
- cross-service client traces
- structured logs
- counters for critical commands
- duration histograms for critical commands

Required business metrics:

- `sales_create_total`
- `sales_create_error_total`
- `receipt_record_total`
- `stock_reserve_total`
- `stock_reserve_error_total`
- `batch_complete_total`
- `batch_complete_error_total`
- `batch_alarm_total`
- `batch_reading_out_of_range_total`
- `material_requirement_shortage_total`
- `stock_adjustment_total`
- `expiring_stock_items_total`
- `customer_balance_outstanding_total`

## 16. Simplicity and Trade-Off Review

The production planning and process model is intentionally constrained:

- step templates are linear and simple
- alarms are rule-based
- forecasts are bounded to owned production standards
- there is no generic workflow engine in the critical path
- there is no attempt to model full plant automation

This design deliberately avoids:

- full ERP scope
- event sourcing
- shared-database writes across domains
- workflow engines in critical paths
- route optimization engines in MVP
- separate reporting microservices in MVP

The main trade-off is that there are multiple applications from day one.
That is accepted because independent run/test boundaries are a hard requirement.
Operational simplicity is preserved by keeping the number of repositories and
bounded contexts small and by reusing the existing platform services.

## 17. Robustness Gate

### Risk 1: Duplicate mobile retries create duplicate sales or receipts

Mitigation:

- idempotency key unique indexes
- request replay detection in business layer

### Risk 2: Concurrent selling causes oversell

Mitigation:

- reservation-first inventory flow
- row locks on affected balance and lot rows
- FEFO allocation in a single transaction

### Risk 3: Provider settlement diverges from internal collections

Mitigation:

- local receipt state machine is authoritative for commercial operations
- provider references are linked, not primary
- reconciliation jobs and exception reports run independently

### Risk 4: Planned production is unrealistic because standards or stock are stale

Mitigation:

- material requirement forecasts are timestamped snapshots
- forecast output always declares input assumptions
- batch start re-validates actual stock before execution
- shortage alarms are raised before blocking steps begin
