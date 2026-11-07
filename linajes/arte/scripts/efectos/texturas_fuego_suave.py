"""Texturas suaves de llama y humo: blancas, sin contornos, en hojas de 4x4 (512 px).
El color lo pone cada capa desde Config.Efectos.Fuego.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/texturas_fuego_suave.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "efectos"
C = 128
yy, xx = np.mgrid[0:C, 0:C].astype(np.float32)
x = (xx - C / 2 + 0.5) / (C / 2)
y = (yy - C / 2 + 0.5) / (C / 2)


def ruido(escala, semilla):
    r = np.random.default_rng(semilla)
    total = np.zeros((C, C), np.float32)
    amp = 1.0
    for o in range(4):
        n = escala * 2**o
        g = (r.random((n, n)) * 255).astype(np.uint8)
        g = np.tile(g, (3, 3))
        big = np.asarray(Image.fromarray(g).resize((C * 3, C * 3), Image.BICUBIC), np.float32)
        total += amp * big[C:2 * C, C:2 * C] / 255
        amp *= 0.55
    return (total - total.min()) / (total.max() - total.min())


N = ruido(3, 31)
M = ruido(5, 32)


def cuadro(t, estirar, dureza):
    a = np.roll(N, int(t * C), axis=0)
    b = np.roll(M, int(t * C * 2), axis=0)
    dx = x + (a - 0.5) * 0.5
    dy = (y + (b - 0.5) * 0.5) / estirar
    r = np.hypot(dx, dy)
    base = np.exp(-((r / 0.5) ** 2) * dureza)
    detalle = 0.45 + 0.9 * (a * 0.6 + b * 0.4)
    borde = np.clip((1 - np.hypot(x, y)) / 0.25, 0, 1)
    return np.clip(base * detalle, 0, 1) * borde


def hoja(nombre, estirar, dureza):
    img = np.zeros((C * 4, C * 4), np.float32)
    for i in range(16):
        f, c = divmod(i, 4)
        img[f * C:(f + 1) * C, c * C:(c + 1) * C] = cuadro(i / 16, estirar, dureza)
    alfa = Image.fromarray((img * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    blanco = Image.new("L", alfa.size, 255)
    Image.merge("RGBA", (blanco, blanco, blanco, alfa)).save(SALIDA / f"{nombre}.png")


hoja("llama-suave", 1.35, 1.5)
hoja("humo-suave", 1.0, 1.0)
