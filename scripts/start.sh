#!/bin/bash
# ============================================
#  Arranque de n8n - Entorno Educativo
#  Script multiplataforma para Linux y macOS
#  Detecta el SO, instala Docker si hace falta
#  y levanta el entorno automaticamente
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

echo ""
echo -e "${BLUE} ============================================${NC}"
echo -e "${BLUE}  n8n - Automatizaciones Educativas${NC}"
echo -e "${BLUE}  Comprobando el sistema...${NC}"
echo -e "${BLUE} ============================================${NC}"
echo ""

# ============================================
#  PASO 1: Detectar sistema operativo
# ============================================
echo -e "[1/5] Detectando sistema operativo..."

OS="$(uname -s)"
ARCH="$(uname -m)"
DISTRO=""

case "$OS" in
    Linux*)
        OS_NAME="Linux"
        # Detectar la distribucion
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="$NAME $VERSION_ID"
        elif [ -f /etc/debian_version ]; then
            DISTRO="Debian $(cat /etc/debian_version)"
        elif [ -f /etc/redhat-release ]; then
            DISTRO="$(cat /etc/redhat-release)"
        else
            DISTRO="Desconocida"
        fi
        echo -e "       ${GREEN}Linux detectado${NC} ($DISTRO, $ARCH)"
        ;;
    Darwin*)
        OS_NAME="macOS"
        MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || echo 'desconocida')"
        echo -e "       ${GREEN}macOS detectado${NC} (version $MACOS_VERSION, $ARCH)"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        OS_NAME="Windows"
        echo -e "       ${YELLOW}Windows detectado (Git Bash/MSYS)${NC}"
        echo -e "       ${YELLOW}Recomendacion: usa scripts\\start.bat para mejor compatibilidad.${NC}"
        ;;
    *)
        echo -e "       ${RED}Sistema operativo no reconocido: $OS${NC}"
        echo "       Este script soporta Linux y macOS."
        exit 1
        ;;
esac

# ============================================
#  PASO 2: Verificar si Docker esta instalado
# ============================================
echo "[2/5] Comprobando si Docker esta instalado..."

if command -v docker &> /dev/null; then
    DOCKER_VERSION="$(docker --version)"
    echo -e "       ${GREEN}$DOCKER_VERSION${NC}"
else
    echo ""
    echo -e "       ${YELLOW}Docker NO esta instalado en este equipo.${NC}"
    echo "       Intentando instalarlo automaticamente..."
    echo ""

    case "$OS_NAME" in
        Linux)
            # Comprobar si somos root o podemos usar sudo
            if [ "$EUID" -ne 0 ]; then
                if ! command -v sudo &> /dev/null; then
                    echo -e "  ${RED}[ERROR] Se necesitan permisos de administrador para instalar Docker.${NC}"
                    echo "  Ejecuta este script como root: sudo ./scripts/start.sh"
                    exit 1
                fi
                SUDO="sudo"
            else
                SUDO=""
            fi

            echo "       Instalando Docker en Linux..."
            echo "       Usando el script oficial de instalacion de Docker..."
            echo ""

            # Metodo 1: Script oficial de Docker (funciona en Ubuntu, Debian, Fedora, CentOS...)
            if command -v curl &> /dev/null; then
                curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
                $SUDO sh /tmp/get-docker.sh
                rm /tmp/get-docker.sh
            elif command -v wget &> /dev/null; then
                wget -qO /tmp/get-docker.sh https://get.docker.com
                $SUDO sh /tmp/get-docker.sh
                rm /tmp/get-docker.sh
            else
                echo -e "  ${RED}[ERROR] Se necesita curl o wget para descargar Docker.${NC}"
                echo "  Instala curl con: sudo apt install curl (Debian/Ubuntu)"
                echo "                    sudo dnf install curl (Fedora)"
                exit 1
            fi

            # Anadir el usuario actual al grupo docker para no necesitar sudo
            if [ "$EUID" -ne 0 ]; then
                $SUDO usermod -aG docker "$USER"
                echo ""
                echo -e "  ${YELLOW}IMPORTANTE: Se ha anadido tu usuario al grupo 'docker'.${NC}"
                echo -e "  ${YELLOW}Cierra la sesion y vuelve a entrar para que surta efecto,${NC}"
                echo -e "  ${YELLOW}o ejecuta: newgrp docker${NC}"
                echo ""
            fi

            # Instalar docker-compose plugin si no esta incluido
            if ! docker compose version &> /dev/null 2>&1; then
                echo "       Instalando Docker Compose plugin..."
                $SUDO apt-get install -y docker-compose-plugin 2>/dev/null || \
                $SUDO dnf install -y docker-compose-plugin 2>/dev/null || \
                echo -e "  ${YELLOW}No se pudo instalar docker-compose automaticamente.${NC}"
            fi

            # Iniciar el servicio Docker
            $SUDO systemctl start docker 2>/dev/null || $SUDO service docker start 2>/dev/null || true
            $SUDO systemctl enable docker 2>/dev/null || true

            echo ""
            echo -e "       ${GREEN}Docker instalado correctamente.${NC}"
            ;;

        macOS)
            echo "       En macOS, Docker Desktop se instala como aplicacion."
            echo ""

            # Intentar con Homebrew
            if command -v brew &> /dev/null; then
                echo "       Homebrew detectado. Instalando Docker Desktop..."
                brew install --cask docker
                echo ""
                echo -e "       ${GREEN}Docker Desktop instalado.${NC}"
                echo -e "       ${YELLOW}Abre Docker Desktop desde Aplicaciones antes de continuar.${NC}"
                echo ""
                echo "       Esperando a que Docker arranque..."
                open -a Docker 2>/dev/null || true

                # Esperar hasta 60 segundos
                INTENTOS=0
                while ! docker info &> /dev/null 2>&1; do
                    INTENTOS=$((INTENTOS + 1))
                    if [ $INTENTOS -gt 30 ]; then
                        echo -e "  ${RED}[ERROR] Docker no ha arrancado en 60 segundos.${NC}"
                        echo "  Abre Docker Desktop manualmente y vuelve a ejecutar este script."
                        exit 1
                    fi
                    sleep 2
                done
                echo -e "       ${GREEN}Docker esta listo.${NC}"
            else
                echo -e "  ${YELLOW}Homebrew no esta disponible.${NC}"
                echo ""
                echo "  Instala Docker Desktop manualmente:"
                if [ "$ARCH" = "arm64" ]; then
                    echo "  https://desktop.docker.com/mac/main/arm64/Docker.dmg"
                else
                    echo "  https://desktop.docker.com/mac/main/amd64/Docker.dmg"
                fi
                echo ""
                echo "  Una vez instalado, vuelve a ejecutar este script."
                exit 1
            fi
            ;;
    esac

    # Verificar que la instalacion fue exitosa
    if ! command -v docker &> /dev/null; then
        echo -e "  ${RED}[ERROR] La instalacion de Docker no se completo correctamente.${NC}"
        echo "  Instala Docker manualmente: https://docs.docker.com/get-docker/"
        exit 1
    fi
