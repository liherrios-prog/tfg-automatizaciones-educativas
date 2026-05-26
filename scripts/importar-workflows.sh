#!/bin/bash
# =============================================================================
# Importar todos los workflows de n8n automáticamente
# Usa la API REST de n8n para importar cada JSON de la carpeta workflows/
# Requiere: n8n corriendo en localhost, curl instalado
# =============================================================================

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuración
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORKFLOWS_DIR="$PROJECT_DIR/workflows"

# Leer puerto del .env o usar 5678 por defecto
if [ -f "$PROJECT_DIR/.env" ]; then
    N8N_PORT=$(grep -E '^N8N_PORT=' "$PROJECT_DIR/.env" | cut -d'=' -f2)
fi
N8N_PORT=${N8N_PORT:-5678}
N8N_URL="http://localhost:$N8N_PORT"

echo -e "${GREEN}=== Importador de Workflows n8n ===${NC}"
echo "URL: $N8N_URL"
echo "Directorio: $WORKFLOWS_DIR"
echo ""

# Verificar que n8n está corriendo
if ! curl -s "$N8N_URL/healthz" > /dev/null 2>&1; then
    echo -e "${RED}ERROR: n8n no está corriendo en $N8N_URL${NC}"
    echo "Ejecuta primero: ./scripts/start.sh"
    exit 1
fi

# Contar workflows
TOTAL=$(ls "$WORKFLOWS_DIR"/*.json 2>/dev/null | wc -l)
if [ "$TOTAL" -eq 0 ]; then
    echo -e "${RED}No se encontraron archivos JSON en $WORKFLOWS_DIR${NC}"
    exit 1
fi

echo -e "Encontrados ${GREEN}$TOTAL${NC} workflows para importar."
echo ""

# Importar cada workflow
OK=0
FAIL=0
for JSON_FILE in "$WORKFLOWS_DIR"/*.json; do
    FILENAME=$(basename "$JSON_FILE")
    WF_NAME=$(python3 -c "import json; print(json.load(open('$JSON_FILE'))['name'])" 2>/dev/null || echo "$FILENAME")

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$N8N_URL/api/v1/workflows" \
        -H "Content-Type: application/json" \
        -d @"$JSON_FILE" 2>/dev/null)

    if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "201" ]; then
        echo -e "  ${GREEN}✓${NC} $WF_NAME"
        OK=$((OK + 1))
    else
        echo -e "  ${RED}✗${NC} $WF_NAME (HTTP $RESPONSE)"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo -e "${GREEN}=== Resultado ===${NC}"
echo -e "  Importados: ${GREEN}$OK${NC}"
[ "$FAIL" -gt 0 ] && echo -e "  Fallidos:   ${RED}$FAIL${NC}"
echo ""
echo "Abre $N8N_URL en el navegador para ver los workflows importados."
