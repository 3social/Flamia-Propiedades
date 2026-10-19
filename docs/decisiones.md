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
| D17 | País, zona horaria y moneda de la subcuenta | **Abierta** | La subcuenta está en San José, Costa Rica, zona `America/Guatemala`, sin moneda. La spec asume Puerto Vallarta (`America/Mexico_City`, USD). Hay que decidir si la demo es Vallarta o Costa Rica; afecta a zona horaria, horario de alertas, moneda, número de voz y datos seed |
