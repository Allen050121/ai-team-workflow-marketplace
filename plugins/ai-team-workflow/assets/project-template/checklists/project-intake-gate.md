---
title: Project Intake Gate
tags:
  - ai-team/checklist
  - intake
status: active
---

# Project Intake Gate

Use this gate at the start of a new product idea, feature request, or "continue" request when the project state is unclear.

## Required Intake

- [ ] Determine whether the current directory is a new empty project, existing codebase, existing AI Team project, mixed/notes directory, or unclear directory.
- [ ] Prefer `.ai-team/scripts/Get-AiTeamIntake.ps1` when available.
- [ ] Do not trust the user's label blindly when repository signals disagree.
- [ ] For existing projects without `.ai-team`, ask before adding `.ai-team` workflow files.
- [ ] For mixed or notes directories, confirm the exact target project directory before creating application files.
- [ ] If the git working tree has unrelated changes, avoid touching them and ask before commit/push.
- [ ] If data/schema/auth/payment/deployment signals exist, require explicit confirmation before changing those areas.

## Recommended Paths

| Intake type | Default path |
|---|---|
| `new_empty_project` | Plan product, choose proportional stack, then initialize project files. |
| `existing_project_without_ai_team` | Add `.ai-team`, create repo-map/project brief, then plan incremental work. |
| `existing_project_with_ai_team` | Read task state and run evidence, then continue the workflow. |
| `ai_team_project` | Continue current task workflow using compact context. |
| `mixed_or_notes_directory` | Ask for target project directory or create a dedicated subdirectory. |
| `unclear_directory` | Inspect lightly and ask one concise clarifying question before writing code. |

## Output

Keep the response compact:

1. Project type and confidence.
2. Signals that caused the classification.
3. Recommended next path.
4. Only the decision-changing questions.

Do not expose the full checklist unless the user asks for operational detail.
