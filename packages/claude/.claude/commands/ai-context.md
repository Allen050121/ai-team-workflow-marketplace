# AI Team Context

Run compact context first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId $ARGUMENTS -Mode compact
```

Use `-Mode standard` only after naming the missing information. Use `-Full` only for review, debugging stale memory, or resolving contradictions.
