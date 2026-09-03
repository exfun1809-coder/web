@echo off
title All Rounders LK - Local Web Server
cd /d "%~dp0"
echo ==========================================================
echo  Starting All Rounders (LK) Local Web Server...
echo ==========================================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0start-server.ps1" -Port 3000
pause
