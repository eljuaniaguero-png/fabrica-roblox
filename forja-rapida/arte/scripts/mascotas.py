"""Las 8 mascotas de Forja Rápida (GameConfig.Mascotas), en vóxel fino y animadas.

Cada pieza (cuerpo, cabeza, patas, cola, alas...) se diseña con formas suaves (elipsoides,
cápsulas, cajas y octaedros, con su color y brillo) y después se "voxeliza": se rellena con
cubitos de GRILLA studs y solo se arman las caras que se ven. Así quedan redondeadas pero
siguen el estilo vóxel del juego. La forma que va más abajo en la lista pisa el color de las
anteriores (ojos sobre la cara, manchas sobre el lomo).

Cada pieza tiene su pivote en la articulación y la animación solo gira o mueve piezas enteras
(como un Motor6D en Roblox). Una acción en bucle por mascota: 32 cuadros a 24 fps.

Exporta a forja-rapida/arte/:
  glb/Mascota_<Id>.glb   con la animación (visor)
  fbx/Mascota_<Id>.fbx   con la animación (Studio)
  renders/Mascota_<Id>.png
  blend/Mascotas.blend   las 8 en fila, para abrir en Blender

Correrlo desde la raíz del repositorio (no toca la escena abierta en Blender):
  blender --background --factory-startup --python forja-rapida/arte/scripts/mascotas.py
  Agregar "-- --sin-renders" para no hacer las imágenes.

Escala: medidas en studs (1 stud = 0,28 m). Pivote en la base, frente hacia -Y de Blender.
"""

import math
import sys
from pathlib import Path

import bpy

from mathutils import Vector

ARTE = Path(__file__).resolve().parents[1]
GLB = ARTE / "glb"
FBX = ARTE / "fbx"
RENDERS = ARTE / "renders"
BLEND = ARTE / "blend"
STUD = 0.28
GRILLA = 0.15  # studs por cubito
CUADROS = 32
FPS = 24

NEGRO = "#15131C"
BLANCO = "#FFFFFF"

# ---------------------------------------------------------------------------------------------
# Formas (todas en studs, coordenadas del mundo). Devuelven (adentro(x, y, z), color, brillo).


def elip(cx, cy, cz, rx, ry, rz, color, brillo=0.0, zmin=None):
    def f(x, y, z):
        if zmin is not None and z < zmin:
            return False
        return ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 + ((z - cz) / rz) ** 2 <= 1

    return (f, color, brillo, (cx - rx, cy - ry, cz - rz, cx + rx, cy + ry, cz + rz))


def caja(cx, cy, cz, sx, sy, sz, color, brillo=0.0):
    def f(x, y, z):
        return abs(x - cx) <= sx and abs(y - cy) <= sy and abs(z - cz) <= sz

    return (f, color, brillo, (cx - sx, cy - sy, cz - sz, cx + sx, cy + sy, cz + sz))


def caps(a, b, r0, color, brillo=0.0, r1=None):
    """Cápsula (o cono redondeado si r1) de a a b."""
    r1 = r0 if r1 is None else r1
    a, b = Vector(a), Vector(b)
    ab = b - a
    largo2 = max(ab.length_squared, 1e-9)

    def f(x, y, z):
        p = Vector((x, y, z))
        t = max(0.0, min(1.0, (p - a).dot(ab) / largo2))
        r = r0 + (r1 - r0) * t
        return (p - (a + ab * t)).length <= r

    rm = max(r0, r1)
    lo = [min(a[i], b[i]) - rm for i in range(3)]
    hi = [max(a[i], b[i]) + rm for i in range(3)]
    return (f, color, brillo, (*lo, *hi))


def octa(cx, cy, cz, rx, ry, rz, color, brillo=0.0):
    def f(x, y, z):
        return abs(x - cx) / rx + abs(y - cy) / ry + abs(z - cz) / rz <= 1

    return (f, color, brillo, (cx - rx, cy - ry, cz - rz, cx + rx, cy + ry, cz + rz))


def espejo(forma_fn, *args, **kw):
    """Lista con la forma en x y en -x (args[0] es x)."""
    return [forma_fn(*args, **kw), forma_fn(-args[0], *args[1:], **kw)]


def espejo_caps(a, b, r0, color, brillo=0.0, r1=None):
    return [caps(a, b, r0, color, brillo, r1),
            caps((-a[0], a[1], a[2]), (-b[0], b[1], b[2]), r0, color, brillo, r1)]


# ---------------------------------------------------------------------------------------------
# Materiales y voxelizado

_materiales = {}


def hex_a_rgb(h):
    h = h.lstrip("#")
    return tuple(((int(h[i : i + 2], 16) / 255) ** 2.2) for i in (0, 2, 4))


