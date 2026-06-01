---
title: Command Policy
tags:
  - ai-team/policy
  - command-safety
status: active
---

# Command Policy

Use this policy before running commands during execution, review, integration, or release work.

## Safe By Default

These commands are normally allowed without extra approval when they stay inside the current project:

- Read-only inspection: `Get-Content`, `Get-ChildItem`, `git status`, `git diff`, `git log`.
- Project checks: build, lint, typecheck, tests, and local smoke checks.
- Non-mutating diagnostics for dependency, environment, or framework versions.

## Requires Human Lead Approval

Pause and ask before commands that can change cost, external state, production state, or broad project structure:

- Installing, removing, or upgrading dependencies.
- Database migrations, seed scripts, or destructive data operations.
- Editing secrets, environment variables, credentials, cookies, or production config.
- `git push`, release tagging, deployment, publishing packages, or calling external production services.
- Deleting, moving, or bulk rewriting files, especially outside task boundaries.
- Commands that contact paid services or create cloud resources.

## Forbidden

Do not run or recommend these actions:

- Commit real secrets, private keys, tokens, or customer data.
- Bypass failed tests, CI, security checks, or review gates to merge.
- Modify production data without explicit approval and rollback plan.
- Run broad destructive commands against computed paths that have not been resolved and checked.
- Hide unrelated changes inside a task branch.

## Recording

- Executor records command results in the task card handoff and `.ai-team/state/runs.json`.
- Reviewer checks whether approval-required commands had explicit approval.
- Integration Gate blocks release when command policy evidence is missing for risky actions.
