"""Genera fase4/ardenza-demo-contenido.sql para Botble Real Estate (Flex Home).

Reescribe el contenido demo de Colombia como demo de Ardenza Propiedades
(México, Costa Rica y Miami) conservando las mismas imágenes.
"""
import sys

DEMO = "<p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>"


def q(s):
    if s is None:
        return "NULL"
    if isinstance(s, (int, float)):
        return str(s)
    return "'" + str(s).replace("\\", "\\\\").replace("'", "''") + "'"


# país: (clave, nombre, nacionalidad, orden, por_defecto)
COUNTRIES = [
    ("mx", "México", "Mexicana", 1, 1),
    ("cr", "Costa Rica", "Costarricense", 2, 0),
    ("us", "Estados Unidos", "Estadounidense", 3, 0),
]

# estado: (clave, nombre, abreviatura, país, slug)
STATES = [
    ("qroo", "Quintana Roo", "QROO", "mx", "quintana-roo"),
    ("cdmx", "Ciudad de México", "CDMX", "mx", "ciudad-de-mexico-estado"),
    ("bcs", "Baja California Sur", "BCS", "mx", "baja-california-sur"),
    ("jal", "Jalisco", "JAL", "mx", "jalisco"),
    ("gte", "Guanacaste", "GTE", "cr", "guanacaste"),
    ("pun", "Puntarenas", "PUN", "cr", "puntarenas"),
    ("sjo", "San José", "SJ", "cr", "san-jose-cr"),
    ("her", "Heredia", "HER", "cr", "heredia-provincia"),
    ("fl", "Florida", "FL", "us", "florida"),
]

# ciudad: (slug, nombre, estado, lat, lng)
CITIES = [
    ("tulum", "Tulum", "qroo", 20.2114, -87.4654),
    ("playa-del-carmen", "Playa del Carmen", "qroo", 20.6296, -87.0739),
    ("cancun", "Cancún", "qroo", 21.1619, -86.8515),
    ("ciudad-de-mexico", "Ciudad de México", "cdmx", 19.4326, -99.1332),
    ("los-cabos", "Los Cabos", "bcs", 22.8905, -109.9167),
    ("puerto-vallarta", "Puerto Vallarta", "jal", 20.6534, -105.2253),
    ("tamarindo", "Tamarindo", "gte", 10.2993, -85.8371),
    ("santa-teresa", "Santa Teresa", "pun", 9.6431, -85.1690),
    ("escazu", "Escazú", "sjo", 9.9189, -84.1395),
    ("heredia", "Heredia", "her", 9.9981, -84.1170),
    ("miami", "Miami", "fl", 25.7617, -80.1918),
    ("miami-beach", "Miami Beach", "fl", 25.7907, -80.1300),
    ("key-biscayne", "Key Biscayne", "fl", 25.6937, -80.1628),
    ("coral-gables", "Coral Gables", "fl", 25.7215, -80.2684),
]


def body(intro, details, highlights):
    items = "".join(f"<li>{h}</li>" for h in highlights)
    return f"<p>{intro}</p><p>{details}</p><ul>{items}</ul>{DEMO}"