def material(color, brillo=0.0):
    clave = (color, brillo)
    if clave in _materiales:
        return _materiales[clave]
    m = bpy.data.materials.new(f"M_{color.lstrip('#')}{'_brillo' if brillo else ''}")
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    rgb = (*hex_a_rgb(color), 1)
    bsdf.inputs["Base Color"].default_value = rgb
    bsdf.inputs["Roughness"].default_value = 0.55
    if brillo:
        bsdf.inputs["Emission Color"].default_value = rgb
        bsdf.inputs["Emission Strength"].default_value = min(brillo, 1.0) * 0.6  # más fuerte se ve blanco
    _materiales[clave] = m
    return m


CARAS = [
    ((1, 0, 0), [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)]),
    ((-1, 0, 0), [(0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0)]),
    ((0, 1, 0), [(0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0)]),
    ((0, -1, 0), [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)]),
    ((0, 0, 1), [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)]),
    ((0, 0, -1), [(0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0)]),
]


def pieza(nombre, padre, pivote, formas):
    """Voxeliza las formas (en studs, mundo) en una malla con origen en `pivote`."""
    lo = [min(f[3][i] for f in formas) for i in range(3)]
    hi = [max(f[3][i + 3] for f in formas) for i in range(3)]
    i0 = [math.floor(lo[k] / GRILLA) for k in range(3)]
    i1 = [math.ceil(hi[k] / GRILLA) for k in range(3)]
    celdas = {}
    for i in range(i0[0], i1[0] + 1):
        x = (i + 0.5) * GRILLA
        for j in range(i0[1], i1[1] + 1):
            y = (j + 0.5) * GRILLA
            for k in range(i0[2], i1[2] + 1):
                z = (k + 0.5) * GRILLA
                if z < 0:
                    continue
                elegido = None
                for f, color, brillo, _ in formas:
                    if f(x, y, z):
                        elegido = (color, brillo)
                if elegido:
                    celdas[(i, j, k)] = elegido
    verts, caras, mats_cara, mats = [], [], [], []
    px, py, pz = (p / GRILLA for p in pivote)
    for (i, j, k), clave in celdas.items():
        for (dx, dy, dz), esquinas in CARAS:
            if (i + dx, j + dy, k + dz) in celdas:
                continue
            base = len(verts)
            for ex, ey, ez in esquinas:
                verts.append(((i + ex - px) * GRILLA * STUD, (j + ey - py) * GRILLA * STUD,
                              (k + ez - pz) * GRILLA * STUD))
            caras.append((base, base + 1, base + 2, base + 3))
            if clave not in mats:
                mats.append(clave)
            mats_cara.append(mats.index(clave))
    malla = bpy.data.meshes.new(nombre)
    malla.from_pydata(verts, [], caras)
    for color, brillo in mats:
        malla.materials.append(material(color, brillo))
    for cara, m in zip(malla.polygons, mats_cara):
        cara.material_index = m
    malla.update()
    obj = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(obj)
    if padre:
        obj.parent = padre
        obj.location = (Vector(pivote) - padre_mundo(padre)) * STUD
    else:
        obj.location = Vector(pivote) * STUD
    obj["pivote"] = list(pivote)
    # junta vértices repetidos (menos peso y sombreado prolijo)
    import bmesh

    bm = bmesh.new()
    bm.from_mesh(malla)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)
    bm.to_mesh(malla)
    bm.free()
    return obj


def padre_mundo(obj):
    p = obj.get("pivote")
    return Vector(p) if p is not None else Vector((0, 0, 0))


def raiz(nombre):
    vacio = bpy.data.objects.new(f"Mascota_{nombre}", None)
    bpy.context.scene.collection.objects.link(vacio)
    vacio["pivote"] = [0, 0, 0]
    rebote = bpy.data.objects.new(f"{nombre}_Rebote", None)
    bpy.context.scene.collection.objects.link(rebote)
    rebote.parent = vacio
    rebote["pivote"] = [0, 0, 0]
    return vacio, rebote


# ---------------------------------------------------------------------------------------------
# Animación (bucle: el primer y el último cuadro coinciden)


def onda(obj, canal, eje, amplitud, fase=0.0, veces=1):
    datos = getattr(obj, canal)
    inicio = datos[eje]
    for f in range(0, CUADROS + 1, 2):
        t = f / CUADROS
        datos[eje] = inicio + amplitud * math.sin(2 * math.pi * (t * veces + fase))
        obj.keyframe_insert(canal, index=eje, frame=f + 1)
    datos[eje] = inicio


def salto(obj, alto, veces=2):
    z = obj.location.z
    for f in range(0, CUADROS + 1, 2):
        t = f / CUADROS
        obj.location.z = z + alto * STUD * abs(math.sin(math.pi * t * veces))
        obj.keyframe_insert("location", index=2, frame=f + 1)
    obj.location.z = z


