# Diagramas del Proyecto

> Diagramas técnicos en formato Mermaid. Para exportar a imagen, usar un renderizador Mermaid (mermaid.live, extensión de VS Code, etc.)

---

## 1. Arquitectura general del sistema

```mermaid
graph TB
    subgraph USB["USB / Carpeta del proyecto"]
        subgraph Docker["Contenedor Docker"]
            N8N["n8n<br/>(motor de automatización)"]
            SQLite["SQLite<br/>(base de datos interna)"]
            N8N -->|persistencia| SQLite
        end

        DC["docker-compose.yml"]
        ENV[".env"]
        Scripts["Scripts de arranque<br/>start.bat / start.sh"]

        subgraph WF["workflows/"]
            Online["15 Workflows Online<br/>(JSON)"]
            Offline["6 Workflows Offline<br/>(JSON)"]
        end

        subgraph Data["n8n-data/ (bind mount)"]
            DB["database.sqlite"]
            Creds["Credenciales cifradas"]
        end
    end

    subgraph Externos["Servicios externos (solo workflows online)"]
        GSheets["Google Sheets"]
        SMTP["Servidor SMTP"]
        GDrive["Google Drive"]
    end

    Usuario["Profesor / Administrador"] -->|"navegador web<br/>localhost:5678"| N8N
    Scripts -->|"docker compose up"| Docker
    N8N -->|"bind mount"| Data
    Online -->|"importar"| N8N
    Offline -->|"importar"| N8N
    N8N -.->|"requiere Internet"| Externos

    style USB fill:#1a1a2e,stroke:#e94560,color:#eee
    style Docker fill:#16213e,stroke:#0f3460,color:#eee
    style Externos fill:#2d2d2d,stroke:#888,color:#ccc,stroke-dasharray: 5 5
    style Offline fill:#0f3460,stroke:#e94560,color:#eee
    style Online fill:#0f3460,stroke:#53868b,color:#eee
```

---

## 2. Flujo de un workflow online: Control de asistencia (04)

```mermaid
flowchart LR
    A["Webhook<br/>POST /control-asistencia"] --> B["Leer Google Sheets<br/>(lista de clase)"]
    B --> C{"¿Alumno existe<br/>en la hoja?"}
    C -->|Sí| D["Registrar asistencia<br/>en Google Sheets"]
    C -->|No| E["Responder: error<br/>alumno no encontrado"]
    D --> F{"¿Ausencia?"}
    F -->|Sí| G["Enviar email SMTP<br/>a familia"]
    F -->|No| H["Responder: OK<br/>asistencia registrada"]
    G --> H

    style A fill:#e94560,color:#fff
    style B fill:#0f3460,color:#fff
    style D fill:#0f3460,color:#fff
    style G fill:#53868b,color:#fff
```

**Dependencias externas:** Google Sheets (lectura/escritura), SMTP (notificación)
**Requiere Internet:** Sí

---

## 3. Flujo de un workflow offline: Calculadora de notas (16)

```mermaid
flowchart LR
    A["Webhook<br/>POST /calcular-notas"] --> B{"¿Acción?"}
    B -->|"registrar"| C["Calcular media<br/>ponderada<br/>(50% examen,<br/>30% trabajo,<br/>20% participación)"]
    C --> D["Asignar calificación<br/>cualitativa<br/>(Sobresaliente,<br/>Notable, etc.)"]
    D --> E["Guardar en<br/>SQLite interno<br/>(staticData)"]
    E --> F["Responder:<br/>nota calculada"]

    B -->|"consultar"| G["Leer histórico<br/>desde SQLite<br/>(staticData)"]
    G --> H{"¿Filtro<br/>por curso?"}
    H -->|Sí| I["Filtrar registros"]
    H -->|No| J["Todos los registros"]
    I --> K["Responder:<br/>histórico de notas"]
    J --> K

    style A fill:#e94560,color:#fff
    style E fill:#0f3460,color:#fff
    style G fill:#0f3460,color:#fff
```

**Dependencias externas:** Ninguna
**Requiere Internet:** No — todos los datos se almacenan en la base de datos SQLite interna de n8n

---

## 4. Flujo de un workflow offline: Registro de incidencias (17)

```mermaid
flowchart LR
    A["Webhook<br/>POST /registro-incidencias"] --> B{"¿Acción?"}
    B -->|"registrar"| C["Validar tipo<br/>(leve, grave,<br/>muy_grave)"]
    C --> D["Crear registro<br/>con timestamp<br/>y datos completos"]
    D --> E["Guardar en<br/>SQLite interno<br/>(staticData)"]
    E --> F["Responder:<br/>incidencia registrada"]

    B -->|"consultar"| G["Leer incidencias<br/>desde SQLite"]
    G --> H["Aplicar filtros<br/>(curso, alumno,<br/>tipo, fecha)"]
    H --> I["Responder:<br/>listado filtrado"]

    B -->|"resumen"| J["Calcular estadísticas<br/>(por tipo, por curso,<br/>totales)"]
    J --> K["Responder:<br/>resumen estadístico"]

    style A fill:#e94560,color:#fff
    style E fill:#0f3460,color:#fff
    style G fill:#0f3460,color:#fff
    style J fill:#0f3460,color:#fff
```

**Dependencias externas:** Ninguna
**Requiere Internet:** No

---

## 5. Comparativa visual: Online vs Offline

```mermaid
graph LR
    subgraph Online["Workflow ONLINE"]
        O1["Webhook"] --> O2["Google Sheets"]
        O2 --> O3["Lógica (Code/IF)"]
        O3 --> O4["SMTP / Email"]
        O4 --> O5["Respuesta"]
    end

    subgraph Offline["Workflow OFFLINE"]
        F1["Webhook"] --> F2["Lógica (Code)"]
        F2 --> F3["SQLite interno<br/>(staticData)"]
        F3 --> F4["Respuesta"]
    end

    Internet(("Internet<br/>requerido")) -.-> Online
    USB(("USB /<br/>Local")) -.-> Offline

    style Online fill:#2d2d2d,stroke:#53868b,color:#eee
    style Offline fill:#1a1a2e,stroke:#e94560,color:#eee
    style Internet fill:#53868b,color:#fff
    style USB fill:#e94560,color:#fff
```
