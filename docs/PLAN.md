# Plan — FLAMIA Luxury Real Estate System

**Hito duro:** demo funcional el **miércoles 21-oct-2026** (conferencia AMPI), con Halcón.
**Hoy:** miércoles 14-oct → 7 días. Documentos de base: [`especificacion.md`](especificacion.md),
[`analisis-especificacion.md`](analisis-especificacion.md), [`decisiones.md`](decisiones.md).

**Objetivo de la demo:** un lead entra por WhatsApp, recibe respuesta en < 60 s en su idioma, el agente busca
en inventario real (ficticio) y devuelve 2–3 opciones, agenda visita; la voz hace lo mismo; al subir una
propiedad llega una alerta de coincidencia; el dueño ve el resumen.

## 1. Frentes de trabajo

| Id | Frente | Carpeta | Dueño | Fase |
|---|---|---|---|---|
| A | Inventario: esquema, trigger, RLS, match | `supabase/migrations` | Claude (MCP Supabase) | 1 |
| B | Herramientas HTTP (5) | `supabase/functions` | Claude | 1 |
| C | Subcuenta GHL demo + snapshot (pipeline, campos, tags, calendario, workflows) | `ghl/` | Claude (MCP GHL) + Michael (pasos manuales) | 1 |
| D | Agentes de texto y voz + prompts | `docs/prompts` | Claude + Michael (UI) | 1 |
| E | Alerta de coincidencia + plantillas WhatsApp | `n8n/workflows`, `ghl/plantillas-whatsapp` | Claude (MCP n8n) | 1 |
| F | Sync de hoja → `properties` + datos demo | `n8n/workflows`, `supabase/seed` | Claude + Michael (hoja) | 1 |
| G | Portal: limpieza mínima + webhook de lead | `portal/` | Michael (Hostinger) + Claude | 1 |
| H | Resumen diario del dueño | `n8n/workflows` | Claude | 1 |
| I | Pruebas y ensayo del guion | `tests/` | Todos | 1 |
| J | Panel Next.js, semántica, funnels+QR, nurture, snapshot | `apps/`, `ghl/` | — | 2 |
| K | Multi-agente, bóveda, conductual, vendedores | — | — | 3 |

## 2. Calendario hasta la demo

| Día | Meta | Entregables | Depende de |
|---|---|---|---|
| **Mié 14** | Fase 0 | Repo y plan (hecho), decisiones D4/D11 pedidas, acceso al portal, estado del ticket Meta, proyecto Supabase `flamia-luxury` creado | Michael |
| **Jue 15** | Cimientos | A: migración 0001 (esquema+trigger+RLS+match) aplicada · C: subcuenta demo creada, campos+tags+custom values+pipeline · F: hoja plantilla compartida y 12–15 propiedades ficticias | Subcuenta demo (manual/API), hoja |
| **Vie 16** | Herramientas | B: `search_properties`, `get_property`, `upsert_buyer_profile` con auth ligada a `client_id` · F: `FLR · sync-sheet-properties` · tests RLS | A, F |
| **Sáb 17** | Agente de texto | D: Conversation AI con acciones → herramientas, bilingüe · B: `book_viewing`, `send_brochure` · C: calendario "Visitas" | B, C, canal WhatsApp o plan B |
| **Dom 18** | Voz y alertas | D: Voice AI con acción de búsqueda y número · E: `FLR · alerta-coincidencia` mínima + 1 plantilla | B, D |
| **Lun 19** | Cierre de piezas | H: resumen diario · G: webhook portal→GHL y limpieza visible · `FLR · handoff-humano` · pruebas trampa | todo lo anterior |
| **Mar 20** | Ensayo | Guion completo **dos veces**, medir latencias, cronometrar, grabar respaldo en video | I |
| **Mié 21** | **Demo** | Congelar cambios 12 h antes; checklist de arranque (§5) | — |

## 3. Ruta crítica y líneas de corte

Ruta crítica: **A → B → D** (sin esquema y herramientas, los agentes no tienen qué consultar).
Los canales (WhatsApp, número de voz) corren en paralelo y son el mayor riesgo externo.

Si hay retraso, se recorta en este orden (ver `analisis-especificacion.md` §D):
1. Paso 6 de la demo (reactivación en vivo) → se muestra con capturas.
2. Panel web → queda solo el resumen diario.
3. Voz saliente → queda entrante.
4. Inglés en voz → queda ES en voz, ES/EN en texto.

No se recorta: filtros duros, opt-in/horario/tope de alertas, "nunca citar precio que no vino de herramienta",
handoff por falla de herramienta.

