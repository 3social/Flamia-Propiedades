# FLR · tool-properties (`4JKBnDhPOGO8ryR0`)

Herramientas `search_properties` y `get_property` (spec §5.4) para los agentes de Ardenza DEMO.

| Ruta | Cuerpo | Respuesta |
|---|---|---|
| `POST /webhook/flr-search-properties` | `operation` (compra/renta), `zone`, `category`, `price_max`, `price_min`, `bedrooms_min`, `query_text`, `language` | `{ok, total_matches, results[≤3], summary}`; cada resultado con `ref_code`, precio, zona, recámaras y `updated_at` |
| `POST /webhook/flr-get-property` | `ref_code`, `language` | `{ok, found, property}` con `highlights` y `construction_m2` |

- **Autenticación (D10):** encabezado `x-flr-key`. El flujo calcula su SHA-256 y lo busca en la Data Table `flr_clients`; de ahí sale el `client_id`. Cualquier `client_id` del cuerpo se ignora. Sin clave válida → 401.
- **Inventario (D22):** Data Table `flr_properties` (ficticio, `supabase/seed/properties-demo.json`). Solo `visibility=public` y `status=activa`; PV-0014 es privada y nunca sale.
- **Código:** `src/tool-properties.js` es el nodo *Build Response*; probado con mocks (búsqueda, ficha, privada, 401) y en producción (≈0.6 s).
- **Pendiente:** al existir Postgres, cambiar los dos nodos Data Table por consultas a `properties`/`tool_secrets`; el contrato no cambia.
- Ojo: el historial de ejecuciones de n8n guarda la clave en claro en *Normalize Request*; poner la retención de ejecuciones del flujo en "no guardar datos exitosos" o rotar la clave si se comparte el n8n.
