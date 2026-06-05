param(
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [switch]$Json
)

$ErrorActionPreference = "Stop"

function New-Rule {
    param(
        [string]$Name,
        [string]$Risk,
        [string]$Pattern,
        [string]$Reason
    )

    [pscustomobject]@{
        name = $Name
        risk = $Risk
        pattern = $Pattern
        reason = $Reason
    }
}

$normalized = ($Command -replace "\s+", " ").Trim()

$forbiddenRules = @(
    New-Rule "secret_literal" "forbidden" "(?i)(ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]+|sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|xox[baprs]-[A-Za-z0-9-]+)" "Command appears to contain a real secret or private key."
    New-Rule "bypass_verification" "forbidden" "(?i)(^|\s)(--no-verify|skip[ _-]?(tests?|ci|checks?))\b" "Command appears to bypass tests, hooks, CI, or review checks."
    New-Rule "dangerous_recursive_delete" "forbidden" "(?i)(\brm\s+-rf\s+([/\\.]|\*|~|\$|%|`)|Remove-Item\b.*\b-Recurse\b.*\b-Force\b.*(\*|\$|%|`)|\bdel\s+/s\b|\brmdir\s+/s\b)" "Command looks like a broad destructive delete."
    New-Rule "hard_reset" "forbidden" "(?i)\bgit\s+reset\s+--hard\b" "Hard reset can discard unreviewed work."
)

$approvalRules = @(
    New-Rule "dependency_change" "approval_required" "(?i)\b(npm|pnpm|yarn|bun)\s+(install|i|add|remove|upgrade|update)\b|\b(pip|uv|poetry|cargo|go)\s+(install|add|get|mod|remove|update)\b" "Dependency installation, removal, or upgrade changes project supply-chain state."
    New-Rule "environment_or_secret_edit" "approval_required" "(?i)(\.env(\.|$)|setx\b|Set-Content\b.*(\.env|secret|token|credential|cookie)|\[Environment\]::SetEnvironmentVariable|export\s+[A-Za-z_][A-Za-z0-9_]*=)" "Environment variables, credentials, or secret-bearing files may be modified."
    New-Rule "database_change" "approval_required" "(?i)\b(migrate|migration|seed|db:|prisma\s+migrate|knex\s+migrate|sequelize\s+db|rails\s+db|alembic|typeorm)\b" "Database migration, seed, or data operation can change durable data."
    New-Rule "git_remote_or_release" "approval_required" "(?i)\bgit\s+(push|tag)\b|\bgh\s+(release|pr|repo|api)\b|\bnpm\s+publish\b|\b(pnpm|yarn)\s+publish\b" "Remote git, release, package publish, or GitHub mutation changes external state."
    New-Rule "deployment_or_cloud" "approval_required" "(?i)\b(vercel|netlify|wrangler|firebase|supabase|aws|gcloud|az|kubectl|helm|docker\s+push)\b" "Deployment, cloud, or external service command can change production or paid resources."
    New-Rule "file_delete_or_move" "approval_required" "(?i)\b(Remove-Item|rm|del|rmdir|Move-Item|mv)\b" "Deleting or moving files can cross task boundaries or destroy work."
)

$safeRules = @(
    New-Rule "read_only_files" "safe" "(?i)^(Get-Content|Get-ChildItem|Select-String|rg|findstr|type|dir|ls|pwd)\b" "Read-only inspection command."
    New-Rule "read_only_git" "safe" "(?i)^git\s+(status|diff|log|show|branch|rev-parse|ls-files)\b" "Read-only git inspection command."
    New-Rule "project_checks" "safe" "(?i)^((npm|pnpm|yarn|bun)\s+run\s+)?(lint|test|typecheck|build|check)\b|^(npm|pnpm|yarn|bun)\s+(test|run\s+(lint|test|typecheck|build|check))\b|^(pytest|python\s+-m\s+pytest|go\s+test|cargo\s+test|dotnet\s+test)\b" "Local verification command."
)

$risk = "approval_required"
$reason = "Command is not in the safe allowlist; Human Lead approval is required before running it."
$matchedRules = @()

foreach ($rule in $forbiddenRules) {
    if ($normalized -match $rule.pattern) {
        $risk = $rule.risk
        $reason = $rule.reason
        $matchedRules += $rule.name
        break
    }
}

if ($matchedRules.Count -eq 0) {
    foreach ($rule in $approvalRules) {
        if ($normalized -match $rule.pattern) {
            $risk = $rule.risk
            $reason = $rule.reason
            $matchedRules += $rule.name
            break
        }
    }
}

if ($matchedRules.Count -eq 0) {
    foreach ($rule in $safeRules) {
        if ($normalized -match $rule.pattern) {
            $risk = $rule.risk
            $reason = $rule.reason
            $matchedRules += $rule.name
            break
        }
    }
}

$result = [ordered]@{
    command = $Command
    risk = $risk
    reason = $reason
    matched_rules = @($matchedRules)
    policy = ".ai-team/policies/command-policy.md"
}

if ($Json) {
    $result | ConvertTo-Json -Depth 5
}
else {
    Write-Host ("Risk: {0}" -f $result.risk)
    Write-Host ("Reason: {0}" -f $result.reason)
    if ($result.matched_rules.Count -gt 0) {
        Write-Host ("Matched rules: {0}" -f ($result.matched_rules -join ", "))
    }
    else {
        Write-Host "Matched rules: none"
    }
}
