<#
.SYNOPSIS
    Minimal Win11Debloat-inspired script to remove bloatware and tweak privacy/UI.

.DESCRIPTION
    Removes default apps, disables telemetry, Bing, Cortana, widgets, chat, and applies UI tweaks.

.NOTES
    Run as Administrator.
#>

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    exit 1
}

# Function to remove appx packages for all users
function Remove-AppxPackageAllUsers {
    param(
        [string[]]$PackageNames
    )
    foreach ($packageName in $PackageNames) {
        Write-Host "Removing app: $packageName"
        # Remove for all users
        Get-AppxPackage -AllUsers -Name $packageName -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
            } catch {}
        }
        # Remove provisioned packages (preinstalled for new users)
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $packageName | ForEach-Object {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
            } catch {}
        }
    }
}

# List of common bloatware app package names (extend as needed)
$bloatwareApps = @(
    "Microsoft.3DBuilder",
    "Microsoft.BingNews",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MSPaint",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# Remove bloatware apps
Remove-AppxPackageAllUsers -PackageNames $bloatwareApps

# Disable telemetry and diagnostics
Write-Host "Disabling telemetry and diagnostics..."
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -PropertyType DWord -Force | Out-Null

# Disable Bing Search and Cortana
Write-Host "Disabling Bing Search and Cortana..."
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -PropertyType DWord -Force | Out-Null

# Show file extensions and hidden files
Write-Host "Showing file extensions and hidden files..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force

# Disable Widgets (Windows 11)
Write-Host "Disabling Widgets..."
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -PropertyType DWord -Force | Out-Null

# Hide Chat icon (Meet Now) on taskbar (Windows 11)
Write-Host "Hiding Chat icon..."
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -PropertyType DWord -Force | Out-Null

# Align taskbar icons to the left (Windows 11)
Write-Host "Aligning taskbar icons to the left..."
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "Debloating complete. Please restart your computer for all changes to take effect."
