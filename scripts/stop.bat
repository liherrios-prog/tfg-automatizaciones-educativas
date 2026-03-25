@echo off
REM ============================================
REM Parada de n8n - Entorno Educativo
REM ============================================

cd /d "%~dp0\.."

echo Parando n8n...
docker compose down

echo n8n se ha detenido. Tus datos estan guardados en n8n-data/
pause
