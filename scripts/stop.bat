@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

cd /d "%~dp0\.."

REM ─── Si se ejecuta desde PowerShell, usar PowerShell nativo ──────────────
if defined PSModulePath (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Set-Location '%cd%'; docker compose down; if ($LASTEXITCODE -ne 0) { docker-compose down }; Write-Host 'n8n detenido. Datos guardados en n8n-data/' -ForegroundColor Green"
    exit /b %errorlevel%
)

echo Parando n8n...
docker compose down 2>nul
if %errorlevel% neq 0 (
    docker-compose down 2>nul
)

echo n8n se ha detenido. Datos guardados en n8n-data/
