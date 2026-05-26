# 1. ESTUDIO DEL PROBLEMA Y ANÁLISIS DEL SISTEMA

## 1.1 Introducción

Este proyecto consiste en la implementación de un sistema de automatizaciones orientado a entornos educativos. Mediante el uso de la herramienta n8n, desplegada sobre contenedores Docker, se busca proporcionar una solución portátil y ligera que permita a profesores y personal administrativo de colegios y academias automatizar tareas repetitivas del día a día.

La solución se distribuye como un paquete autocontenido ejecutable desde un USB o clonado desde GitHub, sin necesidad de instalaciones complejas ni conocimientos avanzados de sistemas. El único requisito es tener Docker instalado en el equipo.

## 1.2 Motivación y finalidad

En los entornos educativos existe una gran cantidad de tareas administrativas y de comunicación que se repiten con frecuencia: enviar notificaciones a familias, generar informes de seguimiento, consolidar datos de evaluación, preparar material didáctico, entre otras. Estas tareas consumen un tiempo considerable que podría dedicarse a la enseñanza y la atención al alumnado.

La motivación del proyecto parte de una idea sencilla: "solo tener que pensar una vez". Si una tarea se puede definir como un proceso con pasos claros, se puede automatizar. La finalidad es optimizar el trabajo del personal educativo, reduciendo el tiempo invertido en tareas mecánicas y permitiendo dedicar más recursos al trabajo pedagógico.

## 1.3 Alcance y objetivos

### Alcance

El sistema implementado ofrece:

- Una infraestructura Docker portátil con n8n como motor de automatización y SQLite para persistencia.
- Scripts de instalación y arranque multiplataforma (Windows y Linux).
- 21 workflows agrupados en ocho categorías: comunicaciones educativas, gestión académica, mantenimiento, gestión TIC, convivencia, gestión de recursos, personal docente y administración.
- Documentación completa con manuales de instalación y uso.
- Repositorio en GitHub como canal de distribución alternativo al USB.

### Objetivos

1. Desplegar un entorno n8n funcional mediante Docker Compose que sea completamente portátil.
2. Crear automatizaciones útiles para tareas reales de un entorno educativo, cubriendo las áreas definidas.
3. Documentar todo el proceso para que cualquier usuario con conocimientos básicos pueda poner en marcha el sistema.
4. Proporcionar una solución escalable donde se puedan añadir nuevas automatizaciones sin modificar la infraestructura.

## 1.4 Planificación temporal

| Fase | Descripción | Dependencias |
| ---- | ----------- | ------------ |
| 1. Infraestructura Docker | Configuración de Docker Compose con n8n y SQLite | Ninguna |
| 2. Scripts de instalación | Scripts de arranque y parada multiplataforma | Fase 1 |
| 3. Workflows de comunicaciones | Automatizaciones de emails, notificaciones y avisos | Fase 1 |
| 4. Workflows de gestión académica | Automatizaciones de notas, asistencia y administración | Fase 1 |
| 5. Workflows de gestión de recursos, personal y calidad | Automatizaciones de solicitudes, guardias, alertas y encuestas | Fase 1 |
| 6. Repositorio GitHub | Estructura del repositorio y documentación de distribución | Fases 1-5 |
| 7. Documentación | Memoria completa del proyecto | Todas |

## 1.5 Estado del arte: comparativa de plataformas de automatización

### Plataformas evaluadas

- **n8n** — Plataforma de automatización de código abierto orientada a workflows visuales. Permite despliegue local mediante Docker.
- **Zapier** — Plataforma SaaS líder. Solo funciona en la nube, sin opción de instalación local.
- **Make (antes Integromat)** — Plataforma SaaS con interfaz visual avanzada. Solo funciona en la nube.
- **Microsoft Power Automate** — Herramienta integrada en el ecosistema Microsoft 365. Requiere licencia y conexión a la nube.

### Tabla comparativa

| Criterio | n8n | Zapier | Make | Power Automate |
|----------|-----|--------|------|----------------|
| **Código abierto** | Sí (Fair-code) | No | No | No |
| **Self-hosted** | Sí (Docker, npm) | No | No | No |
| **Funciona sin Internet** | Sí (SQLite) | No | No | Parcialmente |
| **Precio** | Gratis (self-hosted) | Desde 19,99 $/mes | Desde 9 $/mes | Incluido en M365 |
| **Portabilidad USB** | Sí | No | No | No |
| **Nodos disponibles** | ~400 + Code (JS/Python) | ~7.000 | ~1.800 | ~1.000 |
| **Nodo de código** | Sí (JS y Python) | Limitado | Limitado | Sí |
| **Adecuación educativa** | Alta: gratis, portable, offline | Baja: coste recurrente | Media: coste recurrente | Media: requiere licencia |

### Justificación de la elección

Se elige **n8n** por: coste cero (crítico en entornos con presupuestos ajustados), portabilidad real desde USB con Docker, funcionamiento offline mediante SQLite, flexibilidad del nodo Code para lógica compleja en JavaScript, y ausencia de vendor lock-in (los workflows se exportan como JSON estándar). Las alternativas comerciales quedan descartadas por su dependencia de la nube y sus costes recurrentes.

## 1.6 Metodología de desarrollo

El proyecto sigue un enfoque **iterativo incremental**: cada workflow sigue el ciclo análisis → diseño → implementación → pruebas → documentación, lo que permite entregar valor de forma incremental y corregir problemas en ciclos cortos sin afectar al resto del sistema.