def vuelta(obj, eje=2):
    for f in range(0, CUADROS + 1, 2):
        obj.rotation_euler[eje] = 2 * math.pi * f / CUADROS
        obj.keyframe_insert("rotation_euler", index=eje, frame=f + 1)
    obj.rotation_euler[eje] = 0


def caminar(patas, grados=28):
    for i, p in enumerate(patas):
        onda(p, "rotation_euler", 0, math.radians(grados), fase=0.5 * (i % 2))


def ojos(x, y, z, r, color=NEGRO, brillo=0.0, reflejo=True):
    """Par de ojos mirando a -Y con su puntito de brillo."""
    formas = espejo(elip, x, y, z, max(r, GRILLA * 0.8), max(r * 0.6, GRILLA), r * 1.15, color, brillo)
    if reflejo and r >= 0.14:  # en ojos chicos el brillo tapaba la pupila
        formas += espejo(caja, x - r * 0.35, y - r * 0.55, z + r * 0.4, GRILLA * 0.5, GRILLA * 0.5,
                         GRILLA * 0.5, BLANCO, 1.5)
    return formas


# ---------------------------------------------------------------------------------------------
# Las 8 mascotas


def cavadin():
    """Topo minero (Común): casco amarillo con linterna, hocico rosa y garras grandes."""
    marron, rosa, claro = "#8A5A2B", "#FFB3C7", "#B98552"
    casco, luz = "#FFCF3F", "#FFF6C8"
    v, r = raiz("Cavadin")
    pieza("Cavadin_Cuerpo", r, (0, 0, 1.0), [
        elip(0, 0.3, 1.15, 1.25, 1.55, 1.1, marron),
        elip(0, -0.55, 0.95, 0.85, 0.75, 0.8, claro),
        elip(0, 1.1, 1.6, 0.5, 0.4, 0.3, claro),  # mancha del lomo
    ])
    cab = pieza("Cavadin_Cabeza", r, (0, -0.9, 1.6), [
        elip(0, -1.45, 1.75, 0.95, 0.85, 0.85, marron),
        elip(0, -2.2, 1.5, 0.45, 0.5, 0.38, rosa),
        elip(0, -2.65, 1.62, 0.2, 0.16, 0.18, "#E0507A"),
        *ojos(0.42, -2.12, 2.0, 0.13),
        *espejo(elip, 0.62, -1.95, 1.55, 0.22, 0.15, 0.13, "#FF8FB0"),  # cachetes
        elip(0, -1.35, 2.45, 0.95, 0.9, 0.55, casco, zmin=2.15),
        caja(0, -1.35, 2.18, 1.02, 0.97, 0.06, "#E0A800"),  # ala del casco
        caja(0, -2.15, 2.42, 0.26, 0.05, 0.23, "#8D939C"),
        caja(0, -2.25, 2.42, 0.18, 0.08, 0.15, luz, 4.0),
    ])
    garras = []
    for s in (1, -1):
        garras.append(pieza(f"Cavadin_Garra{len(garras) + 1}", r, (s * 0.95, -0.95, 0.8), [
            elip(s * 1.0, -1.3, 0.42, 0.38, 0.5, 0.3, rosa),
            *[caps((s * (0.85 + d), -1.7, 0.35), (s * (0.85 + d), -1.95, 0.2), 0.08, BLANCO)
              for d in (0.0, 0.17, 0.34)],
        ]))
    patas = [pieza(f"Cavadin_Pata{i + 1}", v, (s * 0.8, 1.2, 0.55), [
        elip(s * 0.85, 1.35, 0.32, 0.42, 0.55, 0.32, marron)]) for i, s in enumerate((1, -1))]
    cola = pieza("Cavadin_Cola", r, (0, 1.75, 0.95), [caps((0, 1.75, 0.95), (0, 2.35, 1.3), 0.14, rosa)])
    salto(r, 0.12)
    caminar(garras + patas, 22)
    onda(cab, "rotation_euler", 2, math.radians(10), fase=0.25)
    onda(cola, "rotation_euler", 2, math.radians(30), veces=2)
    return v


