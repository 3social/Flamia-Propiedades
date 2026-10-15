-- =====================================================================
-- ARDENZA PROPIEDADES · Marca y limpieza total del demo anterior
-- Botble Real Estate (tema Flex Home)
--
-- Requisitos, en este orden:
--   1. Respaldo: phpMyAdmin → base u783834143_inmobil → Exportar.
--   2. Ya ejecutada la Fase 4 (fase4/ardenza-demo-contenido.sql).
--   3. Subidos los 3 archivos del logo a public/storage/ardenza/ (ver README).
--
-- Qué hace:
--   A. Busca en TODAS las tablas y reemplaza:
--        kosaricorp@gmail.com y correos @propiedadesvip → contacto@flamiagroup.com
--        enlaces a propiedadesvip.com                  → https://inmobiliaria.flamiagroup.com
--        "PropiedadesVIP" (y variantes en texto)       → "Ardenza Propiedades"
--        "Kosari" / "Kosari Corp"                      → "FLAMIA"
--        +57 321 368 4885                              → +506 8940-1202
--      Las rutas de imágenes (carpeta propiedadesvip/) NO se tocan.
--   B. Nombre, SEO, logo, favicon, colores, tipografía, pie y contacto del sitio.
--   C. Un agente demo por país (México, Costa Rica, Miami) con sus propiedades;
--      elimina las demás cuentas de agentes demo.
-- =====================================================================

SET NAMES utf8mb4;

-- La Fase 4 debe estar aplicada: se usan sus países.
DROP PROCEDURE IF EXISTS ard_check;
DELIMITER $$
CREATE PROCEDURE ard_check()
BEGIN
  IF (SELECT COUNT(*) FROM countries WHERE name IN ('México', 'Costa Rica', 'Estados Unidos')) < 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primero ejecuta fase4/ardenza-demo-contenido.sql';
  END IF;
END$$
DELIMITER ;
CALL ard_check();
DROP PROCEDURE ard_check;

-- A. Reemplazo de textos en toda la base ---------------------------------
DROP TABLE IF EXISTS ard_rules;
CREATE TABLE ard_rules (n INT PRIMARY KEY, pattern VARCHAR(255), replacement VARCHAR(255)) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_rules VALUES
  (1, '(?i)kosaricorp@gmail\\.com', 'contacto@flamiagroup.com'),
  (2, '(?i)[a-z0-9._%+-]+@propiedadesvip\\.[a-z.]+', 'contacto@flamiagroup.com'),
  (3, '(?i)https?:(\\\\?/){2}(www\\.)?propiedadesvip\\.[a-z.]+', 'https://inmobiliaria.flamiagroup.com'),
  (4, '(?-i)Propiedades ?(VIP|Vip|vip)\\b|PROPIEDADES ?VIP\\b', 'Ardenza Propiedades'),
  (5, '(?-i)\\b(Kosari|KOSARI)( Corp(oration)?)?\\b(?![./_-]\\w)', 'FLAMIA'),
  (6, '\\+? ?57 ?321 ?368 ?4885', '+506 8940-1202');

DROP TABLE IF EXISTS ard_cols;
CREATE TABLE ard_cols AS
SELECT c.TABLE_NAME AS t, c.COLUMN_NAME AS col, c.CHARACTER_SET_NAME AS cs, c.COLLATION_NAME AS coll
FROM information_schema.COLUMNS c
JOIN information_schema.TABLES tb ON tb.TABLE_SCHEMA = c.TABLE_SCHEMA AND tb.TABLE_NAME = c.TABLE_NAME AND tb.TABLE_TYPE = 'BASE TABLE'
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.DATA_TYPE IN ('char', 'varchar', 'tinytext', 'text', 'mediumtext', 'longtext', 'json')
  AND c.TABLE_NAME NOT LIKE 'ard\_%'
  AND c.TABLE_NAME NOT IN ('migrations', 'sessions', 'cache', 'cache_locks', 'jobs', 'failed_jobs', 'password_reset_tokens')
  -- Columnas con índice único (correos de usuario, claves): se tratan aparte para no duplicar valores.
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.STATISTICS s
    WHERE s.TABLE_SCHEMA = c.TABLE_SCHEMA AND s.TABLE_NAME = c.TABLE_NAME
      AND s.COLUMN_NAME = c.COLUMN_NAME AND s.NON_UNIQUE = 0);