fi

# ============================================
#  PASO 3: Verificar que Docker esta corriendo
# ============================================
echo "[3/5] Comprobando que Docker esta en ejecucion..."

if ! docker info &> /dev/null 2>&1; then
    echo -e "       ${YELLOW}Docker esta instalado pero no esta corriendo.${NC}"
    echo "       Intentando iniciarlo..."

    case "$OS_NAME" in
        Linux)
            sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || true
            ;;
        macOS)
            open -a Docker 2>/dev/null || true
            ;;
    esac

    echo "       Esperando a que Docker arranque (hasta 60 segundos)..."

    INTENTOS=0
    while ! docker info &> /dev/null 2>&1; do
        INTENTOS=$((INTENTOS + 1))
        if [ $INTENTOS -gt 30 ]; then
            echo -e "  ${RED}[ERROR] Docker no ha arrancado despues de 60 segundos.${NC}"
            echo "  Inicia Docker manualmente y vuelve a ejecutar este script."
            exit 1
        fi
        sleep 2
    done
fi

echo -e "       ${GREEN}Docker esta corriendo correctamente.${NC}"

# ============================================
#  PASO 4: Preparar el entorno
# ============================================
echo "[4/5] Preparando el entorno..."

# Crear .env desde ejemplo si no existe
if [ ! -f .env ]; then
    echo "       Creando archivo .env desde .env.example..."
    cp .env.example .env
fi

# Crear directorio de datos si no existe
mkdir -p n8n-data

echo -e "       ${GREEN}Entorno preparado.${NC}"

# ============================================
#  PASO 5: Levantar n8n
# ============================================
echo "[5/5] Iniciando n8n..."
echo ""

docker compose up -d

if [ $? -ne 0 ]; then
    echo ""
    echo -e "  ${RED}[ERROR] No se pudo iniciar n8n.${NC}"
    echo "  Comprueba que el puerto 5678 no este ocupado."
    echo "  Puedes cambiar el puerto en el archivo .env"
    exit 1
fi

# Leer el puerto del .env
N8N_PORT="${N8N_PORT:-5678}"
if [ -f .env ]; then
    PORT_LINE="$(grep -E '^N8N_PORT=' .env 2>/dev/null || true)"
    if [ -n "$PORT_LINE" ]; then
        N8N_PORT="${PORT_LINE#N8N_PORT=}"
    fi
fi

echo ""
echo -e "${GREEN} ============================================${NC}"
echo ""
echo "  n8n esta arrancando!"
echo ""
echo -e "  Abre tu navegador en:"
echo -e "  ${BLUE}http://localhost:${N8N_PORT}${NC}"
echo ""
echo "  Primera vez? n8n te pedira crear una cuenta."
echo "  Los datos se guardan en la carpeta n8n-data/"
echo ""
echo "  Para parar: ./scripts/stop.sh"
echo ""
echo -e "${GREEN} ============================================${NC}"
echo ""
