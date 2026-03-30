const pptxgen = require("pptxgenjs");
const path = require("path");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "Liher Ríos Ruiz";
pres.title = "Automatizaciones para entornos educativos";

// Color palette — dark tech theme
const C = {
  bg:      "0F172A", // slate-950
  bgCard:  "1E293B", // slate-800
  accent:  "3B82F6", // blue-500
  green:   "10B981", // emerald-500
  red:     "EF4444", // red-500
  orange:  "F59E0B", // amber-500
  white:   "F8FAFC",
  gray:    "94A3B8", // slate-400
  dimGray: "64748B", // slate-500
  darkLine:"334155", // slate-700
};

const mkShadow = () => ({ type: "outer", blur: 6, offset: 2, angle: 135, color: "000000", opacity: 0.25 });

// ─── SLIDE 1: TITLE ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  // Accent bar top
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("Implementación de\nautomatizaciones para\nentornos educativos", {
    x: 0.8, y: 0.8, w: 8.4, h: 2.4, fontSize: 38, fontFace: "Calibri",
    color: C.white, bold: true, lineSpacingMultiple: 1.1, margin: 0
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.4, w: 1.5, h: 0.04, fill: { color: C.accent } });
  s.addText("Liher Ríos Ruiz", {
    x: 0.8, y: 3.65, w: 5, h: 0.4, fontSize: 18, fontFace: "Calibri", color: C.white, bold: true, margin: 0
  });
  s.addText("CFGS Administración de Sistemas Informáticos en Red\nSalesianos Los Boscos — Curso 2024/2025", {
    x: 0.8, y: 4.1, w: 6, h: 0.7, fontSize: 13, fontFace: "Calibri", color: C.gray, margin: 0
  });
  // Tech stack badges
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 5.0, w: 1.1, h: 0.32, fill: { color: C.accent }, rectRadius: 0.05 });
  s.addText("Docker", { x: 0.8, y: 5.0, w: 1.1, h: 0.32, fontSize: 11, fontFace: "Calibri", color: C.white, bold: true, align: "center", valign: "middle" });
  s.addShape(pres.shapes.RECTANGLE, { x: 2.05, y: 5.0, w: 0.7, h: 0.32, fill: { color: C.green }, rectRadius: 0.05 });
  s.addText("n8n", { x: 2.05, y: 5.0, w: 0.7, h: 0.32, fontSize: 11, fontFace: "Calibri", color: C.white, bold: true, align: "center", valign: "middle" });
  s.addShape(pres.shapes.RECTANGLE, { x: 2.9, y: 5.0, w: 1.0, h: 0.32, fill: { color: "334155" }, rectRadius: 0.05 });
  s.addText("SQLite", { x: 2.9, y: 5.0, w: 1.0, h: 0.32, fontSize: 11, fontFace: "Calibri", color: C.gray, bold: true, align: "center", valign: "middle" });
}

// ─── SLIDE 2: EL PROBLEMA ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("El problema", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  s.addText("Los profesores dedican horas a tareas mecánicas que se repiten cada día, cada semana, cada mes.", {
    x: 0.8, y: 1.1, w: 8.4, h: 0.5, fontSize: 15, fontFace: "Calibri", color: C.gray, margin: 0
  });
  const tasks = [
    { label: "Enviar comunicaciones", desc: "Emails a familias, boletines, avisos..." },
    { label: "Pasar lista y registrar", desc: "Asistencia, incidencias, préstamos..." },
    { label: "Consolidar datos", desc: "Notas trimestrales, informes de asistencia..." },
    { label: "Gestionar recursos", desc: "Material, guardias, sustituciones..." },
  ];
  tasks.forEach((t, i) => {
    const y = 1.9 + i * 0.85;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 8.4, h: 0.7, fill: { color: C.bgCard }, shadow: mkShadow() });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 0.06, h: 0.7, fill: { color: C.red } });
    s.addText(t.label, { x: 1.15, y, w: 3, h: 0.7, fontSize: 15, fontFace: "Calibri", color: C.white, bold: true, valign: "middle", margin: 0 });
    s.addText(t.desc, { x: 4.2, y, w: 4.8, h: 0.7, fontSize: 13, fontFace: "Calibri", color: C.gray, valign: "middle", margin: 0 });
  });
  s.addText("Tiempo que se podría dedicar a los alumnos.", {
    x: 0.8, y: 5.0, w: 8.4, h: 0.4, fontSize: 14, fontFace: "Calibri", color: C.accent, italic: true, margin: 0
  });
}

