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

| Fase                                                    | Descripción                                                                         | Dependencias |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------ |
| 1. Infraestructura Docker                               | Configuración de Docker Compose con n8n y SQLite, persistencia mediante bind mounts | Ninguna      |
| 2. Scripts de instalación                               | Scripts de arranque y parada multiplataforma                                        | Fase 1       |
| 3. Workflows de comunicaciones                          | Automatizaciones de emails, notificaciones y avisos                                 | Fase 1       |
| 4. Workflows de gestión académica                       | Automatizaciones de notas, asistencia y administración                              | Fase 1       |
| 5. Workflows de gestión de recursos, personal y calidad | Automatizaciones de solicitudes, guardias, alertas y encuestas                      | Fase 1       |
| 6. Repositorio GitHub                                   | Estructura del repositorio y documentación de distribución                          | Fases 1-5    |
| 7. Documentación                                        | Memoria completa del proyecto siguiendo la plantilla del centro                     | Todas        |

El setup inicial de la infraestructura Docker es sencillo y rápido. El grueso del trabajo recae en la creación de workflows, ya que el proyecto es altamente escalable: se pueden crear tantas automatizaciones como se necesiten, y cada una requiere su propio diseño, implementación y pruebas.

## 1.5 Estado del arte: comparativa de plataformas de automatización

Antes de elegir la herramienta sobre la que construir el proyecto, se evaluaron las principales plataformas de automatización disponibles en el mercado. El análisis se centra en los criterios más relevantes para un entorno educativo con recursos limitados.

### Plataformas evaluadas

- **n8n** — Plataforma de automatización de código abierto, orientada a workflows visuales. Permite despliegue local mediante Docker.
- **Zapier** — Plataforma SaaS líder en automatización. Solo funciona en la nube, sin opción de instalación local.
- **Make (antes Integromat)** — Plataforma SaaS con interfaz visual avanzada. Solo funciona en la nube.
- **Microsoft Power Automate** — Herramienta de automatización integrada en el ecosistema Microsoft 365. Requiere licencia y conexión a la nube de Microsoft.

### Tabla comparativa

| Criterio | n8n | Zapier | Make | Power Automate |
|----------|-----|--------|------|----------------|
| **Código abierto** | Sí (Fair-code, licencia Sustainable Use) | No | No | No |
| **Self-hosted (instalación local)** | Sí (Docker, npm) | No | No | No (solo Desktop para flujos locales básicos) |
| **Funciona sin Internet** | Sí (workflows offline con SQLite) | No | No | Parcialmente (solo flujos de escritorio) |
| **Precio** | Gratis (self-hosted) | Gratis limitado (100 tareas/mes), desde 19,99 $/mes | Gratis limitado (1.000 ops/mes), desde 9 $/mes | Incluido en Microsoft 365 (licencia educativa), Premium desde 15 $/usuario/mes |
| **Portabilidad USB** | Sí (Docker + volúmenes) | No | No | No |
| **Nodos/conectores disponibles** | ~400 integraciones + nodo Code (JavaScript/Python) | ~7.000 integraciones | ~1.800 integraciones | ~1.000 conectores |
| **Nodo de código personalizado** | Sí (JavaScript y Python) | Limitado (Code by Zapier) | Limitado (módulo HTTP + JSON) | Sí (expresiones y scripts) |
| **Interfaz visual de flujos** | Sí (editor canvas) | Sí (lineal) | Sí (canvas avanzado) | Sí (lineal/canvas) |
| **Comunidad y documentación** | Activa, foros oficiales, docs completa | Muy extensa | Extensa | Extensa (ecosistema Microsoft) |
| **Curva de aprendizaje** | Media (requiere conceptos básicos de APIs/JSON) | Baja | Media | Media-alta (ecosistema complejo) |
| **Adecuación educativa** | Alta: gratis, portable, offline, escalable | Baja: coste recurrente, sin offline | Media: coste recurrente, sin offline | Media: requiere licencia Microsoft |

