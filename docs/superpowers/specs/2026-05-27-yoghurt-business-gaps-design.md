# Yoghurt Business Operations — Gap Coverage Design

## 1. Overview

This spec defines the remaining operational capabilities needed to run a complete
yoghurt business on the antinvestor platform. It extends the existing
service-commerce and service-manufacturing architectures with ten domain areas
that were identified as gaps in the original design.

### Scope

- Procurement and supplier management
- Inbound quality control and receiving inspection
- Traceability and recall management
- Cold chain monitoring
- Shelf life and expiry label management
- Equipment and cleaning (CIP)
- Waste and by-product management
- Pricing management
- Costing and margin analysis
- Demand-driven production planning

### Out of Scope

- Full ERP/MRP engine
- Automated IoT device provisioning (readings API supports device push)
- Route optimization for deliveries
- Multi-currency pricing
- Tax/VAT engine
- Loyalty/rewards programs

### Key Decision: property_id

All entities that were previously scoped to a facility use `property_id` instead
of `facility_id`. A property represents a physical site (factory, kitchen, dairy
plant) managed by the existing property service. This avoids introducing a
parallel location concept and reuses the platform's existing geospatial and
hierarchical property model.

## 2. Service Topology

These gaps extend the existing two-repository structure:

```text
service-commerce/
  apps/catalog/           (existing)
  apps/customers/         (existing)
  apps/sales/             (existing — gains pricing entities)
  apps/procurement/       (NEW)

service-manufacturing/
  apps/default/           (existing — gains quality, equipment, waste,
                           cold chain, traceability, costing, shelf life,
                           demand planning)
```

No new repositories. Each gap is a module within the owning application,
following the three-layer architecture (handlers → business → repository).

## 3. Procurement & Supplier Management

### Where It Lives

`service-commerce/apps/procurement/`

Procurement is the buy-side mirror of sales. Sales manages selling to customers;
procurement manages buying from suppliers. Both are commercial relationships with
pricing, terms, and payment tracking.

### 3.1 Supplier

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `profile_id` | string | links to service-profile for identity |
| `name` | string | display name (denormalized) |
| `supplier_type` | enum | RAW_MATERIAL, PACKAGING, SERVICE, EQUIPMENT |
| `status` | enum | ACTIVE, SUSPENDED, INACTIVE |
| `payment_terms_days` | int | e.g. 30 |
| `currency` | string | preferred currency |
| `lead_time_days` | int | default lead time for planning |
| `rating` | enum | UNRATED, APPROVED, PREFERRED, PROBATION |
| `notes` | string | |

### 3.2 SupplierItem

What a supplier can provide and at what price.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `supplier_id` | string | FK |
| `inventory_item_id` | string | FK → manufacturing inventory item |
| `supplier_sku` | string | supplier's own code |
| `unit_price` | Money | price per unit |
| `min_order_quantity` | decimal | minimum order |
| `unit` | string | e.g. "liters", "kg" |
| `lead_time_days` | int | nullable — overrides supplier default |
| `status` | enum | ACTIVE, DISCONTINUED |

### 3.3 PurchaseOrder

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | receiving property |
| `supplier_id` | string | FK |
| `order_number` | string | human-readable |
| `status` | enum | DRAFT, SUBMITTED, CONFIRMED, PARTIALLY_RECEIVED, RECEIVED, CANCELLED |
| `expected_delivery_date` | date | |
| `submitted_at` | timestamp | |
| `submitted_by` | string | |
| `total_amount` | Money | computed |
| `notes` | string | |
| `plan_id` | string | nullable — if generated from material requirements |

### 3.4 PurchaseOrderLine

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `purchase_order_id` | string | FK |
| `supplier_item_id` | string | FK |
| `inventory_item_id` | string | FK |
| `ordered_quantity` | decimal | |
| `received_quantity` | decimal | running total |
| `unit_price` | Money | snapshot from supplier item |
| `unit` | string | |
| `status` | enum | PENDING, PARTIALLY_RECEIVED, RECEIVED, CANCELLED |

### 3.5 GoodsReceipt

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `purchase_order_id` | string | FK |
| `property_id` | string | |
| `received_by` | string | operator who received |
| `received_at` | timestamp | |
| `status` | enum | PENDING_INSPECTION, ACCEPTED, PARTIALLY_ACCEPTED, REJECTED |
| `notes` | string | |

### 3.6 GoodsReceiptLine

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `goods_receipt_id` | string | FK |
| `purchase_order_line_id` | string | FK |
| `inventory_item_id` | string | FK |
| `received_quantity` | decimal | |
| `accepted_quantity` | decimal | after inspection |
| `rejected_quantity` | decimal | |
| `rejection_reason` | string | |
| `lot_number` | string | assigned or supplier-provided |
| `expiry_date` | date | for perishables |
| `unit` | string | |

### 3.7 Procurement Flow

```
1. Material requirements show shortage → operator creates PO
   (or system suggests PO from shortages via SuggestPurchaseOrders)
2. PO submitted to supplier (external — system tracks status)
3. Goods arrive → operator creates GoodsReceipt against PO
4. Each receipt line triggers receiving inspection (Section 4)
5. Accepted lines → stock-in movement in manufacturing inventory
6. PO line received_quantity updates; PO status transitions automatically
7. Rejected lines create a rejection record — no stock movement
```

### 3.8 PurchaseOrder Status Machine

```
DRAFT → SUBMITTED → CONFIRMED → PARTIALLY_RECEIVED → RECEIVED
                  ↘ CANCELLED
```

- DRAFT: operator is building the PO
- SUBMITTED: sent to supplier
- CONFIRMED: supplier acknowledged
- PARTIALLY_RECEIVED: at least one goods receipt exists but lines remain open
- RECEIVED: all lines fully received
- CANCELLED: PO cancelled (only before RECEIVED)

### 3.9 Procurement APIs

| RPC | Description |
|---|---|
| `SupplierSave` | Create or update supplier |
| `SupplierGet` | Get supplier details |
| `SupplierSearch` | List/search suppliers |
| `SupplierItemSave` | Link a supplier to an inventory item with price |
| `SupplierItemSearch` | List supplier items |
| `PurchaseOrderCreate` | Create PO (manual or from material requirements) |
| `PurchaseOrderGet` | Get PO with lines |
| `PurchaseOrderSearch` | List/filter POs |
| `PurchaseOrderSubmit` | Move DRAFT → SUBMITTED |
| `PurchaseOrderCancel` | Cancel a PO |
| `GoodsReceiptCreate` | Record delivery against PO |
| `GoodsReceiptGet` | Get receipt with lines |
| `GoodsReceiptSearch` | List receipts |
| `SuggestPurchaseOrders` | Generate PO suggestions from material shortages |

### 3.10 Procurement Integration Points

- Manufacturing → Procurement: material requirement shortages generate PO suggestions
- Procurement → Manufacturing: accepted goods receipt triggers stock-in via Connect RPC
- Procurement → Quality: goods receipt lines feed into receiving inspection
- Procurement → Costing: purchase prices flow into batch cost computation

### 3.11 Procurement Permissions

```
namespace: "service_procurement"
permissions:
  - supplier_view
  - supplier_manage
  - purchase_order_view
  - purchase_order_create
  - purchase_order_submit
  - purchase_order_cancel
  - goods_receipt_view
  - goods_receipt_create
```

