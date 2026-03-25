# 5. CONCLUSIONES FINALES

## 5.1 Grado de cumplimiento de los objetivos fijados

Una vez terminado el desarrollo y las pruebas, toca hacer balance de lo que se ha conseguido respecto a los objetivos que planteé al inicio del proyecto.

| Objetivo | Estado | Observaciones |
|----------|--------|--------------|
| Entorno n8n portátil mediante Docker | Cumplido | El sistema arranca con un solo script, funciona en cualquier equipo con Docker y los datos se mantienen entre sesiones. Se ha probado la portabilidad copiando la carpeta a un USB y usándola en otros equipos. |
| Automatizaciones de comunicaciones educativas | Cumplido | Se han desarrollado 3 workflows de comunicaciones: envío de emails masivos personalizados, recepción/procesamiento de respuestas de Google Forms, y recordatorio de entregas y exámenes a los alumnos. Todos funcionan correctamente en las pruebas. |
| Automatizaciones de gestión académica | Cumplido | Se han implementado 5 workflows: recordatorio de reuniones, control de asistencia, consolidación de notas, informe mensual de asistencia y gestión de inventario TIC. Cubren las tareas administrativas más repetitivas que tiene un centro educativo. |
| Automatizaciones de mantenimiento y convivencia | Cumplido | Se han añadido 2 workflows adicionales: backup automático de datos a Google Drive y notificación de cumpleaños de alumnos al tutor. Demuestran que las automatizaciones pueden ir más allá de lo administrativo. |
| Documentación completa del sistema | Cumplido | Se ha documentado todo el sistema: manual de instalación, manual de uso, descripción de cada workflow y esta misma memoria. Un profesor sin conocimientos técnicos avanzados debería poder instalar y usar el sistema siguiendo la documentación. |
| Distribución vía USB y GitHub | Cumplido | El proyecto se distribuye tanto en un repositorio de GitHub como en una carpeta preparada para copiar a un USB. Ambos métodos han sido probados y funcionan correctamente. |

En general estoy satisfecho con el resultado. El objetivo principal, que era facilitar la vida al profesorado automatizando tareas repetitivas, se ha cumplido con creces. Los 10 workflows desarrollados cubren comunicaciones, gestión académica, mantenimiento del sistema, gestión TIC y convivencia, lo que demuestra la versatilidad de la solución. Además, los scripts de arranque multiplataforma con instalación automática de Docker hacen que la puesta en marcha sea realmente "en un solo click", cumpliendo la promesa del anteproyecto.

## 5.2 Propuesta de modificaciones o ampliaciones futuras

Durante el desarrollo del proyecto fui apuntando ideas que se me ocurrían pero que no daba tiempo a implementar. Aquí recojo las que me parecen más realistas y útiles como ampliaciones futuras:

1. **Workflows de generación de contenido educativo.** Es el objetivo que quedó pendiente. La idea sería crear workflows que, usando la API de un modelo de lenguaje (como la de OpenAI), generen automáticamente exámenes tipo test a partir de un temario, resúmenes de temas o ejercicios de repaso. Sería una ampliación natural del proyecto.

2. **Integración con Google Classroom y Moodle.** Muchos centros usan estas plataformas. Se podrían crear workflows que sincronicen las notas de Google Sheets con el libro de calificaciones de Classroom, o que publiquen automáticamente tareas en Moodle cuando se añaden a una hoja de cálculo. n8n tiene nodos para ambas plataformas, así que técnicamente es viable.

3. **Panel de monitorización.** Ahora mismo, para ver si un workflow ha fallado hay que entrar en n8n y revisar el historial de ejecuciones. Sería útil tener un pequeño dashboard (por ejemplo con Grafana o una página web sencilla) que muestre de un vistazo el estado de cada workflow: cuándo se ejecutó por última vez, si hubo errores, etc.

4. **Mejora del sistema de backups.** Actualmente el workflow 07 realiza un backup diario de los workflows a Google Drive. Se podría ampliar para que también exporte las credenciales (de forma cifrada), implemente una política de retención (por ejemplo, mantener solo los últimos 30 backups) e incluya un workflow de restauración automática.

5. **Guía para crear workflows personalizados.** El sistema está pensado para que lo use un profesor, pero n8n permite crear workflows sin programar. Estaría bien incluir una guía paso a paso con un ejemplo sencillo (por ejemplo, un workflow que envíe un email cuando se añade una fila a una hoja de cálculo) para que los profesores más curiosos puedan crear sus propias automatizaciones.

6. **Despliegue en la nube para centros sin infraestructura local.** La versión USB es práctica, pero algunos centros podrían preferir tener n8n en un servidor accesible desde cualquier equipo. Se podría documentar cómo desplegar el mismo `docker-compose.yml` en un VPS o en un servicio como Railway o Render, con un dominio propio y acceso por HTTPS.
