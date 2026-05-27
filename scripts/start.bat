@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

cd /d "%~dp0\.."

REM ─── Si se ejecuta desde PowerShell, delegar a start.ps1 ─────────────────
REM PSModulePath solo existe en entornos PowerShell
if defined PSModulePath (
    echo Detectado PowerShell. Usando start.ps1...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1"
    exit /b %errorlevel%
)

REM ─── Modo cmd.exe nativo ──────────────────────────────────────────────────

echo.
echo  ============================================
echo   n8n - Automatizaciones Educativas
echo  ============================================
echo.

REM ── PASO 1: Docker instalado? ─────────────────
echo [1/5] Verificando Docker...

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo     Docker no encontrado. Instalando...
    echo.
    set "INSTALLED=0"

    REM Intento 1: winget
    winget --version >nul 2>&1
    if !errorlevel! equ 0 (
        echo     Usando winget...
        winget install -e --id Docker.DockerDesktop ^
            --accept-package-agreements --accept-source-agreements --silent
        if !errorlevel! equ 0 set "INSTALLED=1"
    )

    REM Intento 2: curl (incluido en Windows 10+)
    if !INSTALLED! equ 0 (
        where curl.exe >nul 2>&1
        if !errorlevel! equ 0 (
            echo     Descargando Docker Desktop con curl...
            curl.exe -L --progress-bar -o "%TEMP%\DockerSetup.exe" ^
                "https://desktop.docker.com/win/main/amd64/DockerDesktopInstaller.exe"
            if !errorlevel! equ 0 (
                start /wait "" "%TEMP%\DockerSetup.exe" install --quiet
                del "%TEMP%\DockerSetup.exe" >nul 2>&1
                set "INSTALLED=1"
            )
        )
    )

    REM Intento 3: PowerShell como fallback
    if !INSTALLED! equ 0 (
        echo     Descargando con PowerShell...
        powershell -NoProfile -ExecutionPolicy Bypass -Command ^
            "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/DockerDesktopInstaller.exe' -OutFile '%TEMP%\DockerSetup.exe' -UseBasicParsing"
        if exist "%TEMP%\DockerSetup.exe" (
            start /wait "" "%TEMP%\DockerSetup.exe" install --quiet
            del "%TEMP%\DockerSetup.exe" >nul 2>&1
            set "INSTALLED=1"
        )
    )

    if !INSTALLED! equ 0 (
        echo.
        echo  [ERROR] No se pudo instalar Docker automaticamente.
        echo  Instálalo manualmente: https://docs.docker.com/get-docker/
        pause
        exit /b 1
    )

    echo.
    echo     Docker Desktop instalado.
    echo.
    echo  IMPORTANTE: Reinicia el equipo y vuelve a ejecutar
    echo  este script para continuar.
    echo.
    pause
    exit /b 0
)

for /f "tokens=*" %%v in ('docker --version 2^>nul') do echo     %%v

REM ── PASO 2: Docker corriendo? ────────────────
echo [2/5] Verificando que Docker esta en ejecucion...

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo     Docker instalado pero no corriendo. Iniciando...

    REM Buscar Docker Desktop en varias rutas posibles
    set "DOCKER_EXE="
    if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
        set "DOCKER_EXE=%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
    )
    if "!DOCKER_EXE!"=="" if exist "%ProgramW6432%\Docker\Docker\Docker Desktop.exe" (
        set "DOCKER_EXE=%ProgramW6432%\Docker\Docker\Docker Desktop.exe"
    )
    if "!DOCKER_EXE!"=="" if exist "%LocalAppData%\Programs\Docker\Docker Desktop.exe" (
        set "DOCKER_EXE=%LocalAppData%\Programs\Docker\Docker Desktop.exe"
    )

    if not "!DOCKER_EXE!"=="" (
        start "" "!DOCKER_EXE!"
    ) else (
        REM Último recurso: intentar por nombre
        powershell -NoProfile -Command "Start-Process 'Docker Desktop' -ErrorAction SilentlyContinue"
    )

    echo     Esperando a Docker (max. 90 segundos)...
    set "WAIT=0"
    :wait_docker
    set /a WAIT+=3
    if !WAIT! gtr 90 (
        echo.
        echo  [ERROR] Docker no arranco en 90 segundos.
        echo  Abre Docker Desktop manualmente y re-ejecuta este script.
        pause
        exit /b 1
    )
    timeout /t 3 /nobreak >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 goto wait_docker
    echo     Docker listo.
)

echo     Docker esta corriendo.

REM ── PASO 3: Entorno ──────────────────────────
echo [3/5] Preparando el entorno...

if not exist .env (
    if exist .env.example (
        copy .env.example .env >nul
        echo     Creado .env desde .env.example
    ) else (
        (echo N8N_PORT=5678) > .env
        (echo TIMEZONE=Europe/Madrid) >> .env
        echo     Creado .env con valores por defecto
    )
)
if not exist n8n-data mkdir n8n-data >nul 2>&1

REM ── PASO 4: Arrancar n8n ─────────────────────
echo [4/5] Iniciando n8n...

docker compose up -d >nul 2>&1
if %errorlevel% neq 0 (
    REM Fallback: docker-compose con guion (versiones antiguas de Docker)
    docker-compose up -d >nul 2>&1
    if !errorlevel! neq 0 (
        echo.
        echo  [ERROR] No se pudo iniciar n8n.
        echo  Comprueba que el puerto 5678 no esta ocupado:
        echo  netstat -aon ^| findstr :5678
        pause
        exit /b 1
    )
)
echo     Contenedor iniciado.

REM ── PASO 5: Health check ─────────────────────
echo [5/5] Esperando a que n8n este listo...

set "N8N_PORT=5678"
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="N8N_PORT" set "N8N_PORT=%%b"
)

set "HC=0"
:healthcheck
set /a HC+=1
if %HC% gtr 30 (
    echo     (n8n puede tardar unos segundos mas en responder)
    goto n8n_ready
)
timeout /t 2 /nobreak >nul
curl -s --max-time 2 -o nul http://localhost:%N8N_PORT%/ 2>nul
if %errorlevel% neq 0 goto healthcheck
echo     n8n listo!

:n8n_ready
echo.
echo  ============================================
echo.
echo   n8n esta arrancando!
echo   http://localhost:%N8N_PORT%
echo.
echo   Primera vez? Crea una cuenta en la web.
echo   Para parar: scripts\stop.bat
echo.
echo  ============================================
echo.

start http://localhost:%N8N_PORT%
pause
