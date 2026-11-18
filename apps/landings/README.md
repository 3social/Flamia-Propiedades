# Landings por proyecto o propiedad (D27)

Una carpeta por landing (`pv-0005/`, …). HTML estático, sin build. La marca del cliente se aplica cambiando solo las
variables de `:root` (colores, tipografías) y el logotipo; la estructura y la mecánica son las mismas para todos.

| Landing | Propiedad | URL de prueba | Estado |
|---|---|---|---|
| `pv-0005` | Villa ficticia en Conchas Chinas, USD 3.4M | https://ardenza-pv-0005.vercel.app | Demo (noindex, "propiedad ficticia") |

## Mecánica
- Formulario multi-paso: rango de presupuesto → plazo → propósito → nombre, WhatsApp, correo y opt-in.
- Envía a `POST /webhook/flr-lead-landing` (n8n `FLR · lead-landing`) con `ref`, zona, idioma y UTM de la URL. Campo trampa `website`.
- Gracias: calendario *Visitas privadas* incrustado (sin datos personales en la URL).
- ES/EN con `?lang=en` o el idioma del navegador.
- Después: GHL crea la oportunidad (FLR · 1), `FLR · calificacion` decide el nivel en ≤ 2 min y el agente de texto continúa.

## Desplegar
Vercel, equipo `michael-proyectos`, proyecto `ardenza-pv-0005` (`prj_2XvrUVIkJ1gCtDTr5YSOIpbtN8Ty`). El alias
`*-michael-proyectos.vercel.app` pide login; el público es `ardenza-pv-0005.vercel.app`.

## Antes de usar con un cliente real
- Fotos reales autorizadas por el cliente (hoy son de stock de Unsplash, "imágenes ilustrativas").
- Nombre y foto del asesor, WhatsApp del negocio, aviso de privacidad, dominio propio, pixel Meta/GA4.
- Quitar `noindex` y la etiqueta de demo.
