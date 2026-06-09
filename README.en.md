# AI Team Workflow Marketplace

<p align="center">
  <a href="./README.md">简体中文</a> | <strong>English</strong>
</p>

`ai-team-workflow` is an AI product delivery workflow plugin for Codex and Claude Code. Its goal is not to simulate a large team, but to let one agent reliably move a product from idea to deployable version.

It turns work into trackable task cards and asks for your decisions at the right moments: target audience, MVP scope, product surface, stack and scale fit, frontend design, backend APIs derived from UI interactions, and deployment capacity.

## What It Solves

Many AI coding workflows start writing code before the product is clear, which leads to drift:

- The audience and core use case are not confirmed.
- The stack is either too weak or overbuilt.
- Backend APIs are written before the frontend needs them.
- The UI does not attract users.
- Backend code lacks maintainable architecture boundaries.
- Deployment happens without capacity, budget, backup, or scaling decisions.

AI Team Workflow moves those decisions into task cards and gates so the agent plans first, confirms key choices, and only then implements.

## Workflow

The default flow is single-agent and serial:

```text
product discovery
 -> product surface
 -> stack and scale
 -> architecture boundaries
 -> frontend design
 -> API mapping
 -> implementation
 -> quality checks
 -> deployment capacity
 -> release
```

Parallel mode is still available, but only when task boundaries are very clear and the work does not touch shared models, auth, migrations, or common APIs.

## Core Capabilities

- Task cards, project memory, repo map, and structured task state.
- Layered task cards for product decisions, design, implementation, verification, deployment, and maintenance.
- Single-agent product delivery by default, with parallel mode only when justified.
- Product discovery, product surface, frontend design, API mapping, and deployment capacity gates.
- Workflow modes: `light`, `standard`, `strict`, and `parallel`.
- Automatic workflow mode classification.
- Compact context and context budget checks to reduce token waste.
- Benchmark templates for recording rework, turns, verification, and context/token budgets on real projects.
- Diff boundary checks, state machine checks, review reports, and run evidence.
- Template version tracking and migration reports during project updates.
- Quality, security, performance, PR, release, and integration gates.

## Recommended Use

In Codex, describe the real product work:

```text
I want to build a product: a personal task management web app. Use AI Team Workflow for product discovery first. Do not write code yet.
```

To continue:

```text
Continue to the next task card.
```

To review:

```text
Review the current task card.
```

## Downloads

Download the latest zip packages from GitHub Releases:

- [Download for Codex](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-codex-v0.5.0.zip)
- [Download for Claude Code](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-claude-v0.5.0.zip)

Both packages share the same `.ai-team` workflow core, but keep platform-specific entry files isolated so Codex and Claude instructions do not conflict.

## Codex Install

Download and extract:

```text
ai-team-workflow-codex-v0.5.0.zip
```

Place the contents in a Codex project root. Keep:

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Claude Code Install

Download and extract:

```text
ai-team-workflow-claude-v0.5.0.zip
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

Pushing a version tag creates a GitHub Release and uploads the zip packages automatically. Bump the template and plugin versions first, then push the matching tag:

```powershell
git tag v0.5.1
git push origin v0.5.1
```
