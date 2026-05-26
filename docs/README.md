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

## Scope

These plans assume:

- All Go backends must follow the `golang-patterns` skill conventions.
- Domain applications must remain separate applications that can be built,
  run, and tested independently.
- Sales remains under the commerce domain.
- Inventory and production remain under a separate operations domain.

