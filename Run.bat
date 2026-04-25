@echo off
:: Win11DebloatMinimal v3.0 Launcher
:: Usage: Run.bat [Profile] [/DryRun] [/NoUI]
::   Profiles: Minimal | Recommended | Aggressive
::   Example:  Run.bat Recommended /DryRun /NoUI
setlocal

set "SCRIPT=%~dp0Win11DebloatMinimal.ps1"
set "ARGS=-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT%\""

:: Pass through any arguments (e.g., "-Profile Recommended -DryRun -NoUI")
if not "%~1"=="" set "ARGS=%ARGS% %*"

PowerShell -Command "Start-Process PowerShell -ArgumentList '%ARGS%' -Verb RunAs"
