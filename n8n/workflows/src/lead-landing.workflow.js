import { workflow, node, trigger, expr, ifElse } from '@n8n/workflow-sdk';

const webhook = trigger({ type: 'n8n-nodes-base.webhook', version: 2.1, config: { name: 'Webhook lead-landing',
  parameters: { httpMethod: 'POST', path: 'flr-lead-landing', responseMode: 'responseNode', options: { allowedOrigins: '*' } } } });

const buildContact = node({ type: 'n8n-nodes-base.code', version: 2, config: { name: 'Build Contact',
  parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: "// FLR · lead-landing — formulario multi-paso de la landing → contacto en GHL (D26 §3, D27).\n// La landing solo captura; FLR · calificacion decide el nivel y GHL crea la oportunidad (FLR · 1 Lead nuevo).\nconst LOC = '20Yv36Yd31saVEePDNwB';\nconst F = {\n  operacion: 'v9nuA3BYnMMgQmTY1hJ0', presupuestoMin: 'UJCK7exwHkzNHtn1TdSv', presupuestoMax: 'DkYitRLjPWXFvVWerdPp',\n  moneda: 'vAlCJWawX7fdEEsNHLJj', plazo: 'oEqdidKzwuhs9YGssBTl', zonas: 'W5wnJnAm5tuhnhFrb53C', idioma: 'rzHfMHa4W0cpEHCIYfd1',\n  optin: 'NAinWUz9ttZkq9vw110z', fechaOptin: 'B21G8QqRea8ykzmhZPNQ', origenOptin: 'sCzcCjmtdjI1Fmt3SuqG',\n  ref: 'RHMJTGCEAXTIMhqJkX6h', utmSource: 'vWhAGbPkbPIQ0TqNZC8C', utmMedium: '4cgJDUcobqcnS1xU8qzZ', utmCampaign: 'SySJ8ZvfNnqixzs2MpAL',\n  proposito: 'p6MGGLJvf89R3Wh5m53P'\n};\nconst RANGOS = { hasta_500k: [null, 500000], '500k_1m': [500000, 1000000], '1m_2m': [1000000, 2000000], mas_2m: [2000000, null] };\nconst PLAZOS = ['Inmediato', '1 a 3 meses', '3 a 6 meses', 'Mas de 6 meses', 'Solo explorando'];\nconst OPERACIONES = ['Compra', 'Renta'];\nconst PROPOSITOS = ['Vivir', 'Inversion', 'Vacacional'];\n\nconst b = $input.first().json.body || {};\nconst s = (v, n) => String(v ?? '').trim().slice(0, n || 120);\nconst fail = (msg) => [{ json: { ok: false, status: 400, body: { ok: false, error: msg } } }];\n\n// Honeypot: un bot llena el campo oculto; se responde ok sin escribir nada.\nif (s(b.website)) return [{ json: { ok: false, status: 200, body: { ok: true } } }];\n\nconst nombre = s(b.nombre, 80);\nconst email = s(b.email, 120).toLowerCase();\nconst telefono = s(b.telefono, 20).replace(/[^\\d+]/g, '');\nif (!nombre) return fail('nombre');\nif (!email && telefono.length < 8) return fail('contacto');\nif (email && !/^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$/.test(email)) return fail('email');\n\nconst [first, ...rest] = nombre.split(/\\s+/);\nconst ref = s(b.ref, 20).toUpperCase();\nconst optin = b.opt_in === true || b.opt_in === 'true' || b.opt_in === 'on';\nconst cf = [];\nconst set = (id, v) => { if (v !== null && v !== undefined && v !== '') cf.push({ id, field_value: v }); };\n\nif (OPERACIONES.includes(b.operacion)) set(F.operacion, b.operacion);\nconst rango = RANGOS[b.rango];\nif (rango) { set(F.presupuestoMin, rango[0]); set(F.presupuestoMax, rango[1]); set(F.moneda, 'USD'); }\nif (PLAZOS.includes(b.plazo)) set(F.plazo, b.plazo);\nif (PROPOSITOS.includes(b.proposito)) set(F.proposito, b.proposito);\nset(F.zonas, s(b.zona, 80));\nset(F.idioma, s(b.idioma, 2) === 'en' ? 'en' : 'es');\nset(F.ref, ref);\nset(F.utmSource, s(b.utm_source, 80)); set(F.utmMedium, s(b.utm_medium, 80)); set(F.utmCampaign, s(b.utm_campaign, 80));\nset(F.optin, optin ? 'Si' : 'No');\nif (optin) { set(F.fechaOptin, new Date().toISOString().slice(0, 10)); set(F.origenOptin, 'landing ' + (ref || 'sin-ref')); }\n\nconst tags = ['landing'];\nif (optin) tags.push('opt_in_whatsapp');\n\nconst contact = { locationId: LOC, firstName: first, lastName: rest.join(' '), source: 'landing ' + (ref || ''), tags, customFields: cf };\nif (email) contact.email = email;\nif (telefono) contact.phone = telefono;\n\nreturn [{ json: { ok: true, contact } }];\n" } } });

const esValido = ifElse({ version: 2.2, config: { name: 'Es valido', parameters: { conditions: {
  options: { caseSensitive: true, leftValue: '', typeValidation: 'loose' },
  conditions: [{ leftValue: expr('{{ $json.ok }}'), operator: { type: 'boolean', operation: 'true', singleValue: true } }],
  combinator: 'and' } } } });

const upsert = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Upsert Contact',
  parameters: { method: 'POST', url: 'https://services.leadconnectorhq.com/contacts/upsert', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json', jsonBody: expr('{{ JSON.stringify($json.contact) }}'), options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const respondOk = node({ type: 'n8n-nodes-base.respondToWebhook', version: 1.5, config: { name: 'Respond OK',
  parameters: { respondWith: 'json', responseBody: '{"ok": true}', options: { responseCode: 200 } } } });

const respondError = node({ type: 'n8n-nodes-base.respondToWebhook', version: 1.5, config: { name: 'Respond Error',
  parameters: { respondWith: 'json', responseBody: expr('{{ JSON.stringify($json.body) }}'), options: { responseCode: expr('{{ $json.status }}') } } } });

export default workflow('flr-lead-landing', 'FLR · lead-landing')
  .add(webhook).to(buildContact).to(esValido.onTrue(upsert.to(respondOk)).onFalse(respondError));
