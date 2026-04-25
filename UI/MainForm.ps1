# UI/MainForm.ps1
# Windows Forms interface. Depends on Engine.ps1 and all Modules being dot-sourced first.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------------------------------------------------------------------------
# Colours & fonts
# ---------------------------------------------------------------------------
$C_BG       = [System.Drawing.Color]::FromArgb(25,  25,  25)
$C_PANEL    = [System.Drawing.Color]::FromArgb(40,  40,  43)
$C_TAB      = [System.Drawing.Color]::FromArgb(45,  45,  48)
$C_LIST     = [System.Drawing.Color]::FromArgb(32,  32,  35)
$C_ACCENT   = [System.Drawing.Color]::FromArgb(0,  120, 215)
$C_DANGER   = [System.Drawing.Color]::FromArgb(196,  43,  28)
$C_TEXT     = [System.Drawing.Color]::White
$C_SUBTEXT  = [System.Drawing.Color]::FromArgb(180, 180, 180)
$C_LOG      = [System.Drawing.Color]::FromArgb(15,  15,  15)
$C_LOGTEXT  = [System.Drawing.Color]::FromArgb(0,  220,  80)

$F_HEADER   = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$F_NORMAL   = New-Object System.Drawing.Font('Segoe UI', 9)
$F_BOLD     = New-Object System.Drawing.Font('Segoe UI', 9,  [System.Drawing.FontStyle]::Bold)
$F_LOG      = New-Object System.Drawing.Font('Consolas',  9)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function New-Label {
    param([string]$Text, [int]$X, [int]$Y, [System.Drawing.Font]$Font = $F_NORMAL,
          [System.Drawing.Color]$Color = $C_TEXT, [bool]$Auto = $true)
    $l = New-Object System.Windows.Forms.Label
    $l.Text      = $Text
    $l.Font      = $Font
    $l.ForeColor = $Color
    $l.Location  = [System.Drawing.Point]::new($X, $Y)
    $l.AutoSize  = $Auto
    $l.BackColor = [System.Drawing.Color]::Transparent
    return $l
}

function New-Button {
    param([string]$Text, [int]$X, [int]$Y, [int]$W = 110, [int]$H = 32,
          [System.Drawing.Color]$BG = $C_ACCENT, [scriptblock]$Click = $null)
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $Text
    $b.Location  = [System.Drawing.Point]::new($X, $Y)
    $b.Size      = [System.Drawing.Size]::new($W, $H)
    $b.BackColor = $BG
    $b.ForeColor = $C_TEXT
    $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $b.Font      = $F_BOLD
    $b.FlatAppearance.BorderSize = 0
    if ($Click) { $b.Add_Click($Click) }
    return $b
}

function New-CheckList {
    param([string[]]$Items, [int]$W = 670, [int]$H = 300)
    $clb = New-Object System.Windows.Forms.CheckedListBox
    $clb.Size         = [System.Drawing.Size]::new($W, $H)
    $clb.Location     = [System.Drawing.Point]::new(8, 8)
    $clb.CheckOnClick = $true
    $clb.BackColor    = $C_LIST
    $clb.ForeColor    = $C_TEXT
    $clb.Font         = $F_NORMAL
    $clb.BorderStyle  = [System.Windows.Forms.BorderStyle]::None
    foreach ($item in $Items) { $clb.Items.Add($item) | Out-Null }
    return $clb
}

# Map display label → function name (used when Apply is clicked)
$Script:TweakMap = [ordered]@{}

function Add-TabPage {
    param([string]$Title, [object[]]$Items)
    $tp  = New-Object System.Windows.Forms.TabPage
    $tp.Text      = $Title
    $tp.BackColor = $C_TAB

    $labels    = $Items | ForEach-Object { $_.Label }
    $clb       = New-CheckList $labels
    $tp.Controls.Add($clb)

    foreach ($item in $Items) {
        $Script:TweakMap[$item.Label] = $item.Fn
    }

    return $tp, $clb
}

# ---------------------------------------------------------------------------
# Tab data — Label + function name pairs
# ---------------------------------------------------------------------------

