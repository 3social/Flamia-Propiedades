// FLR · tool-properties — búsqueda y ficha de propiedades para los agentes.
// El tenant sale SOLO del secreto (D10): se ignora cualquier client_id del cuerpo.
const keyHash = $('Hash Key').first().json.keyHash || '';
const rawKey = $('Hash Key').first().json.rawKey || '';
const req = $('Normalize Request').first().json;
const client = $('Get Clients').all().map(i => i.json)
  .find(c => rawKey && c.active !== false && c.tool_secret_sha256 === keyHash);

if (!client) {
  return [{ json: { status: 401, body: { ok: false, error: 'unauthorized' } } }];
}

const fold = s => String(s || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().trim();
const num = v => (v === null || v === undefined || v === '' || isNaN(Number(v))) ? null : Number(v);
const en = fold(req.language).startsWith('en');
const day = d => String(d || '').slice(0, 10);

const rows = $input.all().map(i => i.json)
  .filter(p => p.client_id === client.client_id && p.visibility === 'public' && p.status === 'activa');

const card = p => ({
  ref_code: p.ref_code,
  title: en ? (p.title_en || p.title) : p.title,
  operation: p.operation,
  category: p.category,
  zone: p.zone,
  price: p.price,
  currency: p.currency,
  bedrooms: p.bedrooms,
  bathrooms: p.bathrooms,
  updated_at: day(p.updated_at),
  short_url: p.short_url || null
});

if (req.action === 'get') {
  const ref = fold(req.ref_code).toUpperCase();
  const p = rows.find(r => fold(r.ref_code).toUpperCase() === ref);
  if (!p) {
    return [{ json: { status: 200, body: { ok: true, found: false, message: en ? 'Property not found or not available.' : 'Propiedad no encontrada o no disponible.' } } }];
  }
  return [{ json: { status: 200, body: { ok: true, found: true, property: Object.assign(card(p), {
    construction_m2: p.construction_m2 || null,
    highlights: en ? (p.highlights_en || p.highlights) : p.highlights
  }) } } }];
}

const opMap = { compra: 'venta', comprar: 'venta', venta: 'venta', buy: 'venta', sale: 'venta', purchase: 'venta',
  renta: 'renta', rentar: 'renta', rent: 'renta', rental: 'renta', alquiler: 'renta' };
const operation = opMap[fold(req.operation)] || null;
const zone = fold(req.zone);
const category = fold(req.category);
const priceMax = num(req.price_max);
const priceMin = num(req.price_min);
const bedroomsMin = num(req.bedrooms_min);
const words = fold(req.query_text).split(/\s+/).filter(w => w.length > 3);
const limit = Math.min(Math.max(num(req.limit) || 3, 1), 3);

const matches = rows.filter(p =>
  (!operation || p.operation === operation) &&
  (!zone || fold(p.zone).includes(zone) || zone.includes(fold(p.zone))) &&
  (!category || fold(p.category).includes(category)) &&
  (priceMax === null || Number(p.price) <= priceMax) &&
  (priceMin === null || Number(p.price) >= priceMin) &&
  (bedroomsMin === null || Number(p.bedrooms) >= bedroomsMin) &&
  (!words.length || words.some(w => fold(p.title + ' ' + p.title_en + ' ' + p.highlights + ' ' + p.highlights_en).includes(w)))
).sort((a, b) => Number(b.price) - Number(a.price));

const results = matches.slice(0, limit).map(card);
const money = p => Number(p.price).toLocaleString('en-US') + ' ' + p.currency + (p.operation === 'renta' ? (en ? '/month' : '/mes') : '');
const summary = results.length
  ? results.map(p => p.ref_code + ': ' + p.title + ', ' + p.zone + ', ' + money(p) + ', ' + p.bedrooms + (en ? ' bd' : ' rec.') + (en ? ' (updated ' : ' (actualizado ') + p.updated_at + ')').join(' | ')
  : (en ? 'No matching properties in the current inventory.' : 'No hay propiedades que coincidan en el inventario actual.');

return [{ json: { status: 200, body: { ok: true, total_matches: matches.length, results, summary } } }];
