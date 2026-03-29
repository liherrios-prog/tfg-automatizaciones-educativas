# n8n - Automatizaciones para Entornos Educativos

> Proyecto de fin de grado (CFGS ASIR) — Salesianos Los Boscos

Solución portátil basada en **Docker** y **n8n** que automatiza tareas repetitivas en colegios y academias: comunicaciones con familias, control de asistencia, gestión de notas, informes y más.

**La idea es simple:** solo tienes que pensar una vez. Crea la automatización y el problema queda resuelto para siempre.

---

## Características

- **Portátil** — Funciona desde un USB o cualquier equipo con Docker
- **Multiplataforma** — Scripts de arranque para Windows, Linux y macOS con instalación automática de Docker
- **Funciona sin Internet** — 6 workflows offline que almacenan datos en SQLite (los 15 restantes usan Google Sheets/SMTP)
- **Escalable** — Añade tantos workflows como necesites sin tocar la infraestructura
- **Listo para usar** — Workflows educativos preconfigurados listos para importar

---

## Workflows incluidos

El proyecto incluye **21 workflows** organizados en dos modos de funcionamiento. Consulta el [catálogo completo](workflows/CATALOGO.md) para más detalles.

### Workflows online (requieren Internet)

| # | Workflow | Categoría | Descripción |
|---|---------|-----------|-------------|
| 01 | Email masivo a padres/tutores | Comunicaciones | Envío de comunicaciones desde una hoja de cálculo |
| 02 | Recogida de Google Forms | Comunicaciones | Centraliza respuestas de formularios en Google Sheets |
| 03 | Recordatorio semanal de reuniones | Gestión académica | Resumen automático cada lunes al equipo educativo |
| 04 | Control de asistencia diario | Gestión académica | Registro vía webhook + notificación a familias por ausencia |
| 05 | Consolidar notas del trimestre | Gestión académica | Agrega calificaciones de varias hojas en un informe unificado |
| 06 | Informe mensual de asistencia | Gestión académica | Genera estadísticas de asistencia por curso cada mes |
| 07 | Backup automático de datos | Mantenimiento | Copia de seguridad diaria de todos los workflows a Google Drive |
| 08 | Recordatorio de entregas y exámenes | Comunicaciones | Avisa a los alumnos 3 días antes de exámenes y entregas |
| 09 | Gestión de inventario TIC | Gestión TIC | Registro de préstamos/devoluciones de equipos informáticos |
| 10 | Notificación de cumpleaños | Convivencia | Avisa al tutor cuando un alumno de su grupo cumple años |
| 11 | Alerta de absentismo acumulado | Alertas | Detecta alumnos con +3 ausencias y alerta al jefe de estudios |
| 12 | Boletín semanal para familias | Comunicaciones | Resumen automático con eventos y avisos cada viernes |
| 13 | Solicitud de material/recursos | Gestión de recursos | Registro vía webhook + notificación urgente al coordinador |
| 14 | Gestión de guardias/sustituciones | Gestión de personal | Asigna sustitutos automáticamente desde el cuadrante de guardias |
| 15 | Encuesta de satisfacción | Calidad | Envío mensual de encuestas a familias con registro de seguimiento |

### Workflows offline (funcionan sin Internet)

Estos workflows almacenan datos en la base de datos interna de n8n (SQLite), sin depender de Google Sheets ni servicios externos. Ideales para centros con conexión limitada o para demostrar la portabilidad total del sistema en USB.

| # | Workflow | Categoría | Descripción |
|---|---------|-----------|-------------|
| 16 | Calculadora de notas offline | Gestión académica | Calcula medias ponderadas y almacena histórico de notas |
| 17 | Registro de incidencias | Convivencia | Registra y consulta incidencias con filtros y estadísticas |
| 18 | Generador de contraseñas | Herramientas TIC | Genera usuarios y contraseñas seguras para listas de alumnos |
| 19 | Control de préstamos offline | Gestión TIC | Gestiona préstamos/devoluciones con alertas de retraso |
| 20 | Sorteo y asignación de grupos | Herramientas docentes | Reparte alumnos en grupos aleatorios equilibrados |
| 21 | Diario de actividad del centro | Administración | Libro de registro digital con búsqueda y resúmenes |

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
│   ├── CATALOGO.md                         # Catálogo organizado de todos los workflows
│   ├── 01-email-masivo-padres.json         # Online — Comunicaciones
│   ├── 02-recogida-formulario-google-forms.json
│   ├── ...                                 # (15 workflows online, ver catálogo)
│   ├── 15-encuesta-satisfaccion.json
│   ├── 16-calculadora-notas-offline.json   # Offline — Gestión académica
│   ├── 17-registro-incidencias.json        # Offline — Convivencia
│   ├── 18-generador-contrasenas.json       # Offline — Herramientas TIC
│   ├── 19-control-prestamos-offline.json   # Offline — Gestión TIC
│   ├── 20-sorteo-grupos.json               # Offline — Herramientas docentes
│   └── 21-diario-actividad.json            # Offline — Administración
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
