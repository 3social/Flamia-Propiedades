import { workflow, node, trigger, expr, ifElse } from '@n8n/workflow-sdk';

const cada5 = trigger({ type: 'n8n-nodes-base.scheduleTrigger', version: 1.3, config: { name: 'Cada 5 minutos',
  parameters: { rule: { interval: [{ field: 'minutes', minutesInterval: 5 }] } } } });

const searchContacts = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Search Contacts',
  parameters: { method: 'POST', url: 'https://services.leadconnectorhq.com/contacts/search', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json',
    jsonBody: "{\"locationId\": \"20Yv36Yd31saVEePDNwB\", \"pageLimit\": 100, \"sort\": [{\"field\": \"dateUpdated\", \"direction\": \"desc\"}]}", options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const getAppointments = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Get Appointments', executeOnce: true,
  parameters: { method: 'GET', url: 'https://services.leadconnectorhq.com/calendars/events', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendQuery: true, queryParameters: { parameters: [
      { name: 'locationId', value: '20Yv36Yd31saVEePDNwB' }, { name: 'calendarId', value: 'BtGxfsUJVMjlqudnl0eM' },
      { name: 'startTime', value: expr('{{ $now.minus({ days: 1 }).toMillis() }}') },
      { name: 'endTime', value: expr('{{ $now.plus({ days: 60 }).toMillis() }}') } ] },
    sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-04-15' }] }, options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const planActions = node({ type: 'n8n-nodes-base.code', version: 2, config: { name: 'Plan Actions',
  parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: "const LOC = '20Yv36Yd31saVEePDNwB';\nconst PIPELINE = 'rS0oVeLwnZsT1FIsPYpv';\nconst ADVISOR = 'sq0EUpVWzXZU8VKIlfWc';\nconst STAGES = ['8fb052d3-5321-41cd-8263-7c217bb2c981', 'c4d90c5b-1d93-449a-9b77-b7a6164d3309', '42cfcd24-5a2a-4a43-a6f7-dc7ec794a9ca',\n  '5dcde591-72fc-40ec-92e9-7d3e7b03c579', '337b0436-a238-49df-a3f5-d31262930ce5', '73f3c3fa-0a47-475e-8453-2c7241e606c2'];\nconst [NUEVO, CALIFICADO, VISITA] = STAGES;\nconst F = { operacion: 'v9nuA3BYnMMgQmTY1hJ0', zonas: 'W5wnJnAm5tuhnhFrb53C', presupuesto: 'DkYitRLjPWXFvVWerdPp', plazo: 'oEqdidKzwuhs9YGssBTl' };\nconst API = 'https://services.leadconnectorhq.com';\n\nconst contacts = ($('Search Contacts').first().json.contacts || []).filter(c => !String(c.firstName || '').startsWith('(Example)'));\nconst events = $('Get Appointments').first().json.events || [];\nconst booked = new Set(events.filter(e => !['cancelled', 'invalid', 'noshow'].includes(e.appointmentStatus)).map(e => e.contactId));\n\nconst calls = [];\nconst call = (rule, contactId, method, path, body, version) =>\n  calls.push({ json: { rule, contactId, method, url: API + path, body: body || {}, version: version || '2021-07-28' } });\nconst rank = id => STAGES.indexOf(id);\nconst has = (v) => v !== undefined && v !== null && String(v).trim() !== '';\n\nfor (const c of contacts) {\n  const tags = new Set((c.tags || []).map(t => String(t).toLowerCase()));\n  const cf = Object.fromEntries((c.customFields || []).map(f => [f.id, f.value]));\n  const opp = (c.opportunities || []).find(o => o.pipelineId === PIPELINE);\n  const name = [c.firstName, c.lastName].filter(Boolean).join(' ') || c.email || 'Lead';\n\n  // 5 \u00b7 Baja: DND en todo y nada m\u00e1s para este contacto.\n  if (tags.has('no_contactar')) {\n    if (!c.dnd) call('baja', c.id, 'PUT', '/contacts/' + c.id, { dnd: true });\n    continue;\n  }\n\n  // 2 \u00b7 Calificado = operaci\u00f3n + zona + (presupuesto o plazo).\n  const calificado = has(cf[F.operacion]) && has(cf[F.zonas]) && (has(cf[F.presupuesto]) || has(cf[F.plazo]));\n  let target = -1;\n  if (calificado) {\n    if (!tags.has('lead_calificado')) call('calificado', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['lead_calificado'] });\n    target = rank(CALIFICADO);\n  }\n\n  // 3 \u00b7 Visita agendada en el calendario Visitas privadas.\n  if (booked.has(c.id)) {\n    if (!tags.has('visita_agendada')) call('visita', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['visita_agendada'] });\n    target = rank(VISITA);\n  }\n  // 1 \u00b7 Lead nuevo: toda persona entra al pipeline Compradores, directo en la etapa que ya le corresponde.\n  if (!opp) {\n    call('lead_nuevo', c.id, 'POST', '/opportunities/', { pipelineId: PIPELINE, locationId: LOC, name: name,\n      pipelineStageId: target > 0 ? STAGES[target] : NUEVO, status: 'open', contactId: c.id, assignedTo: ADVISOR, source: c.source || 'FLR' });\n  } else if (opp.status === 'open' && target > rank(opp.pipelineStageId)) {\n    call(target === rank(VISITA) ? 'visita' : 'calificado', c.id, 'PUT', '/opportunities/' + opp.id, { pipelineStageId: STAGES[target] });\n  }\n\n  // 4 \u00b7 Pasar a humano: pausa marcada con ia_pausada + tarea para el asesor (la tarea se verifica en vivo antes de crearla).\n  if (tags.has('handoff_humano') && !tags.has('ia_pausada')) {\n    call('handoff', c.id, 'POST', '/contacts/' + c.id + '/tags', { tags: ['ia_pausada'] });\n    call('handoff_tarea', c.id, 'POST', '/contacts/' + c.id + '/tasks', { title: 'Contactar hoy: ' + name + ' pidi\u00f3 un asesor',\n      body: 'El agente de IA pas\u00f3 la conversaci\u00f3n a humano. Revisa la conversaci\u00f3n antes de escribir.',\n      dueDate: new Date(Date.now() + 2 * 3600 * 1000).toISOString(), completed: false, assignedTo: ADVISOR });\n  }\n}\n\nreturn calls;\n" } } });