**Herramientas de soporte:** Git/GitHub para control de versiones y distribución; herramientas de IA (Claude, ChatGPT) como apoyo en generación de configuraciones, revisión de código JavaScript y asistencia en documentación; Obsidian para redacción de la memoria.

---

# 2. RECURSOS NECESARIOS

## 2.1 Recursos humanos

El proyecto ha sido desarrollado íntegramente por un único alumno como Proyecto de Fin de Ciclo (PFC) del ciclo formativo CFGS ASIR en modalidad Dual, en el centro Salesianos Los Boscos.

- **Desarrollador:** Liher Ríos Ruiz
- **Centro:** Salesianos Los Boscos
- **Ciclo:** CFGS Administración de Sistemas Informáticos en Red (ASIR) - Dual

## 2.2 Recursos hardware

| Recurso | Uso en el proyecto |
|---------|-------------------|
| Ordenador personal (Windows 11) | Desarrollo, pruebas y documentación |
| Memoria USB | Distribución y ejecución portátil |

Requisitos mínimos: CPU con virtualización (VT-x/AMD-V), 2 GB de RAM disponibles para Docker, 500 MB de almacenamiento libre, Windows 10/11, Linux o macOS con Docker instalado.

## 2.3 Recursos software

| Software | Función | Licencia |
|----------|---------|----------|
| Docker Desktop 4.x | Motor de contenedores | Gratuito para uso educativo |
| Docker Compose | Orquestación del contenedor | Incluido con Docker |
| n8n (última versión) | Motor de automatización de workflows | Fair-code (gratuito self-hosted) |
| SQLite (incluido en n8n) | Persistencia de datos offline | Dominio público |
| Git 2.x | Control de versiones | GPLv2 |
| GitHub | Repositorio remoto y distribución | Gratuito |
| Obsidian 1.x | Redacción de la documentación | Gratuito personal |
| Visual Studio Code 1.x | Edición de archivos de configuración | Gratuito |

## 2.4 Análisis de costes

Todo el software utilizado es gratuito: Docker, n8n, SQLite, Git, GitHub, Google Sheets API, SMTP y las herramientas de desarrollo suman **0 €**. Frente a alternativas SaaS como Zapier (~20 $/mes), Make (~9 $/mes) o Power Automate (~15 $/usuario/mes), el ahorro para un centro con 5 docentes supera los 900 € anuales.

## 2.5 Estimación temporal

| Fase | Horas estimadas |
|------|-----------------|
| Investigación y aprendizaje | 15 h |
| Infraestructura Docker | 8 h |
| Workflows online (01-15) | 40 h |
| Workflows offline (16-21) | 15 h |
| Panel visual y catálogo | 10 h |
| Documentación (Memoria) | 25 h |
| Pruebas y depuración | 10 h |
| **Total estimado** | **~123 h** |

---

# 3. IMPLEMENTACIÓN DEL PROYECTO Y DOCUMENTACIÓN TÉCNICA

## 3.1 Ejecución del proyecto

### 3.1.1 Fase 1: Infraestructura Docker portátil

El archivo `docker-compose.yml` define un servicio con la imagen oficial de n8n. Las decisiones de diseño clave son:

- **Bind mount** (`./n8n-data:/home/node/.n8n`) en lugar de volumen Docker con nombre, para que los datos residan físicamente dentro de la carpeta del proyecto y sean portátiles en USB.
- **Zona horaria** configurada a `Europe/Madrid` para que los triggers programados se ejecuten correctamente.
- **Health check** cada 30 segundos sobre `/healthz`: si n8n no responde en 3 intentos, Docker lo reinicia automáticamente.
- **Límite de memoria** (512 MB) para prevenir que un pico de carga consuma todos los recursos del equipo.
- **Diagnósticos desactivados** (`N8N_DIAGNOSTICS_ENABLED=false`) para respetar la privacidad del entorno educativo.

El archivo `.env.example` expone dos variables configurables por el usuario: `N8N_PORT` (por defecto 5678) y `TIMEZONE` (por defecto `Europe/Madrid`). El script de arranque crea automáticamente el `.env` si no existe.

### 3.1.2 Fase 2: Scripts de instalación y arranque

| Script | Plataforma | Función |
|--------|-----------|---------|
| `scripts/start.bat` | Windows | Arranque con instalación automática de Docker vía winget si falta |
| `scripts/start.sh` | Linux/macOS | Equivalente Unix (instala Docker via script oficial o Homebrew) |
| `scripts/stop.bat` | Windows | Detiene el contenedor de forma limpia |
| `scripts/stop.sh` | Linux/macOS | Equivalente Unix |

Los scripts detectan si Docker está instalado, lo instalan si falta, esperan hasta 60 segundos a que arranque, crean `.env` y `n8n-data/` si no existen, y ejecutan `docker compose up -d`. El usuario no necesita conocimientos técnicos previos.

### 3.1.3 Workflows de comunicaciones educativas

#### 01 - Email Masivo a Padres/Tutores
**Categoría:** Comunicaciones

Lee el listado de familias (nombre, email, curso) desde Google Sheets y envía un email personalizado a cada una vía SMTP. Un nodo IF filtra registros sin email para evitar errores de envío. Trigger manual: el tutor decide cuándo lanzar el comunicado, evitando envíos accidentales. Se usa SMTP en lugar de servicios externos porque la mayoría de centros ya dispone de servidor de correo institucional.

#### 02 - Recogida Automática de Google Forms
**Categoría:** Comunicaciones / Gestión

Recibe respuestas de formularios por webhook (compatible con cualquier formulario HTTP, incluido Google Forms vía Apps Script), las archiva con fecha y hora automáticas en Google Sheets y notifica al profesor por email. La respuesta webhook síncrona confirma al remitente que sus datos han llegado correctamente.

