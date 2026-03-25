# 1. ESTUDIO DEL PROBLEMA Y ANÁLISIS DEL SISTEMA

## 1.1 Introducción

Este proyecto consiste en la implementación de un sistema de automatizaciones orientado a entornos educativos. Mediante el uso de la herramienta n8n, desplegada sobre contenedores Docker, se busca proporcionar una solución portátil y ligera que permita a profesores y personal administrativo de colegios y academias automatizar tareas repetitivas del día a día.

La solución se distribuye como un paquete autocontenido que puede ejecutarse desde un USB o clonarse desde un repositorio de GitHub, sin necesidad de instalaciones complejas ni conocimientos avanzados de sistemas. El usuario solo necesita tener Docker instalado en su equipo.

## 1.2 Motivación y finalidad

En los entornos educativos existe una gran cantidad de tareas administrativas y de comunicación que se repiten con frecuencia: enviar notificaciones a familias, generar informes de seguimiento, consolidar datos de evaluación, preparar material didáctico, entre otras. Estas tareas consumen un tiempo considerable que podría dedicarse a la enseñanza y la atención al alumnado.

La motivación de este proyecto parte de una idea sencilla: "solo tener que pensar una vez". Si una tarea se puede definir como un proceso con pasos claros, se puede automatizar. Una vez creada la automatización, el problema queda resuelto de forma indefinida, ejecutándose con un solo click cada vez que sea necesario.

La finalidad es optimizar el trabajo del personal educativo, reduciendo el tiempo invertido en tareas mecánicas y permitiendo dedicar más recursos al trabajo pedagógico.

## 1.3 Alcance y objetivos

### Alcance

El sistema implementado ofrece:

- Una infraestructura Docker portátil que incluye n8n como motor de automatización y SQLite como base de datos para persistencia.
- Scripts de instalación y arranque multiplataforma (Windows y Linux) para facilitar la puesta en marcha.
- Un conjunto de workflows de automatización agrupados en siete categorías: comunicaciones educativas, gestión académica, mantenimiento, gestión TIC, convivencia, gestión de recursos y gestión de personal docente.
- Documentación completa que incluye manuales de instalación y de uso.
- Un repositorio en GitHub como canal de distribución alternativo al USB.

### Objetivos

1. Desplegar un entorno n8n funcional mediante Docker Compose que sea completamente portátil y no requiera descargas adicionales una vez instalado.
2. Crear automatizaciones útiles para tareas reales de un entorno educativo, cubriendo las áreas de comunicación, gestión académica, mantenimiento, gestión TIC, convivencia, gestión de recursos y gestión de personal.
3. Documentar todo el proceso de forma que cualquier usuario con conocimientos básicos pueda poner en marcha el sistema y utilizar los workflows.
4. Proporcionar una solución escalable donde se puedan añadir nuevas automatizaciones según las necesidades del centro.

## 1.4 Planificación temporal

El desarrollo del proyecto se organiza en las siguientes fases:

| Fase | Descripción | Dependencias |
|------|-------------|-------------- |
| 1. Infraestructura Docker | Configuración de Docker Compose con n8n y SQLite, persistencia mediante bind mounts | Ninguna |
| 2. Scripts de instalación | Scripts de arranque y parada multiplataforma | Fase 1 |
| 3. Workflows de comunicaciones | Automatizaciones de emails, notificaciones y avisos | Fase 1 |
| 4. Workflows de gestión académica | Automatizaciones de notas, asistencia y administración | Fase 1 |
| 5. Workflows de gestión de recursos, personal y calidad | Automatizaciones de solicitudes, guardias, alertas y encuestas | Fase 1 |
| 6. Repositorio GitHub | Estructura del repositorio y documentación de distribución | Fases 1-5 |
| 7. Documentación | Memoria completa del proyecto siguiendo la plantilla del centro | Todas |

El setup inicial de la infraestructura Docker es sencillo y rápido. El grueso del trabajo recae en la creación de workflows, ya que el proyecto es altamente escalable: se pueden crear tantas automatizaciones como se necesiten, y cada una requiere su propio diseño, implementación y pruebas.
