# Snapshot GHL por cliente — notas

Lo que debe contener la subcuenta demo y, después, el snapshot reutilizable (spec §10).
La definición de máquina está en los `*.json` de esta carpeta; aquí va lo que no cabe en JSON.

## Qué se crea y cómo

| Elemento | Fuente | Cómo |
|---|---|---|
| Subcuenta | — | API de agencia (patrón del flujo n8n `SaaS - Provisioning Stripe a GHL`) o UI; el MCP no la expone |
| Campos personalizados | `custom-fields.json` | MCP `locations.create-custom-field` |
| Etiquetas | `tags.json` | MCP `create-tag` |
| Custom values | `custom-values.json` | MCP `create-custom-value` |
| Pipeline Compradores | `pipeline.json` | **UI** (la API no crea pipelines) |
| Calendario "Visitas privadas" | abajo | UI (round-robin por agente, recordatorios 24 h y 2 h) |
| Workflows | abajo | UI de GHL |
| Conversation AI / Voice AI | `docs/prompts/` | UI (texto) y MCP `voice-ai.*` (voz) |
| WhatsApp (número + WABA + plantillas) | `plantillas-whatsapp/` | UI de GHL / Meta — ver riesgo WABA y D11 |

## Roles

`owner` (dueño del cliente) · `agent` (ve solo lo suyo) · `partner` (Halcón, acceso de revendedor; alcance por definir).

## Calendario "Visitas privadas"

Duración 45 min, buffer 15 min, round-robin entre agentes del cliente, recordatorio 24 h y 2 h antes por WhatsApp (plantilla
`recordatorio_visita`), zona horaria del cliente. Preferir calendario de GHL sobre Google Calendar: las citas deben entrar al CRM.

## Workflows de GHL

| Workflow | Disparador | Acciones |
|---|---|---|
| Respuesta inmediata | Mensaje entrante / formulario | Asigna tag de canal, crea oportunidad en "Nuevo lead", activa agente |
| Escalamiento por falta de respuesta | Lead sin respuesta humana > 10 min (default) tras handoff | Notifica al agente; si sigue, reasigna |
| Alerta de coincidencia | Tag `alerta_pendiente` | Envía plantilla WhatsApp ES/EN según `Idioma Preferido`; quita el tag |
| Recordatorio de visita | Cita creada | Plantilla `recordatorio_visita` 24 h y 2 h antes |
| Handoff humano | Tag `handoff_humano` | Pausa IA (`ia_pausada`), notifica al agente asignado |
| Baja de alertas | Respuesta "no más alertas" / `STOP` | Tag `no_contactar`, Opt-in = No; n8n marca `opted_out` |
| Nurture 12 meses | Etapa / segmento | Fase 2 |
| Reactivación de base | Lista segmentada | Fase 2 (en la demo, simulada con datos ficticios) |
| Reseñas post-visita | Etapa "Visita realizada" | Fase 2 |

## Reglas que GHL no debe saltarse

Ningún workflow de marketing envía si el contacto tiene `no_contactar` u `Opt-in WhatsApp = No`.
El tope semanal y el horario los aplica n8n **antes** de poner `alerta_pendiente`; GHL solo entrega.
