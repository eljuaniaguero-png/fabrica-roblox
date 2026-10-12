"""Base del estilo toon de Mutant Lab (ideas/estilo-toon.md), sin Blender.

Genera dos cosas:
1. El cielo: 4 imágenes PNG para el Sky de Roblox (arriba, abajo, costado y costado con la luna),
   con el degradé violeta a rosa y una luna grande de caricatura con contorno.
2. Las mallas del contorno por casco invertido: esfera, caja, cilindro y cuña con las caras
   dadas vuelta, en un solo OBJ para importar en Studio de una vez (shared/Toon.luau las usa).

Se corre con Python común (no necesita Blender ni paquetes):
    python mutant-lab/arte/scripts/toon_base.py

Los colores son los de shared/Paleta.luau (Paleta.Toon). Si cambian allá, cambiarlos acá y volver a
correrlo: las imágenes del cielo quedan con el color "horneado".
"""

import math
import os
import struct
import zlib

AQUI = os.path.dirname(os.path.abspath(__file__))
EXPORT = os.path.join(AQUI, "..", "export")

# Paleta.Toon (shared/Paleta.luau)
CONTORNO = "241A3A"
CIELO_ARRIBA = "3B3A9E"
CIELO_ABAJO = "7A4FB0"
HORIZONTE = "F2A3C7"
LUNA = "FFF1C9"  # crema amarillenta, un punto más clara que el crema durazno
CRATER = "F5D59A"
ESTRELLA = "FFF6D8"

# Degradé del cielo según la altura sobre el horizonte (grados): de abajo hacia arriba.
DEGRADE = [
    (-90, HORIZONTE),
    (2, HORIZONTE),
    (22, CIELO_ABAJO),
    (60, CIELO_ARRIBA),
    (90, CIELO_ARRIBA),
]

# Luna: dónde está en la cara "costado con luna" y qué tan grande se ve (grados).
LUNA_ALTURA = 24
LUNA_DIAMETRO = 20
LUNA_BORDE = 0.9  # grosor del contorno, en grados
CRATERES = [  # (x, y, radio) en unidades del radio de la luna, mirando la luna de frente
    (-0.35, 0.30, 0.22),
    (0.30, -0.25, 0.28),
    (0.42, 0.42, 0.12),
    (-0.20, -0.50, 0.12),
]
# Estrellitas de 4 puntas: (acimut en grados desde el centro de la cara, altura, tamaño en grados)
ESTRELLAS = [
    (-30, 52, 2.6),
    (28, 63, 2.0),
    (-12, 72, 1.6),
    (38, 40, 1.8),
    (-40, 34, 1.4),
]


def rgb(h: str):
    return tuple(int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))