# propiedad: (slug, nombre, ciudad, tipo, recámaras, baños, pisos, m2, precio, ubicación, descripción, contenido)
PROPERTIES = [
    ("villa-selva-tulum", "Villa Selva con alberca privada", "tulum", "sale", 4, 4, 2, 420, 1250000,
     "Región 15, Tulum, Quintana Roo, México",
     "Villa de cuatro recámaras rodeada de selva, a diez minutos de las playas de Tulum.",
     body("Arquitectura contemporánea en chukum y madera tropical, integrada a la selva maya.",
          "La planta baja abre por completo hacia la alberca y el jardín; la planta alta concentra las recámaras con terrazas privadas.",
          ["Alberca privada y jardín", "Roof garden con vista a la selva", "Paneles solares y cisterna", "A 10 minutos de la zona hotelera"])),
    ("penthouse-aldea-zama-tulum", "Penthouse en Aldea Zamá con roof privado", "tulum", "sale", 3, 3, 1, 210, 890000,
     "Aldea Zamá, Tulum, Quintana Roo, México",
     "Penthouse con terraza privada y jacuzzi en la zona residencial más buscada de Tulum.",
     body("Penthouse de tres recámaras en un condominio boutique de solo doce unidades.",
          "Terraza privada con jacuzzi y cocina exterior, ideal para renta vacacional o residencia.",
          ["Jacuzzi en el roof", "Amenidades tipo hotel", "Administración de rentas disponible", "Entrega inmediata"])),
    ("departamento-playacar", "Departamento en Playacar con vista al mar", "playa-del-carmen", "sale", 2, 2, 1, 140, 485000,
     "Playacar Fase I, Playa del Carmen, Quintana Roo, México",
     "Departamento frente al mar dentro de Playacar, a pasos de la Quinta Avenida.",
     body("Vista abierta al Caribe desde la sala y la recámara principal.",
          "Condominio con seguridad 24 horas, alberca infinity y acceso directo a la playa.",
          ["Acceso directo a la playa", "Alberca infinity", "Seguridad 24/7", "A 5 minutos de la Quinta Avenida"])),
    ("residencia-puerto-cancun", "Residencia en Puerto Cancún con muelle", "cancun", "sale", 5, 6, 2, 650, 2900000,
     "Puerto Cancún, Cancún, Quintana Roo, México",
     "Residencia frente a la marina con muelle privado para yate.",
     body("Casa de cinco recámaras en el desarrollo residencial más exclusivo de Cancún.",
          "Doble altura en áreas sociales, cocina de chef y estancia frente al canal.",
          ["Muelle privado", "Club de golf y marina", "Elevador", "Cuarto de servicio"])),
    ("penthouse-polanco", "Penthouse en Polanco con terraza panorámica", "ciudad-de-mexico", "sale", 3, 3, 1, 280, 1350000,
     "Polanco V Sección, Ciudad de México, México",
     "Penthouse de lujo a una cuadra de Masaryk, con terraza de 80 m².",
     body("Acabados en mármol y madera de nogal, con vista abierta a Chapultepec.",
          "Edificio con lobby con concierge, gimnasio y dos lugares de estacionamiento.",
          ["Terraza de 80 m²", "Concierge 24/7", "Cava y cuarto de servicio", "A una cuadra de Masaryk"])),
    ("loft-condesa", "Loft de diseño en la Condesa", "ciudad-de-mexico", "rent", 1, 1, 1, 95, 3200,
     "Condesa, Ciudad de México, México",
     "Loft amueblado en edificio art déco restaurado, frente al Parque México.",
     body("Loft de doble altura con mobiliario de diseño mexicano.",
          "Renta mensual con servicios incluidos, ideal para ejecutivos y nómadas digitales.",
          ["Amueblado y equipado", "Servicios incluidos", "Frente al Parque México", "Contrato mínimo de 6 meses"])),
    ("villa-pedregal-los-cabos", "Villa en Pedregal con vista al mar de Cortés", "los-cabos", "sale", 5, 5, 3, 520, 4200000,
     "El Pedregal, Cabo San Lucas, Baja California Sur, México",
     "Villa sobre el acantilado con vista al Arco y al océano Pacífico.",
     body("Villa de cinco recámaras en la comunidad privada de El Pedregal.",
          "Alberca infinity, terrazas escalonadas y atardeceres sobre el Pacífico.",
          ["Vista al Arco", "Alberca infinity", "Comunidad con acceso controlado", "A 5 minutos de la marina"])),
    ("condominio-conchas-chinas", "Condominio en Conchas Chinas frente a la bahía", "puerto-vallarta", "sale", 3, 3, 1, 230, 980000,
     "Conchas Chinas, Puerto Vallarta, Jalisco, México",
     "Condominio frente a la Bahía de Banderas, a minutos de la Zona Romántica.",
     body("Tres recámaras con vista panorámica a la Bahía de Banderas.",
          "Edificio con alberca, gimnasio y acceso a playa privada.",
          ["Vista a la bahía", "Playa privada", "Alberca y gimnasio", "A 5 minutos de la Zona Romántica"])),
    ("casa-playa-tamarindo", "Casa de playa en Tamarindo", "tamarindo", "sale", 4, 4, 2, 380, 1450000,
     "Playa Langosta, Tamarindo, Guanacaste, Costa Rica",
     "Casa a pasos de Playa Langosta, en una de las costas más buscadas de Guanacaste.",
     body("Diseño tropical moderno con grandes ventanales y ventilación cruzada.",
          "Jardín con palmeras, alberca y rancho exterior para disfrutar el atardecer.",
          ["A pasos de la playa", "Alberca y rancho", "Título inscrito", "A 30 minutos del aeropuerto de Liberia"])),
    ("villa-surf-santa-teresa", "Villa de surf en Santa Teresa", "santa-teresa", "sale", 3, 3, 1, 300, 1100000,
     "Santa Teresa, Puntarenas, Costa Rica",
     "Villa con vista al océano en las colinas de Santa Teresa, destino de surf de clase mundial.",
     body("Tres suites independientes ideales para renta vacacional.",
          "Vista al Pacífico desde todas las habitaciones y a cinco minutos de la playa.",
          ["Vista al océano", "Ideal para renta vacacional", "Alberca infinity", "A 5 minutos de la playa"])),
    ("residencia-escazu", "Residencia en Escazú con vista al Valle Central", "escazu", "sale", 4, 5, 2, 480, 1650000,
     "San Rafael de Escazú, San José, Costa Rica",
     "Residencia en condominio privado con vista panorámica al Valle Central.",
     body("Cuatro recámaras con baño propio y estudio en el zona residencial más exclusiva de San José.",
          "Condominio con seguridad, áreas verdes y cercanía a colegios internacionales.",
          ["Vista al Valle Central", "Condominio privado", "Cerca de colegios internacionales", "A 15 minutos de San José"])),
    ("casa-heredia", "Casa en condominio en Heredia", "heredia", "sale", 3, 3, 2, 260, 420000,
     "San Rafael de Heredia, Costa Rica",
     "Casa familiar en condominio arbolado, con clima de montaña y vista a la ciudad.",
     body("Tres recámaras, estudio y jardín privado en un entorno tranquilo y fresco.",
          "Condominio con seguridad, casa club y senderos.",
          ["Clima de montaña", "Jardín privado", "Casa club", "A 25 minutos del aeropuerto"])),
    ("condo-brickell", "Condo en Brickell con vista a la bahía", "miami", "sale", 2, 2, 1, 135, 1150000,
     "Brickell, Miami, Florida, EE. UU.",
     "Condo de dos recámaras en torre de lujo con vista a la Bahía de Biscayne.",
     body("Ventanales de piso a techo, cocina italiana y balcón con vista a la bahía.",
          "Torre con spa, alberca en el piso 40 y valet parking.",
          ["Vista a la Bahía de Biscayne", "Spa y alberca en altura", "Valet parking", "A pasos de Brickell City Centre"])),
    ("penthouse-south-beach", "Penthouse en South Beach frente al océano", "miami-beach", "sale", 3, 4, 1, 290, 4800000,
     "South of Fifth, Miami Beach, Florida, EE. UU.",
     "Penthouse frente al océano en South of Fifth, con terraza privada y alberca.",
     body("Tres recámaras con vistas al Atlántico y a la bahía.",
          "Terraza en la azotea con alberca privada y cocina de verano.",
          ["Frente al océano", "Alberca privada en la azotea", "Servicios de hotel cinco estrellas", "A pasos de Ocean Drive"])),
    ("residencia-key-biscayne", "Residencia frente al agua en Key Biscayne", "key-biscayne", "sale", 5, 6, 2, 610, 7900000,
     "Key Biscayne, Florida, EE. UU.",
     "Residencia frente al agua con muelle privado en la isla de Key Biscayne.",
     body("Casa de cinco recámaras en terreno frente al agua con acceso al mar abierto.",
          "Muelle para yate, alberca y jardín tropical, a 15 minutos de Brickell.",
          ["Muelle privado", "Acceso a mar abierto", "Alberca y jardín tropical", "A 15 minutos de Brickell"])),
    ("casa-mediterranea-coral-gables", "Casa mediterránea en Coral Gables", "coral-gables", "rent", 4, 4, 2, 400, 18000,
     "Coral Gables, Florida, EE. UU.",
     "Casa estilo mediterráneo en renta, en una de las zonas residenciales más tradicionales de Miami.",
     body("Cuatro recámaras, techos altos y patio interior con fuente.",
          "Renta mensual cerca de colegios privados y del Biltmore Hotel.",
          ["Estilo mediterráneo", "Patio con alberca", "Cerca de colegios privados", "Contrato anual"])),
]

