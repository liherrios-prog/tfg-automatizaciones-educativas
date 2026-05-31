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
git clone https://github.com/liherrios-prog/tfg-automatizaciones-educativas.git
cd tfg-automatizaciones-educativas
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

El proyecto incluye **23 workflows** organizados en tres modos de funcionamiento. Para una referencia completa con endpoints, dependencias y nodos utilizados, consultar el catálogo en `workflows/CATALOGO.md`. Para una guía práctica paso a paso con ejemplos de uso y comandos listos para copiar y pegar, consultar `workflows/GUIA-DE-USO.md`.

**Workflows online** (requieren conexión a Internet):

| Workflow | Categoría | Descripción | Trigger |
|----------|-----------|-------------|---------|
| 01 - Email Masivo | Comunicaciones | Lee una lista de destinatarios de una hoja de Google Sheets y envía un email personalizado a cada uno con el nombre, curso y el mensaje definido en una plantilla. | Manual (botón ejecutar) |
| 02 - Google Forms | Comunicaciones | Recibe las respuestas de un formulario de Google a través de un webhook, procesa los datos y los registra en una hoja de Google Sheets organizada por fecha y asignatura. | Webhook (automático al recibir respuesta) |
| 03 - Recordatorio Reuniones | Gestión académica | Consulta el calendario cada lunes por la mañana y envía un email con el listado de reuniones programadas para esa semana. | Programado (cron: lunes a las 9:00) |
| 04 - Control Asistencia | Gestión académica | Recibe los datos de asistencia a través de un webhook y los registra en Google Sheets. Si el alumno está ausente, notifica a la familia. | Webhook (al recibir datos de asistencia) |
| 05 - Consolidar Notas | Gestión académica | Lee las notas de los alumnos, calcula la media ponderada y genera una hoja resumen con calificaciones cualitativas. | Manual (botón ejecutar) |
| 06 - Informe Asistencia | Gestión académica | Recopila los registros de asistencia del mes anterior, calcula el porcentaje por alumno y genera un informe resumen. | Programado (cron: día 1 de cada mes a las 8:00) |
| 07 - Backup Automático | Mantenimiento | Exporta todos los workflows de n8n a Google Drive como copia de seguridad diaria. | Programado (cron: diario a las 2:00) |
| 08 - Recordatorio Entregas | Gestión académica | Avisa a los alumnos cuando hay exámenes o entregas en los próximos 3 días. | Programado (cron: lunes a viernes a las 8:00) |
| 09 - Inventario TIC | Gestión TIC | Registra préstamos y devoluciones de equipos informáticos vía webhook y mantiene un inventario actualizado. | Webhook (POST /inventario-tic) |
| 10 - Cumpleaños Alumnos | Convivencia | Avisa al tutor cuando un alumno de su grupo cumple años para que pueda felicitarle en clase. | Programado (cron: lunes a viernes a las 8:30) |
| 11 - Alerta Absentismo | Alertas | Detecta alumnos con más de 3 ausencias en el mes y envía un informe de alerta al jefe de estudios. | Programado (cron: viernes a las 14:00) |
| 12 - Boletín Semanal | Comunicaciones | Genera un resumen semanal con eventos y avisos del tutor y lo envía a las familias de cada curso. | Programado (cron: viernes a las 16:00) |
| 13 - Solicitud Material | Gestión de recursos | Registra solicitudes de material vía webhook. Las urgentes se notifican inmediatamente al coordinador. | Webhook (POST /solicitud-material) |
| 14 - Guardias y Sustituciones | Gestión de personal | Asigna sustitutos automáticamente consultando el cuadrante de guardias cuando un profesor comunica su ausencia. | Webhook (POST /ausencia-profesor) |
| 15 - Encuesta Satisfacción | Calidad | Envía encuestas de satisfacción mensuales a las familias y registra cada envío para seguimiento. | Programado (cron: día 1 de cada mes a las 10:00) |

**Workflows offline** (funcionan sin conexión a Internet):

Estos workflows almacenan los datos en la base de datos SQLite interna de n8n mediante `$getWorkflowStaticData('global')`. No dependen de Google Sheets, SMTP ni ningún servicio externo.

