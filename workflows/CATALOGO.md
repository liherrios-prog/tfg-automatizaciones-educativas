# Catalogo de Workflows

> Referencia completa de los 23 workflows incluidos en el proyecto. Organizados por categoria y modo de funcionamiento.

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Total de workflows | 23 |
| Workflows online (requieren Internet) | 15 |
| Workflows offline (funcionan sin Internet) | 6 |
| Herramientas de utilidad | 2 |
| Categorias cubiertas | 8 |
| Tipos de trigger | 4 (webhook, manual, programado, schedule) |

---

## Clasificacion por modo de funcionamiento

### Workflows OFFLINE (sin Internet)

Estos workflows funcionan completamente sin conexion a Internet. Utilizan la base de datos interna de n8n (SQLite) para almacenar datos, lo que garantiza la portabilidad total del sistema en USB.

| # | Workflow | Categoria | Trigger | Endpoint | Descripcion |
|---|---------|-----------|---------|----------|-------------|
| 16 | Calculadora de Notas | Gestion academica | Webhook | POST /calcular-notas | Calcula medias ponderadas, almacena historico de notas |
| 17 | Registro de Incidencias | Convivencia | Webhook | POST /registro-incidencias | Registra y consulta incidencias con filtros y resumen estadistico |
| 18 | Generador de Contrasenas | Herramientas TIC | Webhook | POST /generar-contrasenas | Genera usuarios y contrasenas seguras para listas de alumnos |
| 19 | Control de Prestamos | Gestion TIC | Webhook | POST /prestamos-offline | Gestiona prestamos/devoluciones de equipos con alertas de retraso |
| 20 | Sorteo de Grupos | Herramientas docentes | Webhook | POST /sorteo-grupos | Reparte alumnos en grupos aleatorios equilibrados (Fisher-Yates) |
| 21 | Diario de Actividad | Administracion | Webhook | POST /diario-actividad | Libro de registro digital del centro con busqueda y resumenes |

**Tecnologia clave:** `$getWorkflowStaticData('global')` — API nativa de n8n que persiste datos en la base SQLite del contenedor. Los datos viajan con el USB sin dependencias externas.

### Workflows ONLINE (requieren Internet)

Estos workflows dependen de Google Sheets para almacenar datos y/o de SMTP para enviar notificaciones por email. Requieren credenciales de Google y un servidor de correo configurados.

| # | Workflow | Categoria | Trigger | Dependencias | Descripcion |
|---|---------|-----------|---------|-------------|-------------|
| 01 | Email Masivo a Padres | Comunicaciones | Manual | Google Sheets, SMTP | Envia comunicados personalizados a familias desde una hoja de calculo |
| 02 | Recogida de Google Forms | Comunicaciones | Webhook | Google Sheets, SMTP | Centraliza respuestas de formularios y notifica al profesor |
| 03 | Recordatorio de Reuniones | Gestion academica | Programado (L 9:00) | Google Sheets, SMTP | Resumen semanal de reuniones cada lunes |
| 04 | Control de Asistencia | Gestion academica | Webhook | Google Sheets, SMTP | Registra asistencia y notifica ausencias a familias |
| 05 | Consolidar Notas | Gestion academica | Manual | Google Sheets, SMTP | Calcula medias ponderadas y genera informe trimestral |
| 06 | Informe de Asistencia | Gestion academica | Programado (1/mes 8:00) | Google Sheets, SMTP | Genera estadisticas mensuales de asistencia por alumno |
| 07 | Backup Automatico | Mantenimiento | Programado (diario 2:00) | API n8n local, Google Drive | Copia de seguridad diaria de workflows a Google Drive |
| 08 | Recordatorio Entregas | Comunicaciones | Programado (L-V 8:00) | Google Sheets, SMTP | Avisa de examenes y entregas en los proximos 3 dias |
| 09 | Inventario TIC | Gestion TIC | Webhook | Google Sheets | Registro de prestamos/devoluciones de equipos |
| 10 | Cumpleanos Alumnos | Convivencia | Programado (L-V 8:30) | Google Sheets, SMTP | Avisa al tutor cuando un alumno cumple anos |
| 11 | Alerta Absentismo | Alertas | Programado (V 14:00) | Google Sheets, SMTP | Detecta alumnos con +3 ausencias mensuales |
| 12 | Boletin Semanal | Comunicaciones | Programado (V 16:00) | Google Sheets, SMTP | Resumen semanal personalizado por curso para familias |
| 13 | Solicitud de Material | Gestion de recursos | Webhook | Google Sheets, SMTP | Registro de solicitudes con alerta urgente al coordinador |
| 14 | Guardias y Sustituciones | Gestion de personal | Webhook | Google Sheets, SMTP | Asignacion automatica de sustitutos desde cuadrante de guardias |
| 15 | Encuesta de Satisfaccion | Calidad | Programado (1/mes 10:00) | Google Sheets, SMTP | Envio mensual de encuestas a familias con registro de seguimiento |

---

## Clasificacion por categoria

### Comunicaciones (4 workflows)
Automatizaciones orientadas a la comunicacion entre el centro y las familias.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 01 | Email Masivo a Padres/Tutores | Online | Manual |
| 02 | Recogida de Google Forms | Online | Webhook |
| 08 | Recordatorio de Entregas y Examenes | Online | Programado |
| 12 | Boletin Semanal para Familias | Online | Programado |

