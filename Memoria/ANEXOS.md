# ANEXOS

---

## Anexo A — Descripción técnica de los 23 workflows

Cada entrada incluye el trigger, los nodos principales en orden de ejecución y los campos de entrada/salida relevantes. Las instrucciones de uso con ejemplos `curl` están en `workflows/GUIA-DE-USO.md`.

---

### 01 - Email Masivo a Padres/Tutores

**Categoría:** Comunicaciones | **Trigger:** Manual

| Nodo | Tipo | Función |
|------|------|---------|
| Manual Trigger | Trigger | Inicia el workflow manualmente |
| Google Sheets | Lectura | Lee hoja con columnas: `nombre_alumno`, `email_padre`, `curso` |
| IF | Condición | Filtra filas donde `email_padre` esté vacío |
| Set | Transformación | Construye asunto (`Comunicado - {{ $json.curso }}`) y cuerpo personalizado |
| Send Email | Acción | Envía por SMTP al `email_padre` de cada fila |

**Campos requeridos en la hoja:** `nombre_alumno`, `email_padre`, `curso`

---

### 02 - Recogida Automática de Google Forms

**Categoría:** Comunicaciones | **Trigger:** Webhook POST `/formulario-educativo`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe JSON de Google Forms vía Apps Script |
| Set | Transformación | Extrae `nombre`, `email`, `mensaje`; añade `fecha` con `{{ $now.format('dd/MM/yyyy HH:mm') }}` |
| Google Sheets | Escritura | Añade fila con los datos recibidos (Append Row) |
| Send Email | Acción | Notifica al profesor con el mensaje completo |
| Respond to Webhook | Respuesta | Devuelve `{ "status": "ok" }` al remitente |

**Respuesta:** Síncrona — el formulario recibe confirmación de recepción.

---

### 03 - Recordatorio Semanal de Reuniones