### 3.1.4 Workflows de gestión académica

#### 03 - Recordatorio Semanal de Reuniones
**Categoría:** Gestión académica

Cada lunes a las 9:00 lee un calendario de reuniones en Google Sheets y envía un resumen semanal al equipo. Un nodo Code filtra por rango de fechas (más limpio que encadenar condiciones IF) y un nodo IF evita enviar emails cuando no hay reuniones esa semana.

#### 04 - Control de Asistencia Diario
**Categoría:** Gestión académica

Recibe registros de asistencia por webhook (desde apps, formularios o lectores de tarjetas), los guarda en Google Sheets y notifica a la familia solo cuando el alumno está ausente. El modo `lastNode` en el webhook permite confirmar al sistema remitente que el registro se procesó correctamente.

#### 05 - Consolidar Notas del Trimestre
**Categoría:** Gestión académica

Combina datos de dos hojas de cálculo (exámenes y trabajos/participación) usando un nodo Merge. Un nodo Code calcula la media ponderada (examen 50%, trabajo 30%, participación 20%) y la convierte a la escala cualitativa española. Los resultados se guardan en una hoja resumen y se notifica al jefe de estudios.

#### 06 - Generador de Informe Mensual de Asistencia
**Categoría:** Gestión académica

El día 1 de cada mes lee los registros del mes anterior, calcula porcentajes de asistencia por alumno y marca con alerta a los que superan 3 ausencias. Envía el informe por email al equipo directivo y archiva los datos procesados en una hoja histórica para analizar tendencias sin reprocesar datos en bruto.

### 3.1.5 Workflows de mantenimiento, convivencia y gestión TIC

#### 07 - Backup Automático de Datos n8n
**Categoría:** Mantenimiento y seguridad

Cada noche a las 2:00 llama a la API interna de n8n (`/api/v1/workflows`) para exportar todos los workflows, los empaqueta en un JSON con metadatos (fecha, hora, total de workflows) y lo sube a una carpeta de Google Drive. Google Drive es gratuito para centros con Google Workspace y garantiza que la copia sobrevive si se pierde el USB.

#### 08 - Recordatorio de Entregas y Exámenes
**Categoría:** Gestión académica / Comunicaciones

Cada día lectivo a las 8:00 revisa el calendario académico en Google Sheets y envía recordatorios cuando hay un evento en los próximos 3 días. El nodo Code calcula etiquetas de urgencia ("HOY", "MAÑANA", "En X días") adaptadas al formato de fecha español DD/MM/YYYY.

#### 09 - Gestión de Inventario TIC
**Categoría:** Gestión TIC

Registra préstamos y devoluciones de equipos informáticos vía webhook (compatible con formularios web, apps móviles y lectores QR). Los registros de préstamo y devolución se añaden como filas independientes (en lugar de actualizar una fila existente) para conservar el historial completo de movimientos.

#### 10 - Notificación de Cumpleaños de Alumnos
**Categoría:** Convivencia y bienestar

Cada día lectivo a las 8:30 compara día y mes de nacimiento de los alumnos, calcula la edad y agrupa los cumpleaños por tutor para enviar un único email aunque coincidan varios alumnos el mismo día.

### 3.1.6 Workflows de alertas, gestión de recursos, personal y calidad

#### 11 - Alerta de Absentismo Acumulado
**Categoría:** Alertas / Gestión académica

Cada viernes a las 14:00 analiza los registros de asistencia del mes en curso, detecta alumnos con más de 3 ausencias y envía un informe de alerta al jefe de estudios. El umbral de 3 faltas es configurable en el nodo Code. Si ningún alumno supera el umbral, el workflow termina sin enviar nada.

#### 12 - Boletín Semanal para Familias
**Categoría:** Comunicaciones educativas

Cada viernes a las 16:00 genera un boletín personalizado por curso con eventos y avisos del tutor (leídos de Google Sheets) y lo envía al email de grupo. El tutor solo tiene que mantener actualizada una hoja con los avisos de la semana.

#### 13 - Solicitud de Material y Recursos
**Categoría:** Gestión de recursos

Registra solicitudes de material (fotocopias, laboratorio, aulas especiales) vía webhook. Solo las solicitudes con urgencia "alta" generan notificación inmediata al coordinador; las de urgencia media o baja quedan registradas para revisión periódica, evitando saturar al coordinador.

#### 14 - Gestión de Guardias y Sustituciones
**Categoría:** Gestión de personal docente

El workflow más complejo del proyecto: cuando un profesor comunica su ausencia por webhook, el sistema lee el cuadrante de guardias de Google Sheets, busca un sustituto disponible para esa franja horaria y notifica a ambas partes. Si no hay sustituto, avisa directamente a jefatura. La respuesta webhook incluye el nombre del sustituto asignado o indica que jefatura está gestionando el caso.

#### 15 - Encuesta de Satisfacción Automatizada
**Categoría:** Calidad y mejora continua

El día 1 de cada mes envía un enlace a una encuesta de Google Forms a todas las familias con email registrado y guarda un log de cada envío (fecha, familia, curso, email) en Google Sheets. Garantiza el cumplimiento puntual de las encuestas de satisfacción obligatorias en muchos sistemas de calidad educativa.

### 3.1.7 Workflows offline (sin conexión a Internet)

Los workflows 16-21 funcionan al 100% sin Internet mediante `$getWorkflowStaticData('global')`, una API de n8n que persiste datos en la base de datos SQLite interna del contenedor. Todos los datos viajan con el USB.