def pedrusco():
    """Gólem de piedra (Común): cristales celestes que brillan, musgo en los hombros."""
    gris, oscuro, cristal, musgo = "#8D939C", "#6B717A", "#7CF5FF", "#5E8C4A"
    v, r = raiz("Pedrusco")
    pieza("Pedrusco_Torso", r, (0, 0, 1.5), [
        caja(0, 0, 2.25, 1.15, 0.8, 0.85, gris),
        caja(0, 0, 1.55, 0.85, 0.65, 0.25, oscuro),
        caja(0.45, -0.81, 2.6, 0.25, 0.04, 0.12, oscuro),  # grietas
        caja(-0.35, -0.81, 2.0, 0.2, 0.04, 0.1, oscuro),
        caps((0.3, -0.7, 2.4), (0.55, -0.95, 2.85), 0.15, cristal, 2.5),
        caps((0, 0.6, 2.8), (0, 0.95, 3.6), 0.2, cristal, 2.5),
        caps((0.4, 0.6, 2.7), (0.6, 0.9, 3.3), 0.15, cristal, 2.5),
        caps((-0.4, 0.6, 2.7), (-0.65, 0.95, 3.25), 0.15, cristal, 2.5),
        *espejo(elip, 1.05, 0, 3.12, 0.4, 0.45, 0.18, musgo),
    ])
    cab = pieza("Pedrusco_Cabeza", r, (0, 0, 3.1), [
        caja(0, -0.1, 3.55, 0.62, 0.55, 0.48, gris),
        caja(0, -0.62, 3.83, 0.66, 0.1, 0.12, oscuro),
        *espejo(caja, 0.28, -0.67, 3.55, 0.15, 0.04, 0.09, cristal, 4.0),
        caps((0.2, 0, 4.0), (0.35, 0.1, 4.55), 0.13, cristal, 2.5),
        caps((-0.15, 0.05, 4.0), (-0.3, 0.15, 4.35), 0.1, cristal, 2.5),
    ])
    brazos = []
    for s in (1, -1):
        brazos.append(pieza(f"Pedrusco_Brazo{len(brazos) + 1}", r, (s * 1.3, 0, 2.85), [
            caps((s * 1.4, 0, 2.8), (s * 1.5, -0.1, 1.7), 0.38, gris),
            caja(s * 1.5, -0.1, 1.35, 0.42, 0.42, 0.35, gris),
            caja(s * 1.5, -0.1, 1.05, 0.38, 0.38, 0.06, oscuro),
        ]))
    piernas = [pieza(f"Pedrusco_Pierna{i + 1}", v, (s * 0.55, 0, 1.4), [
        caja(s * 0.55, 0, 0.7, 0.38, 0.42, 0.7, gris),
        caja(s * 0.55, -0.1, 0.1, 0.42, 0.5, 0.1, oscuro)]) for i, s in enumerate((1, -1))]
    salto(r, 0.15)
    for i, b in enumerate(brazos):
        onda(b, "rotation_euler", 0, math.radians(30), fase=0.5 * i)
    for i, p in enumerate(piernas):
        onda(p, "rotation_euler", 0, math.radians(20), fase=0.5 * (1 - i))
    onda(cab, "rotation_euler", 2, math.radians(10), fase=0.25)
    return v


def brasita():
    """Zorrito de fuego (Rara): cola terminada en llama, orejas grandes."""
    nar, crema, oscuro, llama = "#FF8C42", "#FFF3E0", "#5A2A10", "#FFCF3F"
    v, r = raiz("Brasita")
    pieza("Brasita_Cuerpo", r, (0, 0, 1.25), [
        elip(0, 0.2, 1.35, 0.72, 1.25, 0.68, nar),
        elip(0, -0.75, 1.25, 0.5, 0.45, 0.55, crema),
    ])
    cab = pieza("Brasita_Cabeza", r, (0, -0.95, 1.8), [
        elip(0, -1.3, 2.25, 0.75, 0.65, 0.65, nar),
        *espejo(elip, 0.45, -1.55, 2.02, 0.36, 0.3, 0.3, crema),
        elip(0, -1.95, 2.05, 0.3, 0.42, 0.25, crema),
        elip(0, -2.33, 2.15, 0.12, 0.1, 0.1, NEGRO),
        *ojos(0.3, -1.85, 2.4, 0.14),
        *espejo_caps((0.45, -1.15, 2.7), (0.65, -1.1, 3.4), 0.25, nar, 0.0, 0.06),
        *espejo_caps((0.45, -1.32, 2.75), (0.6, -1.3, 3.2), 0.12, oscuro, 0.0, 0.04),
    ])
    patas = []
    for i, (sx, y) in enumerate([(1, -0.6), (-1, 0.95), (-1, -0.6), (1, 0.95)]):
        patas.append(pieza(f"Brasita_Pata{i + 1}", v, (sx * 0.4, y, 1.0), [
            caps((sx * 0.4, y, 1.0), (sx * 0.4, y, 0.2), 0.17, nar),
            elip(sx * 0.4, y - 0.05, 0.12, 0.2, 0.24, 0.12, oscuro)]))
    cola = pieza("Brasita_Cola", r, (0, 1.35, 1.55), [
        caps((0, 1.35, 1.55), (0, 2.15, 2.1), 0.3, nar, 0.0, 0.45),
        elip(0, 2.45, 2.45, 0.42, 0.42, 0.45, llama, 2.0),
        caps((0, 2.45, 2.6), (0, 2.6, 3.25), 0.3, "#FF6A1F", 2.5, 0.05),
        caps((0.15, 2.3, 2.6), (0.25, 2.35, 3.0), 0.15, llama, 2.5, 0.04),
    ])
    salto(r, 0.18)
    caminar(patas)
    onda(cab, "rotation_euler", 0, math.radians(6), veces=2)
    onda(cab, "rotation_euler", 2, math.radians(8), fase=0.25)
    onda(cola, "rotation_euler", 2, math.radians(30), veces=2)
    return v


