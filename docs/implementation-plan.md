# Implementation Plan

## 1. Delivery Objectives

This plan turns the architecture into a backend program that can be delivered
incrementally without violating domain ownership or the mandatory Go/Frame
patterns.

## 2. Repository and App Structure

### 2.1 `service-commerce`

Target structure:

```text
service-commerce/
├── apps/
│   ├── catalog/
│   ├── customers/
│   └── sales/
├── proto/
│   ├── catalog/v1/
│   ├── customers/v1/
│   └── sales/v1/
├── opl/
│   ├── catalog/
│   ├── customers/
│   └── sales/
└── pkg/
    ├── commerceclient/
    ├── profileclient/
    ├── identityclient/
    ├── paymentclient/
    └── shared/
```

### 2.2 `service-operations`

Target structure:

```text
service-operations/
├── apps/
│   ├── inventory/
│   └── production/
├── proto/
│   ├── inventory/v1/
│   └── production/v1/
├── opl/
│   ├── inventory/
│   └── production/
└── pkg/
    ├── inventoryclient/
    ├── notificationclient/
    └── shared/
```

Each app is:

- built as its own binary
- run independently
- tested independently
- deployed independently when required

## 3. Standard Per-App Layout

Every application uses the same Frame layout:

```text
apps/<app-name>/
├── cmd/main.go
├── config/config.go
├── service/
│   ├── handlers/
│   ├── business/
│   ├── repository/
│   ├── models/
│   └── events/
├── migrations/
└── tests/
```

No app should contain business logic in handlers or raw database access in
business code.

## 4. Proto Strategy

Split API ownership by application instead of building a single oversized proto.

Commerce:

- `proto/catalog/v1/catalog.proto`
- `proto/customers/v1/customers.proto`
- `proto/sales/v1/sales.proto`

Operations:

- `proto/inventory/v1/inventory.proto`
- `proto/production/v1/production.proto`

Rules:

- every service declares `service_permissions`
- every RPC declares `method_permissions`
- all OPL is generated from proto
- all OpenAPI is generated from proto

## 5. Client and Integration Strategy

### 5.1 Internal Clients

Typed Connect clients must live in `pkg/` and be reused by business layers.

Examples:

- sales -> inventory client
- customers -> profile client
- sales -> payment client
- customers -> identity client
- inventory -> notification client

### 5.2 Integration Rules

- critical cross-domain writes use synchronous Connect RPC
- non-critical notifications and exports use Frame queue
- fast local projection refresh uses Frame events

## 6. Database Strategy

### 6.1 Ownership

Each repository owns its own database schema and migrations.

- `service-commerce`: commercial schema
- `service-operations`: operational schema

### 6.2 Migration Rules

- one migration directory per application or one shared repository migration
  root with ownership clearly labeled
- backward-compatible migrations first
- destructive migrations only after all readers/writers have been upgraded

### 6.3 Indexing Priorities

Commerce:

- sales by `customer_id`, `salesperson_member_id`, `created_at`
- receipts by `customer_id`, `created_at`
- customer locations by `customer_id`, `state`
- balances by `customer_id`

Operations:

- stock balances by `location_id`, `item_id`, `lot_id`
- stock movements by `item_id`, `location_id`, `created_at`
- lots by `item_id`, `expiry_date`, `location_id`
- batches by `product_item_id`, `production_date`, `status`

## 7. Application Build Order

### Phase 1: Foundation

- create `service-operations`
- split `service-commerce` into catalog, customers, and sales applications
- define protos and permissions
- wire Frame service bootstraps
- create shared client packages

Exit criteria:

- every app builds
- every app starts
- every app has auth, authz, datastore, and health wiring

### Phase 2: Inventory Core

- inventory items
- stock locations
- stock movements
- stock balances
- stock-in
- adjustments
- transfers
- reservation APIs

Exit criteria:

- deterministic stock mutation flow
- stock balance projection repair command exists
- integration tests cover concurrency-sensitive reservations

