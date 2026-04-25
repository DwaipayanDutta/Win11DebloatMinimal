<#
.SYNOPSIS
    Win11DebloatMinimal  -  modular, safe, and reversible Windows debloat tool.

.DESCRIPTION
    Removes bloatware, reduces telemetry, and applies performance tweaks.
    Every change is logged, optional, and captured in a restore script.

.PARAMETER Profile
    Apply a preset profile without the GUI: Minimal | Recommended | Aggressive

.PARAMETER DryRun
    Preview what would change  -  nothing is written to the registry or disk.

.PARAMETER NoUI
    Run headlessly (requires -Profile). Useful for scripted/automated deployments.

.PARAMETER Restore
    Path to a previously generated restore script. Runs it to undo changes.

.EXAMPLE
    # Interactive GUI (default)
    .\Win11DebloatMinimal.ps1

.EXAMPLE
    # Headless minimal profile, dry run
    .\Win11DebloatMinimal.ps1 -Profile Minimal -DryRun -NoUI

.EXAMPLE
    # Apply recommended profile silently
    .\Win11DebloatMinimal.ps1 -Profile Recommended -NoUI

.EXAMPLE
    # Undo a previous run
    .\Win11DebloatMinimal.ps1 -Restore "$env:TEMP\Win11Debloat\Restore_20260426_120000.ps1"
#>

#Requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('Minimal', 'Recommended', 'Aggressive')]
    [string] $Profile = '',

    [switch] $DryRun,
    [switch] $NoUI,
    [string] $Restore = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------------------------------------------------------------------------
# Auto-elevate (GUI mode only  -  NoUI callers should handle elevation themselves)
# ---------------------------------------------------------------------------

function Request-Elevation {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    if (([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return
    }
    if ($NoUI) {
        Write-Warning 'Not running as Administrator. Relaunch from an elevated prompt.'
        exit 1
    }
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    if ($Profile)  { $args += " -Profile $Profile" }
    if ($DryRun)   { $args += ' -DryRun' }
    if ($NoUI)     { $args += ' -NoUI' }
    if ($Restore)  { $args += " -Restore `"$Restore`"" }
    Start-Process powershell -ArgumentList $args -Verb RunAs
    exit
}

# ---------------------------------------------------------------------------
# Load modules
# ---------------------------------------------------------------------------

function Import-AllModules {
    . "$ScriptRoot\Core\Engine.ps1"
    . "$ScriptRoot\Modules\Apps.ps1"
    . "$ScriptRoot\Modules\Privacy.ps1"
    . "$ScriptRoot\Modules\Tweaks.ps1"
    . "$ScriptRoot\Modules\Services.ps1"
    . "$ScriptRoot\Modules\Features.ps1"
    # Profiles depend on each other  -  load in order
    . "$ScriptRoot\Profiles\Minimal.ps1"
    . "$ScriptRoot\Profiles\Recommended.ps1"
    . "$ScriptRoot\Profiles\Aggressive.ps1"
}

# ---------------------------------------------------------------------------
# Restore mode  -  run a previously saved restore script
# ---------------------------------------------------------------------------

if ($Restore) {
    if (-not (Test-Path $Restore)) {
        Write-Error "Restore script not found: $Restore"
        exit 1
    }
    Request-Elevation
    Write-Host "Running restore script: $Restore" -ForegroundColor Cyan
    & $Restore
    exit
}

# ---------------------------------------------------------------------------
# Load everything
# ---------------------------------------------------------------------------

Request-Elevation
Import-AllModules
Initialize-Engine -DryRun:$DryRun.IsPresent

# ---------------------------------------------------------------------------
# Headless profile mode (-Profile + -NoUI)
# ---------------------------------------------------------------------------

if ($Profile -and $NoUI) {
    $tweakList = switch ($Profile) {
        'Minimal'     { $Script:ProfileMinimal }
        'Recommended' { $Script:ProfileRecommended }
        'Aggressive'  { $Script:ProfileAggressive }
    }

    Write-Log "Running profile '$Profile' ($($tweakList.Count) tweaks)" INFO
    Invoke-TweakList $tweakList

    $stats = Get-EngineStats
    Write-Log "Finished  -  Applied: $($stats.Applied)  Skipped: $($stats.Skipped)  Errors: $($stats.Errors)" SUCCESS

    if (-not $DryRun -and $Script:RestoreActions.Count -gt 0) {
        Save-RestoreScript | Out-Null
    }
    exit
}

# ---------------------------------------------------------------------------
# Interactive GUI mode (default)
# ---------------------------------------------------------------------------

# If -Profile was passed without -NoUI, pre-select the profile in the UI
# by setting a global that MainForm.ps1 can read after load.
if ($Profile) {
    $Script:DefaultProfile = $Profile
}

. "$ScriptRoot\UI\MainForm.ps1"
