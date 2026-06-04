param(
    [string]$Title = "",
    [string]$Goal = "",
    [string[]]$AllowedFiles = @(),
    [ValidateSet("serial", "parallel")]
    [string]$Mode = "serial",
    [ValidateSet("Prototype", "MVP", "Production")]
    [string]$WorkMode = "MVP",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$highRiskPatterns = @(
    "auth", "login", "session", "permission", "role", "rbac", "oauth", "jwt",
    "payment", "billing", "stripe", "checkout", "invoice", "subscription",
    "migration", "schema", "database", "db", "sql", "prisma", "drizzle",
    "secret", "token", "key", "credential", "env",
    "deploy", "deployment", "release", "production", "vercel", "netlify", "aws", "azure", "gcp",
    "dependency", "package", "npm install", "pnpm add", "yarn add",
    "security", "encryption", "webhook", "external service", "api key"
)

$lowRiskPatterns = @(
    "copy", "text", "typo", "readme", "docs", "style", "css", "spacing",
    "color", "label", "button", "icon", "minor", "small"
)

function Normalize-List {
    param([string[]]$Values)

    return @(
        $Values |
            ForEach-Object { "$_" -split "," } |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }
    )
}

$normalizedFiles = Normalize-List $AllowedFiles
$haystack = (@($Title, $Goal) + $normalizedFiles) -join " "
$haystack = $haystack.ToLowerInvariant()

$reasons = New-Object System.Collections.Generic.List[string]
$risk = "normal"
$workflowMode = "standard"

if ($Mode -eq "parallel") {
    $workflowMode = "parallel"
    $reasons.Add("Task mode is parallel.") | Out-Null
}

if ($WorkMode -eq "Production") {
    $workflowMode = "strict"
    $risk = "high"
    $reasons.Add("Work mode is Production.") | Out-Null
}

foreach ($pattern in $highRiskPatterns) {
    if ($haystack.Contains($pattern)) {
        $workflowMode = "strict"
        $risk = "high"
        $reasons.Add("Matched high-risk signal: $pattern") | Out-Null
        break
    }
}

if ($workflowMode -eq "standard") {
    $lowRiskMatch = $false
    foreach ($pattern in $lowRiskPatterns) {
        if ($haystack.Contains($pattern)) {
            $lowRiskMatch = $true
            $reasons.Add("Matched low-risk signal: $pattern") | Out-Null
            break
        }
    }

    if ($lowRiskMatch -and $normalizedFiles.Count -gt 0 -and $normalizedFiles.Count -le 3) {
        $workflowMode = "light"
        $risk = "low"
    }
    else {
        $reasons.Add("Defaulted to standard for ordinary product work.") | Out-Null
    }
}

$result = [ordered]@{
    workflow_mode = $workflowMode
    risk = $risk
    reasons = @($reasons)
    allowed_file_count = $normalizedFiles.Count
}

if ($Json) {
    $result | ConvertTo-Json -Depth 4
}
else {
    Write-Host ("workflow_mode: {0}" -f $result.workflow_mode)
    Write-Host ("risk: {0}" -f $result.risk)
    foreach ($reason in $result.reasons) {
        Write-Host ("- {0}" -f $reason)
    }
}
