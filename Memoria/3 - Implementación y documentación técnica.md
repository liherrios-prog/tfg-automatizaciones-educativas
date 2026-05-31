# 3. IMPLEMENTACIÓN DEL PROYECTO Y DOCUMENTACIÓN TÉCNICA

## 3.1 Infraestructura Docker portátil

El primer paso fue crear la base sobre la que corre todo el sistema: un archivo `docker-compose.yml` que define el contenedor de n8n con los parámetros necesarios para que sea portátil.

Hay algunas decisiones de configuración que conviene explicar.

Uso un bind mount (`./n8n-data:/home/node/.n8n`) en lugar de un volumen Docker con nombre. La diferencia práctica es importante: con bind mount los datos de n8n quedan físicamente dentro de la carpeta del proyecto, en el mismo USB. Con un volumen con nombre los datos quedarían en una ubicación gestionada por Docker que no se mueve con el USB.

La zona horaria (`Europe/Madrid`) está configurada explícitamente porque sin ella los workflows programados con cron se ejecutan en UTC, con una diferencia de 1 o 2 horas respecto a la hora local.

He desactivado los diagnósticos (`N8N_DIAGNOSTICS_ENABLED=false`) porque n8n envía telemetría por defecto. En un entorno educativo con datos de menores parece lo más prudente desactivarla.

Las dos variables añadidas para los workflows de productividad (22 y 23):
- `NODE_FUNCTION_ALLOW_EXTERNAL=xlsx` — autoriza la librería SheetJS para leer y escribir Excel
- `NODE_FUNCTION_ALLOW_BUILTIN=fs,path` — habilita los módulos de Node.js para acceder al disco

El segundo volumen (`./data:/data`) comparte la carpeta `data/` del proyecto con el interior del contenedor, para que los workflows puedan leer los archivos de entrada (Excel, logo) y escribir los archivos generados (HTML, XLSX) en una ruta accesible desde el USB.

**Archivo `docker-compose.yml`:**

```yaml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n-educativo
    restart: unless-stopped
    ports:
      - "${N8N_PORT:-5678}:5678"
    environment:
      - GENERIC_TIMEZONE=${TIMEZONE:-Europe/Madrid}
      - TZ=${TIMEZONE:-Europe/Madrid}
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_RUNNERS_ENABLED=true
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_TEMPLATES_ENABLED=true
      - NODE_FUNCTION_ALLOW_EXTERNAL=xlsx
      - NODE_FUNCTION_ALLOW_BUILTIN=fs,path
    volumes:
      - ./n8n-data:/home/node/.n8n
      - ./data:/data
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    deploy:
      resources:
        limits:
          memory: 512M
```

El health check comprueba cada 30 segundos si n8n responde en `/healthz`. Si falla 3 veces seguidas, Docker lo marca como `unhealthy`. La política `restart: unless-stopped` reinicia el contenedor automáticamente si n8n se queda colgado sin caer del todo. El límite de 512 MB evita que consuma toda la memoria disponible en equipos con poca RAM.

**Archivo `.env.example`:**

```
N8N_PORT=5678
TIMEZONE=Europe/Madrid
NODE_FUNCTION_ALLOW_EXTERNAL=xlsx
NODE_FUNCTION_ALLOW_BUILTIN=fs,path
```

## 3.2 Scripts de instalación y arranque

Para que la puesta en marcha sea realmente "en un solo click", los scripts de arranque hacen cinco cosas automáticamente: detectar el sistema operativo, comprobar si Docker está instalado (e instalarlo si no está), verificar que Docker está corriendo, crear `.env` desde `.env.example` si no existe, y levantar el contenedor con `docker compose up -d`.

| Script | Plataforma | Función |
|--------|-----------|---------|
| `scripts/start.bat` | Windows | Arranque completo con instalación automática de Docker |
| `scripts/start.sh` | Linux/macOS | Equivalente para sistemas Unix |
| `scripts/stop.bat` | Windows | Detiene el contenedor de forma limpia |
| `scripts/stop.sh` | Linux/macOS | Equivalente para sistemas Unix |

