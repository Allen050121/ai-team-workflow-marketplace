param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$InputText,

    [switch]$NoClipboard
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$AiScript = Join-Path $ScriptDir "ai.ps1"

function Invoke-AiTeam {
    param(
        [string[]]$ArgsList
    )

    $fullArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $AiScript)
    $fullArgs += $ArgsList

    if (-not $NoClipboard) {
        $commandName = $ArgsList[0]
        if ($commandName -eq "dispatch" -or $commandName -eq "exec" -or $commandName -eq "review" -or $commandName -eq "memory" -or $commandName -eq "integrate") {
            $fullArgs += "-Clipboard"
        }
    }

    & powershell @fullArgs
}

function Show-AiTeamHelp {
    Write-Host ""
    Write-Host "AI Team Console"
    Write-Host ""
    Write-Host "Use natural language:"
    Write-Host "  .\ai ""I want to build a todo app with login and task list"""
    Write-Host ""
    Write-Host "Or use short commands:"
    Write-Host "  .\ai exec 001-app-shell"
    Write-Host "  .\ai review 001-app-shell"
    Write-Host "  .\ai worktree 001-app-shell"
    Write-Host "  .\ai new 001-app-shell ""Build app shell"""
    Write-Host "  .\ai status"
    Write-Host "  .\ai hooks"
    Write-Host ""
    Write-Host "Generated agent bundles are copied to clipboard by default."
}

function Split-FirstWord {
    param([string]$Text)

    $trimmed = $Text.Trim()
    if (-not $trimmed) {
        return @("", "")
    }

    $index = $trimmed.IndexOf(" ")
    if ($index -lt 0) {
        return @($trimmed, "")
    }

    return @($trimmed.Substring(0, $index), $trimmed.Substring($index + 1).Trim())
}

$text = ($InputText -join " ").Trim()

if (-not $text) {
    Show-AiTeamHelp
    exit 0
}

$parts = Split-FirstWord $text
$command = $parts[0].ToLowerInvariant()
$rest = $parts[1]

switch ($command) {
    "help" {
        Show-AiTeamHelp
    }
    "status" {
        Invoke-AiTeam @("status")
    }
    "hooks" {
        Invoke-AiTeam @("hooks")
    }
    "exec" {
        if (-not $rest) { throw "Usage: .\ai exec TASK_ID" }
        Invoke-AiTeam @("exec", $rest)
    }
    "review" {
        if (-not $rest) { throw "Usage: .\ai review TASK_ID" }
        Invoke-AiTeam @("review", $rest)
    }
    "worktree" {
        if (-not $rest) { throw "Usage: .\ai worktree TASK_ID" }
        Invoke-AiTeam @("worktree", $rest)
    }
    "memory" {
        Invoke-AiTeam @("memory", $rest)
    }
    "integrate" {
        Invoke-AiTeam @("integrate", $rest)
    }
    "new" {
        $newParts = Split-FirstWord $rest
        if (-not $newParts[0] -or -not $newParts[1]) {
            throw "Usage: .\ai new TASK_ID TITLE"
        }
        Invoke-AiTeam @("new", $newParts[0], $newParts[1])
    }
    default {
        Invoke-AiTeam @("dispatch", $text)
    }
}