// ─── SLIDE 3: LA IDEA ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("La idea", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  // Big quote
  s.addShape(pres.shapes.RECTANGLE, { x: 1.2, y: 1.5, w: 7.6, h: 2.0, fill: { color: C.bgCard }, shadow: mkShadow() });
  s.addShape(pres.shapes.RECTANGLE, { x: 1.2, y: 1.5, w: 0.06, h: 2.0, fill: { color: C.accent } });
  s.addText('"Solo tienes que\npensar una vez"', {
    x: 1.6, y: 1.5, w: 6.8, h: 2.0, fontSize: 34, fontFace: "Georgia", color: C.white, italic: true, valign: "middle", margin: 0
  });
  s.addText("Si una tarea se puede describir como una serie de pasos,\nse puede automatizar. Y una vez automatizada, queda resuelta para siempre.", {
    x: 0.8, y: 3.9, w: 8.4, h: 0.8, fontSize: 15, fontFace: "Calibri", color: C.gray, margin: 0
  });
}

// ─── SLIDE 4: LA SOLUCIÓN ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("La solución", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  // Architecture cards
  const cards = [
    { title: "Docker", desc: "Contenedor portátil\nMismo entorno en cualquier equipo\nBind mount → portabilidad USB", color: C.accent },
    { title: "n8n", desc: "Motor de automatización visual\nWorkflows con bloques conectables\nSQLite integrado para datos", color: C.green },
    { title: "Scripts", desc: "Arranque en 1 click\nAutoinstalación de Docker\nWindows, Linux y macOS", color: C.orange },
  ];
  cards.forEach((c, i) => {
    const x = 0.8 + i * 3.05;
    s.addShape(pres.shapes.RECTANGLE, { x, y: 1.2, w: 2.75, h: 2.8, fill: { color: C.bgCard }, shadow: mkShadow() });
    s.addShape(pres.shapes.RECTANGLE, { x, y: 1.2, w: 2.75, h: 0.06, fill: { color: c.color } });
    s.addText(c.title, { x: x + 0.2, y: 1.45, w: 2.35, h: 0.4, fontSize: 20, fontFace: "Calibri", color: c.color, bold: true, margin: 0 });
    s.addText(c.desc, { x: x + 0.2, y: 1.95, w: 2.35, h: 1.8, fontSize: 13, fontFace: "Calibri", color: C.gray, margin: 0 });
  });
  // Bottom stats
  const stats = [
    { num: "21", label: "workflows" },
    { num: "15+6", label: "online + offline" },
    { num: "8", label: "categorías" },
    { num: "3", label: "plataformas" },
  ];
  stats.forEach((st, i) => {
    const x = 0.8 + i * 2.35;
    s.addText(st.num, { x, y: 4.3, w: 2.05, h: 0.5, fontSize: 28, fontFace: "Calibri", color: C.accent, bold: true, align: "center", margin: 0 });
    s.addText(st.label, { x, y: 4.8, w: 2.05, h: 0.35, fontSize: 12, fontFace: "Calibri", color: C.dimGray, align: "center", margin: 0 });
  });
}

