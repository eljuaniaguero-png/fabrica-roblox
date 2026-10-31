"""Caras y marcas del cuerpo propio, estilo anime (texturas con fondo transparente).

Estilo (pedido de Juani, 31 oct, a partir de capturas de referencia en arte/referencias/anime/):
ojos almendrados con delineado negro grueso que termina en punta, iris grande oscuro con brillo,
blanco grisáceo con sombra arriba, cejas finas en punta, arrugas de ceño al enojarse, nariz
marcada con una sombra de costado y un brillo, boca de línea con sombra del labio de abajo.
Se toma la idea, no el dibujo: proporciones, colores de iris y bocas son nuestros.

Uso (Python de la compu, necesita Pillow):
    python linajes/arte/scripts/caras.py

Escribe en linajes/arte/exports/cuerpo/:
- caras/cara_<NN>_<expresion>.png: 12 caras x 8 expresiones (1024 px).
- caras/hoja_caras.png: las 12 caras neutrales (4x3). caras/hoja_expresiones.png: la 01 (4x2).
- marcas/marca_<NN>.png: 6 cicatrices o marcas.

Proyección de frente (ver cuerpo.py, uv_cabeza): x de -0,18 a 0,18 m -> u, z de 1,205 a 1,535 -> v.
"""

import math
import os
import random

from PIL import Image, ImageDraw

ARTE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SALIDA = os.path.join(ARTE, "exports", "cuerpo")

LADO = 1024
SS = 3
MEDIO_ANCHO = 0.18
Z_ARRIBA, Z_ABAJO = 1.535, 1.205

NEGRO = (16, 14, 16, 255)
EXPRESIONES = ["neutral", "enojado", "contento", "sorprendido", "dolor", "concentrado", "cansado", "derrotado"]

GESTOS = {
    "neutral": dict(ceja_in=0.0, ceja_out=0.0, abre=1.0, enojo=0.15, mejilla=0.0, sonrisa=0.0, boca=0.0, dientes=None, pupila=1.0, mira=0.0, ceno=0),
    "enojado": dict(ceja_in=-0.012, ceja_out=0.006, abre=0.85, enojo=0.7, mejilla=0.0, sonrisa=-0.3, boca=0.0, dientes=None, pupila=0.8, mira=0.0, ceno=3),
    "contento": dict(ceja_in=0.002, ceja_out=0.002, abre=0.8, enojo=0.0, mejilla=0.5, sonrisa=1.0, boca=0.8, dientes="arriba", pupila=1.0, mira=0.0, ceno=0),
    "sorprendido": dict(ceja_in=0.014, ceja_out=0.012, abre=1.45, enojo=0.0, mejilla=0.0, sonrisa=0.0, boca=0.9, dientes="redonda", pupila=0.6, mira=0.0, ceno=0),
    "dolor": dict(ceja_in=0.010, ceja_out=-0.006, abre=0.1, enojo=0.0, mejilla=0.3, sonrisa=-0.4, boca=0.5, dientes="apretados", pupila=1.0, mira=0.0, ceno=2),
    "concentrado": dict(ceja_in=-0.007, ceja_out=0.002, abre=0.62, enojo=0.5, mejilla=0.1, sonrisa=-0.1, boca=0.0, dientes=None, pupila=0.9, mira=0.0, ceno=2),
    "cansado": dict(ceja_in=0.002, ceja_out=-0.006, abre=0.45, enojo=0.0, mejilla=0.0, sonrisa=-0.15, boca=0.0, dientes=None, pupila=1.0, mira=-0.004, ceno=0, ojeras=True),
    "derrotado": dict(ceja_in=0.010, ceja_out=-0.008, abre=0.55, enojo=0.0, mejilla=0.0, sonrisa=-0.7, boca=0.0, dientes=None, pupila=1.0, mira=-0.008, ceno=0),
}

