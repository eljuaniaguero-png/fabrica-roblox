"""Cuerpo oficial del jugador, estilo cómic urbano, sobre el esqueleto R15 "Maniqui" de cuerpo.blend.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/cuerpo_comic.py

No mueve ningún hueso: cada pieza sigue a un solo hueso, sin deformar. Escribe
blender/cuerpo-comic.blend, exports/cuerpo-comic/*.fbx y exports/cuerpo-comic/caras/*.png.
Las caras las genera caras_comic.py antes de este script.
"""

import math
import os

import bpy
import numpy as np
from mathutils import Euler, Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ARTE, "blender", "cuerpo.blend")
SALIDA = os.path.join(ARTE, "blender", "cuerpo-comic.blend")
EXPORTS = os.path.join(ARTE, "exports", "cuerpo-comic")
STUD = 0.28
BORDE = 0.009
ZAPA_X, ZAPA_ATRAS, ZAPA_FRENTE, ZAPA_SUELA = 0.134, 0.134, -0.205, 0.034

COLORES = {
    "Piel": "#d8a06f",
    "Remera": "#e6e3da",
    "Campera": "#28436f",
    "Cuello": "#c2213a",
    "Cinturon": "#c2213a",
    "Pantalon": "#242a39",
    "Zapatillas": "#7f2831",
    "Pelo": "#12141e",
    "PeloLuz": "#30405f",
    "Forro": "#17233b",
    "Ribete": "#d7d2c4",
    "Suela": "#ece8dd",
    "Metal": "#c9ced8",
}


