// FLR · lead-landing — formulario multi-paso de la landing → contacto en GHL (D26 §3, D27, D28).
// La landing solo captura; FLR · calificacion decide el nivel y GHL crea la oportunidad (FLR · 1 Lead nuevo).
const LOC = '20Yv36Yd31saVEePDNwB';
const F = {
  operacion: 'v9nuA3BYnMMgQmTY1hJ0', presupuestoMin: 'UJCK7exwHkzNHtn1TdSv', presupuestoMax: 'DkYitRLjPWXFvVWerdPp',
  moneda: 'vAlCJWawX7fdEEsNHLJj', plazo: 'oEqdidKzwuhs9YGssBTl', zonas: 'W5wnJnAm5tuhnhFrb53C', idioma: 'rzHfMHa4W0cpEHCIYfd1',
  optin: 'NAinWUz9ttZkq9vw110z', fechaOptin: 'B21G8QqRea8ykzmhZPNQ', origenOptin: 'sCzcCjmtdjI1Fmt3SuqG',
  ref: 'RHMJTGCEAXTIMhqJkX6h', utmSource: 'vWhAGbPkbPIQ0TqNZC8C', utmMedium: '4cgJDUcobqcnS1xU8qzZ', utmCampaign: 'SySJ8ZvfNnqixzs2MpAL',
  utmContent: 'rmQF0Avl6qr30tYXfjal', utmTerm: '5qDaPA3XGj6woYvSQslW', proposito: 'p6MGGLJvf89R3Wh5m53P',
  canal: 'ZKid0PLgouENEPuJw9ws', primerCanal: 'UlA83oq28Nwf9XEpzcA9', fechaPrimer: 'LeTlBesjW1K4CXxauMdc',
  campanaId: 'seOWjQYrlhEYmTJtQnte', grupoId: 'Z8WSwT5fAhYHdndKDRxk', anuncioId: 'mGdVGdIIeCrduuswCNTT',
  gclid: 'XHWBuCwkw8z74VVlurtB', gbraid: '9CV8eYRK1tOJuHEqvbzd', wbraid: 'PeLxfZnDl2vk8vCXmauq',
  fbclid: '4h4v1mSTdmgHadY150qk', fbc: 'OmYCdY7YeDQnCxPmRbkw', fbp: 'm0r3g8PytZUV0vo1smVj', ttclid: 'vypCKC4Fru1Xm7UyfcFh',
  landingUrl: 'UaA87Xb3gYpyR0J5lBVB', referrer: '0Qyk8jZ0Xny1YimBv4df'
};
const RANGOS = { hasta_500k: [null, 500000], '500k_1m': [500000, 1000000], '1m_2m': [1000000, 2000000], mas_2m: [2000000, null] };
const PLAZOS = ['Inmediato', '1 a 3 meses', '3 a 6 meses', 'Mas de 6 meses', 'Solo explorando'];
const OPERACIONES = ['Compra', 'Renta'];
const PROPOSITOS = ['Vivir', 'Inversion', 'Vacacional'];

// --- regla de canal (copia de canal.js) ---
function canalDe(a) {
  const src = String(a.utm_source || '').toLowerCase();
  const ref = String(a.referrer || '').toLowerCase();
  if (a.gclid || a.gbraid || a.wbraid || ['google', 'adwords', 'youtube'].includes(src)) return 'Google Ads';
  if (a.fbclid || a.fbc || ['facebook', 'fb', 'instagram', 'ig', 'meta'].includes(src)) return 'Meta Ads';
  if (a.ttclid || src === 'tiktok') return 'TikTok Ads';
  if (src) return 'Otro';
  if (/(^|\/\/|\.)(google|bing|duckduckgo|yahoo)\./.test(ref)) return 'Organico';
  if (ref) return 'Referido';
  return 'Directo';
}
const TAG_CANAL = { 'Google Ads': 'fuente_google', 'Meta Ads': 'fuente_meta', 'TikTok Ads': 'fuente_tiktok',
  Organico: 'fuente_organico', Directo: 'fuente_directo' };
// ---

const b = $('Webhook lead-landing').first().json.body || {};
const existing = ($('Find Duplicate').first().json || {}).contact || null;
const s = (v, n) => String(v ?? '').trim().slice(0, n || 120);
const fail = (msg) => [{ json: { ok: false, status: 400, body: { ok: false, error: msg } } }];

