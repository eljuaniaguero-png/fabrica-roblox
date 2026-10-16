"""Rocas terminadas: cinco geodas por bioma, más las especiales (Oculta, Prismática y Renacida).

Cada roca tiene su forma, sus cristales y sus colores (los de GameConfig, Zonas[n].Variantes: el
juego las pinta con esos colores, un color por malla). Estilo de arte/referencias/geodas-gemini.jpg:
cubitos lisos o caras planas, y un nido de ramitas.
  1 Pradera de Cuarzo   Cuarzo (anillos y amatistas), Musgosa, Caliza, Esmeralda, Cuarzo Rosa
  2 Dunas de Ámbar      Ámbar (capas y gotas), Arenisca Roja, Desértica, Topacio, Fósil
  3 Glaciar de Zafiro   Zafiro (hielo facetado), Escarcha, Glaciar Profundo, Iceberg, Aurora
  4 Volcán de Rubí      Rubí (columnas y lava), Obsidiana, Azufre, Magma, Ceniza
  5 Abismo Estelar      Estelar (abertura y estrellas), Nebulosa, Meteorito, Cometa, Eclipse
  Oculta     huevo con una veta brillante alrededor (el mineral secreto)
  Prisma     prisma alto con esquirlas de colores
  Renacida   roca dorada con corona y alas de fénix (la del Santuario del Renacer)

Exporta un FBX por bioma (arte/fbx/Geodas_Zona<N>.fbx): la roca 1 en Pequena, Mediana, Gigante y
Jefe, y las otras en Pequena_2, Mediana_2, Gigante_2... hasta _5 (sin Jefe). Las especiales van
en Geodas_Especiales.fbx (Oculta, Prisma, Renacida). Cada tamaño tiene las mallas Roca,
Cristales, Base, Grietas y Grietas2 (las que pinta ModeloGeoda.luau). Render de muestra:
arte/renders/geodas_biomas.jpg (las 25 y las especiales).

Uso: <python de Blender> forja-rapida/arte/scripts/rocas.py   (--solo-render: sin exportar;
--nuevas: tabla de triángulos de las 25 rocas y render de las rocas 1 al lado de la imagen de
Gemini; --biomas: exporta Geodas_Zona1..5 sin tocar las especiales)
"""

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001  (bpy antes que modelos, que usa bmesh)
import bmesh  # noqa: E402
import modelos as M  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402
from mathutils.bvhtree import BVHTree  # noqa: E402

# Las 5 rocas de cada bioma (ver "rocas 1 nuevas" y "rocas 2 a 5" más abajo). Los colores son
# los de GameConfig (Zonas[n].Variantes), que es con los que el juego las pinta.
ESTILOS = {
    1: [
        {"nombre": "Cuarzo", "forma": "anillos", "roca": "#6E7487", "cris": "#C77DFF"},
        {"nombre": "Musgosa", "forma": "musgosa", "roca": "#5E8C4A", "cris": "#FF8FD8"},
        {"nombre": "Caliza", "forma": "caliza", "roca": "#D8D2C0", "cris": "#7CF5FF"},
        {"nombre": "Esmeralda", "forma": "esmeralda", "roca": "#8A8F7A", "cris": "#2EE88A"},
        {"nombre": "Cuarzo Rosa", "forma": "cuarzo_rosa", "roca": "#C9B8C4", "cris": "#FF7BB0"},
    ],
    2: [
        {"nombre": "Ámbar", "forma": "capas_ambar", "roca": "#B07A4A", "cris": "#FFB627"},
        {"nombre": "Arenisca Roja", "forma": "arenisca", "roca": "#C4553A", "cris": "#FFE14D"},
        {"nombre": "Desértica", "forma": "desertica", "roca": "#E8C98A", "cris": "#FF8C42"},
        {"nombre": "Topacio", "forma": "topacio", "roca": "#9A6B3F", "cris": "#FFD27A"},
        {"nombre": "Fósil", "forma": "fosil", "roca": "#8C7B6B", "cris": "#FF6A2B"},
    ],
    3: [
        {"nombre": "Zafiro", "forma": "hielo", "roca": "#7FA6C9", "cris": "#3D7BFF"},
        {"nombre": "Escarcha", "forma": "escarcha", "roca": "#E8F4FF", "cris": "#7CF5FF"},
        {"nombre": "Glaciar Profundo", "forma": "profundo", "roca": "#2F5D8A", "cris": "#B8F3FF"},
        {"nombre": "Iceberg", "forma": "iceberg", "roca": "#5FB8D6", "cris": "#E0FFFF"},
        {"nombre": "Aurora", "forma": "aurora", "roca": "#3B4A7A", "cris": "#7CFFB2"},
    ],
    4: [
        {"nombre": "Rubí", "forma": "basalto", "roca": "#4A3338", "cris": "#FF2E4D"},
        {"nombre": "Obsidiana", "forma": "obsidiana", "roca": "#1E1A24", "cris": "#FF7A00"},
        {"nombre": "Azufre", "forma": "azufre", "roca": "#6B5A2E", "cris": "#F5FF4D"},
        {"nombre": "Magma", "forma": "magma", "roca": "#7A2E1E", "cris": "#FFB000"},
        {"nombre": "Ceniza", "forma": "ceniza", "roca": "#8E8A86", "cris": "#FF4D1A"},
    ],
    5: [
        {"nombre": "Estelar", "forma": "abertura", "roca": "#2E2A5C", "cris": "#7CF5FF"},
        {"nombre": "Nebulosa", "forma": "nebulosa", "roca": "#4B2A6B", "cris": "#FF6FD8"},
        {"nombre": "Meteorito", "forma": "meteorito_nuevo", "roca": "#3B3B3B", "cris": "#FFB347"},
        {"nombre": "Cometa", "forma": "cometa", "roca": "#5A6B9C", "cris": "#B8FFFF"},
        {"nombre": "Eclipse", "forma": "eclipse", "roca": "#14121F", "cris": "#FFE07A"},
    ],
}
ESPECIALES = {
    "Oculta": {"forma": "huevo", "cristal": "veta", "roca": "#3A3F66", "cris": "#CFE8FF", "tam": "Mediana", "escala": 1.07},
    "Prisma": {"forma": "prisma", "cristal": "esquirlas", "roca": "#F2F7FF", "cris": "#9CFBFF", "tam": "Gigante", "escala": 0.83},
    "Renacida": {"forma": "corona", "cristal": "fenix", "roca": "#E8A317", "cris": "#FF6A3D", "tam": "Gigante", "escala": 1.0},
}


def datos_especial(est):
    """Tamaño de una especial: el de su molde por "escala", para que mida lo mismo que en el juego
    (Tamanos.Oculta.Escala 1,6, Prisma 1,9 y Renacida 2,3 de GameConfig, sobre la Pequeña de
    3 studs)."""
    datos = dict(M.GEODAS[est["tam"]])
    datos["diametro"] *= est["escala"]
    return datos


def nombre_tamano(tam, variante):
    """Pequena, Pequena_2, Pequena_3... (la variante 1 no lleva número)."""
    return tam if variante == 1 else f"{tam}_{variante}"


def semilla_de(datos, zona, variante):
    # la variante 1 usa la misma semilla de siempre, así no cambia
    return datos["semilla"] + zona * 101 + (variante - 1) * 37


def apoyar(celdas):
    zmin = min(c[2] for c in celdas)
    return {(x, y, z - zmin) for x, y, z in celdas}


# --- ayudas de vóxeles ------------------------------------------------------------------------
# Las celdas son (x, y, z) enteros, con z para arriba; la celda x va de x a x + 1.


def elipsoide(rx, ry, rz, semilla, bultos=0.18, corte=0.6, escala=0.35):
    """Elipsoide con bultos (ruido), centrado en 0 y cortado abajo en -rz * corte."""
    celdas = set()
    for x in range(-int(rx) - 2, int(rx) + 3):
        for y in range(-int(ry) - 2, int(ry) + 3):
            for z in range(-int(rz) - 2, int(rz) + 3):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                d = (cx / rx) ** 2 + (cy / ry) ** 2 + (cz / rz) ** 2
                d += bultos * M.ruido(cx, cy, cz, escala, semilla)
                if d <= 1 and cz > -rz * corte:
                    celdas.add((x, y, z))
    return celdas


def bola(cx, cy, cz, radio):
    """Celdas dentro de una esfera (centro en unidades de celda)."""
    celdas = set()
    for x in range(math.floor(cx - radio) - 1, math.ceil(cx + radio) + 1):
        for y in range(math.floor(cy - radio) - 1, math.ceil(cy + radio) + 1):
            for z in range(math.floor(cz - radio) - 1, math.ceil(cz + radio) + 1):
                if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 + (z + 0.5 - cz) ** 2 <= radio * radio:
                    celdas.add((x, y, z))
    return celdas


def techo(celdas):
    """Altura de la celda más alta de cada columna (x, y)."""
    alto = {}
    for x, y, z in celdas:
        alto[(x, y)] = max(alto.get((x, y), -1), z)
    return alto


def expuestas(celdas, ejes=M.EJES[:5]):
    """Caras que dan afuera (celda, dirección), sin las de abajo. Ordenadas (siempre igual)."""
    return sorted((c, d) for c in celdas for d in ejes if M._suma(c, d) not in celdas)


# --- formas de roca ---------------------------------------------------------------------------
# Cada forma devuelve las celdas apoyadas en z = 0. En `info` deja lo que necesitan sus
# cristales (dónde está el hueco, el cráter, los hoyos...).


def f_huevo(r, rng, semilla, info):
    return M.celdas_roca(r, semilla)


def f_prisma(r, rng, semilla, info):
    celdas = set()
    rz = r * 1.8
    for x in range(-r - 1, r + 2):
        for y in range(-r - 1, r + 2):
            for z in range(int(rz)):
                hexa = max(abs(x + 0.5), (abs(x + 0.5) * 0.5 + abs(y + 0.5) * 0.87))
                punta = 1 - max(0, (z - rz * 0.7) / (rz * 0.3)) * 0.6
                if hexa <= r * 0.85 * punta:
                    celdas.add((x, y, z))
    return apoyar(celdas)


