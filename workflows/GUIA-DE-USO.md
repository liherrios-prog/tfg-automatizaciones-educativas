# Guía de Uso de los Workflows

Guía práctica paso a paso para usar los 21 workflows del proyecto. Incluye comandos listos para copiar y pegar.

---

## Antes de empezar

### 1. Tener n8n corriendo

Ejecuta el script de arranque de tu sistema operativo:
- **Windows:** Doble click en `scripts\start.bat`
- **Linux/macOS:** `./scripts/start.sh`

Espera a que aparezca el mensaje de que n8n está listo y abre el navegador en: **http://localhost:5678**

### 2. Importar los workflows

1. En n8n, haz click en el menú de la izquierda y selecciona **"Import from File"**
2. Navega a la carpeta `workflows/` y selecciona el archivo `.json` del workflow que quieras usar
3. Repite para cada workflow que necesites

### 3. Activar workflows con webhook

Los workflows que usan webhook (04, 09, 13, 14, y todos los offline 16-21) necesitan estar **activados** para recibir peticiones:

1. Abre el workflow en n8n
2. En la esquina superior derecha, activa el interruptor de **"Active"** (debe quedar en verde)
3. Mientras esté activo, el workflow escuchará peticiones en su endpoint

### 4. Cómo hacer peticiones (curl)

Los workflows con webhook se usan enviando peticiones HTTP. El comando `curl` viene instalado en Windows 10/11, Linux y macOS.

**En Windows (CMD o PowerShell):**
```
curl -X POST http://localhost:5678/webhook/ENDPOINT -H "Content-Type: application/json" -d "{\"campo\":\"valor\"}"
```

**En Linux/macOS (Terminal):**
```bash
curl -X POST http://localhost:5678/webhook/ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{"campo": "valor"}'
```

> **Nota Windows:** Las comillas dentro del JSON se escapan con `\"`. En Linux/macOS se usa comilla simple por fuera y doble por dentro.

---

## Workflows Offline (16-21)

Estos workflows funcionan **sin conexión a Internet**. No necesitan configurar credenciales de Google ni email. Solo necesitan que n8n esté corriendo.

---

### 16 - Calculadora de Notas Offline

**Endpoint:** `POST http://localhost:5678/webhook/calcular-notas`

Calcula la media ponderada de un alumno y guarda un histórico consultable.

**Ponderación por defecto:** Examen 50% + Trabajo 30% + Participación 20%

#### Registrar notas de un alumno

**Windows:**
```
curl -X POST http://localhost:5678/webhook/calcular-notas -H "Content-Type: application/json" -d "{\"alumno\":\"Maria Garcia\",\"curso\":\"2ESO-A\",\"examen\":7.5,\"trabajo\":8,\"participacion\":9}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/calcular-notas \
  -H "Content-Type: application/json" \
  -d '{"alumno":"Maria Garcia","curso":"2ESO-A","examen":7.5,"trabajo":8,"participacion":9}'
```

**Campos requeridos:**

| Campo | Tipo | Ejemplo | Descripción |
|-------|------|---------|-------------|
| `alumno` | texto | "Maria Garcia" | Nombre del alumno |
| `curso` | texto | "2ESO-A" | Curso y grupo |
| `examen` | número | 7.5 | Nota del examen (0-10) |
| `trabajo` | número | 8 | Nota de trabajos (0-10) |
| `participacion` | número | 9 | Nota de participación (0-10) |

**Respuesta esperada:**
```json
{
  "status": "ok",
  "alumno": "Maria Garcia",
  "curso": "2ESO-A",
  "media": 7.95,
  "calificacion": "Notable",
  "fecha": "07/04/2026, 12:30:00"
}
```

**Escala de calificaciones:** <5 Insuficiente | 5-6 Suficiente | 6-7 Bien | 7-9 Notable | ≥9 Sobresaliente

#### Consultar histórico de notas

**Windows:**
```
curl -X POST http://localhost:5678/webhook/calcular-notas -H "Content-Type: application/json" -d "{\"accion\":\"consultar\",\"curso\":\"2ESO-A\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/calcular-notas \
  -H "Content-Type: application/json" \
  -d '{"accion":"consultar","curso":"2ESO-A"}'
```

**Filtros opcionales:** Puedes omitir `curso` para ver todos, o añadir `"alumno":"Maria Garcia"` para filtrar por alumno.

---

### 17 - Registro de Incidencias Offline

