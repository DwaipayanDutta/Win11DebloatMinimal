# Win11DebloatMinimal - Enhanced Windows Debloat Script
# Inspired by Sophia Script for Windows and ChrisTitusTech/winutil
# Version: 2.0

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# Helper Functions
# =========================

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $color = switch ($Type) {
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        "WARN" { "Yellow" }
        default { "White" }
    }
    $logEntry = "[$timestamp] [$Type] $Message"
    $richTextBox.AppendText($logEntry + "`n")
    $richTextBox.SelectionStart = $richTextBox.Text.Length
    $richTextBox.ScrollToCaret()
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Confirm-Action {
    param([string]$Message)
    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        "Confirm",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

# =========================
# Main Form Configuration
# =========================

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows 11 Debloater - Minimal UI v2.0'
$form.Size = New-Object System.Drawing.Size(750, 650)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "Win11DebloatMinimal v2.0"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$headerLabel.Location = New-Object System.Drawing.Point(20, 10)
$headerLabel.AutoSize = $true
$form.Controls.Add($headerLabel)

# Sub Header
$subHeaderLabel = New-Object System.Windows.Forms.Label
$subHeaderLabel.Text = "Inspired by Sophia Script & WinUtil"
$subHeaderLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subHeaderLabel.ForeColor = [System.Drawing.Color]::Gray
$subHeaderLabel.Location = New-Object System.Drawing.Point(22, 40)
$subHeaderLabel.AutoSize = $true
$form.Controls.Add($subHeaderLabel)

# =========================
# Tab Control Setup
# =========================

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(710, 380)
$tabControl.Location = New-Object System.Drawing.Point(10, 65)
$tabControl.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

# Helper function to create a CheckedListBox
function New-CheckedListBox {
    param($items, $height = 320)
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Size = New-Object System.Drawing.Size(670, $height)
    $listBox.Location = New-Object System.Drawing.Point(10, 10)
    $listBox.CheckOnClick = $true
    $listBox.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 38)
    $listBox.ForeColor = [System.Drawing.Color]::White
    $listBox.Items.AddRange($items)
    return $listBox
}

# =========================
# Tab 1: Apps (UWP & Bloatware)
# =========================

$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = "Remove Apps"
$checkedListApps = New-CheckedListBox @(
    'Uninstall OneDrive',
    'Remove Xbox App (Gaming)',
    'Remove Microsoft Edge',
    'Remove Microsoft Teams (Classic)',
    'Remove Teams (New)',
    'Remove Cortana',
    'Remove Skype',
    'Remove Solitaire Collection',
    'Remove News and Interests',
    'Remove Weather App',
    'Remove Get Help App',
    'Remove Tips App',
    'Remove Maps App',
    'Remove 3D Viewer',
    'Remove Paint 3D',
    'Remove Voice Recorder',
    'Remove Media Player',
    'Remove Clock App',
    'Remove Calculator App',
    'Remove Sticky Notes'
)
$tabApps.Controls.Add($checkedListApps)

# =========================
# Tab 2: Privacy & Telemetry
# =========================

$tabPrivacy = New-Object System.Windows.Forms.TabPage
$tabPrivacy.Text = "Privacy & Telemetry"
$checkedListPrivacy = New-CheckedListBox @(
    'Disable Telemetry Services',
    'Disable Windows Tips',
    'Disable Feedback Notifications',
    'Disable Location Services',
    'Disable Advertising ID',
    'Disable Cortana (Policy)',
    'Disable Diagnostic Data',
    'Disable Activity History',
    'Disable Tailored Experiences',
    'Disable Handwriting Data Collection',
    'Disable Inking & Typing Personalization',
    'Disable Cloud Optimized Content',
    'Disable Account Info Access',
    'Disable Contacts Sync',
    'Block Windows Update Delivery Optimization',
    'Set Windows Update to Notify Only'
)
$tabPrivacy.Controls.Add($checkedListPrivacy)

# =========================
# Tab 3: System Tweaks
# =========================

