@echo off
:: Win11DebloatMinimal v3.0 Launcher
:: Double-click to open the GUI, or call with arguments:
::   Run.bat -Profile Minimal
::   Run.bat -Profile Recommended -DryRun -NoUI
::   Run.bat -Profile Aggressive -NoUI

PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Win11DebloatMinimal.ps1"" %*' -Verb RunAs"