# 12 caras: tamaño del ojo, rabillo (sube afuera), iris, delineado, ceja, boca, extras.
CARAS = [
    dict(ojo=(0.036, 0.014), punta=0.5, iris=(40, 34, 32), linea=1.0, ceja=1.0, boca=0.050),
    dict(ojo=(0.034, 0.018), punta=0.2, iris=(70, 46, 30), linea=0.8, ceja=0.8, boca=0.044, pliegue=True),
    dict(ojo=(0.040, 0.012), punta=0.8, iris=(30, 30, 36), linea=1.2, ceja=1.2, boca=0.054),
    dict(ojo=(0.033, 0.019), punta=0.1, iris=(50, 90, 140), linea=0.9, ceja=0.7, boca=0.042, pestanas=True),
    dict(ojo=(0.037, 0.013), punta=0.6, iris=(90, 70, 36), linea=1.1, ceja=1.3, boca=0.056, barba=True),
    dict(ojo=(0.032, 0.017), punta=0.3, iris=(80, 86, 96), linea=0.8, ceja=0.8, boca=0.044, pecas=True),
    dict(ojo=(0.041, 0.011), punta=0.9, iris=(24, 22, 24), linea=1.3, ceja=1.1, boca=0.050, pestanas=True),
    dict(ojo=(0.035, 0.015), punta=0.4, iris=(150, 100, 30), linea=1.0, ceja=0.9, boca=0.048, pliegue=True),
    dict(ojo=(0.036, 0.013), punta=0.7, iris=(60, 46, 40), linea=1.1, ceja=1.4, boca=0.058, ojeras=True),
    dict(ojo=(0.033, 0.018), punta=0.25, iris=(40, 110, 100), linea=0.9, ceja=0.75, boca=0.044, pestanas=True, pecas=True),
    dict(ojo=(0.037, 0.015), punta=0.5, iris=(80, 54, 120), linea=1.0, ceja=1.0, boca=0.050, pliegue=True),
    dict(ojo=(0.038, 0.012), punta=0.75, iris=(44, 30, 24), linea=1.2, ceja=1.2, boca=0.054, barba=True),
]

OJO_X, OJO_Z = 0.074, 1.392
CEJA_Z = 1.440
BOCA_Z = 1.292


def px(x, z):
    return ((0.5 + x / (2 * MEDIO_ANCHO)) * LADO * SS, (Z_ARRIBA - z) / (Z_ARRIBA - Z_ABAJO) * LADO * SS)


def w_px(m):
    return max(1, int(m / (2 * MEDIO_ANCHO) * LADO * SS))


def _curva(p0, p1, p2, n=18):
    return [
        ((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0], (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])
        for t in (i / n for i in range(n + 1))
    ]


def _trazo(d, puntos, grueso_ini, grueso_fin, color=NEGRO, grueso_medio=None):
    """Trazo que cambia de grosor (polígono): `puntos` en metros."""
    n = len(puntos)
    izq, der = [], []
    for i, (x, z) in enumerate(puntos):
        a = puntos[max(0, i - 1)]
        b = puntos[min(n - 1, i + 1)]
        tx, tz = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(tx, tz) or 1
        nx, nz = -tz / ln, tx / ln
        t = i / (n - 1)
        if grueso_medio is not None:
            g = grueso_ini + (grueso_medio - grueso_ini) * (t * 2) if t < 0.5 else grueso_medio + (grueso_fin - grueso_medio) * (t * 2 - 1)
        else:
            g = grueso_ini + (grueso_fin - grueso_ini) * t
        izq.append((x + nx * g / 2, z + nz * g / 2))
        der.append((x - nx * g / 2, z - nz * g / 2))
    d.polygon([px(*p) for p in izq + der[::-1]], fill=color)


def _recortado(img, contorno, dibujar):
    capa = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dibujar(ImageDraw.Draw(capa))
    mascara = Image.new("L", img.size, 0)
    ImageDraw.Draw(mascara).polygon(contorno, fill=255)
    vacia = Image.new("RGBA", img.size, (0, 0, 0, 0))
    img.alpha_composite(Image.composite(capa, vacia, mascara))