### Phase 3: Production Core

- production plans and plan lines
- production batch lifecycle
- process templates and ordered steps
- process event capture
- process readings capture
- operator alarms and acknowledgements
- material requirement forecast generation
- batch input and output recording
- spoilage
- expiry handling
- costing snapshot generation

Exit criteria:

- production can be planned before execution
- required raw materials can be forecast from planned output
- process events and readings are captured with idempotent writes
- alarms can be created and acknowledged
- batch completion transaction is atomic
- inventory reflects consumption and outputs correctly
- yield and spoilage reports are available

### Phase 4: Customer and Location Core

- customer commercial account
- customer locations
- assignment to salesperson
- notes
- credit policy

Exit criteria:

- one customer can have many locations
- sales can target a specific customer location
- search supports customer and location filters

### Phase 5: Sales and Receipts Core

- create sale
- return sale
- local receipts
- receipt allocations
- customer balance projection
- stock-backed selling integration with inventory

Exit criteria:

- no oversell under concurrent sale creation
- customer balances reconcile from sale and receipt data
- local receipt flow works with and without external payment rail

### Phase 6: Reporting and Alerts

- low stock
- expiry report
- planned material shortage report
- production process alarm report
- daily sales summary
- customer balances
- salesperson summary
- notifications for expiry, low stock, and production alarms

Exit criteria:

- reports return from owned data with acceptable latency
- alerting is asynchronous and retryable

## 8. Testing Strategy

Every app gets its own integration test suite.

### 8.1 Required Test Layers

- handler tests
- business tests
- repository tests
- integration tests with real PostgreSQL
- integration tests with `mem://localhost` queues

### 8.2 Critical Scenario Tests

Inventory:

- stock-in
- adjustment
- transfer
- reservation
- reservation release
- FEFO allocation

Production:

- create plan and compute material forecast
- fail plan readiness when critical inputs are insufficient
- start batch from plan
- capture process events in order
- capture out-of-range temperature reading and create alarm
- acknowledge alarm with audit trail
- complete batch with sufficient inputs
- fail batch when inputs missing
- spoilage handling
- cost snapshot generation

Customers:

- create customer
- add multiple customer locations
- assign default billing and delivery locations

Sales:

- create sale against customer location
- create sale without oversell under concurrency
- return sale
- partial receipt allocation
- receipt reversal

### 8.3 Cross-App Contract Tests

- sales -> inventory stock reservation flow
- sales -> payment receipt linkage flow
- customers -> profile address linkage flow

## 9. Deployment Profiles

### 9.1 Small Profile

Deploy:

- catalog
- customers
- sales
- inventory
- production

Shared infrastructure:

- one PostgreSQL cluster
- one NATS deployment
- optional single Valkey

### 9.2 Growth Profile

- autoscale sales independently
- autoscale inventory independently
- add read replicas for report traffic

### 9.3 Enterprise Profile

- independent release cadence per app
- dedicated reconciliation workers
- dedicated export/report workers
- regional deployment if needed

The code structure remains unchanged across profiles.

## 10. Operational Guardrails

- no direct infrastructure clients outside Frame
- no shared table writes across repositories
- no unbounded goroutines
- no manual permission constants outside proto
- no reporting-only shortcuts that bypass owning services
- no hidden business logic in SQL triggers

## 11. Backward Compatibility Rules

- additive proto changes first
- never repurpose fields
- deprecate before removal
- keep idempotency behavior stable
- preserve event names once externalized

## 12. Recommended Immediate Next Steps

1. Split the current commerce API plan into `catalog`, `customers`, and `sales` proto services.
2. Scaffold the new `service-operations` repository with `inventory` and `production` apps.
3. Write the stock movement, production planning, and sale creation transaction specs before implementation starts.
4. Define the `customer_locations` schema and the location-aware sales RPCs early.
5. Define the production process template, readings, and alarm model before coding batch execution.
6. Add app-level integration test scaffolds before building business logic.
