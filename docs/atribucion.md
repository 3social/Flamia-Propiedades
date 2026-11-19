# Atribución de leads de Google Ads, Meta Ads y TikTok Ads (D28)

Objetivo: que cada lead llegue a GHL con **de dónde vino** (canal, campaña, grupo, anuncio, click ID) y que esa
información sirva después para devolver conversiones a cada plataforma (Fase 2: CAPI / conversiones offline).

## 1. Dos caminos de entrada

| Camino | Google Ads | Meta Ads | TikTok Ads |
|---|---|---|---|
| **A. Clic → landing** (`apps/landings/*`) | `gclid` / `gbraid` / `wbraid` + UTM | `fbclid` (+ cookies `_fbp`/`_fbc` si hay pixel) + UTM | `ttclid` (+ cookie `_ttp` si hay pixel) + UTM |
| **B. Formulario nativo** | Lead Form Asset → integración nativa de GHL (Google Ads conectado) → `FLR · 6` | Lead Ads → integración nativa de GHL (página de Facebook conectada) | Lead Generation → integración nativa de GHL (TikTok conectado) |

Click-to-WhatsApp / Messenger / Instagram DM: GHL registra el anuncio de origen en la conversación; se marca con
el tag de fuente igual que B.

## 2. Qué se guarda (campos del contacto)

| Campo | Fuente | Para qué |
|---|---|---|
| `Canal Origen` (último toque) | regla de §3 | Reporte por canal, ruteo |
| `Primer Canal` + `Fecha Primer Contacto` | primer toque (no se sobrescribe) | Atribución real en ciclos largos (lujo: meses) |
| `UTM Source / Medium / Campaign / Content / Term` | URL | Campaña / anuncio legibles |
| `Campana ID`, `Grupo Anuncios ID`, `Anuncio ID` | `utm_id`/`campaign_id`, `adset_id`/`adgroup_id`, `ad_id`/`creative_id` | Cruzar con el gasto de cada plataforma |
| `Google Click ID` (gclid), `GBRAID`, `WBRAID` | URL (Google) | Conversiones offline de Google Ads |
| `FBCLID`, `FBC`, `FBP` | URL / cookies (Meta) | Conversions API de Meta (match quality) |
| `TTCLID` | URL (TikTok) | Events API de TikTok |
| `Landing URL`, `Referrer` | navegador | Diagnóstico y orgánico vs. directo |

Además tags `fuente_google`, `fuente_meta`, `fuente_tiktok`, `fuente_organico`, `fuente_directo` (para filtros y workflows).

## 3. Regla de canal (en el orden en que se evalúa; GHL `FLR · 9b`)

**Manda el `utm_source` de la visita actual.** Los click IDs quedan guardados en el contacto desde visitas anteriores, así
que solo deciden cuando la visita no trae UTM (si no, un `gclid` viejo marcaría Google en una visita de Meta).

1. `utm_source` ∈ {google, youtube, adwords} → **Google Ads**
2. `utm_source` ∈ {meta, facebook, fb, instagram, ig} → **Meta Ads**
3. `utm_source` = tiktok → **TikTok Ads**
4. Otro `utm_source` → **Otro**
5. Sin UTM: `gclid`/`gbraid`/`wbraid` → Google Ads · `fbclid` → Meta Ads · `ttclid` → TikTok Ads
6. Nada → **Directo**

Por eso **toda plantilla de URL debe llevar `utm_source`** (§4). Orgánico / referido lo registra la atribución nativa de
GHL (`attributionSource.sessionSource`), no este campo.

**Primer toque:** `FLR · 10` copia `Canal Origen` a `Primer Canal` solo si está vacío.

## 4. Configuración que hace el cliente en cada plataforma (una vez)

- **URL final con parámetros** (plantilla de seguimiento):
  - Google: `{lpurl}?utm_source=google&utm_medium=cpc&utm_campaign={campaignid}&utm_content={creative}&utm_term={keyword}&campaign_id={campaignid}&adgroup_id={adgroupid}&ad_id={creative}` (auto-tagging activo para `gclid`).
  - Meta: `utm_source=meta&utm_medium=paid_social&utm_campaign={{campaign.name}}&utm_content={{ad.name}}&campaign_id={{campaign.id}}&adgroup_id={{adset.id}}&ad_id={{ad.id}}`.
  - TikTok: `utm_source=tiktok&utm_medium=paid_social&utm_campaign=__CAMPAIGN_NAME__&utm_content=__CID_NAME__&campaign_id=__CAMPAIGN_ID__&adgroup_id=__AID__&ad_id=__CID__`.
