# Pesca al Compás · generador de los 3 cebos de la tienda y la caña del personaje.
# Uso: abrir en el Text Editor de Blender y Run Script (Alt+P). Se puede correr las veces
# que haga falta: borra solo la colección "Cebos_Cana" que creó antes y la vuelve a armar.
#
# Mismas reglas que peces_toon.py:
#   - 1 stud = 0.28 m. Medidas en studs, convertidas con S().
#   - Todo mira hacia -Y en Blender -> al exportar (Forward -Z, Up Y) mira a -Z en Roblox.
#   - Sin contorno en la malla: lo pone el Highlight del juego.
#   - Una malla por rol (Cuerpo, Aleta, Ojo, Pupila, Brillo, Detalle, DetalleOscuro).
#   - Sin huesos. La caña tiene el origen en el puño (donde la agarra la RightHand R15).

import math
import os

import bmesh
import bpy
from mathutils import Matrix, Vector

STUD = 0.28
COLECCION = "Cebos_Cana"
CARPETA_FBX = r"C:\Users\eljua\fabrica-roblox\pesca-compas\arte\fbx"
EXPORTAR = True


def S(studs):
    return studs * STUD


BLANCO = (1.0, 1.0, 1.0)
NEGRO = (0.04, 0.05, 0.12)
CREMA = (1.0, 0.93, 0.75)


def rgb(r, g, b):
    return (r / 255, g / 255, b / 255)


def oscuro(c, f=0.65):
    return tuple(v * f for v in c)


# ---------------------------------------------------------------- utilidades

def material(nombre, color):
    m = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Roughness"].default_value = 1.0
    m.diffuse_color = (*color, 1.0)
    return m


def malla(tipo, seg):
    bm = bmesh.new()
    if tipo == "esfera":
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=max(4, seg // 2 + 1), radius=0.5)
    elif tipo == "ico":  # facetada: bola de boliche disco
        bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.5)
    elif tipo == "cono":
        bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=0.5, radius2=0.0, depth=1.0)
    elif tipo == "tronco":  # cono truncado, para la vara de la caña
        bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=0.5, radius2=0.25, depth=1.0)
    elif tipo == "cilindro":
        bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=0.5, radius2=0.5, depth=1.0)
    elif tipo == "cubo":
        bmesh.ops.create_cube(bm, size=1.0)
    return bm


def parte(obj, rol, tipo, tam, pos, color, rot=(0, 0, 0), seg=10):
    """tam y pos en studs; rot en grados (X, Y, Z)."""
    bm = malla(tipo, seg)
    m = Matrix.Diagonal((S(tam[0]), S(tam[1]), S(tam[2]), 1.0))
    r = (
        Matrix.Rotation(math.radians(rot[2]), 4, "Z")
        @ Matrix.Rotation(math.radians(rot[1]), 4, "Y")
        @ Matrix.Rotation(math.radians(rot[0]), 4, "X")
    )
    bmesh.ops.transform(bm, matrix=Matrix.Translation(Vector([S(v) for v in pos])) @ r @ m, verts=bm.verts)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0005)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.dissolve_degenerate(bm, edges=bm.edges, dist=0.0001)

    nombre = f"{obj['id']}_{rol}"
    existente = obj["roles"].get(rol)
    if existente:
        bm.from_mesh(existente.data)
        bm.to_mesh(existente.data)
        bm.free()
        for p in existente.data.polygons:
            p.use_smooth = False
        return existente

    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = False
    ob = bpy.data.objects.new(nombre, me)
    obj["roles"][rol] = ob
    ob.data.materials.append(material(f"PC_{rol}_{obj['id']}", color))
    obj["col"].objects.link(ob)
    ob.parent = obj["raiz"]
    obj["partes"].append(ob)
    return ob


def ojos(obj, x, y, z, radio):
    for lado in (-1, 1):
        cx = lado * x
        parte(obj, "Ojo", "esfera", (radio * 2,) * 3, (cx, y, z), BLANCO, seg=8)
        parte(obj, "Pupila", "esfera", (radio * 1.15,) * 3, (cx + lado * radio * 0.4, y - radio * 0.55, z), NEGRO, seg=6)
        parte(obj, "Brillo", "esfera", (radio * 0.4,) * 3,
              (cx + lado * radio * 0.75, y - radio * 0.85, z + radio * 0.35), BLANCO, seg=6)