#### 16 - Calculadora de Notas Offline
**Categoría:** Gestión académica | **Modo:** Offline

Recibe notas por webhook, calcula la media ponderada (examen 50%, trabajo 30%, participación 20%) y almacena el histórico en SQLite. Un único endpoint acepta tanto el registro de notas nuevas como la consulta del histórico filtrado por curso. `$getWorkflowStaticData` es atómica, sin riesgo de corrupción por escrituras concurrentes.

#### 17 - Registro de Incidencias Offline
**Categoría:** Convivencia | **Modo:** Offline

Gestiona incidencias de convivencia (leve, grave, muy grave) con un CRUD completo: registrar (con validación de tipos permitidos, ID único y timestamp), consultar con filtros combinables (curso, alumno, tipo, rango de fechas) y generar resúmenes estadísticos por tipo y por curso.

#### 18 - Generador de Contraseñas para Alumnos
**Categoría:** Herramientas TIC | **Modo:** Offline

Genera usuarios (primera letra + apellido, sin acentos) y contraseñas aleatorias seguras para listas de alumnos. Excluye caracteres ambiguos (0, O, l, I, 1) para evitar confusiones. Las credenciales se generan y devuelven en la respuesta sin persistirse en la base de datos, minimizando el riesgo de exposición.

#### 19 - Control de Préstamos de Material Offline
**Categoría:** Gestión TIC | **Modo:** Offline

Versión offline del workflow 09. Gestiona préstamos y devoluciones de equipos sin Google Sheets. Detecta automáticamente equipos prestados hace más de 7 días y los marca con alerta informativa en las consultas de inventario. Bloquea prestar un equipo que ya está prestado.

#### 20 - Sorteo y Asignación de Grupos
**Categoría:** Herramientas docentes | **Modo:** Offline

Forma equipos de trabajo aleatorios y equilibrados usando el algoritmo Fisher-Yates (permutaciones imparciales, a diferencia de `sort(() => Math.random() - 0.5)` que tiene sesgo estadístico demostrable) y distribución round-robin para que la diferencia de tamaño entre grupos sea como máximo de 1 alumno. No persiste datos.

#### 21 - Diario de Actividad del Centro
**Categoría:** Administración | **Modo:** Offline

Libro de registro digital generalista (a diferencia del workflow 17, específico de convivencia). Soporta 5 tipos de entrada (evento, incidencia, logro, recordatorio, acta), búsqueda de texto libre case-insensitive, filtros por tipo y rango de fechas, y resúmenes estadísticos con las 5 entradas más recientes.

## 3.2 Documentación técnica

### 3.2.1 Estructura del proyecto

```
proyecto/
├── docker-compose.yml          # Configuración del contenedor
├── .env.example                # Plantilla de variables de entorno
├── .gitignore                  # Excluye n8n-data/ y .env del repositorio
├── scripts/
│   ├── start.bat / start.sh    # Arranque multiplataforma
│   └── stop.bat / stop.sh      # Parada multiplataforma
├── workflows/
│   ├── CATALOGO.md             # Catálogo organizado de los 21 workflows
│   ├── GUIA-DE-USO.md          # Guía práctica con ejemplos curl
│   ├── 01-15 (*.json)          # Workflows online
│   └── 16-21 (*.json)          # Workflows offline
├── n8n-data/                   # Datos persistentes (excluido de Git)
│   └── database.sqlite         # Workflows, credenciales y staticData
└── Memoria/                    # Documentación del proyecto (7 capítulos)
```

### 3.2.2 Workflows implementados

**Workflows online** (requieren conexión a Internet):

| Workflow | Categoría | Trigger | Nodos principales |
|----------|-----------|---------|-------------------|
| 01 - Email Masivo a Padres/Tutores | Comunicaciones | Manual | Google Sheets, IF, Set, Send Email |
| 02 - Recogida de Google Forms | Comunicaciones | Webhook POST `/formulario-educativo` | Set, Google Sheets, Send Email |
| 03 - Recordatorio Semanal de Reuniones | Gestión académica | Schedule `0 9 * * 1` | Google Sheets, Code, IF, Send Email |
| 04 - Control de Asistencia Diario | Gestión académica | Webhook POST `/asistencia` | Set, Google Sheets, IF, Send Email, Respond |
| 05 - Consolidar Notas del Trimestre | Gestión académica | Manual | Google Sheets ×2, Merge, Code, Send Email |
| 06 - Informe Mensual de Asistencia | Gestión académica | Schedule `0 8 1 * *` | Google Sheets, Code, Send Email, Google Sheets |
| 07 - Backup Automático de n8n | Mantenimiento | Schedule `0 2 * * *` | HTTP Request, Code, Google Drive |
| 08 - Recordatorio de Entregas y Exámenes | Gestión académica | Schedule `0 8 * * 1-5` | Google Sheets, Code, IF, Send Email |
| 09 - Gestión de Inventario TIC | Gestión TIC | Webhook POST `/inventario-tic` | IF, Google Sheets ×2, Code |
| 10 - Notificación de Cumpleaños | Convivencia | Schedule `30 8 * * 1-5` | Google Sheets, Code, IF, Send Email |
| 11 - Alerta de Absentismo Acumulado | Alertas | Schedule `0 14 * * 5` | Google Sheets, Code, IF, Send Email |
| 12 - Boletín Semanal para Familias | Comunicaciones | Schedule `0 16 * * 5` | Google Sheets, IF, Code, Send Email |
| 13 - Solicitud de Material y Recursos | Gestión de recursos | Webhook POST `/solicitud-material` | Set, Google Sheets, IF, Send Email, Respond |
| 14 - Gestión de Guardias y Sustituciones | Gestión de personal | Webhook POST `/ausencia-profesor` | Set, Google Sheets, Code, IF, Send Email ×2, Respond |
| 15 - Encuesta de Satisfacción | Calidad | Schedule `0 10 1 * *` | Google Sheets, IF, Code, Send Email, Google Sheets |

