# 5. CONCLUSIONES FINALES

## 5.1 Grado de cumplimiento de los objetivos fijados

Una vez terminado el desarrollo y las pruebas, toca hacer balance de lo que se ha conseguido respecto a los objetivos que planteé al inicio del proyecto.

| Objetivo | Estado | Observaciones |
|----------|--------|--------------|
| Entorno n8n portátil mediante Docker | Cumplido | El sistema arranca con un solo script, funciona en cualquier equipo con Docker y los datos se mantienen entre sesiones. Se ha probado la portabilidad copiando la carpeta a un USB y usándola en otros equipos. |
| Automatizaciones de comunicaciones educativas | Cumplido | Se han desarrollado 4 workflows de comunicaciones: envío de emails masivos personalizados, recepción/procesamiento de respuestas de Google Forms, recordatorio de entregas y exámenes, y boletín semanal para familias. Todos funcionan correctamente en las pruebas. |
| Automatizaciones de gestión académica | Cumplido | Se han implementado 6 workflows: recordatorio de reuniones, control de asistencia, consolidación de notas, informe mensual de asistencia, gestión de inventario TIC y alerta de absentismo acumulado. Cubren las tareas administrativas más repetitivas que tiene un centro educativo. |
| Automatizaciones de mantenimiento y convivencia | Cumplido | Se han añadido 2 workflows: backup automático de datos a Google Drive y notificación de cumpleaños de alumnos al tutor. Demuestran que las automatizaciones pueden ir más allá de lo administrativo. |
| Automatizaciones de gestión de recursos, personal y calidad | Cumplido | Se han desarrollado 3 workflows adicionales: solicitud de material y recursos con notificación urgente, gestión automática de guardias y sustituciones, y encuesta de satisfacción mensual a familias. Amplían el alcance del proyecto a la gestión integral del centro. |
| Workflows offline (sin conexión a Internet) | Cumplido | Se han desarrollado 6 workflows que funcionan al 100% sin Internet, usando la base de datos SQLite interna de n8n como almacenamiento. Esto resuelve la limitación de los 15 workflows online y demuestra la portabilidad real del sistema en USB. |
| Catálogo organizado de workflows | Cumplido | Se ha creado un catálogo completo (`workflows/CATALOGO.md`) que clasifica los 21 workflows por modo (online/offline), categoría, dependencias y endpoints. Facilita la consulta rápida y demuestra un enfoque sistemático. |
| Comparativa con alternativas del mercado | Cumplido | Se ha elaborado una tabla comparativa formal (Cap. 1) entre n8n, Zapier, Make y Power Automate, justificando la elección tecnológica con criterios objetivos. |
| Documentación completa del sistema | Cumplido | Se ha documentado todo el sistema: manual de instalación, manual de uso, descripción detallada de cada workflow (los 21), diagramas de arquitectura y flujo, y esta misma memoria. Un profesor sin conocimientos técnicos avanzados debería poder instalar y usar el sistema siguiendo la documentación. |
| Distribución vía USB y GitHub | Cumplido | El proyecto se distribuye tanto en un repositorio de GitHub (https://github.com/liherrios-prog/tfg-automatizaciones-educativas) como en una carpeta preparada para copiar a un USB. Ambos métodos han sido probados y funcionan correctamente. |

En general estoy satisfecho con el resultado. El objetivo principal, que era facilitar la vida al profesorado automatizando tareas repetitivas, se ha cumplido con creces. Los 21 workflows desarrollados cubren 8 categorías: comunicaciones, gestión académica, mantenimiento del sistema, gestión TIC, convivencia, gestión de recursos, gestión de personal docente y administración. De estos 21 workflows, 6 funcionan completamente sin Internet, demostrando que el sistema es verdaderamente portátil y autónomo. Además, los scripts de arranque multiplataforma con instalación automática de Docker hacen que la puesta en marcha sea realmente "en un solo click", cumpliendo la promesa del anteproyecto.

La incorporación de los workflows offline supuso un salto cualitativo en el proyecto. El uso de `$getWorkflowStaticData('global')` para almacenar datos en la base de datos SQLite interna de n8n permite que un profesor pueda llevar el sistema en un USB, conectarlo a un ordenador sin Internet y seguir utilizando herramientas como la calculadora de notas, el registro de incidencias o el control de préstamos. Esto es especialmente relevante en centros educativos con conectividad limitada o inestable.

## 5.2 Propuesta de modificaciones o ampliaciones futuras

Durante el desarrollo del proyecto fui apuntando ideas que se me ocurrían pero que no daba tiempo a implementar. Aquí recojo las que me parecen más realistas y útiles como ampliaciones futuras:

1. **Workflows de generación de contenido educativo con IA.** La idea sería crear workflows que, usando la API de un modelo de lenguaje (como la de OpenAI o Anthropic), generen automáticamente exámenes tipo test a partir de un temario, resúmenes de temas o ejercicios de repaso personalizados. n8n tiene nodos nativos para estas APIs, lo que hace la integración sencilla.

2. **Integración con Google Classroom y Moodle.** Muchos centros usan estas plataformas. Se podrían crear workflows que sincronicen las notas con el libro de calificaciones de Classroom, o que publiquen automáticamente tareas en Moodle. n8n tiene nodos para ambas plataformas, así que técnicamente es viable.

3. **Interfaz web simplificada.** Los workflows se consumen actualmente vía webhook (con `curl` o herramientas HTTP). Se podría añadir una interfaz web sencilla (por ejemplo con HTML + JavaScript estático) que sirva como formulario frontal para los webhooks, haciendo la experiencia más amigable para profesores que no se manejen con herramientas técnicas.

4. **Más workflows offline.** Con la base técnica ya establecida (`$getWorkflowStaticData`), se podrían crear versiones offline de workflows que actualmente dependen de Google Sheets. Por ejemplo, un control de asistencia offline o un gestor de reuniones que funcione sin Internet.

5. **Panel de monitorización.** Sería útil tener un pequeño dashboard que muestre de un vistazo el estado de cada workflow: cuándo se ejecutó por última vez, si hubo errores, y estadísticas de uso.

6. **Despliegue en la nube.** La versión USB es práctica, pero algunos centros podrían preferir tener n8n en un servidor accesible desde cualquier equipo. Se podría documentar cómo desplegar el mismo `docker-compose.yml` en un VPS o en un servicio cloud, con un dominio propio y acceso por HTTPS.

7. **Guía para crear workflows personalizados.** Incluir una guía paso a paso con un ejemplo sencillo para que los profesores más curiosos puedan crear sus propias automatizaciones sin necesidad de programar.
