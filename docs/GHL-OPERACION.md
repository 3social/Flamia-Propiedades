# Operación de GHL desde este repo

Comprobado el 2026-10-14 contra el conector MCP `MCP-Lead-GHL` (conexión multi-subcuenta, `list_locations` devuelve 9).

## Qué puede hacer el MCP y qué no

| Objeto | MCP | Cómo |
|---|---|---|
| Subcuenta | ❌ no expuesto | API de agencia vía n8n (patrón `SaaS - Provisioning Stripe a GHL`, que ya crea subcuentas con snapshot) o UI |
| Campos personalizados | ✅ | `locations.create-custom-field` |
| Custom values | ✅ | `create-custom-value` |
| Etiquetas | ✅ | `create-tag`, `get-location-tags` |
| Pipelines / etapas | ✅ vía MCP propio (`POST /opportunities/pipelines`, con `stages[].position` numérica). El conector `MCP-Lead-GHL` solo lee | Corrección 2026-10-19: antes se creía que no existía |
| Oportunidades | ✅ | `create-opportunity`, `Upsert-opportunity`, `update-opportunity` |
| Agente de voz | ✅ | `voice-ai.create-agent`, `patch-agent`, `voice-ai.create-action` |
| Agente de texto | Existe `/agent-studio/agents` (200, hoy vacío); `/conversation-ai/agents` no existe (404) | Por explorar con el MCP propio; si no alcanza, UI con `docs/prompts/texto.md` |
| Plantillas de WhatsApp, números, workflows | ❌ | UI de GHL / Meta |

## Pasos manuales previstos

1. **Subcuenta demo** (Fase 0/1-C): preferible por API de agencia reutilizando el flujo de n8n; si no, UI desde snapshot.
   Luego `list_locations` y copiar el `locationId` a `ghl/state.json` → `demoLocationId`.
2. ~~Pipeline "Compradores"~~ **Hecho por API** el 2026-10-19 (ids en `ghl/state.json`).
3. **Agente de texto**: probar primero Agent Studio por API; si no alcanza, UI (pegar prompt, conectar canal, 5 acciones webhook con el secreto del agente).
4. **WhatsApp**: número, WABA, plantillas (`ghl/plantillas-whatsapp`). Ver D11 si el ticket de Meta no se resuelve.

## Reglas de seguridad al escribir

- `locationId` explícito = `demoLocationId`. **Nunca** `Mzmr9yxQ2iMapPYViK1B` (agencia Flamiagroup) ni otras subcuentas.
- `idempotencyKey` con prefijo `flr-`; `dryRun: true` la primera vez por tipo; después **leer de vuelta** para verificar.
- Antes de crear: listar lo existente y comparar por nombre (ej. `site_chat` ya existe en otras cuentas del flujo Sofía).

## Actualización 2026-10-19 — MCP propio de Ardenza

Con el MCP propio (`FLR · MCP GHL Ardenza v3`, ver `docs/infra-easypanel.md`) varias cosas marcadas como manuales dejan de serlo, porque el proxy llega a endpoints
que el conector `MCP-Lead-GHL` no expone. Verificado: crear pipelines (hecho), listar `agent-studio`, `voice-ai`, `knowledge-bases`.
Siguen sin poder hacerse con el token de subcuenta: editar la ubicación (401, exige agencia), crear subcuentas y `custom-menus` (sin ámbito).
Telefonía: la subcuenta **no tiene sistema telefónico** (`/phone-system/numbers` → 404 "No Twilio account"); sin él no hay número para voz ni SMS.

## Hallazgos 2026-10-19 (calendario y voz)

- Calendarios: `PUT` reemplaza `slotDuration`/`slotInterval` si no se reenvían; `openHours` admite un solo día en `daysOfTheWeek` por entrada.
- Voice AI: `language` válido es `es` (no `es-MX`); `GET /voice-ai/voices` rechaza `locationId` y `pageSize` > 20.
- Un `POST` de prueba puede crear objetos reales (así nació el agente de voz). Probar en lectura primero.
- Herramienta de contactos del MCP: el parámetro `tags` es texto separado por comas, no un arreglo JSON.