En Windows la instalación automática usa `winget` o descarga el instalador directamente. En Linux usa el script oficial de `get.docker.com`. En macOS intenta Homebrew.

## 3.3 Workflows online (01-15)

Los quince workflows online trabajan con dos servicios externos: Google Sheets como base de datos y SMTP para enviar emails. El trigger puede ser manual, un horario cron o un webhook; el resto del flujo es siempre leer o escribir en Sheets y, opcionalmente, enviar un email.

### Comunicaciones (01, 02, 08, 12)

El email masivo (01) lee un listado de familias de Google Sheets y envía un email personalizado a cada una. La personalización usa expresiones de n8n en el asunto y el cuerpo: `{{ $json.nombre_alumno }}`, `{{ $json.curso }}`. Un nodo IF filtra las filas sin email antes de intentar enviar, porque en cualquier listado real siempre hay algún hueco.

El webhook de formularios (02) recibe peticiones HTTP desde Google Forms vía Apps Script. No es específico de Google Forms: cualquier formulario que pueda enviar JSON funciona. La respuesta del webhook es síncrona, así que el remitente recibe confirmación inmediata de que sus datos han llegado.

Los workflows 08 y 12 siguen el mismo esquema (cron, lectura de hoja, envío). En el 08 la ventana de aviso son 3 días. El asunto del email incluye una etiqueta de urgencia ("HOY:", "MAÑANA:", "En X días:") para distinguir los recordatorios sin abrirlos.

### Gestión académica (03, 04, 05, 06, 11)

El más interesante técnicamente es el 05 (Consolidar Notas). Lee dos hojas en paralelo con dos nodos Google Sheets conectados al mismo trigger, luego las combina con un nodo Merge por nombre de alumno. El nodo Code calcula la media ponderada y convierte el resultado a la escala cualitativa española en el mismo bloque de JavaScript.

El workflow 04 (Control de Asistencia) usa el modo `lastNode` en el webhook. La respuesta HTTP la genera el último nodo del workflow, una vez que el registro ya está guardado en Sheets y (si el alumno está ausente) el email a la familia ya está enviado. Así el sistema externo recibe confirmación real de que todo el proceso se completó.

Los workflows 03, 06 y 11 comparten la misma hoja de asistencia del 04 como fuente de datos, lo que demuestra que los workflows pueden reutilizar datos sin acoplarse entre sí.

### Resto de workflows online (07, 09, 10, 13, 14, 15)

El 07 (Backup) llama a la API REST interna de n8n para exportar todos los workflows en JSON y subirlos a Google Drive. El 14 (Guardias) es el más complejo del bloque: cruza el día de la semana y la franja horaria con un cuadrante de guardias, busca un sustituto disponible y da respuestas distintas según encuentre uno o no.

Los workflows 09, 10, 13 y 15 son estructuralmente similares a los de comunicaciones. Sus descripciones completas, con el flujo de nodos y los campos, están en el Anexo A.

## 3.4 Workflows offline (16-21)

Con 15 workflows hechos, todos dependían de Google Sheets o SMTP. Me di cuenta de que "portátil en USB" y "requiere Internet" no encajaban bien. La solución fue `$getWorkflowStaticData('global')`: una función nativa de n8n que almacena datos en la base de datos SQLite interna del contenedor. No requiere configuración adicional, los datos persisten entre reinicios y viajan dentro del USB junto con todo lo demás.

Con esta técnica construí 6 workflows que funcionan al 100% sin conexión:

| Workflow | Función | Persiste datos |
|----------|---------|---------------|
| 16 - Calculadora de Notas | Calcula medias ponderadas, guarda histórico consultable | Sí |
| 17 - Registro de Incidencias | CRUD de incidencias con estadísticas por tipo y curso | Sí |
| 18 - Generador de Contraseñas | Genera usuarios y contraseñas para listas de alumnos | No (por seguridad) |
| 19 - Control de Préstamos | Préstamos y devoluciones de equipos, alerta si superan 7 días | Sí |
| 20 - Sorteo de Grupos | Distribuye alumnos en grupos aleatorios con Fisher-Yates | No |
| 21 - Diario de Actividad | Registro general del centro con búsqueda por texto | Sí |

