"""Texturas pintadas del kit de la arena: color, normal y rugosidad, 1024 px, 2x2 celdas.
Claras para teñirlas desde SurfaceAppearance.Color. Logos y números inventados.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/texturas_kit.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "arena-kit"
T = 1024
C = T // 2
r = np.random.default_rng(12)


def ruido(n, escala, oct=4):
    total = np.zeros((n, n), np.float32)
    amp = 1.0
    for o in range(oct):
        k = max(escala * 2**o, 2)
        g = (r.random((k, k)) * 255).astype(np.uint8)
        total += amp * np.asarray(Image.fromarray(g).resize((n, n), Image.BICUBIC), np.float32) / 255
        amp *= 0.55
    return (total - total.min()) / (total.max() - total.min())


def paso(a, b, v):
    t = np.clip((v - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def bordes(n, ancho):
    y, x = np.mgrid[0:n, 0:n].astype(np.float32) / n
    d = np.minimum(np.minimum(x, 1 - x), np.minimum(y, 1 - y))
    return 1 - paso(0, ancho, d)


def chorreados(n, cantidad, largo):
    m = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(m)
    for _ in range(cantidad):
        x, y = int(r.integers(0, n)), int(r.integers(0, n // 3))
        d.line([x, y, x + int(r.integers(-3, 4)), y + int(r.integers(largo // 3, largo))],
               fill=int(r.integers(90, 220)), width=int(r.integers(2, 6)))
    return np.asarray(m.filter(ImageFilter.GaussianBlur(1.6)), np.float32) / 255


def rayones(n, cantidad):
    m = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(m)
    for _ in range(cantidad):
        x, y = r.integers(0, n, 2)
        d.line([int(x), int(y), int(x + r.integers(-90, 90)), int(y + r.integers(-30, 30))],
               fill=int(r.integers(110, 255)), width=1)
    return np.asarray(m, np.float32) / 255


def metal_pintado(pintura, oxido_extra=0.0, abolladuras=False):
    """Devuelve color, alto y rugosidad de una celda."""
    n = C
    grande, fino = ruido(n, 4), ruido(n, 24)
    filo = bordes(n, 0.09)
    oxido = paso(0.74 - oxido_extra, 0.84 - oxido_extra, grande * 0.62 + fino * 0.22 + filo * 0.42)
    pelado = paso(0.63, 0.67, ruido(n, 9) * 0.8 + filo * 0.25) * (1 - oxido)
    chorro = chorreados(n, 46, 200)
    raya = rayones(n, 80)
    y = np.linspace(0, 1, n, dtype=np.float32)[:, None] * np.ones((1, n), np.float32)
    suciedad = paso(0.62, 1.0, y) * (0.6 + 0.4 * fino)
    polvo = paso(0.25, 0.0, y) * (0.5 + 0.5 * grande)
    color = np.ones((n, n, 3), np.float32) * np.array(pintura, np.float32)
    color *= (0.9 + 0.2 * fino)[..., None]
    plata = np.array([0.62, 0.62, 0.6], np.float32)
    marron = np.array([0.46, 0.27, 0.17], np.float32) * (0.75 + 0.5 * fino)[..., None]
    color = color * (1 - pelado[..., None]) + plata * pelado[..., None]
    color = color * (1 - raya[..., None] * 0.6) + plata * raya[..., None] * 0.6
    color = color * (1 - oxido[..., None]) + marron * oxido[..., None]
    color = color * (1 - chorro[..., None] * 0.7) + marron * chorro[..., None] * 0.7
    color *= (1 - suciedad * 0.5)[..., None]
    color = color + polvo[..., None] * 0.1
    alto = fino * 0.25 + oxido * 0.5 - pelado * 0.35 - raya * 0.25
    if abolladuras:
        for _ in range(7):
            cx, cy, rad = r.integers(0, n), r.integers(0, n), r.integers(26, 70)
            yy, xx = np.mgrid[0:n, 0:n]
            alto -= 1.1 * np.exp(-(((xx - cx) ** 2 + (yy - cy) ** 2) / rad**2))
    rugoso = 0.42 + oxido * 0.5 + suciedad * 0.15 - pelado * 0.15
    return color, alto, rugoso


def madera(tono=(0.62, 0.45, 0.3)):
    n = C
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    onda = ruido(n, 3, 3) * 26
    vetas = 0.5 + 0.5 * np.sin((y + onda) * 3.8 + ruido(n, 6, 2) * 9)
    color = np.ones((n, n, 3), np.float32) * np.array(tono, np.float32)
    color *= (0.95 + 0.09 * vetas)[..., None]
    alto = vetas * 0.08
    for _ in range(5):  # nudos
        cx, cy, rad = r.integers(0, n), r.integers(0, n), r.integers(10, 26)
        d = np.sqrt((x - cx) ** 2 + ((y - cy) * 1.6) ** 2)
        nudo = np.exp(-(d / rad) ** 2)
        color *= (1 - nudo * 0.6)[..., None]
        alto -= nudo * 0.5
    gasto = bordes(n, 0.07) * (0.5 + 0.5 * ruido(n, 18, 2))
    color = color * (1 - gasto[..., None]) + np.array([0.8, 0.72, 0.58], np.float32) * gasto[..., None]
    return color, alto, 0.82 + 0.1 * vetas


def oscuro():
    n = C
    f = ruido(n, 20)
    return np.ones((n, n, 3), np.float32) * (0.1 + 0.08 * f)[..., None], f * 0.2, 0.75 + 0 * f


def rotular(color):
    """Número de serie y logo inventado sobre la celda del costado."""
    im = Image.fromarray((np.clip(color, 0, 1) * 255).astype(np.uint8))
    d = ImageDraw.Draw(im)
    f1 = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 34)
    f2 = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 22)
    d.text((40, 90), "OXD 417205 3", font=f1, fill=(232, 232, 226))
    d.text((40, 136), "22G1  MAX 30480 KG", font=f2, fill=(222, 222, 216))
    d.ellipse((340, 300, 460, 420), outline=(232, 232, 226), width=9)
    d.polygon([(400, 318), (438, 392), (362, 392)], outline=(232, 232, 226), width=7)
    d.text((326, 430), "MAREA", font=f1, fill=(232, 232, 226))
    return np.asarray(im, np.float32) / 255


def normal(alto):
    fuerza = 1.1
    gy, gx = np.gradient(alto * fuerza)
    n = np.dstack([-gx * 8, gy * 8, np.ones_like(alto)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    return (n * 0.5 + 0.5) * 255


def guardar(nombre, celdas):
    col = np.zeros((T, T, 3), np.float32)
    alt = np.zeros((T, T), np.float32)
    rug = np.zeros((T, T), np.float32)
    # Blender cuenta la celda 0 abajo a la izquierda.
    lugares = [(C, 0), (C, C), (0, 0), (0, C)]
    for (c, a, g), (fy, fx) in zip(celdas, lugares):
        col[fy:fy + C, fx:fx + C] = c
        alt[fy:fy + C, fx:fx + C] = a
        rug[fy:fy + C, fx:fx + C] = g
    Image.fromarray((np.clip(col, 0, 1) * 255).astype(np.uint8)).save(SALIDA / f"K_{nombre}_color.png")
    Image.fromarray(normal(alt).astype(np.uint8)).save(SALIDA / f"K_{nombre}_normal.png")
    g = (np.clip(rug, 0, 1) * 255).astype(np.uint8)
    Image.fromarray(np.dstack([g, g, g])).save(SALIDA / f"K_{nombre}_rough.png")


def ladrillos():
    filas, cols, junta = 14, 7, 6
    alto_l, ancho_l = T // filas, T // cols
    y, x = np.mgrid[0:T, 0:T]
    fila = y // alto_l
    corrido = np.where(fila % 2 == 1, ancho_l // 2, 0)
    xx = x + corrido
    col = (xx // ancho_l) % cols
    es_junta = (y % alto_l < junta) | (xx % ancho_l < junta)
    azar = r.uniform(0.72, 1.1, (filas + 1, cols + 1)).astype(np.float32)
    tono = azar[np.minimum(fila, filas), col]
    f = ruido(T, 40)
    g = ruido(T, 5)
    base = np.array([0.5, 0.23, 0.16], np.float32) * (tono * (0.82 + 0.3 * f))[..., None]
    cemento = np.array([0.6, 0.58, 0.53], np.float32) * (0.8 + 0.3 * f)[..., None]
    color = np.where(es_junta[..., None], cemento, base)
    yy = np.linspace(0, 1, T, dtype=np.float32)[:, None]
    color *= (1 - paso(0.6, 1, yy) * 0.5 * (0.6 + 0.4 * g))[..., None]
    alto = np.where(es_junta, 0.0, 1.0) + f * 0.3
    alto = np.asarray(Image.fromarray((np.clip(alto / 1.3, 0, 1) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.3)), np.float32) / 255
    Image.fromarray((np.clip(color, 0, 1) * 255).astype(np.uint8)).save(SALIDA / "K_ladrillo_color.png")
    Image.fromarray(normal(alto).astype(np.uint8)).save(SALIDA / "K_ladrillo_normal.png")
    gr = (np.full((T, T), 0.9) * 255).astype(np.uint8)
    Image.fromarray(np.dstack([gr, gr, gr])).save(SALIDA / "K_ladrillo_rough.png")


claro = (0.86, 0.86, 0.84)
c, a, g = metal_pintado(claro, abolladuras=True)
guardar("contenedor", [(rotular(c), a, g), metal_pintado(claro, 0.14), metal_pintado((0.26, 0.27, 0.29), 0.05), oscuro()])
guardar("metal", [metal_pintado(claro, 0.1), metal_pintado(claro, 0.22), metal_pintado((0.72, 0.72, 0.7), 0.05), oscuro()])
guardar("madera", [madera(), madera((0.48, 0.34, 0.23)), madera((0.7, 0.54, 0.38)), oscuro()])
ladrillos()
