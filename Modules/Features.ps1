# Modules/Features.ps1 — Windows Optional Features
# Disabling a feature is reversible via: Enable-WindowsOptionalFeature -Online -FeatureName <name>
# Most require a restart to take effect.

function Disable-OptionalFeatureSafe {
    param(
        [Parameter(Mandatory)][string] $FeatureName,
        [Parameter(Mandatory)][string] $DisplayName
    )
    if ($Script:DryRun) {
        Write-Log "[DRY-RUN] Would disable Windows feature: $DisplayName ($FeatureName)" DEBUG
        return
    }
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction SilentlyContinue
    if (-not $feature) {
        Write-Log "Feature not found: $DisplayName" WARN
        return
    }
    if ($feature.State -ne 'Enabled') {
        Write-Log "Already disabled: $DisplayName" INFO
        return
    }
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -ErrorAction Stop | Out-Null
        Write-Log "Disabled feature: $DisplayName (restart required)" SUCCESS
    } catch {
        Write-Log "Could not disable $DisplayName — $_" ERROR
        $Script:Stats.Errors++
    }
}

function Disable-HyperV {
    Invoke-Tweak 'Disable Hyper-V' -Dangerous {
        Write-Log 'NOTE: Disabling Hyper-V may break WSL 2, Docker Desktop, and other VMs.' WARN
        Disable-OptionalFeatureSafe 'Microsoft-Hyper-V-All' 'Hyper-V'
    }
}

function Disable-WindowsSandbox {
    Invoke-Tweak 'Disable Windows Sandbox' {
        Disable-OptionalFeatureSafe 'Containers-DisposableClientVM' 'Windows Sandbox'
    }
}

function Disable-VirtualMachinePlatform {
    Invoke-Tweak 'Disable Virtual Machine Platform' -Dangerous {
        Write-Log 'NOTE: This may break WSL 2 and Android app support.' WARN
        Disable-OptionalFeatureSafe 'VirtualMachinePlatform' 'Virtual Machine Platform'
    }
}

function Disable-WSL {
    Invoke-Tweak 'Disable Windows Subsystem for Linux (WSL)' -Dangerous {
        Disable-OptionalFeatureSafe 'Microsoft-Windows-Subsystem-Linux' 'Windows Subsystem for Linux'
    }
}

function Disable-PrintToPDF {
    Invoke-Tweak 'Disable Microsoft Print to PDF' {
        Disable-OptionalFeatureSafe 'Printing-XPSServices-Features' 'Microsoft Print to PDF / XPS'
    }
}

function Disable-FaxAndScan {
    Invoke-Tweak 'Disable Windows Fax and Scan' {
        Disable-OptionalFeatureSafe 'FaxServicesClientPackage' 'Windows Fax and Scan'
    }
}

function Disable-LegacyMediaPlayer {
    Invoke-Tweak 'Disable Windows Media Player (Legacy)' {
        Disable-OptionalFeatureSafe 'WindowsMediaPlayer' 'Windows Media Player (Legacy)'
    }
}

function Disable-InternetExplorer {
    Invoke-Tweak 'Disable Internet Explorer' {
        Disable-OptionalFeatureSafe 'Internet-Explorer-Optional-amd64' 'Internet Explorer'
    }
}

function Disable-PowerShellV2 {
    # PSv2 has known security weaknesses (no AMSI, no script block logging).
    Invoke-Tweak 'Disable PowerShell 2.0 (Legacy, Insecure)' {
        Disable-OptionalFeatureSafe 'MicrosoftWindowsPowerShellV2Root' 'PowerShell 2.0'
    }
}

function Disable-WorkFolders {
    Invoke-Tweak 'Disable Work Folders Client' {
        Disable-OptionalFeatureSafe 'WorkFolders-Client' 'Work Folders Client'
    }
}

function Disable-TelnetClient {
    Invoke-Tweak 'Disable Telnet Client' {
        Disable-OptionalFeatureSafe 'TelnetClient' 'Telnet Client'
    }
}
