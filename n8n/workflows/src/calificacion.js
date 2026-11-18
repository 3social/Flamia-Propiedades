// FLR · calificacion — regla única de calificación (D26, docs/calificacion.md §2).
// Lee los contactos actualizados recientemente y escribe solo lo que cambia (idempotente).
const LOC = '20Yv36Yd31saVEePDNwB';
const PIPELINE = 'rS0oVeLwnZsT1FIsPYpv';
const ADVISOR = 'sq0EUpVWzXZU8VKIlfWc';
const F = {
  operacion: 'v9nuA3BYnMMgQmTY1hJ0', zonas: 'W5wnJnAm5tuhnhFrb53C', presupuesto: 'DkYitRLjPWXFvVWerdPp', presupuestoMin: 'UJCK7exwHkzNHtn1TdSv',
  plazo: 'oEqdidKzwuhs9YGssBTl', pago: 'N7i0mqlEVl78v2OgwtD0', nivel: 'E8fG0YO2XxTklhyXJ5gI',
  canal: 'ZKid0PLgouENEPuJw9ws', primerCanal: 'UlA83oq28Nwf9XEpzcA9', fechaPrimer: 'LeTlBesjW1K4CXxauMdc'
};
const API = 'https://services.leadconnectorhq.com';
const umbral = Number((($('Get Umbral').first().json || {}).customValue || {}).value) || 1000000;

const contacts = ($('Search Contacts').first().json.contacts || [])
  .filter(c => !String(c.firstName || '').startsWith('(Example)'));

const calls = [];
const call = (rule, contactId, method, path, body) =>
  calls.push({ json: { rule, contactId, method, url: API + path, body: body || {} } });
const CANAL_TAG = { fuente_google: 'Google Ads', fuente_meta: 'Meta Ads', fuente_tiktok: 'TikTok Ads' };
const has = v => v !== undefined && v !== null && String(v).trim() !== '';

for (const c of contacts) {
  const tags = new Set((c.tags || []).map(t => String(t).toLowerCase()));
  if (tags.has('no_contactar')) continue;
  const cf = Object.fromEntries((c.customFields || []).map(f => [f.id, f.value]));
  const name = [c.firstName, c.lastName].filter(Boolean).join(' ') || c.email || 'Lead';

  const plazo = String(cf[F.plazo] || '');
  const pago = String(cf[F.pago] || '');
  // La landing guarda rangos (mín–máx; "más de 2M" no tiene máximo): cualquiera de los dos cuenta como presupuesto.
  const presupuesto = has(cf[F.presupuestoMin]) ? Number(cf[F.presupuestoMin]) : Number(cf[F.presupuesto]);
  const calificado = has(cf[F.operacion]) && has(cf[F.zonas]) && (has(cf[F.presupuesto]) || has(cf[F.presupuestoMin])) && has(plazo);
  const vip = presupuesto >= umbral;

  let nivel = null;
  if (plazo === 'Solo explorando') nivel = 'Frio';
  else if (calificado && ['Inmediato', '1 a 3 meses'].includes(plazo) &&
           (['Contado', 'Fideicomiso', 'Credito'].includes(pago) || tags.has('visita_agendada'))) nivel = 'Caliente';
  else if (calificado) nivel = 'Tibio';

  const upd = [];
  if (nivel && cf[F.nivel] !== nivel) upd.push({ id: F.nivel, field_value: nivel });
  // Formularios nativos (Meta Lead Ads, TikTok Lead Gen): GHL solo pone el tag de fuente; aquí se completa el canal (D28).
  const fuente = Object.keys(CANAL_TAG).find(t => tags.has(t));
  if (fuente && !has(cf[F.canal])) upd.push({ id: F.canal, field_value: CANAL_TAG[fuente] });
  if (fuente && !has(cf[F.primerCanal])) {
    upd.push({ id: F.primerCanal, field_value: CANAL_TAG[fuente] });
    upd.push({ id: F.fechaPrimer, field_value: String(c.dateAdded || new Date().toISOString()).slice(0, 10) });
  }
  if (upd.length) call('campos', c.id, 'PUT', '/contacts/' + c.id, { customFields: upd });

  const add = [];
  if (calificado && !tags.has('lead_calificado')) add.push('lead_calificado');
  if (nivel === 'Caliente' && !tags.has('lead_caliente')) {
    add.push('lead_caliente');
    call('caliente_tarea', c.id, 'POST', '/contacts/' + c.id + '/tasks', {
      title: 'Lead caliente: contactar en 15 min · ' + name,
      body: 'Calificado con plazo corto y pago definido (o visita agendada). Revisa la conversación y llama.',
      dueDate: new Date(Date.now() + 15 * 60 * 1000).toISOString(), completed: false, assignedTo: ADVISOR });
  }
  // VIP: humano directo aunque falten datos; FLR · 4 Pasar a humano pone ia_pausada y la tarea.
  if (vip && !tags.has('handoff_humano') && !tags.has('ia_pausada')) add.push('handoff_humano');
  if (add.length) call('tags', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: add });

}

// El builder de GHL no guarda el usuario en el paso de oportunidad: se asigna aquí.
// La búsqueda de contactos no trae assignedTo, por eso se leen las oportunidades aparte.
for (const o of ($('Get Opportunities').first().json.opportunities || [])) {
  if (o.status === 'open' && !o.assignedTo) call('asignar', o.contactId, 'PUT', '/opportunities/' + o.id, { assignedTo: ADVISOR });
}

return calls;
