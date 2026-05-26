# 3. IMPLEMENTACIÓN DEL PROYECTO Y DOCUMENTACIÓN TÉCNICA

## 3.1 Ejecución del proyecto

El desarrollo del proyecto se ha llevado a cabo siguiendo las fases definidas en la planificación temporal. A continuación se detalla el trabajo realizado en cada una.

### 3.1.1 Fase 1: Infraestructura Docker portátil

El primer paso fue crear la infraestructura que sirve de base para todo el proyecto. Se configuró un archivo `docker-compose.yml` que define un servicio con la imagen oficial de n8n.

**Decisiones de diseño:**

- Se utiliza un **bind mount** (`./n8n-data:/home/node/.n8n`) en lugar de un volumen Docker con nombre. Esto permite que los datos de n8n (workflows, credenciales, base de datos SQLite) residan físicamente dentro de la carpeta del proyecto, haciendo posible la portabilidad en USB.
- Se configura la **zona horaria** a `Europe/Madrid` mediante variables de entorno, para que los workflows programados se ejecuten en el horario correcto.
- Se desactivan los **diagnósticos** (`N8N_DIAGNOSTICS_ENABLED=false`) para respetar la privacidad del entorno educativo.
- Se habilitan los **task runners** (`N8N_RUNNERS_ENABLED=true`), funcionalidad actual de n8n para la ejecución de tareas.
- Se activan las **plantillas de n8n** (`N8N_TEMPLATES_ENABLED=true`) para que el usuario pueda explorar automatizaciones de ejemplo desde la interfaz.

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
    volumes:
      - ./n8n-data:/home/node/.n8n
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

Se ha añadido un **health check** que comprueba cada 30 segundos si n8n responde correctamente en su endpoint de salud (`/healthz`). Si n8n no responde en 3 intentos consecutivos, Docker lo marca como unhealthy y puede reiniciarlo automáticamente gracias a la política `restart: unless-stopped`. Esto es especialmente útil para detectar situaciones en las que n8n se queda colgado sin caer del todo.

También se establecen **límites de memoria** (512 MB) mediante la sección `deploy.resources.limits`. Esto evita que n8n consuma toda la memoria del equipo en caso de un pico de carga o un leak de memoria, lo cual es una buena práctica de producción en entornos con recursos compartidos.

**Archivo `.env.example`:**

Se proporciona un archivo de ejemplo con las variables de entorno configurables. El usuario copia este archivo como `.env` para personalizar su instalación:

```
N8N_PORT=5678
TIMEZONE=Europe/Madrid
```

### 3.1.2 Fase 2: Scripts de instalación y arranque

Para cumplir con el objetivo de que la puesta en marcha sea "en un solo click", se crearon scripts de arranque y parada para Windows y Linux:

| Script | Plataforma | Función |
|--------|-----------|---------|
| `scripts/start.bat` | Windows | Arranque completo con instalación automática de Docker |
| `scripts/start.sh` | Linux/macOS | Equivalente para sistemas Unix |
| `scripts/stop.bat` | Windows | Detiene el contenedor de forma limpia |
| `scripts/stop.sh` | Linux/macOS | Equivalente para sistemas Unix |

Los scripts de arranque son multiplataforma y realizan las siguientes comprobaciones automáticas en 5 pasos:

1. **Detectar sistema operativo**: Identifica si es Windows (versión), Linux (distribución) o macOS (versión y arquitectura ARM/Intel).
2. **Verificar Docker**: Comprueba si Docker está instalado. Si no lo está, intenta instalarlo automáticamente: en Windows mediante `winget` o descarga directa de Docker Desktop, en Linux mediante el script oficial de Docker (`get.docker.com`), y en macOS mediante Homebrew.
3. **Verificar que Docker está corriendo**: Si Docker está instalado pero no arrancado, intenta iniciarlo y espera hasta 60 segundos a que esté operativo.
4. **Preparar el entorno**: Crea el archivo `.env` desde `.env.example` si no existe, y la carpeta `n8n-data/` para la persistencia.
5. **Levantar n8n**: Ejecuta `docker compose up -d` y muestra la URL de acceso.

Esta automatización del proceso de instalación convierte el proyecto en una solución verdaderamente portátil: el usuario no necesita conocimientos técnicos previos sobre Docker para poner en marcha el sistema.

### 3.1.3 Fase 3: Workflows de comunicaciones educativas

En esta fase he creado los dos primeros workflows del proyecto, centrados en la comunicación entre el centro educativo y las familias. He decidido empezar por aquí porque la comunicación con familias es una de las tareas que más tiempo consume a los profesores y donde la automatización aporta un beneficio inmediato.

#### 01 - Email Masivo a Padres/Tutores

**Categoría:** Comunicaciones | **Tag:** Familias

Este workflow resuelve un problema muy concreto: cuando un tutor necesita enviar un comunicado a todas las familias de su grupo, normalmente tiene que ir email por email o usar herramientas externas. Con este workflow, basta con tener una hoja de cálculo actualizada y pulsar un botón.

**Flujo de ejecución:**

1. **Manual Trigger**: He elegido un trigger manual porque el envío de emails masivos no debe ser automático. El profesor decide cuándo lanzarlo, lo que evita envíos accidentales. En n8n esto se traduce en un botón "Execute Workflow" en la interfaz.

2. **Google Sheets (Leer alumnos)**: Lee la hoja de cálculo donde están los datos de los alumnos. Las columnas que necesita son `nombre_alumno`, `email_padre` y `curso`. He utilizado el nodo Google Sheets con la operación "Read Rows" apuntando a la hoja correspondiente.

3. **IF (Filtrar emails vacíos)**: Antes de intentar enviar nada, un nodo IF comprueba que el campo `email_padre` no esté vacío. La condición es `{{$json.email_padre}} is not empty`. Esto es importante porque en cualquier listado real siempre hay algún registro sin email, y sin este filtro el workflow fallaría al intentar enviar a una dirección vacía.

4. **Set (Preparar mensaje)**: Un nodo Set construye el mensaje personalizado usando expresiones de n8n. El asunto incluye el curso (`Comunicado - {{ $json.curso }}`) y el cuerpo saluda al padre/tutor por el nombre del alumno. He preferido usar un nodo Set en lugar de escribir el mensaje directamente en el nodo de email porque así es más fácil modificar la plantilla sin tocar la configuración SMTP.

5. **Send Email (SMTP)**: Envía el email utilizando las credenciales SMTP configuradas en n8n. El campo "To" se rellena con `{{ $json.email_padre }}` y el cuerpo con el mensaje preparado en el paso anterior.

**Decisión de diseño**: Se usa SMTP en lugar de un servicio como SendGrid o Mailgun porque la mayoría de centros educativos ya tienen un servidor de correo institucional, y no quería añadir dependencias externas que complicasen la puesta en marcha.

#### 02 - Recogida Automática de Google Forms

**Categoría:** Comunicaciones / Gestión