**Workflows offline** (funcionan sin conexión a Internet):

| Workflow | Categoría | Trigger | Almacenamiento |
|----------|-----------|---------|----------------|
| 16 - Calculadora de Notas Offline | Gestión académica | Webhook POST `/calcular-notas` | SQLite (staticData) |
| 17 - Registro de Incidencias Offline | Convivencia | Webhook POST `/registro-incidencias` | SQLite (staticData) |
| 18 - Generador de Contraseñas | Herramientas TIC | Webhook POST `/generar-contrasenas` | Sin estado |
| 19 - Control de Préstamos Offline | Gestión TIC | Webhook POST `/prestamos-offline` | SQLite (staticData) |
| 20 - Sorteo de Grupos | Herramientas docentes | Webhook POST `/sorteo-grupos` | Sin estado |
| 21 - Diario de Actividad del Centro | Administración | Webhook POST `/diario-actividad` | SQLite (staticData) |

Todos los workflows se exportan en formato JSON y se almacenan en `workflows/`, lo que permite importarlos en cualquier instancia de n8n sin recrearlos manualmente. El catálogo completo con endpoints y dependencias está en `workflows/CATALOGO.md`.

## 3.3 Consideraciones de seguridad y protección de datos

### 3.3.1 Marco legal aplicable

- **RGPD** — Reglamento (UE) 2016/679: principios de licitud, minimización de datos, limitación de finalidad, integridad y confidencialidad.
- **LOPD-GDD** — Ley Orgánica 3/2018: adapta el RGPD al ordenamiento español y establece protección reforzada para datos de menores de 14 años, cuyo tratamiento requiere consentimiento del titular de la patria potestad.

### 3.3.2 Datos personales tratados

| Nivel | Datos | Workflows |
|-------|-------|-----------|
| **Alto** | Notas y calificaciones académicas | 05, 16 |
| **Alto** | Incidencias de convivencia | 17 |
| **Alto** | Registros de asistencia y absentismo | 04, 06, 11 |
| **Medio** | Nombres y apellidos de alumnos | 01, 02, 04, 05, 10, 11, 12, 16-21 |
| **Medio** | Emails de familias / tutores legales | 01, 08, 12, 15 |
| **Medio** | Datos de profesores (nombres, horarios) | 03, 14 |
| **Bajo** | Inventario de equipos informáticos | 09, 19 |
| **Bajo** | Entradas del diario de actividad | 21 |

### 3.3.3 Medidas técnicas implementadas

1. **Almacenamiento local.** Los workflows offline (16-21) almacenan datos únicamente en SQLite dentro de `n8n-data/`, en el USB o equipo del usuario. Nada viaja a servidores externos, a diferencia de Zapier o Make donde los datos del centro irían a servidores de terceros fuera de la UE.
2. **Credenciales cifradas.** n8n almacena las credenciales de servicios externos (Google Sheets, SMTP) cifradas en su base de datos. Nunca se almacenan en texto plano ni en los JSON de los workflows.
3. **Exclusión de datos del repositorio.** `.gitignore` excluye `n8n-data/` y `.env`, garantizando que al compartir el proyecto vía GitHub no se filtran datos personales ni credenciales.
4. **Webhooks solo en localhost.** Por defecto n8n escucha únicamente en `localhost:5678`, accesible solo desde el propio equipo.
5. **Contraseñas no persistidas.** El workflow 18 genera credenciales y las devuelve en la respuesta HTTP sin almacenarlas.

### 3.3.4 Recomendaciones para producción

1. Activar autenticación (`N8N_BASIC_AUTH_ACTIVE=true`).
2. Restringir acceso por red con firewall o proxy inverso (Nginx) con HTTPS si se expone en la LAN.
3. Cifrar los backups del workflow 07 con GPG antes de subirlos a Drive.
4. Documentar el registro de actividades de tratamiento exigido por el RGPD.
5. Establecer política de retención y purgado periódico de datos en `$getWorkflowStaticData`.

---

# 4. FASE DE PRUEBAS

## 4.1 Pruebas realizadas

### 4.1.1 Pruebas de infraestructura

| Prueba | Resultado obtenido |
|--------|--------------------|
| Arranque del contenedor (`start.bat`) | n8n accesible en `http://localhost:5678` en ~10 segundos. La primera vez tarda más por la descarga de la imagen. |
| Persistencia de datos tras reinicio | Workflows y configuraciones intactos tras `stop.bat` + `start.bat`. Los datos se conservan en `n8n-data/`. |
| Portabilidad USB | Copiada la carpeta a otro equipo con Docker Desktop; arrancó con los mismos workflows y credenciales sin configuración adicional. |
| Creación automática de `.env` | Al borrar `.env` y ejecutar `start.bat`, el script lo recrea desde `.env.example` correctamente. |
| Parada limpia (`stop.bat`) | Contenedor detenido en ~3 segundos sin pérdida de datos. |
| Cambio de puerto vía `.env` | n8n respondió en el nuevo puerto tras reinicio. Al revertir, funcionó correctamente. |

Resultado: **6/6 pruebas correctas.**

### 4.1.2 Pruebas de workflows

Los 15 workflows online se probaron con datos de ejemplo desde la interfaz de n8n y con peticiones `curl` a los webhooks. Los 6 workflows offline se probaron con WiFi desconectado para verificar su independencia de Internet.