Los workflows 18 y 20 no almacenan datos de forma deliberada: las contraseñas no deberían quedar guardadas en ningún sitio, y los grupos del sorteo son efímeros por naturaleza. Para los cuatro que sí persisten datos, la atomicidad de SQLite evita corrupciones incluso si n8n se interrumpe a mitad de una escritura.

Las descripciones técnicas completas de cada uno, con el flujo de nodos y la documentación de la API, están en el Anexo A.

## 3.5 Workflows de productividad (22-23)

Estos dos workflows se añadieron después de los 21 originales y son los más distintos del resto: producen archivos físicos en disco en lugar de solo respuestas JSON. Esto requirió las variables `NODE_FUNCTION_ALLOW_EXTERNAL` y `NODE_FUNCTION_ALLOW_BUILTIN` en el contenedor, y el volumen `./data:/data` para compartir archivos entre el host y el interior del contenedor.

### 22 - Convertidor Excel Masivo

Convierte lotes de archivos en formatos heredados (`.xls`, `.xlsm`, `.xlsb`, `.csv`) al formato moderno `.xlsx`. El caso de uso es real: muchos centros tienen archivos de hace años que las herramientas actuales no abren correctamente.

El workflow tiene dos nodos Code. El primero lee el directorio de entrada, convierte cada archivo con SheetJS y anota el resultado (estado, hojas, tiempo transcurrido). Si un archivo falla por estar protegido con contraseña o por corrupción, lo registra con `estado: error` y sigue con el siguiente; no aborta el proceso completo. El segundo nodo genera un `REPORTE_YYYY-MM-DD.csv` con el resultado de cada conversión, para identificar los archivos problemáticos sin revisarlos uno por uno.

### 23 - Generador de Diplomas de Graduación

Es el workflow más visual del proyecto. A partir de un Excel con los datos de los alumnos de la promoción, genera un diploma HTML personalizado para cada uno con el logotipo del centro y los colores corporativos de Salesianos Los Boscos.

El flujo tiene seis pasos:

1. Un nodo Set define los parámetros del diploma (nombre del centro, ciudad, fecha). Al estar separado del código, el usuario solo edita este nodo para adaptar los diplomas a cualquier promoción.
2. El nodo Code central lee el Excel con SheetJS y el logo con `fs.readFileSync`. El logo se convierte a Base64 y queda embebido en el HTML como `data:image/png;base64,...`. Cada diploma es un archivo autocontenido: funciona sin conexión y se puede enviar por email o copiar a otro equipo sin depender de ninguna ruta externa.
3. El HTML aplica el tema visual de Salesianos Los Boscos: borde y títulos en rojo institucional (`#CC1C1C`), subtítulos en gris (`#5C6770`), tipografía Georgia y fondo crema. El logo aparece centrado entre las firmas del tutor y de dirección, encima de la fecha.
4. Se generan dos salidas: diplomas individuales (uno por alumno en `data/diplomas/output/YYYY/`) y un archivo `TODOS.html` con todos juntos separados por saltos de página, para imprimir la promoción completa de una vez.
5. Un nodo IF filtra los alumnos con email y los pasa al nodo de envío.
6. El nodo de envío adjunta el diploma como HTML al email de destino.

El formato HTML en lugar de PDF es una limitación de n8n, que no incluye motor de renderizado de PDF. Abriendo `TODOS.html` en Chrome con `Ctrl+P` → Guardar como PDF en orientación horizontal A4, el resultado es equivalente a un PDF generado directamente.

## 3.6 Documentación técnica

### 3.6.1 Estructura del proyecto

