# 4. FASE DE PRUEBAS

## 4.1 Pruebas realizadas

A continuación se documenta la batería de pruebas realizadas para verificar el correcto funcionamiento del sistema.

### 4.1.1 Pruebas de infraestructura

| Prueba | Descripción | Resultado esperado | Resultado obtenido |
|--------|-------------|-------------------|-------------------|
| Arranque del contenedor | Ejecutar `scripts/start.bat` | n8n accesible en `http://localhost:5678` | Correcto. n8n arranca en unos 10 segundos y se accede desde el navegador sin problemas. La primera vez tarda algo más porque Docker descarga la imagen. |
| Persistencia de datos | Crear un workflow, parar y reiniciar el contenedor | El workflow sigue disponible tras reiniciar | Correcto. Creé un workflow de prueba, paré el contenedor con `stop.bat` y al volver a arrancar el workflow seguía ahí con todos los nodos y configuraciones intactos. Los datos se guardan en la carpeta `n8n-data/`. |
| Portabilidad USB | Copiar la carpeta completa a otro equipo con Docker | n8n arranca con los mismos workflows y datos | Correcto. Copié toda la carpeta a un USB y lo probé en otro ordenador del aula. Al ejecutar `start.bat` arrancó con los mismos workflows y credenciales. Solo hizo falta que el otro equipo tuviera Docker Desktop instalado. |
| Creación automática de `.env` | Arrancar sin archivo `.env` existente | Se crea `.env` desde `.env.example` automáticamente | Correcto. Borré el archivo `.env` y al ejecutar `start.bat` el script detectó que no existía, copió `.env.example` como `.env` y arrancó con la configuración por defecto. |
| Parada limpia | Ejecutar `scripts/stop.bat` | El contenedor se detiene sin pérdida de datos | Correcto. El contenedor se detuvo de forma limpia en unos 3 segundos. Al volver a arrancar, todos los datos seguían disponibles sin ninguna pérdida. |
| Cambio de puerto | Modificar `N8N_PORT` en `.env` y reiniciar | n8n escucha en el nuevo puerto | Correcto. Cambié el puerto a 8080 en el `.env`, reinicié y n8n respondía en `http://localhost:8080`. Al volver a poner 5678 y reiniciar, todo funcionaba como antes. |

### 4.1.2 Pruebas de workflows

Para probar cada workflow preparé datos de ejemplo e hice ejecuciones manuales desde la interfaz de n8n. En algunos casos usé `curl` para simular peticiones al webhook.

