# GUION DE LA DEFENSA ORAL

**Proyecto:** Implementación de automatizaciones para entornos educativos
**Alumno:** Liher Ríos Ruiz
**Ciclo:** CFGS ASIR — Salesianos Los Boscos
**Duración objetivo:** 10 minutos de exposición + preguntas del tribunal

---

## ANTES DE EMPEZAR (checklist técnica)

- [ ] Portátil encendido con Docker Desktop arrancado
- [ ] n8n corriendo en http://localhost:5678 (ejecutar `scripts/start.bat` 5 minutos antes)
- [ ] Los 21 workflows importados y visibles en n8n
- [ ] Navegador abierto con dos pestañas: n8n y una hoja de Google Sheets de ejemplo
- [ ] WiFi desconectado para la demo offline (o preparado para desconectarlo)
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
> "El sistema se puede llevar en un USB. El profesor ejecuta un script, se abre n8n en el navegador, y ya tiene disponibles 21 automatizaciones listas para usar. De estas 21, 6 funcionan completamente sin Internet, almacenando los datos en la base de datos SQLite interna de n8n. Los scripts de arranque detectan si Docker está instalado y, si no lo está, lo instalan automáticamente. Funciona en Windows, Linux y macOS."

**Puntos clave a mencionar:**
- Docker + SQLite = portabilidad total (USB)
- 21 workflows: 15 online + 6 offline
- Los offline usan `$getWorkflowStaticData` para almacenar datos sin Internet
- Scripts multiplataforma con auto-instalación de Docker
- Comparativa formal: n8n elegido sobre Zapier, Make y Power Automate

### Slide 4: Los 21 workflows (1 minuto)

> "He desarrollado 21 automatizaciones organizadas en 8 categorías y dos modos de funcionamiento:"

Enumerar rápido por categorías, SIN detenerse en cada uno:

| Categoría | Workflows (online) | Workflows (offline) |
|-----------|-------------------|-------------------|
| Comunicaciones | Email masivo, Google Forms, boletín semanal, recordatorio entregas | — |
| Gestión académica | Recordatorio reuniones, control asistencia, notas trimestre, informe mensual | Calculadora de notas offline |
| Gestión TIC | Inventario equipos | Control de préstamos offline |
| Convivencia | Cumpleaños alumnos | Registro de incidencias |
| Alertas | Absentismo acumulado | — |
| Gestión de recursos/personal | Solicitud material, guardias/sustituciones | — |
| Calidad | Encuesta satisfacción | — |
| Herramientas docentes/TIC/Admin | — | Generador contraseñas, sorteo grupos, diario actividad |
| Mantenimiento | Backup automático | — |

> "Ahora os voy a enseñar cómo funciona esto en la práctica."

---

## PARTE 2 — DEMO EN DIRECTO (5 minutos)

**Estrategia:** Mostrar 3 workflows que demuestren: un online clásico, un offline sin Internet, y uno con webhook técnico.

### Demo 1: Email masivo a padres (workflow 01) — 1.5 minutos

**Por qué este:** Es el más visual y fácil de entender. Trigger manual. Demuestra el modo online.

1. Abrir n8n y mostrar el workflow 01
2. Señalar la Sticky Note amarilla: "Cada workflow tiene una nota explicativa con instrucciones"
3. Recorrer los nodos: "Lee de Google Sheets → filtra emails vacíos → personaliza el mensaje → envía por SMTP"
4. **Ejecutar el workflow** con datos de prueba
5. Mostrar el resultado: "Se han enviado X emails personalizados en 2 segundos. Manualmente esto lleva media hora"

> "Fijaos en que el nodo IF filtra automáticamente las filas sin email. En un listado real siempre hay algún dato que falta, y sin este filtro el workflow fallaría."

### Demo 2: Calculadora de notas OFFLINE (workflow 16) — 2 minutos