$tabTweaks = New-Object System.Windows.Forms.TabPage
$tabTweaks.Text = "System Tweaks"
$checkedListTweaks = New-CheckedListBox @(
    'Show File Extensions',
    'Show Hidden Files',
    'Disable SmartScreen Filter',
    'Disable Windows Security Notifications',
    'Disable Windows Defender (Not Recommended)',
    'Disable Windows Firewall (Not Recommended)',
    'Remove OneDrive from Explorer',
    'Disable Storage Sense',
    'Clean Temp Files',
    'Clean Windows Update Cache',
    'Disable Hibernate',
    'Disable Sleep Mode',
    'Remove Recycle Bin from Desktop',
    'Disable Taskbar Search (Windows 11)',
    'Disable Widgets',
    'Disable Chat (Meet)',
    'Align Taskbar to Left (Win 11)',
    'Disable Auto-install Apps',
    'Disable Startup Sound',
    'Disable Lock Screen Blur'
)
$tabTweaks.Controls.Add($checkedListTweaks)

# =========================
# Tab 4: Services
# =========================

$tabServices = New-Object System.Windows.Forms.TabPage
$tabServices.Text = "Services"
$checkedListServices = New-CheckedListBox @(
    'Disable Connected User Experience (DiagTrack)',
    'Disable WAP Push Service',
    'Disable Windows Error Reporting',
    'Disable Remote Registry',
    'Disable Xbox Services',
    'Disable Geolocation Service',
    'Disable IP Helper',
    'Disable Xbox Live Auth Manager',
    'Disable Xbox Live Game Save',
    'Disable Secondary Logon'
)
$tabServices.Controls.Add($checkedListServices)

# =========================
# Tab 5: Windows Features
# =========================

$tabFeatures = New-Object System.Windows.Forms.TabPage
$tabFeatures.Text = "Windows Features"
$checkedListFeatures = New-CheckedListBox @(
    'Disable Hyper-V',
    'Disable Windows Sandbox',
    'Disable Virtual Machine Platform',
    'Disable Windows Subsystem for Linux',
    'Disable Internet Explorer',
    'Disable Legacy Edge',
    'Disable Microsoft Print to PDF',
    'Disable Windows Fax and Scan',
    'Disable Remote Desktop',
    'Disable Windows Media Player'
)
$tabFeatures.Controls.Add($checkedListFeatures)

# Add all tabs
$tabControl.TabPages.AddRange(@($tabApps, $tabPrivacy, $tabTweaks, $tabServices, $tabFeatures))
$form.Controls.Add($tabControl)

# =========================
# Status Output Box
# =========================

$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Multiline = $true
$richTextBox.ReadOnly = $true
$richTextBox.ScrollBars = 'Vertical'
$richTextBox.Size = New-Object System.Drawing.Size(710, 120)
$richTextBox.Location = New-Object System.Drawing.Point(10, 455)
$richTextBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$richTextBox.ForeColor = [System.Drawing.Color]::Lime
$richTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($richTextBox)

# =========================
# Debloat Functions
# =========================

# Uninstall OneDrive
function Remove-OneDrive {
    Write-Log "Uninstalling OneDrive..." "INFO"
    Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
    $OneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (Test-Path $OneDriveSetup) {
        Start-Process -FilePath $OneDriveSetup -ArgumentList "/uninstall" -Wait -WindowStyle Hidden
        Write-Log "OneDrive uninstalled." "SUCCESS"
    } else {
        $OneDriveSetupX64 = "$env:SystemRoot\OneDriveSetup.exe"
        if (Test-Path $OneDriveSetupX64) {
            Start-Process -FilePath $OneDriveSetupX64 -ArgumentList "/uninstall" -Wait -WindowStyle Hidden
            Write-Log "OneDrive uninstalled." "SUCCESS"
        } else {
            Write-Log "OneDriveSetup.exe not found." "WARN"
        }
    }
    Remove-Item "$env:UserProfile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove Appx Package by name pattern
function Remove-AppxPackageByName {
    param($pattern, $friendlyName)
    Write-Log "Removing $friendlyName..." "INFO"
    $packages = Get-AppxPackage -Name "*$pattern*" -AllUsers -ErrorAction SilentlyContinue
    if ($packages) {
        foreach ($pkg in $packages) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                Write-Log "Removed: $($pkg.PackageFullName)" "SUCCESS"
            } catch {
                Write-Log "Failed to remove: $($pkg.Name)" "ERROR"
            }
        }
    } else {
        Write-Log "$friendlyName not found or already removed." "INFO"
    }
}