$tabDataApps = @(
    @{ Label = 'Remove OneDrive';                    Fn = 'Remove-OneDrive' }
    @{ Label = 'Remove Xbox App';                    Fn = 'Remove-XboxApp' }
    @{ Label = 'Remove Xbox Game Bar';               Fn = 'Remove-XboxGamingOverlay' }
    @{ Label = 'Remove Microsoft Teams';             Fn = 'Remove-MicrosoftTeams' }
    @{ Label = 'Remove Cortana App';                 Fn = 'Remove-Cortana' }
    @{ Label = 'Remove Skype';                       Fn = 'Remove-Skype' }
    @{ Label = 'Remove Solitaire Collection';        Fn = 'Remove-Solitaire' }
    @{ Label = 'Remove Weather (Bing)';              Fn = 'Remove-BingWeather' }
    @{ Label = 'Remove News (Bing)';                 Fn = 'Remove-BingNews' }
    @{ Label = 'Remove Maps (Bing)';                 Fn = 'Remove-BingMaps' }
    @{ Label = 'Remove 3D Viewer';                   Fn = 'Remove-3DViewer' }
    @{ Label = 'Remove Paint 3D';                    Fn = 'Remove-Paint3D' }
    @{ Label = 'Remove Voice Recorder';              Fn = 'Remove-VoiceRecorder' }
    @{ Label = 'Remove Legacy Media Player (Zune)';  Fn = 'Remove-LegacyMediaPlayer' }
    @{ Label = 'Remove Sticky Notes';                Fn = 'Remove-StickyNotes' }
    @{ Label = 'Remove Feedback Hub';                Fn = 'Remove-FeedbackHub' }
    @{ Label = 'Remove Clipchamp';                   Fn = 'Remove-Clipchamp' }
    @{ Label = 'Remove Power Automate';              Fn = 'Remove-PowerAutomate' }
    @{ Label = 'Remove Mixed Reality Portal';        Fn = 'Remove-MixedReality' }
    @{ Label = 'Remove Phone Link (Your Phone)';     Fn = 'Remove-YourPhone' }
    @{ Label = 'Remove Quick Assist';                Fn = 'Remove-QuickAssist' }
    @{ Label = 'Remove Microsoft Family Safety';     Fn = 'Remove-MicrosoftFamily' }
)

$tabDataPrivacy = @(
    @{ Label = 'Disable Telemetry Services';             Fn = 'Disable-TelemetryServices' }
    @{ Label = 'Disable Diagnostic Data';                Fn = 'Disable-DiagnosticData' }
    @{ Label = 'Disable Advertising ID';                 Fn = 'Disable-AdvertisingId' }
    @{ Label = 'Disable Location Services';              Fn = 'Disable-LocationServices' }
    @{ Label = 'Disable Cortana & Bing Search';          Fn = 'Disable-Cortana' }
    @{ Label = 'Disable Activity History';               Fn = 'Disable-ActivityHistory' }
    @{ Label = 'Disable Tailored Experiences';           Fn = 'Disable-TailoredExperiences' }
    @{ Label = 'Disable Feedback Notifications';         Fn = 'Disable-FeedbackNotifications' }
    @{ Label = 'Disable Handwriting Data Collection';    Fn = 'Disable-HandwritingData' }
    @{ Label = 'Disable Inking & Typing Personalization';Fn = 'Disable-InkingPersonalization' }
    @{ Label = 'Disable Cloud / Suggested Content';      Fn = 'Disable-CloudContent' }
    @{ Label = 'Disable Windows Tips & Suggestions';     Fn = 'Disable-WindowsTips' }
    @{ Label = 'Disable Account Info App Access';        Fn = 'Disable-AccountInfoAccess' }
    @{ Label = 'Disable Delivery Optimization (P2P)';    Fn = 'Disable-DeliveryOptimization' }
)

$tabDataTweaks = @(
    @{ Label = 'Show File Extensions';                   Fn = 'Enable-FileExtensions' }
    @{ Label = 'Show Hidden Files & Folders';            Fn = 'Enable-HiddenFiles' }
    @{ Label = 'Disable Taskbar Widgets';                Fn = 'Disable-TaskbarWidgets' }
    @{ Label = 'Disable Taskbar Chat (Teams)';           Fn = 'Disable-TaskbarChat' }
    @{ Label = 'Align Taskbar Left (Win 11)';            Fn = 'Set-TaskbarAlignLeft' }
    @{ Label = 'Disable Auto-Install Suggested Apps';    Fn = 'Disable-AutoInstallApps' }
    @{ Label = 'Disable Taskbar Search Box';             Fn = 'Disable-TaskbarSearch' }
    @{ Label = 'Disable Startup Sound';                  Fn = 'Disable-StartupSound' }
    @{ Label = 'Disable Lock Screen Blur';               Fn = 'Disable-LockScreenBlur' }
    @{ Label = 'Disable Storage Sense';                  Fn = 'Disable-StorageSense' }
    @{ Label = 'Remove OneDrive from Explorer Sidebar';  Fn = 'Disable-OneDriveSidebarPin' }
    @{ Label = 'Disable Remote Desktop (RDP)';           Fn = 'Disable-RemoteDesktop' }
    @{ Label = 'Disable Remote Assistance';              Fn = 'Disable-RemoteAssistance' }
    @{ Label = 'Disable Hibernate';                      Fn = 'Disable-Hibernate' }
    @{ Label = 'Disable Sleep on AC Power';              Fn = 'Disable-SleepOnAC' }
    @{ Label = 'Set Windows Update — Notify Only';       Fn = 'Set-WindowsUpdateNotifyOnly' }
    @{ Label = 'Clean Temp Files (>1 day old)';          Fn = 'Invoke-CleanTempFiles' }
    @{ Label = 'Clean Windows Update Cache';             Fn = 'Invoke-CleanUpdateCache' }
    @{ Label = 'DANGER: Disable SmartScreen';            Fn = 'Disable-SmartScreen' }
    @{ Label = 'DANGER: Disable Windows Defender';       Fn = 'Disable-WindowsDefender' }
    @{ Label = 'DANGER: Disable Windows Firewall';       Fn = 'Disable-WindowsFirewall' }
)

