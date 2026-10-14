# AGENTS.md — FLAMIA Luxury Real Estate System

Guía común para cualquier agente de código (Claude Code, Codex, Cursor…). Claude Code además lee
`CLAUDE.md`, que importa este archivo.

## Qué es

Plataforma inmobiliaria premium que FLAMIA construye y **Halcón** (Puerto Vallarta / Guadalajara) vende a
agentes y equipos de lujo. No es solo un CRM: responde a cada lead en < 1 min, atiende por texto y voz en
ES/EN, ofrece propiedades reales del inventario, da seguimiento 12 meses y muestra al dueño qué hace cada
agente. **No** es MLS, contabilidad ni reemplazo del agente humano (la IA califica y agenda; el humano cierra).

Hito: **demo el 21-oct-2026**. Plan en `docs/PLAN.md`; especificación en `docs/especificacion.md`.

## Principios (no negociables)

1. **Una sola fuente de verdad de inventario: Supabase.** Los agentes nunca "recuerdan" precios: solo citan lo que devuelve una herramienta, con fecha de actualización.
2. **GHL es canal y CRM**; la lógica pesada vive en Supabase + n8n.
3. **Multi-tenant desde el día 1:** todo registro lleva `client_id`.
4. **Consentimiento primero:** sin opt-in no hay marketing por WhatsApp; la baja corta todo envío.
5. **Menos mensajes, más relevantes:** máx. 2 alertas/semana por comprador, 2–3 propiedades por mensaje, nada entre 21:00 y 08:00.
6. **Idempotencia:** toda sincronización puede correr dos veces sin duplicar (`unique (client_id, source, external_id)`).
7. **Datos ficticios en demo.** Nunca listings reales de agentes sin autorización escrita.
8. **Español primero, inglés soportado** (agentes, portal, plantillas).
9. **Simple antes que ingenioso:** filtros duros primero, semántica después.

## Arquitectura en una vista

```
Portal / funnels / QR / WhatsApp ──► Supabase (properties, buyer_profiles, alerts_sent…) ◄── Sheets · portal · EasyBroker
                                          │ Edge Functions = herramientas (search, get, book, brochure, upsert)
                                          ▼
                       Agentes IA (GHL Conversation AI · GHL Voice AI) ──► GHL (CRM, pipeline, mensajes)
                                          ▲
                              n8n: sync · alertas · reglas de envío · resumen diario
```

- **Supabase** decide *quién* coincide con *qué*. **n8n** decide *cuándo* y *a quién sí*. **GHL** entrega, registra y mueve el pipeline.

## Estructura del repo

```
AGENTS.md / CLAUDE.md          guías para agentes
docs/especificacion.md         documento fuente (no editar)
docs/analisis-especificacion.md hallazgos y correcciones a la spec
docs/decisiones.md             D1–D15 con estado
docs/PLAN.md                   calendario, frentes, criterios
docs/runbook-alta-cliente.md   alta de cliente nuevo y "terminado" para producción
docs/GHL-OPERACION.md          qué hace el MCP de GHL y qué es manual
docs/prompts/                  prompts versionados (texto, voz, vendedores)
supabase/{migrations,functions,seed}
n8n/workflows/                 JSON exportados + README de cada flujo
ghl/                           snapshot-notas.md, *.json de configuración, plantillas-whatsapp/, state.json
apps/{dashboard,landings}      Next.js (Fase 2)
portal/                        notas-rebrand.md y tema/flamia-custom.css (Flex Home / Botble)
tests/{rls,sync,agentes}
```

## Reglas operativas

- **Idioma**: documentación y commits en español; prompts en ES y EN (el agente responde en el idioma del lead).
- **Marca**: violeta `#7C3AED`, magenta `#D946EF`, navy `#0A0E1A`; títulos Syne, cuerpo DM Sans. El nombre del producto/portal es una variable (D4); no hardcodear.
- **Secretos** (PIT de GHL, claves de Supabase, API keys de clientes): variables de entorno o Supabase Vault. **Nunca** en el repo. Datos pendientes se marcan `null`.
- **Marcas `[POR VALIDAR]`** en la spec = supuesto, no hecho. Verificar o preguntar.
- Archivos `ghl/*.json`: `required_input: true` = dato que debe dar el cliente, no se inventa. Aplicar es idempotente: listar antes de crear y registrar IDs en `ghl/state.json`.
- Herramientas para agentes: respuestas cortas (voz), máx. 3 resultados, siempre con `updated_at`; `visibility='private'` jamás sale por herramientas públicas.

## Git

Rama de la sesión; commits pequeños y descriptivos. No abrir Pull Request salvo que se pida.
