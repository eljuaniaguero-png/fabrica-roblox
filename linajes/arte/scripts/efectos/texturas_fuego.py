"""Dibuja el fuego propio: llama y bola, con el color ya pintado, en hojas de 4x4.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/texturas_fuego.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "efectos"
C = 256
yy, xx = np.mgrid[0:C, 0:C].astype(np.float32)
x = (xx - C / 2 + 0.5) / (C / 2)
y = (yy - C / 2 + 0.5) / (C / 2)
R = np.hypot(x, y)
V = (1 - y) / 2  # 0 abajo, 1 arriba
TONOS = [(0.16, (200, 34, 10)), (0.36, (255, 96, 20)), (0.58, (255, 186, 48)), (0.8, (255, 246, 196))]


def suave(a, b, v):
    t = np.clip((v - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def ruido(escala, semilla):
    r = np.random.default_rng(semilla)
    total = np.zeros((C, C), np.float32)
    amp = 1.0
    for o in range(3):
        n = escala * 2**o
        g = (r.random((n, n)) * 255).astype(np.uint8)
        g = np.pad(g, 2, mode="wrap")
        big = Image.fromarray(g).resize((C * (n + 4) // n, C * (n + 4) // n), Image.BICUBIC)
        k = 2 * C // n
        total += amp * np.asarray(big, np.float32)[k:k + C, k:k + C] / 255
        amp *= 0.5
    return (total - total.min()) / (total.max() - total.min())


N1, N2 = ruido(4, 21), ruido(7, 22)


def subir(n, t, vueltas=1):
    return np.roll(n, int(t * C * vueltas), axis=0)


def pintar(calor):
    rgb = np.zeros((C, C, 3), np.float32)
    rgb[:] = TONOS[0][1]
    for corte, color in TONOS[1:]:
        m = suave(corte - 0.015, corte + 0.015, calor)[..., None]
        rgb = rgb * (1 - m) + np.array(color, np.float32) * m
    alfa = suave(TONOS[0][0] - 0.03, TONOS[0][0] + 0.03, calor)
    return np.dstack([rgb, alfa * 255])


def llama(t):
    a, b = subir(N1, t), subir(N2, t, 2)
    onda = (a - 0.5) * 0.7 * (0.2 + V)
    ancho = 0.62 * np.clip(V * 7, 0, 1) ** 0.5 * np.clip(1 - V, 0, 1) ** 0.75 * (1 - 0.35 * t)
    forma = 1 - np.abs(x + onda) / (ancho + 1e-3)
    calor = forma * 1.05 - V * 0.28 + (b - 0.5) * 0.5 - suave(0.45, 1, t) * 0.8
    return pintar(np.clip(calor, 0, 1) * suave(0.0, 0.1, t + 0.04))


def bola(t):
    a, b = subir(N1, t), subir(N2, t, 2)
    calor = 1.02 - R / 0.72 + (a - 0.5) * 0.62 + (b - 0.5) * 0.28
    return pintar(np.clip(calor, 0, 1))


def hoja(nombre, fn):
    img = np.zeros((C * 4, C * 4, 4), np.float32)
    borde = 1 - suave(0.9, 0.99, np.maximum(np.abs(x), np.abs(y)))
    for i in range(16):
        f, c = divmod(i, 4)
        cuadro = fn(i / 16)
        cuadro[..., 3] *= borde
        img[f * C:(f + 1) * C, c * C:(c + 1) * C] = cuadro
    im = Image.fromarray(img.astype(np.uint8), "RGBA")
    im.save(SALIDA / f"{nombre}.png")
    fondo = Image.new("RGBA", im.size, (24, 26, 34, 255))
    fondo.alpha_composite(im)
    return fondo.convert("RGB").resize((640, 640))


vistas = [hoja("llama", llama), hoja("bola-fuego", bola)]
h = Image.new("RGB", (1280, 640))
h.paste(vistas[0], (0, 0))
h.paste(vistas[1], (640, 0))
h.save(SALIDA.parents[1] / "renders" / "efectos-fuego-hojas.jpg", quality=88)
