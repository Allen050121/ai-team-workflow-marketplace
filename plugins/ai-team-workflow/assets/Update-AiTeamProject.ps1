param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [switch]$IncludeProjectDocs
)

$ErrorActionPreference = "Stop"
$TemplateRoot = Join-Path $CodexHome "ai-team\project-template"
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Target = Join-Path $ProjectPath ".ai-team"

if (-not (Test-Path -LiteralPath $TemplateRoot)) {
    throw "Missing global AI Team template: $TemplateRoot"
}

if (-not (Test-Path -LiteralPath $Target)) {
    throw "Project does not have .ai-team yet: $Target. Run Initialize-AiTeamProject.ps1 first."
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
    "CODEX.md",
    "ROUTER.md",
    "USAGE.md"
)

if ($IncludeProjectDocs) {
    $templateManaged += "README.md"
}

foreach ($item in $templateManaged) {
    Copy-TemplateItem $item
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "state\runs.json"))) {
    Copy-TemplateItem "state\runs.json"
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "state\tasks.json"))) {
    Copy-TemplateItem "state\tasks.json"
}

if (-not (Test-Path -LiteralPath (Join-Path $Target "memory\production-mode.md"))) {
    Copy-TemplateItem "memory\production-mode.md"
}

Write-Host ""
Write-Host "AI Team project workflow files updated."
Write-Host "Protected project-local directories: memory, tasks/*.md, state, index, commands.json."
Write-Host "Run .ai-team/scripts/Sync-AiTeamState.ps1 after reviewing task cards."
