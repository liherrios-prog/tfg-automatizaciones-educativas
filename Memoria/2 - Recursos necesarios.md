# 2. RECURSOS NECESARIOS

## 2.1 Recursos humanos

El proyecto ha sido desarrollado íntegramente por un único alumno como Trabajo de Fin de Grado del ciclo formativo de Administración de Sistemas Informáticos en Red (ASIR) en modalidad Dual, en el centro Salesianos Los Boscos.

- **Desarrollador:** Liher Ríos Ruiz
- **Centro:** Salesianos Los Boscos
- **Ciclo:** CFGS Administración de Sistemas Informáticos en Red (ASIR) - Dual

## 2.2 Recursos hardware

| Recurso            | Descripción                             | Uso en el proyecto                             |
| ------------------ | --------------------------------------- | ---------------------------------------------- |
| Ordenador personal | Equipo con sistema operativo Windows 11 | Desarrollo, pruebas y documentación            |
| Memoria USB        | Dispositivo de almacenamiento portátil  | Distribución y ejecución portátil del proyecto |

El proyecto está diseñado para ejecutarse en cualquier equipo que disponga de Docker, con requisitos mínimos de hardware:

- **Procesador:** Cualquier CPU compatible con virtualización (VT-x/AMD-V)
- **RAM:** Mínimo 2 GB disponibles para Docker
- **Almacenamiento:** Mínimo 500 MB libres (imagen Docker de n8n + datos)
- **Sistema operativo:** Windows 10/11, Linux o macOS con Docker instalado

## 2.3 Recursos software

| Software           | Versión                                           | Función                                             | Licencia                                  |
| ------------------ | ------------------------------------------------- | --------------------------------------------------- | ----------------------------------------- |
| Docker Desktop     | 4.x o superior                                    | Motor de contenedores, cimientos del proyecto       | Gratuito para uso personal y educativo    |
| Docker Compose     | Incluido en Docker Desktop                        | Orquestación del contenedor con persistencia        | Incluido con Docker                       |
| n8n                | Última versión (imagen `docker.n8n.io/n8nio/n8n`) | Motor de automatización de workflows                | Fair-code (gratuito para autoalojamiento) |
| SQLite             | Incluido en n8n                                   | Base de datos ligera para persistencia de workflows | Dominio público                           |
| Git                | 2.x                                               | Control de versiones y distribución del proyecto    | GPLv2                                     |
| GitHub             | -                                                 | Repositorio remoto para distribución                | Gratuito                                  |
| Obsidian           | 1.x                                               | Redacción de la documentación del proyecto          | Gratuito para uso personal                |
| Visual Studio Code | 1.x                                               | Edición de archivos de configuración y scripts      | Gratuito                                  |

### Descripción de las herramientas principales

**Docker y Docker Compose** son la base sobre la que se construye todo el proyecto. Docker permite empaquetar n8n y sus dependencias en un contenedor aislado, garantizando que el sistema funcione de forma idéntica independientemente del equipo donde se ejecute. Docker Compose permite definir la configuración del contenedor de forma declarativa en un archivo YAML, incluyendo volúmenes para la persistencia de datos.

**n8n** es una herramienta de automatización de workflows de código abierto (licencia fair-code) que permite conectar diferentes servicios y aplicaciones mediante una interfaz visual de nodos. Cada nodo representa una acción (enviar un email, leer una hoja de cálculo, hacer una petición HTTP, etc.) y los workflows se construyen conectando estos nodos entre sí. n8n se autoaloja, lo que significa que los datos permanecen en el equipo del usuario y no dependen de servicios en la nube.

**SQLite** es la base de datos que n8n utiliza por defecto para almacenar los workflows y su configuración. Al ser un sistema basado en un único archivo, encaja perfectamente con el requisito de portabilidad del proyecto: toda la información viaja dentro de la carpeta del proyecto.

## 2.4 Análisis de costes

Uno de los puntos fuertes de este proyecto es que todo el software utilizado es gratuito. A continuación se desglosa el coste real y se compara con lo que costaría una solución equivalente basada en plataformas comerciales.

### Coste real del proyecto

| Recurso | Coste |
|---------|-------|
| Docker Desktop (uso educativo/personal) | 0 € |
| n8n self-hosted (licencia fair-code) | 0 € |
| SQLite (dominio público) | 0 € |
| Git + GitHub (plan gratuito) | 0 € |
| Google Sheets API (cuenta gratuita) | 0 € |
| SMTP (cuenta de correo existente del centro) | 0 € |
| Obsidian (uso personal) | 0 € |
| Visual Studio Code (gratuito) | 0 € |
| **Total** | **0 €** |

### Comparativa de coste con alternativas comerciales

Si se quisiera conseguir una funcionalidad similar con plataformas comerciales, el coste sería significativo:

| Plataforma | Plan necesario | Coste mensual | Coste anual |
|------------|---------------|---------------|-------------|
| **Zapier** | Professional (2.000 tareas/mes) | ~20 $/mes | ~240 $/año |
| **Make** | Pro (10.000 ops/mes) | ~9 $/mes | ~108 $/año |
| **Power Automate** | Premium (por usuario) | ~15 $/usuario/mes | ~180 $/usuario/año |
| **n8n Cloud** | Starter (2.500 ejecuciones) | ~20 €/mes | ~240 €/año |
| **Este proyecto** | Self-hosted | 0 € | **0 €** |

Para un centro educativo con 5 profesores utilizando la herramienta, el ahorro anual respecto a Power Automate sería de aproximadamente 900 € (5 × 180 $/año). En un periodo de 3 años, el ahorro acumulado superaría los 2.700 €. Y a diferencia de las soluciones SaaS, este proyecto no tiene costes recurrentes: una vez instalado, funciona indefinidamente sin suscripciones.

### Coste oculto: tiempo de desarrollo

El único "coste" real del proyecto es el tiempo invertido en su desarrollo, que forma parte del trabajo académico del TFG y no supone un desembolso económico adicional.

## 2.5 Estimación temporal

El desarrollo del proyecto se ha distribuido en las siguientes fases, con una estimación aproximada del tiempo dedicado a cada una:

| Fase | Descripción | Horas estimadas |
|------|-------------|-----------------|
| Investigación y aprendizaje | Documentación de n8n, Docker, APIs de Google | 15 h |
| Infraestructura Docker | docker-compose.yml, scripts multiplataforma, configuración | 8 h |
| Workflows online (01-15) | Diseño, implementación y pruebas de 15 workflows | 40 h |
| Workflows offline (16-21) | Diseño, implementación y pruebas de 6 workflows con SQLite | 15 h |
| Panel visual y catálogo | panel.html interactivo + CATALOGO.md + GUIA-DE-USO.md | 10 h |
| Documentación (Memoria) | Redacción de los 7 capítulos, diagramas, guion y presentación | 25 h |
| Pruebas y depuración | Batería completa de pruebas funcionales y de errores | 10 h |
| **Total estimado** | | **~123 h** |

Estas estimaciones no incluyen el tiempo de curva de aprendizaje inicial con las herramientas (Docker, n8n, APIs de Google), que fue considerable al tratarse de tecnologías nuevas para el alumno.
