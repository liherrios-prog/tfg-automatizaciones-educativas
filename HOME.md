# TFG — n8n Automatizaciones para Entornos Educativos

**Alumno:** Liher Ríos Ruiz · CFGS ASIR · Salesianos Los Boscos · 2024/2025
**Repo:** https://github.com/liherrios-prog/tfg-automatizaciones-educativas
**Estado:** Completado — pendiente de defensa oral

---

## Navegación rápida

### Documentación
| Nota | Descripción |
|------|-------------|
| [[Memoria/1 - Estudio del problema y análisis del sistema]] | Cap. 1 — Introducción, objetivos, planificación |
| [[Memoria/2 - Recursos necesarios]] | Cap. 2 — Hardware, software, humanos |
| [[Memoria/3 - Implementación y documentación técnica]] | Cap. 3 — El más extenso, toda la técnica |
| [[Memoria/4 - Fase de pruebas]] | Cap. 4 — Batería de pruebas |
| [[Memoria/5 - Conclusiones finales]] | Cap. 5 — Objetivos cumplidos, mejoras futuras |
| [[Memoria/6 - Documentación del sistema desarrollado]] | Cap. 6 — Manual instalación y uso |
| [[Memoria/7 - Bibliografía]] | Cap. 7 — Referencias IEEE |
| [[Memoria/DIAGRAMAS]] | Diagramas de arquitectura y flujo |
| [[Memoria/GUION-DEFENSA-ORAL]] | Guion de 10 min para el tribunal |

### Workflows
| Nota | Descripción |
|------|-------------|
| [[workflows/CATALOGO]] | Tabla completa: 21 workflows, categorías, endpoints |
| [[workflows/GUIA-DE-USO]] | Ejemplos curl por workflow |

### Referencia y contexto
| Nota | Descripción |
|------|-------------|
| [[resumen]] | Resumen técnico compacto del proyecto |
| [[Referencia/ANTEPROYECTO]] | Anteproyecto aprobado por el centro |
| [[Referencia/Módulo PROYECTO CFGS ASIR DUAL]] | Normativa oficial del módulo Proyecto |

### Entregables finales
| Archivo | Descripción |
|---------|-------------|
| `Entregables/Implementación...md` | Memoria completa compilada (todos los capítulos) |
| `Entregables/Implementación...pdf` | PDF para entrega impresa |
| `Entregables/Anteproyecto...pdf` | PDF del anteproyecto |

---

## Estado del proyecto

### Todo completado ✅
- [x] Infraestructura Docker portátil (USB)
- [x] Scripts arranque/parada multiplataforma
- [x] 15 workflows online (Google Sheets + SMTP)
- [x] 6 workflows offline (SQLite, sin internet)
- [x] Catálogo organizado (`workflows/CATALOGO.md`)
- [x] Comparativa n8n vs Zapier vs Make vs Power Automate
- [x] Diagramas de arquitectura y flujo
- [x] Memoria completa (7 capítulos)
- [x] Guion defensa oral (10 min)
- [x] Presentación PPTX para tribunal
- [x] Panel HTML interactivo (`panel.html`)
- [x] Repositorio GitHub público

### Pendiente para la defensa
- [ ] Preparar demo en vivo (arrancar Docker, abrir n8n, ejecutar 1-2 workflows)
- [ ] Revisar guion de defensa oral
- [ ] Imprimir y encuadernar memoria

---

## Arranque rápido

```cmd
scripts\start.bat
```
n8n disponible en: http://localhost:5678

```bash
# Probar un workflow offline
curl -X POST http://localhost:5678/webhook/calcular-notas \
  -H "Content-Type: application/json" \
  -d '{"alumno":"Liher","asignaturas":[{"nombre":"Redes","nota":8,"peso":0.3},{"nombre":"SO","nota":9,"peso":0.7}]}'
```