**Endpoint:** `POST http://localhost:5678/webhook/registro-incidencias`

Registra incidencias de convivencia y permite consultarlas con filtros.

#### Registrar una incidencia

**Windows:**
```
curl -X POST http://localhost:5678/webhook/registro-incidencias -H "Content-Type: application/json" -d "{\"alumno\":\"Carlos Lopez\",\"curso\":\"3ESO-B\",\"tipo\":\"leve\",\"descripcion\":\"Uso del movil en clase\",\"reportado_por\":\"Prof. Martinez\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/registro-incidencias \
  -H "Content-Type: application/json" \
  -d '{"alumno":"Carlos Lopez","curso":"3ESO-B","tipo":"leve","descripcion":"Uso del movil en clase","reportado_por":"Prof. Martinez"}'
```

**Campos requeridos:**

| Campo | Tipo | Valores permitidos | Descripción |
|-------|------|--------------------|-------------|
| `alumno` | texto | — | Nombre del alumno |
| `curso` | texto | — | Curso y grupo |
| `tipo` | texto | `leve`, `grave`, `muy_grave` | Gravedad de la incidencia |
| `descripcion` | texto | — | Descripción de lo ocurrido |
| `reportado_por` | texto | — | Nombre del profesor que reporta |

#### Consultar incidencias

```
curl -X POST http://localhost:5678/webhook/registro-incidencias -H "Content-Type: application/json" -d "{\"accion\":\"consultar\"}"
```

La respuesta incluye un resumen estadístico (total, desglose por tipo) junto con el listado de incidencias.

**Filtros opcionales:** Añade `"curso":"3ESO-B"`, `"alumno":"Carlos Lopez"` o `"tipo":"grave"` para filtrar.

#### Borrar todos los datos (cuidado)

```
curl -X POST http://localhost:5678/webhook/registro-incidencias -H "Content-Type: application/json" -d "{\"accion\":\"borrar_todo\",\"confirmar\":true}"
```

---

### 18 - Generador de Contraseñas para Alumnos

**Endpoint:** `POST http://localhost:5678/webhook/generar-contrasenas`

Genera usuarios y contraseñas seguras para una lista de alumnos. No almacena datos.

#### Generar credenciales

**Windows:**
```
curl -X POST http://localhost:5678/webhook/generar-contrasenas -H "Content-Type: application/json" -d "{\"alumnos\":[\"Maria Garcia\",\"Carlos Lopez\",\"Ana Martinez\"],\"longitud\":12}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/generar-contrasenas \
  -H "Content-Type: application/json" \
  -d '{"alumnos":["Maria Garcia","Carlos Lopez","Ana Martinez"],"longitud":12}'
```

**Campos:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `alumnos` | array de textos | Sí | Lista de nombres de alumnos |
| `longitud` | número | No (defecto: 12) | Longitud de las contraseñas |

**Respuesta esperada:**
```json
{
  "status": "ok",
  "total": 3,
  "credenciales": [
    {"alumno": "Maria Garcia", "usuario": "mgarcia", "contrasena": "Kx7$mPw9&Rn2"},
    {"alumno": "Carlos Lopez", "usuario": "clopez", "contrasena": "Bq3#jTv8%Yf5"},
    {"alumno": "Ana Martinez", "usuario": "amartinez", "contrasena": "Hn6&wRs4$Dk9"}
  ]
}
```

Las contraseñas incluyen mayúsculas, minúsculas, números y símbolos. Se excluyen caracteres ambiguos (0, O, l, I, 1).

---

### 19 - Control de Préstamos de Material Offline

**Endpoint:** `POST http://localhost:5678/webhook/prestamos-offline`

Gestiona préstamos y devoluciones de equipos informáticos. Alerta si un equipo lleva más de 7 días prestado.

#### Prestar un equipo

**Windows:**
```
curl -X POST http://localhost:5678/webhook/prestamos-offline -H "Content-Type: application/json" -d "{\"accion\":\"prestar\",\"equipo\":\"PORTATIL-012\",\"profesor\":\"Garcia\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/prestamos-offline \
  -H "Content-Type: application/json" \
  -d '{"accion":"prestar","equipo":"PORTATIL-012","profesor":"Garcia"}'
```

#### Devolver un equipo

```
curl -X POST http://localhost:5678/webhook/prestamos-offline -H "Content-Type: application/json" -d "{\"accion\":\"devolver\",\"equipo\":\"PORTATIL-012\"}"
```