Este workflow automatiza la recogida de respuestas de formularios. El caso de uso típico es un formulario donde las familias pueden enviar consultas, justificaciones de faltas o solicitudes al centro. En lugar de que el profesor tenga que revisar el formulario periódicamente, el workflow recoge cada respuesta en tiempo real, la archiva y avisa al profesor.

**Flujo de ejecución:**

1. **Webhook (POST /formulario-educativo)**: El workflow se activa cuando recibe una petición POST en la ruta `/formulario-educativo`. He elegido un webhook en lugar de un trigger de Google Forms nativo porque el webhook es más universal: funciona con cualquier formulario que pueda enviar datos por HTTP, no solo con Google Forms. Además, Google Forms permite configurar un script de Apps Script que envíe los datos al webhook cuando se registra una respuesta.

2. **Set (Extraer y preparar datos)**: Extrae los campos relevantes del cuerpo de la petición (`nombre`, `email`, `mensaje`) y añade automáticamente la fecha y hora actual usando la expresión `{{ $now.format('dd/MM/yyyy HH:mm') }}`. Este nodo también sirve para "limpiar" los datos y asegurarse de que solo se guardan los campos necesarios.

3. **Google Sheets (Guardar respuesta)**: Añade una nueva fila en la hoja de cálculo de respuestas con la operación "Append Row". Las columnas son: fecha, nombre, email y mensaje. De esta forma queda un registro histórico de todas las comunicaciones recibidas.

4. **Send Email (Notificar al profesor)**: Envía un email al profesor avisándole de que ha llegado una nueva respuesta. El asunto indica el nombre del remitente y el cuerpo incluye el mensaje completo. Así el profesor no necesita abrir la hoja de cálculo para ver qué ha llegado.

**Decisión de diseño**: El webhook es síncrono, es decir, devuelve una respuesta al formulario confirmando que los datos se han recibido. Esto es útil para que el remitente sepa que su mensaje ha llegado correctamente.

### 3.1.4 Fase 4: Workflows de gestión académica

Esta fase es la más extensa del proyecto. Contiene cuatro workflows que cubren las tareas de gestión que un centro educativo repite constantemente: reuniones, asistencia, notas e informes. He intentado que cada workflow sea autónomo, es decir, que funcione por sí solo sin depender de los demás, aunque algunos comparten hojas de cálculo como fuente de datos.

#### 03 - Recordatorio Semanal de Reuniones

**Categoría:** Gestión académica

Los profesores tienen reuniones de departamento, tutorías, claustros y evaluaciones repartidos por el calendario. Es habitual que se olvide alguna, sobre todo cuando caen en semanas con mucha carga de trabajo. Este workflow envía cada lunes un resumen con las reuniones de esa semana.

**Flujo de ejecución:**

1. **Schedule Trigger (lunes a las 9:00)**: Se ejecuta automáticamente todos los lunes a las 9 de la mañana. La expresión cron es `0 9 * * 1`. He elegido el lunes porque es cuando tiene sentido planificar la semana, y las 9:00 porque a esa hora los profesores suelen estar ya en el centro y revisan el correo antes de empezar las clases.

2. **Google Sheets (Leer calendario)**: Lee la hoja de cálculo que actúa como calendario de reuniones. Las columnas típicas son: fecha, hora, tipo de reunión, lugar y asistentes. He usado Google Sheets como calendario en lugar de Google Calendar porque muchos centros gestionan sus reuniones en hojas compartidas, no en calendarios individuales.

3. **Code (Filtrar semana actual)**: Un nodo Code en JavaScript filtra las reuniones cuya fecha cae entre el lunes y el viernes de la semana en curso. El código calcula las fechas de inicio y fin de la semana usando `new Date()` y compara cada registro. He optado por un nodo Code en lugar de un nodo IF porque la lógica de comparar rangos de fechas es más limpia en código que encadenando múltiples condiciones.

4. **IF (¿Hay reuniones?)**: Comprueba si el resultado del filtro tiene algún elemento. Si no hay reuniones esta semana, el workflow se detiene sin enviar nada. Esto evita que el profesor reciba un email vacío diciendo "No hay reuniones", que acabaría ignorando.

5. **Send Email (Resumen semanal)**: Si hay reuniones, envía un email con el listado formateado: fecha, hora, tipo y lugar de cada reunión. El asunto del email incluye el rango de fechas de la semana para que sea fácil de localizar en la bandeja de entrada.

#### 04 - Control de Asistencia Diario

**Categoría:** Gestión académica

El control de asistencia es probablemente la tarea administrativa más repetitiva en un centro educativo. Este workflow permite registrar la asistencia mediante una petición HTTP (que podría venir de una aplicación web, un formulario o incluso un lector de tarjetas) y notifica automáticamente a la familia si el alumno está ausente.

**Flujo de ejecución:**

1. **Webhook (POST /asistencia)**: Recibe los datos de asistencia por HTTP. Los campos esperados son: `alumno`, `curso`, `presente` (booleano), y opcionalmente `motivo`. He configurado el webhook con el modo `lastNode`, lo que significa que la respuesta HTTP la genera el último nodo del workflow, no el propio webhook. Esto permite confirmar al sistema remitente que el registro se ha procesado correctamente.

2. **Set (Preparar registro)**: Prepara el registro añadiendo la fecha con `{{ $now.format('dd/MM/yyyy') }}` y la hora con `{{ $now.format('HH:mm') }}`. También normaliza los datos recibidos para que la estructura sea siempre la misma independientemente de cómo lleguen.

3. **Google Sheets (Guardar registro)**: Guarda el registro de asistencia en la hoja correspondiente con la operación "Append Row". Las columnas son: alumno, curso, presente, motivo, fecha y hora.

4. **IF (¿Ausente?)**: Comprueba si el campo `presente` es `false`. Si el alumno está presente, el workflow salta directamente a la respuesta. Si está ausente, se ejecuta la notificación.

5. **Send Email (Notificar familia)**: Solo se ejecuta si el alumno está ausente. Envía un email a la familia informando de la ausencia, incluyendo el motivo si se ha proporcionado. El tono del mensaje es informativo, no alarmista.

6. **Respond to Webhook**: Genera la respuesta JSON para confirmar que el registro se ha procesado. Devuelve `{ "status": "ok", "alumno": "...", "registrado": true }`. Este nodo es el que determina la respuesta HTTP gracias al modo `lastNode` configurado en el webhook.

**Decisión de diseño**: He separado la notificación a familias del registro de asistencia usando el nodo IF. De esta forma, el registro se guarda siempre (tanto si el alumno está presente como ausente), pero solo se envía email cuando hay una ausencia. Esto reduce la cantidad de correos que reciben las familias y evita que ignoren los mensajes importantes.

#### 05 - Consolidar Notas del Trimestre

**Categoría:** Gestión académica

Al final de cada trimestre, el tutor necesita calcular la nota media de cada alumno combinando diferentes componentes de evaluación. Este workflow lee las notas de distintas fuentes, las combina y genera un resumen con la calificación final según la escala española.

**Flujo de ejecución:**

1. **Manual Trigger**: El cálculo de notas trimestrales se lanza manualmente porque es un proceso que el profesor quiere controlar. No tendría sentido que se ejecutara automáticamente un día cualquiera.