### Justificación de la elección

Se elige **n8n** como plataforma del proyecto por las siguientes razones:

1. **Coste cero** — Al ser self-hosted y de código abierto, no genera costes de licencia ni suscripción. Esto es crítico en entornos educativos con presupuestos ajustados.
2. **Portabilidad real** — Es la única plataforma que puede ejecutarse completamente desde un USB con Docker, sin depender de servidores externos.
3. **Funcionamiento offline** — Gracias al almacenamiento interno en SQLite (`$getWorkflowStaticData`), permite crear workflows que funcionan sin conexión a Internet. Esto es especialmente útil en centros con conectividad limitada o inestable.
4. **Flexibilidad del nodo Code** — Permite implementar lógica compleja en JavaScript directamente dentro del workflow, sin limitaciones artificiales como las de Zapier o Make.
5. **Sin dependencia de proveedor (vendor lock-in)** — Los workflows se exportan como archivos JSON estándar, facilitando su distribución, respaldo y versionado en Git.

Las alternativas comerciales (Zapier, Make, Power Automate) quedan descartadas por su dependencia de la nube, sus costes recurrentes y la imposibilidad de funcionar offline o desde un USB.

## 1.6 Metodología de desarrollo

### Enfoque adoptado

El desarrollo del proyecto sigue un enfoque **iterativo incremental**. En lugar de planificar todo el sistema por adelantado y construirlo de una sola vez (modelo en cascada), el trabajo se organiza en ciclos cortos donde cada ciclo produce un resultado funcional y probado.

Cada workflow sigue el mismo ciclo de desarrollo:

1. **Análisis** — Identificar una tarea repetitiva real del centro educativo y definir qué datos de entrada necesita, qué procesamiento debe hacer y qué resultado debe producir.
2. **Diseño** — Seleccionar los nodos de n8n adecuados, definir el flujo de datos entre ellos y decidir el tipo de trigger (manual, cron, webhook).
3. **Implementación** — Construir el workflow en la interfaz visual de n8n, escribir el código JavaScript de los nodos Code y configurar las conexiones con servicios externos.
4. **Pruebas** — Ejecutar el workflow con datos de ejemplo, probar casos límite y verificar el resultado. Documentar los resultados en el capítulo 4.
5. **Documentación** — Exportar el workflow como JSON, documentar su funcionamiento en el capítulo 3 y añadir la entrada al catálogo.

Este enfoque permite entregar valor de forma incremental: tras cada ciclo hay un workflow nuevo y funcional que se puede mostrar, probar y validar. Si un workflow no funciona como se esperaba, se corrige en el siguiente ciclo sin afectar al resto.

### Justificación

Se descartó el uso de metodologías ágiles formales (Scrum, Kanban) porque están diseñadas para equipos de varias personas con roles diferenciados. En un proyecto individual como este TFG, las ceremonias formales (dailies, retrospectivas, sprint reviews) no aportan valor. El enfoque iterativo conserva la esencia ágil (entrega incremental, adaptación al cambio) sin la sobrecarga organizativa.

### Herramientas de soporte

- **Git y GitHub** — Control de versiones y distribución del código. Cada hito importante del proyecto se registra en un commit con mensaje descriptivo. GitHub sirve como canal de distribución alternativo al USB y como copia de seguridad del proyecto.
- **Herramientas de IA (Claude, ChatGPT)** — Se han utilizado como herramientas de apoyo transversal: generación de archivos de configuración, asistencia en la redacción de documentación técnica, revisión de código JavaScript de los nodos Code, y contraste de ideas de diseño. El uso de estas herramientas ha permitido acelerar el desarrollo sin sustituir el trabajo de diseño y toma de decisiones, que sigue siendo responsabilidad del alumno.
- **Obsidian** — Editor de Markdown utilizado para redactar la memoria del proyecto. Su estructura de vault local encaja bien con el flujo de trabajo del proyecto.