def material(nombre):
    m = bpy.data.materials.new(f"Mat_{nombre}")
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    h = COLORES[nombre]
    b.inputs["Base Color"].default_value = (*[(int(h[i : i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)], 1)
    b.inputs["Roughness"].default_value = 0.62
    return m


def negro():
    m = bpy.data.materials.new("Contorno")
    m.use_nodes = True
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.005, 0.005, 0.01, 1)
    m.use_backface_culling = True
    return m


def pegar(o, arm, hueso):
    """Pieza rígida: sigue al hueso sin deformarse y sin moverse de su lugar."""
    bpy.context.view_layer.update()
    lugar = o.matrix_world.copy()
    o.parent = arm
    o.parent_type = "BONE"
    o.parent_bone = hueso
    bpy.context.view_layer.update()
    o.matrix_world = lugar


def preparar(o, hueso, mat, pieza, arm, borde):
    o["Pieza"] = pieza
    o.data.materials.append(mat)
    o.data.materials.append(borde)
    pegar(o, arm, hueso)
    s = o.modifiers.new("Borde", "SOLIDIFY")
    s.thickness, s.offset, s.use_flip_normals, s.material_offset = BORDE, 1, True, 1
    return o


def contorno(mx, atras, frente, radio):
    """Planta del pie: talón recto y punta apenas redondeada. Mismo orden de puntos siempre."""
    b = 0.006
    puntos = [(-mx + b, atras), (mx - b, atras), (mx, atras - b)]
    for i in range(5):
        a = math.radians(-90 * i / 4)
        puntos.append((mx - radio + radio * math.cos(a), frente + radio + radio * math.sin(a)))
    for i in range(5):
        a = math.radians(-90 - 90 * i / 4)
        puntos.append((-mx + radio + radio * math.cos(a), frente + radio + radio * math.sin(a)))
    puntos.append((-mx, atras - b))
    return puntos


def textura_zapatilla():
    """Mitad izquierda: capellada vista de arriba, con cordones. Mitad derecha: suela con línea."""
    n = 256

    def lin(nombre):
        return np.array([(int(COLORES[nombre][i : i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)])

    def fila(y):
        return int(((y - ZAPA_FRENTE) / (ZAPA_ATRAS - ZAPA_FRENTE) * 0.96 + 0.02) * n)

    px = np.ones((n, n, 4), dtype=np.float32)
    px[:, : n // 2, :3] = lin("Zapatillas")
    px[:, n // 2 :, :3] = lin("Suela")
    px[int(n * 0.3) : int(n * 0.36), n // 2 :, :3] = lin("Pantalon")  # línea de la suela
    px[fila(-0.17) : fila(-0.1), 48:80, :3] = lin("Ribete")  # lengüeta
    for y in (-0.16, -0.14, -0.12):
        px[fila(y) : fila(y + 0.008), 38:90, :3] = lin("Suela")  # cordones
    img = bpy.data.images.new("Zapatillas_color", n, n, alpha=False)
    img.colorspace_settings.name = "Linear Rec.709"
    img.pixels.foreach_set(px.ravel())
    carpeta = os.path.join(ARTE, "blender", "texturas", "zapatillas")
    os.makedirs(carpeta, exist_ok=True)
    img.filepath_raw = os.path.join(carpeta, "Zapatillas_color.png")
    img.file_format = "PNG"
    img.save()
    img.pack()
    m = bpy.data.materials.new("Mat_ZapatillaTextura")
    m.use_nodes = True
    t = m.node_tree.nodes.new("ShaderNodeTexImage")
    t.image = img
    t.interpolation = "Closest"
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Roughness"].default_value = 0.62
    m.node_tree.links.new(t.outputs["Color"], b.inputs["Base Color"])
    return m


def zapatilla(nombre, hueso, lx, mat, arm, borde):
    """Una malla cerrada: suela continua alrededor de todo el pie y capellada encima."""

    def alto(y):
        k = min(max((-0.12 - y) / (-0.12 - ZAPA_FRENTE), 0), 1)
        return 0.125 - 0.05 * k * k

    suela = contorno(ZAPA_X, ZAPA_ATRAS, ZAPA_FRENTE, 0.04)
    arriba = contorno(ZAPA_X - 0.006, ZAPA_ATRAS - 0.006, ZAPA_FRENTE + 0.006, 0.036)
    abajo = contorno(ZAPA_X - 0.005, ZAPA_ATRAS - 0.005, ZAPA_FRENTE + 0.005, 0.036)
    aros = [
        [(x, y, 0.0) for x, y in abajo],
        [(x, y, 0.006) for x, y in suela],
        [(x, y, ZAPA_SUELA) for x, y in suela],
        [(x, y, ZAPA_SUELA) for x, y in arriba],
        [(x, y, alto(y)) for x, y in arriba],
        [(x * 0.55, y * 0.6 - 0.03, alto(y * 0.6 - 0.03)) for x, y in arriba],
    ]
    n = len(suela)
    verts = [v for aro in aros for v in aro]
    abajo_c, arriba_c = len(verts), len(verts) + 1
    verts += [(0, -0.03, 0.0), (0, -0.03, alto(-0.03))]
    caras, es_suela = [], []
    for j in range(len(aros) - 1):
        for i in range(n):
            k = (i + 1) % n
            caras.append((j * n + i, j * n + k, (j + 1) * n + k, (j + 1) * n + i))
            es_suela.append(j < 3)
    for i in range(n):
        k = (i + 1) % n
        caras.append((abajo_c, k, i))
        es_suela.append(True)
        caras.append((arriba_c, (len(aros) - 1) * n + i, (len(aros) - 1) * n + k))
        es_suela.append(False)
    me = bpy.data.meshes.new(nombre)
    me.from_pydata([(x + lx, y, z) for x, y, z in verts], [], caras)
    capa = me.uv_layers.new(name="UV")
    for cara, blanca in zip(me.polygons, es_suela):
        for lazo in cara.loop_indices:
            x, y, z = verts[me.loops[lazo].vertex_index]
            if blanca:
                capa.data[lazo].uv = (0.75, 0.05 + 0.9 * z / ZAPA_SUELA)
            else:
                capa.data[lazo].uv = ((x + ZAPA_X) / (2 * ZAPA_X) * 0.46 + 0.02, (y - ZAPA_FRENTE) / (ZAPA_ATRAS - ZAPA_FRENTE) * 0.96 + 0.02)
    me.update()
    o = bpy.data.objects.new(nombre, me)
    bpy.context.collection.objects.link(o)
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    aristas = {}
    for f in me.polygons:
        for k in f.edge_keys:
            aristas[k] = aristas.get(k, 0) + 1
    unicos = {tuple(round(c, 5) for c in v.co) for v in me.vertices}
    print("ZAPATILLA", nombre, "triangulos", sum(len(f.vertices) - 2 for f in me.polygons), "abiertas", sum(1 for c in aristas.values() if c != 2), "vertices_duplicados", len(me.vertices) - len(unicos))
    return preparar(o, hueso, mat, "Zapatillas", arm, borde)


def main():
    bpy.ops.wm.open_mainfile(filepath=BASE)
    arm = bpy.data.objects["Maniqui"]
    arm.animation_data_clear()
    for o in list(bpy.data.objects):
        if o.type == "MESH" and o.name != "Niebla":
            bpy.data.objects.remove(o)
    mats = {n: material(n) for n in COLORES}
    borde = negro()
    mat_zapa = textura_zapatilla()

    def caja(nombre, hueso, centro, medida, mat, pieza, giro=(0, 0, 0)):
        bpy.ops.mesh.primitive_cube_add(size=1, location=centro)
        o = bpy.context.object
        o.name = nombre
        o.scale = medida
        o.rotation_euler = Euler([math.radians(x) for x in giro])
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        return preparar(o, hueso, mats[mat], pieza, arm, borde)

    def punta(nombre, base, hacia, ancho, pieza, mat="Pelo"):
        d = Vector(hacia)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=ancho, depth=d.length, location=Vector(base) + d / 2)
        o = bpy.context.object
        o.name = nombre
        o.rotation_mode = "QUATERNION"
        o.rotation_quaternion = d.to_track_quat("Z", "Y")
        return preparar(o, "Head", mats[mat], pieza, arm, borde)

    # Piel
    caja("Cuerpo_Head", "Head", (0, 0, 1.363), (0.34, 0.31, 0.325), "Piel", "Cuerpo")
    caja("Cuello_Piel", "Head", (0, 0, 1.19), (0.17, 0.16, 0.08), "Piel", "Cuerpo")
    for lado, n in ((1, "Left"), (-1, "Right")):
        x = 0.412 * lado
        caja(f"Cuerpo_{n}Hand", f"{n}Hand", (x, 0, 0.652), (0.235, 0.245, 0.1), "Piel", "Cuerpo")
        # Manga continua de la campera: dos bloques iguales que se tocan en el codo.
        caja(f"Cuerpo_{n}LowerArm", f"{n}LowerArm", (x, 0, 0.805), (0.27, 0.275, 0.218), "Campera", "Campera")
        caja(f"Cuerpo_{n}UpperArm", f"{n}UpperArm", (x, 0, 1.045), (0.27, 0.275, 0.262), "Campera", "Campera")
        # Pantalón y zapatillas
        caja(f"Cuerpo_{n}UpperLeg", f"{n}UpperLeg", (0.14 * lado, 0, 0.484), (0.255, 0.255, 0.27), "Pantalon", "Pantalon")
        caja(f"Cuerpo_{n}LowerLeg", f"{n}LowerLeg", (0.14 * lado, 0, 0.215), (0.25, 0.25, 0.29), "Pantalon", "Pantalon")
        zapatilla(f"Cuerpo_{n}Foot", f"{n}Foot", 0.14 * lado, mat_zapa, arm, borde)
        # Campera en el torso: frente abierto, costado y solapa.
        caja(f"Campera_Frente{n}", "UpperTorso", (0.185 * lado, -0.135, 0.965), (0.17, 0.035, 0.49), "Campera", "Campera")
        caja(f"Campera_Costado{n}", "UpperTorso", (0.262 * lado, 0, 0.965), (0.035, 0.28, 0.49), "Campera", "Campera")
        caja(f"Cuello_Solapa{n}", "UpperTorso", (0.105 * lado, -0.158, 1.07), (0.052, 0.02, 0.265), "Cuello", "Campera", (0, -12 * lado, 0))
        caja(f"Cuello_Lado{n}", "UpperTorso", (0.135 * lado, 0, 1.215), (0.055, 0.25, 0.09), "Cuello", "Campera")
    caja("Cuerpo_UpperTorso", "UpperTorso", (0, 0, 0.965), (0.5, 0.25, 0.48), "Remera", "Remera")
    caja("Campera_Espalda", "UpperTorso", (0, 0.135, 0.965), (0.56, 0.035, 0.49), "Campera", "Campera")
    caja("Cuello_Atras", "UpperTorso", (0, 0.13, 1.225), (0.32, 0.07, 0.11), "Cuello", "Campera")
    caja("Cuerpo_LowerTorso", "LowerTorso", (0, 0, 0.665), (0.54, 0.26, 0.11), "Pantalon", "Pantalon")
    caja("Cinturon", "LowerTorso", (0, 0, 0.724), (0.55, 0.275, 0.05), "Cinturon", "Cinturon")

    # Capas de ropa: todas siguen a su hueso, así que no estorban las articulaciones.
    for lado, n in ((1, "Left"), (-1, "Right")):
        x = 0.412 * lado
        # Campera: bolsillo, cierre, puño con ribete, tira de hombro y forro visible.
        caja(f"Campera_Bolsillo{n}", "UpperTorso", (0.185 * lado, -0.156, 0.82), (0.13, 0.012, 0.1), "Forro", "Campera")
        caja(f"Campera_Tapa{n}", "UpperTorso", (0.185 * lado, -0.164, 0.875), (0.145, 0.018, 0.026), "Ribete", "Campera")
        caja(f"Campera_Cierre{n}", "UpperTorso", (0.103 * lado, -0.155, 0.86), (0.012, 0.012, 0.28), "Metal", "Campera")
        caja(f"Campera_Forro{n}", "UpperTorso", (0.097 * lado, -0.143, 0.965), (0.022, 0.018, 0.49), "Forro", "Campera")
        caja(f"Campera_Hombro{n}", f"{n}UpperArm", (x, 0, 1.175), (0.282, 0.287, 0.028), "Cuello", "Campera")
        # Puño de la manga, en la muñeca.
        caja(f"Campera_Punio{n}", f"{n}LowerArm", (x, 0, 0.715), (0.283, 0.288, 0.045), "Forro", "Campera")
        caja(f"Campera_Ribete{n}", f"{n}LowerArm", (x, 0, 0.746), (0.285, 0.29, 0.016), "Ribete", "Campera")
        # Pantalón: bolsillo, rodillera y costura; botamanga arriba de la zapatilla.
        lx = 0.14 * lado
        caja(f"Pantalon_Bolsillo{n}", f"{n}UpperLeg", (lx + 0.075 * lado, -0.132, 0.56), (0.08, 0.012, 0.075), "Forro", "Pantalon")
        caja(f"Pantalon_Costura{n}", f"{n}UpperLeg", (lx + 0.131 * lado, 0, 0.484), (0.01, 0.045, 0.255), "Cuello", "Pantalon")
        caja(f"Pantalon_Costura2{n}", f"{n}LowerLeg", (lx + 0.129 * lado, 0, 0.2575), (0.01, 0.045, 0.205), "Cuello", "Pantalon")
        caja(f"Pantalon_Rodillera{n}", f"{n}LowerLeg", (lx, -0.133, 0.285), (0.18, 0.018, 0.105), "Forro", "Pantalon")
        caja(f"Pantalon_Botamanga{n}", f"{n}LowerLeg", (lx, 0, 0.135), (0.265, 0.265, 0.038), "Forro", "Pantalon")
    # Cuello doble, parche de espalda original y dobladillo.
    caja("Cuello_Forro", "UpperTorso", (0, 0.098, 1.25), (0.26, 0.035, 0.07), "Forro", "Campera")
    caja("Campera_Dobladillo", "UpperTorso", (0, 0.154, 0.74), (0.565, 0.012, 0.045), "Forro", "Campera")
    caja("Campera_Parche", "UpperTorso", (0, 0.158, 1.01), (0.2, 0.012, 0.2), "Cuello", "Campera", (0, 45, 0))
    caja("Campera_ParcheCentro", "UpperTorso", (0, 0.165, 1.01), (0.11, 0.012, 0.11), "Ribete", "Campera", (0, 45, 0))
    # Remera: cuello y franja.
    caja("Remera_Cuello", "UpperTorso", (0, -0.128, 1.18), (0.2, 0.014, 0.035), "Forro", "Remera")
    caja("Remera_Franja", "UpperTorso", (0, -0.13, 0.95), (0.13, 0.012, 0.055), "Cuello", "Remera")
    # Cinturón: hebilla y presillas.
    caja("Cinturon_Hebilla", "LowerTorso", (0, -0.144, 0.724), (0.085, 0.018, 0.058), "Metal", "Cinturon")
    caja("Cinturon_Centro", "LowerTorso", (0, -0.155, 0.724), (0.045, 0.012, 0.028), "Cuello", "Cinturon")
    for x in (-0.19, 0.19):
        caja(f"Cinturon_Presilla{x}", "LowerTorso", (x, -0.142, 0.724), (0.022, 0.014, 0.07), "Pantalon", "Cinturon")

    # Cara: un plano con textura delante de la cabeza.
    for i in (1, 2, 3):
        bpy.ops.mesh.primitive_plane_add(size=1, location=(0, -0.1565, 1.36), rotation=(math.radians(90), 0, 0))
        o = bpy.context.object
        o.name = f"Cara_{i}"
        o.scale = (0.33, 0.315, 1)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        m = bpy.data.materials.new(f"Mat_Cara_{i}")
        m.use_nodes = True
        m.surface_render_method = "BLENDED"
        t = m.node_tree.nodes.new("ShaderNodeTexImage")
        t.image = bpy.data.images.load(os.path.join(EXPORTS, "caras", f"cara-{i}.png"))
        b = m.node_tree.nodes["Principled BSDF"]
        m.node_tree.links.new(t.outputs["Color"], b.inputs["Base Color"])
        m.node_tree.links.new(t.outputs["Alpha"], b.inputs["Alpha"])
        o.data.materials.append(m)
        o["Pieza"] = f"Cara{i}"
        pegar(o, arm, "Head")
        o.hide_render = o.hide_viewport = i != 1

    # Peinados. Coordenadas relativas al centro de la cabeza.
    def cabeza(x, y, z):
        return (x, y, 1.363 + z)

    def peinado(nombre, cajas, puntas, capa=()):
        pieza = f"Pelo{nombre}"
        for i, (b, h, a) in enumerate(capa):
            punta(f"Pelo_{nombre}_L{i}", cabeza(*b), h, a, pieza, "PeloLuz")
        for i, (c, m) in enumerate(cajas):
            caja(f"Pelo_{nombre}_C{i}", "Head", cabeza(*c), m, "Pelo", pieza)
        for i, (b, h, a) in enumerate(puntas):
            punta(f"Pelo_{nombre}_P{i}", cabeza(*b), h, a, pieza)

    casco = [((0, 0.02, 0.17), (0.37, 0.33, 0.1))]
    nuca = [((0, 0.145, 0.03), (0.36, 0.06, 0.26)), ((0.175, 0.07, 0.07), (0.03, 0.2, 0.2)), ((-0.175, 0.07, 0.07), (0.03, 0.2, 0.2))]
    atras = [((x, 0.17, y), (x * 0.5, 0.1, -0.09), 0.07) for x, y in ((-0.12, 0.13), (0, 0.11), (0.12, 0.13))]
    peinado(
        "Puntas",
        casco + nuca,
        [((-0.15, -0.08, 0.16), (-0.13, -0.03, 0.1), 0.095), ((-0.08, -0.08, 0.17), (-0.08, -0.07, 0.17), 0.095), ((0, -0.09, 0.17), (0.01, -0.09, 0.2), 0.095), ((0.08, -0.08, 0.17), (0.08, -0.07, 0.16), 0.095), ((0.15, -0.08, 0.16), (0.13, -0.02, 0.09), 0.095)]
        + [((x, 0.09, 0.17), (x * 0.8, 0.14, 0.12), 0.09) for x in (-0.14, 0, 0.14)]
        + atras,
        [((-0.13, -0.13, 0.18), (-0.11, -0.05, 0.1), 0.055), ((-0.04, -0.13, 0.19), (-0.04, -0.09, 0.14), 0.055), ((0.05, -0.13, 0.19), (0.05, -0.09, 0.13), 0.055), ((0.13, -0.13, 0.18), (0.1, -0.04, 0.09), 0.055)]
        + [((x, 0.03, 0.24), (x * 0.7, -0.02, 0.17), 0.065) for x in (-0.1, 0.1)]
        + [((x * 0.18, 0.05, 0.08), (x * 0.08, 0, -0.14), 0.04) for x in (-1, 1)]
        + [((0.179 * x, 0.02, 0.03), (0.018 * x, -0.03, -0.12), 0.04) for x in (-1, 1)],
    )
    # Sin casco plano: una base al ras de la cabeza y puntas que salen de toda la cabeza.
    base = [((0, 0, 0.169), (0.345, 0.315, 0.014))]
    peinado(
        "Flequillo",
        base + nuca,
        [((x, -0.155, 0.17), (x * 0.15, -0.015, -h), 0.058) for x, h in ((-0.15, 0.2), (-0.075, 0.13), (0, 0.16), (0.075, 0.12), (0.15, 0.2))]
        + [((x, y, 0.15), (x * 0.65, y * 0.65, 0.16), 0.085) for x in (-0.12, 0, 0.12) for y in (-0.08, 0.02, 0.11)]
        + [((0.16 * x, y, 0.1), (0.13 * x, y * 0.4, 0.07), 0.07) for x in (-1, 1) for y in (-0.07, 0.07)]
        + atras,
        [((x, -0.158, 0.13), (x * 0.1, -0.01, -h), 0.034) for x, h in ((-0.11, 0.14), (-0.035, 0.09), (0.04, 0.11), (0.115, 0.15))]
        + [((x, y, 0.2), (x * 0.5, y * 0.5, 0.14), 0.05) for x in (-0.07, 0.07) for y in (-0.03, 0.08)],
    )
    peinado(
        "Cresta",
        # Costados parejos: pelo corto en los dos lados, sin zonas de piel.
        [((0, 0, 0.169), (0.345, 0.315, 0.014)), ((0, 0.01, 0.185), (0.2, 0.33, 0.04)), ((0.176, 0.03, 0.09), (0.018, 0.26, 0.15)), ((-0.176, 0.03, 0.09), (0.018, 0.26, 0.15))] + nuca[:1],
        [((0, y, 0.17), (0, y * 0.45, h), 0.1) for y, h in ((-0.12, 0.17), (-0.04, 0.23), (0.04, 0.22), (0.12, 0.16))] + atras,
        [((0, y, 0.2), (0, y * 0.35, h), 0.052) for y, h in ((-0.09, 0.2), (0, 0.27), (0.09, 0.19))]
        + [((x, -0.02, 0.15), (x * 0.15, 0, -0.06), 0.03) for x in (-0.14, 0.14)],
    )
    for o in bpy.data.objects:
        if o.get("Pieza", "").startswith("Pelo") and o["Pieza"] != "PeloPuntas":
            o.hide_render = o.hide_viewport = True

    bpy.ops.wm.save_as_mainfile(filepath=SALIDA)

    # Un FBX por pieza, para el creador de personaje.
    os.makedirs(EXPORTS, exist_ok=True)
    piezas = sorted({o["Pieza"] for o in bpy.data.objects if "Pieza" in o and not o["Pieza"].startswith(("Cara", "Pelo"))})  # los peinados salen de pelo_hebras.py
    for o in bpy.data.objects:
        o.hide_viewport = False
    for pieza in piezas:
        bpy.ops.object.select_all(action="DESELECT")
        for o in bpy.data.objects:
            if o.get("Pieza") == pieza:
                o.select_set(True)
        bpy.ops.export_scene.fbx(
            filepath=os.path.join(EXPORTS, f"{pieza}.fbx"),
            use_selection=True,
            object_types={"MESH"},
            use_mesh_modifiers=False,
            global_scale=1 / STUD,
            apply_unit_scale=True,
            apply_scale_options="FBX_SCALE_UNITS",
            axis_forward="Z",
            axis_up="Y",
        )


main()
