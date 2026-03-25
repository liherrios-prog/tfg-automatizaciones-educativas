# 6. DOCUMENTACIÓN DEL SISTEMA DESARROLLADO

## 6.1 Manual de instalación

### Requisitos previos

1. **Docker Desktop** instalado en el equipo.
   - Windows: Descargar desde [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) e instalar. Requiere activar la virtualización en la BIOS (VT-x o AMD-V).
   - Linux: Instalar Docker Engine y Docker Compose siguiendo la guía oficial.
   - macOS: Descargar Docker Desktop desde la web oficial.

2. Espacio en disco mínimo de **500 MB** disponibles.

### Instalación desde GitHub

```bash
git clone https://github.com/USUARIO/REPOSITORIO.git
cd REPOSITORIO
```

### Instalación desde USB

1. Conectar el USB al equipo.
2. Abrir la carpeta del proyecto en el USB.

### Primer arranque

**Windows:**
1. Hacer doble click en `scripts\start.bat`.
2. Esperar a que Docker descargue la imagen de n8n (solo la primera vez, requiere conexión a Internet).
3. Una vez arrancado, abrir el navegador en `http://localhost:5678`.
4. En el primer acceso, n8n pedirá crear una cuenta de administrador (email y contraseña). Estos datos se guardan localmente.

**Linux / macOS:**
```bash
./scripts/start.sh
```

### Configuración personalizada

Para cambiar el puerto o la zona horaria, editar el archivo `.env`:

```
N8N_PORT=8080
TIMEZONE=Europe/London
```

Después reiniciar:
```bash
# Parar
scripts/stop.bat   (Windows) o ./scripts/stop.sh   (Linux/Mac)

# Arrancar de nuevo
scripts/start.bat  (Windows) o ./scripts/start.sh  (Linux/Mac)
```

## 6.2 Manual de uso

### Acceso a n8n

Una vez arrancado el sistema, acceder a la interfaz de n8n desde el navegador:

```
http://localhost:5678
```

Introducir el email y contraseña creados en el primer acceso.

### Interfaz principal

Al acceder a n8n se muestra el panel principal con los workflows disponibles. Desde aquí se puede:

- **Crear** un nuevo workflow pulsando el botón "Add workflow".
- **Importar** un workflow desde un archivo JSON (los workflows del proyecto están en la carpeta `workflows/`).
- **Ejecutar** un workflow manualmente pulsando "Execute Workflow".
- **Activar** un workflow para que se ejecute automáticamente según su trigger (horario, webhook, etc.).

### Importar los workflows del proyecto

1. En n8n, ir a la lista de workflows.
2. Pulsar los tres puntos o el menú de importación.
3. Seleccionar "Import from File".
4. Navegar hasta la carpeta `workflows/` del proyecto y seleccionar el archivo JSON deseado.
5. El workflow se cargará en n8n listo para ejecutar o personalizar.

### Exportar workflows

Para guardar un workflow y compartirlo:

1. Abrir el workflow en el editor de n8n.
2. Pulsar los tres puntos del menú superior.
3. Seleccionar "Download".
4. Guardar el archivo JSON en la carpeta `workflows/` del proyecto.

### Workflows disponibles

| Workflow | Categoría | Descripción | Trigger |
|----------|-----------|-------------|---------|
| Email Masivo | Comunicaciones | Lee una lista de destinatarios de una hoja de Google Sheets y envía un email personalizado a cada uno con el nombre, curso y el mensaje definido en una plantilla. | Manual (botón ejecutar) |
| Google Forms | Comunicaciones | Recibe las respuestas de un formulario de Google a través de un webhook, procesa los datos y los registra en una hoja de Google Sheets organizada por fecha y asignatura. | Webhook (se dispara automáticamente al recibir una respuesta) |
| Recordatorio Reuniones | Gestión académica | Consulta el calendario de Google del profesor cada lunes por la mañana y envía un email con el listado de reuniones programadas para esa semana. Si no hay reuniones, envía un aviso indicándolo. | Programado (cron: lunes a las 8:00) |
| Control Asistencia | Gestión académica | Recibe los datos de asistencia a través de un webhook (alumno, fecha, estado y asignatura) y los registra en una hoja de Google Sheets. Pensado para integrarse con un formulario o una aplicación que envíe los datos. | Webhook (se dispara al recibir datos de asistencia) |
| Consolidar Notas | Gestión académica | Lee las notas de los alumnos de una hoja de Google Sheets, calcula la media de cada alumno y genera una hoja resumen con las medias y un listado de alumnos con alguna asignatura suspensa. | Manual (botón ejecutar) |
| Informe Asistencia | Gestión académica | Recopila los registros de asistencia del mes anterior, calcula el porcentaje de asistencia por alumno y genera un informe resumen que se envía por email al profesor. | Programado (cron: día 1 de cada mes a las 9:00) |

### Parar el sistema

**Windows:** Hacer doble click en `scripts\stop.bat`.

**Linux / macOS:** `./scripts/stop.sh`

Los datos quedan guardados en la carpeta `n8n-data/` y estarán disponibles en el siguiente arranque.
