# GUION DE LA DEFENSA ORAL

**Proyecto:** Implementación de automatizaciones para entornos educativos
**Alumno:** Liher Ríos Ruiz
**Ciclo:** CFGS ASIR — Salesianos Los Boscos
**Duración objetivo:** 10 minutos de exposición + preguntas del tribunal

---

## ANTES DE EMPEZAR (checklist técnica)

- [ ] Portátil encendido con Docker Desktop arrancado
- [ ] n8n corriendo en http://localhost:5678 (ejecutar `scripts/start.bat` 5 minutos antes)
- [ ] Los 10 workflows importados y visibles en n8n
- [ ] Navegador abierto con dos pestañas: n8n y una hoja de Google Sheets de ejemplo
- [ ] Presentación (si la usas) cargada en pantalla
- [ ] Cable HDMI / adaptador probado con el proyector
- [ ] Plan B: capturas de pantalla de los workflows por si Docker falla

---

## PARTE 1 — CONTEXTO (3 minutos)

### Slide 1: El problema (30 segundos)

> "En un centro educativo, los profesores dedican una cantidad enorme de tiempo a tareas que se repiten: enviar comunicaciones a familias, pasar lista, consolidar notas, generar informes... Son tareas necesarias, pero mecánicas. Tiempo que se podría dedicar a los alumnos."

### Slide 2: La idea (30 segundos)

> "La idea de este proyecto es simple: solo tienes que pensar una vez. Si una tarea se puede describir como una serie de pasos, se puede automatizar. Y una vez automatizada, queda resuelta para siempre."

### Slide 3: La solución (1 minuto)

> "He creado un sistema basado en dos tecnologías: Docker, para que todo funcione dentro de un contenedor portátil, y n8n, que es un motor de automatización visual donde creas flujos de trabajo arrastrando y conectando bloques."
>
> "El sistema se puede llevar en un USB. El profesor ejecuta un script, se abre n8n en el navegador, y ya tiene disponibles 10 automatizaciones listas para usar. Los scripts de arranque detectan si Docker está instalado y, si no lo está, lo instalan automáticamente. Funciona en Windows, Linux y macOS."

**Puntos clave a mencionar:**
- Docker + SQLite = sin dependencias externas
- Bind mount = portabilidad real (USB)
- Scripts multiplataforma con auto-instalación de Docker
- 10 workflows cubriendo 5 categorías diferentes

### Slide 4: Los 10 workflows (1 minuto)

> "He desarrollado 10 automatizaciones organizadas en 5 categorías:"

Enumerar rápido, SIN detenerse en cada uno:

| Categoría | Workflows |
|-----------|-----------|
| Comunicaciones | Email masivo a familias, recogida de Google Forms, recordatorio de entregas/exámenes |
| Gestión académica | Recordatorio de reuniones, control de asistencia, consolidación de notas, informe mensual |
| Gestión TIC | Inventario de equipos informáticos |
| Mantenimiento | Backup automático a Google Drive |
| Convivencia | Notificación de cumpleaños al tutor |

> "Ahora os voy a enseñar cómo funciona esto en la práctica."

---

## PARTE 2 — DEMO EN DIRECTO (5 minutos)

**Estrategia:** Mostrar 3 workflows que demuestren variedad de triggers y complejidad.

### Demo 1: Email masivo a padres (workflow 01) — 1.5 minutos

**Por qué este:** Es el más visual y fácil de entender. Trigger manual.

1. Abrir n8n y mostrar el workflow 01
2. Señalar la Sticky Note amarilla: "Cada workflow tiene una nota explicativa con instrucciones"
3. Recorrer los nodos: "Lee de Google Sheets → filtra emails vacíos → personaliza el mensaje → envía por SMTP"
4. **Ejecutar el workflow** con datos de prueba
5. Mostrar el resultado: "Se han enviado X emails personalizados en 2 segundos. Manualmente esto lleva media hora"

> "Fijaos en que el nodo IF filtra automáticamente las filas sin email. En un listado real siempre hay algún dato que falta, y sin este filtro el workflow fallaría."

### Demo 2: Control de asistencia (workflow 04) — 2 minutos

**Por qué este:** Usa webhook (concepto técnico potente) + lógica condicional + respuesta al remitente.

1. Abrir el workflow 04 en n8n
2. Explicar: "Este se activa cuando recibe una petición HTTP. Podría venir de una app móvil, de un formulario o de un lector de tarjetas"
3. **Lanzar una petición de prueba** desde el navegador o curl:
   ```
   curl -X POST http://localhost:5678/webhook/asistencia \
     -H "Content-Type: application/json" \
     -d '{"alumno":"María García","curso":"2ESO-A","presente":false,"motivo":"Cita médica"}'
   ```
4. Mostrar cómo el workflow:
   - Registra la asistencia en Google Sheets
   - Detecta que es una ausencia
   - Envía notificación a la familia
   - Devuelve confirmación JSON al sistema remitente

> "El webhook devuelve una respuesta estructurada, lo que permite integrarlo con cualquier sistema externo. Y solo envía email a la familia cuando hay una ausencia, para no saturar con notificaciones."

### Demo 3: Backup automático (workflow 07) — 1.5 minutos

**Por qué este:** Demuestra pensamiento de sysadmin (seguridad/mantenimiento) y uso de la API interna de n8n.

1. Abrir el workflow 07
2. Explicar: "Este se ejecuta cada noche a las 2 AM. Llama a la API interna de n8n para exportar todos los workflows y los sube a Google Drive como copia de seguridad"
3. **Ejecutar manualmente** para mostrar que genera el archivo JSON
4. Mostrar el nombre del archivo con la fecha: `backup-n8n-2025-06-XX.json`

