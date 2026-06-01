---
title: AI Team Usage
tags:
  - ai-team
  - usage
status: active
---

# AI Team Usage

This workflow is optimized for Codex first. In normal use, do not run commands and do not repeat fixed role instructions. Just talk about the product work in Codex.

## Codex Daily Use

Start with a product idea:

```text
我要做一个待办产品，MVP 包含登录、任务列表、部署到 Vercel。先拆任务，不要写代码。
```

Continue work:

```text
继续 todo MVP
```

Ask for review:

```text
审核刚才的任务
```

Move toward release:

```text
继续到部署前检查，不要真正部署生产环境。
```

Codex should inspect `.ai-team/tasks/`, `.ai-team/state/tasks.json`, and `.ai-team/state/runs.json`, infer the next step, and avoid asking you to run fixed commands.

## What Codex Should Do

Codex should automatically:

- Read `AGENTS.md` and `.ai-team/` workflow files.
- Respect `.ai-team/memory/human-lead.md`.
- Use `.ai-team/memory/technology-policy.md` to avoid both messy underengineering and expensive overengineering.
- Route your natural-language request to Dispatcher, Executor, Reviewer, Integration, or Memory Curator.
- Use `.ai-team/policies/command-policy.md` before risky commands.
- Record compact execution and review evidence in `.ai-team/state/runs.json`.
- Prefer compact context bundles; use full context only when compact context is insufficient.
- Show task IDs, business meaning, status, dependency state, evidence state, and recommended next action when there are choices.
- Ask you only when the answer affects product behavior, architecture, data, cost, security, or deployment.
- Update task cards and handoff notes as work progresses.

## What You Still Need To Say

Only say the part that requires human judgment:

- Product goal.
- Must-have scope.
- What not to build.
- Deployment preference.
- Approval for risky merge, external service, or production deployment.

## Evidence Without Extra Work

You do not need to paste fixed status commands during normal Codex use. Codex should keep task cards and `.ai-team/state/runs.json` updated so "continue" can see the latest task result, verification state, and blocker reason.

For low-token handoffs, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId <task-id>
```

Use `-Mode standard` or `-Full` only when the compact bundle is not enough.

## Optional Fallback

Use `.ai.cmd` only if Codex is not reading the project files or if you are in a different tool:

```text
.\ai.cmd "我要做一个待办产品，MVP 包含登录、任务列表、部署到 Vercel"
```

This fallback copies the workflow context to your clipboard.
