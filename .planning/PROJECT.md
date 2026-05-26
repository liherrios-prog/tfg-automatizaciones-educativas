# Implementación de automatizaciones para entornos educativos

## What This Is

TFG (Trabajo de Fin de Grado) del ciclo formativo ASIR en Salesianos Los Boscos. Es una solución portátil basada en Docker y n8n que permite automatizar tareas repetitivas en entornos educativos (colegios, academias). La infraestructura corre desde un USB o se distribuye vía GitHub, y los workflows automatizan comunicaciones, gestión académica y generación de contenido.

## Core Value

Una herramienta portátil que permite a cualquier usuario de un entorno educativo automatizar tareas repetitivas con un solo click — "solo tener que pensar una vez".

## Current Milestone: v2.0 Mejoras, autonomía offline y defensa

**Goal:** Elevar la calidad del TFG añadiendo workflows autónomos (sin dependencias online), reorganizando el catálogo completo, ampliando la documentación técnica, y preparando la presentación para la defensa oral.

**Target features:**
- Nuevos workflows autónomos que funcionen sin conexión a internet
- Clasificación y reorganización del catálogo completo de workflows
- Ampliación de documentación técnica (diagramas, comparativas, detalle)
- Presentación profesional (diapositivas) para la defensa ante tribunal

## Requirements

### Validated

- ✓ Setup Docker Compose con n8n + SQLite portable (funciona desde USB) — Milestone 1
- ✓ Repositorio GitHub con archivos de instalación y workflows — Milestone 1
- ✓ Scripts de instalación automática para puesta en marcha rápida — Milestone 1
- ✓ Workflows de automatización para comunicaciones educativas (4 workflows) — Milestone 1
- ✓ Workflows de automatización para gestión académica (6 workflows) — Milestone 1
- ✓ Workflows de automatización para gestión de recursos, personal y calidad (3 workflows) — Milestone 1
- ✓ Workflows de mantenimiento y convivencia (2 workflows) — Milestone 1
- ✓ Documentación extensiva en Obsidian siguiendo plantilla del centro (7 capítulos) — Milestone 1
- ✓ Guion de defensa oral — Milestone 1

### Active

- [ ] Workflows autónomos sin dependencias online (usan nodos locales: Code, archivos, SQLite)
- [ ] Clasificación y reorganización del catálogo completo de workflows
- [ ] Ampliación de documentación técnica (diagramas de flujo, comparativas, detalle de diseño)
- [ ] Presentación profesional para la defensa oral (diapositivas)

### Out of Scope

- Desarrollo de interfaz web propia — se usa la interfaz nativa de n8n
- Despliegue en la nube — el proyecto es portátil y local (USB)
- Integración con APIs de pago — el proyecto debe ser gratuito y accesible

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
| n8n como motor de automatización | Herramienta open-source, visual, con muchos nodos disponibles | ✓ Good |
| Docker Compose para infraestructura | Permite portabilidad y persistencia con SQLite | ✓ Good |
| SQLite como BBDD | Ligera, no requiere servidor separado, cabe en un contenedor | ✓ Good |
| IA como herramienta, no feature | El TFG se centra en n8n y automatizaciones, no en IA como producto | ✓ Good |
| Obsidian para documentación | Vault local, markdown, flexible, con la estructura del TFG | ✓ Good |
| GitHub para distribución | Alternativa al USB, permite compartir archivos y workflows | ✓ Good |
| Workflows offline | Demostrar autonomía sin internet refuerza el argumento de portabilidad USB | — Pending |

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
*Last updated: 2026-03-26 after Milestone v2.0 start*