# proyecto: (slug, nombre, ciudad, bloques, pisos, unidades, precio_desde, precio_hasta, ubicación, descripción, contenido)
PROJECTS = [
    ("aldea-ardenza-tulum", "Aldea Ardenza Tulum", "tulum", 4, 4, 48, 380000, 1200000,
     "Región 15, Tulum, Quintana Roo, México",
     "Desarrollo boutique de 48 residencias integradas a la selva, con club de playa.",
     body("Departamentos y penthouses con roof privado, rodeados de selva.",
          "Club de playa, spa y concierge para administración de rentas.",
          ["48 residencias", "Club de playa", "Spa y gimnasio", "Entrega estimada 2027"])),
    ("torre-mareas-cancun", "Torre Mareas Cancún", "cancun", 1, 32, 120, 420000, 2100000,
     "Zona Hotelera, Cancún, Quintana Roo, México",
     "Torre residencial frente al mar Caribe con amenidades tipo resort.",
     body("Departamentos de una a cuatro recámaras con vista al mar.",
          "Alberca infinity, marina y restaurante privado para residentes.",
          ["Frente al mar", "Marina privada", "Restaurante para residentes", "Entrega estimada 2028"])),
    ("residencias-polanco-uno", "Residencias Polanco Uno", "ciudad-de-mexico", 1, 18, 36, 950000, 3400000,
     "Polanco, Ciudad de México, México",
     "Edificio de autor con 36 residencias de lujo frente a Chapultepec.",
     body("Residencias de dos a cuatro recámaras con terrazas ajardinadas.",
          "Lobby con concierge, spa, cava y salón de eventos privado.",
          ["36 residencias", "Vista a Chapultepec", "Concierge 24/7", "Entrega estimada 2027"])),
    ("tamarindo-bay-residences", "Tamarindo Bay Residences", "tamarindo", 3, 3, 30, 450000, 1600000,
     "Tamarindo, Guanacaste, Costa Rica",
     "Condominio de playa con 30 residencias a pasos de la bahía de Tamarindo.",
     body("Villas y departamentos con diseño tropical contemporáneo.",
          "Club de playa, alberca y administración de rentas vacacionales.",
          ["30 residencias", "A pasos de la playa", "Administración de rentas", "Entrega estimada 2027"])),
    ("escazu-hills", "Escazú Hills", "escazu", 2, 8, 40, 520000, 1300000,
     "Escazú, San José, Costa Rica",
     "Residencias con vista al Valle Central en las colinas de Escazú.",
     body("Departamentos amplios con terrazas y vista panorámica.",
          "Senderos, casa club y seguridad las 24 horas.",
          ["40 residencias", "Vista al Valle Central", "Casa club", "Entrega estimada 2027"])),
    ("brickell-bay-tower", "Brickell Bay Tower", "miami", 1, 45, 210, 850000, 6500000,
     "Brickell Bay Drive, Miami, Florida, EE. UU.",
     "Torre de lujo frente a la Bahía de Biscayne con amenidades de hotel cinco estrellas.",
     body("Residencias de una a cinco recámaras con vista a la bahía y al océano.",
          "Spa, club privado, alberca en altura y servicio de valet.",
          ["210 residencias", "Frente a la bahía", "Club privado", "Entrega estimada 2028"])),
]

