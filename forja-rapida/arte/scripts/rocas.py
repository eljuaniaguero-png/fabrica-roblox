"""Rocas terminadas: tres geodas distintas por bioma, más las especiales (Oculta, Prismática y
Renacida).

Cada variante tiene su forma de roca, su tipo de cristal y sus colores (los mismos de
GameConfig, Zonas[n].Variantes: el juego las pinta con esos colores). Todo en estilo vóxel, como
modelos.py:
  1 Pradera de Cuarzo   Cuarzo (huevo con puntas), Musgosa (almohadones de musgo con drusas),
                        Caliza (lajas apiladas con agujas)
  2 Dunas de Ámbar      Ámbar (canto con gotas), Arenisca Roja (meseta con rosas del desierto),
                        Desértica (geoda partida con cristales adentro)
  3 Glaciar de Zafiro   Zafiro (facetada con esquirlas), Escarcha (roca nevada con escarcha),
                        Glaciar Profundo (bloques de hielo con carámbanos)
  4 Volcán de Rubí      Rubí (columnas con bloques), Obsidiana (lajas filosas con vetas de lava),
                        Azufre (cráter lleno de cristales)
  5 Abismo Estelar      Estelar (surco con estrellas), Nebulosa (planeta con anillo),
                        Meteorito (roca con hoyos que brillan)
  Oculta     huevo con una veta brillante alrededor (el mineral secreto)
  Prisma     prisma alto con esquirlas de colores
  Renacida   roca dorada con corona y alas de fénix (la del Santuario del Renacer)
La variante 1 de cada bioma es la de siempre.

Exporta un FBX por bioma (arte/fbx/Geodas_Zona<N>.fbx): la variante 1 en Pequena, Mediana,
Gigante y Jefe, y las otras dos en Pequena_2, Mediana_2, Gigante_2, Pequena_3, Mediana_3 y
Gigante_3 (sin Jefe). Las especiales van en Geodas_Especiales.fbx (Oculta, Prisma, Renacida).
Cada tamaño tiene las mallas Roca, Cristales, Base, Grietas y Grietas2 (las que pinta
ModeloGeoda.luau). Render de muestra: arte/renders/geodas_biomas.jpg (las 15 y las especiales).

Uso: <python de Blender> forja-rapida/arte/scripts/rocas.py   (--solo-render: sin exportar)
"""

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001  (bpy antes que modelos, que usa bmesh)
import modelos as M  # noqa: E402

