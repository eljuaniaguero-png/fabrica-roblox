"""Hoja de animaciones con una columna de nombres a la izquierda: una animación por fila (su
tira de 3 cuadros). Se corre con Python común (necesita Pillow), después de
base.py -- renders <grupo>.

Uso:
    python linajes/arte/scripts/animaciones/hoja.py combate
Lee renders/_hoja-<grupo>.txt (nombre|etiqueta, con "/" como salto de línea) y escribe
renders/anim-base-hoja-<grupo>.png.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

RENDERS = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "renders")
FONDO = (14, 16, 22)
TEXTO = (232, 234, 240)
ESCALA = 0.4
COLUMNA = 300


def fuente(tam):
    for f in ("segoeuib.ttf", "arialbd.ttf", "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(f, tam)
        except OSError:
            pass
    return ImageFont.load_default()


def armar(grupo):
    sufijo = "" if grupo == "locomocion" else f"-{grupo}"
    lista = os.path.join(RENDERS, f"_hoja{sufijo}.txt")
    with open(lista, encoding="utf-8") as fh:
        filas = [linea.rstrip("\n").split("|") for linea in fh if linea.strip()]
    tiras = [Image.open(os.path.join(RENDERS, f"anim-base-{n}.png")).convert("RGB") for n, _ in filas]
    tiras = [t.resize((int(t.width * ESCALA), int(t.height * ESCALA)), Image.LANCZOS) for t in tiras]
    ancho = COLUMNA + max(t.width for t in tiras)
    alto = sum(t.height for t in tiras)
    hoja = Image.new("RGB", (ancho, alto), FONDO)
    dibujo = ImageDraw.Draw(hoja)
    letra = fuente(30)
    y = 0
    for (_, etiqueta), tira in zip(filas, tiras):
        hoja.paste(tira, (COLUMNA, y))
        texto = etiqueta.replace("/", "\n")
        caja = dibujo.multiline_textbbox((0, 0), texto, font=letra, spacing=6)
        dibujo.multiline_text((24, y + (tira.height - (caja[3] - caja[1])) // 2), texto, font=letra, fill=TEXTO, spacing=6)
        dibujo.line((0, y + tira.height - 1, ancho, y + tira.height - 1), fill=(40, 44, 56), width=2)
        y += tira.height
    hoja.save(os.path.join(RENDERS, f"anim-base-hoja{sufijo}.png"))
    os.remove(lista)


if __name__ == "__main__":
    armar(sys.argv[1] if len(sys.argv) > 1 else "combate")
