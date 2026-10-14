@AGENTS.md

# CLAUDE.md — instrucciones específicas para Claude Code

Léelo junto con `docs/PLAN.md` (qué toca hoy) y `docs/decisiones.md` (qué está decidido).

## Stack y comandos

- Supabase (Postgres + pgvector + Edge Functions + RLS) · n8n (Easypanel) · GoHighLevel · Next.js 15 en Vercel (Fase 2).
- Aún no hay build ni tests automatizados. Cuando existan se documentan aquí:
  - `tests/rls`: aislamiento por `client_id` · `tests/sync`: idempotencia · `tests/agentes`: preguntas trampa.

## Herramientas MCP y límites

| Sistema | Úsalo para | Límites |
|---|---|---|
| **GHL** `MCP-Lead-GHL` | custom values, campos, tags, oportunidades, Voice AI | Flujo `search_operations → describe_operation → execute_operation`. Toda escritura con `idempotencyKey` (`flr-<objeto>-<clave>`) y `locationId` explícito; `dryRun` la primera vez por tipo. **No crea subcuentas, pipelines ni Conversation AI** (ver `docs/GHL-OPERACION.md`). Solo opera sobre `demoLocationId` de `ghl/state.json`; **nunca** sobre `Mzmr9yxQ2iMapPYViK1B` (agencia Flamiagroup) ni subcuentas de otros clientes |
| **Supabase** | migraciones, SQL, funciones, logs | Solo el proyecto `flamia-luxury` (`supabaseProjectRef` en `state.json`). **No tocar** `property-matcher-mach` ni otros proyectos de la organización. Cambios de esquema siempre vía `apply_migration` y reflejados en `supabase/migrations/` |
| **n8n** | crear/probar workflows | Prefijo `FLR · `. **No modificar** flujos existentes: sirven a clientes en producción (AS Propiedades, Top Mover, etc.). Reutilizar = leer y copiar el patrón |
| **Linear** (equipo `FLA`) | seguimiento | Proyecto "FLAMIA Luxury Real Estate". Mover estado al empezar/terminar y comentar IDs creados |
| **/graphify** | grafo de la configuración | Ejecutar al cerrar la Fase 1, no antes |

## Flujo por tarea

1. Leer el frente en `docs/PLAN.md` y su "hecho cuando"; revisar `docs/decisiones.md`.
2. Escribir primero en el repo (SQL, JSON, prompt, workflow exportado) y luego aplicar al sistema.
3. **Verificar leyendo de vuelta** del sistema real (no asumir que la escritura funcionó); correr la prueba de `tests/` que corresponda.
4. Registrar IDs en `ghl/state.json`, commit + push, actualizar Linear.

## Antes de tocar datos de personas

Compradores y leads son personas reales aunque el entorno sea demo: usar únicamente datos ficticios, RLS activa,
sin volcar tablas con PII a la conversación, y respetar `opted_out` / `no_contactar` siempre.

## Estilo

Cambios mínimos y legibles. Documentar el *por qué* en `docs/decisiones.md`, no con comentarios decorativos.
Si la spec y la realidad chocan, anotarlo en `docs/analisis-especificacion.md` en lugar de resolverlo en silencio.
