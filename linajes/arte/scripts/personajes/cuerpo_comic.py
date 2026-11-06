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
from mathutils import Euler, Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ARTE, "blender", "cuerpo.blend")
SALIDA = os.path.join(ARTE, "blender", "cuerpo-comic.blend")
EXPORTS = os.path.join(ARTE, "exports", "cuerpo-comic")
STUD = 0.28
BORDE = 0.009

COLORES = {
    "Piel": "#d8a06f",
    "Remera": "#e6e3da",
    "Campera": "#28436f",
    "Cuello": "#c2213a",
    "Cinturon": "#c2213a",
    "Pantalon": "#242a39",
    "Zapatillas": "#7f2831",
    "Pelo": "#12141e",
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


def main():
    bpy.ops.wm.open_mainfile(filepath=BASE)
    arm = bpy.data.objects["Maniqui"]
    arm.animation_data_clear()
    for o in list(bpy.data.objects):
        if o.type == "MESH" and o.name != "Niebla":
            bpy.data.objects.remove(o)
    mats = {n: material(n) for n in COLORES}
    borde = negro()

    def caja(nombre, hueso, centro, medida, mat, pieza, giro=(0, 0, 0)):
        bpy.ops.mesh.primitive_cube_add(size=1, location=centro)
        o = bpy.context.object
        o.name = nombre
        o.scale = medida
        o.rotation_euler = Euler([math.radians(x) for x in giro])
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        return preparar(o, hueso, mats[mat], pieza, arm, borde)

    def punta(nombre, base, hacia, ancho, pieza):
        d = Vector(hacia)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=ancho, depth=d.length, location=Vector(base) + d / 2)
        o = bpy.context.object
        o.name = nombre
        o.rotation_mode = "QUATERNION"
        o.rotation_quaternion = d.to_track_quat("Z", "Y")
        return preparar(o, "Head", mats["Pelo"], pieza, arm, borde)

    # Piel
    caja("Cuerpo_Head", "Head", (0, 0, 1.363), (0.34, 0.31, 0.325), "Piel", "Cuerpo")
    caja("Cuello_Piel", "Head", (0, 0, 1.19), (0.17, 0.16, 0.08), "Piel", "Cuerpo")
    for lado, n in ((1, "Left"), (-1, "Right")):
        x = 0.412 * lado
        caja(f"Cuerpo_{n}Hand", f"{n}Hand", (x, 0, 0.652), (0.235, 0.245, 0.1), "Piel", "Cuerpo")
        # Remera: antebrazo. Campera: manga corta hasta el codo, para que el codo doble limpio.
        caja(f"Cuerpo_{n}LowerArm", f"{n}LowerArm", (x, 0, 0.805), (0.245, 0.25, 0.218), "Remera", "Remera")
        caja(f"Cuerpo_{n}UpperArm", f"{n}UpperArm", (x, 0, 1.02), (0.27, 0.275, 0.3), "Campera", "Campera")
        # Pantalón y zapatillas
        caja(f"Cuerpo_{n}UpperLeg", f"{n}UpperLeg", (0.14 * lado, 0, 0.484), (0.255, 0.255, 0.27), "Pantalon", "Pantalon")
        caja(f"Cuerpo_{n}LowerLeg", f"{n}LowerLeg", (0.14 * lado, 0, 0.215), (0.25, 0.25, 0.29), "Pantalon", "Pantalon")
        caja(f"Cuerpo_{n}Foot", f"{n}Foot", (0.14 * lado, -0.025, 0.045), (0.265, 0.315, 0.09), "Zapatillas", "Zapatillas")
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

    def peinado(nombre, cajas, puntas):
        pieza = f"Pelo{nombre}"
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
    )
    peinado(
        "Flequillo",
        casco + nuca,
        [((x, -0.155, 0.17), (x * 0.15, -0.015, -h), 0.058) for x, h in ((-0.15, 0.2), (-0.075, 0.13), (0, 0.16), (0.075, 0.12), (0.15, 0.2))]
        + [((x, 0.05, 0.19), (x * 0.5, 0.12, 0.15), 0.09) for x in (-0.13, 0, 0.13)]
        + atras,
    )
    peinado(
        "Cresta",
        [((0, 0.01, 0.17), (0.2, 0.33, 0.055))] + nuca[:1],
        [((0, y, 0.17), (0, y * 0.45, h), 0.1) for y, h in ((-0.12, 0.17), (-0.04, 0.23), (0.04, 0.22), (0.12, 0.16))] + atras,
    )
    for o in bpy.data.objects:
        if o.get("Pieza", "").startswith("Pelo") and o["Pieza"] != "PeloPuntas":
            o.hide_render = o.hide_viewport = True

    bpy.ops.wm.save_as_mainfile(filepath=SALIDA)

    # Un FBX por pieza, para el creador de personaje.
    os.makedirs(EXPORTS, exist_ok=True)
    piezas = sorted({o["Pieza"] for o in bpy.data.objects if "Pieza" in o and not o["Pieza"].startswith("Cara")})
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
