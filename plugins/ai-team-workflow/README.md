# AI Team Workflow Plugin

Codex-first AI development team workflow packaged as a local plugin.

## What It Provides

- Global Human Lead profile.
- Global project template for `.ai-team`.
- Natural-language routing rules for Codex.
- Task cards, memory files, prompts, and quality gates.
- Scale, quality, and performance gates to avoid both messy code and overengineering.
- Lightweight GitHub PR, CI, and security gates integrated with task cards.
- Repo map and structured task state for more reliable "continue" behavior.

## Install Global Template

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

## Initialize A Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

## 中文说明

这个插件会安装一套 Codex-first 的 AI 开发团队模板。全局保存标准和 Human Lead 人设，项目目录保存 `.ai-team` 任务卡、项目记忆、代码地图和结构化状态。

日常在 Codex 里直接说：

```text
我想做一个产品：xxx。遇到关键选择先问我。
```

后续说：

```text
继续
```
