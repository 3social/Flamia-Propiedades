# Marca y limpieza total del demo anterior

`ardenza-marca-y-limpieza.sql` deja el sitio 100 % como **Ardenza Propiedades**:

| Qué | Cómo |
|---|---|
| `kosaricorp@gmail.com` y correos `@propiedadesvip` | → `contacto@flamiagroup.com`, en todas las tablas |
| "PropiedadesVIP" y variantes de texto | → "Ardenza Propiedades" |
| "Kosari" / "Kosari Corp" | → "FLAMIA" |
| +57 321 368 4885 | → +506 8940-1202 |
| Enlaces a propiedadesvip.com | → https://inmobiliaria.flamiagroup.com |
| Nombre, SEO, pie, contacto, colores y tipografía | Opciones del tema |
| Logo, favicon e imagen para redes | Apunta a `storage/ardenza/` |
| Redes sociales de Kosari | Se vacían (cargar las de FLAMIA en el panel) |
| Agentes | Uno por país (México, Costa Rica, Miami), con las propiedades de su país; se borran las demás cuentas demo |

Las rutas de imágenes (carpeta `propiedadesvip/`, `kosari-logo.png`) **no se tocan**, para no romper fotos.

## Orden

1. **Respaldo**: phpMyAdmin → `u783834143_inmobil` → Exportar.
2. **Fase 4**: ejecutar `fase4/ardenza-demo-contenido.sql` si aún no se ejecutó.
3. **Logo**: hPanel → Administrador de archivos → `public_html/inmobiliaria/public/storage/` →
   subir `marca/ardenza-logos-storage.zip` → clic derecho → Extraer. Debe quedar la carpeta `storage/ardenza/`.
4. **Este script**: phpMyAdmin → SQL → pegar todo → Continuar.
   Al final: "Textos del demo que quedan" = 0 y una fila por país con su agente.
5. **CSS**: `/admin → Apariencia → CSS personalizado` → pegar `tema/ardenza-custom.css`.
6. **Caché**: `/admin → Administración de la plataforma → Caché → Limpiar toda la caché`, y hPanel → Caché.

Probado en MariaDB 10.11 con el esquema del sitio y casos trampa (rutas de imágenes con "propiedadesvip",
JSON con barras escapadas, correo único en `users`).

## Después

- **Correo saliente (SMTP)**: si estaba configurado con la cuenta de Kosari, ahora dice `contacto@flamiagroup.com`
  pero la contraseña ya no corresponde. Configurarlo en `/admin → Ajustes → Correo` con la cuenta de FLAMIA.
- **Redes sociales**: cargar las de FLAMIA en Opciones del tema → Redes sociales.