def f_capas(r, rng, semilla, info):
    # lajas apiladas: cada una más chica y un poco corrida; la cara de abajo de cada laja se mete
    # un cubito, así se ve la junta entre una y otra
    celdas = set()
    n = 5
    total = 2 * r
    alturas = [total // n + (1 if i < total % n else 0) for i in range(n)]
    ox = oy = 0.0
    z = 0
    for i, grosor in enumerate(alturas):
        radio = r * (1.18 - 0.15 * i)
        rx, ry = radio * rng.uniform(0.92, 1.08), radio * rng.uniform(0.82, 0.98)
        ox += rng.uniform(-0.7, 0.7)
        oy += rng.uniform(-0.7, 0.7)
        for k in range(grosor):
            achique = 0.84 if k == 0 and i > 0 else 1.0
            for x in range(-int(rx) - 3, int(rx) + 4):
                for y in range(-int(ry) - 3, int(ry) + 4):
                    cx, cy = x + 0.5 - ox, y + 0.5 - oy
                    d = (abs(cx) / (rx * achique)) ** 2.6 + (abs(cy) / (ry * achique)) ** 2.6
                    if d + 0.12 * M.ruido(x, y, z + k, 0.5, semilla) <= 1:
                        celdas.add((x, y, z + k))
        z += grosor
    return celdas


def f_meseta(r, rng, semilla, info):
    # meseta del desierto: paredes rectas en tres escalones, rayas de capas y arriba plana
    alto = round(r * 1.5)
    celdas = set()
    for z in range(alto):
        t = z / alto
        esc = 1.12 if t < 0.3 else (0.9 if t < 0.68 else 0.68)
        if z % 3 == 2:
            esc -= 0.07  # la raya de cada capa
        rx, ry = r * esc, r * 0.86 * esc
        for x in range(-r - 3, r + 4):
            for y in range(-r - 3, r + 4):
                cx, cy = x + 0.5, y + 0.5
                d = (abs(cx) / rx) ** 3 + (abs(cy) / ry) ** 3 + 0.22 * M.ruido(cx, cy, z, 0.4, semilla)
                if d <= 1:
                    celdas.add((x, y, z))
    return celdas


def f_crater(r, rng, semilla, info):
    # roca ancha con un cráter arriba (ahí adentro crecen los cristales)
    celdas = apoyar(elipsoide(r * 1.12, r * 1.05, r * 0.8, semilla, bultos=0.2, corte=0.55))
    zmax = max(c[2] for c in celdas)
    cz, radio = zmax + 1 + r * 0.1, r * 0.74
    celdas = {c for c in celdas if (c[0] + 0.5) ** 2 + (c[1] + 0.5) ** 2 + (c[2] + 0.5 - cz) ** 2 > radio**2}
    info["crater"] = radio
    return celdas


def f_planeta(r, rng, semilla, info):
    # una bola casi perfecta, como un planeta (el anillo son los cristales)
    radio = r * 0.86
    celdas = elipsoide(radio, radio, radio, semilla, bultos=0.1, corte=0.9)
    zmin = min(c[2] for c in celdas)
    info["centro"] = (0.0, 0.0, float(-zmin))
    info["radio"] = radio
    return apoyar(celdas)


def f_meteorito(r, rng, semilla, info):
    # roca áspera con hoyos redondos (en el fondo de cada hoyo brilla un núcleo)
    celdas = elipsoide(r * 1.05, r * 0.95, r * 0.86, semilla, bultos=0.3, corte=0.6, escala=0.5)
    zmin = min(c[2] for c in celdas)
    celdas = apoyar(celdas)
    centro = (0.0, 0.0, -zmin)
    zmax = max(c[2] for c in celdas)
    lugares = [c for c, d in expuestas(celdas) if c[2] >= zmax * 0.3]
    rng.shuffle(lugares)
    hoyos = []
    for c in lugares:
        if len(hoyos) >= 5:
            break
        if all(math.dist(c, h[:3]) > r * 0.75 for h in hoyos):
            p = (c[0] + 0.5, c[1] + 0.5, c[2] + 0.5)
            n = [p[i] - centro[i] for i in range(3)]
            largo = math.hypot(*n) or 1
            n = [v / largo for v in n]
            radio = r * rng.uniform(0.26, 0.36)
            hoyos.append((*[p[i] + n[i] * radio * 0.3 for i in range(3)], *n, radio))
    for hx, hy, hz, *_, radio in hoyos:
        celdas -= bola(hx, hy, hz, radio)
    info["hoyos"] = hoyos
    return celdas


def f_corona(r, rng, semilla, info):
    # roca alta y plana arriba, con un borde (ahí va la corona) y un cinturón que sobresale
    celdas = apoyar(elipsoide(r * 0.95, r * 0.95, r * 1.1, semilla, bultos=0.12, corte=0.7))
    zmax = max(c[2] for c in celdas)
    tope = int(zmax * 0.86)
    celdas = {c for c in celdas if c[2] <= tope and not (c[2] == tope and math.hypot(c[0] + 0.5, c[1] + 0.5) < r * 0.42)}
    medio = tope // 2
    capa = {(x, y) for x, y, z in celdas if z == medio}
    for x, y in sorted(capa):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if (x + dx, y + dy) not in capa:
                celdas.add((x + dx, y + dy, medio))
                celdas.add((x + dx, y + dy, medio + 1))
    borde = max(math.hypot(x + 0.5, y + 0.5) for x, y, z in celdas if z == tope)
    info["tope"], info["borde"] = tope, borde
    info["ancho"] = max(abs(x + 0.5) for x, y, z in celdas if abs(z - tope * 0.6) < 1)
    return celdas


FORMAS = {
    "huevo": f_huevo,
    "prisma": f_prisma,
    "capas": f_capas,
    "meseta": f_meseta,
    "crater": f_crater,
    "planeta": f_planeta,
    "meteorito": f_meteorito,
    "corona": f_corona,
}


def forma(nombre, r, semilla, info=None):
    rng = random.Random(semilla)
    return FORMAS[nombre](r, rng, semilla, {} if info is None else info)


# --- cristales (en la grilla el doble de fina) -------------------------------------------------
# La celda de roca (x, y, z) ocupa las celdas finas 2x..2x+1 (lo mismo en y y en z).


def arriba(roca, rng, cantidad, minimo=0.62, separacion=3):
    alto = techo(roca)
    zmax = max(alto.values())
    lugares = [(xy, z) for xy, z in alto.items() if z >= zmax * minimo]
    rng.shuffle(lugares)
    elegidos = []
    for xy, z in lugares:
        if all(abs(xy[0] - e[0][0]) + abs(xy[1] - e[0][1]) >= separacion for e in elegidos):
            elegidos.append((xy, z))
        if len(elegidos) >= cantidad:
            break
    return elegidos, zmax


def c_esquirlas(roca, cantidad, rng, semilla, info):
    celdas = set()
    for i, ((x, y), z) in enumerate(arriba(roca, rng, cantidad + 2, 0.5, 2)[0]):
        bx, by, bz = x * 2, y * 2, z * 2 + 1
        h = rng.randint(8, 12) + (3 if i == 0 else 0)
        incl = (math.copysign(1, x) if x else rng.choice([-1, 1]), math.copysign(1, y) if y else 0)
        for k in range(h):
            ox, oy = bx + int(incl[0]) * (k // 2), by + int(incl[1]) * (k // 2)
            grosor = 2 if k < 3 else 1
            for dx in range(grosor):
                for dy in range(grosor):
                    celdas.add((ox + dx, oy + dy, bz + k))
    return celdas


def c_veta(roca, cantidad, rng, semilla, info):
    # una banda que asoma alrededor de la roca a media altura, y unas puntitas
    celdas = set()
    zmax = max(c[2] for c in roca)
    medio = int(zmax * 0.5)
    for x, y, z in roca:
        if z in (medio, medio + 1):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + dx, y + dy, z) not in roca:
                    fx, fy = (x + dx) * 2, (y + dy) * 2
                    for a in range(2):
                        for b in range(2):
                            for c in range(2):
                                celdas.add((fx + a - dx, fy + b - dy, z * 2 + c))
    celdas |= M.celdas_cristales(roca, 2, semilla)
    return celdas


def c_fenix(roca, cantidad, rng, semilla, info):
    # corona de puntas altas y bajas alrededor del borde, un cristal grande al centro y dos alas
    celdas = set()
    tope, borde = info["tope"], info["borde"] * 2
    bz = tope * 2 + 1
    n = 10
    for i in range(n):
        a = i / n * math.tau
        px, py = math.cos(a) * (borde - 2), math.sin(a) * (borde - 2)
        h = 13 if i % 2 == 0 else 8
        for k in range(h):
            g = 2 if k < h - 3 else 1
            ox = math.floor(px + math.cos(a) * (k // 4))
            oy = math.floor(py + math.sin(a) * (k // 4))
            for dx in range(-(g // 2), g - g // 2):
                for dy in range(-(g // 2), g - g // 2):
                    celdas.add((ox + dx, oy + dy, bz + k))
    for k in range(17):
        g = 4 if k < 10 else (2 if k < 15 else 1)
        for dx in range(-(g // 2), g - g // 2):
            for dy in range(-(g // 2), g - g // 2):
                celdas.add((dx, dy, bz - 2 + k))
    # alas: plumas que salen de los costados (±X), abiertas como un abanico hacia arriba
    zala = round(tope * 2 * 0.62)
    xala = info["ancho"] * 2 - 1
    for lado in (1, -1):
        for j, (ang, largo) in enumerate(((8, 9), (28, 12), (48, 13), (68, 11))):
            a = math.radians(ang)
            s = 0.0
            while s <= largo:
                px = lado * (xala + math.cos(a) * s)
                pz = zala + math.sin(a) * s
                ancho = 2 if s < largo - 3 else 1
                for dy in range(-1, ancho - 1):
                    celdas.add((math.floor(px), dy, math.floor(pz)))
                    celdas.add((math.floor(px), dy, math.floor(pz) + 1))
                s += 0.5
    return celdas


CRISTALES = {
    "esquirlas": c_esquirlas,
    "veta": c_veta,
    "fenix": c_fenix,
}


def cristales(nombre, roca, cantidad, semilla, info=None):
    rng = random.Random(semilla)
    return CRISTALES[nombre](roca, cantidad, rng, semilla, {} if info is None else info)


# --- rocas 1 nuevas (16/10/2026) -------------------------------------------------------------
# Copiadas de arte/referencias/geodas-gemini.jpg. Van sin la ranura de cada cubito y con piezas
# facetadas (cascos convexos), así la Mediana queda debajo de 4.000 triángulos y el Jefe de
# 20.000. Medidas en metros: W es el ancho de la roca (el diámetro del tamaño), z0 donde se apoya
# la roca adentro del nido. El frente es -Y (de ahí mira la cámara del render).


def casco(bm, puntos):
    """Agrega a bm el casco convexo de los puntos: una pieza facetada."""
    tmp = bmesh.new()
    vs = [tmp.verts.new(p) for p in puntos]
    res = bmesh.ops.convex_hull(tmp, input=vs)
    sobra = {v for v in res["geom_interior"] + res["geom_unused"] if isinstance(v, bmesh.types.BMVert)}
    if sobra:
        bmesh.ops.delete(tmp, geom=list(sobra), context="VERTS")
    malla = bpy.data.meshes.new("tmp")
    tmp.to_mesh(malla)
    tmp.free()
    bm.from_mesh(malla)  # se suma a lo que ya tenía bm
    bpy.data.meshes.remove(malla)


def punta(base, direccion, radio, largo, lados=6, giro=0.0, hombro=0.72):
    """Cristal: prisma de `lados` lados que sale de `base` hacia `direccion` y termina en punta
    (arranca un poco metido en la roca)."""
    d = Vector(direccion).normalized()
    a = d.orthogonal().normalized()
    b = d.cross(a)
    base = Vector(base)
    pts = [base + d * largo]
    for i in range(lados):
        t = giro + i / lados * math.tau
        r = (a * math.cos(t) + b * math.sin(t)) * radio
        pts.append(base - d * radio * 0.6 + r)
        pts.append(base + d * largo * hombro + r * 0.92)
    return pts


def caja(centro, ejes, medios):
    c = Vector(centro)
    return [
        c + ejes[0] * medios[0] * sx + ejes[1] * medios[1] * sy + ejes[2] * medios[2] * sz
        for sx in (-1, 1)
        for sy in (-1, 1)
        for sz in (-1, 1)
    ]


def gema(bm, x, y, z, radio, giro):
    """Gema facetada apoyada en (x, y, z): corona de 6 lados con mesa arriba."""
    pts = [Vector((x, y, z - radio * 0.2)), Vector((x, y, z + radio * 1.5))]
    for i in range(6):
        a = giro + i / 6 * math.tau
        pts.append(Vector((x + math.cos(a) * radio * 0.8, y + math.sin(a) * radio * 0.8, z + radio * 0.35)))
        b = a + math.pi / 6
        pts.append(Vector((x + math.cos(b) * radio, y + math.sin(b) * radio, z + radio * 0.85)))
    casco(bm, pts)


def estrella(bm, c, t):
    """Estrellita de 4 puntas que mira al frente: dos rombos finitos cruzados."""
    c = Vector(c)
    g, f = t * 0.2, t * 0.12
    casco(bm, [c + Vector(v) for v in ((0, 0, t), (0, 0, -t), (g, 0, 0), (-g, 0, 0), (0, f, 0), (0, -f, 0))])
    casco(bm, [c + Vector(v) for v in ((t, 0, 0), (-t, 0, 0), (0, 0, g), (0, 0, -g), (0, f, 0), (0, -f, 0))])


def nido(W, semilla):
    """Nido de pájaro: tres vueltas de ramitas cruzadas, bajito y más ancho que la roca."""
    rng = random.Random(semilla + 5)
    bm = bmesh.new()
    vueltas = ((0.5, 0.03, 16), (0.56, 0.075, 18), (0.53, 0.125, 18), (0.48, 0.17, 16))
    for capa, (radio, z, n) in enumerate(vueltas):
        for i in range(n):
            a = (i + rng.uniform(-0.25, 0.25) + capa * 0.5) / n * math.tau
            cruce = math.radians(rng.uniform(14, 26)) * (1 if (i + capa) % 2 else -1)
            rumbo = a + math.pi / 2 + cruce  # tangente al anillo, girada para que se crucen
            d = Vector((math.cos(rumbo), math.sin(rumbo), rng.uniform(-0.25, 0.25))).normalized()
            costado = Vector((0, 0, 1)).cross(d).normalized()
            arriba = d.cross(costado)
            r = W * (radio + rng.uniform(-0.02, 0.02))
            centro = (math.cos(a) * r, math.sin(a) * r, W * z)
            grueso = W * rng.uniform(0.024, 0.032)
            casco(bm, caja(centro, (d, costado, arriba), (W * rng.uniform(0.15, 0.19), grueso, grueso)))
    return bm


def sobre(alto, lado, z0, x, y):
    """Altura en metros de la cara de arriba de la roca de vóxeles en el punto (x, y)."""
    z = alto.get((math.floor(x / lado), math.floor(y / lado)))
    return None if z is None else z0 + (z + 1) * lado


def borde(celdas, a, z):
    """Hasta dónde llega la roca (en celdas, desde el eje) yendo en el ángulo a a la altura z."""
    ultimo, s = 0.0, 0.0
    while s < 40:
        if (math.floor(math.cos(a) * s), math.floor(math.sin(a) * s), z) in celdas:
            ultimo = s
        s += 0.25
    return ultimo + 0.25


def huevo_liso(r, semilla, alto=1.12, bultos=0.06):
    """Huevo de cubitos con pocos bultos (el de modelos.celdas_roca es más grumoso)."""
    rx, ry, rz = r, r * 0.95, r * alto
    celdas = set()
    for x in range(-r - 2, r + 2):
        for y in range(-r - 2, r + 2):
            for z in range(-int(rz) - 2, int(rz) + 2):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                ancho = 1 + 0.14 * (-cz / rz)
                d = (cx / (rx * ancho)) ** 2 + (cy / (ry * ancho)) ** 2 + (cz / rz) ** 2
                d += bultos * M.ruido(cx, cy, cz, 0.35, semilla)
                if d <= 1 and cz > -rz * 0.72:
                    celdas.add((x, y, z))
    return apoyar(celdas)


def r_anillos(W, r, lado, z0, semilla):
    # Pradera: huevo gris con anillos marcados (surcos de un cubito en el frente y atrás) y un
    # racimo de amatistas arriba a la izquierda
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla)
    zc = max(c[2] for c in celdas) * 0.45
    # anillos: rebordes de un cubito en la cara de adelante y la de atrás, como vetas de geoda
    # (solo en la parte que mira al frente o atrás: en los costados deformaba el huevo)
    rebordes = set()
    for x, y, z in celdas:
        d = math.hypot(x + 0.5, (z + 0.5 - zc) * 0.85)
        anillo = d < 0.9 or (d < r * 0.6 and abs(d - 2.6 * round(d / 2.6)) < 0.5)
        for dy in (-1, 1):
            if anillo and (x, y + dy, z) not in celdas:
                rebordes.add((x, y + dy, z))
    celdas |= rebordes
    alto = techo(celdas)
    cris = bmesh.new()
    bx, by = -r * 0.42 * lado, -r * 0.15 * lado
    for i in range(7):
        if i == 0:
            off, d, largo, radio = Vector((0, 0, 0)), Vector((-0.35, -0.1, 1)), W * 0.42, W * 0.075
        else:
            a = i / 6 * math.tau + rng.uniform(-0.3, 0.3)
            off = Vector((math.cos(a), math.sin(a), 0)) * W * 0.1
            d = Vector((math.cos(a) * 0.75 - 0.25, math.sin(a) * 0.75, 1))
            largo, radio = W * rng.uniform(0.2, 0.3), W * rng.uniform(0.045, 0.06)
        x, y = bx + off.x, by + off.y
        z = sobre(alto, lado, z0, x, y) or sobre(alto, lado, z0, bx, by)
        cris_pts = punta((x, y, z - lado * 0.3), d, radio, largo, giro=rng.random())
        casco(cris, cris_pts)
    return {"roca": celdas, "cris": cris}


def r_capas_ambar(W, r, lado, z0, semilla):
    # Dunas: huevo color arena en capas (cada 3 filas, el borde se mete un cubito) y gotas de
    # ámbar que chorrean desde arriba
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.18)
    # capas: cada 3 filas, un borde que sobresale un cubito alrededor
    capas = set()
    for x, y, z in celdas:
        if z % 3 == 0 and z > 0:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + dx, y + dy, z) not in celdas:
                    capas.add((x + dx, y + dy, z))
    celdas |= capas
    zmax = max(c[2] for c in celdas)
    cris = bmesh.new()

    def en(a, z, afuera=0.0):
        s = borde(celdas, a, z) * lado + afuera
        return Vector((math.cos(a) * s, math.sin(a) * s, z0 + (z + 0.5) * lado))

    # charco arriba, que cae un poco por el costado
    top = z0 + (zmax + 1) * lado
    pts = [Vector((0.02 * W, -0.02 * W, top + W * 0.06))]
    for i in range(8):
        a = i / 8 * math.tau
        pts.append(Vector((math.cos(a) * W * 0.17, math.sin(a) * W * 0.15, top - lado * 0.6)))
        pts.append(Vector((math.cos(a) * W * 0.12, math.sin(a) * W * 0.1, top + W * 0.035)))
    casco(cris, pts)
    # chorreadas: arriba finitas, abajo una gota gorda
    angulos = [-math.pi / 2 + v for v in (-1.1, -0.45, 0.2, 0.9)] + [math.pi / 2 + v for v in (-0.6, 0.6)]
    for a in angulos:
        a += rng.uniform(-0.15, 0.15)
        zt = round(zmax * rng.uniform(0.82, 0.92))
        zb = max(2, zt - round(r * rng.uniform(0.25, 0.45)))
        arriba_, gota = en(a, zt, W * 0.01), en(a, zb, W * 0.045)
        afuera = Vector((math.cos(a), math.sin(a), 0))
        lado_ = Vector((-math.sin(a), math.cos(a), 0))
        g = W * rng.uniform(0.085, 0.105)
        pts = [gota - Vector((0, 0, g * 0.95))]
        for i in range(7):
            t = i / 7 * math.tau
            v = lado_ * math.cos(t) + afuera * math.sin(t) * 0.8
            pts.append(arriba_ + v * W * 0.035)
            pts.append(gota + v * g * 0.75 + Vector((0, 0, g * 0.55)))
            pts.append(gota + v * g)
            pts.append(gota + v * g * 0.7 - Vector((0, 0, g * 0.7)))
        casco(cris, pts)
    return {"roca": celdas, "cris": cris}


def r_hielo(W, r, lado, z0, semilla):
    # Glaciar: huevo de hielo de caras planas grandes y esquirlas largas de zafiro inclinadas
    rng = random.Random(semilla)
    H = W * 1.18
    perfil = [(0.0, 0.64), (0.13, 0.88), (0.3, 1.0), (0.5, 0.97), (0.7, 0.8), (0.87, 0.52)]
    roca = bmesh.new()
    pts = []
    for k, (h, f) in enumerate(perfil):
        for i in range(9):
            a = (i + (k % 2) * 0.5 + rng.uniform(-0.3, 0.3)) / 9 * math.tau
            rr = W / 2 * f * rng.uniform(0.84, 1.06)
            pts.append(Vector((math.cos(a) * rr, math.sin(a) * rr, z0 + H * h + rng.uniform(-0.05, 0.05) * W)))
    pts.append(Vector((rng.uniform(-0.05, 0.05) * W, rng.uniform(-0.05, 0.05) * W, z0 + H)))
    casco(roca, pts)

    def radio_a(h):
        for (h1, f1), (h2, f2) in zip(perfil, perfil[1:]):
            if h1 <= h <= h2:
                return W / 2 * (f1 + (f2 - f1) * (h - h1) / (h2 - h1))
        return W / 2 * 0.4

    cris = bmesh.new()
    # (ángulo en grados, altura 0-1, inclinación desde arriba, largo, grosor)
    for ang, h, incl, largo, grosor in (
        (-10, 0.62, 42, 0.62, 0.06),
        (25, 0.78, 30, 0.7, 0.065),
        (-55, 0.45, 55, 0.42, 0.05),
        (160, 0.58, 40, 0.55, 0.055),
        (110, 0.75, 32, 0.45, 0.05),
        (200, 0.4, 58, 0.32, 0.045),
    ):
        a = math.radians(ang + rng.uniform(-8, 8))
        t = math.radians(incl)
        rr = radio_a(h) * 0.8
        base = (math.cos(a) * rr, math.sin(a) * rr, z0 + H * h)
        d = (math.cos(a) * math.sin(t), math.sin(a) * math.sin(t), math.cos(t))
        casco(cris, punta(base, d, W * grosor, W * largo, lados=5, giro=rng.random(), hombro=0.8))
    return {"roca": roca, "cris": cris}


def r_basalto(W, r, lado, z0, semilla):
    # Volcán: columnas de basalto de distintas alturas, rubíes facetados encima y lava que
    # asoma abajo entre las columnas
    rng = random.Random(semilla)
    roca = bmesh.new()
    cris = bmesh.new()
    s = W * 0.215
    topes = []
    for j in range(-3, 4):
        for i in range(-3, 4):
            x, y = (i + 0.5 * j) * s, j * s * 0.866
            dist = math.hypot(x, y)
            if dist > W * 0.43:
                continue
            x += rng.uniform(-0.02, 0.02) * W
            y += rng.uniform(-0.02, 0.02) * W
            alto = max(W * 0.4, W * (1.18 - 1.3 * dist / W) * rng.uniform(0.8, 1.1))
            m, giro = W * rng.uniform(0.085, 0.097), rng.uniform(0, math.pi / 2)
            pts = []
            for k in range(8):
                # 8 lados: un cuadrado con las esquinas cortadas
                a = giro + k * math.pi / 4
                ex, ey = math.cos(a) * m, math.sin(a) * m
                pts.append(Vector((x + ex, y + ey, z0 - W * 0.02)))
                pts.append(Vector((x + ex, y + ey, z0 + alto + rng.uniform(-0.02, 0.02) * W)))
            casco(roca, pts)
            topes.append((alto, x, y))
    topes.sort(reverse=True)
    for n, (alto, x, y) in enumerate(topes[:9]):
        if n in (0, 1, 3, 5, 6, 8):
            gema(cris, x, y, z0 + alto, W * rng.uniform(0.1, 0.13), rng.random())
    # lava: una losa que brilla abajo, entre las columnas
    pts = []
    for i in range(12):
        a = i / 12 * math.tau
        rr = W * 0.47 * rng.uniform(0.92, 1.0)
        pts.append(Vector((math.cos(a) * rr, math.sin(a) * rr, z0 - W * 0.02)))
        pts.append(Vector((math.cos(a) * rr * 0.97, math.sin(a) * rr * 0.97, z0 + W * 0.2)))
    casco(cris, pts)
    # grietas de lava que suben por el frente, entre las columnas de afuera
    for x, y in sorted(((x, y) for _, x, y in topes if y < -W * 0.15), key=lambda p: p[0]):
        for lado_x in (-1, 1):
            px = x + lado_x * W * 0.1
            pz = z0 + W * rng.uniform(0.22, 0.32)
            ejes = (Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1)))
            casco(cris, caja((px, y - W * 0.05, (pz + z0) * 0.5), ejes, (W * 0.04, W * 0.05, (pz - z0) * 0.5)))
    return {"roca": roca, "cris": cris}


def r_abertura(W, r, lado, z0, semilla):
    # Abismo: huevo alto violeta muy oscuro con una abertura al frente, estrellitas adentro y
    # otras que flotan arriba
    rng = random.Random(semilla)
    rx, ry, rz = r * 0.9, r * 0.86, r * 1.42
    celdas = set()
    for x in range(-r - 2, r + 2):
        for y in range(-r - 2, r + 2):
            for z in range(-int(rz) - 2, int(rz) + 2):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                ancho = 1 + 0.1 * (-cz / rz)
                d = (cx / (rx * ancho)) ** 2 + (cy / (ry * ancho)) ** 2 + (cz / rz) ** 2
                d += 0.16 * M.ruido(cx, cy, cz, 0.35, semilla)
                if d <= 1 and cz > -rz * 0.72:
                    celdas.add((x, y, z))
    celdas = apoyar(celdas)
    zmax = max(c[2] for c in celdas)
    hc = (0.0, -ry * 0.85, zmax * 0.47)
    hr = (r * 0.42, r * 0.62, zmax * 0.3)
    celdas = {
        c
        for c in celdas
        if sum(((c[i] + 0.5 - hc[i]) / hr[i]) ** 2 for i in range(3)) > 1
    }
    cris = bmesh.new()
    fondo_y = (hc[1] + hr[1] * 0.55) * lado
    for i in range(7):
        a = rng.uniform(0, math.tau)
        d = math.sqrt(rng.uniform(0.05, 0.75))
        x = math.cos(a) * d * hr[0] * lado
        z = z0 + (hc[2] + math.sin(a) * d * hr[2]) * lado
        estrella(cris, (x, fondo_y - rng.uniform(0, 0.06) * W, z), W * rng.uniform(0.05, 0.085))
    top = z0 + (zmax + 1) * lado
    for i in range(5):
        x = (i - 2) * W * 0.17 + rng.uniform(-0.04, 0.04) * W
        z = top + W * (0.06 + 0.14 * rng.random() + (0.08 if i == 2 else 0))
        estrella(cris, (x * 0.8, rng.uniform(-0.12, 0.05) * W, z), W * rng.uniform(0.05, 0.08))
    return {"roca": celdas, "cris": cris}


# --- rocas 2 a 5 (16/10/2026) ----------------------------------------------------------------
# Mismo estilo que las rocas 1: la 2 y la 3 conservan su idea y sus colores, la 4 y la 5 son
# nuevas. Piezas que se repiten:


def en_metros(lado, z0, x, y, z):
    """Centro de la celda (x, y, z) en metros."""
    return Vector(((x + 0.5) * lado, (y + 0.5) * lado, z0 + (z + 0.5) * lado))


def alto_en(celdas, lado, z0, x, y):
    """Altura de la cara de arriba de la roca en (x, y) metros; si no hay roca ahí, la más alta."""
    alto = techo(celdas)
    return sobre(alto, lado, z0, x, y) or z0 + (max(alto.values()) + 1) * lado


def sin_hueco(celdas, centro, radios):
    """Saca de la roca las celdas dentro del elipsoide (centro y radios en celdas)."""
    return {c for c in celdas if sum(((c[i] + 0.5 - centro[i]) / radios[i]) ** 2 for i in range(3)) > 1}


def racimo_hull(bm, base, rng, n, largo, radio, abrir=0.6, eje=(0, 0, 1), lados=6):
    """Racimo de cristales: uno al medio sobre `eje` y los demás abiertos alrededor."""
    eje = Vector(eje).normalized()
    a0 = eje.orthogonal().normalized()
    b0 = eje.cross(a0)
    for i in range(n):
        if i == 0:
            d, off, l, rr = eje, Vector((0, 0, 0)), largo * 1.15, radio * 1.15
        else:
            t = i / max(1, n - 1) * math.tau + rng.uniform(-0.3, 0.3)
            lateral = a0 * math.cos(t) + b0 * math.sin(t)
            d = eje + lateral * abrir * rng.uniform(0.7, 1.2)
            off = lateral * radio * 1.6
            l, rr = largo * rng.uniform(0.55, 0.85), radio * rng.uniform(0.7, 0.9)
        casco(bm, punta(Vector(base) + off, d, rr, l, lados=lados, giro=rng.random()))


def roca_facetada(W, z0, perfil, rng, n=8, cima=None, jit=0.06):
    """Roca de caras planas: anillos de puntos (altura y radio, en W) y una cima."""
    bm = bmesh.new()
    pts = []
    for k, (h, f) in enumerate(perfil):
        for i in range(n):
            a = (i + (k % 2) * 0.5 + rng.uniform(-0.3, 0.3)) / n * math.tau
            rr = W / 2 * f * rng.uniform(1 - jit * 2, 1 + jit)
            pts.append(Vector((math.cos(a) * rr, math.sin(a) * rr, z0 + W * h + rng.uniform(-jit, jit) * W * 0.5)))
    if cima:
        pts.append(Vector(cima))
    casco(bm, pts)
    return bm


def aro(bm, centro, radio, ancho, grosor, inclinacion, giro, n=18):
    """Anillo inclinado hecho de n tramos facetados."""
    c = Vector(centro)
    rot = Matrix.Rotation(giro, 3, "Z") @ Matrix.Rotation(inclinacion, 3, "X")
    for i in range(n):
        pts = []
        for a in (i / n * math.tau, (i + 1) / n * math.tau):
            for rr in (radio - ancho, radio):
                for zz in (-grosor / 2, grosor / 2):
                    pts.append(c + rot @ Vector((math.cos(a) * rr, math.sin(a) * rr, zz)))
        casco(bm, pts)


def rosa(bm, c, radio, rng):
    """Rosa del desierto: tres discos finitos parados que se cruzan."""
    c = Vector(c)
    giro = rng.random()
    for j in range(3):
        a = giro + j * math.pi / 3
        u, v = Vector((math.cos(a), math.sin(a), 0)), Vector((0, 0, 1))
        n = u.cross(v)
        pts = []
        for i in range(8):
            t = i / 8 * math.tau
            p = c + u * math.cos(t) * radio + v * (math.sin(t) * radio * 0.8 + radio * 0.55)
            pts += [p + n * radio * 0.07, p - n * radio * 0.07]
        casco(bm, pts)


def hoja(bm, base, direccion, ancho, largo, grosor):
    """Laja filosa: ancha y finita, con punta."""
    d = Vector(direccion).normalized()
    lat = d.cross(Vector((0, 0, 1)))
    lat = lat.normalized() if lat.length > 1e-4 else Vector((1, 0, 0))
    nor = d.cross(lat).normalized()
    b = Vector(base)
    casco(
        bm,
        [
            b + lat * ancho,
            b - lat * ancho,
            b + nor * grosor,
            b - nor * grosor,
            b + d * largo,
            b + d * largo * 0.55 + lat * ancho * 0.75,
            b + d * largo * 0.6 - lat * ancho * 0.5,
        ],
    )


def bloque(W, rng, centro, medios, giro, jit=0.04):
    """Bloque facetado: caja girada con las esquinas corridas al azar."""
    ejes = (Vector((math.cos(giro), math.sin(giro), 0)), Vector((-math.sin(giro), math.cos(giro), 0)), Vector((0, 0, 1)))
    return [p + Vector([rng.uniform(-jit, jit) * W for _ in range(3)]) for p in caja(centro, ejes, medios)]


# Pradera


def r_musgosa(W, r, lado, z0, semilla):
    # almohadones de musgo arriba y dos racimos de cristales rosas
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=0.95, bultos=0.08)
    alto = techo(celdas)
    for i in range(5):
        a = i / 5 * math.tau + rng.uniform(-0.4, 0.4)
        d = r * rng.uniform(0.3, 0.6) if i else 0.0
        px, py = math.cos(a) * d, math.sin(a) * d
        z = alto.get((math.floor(px), math.floor(py)))
        if z is not None:
            rr = r * rng.uniform(0.28, 0.38)
            celdas |= {c for c in bola(px, py, z + 1 - rr * 0.35, rr) if c[2] >= 0}
    cris = bmesh.new()
    for bx, by, n, esc in ((0.35, -0.3, 6, 1.0), (-0.45, 0.1, 4, 0.7)):
        x, y = bx * r * lado, by * r * lado
        base = (x, y, alto_en(celdas, lado, z0, x, y) - lado * 0.4)
        racimo_hull(cris, base, rng, n, W * 0.3 * esc, W * 0.05 * esc, 0.7)
    return {"roca": celdas, "cris": cris}


def r_caliza(W, r, lado, z0, semilla):
    # lajas apiladas con manojos de agujas finitas
    rng = random.Random(semilla)
    celdas = forma("capas", r, semilla)
    cris = bmesh.new()
    for (x, y), z in arriba(celdas, rng, 3, 0.7, 3)[0]:
        base = en_metros(lado, z0, x, y, z) + Vector((0, 0, lado * 0.3))
        for _ in range(4):
            off = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)) * W * 0.05
            d = (rng.uniform(-0.25, 0.25), rng.uniform(-0.25, 0.25), 1)
            largo = W * rng.uniform(0.22, 0.4)
            casco(cris, punta(base + off, d, W * 0.022, largo, lados=4, giro=rng.random()))
    return {"roca": celdas, "cris": cris}


def r_esmeralda(W, r, lado, z0, semilla):
    # huevo abierto al frente, con esmeraldas que salen de adentro
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.05)
    zmax = max(c[2] for c in celdas)
    hc, hr = (0.0, -r * 0.75, zmax * 0.45), (r * 0.5, r * 0.6, zmax * 0.32)
    celdas = sin_hueco(celdas, hc, hr)
    cris = bmesh.new()
    fondo = (hc[1] + hr[1] * 0.45) * lado
    for i in range(7):
        a = i / 7 * math.tau + rng.uniform(-0.3, 0.3)
        d = 0.0 if i == 0 else rng.uniform(0.35, 0.7)
        ox, oz = math.cos(a) * d * hr[0] * lado, math.sin(a) * d * hr[2] * lado
        base = (ox, fondo, z0 + (hc[2] + 0.5) * lado + oz)
        radio, largo = W * rng.uniform(0.04, 0.055), W * rng.uniform(0.2, 0.3)
        casco(cris, punta(base, (ox * 4, -W, oz * 4), radio, largo, hombro=0.85, giro=rng.random()))
    x, y = W * 0.12, W * 0.05
    racimo_hull(cris, (x, y, alto_en(celdas, lado, z0, x, y) - lado * 0.4), rng, 3, W * 0.22, W * 0.045, 0.6)
    return {"roca": celdas, "cris": cris}


def r_cuarzo_rosa(W, r, lado, z0, semilla):
    # huevo bajo y redondo con una corona de puntas rosas arriba
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=0.82, bultos=0.05)
    zmax = max(c[2] for c in celdas)
    zr = int(zmax * 0.78)
    cris = bmesh.new()
    for i in range(10):
        a = i / 10 * math.tau
        s = borde(celdas, a, zr) * lado * 0.82
        base = (math.cos(a) * s, math.sin(a) * s, z0 + (zr + 1) * lado)
        d = (math.cos(a) * 0.5, math.sin(a) * 0.5, 1)
        casco(cris, punta(base, d, W * 0.045, W * (0.3 if i % 2 else 0.2), giro=rng.random()))
    casco(cris, punta((0, 0, z0 + (zmax + 0.5) * lado), (0, 0, 1), W * 0.07, W * 0.42, giro=rng.random()))
    return {"roca": celdas, "cris": cris}


# Dunas


def r_arenisca(W, r, lado, z0, semilla):
    # meseta en escalones con rosas del desierto arriba
    rng = random.Random(semilla)
    celdas = forma("meseta", r, semilla)
    cris = bmesh.new()
    for i, ((x, y), z) in enumerate(arriba(celdas, rng, 3, 0.9, 3)[0]):
        c = en_metros(lado, z0, x, y, z) + Vector((0, 0, lado * 0.3))
        rosa(cris, c, W * (0.16 if i == 0 else 0.12), rng)
    return {"roca": celdas, "cris": cris}


def r_desertica(W, r, lado, z0, semilla):
    # geoda partida: un hueco grande al frente tapizado de puntas que miran al centro
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.0, bultos=0.08)
    zmax = max(c[2] for c in celdas)
    hc, hr = (0.0, -r * 0.6, zmax * 0.5), (r * 0.62, r * 0.7, zmax * 0.38)
    celdas = sin_hueco(celdas, hc, hr)
    cris = bmesh.new()
    centro = Vector((hc[0] * lado, hc[1] * lado, z0 + hc[2] * lado))
    for _ in range(13):
        u = Vector((rng.uniform(-1, 1), rng.uniform(0.25, 1), rng.uniform(-1, 1))).normalized()
        pared = centro + Vector((u.x * hr[0], u.y * hr[1], u.z * hr[2])) * lado * 0.95
        largo = W * rng.uniform(0.11, 0.17)
        casco(cris, punta(pared, centro - pared, W * 0.035, largo, lados=5, giro=rng.random()))
    return {"roca": celdas, "cris": cris}


def r_topacio(W, r, lado, z0, semilla):
    # duna baja y ancha con prismas grandes de topacio acostados
    rng = random.Random(semilla)
    celdas = apoyar(elipsoide(r * 1.2, r * 0.9, r * 0.85, semilla, bultos=0.1, corte=0.2))
    cris = bmesh.new()
    zt = alto_en(celdas, lado, z0, 0, 0)
    prismas = ((-30, 0.48, 0.085), (150, 0.4, 0.075), (70, 0.34, 0.065), (-110, 0.26, 0.05), (20, 0.24, 0.05))
    for ang, largo, rad in prismas:
        a = math.radians(ang + rng.uniform(-10, 10))
        base = (math.cos(a) * W * 0.12, math.sin(a) * W * 0.12, zt - W * 0.03)
        d = (math.cos(a), math.sin(a), rng.uniform(0.6, 0.9))
        casco(cris, punta(base, d, W * rad, W * largo * 1.3, lados=4, giro=math.pi / 4, hombro=0.8))
    return {"roca": celdas, "cris": cris}


def r_fosil(W, r, lado, z0, semilla):
    # huevo con un caracol fósil en espiral al frente (un surco de dos cubitos) y piedras de sol
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.0)
    zc = max(c[2] for c in celdas) * 0.45
    paso = 2.6
    surco = set()
    for x, y, z in celdas:
        dx, dz = x + 0.5, z + 0.5 - zc
        d = math.hypot(dx, dz)
        if y >= 0 or d > r * 0.8 or d < 0.8:
            continue
        t = math.atan2(dz, dx) % math.tau
        if (d - paso * t / math.tau) % paso < 1.0 and ((x, y - 1, z) not in celdas or (x, y - 2, z) not in celdas):
            surco.add((x, y, z))
    celdas -= surco
    cris = bmesh.new()
    frente = min((y for x, y, z in celdas if x == 0 and z == round(zc)), default=-r) * lado
    gema(cris, 0.5 * lado, frente + W * 0.02, z0 + (zc - 0.3) * lado, W * 0.07, 0.3)
    x, y = -W * 0.1, W * 0.05
    racimo_hull(cris, (x, y, alto_en(celdas, lado, z0, x, y) - lado * 0.4), rng, 4, W * 0.2, W * 0.045, 0.7)
    return {"roca": celdas, "cris": cris}


# Glaciar


def r_escarcha(W, r, lado, z0, semilla):
    # roca nevada de caras planas con escarcha de puntitas arriba
    rng = random.Random(semilla)
    perfil = [(0.0, 0.7), (0.12, 0.95), (0.32, 1.0), (0.55, 0.88), (0.75, 0.55)]
    roca = roca_facetada(W, z0, perfil, rng, cima=(0, 0, z0 + W * 0.92))
    cris = bmesh.new()
    for i in range(9):
        a = i / 9 * math.tau + rng.uniform(-0.2, 0.2)
        base = (math.cos(a) * W * 0.28, math.sin(a) * W * 0.28, z0 + W * 0.74)
        d = (math.cos(a) * 0.6, math.sin(a) * 0.6, 1)
        casco(cris, punta(base, d, W * 0.032, W * rng.uniform(0.14, 0.22), lados=4, giro=rng.random()))
    racimo_hull(cris, (0, 0, z0 + W * 0.86), rng, 3, W * 0.26, W * 0.045, 0.5, lados=4)
    return {"roca": roca, "cris": cris}


def r_profundo(W, r, lado, z0, semilla):
    # dos bloques de hielo, el de arriba corrido, con carámbanos que cuelgan
    rng = random.Random(semilla)
    roca = bmesh.new()
    casco(roca, bloque(W, rng, (0, 0, z0 + W * 0.3), (W * 0.45, W * 0.38, W * 0.3), 0.2, jit=0.08))
    centro = Vector((W * 0.12, -W * 0.06, z0 + W * 0.8))
    giro = 0.75
    casco(roca, bloque(W, rng, centro, (W * 0.38, W * 0.3, W * 0.2), giro, jit=0.07))
    cris = bmesh.new()
    for i in range(7):
        a = i / 7 * math.tau + 0.3
        p = Vector((math.cos(a) * W * 0.36, math.sin(a) * W * 0.28, 0))
        p.rotate(Matrix.Rotation(giro, 3, "Z"))
        base = centro + p + Vector((0, 0, -W * 0.17))
        d = (rng.uniform(-0.1, 0.1), rng.uniform(-0.1, 0.1), -1)
        casco(cris, punta(base, d, W * 0.045, W * rng.uniform(0.2, 0.34), lados=4, giro=rng.random()))
    racimo_hull(cris, centro + Vector((0, 0, W * 0.16)), rng, 3, W * 0.3, W * 0.05, 0.5)
    return {"roca": roca, "cris": cris}


def r_iceberg(W, r, lado, z0, semilla):
    # pico de hielo facetado, con la punta corrida, y esquirlas en la base
    rng = random.Random(semilla)
    perfil = [(0.0, 0.95), (0.15, 1.0), (0.42, 0.72), (0.75, 0.38)]
    roca = roca_facetada(W, z0, perfil, rng, n=6, cima=(W * 0.15, W * 0.05, z0 + W * 1.3), jit=0.12)
    pts = [Vector((-W * 0.3 + math.cos(a) * W * 0.22, math.sin(a) * W * 0.22, z0)) for a in (0, 2.1, 4.2)]
    pts += [Vector((-W * 0.18 + math.cos(a) * W * 0.18, math.sin(a) * W * 0.16, z0 + W * 0.35)) for a in (0.5, 2.6, 4.7)]
    casco(roca, pts + [Vector((-W * 0.3, -W * 0.05, z0 + W * 0.8))])
    cris = bmesh.new()
    for i in range(6):
        a = i / 6 * math.tau + rng.uniform(-0.25, 0.25)
        base = (math.cos(a) * W * 0.4, math.sin(a) * W * 0.4, z0 + W * 0.1)
        d = (math.cos(a), math.sin(a), 0.55)
        casco(cris, punta(base, d, W * 0.045, W * rng.uniform(0.2, 0.3), lados=5, giro=rng.random()))
    return {"roca": roca, "cris": cris}


def r_aurora(W, r, lado, z0, semilla):
    # huevo índigo con un abanico de cristales arriba, como una aurora
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.1, bultos=0.08)
    cris = bmesh.new()
    base = Vector((0, W * 0.05, alto_en(celdas, lado, z0, 0, W * 0.05) - lado * 0.6))
    for i in range(7):
        f = (i - 3) / 3  # de -1 a 1
        ang = math.radians(65) * f
        d = (math.sin(ang), 0.15, math.cos(ang))
        largo = W * (0.68 - 0.3 * abs(f)) * rng.uniform(0.9, 1.05)
        p = base + Vector((f * W * 0.12, 0, 0))
        casco(cris, punta(p, d, W * 0.045, largo, lados=5, giro=rng.random(), hombro=0.8))
    return {"roca": celdas, "cris": cris}


