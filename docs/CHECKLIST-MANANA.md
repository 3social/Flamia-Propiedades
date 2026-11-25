# Estado y pendientes — Ardenza DEMO (`20Yv36Yd31saVEePDNwB`)

Actualizado 2026-11-18. Todo lo marcado hecho se verificó leyendo de vuelta desde GHL o n8n; ids en `ghl/state.json`.

## Hecho
- **Base CRM:** 20 tags, 22 campos, 19 custom values, pipeline *Compradores*, calendario *Visitas privadas*. Zona horaria y moneda ya en `America/Mexico_City` / USD.
- **Inventario demo:** 14 propiedades ficticias (1 privada) en la Data Table `flr_properties` de n8n (D22) + `flr_clients` con el hash del secreto.
- **Herramientas:** `FLR · tool-properties` (`search_properties`, `get_property`) publicado; probado en producción (≈0.6 s, máx. 3 resultados, nunca la privada, 401 sin clave).
- **Bases de conocimiento:** *Ardenza - Preguntas frecuentes* (13 FAQs sin precios ni datos legales) y *Ardenza - Inventario* (13 fichas públicas con fecha).
- **Agente de voz** `Sofía (voz)`: prompt con regla de oro y 11 acciones — búsqueda e info de propiedad (n8n), FAQs, agenda en *Visitas privadas* y 7 extracciones a campos del contacto.
- **Agente de texto** `Sofía (texto)` (Conversation AI, autopiloto, WhatsApp/SMS/chat web/FB/IG): KB de inventario y FAQs, agenda, baja con tag `no_contactar` y 8 acciones de guardar campos.

## Necesita tu intervención (en orden de impacto)
1. **Telefonía**: la subcuenta sigue sin sistema telefónico. Activar LC Phone/Twilio y asignar un número al agente de voz → sin esto no hay llamadas ni SMS.
2. **WhatsApp / WABA (D11)**: conectar el canal; el agente de texto ya está en autopiloto para WhatsApp y responderá en cuanto exista.
3. ~~Usuarios~~ hecho: asesor asignado al calendario (ahora round-robin) y pase a humano en el agente de texto.
4. **Flujos del CRM**: 5 workflows nativos de GHL publicados y probados (D25, FLA-42). Asesor asignado en la oportunidad (FLR · 1, probado 2026-11-23). FLR · 3 probado con una cita real desde la página de gracias (2026-11-24).
5. **Probar** en *AI Agents*: llamada de prueba con el agente de voz y chat de prueba con el de texto; pasar `tests/agentes/preguntas-trampa.md`.
6. **Postgres** en EasyPanel + credencial en n8n → migrar `flr_properties` a Supabase (el contrato de las herramientas no cambia).
7. **Cuenta de Google**, datos reales del cliente para los custom values en PENDIENTE (D4), y voz Daniela aprobada.
8. Opcional: retención de ejecuciones de `FLR · tool-properties` en "no guardar" (la clave queda en el historial) y rotar secretos expuestos.

## Lo siguiente que construyo cuando haya (1)–(4)
- `FLR · sync-kb-inventario` (regenera la KB de inventario desde `flr_properties`, D23).
- `FLR · alerta-coincidencia` pospuesto hasta tener base de datos real (D32, será workflow nativo de GHL); `FLR · lead-portal-a-ghl` en pausa. El resumen diario ya está en GHL (D31: *FLR · Panel del dueño*, correo diario 08:00).
- Acciones `WORKFLOW_TRIGGER` / `callEndWorkflowIds` del agente de voz apuntando a los workflows de la UI.
