"""Piedras que le pueden tocar al jugador (12 por zona, 2 por rareza), estilo vóxel como modelos.py.

Cada piedra es un conjunto de cubitos de colores: sale una malla por color (un material por
malla) y, si tiene partes que giran u orbitan, cada una va aparte. Pivote en el centro.

Cómo correrlo (desde la raíz del repositorio):
  blender -b --factory-startup --python forja-rapida/arte/scripts/gemas.py -- Cuarzo Jaspe
  Opciones después de los nombres:
    --exportar   suma las piedras al FBX de su zona (arte/fbx/Gemas_ZonaN.fbx)
    --icono      render cuadrado de 512 px con fondo transparente (arte/iconos/gemas/<Nombre>.png)
  Sin opciones: solo render de frente y de costado en arte/renders/gema_<Nombre>.jpg.
"""

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402

import bmesh  # noqa: E402
import modelos as m  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

ICONOS = m.ARTE / "iconos" / "gemas"

# Solo las piedras que Juani ya aprobó entran al FBX de su zona
APROBADAS = {"Cuarzo", "Jaspe", "Amatista", "AgataMusgosa", "Esmeralda", "TurmalinaRosa", "CorazondePradera", "DiamanteFloral", "JadeArcoiris", "TreboldeCristal", "AuroraVerde", "SemilladelMundo", "Arenisca", "Ambar", "Citrino", "OjodeTigre", "TopacioImperial", "Cornalina"}

# Piedras con alto propio (studs) y pivote en el centro de la base en vez del centro de la caja
ALTO = {"Cuarzo": 2.5, "Jaspe": 2.5, "Amatista": 3.0, "AgataMusgosa": 3.0, "Esmeralda": 3.5, "TurmalinaRosa": 3.5, "CorazondePradera": 4.0, "DiamanteFloral": 4.0, "JadeArcoiris": 4.5, "TreboldeCristal": 4.5, "AuroraVerde": 5.0, "SemilladelMundo": 5.0, "Arenisca": 2.5, "Ambar": 2.5, "Citrino": 3.0, "OjodeTigre": 3.0, "TopacioImperial": 3.5, "Cornalina": 3.5}
PIVOTE_BASE = {"Cuarzo", "Jaspe", "Amatista", "AgataMusgosa", "Esmeralda", "TurmalinaRosa", "CorazondePradera", "DiamanteFloral", "JadeArcoiris", "TreboldeCristal", "AuroraVerde", "SemilladelMundo", "Arenisca", "Ambar", "Citrino", "OjodeTigre", "TopacioImperial", "Cornalina"}
# Topes de triángulos propios (pisan el de la rareza)
TOPE = {"Esmeralda": 4000, "TurmalinaRosa": 4000, "CorazondePradera": 6000, "DiamanteFloral": 6000, "JadeArcoiris": 8000, "TreboldeCristal": 8000, "AuroraVerde": 10000, "SemilladelMundo": 10000, "TopacioImperial": 4000, "Cornalina": 4000}

# Alto (studs) y tope de triángulos por rareza
RAREZAS = {
    "Comun": (1.5, 1500),
    "Rara": (2.0, 2500),
    "Epica": (2.5, 1200),
    "Legendaria": (3.0, 2000),
    "Mitica": (3.5, 3000),
    "Celestial": (4.0, 4000),
}


# ---------------------------------------------------------------------------------------------
# Formas (cada una devuelve {celda: clave de color}; z hacia arriba)


def h(x, y, z, s):
    """Número fijo entre 0 y 1 para una celda (azar repetible)."""
    v = (x * 73856093 ^ y * 19349663 ^ z * 83492791 ^ s * 2654435761) & 0xFFFFFFFF
    return v / 0xFFFFFFFF


def _sumar(bm, otro):
    """Copia la malla de un bmesh temporal dentro de bm."""
    malla = bpy.data.meshes.new("tmp")
    otro.to_mesh(malla)
    otro.free()
    bm.from_mesh(malla)
    bpy.data.meshes.remove(malla)


def _casco(bm, puntos):
    """Malla cerrada que envuelve los puntos (casco convexo), con las caras planas juntadas."""
    vs = [bm.verts.new(p) for p in puntos]
    r = bmesh.ops.convex_hull(bm, input=vs)
    sobran = list({v for v in r["geom_interior"] + r["geom_unused"] if isinstance(v, bmesh.types.BMVert)})
    bmesh.ops.delete(bm, geom=sobran, context="VERTS")
    bmesh.ops.dissolve_limit(bm, angle_limit=math.radians(2), verts=bm.verts, edges=bm.edges)


def _objeto(nombre, bm, color, rugoso=0.45, brillo=None, fuerza=0.0, alfa=1.0):
    bmesh.ops.triangulate(bm, faces=bm.faces)
    mat = m.material(nombre, color, rugoso=rugoso, brillo=brillo, fuerza_brillo=fuerza)
    if alfa < 1:
        mat.node_tree.nodes["Principled BSDF"].inputs["Alpha"].default_value = alfa
        if hasattr(mat, "surface_render_method"):
            mat.surface_render_method = "BLENDED"
    obj, _ = m.objeto_desde_bmesh(nombre, bm, mat)
    return obj


def _cristalito(bm, base, direccion, radio, largo, giro):
    """Prisma de 6 lados con punta, apoyado en 'base' y apuntando hacia 'direccion'."""
    tmp = bmesh.new()
    m.bm_prisma(tmp, 6, radio, 0, largo, radio * 1.6, 0, giro=giro)
    rot = Vector((0, 0, 1)).rotation_difference(direccion.normalized()).to_matrix().to_4x4()
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(base) @ rot, verts=tmp.verts)
    _sumar(bm, tmp)


def _grieta(bm, centro, normal, tangente, largo, semilla, ancho=0.035):
    """Zigzag de 3 tramos finitos pegado a una cara."""
    rng = random.Random(semilla)
    b = normal.cross(tangente).normalized()
    pts = [
        centro + tangente * (largo * (i / 3 - 0.5)) + b * (rng.uniform(-0.12, 0.12) * largo) for i in range(4)
    ]
    for a, c in zip(pts, pts[1:]):
        d = c - a
        eje_x = d.normalized()
        eje_y = normal.cross(eje_x).normalized()
        rot = Matrix((eje_x, eje_y, normal)).transposed().to_4x4()
        esc = Matrix.Diagonal((d.length + 0.03, ancho, 0.03, 1))
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=1)
        bmesh.ops.transform(
            tmp, matrix=Matrix.Translation((a + c) / 2 + normal * 0.004) @ rot @ esc, verts=tmp.verts
        )
        _sumar(bm, tmp)


def bruto(nombre, d):
    """Piedra en bruto: trozo irregular con caras talladas que brillan, bisel claro en los bordes,
    3 tonos (claro arriba, oscuro abajo), grietas, vetas, cristalitos (uno transparente con un
    núcleo que brilla adentro) y tierra pegada en la base. 'd' trae los números de cada piedra.
    Medidas libres: armar_tallada() la escala."""
    rng = random.Random(d["semilla"])
    ax, ay, az, inclina = d["cuerpo"]
    zc = d.get("zc", 1.2)  # altura del centro del cuerpo (más bajo = apoya en la tierra)
    centro = Vector((0, 0, zc + 0.05))
    puntos = []
    for _ in range(16):
        a = rng.uniform(0, 2 * math.pi)
        z = rng.uniform(-1, 1)
        r = math.sqrt(1 - z * z)
        puntos.append(
            Vector((ax * r * math.cos(a), ay * r * math.sin(a), zc + az * z + inclina * r * math.cos(a)))
        )
    # cortes planos: cada punto que se pasa del plano se aplasta sobre él -> cara grande y plana
    cortes = [Vector(n).normalized() * dist for n, dist in d["cortes"]]
    for i, p in enumerate(puntos):
        for c in cortes:
            n = c.normalized()
            exceso = (p - centro).dot(n) - c.length
            if exceso > 0:
                p = p - n * exceso
        p.z = max(p.z, 0.35)
        puntos[i] = p
    bm = bmesh.new()
    _casco(bm, puntos)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    # tono de cada cara: 0 oscuro, 1 medio, 2 claro, 3 brillo (las talladas)
    tono = bm.faces.layers.int.new("tono")
    for f in bm.faces:
        n = f.normal
        if any(n.dot(c.normalized()) > 0.97 for c in cortes):
            f[tono] = 3
        elif n.z > 0.35:
            f[tono] = 2
        elif n.z < -0.15 or f.calc_center_median().z < 0.8:
            f[tono] = 0
        else:
            f[tono] = 1
    talladas = sorted(
        ((f.calc_center_median().copy(), f.normal.copy(), f.calc_area()) for f in bm.faces if f[tono] == 3),
        key=lambda c: -c[2],
    )
    r = bmesh.ops.bevel(
        bm, geom=list(bm.edges), offset=0.07, segments=1, profile=0.5, affect="EDGES", clamp_overlap=True
    )
    for f in r["faces"]:
        f[tono] = 2 if f.normal.z > -0.2 else 0  # bisel claro: marca los bordes
    objetos = []
    for i, sufijo in enumerate(("Oscuro", "Medio", "Claro", "Brillo")):
        color, rug, br, fu = d["tonos"][i]
        copia = bm.copy()
        capa = copia.faces.layers.int["tono"]
        bmesh.ops.delete(copia, geom=[f for f in copia.faces if f[capa] != i], context="FACES")
        objetos.append(_objeto(f"{nombre}_{sufijo}", copia, color, rug, br, fu))
    bm.free()

    # grietas finas sobre las 2 caras talladas más grandes
    bm = bmesh.new()
    for k, (c, n, area) in enumerate(talladas[:2]):
        t = n.cross(Vector((0.6, 0.3, 1)))
        if t.length < 0.1:
            t = Vector((1, 0, 0))
        _grieta(bm, c + t.normalized().cross(n) * 0.05, n, t.normalized(), math.sqrt(area) * 0.55, 10 + k)
    objetos.append(_objeto(f"{nombre}_Grieta", bm, d["grieta"], 0.6))

    # vetas: bandas anchas que cruzan las caras talladas en diagonal
    if d.get("veta"):
        bm = bmesh.new()
        for k, (c, n, area) in enumerate(talladas[: d["vetas"]]):
            t = n.cross(Vector((0.3, -0.5, 1)))
            if t.length < 0.1:
                t = Vector((1, 0, 0))
            _grieta(bm, c, n, t.normalized(), math.sqrt(area) * 1.15, 20 + k, ancho=0.11)
        objetos.append(_objeto(f"{nombre}_Veta", bm, d["veta"], 0.4))

    # cristalitos asomando y 1 transparente con un núcleo que brilla adentro
    def punto_en(direccion):
        dd = direccion.normalized()
        mejor = max(puntos, key=lambda p: (p - centro).normalized().dot(dd))
        return mejor.lerp(centro, 0.25), dd

    bm = bmesh.new()
    for direccion, radio, largo, giro in d["cristales"]:
        base, dd = punto_en(Vector(direccion))
        _cristalito(bm, base, dd, radio, largo, giro)
    color, br, fu = d["cristal"]
    objetos.append(_objeto(f"{nombre}_Cristal", bm, color, 0.2, br, fu))
    base, dd = punto_en(Vector(d["vidrio"]))
    bm = bmesh.new()
    _cristalito(bm, base, dd, 0.17, 0.55, 0.0)
    objetos.append(_objeto(f"{nombre}_Vidrio", bm, d["color_vidrio"], 0.05, alfa=0.45))
    bm = bmesh.new()
    _cristalito(bm, base + dd * 0.12, dd, 0.07, 0.3, 0.5)
    objetos.append(_objeto(f"{nombre}_Nucleo", bm, d["nucleo"], 0.2, d["nucleo"], 2.0))

    # tierra pegada en la base y 3 piedritas
    bm = bmesh.new()
    pts = []
    for i in range(14):
        a = 2 * math.pi * i / 14 + rng.uniform(-0.15, 0.15)
        rr = rng.uniform(0.85, 1.15)
        pts.append(Vector((rr * 1.15 * math.cos(a), rr * 0.95 * math.sin(a), rng.uniform(0.25, 0.5))))
        pts.append(Vector((rr * 0.8 * math.cos(a), rr * 0.65 * math.sin(a), 0.0)))
    _casco(bm, pts)
    objetos.append(_objeto(f"{nombre}_Tierra", bm, "#A8693D", 0.85))
    bm = bmesh.new()
    for a in (0.4, 2.6, 4.4):
        c = Vector((1.15 * math.cos(a), 0.95 * math.sin(a), 0.2))
        tmp = bmesh.new()
        _casco(
            tmp,
            [c + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-0.6, 0.8))) * 0.17 for _ in range(10)],
        )
        _sumar(bm, tmp)
    objetos.append(_objeto(f"{nombre}_Piedrita", bm, d["piedrita"], 0.8))
    return objetos


