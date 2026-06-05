param(
    [string]$TaskId,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tasksPath = Join-Path $ProjectRoot ".ai-team\state\tasks.json"
$runsPath = Join-Path $ProjectRoot ".ai-team\state\runs.json"

function Read-JsonFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    return Get-Content -LiteralPath $Path -Encoding UTF8 -Raw | ConvertFrom-Json
}

function Get-RunsForTask {
    param(
        [array]$Runs,
        [string]$TaskId
    )

    if (-not $Runs -or -not $TaskId) { return @() }
    return @($Runs | Where-Object { $_.task_id -eq $TaskId })
}

function Test-HasRun {
    param(
        [array]$Runs,
        [string]$Role,
        [string[]]$Statuses = @("passed", "waived")
    )

    return @($Runs | Where-Object { $_.role -eq $Role -and $_.status -in $Statuses }).Count -gt 0
}

function Test-HasVerification {
    param([array]$Runs)

    return @($Runs | Where-Object { $_.verification -and @($_.verification).Count -gt 0 -and $_.status -in @("passed", "waived") }).Count -gt 0
}

$taskState = Read-JsonFile $tasksPath
$runState = Read-JsonFile $runsPath
$runs = @()
if ($runState -and $runState.runs) { $runs = @($runState.runs) }

$tasks = @()
if ($taskState -and $taskState.tasks) { $tasks = @($taskState.tasks) }
if ($TaskId) { $tasks = @($tasks | Where-Object { $_.task_id -eq $TaskId }) }

$findings = New-Object System.Collections.Generic.List[object]

foreach ($task in $tasks) {
    $status = "$($task.status)".ToLowerInvariant()
    $workflowMode = "$($task.workflow_mode)".ToLowerInvariant()
    $taskRuns = Get-RunsForTask $runs $task.task_id
    $hasExecutorEvidence = Test-HasRun $taskRuns "executor"
    $hasReviewerEvidence = Test-HasRun $taskRuns "reviewer"
    $hasIntegrationEvidence = Test-HasRun $taskRuns "integration"
    $hasVerification = Test-HasVerification $taskRuns

    if ($status -eq "review" -and -not $hasExecutorEvidence) {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "error"
            message = "Task is in review without passed or waived executor evidence."
        }) | Out-Null
    }

    if ($status -eq "done" -and -not $hasExecutorEvidence) {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "error"
            message = "Task is done without executor evidence."
        }) | Out-Null
    }

    if ($status -eq "done" -and -not $hasReviewerEvidence) {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "error"
            message = "Task is done without reviewer evidence."
        }) | Out-Null
    }

    if ($status -in @("review", "done") -and -not $hasVerification) {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "warning"
            message = "Task is review/done without recorded verification."
        }) | Out-Null
    }

    if ($workflowMode -eq "strict" -and $status -eq "done" -and -not $hasIntegrationEvidence) {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "error"
            message = "Strict task is done without integration evidence or explicit waiver."
        }) | Out-Null
    }

    if ($task.last_result -in @("failed", "blocked") -and $status -eq "done") {
        $findings.Add([ordered]@{
            task_id = $task.task_id
            severity = "error"
            message = "Task is done but last_result is failed or blocked."
        }) | Out-Null
    }
}

$status = "passed"
if (@($findings | Where-Object { $_.severity -eq "error" }).Count -gt 0) {
    $status = "failed"
}
elseif ($findings.Count -gt 0) {
    $status = "warning"
}

$findingItems = @($findings | ForEach-Object { $_ })

$result = [ordered]@{
    version = 1
    status = $status
    task_id = $TaskId
    findings = $findingItems
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
}
else {
    Write-Host "AI Team state machine check"
    Write-Host "Status: $status"
    foreach ($finding in $findings) {
        Write-Host ("- [{0}] {1}: {2}" -f $finding.severity, $finding.task_id, $finding.message)
    }
}

if ($status -eq "failed") {
    exit 1
}
