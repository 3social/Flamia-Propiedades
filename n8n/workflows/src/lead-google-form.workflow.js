import { workflow, node, trigger, expr, ifElse } from '@n8n/workflow-sdk';

const webhook = trigger({ type: 'n8n-nodes-base.webhook', version: 2.1, config: { name: 'Webhook google-form',
  parameters: { httpMethod: 'POST', path: 'flr-lead-google-form', responseMode: 'responseNode', options: {} } } });

const hashKey = node({ type: 'n8n-nodes-base.crypto', version: 2, config: { name: 'Hash Key',
  parameters: { action: 'hash', type: 'SHA256', value: expr('{{ $json.body.google_key || "" }}'), dataPropertyName: 'keyHash', encoding: 'hex' } } });

const findDup = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Find Duplicate', onError: 'continueRegularOutput', alwaysOutputData: true,
  parameters: { method: 'GET', url: 'https://services.leadconnectorhq.com/contacts/search/duplicate', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendQuery: true, queryParameters: { parameters: [
      { name: 'locationId', value: '20Yv36Yd31saVEePDNwB' }, { name: 'email', value: expr("{{ (($('Webhook google-form').first().json.body.user_column_data || []).find(c => c.column_id === 'EMAIL') || {}).string_value || 'sin-correo@invalid.local' }}") } ] },
    sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] }, options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const buildContact = node({ type: 'n8n-nodes-base.code', version: 2, config: { name: 'Build Contact',
  parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: "// FLR · lead-google-form — webhook del Lead Form Asset de Google Ads → contacto en GHL (D28).\n// La clave (google_key) vive fuera del repo (.secrets/); aquí solo su SHA-256.\nconst KEY_SHA256 = 'c922111ae856d384ec3a8644b18a89e23c1f2ac213ca1a1a0b49e7109fc47a93';\nconst LOC = '20Yv36Yd31saVEePDNwB';\nconst F = {\n  zonas: 'W5wnJnAm5tuhnhFrb53C', preferencias: 'iTYEfN6SyUURSy90TCwk', idioma: 'rzHfMHa4W0cpEHCIYfd1',\n  canal: 'ZKid0PLgouENEPuJw9ws', primerCanal: 'UlA83oq28Nwf9XEpzcA9', fechaPrimer: 'LeTlBesjW1K4CXxauMdc',\n  campanaId: 'seOWjQYrlhEYmTJtQnte', grupoId: 'Z8WSwT5fAhYHdndKDRxk', anuncioId: 'mGdVGdIIeCrduuswCNTT',\n  gclid: 'XHWBuCwkw8z74VVlurtB', utmSource: 'vWhAGbPkbPIQ0TqNZC8C', utmMedium: '4cgJDUcobqcnS1xU8qzZ'\n};\n\nconst b = $('Webhook google-form').first().json.body || {};\nconst keyHash = $('Hash Key').first().json.keyHash || '';\nconst existing = ($('Find Duplicate').first().json || {}).contact || null;\nconst s = (v, n) => String(v ?? '').trim().slice(0, n || 200);\n\nif (!b.google_key || keyHash !== KEY_SHA256) return [{ json: { ok: false, status: 401, body: { ok: false, error: 'unauthorized' } } }];\n\n// user_column_data: [{ column_id: 'FULL_NAME' | 'EMAIL' | 'PHONE_NUMBER' | ..., column_name, string_value }]\nconst cols = Array.isArray(b.user_column_data) ? b.user_column_data : [];\nconst val = id => s((cols.find(c => c.column_id === id) || {}).string_value);\nconst full = val('FULL_NAME') || [val('FIRST_NAME'), val('LAST_NAME')].filter(Boolean).join(' ');\nconst email = val('EMAIL').toLowerCase();\nconst phone = val('PHONE_NUMBER').replace(/[^\\d+]/g, '');\nconst otras = cols.filter(c => !['FULL_NAME', 'FIRST_NAME', 'LAST_NAME', 'EMAIL', 'PHONE_NUMBER', 'WORK_EMAIL', 'WORK_PHONE'].includes(c.column_id))\n  .map(c => s(c.column_name || c.column_id, 80) + ': ' + s(c.string_value, 200)).join(' | ');\nif (!email && phone.length < 8) return [{ json: { ok: false, status: 200, body: {} } }];\n\nconst [first, ...rest] = (full || 'Lead Google').split(/\\s+/);\nconst cf = [];\nconst set = (id, v) => { if (v !== null && v !== undefined && v !== '') cf.push({ id, field_value: v }); };\nset(F.canal, 'Google Ads'); set(F.utmSource, 'google'); set(F.utmMedium, 'lead_form');\nset(F.gclid, s(b.gcl_id, 300)); set(F.campanaId, s(b.campaign_id, 60)); set(F.grupoId, s(b.adgroup_id, 60)); set(F.anuncioId, s(b.creative_id, 60));\nset(F.zonas, val('CITY')); set(F.preferencias, otras ? 'Formulario Google: ' + otras : '');\nconst prevCf = Object.fromEntries(((existing && existing.customFields) || []).map(f => [f.id, f.value]));\nif (!prevCf[F.primerCanal]) { set(F.primerCanal, 'Google Ads'); set(F.fechaPrimer, new Date().toISOString().slice(0, 10)); }\n\nconst tags = ['formulario_nativo', 'fuente_google'];\nif (b.is_test) tags.push('demo');\n// Los tags NO van en el upsert (GHL los reemplazaría); se agregan en 'Add Tags'.\nconst contact = { locationId: LOC, firstName: first, lastName: rest.join(' '), source: 'google lead form ' + s(b.form_id, 40), customFields: cf };\nif (email) contact.email = email;\nif (phone) contact.phone = phone;\nreturn [{ json: { ok: true, contact, tags } }];\n" } } });

