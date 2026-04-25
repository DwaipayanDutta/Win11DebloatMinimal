# Win11DebloatMinimal v3.0

Modular, safe, and reversible Windows 11 debloat tool — inspired by [Sophia Script](https://github.com/farag2/Sophia-Script-for-Windows) and [WinUtil](https://github.com/ChrisTitusTech/winutil).

## What's New in v3.0

- **Modular architecture** — split into `Core/`, `Modules/`, `Profiles/`, `UI/`
- **Dry-run mode** — preview every change before writing anything
- **Auto rollback** — a restore script is generated after every run
- **Three profiles** — Minimal, Recommended, Aggressive
- **CLI / headless mode** — run without the GUI for scripted deployments
- **73 tweaks** across Apps, Privacy, Tweaks, Services, and Features tabs
- **Idempotent** — safe to run multiple times; checks state before changing
- **File + console logging** — every action timestamped and saved to `%TEMP%\Win11Debloat\`

## Quick Start

Double-click `Run.bat` — it auto-elevates to Administrator and opens the GUI.

```
Run.bat
```

## CLI Usage

```powershell
# Interactive GUI (default)
.\Win11DebloatMinimal.ps1

# Apply a profile silently (no GUI)
.\Win11DebloatMinimal.ps1 -Profile Minimal     -NoUI
.\Win11DebloatMinimal.ps1 -Profile Recommended -NoUI
.\Win11DebloatMinimal.ps1 -Profile Aggressive  -NoUI

# Preview without writing anything
.\Win11DebloatMinimal.ps1 -Profile Recommended -DryRun -NoUI

# Undo a previous run
.\Win11DebloatMinimal.ps1 -Restore "$env:TEMP\Win11Debloat\Restore_TIMESTAMP.ps1"
```

## Profiles

| Profile | Tweaks | What it covers |
|---|---|---|
| **Minimal** | 18 | Privacy, telemetry, safe UI tweaks, non-essential services |
| **Recommended** | 45 | Minimal + deeper privacy, common bloatware removal |
| **Aggressive** | 73 | Recommended + OneDrive, Teams, optional Windows features |

## Project Structure

```
Win11DebloatMinimal/
├── Run.bat                    Double-click launcher (auto-elevates)
├── Win11DebloatMinimal.ps1    Entry point — CLI flags, module loader
├── Core/
│   └── Engine.ps1             Logging, dry-run, rollback engine
├── Modules/
│   ├── Apps.ps1               UWP / provisioned app removal (25 functions)
│   ├── Privacy.ps1            Telemetry & privacy tweaks (14 functions)
│   ├── Tweaks.ps1             Explorer, taskbar, power tweaks (21 functions)
│   ├── Services.ps1           Service hardening (15 functions)
│   └── Features.ps1           Windows optional features (12 functions)
├── Profiles/
│   ├── Minimal.ps1
│   ├── Recommended.ps1
│   └── Aggressive.ps1
└── UI/
    └── MainForm.ps1           Dark-themed Windows Forms interface
```

## Safety

- Every registry change saves the original value before writing
- Every service stores its original startup type before disabling
- After applying, a `Restore_TIMESTAMP.ps1` is generated in `%TEMP%\Win11Debloat\` — run it to undo everything
- Dangerous tweaks (Defender, Firewall, Hyper-V, WSL) are labelled **DANGER** in the UI and excluded from all default profiles
- Windows Update, Windows Store, and core OS services are never touched

## Requirements

- Windows 10 / Windows 11
- PowerShell 5.1 or later
- Administrator rights (Run.bat handles this automatically)
- No external dependencies

## License

MIT