```
proyecto/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── scripts/
│   ├── start.bat / start.sh
│   └── stop.bat / stop.sh
├── workflows/
│   ├── CATALOGO.md             # Catálogo completo de los 23 workflows
│   ├── GUIA-DE-USO.md          # Guía práctica con ejemplos curl
│   ├── 01 a 15 (*.json)        # Workflows online
│   ├── 16 a 21 (*.json)        # Workflows offline
│   └── 22 a 23 (*.json)        # Herramientas de productividad
├── data/
│   ├── conversion/             # WF 22: input/ (archivos) y output/ (xlsx)
│   └── diplomas/               # WF 23: alumnos.xlsx, logo.png, output/
├── n8n-data/                   # Datos persistentes de n8n (no se sube a GitHub)
│   └── database.sqlite
└── Memoria/
    └── (capítulos .md + ANEXOS.md)
```

### 3.6.2 Ficheros de configuración

`docker-compose.yml` define el servicio n8n con la imagen oficial. El contenedor se reinicia automáticamente salvo que se detenga con `stop.bat` o `stop.sh`.

`.env` contiene las variables de entorno y no se sube al repositorio (está en `.gitignore`). Se genera automáticamente desde `.env.example` en el primer arranque.

`.gitignore` excluye `n8n-data/` (base de datos con datos del usuario), `.env` (puede contener credenciales) y el contenido de `data/output/` (archivos generados por los workflows).

### 3.6.3 Características técnicas

| Característica | Detalle |
|---------------|---------|
| Imagen Docker | `docker.n8n.io/n8nio/n8n` (última versión estable) |
| Base de datos | SQLite (`n8n-data/database.sqlite`) |
| Puerto por defecto | 5678 (configurable en `.env`) |
| Persistencia | Bind mount `./n8n-data` + bind mount `./data` |
| Zona horaria | Europe/Madrid (configurable en `.env`) |
| Plataformas soportadas | Windows 10/11, Linux, macOS |
| Requisito previo | Docker (los scripts lo instalan automáticamente si no está) |

### 3.6.4 Resumen de los 23 workflows

**Workflows online** (01-15, requieren conexión a Internet):

| # | Workflow | Categoría | Trigger | Dependencias |
|---|---------|-----------|---------|-------------|
| 01 | Email Masivo a Padres/Tutores | Comunicaciones | Manual | Google Sheets, SMTP |
| 02 | Recogida de Google Forms | Comunicaciones | Webhook | Google Sheets, SMTP |
| 03 | Recordatorio Semanal de Reuniones | Gestión académica | Programado (L 9:00) | Google Sheets, SMTP |
| 04 | Control de Asistencia Diario | Gestión académica | Webhook | Google Sheets, SMTP |
| 05 | Consolidar Notas del Trimestre | Gestión académica | Manual | Google Sheets, SMTP |
| 06 | Informe Mensual de Asistencia | Gestión académica | Programado (1/mes 8:00) | Google Sheets, SMTP |
| 07 | Backup Automático | Mantenimiento | Programado (diario 2:00) | API n8n, Google Drive |
| 08 | Recordatorio de Entregas y Exámenes | Comunicaciones | Programado (L-V 8:00) | Google Sheets, SMTP |
| 09 | Inventario TIC | Gestión TIC | Webhook | Google Sheets |
| 10 | Cumpleaños de Alumnos | Convivencia | Programado (L-V 8:30) | Google Sheets, SMTP |
| 11 | Alerta de Absentismo | Alertas | Programado (V 14:00) | Google Sheets, SMTP |
| 12 | Boletín Semanal para Familias | Comunicaciones | Programado (V 16:00) | Google Sheets, SMTP |
| 13 | Solicitud de Material | Gestión de recursos | Webhook | Google Sheets, SMTP |
| 14 | Guardias y Sustituciones | Gestión de personal | Webhook | Google Sheets, SMTP |
| 15 | Encuesta de Satisfacción | Calidad | Programado (1/mes 10:00) | Google Sheets, SMTP |

**Workflows offline** (16-21, sin Internet):

