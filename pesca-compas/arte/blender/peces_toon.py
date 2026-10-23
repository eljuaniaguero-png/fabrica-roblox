# Pesca al Compás · generador de los 8 peces de la Isla 1 (estilo "Toon de playa").
# Uso: abrir en el Text Editor de Blender y Run Script (Alt+P). Se puede correr las veces
# que haga falta: borra solo la colección "Peces_Isla1" que creó antes y la vuelve a armar.
#
# Reglas del pipeline:
#   - 1 stud = 0.28 m. Los largos se escriben en studs y se convierten con S().
#   - Cada pez mira hacia -Y en Blender -> al exportar (Forward -Z, Up Y) mira a -Z en Roblox.
#   - Sin contorno en la malla (nada de casco invertido): el contorno lo pone el Highlight
#     del juego, así no se duplican triángulos.
#   - Cada pieza es un objeto aparte con un nombre de rol (Cuerpo, Aleta, Ojo, Pupila, Brillo,
#     Detalle, DetalleOscuro). En Roblox el color se pinta por código según ese rol.
#   - Sin huesos: los peces no tienen rig. Se animan con TweenService (aleteo, salto).

import math
import os

import bmesh
import bpy
from mathutils import Matrix, Vector

STUD = 0.28
COLECCION = "Peces_Isla1"
CARPETA_FBX = r"C:\Users\eljua\fabrica-roblox\pesca-compas\arte\fbx"
EXPORTAR = True


def S(studs):
    return studs * STUD


# Paleta de referencia (la final la pinta Roblox). Coincide con Config.Peces y Estilo.luau.
BLANCO = (1.0, 1.0, 1.0)
NEGRO = (0.04, 0.05, 0.12)  # azul marino casi negro, igual que el contorno
CREMA = (1.0, 0.93, 0.75)


def rgb(r, g, b):
    return (r / 255, g / 255, b / 255)


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
    elif tipo == "cono":
        bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=0.5, radius2=0.0, depth=1.0)
    elif tipo == "cilindro":
        bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=0.5, radius2=0.5, depth=1.0)
    elif tipo == "cubo":
        bmesh.ops.create_cube(bm, size=1.0)
    return bm


def parte(pez, rol, tipo, tam, pos, color, rot=(0, 0, 0), seg=10):
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
    # los conos de 5-6 lados con radio 0 dejan caras degeneradas: se limpian acá
    bmesh.ops.dissolve_degenerate(bm, edges=bm.edges, dist=0.0001)

    # Una sola malla por rol: todas las piezas del mismo rol se suman al mismo objeto.
    # Así cada pez llega a Roblox con 7 MeshParts como máximo (menos draw calls).
    nombre = f"{pez['id']}_{rol}"
    existente = pez["roles"].get(rol)
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
        p.use_smooth = False  # toon: caras planas
    ob = bpy.data.objects.new(nombre, me)
    pez["roles"][rol] = ob
    ob.data.materials.append(material(f"PC_{rol}_{pez['id']}", color))
    pez["col"].objects.link(ob)
    ob.parent = pez["raiz"]
    pez["partes"].append(ob)
    return ob


def ojos(pez, x, y, z, radio, separacion=None):
    """Ojos enormes: blanco + pupila + brillo, a los dos lados de la cabeza."""
    sep = separacion if separacion is not None else x
    for lado in (-1, 1):
        cx = lado * sep
        parte(pez, "Ojo", "esfera", (radio * 2, radio * 2, radio * 2), (cx, y, z), BLANCO, seg=12)
        parte(pez, "Pupila", "esfera", (radio * 1.15, radio * 1.15, radio * 1.15),
              (cx + lado * radio * 0.55, y - radio * 0.45, z), NEGRO, seg=10)
        parte(pez, "Brillo", "esfera", (radio * 0.4, radio * 0.4, radio * 0.4),
              (cx + lado * radio * 0.95, y - radio * 0.7, z + radio * 0.35), BLANCO, seg=6)