- **Google Lead Form, Meta Lead Ads y TikTok Lead Gen:** conectar la cuenta de Google Ads, la página y TikTok en GHL
  (*Settings → Integrations* / Ad Manager; OAuth del cliente). Luego en `FLR · 6` elegir la cuenta de Google Ads en el
  disparador *Google lead form submitted*, publicar y activar reentrada (D30). Ya no hay webhook ni clave.
- **Pixels** (Meta, TikTok, GA4 / Google tag) en la landing: Fase 2, con el ID de cada cliente y banner de consentimiento.

## 5. Fase 2 (no construido): devolver conversiones
Eventos `Lead` (formulario), `Schedule` (visita agendada) y `Purchase`/valor (cerrado) a Meta CAPI, Google Ads
(conversiones offline por `gclid`) y TikTok Events API desde n8n, usando los campos de §2. Requiere tokens de cada cuenta publicitaria.

## 6. Estado (2026-11-18) y pruebas

| Pieza | ID | Prueba |
|---|---|---|
| Landing con captura (último + primer toque, `fbc` construido desde `fbclid`) | `apps/landings/pv-0005`, desplegada | ✅ Google → regreso directo conserva Google → Meta cambia el último toque, primer toque sigue en Google |
| n8n `FLR · lead-landing` | `eC8OJNpTuYx9oA1W` | ✅ canal, UTM, IDs, click IDs, primer toque sin sobrescribir; tags agregados sin borrar los existentes |
| n8n `FLR · lead-google-form` | `9GvtIyxNiai8Q9Il` | ✅ payload de prueba de Google con clave; ❌ clave inválida → 401 |
| GHL `FLR · 7 Lead Meta (formulario nativo)` | `03a99edf-…` | publicado; sin probar con un lead real (falta conectar la página) |
| GHL `FLR · 8 Lead TikTok (formulario nativo)` | `9631a7a8-…` | publicado; sin probar con un lead real (falta conectar TikTok) |
| `FLR · calificacion` completa canal desde el tag | `PtU5gnp8hqaAJeb5` | ✅ contacto con solo `fuente_meta` → Canal y Primer Canal = Meta Ads |

Lecciones:
- **El upsert de GHL reemplaza los tags**: nunca mandar `tags` en `/contacts/upsert` (borraría `no_contactar`); se agregan con `POST /contacts/{id}/tags`.
- UTM e IDs de campaña se reemplazan completos en cada toque (no se mezclan); los click IDs se conservan por plataforma.
- `GCLID` no se puede crear como campo: choca con el estándar `contact.gclid`.

### Migración a GHL (D29, 2026-11-18)
La landing ahora es un funnel nativo de GHL; los campos ocultos del formulario se llenan desde la URL con estas llaves:
`ref`, `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, `campaign_id`, `adgroup_id`, `ad_id`, `gclid`,
`gbraid`, `wbraid`, `fbclid`, `ttclid` (por eso Meta usa `adgroup_id={{adset.id}}`). Un parámetro vacío no borra el valor
anterior. GHL además guarda su atribución nativa (`attributionSource` / `lastAttributionSource`, con `fbp`).

| Pieza | ID | Prueba |
|---|---|---|
| `FLR · 9b Landing: canal de origen` | `e40c59f2-…` | ✅ visita de Meta con gclid viejo → Meta Ads |
| `FLR · 10 Primer canal` | `47e61d39-…` | ✅ Primer Canal no se sobrescribe |
| `FLR · 6 Lead Google (formulario nativo)` | `449bc82e-…` | borrador: falta el disparador (requiere Google Ads conectado) |
| n8n `FLR · lead-landing` y `FLR · lead-google-form` | `eC8OJNpTuYx9oA1W`, `9GvtIyxNiai8Q9Il` | archivados (D29/D30) |
