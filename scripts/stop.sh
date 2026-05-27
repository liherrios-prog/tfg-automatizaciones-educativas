#!/bin/bash
# ============================================
#  Parada de n8n — Entorno Educativo
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "Parando n8n..."

if docker compose version >/dev/null 2>&1; then
    docker compose down
elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose down
else
    echo "[ERROR] docker compose no encontrado."
    exit 1
fi

echo "n8n se ha detenido. Datos guardados en n8n-data/"