$tabDataServices = @(
    @{ Label = 'Disable DiagTrack (Telemetry)';          Fn = 'Disable-DiagTrack' }
    @{ Label = 'Disable WAP Push Service';               Fn = 'Disable-WapPush' }
    @{ Label = 'Disable Windows Error Reporting';        Fn = 'Disable-ErrorReporting' }
    @{ Label = 'Disable Remote Registry';                Fn = 'Disable-RemoteRegistrySvc' }
    @{ Label = 'Disable Xbox Live Services';             Fn = 'Disable-XboxServices' }
    @{ Label = 'Disable Geolocation Service';            Fn = 'Disable-GeolocationSvc' }
    @{ Label = 'Disable IP Helper (IPv6 tunnels)';       Fn = 'Disable-IpHelperSvc' }
    @{ Label = 'Disable Secondary Logon';                Fn = 'Disable-SecondaryLogon' }
    @{ Label = 'Disable Downloaded Maps Manager';        Fn = 'Disable-MapsBrokerSvc' }
    @{ Label = 'Disable Retail Demo Service';            Fn = 'Disable-RetailDemoSvc' }
    @{ Label = 'Disable Fax Service';                   Fn = 'Disable-FaxSvc' }
    @{ Label = 'Disable Windows Biometric Service';      Fn = 'Disable-BiometricSvc' }
    @{ Label = 'Disable Mixed Reality OpenXR Service';   Fn = 'Disable-MixedRealitySvc' }
    @{ Label = 'Disable Parental Controls Service';      Fn = 'Disable-ParentalControlsSvc' }
    @{ Label = 'DANGER: Disable Print Spooler';          Fn = 'Disable-PrintSpooler' }
)

$tabDataFeatures = @(
    @{ Label = 'Disable Internet Explorer';              Fn = 'Disable-InternetExplorer' }
    @{ Label = 'Disable PowerShell 2.0 (Legacy)';        Fn = 'Disable-PowerShellV2' }
    @{ Label = 'Disable Windows Media Player (Legacy)';  Fn = 'Disable-LegacyMediaPlayer' }
    @{ Label = 'Disable Windows Fax and Scan';           Fn = 'Disable-FaxAndScan' }
    @{ Label = 'Disable Microsoft Print to PDF';         Fn = 'Disable-PrintToPDF' }
    @{ Label = 'Disable Work Folders Client';            Fn = 'Disable-WorkFolders' }
    @{ Label = 'Disable Telnet Client';                  Fn = 'Disable-TelnetClient' }
    @{ Label = 'Disable Windows Sandbox';                Fn = 'Disable-WindowsSandbox' }
    @{ Label = 'DANGER: Disable Virtual Machine Platform';Fn = 'Disable-VirtualMachinePlatform' }
    @{ Label = 'DANGER: Disable Hyper-V';                Fn = 'Disable-HyperV' }
    @{ Label = 'DANGER: Disable WSL';                    Fn = 'Disable-WSL' }
)

# ---------------------------------------------------------------------------
# Build form
# ---------------------------------------------------------------------------

$form              = New-Object System.Windows.Forms.Form
$form.Text         = "Win11DebloatMinimal v$Script:EngineVersion"
$form.Size         = [System.Drawing.Size]::new(760, 710)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox  = $false
$form.BackColor    = $C_BG

# Header
$form.Controls.Add((New-Label 'Win11DebloatMinimal' 16 10 $F_HEADER $C_ACCENT))
$form.Controls.Add((New-Label "v$Script:EngineVersion  |  Inspired by Sophia Script & WinUtil" 20 42 $F_NORMAL $C_SUBTEXT))