# Disable Telemetry Services
function Disable-TelemetryServices {
    Write-Log "Disabling telemetry services..." "INFO"
    $services = @('DiagTrack', 'dmwappushservice')
    foreach ($svc in $services) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled
            Write-Log "Service $svc disabled." "SUCCESS"
        }
    }
    # Registry tweaks for telemetry
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Windows Tips
function Disable-WindowsTips {
    Write-Log "Disabling Windows Tips..." "INFO"
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "SubscribedContent-338388Enabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $path -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Windows Tips disabled." "SUCCESS"
}

# Disable Feedback Notifications
function Disable-FeedbackNotifications {
    Write-Log "Disabling Feedback Notifications..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInSIUF" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Location Services
function Disable-LocationServices {
    Write-Log "Disabling Location Services..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    }
    # Also disable via policy
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    Write-Log "Location Services disabled." "SUCCESS"
}

# Disable Advertising ID
function Disable-AdvertisingID {
    Write-Log "Disabling Advertising ID..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Advertising ID disabled." "SUCCESS"
}

# Disable Cortana
function Disable-Cortana {
    Write-Log "Disabling Cortana..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Cortana disabled." "SUCCESS"
}

# Disable Diagnostic Data
function Disable-DiagnosticData {
    Write-Log "Disabling Diagnostic Data..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "LimitEnhancedDiagnosticDataWindows10" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Diagnostic Data disabled." "SUCCESS"
}

# Disable Activity History
function Disable-ActivityHistory {
    Write-Log "Disabling Activity History..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivity" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivity" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Activity History disabled." "SUCCESS"
}

# Disable Tailored Experiences
function Disable-TailoredExperiences {
    Write-Log "Disabling Tailored Experiences..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Tailored Experiences disabled." "SUCCESS"
}

# Disable Handwriting Data Collection
function Disable-HandwritingData {
    Write-Log "Disabling Handwriting Data Collection..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Handwriting Data Collection disabled." "SUCCESS"
}

# Disable Inking & Typing Personalization
function Disable-InkingTypingPersonalization {
    Write-Log "Disabling Inking & Typing Personalization..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "UserContentIndex" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Inking & Typing Personalization disabled." "SUCCESS"
}

# Disable Cloud Optimized Content
function Disable-CloudContent {
    Write-Log "Disabling Cloud Optimized Content..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Cloud Optimized Content disabled." "SUCCESS"
}

# Disable Account Info Access
function Disable-AccountInfoAccess {
    Write-Log "Disabling Account Info Access..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\accountInfo"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    }
    Write-Log "Account Info Access disabled." "SUCCESS"
}

# Disable Contacts Sync
function Disable-ContactsSync {
    Write-Log "Disabling Contacts Sync..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    }
    Write-Log "Contacts Sync disabled." "SUCCESS"
}

# Block Windows Update Delivery Optimization
function Disable-DeliveryOptimization {
    Write-Log "Disabling Delivery Optimization..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DownloadMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Delivery Optimization disabled." "SUCCESS"
}

# Set Windows Update to Notify Only
function Set-WindowsUpdateNotifyOnly {
    Write-Log "Setting Windows Update to Notify Only..." "INFO"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Windows Update set to Notify Only." "SUCCESS"
}

# Show File Extensions
function Show-FileExtensions {
    Write-Log "Showing File Extensions..." "INFO"
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "HideFileExt" -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $path -Name "ShowExt" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }
    }
    Write-Log "File Extensions will be visible." "SUCCESS"
}

# Show Hidden Files
function Show-HiddenFiles {
    Write-Log "Showing Hidden Files..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "Hidden" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "ShowSuperHidden" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Hidden Files will be visible." "SUCCESS"
}

# Disable SmartScreen Filter
function Disable-SmartScreenFilter {
    Write-Log "Disabling SmartScreen Filter..." "INFO"
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "SmartScreenEnabled" -Value "Off" -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $path -Name "SmartScreenKnownBadURLs" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        }
    }
    # Disable via policy
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "SmartScreen Filter disabled." "SUCCESS"
}