def cola(pez, y, tam, color, z=0.0):
    # Dos conos aplastados en V, como cola de dibujo
    for lado in (-1, 1):
        parte(pez, "Aleta", "cono", (0.15, tam, tam * 0.9), (0, y + tam * 0.35, z + lado * tam * 0.3),
              color, rot=(-90 + lado * 35, 0, 0), seg=6)


def nuevo_pez(pid, color):
    col = bpy.data.collections[COLECCION]
    raiz = bpy.data.objects.new(pid, None)
    raiz.empty_display_type = "PLAIN_AXES"
    raiz.empty_display_size = S(0.5)
    col.objects.link(raiz)
    return {"id": pid, "col": col, "raiz": raiz, "partes": [], "roles": {}, "color": color}


def oscuro(c, f=0.65):
    return tuple(v * f for v in c)


# ---------------------------------------------------------------- los 8 peces
# Largos (studs): comunes ~2, raros ~2.5, épicos ~3, legendario 4, mítico 3.5, jefe 9.

def mojarra_globo():
    c = rgb(120, 200, 255)
    p = nuevo_pez("MojarraGlobo", c)
    parte(p, "Cuerpo", "esfera", (1.3, 2.0, 1.6), (0, 0, 0), c, seg=12)
    parte(p, "Detalle", "esfera", (1.0, 1.4, 1.0), (0, -0.15, -0.35), CREMA, seg=10)  # panza
    parte(p, "Aleta", "cono", (0.12, 0.8, 0.7), (0, 0.15, 0.85), oscuro(c), rot=(-60, 0, 0), seg=5)
    cola(p, 0.85, 0.9, oscuro(c))
    ojos(p, 0.42, -0.6, 0.25, 0.32)
    return p


def sardina_maraca():
    c = rgb(255, 230, 120)
    p = nuevo_pez("SardinaMaraca", c)
    parte(p, "Cuerpo", "esfera", (0.9, 2.2, 1.0), (0, 0, 0), c, seg=12)
    parte(p, "Detalle", "cilindro", (0.95, 0.15, 1.05), (0, 0.3, 0), rgb(255, 110, 80), rot=(90, 0, 0), seg=10)
    cola(p, 0.95, 0.7, oscuro(c))
    # la maraca sale del lomo
    parte(p, "DetalleOscuro", "cilindro", (0.12, 0.12, 0.6), (0, 0.1, 0.75), rgb(130, 80, 40), seg=6)
    parte(p, "Detalle", "esfera", (0.5, 0.5, 0.6), (0, 0.1, 1.2), rgb(255, 110, 80), seg=8)
    ojos(p, 0.3, -0.65, 0.18, 0.26)
    return p


def pejerrey_flauta():
    c = rgb(120, 255, 170)
    p = nuevo_pez("PejerreyFlauta", c)
    parte(p, "Cuerpo", "esfera", (0.8, 2.4, 0.9), (0, 0.2, 0), c, seg=12)
    # trompa de flauta con 3 agujeros
    parte(p, "Detalle", "cilindro", (0.28, 0.28, 1.1), (0, -1.35, 0.05), rgb(230, 235, 245), rot=(90, 0, 0), seg=8)
    for i in range(3):
        parte(p, "DetalleOscuro", "cilindro", (0.1, 0.1, 0.05), (0, -1.1 - i * 0.28, 0.2), NEGRO, seg=6)
    parte(p, "Aleta", "cono", (0.1, 0.9, 0.5), (0, 0.4, 0.5), oscuro(c), rot=(-70, 0, 0), seg=5)
    cola(p, 1.2, 0.75, oscuro(c))
    ojos(p, 0.28, -0.55, 0.18, 0.24)
    return p


