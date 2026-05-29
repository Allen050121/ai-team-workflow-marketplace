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
- [ ] Manual smoke test was run when user-facing behavior changed.
- [ ] Final diff contains no unrelated edits.
- [ ] New durable pitfalls were added to `pitfalls.md`.
- [ ] New reusable patterns were added to `patterns.md`.
- [ ] Task cards were updated with final status and verification evidence.
