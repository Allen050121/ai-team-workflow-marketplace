---
title: Integration Gate Checklist
tags:
  - ai-team/checklist
  - integration
status: active
---

# Integration Gate Checklist

Use before merging task branches into the main integration branch.

- [ ] All task-level review gates passed.
- [ ] Task branches were merged in the planned dependency order.
- [ ] Combined changed file list has no unexpected collisions.
- [ ] Build, test, lint, typecheck, or documented project checks passed.
- [ ] GitHub CI is passing when GitHub is used, or waiver is documented.
- [ ] Security Gate passed for auth, user data, secrets, dependencies, deployment, or external services.
- [ ] Command Policy was followed for dependency, data, git push, deployment, and external-service actions.
- [ ] Command risk classifications and Human Lead approvals are recorded for approval-required actions.
- [ ] Release Gate passed when deployment, release tagging, publishing, or production-facing actions are involved.
- [ ] Manual smoke test was run when user-facing behavior changed.
- [ ] `.ai-team/state/runs.json` contains compact evidence for execution, review, and integration checks.
- [ ] Final diff contains no unrelated edits.
- [ ] New durable pitfalls were added to `pitfalls.md`.
- [ ] New reusable patterns were added to `patterns.md`.
- [ ] Task cards were updated with final status and verification evidence.
