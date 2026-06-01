# AI Team Workflow Marketplace

<p align="center">
  <strong>English</strong> · <a href="./README.zh-CN.md">简体中文</a>
</p>

`ai-team-workflow` is a Codex-first AI development team workflow plugin.

It provides a reusable global standard plus project-local `.ai-team` files for product planning, task cards, repo maps, structured task state, review gates, and lightweight GitHub PR/CI/security checks.

## What It Provides

- Global Human Lead profile.
- Clean project template for `.ai-team`.
- Natural-language routing for Codex.
- Task cards, project memory, repo map, and structured task state.
- Scale, quality, performance, security, PR, and integration gates.
- Lightweight GitHub issue/PR templates without forcing GitHub Projects.

## Install On Another Computer

Clone this repository:

```powershell
git clone https://github.com/Allen050121/ai-team-workflow-marketplace.git
cd ai-team-workflow-marketplace
```

Add this marketplace in Codex using the repository root or marketplace file:

```text
ai-team-workflow-marketplace/marketplace.json
```

After installing the plugin, sync the global template:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\plugins\ai-team-workflow\scripts\Install-AiTeamWorkflow.ps1 -Force
```

## Initialize A Project

From any project directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

Then use Codex naturally:

```text
I want to build a product: xxx. Ask me before key product or technical choices.
```

## Daily Use

In Codex, use natural language:

```text
Continue
```

```text
Review the last task
```

```text
Continue to pre-deployment checks, but do not deploy to production yet.
```

Codex should read the global standard, inspect the project `.ai-team`, and route the work automatically.
