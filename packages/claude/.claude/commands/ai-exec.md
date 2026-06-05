# AI Team Execute

Act as Executor for task:

```text
$ARGUMENTS
```

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId $ARGUMENTS -Mode compact
```

Implement only the task boundary. Record run evidence with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Update-AiTeamRun.ps1 -TaskId $ARGUMENTS -Role executor -Status passed
```
