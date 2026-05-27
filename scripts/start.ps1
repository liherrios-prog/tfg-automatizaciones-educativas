#Requires -Version 5.1
<#
.SYNOPSIS
    Arranca n8n en un equipo nuevo desde USB.
    Instala Docker si no está presente. Abre el navegador al terminar.
.NOTES
    Compatible con PowerShell 5.1 y 7+.
    Requiere permisos de administrador para instalar Docker.
#>

# ── Auto-elevación ────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    $proc = Start-Process -FilePath "powershell" -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Wait -PassThru -ErrorAction SilentlyContinue
    if ($proc) { exit $proc.ExitCode } else { exit 0 }
}

$ProgressPreference    = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

$ScriptDir  = Split-Path $PSCommandPath -Parent
$ProjectDir = Split-Path $ScriptDir -Parent
Set-Location $ProjectDir

# ── Helpers ───────────────────────────────────────────────────────────────────
function Write-Step { param([string]$n, [string]$msg)  Write-Host "`n[$n] $msg" -ForegroundColor Cyan   }
function Write-OK   { param([string]$msg)               Write-Host "    OK  $msg" -ForegroundColor Green  }
function Write-Warn { param([string]$msg)               Write-Host "    !   $msg" -ForegroundColor Yellow }
function Write-Fail { param([string]$msg)               Write-Host "`n  [ERROR] $msg" -ForegroundColor Red }

function Invoke-Compose {
    param([string]$Args)
    # Prueba primero el plugin integrado, luego el binario standalone
    Invoke-Expression "docker compose $Args" 2>$null
    if ($LASTEXITCODE -eq 0) { return $true }
    Invoke-Expression "docker-compose $Args" 2>$null
    return $LASTEXITCODE -eq 0
}

function Wait-Docker {
    param([int]$MaxSeconds = 90)
    $elapsed = 0
    while ($elapsed -lt $MaxSeconds) {
        Start-Sleep 3; $elapsed += 3
        $null = docker info 2>&1
        if ($LASTEXITCODE -eq 0) { return $true }
        Write-Host "    ${elapsed}s...`r" -NoNewline -ForegroundColor Gray
    }
    return $false
}

function Get-EnvPort {
    $line = Select-String -Path ".env" -Pattern "^N8N_PORT=(\d+)" -ErrorAction SilentlyContinue
    if ($line) { return [int]$line.Matches[0].Groups[1].Value }
    return 5678
}

# ── Banner ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host " ============================================" -ForegroundColor Cyan
Write-Host "  n8n — Automatizaciones Educativas"         -ForegroundColor Cyan
Write-Host " ============================================" -ForegroundColor Cyan

# ── PASO 1: Docker instalado ──────────────────────────────────────────────────
Write-Step "1/5" "Verificando Docker..."

$dockerOk = $false
try {
    $v = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) { Write-OK $v; $dockerOk = $true }
} catch {}

if (-not $dockerOk) {
    Write-Warn "Docker no encontrado. Instalando..."

    $installed = $false

    # Método 1: winget
    try {
        $null = winget --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    Usando winget..." -ForegroundColor Gray
            winget install -e --id Docker.DockerDesktop `
                --accept-package-agreements --accept-source-agreements --silent
            $installed = $LASTEXITCODE -eq 0
        }
    } catch {}

    # Método 2: descarga directa
    if (-not $installed) {
        $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'amd64' }
        $url  = "https://desktop.docker.com/win/main/$arch/DockerDesktopInstaller.exe"
        $tmp  = "$env:TEMP\DockerDesktopInstaller.exe"
        Write-Host "    Descargando Docker Desktop ($arch, puede tardar varios minutos)..." -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
            Start-Process $tmp -ArgumentList "install --quiet" -Wait
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
            $installed = $true
        } catch {
            Write-Fail "No se pudo descargar Docker."
            Write-Host "    Instálalo manualmente: https://docs.docker.com/get-docker/" -ForegroundColor White
            Read-Host "`nPulsa Enter para salir"
            exit 1
        }
    }

    Write-Host ""
    Write-OK "Docker Desktop instalado."
    Write-Host ""
    Write-Host "  IMPORTANTE: Reinicia el equipo y vuelve a" -ForegroundColor Yellow
    Write-Host "  ejecutar este script para continuar."      -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pulsa Enter para salir"
    exit 0
}

