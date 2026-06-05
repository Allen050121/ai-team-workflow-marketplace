param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,

    [string]$Branch,

    [string]$BaseRef = "HEAD",

    [string]$WorktreeRoot
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

if ($TaskId -notmatch "^[a-z0-9][a-z0-9._-]*$") {
    throw "Task id must use lowercase letters, numbers, dot, underscore, or hyphen, and must start with a letter or number."
}

$taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"
if (-not (Test-Path -LiteralPath $taskPath)) {
    throw "Missing task card: $taskPath"
}

$repoRoot = (git -C $ProjectRoot rev-parse --show-toplevel).Trim()
$projectPrefix = (git -C $ProjectRoot rev-parse --show-prefix).Trim()

if (-not $Branch) {
    $Branch = "codex/$TaskId"
}

if (-not $WorktreeRoot) {
    $WorktreeRoot = Join-Path (Split-Path $repoRoot -Parent) ".ai-team-worktrees"
}

if (-not (Test-Path -LiteralPath $WorktreeRoot)) {
    New-Item -ItemType Directory -Path $WorktreeRoot | Out-Null
}

$safeName = $TaskId -replace "[/\\:]", "-"
$worktreePath = Join-Path $WorktreeRoot $safeName

if (Test-Path -LiteralPath $worktreePath) {
    throw "Worktree path already exists: $worktreePath"
}

$dirty = git -C $repoRoot status --porcelain
if ($dirty) {
    Write-Warning "Current repository has uncommitted changes. The new worktree is created from $BaseRef and will not include uncommitted files."
}

$branchExists = $false
git -C $repoRoot show-ref --verify --quiet "refs/heads/$Branch"
if ($LASTEXITCODE -eq 0) {
    $branchExists = $true
}

if ($branchExists) {
    git -C $repoRoot worktree add $worktreePath $Branch
}
else {
    git -C $repoRoot worktree add -b $Branch $worktreePath $BaseRef
}

$worktreeProjectPath = Join-Path $worktreePath $projectPrefix

Write-Host ""
Write-Host "Created worktree:"
Write-Host "  Branch: $Branch"
Write-Host "  Worktree: $worktreePath"
Write-Host "  Project path: $worktreeProjectPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  cd `"$worktreeProjectPath`""
Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Get-AiTeamContext.ps1 -TaskId $TaskId"
Write-Host ""
Write-Host "If .ai-team is missing in the worktree, commit or copy the workflow files before assigning Executors."