# Disable Windows Security Notifications
function Disable-WindowsSecurityNotifications {
    Write-Log "Disabling Windows Security Notifications..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Windows Security Notifications disabled." "SUCCESS"
}

# Disable Windows Defender
function Disable-WindowsDefender {
    Write-Log "Disabling Windows Defender..." "WARN"
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    # Disable scheduled tasks
    $tasks = @(
        "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
        "Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
        "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
        "Microsoft\Windows\Windows Defender\Windows Defender Verification"
    )
    foreach ($task in $tasks) {
        $taskName = $task.Split('\')[-1]
        $taskPath = "\" + ($task.Substring(0, $task.LastIndexOf("\")))
        try {
            if (Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue) {
                Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName | Out-Null
            }
        } catch {}
    }
    Write-Log "Windows Defender disabled." "SUCCESS"
}

# Disable Windows Firewall
function Disable-WindowsFirewall {
    Write-Log "Disabling Windows Firewall..." "WARN"
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
    Write-Log "Windows Firewall disabled." "SUCCESS"
}

# Remove OneDrive from Explorer
function Remove-OneDriveFromExplorer {
    Write-Log "Removing OneDrive from Explorer..." "INFO"
    $path = "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4fd0-A96D-5149324A4B3A}"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "System.IsPinned" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "OneDrive removed from Explorer." "SUCCESS"
}

# Disable Storage Sense
function Disable-StorageSense {
    Write-Log "Disabling Storage Sense..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "Configured" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Storage Sense disabled." "SUCCESS"
}

# Clean Temp Files
function Clean-TempFiles {
    Write-Log "Cleaning Temp Files..." "INFO"
    $tempPaths = @("$env:TEMP", "$env:SystemRoot\Temp")
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } | Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Temp files cleaned." "SUCCESS"
}

# Clean Windows Update Cache
function Clean-WindowsUpdateCache {
    Write-Log "Cleaning Windows Update Cache..." "INFO"
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Remove-Item "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Log "Windows Update Cache cleaned." "SUCCESS"
}

# Disable Hibernate
function Disable-Hibernate {
    Write-Log "Disabling Hibernate..." "INFO"
    powercfg /h off
    Write-Log "Hibernate disabled." "SUCCESS"
}

# Disable Sleep Mode
function Disable-SleepMode {
    Write-Log "Disabling Sleep Mode..." "INFO"
    powercfg /change standby-timeout-ac 0
    powercfg /change monitor-timeout-ac 0
    Write-Log "Sleep Mode disabled." "SUCCESS"
}

# Remove Recycle Bin from Desktop
function Remove-RecycleBinFromDesktop {
    Write-Log "Removing Recycle Bin from Desktop..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Recycle Bin removed from Desktop." "SUCCESS"
}

# Disable Taskbar Search (Windows 11)
function Disable-TaskbarSearch {
    Write-Log "Disabling Taskbar Search..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Taskbar Search disabled." "SUCCESS"
}

# Disable Widgets
function Disable-Widgets {
    Write-Log "Disabling Widgets..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDa"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "WidgetServiceEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    # Also disable via registry
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ShowChat" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Widgets disabled." "SUCCESS"
}

# Disable Chat (Meet)
function Disable-Chat {
    Write-Log "Disabling Chat..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDa"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "ChatEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Chat disabled." "SUCCESS"
}

# Align Taskbar to Left (Windows 11)
function Align-TaskbarLeft {
    Write-Log "Aligning Taskbar to Left..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "TaskbarAl" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Taskbar aligned to left." "SUCCESS"
}

# Disable Auto-install Apps
function Disable-AutoInstallApps {
    Write-Log "Disabling Auto-install Apps..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Auto-install Apps disabled." "SUCCESS"
}

# Disable Startup Sound
function Disable-StartupSound {
    Write-Log "Disabling Startup Sound..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualFX\Animation"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "MinAnimate" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    # Also disable boot sound
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "BootAnimation" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Startup Sound disabled." "SUCCESS"
}

# Disable Lock Screen Blur
function Disable-LockScreenBlur {
    Write-Log "Disabling Lock Screen Blur..." "INFO"
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "DisableLockScreenBlur" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Log "Lock Screen Blur disabled." "SUCCESS"
}

