param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$TemplateRoot = Join-Path $CodexHome "ai-team\project-template"
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Target = Join-Path $ProjectPath ".ai-team"

if (-not (Test-Path -LiteralPath $TemplateRoot)) {
    throw "Missing global AI Team template: $TemplateRoot"
}

if ((Test-Path -LiteralPath $Target) -and -not $Force) {
    Write-Host "Project already has .ai-team: $Target"
    Write-Host "Use -Force to overwrite template-managed files. Existing task cards are not removed by this script."
    exit 0
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null
foreach ($item in Get-ChildItem -LiteralPath $TemplateRoot -Force) {
    $destination = Join-Path $Target $item.Name
    if (Test-Path -LiteralPath $destination) {
        if ($item.PSIsContainer) {
            Copy-Item -LiteralPath (Join-Path $item.FullName "*") -Destination $destination -Recurse -Force
        }
        else {
            Copy-Item -LiteralPath $item.FullName -Destination $destination -Force
        }
    }
    else {
        Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
    }
}

$root = $ProjectPath -replace "\\", "/"
$versionPath = Join-Path $Target "VERSION.json"
$configPath = Join-Path $Target "config.json"
if ((Test-Path -LiteralPath $versionPath) -and (Test-Path -LiteralPath $configPath)) {
    try {
        $version = Get-Content -LiteralPath $versionPath -Encoding UTF8 -Raw | ConvertFrom-Json
        $config = Get-Content -LiteralPath $configPath -Encoding UTF8 -Raw | ConvertFrom-Json
        $config | Add-Member -NotePropertyName "installedTemplateVersion" -NotePropertyValue $version.templateVersion -Force
        $config | Add-Member -NotePropertyName "installedAt" -NotePropertyValue (Get-Date).ToString("o") -Force
        $config | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $configPath -Encoding UTF8
    }
    catch {
        Write-Host "Warning: could not record installed template version: $($_.Exception.Message)"
    }
}

$brief = Join-Path $Target "memory\project-brief.md"
if (Test-Path -LiteralPath $brief) {
    $content = Get-Content -LiteralPath $brief -Encoding UTF8 -Raw
    $content = $content.Replace("- Repository root: TODO", "- Repository root: ``$root``")
    $content = $content.Replace("- Working directory: TODO", "- Working directory: ``$root``")
    Set-Content -LiteralPath $brief -Encoding UTF8 -Value $content
}

Write-Host "Initialized AI Team project files at: $Target"
Write-Host "Next: ask Codex to inspect the project and update .ai-team/memory/project-brief.md."
