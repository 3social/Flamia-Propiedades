# Decisiones

Estado: **Adoptada** = default aplicado, se puede revertir · **Abierta** = requiere respuesta de una persona.
Formato: contexto → decisión → consecuencia.

## De la especificación (§14)

| # | Decisión | Estado | Resolución adoptada |
|---|---|---|---|
| D1 | Modelo del portal | Adoptada | Instancia por cliente (Signature/Private). Portal compartido solo si Halcón lo pide para la revista |
| D2 | Fuente de inventario | Adoptada | Hoja de Google para la demo; el resto según entrevista con cada agente |
| D3 | Voz | Adoptada | GHL Voice AI para Signature y demo; evaluar Retell/Vapi en Private tras pruebas de latencia |
| D4 | Nombre del producto/portal | **Abierta** | Variable de configuración (`Empresa Nombre`); demo usa "[Nombre ficticio] Realty" |
| D5 | Reparto con Halcón | **Abierta** | Fuera del alcance técnico; cierra Michael con Tomás |
| D6 | Licencia del portal (Flex Home / Botble) | **Abierta** | Verificar antes de vender; no bloquea la demo |

## Nuevas, surgidas del análisis

| # | Decisión | Estado | Resolución |
|---|---|---|---|
| D7 | Agente de texto de la demo | Adoptada | **GHL Conversation AI** (WhatsApp) con acciones webhook a las herramientas: queda todo en el CRM. Sofía (n8n) sigue en chat web |
| D8 | Dónde vive el inventario | Adoptada | **Proyecto Supabase nuevo `flamia-luxury`**. `property-matcher-mach` contiene datos reales de agentes y no es multi-tenant; mezclarlo rompe los principios 3 y 7 |
| D9 | Pipeline de compradores | Adoptada | 6 etapas (Nuevo lead → Calificado → Visita agendada → Visita realizada → Negociación → Cerrado) + estado won/lost |
| D10 | Autenticación de herramientas | Adoptada | Un secreto por agente/cliente guardado en servidor y ligado a `client_id`; el cuerpo no puede elegir tenant |
| D11 | Plan B de WhatsApp para la demo | **Abierta** | Orden: (1) número ya verificado en GHL → (2) alerta por SMS/email para el paso 4 → (3) Evolution API en un número de demo, **solo demo, nunca producción** (incumple términos de Meta). Michael elige |
| D12 | Zona horaria y moneda | Adoptada | `America/Mexico_City`, USD (listados de Vallarta) |
| D13 | Alta de subcuenta | Adoptada | Vía API de agencia usando el patrón del flujo n8n `SaaS - Provisioning Stripe a GHL`; el MCP `MCP-Lead-GHL` no la expone |
| D14 | Convenciones de nombres | Adoptada | Workflows n8n con prefijo `FLR · `; tags con guion bajo; ref de propiedad `PV-0001` |
| D15 | Retención de datos de compradores | **Abierta** | Default 24 meses hasta revisión legal |

## Subcuenta de trabajo

| # | Decisión | Estado | Resolución |
|---|---|---|---|
| D16 | Dónde se monta el sistema | Adoptada | Subcuenta **Ardenza DEMO** (`20Yv36Yd31saVEePDNwB`) dentro de la agencia Flamia. Sustituye a la "subcuenta demo" por crear; el token tiene todos los ámbitos (`scopeFilteredCount` 0) |
| D17 | País, zona horaria y moneda de la subcuenta | Adoptada | **La demo es Puerto Vallarta** (`America/Mexico_City`, USD). Ardenza DEMO está creada como San José, CR / `America/Guatemala`: el MCP no expone la edición de la ubicación (hay operaciones filtradas por ámbito), así que la zona horaria y la moneda se corrigen a mano en *Settings → Business Profile* |

## Infraestructura