// ─── SLIDE 5: 21 WORKFLOWS ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("21 workflows en 8 categorías", { x: 0.8, y: 0.3, w: 9, h: 0.5, fontSize: 28, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });

  const headerRow = [
    { text: "Categoría", options: { fill: { color: "334155" }, color: C.white, bold: true, fontSize: 11, fontFace: "Calibri", align: "left" } },
    { text: "Online", options: { fill: { color: "334155" }, color: C.accent, bold: true, fontSize: 11, fontFace: "Calibri", align: "center" } },
    { text: "Offline", options: { fill: { color: "334155" }, color: C.green, bold: true, fontSize: 11, fontFace: "Calibri", align: "center" } },
  ];
  const mkRow = (cat, on, off) => [
    { text: cat, options: { fontSize: 10, fontFace: "Calibri", color: C.white, fill: { color: C.bgCard } } },
    { text: on, options: { fontSize: 10, fontFace: "Calibri", color: C.gray, fill: { color: C.bgCard }, align: "center" } },
    { text: off, options: { fontSize: 10, fontFace: "Calibri", color: C.green, fill: { color: C.bgCard }, align: "center" } },
  ];
  const tableData = [
    headerRow,
    mkRow("Comunicaciones", "Email, Forms, boletín, entregas", "—"),
    mkRow("Gestión académica", "Reuniones, asistencia, notas, informe", "Calculadora notas"),
    mkRow("Gestión TIC", "Inventario equipos", "Préstamos offline"),
    mkRow("Convivencia", "Cumpleaños alumnos", "Incidencias"),
    mkRow("Alertas", "Absentismo acumulado", "—"),
    mkRow("Recursos / Personal", "Solicitud material, guardias", "—"),
    mkRow("Calidad", "Encuesta satisfacción", "—"),
    mkRow("Herramientas / Admin", "—", "Contraseñas, sorteo, diario"),
    mkRow("Mantenimiento", "Backup automático", "—"),
  ];
  s.addTable(tableData, {
    x: 0.8, y: 1.0, w: 8.4, colW: [2.8, 3.3, 2.3],
    border: { pt: 0.5, color: C.darkLine },
    rowH: [0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38],
  });
  // Legend
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 5.0, w: 0.2, h: 0.2, fill: { color: C.accent } });
  s.addText("Requiere Internet", { x: 1.1, y: 5.0, w: 2, h: 0.2, fontSize: 10, fontFace: "Calibri", color: C.gray, valign: "middle", margin: 0 });
  s.addShape(pres.shapes.RECTANGLE, { x: 3.3, y: 5.0, w: 0.2, h: 0.2, fill: { color: C.green } });
  s.addText("Funciona sin Internet (SQLite)", { x: 3.6, y: 5.0, w: 3, h: 0.2, fontSize: 10, fontFace: "Calibri", color: C.gray, valign: "middle", margin: 0 });
}

// ─── SLIDE 6: COMPARATIVA ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("¿Por qué n8n?", { x: 0.8, y: 0.3, w: 8, h: 0.5, fontSize: 28, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });

  const hdr = (t) => ({ text: t, options: { fill: { color: "334155" }, color: C.white, bold: true, fontSize: 10, fontFace: "Calibri", align: "center" } });
  const cell = (t, clr) => ({ text: t, options: { fontSize: 10, fontFace: "Calibri", color: clr || C.gray, fill: { color: C.bgCard }, align: "center" } });
  const cellL = (t) => ({ text: t, options: { fontSize: 10, fontFace: "Calibri", color: C.white, fill: { color: C.bgCard }, bold: true } });

  const tbl = [
    [hdr("Criterio"), hdr("n8n"), hdr("Zapier"), hdr("Make"), hdr("Power Automate")],
    [cellL("Open source"), cell("Sí", C.green), cell("No", C.red), cell("No", C.red), cell("No", C.red)],
    [cellL("Self-hosted"), cell("Sí", C.green), cell("No", C.red), cell("No", C.red), cell("No", C.red)],
    [cellL("Funciona offline"), cell("Sí", C.green), cell("No", C.red), cell("No", C.red), cell("Parcial", C.orange)],
    [cellL("Portabilidad USB"), cell("Sí", C.green), cell("No", C.red), cell("No", C.red), cell("No", C.red)],
    [cellL("Coste"), cell("Gratis", C.green), cell("Desde 20$/mes", C.orange), cell("Desde 9$/mes", C.orange), cell("Licencia M365", C.orange)],
    [cellL("Nodo de código"), cell("JS + Python", C.green), cell("Limitado", C.orange), cell("Limitado", C.orange), cell("Sí", C.green)],
  ];
  s.addTable(tbl, {
    x: 0.5, y: 1.0, w: 9.0, colW: [1.8, 1.5, 1.5, 1.5, 1.7],
    border: { pt: 0.5, color: C.darkLine },
    rowH: [0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38],
  });
  s.addText("n8n es la única plataforma que cumple todos los requisitos del proyecto:\nopen source, gratuita, portable en USB y capaz de funcionar sin Internet.", {
    x: 0.8, y: 4.2, w: 8.4, h: 0.6, fontSize: 13, fontFace: "Calibri", color: C.accent, italic: true, margin: 0
  });
}

