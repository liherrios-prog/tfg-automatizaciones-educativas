# 4. FASE DE PRUEBAS

## 4.1 Metodología

Para cada workflow preparé datos de ejemplo y ejecuté el flujo completo desde la interfaz de n8n o mediante `curl` al webhook. Las pruebas cubren tres tipos de escenarios: el caso normal (datos correctos, flujo completo), casos límite (campos vacíos, datos ausentes, situaciones extremas) y casos de error (entradas inválidas, servicios no disponibles).

Los workflows offline (16-21) se probaron con el WiFi físicamente desconectado. Los workflows 22 y 23 se probaron generando archivos reales y verificando el contenido de cada salida.

La tabla completa con los datos de entrada y salida de las 51 pruebas está en el Anexo B.

## 4.2 Resumen de resultados

| Categoría | Pruebas | Correctas | Fallidas |
|-----------|---------|-----------|---------|
| Infraestructura (arranque, persistencia, USB) | 6 | 6 | 0 |
| Workflows online (01-15) | 18 | 18 | 0 |
| Workflows offline (16-21) | 14 | 14 | 0 |
| Herramientas de productividad (22-23) | 9 | 9 | 0 |
| Errores y casos límite | 4 | 4 | 0 |
| **Total** | **51** | **51** | **0** |

Todas las pruebas se superaron. En algunos casos (celdas vacías en notas, registros duplicados de asistencia) el comportamiento no era ideal pero sí predecible y coherente, y queda documentado como posible mejora futura.

## 4.3 Casos destacados

De las 51 pruebas, selecciono las más representativas.

**Portabilidad USB.** Copié la carpeta completa del proyecto a un USB y lo conecté a otro ordenador del aula con Docker Desktop instalado. Al ejecutar `start.bat`, n8n arrancó con los mismos workflows y datos. Solo era necesario que el otro equipo tuviera Docker.

**Workflows offline con WiFi desconectado.** Registré datos en los workflows 16-21 con el WiFi físicamente desconectado. Todos respondieron correctamente. Después paré el contenedor con `stop.bat` y lo volví a arrancar; los datos seguían disponibles. SQLite los conserva en `n8n-data/database.sqlite`.

**USB extraído en caliente.** Lo extraje sin "Expulsar de forma segura" mientras n8n estaba corriendo. El contenedor se detuvo con errores de lectura. Al reconectarlo y arrancar, los datos se conservaron hasta el momento de la extracción, sin corrupción de la base de datos. La recomendación es siempre parar con `stop.bat` antes de extraer.

**Diploma autocontenido.** Generé un diploma con el workflow 23 y lo abrí en un navegador sin conexión a Internet. El logo de Salesianos Los Boscos se mostró correctamente porque está codificado en Base64 dentro del propio HTML. También lo copié a otro equipo sin el USB conectado y funcionó igual.

**Archivo Excel protegido con contraseña.** Incluí un `.xls` con contraseña en el lote del workflow 22. Apareció en el reporte con `estado: error` y el mensaje de SheetJS. Los demás archivos del lote se convirtieron sin problema. El workflow no se interrumpió.

**Tipo de incidencia inválido.** Envié al webhook del workflow 17 un tipo no permitido (`"tipo": "moderada"`). La respuesta fue inmediata: `"error": "Tipo no válido. Use: leve, grave, muy_grave"`. El workflow valida la entrada antes de guardar.

## 4.4 Comportamiento ante errores frecuentes

**Sin conexión a Internet.** Los workflows offline siguen funcionando sin problema. Los online fallan con error de conexión en el nodo de Google Sheets o SMTP y se recuperan solos al volver a haber conexión.

**Puerto ocupado.** Si el puerto 5678 ya está en uso, Docker muestra `Bind for 0.0.0.0:5678 failed: port is already allocated`. Se resuelve cambiando `N8N_PORT` en `.env` y reiniciando.

**Docker no arrancado.** Los scripts esperan hasta 60 segundos a que Docker arranque. Si no responde, muestran un mensaje pidiendo que se inicie manualmente.

## 4.5 Cobertura por workflow

| Workflow | Funcional | Caso límite | Offline verificado |
|----------|:---------:|:-----------:|:------------------:|
| 01 - Email Masivo | ✓ | ✓ (email vacío) | — |
| 02 - Google Forms | ✓ | ✓ (campos incompletos) | — |
| 03 - Recordatorio Reuniones | ✓ | ✓ (semana sin reuniones) | — |
| 04 - Control Asistencia | ✓ | ✓ (registro duplicado) | — |
| 05 - Consolidar Notas | ✓ | ✓ (celdas vacías) | — |
| 06 - Informe Asistencia | ✓ | ✓ (mes sin registros) | — |
| 07 - Backup Automático | ✓ | — | — |
| 08 - Recordatorio Entregas | ✓ | ✓ (sin eventos próximos) | — |
| 09 - Inventario TIC | ✓ | — | — |
| 10 - Cumpleaños Alumnos | ✓ | ✓ (día sin cumpleaños) | — |
| 11 - Alerta Absentismo | ✓ | ✓ (sin absentismo) | — |
| 12 - Boletín Semanal | ✓ | ✓ (curso sin email) | — |
| 13 - Solicitud Material | ✓ | ✓ (no urgente) | — |
| 14 - Guardias | ✓ | ✓ (sin sustituto) | — |
| 15 - Encuesta Satisfacción | ✓ | — | — |
| 16 - Calculadora Notas | ✓ | ✓ (curso sin datos) | ✓ |
| 17 - Registro Incidencias | ✓ | ✓ (tipo inválido) | ✓ |
| 18 - Generador Contraseñas | ✓ | ✓ (sin ambiguos) | ✓ |
| 19 - Control Préstamos | ✓ | ✓ (equipo ya prestado, retraso 7d) | ✓ |
| 20 - Sorteo Grupos | ✓ | ✓ (número impar) | ✓ |
| 21 - Diario Actividad | ✓ | — | ✓ |
| 22 - Convertidor Excel | ✓ | ✓ (archivo protegido, carpeta vacía) | ✓ |
| 23 - Generador Diplomas | ✓ | ✓ (sin email, sin logo, Excel inválido) | ✓ |
