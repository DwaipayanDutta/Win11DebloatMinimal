# Profiles/Minimal.ps1
# Safe defaults: privacy improvements + UI cleanup.
# Nothing destructive. All changes are reversible via the generated restore script.

$Script:ProfileMinimal = @(
    # --- Privacy & Telemetry ---
    'Disable-AdvertisingId',
    'Disable-TelemetryServices',
    'Disable-DiagnosticData',
    'Disable-FeedbackNotifications',
    'Disable-ActivityHistory',
    'Disable-TailoredExperiences',
    'Disable-CloudContent',
    'Disable-WindowsTips',

    # --- Explorer / UI ---
    'Enable-FileExtensions',
    'Enable-HiddenFiles',
    'Disable-TaskbarWidgets',
    'Disable-TaskbarChat',
    'Set-TaskbarAlignLeft',
    'Disable-AutoInstallApps',

    # --- Safe Services ---
    'Disable-DiagTrack',
    'Disable-WapPush',
    'Disable-RetailDemoSvc',
    'Disable-MapsBrokerSvc'
)