def jadeita():
    """Tortuga con caparazón de jade y cristalitos verdes (Rara)."""
    verde, cap, borde, panza, jade = "#5E8C4A", "#B07A4A", "#7A5233", "#D9C27A", "#4DFFB0"
    v, r = raiz("Jadeita")
    pieza("Jadeita_Caparazon", r, (0, 0, 0.55), [
        elip(0, 0, 0.6, 1.3, 1.5, 0.28, panza),
        elip(0, 0, 0.8, 1.42, 1.62, 0.95, borde, zmin=0.65),
        elip(0, 0, 0.82, 1.3, 1.5, 0.98, cap, zmin=0.78),
        *[elip(x, y, 1.62, 0.32, 0.32, 0.12, borde) for x, y in ((0, 0), (0.6, 0.55), (-0.6, 0.55), (0.6, -0.5), (-0.6, -0.5))],
        octa(0, 0.1, 1.95, 0.22, 0.22, 0.45, jade, 2.0),
        octa(0.55, 0.6, 1.75, 0.15, 0.15, 0.3, jade, 2.0),
        octa(-0.5, -0.45, 1.75, 0.15, 0.15, 0.32, jade, 2.0),
    ])
    cab = pieza("Jadeita_Cabeza", r, (0, -1.3, 0.8), [
        caps((0, -1.3, 0.8), (0, -1.75, 0.95), 0.3, verde),
        elip(0, -2.0, 1.05, 0.5, 0.55, 0.45, verde),
        *ojos(0.27, -2.42, 1.2, 0.12),
        caja(0, -2.52, 0.92, 0.18, 0.04, 0.03, "#2E4A22"),
    ])
    patas = []
    for i, (sx, y) in enumerate([(1, -0.9), (-1, 0.9), (-1, -0.9), (1, 0.9)]):
        patas.append(pieza(f"Jadeita_Pata{i + 1}", v, (sx * 1.0, y, 0.6), [
            elip(sx * 1.15, y, 0.35, 0.38, 0.4, 0.35, verde)]))
    cola = pieza("Jadeita_Cola", r, (0, 1.4, 0.6), [caps((0, 1.4, 0.6), (0, 1.85, 0.45), 0.15, verde, 0.0, 0.06)])
    salto(r, 0.08)
    caminar(patas, 18)
    onda(cab, "location", 1, -0.18 * STUD)
    onda(cab, "rotation_euler", 2, math.radians(10), fase=0.25)
    onda(cola, "rotation_euler", 2, math.radians(25), veces=2)
    return v


def prismo():
    """Cristal vivo que flota (Épica): carita, corona de puntas y 3 esquirlas en órbita."""
    violeta, blanco, claro = "#C77DFF", BLANCO, "#E9C8FF"
    v, r = raiz("Prismo")
    r.location.z = 0.6 * STUD
    r["pivote"] = [0, 0, 0.6]
    cuerpo = pieza("Prismo_Cuerpo", r, (0, 0, 2.2), [
        octa(0, 0, 2.2, 1.0, 1.0, 1.55, violeta, 0.6),
        octa(0, 0, 2.2, 0.55, 0.55, 1.05, claro, 1.0),
        *ojos(0.33, -0.62, 2.35, 0.17),
        caja(0, -0.6, 1.95, 0.12, 0.08, 0.04, "#6E22D6"),
        caps((0, 0, 3.4), (0, 0, 4.1), 0.18, blanco, 2.0, 0.04),
        caps((0.35, 0, 3.2), (0.6, 0, 3.75), 0.13, violeta, 1.0, 0.03),
        caps((-0.35, 0, 3.2), (-0.6, 0, 3.75), 0.13, violeta, 1.0, 0.03),
    ])
    orbita = pieza("Prismo_Orbita", r, (0, 0, 2.2), [
        octa(1.6, 0, 2.4, 0.22, 0.22, 0.38, blanco, 2.0),
        octa(-0.8, 1.4, 2.0, 0.18, 0.18, 0.32, violeta, 1.5),
        octa(-0.8, -1.4, 2.6, 0.18, 0.18, 0.32, violeta, 1.5),
    ])
    sombra = pieza("Prismo_Sombra", v, (0, 0, 0), [elip(0, 0, 0.02, 0.9, 0.9, 0.06, "#3A2A55")])
    onda(r, "location", 2, 0.25 * STUD)
    onda(cuerpo, "rotation_euler", 2, math.radians(14))
    vuelta(orbita)
    for f in range(0, CUADROS + 1, 2):
        s = 1 - 0.15 * math.sin(2 * math.pi * f / CUADROS)
        sombra.scale = (s, s, 1)
        sombra.keyframe_insert("scale", frame=f + 1)
    return v


def escarchin():
    """Pingüino de hielo (Épica): bufanda, corona de cristales de hielo."""
    azul, blanco, nar, bufanda, hielo = "#2F5D8A", "#E8F4FF", "#FFA51F", "#E0336E", "#9EEBFF"
    v, r = raiz("Escarchin")
    pieza("Escarchin_Cuerpo", r, (0, 0, 0.3), [
        elip(0, 0, 1.25, 0.85, 0.75, 1.05, azul),
        elip(0, -0.35, 1.15, 0.62, 0.5, 0.85, blanco),
        elip(0, 0, 2.0, 0.78, 0.7, 0.18, bufanda),
        caps((0.35, -0.55, 2.0), (0.5, -0.75, 1.3), 0.14, bufanda),
        caja(0.5, -0.76, 1.32, 0.13, 0.08, 0.05, "#FFE14D"),
    ])
    cab = pieza("Escarchin_Cabeza", r, (0, 0, 2.05), [
        elip(0, 0, 2.6, 0.72, 0.66, 0.6, azul),
        elip(0, -0.35, 2.55, 0.52, 0.4, 0.42, blanco),
        *ojos(0.25, -0.68, 2.68, 0.13),
        caps((0, -0.6, 2.45), (0, -1.0, 2.38), 0.15, nar, 0.0, 0.05),
        *[octa(x, 0.05, 3.25 + h, 0.12, 0.12, 0.25 + h, hielo, 1.5) for x, h in ((0, 0.12), (0.3, 0), (-0.3, 0))],
    ])
    aletas = []
    for s in (1, -1):
        aletas.append(pieza(f"Escarchin_Aleta{len(aletas) + 1}", r, (s * 0.8, 0, 1.85), [
            caps((s * 0.85, 0, 1.75), (s * 1.1, -0.05, 0.95), 0.2, azul, 0.0, 0.12)]))
    pies = [pieza(f"Escarchin_Pie{i + 1}", v, (s * 0.35, -0.2, 0.3), [
        elip(s * 0.35, -0.35, 0.12, 0.25, 0.35, 0.12, nar)]) for i, s in enumerate((1, -1))]
    salto(r, 0.15)
    onda(r, "rotation_euler", 1, math.radians(7))
    for i, a in enumerate(aletas):
        onda(a, "rotation_euler", 1, math.radians(28) * (1 if i else -1), veces=2)
    for i, p in enumerate(pies):
        onda(p, "rotation_euler", 0, math.radians(15), fase=0.5 * i)
    onda(cab, "rotation_euler", 0, math.radians(5), veces=2)
    return v


def fraguon():
    """Dragoncito de la fragua (Legendaria): alas, cuernos, púas y cola con brasa."""
    rojo, oro, oscuro, ala = "#FF3B1F", "#FFE14D", "#8A1A0E", "#B3261A"
    v, r = raiz("Fraguon")
    pieza("Fraguon_Cuerpo", r, (0, 0, 1.4), [
        elip(0, 0.2, 1.5, 0.88, 1.35, 0.85, rojo),
        elip(0, -0.55, 1.3, 0.6, 0.75, 0.6, oro),
        *[caps((0, y, 2.2), (0, y + 0.15, 2.65), 0.15, oro, 0.0, 0.03) for y in (-0.3, 0.3, 0.9)],
    ])
    cab = pieza("Fraguon_Cabeza", r, (0, -0.9, 2.0), [
        caps((0, -0.9, 2.0), (0, -1.35, 2.6), 0.42, rojo),
        elip(0, -1.6, 2.85, 0.62, 0.72, 0.55, rojo),
        elip(0, -2.2, 2.68, 0.4, 0.45, 0.3, rojo),
        elip(0, -2.2, 2.52, 0.32, 0.4, 0.12, oro),
        *espejo(caja, 0.15, -2.62, 2.78, 0.06, 0.04, 0.05, "#FF6A1F", 4.0),
        *ojos(0.33, -2.0, 3.05, 0.15, oro, 2.5),
        *espejo_caps((0.35, -1.4, 3.25), (0.55, -0.95, 3.85), 0.15, oro, 0.0, 0.04),
        *espejo_caps((0.6, -1.55, 2.95), (0.9, -1.35, 3.15), 0.08, oro, 0.0, 0.03),
    ])
    alas = []
    for s in (1, -1):
        alas.append(pieza(f"Fraguon_Ala{len(alas) + 1}", r, (s * 0.7, 0, 2.2), [
            caps((s * 0.7, 0, 2.2), (s * 2.3, 0.2, 3.0), 0.12, rojo),
            caps((s * 2.3, 0.2, 3.0), (s * 2.7, 0.5, 2.2), 0.09, rojo),
            elip(s * 1.75, 0.35, 2.45, 0.95, 0.5, 0.13, ala),
            elip(s * 2.3, 0.5, 2.35, 0.45, 0.35, 0.12, ala),
        ]))
    patas = []
    for i, (sx, y) in enumerate([(1, -0.5), (-1, 1.0), (-1, -0.5), (1, 1.0)]):
        patas.append(pieza(f"Fraguon_Pata{i + 1}", v, (sx * 0.55, y, 1.0), [
            caps((sx * 0.55, y, 1.0), (sx * 0.6, y, 0.2), 0.22, rojo),
            elip(sx * 0.6, y - 0.1, 0.13, 0.26, 0.3, 0.13, oscuro)]))
    cola = pieza("Fraguon_Cola", r, (0, 1.4, 1.35), [
        caps((0, 1.4, 1.35), (0, 2.8, 0.8), 0.38, rojo, 0.0, 0.12),
        octa(0, 3.05, 0.75, 0.3, 0.35, 0.3, "#FF6A1F", 3.0),
    ])
    salto(r, 0.15)
    caminar(patas)
    for i, a in enumerate(alas):
        onda(a, "rotation_euler", 1, math.radians(32) * (1 if i else -1), veces=2)
    onda(cab, "rotation_euler", 0, math.radians(6), veces=2)
    onda(cola, "rotation_euler", 2, math.radians(25), veces=2)
    return v


