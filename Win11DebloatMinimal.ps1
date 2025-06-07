Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# Main Form Configuration
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows 11 Debloater - Minimal UI'
$form.Size = New-Object System.Drawing.Size(620, 530)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# =========================
# Tab Control Setup
# =========================
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(590, 320)
$tabControl.Location = New-Object System.Drawing.Point(10, 10)

# Helper function to create a CheckedListBox and return it
function New-CheckedListBox {
    param($items)
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Size = New-Object System.Drawing.Size(550, 280)
    $listBox.Location = New-Object System.Drawing.Point(10, 10)
    $listBox.CheckOnClick = $true
    $listBox.Items.AddRange($items)
    return $listBox
}

# Tab 1: Apps
$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = "Remove Apps"
$checkedListApps = New-CheckedListBox @(
    'Uninstall OneDrive',
    'Remove Xbox App',
    'Remove Microsoft Edge',
    'Remove Microsoft Teams',
    'Remove Cortana',
    'Remove Skype',
    'Remove Solitaire Collection',
    'Remove News and Interests',
    'Remove Weather App'
)
$tabApps.Controls.Add($checkedListApps)

# Tab 2: Privacy
$tabPrivacy = New-Object System.Windows.Forms.TabPage
$tabPrivacy.Text = "Privacy & Telemetry"
$checkedListPrivacy = New-CheckedListBox @(
    'Disable Telemetry Services',
    'Disable Windows Tips',
    'Disable Feedback Notifications',
    'Disable Location Services',
    'Disable Advertising ID',
    'Disable Cortana (Privacy)',
    'Disable Diagnostic Data'
)
$tabPrivacy.Controls.Add($checkedListPrivacy)

# Tab 3: Security
$tabSecurity = New-Object System.Windows.Forms.TabPage
$tabSecurity.Text = "Security & Defender"
$checkedListSecurity = New-CheckedListBox @(
    'Disable Windows Defender Real-Time Protection',
    'Disable Windows Defender Scheduled Tasks',
    'Disable SmartScreen Filter',
    'Disable Windows Firewall (Not Recommended)'
)
$tabSecurity.Controls.Add($checkedListSecurity)

# Add tabs to control
$tabControl.TabPages.AddRange(@($tabApps, $tabPrivacy, $tabSecurity))
$form.Controls.Add($tabControl)

# =========================
# Status Output Box
# =========================
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ReadOnly = $true
$statusBox.ScrollBars = 'Vertical'
$statusBox.Size = New-Object System.Drawing.Size(590, 100)
$statusBox.Location = New-Object System.Drawing.Point(10, 340)
$form.Controls.Add($statusBox)

function Append-StatusText {
    param([string]$text)
    $statusBox.AppendText("[$(Get-Date -Format 'HH:mm:ss')] $text`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
}

# =========================
# Debloat Functions (Inspired by Win11Debloat)
# =========================

# Uninstall OneDrive
function Uninstall-OneDrive {
    Append-StatusText "Uninstalling OneDrive..."
    Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
    $OneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (Test-Path $OneDriveSetup) {
        Start-Process -FilePath $OneDriveSetup -ArgumentList "/uninstall" -Wait
        Append-StatusText "OneDrive uninstalled."
    } else {
        Append-StatusText "OneDriveSetup.exe not found."
    }
    Remove-Item "$env:UserProfile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove Appx Package by name pattern
function Remove-AppxPackageByName {
    param($pattern, $friendlyName)
    Append-StatusText "Removing $friendlyName..."
    $packages = Get-AppxPackage -Name "*$pattern*" -ErrorAction SilentlyContinue
    if ($packages) {
        foreach ($pkg in $packages) {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
        }
        Append-StatusText "$friendlyName removed."
    } else {
        Append-StatusText "$friendlyName not found or already removed."
    }
}

# Disable Telemetry Services
function Disable-TelemetryServices {
    Append-StatusText "Disabling telemetry services..."
    $services = @('DiagTrack', 'dmwappushservice')
    foreach ($svc in $services) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled
            Append-StatusText "Service $svc disabled."
        } else {
            Append-StatusText "Service $svc not found."
        }
    }
}

# Disable Windows Tips
function Disable-WindowsTips {
    Append-StatusText "Disabling Windows Tips..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -ErrorAction SilentlyContinue
}

# Disable Feedback Notifications
function Disable-FeedbackNotifications {
    Append-StatusText "Disabling Feedback Notifications..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -ErrorAction SilentlyContinue
}

# Disable Location Services
function Disable-LocationServices {
    Append-StatusText "Disabling Location Services..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
}

# Disable Advertising ID
function Disable-AdvertisingID {
    Append-StatusText "Disabling Advertising ID..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
}

