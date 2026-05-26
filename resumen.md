# Resumen técnico del PFC — n8n Automatizaciones Educativas

**Alumno:** Liher Ríos (CFGS ASIR, Salesianos Los Boscos)
**Repo:** https://github.com/liherrios-prog/tfg-automatizaciones-educativas.git

---

## Qué es esto

Plataforma de automatización de tareas administrativas para centros educativos. Motor: **n8n** (workflow automation, self-hosted). Diseño portable: corre desde un USB sin infraestructura previa. Un solo contenedor Docker, sin dependencias de red obligatorias para el bloque offline.

---

## Stack

| Capa                 | Tecnología                                                   |
| -------------------- | ------------------------------------------------------------ |
| Contenedor           | Docker Compose (1 servicio: `n8n-educativo`)                 |
| Motor de workflows   | n8n (imagen oficial)                                         |
| Persistencia offline | SQLite interno de n8n vía `$getWorkflowStaticData('global')` |
| Persistencia online  | Google Sheets (API)                                          |
| Notificaciones       | SMTP (email)                                                 |
| Backup nube          | Google Drive                                                 |
| Presentación PPTX    | Node.js + pptxgenjs                                          |
| Panel visual         | HTML estático (`panel.html`)                                 |

**Volumen persistente:** `./n8n-data` montado en el contenedor. Aquí vive la SQLite con datos de workflows offline.

---

## Arranque

```bash
# Windows
scripts\start.bat

# Linux/macOS
./scripts/start.sh
```

Los scripts auto-detectan Docker, lo instalan si falta, generan `.env` desde `.env.example` y hacen `docker compose up -d`. n8n disponible en `http://localhost:5678`.

**Variables de entorno (.env):**
- `N8N_PORT=5678`
- `TIMEZONE=Europe/Madrid`

**Contenedor:** `n8n-educativo`

---

## Los 21 workflows

### Bloque OFFLINE (16-21) — sin Internet

Usan `$getWorkflowStaticData('global')` para persistir en SQLite. Portables al 100%.

| # | Nombre | Endpoint | Función |
|---|--------|----------|---------|
| 16 | Calculadora de Notas | POST /calcular-notas | Media ponderada (examen+trabajo+participacion) + histórico SQLite |
| 17 | Registro de Incidencias | POST /registro-incidencias | CRUD incidencias + estadísticas |
| 18 | Generador de Contraseñas | POST /generar-contrasenas | Usuarios/passwords para listas de alumnos |
| 19 | Control de Préstamos | POST /prestamos-offline | Préstamo/devolución equipos + alertas retraso |
| 20 | Sorteo de Grupos | POST /sorteo-grupos | Fisher-Yates para grupos equilibrados |
| 21 | Diario de Actividad | POST /diario-actividad | Libro de registro digital del centro |

### Bloque ONLINE (01-15) — requieren Google + SMTP

| # | Nombre | Trigger | Dependencias |
|---|--------|---------|-------------|
| 01 | Email Masivo a Padres | Manual | Google Sheets + SMTP |
| 02 | Recogida Google Forms | Webhook | Google Sheets + SMTP |
| 03 | Recordatorio Reuniones | Cron (L 9:00) | Google Sheets + SMTP |
| 04 | Control Asistencia | Webhook | Google Sheets + SMTP |
| 05 | Consolidar Notas | Manual | Google Sheets + SMTP |
| 06 | Informe Asistencia | Cron (1/mes 8:00) | Google Sheets + SMTP |
| 07 | Backup Automático | Cron (diario 2:00) | Google Drive + API n8n local |
| 08 | Recordatorio Entregas | Cron (L-V 8:00) | Google Sheets + SMTP |
| 09 | Inventario TIC | Webhook | Google Sheets |
| 10 | Cumpleaños Alumnos | Cron (L-V 8:30) | Google Sheets + SMTP |
| 11 | Alerta Absentismo | Cron (V 14:00) | Google Sheets + SMTP |
| 12 | Boletín Semanal | Cron (V 16:00) | Google Sheets + SMTP |
| 13 | Solicitud Material | Webhook | Google Sheets + SMTP |
| 14 | Guardias/Sustituciones | Webhook | Google Sheets + SMTP |
| 15 | Encuesta Satisfacción | Cron (1/mes 10:00) | Google Sheets + SMTP |

---

## Estructura de archivos clave

```
workflows/         JSONs importables en n8n (no editar a mano)
  CATALOGO.md      Referencia rápida de todos los workflows
  GUIA-DE-USO.md   Ejemplos curl por workflow
Memoria/           7 capítulos obligatorios del centro
  DIAGRAMAS.md     Arquitectura y flujos
  GUION-DEFENSA-ORAL.md  Guion 10 min para tribunal
scripts/
  start.bat / start.sh   Arranque automático
  stop.bat / stop.sh     Parada
  genera-presentacion.js → Memoria/PRESENTACION-DEFENSA.pptx
panel.html         Panel HTML con sidebar navegable (todos los workflows)
docker-compose.yml Un servicio, volumen ./n8n-data
.env               Configuración local (no en git)
.mcp.json          MCP de n8n configurado para Claude Code
```

---

## Operación habitual

**Probar webhook:**
```bash
curl -X POST http://localhost:5678/webhook/ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{"campo": "valor"}'
```

**Modificar un workflow:** importar JSON en UI n8n → editar → exportar → sobreescribir archivo. No editar JSON a mano salvo cambios triviales.

**Ver logs:** `docker compose logs -f`

**Shell en contenedor:** `docker exec -it n8n-educativo sh`

**MCP activo:** cuando n8n está corriendo, Claude Code puede listar, crear, modificar y ejecutar workflows vía `mcp__n8n-mcp__*` tools.

---

## Convenciones

- Todo en español (docs, commits, nombres de archivo)
- Commits: `tipo: descripción` (feat / docs / fix)
- Workflows: `NN-descripcion-en-espanol.json` (01-21)
- Sin build, lint ni tests automatizados — validación manual vía UI o curl
- Workflows offline llevan sticky notes con instrucciones de configuración
