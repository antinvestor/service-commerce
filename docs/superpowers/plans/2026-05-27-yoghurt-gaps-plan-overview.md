# Yoghurt Business Gaps — Plan Decomposition Overview

> **Spec:** `docs/superpowers/specs/2026-05-27-yoghurt-business-gaps-design.md`

## Plan Inventory

10 independent plans, ordered by dependency. Plans in the same phase have no
dependencies on each other and can be implemented in parallel.

### Phase 1 — No Dependencies

| Plan | Name | Repo | Location | Entities |
|---|---|---|---|---|
| 1 | Procurement & Supplier Management | service-commerce | apps/procurement/ (NEW) | Supplier, SupplierItem, PurchaseOrder, PurchaseOrderLine, GoodsReceipt, GoodsReceiptLine |
| 2 | Equipment & CIP | service-manufacturing | apps/default/ | Equipment, CleaningSchedule, CleaningRecord, MaintenanceRecord |
| 3 | Cold Chain Monitoring | service-manufacturing | apps/default/ | MonitoringPoint, EnvironmentReading, EnvironmentAlarm |
| 4 | Shelf Life & Labels | service-manufacturing | apps/default/ | ShelfLifeRule, LabelData |
| 5 | Pricing Management | service-commerce | apps/default/ (sales) | PriceList, PriceListEntry, CustomerPriceListAssignment, CustomerPriceOverride, DiscountRule |

### Phase 2 — Depends on Phase 1

| Plan | Name | Repo | Depends On | Entities |
|---|---|---|---|---|
| 6 | Inbound Quality Control | service-manufacturing | Plan 1 (GoodsReceipt) | InspectionTemplate, ReceivingInspection, InspectionReading |
| 7 | Waste & By-product Management | service-manufacturing | None (soft dep on batch) | WasteRecord, ByProductOutput |
| 8 | Costing & Margin Analysis | service-manufacturing | Plan 1 (purchase prices) | CostComponent, BatchCostSnapshot, BatchCostLine |

### Phase 3 — Depends on Phase 2

| Plan | Name | Repo | Depends On | Entities |
|---|---|---|---|---|
| 9 | Traceability & Recall | service-manufacturing | Plans 1, 6 (lot provenance) | Recall, RecallLot + StockLot extensions |
| 10 | Demand-Driven Planning | service-manufacturing | Commerce integration | DemandSignal, DemandForecast, ProductionSuggestion, ForecastConfig |

## Implementation Order

Recommended order within each phase:

**Phase 1:** Plan 1 (Procurement) first — it's the most critical gap and
foundation for Plans 6, 8, 9. Plans 2-5 can proceed in parallel.

**Phase 2:** Plan 6 (Quality Control) first — completes the procurement →
inspection → stock-in pipeline. Plans 7-8 can proceed in parallel.

**Phase 3:** Plan 9 (Traceability) then Plan 10 (Demand). Plan 10 is the
least urgent and requires the most cross-service integration.

## Estimated Scope Per Plan

Each plan follows the same structure: proto → models → repositories →
business logic → handlers → authz → config → tests. Estimated 5-8 tasks per
plan, 10-30 steps per task.