# Dry-run toggle
$chkDryRun = New-Object System.Windows.Forms.CheckBox
$chkDryRun.Text      = 'Dry Run (preview only — no changes written)'
$chkDryRun.Font      = $F_NORMAL
$chkDryRun.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 50)
$chkDryRun.BackColor = [System.Drawing.Color]::Transparent
$chkDryRun.Location  = [System.Drawing.Point]::new(440, 14)
$chkDryRun.AutoSize  = $true
$chkDryRun.Checked   = $Script:DryRun
$chkDryRun.Add_CheckedChanged({
    $Script:DryRun = $chkDryRun.Checked
    $label = if ($Script:DryRun) { '[DRY-RUN] Mode ON — no changes will be written' } else { 'Dry Run off — changes WILL be applied' }
    Write-Log $label WARN
})
$form.Controls.Add($chkDryRun)

# Profile selector
$lblProfile = New-Label 'Load Profile:' 440 44 $F_NORMAL $C_SUBTEXT
$form.Controls.Add($lblProfile)

$cmbProfile = New-Object System.Windows.Forms.ComboBox
$cmbProfile.Location     = [System.Drawing.Point]::new(524, 41)
$cmbProfile.Size         = [System.Drawing.Size]::new(130, 22)
$cmbProfile.DropDownStyle = 'DropDownList'
$cmbProfile.BackColor    = $C_PANEL
$cmbProfile.ForeColor    = $C_TEXT
$cmbProfile.Font         = $F_NORMAL
@('Custom', 'Minimal', 'Recommended', 'Aggressive') | ForEach-Object { $cmbProfile.Items.Add($_) | Out-Null }
$cmbProfile.SelectedIndex = 0
$cmbProfile.Add_SelectedIndexChanged({
    $selected = $cmbProfile.SelectedItem
    if ($selected -eq 'Custom') { return }

    $profileVar = switch ($selected) {
        'Minimal'     { $Script:ProfileMinimal }
        'Recommended' { $Script:ProfileRecommended }
        'Aggressive'  { $Script:ProfileAggressive }
    }

    # Check/uncheck items matching profile function names
    foreach ($clb in $Script:AllCheckLists) {
        for ($i = 0; $i -lt $clb.Items.Count; $i++) {
            $fn = $Script:TweakMap[$clb.Items[$i]]
            $clb.SetItemChecked($i, ($fn -and $fn -in $profileVar))
        }
    }
    Write-Log "Profile '$selected' loaded — review selections and click Apply" INFO
})
$form.Controls.Add($cmbProfile)

# Tab control
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location  = [System.Drawing.Point]::new(8, 68)
$tabs.Size      = [System.Drawing.Size]::new(726, 360)
$tabs.BackColor = $C_TAB
$tabs.Font      = $F_NORMAL

$tabPageApps,     $clbApps     = Add-TabPage 'Remove Apps'     $tabDataApps
$tabPagePrivacy,  $clbPrivacy  = Add-TabPage 'Privacy'         $tabDataPrivacy
$tabPageTweaks,   $clbTweaks   = Add-TabPage 'Tweaks'          $tabDataTweaks
$tabPageServices, $clbServices = Add-TabPage 'Services'        $tabDataServices
$tabPageFeatures, $clbFeatures = Add-TabPage 'Features'        $tabDataFeatures

$tabs.TabPages.AddRange(@($tabPageApps, $tabPagePrivacy, $tabPageTweaks, $tabPageServices, $tabPageFeatures))
$form.Controls.Add($tabs)

$Script:AllCheckLists = @($clbApps, $clbPrivacy, $clbTweaks, $clbServices, $clbFeatures)

# Log output
$richLog = New-Object System.Windows.Forms.RichTextBox
$richLog.Location   = [System.Drawing.Point]::new(8, 436)
$richLog.Size       = [System.Drawing.Size]::new(726, 170)
$richLog.ReadOnly   = $true
$richLog.ScrollBars = 'Vertical'
$richLog.BackColor  = $C_LOG
$richLog.ForeColor  = $C_LOGTEXT
$richLog.Font       = $F_LOG
$richLog.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$form.Controls.Add($richLog)