# Volcán


def r_obsidiana(W, r, lado, z0, semilla):
    # base baja de donde salen lajas filosas de obsidiana, con lava abajo
    rng = random.Random(semilla)
    roca = roca_facetada(W, z0, [(0.0, 0.9), (0.12, 1.0), (0.28, 0.75)], rng, cima=(0, 0, z0 + W * 0.36))
    hoja(roca, (0, 0, z0 + W * 0.2), (0.05, -0.05, 1), W * 0.12, W * 0.95, W * 0.05)
    for i in range(5):
        a = i / 5 * math.tau + rng.uniform(-0.3, 0.3)
        t = math.radians(rng.uniform(22, 36))
        base = (math.cos(a) * W * 0.18, math.sin(a) * W * 0.18, z0 + W * 0.18)
        d = (math.cos(a) * math.sin(t), math.sin(a) * math.sin(t), math.cos(t))
        hoja(roca, base, d, W * 0.1, W * rng.uniform(0.5, 0.65), W * 0.045)
    cris = bmesh.new()
    for i in range(6):
        a = (i + 0.5) / 6 * math.tau
        gema(cris, math.cos(a) * W * 0.42, math.sin(a) * W * 0.42, z0 + W * 0.02, W * 0.07, rng.random())
    return {"roca": roca, "cris": cris}


