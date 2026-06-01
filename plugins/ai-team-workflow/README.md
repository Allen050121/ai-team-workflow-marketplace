# AI Team Workflow Plugin

<p align="center">
  <strong>English</strong> · <a href="./README.zh-CN.md">简体中文</a>
</p>

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

## Normal Codex Use

```text
I want to build a product: xxx. Ask me before key choices.
```

Then continue with:

```text
Continue
```
