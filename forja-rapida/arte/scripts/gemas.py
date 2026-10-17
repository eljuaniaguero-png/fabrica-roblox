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
APROBADAS = {"Cuarzo", "Jaspe", "Amatista", "AgataMusgosa", "Esmeralda", "TurmalinaRosa", "CorazondePradera", "DiamanteFloral", "JadeArcoiris", "TreboldeCristal", "AuroraVerde", "SemilladelMundo", "Arenisca", "Ambar", "Citrino", "OjodeTigre", "TopacioImperial", "Cornalina", "SoldelDesierto", "EscarabajodeOro", "LagrimadeFaraon", "Espejismo", "CoronadelSol", "RelojdeArenaEterno", "CristaldeRoca", "PiedraEscarcha", "Aguamarina", "Celestina", "Zafiro", "PiedraLuna", "CorazondeHielo", "DiamantePolar", "AuroraBoreal", "EstrelladeEscarcha", "CopoEterno", "TronodeHielo", "Obsidiana", "BasaltoRojo", "Granate", "CristaldeAzufre", "Rubi", "OpalodeFuego", "NucleodeMagma", "PiedraFenix", "OjodeDragon", "LlamaViva", "CorazondelVolcan", "CoronaIgnea", "Meteorita", "PolvoEstelar", "Iolita", "FluoritaNocturna", "OpaloNegro", "Alejandrita", "FragmentodeNebulosa", "OjodelVacio", "CometaErrante", "GalaxiaEspiral", "Supernova", "AgujeroNegro"}

# Piedras con alto propio (studs) y pivote en el centro de la base en vez del centro de la caja
ALTO = {"Cuarzo": 2.5, "Jaspe": 2.5, "Amatista": 3.0, "AgataMusgosa": 3.0, "Esmeralda": 3.5, "TurmalinaRosa": 3.5, "CorazondePradera": 4.0, "DiamanteFloral": 4.0, "JadeArcoiris": 4.5, "TreboldeCristal": 4.5, "AuroraVerde": 5.0, "SemilladelMundo": 5.0, "Arenisca": 2.5, "Ambar": 2.5, "Citrino": 3.0, "OjodeTigre": 3.0, "TopacioImperial": 3.5, "Cornalina": 3.5, "SoldelDesierto": 4.0, "EscarabajodeOro": 4.0, "LagrimadeFaraon": 4.5, "Espejismo": 4.5, "CoronadelSol": 5.0, "RelojdeArenaEterno": 5.0, "CristaldeRoca": 2.5, "PiedraEscarcha": 2.5, "Aguamarina": 3.0, "Celestina": 3.0, "Zafiro": 3.5, "PiedraLuna": 3.5, "CorazondeHielo": 4.0, "DiamantePolar": 4.0, "AuroraBoreal": 4.5, "EstrelladeEscarcha": 4.5, "CopoEterno": 5.0, "TronodeHielo": 5.0, "Obsidiana": 2.5, "BasaltoRojo": 2.5, "Granate": 3.0, "CristaldeAzufre": 3.0, "Rubi": 3.5, "OpalodeFuego": 3.5, "NucleodeMagma": 4.0, "PiedraFenix": 4.0, "OjodeDragon": 4.5, "LlamaViva": 4.5, "CorazondelVolcan": 5.0, "CoronaIgnea": 5.0, "Meteorita": 2.5, "PolvoEstelar": 2.5, "Iolita": 3.0, "FluoritaNocturna": 3.0, "OpaloNegro": 3.5, "Alejandrita": 3.5, "FragmentodeNebulosa": 4.0, "OjodelVacio": 4.0, "CometaErrante": 4.5, "GalaxiaEspiral": 4.5, "Supernova": 5.0, "AgujeroNegro": 5.0}
PIVOTE_BASE = {"Cuarzo", "Jaspe", "Amatista", "AgataMusgosa", "Esmeralda", "TurmalinaRosa", "CorazondePradera", "DiamanteFloral", "JadeArcoiris", "TreboldeCristal", "AuroraVerde", "SemilladelMundo", "Arenisca", "Ambar", "Citrino", "OjodeTigre", "TopacioImperial", "Cornalina", "SoldelDesierto", "EscarabajodeOro", "LagrimadeFaraon", "Espejismo", "CoronadelSol", "RelojdeArenaEterno", "CristaldeRoca", "PiedraEscarcha", "Aguamarina", "Celestina", "Zafiro", "PiedraLuna", "CorazondeHielo", "DiamantePolar", "AuroraBoreal", "EstrelladeEscarcha", "CopoEterno", "TronodeHielo", "Obsidiana", "BasaltoRojo", "Granate", "CristaldeAzufre", "Rubi", "OpalodeFuego", "NucleodeMagma", "PiedraFenix", "OjodeDragon", "LlamaViva", "CorazondelVolcan", "CoronaIgnea", "Meteorita", "PolvoEstelar", "Iolita", "FluoritaNocturna", "OpaloNegro", "Alejandrita", "FragmentodeNebulosa", "OjodelVacio", "CometaErrante", "GalaxiaEspiral", "Supernova", "AgujeroNegro"}
# Topes de triángulos propios (pisan el de la rareza)
TOPE = {"Esmeralda": 4000, "TurmalinaRosa": 4000, "CorazondePradera": 6000, "DiamanteFloral": 6000, "JadeArcoiris": 8000, "TreboldeCristal": 8000, "AuroraVerde": 10000, "SemilladelMundo": 10000, "TopacioImperial": 4000, "Cornalina": 4000, "SoldelDesierto": 6000, "EscarabajodeOro": 6000, "LagrimadeFaraon": 8000, "Espejismo": 8000, "CoronadelSol": 10000, "RelojdeArenaEterno": 10000, "CristaldeRoca": 1500, "PiedraEscarcha": 1500, "Aguamarina": 2500, "Celestina": 2500, "Zafiro": 4000, "PiedraLuna": 4000, "CorazondeHielo": 6000, "DiamantePolar": 6000, "AuroraBoreal": 8000, "EstrelladeEscarcha": 8000, "CopoEterno": 10000, "TronodeHielo": 10000, "Obsidiana": 1500, "BasaltoRojo": 1500, "Granate": 2500, "CristaldeAzufre": 2500, "Rubi": 4000, "OpalodeFuego": 4000, "NucleodeMagma": 6000, "PiedraFenix": 6000, "OjodeDragon": 8000, "LlamaViva": 8000, "CorazondelVolcan": 10000, "CoronaIgnea": 10000, "Meteorita": 1500, "PolvoEstelar": 1500, "Iolita": 2500, "FluoritaNocturna": 2500, "OpaloNegro": 4000, "Alejandrita": 4000, "FragmentodeNebulosa": 6000, "OjodelVacio": 6000, "CometaErrante": 8000, "GalaxiaEspiral": 8000, "Supernova": 10000, "AgujeroNegro": 10000}

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
    izq = d.get("tonos_izq")  # otros tonos para la mitad izquierda (gema de dos colores)
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
                    o, me, cl = izq if izq and x < 0 else (oscuro, medio, claro)
                    celdas[(x, y, z)] = cl if v > 0.62 else me if v > 0.3 else o
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
    colores.update(d.get("base", {}))  # roca y pasto de otra zona
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


def corazon_de_pradera(nombre, paleta=None, extra=None):
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
    colores.update(paleta or {})  # la misma forma con colores de otra zona
    if extra:
        extra(celdas)
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