BRUTAS = {
    # cuarzo blanco lechoso con reflejos lila: trozo alto y torcido, cristales agrupados a un costado
    "Cuarzo": {
        "semilla": 7,
        "cuerpo": (1.2, 0.9, 0.85, 0.35),
        "cortes": [
            ((0.15, -1, 0.55), 0.62),  # frente
            ((1, 0.2, 0.45), 0.70),  # costado derecho
            ((-0.9, 0.45, 0.6), 0.66),  # izquierdo de atrás
            ((0.1, 0.25, 1), 0.82),  # arriba
            ((-0.6, -0.7, 0.2), 0.72),  # frente izquierdo
        ],
        "tonos": [
            ("#9C74EA", 0.5, None, 0.0),
            ("#D8C2FF", 0.4, None, 0.0),
            ("#FCF8FF", 0.35, None, 0.0),
            ("#F3E8FF", 0.12, "#B98CFF", 0.45),
        ],
        "grieta": "#6B3FC4",
        "cristales": [((0.9, -0.7, 0.55), 0.16, 0.5, 0.3), ((0.5, -1, 0.25), 0.12, 0.36, 0.9)],
        "cristal": ("#A06BFF", "#8A4DFF", 0.4),
        "vidrio": (0.7, 0.05, 1),
        "color_vidrio": "#EBDDFF",
        "nucleo": "#C77DFF",
        "piedrita": "#6E4128",
    },
    # jaspe rojo ladrillo con vetas crema: canto ancho y bajo, cristalitos crema arriba
    "Jaspe": {
        "semilla": 23,
        "zc": 0.85,
        "cuerpo": (1.55, 1.1, 0.6, -0.15),
        "cortes": [
            ((0.1, -1, 0.35), 0.72),  # frente
            ((1, -0.15, 0.5), 1.05),  # costado derecho
            ((-1, 0.1, 0.45), 1.0),  # costado izquierdo
            ((-0.15, 0.1, 1), 0.48),  # arriba, bien plana
            ((0.3, 1, 0.4), 0.75),  # atrás
        ],
        "tonos": [
            ("#7E1F14", 0.55, None, 0.0),
            ("#B83A25", 0.45, None, 0.0),
            ("#E2603F", 0.4, None, 0.0),
            ("#EE7350", 0.15, "#FF7A4A", 0.35),
        ],
        "grieta": "#4A0F08",
        "veta": "#F6E2BC",
        "vetas": 3,
        "cristales": [((-0.8, -0.6, 0.7), 0.13, 0.36, 0.2), ((-0.4, -0.9, 0.5), 0.1, 0.28, 0.8)],
        "cristal": ("#F6E2BC", "#FFD9A0", 0.25),
        "vidrio": (0.55, -0.3, 1),
        "color_vidrio": "#FFE6C7",
        "nucleo": "#FF5A2E",
        "piedrita": "#4E9A3A",  # matitas de pasto en vez de piedritas: es de la Pradera
    },
}


def cubitos(nombre, celdas, colores):
    """Una malla por color con solo las caras de afuera (las tapadas por otro cubito no se hacen;
    detrás del vidrio sí, porque se ven). colores = {clave: (color, rugoso, brillo, fuerza, alfa)}."""
    vidrio = {c for c, k in celdas.items() if colores[k][4] < 1}
    # caras de afuera agrupadas por (color, dirección, plano): {clave: {(u, v)}}
    planos = {}
    for (x, y, z), k in celdas.items():
        for (dx, dy, dz), _ in m.CARAS:
            vecino = (x + dx, y + dy, z + dz)
            if vecino in celdas and (vecino not in vidrio or (x, y, z) in vidrio):
                continue
            if dz == -1 and z == 0:
                continue  # apoyada en el piso: no se ve
            n = (dx, dy, dz)
            eje = [i for i in range(3) if n[i]][0]
            u, v = [i for i in range(3) if i != eje]
            c = (x, y, z)
            plano = c[eje] + (1 if n[eje] > 0 else 0)
            planos.setdefault((k, n, plano), set()).add((c[u], c[v]))
    # juntar cuadraditos vecinos en rectángulos (2 triángulos cada uno)
    bms = {k: bmesh.new() for k in colores}
    for (k, n, plano), libres in planos.items():
        eje = [i for i in range(3) if n[i]][0]
        u, v = [i for i in range(3) if i != eje]
        for celda in sorted(libres):
            if celda not in libres:
                continue
            u0, v0 = celda
            u1 = u0
            while (u1 + 1, v0) in libres:
                u1 += 1
            v1 = v0
            while all((uu, v1 + 1) in libres for uu in range(u0, u1 + 1)):
                v1 += 1
            for uu in range(u0, u1 + 1):
                for vv in range(v0, v1 + 1):
                    libres.discard((uu, vv))
            esquinas = []
            for a, bb in ((u0, v0), (u1 + 1, v0), (u1 + 1, v1 + 1), (u0, v1 + 1)):
                p = [0, 0, 0]
                p[eje], p[u], p[v] = plano, a, bb
                esquinas.append(bms[k].verts.new(p))
            cara = bms[k].faces.new(esquinas)
            cara.normal_update()
            if cara.normal.dot(Vector(n)) < 0:
                cara.normal_flip()
    objetos = []
    for k, (color, rug, br, fu, alfa) in colores.items():
        if not bms[k].faces:
            continue
        obj = _objeto(f"{nombre}_{k}", bms[k], color, rug, br, fu, alfa)
        for cara in obj.data.polygons:
            cara.use_smooth = False  # cubitos: cada cara plana, sin sombras raras
        objetos.append(obj)
    return objetos


