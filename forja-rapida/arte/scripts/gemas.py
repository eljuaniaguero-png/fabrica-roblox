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
APROBADAS = {"Cuarzo"}

# Alto (studs) y tope de triángulos por rareza
RAREZAS = {
    "Comun": (1.5, 1500),
    "Rara": (2.0, 800),
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


def _grieta(bm, centro, normal, tangente, largo, semilla):
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
        esc = Matrix.Diagonal((d.length + 0.03, 0.035, 0.03, 1))
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=1)
        bmesh.ops.transform(
            tmp, matrix=Matrix.Translation((a + c) / 2 + normal * 0.004) @ rot @ esc, verts=tmp.verts
        )
        _sumar(bm, tmp)


def cuarzo(nombre):
    """Piedra en bruto: trozo irregular con 5 caras talladas que brillan, bisel claro en los bordes,
    3 tonos (claro arriba, oscuro abajo), 2 grietas, 3 cristalitos (uno transparente con un núcleo
    lila adentro) y tierra pegada en la base. Medidas libres: armar_tallada() la escala."""
    rng = random.Random(7)
    centro = Vector((0, 0, 1.25))
    puntos = []
    for _ in range(16):
        a = rng.uniform(0, 2 * math.pi)
        z = rng.uniform(-1, 1)
        r = math.sqrt(1 - z * z)
        puntos.append(Vector((1.2 * r * math.cos(a), 0.9 * r * math.sin(a), 1.2 + 0.85 * z + 0.35 * r * math.cos(a))))
    # 5 cortes planos: cada punto que se pasa del plano se aplasta sobre él -> cara grande y plana
    cortes = [
        Vector((0.15, -1, 0.55)).normalized() * 0.62,  # frente
        Vector((1, 0.2, 0.45)).normalized() * 0.70,  # costado derecho
        Vector((-0.9, 0.45, 0.6)).normalized() * 0.66,  # izquierdo de atrás
        Vector((0.1, 0.25, 1)).normalized() * 0.82,  # arriba
        Vector((-0.6, -0.7, 0.2)).normalized() * 0.72,  # frente izquierdo
    ]
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
    tonos = [
        ("Oscuro", "#9C74EA", 0.5, None, 0.0),
        ("Medio", "#D8C2FF", 0.4, None, 0.0),
        ("Claro", "#FCF8FF", 0.35, None, 0.0),
        ("Brillo", "#F3E8FF", 0.12, "#B98CFF", 0.45),
    ]
    for i, (sufijo, color, rug, br, fu) in enumerate(tonos):
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
    objetos.append(_objeto(f"{nombre}_Grieta", bm, "#6B3FC4", 0.6))

    # cristalitos asomando: 2 lila fuerte y 1 transparente con un núcleo que brilla adentro
    def punto_en(direccion):
        d = direccion.normalized()
        mejor = max(puntos, key=lambda p: (p - centro).normalized().dot(d))
        return mejor.lerp(centro, 0.25), d

    bm = bmesh.new()
    for direccion, radio, largo, giro in (
        (Vector((0.9, -0.7, 0.55)), 0.16, 0.5, 0.3),
        (Vector((0.5, -1, 0.25)), 0.12, 0.36, 0.9),
    ):
        base, d = punto_en(direccion)
        _cristalito(bm, base, d, radio, largo, giro)
    objetos.append(_objeto(f"{nombre}_Cristal", bm, "#A06BFF", 0.2, "#8A4DFF", 0.4))
    base, d = punto_en(Vector((0.7, 0.05, 1)))
    bm = bmesh.new()
    _cristalito(bm, base, d, 0.17, 0.55, 0.0)
    objetos.append(_objeto(f"{nombre}_Vidrio", bm, "#EBDDFF", 0.05, alfa=0.45))
    bm = bmesh.new()
    _cristalito(bm, base + d * 0.12, d, 0.07, 0.3, 0.5)
    objetos.append(_objeto(f"{nombre}_Nucleo", bm, "#C77DFF", 0.2, "#C77DFF", 2.0))

    # tierra pegada en la base y 3 piedritas oscuras
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
    objetos.append(_objeto(f"{nombre}_Piedrita", bm, "#6E4128", 0.8))
    return objetos


def jaspe():
    # canto rodado ancho y bajo, rojo ladrillo con 2 vetas crema que lo cruzan
    celdas = {}
    for z in range(4):
        for x in range(-3, 4):
            for y in range(-2, 3):
                if (x / 3.6) ** 2 + (y / 2.6) ** 2 + ((z - 1.2) / 2.6) ** 2 <= 1:
                    celdas[(x, y, z)] = "piedra"
    for c in list(celdas):
        x, y, z = c
        if x - z in (-2, 2):
            celdas[c] = "veta"
    for c in list(celdas):
        x, y, z = c
        if z == 3 and abs(x) <= 1 and celdas[c] == "piedra":
            celdas[c] = "brillo"
    return celdas


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
        {"piedra": ("#B23A26", 0.0), "veta": ("#F3DDB5", 0.0), "brillo": ("#E8664D", 0.35)},
    ),
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
        alto = RAREZAS[PIEDRAS[nombre][1]][0] * m.STUD
        for j, giro in enumerate((0.0, math.radians(90))):
            objetos, t, _ = armar(nombre)
            m.mover(objetos, x0 + (j - 0.5) * ancho, giro=giro)
            for o in objetos:
                o.location.z += alto / 2
        m.etiqueta(f"{nombre} ({t} tri)", x0, -0.6, tam=0.12)
    m.camara(escena, (0, 0, 0.25), 3.2 * max(1, len(nombres) * 0.8), 0.9, lente=50, giro=0)
    m.render("gema_" + "_".join(nombres))


def icono(nombre):
    m.limpiar_escena()
    escena = escena_render_gema(transparente=True, cuadrado=True)
    objetos, _, _ = armar(nombre)
    alto = RAREZAS[PIEDRAS[nombre][1]][0] * m.STUD
    m.camara(escena, (0, 0, 0), alto * 2.6, alto * 0.7, lente=50, giro=-30)
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
        _, t, _ = armar(n)
        print(f"  {n}: {t} triángulos")
    if "--icono" in args:
        for n in nombres:
            icono(n)
    if "--exportar" in args:
        for z in sorted({PIEDRAS[n][0] for n in nombres}):
            exportar_zona(z)
    if "--icono" not in args and "--exportar" not in args:
        render_piedras(nombres)
    print("Listo")
