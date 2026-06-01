param(
    [string]$TaskId,
    [switch]$Full,
    [ValidateSet("compact", "standard", "full")]
    [string]$Mode = "compact",
    [int]$MaxRuns = 3
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

function Show-RunSummary {
    param(
        [string]$TaskId,
        [string]$Path,
        [int]$Limit
    )

    Write-Host ""
    Write-Host "===== Recent Run Evidence ====="

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Missing: $Path"
        return
    }

    if ($Full -or $Mode -eq "full") {
        Get-Content -LiteralPath $Path -Encoding UTF8
        return
    }

    try {
        $state = Get-Content -LiteralPath $Path -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "Run state exists but could not be parsed: $Path"
        return
    }

    $runs = @()
    if ($state.runs) {
        $runs = @($state.runs | Where-Object { $_.task_id -eq $TaskId })
    }

    if ($runs.Count -eq 0) {
        Write-Host "No run evidence recorded for task: $TaskId"
        return
    }

    $runs |
        Sort-Object @{ Expression = { if ($_.finished_at) { $_.finished_at } else { $_.started_at } }; Descending = $true } |
        Select-Object -First $Limit |
        ForEach-Object {
            Write-Host ("- {0} role={1}; status={2}; finished={3}" -f $_.run_id, $_.role, $_.status, $_.finished_at)
            if ($_.verification -and @($_.verification).Count -gt 0) {
                Write-Host ("  verification: {0}" -f (@($_.verification) -join "; "))
            }
            if ($_.blocked_reason) {
                Write-Host ("  blocked: {0}" -f $_.blocked_reason)
            }
            if ($_.followups -and @($_.followups).Count -gt 0) {
                Write-Host ("  followups: {0}" -f (@($_.followups) -join "; "))
            }
        }
}

function Show-TaskStateSummary {
    param(
        [string]$TaskId,
        [string]$Path
    )

    Write-Host ""
    Write-Host "===== Task State ====="

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Missing: $Path"
        return
    }

    if ($Full -or $Mode -eq "full") {
        Get-Content -LiteralPath $Path -Encoding UTF8
        return
    }

    try {
        $state = Get-Content -LiteralPath $Path -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "Task state exists but could not be parsed: $Path"
        return
    }

    if ($state.updatedAt) {
        Write-Host ("State updated: {0}" -f $state.updatedAt)
    }

    $task = $null
    if ($state.tasks) {
        $task = @($state.tasks | Where-Object { $_.task_id -eq $TaskId } | Select-Object -First 1)
    }

    if (-not $task) {
        Write-Host "No task state recorded for task: $TaskId"
        return
    }

    Write-Host ("- {0} [{1}] {2}" -f $task.task_id, $task.status, $task.title)
    if ($task.work_mode) { Write-Host ("  work_mode: {0}" -f $task.work_mode) }
    if ($task.mode) { Write-Host ("  mode: {0}" -f $task.mode) }
    if ($task.dependencies -and @($task.dependencies).Count -gt 0) {
        Write-Host ("  dependencies: {0}" -f (@($task.dependencies) -join ", "))
    }
    if ($task.verification_status -or $task.last_run_id -or $task.last_result) {
        Write-Host ("  evidence: verification={0}; last_run={1}; result={2}" -f $task.verification_status, $task.last_run_id, $task.last_result)
    }
    if ($task.blocked_reason) { Write-Host ("  blocked: {0}" -f $task.blocked_reason) }
    if ($task.branch -or $task.github_issue -or $task.github_pr -or $task.ci_status) {
        Write-Host ("  github: branch={0}; issue={1}; pr={2}; ci={3}" -f $task.branch, $task.github_issue, $task.github_pr, $task.ci_status)
    }
}

Write-Host "AI Team context bundle"
Write-Host "Project root: $ProjectRoot"
Write-Host "Mode: $Mode"
Write-Host "Tip: use -Mode standard for more context or -Full for complete files."

Show-Section "Project Brief" (Join-Path $ProjectRoot ".ai-team\memory\project-brief.md") 80 160
Show-Section "Human Lead" (Join-Path $ProjectRoot ".ai-team\memory\human-lead.md") 60 120
Show-Section "Production Mode" (Join-Path $ProjectRoot ".ai-team\memory\production-mode.md") 80 160
Show-Section "Technology Policy" (Join-Path $ProjectRoot ".ai-team\memory\technology-policy.md") 80 160
Show-Section "Repo Map" (Join-Path $ProjectRoot ".ai-team\index\repo-map.md") 80 160
Show-Section "Pitfalls" (Join-Path $ProjectRoot ".ai-team\memory\pitfalls.md") 80 160
Show-Section "Patterns" (Join-Path $ProjectRoot ".ai-team\memory\patterns.md") 80 160
Show-Section "Command Policy" (Join-Path $ProjectRoot ".ai-team\policies\command-policy.md") 80 120

if ($TaskId) {
    $taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"
    Show-Section "Task: $TaskId" $taskPath 140 220
    Show-TaskStateSummary $TaskId (Join-Path $ProjectRoot ".ai-team\state\tasks.json")
    Show-RunSummary $TaskId (Join-Path $ProjectRoot ".ai-team\state\runs.json") $MaxRuns
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