def cuarzo(nombre):
    """Piedra en bruto de cubitos: trozo de cuarzo lechoso en escalones, más claro arriba, con
    reflejos lila, 2 grietas oscuras, 3 cristalitos cuadrados (uno de vidrio con núcleo que brilla)
    y tierra con piedritas y pasto pegados en la base."""
    rng = random.Random(7)
    celdas = {}
    # base de tierra: mancha irregular de 2 capas
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8, y / 6.5) + (h(x // 2, y // 2, 0, 3) - 0.5) * 0.35
            if r < 1:
                celdas[(x, y, 0)] = "TierraOscura"
            if r < 0.85:
                celdas[(x, y, 1)] = "Tierra" if h(x, y, 1, 4) > 0.08 else "TierraOscura"
    # cuerpo: capas que se achican y se corren al subir, con bordes en escalones
    tope = 11
    for z in range(1, tope + 1):
        t = (z - 1) / (tope - 1)
        cx, cy = round(1.8 * t), round(-0.8 * t)
        rx, ry = 6.2 * (1 - 0.5 * t**1.6), 5.0 * (1 - 0.45 * t**1.4)
        for x in range(-8, 9):
            for y in range(-7, 8):
                ruido = (h(x // 3, y // 3, z // 2, 7) - 0.5) * 0.55
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1 + ruido:
                    continue
                if x - y > 9 - z * 0.4:  # corte en diagonal: canto de mineral partido
                    continue
                v = t + (h(x, y, z, 9) - 0.5) * 0.1
                celdas[(x, y, z)] = "Claro" if v > 0.62 else "Medio" if v > 0.3 else "Oscuro"
    llenas = set(celdas)

    def afuera(c):
        x, y, z = c
        return any((x + dx, y + dy, z + dz) not in llenas for (dx, dy, dz), _ in m.CARAS[:5])

    cuerpo = sorted(c for c, k in celdas.items() if k in ("Claro", "Medio", "Oscuro") and afuera(c))
    # reflejos lila sueltos en la superficie
    for c in cuerpo:
        if h(*c, 11) < 0.04:
            celdas[c] = "Lila"
    # grietas: caminos de cubitos oscuros que bajan por la superficie
    for inicio in ((-3, -4, 8), (4, 1, 7)):
        c = min(cuerpo, key=lambda p: sum((a - b) ** 2 for a, b in zip(p, inicio)))
        for _ in range(9):
            celdas[c] = "Grieta"
            vecinos = [
                p for p in cuerpo
                if p[2] <= c[2] and sum(abs(a - b) for a, b in zip(p, c)) == 1 and celdas[p] != "Grieta"
            ]
            if not vecinos:
                break
            c = rng.choice(vecinos)

    def columna(x0, y0, z0, lado, alto, clave, corre=(0, 0)):
        for i in range(alto):
            dx, dy = corre[0] * (i // 2), corre[1] * (i // 2)
            ancho = lado if i < alto - 1 else max(1, lado - 2)
            off = (lado - ancho) // 2
            for a in range(ancho):
                for b in range(ancho):
                    celdas[(x0 + dx + off + a, y0 + dy + off + b, z0 + i)] = clave

    # cristalitos: uno de vidrio grande arriba con núcleo, uno lila al costado, uno chico adelante
    columna(0, -2, 9, 3, 6, "Vidrio", corre=(1, 0))
    for i in range(4):
        celdas[(1 + i // 2, -1, 10 + i)] = "Nucleo"
    columna(-5, 0, 5, 2, 5, "Cristal", corre=(-1, 1))
    columna(3, -5, 3, 2, 3, "Cristal", corre=(1, -1))
    # piedritas y matas de pasto en la tierra
    for x, y in ((-7, 2), (6, 4), (-2, 6)):
        celdas[(x, y, 1)] = celdas[(x, y, 2)] = "Piedrita"
    for x, y in ((5, -5), (-6, -3), (7, 0), (0, 6)):
        celdas[(x, y, 2)] = "Pasto"
    colores = {
        "Oscuro": ("#B9A4DC", 0.5, None, 0.0, 1),
        "Medio": ("#E4D9F5", 0.4, None, 0.0, 1),
        "Claro": ("#FBF8FF", 0.35, None, 0.0, 1),
        "Lila": ("#C7A2FF", 0.2, "#B98CFF", 0.3, 1),
        "Grieta": ("#6F4FAE", 0.6, None, 0.0, 1),
        "Cristal": ("#A06BFF", 0.2, "#8A4DFF", 0.35, 1),
        "Vidrio": ("#E3D2FF", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#C77DFF", 0.2, "#C77DFF", 2.0, 1),
        "Tierra": ("#A8693D", 0.85, None, 0.0, 1),
        "TierraOscura": ("#7A4A2A", 0.9, None, 0.0, 1),
        "Piedrita": ("#6B6B73", 0.8, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def jaspe(nombre):
    """Piedra en bruto de cubitos: canto ancho y chato de jaspe rojo ladrillo (más claro arriba),
    cruzado por 2 vetas crema en diagonal, grietas oscuras, 2 cristalitos crema y 1 de vidrio con
    brasa naranja adentro, y tierra con pasto en la base. Ancho y bajo para no confundirse con
    el Cuarzo, que es alto, blanco y torcido."""
    rng = random.Random(23)
    celdas = {}
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7) + (h(x // 2, y // 2, 0, 5) - 0.5) * 0.3
            if r < 1:
                celdas[(x, y, 0)] = "TierraOscura"
            if r < 0.88:
                celdas[(x, y, 1)] = "Tierra" if h(x, y, 1, 6) > 0.08 else "TierraOscura"
    # cuerpo: losa ancha que se achica en escalones grandes, techo casi plano
    tope = 8
    for z in range(1, tope + 1):
        t = (z - 1) / (tope - 1)
        rx, ry = 7.4 * (1 - 0.35 * t**2), 5.6 * (1 - 0.4 * t**2)
        for x in range(-8, 9):
            for y in range(-7, 8):
                ruido = (h(x // 3, y // 3, z // 3, 21) - 0.5) * 0.5
                if ((x + 0.5 * t) / rx) ** 2 + (y / ry) ** 2 > 1 + ruido:
                    continue
                if -x - y > 10 - z * 0.6:  # canto partido adelante a la izquierda
                    continue
                v = t + (h(x, y, z, 22) - 0.5) * 0.1
                clave = "Claro" if v > 0.62 else "Medio" if v > 0.28 else "Oscuro"
                # vetas crema: 2 bandas en diagonal que atraviesan toda la piedra
                if abs((x + z * 0.8) - 3) < 0.9 or abs((x - y * 0.5 + z * 0.8) + 5) < 0.7:
                    clave = "Veta"
                celdas[(x, y, z)] = clave
    llenas = set(celdas)

    def afuera(c):
        x, y, z = c
        return any((x + dx, y + dy, z + dz) not in llenas for (dx, dy, dz), _ in m.CARAS[:5])

    cuerpo = sorted(c for c, k in celdas.items() if k in ("Claro", "Medio", "Oscuro") and afuera(c))
    for inicio in ((2, -6, 6), (-5, 3, 7), (6, 2, 5)):
        c = min(cuerpo, key=lambda p: sum((a - b) ** 2 for a, b in zip(p, inicio)))
        for _ in range(8):
            celdas[c] = "Grieta"
            vecinos = [
                p for p in cuerpo
                if p[2] <= c[2] and sum(abs(a - b) for a, b in zip(p, c)) == 1 and celdas[p] != "Grieta"
            ]
            if not vecinos:
                break
            c = rng.choice(vecinos)

    def columna(x0, y0, z0, lado, alto, clave, corre=(0, 0)):
        for i in range(alto):
            dx, dy = corre[0] * (i // 2), corre[1] * (i // 2)
            ancho = lado if i < alto - 1 else max(1, lado - 2)
            off = (lado - ancho) // 2
            for a in range(ancho):
                for b in range(ancho):
                    celdas[(x0 + dx + off + a, y0 + dy + off + b, z0 + i)] = clave

    # cristalitos: vidrio con brasa arriba a la derecha, 2 crema chicos del otro lado
    columna(2, -1, 7, 3, 6, "Vidrio", corre=(1, 0))
    for i in range(4):
        celdas[(3 + i // 2, 0, 8 + i)] = "Nucleo"
    columna(-4, -2, 7, 2, 4, "Cristal", corre=(-1, -1))
    columna(-1, 2, 8, 2, 3, "Cristal", corre=(0, 1))
    for x, y in ((-7, 3), (7, -3), (1, 6)):
        celdas[(x, y, 1)] = celdas[(x, y, 2)] = "Piedrita"
    for x, y in ((6, 4), (-7, -2), (3, -6), (-3, 6)):
        celdas[(x, y, 2)] = "Pasto"
    colores = {
        "Oscuro": ("#7E1F14", 0.55, None, 0.0, 1),
        "Medio": ("#B83A25", 0.45, None, 0.0, 1),
        "Claro": ("#E2603F", 0.4, None, 0.0, 1),
        "Veta": ("#F6E2BC", 0.35, None, 0.0, 1),
        "Grieta": ("#4A0F08", 0.6, None, 0.0, 1),
        "Cristal": ("#F6E2BC", 0.2, "#FFD9A0", 0.3, 1),
        "Vidrio": ("#FFE6C7", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#FF5A2E", 0.2, "#FF5A2E", 2.0, 1),
        "Tierra": ("#A8693D", 0.85, None, 0.0, 1),
        "TierraOscura": ("#7A4A2A", 0.9, None, 0.0, 1),
        "Piedrita": ("#6B6B73", 0.8, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def _punta(bms, base, direccion, radio, largo, giro):
    """Punta de cristal de 6 caras con hombro y punta tallada, partida en 3 tonos
    (bms = [oscuro abajo, medio, claro arriba]). Se apoya en 'base' mirando hacia 'direccion'."""
    anillos = [(0.0, 1.0), (0.45, 1.06), (0.78, 0.96), (0.93, 0.42)]  # (alto, radio) relativos
    rot = Vector((0, 0, 1)).rotation_difference(direccion.normalized()).to_matrix().to_4x4()
    mat = Matrix.Translation(base) @ rot

    def v(alto, rr, i):
        a = giro + 2 * math.pi * i / 6
        return mat @ Vector((radio * rr * math.cos(a), radio * rr * math.sin(a), largo * alto))

    for seg in range(3):
        bm = bms[seg]
        (h0, r0), (h1, r1) = anillos[seg], anillos[seg + 1]
        abajo = [bm.verts.new(v(h0, r0, i)) for i in range(6)]
        arriba = [bm.verts.new(v(h1, r1, i)) for i in range(6)]
        for i in range(6):
            j = (i + 1) % 6
            bm.faces.new([abajo[i], abajo[j], arriba[j], arriba[i]])
        if seg == 0:
            bm.faces.new(list(reversed(abajo)))
    # punta tallada: anillo chico + vértice, en el tono claro
    bm = bms[2]
    h0, r0 = anillos[3]
    anillo = [bm.verts.new(v(h0, r0, i)) for i in range(6)]
    pico = bm.verts.new(mat @ Vector((0, 0, largo)))
    for i in range(6):
        bm.faces.new([anillo[i], anillo[(i + 1) % 6], pico])


def cristal_tallado(nombre, d):
    """Racimo de puntas de cristal (6 caras, punta tallada, 3 tonos, vidrio con un núcleo claro que
    brilla adentro) saliendo de una base de roca biselada, con esquirlas sueltas y pasto."""
    rng = random.Random(d["semilla"])
    objetos = []
    oscuro, medio, claro = d["tonos"]
    bms = [bmesh.new() for _ in range(3)]
    nucleos = bmesh.new()
    for direccion, radio, largo, giro in d["puntas"]:
        dd = Vector(direccion).normalized()
        base = Vector((dd.x * 0.25, dd.y * 0.25, 0.45))
        _punta(bms, base, dd, radio, largo, giro)
        _cristalito(nucleos, base + dd * 0.1, dd, radio * 0.4, largo * 0.6, giro)
    for bm, sufijo, (color, alfa) in zip(bms, ("Oscuro", "Medio", "Claro"), (oscuro, medio, claro)):
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        bmesh.ops.bevel(bm, geom=list(bm.edges), offset=0.012, segments=1, affect="EDGES", clamp_overlap=True)
        objetos.append(_objeto(f"{nombre}_{sufijo}", bm, color, 0.1, color, 0.15, alfa=alfa))
    objetos.append(_objeto(f"{nombre}_Nucleo", nucleos, d["nucleo"], 0.2, d["nucleo"], 1.2))

    # base de roca biselada, más oscura abajo
    pts = []
    for i in range(12):
        a = 2 * math.pi * i / 12 + rng.uniform(-0.2, 0.2)
        rr = rng.uniform(0.85, 1.1)
        pts.append(Vector((rr * 0.85 * math.cos(a), rr * 0.75 * math.sin(a), rng.uniform(0.45, 0.65))))
        pts.append(Vector((rr * 1.05 * math.cos(a), rr * 0.9 * math.sin(a), rng.uniform(0.0, 0.15))))
    bm = bmesh.new()
    _casco(bm, pts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.bevel(bm, geom=list(bm.edges), offset=0.05, segments=1, affect="EDGES", clamp_overlap=True)
    abajo = bm.copy()
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.normal.z < 0.3], context="FACES")
    bmesh.ops.delete(abajo, geom=[f for f in abajo.faces if f.normal.z >= 0.3], context="FACES")
    objetos.append(_objeto(f"{nombre}_RocaArriba", bm, d["roca"][0], 0.7))
    objetos.append(_objeto(f"{nombre}_RocaAbajo", abajo, d["roca"][1], 0.8))

    # esquirlas sueltas apoyadas en la base y matitas de pasto
    bm = bmesh.new()
    for x, y, dx, dy in d["esquirlas"]:
        _cristalito(bm, Vector((x, y, 0.55)), Vector((dx, dy, 0.35)), 0.06, 0.16, 0.4)
    objetos.append(_objeto(f"{nombre}_Esquirla", bm, d["esquirla"], 0.15, d["esquirla"], 0.3))
    bm = bmesh.new()
    for a in (1.2, 3.3, 5.2):
        c = Vector((1.0 * math.cos(a), 0.85 * math.sin(a), 0.12))
        tmp = bmesh.new()
        _casco(tmp, [c + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(0, 1.2))) * 0.12 for _ in range(8)])
        _sumar(bm, tmp)
    objetos.append(_objeto(f"{nombre}_Pasto", bm, "#4E9A3A", 0.8))
    return objetos


TALLADOS = {
    # racimo de 3 puntas de amatista violeta de distintos largos, inclinadas hacia afuera
    "Amatista": {
        "semilla": 31,
        "puntas": [
            ((0.05, 0.1, 1), 0.3, 2.0, 0.1),  # la grande, al medio
            ((0.7, -0.35, 0.8), 0.22, 1.3, 0.5),  # derecha
            ((-0.65, -0.25, 0.85), 0.18, 1.0, 0.9),  # izquierda, la chica
        ],
        "tonos": [("#5B22B8", 0.8), ("#8A3FF0", 0.7), ("#C394FF", 0.65)],
        "nucleo": "#F2DDFF",
        "roca": ("#8C6448", "#5E3F2C"),
        "esquirlas": [(0.45, 0.45, 1, 0.6), (-0.4, 0.4, -0.8, 1)],
        "esquirla": "#A86BFF",
    },
}


def racimo(nombre, d):
    """Cristal de cubitos: racimo de columnas cuadradas (3 tonos, más claro arriba, aristas claras
    y líneas de crecimiento oscuras) que terminan en punta escalonada; la grande es de vidrio con
    un núcleo claro que brilla adentro y las otras muestran el núcleo en la punta. Salen de una base
    de roca de 2 tonos con esquirlas sueltas y pasto. Con "musgo", manchitas oscuras en grupitos
    sobre las columnas y flotando dentro del vidrio. 'd' trae los números de cada piedra."""
    celdas = {}
    for x in range(-7, 8):
        for y in range(-7, 8):
            r = math.hypot(x / 7.5, y / 7) + (h(x // 2, y // 2, 0, 31) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.18:
                    celdas[(x, y, z)] = "Roca" if z == 2 or h(x, y, z, 32) > 0.75 else "RocaOscura"
    musgo = d.get("musgo", 0)

    def manchita(c):
        x, y, z = c
        # h() casi no cambia entre celdas vecinas: para manchas sueltas conviene un azar de verdad
        grupo = random.Random(f"musgo{x // 2},{y // 2},{z // 2}").random()
        return musgo and grupo < musgo and random.Random(f"m{c}").random() < 0.7

    def columna(x0, y0, z0, lado, alto, vidrio, corre):
        """Columna cuadrada con punta escalonada: se achica 1 por lado cada 2 cubitos al final."""
        punta = lado  # cubitos de punta (achicando)
        for i in range(alto + punta):
            dx, dy = round(corre[0] * i), round(corre[1] * i)
            achica = max(0, (i - alto) // 2 + 1) if i >= alto else 0
            ancho = lado - 2 * achica
            if ancho <= 0:
                ancho = 1
            t = i / (alto + punta)
            for a in range(achica, achica + ancho):
                for b in range(achica, achica + ancho):
                    borde = a in (achica, achica + ancho - 1) or b in (achica, achica + ancho - 1)
                    c = (x0 + dx + a, y0 + dy + b, z0 + i)
                    if not borde and i < alto + punta - 2:
                        celdas[c] = "Musgo" if vidrio and manchita(c) else "Nucleo"
                    elif vidrio:
                        celdas[c] = "Vidrio"
                    elif manchita(c):
                        celdas[c] = "Musgo"
                    else:
                        esquina = a in (achica, achica + ancho - 1) and b in (achica, achica + ancho - 1)
                        v = t + (h(*c, 33) - 0.5) * 0.3
                        if esquina and ancho > 2:
                            v += 0.35  # aristas más claras: marcan la columna
                        elif i % 4 == 3:
                            v -= 0.3  # líneas de crecimiento más oscuras
                        celdas[c] = "Claro" if v > 0.6 else "Medio" if v > 0.3 else "Oscuro"
            if ancho == 1 and i >= alto:
                break

    for col in d["columnas"]:
        columna(*col)
    # esquirlas sueltas y pasto en la roca
    for c in d["esquirlas"]:
        celdas[c] = "Esquirla"
    for x, y in ((6, -2), (-6, 3), (2, 6), (-3, -6)):
        celdas[(x, y, 2)] = "Pasto"
    colores = dict(d["colores"])
    colores.update({
        "Roca": ("#8C6448", 0.75, None, 0.0, 1),
        "RocaOscura": ("#5E3F2C", 0.85, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    })
    return cubitos(nombre, celdas, colores)


RACIMOS = {
    # 5 columnas violetas altas y finitas, la grande al medio de vidrio
    "Amatista": {
        "columnas": [
            (-2, -2, 2, 5, 12, True, (0.0, 0.0)),  # la grande, al medio, de vidrio
            (2, -5, 2, 4, 8, False, (0.15, -0.08)),  # derecha adelante
            (-6, -1, 2, 4, 6, False, (-0.15, 0.0)),  # izquierda
            (0, 3, 2, 3, 4, False, (0.0, 0.2)),  # chica atrás
            (4, 1, 2, 3, 3, False, (0.2, 0.1)),  # chiquita a la derecha
        ],
        "esquirlas": [(5, 3, 3), (6, 3, 3), (-5, -4, 3), (-4, 5, 3), (5, 3, 4)],
        "colores": {
            "Oscuro": ("#4A1A9E", 0.3, None, 0.0, 1),
            "Medio": ("#7A35E0", 0.25, None, 0.0, 1),
            "Claro": ("#B07DFF", 0.2, "#9B5CFF", 0.2, 1),
            "Vidrio": ("#9E6BFF", 0.05, None, 0.0, 0.5),
            "Nucleo": ("#EBD6FF", 0.2, "#D9B8FF", 1.2, 1),
            "Esquirla": ("#A86BFF", 0.2, "#A86BFF", 0.3, 1),
        },
    },
    # ágata verde clara con musgo: 4 columnas gordas y abiertas en abanico, de vidrio la del medio
    # con musgo flotando adentro; más ancha y verde para no confundirse con la Amatista
    "AgataMusgosa": {
        "musgo": 0.3,
        "columnas": [
            (-3, -3, 2, 6, 9, True, (0.0, 0.0)),  # la grande, gorda, de vidrio con musgo
            (2, -6, 2, 5, 6, False, (0.35, -0.1)),  # derecha adelante, bien inclinada
            (-7, -2, 2, 5, 5, False, (-0.3, 0.05)),  # izquierda, inclinada
            (-1, 3, 2, 4, 5, False, (0.0, 0.3)),  # atrás
        ],
        "esquirlas": [(5, 3, 3), (5, 4, 3), (-5, 5, 3), (-4, -6, 3), (5, 3, 4)],
        "colores": {
            "Oscuro": ("#4FA05A", 0.35, None, 0.0, 1),
            "Medio": ("#7FD08A", 0.3, None, 0.0, 1),
            "Claro": ("#BDF2C2", 0.25, "#9BE8A6", 0.15, 1),
            "Musgo": ("#1F5A2A", 0.6, None, 0.0, 1),
            "Vidrio": ("#C8F5CF", 0.05, None, 0.0, 0.45),
            "Nucleo": ("#F0FFE8", 0.2, "#D8FFD0", 1.0, 1),
            "Esquirla": ("#9BE8A6", 0.2, "#9BE8A6", 0.3, 1),
        },
    },
}


def amatista(nombre):
    return racimo(nombre, RACIMOS["Amatista"])


def agata_musgosa(nombre):
    return racimo(nombre, RACIMOS["AgataMusgosa"])


def tallada(nombre, d):
    """Gema tallada de cubitos: ancha arriba y en punta escalonada abajo, de vidrio en 3 tonos (más
    claro arriba) con aristas claras que hacen de facetas; adentro un corazón que brilla (malla
    aparte). Va sentada en un engarce cuadrado de oro con 4 garras, sobre una base de roca con
    cristalitos. Con "punta", las últimas capas de arriba van con otros tonos (otra punta de color).
    'd' trae los números de cada gema."""
    celdas = {}
    # base de roca
    for x in range(-8, 9):
        for y in range(-8, 9):
            r = math.hypot(x / 8.5, y / 8) + (random.Random(f"r{x // 2},{y // 2}").random() - 0.5) * 0.15
            for z in range(3):
                if r < 1 - z * 0.07:  # loma ancha y chata: el engarce apoya entero arriba
                    oscura = z < 2 and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else "Roca"
    # engarce: marco cuadrado de oro hueco
    ex, ey = d["engarce"]
    for x in range(-ex, ex + 1):
        for y in range(-ey, ey + 1):
            if max(abs(x) / ex, abs(y) / ey) >= 0.75:
                celdas[(x, y, 3)] = "Oro"
    # gema: (z, medio ancho en x, medio ancho en y): pabellón en punta abajo, corona arriba
    capas = [(3 + i, ax, ay) for i, (ax, ay) in enumerate(d["anchos"])]
    medida = {z: (ax, ay) for z, ax, ay in capas}
    z0, zmax = capas[0][0], capas[-1][0]
    oscuro, medio, claro = d["tonos"]
    punta = d.get("punta", 0)
    for z, ax, ay in capas:
        t = (z - z0) / (zmax - z0)
        sig = medida.get(z + 1)
        for x in range(-ax, ax + 1):
            for y in range(-ay, ay + 1):
                borde = abs(x) == ax or abs(y) == ay
                esquina = abs(x) == ax and abs(y) == ay
                # escalón: la celda queda al aire arriba (faceta horizontal de la corona)
                escalon = sig is None or abs(x) > sig[0] or abs(y) > sig[1]
                if abs(x) <= min(2, ax - 2) and abs(y) <= min(1, ay - 1) and z < zmax - 1:
                    celdas[(x, y, z)] = "Corazon"
                    continue
                if not borde and not escalon:
                    continue  # hueco por dentro: se ve el corazón a través del vidrio
                if z > zmax - punta:  # la punta de color manda, también en las facetas
                    claro_p = esquina or random.Random(f"p{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "PuntaClaro" if claro_p else "Punta"
                elif esquina or (escalon and borde):
                    celdas[(x, y, z)] = "Faceta"
                else:
                    v = t + (random.Random(f"e{x},{y},{z}").random() - 0.5) * 0.25
                    celdas[(x, y, z)] = claro if v > 0.62 else medio if v > 0.3 else oscuro
    # 4 garras de oro en las esquinas: suben pegadas a la gema y se doblan sobre ella
    gx, gy, gz = d["garras"]  # punta doblada de cada garra y altura donde se dobla
    for sx in (-1, 1):
        for sy in (-1, 1):
            for z in range(3, gz):
                ax, ay = medida.get(z, (1, 0))
                celdas[(sx * (ax + 1), sy * (ay + 1), z)] = "Oro"
            celdas[(sx * gx, sy * gy, gz)] = celdas[(sx * (gx - 1), sy * gy, gz)] = "Oro"
    # cristalitos en la roca
    for x, y, alto in ((-7, 3, 3), (6, -5, 2), (-3, -7, 2), (7, 4, 2), (2, 7, 3)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1  # apoyado en la roca
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Cristal"
    for x, y in ((-6, -4), (4, 6), (-1, 7)):
        if (x, y, 2) in celdas:
            celdas[(x, y, 3)] = "Pasto"
    colores = dict(d["colores"])
    colores.update({
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    })
    return cubitos(nombre, celdas, colores)


TALLADAS_CUBITOS = {
    # esmeralda verde rectangular, ancha y corta
    "Esmeralda": {
        "engarce": (5, 4),
        "anchos": [(1, 0), (1, 0), (2, 1), (2, 1), (3, 1), (3, 2), (4, 2), (4, 2), (5, 3), (5, 3), (6, 3),
                   (6, 4), (6, 4), (6, 4), (5, 3), (5, 3), (4, 2), (3, 2)],
        "garras": (6, 4, 17),
        "tonos": ("VerdeOscuro", "VerdeMedio", "VerdeClaro"),
        "colores": {
            "VerdeOscuro": ("#06703A", 0.05, None, 0.0, 0.7),
            "VerdeMedio": ("#10A651", 0.05, None, 0.0, 0.6),
            "VerdeClaro": ("#3FE07E", 0.05, None, 0.0, 0.55),
            "Faceta": ("#B8FFD2", 0.05, "#7DFFB0", 0.25, 0.8),
            "Corazon": ("#7DFFB0", 0.2, "#4DFF94", 2.5, 1),
            "Cristal": ("#3FE07E", 0.15, "#3FE07E", 0.4, 1),
        },
    },
    # turmalina rosa alargada y finita, con las 4 capas de arriba verdes (punta de sandía)
    "TurmalinaRosa": {
        "engarce": (3, 3),
        "anchos": [(1, 0), (1, 0), (1, 1), (1, 1), (2, 1), (2, 1), (2, 2), (3, 2), (3, 2), (3, 2), (3, 2),
                   (3, 2), (3, 2), (3, 2), (3, 2), (3, 2), (3, 2), (2, 2), (2, 1), (1, 1)],
        "garras": (3, 2, 17),
        "punta": 5,
        "tonos": ("RosaOscuro", "RosaMedio", "RosaClaro"),
        "colores": {
            "RosaOscuro": ("#B0205E", 0.05, None, 0.0, 0.7),
            "RosaMedio": ("#E8478C", 0.05, None, 0.0, 0.6),
            "RosaClaro": ("#FF85B8", 0.05, None, 0.0, 0.55),
            "Punta": ("#1E9E4A", 0.05, None, 0.0, 0.65),
            "PuntaClaro": ("#6BE38A", 0.05, None, 0.0, 0.55),
            "Faceta": ("#FFD1E6", 0.05, "#FF9CC8", 0.25, 0.8),
            "Corazon": ("#FFB3D6", 0.2, "#FF6FB0", 2.5, 1),
            "Cristal": ("#FF85B8", 0.15, "#FF85B8", 0.4, 1),
        },
    },
    # topacio imperial ovalado (más largo en x), naranja dorado con reflejos rosados en las facetas
    "TopacioImperial": {
        "engarce": (5, 4),
        "anchos": [(1, 0), (1, 1), (2, 1), (3, 2), (3, 2), (4, 3), (5, 3), (5, 3), (6, 4), (6, 4), (6, 4),
                   (6, 4), (6, 4), (5, 4), (5, 3), (4, 3), (3, 2), (2, 1)],
        "garras": (5, 3, 15),
        "tonos": ("NaranjaOscuro", "NaranjaMedio", "NaranjaClaro"),
        "colores": {
            "NaranjaOscuro": ("#C2501A", 0.05, None, 0.0, 0.7),
            "NaranjaMedio": ("#EE8A2A", 0.05, None, 0.0, 0.6),
            "NaranjaClaro": ("#FFC05A", 0.05, None, 0.0, 0.55),
            "Faceta": ("#FFB37A", 0.05, "#FF8F5A", 0.25, 0.75),
            "Corazon": ("#FFC870", 0.2, "#FF9A30", 2.5, 1),
            "Cristal": ("#FFB04A", 0.15, "#FFA030", 0.4, 1),
        },
    },
    # cornalina en gota: panza abajo y punta escalonada larga arriba, rojo anaranjado
    "Cornalina": {
        "engarce": (4, 4),
        "anchos": [(1, 0), (2, 1), (3, 2), (4, 3), (4, 3), (5, 4), (5, 4), (5, 4), (5, 4), (4, 3), (4, 3),
                   (3, 3), (3, 2), (3, 2), (2, 2), (2, 1), (1, 1), (1, 1), (1, 0), (0, 0)],
        "garras": (4, 3, 9),
        "tonos": ("RojoOscuro", "RojoMedio", "RojoClaro"),
        "colores": {
            "RojoOscuro": ("#A3200F", 0.05, None, 0.0, 0.7),
            "RojoMedio": ("#D9431C", 0.05, None, 0.0, 0.6),
            "RojoClaro": ("#F2552A", 0.05, None, 0.0, 0.55),
            "Faceta": ("#F2603A", 0.05, "#FF5A2E", 0.25, 0.75),
            "Corazon": ("#FF8A5C", 0.2, "#FF4A1A", 2.5, 1),
            "Cristal": ("#E8552A", 0.15, "#E8552A", 0.4, 1),
        },
    },
}


def esmeralda(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["Esmeralda"])


def topacio_imperial(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["TopacioImperial"])


def cornalina(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["Cornalina"])


def turmalina_rosa(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["TurmalinaRosa"])


def corazon_de_pradera(nombre):
    """Gema legendaria de cubitos: corazón de vidrio verde parado (3 tonos, más claro arriba, con
    los bordes en escalones como facetas claras) y un corazón que brilla fuerte adentro (malla
    aparte). Lo rodea un marco de oro con remaches en relieve, hojitas doradas abajo y entre los
    lóbulos y 3 gemitas cuadradas engarzadas. Se apoya en un pie de oro sobre una roca de la que
    crecen cristales cuadrados verdes."""
    celdas = {}
    # roca
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7.5) + (random.Random(f"r{x // 2},{y // 2}").random() - 0.5) * 0.15
            for z in range(3):
                if r < 1 - z * 0.12:
                    oscura = z < 2 and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else "Roca"
    # pie de oro
    for z in (3, 4):
        for x in range(-2 + (z - 3), 3 - (z - 3)):
            for y in range(-2, 3):
                celdas[(x, y, z)] = "Oro"
    # silueta del corazón en el plano x-z
    zb, alto = 5, 18

    def dentro(x, z):
        """2 lóbulos (círculos) arriba y un triángulo con la punta abajo: hendidura bien marcada."""
        u = (x + 0.5) / 7.5
        v = -1 + (z - zb + 0.5) / alto * 1.97
        lobulo = min(math.hypot(u - 0.48, v - 0.45), math.hypot(u + 0.48, v - 0.45)) <= 0.52
        return lobulo or (v <= 0.45 and abs(u) <= (v + 1) / 1.45)

    plano = {(x, z) for x in range(-10, 11) for z in range(zb, zb + alto + 2) if dentro(x, z)}

    def hondo(x, z):
        """Cuántos pasos hasta salir de la silueta (máx. 4)."""
        for k in range(1, 5):
            if any((x + dx * k, z + dz * k) not in plano for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                return k
        return 4

    zmin = min(z for _, z in plano)
    zmax = max(z for _, z in plano)
    for x, z in plano:
        k = hondo(x, z)
        grosor = min(3, k)  # bordes en escalones: más fino afuera, más grueso al medio
        t = (z - zmin) / (zmax - zmin)
        for y in range(-grosor, grosor + 1):
            if k >= 3 and abs(y) <= 1:
                celdas[(x, y, z)] = "Corazon"
                continue
            frente = abs(y) == grosor
            if not frente and k > 1:
                continue  # hueco: se ve el corazón a través del vidrio
            escalon = frente and hondo(x, z) < 3 and (k == 1 or min(3, hondo(x + 1, z), hondo(x - 1, z),
                                                            hondo(x, z + 1), hondo(x, z - 1)) < grosor)
            if escalon:
                celdas[(x, y, z)] = "Faceta"
            else:
                v = t + (random.Random(f"c{x},{y},{z}").random() - 0.5) * 0.25
                celdas[(x, y, z)] = "VerdeClaro" if v > 0.62 else "VerdeMedio" if v > 0.3 else "VerdeOscuro"
    # marco de oro alrededor, con remaches en relieve
    marco = set()
    for x, z in plano:
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            c = (x + dx, z + dz)
            if c not in plano:
                marco.add(c)
    for x, z in marco:
        for y in (-1, 0, 1):
            celdas[(x, y, z)] = "Oro"
        if (x * 3 + z) % 5 == 0:
            celdas[(x, 2, z)] = celdas[(x, -2, z)] = "Remache"
    # hojitas doradas: rombos chicos que salen del marco
    def hoja(x0, z0, dx, dz):
        for i, ancho in enumerate((0, 1, 1, 0)):
            cx, cz = x0 + dx * i, z0 + dz * i
            for w in range(-ancho, ancho + 1):
                c = (cx + (-dz) * w, 0, cz + dx * w)
                if (c[0], c[2]) not in plano:
                    celdas[c] = "Hoja" if w == 0 or i == 0 else "HojaOscura"
    izq = min(marco, key=lambda c: (c[0] + c[1] * 0.2) if c[1] < zb + 7 else 99)
    der = max(marco, key=lambda c: (c[0] - c[1] * 0.2) if c[1] < zb + 7 else -99)
    hoja(izq[0], izq[1], -1, 0)
    hoja(der[0], der[1], 1, 0)
    hoja(-1, zb, -1, 0)
    hoja(1, zb, 1, 0)
    arriba = max(z for x, z in marco if x == 0)  # la hendidura entre los lóbulos
    hoja(0, arriba, 0, 1)
    # 3 gemitas cuadradas engarzadas: arriba de cada lóbulo y al frente de la roca
    for x0 in (-4, 3):
        ztop = max(z for x, z in marco if x == x0) + 1
        for a in range(2):
            for b in range(2):
                celdas[(x0 + a, b - 1, ztop + b)] = "Gemita"
        celdas[(x0 - 1, 0, ztop)] = celdas[(x0 + 2, 0, ztop)] = "Oro"
    for a in range(2):
        for b in range(2):
            celdas[(a, -6, 3 + b)] = "Gemita"
    celdas[(-1, -6, 3)] = celdas[(2, -6, 3)] = "Oro"
    # cristales cuadrados que crecen de la roca
    for x, y, alto_c in ((-7, 2, 4), (-6, 3, 2), (6, -3, 3), (7, 2, 5), (-4, 5, 3), (4, 5, 2), (-5, -4, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto_c):
            celdas[(x, y, z)] = "Cristal" if z < z0 + alto_c - 1 else "CristalClaro"
    for x, y in ((-3, -5), (5, 4), (-7, -1)):
        if (x, y, 2) in celdas:
            celdas[(x, y, 3)] = "Pasto"
    colores = {
        "VerdeOscuro": ("#0B6B2E", 0.05, None, 0.0, 0.7),
        "VerdeMedio": ("#1DB04A", 0.05, None, 0.0, 0.6),
        "VerdeClaro": ("#5BEA7A", 0.05, None, 0.0, 0.55),
        "Faceta": ("#C9FFD6", 0.05, "#8CFFA8", 0.3, 0.8),
        "Corazon": ("#B5FFC4", 0.2, "#5CFF84", 4.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Hoja": ("#FFD24A", 0.25, None, 0.0, 1),
        "HojaOscura": ("#C98A12", 0.3, None, 0.0, 1),
        "Gemita": ("#FF5FA2", 0.05, "#FF5FA2", 0.6, 1),
        "Cristal": ("#2FBF5C", 0.15, None, 0.0, 1),
        "CristalClaro": ("#9BFFB3", 0.15, "#7DFF9C", 0.5, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def diamante_floral(nombre):
    """Gema legendaria de cubitos: diamante blanco de vidrio con planta de rombo (punta escalonada
    abajo, corona escalonada arriba, aristas claras como facetas) y adentro una flor de pétalos
    rosas alrededor de un centro que brilla fuerte (malla aparte). Lo ciñe un cinto de oro con
    remaches en relieve, 4 garras y 3 gemitas cuadradas; va sobre un pie de oro y una roca con
    cristales blancos y rosas."""
    celdas = {}
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7.5) + (random.Random(f"r{x // 2},{y // 2}").random() - 0.5) * 0.15
            for z in range(3):
                if r < 1 - z * 0.12:
                    oscura = z < 2 and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else "Roca"
    for z in (3, 4):  # pie de oro
        for x in range(-2 + (z - 3), 3 - (z - 3)):
            for y in range(-2 + (z - 3), 3 - (z - 3)):
                celdas[(x, y, z)] = "Oro"
    # diamante: medio ancho del rombo (|x| + |y| <= w) en cada capa
    anchos = [0, 1, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 5, 4, 3]
    zb = 5
    w_de = {zb + i: w for i, w in enumerate(anchos)}
    zmax = zb + len(anchos) - 1
    wmax = max(anchos)
    cinto = [z for z, w in w_de.items() if w == wmax][1:3]  # 2 capas del medio de la parte ancha
    for z, w in w_de.items():
        t = (z - zb) / (zmax - zb)
        sig = w_de.get(z + 1, -1)
        for x in range(-w, w + 1):
            for y in range(-w, w + 1):
                d = abs(x) + abs(y)
                if d > w:
                    continue
                borde = d == w
                escalon = d > sig
                if not borde and not escalon:
                    continue  # hueco: adentro va la flor
                if borde and (x == 0 or y == 0) or (escalon and borde):
                    celdas[(x, y, z)] = "Faceta"
                else:
                    v = t + (random.Random(f"d{x},{y},{z}").random() - 0.5) * 0.25
                    celdas[(x, y, z)] = "BlancoClaro" if v > 0.62 else "BlancoMedio" if v > 0.3 else "BlancoOscuro"
    # flor adentro, de frente: centro que brilla y 8 pétalos rosas en el plano x-z
    zc = cinto[0] - 3  # debajo del cinto, donde el vidrio deja verla de frente

    def adentro(x, y, z):
        return z in w_de and abs(x) + abs(y) < w_de[z]

    for x in range(-1, 2):
        for y in range(-1, 2):
            for z in range(zc - 1, zc + 2):
                celdas[(x, y, z)] = "Corazon"
    for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, 1), (1, -1), (-1, -1)):
        recto = dx == 0 or dz == 0
        largo = 4 if recto else 3
        for k in range(2, 2 + largo):
            # pétalo recto: 3 de ancho; en diagonal: 2 cubitos en escalera
            puntos = [(dx * k - dz * w, zc + dz * k + dx * w) for w in (-1, 0, 1)] if recto else [
                (dx * k, zc + dz * k), (dx * k, zc + dz * (k - 1))]
            for x, z in puntos:
                for y in (-1, 0):
                    if adentro(x, y, z) and (x, y, z) not in celdas:
                        celdas[(x, y, z)] = "PetaloClaro" if k == 1 + largo else "Petalo"
    # cinto de oro con remaches, 4 garras y 3 gemitas
    for z in cinto:
        for x in range(-wmax - 1, wmax + 2):
            for y in range(-wmax - 1, wmax + 2):
                if abs(x) + abs(y) == wmax + 1:
                    celdas[(x, y, z)] = "Oro"
    for x in range(-wmax - 2, wmax + 3):
        for y in range(-wmax - 2, wmax + 3):
            if abs(x) + abs(y) == wmax + 2 and (x + y) % 3 == 0:
                celdas[(x, y, cinto[0])] = "Remache"
    for sx, sy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        for z in range(cinto[-1] + 1, zmax + 1):
            r = w_de[z] + 1
            celdas[(sx * r, sy * r, z)] = "Oro"
        for z in range(cinto[0] - 3, cinto[0]):
            r = w_de[z] + 1
            celdas[(sx * r, sy * r, z)] = "Oro"
    for (gx, gy), clave in (((0, -wmax - 2), "Gemita"), ((-wmax - 2, 0), "GemitaVerde"), ((wmax + 2, 0), "GemitaVerde")):
        for a in (0, 1):  # gemita de 2 x 2 pegada al cinto, mirando hacia afuera
            for b in (0, 1):
                c = (a, gy, cinto[0] + b) if gx == 0 else (gx, a, cinto[0] + b)
                celdas[c] = clave
    # cristales que crecen de la roca: blancos con punta rosa
    for x, y, alto_c in ((-7, 2, 4), (-6, 3, 2), (6, -3, 3), (7, 2, 5), (-4, 5, 3), (4, 5, 2), (-5, -4, 2), (3, -6, 3)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto_c):
            celdas[(x, y, z)] = "Cristal" if z < z0 + alto_c - 1 else "CristalRosa"
    for x, y in ((-3, -5), (5, 4), (-7, -1)):
        if (x, y, 2) in celdas:
            celdas[(x, y, 3)] = "Pasto"
    colores = {
        "BlancoOscuro": ("#BCD0EA", 0.05, None, 0.0, 0.4),
        "BlancoMedio": ("#DCEAFF", 0.05, None, 0.0, 0.3),
        "BlancoClaro": ("#F4F9FF", 0.05, None, 0.0, 0.25),
        "Faceta": ("#FFFFFF", 0.05, "#DDEBFF", 0.35, 0.7),
        "Corazon": ("#FFF3B0", 0.2, "#FFE680", 4.0, 1),
        "Petalo": ("#FF4F9A", 0.3, "#FF4F9A", 0.8, 1),
        "PetaloClaro": ("#FFA8CF", 0.3, "#FFA8CF", 1.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Gemita": ("#FF5FA2", 0.05, "#FF5FA2", 0.6, 1),
        "GemitaVerde": ("#3FE07E", 0.05, "#3FE07E", 0.5, 1),
        "Cristal": ("#EEF4FF", 0.1, None, 0.0, 1),
        "CristalRosa": ("#FF9CC8", 0.15, "#FF9CC8", 0.5, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def jade_arcoiris(nombre):
    """Gema mítica de cubitos: torre de capas que se alternan entre cuadrado y rombo, con una
    cáscara de vidrio que pasa por el arcoíris de abajo (rojo) a arriba (violeta), un núcleo de
    jade que brilla adentro, bordes de oro con remaches de plata en cada capa, y un anillo cuadrado
    de plata alrededor (malla aparte, para que gire). Va sobre un zócalo de oro y una roca."""
    celdas = {}
    for x in range(-7, 8):
        for y in range(-7, 8):
            r = math.hypot(x / 7.5, y / 7.5) + (random.Random(f"r{x // 2},{y // 2}").random() - 0.5) * 0.15
            for z in range(3):
                if r < 1 - z * 0.1:
                    oscura = z < 2 and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else "Roca"
    for x in range(-5, 6):  # zócalo de oro
        for y in range(-5, 6):
            celdas[(x, y, 3)] = "Oro"
    # capas: (desde z, hasta z, medida, rombo?)
    capas = [(4, 7, 6, False), (8, 10, 7, True), (11, 14, 5, False), (15, 17, 6, True),
             (18, 20, 3, False), (21, 23, 4, True), (24, 25, 1, False)]
    arcoiris = ["Rojo", "Naranja", "Amarillo", "Verde", "Celeste", "Azul", "Violeta"]
    z0, zmax = capas[0][0], capas[-1][1]

    def medida(x, y, rombo):
        return abs(x) + abs(y) if rombo else max(abs(x), abs(y))

    for desde, hasta, r, rombo in capas:
        for z in range(desde, hasta + 1):
            for x in range(-r, r + 1):
                for y in range(-r, r + 1):
                    d = medida(x, y, rombo)
                    if d > r:
                        continue
                    if d <= r - 2 and z < hasta:
                        celdas[(x, y, z)] = "Nucleo"
                    elif d >= r - 1 or z == hasta:
                        if d == r and z == hasta:
                            # borde de cada capa: esquinas de oro y remaches de plata salteados
                            esquina = (abs(x) == abs(y)) if not rombo else (x == 0 or y == 0)
                            if esquina or (x + y) % 4 == 0:
                                celdas[(x, y, z)] = "Oro" if esquina else "Plata"
                                continue
                        t = (z - z0 + (random.Random(f"j{x},{y},{z}").random() - 0.5) * 2.2) / (zmax - z0 + 1)
                        celdas[(x, y, z)] = arcoiris[max(0, min(6, int(t * 7)))]
    # anillo cuadrado de plata que gira, a media altura, con dientes arriba y abajo
    for x in range(-9, 10):
        for y in range(-9, 10):
            if max(abs(x), abs(y)) == 9:
                celdas[(x, y, 12)] = celdas[(x, y, 13)] = "Anillo"
                if (x + y) % 4 == 0:
                    celdas[(x, y, 14)] = celdas[(x, y, 11)] = "Anillo"
    colores = {
        "Rojo": ("#F02828", 0.1, "#F02828", 0.25, 0.85),
        "Naranja": ("#FF7A10", 0.1, "#FF7A10", 0.25, 0.85),
        "Amarillo": ("#FFD210", 0.1, "#FFD210", 0.25, 0.85),
        "Verde": ("#18C850", 0.1, "#18C850", 0.25, 0.85),
        "Celeste": ("#10C0E8", 0.1, "#10C0E8", 0.25, 0.85),
        "Azul": ("#2850F0", 0.1, "#2850F0", 0.25, 0.85),
        "Violeta": ("#9030F0", 0.1, "#9030F0", 0.25, 0.85),
        "Nucleo": ("#2FBF71", 0.2, "#3DFF8C", 1.5, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Anillo": ("#D9E2EC", 0.2, "#BFD4FF", 0.3, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def trebol_de_cristal(nombre):
    """Gema mítica de cubitos: trébol de 4 hojas parado, de vidrio verde en capas (más fino en el
    borde y más grueso al medio, degradé de verde oscuro abajo a verde claro arriba, venas claras)
    con un núcleo dorado que brilla adentro de cada hoja, borde de oro con remaches de plata y un
    botón de oro al centro. Lo sostiene un tallo verde sobre un zócalo de oro y una roca, y a media
    altura gira un anillo cuadrado de plata (malla aparte)."""
    celdas = {}
    for x in range(-7, 8):
        for y in range(-7, 8):
            r = math.hypot(x / 7.5, y / 7.5) + (random.Random(f"r{x // 2},{y // 2}").random() - 0.5) * 0.15
            for z in range(3):
                if r < 1 - z * 0.1:
                    oscura = z < 2 and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else "Roca"
    for x in range(-4, 5):  # zócalo de oro
        for y in range(-4, 5):
            celdas[(x, y, 3)] = "Oro"
    zc = 17  # centro del trébol

    def en_hoja(x, z):
        """4 hojas en diagonal: cada una, 2 lóbulos y un triángulo que llega al centro."""
        for sx in (-1, 1):
            for sz in (-1, 1):
                u, v = sx * (x + 0.5) - 0.5, sz * (z - zc)
                if u < 1 or v < 1:
                    continue  # canal entre hojas: así se leen las 4 por separado
                if math.hypot(u - 5.2, v - 2.8) <= 2.5 or math.hypot(u - 2.8, v - 5.2) <= 2.5:
                    return True
                if u + v <= 5.5:
                    return True
        return abs(x + 0.5) <= 1.5 and abs(z - zc) <= 1  # centro que une las hojas

    plano = {(x, z) for x in range(-9, 10) for z in range(zc - 9, zc + 10) if en_hoja(x, z)}

    def hondo(x, z):
        for k in range(1, 4):
            if any((x + dx * k, z + dz * k) not in plano for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                return k
        return 3

    zmin = min(z for _, z in plano)
    zmax = max(z for _, z in plano)
    for x, z in plano:
        k = hondo(x, z)
        t = (z - zmin) / (zmax - zmin)
        vena = abs(abs(x + 0.5) - abs(z - zc)) < 0.6 and abs(x + 0.5) > 1  # diagonales: venas
        for y in range(-k, k + 1):
            if k >= 3 and abs(y) <= 1:
                celdas[(x, y, z)] = "Nucleo"
                continue
            if abs(y) != k and k > 1:
                continue  # hueco: se ve el núcleo
            if abs(y) == k and vena:
                celdas[(x, y, z)] = "Vena"
            elif k == 1:
                celdas[(x, y, z)] = "Faceta"
            else:
                v = t + (random.Random(f"t{x},{y},{z}").random() - 0.5) * 0.25
                celdas[(x, y, z)] = "VerdeClaro" if v > 0.62 else "VerdeMedio" if v > 0.3 else "VerdeOscuro"
    # borde de oro con remaches de plata
    for x, z in plano:
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            c = (x + dx, z + dz)
            if c not in plano:
                celdas[(c[0], 0, c[1])] = "Oro"
                if (c[0] * 2 + c[1]) % 5 == 0:
                    celdas[(c[0], 1, c[1])] = celdas[(c[0], -1, c[1])] = "Plata"
    # botón de oro al centro, adelante y atrás
    for x in (-1, 0):
        for z in (zc - 1, zc, zc + 1):
            for y in (-4, 4):
                celdas[(x, y, z)] = "Oro"
    celdas[(-1, -5, zc)] = celdas[(0, -5, zc)] = celdas[(-1, 5, zc)] = celdas[(0, 5, zc)] = "Plata"
    # tallo verde con una curvita, y collar de oro arriba
    for z in range(4, zmin + 1):
        dx = 1 if 7 <= z <= 10 else 0
        for x in (-1 + dx, dx):
            for y in (-1, 0):
                celdas[(x, y, z)] = "Tallo" if z < zmin - 1 else "Oro"
    # anillo cuadrado de plata alrededor del tallo (gira)
    for x in range(-7, 8):
        for y in range(-7, 8):
            if max(abs(x), abs(y)) == 7:
                celdas[(x, y, 8)] = "Anillo"
                if (x + y) % 3 == 0:
                    celdas[(x, y, 9)] = "Anillo"
    colores = {
        "VerdeOscuro": ("#0A7A3A", 0.05, None, 0.0, 0.7),
        "VerdeMedio": ("#22B85A", 0.05, None, 0.0, 0.6),
        "VerdeClaro": ("#6BF08E", 0.05, None, 0.0, 0.55),
        "Faceta": ("#C9FFD6", 0.05, "#8CFFA8", 0.3, 0.8),
        "Vena": ("#D8FFB0", 0.1, "#C8FF80", 0.6, 0.9),
        "Nucleo": ("#E8FF9A", 0.2, "#D4FF6A", 1.5, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Tallo": ("#2E8B3E", 0.6, None, 0.0, 1),
        "Anillo": ("#D9E2EC", 0.2, "#BFD4FF", 0.3, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def aurora_verde(nombre):
    """Gema celestial de cubitos: cristal verde claro en capas (punta escalonada arriba y abajo,
    3 tonos, aristas claras, cinto de oro con remaches) con un núcleo que brilla fuerte, rodeado
    por 2 cintas de luz verde y celeste en espiral. Flota sobre un pedestal chiquito de la
    Pradera (escalones de piedra y pasto con cristalitos). Atrás, un halo cuadrado de luz; alrededor,
    un anillo grande cuadrado y 3 gemitas que orbitan. Lo que se mueve va en mallas aparte:
    Anillo, Halo y cada Gemita."""
    celdas = {}
    # pedestal chiquito en escalones
    for z, r, clave in ((0, 6, "Roca"), (1, 5, "Roca"), (2, 4, "Pasto"), (3, 3, "Piedra")):
        for x in range(-r, r + 1):
            for y in range(-r, r + 1):
                if max(abs(x), abs(y)) <= r and not (abs(x) == r and abs(y) == r):
                    oscura = clave == "Roca" and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else clave
    for x, y, z0, alto in ((-5, 2, 2, 2), (5, -3, 2, 3), (2, 5, 2, 2), (-3, -5, 2, 2), (4, 4, 3, 1)):
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Cristalito"
    # gema en capas: medio ancho del cuadrado en cada capa
    anchos = [0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 5, 5, 5, 4, 4, 3, 2, 2, 1, 0]
    zb = 7
    w_de = {zb + i: w for i, w in enumerate(anchos)}
    zmax = zb + len(anchos) - 1
    wmax = max(anchos)
    cinto = [z for z, w in w_de.items() if w == wmax][1]
    for z, w in w_de.items():
        t = (z - zb) / (zmax - zb)
        arriba, abajo = w_de.get(z + 1, -1), w_de.get(z - 1, -1)
        for x in range(-w, w + 1):
            for y in range(-w, w + 1):
                d = max(abs(x), abs(y))
                if d <= w - 2 and 0 < z - zb < len(anchos) - 1:
                    celdas[(x, y, z)] = "Nucleo"
                    continue
                if d < w and d <= arriba and d <= abajo:
                    continue  # hueco: se ve el núcleo
                if z == cinto and d == w:
                    celdas[(x, y, z)] = "Remache" if (x + y) % 3 == 0 else "Oro"
                elif d == w and abs(x) == abs(y) or d > arriba or d > abajo:
                    celdas[(x, y, z)] = "Faceta"
                else:
                    v = t + (random.Random(f"a{x},{y},{z}").random() - 0.5) * 0.25
                    celdas[(x, y, z)] = "VerdeClaro" if v > 0.6 else "VerdeMedio" if v > 0.3 else "VerdeOscuro"
    celdas[(0, 0, zmax + 1)] = "Oro"  # puntita de oro arriba
    celdas[(0, 0, zb - 1)] = "Oro"

    # cintas de luz en espiral alrededor de la gema
    def borde(i, r):
        """Punto i del contorno de un cuadrado de medio ancho r (recorrido en vueltas)."""
        lado = 2 * r
        i %= 4 * lado
        tramo, k = divmod(i, lado)
        return [(-r + k, -r), (r, -r + k), (r - k, r), (-r, r - k)][tramo]

    for fase, clave in ((0, "CintaVerde"), (14, "CintaCeleste")):
        for z in range(zb + 1, zmax):
            for paso in range(3):
                x, y = borde(fase + (z - zb) * 3 + paso, wmax + 2)
                celdas[(x, y, z)] = clave
    # halo cuadrado de luz atrás (vertical)
    hz = (zb + zmax) // 2
    for x in range(-7, 8):
        for z in range(hz - 7, hz + 8):
            if max(abs(x), abs(z - hz)) == 7 or (max(abs(x), abs(z - hz)) == 6 and (x + z) % 2 == 0):
                celdas[(x, 9, z)] = "Halo"
    # anillo grande cuadrado alrededor (horizontal)
    for x in range(-9, 10):
        for y in range(-9, 10):
            if max(abs(x), abs(y)) == 9 and y != 9:
                celdas[(x, y, cinto - 3)] = "Anillo"
                if (x + y) % 4 == 0:
                    celdas[(x, y, cinto - 2)] = "Anillo"
    # 3 gemitas que orbitan (cubitos de 2 x 2 x 2)
    for (gx, gy, gz), clave in (((-9, -3, zb + 2), "Gemita1"), ((7, -6, cinto + 3), "Gemita2"),
                                ((-6, 6, zmax - 1), "Gemita3")):
        for a in range(2):
            for b in range(2):
                for c in range(2):
                    celdas[(gx + a, gy + b, gz + c)] = clave
    colores = {
        "VerdeOscuro": ("#139A4A", 0.05, None, 0.0, 0.75),
        "VerdeMedio": ("#3CCB6E", 0.05, None, 0.0, 0.65),
        "VerdeClaro": ("#8AF0A8", 0.05, None, 0.0, 0.55),
        "Faceta": ("#C8FFD8", 0.05, "#8AF0A8", 0.2, 0.8),
        "Nucleo": ("#B8FFD0", 0.2, "#5CFF8A", 2.5, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "CintaVerde": ("#2EE86A", 0.1, "#2EE86A", 1.2, 0.85),
        "CintaCeleste": ("#2EC8F0", 0.1, "#2EC8F0", 1.2, 0.85),
        "Halo": ("#7DFFB0", 0.1, "#5CFF8A", 0.8, 0.5),
        "Anillo": ("#E6F0F2", 0.2, "#C8F0FF", 0.4, 1),
        "Gemita1": ("#5CE6FF", 0.05, "#5CE6FF", 0.8, 1),
        "Gemita2": ("#5CFF8A", 0.05, "#5CFF8A", 0.8, 1),
        "Gemita3": ("#FFFFFF", 0.05, "#E0FFF0", 0.8, 1),
        "Cristalito": ("#8CEBA8", 0.1, "#8CEBA8", 0.4, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
        "Piedra": ("#B8BCC4", 0.7, None, 0.0, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def semilla_del_mundo(nombre):
    """Gema celestial de cubitos: semilla dorada gigante en capas (punta abajo, 3 tonos de oro,
    surcos oscuros, 2 grietas de ámbar transparente) con un núcleo que brilla fuerte y se asoma por
    arriba, de donde sale un brote: tallo verde y 3 hojas de cristal verde con venas que brillan.
    Flota sobre un pedestal chiquito de la Pradera. Atrás, un halo cuadrado de luz; alrededor, un
    anillo grande cuadrado y 3 gemitas que orbitan, cada una en su malla para animarla."""
    celdas = {}
    for z, r, clave in ((0, 6, "Roca"), (1, 5, "Roca"), (2, 4, "Pasto"), (3, 3, "Piedra")):
        for x in range(-r, r + 1):
            for y in range(-r, r + 1):
                if not (abs(x) == r and abs(y) == r):
                    oscura = clave == "Roca" and random.Random(f"{x},{y},{z}").random() < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else clave
    for x, y, z0, alto in ((-5, 2, 2, 2), (5, -3, 2, 3), (2, 5, 2, 2), (-3, -5, 2, 2), (4, 4, 3, 1)):
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Cristalito"
    # semilla: medio ancho del cuadrado en cada capa
    anchos = [0, 1, 2, 3, 4, 4, 5, 5, 5, 5, 4, 4, 3]
    zb = 6
    w_de = {zb + i: w for i, w in enumerate(anchos)}
    ztop = zb + len(anchos) - 1
    for z, w in w_de.items():
        t = (z - zb) / (ztop - zb)
        arriba, abajo = w_de.get(z + 1, -1), w_de.get(z - 1, -1)
        for x in range(-w, w + 1):
            for y in range(-w, w + 1):
                d = max(abs(x), abs(y))
                if d <= w - 2 and z > zb:
                    celdas[(x, y, z)] = "Nucleo"
                    continue
                if d < w and d <= arriba and d <= abajo:
                    continue
                if z == ztop and d <= 1:
                    celdas[(x, y, z)] = "Nucleo"  # la semilla se abre arriba: se ve el brillo
                    continue
                cara = y if abs(x) == w else x  # coordenada a lo largo de la cara
                if d == w and abs(cara) == 2 and abs(x) != abs(y):
                    celdas[(x, y, z)] = "Surco"
                elif d == w and ((x == w and y == 0) or (y == -w and x == 1)) and zb + 3 <= z <= ztop - 2:
                    celdas[(x, y, z)] = "Ambar"  # grietas por donde se ve el núcleo
                else:
                    v = t + (random.Random(f"s{x},{y},{z}").random() - 0.5) * 0.25
                    celdas[(x, y, z)] = "OroClaro" if v > 0.62 else "OroMedio" if v > 0.3 else "OroOscuro"
    celdas[(0, 0, zb - 1)] = "OroOscuro"
    # brote: tallo y 3 hojas de cristal con vena que brilla
    for z in range(ztop + 1, ztop + 6):
        for x in (-1, 0):
            for y in (-1, 0):
                celdas[(x, y, z)] = "Tallo"

    def hoja(base_z, sx, sy, largo):
        """Hoja en diagonal hacia arriba y afuera, en rombo de cubitos, con la vena al medio."""
        for u in range(1, largo + 1):
            ancho = min(u, largo + 1 - u) // 2 + 1
            centro = base_z + round(u * 0.7)
            for dz in range(-ancho, ancho + 1):
                for grosor in (-1, 0):
                    x = sx * u + (grosor if sy else 0) - (1 if sx < 0 else 0)
                    y = sy * u + (grosor if sx else 0) - (1 if sy < 0 else 0)
                    if sx and sy:
                        continue
                    celdas[(x, y, centro + dz)] = "Vena" if dz == 0 and grosor == 0 else "Hoja"

    hoja(ztop + 3, -1, 0, 7)
    hoja(ztop + 4, 1, 0, 7)
    hoja(ztop + 5, 0, -1, 5)
    for x in (-1, 0):  # yema de arriba
        for y in (-1, 0):
            celdas[(x, y, ztop + 6)] = celdas[(x, y, ztop + 7)] = "Hoja"
    celdas[(0, 0, ztop + 8)] = "Vena"
    zmax = max(c[2] for c in celdas)
    # halo cuadrado de luz atrás
    hz = (zb + zmax) // 2
    for x in range(-7, 8):
        for z in range(hz - 7, hz + 8):
            m_ = max(abs(x), abs(z - hz))
            if m_ == 7 or (m_ == 6 and (x + z) % 2 == 0):
                celdas[(x, 9, z)] = "Halo"
    # anillo grande cuadrado
    for x in range(-9, 10):
        for y in range(-9, 10):
            if max(abs(x), abs(y)) == 9 and y != 9:
                celdas[(x, y, zb + 6)] = "Anillo"
                if (x + y) % 4 == 0:
                    celdas[(x, y, zb + 7)] = "Anillo"
    for (gx, gy, gz), clave in (((-9, -3, zb + 2), "Gemita1"), ((7, -6, zb + 10), "Gemita2"),
                                ((-6, 6, zmax - 3), "Gemita3")):
        for a in range(2):
            for b in range(2):
                for c in range(2):
                    celdas[(gx + a, gy + b, gz + c)] = clave
    colores = {
        "OroOscuro": ("#B07A12", 0.3, None, 0.0, 1),
        "OroMedio": ("#E0A82A", 0.25, None, 0.0, 1),
        "OroClaro": ("#FFD45C", 0.2, "#FFD45C", 0.1, 1),
        "Surco": ("#7A5008", 0.4, None, 0.0, 1),
        "Ambar": ("#FFB830", 0.05, None, 0.0, 0.5),
        "Nucleo": ("#FFF6C0", 0.2, "#FFE680", 4.0, 1),
        "Tallo": ("#2E8B3E", 0.6, None, 0.0, 1),
        "Hoja": ("#3CE07A", 0.05, None, 0.0, 0.6),
        "Vena": ("#C8FFB0", 0.1, "#9CFF80", 2.0, 1),
        "Halo": ("#FFE9A0", 0.1, "#FFD860", 0.8, 0.5),
        "Anillo": ("#FFE58A", 0.2, None, 0.0, 1),
        "Gemita1": ("#3CE07A", 0.05, "#3CE07A", 0.8, 1),
        "Gemita2": ("#FFD45C", 0.05, "#FFD45C", 0.8, 1),
        "Gemita3": ("#5CE6FF", 0.05, "#5CE6FF", 0.8, 1),
        "Cristalito": ("#8CEBA8", 0.1, "#8CEBA8", 0.4, 1),
        "Pasto": ("#4E9A3A", 0.8, None, 0.0, 1),
        "Piedra": ("#B8BCC4", 0.7, None, 0.0, 1),
        "Roca": ("#8A8F99", 0.8, None, 0.0, 1),
        "RocaOscura": ("#5D626C", 0.85, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def arenisca(nombre):
    """Piedra en bruto de cubitos (Dunas): trozo de arenisca en capas que se escalonan como una
    meseta chica, franjas naranja, arena y crema (cada una más clara arriba), vetas claras,
    2 grietas marrones, 3 cristalitos de ámbar (uno de vidrio con núcleo) y base de tierra
    rojiza con piedritas."""
    rng = random.Random(21)
    celdas = {}
    for x in range(-9, 10):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 6.5) + (h(x // 2, y // 2, 0, 5) - 0.5) * 0.35
            if r < 1:
                celdas[(x, y, 0)] = "TierraOscura"
            if r < 0.85:
                celdas[(x, y, 1)] = "Tierra" if h(x, y, 1, 6) > 0.1 else "TierraOscura"
    # franjas (desde abajo): cada capa de 2 cubitos se achica y se corre, así quedan escalones
    franjas = ["Naranja", "Arena", "Crema", "Naranja", "Arena", "Crema"]
    capas = [(1 + 2 * i + j, i, f) for i, f in enumerate(franjas) for j in range(2)]
    tope = capas[-1][0]
    for z, i, f in capas:
        t = i / (len(franjas) - 1)
        cx, cy = round(1.5 * t), round(-1.0 * t)
        rx, ry = 7.0 * (1 - 0.55 * t**1.3), 5.4 * (1 - 0.5 * t**1.2)
        for x in range(-9, 10):
            for y in range(-7, 8):
                ruido = (h(x // 3, y // 3, i, 8) - 0.5) * 0.5
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1 + ruido:
                    continue
                if x + y > 10 - i * 1.2:  # canto partido en diagonal
                    continue
                tono = z / tope + (h(x, y, z, 9) - 0.5) * 0.15
                celdas[(x, y, z)] = f + ("Claro" if tono > 0.6 else "" if tono > 0.3 else "Oscuro")
    llenas = set(celdas)

    def afuera(c):
        x, y, z = c
        return any((x + dx, y + dy, z + dz) not in llenas for (dx, dy, dz), _ in m.CARAS[:5])

    roca = sorted(c for c, k in celdas.items() if not k.startswith("Tierra") and afuera(c))
    # vetas: puntitos claros sueltos que cortan las franjas
    for c in roca:
        if h(*c, 12) < 0.05:
            celdas[c] = "Veta"
    # grietas: caminos de cubitos marrones que bajan por la superficie
    for inicio in ((-4, -4, 10), (5, 2, 8)):
        c = min(roca, key=lambda p: sum((a - b) ** 2 for a, b in zip(p, inicio)))
        for _ in range(8):
            celdas[c] = "Grieta"
            vec = [
                p for p in roca
                if p[2] <= c[2] and sum(abs(a - b) for a, b in zip(p, c)) == 1 and celdas[p] != "Grieta"
            ]
            if not vec:
                break
            c = rng.choice(vec)

    def columna(x0, y0, z0, lado, alto, clave, corre=(0, 0)):
        for i in range(alto):
            dx, dy = corre[0] * (i // 2), corre[1] * (i // 2)
            ancho = lado if i < alto - 1 else max(1, lado - 2)
            off = (lado - ancho) // 2
            for a in range(ancho):
                for b in range(ancho):
                    celdas[(x0 + dx + off + a, y0 + dy + off + b, z0 + i)] = clave

    # cristalitos de ámbar: uno de vidrio arriba con núcleo, dos macizos a los costados
    columna(0, -2, tope - 1, 3, 3, "Vidrio", corre=(1, 0))
    celdas[(1, -1, tope)] = celdas[(1, -1, tope + 1)] = "Nucleo"
    columna(-6, 1, 4, 2, 4, "Ambar", corre=(-1, 1))
    columna(4, -5, 2, 2, 3, "Ambar", corre=(1, -1))
    # piedritas y montoncitos de arena en la tierra
    for x, y in ((-8, 2), (7, 3), (-3, 6), (2, 6)):
        celdas[(x, y, 1)] = celdas[(x, y, 2)] = "Piedrita"
    for x, y in ((6, -4), (-7, -3)):
        celdas[(x, y, 2)] = "Arenita"
    colores = {
        "NaranjaOscuro": ("#B8561E", 0.75, None, 0.0, 1),
        "Naranja": ("#E07A2E", 0.7, None, 0.0, 1),
        "NaranjaClaro": ("#F29A4A", 0.7, None, 0.0, 1),
        "ArenaOscuro": ("#C99A55", 0.75, None, 0.0, 1),
        "Arena": ("#E3B86E", 0.7, None, 0.0, 1),
        "ArenaClaro": ("#F2D08C", 0.7, None, 0.0, 1),
        "CremaOscuro": ("#E2CFA6", 0.7, None, 0.0, 1),
        "Crema": ("#F4E6C4", 0.65, None, 0.0, 1),
        "CremaClaro": ("#FFF6E0", 0.6, None, 0.0, 1),
        "Veta": ("#FFFBEF", 0.5, None, 0.0, 1),
        "Grieta": ("#6E3A18", 0.85, None, 0.0, 1),
        "Ambar": ("#FFB347", 0.2, "#FF9A2E", 0.35, 1),
        "Vidrio": ("#FFE1A8", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#FF8C1A", 0.2, "#FF8C1A", 2.0, 1),
        "Tierra": ("#9C4F2C", 0.85, None, 0.0, 1),
        "TierraOscura": ("#6E3420", 0.9, None, 0.0, 1),
        "Piedrita": ("#7A6A5C", 0.8, None, 0.0, 1),
        "Arenita": ("#D9B27A", 0.8, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def ambar(nombre):
    """Piedra en bruto de cubitos (Dunas): gota de ámbar translúcido en escalones (ancha abajo,
    punta corrida arriba), cáscara de vidrio naranja en 3 tonos (más clara arriba) con un corazón
    macizo que brilla y una ramita oscura atrapada adentro, 2 grietas, 3 cristalitos de miel
    y base de roca y tierra rojiza."""
    rng = random.Random(33)
    celdas = {}
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 7.5, y / 6.5) + (h(x // 2, y // 2, 0, 13) - 0.5) * 0.4
            if r < 1:
                celdas[(x, y, 0)] = "Roca" if h(x, y, 0, 14) > 0.6 else "TierraOscura"
            if r < 0.8:
                celdas[(x, y, 1)] = "Tierra" if h(x, y, 1, 15) > 0.12 else "Roca"
    # gota: radio que crece rápido, panza abajo y se afina hacia una punta corrida
    tope = 14
    for z in range(1, tope + 1):
        t = (z - 1) / (tope - 1)
        rad = 5.8 * math.sin(math.pi * min(1.0, 0.25 + t * 0.85)) ** 0.8 * (1 - 0.6 * t)
        rad = max(rad, 1.0)
        cx, cy = round(2.2 * t**2), round(-0.6 * t)
        for x in range(-8, 9):
            for y in range(-7, 8):
                ruido = (h(x // 2, y // 2, z // 3, 16) - 0.5) * 0.45
                if math.hypot(x - cx, (y - cy) * 1.15) > rad * (1 + ruido * 0.5) + 0.3:
                    continue
                if -x + y > 8 - z * 0.3:  # canto partido
                    continue
                v = t + (h(x, y, z, 17) - 0.5) * 0.12
                celdas[(x, y, z)] = "Claro" if v > 0.6 else "Medio" if v > 0.28 else "Oscuro"
    llenas = set(celdas)

    def afuera(c):
        x, y, z = c
        return any((x + dx, y + dy, z + dz) not in llenas for (dx, dy, dz), _ in m.CARAS)

    # adentro: lo que no toca el aire es corazón macizo (se ve a través del vidrio)
    gota = [c for c, k in celdas.items() if k in ("Claro", "Medio", "Oscuro")]
    for c in gota:
        if not afuera(c) and c[2] >= 3:
            celdas[c] = "Corazon"
    # ramita atrapada: palito oscuro con dos brazos
    for c in ((0, 0, 4), (0, 0, 5), (1, 0, 6), (1, 0, 7), (2, 0, 8), (0, 0, 6), (-1, 0, 7), (2, 0, 6)):
        if celdas.get(c) == "Corazon":
            celdas[c] = "Ramita"
    llenas = set(celdas)
    piel = sorted(c for c in gota if celdas[c] in ("Claro", "Medio", "Oscuro") and afuera(c))
    # burbujitas claras sueltas en la superficie
    for c in piel:
        if h(*c, 18) < 0.05:
            celdas[c] = "Burbuja"
    for inicio in ((-3, -4, 9), (4, 2, 5)):
        c = min(piel, key=lambda p: sum((a - b) ** 2 for a, b in zip(p, inicio)))
        for _ in range(7):
            celdas[c] = "Grieta"
            vec = [
                p for p in piel
                if p[2] <= c[2] and sum(abs(a - b) for a, b in zip(p, c)) == 1 and celdas[p] != "Grieta"
            ]
            if not vec:
                break
            c = rng.choice(vec)

    def columna(x0, y0, z0, lado, alto, clave, corre=(0, 0)):
        for i in range(alto):
            dx, dy = corre[0] * (i // 2), corre[1] * (i // 2)
            ancho = lado if i < alto - 1 else max(1, lado - 2)
            off = (lado - ancho) // 2
            for a in range(ancho):
                for b in range(ancho):
                    celdas[(x0 + dx + off + a, y0 + dy + off + b, z0 + i)] = clave

    # cristalitos de miel asomando: dos al costado, uno chico abajo adelante
    columna(-5, -1, 4, 2, 4, "Cristal", corre=(-1, 0))
    columna(4, -4, 3, 2, 3, "Cristal", corre=(1, -1))
    columna(-2, -6, 2, 1, 2, "Cristal")
    for x, y in ((-7, 3), (6, 4), (3, 6)):
        celdas[(x, y, 1)] = celdas[(x, y, 2)] = "Roca"
    colores = {
        "Oscuro": ("#C2480E", 0.08, None, 0.0, 0.6),
        "Medio": ("#F07818", 0.06, None, 0.0, 0.55),
        "Claro": ("#FFB040", 0.05, None, 0.0, 0.5),
        "Burbuja": ("#FFE6A8", 0.05, None, 0.0, 0.5),
        "Corazon": ("#FF8A10", 0.2, "#FF7A00", 1.2, 1),
        "Ramita": ("#3B1E0E", 0.8, None, 0.0, 1),
        "Grieta": ("#7A2E08", 0.7, None, 0.0, 1),
        "Cristal": ("#FFC85A", 0.15, "#FFB020", 0.4, 1),
        "Tierra": ("#9C4F2C", 0.85, None, 0.0, 1),
        "TierraOscura": ("#6E3420", 0.9, None, 0.0, 1),
        "Roca": ("#6E6460", 0.85, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def citrino(nombre):
    """Cristal de cubitos (Dunas): racimo de 4 columnas de citrino dorado de distintas alturas,
    inclinadas hacia afuera y con punta escalonada. Cada columna es una cáscara de vidrio en 3 tonos
    (ámbar abajo, limón arriba) con aristas claras y un centro macizo que brilla suave; salen de una
    base de roca de arena con vetas y hay cristalitos sueltos en la base."""
    celdas = {}
    # base de roca: loma chata de 3 capas, más oscura abajo
    for x in range(-9, 10):
        for y in range(-8, 9):
            r = math.hypot(x / 9, y / 8) + (h(x // 2, y // 2, 0, 41) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, 42)
                    celdas[(x, y, z)] = "Veta" if v < 0.05 else "RocaOscura" if z == 0 or v < 0.25 else "Roca"
    # columnas: (x, y, medio ancho, alto, inclinación x, inclinación y)
    columnas = [(0, 0, 2, 19, 0, 0), (-4, 2, 1, 13, -1, 1), (4, -1, 2, 14, 1, 0), (1, 4, 1, 10, 0, 1)]
    for cx, cy, a, alto, ix, iy in columnas:
        punta = a + 2  # capas de la punta escalonada
        for i in range(alto):
            z = 2 + i
            ox, oy = cx + ix * (i // 5), cy + iy * (i // 5)
            ancho = a if i < alto - punta else max(0, a - (i - (alto - punta)) // 2 - 1)
            t = i / (alto - 1)
            for x in range(-ancho, ancho + 1):
                for y in range(-ancho, ancho + 1):
                    c = (ox + x, oy + y, z)
                    borde = abs(x) == ancho or abs(y) == ancho
                    if not borde and i < alto - punta:
                        celdas[c] = "Centro"  # se ve a través del vidrio
                        continue
                    if abs(x) == ancho and abs(y) == ancho and ancho > 0:
                        celdas[c] = "Arista"
                        continue
                    v = t + (h(*c, 43) - 0.5) * 0.2
                    celdas[c] = "Claro" if v > 0.62 else "Medio" if v > 0.3 else "Oscuro"
    # cristalitos sueltos en la base
    for x, y, alto in ((-7, -3, 2), (7, 4, 3), (-2, -6, 2), (5, -5, 1), (-6, 5, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Suelto"
    colores = {
        "Oscuro": ("#D9820A", 0.05, None, 0.0, 0.7),
        "Medio": ("#F5B321", 0.05, None, 0.0, 0.6),
        "Claro": ("#FFE45C", 0.05, None, 0.0, 0.55),
        "Arista": ("#FFF6B8", 0.05, "#FFE97A", 0.25, 0.8),
        "Centro": ("#FFF0A0", 0.2, "#FFD84A", 1.0, 1),
        "Suelto": ("#FFD23F", 0.15, "#FFC21A", 0.4, 1),
        "Roca": ("#B58A5A", 0.85, None, 0.0, 1),
        "RocaOscura": ("#7E5A3A", 0.9, None, 0.0, 1),
        "Veta": ("#F0D9A8", 0.7, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def ojo_de_tigre(nombre):
    """Cristal de cubitos (Dunas): 3 columnas anchas y macizas de ojo de tigre pulido, de distintas
    alturas y punta escalonada. Rayas que cruzan cada columna: marrón oscuro, miel y dorado, con una
    raya fina que brilla (el reflejo de la piedra) y puntos claros sueltos en las rayas doradas.
    Salen de una base de roca oscura y hay cubitos dorados sueltos en la base."""
    celdas = {}
    for x in range(-9, 10):
        for y in range(-8, 9):
            r = math.hypot(x / 9, y / 8) + (h(x // 2, y // 2, 0, 51) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, 52)
                    celdas[(x, y, z)] = "RocaOscura" if z == 0 or v < 0.3 else "Roca"
    # columnas: (x, y, medio ancho, alto, inclinación x, inclinación y)
    columnas = [(-1, 0, 3, 19, 0, 0), (4, -2, 2, 13, 1, -1), (-5, 3, 2, 11, -1, 1)]
    rayas = ["Oscuro", "Oscuro", "Medio", "Dorado", "Brillo", "Dorado", "Medio"]
    for cx, cy, a, alto, ix, iy in columnas:
        punta = a + 3
        for i in range(alto):
            z = 2 + i
            ox, oy = cx + ix * (i // 6), cy + iy * (i // 6)
            ancho = a if i < alto - punta else max(0, a - (i - (alto - punta) + 1) // 2)
            raya = rayas[(i + cx) % len(rayas)]
            for x in range(-ancho, ancho + 1):
                for y in range(-ancho, ancho + 1):
                    c = (ox + x, oy + y, z)
                    if abs(x) < ancho and abs(y) < ancho and i < alto - punta:
                        celdas[c] = "Medio"  # relleno que no se ve (las caras se juntan)
                        continue
                    if raya == "Dorado" and h(*c, 53) < 0.35:
                        celdas[c] = "Claro"  # reflejo que corre por la raya
                    else:
                        celdas[c] = raya
    for x, y, alto in ((-8, -2, 2), (7, 4, 2), (1, -6, 1), (-3, 6, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Suelto"
    colores = {
        "Oscuro": ("#4A2410", 0.3, None, 0.0, 1),
        "Medio": ("#8A4E1C", 0.25, None, 0.0, 1),
        "Dorado": ("#C98A2E", 0.2, None, 0.0, 1),
        "Claro": ("#E8B456", 0.15, "#E8B456", 0.15, 1),
        "Brillo": ("#FFD77A", 0.1, "#FFC94A", 0.8, 1),
        "Suelto": ("#E0A040", 0.2, "#D9952A", 0.3, 1),
        "Roca": ("#5E534C", 0.85, None, 0.0, 1),
        "RocaOscura": ("#3E3632", 0.9, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


# nombre: (zona, rareza, forma, {clave: (color, brillo)})
PIEDRAS = {
    "Cuarzo": (
        1,
        "Comun",
        cuarzo,
        None,  # malla tallada: arma sus propias partes y colores
    ),
    "Jaspe": (
        1,
        "Comun",
        jaspe,
        None,
    ),
    "Amatista": (1, "Rara", amatista, None),
    "AgataMusgosa": (1, "Rara", agata_musgosa, None),
    "Esmeralda": (1, "Epica", esmeralda, None),
    "TurmalinaRosa": (1, "Epica", turmalina_rosa, None),
    "CorazondePradera": (1, "Legendaria", corazon_de_pradera, None),
    "DiamanteFloral": (1, "Legendaria", diamante_floral, None),
    "JadeArcoiris": (1, "Mitica", jade_arcoiris, None),
    "TreboldeCristal": (1, "Mitica", trebol_de_cristal, None),
    "AuroraVerde": (1, "Celestial", aurora_verde, None),
    "SemilladelMundo": (1, "Celestial", semilla_del_mundo, None),
    "Arenisca": (2, "Comun", arenisca, None),
    "Ambar": (2, "Comun", ambar, None),
    "Citrino": (2, "Rara", citrino, None),
    "OjodeTigre": (2, "Rara", ojo_de_tigre, None),
    "TopacioImperial": (2, "Epica", topacio_imperial, None),
    "Cornalina": (2, "Epica", cornalina, None),
}


# ---------------------------------------------------------------------------------------------
# Armado


def juntar_caras(obj):
    """Junta las caras planas vecinas (mismos cubitos, menos triángulos) y devuelve cuántos quedan."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.dissolve_limit(bm, angle_limit=math.radians(1), verts=bm.verts, edges=bm.edges)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    bm.to_mesh(obj.data)
    bm.free()
    return len(obj.data.polygons)


def armar(nombre):
    zona, rareza, forma, colores = PIEDRAS[nombre]
    alto, tope = RAREZAS[rareza]
    alto = ALTO.get(nombre, alto)
    tope = TOPE.get(nombre, tope)
    if colores is None:
        return armar_tallada(nombre, forma, alto, tope, zona)
    celdas = forma()
    zs = [c[2] for c in celdas]
    lado = alto * m.STUD / (max(zs) - min(zs) + 1)
    xs = [c[0] for c in celdas]
    ys = [c[1] for c in celdas]
    centro = (
        -(min(xs) + max(xs) + 1) / 2 * lado,
        -(min(ys) + max(ys) + 1) / 2 * lado,
        -(min(zs) + max(zs) + 1) / 2 * lado,
    )
    objetos, total = [], 0
    for clave, (color, brillo) in colores.items():
        grupo = {c for c, k in celdas.items() if k == clave}
        if not grupo:
            continue
        mat = m.material(
            f"{nombre}_{clave}", color, rugoso=0.2 if brillo else 0.5, brillo=color if brillo else None,
            fuerza_brillo=brillo,
        )
        # las caras entre grupos no se ven pero se dejan: así cada malla queda cerrada
        obj, t = m.voxeles(f"{nombre}_{clave.capitalize()}", grupo, lado, mat, origen=centro, ranura=0)
        t = juntar_caras(obj)
        objetos.append(obj)
        total += t
    if total > tope:
        raise RuntimeError(f"{nombre}: {total} triángulos (máximo {tope})")
    return objetos, total, zona


def armar_tallada(nombre, forma, alto, tope, zona):
    """Escala las partes al alto de la rareza y deja el pivote en el centro de la caja."""
    objetos = forma(nombre)
    vs = [v.co.copy() for o in objetos for v in o.data.vertices]
    lo = Vector([min(v[i] for v in vs) for i in range(3)])
    hi = Vector([max(v[i] for v in vs) for i in range(3)])
    k = alto * m.STUD / (hi.z - lo.z)
    centro = (lo + hi) / 2
    if nombre in PIVOTE_BASE:
        centro.z = lo.z
    total = 0
    for o in objetos:
        for v in o.data.vertices:
            v.co = (v.co - centro) * k
        o.data.update()
        total += len(o.data.polygons)
    if total > tope:
        raise RuntimeError(f"{nombre}: {total} triángulos (máximo {tope})")
    return objetos, total, zona


def escena_render_gema(transparente=False, cuadrado=False):
    escena = m.escena_render(512 if cuadrado else 1600, 512 if cuadrado else 900)
    if transparente:
        escena.render.film_transparent = True
        piso = bpy.data.objects.get("Plane")
        if piso:
            bpy.data.objects.remove(piso)
    return escena


def render_piedras(nombres):
    m.limpiar_escena()
    escena = escena_render_gema()
    ancho = 0.9
    for i, nombre in enumerate(nombres):
        x0 = (i - (len(nombres) - 1) / 2) * ancho * 2.2
        alto = ALTO.get(nombre, RAREZAS[PIEDRAS[nombre][1]][0]) * m.STUD
        subir = 0 if nombre in PIVOTE_BASE else alto / 2
        for j, giro in enumerate((0.0, math.radians(90))):
            objetos, t, _ = armar(nombre)
            m.mover(objetos, x0 + (j - 0.5) * ancho, giro=giro)
            for o in objetos:
                o.location.z += subir
        m.etiqueta(f"{nombre} ({t} tri)", x0, -0.6, tam=0.12)
    mas_alta = max(ALTO.get(n, RAREZAS[PIEDRAS[n][1]][0]) for n in nombres) * m.STUD
    lejos = max(3.2, mas_alta * 3.2) * max(1, len(nombres) * 0.8)
    m.camara(escena, (0, 0, max(0.25, mas_alta * 0.45)), lejos, 0.9, lente=50, giro=0)
    m.render("gema_" + "_".join(nombres))


def icono(nombre):
    m.limpiar_escena()
    escena = escena_render_gema(transparente=True, cuadrado=True)
    objetos, _, _ = armar(nombre)
    alto = ALTO.get(nombre, RAREZAS[PIEDRAS[nombre][1]][0]) * m.STUD
    m.camara(escena, (0, 0, alto / 2 if nombre in PIVOTE_BASE else 0), alto * 2.6, alto * 0.7, lente=50, giro=-30)
    ICONOS.mkdir(parents=True, exist_ok=True)
    ajustes = escena.render.image_settings
    ajustes.file_format = "PNG"
    ajustes.color_mode = "RGBA"
    escena.render.filepath = str(ICONOS / f"{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"  Icono {nombre}.png")


def exportar_zona(zona):
    m.limpiar_escena()
    objetos = []
    for nombre, datos in PIEDRAS.items():
        if datos[0] == zona and nombre in APROBADAS:
            partes, _, _ = armar(nombre)
            for p in partes:
                p.name = f"{nombre}__{p.name.split('_', 1)[1]}"
            objetos += partes
    m.exportar(objetos, f"Gemas_Zona{zona}.fbx")
    print(f"  Gemas_Zona{zona}.fbx: {len(objetos)} mallas")


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    nombres = [a for a in args if not a.startswith("--")] or list(PIEDRAS)
    for n in nombres:
        m.limpiar_escena()
        objs, t, _ = armar(n)
        vs = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
        med = [(max(v[i] for v in vs) - min(v[i] for v in vs)) / m.STUD for i in range(3)]
        print(f"  {n}: {t} triángulos, {med[0]:.2f} x {med[1]:.2f} x {med[2]:.2f} studs")
    if "--icono" in args:
        for n in nombres:
            icono(n)
    if "--exportar" in args:
        for z in sorted({PIEDRAS[n][0] for n in nombres}):
            exportar_zona(z)
    if "--icono" not in args and "--exportar" not in args:
        render_piedras(nombres)
    print("Listo")
