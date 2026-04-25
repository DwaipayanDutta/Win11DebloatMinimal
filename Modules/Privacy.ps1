# Modules/Privacy.ps1 — Telemetry, data collection, and privacy tweaks
# All changes are registry/service-based and captured by the rollback engine.

function Disable-TelemetryServices {
    Invoke-Tweak 'Disable Telemetry Services' {
        Disable-ServiceSafe 'DiagTrack'        'Connected User Experience & Telemetry'
        Disable-ServiceSafe 'dmwappushservice' 'WAP Push Message Routing'

        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            'AllowTelemetry' 0 -Description 'Policy: allow telemetry'
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' `
            'AllowTelemetry' 0 -Description 'User policy: allow telemetry'
    }
}

function Disable-DiagnosticData {
    Invoke-Tweak 'Disable Diagnostic Data' {
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            'AllowTelemetry' 0 -Description 'Diagnostic telemetry'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            'LimitEnhancedDiagnosticDataWindows10' 0 -Description 'Enhanced diagnostics limit'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            'DisableOneSettingsDownloads' 1 -Description 'OneSettings downloads'
    }
}

function Disable-AdvertisingId {
    Invoke-Tweak 'Disable Advertising ID' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
            'Enabled' 0 -Description 'HKCU Advertising ID'
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
            'Enabled' 0 -Description 'HKLM Advertising ID'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
            'DisabledByGroupPolicy' 1 -Description 'Advertising ID group policy flag'
    }
}

function Disable-LocationServices {
    Invoke-Tweak 'Disable Location Services' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' `
            'Value' 'Deny' -Type String -Description 'HKCU Location consent'
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' `
            'Value' 'Deny' -Type String -Description 'HKLM Location consent'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' `
            'DisableLocation' 1 -Description 'Location policy'
    }
}

function Disable-Cortana {
    Invoke-Tweak 'Disable Cortana (Policy)' {
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
            'AllowCortana' 0 -Description 'Cortana policy'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
            'AllowCortanaAboveLock' 0 -Description 'Cortana above lock screen'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
            'DisableWebSearch' 1 -Description 'Cortana web search'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' `
            'CortanaEnabled' 0 -Description 'Cortana enabled (user)'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' `
            'BingSearchEnabled' 0 -Description 'Bing search in Start'
    }
}

function Disable-ActivityHistory {
    Invoke-Tweak 'Disable Activity History' {
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
            'PublishUserActivity' 0 -Description 'Publish user activity'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
            'UploadUserActivity' 0 -Description 'Upload user activity'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' `
            'ActivityHistoryEnabled' 0 -Description 'Activity history (user)'
    }
}

function Disable-TailoredExperiences {
    Invoke-Tweak 'Disable Tailored Experiences' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' `
            'TailoredExperiencesWithDiagnosticDataEnabled' 0 -Description 'Tailored experiences'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' `
            'DisableTailoredExperiencesWithDiagnosticData' 1 -Description 'Tailored experiences policy'
    }
}

function Disable-FeedbackNotifications {
    Invoke-Tweak 'Disable Feedback Notifications' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Siuf\Rules' `
            'NumberOfSIUFInPeriod' 0 -Description 'Feedback frequency'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Siuf\Rules' `
            'PeriodInSIUF' 0 -Description 'Feedback period'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            'DoNotShowFeedbackNotifications' 1 -Description 'Feedback notifications policy'
    }
}

function Disable-HandwritingData {
    Invoke-Tweak 'Disable Handwriting Data Collection' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' `
            'RestrictImplicitTextCollection' 1 -Description 'Handwriting text collection'
        Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' `
            'RestrictImplicitInkCollection' 1 -Description 'Handwriting ink collection'
    }
}

function Disable-InkingPersonalization {
    Invoke-Tweak 'Disable Inking & Typing Personalization' {
        Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' `
            'HarvestContacts' 0 -Description 'Inking harvest contacts'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Personalization\Settings' `
            'AcceptedPrivacyPolicy' 0 -Description 'Personalization privacy policy'
        Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' `
            'RestrictImplicitTextCollection' 1 -Description 'Inking text restriction'
    }
}

function Disable-CloudContent {
    Invoke-Tweak 'Disable Cloud / Suggested Content' {
        $cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        $pol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'

        Set-RegistryValue $pol 'DisableWindowsConsumerFeatures'             1 -Description 'Consumer features'
        Set-RegistryValue $pol 'DisableCloudOptimizedContent'               1 -Description 'Cloud optimized content'
        Set-RegistryValue $pol 'DisableSoftLanding'                         1 -Description 'Soft landing'

        Set-RegistryValue $cdm 'ContentDeliveryAllowed'                     0 -Description 'CDM delivery'
        Set-RegistryValue $cdm 'OemPreInstalledAppsEnabled'                 0 -Description 'CDM OEM apps'
        Set-RegistryValue $cdm 'PreInstalledAppsEnabled'                    0 -Description 'CDM preinstalled apps'
        Set-RegistryValue $cdm 'SilentInstalledAppsEnabled'                 0 -Description 'CDM silent installs'
        Set-RegistryValue $cdm 'SoftLandingEnabled'                         0 -Description 'CDM soft landing'
        Set-RegistryValue $cdm 'SubscribedContent-310093Enabled'            0 -Description 'CDM tips'
        Set-RegistryValue $cdm 'SubscribedContent-338380Enabled'            0 -Description 'CDM spotlight'
        Set-RegistryValue $cdm 'SubscribedContent-338387Enabled'            0 -Description 'CDM lock screen'
        Set-RegistryValue $cdm 'SubscribedContent-338388Enabled'            0 -Description 'CDM tips notifications'
        Set-RegistryValue $cdm 'SubscribedContent-338389Enabled'            0 -Description 'CDM get started'
        Set-RegistryValue $cdm 'SubscribedContent-353698Enabled'            0 -Description 'CDM timeline'
    }
}

function Disable-AccountInfoAccess {
    Invoke-Tweak 'Disable App Access to Account Info' {
        Set-RegistryValue `
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation' `
            'Value' 'Deny' -Type String -Description 'Account info access consent'
    }
}

function Disable-DeliveryOptimization {
    Invoke-Tweak 'Disable Delivery Optimization (P2P Updates)' {
        Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' `
            'DODownloadMode' 0 -Description 'DO mode (config)'
        Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' `
            'DODownloadMode' 0 -Description 'DO mode (policy)'
        Disable-ServiceSafe 'DoSvc' 'Delivery Optimization Service'
    }
}

function Disable-WindowsTips {
    Invoke-Tweak 'Disable Windows Tips & Suggestions' {
        $cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-RegistryValue $cdm 'SubscribedContent-338388Enabled' 0 -Description 'Tips subscribed content'
        Set-RegistryValue $cdm 'SubscribedContent-338389Enabled' 0 -Description 'Get started subscribed content'
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' `
            'ScoobeSystemSettingEnabled' 0 -Description 'OOBE settings suggestion'
    }
}
