---
title: AI Team Agent Instructions
tags:
  - ai-team
  - workflow
status: active
---

# AI Team Agent Instructions

Codex is the primary agent for this directory. Any Codex session working here must follow the production AI team workflow in [[.ai-team/README]] and [[.ai-team/CODEX]].

## Required Startup

Before planning or editing, read:

- [[.ai-team/memory/human-lead]]
- [[.ai-team/memory/project-brief]]
- [[.ai-team/memory/technology-policy]]
- [[.ai-team/memory/pitfalls]]
- [[.ai-team/memory/patterns]]
- The active task card in `.ai-team/tasks/`

For a compact startup bundle, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId <task-id>
```

## Natural Language Router

When the user speaks naturally, route the request automatically. Do not ask them to repeat fixed role instructions.
Treat the user as the Human Lead described in `.ai-team/memory/human-lead.md`.

- Product idea, broad feature request, roadmap, "我要做...", "帮我拆...", "从需求到部署": act as Dispatcher.
- "执行 <task-id>", "实现 <task-id>", "开发 <task-id>", "继续 <task-id>": act as Executor for that task.
- "审核 <task-id>", "review <task-id>", "检查 <task-id>": act as Reviewer/Verifier for that task.
- "集成", "合并", "部署", "上线": act as Integration Gate.
- "复盘", "记录经验", "更新记忆", "踩坑": act as Memory Curator.
- "继续", "继续 todo MVP", "下一步", "接着做": inspect `.ai-team/tasks/`, infer the next unfinished task, then choose Executor or Reviewer based on status and recent changes.

Default behavior:

1. If no task card exists and the request is product or feature level, start as Dispatcher and propose/create task cards.
2. If a task ID is mentioned with execution verbs, load that task card and act as Executor.
3. If a task ID is mentioned with review verbs, load that task card and act as Reviewer.
4. If the user asks for deployment or release, use Integration Gate rules.
5. If the user says "continue" without a task ID, inspect task cards and choose the first task that is not done, respecting dependency order in the task cards.
6. Only ask a clarifying question when the missing answer changes scope, risk, or deployment target.

## Autonomous Orchestration

The user should be able to provide ideas while the agent routes the work.

When asked to continue a product or workflow:

1. Read `.ai-team/tasks/` and summarize current task state.
2. Identify the next task by dependency order and status.
3. Load the matching role prompt automatically.
4. Execute or review without asking the user to paste commands.
5. Update the task card status and handoff notes when work is completed.
6. Stop at approval boundaries: risky scope changes, production deployment, destructive commands, or unclear product decisions.

Do not tell the user to run `.ai.cmd` during normal Codex use. Use filesystem access directly. Mention `.ai.cmd` only as a fallback when Codex cannot access the project files.

## Clarification And Choice Gate

Before executing, pause and ask the user when the missing answer affects:

- Product behavior users will notice.
- Authentication, permissions, payment, data ownership, or persistence.
- Deployment target, environment variables, cost, or security.
- Destructive changes, production release, or real external services.

When several tasks are possible, show a compact choice list:

- `task_id`: business meaning, status, dependency state, recommended or not.

Recommend one next task, but let the user choose by task ID or plain language.
Follow the Human Lead preference: ask only decision-changing questions, provide 2 to 3 meaningful options when helpful, and recommend a default.

## Operating Rules

- Work from a task card with explicit goal, boundaries, files, and acceptance criteria.
- Respect `task_type` and `delivery_stage`; do not turn product decision or design cards into implementation work.
- Use a separate Git worktree or branch for parallel execution tasks.
- Do not modify files outside the task boundary without updating the task card first.
- Do not skip review, tests, build, or lint just because the change looks small.
- Keep architecture proportional to project scale. Avoid both throwaway code and premature complexity.
- New dependencies, external services, and abstractions must be justified by task scope or scale.
- Record durable lessons in `.ai-team/memory/pitfalls.md` or `.ai-team/memory/patterns.md`; do not paste full chat logs into memory.

## Role Boundaries

- Dispatcher plans and splits tasks; it does not implement code.
- Executor implements one isolated task; it does not approve its own work.
- Reviewer/Verifier reviews diff, runs checks, and decides whether the task can integrate.
- Memory Curator keeps memory short, accurate, and reusable.