#### Consultar inventario

```
curl -X POST http://localhost:5678/webhook/prestamos-offline -H "Content-Type: application/json" -d "{\"accion\":\"consultar\"}"
```

**Respuesta de consulta:** Muestra todos los equipos con su estado (prestado/disponible), quién los tiene, días prestados y alerta si superan los 7 días.

**Campos por acción:**

| Acción | Campos requeridos |
|--------|-------------------|
| `prestar` | `accion`, `equipo`, `profesor` |
| `devolver` | `accion`, `equipo` |
| `consultar` | `accion` |

---

### 20 - Sorteo y Asignación de Grupos

**Endpoint:** `POST http://localhost:5678/webhook/sorteo-grupos`

Reparte alumnos en grupos aleatorios y equilibrados. No almacena datos (cada ejecución genera grupos diferentes).

#### Sortear grupos

**Windows:**
```
curl -X POST http://localhost:5678/webhook/sorteo-grupos -H "Content-Type: application/json" -d "{\"alumnos\":[\"Maria\",\"Carlos\",\"Ana\",\"Pedro\",\"Lucia\",\"Jorge\"],\"num_grupos\":3}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/sorteo-grupos \
  -H "Content-Type: application/json" \
  -d '{"alumnos":["Maria","Carlos","Ana","Pedro","Lucia","Jorge"],"num_grupos":3}'
```

**Campos:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `alumnos` | array de textos | Sí | Lista de nombres |
| `num_grupos` | número | No (defecto: 2) | Número de grupos a formar (mínimo 2) |

**Respuesta esperada:**
```json
{
  "status": "ok",
  "total_alumnos": 6,
  "num_grupos": 3,
  "grupos": [
    {"nombre": "Grupo 1", "miembros": ["Ana", "Jorge"], "total": 2},
    {"nombre": "Grupo 2", "miembros": ["Pedro", "Maria"], "total": 2},
    {"nombre": "Grupo 3", "miembros": ["Lucia", "Carlos"], "total": 2}
  ],
  "nota": "Cada ejecucion genera una distribucion diferente"
}
```

---

### 21 - Diario de Actividad del Centro

**Endpoint:** `POST http://localhost:5678/webhook/diario-actividad`

Libro de registro digital del centro. Permite anotar eventos, incidencias, logros, recordatorios y actas.

#### Registrar una entrada

**Windows:**
```
curl -X POST http://localhost:5678/webhook/diario-actividad -H "Content-Type: application/json" -d "{\"tipo\":\"evento\",\"titulo\":\"Excursion al museo\",\"descripcion\":\"Salida con 2ESO al Museo de Ciencias\",\"responsable\":\"Prof. Lopez\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/diario-actividad \
  -H "Content-Type: application/json" \
  -d '{"tipo":"evento","titulo":"Excursion al museo","descripcion":"Salida con 2ESO al Museo de Ciencias","responsable":"Prof. Lopez"}'
```

**Campos:**

| Campo | Tipo | Requerido | Valores permitidos |
|-------|------|-----------|-------------------|
| `tipo` | texto | Sí | `evento`, `incidencia`, `logro`, `recordatorio`, `acta` |
| `titulo` | texto | Sí | — |
| `descripcion` | texto | Sí | — |
| `responsable` | texto | No (defecto: "No especificado") | — |

#### Consultar entradas

```
curl -X POST http://localhost:5678/webhook/diario-actividad -H "Content-Type: application/json" -d "{\"accion\":\"consultar\"}"
```

**Filtros opcionales:**

| Filtro | Ejemplo | Descripción |
|--------|---------|-------------|
| `tipo` | `"tipo":"evento"` | Solo entradas de ese tipo |
| `buscar` | `"buscar":"museo"` | Búsqueda de texto en título y descripción |
| `responsable` | `"responsable":"Prof. Lopez"` | Solo entradas de ese responsable |
| `fecha` | `"fecha":"07/04/2026"` | Solo entradas de ese día (formato DD/MM/YYYY) |

Ejemplo con filtro:
```
curl -X POST http://localhost:5678/webhook/diario-actividad -H "Content-Type: application/json" -d "{\"accion\":\"consultar\",\"buscar\":\"museo\"}"
```

#### Ver resumen estadístico

```
curl -X POST http://localhost:5678/webhook/diario-actividad -H "Content-Type: application/json" -d "{\"accion\":\"resumen\"}"
```

