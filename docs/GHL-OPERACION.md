# Operación de GHL desde este repo

Comprobado el 2026-10-14 contra el conector MCP `MCP-Lead-GHL` (conexión multi-subcuenta, `list_locations` devuelve 9).

## Qué puede hacer el MCP y qué no

| Objeto | MCP | Cómo |
|---|---|---|
| Subcuenta | ❌ no expuesto | API de agencia vía n8n (patrón `SaaS - Provisioning Stripe a GHL`, que ya crea subcuentas con snapshot) o UI |
| Campos personalizados | ✅ | `locations.create-custom-field` |
| Custom values | ✅ | `create-custom-value` |
| Etiquetas | ✅ | `create-tag`, `get-location-tags` |
| Pipelines / etapas | ❌ no hay creación, solo `get-pipelines` | **UI**, luego leer IDs y guardarlos en `state.json` |
| Oportunidades | ✅ | `create-opportunity`, `Upsert-opportunity`, `update-opportunity` |
| Agente de voz | ✅ | `voice-ai.create-agent`, `patch-agent`, `voice-ai.create-action` |
| Agente de texto (Conversation AI) | ❌ no expuesto | **UI** con el prompt de `docs/prompts/texto.md` |
| Plantillas de WhatsApp, números, workflows | ❌ | UI de GHL / Meta |

## Pasos manuales previstos

1. **Subcuenta demo** (Fase 0/1-C): preferible por API de agencia reutilizando el flujo de n8n; si no, UI desde snapshot.
   Luego `list_locations` y copiar el `locationId` a `ghl/state.json` → `demoLocationId`.
2. **Pipeline "Compradores"** (~5 min): *Settings → Pipelines*, etapas exactas de `ghl/pipeline.json`; luego `get-pipelines`.
3. **Conversation AI** (~15 min): pegar prompt, conectar canal, crear las 5 acciones webhook con el secreto del agente.
4. **WhatsApp**: número, WABA, plantillas (`ghl/plantillas-whatsapp`). Ver D11 si el ticket de Meta no se resuelve.

## Reglas de seguridad al escribir

- `locationId` explícito = `demoLocationId`. **Nunca** `Mzmr9yxQ2iMapPYViK1B` (agencia Flamiagroup) ni otras subcuentas.
- `idempotencyKey` con prefijo `flr-`; `dryRun: true` la primera vez por tipo; después **leer de vuelta** para verificar.
- Antes de crear: listar lo existente y comparar por nombre (ej. `site_chat` ya existe en otras cuentas del flujo Sofía).
