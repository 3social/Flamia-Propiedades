"""Genera el logo de Ardenza Propiedades en SVG con letras convertidas a trazos.

Símbolo: un arco de puerta (el hogar) con una llama al centro (ardere, FLAMIA).
Wordmark: ARDENZA en Playfair Display y PROPIEDADES en DM Sans.

Uso: python3 generar_logo.py <carpeta_fuentes> <carpeta_salida>
"""
import os
import sys

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

FONTS, OUT = sys.argv[1], sys.argv[2]
PLAYFAIR = os.path.join(FONTS, "playfair-display-latin-600-normal.woff2")
DMSANS = os.path.join(FONTS, "dm-sans-latin-500-normal.woff2")

NAVY = "#0F1B2D"
GOLD = "#C9A55C"
IVORY = "#F7F3EC"


def text_path(font_file, text, size, tracking=0.0):
    """Devuelve (d, ancho, alto_mayúsculas) del texto como un solo path SVG."""
    font = TTFont(font_file)
    glyphs = font.getGlyphSet()
    cmap = font.getBestCmap()
    upm = font["head"].unitsPerEm
    scale = size / upm
    cap = font["OS/2"].sCapHeight * scale
    pen = SVGPathPen(glyphs)
    x = 0.0
    for i, ch in enumerate(text):
        name = cmap[ord(ch)]
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x, 0)))
        x += glyphs[name].width * scale
        if i < len(text) - 1:
            x += tracking * size
    return pen.getCommands(), x, cap


def symbol(color, flame_color, stroke=3.2):
    """Arco de 100×124 con la llama al centro; el origen es la esquina superior izquierda."""
    arch = (f'<path d="M14,118 V52 A36,36 0 0 1 86,52 V118" fill="none" stroke="{color}" '
            f'stroke-width="{stroke}" stroke-linecap="square"/>'
            f'<path d="M4,118 H96" stroke="{color}" stroke-width="{stroke}" stroke-linecap="square"/>')
    # Llama: contorno exterior y lengua interior recortada (evenodd) para dar dos tonos sin perder transparencia.
    # La punta se curva hacia la derecha y una lengua lateral sube por la izquierda: así se lee fuego, no gota.
    flame = ('M53,40 C50,52 58,58 64,67 C70,76 72,86 69,95 C66,103 59,108 50,108 '
             'C41,108 33,103 31,94 C29,85 33,77 38,71 C38,78 41,83 45,85 '
             'C42,73 46,60 53,40 Z '
             'M52,74 C51,81 57,86 57,93 C57,99 54,102 50,102 C46,102 43,99 43,95 '
             'C43,89 47,83 52,74 Z')
    return arch + f'<path d="{flame}" fill="{flame_color}" fill-rule="evenodd"/>'


def svg(width, height, body, background=None):
    bg = f'<rect width="100%" height="100%" fill="{background}"/>' if background else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width:.1f} {height:.1f}" '
            f'width="{width:.0f}" height="{height:.0f}">{bg}{body}</svg>\n')


def wordmark(fg, accent, x, y, scale=1.0):
    """ARDENZA + regla dorada + PROPIEDADES, alineado a la izquierda en (x, y = línea base de ARDENZA)."""
    d_name, w_name, cap = text_path(PLAYFAIR, "ARDENZA", 64 * scale, tracking=0.14)
    d_sub, w_sub, cap_sub = text_path(DMSANS, "PROPIEDADES", 15 * scale, tracking=0.62)
    sub_x = x + (w_name - w_sub) / 2
    sub_y = y + 34 * scale
    body = (f'<path transform="translate({x:.2f},{y:.2f})" d="{d_name}" fill="{fg}"/>'
            f'<path transform="translate({sub_x:.2f},{sub_y:.2f})" d="{d_sub}" fill="{accent}"/>')
    return body, w_name, cap, sub_y


def horizontal(fg, accent, background=None):
    pad = 24
    sym_h = 124
    body_name, w_name, cap, sub_y = wordmark(fg, accent, 0, 0)
    gap = 34
    text_x = pad + 100 + gap
    # La línea base de ARDENZA se alinea para que el bloque de texto quede centrado con el arco.
    block_h = cap + (sub_y)
    base = pad + (sym_h - block_h) / 2 + cap + 6
    body_name, w_name, cap, sub_y = wordmark(fg, accent, text_x, base)
    w = text_x + w_name + pad
    h = pad * 2 + sym_h
    body = f'<g transform="translate({pad},{pad})">{symbol(fg, accent)}</g>' + body_name
    return svg(w, h, body, background)


def stacked(fg, accent, background=None):
    pad = 40
    _, w_name, cap, _ = wordmark(fg, accent, 0, 0)
    w = w_name + pad * 2
    sym_x = (w - 100) / 2
    base = pad + 124 + 40 + cap
    body_name, _, _, sub_y = wordmark(fg, accent, pad, base)
    h = sub_y + pad + 6
    body = f'<g transform="translate({sym_x:.2f},{pad})">{symbol(fg, accent)}</g>' + body_name
    return svg(w, h, body, background)


def favicon(size=512):
    # Símbolo en oro sobre navy, con márgenes para que respire en iconos redondos.
    s = size / 160
    body = (f'<rect width="{size}" height="{size}" rx="{size * 0.18:.0f}" fill="{NAVY}"/>'
            f'<g transform="translate({(size - 100 * s) / 2:.2f},{(size - 124 * s) / 2:.2f}) scale({s:.4f})">'
            f'{symbol(GOLD, GOLD, stroke=4.2)}</g>')
    return svg(size, size, body)


def og_image():
    """Imagen para compartir en redes (1200×630): logo vertical sobre navy y una línea de mercados."""
    w, h = 1200, 630
    _, w_name, cap, _ = wordmark(IVORY, GOLD, 0, 0, scale=1.25)
    base = 150 + 124 * 1.1 + 52 + cap
    body_name, _, _, sub_y = wordmark(IVORY, GOLD, (w - w_name) / 2, base, scale=1.25)
    d_tag, w_tag, _ = text_path(DMSANS, "México · Costa Rica · Miami", 22, tracking=0.12)
    tag_y = sub_y + 62
    body = (f'<g transform="translate({(w - 110) / 2:.2f},120) scale(1.1)">{symbol(IVORY, GOLD)}</g>'
            + body_name
            + f'<path transform="translate({(w - w_tag) / 2:.2f},{tag_y:.2f})" d="{d_tag}" fill="{IVORY}" fill-opacity="0.72"/>')
    return svg(w, h, body, NAVY)


os.makedirs(OUT, exist_ok=True)
files = {
    "ardenza-horizontal.svg": horizontal(NAVY, GOLD),
    "ardenza-horizontal-negativo.svg": horizontal(IVORY, GOLD, background=NAVY),
    "ardenza-vertical.svg": stacked(NAVY, GOLD),
    "ardenza-vertical-negativo.svg": stacked(IVORY, GOLD, background=NAVY),
    "ardenza-simbolo.svg": svg(124, 148, f'<g transform="translate(12,12)">{symbol(NAVY, GOLD)}</g>'),
    "ardenza-favicon.svg": favicon(),
    "ardenza-redes-1200x630.svg": og_image(),
}
for name, content in files.items():
    with open(os.path.join(OUT, name), "w", encoding="utf-8") as f:
        f.write(content)
    print(name)
