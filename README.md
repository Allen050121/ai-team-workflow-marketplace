# AI Team Workflow Marketplace

Local/Git marketplace for the `ai-team-workflow` Codex plugin.

## Plugin

- `ai-team-workflow`: Codex-first AI development team workflow with a global Human Lead profile, project-local `.ai-team` task system, natural-language routing, scale-aware quality gates, and lightweight GitHub PR/CI/security gates.

## Install On Another Computer

Clone this repository:

```powershell
git clone <your-repo-url> ai-team-workflow-marketplace
```

Then add this marketplace in Codex using the repository root or marketplace file, depending on the Codex UI/version.

Marketplace file:

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
我想做一个产品：xxx。遇到关键选择先问我。
```
