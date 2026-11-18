# Panel del dueño — Next.js 15 (Fase 2)

No se construye antes de la demo (línea de corte nº 2: en la demo el dueño ve el resumen diario).

Alcance: vista por agente (leads, respuesta, citas, conversiones), por fuente/propiedad/anunciante (QR/UTM), embudo por pipeline,
inventario (activas, cambios de precio, más interés), filtros por fecha y export CSV. Auth con Supabase Auth, roles `owner` y
`agent` (el agente solo ve lo suyo). Datos desde GHL (API) y Supabase, cacheados; nunca de otro `client_id`. Despliegue en Vercel.
