param(
    [string]$Version = "0.5.1",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$DistRoot = Join-Path $RepoRoot "dist"
$CodexPackage = Join-Path $RepoRoot "packages\codex"
$ClaudePackage = Join-Path $RepoRoot "packages\claude"

if ($Clean -and (Test-Path -LiteralPath $DistRoot)) {
    Remove-Item -LiteralPath $DistRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $DistRoot | Out-Null

function New-Zip {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Missing package source: $Source"
    }
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Force
    }

    $items = @(Get-ChildItem -LiteralPath $Source -Force)
    if ($items.Count -eq 0) {
        throw "Package source is empty: $Source"
    }

    Compress-Archive -Path @($items.FullName) -DestinationPath $Destination -Force
    if (-not (Test-Path -LiteralPath $Destination)) {
        throw "Failed to write package: $Destination"
    }
    Write-Host "Wrote: $Destination"
}

$distReadme = @(
    "# AI Team Workflow Packages",
    "",
    "This directory contains downloadable zip packages:",
    "",
    "- ``ai-team-workflow-codex-v$Version.zip``",
    "- ``ai-team-workflow-claude-v$Version.zip``",
    "",
    "Rebuild with:",
    "",
    "``````",
    "powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-AiTeamPackages.ps1 -Version $Version -Clean",
    "``````"
) -join [Environment]::NewLine

Set-Content -LiteralPath (Join-Path $DistRoot "README.md") -Encoding UTF8 -Value $distReadme

$codexZip = Join-Path $DistRoot "ai-team-workflow-codex-v$Version.zip"
$claudeZip = Join-Path $DistRoot "ai-team-workflow-claude-v$Version.zip"

New-Zip $CodexPackage $codexZip
New-Zip $ClaudePackage $claudeZip

Write-Host ""
Write-Host "AI Team packages built:"
Write-Host "- $codexZip"
Write-Host "- $claudeZip"
