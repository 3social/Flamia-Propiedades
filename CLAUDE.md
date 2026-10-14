@AGENTS.md

# CLAUDE.md — instrucciones específicas para Claude Code

## Herramientas y cómo usarlas

- **GHL (MCP `MCP-Lead-GHL`)**: flujo `search_operations` → `describe_operation` → `execute_operation`.
  - Toda escritura exige `idempotencyKey` (usa `flamia-prop-<objeto>-<clave>`) y `locationId`.
  - Haz `dryRun: true` antes de la primera escritura de cada tipo de objeto.
  - **Solo** operar sobre la subcuenta de Flamia Propiedades (`locationId` en `ghl/state.json`).
    **Nunca** escribir en `Mzmr9yxQ2iMapPYViK1B` (Flamiagroup, cuenta de la agencia) ni en las
    subcuentas de otros clientes que lista `list_locations`.
  - Si `state.json` no tiene `locationId`, detenerse y pedirlo: la fase 1 es manual (ver `docs/GHL-OPERACION.md`).
- **Linear (equipo `FLA`)**: el seguimiento vive en el proyecto "Flamia Propiedades · CRM GHL".
  Un issue por fase; mover estado al empezar/terminar y comentar los IDs creados en GHL.
- **/graphify**: ejecutar cuando las fases 2–7 estén aplicadas, para dejar el grafo de la configuración
  (objetos GHL ↔ archivos ↔ issues). No antes: con el repo casi vacío no aporta.

## Flujo por fase

1. Leer la fase en `docs/PLAN.md` y su "hecho cuando".
2. Editar el JSON/MD correspondiente en `ghl/` (el repo manda).
3. Aplicar a GHL (MCP o guía manual), guardar IDs en `ghl/state.json`.
4. Verificar leyendo de vuelta desde GHL (no asumir que la escritura funcionó).
5. Commit + push a la rama de la sesión; actualizar el issue de Linear.

## Estilo

- Cambios mínimos y legibles; sin abstracciones que el repo todavía no necesita (hoy son JSON + Markdown).
- Documentar el *por qué* de una decisión en `docs/`, no comentarios decorativos.
