param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,

    [ValidateSet("dispatcher", "executor", "reviewer", "integration", "memory")]
    [string]$Role = "executor",

    [ValidateSet("started", "passed", "failed", "blocked", "waived")]
    [string]$Status = "passed",

    [string[]]$ChangedFiles = @(),

    [string[]]$Verification = @(),

    [string[]]$HumanDecisions = @(),

    [string]$BlockedReason = "",

    [string[]]$Followups = @(),

    [string]$RunId
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$stateDir = Join-Path $ProjectRoot ".ai-team\state"
$runsPath = Join-Path $stateDir "runs.json"

New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

if (-not $RunId) {
    $safeTaskId = $TaskId -replace "[^a-zA-Z0-9._-]", "-"
    $RunId = "{0}-{1}-{2}" -f $safeTaskId, $Role, (Get-Date -Format "yyyyMMddHHmmss")
}

if (Test-Path -LiteralPath $runsPath) {
    try {
        $state = Get-Content -LiteralPath $runsPath -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    catch {
        throw "Run state exists but could not be parsed: $runsPath"
    }
}
else {
    $state = [pscustomobject]@{
        version = 1
        runs = @()
        updatedAt = $null
    }
}

$runs = @()
if ($state.runs) {
    $runs = @($state.runs)
}

$now = (Get-Date).ToString("o")
$existing = $runs | Where-Object { $_.run_id -eq $RunId } | Select-Object -First 1

$run = [ordered]@{
    run_id = $RunId
    task_id = $TaskId
    role = $Role
    status = $Status
    started_at = $now
    finished_at = $now
    changed_files = @($ChangedFiles)
    verification = @($Verification)
    human_decisions = @($HumanDecisions)
    blocked_reason = $BlockedReason
    followups = @($Followups)
}

if ($existing) {
    if ($existing.started_at) {
        $run.started_at = $existing.started_at
    }
    $runs = @($runs | Where-Object { $_.run_id -ne $RunId })
}

$runs += [pscustomobject]$run

$newState = [ordered]@{
    version = 1
    updatedAt = $now
    runs = $runs
}

$json = $newState | ConvertTo-Json -Depth 10
Set-Content -LiteralPath $runsPath -Encoding UTF8 -Value $json
Write-Host "Updated run evidence: $runsPath"
Write-Host "Run ID: $RunId"