### Gestion academica (7 workflows)
Control de notas, asistencia, reuniones e informes academicos.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 03 | Recordatorio Semanal de Reuniones | Online | Programado |
| 04 | Control de Asistencia Diario | Online | Webhook |
| 05 | Consolidar Notas del Trimestre | Online | Manual |
| 06 | Informe Mensual de Asistencia | Online | Programado |
| 11 | Alerta de Absentismo Acumulado | Online | Programado |
| **16** | **Calculadora de Notas Offline** | **Offline** | **Webhook** |

### Gestion TIC (2 workflows)
Gestion de equipos informaticos y herramientas tecnologicas.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 09 | Gestion de Inventario TIC | Online | Webhook |
| **19** | **Control de Prestamos Offline** | **Offline** | **Webhook** |

### Gestion de recursos (1 workflow)
Solicitudes de material y recursos del centro.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 13 | Solicitud de Material y Recursos | Online | Webhook |

### Gestion de personal (1 workflow)
Gestion de guardias, sustituciones y personal docente.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 14 | Guardias y Sustituciones | Online | Webhook |

### Convivencia (3 workflows)
Seguimiento de la convivencia, cumpleanos e incidencias.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 10 | Notificacion de Cumpleanos | Online | Programado |
| **17** | **Registro de Incidencias Offline** | **Offline** | **Webhook** |
| **21** | **Diario de Actividad del Centro** | **Offline** | **Webhook** |

### Herramientas docentes y TIC (3 workflows)
Herramientas de utilidad para el profesorado.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| **18** | **Generador de Contrasenas** | **Offline** | **Webhook** |
| **20** | **Sorteo y Asignacion de Grupos** | **Offline** | **Webhook** |
| **22** | **Convertidor Excel Masivo** | **Offline** | **Manual** |
| **23** | **Generador de Diplomas** | **Offline + SMTP** | **Manual** |

### Mantenimiento (1 workflow)
Copias de seguridad y mantenimiento del sistema.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 07 | Backup Automatico de Datos | Online | Programado |

### Calidad (1 workflow)
Evaluacion y seguimiento de la calidad educativa.

| # | Workflow | Modo | Trigger |
|---|---------|------|---------|
| 15 | Encuesta de Satisfaccion | Online | Programado |

---

## Referencia de endpoints webhook

Todos los webhooks escuchan en `http://localhost:5678/webhook/`.

| Endpoint | Metodo | Workflow | Modo |
|----------|--------|---------|------|
| /formulario-educativo | POST | 02 - Google Forms | Online |
| /asistencia | POST | 04 - Control Asistencia | Online |
| /inventario-tic | POST | 09 - Inventario TIC | Online |
| /solicitud-material | POST | 13 - Solicitud Material | Online |
| /ausencia-profesor | POST | 14 - Guardias | Online |
| /calcular-notas | POST | 16 - Calculadora Notas | **Offline** |
| /registro-incidencias | POST | 17 - Registro Incidencias | **Offline** |
| /generar-contrasenas | POST | 18 - Generador Contrasenas | **Offline** |
| /prestamos-offline | POST | 19 - Control Prestamos | **Offline** |
| /sorteo-grupos | POST | 20 - Sorteo Grupos | **Offline** |
| /diario-actividad | POST | 21 - Diario Actividad | **Offline** |

---

## Dependencias por servicio externo

| Servicio | Workflows que lo usan | Alternativa offline |
|----------|----------------------|---------------------|
| Google Sheets | 01, 02, 03, 04, 05, 06, 08, 09, 10, 11, 12, 13, 14, 15 | Workflows 16-21 usan SQLite interno |
| SMTP (email) | 01, 02, 03, 04, 05, 06, 08, 10, 11, 12, 13, 14, 15 | — |
| Google Drive | 07 | — |
| API n8n (localhost) | 07 | Local (no requiere internet) |

---

## Nodos n8n utilizados

| Nodo | Tipo | Requiere Internet | Workflows |
|------|------|-------------------|-----------|
| Sticky Note | Documentacion | No | Todos |
| Webhook | Trigger HTTP | No | 02, 04, 09, 13, 14, 16-21 |
| Schedule Trigger | Trigger temporal | No | 03, 06, 07, 08, 10, 11, 12, 15 |
| Manual Trigger | Trigger manual | No | 01, 05 |
| Code | JavaScript | No | 03, 05-12, 14-21 |
| IF | Condicional | No | 03, 04, 08-15 |
| Set | Asignar valores | No | 01, 02, 04, 13, 14 |
| Filter | Filtrar datos | No | 01 |
| Merge | Combinar datos | No | 05 |
| Respond to Webhook | Respuesta HTTP | No | 04, 13, 14 |
| Google Sheets | Hojas de calculo | **Si** | 01-06, 08-15 |
| Send Email (SMTP) | Envio de correo | **Si** | 01-06, 08, 10-15 |
| Google Drive | Almacenamiento nube | **Si** | 07 |
| HTTP Request | Peticiones HTTP | Depende del destino | 07 (localhost) |