# ── PASO 2: Docker corriendo ──────────────────────────────────────────────────
Write-Step "2/5" "Verificando que Docker está en ejecución..."

$dockerRunning = $false
try { $null = docker info 2>&1; $dockerRunning = $LASTEXITCODE -eq 0 } catch {}

if (-not $dockerRunning) {
    Write-Warn "Docker no está corriendo. Iniciando Docker Desktop..."

    $dockerPaths = @(
        "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$env:ProgramW6432\Docker\Docker\Docker Desktop.exe",
        "$env:LocalAppData\Programs\Docker\Docker Desktop.exe"
    )
    $launched = $false
    foreach ($p in $dockerPaths) {
        if (Test-Path $p) {
            Start-Process $p -ErrorAction SilentlyContinue
            $launched = $true
            break
        }
    }
    if (-not $launched) {
        # Último recurso: buscar en el registro
        try {
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\Docker Inc.\Docker Desktop" -ErrorAction Stop
            if ($reg.AppPath) {
                Start-Process (Join-Path $reg.AppPath "Docker Desktop.exe") -ErrorAction SilentlyContinue
                $launched = $true
            }
        } catch {}
    }

    Write-Host "    Esperando a Docker (máx. 90s)..." -ForegroundColor Gray
    $dockerRunning = Wait-Docker -MaxSeconds 90
    Write-Host "                    " -NoNewline; Write-Host ""   # limpiar línea

    if (-not $dockerRunning) {
        Write-Fail "Docker no arrancó en 90s. Ábrelo manualmente y re-ejecuta este script."
        Read-Host "`nPulsa Enter para salir"
        exit 1
    }
}
Write-OK "Docker está corriendo."

# ── PASO 3: Preparar entorno ──────────────────────────────────────────────────
Write-Step "3/5" "Preparando el entorno..."

if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-OK "Creado .env desde .env.example"
    } else {
        "N8N_PORT=5678`nTIMEZONE=Europe/Madrid" | Set-Content ".env"
        Write-OK "Creado .env con valores por defecto"
    }
}
if (-not (Test-Path "n8n-data")) {
    New-Item -ItemType Directory "n8n-data" | Out-Null
    Write-OK "Directorio n8n-data creado"
}

# ── PASO 4: Arrancar n8n ──────────────────────────────────────────────────────
Write-Step "4/5" "Iniciando n8n..."

$ok = Invoke-Compose "up -d"
if (-not $ok) {
    Write-Fail "No se pudo iniciar n8n."
    Write-Host "    Comprueba que el puerto 5678 no está ocupado:" -ForegroundColor White
    Write-Host "    netstat -aon | findstr :5678" -ForegroundColor Gray
    Read-Host "`nPulsa Enter para salir"
    exit 1
}
Write-OK "Contenedor iniciado."

# ── PASO 5: Health check ──────────────────────────────────────────────────────
$port = Get-EnvPort

Write-Step "5/5" "Esperando a que n8n esté listo (máx. 60s)..."

$ready = $false; $elapsed = 0
while (-not $ready -and $elapsed -lt 60) {
    Start-Sleep 2; $elapsed += 2
    try {
        $null = Invoke-WebRequest -Uri "http://localhost:$port/" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        $ready = $true
    } catch {
        try {
            $conn = Test-NetConnection -ComputerName localhost -Port $port `
                -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            if ($conn) { $ready = $true }
        } catch {}
    }
    if (-not $ready) { Write-Host "    ${elapsed}s...`r" -NoNewline -ForegroundColor Gray }
}
Write-Host "                    " -NoNewline; Write-Host ""  # limpiar línea

if ($ready) { Write-OK "n8n listo." } else { Write-Warn "n8n puede tardar unos segundos más." }

# ── Resultado final ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host " ============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  n8n está arrancando!"                     -ForegroundColor Green
Write-Host "  http://localhost:$port"                   -ForegroundColor Cyan
Write-Host ""
Write-Host "  Primera vez? Crea una cuenta en la web."  -ForegroundColor White
Write-Host "  Para parar:  scripts\stop.bat"            -ForegroundColor White
Write-Host ""
Write-Host " ============================================" -ForegroundColor Green
Write-Host ""

# explorer.exe abre el navegador como usuario normal aunque el script corra elevado
Start-Process "explorer.exe" "http://localhost:$port"

Read-Host "`nPulsa Enter para cerrar esta ventana"
