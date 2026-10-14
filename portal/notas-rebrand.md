# Portal inmobiliaria.flamiagroup.com — diagnóstico y rebranding

Portal existente (Hostinger; PHP/Laravel; tema Flex Home sobre Botble Real Estate **[POR VALIDAR]**).
Observado: proyectos, propiedades, agentes con cuenta, filtros, lista de deseos ("me importa"), ES/EN, multimoneda, noticias.
Datos de ejemplo de Colombia.

La capa de marca está en [`tema/flamia-custom.css`](tema/flamia-custom.css). Se pega en *Apariencia → CSS personalizado* y
requiere en *Opciones del tema*: Primary font DM Sans · Primary color `#7C3AED` · Hover `#6D28D9`.

## Fase 1 (hasta el 19-oct) — solo lo visible en la demo
- [ ] Acceso al panel admin y a Hostinger; ¿hay API/webhooks o hay que leer la BD? **[POR VALIDAR]**
- [ ] Limpiar restos de plantilla: enlaces sociales ajenos, moneda VND, noticias de 2024, textos en inglés mezclados.
- [ ] Quitar correos/teléfonos de prueba de agentes demo.
- [ ] Cargar las propiedades demo de Vallarta (las mismas del seed de Supabase).
- [ ] Webhook de contacto y de "me importa" → `FLR · lead-portal-a-ghl`.
- [ ] Enlaces con `ref` + UTM por propiedad (alimenta `Ref Propiedad Origen`).
- [ ] Nombre del producto como variable (D4), sin hardcode.

## Fase 2
- [ ] Sync portal → Supabase (`FLR · sync-portal-properties`).
- [ ] QR por propiedad/anunciante; landings por propiedad parametrizadas (`apps/landings`).
- [ ] Seguridad: actualizar versión, SSL, respaldos automáticos, política de privacidad y cookies.
- [ ] Decidir instancia por cliente vs. compartido (D1) y verificar licencia multi-cliente (D6).