| # | Decisión | Estado | Resolución |
|---|---|---|---|
| D18 | MCP propio para Ardenza | Propuesta | MCP de n8n atado a una ubicación con PIT de todos los ámbitos y 3 herramientas genéricas (`ghl_get`, `ghl_write`, `ghl_delete`). Ver `docs/infra-easypanel.md`. Pendiente: Michael crea la credencial `GHL PIT - Ardenza` en n8n |
| D19 | Supabase en EasyPanel, solo lo necesario | Adoptada | Postgres con pgvector + PostgREST (+ Kong/Studio opcionales). Sin Edge Functions: las herramientas son webhooks de n8n. Supersede la recomendación de proyecto gestionado |
| D20 | Ubicación de la base | Propuesta | En `personaldev` junto a n8n (red interna); el proyecto `supabase` vacío queda para la Fase 2 o se reutiliza si Michael prefiere |
| D21 | Cómo corregir la zona horaria/moneda de Ardenza | Cerrada | Corregida a mano en la UI: `America/Mexico_City`, USD (verificado por API el 2026-11-18) |
| D22 | Inventario de la demo mientras no hay Postgres | Adoptada | Data Tables de n8n `flr_properties` y `flr_clients` (mismo esquema mínimo que `properties`/`tool_secrets`). Las herramientas `FLR · tool-properties` leen de ahí con el tenant resuelto por secreto (D10). Al crear Postgres se cambian solo los dos nodos de lectura; el contrato de las herramientas no cambia |
| D23 | Cómo consulta inventario el agente de texto | Adoptada (provisional) | Conversation AI no puede llamar webhooks, solo leer bases de conocimiento. Para la demo, la KB **Ardenza - Inventario** guarda una copia de las fichas públicas con su fecha de actualización. Choca con el principio 1 (una sola fuente): mitigación = la copia se regenera desde `flr_properties` (pendiente `FLR · sync-kb-inventario`) y el prompt obliga a citar referencia y fecha. Salida definitiva: Agent Studio con nodo HTTP a las herramientas cuando su API de versiones esté documentada |
| D24 | Dónde viven los flujos del CRM | Adoptada | En n8n (`FLR · ghl-automatizaciones`, sondeo cada 5 min) porque la API de workflows de GHL no está habilitada para la subcuenta. Si GHL la habilita o se hace snapshot con workflows de UI, se puede migrar; las reglas quedan documentadas en `ghl/workflows.md` |

## D25 — Flujos del CRM en GHL, no en n8n (2026-11-17)
**Estado:** decidido. El MCP `ghl-master` crea y publica workflows con el builder interno de GHL, lo que la API pública no
permitía (D24). Los 5 flujos pasan a ser workflows nativos de GHL (`FLR · 1…5`) y `FLR · ghl-automatizaciones` de n8n se archiva.
**Por qué:** se disparan por eventos (contacto creado, tag, cita) en vez de un sondeo cada 5 min con ~1 min de atraso en la
búsqueda; el cliente los ve y edita en su propia cuenta; desaparece la guarda anti-tarea duplicada.
**Costo:** la calificación (operación + zonas + presupuesto/plazo) ya no se calcula sola; el flujo 2 depende del tag `lead_calificado`.

## D26 — Modelo único de calificación (2026-11-17)
**Estado:** decidido. Voz, texto y landing **solo capturan** datos en campos del contacto; un flujo central (GHL dispara,
n8n calcula) escribe `Nivel Lead` y los tags `lead_calificado` / `lead_caliente` / `handoff_humano`. Detalle en `docs/calificacion.md`.
Umbral VIP = custom value `Umbral VIP USD`, demo **1,000,000**: arriba de eso el ticket justifica humano inmediato.
Campos nuevos: `Nivel Lead`, `Proposito`, `Residencia`.
**Por qué:** un lead cruza canales; con la regla en un solo lugar no repite respuestas y el criterio se ajusta por cliente sin tocar prompts.

## D27 — Landing por proyecto o propiedad, con la marca del cliente (2026-11-17)
**Estado:** decidido. La landing lleva la **marca del cliente**, no la de FLAMIA. Una plantilla parametrizada por proyecto o
propiedad. El diseño visual se define **por cliente** con wireframe aprobado antes de construir en GHL; FLAMIA aporta
estructura, sistema de diseño luxury y la mecánica (multi-paso, calendario, WhatsApp con `ref`, QR, UTM, pixel, A/B).

## D28 — Atribución de Google, Meta y TikTok (2026-11-18)
**Estado:** decidido. Cada lead guarda canal de último toque y de primer toque (este no se sobrescribe), UTM completos,
IDs de campaña/grupo/anuncio y el click ID de cada plataforma (`gclid`/`gbraid`/`wbraid`, `fbclid`/`fbc`/`fbp`, `ttclid`).
Dos entradas: landing (captura en el navegador, 90 días de primer toque) y formularios nativos (Google por webhook a n8n;
Meta y TikTok por la integración de GHL + tag de fuente). Detalle en `docs/atribucion.md`.
**Por qué:** en lujo el ciclo dura meses; sin primer toque se le atribuye la venta al último anuncio. Los click IDs permiten
devolver conversiones (Fase 2) para que cada plataforma optimice hacia compradores reales, no hacia formularios.
