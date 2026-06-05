# AI Team Workflow Marketplace

<p align="center">
  <strong>English</strong> | <a href="./README.zh-CN.md">简体中文</a>
</p>

`ai-team-workflow` is an AI development team workflow plugin with a shared `.ai-team` core and isolated Codex / Claude Code distribution packages.

## Download Packages

Prebuilt zip packages are in `dist/`:

- `ai-team-workflow-codex-v0.5.0.zip` for Codex projects.
- `ai-team-workflow-claude-v0.5.0.zip` for Claude Code projects.

Both packages share the same `.ai-team` workflow core, but keep platform-specific entry files isolated so Codex and Claude instructions do not conflict.

## Core Capabilities

- Task cards, project memory, repo map, and structured task state.
- Workflow modes: `light`, `standard`, `strict`, and `parallel`.
- Automatic workflow mode classification.
- Compact context and context budget checks to reduce token waste.
- Diff boundary checks, state machine checks, review reports, and run evidence.
- Template version tracking and migration reports during project updates.
- Quality, security, performance, PR, release, and integration gates.

## Codex Install

Download and extract:

```text
dist/ai-team-workflow-codex-v0.5.0.zip
```

Place the contents in a Codex project root. Keep:

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Claude Install

Download and extract:

```text
dist/ai-team-workflow-claude-v0.5.0.zip
```

Place the contents in a Claude Code project root. Keep:

- `.ai-team/`
- `.claude/`
- `CLAUDE.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Validate

From the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
```

## Rebuild Packages

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-AiTeamPackages.ps1 -Version 0.5.0 -Clean
```
