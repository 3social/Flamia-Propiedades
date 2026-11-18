# Flujos del CRM (lead nuevo, calificado, visita, humano, baja)

> **Desde 2026-11-17 los flujos viven en GHL** (sección *Workflows nativos en GHL*, al final). El flujo de n8n
> `FLR · ghl-automatizaciones` y sus 2 versiones anteriores quedaron **archivados** (D25). Lo que sigue describe la versión de n8n.

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

Estado (2026-11-17) y pruebas con contactos ficticios (`demoPruebas` en `state.json`):

| Workflow | Estado | Prueba |
|---|---|---|
| 1 Lead nuevo | publicado | ✅ oportunidad en *Nuevo lead* + tag `comprador`. ⚠️ **sin asesor asignado** (el builder descarta el usuario) |
| 2 Calificado | publicado | ✅ pasa a *Calificado* |
| 3 Visita agendada | publicado | sin probar (requiere cita real en el calendario) |
| 4 Pasar a humano | publicado | ✅ `ia_pausada` + tarea asignada al asesor. Vence al día siguiente: GHL rechaza `unit: hours` por API |
| 5 Baja | publicado | ✅ DND activo en Call, SMS, Email, WhatsApp, FB y GMB · quita `opt_in_whatsapp` · nota |

Aprendido sobre el builder (para no repetir intentos):
- DND = tipo `dnd_contact` con `attributes: {dnd_contact: "enable", dnd_direction: "outbound"}` (forma leída de lo que guarda la UI). Sin canal = todos.
- Tarea = `task_notification` con `assignedTo` y `dueDate: {duration, unit: "days", time, skipWeekends}`; `hours`/`hour` dan "Due Date is invalid".
- Los workflows tienen `allowMultiple: false`: un contacto no vuelve a entrar al mismo flujo; para repetir una prueba se necesita otro contacto.

Pendiente:
1. **Asesor en la oportunidad (flujos 1-3):** tras editar en la UI, el paso `create_opportunity` sigue sin usuario
   (solo se guardó `opportunity_status: open`). En el paso, campo *Assigned to* → asesor → guardar → publicar. Luego leer
   de vuelta con `get_workflow_full` y anotar aquí el nombre del atributo.
2. Opcional: **FLR · 4** → vencimiento de la tarea en 2 h (por API solo acepta días).
3. Probar el flujo 3 con una cita real en *Visitas privadas*.

## Calificación, landing y atribución en GHL (D29, 2026-11-18)
| Workflow | Disparador | Qué hace |
|---|---|---|
| FLR · 0 Calificación | Contacto creado · cambio en Operacion, Zonas, Presupuesto Min/Max, Plazo, Financiamiento · tag `visita_agendada` | Nivel Frio / Caliente / Tibio + `lead_calificado`; 1.ª vez caliente → `lead_caliente` + tarea hoy |
| FLR · 0b VIP a humano | Cambio en Presupuesto Max | ≥ `{{custom_values.umbral_vip_usd}}` → `handoff_humano` |
| FLR · 9a Landing: rango a presupuesto | Envío del formulario de la landing | Rango → min/max USD (sin tope = 100,000,000) |
| FLR · 9b Landing: canal de origen | Envío del formulario | Canal Origen + tag de fuente (UTM primero, `docs/atribucion.md` §3) |
| FLR · 9c Landing: tags y opt-in | Envío del formulario | `landing`, opt-in + Origen Opt-in, Operacion y Zonas desde custom values |
| FLR · 10 Primer canal | Cambio en Canal Origen | Primer Canal = Canal Origen si está vacío |

FLR · 7 y 8 también escriben Canal y Primer Canal. Todos publicados con reentrada activa.

Aprendido del builder:
- if/else por API: **2 ramas** (sí / no); varias opciones = cadena anidada en la rama "no".
- Condición: `{conditionType: contact_detail, conditionSubType: <fieldId|tags>, conditionOperator: ==|>|has_value|index-of-true…}`; acepta `{{custom_values.x}}`.
- **Reentrada** solo en la UI (Configuración → Permitir reentrada → Guardar). Cada `update_workflow_actions` la apaga.
- La UI no publica un `update_contact_field` con valor vacío.
