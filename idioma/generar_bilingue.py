"""Genera idioma/ardenza-bilingue.sql: el sitio completo en español e inglés.

Botble guarda cada idioma en un lugar distinto:
  - propiedades, desarrollos, noticias, páginas, ubicaciones, categorías → tabla base (idioma
    principal) + tabla *_translations (otros idiomas; si está vacía se muestra el principal);
  - menús → un menú propio por idioma (language_meta);
  - widgets → filas propias por idioma (theme = 'flex-home-<código>'); sin ellas no se muestran;
  - opciones del tema → settings 'theme-flex-home-<código>-<clave>'.
El script detecta cuál es el idioma principal y llena el otro, sin depender de que sea español.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "fase4"))
sys.path.insert(0, HERE)

import contenido_en as en  # noqa: E402
import generar_sql as f4  # noqa: E402
import terminos  # noqa: E402

q = f4.q
MENU = "Botble\\Menu\\Models\\Menu"
MENU_NODE = "Botble\\Menu\\Models\\MenuNode"

# ---------------------------------------------------------------------------
# Diccionarios: (español, inglés, [otras formas que aparecen en la base])
# ---------------------------------------------------------------------------
ATTRS = [  # valores de title="…" / subtitle="…" en los bloques de las páginas
    ("Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.",
     "We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.",
     ["We make the best choices with the hottest and most prestigious projects, please visit the details below to find out more."]),
    ("Estas son las propiedades de lujo disponibles para compra",
     "Luxury properties currently available for purchase",
     ["Below is a list of properties that are currently up for sale"]),
    ("Estas son las residencias disponibles para renta",
     "Luxury residences currently available for rent",
     ["Below is a detailed price list of houses for rent"]),
    ("Guías y noticias para comprar e invertir en México, Costa Rica y Miami.",
     "Guides and news for buying and investing in Mexico, Costa Rica and Miami.",
     ["Below is the latest real estate news we get regularly updated from reliable sources."]),
    ("Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.",
     "Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.",
     ["Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful properties."]),
    ("Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.",
     "Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.",
     ["Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful projects."]),
    ("Encuentra la propiedad de tus sueños", "Find the home of your dreams", ["Find your favorite homes at Flex Home"]),
    ("Desarrollos destacados", "Featured developments", ["Featured projects", "Featured Projects", "Proyectos destacados"]),
    ("Propiedades en venta", "Properties for sale", ["Properties For Sale"]),
    ("Propiedades en renta", "Properties for rent", ["Properties For Rent", "Propiedades en arriendo"]),
    ("Agentes destacados", "Featured agents", ["Featured Agents"]),
    ("Propiedades destacadas", "Featured properties", ["Featured Properties"]),
    ("Desarrollos por ubicación", "Developments by location", ["Projects by locations", "Proyectos por ubicación"]),
    ("Propiedades por ubicación", "Properties by location", ["Properties by locations"]),
    ("Vistas recientemente", "Recently viewed", ["Recently Viewed Properties"]),
    ("Últimas noticias", "Latest news", ["Latest News"]),
    ("Noticias", "News", []),
    ("Contáctanos", "Contact us", ["Contact Us", "Contáctenos"]),
    ("Descubre nuestras propiedades", "Discover our properties", []),
    ("Descubre nuestros desarrollos", "Discover our developments", ["Discover our projects", "Descubre nuestros proyectos"]),
]

TITLES = [  # valores completos: nombres de páginas, opciones de menú, títulos de widgets, categorías del blog
    ("Inicio", "Home", []),
    ("Desarrollos", "Developments", ["Projects", "Proyectos"]),
    ("Propiedades", "Properties", []),
    ("Agentes", "Agents", ["Realtors", "Asesores"]),
    ("Noticias", "News", ["Blog"]),
    ("Empleos", "Careers", ["Trabaja con nosotros"]),
    ("Contacto", "Contact", []),
    ("Contáctanos", "Contact us", ["Contáctenos"]),
    ("Nosotros", "About us", ["About", "About Us", "Sobre nosotros", "Quiénes somos"]),
    ("Términos y condiciones", "Terms & Conditions", ["Terms and Conditions", "Terms Conditions", "Terms & conditions"]),
    ("Política de privacidad", "Privacy Policy", ["Privacy policy"]),
    ("Política de cookies", "Cookie Policy", ["Cookie policy", "Cookies Policy"]),
    ("Preguntas frecuentes", "FAQ", ["FAQs"]),
    ("En venta", "For sale", ["Sale", "Venta"]),
    ("En renta", "For rent", ["Rent", "Renta", "Arriendo"]),
    ("Propiedades en venta", "Properties for sale", ["Properties For Sale"]),
    ("Propiedades en renta", "Properties for rent", ["Properties For Rent"]),
    ("Enlaces rápidos", "Quick links", ["Quick Links"]),
    ("Enlaces útiles", "Useful links", ["Useful Links"]),
    ("Información", "Information", []),
    ("Categorías", "Categories", []),
    ("Artículos recientes", "Recent posts", ["Recent Posts"]),
    ("Últimas noticias", "Latest news", ["Latest News"]),
    ("Arquitectura", "Architecture", ["House architecture"]),
    ("Diseño de interiores", "Interior design", ["House design"]),
    ("Materiales de construcción", "Building materials", ["Building materials"]),
    ("Inversión", "Investment", []),
    ("Estilo de vida", "Lifestyle", []),
]

# Inmobiliario: categorías de propiedad, características y lugares cercanos (nombre exacto)
RE_CATEGORIES = [
    ("Departamento", "Apartment", ["Apartamento", "Apartamentos", "Departamentos"]),
    ("Villa", "Villa", ["Villas"]),
    ("Condominio", "Condo", ["Condos", "Condominios"]),
    ("Casa", "House", ["Casas", "Houses"]),
    ("Terreno", "Land", ["Lote", "Lotes", "Terrenos"]),
    ("Local comercial", "Commercial property", ["Local", "Locales", "Commercial"]),
    ("Oficina", "Office", ["Oficinas", "Offices"]),
    ("Penthouse", "Penthouse", []),
    ("Finca", "Farm", ["Fincas", "Rancho"]),
]
RE_FEATURES = [
    ("Wifi", "Wifi", ["Wi-Fi", "WiFi"]),
    ("Estacionamiento", "Parking", ["Parqueadero", "Garaje"]),
    ("Alberca", "Swimming pool", ["Piscina", "Pool"]),
    ("Balcón", "Balcony", []),
    ("Jardín", "Garden", []),
    ("Seguridad 24/7", "24/7 security", ["Security", "Seguridad", "Portería"]),
    ("Gimnasio", "Fitness center", ["Gym"]),
    ("Aire acondicionado", "Air conditioning", ["Air Conditioning"]),
    ("Calefacción central", "Central heating", ["Central Heating", "Calefacción"]),
    ("Cuarto de lavado", "Laundry room", ["Laundry Room", "Lavandería"]),
    ("Se aceptan mascotas", "Pets allowed", ["Pets Allow", "Pet friendly", "Mascotas"]),
    ("Spa y masajes", "Spa & massage", ["Spa & Massage"]),
    ("Elevador", "Elevator", ["Ascensor"]),
    ("Terraza", "Terrace", []),
    ("Vista al mar", "Ocean view", ["Sea view"]),
]
RE_FACILITIES = [
    ("Hospital", "Hospital", []),
    ("Supermercado", "Supermarket", ["Super Market"]),
    ("Escuela", "School", ["Colegio"]),
    ("Entretenimiento", "Entertainment", []),
    ("Farmacia", "Pharmacy", ["Droguería"]),
    ("Aeropuerto", "Airport", []),
    ("Estación de tren", "Train station", ["Railways"]),
    ("Parada de autobús", "Bus stop", ["Bus Stop", "Parada de bus"]),
    ("Playa", "Beach", []),
    ("Centro comercial", "Shopping mall", ["Mall"]),
    ("Banco", "Bank", []),
]

COUNTRIES = [("México", "Mexico", "Mexicana", "Mexican"), ("Costa Rica", "Costa Rica", "Costarricense", "Costa Rican"),
             ("Estados Unidos", "United States", "Estadounidense", "American")]
STATES = [("Ciudad de México", "Mexico City")]
CITIES = [("Ciudad de México", "Mexico City"), ("Cancún", "Cancun")]

OPTIONS = [  # opciones del tema con texto
    ("site_title", "Ardenza Propiedades", "Ardenza Estates"),
    ("seo_title", "Ardenza Propiedades · Propiedades de lujo en México, Costa Rica y Miami",
     "Ardenza Estates · Luxury real estate in Mexico, Costa Rica and Miami"),
    ("seo_description",
     "Casas, departamentos y residencias de lujo en México, Costa Rica y Miami. Propiedades seleccionadas y publicadas por realtors verificados. Un portal de FLAMIA.",
     "Luxury homes, condos and residences in Mexico, Costa Rica and Miami. Curated properties listed by verified realtors. A FLAMIA portal."),
    ("copyright", "© 2026 Ardenza Propiedades · by FLAMIA Group. Todos los derechos reservados.",
     "© 2026 Ardenza Estates · by FLAMIA Group. All rights reserved."),
    ("address", "Heredia, Costa Rica · México · Miami", "Heredia, Costa Rica · Mexico · Miami"),
    ("about-us",
     "Ardenza Propiedades es el portal de propiedades de lujo de FLAMIA en México, Costa Rica y Miami. Cada propiedad es publicada por realtors verificados y revisada antes de salir en el sitio.",
     "Ardenza Estates is FLAMIA's luxury real estate portal in Mexico, Costa Rica and Miami. Every property is listed by verified realtors and reviewed before it goes live."),
]
OPTIONS_IF_SET = [("home_banner_description", "Encuentra la propiedad de tus sueños", "Find the home of your dreams")]


def json_forms(s):
    """Formas en que un texto puede aparecer dentro del JSON de un widget (PHP json_encode)."""
    esc = json.dumps(s, ensure_ascii=True)[1:-1].replace("/", "\\/")
    return [s] if esc == s else [s, esc]


def pairs(rows):
    """(forma encontrada, español, inglés) para cada concepto y cada forma conocida."""
    out = []
    for es, en_, alts in rows:
        for src in dict.fromkeys([es, en_] + alts):
            out.append((src, es, en_))
    return out


def values(rows):
    return ",\n  ".join("(" + ", ".join(q(v) for v in r) + ")" for r in rows)


def table(name, cols, rows):
    defs = ", ".join(f"{c} {t}" for c, t in cols)
    return (f"DROP TABLE IF EXISTS {name};\n"
            f"CREATE TABLE {name} ({defs}) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n"
            f"INSERT INTO {name} ({', '.join(c for c, _ in cols)}) VALUES\n  {values(rows)};")


def content_rows():
    rows = []
    for t in f4.PROPERTIES:
        e = en.PROPERTIES[t[0]]
        rows.append(("prop", t[0], t[1], e[0], t[10], e[2], t[11], e[3], t[9], e[1]))
    for t in f4.PROJECTS:
        e = en.PROJECTS[t[0]]
        rows.append(("proj", t[0], t[1], e[0], t[9], e[2], t[10], e[3], t[8], e[1]))
    for t in f4.POSTS:
        e = en.POSTS[t[0]]
        rows.append(("post", t[0], t[1], e[0], t[2], e[1], t[3], e[2], None, None))
    return rows


# Para cada tipo de contenido: (clave, tabla, tabla de traducción, columna id, modelo en slugs, columnas extra)
CONTENT = [
    ("prop", "re_properties", "re_properties_translations", "re_properties_id", "%RealEstate%Models%Property", True),
    ("proj", "re_projects", "re_projects_translations", "re_projects_id", "%RealEstate%Models%Project", True),
    ("post", "posts", "posts_translations", "posts_id", "%Blog%Models%Post", False),
]


def content_sql():
    out = [table("ard_t", [("kind", "VARCHAR(10)"), ("slug", "VARCHAR(190)"), ("es_name", "VARCHAR(300)"), ("en_name", "VARCHAR(300)"),
                           ("es_desc", "VARCHAR(400)"), ("en_desc", "VARCHAR(400)"), ("es_content", "LONGTEXT"), ("en_content", "LONGTEXT"),
                           ("es_loc", "VARCHAR(255)"), ("en_loc", "VARCHAR(255)")], content_rows())]
    out.append("""DROP TABLE IF EXISTS ard_m;
