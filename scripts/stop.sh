#!/bin/bash
# ============================================
# Parada de n8n - Entorno Educativo
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Parando n8n..."
docker compose down

echo "n8n se ha detenido. Tus datos estan guardados en n8n-data/"