Role families:
- procurement_admin: all permissions
- procurement_manager: all except cancel
- buyer: purchase_order_view, purchase_order_create, purchase_order_submit, goods_receipt_view, goods_receipt_create
- viewer: all *_view permissions

### 3.12 Procurement Robustness

**Risk: duplicate goods receipts for the same delivery.**

Mitigation: idempotency key on GoodsReceiptCreate. received_quantity on a PO line
cannot exceed ordered_quantity — the system rejects receipt lines that would
overflow.

**Risk: PO created from stale shortage data.**

Mitigation: SuggestPurchaseOrders recomputes material requirements at call time,
not from cached snapshots. Suggestions include a `computed_at` timestamp so the
operator sees data freshness.

**Risk: partial delivery with remaining lines forgotten.**

Mitigation: PO stays in PARTIALLY_RECEIVED until all lines reach RECEIVED or
CANCELLED. Background alerts for POs in PARTIALLY_RECEIVED longer than a
configurable threshold (default: lead_time_days × 2).

## 4. Inbound Quality Control

### Where It Lives

`service-manufacturing/apps/default/` — quality control determines whether
incoming materials are fit for production. The readings, thresholds, and
accept/reject decisions are manufacturing concerns.

### 4.1 InspectionTemplate

Defines what to check for a given material type.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `inventory_item_id` | string | nullable — if item-specific |
| `material_category` | string | e.g. "raw_milk", "culture", "packaging" |
| `name` | string | e.g. "Raw Milk Receiving Check" |
| `reading_specs` | jsonb | array of required readings with thresholds |
| `pass_criteria` | enum | ALL_PASS, MAJORITY_PASS, CUSTOM |
| `status` | enum | ACTIVE, ARCHIVED |

Reading spec schema (same pattern as recipe step readings):

```json
[
  {
    "reading_type": "temperature",
    "unit": "celsius",
    "min_value": 2,
    "max_value": 6,
    "is_required": true
  },
  {
    "reading_type": "fat_content",
    "unit": "percent",
    "min_value": 3.2,
    "max_value": 4.0,
    "is_required": true
  },
  {
    "reading_type": "antibiotic_residue",
    "unit": "boolean",
    "min_value": 0,
    "max_value": 0,
    "is_required": true
  },
  {
    "reading_type": "somatic_cell_count",
    "unit": "cells_per_ml",
    "min_value": 0,
    "max_value": 400000,
    "is_required": false
  }
]
```

### 4.2 ReceivingInspection

Actual inspection performed on a goods receipt line.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `goods_receipt_line_id` | string | FK — links to procurement |
| `inventory_item_id` | string | FK |
| `template_id` | string | FK → InspectionTemplate used |
| `status` | enum | PENDING, IN_PROGRESS, PASSED, FAILED, CONDITIONAL_PASS |
| `inspector_id` | string | operator who performed inspection |
| `inspected_at` | timestamp | |
| `overall_notes` | string | |
| `supplier_id` | string | denormalized for analytics |

### 4.3 InspectionReading

Individual measurement during an inspection.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `inspection_id` | string | FK |
| `reading_type` | string | e.g. "temperature" |
| `value_decimal` | decimal | |
| `value_unit` | string | |
| `min_threshold` | decimal | from template at inspection time |
| `max_threshold` | decimal | |
| `passed` | bool | computed |
| `source` | enum | MANUAL, DEVICE, LAB |
| `recorded_at` | timestamp | |
| `recorded_by` | string | |

### 4.4 Inspection Flow

```
1. GoodsReceipt created in procurement
2. Manufacturing auto-creates ReceivingInspection per receipt line
   (matches inventory_item_id to an InspectionTemplate)
3. Inspector records readings against the template
4. System evaluates pass/fail per reading and overall
5. PASSED → signals procurement to accept the line → stock-in movement created
6. FAILED → signals procurement to reject → no stock movement
7. CONDITIONAL_PASS → requires override permission, creates audit entry
```

### 4.5 Quality Control APIs

| RPC | Description |
|---|---|
| `InspectionTemplateSave` | Create/update inspection template |
| `InspectionTemplateGet` | Get template |
| `InspectionTemplateSearch` | List templates |
| `GetReceivingInspection` | Get inspection with readings |
| `ListReceivingInspections` | Search/filter inspections |
| `RecordInspectionReading` | Record a reading |
| `CompleteInspection` | Evaluate and finalize |
| `OverrideInspection` | Force-pass a failed inspection (audited) |
| `SupplierQualityReport` | Aggregate pass/fail rates by supplier |

### 4.6 Quality Control Permissions

```
permissions:
  - inspection_view
  - inspection_perform
  - inspection_override
  - inspection_template_manage
```

inspection_override is a separate auditable permission for conditional-passing a
failed inspection. Override creates a structured audit record with the operator,
reason, and which readings failed.

### 4.7 Quality Control Robustness

**Risk: goods accepted without inspection.**

Mitigation: GoodsReceiptLine starts in a state where no stock-in movement is
created. Only a PASSED or CONDITIONAL_PASS inspection triggers the stock-in. If
no InspectionTemplate matches the item, the line is auto-passed (configurable:
strict mode requires a template for every item).

**Risk: inspector overrides everything to speed up receiving.**

Mitigation: OverrideInspection requires a distinct permission (inspection_override)
and creates a permanent audit entry. SupplierQualityReport surfaces override
frequency. Alerts fire when override rate exceeds a configurable threshold.

**Risk: template thresholds are wrong.**

Mitigation: templates are versioned implicitly — InspectionReading snapshots
min_threshold and max_threshold from the template at recording time. Changing a
template does not retroactively change past inspection results.

## 5. Traceability & Recall Management

### Where It Lives

`service-manufacturing/apps/default/` — the trace data originates in
manufacturing (lots → batches → outputs → stock movements).

### 5.1 Design Approach

No new tables are needed for the trace itself. The data already exists across
batch_material_usages, batches, packing_executions, stock_movements, and
stock_lots. What is new is lot provenance enrichment and a recall workflow.

### 5.2 StockLot Provenance Extensions

Add provenance fields to the existing stock_lots model:

| Field | Type | Notes |
|---|---|---|
| `supplier_id` | string | nullable — who supplied this material |
| `purchase_order_id` | string | nullable — which PO brought it in |
| `goods_receipt_id` | string | nullable — which delivery |
| `inspection_id` | string | nullable — which inspection cleared it |
| `source_batch_id` | string | nullable — if produced internally |
| `origin_lot_ids` | string[] | nullable — parent lots if transformed/split |

Every lot becomes a node in a directed acyclic graph of provenance. Raw material
lots point to suppliers and POs. Output lots point to source batches. The trace
walks this graph.

### 5.3 Recall

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `title` | string | e.g. "Antibiotic contamination — Supplier X milk batch" |
| `reason` | string | detailed description |
| `severity` | enum | PRECAUTIONARY, MANDATORY, CRITICAL |
| `status` | enum | INITIATED, INVESTIGATING, ACTIVE, RESOLVED, CLOSED |
| `initiated_by` | string | operator/manager who started it |
| `initiated_at` | timestamp | |
| `resolved_at` | timestamp | |

### 5.4 RecallLot

