# AGENTS.md — Flamia Propiedades

Guía común para cualquier agente de código (Claude Code, Codex, Cursor…) que trabaje en este repo.
Claude Code además lee `CLAUDE.md`, que importa este archivo.

## Qué es este proyecto

Sistema comercial para una inmobiliaria cliente de FLAMIA, en dos piezas:

1. **Sitio web** — tema Flex Home sobre Botble Real Estate. La capa de marca vive en `tema/flamia-custom.css`.
2. **CRM en GoHighLevel (GHL)** — una subcuenta dedicada con captación, pipeline y dos agentes de IA
   (texto y voz) que califican leads y agendan visitas.

El repo es la **fuente de verdad** de la configuración de GHL: cada objeto (custom values, tags,
pipeline, prompts) se define aquí en archivos y luego se aplica a la subcuenta. Nada se configura
"a ojo" en la UI sin quedar reflejado en `ghl/`.

## Estructura

```
AGENTS.md / CLAUDE.md     guías para agentes
docs/PLAN.md              plan por fases, dependencias y criterios de "hecho"
docs/GHL-OPERACION.md     qué se puede automatizar por MCP y qué es manual
ghl/state.json            IDs reales de GHL (locationId, pipelineId, agentId…); se llena al aplicar
ghl/custom-values.json    textos y datos de negocio reutilizables ({{custom_values.*}})
ghl/custom-fields.json    campos de contacto que usan agentes y pipeline
ghl/tags.json             etiquetas básicas
ghl/pipeline.json         pipeline de ventas de 5 etapas
ghl/agents/texto.md       prompt y reglas del agente de texto (Conversation AI)
ghl/agents/voz.md         prompt y reglas del agente de voz (Voice AI)
tema/flamia-custom.css    marca para el tema web
```

## Reglas del dominio

- **Idioma**: español neutro, tuteo cercano y profesional. Prompts, tags y textos al cliente van en español.
- **Marca FLAMIA**: violeta `#7C3AED`, magenta `#D946EF`, navy `#0A0E1A`; títulos Syne, cuerpo DM Sans.
- **Pipeline** (5 etapas): Nuevo lead → Calificado → Visita agendada → Negociación → Cierre.
- Los agentes **nunca inventan** precios, disponibilidad ni condiciones legales o de financiamiento;
  si no está en la base de conocimiento, derivan a un asesor humano.
- No se guardan secretos (tokens, claves, teléfonos personales) en el repo. Datos pendientes se marcan `null`.

## Convenciones de archivos `ghl/*.json`

- Una entrada = un objeto GHL. Claves en `snake_case`, nombres visibles en español.
- Campo `required_input: true` → el dato lo debe dar el cliente; no se aplica con valores inventados.
- Aplicar es **idempotente**: antes de crear, listar lo existente y comparar por nombre/clave.
  Tras crear, registrar el ID en `ghl/state.json`.

## Git

- Rama de trabajo asignada por la sesión; commits pequeños y descriptivos en español.
- No abrir Pull Request salvo que se pida explícitamente.
