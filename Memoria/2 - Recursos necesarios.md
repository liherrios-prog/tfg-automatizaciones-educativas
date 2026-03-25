# 2. RECURSOS NECESARIOS

## 2.1 Recursos humanos

El proyecto ha sido desarrollado íntegramente por un único alumno como Trabajo de Fin de Grado del ciclo formativo de Administración de Sistemas Informáticos en Red (ASIR) en modalidad Dual, en el centro Salesianos Los Boscos.

- **Desarrollador:** Liher Ríos Ruiz
- **Centro:** Salesianos Los Boscos
- **Ciclo:** CFGS Administración de Sistemas Informáticos en Red (ASIR) - Dual

## 2.2 Recursos hardware

| Recurso | Descripción | Uso en el proyecto |
|---------|-------------|-------------------|
| Ordenador personal | Equipo con sistema operativo Windows 11 | Desarrollo, pruebas y documentación |
| Memoria USB | Dispositivo de almacenamiento portátil | Distribución y ejecución portátil del proyecto |

El proyecto está diseñado para ejecutarse en cualquier equipo que disponga de Docker, con requisitos mínimos de hardware:

- **Procesador:** Cualquier CPU compatible con virtualización (VT-x/AMD-V)
- **RAM:** Mínimo 2 GB disponibles para Docker
- **Almacenamiento:** Mínimo 500 MB libres (imagen Docker de n8n + datos)
- **Sistema operativo:** Windows 10/11, Linux o macOS con Docker instalado

## 2.3 Recursos software

| Software | Versión | Función | Licencia |
|----------|---------|---------|----------|
| Docker Desktop | 4.x o superior | Motor de contenedores, cimientos del proyecto | Gratuito para uso personal y educativo |
| Docker Compose | Incluido en Docker Desktop | Orquestación del contenedor con persistencia | Incluido con Docker |
| n8n | Última versión (imagen `docker.n8n.io/n8nio/n8n`) | Motor de automatización de workflows | Fair-code (gratuito para autoalojamiento) |
| SQLite | Incluido en n8n | Base de datos ligera para persistencia de workflows | Dominio público |
| Git | 2.x | Control de versiones y distribución del proyecto | GPLv2 |
| GitHub | - | Repositorio remoto para distribución | Gratuito |
| Obsidian | 1.x | Redacción de la documentación del proyecto | Gratuito para uso personal |
| Visual Studio Code | 1.x | Edición de archivos de configuración y scripts | Gratuito |

### Descripción de las herramientas principales

**Docker y Docker Compose** son la base sobre la que se construye todo el proyecto. Docker permite empaquetar n8n y sus dependencias en un contenedor aislado, garantizando que el sistema funcione de forma idéntica independientemente del equipo donde se ejecute. Docker Compose permite definir la configuración del contenedor de forma declarativa en un archivo YAML, incluyendo volúmenes para la persistencia de datos.

**n8n** es una herramienta de automatización de workflows de código abierto (licencia fair-code) que permite conectar diferentes servicios y aplicaciones mediante una interfaz visual de nodos. Cada nodo representa una acción (enviar un email, leer una hoja de cálculo, hacer una petición HTTP, etc.) y los workflows se construyen conectando estos nodos entre sí. n8n se autoaloja, lo que significa que los datos permanecen en el equipo del usuario y no dependen de servicios en la nube.

**SQLite** es la base de datos que n8n utiliza por defecto para almacenar los workflows y su configuración. Al ser un sistema basado en un único archivo, encaja perfectamente con el requisito de portabilidad del proyecto: toda la información viaja dentro de la carpeta del proyecto.