## 4. Fases y "hecho cuando"

### Fase 0 — Descubrimiento y decisiones (14–15 oct)
- [x] Estructura del repo, `CLAUDE.md`/`AGENTS.md`, `decisiones.md`, análisis.
- [ ] Michael responde D4, D11 (y confirma D7, D8).
- [ ] Acceso al panel del portal / Hostinger y diagnóstico (¿API, BD, licencia?).
- [ ] Estado del ticket Meta/WABA y número disponible para WhatsApp y voz.
- [ ] Proyecto Supabase `flamia-luxury` creado (el MCP lo puede crear; confirmar región y costo).
- **Hecho cuando:** `ghl/state.json` tiene `supabaseProjectRef` y `demoLocationId`.

### Fase 1 — MVP de demo (15–20 oct)
- A. Migración con las correcciones C1–C6 del análisis; `select match_buyers_for_property(...)` devuelve los compradores esperados con datos seed.
- B. 5 herramientas; `search_properties` p95 < 1.5 s y ≤ 3 resultados; cada respuesta incluye `updated_at`.
- C. Pipeline de compradores, campos, tags, custom values, calendario y workflows de [`ghl/snapshot-notas.md`](../ghl/snapshot-notas.md).
- D. Prompts de [`docs/prompts/`](prompts/) cargados; pasan [`tests/agentes/preguntas-trampa.md`](../tests/agentes/preguntas-trampa.md).
- E. Cambio de precio o propiedad nueva → alerta en < 2 min, solo con opt-in, dentro de horario, sin repetir.
- F. Sync idempotente (2 corridas no duplican); propiedades desaparecidas → `withdrawn`.
- G/H. Lead del portal llega a GHL con tags, nota y oportunidad; resumen diario llega a las 8:00.
- **Hecho cuando:** se cumplen todos los criterios de §13 de la especificación (copiados en §6).

### Fase 2 — Producción Signature (después del 21)
Panel Next.js con auth y roles · sync de portal real y EasyBroker · búsqueda semántica · funnels por propiedad + QR ·
reactivación repetible y nurture 12 meses · snapshot + alta de cliente en ≤ 1 día · observabilidad y costos ·
RLS con test automatizado · modelo de costos por cliente.

### Fase 3 — Private
Multi-agente y ruteo · bóveda `visibility='private'` · motor conductual · agente de vendedores (pipeline Captación) ·
scoring de llamadas · voz premium (Retell/Vapi) · portal con dominio propio.

## 5. Checklist de arranque el día de la demo

- [ ] Supabase activo (no pausado), hoja de inventario accesible, secretos vigentes.
- [ ] Workflows `FLR · *` activos; última ejecución de cada uno en verde.
- [ ] Número de WhatsApp conectado; teléfono de la demo con `opt_in_whatsapp`.
- [ ] Número de voz asignado y llamada de prueba hecha en la última hora.
- [ ] Contacto de prueba reseteado (sin tags `alerta_pendiente`, sin alertas previas).
- [ ] Video de respaldo del guion completo en el equipo de la demo.

## 6. Criterios de aceptación de la Fase 1

1. Respuesta del agente de texto < 60 s en 9 de 10 pruebas.
2. `search_properties` p95 < 1.5 s con ≤ 3 resultados.
3. Cambio de precio → fila en `property_history` y, con coincidencia y opt-in, alerta en < 2 min.
4. Ninguna alerta sin opt-in, fuera de 08:00–21:00 o repetida (se prueban los tres casos).
5. El agente nunca cita un precio que no vino de la herramienta (preguntas trampa).
6. Herramienta caída → el agente lo admite y deriva a humano (se apaga el endpoint para probar).
7. Todos los leads de la demo aparecen en GHL con tags, nota y oportunidad.

## 7. Riesgos principales

| Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|
| WABA/plantillas no listas | Alta | Alto | D11: plan B por orden; iniciar plantillas hoy; no depender de aprobación nueva |
| Número de voz no disponible a tiempo | Media | Alto | Probar con número US de demo; llamada de Halcón entra a ese número |
| Fuga entre tenants | Baja | Crítico | D10 + tests RLS antes de cargar cualquier dato |
| Datos reales en la demo | Baja | Crítico | `property-matcher-mach` queda fuera; seed 100 % ficticio |
| Latencia de voz | Media | Medio | Respuestas ≤ 3 resultados; endpoint cerca de la región de GHL; ensayo con cronómetro |
| Alcance de 7 días | Alta | Alto | Líneas de corte de §3 |
