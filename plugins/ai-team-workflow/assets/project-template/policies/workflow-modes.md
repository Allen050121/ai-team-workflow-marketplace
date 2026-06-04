---
title: Workflow Modes
tags:
  - ai-team/policy
  - workflow-modes
status: active
---

# Workflow Modes

Use workflow modes to spend the right amount of process and context for each task. The goal is stable execution with low token waste.

## Modes

| Mode | Use When | Required Flow | Context Budget |
|---|---|---|---|
| `light` | Small, low-risk edits with clear files, such as copy, styling, typo fixes, or one narrow bug. | Direct Executor work, concise verification, optional Reviewer if risk appears. | Compact bundle only; read the task card and touched files. |
| `standard` | Normal feature work, non-trivial bug fixes, or changes touching several files. | Task card, Executor, run evidence, Reviewer before integration. | Compact bundle first; upgrade to standard only when needed. |
| `strict` | Auth, payments, durable data, permissions, migrations, build config, dependencies, deployment, security, or production traffic. | Task card, explicit gates, command risk checks, Reviewer, Integration Gate, run evidence required. | Standard bundle; read the relevant policies and gates. |
| `parallel` | Multiple independent tasks with clean file boundaries and low shared-state collision risk. | Dispatcher creates isolated task cards/worktrees; Reviewer checks each task before integration. | Per-task compact bundles; never give executors the full planning chat. |

## Selection Rules

- Default to `light` only when the change is small, reversible, and does not touch shared contracts.
- Default to `standard` for ordinary product work.
- Escalate to `strict` when any Production Mode trigger appears.
- Use `parallel` only when file boundaries are explicit and no task touches shared schemas, auth, payments, migrations, common APIs, or build configuration.
- If mode is uncertain, choose the safer higher mode but keep context compact.

## Token Discipline

- Start every role with `.ai-team/scripts/Get-AiTeamContext.ps1 -Mode compact`.
- Use `-Mode standard` only after naming the missing information.
- Use `-Full` only for review, debugging stale memory, or resolving contradictions.
- Do not load full chat history when the task card, repo map, and run evidence are enough.
- Keep memory files short and durable. Raw logs and one-off observations belong in `.ai-team/state/runs.json`, not memory.
