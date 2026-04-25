@echo off
:: Win11DebloatMinimal v2.0 Launcher

:: Request admin rights and run the script
PowerShell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0Win11DebloatMinimal.ps1\"' -Verb RunAs"