CREATE TABLE ard_m (kind VARCHAR(10), ref_id BIGINT UNSIGNED, slug VARCHAR(190), sfx VARCHAR(60) DEFAULT '', PRIMARY KEY (kind, ref_id))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;""")
    for kind, tbl, tr, fk, model, has_loc in CONTENT:
        loc_cols = ", location" if has_loc else ""
        loc_vals = ", IF(@def_en, t.es_loc, t.en_loc)" if has_loc else ""
        loc_set = "\n    b.location = t.en_loc," if has_loc else ""
        out.append(f"""-- {tbl}
INSERT IGNORE INTO ard_m (kind, ref_id, slug)
SELECT '{kind}', s.reference_id, t.slug FROM slugs s
JOIN ard_t t ON t.kind = '{kind}' AND (s.`key` = t.slug OR s.`key` = CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '{model}';
-- Sufijo de las copias (« · 2», « · Fase 2», « (2)») para conservarlo en el otro idioma.
UPDATE ard_m m JOIN {tbl} b ON b.id = m.ref_id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET m.sfx = CASE WHEN b.name LIKE CONCAT(t.es_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.es_name) + 1)
                 WHEN b.name LIKE CONCAT(t.en_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.en_name) + 1)
                 ELSE '' END
WHERE m.kind = '{kind}';
DELETE tr FROM {tr} tr
JOIN ard_m m ON m.kind = '{kind}' AND m.ref_id = tr.{fk}
JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO {tr} (lang_code, {fk}, name, description, content{loc_cols})
SELECT o.code, m.ref_id, CONCAT(IF(@def_en, t.es_name, t.en_name), m.sfx), IF(@def_en, t.es_desc, t.en_desc),
       IF(@def_en, t.es_content, t.en_content){loc_vals}