2. **Google Sheets x2 (Leer notas en paralelo)**: Dos nodos Google Sheets leen en paralelo las hojas de notas. Una hoja contiene las notas de exámenes y otra las de trabajos y participación. He decidido leerlas en paralelo (no secuencialmente) para que el workflow sea más rápido. n8n permite esto conectando ambos nodos al mismo trigger.

3. **Merge (Combinar por alumno)**: Un nodo Merge con modo "Combine" junta los datos de ambas hojas usando el nombre del alumno como clave. Esto genera un único registro por alumno con todas sus notas. He elegido el modo Combine en lugar de Append porque necesito que las notas de cada alumno queden en la misma fila, no en filas separadas.

4. **Code (Calcular media ponderada)**: Un nodo Code en JavaScript calcula la nota final de cada alumno aplicando la ponderación definida por el departamento: examen 50%, trabajo 30% y participación 20%. La fórmula es:

   `media = (examen * 0.5) + (trabajo * 0.3) + (participacion * 0.2)`

   Además, el código convierte la nota numérica a la escala cualitativa española:
   - 0 a 4.99: Insuficiente
   - 5 a 5.99: Suficiente
   - 6 a 6.99: Bien
   - 7 a 8.99: Notable
   - 9 a 10: Sobresaliente

   He puesto esta lógica en un nodo Code porque no existe un nodo nativo de n8n que haga cálculos ponderados con conversión a escala. Intentar hacerlo con nodos Set y expresiones sería posible pero mucho menos legible.

5. **Google Sheets (Guardar resumen)**: Escribe los resultados en una hoja de resumen con las columnas: alumno, nota examen, nota trabajo, nota participación, media numérica y calificación cualitativa.

6. **Send Email (Notificar jefe de estudios)**: Envía un email al jefe de estudios informando de que las notas del trimestre están consolidadas e indicando el enlace a la hoja de resumen.

#### 06 - Generador de Informe Mensual de Asistencia

**Categoría:** Gestión académica

Este workflow genera automáticamente un informe de asistencia del mes anterior el primer día de cada mes. Es complementario al workflow 04 (Control de Asistencia Diario): el 04 registra la asistencia día a día, y el 06 la analiza mensualmente. He decidido crearlos por separado para que cada uno tenga una responsabilidad clara.

**Flujo de ejecución:**

1. **Schedule Trigger (día 1 de cada mes a las 8:00)**: La expresión cron es `0 8 1 * *`. Se ejecuta el primer día de cada mes a las 8 de la mañana, antes de que empiece la jornada escolar. He elegido esta hora porque así el equipo directivo tiene el informe disponible a primera hora.

2. **Google Sheets (Leer registros de asistencia)**: Lee todos los registros de la hoja de asistencia que alimenta el workflow 04.

3. **Code (Procesar datos del mes anterior)**: Este es el nodo más largo del workflow. El código JavaScript hace varias cosas:
   - Filtra los registros para quedarse solo con los del mes anterior. El motivo de no usar el mes actual es que el informe se genera el día 1, así que los datos del mes en curso estarían vacíos.
   - Agrupa los registros por alumno.
   - Para cada alumno, calcula el número de días presentes, ausentes y el porcentaje de asistencia.
   - Marca con una alerta a los alumnos que acumulan más de 3 ausencias en el mes, ya que eso puede ser indicador de un problema que requiere intervención del tutor.

4. **Send Email (Enviar informe a dirección)**: Envía el informe completo al equipo directivo. El email incluye una tabla resumen con los datos de cada alumno y destaca en el asunto el mes al que corresponde el informe. Los alumnos con alerta por ausencias aparecen señalados en el listado.

5. **Google Sheets (Archivar en hoja histórica)**: Guarda los datos procesados en una hoja de histórico separada. Esto permite consultar la evolución de la asistencia a lo largo de los meses sin tener que volver a procesar los datos en bruto. Es una decisión pensada para que, a final de curso, el centro pueda ver tendencias sin esfuerzo adicional.

### 3.1.5 Fase 5: Workflows de mantenimiento, convivencia y gestión TIC

En esta fase he desarrollado cuatro workflows adicionales que amplían el alcance del proyecto más allá de la gestión académica pura. Cubren necesidades que surgieron al analizar el día a día real de un centro educativo: la seguridad de los datos, los recordatorios académicos, la gestión de equipos informáticos y el bienestar del alumnado.

#### 07 - Backup Automático de Datos n8n

**Categoría:** Mantenimiento y seguridad

Este workflow resuelve una necesidad crítica: si el USB se pierde o el equipo falla, se pierden todos los workflows configurados. Con este backup automático, cada noche se exportan todos los workflows a Google Drive como copia de seguridad.

**Flujo de ejecución:**

1. **Schedule Trigger (cada día a las 2:00 AM)**: La expresión cron es `0 2 * * *`. Se ejecuta de madrugada para no interferir con el uso normal del sistema. He elegido las 2 AM porque es un momento en el que nadie estará usando n8n.

2. **HTTP Request (API interna de n8n)**: Llama a la API REST de n8n (`http://localhost:5678/api/v1/workflows`) para obtener la lista completa de todos los workflows configurados. Necesita una API key que se genera en Settings > API dentro de n8n. He optado por la API interna en lugar de acceder directamente al archivo SQLite porque la API devuelve los workflows en formato JSON limpio, listos para reimportar.

3. **Code (Preparar backup)**: Empaqueta todos los workflows en un único archivo JSON con metadatos: fecha del backup, hora exacta y número total de workflows. El nombre del archivo incluye la fecha (`backup-n8n-2025-06-15.json`) para organizar los backups cronológicamente.

4. **Google Drive (Subir backup)**: Sube el archivo JSON a una carpeta específica de Google Drive. El usuario solo necesita configurar el ID de la carpeta de destino una vez.

**Decisión de diseño**: He elegido Google Drive como destino del backup porque es gratuito y la mayoría de centros ya tienen cuentas de Google Workspace. Además, al estar en la nube, la copia de seguridad sobrevive incluso si se pierde el USB y el equipo a la vez.

#### 08 - Recordatorio de Entregas y Exámenes

**Categoría:** Gestión académica / Comunicaciones

Los alumnos a menudo se enteran tarde de que tienen un examen o una entrega de trabajo. Este workflow revisa cada mañana el calendario académico y envía recordatorios automáticos cuando hay un evento en los próximos 3 días.

**Flujo de ejecución:**

1. **Schedule Trigger (lunes a viernes a las 8:00)**: La expresión cron es `0 8 * * 1-5`. Solo se ejecuta en días lectivos, antes del inicio de clases.

2. **Google Sheets (Leer calendario académico)**: Lee la hoja con las fechas de exámenes y entregas. Las columnas necesarias son: `fecha` (DD/MM/YYYY), `tipo` (examen o entrega), `asignatura`, `curso`, `descripcion` y `email_grupo`.

