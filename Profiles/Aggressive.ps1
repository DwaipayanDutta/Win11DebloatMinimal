# Profiles/Aggressive.ps1
# Maximum debloat. Review every item before applying  -  some are harder to undo.
# Requires $Script:ProfileRecommended to be defined (loaded after Recommended.ps1).

$Script:ProfileAggressive = $Script:ProfileRecommended + @(
    # --- Heavy App Removal ---
    'Remove-OneDrive',
    'Remove-MicrosoftTeams',
    'Remove-Skype',
    'Remove-Solitaire',
    'Remove-GetHelp',
    'Remove-BingMaps',
    'Remove-MicrosoftFamily',
    'Remove-QuickAssist',
    'Remove-YourPhone',
    'Remove-LegacyMediaPlayer',

    # --- Additional Services ---
    'Disable-RemoteRegistrySvc',
    'Disable-SecondaryLogon',
    'Disable-FaxSvc',
    'Disable-BiometricSvc',
    'Disable-MixedRealitySvc',

    # --- Windows Features ---
    'Disable-InternetExplorer',
    'Disable-PowerShellV2',
    'Disable-LegacyMediaPlayer',
    'Disable-WorkFolders',
    'Disable-TelnetClient',
    'Disable-FaxAndScan',
    'Disable-PrintToPDF',

    # --- System Tweaks ---
    'Disable-RemoteAssistance',
    'Disable-TaskbarSearch',
    'Disable-LockScreenBlur',
    'Set-WindowsUpdateNotifyOnly',
    'Invoke-CleanTempFiles',
    'Invoke-CleanUpdateCache'
)