**Por qué este:** Demuestra la gran novedad del proyecto: funcionar sin Internet. Impacto visual de desconectar el WiFi.

1. **Desconectar el WiFi** del portátil (hacerlo visible para el tribunal)
2. Abrir el workflow 16 en n8n
3. Explicar: "Este workflow funciona al 100% sin Internet. Los datos se almacenan en la base de datos SQLite interna de n8n, que viaja con el USB"
4. **Registrar notas** con curl:
   ```
   curl -X POST http://localhost:5678/webhook/calcular-notas ^
     -H "Content-Type: application/json" ^
     -d "{\"alumno\":\"Maria Garcia\",\"curso\":\"2ESO-A\",\"examen\":7.5,\"trabajo\":8,\"participacion\":9}"
   ```
5. Mostrar la respuesta: media ponderada 7.95, calificación "Notable"
6. **Consultar el histórico** para demostrar que los datos persisten:
   ```
   curl -X POST http://localhost:5678/webhook/calcular-notas ^
     -H "Content-Type: application/json" ^
     -d "{\"accion\":\"consultar\",\"curso\":\"2ESO-A\"}"
   ```

> "Sin WiFi, sin Google Sheets, sin nada externo. Todo funciona dentro del contenedor Docker. Esto es lo que hace el sistema verdaderamente portátil: un profesor puede llevarse el USB a un aula sin Internet y seguir trabajando."

7. **Reconectar el WiFi** (para la siguiente demo si la necesitas)

### Demo 3: Control de asistencia online (workflow 04) — 1.5 minutos

**Por qué este:** Usa webhook + lógica condicional + respuesta al remitente. Contrasta con la demo offline.

1. Abrir el workflow 04 en n8n
2. Explicar: "Este se activa cuando recibe una petición HTTP. Podría venir de una app móvil, de un formulario o de un lector de tarjetas. A diferencia del anterior, este sí necesita Internet para guardar en Google Sheets y enviar email"
3. **Lanzar una petición de prueba**:
   ```
   curl -X POST http://localhost:5678/webhook/asistencia ^
     -H "Content-Type: application/json" ^
     -d "{\"alumno\":\"Maria Garcia\",\"curso\":\"2ESO-A\",\"presente\":false,\"motivo\":\"Cita medica\"}"
   ```
4. Mostrar cómo el workflow registra, detecta ausencia, notifica a la familia y devuelve confirmación JSON

> "La diferencia clave entre estos dos modos: los online se integran con servicios externos y dan más funcionalidad, pero los offline garantizan que el sistema funciona siempre, incluso sin conectividad."

---

## PARTE 3 — CIERRE (2 minutos)

### Resultados (45 segundos)

> "En resumen: el proyecto cumple todos los objetivos que planteé en el anteproyecto y va más allá. Tenemos una infraestructura Docker portátil que arranca con un script, 21 automatizaciones funcionales (15 online y 6 offline) que cubren 8 categorías distintas, documentación completa con diagramas y comparativa tecnológica, y distribución tanto por USB como por GitHub."

Mencionar datos concretos:
- 21 workflows en 8 categorías (15 online + 6 offline)
- 6 workflows 100% offline con SQLite interno
- 4 scripts multiplataforma con auto-instalación
- Comparativa formal: n8n vs Zapier vs Make vs Power Automate
- 7 capítulos de memoria + diagramas + manuales de instalación y uso
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

> "En el capítulo 1 de la memoria incluyo una comparativa formal con tabla de criterios. En resumen: n8n es la única plataforma que es open source, self-hosted, y permite funcionar sin Internet. Zapier y Make son solo cloud y tienen costes de suscripción. Power Automate requiere licencia Microsoft. Para un centro educativo con presupuesto ajustado que necesita portabilidad USB, n8n era la única opción viable."

### "¿Por qué Docker y no una instalación directa de n8n?"

