param(
    [Parameter(Mandatory = $true)]
    [string]$Id,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [ValidateSet("planned", "running", "complete")]
    [string]$Status = "planned",

    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$metricsDir = Join-Path $ProjectRoot ".ai-team\metrics"
$templatePath = Join-Path $metricsDir "BENCHMARK_TEMPLATE.md"
$benchmarkPath = Join-Path $metricsDir "$Id.md"
$statePath = Join-Path $metricsDir "benchmarks.json"

if ($Id -notmatch "^[a-z0-9][a-z0-9._-]*$") {
    throw "Benchmark id must use lowercase letters, numbers, dot, underscore, or hyphen, and must start with a letter or number."
}

if ((Test-Path -LiteralPath $benchmarkPath) -and -not $Force) {
    throw "Benchmark already exists: $benchmarkPath. Use -Force to overwrite."
}

if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Missing benchmark template: $templatePath"
}

New-Item -ItemType Directory -Force -Path $metricsDir | Out-Null

$content = Get-Content -LiteralPath $templatePath -Encoding UTF8 -Raw
$content = $content.Replace("{{BENCHMARK_ID}}", $Id)
$content = $content.Replace("{{PROJECT_NAME}}", $ProjectName)
$content = $content.Replace("{{DATE}}", (Get-Date -Format "yyyy-MM-dd"))
$content = $content.Replace("status: planned", "status: $Status")
Set-Content -LiteralPath $benchmarkPath -Encoding UTF8 -Value $content

if (Test-Path -LiteralPath $statePath) {
    try {
        $state = Get-Content -LiteralPath $statePath -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    catch {
        throw "Benchmark state exists but could not be parsed: $statePath"
    }
}
else {
    $state = [pscustomobject]@{
        version = 1
        benchmarks = @()
    }
}

$benchmarks = @()
if ($state.benchmarks) { $benchmarks = @($state.benchmarks) }
$benchmarks = @($benchmarks | Where-Object { $_.benchmark_id -ne $Id })
$benchmarks += [ordered]@{
    benchmark_id = $Id
    project_name = $ProjectName
    status = $Status
    created_at = (Get-Date).ToString("o")
    report = ".ai-team/metrics/$Id.md"
}

$newState = [ordered]@{
    version = 1
    updatedAt = (Get-Date).ToString("o")
    benchmarks = $benchmarks
}

$newState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
Write-Host "Created benchmark report: $benchmarkPath"
