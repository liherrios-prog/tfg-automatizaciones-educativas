# Implementación de automatizaciones para entornos educativos

## What This Is

TFG (Trabajo de Fin de Grado) del ciclo formativo ASIR en Salesianos Los Boscos. Es una solución portátil basada en Docker y n8n que permite automatizar tareas repetitivas en entornos educativos (colegios, academias). La infraestructura corre desde un USB o se distribuye vía GitHub, y los workflows automatizan comunicaciones, gestión académica y generación de contenido.

## Core Value

Una herramienta portátil que permite a cualquier usuario de un entorno educativo automatizar tareas repetitivas con un solo click — "solo tener que pensar una vez".

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Setup Docker Compose con n8n + SQLite portable (funciona desde USB)
- [ ] Repositorio GitHub con archivos de instalación y workflows
- [ ] Scripts de instalación automática para puesta en marcha rápida
- [ ] Workflows de automatización para comunicaciones educativas
- [ ] Workflows de automatización para gestión académica
- [ ] Workflows de automatización para generación de contenido
- [ ] Documentación extensiva en Obsidian siguiendo plantilla del centro
- [ ] Documentación del proceso de creación del proyecto

### Out of Scope

- Integración de IA como feature dentro de los workflows de n8n — la IA se usa como herramienta de apoyo en el proceso del TFG, no como componente del producto final
- Desarrollo de interfaz web propia — se usa la interfaz nativa de n8n
- Despliegue en la nube — el proyecto es portátil y local (USB)

## Context

- **Autor**: Liher Ríos Ruiz, estudiante ASIR, Salesianos Los Boscos
- **Tipo**: Trabajo de Fin de Grado (TFG) del ciclo formativo
- **Evaluación**: Tribunal que valora especialmente la documentación del proceso
- **Herramientas IA**: Claude y ChatGPT como herramientas de apoyo transversal (documentar, crear configs, scripts)
- **Documentación**: Obsidian vault en D:\PROYECTOS\TFG, con plantilla del centro (pendiente de compartir)
- **Distribución**: USB (portabilidad) + repositorio GitHub (accesibilidad)
- **Stack técnico**: Docker Compose, n8n, SQLite para persistencia
- **Escalabilidad**: El proyecto es muy escalable — se pueden añadir tantos workflows como se quiera

## Constraints

- **Deadline**: Junio 2025 — presentación ante tribunal
- **Portabilidad**: Todo debe correr desde un USB sin necesidad de descargas adicionales
- **Persistencia**: SQLite para guardar workflows y datos en ruta específica del contenedor
- **Contenedor único**: Todas las herramientas corren dentro de un mismo contenedor Docker Compose
- **Documentación**: Debe seguir la plantilla del centro educativo (pendiente de recibir)
- **Hardware**: USB como medio de almacenamiento y ejecución

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| n8n como motor de automatización | Herramienta open-source, visual, con muchos nodos disponibles | — Pending |
| Docker Compose para infraestructura | Permite portabilidad y persistencia con SQLite | — Pending |
| SQLite como BBDD | Ligera, no requiere servidor separado, cabe en un contenedor | — Pending |
| IA como herramienta, no feature | El TFG se centra en n8n y automatizaciones, no en IA como producto | ✓ Good |
| Obsidian para documentación | Vault local, markdown, flexible, con la estructura del TFG | — Pending |
| GitHub para distribución | Alternativa al USB, permite compartir archivos y workflows | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2025-03-24 after initialization*
