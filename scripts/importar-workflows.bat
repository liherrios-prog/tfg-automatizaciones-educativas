@echo off
REM =============================================================================
REM Importar todos los workflows de n8n automaticamente
REM Usa la API REST de n8n para importar cada JSON de la carpeta workflows/
REM Requiere: n8n corriendo en localhost, curl instalado (incluido en Windows 10+)
REM =============================================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "WORKFLOWS_DIR=%PROJECT_DIR%\workflows"
set "N8N_PORT=5678"

REM Leer puerto del .env si existe
if exist "%PROJECT_DIR%\.env" (
    for /f "tokens=2 delims==" %%a in ('findstr /B "N8N_PORT" "%PROJECT_DIR%\.env"') do set "N8N_PORT=%%a"
)

set "N8N_URL=http://localhost:%N8N_PORT%"

echo === Importador de Workflows n8n ===
echo URL: %N8N_URL%
echo Directorio: %WORKFLOWS_DIR%
echo.

REM Verificar que n8n esta corriendo
curl -s "%N8N_URL%/healthz" > nul 2>&1
if errorlevel 1 (
    echo ERROR: n8n no esta corriendo en %N8N_URL%
    echo Ejecuta primero: scripts\start.bat
    exit /b 1
)

REM Importar cada workflow
set OK=0
set FAIL=0
set TOTAL=0

for %%f in ("%WORKFLOWS_DIR%\*.json") do (
    set /a TOTAL+=1
    set "FILENAME=%%~nxf"

    curl -s -o nul -w "%%{http_code}" -X POST "%N8N_URL%/api/v1/workflows" -H "Content-Type: application/json" -d @"%%f" > "%TEMP%\n8n_import_code.tmp" 2>nul
    set /p RESPONSE=<"%TEMP%\n8n_import_code.tmp"

    if "!RESPONSE!"=="200" (
        echo   [OK] !FILENAME!
        set /a OK+=1
    ) else if "!RESPONSE!"=="201" (
        echo   [OK] !FILENAME!
        set /a OK+=1
    ) else (
        echo   [FAIL] !FILENAME! ^(HTTP !RESPONSE!^)
        set /a FAIL+=1
    )
)

del "%TEMP%\n8n_import_code.tmp" 2>nul

echo.
echo === Resultado ===
echo   Importados: %OK% de %TOTAL%
if %FAIL% gtr 0 echo   Fallidos:   %FAIL%
echo.
echo Abre %N8N_URL% en el navegador para ver los workflows importados.
pause
