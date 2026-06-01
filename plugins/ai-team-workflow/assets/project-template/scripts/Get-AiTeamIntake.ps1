param(
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$aiTeamRoot = Join-Path $ProjectRoot ".ai-team"

function Test-AnyPath {
    param([string[]]$RelativePaths)

    foreach ($relativePath in $RelativePaths) {
        if (Test-Path -LiteralPath (Join-Path $ProjectRoot $relativePath)) {
            return $true
        }
    }
    return $false
}

function Get-ExistingPathNames {
    param([string[]]$RelativePaths)

    $found = @()
    foreach ($relativePath in $RelativePaths) {
        if (Test-Path -LiteralPath (Join-Path $ProjectRoot $relativePath)) {
            $found += $relativePath
        }
    }
    return $found
}

function Get-GitStatusLines {
    try {
        $gitRoot = git -C $ProjectRoot rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $gitRoot) { return @() }
        return @(git -C $ProjectRoot status --short 2>$null)
    }
    catch {
        return @()
    }
}

$manifestPaths = @(
    "package.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "package-lock.json",
    "pom.xml",
    "build.gradle",
    "settings.gradle",
    "requirements.txt",
    "pyproject.toml",
    "Pipfile",
    "go.mod",
    "Cargo.toml",
    "composer.json",
    "Gemfile"
)

$sourcePaths = @(
    "src",
    "app",
    "pages",
    "components",
    "server",
    "api",
    "lib",
    "internal",
    "cmd"
)

$configPaths = @(
    ".env",
    ".env.local",
    ".env.example",
    "next.config.js",
    "next.config.mjs",
    "vite.config.ts",
    "vite.config.js",
    "tsconfig.json",
    "vercel.json",
    "docker-compose.yml",
    "Dockerfile"
)

$docsPaths = @("README.md", "readme.md", "docs")
$dataPaths = @("prisma", "migrations", "schema.sql", "supabase", "drizzle", "db")
$testPaths = @("tests", "__tests__", "test", "spec", "playwright.config.ts", "vitest.config.ts", "jest.config.js")

$manifestMatches = Get-ExistingPathNames $manifestPaths
$sourceMatches = Get-ExistingPathNames $sourcePaths
$configMatches = Get-ExistingPathNames $configPaths
$docsMatches = Get-ExistingPathNames $docsPaths
$dataMatches = Get-ExistingPathNames $dataPaths
$testMatches = Get-ExistingPathNames $testPaths
$gitStatus = Get-GitStatusLines

$topLevelItems = @()
try {
    $topLevelItems = @(Get-ChildItem -LiteralPath $ProjectRoot -Force | Where-Object {
        $_.Name -notin @(".git", ".ai-team", "node_modules", ".next", "dist", "build", "coverage")
    })
}
catch {
    $topLevelItems = @()
}

$hasAiTeam = Test-Path -LiteralPath $aiTeamRoot
$hasManifest = $manifestMatches.Count -gt 0
$hasSource = $sourceMatches.Count -gt 0
$hasConfig = $configMatches.Count -gt 0
$hasDocs = $docsMatches.Count -gt 0
$hasData = $dataMatches.Count -gt 0
$hasTests = $testMatches.Count -gt 0
$hasGitHistory = $false
try {
    git -C $ProjectRoot rev-parse --verify HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $hasGitHistory = $true }
}
catch {
    $hasGitHistory = $false
}

$dirtyCount = @($gitStatus | Where-Object { $_ }).Count
$nonAiTeamDirtyCount = @($gitStatus | Where-Object { $_ -and ($_ -notmatch "^\?\?\s+\.ai-team/" -and $_ -notmatch "^\s*M\s+\.ai-team/" -and $_ -notmatch "^\s*A\s+\.ai-team/") }).Count
$isMostlyEmpty = ($topLevelItems.Count -eq 0) -or (($topLevelItems.Count -le 2) -and -not $hasManifest -and -not $hasSource)
$looksLikeProductProject = $hasManifest -or $hasSource -or $hasConfig -or $hasData
$looksLikeExistingProject = $looksLikeProductProject -or $hasGitHistory
$looksLikeMixedDirectory = (-not $looksLikeProductProject) -and $topLevelItems.Count -gt 8

