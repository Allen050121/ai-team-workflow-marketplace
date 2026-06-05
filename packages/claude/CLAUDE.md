# Claude Project Instructions

This project uses AI Team Workflow.

Start with compact project context. Do not load full memory, full chat history, or full task files unless compact context is insufficient.

Read these first:

- `.ai-team/ROUTER.md`
- `.ai-team/policies/workflow-modes.md`
- `.ai-team/policies/command-policy.md`

When continuing work, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamStatus.ps1
```

When working on a task, run compact context:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId <task-id> -Mode compact
```

Follow these rules:

- Respect task card file boundaries.
- Respect `workflow_mode`: `light`, `standard`, `strict`, or `parallel`.
- Record run evidence in `.ai-team/state/runs.json`.
- Generate review reports with `New-AiTeamReviewReport.ps1 -OutFile auto`.
- Run `Test-AiTeamProject.ps1` before integration or release.
- Ask before production actions, destructive commands, external deployments, paid resources, secrets, auth, payments, migrations, or data ownership changes.

Claude-specific note: keep Claude memory short. Use `.ai-team/memory/` for durable project facts only, not raw logs or long transcripts.
