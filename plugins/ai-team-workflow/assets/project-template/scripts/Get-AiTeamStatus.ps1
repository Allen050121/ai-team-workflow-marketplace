$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tasksDir = Join-Path $ProjectRoot ".ai-team\tasks"
$statePath = Join-Path $ProjectRoot ".ai-team\state\tasks.json"
$runsPath = Join-Path $ProjectRoot ".ai-team\state\runs.json"

if (-not (Test-Path -LiteralPath $tasksDir)) {
    throw "Missing tasks directory: $tasksDir"
}

Write-Host "AI Team Status"
Write-Host "Project: $ProjectRoot"
Write-Host ""

$stateTasks = @()
$runs = @()
if (Test-Path -LiteralPath $statePath) {
    try {
        $state = Get-Content -LiteralPath $statePath -Encoding UTF8 -Raw | ConvertFrom-Json
        if ($state.tasks) { $stateTasks = @($state.tasks) }
        Write-Host "State: $statePath"
        if ($state.updatedAt) { Write-Host "State updated: $($state.updatedAt)" }
        Write-Host ""
    }
    catch {
        Write-Host "State file exists but could not be parsed: $statePath"
        Write-Host ""
    }
}

if (Test-Path -LiteralPath $runsPath) {
    try {
        $runState = Get-Content -LiteralPath $runsPath -Encoding UTF8 -Raw | ConvertFrom-Json
        if ($runState.runs) { $runs = @($runState.runs) }
    }
    catch {
        Write-Host "Run state exists but could not be parsed: $runsPath"
        Write-Host ""
    }
}

function Get-LatestRunForTask {
    param(
        [string]$TaskId
    )

    if (-not $runs -or -not $TaskId) { return $null }

    return $runs |
        Where-Object { $_.task_id -eq $TaskId } |
        Sort-Object @{ Expression = { if ($_.finished_at) { $_.finished_at } else { $_.started_at } }; Descending = $true } |
        Select-Object -First 1
}

function Get-TaskById {
    param(
        [array]$Tasks,
        [string]$TaskId
    )

    if (-not $Tasks -or -not $TaskId) { return $null }
    return $Tasks | Where-Object { $_.task_id -eq $TaskId } | Select-Object -First 1
}

function Test-DependenciesDone {
    param(
        [array]$Tasks,
        [object]$Task
    )

    $dependencies = @($Task.dependencies | Where-Object { $_ })
    if ($dependencies.Count -eq 0) { return $true }

    foreach ($dependencyId in $dependencies) {
        $dependency = Get-TaskById $Tasks $dependencyId
        if (-not $dependency) { return $false }
        if ("$($dependency.status)".ToLowerInvariant() -ne "done") { return $false }
    }
    return $true
}

function Get-BlockedDependencies {
    param(
        [array]$Tasks,
        [object]$Task
    )

    $blocked = @()
    foreach ($dependencyId in @($Task.dependencies | Where-Object { $_ })) {
        $dependency = Get-TaskById $Tasks $dependencyId
        if (-not $dependency) {
            $blocked += "$dependencyId (missing)"
        }
        elseif ("$($dependency.status)".ToLowerInvariant() -ne "done") {
            $blocked += "$dependencyId [$($dependency.status)]"
        }
    }
    return $blocked
}

function Get-RecommendedAction {
    param(
        [array]$Tasks
    )

    if (-not $Tasks -or $Tasks.Count -eq 0) { return $null }

    foreach ($task in $Tasks) {
        $status = "$($task.status)".ToLowerInvariant()
        $lastResult = "$($task.last_result)".ToLowerInvariant()
        $verification = "$($task.verification_status)".ToLowerInvariant()
        if ($status -eq "blocked" -or $lastResult -in @("failed", "blocked") -or $verification -eq "failed") {
            return [ordered]@{
                task_id = $task.task_id
                action = "fix"
                reason = "Task has blocked or failed evidence."
            }
        }
    }

    foreach ($task in $Tasks) {
        $status = "$($task.status)".ToLowerInvariant()
        if ($status -eq "review" -and (Test-DependenciesDone $Tasks $task)) {
            return [ordered]@{
                task_id = $task.task_id
                action = "review"
                reason = "Task is waiting for Reviewer/Verifier."
            }
        }
    }

    foreach ($task in $Tasks) {
        $status = "$($task.status)".ToLowerInvariant()
        if ($status -in @("planned", "in_progress", "unknown") -and (Test-DependenciesDone $Tasks $task)) {
            return [ordered]@{
                task_id = $task.task_id
                action = "execute"
                reason = "Dependencies are done and task is not complete."
            }
        }
    }

    foreach ($task in $Tasks) {
        $status = "$($task.status)".ToLowerInvariant()
        if ($status -ne "done") {
            $blocked = Get-BlockedDependencies $Tasks $task
            return [ordered]@{
                task_id = $task.task_id
                action = "wait"
                reason = if ($blocked.Count -gt 0) { "Waiting on dependencies: $($blocked -join ', ')." } else { "Task is not done but no safe next action was inferred." }
            }
        }
    }

    return $null
}

