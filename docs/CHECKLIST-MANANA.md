# Checklist de la mañana — Ardenza DEMO (`20Yv36Yd31saVEePDNwB`)

Estado al 2026-10-19. Lo hecho está verificado leyendo de vuelta desde GHL; ids en `ghl/state.json`.

## Hecho en la subcuenta
- 20 etiquetas, 22 campos de contacto, 19 custom values (plantilla de snapshot; los `required_input` quedan en PENDIENTE).
- Pipeline **Compradores** (6 etapas) y calendario **Visitas privadas** (`BtGxfsUJVMjlqudnl0eM`: L–V 9–18, S 9–14, citas de 45 min, margen 15).
- Custom value *Link Agendar Visita* apuntando al calendario.
- Agente de voz (`6ad5929c4dd24333b8e4211f`): prompt en español, voz Daniela, idioma `es`, 6 min máx. Sin número aún.
- MCP propio `FLR · MCP GHL Ardenza v3` en n8n (53 herramientas + genéricas).
- 1 contacto ficticio (`demo.comprador.mar@example.com`) con etiquetas demo.

## Necesita tu intervención (en orden de impacto)
1. **Zona horaria y moneda (D21)**: la subcuenta está como San José / `America/Guatemala`. Corregir en *Settings → Business Profile* (`America/Mexico_City`, USD) o aprobar usar la credencial de agencia. Afecta horarios del calendario y de los agentes.
2. **Telefonía**: la subcuenta no tiene sistema telefónico (sin Twilio/LC Phone). Sin esto no hay número para voz ni SMS. Activarlo y comprar/asignar número al agente de voz.
3. **Cuenta de Google**: conectar para sincronizar el calendario y la hoja de inventario demo.
4. **WhatsApp / WABA (D11)**: canal, número y plantillas (`ghl/plantillas-whatsapp/plantillas.md`).
5. **Usuarios**: la subcuenta no tiene usuarios; añadir al menos uno para asignar el calendario y el handoff.
6. **Agente de texto**: Agent Studio por API no se pudo crear sin explorar el esquema (un POST de prueba puede crear objetos reales). Crearlo en la UI pegando `docs/prompts/texto.md`.
7. **Escuchar y aprobar la voz** del agente (Daniela) y el guion.
8. **Postgres**: confirmar crear el servicio en el proyecto `supabase` de EasyPanel y crear la credencial Postgres en n8n (necesaria para migraciones y herramientas `FLR · tool-*`).
9. **Datos reales del cliente** para custom values pendientes (nombre D4, teléfono, web, horario).
10. Opcional: rotar secretos expuestos en el volcado de variables de EasyPanel.

## Pendiente que sigo yo cuando haya (2) y (8)
- Migraciones 0001–0005 + seed en `supabase/`, workflows `FLR · tool-*`, acciones del agente de voz, base de conocimiento y FAQs, workflows de GHL (no creables por API).
