-- Las imágenes del logo se subieron desde el panel de medios a la raíz de storage/
-- (no a storage/ardenza/). Este ajuste apunta logo, favicon e imagen para redes a esa ubicación.
UPDATE settings SET value = REPLACE(value, 'ardenza/', '')
WHERE value IN ('ardenza/ardenza-horizontal.png', 'ardenza/ardenza-favicon.png', 'ardenza/ardenza-redes-1200x630.png');

SELECT `key`, value FROM settings WHERE value LIKE 'ardenza-%.png';
