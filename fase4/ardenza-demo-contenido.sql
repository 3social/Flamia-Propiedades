-- =====================================================================
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

-- 1. Ubicaciones nuevas -------------------------------------------------
DROP TABLE IF EXISTS ard_old_cities;
CREATE TABLE ard_old_cities AS SELECT id, image FROM cities;
DROP TABLE IF EXISTS ard_old_states;
CREATE TABLE ard_old_states AS SELECT id FROM states;
DROP TABLE IF EXISTS ard_old_countries;
CREATE TABLE ard_old_countries AS SELECT id FROM countries;
UPDATE countries SET is_default = 0;
UPDATE cities SET slug = NULL WHERE slug IN ('tulum', 'playa-del-carmen', 'cancun', 'ciudad-de-mexico', 'los-cabos', 'puerto-vallarta', 'tamarindo', 'santa-teresa', 'escazu', 'heredia', 'miami', 'miami-beach', 'key-biscayne', 'coral-gables');
UPDATE states SET slug = NULL WHERE slug IN ('quintana-roo', 'ciudad-de-mexico-estado', 'baja-california-sur', 'jalisco', 'guanacaste', 'puntarenas', 'san-jose-cr', 'heredia-provincia', 'florida');
INSERT INTO countries (name, nationality, `order`, is_default, status, created_at, updated_at) VALUES ('México', 'Mexicana', 1, 1, 'published', NOW(), NOW());
SET @c_mx = LAST_INSERT_ID();
INSERT INTO countries (name, nationality, `order`, is_default, status, created_at, updated_at) VALUES ('Costa Rica', 'Costarricense', 2, 0, 'published', NOW(), NOW());
SET @c_cr = LAST_INSERT_ID();
INSERT INTO countries (name, nationality, `order`, is_default, status, created_at, updated_at) VALUES ('Estados Unidos', 'Estadounidense', 3, 0, 'published', NOW(), NOW());
SET @c_us = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Quintana Roo', 'quintana-roo', 'QROO', @c_mx, 0, 0, 'published', NOW(), NOW());
SET @s_qroo = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Ciudad de México', 'ciudad-de-mexico-estado', 'CDMX', @c_mx, 0, 0, 'published', NOW(), NOW());
SET @s_cdmx = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Baja California Sur', 'baja-california-sur', 'BCS', @c_mx, 0, 0, 'published', NOW(), NOW());
SET @s_bcs = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Jalisco', 'jalisco', 'JAL', @c_mx, 0, 0, 'published', NOW(), NOW());
SET @s_jal = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Guanacaste', 'guanacaste', 'GTE', @c_cr, 0, 0, 'published', NOW(), NOW());
SET @s_gte = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Puntarenas', 'puntarenas', 'PUN', @c_cr, 0, 0, 'published', NOW(), NOW());
SET @s_pun = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('San José', 'san-jose-cr', 'SJ', @c_cr, 0, 0, 'published', NOW(), NOW());
SET @s_sjo = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Heredia', 'heredia-provincia', 'HER', @c_cr, 0, 0, 'published', NOW(), NOW());
SET @s_her = LAST_INSERT_ID();
INSERT INTO states (name, slug, abbreviation, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Florida', 'florida', 'FL', @c_us, 0, 0, 'published', NOW(), NOW());
SET @s_fl = LAST_INSERT_ID();
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Tulum', 'tulum', @s_qroo, @c_mx, 0, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Playa del Carmen', 'playa-del-carmen', @s_qroo, @c_mx, 1, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Cancún', 'cancun', @s_qroo, @c_mx, 2, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Ciudad de México', 'ciudad-de-mexico', @s_cdmx, @c_mx, 3, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Los Cabos', 'los-cabos', @s_bcs, @c_mx, 4, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Puerto Vallarta', 'puerto-vallarta', @s_jal, @c_mx, 5, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Tamarindo', 'tamarindo', @s_gte, @c_cr, 6, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Santa Teresa', 'santa-teresa', @s_pun, @c_cr, 7, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Escazú', 'escazu', @s_sjo, @c_cr, 8, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Heredia', 'heredia', @s_her, @c_cr, 9, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Miami', 'miami', @s_fl, @c_us, 10, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Miami Beach', 'miami-beach', @s_fl, @c_us, 11, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Key Biscayne', 'key-biscayne', @s_fl, @c_us, 12, 0, 'published', NOW(), NOW());
INSERT INTO cities (name, slug, state_id, country_id, `order`, is_default, status, created_at, updated_at) VALUES ('Coral Gables', 'coral-gables', @s_fl, @c_us, 13, 0, 'published', NOW(), NOW());

-- Las nuevas ciudades reutilizan las imágenes de las ciudades del demo anterior.
DROP TABLE IF EXISTS ard_map_city, ard_old_city_img;
CREATE TABLE ard_map_city AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM cities WHERE id NOT IN (SELECT id FROM ard_old_cities);
CREATE TABLE ard_old_city_img AS SELECT image, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM ard_old_cities WHERE image IS NOT NULL AND image <> '';
SET @ni = (SELECT COUNT(*) FROM ard_old_city_img);
UPDATE cities c
JOIN ard_map_city nc ON nc.id = c.id
JOIN ard_old_city_img oc ON oc.rn = nc.rn % GREATEST(@ni, 1)
SET c.image = oc.image;

-- 2. Monedas ------------------------------------------------------------
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

-- 3. Propiedades ---------------------------------------------------------
DROP TABLE IF EXISTS ard_city_geo;
CREATE TABLE ard_city_geo (n INT PRIMARY KEY, slug VARCHAR(120), lat DECIMAL(10,6), lng DECIMAL(10,6)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_city_geo (n, slug, lat, lng) VALUES
  (0, 'tulum', 20.2114, -87.4654),
  (1, 'playa-del-carmen', 20.6296, -87.0739),
  (2, 'cancun', 21.1619, -86.8515),
  (3, 'ciudad-de-mexico', 19.4326, -99.1332),
  (4, 'los-cabos', 22.8905, -109.9167),
  (5, 'puerto-vallarta', 20.6534, -105.2253),
  (6, 'tamarindo', 10.2993, -85.8371),
  (7, 'santa-teresa', 9.6431, -85.169),
  (8, 'escazu', 9.9189, -84.1395),
  (9, 'heredia', 9.9981, -84.117),
  (10, 'miami', 25.7617, -80.1918),
  (11, 'miami-beach', 25.7907, -80.13),
  (12, 'key-biscayne', 25.6937, -80.1628),
  (13, 'coral-gables', 25.7215, -80.2684);
DROP TABLE IF EXISTS ard_tpl_prop;
CREATE TABLE ard_tpl_prop (n INT PRIMARY KEY, slug VARCHAR(190), name VARCHAR(300), city VARCHAR(120), type VARCHAR(20), bed INT, bath INT, floors INT, square INT, price DECIMAL(15,0), location VARCHAR(255), description VARCHAR(400), content LONGTEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tpl_prop (n, slug, name, city, type, bed, bath, floors, square, price, location, description, content) VALUES
  (0, 'villa-selva-tulum', 'Villa Selva con alberca privada', 'tulum', 'sale', 4, 4, 2, 420, 1250000, 'Región 15, Tulum, Quintana Roo, México', 'Villa de cuatro recámaras rodeada de selva, a diez minutos de las playas de Tulum.', '<p>Arquitectura contemporánea en chukum y madera tropical, integrada a la selva maya.</p><p>La planta baja abre por completo hacia la alberca y el jardín; la planta alta concentra las recámaras con terrazas privadas.</p><ul><li>Alberca privada y jardín</li><li>Roof garden con vista a la selva</li><li>Paneles solares y cisterna</li><li>A 10 minutos de la zona hotelera</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (1, 'penthouse-aldea-zama-tulum', 'Penthouse en Aldea Zamá con roof privado', 'tulum', 'sale', 3, 3, 1, 210, 890000, 'Aldea Zamá, Tulum, Quintana Roo, México', 'Penthouse con terraza privada y jacuzzi en la zona residencial más buscada de Tulum.', '<p>Penthouse de tres recámaras en un condominio boutique de solo doce unidades.</p><p>Terraza privada con jacuzzi y cocina exterior, ideal para renta vacacional o residencia.</p><ul><li>Jacuzzi en el roof</li><li>Amenidades tipo hotel</li><li>Administración de rentas disponible</li><li>Entrega inmediata</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (2, 'departamento-playacar', 'Departamento en Playacar con vista al mar', 'playa-del-carmen', 'sale', 2, 2, 1, 140, 485000, 'Playacar Fase I, Playa del Carmen, Quintana Roo, México', 'Departamento frente al mar dentro de Playacar, a pasos de la Quinta Avenida.', '<p>Vista abierta al Caribe desde la sala y la recámara principal.</p><p>Condominio con seguridad 24 horas, alberca infinity y acceso directo a la playa.</p><ul><li>Acceso directo a la playa</li><li>Alberca infinity</li><li>Seguridad 24/7</li><li>A 5 minutos de la Quinta Avenida</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (3, 'residencia-puerto-cancun', 'Residencia en Puerto Cancún con muelle', 'cancun', 'sale', 5, 6, 2, 650, 2900000, 'Puerto Cancún, Cancún, Quintana Roo, México', 'Residencia frente a la marina con muelle privado para yate.', '<p>Casa de cinco recámaras en el desarrollo residencial más exclusivo de Cancún.</p><p>Doble altura en áreas sociales, cocina de chef y estancia frente al canal.</p><ul><li>Muelle privado</li><li>Club de golf y marina</li><li>Elevador</li><li>Cuarto de servicio</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (4, 'penthouse-polanco', 'Penthouse en Polanco con terraza panorámica', 'ciudad-de-mexico', 'sale', 3, 3, 1, 280, 1350000, 'Polanco V Sección, Ciudad de México, México', 'Penthouse de lujo a una cuadra de Masaryk, con terraza de 80 m².', '<p>Acabados en mármol y madera de nogal, con vista abierta a Chapultepec.</p><p>Edificio con lobby con concierge, gimnasio y dos lugares de estacionamiento.</p><ul><li>Terraza de 80 m²</li><li>Concierge 24/7</li><li>Cava y cuarto de servicio</li><li>A una cuadra de Masaryk</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (5, 'loft-condesa', 'Loft de diseño en la Condesa', 'ciudad-de-mexico', 'rent', 1, 1, 1, 95, 3200, 'Condesa, Ciudad de México, México', 'Loft amueblado en edificio art déco restaurado, frente al Parque México.', '<p>Loft de doble altura con mobiliario de diseño mexicano.</p><p>Renta mensual con servicios incluidos, ideal para ejecutivos y nómadas digitales.</p><ul><li>Amueblado y equipado</li><li>Servicios incluidos</li><li>Frente al Parque México</li><li>Contrato mínimo de 6 meses</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (6, 'villa-pedregal-los-cabos', 'Villa en Pedregal con vista al mar de Cortés', 'los-cabos', 'sale', 5, 5, 3, 520, 4200000, 'El Pedregal, Cabo San Lucas, Baja California Sur, México', 'Villa sobre el acantilado con vista al Arco y al océano Pacífico.', '<p>Villa de cinco recámaras en la comunidad privada de El Pedregal.</p><p>Alberca infinity, terrazas escalonadas y atardeceres sobre el Pacífico.</p><ul><li>Vista al Arco</li><li>Alberca infinity</li><li>Comunidad con acceso controlado</li><li>A 5 minutos de la marina</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (7, 'condominio-conchas-chinas', 'Condominio en Conchas Chinas frente a la bahía', 'puerto-vallarta', 'sale', 3, 3, 1, 230, 980000, 'Conchas Chinas, Puerto Vallarta, Jalisco, México', 'Condominio frente a la Bahía de Banderas, a minutos de la Zona Romántica.', '<p>Tres recámaras con vista panorámica a la Bahía de Banderas.</p><p>Edificio con alberca, gimnasio y acceso a playa privada.</p><ul><li>Vista a la bahía</li><li>Playa privada</li><li>Alberca y gimnasio</li><li>A 5 minutos de la Zona Romántica</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (8, 'casa-playa-tamarindo', 'Casa de playa en Tamarindo', 'tamarindo', 'sale', 4, 4, 2, 380, 1450000, 'Playa Langosta, Tamarindo, Guanacaste, Costa Rica', 'Casa a pasos de Playa Langosta, en una de las costas más buscadas de Guanacaste.', '<p>Diseño tropical moderno con grandes ventanales y ventilación cruzada.</p><p>Jardín con palmeras, alberca y rancho exterior para disfrutar el atardecer.</p><ul><li>A pasos de la playa</li><li>Alberca y rancho</li><li>Título inscrito</li><li>A 30 minutos del aeropuerto de Liberia</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (9, 'villa-surf-santa-teresa', 'Villa de surf en Santa Teresa', 'santa-teresa', 'sale', 3, 3, 1, 300, 1100000, 'Santa Teresa, Puntarenas, Costa Rica', 'Villa con vista al océano en las colinas de Santa Teresa, destino de surf de clase mundial.', '<p>Tres suites independientes ideales para renta vacacional.</p><p>Vista al Pacífico desde todas las habitaciones y a cinco minutos de la playa.</p><ul><li>Vista al océano</li><li>Ideal para renta vacacional</li><li>Alberca infinity</li><li>A 5 minutos de la playa</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (10, 'residencia-escazu', 'Residencia en Escazú con vista al Valle Central', 'escazu', 'sale', 4, 5, 2, 480, 1650000, 'San Rafael de Escazú, San José, Costa Rica', 'Residencia en condominio privado con vista panorámica al Valle Central.', '<p>Cuatro recámaras con baño propio y estudio en el zona residencial más exclusiva de San José.</p><p>Condominio con seguridad, áreas verdes y cercanía a colegios internacionales.</p><ul><li>Vista al Valle Central</li><li>Condominio privado</li><li>Cerca de colegios internacionales</li><li>A 15 minutos de San José</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (11, 'casa-heredia', 'Casa en condominio en Heredia', 'heredia', 'sale', 3, 3, 2, 260, 420000, 'San Rafael de Heredia, Costa Rica', 'Casa familiar en condominio arbolado, con clima de montaña y vista a la ciudad.', '<p>Tres recámaras, estudio y jardín privado en un entorno tranquilo y fresco.</p><p>Condominio con seguridad, casa club y senderos.</p><ul><li>Clima de montaña</li><li>Jardín privado</li><li>Casa club</li><li>A 25 minutos del aeropuerto</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (12, 'condo-brickell', 'Condo en Brickell con vista a la bahía', 'miami', 'sale', 2, 2, 1, 135, 1150000, 'Brickell, Miami, Florida, EE. UU.', 'Condo de dos recámaras en torre de lujo con vista a la Bahía de Biscayne.', '<p>Ventanales de piso a techo, cocina italiana y balcón con vista a la bahía.</p><p>Torre con spa, alberca en el piso 40 y valet parking.</p><ul><li>Vista a la Bahía de Biscayne</li><li>Spa y alberca en altura</li><li>Valet parking</li><li>A pasos de Brickell City Centre</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (13, 'penthouse-south-beach', 'Penthouse en South Beach frente al océano', 'miami-beach', 'sale', 3, 4, 1, 290, 4800000, 'South of Fifth, Miami Beach, Florida, EE. UU.', 'Penthouse frente al océano en South of Fifth, con terraza privada y alberca.', '<p>Tres recámaras con vistas al Atlántico y a la bahía.</p><p>Terraza en la azotea con alberca privada y cocina de verano.</p><ul><li>Frente al océano</li><li>Alberca privada en la azotea</li><li>Servicios de hotel cinco estrellas</li><li>A pasos de Ocean Drive</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (14, 'residencia-key-biscayne', 'Residencia frente al agua en Key Biscayne', 'key-biscayne', 'sale', 5, 6, 2, 610, 7900000, 'Key Biscayne, Florida, EE. UU.', 'Residencia frente al agua con muelle privado en la isla de Key Biscayne.', '<p>Casa de cinco recámaras en terreno frente al agua con acceso al mar abierto.</p><p>Muelle para yate, alberca y jardín tropical, a 15 minutos de Brickell.</p><ul><li>Muelle privado</li><li>Acceso a mar abierto</li><li>Alberca y jardín tropical</li><li>A 15 minutos de Brickell</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (15, 'casa-mediterranea-coral-gables', 'Casa mediterránea en Coral Gables', 'coral-gables', 'rent', 4, 4, 2, 400, 18000, 'Coral Gables, Florida, EE. UU.', 'Casa estilo mediterráneo en renta, en una de las zonas residenciales más tradicionales de Miami.', '<p>Cuatro recámaras, techos altos y patio interior con fuente.</p><p>Renta mensual cerca de colegios privados y del Biltmore Hotel.</p><ul><li>Estilo mediterráneo</li><li>Patio con alberca</li><li>Cerca de colegios privados</li><li>Contrato anual</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>');
SET @np = 16;
DROP TABLE IF EXISTS ard_map_prop;
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

-- 4. Proyectos y desarrolladores ------------------------------------------
DROP TABLE IF EXISTS ard_city_geo;
CREATE TABLE ard_city_geo (n INT PRIMARY KEY, slug VARCHAR(120), lat DECIMAL(10,6), lng DECIMAL(10,6)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_city_geo (n, slug, lat, lng) VALUES
  (0, 'tulum', 20.2114, -87.4654),
  (1, 'playa-del-carmen', 20.6296, -87.0739),
  (2, 'cancun', 21.1619, -86.8515),
  (3, 'ciudad-de-mexico', 19.4326, -99.1332),
  (4, 'los-cabos', 22.8905, -109.9167),
  (5, 'puerto-vallarta', 20.6534, -105.2253),
  (6, 'tamarindo', 10.2993, -85.8371),
  (7, 'santa-teresa', 9.6431, -85.169),
  (8, 'escazu', 9.9189, -84.1395),
  (9, 'heredia', 9.9981, -84.117),
  (10, 'miami', 25.7617, -80.1918),
  (11, 'miami-beach', 25.7907, -80.13),
  (12, 'key-biscayne', 25.6937, -80.1628),
  (13, 'coral-gables', 25.7215, -80.2684);
DROP TABLE IF EXISTS ard_tpl_proj;
CREATE TABLE ard_tpl_proj (n INT PRIMARY KEY, slug VARCHAR(190), name VARCHAR(300), city VARCHAR(120), blocks INT, floors INT, flats INT, price_from DECIMAL(15,0), price_to DECIMAL(15,0), location VARCHAR(255), description VARCHAR(400), content LONGTEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tpl_proj (n, slug, name, city, blocks, floors, flats, price_from, price_to, location, description, content) VALUES
  (0, 'aldea-ardenza-tulum', 'Aldea Ardenza Tulum', 'tulum', 4, 4, 48, 380000, 1200000, 'Región 15, Tulum, Quintana Roo, México', 'Desarrollo boutique de 48 residencias integradas a la selva, con club de playa.', '<p>Departamentos y penthouses con roof privado, rodeados de selva.</p><p>Club de playa, spa y concierge para administración de rentas.</p><ul><li>48 residencias</li><li>Club de playa</li><li>Spa y gimnasio</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (1, 'torre-mareas-cancun', 'Torre Mareas Cancún', 'cancun', 1, 32, 120, 420000, 2100000, 'Zona Hotelera, Cancún, Quintana Roo, México', 'Torre residencial frente al mar Caribe con amenidades tipo resort.', '<p>Departamentos de una a cuatro recámaras con vista al mar.</p><p>Alberca infinity, marina y restaurante privado para residentes.</p><ul><li>Frente al mar</li><li>Marina privada</li><li>Restaurante para residentes</li><li>Entrega estimada 2028</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (2, 'residencias-polanco-uno', 'Residencias Polanco Uno', 'ciudad-de-mexico', 1, 18, 36, 950000, 3400000, 'Polanco, Ciudad de México, México', 'Edificio de autor con 36 residencias de lujo frente a Chapultepec.', '<p>Residencias de dos a cuatro recámaras con terrazas ajardinadas.</p><p>Lobby con concierge, spa, cava y salón de eventos privado.</p><ul><li>36 residencias</li><li>Vista a Chapultepec</li><li>Concierge 24/7</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (3, 'tamarindo-bay-residences', 'Tamarindo Bay Residences', 'tamarindo', 3, 3, 30, 450000, 1600000, 'Tamarindo, Guanacaste, Costa Rica', 'Condominio de playa con 30 residencias a pasos de la bahía de Tamarindo.', '<p>Villas y departamentos con diseño tropical contemporáneo.</p><p>Club de playa, alberca y administración de rentas vacacionales.</p><ul><li>30 residencias</li><li>A pasos de la playa</li><li>Administración de rentas</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (4, 'escazu-hills', 'Escazú Hills', 'escazu', 2, 8, 40, 520000, 1300000, 'Escazú, San José, Costa Rica', 'Residencias con vista al Valle Central en las colinas de Escazú.', '<p>Departamentos amplios con terrazas y vista panorámica.</p><p>Senderos, casa club y seguridad las 24 horas.</p><ul><li>40 residencias</li><li>Vista al Valle Central</li><li>Casa club</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>'),
  (5, 'brickell-bay-tower', 'Brickell Bay Tower', 'miami', 1, 45, 210, 850000, 6500000, 'Brickell Bay Drive, Miami, Florida, EE. UU.', 'Torre de lujo frente a la Bahía de Biscayne con amenidades de hotel cinco estrellas.', '<p>Residencias de una a cinco recámaras con vista a la bahía y al océano.</p><p>Spa, club privado, alberca en altura y servicio de valet.</p><ul><li>210 residencias</li><li>Frente a la bahía</li><li>Club privado</li><li>Entrega estimada 2028</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>');
SET @nj = 6;
DROP TABLE IF EXISTS ard_map_proj;
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

DROP TABLE IF EXISTS ard_tpl_inv;
CREATE TABLE ard_tpl_inv (n INT PRIMARY KEY, name VARCHAR(120)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tpl_inv (n, name) VALUES
  (0, 'Grupo Riviera Residencial'),
  (1, 'Pacífico Living'),
  (2, 'Valle Central Desarrollos'),
  (3, 'Bayfront Living Group');
DROP TABLE IF EXISTS ard_map_inv;
CREATE TABLE ard_map_inv AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_investors;
UPDATE re_investors i
JOIN ard_map_inv m ON m.id = i.id
JOIN ard_tpl_inv t ON t.n = m.rn % 4
SET i.name = IF(m.rn < 4, t.name, CONCAT(t.name, ' ', FLOOR(m.rn / 4) + 1));

-- 5. Agentes (cuentas de realtors demo) ------------------------------------
DROP TABLE IF EXISTS ard_tpl_agent;
CREATE TABLE ard_tpl_agent (n INT PRIMARY KEY, first_name VARCHAR(120), last_name VARCHAR(120), city VARCHAR(120), phone VARCHAR(25), description TEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tpl_agent (n, first_name, last_name, city, phone, description) VALUES
  (0, 'Mariana', 'Salazar', 'tulum', '+52 984 000 0101', 'Especialista en villas y desarrollos en Tulum y la Riviera Maya.'),
  (1, 'Diego', 'Herrera', 'ciudad-de-mexico', '+52 55 0000 0202', 'Asesor de residencias de lujo en Polanco, Lomas y Condesa.'),
  (2, 'Sofía', 'Navarro', 'los-cabos', '+52 624 000 0303', 'Propiedades frente al mar en Los Cabos y el Pacífico mexicano.'),
  (3, 'Andrés', 'Mora', 'tamarindo', '+506 0000 0404', 'Casas de playa e inversión en Guanacaste.'),
  (4, 'Valeria', 'Castillo', 'escazu', '+506 0000 0505', 'Residencias en Escazú, Santa Ana y el Valle Central.'),
  (5, 'Daniel', 'Ríos', 'miami', '+1 305 000 0606', 'Condos y penthouses en Brickell y Downtown Miami.'),
  (6, 'Camila', 'Torres', 'miami-beach', '+1 305 000 0707', 'Propiedades frente al océano en Miami Beach y Key Biscayne.'),
  (7, 'Luis', 'Ortega', 'cancun', '+52 998 000 0808', 'Residencias y preventas en Cancún y Playa del Carmen.');
SET @na = 8;
DROP TABLE IF EXISTS ard_map_acc;
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

-- 6. Noticias del blog ----------------------------------------------------
DROP TABLE IF EXISTS ard_tpl_post;
CREATE TABLE ard_tpl_post (n INT PRIMARY KEY, slug VARCHAR(190), name VARCHAR(255), description VARCHAR(400), content LONGTEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tpl_post (n, slug, name, description, content) VALUES
  (0, 'comprar-propiedad-en-mexico-siendo-extranjero', 'Cómo comprar propiedad en México siendo extranjero', 'El fideicomiso bancario y otras claves para invertir en la costa mexicana.', '<p>Los extranjeros pueden comprar propiedades en México. En la llamada zona restringida —50 km desde la costa y 100 km desde las fronteras— la compra se hace a través de un fideicomiso bancario o de una sociedad mexicana.</p><p>El fideicomiso da al comprador todos los derechos de uso, renta y venta del inmueble, y se puede heredar.</p><p>Antes de firmar, conviene revisar el título, el certificado de libertad de gravamen y el uso de suelo con un notario público.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em></p>'),
  (1, 'tulum-o-playa-del-carmen-donde-invertir', 'Tulum o Playa del Carmen: dónde invertir', 'Dos destinos del Caribe mexicano con perfiles de inversión distintos.', '<p>Tulum atrae a compradores que buscan diseño, naturaleza y renta vacacional de alto valor por noche.</p><p>Playa del Carmen ofrece un mercado más consolidado, con demanda de renta durante todo el año y mejor conectividad.</p><p>La decisión depende del horizonte de inversión, del uso personal que se planee y del nivel de riesgo aceptable.</p><p><em>Contenido informativo de demostración.</em></p>'),
  (2, 'comprar-en-guanacaste-costa-rica', 'Comprar en Guanacaste, Costa Rica, paso a paso', 'Lo que un comprador internacional debe saber antes de invertir en la costa del Pacífico.', '<p>En Costa Rica, los extranjeros pueden tener propiedades con título inscrito con los mismos derechos que los nacionales.</p><p>La franja de 200 metros desde la pleamar es zona marítimo-terrestre: los primeros 50 metros son públicos y el resto se otorga en concesión.</p><p>Por eso es clave confirmar si la propiedad tiene título inscrito o concesión antes de comprar.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em></p>'),
  (3, 'miami-para-compradores-latinoamericanos', 'Miami para compradores latinoamericanos', 'Por qué Miami sigue siendo el destino favorito de la inversión latinoamericana.', '<p>Miami combina estabilidad del dólar, conectividad con toda Latinoamérica y un mercado de lujo profundo.</p><p>Los compradores extranjeros pueden adquirir propiedades sin residencia. Al vender, aplica una retención fiscal (FIRPTA) que conviene planear desde la compra.</p><p>Brickell, Miami Beach, Key Biscayne y Coral Gables concentran la mayor demanda internacional.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor fiscal.</em></p>'),
  (4, 'renta-vacacional-en-el-caribe-mexicano', 'Renta vacacional en el Caribe mexicano', 'Cómo evaluar el rendimiento de una propiedad para renta de corto plazo.', '<p>La renta vacacional puede generar ingresos atractivos, pero depende de la ocupación, la tarifa por noche y los costos de administración.</p><p>Conviene revisar el reglamento del condominio, los permisos locales y la oferta comparable en la zona.</p><p>Una administradora profesional puede encargarse de reservas, limpieza y mantenimiento.</p><p><em>Contenido informativo de demostración.</em></p>'),
  (5, 'como-evaluar-un-desarrollo-en-preventa', 'Cómo evaluar un desarrollo en preventa', 'Preguntas clave antes de comprar en un proyecto que aún está en construcción.', '<p>La preventa permite comprar a mejor precio, a cambio de esperar la entrega.</p><p>Revisa la trayectoria del desarrollador, los permisos de construcción, el esquema de pagos y las garantías de entrega.</p><p>Visitar la obra y hablar con compradores de proyectos anteriores ayuda a reducir el riesgo.</p><p><em>Contenido informativo de demostración.</em></p>');
SET @nb = 6;
DROP TABLE IF EXISTS ard_map_post;
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

-- 7. Traducciones viejas y limpieza ----------------------------------------
-- El inglés vuelve a mostrar el texto en español hasta que se traduzca.
DELETE FROM re_properties_translations;
DELETE FROM re_projects_translations;
DELETE FROM posts_translations;
DELETE st FROM slugs_translations st JOIN slugs s ON s.id = st.slugs_id
WHERE s.reference_type LIKE '%RealEstate%Models%Property'
   OR s.reference_type LIKE '%RealEstate%Models%Project'
   OR s.reference_type LIKE '%Blog%Models%Post';

-- Se conservan solo las ubicaciones nuevas (por slug), aunque el script se haya ejecutado por partes.
DELETE FROM cities WHERE slug IS NULL OR slug NOT IN ('tulum', 'playa-del-carmen', 'cancun', 'ciudad-de-mexico', 'los-cabos', 'puerto-vallarta', 'tamarindo', 'santa-teresa', 'escazu', 'heredia', 'miami', 'miami-beach', 'key-biscayne', 'coral-gables');
DELETE FROM states WHERE slug IS NULL OR slug NOT IN ('quintana-roo', 'ciudad-de-mexico-estado', 'baja-california-sur', 'jalisco', 'guanacaste', 'puntarenas', 'san-jose-cr', 'heredia-provincia', 'florida');
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
