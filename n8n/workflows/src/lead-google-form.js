// FLR · lead-google-form — webhook del Lead Form Asset de Google Ads → contacto en GHL (D28).
// La clave (google_key) vive fuera del repo (.secrets/); aquí solo su SHA-256.
const KEY_SHA256 = 'c922111ae856d384ec3a8644b18a89e23c1f2ac213ca1a1a0b49e7109fc47a93';
const LOC = '20Yv36Yd31saVEePDNwB';
const F = {
  zonas: 'W5wnJnAm5tuhnhFrb53C', preferencias: 'iTYEfN6SyUURSy90TCwk', idioma: 'rzHfMHa4W0cpEHCIYfd1',
  canal: 'ZKid0PLgouENEPuJw9ws', primerCanal: 'UlA83oq28Nwf9XEpzcA9', fechaPrimer: 'LeTlBesjW1K4CXxauMdc',
  campanaId: 'seOWjQYrlhEYmTJtQnte', grupoId: 'Z8WSwT5fAhYHdndKDRxk', anuncioId: 'mGdVGdIIeCrduuswCNTT',
  gclid: 'XHWBuCwkw8z74VVlurtB', utmSource: 'vWhAGbPkbPIQ0TqNZC8C', utmMedium: '4cgJDUcobqcnS1xU8qzZ'
};

const b = $('Webhook google-form').first().json.body || {};
const keyHash = $('Hash Key').first().json.keyHash || '';
const existing = ($('Find Duplicate').first().json || {}).contact || null;
const s = (v, n) => String(v ?? '').trim().slice(0, n || 200);

if (!b.google_key || keyHash !== KEY_SHA256) return [{ json: { ok: false, status: 401, body: { ok: false, error: 'unauthorized' } } }];

// user_column_data: [{ column_id: 'FULL_NAME' | 'EMAIL' | 'PHONE_NUMBER' | ..., column_name, string_value }]
const cols = Array.isArray(b.user_column_data) ? b.user_column_data : [];
const val = id => s((cols.find(c => c.column_id === id) || {}).string_value);
const full = val('FULL_NAME') || [val('FIRST_NAME'), val('LAST_NAME')].filter(Boolean).join(' ');
const email = val('EMAIL').toLowerCase();
const phone = val('PHONE_NUMBER').replace(/[^\d+]/g, '');
const otras = cols.filter(c => !['FULL_NAME', 'FIRST_NAME', 'LAST_NAME', 'EMAIL', 'PHONE_NUMBER', 'WORK_EMAIL', 'WORK_PHONE'].includes(c.column_id))
  .map(c => s(c.column_name || c.column_id, 80) + ': ' + s(c.string_value, 200)).join(' | ');
if (!email && phone.length < 8) return [{ json: { ok: false, status: 200, body: {} } }];

const [first, ...rest] = (full || 'Lead Google').split(/\s+/);
const cf = [];
const set = (id, v) => { if (v !== null && v !== undefined && v !== '') cf.push({ id, field_value: v }); };
set(F.canal, 'Google Ads'); set(F.utmSource, 'google'); set(F.utmMedium, 'lead_form');
set(F.gclid, s(b.gcl_id, 300)); set(F.campanaId, s(b.campaign_id, 60)); set(F.grupoId, s(b.adgroup_id, 60)); set(F.anuncioId, s(b.creative_id, 60));
set(F.zonas, val('CITY')); set(F.preferencias, otras ? 'Formulario Google: ' + otras : '');
const prevCf = Object.fromEntries(((existing && existing.customFields) || []).map(f => [f.id, f.value]));
if (!prevCf[F.primerCanal]) { set(F.primerCanal, 'Google Ads'); set(F.fechaPrimer, new Date().toISOString().slice(0, 10)); }

const tags = ['formulario_nativo', 'fuente_google'];
if (b.is_test) tags.push('demo');
// Los tags NO van en el upsert (GHL los reemplazaría); se agregan en 'Add Tags'.
const contact = { locationId: LOC, firstName: first, lastName: rest.join(' '), source: 'google lead form ' + s(b.form_id, 40), customFields: cf };
if (email) contact.email = email;
if (phone) contact.phone = phone;
return [{ json: { ok: true, contact, tags } }];
