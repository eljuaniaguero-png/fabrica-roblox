"""Texturas del rincón: cemento mojado con juntas, charco, reflejo de luz y cielo de niebla.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/texturas_rincon.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "rincon"
SALIDA.mkdir(parents=True, exist_ok=True)
T = 1024
r = np.random.default_rng(21)


def ruido(escala, oct=5, n=T):
    total = np.zeros((n, n), np.float32)
    amp = 1.0
    for o in range(oct):
        k = escala * 2**o
        g = r.random((k, k)).astype(np.float32)
        g = np.tile(g, (3, 3))
        im = Image.fromarray((g * 255).astype(np.uint8)).resize((n * 3, n * 3), Image.BICUBIC)
        total += amp * np.asarray(im, np.float32)[n:2 * n, n:2 * n] / 255
        amp *= 0.5
    return (total - total.min()) / (total.max() - total.min())


def paso(a, b, v):
    t = np.clip((v - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def piso():
    grande, fino = ruido(3), ruido(32, 3)
    c = np.ones((T, T, 3), np.float32) * np.array([43, 47, 54], np.float32)
    c *= (0.72 + 0.2 * grande + 0.1 * fino)[..., None]
    mojado = paso(0.5, 0.72, ruido(4))
    c *= (1 - 0.42 * mojado)[..., None]
    oxido = paso(0.78, 0.9, ruido(5))[..., None]
    c = c * (1 - oxido * 0.35) + np.array([62, 40, 28], np.float32) * oxido * 0.35
    y, x = np.mgrid[0:T, 0:T]
    junta = (np.minimum(x % 512, 512 - x % 512) < 3) | (np.minimum(y % 512, 512 - y % 512) < 3)
    c[junta] *= 0.32
    for _ in range(9):  # grietas finas
        px, py = r.integers(0, T, 2).astype(np.float32)
        ang = r.uniform(0, 6.28)
        for _ in range(170):
            ang += r.uniform(-0.45, 0.45)
            px, py = (px + np.cos(ang) * 2) % T, (py + np.sin(ang) * 2) % T
            c[int(py), int(px)] *= 0.55
    Image.fromarray(np.clip(c, 0, 255).astype(np.uint8)).save(SALIDA / "piso.png")


def charco():
    n = 512
    y, x = np.mgrid[0:n, 0:n].astype(np.float32) / n - 0.5
    d = np.hypot(x * 1.15, y * 1.7) + (ruido(4, 4, n) - 0.5) * 0.3
    alfa = 1 - paso(0.27, 0.37, d)
    tono = np.ones((n, n, 3), np.float32) * np.array([24, 32, 50], np.float32)
    brillo = paso(0.2, 0.34, d) * alfa
    tono += brillo[..., None] * np.array([48, 56, 74], np.float32)
    im = np.dstack([tono, alfa * 205]).astype(np.uint8)
    Image.fromarray(im, "RGBA").save(SALIDA / "charco.png")


def reflejo():
    n = 512
    y, x = np.mgrid[0:n, 0:n].astype(np.float32) / n
    ancho = 0.16 + 0.1 * y
    a = np.exp(-(((x - 0.5) / ancho) ** 2)) * paso(0, 0.1, y) * paso(1, 0.25, y)
    a *= 0.62 + 0.55 * ruido(5, 3, n)
    blanco = np.full((n, n), 255, np.float32)
    im = np.dstack([blanco, blanco, blanco, np.clip(a, 0, 1) * 255]).astype(np.uint8)
    Image.fromarray(im, "RGBA").filter(ImageFilter.GaussianBlur(2)).save(SALIDA / "reflejo.png")


def estrellas(c, cantidad, fuerza, alto=1.0):
    """Puntos tenues; alto 1 = todo el cuadro, 0.6 = solo la parte de arriba."""
    n = c.shape[0]
    for _ in range(cantidad):
        x = int(r.integers(0, n))
        y = int(r.integers(0, max(2, int(n * alto))))
        b = r.uniform(0.35, 1.0) ** 2 * fuerza
        c[y, x] += np.array([b * 210, b * 220, b * 255], np.float32)
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            c[(y + dy) % n, (x + dx) % n] += np.array([b * 60, b * 64, b * 76], np.float32)
    return c


def cielo():
    """Noche de verdad: cenit azul casi negro (#0b1020) y niebla azul en el horizonte.
    En un skybox el horizonte cae en el MEDIO de la cara: el resplandor va en y=0,5."""
    y = np.linspace(0, 1, T, dtype=np.float32)[:, None] * np.ones((1, T), np.float32)
    cenit = np.array([11, 16, 32], np.float32)
    niebla = np.array([56, 72, 108], np.float32)
    # Resplandor de niebla centrado en el horizonte (y = 0,5), que se apaga hacia arriba.
    glow = np.exp(-(((y - 0.5) / 0.14) ** 2))
    bajo = paso(0.5, 0.95, y)  # debajo del horizonte, agua: se apaga
    c = cenit + (niebla - cenit) * (glow * (1 - 0.7 * bajo))[..., None]
    c *= (0.94 + 0.12 * ruido(3))[..., None]
    c = estrellas(c, 420, 0.75, 0.42)
    Image.fromarray(np.clip(c, 0, 255).astype(np.uint8)).save(SALIDA / "cielo.png")
    a = np.ones((T, T, 3), np.float32) * np.array([10, 14, 28], np.float32)
    a *= (0.94 + 0.12 * ruido(3))[..., None]
    a = estrellas(a, 700, 0.8)
    Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).save(SALIDA / "cielo-arriba.png")
    b = np.ones((64, 64, 3), np.uint8) * np.array([9, 12, 22], np.uint8)
    Image.fromarray(b).save(SALIDA / "cielo-abajo.png")


def sombra():
    """Sombra de contacto: mancha oscura blanda para apoyar los objetos en el piso."""
    n = 512
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) / n - 0.5
    d = np.hypot(xx, yy) * 2
    a = (1 - paso(0.15, 1.0, d)) ** 1.6 * 0.72
    im = np.dstack([np.zeros((n, n, 3), np.float32), np.clip(a, 0, 1) * 255]).astype(np.uint8)
    Image.fromarray(im, "RGBA").filter(ImageFilter.GaussianBlur(6)).save(SALIDA / "sombra.png")


piso()
charco()
reflejo()
cielo()
sombra()
