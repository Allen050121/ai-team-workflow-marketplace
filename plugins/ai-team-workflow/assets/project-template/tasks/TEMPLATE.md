---
title: "{{TITLE}}"
task_id: "{{TASK_ID}}"
status: "{{STATUS}}"
owner: "{{OWNER}}"
mode: "{{MODE}}"
created: "{{DATE}}"
tags:
  - ai-team/task
---

# Task: {{TITLE}}

## Status

- Task ID: `{{TASK_ID}}`
- Owner: `{{OWNER}}`
- Status: `{{STATUS}}`
- Mode: `{{MODE}}`

## Goal

Describe the user-visible result this task must deliver.

## Non-Goals

List what this task must not change.

## File Boundaries

### Allowed To Modify

{{ALLOWED_FILES}}

### Must Not Modify

- Files outside the allowed boundary unless this card is updated first.
- Shared schemas, migrations, auth, payment, or build configuration unless explicitly listed above.

## Context To Read

- `.ai-team/memory/project-brief.md`
- `.ai-team/memory/pitfalls.md`
- `.ai-team/memory/patterns.md`
- Related source files listed above.

## Implementation Notes

- Keep the change small enough for one reviewer to inspect quickly.
- Prefer existing project patterns over new abstractions.
- If boundaries are wrong, stop and update this card before editing.

## Acceptance Criteria

- [ ] Goal is implemented.
- [ ] File boundary was respected or this card was updated.
- [ ] Diff has no unrelated edits.
- [ ] Pitfalls were checked.
- [ ] Verification command was run or explicitly waived with a reason.

## Verification

```powershell
# Replace with real project commands.
git status --short
```

## Handoff Notes

- Changed files:
- Verification result:
- Known follow-ups:
- Memory updates needed:
