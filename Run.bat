@echo off
:: Win11DebloatMinimal v3.0 Launcher
:: Double-click to open the GUI (auto-elevates to Administrator).
:: CLI usage — pass arguments directly:
::   Run.bat -Profile Minimal
::   Run.bat -Profile Recommended -DryRun -NoUI
::   Run.bat -Profile Aggressive -NoUI

set "F=%~dp0Win11DebloatMinimal.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File','%F%')"
