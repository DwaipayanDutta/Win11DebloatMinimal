@echo off
PowerShell -ExecutionPolicy Bypass -Command ^
  "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0Win11DebloatMinimal.ps1\"' -Verb RunAs}"