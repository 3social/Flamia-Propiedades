# Fase 4 · Contenido demo de México, Costa Rica y Miami

`ardenza-demo-contenido.sql` reescribe el demo de Colombia sin borrar las fichas:
cambia textos, ubicaciones, precios y URLs, y **conserva las mismas imágenes**.

| Qué | Resultado |
|---|---|
| Ubicaciones | México (Tulum, Playa del Carmen, Cancún, CDMX, Los Cabos, Puerto Vallarta), Costa Rica (Tamarindo, Santa Teresa, Escazú, Heredia) y EE. UU. (Miami, Miami Beach, Key Biscayne, Coral Gables). Se borran las del demo anterior. |
| Propiedades | 16 fichas nuevas (si hay más propiedades, se repiten con sufijo "· 2"), con coordenadas reales para el mapa. |
| Proyectos | 6 desarrollos (Tulum, Cancún, CDMX, Tamarindo, Escazú, Brickell). |
| Agentes | 8 realtors demo con correos `@example.com` (no reciben correo real). |
| Blog | 6 artículos sobre comprar en México, Costa Rica y Miami. |
| Monedas | USD por defecto; MXN y CRC con tipo de cambio aproximado (actualizar en el panel). Se elimina COP. |
| Tema | Teléfono +506 8940-1202 y dirección "Heredia, Costa Rica · México · Miami". |

Cada ficha dice "Ficha de demostración" al final; se quita al cargar propiedades reales.

## Cómo ejecutarlo

1. phpMyAdmin → base `u783834143_inmobil` → **Exportar** → Continuar (respaldo de hoy).
2. Pestaña **SQL** → pegar todo el archivo → **Continuar**.
3. Al final aparece una tabla con país, ciudad y cantidad de propiedades: solo deben salir México, Costa Rica y Estados Unidos.
4. En el `/admin`: Administración de la plataforma → Caché → Limpiar toda la caché.

Probado contra MariaDB 10.11 con el esquema de las migraciones del sitio (incluida una segunda ejecución).
`generar_sql.py` regenera el `.sql` si se cambian los textos.
