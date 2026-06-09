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
        $looksLikeAiTeamTask = (
            $content -match '(?m)^task_id:' -or
            $content -match '(?m)^title:' -or
            $content -match '(?m)^### Allowed To Modify'
        )
        if (-not $looksLikeAiTeamTask) { continue }

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

function Get-MarkdownSection {
    param(
        [string]$Content,
        [string]$Heading
    )

    $pattern = "(?s)## " + [regex]::Escape($Heading) + "\s+(.+?)(\r?\n## |\z)"
    if ($Content -match $pattern) {
        return $Matches[1].Trim()
    }

    return ""
}

function Get-TaskField {
    param(
        [string]$Content,
        [string]$Name
    )

    if ($Content -match ("(?m)^" + [regex]::Escape($Name) + ":[ \t]*[""']?([^""'\r\n]*)")) {
        return $Matches[1].Trim()
    }
    return ""
}

function Get-AllowedFilesFromTask {
    param([string]$Content)

    $match = [regex]::Match($Content, "(?ms)^### Allowed To Modify\s*(?<body>.*?)(?:^### |^## |\z)")
    if (-not $match.Success) { return @() }

    return @(
        $match.Groups["body"].Value -split "\r?\n" |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -match "^\-\s+\S" } |
            ForEach-Object { $_ -replace "^\-\s+", "" } |
            Where-Object { $_ -and $_ -notmatch "Dispatcher must fill" }
    )
}

function Test-WorkflowModeClassification {
    $classifierPath = Join-Path $aiTeamRoot "scripts\Get-AiTeamWorkflowMode.ps1"
    $tasksDir = Join-Path $aiTeamRoot "tasks"
    if (-not (Test-Path -LiteralPath $classifierPath) -or -not (Test-Path -LiteralPath $tasksDir)) { return }

    $cases = @(
        @{ title = "Fix README typo"; files = @("README.md"); expected = "light" },
        @{ title = "Implement login auth"; files = @("src/auth.ts"); expected = "strict" },
        @{ title = "Build dashboard filters"; files = @("src/dashboard.tsx", "src/filters.ts"); expected = "standard" },
        @{ title = "Parallel docs cleanup"; files = @("docs/usage.md"); mode = "parallel"; expected = "parallel" }
    )

    foreach ($case in $cases) {
        $mode = if ($case.mode) { $case.mode } else { "serial" }
        try {
            $result = powershell -NoProfile -ExecutionPolicy Bypass -File $classifierPath -Title $case.title -AllowedFiles $case.files -Mode $mode -Json | ConvertFrom-Json
            if ($result.workflow_mode -ne $case.expected) {
                Add-CheckError "Workflow mode classifier expected '$($case.title)' to be $($case.expected), got $($result.workflow_mode)."
            }
        }
        catch {
            Add-CheckError "Workflow mode classifier failed for '$($case.title)': $($_.Exception.Message)"
        }
    }

    foreach ($taskFile in Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" -File) {
        if ($taskFile.Name -eq "TEMPLATE.md") { continue }

        $content = Get-Content -LiteralPath $taskFile.FullName -Raw -Encoding UTF8
        $taskWorkflowMode = Get-TaskField $content "workflow_mode"
        if (-not $taskWorkflowMode) { $taskWorkflowMode = "standard" }

        $title = Get-TaskField $content "title"
        $goal = Get-MarkdownSection $content "Goal"
        if (-not $title -and -not $goal) {
            continue
        }
        $mode = Get-TaskField $content "mode"
        if (-not $mode) { $mode = "serial" }
        $workMode = Get-TaskField $content "work_mode"
        if (-not $workMode) { $workMode = "MVP" }
        $allowedFiles = Get-AllowedFilesFromTask $content

        try {
            $inferred = powershell -NoProfile -ExecutionPolicy Bypass -File $classifierPath -Title $title -Goal $goal -AllowedFiles $allowedFiles -Mode $mode -WorkMode $workMode -Json | ConvertFrom-Json
        }
        catch {
            Add-CheckError "Workflow mode inference failed for .ai-team/tasks/$($taskFile.Name): $($_.Exception.Message)"
            continue
        }

        if ($inferred.workflow_mode -eq "strict" -and $taskWorkflowMode -ne "strict") {
            Add-CheckError "Task .ai-team/tasks/$($taskFile.Name) is likely strict risk but workflow_mode is '$taskWorkflowMode'."
        }
        elseif ($inferred.workflow_mode -eq "parallel" -and $taskWorkflowMode -ne "parallel") {
            Add-CheckError "Task .ai-team/tasks/$($taskFile.Name) is marked mode=parallel but workflow_mode is '$taskWorkflowMode'."
        }
    }
}

