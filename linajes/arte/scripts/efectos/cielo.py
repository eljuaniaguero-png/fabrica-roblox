"""Cielo propio de la arena: verde azulado, nubes suaves y luna eclipsada en una cara.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/cielo.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "cielo"
SALIDA.mkdir(parents=True, exist_ok=True)
T = 1024
r = np.random.default_rng(4)
ALTO = np.array([7, 22, 38], np.float32)
MEDIO = np.array([16, 70, 86], np.float32)
HORIZONTE = np.array([64, 150, 150], np.float32)


def ruido(escala):
    total = np.zeros((T, T), np.float32)
    amp = 1.0
    for o in range(5):
        k = escala * 2**o
        g = (r.random((k, k)) * 255).astype(np.uint8)
        total += amp * np.asarray(Image.fromarray(g).resize((T, T), Image.BICUBIC), np.float32) / 255
        amp *= 0.5
    return (total - total.min()) / (total.max() - total.min())


def paso(a, b, v):
    t = np.clip((v - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def costado(luna=False):
    y = np.linspace(0, 1, T, dtype=np.float32)[:, None] * np.ones((1, T), np.float32)
    x = np.linspace(0, 1, T, dtype=np.float32)[None, :] * np.ones((T, 1), np.float32)
    t = paso(0, 0.5, y)[..., None]
    h = paso(0.5, 1, y)[..., None]
    c = ALTO * (1 - t) + MEDIO * t
    c = c * (1 - h) + HORIZONTE * h
    nubes = paso(0.55, 0.8, ruido(3)) * paso(0.2, 0.5, y) * paso(0.98, 0.7, y)
    nubes *= paso(0, 0.1, x) * paso(1, 0.9, x)  # sin costura entre caras
    c = c * (1 - nubes[..., None] * 0.5) + np.array([120, 170, 170], np.float32) * nubes[..., None] * 0.5
    estrellas = (r.random((T, T)) > 0.9985) * paso(0.55, 0.1, y)
    c += estrellas[..., None] * 170
    if luna:
        yy, xx = np.mgrid[0:T, 0:T].astype(np.float32)
        d = np.hypot(xx - T * 0.5, yy - T * 0.4)
        radio = 80
        halo = np.exp(-(((d - radio) / 46) ** 2)) * 0.8
        c = c * (1 - halo[..., None]) + np.array([255, 150, 70], np.float32) * halo[..., None]
        anillo = np.exp(-(((d - radio) / 4) ** 2))
        c = c * (1 - anillo[..., None]) + np.array([255, 236, 190], np.float32) * anillo[..., None]
        disco = paso(radio, radio - 3, d)
        c = c * (1 - disco[..., None]) + np.array([9, 12, 20], np.float32) * disco[..., None]
    return c


def guardar(nombre, c):
    Image.fromarray(np.clip(c, 0, 255).astype(np.uint8)).save(SALIDA / f"{nombre}.png")


for n in ("Bk", "Lf", "Rt"):
    guardar(n, costado())
guardar("Ft", costado(True))
guardar("Up", np.ones((T, T, 3), np.float32) * ALTO)
guardar("Dn", np.ones((T, T, 3), np.float32) * np.array([10, 24, 30], np.float32))
