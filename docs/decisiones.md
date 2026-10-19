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
| D21 | Cómo corregir la zona horaria/moneda de Ardenza | **Abierta** | El token de subcuenta no puede editar la ubicación (401). Opciones: (a) a mano en la UI, 1 min; (b) una sola llamada con la credencial de agencia `GHL Agency subc auto` de n8n, con aprobación expresa de Michael |
