---
title: Production AI Team Workflow
tags:
  - ai-team
  - production
  - workflow
status: active
---

# Production AI Team Workflow

This directory implements a production-oriented AI development team:

```mermaid
flowchart LR
    Human["Human Lead"] --> Dispatcher["Dispatcher / Planner"]
    Dispatcher --> TaskCards["Task Cards"]
    TaskCards --> Exec1["Executor Worktree A"]
    TaskCards --> Exec2["Executor Worktree B"]
    TaskCards --> Exec3["Executor Worktree C"]
    Exec1 --> Reviewer["Reviewer / Verifier"]
    Exec2 --> Reviewer
    Exec3 --> Reviewer
    Reviewer --> Integration["Integration Gate"]
    Integration --> Memory["Memory Curator"]
    Memory --> Dispatcher
```

## Core Idea

Parallelism happens only in isolated Git worktrees with explicit task boundaries. Quality control stays centralized through review and integration gates.

This avoids the common failure mode of many AI windows: each window has partial context, edits overlapping files, repeats past mistakes, and spends tokens rediscovering the project.

## Daily Workflow

1. Tell Codex the real product or feature request in natural language.
2. Codex routes the request through `AGENTS.md`, then uses Dispatcher to split the fewest useful tasks.
3. Executor works from one task card, one branch or worktree, and only the relevant project context.
4. Executor records compact evidence in `.ai-team/state/runs.json`.
5. Reviewer checks diff, verification, command policy, and task evidence before passing work.
6. Integration Gate merges in dependency order and uses Release Gate for deployment or publishing.
7. Memory Curator records only durable pitfalls and reusable patterns.

## Minimal Commands

Most days in Codex, just say the real request:

```text
我要做一个待办产品，MVP 包含登录、任务列表、部署到 Vercel
```

Codex should route the request through `AGENTS.md` and `.ai-team/`. The scripts are fallback helpers and repeatable audit tools, not the normal user interface.

Create a task card:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/New-AiTeamTask.ps1 -Id login-auth -Title "Implement login auth"
```

Record run evidence:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Update-AiTeamRun.ps1 -TaskId login-auth -Role executor -Status passed -Verification "npm run build: passed"
```

Show current task and run status:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamStatus.ps1
```

Print an agent startup bundle:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId login-auth
```

Create an isolated worktree:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/New-AiTeamWorktree.ps1 -TaskId login-auth
```

Review a task diff:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamTask.ps1 -TaskId login-auth -WorktreePath <path-to-worktree>
```

## Non-Negotiable Rules

- Default parallelism is 2 to 3 Executor agents. Use 4 only when file boundaries are very clean.
- A task that touches shared data models, common APIs, auth, payment, migrations, or build configuration is serial by default.
- No Executor approves its own work.
- No task is done without a reproducible verification command or an explicit reason why verification is impossible.
- Approval-required commands must follow `.ai-team/policies/command-policy.md`.
- Deployment, publishing, release tagging, and production-facing actions must pass Release Gate.
- Memory must be compressed and reusable. Full transcripts, raw logs, run ledgers, and one-off observations do not belong in memory.

## Directory Map

- `.ai-team/memory/`: durable project context, pitfalls, and reusable patterns.
- `.ai-team/tasks/`: task cards and task state.
- `.ai-team/prompts/`: role prompts for Dispatcher, Executor, Reviewer, and Memory Curator.
- `.ai-team/checklists/`: plan, review, security, release, and integration gates.
- `.ai-team/policies/command-policy.md`: safe, approval-required, and forbidden command classes.
- `.ai-team/scripts/`: small PowerShell helpers for repeatable operations.
- `.ai-team/hooks/`: reusable hook entrypoints and examples for agent tools.
- `.ai-team/commands.json`: project verification commands used by Reviewer/Verifier.
- `.ai-team/github/`: lightweight issue and PR templates for GitHub-backed projects.
- `.ai-team/index/repo-map.md`: compact codebase map to reduce repeated exploration.
- `.ai-team/state/tasks.json`: tool-readable task state synced from task cards.
- `.ai-team/state/runs.json`: compact run evidence for execution, review, and integration.