Affected lots identified during the trace.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `recall_id` | string | FK |
| `lot_id` | string | FK → stock_lot |
| `lot_type` | enum | SOURCE_MATERIAL, INTERMEDIATE, FINISHED_GOOD |
| `batch_id` | string | nullable — batch that used/produced this lot |
| `disposition` | enum | QUARANTINED, DESTROYED, RETURNED, CLEARED |
| `notes` | string | |

### 5.5 Trace Algorithms

**Forward trace** (from source lot → what was produced → who bought it):

```
Input: lot_id (e.g. raw milk lot from Supplier X)
1. Find all batch_material_usages where this lot was consumed → batch_ids
2. For each batch → find output lots (stock_lots where source_batch_id = batch_id)
3. For each output lot → find packing_executions → product_variant_ids
4. For each output lot → find stock_movements of type SELL → order references
5. Call Commerce.SearchSales for affected lot/SKU combinations
Return: tree of { batches, output_lots, packed_skus, affected_orders }
```

**Reverse trace** (from customer complaint → back to raw materials):

```
Input: product_variant_id + lot_number (from customer/label)
1. Find stock_lot by lot_number
2. Find source_batch_id on that lot → batch
3. Find batch_material_usages for that batch → input lots
4. For each input lot → supplier_id, purchase_order_id, inspection_id
5. Recursively trace if input lot has origin_lot_ids (multi-stage production)
Return: tree of { batch, input_lots, suppliers, inspections, sibling_output_lots }
```

### 5.6 Recall Flow

```
1. Operator initiates recall with a trigger lot or batch
2. System auto-runs forward trace to identify all affected downstream lots
3. Recall status → INVESTIGATING
4. All identified lots get RecallLot entries with disposition = QUARANTINED
5. Quarantined lots are immediately excluded from FEFO allocation
6. Operator investigates each branch, sets final disposition
7. ACTIVE recall triggers notifications to affected customers
   (identified through forward trace → sales)
8. All lots dispositioned → recall can be RESOLVED → CLOSED
```

### 5.7 Traceability APIs

| RPC | Description |
|---|---|
| `TraceForward` | From a source lot, find all downstream products and sales |
| `TraceReverse` | From a finished good lot, find all upstream materials and suppliers |
| `InitiateRecall` | Create a recall, auto-run forward trace to identify affected lots |
| `GetRecall` | Get recall with affected lots |
| `ListRecalls` | Search/filter recalls |
| `UpdateRecallLotDisposition` | Mark lot as quarantined, destroyed, cleared, etc. |
| `ResolveRecall` | Close a recall after all lots are dispositioned |

### 5.8 Traceability Permissions

```
permissions:
  - trace_view
  - recall_initiate
  - recall_manage
  - recall_resolve
```

### 5.9 Traceability Robustness

**Risk: trace is slow on large lot graphs.**

Mitigation: trace queries are bounded by property and date range. The lot DAG is
shallow for dairy (typically 2-3 levels: raw material → base → flavored →
packed). Queries use indexed joins on source_batch_id and origin_lot_ids.

**Risk: recall misses lots.**

Mitigation: InitiateRecall runs forward trace automatically. Operator can add
lots manually. Recall stays in INVESTIGATING until the operator explicitly
moves it to ACTIVE, ensuring all branches have been followed.

**Risk: quarantined stock sold before recall completes.**

Mitigation: quarantine disposition immediately sets a flag on the stock_lot that
FEFO allocation respects. The allocation query filters out lots with
disposition = QUARANTINED.

**Risk: cross-service trace fails midway.**

Mitigation: the forward trace that reaches into Commerce (to find affected sales)
is a read-only query. If Commerce is unavailable, the manufacturing-side trace
still completes — affected sales are marked as "pending commerce lookup" and
retried.

## 6. Cold Chain Monitoring

### Where It Lives

`service-manufacturing/apps/default/` — cold chain is about storage conditions
at manufacturing properties and stock locations.

### 6.1 MonitoringPoint

A named location where environmental readings are taken.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `stock_location_id` | string | nullable — links to inventory location |
| `name` | string | e.g. "Cold Room A", "Dispatch Bay", "Incubation Room" |
| `point_type` | enum | COLD_STORAGE, AMBIENT_STORAGE, PRODUCTION_AREA, DISPATCH, VEHICLE |
| `reading_specs` | jsonb | expected readings with thresholds |
| `reading_interval_minutes` | int | expected frequency (e.g. 30 min) |
| `status` | enum | ACTIVE, INACTIVE |

Reading spec schema (same pattern as recipe steps and inspection templates):

```json
[
  {
    "reading_type": "temperature",
    "unit": "celsius",
    "min_value": 2,
    "max_value": 6
  },
  {
    "reading_type": "humidity",
    "unit": "percent",
    "min_value": 30,
    "max_value": 70
  }
]
```

### 6.2 EnvironmentReading

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `monitoring_point_id` | string | FK |
| `reading_type` | string | e.g. "temperature" |
| `value_decimal` | decimal | |
| `value_unit` | string | |
| `in_range` | bool | computed against monitoring point thresholds |
| `source` | enum | MANUAL, DEVICE, INTEGRATION |
| `device_id` | string | nullable — if from a sensor |
| `recorded_at` | timestamp | when the reading was taken |
| `recorded_by` | string | nullable — operator for manual readings |

### 6.3 EnvironmentAlarm

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `monitoring_point_id` | string | FK |
| `trigger_type` | enum | READING_OUT_OF_RANGE, READING_OVERDUE, SUSTAINED_BREACH |
| `severity` | enum | WARNING, CRITICAL |
| `reading_id` | string | nullable — the reading that triggered it |
| `message` | string | |
| `status` | enum | ACTIVE, ACKNOWLEDGED, RESOLVED |
| `acknowledged_by` | string | |
| `acknowledged_at` | timestamp | |
| `resolved_at` | timestamp | |

SUSTAINED_BREACH means a reading type has been out of range for more than a
configured duration (e.g. cold room above 8°C for 15+ minutes). Detection
compares the current reading against recent history for the same monitoring
point and reading type.

### 6.4 Device Ingestion

The RecordEnvironmentReading RPC accepts both manual and device readings:

- Device authenticates as a service account with `environment_record` permission
- Device identifies itself via `device_id` field
- Bulk endpoint RecordEnvironmentReadingBatch accepts multiple readings in one
  call (for devices that buffer offline readings)
- Readings are idempotent by `(monitoring_point_id, device_id, recorded_at)`

### 6.5 Cold Chain APIs

| RPC | Description |
|---|---|
| `MonitoringPointSave` | Create/update a monitoring point |
| `MonitoringPointGet` | Get monitoring point with current status |
| `MonitoringPointSearch` | List points for a property |
| `RecordEnvironmentReading` | Record a single reading |
| `RecordEnvironmentReadingBatch` | Record multiple readings (device bulk) |
| `ListEnvironmentReadings` | Query readings by point, time range |
| `ListEnvironmentAlarms` | List alarms by point, status |
| `AcknowledgeEnvironmentAlarm` | Acknowledge an alarm |
| `ResolveEnvironmentAlarm` | Resolve an alarm |
| `EnvironmentComplianceReport` | Compliance summary per point over date range |

### 6.6 Cold Chain Permissions

```
permissions:
  - environment_view
  - environment_record
  - environment_alarm_acknowledge
  - environment_manage
```

