# n8n - Automatizaciones para Entornos Educativos

> Proyecto de fin de grado (CFGS ASIR) — Salesianos Los Boscos

Solución portátil basada en **Docker** y **n8n** que automatiza tareas repetitivas en colegios y academias: comunicaciones con familias, control de asistencia, gestión de notas, informes y más.

**La idea es simple:** solo tienes que pensar una vez. Crea la automatización y el problema queda resuelto para siempre.

---

## Características

- **Portátil** — Funciona desde un USB o cualquier equipo con Docker
- **Multiplataforma** — Scripts de arranque para Windows, Linux y macOS con instalación automática de Docker
- **Sin dependencias externas** — Todo corre dentro de un contenedor Docker con base de datos SQLite integrada
- **Escalable** — Añade tantos workflows como necesites sin tocar la infraestructura
- **Listo para usar** — Workflows educativos preconfigurados listos para importar

---

## Workflows incluidos

| # | Workflow | Descripción |
|---|---------|-------------|
| 01 | Email masivo a padres/tutores | Envío de comunicaciones desde una hoja de cálculo |
| 02 | Recogida de Google Forms | Centraliza respuestas de formularios en Google Sheets |
| 03 | Recordatorio semanal de reuniones | Resumen automático cada lunes al equipo educativo |
| 04 | Control de asistencia diario | Registro vía webhook + notificación a familias por ausencia |
| 05 | Consolidar notas del trimestre | Agrega calificaciones de varias hojas en un informe unificado |
| 06 | Informe mensual de asistencia | Genera estadísticas de asistencia por curso cada mes |
| 07 | Backup automático de datos | Copia de seguridad diaria de todos los workflows a Google Drive |
| 08 | Recordatorio de entregas y exámenes | Avisa a los alumnos 3 días antes de exámenes y entregas |
| 09 | Gestión de inventario TIC | Registro de préstamos/devoluciones de equipos informáticos |
| 10 | Notificación de cumpleaños | Avisa al tutor cuando un alumno de su grupo cumple años |
| 11 | Alerta de absentismo acumulado | Detecta alumnos con +3 ausencias y alerta al jefe de estudios |
| 12 | Boletín semanal para familias | Resumen automático con eventos y avisos cada viernes |
| 13 | Solicitud de material/recursos | Registro vía webhook + notificación urgente al coordinador |
| 14 | Gestión de guardias/sustituciones | Asigna sustitutos automáticamente desde el cuadrante de guardias |
| 15 | Encuesta de satisfacción | Envío mensual de encuestas a familias con registro de seguimiento |

Todos los workflows están en la carpeta `workflows/` como archivos JSON listos para importar en n8n.

---

## Requisitos

- **Docker** (Docker Desktop en Windows/macOS, Docker Engine en Linux)
- **Puerto 5678** disponible (configurable en `.env`)

> Si no tienes Docker instalado, los scripts de arranque lo detectan y te guían en la instalación automática.

---

## Instalación y arranque

### 1. Clona o descarga el proyecto

```bash
git clone https://github.com/liherrios/n8n-automatizaciones-educativas.git
cd n8n-automatizaciones-educativas
```

### 2. Ejecuta el script de arranque

**Windows** (doble clic o desde terminal):
```cmd
scripts\start.bat
```

**Linux / macOS**:
```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

El script automáticamente:
1. Detecta tu sistema operativo
2. Comprueba si Docker está instalado (y lo instala si no)
3. Verifica que Docker esté corriendo
4. Prepara el entorno (`.env`, directorio de datos)
5. Levanta n8n

### 3. Abre n8n en el navegador

```
http://localhost:5678
```

La primera vez, n8n te pedirá crear una cuenta de administrador.

---

## Importar los workflows

1. Abre n8n en el navegador
2. Ve a **Workflows** > **Importar desde archivo**
3. Selecciona cualquier archivo `.json` de la carpeta `workflows/`
4. Configura las credenciales necesarias (Google Sheets, SMTP, etc.) según las instrucciones del sticky note de cada workflow

---

## Parar n8n

**Windows:**
```cmd
scripts\stop.bat
```

**Linux / macOS:**
```bash
./scripts/stop.sh
```

---

## Estructura del proyecto

```
.
├── docker-compose.yml          # Definición del contenedor n8n
├── .env.example                # Variables de entorno de ejemplo
├── scripts/
│   ├── start.bat               # Arranque para Windows
│   ├── start.sh                # Arranque para Linux/macOS
│   ├── stop.bat                # Parada para Windows
│   └── stop.sh                 # Parada para Linux/macOS
├── workflows/
│   ├── 01-email-masivo-padres.json
│   ├── 02-recogida-formulario-google-forms.json
│   ├── 03-recordatorio-reuniones-semanal.json
│   ├── 04-control-asistencia.json
│   ├── 05-consolidar-notas-trimestre.json
│   ├── 06-generador-informe-asistencia.json
│   ├── 07-backup-automatico-datos.json
│   ├── 08-recordatorio-entregas-examenes.json
│   ├── 09-gestion-inventario-tic.json
│   ├── 10-notificacion-cumpleanos-alumnos.json
│   ├── 11-alerta-absentismo-acumulado.json
│   ├── 12-boletin-semanal-familias.json
│   ├── 13-solicitud-material-recursos.json
│   ├── 14-gestion-guardias-sustituciones.json
│   └── 15-encuesta-satisfaccion.json
├── n8n-data/                   # Datos persistentes (se crea automáticamente)
└── Memoria/                    # Documentación del proyecto (7 capítulos)
```

---

## Configuración

Edita el archivo `.env` (se crea automáticamente desde `.env.example`):

| Variable | Valor por defecto | Descripción |
|----------|-------------------|-------------|
| `N8N_PORT` | `5678` | Puerto en el que escucha n8n |
| `TIMEZONE` | `Europe/Madrid` | Zona horaria para los cron jobs |

---

## Tecnologías utilizadas

- [n8n](https://n8n.io/) — Plataforma de automatización de workflows
- [Docker](https://www.docker.com/) / Docker Compose — Contenerización y orquestación
- [SQLite](https://www.sqlite.org/) — Base de datos integrada para persistencia

---

## Autor

**Liher Ríos Ruiz**
CFGS Administración de Sistemas Informáticos en Red (ASIR)
Salesianos Los Boscos — Curso 2024/2025

---

## Licencia

Este proyecto se distribuye con fines educativos como parte de un Trabajo de Fin de Grado.
