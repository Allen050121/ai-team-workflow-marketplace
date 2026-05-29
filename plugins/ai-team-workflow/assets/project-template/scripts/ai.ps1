param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet("dispatch", "exec", "review", "memory", "integrate", "new", "worktree", "status", "next", "hooks")]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$TaskId,

    [Parameter(Position = 2)]
    [string]$Text,

    [switch]$Clipboard
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..\..")

function Invoke-Role {
    param(
        [string]$Role,
        [string]$Id,
        [string]$Request
    )

    $argsList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Join-Path $ScriptDir "Start-AiTeamRole.ps1"), "-Role", $Role)
    if ($Id) {
        $argsList += @("-TaskId", $Id)
    }
    if ($Request) {
        $argsList += @("-Request", $Request)
    }
    if ($Clipboard) {
        $argsList += "-Clipboard"
    }

    & powershell @argsList
}

switch ($Command) {
    "dispatch" {
        Invoke-Role -Role "dispatcher" -Request $TaskId
    }
    "exec" {
        if (-not $TaskId) { throw "Usage: ai.ps1 exec <task-id> [-Clipboard]" }
        Invoke-Role -Role "executor" -Id $TaskId -Request $Text
    }
    "review" {
        if (-not $TaskId) { throw "Usage: ai.ps1 review <task-id> [-Clipboard]" }
        Invoke-Role -Role "reviewer" -Id $TaskId -Request $Text
    }
    "memory" {
        Invoke-Role -Role "memory" -Id $TaskId -Request $Text
    }
    "integrate" {
        Invoke-Role -Role "integration" -Request $TaskId
    }
    "new" {
        if (-not $TaskId -or -not $Text) {
            throw "Usage: ai.ps1 new <task-id> ""<title>"""
        }
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "New-AiTeamTask.ps1") -Id $TaskId -Title $Text
    }
    "worktree" {
        if (-not $TaskId) { throw "Usage: ai.ps1 worktree <task-id>" }
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "New-AiTeamWorktree.ps1") -TaskId $TaskId
    }
    "status" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "Get-AiTeamStatus.ps1")
    }
    "next" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "Get-AiTeamStatus.ps1")
    }
    "hooks" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "Install-AiTeamHooks.ps1")
    }
}