# Wire up the log callback so engine output goes to the RichTextBox
$Script:LogCallback = {
    param([string]$entry, [string]$type)
    if ($richLog.IsHandleCreated) {
        $richLog.Invoke([Action]{
            $color = switch ($type) {
                'ERROR'   { [System.Drawing.Color]::FromArgb(255,  80,  80) }
                'SUCCESS' { [System.Drawing.Color]::FromArgb(  0, 220,  80) }
                'WARN'    { [System.Drawing.Color]::FromArgb(255, 200,  50) }
                'DEBUG'   { [System.Drawing.Color]::FromArgb(130, 130, 130) }
                default   { $C_LOGTEXT }
            }
            $richLog.SelectionStart  = $richLog.TextLength
            $richLog.SelectionLength = 0
            $richLog.SelectionColor  = $color
            $richLog.AppendText($entry + "`n")
            $richLog.SelectionStart  = $richLog.Text.Length
            $richLog.ScrollToCaret()
        })
    }
}

# ---------------------------------------------------------------------------
# Bottom buttons
# ---------------------------------------------------------------------------

$btnY = 618

$btnSelectAll = New-Button 'Select All' 8 $btnY 100 -Click {
    foreach ($clb in $Script:AllCheckLists) {
        for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) }
    }
}
$form.Controls.Add($btnSelectAll)

$btnDeselectAll = New-Button 'Deselect All' 116 $btnY 100 -Click {
    foreach ($clb in $Script:AllCheckLists) {
        for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
    }
}
$form.Controls.Add($btnDeselectAll)

$btnSaveRestore = New-Button 'Save Restore Script' 224 $btnY 148 -BG ([System.Drawing.Color]::FromArgb(60,120,60)) -Click {
    if ($Script:RestoreActions.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('No changes have been applied yet.', 'Nothing to save')
        return
    }
    $path = Save-RestoreScript
    [System.Windows.Forms.MessageBox]::Show("Restore script saved to:`n$path", 'Saved', 'OK', 'Information')
}
$form.Controls.Add($btnSaveRestore)

$btnApply = New-Button 'Apply Changes' 594 $btnY 140 -BG $C_ACCENT -Click {
    if (-not (Test-Administrator)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Please run this tool as Administrator.',
            'Admin Required', 'OK', 'Error')
        return
    }

    # Collect all checked items across all tabs
    $selected = [System.Collections.Generic.List[string]]::new()
    foreach ($clb in $Script:AllCheckLists) {
        foreach ($item in $clb.CheckedItems) {
            $fn = $Script:TweakMap[$item]
            if ($fn) { $selected.Add($fn) }
        }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('No items selected.', 'Nothing to do')
        return
    }

    $dryLabel = if ($Script:DryRun) { ' [DRY-RUN]' } else { '' }
    $msg = "Apply$dryLabel $($selected.Count) selected tweak(s)?$(if (-not $Script:DryRun){"`n`nA restore script will be saved to %TEMP%\Win11Debloat."})"
    $confirm = [System.Windows.Forms.MessageBox]::Show($msg, 'Confirm', 'YesNo', 'Question')
    if ($confirm -ne 'Yes') { return }

    $btnApply.Enabled = $false
    $richLog.Clear()

    Write-Log ('=' * 50) INFO
    Write-Log "Starting$dryLabel — $($selected.Count) tweaks selected" INFO
    Write-Log ('=' * 50) INFO

    Invoke-TweakList $selected

    $stats = Get-EngineStats
    Write-Log ('=' * 50) INFO
    Write-Log "Done — Applied: $($stats.Applied)  Skipped: $($stats.Skipped)  Errors: $($stats.Errors)" SUCCESS
    Write-Log ('=' * 50) INFO

    if (-not $Script:DryRun -and $Script:RestoreActions.Count -gt 0) {
        $restorePath = Save-RestoreScript
        Write-Log "Restore script: $restorePath" INFO
    }

    $btnApply.Enabled = $true

    if (-not $Script:DryRun) {
        [System.Windows.Forms.MessageBox]::Show(
            "Done!`n`nApplied: $($stats.Applied)   Errors: $($stats.Errors)`n`nRestart your PC for all changes to take effect.",
            'Complete', 'OK', 'Information')
    }
}
$form.Controls.Add($btnApply)

# ---------------------------------------------------------------------------
# Show
# ---------------------------------------------------------------------------

Write-Log "Win11DebloatMinimal v$Script:EngineVersion ready. Select tweaks or load a profile, then click Apply." INFO
if (-not (Test-Administrator)) {
    Write-Log 'WARNING: Not running as Administrator — some tweaks will fail.' WARN
}

# Pre-select a profile if one was passed via CLI
if ($Script:DefaultProfile) {
    $idx = $cmbProfile.Items.IndexOf($Script:DefaultProfile)
    if ($idx -ge 0) { $cmbProfile.SelectedIndex = $idx }
}

[System.Windows.Forms.Application]::Run($form)
