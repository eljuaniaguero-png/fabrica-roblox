"""Dibuja las texturas propias del golpe: hojas de 4x4 cuadros, blancas con transparencia.
Uso: uv run --python 3.12 --with pillow --with numpy python linajes/arte/scripts/efectos/texturas_golpe.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

SALIDA = Path(__file__).resolve().parents[2] / "exports" / "efectos"
C = 256  # lado de cada cuadro; la hoja queda de 1024
y, x = np.mgrid[0:C, 0:C].astype(np.float32)
x = (x - C / 2 + 0.5) / (C / 2)
y = (y - C / 2 + 0.5) / (C / 2)
R = np.hypot(x, y)
A = np.arctan2(y, x)
rng = np.random.default_rng(7)


def suave(a, b, v):
    t = np.clip((v - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def ruido(escala, semilla):
    r = np.random.default_rng(semilla)
    total = np.zeros((C, C), np.float32)
    amp = 1.0
    for o in range(4):
        n = escala * 2**o
        g = (r.random((n + 1, n + 1)) * 255).astype(np.uint8)
        total += amp * np.asarray(Image.fromarray(g).resize((C, C), Image.BICUBIC), np.float32) / 255
        amp *= 0.5
    return (total - total.min()) / (total.max() - total.min())


def perfil_angular(puntas, semilla):
    """Largo de cada punta según el ángulo."""
    r = np.random.default_rng(semilla)
    v = np.zeros_like(A)
    for _ in range(puntas):
        c, largo, ancho = r.uniform(-np.pi, np.pi), r.uniform(0.35, 1), r.uniform(0.03, 0.085)
        d = np.abs((A - c + np.pi) % (2 * np.pi) - np.pi)
        v = np.maximum(v, largo * np.clip(1 - d / ancho, 0, 1))
    return v


def destello(t):
    crece = 1 - (1 - min(t / 0.25, 1)) ** 3
    apaga = 1 - suave(0.3, 1, t)
    puntas = perfil_angular(13, 3) * 0.95 * crece
    forma = R < puntas * (1 - 0.25 * t)
    grosor = 1 - 0.75 * t
    largas = suave(0.0, 0.02, puntas - R) * grosor
    nucleo = np.exp(-((R / (0.22 * crece * (1 - t) + 0.01)) ** 2))
    halo = 0.3 * np.exp(-((R / (0.5 * crece + 0.01)) ** 2)) * (1 - t)
    return np.clip(np.maximum(largas * forma, nucleo) + halo, 0, 1) * apaga


def anillo(t):
    radio = 0.12 + 0.8 * (1 - (1 - t) ** 3)
    irregular = 0.5 + 0.5 * np.sin(A * 3 + 1) * np.sin(A * 7 + 2)
    ancho = (0.09 * (1 - t) ** 1.4 + 0.004) * (0.45 + 0.9 * irregular)
    borde = 1 - suave(0, 1, np.abs(R - radio) / ancho)
    cortes = suave(0.15 + 0.6 * t, 0.3 + 0.6 * t, irregular + 0.25)
    return borde * cortes * (1 - suave(0.65, 1, t))


def arco(t):
    # Media luna afilada que barre de izquierda a derecha y se afina.
    centro = -0.9 + 2.3 * (1 - (1 - t) ** 2.4)
    ang = np.arctan2(y + 0.05, x)
    u = (ang + np.pi) / (2 * np.pi)  # 0..1 alrededor
    u = (ang - (-2.6)) / 2.2 - 0.0  # arco superior
    pos = (u * 2 - 1)
    largo = 0.8
    env = np.clip(1 - np.abs(pos - centro) / largo, 0, 1) ** 1.4
    radio = 0.74
    ancho = 0.27 * env * (1 - 0.65 * t)
    cuerpo = 1 - suave(0.45, 1, np.abs(R - radio) / (ancho + 1e-4))
    rayas = 0.72 + 0.28 * np.sin(R * 95 + 2)
    return np.clip(cuerpo * (env > 0) * rayas, 0, 1) * (1 - suave(0.7, 1, t))


BASE_HUMO = ruido(4, 11)
FINO_HUMO = ruido(10, 12)


def humo(t):
    radio = 0.3 + 0.55 * (1 - (1 - t) ** 2.5)
    borde = R + (BASE_HUMO - 0.5) * 0.65
    forma = 1 - suave(radio - 0.025, radio + 0.025, borde)
    limite = suave(0.15, 1, t) * 1.05
    disuelve = suave(limite - 0.05, limite + 0.05, FINO_HUMO * 0.6 + BASE_HUMO * 0.4)
    sombra = 0.82 + 0.18 * (BASE_HUMO > 0.48)  # dos tonos, tipo dibujo
    return forma * disuelve * sombra * (1 - suave(0.8, 1, t))


def lineas(t):
    inicio = 0.25 + 0.7 * t
    puntas = perfil_angular(26, 9)
    fin = inicio + puntas * 0.55 * (1 - t)
    franja = (R > inicio) & (R < fin)
    afina = np.clip(1 - np.abs(R - (inicio + fin) / 2) / ((fin - inicio) / 2 + 1e-4), 0, 1)
    return franja * (puntas > 0) * afina * (1 - suave(0.7, 1, t))


def hoja(nombre, fn):
    img = np.zeros((C * 4, C * 4), np.float32)
    for i in range(16):
        f, c = divmod(i, 4)
        marco = suave(0.92, 0.99, R)
        img[f * C:(f + 1) * C, c * C:(c + 1) * C] = np.clip(fn(i / 15), 0, 1) * (1 - marco)
    rgba = np.dstack([np.full_like(img, 255), np.full_like(img, 255), np.full_like(img, 255), img * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(SALIDA / f"{nombre}.png")
    fondo = Image.new("RGBA", (1024, 1024), (24, 26, 34, 255))
    fondo.alpha_composite(Image.fromarray(rgba, "RGBA"))
    return fondo.convert("RGB").resize((512, 512))


SALIDA.mkdir(parents=True, exist_ok=True)
vistas = [hoja(n, f) for n, f in [("destello", destello), ("anillo", anillo), ("arco", arco), ("humo", humo), ("lineas", lineas)]]
hojas = Image.new("RGB", (512 * 3, 1024), (0, 0, 0))
for i, v in enumerate(vistas):
    hojas.paste(v, ((i % 3) * 512, (i // 3) * 512))
hojas.save(SALIDA.parents[1] / "renders" / "efectos-golpe-hojas.jpg", quality=88)