3. **Code (Filtrar próximos 3 días)**: Compara cada fecha con la fecha actual y selecciona solo los eventos que caen en los próximos 3 días. Para cada evento, calcula una etiqueta de urgencia: "HOY", "MAÑANA" o "En X días". He elegido 3 días como ventana porque da tiempo suficiente para prepararse sin ser un aviso tan lejano que se ignore. El parseo de fechas está adaptado al formato español DD/MM/YYYY.

4. **IF (¿Hay eventos próximos?)**: Si no hay ningún evento en los próximos 3 días, el workflow termina sin hacer nada.

5. **Send Email (Enviar recordatorio)**: Envía un email al grupo de alumnos afectado. El asunto incluye la urgencia ("HOY: Examen de Matemáticas - 2ESO-A") para que los alumnos lo vean de un vistazo en su bandeja de entrada.

#### 09 - Gestión de Inventario TIC

**Categoría:** Gestión TIC

En muchos centros, los equipos informáticos (portátiles, tablets, proyectores) se prestan a los profesores y a veces no se devuelven. Este workflow permite registrar préstamos y devoluciones mediante un webhook y mantener un inventario actualizado en Google Sheets.

**Flujo de ejecución:**

1. **Webhook (POST /inventario-tic)**: Recibe peticiones con tres campos: `equipo` (identificador del dispositivo, por ejemplo PORTATIL-012), `accion` ("prestar" o "devolver") y `profesor` (nombre del docente). He elegido un webhook porque permite integrarlo con cualquier interfaz: un formulario web, una aplicación móvil o incluso un script que lea códigos QR pegados a los equipos.

2. **IF (¿Préstamo o devolución?)**: Decide el flujo según el valor de `accion`. Si es "prestar", va por la rama superior; si es "devolver", por la inferior.

3. **Google Sheets (Registrar préstamo)**: Añade una fila con el equipo, profesor, fecha y hora del préstamo, y el estado "prestado".

4. **Google Sheets (Registrar devolución)**: Añade una fila con el equipo, profesor, fecha y hora de la devolución, y el estado "disponible".

5. **Code (Respuesta OK)**: Genera una respuesta JSON de confirmación para quien hizo la petición.

**Decisión de diseño**: He separado los registros de préstamo y devolución en filas independientes (en lugar de actualizar una fila existente) porque así queda un historial completo de todos los movimientos. El coordinador TIC puede filtrar por estado para ver de un vistazo qué equipos están prestados.

#### 10 - Notificación de Cumpleaños de Alumnos

**Categoría:** Convivencia y bienestar

Este workflow tiene un enfoque diferente al resto: no resuelve un problema administrativo, sino que mejora la convivencia. Cada mañana revisa la lista de alumnos y avisa al tutor si alguien de su grupo cumple años ese día, para que pueda organizar una felicitación en clase.

**Flujo de ejecución:**

1. **Schedule Trigger (lunes a viernes a las 8:30)**: La expresión cron es `30 8 * * 1-5`. Se ejecuta media hora antes del inicio de clases para dar tiempo al tutor a preparar la felicitación.

2. **Google Sheets (Leer lista de alumnos)**: Lee la hoja con los datos de todos los alumnos. Las columnas necesarias son: `nombre_alumno`, `fecha_nacimiento` (DD/MM/YYYY), `curso` y `email_tutor`.

3. **Code (Buscar cumpleaños de hoy)**: Compara el día y mes de nacimiento de cada alumno con la fecha actual (ignorando el año). Si alguien cumple años, calcula su edad y lo añade a la lista. He incluido una lógica de agrupación por tutor: si en un mismo grupo hay dos alumnos que cumplen años el mismo día, el tutor recibe un solo email con ambos en lugar de dos emails separados.

4. **IF (¿Alguien cumple hoy?)**: Si no hay cumpleaños, el workflow termina.

5. **Send Email (Notificar al tutor)**: Envía un email al tutor del grupo con la lista de alumnos que cumplen años y la edad que cumplen. El tono es cercano y positivo.

**Decisión de diseño**: Este workflow demuestra que las automatizaciones no tienen que ser solo administrativas. Un pequeño detalle como felicitar a un alumno puede mejorar mucho el clima del aula, y automatizarlo asegura que no se olvide ningún cumpleaños.

### 3.1.6 Fase 6: Workflows de alertas, gestión de recursos, personal y calidad

En esta última fase de desarrollo he creado cinco workflows adicionales que llevan el proyecto un paso más allá: el sistema ya no solo ejecuta tareas mecánicas, sino que también detecta problemas de forma proactiva, gestiona recursos del centro, coordina sustituciones de profesores y recoge feedback de las familias.

#### 11 - Alerta de Absentismo Acumulado

**Categoría:** Alertas / Gestión académica

Este workflow es diferente a los anteriores porque no se limita a ejecutar una tarea: analiza datos y toma una decisión. Cada viernes revisa los registros de asistencia del mes en curso, detecta los alumnos que acumulan más de 3 ausencias y envía un informe de alerta al jefe de estudios.

**Flujo de ejecución:**

1. **Schedule Trigger (viernes a las 14:00)**: La expresión cron es `0 14 * * 5`. Se ejecuta los viernes por la tarde para que el jefe de estudios tenga el informe antes de terminar la semana y pueda actuar el lunes.

2. **Google Sheets (Leer registros de asistencia)**: Lee la misma hoja que alimenta el workflow 04, lo que demuestra que los workflows pueden compartir fuentes de datos sin conflictos.

3. **Code (Detectar absentismo)**: Filtra los registros del mes en curso, agrupa por alumno, cuenta las ausencias y calcula el porcentaje de asistencia. Solo pasan al siguiente nodo los alumnos que superan el umbral de 3 faltas.

4. **IF (¿Hay alumnos en alerta?)**: Si no hay nadie por encima del umbral, el workflow termina sin enviar nada. El jefe de estudios solo recibe correo cuando hay un problema real.

5. **Code (Preparar informe)**: Genera un informe formateado con una tabla de alumnos, sus ausencias y porcentajes.

6. **Send Email**: Envía el informe al jefe de estudios con un asunto que incluye el número de alumnos en alerta.

**Decisión de diseño**: El umbral de 3 ausencias es configurable en el código. He elegido 3 porque es el número que la mayoría de centros usa como indicador de riesgo de absentismo escolar.

#### 12 - Boletín Semanal para Familias

**Categoría:** Comunicaciones educativas

Cada viernes por la tarde genera un boletín con las novedades del curso (próximos eventos, avisos del tutor) y lo envía por email a las familias de cada grupo. El tutor solo tiene que rellenar una hoja de cálculo con los avisos de la semana.

**Flujo de ejecución:**

1. **Schedule Trigger (viernes a las 16:00)**: Se ejecuta al final de la jornada escolar para que las familias reciban el boletín antes del fin de semana.

2. **Google Sheets (Leer boletines por curso)**: Cada fila de la hoja corresponde a un curso, con sus eventos y avisos.

3. **IF (Tiene email de grupo)**: Filtra cursos sin email configurado.

4. **Code (Componer boletín)**: Genera el cuerpo del email con los eventos de la próxima semana y los avisos del tutor. Calcula automáticamente las fechas.

