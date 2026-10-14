# Análisis de la especificación (14-oct-2026)

Lectura crítica de `docs/especificacion.md` contra lo que ya existe en FLAMIA (repo, n8n, Supabase, GHL).
Cada hallazgo indica cómo lo resuelve el plan.

## A. Qué cambia respecto al repo anterior

| Antes (sesión previa) | Ahora |
|---|---|
| Una subcuenta GHL para una inmobiliaria cualquiera | Plataforma multi-tenant (Supabase + n8n + GHL) para inmobiliarias de lujo; la subcuenta es el **cliente demo** y luego el snapshot |
| Pipeline de 5 etapas | Compradores de 6 etapas + estado ganado/perdido, y pipeline de Captación (Fase 3) |
| Agentes solo en español, sin herramientas | Bilingües ES/EN, con herramientas HTTP que consultan inventario |
| Sin inventario | `properties` en Supabase como única fuente de verdad |
| Tags con guiones (`lead-calificado`) | Tags con guion bajo, alineados con los que ya usa Sofía (`site_chat`) y con la spec |
| `tema/` en la raíz | `portal/tema/` |

## B. Lo que ya existe y se reutiliza

| Activo | Dónde | Uso |
|---|---|---|
| Proyecto `property-matcher-mach` (526 propiedades, 91 matches, pgvector) | Supabase | **No** se usa para la demo (probable data real de agentes; principio 7). Sirve de referencia de PropertyMatch |
| `Wasi - Lectura de Propiedades (AS Propiedades)` | n8n | Patrón de webhooks `buscar` / `detalle` para las herramientas 5.4 |
| `Wasi - Respuesta Automatica Agente` | n8n | Patrón "GHL → buscar → responder por WhatsApp" |
| `Flamia – Agente Unificado` (Sofía) | n8n | Captura de leads: contacto + tag `site_chat` + nota + oportunidad en `Lead-DEMO` |
| `Flamia – Voice Call Vapi` | n8n | Base si se evalúa Retell/Vapi (Private) |
| `01 Calificacion…`, `RE – 02 Agendar Showing`, `RE – 03 Seguimiento Leads Fríos` | n8n | Lógica a portar a las herramientas y al nurture |
| `SaaS - Provisioning Stripe a GHL` | n8n | **Crea subcuentas por API** con snapshot: base del runbook de alta de cliente |
| Cuenta GHL `Flamiagroup` (agencia) | GHL | Aloja el snapshot; **no** se escribe en ella |

> Los flujos de AS Propiedades y otros clientes están en producción: **no se modifican**. Los nuevos llevan prefijo `FLR ·`.

## C. Problemas técnicos del esquema y cómo se corrigen

| # | Hallazgo | Riesgo | Corrección |
|---|---|---|---|
| 1 | `location geography(point)` exige PostGIS (disponible pero no instalado) | La migración falla | Omitir en la demo; usar `lat`/`lng numeric`. PostGIS en Fase 2 si hace falta |
| 2 | `b.zones is null or p.zone = any(b.zones)`: un arreglo vacío `{}` no es NULL y excluye todo | Compradores válidos nunca coinciden | Tratar `null` **y** `cardinality = 0` como "sin filtro" (zonas, categorías) |
| 3 | `alerts_sent` no impide duplicados | "No repetir" depende solo de n8n | `price_at_send` + `unique (buyer_profile_id, property_id, reason, price_at_send)` |
| 4 | Edge Functions son URLs públicas y el `client_id` viene en el cuerpo | Un agente mal configurado (o un atacante) lee datos de otro cliente | El secreto de cada agente se **liga a un `client_id`** en servidor; se ignora el `client_id` del cuerpo |
| 5 | Trigger solo en `UPDATE` y barrido de 15 min | No cumple "alerta en < 2 min" ni cubre `INSERT` | Database Webhook (`pg_net`) en `INSERT` y en cambio de precio hacia n8n; el barrido queda como respaldo |
| 6 | `embedding vector(1536)` fija la dimensión | Rehacer la columna al cambiar de modelo | Columna nullable, no se usa en Fase 1; decidir modelo en Fase 2 |
| 7 | `match_buyers_for_property` exige `whatsapp_opt_in` | Compradores sin opt-in jamás reciben alerta | Es intencional (principio 4); documentado. Dentro de una conversación activa el agente sí responde |
| 8 | "Cerrado ganado/perdido" como etapa | En GHL ganado/perdido es el **estado** de la oportunidad | Etapa "Cerrado" + estado won/lost |
| 9 | Texto en "GHL Conversation AI y/o n8n" | Dos agentes de texto compiten | D7: GHL Conversation AI para WhatsApp en la demo; Sofía (n8n) sigue en chat web |

## D. Riesgos de calendario (7 días para la demo)

- La Fase 1 tiene ~9 frentes en paralelo y **WhatsApp depende de un ticket externo con Meta**.
- La voz necesita número; disponibilidad de número mexicano en GHL **[POR VALIDAR]**. Para la demo basta un número que pueda recibir la llamada de Halcón.
- Plantillas de marketing nuevas pueden tardar días en aprobarse: iniciar el 14-oct o no contar con ellas.
- **Líneas de corte** (se recortan en este orden si hay retraso): paso 6 de la demo (reactivación en vivo → capturas) → panel web (queda resumen diario) → voz saliente (queda entrante) → inglés en voz.
- Lo que **no** se recorta: filtros duros, opt-in/horario/tope de alertas, "no inventar precios", handoff por falla de herramienta.

## E. Lagunas de la especificación (se cubren con un default)

- Nombre comercial del producto y del cliente demo (D4): variable `Empresa Nombre`.
- Quién mantiene la hoja de inventario de la demo: Michael.
- Retención de datos de compradores: sin definir → 24 meses por defecto, documentado en el runbook.
- Texto legal del aviso de IA y de privacidad: pendiente de revisión legal local.
- Costo por cliente (GHL + Meta + voz): sin modelar, necesario antes de fijar precios de la sección 17.