Se realizaron **38 pruebas funcionales** y **4 de casos límite** (comportamientos en datos incompletos, situaciones sin resultados, etc.). Todos los resultados fueron correctos o predecibles.

Comportamientos documentados como predecibles aunque no ideales:
- **Workflow 05 (Notas):** celdas vacías en notas tratadas como 0 en el cálculo de media.
- **Workflow 04 (Asistencia):** no comprueba registros duplicados del mismo alumno y fecha; es responsabilidad del sistema que consume el webhook.

Todos los workflows offline superaron adicionalmente la **prueba de persistencia tras reinicio**: los datos (notas, incidencias, préstamos, diario) sobrevivieron a `stop.bat` + `start.bat` íntegros.

### 4.1.3 Pruebas de errores y casos límite

| Escenario | Comportamiento observado |
|-----------|--------------------------|
| Docker no arrancado | El script detecta el estado e intenta iniciarlo; espera 60 s y avisa si falla. |
| Puerto 5678 ocupado | Docker muestra `port is already allocated`; solución: cambiar `N8N_PORT` en `.env`. |
| Sin conexión a Internet | Workflows offline funcionan normalmente; los online fallan en el nodo de red y se recuperan al volver la conexión. |
| USB extraído sin parar el contenedor | n8n se detuvo con errores; al reconectar, los datos se conservaron sin corrupción. **Recomendación: siempre parar con `stop.bat` antes de extraer.** |

## 4.2 Resumen de resultados

| Categoría | Pruebas | Correctas | Fallidas |
|-----------|---------|-----------|----------|
| Infraestructura | 6 | 6 | 0 |
| Workflows online (01-15) | 18 | 18 | 0 |
| Workflows offline (16-21) | 14 | 14 | 0 |
| Errores y casos límite | 4 | 4 | 0 |
| **Total** | **42** | **42** | **0** |

### Matriz de cobertura por workflow

| Workflow | Funcional | Caso límite | Offline verificado |
|----------|:---------:|:-----------:|:------------------:|
| 01 - Email Masivo | ✓ | ✓ (email vacío) | — |
| 02 - Google Forms | ✓ | ✓ (campos incompletos) | — |
| 03 - Recordatorio Reuniones | ✓ | ✓ (sin reuniones) | — |
| 04 - Control Asistencia | ✓ | ✓ (duplicado) | — |
| 05 - Consolidar Notas | ✓ | ✓ (celdas vacías) | — |
| 06 - Informe Asistencia | ✓ | ✓ (mes sin datos) | — |
| 07 - Backup Automático | ✓ | — | — |
| 08 - Recordatorio Entregas | ✓ | ✓ (sin eventos) | — |
| 09 - Inventario TIC | ✓ | — | — |
| 10 - Cumpleaños Alumnos | ✓ | ✓ (sin cumpleaños) | — |
| 11 - Alerta Absentismo | ✓ | ✓ (sin absentismo) | — |
| 12 - Boletín Semanal | ✓ | ✓ (sin email de grupo) | — |
| 13 - Solicitud Material | ✓ | ✓ (no urgente) | — |
| 14 - Guardias | ✓ | ✓ (sin sustituto) | — |
| 15 - Encuesta Satisfacción | ✓ | — | — |
| 16 - Calculadora Notas | ✓ | ✓ (curso sin datos) | ✓ |
| 17 - Registro Incidencias | ✓ | ✓ (tipo inválido) | ✓ |
| 18 - Generador Contraseñas | ✓ | ✓ (sin ambiguos) | ✓ |
| 19 - Control Préstamos | ✓ | ✓ (ya prestado, retraso) | ✓ |
| 20 - Sorteo Grupos | ✓ | ✓ (número impar) | ✓ |
| 21 - Diario Actividad | ✓ | — | ✓ |

---

# 5. CONCLUSIONES FINALES

## 5.1 Grado de cumplimiento de los objetivos

Todos los objetivos se han cumplido satisfactoriamente. El entorno n8n portátil arranca con un solo script y ha sido verificado copiando la carpeta a un USB en otros equipos. Se han desarrollado los 21 workflows planificados, cubriendo las 8 categorías previstas. Los 6 workflows offline demuestran la portabilidad real del sistema en entornos sin Internet. La documentación cubre instalación, uso y descripción técnica de cada workflow. El proyecto se distribuye tanto vía GitHub (`https://github.com/liherrios-prog/tfg-automatizaciones-educativas`) como en USB, ambos probados y funcionales.

## 5.2 Propuesta de ampliaciones futuras

La escalabilidad es una de las mayores fortalezas del proyecto: añadir un workflow no requiere tocar la infraestructura. Las ampliaciones más relevantes identificadas:

1. **Generación de contenido con IA.** Workflows que usen la API de OpenAI o Anthropic para generar exámenes tipo test o resúmenes; n8n tiene nodos nativos para estas APIs.
2. **Integración con Google Classroom y Moodle.** Sincronizar notas o publicar tareas automáticamente; n8n dispone de nodos para ambas plataformas.
3. **Interfaz web para webhooks.** Formularios HTML estáticos como frontal para usuarios no familiarizados con herramientas HTTP.
4. **Versiones offline adicionales.** Control de asistencia y gestor de reuniones sin dependencia de Google Sheets.
5. **Despliegue en la nube.** Documentar cómo usar el mismo `docker-compose.yml` en un VPS con dominio y HTTPS para centros que prefieran acceso multi-equipo.

## 5.3 Lecciones aprendidas