def r_azufre(W, r, lado, z0, semilla):
    # roca ancha con un cráter lleno de cristales de azufre
    rng = random.Random(semilla)
    info = {}
    celdas = forma("crater", r, semilla, info)
    alto = techo(celdas)
    lugares = sorted(xy for xy in alto if math.hypot(xy[0] + 0.5, xy[1] + 0.5) < info["crater"] * 0.6)
    rng.shuffle(lugares)
    elegidos = []
    for xy in lugares:
        if all(abs(xy[0] - e[0]) + abs(xy[1] - e[1]) >= 2 for e in elegidos):
            elegidos.append(xy)
    cris = bmesh.new()
    for i, (x, y) in enumerate(elegidos[:8]):
        base = en_metros(lado, z0, x, y, alto[(x, y)]) + Vector((0, 0, lado * 0.3))
        d = (rng.uniform(-0.4, 0.4), rng.uniform(-0.4, 0.4), 1)
        largo = W * rng.uniform(0.15, 0.28) * (1.3 if i == 0 else 1)
        casco(cris, punta(base, d, W * rng.uniform(0.035, 0.05), largo, lados=4, giro=rng.random()))
    return {"roca": celdas, "cris": cris}


def r_magma(W, r, lado, z0, semilla):
    # huevo con un cinturón de lava: la roca se abre en el medio y asoman bolas que brillan
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=1.0, bultos=0.1)
    zm = max(c[2] for c in celdas) // 2
    anchos = {z: max(math.hypot(x + 0.5, y + 0.5) for x, y, zz in celdas if zz == z) for z in (zm, zm + 1)}
    celdas = {c for c in celdas if not (c[2] in anchos and math.hypot(c[0] + 0.5, c[1] + 0.5) > anchos[c[2]] - 1.6)}
    cris = bmesh.new()
    for i in range(12):
        a = i / 12 * math.tau + rng.uniform(-0.1, 0.1)
        s = (anchos[zm] - 1.2) * lado
        gema(cris, math.cos(a) * s, math.sin(a) * s, z0 + (zm - 0.2) * lado, W * rng.uniform(0.06, 0.08), rng.random())
    gema(cris, 0, 0, alto_en(celdas, lado, z0, 0, 0) - W * 0.04, W * 0.09, 0.2)
    return {"roca": celdas, "cris": cris}


