param(
    [switch]$SkipSync
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$aiTeamRoot = Join-Path $ProjectRoot ".ai-team"
$errors = New-Object System.Collections.Generic.List[string]

function Add-CheckError {
    param([string]$Message)
    $errors.Add($Message) | Out-Null
}

function Test-PathRequired {
    param([string]$RelativePath)

    $path = Join-Path $aiTeamRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-CheckError "Missing .ai-team/$($RelativePath -replace '\\', '/')"
    }
}

function Test-JsonFile {
    param([string]$RelativePath)

    $path = Join-Path $aiTeamRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) { return }

    try {
        Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
    }
    catch {
        Add-CheckError "Invalid JSON in .ai-team/$($RelativePath -replace '\\', '/'): $($_.Exception.Message)"
    }
}

function Test-PowerShellSyntax {
    param([string]$Directory)

    $path = Join-Path $aiTeamRoot $Directory
    if (-not (Test-Path -LiteralPath $path)) { return }

    foreach ($script in Get-ChildItem -LiteralPath $path -Filter "*.ps1") {
        $tokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
        if ($parseErrors -and $parseErrors.Count -gt 0) {
            Add-CheckError "PowerShell syntax error in .ai-team/$Directory/$($script.Name)"
        }
    }
}

function Test-CommandRiskClassifier {
    $classifierPath = Join-Path $aiTeamRoot "scripts\Test-AiTeamCommand.ps1"
    if (-not (Test-Path -LiteralPath $classifierPath)) { return }

    $cases = @(
        @{ command = "git status --short"; expected = "safe" },
        @{ command = "npm install left-pad"; expected = "approval_required" },
        @{ command = "git commit --no-verify"; expected = "forbidden" },
        @{ command = "unknown-tool --flag"; expected = "approval_required" }
    )

    foreach ($case in $cases) {
        try {
            $result = powershell -NoProfile -ExecutionPolicy Bypass -File $classifierPath -Command $case.command -Json | ConvertFrom-Json
            if ($result.risk -ne $case.expected) {
                Add-CheckError "Command risk classifier expected '$($case.command)' to be $($case.expected), got $($result.risk)."
            }
        }
        catch {
            Add-CheckError "Command risk classifier failed for '$($case.command)': $($_.Exception.Message)"
        }
    }
}

function Test-TaskFileBoundaries {
    $tasksDir = Join-Path $aiTeamRoot "tasks"
    if (-not (Test-Path -LiteralPath $tasksDir)) { return }

    foreach ($taskFile in Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" -File) {
        if ($taskFile.Name -eq "TEMPLATE.md") { continue }

        $content = Get-Content -LiteralPath $taskFile.FullName -Raw -Encoding UTF8
        if ($content -match '(?m)^\s*-\s+`?\$_`?\s*$') {
            Add-CheckError ("Task boundary in .ai-team/tasks/{0} contains literal '- `$_'. Regenerate or fix Allowed To Modify." -f $taskFile.Name)
        }

        $match = [regex]::Match($content, "(?ms)^### Allowed To Modify\s*(?<body>.*?)(?:^### |^## |\z)")
        if (-not $match.Success) {
            Add-CheckError "Task card .ai-team/tasks/$($taskFile.Name) is missing an Allowed To Modify section."
            continue
        }

        $allowedLines = @(
            $match.Groups["body"].Value -split "\r?\n" |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ -match "^\-\s+\S" }
        )

        foreach ($line in $allowedLines) {
            $boundary = $line -replace "^\-\s+", ""
            if ($boundary -match ",") {
                Add-CheckError "Task boundary in .ai-team/tasks/$($taskFile.Name) appears to combine multiple paths on one line: $line"
            }
        }
    }
}

Write-Host "AI Team project health check"
Write-Host "Project: $ProjectRoot"
Write-Host ""

if (-not (Test-Path -LiteralPath $aiTeamRoot)) {
    throw "Missing .ai-team directory: $aiTeamRoot"
}

$requiredPaths = @(
    "config.json",
    "commands.json",
    "memory\project-brief.md",
    "memory\production-mode.md",
    "memory\technology-policy.md",
    "memory\pitfalls.md",
    "memory\patterns.md",
    "policies\command-policy.md",
    "checklists\plan-gate.md",
    "checklists\review-gate.md",
    "checklists\integration-gate.md",
    "checklists\release-gate.md",
    "prompts\dispatcher.md",
    "prompts\executor.md",
    "prompts\reviewer-verifier.md",
    "scripts\Get-AiTeamContext.ps1",
    "scripts\Get-AiTeamStatus.ps1",
    "scripts\Sync-AiTeamState.ps1",
    "scripts\Test-AiTeamCommand.ps1",
    "scripts\Update-AiTeamRun.ps1",
    "tasks\TEMPLATE.md",
    "state\runs.json"
)

foreach ($relativePath in $requiredPaths) {
    Test-PathRequired $relativePath
}

foreach ($jsonPath in @("config.json", "commands.json", "state\tasks.json", "state\runs.json")) {
    Test-JsonFile $jsonPath
}

$taskTemplatePath = Join-Path $aiTeamRoot "tasks\TEMPLATE.md"
if (Test-Path -LiteralPath $taskTemplatePath) {
    $taskTemplate = Get-Content -LiteralPath $taskTemplatePath -Raw -Encoding UTF8
    if ($taskTemplate -notmatch "(?m)^work_mode:") {
        Add-CheckError "Task template is missing work_mode."
    }
}

Test-PowerShellSyntax "scripts"
Test-PowerShellSyntax "hooks"
Test-CommandRiskClassifier
Test-TaskFileBoundaries

if (-not $SkipSync) {
    $syncScript = Join-Path $aiTeamRoot "scripts\Sync-AiTeamState.ps1"
    if (Test-Path -LiteralPath $syncScript) {
        try {
            powershell -NoProfile -ExecutionPolicy Bypass -File $syncScript | Out-Null
        }
        catch {
            Add-CheckError "Task state sync failed: $($_.Exception.Message)"
        }
    }
}

$statusScript = Join-Path $aiTeamRoot "scripts\Get-AiTeamStatus.ps1"
if (Test-Path -LiteralPath $statusScript) {
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $statusScript | Out-Null
    }
    catch {
        Add-CheckError "Status command failed: $($_.Exception.Message)"
    }
}

$contextScript = Join-Path $aiTeamRoot "scripts\Get-AiTeamContext.ps1"
if (Test-Path -LiteralPath $contextScript) {
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $contextScript | Out-Null
    }
    catch {
        Add-CheckError "Context command failed: $($_.Exception.Message)"
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Result: failed"
    foreach ($errorItem in $errors) {
        Write-Host "- $errorItem"
    }
    exit 1
}

Write-Host "Result: passed"
Write-Host "Checked structure, JSON, PowerShell syntax, command risk rules, sync, status, and compact context."
