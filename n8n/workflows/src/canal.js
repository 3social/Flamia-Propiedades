// Regla de canal (docs/atribucion.md §3). Se copia tal cual en los nodos Code que la usan
// (FLR · lead-landing, FLR · lead-google-form); si cambia aquí, cambia en ambos.
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
