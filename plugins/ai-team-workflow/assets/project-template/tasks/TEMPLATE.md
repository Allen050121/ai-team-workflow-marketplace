---
title: "{{TITLE}}"
task_id: "{{TASK_ID}}"
status: "{{STATUS}}"
owner: "{{OWNER}}"
mode: "{{MODE}}"
work_mode: "{{WORK_MODE}}"
workflow_mode: "{{WORKFLOW_MODE}}"
created: "{{DATE}}"
dependencies:
verification_status: not_run
last_run_id:
last_result:
blocked_reason:
branch:
github_issue:
github_pr:
ci_status:
tags:
  - ai-team/task
---

# Task: {{TITLE}}

## Status

- Task ID: `{{TASK_ID}}`
- Owner: `{{OWNER}}`
- Status: `{{STATUS}}`
- Mode: `{{MODE}}`
- Work Mode: `{{WORK_MODE}}`
- Workflow Mode: `{{WORKFLOW_MODE}}`
- Dependencies:
- Verification Status: `not_run`
- Last Run:
- Last Result:
- Blocked Reason:
- Branch:
- GitHub Issue:
- GitHub PR:
- CI Status:

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
- `.ai-team/memory/production-mode.md`
- `.ai-team/memory/technology-policy.md`
- `.ai-team/memory/pitfalls.md`
- `.ai-team/memory/patterns.md`
- `.ai-team/commands.json`
- `.ai-team/policies/command-policy.md`
- `.ai-team/policies/workflow-modes.md`
- Related source files listed above.

## Implementation Notes

- Keep the change small enough for one reviewer to inspect quickly.
- Match process weight to Workflow Mode: light, standard, strict, or parallel.
- Prefer existing project patterns over new abstractions.
- If boundaries are wrong, stop and update this card before editing.
- Create or use a task branch when code changes are required.
- Keep GitHub issue/PR fields updated when GitHub is used for the project.
- Record execution or review evidence in `.ai-team/state/runs.json`.

## Acceptance Criteria

- [ ] Goal is implemented.
- [ ] File boundary was respected or this card was updated.
- [ ] Diff has no unrelated edits.
- [ ] Pitfalls were checked.
- [ ] Workflow Mode was appropriate for the risk level.
- [ ] Verification command was run or explicitly waived with a reason.
- [ ] Security-sensitive changes passed `.ai-team/checklists/security-gate.md`.
- [ ] PR/CI status is recorded when GitHub is used.
- [ ] Run evidence was recorded in `.ai-team/state/runs.json`.

## Verification

```powershell
# Replace with real project commands.
git status --short
```

## Handoff Notes

- Changed files:
- Verification result:
- Run evidence:
- Known follow-ups:
- Memory updates needed:
