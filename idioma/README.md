# Sitio en español e inglés

Al cambiar de idioma, Botble lee cada parte del sitio de un lugar distinto. Si falta el otro idioma
en alguno de esos lugares, esa parte se queda en el idioma principal o directamente no aparece:

| Parte del sitio | Dónde vive cada idioma | Qué lo resuelve |
|---|---|---|
| Botones, filtros y textos del tema | `lang/es.json` (español) · inglés de origen | `es.json` |
| Panel del agente, estados (venta/renta), formulario de contacto, cookies, captcha, pagos | `lang/vendor/plugins/<módulo>/<idioma>/` | `ardenza-lang-vendor.zip` |
| Propiedades, desarrollos, noticias | tabla base + `*_translations` | `ardenza-bilingue.sql` |
| Países, ciudades, categorías, características | tabla base + `*_translations` | `ardenza-bilingue.sql` |
| Títulos y frases del inicio, nombres de páginas, Términos y condiciones | `pages` + `pages_translations` | `ardenza-bilingue.sql` |
| Menú principal y menús del pie | un menú por idioma | `ardenza-bilingue.sql` (copia el que falte) |
| Widgets del pie de página | filas por idioma (`flex-home-en_US`) | `ardenza-bilingue.sql` (copia los que falten) |
| Nombre del sitio, SEO, copyright, dirección, "sobre nosotros" | `theme-flex-home-<idioma>-…` | `ardenza-bilingue.sql` |

## Pasos

1. Exporta la base `u783834143_inmobil` (phpMyAdmin → Exportar).
2. phpMyAdmin → `u783834143_inmobil` → **Importar** → `ardenza-bilingue.sql` → Continuar.
   Al final muestra el idioma principal detectado, cuántas fichas tradujo y los menús de cada idioma.
3. Sube `es.json` a `public_html/inmobiliaria/lang/es.json` (reemplaza el anterior).
4. Sube `ardenza-lang-vendor.zip` a `public_html/inmobiliaria/lang/` y extráelo ahí: queda la carpeta
   `lang/vendor/plugins/…` junto a `es/`, `en/` y `es.json`. Estos archivos solo cambian las claves que
   traducen; el resto sigue saliendo de los originales del sistema.
5. Panel → Plataforma → **Limpiar caché** → "Limpiar todo el caché".

El script detecta cuál es el idioma principal (español o inglés) y llena el otro. Se puede ejecutar
más de una vez: no duplica menús, widgets ni traducciones.

## Qué no traduce

- Páginas con texto libre escrito a mano (por ejemplo "Sobre nosotros" si tiene párrafos propios):
  se editan en el panel → Páginas → elegir el idioma con la bandera.
- Descripción de los agentes y nombre de los desarrolladores: Botble no los traduce por idioma.

## Archivos

- `generar_bilingue.py` → `ardenza-bilingue.sql`. Diccionarios de títulos, menús, categorías y opciones.
- `contenido_en.py`: versión en inglés de las fichas demo (mismas claves que `fase4/generar_sql.py`).
- `terminos.py`: Términos y condiciones de Ardenza en español e inglés (revisar con un abogado).
- `generar_es_json.py` → `es.json`: textos fijos del tema y de los módulos.
- `modulos.py` + `generar_modulos.py` → `lang/vendor/plugins/…` y `ardenza-lang-vendor.zip`. Valida cada
  clave contra `origen/` (copia de los archivos en inglés del servidor). En el servidor, los archivos
  "inglés" del panel del agente estaban en español; `lang/vendor/plugins/real-estate/en/` los devuelve a inglés.
