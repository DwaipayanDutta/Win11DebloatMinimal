# Modules/Apps.ps1 — UWP / provisioned app removal
# Every function is safe to call multiple times (idempotent).
# App removal is NOT reversible via the restore script; use Windows Settings > Apps to reinstall.

# ---------------------------------------------------------------------------
# Internal helper — removes both per-user package and provisioned package
# ---------------------------------------------------------------------------

function Remove-UwpApp {
    param(
        [Parameter(Mandatory)][string] $Pattern,
        [Parameter(Mandatory)][string] $DisplayName
    )
    if ($Script:DryRun) {
        Write-Log "[DRY-RUN] Would remove packages matching: *$Pattern*" DEBUG
        return
    }

    $pkgs  = Get-AppxPackage          -Name "*$Pattern*" -AllUsers -ErrorAction SilentlyContinue
    $provs = Get-AppxProvisionedPackage -Online           -ErrorAction SilentlyContinue |
             Where-Object DisplayName -like "*$Pattern*"

    if (-not $pkgs -and -not $provs) {
        Write-Log "$DisplayName — not found or already removed" INFO
        return
    }

    foreach ($p in $pkgs) {
        try {
            Remove-AppxPackage -Package $p.PackageFullName -AllUsers -ErrorAction Stop
            Write-Log "Removed package: $($p.Name)" SUCCESS
        } catch {
            Write-Log "Could not remove $($p.Name) — $_" WARN
        }
    }

    foreach ($p in $provs) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop | Out-Null
            Write-Log "Removed provisioned: $($p.DisplayName)" SUCCESS
        } catch {
            Write-Log "Could not remove provisioned $($p.DisplayName) — $_" WARN
        }
    }
}

# ---------------------------------------------------------------------------
# OneDrive — separate handler because it uses its own uninstaller
# ---------------------------------------------------------------------------

function Remove-OneDrive {
    Invoke-Tweak 'Remove OneDrive' {
        Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue

        $installer = @(
            "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
            "$env:SystemRoot\System32\OneDriveSetup.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1

        if ($installer) {
            Start-Process -FilePath $installer -ArgumentList '/uninstall' -Wait -WindowStyle Hidden
            Write-Log 'OneDrive uninstalled' SUCCESS
        } else {
            Write-Log 'OneDrive installer not found — may already be removed' WARN
        }

        # Remove leftover directories
        @(
            "$env:UserProfile\OneDrive",
            "$env:LocalAppData\Microsoft\OneDrive",
            'C:\OneDriveTemp'
        ) | Where-Object { Test-Path $_ } |
            ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }

        # Remove from Explorer sidebar
        Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{018D5C66-4533-4fd0-A96D-5149324A4B3A}' `
            'System.IsPinned' 0 -Description 'OneDrive Explorer sidebar pin'
    }
}

# ---------------------------------------------------------------------------
# Individual app wrappers
# ---------------------------------------------------------------------------

function Remove-XboxApp            { Invoke-Tweak 'Remove Xbox App'              { Remove-UwpApp 'XboxApp'                     'Xbox App' } }
function Remove-XboxGamingOverlay  { Invoke-Tweak 'Remove Xbox Game Bar'         { Remove-UwpApp 'XboxGamingOverlay'           'Xbox Game Bar' } }
function Remove-MicrosoftTeams     { Invoke-Tweak 'Remove Microsoft Teams'       { Remove-UwpApp 'Teams'                       'Teams' } }
function Remove-Cortana            { Invoke-Tweak 'Remove Cortana App'           { Remove-UwpApp 'Cortana'                     'Cortana' } }
function Remove-Skype              { Invoke-Tweak 'Remove Skype'                 { Remove-UwpApp 'SkypeApp'                    'Skype' } }
function Remove-Solitaire          { Invoke-Tweak 'Remove Solitaire Collection'  { Remove-UwpApp 'solitairecollection'         'Solitaire' } }
function Remove-BingWeather        { Invoke-Tweak 'Remove Weather'               { Remove-UwpApp 'BingWeather'                 'Weather' } }
function Remove-BingNews           { Invoke-Tweak 'Remove News'                  { Remove-UwpApp 'BingNews'                    'Microsoft News' } }
function Remove-BingFinance        { Invoke-Tweak 'Remove Money'                 { Remove-UwpApp 'BingFinance'                 'Money App' } }
function Remove-BingSports         { Invoke-Tweak 'Remove Sports'                { Remove-UwpApp 'BingSports'                  'Sports App' } }
function Remove-GetHelp            { Invoke-Tweak 'Remove Get Help'              { Remove-UwpApp 'GetHelp'                     'Get Help' } }
function Remove-FeedbackHub        { Invoke-Tweak 'Remove Feedback Hub'          { Remove-UwpApp 'MicrosoftWindowsFeedbackHub' 'Feedback Hub' } }
function Remove-BingMaps           { Invoke-Tweak 'Remove Maps'                  { Remove-UwpApp 'BingMaps'                    'Maps' } }
function Remove-3DViewer           { Invoke-Tweak 'Remove 3D Viewer'             { Remove-UwpApp '3DViewer'                    '3D Viewer' } }
function Remove-Paint3D            { Invoke-Tweak 'Remove Paint 3D'              { Remove-UwpApp 'Paint3D'                     'Paint 3D' } }
function Remove-VoiceRecorder      { Invoke-Tweak 'Remove Voice Recorder'        { Remove-UwpApp 'SoundRecorder'               'Voice Recorder' } }
function Remove-LegacyMediaPlayer  { Invoke-Tweak 'Remove Legacy Media Player'   { Remove-UwpApp 'ZuneMusic'                   'Media Player (Legacy)' } }
function Remove-StickyNotes        { Invoke-Tweak 'Remove Sticky Notes'          { Remove-UwpApp 'StickyNotes'                 'Sticky Notes' } }
function Remove-MicrosoftFamily    { Invoke-Tweak 'Remove Family Safety'         { Remove-UwpApp 'MicrosoftFamily'             'Microsoft Family Safety' } }
function Remove-PowerAutomate      { Invoke-Tweak 'Remove Power Automate'        { Remove-UwpApp 'PowerAutomateDesktop'        'Power Automate' } }
function Remove-Clipchamp          { Invoke-Tweak 'Remove Clipchamp'             { Remove-UwpApp 'Clipchamp'                   'Clipchamp' } }
function Remove-QuickAssist        { Invoke-Tweak 'Remove Quick Assist'          { Remove-UwpApp 'QuickAssist'                 'Quick Assist' } }
function Remove-MixedReality       { Invoke-Tweak 'Remove Mixed Reality Portal'  { Remove-UwpApp 'MixedReality.Portal'         'Mixed Reality Portal' } }
function Remove-YourPhone          { Invoke-Tweak 'Remove Phone Link'            { Remove-UwpApp 'YourPhone'                   'Phone Link (Your Phone)' } }