# Disable Cortana (Privacy)
function Disable-CortanaPrivacy {
    Append-StatusText "Disabling Cortana (Privacy)..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Diagnostic Data
function Disable-DiagnosticData {
    Append-StatusText "Disabling Diagnostic Data..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Windows Defender Real-Time Protection
function Disable-WindowsDefenderRealtime {
    Append-StatusText "Disabling Windows Defender Real-Time Protection..."
    Set-MpPreference -DisableRealtimeMonitoring $true
}

# Disable Windows Defender Scheduled Tasks
function Disable-WindowsDefenderTasks {
    Append-StatusText "Disabling Windows Defender Scheduled Tasks..."
    $tasks = @(
        "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
        "Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
        "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
        "Microsoft\Windows\Windows Defender\Windows Defender Verification"
    )
    foreach ($task in $tasks) {
        $taskName = $task.Split('\')[-1]
        $taskPath = "\" + ($task.Substring(0, $task.LastIndexOf("\")))
        if (Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue) {
            Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName
            Append-StatusText "Disabled scheduled task: $task"
        }
    }
}

# Disable SmartScreen Filter
function Disable-SmartScreenFilter {
    Append-StatusText "Disabling SmartScreen Filter..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -ErrorAction SilentlyContinue
}

# Disable Windows Firewall (Not Recommended)
function Disable-WindowsFirewall {
    Append-StatusText "Disabling Windows Firewall..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

# =========================
# Buttons
# =========================
function New-UIButton {
    param($text, $x, $clickHandler)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(100, 30)
    $btn.Location = New-Object System.Drawing.Point($x, 450)
    if ($clickHandler) { $btn.Add_Click($clickHandler) }
    return $btn
}

# Select All
$buttonSelectAll = New-UIButton "Select All" 10 {
    foreach ($tab in $tabControl.TabPages) {
        $clb = $tab.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckedListBox] }
        for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) }
    }
}
$form.Controls.Add($buttonSelectAll)

# Deselect All
$buttonDeselectAll = New-UIButton "Deselect All" 120 {
    foreach ($tab in $tabControl.TabPages) {
        $clb = $tab.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckedListBox] }
        for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
    }
}
$form.Controls.Add($buttonDeselectAll)

# Apply
$buttonApply = New-UIButton "Apply Changes" 480 {
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Are you sure you want to apply these changes?",
        "Confirm",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Append-StatusText "Applying selected debloat actions..."

    # Process Apps tab
    foreach ($item in $checkedListApps.CheckedItems) {
        switch ($item) {
            'Uninstall OneDrive' { Uninstall-OneDrive }
            'Remove Xbox App' { Remove-AppxPackageByName 'xboxapp' 'Xbox App' }
            'Remove Microsoft Edge' { Append-StatusText "Microsoft Edge removal skipped (manual removal recommended)." }
            'Remove Microsoft Teams' { Remove-AppxPackageByName 'Teams' 'Microsoft Teams' }
            'Remove Cortana' { Remove-AppxPackageByName 'Cortana' 'Cortana' }
            'Remove Skype' { Remove-AppxPackageByName 'SkypeApp' 'Skype' }
            'Remove Solitaire Collection' { Remove-AppxPackageByName 'solitairecollection' 'Solitaire Collection' }
            'Remove News and Interests' {
                Append-StatusText "Disabling News and Interests..."
                $task = Get-ScheduledTask -TaskName "ShellExperienceHost" -ErrorAction SilentlyContinue
                if ($task) {
                    Disable-ScheduledTask -TaskName "ShellExperienceHost"
                    Append-StatusText "News and Interests disabled."
                } else {
                    Append-StatusText "News and Interests task not found."
                }
            }
            'Remove Weather App' { Remove-AppxPackageByName 'BingWeather' 'Weather App' }
        }
    }

    # Process Privacy tab
    foreach ($item in $checkedListPrivacy.CheckedItems) {
        switch ($item) {
            'Disable Telemetry Services' { Disable-TelemetryServices }
            'Disable Windows Tips' { Disable-WindowsTips }
            'Disable Feedback Notifications' { Disable-FeedbackNotifications }
            'Disable Location Services' { Disable-LocationServices }
            'Disable Advertising ID' { Disable-AdvertisingID }
            'Disable Cortana (Privacy)' { Disable-CortanaPrivacy }
            'Disable Diagnostic Data' { Disable-DiagnosticData }
        }
    }

    # Process Security tab
    foreach ($item in $checkedListSecurity.CheckedItems) {
        switch ($item) {
            'Disable Windows Defender Real-Time Protection' { Disable-WindowsDefenderRealtime }
            'Disable Windows Defender Scheduled Tasks' { Disable-WindowsDefenderTasks }
            'Disable SmartScreen Filter' { Disable-SmartScreenFilter }
            'Disable Windows Firewall (Not Recommended)' { Disable-WindowsFirewall }
        }
    }

    Append-StatusText "Debloating complete. Restart recommended."
    [System.Windows.Forms.MessageBox]::Show("Done! Please restart your PC.", "Complete")
}
$form.Controls.Add($buttonApply)

# =========================
# Run Form
# =========================
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
