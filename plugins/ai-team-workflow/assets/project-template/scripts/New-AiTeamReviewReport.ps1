param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,

    [string]$WorktreePath,

    [string]$BaseRef = "HEAD",

    [switch]$IncludeAiTeam,

    [switch]$Json
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
if (-not $WorktreePath) { $WorktreePath = $ProjectRoot }
$WorktreePath = (Resolve-Path $WorktreePath).Path

$taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"
$runsPath = Join-Path $ProjectRoot ".ai-team\state\runs.json"
$tasksPath = Join-Path $ProjectRoot ".ai-team\state\tasks.json"

if (-not (Test-Path -LiteralPath $taskPath)) {
    throw "Missing task card: $taskPath"
}

function Get-Field {
    param(
        [string]$Content,
        [string]$Name
    )

    if ($Content -match ("(?m)^" + [regex]::Escape($Name) + ":[ \t]*[""']?([^""'\r\n]*)")) {
        return $Matches[1].Trim()
    }
    return ""
}

function Read-JsonFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    return Get-Content -LiteralPath $Path -Encoding UTF8 -Raw | ConvertFrom-Json
}

function Get-LatestRun {
    param(
        [array]$Runs,
        [string]$TaskId,
        [string]$Role
    )

    return $Runs |
        Where-Object { $_.task_id -eq $TaskId -and (-not $Role -or $_.role -eq $Role) } |
        Sort-Object @{ Expression = { if ($_.finished_at) { $_.finished_at } else { $_.started_at } }; Descending = $true } |
        Select-Object -First 1
}

function Get-GitChangedFiles {
    param(
        [string]$Path,
        [string]$BaseRef,
        [bool]$IncludeAiTeam
    )

    $diffFiles = @(git -C $Path diff --name-only $BaseRef -- | Where-Object { $_ })
    $untracked = @(git -C $Path ls-files --others --exclude-standard | Where-Object { $_ })
    $files = @($diffFiles + $untracked | Sort-Object -Unique)
    if (-not $IncludeAiTeam) {
        $files = @($files | Where-Object { $_ -notmatch "^\.ai-team[\\/]" })
    }
    return $files
}

$taskContent = Get-Content -LiteralPath $taskPath -Encoding UTF8 -Raw
$task = [ordered]@{
    task_id = $TaskId
    title = Get-Field $taskContent "title"
    status = Get-Field $taskContent "status"
    mode = Get-Field $taskContent "mode"
    work_mode = Get-Field $taskContent "work_mode"
    workflow_mode = Get-Field $taskContent "workflow_mode"
}

$runState = Read-JsonFile $runsPath
$runs = @()
if ($runState -and $runState.runs) { $runs = @($runState.runs) }

$taskState = Read-JsonFile $tasksPath
$stateTask = $null
if ($taskState -and $taskState.tasks) {
    $stateTask = @($taskState.tasks | Where-Object { $_.task_id -eq $TaskId } | Select-Object -First 1)
}

$changedFiles = Get-GitChangedFiles $WorktreePath $BaseRef $IncludeAiTeam.IsPresent
$latestExecutor = Get-LatestRun $runs $TaskId "executor"
$latestReviewer = Get-LatestRun $runs $TaskId "reviewer"
$latestIntegration = Get-LatestRun $runs $TaskId "integration"

$boundaryResult = $null
$boundaryScript = Join-Path $ProjectRoot ".ai-team\scripts\Test-AiTeamDiffBoundary.ps1"
if (Test-Path -LiteralPath $boundaryScript) {
    $boundaryJson = powershell -NoProfile -ExecutionPolicy Bypass -File $boundaryScript -TaskId $TaskId -WorktreePath $WorktreePath -BaseRef $BaseRef -Json 2>$null
    if ($boundaryJson) {
        $boundaryResult = $boundaryJson | ConvertFrom-Json
    }
}

$stateMachineResult = $null
$stateMachineScript = Join-Path $ProjectRoot ".ai-team\scripts\Test-AiTeamStateMachine.ps1"
if (Test-Path -LiteralPath $stateMachineScript) {
    $stateMachineJson = powershell -NoProfile -ExecutionPolicy Bypass -File $stateMachineScript -TaskId $TaskId -Json 2>$null
    if ($stateMachineJson) {
        $stateMachineResult = $stateMachineJson | ConvertFrom-Json
    }
}

$warnings = New-Object System.Collections.Generic.List[string]
$blocking = New-Object System.Collections.Generic.List[string]

if (-not $latestExecutor) { $warnings.Add("No executor run evidence found.") | Out-Null }
if ($latestExecutor -and -not $latestExecutor.verification) { $warnings.Add("Latest executor run has no verification entries.") | Out-Null }
if ($boundaryResult -and $boundaryResult.status -ne "passed") { $blocking.Add("Diff boundary check failed.") | Out-Null }
if ($stateMachineResult -and $stateMachineResult.status -eq "failed") { $blocking.Add("State machine check failed.") | Out-Null }
if ($task.workflow_mode -eq "strict" -and -not $latestIntegration) { $warnings.Add("Strict task has no integration evidence yet.") | Out-Null }

$decision = "pass"
if ($blocking.Count -gt 0) {
    $decision = "blocked"
}
elseif ($warnings.Count -gt 0) {
    $decision = "request_changes"
}

$report = [ordered]@{
    version = 1
    task = $task
    state_task = $stateTask
    worktree = $WorktreePath
    base_ref = $BaseRef
    changed_files = @($changedFiles)
    boundary_check = $boundaryResult
    state_machine = $stateMachineResult
    latest_runs = [ordered]@{
        executor = $latestExecutor
        reviewer = $latestReviewer
        integration = $latestIntegration
    }
    warnings = @($warnings)
    blocking = @($blocking)
    recommended_decision = $decision
}

if ($Json) {
    $report | ConvertTo-Json -Depth 12
}
else {
    Write-Host "AI Team review report"
    Write-Host ("Task: {0} - {1}" -f $TaskId, $task.title)
    Write-Host ("Status: {0}; work_mode: {1}; workflow_mode: {2}" -f $task.status, $task.work_mode, $task.workflow_mode)
    Write-Host ("Recommended decision: {0}" -f $decision)
    Write-Host ""
    Write-Host "Changed files:"
    foreach ($file in $changedFiles) { Write-Host ("- {0}" -f $file) }
    Write-Host ""
    if ($boundaryResult) { Write-Host ("Boundary check: {0} - {1}" -f $boundaryResult.status, $boundaryResult.message) }
    if ($stateMachineResult) { Write-Host ("State machine: {0}" -f $stateMachineResult.status) }
    Write-Host ""
    Write-Host "Latest evidence:"
    foreach ($role in @("executor", "reviewer", "integration")) {
        $run = $report.latest_runs[$role]
        if ($run) {
            Write-Host ("- {0}: {1} ({2})" -f $role, $run.status, $run.run_id)
        }
        else {
            Write-Host ("- {0}: missing" -f $role)
        }
    }
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:"
        foreach ($warning in $warnings) { Write-Host ("- {0}" -f $warning) }
    }
    if ($blocking.Count -gt 0) {
        Write-Host ""
        Write-Host "Blocking:"
        foreach ($item in $blocking) { Write-Host ("- {0}" -f $item) }
    }
}
