---
title: Technology Policy
tags:
  - ai-team/memory
  - technology
status: active
---

# Technology Policy

Keep the stack proportional to product scale. Prefer boring, maintainable choices.

## Scale Defaults

- S / MVP: one app, minimal dependencies, simple persistence, fast delivery.
- M / real product: auth, durable database, basic tests, deployment docs, clear ownership boundaries.
- L / high-risk product: explicit architecture plan, observability, load testing, security review, rollout/rollback plan.

## Avoid By Default

- Microservices, queues, Redis, Kubernetes, event sourcing, complex state libraries, premature service/repository layers.
- New dependencies without a clear reason in the task card.
- Abstracting before two real call sites or a clear project pattern exists.

## Human Lead Approval

- Confirm every major stack choice before scaffolding or implementation when the project is new or the choice changes cost, scale, deployment, data ownership, or maintenance.
- State the expected user scale and capacity assumption for the proposed stack.
- Explain why the stack is sufficient and why heavier or lighter alternatives are not selected.
- Do not add paid external services, databases, auth providers, queues, caches, object storage, or deployment platforms without approval.

## Upgrade Architecture When

- Multi-user data isolation is required.
- Data cannot be lost or must sync across devices.
- Permissions, payments, audit logs, external integrations, or production traffic are in scope.
- Performance requirements exceed simple local/manual checks.

## Backend Architecture Defaults

- Use a modular monolith before microservices for most MVP and real-product work.
- Keep route/controller, service/business, data access, validation schema, and error handling boundaries clear when backend business logic is non-trivial.
- Use design patterns only when they remove real duplication or clarify known variation:
  - strategy for interchangeable business rules
  - adapter for external services or channels
  - factory for complex object creation
  - template method for repeated workflows with controlled variation
- Do not introduce architecture theater for tiny prototypes, but do not put auth, permissions, payments, or durable business rules into unstructured handlers.

## Frontend-First Product Rule

- For user-facing products, design the frontend flow before backend API design.
- Backend APIs should trace to a visible interaction, integration, scheduled job, or operational need.
- Prioritize a polished, usable first screen and complete loading, empty, error, and success states.

## Code Quality Defaults

- Small modules with clear names.
- Existing framework patterns over custom architecture.
- Explicit error, loading, and empty states for user-facing flows.
- Verification command or documented waiver on every task.

## GitHub Defaults

- Use one task branch per implementation task when GitHub is enabled.
- Prefer PR + CI as the production merge gate.
- Do not merge code tasks without recorded verification and review result.
- GitHub Issues/Projects are optional until collaboration or tracking complexity requires them.
