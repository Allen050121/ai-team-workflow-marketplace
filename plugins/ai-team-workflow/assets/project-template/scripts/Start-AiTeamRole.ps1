param(
    [ValidateSet("dispatcher", "executor", "reviewer", "memory", "integration")]
    [string]$Role = "dispatcher",

    [string]$TaskId,

    [string]$Request,

    [switch]$Clipboard,

    [switch]$Full
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$hookPath = Join-Path $ProjectRoot ".ai-team\hooks\ai-team-hook.ps1"

if (-not (Test-Path -LiteralPath $hookPath)) {
    throw "Missing hook script: $hookPath"
}

$argsList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $hookPath, "-Role", $Role)
if ($TaskId) {
    $argsList += @("-TaskId", $TaskId)
}
if ($Full) {
    $argsList += "-Full"
}

$bundle = & powershell @argsList | Out-String

if ($Request) {
    $bundle += [Environment]::NewLine
    $bundle += "===== User Request =====" + [Environment]::NewLine
    $bundle += $Request + [Environment]::NewLine
}

if ($Clipboard) {
    Set-Clipboard -Value $bundle
    Write-Host "AI Team $Role bundle copied to clipboard."
    if ($TaskId) {
        Write-Host "Task: $TaskId"
    }
    Write-Host "Paste it into the agent window, then add only the real business instruction if needed."
}
else {
    Write-Host "Paste the following bundle into your agent window, or configure your tool hook to run this command automatically."
    Write-Host ""
    Write-Host $bundle
}
