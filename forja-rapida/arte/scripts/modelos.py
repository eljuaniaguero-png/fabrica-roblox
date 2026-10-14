"""Modelos de Forja Rápida, generados por código (estilo vóxel, como las capturas de referencia).

Arma en Blender:
  - 4 geodas (Pequena, Mediana, Gigante, Jefe), cada una con 5 mallas: Roca, Cristales, Base,
    Grietas y Grietas2 (las grietas que brillan en las geodas exóticas, una por modificador).
  - Un anillo de cubitos (Geoda_Anillo) que gira alrededor de las geodas de Lava.
  - Eventos y exhibición (grupos 6 y 7): Geoda Ancestral (con corona de cristales y cinturón de
    Runas), pedestal de vitrina, estatuas de gemas (una por rareza), cristal de la lluvia, bomba
    de lava y tablero de clasificación.
  - 8 texturas de 256 px para la Roca de las exóticas (texturas/): rayas de lava, cuadritos de
    colores neón, oro, vacío y las 4 combinaciones. La Roca tiene un mapa UV "por cubito": cada
    cara cae en una celda de 16 x 16 según su altura, así la misma textura sirve en los 4 tamaños.
  - 5 gemas, una forma por rareza (el color de cada gema lo pone el juego).
  - 5 picos, con 2 o 3 mallas: Mango, Cabeza y (Oro y Cósmico) Detalle.
Exporta un FBX por modelo a forja-rapida/arte/fbx/ y renders de muestra a forja-rapida/arte/renders/.

Cómo correrlo (desde la raíz del repositorio):
  blender --background --python forja-rapida/arte/scripts/modelos.py
  (o con Python y el paquete bpy: python forja-rapida/arte/scripts/modelos.py)
  Para no hacer los renders (tardan un par de minutos): agregar "-- --sin-renders".

Reglas (GUIA, sección 5): escala real (1 stud = 0,28 m), pivote en la base, frente a -Z de
Roblox, malla cerrada con normales hacia afuera, un material por malla, un set de UV en 0-1,
y como mucho 20.000 triángulos por malla. Cada malla sale sin textura: el juego le pone color y
material (ModeloGeoda.luau pinta la geoda según la zona y el modificador exótico).

Importar en Studio: 3D Importer con cada FBX. Las geodas van a ServerStorage > Modelos >
Geodas > <Pequena|Mediana|Gigante|Jefe> (un Model con las partes Roca, Cristales y Base).
"""

import math
import random
import sys
from pathlib import Path

import bpy  # primero bpy: con el paquete de Python, bmesh y mathutils aparecen recién después

import bmesh
from mathutils import Vector, noise

ARTE = Path(__file__).resolve().parents[1]
FBX = ARTE / "fbx"
RENDERS = ARTE / "renders"
TEXTURAS = ARTE / "texturas"
CELDAS_TEXTURA = 16  # la textura es una grilla de 16 x 16 celdas de 16 px
STUD = 0.28  # metros por stud
MAX_TRIANGULOS = 20000

# Colores solo para los renders (en el juego los pone GameConfig). Zona 1: Pradera de Cuarzo.
COLOR_ROCA = "#6E7487"
COLOR_CRISTAL = "#C77DFF"
COLOR_BASE = "#7A5233"
COLOR_PISO = "#7ED957"
COLOR_CIELO = "#55B8FF"

# Tamaños (en studs): diámetro de la roca y cuántos vóxeles tiene de radio. Las grandes tienen
# vóxeles más gordos para no pasar el límite de triángulos (y se ven más "pesadas").
GEODAS = {
    "Pequena": {"diametro": 3.0, "radio": 5, "cristales": 3, "semilla": 11},
    "Mediana": {"diametro": 4.5, "radio": 6, "cristales": 4, "semilla": 22},
    "Gigante": {"diametro": 6.9, "radio": 7, "cristales": 6, "semilla": 33},
    "Jefe": {"diametro": 12.0, "radio": 9, "cristales": 9, "semilla": 44},
}

# Las 6 caras de un cubo de lado 1: dirección del vecino y esquinas en sentido antihorario
# vistas desde afuera (así la normal apunta hacia afuera).
CARAS = [
    ((1, 0, 0), [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)]),
    ((-1, 0, 0), [(0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0)]),
    ((0, 1, 0), [(0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0)]),
    ((0, -1, 0), [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)]),
    ((0, 0, 1), [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)]),
    ((0, 0, -1), [(0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0)]),
]


# ---------------------------------------------------------------------------------------------
# Utilidades


