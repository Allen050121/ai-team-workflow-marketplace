$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tasksDir = Join-Path $ProjectRoot ".ai-team\tasks"
$statePath = Join-Path $ProjectRoot ".ai-team\state\tasks.json"

if (-not (Test-Path -LiteralPath $tasksDir)) {
    throw "Missing tasks directory: $tasksDir"
}

Write-Host "AI Team Status"
Write-Host "Project: $ProjectRoot"
Write-Host ""

$stateTasks = @()
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

$taskFiles = Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" |
    Where-Object { $_.Name -ne "TEMPLATE.md" } |
    Sort-Object Name

if ($stateTasks.Count -gt 0) {
    Write-Host "Tasks:"
    foreach ($task in $stateTasks) {
        Write-Host ("- {0} [{1}] {2}" -f $task.task_id, $task.status, $task.title)
        if ($task.business) { Write-Host ("  Business: {0}" -f $task.business) }
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

        if ($content -match "(?m)^status:\s*[""']?([^""'\r\n]+)") {
            $status = $Matches[1].Trim()
        }
        elseif ($content -match "(?m)^-\s*Status:\s*`?([^`\r\n]+)`?") {
            $status = $Matches[1].Trim()
        }

        if ($content -match "(?m)^title:\s*[""']?([^""'\r\n]+)") {
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

$next = $null
if ($stateTasks.Count -gt 0) {
    foreach ($task in $stateTasks) {
        $status = "$($task.status)".ToLowerInvariant()
        if ($status -ne "done") {
            $next = $task.task_id
            break
        }
    }
}
else {
foreach ($file in $taskFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
    $status = "unknown"
    if ($content -match "(?m)^status:\s*[""']?([^""'\r\n]+)") {
        $status = $Matches[1].Trim().ToLowerInvariant()
    }
    elseif ($content -match "(?m)^-\s*Status:\s*`?([^`\r\n]+)`?") {
        $status = $Matches[1].Trim().ToLowerInvariant()
    }

    if ($status -ne "done") {
        $next = $file.BaseName
        break
    }
}
}

if ($next) {
    Write-Host "Continue with task: $next"
}
else {
    Write-Host "All known task cards are done. Run review/integration or create the next task card."
}

Write-Host ""
Write-Host "Git status:"
git -C $ProjectRoot status --short
