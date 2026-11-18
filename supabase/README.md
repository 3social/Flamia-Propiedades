# Supabase — inventario (frente A y B)

Proyecto objetivo: **`flamia-luxury`** (nuevo, D8). Referencia en `ghl/state.json` → `supabaseProjectRef`.
No usar `property-matcher-mach`: contiene propiedades reales de agentes y no es multi-tenant.

## Orden de migraciones

| Archivo | Contenido |
|---|---|
| `0001_esquema.sql` | `vector`, `clients`, `properties`, `property_history`, `buyer_profiles`, `alerts_sent`, `lead_events`, índices |
| `0002_historial_y_triggers.sql` | `log_property_change` y trigger; Database Webhook (INSERT y cambio de precio → n8n) |
| `0003_match.sql` | `match_buyers_for_property` (filtros duros) |
| `0004_rls.sql` | RLS por `client_id`; `buyer_profiles` y `lead_events` sin acceso anon |
| `0005_tool_secrets.sql` | Tabla de secretos de herramientas ligados a `client_id` (hash, no texto plano) |

## Correcciones sobre el esquema de la spec (ver `docs/analisis-especificacion.md` §C)

1. Quitar `location geography(point)` → `lat numeric, lng numeric` (PostGIS no está instalado).
2. En `match_buyers_for_property`: `zones`/`categories` cuentan como "sin filtro" si son `null` **o** `cardinality = 0`.
3. `alerts_sent`: añadir `price_at_send numeric` y `unique (buyer_profile_id, property_id, reason, price_at_send)`.
4. Índices: `properties (client_id, status, visibility, operation, zone)`, `properties (client_id, ref_code)` único, `buyer_profiles (client_id, ghl_contact_id)`.
5. `embedding` nullable; sin índice vectorial hasta la Fase 2.

## Herramientas (Edge Functions, `functions/`)

`search_properties` · `get_property` · `send_brochure` · `book_viewing` · `upsert_buyer_profile`.

- Autenticación: encabezado con secreto → servidor resuelve `client_id`; **se ignora cualquier `client_id` del cuerpo** (D10).
- Salida corta, con `updated_at`; máx. 3 resultados en `search_properties`; `visibility='private'` nunca se devuelve.
- Registrar cada llamada (herramienta, `client_id`, latencia, error) para el criterio p95 < 1.5 s.

## Seed (`seed/`)

12–15 propiedades **ficticias** en Marina Vallarta, Zona Romántica, Conchas Chinas, Nuevo Vallarta… (USD, ES/EN, fotos de stock),
3–4 compradores ficticios (uno con opt-in conectado al teléfono de la demo), cliente demo `plan='signature'`.
Nada real, ni siquiera "inspirado en" un listing existente.

## Pruebas

`tests/rls` (usuario del cliente A no lee datos del B), `tests/sync` (dos corridas = mismo resultado).