def hex_a_rgb(h):
    h = h.lstrip("#")
    srgb = [int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    # Blender trabaja en lineal
    return [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb]


def limpiar_escena():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(nombre, color, metal=0.0, rugoso=0.6, brillo=None, fuerza_brillo=0.0):
    m = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    if bpy.app.version < (5, 0, 0) and not m.use_nodes:
        m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf is None:
        bsdf = m.node_tree.nodes.new("ShaderNodeBsdfPrincipled")
        salida = m.node_tree.nodes.get("Material Output") or m.node_tree.nodes.new(
            "ShaderNodeOutputMaterial"
        )
        m.node_tree.links.new(bsdf.outputs["BSDF"], salida.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*hex_a_rgb(color), 1)
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Roughness"].default_value = rugoso
    if brillo:
        bsdf.inputs["Emission Color"].default_value = (*hex_a_rgb(brillo), 1)
        bsdf.inputs["Emission Strength"].default_value = fuerza_brillo
    m.diffuse_color = (*hex_a_rgb(color), 1)
    return m


def uv_caja(bm):
    """UV por proyección de caja (según hacia dónde mira cada cara), metidas en 0-1."""
    capa = bm.loops.layers.uv.verify()
    todos = []
    for f in bm.faces:
        n = f.normal
        eje = max(range(3), key=lambda i: abs(n[i]))
        a, b = [(1, 2), (0, 2), (0, 1)][eje]
        for loop in f.loops:
            co = loop.vert.co
            loop[capa].uv = (co[a], co[b])
            todos.append(loop[capa].uv)
    if not todos:
        return
    minu = min(u.x for u in todos)
    minv = min(u.y for u in todos)
    lado = max(max(u.x for u in todos) - minu, max(u.y for u in todos) - minv) or 1
    for f in bm.faces:
        for loop in f.loops:
            uv = loop[capa].uv
            loop[capa].uv = ((uv.x - minu) / lado, (uv.y - minv) / lado)


def objeto_desde_bmesh(nombre, bm, mat, uv=True):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    if uv:
        uv_caja(bm)
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    malla.materials.append(mat)
    obj = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(obj)
    triangulos = sum(len(p.vertices) - 2 for p in malla.polygons)
    if triangulos > MAX_TRIANGULOS:
        raise RuntimeError(f"{nombre}: {triangulos} triángulos (máximo {MAX_TRIANGULOS})")
    return obj, triangulos


def voxeles(nombre, celdas, lado, mat, origen=(0, 0, 0), ranura=0.16, hundir=0.06, atlas=False):
    """Malla de cubitos: solo las caras que dan afuera, cada una con una ranura alrededor
    (el borde de cada cubito que se ve en las capturas). `lado` en metros.
    Con atlas=True, cada cara usa una celda de la textura de 16 x 16: la fila según la altura
    del cubito y la columna al azar (fija para cada cara)."""
    bm = bmesh.new()
    vertices = {}

    def vert(p):
        if p not in vertices:
            vertices[p] = bm.verts.new(
                (origen[0] + p[0] * lado, origen[1] + p[1] * lado, origen[2] + p[2] * lado)
            )
        return vertices[p]

    caras = []
    celda_de = {}
    for x, y, z in celdas:
        for k, ((dx, dy, dz), esquinas) in enumerate(CARAS):
            if (x + dx, y + dy, z + dz) in celdas:
                continue
            vs = [vert((x + ex, y + ey, z + ez)) for ex, ey, ez in esquinas]
            try:
                cara = bm.faces.new(vs)
            except ValueError:
                continue  # cara repetida (no debería pasar)
            caras.append(cara)
            celda_de[cara] = (x, y, z, k)
    bm.normal_update()
    if atlas:
        # UV antes de la ranura: las caras nuevas heredan la celda de su cara original
        capa = bm.loops.layers.uv.verify()
        zmax = max(c[2] for c in celdas)
        n = CELDAS_TEXTURA
        for cara, (x, y, z, k) in celda_de.items():
            h = (x * 73856093 ^ y * 19349663 ^ z * 83492791 ^ k * 2654435761) & 0xFFFFFFFF
            col = h % n
            fila = min(n - 1, z * n // (zmax + 1))
            u0, u1 = (col + 0.1) / n, (col + 0.9) / n
            v0, v1 = (fila + 0.1) / n, (fila + 0.9) / n
            for loop, uv in zip(cara.loops, [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]):
                loop[capa].uv = uv
    bmesh.ops.inset_individual(
        bm, faces=caras, thickness=lado * ranura, depth=-lado * hundir, use_even_offset=True
    )
    return objeto_desde_bmesh(nombre, bm, mat, uv=not atlas)


def ruido(x, y, z, escala, semilla):
    return noise.noise(Vector((x * escala + semilla * 7.31, y * escala - semilla, z * escala)))


# ---------------------------------------------------------------------------------------------
# Geodas


def celdas_roca(r, semilla):
    """Huevo de cubitos algo achatado abajo, con bultos. Devuelve las celdas con z >= 0."""
    rx, ry, rz = r, r * 0.95, r * 1.12
    celdas = set()
    for x in range(-r - 2, r + 2):
        for y in range(-r - 2, r + 2):
            for z in range(-int(rz) - 2, int(rz) + 2):
                cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                # más ancho abajo que arriba (forma de huevo)
                ancho = 1 + 0.12 * (-cz / rz)
                d = (cx / (rx * ancho)) ** 2 + (cy / (ry * ancho)) ** 2 + (cz / rz) ** 2
                d += 0.22 * ruido(cx, cy, cz, 0.35, semilla)
                if d <= 1 and cz > -rz * 0.72:
                    celdas.add((x, y, z))
    zmin = min(c[2] for c in celdas)
    return {(x, y, z - zmin) for x, y, z in celdas}


def celdas_cristales(roca, cantidad, semilla):
    """Columnas de cubitos que asoman de la mitad de arriba de la roca, inclinadas de a
    escalones. Usan una grilla el doble de fina que la roca."""
    rng = random.Random(semilla)
    alto = {}
    for x, y, z in roca:
        alto[(x, y)] = max(alto.get((x, y), -1), z)
    zmax = max(alto.values())
    # lugares de la parte de arriba, no justo en el borde
    lugares = [(xy, z) for xy, z in alto.items() if z >= zmax * 0.62]
    rng.shuffle(lugares)
    elegidos = []
    for xy, z in lugares:
        if all(abs(xy[0] - e[0][0]) + abs(xy[1] - e[0][1]) >= 3 for e in elegidos):
            elegidos.append((xy, z))
        if len(elegidos) >= cantidad:
            break
    celdas = set()
    for i, ((x, y), z) in enumerate(elegidos):
        # en la grilla fina (x2): base de 2x2, punta de 1x1
        bx, by, bz = x * 2, y * 2, z * 2 + 1
        h = rng.randint(5, 9) + (2 if i == 0 else 0)
        incl = rng.choice([(1, 0), (-1, 0), (0, 1), (0, -1)])
        for k in range(h):
            corrimiento = k // 3
            ox = bx + incl[0] * corrimiento
            oy = by + incl[1] * corrimiento
            grosor = 2 if k < h - 2 else 1
            for dx in range(grosor):
                for dy in range(grosor):
                    celdas.add((ox + dx, oy + dy, bz + k))
    return celdas


def celdas_base(r, semilla):
    """Nido de escombros: un anillo bajo y desparejo alrededor de la roca."""
    rng = random.Random(semilla)
    celdas = set()
    exterior = r * 1.38
    interior = r * 0.62
    for x in range(-int(exterior) - 1, int(exterior) + 2):
        for y in range(-int(exterior) - 1, int(exterior) + 2):
            d = math.hypot(x + 0.5, y + 0.5)
            if interior <= d <= exterior + 0.6 * ruido(x, y, 0, 0.5, semilla):
                celdas.add((x, y, 0))
                if d < exterior - 1 and rng.random() < 0.55:
                    celdas.add((x, y, 1))
    return celdas


EJES = [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]


def _suma(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def _neg(a):
    return (-a[0], -a[1], -a[2])


def caminos_grieta(celdas, semilla, cantidad, largo):
    """Caminos al azar por la superficie de la roca (cara de cubito en cara de cubito, doblando
    en los bordes). Devuelve las caras visitadas: (celda, dirección hacia afuera)."""
    rng = random.Random(semilla)

    def expuesta(c, d):
        return c in celdas and _suma(c, d) not in celdas

    zmax = max(c[2] for c in celdas)
    inicios = [
        (c, d)
        for c in celdas
        for d in EJES[:4]
        if expuesta(c, d) and zmax * 0.25 <= c[2] <= zmax * 0.8
    ]
    inicios.sort()
    rng.shuffle(inicios)
    caras = []
    vistas = set()
    for c, d in inicios[:cantidad]:
        t = rng.choice([e for e in EJES if e not in (d, _neg(d))])
        for _ in range(largo):
            if (c, d) not in vistas:
                vistas.add((c, d))
                caras.append((c, d))
            if rng.random() < 0.3:
                t = rng.choice([e for e in EJES if e not in (d, _neg(d))])
            n = _suma(c, t)
            if expuesta(n, d):
                c = n  # sigue en el mismo plano
            elif n not in celdas:
                d, t = t, _neg(d)  # borde que sale: dobla a la cara de al lado
            elif _suma(n, d) in celdas and expuesta(_suma(n, d), _neg(t)):
                c, d, t = _suma(n, d), _neg(t), d  # rincón: sube por la pared
            else:
                break
    return caras


def grietas(nombre, celdas, lado, mat, origen, semilla, cantidad, largo):
    """Grietas que brillan: una baldosita apenas salida sobre cada cara del camino. El juego
    las muestra (material Neon, color del modificador) solo en las geodas exóticas."""
    return baldositas(nombre, caminos_grieta(celdas, semilla, cantidad, largo), lado, mat, origen)


def baldositas(nombre, caras, lado, mat, origen):
    """Una baldosita apenas salida (una cajita finita) sobre cada cara (celda, dirección)."""
    bm = bmesh.new()
    achicar, salir, grosor = 0.78, 0.02, 0.05
    for c, d in caras:
        esquinas = dict(CARAS)[d]
        centro = Vector(c) + Vector((0.5, 0.5, 0.5)) + Vector(d) * 0.5
        base = []
        for e in esquinas:
            p = centro + (Vector(_suma(c, e)) - centro) * achicar
            base.append(p + Vector(d) * salir)
        arriba = [p + Vector(d) * grosor for p in base]
        vb = [bm.verts.new(Vector(origen) + p * lado) for p in base]
        va = [bm.verts.new(Vector(origen) + p * lado) for p in arriba]
        bm.faces.new(va)
        bm.faces.new(list(reversed(vb)))
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new([vb[i], vb[j], va[j], va[i]])
    return objeto_desde_bmesh(nombre, bm, mat)


def caras_runas(celdas):
    """Cinturón de runas alrededor de la mitad de la roca: una fila entera y, arriba y abajo,
    marcas salteadas (parecen letras antiguas)."""
    zmax = max(c[2] for c in celdas)
    zmid = zmax // 2
    caras = []
    for x, y, z in celdas:
        if abs(z - zmid) > 1:
            continue
        for d in EJES[:4]:
            if _suma((x, y, z), d) in celdas:
                continue
            if z == zmid or (x * 3 + y * 5 + z) % 4 == 0:
                caras.append(((x, y, z), d))
    return caras


def celdas_anillo(r):
    """Anillo de cubitos alrededor de la roca (como el de la referencia de lava)."""
    radio = r * 1.45
    celdas = set()
    for x in range(-int(radio) - 2, int(radio) + 3):
        for y in range(-int(radio) - 2, int(radio) + 3):
            if radio - 0.9 <= math.hypot(x + 0.5, y + 0.5) <= radio + 0.5:
                celdas.add((x, y, 0))
    return celdas


# ---------------------------------------------------------------------------------------------
# Texturas de los modificadores (16 x 16 celdas de 16 px; fila 0 = la parte de abajo de la roca)


def _rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def _mezcla(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def _hsv(h, s, v):
    import colorsys

    return tuple(round(x * 255) for x in colorsys.hsv_to_rgb(h, s, v))


LAVA = [_rgb(c) for c in ("#FF2A00", "#FF5A00", "#FF8C00", "#FFB300", "#FFE14D")]
ORO = [_rgb(c) for c in ("#E8A317", "#FFC83D", "#FFD95A", "#FFF0A0")]


def c_lava(col, fila, rng):
    # rayas horizontales onduladas, de rojo a amarillo y vuelta
    onda = round(1.3 * math.sin(col * 0.8))
    banda = (fila + onda) // 2
    return LAVA[[0, 1, 2, 3, 4, 3, 2, 1][banda % 8]]


def c_neon(col, fila, rng):
    # cuadritos de todos los colores sobre un fondo violeta (como el gato de la referencia)
    if rng.random() < 0.5:
        return _mezcla(_rgb("#2B1B8F"), _rgb("#5B2BD9"), fila / 15)
    return _hsv(rng.random(), 0.8, 1.0)


def c_midas(col, fila, rng):
    base = rng.choice(ORO[:3])
    return _mezcla(base, ORO[3], 0.35) if fila >= 12 or rng.random() < 0.1 else base


def c_vacio(col, fila, rng):
    x = rng.random()
    if x < 0.04:
        return (255, 255, 255)  # estrellas
    if x < 0.16:
        return _rgb("#9B4DFF")
    if x < 0.22:
        return _rgb("#4D2BFF")
    return _mezcla(_rgb("#0E0820"), _rgb("#24104A"), rng.random())


def c_lava_neon(col, fila, rng):
    return c_neon(col, fila, rng) if rng.random() < 0.3 else c_lava(col, fila, rng)


def c_midas_neon(col, fila, rng):
    return _hsv(rng.random(), 0.75, 1.0) if rng.random() < 0.28 else c_midas(col, fila, rng)


def c_vacio_lava(col, fila, rng):
    return c_lava(col, fila, rng) if (fila // 3) % 2 == 0 else c_vacio(col, fila, rng)


def c_vacio_midas(col, fila, rng):
    veta = abs(math.sin(col * 0.7 + fila * 0.45)) < 0.28 or rng.random() < 0.06
    return rng.choice(ORO) if veta else c_vacio(col, fila, rng)


TEXTURAS_MOD = {
    "Lava": c_lava,
    "Neon": c_neon,
    "Midas": c_midas,
    "Vacio": c_vacio,
    "LavaNeon": c_lava_neon,
    "MidasNeon": c_midas_neon,
    "VacioLava": c_vacio_lava,
    "VacioMidas": c_vacio_midas,
}


def guardar_png(ruta, ancho, alto, filas):
    """PNG RGB sin dependencias (filas de arriba hacia abajo, valores 0-255)."""
    import struct
    import zlib

    crudo = b"".join(b"\x00" + bytes(v for px in fila for v in px) for fila in filas)

    def bloque(tipo, datos):
        return (
            struct.pack(">I", len(datos))
            + tipo
            + datos
            + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF)
        )

    png = (
        b"\x89PNG\r\n\x1a\n"
        + bloque(b"IHDR", struct.pack(">IIBBBBB", ancho, alto, 8, 2, 0, 0, 0))
        + bloque(b"IDAT", zlib.compress(crudo, 9))
        + bloque(b"IEND", b"")
    )
    Path(ruta).write_bytes(png)


def hacer_texturas():
    TEXTURAS.mkdir(parents=True, exist_ok=True)
    n, px = CELDAS_TEXTURA, 16
    for nombre, color_de in TEXTURAS_MOD.items():
        rng = random.Random(nombre)
        celdas = [[color_de(col, fila, rng) for col in range(n)] for fila in range(n)]
        filas = []
        for y in range(n * px):
            fila = (n * px - 1 - y) // px  # la fila 0 de celdas va abajo
            j = y % px
            linea = []
            for x in range(n * px):
                col, i = x // px, x % px
                c = celdas[fila][col]
                # cada cubito con luz arriba-izquierda y sombra abajo-derecha
                if i < 2 or j < 2:
                    c = tuple(min(255, round(v * 1.18 + 12)) for v in c)
                elif i > 13 or j > 13:
                    c = tuple(round(v * 0.78) for v in c)
                linea.append(c)
            filas.append(linea)
        guardar_png(TEXTURAS / f"{nombre}.png", n * px, n * px, filas)
    print(f"  {len(TEXTURAS_MOD)} texturas en {TEXTURAS}")


def armar_geoda(nombre, datos, mats, runas=False):
    r = datos["radio"]
    lado = datos["diametro"] * STUD / (2 * r)
    roca = celdas_roca(r, datos["semilla"])
    # la roca se apoya medio cubito adentro del nido
    o_roca = (0, 0, lado * 0.5)
    obj_roca, t1 = voxeles("Roca", roca, lado, mats["roca"], origen=o_roca, atlas=True)
    cristales = celdas_cristales(roca, datos["cristales"], datos["semilla"])
    obj_cris, t2 = voxeles("Cristales", cristales, lado / 2, mats["cristal"], origen=o_roca)
    obj_base, t3 = voxeles("Base", celdas_base(r, datos["semilla"]), lado, mats["base"])
    largo = r * 3
    obj_g1, t4 = grietas(
        "Grietas", roca, lado, mats.get("grieta", mats["cristal"]), o_roca, datos["semilla"], 3, largo
    )
    obj_g2, t5 = grietas(
        "Grietas2",
        roca,
        lado,
        mats.get("grieta2", mats["cristal"]),
        o_roca,
        datos["semilla"] + 1000,
        3,
        largo,
    )
    print(
        f"  Geoda {nombre}: roca {t1}, cristales {t2}, base {t3}, grietas {t4} + {t5} triángulos"
    )
    objetos = [obj_roca, obj_cris, obj_base, obj_g1, obj_g2]
    if runas:
        obj_r, t6 = baldositas("Runas", caras_runas(roca), lado, mats.get("runas", mats["cristal"]), o_roca)
        print(f"  Geoda {nombre}: runas {t6} triángulos")
        objetos.append(obj_r)
    return objetos


# ---------------------------------------------------------------------------------------------
# Gemas (formas lisas talladas; 2 studs de alto)


def bm_prisma(bm, lados, radio, z0, z1, punta_arriba, punta_abajo, giro=0.0):
    anillo0 = []
    anillo1 = []
    for i in range(lados):
        a = giro + 2 * math.pi * i / lados
        anillo0.append(bm.verts.new((radio * math.cos(a), radio * math.sin(a), z0)))
        anillo1.append(bm.verts.new((radio * math.cos(a), radio * math.sin(a), z1)))
    for i in range(lados):
        j = (i + 1) % lados
        bm.faces.new([anillo0[i], anillo0[j], anillo1[j], anillo1[i]])
    arriba = bm.verts.new((0, 0, z1 + punta_arriba))
    abajo = bm.verts.new((0, 0, z0 - punta_abajo))
    for i in range(lados):
        j = (i + 1) % lados
        bm.faces.new([anillo1[i], anillo1[j], arriba])
        bm.faces.new([anillo0[j], anillo0[i], abajo])


def gema_comun(alto):
    # pepita de cubitos
    celdas = {(x, y, z) for x in range(3) for y in range(3) for z in range(3)}
    for esquina in [(0, 0, 0), (2, 2, 0), (0, 2, 2), (2, 0, 2), (2, 2, 2)]:
        celdas.discard(esquina)
    celdas |= {(1, 1, 3), (3, 1, 1)}
    lado = alto / 5
    return voxeles("Gema", celdas, lado, None, origen=(-1.5 * lado, -1.5 * lado, 0))


def gema_rara(alto):
    bm = bmesh.new()
    bm_prisma(bm, 6, alto * 0.22, alto * 0.25, alto * 0.72, alto * 0.28, alto * 0.25)
    return objeto_desde_bmesh("Gema", bm, None)


def gema_epica(alto):
    bm = bmesh.new()
    bm_prisma(bm, 8, alto * 0.38, alto * 0.48, alto * 0.52, alto * 0.48, alto * 0.48)
    return objeto_desde_bmesh("Gema", bm, None)


def gema_legendaria(alto):
    # talla brillante: mesa, corona y pabellón
    bm = bmesh.new()
    lados = 10
    r_cintura, r_mesa = alto * 0.48, alto * 0.28
    z_punta, z_cintura, z_mesa = 0.0, alto * 0.55, alto * 0.82
    cintura = []
    mesa = []
    for i in range(lados):
        a = 2 * math.pi * i / lados
        cintura.append(bm.verts.new((r_cintura * math.cos(a), r_cintura * math.sin(a), z_cintura)))
        b = a + math.pi / lados
        mesa.append(bm.verts.new((r_mesa * math.cos(b), r_mesa * math.sin(b), z_mesa)))
    punta = bm.verts.new((0, 0, z_punta))
    for i in range(lados):
        j = (i + 1) % lados
        bm.faces.new([cintura[j], cintura[i], punta])
        bm.faces.new([cintura[i], cintura[j], mesa[i]])
        bm.faces.new([mesa[i], cintura[j], mesa[j]])
    bm.faces.new(mesa)
    return objeto_desde_bmesh("Gema", bm, None)


def gema_mitica(alto):
    # racimo: un cristal alto y cuatro más chicos inclinados alrededor
    bm = bmesh.new()
    bm_prisma(bm, 6, alto * 0.14, alto * 0.08, alto * 0.7, alto * 0.3, alto * 0.08)
    for i in range(4):
        tmp = bmesh.new()
        bm_prisma(tmp, 6, alto * 0.09, 0, alto * 0.32, alto * 0.16, alto * 0.05, giro=0.3)
        ang = math.pi / 2 * i + 0.4
        for v in tmp.verts:
            v.co.rotate(_rot_x(0.45))
            v.co.rotate(_rot_z(ang))
            v.co.z += alto * 0.08
        malla = bpy.data.meshes.new("tmp")
        tmp.to_mesh(malla)
        tmp.free()
        bm.from_mesh(malla)
        bpy.data.meshes.remove(malla)
    return objeto_desde_bmesh("Gema", bm, None)


def _rot_x(a):
    from mathutils import Matrix

    return Matrix.Rotation(a, 3, "X")


def _rot_z(a):
    from mathutils import Matrix

    return Matrix.Rotation(a, 3, "Z")


GEMAS = {
    "Comun": (gema_comun, "#E8E3F5"),
    "Raro": (gema_rara, "#D9534F"),
    "Epico": (gema_epica, "#A45CFF"),
    "Legendario": (gema_legendaria, "#22D07A"),
    "Mitico": (gema_mitica, "#9DFF3C"),
}


# ---------------------------------------------------------------------------------------------
# Picos (pixel art extruido: el mango vertical, la cabeza arriba)

# Cada dibujo va de arriba hacia abajo. c = cabeza, m = mango, d = detalle (otro color).
# Las filas que faltan abajo se completan con el mango.
PICOS = {
    "Madera": (
        [".....cccccc.....", "...cccccccccc...", ".ccccccmmcccccc.", "cccc...mm...cccc", "cc.....mm.....cc"],
        2,
        ("#8B5A2B", "#C08A4E", None),
    ),
    "Piedra": (
        [
            "....cccccccc....",
            "..cccccccccccc..",
            ".ccccccmmcccccc.",
            "cccc...mm...cccc",
            "ccc....mm....ccc",
            "cc.....mm.....cc",
        ],
        2,
        ("#8B5A2B", "#8D939C", None),
    ),
    "Hierro": (
        [
            "....cccccccc....",
            "..cccccccccccc..",
            ".ccccccmmcccccc.",
            "cccc...mm...cccc",
            "cc.....mm.....cc",
            "c......mm......c",
            "c......mm......c",
        ],
        2,
        ("#3E3A39", "#D8DEE6", None),
    ),
    "Oro": (
        [
            "....cccccccc....",
            "..cccccddccccc..",
            ".ccccccddcccccc.",
            "cccc...mm...cccc",
            "cc.....mm.....cc",
            "c......mm......c",
            "c......mm......c",
        ],
        3,
        ("#3E3A39", "#FFC83D", "#2EF2FF"),
    ),
    "Cosmico": (
        [
            "d......dd......d",
            ".d..cccccccc..d.",
            "..ccccdddddcccc.",
            ".ccccccddcccccc.",
            "cccc...mm...cccc",
            "cc.....mm.....cc",
            "c......mm......c",
            "d......mm......d",
        ],
        3,
        ("#26224A", "#7A4DFF", "#7CF5FF"),
    ),
}
FILAS_PICO = 18  # alto total en cubitos
LADO_PICO = 4.5 * STUD / FILAS_PICO


def armar_pico(nombre, mats):
    dibujo, grosor, _ = PICOS[nombre]
    filas = list(dibujo) + [".......mm......."] * (FILAS_PICO - len(dibujo))
    celdas = {"c": set(), "m": set(), "d": set()}
    ancho = len(filas[0])
    for i, fila in enumerate(filas):
        z = FILAS_PICO - 1 - i
        for x, letra in enumerate(fila):
            if letra in celdas:
                # el mango es de 2 de grosor; la cabeza y el detalle, de `grosor`
                g = 2 if letra == "m" else grosor
                for y in range(g):
                    celdas[letra].add((x, y - g // 2, z))
    origen = (-ancho / 2 * LADO_PICO, 0, 0)
    objetos = []
    for letra, parte in (("m", "Mango"), ("c", "Cabeza"), ("d", "Detalle")):
        if celdas[letra]:
            obj, t = voxeles(parte, celdas[letra], LADO_PICO, mats[parte], origen=origen)
            objetos.append(obj)
            print(f"  Pico {nombre} {parte}: {t} triángulos")
    return objetos


# ---------------------------------------------------------------------------------------------
# Eventos y exhibición (grupos 6 y 7)

# La Geoda Ancestral: como el Jefe pero de 18 studs, con más cristales y runas.
ANCESTRAL = {"diametro": 18.0, "radio": 9, "cristales": 14, "semilla": 77}


def celdas_columna(r, alto):
    """Columna octogonal de cubitos (r = radio en celdas)."""
    celdas = set()
    for x in range(-r, r):
        for y in range(-r, r):
            cx, cy = x + 0.5, y + 0.5
            if abs(cx) + abs(cy) <= r * 1.35:
                for z in range(alto):
                    celdas.add((x, y, z))
    return celdas


def armar_vitrina(mats):
    """Pedestal de la vitrina: columna de piedra clara, bordes dorados y una placa al frente.
    5 studs de ancho y 4 de alto (la estatua flota arriba). En el juego, el tag "Vitrina" va en
    la parte "Pedestal"."""
    r, alto = 5, 8
    lado = 5 * STUD / (2 * r)
    columna = celdas_columna(r, alto - 2)  # entre los dos bordes, sin pisarlos
    borde = {(x, y, z) for x, y, z in celdas_columna(r + 1, 2)}
    borde |= {(x, y, z + alto) for x, y, z in celdas_columna(r + 1, 2)}
    placa = {(x, -r - 1, z) for x in range(-2, 2) for z in range(3, 6)}
    o1, t1 = voxeles("Pedestal", columna, lado, mats["pedestal"], origen=(0, 0, 2 * lado))
    o2, t2 = voxeles("Borde", borde, lado, mats["borde"])
    o3, t3 = voxeles("Placa", placa, lado, mats["borde"], origen=(0, 0, 0))
    print(f"  Vitrina: pedestal {t1}, borde {t2}, placa {t3} triángulos")
    return [o1, o2, o3]


def armar_tablero(mats):
    """Tablero de la clasificación: marco de cubitos, pantalla (ahí va el SurfaceGui y el tag
    "TableroClasificacion") y un remate dorado arriba. 14 x 10 studs."""
    ancho, alto = 28, 20  # celdas de 0,5 stud
    lado = 0.5 * STUD
    marco = set()
    for x in range(ancho):
        for z in range(alto):
            if x < 1 or x >= ancho - 1 or z < 1 or z >= alto - 1:
                for y in range(2):
                    marco.add((x - ancho // 2, y, z))
    remate = set()
    for x in range(-5, 5):
        for z in range(alto, alto + 3 - abs(x) // 2):
            remate.add((x, 0, z))
            remate.add((x, 1, z))
    o1, t1 = voxeles("Marco", marco, lado, mats["marco"])
    o2, t2 = voxeles("Remate", remate, lado, mats["borde"])
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= (ancho - 2) * lado
        v.co.y *= lado * 0.6
        v.co.z *= (alto - 2) * lado
        v.co.z += alto * lado / 2
        v.co.y += lado * 0.9
    o3, t3 = objeto_desde_bmesh("Pantalla", bm, mats["pantalla"])
    print(f"  Tablero: marco {t1}, remate {t2}, pantalla {t3} triángulos")
    return [o1, o2, o3]


def cristal_lluvia(alto):
    """Cristal de la Lluvia de Cristales: un prisma de 6 lados con punta, 2,4 studs."""
    bm = bmesh.new()
    bm_prisma(bm, 6, alto * 0.2, alto * 0.15, alto * 0.7, alto * 0.3, alto * 0.15)
    return objeto_desde_bmesh("CristalLluvia", bm, None)


def bomba_lava(mat):
    """Bomba de lava (Erupción): bolita de cubitos con el mapa UV de la textura de lava."""
    r = 3
    celdas = set()
    for x in range(-r, r):
        for y in range(-r, r):
            for z in range(-r, r):
                if (x + 0.5) ** 2 + (y + 0.5) ** 2 + (z + 0.5) ** 2 <= r * r + ruido(x, y, z, 0.6, 5) * 3:
                    celdas.add((x, y, z + r))
    lado = 2 * STUD / (2 * r)
    return voxeles("BombaLava", celdas, lado, mat, atlas=True)


def exportar_eventos_y_exhibicion():
    mats = {
        "roca": material("Roca", COLOR_ROCA),
        "cristal": material("Cristales", COLOR_CRISTAL),
        "base": material("Base", COLOR_BASE),
        "grieta": material("Grietas", "#FF6A1A"),
        "grieta2": material("Grietas2", "#2EF2FF"),
        "runas": material("Runas", "#FFD23F"),
        "pedestal": material("Pedestal", "#E3E8F2"),
        "borde": material("Borde", "#FFC93C", metal=0.6, rugoso=0.3),
        "marco": material("Marco", "#7A2FE0"),
        "pantalla": material("Pantalla", "#1B1F3B"),
    }
    objetos = armar_geoda("Ancestral", ANCESTRAL, mats, runas=True)
    exportar(objetos, "Geoda_Ancestral.fbx")
    for o in objetos:
        bpy.data.objects.remove(o)
    for nombre, crear, archivo in (
        ("Vitrina", armar_vitrina, "Vitrina.fbx"),
        ("Tablero", armar_tablero, "Tablero.fbx"),
    ):
        objetos = crear(mats)
        exportar(objetos, archivo)
        for o in objetos:
            bpy.data.objects.remove(o)
    cristal, t = cristal_lluvia(2.4 * STUD)
    cristal.data.materials.append(material("CristalLluvia", "#7CF5FF"))
    print(f"  Cristal de lluvia: {t} triángulos")
    exportar([cristal], "CristalLluvia.fbx")
    bpy.data.objects.remove(cristal)
    bomba, t = bomba_lava(material("BombaLava", "#FF6A1A"))
    print(f"  Bomba de lava: {t} triángulos")
    exportar([bomba], "BombaLava.fbx")
    bpy.data.objects.remove(bomba)
    # Estatuas: la misma forma de cada gema, de 3,5 studs, con el nombre de la rareza
    for rareza, (crear, color) in GEMAS.items():
        obj, t = crear(3.5 * STUD)
        obj.data.materials.clear()
        obj.data.materials.append(material("Estatua_" + rareza, color, rugoso=0.15))
        obj.name = rareza
        exportar([obj], f"Estatua_{rareza}.fbx")
        bpy.data.objects.remove(obj)


# ---------------------------------------------------------------------------------------------
# Exportar


def exportar(objetos, archivo):
    FBX.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objetos:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objetos[0]
    bpy.ops.export_scene.fbx(
        filepath=str(FBX / archivo),
        use_selection=True,
        object_types={"MESH"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        use_mesh_modifiers=True,
        bake_space_transform=True,
        add_leaf_bones=False,
    )


def exportar_todo():
    limpiar_escena()
    hacer_texturas()
    mats = {
        "roca": material("Roca", COLOR_ROCA),
        "cristal": material("Cristales", COLOR_CRISTAL),
        "base": material("Base", COLOR_BASE),
        "grieta": material("Grietas", "#FF6A1A"),
        "grieta2": material("Grietas2", "#2EF2FF"),
    }
    for nombre, datos in GEODAS.items():
        objetos = armar_geoda(nombre, datos, mats)
        exportar(objetos, f"Geoda_{nombre}.fbx")
        for o in objetos:
            bpy.data.objects.remove(o)
    # Anillo de la Lava, al tamaño de la Mediana (el juego lo escala según la roca)
    mediana = GEODAS["Mediana"]
    lado = mediana["diametro"] * STUD / (2 * mediana["radio"])
    anillo, t = voxeles("Anillo", celdas_anillo(mediana["radio"]), lado, material("Anillo", "#FF8C00"))
    print(f"  Anillo: {t} triángulos")
    exportar([anillo], "Geoda_Anillo.fbx")
    bpy.data.objects.remove(anillo)
    for rareza, (crear, color) in GEMAS.items():
        obj, t = crear(2 * STUD)
        obj.data.materials.clear()
        obj.data.materials.append(material("Gema_" + rareza, color, rugoso=0.15))
        obj.name = "Gema_" + rareza
        print(f"  Gema {rareza}: {t} triángulos")
        exportar([obj], f"Gema_{rareza}.fbx")
        bpy.data.objects.remove(obj)
    for nombre, (_, _, colores) in PICOS.items():
        mats_pico = {
            "Mango": material(f"{nombre}_Mango", colores[0]),
            "Cabeza": material(f"{nombre}_Cabeza", colores[1], metal=0.3),
            "Detalle": material(f"{nombre}_Detalle", colores[2] or "#FFFFFF"),
        }
        objetos = armar_pico(nombre, mats_pico)
        exportar(objetos, f"Pico_{nombre}.fbx")
        for o in objetos:
            bpy.data.objects.remove(o)
    exportar_eventos_y_exhibicion()


# ---------------------------------------------------------------------------------------------
# Renders de muestra


def escena_render(ancho=1600, alto=900):
    escena = bpy.context.scene
    escena.render.engine = "CYCLES"
    escena.cycles.device = "CPU"
    escena.cycles.samples = 48
    escena.cycles.use_denoising = True
    escena.render.resolution_x = ancho
    escena.render.resolution_y = alto
    escena.render.film_transparent = False
    # "Standard": colores saturados como en Roblox (AgX los apaga)
    escena.view_settings.view_transform = "Standard"
    mundo = bpy.data.worlds.new("Cielo")
    escena.world = mundo
    if bpy.app.version < (5, 0, 0) and not mundo.use_nodes:
        mundo.use_nodes = True
    fondo = mundo.node_tree.nodes.get("Background") or mundo.node_tree.nodes.new(
        "ShaderNodeBackground"
    )
    fondo.inputs["Color"].default_value = (*hex_a_rgb(COLOR_CIELO), 1)
    fondo.inputs["Strength"].default_value = 1.0
    salida = mundo.node_tree.nodes.get("World Output") or mundo.node_tree.nodes.new(
        "ShaderNodeOutputWorld"
    )
    mundo.node_tree.links.new(fondo.outputs["Background"], salida.inputs["Surface"])

    sol = bpy.data.lights.new("Sol", "SUN")
    sol.energy = 4.5
    sol.angle = math.radians(8)
    obj_sol = bpy.data.objects.new("Sol", sol)
    obj_sol.rotation_euler = (math.radians(50), math.radians(10), math.radians(35))
    escena.collection.objects.link(obj_sol)

    # piso con cuadritos (los studs del piso de las capturas)
    bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, 0))
    piso = bpy.context.active_object
    m = material("Piso", COLOR_PISO, rugoso=0.8)
    nodos = m.node_tree.nodes
    tablero = nodos.new("ShaderNodeTexChecker")
    tablero.inputs["Scale"].default_value = 60 / STUD / 2
    tablero.inputs["Color1"].default_value = (*hex_a_rgb(COLOR_PISO), 1)
    tablero.inputs["Color2"].default_value = (*hex_a_rgb("#74CF4E"), 1)
    m.node_tree.links.new(tablero.outputs["Color"], nodos["Principled BSDF"].inputs["Base Color"])
    piso.data.materials.append(m)
    return escena


def camara(escena, objetivo, distancia, altura, lente=50, giro=-25):
    cam = bpy.data.cameras.new("Camara")
    cam.lens = lente
    obj = bpy.data.objects.new("Camara", cam)
    escena.collection.objects.link(obj)
    a = math.radians(giro)
    obj.location = (
        objetivo[0] + distancia * math.sin(a),
        objetivo[1] - distancia * math.cos(a),
        objetivo[2] + altura,
    )
    direccion = Vector(objetivo) - obj.location
    obj.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
    escena.camera = obj


def etiqueta(texto, x, y, z=0.02, tam=0.35, color="#FFFFFF"):
    curva = bpy.data.curves.new("Texto", "FONT")
    curva.body = texto
    curva.size = tam
    curva.align_x = "CENTER"
    curva.extrude = 0.01
    obj = bpy.data.objects.new("Texto_" + texto, curva)
    obj.location = (x, y, z)
    obj.data.materials.append(material("Texto_" + color, color, rugoso=0.4))
    bpy.context.scene.collection.objects.link(obj)
    return obj


def sin_grietas(objetos):
    """Las geodas normales no muestran las grietas (en el juego quedan invisibles)."""
    for o in list(objetos):
        if o.name.startswith("Grietas"):
            objetos.remove(o)
            bpy.data.objects.remove(o)
    return objetos


def mover(objetos, x, y=0.0, giro=0.0):
    for o in objetos:
        o.location.x += x
        o.location.y += y
        o.rotation_euler.z += giro


def luz_punto(x, y, z, color, energia):
    luz = bpy.data.lights.new("Brillo", "POINT")
    luz.color = hex_a_rgb(color)
    luz.energy = energia
    luz.shadow_soft_size = 0.3
    obj = bpy.data.objects.new("Brillo", luz)
    obj.location = (x, y, z)
    bpy.context.scene.collection.objects.link(obj)


def render(nombre):
    RENDERS.mkdir(parents=True, exist_ok=True)
    ajustes = bpy.context.scene.render.image_settings
    ajustes.file_format = "JPEG"  # livianas para git
    ajustes.quality = 88
    bpy.context.scene.render.filepath = str(RENDERS / f"{nombre}.jpg")
    bpy.ops.render.render(write_still=True)
    print(f"  Render {nombre}.jpg")


def mats_zona(roca, cristal, base=COLOR_BASE, metal=0.0, brillo=None, fuerza=0.0, roca_brillo=None):
    return {
        "roca": material(f"R{roca}{roca_brillo}", roca, metal=metal, rugoso=0.35 if metal else 0.7,
                         brillo=roca_brillo, fuerza_brillo=fuerza * 0.3 if roca_brillo else 0),
        "cristal": material(f"C{cristal}{fuerza}", cristal, rugoso=0.2, brillo=brillo,
                            fuerza_brillo=fuerza),
        "base": material("B" + base, base),
    }


def render_tamanos():
    limpiar_escena()
    escena = escena_render()
    mats = mats_zona(COLOR_ROCA, COLOR_CRISTAL)
    anchos = [d["diametro"] * STUD * 1.45 for d in GEODAS.values()]
    total = sum(anchos) + 0.5 * (len(anchos) - 1)
    x = -total / 2
    for (nombre, datos), ancho in zip(GEODAS.items(), anchos):
        x += ancho / 2
        mover(sin_grietas(armar_geoda(nombre, datos, mats)), x, giro=0.4)
        etiqueta({"Pequena": "Pequeña", "Jefe": "JEFE"}.get(nombre, nombre), x, -ancho / 2 - 0.3)
        x += ancho / 2 + 0.5
    camara(escena, (-0.6, 0, 1.2), 15.5, 4.2, lente=40, giro=-12)
    render("geodas_tamanos")


def material_textura(nombre, textura, brillo=0.0, metal=0.0, rugoso=0.6):
    """Material con una de las texturas de modificador (píxeles nítidos, sin suavizar)."""
    m = material(nombre, "#FFFFFF", metal=metal, rugoso=rugoso)
    nodos = m.node_tree.nodes
    imagen = nodos.new("ShaderNodeTexImage")
    imagen.image = bpy.data.images.load(str(TEXTURAS / f"{textura}.png"), check_existing=True)
    imagen.interpolation = "Closest"
    bsdf = nodos["Principled BSDF"]
    m.node_tree.links.new(imagen.outputs["Color"], bsdf.inputs["Base Color"])
    if brillo:
        m.node_tree.links.new(imagen.outputs["Color"], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = brillo
    return m


# (texto, textura, color de Grietas y cristales, color de Grietas2, anillo de lava, metal)
EXOTICAS = [
    ("Lava x3", "Lava", "#FF6A1A", "#FFB300", True, 0.0),
    ("Neón x5", "Neon", "#2EF2FF", "#FF4DF0", False, 0.0),
    ("Dorada x10", "Midas", "#FFD23F", "#FFF3B0", False, 0.7),
    ("Vacío x25", "Vacio", "#9B4DFF", "#FFFFFF", False, 0.0),
]
COMBOS = [
    ("Magma Eléctrico x15", "LavaNeon", "#FF6A1A", "#2EF2FF", True, 0.0),
    ("Relámpago Dorado x50", "MidasNeon", "#FFD23F", "#2EF2FF", False, 0.6),
    ("Eclipse de Lava x75", "VacioLava", "#9B4DFF", "#FF6A1A", True, 0.0),
    ("Vacío Dorado x250", "VacioMidas", "#9B4DFF", "#FFD23F", False, 0.3),
]


def geoda_exotica(i, x, variante):
    texto, textura, c1, c2, anillo, metal = variante
    brillo_roca = 0.9 if "Neon" in textura else (0.05 if "Lava" in textura else 0.2)
    mats = {
        "roca": material_textura(f"Roca_{textura}", textura, brillo=brillo_roca, metal=metal),
        "cristal": material(f"Cris_{textura}", c1, rugoso=0.2, brillo=c1, fuerza_brillo=8),
        "base": material("B" + COLOR_BASE, COLOR_BASE),
        "grieta": material(f"G1_{textura}", c1, brillo=c1, fuerza_brillo=10),
        "grieta2": material(f"G2_{textura}", c2, brillo=c2, fuerza_brillo=10),
    }
    datos = GEODAS["Mediana"]
    objetos = armar_geoda(f"Mediana-{textura}", datos, mats)
    if anillo:
        lado = datos["diametro"] * STUD / (2 * datos["radio"])
        aro, _ = voxeles(
            "Anillo",
            celdas_anillo(datos["radio"]),
            lado,
            material_textura("Anillo_lava", "Lava", brillo=0.6),
        )
        aro.location.z = datos["diametro"] * STUD * 0.55
        aro.rotation_euler.x = 0.32
        objetos.append(aro)
    mover(objetos, x, giro=0.35 * i)
    etiqueta(texto, x, -1.3, tam=0.24)
    luz_punto(x, -0.6, 1.1, c1, 15)
    luz_punto(x + 0.3, 0.5, 0.5, c2, 10)


def render_exoticas():
    limpiar_escena()
    escena = escena_render()
    normal = armar_geoda("Mediana-normal", GEODAS["Mediana"], mats_zona(COLOR_ROCA, COLOR_CRISTAL))
    mover(sin_grietas(normal), -4.4)
    etiqueta("Normal", -4.4, -1.3, tam=0.24)
    for i, variante in enumerate(EXOTICAS):
        geoda_exotica(i, (i - 1) * 2.2 + 0.0, variante)
    camara(escena, (-0.6, 0, 0.6), 14.0, 3.2, lente=45, giro=-10)
    render("geodas_exoticas")


def render_combos():
    limpiar_escena()
    escena = escena_render()
    for i, variante in enumerate(COMBOS):
        geoda_exotica(i, (i - 1.5) * 2.5, variante)
    camara(escena, (0, 0, 0.6), 12.5, 3.0, lente=45, giro=-10)
    render("geodas_combinaciones")


def render_zonas():
    limpiar_escena()
    escena = escena_render()
    zonas = [
        ("1 Pradera", "#6E7487", "#C77DFF"),
        ("2 Dunas", "#B07A4A", "#FFB627"),
        ("3 Glaciar", "#7FA6C9", "#3D7BFF"),
        ("4 Volcán", "#4A3338", "#FF2E4D"),
        ("5 Abismo", "#2E2A5C", "#7CF5FF"),
    ]
    datos = GEODAS["Mediana"]
    for i, (texto, roca, cristal) in enumerate(zonas):
        x = (i - 2) * 2.0
        mover(sin_grietas(armar_geoda(f"Mediana-{i}", datos, mats_zona(roca, cristal))), x, giro=0.5 * i)
        etiqueta(texto, x, -1.25)
    camara(escena, (-0.4, 0, 0.6), 13.0, 3.2, lente=45, giro=-12)
    render("geodas_zonas")


def render_gemas():
    limpiar_escena()
    escena = escena_render(1600, 700)
    nombres = {
        "Comun": "Común",
        "Raro": "Raro",
        "Epico": "Épico",
        "Legendario": "Legendario",
        "Mitico": "Mítico",
    }
    for i, (rareza, (crear, color)) in enumerate(GEMAS.items()):
        obj, _ = crear(2 * STUD * 1.6)
        obj.data.materials.clear()
        obj.data.materials.append(
            material("G" + rareza, color, rugoso=0.08, brillo=color, fuerza_brillo=0.6)
        )
        x = (i - 2) * 1.3
        mover([obj], x, giro=0.5)
        etiqueta(nombres[rareza], x, -0.75, tam=0.22)
    camara(escena, (-0.2, 0, 0.4), 8.5, 2.2, lente=50, giro=-10)
    render("gemas")


def render_picos():
    limpiar_escena()
    escena = escena_render(1600, 800)
    nombres = {"Madera": "Madera", "Piedra": "Piedra", "Hierro": "Hierro", "Oro": "Oro", "Cosmico": "Cósmico"}
    for i, (nombre, (_, _, colores)) in enumerate(PICOS.items()):
        mats = {
            "Mango": material(f"{nombre}_Mango", colores[0]),
            "Cabeza": material(f"{nombre}_Cabeza", colores[1], metal=0.4, rugoso=0.4),
            "Detalle": material(
                f"{nombre}_Detalle", colores[2] or "#FFFFFF", brillo=colores[2], fuerza_brillo=4
            ),
        }
        x = (i - 2) * 1.45
        mover(armar_pico(nombre, mats), x)
        etiqueta(nombres[nombre], x, -0.45, tam=0.26)
    camara(escena, (0, 0, 0.5), 11.0, 2.4, lente=50, giro=-6)
    render("picos")


def render_eventos_y_exhibicion():
    limpiar_escena()
    escena = escena_render()
    # Geoda Ancestral del Vacío con runas doradas y la corona de cristales
    mats = {
        "roca": material_textura("Roca_Vacio_A", "Vacio", brillo=0.2),
        "cristal": material("CrisA", "#C77DFF", rugoso=0.2, brillo="#C77DFF", fuerza_brillo=8),
        "base": material("B" + COLOR_BASE, COLOR_BASE),
        "grieta": material("G1A", "#9B4DFF", brillo="#9B4DFF", fuerza_brillo=10),
        "grieta2": material("G2A", "#FFD23F", brillo="#FFD23F", fuerza_brillo=10),
        "runas": material("RunasA", "#FFD23F", brillo="#FFD23F", fuerza_brillo=12),
    }
    mover(armar_geoda("Ancestral", ANCESTRAL, mats, runas=True), -5.0, y=3.0, giro=0.4)
    luz_punto(-5.0, 0.0, 2.5, "#9B4DFF", 120)
    etiqueta("GEODA ANCESTRAL", -5.0, -0.6, tam=0.4)
    # vitrina con una estatua Mítica arriba
    mv = {
        "pedestal": material("PedR", "#E3E8F2"),
        "borde": material("BorR", "#FFC93C", metal=0.6, rugoso=0.3),
    }
    mover(armar_vitrina(mv), 1.2)
    est, _ = gema_mitica(3.5 * STUD)
    est.data.materials.clear()
    est.data.materials.append(material("EstR", "#9DFF3C", rugoso=0.1, brillo="#9DFF3C", fuerza_brillo=1.5))
    mover([est], 1.2)
    est.location.z += 4 * STUD + 0.35
    etiqueta("Vitrina", 1.2, -1.2, tam=0.28)
    # tablero
    mt = {"marco": material("MarR", "#7A2FE0"), "borde": mv["borde"], "pantalla": material("PanR", "#20243F")}
    tablero = armar_tablero(mt)
    mover(tablero, 4.6, y=0.8, giro=-0.35)
    etiqueta("Tablero", 4.6, -1.0, tam=0.28)
    # cristales de la lluvia y bombas de lava
    for i, (x, y) in enumerate([(-0.6, -1.6), (0.2, -2.1), (2.6, -1.9)]):
        c, _ = cristal_lluvia(2.4 * STUD)
        c.data.materials.append(material(f"CL{i}", "#7CF5FF", rugoso=0.1, brillo="#7CF5FF", fuerza_brillo=3))
        mover([c], x, y=y, giro=i)
    for i, (x, y) in enumerate([(-1.6, -2.4), (3.4, -2.6)]):
        b, _ = bomba_lava(material_textura(f"BL{i}", "Lava", brillo=0.8))
        mover([b], x, y=y, giro=i)
    etiqueta("Cristales y bombas de lava", 1.0, -2.9, tam=0.22)
    camara(escena, (-0.6, 0.8, 1.6), 19.0, 4.2, lente=40, giro=-8)
    render("eventos_y_exhibicion")


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    print("Exportando FBX a", FBX)
    exportar_todo()
    if "--solo-eventos" in argumentos:
        render_eventos_y_exhibicion()
    elif "--sin-renders" not in argumentos:
        print("Renders a", RENDERS)
        render_tamanos()
        render_exoticas()
        render_combos()
        render_zonas()
        render_gemas()
        render_picos()
        render_eventos_y_exhibicion()
    print("Listo")
