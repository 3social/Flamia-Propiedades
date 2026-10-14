# Plan — Flamia Propiedades · CRM en GoHighLevel

**Objetivo:** que un interesado en una propiedad reciba respuesta inmediata (texto o llamada), quede
calificado, agende una visita y avance por un pipeline claro, con un humano interviniendo solo donde
aporta valor.

**Base de negocio** (skill de propuesta FLAMIA, nicho inmobiliaria): subcuenta *especializada* —
setup $450, retainer $120/mes; pipeline Nuevo lead → Calificado → Visita agendada → Negociación → Cierre;
etiquetado por tipo de propiedad y zona; confirmación automática de visitas.

> Supuestos a confirmar (no estaban en el repo ni en Linear): nombre comercial final, país/moneda,
> teléfono/WhatsApp, zonas de cobertura, horario y asesor responsable. Están modelados como
> `required_input` en `ghl/custom-values.json` para no inventar datos.

## Mapa de fases

| Fase | Entregable | Cómo se hace | Depende de |
|---|---|---|---|
| 0 | Plan, estructura del repo, issues en Linear | Hecho en esta sesión | — |
| 1 | **Subcuenta** en GHL | Manual en UI (el MCP no crea subcuentas) | 0 |
| 2 | **Estructura base**: perfil de negocio, zona horaria, calendario "Visitas", campos personalizados | MCP + UI | 1 |
| 3 | **Custom values** | MCP | 2 |
| 4 | **Etiquetas básicas** | MCP | 2 |
| 5 | **Pipeline** de 5 etapas | UI (la API pública no crea pipelines) + leer IDs por MCP | 2 |
| 6 | **Agente de texto** (Conversation AI) | UI con prompt versionado; base de conocimiento por MCP si aplica | 3, 4, 5 |
| 7 | **Agente de voz** (Voice AI) | MCP (`voice-ai.create-agent`) + número en UI | 3, 4, 5, 6 |
| 8 | Pruebas de extremo a extremo, grafo (/graphify), entrega y capacitación | Mixto | 1–7 |

El orden respeta el pedido (subcuenta → estructura → custom values → etiquetas → pipeline → texto → voz).
Los campos personalizados se adelantan a la fase 2 porque los dos agentes los rellenan.

## Detalle y "hecho cuando"

### Fase 1 — Subcuenta
- Crear en *Agency → Sub-Accounts → Create*: nombre "Flamia Propiedades" (o el comercial del cliente),
  zona horaria, moneda, idioma `es`, dominio de envío verificado.
- Opción recomendada si FLAMIA ya tiene un snapshot de inmobiliaria: crear desde snapshot y luego
  sobrescribir con este repo. Si no, subcuenta limpia.
- **Hecho cuando:** `list_locations` devuelve la nueva subcuenta y su `locationId` está en `ghl/state.json`.

### Fase 2 — Estructura base
- Perfil de negocio completo (nombre, teléfono, dirección, logo, web).
- Calendario "Visitas a propiedades" (duración 45 min, buffer 15, asesor asignado) → su enlace alimenta
  el custom value `link_agendar_visita`.
- Campos personalizados de `ghl/custom-fields.json`.
- **Hecho cuando:** los campos existen y se leen de vuelta con `locations.get-custom-fields`.

### Fase 3 — Custom values
- Aplicar `ghl/custom-values.json`. Los marcados `required_input` se crean solo con dato real del cliente.
- **Hecho cuando:** cada clave existe en GHL y los agentes pueden citarla como `{{custom_values.<clave>}}`.

### Fase 4 — Etiquetas básicas
- Aplicar `ghl/tags.json` (origen, intención, tipo de propiedad, estado, control de IA).
- **Hecho cuando:** `get-location-tags` devuelve todas y ninguna está duplicada.

### Fase 5 — Pipeline
- Crear en UI el pipeline "Ventas · Propiedades" con las 5 etapas de `ghl/pipeline.json`.
- Leer IDs con `get-pipelines` y guardarlos en `ghl/state.json`.
- **Hecho cuando:** `get-pipelines` muestra 5 etapas en el orden definido y una oportunidad de prueba recorre las 5.

### Fase 6 — Agente de texto
- Prompt y reglas en `ghl/agents/texto.md`. Canales: WhatsApp/SMS/chat web según lo conectado.
- Acciones: actualizar campos, aplicar tags, mover etapa, agendar visita, derivar a humano.
- **Hecho cuando:** una conversación de prueba termina con campos llenos, tag `lead-calificado`,
  oportunidad en "Calificado" y, si aplica, visita agendada.

### Fase 7 — Agente de voz
- Prompt en `ghl/agents/voz.md`; creación por `voice-ai.create-agent`, acciones por `voice-ai.create-action`.
- Casos: entrante (consulta por propiedad) y saliente *speed-to-lead* (lead nuevo del formulario).
- **Hecho cuando:** llamada de prueba entrante y saliente califica, agenda y deja la transcripción en el contacto.

### Fase 8 — Verificación y cierre
- Recorrido completo desde formulario web hasta cierre; revisar tags y etapas en cada salto.
- Generar el grafo con /graphify (archivos ↔ objetos GHL ↔ issues).
- Sesión de entrega y capacitación al cliente.

## Riesgos conocidos

| Riesgo | Mitigación |
|---|---|
| El MCP no crea subcuentas ni pipelines | Pasos manuales guiados en `docs/GHL-OPERACION.md`; el repo conserva la definición |
| Escribir por error en la cuenta de la agencia u otro cliente | Regla en `CLAUDE.md`: solo el `locationId` de `state.json` |
| Agentes que prometen precios o financiamiento | Reglas duras en los prompts + derivación a humano |
| Voz y SMS requieren número y registro (A2P/10DLC en EE. UU.) | Iniciar el trámite del número en fase 2, en paralelo |