const esValido = ifElse({ version: 2.2, config: { name: 'Es valido', parameters: { conditions: {
  options: { caseSensitive: true, leftValue: '', typeValidation: 'loose' },
  conditions: [{ leftValue: expr('{{ $json.ok }}'), operator: { type: 'boolean', operation: 'true', singleValue: true } }],
  combinator: 'and' } } } });

const upsert = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Upsert Contact',
  parameters: { method: 'POST', url: 'https://services.leadconnectorhq.com/contacts/upsert', authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json', jsonBody: expr('{{ JSON.stringify($json.contact) }}'), options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const addTags = node({ type: 'n8n-nodes-base.httpRequest', version: 4.2, config: { name: 'Add Tags', onError: 'continueRegularOutput',
  parameters: { method: 'POST', url: expr('https://services.leadconnectorhq.com/contacts/{{ $json.contact.id }}/tags'), authentication: 'genericCredentialType',
    genericAuthType: 'httpBearerAuth', sendHeaders: true, headerParameters: { parameters: [{ name: 'Version', value: '2021-07-28' }] },
    sendBody: true, contentType: 'json', specifyBody: 'json', jsonBody: expr("{{ JSON.stringify({ tags: $('Build Contact').first().json.tags }) }}"), options: {} },
  credentials: { httpBearerAuth: { id: 'RVXU4guLpA2rVXFu', name: 'GHL PIT - Ardenza' } } } });

const respondOk = node({ type: 'n8n-nodes-base.respondToWebhook', version: 1.5, config: { name: 'Respond OK',
  parameters: { respondWith: 'json', responseBody: '{"ok": true}', options: { responseCode: 200 } } } });

const respondError = node({ type: 'n8n-nodes-base.respondToWebhook', version: 1.5, config: { name: 'Respond Error',
  parameters: { respondWith: 'json', responseBody: expr('{{ JSON.stringify($json.body) }}'), options: { responseCode: expr('{{ $json.status }}') } } } });

export default workflow('flr-lead-google-form', 'FLR · lead-google-form')
  .add(webhook).to(hashKey).to(findDup).to(buildContact).to(esValido.onTrue(upsert.to(addTags.to(respondOk))).onFalse(respondError));
