param(
    [switch]$Json,
    [int]$MemoryWarnChars = 6000,
    [int]$TaskWarnChars = 8000,
    [int]$RepoMapWarnChars = 12000,
    [int]$RunsWarnChars = 20000
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$aiTeamRoot = Join-Path $ProjectRoot ".ai-team"

function Measure-File {
    param(
        [string]$RelativePath,
        [int]$WarnChars,
        [string]$Kind
    )

    $path = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        return [ordered]@{
            path = $RelativePath
            kind = $Kind
            exists = $false
            chars = 0
            lines = 0
            status = "missing"
            warning = "Missing file."
        }
    }

    $content = Get-Content -LiteralPath $path -Encoding UTF8 -Raw
    $lines = if ($content.Length -eq 0) { 0 } else { @($content -split "\r?\n").Count }
    $status = if ($content.Length -gt $WarnChars) { "warning" } else { "ok" }
    $warning = if ($status -eq "warning") { "Exceeds suggested context budget of $WarnChars chars." } else { "" }

    return [ordered]@{
        path = $RelativePath
        kind = $Kind
        exists = $true
        chars = $content.Length
        lines = $lines
        status = $status
        warning = $warning
    }
}

$items = New-Object System.Collections.Generic.List[object]

foreach ($file in @(
    ".ai-team/memory/human-lead.md",
    ".ai-team/memory/project-brief.md",
    ".ai-team/memory/production-mode.md",
    ".ai-team/memory/technology-policy.md",
    ".ai-team/memory/pitfalls.md",
    ".ai-team/memory/patterns.md"
)) {
    $items.Add((Measure-File $file $MemoryWarnChars "memory")) | Out-Null
}

$items.Add((Measure-File ".ai-team/index/repo-map.md" $RepoMapWarnChars "repo_map")) | Out-Null
$items.Add((Measure-File ".ai-team/state/runs.json" $RunsWarnChars "run_state")) | Out-Null

$tasksDir = Join-Path $aiTeamRoot "tasks"
if (Test-Path -LiteralPath $tasksDir) {
    foreach ($task in Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" | Where-Object { $_.Name -ne "TEMPLATE.md" }) {
        $relative = ".ai-team/tasks/$($task.Name)"
        $items.Add((Measure-File $relative $TaskWarnChars "task")) | Out-Null
    }
}

$itemArray = @($items | ForEach-Object { $_ })
$totalChars = 0
foreach ($item in $itemArray) {
    $totalChars += [int]$item.chars
}

$warnings = @($itemArray | Where-Object { $_.status -eq "warning" -or $_.status -eq "missing" })
$status = if ($warnings.Count -gt 0) { "warning" } else { "ok" }

$recommendations = New-Object System.Collections.Generic.List[string]
if (@($itemArray | Where-Object { $_.kind -eq "run_state" -and $_.status -eq "warning" }).Count -gt 0) {
    $recommendations.Add("Archive or summarize old run evidence before adding it to context.") | Out-Null
}
if (@($itemArray | Where-Object { $_.kind -eq "memory" -and $_.status -eq "warning" }).Count -gt 0) {
    $recommendations.Add("Compress memory files to durable facts, pitfalls, and reusable patterns.") | Out-Null
}
if (@($itemArray | Where-Object { $_.kind -eq "repo_map" -and $_.status -eq "warning" }).Count -gt 0) {
    $recommendations.Add("Regenerate or trim repo-map to high-signal structure only.") | Out-Null
}
if (@($itemArray | Where-Object { $_.kind -eq "task" -and $_.status -eq "warning" }).Count -gt 0) {
    $recommendations.Add("Split oversized task cards or move raw notes out of the task card.") | Out-Null
}

$result = [ordered]@{
    version = 1
    status = $status
    total_chars = $totalChars
    estimated_tokens = [math]::Ceiling($totalChars / 4)
    budgets = [ordered]@{
        memory_warn_chars = $MemoryWarnChars
        task_warn_chars = $TaskWarnChars
        repo_map_warn_chars = $RepoMapWarnChars
        runs_warn_chars = $RunsWarnChars
    }
    items = $itemArray
    recommendations = @($recommendations)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 8
}
else {
    Write-Host "AI Team context budget"
    Write-Host ("Status: {0}" -f $status)
    Write-Host ("Estimated loaded text: {0} chars (~{1} tokens)" -f $totalChars, $result.estimated_tokens)
    Write-Host ""
    foreach ($item in $itemArray) {
        Write-Host ("- [{0}] {1}: {2} chars, {3} lines" -f $item.status, $item.path, $item.chars, $item.lines)
        if ($item.warning) { Write-Host ("  {0}" -f $item.warning) }
    }
    if ($recommendations.Count -gt 0) {
        Write-Host ""
        Write-Host "Recommendations:"
        foreach ($recommendation in $recommendations) {
            Write-Host ("- {0}" -f $recommendation)
        }
    }
}