def r_ceniza(W, r, lado, z0, semilla):
    # volcancito de ceniza con piedras de fuego que salen volando del cráter
    rng = random.Random(semilla)
    H = round(r * 1.5)
    celdas = set()
    for z in range(H):
        R = r * 1.15 * (1 - z / H * 0.68)
        for x in range(-r - 2, r + 2):
            for y in range(-r - 2, r + 2):
                d = math.hypot(x + 0.5, y + 0.5) + 0.5 * M.ruido(x, y, z, 0.4, semilla)
                if d <= R and not (z >= H - 3 and d < R * 0.72):
                    celdas.add((x, y, z))
    cris = bmesh.new()
    top = z0 + H * lado
    gema(cris, 0, 0, top - lado * 2.8, W * 0.12, 0.1)
    for i in range(4):
        a = i / 4 * math.tau + rng.uniform(-0.4, 0.4)
        x, y = math.cos(a) * W * 0.16, math.sin(a) * W * 0.1
        gema(cris, x, y, top + W * (0.12 + 0.12 * i), W * (0.1 - 0.012 * i), rng.random())
    return {"roca": celdas, "cris": cris}


# Abismo


def r_nebulosa(W, r, lado, z0, semilla):
    # planeta con un anillo inclinado y dos lunas
    rng = random.Random(semilla)
    info = {}
    celdas = forma("planeta", r, semilla, info)
    centro = Vector((0, 0, z0 + info["centro"][2] * lado))
    radio = info["radio"] * lado
    cris = bmesh.new()
    aro(cris, centro, radio * 1.5, W * 0.13, W * 0.025, 0.42, 0.5, n=20)
    for i in range(2):
        a = rng.uniform(0, math.tau)
        z = centro.z + radio * (1.15 + 0.3 * i)
        gema(cris, math.cos(a) * radio * 1.3, math.sin(a) * radio * 0.6, z, W * 0.05, rng.random())
    return {"roca": celdas, "cris": cris}