Devuelve: total de entradas, desglose por tipo, entradas de los últimos 7 días y las 5 más recientes.

#### Borrar todos los datos (cuidado)

```
curl -X POST http://localhost:5678/webhook/diario-actividad -H "Content-Type: application/json" -d "{\"accion\":\"borrar_todo\",\"confirmar\":true}"
```

---

## Workflows Online (01-15)

Estos workflows necesitan **conexión a Internet** y tener configuradas las credenciales de Google Sheets y/o SMTP en n8n.

### Configuración previa (una sola vez)

#### Configurar credenciales de Google Sheets

1. En n8n, ve a **Settings > Credentials > Add Credential**
2. Busca **"Google Sheets API"** (o "Google Sheets OAuth2")
3. Sigue las instrucciones para conectar tu cuenta de Google
4. Una vez conectada, todos los workflows que usen Google Sheets podrán acceder a tus hojas de cálculo

#### Configurar credenciales SMTP (para enviar emails)

1. En n8n, ve a **Settings > Credentials > Add Credential**
2. Busca **"SMTP"**
3. Rellena los datos de tu servidor de correo:
   - **Gmail:** Host `smtp.gmail.com`, Puerto `465`, SSL activado, usuario y contraseña de aplicación
   - **Outlook:** Host `smtp.office365.com`, Puerto `587`, STARTTLS activado