**Categoría:** Gestión académica | **Trigger:** Schedule `0 9 * * 1` (lunes 9:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | Cron lunes a las 9:00 |
| Google Sheets | Lectura | Lee hoja con columnas: `fecha`, `hora`, `tipo`, `lugar`, `asistentes` |
| Code | Lógica | Filtra reuniones cuya fecha cae entre el lunes y viernes de la semana en curso |
| IF | Condición | Si no hay reuniones, termina sin enviar |
| Send Email | Acción | Envía resumen con el listado de reuniones de la semana |

---

### 04 - Control de Asistencia Diario

**Categoría:** Gestión académica | **Trigger:** Webhook POST `/asistencia`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Modo `lastNode`; la respuesta la genera el último nodo |
| Set | Transformación | Añade `fecha` y `hora` automáticos; normaliza campos |
| Google Sheets | Escritura | Registra fila con: alumno, curso, presente, motivo, fecha, hora |
| IF | Condición | Si `presente === false`, pasa a notificación |
| Send Email | Acción | Avisa a la familia solo si el alumno está ausente |
| Respond to Webhook | Respuesta | Devuelve `{ "status": "ok", "alumno": "...", "registrado": true }` |

**Payload de entrada:** `{ "alumno": "...", "curso": "...", "presente": false, "motivo": "..." }`

---

### 05 - Consolidar Notas del Trimestre

**Categoría:** Gestión académica | **Trigger:** Manual

| Nodo | Tipo | Función |
|------|------|---------|
| Manual Trigger | Trigger | Lanzamiento manual por el profesor |
| Google Sheets ×2 | Lectura | Lee en paralelo: hoja de exámenes y hoja de trabajos/participación |
| Merge | Combinación | Une ambas hojas por `nombre_alumno` (modo Combine) |
| Code | Cálculo | Media ponderada: examen×0.5 + trabajo×0.3 + participación×0.2; convierte a escala cualitativa española |
| Google Sheets | Escritura | Guarda resumen con nota numérica y calificación cualitativa |
| Send Email | Acción | Notifica al jefe de estudios que las notas están consolidadas |

**Escala:** 0-4.99 Insuficiente · 5-5.99 Suficiente · 6-6.99 Bien · 7-8.99 Notable · 9-10 Sobresaliente

---

### 06 - Informe Mensual de Asistencia

**Categoría:** Gestión académica | **Trigger:** Schedule `0 8 1 * *` (día 1 de cada mes, 8:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | El día 1 de cada mes a las 8:00 |
| Google Sheets | Lectura | Lee la misma hoja que alimenta el workflow 04 |
| Code | Procesamiento | Filtra registros del mes anterior; agrupa por alumno; calcula presencias, ausencias y porcentaje; marca con alerta a quienes superan 3 ausencias |
| Send Email | Acción | Envía informe al equipo directivo con tabla resumen |
| Google Sheets | Escritura | Archiva datos procesados en hoja histórica |

---

### 07 - Backup Automático de Datos n8n

**Categoría:** Mantenimiento | **Trigger:** Schedule `0 2 * * *` (diario 2:00 AM)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | Cada noche a las 2:00 AM |
| HTTP Request | Petición | Llama a la API interna de n8n (`/api/v1/workflows`) con API key |
| Code | Empaquetado | Genera JSON con todos los workflows + metadatos (fecha, cantidad) |
| Google Drive | Subida | Sube el archivo `backup-n8n-YYYY-MM-DD.json` a la carpeta configurada |

**Requisito:** API key generada en Settings > API de la interfaz de n8n.

---

### 08 - Recordatorio de Entregas y Exámenes

**Categoría:** Comunicaciones | **Trigger:** Schedule `0 8 * * 1-5` (L-V 8:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | Lunes a viernes a las 8:00 |
| Google Sheets | Lectura | Lee calendario con: `fecha`, `tipo`, `asignatura`, `curso`, `email_grupo` |
| Code | Filtrado | Selecciona eventos en ventana de 3 días; calcula etiqueta de urgencia ("HOY:", "MAÑANA:", "En X días:") |
| IF | Condición | Si no hay eventos próximos, termina |
| Send Email | Acción | Envía recordatorio al email de grupo del curso afectado |

---

### 09 - Gestión de Inventario TIC

**Categoría:** Gestión TIC | **Trigger:** Webhook POST `/inventario-tic`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe: `equipo`, `accion` ("prestar"/"devolver"), `profesor` |
| IF | Condición | Bifurca según valor de `accion` |
| Google Sheets (préstamo) | Escritura | Añade fila con equipo, profesor, fecha, hora y estado "prestado" |
| Google Sheets (devolución) | Escritura | Añade fila con equipo, profesor, fecha, hora y estado "disponible" |
| Code | Respuesta | Genera confirmación JSON |

Cada movimiento genera una fila independiente, lo que mantiene historial completo.

---

### 10 - Notificación de Cumpleaños de Alumnos

**Categoría:** Convivencia | **Trigger:** Schedule `30 8 * * 1-5` (L-V 8:30)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | L-V a las 8:30 |
| Google Sheets | Lectura | Lee lista con: `nombre_alumno`, `fecha_nacimiento` (DD/MM/YYYY), `curso`, `email_tutor` |
| Code | Búsqueda | Compara día y mes de nacimiento con la fecha actual; agrupa por tutor si hay varios en el mismo grupo |
| IF | Condición | Si nadie cumple hoy, termina |
| Send Email | Acción | Envía email al tutor con los alumnos que cumplen años y la edad que cumplen |

---

### 11 - Alerta de Absentismo Acumulado

**Categoría:** Alertas | **Trigger:** Schedule `0 14 * * 5` (viernes 14:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | Viernes a las 14:00 |
| Google Sheets | Lectura | Lee la misma hoja de asistencia del workflow 04 |
| Code | Análisis | Filtra registros del mes en curso; agrupa por alumno; cuenta ausencias; filtra quienes superan el umbral (3 faltas) |
| IF | Condición | Si no hay nadie en alerta, termina |
| Code | Informe | Genera tabla con alumno, ausencias y porcentaje de asistencia |
| Send Email | Acción | Envía informe al jefe de estudios |

---

### 12 - Boletín Semanal para Familias

**Categoría:** Comunicaciones | **Trigger:** Schedule `0 16 * * 5` (viernes 16:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | Viernes a las 16:00 |
| Google Sheets | Lectura | Lee hoja con una fila por curso: eventos, avisos del tutor, `email_grupo` |
| IF | Condición | Filtra cursos sin `email_grupo` configurado |
| Code | Composición | Genera cuerpo del boletín con eventos de la semana siguiente y avisos; calcula fechas automáticamente |
| Send Email | Acción | Envía boletín personalizado al email de grupo de cada curso |

---

### 13 - Solicitud de Material y Recursos

**Categoría:** Gestión de recursos | **Trigger:** Webhook POST `/solicitud-material`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe: `profesor`, `tipo`, `descripcion`, `urgencia` (baja/media/alta) |
| Set | Normalización | Añade fecha, hora y estado "pendiente" |
| Google Sheets | Escritura | Registra la solicitud en la hoja de seguimiento |
| IF | Condición | Si urgencia es "alta", pasa a notificación |
| Send Email | Acción | Avisa al coordinador solo si es urgente |
| Respond to Webhook | Respuesta | Confirma al profesor que la solicitud ha sido registrada |

---

### 14 - Gestión de Guardias y Sustituciones

**Categoría:** Gestión de personal | **Trigger:** Webhook POST `/ausencia-profesor`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe: `profesor`, `motivo`, `franja_horaria` |
| Set | Preparación | Calcula el día de la semana actual para buscar en el cuadrante |
| Google Sheets | Lectura | Lee el cuadrante de guardias del centro |
| Code | Asignación | Cruza día y franja horaria con el cuadrante para encontrar el profesor de guardia disponible |
| Google Sheets | Escritura | Registra la ausencia con el sustituto asignado |
| IF | Condición | Bifurca según si se encontró sustituto o no |
| Send Email (sustituto) | Acción | Notifica al sustituto con los detalles de la guardia |
| Send Email (jefatura) | Acción | Si no hay sustituto, avisa a jefatura |
| Respond to Webhook | Respuesta | Devuelve al profesor los datos del sustituto o el estado "sin cobertura" |

---

### 15 - Encuesta de Satisfacción Automatizada

**Categoría:** Calidad | **Trigger:** Schedule `0 10 1 * *` (día 1 de cada mes, 10:00)

| Nodo | Tipo | Función |
|------|------|---------|
| Schedule Trigger | Trigger | El día 1 de cada mes a las 10:00 |
| Google Sheets | Lectura | Lee listado de familias con emails y cursos |
| IF | Condición | Filtra familias sin email |
| Code | Composición | Genera email personalizado con enlace a Google Forms, nombre de la familia y mes |
| Send Email | Acción | Envía encuesta a cada familia |
| Google Sheets | Escritura | Registra log de envíos: fecha, familia, curso, email |

---

### 16 - Calculadora de Notas Offline

**Categoría:** Gestión académica | **Modo:** Offline | **Trigger:** Webhook POST `/calcular-notas`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Acepta dos tipos de petición: registro y consulta |
| Code | Lógica central | Lee `$getWorkflowStaticData('global')`; si es registro calcula media ponderada y guarda; si es consulta devuelve histórico filtrado por curso |
| Respond to Webhook | Respuesta | Devuelve nota calculada o listado histórico |

**Payload registro:** `{ "alumno": "...", "curso": "...", "examen": 7.5, "trabajo": 8, "participacion": 9 }`
**Payload consulta:** `{ "accion": "consultar", "curso": "2ESO-A" }`

---

### 17 - Registro de Incidencias Offline

**Categoría:** Convivencia | **Modo:** Offline | **Trigger:** Webhook POST `/registro-incidencias`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Acepta tres acciones: `registrar`, `consultar`, `resumen` |
| Code | CRUD + estadísticas | Valida tipo (`leve`, `grave`, `muy_grave`); genera ID único y timestamp; almacena en `staticData`; aplica filtros combinados; calcula estadísticas por tipo y por curso |
| Respond to Webhook | Respuesta | Devuelve resultado según acción |

**Payload registro:** `{ "alumno": "...", "curso": "...", "tipo": "leve", "descripcion": "...", "reportado_por": "..." }`

---

### 18 - Generador de Contraseñas para Alumnos

**Categoría:** Herramientas TIC | **Modo:** Offline | **Trigger:** Webhook POST `/generar-contrasenas`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe array de nombres y longitud opcional (por defecto 12) |
| Code | Generación | Crea usuario: primera letra del nombre + apellido en minúsculas sin acentos; genera contraseña aleatoria excluyendo caracteres ambiguos (0, O, l, I, 1) |
| Respond to Webhook | Respuesta | Devuelve array de pares usuario/contraseña |

No almacena datos. Las credenciales se generan, se entregan y desaparecen.

**Payload:** `{ "alumnos": ["María García", "Carlos López"], "longitud": 12 }`

---

### 19 - Control de Préstamos de Material Offline

**Categoría:** Gestión TIC | **Modo:** Offline | **Trigger:** Webhook POST `/prestamos-offline`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Acepta tres acciones: `prestar`, `devolver`, `consultar` |
| Code | Gestión | Prestar: registra préstamo con timestamp; devuelve error si ya está prestado. Devolver: marca como "devuelto". Consultar: lista préstamos activos; calcula días transcurridos; marca con `alerta: true` si superan 7 días |
| Respond to Webhook | Respuesta | Devuelve resultado de la operación |

**Payload préstamo:** `{ "accion": "prestar", "equipo": "PORTATIL-012", "profesor": "García" }`

---

### 20 - Sorteo y Asignación de Grupos

**Categoría:** Herramientas docentes | **Modo:** Offline | **Trigger:** Webhook POST `/sorteo-grupos`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Recibe array de alumnos y número de grupos (por defecto 2) |
| Code | Sorteo | Implementa Fisher-Yates shuffle (sin sesgo estadístico); distribuye alumnos con round-robin garantizando diferencia máxima de 1 entre grupos |
| Respond to Webhook | Respuesta | Devuelve grupos formados con sus miembros |

No persiste datos. Cada ejecución es un sorteo independiente.

**Payload:** `{ "alumnos": ["María", "Carlos", "Ana", "Pedro"], "num_grupos": 2 }`

---

### 21 - Diario de Actividad del Centro

**Categoría:** Administración | **Modo:** Offline | **Trigger:** Webhook POST `/diario-actividad`

| Nodo | Tipo | Función |
|------|------|---------|
| Webhook | Trigger | Acepta tres acciones: `registrar`, `consultar`, `resumen` |
| Code | Diario | Registrar: almacena entrada con tipo, título, descripción, responsable y timestamp. Consultar: filtra por tipo, rango de fechas o búsqueda de texto libre (case-insensitive). Resumen: total de entradas, desglose por tipo, entradas de los últimos 7 y 30 días, 5 más recientes |
| Respond to Webhook | Respuesta | Devuelve resultado según acción |

**Tipos válidos:** `evento`, `incidencia`, `logro`, `recordatorio`, `acta`

---

### 22 - Convertidor Excel Masivo

**Categoría:** Herramientas TIC | **Modo:** Offline | **Trigger:** Manual

| Nodo | Tipo | Función |
|------|------|---------|
| Manual Trigger | Trigger | Lanzamiento manual tras colocar archivos en la carpeta de entrada |
| Set | Configuración | Define rutas: entrada `/data/conversion/input`, salida `/data/conversion/output` |
| Code (Convertir) | Procesamiento | Lee directorio con `fs.readdirSync`; filtra `.xls`, `.xlsm`, `.xlsb`, `.csv`; convierte cada archivo con `XLSX.readFile` / `XLSX.writeFile`; captura errores individuales sin abortar el lote |
| Code (Reporte) | Informe | Genera `REPORTE_YYYY-MM-DD.csv` con: nombre, estado, número de hojas y tiempo de conversión por archivo |

**Formatos de entrada:** `.xls`, `.xlsm`, `.xlsb`, `.csv`
**Salida:** Archivos `.xlsx` + `REPORTE_YYYY-MM-DD.csv`

---

### 23 - Generador de Diplomas de Graduación

**Categoría:** Herramientas docentes | **Modo:** Offline + SMTP opcional | **Trigger:** Manual

| Nodo | Tipo | Función |
|------|------|---------|
| Manual Trigger | Trigger | Lanzamiento manual |
| Set (Configuración) | Parámetros | Define: nombre del centro, ciudad, fecha de graduación, email remitente. Solo hay que editar este nodo para adaptar los diplomas a otra promoción |
| Code (Generar Diplomas) | Generación | Lee `alumnos.xlsx` con SheetJS; lee `logo.png` y lo codifica en Base64; genera HTML de cada diploma con tema visual Salesianos (rojo `#CC1C1C`, gris `#5C6770`, Georgia, fondo crema); escribe archivos individuales en `data/diplomas/output/YYYY/` y un `TODOS.html` para impresión de toda la promoción |
| IF | Condición | Filtra alumnos que tienen `email_destinatario` en el Excel |
| Send Email | Envío opcional | Adjunta el diploma HTML al email del destinatario |
| Code (Resumen) | Informe | Genera resumen de ejecución: diplomas generados, enviados, ruta a `TODOS.html` |

**Campos Excel requeridos:** `nombre_alumno`, `curso`, `tutor`
**Campos opcionales:** `email_destinatario` (activa el envío por correo)
**Impresión:** Abrir `TODOS.html` en Chrome → `Ctrl+P` → Guardar como PDF → Orientación horizontal A4

---

## Anexo B — Tabla completa de pruebas (51 pruebas)

### Infraestructura (6 pruebas)

| # | Prueba | Entrada | Salida esperada | Resultado |
|---|--------|---------|-----------------|-----------|
| 1 | Arranque en Windows con `start.bat` | Ejecución del script en Windows 11 con Docker Desktop instalado | n8n disponible en `http://localhost:5678` | n8n operativo en menos de 30s. El script creó `.env` desde `.env.example` automáticamente | Correcto |
| 2 | Arranque en Linux con `start.sh` | Ejecución del script en Ubuntu 22.04 con Docker instalado | n8n disponible en `http://localhost:5678` | n8n operativo. El script detectó el sistema operativo correctamente | Correcto |
| 3 | Parada limpia con `stop.bat` | n8n en ejecución; ejecutar `stop.bat` | El contenedor se detiene sin errores | El contenedor se detuvo limpiamente. `docker ps` confirmó que no había contenedores activos | Correcto |
| 4 | Persistencia tras reinicio | Registrar datos en workflows offline; parar con `stop.bat`; arrancar con `start.bat`; consultar datos | Los datos siguen disponibles tras el reinicio | Todos los datos (notas, incidencias, préstamos, diario) estaban disponibles tras reiniciar. SQLite los conserva en `n8n-data/` | Correcto |
| 5 | Portabilidad USB | Copiar carpeta del proyecto a un USB; conectarlo a otro equipo con Docker; ejecutar `start.bat` | n8n arranca con los mismos workflows y datos | n8n arrancó correctamente en el segundo equipo con todos los workflows y datos intactos | Correcto |
| 6 | USB extraído en caliente | Arrancar n8n desde USB; extraer el USB sin "Expulsar" mientras n8n está corriendo | El contenedor se detiene; al reconectar y arrancar, los datos persisten | El contenedor se detuvo con errores de lectura. Al reconectar el USB y arrancar, los datos se conservaron hasta el momento de la extracción sin corrupción | Correcto |

### Workflows online 01-15 (18 pruebas)

| # | Prueba | Workflow | Entrada | Salida esperada | Resultado |
|---|--------|---------|---------|-----------------|-----------|
| 7 | Email masivo enviado | Email Masivo (01) | Hoja con 3 familias, todas con email | Se envían 3 emails personalizados con nombre del alumno y curso | Los 3 emails llegaron con el asunto y cuerpo correctamente personalizados | Correcto |
| 8 | Fila sin email filtrada | Email Masivo (01) | Hoja con 4 familias, una sin `email_padre` | Se envían 3 emails; la fila sin email se omite sin error | El nodo IF filtró correctamente la fila vacía. No se intentó enviar a dirección vacía | Correcto |
| 9 | Formulario recibido y guardado | Google Forms (02) | POST al webhook con `{ "nombre": "Ana", "email": "ana@test.es", "mensaje": "Consulta" }` | Se archiva en Sheets y se notifica al profesor | La fila se añadió a la hoja con fecha automática. El profesor recibió el email con el mensaje | Correcto |
| 10 | Recordatorio semanal con reuniones | Reuniones (03) | Hoja con 2 reuniones en la semana en curso | Email con el listado de las 2 reuniones | El email llegó con fecha, hora, tipo y lugar de cada reunión | Correcto |
| 11 | Semana sin reuniones — no envía | Reuniones (03) | Hoja con reuniones en fechas fuera de la semana actual | No se envía ningún email | El workflow terminó en el nodo IF sin enviar nada | Correcto |
| 12 | Asistencia presente registrada | Asistencia (04) | POST con `{ "alumno": "Pedro", "curso": "1ESO-A", "presente": true }` | Se registra en Sheets; no se envía email | La fila se añadió con estado "presente". No se envió email a la familia | Correcto |
| 13 | Asistencia ausente — notificación | Asistencia (04) | POST con `{ "alumno": "Pedro", "curso": "1ESO-A", "presente": false, "motivo": "Enfermedad" }` | Se registra en Sheets y se envía email a la familia | La fila se registró y la familia recibió el email con el motivo incluido | Correcto |
| 14 | Notas consolidadas con media ponderada | Consolidar Notas (05) | Dos hojas con examen (7.5), trabajo (8) y participación (9) para María García | Media correcta (7.95) y calificación "Notable" | La media se calculó correctamente. La hoja de resumen recibió la fila con todos los campos | Correcto |
| 15 | Informe mensual de asistencia | Informe Asistencia (06) | Hoja de asistencia con 20 registros del mes anterior; 2 alumnos con 4 ausencias | Informe con tabla de alumnos y 2 marcados como alerta | El informe llegó al equipo directivo con los 2 alumnos en alerta resaltados | Correcto |
| 16 | Backup automático exportado | Backup (07) | Ejecución manual del workflow con 21 workflows configurados en n8n | Archivo `backup-n8n-YYYY-MM-DD.json` subido a Google Drive | El archivo apareció en la carpeta de Google Drive con todos los workflows empaquetados | Correcto |
| 17 | Recordatorio dentro de ventana | Entregas y Exámenes (08) | Calendario con examen mañana y entrega en 5 días | Solo se envía el recordatorio del examen de mañana | Email enviado con etiqueta "MAÑANA" en el asunto. El evento de 5 días no generó notificación | Correcto |
| 18 | Sin eventos próximos — no envía | Entregas y Exámenes (08) | Calendario con todos los eventos en fechas posteriores a 3 días | No se envía ningún email | El workflow terminó en el nodo IF sin enviar nada | Correcto |
| 19 | Préstamo de equipo registrado | Inventario TIC (09) | POST con `{ "equipo": "PORTATIL-012", "accion": "prestar", "profesor": "García" }` | Fila añadida en Sheets con estado "prestado" | La fila se añadió con fecha, hora y estado correcto. El webhook devolvió confirmación JSON | Correcto |
| 20 | Devolución de equipo registrada | Inventario TIC (09) | POST con `{ "equipo": "PORTATIL-012", "accion": "devolver", "profesor": "García" }` | Nueva fila con estado "disponible"; historial anterior conservado | La fila de devolución se añadió correctamente. El préstamo anterior seguía en la hoja | Correcto |
| 21 | Cumpleaños detectado | Cumpleaños (10) | Hoja con un alumno cuya fecha de nacimiento coincide con hoy | Email al tutor informando del cumpleaños y la edad | El tutor recibió el email con el nombre del alumno y la edad que cumple | Correcto |
| 22 | Día sin cumpleaños — no envía | Cumpleaños (10) | Hoja con alumnos sin cumpleaños hoy | No se envía ningún email | El workflow terminó en el nodo IF sin enviar nada | Correcto |
| 23 | Alerta de absentismo enviada | Alerta Absentismo (11) | Hoja con 2 alumnos con 4 y 5 ausencias en el mes, resto con 1-2 | Alerta solo con los 2 alumnos que superan el umbral de 3 | El informe listó los 2 alumnos ordenados por número de faltas con porcentaje correcto | Correcto |
| 24 | Sin absentismo — no envía | Alerta Absentismo (11) | Hoja con todos los alumnos con 3 o menos ausencias | No se envía ningún email | El workflow terminó sin enviar. Confirmado en el historial de ejecuciones de n8n | Correcto |

### Workflows offline 16-21 (14 pruebas)

| # | Prueba | Workflow | Entrada | Salida esperada | Resultado |
|---|--------|---------|---------|-----------------|-----------|
| 25 | Registrar notas de un alumno | Calculadora (16) | POST `{ "alumno": "María García", "curso": "2ESO-A", "examen": 7.5, "trabajo": 8, "participacion": 9 }` | Media 7.95, calificación "Notable", guardado en staticData | Media correcta (7.95), calificación "Notable". Registro almacenado con timestamp | Correcto |
| 26 | Consultar histórico de notas | Calculadora (16) | POST `{ "accion": "consultar", "curso": "2ESO-A" }` | Listado de notas del curso | Devolvió el registro de María García con todos los campos incluyendo fecha de registro | Correcto |
| 27 | Consultar curso sin registros | Calculadora (16) | POST `{ "accion": "consultar", "curso": "4ESO-B" }` (sin datos) | Array vacío sin errores | Devolvió `{ "registros": [], "total": 0 }` sin error | Correcto |
| 28 | Registrar incidencia | Incidencias (17) | POST `{ "alumno": "Carlos López", "curso": "3ESO-B", "tipo": "leve", "descripcion": "Uso del móvil en clase", "reportado_por": "Prof. Martínez" }` | Incidencia guardada con ID y timestamp | Incidencia registrada con ID único y fecha/hora automáticos | Correcto |
| 29 | Tipo de incidencia inválido | Incidencias (17) | POST `{ "tipo": "moderada" }` | Error con tipos válidos | Error: `"Tipo no válido. Use: leve, grave, muy_grave"` | Correcto |
| 30 | Resumen estadístico de incidencias | Incidencias (17) | POST `{ "accion": "resumen" }` tras registrar 5 incidencias | Desglose por tipo y por curso | Resumen: 3 leves (60%), 1 grave (20%), 1 muy grave (20%), desglose por curso correcto | Correcto |
| 31 | Generar contraseñas | Contraseñas (18) | POST `{ "alumnos": ["María García", "Carlos López", "Ana Martínez"], "longitud": 12 }` | 3 pares usuario/contraseña | 3 credenciales: mgarcia, clopez, amartinez; contraseñas de 12 caracteres con mayúsculas, minúsculas, números y símbolos | Correcto |
| 32 | Sin caracteres ambiguos | Contraseñas (18) | POST `{ "alumnos": ["Test User"], "longitud": 50 }` | Ninguna contraseña contiene 0, O, l, I, 1 | Verificado manualmente: ningún carácter ambiguo en la contraseña generada | Correcto |
| 33 | Prestar un equipo | Préstamos (19) | POST `{ "accion": "prestar", "equipo": "PORTATIL-012", "profesor": "García" }` | Préstamo registrado con timestamp | Préstamo registrado correctamente. La respuesta confirmó la operación | Correcto |
| 34 | Prestar equipo ya prestado | Préstamos (19) | POST con el mismo equipo sin devolver | Error indicando que está prestado | Error: `"El equipo PORTATIL-012 ya está prestado a García"` | Correcto |
| 35 | Devolver equipo | Préstamos (19) | POST `{ "accion": "devolver", "equipo": "PORTATIL-012" }` | Préstamo marcado como devuelto | Préstamo actualizado a "devuelto" con fecha. Equipo disponible para nuevos préstamos | Correcto |
| 36 | Sortear 6 alumnos en 3 grupos | Sorteo (20) | POST `{ "alumnos": ["María", "Carlos", "Ana", "Pedro", "Lucía", "Jorge"], "num_grupos": 3 }` | 3 grupos de 2 alumnos | 3 grupos equilibrados (2 alumnos cada uno). Distribución cambia en cada ejecución | Correcto |
| 37 | Sorteo con número impar | Sorteo (20) | POST con 7 alumnos y 3 grupos | Grupos equilibrados con diferencia máxima de 1 alumno | Grupos de 3, 2 y 2 alumnos. Diferencia máxima: 1 alumno | Correcto |
| 38 | Búsqueda de texto en el diario | Diario (21) | POST `{ "accion": "consultar", "buscar": "museo" }` tras registrar excursión al Museo de Ciencias | Entradas que contienen "museo" | Encontró la excursión. Búsqueda case-insensitive: "museo" encontró "Museo" | Correcto |

### Herramientas de productividad 22-23 (9 pruebas)

| # | Prueba | Workflow | Entrada | Salida esperada | Resultado |
|---|--------|---------|---------|-----------------|-----------|
| 39 | Conversión de lote mixto | Excel Masivo (22) | Carpeta con 3 archivos: un `.xls`, un `.xlsm` y un `.csv` | 3 archivos `.xlsx` y reporte CSV con estado `ok` | Los 3 archivos se convirtieron correctamente. El reporte CSV recogió nombre, hojas y tiempo de conversión | Correcto |
| 40 | Archivo protegido con contraseña | Excel Masivo (22) | Lote con 2 archivos normales y 1 `.xls` protegido | 2 convertidos; el protegido aparece con `estado: error` | Los 2 archivos normales se convirtieron. El protegido apareció con `estado: error` y mensaje de SheetJS. El workflow no se interrumpió | Correcto |
| 41 | Carpeta de entrada vacía | Excel Masivo (22) | Ejecutar con la carpeta `input/` vacía | Reporte CSV vacío sin errores | El reporte se generó con cabecera pero sin filas. Sin errores | Correcto |
| 42 | Hojas múltiples preservadas | Excel Masivo (22) | Archivo `.xls` con 3 hojas de datos | `.xlsx` generado con 3 hojas intactas | El `.xlsx` resultante contenía las 3 hojas con todos los datos correctos | Correcto |
| 43 | Generar diplomas desde Excel | Diplomas (23) | Excel con 5 alumnos (todos los campos rellenos) | 5 archivos HTML individuales y un `TODOS.html` en `output/2026/` | Se generaron los 5 diplomas individuales y el archivo batch. Cada HTML incluía nombre, curso, tutor y fecha correctos | Correcto |
| 44 | Logo embebido en el diploma | Diplomas (23) | Excel con 1 alumno; `logo.png` presente en `data/diplomas/` | HTML con logo en Base64, visible sin conexión | Logo visible sin conexión. Al inspeccionar el código, el `src` era una cadena Base64 | Correcto |
| 45 | Alumno sin email — solo genera archivo | Diplomas (23) | Excel con 1 alumno sin campo `email_destinatario` | Diploma HTML generado en disco; no se intenta enviar email | Diploma generado. El nodo IF filtró la fila correctamente y no se ejecutó el nodo de envío | Correcto |
| 46 | Alumno con email — envío por correo | Diplomas (23) | Excel con 1 alumno con email válido; credencial SMTP configurada | Diploma generado y enviado como adjunto HTML | El diploma llegó a la bandeja con el archivo `.html` adjunto y el nombre del alumno en el cuerpo | Correcto |
| 47 | Excel sin columnas requeridas | Diplomas (23) | Excel con columnas con nombres incorrectos (sin `nombre_alumno`) | Error descriptivo | n8n lanzó error en el nodo Code indicando que no se encontraron filas válidas. Mensaje legible | Correcto |

### Errores y casos límite de infraestructura (4 pruebas)

| # | Prueba | Entrada | Salida esperada | Resultado |
|---|--------|---------|-----------------|-----------|
| 48 | Puerto 5678 ocupado por otra aplicación | Puerto 5678 en uso al arrancar Docker | Error claro con instrucción de solución | Docker mostró `Bind for 0.0.0.0:5678 failed: port is already allocated`. Documentado en GUIA-DE-USO.md: cambiar `N8N_PORT` en `.env` | Correcto |
| 49 | Credencial SMTP incorrecta | Workflow con envío de email; credencial SMTP con contraseña errónea | Error en el nodo Send Email con mensaje descriptivo | n8n mostró el error de autenticación SMTP en el nodo correspondiente. El resto del workflow se ejecutó hasta ese punto | Correcto |
| 50 | Sin conexión a Internet | WiFi desconectado; ejecutar workflow online (01) y workflow offline (16) | Online falla con error de conexión; offline responde normalmente | WF01 falló con error en el nodo Google Sheets. WF16 respondió con normalidad. Al restaurar el WiFi, WF01 funcionó sin problema | Correcto |
| 51 | Docker no instalado (simulado) | Ejecutar `start.bat` en un equipo sin Docker | El script intenta instalar Docker automáticamente | El script detectó que Docker no estaba instalado e intentó instalarlo vía `winget`. Con conexión a Internet, la instalación se completó y n8n arrancó | Correcto |
