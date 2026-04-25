@echo off
:: ============================================
:: Win11DebloatMinimal v2.0 Launcher
:: Inspired by Sophia Script & WinUtil
:: ============================================

echo.
echo ============================================
echo  🚀 Win11DebloatMinimal v2.0
echo ============================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Not running as Administrator!
    echo    Requesting elevated privileges...
    echo.
    PowerShell -ExecutionPolicy Bypass -Command ^
        "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0Win11DebloatMinimal.ps1\"' -Verb RunAs"
    exit /b
)

echo ✅ Running with Administrator privileges...
echo.
echo Starting Win11DebloatMinimal...
echo.

:: Run the debloat script
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Win11DebloatMinimal.ps1"

echo.
echo ============================================
echo  Script finished!
echo ============================================
echo.

pause