def cangrejo_castanuela():
    c = rgb(255, 110, 80)
    p = nuevo_pez("CangrejoCastanuela", c)
    parte(p, "Cuerpo", "esfera", (2.0, 1.4, 0.8), (0, 0, 0), c, seg=12)
    # pinzas = castañuelas (dos medias tapas con cordón)
    for lado in (-1, 1):
        x = lado * 1.25
        parte(p, "Cuerpo", "esfera", (0.75, 0.75, 0.28), (x, -0.75, 0.12), c, seg=10)
        parte(p, "DetalleOscuro", "esfera", (0.75, 0.75, 0.28), (x, -0.75, -0.12), rgb(130, 60, 40), seg=10)
        parte(p, "DetalleOscuro", "cilindro", (0.15, 0.15, 0.5), (lado * 0.95, -0.45, 0), oscuro(c),
              rot=(0, 90, lado * 45), seg=6)
        for i in range(3):
            parte(p, "DetalleOscuro", "cilindro", (0.12, 0.12, 0.7), (lado * 1.0, 0.1 + i * 0.3, -0.35),
                  oscuro(c), rot=(0, lado * 60, 0), seg=5)
        # ojos sobre palitos
        parte(p, "DetalleOscuro", "cilindro", (0.1, 0.1, 0.45), (lado * 0.3, -0.45, 0.5), oscuro(c), seg=5)
    ojos(p, 0.3, -0.5, 0.85, 0.24)
    return p


def globo_bombo():
    c = rgb(190, 120, 255)
    p = nuevo_pez("GloboBombo", c)
    parte(p, "Cuerpo", "esfera", (2.4, 2.4, 2.4), (0, 0, 0), c, seg=14)
    # aro de bombo con parche crema adelante y atrás
    parte(p, "Detalle", "cilindro", (2.5, 2.5, 0.5), (0, 0, 0), rgb(255, 70, 90), rot=(0, 90, 0), seg=14)
    for lado in (-1, 1):
        parte(p, "Detalle", "cilindro", (2.1, 2.1, 0.06), (lado * 0.27, 0, 0), CREMA, rot=(0, 90, 0), seg=14)
    for ang in range(0, 360, 60):  # púas
        a = math.radians(ang)
        parte(p, "DetalleOscuro", "cono", (0.3, 0.3, 0.45), (0, math.cos(a) * 1.25, math.sin(a) * 1.25),
              BLANCO, rot=(ang - 90, 0, 0), seg=5)
    cola(p, 1.25, 0.8, oscuro(c))
    ojos(p, 0.5, -0.95, 0.45, 0.38)
    return p


def anguila_teclado():
    c = rgb(40, 40, 60)
    p = nuevo_pez("AnguilaTeclado", c)
    n = 5
    for i in range(n):
        r = 0.85 - i * 0.1
        y = -1.2 + i * 0.75
        z = math.sin(i * 1.1) * 0.25
        parte(p, "Cuerpo", "esfera", (r, 1.1, r), (0, y, z), c, seg=10)
        # teclas: blanca grande + negra chica
        parte(p, "Detalle", "cubo", (r * 0.7, 0.32, 0.1), (0, y - 0.1, z + r * 0.48), BLANCO)
        parte(p, "DetalleOscuro", "cubo", (r * 0.4, 0.16, 0.12), (0, y + 0.22, z + r * 0.5), NEGRO)
    cola(p, 2.4, 0.6, rgb(255, 190, 40))
    ojos(p, 0.28, -1.55, 0.22, 0.26)
    return p


