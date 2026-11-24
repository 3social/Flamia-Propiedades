# Landings por proyecto o propiedad (D27)

Una carpeta por landing (`pv-0005/`, …). HTML estático, sin build. La marca del cliente se aplica cambiando solo las
variables de `:root` (colores, tipografías) y el logotipo; la estructura y la mecánica son las mismas para todos.

| Landing | Propiedad | URL de prueba | Estado |
|---|---|---|---|
| `pv-0005` (GHL) | Villa ficticia en Conchas Chinas, USD 3.4M | https://app.flamiagroup.com/preview/7KjndMMOo6f9znLp9KqA | **Oficial (D29)** |
| `pv-0005/` (esta carpeta) | igual | https://ardenza-pv-0005.vercel.app | Reemplazada; queda como referencia de diseño |

## En GHL (D29, lo que se entrega en el snapshot)
- Funnel `FLR · Propiedad PV-0005 (luxury)` (`5dT5h0j6AVM49BI2DvBl`), página `7KjndMMOo6f9znLp9KqA`, hecha con elementos
  nativos (builder AI de GHL con un brief) y textos/fotos en **custom values `landing_*`**: para otra propiedad se cambian
  los custom values, no la página.
- Formulario nativo `FLR · Landing propiedad (visita privada)` (`alfV7H8SLGq44ocnNnTT`): rango, plazo, propósito, nombre,
  WhatsApp, correo, opt-in + campos ocultos desde la URL (ver `docs/atribucion.md`).
- Workflows: `FLR · 9a` rango → presupuesto, `9b` canal, `9c` tags/opt-in/operación/zona, `10` primer canal; luego `0` y `0b`.
- **Página de gracias** (paso *Gracias*, página `HoVqbpXxiVRsvHun4oji`): titular, texto con custom values y el **calendario nativo**
  *Visitas privadas* (no código personalizado). El formulario redirige a `{{custom_values.landing_url_gracias}}` (GHL resuelve el
  custom value en la URL de redirección; en cada cliente se cambia ese valor, no el formulario).
- Probado 2026-11-24: landing → gracias (conserva UTM) → cita → *FLR · 3* (`visita_agendada`, etapa *Visita agendada*) → *FLR · 0*
  sube el nivel a **Caliente** + `lead_caliente`.
- Aprendido: el builder AI de GHL a veces mete *Custom Code* (calendario falso, adornos) o fija textos de marca; revisar cada
  elemento y pedirle variables literales. `{{contact.first_name}}` no se resuelve en la vista previa: el titular no lo usa.
- Pendiente: país por defecto del teléfono = México (Perfil de la empresa de la subcuenta, lo hace Michael); dominio (sin dominio
  no se puede *Publicar*, la vista previa sirve lo guardado); título SEO de la página fijo con "Ardenza"; comprobar con dominio
  real que el calendario prellena los datos del lead; popup de salida (opcional).
- Ojo: el formulario actualiza el contacto que el navegador ya tiene identificado (cookie de GHL). En pruebas, usar ventana
  privada para no pisar otro contacto.

## Vercel (reemplazada)

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
