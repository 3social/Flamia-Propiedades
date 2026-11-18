// FLR · lead-landing — formulario multi-paso de la landing → contacto en GHL (D26 §3, D27).
// La landing solo captura; FLR · calificacion decide el nivel y GHL crea la oportunidad (FLR · 1 Lead nuevo).
const LOC = '20Yv36Yd31saVEePDNwB';
const F = {
  operacion: 'v9nuA3BYnMMgQmTY1hJ0', presupuestoMin: 'UJCK7exwHkzNHtn1TdSv', presupuestoMax: 'DkYitRLjPWXFvVWerdPp',
  moneda: 'vAlCJWawX7fdEEsNHLJj', plazo: 'oEqdidKzwuhs9YGssBTl', zonas: 'W5wnJnAm5tuhnhFrb53C', idioma: 'rzHfMHa4W0cpEHCIYfd1',
  optin: 'NAinWUz9ttZkq9vw110z', fechaOptin: 'B21G8QqRea8ykzmhZPNQ', origenOptin: 'sCzcCjmtdjI1Fmt3SuqG',
  ref: 'RHMJTGCEAXTIMhqJkX6h', utmSource: 'vWhAGbPkbPIQ0TqNZC8C', utmMedium: '4cgJDUcobqcnS1xU8qzZ', utmCampaign: 'SySJ8ZvfNnqixzs2MpAL',
  proposito: 'p6MGGLJvf89R3Wh5m53P'
};
const RANGOS = { hasta_500k: [null, 500000], '500k_1m': [500000, 1000000], '1m_2m': [1000000, 2000000], mas_2m: [2000000, null] };
const PLAZOS = ['Inmediato', '1 a 3 meses', '3 a 6 meses', 'Mas de 6 meses', 'Solo explorando'];
const OPERACIONES = ['Compra', 'Renta'];
const PROPOSITOS = ['Vivir', 'Inversion', 'Vacacional'];

const b = $input.first().json.body || {};
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

if (OPERACIONES.includes(b.operacion)) set(F.operacion, b.operacion);
const rango = RANGOS[b.rango];
if (rango) { set(F.presupuestoMin, rango[0]); set(F.presupuestoMax, rango[1]); set(F.moneda, 'USD'); }
if (PLAZOS.includes(b.plazo)) set(F.plazo, b.plazo);
if (PROPOSITOS.includes(b.proposito)) set(F.proposito, b.proposito);
set(F.zonas, s(b.zona, 80));
set(F.idioma, s(b.idioma, 2) === 'en' ? 'en' : 'es');
set(F.ref, ref);
set(F.utmSource, s(b.utm_source, 80)); set(F.utmMedium, s(b.utm_medium, 80)); set(F.utmCampaign, s(b.utm_campaign, 80));
set(F.optin, optin ? 'Si' : 'No');
if (optin) { set(F.fechaOptin, new Date().toISOString().slice(0, 10)); set(F.origenOptin, 'landing ' + (ref || 'sin-ref')); }

const tags = ['landing'];
if (optin) tags.push('opt_in_whatsapp');

const contact = { locationId: LOC, firstName: first, lastName: rest.join(' '), source: 'landing ' + (ref || ''), tags, customFields: cf };
if (email) contact.email = email;
if (telefono) contact.phone = telefono;

return [{ json: { ok: true, contact } }];
