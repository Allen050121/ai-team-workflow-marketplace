---
title: Production Mode
tags:
  - ai-team/memory
  - production
status: active
---

# Production Mode

Use production mode when the work affects real users, durable data, authentication, payments, external services, deployment, or public release.

## Modes

- Prototype: local experiment, disposable data, no real users, no deployment gate.
- MVP: usable product slice, simple architecture, basic verification, optional deployment.
- Production: real users or durable data, CI/review/release gates, rollback path, security checks.

## Production Mode Triggers

Switch to Production when any of these are true:

- Login, permissions, user-owned data, tenant isolation, or payments are in scope.
- Data must survive browser/device changes or cannot be safely lost.
- A deployment, public URL, package publish, or external service is involved.
- The user says production,上线,部署,真实用户,客户,商业化, or长期维护.
- A failure could leak secrets, corrupt data, charge money, or block real users.

## Required In Production

- Task card with file boundaries, acceptance criteria, and verification command.
- Review Gate before integration.
- Security Gate for auth, user data, secrets, dependencies, deployment, or external services.
- Release Gate before deployment, publishing, or production-facing external action.
- Run evidence in `.ai-team/state/runs.json`.
- Human Lead approval for approval-required commands and production actions.

## Avoid In Production

- In-memory or local-only persistence for user data unless explicitly accepted.
- Skipping tests, lint, build, review, or CI because the change looks small.
- Hidden real secrets in code, logs, screenshots, task cards, or run evidence.
- Broad refactors mixed into feature tasks.