### 6.7 Cold Chain Integration Points

- Cold Chain → Notification: alarms trigger operator/supervisor notifications
- Cold Chain → Traceability: sustained breach on a stock location flags all lots
  stored there during the breach window — feeds into recall investigation
- Cold Chain → Inventory: CRITICAL unresolved alarm on a stock location can block
  dispatch from that location (configurable per monitoring point)

### 6.8 Cold Chain Robustness

**Risk: sensor floods system with readings.**

Mitigation: rate limiting per device_id. Readings closer together than
reading_interval_minutes / 2 are deduplicated. Bulk endpoint has a max batch
size (configurable, default 100).

**Risk: sensor goes offline and nobody notices.**

Mitigation: READING_OVERDUE alarm triggers when no reading arrives within
2 × reading_interval_minutes. This is checked by a periodic background job.

**Risk: brief temperature spike triggers false alarm.**

Mitigation: SUSTAINED_BREACH requires N consecutive out-of-range readings (not
just one). Single out-of-range readings create a WARNING; sustained breaches
escalate to CRITICAL.

## 7. Shelf Life & Expiry Label Management

### Where It Lives

`service-manufacturing/apps/default/` — shelf life rules are tied to recipes
and products; label data is generated at batch completion.

### 7.1 ShelfLifeRule

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `recipe_id` | string | nullable — if recipe-specific |
| `inventory_item_id` | string | nullable — if product-specific |
| `shelf_life_days` | int | e.g. 21 for plain yoghurt, 14 for flavored |
| `expiry_type` | enum | USE_BY, BEST_BEFORE |
| `storage_conditions` | string | e.g. "Store at 2-6°C" |
| `priority` | int | higher priority overrides lower |
| `status` | enum | ACTIVE, ARCHIVED |

Priority resolution order: recipe-specific > product-specific > property default.

### 7.2 LabelData

Generated at batch/packing completion, consumed by label printers.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK |
| `packing_execution_id` | string | FK |
| `product_variant_id` | string | FK |
| `batch_number` | string | |
| `production_date` | date | |
| `expiry_date` | date | computed: production_date + shelf_life_days |
| `expiry_type` | enum | USE_BY, BEST_BEFORE |
| `lot_number` | string | |
| `storage_conditions` | string | from shelf life rule |
| `property_name` | string | denormalized |
| `nutritional_data` | jsonb | nullable — per-product nutritional info |
| `allergen_declarations` | string[] | e.g. ["milk", "contains live cultures"] |
| `label_format` | string | nullable — template reference for printing |

### 7.3 Auto-Expiry Calculation

When CompleteBatch creates output stock lots, the system:

1. Resolves the applicable ShelfLifeRule by priority
2. Sets `lot.expiry_date = batch.completed_at.date + rule.shelf_life_days`
3. Sets `lot.expiry_type` from the rule
4. This expiry date drives FEFO allocation in inventory

If no ShelfLifeRule matches, the batch completion requires manual expiry date
entry.

### 7.4 Label Generation Flow

```
1. Batch completes → packing execution records actual counts
2. System resolves shelf life rule (recipe-specific first, then product, then
   property default)
3. LabelData generated automatically per packing execution with computed
   expiry_date
4. Label data available via API for label printing systems
5. Expiry date also set on the stock_lot created by the packing output
```

### 7.5 Shelf Life APIs

| RPC | Description |
|---|---|
| `ShelfLifeRuleSave` | Create/update a shelf life rule |
| `ShelfLifeRuleSearch` | List rules for a property |
| `GetLabelData` | Get label data for a packing execution |
| `ListLabelData` | List label data by batch or date range |
| `GenerateLabelData` | Force regenerate (e.g. after rule correction) |

## 8. Equipment & Cleaning (CIP)

### Where It Lives

`service-manufacturing/apps/default/` — equipment is a manufacturing concern.
Production planning needs equipment availability, and CIP schedules are driven
by batch changeovers.

### 8.1 Equipment

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `name` | string | e.g. "Pasteurizer #1", "Filler Line A" |
| `equipment_type` | enum | PASTEURIZER, INCUBATOR, MIXER, FILLER, TANK, COLD_ROOM, OTHER |
| `serial_number` | string | nullable |
| `manufacturer` | string | nullable |
| `commissioned_date` | date | nullable |
| `status` | enum | OPERATIONAL, MAINTENANCE, OUT_OF_SERVICE, DECOMMISSIONED |
| `capacity` | decimal | nullable — e.g. 500 (liters) |
| `capacity_unit` | string | nullable |
| `properties` | jsonb | extensible metadata |

### 8.2 CleaningSchedule

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `equipment_id` | string | FK |
| `schedule_type` | enum | BETWEEN_BATCHES, BETWEEN_FLAVORS, DAILY, WEEKLY, ON_DEMAND |
| `cleaning_method` | enum | CIP, COP, MANUAL, SANITIZE_ONLY |
| `expected_duration_minutes` | int | |
| `instructions` | string | operator-facing cleaning procedure |
| `requires_verification` | bool | must an operator confirm cleaning is complete? |
| `status` | enum | ACTIVE, ARCHIVED |

### 8.3 CleaningRecord

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `equipment_id` | string | FK |
| `schedule_id` | string | nullable — FK if from a schedule |
| `preceding_batch_id` | string | nullable — batch before cleaning |
| `following_batch_id` | string | nullable — batch after cleaning |
| `cleaned_by` | string | operator |
| `started_at` | timestamp | |
| `completed_at` | timestamp | |
| `status` | enum | IN_PROGRESS, COMPLETED, VERIFIED, FAILED |
| `verified_by` | string | nullable — if verification required |
| `verified_at` | timestamp | |
| `notes` | string | |
| `readings` | jsonb | nullable — e.g. rinse water pH, sanitizer concentration |

### 8.4 MaintenanceRecord

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `equipment_id` | string | FK |
| `maintenance_type` | enum | PREVENTIVE, CORRECTIVE, CALIBRATION, INSPECTION |
| `description` | string | what was done |
| `performed_by` | string | technician/operator |
| `performed_at` | timestamp | |
| `next_due_date` | date | nullable — for recurring maintenance |
| `cost` | Money | nullable |
| `parts_used` | string | nullable |
| `status` | enum | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED |

### 8.5 RecipeStep Equipment Extension

Add optional equipment reference to RecipeStep:

| Field | Type | Notes |
|---|---|---|
| `equipment_type` | enum | nullable — which equipment type this step needs |
| `equipment_id` | string | nullable — if pinned to specific equipment |

### 8.6 CIP Enforcement Flow

```
1. Batch completes (e.g. strawberry yoghurt)
2. System checks if next planned batch uses different flavor/product family
3. If yes → auto-creates a CleaningRecord (IN_PROGRESS) for affected equipment
4. Next batch StartBatch checks: is there an unverified cleaning record
   for required equipment?
   → If requires_verification and not VERIFIED → batch start blocked
   → Operator must complete and verify cleaning first
5. If same product family → no CIP required (configurable per schedule)
```

### 8.7 Equipment & Plan Validation

When a production plan is validated:

1. Each recipe step can optionally reference an equipment_type it requires
2. Validation checks that the property has at least one OPERATIONAL equipment
   of each required type
