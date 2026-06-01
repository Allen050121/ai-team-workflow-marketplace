---
title: AI Team Natural Language Router
tags:
  - ai-team
  - router
status: active
---

# AI Team Natural Language Router

Use this file when a tool supports project instructions such as `AGENTS.md`.

## Intent Mapping

| User says | Route to |
|---|---|
| 我要做一个产品 / 帮我设计 / 先拆任务 / 需求到部署 | Dispatcher |
| 执行 / 实现 / 开发 / 继续 + task id | Executor |
| 审核 / review / 检查 + task id | Reviewer/Verifier |
| 合并 / 集成 / 部署 / 上线 | Integration Gate |
| 复盘 / 记录踩坑 / 更新记忆 | Memory Curator |
| 继续 / 下一步 / 接着做 | Inspect task cards, then route to Executor or Reviewer |

## Default Startup

Always load:

- `.ai-team/memory/project-brief.md`
- `.ai-team/memory/pitfalls.md`
- `.ai-team/memory/patterns.md`
- `.ai-team/policies/command-policy.md`

Then load the routed role prompt:

- Dispatcher: `.ai-team/prompts/dispatcher.md`
- Executor: `.ai-team/prompts/executor.md`
- Reviewer: `.ai-team/prompts/reviewer-verifier.md`
- Memory Curator: `.ai-team/prompts/memory-curator.md`
- Integration: `.ai-team/checklists/integration-gate.md` and `.ai-team/checklists/release-gate.md` when deployment or publishing is involved

## User Experience Rule

The user should only need to state the real work. Do not require them to type fixed phrases like "you are Dispatcher" or "read memory first".

For Codex-style tools with filesystem access, do not require `.ai.cmd` for normal operation. Inspect the repository directly.