INVESTORS = ["Grupo Riviera Residencial", "Pacífico Living", "Valle Central Desarrollos", "Bayfront Living Group"]

# agente: (nombre, apellido, ciudad, teléfono, descripción)
AGENTS = [
    ("Mariana", "Salazar", "tulum", "+52 984 000 0101", "Especialista en villas y desarrollos en Tulum y la Riviera Maya."),
    ("Diego", "Herrera", "ciudad-de-mexico", "+52 55 0000 0202", "Asesor de residencias de lujo en Polanco, Lomas y Condesa."),
    ("Sofía", "Navarro", "los-cabos", "+52 624 000 0303", "Propiedades frente al mar en Los Cabos y el Pacífico mexicano."),
    ("Andrés", "Mora", "tamarindo", "+506 0000 0404", "Casas de playa e inversión en Guanacaste."),
    ("Valeria", "Castillo", "escazu", "+506 0000 0505", "Residencias en Escazú, Santa Ana y el Valle Central."),
    ("Daniel", "Ríos", "miami", "+1 305 000 0606", "Condos y penthouses en Brickell y Downtown Miami."),
    ("Camila", "Torres", "miami-beach", "+1 305 000 0707", "Propiedades frente al océano en Miami Beach y Key Biscayne."),
    ("Luis", "Ortega", "cancun", "+52 998 000 0808", "Residencias y preventas en Cancún y Playa del Carmen."),
]


def p(*paras):
    return "".join(f"<p>{x}</p>" for x in paras)


