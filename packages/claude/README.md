# AI Team Workflow - Claude Package

This package is the Claude Code-oriented AI Team Workflow distribution.

It keeps the same `.ai-team/` core workflow as the Codex package, but uses Claude-native entry files:

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/commands/*.md`

## Install

Extract this package into a Claude Code project root.

Then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
```

Claude Code should read `CLAUDE.md` automatically. Use the slash command files in `.claude/commands/` for status, context, dispatch, execution, and review flows.

## Token Discipline

Claude should start with compact context and only expand when the task requires it:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -Mode compact
```