def nuevo(oid):
    col = bpy.data.collections[COLECCION]
    raiz = bpy.data.objects.new(oid, None)
    raiz.empty_display_type = "PLAIN_AXES"
    raiz.empty_display_size = S(0.3)
    col.objects.link(raiz)
    return {"id": oid, "col": col, "raiz": raiz, "partes": [], "roles": {}}


# ---------------------------------------------------------------- cebos
# Se ven colgando del anzuelo y en las tarjetas de la tienda: ~1 stud de largo.
# Colores = Config.Cebos[].Color. El origen queda arriba, donde entra el anzuelo.

def lombriz_bailarina():
    c = rgb(255, 140, 170)
    o = nuevo("CeboLombriz")
    # cuerpo en S (5 bolitas que se achican), como si bailara
    for i in range(5):
        r = 0.42 - i * 0.05
        parte(o, "Cuerpo", "esfera", (r, r, r), (math.sin(i * 1.2) * 0.18, 0, -0.15 - i * 0.28), c, seg=6)
        if i % 2 == 1:  # anillos más oscuros
            parte(o, "Detalle", "cilindro", (r * 1.05, r * 1.05, 0.06),
                  (math.sin(i * 1.2) * 0.18, 0, -0.15 - i * 0.28), oscuro(c, 0.8), seg=8)
    # galerita de baile
    parte(o, "DetalleOscuro", "cilindro", (0.5, 0.5, 0.05), (0, 0, 0.06), NEGRO, seg=8)
    parte(o, "DetalleOscuro", "cilindro", (0.3, 0.3, 0.3), (0, 0, 0.22), NEGRO, seg=8)
    parte(o, "Detalle", "cilindro", (0.31, 0.31, 0.06), (0, 0, 0.12), rgb(255, 215, 60), seg=8)
    ojos(o, 0.09, -0.16, -0.08, 0.09)
    return o


def camaron_groovy():
    c = rgb(255, 160, 80)
    o = nuevo("CeboCamaron")
    # cuerpo curvado en C: segmentos que giran alrededor del eje X
    for i in range(6):
        a = math.radians(-20 + i * 38)
        r = 0.36 - i * 0.04
        parte(o, "Cuerpo", "esfera", (r, r * 1.1, r * 0.9),
              (0, -math.cos(a) * 0.4 + 0.1, -math.sin(a) * 0.4 - 0.2), c, rot=(i * 38, 0, 0), seg=8)
    # abanico de cola
    parte(o, "Aleta", "cono", (0.4, 0.08, 0.4), (0, 0.35, -0.65), oscuro(c), rot=(-120, 0, 0), seg=5)
    # anteojos de sol "groovy" (cabeza = primer segmento, adelante) + antenas
    for lado in (-1, 1):
        parte(o, "DetalleOscuro", "cilindro", (0.2, 0.2, 0.05), (lado * 0.1, -0.45, 0.0), NEGRO, rot=(90, 0, 0), seg=8)
        parte(o, "DetalleOscuro", "cilindro", (0.025, 0.025, 0.55), (lado * 0.08, -0.5, 0.28), oscuro(c, 0.5),
              rot=(-35, lado * 15, 0), seg=4)
    parte(o, "DetalleOscuro", "cubo", (0.1, 0.03, 0.03), (0, -0.46, 0.0), NEGRO)
    parte(o, "Brillo", "esfera", (0.06, 0.06, 0.06), (0.14, -0.49, 0.03), BLANCO, seg=6)
    return o


def calamar_disco():
    c = rgb(190, 110, 255)
    o = nuevo("CeboCalamar")
    # manto en punta hacia arriba (origen en la punta, entra el anzuelo)
    parte(o, "Cuerpo", "esfera", (0.55, 0.55, 0.75), (0, 0, -0.45), c, seg=10)
    parte(o, "Aleta", "cono", (0.75, 0.12, 0.45), (0, 0, -0.08), oscuro(c), seg=4)
    # 6 tentáculos abiertos
    for i in range(6):
        a = math.radians(i * 60)
        parte(o, "Cuerpo", "cono", (0.14, 0.14, 0.55), (math.cos(a) * 0.14, math.sin(a) * 0.14, -1.0), c,
              rot=(180 + math.sin(a) * 20, -math.cos(a) * 20, 0), seg=5)
    # bola de boliche disco en la panza (facetada, refleja la luz)
    parte(o, "Brillo", "ico", (0.32, 0.32, 0.32), (0, -0.28, -0.7), rgb(220, 230, 255))
    ojos(o, 0.15, -0.22, -0.4, 0.1)
    return o


