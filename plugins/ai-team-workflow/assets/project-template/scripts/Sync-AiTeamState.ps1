$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tasksDir = Join-Path $ProjectRoot ".ai-team\tasks"
$stateDir = Join-Path $ProjectRoot ".ai-team\state"
$statePath = Join-Path $stateDir "tasks.json"

if (-not (Test-Path -LiteralPath $tasksDir)) {
    throw "Missing tasks directory: $tasksDir"
}

New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

function Get-Field {
    param(
        [string]$Content,
        [string]$Name
    )

    if ($Content -match ("(?m)^" + [regex]::Escape($Name) + ":\s*[""']?([^""'\r\n]*)")) {
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

$tasks = @()
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

    $branch = Get-Field $content "branch"
    $githubIssue = Get-Field $content "github_issue"
    $githubPr = Get-Field $content "github_pr"
    $ciStatus = Get-Field $content "ci_status"
    $business = Get-SectionSummary $content "Business Meaning"
    if (-not $business) { $business = Get-SectionSummary $content "Goal" }

    $tasks += [ordered]@{
        task_id = $taskId
        title = $title
        status = $status
        mode = $mode
        branch = $branch
        github_issue = $githubIssue
        github_pr = $githubPr
        ci_status = $ciStatus
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
