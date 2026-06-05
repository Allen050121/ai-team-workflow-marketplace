param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$hooksDir = Join-Path $ProjectRoot ".ai-team\hooks"
$commandsPath = Join-Path $hooksDir "commands.md"
$examplePath = Join-Path $hooksDir "claude-code-settings.example.json"

if (-not (Test-Path -LiteralPath $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir | Out-Null
}

$content = @"
# AI Team Hook Commands

Use these commands in any agent tool that supports startup hooks or custom commands.

## Dispatcher

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role dispatcher
```

## Executor

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role executor -TaskId <task-id>
```

## Reviewer

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role reviewer -TaskId <task-id>
```

## Memory Curator

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role memory -TaskId <task-id>
```

## Integration Gate

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/hooks/ai-team-hook.ps1 -Role integration
```

See ``$examplePath`` for a Claude Code settings example.
"@

if ((Test-Path -LiteralPath $commandsPath) -and -not $Force) {
    Write-Host "Hook command file already exists: $commandsPath"
}
else {
    Set-Content -LiteralPath $commandsPath -Encoding UTF8 -Value $content
    Write-Host "Wrote hook command file: $commandsPath"
}

if (Test-Path -LiteralPath $examplePath) {
    Write-Host "Claude Code example exists: $examplePath"
}
else {
    Write-Warning "Claude Code example is missing: $examplePath"
}

Write-Host ""
Write-Host "Next:"
Write-Host "1. If your tool supports hooks, copy the relevant command from $commandsPath."
Write-Host "2. If it does not, run Start-AiTeamRole.ps1 and paste the generated bundle."
