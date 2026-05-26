# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Proyecto

TFG de CFGS ASIR (Salesianos Los Boscos) — **n8n: Automatizaciones para Entornos Educativos**. Solución portable basada en Docker + n8n que automatiza tareas administrativas de un centro educativo. Diseñada para funcionar desde USB sin infraestructura previa.

**Stack:** Docker Compose, n8n (motor de workflows), SQLite (workflows offline), Google Sheets + SMTP (workflows online), Node.js (solo para script de presentación con pptxgenjs).

**Repo:** `https://github.com/liherrios-prog/tfg-automatizaciones-educativas.git`

## Arranque y parada

```bash
# Windows
scripts\start.bat
scripts\stop.bat

# Linux/macOS
./scripts/start.sh
./scripts/stop.sh
```

Los scripts de arranque auto-detectan Docker, lo instalan si falta, configuran `.env` desde `.env.example` y levantan el contenedor. n8n queda disponible en `http://localhost:5678`.

Para levantar manualmente: `docker compose up -d` (requiere `.env` configurado).

**Comandos Docker directos** (el contenedor se llama `n8n-educativo`):
```bash
docker compose logs -f          # Ver logs en tiempo real
docker compose restart           # Reiniciar n8n
docker exec -it n8n-educativo sh # Shell dentro del contenedor
```

## Estructura

```
workflows/          21 workflows JSON de n8n + CATALOGO.md + GUIA-DE-USO.md
Memoria/            Documentación formal (7 capítulos obligatorios del centro)
scripts/            Scripts arranque/parada multiplataforma + genera-presentacion.js
docker-compose.yml  Contenedor único n8n con volumen persistente ./n8n-data
panel.html          Panel visual HTML interactivo con sidebar de navegación por todos los workflows
.env.example        Variables: N8N_PORT (5678) y TIMEZONE (Europe/Madrid)
.planning/          Tracking del proyecto con GSD (PROJECT.md, roadmap, etc.)
```

## Workflows

**21 workflows** organizados en dos bloques:

- **01-15 (online):** Dependen de Google Sheets y/o SMTP. Triggers: webhook, cron o manual.
- **16-21 (offline):** Usan SQLite interno de n8n via `$getWorkflowStaticData('global')`. Sin dependencias externas.

**Categorías:** Comunicaciones, Gestión académica, Gestión TIC, Convivencia, Recursos, Personal, Mantenimiento, Calidad.

**Probar un workflow webhook:**
```bash
curl -X POST http://localhost:5678/webhook/ENDPOINT -H "Content-Type: application/json" -d '{"campo": "valor"}'
```

Los endpoints y payloads de cada workflow están documentados en `workflows/GUIA-DE-USO.md`.

**Para modificar workflows:** Importar el JSON en la UI de n8n, editar visualmente, exportar y sobrescribir el archivo JSON. No editar los JSON a mano salvo cambios triviales.

## MCP n8n

El repositorio incluye `.mcp.json` con el servidor MCP de n8n configurado. Permite a Claude Code listar, crear, modificar y ejecutar workflows directamente via API cuando n8n está corriendo. Las herramientas MCP disponibles empiezan con `mcp__n8n-mcp__`.

**Requisito:** n8n debe estar corriendo (`docker compose up -d`) para que el MCP funcione.

## Documentación

**Memoria** — 7 capítulos obligatorios siguiendo la plantilla del centro:
1. Estudio del problema y análisis del sistema
2. Recursos necesarios
3. Implementación y documentación técnica (el más extenso)
4. Fase de pruebas
5. Conclusiones finales
6. Documentación del sistema desarrollado
7. Bibliografía

**Archivos adicionales en `Memoria/`:**
- `DIAGRAMAS.md` — Diagramas de flujo y arquitectura
- `GUION-DEFENSA-ORAL.md` — Guion de 10 minutos para la defensa ante tribunal

**Presentación:** Generada con `node scripts/genera-presentacion.js` → produce `Memoria/PRESENTACION-DEFENSA.pptx`

**Referencia rápida de workflows:**
- `workflows/CATALOGO.md` — Tablas por categoría, endpoints, dependencias
- `workflows/GUIA-DE-USO.md` — Guía práctica con ejemplos curl para cada workflow

## Convenciones

- **Idioma:** Todo en español (documentación, commits, nombres de archivo).
- **Commits:** Formato `tipo: descripción` (ej: `feat: add 6 offline workflows`). Tipos: feat, docs, fix.
- **Nombrado workflows:** `NN-descripcion-en-espanol.json` (01-21, numeración correlativa).
- **Workflows offline** incluyen sticky notes en n8n con instrucciones de configuración.
- **No hay build, lint ni tests automatizados.** Los workflows se validan manualmente via UI de n8n o curl.
