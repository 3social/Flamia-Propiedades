# Flujos del CRM (lead nuevo, calificado, visita, humano, baja)

GHL responde `403 WORKFLOW_API_NOT_ENABLED_FOR_LOCATION` a la API de workflows: *"no es un problema de token ni de ámbitos;
la API está disponible solo para algunas subcuentas y agencias"*. Por eso los 5 flujos viven en **n8n**:
`FLR · ghl-automatizaciones` (`vDRGGJiXKnvXMVTt`), cada 5 minutos (D24). Reglas en `n8n/workflows/src/ghl-automatizaciones.js`.

| # | Flujo | Condición (leída del estado de GHL) | Acción |
|---|---|---|---|
| 1 | Lead nuevo | Contacto sin oportunidad en *Compradores* | Crea oportunidad en **Nuevo lead**, asignada al asesor |
| 2 | Calificado | `Operacion` + `Zonas de Interes` + (`Presupuesto Maximo` o `Plazo de Decision`) | Tag `lead_calificado`; sube a **Calificado** |
| 3 | Visita agendada | Cita no cancelada en *Visitas privadas* (−1 a +60 días) | Tag `visita_agendada`; sube a **Visita agendada** |
| 4 | Pasar a humano | Tag `handoff_humano` (lo pone el agente de texto) sin `ia_pausada` | Tag `ia_pausada` + tarea "Contactar hoy" al asesor, vence en 2 h |
| 5 | Baja | Tag `no_contactar` | DND en todos los canales; no se aplica ninguna otra regla |

- **Idempotente:** cada corrida compara contra el estado actual y solo envía lo que falta; las etapas solo avanzan, nunca retroceden.
- Excluye los contactos de ejemplo de GHL (`(Example) …`). Lee los 100 contactos actualizados más recientes.
- Probado con datos fijados (lead nuevo, calificado + humano, contacto de ejemplo ignorado) y el payload de oportunidad validado contra la API real.
- **Pendiente manual (1 min):** en n8n, abrir el flujo y elegir la credencial `GHL PIT - Ardenza` en los 3 nodos HTTP; luego *Publish*. El MCP de n8n no permite adjuntar credenciales a nodos HTTP.
- Recordatorios de cita y confirmación por WhatsApp/SMS: se activan en el calendario de GHL (*Notifications*) cuando haya canal.
