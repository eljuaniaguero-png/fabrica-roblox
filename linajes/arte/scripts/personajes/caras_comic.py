"""Tres caras en estilo cómic urbano: PNG con fondo transparente. Se corre con Python común y Pillow.

Uso:
    python linajes/arte/scripts/personajes/caras_comic.py
"""

import os

from PIL import Image, ImageDraw

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SALIDA = os.path.join(ARTE, "exports", "cuerpo-comic", "caras")
T = 512
NEGRO = (20, 20, 28, 255)
BLANCO = (242, 240, 234, 255)


def ojo(d, lado, iris, alto, caida):
    """Ojo anguloso: lado -1 izquierda de la imagen, 1 derecha. caida inclina hacia la nariz."""
    cx = T / 2 + lado * 112
    forma = [(cx - 72, 248 + (caida if lado > 0 else -caida)), (cx + 72, 248 + (-caida if lado > 0 else caida)), (cx + 58, 248 + alto), (cx - 58, 248 + alto)]
    d.polygon(forma, fill=BLANCO, outline=NEGRO, width=8)
    ix = cx - lado * 12
    d.rectangle([ix - 25, 248, ix + 25, 244 + alto], fill=iris)
    d.rectangle([ix - 10, 256, ix + 10, 240 + alto], fill=NEGRO)


def ceja(d, lado, inclina, grosor):
    cx = T / 2 + lado * 112
    a = (cx - lado * 88, 208 + inclina)
    b = (cx + lado * 88, 190 - inclina)
    d.polygon([a, b, (b[0], b[1] + grosor), (a[0], a[1] + grosor)], fill=NEGRO)


def boca(d, puntos, ancho=9):
    d.line(puntos, fill=NEGRO, width=ancho, joint="curve")


def hacer(n, iris, alto, caida, inclina, grosor, boca_puntos, marca=False):
    im = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for lado in (-1, 1):
        ojo(d, lado, iris, alto, caida)
        ceja(d, lado, inclina, grosor)
    boca(d, boca_puntos)
    if marca:
        d.line([(372, 198), (340, 318)], fill=(150, 48, 45, 255), width=11)
    im.save(os.path.join(SALIDA, f"cara-{n}.png"))


os.makedirs(SALIDA, exist_ok=True)
hacer(1, (57, 211, 255, 255), 58, 12, 24, 25, [(222, 395), (292, 395)])
hacer(2, (120, 214, 110, 255), 48, 20, 34, 29, [(205, 400), (250, 390), (305, 398)])
hacer(3, (245, 170, 60, 255), 66, 6, 14, 20, [(218, 390), (256, 404), (300, 386)], True)
