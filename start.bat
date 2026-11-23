@echo off
setlocal enabledelayedexpansion
title Ledgerly - All-in-One Launcher

:MENU
cls
echo ======================================================================
echo                     LEDGERLY - FINTECH SYSTEM LAUNCHER
echo ======================================================================
echo.
echo   [1] Start Ledgerly Flutter App (On-Device Mobile RAG) [RECOMMENDED]
echo   [2] Run All Automated Verification Tests (flutter test)
echo   [3] Start Node.js Express Backend (Port 5000)
echo   [4] Build Production APK (with Obfuscation & Fast SIMD)
echo   [0] Exit
echo.
echo ======================================================================
set /p choice="Enter your choice [0-4] (default is 1): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto START_FLUTTER
if "%choice%"=="2" goto RUN_TESTS
if "%choice%"=="3" goto START_NODE
if "%choice%"=="4" goto BUILD_APK
if "%choice%"=="0" goto EXIT
goto INVALID

:START_FLUTTER
echo.
echo ======================================================================
echo Launching Ledgerly Flutter App with On-Device RAG Engine...
echo ======================================================================
cd /d "%~dp0"
flutter run
goto END

:RUN_TESTS
echo.
echo ======================================================================
echo Running Flutter & On-Device RAG Test Suite...
echo ======================================================================
cd /d "%~dp0"
call flutter test
echo.
pause
goto MENU

:START_NODE
echo.
echo ======================================================================
echo Starting Node.js Express Backend on http://localhost:5000 ...
echo ======================================================================
cd /d "%~dp0backend"
npm start
goto END

:BUILD_APK
echo.
echo ======================================================================
echo Building Obfuscated Release APK...
echo ======================================================================
cd /d "%~dp0"
flutter build apk --obfuscate --split-debug-info=./build/app/outputs/symbols
echo.
pause
goto MENU

:INVALID
echo Invalid choice. Please try again.
pause
goto MENU

:END
pause

:EXIT
exit /b 0
