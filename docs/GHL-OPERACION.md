# Operación de GHL desde este repo

Comprobado el 2026-10-14 contra el conector MCP `MCP-Lead-GHL` (conexión multi-subcuenta).

## Qué puede hacer el MCP y qué no

| Objeto | MCP | Operación |
|---|---|---|
| Subcuenta | ❌ no crea | solo `get-location`, `search-locations`, `list_locations` → **manual** |
| Custom values | ✅ | `create-custom-value` |
| Campos personalizados | ✅ | `locations.create-custom-field` |
| Etiquetas | ✅ | `create-tag`, `get-location-tags` |
| Pipeline / etapas | ❌ no crea | solo `get-pipelines` (lectura) → **manual** en UI |
| Oportunidades | ✅ | `create-opportunity`, `update-opportunity`, `Upsert-opportunity` |
| Agente de voz | ✅ | `voice-ai.create-agent`, `patch-agent`, `voice-ai.create-action` |
| Agente de texto (Conversation AI) | ❌ no expuesto | **manual** en UI con prompt de `ghl/agents/texto.md` |

## Fase 1 — crear la subcuenta (manual, ~5 min)

1. Agency view → **Sub-Accounts → Create Sub-Account** (o desde snapshot de inmobiliaria si existe).
2. Datos: nombre, teléfono, correo, dirección, zona horaria, moneda, idioma.
3. Activar los permisos de Conversaciones, Calendarios, Oportunidades, Workflows y Voice AI.
4. Volver a esta sesión y pedir: *"lista las ubicaciones"*. Copiar el `locationId` nuevo a `ghl/state.json`.

## Fase 5 — crear el pipeline (manual, ~5 min)

Settings → **Pipelines → Create**, nombre y etapas exactamente como `ghl/pipeline.json`.
Después ejecutar `get-pipelines` y guardar `pipelineId` y los `stageId` en `ghl/state.json`.

## Fase 6 — agente de texto (manual)

AI Agents → **Conversation AI** → crear bot; pegar el prompt de `ghl/agents/texto.md`; conectar canales;
activar acciones de campos, tags, etapa y calendario. Registrar el ID del bot en `ghl/state.json`.

## Reglas de seguridad al escribir

- Siempre `locationId` explícito = el de `ghl/state.json`.
- `idempotencyKey` con prefijo `flamia-prop-`.
- `dryRun: true` en la primera escritura de cada tipo; luego aplicar y **leer de vuelta** para verificar.
- Cuentas que **no** se tocan: Flamiagroup (`Mzmr9yxQ2iMapPYViK1B`, agencia) y las de otros clientes.
