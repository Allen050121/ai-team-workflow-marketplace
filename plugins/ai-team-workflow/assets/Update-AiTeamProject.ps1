param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [switch]$IncludeProjectDocs,
    [switch]$SkipHealthCheck
)

$ErrorActionPreference = "Stop"
$TemplateRoot = Join-Path $CodexHome "ai-team\project-template"
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Target = Join-Path $ProjectPath ".ai-team"
$migrationReportDir = Join-Path $Target "reports"
$migrationReportPath = Join-Path $migrationReportDir ("migration-" + (Get-Date -Format "yyyyMMddHHmmss") + ".json")

if (-not (Test-Path -LiteralPath $TemplateRoot)) {
    throw "Missing global AI Team template: $TemplateRoot"
}

if (-not (Test-Path -LiteralPath $Target)) {
    throw "Project does not have .ai-team yet: $Target. Run Initialize-AiTeamProject.ps1 first."
}

function Read-JsonSafe {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        return Get-Content -LiteralPath $Path -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "Warning: could not parse JSON: $Path"
        return $null
    }
}

$templateVersionPath = Join-Path $TemplateRoot "VERSION.json"
$templateVersion = Read-JsonSafe $templateVersionPath
$templateConfig = Read-JsonSafe (Join-Path $TemplateRoot "config.json")
$projectConfigPath = Join-Path $Target "config.json"
$projectConfigBefore = Read-JsonSafe $projectConfigPath
$currentVersion = if ($projectConfigBefore -and $projectConfigBefore.installedTemplateVersion) { $projectConfigBefore.installedTemplateVersion } else { "unknown" }
$latestVersion = if ($templateVersion -and $templateVersion.templateVersion) { $templateVersion.templateVersion } elseif ($templateConfig -and $templateConfig.templateVersion) { $templateConfig.templateVersion } else { "unknown" }

$updatedItems = New-Object System.Collections.Generic.List[string]
$preservedItems = New-Object System.Collections.Generic.List[string]
$createdItems = New-Object System.Collections.Generic.List[string]
$health = [ordered]@{
    ran = $false
    status = "not_run"
    output = @()
}

function Copy-TemplateItem {
    param(
        [string]$RelativePath
    )

    $source = Join-Path $TemplateRoot $RelativePath
    $destination = Join-Path $Target $RelativePath

    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "Skipping missing template item: $RelativePath"
        return
    }

    $parent = Split-Path -Parent $destination
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
        $updatedItems.Add($RelativePath) | Out-Null
    }
    else {
        $createdItems.Add($RelativePath) | Out-Null
    }

    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
    Write-Host "Updated: .ai-team/$($RelativePath -replace '\\', '/')"
}

$templateManaged = @(
    "checklists",
    "github",
    "hooks",
    "policies",
    "prompts",
    "scripts",
    "tasks\TEMPLATE.md",
    "VERSION.json",
    "config.json",
    "CODEX.md",
    "ROUTER.md",
    "USAGE.md"
)

if ($IncludeProjectDocs) {
    $templateManaged += "README.md"
}

foreach ($item in $templateManaged) {
    if ($item -ne "config.json") {
        Copy-TemplateItem $item
    }
}

$templateConfigPath = Join-Path $TemplateRoot "config.json"
if (Test-Path -LiteralPath $templateConfigPath) {
    $configExisted = Test-Path -LiteralPath $projectConfigPath
    $projectConfig = if ($projectConfigBefore) { $projectConfigBefore } else { [pscustomobject]@{} }
    $newConfig = Get-Content -LiteralPath $templateConfigPath -Encoding UTF8 -Raw | ConvertFrom-Json
    foreach ($property in $newConfig.PSObject.Properties) {
        $projectConfig | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value -Force
    }
    $projectConfig | Add-Member -NotePropertyName "installedTemplateVersion" -NotePropertyValue $latestVersion -Force
    $projectConfig | Add-Member -NotePropertyName "previousTemplateVersion" -NotePropertyValue $currentVersion -Force
    $projectConfig | Add-Member -NotePropertyName "updatedAt" -NotePropertyValue (Get-Date).ToString("o") -Force
    $projectConfig | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $projectConfigPath -Encoding UTF8
    if ($configExisted) {
        $updatedItems.Add("config.json") | Out-Null
    }
    else {
        $createdItems.Add("config.json") | Out-Null
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "state\runs.json"))) {
    Copy-TemplateItem "state\runs.json"
}
else {
    $preservedItems.Add("state\runs.json") | Out-Null
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "state\tasks.json"))) {
    Copy-TemplateItem "state\tasks.json"
}
else {
    $preservedItems.Add("state\tasks.json") | Out-Null
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "memory\production-mode.md"))) {
    Copy-TemplateItem "memory\production-mode.md"
}
else {
    $preservedItems.Add("memory\production-mode.md") | Out-Null
}

foreach ($item in @("memory", "tasks/*.md", "state", "index", "commands.json")) {
    $preservedItems.Add($item) | Out-Null
}

if (-not $SkipHealthCheck) {
    $healthScript = Join-Path $Target "scripts\Test-AiTeamProject.ps1"
    if (Test-Path -LiteralPath $healthScript) {
        $health.ran = $true
        try {
            $healthOutput = powershell -NoProfile -ExecutionPolicy Bypass -File $healthScript 2>&1
            $health.output = @($healthOutput | ForEach-Object { "$_" })
            $health.status = if ($LASTEXITCODE -eq 0) { "passed" } else { "failed" }
        }
        catch {
            $health.status = "failed"
            $health.output = @("$($_.Exception.Message)")
        }
    }
}

New-Item -ItemType Directory -Force -Path $migrationReportDir | Out-Null
$report = [ordered]@{
    version = 1
    previousTemplateVersion = $currentVersion
    latestTemplateVersion = $latestVersion
    updatedAt = (Get-Date).ToString("o")
    updatedItems = @($updatedItems)
    createdItems = @($createdItems)
    preservedItems = @($preservedItems | Sort-Object -Unique)
    healthCheck = $health
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $migrationReportPath -Encoding UTF8

Write-Host ""
Write-Host "AI Team project workflow files updated."
Write-Host "Template version: $currentVersion -> $latestVersion"
Write-Host "Migration report: $migrationReportPath"
if ($health.ran) {
    Write-Host "Health check: $($health.status)"
}
Write-Host "Protected project-local directories: memory, tasks/*.md, state, index, commands.json."
Write-Host "Run .ai-team/scripts/Sync-AiTeamState.ps1 after reviewing task cards."
