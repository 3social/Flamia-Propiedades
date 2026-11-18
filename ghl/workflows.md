# Flujos del CRM (lead nuevo, calificado, visita, humano, baja)

GHL responde `403 WORKFLOW_API_NOT_ENABLED_FOR_LOCATION` a la API de workflows: *"no es un problema de token ni de ámbitos;
la API está disponible solo para algunas subcuentas y agencias"*. Verificado de nuevo el 2026-11-18 con el MCP master
(`MCP-Lead-GHL`: solo expone lectura de workflows) y con el MCP de Ardenza. Por eso los 5 flujos viven en **n8n**:
`FLR · ghl-automatizaciones` (`oaVq33tFfiEV2oGg`), cada 5 minutos (D24).

- Reglas: `n8n/workflows/src/ghl-automatizaciones.js`. Fuente completa del workflow (SDK de n8n): `ghl-automatizaciones.workflow.js`.
- Cadena: `Cada 5 minutos → Search Contacts → Get Appointments → Plan Actions → Es tarea? → (Get Tasks → Sin tarea abierta) → Apply Action`.

| # | Flujo | Condición (leída del estado de GHL) | Acción |
|---|---|---|---|
| 1 | Lead nuevo | Contacto sin oportunidad en *Compradores* | Crea la oportunidad asignada al asesor, **directo en la etapa que ya le corresponde** (Nuevo lead / Calificado / Visita agendada) |
| 2 | Calificado | `Operacion` + `Zonas de Interes` + (`Presupuesto Maximo` o `Plazo de Decision`) | Tag `lead_calificado`; sube a **Calificado** |
| 3 | Visita agendada | Cita no cancelada en *Visitas privadas* (−1 a +60 días) | Tag `visita_agendada`; sube a **Visita agendada** |
| 4 | Pasar a humano | Tag `handoff_humano` (lo pone el agente de texto) sin `ia_pausada` | Tag `ia_pausada` + tarea "Contactar hoy" al asesor, vence en 2 h |
| 5 | Baja | Tag `no_contactar` | DND en todos los canales; no se aplica ninguna otra regla |

## Idempotencia
- Las etapas solo avanzan, nunca retroceden. Tags y DND son idempotentes; GHL rechaza una segunda oportunidad para el mismo contacto en el pipeline (`OPPORTUNITY_NO_DUPLICATE`).
- **La búsqueda de contactos de GHL va ~1 min atrasada** respecto a las escrituras (medido el 2026-11-18). Con datos viejos, la única
  acción no idempotente era la tarea del pase a humano (se duplicó en la prueba). Por eso, antes de crearla, el flujo lee en vivo
  `GET /contacts/{id}/tasks` y no crea si ya hay una abierta con el mismo título.
- Excluye los contactos de ejemplo de GHL (`(Example) …`). Lee los 100 contactos actualizados más recientes.

## Credencial
`GHL PIT - Ardenza` ya va puesta en los 4 nodos HTTP desde la creación por código (el MCP de n8n rechaza `setNodeCredential`
y `addNode` con `httpBearerAuth` en nodos HTTP, pero `create_workflow_from_code` sí la acepta). Ya no hay paso manual.

## Pruebas contra GHL real (2026-11-18, contacto ficticio `Prueba Flujos FLR`)
| Regla | Resultado |
|---|---|
| 1 + 2 | Oportunidad creada directo en *Calificado* + tag `lead_calificado` ✅ |
| 4 | `ia_pausada` + tarea al asesor ✅ · guarda contra tarea duplicada: creada, **prueba sin cerrar** |
| 5 | `dnd: true` ✅ |
| 3 | Sin probar (no hay citas en el calendario) |

## Pendiente
1. Cerrar la prueba de la guarda (quitar `ia_pausada`, esperar 1 min, correr: debe poner el tag y **no** crear tarea).
2. Borrar el contacto y la oportunidad de prueba (`ghl/state.json` → `demoPruebas`) y las 2 tareas que creó.
3. Publicar `oaVq33tFfiEV2oGg`; archivar `vDRGGJiXKnvXMVTt` y `CnZiQBozUkXLyE5F` (ninguno está activo).
4. Recordatorios de cita y confirmación por WhatsApp/SMS: se activan en el calendario de GHL (*Notifications*) cuando haya canal.

## Workflows nativos en GHL (2026-11-17, MCP `ghl-master`)
El MCP `ghl-master` usa el builder interno de GHL (no la API pública), así que **sí puede crear workflows** en Ardenza DEMO.
Creados en **borrador**; IDs en `ghl/state.json` → `ghlWorkflowIds`. Los 5 pasan `verify_workflow` y `validate_workflow`.

| Workflow | Disparador | Pasos |
|---|---|---|
| FLR · 1 Lead nuevo | Contacto creado | Oportunidad en *Compradores / Nuevo lead* asignada al asesor (sin duplicar) · tag `comprador` |
| FLR · 2 Calificado | Tag `lead_calificado` agregado | Mueve la oportunidad a *Calificado* (no retrocede) |
| FLR · 3 Visita agendada | Cita en el calendario *Visitas privadas* | Tag `visita_agendada` · mueve a *Visita agendada* |
| FLR · 4 Pasar a humano | Tag `handoff_humano` agregado | Tag `ia_pausada` · tarea "Contactar hoy" al asesor (2 h) |
| FLR · 5 Baja | Tag `no_contactar` agregado | DND en todos los canales · quita `opt_in_whatsapp` y `alerta_pendiente` · nota |

Diferencias con n8n:
- El flujo 2 se dispara con el tag `lead_calificado`; GHL no calcula por sí solo "operación + zonas + presupuesto/plazo".
  Alguien tiene que poner el tag: el agente de texto, el asesor o la regla 2 de n8n.
- La guarda anti-tarea duplicada no hace falta: GHL ejecuta el workflow una vez por cada vez que se agrega el tag.

Antes de publicar:
1. Abrir **FLR · 5 Baja** en la UI y confirmar que el paso DND muestra "todos los canales" (la forma del paso DND se
   armó a mano; el verificador la acepta pero no la contrastó con un ejemplo de la UI).
2. Revisar en la UI que el paso de tarea del flujo 4 muestra vencimiento de 2 h y el asesor asignado.
3. Decidir n8n **o** GHL para las reglas 1, 3, 4 y 5: si ambos están activos, se duplican tareas y notas.