# ---------------------------------------------------------------- caña
# ~5.5 studs. Origen = centro del puño. La vara apunta a -Y (adelante, -Z en Roblox).

def cana():
    madera = rgb(150, 95, 55)
    o = nuevo("CanaPesca")
    # puño de corcho
    parte(o, "Detalle", "cilindro", (0.32, 0.32, 1.2), (0, 0.15, 0), CREMA, rot=(90, 0, 0), seg=8)
    parte(o, "DetalleOscuro", "cilindro", (0.36, 0.36, 0.12), (0, -0.48, 0), oscuro(madera), rot=(90, 0, 0), seg=8)
    # vara de madera que se afina
    parte(o, "Cuerpo", "tronco", (0.2, 0.2, 4.6), (0, -2.85, 0), madera, rot=(90, 0, 0), seg=6)
    # anillas (guías del hilo)
    for i in range(3):
        parte(o, "DetalleOscuro", "cilindro", (0.16, 0.04, 0.16), (0, -1.6 - i * 1.25, -0.12), NEGRO, seg=6)
    # punta: nota musical amarilla (la firma del juego)
    parte(o, "Brillo", "esfera", (0.32, 0.22, 0.26), (0, -5.25, -0.05), rgb(255, 215, 60), rot=(0, 0, 20), seg=8)
    parte(o, "Brillo", "cilindro", (0.05, 0.05, 0.45), (0.12, -5.2, 0.18), rgb(255, 215, 60), seg=4)
    # reel: carrete con manija, debajo del puño
    parte(o, "Aleta", "cilindro", (0.5, 0.5, 0.22), (0, -0.15, -0.38), rgb(255, 110, 80), rot=(0, 90, 0), seg=10)
    parte(o, "DetalleOscuro", "cilindro", (0.08, 0.08, 0.25), (0, -0.15, -0.2), NEGRO, seg=5)
    parte(o, "DetalleOscuro", "cubo", (0.06, 0.06, 0.3), (0.16, -0.15, -0.5), NEGRO)
    parte(o, "Detalle", "esfera", (0.1, 0.1, 0.1), (0.2, -0.15, -0.65), CREMA, seg=6)
    return o


OBJETOS = [lombriz_bailarina, camaron_groovy, calamar_disco, cana]


# ---------------------------------------------------------------- armado

def limpiar_coleccion():
    col = bpy.data.collections.get(COLECCION)
    if col:
        for ob in list(col.objects):
            data = ob.data
            bpy.data.objects.remove(ob, do_unlink=True)
            if data is not None and data.users == 0:
                bpy.data.meshes.remove(data)
    else:
        col = bpy.data.collections.new(COLECCION)
        bpy.context.scene.collection.children.link(col)
    return col


def exportar(o):
    os.makedirs(CARPETA_FBX, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    o["raiz"].select_set(True)
    for ob in o["partes"]:
        ob.select_set(True)
    bpy.context.view_layer.objects.active = o["raiz"]
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(CARPETA_FBX, f"{o['id']}.fbx"),
        use_selection=True,
        object_types={"EMPTY", "MESH"},
        use_mesh_modifiers=True,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="-Z",
        axis_up="Y",
        bake_space_transform=True,
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
        bake_anim=False,
        path_mode="AUTO",
    )


def armar():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    limpiar_coleccion()
    reporte = {}
    hechos = []
    x = 0.0
    for fn in OBJETOS:
        o = fn()
        hechos.append(o)
        bpy.context.view_layer.update()
        ancho = max(S(2), max(ob.dimensions.x for ob in o["partes"]) + S(1))
        o["raiz"].location = (x + ancho / 2, S(-12), 0)  # al costado de los peces
        x += ancho + S(1)
        tris = sum(sum(len(f.vertices) - 2 for f in ob.data.polygons) for ob in o["partes"])
        reporte[o["id"]] = {"piezas": len(o["partes"]), "tris": tris}
    bpy.context.view_layer.update()
    if EXPORTAR:
        for o in hechos:
            guardado = o["raiz"].location.copy()
            o["raiz"].location = (0, 0, 0)
            bpy.context.view_layer.update()
            exportar(o)
            o["raiz"].location = guardado
        bpy.context.view_layer.update()
    return reporte


resultado = armar()
for k, v in resultado.items():
    print(f"{k:14s} piezas={v['piezas']:2d} tris={v['tris']}")
