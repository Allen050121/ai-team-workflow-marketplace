param(
    [string]$TaskId,
    [switch]$Full,
    [ValidateSet("compact", "standard", "full")]
    [string]$Mode = "compact"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
if ($Full) {
    $Mode = "full"
}

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

    if ($Tail -gt 0 -and -not $Full -and $Mode -ne "full") {
        Get-Content -LiteralPath $Path -Encoding UTF8 -Tail $Tail
    }
    else {
        Get-Content -LiteralPath $Path -Encoding UTF8
    }
}

function Show-Section {
    param(
        [string]$Label,
        [string]$Path,
        [int]$CompactTail,
        [int]$StandardTail = 0
    )

    if ($Full -or $Mode -eq "full") {
        Show-File $Label $Path
        return
    }

    if ($Mode -eq "standard" -and $StandardTail -gt 0) {
        Show-File $Label $Path $StandardTail
        return
    }

    Show-File $Label $Path $CompactTail
}

Write-Host "AI Team context bundle"
Write-Host "Project root: $ProjectRoot"
Write-Host "Mode: $Mode"
Write-Host "Tip: use -Mode standard for more context or -Full for complete files."

Show-Section "Project Brief" (Join-Path $ProjectRoot ".ai-team\memory\project-brief.md") 80 160
Show-Section "Human Lead" (Join-Path $ProjectRoot ".ai-team\memory\human-lead.md") 60 120
Show-Section "Technology Policy" (Join-Path $ProjectRoot ".ai-team\memory\technology-policy.md") 80 160
Show-Section "Repo Map" (Join-Path $ProjectRoot ".ai-team\index\repo-map.md") 80 160
Show-Section "Pitfalls" (Join-Path $ProjectRoot ".ai-team\memory\pitfalls.md") 80 160
Show-Section "Patterns" (Join-Path $ProjectRoot ".ai-team\memory\patterns.md") 80 160
Show-Section "Command Policy" (Join-Path $ProjectRoot ".ai-team\policies\command-policy.md") 80 120

if ($TaskId) {
    $taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"
    Show-Section "Task: $TaskId" $taskPath 140 220
    Show-Section "Task State" (Join-Path $ProjectRoot ".ai-team\state\tasks.json") 120 200
    Show-Section "Recent Run Evidence" (Join-Path $ProjectRoot ".ai-team\state\runs.json") 120 220
}
else {
    Write-Host ""
    Write-Host "No task id provided. Add -TaskId <task-id> to include a task card."
}

Write-Host ""
Write-Host "===== Git Status ====="
try {
    $gitRoot = git -C $ProjectRoot rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $gitRoot) {
        Write-Host "Git status unavailable. This directory may not be a git repository yet."
    }
    else {
        git -C $ProjectRoot status --short
    }
}
catch {
    Write-Host "Git status unavailable. This directory may not be a git repository yet."
}