> "Si el USB se pierde o el equipo falla, los workflows están a salvo en la nube. Es una capa de seguridad que funciona sola una vez configurada."

---

## PARTE 3 — CIERRE (2 minutos)

### Resultados (45 segundos)

> "En resumen: el proyecto cumple todos los objetivos que planteé en el anteproyecto. Tenemos una infraestructura Docker portátil que arranca con un script, 10 automatizaciones funcionales que cubren las necesidades reales de un centro educativo, documentación completa, y distribución tanto por USB como por GitHub."

Mencionar datos concretos:
- 10 workflows en 5 categorías
- 4 scripts multiplataforma con auto-instalación
- 7 capítulos de memoria + manuales de instalación y uso
- Probado en Windows, Linux y macOS

### Ampliaciones futuras (45 segundos)

> "El sistema está diseñado para crecer. Las principales líneas de ampliación que propongo son:"

Mencionar solo 3 (las más impactantes):
1. **Generación de contenido con IA** — Crear exámenes y resúmenes automáticamente usando APIs de modelos de lenguaje
2. **Integración con Google Classroom/Moodle** — Sincronizar notas y tareas con las plataformas que ya usan los centros
3. **Despliegue en la nube** — Para centros que prefieran acceso remoto en vez de USB

### Frase final (15 segundos)

> "La idea con la que empecé era 'solo tener que pensar una vez'. Creo que el proyecto lo demuestra: cada una de estas automatizaciones resuelve un problema real y, una vez configurada, funciona sola. Eso es lo que quería conseguir."

> "Estoy abierto a vuestras preguntas."

---

## PREGUNTAS FRECUENTES DEL TRIBUNAL (preparación)

### "¿Por qué n8n y no Zapier, Make o Power Automate?"

> "n8n es open source y self-hosted. Eso significa que no depende de un servicio en la nube, no tiene costes de suscripción y funciona sin conexión a Internet (excepto para las integraciones con Google). Para un centro educativo con presupuesto limitado, esto es clave. Además, n8n permite alojar todo en un contenedor Docker, que es lo que hace posible la portabilidad en USB."

### "¿Por qué Docker y no una instalación directa de n8n?"

> "Docker garantiza que el entorno es siempre el mismo, independientemente del sistema operativo o la configuración del equipo. Si instalara n8n directamente, tendría que gestionar versiones de Node.js, dependencias del sistema, rutas de archivos diferentes en cada OS... Con Docker, un solo archivo docker-compose.yml define todo lo necesario. Además, el bind mount permite que los datos vivan dentro de la carpeta del proyecto, lo que es imprescindible para la portabilidad USB."

### "¿Has probado la portabilidad real en USB?"

> "Sí. Copié la carpeta completa a un USB, la conecté a otro equipo con Docker instalado, ejecuté el script de arranque y todos los workflows estaban disponibles con sus datos. La base de datos SQLite y la configuración viajan dentro de la carpeta n8n-data."

### "¿Qué pasa si Docker no está instalado?"

> "Los scripts de arranque lo detectan automáticamente. En Windows intentan instalarlo con winget, en Linux con el script oficial de Docker, y en macOS con Homebrew. Si la instalación automática no es posible, muestran un mensaje con instrucciones para instalarlo manualmente."

### "¿Cómo configura las credenciales un profesor sin conocimientos técnicos?"

> "Cada workflow tiene una Sticky Note con instrucciones paso a paso: qué credenciales necesita, cómo crearlas en n8n, y qué datos poner. Además, en el capítulo 6 de la memoria hay un manual de uso con capturas de pantalla. La idea es que el profesor solo tenga que seguir los pasos una vez."

### "¿Qué limitaciones tiene el sistema?"

> "La principal es que necesita conexión a Internet para las integraciones con Google (Sheets, Drive, Gmail). Si el equipo no tiene conexión, los workflows que dependen de Google no funcionan. Otra limitación es que SQLite no soporta acceso concurrente desde varios equipos, así que el sistema está pensado para uso individual, no para un servidor compartido."

### "¿Qué harías diferente si empezaras de nuevo?"

> "Probablemente empezaría por definir un esquema estándar para las hojas de Google Sheets. Ahora cada workflow tiene su propia estructura de columnas, y si el profesor cambia un nombre de columna, el workflow falla. Sería mejor tener plantillas de Sheets predefinidas y validar los datos de entrada antes de procesarlos."

### "¿Se podría usar en un centro real?"

> "Sí, con algunas adaptaciones. Habría que configurar las credenciales con las cuentas reales del centro, ajustar los horarios de los cron jobs al calendario escolar, y posiblemente añadir los emails reales de los profesores y familias en las hojas de cálculo. La infraestructura está lista; lo que falta es la personalización para cada centro concreto."

---

## CONSEJOS PARA LA PRESENTACION

1. **No leas.** Conoces el proyecto mejor que nadie. Habla de lo que has hecho como si se lo explicaras a un compañero.
2. **La demo es tu mejor arma.** Un workflow ejecutándose en directo vale más que 20 slides.
3. **Controla el tiempo.** Ensaya con cronómetro. Si te pasas de 10 minutos, corta por la demo 3.
4. **Prepara el plan B.** Si Docker no arranca, ten capturas de pantalla listas.
5. **Las preguntas no son un ataque.** El tribunal quiere que demuestres que entiendes lo que has hecho. Si no sabes algo, di "No lo he investigado, pero lo abordaría de esta forma..."
6. **Ensaya la demo 3 veces.** La primera vez algo fallará. La segunda irá mejor. La tercera será natural.
