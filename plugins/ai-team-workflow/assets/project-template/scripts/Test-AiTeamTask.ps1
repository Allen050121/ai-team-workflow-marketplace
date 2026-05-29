param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,

    [string]$WorktreePath,

    [string]$BaseRef = "HEAD",

    [string[]]$VerifyCommand = @()
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

if (-not $WorktreePath) {
    $WorktreePath = $ProjectRoot
}

$WorktreePath = Resolve-Path $WorktreePath
$taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$TaskId.md"

if (-not (Test-Path -LiteralPath $taskPath)) {
    throw "Missing task card in main project: $taskPath"
}

Write-Host "AI Team task review"
Write-Host "Task: $TaskId"
Write-Host "Worktree: $WorktreePath"
Write-Host "Base ref: $BaseRef"

Write-Host ""
Write-Host "===== Task Card ====="
Get-Content -LiteralPath $taskPath -Encoding UTF8

Write-Host ""
Write-Host "===== Changed Files ====="
git -C $WorktreePath diff --name-status $BaseRef

Write-Host ""
Write-Host "===== Diff Stat ====="
git -C $WorktreePath diff --stat $BaseRef

if ($VerifyCommand.Count -eq 0) {
    Write-Host ""
    Write-Host "No verification command provided. Use -VerifyCommand to run project checks."
}
else {
    foreach ($command in $VerifyCommand) {
        Write-Host ""
        Write-Host "===== Verify: $command ====="
        powershell -NoProfile -ExecutionPolicy Bypass -Command $command
        if ($LASTEXITCODE -ne 0) {
            throw "Verification failed: $command"
        }
    }
}

Write-Host ""
Write-Host "Review prompt: .ai-team/prompts/reviewer-verifier.md"
Write-Host "Review checklist: .ai-team/checklists/review-gate.md"
