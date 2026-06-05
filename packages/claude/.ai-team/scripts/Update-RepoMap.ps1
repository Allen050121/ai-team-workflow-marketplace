$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$indexDir = Join-Path $ProjectRoot ".ai-team\index"
$repoMap = Join-Path $indexDir "repo-map.md"

New-Item -ItemType Directory -Force -Path $indexDir | Out-Null

$files = Get-ChildItem -LiteralPath $ProjectRoot -Force |
    Where-Object { $_.Name -notin @(".git", ".ai-team", "node_modules", ".next", "dist", "build", "coverage") } |
    Sort-Object { -not $_.PSIsContainer }, Name |
    Select-Object -First 80

$packageJson = Join-Path $ProjectRoot "package.json"
$projectType = "TODO"
$language = "TODO"
$framework = "TODO"
$packageManager = "TODO"

if (Test-Path -LiteralPath $packageJson) {
    $projectType = "Web/Node project"
    $language = "JavaScript/TypeScript"
    $packageManager = "npm/pnpm/yarn, inspect lockfile"
    $pkg = Get-Content -LiteralPath $packageJson -Encoding UTF8 -Raw | ConvertFrom-Json
    $deps = @()
    if ($pkg.dependencies) { $deps += $pkg.dependencies.PSObject.Properties.Name }
    if ($pkg.devDependencies) { $deps += $pkg.devDependencies.PSObject.Properties.Name }
    if ($deps -contains "next") { $framework = "Next.js" }
    elseif ($deps -contains "react") { $framework = "React" }
    elseif ($deps -contains "vue") { $framework = "Vue" }
}

$lines = @()
$lines += "---"
$lines += "title: Repo Map"
$lines += "tags:"
$lines += "  - ai-team/index"
$lines += "  - repo-map"
$lines += "status: active"
$lines += "---"
$lines += ""
$lines += "# Repo Map"
$lines += ""
$lines += "> Compact project index for Codex. Keep this short and update it when structure changes."
$lines += ""
$lines += "## Project Shape"
$lines += ""
$lines += "- Type: $projectType"
$lines += "- Main language: $language"
$lines += "- Framework/runtime: $framework"
$lines += "- Package manager: $packageManager"
$lines += ""
$lines += "## Top-Level Structure"
$lines += ""
foreach ($file in $files) {
    $kind = if ($file.PSIsContainer) { "dir" } else { "file" }
    $lines += "- $($file.Name) ($kind)"
}
$lines += ""
$lines += "## Important Directories"
$lines += ""
$lines += "- TODO: Codex should fill this after inspecting the code."
$lines += ""
$lines += "## Entry Points"
$lines += ""
$lines += "- TODO"
$lines += ""
$lines += "## Data / State"
$lines += ""
$lines += "- TODO"
$lines += ""
$lines += "## Tests And Verification"
$lines += ""
$lines += "- TODO: keep aligned with `.ai-team/commands.json`."
$lines += ""
$lines += "## Deployment"
$lines += ""
$lines += "- TODO"
$lines += ""
$lines += "## Notes For Agents"
$lines += ""
$lines += "- Prefer this map before broad repository searches."
$lines += "- If this map is stale, update it instead of rediscovering the same facts repeatedly."

Set-Content -LiteralPath $repoMap -Encoding UTF8 -Value ($lines -join [Environment]::NewLine)
Write-Host "Updated repo map: $repoMap"
