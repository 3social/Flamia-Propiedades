import { workflow, node, trigger, expr } from '@n8n/workflow-sdk';

const cada2 = trigger({ type: 'n8n-nodes-base.scheduleTrigger', version: 1.3, config: { name: 'Cada 2 minutos',
  parameters: { rule: { interval: [{ field: 'minutes', minutesInterval: 2 }] } } } });

const getUmbral = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Get Umbral',
  parameters: { method: 'GET', url: 'https://services.leadconnectorhq.com/locations/20Yv36Yd31saVEePDNwB/customValues/2Kk9KolkVmYu4mOIm6tb',
    authentication: 'genericCredentialType', genericAuthType: 'httpBearerAuth', sendHeaders: true,
    headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] }, options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const searchContacts = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Search Contacts',
  parameters: { method: 'POST', url: 'https://services.leadconnectorhq.com/contacts/search', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json',
    jsonBody: "{\"locationId\": \"20Yv36Yd31saVEePDNwB\", \"pageLimit\": 100, \"sort\": [{\"field\": \"dateUpdated\", \"direction\": \"desc\"}]}", options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const getOpportunities = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Get Opportunities',
  parameters: { method: 'GET', url: 'https://services.leadconnectorhq.com/opportunities/search', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendQuery: true, queryParameters: { parameters: [
      { name: 'location_id', value: '20Yv36Yd31saVEePDNwB' }, { name: 'pipeline_id', value: 'rS0oVeLwnZsT1FIsPYpv' },
      { name: 'status', value: 'open' }, { name: 'limit', value: '100' } ] },
    sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] }, options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const planActions = node({ type: 'n8n-nodes-base.code', version: 2, config: { name: 'Plan Actions',
  parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: "// FLR · calificacion — regla única de calificación (D26, docs/calificacion.md §2).\n// Lee los contactos actualizados recientemente y escribe solo lo que cambia (idempotente).\nconst LOC = '20Yv36Yd31saVEePDNwB';\nconst PIPELINE = 'rS0oVeLwnZsT1FIsPYpv';\nconst ADVISOR = 'sq0EUpVWzXZU8VKIlfWc';\nconst F = {\n  operacion: 'v9nuA3BYnMMgQmTY1hJ0', zonas: 'W5wnJnAm5tuhnhFrb53C', presupuesto: 'DkYitRLjPWXFvVWerdPp', presupuestoMin: 'UJCK7exwHkzNHtn1TdSv',\n  plazo: 'oEqdidKzwuhs9YGssBTl', pago: 'N7i0mqlEVl78v2OgwtD0', nivel: 'E8fG0YO2XxTklhyXJ5gI'\n};\nconst API = 'https://services.leadconnectorhq.com';\nconst umbral = Number((($('Get Umbral').first().json || {}).customValue || {}).value) || 1000000;\n\nconst contacts = ($('Search Contacts').first().json.contacts || [])\n  .filter(c => !String(c.firstName || '').startsWith('(Example)'));\n\nconst calls = [];\nconst call = (rule, contactId, method, path, body) =>\n  calls.push({ json: { rule, contactId, method, url: API + path, body: body || {} } });\nconst has = v => v !== undefined && v !== null && String(v).trim() !== '';\n\nfor (const c of contacts) {\n  const tags = new Set((c.tags || []).map(t => String(t).toLowerCase()));\n  if (tags.has('no_contactar')) continue;\n  const cf = Object.fromEntries((c.customFields || []).map(f => [f.id, f.value]));\n  const name = [c.firstName, c.lastName].filter(Boolean).join(' ') || c.email || 'Lead';\n\n  const plazo = String(cf[F.plazo] || '');\n  const pago = String(cf[F.pago] || '');\n  // La landing guarda rangos (mín–máx; \"más de 2M\" no tiene máximo): cualquiera de los dos cuenta como presupuesto.\n  const presupuesto = has(cf[F.presupuestoMin]) ? Number(cf[F.presupuestoMin]) : Number(cf[F.presupuesto]);\n  const calificado = has(cf[F.operacion]) && has(cf[F.zonas]) && (has(cf[F.presupuesto]) || has(cf[F.presupuestoMin])) && has(plazo);\n  const vip = presupuesto >= umbral;\n\n  let nivel = null;\n  if (plazo === 'Solo explorando') nivel = 'Frio';\n  else if (calificado && ['Inmediato', '1 a 3 meses'].includes(plazo) &&\n           (['Contado', 'Fideicomiso', 'Credito'].includes(pago) || tags.has('visita_agendada'))) nivel = 'Caliente';\n  else if (calificado) nivel = 'Tibio';\n\n  if (nivel && cf[F.nivel] !== nivel) {\n    call('nivel', c.id, 'PUT', '/contacts/' + c.id, { customFields: [{ id: F.nivel, field_value: nivel }] });\n  }\n\n  const add = [];\n  if (calificado && !tags.has('lead_calificado')) add.push('lead_calificado');\n  if (nivel === 'Caliente' && !tags.has('lead_caliente')) {\n    add.push('lead_caliente');\n    call('caliente_tarea', c.id, 'POST', '/contacts/' + c.id + '/tasks', {\n      title: 'Lead caliente: contactar en 15 min · ' + name,\n      body: 'Calificado con plazo corto y pago definido (o visita agendada). Revisa la conversación y llama.',\n      dueDate: new Date(Date.now() + 15 * 60 * 1000).toISOString(), completed: false, assignedTo: ADVISOR });\n  }\n  // VIP: humano directo aunque falten datos; FLR · 4 Pasar a humano pone ia_pausada y la tarea.\n  if (vip && !tags.has('handoff_humano') && !tags.has('ia_pausada')) add.push('handoff_humano');\n  if (add.length) call('tags', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: add });\n\n}\n\n// El builder de GHL no guarda el usuario en el paso de oportunidad: se asigna aquí.\n// La búsqueda de contactos no trae assignedTo, por eso se leen las oportunidades aparte.\nfor (const o of ($('Get Opportunities').first().json.opportunities || [])) {\n  if (o.status === 'open' && !o.assignedTo) call('asignar', o.contactId, 'PUT', '/opportunities/' + o.id, { assignedTo: ADVISOR });\n}\n\nreturn calls;\n" } } });

const applyAction = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Apply Action', onError: 'continueRegularOutput',
  parameters: { method: expr('{{ $json.method }}'), url: expr('{{ $json.url }}'), authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json', jsonBody: expr('{{ JSON.stringify($json.body) }}'),
    options: { batching: { batch: { batchSize: 5, batchInterval: 1000 } } } },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

export default workflow('flr-calificacion', 'FLR · calificacion')
  .add(cada2).to(getUmbral).to(searchContacts).to(getOpportunities).to(planActions).to(applyAction);