$projectType = "unknown"
$recommendedPath = "inspect_first"
$confidence = "medium"
$requiresConfirmation = $true
$questions = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ($hasAiTeam -and $looksLikeExistingProject) {
    $projectType = "ai_team_project"
    $recommendedPath = "continue_existing_ai_team_workflow"
    $requiresConfirmation = $false
    $confidence = "high"
}
elseif ($isMostlyEmpty -and -not $looksLikeExistingProject) {
    $projectType = "new_empty_project"
    $recommendedPath = "plan_product_then_initialize_project"
    $confidence = "high"
    $questions.Add("Confirm product scope, persistence, authentication, deployment target, and project scale before creating code.") | Out-Null
}
elseif ($looksLikeProductProject -and -not $hasAiTeam) {
    $projectType = "existing_project_without_ai_team"
    $recommendedPath = "initialize_ai_team_then_create_repo_map_before_code_changes"
    $confidence = "high"
    $questions.Add("Confirm whether Codex may add .ai-team workflow files before changing business code.") | Out-Null
}
elseif ($looksLikeProductProject -and $hasAiTeam) {
    $projectType = "existing_project_with_ai_team"
    $recommendedPath = "read_ai_team_state_then_plan_incremental_change"
    $requiresConfirmation = $false
    $confidence = "high"
}
elseif ($looksLikeMixedDirectory) {
    $projectType = "mixed_or_notes_directory"
    $recommendedPath = "ask_for_target_project_directory_or_create_subdirectory"
    $confidence = "medium"
    $questions.Add("Confirm the exact project directory before creating app files or modifying business code.") | Out-Null
}
else {
    $projectType = "unclear_directory"
    $recommendedPath = "inspect_and_ask_before_writing_code"
    $confidence = "low"
    $questions.Add("Confirm whether this should be treated as a new product, an existing codebase, or a notes/mixed directory.") | Out-Null
}

if ($nonAiTeamDirtyCount -gt 0) {
    $warnings.Add("Git working tree has non-.ai-team changes. Do not touch unrelated files; ask before committing or rewriting history.") | Out-Null
}
if ($hasData) {
    $warnings.Add("Data/schema files detected. Database, migration, and data ownership changes require confirmation.") | Out-Null
}
if ($configMatches | Where-Object { $_ -match "^\.env" }) {
    $warnings.Add("Environment files detected. Do not expose or commit real secrets.") | Out-Null
}
if (-not $hasTests -and $looksLikeProductProject) {
    $warnings.Add("No obvious test directory/config detected. Dispatcher should define build/lint/manual verification before execution.") | Out-Null
}

$signals = [ordered]@{
    has_ai_team = $hasAiTeam
    has_git_history = $hasGitHistory
    dirty_files = $dirtyCount
    non_ai_team_dirty_files = $nonAiTeamDirtyCount
    top_level_item_count = $topLevelItems.Count
    manifests = @($manifestMatches)
    source_dirs = @($sourceMatches)
    config_files = @($configMatches)
    docs = @($docsMatches)
    data_or_schema = @($dataMatches)
    tests = @($testMatches)
}

$result = [ordered]@{
    version = 1
    project_root = "$ProjectRoot"
    project_type = $projectType
    confidence = $confidence
    recommended_path = $recommendedPath
    requires_confirmation = $requiresConfirmation
    signals = $signals
    warnings = @($warnings)
    questions = @($questions)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 8
    return
}

Write-Host "AI Team Project Intake"
Write-Host "Project: $ProjectRoot"
Write-Host ("Type: {0} ({1})" -f $projectType, $confidence)
Write-Host ("Recommended path: {0}" -f $recommendedPath)
Write-Host ("Requires confirmation: {0}" -f $requiresConfirmation)
Write-Host ""
Write-Host "Signals:"
Write-Host ("- .ai-team: {0}" -f $hasAiTeam)
Write-Host ("- git history: {0}; dirty files: {1}; non-.ai-team dirty files: {2}" -f $hasGitHistory, $dirtyCount, $nonAiTeamDirtyCount)
Write-Host ("- manifests: {0}" -f ($(if ($manifestMatches.Count) { $manifestMatches -join ", " } else { "none" })))
Write-Host ("- source dirs: {0}" -f ($(if ($sourceMatches.Count) { $sourceMatches -join ", " } else { "none" })))
Write-Host ("- data/schema: {0}" -f ($(if ($dataMatches.Count) { $dataMatches -join ", " } else { "none" })))
Write-Host ("- tests: {0}" -f ($(if ($testMatches.Count) { $testMatches -join ", " } else { "none" })))

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings:"
    foreach ($warning in $warnings) { Write-Host "- $warning" }
}

if ($questions.Count -gt 0) {
    Write-Host ""
    Write-Host "Questions before execution:"
    foreach ($question in $questions) { Write-Host "- $question" }
}
