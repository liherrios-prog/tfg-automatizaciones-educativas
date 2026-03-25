@echo off
chcp 65001 >nul 2>&1
REM ============================================
REM  Arranque de n8n - Entorno Educativo
REM  Script multiplataforma para Windows
REM  Detecta Docker, lo instala si hace falta
REM  y levanta el entorno automaticamente
REM ============================================

cd /d "%~dp0\.."

echo.
echo  ============================================
echo   n8n - Automatizaciones Educativas
echo   Comprobando el sistema...
echo  ============================================
echo.

REM ============================================
REM  PASO 1: Detectar sistema operativo
REM ============================================
echo [1/5] Detectando sistema operativo...

for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo        Windows detectado (version %VERSION%)

REM Comprobar si es Windows 10 o superior (necesario para Docker Desktop)
for /f "tokens=1 delims=." %%a in ("%VERSION%") do set MAJOR=%%a
if %MAJOR% LSS 10 (
    echo.
    echo  [ERROR] Docker Desktop requiere Windows 10 o superior.
    echo  Tu version de Windows no es compatible.
    echo  Considera usar una maquina con Windows 10/11 o Linux.
    echo.
    pause
    exit /b 1
)

REM ============================================
REM  PASO 2: Verificar si Docker esta instalado
REM ============================================
echo [2/5] Comprobando si Docker esta instalado...

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo        Docker NO esta instalado en este equipo.
    echo        Intentando instalarlo automaticamente...
    echo.

    REM Intentar instalar con winget (disponible en Windows 10 1709+)
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo        Usando winget para instalar Docker Desktop...
        echo        Esto puede tardar unos minutos. No cierres esta ventana.
        echo.
        winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

        if %errorlevel% equ 0 (
            echo.
            echo        Docker Desktop se ha instalado correctamente.
            echo.
            echo  ============================================
            echo   IMPORTANTE: Reinicia el equipo para que
            echo   Docker termine de configurarse. Despues,
            echo   vuelve a ejecutar este script.
            echo  ============================================
            echo.
            pause
            exit /b 0
        ) else (
            echo.
            echo        No se pudo instalar con winget.
            echo        Intentando descarga directa...
            echo.
        )
    )

    REM Si winget falla, intentar con PowerShell (descarga directa)
    echo        Descargando Docker Desktop con PowerShell...
    echo        Esto puede tardar unos minutos segun tu conexion.
    echo.

    set "DOCKER_URL=https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe"
    set "DOCKER_INSTALLER=%TEMP%\DockerDesktopInstaller.exe"

    powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOCKER_URL%' -OutFile '%DOCKER_INSTALLER%' -UseBasicParsing } catch { exit 1 }"

    if exist "%DOCKER_INSTALLER%" (
        echo        Descarga completada. Ejecutando instalador...
        echo        Sigue las instrucciones del instalador de Docker Desktop.
        echo.
        start /wait "" "%DOCKER_INSTALLER%" install --quiet
        del "%DOCKER_INSTALLER%" >nul 2>&1

        echo.
        echo  ============================================
        echo   Docker Desktop se ha instalado.
        echo   Reinicia el equipo y vuelve a ejecutar
        echo   este script.
        echo  ============================================
        echo.
        pause
        exit /b 0
    ) else (
        echo.
        echo  ============================================
        echo   No se pudo descargar Docker automaticamente.
        echo   Por favor, instala Docker Desktop manualmente:
        echo.
        echo   https://www.docker.com/products/docker-desktop/
        echo.
        echo   Una vez instalado, reinicia el equipo y
        echo   vuelve a ejecutar este script.
        echo  ============================================
        echo.
        pause
        exit /b 1
    )
)

for /f "tokens=*" %%v in ('docker --version') do echo        %%v

REM ============================================
REM  PASO 3: Verificar que Docker esta corriendo
REM ============================================
echo [3/5] Comprobando que Docker esta en ejecucion...

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo        Docker esta instalado pero no esta corriendo.
    echo        Intentando iniciar Docker Desktop...

    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" >nul 2>&1
    if %errorlevel% neq 0 (
        start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" >nul 2>&1
    )

    echo        Esperando a que Docker arranque (puede tardar hasta 60 segundos)...

    set INTENTOS=0
    :esperar_docker
    set /a INTENTOS+=1
    if %INTENTOS% gtr 30 (
        echo.
        echo  [ERROR] Docker no ha arrancado despues de 60 segundos.
        echo  Abre Docker Desktop manualmente y vuelve a ejecutar este script.
        echo.
        pause
        exit /b 1
    )
    timeout /t 2 /nobreak >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 goto esperar_docker

    echo        Docker esta listo.
)

echo        Docker esta corriendo correctamente.

REM ============================================
REM  PASO 4: Preparar el entorno
REM ============================================
echo [4/5] Preparando el entorno...

REM Crear .env desde ejemplo si no existe
if not exist .env (
    echo        Creando archivo .env desde .env.example...
    copy .env.example .env >nul
)

REM Crear directorio de datos si no existe
if not exist n8n-data mkdir n8n-data

echo        Entorno preparado.

REM ============================================
REM  PASO 5: Levantar n8n
REM ============================================
echo [5/5] Iniciando n8n...
echo.

docker compose up -d

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] No se pudo iniciar n8n.
    echo  Comprueba que el puerto 5678 no este ocupado.
    echo  Puedes cambiar el puerto en el archivo .env
    echo.
    pause
    exit /b 1
)

REM Leer el puerto del .env o usar el predeterminado
set N8N_PORT=5678
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="N8N_PORT" set N8N_PORT=%%b
)

echo.
echo  ============================================
echo.
echo   n8n esta arrancando!
echo.
echo   Abre tu navegador en:
echo   http://localhost:%N8N_PORT%
echo.
echo   Primera vez? n8n te pedira crear una cuenta.
echo   Los datos se guardan en la carpeta n8n-data/
echo.
echo   Para parar: scripts\stop.bat
echo.
echo  ============================================
echo.
pause
