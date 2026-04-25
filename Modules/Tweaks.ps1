# Modules/Tweaks.ps1  -  Explorer, taskbar, power, and UI tweaks

function Enable-FileExtensions {
    Invoke-Tweak 'Show File Extensions' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
            'HideFileExt' 0 -Description 'Explorer: hide file extensions'
    }
}

function Enable-HiddenFiles {
    Invoke-Tweak 'Show Hidden Files & Folders' {
        $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Set-RegistryValue $adv 'Hidden'          1 -Description 'Explorer: show hidden files'
        Set-RegistryValue $adv 'ShowSuperHidden' 1 -Description 'Explorer: show protected OS files'
    }
}

function Disable-SmartScreen {
    Invoke-Tweak 'Disable SmartScreen Filter' -Dangerous {
        Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost' `
            'EnableWebContentEvaluation' 0 -Description 'SmartScreen web evaluation'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
            'EnableSmartScreen' 0 -Description 'SmartScreen policy'
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' `
            'SmartScreenEnabled' 'Off' -Type String -Description 'SmartScreen Explorer status'
    }
}

function Disable-TaskbarSearch {
    Invoke-Tweak 'Disable Taskbar Search Box' {
        # 0 = hidden, 1 = icon only, 2 = full box
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' `
            'SearchboxTaskbarMode' 0 -Description 'Taskbar search box mode'
    }
}

function Disable-TaskbarWidgets {
    Invoke-Tweak 'Disable Taskbar Widgets Button' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
            'TaskbarDa' 0 -Description 'Taskbar widgets (News & Interests)'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' `
            'AllowNewsAndInterests' 0 -Description 'News and interests policy'
    }
}

function Disable-TaskbarChat {
    Invoke-Tweak 'Disable Taskbar Chat (Teams Meet Now)' {
        # TaskbarMn = Meet Now / Chat button
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
            'TaskbarMn' 0 -Description 'Taskbar chat/meet button'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat' `
            'ChatIcon' 3 -Description 'Chat icon policy (3 = disabled)'
    }
}

function Set-TaskbarAlignLeft {
    Invoke-Tweak 'Align Taskbar to Left (Windows 11)' {
        # 0 = left, 1 = center (Windows 11 default)
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
            'TaskbarAl' 0 -Description 'Taskbar alignment'
    }
}

function Disable-AutoInstallApps {
    Invoke-Tweak 'Disable Auto-Install Suggested Apps' {
        $cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-RegistryValue $cdm 'SilentInstalledAppsEnabled' 0 -Description 'CDM silent app install'
        Set-RegistryValue $cdm 'PreInstalledAppsEnabled'    0 -Description 'CDM preinstalled apps'
        Set-RegistryValue $cdm 'OemPreInstalledAppsEnabled' 0 -Description 'CDM OEM apps'
    }
}

function Disable-StartupSound {
    Invoke-Tweak 'Disable Windows Startup Sound' {
        Set-RegistryValue `
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation' `
            'DisableStartupSound' 1 -Description 'Boot startup sound'
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' `
            'EnableFirstLogonAnimation' 0 -Description 'First logon animation'
    }
}

function Disable-LockScreenBlur {
    Invoke-Tweak 'Disable Lock Screen Acrylic Blur' {
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
            'DisableAcrylicBackgroundOnLogon' 1 -Description 'Logon acrylic background blur'
    }
}

function Disable-StorageSense {
    Invoke-Tweak 'Disable Storage Sense' {
        # StoragePolicy\01 = Storage Sense on/off toggle
        Set-RegistryValue `
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' `
            '01' 0 -Description 'Storage Sense enabled flag'
    }
}

function Disable-OneDriveSidebarPin {
    Invoke-Tweak 'Remove OneDrive from Explorer Sidebar' {
        $clsid = '{018D5C66-4533-4fd0-A96D-5149324A4B3A}'
        Set-RegistryValue "HKCU:\Software\Classes\CLSID\$clsid"              'System.IsPinned' 0 -Description 'OneDrive Explorer pin (64-bit)'
        Set-RegistryValue "HKCU:\Software\Classes\Wow6432Node\CLSID\$clsid"  'System.IsPinned' 0 -Description 'OneDrive Explorer pin (32-bit)'
    }
}

function Invoke-CleanTempFiles {
    Invoke-Tweak 'Clean Temporary Files (>1 day old)' {
        if ($Script:DryRun) {
            Write-Log '[DRY-RUN] Would clean %TEMP% and Windows\Temp' DEBUG
            return
        }
        foreach ($dir in @($env:TEMP, "$env:SystemRoot\Temp")) {
            if (-not (Test-Path $dir)) { continue }
            $items = Get-ChildItem $dir -Recurse -Force -ErrorAction SilentlyContinue |
                     Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) }
            $items | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Log "Cleaned $($items.Count) items from $dir" INFO
        }
    }
}

function Invoke-CleanUpdateCache {
    Invoke-Tweak 'Clean Windows Update Download Cache' {
        if ($Script:DryRun) {
            Write-Log '[DRY-RUN] Would stop wuauserv, delete SoftwareDistribution\Download, restart' DEBUG
            return
        }
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Remove-Item "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Log 'Windows Update cache cleared' SUCCESS
    }
}

function Disable-Hibernate {
    Invoke-Tweak 'Disable Hibernate' {
        if ($Script:DryRun) { Write-Log '[DRY-RUN] Would run: powercfg /h off' DEBUG; return }
        & powercfg /h off
    }
}

function Disable-SleepOnAC {
    Invoke-Tweak 'Disable Sleep on AC Power' {
        if ($Script:DryRun) { Write-Log '[DRY-RUN] Would disable AC sleep/monitor timeout' DEBUG; return }
        & powercfg /change standby-timeout-ac 0
        & powercfg /change monitor-timeout-ac 0
    }
}

function Set-WindowsUpdateNotifyOnly {
    Invoke-Tweak 'Set Windows Update  -  Notify Before Download' {
        # AUOptions: 2 = Notify, 3 = Auto download + notify install, 4 = Auto schedule
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' `
            'AUOptions' 2 -Description 'Windows Update auto-update option'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' `
            'NoAutoUpdate' 0 -Description 'Windows Update no-auto flag'
    }
}

function Disable-RemoteDesktop {
    Invoke-Tweak 'Disable Remote Desktop (RDP)' {
        Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
            'fDenyTSConnections' 1 -Description 'RDP deny connections'
        Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
            'UserAuthentication' 1 -Description 'RDP require NLA'
    }
}

function Disable-RemoteAssistance {
    Invoke-Tweak 'Disable Remote Assistance' {
        Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Remote Assistance' `
            'fAllowToGetHelp' 0 -Description 'Remote Assistance allow'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' `
            'fAllowToGetHelp' 0 -Description 'Remote Assistance policy'
    }
}

function Disable-WindowsDefender {
    # Intentionally not in any default profile. Only apply if you have a third-party AV.
    Invoke-Tweak 'Disable Windows Defender Real-time Protection' -Dangerous {
        Write-Log 'WARNING: This leaves the system unprotected. Use only with a third-party AV.' WARN
        if (-not $Script:DryRun) {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        }
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' `
            'DisableAntiSpyware' 1 -Description 'Defender anti-spyware policy'
    }
}

function Disable-WindowsFirewall {
    # Intentionally not in any default profile.
    Invoke-Tweak 'Disable Windows Firewall (ALL profiles)' -Dangerous {
        Write-Log 'WARNING: Disabling the firewall exposes the system to network threats.' WARN
        if (-not $Script:DryRun) {
            Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False -ErrorAction SilentlyContinue
        }
    }
}