// ─── SLIDE 7: DEMO EN DIRECTO ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.green } });
  s.addText("Demo en directo", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  const demos = [
    { num: "1", title: "Email masivo a familias", desc: "Workflow online — Lee Google Sheets, filtra, personaliza y envía", tag: "ONLINE", tagColor: C.accent },
    { num: "2", title: "Calculadora de notas offline", desc: "Workflow offline — WiFi desconectado, datos en SQLite interno", tag: "OFFLINE", tagColor: C.green },
    { num: "3", title: "Control de asistencia", desc: "Webhook HTTP — Registro + notificación automática a familias", tag: "ONLINE", tagColor: C.accent },
  ];
  demos.forEach((d, i) => {
    const y = 1.3 + i * 1.3;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 8.4, h: 1.05, fill: { color: C.bgCard }, shadow: mkShadow() });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 0.06, h: 1.05, fill: { color: d.tagColor } });
    s.addText(d.num, { x: 1.1, y, w: 0.5, h: 1.05, fontSize: 28, fontFace: "Calibri", color: d.tagColor, bold: true, valign: "middle", margin: 0 });
    s.addText(d.title, { x: 1.7, y: y + 0.1, w: 5, h: 0.4, fontSize: 18, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
    s.addText(d.desc, { x: 1.7, y: y + 0.55, w: 5, h: 0.35, fontSize: 12, fontFace: "Calibri", color: C.gray, margin: 0 });
    s.addShape(pres.shapes.RECTANGLE, { x: 7.5, y: y + 0.35, w: 1.2, h: 0.3, fill: { color: d.tagColor } });
    s.addText(d.tag, { x: 7.5, y: y + 0.35, w: 1.2, h: 0.3, fontSize: 10, fontFace: "Calibri", color: C.white, bold: true, align: "center", valign: "middle" });
  });
  s.addText("Cambiar a n8n en el navegador →  localhost:5678", {
    x: 0.8, y: 5.0, w: 8.4, h: 0.35, fontSize: 13, fontFace: "Consolas", color: C.dimGray, align: "center", margin: 0
  });
}

