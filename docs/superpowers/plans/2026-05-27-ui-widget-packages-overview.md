# Service UI Widget Packages — Plan Decomposition Overview

> **Spec:** `docs/superpowers/specs/2026-05-27-service-ui-widget-packages-design.md`

## Prerequisites

Before any widget package can be built:

### 1. Regenerate Commerce Dart SDK

The commerce proto has been updated with pricing RPCs but the Dart SDK
(`sdk/dart/commerce/`) hasn't been regenerated. Run:

```bash
cd service-commerce && make proto-generate-dart
```

### 2. Generate Procurement Dart SDK

The procurement proto exists but has no Dart SDK. Create:
- `service-commerce/proto/buf.gen.dart.procurement.yaml`
- `service-commerce/sdk/dart/procurement/`

### 3. Generate Manufacturing Dart SDK

The manufacturing proto exists but has no Dart SDK. Create:
- `service-manufacturing/proto/buf.gen.dart.manufacturing.yaml`
- `service-manufacturing/sdk/dart/manufacturing/`

## Plan Inventory

16 plans, one per package, grouped by phase.

### Phase A — Leaf Packages (no cross-package UI deps)

| Plan | Package | Repo | SDK Needed | Estimated Files |
|---|---|---|---|---|
| A1 | `ui_catalog` | service-commerce | api_commerce (exists) | ~18 |
| A2 | `ui_inventory` | service-manufacturing | api_manufacturing (generate) | ~20 |
| A3 | `ui_equipment` | service-manufacturing | api_manufacturing | ~14 |
| A4 | `ui_coldchain` | service-manufacturing | api_manufacturing | ~14 |
| A5 | `ui_costing` | service-manufacturing | api_manufacturing | ~14 |

### Phase B — Tier 2 (depends on Phase A + ui_profile)

| Plan | Package | Repo | Depends On | Estimated Files |
|---|---|---|---|---|
| B1 | `ui_customers` | service-commerce | ui_profile, api_commerce | ~16 |
| B2 | `ui_recipes` | service-manufacturing | ui_inventory, api_manufacturing | ~18 |
| B3 | `ui_quality` | service-manufacturing | ui_inventory, api_manufacturing | ~14 |
| B4 | `ui_waste` | service-manufacturing | ui_inventory, api_manufacturing | ~12 |
| B5 | `ui_demand` | service-manufacturing | ui_inventory, api_manufacturing | ~16 |
| B6 | `ui_traceability` | service-manufacturing | ui_inventory, api_manufacturing | ~14 |

### Phase C — Tier 3 (depends on Phase B)

| Plan | Package | Repo | Depends On | Estimated Files |
|---|---|---|---|---|
| C1 | `ui_orders` | service-commerce | ui_catalog, ui_customers | ~18 |
| C2 | `ui_pricing` | service-commerce | ui_catalog, ui_customers | ~16 |
| C3 | `ui_procurement` | service-commerce | ui_inventory, ui_profile | ~16 |
| C4 | `ui_production` | service-manufacturing | ui_recipes, ui_inventory | ~20 |
| C5 | `ui_shelflife` | service-manufacturing | ui_recipes | ~10 |

## Implementation Strategy

Each plan follows the same task structure:

1. **Package scaffold** — pubspec.yaml, barrel export, directory structure
2. **Transport provider** — service client wiring
3. **Providers** — Riverpod state management
4. **Widgets** — reusable composable widgets (cards, badges, pickers)
5. **Screens** — full-page flows and wizards
6. **Route module** — GoRouter integration
7. **Tests** — widget tests for key components

Plan A1 (ui_catalog) is the reference implementation. All subsequent plans
follow the identical pattern with domain-specific content.

## Parallel Execution

Within each phase, all plans can be executed in parallel since they have no
dependencies on each other. Across phases, Phase A must complete before Phase
B starts, and Phase B before Phase C.
