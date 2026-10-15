-- =====================================================================
-- ARDENZA · Títulos y frases de las secciones del inicio en español
-- Los textos salen de los atributos title="..." y subtitle="..." de cada
-- bloque de la página de inicio. Cubre pages, pages_translations y widgets.
-- Ejecutar en phpMyAdmin → u783834143_inmobil → Importar (o pestaña SQL).
-- =====================================================================
SET NAMES utf8mb4;

DROP TABLE IF EXISTS ard_tr;
CREATE TABLE ard_tr (n INT AUTO_INCREMENT PRIMARY KEY, en VARCHAR(400), es VARCHAR(400))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_tr (en, es) VALUES
-- Frases (subtítulos) del demo del tema
('We make the best choices with the hottest and most prestigious projects, please visit the details below to find out more.',
 'Seleccionamos los desarrollos más exclusivos de México, Costa Rica y Miami. Conoce los detalles a continuación.'),
('Below is a list of properties that are currently up for sale',
 'Estas son las propiedades de lujo disponibles para compra'),
('Below is a detailed price list of houses for rent',
 'Estas son las residencias disponibles para renta'),
('Below is the latest real estate news we get regularly updated from reliable sources.',
 'Guías y noticias para comprar e invertir en México, Costa Rica y Miami.'),
('Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful properties.',
 'Cada destino tiene su encanto. Descubre nuestras propiedades en México, Costa Rica y Miami.'),
('Each place is a good choice, it will help you make the right decision, do not miss the opportunity to discover our wonderful projects.',
 'Cada destino tiene su encanto. Descubre nuestros desarrollos en México, Costa Rica y Miami.'),
('Find your favorite homes at Flex Home', 'Encuentra la propiedad de tus sueños'),
-- Títulos
('Featured projects', 'Desarrollos destacados'),
('Featured Projects', 'Desarrollos destacados'),
('Properties For Sale', 'Propiedades en venta'),
('Properties for sale', 'Propiedades en venta'),
('Properties For Rent', 'Propiedades en renta'),
('Properties for rent', 'Propiedades en renta'),
('Featured Agents', 'Agentes destacados'),
('Featured agents', 'Agentes destacados'),
('Featured properties', 'Propiedades destacadas'),
('Featured Properties', 'Propiedades destacadas'),
('Projects by locations', 'Desarrollos por ubicación'),
('Properties by locations', 'Propiedades por ubicación'),
('Recently Viewed Properties', 'Vistas recientemente'),
('Latest news', 'Últimas noticias'),
('Latest News', 'Últimas noticias'),
('News', 'Noticias'),
('Contact us', 'Contáctanos'),
('Discover our properties', 'Descubre nuestras propiedades'),
('Discover our projects', 'Descubre nuestros desarrollos');

-- Reemplaza solo valores de atributos (="…" o =&quot;…&quot;), del texto más largo al más corto.
DROP PROCEDURE IF EXISTS ard_traducir;
DELIMITER $$
CREATE PROCEDURE ard_traducir()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_en, v_es VARCHAR(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  DECLARE cur CURSOR FOR SELECT en, es FROM ard_tr ORDER BY CHAR_LENGTH(en) DESC;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  OPEN cur;
  l: LOOP
    FETCH cur INTO v_en, v_es;
    IF done THEN LEAVE l; END IF;
    UPDATE pages SET content = REPLACE(REPLACE(content,
        CONCAT('="', v_en, '"'), CONCAT('="', v_es, '"')),
        CONCAT('=&quot;', v_en, '&quot;'), CONCAT('=&quot;', v_es, '&quot;'))
      WHERE content LIKE CONCAT('%', v_en, '%');
    UPDATE pages_translations SET content = REPLACE(REPLACE(content,
        CONCAT('="', v_en, '"'), CONCAT('="', v_es, '"')),
        CONCAT('=&quot;', v_en, '&quot;'), CONCAT('=&quot;', v_es, '&quot;'))
      WHERE content LIKE CONCAT('%', v_en, '%');
    UPDATE widgets SET data = REPLACE(data, CONCAT('"', v_en, '"'), CONCAT('"', v_es, '"'))
      WHERE data LIKE CONCAT('%', v_en, '%');
  END LOOP;
  CLOSE cur;
END$$
DELIMITER ;
CALL ard_traducir();
DROP PROCEDURE ard_traducir;
DROP TABLE ard_tr;

-- Verificación: bloques de la página de inicio tal como quedaron.
SELECT id, name, LEFT(content, 1500) AS contenido_inicio
FROM pages
WHERE content LIKE '%[featured-projects%' OR content LIKE '%[properties-for-sale%' OR content LIKE '%[search-box%';
