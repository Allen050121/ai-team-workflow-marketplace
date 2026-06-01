param(
    [string]$TaskId,
    [switch]$Full
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

function Show-File {
    param(
        [string]$Label,
        [string]$Path,
        [int]$Tail = 0
    )

    Write-Host ""
    Write-Host "===== $Label ====="

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Missing: $Path"
        return
    }

    if ($Tail -gt 0 -and -not $Full) {
        Get-Content -LiteralPath $Path -Encoding UTF8 -Tail $Tail
    }
    else {
        Get-Content -LiteralPath $Path -Encoding UTF8
    }
}

Write-Host "AI Team context bundle"
Write-Host "Project root: $ProjectRoot"

Show-File "Project Brief" (Join-Path $ProjectRoot ".ai-team\memory\project-brief.md")
Show-File "Human Lead" (Join-Path $ProjectRoot ".ai-team\memory\human-lead.md")
Show-File "Technology Policy" (Join-Path $ProjectRoot ".ai-team\memory\technology-policy.md")
Show-File "Pitfalls" (Join-Path $ProjectRoot ".ai-team\memory\pitfalls.md") 120
Show-File "Patterns" (Join-Path $ProjectRoot ".ai-team\memory\patterns.md") 120
Show-File "Command Policy" (Join-Path $ProjectRoot ".ai-team\policies\command-policy.md")

if ($TaskId) {
    $taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"
    Show-File "Task: $TaskId" $taskPath
    Show-File "Recent Run Evidence" (Join-Path $ProjectRoot ".ai-team\state\runs.json") 160
}
else {
    Write-Host ""
    Write-Host "No task id provided. Add -TaskId <task-id> to include a task card."
}

Write-Host ""
Write-Host "===== Git Status ====="
try {
    git -C $ProjectRoot status --short
}
catch {
    Write-Host "Git status unavailable: $($_.Exception.Message)"
}