// Honeypot: un bot llena el campo oculto; se responde ok sin escribir nada.
if (s(b.website)) return [{ json: { ok: false, status: 200, body: { ok: true } } }];

const nombre = s(b.nombre, 80);
const email = s(b.email, 120).toLowerCase();
const telefono = s(b.telefono, 20).replace(/[^\d+]/g, '');
if (!nombre) return fail('nombre');
if (!email && telefono.length < 8) return fail('contacto');
if (email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return fail('email');

const [first, ...rest] = nombre.split(/\s+/);
const ref = s(b.ref, 20).toUpperCase();
const optin = b.opt_in === true || b.opt_in === 'true' || b.opt_in === 'on';
const cf = [];
const set = (id, v) => { if (v !== null && v !== undefined && v !== '') cf.push({ id, field_value: v }); };
// put: escribe aunque venga vacío, para que los UTM/IDs de un toque anterior no se mezclen con el actual.
const put = (id, v) => cf.push({ id, field_value: v ?? '' });

if (OPERACIONES.includes(b.operacion)) set(F.operacion, b.operacion);
const rango = RANGOS[b.rango];
if (rango) { set(F.presupuestoMin, rango[0]); set(F.presupuestoMax, rango[1]); set(F.moneda, 'USD'); }
if (PLAZOS.includes(b.plazo)) set(F.plazo, b.plazo);
if (PROPOSITOS.includes(b.proposito)) set(F.proposito, b.proposito);
set(F.zonas, s(b.zona, 80));
set(F.idioma, s(b.idioma, 2) === 'en' ? 'en' : 'es');
set(F.ref, ref);
set(F.optin, optin ? 'Si' : 'No');
if (optin) { set(F.fechaOptin, new Date().toISOString().slice(0, 10)); set(F.origenOptin, 'landing ' + (ref || 'sin-ref')); }

// Atribución del último toque (D28). Se escriben solo los valores presentes.
const a = {}; ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'gclid', 'gbraid', 'wbraid',
  'fbclid', 'fbc', 'fbp', 'ttclid', 'referrer'].forEach(k => { a[k] = s(b[k], 300); });
const canal = canalDe(a);
set(F.canal, canal);
put(F.utmSource, a.utm_source); put(F.utmMedium, a.utm_medium); put(F.utmCampaign, a.utm_campaign);
put(F.utmContent, a.utm_content); put(F.utmTerm, a.utm_term);
put(F.campanaId, s(b.campaign_id || b.utm_id, 60)); put(F.grupoId, s(b.adset_id || b.adgroup_id, 60)); put(F.anuncioId, s(b.ad_id || b.creative_id, 60));
// Click IDs: se conservan los anteriores (cada plataforma necesita el suyo para devolver conversiones).
set(F.gclid, a.gclid); set(F.gbraid, a.gbraid); set(F.wbraid, a.wbraid);
set(F.fbclid, a.fbclid); set(F.fbc, a.fbc); set(F.fbp, a.fbp); set(F.ttclid, a.ttclid);
set(F.landingUrl, s(b.landing_url, 500)); set(F.referrer, a.referrer);

// Primer toque: solo si el contacto no lo tiene ya.
const prevCf = Object.fromEntries(((existing && existing.customFields) || []).map(f => [f.id, f.value]));
if (!prevCf[F.primerCanal]) {
  const ft = (b.first_touch && typeof b.first_touch === 'object') ? b.first_touch : {};
  const ftCanal = canalDe({ utm_source: s(ft.utm_source), gclid: s(ft.gclid), fbclid: s(ft.fbclid), ttclid: s(ft.ttclid), referrer: s(ft.referrer, 300) });
  set(F.primerCanal, ft.ts ? ftCanal : canal);
  set(F.fechaPrimer, new Date(Number(ft.ts) || Date.now()).toISOString().slice(0, 10));
}

const tags = ['landing'];
if (TAG_CANAL[canal]) tags.push(TAG_CANAL[canal]);
if (optin) tags.push('opt_in_whatsapp');

// Los tags NO van en el upsert: GHL los reemplazaría (borraría no_contactar, handoff_humano…). Se agregan en 'Add Tags'.
const contact = { locationId: LOC, firstName: first, lastName: rest.join(' '), source: 'landing ' + (ref || ''), customFields: cf };
if (email) contact.email = email;
if (telefono) contact.phone = telefono;

return [{ json: { ok: true, contact, tags } }];