5. **Send Email**: Envía el boletín personalizado al email de grupo de cada curso.

#### 13 - Solicitud de Material y Recursos

**Categoría:** Gestión de recursos

Permite a los profesores solicitar material (fotocopias, laboratorio, aulas especiales) mediante un webhook. La solicitud se registra en Google Sheets y, si es urgente, se notifica inmediatamente al coordinador.

**Flujo de ejecución:**

1. **Webhook (POST /solicitud-material)**: Recibe la solicitud con campos: profesor, tipo, descripción y urgencia (baja/media/alta).

2. **Set (Preparar registro)**: Normaliza los datos y añade fecha, hora y estado "pendiente".

3. **Google Sheets (Guardar solicitud)**: Registra la solicitud en la hoja de seguimiento.

4. **IF (¿Es urgente?)**: Si la urgencia es "alta", ejecuta la notificación. Si no, el workflow termina con la confirmación.

5. **Send Email (Notificar coordinador)**: Solo para solicitudes urgentes.

6. **Respond to Webhook**: Devuelve confirmación JSON al profesor.

**Decisión de diseño**: Solo las solicitudes urgentes generan notificación inmediata. Las de urgencia media o baja quedan en la hoja para revisión periódica, evitando saturar al coordinador con emails.

#### 14 - Gestión de Guardias y Sustituciones

**Categoría:** Gestión de personal docente

Este es el workflow más complejo del proyecto. Cuando un profesor comunica su ausencia, el sistema consulta automáticamente el cuadrante de guardias del día, busca un sustituto disponible para esa franja horaria y notifica tanto al sustituto como a jefatura de estudios.

**Flujo de ejecución:**

1. **Webhook (POST /ausencia-profesor)**: Recibe la ausencia con: profesor, motivo y franja horaria.

2. **Set (Preparar datos)**: Calcula automáticamente el día de la semana actual para buscar en el cuadrante.

3. **Google Sheets (Leer cuadrante de guardias)**: Lee la hoja con el cuadrante de guardias del centro.

4. **Code (Buscar sustituto)**: Cruza el día y la franja horaria con el cuadrante para encontrar al profesor de guardia disponible.

5. **Google Sheets (Registrar ausencia)**: Guarda el registro con el sustituto asignado.

6. **IF (¿Sustituto encontrado?)**: Si hay profesor de guardia, va a notificarle. Si no, avisa a jefatura.

7. **Send Email (Notificar sustituto)** o **Send Email (Avisar jefatura)**: Según si se encontró sustituto o no.

8. **Respond to Webhook**: Devuelve al profesor ausente los datos del sustituto asignado.

**Decisión de diseño**: He separado las ramas de "sustituto encontrado" y "sin sustituto" con respuestas webhook distintas. Así el profesor sabe inmediatamente si alguien le cubre o si tiene que esperar a que jefatura lo gestione.

#### 15 - Encuesta de Satisfacción Automatizada

**Categoría:** Calidad y mejora continua

El primer día de cada mes envía automáticamente un enlace a una encuesta de Google Forms a todas las familias. Registra cada envío en una hoja de log para seguimiento.

**Flujo de ejecución:**

1. **Schedule Trigger (día 1 de cada mes a las 10:00)**: La expresión cron es `0 10 1 * *`.

2. **Google Sheets (Leer familias)**: Lee el listado de familias con sus emails y cursos.

3. **IF (Tiene email)**: Filtra familias sin email.

4. **Code (Componer email)**: Genera un email personalizado con el enlace a la encuesta, el nombre de la familia y el mes correspondiente.

5. **Send Email**: Envía la encuesta a cada familia.

6. **Google Sheets (Registrar envío)**: Guarda un log de cada envío con fecha, familia, curso y email.

**Decisión de diseño**: Este workflow demuestra que las automatizaciones pueden contribuir a la mejora continua del centro. Las encuestas de satisfacción son obligatorias en muchos sistemas de calidad educativa, y automatizar su distribución garantiza que se envían puntualmente sin depender de que alguien se acuerde.

### 3.1.8 Fase 6: Workflows offline (sin conexión a Internet)

Hasta este punto, los 15 workflows anteriores dependen de servicios externos: Google Sheets como base de datos y SMTP para enviar emails. Esto significa que sin conexión a Internet, ninguno de ellos funciona. Para un proyecto que se vende como "portátil en USB", esta es una limitación importante.

En esta fase se crean 6 workflows que funcionan al 100% sin Internet. La clave técnica es el uso de `$getWorkflowStaticData('global')`, una API de n8n que permite almacenar y leer datos directamente en la base de datos SQLite interna. Los datos persisten entre ejecuciones y viajan con el USB junto con el contenedor.

Estos workflows demuestran que n8n puede ser una herramienta completamente autónoma, no solo un orquestador de servicios en la nube.

#### 16 - Calculadora de Notas Offline

**Categoría:** Gestión académica | **Modo:** Offline

Este workflow es la versión offline del workflow 05 (Consolidar Notas del Trimestre). En lugar de leer notas de Google Sheets, las recibe por webhook y las almacena en SQLite interno. La principal diferencia es que todo el ciclo de vida de los datos (entrada, cálculo, almacenamiento y consulta) ocurre dentro del contenedor Docker sin ninguna conexión externa.

**Flujo de ejecución:**

1. **Webhook (POST /calcular-notas)**: Recibe los datos de notas por HTTP. Acepta dos tipos de petición: registrar notas nuevas (con campos `alumno`, `curso`, `examen`, `trabajo`, `participacion`) o consultar el histórico (con `accion: "consultar"`). He usado un único endpoint para ambas operaciones porque simplifica la integración: quien consume la API solo necesita conocer una URL.

2. **Code (Procesar notas o consultar)**: Este es el nodo central del workflow. El código JavaScript:
   - Lee los datos almacenados con `$getWorkflowStaticData('global')`.
   - Si la petición es de registro: calcula la media ponderada (examen 50%, trabajo 30%, participación 20%), asigna la calificación cualitativa (Insuficiente, Suficiente, Bien, Notable, Sobresaliente) y guarda el registro con timestamp.
   - Si la petición es de consulta: recupera el histórico y opcionalmente lo filtra por curso.
   - Devuelve el resultado formateado como JSON.

3. **Respond to Webhook**: Devuelve la respuesta JSON con la nota calculada o el histórico solicitado.

**Decisión de diseño**: He elegido `$getWorkflowStaticData('global')` en lugar de leer/escribir archivos JSON locales porque la API de static data es atómica (no hay riesgo de corrupción por escrituras concurrentes) y los datos se almacenan en la misma base de datos SQLite que usa n8n internamente, lo que garantiza que viajan con el contenedor.

#### 17 - Registro de Incidencias Offline

**Categoría:** Convivencia | **Modo:** Offline

Permite registrar y consultar incidencias de convivencia sin depender de Google Sheets. Cada incidencia queda almacenada con fecha, tipo (leve, grave, muy grave), alumno, curso y profesor que la reporta. El workflow también genera resúmenes estadísticos por tipo y por curso.

**Flujo de ejecución:**

