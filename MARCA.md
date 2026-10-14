# Ardenza Propiedades · by FLAMIA

Portal inmobiliario multiagente de lujo sobre Botble Real Estate (tema Flex Home),
instalado en `inmobiliaria.flamiagroup.com` (Hostinger, cuenta `u783834143`).

## Decisiones

| Tema | Decisión |
|---|---|
| Nombre | **Ardenza Propiedades** (español) · **Ardenza Estates** (inglés, Miami) |
| Firma | by FLAMIA |
| Modelo | Un solo portal multiagente: los realtors publican en el mismo sitio. Réplica por cliente solo como servicio premium. |
| Mercados | México, Costa Rica y Miami en un solo sitio (ubicaciones País → Estado → Ciudad); Latinoamérica después |
| Idiomas | Español (principal) e inglés |
| Monedas | USD base; MXN y CRC como alternativas |
| Posicionamiento | Lujo: propiedades aprobadas por FLAMIA antes de publicarse |

## Paleta

| Uso | Color | Contraste |
|---|---|---|
| Navy (botones, enlaces, texto) | `#0F1B2D` | 17.3:1 con blanco |
| Navy profundo (pie de página) | `#0A1220` | — |
| Oro (acentos sobre navy) | `#C9A55C` | 8.1:1 sobre `#0A1220` |
| Oro oscuro (hover, precios sobre blanco) | `#8C6A2F` | 5.0:1 con blanco |
| Marfil (fondos suaves) | `#F7F3EC` | — |

## Tipografía

- Títulos: **Playfair Display** (Google Fonts)
- Texto: **DM Sans** (se elige en Opciones del tema)

## Dónde se aplica

1. `/admin → Apariencia → Opciones del tema → General`: fuente, colores primarios y copyright.
2. `/admin → Apariencia → CSS personalizado`: pegar `tema/ardenza-custom.css` completo.
3. Limpiar caché: Botble (Administración de la plataforma → Caché) y hPanel (Caché).

## Dominios candidatos (libres al 2026-10-14, sin comprar)

`ardenzapropiedades.com` (principal), `ardenzapropiedades.mx`, `ardenza.mx`,
`ardenzaestates.com`. Antes de comprar: buscar "Ardenza" en clase 36 en IMPI y USPTO.

## Logo

Concepto: un arco de puerta (el hogar) con la llama encendida al centro — una chimenea.
La llama viene de *ardere* (arder), la raíz de Ardenza, y conecta con FLAMIA.

| Archivo (`marca/png/`) | Uso |
|---|---|
| `ardenza-horizontal.png` | Logo del sitio (cabecera clara) |
| `ardenza-horizontal-negativo.png` | Sobre fondos navy u oscuros |
| `ardenza-vertical.png` / `-negativo.png` | Redes, papelería, firma de correo |
| `ardenza-simbolo.png` | Avatar, marca de agua en fotos |
| `ardenza-favicon.png` / `favicon.ico` | Favicon e ícono de app |
| `ardenza-redes-1200x630.png` | Imagen para compartir (SEO / Open Graph) |

Los SVG vectoriales están en `marca/svg/` (letras convertidas a trazos; no requieren fuentes instaladas).
Para regenerarlos: `python3 marca/generar_logo.py <carpeta con los .woff2 de Playfair Display 600 y DM Sans 500> marca/svg`.
Fuentes con licencia SIL Open Font License.