const applyAction = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Apply Action', onError: 'continueRegularOutput',
  parameters: { method: expr('{{ $json.method }}'), url: expr('{{ $json.url }}'), authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: expr('{{ $json.version }}') }] },
    sendBody: true, contentType: 'json', specifyBody: 'json', jsonBody: expr('{{ JSON.stringify($json.body) }}'),
    options: { batching: { batch: { batchSize: 5, batchInterval: 1000 } } } },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });


const esTarea = ifElse({ version: 2.2, config: { name: 'Es tarea', parameters: { conditions: {
  options: { caseSensitive: true, leftValue: '', typeValidation: 'strict' },
  conditions: [{ leftValue: expr('{{ $json.rule }}'), operator: { type: 'string', operation: 'equals' }, rightValue: 'handoff_tarea' }],
  combinator: 'and' } } } });

const getTasks = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Get Tasks',
  parameters: { method: 'GET', url: expr('{{ $json.url }}'), authentication: 'genericCredentialType', genericAuthType: 'httpBearerAuth',
    sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] }, options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const sinTareaAbierta = node({ type: 'n8n-nodes-base.code', version: 2, config: { name: 'Sin tarea abierta',
  parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: "// La b\u00fasqueda de GHL puede ir ~1 min atrasada: solo se crea la tarea si el contacto no tiene ya una abierta igual.\nconst planned = $('Es tarea').all();\nreturn $input.all().flatMap((it, i) => {\n  const call = planned[i].json;\n  const yaExiste = (it.json.tasks || []).some(t => !t.completed && t.title === call.body.title);\n  return yaExiste ? [] : [{ json: call }];\n});" } } });

export default workflow('flr-ghl-automatizaciones', 'FLR · ghl-automatizaciones')
  .add(cada5).to(searchContacts).to(getAppointments).to(planActions)
  .to(esTarea.onTrue(getTasks.to(sinTareaAbierta.to(applyAction))).onFalse(applyAction));