1. **Webhook (POST /registro-incidencias)**: Recibe tres tipos de petición: registrar una nueva incidencia, consultar incidencias con filtros, o generar un resumen estadístico.

2. **Code (Gestionar incidencias)**: El código JavaScript implementa un CRUD completo:
   - **Registrar**: Valida que el tipo sea uno de los permitidos (`leve`, `grave`, `muy_grave`), genera un ID único y un timestamp, y almacena la incidencia en `staticData`.
   - **Consultar**: Recupera las incidencias y aplica filtros opcionales por curso, alumno, tipo o rango de fechas. Los filtros se combinan (AND lógico).
   - **Resumen**: Calcula estadísticas: total de incidencias, desglose por tipo (porcentaje de leves, graves y muy graves), desglose por curso, y los 3 cursos con más incidencias.

3. **Respond to Webhook**: Devuelve el resultado correspondiente a la acción solicitada.

**Decisión de diseño**: He implementado el filtrado y las estadísticas directamente en el nodo Code porque no existen nodos nativos de n8n para consultar datos estructurados en staticData. En un sistema con base de datos SQL se usarían queries, pero aquí el Code actúa como un mini motor de consultas sobre un array JSON.

#### 18 - Generador de Contraseñas para Alumnos

**Categoría:** Herramientas TIC | **Modo:** Offline

Herramienta práctica para el coordinador TIC del centro. Recibe una lista de nombres de alumnos y genera un usuario y contraseña segura para cada uno. Útil para crear cuentas en plataformas internas, laboratorios o equipos compartidos. No almacena datos: genera las credenciales en el momento y las devuelve.

**Flujo de ejecución:**

1. **Webhook (POST /generar-contrasenas)**: Recibe un array de nombres de alumnos y opcionalmente la longitud deseada de la contraseña (por defecto 12 caracteres).

2. **Code (Generar credenciales)**: Para cada alumno:
   - Genera un nombre de usuario basado en el nombre (primera letra del nombre + apellido, en minúsculas, sin acentos ni caracteres especiales).
   - Genera una contraseña aleatoria que incluye mayúsculas, minúsculas, números y símbolos. Se excluyen caracteres ambiguos (0, O, l, I, 1) para evitar confusiones al teclearlas.
   - Devuelve el listado completo en formato JSON.

3. **Respond to Webhook**: Devuelve el array de credenciales generadas.

**Decisión de diseño**: Este workflow no usa `staticData` porque no tiene sentido almacenar contraseñas generadas (sería un riesgo de seguridad). Las credenciales se generan, se entregan y no se persisten. Si el usuario necesita guardarlas, puede copiar la respuesta JSON a un archivo o imprimirla.

#### 19 - Control de Préstamos de Material Offline

**Categoría:** Gestión TIC | **Modo:** Offline

Versión offline del workflow 09 (Gestión de Inventario TIC). Gestiona préstamos y devoluciones de equipos informáticos (portátiles, tablets, proyectores) sin depender de Google Sheets. Además, detecta equipos que llevan más de 7 días prestados y los marca como "alerta" en las consultas.

**Flujo de ejecución:**

1. **Webhook (POST /prestamos-offline)**: Acepta tres acciones: prestar un equipo, registrar una devolución o consultar el estado del inventario.

2. **Code (Gestionar préstamos)**: El código maneja tres operaciones:
   - **Prestar**: Registra el préstamo con equipo, profesor, fecha y estado "prestado". Si el equipo ya está prestado, devuelve un error.
   - **Devolver**: Busca el préstamo activo del equipo, lo marca como "devuelto" y registra la fecha de devolución.
   - **Consultar**: Lista todos los préstamos activos, calcula los días transcurridos desde cada préstamo y marca con una alerta los que superan los 7 días.

3. **Respond to Webhook**: Devuelve el resultado de la operación.

**Decisión de diseño**: He añadido la alerta de 7 días porque en un centro educativo es habitual que un profesor pida un portátil "para una clase" y lo devuelva semanas después. La alerta no bloquea nada, simplemente informa al coordinador TIC de qué equipos llevan demasiado tiempo fuera.

#### 20 - Sorteo y Asignación de Grupos

**Categoría:** Herramientas docentes | **Modo:** Offline

Herramienta para formar equipos de trabajo de forma aleatoria y equilibrada. Recibe una lista de alumnos y un número de grupos, y reparte los alumnos usando el algoritmo Fisher-Yates para garantizar una distribución verdaderamente aleatoria. No almacena datos.

**Flujo de ejecución:**

1. **Webhook (POST /sorteo-grupos)**: Recibe un array de nombres de alumnos y opcionalmente el número de grupos deseado (por defecto 2).

2. **Code (Sortear y distribuir)**: El código implementa:
   - **Fisher-Yates shuffle**: Baraja el array de alumnos de forma aleatoria. He elegido este algoritmo porque es el estándar para permutaciones imparciales: cada posible ordenación tiene la misma probabilidad. Un `sort(() => Math.random() - 0.5)` parece funcionar pero tiene sesgo estadístico demostrable.
   - **Distribución round-robin**: Asigna los alumnos barajados a los grupos de forma circular (alumno 1 al grupo 1, alumno 2 al grupo 2, etc., y vuelta a empezar). Esto garantiza que la diferencia de tamaño entre grupos sea como máximo de 1 alumno.

3. **Respond to Webhook**: Devuelve los grupos formados con sus miembros.

**Decisión de diseño**: El workflow no persiste los grupos generados porque cada ejecución es un sorteo independiente. Si el profesor necesita repetir el mismo sorteo (por ejemplo, para grupos estables durante un trimestre), puede guardar la respuesta JSON. Hacer que el workflow almacene grupos añadiría complejidad sin un caso de uso claro.

#### 21 - Diario de Actividad del Centro

**Categoría:** Administración | **Modo:** Offline

Actúa como un libro de registro digital del centro educativo. Permite anotar eventos, incidencias, logros, recordatorios y actas. A diferencia del workflow 17 (Registro de Incidencias), que se centra en convivencia, este es un registro generalista: cualquier cosa relevante que ocurra en el centro puede anotarse aquí.

**Flujo de ejecución:**

1. **Webhook (POST /diario-actividad)**: Acepta tres acciones: registrar una nueva entrada, consultar entradas (con filtros por tipo, fecha o búsqueda de texto) o generar un resumen estadístico.

2. **Code (Gestionar diario)**: El código implementa:
   - **Registrar**: Almacena la entrada con tipo (`evento`, `incidencia`, `logro`, `recordatorio`, `acta`), título, descripción, responsable y timestamp automático.
   - **Consultar**: Recupera entradas con filtros combinables: por tipo, por rango de fechas, o por búsqueda de texto libre en título y descripción (búsqueda case-insensitive).
   - **Resumen**: Genera estadísticas del diario: total de entradas, desglose por tipo, entradas de los últimos 7 y 30 días, y las 5 entradas más recientes.

3. **Respond to Webhook**: Devuelve el resultado correspondiente.

