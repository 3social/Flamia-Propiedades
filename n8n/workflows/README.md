# Workflows n8n

Prefijo `FLR · ` en el nombre dentro de n8n. Aquí se guardan los JSON exportados y una nota por flujo.
**No modificar** los flujos existentes (producción de otros clientes); solo leerlos como patrón.

| Workflow | Disparador | Qué hace | Fase | Patrón existente a reutilizar |
|---|---|---|---|---|
| `FLR · sync-sheet-properties` | cada 15 min | Lee la hoja, `upsert` en `properties`, marca `withdrawn` las que desaparecen | 1 | `Wasi - Lectura de Propiedades (AS Propiedades)` (mapeo de campos) |
| `FLR · alerta-coincidencia` | Database Webhook (insert / baja de precio) + barrido 15 min | `match_buyers_for_property` → reglas (opt-in, tope 2/sem, no repetir, 08:00–21:00, agrupar 2–3) → campos GHL + tag `alerta_pendiente` → `alerts_sent` | 1 | — |
| `FLR · lead-portal-a-ghl` | webhook del portal (formulario, "me importa") | Contacto + tag de canal + nota + oportunidad "Nuevo lead", con `ref` y UTM | 1 | `Flamia – Agente Unificado` (Sofía) |
| `FLR · perfil-comprador-ghl-a-supabase` | cambio de campos del contacto en GHL | Sincroniza a `buyer_profiles`, incluido opt-in/out | 1 | — |
| `FLR · resumen-diario-dueno` | diario 08:00 hora local | Leads nuevos, tiempo de 1.ª respuesta, sin atender, estancados, visitas, alertas | 1 (simple) | — |
| `FLR · handoff-humano` | tag `handoff_humano` o fallo de herramienta | Pausa IA, avisa al agente, reasigna si no responde en 10 min | 1 (mínimo) | `RE – 02 Agendar Showing GHL` |
| `FLR · sync-portal-properties` | cada 15 min | Portal → `properties` | 2 | — |
| `FLR · sync-easybroker` | cada 15–30 min | EasyBroker (API key solo lectura, cifrada) → `properties` | 2 | — |
| `FLR · reactivacion-base` | manual / campaña | Limpia, segmenta y envía por plantillas con consentimiento | 2 (demo simulada) | `RE – 03 Seguimiento Leads Fríos GHL` |

## Reglas

- Credenciales de GHL (PIT, Bearer) y Supabase **solo** como credenciales de n8n; nunca en el JSON exportado.
- Todo flujo es idempotente y registra fallos (alerta por correo a FLAMIA, como el provisioning de SaaS).
- Un flujo por archivo: `n8n/workflows/<nombre>.json` + sección en este README al crearlo.
- Alta de cliente nuevo: base en `SaaS - Provisioning Stripe a GHL` (ver `docs/runbook-alta-cliente.md`).
