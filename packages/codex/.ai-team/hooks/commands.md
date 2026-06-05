# AI Team Hook Commands

Use these commands in any agent tool that supports startup hooks or custom commands.

## Dispatcher

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role dispatcher
```

## Executor

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role executor -TaskId TASK_ID
```

## Reviewer

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role reviewer -TaskId TASK_ID
```

## Memory Curator

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role memory -TaskId TASK_ID
```

## Integration Gate

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role integration
```

See `.ai-team/hooks/claude-code-settings.example.json` for a hook settings example.