def pulpo_dj():
    c = rgb(255, 80, 200)
    p = nuevo_pez("PulpoDJ", c)
    parte(p, "Cuerpo", "esfera", (2.0, 1.9, 2.3), (0, 0, 0.6), c, seg=14)
    for i in range(8):  # tentáculos
        a = math.radians(i * 45)
        parte(p, "Cuerpo", "cono", (0.45, 0.45, 1.5), (math.cos(a) * 0.65, math.sin(a) * 0.65, -0.8), c,
              rot=(math.sin(a) * 25, -math.cos(a) * 25, 0), seg=6)
    # auriculares
    parte(p, "DetalleOscuro", "cubo", (2.3, 0.3, 0.2), (0, 0, 1.85), NEGRO)
    for lado in (-1, 1):
        parte(p, "DetalleOscuro", "cubo", (0.2, 0.3, 0.9), (lado * 1.12, 0, 1.4), NEGRO)
        parte(p, "Detalle", "cilindro", (0.75, 0.75, 0.3), (lado * 1.05, 0, 0.85), rgb(120, 255, 170),
              rot=(0, 90, 0), seg=10)
    ojos(p, 0.42, -0.8, 0.75, 0.36)
    return p


def ballena_bandoneon():
    c = rgb(80, 110, 200)
    p = nuevo_pez("BallenaBandoneon", c)
    parte(p, "Cuerpo", "esfera", (4.6, 9.0, 4.2), (0, 0, 0), c, seg=16)
    parte(p, "Detalle", "esfera", (3.6, 7.0, 2.2), (0, -0.4, -1.2), CREMA, seg=12)  # panza
    # fuelle de bandoneón a los costados (pliegues alternados)
    for lado in (-1, 1):
        for i in range(5):
            col = BLANCO if i % 2 == 0 else NEGRO
            parte(p, "Detalle" if i % 2 == 0 else "DetalleOscuro", "cubo", (0.35, 0.5, 2.0),
                  (lado * 2.15, -1.0 + i * 0.5, 0.1), col)
        parte(p, "Aleta", "cono", (0.2, 1.6, 1.4), (lado * 2.0, 0.8, -1.3), oscuro(c), rot=(-80, 0, lado * 30), seg=5)
    # cola horizontal (flukes): conos aplastados en Z que apuntan hacia atrás y se abren en V
    for lado in (-1, 1):
        parte(p, "Aleta", "cono", (1.6, 0.3, 2.2), (lado * 0.8, 5.2, 0.4), oscuro(c), rot=(-90, 0, lado * 35), seg=6)
    parte(p, "Cuerpo", "cono", (1.3, 1.3, 2.0), (0, 4.3, 0.2), c, rot=(-90, 0, 0), seg=10)
    ojos(p, 1.55, -2.6, 0.6, 0.6)
    return p


PECES = [mojarra_globo, sardina_maraca, pejerrey_flauta, cangrejo_castanuela,
         globo_bombo, anguila_teclado, pulpo_dj, ballena_bandoneon]


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


def exportar(p):
    os.makedirs(CARPETA_FBX, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    p["raiz"].select_set(True)
    for ob in p["partes"]:
        ob.select_set(True)
    bpy.context.view_layer.objects.active = p["raiz"]
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(CARPETA_FBX, f"{p['id']}.fbx"),
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
    x = 0.0
    for fn in PECES:
        p = fn()
        # en fila para verlos todos; el origen de cada pez queda en su centro
        ancho = max(S(3), max(ob.dimensions.x for ob in p["partes"]) + S(1))
        p["raiz"].location.x = x + ancho / 2
        x += ancho + S(1)
        tris = sum(sum(len(f.vertices) - 2 for f in ob.data.polygons) for ob in p["partes"])
        reporte[p["id"]] = {"piezas": len(p["partes"]), "tris": tris}
    bpy.context.view_layer.update()
    if EXPORTAR:
        for fn_p in list(bpy.data.collections[COLECCION].objects):
            if fn_p.type == "EMPTY":
                partes = [o for o in fn_p.children]
                guardado = fn_p.location.copy()
                fn_p.location = (0, 0, 0)  # se exporta centrado en el origen
                bpy.context.view_layer.update()
                exportar({"id": fn_p.name, "raiz": fn_p, "partes": partes})
                fn_p.location = guardado
    return reporte


resultado = armar()
for k, v in resultado.items():
    print(f"{k:22s} piezas={v['piezas']:3d} tris={v['tris']}")