| Prueba | Workflow | Entrada de prueba | Salida esperada | Salida obtenida | Resultado |
|--------|----------|-------------------|-----------------|-----------------|-----------|
| Envío masivo a lista de alumnos | Email Masivo | Hoja de Google Sheets con 5 filas de prueba (nombre, email, curso) y una plantilla de mensaje | Se envía un email personalizado a cada dirección de la hoja | Se enviaron los 5 emails correctamente. Cada uno incluía el nombre del alumno y su curso en el cuerpo del mensaje | Correcto |
| Envío con campo email vacío | Email Masivo | Misma hoja pero con una fila sin email | Se saltan las filas sin email y se envían el resto | n8n saltó la fila vacía y envió 4 emails. En el log apareció un aviso de que se omitió una fila | Correcto |
| Recepción de respuesta de formulario | Google Forms | POST con `curl` al webhook simulando una respuesta de Google Forms con campos nombre, asignatura y valoración | n8n recibe los datos, los procesa y los registra en Google Sheets | Los datos llegaron al webhook y se insertaron en la hoja de cálculo en una fila nueva con todos los campos correctos | Correcto |
| Formulario con campos incompletos | Google Forms | POST al webhook con el campo valoración vacío | Se registra la fila con el campo vacío | La fila se insertó con la celda de valoración en blanco, sin errores | Correcto |
| Recordatorio de reuniones de la semana | Recordatorio Reuniones | Calendario de Google con 3 reuniones creadas en la semana actual | Se envía un email resumen con las reuniones de la semana | Se recibió el email con el listado de las 3 reuniones, incluyendo fecha, hora y título de cada una | Correcto |
| Semana sin reuniones | Recordatorio Reuniones | Calendario sin ninguna reunión en la semana | Se envía email indicando que no hay reuniones programadas | Se recibió el email indicando que no había reuniones para la semana. El mensaje era claro | Correcto |
| Registro de asistencia | Control Asistencia | POST al webhook con JSON: alumno, fecha, estado (presente/ausente) y asignatura | Se registra la asistencia en Google Sheets | La fila se añadió correctamente en la hoja de asistencia con todos los campos | Correcto |
| Registro duplicado mismo día | Control Asistencia | POST con los mismos datos de alumno y fecha que una entrada anterior | Se actualiza el registro existente o se crea uno nuevo según la configuración | Se creó una nueva fila. Esto lo tuve en cuenta: el workflow no comprueba duplicados, así que es responsabilidad del usuario no enviar dos veces el mismo registro | Funciona según lo esperado |
| Consolidación de notas | Consolidar Notas | Hoja de Google Sheets con notas de 8 alumnos en 3 asignaturas (algunos con notas pendientes) | Se genera una hoja resumen con la media de cada alumno y un listado de suspensos | La hoja resumen se creó con las medias calculadas correctamente. Los alumnos con alguna nota por debajo de 5 aparecían marcados en el listado de suspensos | Correcto |
| Notas con celdas vacías | Consolidar Notas | Misma hoja pero con 2 alumnos sin nota en una asignatura | Se calcula la media solo con las notas disponibles | Las celdas vacías se trataron como 0 en la media. Esto es algo que habría que mejorar, pero funciona de forma predecible | Funciona según lo esperado |
| Generación de informe mensual | Informe Asistencia | Registros de asistencia del mes anterior en Google Sheets (20 días lectivos, 15 alumnos) | Se genera un informe con porcentaje de asistencia por alumno y resumen general | El informe se generó correctamente con los porcentajes de cada alumno y el porcentaje global del grupo. Se envió por email al profesor | Correcto |
| Mes sin registros | Informe Asistencia | Hoja de asistencia vacía para el mes consultado | Se genera un informe indicando que no hay datos | El workflow detectó que no había registros y envió un email informando de que no se encontraron datos de asistencia para ese mes | Correcto |
| Backup diario de workflows | Backup Datos | Ejecución manual del trigger con 3 workflows activos en n8n | Se genera un archivo JSON con los 3 workflows y se sube a Google Drive | El archivo se generó con el nombre correcto (backup-n8n-fecha.json) y contenía los 3 workflows completos. Se subió a la carpeta configurada de Drive | Correcto |
| Recordatorio de examen próximo | Entregas y Exámenes | Hoja con un examen programado para mañana y otro para dentro de 5 días | Se envía recordatorio solo del examen de mañana (dentro de la ventana de 3 días) | Se envió el email con la etiqueta "MAÑANA" en el asunto. El examen de dentro de 5 días no generó notificación | Correcto |
| Día sin eventos próximos | Entregas y Exámenes | Hoja con todos los eventos en fechas posteriores a 3 días | No se envía ningún email | El workflow terminó sin enviar nada, según lo esperado | Correcto |
| Préstamo de equipo | Inventario TIC | POST al webhook con `{ equipo: "PORTATIL-012", accion: "prestar", profesor: "García" }` | Se registra el préstamo en Google Sheets con estado "prestado" | La fila se añadió correctamente con la fecha, hora y estado. El webhook devolvió la confirmación JSON | Correcto |
| Devolución de equipo | Inventario TIC | POST al webhook con `{ equipo: "PORTATIL-012", accion: "devolver", profesor: "García" }` | Se registra la devolución con estado "disponible" | Nueva fila con estado "disponible" y la fecha/hora de devolución. El historial de préstamo anterior se conservó | Correcto |
| Cumpleaños detectado | Cumpleaños Alumnos | Hoja con un alumno cuya fecha de nacimiento coincide con hoy (día y mes) | Se envía email al tutor informando del cumpleaños | El tutor recibió el email con el nombre del alumno y la edad que cumple | Correcto |
| Día sin cumpleaños | Cumpleaños Alumnos | Hoja con alumnos cuyas fechas de nacimiento no coinciden con hoy | No se envía ningún email | El workflow terminó sin enviar nada | Correcto |

### 4.1.3 Pruebas de errores y casos límite

Además de las pruebas funcionales, quise comprobar qué pasa cuando las cosas van mal. Es importante documentar estos casos porque un profesor que use el sistema en su centro puede encontrarse con cualquiera de estas situaciones.

**Docker no está arrancado**

Los scripts de arranque detectan automáticamente si Docker no está instalado e intentan instalarlo (mediante `winget` en Windows, el script oficial de Docker en Linux, o Homebrew en macOS). Si Docker está instalado pero no arrancado, los scripts intentan iniciarlo y esperan hasta 60 segundos. Si tras ese tiempo no arranca, muestran un mensaje pidiendo al usuario que lo inicie manualmente.

**Puerto ocupado por otra aplicación**

Si el puerto 5678 ya está siendo usado por otro programa, Docker muestra un error `Bind for 0.0.0.0:5678 failed: port is already allocated`. La solución es sencilla: abrir el archivo `.env`, cambiar `N8N_PORT` a otro valor (por ejemplo 8080) y volver a arrancar. También se puede cerrar la aplicación que esté usando ese puerto, aunque lo más rápido es cambiar el puerto en el `.env`.

**Sin conexión a Internet**

Probé a desconectar el WiFi con n8n ya arrancado. Los workflows que trabajan solo con datos locales siguen funcionando sin problema. Sin embargo, los que necesitan conectarse a Google Sheets o enviar emails fallan con un error de conexión. n8n muestra el error en el nodo correspondiente y el resto del workflow no se ejecuta. En cuanto se recupera la conexión, al volver a ejecutar el workflow funciona con normalidad. Esto es algo a tener en cuenta: si el centro tiene cortes de Internet frecuentes, los workflows que dependen de servicios externos no van a funcionar en esos momentos.

**USB extraído en caliente**

Esta prueba la hice con cuidado. Arranqué n8n desde el USB y mientras estaba funcionando, extraje el USB sin hacer "Expulsar de forma segura". Lo que pasó es que n8n se detuvo inmediatamente y Docker mostró errores de lectura del volumen. Al volver a conectar el USB y arrancar, los datos se habían conservado hasta el momento de la extracción, ya que SQLite guarda los datos de forma periódica. No hubo corrupción de la base de datos, aunque esto podría ocurrir si se extrae justo en medio de una escritura. La recomendación es siempre parar n8n con `stop.bat` antes de extraer el USB.