def mezclar(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def suave(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


DEGRADE_RGB = [(g, rgb(h)) for g, h in DEGRADE]


def color_cielo(altura):
    for (g0, c0), (g1, c1) in zip(DEGRADE_RGB, DEGRADE_RGB[1:]):
        if altura <= g1:
            return mezclar(c0, c1, suave((altura - g0) / (g1 - g0)))
    return DEGRADE_RGB[-1][1]


def guardar_png(ruta, ancho, alto, pixeles):
    """pixeles: lista de filas, cada fila una lista de (r, g, b) entre 0 y 1."""
    crudo = bytearray()
    for fila in pixeles:
        crudo.append(0)
        for r, g, b in fila:
            crudo += bytes((round(r * 255), round(g * 255), round(b * 255)))

    def bloque(tipo, datos):
        c = struct.pack(">I", len(datos)) + tipo + datos
        return c + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += bloque(b"IHDR", struct.pack(">IIBBBBB", ancho, alto, 8, 2, 0, 0, 0))
    png += bloque(b"IDAT", zlib.compress(bytes(crudo), 9))
    png += bloque(b"IEND", b"")
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    with open(ruta, "wb") as f:
        f.write(png)


def normal(v):
    m = math.sqrt(sum(x * x for x in v))
    return tuple(x / m for x in v)


# Cada cara del cubo: dirección del centro, hacia la derecha y hacia arriba de la imagen.
# Las de costado tienen el "arriba" de la imagen hacia el cielo, así que sirven las cuatro iguales.
CARAS = {
    "Lado": ((0, 0, -1), (1, 0, 0), (0, 1, 0)),
    "Arriba": ((0, 1, 0), (1, 0, 0), (0, 0, 1)),
    "Abajo": ((0, -1, 0), (1, 0, 0), (0, 0, -1)),
}


def direccion(cara, u, v):
    """u y v entre -1 y 1 (v = 1 es el borde de arriba de la imagen)."""
    c, d, a = CARAS[cara]
    return normal(tuple(c[i] + d[i] * u + a[i] * v for i in range(3)))


def altura_de(d):
    return math.degrees(math.asin(max(-1.0, min(1.0, d[1]))))


def estrella(d, centro, tam):
    """Estrellita de 4 puntas: 0 afuera, 1 adentro."""
    c, x, y = centro
    pu = sum(d[i] * x[i] for i in range(3))
    pv = sum(d[i] * y[i] for i in range(3))
    if sum(d[i] * c[i] for i in range(3)) <= 0:
        return 0
    r = math.radians(tam)
    ax, ay = abs(pu) / r, abs(pv) / r
    # Astroide: |x|^0.5 + |y|^0.5 <= 1
    return 1 if math.sqrt(ax) + math.sqrt(ay) <= 1 else 0


def base_tangente(d):
    """Dos ejes perpendiculares a d para dibujar cosas redondas en el cielo."""
    arriba = (0, 1, 0)
    x = normal(
        (
            arriba[1] * d[2] - arriba[2] * d[1],
            arriba[2] * d[0] - arriba[0] * d[2],
            arriba[0] * d[1] - arriba[1] * d[0],
        )
    )
    y = (
        d[1] * x[2] - d[2] * x[1],
        d[2] * x[0] - d[0] * x[2],
        d[0] * x[1] - d[1] * x[0],
    )
    return x, y


def dir_desde(acimut, altura):
    a, h = math.radians(acimut), math.radians(altura)
    return normal((math.sin(a) * math.cos(h), math.sin(h), -math.cos(a) * math.cos(h)))


def color_en(d, con_luna):
    col = color_cielo(altura_de(d))
    for acimut, alt, tam in ESTRELLAS:
        c = dir_desde(acimut, alt)
        x, y = base_tangente(c)
        if estrella(d, (c, x, y), tam):
            col = rgb(ESTRELLA)
    if not con_luna:
        return col
    c = dir_desde(0, LUNA_ALTURA)
    ang = math.degrees(math.acos(max(-1.0, min(1.0, sum(d[i] * c[i] for i in range(3))))))
    radio = LUNA_DIAMETRO / 2
    if ang > radio:
        return col
    if ang > radio - LUNA_BORDE:
        return rgb(CONTORNO)
    x, y = base_tangente(c)
    r = math.tan(math.radians(radio))
    pu = sum(d[i] * x[i] for i in range(3)) / r
    pv = sum(d[i] * y[i] for i in range(3)) / r
    luna = rgb(LUNA)
    borde_crater = LUNA_BORDE / radio * 0.7
    for cx, cy, cr in CRATERES:
        dist = math.hypot(pu - cx, pv - cy)
        if dist <= cr:
            return rgb(CRATER) if dist <= cr - borde_crater else rgb(CONTORNO)
    # Sombra de un solo escalón abajo a la derecha (estilo dibujo animado).
    if math.hypot(pu + 0.18, pv - 0.18) > 1.0:
        return mezclar(luna, rgb(CRATER), 0.6)
    return luna


def cara(nombre, tam, con_luna=False, muestras=1):
    filas = []
    for j in range(tam):
        fila = []
        for i in range(tam):
            acum = [0.0, 0.0, 0.0]
            for sj in range(muestras):
                for si in range(muestras):
                    u = ((i + (si + 0.5) / muestras) / tam) * 2 - 1
                    v = 1 - ((j + (sj + 0.5) / muestras) / tam) * 2
                    c = color_en(direccion(nombre, u, v), con_luna)
                    for k in range(3):
                        acum[k] += c[k]
            n = muestras * muestras
            fila.append(tuple(x / n for x in acum))
        filas.append(fila)
    return filas


def cielo():
    carpeta = os.path.join(EXPORT, "Cielo")
    guardar_png(os.path.join(carpeta, "CieloArriba.png"), 256, 256, cara("Arriba", 256))
    guardar_png(os.path.join(carpeta, "CieloAbajo.png"), 64, 64, cara("Abajo", 64))
    guardar_png(os.path.join(carpeta, "CieloLado.png"), 512, 512, cara("Lado", 512, muestras=2))
    guardar_png(
        os.path.join(carpeta, "CieloLuna.png"), 1024, 1024, cara("Lado", 1024, True, muestras=2)
    )


# --- Mallas del contorno (casco invertido) ---
# Todas miden 1 x 1 x 1 alrededor del origen, como una Part de Roblox de tamaño 1.
# Las caras van en el orden contrario al normal y las normales miran hacia adentro: así Roblox
# dibuja solo la parte de atrás del casco y se ve como un borde alrededor de la pieza.


def esfera(seg=16, anillos=12):
    vs, caras = [], []
    for i in range(anillos + 1):
        t = math.pi * i / anillos
        for j in range(seg):
            p = 2 * math.pi * j / seg
            vs.append((0.5 * math.sin(t) * math.cos(p), 0.5 * math.cos(t), 0.5 * math.sin(t) * math.sin(p)))
    for i in range(anillos):
        for j in range(seg):
            a, b = i * seg + j, i * seg + (j + 1) % seg
            c, d = (i + 1) * seg + j, (i + 1) * seg + (j + 1) % seg
            if i > 0:  # en los polos ese triángulo no tiene superficie
                caras.append((a, c, b))
            if i < anillos - 1:
                caras.append((b, c, d))
    return vs, caras


def caja():
    vs = [(x, y, z) for x in (-0.5, 0.5) for y in (-0.5, 0.5) for z in (-0.5, 0.5)]
    idx = {v: i for i, v in enumerate(vs)}

    def q(a, b, c, d):
        return [(idx[a], idx[b], idx[c]), (idx[a], idx[c], idx[d])]

    h = 0.5
    caras = []
    # Cada cara en orden antihorario visto desde afuera; después se da vuelta todo junto.
    caras += q((h, -h, -h), (h, h, -h), (h, h, h), (h, -h, h))
    caras += q((-h, -h, h), (-h, h, h), (-h, h, -h), (-h, -h, -h))
    caras += q((-h, h, -h), (-h, h, h), (h, h, h), (h, h, -h))
    caras += q((-h, -h, h), (-h, -h, -h), (h, -h, -h), (h, -h, h))
    caras += q((-h, -h, h), (h, -h, h), (h, h, h), (-h, h, h))
    caras += q((h, -h, -h), (-h, -h, -h), (-h, h, -h), (h, h, -h))
    return vs, [(a, c, b) for a, b, c in caras]


def cilindro(seg=24):
    # Eje en X, como la Part cilíndrica de Roblox.
    vs = []
    for x in (-0.5, 0.5):
        for j in range(seg):
            p = 2 * math.pi * j / seg
            vs.append((x, 0.5 * math.cos(p), 0.5 * math.sin(p)))
    vs += [(-0.5, 0, 0), (0.5, 0, 0)]
    c0, c1 = 2 * seg, 2 * seg + 1
    caras = []
    for j in range(seg):
        a, b = j, (j + 1) % seg
        c, d = seg + j, seg + (j + 1) % seg
        caras += [(a, c, b), (b, c, d)]  # costado (ya invertido)
        caras.append((c0, a, b))  # tapa izquierda (ya invertida)
        caras.append((c1, d, c))  # tapa derecha (ya invertida)
    return vs, caras


def cunia():
    # Como la WedgePart de Roblox: alta atrás (+Z), baja adelante (-Z).
    h = 0.5
    vs = [(-h, -h, -h), (h, -h, -h), (h, -h, h), (-h, -h, h), (-h, h, h), (h, h, h)]
    caras = [
        (0, 1, 2), (0, 2, 3),  # piso
        (3, 2, 5), (3, 5, 4),  # atrás
        (0, 4, 5), (0, 5, 1),  # rampa
        (0, 3, 4),  # costado izquierdo
        (1, 5, 2),  # costado derecho
    ]
    # Verificar el sentido con la normal hacia afuera y dar vuelta al final.
    centro = (0, -0.1667, 0.1667)
    buenas = []
    for a, b, c in caras:
        pa, pb, pc = vs[a], vs[b], vs[c]
        u = [pb[i] - pa[i] for i in range(3)]
        w = [pc[i] - pa[i] for i in range(3)]
        n = (u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2], u[0] * w[1] - u[1] * w[0])
        afuera = [pa[i] - centro[i] for i in range(3)]
        if sum(n[i] * afuera[i] for i in range(3)) < 0:
            a, b, c = a, c, b
        buenas.append((a, c, b))  # invertida
    return vs, buenas


def verificar_invertida(vs, caras, nombre):
    """Todas las normales tienen que mirar hacia el centro."""
    cx = sum(v[0] for v in vs) / len(vs)
    cy = sum(v[1] for v in vs) / len(vs)
    cz = sum(v[2] for v in vs) / len(vs)
    for a, b, c in caras:
        pa, pb, pc = vs[a], vs[b], vs[c]
        u = [pb[i] - pa[i] for i in range(3)]
        w = [pc[i] - pa[i] for i in range(3)]
        n = (u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2], u[0] * w[1] - u[1] * w[0])
        m = ((pa[0] + pb[0] + pc[0]) / 3 - cx, (pa[1] + pb[1] + pc[1]) / 3 - cy, (pa[2] + pb[2] + pc[2]) / 3 - cz)
        if sum(n[i] * m[i] for i in range(3)) > 1e-9:
            raise SystemExit(f"{nombre}: hay una cara mirando hacia afuera")


