#Requires -Version 5.1
# Core/Engine.ps1
# Central engine: logging, dry-run gate, rollback registry, and module runner.
# All other modules depend on functions defined here.

Set-StrictMode -Version Latest

$Script:EngineVersion  = '3.0'
$Script:DryRun         = $false
$Script:LogFile        = $null
$Script:LogCallback    = $null   # scriptblock(message, type) injected by UI
$Script:RestoreActions = [System.Collections.Generic.List[psobject]]::new()
$Script:Stats          = @{ Applied = 0; Skipped = 0; Errors = 0 }
$Script:DefaultProfile = $null   # optionally set by CLI before loading UI

# ---------------------------------------------------------------------------
# Initialise
# ---------------------------------------------------------------------------

function Initialize-Engine {
    param(
        [bool]   $DryRun      = $false,
        [string] $LogDir      = "$env:TEMP\Win11Debloat",
        [scriptblock] $LogCallback = $null
    )
    $Script:DryRun      = $DryRun
    $Script:LogCallback = $LogCallback
    $Script:Stats       = @{ Applied = 0; Skipped = 0; Errors = 0 }
    $Script:RestoreActions.Clear()

    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $Script:LogFile = "$LogDir\Debloat_$ts.log"

    Write-Log "Win11DebloatMinimal v$Script:EngineVersion initialised" INFO
    if ($Script:DryRun) { Write-Log '*** DRY-RUN MODE — no changes will be written ***' WARN }
    Write-Log "Log: $Script:LogFile" INFO
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

function Write-Log {
    param(
        [string] $Message,
        [ValidateSet('INFO','SUCCESS','WARN','ERROR','DEBUG')]
        [string] $Type = 'INFO'
    )
    $ts    = Get-Date -Format 'HH:mm:ss'
    $entry = "[$ts][$Type] $Message"

    if ($Script:LogFile) {
        Add-Content -Path $Script:LogFile -Value $entry -ErrorAction SilentlyContinue
    }

    if ($Script:LogCallback) {
        & $Script:LogCallback $entry $Type
    } else {
        $color = switch ($Type) {
            'ERROR'   { 'Red' }
            'SUCCESS' { 'Green' }
            'WARN'    { 'Yellow' }
            'DEBUG'   { 'DarkGray' }
            default   { 'White' }
        }
        Write-Host $entry -ForegroundColor $color
    }
}

# ---------------------------------------------------------------------------
# Registry helper — backs up original value for automatic rollback
# ---------------------------------------------------------------------------

function Set-RegistryValue {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)]         $Value,
        [string] $Type        = 'DWord',
        [string] $Description = ''
    )

    # Capture original state for rollback
    $pathExists  = Test-Path $Path
    $origValue   = $null
    $origExists  = $false
    $origType    = $Type

    if ($pathExists) {
        try {
            $origValue  = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
            $origExists = $true
            # Preserve the original registry kind so restore is faithful
            $regObj  = Get-Item -Path $Path -ErrorAction SilentlyContinue
            if ($regObj) {
                $kind    = $regObj.GetValueKind($Name)
                $origType = $kind.ToString()
            }
        } catch { }
    }

    if ($Script:DryRun) {
        Write-Log "[DRY-RUN] Set $Path\$Name = $Value ($Type)" DEBUG
        return $true
    }

    try {
        if (-not $pathExists) { New-Item -Path $Path -Force -ErrorAction Stop | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop

        if ($origExists) {
            $Script:RestoreActions.Add([pscustomobject]@{
                Action      = 'SetRegistry'
                Path        = $Path
                Name        = $Name
                Value       = $origValue
                Type        = $origType
                Description = $Description
            })
        } else {
            $Script:RestoreActions.Add([pscustomobject]@{
                Action      = 'DeleteRegistryValue'
                Path        = $Path
                Name        = $Name
                Description = $Description
            })
        }
        return $true
    } catch {
        Write-Log "Registry error at $Path\$Name — $_" ERROR
        $Script:Stats.Errors++
        return $false
    }
}

# ---------------------------------------------------------------------------
# Service helper — captures startup type for rollback
# ---------------------------------------------------------------------------