# artículo: (slug, título, descripción, contenido)
POSTS = [
    ("comprar-propiedad-en-mexico-siendo-extranjero", "Cómo comprar propiedad en México siendo extranjero",
     "El fideicomiso bancario y otras claves para invertir en la costa mexicana.",
     p("Los extranjeros pueden comprar propiedades en México. En la llamada zona restringida —50 km desde la costa y 100 km desde las fronteras— la compra se hace a través de un fideicomiso bancario o de una sociedad mexicana.",
       "El fideicomiso da al comprador todos los derechos de uso, renta y venta del inmueble, y se puede heredar.",
       "Antes de firmar, conviene revisar el título, el certificado de libertad de gravamen y el uso de suelo con un notario público.",
       "<em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em>")),
    ("tulum-o-playa-del-carmen-donde-invertir", "Tulum o Playa del Carmen: dónde invertir",
     "Dos destinos del Caribe mexicano con perfiles de inversión distintos.",
     p("Tulum atrae a compradores que buscan diseño, naturaleza y renta vacacional de alto valor por noche.",
       "Playa del Carmen ofrece un mercado más consolidado, con demanda de renta durante todo el año y mejor conectividad.",
       "La decisión depende del horizonte de inversión, del uso personal que se planee y del nivel de riesgo aceptable.",
       "<em>Contenido informativo de demostración.</em>")),
    ("comprar-en-guanacaste-costa-rica", "Comprar en Guanacaste, Costa Rica, paso a paso",
     "Lo que un comprador internacional debe saber antes de invertir en la costa del Pacífico.",
     p("En Costa Rica, los extranjeros pueden tener propiedades con título inscrito con los mismos derechos que los nacionales.",
       "La franja de 200 metros desde la pleamar es zona marítimo-terrestre: los primeros 50 metros son públicos y el resto se otorga en concesión.",
       "Por eso es clave confirmar si la propiedad tiene título inscrito o concesión antes de comprar.",
       "<em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em>")),
    ("miami-para-compradores-latinoamericanos", "Miami para compradores latinoamericanos",
     "Por qué Miami sigue siendo el destino favorito de la inversión latinoamericana.",
     p("Miami combina estabilidad del dólar, conectividad con toda Latinoamérica y un mercado de lujo profundo.",
       "Los compradores extranjeros pueden adquirir propiedades sin residencia. Al vender, aplica una retención fiscal (FIRPTA) que conviene planear desde la compra.",
       "Brickell, Miami Beach, Key Biscayne y Coral Gables concentran la mayor demanda internacional.",
       "<em>Contenido informativo de demostración. Consulta siempre a un asesor fiscal.</em>")),
    ("renta-vacacional-en-el-caribe-mexicano", "Renta vacacional en el Caribe mexicano",
     "Cómo evaluar el rendimiento de una propiedad para renta de corto plazo.",
     p("La renta vacacional puede generar ingresos atractivos, pero depende de la ocupación, la tarifa por noche y los costos de administración.",
       "Conviene revisar el reglamento del condominio, los permisos locales y la oferta comparable en la zona.",
       "Una administradora profesional puede encargarse de reservas, limpieza y mantenimiento.",
       "<em>Contenido informativo de demostración.</em>")),
    ("como-evaluar-un-desarrollo-en-preventa", "Cómo evaluar un desarrollo en preventa",
     "Preguntas clave antes de comprar en un proyecto que aún está en construcción.",
     p("La preventa permite comprar a mejor precio, a cambio de esperar la entrega.",
       "Revisa la trayectoria del desarrollador, los permisos de construcción, el esquema de pagos y las garantías de entrega.",
       "Visitar la obra y hablar con compradores de proyectos anteriores ayuda a reducir el riesgo.",
       "<em>Contenido informativo de demostración.</em>")),
]


def tpl_table(name, cols, rows):
    out = [f"DROP TABLE IF EXISTS {name};",
           f"CREATE TABLE {name} (n INT PRIMARY KEY, {', '.join(c + ' ' + t for c, t in cols)}) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"]
    vals = []
    for i, r in enumerate(rows):
        vals.append("(" + ", ".join([str(i)] + [q(v) for v in r]) + ")")
    out.append(f"INSERT INTO {name} (n, {', '.join(c for c, _ in cols)}) VALUES\n  " + ",\n  ".join(vals) + ";")
    return "\n".join(out)


sql = []
sql.append("""-- =====================================================================
-- ARDENZA PROPIEDADES · Fase 4: contenido demo México, Costa Rica y Miami
-- Botble Real Estate (tema Flex Home)
--
-- Qué hace:
--   1. Crea ubicaciones: México, Costa Rica y Estados Unidos (Florida).
--   2. Reescribe propiedades, proyectos, desarrolladores, agentes y noticias
--      del demo de Colombia, CONSERVANDO las mismas imágenes.
--   3. Mueve todo a las nuevas ciudades, con coordenadas reales para el mapa.
--   4. Monedas: USD por defecto, MXN y CRC; elimina COP.
--   5. Borra países, estados y ciudades del demo anterior.
--
-- ANTES DE EJECUTAR: exporta la base u783834143_inmobil desde phpMyAdmin.
-- Ejecutar completo en phpMyAdmin → base u783834143_inmobil → pestaña SQL.
-- =====================================================================

SET NAMES utf8mb4;
""")

# 1. Ubicaciones
sql.append("-- 1. Ubicaciones nuevas -------------------------------------------------")
sql.append("DROP TABLE IF EXISTS ard_old_cities;")
sql.append("CREATE TABLE ard_old_cities AS SELECT id, image FROM cities;")
sql.append("DROP TABLE IF EXISTS ard_old_states;")
sql.append("CREATE TABLE ard_old_states AS SELECT id FROM states;")
sql.append("DROP TABLE IF EXISTS ard_old_countries;")
sql.append("CREATE TABLE ard_old_countries AS SELECT id FROM countries;")
sql.append("UPDATE countries SET is_default = 0;")
sql.append("UPDATE cities SET slug = NULL WHERE slug IN (" + ", ".join(q(c[0]) for c in CITIES) + ");")
sql.append("UPDATE states SET slug = NULL WHERE slug IN (" + ", ".join(q(s[4]) for s in STATES) + ");")
for key, name, nat, order, default in COUNTRIES:
    sql.append(f"INSERT INTO countries (name, nationality, `order`, is_default, status, created_at, updated_at) "
               f"VALUES ({q(name)}, {q(nat)}, {order}, {default}, 'published', NOW(), NOW());")
    sql.append(f"SET @c_{key} = LAST_INSERT_ID();")