def cascos():
    mallas = {
        "CascoEsfera": esfera(),
        "CascoCaja": caja(),
        "CascoCilindro": cilindro(),
        "CascoCunia": cunia(),
    }
    lineas = ["# Mallas de contorno de Mutant Lab (casco invertido). Generado por toon_base.py"]
    base = 0
    for nombre, (vs, caras) in mallas.items():
        verificar_invertida(vs, caras, nombre)
        lineas.append(f"o {nombre}")
        for v in vs:
            lineas.append("v %.5f %.5f %.5f" % v)
        for a, b, c in caras:
            lineas.append(f"f {a + 1 + base} {b + 1 + base} {c + 1 + base}")
        base += len(vs)
    carpeta = os.path.join(EXPORT, "Toon")
    os.makedirs(carpeta, exist_ok=True)
    with open(os.path.join(carpeta, "_PaqueteToon.obj"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lineas) + "\n")


def rugoso():
    """Textura blanca para el RoughnessMap del material Toon: plástico sin brillo."""
    guardar_png(os.path.join(EXPORT, "Toon", "Rugoso.png"), 8, 8, [[(1, 1, 1)] * 8] * 8)


if __name__ == "__main__":
    cascos()
    rugoso()
    cielo()
    print("Listo: export/Cielo y export/Toon/_PaqueteToon.obj")