**Decisión de diseño**: He incluido 5 tipos de entrada en lugar de texto libre para poder generar estadísticas significativas. Los tipos cubren el espectro de lo que un centro educativo registra: eventos (excursiones, celebraciones), incidencias (averías, problemas), logros (premios, reconocimientos), recordatorios (plazos, entregas) y actas (reuniones, claustros).

## 3.2 Documentación técnica

### 3.2.1 Estructura del proyecto

```
proyecto/
├── docker-compose.yml          # Configuración del contenedor
├── .env.example                # Plantilla de variables de entorno
├── .gitignore                  # Archivos excluidos del repositorio
├── scripts/
│   ├── start.bat               # Arranque en Windows
│   ├── start.sh                # Arranque en Linux/macOS
│   ├── stop.bat                # Parada en Windows
│   └── stop.sh                 # Parada en Linux/macOS
├── workflows/
│   ├── CATALOGO.md             # Catálogo organizado de los 21 workflows
│   ├── 01 a 15 (*.json)       # Workflows online (requieren Internet)
│   └── 16 a 21 (*.json)       # Workflows offline (funcionan sin Internet)
├── n8n-data/                   # Datos persistentes de n8n (no se sube a GitHub)
│   └── database.sqlite         # Base de datos con workflows y configuración
└── Memoria/                    # Documentación del proyecto
    └── (capítulos .md)
```

### 3.2.2 Ficheros de configuración

**`docker-compose.yml`**: Archivo principal que define el servicio n8n. Utiliza la imagen oficial del registro de Docker de n8n (`docker.n8n.io/n8nio/n8n`). El contenedor se reinicia automáticamente (`restart: unless-stopped`) a menos que se detenga manualmente.

**`.env`**: Archivo de variables de entorno que no se sube al repositorio (está en `.gitignore`) ya que puede contener datos sensibles. Se genera automáticamente a partir de `.env.example` en el primer arranque.

**`.gitignore`**: Excluye del repositorio la carpeta `n8n-data/` (contiene la base de datos y datos del usuario), el archivo `.env` (puede contener credenciales) y otros archivos de sistema.

### 3.2.3 Características técnicas

| Característica | Detalle |
|---------------|---------|
| Imagen Docker | `docker.n8n.io/n8nio/n8n` (última versión estable) |
| Base de datos | SQLite (archivo único en `n8n-data/database.sqlite`) |
| Puerto por defecto | 5678 (configurable mediante `.env`) |
| Persistencia | Bind mount a `./n8n-data` |
| Zona horaria | Europe/Madrid (configurable mediante `.env`) |
| Plataformas soportadas | Windows 10/11, Linux, macOS |
| Requisito previo | Docker (los scripts de arranque lo instalan automáticamente si no está presente) |

### 3.2.4 Workflows implementados

La siguiente tabla resume los veintiún workflows desarrollados en el proyecto, separados por modo de funcionamiento.

**Workflows online** (requieren conexión a Internet):

| Workflow | Categoría | Descripción breve | Trigger | Nodos principales |
|----------|-----------|-------------------|---------|-------------------|
| 01 - Email Masivo a Padres/Tutores | Comunicaciones | Envía emails personalizados a las familias a partir de un listado en Google Sheets | Manual Trigger | Google Sheets, IF, Set, Send Email (SMTP) |
| 02 - Recogida Automática de Google Forms | Comunicaciones / Gestión | Recibe respuestas de formularios por webhook, las archiva y notifica al profesor | Webhook POST `/formulario-educativo` | Set, Google Sheets, Send Email |
| 03 - Recordatorio Semanal de Reuniones | Gestión académica | Envía cada lunes un resumen con las reuniones de la semana | Schedule Trigger (`0 9 * * 1`) | Google Sheets, Code, IF, Send Email |
| 04 - Control de Asistencia Diario | Gestión académica | Registra la asistencia por webhook y notifica a la familia si hay ausencia | Webhook POST `/asistencia` | Set, Google Sheets, IF, Send Email, Respond to Webhook |
| 05 - Consolidar Notas del Trimestre | Gestión académica | Combina notas de varias fuentes, calcula la media ponderada y genera un resumen | Manual Trigger | Google Sheets x2, Merge, Code, Google Sheets, Send Email |
| 06 - Generador de Informe Mensual de Asistencia | Gestión académica | Genera un informe mensual con porcentajes de asistencia y alertas por ausencias | Schedule Trigger (`0 8 1 * *`) | Google Sheets, Code, Send Email, Google Sheets |
| 07 - Backup Automático de Datos n8n | Mantenimiento | Exporta todos los workflows a Google Drive como copia de seguridad diaria | Schedule Trigger (`0 2 * * *`) | HTTP Request, Code, Google Drive |
| 08 - Recordatorio de Entregas y Exámenes | Gestión académica | Avisa a los alumnos 3 días antes de exámenes y entregas de trabajos | Schedule Trigger (`0 8 * * 1-5`) | Google Sheets, Code, IF, Send Email |
| 09 - Gestión de Inventario TIC | Gestión TIC | Registra préstamos y devoluciones de equipos informáticos vía webhook | Webhook POST `/inventario-tic` | IF, Google Sheets x2, Code |
| 10 - Notificación de Cumpleaños | Convivencia | Avisa al tutor cuando un alumno de su grupo cumple años | Schedule Trigger (`30 8 * * 1-5`) | Google Sheets, Code, IF, Send Email |
| 11 - Alerta de Absentismo Acumulado | Alertas | Detecta alumnos con más de 3 ausencias en el mes y alerta al jefe de estudios | Schedule Trigger (`0 14 * * 5`) | Google Sheets, Code, IF, Code, Send Email |
| 12 - Boletín Semanal para Familias | Comunicaciones | Genera un resumen semanal con eventos y avisos y lo envía a las familias | Schedule Trigger (`0 16 * * 5`) | Google Sheets, IF, Code, Send Email |
| 13 - Solicitud de Material y Recursos | Gestión de recursos | Registra solicitudes de material vía webhook y notifica al coordinador si es urgente | Webhook POST `/solicitud-material` | Set, Google Sheets, IF, Send Email, Respond to Webhook |
| 14 - Gestión de Guardias y Sustituciones | Gestión de personal | Asigna sustitutos automáticamente consultando el cuadrante de guardias | Webhook POST `/ausencia-profesor` | Set, Google Sheets, Code, Google Sheets, IF, Send Email x2, Respond to Webhook |
| 15 - Encuesta de Satisfacción Automatizada | Calidad | Envía encuestas mensuales a las familias y registra los envíos | Schedule Trigger (`0 10 1 * *`) | Google Sheets, IF, Code, Send Email, Google Sheets |

**Workflows offline** (funcionan sin conexión a Internet):