3. Equipment in MAINTENANCE status during the planned window generates a warning
4. Batch start can optionally lock specific equipment (prevents concurrent use)

This is advisory, not hard-blocking. Small properties often have one of each.

### 8.8 Equipment APIs

| RPC | Description |
|---|---|
| `EquipmentSave` | Create/update equipment |
| `EquipmentGet` | Get equipment with current status |
| `EquipmentSearch` | List equipment for a property |
| `CleaningScheduleSave` | Create/update cleaning schedule |
| `CleaningScheduleSearch` | List schedules for equipment |
| `StartCleaning` | Create a cleaning record |
| `CompleteCleaning` | Mark cleaning done |
| `VerifyCleaning` | Verify cleaning was adequate |
| `ListCleaningRecords` | Search cleaning history |
| `MaintenanceRecordSave` | Create/update maintenance record |
| `MaintenanceRecordSearch` | List maintenance history |
| `EquipmentAvailabilityCheck` | Check equipment readiness for a planned date |

### 8.9 Equipment Permissions

```
permissions:
  - equipment_view
  - equipment_manage
  - cleaning_perform
  - cleaning_verify
  - maintenance_manage
```

### 8.10 Equipment Robustness

**Risk: batch starts on dirty equipment.**

Mitigation: CIP enforcement checks are advisory by default. batch_override
permission allows proceeding, creating an audit entry.

**Risk: concurrent batches claim same equipment.**

Mitigation: optional equipment locking at batch start via row-level lock on
equipment status. Second batch start fails with a clear error identifying the
equipment and the conflicting batch.

**Risk: maintenance overdue and nobody notices.**

Mitigation: background job checks next_due_date against current date. Overdue
equipment triggers a notification alarm. Does not auto-block production but
surfaces in EquipmentAvailabilityCheck and plan validation warnings.

## 9. Waste & By-product Management

### Where It Lives

`service-manufacturing/apps/default/` — waste originates in production and
inventory.

### 9.1 WasteRecord

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `waste_type` | enum | PRODUCTION_LOSS, BY_PRODUCT, EXPIRED_STOCK, CUSTOMER_RETURN, QUALITY_REJECT, DISPOSAL |
| `source_type` | enum | BATCH, INVENTORY, INSPECTION, RECALL |
| `source_id` | string | FK → batch_id, lot_id, inspection_id, or recall_id |
| `inventory_item_id` | string | nullable — what material was wasted |
| `lot_id` | string | nullable — specific lot |
| `quantity` | decimal | |
| `unit` | string | |
| `disposition` | enum | PENDING, DISPOSED, RECYCLED, SOLD, DONATED, QUARANTINED |
| `disposition_method` | string | nullable — e.g. "effluent treatment", "animal feed" |
| `disposed_by` | string | nullable |
| `disposed_at` | timestamp | nullable |
| `estimated_cost` | Money | nullable — cost of the wasted material |
| `notes` | string | |

### 9.2 ByProductOutput

Tracks valuable by-products (e.g. whey from yoghurt straining).

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK — which batch produced this |
| `inventory_item_id` | string | FK — the by-product as an inventory item |
| `quantity` | decimal | |
| `unit` | string | |
| `lot_id` | string | nullable — if stocked for sale or use |
| `disposition` | enum | STOCKED, SOLD_EXTERNAL, DISPOSED |
| `notes` | string | |

### 9.3 Waste Sources

| Source | Trigger | waste_type |
|---|---|---|
| Batch completion | Spoilage quantity reported | PRODUCTION_LOSS |
| Batch completion | Whey or other by-product | BY_PRODUCT |
| Inventory expiry job | Lot passes expiry_date | EXPIRED_STOCK |
| Customer return | Return processed in commerce | CUSTOMER_RETURN |
| Receiving inspection | Goods rejected | QUALITY_REJECT |
| Recall | Lots destroyed | DISPOSAL |

### 9.4 Integration with Existing Spoilage

The existing batch completion already records spoilage and creates a SPOIL stock
movement. This design wraps that with a WasteRecord for disposition tracking,
cost attribution, and waste analytics.

After creating the SPOIL movement, batch completion also creates a WasteRecord
with source_type=BATCH.

### 9.5 Expired Stock Workflow

```
1. Background job scans stock_lots where expiry_date < today and status = ACTIVE
2. For each expired lot → creates WasteRecord with waste_type = EXPIRED_STOCK
3. Lot status → EXPIRED (blocks FEFO allocation)
4. WasteRecord disposition = PENDING
5. Operator reviews and sets disposition (DISPOSED, DONATED, etc.)
6. Disposition creates corresponding stock movement (WRITE_OFF)
```

### 9.6 Waste APIs

| RPC | Description |
|---|---|
| `CreateWasteRecord` | Record waste from any source |
| `GetWasteRecord` | Get waste record details |
| `ListWasteRecords` | Search/filter waste records |
| `UpdateWasteDisposition` | Set how waste was disposed |
| `RecordByProductOutput` | Record by-product from a batch |
| `WasteSummaryReport` | Aggregate waste by type, source, period |
| `ExpiredStockReport` | List expired/expiring stock needing disposition |

### 9.7 Waste Permissions

```
permissions:
  - waste_view
  - waste_record
  - waste_dispose
```

### 9.8 Waste Robustness

**Risk: waste records created but never dispositioned.**

Mitigation: background alert for WasteRecords in PENDING disposition longer than
a configurable threshold (default: 7 days).

**Risk: expired stock disposal not reflected in inventory.**

Mitigation: UpdateWasteDisposition for EXPIRED_STOCK waste creates the WRITE_OFF
stock movement atomically in the same transaction as the disposition update.

## 10. Pricing Management

### Where It Lives

`service-commerce/apps/sales/` — pricing is a business-layer capability within
the sales app. No separate app or proto.

### 10.1 PriceList

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `shop_id` | string | FK |
| `name` | string | e.g. "Retail", "Wholesale", "Distributor" |
| `currency` | string | |
| `priority` | int | higher wins when customer matches multiple lists |
| `valid_from` | timestamp | nullable — for time-bound pricing |
| `valid_until` | timestamp | nullable |
| `status` | enum | ACTIVE, DRAFT, EXPIRED |

### 10.2 PriceListEntry

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `price_list_id` | string | FK |
| `product_variant_id` | string | FK |
| `unit_price` | Money | the price in this list |
| `min_quantity` | int | nullable — volume break threshold |
| `max_quantity` | int | nullable |

Multiple entries per variant per list support volume breaks:

```
Strawberry 500ml in "Wholesale" list:
  qty 1-49   → KES 120
  qty 50-199 → KES 110
  qty 200+   → KES 100
```

### 10.3 CustomerPriceListAssignment

Explicitly links a customer to a price list. Without an assignment, the customer
gets the default catalog price.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `customer_id` | string | FK |
| `price_list_id` | string | FK |
| `assigned_by` | string | who assigned this list |
| `status` | enum | ACTIVE, INACTIVE |

A customer can be assigned to multiple price lists. When resolving prices, the
system picks the highest-priority list among the customer's active assignments.

### 10.4 CustomerPriceOverride

Negotiated price for a specific customer. Takes precedence over any price list.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `customer_id` | string | FK |
| `product_variant_id` | string | FK |
| `unit_price` | Money | |
| `valid_from` | timestamp | nullable |
| `valid_until` | timestamp | nullable |
| `approved_by` | string | who approved this override |
| `status` | enum | ACTIVE, EXPIRED |