for key, name, abbr, country, slug in STATES:
    sql.append(f"INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) "
               f"VALUES ({q(name)}, {q(slug)}, {q(abbr)}, @c_{country}, 0, 0, 'published', NOW(), NOW());")
    sql.append(f"SET @s_{key} = LAST_INSERT_ID();")
state_country = {s[0]: s[3] for s in STATES}
for order, (slug, name, state, lat, lng) in enumerate(CITIES):
    sql.append(f"INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) "
               f"VALUES ({q(name)}, {q(slug)}, @s_{state}, @c_{state_country[state]}, {order}, 0, 'published', NOW(), NOW());")


sql.append("""
-- Las nuevas ciudades reutilizan las imágenes de las ciudades del demo anterior.
DROP TABLE IF EXISTS ard_map_city, ard_old_city_img;
CREATE TABLE ard_map_city AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM cities WHERE id NOT IN (SELECT id FROM ard_old_cities);
CREATE TABLE ard_old_city_img AS SELECT image, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM ard_old_cities WHERE image IS NOT NULL AND image <> '';
SET @ni = (SELECT COUNT(*) FROM ard_old_city_img);
UPDATE cities c
JOIN ard_map_city nc ON nc.id = c.id
JOIN ard_old_city_img oc ON oc.rn = nc.rn % GREATEST(@ni, 1)
SET c.image = oc.image;
""")

# 2. Monedas
sql.append("""-- 2. Monedas ------------------------------------------------------------
INSERT INTO re_currencies (title, symbol, is_prefix_symbol, decimals, `order`, is_default, exchange_rate, created_at, updated_at)
SELECT 'USD', '$', 1, 0, 0, 0, 1, NOW(), NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM re_currencies WHERE title = 'USD');
INSERT INTO re_currencies (title, symbol, is_prefix_symbol, decimals, `order`, is_default, exchange_rate, created_at, updated_at)
SELECT 'MXN', 'MX$', 1, 0, 1, 0, 18.5, NOW(), NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM re_currencies WHERE title = 'MXN');
INSERT INTO re_currencies (title, symbol, is_prefix_symbol, decimals, `order`, is_default, exchange_rate, created_at, updated_at)
SELECT 'CRC', '₡', 1, 0, 2, 0, 510, NOW(), NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM re_currencies WHERE title = 'CRC');
UPDATE re_currencies SET is_default = IF(title = 'USD', 1, 0), exchange_rate = IF(title = 'USD', 1, exchange_rate);
UPDATE re_currencies SET symbol = '$', is_prefix_symbol = 1 WHERE title = 'USD';
SET @usd = (SELECT id FROM re_currencies WHERE title = 'USD' ORDER BY id LIMIT 1);
UPDATE re_properties SET currency_id = @usd;
UPDATE re_projects SET currency_id = @usd;
UPDATE re_packages SET currency_id = @usd;
DELETE FROM re_currencies WHERE title NOT IN ('USD', 'MXN', 'CRC');
""")

# 3. Propiedades
sql.append("-- 3. Propiedades ---------------------------------------------------------")
sql.append(tpl_table("ard_city_geo", [("slug", "VARCHAR(120)"), ("lat", "DECIMAL(10,6)"), ("lng", "DECIMAL(10,6)")],
                     [(c[0], c[3], c[4]) for c in CITIES]))
sql.append(tpl_table("ard_tpl_prop", [
    ("slug", "VARCHAR(190)"), ("name", "VARCHAR(300)"), ("city", "VARCHAR(120)"), ("type", "VARCHAR(20)"),
    ("bed", "INT"), ("bath", "INT"), ("floors", "INT"), ("square", "INT"), ("price", "DECIMAL(15,0)"),
    ("location", "VARCHAR(255)"), ("description", "VARCHAR(400)"), ("content", "LONGTEXT")], PROPERTIES))
