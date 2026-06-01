$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tasksDir = Join-Path $ProjectRoot ".ai-team\tasks"
$stateDir = Join-Path $ProjectRoot ".ai-team\state"
$statePath = Join-Path $stateDir "tasks.json"
$runsPath = Join-Path $stateDir "runs.json"

if (-not (Test-Path -LiteralPath $tasksDir)) {
    throw "Missing tasks directory: $tasksDir"
}

New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

function Get-Field {
    param(
        [string]$Content,
        [string]$Name
    )

    if ($Content -match ("(?m)^" + [regex]::Escape($Name) + ":[ \t]*[""']?([^""'\r\n]*)")) {
        return $Matches[1].Trim()
    }
    return $null
}

function Get-SectionSummary {
    param(
        [string]$Content,
        [string]$Heading
    )

    if ($Content -match ("(?s)## " + [regex]::Escape($Heading) + "\s+(.+?)(\r?\n## |\z)")) {
        return (($Matches[1] -replace "\s+", " ").Trim())
    }
    return ""
}

function Get-ListField {
    param(
        [string]$Content,
        [string]$Name
    )

    $value = Get-Field $Content $Name
    if (-not $value) { return @() }

    return @($value -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Get-LatestRun {
    param(
        [array]$Runs,
        [string]$TaskId
    )

    if (-not $Runs -or -not $TaskId) { return $null }

    return $Runs |
        Where-Object { $_.task_id -eq $TaskId } |
        Sort-Object @{ Expression = { if ($_.finished_at) { $_.finished_at } else { $_.started_at } }; Descending = $true } |
        Select-Object -First 1
}

$tasks = @()
$runs = @()
if (Test-Path -LiteralPath $runsPath) {
    try {
        $runsState = Get-Content -LiteralPath $runsPath -Encoding UTF8 -Raw | ConvertFrom-Json
        if ($runsState.runs) { $runs = @($runsState.runs) }
    }
    catch {
        Write-Host "Run state exists but could not be parsed: $runsPath"
    }
}

$taskFiles = Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" |
    Where-Object { $_.Name -ne "TEMPLATE.md" } |
    Sort-Object Name

foreach ($file in $taskFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
    $taskId = Get-Field $content "task_id"
    if (-not $taskId) { $taskId = $file.BaseName }

    $title = Get-Field $content "title"
    if (-not $title) { $title = $file.BaseName }

    $status = Get-Field $content "status"
    if (-not $status) { $status = "unknown" }

    $mode = Get-Field $content "mode"
    if (-not $mode) { $mode = "serial" }

    $workMode = Get-Field $content "work_mode"
    if (-not $workMode) { $workMode = "MVP" }

    $branch = Get-Field $content "branch"
    $githubIssue = Get-Field $content "github_issue"
    $githubPr = Get-Field $content "github_pr"
    $ciStatus = Get-Field $content "ci_status"
    $dependencies = Get-ListField $content "dependencies"
    $verificationStatus = Get-Field $content "verification_status"
    $lastRunId = Get-Field $content "last_run_id"
    $lastResult = Get-Field $content "last_result"
    $blockedReason = Get-Field $content "blocked_reason"
    $business = Get-SectionSummary $content "Business Meaning"
    if (-not $business) { $business = Get-SectionSummary $content "Goal" }

    $latestRun = Get-LatestRun $runs $taskId
    if ($latestRun) {
        if (-not $lastRunId) { $lastRunId = $latestRun.run_id }
        if (-not $lastResult) { $lastResult = $latestRun.status }
        if ($latestRun.blocked_reason -and -not $blockedReason) {
            $blockedReason = $latestRun.blocked_reason
        }
        if ((-not $verificationStatus) -or $verificationStatus -eq "not_run") {
            if ($latestRun.verification -and @($latestRun.verification).Count -gt 0) {
                $verificationStatus = $latestRun.status
            }
            else {
                $verificationStatus = "not_recorded"
            }
        }
    }

    if (-not $verificationStatus) { $verificationStatus = "not_run" }

    $tasks += [ordered]@{
        task_id = $taskId
        title = $title
        status = $status
        mode = $mode
        work_mode = $workMode
        branch = $branch
        github_issue = $githubIssue
        github_pr = $githubPr
        ci_status = $ciStatus
        dependencies = @($dependencies)
        last_run_id = $lastRunId
        last_result = $lastResult
        blocked_reason = $blockedReason
        verification_status = $verificationStatus
        updated_at = (Get-Date).ToString("o")
        business = $business
        task_card = ".ai-team/tasks/$($file.Name)"
    }
}

$state = [ordered]@{
    version = 1
    updatedAt = (Get-Date).ToString("o")
    tasks = $tasks
}

$json = $state | ConvertTo-Json -Depth 8
Set-Content -LiteralPath $statePath -Encoding UTF8 -Value $json
Write-Host "Synced task state: $statePath"
