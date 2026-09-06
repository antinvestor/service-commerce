# Backend Plans

This directory contains the implementation-grade backend plans for the
commerce and operations platform described in this repository.

## Documents

- [Backend Architecture](./backend-architecture.md)
  Core system design, domain ownership, application boundaries, data model,
  execution flows, scaling model, and platform integrations.
- [Implementation Plan](./implementation-plan.md)
  Delivery phases, repository/app structure, proto strategy, testing strategy,
  rollout approach, and operational milestones.

## Current state versus these plans

These documents describe the target topology. As of September 2026 the
repository actually contains:

- `apps/default` — the commerce service (shops, catalog, carts, orders,
  fulfilment, pricing) exposed as one `CommerceService`.
- `apps/procurement` — the procurement service (suppliers, purchase orders,
  goods receipts).
- `proto/`, `opl/`, `sdk/dart/`, `ui/`, and `web/` — contracts, Keto
  namespaces, generated Dart SDKs, Flutter widget packages, and the Hugo
  storefront module.

The catalog/customers/sales split and the separate operations repository
have not been carried out. Tenancy is settled as: one seller context per
partition, buyers are partition members, and staff roles are provisioned by
the identity service rather than by commerce RPCs.

## Scope

These plans assume:

- All Go backends must follow the `golang-patterns` skill conventions.
- Domain applications must remain separate applications that can be built,
  run, and tested independently.
- Sales remains under the commerce domain.
- Inventory and production remain under a separate operations domain.

