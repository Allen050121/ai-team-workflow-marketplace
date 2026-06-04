param(
    [Parameter(Mandatory = $true)]
    [string]$Id,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [string]$Owner = "dispatcher",

    [ValidateSet("planned", "in_progress", "review", "blocked", "done")]
    [string]$Status = "planned",

    [ValidateSet("serial", "parallel")]
    [string]$Mode = "serial",

    [ValidateSet("Prototype", "MVP", "Production")]
    [string]$WorkMode = "MVP",

    [ValidateSet("light", "standard", "strict", "parallel")]
    [string]$WorkflowMode = "standard",

    [string[]]$Dependencies = @(),

    [string[]]$AllowedFiles = @(),

    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

if ($Id -notmatch "^[a-z0-9][a-z0-9._-]*$") {
    throw "Task id must use lowercase letters, numbers, dot, underscore, or hyphen, and must start with a letter or number."
}

$templatePath = Join-Path $ProjectRoot ".ai-team\tasks\TEMPLATE.md"
$taskPath = Join-Path $ProjectRoot ".ai-team\tasks\$Id.md"

if ((Test-Path -LiteralPath $taskPath) -and -not $Force) {
    throw "Task already exists: $taskPath. Use -Force to overwrite."
}

if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Missing task template: $templatePath"
}

$normalizedAllowedFiles = @(
    $AllowedFiles |
        ForEach-Object { "$_" -split "," } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
)

if ($normalizedAllowedFiles.Count -gt 0) {
    $allowed = ($normalizedAllowedFiles | ForEach-Object { "- {0}" -f $_ }) -join [Environment]::NewLine
}
else {
    $allowed = "- Dispatcher must fill this in before Executor starts."
}

$content = Get-Content -LiteralPath $templatePath -Encoding UTF8 -Raw
$content = $content.Replace("{{TITLE}}", $Title)
$content = $content.Replace("{{TASK_ID}}", $Id)
$content = $content.Replace("{{STATUS}}", $Status)
$content = $content.Replace("{{OWNER}}", $Owner)
$content = $content.Replace("{{MODE}}", $Mode)
$content = $content.Replace("{{WORK_MODE}}", $WorkMode)
$content = $content.Replace("{{WORKFLOW_MODE}}", $WorkflowMode)
$content = $content.Replace("{{DATE}}", (Get-Date -Format "yyyy-MM-dd"))
$content = $content.Replace("dependencies:", ("dependencies: " + (($Dependencies | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ", ")))
$content = $content.Replace("{{ALLOWED_FILES}}", $allowed)

Set-Content -LiteralPath $taskPath -Encoding UTF8 -Value $content
Write-Host "Created task card: $taskPath"