DROP PROCEDURE IF EXISTS ard_rebrand;
DELIMITER $$
CREATE PROCEDURE ard_rebrand()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_t, v_c, v_cs, v_coll VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT t, col, cs, coll FROM ard_cols;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  OPEN cur;
  cols: LOOP
    FETCH cur INTO v_t, v_c, v_cs, v_coll;
    IF done THEN LEAVE cols; END IF;
    SET @n = 1;
    WHILE @n <= 6 DO
      SELECT pattern, replacement INTO @p, @r FROM ard_rules WHERE n = @n;
      -- Patrón y reemplazo se convierten al cotejo de cada columna (las tablas pueden no compartir el mismo).
      SET @arg = CONCAT('CONVERT(? USING ', v_cs, ') COLLATE ', v_coll);
      SET @sql = CONCAT('UPDATE `', v_t, '` SET `', v_c, '` = REGEXP_REPLACE(`', v_c, '`, ', @arg, ', ', @arg,
                        ') WHERE `', v_c, '` REGEXP ', @arg);
      PREPARE st FROM @sql;
      EXECUTE st USING @p, @r, @p;
      DEALLOCATE PREPARE st;
      SET @n = @n + 1;
    END WHILE;
  END LOOP;
  CLOSE cur;
END$$
DELIMITER ;
CALL ard_rebrand();
DROP PROCEDURE ard_rebrand;

-- Correos en columnas únicas: solo si el nuevo valor no existe ya.
UPDATE users SET email = 'contacto@flamiagroup.com'
WHERE email = 'kosaricorp@gmail.com'
  AND NOT EXISTS (SELECT 1 FROM (SELECT email FROM users) u WHERE u.email = 'contacto@flamiagroup.com');

