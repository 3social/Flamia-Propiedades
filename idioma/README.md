# Textos del sitio en español

| Archivo | Qué traduce | Dónde va |
|---|---|---|
| `es.json` | Los ~400 textos fijos del tema (botones, filtros, "Featured properties", "Add Property", "Wishlist"…) | Subir a `public_html/inmobiliaria/lang/es.json` (junto a las carpetas `es/`, `en/`, `vi/`) |
| `traducir-titulos-inicio.sql` | Títulos de las secciones del inicio y widgets (`title="Featured projects"` → `title="Desarrollos destacados"`) | phpMyAdmin → Importar |

`generar_es_json.py` contiene el diccionario y regenera ambos si se ajusta un texto.
El SQL solo reemplaza valores exactos entre comillas; el resto del contenido no se toca.
