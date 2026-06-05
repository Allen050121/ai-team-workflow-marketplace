# AI Team Review

Act as Reviewer for task:

```text
$ARGUMENTS
```

Generate a structured review report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/New-AiTeamReviewReport.ps1 -TaskId $ARGUMENTS -OutFile auto
```

Then verify boundary, state machine, command policy, workflow mode, and test evidence before deciding: `pass`, `request_changes`, or `blocked`.