# Disable Services
function Disable-Services {
    Write-Log "Disabling Services..." "INFO"
    $services = @(
        @{Name = "DiagTrack"; DisplayName = "Connected User Experience" },
        @{Name = "dmwappushservice"; DisplayName = "WAP Push Service" },
        @{Name = "WerSvc"; DisplayName = "Windows Error Reporting" },
        @{Name = "RemoteRegistry"; DisplayName = "Remote Registry" },
        @{Name = "XblAuthManager"; DisplayName = "Xbox Live Auth Manager" },
        @{Name = "XblGameSave"; DisplayName = "Xbox Live Game Save" },
        @{Name = "XboxNetApiSvc"; DisplayName = "Xbox Services" },
        @{Name = "lfsvc"; DisplayName = "Geolocation Service" },
        @{Name = "iphlpsvc"; DisplayName = "IP Helper" },
        @{Name = "seclogon"; DisplayName = "Secondary Logon" }
    )
    foreach ($svc in $services) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Log "Service $($svc.DisplayName) disabled." "SUCCESS"
            } catch {
                Write-Log "Failed to disable $($svc.DisplayName)" "ERROR"
            }
        }
    }
}

# Disable Windows Features
function Disable-WindowsFeatures {
    Write-Log "Disabling Windows Features..." "INFO"
    $features = @(
        "Microsoft-Hyper-V-All",
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Internet-Explorer-Optional-amd64",
        "MicrosoftWindowsPowerShellV2.Root",
        "Printing-XPSServices-Features",
        "FaxServicesExtPackage"
    )
    foreach ($feature in $features) {
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -WarningAction SilentlyContinue
            Write-Log "Feature $feature disabled." "SUCCESS"
        } catch {}
    }
}

# =========================
# Buttons
# =========================

function New-UIButton {
    param($text, $x, $clickHandler, $width = 100)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size($width, 35)
    $btn.Location = New-Object System.Drawing.Point($x, 585)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    if ($clickHandler) { $btn.Add_Click($clickHandler) }
    return $btn
}

# Select All
$buttonSelectAll = New-UIButton "Select All" 10 {
    foreach ($tab in $tabControl.TabPages) {
        $clb = $tab.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckedListBox] }
        if ($clb) {
            for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) }
        }
    }
}
$form.Controls.Add($buttonSelectAll)

# Deselect All
$buttonDeselectAll = New-UIButton "Deselect All" 120 {
    foreach ($tab in $tabControl.TabPages) {
        $clb = $tab.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckedListBox] }
        if ($clb) {
            for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
        }
    }
}
$form.Controls.Add($buttonDeselectAll)

# Refresh
$buttonRefresh = New-UIButton "Refresh" 230 {
    Write-Log "Refreshing..." "INFO"
    [System.Windows.Forms.MessageBox]::Show("Refresh complete!", "Info")
}
$form.Controls.Add($buttonRefresh)