def astralis():
    """Gato cósmico (Mítica): pelaje de noche con estrellas, ojos celestes y cola de cometa."""
    noche, hocico, celeste, estrella = "#4B2A6B", "#7B5A9E", "#7CF5FF", "#FFE14D"
    v, r = raiz("Astralis")
    pieza("Astralis_Cuerpo", r, (0, 0, 1.2), [
        elip(0, 0.2, 1.3, 0.7, 1.25, 0.65, noche),
        elip(0, -0.7, 1.15, 0.45, 0.4, 0.5, hocico),
        *[elip(x, y, z, 0.1, 0.1, 0.1, c, 3.0) for x, y, z, c in (
            (0.3, 0.2, 1.92, celeste), (-0.25, 0.75, 1.85, estrella), (0.1, 1.1, 1.75, celeste),
            (-0.4, -0.2, 1.8, BLANCO), (0.55, 0.9, 1.5, estrella))],
    ])
    cab = pieza("Astralis_Cabeza", r, (0, -0.9, 1.7), [
        elip(0, -1.2, 2.15, 0.78, 0.66, 0.62, noche),
        elip(0, -1.75, 1.98, 0.38, 0.3, 0.26, hocico),
        elip(0, -2.02, 2.07, 0.09, 0.07, 0.07, "#FF8FB0"),
        *espejo(elip, 0.32, -1.72, 2.3, 0.2, 0.12, 0.22, celeste, 3.0),
        *espejo(caja, 0.32, -1.86, 2.3, 0.05, 0.03, 0.15, NEGRO),
        octa(0, -1.75, 2.62, 0.13, 0.05, 0.13, estrella, 3.0),
        *espejo_caps((0.45, -1.05, 2.6), (0.6, -1.0, 3.25), 0.27, noche, 0.0, 0.05),
        *espejo_caps((0.45, -1.22, 2.65), (0.56, -1.2, 3.05), 0.12, celeste, 2.0, 0.03),
        *[caps((s * 0.45, -1.85, 1.95), (s * 0.95, -1.95, 2.05), 0.025, BLANCO) for s in (1, -1)],
    ])
    patas = []
    for i, (sx, y) in enumerate([(1, -0.55), (-1, 0.95), (-1, -0.55), (1, 0.95)]):
        patas.append(pieza(f"Astralis_Pata{i + 1}", v, (sx * 0.38, y, 0.95), [
            caps((sx * 0.38, y, 0.95), (sx * 0.38, y, 0.18), 0.16, noche),
            elip(sx * 0.38, y - 0.05, 0.12, 0.19, 0.23, 0.12, hocico)]))
    cola = pieza("Astralis_Cola", r, (0, 1.35, 1.45), [
        caps((0, 1.35, 1.45), (0, 2.0, 2.15), 0.16, noche),
        caps((0, 2.0, 2.15), (0, 1.85, 2.85), 0.15, noche),
        elip(0, 1.85, 2.95, 0.25, 0.25, 0.25, celeste, 3.0),
        caps((0, 1.9, 3.0), (0, 2.5, 3.2), 0.18, celeste, 1.5, 0.03),
    ])
    salto(r, 0.18)
    caminar(patas)
    onda(cab, "rotation_euler", 2, math.radians(9), fase=0.25)
    onda(cola, "rotation_euler", 1, math.radians(18), veces=2)
    return v