def ojo(img, d, lado, c, g):
    cx = lado * OJO_X
    w, h = c["ojo"][0] * 1.45, c["ojo"][1] * 1.6
    abre = g["abre"]
    punta = c["punta"] * h
    adentro = (cx - lado * w, OJO_Z - h * 0.25)
    afuera = (cx + lado * w, OJO_Z + punta * 0.6)
    enojo = g["enojo"] * h * 1.3
    if abre < 0.2:  # apretado: ">" grueso
        pts = [(cx + lado * w, OJO_Z + h * 1.0), (cx - lado * w * 0.5, OJO_Z), (cx + lado * w, OJO_Z - h * 0.8)]
        _trazo(d, [pts[0], pts[1], pts[2]], 0.006, 0.003, grueso_medio=0.007)
        return
    arriba_ctrl = (cx - lado * w * 0.15, OJO_Z + h * 1.6 * abre - enojo)
    abajo_ctrl = (cx + lado * w * 0.1, OJO_Z - h * 1.25 * min(1.0, abre) * (1 - g["mejilla"] * 0.6))
    arriba = _curva(adentro, arriba_ctrl, afuera)
    abajo = _curva(afuera, abajo_ctrl, adentro)
    contorno = [px(*p) for p in arriba + abajo]
    d.polygon(contorno, fill=(226, 229, 234, 255))

    def interior(di):
        # Sombra del párpado sobre el blanco.
        di.polygon([px(*p) for p in arriba] + [px(afuera[0], afuera[1] - h * 0.5), px(adentro[0], adentro[1] - h * 0.3)], fill=(150, 156, 168, 255))
        r = h * 1.35 * (g["pupila"] ** 0.25)
        ix, iz = cx - lado * w * 0.12, OJO_Z + g["mira"] + h * 0.15
        di.ellipse([px(ix - r, iz + r), px(ix + r, iz - r)], fill=(*c["iris"], 255))
        rp = r * 0.62 * g["pupila"]
        di.ellipse([px(ix - rp, iz + rp), px(ix + rp, iz - rp)], fill=(8, 8, 10, 255))
        rb = r * 0.24
        bx, bz = ix + lado * r * 0.35, iz + r * 0.35
        di.ellipse([px(bx - rb, bz + rb), px(bx + rb, bz - rb)], fill=(255, 255, 255, 240))

    _recortado(img, contorno, interior)
    k = c["linea"]
    # Delineado de arriba: grueso afuera, termina en punta pasando el rabillo.
    ala = (afuera[0] + lado * w * 0.25, afuera[1] + punta * 0.4 + h * 0.15)
    _trazo(d, arriba + [ala], 0.004 * k, 0.002, grueso_medio=0.010 * k)
    # Delineado de abajo: solo la mitad de afuera.
    _trazo(d, abajo[: len(abajo) // 2 + 2], 0.005 * k, 0.001)
    if c.get("pliegue"):
        _trazo(d, _curva((cx - lado * w * 0.5, OJO_Z + h * 1.6), (cx, OJO_Z + h * 2.3 * abre), (cx + lado * w * 0.8, OJO_Z + h * 1.6)), 0.0006, 0.0014, (60, 40, 36, 200))
    if c.get("pestanas"):
        for t in (0.7, 0.85):
            x0, z0 = arriba[int(t * (len(arriba) - 1))]
            _trazo(d, [(x0, z0), (x0 + lado * 0.006, z0 + 0.006)], 0.002, 0.0003)
    if c.get("ojeras") or g.get("ojeras"):
        _trazo(d, _curva((cx - lado * w * 0.6, OJO_Z - h * 1.7), (cx, OJO_Z - h * 2.6), (cx + lado * w * 0.7, OJO_Z - h * 1.5)), 0.0005, 0.0015, (90, 55, 50, 120))


def ceja(d, lado, c, g):
    cx = lado * (OJO_X + 0.004)
    largo = 0.058
    adentro = (cx - lado * largo * 0.85, CEJA_Z + g["ceja_in"] - 0.002)
    afuera = (cx + lado * largo, CEJA_Z + g["ceja_out"] + 0.004)
    medio = (cx + lado * 0.004, CEJA_Z + 0.007 + (g["ceja_in"] + g["ceja_out"]) * 0.5)
    _trazo(d, _curva(adentro, medio, afuera), 0.009 * c["ceja"], 0.0008, grueso_medio=0.006 * c["ceja"])
    if g["enojo"] > 0.3:  # sombra suave arriba del ojo
        _trazo(d, _curva((cx - lado * 0.025, CEJA_Z - 0.010), (cx, CEJA_Z - 0.004), (cx + lado * 0.02, CEJA_Z - 0.009)), 0.0015, 0.004, (120, 72, 52, 90))


def ceno(d, n):
    for k in range(n):
        for lado in (1, -1):
            x = lado * (0.016 + k * 0.004)
            _trazo(d, _curva((x, 1.418 - k * 0.003), (x - lado * 0.004, 1.410), (x, 1.400 + k * 0.002), 6), 0.0006, 0.0006, (40, 26, 22, 200))


def nariz(d):
    # Sombra de costado (la luz viene de la izquierda de la imagen) y brillo en la punta.
    d.polygon([px(-0.004, 1.395), px(-0.024, 1.334), px(-0.014, 1.326), px(0.006, 1.330)], fill=(140, 80, 50, 120))
    _trazo(d, [(-0.024, 1.334), (-0.012, 1.327), (0.004, 1.330)], 0.002, 0.001, (90, 50, 36, 180))
    _trazo(d, [(0.010, 1.352), (0.010, 1.338)], 0.0025, 0.002, (255, 250, 245, 220))


def boca(img, d, c, g):
    w = 1.35 * c["boca"] * (1 + 0.2 * max(0.0, g["sonrisa"]))
    s = g["sonrisa"] * 0.010
    izq, der = (-w / 2, BOCA_Z + s), (w / 2, BOCA_Z + s)
    labio = (95, 55, 40, 150)
    if g["boca"] < 0.1:
        _trazo(d, _curva(izq, (0, BOCA_Z - s * 0.8), der), 0.002, 0.002, grueso_medio=0.006)
        _trazo(d, _curva((-w * 0.22, BOCA_Z - 0.010 - s * 0.3), (0, BOCA_Z - 0.015 - s * 0.3), (w * 0.22, BOCA_Z - 0.010 - s * 0.3)), 0.001, 0.001, labio, grueso_medio=0.004)
        return
    alto = g["boca"] * 0.030
    if g["dientes"] == "redonda":
        r = w * 0.22
        d.ellipse([px(-r, BOCA_Z + alto * 0.3), px(r, BOCA_Z - alto * 0.9)], fill=(70, 20, 26, 255), outline=NEGRO, width=w_px(0.003))
        return
    arriba = _curva(izq, (0, BOCA_Z + alto * 0.1 - s * 0.6), der)
    abajo = _curva(der, (0, BOCA_Z - alto - s), izq)
    if g["dientes"] == "apretados":
        arriba = _curva(izq, (0, BOCA_Z + alto * 0.3), der)
        abajo = _curva(der, (0, BOCA_Z - alto * 0.5), izq)
    contorno = [px(*p) for p in arriba + abajo]
    d.polygon(contorno, fill=(70, 20, 26, 255))

    def dentro(di):
        if g["dientes"] == "arriba":
            di.polygon([px(*p) for p in arriba] + [px(der[0], der[1] - alto * 0.35), px(izq[0], izq[1] - alto * 0.35)], fill=(246, 244, 240, 255))
            di.ellipse([px(-w * 0.25, BOCA_Z - alto * 0.55), px(w * 0.25, BOCA_Z - alto * 1.4)], fill=(222, 112, 118, 255))
        elif g["dientes"] == "apretados":
            di.rectangle([px(-w, BOCA_Z + 0.02), px(w, BOCA_Z - 0.02)], fill=(240, 238, 232, 255))
            mz = BOCA_Z - alto * 0.1
            di.line([px(-w / 2, mz), px(w / 2, mz)], fill=(120, 110, 108, 255), width=w_px(0.0012))
            for k in range(-4, 5):
                x = k * w / 10
                di.line([px(x, mz + alto * 0.4), px(x, mz - alto * 0.4)], fill=(150, 140, 138, 255), width=w_px(0.0008))

    _recortado(img, contorno, dentro)
    d.line(contorno + [contorno[0]], fill=NEGRO, width=w_px(0.0025), joint="curve")
    _trazo(d, _curva((-w * 0.2, BOCA_Z - alto - s - 0.008), (0, BOCA_Z - alto - s - 0.012), (w * 0.2, BOCA_Z - alto - s - 0.008)), 0.001, 0.001, labio, grueso_medio=0.0035)


def extras(d, c):
    if c.get("pecas"):
        r = random.Random(7)
        for _ in range(30):
            x = r.choice((-1, 1)) * r.uniform(0.030, 0.095)
            z = r.uniform(1.335, 1.365)
            rr = r.uniform(0.0012, 0.0022)
            d.ellipse([px(x - rr, z + rr), px(x + rr, z - rr)], fill=(120, 62, 40, 120))
    if c.get("barba"):
        r = random.Random(11)
        for _ in range(900):
            a = r.uniform(0.15, math.pi - 0.15)
            rad = r.uniform(0.0, 0.025)
            x = -math.cos(a) * (0.12 - rad * 0.4)
            z = 1.300 - math.sin(a) * (0.085 - rad)
            if z > 1.29 and abs(x) < 0.04:
                continue
            rr = 0.0009
            d.ellipse([px(x - rr, z + rr), px(x + rr, z - rr)], fill=(40, 30, 28, 90))


def cara(n, gesto):
    img = Image.new("RGBA", (LADO * SS, LADO * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c, g = CARAS[n], GESTOS[gesto]
    extras(d, c)
    nariz(d)
    for lado in (1, -1):
        ojo(img, d, lado, c, g)
        ceja(d, lado, c, g)
    ceno(d, g["ceno"])
    boca(img, d, c, g)
    return img


def _cicatriz(d, puntos, ancho=0.004, puntadas=True):
    _trazo(d, puntos, ancho * 0.5, ancho * 0.5, (150, 70, 70, 210), grueso_medio=ancho)
    _trazo(d, puntos, ancho * 0.15, ancho * 0.15, (225, 160, 150, 200), grueso_medio=ancho * 0.35)
    if puntadas:
        for (x0, z0), (x1, z1) in zip(puntos, puntos[1:]):
            for t in (0.3, 0.7):
                x, z = x0 + (x1 - x0) * t, z0 + (z1 - z0) * t
                nx, nz = -(z1 - z0), x1 - x0
                ln = math.hypot(nx, nz) or 1
                nx, nz = nx / ln * 0.006, nz / ln * 0.006
                _trazo(d, [(x - nx, z - nz), (x + nx, z + nz)], 0.0014, 0.0014, (110, 50, 55, 220))


def marca(n):
    img = Image.new("RGBA", (LADO * SS, LADO * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if n == 0:  # cicatriz que cruza el ojo izquierdo (derecha de la imagen)
        _cicatriz(d, [(0.055, 1.455), (0.060, 1.420), (0.066, 1.380), (0.072, 1.345)])
    elif n == 1:  # tajo en la mejilla
        _cicatriz(d, [(-0.110, 1.360), (-0.090, 1.342), (-0.068, 1.330)], puntadas=False, ancho=0.005)
    elif n == 2:  # cruz en el puente de la nariz
        _cicatriz(d, [(-0.022, 1.378), (0.022, 1.366)], puntadas=False)
        _cicatriz(d, [(-0.020, 1.364), (0.020, 1.378)], puntadas=False)
    elif n == 3:  # quemadura en el costado
        r = random.Random(3)
        for _ in range(70):
            x, z = r.gauss(-0.110, 0.015), r.gauss(1.40, 0.030)
            rr = r.uniform(0.004, 0.011)
            d.ellipse([px(x - rr, z + rr), px(x + rr, z - rr)], fill=(170, 80, 70, 45))
    elif n == 4:  # dos rayas pintadas debajo de cada ojo
        for lado in (1, -1):
            for k in range(2):
                x0 = lado * (0.045 + k * 0.016)
                _trazo(d, [(x0, 1.368), (x0 + lado * 0.005, 1.335)], 0.006, 0.002, (25, 25, 34, 230))
    elif n == 5:  # tres cortes y un punto en la sien (diseño propio)
        for k in range(3):
            z = 1.430 - k * 0.014
            _trazo(d, [(-0.120, z), (-0.140, z - 0.007)], 0.004, 0.002, (30, 40, 60, 210))
        d.ellipse([px(-0.133, 1.392), px(-0.125, 1.384)], fill=(30, 40, 60, 210))
    return img


def guardar(img, ruta):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    img.resize((LADO, LADO), Image.LANCZOS).save(ruta)
    return ruta


def hoja(rutas, columnas, ruta, lado=512):
    filas = math.ceil(len(rutas) / columnas)
    total = Image.new("RGBA", (columnas * lado, filas * lado), (0, 0, 0, 0))
    for i, r in enumerate(rutas):
        total.paste(Image.open(r).resize((lado, lado), Image.LANCZOS), ((i % columnas) * lado, (i // columnas) * lado))
    total.save(ruta)


def main():
    carpeta = os.path.join(SALIDA, "caras")
    for n in range(len(CARAS)):
        for gesto in EXPRESIONES:
            guardar(cara(n, gesto), os.path.join(carpeta, f"cara_{n + 1:02d}_{gesto}.png"))
    hoja([os.path.join(carpeta, f"cara_{n + 1:02d}_neutral.png") for n in range(12)], 4, os.path.join(carpeta, "hoja_caras.png"))
    hoja([os.path.join(carpeta, f"cara_01_{g}.png") for g in EXPRESIONES], 4, os.path.join(carpeta, "hoja_expresiones.png"))
    for n in range(6):
        guardar(marca(n), os.path.join(SALIDA, "marcas", f"marca_{n + 1:02d}.png"))
    print("Listo:", carpeta)


if __name__ == "__main__":
    main()