### 10.5 DiscountRule

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `shop_id` | string | FK |
| `name` | string | e.g. "Early Payment 5%", "New Customer 10%" |
| `discount_type` | enum | PERCENTAGE, FIXED_AMOUNT |
| `value` | decimal | e.g. 5.0 for 5%, or 50 for KES 50 off |
| `applies_to` | enum | ORDER, LINE_ITEM |
| `conditions` | jsonb | nullable — rules for auto-application (see schema below) |
| `requires_approval` | bool | if true, needs manager approval |
| `max_discount_percent` | decimal | ceiling — prevents excessive discounts |
| `valid_from` | timestamp | nullable |
| `valid_until` | timestamp | nullable |
| `status` | enum | ACTIVE, INACTIVE |

Discount conditions schema:

```json
{
  "min_order_total": 10000,
  "customer_types": ["wholesale", "distributor"],
  "product_ids": ["prod_abc"],
  "min_line_quantity": 50,
  "payment_method": "cash"
}
```

All condition fields are optional. When multiple fields are present, all must
match (AND logic). An empty or null conditions object means the discount applies
to all qualifying sales.

### 10.6 Price Resolution Algorithm

When creating a sale, the system resolves the price for each line item:

```
1. Check CustomerPriceOverride for (customer_id, variant_id) — if active, use it
2. Check CustomerPriceListAssignments for the customer
   → Find ACTIVE assignments → load their PriceLists
   → Find entries matching variant_id
   → Among matching entries, pick the one matching the quantity range
   → If multiple lists match, use highest priority list
3. Fall back to ProductVariant.price (the base catalog price)
4. Apply any applicable DiscountRules (evaluate conditions against the sale)
5. If discount requires approval → sale created in PENDING_APPROVAL status
```

The resolved price and its source are snapshotted on the sale line so historical
sales always show what price was charged and why.

### 10.7 Sale Line Pricing Extension

Add to the existing sale line model:

| Field | Type | Notes |
|---|---|---|
| `price_source` | enum | CATALOG, PRICE_LIST, CUSTOMER_OVERRIDE |
| `price_list_id` | string | nullable — which list was used |
| `override_id` | string | nullable — which override was used |
| `discount_amount` | Money | nullable |
| `discount_rule_id` | string | nullable |
| `pre_discount_total` | Money | |

### 10.8 Pricing APIs

Added to SalesService (not a separate service):

| RPC | Description |
|---|---|
| `PriceListSave` | Create/update a price list |
| `PriceListGet` | Get price list with entries |
| `PriceListSearch` | List price lists |
| `PriceListEntryBatchSave` | Set entries for a price list (replace-all per variant) |
| `CustomerPriceListAssignmentSave` | Assign a customer to a price list |
| `CustomerPriceListAssignmentSearch` | List assignments for a customer |
| `CustomerPriceOverrideSave` | Set a customer-specific price |
| `CustomerPriceOverrideSearch` | List overrides for a customer |
| `DiscountRuleSave` | Create/update a discount rule |
| `DiscountRuleSearch` | List discount rules |
| `ResolvePrice` | Preview price resolution for customer + variant + quantity |

### 10.9 Pricing Permissions

```
permissions:
  - price_list_view
  - price_list_manage
  - customer_price_override
  - discount_manage
  - discount_approve
```

discount_approve is required to approve sales with discounts that have
requires_approval = true.

### 10.10 Pricing Robustness

**Risk: price list changes mid-order.**

Mitigation: price is snapshotted on the sale line at creation time. Price list
changes do not affect existing sales.

**Risk: overlapping volume breaks cause ambiguity.**

Mitigation: PriceListEntryBatchSave validates that quantity ranges do not
overlap within the same variant + price list.

**Risk: expired price lists still applied.**

Mitigation: price resolution filters by valid_from/valid_until and status =
ACTIVE. Background job transitions ACTIVE lists past valid_until to EXPIRED.

## 11. Costing & Margin Analysis

### Where It Lives

`service-manufacturing/apps/default/` — costing is computed from production
data (material usage, labor, overhead).

### 11.1 CostComponent

Configurable cost categories for a property.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `name` | string | e.g. "Direct Materials", "Labor", "Energy", "Packaging" |
| `cost_type` | enum | MATERIAL, LABOR, OVERHEAD, PACKAGING |
| `allocation_method` | enum | PER_BATCH, PER_UNIT, PER_HOUR, FIXED_MONTHLY |
| `default_rate` | Money | nullable — e.g. KES 500/hour for labor |
| `default_rate_unit` | string | nullable — "hour", "batch", "unit" |
| `status` | enum | ACTIVE, ARCHIVED |

### 11.2 BatchCostSnapshot

Computed cost breakdown for a completed batch.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `batch_id` | string | FK |
| `property_id` | string | FK |
| `computed_at` | timestamp | |
| `total_cost` | Money | sum of all components |
| `cost_per_unit` | Money | total_cost / output_quantity |
| `output_quantity` | decimal | from batch |
| `output_unit` | string | |

### 11.3 BatchCostLine

Individual cost line within a snapshot.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `snapshot_id` | string | FK |
| `cost_component_id` | string | FK |
| `description` | string | e.g. "Whole Milk — 80L @ KES 65/L" |
| `quantity` | decimal | nullable |
| `unit_cost` | Money | nullable |
| `total_cost` | Money | |
| `source_type` | enum | MATERIAL_USAGE, LABOR_HOURS, EQUIPMENT_TIME, OVERHEAD_ALLOCATION, MANUAL |
| `source_id` | string | nullable — FK to batch_material_usage, etc. |

### 11.4 Cost Computation Flow

```
1. Batch completes → triggers cost snapshot computation

2. MATERIAL lines:
   For each batch_material_usage:
   → Look up purchase price from the consumed lot's goods receipt line
   → If no receipt (ad-hoc stock-in), use supplier item price or manual cost
   → cost = actual_quantity × unit_purchase_price

3. PACKAGING lines:
   For each packing_execution:
   → Look up packaging material cost from procurement
   → cost = actual_count × packaging_unit_cost

4. LABOR lines:
   → batch duration (started_at → completed_at) × labor rate from CostComponent
   → Or operator-entered hours if configured

5. OVERHEAD lines:
   → Property-level monthly overhead ÷ batches in period (allocation)
   → Or fixed per-batch overhead from CostComponent

6. Sum all lines → total_cost
7. cost_per_unit = total_cost / batch.output_quantity
```

### 11.5 Margin Analysis

Margin is computed by joining manufacturing cost data with commerce sales data.
Since these are separate services, margin queries work via RPC.

**Product margin flow:**

```
1. Manufacturing: compute average cost_per_unit for a product over a date range
2. Call Commerce: get average selling price for the same product over same range
3. margin = selling_price - cost_per_unit
4. margin_percent = margin / selling_price × 100
```

**Batch cost variance:**

```
planned_cost = recipe BOM quantities × standard purchase prices
actual_cost  = batch cost snapshot total
variance     = actual - planned
variance_percent = variance / planned × 100
```

### 11.6 Costing APIs

