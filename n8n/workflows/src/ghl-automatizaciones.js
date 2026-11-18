// FLR · ghl-automatizaciones — sustituye los 5 workflows de GHL (la API de workflows no está habilitada para la subcuenta).
// Lee el estado actual de GHL y devuelve solo las llamadas que faltan: correr dos veces no duplica nada (principio 6).
const LOC = '20Yv36Yd31saVEePDNwB';
const PIPELINE = 'rS0oVeLwnZsT1FIsPYpv';
const ADVISOR = 'sq0EUpVWzXZU8VKIlfWc';
const STAGES = ['8fb052d3-5321-41cd-8263-7c217bb2c981', 'c4d90c5b-1d93-449a-9b77-b7a6164d3309', '42cfcd24-5a2a-4a43-a6f7-dc7ec794a9ca',
  '5dcde591-72fc-40ec-92e9-7d3e7b03c579', '337b0436-a238-49df-a3f5-d31262930ce5', '73f3c3fa-0a47-475e-8453-2c7241e606c2'];
const [NUEVO, CALIFICADO, VISITA] = STAGES;
const F = { operacion: 'v9nuA3BYnMMgQmTY1hJ0', zonas: 'W5wnJnAm5tuhnhFrb53C', presupuesto: 'DkYitRLjPWXFvVWerdPp', plazo: 'oEqdidKzwuhs9YGssBTl' };
const API = 'https://services.leadconnectorhq.com';

const contacts = ($('Search Contacts').first().json.contacts || []).filter(c => !String(c.firstName || '').startsWith('(Example)'));
const events = $('Get Appointments').first().json.events || [];
const booked = new Set(events.filter(e => !['cancelled', 'invalid', 'noshow'].includes(e.appointmentStatus)).map(e => e.contactId));

const calls = [];
const call = (rule, contactId, method, path, body, version) =>
  calls.push({ json: { rule, contactId, method, url: API + path, body: body || {}, version: version || '2021-07-28' } });
const rank = id => STAGES.indexOf(id);
const has = (v) => v !== undefined && v !== null && String(v).trim() !== '';

for (const c of contacts) {
  const tags = new Set((c.tags || []).map(t => String(t).toLowerCase()));
  const cf = Object.fromEntries((c.customFields || []).map(f => [f.id, f.value]));
  const opp = (c.opportunities || []).find(o => o.pipelineId === PIPELINE);
  const name = [c.firstName, c.lastName].filter(Boolean).join(' ') || c.email || 'Lead';

  // 5 · Baja: DND en todo y nada más para este contacto.
  if (tags.has('no_contactar')) {
    if (!c.dnd) call('baja', c.id, 'PUT', '/contacts/' + c.id, { dnd: true });
    continue;
  }

  // 2 · Calificado = operación + zona + (presupuesto o plazo).
  const calificado = has(cf[F.operacion]) && has(cf[F.zonas]) && (has(cf[F.presupuesto]) || has(cf[F.plazo]));
  let target = -1;
  if (calificado) {
    if (!tags.has('lead_calificado')) call('calificado', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['lead_calificado'] });
    target = rank(CALIFICADO);
  }

  // 3 · Visita agendada en el calendario Visitas privadas.
  if (booked.has(c.id)) {
    if (!tags.has('visita_agendada')) call('visita', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['visita_agendada'] });
    target = rank(VISITA);
  }
  // 1 · Lead nuevo: toda persona entra al pipeline Compradores, directo en la etapa que ya le corresponde.
  if (!opp) {
    call('lead_nuevo', c.id, 'POST', '/opportunities/', { pipelineId: PIPELINE, locationId: LOC, name: name,
      pipelineStageId: target > 0 ? STAGES[target] : NUEVO, status: 'open', contactId: c.id, assignedTo: ADVISOR, source: c.source || 'FLR' });
  } else if (opp.status === 'open' && target > rank(opp.pipelineStageId)) {
    call(target === rank(VISITA) ? 'visita' : 'calificado', c.id, 'PUT', '/opportunities/' + opp.id, { pipelineStageId: STAGES[target] });
  }

  // 4 · Pasar a humano: pausa marcada con ia_pausada + tarea para el asesor (la tarea se verifica en vivo antes de crearla).
  if (tags.has('handoff_humano') && !tags.has('ia_pausada')) {
    call('handoff', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['ia_pausada'] });
    call('handoff_tarea', c.id, 'POST', '/contacts/' + c.id + '/tasks', { title: 'Contactar hoy: ' + name + ' pidió un asesor',
      body: 'El agente de IA pasó la conversación a humano. Revisa la conversación antes de escribir.',
      dueDate: new Date(Date.now() + 2 * 3600 * 1000).toISOString(), completed: false, assignedTo: ADVISOR });
  }
}

return calls;

// ── Nodo "Sin tarea abierta" (tras "Es tarea" → "Get Tasks" GET /contacts/{id}/tasks) ──
// La búsqueda de GHL puede ir ~1 min atrasada: solo se crea la tarea si el contacto no tiene ya una abierta igual.
// const planned = $('Es tarea').all();
// return $input.all().flatMap((it, i) => {
//   const call = planned[i].json;
//   const yaExiste = (it.json.tasks || []).some(t => !t.completed && t.title === call.body.title);
//   return yaExiste ? [] : [{ json: call }];
// });