-- B. Identidad del sitio --------------------------------------------------
DROP TABLE IF EXISTS ard_settings;
CREATE TABLE ard_settings (k VARCHAR(190) PRIMARY KEY, v TEXT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_settings VALUES
  ('site_title', 'Ardenza Propiedades'),
  ('show_site_name', '0'),
  ('seo_title', 'Ardenza Propiedades · Propiedades de lujo en México, Costa Rica y Miami'),
  ('seo_description', 'Casas, departamentos y residencias de lujo en México, Costa Rica y Miami. Propiedades seleccionadas y publicadas por realtors verificados. Un portal de FLAMIA.'),
  ('seo_og_image', 'ardenza/ardenza-redes-1200x630.png'),
  ('logo', 'ardenza/ardenza-horizontal.png'),
  ('favicon', 'ardenza/ardenza-favicon.png'),
  ('copyright', '© 2026 Ardenza Propiedades · by FLAMIA Group. Todos los derechos reservados.'),
  ('primary_font', 'DM Sans'),
  ('primary_color', '#0F1B2D'),
  ('primary_color_hover', '#8C6A2F'),
  ('email', 'contacto@flamiagroup.com'),
  ('hotline', '+506 8940-1202'),
  ('address', 'Heredia, Costa Rica · México · Miami'),
  ('about-us', 'Ardenza Propiedades es el portal de propiedades de lujo de FLAMIA en México, Costa Rica y Miami. Cada propiedad es publicada por realtors verificados y revisada antes de salir en el sitio.');

-- Opción del tema en el idioma principal…
INSERT INTO settings (`key`, value)
SELECT CONCAT('theme-flex-home-', k), v FROM ard_settings
ON DUPLICATE KEY UPDATE value = VALUES(value);
-- …y en las versiones por idioma que ya existan (p. ej. theme-flex-home-en_US-site_title).
UPDATE settings s JOIN ard_settings a
  ON s.`key` REGEXP CONCAT('^theme-flex-home-[A-Za-z_]+-', a.k, '$')
SET s.value = a.v;

-- Redes sociales del demo anterior: se vacían para cargar las de FLAMIA en el panel.
UPDATE settings SET value = '[]'
WHERE `key` REGEXP '^theme-flex-home-([A-Za-z_]+-)?social_links$' AND LOWER(value) LIKE '%kosari%';

-- Panel de administración.
INSERT INTO settings (`key`, value) VALUES
  ('admin_title', 'Ardenza Propiedades'),
  ('admin_logo', 'ardenza/ardenza-horizontal.png'),
  ('admin_favicon', 'ardenza/ardenza-favicon.png')
ON DUPLICATE KEY UPDATE value = VALUES(value);

-- C. Un agente demo por país ---------------------------------------------
DROP TABLE IF EXISTS ard_agents;
CREATE TABLE ard_agents (
  n INT PRIMARY KEY, country VARCHAR(120), city VARCHAR(120), first_name VARCHAR(120), last_name VARCHAR(120),
  email VARCHAR(190), username VARCHAR(60), phone VARCHAR(25), description TEXT, id BIGINT UNSIGNED NULL
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ard_agents (n, country, city, first_name, last_name, email, username, phone, description) VALUES
  (0, 'México', 'tulum', 'Mariana', 'Salazar', 'agente.mexico@example.com', 'agente-mexico', '+52 984 000 0101',
   'Agente de demostración. Residencias de lujo en la Riviera Maya, Ciudad de México, Los Cabos y Puerto Vallarta.'),
  (1, 'Costa Rica', 'escazu', 'Andrés', 'Mora', 'agente.costarica@example.com', 'agente-costarica', '+506 0000 0404',
   'Agente de demostración. Casas de playa en Guanacaste y residencias en Escazú y el Valle Central.'),
  (2, 'Estados Unidos', 'miami', 'Daniel', 'Ríos', 'agente.miami@example.com', 'agente-miami', '+1 305 000 0606',
   'Agente de demostración. Condos, penthouses y residencias frente al agua en Miami.');

-- Libera correos y usuarios por si alguna cuenta ya los tiene.
UPDATE re_accounts SET email = CONCAT('old', id, '@example.com'), username = CONCAT('old', id)
WHERE email IN (SELECT email FROM ard_agents) OR username IN (SELECT username FROM ard_agents);

-- Asegura al menos 3 cuentas (si el demo tenía menos).
INSERT INTO re_accounts (first_name, last_name, email, username, password, confirmed_at, created_at, updated_at)
SELECT 'Agente', CONCAT('Demo ', a.n), CONCAT('nuevo', a.n, '@example.com'), CONCAT('nuevo', a.n),
       '$2y$10$kJwpfOxVshgx6nNmOySQEeOezNEKgDk4prUscJofyo471vFE7iNgu', NOW(), NOW(), NOW()
FROM ard_agents a WHERE a.n >= (SELECT COUNT(*) FROM re_accounts);

-- Las 3 primeras cuentas pasan a ser los agentes por país.
DROP TABLE IF EXISTS ard_map_acc;
CREATE TABLE ard_map_acc AS SELECT id, ROW_NUMBER() OVER (ORDER BY id) - 1 AS rn FROM re_accounts;
UPDATE ard_agents a JOIN ard_map_acc m ON m.rn = a.n SET a.id = m.id;
UPDATE re_accounts r
JOIN ard_agents a ON a.id = r.id
JOIN cities c ON c.slug = a.city
SET r.first_name = a.first_name, r.last_name = a.last_name, r.email = a.email, r.username = a.username,
    r.phone = a.phone, r.description = a.description, r.company = 'Ardenza Propiedades',
    r.is_featured = 1, r.is_public_profile = 1, r.confirmed_at = COALESCE(r.confirmed_at, NOW()),
    r.country_id = c.country_id, r.state_id = c.state_id, r.city_id = c.id;

-- Cada propiedad queda a nombre del agente de su país.
UPDATE re_properties p
JOIN countries co ON co.id = p.country_id
JOIN ard_agents a ON a.country = co.name
SET p.author_id = a.id, p.author_type = 'Botble\\RealEstate\\Models\\Account';

-- Elimina las demás cuentas demo y sus registros asociados.
DELETE FROM re_account_activity_logs WHERE account_id NOT IN (SELECT id FROM ard_agents);
DELETE FROM re_account_packages WHERE account_id NOT IN (SELECT id FROM ard_agents);
DELETE FROM re_reviews WHERE account_id NOT IN (SELECT id FROM ard_agents);
DELETE FROM transactions WHERE account_id IS NOT NULL AND account_id NOT IN (SELECT id FROM ard_agents);
DELETE FROM re_accounts WHERE id NOT IN (SELECT id FROM ard_agents);

DROP TABLE IF EXISTS ard_rules, ard_cols, ard_settings, ard_agents, ard_map_acc;

-- Verificación ------------------------------------------------------------
SELECT 'Textos del demo que quedan (debe ser 0)' AS chequeo,
  (SELECT COUNT(*) FROM settings WHERE value REGEXP '(?i)kosari|propiedades ?vip(?!/)')
  + (SELECT COUNT(*) FROM pages WHERE content REGEXP '(?i)kosari|propiedades ?vip(?!/)' OR name REGEXP '(?i)kosari|propiedades ?vip')
  AS resultado
UNION ALL
SELECT 'Agentes', (SELECT COUNT(*) FROM re_accounts)
UNION ALL
SELECT 'Nombre del sitio', (SELECT value FROM settings WHERE `key` = 'theme-flex-home-site_title');

SELECT co.name AS pais, CONCAT(r.first_name, ' ', r.last_name) AS agente,
       (SELECT COUNT(*) FROM re_properties p WHERE p.author_id = r.id) AS propiedades
FROM re_accounts r JOIN countries co ON co.id = r.country_id ORDER BY co.`order`;