4. Para Gmail necesitas una [contraseña de aplicación](https://myaccount.google.com/apppasswords), no la contraseña normal

> **Importante:** Dentro de cada workflow, los nodos de Google Sheets y Send Email tienen una credencial asignada. Si al importar el workflow aparece un error de credenciales, haz click en el nodo, selecciona tu credencial configurada y guarda.

---

### 01 - Email Masivo a Padres/Tutores

**Trigger:** Manual (botón "Execute" en n8n)
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

Crea una hoja de Google Sheets con estas columnas (exactamente estos nombres):

| nombre_alumno | email_padre | curso |
|---------------|-------------|-------|
| Maria Garcia | familia.garcia@email.com | 2ESO-A |
| Carlos Lopez | familia.lopez@email.com | 3ESO-B |

#### Cómo usarlo

1. Abre el workflow 01 en n8n
2. En el nodo "Leer Lista de Padres", configura la URL de tu hoja de Google Sheets
3. Haz click en **"Execute Workflow"** (botón de play)
4. El workflow lee la hoja, filtra las filas sin email, y envía un email personalizado a cada familia

---

### 02 - Recogida de Google Forms a Hoja de Cálculo

**Trigger:** Webhook POST `/webhook/formulario-educativo`
**Requiere:** Google Sheets + SMTP

#### Configuración

1. Crea un Google Form para recoger respuestas
2. En el editor del Form, ve a **Extensions > Apps Script**
3. Añade un script que envíe las respuestas al webhook:
   ```javascript
   function onFormSubmit(e) {
     var respuestas = e.response.getItemResponses();
     UrlFetchApp.fetch("http://TU-IP:5678/webhook/formulario-educativo", {
       method: "post",
       contentType: "application/json",
       payload: JSON.stringify({
         nombre: respuestas[0].getResponse(),
         email: respuestas[1].getResponse(),
         mensaje: respuestas[2].getResponse()
       })
     });
   }
   ```
4. Configura un trigger "On form submit" en Apps Script

> **Nota:** Para que el webhook sea accesible desde Internet, n8n debe estar expuesto (no solo en localhost). Esto solo funciona si el equipo tiene IP pública o usas un túnel como ngrok.

---

### 03 - Recordatorio Semanal de Reuniones

**Trigger:** Automático cada lunes a las 9:00
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

| fecha | hora | tipo_reunion | asistentes | ubicacion |
|-------|------|-------------|------------|-----------|
| 07/04/2026 | 10:00 | claustro | Todo el profesorado | Salon de actos |
| 09/04/2026 | 16:00 | tutoria | Tutores 2ESO | Aula 201 |

#### Cómo usarlo

1. Rellena la hoja con las reuniones del mes (fechas en formato DD/MM/YYYY)
2. Configura el nodo de Google Sheets con la URL de tu hoja
3. Cambia el email de destino en el nodo "Enviar Email" por el email real del equipo educativo
4. **Activa el workflow** (interruptor verde) — se ejecutará solo cada lunes

---

### 04 - Control de Asistencia Diario

**Trigger:** Webhook POST `/webhook/asistencia`
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

Crea una hoja vacía con las columnas: `alumno`, `curso`, `presente`, `motivo_ausencia`, `fecha`, `hora` (el workflow las rellena automáticamente).

#### Registrar asistencia

**Windows:**
```
curl -X POST http://localhost:5678/webhook/asistencia -H "Content-Type: application/json" -d "{\"alumno\":\"Maria Garcia\",\"curso\":\"2ESO-A\",\"presente\":false,\"motivo_ausencia\":\"Cita medica\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/asistencia \
  -H "Content-Type: application/json" \
  -d '{"alumno":"Maria Garcia","curso":"2ESO-A","presente":false,"motivo_ausencia":"Cita medica"}'
```

**Campos:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `alumno` | texto | Sí | Nombre del alumno |
| `curso` | texto | Sí | Curso y grupo |
| `presente` | booleano | Sí | `true` o `false` |
| `motivo_ausencia` | texto | No | Solo si `presente` es `false` |

Si el alumno está ausente, se envía automáticamente un email a la familia.

---

### 05 - Consolidar Notas del Trimestre

**Trigger:** Manual (botón "Execute" en n8n)
**Requiere:** Google Sheets + SMTP

#### Preparar las hojas de cálculo

Necesitas una hoja por asignatura con las columnas:

| alumno | nota_examen | nota_trabajo | nota_participacion |
|--------|-------------|--------------|-------------------|
| Maria Garcia | 7.5 | 8 | 9 |
| Carlos Lopez | 6 | 7 | 6.5 |

#### Cómo usarlo

1. Configura los nodos de lectura de Google Sheets con las URLs de cada hoja de asignatura
2. Ajusta las ponderaciones si es necesario (por defecto: 50% examen, 30% trabajo, 20% participación)
3. Ejecuta manualmente al final del trimestre
4. El workflow genera una hoja consolidada con media, calificación (Insuficiente a Sobresaliente) y si está aprobado

---

### 06 - Informe Mensual de Asistencia

**Trigger:** Automático el día 1 de cada mes a las 8:00
**Requiere:** Google Sheets + SMTP

#### Configuración

1. Vincula la hoja de asistencia del workflow 04 (usa los mismos datos)
2. Cambia el email de destino por el de dirección del centro
3. **Activa el workflow**

El informe incluye: porcentaje de asistencia por alumno, alertas para alumnos con más de 3 ausencias en el mes, y se envía automáticamente a dirección.

---

### 07 - Backup Automático de Datos

**Trigger:** Automático cada día a las 2:00 AM
**Requiere:** API de n8n + Google Drive

#### Configuración

1. En n8n, ve a **Settings > API** y genera una clave API
2. Configura las credenciales de Google Drive en n8n
3. Crea una carpeta en Google Drive para los backups
4. En el nodo "Subir Backup a Drive", pega el ID de la carpeta (lo encuentras en la URL de Google Drive después de `/folders/`)
5. **Activa el workflow**

El workflow exporta todos los workflows como un archivo JSON y lo sube a Google Drive cada noche. Nombre del archivo: `backup-n8n-YYYY-MM-DD.json`.

---

### 08 - Recordatorio de Entregas y Exámenes

**Trigger:** Automático de lunes a viernes a las 8:00
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

| fecha | tipo | asignatura | curso | descripcion | email_grupo |
|-------|------|-----------|-------|-------------|-------------|
| 10/04/2026 | examen | Matematicas | 3ESO-A | Tema 5: Ecuaciones | grupo.3eso-a@centro.edu |
| 12/04/2026 | entrega | Ingles | 4ESO-B | Trabajo sobre Shakespeare | grupo.4eso-b@centro.edu |

#### Cómo usarlo

1. Rellena la hoja con las fechas de exámenes y entregas
2. Configura los nodos de Google Sheets y SMTP
3. **Activa el workflow**

El workflow revisa cada mañana si hay eventos en los próximos 3 días y envía recordatorios con urgencia: **HOY**, **MAÑANA** o **En X días**.

---

### 09 - Gestión de Inventario TIC

**Trigger:** Webhook POST `/webhook/inventario-tic`
**Requiere:** Google Sheets + (opcionalmente SMTP)

Similar al workflow 19 (offline) pero registra los datos en Google Sheets en vez de SQLite.

#### Prestar/devolver equipo

```
curl -X POST http://localhost:5678/webhook/inventario-tic -H "Content-Type: application/json" -d "{\"accion\":\"prestar\",\"equipo\":\"PORTATIL-012\",\"profesor\":\"Garcia\"}"
```

```
curl -X POST http://localhost:5678/webhook/inventario-tic -H "Content-Type: application/json" -d "{\"accion\":\"devolver\",\"equipo\":\"PORTATIL-012\"}"
```

**Campos:** Misma estructura que el workflow 19 (ver arriba).

#### Preparar la hoja de cálculo

Columnas: `equipo`, `tipo`, `estado`, `profesor`, `fecha_prestamo`, `fecha_devolucion`

---

### 10 - Notificación de Cumpleaños de Alumnos

**Trigger:** Automático de lunes a viernes a las 8:30
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

| nombre_alumno | fecha_nacimiento | curso | email_tutor |
|---------------|-----------------|-------|-------------|
| Maria Garcia | 07/04/2012 | 2ESO-A | tutor.2eso-a@centro.edu |
| Carlos Lopez | 15/06/2011 | 3ESO-B | tutor.3eso-b@centro.edu |

#### Cómo usarlo

1. Rellena la hoja con los datos de todos los alumnos (fechas en DD/MM/YYYY)
2. Configura los nodos de Google Sheets y SMTP
3. **Activa el workflow** — cada mañana comprueba si alguien cumple años y avisa al tutor

---

### 11 - Alerta de Absentismo Acumulado

**Trigger:** Automático cada viernes a las 14:00
**Requiere:** Google Sheets + SMTP

#### Configuración

1. Usa la misma hoja de asistencia del workflow 04
2. Cambia el email de destino por el del jefe de estudios
3. **Activa el workflow**

Cada viernes revisa las ausencias del mes en curso. Si un alumno tiene 3 o más ausencias, envía una alerta al jefe de estudios con nombres, número de faltas y porcentaje de asistencia.

---

### 12 - Boletín Semanal para Familias

**Trigger:** Automático cada viernes a las 16:00
**Requiere:** Google Sheets + SMTP

#### Preparar la hoja de cálculo

| curso | email_grupo | eventos_semana | avisos_tutor |
|-------|-------------|----------------|-------------|
| 2ESO-A | familias.2eso-a@centro.edu | Excursión al museo el martes | Recordar traer libro de lectura |
| 3ESO-B | familias.3eso-b@centro.edu | Examen de mates el jueves | Reunión de padres el viernes |

#### Cómo usarlo

1. Los tutores actualizan la hoja cada semana con los eventos y avisos
2. **Activa el workflow** — cada viernes a las 16:00 envía el boletín a cada grupo

---

### 13 - Solicitud de Material y Recursos

**Trigger:** Webhook POST `/webhook/solicitud-material`
**Requiere:** Google Sheets + SMTP

#### Solicitar material

**Windows:**
```
curl -X POST http://localhost:5678/webhook/solicitud-material -H "Content-Type: application/json" -d "{\"profesor\":\"Garcia\",\"tipo\":\"fotocopias\",\"descripcion\":\"50 copias del examen de Tema 5\",\"urgencia\":\"media\"}"
```

**Linux/macOS:**
```bash
curl -X POST http://localhost:5678/webhook/solicitud-material \
  -H "Content-Type: application/json" \
  -d '{"profesor":"Garcia","tipo":"fotocopias","descripcion":"50 copias del examen de Tema 5","urgencia":"media"}'
```

**Campos:**

| Campo | Tipo | Valores permitidos |
|-------|------|--------------------|
| `profesor` | texto | — |
| `tipo` | texto | `fotocopias`, `laboratorio`, `aula`, `informatica`, `otro` |
| `descripcion` | texto | Detalle de la solicitud |
| `urgencia` | texto | `baja`, `media`, `alta` |

Si la urgencia es **alta**, se envía un email inmediato al coordinador.

---

### 14 - Gestión de Guardias y Sustituciones

**Trigger:** Webhook POST `/webhook/ausencia-profesor`
**Requiere:** Google Sheets + SMTP

#### Preparar las hojas de cálculo

**Hoja "Cuadrante Guardias":**

| dia_semana | franja_horaria | profesor_guardia | email_profesor |
|------------|---------------|-----------------|----------------|
| lunes | 1a | Prof. Lopez | lopez@centro.edu |
| lunes | 2a | Prof. Martinez | martinez@centro.edu |

**Hoja "Ausencias":** Se rellena automáticamente.

#### Comunicar una ausencia

**Windows:**
```
curl -X POST http://localhost:5678/webhook/ausencia-profesor -H "Content-Type: application/json" -d "{\"profesor\":\"Garcia\",\"motivo\":\"Cita medica\",\"franja_horaria\":\"2a\"}"
```

**Campos:**

| Campo | Tipo | Valores permitidos |
|-------|------|--------------------|
| `profesor` | texto | Nombre del profesor ausente |
| `motivo` | texto | Razón de la ausencia |
| `franja_horaria` | texto | `1a`, `2a`, `3a`, `4a`, `5a`, `6a` |

El workflow busca automáticamente un profesor de guardia disponible para esa franja y le envía un email. Si no hay sustituto, avisa a jefatura de estudios.

---

### 15 - Encuesta de Satisfacción Automatizada

**Trigger:** Automático el día 1 de cada mes a las 10:00
**Requiere:** Google Sheets + SMTP + Google Forms

#### Configuración

1. Crea un Google Form con las preguntas de la encuesta
2. Copia el enlace del formulario
3. En n8n, abre el workflow 15 y en el nodo "Componer Email", cambia la URL del formulario por la tuya
4. Prepara la hoja de familias:

| nombre_familia | email | curso |
|---------------|-------|-------|
| Familia Garcia | garcia@email.com | 2ESO-A |
| Familia Lopez | lopez@email.com | 3ESO-B |

5. **Activa el workflow** — cada mes envía el enlace de la encuesta a todas las familias con email

---

## Workflow 22 - Convertidor Excel Masivo

**Trigger:** Manual (botón "Execute" en n8n)
**Modo:** Offline — sin Internet, sin credenciales
**Formatos de entrada:** `.xls` `.xlsm` `.xlsb` `.csv`
**Formato de salida:** `.xlsx`

### Antes de usarlo (una sola vez)

Asegúrate de que tu `.env` contiene:
```
NODE_FUNCTION_ALLOW_EXTERNAL=xlsx
```
Esta línea ya está en `.env.example`. Si copiaste el `.env` antes de instalar este workflow, añádela manualmente y reinicia n8n (`scripts/stop.bat` → `scripts/start.bat`).

### Cómo usarlo

1. Copia los archivos a convertir en la carpeta de entrada del host:
   ```
   data\conversion\input\
   ```
   (relativo a la raíz del proyecto / USB)

2. En n8n, abre el workflow **22 - Convertidor Excel Masivo**

3. Pulsa el botón **▶ Execute Workflow**

4. Cuando termine, los `.xlsx` convertidos aparecen en:
   ```
   data\conversion\output\
   ```

5. También aparece un CSV de reporte:
   ```
   data\conversion\output\REPORTE_YYYY-MM-DD.csv
   ```

### Resultado del reporte

| Columna | Descripción |
|---------|-------------|
| `archivo_origen` | Nombre del archivo original |
| `archivo_salida` | Nombre del `.xlsx` generado |
| `estado` | `ok` o `error` |
| `hojas` | Número de hojas del libro |
| `nombres_hojas` | Nombres de las hojas separados por coma |
| `tiempo_ms` | Tiempo de conversión en milisegundos |
| `error` | Mensaje de error (solo si `estado` es `error`) |

### Cambiar las rutas de entrada/salida

Las rutas por defecto son `/data/conversion/input` y `/data/conversion/output` (dentro del contenedor).
Para usar carpetas distintas, edita el nodo **"Configurar Rutas"** antes de ejecutar.

### Notas

- Los archivos con error (protegidos con contraseña, corruptos) se saltan y quedan registrados en el reporte.
- Las hojas múltiples se preservan en el `.xlsx` de salida.
- Si ya existe un `.xlsx` con el mismo nombre en la carpeta de salida, se sobreescribe.

---

## Workflow 23 - Generador de Diplomas

**Trigger:** Manual (botón "Execute" en n8n)
**Modo:** Offline para generación de archivos + SMTP para envío de emails
**Requiere:** SMTP configurado en n8n solo si se quieren enviar emails

### Preparar el Excel

Crear el archivo `data\diplomas\alumnos.xlsx` (o copiar y renombrar `data\diplomas\input\PLANTILLA.csv` como `.xlsx`).

Primera hoja con estas columnas:

| Columna | Tipo | Ejemplo | Obligatorio |
|---------|------|---------|-------------|
| `nombre_alumno` | texto | Maria Garcia Lopez | Sí |
| `curso_grado` | texto | CFGS ASIR Dual | Sí |
| `nombre_tutor` | texto | Prof. Rodriguez | Sí |
| `email_destinatario` | email | familia@email.com | No |
| `promocion` | texto | 2025-2026 | Sí |

> Si `email_destinatario` está vacío, el diploma se genera en disco pero no se envía por email.

### Configurar el nodo "Configuración"

Antes de ejecutar, ajusta los valores del nodo **Configuración** según tu centro:

| Campo | Por defecto | Descripción |
|-------|-------------|-------------|
| `nombre_centro` | Salesianos Los Boscos | Aparece en la cabecera del diploma |
| `ciudad` | Logroño | Aparece en el pie junto a la fecha |
| `fecha_graduacion` | (vacío = hoy) | Formato libre, ej: "20 de junio de 2026" |
| `email_remitente` | noreply@salesianos.edu | Email de origen del envío |

### Cómo usarlo

1. Coloca `alumnos.xlsx` en la carpeta `data\diplomas\` del proyecto
2. En n8n, abre el workflow **23 - Generador de Diplomas**
3. Ajusta el nodo **Configuración** si es necesario
4. Si vas a enviar emails, selecciona tu credencial SMTP en el nodo **Enviar Diploma**
5. Pulsa **▶ Execute Workflow**

### Resultado

Los archivos generados aparecen en:
```
data\diplomas\output\YYYY\
├── diploma_Maria_Garcia_Lopez.html   ← uno por alumno
├── diploma_Carlos_Martinez_Ruiz.html
└── TODOS.html                        ← batch para imprimir todos
```

### Imprimir todos los diplomas como PDF

1. Abre `TODOS.html` en Google Chrome
2. `Ctrl+P` → Destino: **Guardar como PDF**
3. Orientación: **Horizontal (Landscape)**
4. Márgenes: **Mínimo** o **Ninguno**
5. Guardar

Cada diploma ocupa una página A4 horizontal.

### Credencial SMTP

El nodo **Enviar Diploma** requiere una credencial SMTP. Si ya tienes una configurada para los workflows 01-15, selecciónala en el desplegable del nodo. Si no, configúrala en **Settings > Credentials > Add Credential > SMTP**.

---

## Referencia rápida de endpoints

| Workflow | Endpoint | Método |
|----------|----------|--------|
| 02 - Formulario | `/webhook/formulario-educativo` | POST |
| 04 - Asistencia | `/webhook/asistencia` | POST |
| 09 - Inventario TIC | `/webhook/inventario-tic` | POST |
| 13 - Solicitud Material | `/webhook/solicitud-material` | POST |
| 14 - Ausencia Profesor | `/webhook/ausencia-profesor` | POST |
| 16 - Notas Offline | `/webhook/calcular-notas` | POST |
| 17 - Incidencias | `/webhook/registro-incidencias` | POST |
| 18 - Contraseñas | `/webhook/generar-contrasenas` | POST |
| 19 - Préstamos | `/webhook/prestamos-offline` | POST |
| 20 - Sorteo Grupos | `/webhook/sorteo-grupos` | POST |
| 21 - Diario Actividad | `/webhook/diario-actividad` | POST |

**Todos los endpoints usan la URL base:** `http://localhost:5678`

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `Connection refused` | n8n no está corriendo | Ejecuta `scripts/start.bat` (Windows) o `scripts/start.sh` (Linux/macOS) |
| `Not found` o `404` | Workflow no activado o path incorrecto | Activa el workflow en n8n (interruptor verde). Verifica que el endpoint es correcto |
| `Internal Server Error` | Falta un campo requerido en el JSON | Revisa que el JSON incluye todos los campos requeridos del workflow |
| No se envía email | Credenciales SMTP no configuradas | Configura las credenciales SMTP en n8n (Settings > Credentials) |
| Google Sheets no funciona | Credenciales de Google no configuradas | Configura las credenciales de Google Sheets en n8n |
| `Invalid JSON` | Comillas mal escapadas | En Windows usa `\"` para las comillas dentro del JSON |
| Datos no persisten (offline) | El workflow no usa staticData | Los workflows 18 y 20 no almacenan datos (solo generan). Los demás offline sí persisten |
