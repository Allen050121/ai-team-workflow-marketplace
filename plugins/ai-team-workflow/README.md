# AI Team Workflow Plugin

Codex-first AI development team workflow packaged as a local plugin.

## What It Provides

- Global Human Lead profile.
- Global project template for `.ai-team`.
- Natural-language routing rules for Codex.
- Task cards, memory files, prompts, and quality gates.
- Scale, quality, and performance gates to avoid both messy code and overengineering.

## Install Global Template

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

## Initialize A Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```