| RPC | Description |
|---|---|
| `CostComponentSave` | Configure cost categories |
| `CostComponentSearch` | List cost components |
| `GetBatchCostSnapshot` | Get cost breakdown for a batch |
| `ListBatchCostSnapshots` | Search cost snapshots |
| `RecomputeBatchCost` | Force recompute (e.g. after price correction) |
| `ProductCostReport` | Average cost per product over date range |
| `ProductMarginReport` | Cost vs selling price margin analysis |
| `CostVarianceReport` | Planned vs actual cost comparison |

### 11.7 Costing Integration Points

- Costing → Procurement: material costs come from purchase order line prices
- Costing → Commerce: selling prices for margin analysis via RPC
- Costing → Batch: triggered automatically at batch completion

### 11.8 Costing Robustness

**Risk: purchase price unavailable for a consumed lot.**

Mitigation: cost computation uses a fallback chain: lot's goods receipt line
price → supplier item standard price → CostComponent default rate → manual
entry flag. BatchCostLine records which source was used.

**Risk: overhead allocation unfair to small batches.**

Mitigation: allocation_method is configurable. PER_BATCH spreads evenly.
PER_UNIT scales with output. Properties can configure the method that best
reflects their cost structure.

**Risk: margin report inaccurate due to cross-service data staleness.**

Mitigation: margin report includes the date ranges and computation timestamps
for both cost and revenue data. The report is a snapshot, not a live calculation.

## 12. Demand-Driven Planning

### Where It Lives

`service-manufacturing/apps/default/` — demand signals feed into the existing
production planning model.

### 12.1 DemandSignal

Aggregated sales data captured for planning purposes.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `product_variant_id` | string | FK |
| `period_start` | date | start of the aggregation window |
| `period_end` | date | |
| `period_type` | enum | DAILY, WEEKLY, MONTHLY |
| `quantity_sold` | decimal | units sold in this period |
| `quantity_returned` | decimal | units returned |
| `net_quantity` | decimal | sold - returned |
| `source` | enum | COMMERCE_SYNC, MANUAL_ENTRY |
| `captured_at` | timestamp | when this signal was recorded |

### 12.2 DemandForecast

Computed projection from demand signals.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `product_variant_id` | string | FK |
| `forecast_date` | date | the date being forecasted |
| `forecast_quantity` | decimal | projected demand |
| `forecast_method` | enum | ROLLING_AVERAGE, WEIGHTED_AVERAGE, SEASONAL_ADJUSTED, MANUAL |
| `confidence` | enum | HIGH, MEDIUM, LOW |
| `lookback_days` | int | how many days of history were used |
| `computed_at` | timestamp | |

### 12.3 ProductionSuggestion

Auto-generated recommendation for what to produce.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `suggested_date` | date | when to produce |
| `product_variant_id` | string | FK |
| `recipe_id` | string | FK — suggested recipe |
| `suggested_quantity` | decimal | how much to produce |
| `reasoning` | jsonb | breakdown of how suggestion was computed |
| `current_stock` | decimal | stock on hand at computation |
| `days_of_stock` | decimal | current_stock / daily_demand |
| `expiring_soon_quantity` | decimal | stock expiring within shelf_life / 3 |
| `status` | enum | PENDING, ACCEPTED, MODIFIED, DISMISSED |
| `accepted_plan_id` | string | nullable — plan created when accepted |

### 12.4 ForecastConfig

Per-property configuration for demand planning.

| Field | Type | Notes |
|---|---|---|
| `id` | string | BaseModel |
| `property_id` | string | FK |
| `lookback_days` | int | default 30 |
| `target_days_of_stock` | int | default 5 |
| `reorder_threshold_days` | int | default 3 — trigger suggestion below this |
| `forecast_method` | enum | ROLLING_AVERAGE, WEIGHTED_AVERAGE |
| `suggestion_frequency` | enum | DAILY, ON_DEMAND |
| `auto_suggest_enabled` | bool | whether background job creates suggestions |
| `status` | enum | ACTIVE, INACTIVE |

### 12.5 Suggestion Algorithm

```
1. For each active product variant linked to a property recipe:
   a. Compute rolling average daily demand from DemandSignals
      (default: 30-day lookback)
   b. Get current stock on hand (via inventory)
   c. Get stock expiring within shelf_life / 3
   d. effective_stock = current_stock - expiring_soon_quantity
   e. days_of_stock = effective_stock / daily_demand
   f. If days_of_stock < reorder_threshold_days:
      → suggested_quantity =
        (target_days_of_stock - days_of_stock) × daily_demand
      → Round up to nearest batch size from recipe
      → Create ProductionSuggestion

2. Suggestions are grouped by date and can be bulk-accepted into a
   ProductionPlan via the existing planning model
```

### 12.6 Demand Signal Capture

```
1. Manufacturing calls Commerce.SalesSummary for each product/period
2. Net quantities stored as DemandSignal records
3. Job runs daily (configurable), capturing the previous day's sales
4. Idempotent: same (product, period_start, period_end) updates rather than
   duplicates
```

Manual entry supports pre-launch estimates, special orders, and seasonal
adjustments.

### 12.7 Demand Planning APIs

| RPC | Description |
|---|---|
| `SyncDemandSignals` | Pull latest sales data from commerce |
| `ListDemandSignals` | View demand history for a product |
| `GetDemandForecast` | Get current forecast for a product |
| `ListDemandForecasts` | Forecasts across products |
| `GenerateProductionSuggestions` | Compute suggestions for a property |
| `ListProductionSuggestions` | View pending suggestions |
| `AcceptProductionSuggestion` | Accept → creates a ProductionPlan |
| `DismissProductionSuggestion` | Dismiss with reason |
| `ForecastConfigSave` | Configure forecast parameters |
| `ForecastConfigGet` | Get current config |
| `DemandOverviewReport` | Dashboard: demand vs production vs stock |

### 12.8 Demand Planning Integration Points

- Demand → Commerce: periodic sync pulls sales summaries
- Demand → Inventory: stock on hand and expiry data for suggestion computation
- Demand → Production Planning: accepted suggestions create production plans
- Demand → Shelf Life: expiring stock factored into effective stock calculation

### 12.9 Demand Planning Robustness

**Risk: stale demand signals.**

Mitigation: each signal records captured_at. Suggestions always state the
freshness of their input data. Stale signals (older than 2 × lookback_days)
are flagged.

**Risk: suggestions pile up unreviewed.**

Mitigation: older suggestions auto-expire after configurable days (default: 3).
New computation replaces expired suggestions.

**Risk: seasonal spikes missed by rolling average.**

Mitigation: WEIGHTED_AVERAGE gives more weight to recent days. SEASONAL_ADJUSTED
(future) uses same-period-last-year data when available. Manual entry allows
operators to inject known seasonal adjustments.

**Risk: demand sync fails.**

Mitigation: sync job is idempotent and retryable. Manufacturing can operate with
stale signals. Suggestions surface data freshness so operators can judge
reliability.

## 13. Cross-Cutting Concerns

### 13.1 Reading Spec Pattern

Three domain areas use the same reading spec pattern:

- Recipe steps (existing manufacturing spec)
- Inspection templates (Section 4)
- Monitoring points (Section 6)

The JSON schema is identical across all three:

```json
{
  "reading_type": "string",
  "unit": "string",
  "min_value": "decimal",
  "max_value": "decimal",
  "is_required": "bool"
}
```

