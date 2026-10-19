# Infraestructura en EasyPanel — Supabase mínimo y MCP por subcuenta

Estado observado el 2026-10-19 (solo lectura).

## VPS

4 CPU · 7.9 GB RAM (1.7 GB usados, 21 %) · 144 GB de disco (101 GB libres).
Ya corren: n8n, Evolution API (+ manager, Postgres y Redis), el proyecto `creator-all` (2 apps) y un proyecto **`supabase` vacío**
creado el 17-oct. Cabe un Supabase mínimo; **no** cabe holgado el stack completo de la plantilla (la analítica/Logflare sola pesa mucho).

## Supabase: solo lo que el proyecto necesita (D19)

Los agentes viven en GHL y llaman a las herramientas por webhook, así que no hace falta casi nada de Supabase.

| Pieza | ¿Ahora? | Motivo |
|---|---|---|
| Postgres (imagen Supabase, con `pgvector`) | **Sí** | Inventario, perfiles, alertas, historial, RLS |
| PostgREST (`rest`) | **Sí** | API REST para n8n y, después, el panel |
| Kong (gateway) | Sí, si se expone la API fuera | Enruta con claves anon/service; se puede omitir si solo n8n accede por red interna |
| Studio | Opcional | Ver datos; liviano de activar y apagar |
| Edge Functions | **No** | Las 5 herramientas serán webhooks de n8n (patrón de `Wasi - Lectura de Propiedades`) |
| Auth | Fase 2 | Roles `owner`/`agent` del panel |
| Realtime, Storage, imgproxy, analytics, vector | No | Sin uso en la demo |

Presupuesto estimado: ~1–1.5 GB de RAM. Los secretos (JWT, claves, contraseña de la base) se generan al desplegar y viven solo en EasyPanel.

### Red
Para que n8n llegue a la base sin abrirla a internet, lo ideal es que base y n8n compartan red de EasyPanel. Hoy n8n está en el proyecto
`personaldev` y el Supabase vacío en `supabase`. Opciones: (1) montar la base en `personaldev` junto a n8n, o (2) en `supabase` con puerto
expuesto y restringido por contraseña fuerte/IP. Recomendación: opción 1 para la demo.

### Herramientas como webhooks de n8n
`FLR · tool-search-properties`, `tool-get-property`, `tool-upsert-buyer`, `tool-book-viewing`, `tool-send-brochure`: cada una valida un
secreto de cabecera ligado a `client_id` (D10) y consulta Postgres. Objetivo de latencia: p95 < 1.5 s.

## MCP propio por subcuenta (D18)

Precedente: `MCP - GHL CRS_ana` y `MCP - GHL AS Propiedades` en n8n (nodo MCP Server Trigger + un nodo HTTP por endpoint, 53 en el de CRS_ana).

Propuesta para Ardenza: **un MCP de n8n atado a una sola ubicación**, con un token privado (PIT) de esa subcuenta con todos los ámbitos y pocas
herramientas genéricas en vez de decenas de nodos:

| Herramienta | Qué hace | Guardarraíles |
|---|---|---|
| `ghl_get` | GET a cualquier ruta permitida | La ubicación siempre es la de Ardenza |
| `ghl_write` | POST/PUT/PATCH | Idem; lista negra: facturación, SaaS, borrar la ubicación |
| `ghl_delete` | DELETE | Desactivada por defecto; se activa por tarea |

Ventajas: usa **todos** los ámbitos del token (incluida la edición de la ubicación que el conector actual filtra) y elimina el riesgo de que
una sesión toque las otras 9 subcuentas de clientes. Límites: un token de subcuenta no crea subcuentas (eso exige token de agencia) y la API
pública no ofrece creación de pipelines, bots de Conversation AI, workflows ni plantillas de WhatsApp **[verificar contra la documentación]**:
esos pasos siguen siendo manuales aunque el MCP sea propio.

El token se carga como credencial `httpBearerAuth` en n8n (`GHL PIT - Ardenza`) por Michael; no se pega en chats ni en el repo.

## Estado del MCP de Ardenza (2026-10-19)

Workflow `FLR · MCP GHL Ardenza` (n8n `07NdqtZhhLzfFlM4`), **creado e inactivo**. Tres herramientas genéricas sobre la API v2 de GHL con el PIT
`GHL PIT - Ardenza`: `ghl_get`, `ghl_write` (POST/PUT/PATCH) y `ghl_delete`. Aceptan cabecera `Version` y query/body libres, así que cubren
cualquier endpoint que el token permita (incluida la edición de la ubicación). Respuestas 4xx se devuelven al modelo (`neverError`).

Para activarlo (pasos manuales en la UI de n8n, no se pueden hacer por API):
1. En `ghl_get`, `ghl_write` y `ghl_delete`: elegir la credencial **GHL PIT - Ardenza** (Bearer).
2. En el nodo `MCP Server Ardenza`: n8n le asignó automáticamente la credencial existente "Vapi" (cabecera). **Sustituirla** por una credencial
   nueva de cabecera dedicada a este MCP; no mezclar secretos entre servicios.
3. Activar el workflow y copiar la *Production URL* del nodo; registrarla como servidor MCP con la cabecera de acceso.

Sin autenticación en la entrada la URL sería pública y cualquiera podría escribir en la subcuenta: no activar antes del paso 2.