function Disable-ServiceSafe {
    param(
        [Parameter(Mandatory)][string] $ServiceName,
        [string] $FriendlyName = ''
    )
    if (-not $FriendlyName) { $FriendlyName = $ServiceName }

    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $svc) {
        Write-Log "Service not found: $FriendlyName" WARN
        return $false
    }

    $origStartType = $svc.StartType
    $wasRunning    = $svc.Status -eq 'Running'

    if ($Script:DryRun) {
        Write-Log "[DRY-RUN] Disable service $FriendlyName (currently $origStartType)" DEBUG
        return $true
    }

    try {
        if ($wasRunning) { Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue }
        Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop

        $Script:RestoreActions.Add([pscustomobject]@{
            Action        = 'RestoreService'
            Name          = $ServiceName
            FriendlyName  = $FriendlyName
            OrigStartType = $origStartType.ToString()
            WasRunning    = $wasRunning
            Description   = "Restore service: $FriendlyName"
        })
        Write-Log "Service disabled: $FriendlyName" SUCCESS
        return $true
    } catch {
        Write-Log "Could not disable service $FriendlyName — $_" ERROR
        $Script:Stats.Errors++
        return $false
    }
}

# ---------------------------------------------------------------------------
# Tweak runner — error isolation and stats tracking for each named tweak
# ---------------------------------------------------------------------------

function Invoke-Tweak {
    param(
        [Parameter(Mandatory, Position = 0)][string]      $Name,
        [Parameter(Mandatory, Position = 1)][scriptblock] $Action,
        [switch] $Dangerous
    )
    if ($Dangerous) { Write-Log "CAUTION: '$Name' is marked potentially dangerous" WARN }
    Write-Log "Applying: $Name" INFO
    try {
        & $Action
        $Script:Stats.Applied++
        Write-Log "Done:     $Name" SUCCESS
    } catch {
        Write-Log "Failed:   $Name — $_" ERROR
        $Script:Stats.Errors++
    }
}

# ---------------------------------------------------------------------------
# Run a list of tweak function names (used by profile and UI apply)
# ---------------------------------------------------------------------------

function Invoke-TweakList {
    param([string[]] $TweakNames)
    foreach ($name in $TweakNames) {
        $fn = Get-Item -Path "function:$name" -ErrorAction SilentlyContinue
        if ($fn) {
            try { & $fn } catch { Write-Log "Uncaught error in $name — $_" ERROR; $Script:Stats.Errors++ }
        } else {
            Write-Log "Tweak function not found: $name" WARN
            $Script:Stats.Skipped++
        }
    }
}

# ---------------------------------------------------------------------------
# Restore script generator
# ---------------------------------------------------------------------------

function Save-RestoreScript {
    param([string] $OutputPath = '')
    if (-not $OutputPath) {
        $ts         = Get-Date -Format 'yyyyMMdd_HHmmss'
        $OutputPath = "$env:TEMP\Win11Debloat\Restore_$ts.ps1"
    }
    $dir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $lines = @(
        '#Requires -RunAsAdministrator',
        "# Win11DebloatMinimal Restore Script — generated $(Get-Date)",
        "# Reverts changes made by Win11DebloatMinimal v$Script:EngineVersion",
        '',
        'Write-Host "Restoring Windows settings..." -ForegroundColor Cyan',
        ''
    )

    foreach ($a in $Script:RestoreActions) {
        $lines += "# $($a.Description)"
        switch ($a.Action) {
            'SetRegistry' {
                $v = if ($a.Value -is [string]) { "'$($a.Value)'" } else { $a.Value }
                $lines += "Set-ItemProperty -Path '$($a.Path)' -Name '$($a.Name)' -Value $v -Type '$($a.Type)' -ErrorAction SilentlyContinue"
            }
            'DeleteRegistryValue' {
                $lines += "Remove-ItemProperty -Path '$($a.Path)' -Name '$($a.Name)' -ErrorAction SilentlyContinue"
            }
            'RestoreService' {
                $lines += "Set-Service -Name '$($a.Name)' -StartupType $($a.OrigStartType) -ErrorAction SilentlyContinue"
                if ($a.WasRunning) {
                    $lines += "Start-Service -Name '$($a.Name)' -ErrorAction SilentlyContinue"
                }
            }
        }
        $lines += ''
    }

    $lines += 'Write-Host "Restore complete. Restart recommended." -ForegroundColor Green'
    $lines -join "`n" | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Log "Restore script saved: $OutputPath" SUCCESS
    return $OutputPath
}

# ---------------------------------------------------------------------------
# Admin check
# ---------------------------------------------------------------------------

function Test-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-EngineStats { return $Script:Stats }
