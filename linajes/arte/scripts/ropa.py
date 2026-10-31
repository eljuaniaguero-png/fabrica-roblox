"""Plantillas de ropa clásica de Roblox (remera y pantalón) para el cuerpo propio.

Son blancas: el color lo pone el juego con Shirt.Color3 y Pants.Color3 (Config.Cuerpo.Ropa).
Lo transparente deja ver el color de la pieza: en la remera, la piel de los antebrazos
(manga corta); en el pantalón, las zapatillas (la parte de abajo de la pierna).

Uso: python linajes/arte/scripts/ropa.py  ->  arte/exports/cuerpo/ropa/{remera,pantalon}.png
"""

import os

from PIL import Image, ImageDraw

ARTE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SALIDA = os.path.join(ARTE, "exports", "cuerpo", "ropa")
BLANCO = (255, 255, 255, 255)
COSTURA = (205, 205, 205, 255)

# Zonas de la plantilla de 585x559 de Roblox (x, y, ancho, alto).
TORSO = [(231, 8, 128, 64), (231, 74, 128, 128), (165, 74, 64, 128), (361, 74, 64, 128), (427, 74, 128, 128), (231, 204, 128, 64)]
BRAZO_ARRIBA = [(217, 289, 64, 64), (308, 289, 64, 64)]
BRAZO_LADOS = [(x, 355, 64, 128) for x in (19, 85, 151, 217, 308, 374, 440, 506)]


def plantilla(manga, borde):
    """`manga` = fracción de arriba del brazo/pierna que se pinta; `borde` = alto de la costura."""
    img = Image.new("RGBA", (585, 559), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for x, y, w, h in TORSO + BRAZO_ARRIBA:
        d.rectangle([x, y, x + w - 1, y + h - 1], fill=BLANCO)
    for x, y, w, h in BRAZO_LADOS:
        alto = int(h * manga)
        d.rectangle([x, y, x + w - 1, y + alto - 1], fill=BLANCO)
        d.rectangle([x, y + alto - borde, x + w - 1, y + alto - 1], fill=COSTURA)
    return img


def main():
    os.makedirs(SALIDA, exist_ok=True)
    remera = plantilla(manga=0.42, borde=5)
    d = ImageDraw.Draw(remera)
    d.rectangle([231 + 40, 74, 231 + 88, 80], fill=COSTURA)  # cuello
    d.rectangle([231, 74 + 122, 231 + 127, 74 + 127], fill=COSTURA)  # ruedo
    remera.save(os.path.join(SALIDA, "remera.png"))
    pantalon = plantilla(manga=0.85, borde=6)
    d = ImageDraw.Draw(pantalon)
    d.rectangle([231, 74 + 96, 231 + 127, 74 + 104], fill=COSTURA)  # cinturón
    pantalon.save(os.path.join(SALIDA, "pantalon.png"))
    print("Listo:", SALIDA)


if __name__ == "__main__":
    main()
