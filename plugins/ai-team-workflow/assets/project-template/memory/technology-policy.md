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

## Upgrade Architecture When

- Multi-user data isolation is required.
- Data cannot be lost or must sync across devices.
- Permissions, payments, audit logs, external integrations, or production traffic are in scope.
- Performance requirements exceed simple local/manual checks.

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