def r_meteorito(W, r, lado, z0, semilla):
    # roca áspera con hoyos; en el fondo de cada hoyo brilla un núcleo
    info = {}
    celdas = forma("meteorito", r, semilla, info)
    cris = bmesh.new()
    for hx, hy, hz, nx, ny, nz, radio in info["hoyos"]:
        p = Vector((hx - nx * radio * 0.55, hy - ny * radio * 0.55, hz - nz * radio * 0.55)) * lado
        gema(cris, p.x, p.y, z0 + p.z - radio * lado * 0.5, radio * lado * 0.8, hx)
    return {"roca": celdas, "cris": cris}


def r_cometa(W, r, lado, z0, semilla):
    # cabeza de cometa áspera con una cola de cristales hacia un costado y arriba
    rng = random.Random(semilla)
    celdas = huevo_liso(r, semilla, alto=0.85, bultos=0.2)
    zt = alto_en(celdas, lado, z0, 0, 0)
    cris = bmesh.new()
    base = Vector((W * 0.15, W * 0.1, zt - W * 0.2))
    for largo, rad, inc in ((0.75, 0.065, 0.55), (0.6, 0.055, 0.85), (0.5, 0.05, 0.3)):
        casco(cris, punta(base, (1, 0.35, inc), W * rad, W * largo, lados=5, giro=rng.random(), hombro=0.82))
    cola = Vector((1, 0.35, 0.55)).normalized()
    for i in range(4):
        p = base + cola * W * (0.35 + 0.22 * i) + Vector((0, -W * 0.12, W * 0.12 * (i % 2)))
        estrella(cris, p, W * 0.05)
    return {"roca": celdas, "cris": cris}


