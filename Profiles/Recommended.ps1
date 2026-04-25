# Profiles/Recommended.ps1
# Balanced debloat: Minimal plus deeper privacy tweaks and common bloatware removal.
# Requires $Script:ProfileMinimal to be defined (loaded after Minimal.ps1).

$Script:ProfileRecommended = $Script:ProfileMinimal + @(
    # --- Additional Privacy ---
    'Disable-Cortana',
    'Disable-LocationServices',
    'Disable-HandwritingData',
    'Disable-InkingPersonalization',
    'Disable-AccountInfoAccess',
    'Disable-DeliveryOptimization',

    # --- Bloatware Removal ---
    'Remove-Cortana',
    'Remove-XboxApp',
    'Remove-XboxGamingOverlay',
    'Remove-BingWeather',
    'Remove-BingNews',
    'Remove-BingFinance',
    'Remove-BingSports',
    'Remove-3DViewer',
    'Remove-Paint3D',
    'Remove-VoiceRecorder',
    'Remove-FeedbackHub',
    'Remove-Clipchamp',
    'Remove-PowerAutomate',
    'Remove-MixedReality',

    # --- Additional Services ---
    'Disable-ErrorReporting',
    'Disable-XboxServices',
    'Disable-GeolocationSvc',
    'Disable-ParentalControlsSvc',

    # --- Additional Tweaks ---
    'Disable-StartupSound',
    'Disable-StorageSense',
    'Disable-OneDriveSidebarPin'
)