**Gestión de credenciales de Google.** Configurar OAuth2, API keys y permisos fue la parte más costosa en tiempo. Un error en los scopes puede hacer que todo falle sin mensajes claros.

**Pruebas con datos reales.** Los datos inventados pasaban todas las pruebas; los datos reales (acentos, campos vacíos, formatos inesperados) revelaron fallos. Los nodos IF y las validaciones de entrada son más críticos de lo que parecen.

**Docker hay que entenderlo.** Depurar problemas de permisos, bind mounts y puertos obligó a comprender el funcionamiento interno de Docker, algo valioso para un alumno de ASIR.

**El enfoque offline fue el salto cualitativo.** La contradicción entre "portabilidad USB" y "requiere Internet" llevó a desarrollar los workflows offline, reforzando el argumento del proyecto y explorando `$getWorkflowStaticData`.

**La documentación cuesta más de lo esperado.** Redactar la memoria fue más laborioso que implementar varios workflows, pero una documentación completa diferencia un proyecto profesional de uno amateur.

## 5.4 Métricas del proyecto

| Métrica | Valor |
|---------|-------|
| Workflows implementados | 21 (15 online + 6 offline) |
| Categorías cubiertas | 8 |
| Pruebas funcionales documentadas | 42 |
| Scripts multiplataforma | 4 (start/stop × Windows/Linux) |
| Referencias bibliográficas | 23 |
| Coste total en software | 0 € |

**Estimación de tiempo ahorrado** por ejecución frente a proceso manual:

| Tarea | Manual | Automatizado | Ahorro |
|-------|--------|--------------|--------|
| Enviar emails a 30 familias | 45-60 min | 3 segundos | ~99% |
| Consolidar notas de un curso | 30-40 min | 2 segundos | ~99% |
| Generar informe mensual de asistencia | 60-90 min | 5 segundos | ~99% |
| Registrar incidencia de convivencia | 5-10 min | 10 segundos | ~95% |
| Generar contraseñas para 25 alumnos | 20-30 min | 1 segundo | ~99% |
| Sortear grupos para una actividad | 10-15 min | 1 segundo | ~99% |

Con un uso regular de los 21 workflows durante un curso escolar, el ahorro acumulado se estima en **varias decenas de horas de trabajo administrativo al año**.

---

# 6. DOCUMENTACIÓN DEL SISTEMA DESARROLLADO

## 6.1 Manual de instalación

### Requisitos previos

- **Docker Desktop** instalado (Windows: desde docker.com, requiere virtualización activada en BIOS; Linux: Docker Engine + Compose; macOS: Docker Desktop).
- **500 MB** de espacio libre en disco.

### Instalación

**Desde GitHub:**
```bash
git clone https://github.com/liherrios-prog/tfg-automatizaciones-educativas.git
cd tfg-automatizaciones-educativas
```

**Desde USB:** Conectar el USB y abrir la carpeta del proyecto.

### Arranque

**Windows:** Doble click en `scripts\start.bat`. Esperar la descarga inicial de la imagen (solo la primera vez). Acceder a `http://localhost:5678` y crear la cuenta de administrador local.

**Linux / macOS:**
```bash
./scripts/start.sh
```

### Configuración personalizada

Editar `.env` para cambiar puerto o zona horaria:
```
N8N_PORT=8080
TIMEZONE=Europe/London
```
Reiniciar con `stop.bat` (o `.sh`) seguido de `start.bat` (o `.sh`).

## 6.2 Manual de uso

Acceder a `http://localhost:5678` con las credenciales creadas en el primer arranque.

**Importar un workflow:** En n8n → lista de workflows → menú → "Import from File" → seleccionar el JSON de la carpeta `workflows/`.

**Ejecutar manualmente:** Abrir el workflow → pulsar "Execute Workflow".

**Activar ejecución automática:** Abrir el workflow → activar el interruptor "Active" (verde) en la esquina superior derecha.

**Exportar un workflow:** Menú superior del editor → "Download" → guardar en `workflows/`.

La referencia completa con endpoints y dependencias está en `workflows/CATALOGO.md`. Los ejemplos de uso con comandos `curl` listos para copiar están en `workflows/GUIA-DE-USO.md`.

**Parar el sistema:** `scripts\stop.bat` (Windows) o `./scripts/stop.sh` (Linux/Mac). Los datos quedan en `n8n-data/`.

## 6.3 Resolución de problemas comunes

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| "Docker no está instalado" | Docker Desktop no instalado | El script intenta instalarlo automáticamente. Si falla, instalar manualmente desde docker.com |
| Contenedor no arranca | Docker Desktop no está ejecutándose | Abrir Docker Desktop. El script espera hasta 60 s |
| "port is already allocated" | Puerto 5678 ocupado | Cambiar `N8N_PORT` en `.env` (ej: 8080) y reiniciar |
| Workflows online fallan | Sin Internet o credenciales no configuradas | Verificar conexión. Sin Internet, usar workflows offline (16-21). Con conexión, revisar credenciales en n8n > Settings |
| "Permission denied" en Linux | Usuario no está en el grupo `docker` | `sudo usermod -aG docker $USER` y reiniciar sesión |
| JSON no importa | Archivo corrupto o versión incompatible | Descargar el JSON original de GitHub |
| Datos offline desaparecen tras reinicio | Bind mount no montado | Verificar `./n8n-data:/home/node/.n8n` en `docker-compose.yml` y permisos de escritura |
| Webhook devuelve "Not Found" | Workflow no activado | Activar el interruptor "Active" en n8n (debe quedar verde) |
| Timeout en envío SMTP | Credenciales incorrectas o servidor no responde | Revisar credenciales SMTP. Alternativa: Gmail con contraseña de aplicación |