def r_eclipse(W, r, lado, z0, semilla):
    # esfera negra con una corona de rayos que asoma alrededor
    rng = random.Random(semilla)
    info = {}
    celdas = forma("planeta", r, semilla, info)
    centro = Vector((0, W * 0.08, z0 + info["centro"][2] * lado))
    radio = info["radio"] * lado
    cris = bmesh.new()
    for i in range(16):
        a = i / 16 * math.tau
        d = Vector((math.cos(a), 0, math.sin(a)))
        if d.z < -0.35:
            continue  # los de abajo quedarían en el piso
        largo = radio * (0.75 if i % 2 == 0 else 0.5) * rng.uniform(0.9, 1.1)
        casco(cris, punta(centro + d * radio * 0.75, d, W * 0.045, radio * 0.25 + largo, lados=4, giro=math.pi / 4))
    return {"roca": celdas, "cris": cris}


NUEVAS = {
    "anillos": r_anillos,
    "capas_ambar": r_capas_ambar,
    "hielo": r_hielo,
    "basalto": r_basalto,
    "abertura": r_abertura,
    "musgosa": r_musgosa,
    "caliza": r_caliza,
    "esmeralda": r_esmeralda,
    "cuarzo_rosa": r_cuarzo_rosa,
    "arenisca": r_arenisca,
    "desertica": r_desertica,
    "topacio": r_topacio,
    "fosil": r_fosil,
    "escarcha": r_escarcha,
    "profundo": r_profundo,
    "iceberg": r_iceberg,
    "aurora": r_aurora,
    "obsidiana": r_obsidiana,
    "azufre": r_azufre,
    "magma": r_magma,
    "ceniza": r_ceniza,
    "nebulosa": r_nebulosa,
    "meteorito_nuevo": r_meteorito,
    "cometa": r_cometa,
    "eclipse": r_eclipse,
}


def grietas_rayos(nombre, obj_roca, mat, semilla, cantidad, W):
    """Grietas para cualquier forma: zigzags pegados a la superficie (se buscan tirando rayos
    hacia el eje). Cada tramo es una tira finita con lomo."""
    bpy.context.view_layer.update()
    arbol = BVHTree.FromObject(obj_roca, bpy.context.evaluated_depsgraph_get())
    zs = [v.co.z for v in obj_roca.data.vertices]
    zmin, zmax = min(zs), max(zs)
    rng = random.Random(semilla)
    bm = bmesh.new()
    for g in range(cantidad):
        a = rng.uniform(0, math.tau)
        h = rng.uniform(0.45, 0.8)
        sentido = 1 if g % 2 == 0 else -1
        puntos = []
        for k in range(9):
            z = zmin + (zmax - zmin) * h
            hit, normal, _, _ = arbol.ray_cast(
                Vector((math.cos(a) * W * 2, math.sin(a) * W * 2, z)), Vector((-math.cos(a), -math.sin(a), 0))
            )
            if hit is None:
                break
            puntos.append((hit + normal * W * 0.002, normal))
            a += rng.uniform(0.08, 0.14) * sentido
            h += 0.05 if k % 2 == 0 else -0.1
        for (p, n), (q, _) in zip(puntos, puntos[1:]):
            if (q - p).length > W * 0.25 or (q - p).length < 1e-4:
                continue  # saltó de una columna a otra
            ancho = (q - p).cross(n).normalized() * W * 0.018
            lomo = n * W * 0.012
            casco(bm, [p - ancho, p + ancho, q + ancho, q - ancho, p + lomo, q + lomo])
    return M.objeto_desde_bmesh(nombre, bm, mat)


CONTEO = {}  # nombre -> triángulos de (Roca, Cristales, Base, Grietas, Grietas2)


def armar_nueva(nombre, datos, estilo, mats, semilla):
    r = datos["radio"]
    W = datos["diametro"] * M.STUD
    lado = W / (2 * r)
    z0 = W * 0.05
    hecho = NUEVAS[estilo["forma"]](W, r, lado, z0, semilla)
    if isinstance(hecho["roca"], set):
        obj_roca, t1 = M.voxeles("Roca", hecho["roca"], lado, mats["roca"], origen=(0, 0, z0), ranura=0, atlas=True)
    else:
        obj_roca, t1 = M.objeto_desde_bmesh("Roca", hecho["roca"], mats["roca"])
    obj_cris, t2 = M.objeto_desde_bmesh("Cristales", hecho["cris"], mats["cristal"])
    obj_base, t3 = M.objeto_desde_bmesh("Base", nido(W, semilla), mats["base"])
    obj_g1, t4 = grietas_rayos("Grietas", obj_roca, mats["grieta"], semilla, 3, W)
    obj_g2, t5 = grietas_rayos("Grietas2", obj_roca, mats["grieta2"], semilla + 1000, 3, W)
    CONTEO[nombre] = (t1, t2, t3, t4, t5)
    print(f"  {nombre}: {t1 + t2 + t3 + t4 + t5} triángulos (roca {t1}, cristales {t2}, nido {t3}, grietas {t4 + t5})")
    return [obj_roca, obj_cris, obj_base, obj_g1, obj_g2]


# --- armar y exportar -------------------------------------------------------------------------


