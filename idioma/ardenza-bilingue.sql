-- =====================================================================
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

-- 1. Propiedades, desarrollos y noticias ------------------------------------
DROP TABLE IF EXISTS ard_t;
CREATE TABLE ard_t (kind VARCHAR(10), slug VARCHAR(190), es_name VARCHAR(300), en_name VARCHAR(300), es_desc VARCHAR(400), en_desc VARCHAR(400), es_content LONGTEXT, en_content LONGTEXT, es_loc VARCHAR(255), en_loc VARCHAR(255)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_t (kind, slug, es_name, en_name, es_desc, en_desc, es_content, en_content, es_loc, en_loc) VALUES
  ('prop', 'villa-selva-tulum', 'Villa Selva con alberca privada', 'Jungle villa with private pool', 'Villa de cuatro recámaras rodeada de selva, a diez minutos de las playas de Tulum.', 'Four-bedroom villa surrounded by jungle, ten minutes from the beaches of Tulum.', '<p>Arquitectura contemporánea en chukum y madera tropical, integrada a la selva maya.</p><p>La planta baja abre por completo hacia la alberca y el jardín; la planta alta concentra las recámaras con terrazas privadas.</p><ul><li>Alberca privada y jardín</li><li>Roof garden con vista a la selva</li><li>Paneles solares y cisterna</li><li>A 10 minutos de la zona hotelera</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Contemporary architecture in chukum and tropical wood, blended into the Mayan jungle.</p><p>The ground floor opens fully onto the pool and garden; the upper floor holds the bedrooms with private terraces.</p><ul><li>Private pool and garden</li><li>Roof garden with jungle views</li><li>Solar panels and water cistern</li><li>10 minutes from the hotel zone</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Región 15, Tulum, Quintana Roo, México', 'Región 15, Tulum, Quintana Roo, Mexico'),
  ('prop', 'penthouse-aldea-zama-tulum', 'Penthouse en Aldea Zamá con roof privado', 'Aldea Zamá penthouse with private rooftop', 'Penthouse con terraza privada y jacuzzi en la zona residencial más buscada de Tulum.', 'Penthouse with private terrace and hot tub in Tulum''s most sought-after residential area.', '<p>Penthouse de tres recámaras en un condominio boutique de solo doce unidades.</p><p>Terraza privada con jacuzzi y cocina exterior, ideal para renta vacacional o residencia.</p><ul><li>Jacuzzi en el roof</li><li>Amenidades tipo hotel</li><li>Administración de rentas disponible</li><li>Entrega inmediata</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Three-bedroom penthouse in a boutique building of only twelve units.</p><p>Private terrace with hot tub and outdoor kitchen, ideal as a vacation rental or residence.</p><ul><li>Rooftop hot tub</li><li>Hotel-style amenities</li><li>Rental management available</li><li>Ready to move in</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Aldea Zamá, Tulum, Quintana Roo, México', 'Aldea Zamá, Tulum, Quintana Roo, Mexico'),
  ('prop', 'departamento-playacar', 'Departamento en Playacar con vista al mar', 'Ocean-view apartment in Playacar', 'Departamento frente al mar dentro de Playacar, a pasos de la Quinta Avenida.', 'Beachfront apartment in Playacar, steps from Fifth Avenue.', '<p>Vista abierta al Caribe desde la sala y la recámara principal.</p><p>Condominio con seguridad 24 horas, alberca infinity y acceso directo a la playa.</p><ul><li>Acceso directo a la playa</li><li>Alberca infinity</li><li>Seguridad 24/7</li><li>A 5 minutos de la Quinta Avenida</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Open Caribbean views from the living room and the primary bedroom.</p><p>Gated community with 24-hour security, infinity pool and direct beach access.</p><ul><li>Direct beach access</li><li>Infinity pool</li><li>24/7 security</li><li>5 minutes from Fifth Avenue</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Playacar Fase I, Playa del Carmen, Quintana Roo, México', 'Playacar Phase I, Playa del Carmen, Quintana Roo, Mexico'),
  ('prop', 'residencia-puerto-cancun', 'Residencia en Puerto Cancún con muelle', 'Puerto Cancún residence with private dock', 'Residencia frente a la marina con muelle privado para yate.', 'Marina-front residence with a private yacht dock.', '<p>Casa de cinco recámaras en el desarrollo residencial más exclusivo de Cancún.</p><p>Doble altura en áreas sociales, cocina de chef y estancia frente al canal.</p><ul><li>Muelle privado</li><li>Club de golf y marina</li><li>Elevador</li><li>Cuarto de servicio</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Five-bedroom home in Cancun''s most exclusive residential community.</p><p>Double-height living areas, chef''s kitchen and a lounge facing the canal.</p><ul><li>Private dock</li><li>Golf club and marina</li><li>Elevator</li><li>Staff quarters</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Puerto Cancún, Cancún, Quintana Roo, México', 'Puerto Cancún, Cancun, Quintana Roo, Mexico'),
  ('prop', 'penthouse-polanco', 'Penthouse en Polanco con terraza panorámica', 'Polanco penthouse with panoramic terrace', 'Penthouse de lujo a una cuadra de Masaryk, con terraza de 80 m².', 'Luxury penthouse one block from Masaryk, with an 80 m² terrace.', '<p>Acabados en mármol y madera de nogal, con vista abierta a Chapultepec.</p><p>Edificio con lobby con concierge, gimnasio y dos lugares de estacionamiento.</p><ul><li>Terraza de 80 m²</li><li>Concierge 24/7</li><li>Cava y cuarto de servicio</li><li>A una cuadra de Masaryk</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Marble and walnut finishes, with open views over Chapultepec.</p><p>Building with concierge lobby, gym and two parking spaces.</p><ul><li>80 m² terrace</li><li>24/7 concierge</li><li>Wine cellar and staff room</li><li>One block from Masaryk</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Polanco V Sección, Ciudad de México, México', 'Polanco V Sección, Mexico City, Mexico'),
  ('prop', 'loft-condesa', 'Loft de diseño en la Condesa', 'Design loft in La Condesa', 'Loft amueblado en edificio art déco restaurado, frente al Parque México.', 'Furnished loft in a restored Art Deco building facing Parque México.', '<p>Loft de doble altura con mobiliario de diseño mexicano.</p><p>Renta mensual con servicios incluidos, ideal para ejecutivos y nómadas digitales.</p><ul><li>Amueblado y equipado</li><li>Servicios incluidos</li><li>Frente al Parque México</li><li>Contrato mínimo de 6 meses</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Double-height loft with Mexican design furniture.</p><p>Monthly rent with utilities included, ideal for executives and digital nomads.</p><ul><li>Fully furnished</li><li>Utilities included</li><li>Facing Parque México</li><li>6-month minimum lease</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Condesa, Ciudad de México, México', 'Condesa, Mexico City, Mexico'),
  ('prop', 'villa-pedregal-los-cabos', 'Villa en Pedregal con vista al mar de Cortés', 'Pedregal villa overlooking the Sea of Cortez', 'Villa sobre el acantilado con vista al Arco y al océano Pacífico.', 'Cliffside villa with views of the Arch and the Pacific Ocean.', '<p>Villa de cinco recámaras en la comunidad privada de El Pedregal.</p><p>Alberca infinity, terrazas escalonadas y atardeceres sobre el Pacífico.</p><ul><li>Vista al Arco</li><li>Alberca infinity</li><li>Comunidad con acceso controlado</li><li>A 5 minutos de la marina</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Five-bedroom villa in the private community of El Pedregal.</p><p>Infinity pool, terraced decks and Pacific sunsets.</p><ul><li>Views of the Arch</li><li>Infinity pool</li><li>Gated community</li><li>5 minutes from the marina</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'El Pedregal, Cabo San Lucas, Baja California Sur, México', 'El Pedregal, Cabo San Lucas, Baja California Sur, Mexico'),
  ('prop', 'condominio-conchas-chinas', 'Condominio en Conchas Chinas frente a la bahía', 'Conchas Chinas bay-front condo', 'Condominio frente a la Bahía de Banderas, a minutos de la Zona Romántica.', 'Condo facing Banderas Bay, minutes from the Romantic Zone.', '<p>Tres recámaras con vista panorámica a la Bahía de Banderas.</p><p>Edificio con alberca, gimnasio y acceso a playa privada.</p><ul><li>Vista a la bahía</li><li>Playa privada</li><li>Alberca y gimnasio</li><li>A 5 minutos de la Zona Romántica</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Three bedrooms with panoramic views of Banderas Bay.</p><p>Building with pool, gym and private beach access.</p><ul><li>Bay views</li><li>Private beach</li><li>Pool and gym</li><li>5 minutes from the Romantic Zone</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Conchas Chinas, Puerto Vallarta, Jalisco, México', 'Conchas Chinas, Puerto Vallarta, Jalisco, Mexico'),
  ('prop', 'casa-playa-tamarindo', 'Casa de playa en Tamarindo', 'Beach house in Tamarindo', 'Casa a pasos de Playa Langosta, en una de las costas más buscadas de Guanacaste.', 'Home steps from Playa Langosta, on one of Guanacaste''s most coveted coastlines.', '<p>Diseño tropical moderno con grandes ventanales y ventilación cruzada.</p><p>Jardín con palmeras, alberca y rancho exterior para disfrutar el atardecer.</p><ul><li>A pasos de la playa</li><li>Alberca y rancho</li><li>Título inscrito</li><li>A 30 minutos del aeropuerto de Liberia</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Modern tropical design with large windows and cross ventilation.</p><p>Palm garden, pool and outdoor rancho to enjoy the sunset.</p><ul><li>Steps from the beach</li><li>Pool and rancho</li><li>Registered title</li><li>30 minutes from Liberia airport</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Playa Langosta, Tamarindo, Guanacaste, Costa Rica', 'Playa Langosta, Tamarindo, Guanacaste, Costa Rica'),
  ('prop', 'villa-surf-santa-teresa', 'Villa de surf en Santa Teresa', 'Surf villa in Santa Teresa', 'Villa con vista al océano en las colinas de Santa Teresa, destino de surf de clase mundial.', 'Ocean-view villa in the hills of Santa Teresa, a world-class surf destination.', '<p>Tres suites independientes ideales para renta vacacional.</p><p>Vista al Pacífico desde todas las habitaciones y a cinco minutos de la playa.</p><ul><li>Vista al océano</li><li>Ideal para renta vacacional</li><li>Alberca infinity</li><li>A 5 minutos de la playa</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Three independent suites, ideal for vacation rental.</p><p>Pacific views from every room and five minutes from the beach.</p><ul><li>Ocean views</li><li>Ideal for vacation rental</li><li>Infinity pool</li><li>5 minutes from the beach</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Santa Teresa, Puntarenas, Costa Rica', 'Santa Teresa, Puntarenas, Costa Rica'),
  ('prop', 'residencia-escazu', 'Residencia en Escazú con vista al Valle Central', 'Escazú residence overlooking the Central Valley', 'Residencia en condominio privado con vista panorámica al Valle Central.', 'Residence in a private community with panoramic views of the Central Valley.', '<p>Cuatro recámaras con baño propio y estudio en el zona residencial más exclusiva de San José.</p><p>Condominio con seguridad, áreas verdes y cercanía a colegios internacionales.</p><ul><li>Vista al Valle Central</li><li>Condominio privado</li><li>Cerca de colegios internacionales</li><li>A 15 minutos de San José</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Four en-suite bedrooms and a study in San José''s most exclusive residential area.</p><p>Gated community with green areas, close to international schools.</p><ul><li>Central Valley views</li><li>Private community</li><li>Near international schools</li><li>15 minutes from San José</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'San Rafael de Escazú, San José, Costa Rica', 'San Rafael de Escazú, San José, Costa Rica'),
  ('prop', 'casa-heredia', 'Casa en condominio en Heredia', 'Gated-community home in Heredia', 'Casa familiar en condominio arbolado, con clima de montaña y vista a la ciudad.', 'Family home in a leafy community, with mountain climate and city views.', '<p>Tres recámaras, estudio y jardín privado en un entorno tranquilo y fresco.</p><p>Condominio con seguridad, casa club y senderos.</p><ul><li>Clima de montaña</li><li>Jardín privado</li><li>Casa club</li><li>A 25 minutos del aeropuerto</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Three bedrooms, a study and a private garden in a quiet, cool setting.</p><p>Gated community with clubhouse and walking trails.</p><ul><li>Mountain climate</li><li>Private garden</li><li>Clubhouse</li><li>25 minutes from the airport</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'San Rafael de Heredia, Costa Rica', 'San Rafael de Heredia, Costa Rica'),
  ('prop', 'condo-brickell', 'Condo en Brickell con vista a la bahía', 'Brickell condo with bay views', 'Condo de dos recámaras en torre de lujo con vista a la Bahía de Biscayne.', 'Two-bedroom condo in a luxury tower overlooking Biscayne Bay.', '<p>Ventanales de piso a techo, cocina italiana y balcón con vista a la bahía.</p><p>Torre con spa, alberca en el piso 40 y valet parking.</p><ul><li>Vista a la Bahía de Biscayne</li><li>Spa y alberca en altura</li><li>Valet parking</li><li>A pasos de Brickell City Centre</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Floor-to-ceiling windows, Italian kitchen and a balcony facing the bay.</p><p>Tower with spa, 40th-floor pool and valet parking.</p><ul><li>Biscayne Bay views</li><li>Spa and sky pool</li><li>Valet parking</li><li>Steps from Brickell City Centre</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Brickell, Miami, Florida, EE. UU.', 'Brickell, Miami, Florida, USA'),
  ('prop', 'penthouse-south-beach', 'Penthouse en South Beach frente al océano', 'Oceanfront penthouse in South Beach', 'Penthouse frente al océano en South of Fifth, con terraza privada y alberca.', 'Oceanfront penthouse in South of Fifth, with private terrace and pool.', '<p>Tres recámaras con vistas al Atlántico y a la bahía.</p><p>Terraza en la azotea con alberca privada y cocina de verano.</p><ul><li>Frente al océano</li><li>Alberca privada en la azotea</li><li>Servicios de hotel cinco estrellas</li><li>A pasos de Ocean Drive</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Three bedrooms with views of the Atlantic and the bay.</p><p>Rooftop terrace with private pool and summer kitchen.</p><ul><li>Oceanfront</li><li>Private rooftop pool</li><li>Five-star hotel services</li><li>Steps from Ocean Drive</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'South of Fifth, Miami Beach, Florida, EE. UU.', 'South of Fifth, Miami Beach, Florida, USA'),
  ('prop', 'residencia-key-biscayne', 'Residencia frente al agua en Key Biscayne', 'Waterfront residence in Key Biscayne', 'Residencia frente al agua con muelle privado en la isla de Key Biscayne.', 'Waterfront residence with private dock on the island of Key Biscayne.', '<p>Casa de cinco recámaras en terreno frente al agua con acceso al mar abierto.</p><p>Muelle para yate, alberca y jardín tropical, a 15 minutos de Brickell.</p><ul><li>Muelle privado</li><li>Acceso a mar abierto</li><li>Alberca y jardín tropical</li><li>A 15 minutos de Brickell</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Five-bedroom home on a waterfront lot with open-ocean access.</p><p>Yacht dock, pool and tropical garden, 15 minutes from Brickell.</p><ul><li>Private dock</li><li>Open-ocean access</li><li>Pool and tropical garden</li><li>15 minutes from Brickell</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Key Biscayne, Florida, EE. UU.', 'Key Biscayne, Florida, USA'),
  ('prop', 'casa-mediterranea-coral-gables', 'Casa mediterránea en Coral Gables', 'Mediterranean home in Coral Gables', 'Casa estilo mediterráneo en renta, en una de las zonas residenciales más tradicionales de Miami.', 'Mediterranean-style home for rent in one of Miami''s most traditional neighborhoods.', '<p>Cuatro recámaras, techos altos y patio interior con fuente.</p><p>Renta mensual cerca de colegios privados y del Biltmore Hotel.</p><ul><li>Estilo mediterráneo</li><li>Patio con alberca</li><li>Cerca de colegios privados</li><li>Contrato anual</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Four bedrooms, high ceilings and an inner courtyard with fountain.</p><p>Monthly rent near private schools and the Biltmore Hotel.</p><ul><li>Mediterranean style</li><li>Courtyard with pool</li><li>Near private schools</li><li>Annual lease</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Coral Gables, Florida, EE. UU.', 'Coral Gables, Florida, USA'),
  ('proj', 'aldea-ardenza-tulum', 'Aldea Ardenza Tulum', 'Aldea Ardenza Tulum', 'Desarrollo boutique de 48 residencias integradas a la selva, con club de playa.', 'Boutique development of 48 residences set in the jungle, with a beach club.', '<p>Departamentos y penthouses con roof privado, rodeados de selva.</p><p>Club de playa, spa y concierge para administración de rentas.</p><ul><li>48 residencias</li><li>Club de playa</li><li>Spa y gimnasio</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Apartments and penthouses with private rooftops, surrounded by jungle.</p><p>Beach club, spa and concierge for rental management.</p><ul><li>48 residences</li><li>Beach club</li><li>Spa and gym</li><li>Estimated delivery 2027</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Región 15, Tulum, Quintana Roo, México', 'Región 15, Tulum, Quintana Roo, Mexico'),
  ('proj', 'torre-mareas-cancun', 'Torre Mareas Cancún', 'Torre Mareas Cancun', 'Torre residencial frente al mar Caribe con amenidades tipo resort.', 'Beachfront residential tower on the Caribbean with resort-style amenities.', '<p>Departamentos de una a cuatro recámaras con vista al mar.</p><p>Alberca infinity, marina y restaurante privado para residentes.</p><ul><li>Frente al mar</li><li>Marina privada</li><li>Restaurante para residentes</li><li>Entrega estimada 2028</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>One- to four-bedroom apartments with ocean views.</p><p>Infinity pool, marina and a private residents'' restaurant.</p><ul><li>Beachfront</li><li>Private marina</li><li>Residents'' restaurant</li><li>Estimated delivery 2028</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Zona Hotelera, Cancún, Quintana Roo, México', 'Hotel Zone, Cancun, Quintana Roo, Mexico'),
  ('proj', 'residencias-polanco-uno', 'Residencias Polanco Uno', 'Residencias Polanco Uno', 'Edificio de autor con 36 residencias de lujo frente a Chapultepec.', 'Signature building with 36 luxury residences facing Chapultepec.', '<p>Residencias de dos a cuatro recámaras con terrazas ajardinadas.</p><p>Lobby con concierge, spa, cava y salón de eventos privado.</p><ul><li>36 residencias</li><li>Vista a Chapultepec</li><li>Concierge 24/7</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Two- to four-bedroom residences with landscaped terraces.</p><p>Concierge lobby, spa, wine cellar and private event room.</p><ul><li>36 residences</li><li>Chapultepec views</li><li>24/7 concierge</li><li>Estimated delivery 2027</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Polanco, Ciudad de México, México', 'Polanco, Mexico City, Mexico'),
  ('proj', 'tamarindo-bay-residences', 'Tamarindo Bay Residences', 'Tamarindo Bay Residences', 'Condominio de playa con 30 residencias a pasos de la bahía de Tamarindo.', 'Beach community of 30 residences steps from Tamarindo Bay.', '<p>Villas y departamentos con diseño tropical contemporáneo.</p><p>Club de playa, alberca y administración de rentas vacacionales.</p><ul><li>30 residencias</li><li>A pasos de la playa</li><li>Administración de rentas</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Villas and apartments in contemporary tropical design.</p><p>Beach club, pool and vacation-rental management.</p><ul><li>30 residences</li><li>Steps from the beach</li><li>Rental management</li><li>Estimated delivery 2027</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Tamarindo, Guanacaste, Costa Rica', 'Tamarindo, Guanacaste, Costa Rica'),
  ('proj', 'escazu-hills', 'Escazú Hills', 'Escazú Hills', 'Residencias con vista al Valle Central en las colinas de Escazú.', 'Residences overlooking the Central Valley in the hills of Escazú.', '<p>Departamentos amplios con terrazas y vista panorámica.</p><p>Senderos, casa club y seguridad las 24 horas.</p><ul><li>40 residencias</li><li>Vista al Valle Central</li><li>Casa club</li><li>Entrega estimada 2027</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>Spacious apartments with terraces and panoramic views.</p><p>Trails, clubhouse and 24-hour security.</p><ul><li>40 residences</li><li>Central Valley views</li><li>Clubhouse</li><li>Estimated delivery 2027</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Escazú, San José, Costa Rica', 'Escazú, San José, Costa Rica'),
  ('proj', 'brickell-bay-tower', 'Brickell Bay Tower', 'Brickell Bay Tower', 'Torre de lujo frente a la Bahía de Biscayne con amenidades de hotel cinco estrellas.', 'Luxury tower on Biscayne Bay with five-star hotel amenities.', '<p>Residencias de una a cinco recámaras con vista a la bahía y al océano.</p><p>Spa, club privado, alberca en altura y servicio de valet.</p><ul><li>210 residencias</li><li>Frente a la bahía</li><li>Club privado</li><li>Entrega estimada 2028</li></ul><p><em>Ficha de demostración · Ardenza Propiedades by FLAMIA.</em></p>', '<p>One- to five-bedroom residences with bay and ocean views.</p><p>Spa, private club, sky pool and valet service.</p><ul><li>210 residences</li><li>Bayfront</li><li>Private club</li><li>Estimated delivery 2028</li></ul><p><em>Demo listing · Ardenza Estates by FLAMIA.</em></p>', 'Brickell Bay Drive, Miami, Florida, EE. UU.', 'Brickell Bay Drive, Miami, Florida, USA'),
  ('post', 'comprar-propiedad-en-mexico-siendo-extranjero', 'Cómo comprar propiedad en México siendo extranjero', 'How to buy property in Mexico as a foreigner', 'El fideicomiso bancario y otras claves para invertir en la costa mexicana.', 'The bank trust (fideicomiso) and other keys to investing on the Mexican coast.', '<p>Los extranjeros pueden comprar propiedades en México. En la llamada zona restringida —50 km desde la costa y 100 km desde las fronteras— la compra se hace a través de un fideicomiso bancario o de una sociedad mexicana.</p><p>El fideicomiso da al comprador todos los derechos de uso, renta y venta del inmueble, y se puede heredar.</p><p>Antes de firmar, conviene revisar el título, el certificado de libertad de gravamen y el uso de suelo con un notario público.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em></p>', '<p>Foreigners can buy property in Mexico. In the so-called restricted zone — 50 km from the coast and 100 km from the borders — the purchase is made through a bank trust (fideicomiso) or a Mexican corporation.</p><p>The trust gives the buyer full rights to use, rent and sell the property, and it can be inherited.</p><p>Before signing, review the title, the lien certificate and the land use with a notary public.</p><p><em>Demo informational content. Always consult a legal advisor.</em></p>', NULL, NULL),
  ('post', 'tulum-o-playa-del-carmen-donde-invertir', 'Tulum o Playa del Carmen: dónde invertir', 'Tulum or Playa del Carmen: where to invest', 'Dos destinos del Caribe mexicano con perfiles de inversión distintos.', 'Two Mexican Caribbean destinations with different investment profiles.', '<p>Tulum atrae a compradores que buscan diseño, naturaleza y renta vacacional de alto valor por noche.</p><p>Playa del Carmen ofrece un mercado más consolidado, con demanda de renta durante todo el año y mejor conectividad.</p><p>La decisión depende del horizonte de inversión, del uso personal que se planee y del nivel de riesgo aceptable.</p><p><em>Contenido informativo de demostración.</em></p>', '<p>Tulum attracts buyers looking for design, nature and high nightly-rate vacation rentals.</p><p>Playa del Carmen offers a more established market, with year-round rental demand and better connectivity.</p><p>The decision depends on your investment horizon, planned personal use and acceptable level of risk.</p><p><em>Demo informational content.</em></p>', NULL, NULL),
  ('post', 'comprar-en-guanacaste-costa-rica', 'Comprar en Guanacaste, Costa Rica, paso a paso', 'Buying in Guanacaste, Costa Rica, step by step', 'Lo que un comprador internacional debe saber antes de invertir en la costa del Pacífico.', 'What an international buyer should know before investing on the Pacific coast.', '<p>En Costa Rica, los extranjeros pueden tener propiedades con título inscrito con los mismos derechos que los nacionales.</p><p>La franja de 200 metros desde la pleamar es zona marítimo-terrestre: los primeros 50 metros son públicos y el resto se otorga en concesión.</p><p>Por eso es clave confirmar si la propiedad tiene título inscrito o concesión antes de comprar.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor legal.</em></p>', '<p>In Costa Rica, foreigners can hold titled property with the same rights as nationals.</p><p>The 200-meter strip from the high-tide line is the maritime zone: the first 50 meters are public and the rest is granted as a concession.</p><p>That is why it is key to confirm whether a property has registered title or a concession before buying.</p><p><em>Demo informational content. Always consult a legal advisor.</em></p>', NULL, NULL),
  ('post', 'miami-para-compradores-latinoamericanos', 'Miami para compradores latinoamericanos', 'Miami for Latin American buyers', 'Por qué Miami sigue siendo el destino favorito de la inversión latinoamericana.', 'Why Miami remains the favorite destination for Latin American investment.', '<p>Miami combina estabilidad del dólar, conectividad con toda Latinoamérica y un mercado de lujo profundo.</p><p>Los compradores extranjeros pueden adquirir propiedades sin residencia. Al vender, aplica una retención fiscal (FIRPTA) que conviene planear desde la compra.</p><p>Brickell, Miami Beach, Key Biscayne y Coral Gables concentran la mayor demanda internacional.</p><p><em>Contenido informativo de demostración. Consulta siempre a un asesor fiscal.</em></p>', '<p>Miami combines the stability of the dollar, connectivity with all of Latin America and a deep luxury market.</p><p>Foreign buyers can purchase property without residency. When selling, a tax withholding (FIRPTA) applies, which is worth planning from the purchase.</p><p>Brickell, Miami Beach, Key Biscayne and Coral Gables concentrate most international demand.</p><p><em>Demo informational content. Always consult a tax advisor.</em></p>', NULL, NULL),
  ('post', 'renta-vacacional-en-el-caribe-mexicano', 'Renta vacacional en el Caribe mexicano', 'Vacation rentals in the Mexican Caribbean', 'Cómo evaluar el rendimiento de una propiedad para renta de corto plazo.', 'How to evaluate a property''s short-term rental returns.', '<p>La renta vacacional puede generar ingresos atractivos, pero depende de la ocupación, la tarifa por noche y los costos de administración.</p><p>Conviene revisar el reglamento del condominio, los permisos locales y la oferta comparable en la zona.</p><p>Una administradora profesional puede encargarse de reservas, limpieza y mantenimiento.</p><p><em>Contenido informativo de demostración.</em></p>', '<p>Vacation rentals can generate attractive income, but they depend on occupancy, nightly rate and management costs.</p><p>Review the condominium rules, local permits and comparable supply in the area.</p><p>A professional management company can handle bookings, cleaning and maintenance.</p><p><em>Demo informational content.</em></p>', NULL, NULL),
  ('post', 'como-evaluar-un-desarrollo-en-preventa', 'Cómo evaluar un desarrollo en preventa', 'How to evaluate a pre-construction development', 'Preguntas clave antes de comprar en un proyecto que aún está en construcción.', 'Key questions before buying in a project that is still under construction.', '<p>La preventa permite comprar a mejor precio, a cambio de esperar la entrega.</p><p>Revisa la trayectoria del desarrollador, los permisos de construcción, el esquema de pagos y las garantías de entrega.</p><p>Visitar la obra y hablar con compradores de proyectos anteriores ayuda a reducir el riesgo.</p><p><em>Contenido informativo de demostración.</em></p>', '<p>Pre-construction lets you buy at a better price in exchange for waiting for delivery.</p><p>Review the developer''s track record, building permits, payment schedule and delivery guarantees.</p><p>Visiting the site and talking to buyers from previous projects helps reduce risk.</p><p><em>Demo informational content.</em></p>', NULL, NULL);
DROP TABLE IF EXISTS ard_m;
CREATE TABLE ard_m (kind VARCHAR(10), ref_id BIGINT UNSIGNED, slug VARCHAR(190), sfx VARCHAR(60) DEFAULT '', PRIMARY KEY (kind, ref_id))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- re_properties
INSERT IGNORE INTO ard_m (kind, ref_id, slug)
SELECT 'prop', s.reference_id, t.slug FROM slugs s
JOIN ard_t t ON t.kind = 'prop' AND (s.`key` = t.slug OR s.`key` = CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%RealEstate%Models%Property';
-- Sufijo de las copias (« · 2», « · Fase 2», « (2)») para conservarlo en el otro idioma.
UPDATE ard_m m JOIN re_properties b ON b.id = m.ref_id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET m.sfx = CASE WHEN b.name LIKE CONCAT(t.es_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.es_name) + 1)
                 WHEN b.name LIKE CONCAT(t.en_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.en_name) + 1)
                 ELSE '' END
WHERE m.kind = 'prop';
DELETE tr FROM re_properties_translations tr
JOIN ard_m m ON m.kind = 'prop' AND m.ref_id = tr.re_properties_id
JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO re_properties_translations (lang_code, re_properties_id, name, description, content, location)
SELECT o.code, m.ref_id, CONCAT(IF(@def_en, t.es_name, t.en_name), m.sfx), IF(@def_en, t.es_desc, t.en_desc),
       IF(@def_en, t.es_content, t.en_content), IF(@def_en, t.es_loc, t.en_loc)
FROM ard_m m JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug JOIN ard_lang o ON o.k = 'otro'
WHERE m.kind = 'prop';
-- Solo si el idioma principal es inglés: la tabla base pasa a inglés.
UPDATE re_properties b JOIN ard_m m ON m.kind = 'prop' AND m.ref_id = b.id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET b.description = t.en_desc, b.content = t.en_content,
    b.location = t.en_loc,
    b.name = CONCAT(t.en_name, m.sfx)
WHERE @def_en = 1;
-- re_projects
INSERT IGNORE INTO ard_m (kind, ref_id, slug)
SELECT 'proj', s.reference_id, t.slug FROM slugs s
JOIN ard_t t ON t.kind = 'proj' AND (s.`key` = t.slug OR s.`key` = CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%RealEstate%Models%Project';
-- Sufijo de las copias (« · 2», « · Fase 2», « (2)») para conservarlo en el otro idioma.
UPDATE ard_m m JOIN re_projects b ON b.id = m.ref_id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET m.sfx = CASE WHEN b.name LIKE CONCAT(t.es_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.es_name) + 1)
                 WHEN b.name LIKE CONCAT(t.en_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.en_name) + 1)
                 ELSE '' END
WHERE m.kind = 'proj';
DELETE tr FROM re_projects_translations tr
JOIN ard_m m ON m.kind = 'proj' AND m.ref_id = tr.re_projects_id
JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO re_projects_translations (lang_code, re_projects_id, name, description, content, location)
SELECT o.code, m.ref_id, CONCAT(IF(@def_en, t.es_name, t.en_name), m.sfx), IF(@def_en, t.es_desc, t.en_desc),
       IF(@def_en, t.es_content, t.en_content), IF(@def_en, t.es_loc, t.en_loc)
FROM ard_m m JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug JOIN ard_lang o ON o.k = 'otro'
WHERE m.kind = 'proj';
-- Solo si el idioma principal es inglés: la tabla base pasa a inglés.
UPDATE re_projects b JOIN ard_m m ON m.kind = 'proj' AND m.ref_id = b.id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET b.description = t.en_desc, b.content = t.en_content,
    b.location = t.en_loc,
    b.name = CONCAT(t.en_name, m.sfx)
WHERE @def_en = 1;
-- posts
INSERT IGNORE INTO ard_m (kind, ref_id, slug)
SELECT 'post', s.reference_id, t.slug FROM slugs s
JOIN ard_t t ON t.kind = 'post' AND (s.`key` = t.slug OR s.`key` = CONCAT(t.slug, '-', s.reference_id))
WHERE s.reference_type LIKE '%Blog%Models%Post';
-- Sufijo de las copias (« · 2», « · Fase 2», « (2)») para conservarlo en el otro idioma.
UPDATE ard_m m JOIN posts b ON b.id = m.ref_id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET m.sfx = CASE WHEN b.name LIKE CONCAT(t.es_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.es_name) + 1)
                 WHEN b.name LIKE CONCAT(t.en_name, '%') THEN SUBSTRING(b.name, CHAR_LENGTH(t.en_name) + 1)
                 ELSE '' END
WHERE m.kind = 'post';
DELETE tr FROM posts_translations tr
JOIN ard_m m ON m.kind = 'post' AND m.ref_id = tr.posts_id
JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
INSERT INTO posts_translations (lang_code, posts_id, name, description, content)
SELECT o.code, m.ref_id, CONCAT(IF(@def_en, t.es_name, t.en_name), m.sfx), IF(@def_en, t.es_desc, t.en_desc),
       IF(@def_en, t.es_content, t.en_content)
FROM ard_m m JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug JOIN ard_lang o ON o.k = 'otro'
WHERE m.kind = 'post';
-- Solo si el idioma principal es inglés: la tabla base pasa a inglés.
UPDATE posts b JOIN ard_m m ON m.kind = 'post' AND m.ref_id = b.id JOIN ard_t t ON t.kind = m.kind AND t.slug = m.slug
SET b.description = t.en_desc, b.content = t.en_content,
    b.name = CONCAT(t.en_name, m.sfx)
WHERE @def_en = 1;

-- 2. Ubicaciones -------------------------------------------------------------
DROP TABLE IF EXISTS ard_loc;
CREATE TABLE ard_loc (kind VARCHAR(10), es VARCHAR(120), en VARCHAR(120), es_nat VARCHAR(120), en_nat VARCHAR(120)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_loc (kind, es, en, es_nat, en_nat) VALUES
  ('country', 'México', 'Mexico', 'Mexicana', 'Mexican'),
  ('country', 'Costa Rica', 'Costa Rica', 'Costarricense', 'Costa Rican'),
  ('country', 'Estados Unidos', 'United States', 'Estadounidense', 'American'),
  ('state', 'Ciudad de México', 'Mexico City', NULL, NULL),
  ('city', 'Ciudad de México', 'Mexico City', NULL, NULL),
  ('city', 'Cancún', 'Cancun', NULL, NULL);
DELETE tr FROM countries_translations tr JOIN countries b ON b.id = tr.countries_id
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

-- 2b. Categorías, características, lugares cercanos y categorías del blog -------
DROP TABLE IF EXISTS ard_d;
CREATE TABLE ard_d (kind VARCHAR(10), src VARCHAR(190), es VARCHAR(190), en VARCHAR(190)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_d (kind, src, es, en) VALUES
  ('recat', 'Departamento', 'Departamento', 'Apartment'),
  ('recat', 'Apartment', 'Departamento', 'Apartment'),
  ('recat', 'Apartamento', 'Departamento', 'Apartment'),
  ('recat', 'Apartamentos', 'Departamento', 'Apartment'),
  ('recat', 'Departamentos', 'Departamento', 'Apartment'),
  ('recat', 'Villa', 'Villa', 'Villa'),
  ('recat', 'Villas', 'Villa', 'Villa'),
  ('recat', 'Condominio', 'Condominio', 'Condo'),
  ('recat', 'Condo', 'Condominio', 'Condo'),
  ('recat', 'Condos', 'Condominio', 'Condo'),
  ('recat', 'Condominios', 'Condominio', 'Condo'),
  ('recat', 'Casa', 'Casa', 'House'),
  ('recat', 'House', 'Casa', 'House'),
  ('recat', 'Casas', 'Casa', 'House'),
  ('recat', 'Houses', 'Casa', 'House'),
  ('recat', 'Terreno', 'Terreno', 'Land'),
  ('recat', 'Land', 'Terreno', 'Land'),
  ('recat', 'Lote', 'Terreno', 'Land'),
  ('recat', 'Lotes', 'Terreno', 'Land'),
  ('recat', 'Terrenos', 'Terreno', 'Land'),
  ('recat', 'Local comercial', 'Local comercial', 'Commercial property'),
  ('recat', 'Commercial property', 'Local comercial', 'Commercial property'),
  ('recat', 'Local', 'Local comercial', 'Commercial property'),
  ('recat', 'Locales', 'Local comercial', 'Commercial property'),
  ('recat', 'Commercial', 'Local comercial', 'Commercial property'),
  ('recat', 'Oficina', 'Oficina', 'Office'),
  ('recat', 'Office', 'Oficina', 'Office'),
  ('recat', 'Oficinas', 'Oficina', 'Office'),
  ('recat', 'Offices', 'Oficina', 'Office'),
  ('recat', 'Penthouse', 'Penthouse', 'Penthouse'),
  ('recat', 'Finca', 'Finca', 'Farm'),
  ('recat', 'Farm', 'Finca', 'Farm'),
  ('recat', 'Fincas', 'Finca', 'Farm'),
  ('recat', 'Rancho', 'Finca', 'Farm'),
  ('refeat', 'Wifi', 'Wifi', 'Wifi'),
  ('refeat', 'Wi-Fi', 'Wifi', 'Wifi'),
  ('refeat', 'WiFi', 'Wifi', 'Wifi'),
  ('refeat', 'Estacionamiento', 'Estacionamiento', 'Parking'),
  ('refeat', 'Parking', 'Estacionamiento', 'Parking'),
  ('refeat', 'Parqueadero', 'Estacionamiento', 'Parking'),
  ('refeat', 'Garaje', 'Estacionamiento', 'Parking'),
  ('refeat', 'Alberca', 'Alberca', 'Swimming pool'),
  ('refeat', 'Swimming pool', 'Alberca', 'Swimming pool'),
  ('refeat', 'Piscina', 'Alberca', 'Swimming pool'),
  ('refeat', 'Pool', 'Alberca', 'Swimming pool'),
  ('refeat', 'Balcón', 'Balcón', 'Balcony'),
  ('refeat', 'Balcony', 'Balcón', 'Balcony'),
  ('refeat', 'Jardín', 'Jardín', 'Garden'),
  ('refeat', 'Garden', 'Jardín', 'Garden'),
  ('refeat', 'Seguridad 24/7', 'Seguridad 24/7', '24/7 security'),
  ('refeat', '24/7 security', 'Seguridad 24/7', '24/7 security'),
  ('refeat', 'Security', 'Seguridad 24/7', '24/7 security'),
  ('refeat', 'Seguridad', 'Seguridad 24/7', '24/7 security'),
  ('refeat', 'Portería', 'Seguridad 24/7', '24/7 security'),
  ('refeat', 'Gimnasio', 'Gimnasio', 'Fitness center'),
  ('refeat', 'Fitness center', 'Gimnasio', 'Fitness center'),
  ('refeat', 'Gym', 'Gimnasio', 'Fitness center'),
  ('refeat', 'Aire acondicionado', 'Aire acondicionado', 'Air conditioning'),
  ('refeat', 'Air conditioning', 'Aire acondicionado', 'Air conditioning'),
  ('refeat', 'Air Conditioning', 'Aire acondicionado', 'Air conditioning'),
  ('refeat', 'Calefacción central', 'Calefacción central', 'Central heating'),
  ('refeat', 'Central heating', 'Calefacción central', 'Central heating'),
  ('refeat', 'Central Heating', 'Calefacción central', 'Central heating'),
  ('refeat', 'Calefacción', 'Calefacción central', 'Central heating'),
  ('refeat', 'Cuarto de lavado', 'Cuarto de lavado', 'Laundry room'),
  ('refeat', 'Laundry room', 'Cuarto de lavado', 'Laundry room'),
  ('refeat', 'Laundry Room', 'Cuarto de lavado', 'Laundry room'),
  ('refeat', 'Lavandería', 'Cuarto de lavado', 'Laundry room'),
  ('refeat', 'Se aceptan mascotas', 'Se aceptan mascotas', 'Pets allowed'),
  ('refeat', 'Pets allowed', 'Se aceptan mascotas', 'Pets allowed'),
  ('refeat', 'Pets Allow', 'Se aceptan mascotas', 'Pets allowed'),
  ('refeat', 'Pet friendly', 'Se aceptan mascotas', 'Pets allowed'),
  ('refeat', 'Mascotas', 'Se aceptan mascotas', 'Pets allowed'),
  ('refeat', 'Spa y masajes', 'Spa y masajes', 'Spa & massage'),
  ('refeat', 'Spa & massage', 'Spa y masajes', 'Spa & massage'),
  ('refeat', 'Spa & Massage', 'Spa y masajes', 'Spa & massage'),
  ('refeat', 'Elevador', 'Elevador', 'Elevator'),
  ('refeat', 'Elevator', 'Elevador', 'Elevator'),
  ('refeat', 'Ascensor', 'Elevador', 'Elevator'),
  ('refeat', 'Terraza', 'Terraza', 'Terrace'),
  ('refeat', 'Terrace', 'Terraza', 'Terrace'),
  ('refeat', 'Vista al mar', 'Vista al mar', 'Ocean view'),
  ('refeat', 'Ocean view', 'Vista al mar', 'Ocean view'),
  ('refeat', 'Sea view', 'Vista al mar', 'Ocean view'),
  ('refac', 'Hospital', 'Hospital', 'Hospital'),
  ('refac', 'Supermercado', 'Supermercado', 'Supermarket'),
  ('refac', 'Supermarket', 'Supermercado', 'Supermarket'),
  ('refac', 'Super Market', 'Supermercado', 'Supermarket'),
  ('refac', 'Escuela', 'Escuela', 'School'),
  ('refac', 'School', 'Escuela', 'School'),
  ('refac', 'Colegio', 'Escuela', 'School'),
  ('refac', 'Entretenimiento', 'Entretenimiento', 'Entertainment'),
  ('refac', 'Entertainment', 'Entretenimiento', 'Entertainment'),
  ('refac', 'Farmacia', 'Farmacia', 'Pharmacy'),
  ('refac', 'Pharmacy', 'Farmacia', 'Pharmacy'),
  ('refac', 'Droguería', 'Farmacia', 'Pharmacy'),
  ('refac', 'Aeropuerto', 'Aeropuerto', 'Airport'),
  ('refac', 'Airport', 'Aeropuerto', 'Airport'),
  ('refac', 'Estación de tren', 'Estación de tren', 'Train station'),
  ('refac', 'Train station', 'Estación de tren', 'Train station'),
  ('refac', 'Railways', 'Estación de tren', 'Train station'),
  ('refac', 'Parada de autobús', 'Parada de autobús', 'Bus stop'),
  ('refac', 'Bus stop', 'Parada de autobús', 'Bus stop'),
  ('refac', 'Bus Stop', 'Parada de autobús', 'Bus stop'),
  ('refac', 'Parada de bus', 'Parada de autobús', 'Bus stop'),
  ('refac', 'Playa', 'Playa', 'Beach'),
  ('refac', 'Beach', 'Playa', 'Beach'),
  ('refac', 'Centro comercial', 'Centro comercial', 'Shopping mall'),
  ('refac', 'Shopping mall', 'Centro comercial', 'Shopping mall'),
  ('refac', 'Mall', 'Centro comercial', 'Shopping mall'),
  ('refac', 'Banco', 'Banco', 'Bank'),
  ('refac', 'Bank', 'Banco', 'Bank'),
  ('blogcat', 'Inicio', 'Inicio', 'Home'),
  ('blogcat', 'Home', 'Inicio', 'Home'),
  ('blogcat', 'Desarrollos', 'Desarrollos', 'Developments'),
  ('blogcat', 'Developments', 'Desarrollos', 'Developments'),
  ('blogcat', 'Projects', 'Desarrollos', 'Developments'),
  ('blogcat', 'Proyectos', 'Desarrollos', 'Developments'),
  ('blogcat', 'Propiedades', 'Propiedades', 'Properties'),
  ('blogcat', 'Properties', 'Propiedades', 'Properties'),
  ('blogcat', 'Agentes', 'Agentes', 'Agents'),
  ('blogcat', 'Agents', 'Agentes', 'Agents'),
  ('blogcat', 'Realtors', 'Agentes', 'Agents'),
  ('blogcat', 'Asesores', 'Agentes', 'Agents'),
  ('blogcat', 'Noticias', 'Noticias', 'News'),
  ('blogcat', 'News', 'Noticias', 'News'),
  ('blogcat', 'Blog', 'Noticias', 'News'),
  ('blogcat', 'Empleos', 'Empleos', 'Careers'),
  ('blogcat', 'Careers', 'Empleos', 'Careers'),
  ('blogcat', 'Trabaja con nosotros', 'Empleos', 'Careers'),
  ('blogcat', 'Contacto', 'Contacto', 'Contact'),
  ('blogcat', 'Contact', 'Contacto', 'Contact'),
  ('blogcat', 'Contáctanos', 'Contáctanos', 'Contact us'),
  ('blogcat', 'Contact us', 'Contáctanos', 'Contact us'),
  ('blogcat', 'Contáctenos', 'Contáctanos', 'Contact us'),
  ('blogcat', 'Nosotros', 'Nosotros', 'About us'),
  ('blogcat', 'About us', 'Nosotros', 'About us'),
  ('blogcat', 'About', 'Nosotros', 'About us'),
  ('blogcat', 'About Us', 'Nosotros', 'About us'),
  ('blogcat', 'Sobre nosotros', 'Nosotros', 'About us'),
  ('blogcat', 'Quiénes somos', 'Nosotros', 'About us'),
  ('blogcat', 'Términos y condiciones', 'Términos y condiciones', 'Terms & Conditions'),
  ('blogcat', 'Terms & Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('blogcat', 'Terms and Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('blogcat', 'Terms Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('blogcat', 'Terms & conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('blogcat', 'Política de privacidad', 'Política de privacidad', 'Privacy Policy'),
  ('blogcat', 'Privacy Policy', 'Política de privacidad', 'Privacy Policy'),
  ('blogcat', 'Privacy policy', 'Política de privacidad', 'Privacy Policy'),
  ('blogcat', 'Política de cookies', 'Política de cookies', 'Cookie Policy'),
  ('blogcat', 'Cookie Policy', 'Política de cookies', 'Cookie Policy'),
  ('blogcat', 'Cookie policy', 'Política de cookies', 'Cookie Policy'),
  ('blogcat', 'Cookies Policy', 'Política de cookies', 'Cookie Policy'),
  ('blogcat', 'Preguntas frecuentes', 'Preguntas frecuentes', 'FAQ'),
  ('blogcat', 'FAQ', 'Preguntas frecuentes', 'FAQ'),
  ('blogcat', 'FAQs', 'Preguntas frecuentes', 'FAQ'),
  ('blogcat', 'En venta', 'En venta', 'For sale'),
  ('blogcat', 'For sale', 'En venta', 'For sale'),
  ('blogcat', 'Sale', 'En venta', 'For sale'),
  ('blogcat', 'Venta', 'En venta', 'For sale'),
  ('blogcat', 'En renta', 'En renta', 'For rent'),
  ('blogcat', 'For rent', 'En renta', 'For rent'),
  ('blogcat', 'Rent', 'En renta', 'For rent'),
  ('blogcat', 'Renta', 'En renta', 'For rent'),
  ('blogcat', 'Arriendo', 'En renta', 'For rent'),
  ('blogcat', 'Propiedades en venta', 'Propiedades en venta', 'Properties for sale'),
  ('blogcat', 'Properties for sale', 'Propiedades en venta', 'Properties for sale'),
  ('blogcat', 'Properties For Sale', 'Propiedades en venta', 'Properties for sale'),
  ('blogcat', 'Propiedades en renta', 'Propiedades en renta', 'Properties for rent'),
  ('blogcat', 'Properties for rent', 'Propiedades en renta', 'Properties for rent'),
  ('blogcat', 'Properties For Rent', 'Propiedades en renta', 'Properties for rent'),
  ('blogcat', 'Enlaces rápidos', 'Enlaces rápidos', 'Quick links'),
  ('blogcat', 'Quick links', 'Enlaces rápidos', 'Quick links'),
  ('blogcat', 'Quick Links', 'Enlaces rápidos', 'Quick links'),
  ('blogcat', 'Enlaces útiles', 'Enlaces útiles', 'Useful links'),
  ('blogcat', 'Useful links', 'Enlaces útiles', 'Useful links'),
  ('blogcat', 'Useful Links', 'Enlaces útiles', 'Useful links'),
  ('blogcat', 'Información', 'Información', 'Information'),
  ('blogcat', 'Information', 'Información', 'Information'),
  ('blogcat', 'Categorías', 'Categorías', 'Categories'),
  ('blogcat', 'Categories', 'Categorías', 'Categories'),
  ('blogcat', 'Artículos recientes', 'Artículos recientes', 'Recent posts'),
  ('blogcat', 'Recent posts', 'Artículos recientes', 'Recent posts'),
  ('blogcat', 'Recent Posts', 'Artículos recientes', 'Recent posts'),
  ('blogcat', 'Últimas noticias', 'Últimas noticias', 'Latest news'),
  ('blogcat', 'Latest news', 'Últimas noticias', 'Latest news'),
  ('blogcat', 'Latest News', 'Últimas noticias', 'Latest news'),
  ('blogcat', 'Arquitectura', 'Arquitectura', 'Architecture'),
  ('blogcat', 'Architecture', 'Arquitectura', 'Architecture'),
  ('blogcat', 'House architecture', 'Arquitectura', 'Architecture'),
  ('blogcat', 'Diseño de interiores', 'Diseño de interiores', 'Interior design'),
  ('blogcat', 'Interior design', 'Diseño de interiores', 'Interior design'),
  ('blogcat', 'House design', 'Diseño de interiores', 'Interior design'),
  ('blogcat', 'Materiales de construcción', 'Materiales de construcción', 'Building materials'),
  ('blogcat', 'Building materials', 'Materiales de construcción', 'Building materials'),
  ('blogcat', 'Inversión', 'Inversión', 'Investment'),
  ('blogcat', 'Investment', 'Inversión', 'Investment'),
  ('blogcat', 'Estilo de vida', 'Estilo de vida', 'Lifestyle'),
  ('blogcat', 'Lifestyle', 'Estilo de vida', 'Lifestyle');
DROP PROCEDURE IF EXISTS ard_nombres;
DELIMITER $$
CREATE PROCEDURE ard_nombres()
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 're_categories_translations') THEN
    DELETE tr FROM re_categories_translations tr
    JOIN re_categories b ON b.id = tr.re_categories_id JOIN ard_d d ON d.kind = 'recat' AND d.src = b.name
    JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
    INSERT INTO re_categories_translations (lang_code, re_categories_id, name, description)
    SELECT o.code, b.id, IF(@def_en, d.es, d.en), b.description
    FROM re_categories b JOIN ard_d d ON d.kind = 'recat' AND d.src = b.name JOIN ard_lang o ON o.k = 'otro'
    GROUP BY b.id;
    UPDATE re_categories b JOIN ard_d d ON d.kind = 'recat' AND d.src = b.name SET b.name = IF(@def_en, d.en, d.es);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 're_features_translations') THEN
    DELETE tr FROM re_features_translations tr
    JOIN re_features b ON b.id = tr.re_features_id JOIN ard_d d ON d.kind = 'refeat' AND d.src = b.name
    JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
    INSERT INTO re_features_translations (lang_code, re_features_id, name)
    SELECT o.code, b.id, IF(@def_en, d.es, d.en)
    FROM re_features b JOIN ard_d d ON d.kind = 'refeat' AND d.src = b.name JOIN ard_lang o ON o.k = 'otro'
    GROUP BY b.id;
    UPDATE re_features b JOIN ard_d d ON d.kind = 'refeat' AND d.src = b.name SET b.name = IF(@def_en, d.en, d.es);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 're_facilities_translations') THEN
    DELETE tr FROM re_facilities_translations tr
    JOIN re_facilities b ON b.id = tr.re_facilities_id JOIN ard_d d ON d.kind = 'refac' AND d.src = b.name
    JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
    INSERT INTO re_facilities_translations (lang_code, re_facilities_id, name)
    SELECT o.code, b.id, IF(@def_en, d.es, d.en)
    FROM re_facilities b JOIN ard_d d ON d.kind = 'refac' AND d.src = b.name JOIN ard_lang o ON o.k = 'otro'
    GROUP BY b.id;
    UPDATE re_facilities b JOIN ard_d d ON d.kind = 'refac' AND d.src = b.name SET b.name = IF(@def_en, d.en, d.es);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'categories_translations') THEN
    DELETE tr FROM categories_translations tr
    JOIN categories b ON b.id = tr.categories_id JOIN ard_d d ON d.kind = 'blogcat' AND d.src = b.name
    JOIN ard_lang o ON o.k = 'otro' AND o.code = tr.lang_code;
    INSERT INTO categories_translations (lang_code, categories_id, name, description)
    SELECT o.code, b.id, IF(@def_en, d.es, d.en), b.description
    FROM categories b JOIN ard_d d ON d.kind = 'blogcat' AND d.src = b.name JOIN ard_lang o ON o.k = 'otro'
    GROUP BY b.id;
    UPDATE categories b JOIN ard_d d ON d.kind = 'blogcat' AND d.src = b.name SET b.name = IF(@def_en, d.en, d.es);
  END IF;
END$$
DELIMITER ;
CALL ard_nombres();
DROP PROCEDURE ard_nombres;

-- 3. Páginas -----------------------------------------------------------------
DROP TABLE IF EXISTS ard_p;
CREATE TABLE ard_p (n INT AUTO_INCREMENT PRIMARY KEY, scope VARCHAR(10), src VARCHAR(400), es VARCHAR(400), en VARCHAR(400))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_p (scope, src, es, en) VALUES
  ('attr', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('attr', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('attr', 'We make the best choices with the hottest and most prestigious projects, please visit the details below to find out more.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('attr', 'Estas son las propiedades de lujo disponibles para compra', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('attr', 'Luxury properties currently available for purchase', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('attr', 'Below is a list of properties that are currently up for sale', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('attr', 'Estas son las residencias disponibles para renta', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('attr', 'Luxury residences currently available for rent', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('attr', 'Below is a detailed price list of houses for rent', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('attr', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('attr', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('attr', 'Below is the latest real estate news we get regularly updated from reliable sources.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('attr', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('attr', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('attr', 'Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful properties.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('attr', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('attr', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('attr', 'Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful projects.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('attr', 'Encuentra la propiedad de tus sueños', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('attr', 'Find the home of your dreams', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('attr', 'Find your favorite homes at Flex Home', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('attr', 'Desarrollos destacados', 'Desarrollos destacados', 'Featured developments'),
  ('attr', 'Featured developments', 'Desarrollos destacados', 'Featured developments'),
  ('attr', 'Featured projects', 'Desarrollos destacados', 'Featured developments'),
  ('attr', 'Featured Projects', 'Desarrollos destacados', 'Featured developments'),
  ('attr', 'Proyectos destacados', 'Desarrollos destacados', 'Featured developments'),
  ('attr', 'Propiedades en venta', 'Propiedades en venta', 'Properties for sale'),
  ('attr', 'Properties for sale', 'Propiedades en venta', 'Properties for sale'),
  ('attr', 'Properties For Sale', 'Propiedades en venta', 'Properties for sale'),
  ('attr', 'Propiedades en renta', 'Propiedades en renta', 'Properties for rent'),
  ('attr', 'Properties for rent', 'Propiedades en renta', 'Properties for rent'),
  ('attr', 'Properties For Rent', 'Propiedades en renta', 'Properties for rent'),
  ('attr', 'Propiedades en arriendo', 'Propiedades en renta', 'Properties for rent'),
  ('attr', 'Agentes destacados', 'Agentes destacados', 'Featured agents'),
  ('attr', 'Featured agents', 'Agentes destacados', 'Featured agents'),
  ('attr', 'Featured Agents', 'Agentes destacados', 'Featured agents'),
  ('attr', 'Propiedades destacadas', 'Propiedades destacadas', 'Featured properties'),
  ('attr', 'Featured properties', 'Propiedades destacadas', 'Featured properties'),
  ('attr', 'Featured Properties', 'Propiedades destacadas', 'Featured properties'),
  ('attr', 'Desarrollos por ubicación', 'Desarrollos por ubicación', 'Developments by location'),
  ('attr', 'Developments by location', 'Desarrollos por ubicación', 'Developments by location'),
  ('attr', 'Projects by locations', 'Desarrollos por ubicación', 'Developments by location'),
  ('attr', 'Proyectos por ubicación', 'Desarrollos por ubicación', 'Developments by location'),
  ('attr', 'Propiedades por ubicación', 'Propiedades por ubicación', 'Properties by location'),
  ('attr', 'Properties by location', 'Propiedades por ubicación', 'Properties by location'),
  ('attr', 'Properties by locations', 'Propiedades por ubicación', 'Properties by location'),
  ('attr', 'Vistas recientemente', 'Vistas recientemente', 'Recently viewed'),
  ('attr', 'Recently viewed', 'Vistas recientemente', 'Recently viewed'),
  ('attr', 'Recently Viewed Properties', 'Vistas recientemente', 'Recently viewed'),
  ('attr', 'Últimas noticias', 'Últimas noticias', 'Latest news'),
  ('attr', 'Latest news', 'Últimas noticias', 'Latest news'),
  ('attr', 'Latest News', 'Últimas noticias', 'Latest news'),
  ('attr', 'Noticias', 'Noticias', 'News'),
  ('attr', 'News', 'Noticias', 'News'),
  ('attr', 'Contáctanos', 'Contáctanos', 'Contact us'),
  ('attr', 'Contact us', 'Contáctanos', 'Contact us'),
  ('attr', 'Contact Us', 'Contáctanos', 'Contact us'),
  ('attr', 'Contáctenos', 'Contáctanos', 'Contact us'),
  ('attr', 'Descubre nuestras propiedades', 'Descubre nuestras propiedades', 'Discover our properties'),
  ('attr', 'Discover our properties', 'Descubre nuestras propiedades', 'Discover our properties'),
  ('attr', 'Descubre nuestros desarrollos', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('attr', 'Discover our developments', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('attr', 'Discover our projects', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('attr', 'Descubre nuestros proyectos', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('title', 'Inicio', 'Inicio', 'Home'),
  ('title', 'Home', 'Inicio', 'Home'),
  ('title', 'Desarrollos', 'Desarrollos', 'Developments'),
  ('title', 'Developments', 'Desarrollos', 'Developments'),
  ('title', 'Projects', 'Desarrollos', 'Developments'),
  ('title', 'Proyectos', 'Desarrollos', 'Developments'),
  ('title', 'Propiedades', 'Propiedades', 'Properties'),
  ('title', 'Properties', 'Propiedades', 'Properties'),
  ('title', 'Agentes', 'Agentes', 'Agents'),
  ('title', 'Agents', 'Agentes', 'Agents'),
  ('title', 'Realtors', 'Agentes', 'Agents'),
  ('title', 'Asesores', 'Agentes', 'Agents'),
  ('title', 'Noticias', 'Noticias', 'News'),
  ('title', 'News', 'Noticias', 'News'),
  ('title', 'Blog', 'Noticias', 'News'),
  ('title', 'Empleos', 'Empleos', 'Careers'),
  ('title', 'Careers', 'Empleos', 'Careers'),
  ('title', 'Trabaja con nosotros', 'Empleos', 'Careers'),
  ('title', 'Contacto', 'Contacto', 'Contact'),
  ('title', 'Contact', 'Contacto', 'Contact'),
  ('title', 'Contáctanos', 'Contáctanos', 'Contact us'),
  ('title', 'Contact us', 'Contáctanos', 'Contact us'),
  ('title', 'Contáctenos', 'Contáctanos', 'Contact us'),
  ('title', 'Nosotros', 'Nosotros', 'About us'),
  ('title', 'About us', 'Nosotros', 'About us'),
  ('title', 'About', 'Nosotros', 'About us'),
  ('title', 'About Us', 'Nosotros', 'About us'),
  ('title', 'Sobre nosotros', 'Nosotros', 'About us'),
  ('title', 'Quiénes somos', 'Nosotros', 'About us'),
  ('title', 'Términos y condiciones', 'Términos y condiciones', 'Terms & Conditions'),
  ('title', 'Terms & Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('title', 'Terms and Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('title', 'Terms Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('title', 'Terms & conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('title', 'Política de privacidad', 'Política de privacidad', 'Privacy Policy'),
  ('title', 'Privacy Policy', 'Política de privacidad', 'Privacy Policy'),
  ('title', 'Privacy policy', 'Política de privacidad', 'Privacy Policy'),
  ('title', 'Política de cookies', 'Política de cookies', 'Cookie Policy'),
  ('title', 'Cookie Policy', 'Política de cookies', 'Cookie Policy'),
  ('title', 'Cookie policy', 'Política de cookies', 'Cookie Policy'),
  ('title', 'Cookies Policy', 'Política de cookies', 'Cookie Policy'),
  ('title', 'Preguntas frecuentes', 'Preguntas frecuentes', 'FAQ'),
  ('title', 'FAQ', 'Preguntas frecuentes', 'FAQ'),
  ('title', 'FAQs', 'Preguntas frecuentes', 'FAQ'),
  ('title', 'En venta', 'En venta', 'For sale'),
  ('title', 'For sale', 'En venta', 'For sale'),
  ('title', 'Sale', 'En venta', 'For sale'),
  ('title', 'Venta', 'En venta', 'For sale'),
  ('title', 'En renta', 'En renta', 'For rent'),
  ('title', 'For rent', 'En renta', 'For rent'),
  ('title', 'Rent', 'En renta', 'For rent'),
  ('title', 'Renta', 'En renta', 'For rent'),
  ('title', 'Arriendo', 'En renta', 'For rent'),
  ('title', 'Propiedades en venta', 'Propiedades en venta', 'Properties for sale'),
  ('title', 'Properties for sale', 'Propiedades en venta', 'Properties for sale'),
  ('title', 'Properties For Sale', 'Propiedades en venta', 'Properties for sale'),
  ('title', 'Propiedades en renta', 'Propiedades en renta', 'Properties for rent'),
  ('title', 'Properties for rent', 'Propiedades en renta', 'Properties for rent'),
  ('title', 'Properties For Rent', 'Propiedades en renta', 'Properties for rent'),
  ('title', 'Enlaces rápidos', 'Enlaces rápidos', 'Quick links'),
  ('title', 'Quick links', 'Enlaces rápidos', 'Quick links'),
  ('title', 'Quick Links', 'Enlaces rápidos', 'Quick links'),
  ('title', 'Enlaces útiles', 'Enlaces útiles', 'Useful links'),
  ('title', 'Useful links', 'Enlaces útiles', 'Useful links'),
  ('title', 'Useful Links', 'Enlaces útiles', 'Useful links'),
  ('title', 'Información', 'Información', 'Information'),
  ('title', 'Information', 'Información', 'Information'),
  ('title', 'Categorías', 'Categorías', 'Categories'),
  ('title', 'Categories', 'Categorías', 'Categories'),
  ('title', 'Artículos recientes', 'Artículos recientes', 'Recent posts'),
  ('title', 'Recent posts', 'Artículos recientes', 'Recent posts'),
  ('title', 'Recent Posts', 'Artículos recientes', 'Recent posts'),
  ('title', 'Últimas noticias', 'Últimas noticias', 'Latest news'),
  ('title', 'Latest news', 'Últimas noticias', 'Latest news'),
  ('title', 'Latest News', 'Últimas noticias', 'Latest news'),
  ('title', 'Arquitectura', 'Arquitectura', 'Architecture'),
  ('title', 'Architecture', 'Arquitectura', 'Architecture'),
  ('title', 'House architecture', 'Arquitectura', 'Architecture'),
  ('title', 'Diseño de interiores', 'Diseño de interiores', 'Interior design'),
  ('title', 'Interior design', 'Diseño de interiores', 'Interior design'),
  ('title', 'House design', 'Diseño de interiores', 'Interior design'),
  ('title', 'Materiales de construcción', 'Materiales de construcción', 'Building materials'),
  ('title', 'Building materials', 'Materiales de construcción', 'Building materials'),
  ('title', 'Inversión', 'Inversión', 'Investment'),
  ('title', 'Investment', 'Inversión', 'Investment'),
  ('title', 'Estilo de vida', 'Estilo de vida', 'Lifestyle'),
  ('title', 'Lifestyle', 'Estilo de vida', 'Lifestyle'),
  ('widget', 'Inicio', 'Inicio', 'Home'),
  ('widget', 'Home', 'Inicio', 'Home'),
  ('widget', 'Desarrollos', 'Desarrollos', 'Developments'),
  ('widget', 'Developments', 'Desarrollos', 'Developments'),
  ('widget', 'Projects', 'Desarrollos', 'Developments'),
  ('widget', 'Proyectos', 'Desarrollos', 'Developments'),
  ('widget', 'Propiedades', 'Propiedades', 'Properties'),
  ('widget', 'Properties', 'Propiedades', 'Properties'),
  ('widget', 'Agentes', 'Agentes', 'Agents'),
  ('widget', 'Agents', 'Agentes', 'Agents'),
  ('widget', 'Realtors', 'Agentes', 'Agents'),
  ('widget', 'Asesores', 'Agentes', 'Agents'),
  ('widget', 'Noticias', 'Noticias', 'News'),
  ('widget', 'News', 'Noticias', 'News'),
  ('widget', 'Blog', 'Noticias', 'News'),
  ('widget', 'Empleos', 'Empleos', 'Careers'),
  ('widget', 'Careers', 'Empleos', 'Careers'),
  ('widget', 'Trabaja con nosotros', 'Empleos', 'Careers'),
  ('widget', 'Contacto', 'Contacto', 'Contact'),
  ('widget', 'Contact', 'Contacto', 'Contact'),
  ('widget', 'Contáctanos', 'Contáctanos', 'Contact us'),
  ('widget', 'Cont\\u00e1ctanos', 'Contáctanos', 'Contact us'),
  ('widget', 'Contact us', 'Contáctanos', 'Contact us'),
  ('widget', 'Contáctenos', 'Contáctanos', 'Contact us'),
  ('widget', 'Cont\\u00e1ctenos', 'Contáctanos', 'Contact us'),
  ('widget', 'Nosotros', 'Nosotros', 'About us'),
  ('widget', 'About us', 'Nosotros', 'About us'),
  ('widget', 'About', 'Nosotros', 'About us'),
  ('widget', 'About Us', 'Nosotros', 'About us'),
  ('widget', 'Sobre nosotros', 'Nosotros', 'About us'),
  ('widget', 'Quiénes somos', 'Nosotros', 'About us'),
  ('widget', 'Qui\\u00e9nes somos', 'Nosotros', 'About us'),
  ('widget', 'Términos y condiciones', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'T\\u00e9rminos y condiciones', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'Terms & Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'Terms and Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'Terms Conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'Terms & conditions', 'Términos y condiciones', 'Terms & Conditions'),
  ('widget', 'Política de privacidad', 'Política de privacidad', 'Privacy Policy'),
  ('widget', 'Pol\\u00edtica de privacidad', 'Política de privacidad', 'Privacy Policy'),
  ('widget', 'Privacy Policy', 'Política de privacidad', 'Privacy Policy'),
  ('widget', 'Privacy policy', 'Política de privacidad', 'Privacy Policy'),
  ('widget', 'Política de cookies', 'Política de cookies', 'Cookie Policy'),
  ('widget', 'Pol\\u00edtica de cookies', 'Política de cookies', 'Cookie Policy'),
  ('widget', 'Cookie Policy', 'Política de cookies', 'Cookie Policy'),
  ('widget', 'Cookie policy', 'Política de cookies', 'Cookie Policy'),
  ('widget', 'Cookies Policy', 'Política de cookies', 'Cookie Policy'),
  ('widget', 'Preguntas frecuentes', 'Preguntas frecuentes', 'FAQ'),
  ('widget', 'FAQ', 'Preguntas frecuentes', 'FAQ'),
  ('widget', 'FAQs', 'Preguntas frecuentes', 'FAQ'),
  ('widget', 'En venta', 'En venta', 'For sale'),
  ('widget', 'For sale', 'En venta', 'For sale'),
  ('widget', 'Sale', 'En venta', 'For sale'),
  ('widget', 'Venta', 'En venta', 'For sale'),
  ('widget', 'En renta', 'En renta', 'For rent'),
  ('widget', 'For rent', 'En renta', 'For rent'),
  ('widget', 'Rent', 'En renta', 'For rent'),
  ('widget', 'Renta', 'En renta', 'For rent'),
  ('widget', 'Arriendo', 'En renta', 'For rent'),
  ('widget', 'Propiedades en venta', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Properties for sale', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Properties For Sale', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Propiedades en renta', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Properties for rent', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Properties For Rent', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Enlaces rápidos', 'Enlaces rápidos', 'Quick links'),
  ('widget', 'Enlaces r\\u00e1pidos', 'Enlaces rápidos', 'Quick links'),
  ('widget', 'Quick links', 'Enlaces rápidos', 'Quick links'),
  ('widget', 'Quick Links', 'Enlaces rápidos', 'Quick links'),
  ('widget', 'Enlaces útiles', 'Enlaces útiles', 'Useful links'),
  ('widget', 'Enlaces \\u00fatiles', 'Enlaces útiles', 'Useful links'),
  ('widget', 'Useful links', 'Enlaces útiles', 'Useful links'),
  ('widget', 'Useful Links', 'Enlaces útiles', 'Useful links'),
  ('widget', 'Información', 'Información', 'Information'),
  ('widget', 'Informaci\\u00f3n', 'Información', 'Information'),
  ('widget', 'Information', 'Información', 'Information'),
  ('widget', 'Categorías', 'Categorías', 'Categories'),
  ('widget', 'Categor\\u00edas', 'Categorías', 'Categories'),
  ('widget', 'Categories', 'Categorías', 'Categories'),
  ('widget', 'Artículos recientes', 'Artículos recientes', 'Recent posts'),
  ('widget', 'Art\\u00edculos recientes', 'Artículos recientes', 'Recent posts'),
  ('widget', 'Recent posts', 'Artículos recientes', 'Recent posts'),
  ('widget', 'Recent Posts', 'Artículos recientes', 'Recent posts'),
  ('widget', 'Últimas noticias', 'Últimas noticias', 'Latest news'),
  ('widget', '\\u00daltimas noticias', 'Últimas noticias', 'Latest news'),
  ('widget', 'Latest news', 'Últimas noticias', 'Latest news'),
  ('widget', 'Latest News', 'Últimas noticias', 'Latest news'),
  ('widget', 'Arquitectura', 'Arquitectura', 'Architecture'),
  ('widget', 'Architecture', 'Arquitectura', 'Architecture'),
  ('widget', 'House architecture', 'Arquitectura', 'Architecture'),
  ('widget', 'Diseño de interiores', 'Diseño de interiores', 'Interior design'),
  ('widget', 'Dise\\u00f1o de interiores', 'Diseño de interiores', 'Interior design'),
  ('widget', 'Interior design', 'Diseño de interiores', 'Interior design'),
  ('widget', 'House design', 'Diseño de interiores', 'Interior design'),
  ('widget', 'Materiales de construcción', 'Materiales de construcción', 'Building materials'),
  ('widget', 'Materiales de construcci\\u00f3n', 'Materiales de construcción', 'Building materials'),
  ('widget', 'Building materials', 'Materiales de construcción', 'Building materials'),
  ('widget', 'Inversión', 'Inversión', 'Investment'),
  ('widget', 'Inversi\\u00f3n', 'Inversión', 'Investment'),
  ('widget', 'Investment', 'Inversión', 'Investment'),
  ('widget', 'Estilo de vida', 'Estilo de vida', 'Lifestyle'),
  ('widget', 'Lifestyle', 'Estilo de vida', 'Lifestyle'),
  ('widget', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('widget', 'Seleccionamos los desarrollos m\\u00e1s exclusivos de M\\u00e9xico, Costa Rica y Miami. Conoce los detalles a continuaci\\u00f3n.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('widget', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('widget', 'We make the best choices with the hottest and most prestigious projects, please visit the details below to find out more.', 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.', 'We curate the most exclusive developments in Mexico, Costa Rica and Miami. See the details below.'),
  ('widget', 'Estas son las propiedades de lujo disponibles para compra', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('widget', 'Luxury properties currently available for purchase', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('widget', 'Below is a list of properties that are currently up for sale', 'Estas son las propiedades de lujo disponibles para compra', 'Luxury properties currently available for purchase'),
  ('widget', 'Estas son las residencias disponibles para renta', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('widget', 'Luxury residences currently available for rent', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('widget', 'Below is a detailed price list of houses for rent', 'Estas son las residencias disponibles para renta', 'Luxury residences currently available for rent'),
  ('widget', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('widget', 'Gu\\u00edas y noticias para comprar e invertir en M\\u00e9xico, Costa Rica y Miami.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('widget', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('widget', 'Below is the latest real estate news we get regularly updated from reliable sources.', 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.', 'Guides and news for buying and investing in Mexico, Costa Rica and Miami.'),
  ('widget', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('widget', 'Cada destino tiene su encanto. Descubre nuestras propiedades en M\\u00e9xico, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('widget', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('widget', 'Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful properties.', 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our properties in Mexico, Costa Rica and Miami.'),
  ('widget', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('widget', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en M\\u00e9xico, Costa Rica y Miami.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('widget', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('widget', 'Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful projects.', 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.', 'Every destination has its charm. Discover our developments in Mexico, Costa Rica and Miami.'),
  ('widget', 'Encuentra la propiedad de tus sueños', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('widget', 'Encuentra la propiedad de tus sue\\u00f1os', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('widget', 'Find the home of your dreams', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('widget', 'Find your favorite homes at Flex Home', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams'),
  ('widget', 'Desarrollos destacados', 'Desarrollos destacados', 'Featured developments'),
  ('widget', 'Featured developments', 'Desarrollos destacados', 'Featured developments'),
  ('widget', 'Featured projects', 'Desarrollos destacados', 'Featured developments'),
  ('widget', 'Featured Projects', 'Desarrollos destacados', 'Featured developments'),
  ('widget', 'Proyectos destacados', 'Desarrollos destacados', 'Featured developments'),
  ('widget', 'Propiedades en venta', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Properties for sale', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Properties For Sale', 'Propiedades en venta', 'Properties for sale'),
  ('widget', 'Propiedades en renta', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Properties for rent', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Properties For Rent', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Propiedades en arriendo', 'Propiedades en renta', 'Properties for rent'),
  ('widget', 'Agentes destacados', 'Agentes destacados', 'Featured agents'),
  ('widget', 'Featured agents', 'Agentes destacados', 'Featured agents'),
  ('widget', 'Featured Agents', 'Agentes destacados', 'Featured agents'),
  ('widget', 'Propiedades destacadas', 'Propiedades destacadas', 'Featured properties'),
  ('widget', 'Featured properties', 'Propiedades destacadas', 'Featured properties'),
  ('widget', 'Featured Properties', 'Propiedades destacadas', 'Featured properties'),
  ('widget', 'Desarrollos por ubicación', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Desarrollos por ubicaci\\u00f3n', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Developments by location', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Projects by locations', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Proyectos por ubicación', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Proyectos por ubicaci\\u00f3n', 'Desarrollos por ubicación', 'Developments by location'),
  ('widget', 'Propiedades por ubicación', 'Propiedades por ubicación', 'Properties by location'),
  ('widget', 'Propiedades por ubicaci\\u00f3n', 'Propiedades por ubicación', 'Properties by location'),
  ('widget', 'Properties by location', 'Propiedades por ubicación', 'Properties by location'),
  ('widget', 'Properties by locations', 'Propiedades por ubicación', 'Properties by location'),
  ('widget', 'Vistas recientemente', 'Vistas recientemente', 'Recently viewed'),
  ('widget', 'Recently viewed', 'Vistas recientemente', 'Recently viewed'),
  ('widget', 'Recently Viewed Properties', 'Vistas recientemente', 'Recently viewed'),
  ('widget', 'Últimas noticias', 'Últimas noticias', 'Latest news'),
  ('widget', '\\u00daltimas noticias', 'Últimas noticias', 'Latest news'),
  ('widget', 'Latest news', 'Últimas noticias', 'Latest news'),
  ('widget', 'Latest News', 'Últimas noticias', 'Latest news'),
  ('widget', 'Noticias', 'Noticias', 'News'),
  ('widget', 'News', 'Noticias', 'News'),
  ('widget', 'Contáctanos', 'Contáctanos', 'Contact us'),
  ('widget', 'Cont\\u00e1ctanos', 'Contáctanos', 'Contact us'),
  ('widget', 'Contact us', 'Contáctanos', 'Contact us'),
  ('widget', 'Contact Us', 'Contáctanos', 'Contact us'),
  ('widget', 'Contáctenos', 'Contáctanos', 'Contact us'),
  ('widget', 'Cont\\u00e1ctenos', 'Contáctanos', 'Contact us'),
  ('widget', 'Descubre nuestras propiedades', 'Descubre nuestras propiedades', 'Discover our properties'),
  ('widget', 'Discover our properties', 'Descubre nuestras propiedades', 'Discover our properties'),
  ('widget', 'Descubre nuestros desarrollos', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('widget', 'Discover our developments', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('widget', 'Discover our projects', 'Descubre nuestros desarrollos', 'Discover our developments'),
  ('widget', 'Descubre nuestros proyectos', 'Descubre nuestros desarrollos', 'Discover our developments');
-- Cada página tiene su versión en el otro idioma (copia de la principal, que luego se traduce).
INSERT INTO pages_translations (lang_code, pages_id, name, description, content)
SELECT o.code, p.id, p.name, p.description, p.content FROM pages p JOIN ard_lang o ON o.k = 'otro'
WHERE NOT EXISTS (SELECT 1 FROM pages_translations t WHERE t.pages_id = p.id AND t.lang_code = o.code);

-- Términos y condiciones con la marca.
DROP TABLE IF EXISTS ard_terms;
CREATE TABLE ard_terms (id BIGINT UNSIGNED PRIMARY KEY) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO ard_terms SELECT reference_id FROM slugs WHERE `key` = 'terms-conditions' AND reference_type LIKE '%Page%Models%Page';
UPDATE pages p JOIN ard_terms x ON x.id = p.id
SET p.name = IF(@def_en, 'Terms & Conditions', 'Términos y condiciones'),
    p.content = IF(@def_en, '<h3>1. Who we are</h3><p>Ardenza Estates is a FLAMIA real estate portal featuring luxury properties and developments in Mexico, Costa Rica and Miami. By using inmobiliaria.flamiagroup.com you accept these terms.</p><h3>2. Property information</h3><p>Listings are published by agents and developers. Prices, sizes, availability and images are for information only, may change without notice and are not a binding offer.</p><p>Prices are shown in US dollars (USD); conversions to MXN or CRC are approximate.</p><h3>3. Agents and advertisers</h3><p>Each agent is responsible for the accuracy of their listings and for holding the licenses required in their country. Ardenza Estates is not a party to any sale or rental between users and advertisers.</p><h3>4. Use of the site</h3><p>You may not post false information, copy content for commercial purposes or use the site for unlawful activities. We may suspend accounts that break these rules.</p><h3>5. Personal data</h3><p>We use the data you send through our forms only to answer your request and put you in touch with the right agent. You can request access to, correction or deletion of your data by writing to contacto@flamiagroup.com.</p><h3>6. Advice</h3><p>Blog content is for information only. Before buying or investing, consult a legal and tax advisor in the property''s country.</p><h3>7. Contact</h3><p>Ardenza Estates by FLAMIA · contacto@flamiagroup.com · +506 8940-1202</p><p><em>Last updated: October 2026.</em></p>', '<h3>1. Quiénes somos</h3><p>Ardenza Propiedades es un portal inmobiliario de FLAMIA que reúne propiedades y desarrollos de lujo en México, Costa Rica y Miami. Al usar inmobiliaria.flamiagroup.com aceptas estos términos.</p><h3>2. Información de las propiedades</h3><p>Las fichas son publicadas por agentes y desarrolladores. Precios, medidas, disponibilidad e imágenes son informativos, pueden cambiar sin aviso y no constituyen una oferta vinculante.</p><p>Los precios se muestran en dólares estadounidenses (USD); las conversiones a MXN o CRC son aproximadas.</p><h3>3. Agentes y anunciantes</h3><p>Cada agente es responsable de la veracidad de sus anuncios y de contar con las licencias que exija su país. Ardenza Propiedades no es parte en las operaciones de compraventa o renta entre usuarios y anunciantes.</p><h3>4. Uso del sitio</h3><p>No está permitido publicar información falsa, copiar el contenido con fines comerciales ni usar el sitio para actividades ilícitas. Podemos suspender cuentas que incumplan estas reglas.</p><h3>5. Datos personales</h3><p>Usamos los datos que envías en formularios únicamente para responder a tu solicitud y ponerte en contacto con el agente correspondiente. Puedes pedir el acceso, la corrección o la eliminación de tus datos escribiendo a contacto@flamiagroup.com.</p><h3>6. Asesoría</h3><p>El contenido del blog es informativo. Antes de comprar o invertir consulta a un asesor legal y fiscal en el país de la propiedad.</p><h3>7. Contacto</h3><p>Ardenza Propiedades by FLAMIA · contacto@flamiagroup.com · +506 8940-1202</p><p><em>Última actualización: octubre de 2026.</em></p>'),
    p.description = NULL;
UPDATE pages_translations t JOIN ard_terms x ON x.id = t.pages_id JOIN ard_lang o ON o.k = 'otro' AND o.code = t.lang_code
SET t.name = IF(@def_en, 'Términos y condiciones', 'Terms & Conditions'),
    t.content = IF(@def_en, '<h3>1. Quiénes somos</h3><p>Ardenza Propiedades es un portal inmobiliario de FLAMIA que reúne propiedades y desarrollos de lujo en México, Costa Rica y Miami. Al usar inmobiliaria.flamiagroup.com aceptas estos términos.</p><h3>2. Información de las propiedades</h3><p>Las fichas son publicadas por agentes y desarrolladores. Precios, medidas, disponibilidad e imágenes son informativos, pueden cambiar sin aviso y no constituyen una oferta vinculante.</p><p>Los precios se muestran en dólares estadounidenses (USD); las conversiones a MXN o CRC son aproximadas.</p><h3>3. Agentes y anunciantes</h3><p>Cada agente es responsable de la veracidad de sus anuncios y de contar con las licencias que exija su país. Ardenza Propiedades no es parte en las operaciones de compraventa o renta entre usuarios y anunciantes.</p><h3>4. Uso del sitio</h3><p>No está permitido publicar información falsa, copiar el contenido con fines comerciales ni usar el sitio para actividades ilícitas. Podemos suspender cuentas que incumplan estas reglas.</p><h3>5. Datos personales</h3><p>Usamos los datos que envías en formularios únicamente para responder a tu solicitud y ponerte en contacto con el agente correspondiente. Puedes pedir el acceso, la corrección o la eliminación de tus datos escribiendo a contacto@flamiagroup.com.</p><h3>6. Asesoría</h3><p>El contenido del blog es informativo. Antes de comprar o invertir consulta a un asesor legal y fiscal en el país de la propiedad.</p><h3>7. Contacto</h3><p>Ardenza Propiedades by FLAMIA · contacto@flamiagroup.com · +506 8940-1202</p><p><em>Última actualización: octubre de 2026.</em></p>', '<h3>1. Who we are</h3><p>Ardenza Estates is a FLAMIA real estate portal featuring luxury properties and developments in Mexico, Costa Rica and Miami. By using inmobiliaria.flamiagroup.com you accept these terms.</p><h3>2. Property information</h3><p>Listings are published by agents and developers. Prices, sizes, availability and images are for information only, may change without notice and are not a binding offer.</p><p>Prices are shown in US dollars (USD); conversions to MXN or CRC are approximate.</p><h3>3. Agents and advertisers</h3><p>Each agent is responsible for the accuracy of their listings and for holding the licenses required in their country. Ardenza Estates is not a party to any sale or rental between users and advertisers.</p><h3>4. Use of the site</h3><p>You may not post false information, copy content for commercial purposes or use the site for unlawful activities. We may suspend accounts that break these rules.</p><h3>5. Personal data</h3><p>We use the data you send through our forms only to answer your request and put you in touch with the right agent. You can request access to, correction or deletion of your data by writing to contacto@flamiagroup.com.</p><h3>6. Advice</h3><p>Blog content is for information only. Before buying or investing, consult a legal and tax advisor in the property''s country.</p><h3>7. Contact</h3><p>Ardenza Estates by FLAMIA · contacto@flamiagroup.com · +506 8940-1202</p><p><em>Last updated: October 2026.</em></p>'),
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

-- 4. Menús: uno por idioma ------------------------------------------------------
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
    JOIN language_meta lm ON lm.reference_id = m.id AND lm.reference_type = 'Botble\\Menu\\Models\\Menu'
    JOIN ard_lang le ON le.k = 'en' JOIN ard_lang ls ON ls.k = 'es'
    WHERE lm.lang_meta_code IN (le.code, ls.code)
      AND NOT EXISTS (SELECT 1 FROM language_meta x
                      WHERE x.reference_type = 'Botble\\Menu\\Models\\Menu' AND x.lang_meta_origin = lm.lang_meta_origin
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
      VALUES (v_code, v_origin, v_new, 'Botble\\Menu\\Models\\Menu');
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
          WHERE reference_id = v_node AND reference_type = 'Botble\\Menu\\Models\\MenuNode';
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
LEFT JOIN language_meta lm ON lm.reference_id = n.menu_id AND lm.reference_type = 'Botble\\Menu\\Models\\Menu'
LEFT JOIN ard_lang le ON le.k = 'en'
SET n.title = IF(COALESCE(lm.lang_meta_code = le.code, @def_en = 1), p.en, p.es);

-- 5. Widgets del pie de página ---------------------------------------------------
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

-- 6. Opciones del tema por idioma -----------------------------------------------
DROP TABLE IF EXISTS ard_opt;
CREATE TABLE ard_opt (k VARCHAR(120), es TEXT, en TEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_opt (k, es, en) VALUES
  ('site_title', 'Ardenza Propiedades', 'Ardenza Estates'),
  ('seo_title', 'Ardenza Propiedades · Propiedades de lujo en México, Costa Rica y Miami', 'Ardenza Estates · Luxury real estate in Mexico, Costa Rica and Miami'),
  ('seo_description', 'Casas, departamentos y residencias de lujo en México, Costa Rica y Miami. Propiedades seleccionadas y publicadas por realtors verificados. Un portal de FLAMIA.', 'Luxury homes, condos and residences in Mexico, Costa Rica and Miami. Curated properties listed by verified realtors. A FLAMIA portal.'),
  ('copyright', '© 2026 Ardenza Propiedades · by FLAMIA Group. Todos los derechos reservados.', '© 2026 Ardenza Estates · by FLAMIA Group. All rights reserved.'),
  ('address', 'Heredia, Costa Rica · México · Miami', 'Heredia, Costa Rica · Mexico · Miami'),
  ('about-us', 'Ardenza Propiedades es el portal de propiedades de lujo de FLAMIA en México, Costa Rica y Miami. Cada propiedad es publicada por realtors verificados y revisada antes de salir en el sitio.', 'Ardenza Estates is FLAMIA''s luxury real estate portal in Mexico, Costa Rica and Miami. Every property is listed by verified realtors and reviewed before it goes live.');
DROP TABLE IF EXISTS ard_opt_si;
CREATE TABLE ard_opt_si (k VARCHAR(120), es TEXT, en TEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_opt_si (k, es, en) VALUES
  ('home_banner_description', 'Encuentra la propiedad de tus sueños', 'Find the home of your dreams');
INSERT INTO settings (`key`, value)
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

-- 7. Resumen ---------------------------------------------------------------------
SELECT
  (SELECT code FROM ard_lang WHERE k = 'def') AS idioma_principal,
  (SELECT code FROM ard_lang WHERE k = 'otro') AS idioma_traducido,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'prop') AS propiedades,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'proj') AS desarrollos,
  (SELECT COUNT(*) FROM ard_m WHERE kind = 'post') AS noticias,
  (SELECT COUNT(*) FROM ard_terms) AS pagina_terminos,
  (SELECT COUNT(*) FROM ard_menu_copia) AS menus_creados;
SELECT m.name AS menu, lm.lang_meta_code AS idioma, GROUP_CONCAT(n.title ORDER BY n.position SEPARATOR ' · ') AS opciones
FROM menus m LEFT JOIN language_meta lm ON lm.reference_id = m.id AND lm.reference_type = 'Botble\\Menu\\Models\\Menu'
LEFT JOIN menu_nodes n ON n.menu_id = m.id AND n.parent_id = 0
GROUP BY m.id, lm.lang_meta_code;

DROP TABLE IF EXISTS ard_lang, ard_t, ard_m, ard_loc, ard_d, ard_p, ard_terms, ard_menu_copia, ard_nodo, ard_opt, ard_opt_si;