This is a shared data pattern, not shared code. Each domain owns its own
reading spec storage and evaluation logic. The consistency makes it easier for
operators to understand thresholds across production, receiving, and storage.

### 13.2 Alarm Pattern

Three domain areas use alarms:

- Batch alarms (existing manufacturing spec)
- Environment alarms (Section 6)
- Equipment/maintenance alarms (Section 8, via notification)

Batch alarms and environment alarms are first-class entities with status
lifecycle (ACTIVE → ACKNOWLEDGED → RESOLVED). Equipment alerts are lighter —
they use the notification service directly without a persistent alarm entity.

### 13.3 Background Jobs

Several features require periodic background processing:

| Job | Frequency | Owner |
|---|---|---|
| Expired stock scanner | Daily | Manufacturing (inventory) |
| Demand signal sync | Daily | Manufacturing (demand) |
| Production suggestion generator | Daily or on-demand | Manufacturing (demand) |
| Environment reading overdue check | Every N minutes | Manufacturing (cold chain) |
| Maintenance due date check | Daily | Manufacturing (equipment) |
| PO overdue delivery check | Daily | Procurement |
| Price list expiry transition | Daily | Sales (pricing) |
| Waste disposition reminder | Daily | Manufacturing (waste) |

All background jobs use Frame's workerpool for bounded local concurrency. Jobs
are idempotent and safe to run concurrently (they operate on disjoint data or
use row-level locking).

### 13.4 New Database Tables

**Procurement (service-commerce):**

- `suppliers`
- `supplier_items`
- `purchase_orders`
- `purchase_order_lines`
- `goods_receipts`
- `goods_receipt_lines`

**Manufacturing extensions (service-manufacturing):**

Quality:
- `inspection_templates`
- `receiving_inspections`
- `inspection_readings`

Traceability:
- `recalls`
- `recall_lots`
- (stock_lots extended with provenance fields)

Cold Chain:
- `monitoring_points`
- `environment_readings`
- `environment_alarms`

Shelf Life:
- `shelf_life_rules`
- `label_data`

Equipment:
- `equipment`
- `cleaning_schedules`
- `cleaning_records`
- `maintenance_records`

Waste:
- `waste_records`
- `by_product_outputs`

Costing:
- `cost_components`
- `batch_cost_snapshots`
- `batch_cost_lines`

Demand:
- `demand_signals`
- `demand_forecasts`
- `production_suggestions`
- `forecast_configs`

**Sales extensions (service-commerce):**

- `price_lists`
- `price_list_entries`
- `customer_price_list_assignments`
- `customer_price_overrides`
- `discount_rules`

### 13.5 Indexing Priorities

Procurement:
- suppliers by status, supplier_type
- purchase_orders by property_id, supplier_id, status, expected_delivery_date
- goods_receipts by purchase_order_id, property_id

Quality:
- inspection_templates by property_id, inventory_item_id
- receiving_inspections by property_id, status, supplier_id
- inspection_readings by inspection_id

Cold Chain:
- monitoring_points by property_id, status
- environment_readings by monitoring_point_id, recorded_at
- environment_alarms by monitoring_point_id, status

Traceability:
- stock_lots by supplier_id, source_batch_id
- recalls by property_id, status
- recall_lots by recall_id, lot_id

Equipment:
- equipment by property_id, equipment_type, status
- cleaning_records by equipment_id, status
- maintenance_records by equipment_id, next_due_date

Waste:
- waste_records by property_id, waste_type, disposition, source_type
- by_product_outputs by batch_id

Costing:
- batch_cost_snapshots by batch_id, property_id
- batch_cost_lines by snapshot_id

Demand:
- demand_signals by property_id, product_variant_id, period_start
- production_suggestions by property_id, status, suggested_date

Pricing:
- price_lists by shop_id, status
- price_list_entries by price_list_id, product_variant_id
- customer_price_list_assignments by customer_id, price_list_id, status
- customer_price_overrides by customer_id, product_variant_id, status
- discount_rules by shop_id, status

## 14. Observability

### 14.1 Procurement Metrics

| Metric | Type |
|---|---|
| `purchase_order_created_total` | counter |
| `purchase_order_submitted_total` | counter |
| `goods_receipt_created_total` | counter |
| `goods_receipt_rejected_total` | counter |
| `po_delivery_overdue_total` | counter |
| `suggested_po_total` | counter |

### 14.2 Quality Metrics

| Metric | Type |
|---|---|
| `inspection_completed_total` | counter |
| `inspection_passed_total` | counter |
| `inspection_failed_total` | counter |
| `inspection_overridden_total` | counter |
| `inspection_reading_out_of_range_total` | counter |

### 14.3 Cold Chain Metrics

| Metric | Type |
|---|---|
| `environment_reading_total` | counter |
| `environment_reading_out_of_range_total` | counter |
| `environment_alarm_created_total` | counter |
| `environment_alarm_acknowledgement_latency_seconds` | histogram |
| `reading_overdue_total` | counter |

### 14.4 Equipment Metrics

| Metric | Type |
|---|---|
| `cleaning_completed_total` | counter |
| `cleaning_verification_total` | counter |
| `maintenance_completed_total` | counter |
| `maintenance_overdue_total` | counter |
| `equipment_downtime_minutes` | histogram |

### 14.5 Waste Metrics

| Metric | Type |
|---|---|
| `waste_recorded_total` | counter (by waste_type) |
| `waste_cost_total` | counter |
| `expired_stock_total` | counter |
| `waste_pending_disposition_total` | gauge |

### 14.6 Costing Metrics

| Metric | Type |
|---|---|
| `batch_cost_computed_total` | counter |
| `batch_cost_variance_percent` | histogram |
| `cost_computation_fallback_total` | counter (tracks missing price data) |

### 14.7 Demand Metrics

| Metric | Type |
|---|---|
| `demand_signal_synced_total` | counter |
| `demand_sync_error_total` | counter |
| `production_suggestion_generated_total` | counter |
| `production_suggestion_accepted_total` | counter |
| `production_suggestion_dismissed_total` | counter |

### 14.8 Pricing Metrics

| Metric | Type |
|---|---|
| `price_resolution_total` | counter (by price_source) |
| `discount_applied_total` | counter |
| `discount_approval_required_total` | counter |

## 15. Structured Log Events

Critical actions that must appear in structured logs:

- Supplier created/suspended (who, reason)
- Purchase order submitted (who, supplier, total)
- Goods receipt created (who, PO, quantities)
- Inspection completed (result, readings summary)
- Inspection overridden (who, reason, which readings failed)
- Recall initiated (who, trigger lot, severity)
- Recall lot disposition changed (who, from/to)
- Environment alarm created (point, trigger, severity)
- Environment alarm acknowledged (who, how long open)
- Cleaning verified (who, equipment, preceding batch)
- Batch started without CIP verification (override, who)
- Waste disposition set (who, method, quantity)
- Cost computation fallback used (batch, which material, fallback source)
- Production suggestion accepted (who, suggested vs actual quantity)
- Price override created (who, customer, product, price)
- Discount requiring approval applied (who, rule, amount)

## 16. Mandatory Standards

All code across both repositories must comply with the golang-patterns skill:

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
- All mutating RPCs accept an idempotency_key
- All background jobs use Frame workerpool
- All cross-service calls use typed Connect clients from pkg/