// ─── SLIDE 8: RESULTADOS ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("Resultados", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  // Stat grid 2x3
  const results = [
    { num: "21", label: "workflows\nfuncionales", color: C.accent },
    { num: "6", label: "100% offline\n(SQLite)", color: C.green },
    { num: "8", label: "categorías\neducativas", color: C.accent },
    { num: "3", label: "plataformas\n(Win/Linux/Mac)", color: C.orange },
    { num: "20", label: "referencias\nbibliográficas", color: C.accent },
    { num: "4", label: "scripts auto-\ninstalación", color: C.green },
  ];
  results.forEach((r, i) => {
    const col = i % 3;
    const row = Math.floor(i / 3);
    const x = 0.8 + col * 3.05;
    const y = 1.2 + row * 1.9;
    s.addShape(pres.shapes.RECTANGLE, { x, y, w: 2.75, h: 1.6, fill: { color: C.bgCard }, shadow: mkShadow() });
    s.addText(r.num, { x, y: y + 0.15, w: 2.75, h: 0.7, fontSize: 42, fontFace: "Calibri", color: r.color, bold: true, align: "center", margin: 0 });
    s.addText(r.label, { x, y: y + 0.9, w: 2.75, h: 0.55, fontSize: 12, fontFace: "Calibri", color: C.gray, align: "center", valign: "top", margin: 0 });
  });
  s.addText("Todos los objetivos del anteproyecto cumplidos + mejoras adicionales (offline, catálogo, comparativa)", {
    x: 0.8, y: 5.1, w: 8.4, h: 0.35, fontSize: 12, fontFace: "Calibri", color: C.dimGray, align: "center", margin: 0
  });
}

// ─── SLIDE 9: AMPLIACIONES FUTURAS ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  s.addText("Ampliaciones futuras", { x: 0.8, y: 0.3, w: 8, h: 0.6, fontSize: 32, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
  const futures = [
    { title: "Generación de contenido con IA", desc: "Crear exámenes tipo test, resúmenes y ejercicios\nautomáticamente usando APIs de modelos de lenguaje", color: C.accent },
    { title: "Integración con Classroom / Moodle", desc: "Sincronizar notas y tareas con las plataformas\nque ya usan los centros educativos", color: C.green },
    { title: "Despliegue en la nube", desc: "Para centros que prefieran acceso remoto\nen vez de USB — misma infraestructura Docker", color: C.orange },
  ];
  futures.forEach((f, i) => {
    const y = 1.3 + i * 1.3;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 8.4, h: 1.05, fill: { color: C.bgCard }, shadow: mkShadow() });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y, w: 0.06, h: 1.05, fill: { color: f.color } });
    s.addText(f.title, { x: 1.15, y: y + 0.1, w: 7.8, h: 0.4, fontSize: 18, fontFace: "Calibri", color: C.white, bold: true, margin: 0 });
    s.addText(f.desc, { x: 1.15, y: y + 0.55, w: 7.8, h: 0.45, fontSize: 13, fontFace: "Calibri", color: C.gray, margin: 0 });
  });
}

// ─── SLIDE 10: CIERRE ───
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: C.accent } });
  // Big closing quote
  s.addShape(pres.shapes.RECTANGLE, { x: 1.5, y: 1.0, w: 7, h: 2.2, fill: { color: C.bgCard }, shadow: mkShadow() });
  s.addShape(pres.shapes.RECTANGLE, { x: 1.5, y: 1.0, w: 0.06, h: 2.2, fill: { color: C.accent } });
  s.addText('"Solo tienes que\npensar una vez"', {
    x: 1.9, y: 1.0, w: 6.2, h: 2.2, fontSize: 36, fontFace: "Georgia", color: C.white, italic: true, valign: "middle", margin: 0
  });
  s.addText("Cada automatización resuelve un problema real.\nUna vez configurada, funciona sola.", {
    x: 1.5, y: 3.5, w: 7, h: 0.7, fontSize: 16, fontFace: "Calibri", color: C.gray, align: "center", margin: 0
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 4.0, y: 4.4, w: 2.0, h: 0.04, fill: { color: C.accent } });
  s.addText("¿Preguntas?", {
    x: 2.5, y: 4.7, w: 5, h: 0.5, fontSize: 22, fontFace: "Calibri", color: C.accent, bold: true, align: "center", margin: 0
  });
}

// ─── WRITE FILE ───
const outPath = path.join(__dirname, "..", "Memoria", "PRESENTACION-DEFENSA.pptx");
pres.writeFile({ fileName: outPath }).then(() => {
  console.log("Presentacion creada: " + outPath);
}).catch(err => {
  console.error("Error:", err);
});