| Workflow | Categoría | Descripción | Trigger |
|----------|-----------|-------------|---------|
| 16 - Calculadora de Notas Offline | Gestión académica | Recibe notas por webhook, calcula la media ponderada (50% examen, 30% trabajo, 20% participación) y devuelve la calificación cualitativa. Almacena un histórico consultable. | Webhook (POST /calcular-notas) |
| 17 - Registro de Incidencias | Convivencia | Registra incidencias de convivencia con tipo (leve, grave, muy grave), alumno, curso y profesor. Permite consultar con filtros y generar resúmenes estadísticos. | Webhook (POST /registro-incidencias) |
| 18 - Generador de Contraseñas | Herramientas TIC | Recibe una lista de nombres de alumnos y genera un usuario y contraseña segura para cada uno. Excluye caracteres ambiguos. No almacena datos. | Webhook (POST /generar-contrasenas) |
| 19 - Control de Préstamos Offline | Gestión TIC | Gestiona préstamos y devoluciones de equipos informáticos. Detecta equipos con más de 7 días prestados y los marca con alerta. | Webhook (POST /prestamos-offline) |
| 20 - Sorteo de Grupos | Herramientas docentes | Reparte una lista de alumnos en grupos aleatorios equilibrados usando el algoritmo Fisher-Yates. No almacena datos. | Webhook (POST /sorteo-grupos) |
| 21 - Diario de Actividad | Administración | Libro de registro digital del centro con 5 tipos de entrada (evento, incidencia, logro, recordatorio, acta). Soporta búsqueda por texto y resúmenes estadísticos. | Webhook (POST /diario-actividad) |

### Parar el sistema

**Windows:** Hacer doble click en `scripts\stop.bat`.

**Linux / macOS:** `./scripts/stop.sh`

Los datos quedan guardados en la carpeta `n8n-data/` y estarán disponibles en el siguiente arranque.

## 6.3 Resolución de problemas comunes

A continuación se recogen los problemas más habituales que puede encontrar un usuario al utilizar el sistema, junto con sus causas y soluciones.

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| El script de arranque dice que Docker no está instalado | Docker Desktop no está instalado en el equipo | El propio script intenta instalarlo automáticamente. Si falla, instalar manualmente desde [docker.com](https://www.docker.com/products/docker-desktop/) |
| Docker está instalado pero el contenedor no arranca | Docker Desktop no está ejecutándose | Abrir Docker Desktop y esperar a que arranque (icono en la barra de tareas). El script espera hasta 60 segundos |
| Error "port is already allocated" | Otro programa está usando el puerto 5678 | Editar `.env` y cambiar `N8N_PORT` a otro valor (ej: 8080). Reiniciar con el script |
| n8n arranca pero los workflows online fallan | Sin conexión a Internet o credenciales no configuradas | Verificar conexión a Internet. Si no hay conexión, usar los workflows offline (16-21). Si hay conexión, revisar las credenciales en n8n > Settings > Credentials |
| "Permission denied" al ejecutar el script en Linux | El usuario no pertenece al grupo `docker` | Ejecutar `sudo usermod -aG docker $USER` y reiniciar la sesión. El script de arranque intenta hacer esto automáticamente |
| n8n no importa un archivo JSON de workflow | Archivo corrupto, formato incompatible o versión de n8n muy diferente | Descargar el JSON original del repositorio de GitHub. Verificar que la versión de n8n es reciente |
| Los datos de workflows offline desaparecen tras reiniciar | La carpeta `n8n-data/` no está montada correctamente | Verificar que el bind mount `./n8n-data:/home/node/.n8n` existe en `docker-compose.yml` y que la carpeta `n8n-data/` tiene permisos de escritura |
| El webhook devuelve "Not Found" | El workflow no está activado en n8n | Abrir el workflow en n8n y activar el interruptor "Active" en la esquina superior derecha (debe quedar en verde) |
| Error de timeout al enviar emails (SMTP) | El servidor SMTP no responde o las credenciales son incorrectas | Verificar las credenciales SMTP en n8n. Probar con un servidor alternativo (ej: Gmail con contraseña de aplicación) |

**Consejo general:** Si algo no funciona, lo primero es revisar los logs del contenedor con `docker compose logs -f`. Los mensajes de error de n8n suelen ser descriptivos y apuntan directamente al nodo o la credencial que falla.