def sol_del_desierto(nombre):
    """Gema legendaria de cubitos (Dunas): disco de vidrio dorado parado (3 tonos, más claro arriba,
    bordes en escalones como facetas claras) con un corazón que brilla fuerte adentro (malla aparte).
    Lo rodea un aro de oro con remaches y 12 rayos de bloques (largos y cortos) como un sol, con
    3 gemitas turquesa engarzadas. Se apoya en un pie de oro sobre una roca de arena de la que
    crecen cristales cuadrados dorados."""
    celdas = {}
    # roca de arena
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7.5) + (h(x // 2, y // 2, 0, 61) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, 62)
                    celdas[(x, y, z)] = "Veta" if v < 0.05 else "RocaOscura" if z == 0 or v < 0.3 else "Roca"
    # pie de oro
    for z in (3, 4):
        for x in range(-2 + (z - 3), 3 - (z - 3)):
            for y in range(-2, 3):
                celdas[(x, y, z)] = "Oro"
    # disco en el plano x-z
    radio = 6.4
    zc = 5 + 3 + radio  # centro: arriba del pie, dejando lugar a los rayos de abajo
    plano = {(x, z) for x in range(-8, 9) for z in range(0, 40) if math.hypot(x, z + 0.5 - zc - 0.5) <= radio}

    def hondo(x, z):
        for k in range(1, 5):
            if any((x + dx * k, z + dz * k) not in plano for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                return k
        return 4

    zmin = min(z for _, z in plano)
    zmax = max(z for _, z in plano)
    for x, z in plano:
        k = hondo(x, z)
        grosor = min(3, k)
        t = (z - zmin) / (zmax - zmin)
        for y in range(-grosor, grosor + 1):
            if k >= 3 and abs(y) <= 1:
                celdas[(x, y, z)] = "Corazon"
                continue
            frente = abs(y) == grosor
            if not frente and k > 1:
                continue  # hueco: se ve el corazón a través del vidrio
            if frente and (k == 1 or (k == 2 and h(x, y, z, 63) < 0.5)):
                celdas[(x, y, z)] = "Faceta"
            else:
                v = t + (h(x, y, z, 64) - 0.5) * 0.25
                celdas[(x, y, z)] = "Claro" if v > 0.62 else "Medio" if v > 0.3 else "Oscuro"
    # aro de oro con remaches en relieve
    aro = set()
    for x, z in plano:
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            c = (x + dx, z + dz)
            if c not in plano:
                aro.add(c)
    for x, z in aro:
        for y in (-1, 0, 1):
            celdas[(x, y, z)] = "Oro"
        if (x * 3 + z) % 4 == 0:
            celdas[(x, 2, z)] = celdas[(x, -2, z)] = "Remache"
    # tallo de oro: une el pie con el aro de abajo, con un anillo en relieve al medio
    abajo = min(z for x, z in aro if x == 0)
    for z in range(5, abajo):
        for x in (-1, 0, 1):
            for y in (-1, 0, 1):
                celdas[(x, y, z)] = "Oro"
        if z == (5 + abajo) // 2:
            for x in (-2, 2):
                for y in (-1, 0, 1):
                    celdas[(x, y, z)] = celdas[(y, x, z)] = "Remache"
    # 12 rayos: bloques que salen del aro, largos (rectos) y cortos (diagonales)
    cz = round(zc)
    for i in range(12):
        ang = i * math.pi / 6
        largo = 3 if i % 2 == 0 else 2
        dx, dz = math.sin(ang), math.cos(ang)
        if dz < -0.8:
            continue  # abajo va el pie
        for paso in range(1, largo + 1):
            d = radio + 0.6 + paso
            x, z = round(dx * d), cz + round(dz * d)
            ancho = 1 if paso < largo and i % 2 == 0 else 0
            for w in range(-ancho, ancho + 1):
                c = (x + round(-dz * w), z + round(dx * w))
                if c in plano or c in aro:
                    continue
                for y in (-1, 0, 1) if w == 0 else (0,):
                    celdas[(c[0], y, c[1])] = "RayoClaro" if paso == largo else "Rayo"
    # 3 gemitas turquesa engarzadas sobre el aro (arriba y a los costados)
    for x0, z0 in ((0, cz + 4), (-4, cz - 2), (4, cz - 2)):
        for a in (-1, 0):
            for b in (0, 1):
                celdas[(x0 + a + 1, -4, z0 + b)] = "Gemita"
                celdas[(x0 + a + 1, -3, z0 + b)] = "Oro"
    # cristales dorados que crecen de la roca
    for x, y, alto_c in ((-7, 2, 4), (-6, 3, 2), (6, -3, 3), (7, 2, 5), (-4, 5, 3), (4, 5, 2), (-5, -4, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto_c):
            celdas[(x, y, z)] = "Cristal" if z < z0 + alto_c - 1 else "CristalClaro"
    colores = {
        "Oscuro": ("#D07A08", 0.05, None, 0.0, 0.7),
        "Medio": ("#F5A81C", 0.05, None, 0.0, 0.6),
        "Claro": ("#FFD54A", 0.05, None, 0.0, 0.55),
        "Faceta": ("#FFE9A0", 0.05, "#FFD86A", 0.3, 0.8),
        "Corazon": ("#FFF0B0", 0.2, "#FFC21A", 4.0, 1),
        "Oro": ("#E8A61E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Rayo": ("#FFC233", 0.2, "#FFB000", 0.3, 1),
        "RayoClaro": ("#FFE680", 0.2, "#FFD040", 0.6, 1),
        "Gemita": ("#22C7C0", 0.05, "#2AE0D6", 0.6, 1),
        "Cristal": ("#E6A12A", 0.15, None, 0.0, 1),
        "CristalClaro": ("#FFE27A", 0.15, "#FFD24A", 0.5, 1),
        "Roca": ("#C4975E", 0.85, None, 0.0, 1),
        "RocaOscura": ("#8E6A40", 0.9, None, 0.0, 1),
        "Veta": ("#F0D9A8", 0.7, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


def escarabajo_de_oro(nombre):
    """Gema legendaria de cubitos (Dunas): escarabajo de oro parado de frente, sobre un pie de oro y
    una roca de arena con cristales turquesa. Cuerpo de oro en 3 tonos con borde oscuro en relieve,
    remaches por el lomo y 6 patas; alas abiertas de vidrio turquesa (más claras arriba, bordes en
    escalones como facetas) con un corazón que brilla fuerte adentro (malla aparte). Gemitas: 2 ojos
    rojos y un solcito naranja que sostiene arriba de la cabeza."""
    celdas = {}
    # roca de arena
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7.5) + (h(x // 2, y // 2, 0, 71) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, 72)
                    celdas[(x, y, z)] = "Veta" if v < 0.05 else "RocaOscura" if z == 0 or v < 0.3 else "Roca"
    # pie de oro
    for z in (3, 4):
        for x in range(-2 + (z - 3), 3 - (z - 3)):
            for y in range(-2, 3):
                celdas[(x, y, z)] = "OroOscuro"
    zb = 5
    # alas en el plano x-z: dos óvalos inclinados hacia afuera y arriba
    alas = set()
    for x in range(-10, 11):
        for z in range(zb, zb + 18):
            for s in (-1, 1):
                u, v = x - s * 5.0, z - (zb + 9.5)
                a, b = u * 0.9 - s * v * 0.42, s * u * 0.42 + v * 0.9
                if (a / 4.3) ** 2 + (b / 7.2) ** 2 <= 1:
                    alas.add((x, z))

    def hondo(plano, x, z):
        for k in range(1, 5):
            if any((x + dx * k, z + dz * k) not in plano for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                return k
        return 4

    zmin = min(z for _, z in alas)
    zmax = max(z for _, z in alas)
    for x, z in alas:
        k = hondo(alas, x, z)
        grosor = min(2, k)
        t = (z - zmin) / (zmax - zmin)
        for y in range(-grosor + 1, grosor + 2):  # un poco más atrás que el cuerpo
            if k >= 3 and y in (1, 2):
                celdas[(x, y, z)] = "Corazon"
                continue
            frente = y in (-grosor + 1, grosor + 1)
            if not frente and k > 1:
                continue  # hueco: se ve el corazón a través del vidrio
            if k == 1:
                celdas[(x, y, z)] = "Faceta"
            else:
                v = t + (h(x, y, z, 73) - 0.5) * 0.25
                celdas[(x, y, z)] = "AlaClaro" if v > 0.62 else "AlaMedio" if v > 0.3 else "AlaOscuro"
    # nervaduras de oro en las alas (diagonales)
    for s in (-1, 1):
        for i in range(1, 9):
            for x, z in ((s * (2 + i * 0.8), zb + 4 + i * 1.3), (s * (3 + i * 0.4), zb + 3 + i * 1.6)):
                c = (round(x), round(z))
                if c in alas and hondo(alas, *c) > 1:
                    celdas[(c[0], 0, c[1])] = "Oro"
    # cuerpo: abdomen ovalado, tórax y cabeza (todo de oro, adelante de las alas)
    cuerpo = set()
    for x in range(-5, 6):
        for z in range(zb, zb + 20):
            if ((x / 4.4) ** 2 + ((z - (zb + 5.5)) / 5.4) ** 2 <= 1
                    or (abs(x) <= 4 - (z == zb + 12) and zb + 10 <= z <= zb + 12)
                    or (abs(x) <= 2 - (z == zb + 15) and zb + 13 <= z <= zb + 15)):
                cuerpo.add((x, z))
    czmin, czmax = min(z for _, z in cuerpo), max(z for _, z in cuerpo)
    for x, z in cuerpo:
        k = hondo(cuerpo, x, z)
        t = (z - czmin) / (czmax - czmin)
        prof = -1 - min(2, k)  # más abultado al medio
        for y in range(prof, 2):
            if k == 1 or z in (zb + 10, zb + 13):
                clave = "Borde"  # borde y cortes entre partes en relieve oscuro
            else:
                v = t + (h(x, y, z, 74) - 0.5) * 0.2
                clave = "OroClaro" if v > 0.62 else "Oro" if v > 0.3 else "OroOscuro"
            celdas[(x, y, z)] = clave
    # línea del lomo con remaches
    for z in range(zb + 1, zb + 10):
        if (0, z) in cuerpo:
            celdas[(0, -1 - min(2, hondo(cuerpo, 0, z)) - 1, z)] = "Remache" if z % 2 else "Borde"
    # 6 patas: escalones de oro que salen del cuerpo hacia afuera y abajo, por delante de las alas
    for s in (-1, 1):
        for z0, dz in ((zb + 11, 1), (zb + 7, 0), (zb + 3, -1)):
            x, z = s * 4, z0
            for i in range(4):
                x += s
                z += dz if i < 2 else -1
                celdas[(x, -2, z)] = "OroOscuro" if i == 3 else "Oro"
    # antenas / patas delanteras que sostienen el solcito
    for s in (-1, 1):
        for i, (x, z) in enumerate(((s * 2, zb + 16), (s * 2, zb + 17), (s * 2, zb + 18))):
            celdas[(x, -1, z)] = "Oro"
    for x in (-1, 0, 1):
        for z in (zb + 18, zb + 19, zb + 20):
            if not (abs(x) == 1 and z in (zb + 18, zb + 20)):
                celdas[(x, -1, z)] = "Sol"
                celdas[(x, 0, z)] = "Oro"
    # ojos: gemitas rojas en la cabeza
    for s in (-1, 1):
        celdas[(s * 1, -4, zb + 14)] = "Ojo"
    # cristales turquesa que crecen de la roca
    for x, y, alto_c in ((-7, 2, 4), (-6, 3, 2), (6, -3, 3), (7, 2, 5), (-4, 5, 3), (4, 5, 2), (-5, -4, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto_c):
            celdas[(x, y, z)] = "Cristal" if z < z0 + alto_c - 1 else "CristalClaro"
    colores = {
        "AlaOscuro": ("#0B7F86", 0.05, None, 0.0, 0.7),
        "AlaMedio": ("#18B5B0", 0.05, None, 0.0, 0.6),
        "AlaClaro": ("#5FE6D8", 0.05, None, 0.0, 0.55),
        "Faceta": ("#BFFFF6", 0.05, "#7DFFEE", 0.3, 0.8),
        "Corazon": ("#B8FFF4", 0.2, "#3FF5E0", 4.0, 1),
        "OroOscuro": ("#B87A10", 0.3, None, 0.0, 1),
        "Oro": ("#E8A61E", 0.25, None, 0.0, 1),
        "OroClaro": ("#FFD24A", 0.2, None, 0.0, 1),
        "Borde": ("#8A5A0A", 0.35, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Ojo": ("#E8202A", 0.05, "#FF3030", 0.6, 1),
        "Sol": ("#FF7A1A", 0.05, "#FF8A2A", 0.8, 1),
        "Cristal": ("#1FA9A6", 0.15, None, 0.0, 1),
        "CristalClaro": ("#7FF2E6", 0.15, "#5FE6D8", 0.5, 1),
        "Roca": ("#C4975E", 0.85, None, 0.0, 1),
        "RocaOscura": ("#8E6A40", 0.9, None, 0.0, 1),
        "Veta": ("#F0D9A8", 0.7, None, 0.0, 1),
    }
    return cubitos(nombre, celdas, colores)


# ---------------------------------------------------------------------------------------------
# Moldes para Míticas y Celestiales (zona 2 en adelante): la base, el anillo, el halo y las
# gemitas salen del molde; cada piedra solo dibuja su cuerpo.


def _capas_gema(celdas, zb, anchos, tonos, nucleo="Nucleo", arista="Faceta", forma=None, mancha=None):
    """Gema hueca en capas cuadradas (o rombos si forma(z) es True): cáscara en degradé de abajo
    hacia arriba (tonos = lista de claves) con aristas claras y núcleo macizo adentro.
    mancha(x, y, z) puede devolver otra clave para un cubito de la cáscara. Devuelve {z: medio ancho}."""
    w_de = {zb + i: w for i, w in enumerate(anchos)}
    zmax = zb + len(anchos) - 1
    for z, w in w_de.items():
        t = (z - zb) / max(1, zmax - zb)
        rombo = forma(z) if forma else False
        arriba, abajo = w_de.get(z + 1, -1), w_de.get(z - 1, -1)
        for x in range(-w, w + 1):
            for y in range(-w, w + 1):
                d = abs(x) + abs(y) if rombo else max(abs(x), abs(y))
                if d > w:
                    continue
                if d <= w - 2 and zb < z < zmax:
                    celdas[(x, y, z)] = nucleo
                    continue
                if d < w and d <= arriba and d <= abajo:
                    continue  # hueco: se ve el núcleo a través del vidrio
                otra = mancha(x, y, z) if mancha else None
                if otra:
                    celdas[(x, y, z)] = otra
                elif arista and d == w and ((x == 0 or y == 0) if rombo else abs(x) == abs(y)):
                    celdas[(x, y, z)] = arista
                else:
                    v = t + (h(x, y, z, 81) - 0.5) * 0.22
                    celdas[(x, y, z)] = tonos[max(0, min(len(tonos) - 1, int(v * len(tonos))))]
    return w_de


def mitica(nombre, cuerpo, colores, anillo_z, radio=9):
    """Molde mítico: roca de 3 capas, zócalo de metal ("Zocalo"), el cuerpo que dibuja cuerpo(celdas)
    desde z = 4, y un anillo cuadrado ("Anillo", malla aparte para que gire) con dientes."""
    celdas = {}
    for x in range(-7, 8):
        for y in range(-7, 8):
            r = math.hypot(x / 7.5, y / 7.5) + (h(x // 2, y // 2, 0, 82) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.1:
                    celdas[(x, y, z)] = "RocaOscura" if z == 0 or h(x, y, z, 83) < 0.3 else "Roca"
    for x in range(-5, 6):
        for y in range(-5, 6):
            celdas[(x, y, 3)] = "Zocalo"
    cuerpo(celdas)
    for x in range(-radio, radio + 1):
        for y in range(-radio, radio + 1):
            if max(abs(x), abs(y)) == radio:
                celdas[(x, y, anillo_z)] = celdas[(x, y, anillo_z + 1)] = "Anillo"
                if (x + y) % 4 == 0:
                    celdas[(x, y, anillo_z + 2)] = celdas[(x, y, anillo_z - 1)] = "Anillo"
    return cubitos(nombre, celdas, colores)


def celestial(nombre, gema, colores, halo=None, anillo_z=None, gemitas=None):
    """Molde celestial: pedestal chiquito en escalones (Roca, Suelo, Piedra) con cristalitos, la gema
    que dibuja gema(celdas, zb) -> zmax flotando arriba, un halo de luz atrás ("Halo"), un anillo
    grande cuadrado ("Anillo") y 3 gemitas ("Gemita1..3"); lo que se mueve va en mallas aparte."""
    celdas = {}
    for z, r, clave in ((0, 6, "Roca"), (1, 5, "Roca"), (2, 4, "Suelo"), (3, 3, "Piedra")):
        for x in range(-r, r + 1):
            for y in range(-r, r + 1):
                if not (abs(x) == r and abs(y) == r):
                    oscura = clave == "Roca" and h(x, y, z, 84) < 0.3
                    celdas[(x, y, z)] = "RocaOscura" if oscura else clave
    for x, y, z0, alto in ((-5, 2, 2, 2), (5, -3, 2, 3), (2, 5, 2, 2), (-3, -5, 2, 2), (4, 4, 3, 1)):
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Cristalito"
    zb = 7
    zmax = gema(celdas, zb)
    hz = (zb + zmax) // 2
    if halo:
        halo(celdas, hz)
    else:
        for x in range(-7, 8):
            for z in range(hz - 7, hz + 8):
                d = max(abs(x), abs(z - hz))
                if d == 7 or (d == 6 and (x + z) % 2 == 0):
                    celdas[(x, 9, z)] = "Halo"
    az = anillo_z if anillo_z is not None else hz - 3
    for x in range(-9, 10):
        for y in range(-9, 10):
            if max(abs(x), abs(y)) == 9 and y != 9:
                celdas[(x, y, az)] = "Anillo"
                if (x + y) % 4 == 0:
                    celdas[(x, y, az + 1)] = "Anillo"
    for (gx, gy, gz), clave in gemitas or (((-9, -3, zb + 2), "Gemita1"), ((7, -6, hz + 3), "Gemita2"),
                                           ((-6, 6, zmax - 1), "Gemita3")):
        for a in range(2):
            for b in range(2):
                for c in range(2):
                    celdas[(gx + a, gy + b, gz + c)] = clave
    return cubitos(nombre, celdas, colores)


DUNA_ROCA = {
    "Roca": ("#C4975E", 0.85, None, 0.0, 1),
    "RocaOscura": ("#8E6A40", 0.9, None, 0.0, 1),
    "Suelo": ("#E8C88A", 0.85, None, 0.0, 1),
    "Piedra": ("#D9B27A", 0.75, None, 0.0, 1),
}


def lagrima_de_faraon(nombre):
    """Mítica (Dunas): gota de lapislázuli parada con la punta arriba, cáscara de vidrio azul en
    degradé (marino abajo, cobalto arriba) con motitas de oro, aristas de oro, núcleo de oro que
    brilla y un ojo dibujado con cubitos al frente. Anillo cuadrado de oro alrededor."""
    anchos = [3, 4, 5, 5, 6, 6, 6, 6, 6, 5, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1, 0]
    zb = 4

    def motas(x, y, z):
        return "Pirita" if h(x, y, z, 85) < 0.06 else None

    def cuerpo(celdas):
        w_de = _capas_gema(celdas, zb, anchos, ["AzulOscuro", "AzulMedio", "AzulClaro"], arista="Oro",
                           mancha=motas)
        celdas[(0, 0, zb + len(anchos))] = "Oro"
        # ojo al frente: O = delineado de oro, B = blanco, N = pupila
        ojo = ["..OOOOO..",
               ".OBBBBBO.",
               "OBBNNNBBO",
               ".OBBNBBO.",
               "..OOOOO..",
               "....O....",
               "....OO..."]
        zc = zb + 10
        for fila, linea in enumerate(ojo):
            z = zc - fila
            w = w_de[z]
            for i, ch in enumerate(linea):
                x = i - 4
                if ch != "." and abs(x) <= w:
                    celdas[(x, -w, z)] = {"O": "Oro", "B": "OjoBlanco", "N": "OjoNegro"}[ch]

    colores = {
        "AzulOscuro": ("#0E2A7A", 0.08, None, 0.0, 0.92),
        "AzulMedio": ("#1E46B8", 0.06, None, 0.0, 0.88),
        "AzulClaro": ("#3F6EF0", 0.05, None, 0.0, 0.85),
        "Pirita": ("#FFD24A", 0.2, "#FFC21A", 0.4, 1),
        "Nucleo": ("#FFD24A", 0.2, "#FFB000", 2.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "OjoBlanco": ("#FFF6E0", 0.4, None, 0.0, 1),
        "OjoNegro": ("#101828", 0.4, None, 0.0, 1),
        "Zocalo": ("#F2B92E", 0.25, None, 0.0, 1),
        "Anillo": ("#F2C24A", 0.2, "#FFD86A", 0.3, 1),
    }
    colores.update({k: DUNA_ROCA[k] for k in ("Roca", "RocaOscura")})
    return mitica(nombre, cuerpo, colores, anillo_z=6)


def espejismo(nombre):
    """Mítica (Dunas): cristal en capas que se corren de lado a lado como el aire caliente del
    desierto (cuadrados y rombos alternados), cáscara medio transparente en degradé de naranja
    (abajo) a celeste (arriba), núcleo blanco que brilla, filetes de plata salteados y un anillo
    cuadrado de plata alrededor."""
    anchos = [2, 3, 4, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 2, 1, 0]
    zb = 4
    tonos = ["Naranja", "Durazno", "Crema", "CelesteClaro", "Celeste"]

    def vaiven(z):
        return round(1.4 * math.sin((z - zb) * 0.55))

    def cuerpo(celdas):
        capa = {}
        _capas_gema(capa, zb, anchos, tonos, arista="Plata", forma=lambda z: (z // 3) % 2 == 1)
        for (x, y, z), k in capa.items():
            if k in tonos and (z - zb) % 4 == 3 and h(x, y, z, 86) < 0.5:
                k = "Plata"
            celdas[(x + vaiven(z), y, z)] = k
        celdas[(vaiven(zb + len(anchos)), 0, zb + len(anchos))] = "Plata"

    colores = {
        "Naranja": ("#FF7A2A", 0.05, None, 0.0, 0.7),
        "Durazno": ("#FFA060", 0.05, None, 0.0, 0.65),
        "Crema": ("#FFD2A0", 0.05, None, 0.0, 0.6),
        "CelesteClaro": ("#7FD6FF", 0.05, None, 0.0, 0.6),
        "Celeste": ("#2FA8F0", 0.05, None, 0.0, 0.65),
        "Nucleo": ("#FFD9B0", 0.2, "#FFB07A", 0.7, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Zocalo": ("#C9D2DC", 0.25, None, 0.0, 1),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.35, 1),
    }
    colores.update({k: DUNA_ROCA[k] for k in ("Roca", "RocaOscura")})
    return mitica(nombre, cuerpo, colores, anillo_z=11)


def corona_del_sol(nombre):
    """Celestial (Dunas): corona de oro cuadrada (aro con remaches y 8 puntas con rubíes) con una
    gema-sol naranja en el centro que asoma por arriba (capas, núcleo que brilla fuerte). Atrás, un
    halo de rayos de luz; anillo grande y 3 gemitas que orbitan; pedestal de arena."""

    def gema(celdas, zb):
        anchos = [1, 2, 3, 4, 4, 5, 5, 5, 5, 5, 5, 4, 4, 3, 3, 2, 1, 1, 0]
        _capas_gema(celdas, zb + 2, anchos, ["NaranjaOscuro", "Naranja", "Amarilla"])
        for z in range(zb, zb + 5):
            for x in range(-7, 8):
                for y in range(-7, 8):
                    d = max(abs(x), abs(y))
                    if d == 7 or (d == 6 and z == zb):
                        remache = z == zb + 2 and d == 7 and (x + y) % 3 == 0
                        celdas[(x, y, z)] = "Remache" if remache else "Oro"
        for x, y in ((-7, -7), (7, -7), (-7, 7), (7, 7), (0, -7), (0, 7), (-7, 0), (7, 0)):
            alto = 5 if x == 0 or y == 0 else 3
            for z in range(zb + 5, zb + 5 + alto):
                celdas[(x, y, z)] = "Oro"
            celdas[(x, y, zb + 5 + alto)] = "Rubi"
        return zb + 2 + len(anchos) - 1

    def halo(celdas, hz):
        hz += 2
        for i in range(12):
            ang = i * math.pi / 6
            largo = 9 if i % 2 == 0 else 7
            for d in range(4, largo + 1):
                celdas[(round(math.sin(ang) * d), 9, hz + round(math.cos(ang) * d))] = "Halo"

    colores = {
        "NaranjaOscuro": ("#D9500F", 0.05, None, 0.0, 0.7),
        "Naranja": ("#FF7A1A", 0.05, None, 0.0, 0.6),
        "Amarilla": ("#FFB833", 0.05, None, 0.0, 0.55),
        "Faceta": ("#FFE0A0", 0.05, "#FFC860", 0.3, 0.8),
        "Nucleo": ("#FFE9A0", 0.2, "#FF9A1A", 3.5, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Rubi": ("#E8202A", 0.05, "#FF3030", 0.6, 1),
        "Halo": ("#FFD86A", 0.1, "#FFC233", 1.0, 0.6),
        "Anillo": ("#F7E2A8", 0.2, "#FFE08A", 0.4, 1),
        "Gemita1": ("#FF7A1A", 0.05, "#FF7A1A", 0.8, 1),
        "Gemita2": ("#FFD24A", 0.05, "#FFD24A", 0.8, 1),
        "Gemita3": ("#22C7C0", 0.05, "#2AE0D6", 0.8, 1),
        "Cristalito": ("#FFC85A", 0.1, "#FFB020", 0.4, 1),
    }
    colores.update(DUNA_ROCA)
    return celestial(nombre, gema, colores, halo=halo)


def reloj_de_arena_eterno(nombre):
    """Celestial (Dunas): reloj de arena con tapas de oro (remaches) y 4 columnas, dos ampollas de
    vidrio en escalones y arena dorada que brilla adentro (abajo llena, arriba a medias, y un hilito
    cayendo por el cuello). Halo, anillo y 3 gemitas que orbitan; pedestal de arena."""

    def gema(celdas, zb):
        perfil = [4, 4, 4, 4, 3, 3, 2, 2, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4]
        z0 = zb + 1
        zt = z0 + len(perfil)
        for x in range(-5, 6):
            for y in range(-5, 6):
                for z in (zb, zt):
                    borde = max(abs(x), abs(y)) == 5
                    celdas[(x, y, z)] = "Remache" if borde and (x + y) % 3 == 0 else "Oro"
        for x in (-5, 5):
            for y in (-5, 5):
                for z in range(z0, zt):
                    celdas[(x, y, z)] = "Oro" if (z - z0) % 4 else "Remache"
        n = len(perfil)
        for i, w in enumerate(perfil):
            z = z0 + i
            for x in range(-w, w + 1):
                for y in range(-w, w + 1):
                    d = max(abs(x), abs(y))
                    if d < w and (i <= 4 or i in (n - 5, n - 4)):
                        celdas[(x, y, z)] = "Arena" if h(x, y, z, 87) > 0.15 else "ArenaClara"
                    elif d == w or i in (0, n - 1):
                        v = (h(x, y, z, 88) - 0.5) * 0.3 + i / n
                        celdas[(x, y, z)] = "VidrioClaro" if v > 0.5 else "Vidrio"
        for i in range(5, 14):
            celdas[(0, 0, z0 + i)] = "ArenaClara"  # hilito que cae por el cuello
        return zt

    colores = {
        "Vidrio": ("#E8F4FF", 0.03, None, 0.0, 0.3),
        "VidrioClaro": ("#FFFFFF", 0.03, None, 0.0, 0.25),
        "Arena": ("#FFC233", 0.3, "#FFB000", 1.2, 1),
        "ArenaClara": ("#FFE58A", 0.25, "#FFD24A", 2.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Halo": ("#FFE08A", 0.1, "#FFD24A", 0.8, 0.5),
        "Anillo": ("#F7E2A8", 0.2, "#FFE08A", 0.4, 1),
        "Gemita1": ("#22C7C0", 0.05, "#2AE0D6", 0.8, 1),
        "Gemita2": ("#FFD24A", 0.05, "#FFD24A", 0.8, 1),
        "Gemita3": ("#FF7A1A", 0.05, "#FF7A1A", 0.8, 1),
        "Cristalito": ("#FFC85A", 0.1, "#FFB020", 0.4, 1),
    }
    colores.update(DUNA_ROCA)
    return celestial(nombre, gema, colores)


# ---------------------------------------------------------------------------------------------
# Moldes para Comunes, Raras y Legendarias (zona 3 en adelante)


def comun(nombre, colores, semilla, velo=0.0, escarcha=0.0, motas=0.0, tope=11):
    """Molde común: trozo de mineral en escalones (Oscuro, Medio, Claro: más claro arriba) sobre una
    mancha de suelo (Suelo, SueloOscuro), con 2 grietas (Grieta), 3 cristalitos (uno de Vidrio con
    Nucleo, dos de Cristal) y piedritas (Piedrita). velo: cubitos sueltos adentro (Velo) que se ven
    si el cuerpo es transparente; escarcha: parte de los cubitos de arriba pasan a Escarcha;
    motas: puntitos de otro color (Mota) salteados en la superficie."""
    rng = random.Random(semilla)
    celdas = {}
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8, y / 6.5) + (h(x // 2, y // 2, 0, semilla) - 0.5) * 0.35
            if r < 1:
                celdas[(x, y, 0)] = "SueloOscuro"
            if r < 0.85:
                celdas[(x, y, 1)] = "Suelo" if h(x, y, 1, semilla + 1) > 0.1 else "SueloOscuro"
    cx1, cy1 = rng.choice((1.8, -1.8)), rng.choice((0.8, -0.8))
    for z in range(1, tope + 1):
        t = (z - 1) / (tope - 1)
        cx, cy = round(cx1 * t), round(cy1 * t)
        rx, ry = 6.2 * (1 - 0.5 * t**1.6), 5.0 * (1 - 0.45 * t**1.4)
        for x in range(-8, 9):
            for y in range(-7, 8):
                ruido = (h(x // 3, y // 3, z // 2, semilla + 2) - 0.5) * 0.55
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1 + ruido:
                    continue
                if (x if cx1 > 0 else -x) - y > 9 - z * 0.4:  # canto partido
                    continue
                v = t + (h(x, y, z, semilla + 3) - 0.5) * 0.1
                celdas[(x, y, z)] = "Claro" if v > 0.62 else "Medio" if v > 0.3 else "Oscuro"
    llenas = set(celdas)

    def afuera(c):
        x, y, z = c
        return any((x + dx, y + dy, z + dz) not in llenas for (dx, dy, dz), _ in m.CARAS[:5])

    cuerpo = [c for c, k in celdas.items() if k in ("Claro", "Medio", "Oscuro")]
    piel = sorted(c for c in cuerpo if afuera(c))
    if velo:
        for c in cuerpo:
            if not afuera(c) and h(*c, semilla + 4) < velo:
                celdas[c] = "Velo"
    if escarcha:
        for c in piel:
            if (c[0], c[1], c[2] + 1) not in llenas and h(*c, semilla + 5) < escarcha:
                celdas[c] = "Escarcha"
    if motas:
        for c in piel:
            if celdas[c] in ("Claro", "Medio", "Oscuro") and h(*c, semilla + 6) < motas:
                celdas[c] = "Mota"
    for inicio in ((-3, -4, 8), (4, 1, 7)):
        c = min(piel, key=lambda p: sum((a - b) ** 2 for a, b in zip(p, inicio)))
        for _ in range(9):
            celdas[c] = "Grieta"
            vec = [p for p in piel
                   if p[2] <= c[2] and sum(abs(a - b) for a, b in zip(p, c)) == 1 and celdas[p] != "Grieta"]
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

    columna(round(cx1 * 0.6), -2, 9, 3, 6, "Vidrio", corre=(1 if cx1 > 0 else -1, 0))
    for i in range(4):
        celdas[(round(cx1 * 0.6) + 1 + (1 if cx1 > 0 else -1) * (i // 2), -1, 10 + i)] = "Nucleo"
    columna(-5 if cx1 > 0 else 4, 0, 5, 2, 5, "Cristal", corre=(-1 if cx1 > 0 else 1, 1))
    columna(3 if cx1 > 0 else -4, -5, 3, 2, 3, "Cristal", corre=(1 if cx1 > 0 else -1, -1))
    for x, y in ((-7, 2), (6, 4), (-2, 6)):
        celdas[(x, y, 1)] = celdas[(x, y, 2)] = "Piedrita"
    return cubitos(nombre, celdas, colores)


def rara(nombre, colores, columnas, semilla, sueltos=None):
    """Molde raro: columnas de vidrio en 3 tonos (Oscuro, Medio, Claro) con aristas (Arista), centro
    que brilla suave (Centro) y punta escalonada, saliendo de una roca (Roca, RocaOscura, Veta), con
    cubitos sueltos en la base (Suelto). columnas = [(x, y, medio ancho, alto, incl. x, incl. y)]."""
    celdas = {}
    for x in range(-9, 10):
        for y in range(-8, 9):
            r = math.hypot(x / 9, y / 8) + (h(x // 2, y // 2, 0, semilla) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, semilla + 1)
                    celdas[(x, y, z)] = "Veta" if v < 0.05 else "RocaOscura" if z == 0 or v < 0.25 else "Roca"
    for cx, cy, a, alto, ix, iy in columnas:
        punta = a + 2
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
                        celdas[c] = "Centro"
                    elif abs(x) == ancho and abs(y) == ancho and ancho > 0:
                        celdas[c] = "Arista"
                    else:
                        v = t + (h(*c, semilla + 2) - 0.5) * 0.2
                        celdas[c] = "Claro" if v > 0.62 else "Medio" if v > 0.3 else "Oscuro"
    for x, y, alto in sueltos or ((-7, -3, 2), (7, 4, 3), (-2, -6, 2), (5, -5, 1), (-6, 5, 2)):
        z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
        for z in range(z0, z0 + alto):
            celdas[(x, y, z)] = "Suelto"
    return cubitos(nombre, celdas, colores)


def _hondo(plano, x, z):
    """Cuántos pasos hasta salir de una silueta en el plano x-z (máx. 4)."""
    for k in range(1, 5):
        if any((x + dx * k, z + dz * k) not in plano for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            return k
    return 4


def _emblema(celdas, plano, tonos, grosor_max=3, aro="Oro", remache="Remache", cada=4):
    """Silueta parada en el plano x-z hecha gema: vidrio en degradé (tonos, de abajo hacia arriba),
    más gruesa al medio, bordes como facetas (Faceta) y núcleo que brilla (Nucleo, malla aparte).
    Con aro, la rodea un marco de metal con remaches en relieve. Devuelve el marco."""
    zmin = min(z for _, z in plano)
    zmax = max(z for _, z in plano)
    for x, z in plano:
        k = _hondo(plano, x, z)
        grosor = min(grosor_max, k)
        t = (z - zmin) / max(1, zmax - zmin)
        for y in range(-grosor, grosor + 1):
            if k >= 3 and abs(y) <= 1:
                celdas[(x, y, z)] = "Nucleo"
                continue
            if abs(y) != grosor and k > 1:
                continue  # hueco: se ve el núcleo
            if k == 1:
                celdas[(x, y, z)] = "Faceta"
            else:
                v = t + (h(x, y, z, 91) - 0.5) * 0.25
                celdas[(x, y, z)] = tonos[max(0, min(len(tonos) - 1, int(v * len(tonos))))]
    marco = set()
    if aro:
        for x, z in plano:
            for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + dx, z + dz) not in plano:
                    marco.add((x + dx, z + dz))
        for x, z in marco:
            for y in (-1, 0, 1):
                celdas[(x, y, z)] = aro
            if (x * 3 + z) % cada == 0:
                celdas[(x, 2, z)] = celdas[(x, -2, z)] = remache
    return marco


def _base_legendaria(celdas, semilla, cristales=True):
    """Roca (Roca, RocaOscura, Veta), pie de metal (Pie) y cristales (Cristal, CristalClaro)."""
    for x in range(-8, 9):
        for y in range(-7, 8):
            r = math.hypot(x / 8.5, y / 7.5) + (h(x // 2, y // 2, 0, semilla) - 0.5) * 0.3
            for z in range(3):
                if r < 1 - z * 0.12:
                    v = h(x, y, z, semilla + 1)
                    celdas[(x, y, z)] = "Veta" if v < 0.05 else "RocaOscura" if z == 0 or v < 0.3 else "Roca"
    for z in (3, 4):
        for x in range(-2 + (z - 3), 3 - (z - 3)):
            for y in range(-2, 3):
                celdas[(x, y, z)] = "Pie"
    if cristales:
        for x, y, alto_c in ((-7, 2, 4), (-6, 3, 2), (6, -3, 3), (7, 2, 5), (-4, 5, 3), (4, 5, 2), (-5, -4, 2)):
            z0 = max((z for z in range(3) if (x, y, z) in celdas), default=-1) + 1
            for z in range(z0, z0 + alto_c):
                celdas[(x, y, z)] = "Cristal" if z < z0 + alto_c - 1 else "CristalClaro"


def _tallo(celdas, hasta, clave="Pie", anillo="Remache"):
    """Tallo de metal desde el pie (z = 5) hasta 'hasta', con un anillo en relieve al medio."""
    for z in range(5, hasta):
        for x in (-1, 0, 1):
            for y in (-1, 0, 1):
                celdas[(x, y, z)] = clave
        if z == (5 + hasta) // 2:
            for a in (-2, 2):
                for b in (-1, 0, 1):
                    celdas[(a, b, z)] = celdas[(b, a, z)] = anillo


def _copo(cz, radio, grueso=1.0):
    """Silueta de copo de nieve de 6 brazos con ramitas, centrada en (0, cz) del plano x-z."""
    plano = set()
    brazos = []
    for i in range(6):
        a = i * math.pi / 3
        dx, dz = math.sin(a), math.cos(a)
        brazos.append(((0, 0), (dx * radio, dz * radio)))
        for f in (0.5, 0.75):
            bx, bz = dx * radio * f, dz * radio * f
            for g in (-1, 1):
                a2 = a + g * math.pi / 4
                largo = radio * (0.35 if f == 0.5 else 0.22)
                brazos.append(((bx, bz), (bx + math.sin(a2) * largo, bz + math.cos(a2) * largo)))

    def cerca(px, pz, p, q, r):
        (ax, az), (bx, bz) = p, q
        lx, lz = bx - ax, bz - az
        t = max(0, min(1, ((px - ax) * lx + (pz - az) * lz) / (lx * lx + lz * lz)))
        return math.hypot(px - ax - lx * t, pz - az - lz * t) <= r

    r0 = int(radio) + 1
    for x in range(-r0, r0 + 1):
        for z in range(-r0, r0 + 1):
            if math.hypot(x, z) <= radio * 0.3 or any(cerca(x, z, p, q, grueso) for p, q in brazos):
                plano.add((x, cz + z))
    return plano


GLACIAR_ROCA = {
    "Roca": ("#9FB4C8", 0.7, None, 0.0, 1),
    "RocaOscura": ("#6E8296", 0.8, None, 0.0, 1),
    "Veta": ("#FFFFFF", 0.5, None, 0.0, 1),
    "Suelo": ("#F2F8FF", 0.6, None, 0.0, 1),
    "Piedra": ("#C8D8E8", 0.6, None, 0.0, 1),
}
GLACIAR_SUELO = {
    "Suelo": ("#F2F8FF", 0.6, None, 0.0, 1),
    "SueloOscuro": ("#C8D8E8", 0.7, None, 0.0, 1),
    "Piedrita": ("#6E8296", 0.8, None, 0.0, 1),
}


def cristal_de_roca(nombre):
    """Común (Glaciar): trozo de cristal de roca transparente en escalones, con velos blancos
    adentro, grietas plateadas, cristalitos y base de nieve con piedritas."""
    colores = {
        "Oscuro": ("#C9DCEB", 0.05, None, 0.0, 0.45),
        "Medio": ("#E2EEF8", 0.05, None, 0.0, 0.4),
        "Claro": ("#FFFFFF", 0.05, None, 0.0, 0.35),
        "Velo": ("#FFFFFF", 0.6, None, 0.0, 1),
        "Grieta": ("#A9B8C6", 0.3, None, 0.0, 1),
        "Cristal": ("#E8F6FF", 0.05, "#CFEFFF", 0.2, 1),
        "Vidrio": ("#F4FBFF", 0.05, None, 0.0, 0.4),
        "Nucleo": ("#BFE8FF", 0.2, "#9FDCFF", 1.5, 1),
        **GLACIAR_SUELO,
    }
    return comun(nombre, colores, 101, velo=0.12)


def piedra_escarcha(nombre):
    """Común (Glaciar): piedra blanca grisácea en escalones con escarcha celeste encima, grietas
    azul grisáceo, cristalitos celestes y base de nieve."""
    colores = {
        "Oscuro": ("#8C949C", 0.85, None, 0.0, 1),
        "Medio": ("#B4BBC2", 0.8, None, 0.0, 1),
        "Claro": ("#E2E6EA", 0.75, None, 0.0, 1),
        "Escarcha": ("#BFF0FF", 0.3, "#8FD8FF", 0.25, 1),
        "Grieta": ("#5E7488", 0.8, None, 0.0, 1),
        "Cristal": ("#7FD0FF", 0.15, "#7FD0FF", 0.35, 1),
        "Vidrio": ("#CFEFFF", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#5CC8FF", 0.2, "#5CC8FF", 2.0, 1),
        **GLACIAR_SUELO,
    }
    return comun(nombre, colores, 111, escarcha=0.4)


def aguamarina(nombre):
    """Rara (Glaciar): 3 columnas gruesas de aguamarina celeste verdoso con punta escalonada y centro
    que brilla suave, sobre roca helada con cubitos sueltos."""
    colores = {
        "Oscuro": ("#2E9C9A", 0.05, None, 0.0, 0.7),
        "Medio": ("#5CCBC4", 0.05, None, 0.0, 0.6),
        "Claro": ("#A8F0E6", 0.05, None, 0.0, 0.55),
        "Arista": ("#E0FFF8", 0.05, "#B8FFF2", 0.25, 0.8),
        "Centro": ("#D8FFF6", 0.2, "#8AF5E2", 1.0, 1),
        "Suelto": ("#7FE6D8", 0.15, "#5CD8C8", 0.4, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return rara(nombre, colores, [(0, 0, 3, 19, 0, 0), (-5, 2, 2, 13, -1, 1), (4, -2, 2, 11, 1, -1)], 121)


def celestina(nombre):
    """Rara (Glaciar): racimo de 7 cristalitos finitos celeste pálido de distintas alturas, con
    centro que brilla suave, sobre roca helada con cubitos sueltos."""
    colores = {
        "Oscuro": ("#8DB8E8", 0.05, None, 0.0, 0.65),
        "Medio": ("#B5D6F7", 0.05, None, 0.0, 0.55),
        "Claro": ("#E2F0FF", 0.05, None, 0.0, 0.5),
        "Arista": ("#FFFFFF", 0.05, "#E2F0FF", 0.25, 0.8),
        "Centro": ("#F0F8FF", 0.2, "#B5D6F7", 0.9, 1),
        "Suelto": ("#B5D6F7", 0.15, "#B5D6F7", 0.4, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    columnas = [(0, 0, 1, 18, 0, 0), (-3, 1, 1, 14, -1, 0), (3, -1, 1, 15, 1, 0), (-1, 3, 1, 11, 0, 1),
                (2, 3, 1, 9, 1, 1), (-4, -3, 1, 8, -1, -1), (4, -4, 1, 10, 1, -1)]
    return rara(nombre, colores, columnas, 131)


def zafiro(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["Zafiro"])


def piedra_luna(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["PiedraLuna"])


GLACIAR_TALLADA = {
    "Roca": ("#9FB4C8", 0.7, None, 0.0, 1),
    "RocaOscura": ("#6E8296", 0.8, None, 0.0, 1),
    "Pasto": ("#F2F8FF", 0.6, None, 0.0, 1),
    "Oro": ("#D9E2EC", 0.2, None, 0.0, 1),  # engarce de plata
}
TALLADAS_CUBITOS["Zafiro"] = {
    "engarce": (5, 4),
    "anchos": [(1, 0), (1, 1), (2, 1), (3, 2), (3, 2), (4, 3), (5, 3), (5, 3), (6, 4), (6, 4), (6, 4),
               (6, 4), (6, 4), (5, 4), (5, 3), (4, 3), (3, 2), (2, 1)],
    "garras": (5, 3, 15),
    "tonos": ("AzulOscuro", "AzulMedio", "AzulClaro"),
    "colores": {
        "AzulOscuro": ("#0A2A8C", 0.05, None, 0.0, 0.8),
        "AzulMedio": ("#1446D8", 0.05, None, 0.0, 0.7),
        "AzulClaro": ("#3C78FF", 0.05, None, 0.0, 0.65),
        "Faceta": ("#7FA8FF", 0.05, "#5C8CFF", 0.25, 0.8),
        "Corazon": ("#9CC0FF", 0.2, "#3C78FF", 2.5, 1),
        "Cristal": ("#3C78FF", 0.15, "#3C78FF", 0.4, 1),
    },
    "base": GLACIAR_TALLADA,
}
TALLADAS_CUBITOS["PiedraLuna"] = {
    "engarce": (5, 5),
    "anchos": [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (4, 4),
               (4, 4), (3, 3), (2, 2), (1, 1)],
    "garras": (5, 5, 11),
    "tonos": ("LunaOscuro", "LunaMedio", "LunaClaro"),
    "colores": {
        "LunaOscuro": ("#D8E2F0", 0.1, None, 0.0, 0.5),
        "LunaMedio": ("#EEF3FA", 0.1, None, 0.0, 0.45),
        "LunaClaro": ("#FFFFFF", 0.1, None, 0.0, 0.4),
        "Faceta": ("#C8E2FF", 0.05, "#7FB8FF", 0.6, 0.8),
        "Corazon": ("#5C9CFF", 0.2, "#2E7CFF", 3.5, 1),
        "Cristal": ("#E8F2FF", 0.15, "#BFE0FF", 0.4, 1),
    },
    "base": GLACIAR_TALLADA,
}


def corazon_de_hielo(nombre):
    """Legendaria (Glaciar): la forma del Corazón de Pradera en hielo azul, marco de plata con
    remaches, esquirlas blancas en vez de hojitas, gemitas celestes, cristales de hielo en la roca y
    cubitos de escarcha flotando alrededor."""
    paleta = {
        "VerdeOscuro": ("#1A5FB0", 0.05, None, 0.0, 0.7),
        "VerdeMedio": ("#3C8CE8", 0.05, None, 0.0, 0.6),
        "VerdeClaro": ("#8CC8FF", 0.05, None, 0.0, 0.55),
        "Faceta": ("#E0F2FF", 0.05, "#BFE4FF", 0.3, 0.8),
        "Corazon": ("#D8F0FF", 0.2, "#7FD0FF", 4.0, 1),
        "Oro": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Remache": ("#FFFFFF", 0.2, None, 0.0, 1),
        "Hoja": ("#FFFFFF", 0.1, "#E0F4FF", 0.3, 1),
        "HojaOscura": ("#CFE8FF", 0.1, None, 0.0, 1),
        "Gemita": ("#5CE0FF", 0.05, "#5CE0FF", 0.6, 1),
        "Cristal": ("#8CC8FF", 0.15, None, 0.0, 1),
        "CristalClaro": ("#E0F4FF", 0.15, "#BFE4FF", 0.5, 1),
        "Pasto": ("#F2F8FF", 0.6, None, 0.0, 1),
        "Escarcha": ("#E8F6FF", 0.1, "#BFE4FF", 0.6, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura")},
    }

    def escarcha(celdas):
        for x, y, z in ((-9, -1, 8), (8, 1, 11), (-8, 0, 17), (9, -1, 20), (-5, -3, 22), (5, -2, 23)):
            if (x, y, z) not in celdas:
                celdas[(x, y, z)] = "Escarcha"

    return corazon_de_pradera(nombre, paleta, escarcha)


def diamante_polar(nombre):
    """Legendaria (Glaciar): diamante blanco celeste con forma de copo de nieve de 6 brazos con
    ramitas, más grueso al centro con un núcleo que brilla fuerte (malla aparte), remaches de plata
    en la punta de cada brazo y 3 gemitas azules engarzadas; tallo y pie de plata sobre roca helada
    con cristales."""
    celdas = {}
    _base_legendaria(celdas, 141)
    cz = 17
    plano = _copo(cz, 9.2, grueso=1.1)
    _emblema(celdas, plano, ["Hielo", "HieloMedio", "HieloClaro"], aro=None)
    _tallo(celdas, min(z for x, z in plano if x == 0))
    for i in range(6):
        a = i * math.pi / 3
        x, z = round(math.sin(a) * 9.6), cz + round(math.cos(a) * 9.6)
        for y in (-1, 0, 1):
            celdas[(x, y, z)] = "Plata"
        celdas[(x, -2, z)] = "Remache"
    for x, z in ((0, cz + 5), (-4, cz - 3), (4, cz - 3)):
        for a in (0, 1):
            for b in (0, 1):
                celdas[(x + a - (x > 0), -3, z + b)] = "Gemita"
    colores = {
        "Hielo": ("#A8D8FF", 0.05, None, 0.0, 0.6),
        "HieloMedio": ("#D0ECFF", 0.05, None, 0.0, 0.55),
        "HieloClaro": ("#F4FBFF", 0.05, None, 0.0, 0.5),
        "Faceta": ("#FFFFFF", 0.05, "#E0F4FF", 0.3, 0.85),
        "Nucleo": ("#E8F8FF", 0.2, "#9FDCFF", 4.0, 1),
        "Pie": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Remache": ("#FFFFFF", 0.2, None, 0.0, 1),
        "Gemita": ("#2E6BFF", 0.05, "#3C78FF", 0.6, 1),
        "Cristal": ("#8CC8FF", 0.15, None, 0.0, 1),
        "CristalClaro": ("#E0F4FF", 0.15, "#BFE4FF", 0.5, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return cubitos(nombre, celdas, colores)


def aurora_boreal(nombre):
    """Mítica (Glaciar): cristal alto y transparente en capas (cuadrados y rombos) con franjas verde,
    celeste y violeta onduladas como una aurora, núcleo blanco que brilla, aristas de plata y
    anillo cuadrado de plata alrededor; base de roca helada."""
    anchos = [2, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 3, 3, 2, 2, 1, 0]
    zb = 4
    franjas = ["Verde", "Celeste", "Violeta"]

    def onda(x, y, z):
        return franjas[int(((z - zb) + 2.2 * math.sin((x + y) * 0.6)) / 3) % 3]

    def cuerpo(celdas):
        _capas_gema(celdas, zb, anchos, franjas, arista="Plata", forma=lambda z: (z // 4) % 2 == 1, mancha=onda)
        celdas[(0, 0, zb + len(anchos))] = "Plata"

    colores = {
        "Verde": ("#2EE88A", 0.05, "#2EE88A", 0.25, 0.6),
        "Celeste": ("#2EC8F0", 0.05, "#2EC8F0", 0.25, 0.6),
        "Violeta": ("#9A5CFF", 0.05, "#9A5CFF", 0.25, 0.6),
        "Nucleo": ("#F0FFFA", 0.2, "#C8FFF0", 1.5, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Zocalo": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.35, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=12)


def estrella_de_escarcha(nombre):
    """Mítica (Glaciar): estrella de 6 puntas parada, de hielo celeste en capas (cáscara de vidrio en
    degradé, bordes como facetas) con un centro blanco que brilla fuerte, marco de plata con
    remaches y anillo cuadrado de plata alrededor; base de roca helada."""
    cz = 14

    def cuerpo(celdas):
        plano = set()
        for x in range(-10, 11):
            for z in range(-11, 12):
                a = math.atan2(x, z) % (math.pi / 3)
                f = abs(a - math.pi / 6) / (math.pi / 6)  # 1 en las puntas, 0 entre puntas
                if math.hypot(x, z) <= 4.6 + 5.4 * f**1.5:
                    plano.add((x, cz + z))
        _emblema(celdas, plano, ["HieloOscuro", "Hielo", "HieloClaro"], aro="Plata", cada=3)

    colores = {
        "HieloOscuro": ("#3CA8F0", 0.05, None, 0.0, 0.65),
        "Hielo": ("#7FD0FF", 0.05, None, 0.0, 0.6),
        "HieloClaro": ("#C8ECFF", 0.05, None, 0.0, 0.55),
        "Faceta": ("#F0FAFF", 0.05, "#C8ECFF", 0.3, 0.85),
        "Nucleo": ("#FFFFFF", 0.2, "#E0F6FF", 3.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Remache": ("#FFFFFF", 0.2, None, 0.0, 1),
        "Zocalo": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.35, 1),
        **{k: GLACIAR_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=6)


def copo_eterno(nombre):
    """Celestial (Glaciar): copo de nieve grande de cristal azul y blanco (6 brazos con ramitas, más
    grueso al centro, núcleo celeste que brilla fuerte) flotando sobre un pedestal de nieve; halo,
    anillo y 3 gemitas que orbitan."""

    def gema(celdas, zb):
        cz = zb + 10
        plano = _copo(cz, 9.0, grueso=1.1)
        _emblema(celdas, plano, ["Azul", "AzulClaro", "Blanco"], aro=None)
        return max(z for _, z in plano)

    colores = {
        "Azul": ("#3C78FF", 0.05, None, 0.0, 0.65),
        "AzulClaro": ("#8CC8FF", 0.05, None, 0.0, 0.55),
        "Blanco": ("#F4FBFF", 0.05, None, 0.0, 0.5),
        "Faceta": ("#FFFFFF", 0.05, "#E0F4FF", 0.3, 0.85),
        "Nucleo": ("#C8F0FF", 0.2, "#5CD0FF", 4.0, 1),
        "Halo": ("#9FDCFF", 0.1, "#7FD0FF", 0.8, 0.5),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.4, 1),
        "Gemita1": ("#5CE0FF", 0.05, "#5CE0FF", 0.8, 1),
        "Gemita2": ("#FFFFFF", 0.05, "#E0F4FF", 0.8, 1),
        "Gemita3": ("#3C78FF", 0.05, "#3C78FF", 0.8, 1),
        "Cristalito": ("#BFE4FF", 0.1, "#BFE4FF", 0.4, 1),
        **GLACIAR_ROCA,
    }
    return celestial(nombre, gema, colores)


def trono_de_hielo(nombre):
    """Celestial (Glaciar): tronito de hielo (asiento, respaldo con almenas, apoyabrazos y patas)
    con filetes de plata, y una gema azul con núcleo que brilla flotando arriba del asiento; flota
    sobre un pedestal de nieve con halo, anillo y 3 gemitas que orbitan."""

    def gema(celdas, zb):
        def hielo(x, y, z):
            v = (z - zb) / 16 + (h(x, y, z, 151) - 0.5) * 0.2
            return "HieloClaro" if v > 0.6 else "Hielo" if v > 0.3 else "HieloOscuro"

        for x in range(-5, 6):
            for y in range(-4, 5):
                for z in range(zb, zb + 4):
                    pata = abs(x) >= 4 and abs(y) >= 3
                    if z < zb + 2 and not pata:
                        continue
                    borde = z == zb + 3 and (abs(x) == 5 or abs(y) == 4)
                    celdas[(x, y, z)] = "Plata" if borde else hielo(x, y, z)
        for x in range(-5, 6):  # respaldo con almenas
            for y in (3, 4):
                for z in range(zb + 4, zb + 15):
                    if z >= zb + 13 and x % 2:
                        continue
                    celdas[(x, y, z)] = "Plata" if abs(x) == 5 else hielo(x, y, z)
        for x in (-5, 5):  # apoyabrazos
            for y in range(-4, 3):
                for z in (zb + 4, zb + 5, zb + 6):
                    celdas[(x, y, z)] = "Plata" if z == zb + 6 else hielo(x, y, z)
        _capas_gema(celdas, zb + 16, [0, 1, 2, 3, 3, 3, 2, 1, 0], ["Azul", "AzulMedio", "AzulClaro"],
                    arista="Faceta")
        return zb + 24

    colores = {
        "HieloOscuro": ("#9FD0F0", 0.05, None, 0.0, 0.75),
        "Hielo": ("#C8E8FA", 0.05, None, 0.0, 0.7),
        "HieloClaro": ("#EEF8FF", 0.05, None, 0.0, 0.65),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Azul": ("#0A2A8C", 0.05, None, 0.0, 0.8),
        "AzulMedio": ("#1446D8", 0.05, None, 0.0, 0.7),
        "AzulClaro": ("#3C78FF", 0.05, None, 0.0, 0.65),
        "Faceta": ("#9CC0FF", 0.05, "#7FA8FF", 0.3, 0.85),
        "Nucleo": ("#BFE0FF", 0.2, "#3C78FF", 4.0, 1),
        "Halo": ("#9FDCFF", 0.1, "#7FD0FF", 0.8, 0.5),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.4, 1),
        "Gemita1": ("#5CE0FF", 0.05, "#5CE0FF", 0.8, 1),
        "Gemita2": ("#FFFFFF", 0.05, "#E0F4FF", 0.8, 1),
        "Gemita3": ("#3C78FF", 0.05, "#3C78FF", 0.8, 1),
        "Cristalito": ("#BFE4FF", 0.1, "#BFE4FF", 0.4, 1),
        **GLACIAR_ROCA,
    }
    return celestial(nombre, gema, colores)


VOLCAN_ROCA = {
    "Roca": ("#4A3F3C", 0.85, None, 0.0, 1),
    "RocaOscura": ("#2A2322", 0.9, None, 0.0, 1),
    "Veta": ("#FF5A1A", 0.4, "#FF5A1A", 1.2, 1),  # vetita de lava
    "Suelo": ("#3A2E2C", 0.9, None, 0.0, 1),
    "Piedra": ("#5A4A44", 0.85, None, 0.0, 1),
}
VOLCAN_SUELO = {
    "Suelo": ("#3A2E2C", 0.9, None, 0.0, 1),
    "SueloOscuro": ("#221A19", 0.9, None, 0.0, 1),
    "Piedrita": ("#FF6A1A", 0.4, "#FF5A1A", 1.0, 1),  # brasitas
}


def _plano_corazon(cz, alto, ancho):
    """Silueta de corazón en el plano x-z: 2 lóbulos arriba y punta abajo, de 'alto' cubitos."""
    zb = cz - alto // 2
    plano = set()
    for x in range(-int(ancho) - 2, int(ancho) + 3):
        for z in range(zb, zb + alto + 2):
            u = (x + 0.5) / ancho
            v = -1 + (z - zb + 0.5) / alto * 1.97
            lobulo = min(math.hypot(u - 0.48, v - 0.45), math.hypot(u + 0.48, v - 0.45)) <= 0.52
            if lobulo or (v <= 0.45 and abs(u) <= (v + 1) / 1.45):
                plano.add((x, z))
    return plano


def obsidiana(nombre):
    """Común (Volcán): trozo de obsidiana negra brillante con canto filoso en escalones, reflejos
    gris violáceo arriba, grietas de lava, cristalitos de vidrio ahumado con brasa adentro y base
    de ceniza con brasitas."""
    colores = {
        "Oscuro": ("#0C0A10", 0.05, None, 0.0, 1),
        "Medio": ("#1C1824", 0.05, None, 0.0, 1),
        "Claro": ("#3A3448", 0.05, None, 0.0, 1),
        "Grieta": ("#FF5A1A", 0.4, "#FF5A1A", 1.0, 1),
        "Cristal": ("#2A2236", 0.05, "#3A2A5A", 0.2, 1),
        "Vidrio": ("#4A3E5A", 0.05, None, 0.0, 0.55),
        "Nucleo": ("#FF7A1A", 0.2, "#FF6A00", 2.0, 1),
        **VOLCAN_SUELO,
    }
    return comun(nombre, colores, 201)


def basalto_rojo(nombre):
    """Común (Volcán): piedra de basalto gris oscuro en escalones con puntitos rojos, grietas
    negras, cristalitos rojos y base de ceniza con brasitas."""
    colores = {
        "Oscuro": ("#4A4A50", 0.85, None, 0.0, 1),
        "Medio": ("#686870", 0.8, None, 0.0, 1),
        "Claro": ("#8C8C94", 0.75, None, 0.0, 1),
        "Mota": ("#E0262A", 0.4, "#E0262A", 0.4, 1),
        "Grieta": ("#1A1A1E", 0.9, None, 0.0, 1),
        "Cristal": ("#C8202A", 0.15, "#E0262A", 0.4, 1),
        "Vidrio": ("#FF8A8A", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#FF3030", 0.2, "#FF3030", 2.0, 1),
        **VOLCAN_SUELO,
    }
    return comun(nombre, colores, 211, motas=0.12)


def granate(nombre):
    """Rara (Volcán): 4 columnas anchas y petisas de granate rojo oscuro (puntas bajas, se ven
    gorditas y redondeadas), centro que brilla suave, sobre roca volcánica con vetitas de lava."""
    colores = {
        "Oscuro": ("#4A0812", 0.05, None, 0.0, 0.9),
        "Medio": ("#7A1020", 0.05, None, 0.0, 0.88),
        "Claro": ("#A01828", 0.05, None, 0.0, 0.85),
        "Arista": ("#E0505A", 0.05, "#C8303A", 0.25, 0.85),
        "Centro": ("#FF6A70", 0.2, "#E0303A", 1.0, 1),
        "Suelto": ("#B01E30", 0.15, "#C8303A", 0.4, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    columnas = [(0, 0, 3, 17, 0, 0), (-5, 1, 2, 12, -1, 0), (5, -1, 2, 13, 1, 0), (0, 4, 2, 9, 0, 1)]
    return rara(nombre, colores, columnas, 221)


def cristal_de_azufre(nombre):
    """Rara (Volcán): racimo de 7 cristalitos finitos amarillo limón de distintas alturas, con
    centro que brilla suave, sobre roca volcánica con vetitas de lava."""
    colores = {
        "Oscuro": ("#C8B000", 0.05, None, 0.0, 0.7),
        "Medio": ("#F0DC10", 0.05, None, 0.0, 0.6),
        "Claro": ("#FFF470", 0.05, None, 0.0, 0.55),
        "Arista": ("#FFFDC0", 0.05, "#FFF470", 0.25, 0.85),
        "Centro": ("#FFFBA0", 0.2, "#F0DC10", 0.9, 1),
        "Suelto": ("#F0DC10", 0.15, "#F0DC10", 0.4, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    columnas = [(0, 0, 1, 18, 0, 0), (-3, 1, 1, 14, -1, 0), (3, -1, 1, 15, 1, 0), (-1, 3, 1, 11, 0, 1),
                (2, 3, 1, 9, 1, 1), (-4, -3, 1, 8, -1, -1), (4, -4, 1, 10, 1, -1)]
    return rara(nombre, colores, columnas, 231)


VOLCAN_TALLADA = {
    "Roca": ("#4A3F3C", 0.85, None, 0.0, 1),
    "RocaOscura": ("#2A2322", 0.9, None, 0.0, 1),
    "Pasto": ("#FF6A1A", 0.4, "#FF5A1A", 1.0, 1),
}
TALLADAS_CUBITOS["Rubi"] = {
    "engarce": (4, 4),
    "anchos": [(1, 0), (2, 1), (3, 2), (4, 3), (4, 3), (5, 4), (5, 4), (5, 4), (5, 4), (4, 3), (4, 3),
               (3, 3), (3, 2), (3, 2), (2, 2), (2, 1), (1, 1), (1, 1), (1, 0), (0, 0)],
    "garras": (4, 3, 9),
    "tonos": ("RojoOscuro", "RojoMedio", "RojoClaro"),
    "colores": {
        "RojoOscuro": ("#6A0010", 0.05, None, 0.0, 0.8),
        "RojoMedio": ("#B0001E", 0.05, None, 0.0, 0.7),
        "RojoClaro": ("#E8102E", 0.05, None, 0.0, 0.65),
        "Faceta": ("#E0203A", 0.05, "#FF1030", 0.3, 0.8),
        "Corazon": ("#FF7080", 0.2, "#FF1030", 2.5, 1),
        "Cristal": ("#C8102A", 0.15, "#E8102E", 0.4, 1),
    },
    "base": VOLCAN_TALLADA,
}
TALLADAS_CUBITOS["OpalodeFuego"] = {
    "engarce": (5, 5),
    "anchos": [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (4, 4),
               (4, 4), (3, 3), (2, 2), (1, 1)],
    "garras": (5, 5, 11),
    "tonos": ("FuegoRojo", "FuegoNaranja", "FuegoAmarillo"),
    "colores": {
        "FuegoRojo": ("#E83A10", 0.05, "#E83A10", 0.3, 0.65),
        "FuegoNaranja": ("#FF8A1A", 0.05, "#FF8A1A", 0.3, 0.6),
        "FuegoAmarillo": ("#FFD030", 0.05, "#FFD030", 0.3, 0.55),
        "Faceta": ("#FFB060", 0.05, "#FF9A30", 0.5, 0.75),
        "Corazon": ("#FFE070", 0.2, "#FF4A10", 3.0, 1),
        "Cristal": ("#FF8A1A", 0.15, "#FF8A1A", 0.4, 1),
    },
    "base": VOLCAN_TALLADA,
}


def rubi(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["Rubi"])


def opalo_de_fuego(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["OpalodeFuego"])


def nucleo_de_magma(nombre):
    """Legendaria (Volcán): esfera de cubitos de roca negra (3 tonos) con grietas de lava naranja
    medio transparentes por las que se ve un centro amarillo que brilla fuerte (malla aparte),
    cinto de oro con remaches y 3 gemitas de fuego engarzadas; tallo y pie de oro sobre roca
    volcánica con cristales naranjas."""
    celdas = {}
    _base_legendaria(celdas, 241)
    r, cz = 7.2, 14
    _tallo(celdas, cz - 7)
    for x in range(-8, 9):
        for y in range(-8, 9):
            for z in range(cz - 8, cz + 9):
                d = math.sqrt(x * x + y * y + (z - cz) ** 2)
                if d > r:
                    continue
                if d < 3.2:
                    celdas[(x, y, z)] = "Nucleo"
                elif d > r - 1.6:
                    # grietas: donde una suma de ondas pasa cerca de cero
                    onda = math.sin(x * 0.9 + z * 0.4) + math.sin(y * 0.8 - z * 0.7) + math.sin((x - y) * 0.5)
                    if abs(onda) < 0.32:
                        celdas[(x, y, z)] = "Lava"
                    else:
                        v = (z - cz + r) / (2 * r) + (h(x, y, z, 242) - 0.5) * 0.2
                        celdas[(x, y, z)] = "RocaClara" if v > 0.62 else "RocaMedia" if v > 0.3 else "RocaNegra"
    for x in range(-8, 9):  # cinto de oro en el ecuador
        for y in range(-8, 9):
            d = math.hypot(x, y)
            if r - 0.6 <= d <= r + 0.9:
                celdas[(x, y, cz)] = "Oro"
                if (x + y) % 3 == 0:
                    celdas[(x, y, cz + 1)] = celdas[(x, y, cz - 1)] = "Remache"
    for x, y in ((0, -8), (-6, -5), (6, -5)):
        for z in (cz, cz + 1):
            celdas[(x, y, z)] = "Gemita"
    colores = {
        "RocaNegra": ("#14100E", 0.6, None, 0.0, 1),
        "RocaMedia": ("#2A2220", 0.6, None, 0.0, 1),
        "RocaClara": ("#463A36", 0.55, None, 0.0, 1),
        "Lava": ("#FF6A10", 0.3, "#FF5A00", 2.0, 0.75),
        "Nucleo": ("#FFF060", 0.2, "#FFD000", 5.0, 1),
        "Pie": ("#F2B92E", 0.25, None, 0.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Gemita": ("#FF3A10", 0.05, "#FF3A10", 0.7, 1),
        "Cristal": ("#E85A10", 0.15, None, 0.0, 1),
        "CristalClaro": ("#FFB040", 0.15, "#FF9A20", 0.6, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return cubitos(nombre, celdas, colores)


def piedra_fenix(nombre):
    """Legendaria (Volcán): gema roja y naranja en rombo (núcleo que brilla fuerte, aparte) con alas
    de plumas de cubitos abiertas hacia arriba (rojo, naranja y punta amarilla), cresta y cola de 3
    plumas; remaches de oro donde nacen las alas y 3 gemitas doradas engarzadas; tallo y pie de
    oro sobre roca volcánica con cristales."""
    celdas = {}
    _base_legendaria(celdas, 251)
    cz = 15
    plano = {(x, z) for x in range(-6, 7) for z in range(cz - 7, cz + 8) if abs(x) * 1.15 + abs(z - cz) <= 7}
    marco = _emblema(celdas, plano, ["Rojo", "Naranja", "Amarilla"], aro="Oro", cada=3)
    _tallo(celdas, min(z for _, z in marco))
    for s in (-1, 1):  # alas: 5 plumas que salen del costado y suben
        for i in range(5):
            largo = 6 - i
            z0 = cz - 1 + i * 2
            for j in range(largo):
                x = s * (5 - i // 2 + j)
                z = z0 + j // 2
                if (x, z) in plano or (x, z) in marco:
                    continue
                clave = "Pluma3" if j >= largo - 1 else "Pluma2" if j >= largo - 3 else "Pluma1"
                for y in (-1, 0):
                    for dz in (0, -1):
                        if (x, z + dz) not in plano and (x, z + dz) not in marco:
                            celdas[(x, y, z + dz)] = clave
            celdas[(s * (5 - i // 2), -2, z0)] = "Remache"
    for i, (x, dz) in enumerate(((0, 0), (-1, 1), (1, 1), (0, 2))):  # cresta
        celdas[(x, 0, cz + 8 + dz)] = "Pluma3" if dz == 2 else "Pluma2"
    for x0 in (-2, 2):  # cola: 2 plumas que caen a los costados del tallo
        for j in range(4):
            celdas[(x0 + (1 if x0 > 0 else -1) * (j // 2), 0, cz - 8 - j)] = "Pluma2" if j < 3 else "Pluma3"
    for x, z in ((0, cz), (-3, cz - 2), (3, cz - 2)):
        celdas[(x, -4, z)] = "Gemita"
    colores = {
        "Rojo": ("#C8101E", 0.05, None, 0.0, 0.7),
        "Naranja": ("#FF5A10", 0.05, None, 0.0, 0.6),
        "Amarilla": ("#FFA020", 0.05, None, 0.0, 0.55),
        "Faceta": ("#FFB070", 0.05, "#FF8A40", 0.4, 0.8),
        "Nucleo": ("#FFE070", 0.2, "#FF6A10", 5.0, 1),
        "Pluma1": ("#D8201E", 0.3, "#D8201E", 0.4, 1),
        "Pluma2": ("#FF7A10", 0.3, "#FF7A10", 0.6, 1),
        "Pluma3": ("#FFD030", 0.25, "#FFD030", 1.0, 1),
        "Pie": ("#F2B92E", 0.25, None, 0.0, 1),
        "Oro": ("#F2B92E", 0.25, None, 0.0, 1),
        "Remache": ("#FFE58A", 0.2, None, 0.0, 1),
        "Gemita": ("#FFD24A", 0.05, "#FFD24A", 0.7, 1),
        "Cristal": ("#E85A10", 0.15, None, 0.0, 1),
        "CristalClaro": ("#FFB040", 0.15, "#FF9A20", 0.6, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return cubitos(nombre, celdas, colores)


def ojo_de_dragon(nombre):
    """Mítica (Volcán): gema roja en capas (cuadrados y rombos) con escamas de cubitos en dos rojos,
    aristas de oro, núcleo naranja que brilla y un ojo de dragón al frente: iris amarillo con la
    pupila de rendija negra. Anillo cuadrado de oro oscuro alrededor."""
    anchos = [3, 4, 5, 5, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 4, 4, 3, 3, 2, 1, 0]
    zb = 4

    def escamas(x, y, z):
        if (z - zb) % 2 == 0 and (x + y + (z // 2)) % 2 == 0:
            return "Escama"
        return None

    def cuerpo(celdas):
        w_de = _capas_gema(celdas, zb, anchos, ["RojoOscuro", "Rojo", "RojoClaro"], arista="Oro",
                           mancha=escamas)
        celdas[(0, 0, zb + len(anchos))] = "Oro"
        ojo = ["...AAA...",
               "..AAAAA..",
               ".AAANAAA.",
               "AAAANAAAA",
               "AAAANAAAA",
               ".AAANAAA.",
               "..AAAAA..",
               "...AAA..."]
        zc = zb + 11
        for fila, linea in enumerate(ojo):
            z = zc - fila
            w = w_de[z]
            for i, ch in enumerate(linea):
                x = i - 4
                if ch != "." and abs(x) <= w:
                    celdas[(x, -w, z)] = {"A": "Iris", "N": "Pupila"}[ch]
            for x in (-5, 5):  # párpado de oro a los costados
                if abs(x) <= w:
                    celdas[(x, -w, z)] = "Oro"

    colores = {
        "RojoOscuro": ("#5A0610", 0.05, None, 0.0, 0.85),
        "Rojo": ("#A00E1E", 0.05, None, 0.0, 0.8),
        "RojoClaro": ("#D81E2E", 0.05, None, 0.0, 0.75),
        "Escama": ("#7A0A16", 0.2, None, 0.0, 0.9),
        "Iris": ("#FFD020", 0.2, "#FFB000", 1.2, 1),
        "Pupila": ("#0A0404", 0.3, None, 0.0, 1),
        "Nucleo": ("#FF8A20", 0.2, "#FF5A00", 2.0, 1),
        "Oro": ("#D8A020", 0.25, None, 0.0, 1),
        "Zocalo": ("#2A2322", 0.6, None, 0.0, 1),
        "Anillo": ("#C8901A", 0.25, "#FFB040", 0.3, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=6)


def llama_viva(nombre):
    """Mítica (Volcán): cristal con forma de llama: capas que se mecen de lado a lado y arriba se
    abren en 3 lenguas de distinta altura; cáscara en degradé rojo, naranja y amarillo, núcleo
    blanco amarillento que brilla fuerte y anillo cuadrado de hierro oscuro con brasas."""
    anchos = [3, 4, 5, 5, 5, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2]
    zb = 4
    tonos = ["Rojo", "Naranja", "Amarilla", "AmarillaClara"]

    def vaiven(z):
        return round(1.2 * math.sin((z - zb) * 0.6))

    def cuerpo(celdas):
        capa = {}
        _capas_gema(capa, zb, anchos, tonos, arista=None)
        for (x, y, z), k in capa.items():
            celdas[(x + vaiven(z), y, z)] = k
        ztop = zb + len(anchos)
        for x0, y0, alto, ladeo in ((0, 0, 8, 1), (-2, 1, 5, -1), (2, -1, 4, 1)):  # lenguas
            for i in range(alto):
                z = ztop + i
                x = x0 + vaiven(ztop) + ladeo * (i // 3)
                ancho = 1 if i < alto - 2 else 0
                for a in range(-ancho, ancho + 1):
                    for b in range(-ancho, ancho + 1):
                        celdas[(x + a, y0 + b, z)] = "AmarillaClara" if i >= alto - 3 else "Amarilla"

    colores = {
        "Rojo": ("#E0201A", 0.05, "#E0201A", 0.4, 0.75),
        "Naranja": ("#FF6A10", 0.05, "#FF6A10", 0.5, 0.7),
        "Amarilla": ("#FFB020", 0.05, "#FFB020", 0.6, 0.65),
        "AmarillaClara": ("#FFE870", 0.05, "#FFE060", 0.9, 0.65),
        "Nucleo": ("#FFF8C0", 0.2, "#FFE070", 3.0, 1),
        "Zocalo": ("#2A2322", 0.6, None, 0.0, 1),
        "Anillo": ("#3A302C", 0.5, "#FF5A10", 0.3, 1),
        **{k: VOLCAN_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=7)


def corazon_del_volcan(nombre):
    """Celestial (Volcán): corazón de roca negra (más grueso al medio) con vetas de lava medio
    transparentes y un núcleo de lava que late (malla aparte), flotando sobre un pedestal de roca
    volcánica; halo de fuego, anillo de fuego y 3 gemitas de brasa que orbitan."""

    def gema(celdas, zb):
        cz = zb + 12
        plano = _plano_corazon(cz, 21, 7.5)
        _emblema(celdas, plano, ["RocaNegra", "RocaMedia", "RocaClara"], aro=None)
        for (x, y, z), k in list(celdas.items()):
            if k in ("RocaNegra", "RocaMedia", "RocaClara", "Faceta") and (x, z) in plano:
                onda = math.sin(x * 0.9 + z * 0.5) + math.sin(x * 0.4 - z * 0.8)
                if abs(onda) < 0.28:
                    celdas[(x, y, z)] = "Lava"
        return max(z for _, z in plano)

    colores = {
        "RocaNegra": ("#14100E", 0.6, None, 0.0, 1),
        "RocaMedia": ("#2A2220", 0.6, None, 0.0, 1),
        "RocaClara": ("#463A36", 0.55, None, 0.0, 1),
        "Faceta": ("#5A4A44", 0.5, None, 0.0, 1),
        "Lava": ("#FF6A10", 0.3, "#FF5A00", 2.0, 0.75),
        "Nucleo": ("#FFB020", 0.2, "#FF7A00", 5.0, 1),
        "Halo": ("#FF7A20", 0.1, "#FF5A10", 1.0, 0.55),
        "Anillo": ("#FF8A20", 0.2, "#FF6A10", 1.2, 1),
        "Gemita1": ("#FF3A10", 0.05, "#FF3A10", 0.9, 1),
        "Gemita2": ("#FFD030", 0.05, "#FFD030", 0.9, 1),
        "Gemita3": ("#FF7A10", 0.05, "#FF7A10", 0.9, 1),
        "Cristalito": ("#FF6A10", 0.2, "#FF5A00", 0.8, 1),
        **VOLCAN_ROCA,
    }
    return celestial(nombre, gema, colores)


def corona_ignea(nombre):
    """Celestial (Volcán): corona de obsidiana (aro negro brillante con remaches de oro) con 8 puntas
    que terminan en llamitas de cubitos, y un rubí gigante en capas en el centro (núcleo que brilla
    fuerte). Halo de llamas, anillo y 3 gemitas que orbitan; pedestal de roca volcánica."""

    def gema(celdas, zb):
        anchos = [1, 2, 3, 4, 5, 5, 6, 6, 6, 6, 6, 6, 5, 5, 4, 4, 3, 3, 2, 1, 1, 0]
        _capas_gema(celdas, zb + 1, anchos, ["RubiOscuro", "Rubi", "RubiClaro"])
        for z in range(zb, zb + 5):
            for x in range(-7, 8):
                for y in range(-7, 8):
                    d = max(abs(x), abs(y))
                    if d == 7 or (d == 6 and z == zb):
                        remache = z == zb + 2 and d == 7 and (x + y) % 3 == 0
                        celdas[(x, y, z)] = "Remache" if remache else "Obsidiana"
        for x, y in ((-7, -7), (7, -7), (-7, 7), (7, 7), (0, -7), (0, 7), (-7, 0), (7, 0)):
            alto = 5 if x == 0 or y == 0 else 3
            for z in range(zb + 5, zb + 5 + alto):
                celdas[(x, y, z)] = "Obsidiana"
            celdas[(x, y, zb + 5 + alto)] = "Fuego"
            celdas[(x, y, zb + 6 + alto)] = "FuegoClaro"
        return zb + 1 + len(anchos) - 1

    def halo(celdas, hz):
        for x in range(-8, 9):
            alto = 4 + round(3 * abs(math.sin(x * 0.9)))
            for z in range(hz - 2, hz + alto + 2):
                if abs(x) >= 6 or z >= hz + alto:
                    celdas[(x, 9, z)] = "Halo"

    colores = {
        "RubiOscuro": ("#6A0010", 0.05, None, 0.0, 0.8),
        "Rubi": ("#B0001E", 0.05, None, 0.0, 0.7),
        "RubiClaro": ("#E8102E", 0.05, None, 0.0, 0.65),
        "Faceta": ("#FF5A6A", 0.05, "#FF2A40", 0.3, 0.8),
        "Nucleo": ("#FF8090", 0.2, "#FF1030", 4.0, 1),
        "Obsidiana": ("#14101A", 0.05, None, 0.0, 1),
        "Remache": ("#F2B92E", 0.25, None, 0.0, 1),
        "Fuego": ("#FF6A10", 0.2, "#FF5A00", 1.5, 1),
        "FuegoClaro": ("#FFD030", 0.2, "#FFC000", 2.0, 1),
        "Halo": ("#FF7A20", 0.1, "#FF5A10", 1.0, 0.55),
        "Anillo": ("#3A302C", 0.4, "#FF6A10", 0.5, 1),
        "Gemita1": ("#E8102E", 0.05, "#E8102E", 0.9, 1),
        "Gemita2": ("#FFD030", 0.05, "#FFD030", 0.9, 1),
        "Gemita3": ("#FF6A10", 0.05, "#FF6A10", 0.9, 1),
        "Cristalito": ("#FF6A10", 0.2, "#FF5A00", 0.8, 1),
        **VOLCAN_ROCA,
    }
    return celestial(nombre, gema, colores, halo=halo)


ABISMO_ROCA = {
    "Roca": ("#2A2440", 0.8, None, 0.0, 1),
    "RocaOscura": ("#16122A", 0.85, None, 0.0, 1),
    "Veta": ("#B98CFF", 0.3, "#B98CFF", 1.0, 1),  # vetita que brilla
    "Suelo": ("#221C38", 0.85, None, 0.0, 1),
    "Piedra": ("#3A3258", 0.8, None, 0.0, 1),
}
ABISMO_SUELO = {
    "Suelo": ("#2A2440", 0.85, None, 0.0, 1),
    "SueloOscuro": ("#16122A", 0.9, None, 0.0, 1),
    "Piedrita": ("#B98CFF", 0.3, "#B98CFF", 0.8, 1),
}
ESTRELLA = ("#FFFFFF", 0.1, "#FFFFFF", 2.0, 1)


def meteorita(nombre):
    """Común (Abismo): trozo de meteorito gris oscuro en escalones con puntitos metálicos, grietas
    negras, cristalitos de metal azulado y base de suelo del abismo con piedritas que brillan."""
    colores = {
        "Oscuro": ("#2E2E34", 0.75, None, 0.0, 1),
        "Medio": ("#46464E", 0.7, None, 0.0, 1),
        "Claro": ("#64646E", 0.65, None, 0.0, 1),
        "Mota": ("#D8DCE6", 0.15, None, 0.0, 1),
        "Grieta": ("#121216", 0.9, None, 0.0, 1),
        "Cristal": ("#8C9CB8", 0.15, "#8C9CB8", 0.2, 1),
        "Vidrio": ("#B8C4D8", 0.05, None, 0.0, 0.5),
        "Nucleo": ("#9FC0FF", 0.2, "#7FA8FF", 2.0, 1),
        **ABISMO_SUELO,
    }
    return comun(nombre, colores, 301, motas=0.15)


def polvo_estelar(nombre):
    """Común (Abismo): piedrita violeta oscuro en escalones con brillitos blancos salteados, grietas
    negras, cristalitos violeta y base de suelo del abismo."""
    colores = {
        "Oscuro": ("#2A1450", 0.6, None, 0.0, 1),
        "Medio": ("#3E1E72", 0.55, None, 0.0, 1),
        "Claro": ("#58309A", 0.5, None, 0.0, 1),
        "Mota": ESTRELLA,
        "Grieta": ("#120828", 0.9, None, 0.0, 1),
        "Cristal": ("#9A5CFF", 0.15, "#9A5CFF", 0.4, 1),
        "Vidrio": ("#C8A8FF", 0.05, None, 0.0, 0.45),
        "Nucleo": ("#FFFFFF", 0.2, "#E0D0FF", 2.0, 1),
        **ABISMO_SUELO,
    }
    return comun(nombre, colores, 317, motas=0.08)


def iolita(nombre):
    """Rara (Abismo): 3 columnas de iolita azul violeta con punta escalonada y centro que brilla
    suave, sobre roca del abismo con vetitas que brillan."""
    colores = {
        "Oscuro": ("#2A2A8C", 0.05, None, 0.0, 0.75),
        "Medio": ("#4848C8", 0.05, None, 0.0, 0.65),
        "Claro": ("#7A72F0", 0.05, None, 0.0, 0.6),
        "Arista": ("#B8B0FF", 0.05, "#9A90FF", 0.25, 0.85),
        "Centro": ("#C8C0FF", 0.2, "#7A72F0", 1.0, 1),
        "Suelto": ("#7A72F0", 0.15, "#7A72F0", 0.4, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return rara(nombre, colores, [(0, 0, 2, 19, 0, 0), (-4, 2, 2, 14, -1, 1), (4, -2, 2, 12, 1, -1)], 321)


def fluorita_nocturna(nombre):
    """Rara (Abismo): 3 columnas anchas de fluorita casi cúbicas con franjas violeta, verde y violeta
    claro de abajo hacia arriba, centro que brilla suave, sobre roca del abismo."""
    colores = {
        "Oscuro": ("#6A2AC8", 0.05, None, 0.0, 0.7),
        "Medio": ("#2EC87A", 0.05, None, 0.0, 0.65),
        "Claro": ("#B07AFF", 0.05, None, 0.0, 0.6),
        "Arista": ("#C8A8FF", 0.05, "#B08CFF", 0.25, 0.85),
        "Centro": ("#D8FFE8", 0.2, "#5CFFA8", 1.0, 1),
        "Suelto": ("#2EC87A", 0.15, "#2EC87A", 0.4, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return rara(nombre, colores, [(0, 0, 3, 18, 0, 0), (-5, 2, 2, 12, -1, 0), (5, -1, 2, 10, 1, 0)], 331)


ABISMO_TALLADA = {
    "Roca": ("#2A2440", 0.8, None, 0.0, 1),
    "RocaOscura": ("#16122A", 0.85, None, 0.0, 1),
    "Pasto": ("#B98CFF", 0.3, "#B98CFF", 0.8, 1),
    "Oro": ("#D9E2EC", 0.2, None, 0.0, 1),  # engarce de plata
}
TALLADAS_CUBITOS["OpaloNegro"] = {
    "engarce": (5, 5),
    "anchos": [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (5, 5), (4, 4),
               (4, 4), (3, 3), (2, 2), (1, 1)],
    "garras": (5, 5, 11),
    "tonos": ("DestelloVioleta", "DestelloVerde", "DestelloAzul"),
    "colores": {
        "DestelloVioleta": ("#120A1E", 0.05, "#9A3CFF", 0.15, 0.95),
        "DestelloVerde": ("#08140E", 0.05, "#2EFF8A", 0.12, 0.95),
        "DestelloAzul": ("#080E1E", 0.05, "#2E9CFF", 0.15, 0.95),
        "Faceta": ("#0C0812", 0.05, "#FF5CC8", 0.2, 0.95),
        "Corazon": ("#FFD24A", 0.2, "#FF8A2E", 2.5, 1),
        "Cristal": ("#9A3CFF", 0.15, "#9A3CFF", 0.4, 1),
    },
    "base": ABISMO_TALLADA,
}
TALLADAS_CUBITOS["Alejandrita"] = {
    "engarce": (5, 4),
    "anchos": [(1, 0), (1, 1), (2, 1), (3, 2), (3, 2), (4, 3), (5, 3), (5, 3), (6, 4), (6, 4), (6, 4),
               (6, 4), (6, 4), (5, 4), (5, 3), (4, 3), (3, 2), (2, 1)],
    "garras": (5, 3, 15),
    "tonos": ("VerdeOscuro", "VerdeMedio", "VerdeClaro"),
    "tonos_izq": ("VioletaOscuro", "VioletaMedio", "VioletaClaro"),
    "colores": {
        "VerdeOscuro": ("#0A5A3A", 0.05, None, 0.0, 0.75),
        "VerdeMedio": ("#16905C", 0.05, None, 0.0, 0.65),
        "VerdeClaro": ("#3CD08A", 0.05, None, 0.0, 0.6),
        "VioletaOscuro": ("#3A0E6A", 0.05, None, 0.0, 0.75),
        "VioletaMedio": ("#6A22B0", 0.05, None, 0.0, 0.65),
        "VioletaClaro": ("#A05CF0", 0.05, None, 0.0, 0.6),
        "Faceta": ("#A898D8", 0.05, "#8C7CC8", 0.2, 0.75),
        "Corazon": ("#F0E8FF", 0.2, "#C8A8FF", 2.5, 1),
        "Cristal": ("#6A22B0", 0.15, "#3CD08A", 0.4, 1),
    },
    "base": ABISMO_TALLADA,
}


def opalo_negro(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["OpaloNegro"])


def alejandrita(nombre):
    return tallada(nombre, TALLADAS_CUBITOS["Alejandrita"])


def fragmento_de_nebulosa(nombre):
    """Legendaria (Abismo): esquirla de cristal transparente alta y despareja con una nube rosa y
    violeta adentro (núcleo que brilla, aparte), estrellitas blancas en la superficie, marco de
    plata con remaches y 3 gemitas rosas engarzadas; tallo y pie de plata sobre roca del abismo."""
    celdas = {}
    _base_legendaria(celdas, 341)
    cz = 16
    plano = {(x, z) for x in range(-6, 7) for z in range(cz - 9, cz + 10)
             if abs(x + (z - cz) * 0.15) * 1.25 + abs(z - cz) * 0.55 <= 5.6 + (h(x // 2, z // 3, 0, 342) - 0.5)}
    marco = _emblema(celdas, plano, ["Vidrio", "VidrioClaro"], aro="Plata", cada=3)
    _tallo(celdas, min(z for _, z in marco))
    for c, k in list(celdas.items()):
        if k == "Nucleo" and h(*c, 343) < 0.45:
            celdas[c] = "Nube"
        elif k in ("Vidrio", "VidrioClaro") and h(*c, 344) < 0.07:
            celdas[c] = "Estrella"
    for x, z in ((0, cz + 7), (-3, cz - 4), (3, cz - 1)):
        celdas[(x, -4, z)] = "Gemita"
    colores = {
        "Vidrio": ("#E8E4FF", 0.03, None, 0.0, 0.3),
        "VidrioClaro": ("#FFFFFF", 0.03, None, 0.0, 0.25),
        "Faceta": ("#F0ECFF", 0.03, "#D8C8FF", 0.2, 0.5),
        "Nucleo": ("#FF8AD8", 0.3, "#FF5CC8", 2.5, 1),
        "Nube": ("#9A5CFF", 0.3, "#9A5CFF", 2.0, 1),
        "Estrella": ESTRELLA,
        "Pie": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Remache": ("#FFFFFF", 0.2, None, 0.0, 1),
        "Gemita": ("#FF5CC8", 0.05, "#FF5CC8", 0.7, 1),
        "Cristal": ("#9A5CFF", 0.15, None, 0.0, 1),
        "CristalClaro": ("#FF8AD8", 0.15, "#FF5CC8", 0.6, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return cubitos(nombre, celdas, colores)


def ojo_del_vacio(nombre):
    """Legendaria (Abismo): disco de cubitos de vidrio negro parado, con un aro violeta brillante
    de marco (remaches claros), y al frente un ojo: iris violeta y centro blanco que brilla (el
    núcleo, aparte); 3 gemitas violetas engarzadas, tallo y pie de plata sobre roca del abismo."""
    celdas = {}
    _base_legendaria(celdas, 351)
    cz = 15
    plano = {(x, z) for x in range(-8, 9) for z in range(cz - 8, cz + 9) if math.hypot(x, z - cz) <= 7.4}
    marco = _emblema(celdas, plano, ["Negro", "NegroClaro"], aro="Aro", remache="Remache", cada=3)
    _tallo(celdas, min(z for _, z in marco))
    for x, z in plano:  # ojo al frente: iris y centro
        d = math.hypot(x, z - cz)
        y = -min(3, _hondo(plano, x, z))
        if d <= 1.6:
            celdas[(x, y, z)] = "Nucleo"
        elif d <= 3.6:
            celdas[(x, y, z)] = "Iris"
    for x, z in ((0, cz + 9), (-7, cz - 4), (7, cz - 4)):
        celdas[(x, -2, z)] = "Gemita"
    colores = {
        "Negro": ("#08060E", 0.05, None, 0.0, 0.92),
        "NegroClaro": ("#1A1428", 0.05, None, 0.0, 0.9),
        "Faceta": ("#2A2040", 0.05, "#6A3CC8", 0.3, 0.9),
        "Nucleo": ("#FFFFFF", 0.2, "#F0E8FF", 4.0, 1),
        "Iris": ("#9A3CFF", 0.1, "#B05CFF", 1.5, 1),
        "Aro": ("#B05CFF", 0.15, "#B05CFF", 1.5, 1),
        "Remache": ("#E8D8FF", 0.2, None, 0.0, 1),
        "Pie": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Gemita": ("#9A3CFF", 0.05, "#9A3CFF", 0.7, 1),
        "Cristal": ("#6A2AC8", 0.15, None, 0.0, 1),
        "CristalClaro": ("#C8A8FF", 0.15, "#B98CFF", 0.6, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura", "Veta")},
    }
    return cubitos(nombre, celdas, colores)


def cometa_errante(nombre):
    """Mítica (Abismo): cometa de cubitos: cabeza de cristal celeste en capas (cáscara en degradé,
    aristas de plata, núcleo blanco que brilla) arriba a un costado, y una cola de cubitos que
    brillan (blanco, celeste y violeta) que baja en diagonal y se abre hasta el zócalo. Anillo
    cuadrado de plata alrededor."""
    def cuerpo(celdas):
        zb = 17
        capa = {}
        _capas_gema(capa, zb, [1, 2, 3, 4, 4, 4, 4, 3, 2, 1], ["CelesteOscuro", "Celeste", "CelesteClaro"],
                    arista="Plata", forma=lambda z: (z - zb) in (0, 9))
        for (x, y, z), k in capa.items():
            celdas[(x + 3, y + 1, z)] = k
        for i in range(18):  # cola: baja hacia la izquierda y se abre
            t = i / 17
            cx, cz2 = 3 - 7 * t, zb + 3 - 13 * t
            ancho = 1 + 2.4 * t
            for x in range(-4, 5):
                for y in range(-4, 5):
                    for dz in range(-2, 3):
                        px, pz = round(cx + x), round(cz2 + dz)
                        if pz < 4 or math.hypot(x, y) > ancho or abs(dz) > 1:
                            continue
                        if h(px, y, pz, 361) > 0.55 - 0.3 * (1 - t):
                            continue
                        celdas.setdefault((px, y + 1, pz), "Cola1" if t < 0.35 else "Cola2" if t < 0.7 else "Cola3")

    colores = {
        "CelesteOscuro": ("#1E8CD8", 0.05, None, 0.0, 0.65),
        "Celeste": ("#4FC3F7", 0.05, None, 0.0, 0.6),
        "CelesteClaro": ("#A8E6FF", 0.05, None, 0.0, 0.55),
        "Nucleo": ("#FFFFFF", 0.2, "#E0F6FF", 3.0, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Cola1": ("#FFFFFF", 0.1, "#E0F6FF", 1.8, 1),
        "Cola2": ("#7FD8FF", 0.1, "#4FC3F7", 1.4, 1),
        "Cola3": ("#9A7CFF", 0.1, "#9A5CFF", 1.0, 1),
        "Zocalo": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Anillo": ("#E6F0F7", 0.2, "#C8ECFF", 0.35, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=6)


def galaxia_espiral(nombre):
    """Mítica (Abismo): disco de cristal violeta parado (cáscara en degradé, bordes como facetas) con
    una galaxia en espiral de estrellitas de cubitos en las dos caras y un centro blanco que brilla
    fuerte; marco de plata con remaches y anillo cuadrado de plata alrededor."""
    cz = 15

    def cuerpo(celdas):
        plano = {(x, z) for x in range(-9, 10) for z in range(cz - 10, cz + 11) if math.hypot(x, z - cz) <= 8.4}
        _emblema(celdas, plano, ["VioletaOscuro", "Violeta", "VioletaClaro"], aro="Plata", cada=3)
        for brazo in (0, math.pi):
            for i in range(60):
                a = brazo + i * 0.11
                r = 1.2 + i * 0.115
                x, z = round(math.cos(a) * r), cz + round(math.sin(a) * r)
                if (x, z) in plano:
                    g = min(3, _hondo(plano, x, z))
                    for y in (-g, g):
                        celdas[(x, y, z)] = "Estrella" if i % 3 else "EstrellaRosa"

    colores = {
        "VioletaOscuro": ("#2A0E5A", 0.05, None, 0.0, 0.75),
        "Violeta": ("#4A1E96", 0.05, None, 0.0, 0.7),
        "VioletaClaro": ("#7A3CD8", 0.05, None, 0.0, 0.65),
        "Faceta": ("#B08CFF", 0.05, "#9A6CFF", 0.3, 0.8),
        "Nucleo": ("#FFFFFF", 0.2, "#F0E0FF", 4.0, 1),
        "Estrella": ESTRELLA,
        "EstrellaRosa": ("#FF8AD8", 0.1, "#FF5CC8", 1.5, 1),
        "Plata": ("#E6ECF2", 0.2, None, 0.0, 1),
        "Remache": ("#FFFFFF", 0.2, None, 0.0, 1),
        "Zocalo": ("#D9E2EC", 0.2, None, 0.0, 1),
        "Anillo": ("#E6F0F7", 0.2, "#D8C8FF", 0.35, 1),
        **{k: ABISMO_ROCA[k] for k in ("Roca", "RocaOscura")},
    }
    return mitica(nombre, cuerpo, colores, anillo_z=6)


def supernova(nombre):
    """Celestial (Abismo): esfera blanca de cubitos que brilla fuerte, con rayos de cubitos rosa,
    violeta y dorado que salen para todos lados como una explosión. Flota sobre un pedestal del
    abismo; halo, anillo y 3 gemitas que orbitan."""

    def gema(celdas, zb):
        cz = zb + 11
        for x in range(-5, 6):
            for y in range(-5, 6):
                for z in range(cz - 5, cz + 6):
                    d = math.sqrt(x * x + y * y + (z - cz) ** 2)
                    if d <= 2.6:
                        celdas[(x, y, z)] = "Nucleo"
                    elif d <= 4.6:
                        celdas[(x, y, z)] = "Blanco" if h(x, y, z, 371) > 0.3 else "BlancoRosa"
        rayos = ["RayoRosa", "RayoVioleta", "RayoOro"]
        for i in range(18):  # direcciones repartidas en la esfera
            zz = 1 - 2 * (i + 0.5) / 18
            rr = math.sqrt(1 - zz * zz)
            a = i * 2.4
            d = (math.cos(a) * rr, math.sin(a) * rr, zz)
            largo = 8 if i % 2 else 6.5
            for k in range(5, int(largo * 2) + 1):
                s = k / 2
                c = (round(d[0] * s), round(d[1] * s), cz + round(d[2] * s))
                if max(abs(c[0]), abs(c[1])) <= 8 and c[2] >= zb - 2:
                    celdas[c] = rayos[i % 3]
        return cz + 10

    colores = {
        "Blanco": ("#FFFFFF", 0.1, "#FFF8F0", 1.2, 0.9),
        "BlancoRosa": ("#FFE0F4", 0.1, "#FFC8EC", 1.2, 0.9),
        "Nucleo": ("#FFFFFF", 0.2, "#FFFFFF", 6.0, 1),
        "RayoRosa": ("#FF5CC8", 0.1, "#FF5CC8", 1.5, 1),
        "RayoVioleta": ("#9A5CFF", 0.1, "#9A5CFF", 1.5, 1),
        "RayoOro": ("#FFD24A", 0.1, "#FFC233", 1.5, 1),
        "Halo": ("#FFC8EC", 0.1, "#FF8AD8", 0.8, 0.5),
        "Anillo": ("#F0E8FF", 0.2, "#D8C8FF", 0.4, 1),
        "Gemita1": ("#FF5CC8", 0.05, "#FF5CC8", 0.9, 1),
        "Gemita2": ("#FFD24A", 0.05, "#FFD24A", 0.9, 1),
        "Gemita3": ("#9A5CFF", 0.05, "#9A5CFF", 0.9, 1),
        "Cristalito": ("#B98CFF", 0.1, "#B98CFF", 0.5, 1),
        **ABISMO_ROCA,
    }
    return celestial(nombre, gema, colores, anillo_z=12)


def agujero_negro(nombre):
    """Celestial (Abismo): esfera negra de cubitos con un borde de luz blanca finita, rodeada por un
    disco de luz naranja y dorado (pegado a la esfera) y, por fuera, el anillo grande violeta que gira.
    Flota sobre un pedestal del abismo; halo violeta y 3 gemitas que orbitan."""

    def gema(celdas, zb):
        cz = zb + 12
        for x in range(-6, 7):
            for y in range(-6, 7):
                for z in range(cz - 6, cz + 7):
                    d = math.sqrt(x * x + y * y + (z - cz) ** 2)
                    if d <= 5.4:
                        celdas[(x, y, z)] = "Borde" if d > 4.7 and abs(y) <= 1 and abs(x) > 3 else "Negro"
        for x in range(-8, 9):  # disco de luz, un poco inclinado
            for y in range(-8, 9):
                d = math.hypot(x, y)
                if 5.6 <= d <= 8.2:
                    z = cz + round(x * 0.25)
                    celdas[(x, y, z)] = "DiscoOro" if d < 6.8 else "DiscoNaranja"
        return cz + 8

    colores = {
        "Negro": ("#040208", 0.3, None, 0.0, 1),
        "Borde": ("#2A1A40", 0.2, "#9A5CFF", 0.8, 1),
        "DiscoOro": ("#FFD24A", 0.1, "#FFC233", 2.0, 1),
        "DiscoNaranja": ("#FF7A1A", 0.1, "#FF6A10", 1.6, 1),
        "Halo": ("#9A5CFF", 0.1, "#9A5CFF", 1.0, 0.5),
        "Anillo": ("#B05CFF", 0.15, "#B05CFF", 1.5, 1),
        "Gemita1": ("#9A5CFF", 0.05, "#9A5CFF", 0.9, 1),
        "Gemita2": ("#FF7A1A", 0.05, "#FF7A1A", 0.9, 1),
        "Gemita3": ("#FFFFFF", 0.05, "#F0E8FF", 0.9, 1),
        "Cristalito": ("#B98CFF", 0.1, "#B98CFF", 0.5, 1),
        **ABISMO_ROCA,
    }
    return celestial(nombre, gema, colores, anillo_z=17)


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
    "SoldelDesierto": (2, "Legendaria", sol_del_desierto, None),
    "EscarabajodeOro": (2, "Legendaria", escarabajo_de_oro, None),
    "LagrimadeFaraon": (2, "Mitica", lagrima_de_faraon, None),
    "Espejismo": (2, "Mitica", espejismo, None),
    "CoronadelSol": (2, "Celestial", corona_del_sol, None),
    "RelojdeArenaEterno": (2, "Celestial", reloj_de_arena_eterno, None),
    "CristaldeRoca": (3, "Comun", cristal_de_roca, None),
    "PiedraEscarcha": (3, "Comun", piedra_escarcha, None),
    "Aguamarina": (3, "Rara", aguamarina, None),
    "Celestina": (3, "Rara", celestina, None),
    "Zafiro": (3, "Epica", zafiro, None),
    "PiedraLuna": (3, "Epica", piedra_luna, None),
    "CorazondeHielo": (3, "Legendaria", corazon_de_hielo, None),
    "DiamantePolar": (3, "Legendaria", diamante_polar, None),
    "AuroraBoreal": (3, "Mitica", aurora_boreal, None),
    "EstrelladeEscarcha": (3, "Mitica", estrella_de_escarcha, None),
    "CopoEterno": (3, "Celestial", copo_eterno, None),
    "TronodeHielo": (3, "Celestial", trono_de_hielo, None),
    "Obsidiana": (4, "Comun", obsidiana, None),
    "BasaltoRojo": (4, "Comun", basalto_rojo, None),
    "Granate": (4, "Rara", granate, None),
    "CristaldeAzufre": (4, "Rara", cristal_de_azufre, None),
    "Rubi": (4, "Epica", rubi, None),
    "OpalodeFuego": (4, "Epica", opalo_de_fuego, None),
    "NucleodeMagma": (4, "Legendaria", nucleo_de_magma, None),
    "PiedraFenix": (4, "Legendaria", piedra_fenix, None),
    "OjodeDragon": (4, "Mitica", ojo_de_dragon, None),
    "LlamaViva": (4, "Mitica", llama_viva, None),
    "CorazondelVolcan": (4, "Celestial", corazon_del_volcan, None),
    "CoronaIgnea": (4, "Celestial", corona_ignea, None),
    "Meteorita": (5, "Comun", meteorita, None),
    "PolvoEstelar": (5, "Comun", polvo_estelar, None),
    "Iolita": (5, "Rara", iolita, None),
    "FluoritaNocturna": (5, "Rara", fluorita_nocturna, None),
    "OpaloNegro": (5, "Epica", opalo_negro, None),
    "Alejandrita": (5, "Epica", alejandrita, None),
    "FragmentodeNebulosa": (5, "Legendaria", fragmento_de_nebulosa, None),
    "OjodelVacio": (5, "Legendaria", ojo_del_vacio, None),
    "CometaErrante": (5, "Mitica", cometa_errante, None),
    "GalaxiaEspiral": (5, "Mitica", galaxia_espiral, None),
    "Supernova": (5, "Celestial", supernova, None),
    "AgujeroNegro": (5, "Celestial", agujero_negro, None),
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