def armar(nombre, datos, estilo, mats, semilla):
    if estilo["forma"] in NUEVAS:
        return armar_nueva(nombre, datos, estilo, mats, semilla)
    r = datos["radio"]
    lado = datos["diametro"] * M.STUD / (2 * r)
    info = {}
    roca = forma(estilo["forma"], r, semilla, info)
    o_roca = (0, 0, lado * 0.5)
    obj_roca, t1 = M.voxeles("Roca", roca, lado, mats["roca"], origen=o_roca, atlas=True)
    cris = cristales(estilo["cristal"], roca, datos["cristales"], semilla, info)
    obj_cris, t2 = M.voxeles("Cristales", cris, lado / 2, mats["cristal"], origen=o_roca)
    obj_base, t3 = M.voxeles("Base", M.celdas_base(r, semilla), lado, mats["base"])
    largo = r * 3
    obj_g1, t4 = M.grietas("Grietas", roca, lado, mats["grieta"], o_roca, semilla, 3, largo)
    obj_g2, t5 = M.grietas("Grietas2", roca, lado, mats["grieta2"], o_roca, semilla + 1000, 3, largo)
    total = t1 + t2 + t3 + t4 + t5
    # cada malla ya se revisa contra el máximo de Roblox (modelos.objeto_desde_bmesh)
    print(f"  {nombre}: {total} triángulos en 5 mallas (roca {t1}, cristales {t2})")
    return [obj_roca, obj_cris, obj_base, obj_g1, obj_g2]


def mats_de(estilo):
    # nombres distintos por color: modelos.material reusa el material si el nombre ya existe
    return {
        "roca": M.material("Roca" + estilo["roca"], estilo["roca"]),
        "cristal": M.material("Cristales" + estilo["cris"], estilo["cris"], rugoso=0.2),
        "base": M.material("Base", M.COLOR_BASE),
        "grieta": M.material("Grietas" + estilo["cris"], estilo["cris"]),
        "grieta2": M.material("Grietas2", "#2EF2FF"),
    }


def variantes():
    """(zona, número de variante, estilo) de las 15 rocas de bioma."""
    for zona, lista in ESTILOS.items():
        for v, est in enumerate(lista, 1):
            yield zona, v, est


def agrupar(nombre, objetos, padre=None):
    vacio = bpy.data.objects.new(nombre, None)
    bpy.context.scene.collection.objects.link(vacio)
    vacio.parent = padre
    for o in objetos:
        o.parent = vacio
    return vacio


def exportar_grupo(raiz, archivo):
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / archivo),
        use_selection=True,
        object_types={"MESH", "EMPTY"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        bake_space_transform=True,
        add_leaf_bones=False,
    )
    print("  FBX", archivo)


def exportar(especiales=True):
    """Un FBX por bioma con sus 5 rocas; con especiales=False no se toca Geodas_Especiales.fbx."""
    M.limpiar_escena()
    for zona, lista in ESTILOS.items():
        raiz = bpy.data.objects.new(f"Zona{zona}", None)
        bpy.context.scene.collection.objects.link(raiz)
        for v, est in enumerate(lista, 1):
            mats = mats_de(est)
            for tam, datos in M.GEODAS.items():
                if tam == "Jefe" and v > 1:
                    continue  # el Jefe es siempre la variante 1
                nombre = nombre_tamano(tam, v)
                objs = armar(f"Zona{zona} {nombre}", datos, est, mats, semilla_de(datos, zona, v))
                agrupar(nombre, objs, raiz)
        exportar_grupo(raiz, f"Geodas_Zona{zona}.fbx")
        M.limpiar_escena()
    if not especiales:
        return
    raiz = bpy.data.objects.new("Especiales", None)
    bpy.context.scene.collection.objects.link(raiz)
    for nombre, est in ESPECIALES.items():
        datos = datos_especial(est)
        objs = armar(nombre, datos, est, mats_de(est), datos["semilla"] + 7)
        agrupar(nombre, objs, raiz)
    exportar_grupo(raiz, "Geodas_Especiales.fbx")
    M.limpiar_escena()


def con_brillo(objs, est, clave, fuerza=2.5):
    """Para el render: los cristales que en el juego son Neon, que brillen."""
    for o in objs:
        if o.name.startswith("Cristales"):
            o.data.materials.clear()
            o.data.materials.append(M.material(f"Brillo{clave}", est["cris"], brillo=est["cris"], fuerza_brillo=fuerza))


def render():
    """Grilla de muestra: una fila por bioma con sus 5 rocas (Mediana) y, en la última
    columna, las 3 especiales. Se ven como en el juego: solo las especiales brillan."""
    M.limpiar_escena()
    paso_x, paso_y = 2.0, 6.0
    elevacion = math.radians(28)
    piezas = []  # (fila, columna, texto, estilo, datos, semilla)
    datos = M.GEODAS["Mediana"]
    for zona, v, est in variantes():
        piezas.append((zona - 1, v - 1, f"{zona}.{v} {est['nombre']}", est, datos, semilla_de(datos, zona, v)))
    for i, (texto, clave) in enumerate((("Oculta", "Oculta"), ("Prismática", "Prisma"), ("Renacida", "Renacida"))):
        d = datos_especial(ESPECIALES[clave])
        piezas.append((i + 1, 5, texto, ESPECIALES[clave], d, d["semilla"] + 7))
    # alto de la imagen según lo que ocupa la grilla vista desde la cámara
    ancho = 6 * paso_x + 0.6
    alto = 4 * paso_y * math.sin(elevacion) + 2.4
    escena = M.escena_render(1800, round(1800 * alto / ancho))
    for i, j, texto, est, d, semilla in piezas:
        x = (j - 2.5) * paso_x + (0.3 if j == 5 else 0)
        y = (2 - i) * paso_y
        objs = armar(texto, d, est, mats_de(est), semilla)
        if est in ESPECIALES.values():
            con_brillo(objs, est, f"{i}{j}")
        objs = M.sin_grietas(objs)
        if d is not datos:
            # las especiales son más grandes: acá se muestran del tamaño de la Mediana
            for o in objs:
                o.scale = [datos["diametro"] / d["diametro"]] * 3
        M.mover(objs, x, y, giro=0.3 if est in ESPECIALES.values() else 0.0)
        t = M.etiqueta(texto, x, y - 1.15, z=0.05, tam=0.22, color="#1B1F3B")
        t.rotation_euler.x = math.pi / 2 - elevacion
        t.visible_shadow = False  # sin sombra, así se lee
    # cámara ortográfica casi de frente: todas se ven del mismo tamaño
    cam = bpy.data.cameras.new("Camara")
    cam.type = "ORTHO"
    cam.sensor_fit = "HORIZONTAL"
    cam.ortho_scale = ancho
    obj = bpy.data.objects.new("Camara", cam)
    escena.collection.objects.link(obj)
    centro = (0.15, -0.6, 0.9)
    obj.location = (centro[0], centro[1] - 40 * math.cos(elevacion), centro[2] + 40 * math.sin(elevacion))
    obj.rotation_euler = (math.pi / 2 - elevacion, 0, 0)
    escena.camera = obj
    M.render("geodas_biomas")


def contar_nuevas():
    """Tabla de triángulos de las 25 rocas (el Jefe es solo la roca 1) y avisa si se pasan."""
    topes = {"Mediana": 4000, "Jefe": 20000}
    filas = []
    for zona, v, est in variantes():
        fila = [f"{zona}.{v} {est['nombre']}"]
        for tam, datos in M.GEODAS.items():
            if tam == "Jefe" and v > 1:
                fila.append("-")
                continue
            M.limpiar_escena()
            clave = f"{zona}.{v}-{tam}"
            armar(clave, datos, est, mats_de(est), semilla_de(datos, zona, v))
            total = sum(CONTEO[clave])
            fila.append(f"{total}{' (SE PASA)' if total > topes.get(tam, 1e9) else ''}")
        filas.append(fila)
    print("TABLA | Roca | " + " | ".join(M.GEODAS))
    for fila in filas:
        print("TABLA | " + " | ".join(fila))
    M.limpiar_escena()


def render_nuevas():
    """Las 5 rocas nuevas (Mediana) en fila, con el encuadre de la imagen de Gemini, y una
    imagen con las dos lado a lado. Se ven como en el juego: un color por malla, sin Neon."""
    M.limpiar_escena()
    escena = M.escena_render(1376, 768)
    datos = M.GEODAS["Mediana"]
    paso = 1.6
    for zona in ESTILOS:
        est = ESTILOS[zona][0]
        objs = armar(f"{zona} {est['nombre']}", datos, est, mats_de(est), semilla_de(datos, zona, 1))
        M.mover(M.sin_grietas(objs), (zona - 3) * paso)
    M.camara(escena, (0, 0, 1.4), 11.7, 2.7, lente=50, giro=0)
    M.render("geodas_nuevas")
    # lado a lado: Gemini a la izquierda, el render a la derecha
    import numpy as np

    ref = bpy.data.images.load(str(M.ARTE / "referencias" / "geodas-gemini.jpg"))
    nuevo = bpy.data.images.load(str(M.RENDERS / "geodas_nuevas.jpg"))
    w, h = ref.size
    if tuple(nuevo.size) != (w, h):
        nuevo.scale(w, h)
    capas = []
    for img in (ref, nuevo):
        px = np.empty(w * h * 4, dtype=np.float32)
        img.pixels.foreach_get(px)
        capas.append(px.reshape(h, w, 4))
    capas.insert(1, np.ones((h, 16, 4), dtype=np.float32))
    junto = np.concatenate(capas, axis=1)
    salida = bpy.data.images.new("comparacion", junto.shape[1], h)
    salida.pixels.foreach_set(junto.ravel())
    salida.filepath_raw = str(M.RENDERS / "geodas_nuevas_vs_gemini.jpg")
    salida.file_format = "JPEG"
    salida.save()
    print("  Render geodas_nuevas_vs_gemini.jpg")


if __name__ == "__main__":
    M.FBX.mkdir(parents=True, exist_ok=True)
    if "--nuevas" in sys.argv:
        # solo para revisar: tabla de triángulos y render, sin exportar
        contar_nuevas()
        render_nuevas()
        print("Listo")
        sys.exit(0)
    if "--biomas" in sys.argv:
        # los 5 FBX de los biomas, sin tocar las especiales
        exportar(especiales=False)
        render()
        print("Listo")
        sys.exit(0)
    if "--solo-render" not in sys.argv:
        exportar()
    render()
    print("Listo")