# Id del juego (no cambia, es lo que está guardado), nombre nuevo y armado
MASCOTAS = [
    ("Topito", "Cavadin", cavadin),
    ("Piedrin", "Pedrusco", pedrusco),
    ("Chispa", "Brasita", brasita),
    ("Musgo", "Jadeita", jadeita),
    ("Cuarcito", "Prismo", prismo),
    ("Glaciel", "Escarchin", escarchin),
    ("Magmo", "Fraguon", fraguon),
    ("Nebula", "Astralis", astralis),
]


# ---------------------------------------------------------------------------------------------


def limpiar():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _materiales.clear()
    escena = bpy.context.scene
    escena.render.fps = FPS
    escena.frame_start = 1
    escena.frame_end = CUADROS


def lineal(vacio):
    for obj in [vacio, *vacio.children_recursive]:
        ad = obj.animation_data
        if not (ad and ad.action):
            continue
        curvas = list(getattr(ad.action, "fcurves", []))
        for capa in getattr(ad.action, "layers", []):
            for tira in capa.strips:
                for bolsa in tira.channelbags:
                    curvas += list(bolsa.fcurves)
        for curva in curvas:
            for k in curva.keyframe_points:
                k.interpolation = "LINEAR"


def seleccionar(vacio):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in [vacio, *vacio.children_recursive]:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = vacio


def exportar(id_juego, vacio):
    seleccionar(vacio)
    bpy.ops.export_scene.gltf(filepath=str(GLB / f"Mascota_{id_juego}.glb"), export_format="GLB",
                              use_selection=True, export_animations=True,
                              export_animation_mode="SCENE", export_force_sampling=True)
    seleccionar(vacio)
    bpy.ops.export_scene.fbx(filepath=str(FBX / f"Mascota_{id_juego}.fbx"), use_selection=True,
                             object_types={"EMPTY", "MESH"}, bake_anim=True,
                             bake_anim_use_all_actions=False, bake_anim_use_nla_strips=False,
                             axis_forward="Z", axis_up="Y")


def escenario():
    escena = bpy.context.scene
    mundo = bpy.data.worlds.new("Cielo")
    mundo.use_nodes = True
    fondo = mundo.node_tree.nodes["Background"]
    fondo.inputs["Color"].default_value = (*hex_a_rgb("#9ED8FF"), 1)
    fondo.inputs["Strength"].default_value = 0.9
    escena.world = mundo
    bpy.ops.mesh.primitive_plane_add(size=60 * STUD)
    bpy.context.object.data.materials.append(material("#7ED957"))
    sol = bpy.data.objects.new("Sol", bpy.data.lights.new("Sol", "SUN"))
    sol.data.energy = 3.2
    sol.data.angle = math.radians(8)
    sol.rotation_euler = (math.radians(50), 0, math.radians(35))
    escena.collection.objects.link(sol)
    motores = [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items]
    escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in motores else "BLENDER_EEVEE"
    escena.render.resolution_x = escena.render.resolution_y = 640


def render(nombre):
    escena = bpy.context.scene
    escenario()
    cam = bpy.data.objects.new("Camara", bpy.data.cameras.new("Camara"))
    escena.collection.objects.link(cam)
    cam.location = Vector((4.2, -7.2, 4.4)) * STUD
    cam.rotation_euler = (Vector((0, -0.3, 1.7)) * STUD - cam.location).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 42
    escena.camera = cam
    escena.frame_set(9)
    escena.render.filepath = str(RENDERS / f"Mascota_{nombre}.png")
    bpy.ops.render.render(write_still=True)


def main():
    sin_renders = "--sin-renders" in sys.argv
    for carpeta in (GLB, FBX, RENDERS, BLEND):
        carpeta.mkdir(parents=True, exist_ok=True)
    for id_juego, nombre, armar in MASCOTAS:
        limpiar()
        vacio = armar()
        lineal(vacio)
        exportar(id_juego, vacio)
        if not sin_renders:
            render(nombre)
        tris = sum(len(o.data.polygons) * 2 for o in vacio.children_recursive if o.type == "MESH")
        print(f"Mascota lista: {nombre} ({id_juego}), {tris} triángulos")
    # las 8 en fila en un .blend para abrir en Blender
    limpiar()
    for n, (_, nombre, armar) in enumerate(MASCOTAS):
        vacio = armar()
        lineal(vacio)
        vacio.location.x = (n - 3.5) * 7 * STUD
    escenario()
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND / "Mascotas.blend"))


main()
