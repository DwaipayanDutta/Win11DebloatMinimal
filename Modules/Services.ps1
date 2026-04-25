# Modules/Services.ps1 — Windows service hardening
# All services are disabled via Set-Service (not registry hacks), so they survive updates.
# Original startup types are recorded by Disable-ServiceSafe for full rollback.

function Disable-DiagTrack {
    Invoke-Tweak 'Disable Connected User Experience & Telemetry (DiagTrack)' {
        Disable-ServiceSafe 'DiagTrack' 'Connected User Experience & Telemetry'
    }
}

function Disable-WapPush {
    Invoke-Tweak 'Disable WAP Push Message Routing Service' {
        Disable-ServiceSafe 'dmwappushservice' 'WAP Push Message Routing'
    }
}

function Disable-ErrorReporting {
    Invoke-Tweak 'Disable Windows Error Reporting Service' {
        Disable-ServiceSafe 'WerSvc' 'Windows Error Reporting'
        # Disable the scheduled tasks too
        if (-not $Script:DryRun) {
            $tasks = @(
                @{ Path = '\Microsoft\Windows\Windows Error Reporting\'; Name = 'QueueReporting' }
            )
            foreach ($t in $tasks) {
                $st = Get-ScheduledTask -TaskPath $t.Path -TaskName $t.Name -ErrorAction SilentlyContinue
                if ($st -and $st.State -ne 'Disabled') {
                    Disable-ScheduledTask -TaskPath $t.Path -TaskName $t.Name -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "Disabled scheduled task: $($t.Name)" SUCCESS
                }
            }
        }
    }
}

function Disable-RemoteRegistrySvc {
    Invoke-Tweak 'Disable Remote Registry Service' {
        Disable-ServiceSafe 'RemoteRegistry' 'Remote Registry'
    }
}

function Disable-XboxServices {
    Invoke-Tweak 'Disable Xbox Live Services' {
        foreach ($svc in @('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc', 'xbgm')) {
            Disable-ServiceSafe $svc "Xbox: $svc"
        }
    }
}

function Disable-GeolocationSvc {
    Invoke-Tweak 'Disable Geolocation Service' {
        Disable-ServiceSafe 'lfsvc' 'Geolocation Service'
    }
}

function Disable-IpHelperSvc {
    # IP Helper enables IPv6 tunneling (Teredo/6to4). Safe to disable on IPv4-only networks.
    Invoke-Tweak 'Disable IP Helper (IPv6 tunnels)' {
        Disable-ServiceSafe 'iphlpsvc' 'IP Helper'
    }
}

function Disable-SecondaryLogon {
    # Secondary Logon allows running processes as a different user. Rarely needed on personal PCs.
    Invoke-Tweak 'Disable Secondary Logon Service' {
        Disable-ServiceSafe 'seclogon' 'Secondary Logon'
    }
}

function Disable-MapsBrokerSvc {
    Invoke-Tweak 'Disable Downloaded Maps Manager' {
        Disable-ServiceSafe 'MapsBroker' 'Downloaded Maps Manager'
    }
}

function Disable-RetailDemoSvc {
    Invoke-Tweak 'Disable Retail Demo Service' {
        Disable-ServiceSafe 'RetailDemo' 'Retail Demo Service'
    }
}

function Disable-FaxSvc {
    Invoke-Tweak 'Disable Fax Service' {
        Disable-ServiceSafe 'Fax' 'Fax'
    }
}

function Disable-PrintSpooler {
    # Only disable on machines that never print. Disabling breaks all local/network printing.
    Invoke-Tweak 'Disable Print Spooler' -Dangerous {
        Write-Log 'NOTE: This disables all printing. Only apply on print-free systems.' WARN
        Disable-ServiceSafe 'Spooler' 'Print Spooler'
    }
}

function Disable-BiometricSvc {
    # Safe unless you use Windows Hello fingerprint/face login.
    Invoke-Tweak 'Disable Windows Biometric Service' {
        Disable-ServiceSafe 'WbioSrvc' 'Windows Biometric Service'
    }
}

function Disable-MixedRealitySvc {
    Invoke-Tweak 'Disable Windows Mixed Reality OpenXR Service' {
        Disable-ServiceSafe 'MixedRealityOpenXRSvc' 'Mixed Reality OpenXR Service'
    }
}

function Disable-ParentalControlsSvc {
    Invoke-Tweak 'Disable Parental Controls Service' {
        Disable-ServiceSafe 'WpcMonSvc' 'Parental Controls'
    }
}
