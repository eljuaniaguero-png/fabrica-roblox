"""Limpia las imágenes del HUD pixel de ForgeGUI (etapa 10b).

- Íconos: saca el fondo blanco (relleno desde los bordes), recorta y deja 128 x 128.
- Panel y casillero: ahueca el centro oscuro (relleno desde el medio) para poder poner texto
  encima en Roblox (9-slice), recorta y deja 256 x 256.
Entrada: plinko-knight/arte/forgegui/pixel/*.png  ->  salida: .../pixel/limpias/*.png
Uso: python -I plinko-knight/modelos/scripts/limpiar_hud.py <carpeta pixel>
"""

import os
import sys
from collections import deque

from PIL import Image

ICONOS = ["corazon", "moneda", "engranaje", "puerta", "espada", "llama"]
MARCOS = ["panel", "casillero"]


def parecido(a, b, tolerancia):
    return all(abs(x - y) <= tolerancia for x, y in zip(a[:3], b[:3]))


def rellenar_transparente(im, inicios, tolerancia):
    """Vuelve transparentes los píxeles conectados a `inicios` con color parecido al del inicio."""
    px = im.load()
    w, h = im.size
    vistos = set()
    for inicio in inicios:
        base = px[inicio]
        cola = deque([inicio])
        while cola:
            x, y = cola.popleft()
            if (x, y) in vistos or not (0 <= x < w and 0 <= y < h):
                continue
            c = px[x, y]
            if c[3] != 0 and not parecido(c, base, tolerancia):
                continue
            vistos.add((x, y))
            px[x, y] = (0, 0, 0, 0)
            cola.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))


def recortar(im):
    caja = im.getbbox()
    return im.crop(caja) if caja else im


def main(carpeta):
    salida = os.path.join(carpeta, "limpias")
    os.makedirs(salida, exist_ok=True)
    for nombre in ICONOS:
        im = Image.open(os.path.join(carpeta, nombre + ".png")).convert("RGBA")
        w, h = im.size
        rellenar_transparente(im, [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)], 18)
        im = recortar(im)
        lado = max(im.size)
        cuadro = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
        cuadro.paste(im, ((lado - im.size[0]) // 2, (lado - im.size[1]) // 2))
        cuadro.resize((128, 128), Image.LANCZOS).save(os.path.join(salida, nombre + ".png"))
    for nombre in MARCOS:
        im = recortar(Image.open(os.path.join(carpeta, nombre + ".png")).convert("RGBA"))
        w, h = im.size
        rellenar_transparente(im, [(w // 2, h // 2)], 14)
        im.resize((256, 256), Image.LANCZOS).save(os.path.join(salida, nombre + ".png"))
    print("listo:", salida)


if __name__ == "__main__":
    main(sys.argv[1])
