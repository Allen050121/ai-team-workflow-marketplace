param(
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$PluginRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Assets = Join-Path $PluginRoot "assets"
$Target = Join-Path $CodexHome "ai-team"
$TemplateTarget = Join-Path $Target "project-template"

New-Item -ItemType Directory -Force -Path $Target | Out-Null

if ((Test-Path -LiteralPath $TemplateTarget) -and -not $Force) {
    Write-Host "Global AI Team template already exists: $TemplateTarget"
    Write-Host "Use -Force to overwrite it from the plugin assets."
}
else {
    if (Test-Path -LiteralPath $TemplateTarget) {
        Remove-Item -LiteralPath $TemplateTarget -Recurse -Force
    }
    Copy-Item -LiteralPath (Join-Path $Assets "project-template") -Destination $TemplateTarget -Recurse
    Write-Host "Installed project template: $TemplateTarget"
}

Copy-Item -LiteralPath (Join-Path $Assets "human-lead.md") -Destination (Join-Path $Target "human-lead.md") -Force
Copy-Item -LiteralPath (Join-Path $Assets "global-AGENTS.md") -Destination (Join-Path $CodexHome "AGENTS.md") -Force

$initSource = Join-Path $TemplateTarget "..\Initialize-AiTeamProject.ps1"
$pluginInit = Join-Path $Assets "Initialize-AiTeamProject.ps1"
if (Test-Path -LiteralPath $pluginInit) {
    Copy-Item -LiteralPath $pluginInit -Destination (Join-Path $Target "Initialize-AiTeamProject.ps1") -Force
}

$pluginUpdate = Join-Path $Assets "Update-AiTeamProject.ps1"
if (Test-Path -LiteralPath $pluginUpdate) {
    Copy-Item -LiteralPath $pluginUpdate -Destination (Join-Path $Target "Update-AiTeamProject.ps1") -Force
}

Write-Host "AI Team Workflow installed to: $Target"
Write-Host "Global Codex rules updated: $(Join-Path $CodexHome 'AGENTS.md')"