# Apply
$buttonApply = New-UIButton "Apply Changes" 580 {
    if (-not (Test-Administrator)) {
        [System.Windows.Forms.MessageBox]::Show("Please run as Administrator!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    $confirm = Confirm-Action "Are you sure you want to apply these changes?`n`nThis may require a system restart."
    if (-not $confirm) { return }

    Write-Log "========================================" "INFO"
    Write-Log "Starting debloat process..." "INFO"
    Write-Log "========================================" "INFO"

    # Process Apps tab
    Write-Log "Processing Apps..." "INFO"
    foreach ($item in $checkedListApps.CheckedItems) {
        switch ($item) {
            'Uninstall OneDrive' { Remove-OneDrive }
            'Remove Xbox App (Gaming)' { Remove-AppxPackageByName 'xboxapp' 'Xbox App' }
            'Remove Microsoft Edge' { Remove-AppxPackageByName 'MicrosoftEdge' 'Microsoft Edge' }
            'Remove Microsoft Teams (Classic)' { Remove-AppxPackageByName 'Teams' 'Microsoft Teams (Classic)' }
            'Remove Teams (New)' { Remove-AppxPackageByName 'MicrosoftTeams' 'Teams (New)' }
            'Remove Cortana' { Remove-AppxPackageByName 'Cortana' 'Cortana' }
            'Remove Skype' { Remove-AppxPackageByName 'SkypeApp' 'Skype' }
            'Remove Solitaire Collection' { Remove-AppxPackageByName 'solitairecollection' 'Solitaire Collection' }
            'Remove News and Interests' {
                Write-Log "Disabling News and Interests..." "INFO"
                try {
                    $task = Get-ScheduledTask -TaskName "ShellExperienceHost" -ErrorAction SilentlyContinue
                    if ($task) {
                        Disable-ScheduledTask -TaskName "ShellExperienceHost" -ErrorAction SilentlyContinue
                        Write-Log "News and Interests disabled." "SUCCESS"
                    }
                } catch {}
            }
            'Remove Weather App' { Remove-AppxPackageByName 'BingWeather' 'Weather App' }
            'Remove Get Help App' { Remove-AppxPackageByName 'GetHelp' 'Get Help App' }
            'Remove Tips App' { Remove-AppxPackageByName 'MicrosoftWindowsFeedbackHub' 'Tips App' }
            'Remove Maps App' { Remove-AppxPackageByName 'BingMaps' 'Maps App' }
            'Remove 3D Viewer' { Remove-AppxPackageByName '3DViewer' '3D Viewer' }
            'Remove Paint 3D' { Remove-AppxPackageByName 'Paint3D' 'Paint 3D' }
            'Remove Voice Recorder' { Remove-AppxPackageByName 'SoundRecorder' 'Voice Recorder' }
            'Remove Media Player' { Remove-AppxPackageByName 'ZuneMusic' 'Media Player' }
            'Remove Clock App' { Remove-AppxPackageByName 'Alarms' 'Clock App' }
            'Remove Calculator App' { Remove-AppxPackageByName 'Calculator' 'Calculator App' }
            'Remove Sticky Notes' { Remove-AppxPackageByName 'StickyNotes' 'Sticky Notes' }
        }
    }

    # Process Privacy tab
    Write-Log "Processing Privacy..." "INFO"
    foreach ($item in $checkedListPrivacy.CheckedItems) {
        switch ($item) {
            'Disable Telemetry Services' { Disable-TelemetryServices }
            'Disable Windows Tips' { Disable-WindowsTips }
            'Disable Feedback Notifications' { Disable-FeedbackNotifications }
            'Disable Location Services' { Disable-LocationServices }
            'Disable Advertising ID' { Disable-AdvertisingID }
            'Disable Cortana (Policy)' { Disable-Cortana }
            'Disable Diagnostic Data' { Disable-DiagnosticData }
            'Disable Activity History' { Disable-ActivityHistory }
            'Disable Tailored Experiences' { Disable-TailoredExperiences }
            'Disable Handwriting Data Collection' { Disable-HandwritingData }
            'Disable Inking & Typing Personalization' { Disable-InkingTypingPersonalization }
            'Disable Cloud Optimized Content' { Disable-CloudContent }
            'Disable Account Info Access' { Disable-AccountInfoAccess }
            'Disable Contacts Sync' { Disable-ContactsSync }
            'Block Windows Update Delivery Optimization' { Disable-DeliveryOptimization }
            'Set Windows Update to Notify Only' { Set-WindowsUpdateNotifyOnly }
        }
    }

    # Process Tweaks tab
    Write-Log "Processing System Tweaks..." "INFO"
    foreach ($item in $checkedListTweaks.CheckedItems) {
        switch ($item) {
            'Show File Extensions' { Show-FileExtensions }
            'Show Hidden Files' { Show-HiddenFiles }
            'Disable SmartScreen Filter' { Disable-SmartScreenFilter }
            'Disable Windows Security Notifications' { Disable-WindowsSecurityNotifications }
            'Disable Windows Defender (Not Recommended)' { Disable-WindowsDefender }
            'Disable Windows Firewall (Not Recommended)' { Disable-WindowsFirewall }
            'Remove OneDrive from Explorer' { Remove-OneDriveFromExplorer }
            'Disable Storage Sense' { Disable-StorageSense }
            'Clean Temp Files' { Clean-TempFiles }
            'Clean Windows Update Cache' { Clean-WindowsUpdateCache }
            'Disable Hibernate' { Disable-Hibernate }
            'Disable Sleep Mode' { Disable-SleepMode }
            'Remove Recycle Bin from Desktop' { Remove-RecycleBinFromDesktop }
            'Disable Taskbar Search (Windows 11)' { Disable-TaskbarSearch }
            'Disable Widgets' { Disable-Widgets }
            'Disable Chat (Meet)' { Disable-Chat }
            'Align Taskbar to Left (Win 11)' { Align-TaskbarLeft }
            'Disable Auto-install Apps' { Disable-AutoInstallApps }
            'Disable Startup Sound' { Disable-StartupSound }
            'Disable Lock Screen Blur' { Disable-LockScreenBlur }
        }
    }

    # Process Services tab
    Write-Log "Processing Services..." "INFO"
    foreach ($item in $checkedListServices.CheckedItems) {
        switch ($item) {
            'Disable Connected User Experience (DiagTrack)' { 
                $svc = Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "DiagTrack" -Force; Set-Service -Name "DiagTrack" -StartupType Disabled }
            }
            'Disable WAP Push Service' {
                $svc = Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "dmwappushservice" -Force; Set-Service -Name "dmwappushservice" -StartupType Disabled }
            }
            'Disable Windows Error Reporting' {
                $svc = Get-Service -Name "WerSvc" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "WerSvc" -Force; Set-Service -Name "WerSvc" -StartupType Disabled }
            }
            'Disable Remote Registry' {
                $svc = Get-Service -Name "RemoteRegistry" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "RemoteRegistry" -Force; Set-Service -Name "RemoteRegistry" -StartupType Disabled }
            }
            'Disable Xbox Services' {
                $svcs = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc")
                foreach ($s in $svcs) {
                    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
                    if ($svc) { Stop-Service -Name $s -Force; Set-Service -Name $s -StartupType Disabled }
                }
            }
            'Disable Geolocation Service' {
                $svc = Get-Service -Name "lfsvc" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "lfsvc" -Force; Set-Service -Name "lfsvc" -StartupType Disabled }
            }
            'Disable IP Helper' {
                $svc = Get-Service -Name "iphlpsvc" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "iphlpsvc" -Force; Set-Service -Name "iphlpsvc" -StartupType Disabled }
            }
            'Disable Secondary Logon' {
                $svc = Get-Service -Name "seclogon" -ErrorAction SilentlyContinue
                if ($svc) { Stop-Service -Name "seclogon" -Force; Set-Service -Name "seclogon" -StartupType Disabled }
            }
        }
    }

    # Process Features tab
    Write-Log "Processing Windows Features..." "INFO"
    foreach ($item in $checkedListFeatures.CheckedItems) {
        switch ($item) {
            'Disable Hyper-V' { Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue }
            'Disable Windows Sandbox' { Disable-WindowsOptionalFeature -Online -FeatureName "Containers" -NoRestart -WarningAction SilentlyContinue }
            'Disable Virtual Machine Platform' { Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart -WarningAction SilentlyContinue }
            'Disable Windows Subsystem for Linux' { Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue }
            'Disable Internet Explorer' { Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart -WarningAction SilentlyContinue }
            'Disable Legacy Edge' { Disable-WindowsOptionalFeature -Online -FeatureName "LegacyEdge" -NoRestart -WarningAction SilentlyContinue }
            'Disable Microsoft Print to PDF' { Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue }
            'Disable Windows Fax and Scan' { Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesExtPackage" -NoRestart -WarningAction SilentlyContinue }
            'Disable Remote Desktop' { 
                Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -ErrorAction SilentlyContinue
            }
            'Disable Windows Media Player' { Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue }
        }
    }

    Write-Log "========================================" "SUCCESS"
    Write-Log "Debloating complete! Restart recommended." "SUCCESS"
    Write-Log "========================================" "SUCCESS"
    
    [System.Windows.Forms.MessageBox]::Show("Done! Please restart your PC for changes to take effect.", "Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$form.Controls.Add($buttonApply)

# =========================
# Run Form
# =========================

# Check for admin rights
if (-not (Test-Administrator)) {
    Write-Log "WARNING: Not running as Administrator. Some features may not work." "WARN"
}

Write-Log "Win11DebloatMinimal v2.0 loaded. Inspired by Sophia Script & WinUtil." "INFO"
Write-Log "Select options and click 'Apply Changes' to begin." "INFO"

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