ESTILOS = {
    1: [
        {"nombre": "Cuarzo", "forma": "huevo", "cristal": "puntas", "roca": "#6E7487", "cris": "#C77DFF"},
        {"nombre": "Musgosa", "forma": "musgo", "cristal": "drusa", "roca": "#5E8C4A", "cris": "#FF8FD8"},
        {"nombre": "Caliza", "forma": "capas", "cristal": "agujas", "roca": "#D8D2C0", "cris": "#7CF5FF"},
    ],
    2: [
        {"nombre": "Ámbar", "forma": "canto", "cristal": "gotas", "roca": "#B07A4A", "cris": "#FFB627"},
        {"nombre": "Arenisca Roja", "forma": "meseta", "cristal": "rosas", "roca": "#C4553A", "cris": "#FFE14D"},
        {"nombre": "Desértica", "forma": "partida", "cristal": "adentro", "roca": "#E8C98A", "cris": "#FF8C42"},
    ],
    3: [
        {"nombre": "Zafiro", "forma": "facetada", "cristal": "esquirlas", "roca": "#7FA6C9", "cris": "#3D7BFF"},
        {"nombre": "Escarcha", "forma": "nevada", "cristal": "escarcha", "roca": "#E8F4FF", "cris": "#7CF5FF"},
        {"nombre": "Glaciar Profundo", "forma": "tempano", "cristal": "carambanos", "roca": "#2F5D8A", "cris": "#B8F3FF"},
    ],
    4: [
        {"nombre": "Rubí", "forma": "columnas", "cristal": "bloques", "roca": "#4A3338", "cris": "#FF2E4D"},
        {"nombre": "Obsidiana", "forma": "filosa", "cristal": "vetas", "roca": "#1E1A24", "cris": "#FF7A00"},
        {"nombre": "Azufre", "forma": "crater", "cristal": "drusa", "roca": "#6B5A2E", "cris": "#F5FF4D"},
    ],
    5: [
        {"nombre": "Estelar", "forma": "surco", "cristal": "estrellas", "roca": "#2E2A5C", "cris": "#7CF5FF"},
        {"nombre": "Nebulosa", "forma": "planeta", "cristal": "anillo", "roca": "#4B2A6B", "cris": "#FF6FD8"},
        {"nombre": "Meteorito", "forma": "meteorito", "cristal": "brasas", "roca": "#3B3B3B", "cris": "#FFB347"},
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


def caja_redonda(cx, cy, cz, rx, ry, rz, semilla, giro=0.0, p=4.0):
    """Cubo de esquinas redondeadas (superelipsoide), girado `giro` radianes en el piso."""
    celdas = set()
    ext = max(rx, ry) * 1.5
    co, si = math.cos(-giro), math.sin(-giro)
    for x in range(math.floor(cx - ext) - 1, math.ceil(cx + ext) + 1):
        for y in range(math.floor(cy - ext) - 1, math.ceil(cy + ext) + 1):
            for z in range(math.floor(cz - rz) - 1, math.ceil(cz + rz) + 1):
                dx, dy, dz = x + 0.5 - cx, y + 0.5 - cy, z + 0.5 - cz
                dx, dy = dx * co - dy * si, dx * si + dy * co
                d = abs(dx / rx) ** p + abs(dy / ry) ** p + abs(dz / rz) ** p
                if d + 0.12 * M.ruido(x, y, z, 0.5, semilla) <= 1:
                    celdas.add((x, y, z))
    return celdas


def laja(sx, sy, sz, dx, dy, dz, largo, grosor):
    """Punta que sale de (sx, sy, sz) hacia (dx, dy, dz) y se afina hasta la punta."""
    celdas = set()
    ex, ey, ez = sx + dx * largo, sy + dy * largo, sz + dz * largo
    for x in range(math.floor(min(sx, ex) - grosor) - 1, math.ceil(max(sx, ex) + grosor) + 1):
        for y in range(math.floor(min(sy, ey) - grosor) - 1, math.ceil(max(sy, ey) + grosor) + 1):
            for z in range(math.floor(min(sz, ez) - grosor) - 1, math.ceil(max(sz, ez) + grosor) + 1):
                px, py, pz = x + 0.5 - sx, y + 0.5 - sy, z + 0.5 - sz
                t = (px * dx + py * dy + pz * dz) / largo
                if 0 <= t <= 1:
                    qx, qy, qz = px - dx * t * largo, py - dy * t * largo, pz - dz * t * largo
                    if math.sqrt(qx * qx + qy * qy + qz * qz) <= grosor * (1 - 0.85 * t):
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


def pegada(c, d, a, b):
    """Celda fina (grilla x2) pegada afuera de la cara d de la celda c; a y b eligen cuál de las
    4 que tapan la cara."""
    f = []
    libres = iter((a, b))
    for i in range(3):
        if d[i] > 0:
            f.append(2 * c[i] + 2)
        elif d[i] < 0:
            f.append(2 * c[i] - 1)
        else:
            f.append(2 * c[i] + next(libres))
    return tuple(f)


# --- formas de roca ---------------------------------------------------------------------------
# Cada forma devuelve las celdas apoyadas en z = 0. En `info` deja lo que necesitan sus
# cristales (dónde está el hueco, el cráter, los hoyos...).


def f_huevo(r, rng, semilla, info):
    return M.celdas_roca(r, semilla)


def f_canto(r, rng, semilla, info):
    celdas = set()
    rx, ry, rz = r * 1.2, r * 1.1, r * 0.82
    for x in range(-r - 3, r + 4):
        for y in range(-r - 3, r + 4):
            for z in range(-r - 2, r + 2):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                d = (cx / rx) ** 2 + (cy / ry) ** 2 + (cz / rz) ** 2 + 0.18 * M.ruido(cx, cy, cz, 0.3, semilla)
                if d <= 1 and cz > -rz * 0.6:
                    # capas: cada 3 filas, el borde se mete un cubito
                    if z % 3 == 0 and d > 0.78:
                        continue
                    celdas.add((x, y, z))
    return apoyar(celdas)


def f_facetada(r, rng, semilla, info):
    celdas = set()
    rx, ry, rz = r * 0.95, r * 0.9, r * 1.3
    for x in range(-r - 2, r + 3):
        for y in range(-r - 2, r + 3):
            for z in range(-int(rz) - 2, int(rz) + 2):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                octa = (abs(cx) / rx + abs(cy) / ry) * 0.62 + abs(cz) / rz
                esf = (cx / rx) ** 2 + (cy / ry) ** 2 + (cz / rz) ** 2
                d = 0.6 * octa + 0.4 * esf + 0.1 * M.ruido(cx, cy, cz, 0.5, semilla)
                if d <= 1 and cz > -rz * 0.55:
                    celdas.add((x, y, z))
    return apoyar(celdas)


def f_columnas(r, rng, semilla, info):
    celdas = set()
    for cx in range(-r, r + 1, 2):
        for cy in range(-r, r + 1, 2):
            dist = math.hypot(cx, cy)
            if dist > r + 0.5:
                continue
            alto = int(r * (1.7 - 0.9 * dist / r)) + rng.randint(-1, 1)
            for dx in range(2):
                for dy in range(2):
                    for z in range(max(2, alto)):
                        celdas.add((cx + dx, cy + dy, z))
    return apoyar(celdas)


def f_surco(r, rng, semilla, info):
    base = M.celdas_roca(r, semilla)
    zmax = max(c[2] for c in base)
    medio = zmax * 0.55
    celdas = set()
    for x, y, z in base:
        borde = any((x + dx, y + dy, z) not in base for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        if abs(z - medio) < 1 and borde:
            continue  # el surco alrededor
        celdas.add((x, y, z))
    # piedritas que flotan arriba
    for i in range(3):
        a = i / 3 * math.tau + semilla
        px, py = int(math.cos(a) * r * 0.9), int(math.sin(a) * r * 0.9)
        celdas.add((px, py, zmax + 3 + i % 2))
    return celdas


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


def f_musgo(r, rng, semilla, info):
    # roca baja y ancha cubierta de almohadones de musgo redondos
    celdas = apoyar(elipsoide(r * 1.12, r * 1.02, r * 0.72, semilla, bultos=0.14, corte=0.55))
    alto = techo(celdas)
    for i in range(6):
        a = i / 6 * math.tau + rng.uniform(-0.4, 0.4)
        d = r * rng.uniform(0.35, 0.7) if i else 0.0
        px, py = math.cos(a) * d, math.sin(a) * d
        arriba = alto.get((math.floor(px), math.floor(py)))
        if arriba is None:
            continue
        rr = r * rng.uniform(0.3, 0.42) * (1.25 if i == 0 else 1)
        celdas |= {c for c in bola(px, py, arriba + 1 - rr * 0.3, rr) if c[2] >= 0}
    return celdas


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


def f_partida(r, rng, semilla, info):
    # geoda partida: un huevo con un hueco grande al frente (-Y), donde se ven los cristales
    celdas = M.celdas_roca(r, semilla)
    zmax = max(c[2] for c in celdas)
    cx, cy, cz, radio = 0.0, -r * 0.62, (zmax + 1) * 0.5, r * 0.68
    hueco = {c for c in celdas if (c[0] + 0.5 - cx) ** 2 + (c[1] + 0.5 - cy) ** 2 + (c[2] + 0.5 - cz) ** 2 <= radio**2}
    info["hueco"] = (cx, cy, cz, radio, hueco)
    return celdas - hueco


def f_nevada(r, rng, semilla, info):
    # roca con un copete de nieve que sobresale alrededor, y gotas de nieve que cuelgan
    cuerpo = elipsoide(r * 0.84, r * 0.8, r * 0.8, semilla, bultos=0.2, corte=0.62)
    zmax = max(c[2] for c in cuerpo)
    copete = elipsoide(r * 1.1, r * 1.02, r * 0.4, semilla + 3, bultos=0.12, corte=1.0)
    alto = zmax - round(r * 0.18)
    celdas = cuerpo | {(x, y, z + alto) for x, y, z in copete}
    # gotas: algunas columnitas que cuelgan del borde del copete
    for (x, y, z) in sorted(celdas):
        if z > alto - 2 and (x, y, z - 1) not in celdas and (x * 7 + y * 13) % 5 == 0:
            for k in range(1, 3):
                celdas.add((x, y, z - k))
    return apoyar(celdas)


def f_tempano(r, rng, semilla, info):
    # bloques de hielo: uno grande abajo y otro arriba, girado y corrido, que sobresale (de los
    # bordes que sobresalen cuelgan los carámbanos)
    abajo = caja_redonda(0, 0, r * 0.62, r * 0.9, r * 0.8, r * 0.62, semilla)
    arriba = caja_redonda(r * 0.3, -r * 0.18, r * 1.62, r * 0.78, r * 0.68, r * 0.42, semilla + 5, giro=0.6)
    return apoyar(abajo | arriba)


def f_filosa(r, rng, semilla, info):
    # obsidiana: una base baja de donde salen lajas filosas, inclinadas para afuera
    celdas = apoyar(elipsoide(r * 1.0, r * 0.95, r * 0.55, semilla, bultos=0.2, corte=0.45))
    zb = max(c[2] for c in celdas)
    puntas = [(0.0, 0.0, r * 1.8, 0.0)]  # (ángulo, distancia al centro, largo, inclinación)
    for i in range(5):
        a = i / 5 * math.tau + rng.uniform(-0.35, 0.35)
        puntas.append((a, r * 0.45, r * rng.uniform(1.0, 1.4), math.radians(rng.uniform(20, 34))))
    for a, d, largo, incl in puntas:
        dx, dy, dz = math.cos(a) * math.sin(incl), math.sin(a) * math.sin(incl), math.cos(incl)
        celdas |= laja(math.cos(a) * d, math.sin(a) * d, zb * 0.4, dx, dy, dz, largo, r * 0.36)
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
    "canto": f_canto,
    "facetada": f_facetada,
    "columnas": f_columnas,
    "surco": f_surco,
    "prisma": f_prisma,
    "musgo": f_musgo,
    "capas": f_capas,
    "meseta": f_meseta,
    "partida": f_partida,
    "nevada": f_nevada,
    "tempano": f_tempano,
    "filosa": f_filosa,
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


def c_puntas(roca, cantidad, rng, semilla, info):
    return M.celdas_cristales(roca, cantidad, semilla)


def c_gotas(roca, cantidad, rng, semilla, info):
    celdas = set()
    for i, ((x, y), z) in enumerate(arriba(roca, rng, cantidad + 3, 0.45, 3)[0]):
        bx, by, bz = x * 2, y * 2, z * 2 + 1
        radio = 3 if i == 0 else 2
        for dx in range(-radio, radio + 1):
            for dy in range(-radio, radio + 1):
                for dz in range(0, radio + 2):
                    if dx * dx + dy * dy + (dz - 1) ** 2 <= radio * radio + 1:
                        celdas.add((bx + dx, by + dy, bz + dz))
    return celdas


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


def c_bloques(roca, cantidad, rng, semilla, info):
    celdas = set()
    for (x, y), z in arriba(roca, rng, cantidad + 2, 0.4, 2)[0]:
        bx, by, bz = x * 2, y * 2, z * 2 + 1
        ancho = rng.choice([2, 3, 3])
        h = rng.randint(5, 9)
        for dx in range(ancho):
            for dy in range(ancho):
                for k in range(h - (1 if (dx + dy) % 2 else 0)):
                    celdas.add((bx + dx, by + dy, bz + k))
    return celdas


def c_estrellas(roca, cantidad, rng, semilla, info):
    celdas = set()
    elegidos, zmax = arriba(roca, rng, cantidad, 0.45)
    for (x, y), z in elegidos:
        cx, cy, cz = x * 2, y * 2, z * 2 + 4  # flotan un poco arriba de la roca
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                for dz in range(-2, 3):
                    if abs(dx) + abs(dy) + abs(dz) <= 2:
                        celdas.add((cx + dx, cy + dy, cz + dz))
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


def racimo(celdas, bx, by, bz, rng, cuantos, alto):
    """Racimo apretado de cristales cortos, cada uno inclinado para otro lado (una drusa)."""
    for j in range(cuantos):
        ox, oy = (0, 0) if j == 0 else (rng.randint(-2, 2), rng.randint(-2, 2))
        incl = (0, 0) if j == 0 else rng.choice([(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1)])
        h = rng.randint(alto - 2, alto) + (2 if j == 0 else 0)
        for k in range(h):
            g = 2 if k < h - 2 else 1
            px, py = bx + ox + incl[0] * (k // 2), by + oy + incl[1] * (k // 2)
            for dx in range(g):
                for dy in range(g):
                    celdas.add((px + dx, py + dy, bz + k))


def c_drusa(roca, cantidad, rng, semilla, info):
    celdas = set()
    alto = techo(roca)
    if "crater" in info:
        # todo el fondo del cráter lleno de cristales cortos
        radio = info["crater"]
        lugares = sorted(xy for xy in alto if math.hypot(xy[0] + 0.5, xy[1] + 0.5) < radio * 0.62)
        rng.shuffle(lugares)
        elegidos = []
        for xy in lugares:
            if all(abs(xy[0] - e[0]) + abs(xy[1] - e[1]) >= 2 for e in elegidos):
                elegidos.append(xy)
        for i, (x, y) in enumerate(elegidos[: cantidad + 3]):
            racimo(celdas, x * 2, y * 2, alto[(x, y)] * 2 + 1, rng, 2 if i else 3, 6 if i else 8)
    else:
        # racimos rosados entre los almohadones de musgo
        for i, ((x, y), z) in enumerate(arriba(roca, rng, max(2, cantidad - 1), 0.5, 4)[0]):
            racimo(celdas, x * 2, y * 2, z * 2 + 1, rng, 4 if i == 0 else 3, 7 if i == 0 else 5)
    return celdas


def c_agujas(roca, cantidad, rng, semilla, info):
    # manojos de agujas finitas y altas
    celdas = set()
    alto = techo(roca)
    for i, ((x, y), z) in enumerate(arriba(roca, rng, 2 + cantidad // 3, 0.7, 3)[0]):
        for j in range(rng.randint(5, 7)):
            fx, fy = x * 2 + rng.randint(-2, 2), y * 2 + rng.randint(-2, 2)
            base = alto.get((fx // 2, fy // 2))
            if base is None:
                continue
            h = rng.randint(7, 12) + (3 if i == 0 and j == 0 else 0)
            lado = rng.choice([(1, 0), (-1, 0), (0, 1), (0, -1)])
            for k in range(h):
                celdas.add((fx + lado[0] * (k // 5), fy + lado[1] * (k // 5), base * 2 + 1 + k))
    return celdas


def c_rosas(roca, cantidad, rng, semilla, info):
    # rosas del desierto: láminas planas paradas que se cruzan en el centro, como una flor
    celdas = set()
    for i, ((x, y), z) in enumerate(arriba(roca, rng, max(2, cantidad // 2 + 1), 0.8, 4)[0]):
        cx, cy, bz = x * 2 + 1, y * 2 + 1, z * 2 + 1
        ancho = 4 if i == 0 else 3
        alto = 8 if i == 0 else 6
        giro = rng.random() * math.pi
        for j in range(4):
            a = giro + j * math.pi / 4
            s = -ancho
            while s <= ancho:
                h = int(round(alto * math.sqrt(max(0.0, 1 - (s / (ancho + 0.6)) ** 2))))
                px, py = math.floor(cx + math.cos(a) * s), math.floor(cy + math.sin(a) * s)
                for k in range(h):
                    celdas.add((px, py, bz + k))
                s += 0.5
    return celdas


def c_adentro(roca, cantidad, rng, semilla, info):
    # cristales que tapizan el hueco de la geoda partida y apuntan hacia el centro
    cx, cy, cz, radio, hueco = info["hueco"]
    C = (cx * 2, cy * 2, cz * 2)
    R = radio * 2
    celdas = set()
    for x in range(math.floor(C[0] - R) - 1, math.ceil(C[0] + R) + 1):
        for y in range(math.floor(C[1] - R) - 1, math.ceil(C[1] + R) + 1):
            for z in range(math.floor(C[2] - R) - 1, math.ceil(C[2] + R) + 1):
                if (x // 2, y // 2, z // 2) in hueco and math.dist((x + 0.5, y + 0.5, z + 0.5), C) >= R - 1.6:
                    celdas.add((x, y, z))
    forro = sorted(celdas)
    rng.shuffle(forro)
    for x, y, z in forro[: 10 + cantidad * 4]:
        # una punta corta hacia el centro
        d = [C[0] - x - 0.5, C[1] - y - 0.5, C[2] - z - 0.5]
        largo = math.hypot(*d) or 1
        for k in range(1, rng.randint(2, 4)):
            celdas.add(tuple(math.floor(p + 0.5 + v / largo * k) for p, v in zip((x, y, z), d)))
    return celdas


def c_escarcha(roca, cantidad, rng, semilla, info):
    # escarcha: cubitos chiquitos que brillan por toda la roca, y unas puntas cortas arriba
    celdas = set()
    for c, d in expuestas(roca):
        if rng.random() < 0.15:
            celdas.add(pegada(c, d, rng.randint(0, 1), rng.randint(0, 1)))
    for (x, y), z in arriba(roca, rng, cantidad, 0.8, 3)[0]:
        h = rng.randint(3, 5)
        for k in range(h):
            g = 2 if k < h - 1 else 1
            for dx in range(g):
                for dy in range(g):
                    celdas.add((x * 2 + dx, y * 2 + dy, z * 2 + 2 + k))
    return celdas


def c_carambanos(roca, cantidad, rng, semilla, info):
    # carámbanos que cuelgan de los bordes que sobresalen, y unos cristales parados arriba
    celdas = set()
    zmax = max(c[2] for c in roca)
    colgados = sorted(c for c in roca if c[2] >= zmax * 0.4 and (c[0], c[1], c[2] - 1) not in roca)
    rng.shuffle(colgados)
    elegidos = []
    for c in colgados:
        if all(abs(c[0] - e[0]) + abs(c[1] - e[1]) >= 2 for e in elegidos):
            elegidos.append(c)
    for x, y, z in elegidos[: cantidad * 2 + 3]:
        largo = rng.randint(3, min(9, 2 * z - 1))
        for k in range(largo):
            g = 2 if k < largo // 2 else 1
            for dx in range(g):
                for dy in range(g):
                    celdas.add((x * 2 + dx, y * 2 + dy, z * 2 - 1 - k))
    for (x, y), z in arriba(roca, rng, 2, 0.85, 3)[0]:
        for k in range(rng.randint(4, 6)):
            for dx in range(2):
                for dy in range(2):
                    celdas.add((x * 2 + dx, y * 2 + dy, z * 2 + 2 + k))
    return celdas


def c_vetas(roca, cantidad, rng, semilla, info):
    # vetas de lava: caminos que brillan sobre la roca, y brasas entre las lajas
    celdas = set()
    for c, d in M.caminos_grieta(roca, semilla + 55, cantidad + 3, 14):
        for a in range(2):
            for b in range(2):
                celdas.add(pegada(c, d, a, b))
    for (x, y), z in arriba(roca, rng, cantidad, 0.1, 3)[0]:
        if z < max(c[2] for c in roca) * 0.5:
            for dx in range(2):
                for dy in range(2):
                    for dz in range(2):
                        celdas.add((x * 2 + dx, y * 2 + dy, z * 2 + 2 + dz))
    return celdas


def c_anillo(roca, cantidad, rng, semilla, info):
    # un anillo inclinado alrededor del planeta, y dos lunitas
    cx, cy, cz = (v * 2 for v in info["centro"])
    radio = info["radio"] * 2 * 1.34
    incl, giro = 0.42, 0.5
    ci, si, cg, sg = math.cos(incl), math.sin(incl), math.cos(giro), math.sin(giro)
    celdas = set()
    ext = math.ceil(radio) + 2
    for x in range(math.floor(cx) - ext, math.floor(cx) + ext + 1):
        for y in range(math.floor(cy) - ext, math.floor(cy) + ext + 1):
            for z in range(math.floor(cz) - ext, math.floor(cz) + ext + 1):
                px, py, pz = x + 0.5 - cx, y + 0.5 - cy, z + 0.5 - cz
                px, py = px * cg + py * sg, -px * sg + py * cg  # girar en el piso
                py, pz = py * ci + pz * si, -py * si + pz * ci  # inclinar
                if abs(pz) <= 0.66 and radio - 2.4 <= math.hypot(px, py) <= radio:
                    celdas.add((x, y, z))
    zmax = max(c[2] for c in roca) * 2
    for i in range(2):
        a = rng.random() * math.tau
        lx, ly = math.floor(math.cos(a) * radio * 0.8), math.floor(math.sin(a) * radio * 0.8)
        lz = zmax + 2 + i * 3
        for dx in range(2):
            for dy in range(2):
                for dz in range(2):
                    celdas.add((lx + dx, ly + dy, lz + dz))
    return celdas


def c_brasas(roca, cantidad, rng, semilla, info):
    # un núcleo que brilla en el fondo de cada hoyo del meteorito
    celdas = set()
    for hx, hy, hz, nx, ny, nz, radio in info["hoyos"]:
        prof = radio * 0.75
        celdas |= bola((hx - nx * prof) * 2, (hy - ny * prof) * 2, (hz - nz * prof) * 2, radio * 1.1)
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
    "puntas": c_puntas,
    "gotas": c_gotas,
    "esquirlas": c_esquirlas,
    "bloques": c_bloques,
    "estrellas": c_estrellas,
    "veta": c_veta,
    "drusa": c_drusa,
    "agujas": c_agujas,
    "rosas": c_rosas,
    "adentro": c_adentro,
    "escarcha": c_escarcha,
    "carambanos": c_carambanos,
    "vetas": c_vetas,
    "anillo": c_anillo,
    "brasas": c_brasas,
    "fenix": c_fenix,
}


def cristales(nombre, roca, cantidad, semilla, info=None):
    rng = random.Random(semilla)
    return CRISTALES[nombre](roca, cantidad, rng, semilla, {} if info is None else info)


# --- armar y exportar -------------------------------------------------------------------------


def armar(nombre, datos, estilo, mats, semilla):
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


def exportar():
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
    """Grilla de muestra: una fila por bioma con sus 3 variantes (Mediana) y, en la última
    columna, las 3 especiales."""
    M.limpiar_escena()
    paso_x, paso_y = 2.5, 3.6
    elevacion = math.radians(40)
    piezas = []  # (fila, columna, texto, estilo, datos, semilla)
    datos = M.GEODAS["Mediana"]
    for zona, v, est in variantes():
        piezas.append((zona - 1, v - 1, f"{zona} {est['nombre']}", est, datos, semilla_de(datos, zona, v)))
    for i, (texto, clave) in enumerate((("Oculta", "Oculta"), ("Prismática", "Prisma"), ("Renacida", "Renacida"))):
        d = datos_especial(ESPECIALES[clave])
        piezas.append((i + 1, 3, texto, ESPECIALES[clave], d, d["semilla"] + 7))
    # alto de la imagen según lo que ocupa la grilla vista desde la cámara
    ancho = 4 * paso_x + 0.5
    alto = 5 * paso_y * math.sin(elevacion) + 1.6
    escena = M.escena_render(1600, round(1600 * alto / ancho))
    for i, j, texto, est, d, semilla in piezas:
        x = (j - 1.5) * paso_x + (0.35 if j == 3 else 0)
        y = (2 - i) * paso_y
        objs = armar(texto, d, est, mats_de(est), semilla)
        if est["cristal"] in ("veta", "estrellas", "brasas", "vetas", "fenix") or texto == "Prismática":
            con_brillo(objs, est, f"{i}{j}")
        objs = M.sin_grietas(objs)
        if d is not datos:
            # las especiales son más grandes: acá se muestran del tamaño de la Mediana
            for o in objs:
                o.scale = [datos["diametro"] / d["diametro"]] * 3
        M.mover(objs, x, y, giro=0.3 if est["forma"] in ("partida", "planeta", "corona") else 0.45 + 0.2 * j)
        t = M.etiqueta(texto, x, y - 1.05, z=0.05, tam=0.3, color="#1B1F3B")
        t.rotation_euler.x = math.pi / 2 - elevacion
        t.visible_shadow = False  # sin sombra, así se lee
    # cámara ortográfica de frente y desde arriba: todas se ven del mismo tamaño
    cam = bpy.data.cameras.new("Camara")
    cam.type = "ORTHO"
    cam.sensor_fit = "HORIZONTAL"
    cam.ortho_scale = ancho
    obj = bpy.data.objects.new("Camara", cam)
    escena.collection.objects.link(obj)
    centro = (0.2, -0.3, 0.7)
    obj.location = (centro[0], centro[1] - 40 * math.cos(elevacion), centro[2] + 40 * math.sin(elevacion))
    obj.rotation_euler = (math.pi / 2 - elevacion, 0, 0)
    escena.camera = obj
    M.render("geodas_biomas")


if __name__ == "__main__":
    M.FBX.mkdir(parents=True, exist_ok=True)
    if "--solo-render" not in sys.argv:
        exportar()
    render()
    print("Listo")