FROM ard_m m JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug JOIN ard_lang o ON o.k = 'otro'
WHERE m.kind = '{kind}';
-- Solo si el idioma principal es inglés: la tabla base pasa a inglés.
UPDATE {tbl} b JOIN ard_m m ON m.kind = '{kind}' AND m.ref_id = b.id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET b.description = t.en_desc, b.content = t.en_content,{loc_set}
    b.name = CONCAT(t.en_name, m.sfx)
WHERE @def_en = 1;""")
    return "\n".join(out)


def bilingual_name_sql(kind, tbl, tr, fk, extra_tr_cols=""):
    """Nombres exactos (categorías, características…): base en el idioma principal, traducción en el otro."""
    extra_sel = "".join(f", b.{c}" for c in extra_tr_cols.split(",") if c) if extra_tr_cols else ""
    extra_ins = "".join(f", {c}" for c in extra_tr_cols.split(",") if c) if extra_tr_cols else ""
    return f"""  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = '{tr}') THEN
    DELETE tr FROM {tr} tr
    JOIN {tbl} b ON b.id = tr.{fk} JOIN ard_d d ON d.kind = '{kind}' AND d.src = b.name
    JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
    INSERT INTO {tr} (lang_code, {fk}, name{extra_ins})
    SELECT o.code, b.id, IF(@def_en, d.es, d.en){extra_sel}
    FROM {tbl} b JOIN ard_d d ON d.kind = '{kind}' AND d.src = b.name JOIN ard_lang o ON o.k = 'otro'
    GROUP BY b.id;
    UPDATE {tbl} b JOIN ard_d d ON d.kind = '{kind}' AND d.src = b.name SET b.name = IF(@def_en, d.en, d.es);
  END IF;"""


def build():
    sql = ["""-- =====================================================================