**Consejo general:** Revisar logs con `docker compose logs -f`. Los mensajes de n8n suelen apuntar directamente al nodo o credencial que falla.

---

# 7. BIBLIOGRAFÍA

## 7.1 Documentación oficial

[1] n8n GmbH, "n8n Documentation," n8n Docs, 2024. [En línea]. Disponible en: https://docs.n8n.io/. [Acceso: 24-Mar-2025].

[2] n8n GmbH, "Self-hosting n8n with Docker," n8n Docs, 2024. [En línea]. Disponible en: https://docs.n8n.io/hosting/installation/docker/. [Acceso: 24-Mar-2025].

[3] Docker Inc., "Docker Compose overview," Docker Documentation, 2024. [En línea]. Disponible en: https://docs.docker.com/compose/. [Acceso: 24-Mar-2025].

[4] Docker Inc., "Docker Desktop for Windows," Docker Documentation, 2024. [En línea]. Disponible en: https://docs.docker.com/desktop/install/windows-install/. [Acceso: 24-Mar-2025].

[5] SQLite Consortium, "About SQLite," SQLite, 2024. [En línea]. Disponible en: https://www.sqlite.org/about.html. [Acceso: 24-Mar-2025].

## 7.2 Recursos adicionales

[6] n8n GmbH, "n8n Community Forum," n8n Community, 2024. [En línea]. Disponible en: https://community.n8n.io/. [Acceso: 24-Mar-2025].

[7] Docker Inc., "Docker Hub - n8n Official Image," Docker Hub, 2024. [En línea]. Disponible en: https://hub.docker.com/r/n8nio/n8n. [Acceso: 24-Mar-2025].

[8] Google Developers, "Google Sheets API Reference," Google for Developers, 2024. [En línea]. Disponible en: https://developers.google.com/sheets/api/reference/rest. [Acceso: 24-Mar-2025].

[9] Google Developers, "Google Apps Script Overview," Google for Developers, 2024. [En línea]. Disponible en: https://developers.google.com/apps-script/overview. [Acceso: 24-Mar-2025].

[10] Stack Overflow, "Questions tagged [n8n]," Stack Overflow, 2024. [En línea]. Disponible en: https://stackoverflow.com/questions/tagged/n8n. [Acceso: 24-Mar-2025].

## 7.3 Documentación técnica específica

[11] n8n GmbH, "Code node: Built-in methods and variables — Static data," n8n Docs, 2024. [En línea]. Disponible en: https://docs.n8n.io/code/builtin/current-node-methods/. [Acceso: 30-Mar-2025].

[12] Docker Inc., "Bind mounts," Docker Documentation, 2024. [En línea]. Disponible en: https://docs.docker.com/storage/bind-mounts/. [Acceso: 30-Mar-2025].

[13] n8n GmbH, "Webhook node," n8n Docs, 2024. [En línea]. Disponible en: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/. [Acceso: 30-Mar-2025].

## 7.4 Plataformas comparadas

[14] Zapier Inc., "Zapier — Automation that moves you forward," Zapier, 2024. [En línea]. Disponible en: https://zapier.com/. [Acceso: 30-Mar-2025].

[15] Celonis SE, "Make (formerly Integromat)," Make, 2024. [En línea]. Disponible en: https://www.make.com/. [Acceso: 30-Mar-2025].

[16] Microsoft Corporation, "Microsoft Power Automate Documentation," Microsoft Learn, 2024. [En línea]. Disponible en: https://learn.microsoft.com/en-us/power-automate/. [Acceso: 30-Mar-2025].

## 7.5 Referencias académicas y sectoriales

[17] M. Zapata-Ros, "La automatización de procesos administrativos en centros educativos: oportunidades y desafíos," *RED: Revista de Educación a Distancia*, vol. 23, no. 73, 2023. [En línea]. Disponible en: https://revistas.um.es/red/. [Acceso: 30-Mar-2025].

[18] UNESCO, "Tecnología en la educación," *Informe de Seguimiento de la Educación en el Mundo 2023*, París: UNESCO, 2023. [En línea]. Disponible en: https://www.unesco.org/gem-report/es/technology. [Acceso: 30-Mar-2025].

[19] INTEF, "Marco Común de Competencia Digital Docente," Ministerio de Educación y FP, 2022. [En línea]. Disponible en: https://intef.es/formacion-y-colaboracion/digital-docente/. [Acceso: 30-Mar-2025].

[20] R. Knuth, "The Art of Computer Programming, Vol. 2: Seminumerical Algorithms — Algorithm P (Shuffling)," 3ª ed. Boston: Addison-Wesley, 1997, pp. 145-146. *Referencia del algoritmo Fisher-Yates (workflow 20).*

## 7.6 Normativa de protección de datos

[21] Parlamento Europeo y Consejo de la UE, "Reglamento (UE) 2016/679 — RGPD," *DOUE*, 27 de abril de 2016. [En línea]. Disponible en: https://eur-lex.europa.eu/eli/reg/2016/679/oj. [Acceso: 7-Abr-2025].

[22] Jefatura del Estado, "Ley Orgánica 3/2018 — LOPD-GDD," *BOE*, núm. 294, 6 de diciembre de 2018. [En línea]. Disponible en: https://www.boe.es/eli/es/lo/2018/12/05/3. [Acceso: 7-Abr-2025].

[23] AEPD, "Guía para centros educativos," AEPD, 2018. [En línea]. Disponible en: https://www.aepd.es/guias/guia-centros-educativos.pdf. [Acceso: 7-Abr-2025].

