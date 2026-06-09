---
name: ai-team-workflow
description: "Use when setting up or operating a Codex-first AI Team workflow: global Human Lead profile, project-local .ai-team task system, natural language routing, scale/quality/performance gates, and project initialization from the global template."
---

# AI Team Workflow

Use this skill when the user wants a stable Codex-first AI development team workflow, project task cards, natural-language routing, quality gates, or a reusable global template.

## Core Model

- Global standard lives in `%USERPROFILE%\.codex\ai-team`.
- Project-specific facts and task cards live in the current project's `.ai-team` directory.
- The user is the Human Lead: they provide product intent and approve high-impact choices; Codex routes, inspects, executes, reviews, and updates task cards.
- GitHub support is lightweight by default: task cards can record branch, issue, PR, and CI status; PR/security gates enforce production basics without requiring GitHub Projects.
- Repo map and structured task state help Codex continue reliably without rediscovering the project every turn.

## Install Or Sync Global Template

Run from this plugin directory or with an absolute path:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

Use `-Force` to overwrite the existing global template from plugin assets.

## Initialize A Project

From a project directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

Then ask Codex to inspect the project and update `.ai-team/memory/project-brief.md`.

## Normal Codex Use

In Codex chat, the user should say natural-language product intent, for example:

```text
我想做一个产品：个人书签管理 Web App。MVP 包含添加、搜索、删除、部署到 Vercel。遇到关键选择先问我。
```

Codex should use `AGENTS.md`, inspect `.ai-team`, create task cards, and continue through Dispatcher, Executor, Reviewer, Integration, and Memory Curator roles without asking the user to run fixed commands.
