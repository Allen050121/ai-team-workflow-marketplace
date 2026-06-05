---
title: AI Team Hooks
tags:
  - ai-team
  - hooks
status: active
---

# AI Team Hooks

Hooks automate the fixed parts of the workflow:

- Load the correct role prompt.
- Load the shared memory files.
- Load the active task card.
- Load the right gate checklist.
- Print a compact startup instruction bundle.

## Universal Hook

Use this command in any tool that can run a shell command before an agent session:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role executor -TaskId <task-id>
```

Supported roles:

- `dispatcher`
- `executor`
- `reviewer`
- `memory`
- `integration`

## Claude Code Example

`claude-code-settings.example.json` shows a hook-style configuration shape. Copy the relevant command into your actual Claude Code settings if your local setup supports hooks.

## Tools Without Hooks

If the tool does not support hooks, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Start-AiTeamRole.ps1 -Role executor -TaskId <task-id>
```

Then paste the output into the agent window. This keeps the manual part to one command.