sql.append(f"SET @np = {len(PROPERTIES)};")
sql.append("""DROP TABLE IF EXISTS ard_map_prop;
CREATE TABLE ard_map_prop AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_properties;
UPDATE re_properties p
JOIN ard_map_prop m ON m.id = p.id
JOIN ard_tpl_prop t ON t.n = m.rn % @np
JOIN cities c ON c.slug = t.city
JOIN ard_city_geo g ON g.slug = t.city
SET p.name = IF(m.rn < @np, t.name, CONCAT(t.name, ' · ', FLOOR(m.rn / @np) + 1)),
    p.description = t.description,
    p.content = t.content,
    p.location = t.location,
    p.type = t.type,
    p.period = 'month',
    p.status = IF(t.type = 'rent', 'renting', 'selling'),
    p.moderation_status = 'approved',
    p.number_bedroom = t.bed,
    p.number_bathroom = t.bath,
    p.number_floor = t.floors,
    p.square = t.square,
    p.price = t.price,
    p.city_id = c.id,
    p.state_id = c.state_id,
    p.country_id = c.country_id,
    p.latitude = ROUND(g.lat + (CAST(p.id % 7 AS SIGNED) - 3) * 0.004, 6),
    p.longitude = ROUND(g.lng + (CAST(p.id % 5 AS SIGNED) - 2) * 0.004, 6);
UPDATE slugs s
JOIN ard_map_prop m ON m.id = s.reference_id
JOIN ard_tpl_prop t ON t.n = m.rn % @np
SET s.`key` = IF(m.rn < @np, t.slug, CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%RealEstate%Models%Property';
""")

# 4. Proyectos y desarrolladores
sql.append("-- 4. Proyectos y desarrolladores ------------------------------------------")
sql.append(tpl_table("ard_city_geo", [("slug", "VARCHAR(120)"), ("lat", "DECIMAL(10,6)"), ("lng", "DECIMAL(10,6)")],
                     [(c[0], c[3], c[4]) for c in CITIES]))
sql.append(tpl_table("ard_tpl_proj", [
    ("slug", "VARCHAR(190)"), ("name", "VARCHAR(300)"), ("city", "VARCHAR(120)"), ("blocks", "INT"), ("floors", "INT"),
    ("flats", "INT"), ("price_from", "DECIMAL(15,0)"), ("price_to", "DECIMAL(15,0)"), ("location", "VARCHAR(255)"),
    ("description", "VARCHAR(400)"), ("content", "LONGTEXT")], PROJECTS))
sql.append(f"SET @nj = {len(PROJECTS)};")
sql.append("""DROP TABLE IF EXISTS ard_map_proj;
CREATE TABLE ard_map_proj AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_projects;
UPDATE re_projects p
JOIN ard_map_proj m ON m.id = p.id
JOIN ard_tpl_proj t ON t.n = m.rn % @nj
JOIN cities c ON c.slug = t.city
JOIN ard_city_geo g ON g.slug = t.city
SET p.name = IF(m.rn < @nj, t.name, CONCAT(t.name, ' · Fase ', FLOOR(m.rn / @nj) + 1)),
    p.description = t.description,
    p.content = t.content,
    p.location = t.location,
    p.number_block = t.blocks,
    p.number_floor = t.floors,
    p.number_flat = t.flats,
    p.price_from = t.price_from,
    p.price_to = t.price_to,
    p.date_finish = '2027-12-31',
    p.status = 'selling',
    p.city_id = c.id,
    p.state_id = c.state_id,
    p.country_id = c.country_id,
    p.latitude = ROUND(g.lat + (CAST(p.id % 7 AS SIGNED) - 3) * 0.004, 6),
    p.longitude = ROUND(g.lng + (CAST(p.id % 5 AS SIGNED) - 2) * 0.004, 6);
UPDATE slugs s
JOIN ard_map_proj m ON m.id = s.reference_id
JOIN ard_tpl_proj t ON t.n = m.rn % @nj
SET s.`key` = IF(m.rn < @nj, t.slug, CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%RealEstate%Models%Project';
""")
sql.append(tpl_table("ard_tpl_inv", [("name", "VARCHAR(120)")], [(n,) for n in INVESTORS]))
sql.append(f"""DROP TABLE IF EXISTS ard_map_inv;
CREATE TABLE ard_map_inv AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_investors;
UPDATE re_investors i
JOIN ard_map_inv m ON m.id = i.id
JOIN ard_tpl_inv t ON t.n = m.rn % {len(INVESTORS)}
SET i.name = IF(m.rn < {len(INVESTORS)}, t.name, CONCAT(t.name, ' ', FLOOR(m.rn / {len(INVESTORS)}) + 1));
""")

# 5. Agentes
sql.append("-- 5. Agentes (cuentas de realtors demo) ------------------------------------")
sql.append(tpl_table("ard_tpl_agent", [("first_name", "VARCHAR(120)"), ("last_name", "VARCHAR(120)"), ("city", "VARCHAR(120)"),
                                       ("phone", "VARCHAR(25)"), ("description", "TEXT")], AGENTS))