$taskFiles = Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" |
    Where-Object { $_.Name -ne "TEMPLATE.md" } |
    Sort-Object Name

if ($stateTasks.Count -gt 0) {
    Write-Host "Tasks:"
    foreach ($task in $stateTasks) {
        Write-Host ("- {0} [{1}] {2}" -f $task.task_id, $task.status, $task.title)
        if ($task.work_mode) { Write-Host ("  Work mode: {0}" -f $task.work_mode) }
        if ($task.business) { Write-Host ("  Business: {0}" -f $task.business) }
        if ($task.dependencies -and @($task.dependencies).Count -gt 0) {
            Write-Host ("  Dependencies: {0}" -f (@($task.dependencies) -join ", "))
        }
        if ($task.verification_status -or $task.last_run_id -or $task.last_result) {
            Write-Host ("  Evidence: verification={0}; last_run={1}; result={2}" -f $task.verification_status, $task.last_run_id, $task.last_result)
        }
        $latestRun = Get-LatestRunForTask $task.task_id
        if ($latestRun) {
            Write-Host ("  Latest run: {0} role={1}; status={2}" -f $latestRun.run_id, $latestRun.role, $latestRun.status)
            if ($latestRun.blocked_reason) { Write-Host ("  Blocked: {0}" -f $latestRun.blocked_reason) }
        }
        if ($task.branch -or $task.github_issue -or $task.github_pr -or $task.ci_status) {
            Write-Host ("  GitHub: branch={0}; issue={1}; pr={2}; ci={3}" -f $task.branch, $task.github_issue, $task.github_pr, $task.ci_status)
        }
    }
}
elseif (-not $taskFiles) {
    Write-Host "No task cards found."
}
else {
    Write-Host "Tasks:"
    foreach ($file in $taskFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
        $status = "unknown"
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $business = ""

        if ($content -match "(?m)^status:[ \t]*[""']?([^""'\r\n]+)") {
            $status = $Matches[1].Trim()
        }
        elseif ($content -match "(?m)^-\s*Status:\s*`?([^`\r\n]+)`?") {
            $status = $Matches[1].Trim()
        }

        if ($content -match "(?m)^title:[ \t]*[""']?([^""'\r\n]+)") {
            $title = $Matches[1].Trim()
        }

        if ($content -match "(?s)## Business Meaning\s+(.+?)(\r?\n## |\z)") {
            $business = (($Matches[1] -replace "\s+", " ").Trim())
        }
        elseif ($content -match "(?s)## Goal\s+(.+?)(\r?\n## |\z)") {
            $business = (($Matches[1] -replace "\s+", " ").Trim())
        }

        Write-Host ("- {0} [{1}] {2}" -f $file.BaseName, $status, $title)
        if ($business) {
            Write-Host ("  Business: {0}" -f $business)
        }
    }
}

Write-Host ""
Write-Host "Suggested next action:"

$recommendation = $null
if ($stateTasks.Count -gt 0) {
    $recommendation = Get-RecommendedAction $stateTasks
}
else {
foreach ($file in $taskFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
    $status = "unknown"
    if ($content -match "(?m)^status:[ \t]*[""']?([^""'\r\n]+)") {
        $status = $Matches[1].Trim().ToLowerInvariant()
    }
    elseif ($content -match "(?m)^-\s*Status:\s*`?([^`\r\n]+)`?") {
        $status = $Matches[1].Trim().ToLowerInvariant()
    }

    if ($status -ne "done") {
        $recommendation = [ordered]@{
            task_id = $file.BaseName
            action = "inspect"
            reason = "Task state has not been synced yet."
        }
        break
    }
}
}

if ($recommendation) {
    Write-Host ("{0}: {1}" -f $recommendation.action, $recommendation.task_id)
    Write-Host ("Reason: {0}" -f $recommendation.reason)
}
else {
    Write-Host "All known task cards are done. Run review/integration or create the next task card."
}

Write-Host ""
Write-Host "Git status:"
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