> "Docker garantiza que el entorno es siempre el mismo, independientemente del sistema operativo o la configuración del equipo. Si instalara n8n directamente, tendría que gestionar versiones de Node.js, dependencias del sistema, rutas de archivos diferentes en cada OS... Con Docker, un solo archivo docker-compose.yml define todo lo necesario. Además, el bind mount permite que los datos vivan dentro de la carpeta del proyecto, lo que es imprescindible para la portabilidad USB."

### "¿Has probado la portabilidad real en USB?"

> "Sí. Copié la carpeta completa a un USB, la conecté a otro equipo con Docker instalado, ejecuté el script de arranque y todos los workflows estaban disponibles con sus datos. La base de datos SQLite y la configuración viajan dentro de la carpeta n8n-data."

### "¿Qué pasa si Docker no está instalado?"

> "Los scripts de arranque lo detectan automáticamente. En Windows intentan instalarlo con winget, en Linux con el script oficial de Docker, y en macOS con Homebrew. Si la instalación automática no es posible, muestran un mensaje con instrucciones para instalarlo manualmente."

### "¿Cómo configura las credenciales un profesor sin conocimientos técnicos?"

> "Cada workflow tiene una Sticky Note con instrucciones paso a paso: qué credenciales necesita, cómo crearlas en n8n, y qué datos poner. Además, en el capítulo 6 de la memoria hay un manual de uso con capturas de pantalla. La idea es que el profesor solo tenga que seguir los pasos una vez."

### "¿Qué limitaciones tiene el sistema?"

> "15 de los 21 workflows necesitan conexión a Internet para las integraciones con Google (Sheets, Drive, Gmail). Si el equipo no tiene conexión, esos workflows no funcionan. Sin embargo, los 6 workflows offline sí funcionan sin Internet, que fue precisamente una de las mejoras que añadí al proyecto. Otra limitación es que SQLite no soporta acceso concurrente desde varios equipos, así que el sistema está pensado para uso individual, no para un servidor compartido."

### "¿Cómo funcionan los workflows offline internamente?"

> "Usan una API de n8n llamada `$getWorkflowStaticData('global')` que permite leer y escribir datos directamente en la base de datos SQLite interna de n8n. Los datos son persistentes: sobreviven reinicios del contenedor y viajan con el USB. Técnicamente es como tener una base de datos clave-valor integrada en el propio motor de automatización, sin necesidad de configurar nada adicional."

### "¿Qué harías diferente si empezaras de nuevo?"

> "Probablemente empezaría por definir un esquema estándar para las hojas de Google Sheets. Ahora cada workflow tiene su propia estructura de columnas, y si el profesor cambia un nombre de columna, el workflow falla. Sería mejor tener plantillas de Sheets predefinidas y validar los datos de entrada antes de procesarlos."

### "¿Se podría usar en un centro real?"

> "Sí, con algunas adaptaciones. Habría que configurar las credenciales con las cuentas reales del centro, ajustar los horarios de los cron jobs al calendario escolar, y añadir los emails reales en las hojas de cálculo. Los workflows offline están listos para usarse directamente, sin configuración adicional. La infraestructura está lista; lo que falta es la personalización de datos para cada centro concreto."

---

## CONSEJOS PARA LA PRESENTACION

1. **No leas.** Conoces el proyecto mejor que nadie. Habla de lo que has hecho como si se lo explicaras a un compañero.
2. **La demo es tu mejor arma.** Un workflow ejecutándose en directo vale más que 20 slides.
3. **Controla el tiempo.** Ensaya con cronómetro. Si te pasas de 10 minutos, corta por la demo 3.
4. **Prepara el plan B.** Si Docker no arranca, ten capturas de pantalla listas.
5. **Las preguntas no son un ataque.** El tribunal quiere que demuestres que entiendes lo que has hecho. Si no sabes algo, di "No lo he investigado, pero lo abordaría de esta forma..."
6. **Ensaya la demo 3 veces.** La primera vez algo fallará. La segunda irá mejor. La tercera será natural.