| Workflow | Categoría | Descripción breve | Trigger | Nodos principales | Almacenamiento |
|----------|-----------|-------------------|---------|-------------------|----------------|
| 16 - Calculadora de Notas Offline | Gestión académica | Calcula medias ponderadas y almacena histórico de notas | Webhook POST `/calcular-notas` | Code, Respond to Webhook | SQLite (staticData) |
| 17 - Registro de Incidencias Offline | Convivencia | Registra y consulta incidencias con filtros y estadísticas | Webhook POST `/registro-incidencias` | Code, Respond to Webhook | SQLite (staticData) |
| 18 - Generador de Contraseñas | Herramientas TIC | Genera usuarios y contraseñas seguras para listas de alumnos | Webhook POST `/generar-contrasenas` | Code, Respond to Webhook | Sin estado |
| 19 - Control de Préstamos Offline | Gestión TIC | Gestiona préstamos/devoluciones con alertas de retraso | Webhook POST `/prestamos-offline` | Code, Respond to Webhook | SQLite (staticData) |
| 20 - Sorteo de Grupos | Herramientas docentes | Reparte alumnos en grupos aleatorios equilibrados | Webhook POST `/sorteo-grupos` | Code, Respond to Webhook | Sin estado |
| 21 - Diario de Actividad del Centro | Administración | Libro de registro digital con búsqueda y resúmenes | Webhook POST `/diario-actividad` | Code, Respond to Webhook | SQLite (staticData) |

Todos los workflows se exportan en formato JSON y se almacenan en la carpeta `workflows/` del proyecto. Esto permite importarlos en cualquier instancia de n8n sin necesidad de recrearlos manualmente, lo que refuerza el objetivo de portabilidad del proyecto. El catálogo completo con clasificación detallada está disponible en `workflows/CATALOGO.md`.

## 3.3 Consideraciones de seguridad y protección de datos

### 3.3.1 Marco legal aplicable

Al tratarse de un sistema que maneja datos personales de alumnos en un entorno educativo, es obligatorio tener en cuenta la normativa vigente en materia de protección de datos:

- **Reglamento General de Protección de Datos (RGPD)** — Reglamento (UE) 2016/679, de aplicación directa en todos los estados miembros de la UE. Establece los principios de licitud, minimización de datos, limitación de la finalidad, integridad y confidencialidad.
- **LOPD-GDD** — Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y garantía de los derechos digitales. Adapta el RGPD al ordenamiento jurídico español y añade disposiciones específicas para el ámbito educativo.

Los datos de menores de edad tienen una protección reforzada. El artículo 7 de la LOPD-GDD establece que el tratamiento de datos de menores de 14 años requiere el consentimiento del titular de la patria potestad. En un entorno educativo, el centro actúa como responsable del tratamiento y debe garantizar que los datos se tratan de forma segura.

### 3.3.2 Datos personales tratados por el sistema

A continuación se clasifican los datos que manejan los workflows del proyecto, organizados por nivel de sensibilidad:

| Nivel | Datos | Workflows que los tratan |
|-------|-------|--------------------------|
| **Alto** | Notas y calificaciones académicas | 05, 16 |
| **Alto** | Incidencias de convivencia (tipo, descripción, alumno) | 17 |
| **Alto** | Registro de asistencia y absentismo | 04, 06, 11 |
| **Medio** | Nombres y apellidos de alumnos | 01, 02, 04, 05, 10, 11, 12, 16-21 |
| **Medio** | Emails de familias / tutores legales | 01, 08, 12, 15 |
| **Medio** | Datos de profesores (nombres, horarios, guardias) | 03, 14 |
| **Bajo** | Inventario de equipos informáticos | 09, 19 |
| **Bajo** | Entradas del diario de actividad | 21 |

### 3.3.3 Medidas técnicas implementadas

El diseño del proyecto incorpora varias medidas que contribuyen a la seguridad de los datos:

1. **Almacenamiento exclusivamente local.** Todos los datos procesados por los workflows offline (16-21) se almacenan en la base de datos SQLite interna de n8n, que reside físicamente en la carpeta `n8n-data/` dentro del USB o equipo del usuario. Los datos nunca se transmiten a servidores externos ni se almacenan en la nube. Esto es una ventaja importante frente a soluciones SaaS como Zapier o Make, donde los datos del centro viajarían a servidores de terceros fuera de la UE.

2. **Credenciales cifradas.** n8n almacena las credenciales de servicios externos (Google Sheets, SMTP) de forma cifrada en su base de datos SQLite, utilizando una clave de cifrado interna. Las credenciales nunca se almacenan en texto plano ni se incluyen en los archivos JSON de los workflows.

3. **Exclusión de datos sensibles del repositorio.** El archivo `.gitignore` excluye la carpeta `n8n-data/` (que contiene la base de datos con datos reales) y el archivo `.env` (que puede contener configuraciones sensibles). Esto garantiza que al compartir el proyecto vía GitHub o USB, no se filtran datos personales ni credenciales.

4. **Webhooks accesibles solo en localhost.** Por defecto, n8n escucha únicamente en `localhost:5678`. Esto significa que los endpoints webhook solo son accesibles desde el propio equipo donde se ejecuta n8n, no desde la red local ni desde Internet. Para acceder remotamente sería necesario configurar explícitamente el reenvío de puertos o un proxy inverso.

5. **Diagnósticos desactivados.** La variable de entorno `N8N_DIAGNOSTICS_ENABLED=false` desactiva el envío de datos de telemetría a los servidores de n8n, respetando la privacidad del entorno educativo.

6. **Contraseñas no persistidas.** El workflow 18 (Generador de Contraseñas) genera credenciales pero no las almacena en la base de datos. Se entregan en la respuesta HTTP y no quedan registradas, minimizando el riesgo de exposición.

### 3.3.4 Recomendaciones para un entorno de producción

Si un centro educativo decidiera utilizar este sistema de forma permanente con datos reales de alumnos, se recomiendan las siguientes medidas adicionales:

1. **Activar la autenticación de n8n.** Configurar las variables de entorno `N8N_BASIC_AUTH_ACTIVE=true`, `N8N_BASIC_AUTH_USER` y `N8N_BASIC_AUTH_PASSWORD` para exigir usuario y contraseña en el acceso a la interfaz web. Sin esta medida, cualquier persona con acceso al equipo podría abrir n8n y ver todos los workflows y datos.

2. **Restringir el acceso por red.** Si n8n se expone en una red local (por ejemplo, para que varios profesores accedan desde sus equipos), configurar un firewall o proxy inverso (como Nginx) que limite el acceso por IP y, preferiblemente, añada cifrado HTTPS.

3. **Realizar backups cifrados.** El workflow 07 realiza backups a Google Drive, pero los archivos no están cifrados. Para datos sensibles, se recomienda cifrar los backups antes de subirlos (por ejemplo, con GPG) o utilizar un destino de backup cifrado.

4. **Elaborar un registro de actividades de tratamiento.** El RGPD exige que el responsable del tratamiento mantenga un registro de las actividades realizadas con datos personales. Se recomienda que el centro documente qué workflows utilizan datos personales, con qué finalidad y durante cuánto tiempo se conservan.

5. **Establecer una política de retención de datos.** Los datos almacenados en `$getWorkflowStaticData` persisten indefinidamente. Se recomienda implementar un mecanismo de purgado periódico (por ejemplo, eliminar registros de cursos anteriores) para cumplir con el principio de limitación del plazo de conservación del RGPD.