sql.append(f"SET @na = {len(AGENTS)};")
sql.append("""DROP TABLE IF EXISTS ard_map_acc;
CREATE TABLE ard_map_acc AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_accounts;
UPDATE re_accounts a
JOIN ard_map_acc m ON m.id = a.id
JOIN ard_tpl_agent t ON t.n = m.rn % @na
JOIN cities c ON c.slug = t.city
SET a.first_name = t.first_name,
    a.last_name = IF(m.rn < @na, t.last_name, CONCAT(t.last_name, ' ', FLOOR(m.rn / @na) + 1)),
    a.description = t.description,
    a.phone = t.phone,
    a.email = CONCAT('agente', a.id, '@example.com'),
    a.username = CONCAT('agente', a.id),
    a.company = 'Ardenza Propiedades',
    a.city_id = c.id,
    a.state_id = c.state_id,
    a.country_id = c.country_id;
""")

# 6. Noticias
sql.append("-- 6. Noticias del blog ----------------------------------------------------")
sql.append(tpl_table("ard_tpl_post", [("slug", "VARCHAR(190)"), ("name", "VARCHAR(255)"), ("description", "VARCHAR(400)"),
                                      ("content", "LONGTEXT")], POSTS))
sql.append(f"SET @nb = {len(POSTS)};")
sql.append("""DROP TABLE IF EXISTS ard_map_post;
CREATE TABLE ard_map_post AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM posts;
UPDATE posts p
JOIN ard_map_post m ON m.id = p.id
JOIN ard_tpl_post t ON t.n = m.rn % @nb
SET p.name = IF(m.rn < @nb, t.name, CONCAT(t.name, ' (', FLOOR(m.rn / @nb) + 1, ')')),
    p.description = t.description,
    p.content = t.content;
UPDATE slugs s
JOIN ard_map_post m ON m.id = s.reference_id
JOIN ard_tpl_post t ON t.n = m.rn % @nb
SET s.`key` = IF(m.rn < @nb, t.slug, CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%Blog%Models%Post';
""")

# 7. Traducciones y limpieza
sql.append(("""-- 7. Traducciones viejas y limpieza ----------------------------------------
-- El inglés vuelve a mostrar el texto en español hasta que se traduzca.
DELETE FROM re_properties_translations;
DELETE FROM re_projects_translations;
DELETE FROM posts_translations;
DELETE st FROM slugs_translations st JOIN slugs s ON s.id = st.slugs_id
WHERE s.reference_type LIKE '%RealEstate%Models%Property'
   OR s.reference_type LIKE '%RealEstate%Models%Project'
   OR s.reference_type LIKE '%Blog%Models%Post';

-- Se conservan solo las ubicaciones nuevas (por slug), aunque el script se haya ejecutado por partes.
DELETE FROM cities WHERE slug IS NULL OR slug NOT IN (""" + ", ".join(q(c[0]) for c in CITIES) + """);
DELETE FROM states WHERE slug IS NULL OR slug NOT IN (""" + ", ".join(q(s_[4]) for s_ in STATES) + """);
DELETE FROM countries WHERE id NOT IN (SELECT country_id FROM (SELECT DISTINCT country_id FROM states WHERE country_id IS NOT NULL) x);
DELETE FROM cities_translations WHERE cities_id NOT IN (SELECT id FROM cities);
DELETE FROM states_translations WHERE states_id NOT IN (SELECT id FROM states);
DELETE FROM countries_translations WHERE countries_id NOT IN (SELECT id FROM countries);

-- Teléfono y dirección del tema (el correo se cambia en el panel).
UPDATE settings SET value = '+506 8940-1202' WHERE `key` REGEXP '^theme-flex-home-([a-zA-Z_]+-)?hotline$';
UPDATE settings SET value = 'Heredia, Costa Rica · México · Miami' WHERE `key` REGEXP '^theme-flex-home-([a-zA-Z_]+-)?address$';

DROP TABLE IF EXISTS ard_old_cities, ard_old_states, ard_old_countries, ard_city_geo, ard_map_city, ard_old_city_img, ard_map_inv, ard_map_acc,
  ard_tpl_prop, ard_map_prop, ard_tpl_proj, ard_map_proj, ard_tpl_inv, ard_tpl_agent, ard_tpl_post, ard_map_post;

-- 8. Verificación: debe listar solo México, Costa Rica y Estados Unidos.
SELECT co.name AS pais, ci.name AS ciudad,
       (SELECT COUNT(*) FROM re_properties p WHERE p.city_id = ci.id) AS propiedades,
       (SELECT COUNT(*) FROM re_projects j WHERE j.city_id = ci.id) AS proyectos
FROM cities ci JOIN countries co ON co.id = ci.country_id
ORDER BY co.`order`, ci.`order`;
"""))

if __name__ == "__main__":
    OUT = sys.argv[1]
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(sql))
    print("ok", OUT)