| # | Workflow | Categoría | Trigger | Almacenamiento |
|---|---------|-----------|---------|---------------|
| 16 | Calculadora de Notas | Gestión académica | Webhook | SQLite (staticData) |
| 17 | Registro de Incidencias | Convivencia | Webhook | SQLite (staticData) |
| 18 | Generador de Contraseñas | Herramientas TIC | Webhook | Sin estado |
| 19 | Control de Préstamos | Gestión TIC | Webhook | SQLite (staticData) |
| 20 | Sorteo de Grupos | Herramientas docentes | Webhook | Sin estado |
| 21 | Diario de Actividad | Administración | Webhook | SQLite (staticData) |

**Herramientas de productividad** (22-23, generan archivos):

| # | Workflow | Trigger | Salida |
|---|---------|---------|--------|
| 22 | Convertidor Excel Masivo | Manual | Archivos .xlsx + CSV de reporte |
| 23 | Generador de Diplomas | Manual | Archivos .html por alumno + TODOS.html |

## 3.7 Consideraciones de seguridad y protección de datos

### 3.7.1 Marco legal

El sistema maneja datos personales de alumnos en un entorno educativo, lo que lo sitúa bajo la normativa de protección de datos:

- **RGPD** — Reglamento (UE) 2016/679. Establece los principios de licitud, minimización de datos, limitación de la finalidad, integridad y confidencialidad.
- **LOPD-GDD** — Ley Orgánica 3/2018. Adapta el RGPD al ordenamiento español con disposiciones específicas para el ámbito educativo. Los datos de menores de 14 años tienen protección reforzada.

### 3.7.2 Datos personales tratados

| Nivel | Datos | Workflows que los tratan |
|-------|-------|--------------------------|
| Alto | Notas y calificaciones | 05, 16 |
| Alto | Incidencias de convivencia | 17 |
| Alto | Registro de asistencia y absentismo | 04, 06, 11 |
| Medio | Nombres y apellidos de alumnos | 01-23 |
| Medio | Emails de familias y tutores | 01, 08, 12, 15, 23 |
| Medio | Datos de profesores (nombres, horarios) | 03, 14 |
| Bajo | Inventario de equipos informáticos | 09, 19 |
| Bajo | Entradas del diario de actividad | 21 |

### 3.7.3 Medidas técnicas implementadas

**Almacenamiento local.** Los workflows offline (16-21) guardan todos sus datos en SQLite, dentro del USB o equipo del usuario. Nada se transmite a servidores externos. Esta es una ventaja concreta frente a Zapier o Make, donde los datos del centro viajarían a servidores de terceros fuera de la UE.

**Credenciales cifradas.** n8n cifra las credenciales de Google Sheets y SMTP en su base de datos. No aparecen en los archivos JSON exportados de los workflows.

**Datos sensibles fuera del repositorio.** El `.gitignore` excluye `n8n-data/` y `.env`. Al compartir el proyecto vía GitHub o USB no se filtran datos personales ni credenciales.

**Webhooks en localhost.** Por defecto n8n solo escucha en `localhost:5678`, accesible únicamente desde el propio equipo.

**Diagnósticos desactivados.** `N8N_DIAGNOSTICS_ENABLED=false` evita el envío de telemetría.

**Contraseñas no persistidas.** El workflow 18 genera credenciales pero no las almacena. Se entregan en la respuesta y desaparecen.

### 3.7.4 Recomendaciones para uso en producción

Si un centro usara este sistema con datos reales de forma permanente, hay cinco medidas adicionales recomendables:

1. Activar la autenticación de n8n con `N8N_BASIC_AUTH_ACTIVE=true`.
2. Usar un proxy inverso (Nginx) con HTTPS si n8n se expone en red local.
3. Cifrar los backups antes de subirlos a Google Drive.
4. Elaborar un registro de actividades de tratamiento, obligatorio por el RGPD.
5. Implementar purgado periódico de datos en `staticData` para respetar el principio de limitación del plazo de conservación.