function Test-CompactContext {
    $contextScript = Join-Path $aiTeamRoot "scripts\Get-AiTeamContext.ps1"
    $tasksDir = Join-Path $aiTeamRoot "tasks"
    if (-not (Test-Path -LiteralPath $contextScript) -or -not (Test-Path -LiteralPath $tasksDir)) { return }

    $taskFile = Get-ChildItem -LiteralPath $tasksDir -Filter "*.md" |
        Where-Object {
            if ($_.Name -eq "TEMPLATE.md") { return $false }
            $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
            return ($content -match '(?m)^task_id:')
        } |
        Sort-Object Name |
        Select-Object -First 1

    if (-not $taskFile) { return }

    $taskId = $taskFile.BaseName
    $taskContent = Get-Content -LiteralPath $taskFile.FullName -Raw -Encoding UTF8
    if ($taskContent -match '(?m)^task_id:[ \t]*["'']?([^"''\r\n]+)') {
        $taskId = $Matches[1].Trim()
    }

    try {
        $context = powershell -NoProfile -ExecutionPolicy Bypass -File $contextScript -TaskId $taskId
        $text = $context -join [Environment]::NewLine
        foreach ($required in @("===== Task: $taskId =====", "===== Task State =====", "===== Recent Run Evidence =====")) {
            if (-not $text.Contains($required)) {
                Add-CheckError "Compact context is missing expected section: $required"
            }
        }
        if ($text -match '"tasks"' -or $text -match '"runs"') {
            Add-CheckError "Compact context dumped JSON state instead of summaries."
        }
    }
    catch {
        Add-CheckError "Compact context failed for task '$taskId': $($_.Exception.Message)"
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
    "VERSION.json",
    "commands.json",
    "memory\project-brief.md",
    "memory\production-mode.md",
    "memory\technology-policy.md",
    "memory\pitfalls.md",
    "memory\patterns.md",
    "policies\command-policy.md",
    "policies\workflow-modes.md",
    "checklists\plan-gate.md",
    "checklists\project-intake-gate.md",
    "checklists\review-gate.md",
    "checklists\integration-gate.md",
    "checklists\release-gate.md",
    "prompts\dispatcher.md",
    "prompts\executor.md",
    "prompts\reviewer-verifier.md",
    "scripts\Get-AiTeamContext.ps1",
    "scripts\Get-AiTeamWorkflowMode.ps1",
    "scripts\Get-AiTeamIntake.ps1",
    "scripts\Get-AiTeamStatus.ps1",
    "scripts\Measure-AiTeamContext.ps1",
    "scripts\New-AiTeamReviewReport.ps1",
    "scripts\Sync-AiTeamState.ps1",
    "scripts\Test-AiTeamCommand.ps1",
    "scripts\Test-AiTeamDiffBoundary.ps1",
    "scripts\Test-AiTeamStateMachine.ps1",
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

Test-JsonFile "VERSION.json"

$taskTemplatePath = Join-Path $aiTeamRoot "tasks\TEMPLATE.md"
if (Test-Path -LiteralPath $taskTemplatePath) {
    $taskTemplate = Get-Content -LiteralPath $taskTemplatePath -Raw -Encoding UTF8
    if ($taskTemplate -notmatch "(?m)^work_mode:") {
        Add-CheckError "Task template is missing work_mode."
    }
    if ($taskTemplate -notmatch "(?m)^workflow_mode:") {
        Add-CheckError "Task template is missing workflow_mode."
    }
}

Test-PowerShellSyntax "scripts"
Test-PowerShellSyntax "hooks"
Test-CommandRiskClassifier
Test-TaskFileBoundaries
Test-WorkflowModeClassification
Test-CompactContext

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

$stateMachineScript = Join-Path $aiTeamRoot "scripts\Test-AiTeamStateMachine.ps1"
if (Test-Path -LiteralPath $stateMachineScript) {
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $stateMachineScript | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Add-CheckError "State machine check failed."
        }
    }
    catch {
        Add-CheckError "State machine check failed: $($_.Exception.Message)"
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

$budgetScript = Join-Path $aiTeamRoot "scripts\Measure-AiTeamContext.ps1"
if (Test-Path -LiteralPath $budgetScript) {
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $budgetScript -Json | ConvertFrom-Json | Out-Null
    }
    catch {
        Add-CheckError "Context budget check failed: $($_.Exception.Message)"
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
Write-Host "Checked structure, JSON, PowerShell syntax, command risk rules, workflow modes, state machine, sync, status, compact context, and context budget."