-- ARDENZA · Sitio completo en español e inglés
--
-- Al cambiar de idioma, Botble lee cada parte del sitio de un lugar distinto.
-- Este script llena el idioma que falta en todas ellas:
--   1. Propiedades, desarrollos y noticias (nombre, descripción, contenido, ubicación).
--   2. Países, estados, ciudades, categorías, características y lugares cercanos.
--   3. Páginas: títulos y frases del inicio, nombres de páginas y Términos y condiciones.
--   4. Menús: crea el menú del otro idioma si no existe y traduce sus opciones.
--   5. Widgets del pie de página en cada idioma.
--   6. Opciones del tema por idioma (nombre, SEO, copyright, dirección, "sobre nosotros").
-- Detecta solo cuál es el idioma principal (español o inglés).
--
-- ANTES: exporta la base u783834143_inmobil (phpMyAdmin → Exportar).
-- Ejecutar en phpMyAdmin → u783834143_inmobil → Importar (este archivo).
-- DESPUÉS: panel → Plataforma → Limpiar caché → "Limpiar todo el caché".
-- =====================================================================
SET NAMES utf8mb4;

-- 0. Idiomas del sitio -------------------------------------------------------
DROP TABLE IF EXISTS ard_lang;
CREATE TABLE ard_lang (k VARCHAR(10) PRIMARY KEY, code VARCHAR(20)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_lang SELECT 'def', lang_code FROM languages WHERE lang_is_default = 1 ORDER BY lang_order LIMIT 1;
INSERT INTO ard_lang SELECT 'en', lang_code FROM languages WHERE lang_locale LIKE 'en%' OR lang_code LIKE 'en%' ORDER BY lang_is_default DESC, lang_order LIMIT 1;
INSERT INTO ard_lang SELECT 'es', lang_code FROM languages WHERE lang_locale LIKE 'es%' OR lang_code LIKE 'es%' ORDER BY lang_is_default DESC, lang_order LIMIT 1;
SET @def_en = (SELECT COUNT(*) FROM ard_lang d JOIN ard_lang e ON e.k = 'en' AND e.code = d.code WHERE d.k = 'def');
INSERT INTO ard_lang SELECT 'otro', code FROM ard_lang WHERE k = IF(@def_en = 1, 'es', 'en');
"""]

    sql.append("-- 1. Propiedades, desarrollos y noticias ------------------------------------")
    sql.append(content_sql())

    sql.append("\n-- 2. Ubicaciones -------------------------------------------------------------")
    sql.append(table("ard_loc", [("kind", "VARCHAR(10)"), ("es", "VARCHAR(120)"), ("en", "VARCHAR(120)"),
                                 ("es_nat", "VARCHAR(120)"), ("en_nat", "VARCHAR(120)")],
                     [("country",) + c for c in COUNTRIES] + [("state", a, b, None, None) for a, b in STATES]
                     + [("city", a, b, None, None) for a, b in CITIES]))
    sql.append("""DELETE tr FROM countries_translations tr JOIN countries b ON b.id = tr.countries_id
JOIN ard_loc l ON l.kind = 'country' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO countries_translations (lang_code, countries_id, name, nationality)
SELECT o.code, b.id, IF(@def_en, l.es, l.en), IF(@def_en, l.es_nat, l.en_nat)
FROM countries b JOIN ard_loc l ON l.kind = 'country' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro';
UPDATE countries b JOIN ard_loc l ON l.kind = 'country' AND (b.name = l.es OR b.name = l.en)
SET b.nationality = IF(@def_en, l.en_nat, l.es_nat), b.name = IF(@def_en, l.en, l.es);
DELETE tr FROM states_translations tr JOIN states b ON b.id = tr.states_id
JOIN ard_loc l ON l.kind = 'state' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO states_translations (lang_code, states_id, name)
SELECT o.code, b.id, IF(@def_en, l.es, l.en)
FROM states b JOIN ard_loc l ON l.kind = 'state' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro';
UPDATE states b JOIN ard_loc l ON l.kind = 'state' AND (b.name = l.es OR b.name = l.en) SET b.name = IF(@def_en, l.en, l.es);
DELETE tr FROM cities_translations tr JOIN cities b ON b.id = tr.cities_id
JOIN ard_loc l ON l.kind = 'city' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO cities_translations (lang_code, cities_id, name)
SELECT o.code, b.id, IF(@def_en, l.es, l.en)
FROM cities b JOIN ard_loc l ON l.kind = 'city' AND (b.name = l.es OR b.name = l.en) JOIN ard_lang o ON o.k = 'otro';
UPDATE cities b JOIN ard_loc l ON l.kind = 'city' AND (b.name = l.es OR b.name = l.en) SET b.name = IF(@def_en, l.en, l.es);
""")

    sql.append("-- 2b. Categorías, características, lugares cercanos y categorías del blog -------")
    d_rows = ([("recat",) + r for r in pairs(RE_CATEGORIES)] + [("refeat",) + r for r in pairs(RE_FEATURES)]
              + [("refac",) + r for r in pairs(RE_FACILITIES)] + [("blogcat",) + r for r in pairs(TITLES)])
    sql.append(table("ard_d", [("kind", "VARCHAR(10)"), ("src", "VARCHAR(190)"), ("es", "VARCHAR(190)"), ("en", "VARCHAR(190)")], d_rows))
    sql.append("DROP PROCEDURE IF EXISTS ard_nombres;\nDELIMITER $$\nCREATE PROCEDURE ard_nombres()\nBEGIN")
    sql.append(bilingual_name_sql("recat", "re_categories", "re_categories_translations", "re_categories_id", "description"))
    sql.append(bilingual_name_sql("refeat", "re_features", "re_features_translations", "re_features_id"))
    sql.append(bilingual_name_sql("refac", "re_facilities", "re_facilities_translations", "re_facilities_id"))
    sql.append(bilingual_name_sql("blogcat", "categories", "categories_translations", "categories_id", "description"))
    sql.append("END$$\nDELIMITER ;\nCALL ard_nombres();\nDROP PROCEDURE ard_nombres;\n")

    sql.append("-- 3. Páginas -----------------------------------------------------------------")
    p_rows = ([("attr",) + r for r in pairs(ATTRS)]
              + [("title",) + r for r in pairs(TITLES)])
    w_rows = []
    for src, es, en_ in pairs(TITLES) + pairs(ATTRS):
        for form in json_forms(src):
            w_rows.append(("widget", form, es, en_))
    sql.append("DROP TABLE IF EXISTS ard_p;\n"
               "CREATE TABLE ard_p (n INT AUTO_INCREMENT PRIMARY KEY, scope VARCHAR(10), src VARCHAR(400), es VARCHAR(400), en VARCHAR(400))\n"
               "  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n"
               "INSERT INTO ard_p (scope, src, es, en) VALUES\n  " + values(p_rows + w_rows) + ";")
    terms_slug = "terms-conditions"
    sql.append(f"""-- Cada página tiene su versión en el otro idioma (copia de la principal, que luego se traduce).
INSERT INTO pages_translations (lang_code, pages_id, name, description, content)
SELECT o.code, p.id, p.name, p.description, p.content FROM pages p JOIN ard_lang o ON o.k = 'otro'
WHERE NOT EXISTS (SELECT 1 FROM pages_translations t WHERE t.pages_id = p.id AND t.lang_code = o.code);

-- Términos y condiciones con la marca.
DROP TABLE IF EXISTS ard_terms;
CREATE TABLE ard_terms (id BIGINT UNSIGNED PRIMARY KEY) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO ard_terms SELECT reference_id FROM slugs WHERE `key` = {q(terms_slug)} AND reference_type LIKE '%Page%Models%Page';
UPDATE pages p JOIN ard_terms x ON x.id = p.id
SET p.name = IF(@def_en, {q(terminos.EN_NAME)}, {q(terminos.ES_NAME)}),
    p.content = IF(@def_en, {q(terminos.EN)}, {q(terminos.ES)}),
    p.description = NULL;
UPDATE pages_translations t JOIN ard_terms x ON x.id = t.pages_id JOIN ard_lang o ON o.k = 'otro' AND o.code = t.lang_code
SET t.name = IF(@def_en, {q(terminos.ES_NAME)}, {q(terminos.EN_NAME)}),
    t.content = IF(@def_en, {q(terminos.ES)}, {q(terminos.EN)}),
    t.description = NULL;

-- Títulos y frases de los bloques (title="…", subtitle="…") y nombres de páginas, en el idioma de cada versión.
DROP PROCEDURE IF EXISTS ard_paginas;
DELIMITER $$
CREATE PROCEDURE ard_paginas()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_scope VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE v_src, v_es, v_en, v_base VARCHAR(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE cur CURSOR FOR SELECT scope, src, es, en FROM ard_p ORDER BY CHAR_LENGTH(src) DESC, n;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  OPEN cur;
  l: LOOP
    FETCH cur INTO v_scope, v_src, v_es, v_en;
    IF done THEN LEAVE l; END IF;
    SET v_base = IF(@def_en, v_en, v_es);
    IF v_scope = 'attr' THEN
      UPDATE pages SET content = REPLACE(REPLACE(content,
          CONCAT('="', v_src, '"'), CONCAT('="', v_base, '"')),
          CONCAT('=&quot;', v_src, '&quot;'), CONCAT('=&quot;', v_base, '&quot;'))
        WHERE content LIKE CONCAT('%', v_src, '%');
      UPDATE pages_translations t JOIN ard_lang l ON l.k IN ('en', 'es') AND l.code = t.lang_code
        SET t.content = REPLACE(REPLACE(t.content,
          CONCAT('="', v_src, '"'), CONCAT('="', IF(l.k = 'en', v_en, v_es), '"')),
          CONCAT('=&quot;', v_src, '&quot;'), CONCAT('=&quot;', IF(l.k = 'en', v_en, v_es), '&quot;'))
        WHERE t.content LIKE CONCAT('%', v_src, '%');
    ELSEIF v_scope = 'title' THEN
      UPDATE pages SET name = v_base WHERE name = v_src;
      UPDATE pages_translations t JOIN ard_lang l ON l.k IN ('en', 'es') AND l.code = t.lang_code
        SET t.name = IF(l.k = 'en', v_en, v_es) WHERE t.name = v_src;
    END IF;
  END LOOP;
  CLOSE cur;
END$$
DELIMITER ;
CALL ard_paginas();
DROP PROCEDURE ard_paginas;
""")

    sql.append(f"""-- 4. Menús: uno por idioma ------------------------------------------------------
-- Si un menú no tiene versión en el otro idioma, se copia con sus opciones y ubicaciones.
DROP TABLE IF EXISTS ard_menu_copia;
CREATE TABLE ard_menu_copia (old_slug VARCHAR(190), new_slug VARCHAR(190), code VARCHAR(20))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TABLE IF EXISTS ard_nodo;
CREATE TABLE ard_nodo (old_id BIGINT UNSIGNED PRIMARY KEY, new_id BIGINT UNSIGNED) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP PROCEDURE IF EXISTS ard_menus;
DELIMITER $$
CREATE PROCEDURE ard_menus()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_menu, v_new, v_node, v_new_node BIGINT UNSIGNED;
  DECLARE v_origin, v_code, v_slug VARCHAR(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE cur CURSOR FOR
    SELECT m.id, lm.lang_meta_origin, IF(lm.lang_meta_code = le.code, ls.code, le.code), m.slug
    FROM menus m
    JOIN language_meta lm ON lm.reference_id = m.id AND lm.reference_type = {q(MENU)}
    JOIN ard_lang le ON le.k = 'en' JOIN ard_lang ls ON ls.k = 'es'
    WHERE lm.lang_meta_code IN (le.code, ls.code)
      AND NOT EXISTS (SELECT 1 FROM language_meta x
                      WHERE x.reference_type = {q(MENU)} AND x.lang_meta_origin = lm.lang_meta_origin
                        AND x.lang_meta_code = IF(lm.lang_meta_code = le.code, ls.code, le.code));
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  OPEN cur;
  l: LOOP
    FETCH cur INTO v_menu, v_origin, v_code, v_slug;
    IF done THEN LEAVE l; END IF;
    SET v_slug = CONCAT(v_slug, '-', LOWER(LEFT(v_code, 2)));
    IF EXISTS (SELECT 1 FROM menus WHERE slug = v_slug) THEN SET v_slug = CONCAT(v_slug, '-', v_menu); END IF;
    INSERT INTO menus (name, slug, status, created_at, updated_at)
      SELECT CONCAT(name, ' (', UPPER(LEFT(v_code, 2)), ')'), v_slug, status, NOW(), NOW() FROM menus WHERE id = v_menu;
    SET v_new = LAST_INSERT_ID();
    INSERT INTO ard_menu_copia SELECT slug, v_slug, v_code FROM menus WHERE id = v_menu;
    INSERT INTO language_meta (lang_meta_code, lang_meta_origin, reference_id, reference_type)
      VALUES (v_code, v_origin, v_new, {q(MENU)});
    INSERT INTO menu_locations (menu_id, location, created_at, updated_at)
      SELECT v_new, location, NOW(), NOW() FROM menu_locations WHERE menu_id = v_menu;
    DELETE FROM ard_nodo;
    BEGIN
      DECLARE done2 INT DEFAULT 0;
      DECLARE cur2 CURSOR FOR SELECT id FROM menu_nodes WHERE menu_id = v_menu ORDER BY id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = 1;
      OPEN cur2;
      l2: LOOP
        FETCH cur2 INTO v_node;
        IF done2 THEN LEAVE l2; END IF;
        INSERT INTO menu_nodes (menu_id, parent_id, reference_id, reference_type, url, icon_font, position, title,
                                css_class, target, has_child, created_at, updated_at)
          SELECT v_new, parent_id, reference_id, reference_type, url, icon_font, position, title,
                 css_class, target, has_child, NOW(), NOW() FROM menu_nodes WHERE id = v_node;
        SET v_new_node = LAST_INSERT_ID();
        INSERT INTO ard_nodo VALUES (v_node, v_new_node);
        INSERT INTO language_meta (lang_meta_code, lang_meta_origin, reference_id, reference_type)
          SELECT v_code, lang_meta_origin, v_new_node, reference_type FROM language_meta
          WHERE reference_id = v_node AND reference_type = {q(MENU_NODE)};
      END LOOP;
      CLOSE cur2;
    END;
    UPDATE menu_nodes n JOIN ard_nodo m ON m.old_id = n.parent_id SET n.parent_id = m.new_id WHERE n.menu_id = v_new;
  END LOOP;
  CLOSE cur;
END$$
DELIMITER ;
CALL ard_menus();
DROP PROCEDURE ard_menus;

-- Opciones de cada menú en su idioma (los menús sin idioma asignado cuentan como el principal).
UPDATE menu_nodes n
JOIN ard_p p ON p.scope = 'title' AND p.src = n.title
LEFT JOIN language_meta lm ON lm.reference_id = n.menu_id AND lm.reference_type = {q(MENU)}
LEFT JOIN ard_lang le ON le.k = 'en'
SET n.title = IF(COALESCE(lm.lang_meta_code = le.code, @def_en = 1), p.en, p.es);
""")

    sql.append("""-- 5. Widgets del pie de página ---------------------------------------------------
-- El otro idioma no muestra ningún widget si no tiene los suyos: se copian los del principal.
INSERT INTO widgets (widget_id, sidebar_id, theme, position, data, created_at, updated_at)
SELECT w.widget_id, w.sidebar_id, CONCAT(w.theme, '-', o.code), w.position, w.data, NOW(), NOW()
FROM widgets w JOIN ard_lang o ON o.k = 'otro'
WHERE w.theme = 'flex-home'
  AND NOT EXISTS (SELECT 1 FROM widgets x WHERE x.theme = CONCAT('flex-home-', o.code));
DROP PROCEDURE IF EXISTS ard_widgets;
DELIMITER $$
CREATE PROCEDURE ard_widgets()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_src, v_es, v_en VARCHAR(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE v_code VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE cur_m CURSOR FOR SELECT old_slug, new_slug, code FROM ard_menu_copia;
  DECLARE cur CURSOR FOR SELECT src, es, en FROM ard_p WHERE scope = 'widget' ORDER BY CHAR_LENGTH(src) DESC, n;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  -- Los widgets de menú del otro idioma apuntan a la copia del menú.
  OPEN cur_m;
  m: LOOP
    FETCH cur_m INTO v_src, v_es, v_code;
    IF done THEN LEAVE m; END IF;
    UPDATE widgets SET data = REPLACE(data, CONCAT('"menu_id":"', v_src, '"'), CONCAT('"menu_id":"', v_es, '"'))
    WHERE theme = CONCAT('flex-home-', v_code);
  END LOOP;
  CLOSE cur_m;
  SET done = 0;
  -- Títulos de los widgets en el idioma de cada versión.
  OPEN cur;
  l: LOOP
    FETCH cur INTO v_src, v_es, v_en;
    IF done THEN LEAVE l; END IF;
    UPDATE widgets w LEFT JOIN ard_lang le ON le.k = 'en' LEFT JOIN ard_lang ls ON ls.k = 'es'
    SET w.data = REPLACE(w.data, CONCAT('"', v_src, '"'), CONCAT('"',
          CASE WHEN w.theme = CONCAT('flex-home-', le.code) THEN v_en
               WHEN w.theme = CONCAT('flex-home-', ls.code) THEN v_es
               WHEN @def_en = 1 THEN v_en ELSE v_es END, '"'))
    WHERE w.theme LIKE 'flex-home%';
  END LOOP;
  CLOSE cur;
END$$
DELIMITER ;
CALL ard_widgets();
DROP PROCEDURE ard_widgets;
""")

    sql.append("-- 6. Opciones del tema por idioma -----------------------------------------------")
    sql.append(table("ard_opt", [("k", "VARCHAR(120)"), ("es", "TEXT"), ("en", "TEXT")], OPTIONS))
    sql.append(table("ard_opt_si", [("k", "VARCHAR(120)"), ("es", "TEXT"), ("en", "TEXT")], OPTIONS_IF_SET))
    sql.append("""INSERT INTO settings (`key`, value)
SELECT CONCAT('theme-flex-home-', k), IF(@def_en, en, es) FROM ard_opt
ON DUPLICATE KEY UPDATE value = VALUES(value);
INSERT INTO settings (`key`, value)
SELECT CONCAT('theme-flex-home-', o.code, '-', a.k), IF(@def_en, a.es, a.en) FROM ard_opt a JOIN ard_lang o ON o.k = 'otro'
ON DUPLICATE KEY UPDATE value = VALUES(value);
-- Versiones por idioma que ya existían (cualquier idioma): cada una en su idioma.
UPDATE settings s JOIN ard_opt a ON s.`key` REGEXP CONCAT('^theme-flex-home-[A-Za-z_]+-', a.k, '$')
JOIN ard_lang le ON le.k = 'en'
SET s.value = IF(s.`key` = CONCAT('theme-flex-home-', le.code, '-', a.k), a.en, a.es);
UPDATE settings s JOIN ard_opt_si a ON s.`key` = CONCAT('theme-flex-home-', a.k)
SET s.value = IF(@def_en, a.en, a.es) WHERE s.value IS NOT NULL AND s.value <> '';
UPDATE settings s JOIN ard_opt_si a ON s.`key` REGEXP CONCAT('^theme-flex-home-[A-Za-z_]+-', a.k, '$')
JOIN ard_lang le ON le.k = 'en'
SET s.value = IF(s.`key` = CONCAT('theme-flex-home-', le.code, '-', a.k), a.en, a.es) WHERE s.value IS NOT NULL AND s.value <> '';
""")

    sql.append("""-- 7. Resumen ---------------------------------------------------------------------
SELECT
  (SELECT code FROM ard_lang WHERE k = 'def') AS idioma_principal,
  (SELECT code FROM ard_lang WHERE k = 'otro') AS idioma_traducido,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'prop') AS propiedades,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'proj') AS desarrollos,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'post') AS noticias,
  (SELECT COUNT(*) FROM ard_terms) AS pagina_terminos,
  (SELECT COUNT(*) FROM ard_menu_copia) AS menus_creados;
SELECT m.name AS menu, lm.lang_meta_code AS idioma, GROUP_CONCAT(n.title ORDER BY n.position SEPARATOR ' · ') AS opciones
FROM menus m LEFT JOIN language_meta lm ON lm.reference_id = m.id AND lm.reference_type = 'Botble\\\\Menu\\\\Models\\\\Menu'
LEFT JOIN menu_nodes n ON n.menu_id = m.id AND n.parent_id = 0
GROUP BY m.id, lm.lang_meta_code;

DROP TABLE IF EXISTS ard_lang, ard_t, ard_m, ard_loc, ard_d, ard_p, ard_terms, ard_menu_copia, ard_nodo, ard_opt, ard_opt_si;
""")
    return "\n".join(sql)


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "ardenza-bilingue.sql")
    with open(out, "w", encoding="utf-8") as f:
        f.write(build())
    print("ok", out)
