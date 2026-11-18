# Workflows de GHL (se arman en la UI)

La API pública de GHL solo **lee** workflows (`search-workflows`, `get-workflow-definition`); no los crea. Ni el MCP master
(`MCP-Lead-GHL`) ni el MCP propio pueden hacerlo. Estos cinco se construyen a mano en *Automation → Workflows* de Ardenza DEMO
(≈30 min en total) y luego se registran sus ids en `ghl/state.json` → `ghlWorkflowIds`.

| # | Nombre | Disparador | Acciones | Para qué |
|---|---|---|---|---|
| 1 | `FLR · Lead nuevo` | Contact Created | Crear oportunidad en **Compradores / Nuevo lead** (si no existe); tag del canal según `source`; nota "Origen: …" | Todo lead entra al pipeline (criterio de aceptación de la demo) |
| 2 | `FLR · Lead calificado` | Contact Changed: `Operacion` y `Zonas de Interes` no vacíos **y** (`Presupuesto Maximo` o `Plazo de Decision` no vacío) | Tag `lead_calificado`; mover oportunidad a **Calificado** | Regla "calificado" de `docs/prompts/texto.md` |
| 3 | `FLR · Visita agendada` | Appointment Status = booked, calendario **Visitas privadas** | Tag `visita_agendada`; mover a **Visita agendada**; mensaje de confirmación (SMS/WhatsApp cuando haya canal); recordatorio 24 h y 2 h antes | Cierra el ciclo del agente que agenda |
| 4 | `FLR · Pasar a humano` | Tag añadido `handoff_humano` | Tag `ia_pausada`; apagar Conversation AI para el contacto; notificación interna al usuario asignado (o al admin); tarea "Contactar hoy" | Sustituye la acción *humanHandOver* del agente de texto, que la API rechaza mientras la subcuenta no tenga usuarios |
| 5 | `FLR · Baja` | Tag añadido `no_contactar` (lo pone la acción *stopBot*) | Activar DND en todos los canales; quitar de workflows de marketing; nota con fecha | Principio 4: la baja corta todo envío |

Después de crear el #4 se puede sumar como `callEndWorkflowIds` del agente de voz un `FLR · Fin de llamada` (nota + tarea si quedó
sin visita) y como acción `WORKFLOW_TRIGGER` del agente de voz para "pasar con un asesor".
