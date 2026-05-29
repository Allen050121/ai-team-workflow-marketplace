---
title: Codex Usage
tags:
  - ai-team
  - codex
status: active
---

# Codex Usage

Use Codex as the main AI team interface.

## Normal Use

In Codex chat, say the real work:

```text
我要做一个产品：个人待办清单 Web App。MVP 包含登录、任务列表、部署到 Vercel。遇到关键选择先问我。
```

Then continue with:

```text
继续
```

or:

```text
审核刚才的任务
```

## Codex Responsibilities

Codex should:

- Read `AGENTS.md`.
- Respect `.ai-team/memory/human-lead.md`.
- Inspect `.ai-team/tasks/` before deciding the next action.
- Use `.ai-team/memory/` for project context and lessons.
- Use `.ai-team/prompts/` internally for the right role.
- Use `.ai-team/checklists/` as gates.
- Ask questions only at clarification or approval boundaries.

## User Responsibilities

The user only provides:

- Product intent.
- Scope choices.
- Approval for risky or external actions.

The user should not need to run `.ai.cmd` during normal Codex use.
