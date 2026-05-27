#!/bin/bash
# ============================================
#  Arranque de n8n — Entorno Educativo
#  Linux y macOS — equipos nuevos compatibles
#  Detecta e instala Docker si hace falta.
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

step() { printf "\n${CYAN}[%s]${NC} %s\n" "$1" "$2"; }
ok()   { printf "    ${GREEN}OK${NC}  %s\n" "$1"; }
warn() { printf "    ${YELLOW}!${NC}   %s\n" "$1"; }
die()  { printf "\n  ${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

# ── Detectar OS ──────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Linux*)         echo "linux"   ;;
        Darwin*)        echo "macos"   ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)              echo "unknown" ;;
    esac
}

OS="$(detect_os)"
[ "$OS" = "windows" ] && die "Usa scripts\\start.bat o scripts\\start.ps1 en Windows."
[ "$OS" = "unknown" ] && die "Sistema operativo no soportado. Instala Docker manualmente: https://docs.docker.com/get-docker/"

# ── docker compose vs docker-compose ─────────
dc() {
    if docker compose version >/dev/null 2>&1; then
        docker compose "$@"
    elif command -v docker-compose >/dev/null 2>&1; then
        docker-compose "$@"
    else
        die "docker compose no encontrado. Actualiza Docker Desktop o instala el plugin."
    fi
}

# ── Abrir navegador ──────────────────────────
open_browser() {
    local url="$1"
    case "$OS" in
        linux) xdg-open "$url" >/dev/null 2>&1 & ;;
        macos) open     "$url" >/dev/null 2>&1 & ;;
    esac
}

# ── Banner ───────────────────────────────────
printf "\n${CYAN} ============================================\n"
printf "  n8n — Automatizaciones Educativas\n"
printf " ============================================${NC}\n"

# ── PASO 1: Docker instalado? ─────────────────
step "1/5" "Verificando Docker..."

if ! command -v docker >/dev/null 2>&1; then
    warn "Docker no encontrado. Instalando..."

    # Necesitamos sudo en Linux si no somos root
    SUDO=""
    if [ "$OS" = "linux" ] && [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 || die "Se necesitan permisos de root para instalar Docker. Ejecuta: sudo $0"
        SUDO="sudo"
    fi

    case "$OS" in
        linux)
            if command -v curl >/dev/null 2>&1; then
                curl -fsSL https://get.docker.com | $SUDO sh \
                    || die "Falló la instalación de Docker. Instálalo manualmente: https://docs.docker.com/get-docker/"
            elif command -v wget >/dev/null 2>&1; then
                wget -qO- https://get.docker.com | $SUDO sh \
                    || die "Falló la instalación de Docker. Instálalo manualmente: https://docs.docker.com/get-docker/"
            else
                die "Se necesita curl o wget para instalar Docker.\n  Instala curl: sudo apt install curl  (Debian/Ubuntu)\n                sudo dnf install curl  (Fedora/RHEL)"
            fi

            # Añadir usuario al grupo docker (sin sudo para comandos futuros)
            if [ "$(id -u)" -ne 0 ]; then
                $SUDO usermod -aG docker "$USER" 2>/dev/null || true
                warn "Usuario añadido al grupo docker."
                warn "Si docker da error de permisos, ejecuta: newgrp docker"
            fi

            # Iniciar servicio Docker
            $SUDO systemctl start  docker 2>/dev/null \
                || $SUDO service docker start 2>/dev/null || true
            $SUDO systemctl enable docker 2>/dev/null || true

            command -v docker >/dev/null 2>&1 \
                || die "Instalación no completada. Instala Docker manualmente: https://docs.docker.com/get-docker/"

            ok "Docker instalado."
            ;;

        macos)
            if command -v brew >/dev/null 2>&1; then
                echo "    Instalando Docker Desktop con Homebrew..."
                brew install --cask docker \
                    || die "Falló la instalación con Homebrew."
                open -a Docker 2>/dev/null || true
                ok "Docker Desktop instalado."
                warn "Espera a que Docker Desktop abra por primera vez."
            else
                ARCH="$(uname -m)"
                if [ "$ARCH" = "arm64" ]; then
                    URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
                else
                    URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
                fi
                die "Instala Docker Desktop manualmente: $URL\nDespués vuelve a ejecutar este script."
            fi
            ;;
    esac
else
    ok "$(docker --version)"
fi

# ── PASO 2: Docker corriendo? ────────────────
step "2/5" "Verificando que Docker está en ejecución..."

if ! docker info >/dev/null 2>&1; then
    warn "Docker no está corriendo. Iniciando..."

    SUDO=""
    [ "$OS" = "linux" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

    case "$OS" in
        linux)
            $SUDO systemctl start docker 2>/dev/null \
                || $SUDO service docker start 2>/dev/null || true
            ;;
        macos)
            open -a Docker 2>/dev/null || true
            ;;
    esac

    printf "    Esperando a Docker (máx. 90s)...\n"
    ELAPSED=0
    while ! docker info >/dev/null 2>&1; do
        sleep 3; ELAPSED=$((ELAPSED + 3))
        [ "$ELAPSED" -gt 90 ] && die "Docker no arrancó en 90s.\nÁbrelo manualmente y vuelve a ejecutar este script."
        printf "    %ds...\r" "$ELAPSED"
    done
    printf "                    \n"
fi

ok "Docker está corriendo."

# ── PASO 3: Entorno ───────────────────────────
step "3/5" "Preparando el entorno..."

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        ok "Creado .env desde .env.example"
    else
        printf 'N8N_PORT=5678\nTIMEZONE=Europe/Madrid\n' > .env
        ok "Creado .env con valores por defecto"
    fi
fi

mkdir -p n8n-data
ok "Entorno preparado."

# ── PASO 4: Arrancar n8n ──────────────────────
step "4/5" "Iniciando n8n..."

dc up -d || die "No se pudo iniciar n8n. ¿Puerto 5678 ocupado?\n  Diagnóstico: ss -tlnp | grep 5678"
ok "Contenedor iniciado."

# ── PASO 5: Health check ──────────────────────
N8N_PORT=5678
if [ -f .env ]; then
    PORT_VAL="$(grep -E '^N8N_PORT=[0-9]+' .env 2>/dev/null | head -1)"
    [ -n "$PORT_VAL" ] && N8N_PORT="${PORT_VAL#N8N_PORT=}"
fi

step "5/5" "Esperando a que n8n esté listo (máx. 60s)..."

ELAPSED=0
READY=0
while [ "$READY" -eq 0 ] && [ "$ELAPSED" -lt 60 ]; do
    sleep 2; ELAPSED=$((ELAPSED + 2))
    if curl -s --max-time 2 "http://localhost:$N8N_PORT/" -o /dev/null 2>/dev/null; then
        READY=1
    fi
    [ "$READY" -eq 0 ] && printf "    %ds...\r" "$ELAPSED"
done
printf "                    \n"

if [ "$READY" -eq 1 ]; then
    ok "n8n listo."
else
    warn "n8n puede tardar unos segundos más en responder."
fi

printf "\n${GREEN} ============================================${NC}\n"
printf "\n"
printf "  n8n está arrancando!\n"
printf "  ${CYAN}http://localhost:${N8N_PORT}${NC}\n"
printf "\n"
printf "  Primera vez? Crea una cuenta en la web.\n"
printf "  Para parar:  ./scripts/stop.sh\n"
printf "\n"
printf "${GREEN} ============================================${NC}\n\n"

open_browser "http://localhost:$N8N_PORT"
