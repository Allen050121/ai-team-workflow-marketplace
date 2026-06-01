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

if (-not $WorktreePath) {
    $WorktreePath = $ProjectRoot
}

$WorktreePath = (Resolve-Path $WorktreePath).Path
$taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"

if (-not (Test-Path -LiteralPath $taskPath)) {
    throw "Missing task card: $taskPath"
}

function Convert-ToRepoPath {
    param([string]$Path)

    return ($Path -replace "\\", "/").Trim()
}

function Get-AllowedBoundary {
    param([string]$TaskCardPath)

    $content = Get-Content -LiteralPath $TaskCardPath -Raw -Encoding UTF8
    $match = [regex]::Match($content, "(?ms)^### Allowed To Modify\s*(?<body>.*?)(?:^### |^## |\z)")
    if (-not $match.Success) { return @() }

    return @(
        $match.Groups["body"].Value -split "\r?\n" |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -match "^\-\s+\S" } |
            ForEach-Object {
                ($_ -replace "^\-\s+", "").Trim(" `t`r`n")
            } |
            Where-Object {
                $_ -and
                $_ -notmatch "Dispatcher must fill this in" -and
                $_ -notmatch "TODO" -and
                $_ -notmatch "^\$_$"
            } |
            ForEach-Object { Convert-ToRepoPath $_ }
    )
}

function Convert-BoundaryToRegex {
    param([string]$Boundary)

    $boundary = Convert-ToRepoPath $Boundary
    $boundary = $boundary -replace "^\./", ""
    $boundary = $boundary.Trim("/")

    if (-not $boundary) { return $null }

    if ($boundary.EndsWith("/**")) {
        $prefix = [regex]::Escape($boundary.Substring(0, $boundary.Length - 3).TrimEnd("/"))
        return "^$prefix(/.*)?$"
    }

    if ($boundary.EndsWith("/")) {
        $prefix = [regex]::Escape($boundary.TrimEnd("/"))
        return "^$prefix(/.*)?$"
    }

    if ($boundary -notmatch "[\*\?]") {
        $exact = [regex]::Escape($boundary)
        return "^$exact$"
    }

    $placeholder = "___AI_TEAM_DOUBLE_STAR___"
    $pattern = [regex]::Escape($boundary)
    $pattern = $pattern.Replace("\*\*", $placeholder)
    $pattern = $pattern.Replace("\*", "[^/]*")
    $pattern = $pattern.Replace("\?", "[^/]")
    $pattern = $pattern.Replace($placeholder, ".*")
    return "^$pattern$"
}

function Test-PathAllowed {
    param(
        [string]$Path,
        [string[]]$Regexes
    )

    $normalized = Convert-ToRepoPath $Path
    foreach ($regex in $Regexes) {
        if ($normalized -match $regex) { return $true }
    }
    return $false
}

$allowed = @(Get-AllowedBoundary $taskPath)
$regexes = @($allowed | ForEach-Object { Convert-BoundaryToRegex $_ } | Where-Object { $_ })

$changedFiles = @()
$ignoredFiles = @()
try {
    $changedFiles = @(git -C $WorktreePath diff --name-only $BaseRef -- | ForEach-Object { Convert-ToRepoPath $_ } | Where-Object { $_ })
    $untrackedFiles = @(git -C $WorktreePath ls-files --others --exclude-standard | ForEach-Object { Convert-ToRepoPath $_ } | Where-Object { $_ })
    $changedFiles = @($changedFiles + $untrackedFiles | Sort-Object -Unique)
    if (-not $IncludeAiTeam) {
        $ignoredFiles = @($changedFiles | Where-Object { $_ -match "^\.ai-team/" })
        $changedFiles = @($changedFiles | Where-Object { $_ -notmatch "^\.ai-team/" })
    }
}
catch {
    throw "Unable to read git diff from $WorktreePath against $BaseRef`: $($_.Exception.Message)"
}

$outOfBoundary = @()
if ($changedFiles.Count -gt 0) {
    foreach ($file in $changedFiles) {
        if (-not (Test-PathAllowed $file $regexes)) {
            $outOfBoundary += $file
        }
    }
}

$status = "passed"
$message = "All changed files are within task boundaries."

if ($allowed.Count -eq 0) {
    $status = "failed"
    $message = "Task card has no concrete Allowed To Modify entries."
    $outOfBoundary = $changedFiles
}
elseif ($outOfBoundary.Count -gt 0) {
    $status = "failed"
    $message = "Changed files exceed task Allowed To Modify boundaries."
}

$result = [ordered]@{
    version = 1
    task_id = $TaskId
    worktree = "$WorktreePath"
    base_ref = $BaseRef
    status = $status
    message = $message
    allowed = @($allowed)
    changed_files = @($changedFiles)
    ignored_files = @($ignoredFiles)
    out_of_boundary = @($outOfBoundary)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
}
else {
    Write-Host "AI Team diff boundary check"
    Write-Host "Task: $TaskId"
    Write-Host "Worktree: $WorktreePath"
    Write-Host "Base ref: $BaseRef"
    Write-Host "Status: $status"
    Write-Host $message
    Write-Host ""
    Write-Host "Allowed:"
    foreach ($item in $allowed) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Changed files:"
    foreach ($file in $changedFiles) { Write-Host "- $file" }
    if ($ignoredFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "Ignored workflow files:"
        foreach ($file in $ignoredFiles) { Write-Host "- $file" }
    }
    if ($outOfBoundary.Count -gt 0) {
        Write-Host ""
        Write-Host "Out of boundary:"
        foreach ($file in $outOfBoundary) { Write-Host "- $file" }
    }
}

if ($status -ne "passed") {
    exit 1
}
