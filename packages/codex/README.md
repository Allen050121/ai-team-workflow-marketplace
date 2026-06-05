# AI Team Workflow - Codex Package

This package is the Codex-oriented AI Team Workflow distribution.

## Install

Copy or extract this package into your project root, then keep:

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

For normal Codex use, talk naturally. Codex should read `AGENTS.md`, then route through `.ai-team/`.

## Quick Checks

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamStatus.ps1
```

## Token Discipline

Use compact context first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -Mode compact
```
