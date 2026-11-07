"""Textura de colores para las zapatillas: cada malla queda con un solo material.

Uso (después de cuerpo_comic.py):
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/zapatillas_textura.py

Roblox pinta cada MeshPart de un color. Acá cada cara apunta a un cuadrado de color de la
textura, así la suela, la franja y los cordones conservan el suyo. No guarda cuerpo-comic.blend.
"""

import math
import os

import bmesh
import bpy
import numpy as np
from mathutils import Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LADO = 128
CELDAS = ("Mat_Zapatillas", "Mat_Suela", "Mat_Cuello", "Mat_Ribete")  # grilla de 2 x 2


def celda(i):
    return ((i % 2 + 0.5) / 2, (i // 2 + 0.5) / 2)


def textura(ruta):
    pixeles = np.ones((LADO, LADO, 4), dtype=np.float32)
    mitad = LADO // 2
    for i, nombre in enumerate(CELDAS):
        color = bpy.data.materials[nombre].node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value
        x, y = (i % 2) * mitad, (i // 2) * mitad
        pixeles[y : y + mitad, x : x + mitad, :3] = color[:3]
    img = bpy.data.images.new("Zapatillas_color", LADO, LADO, alpha=False)
    img.colorspace_settings.name = "Linear Rec.709"
    img.pixels.foreach_set(pixeles.ravel())
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()
    return img


def tipo_de_pieza(cajas):
    """Reconoce la pieza por su tamaño: en la malla unida se perdió el material de cada cara."""
    x, y, z = (max(c) - min(c) for c in cajas)
    alto = (max(cajas[2]) + min(cajas[2])) / 2
    if z > 0.1:
        return "Mat_Zapatillas"  # capellada
    if abs(z - 0.018) < 0.002:
        return "Mat_Ribete" if alto > 0.07 else "Mat_Cuello"  # lengüeta o franja
    return "Mat_Suela"  # suela, puntera y cordones


def pasar_a_textura(pie, material):
    me = pie.data
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    capa = bm.loops.layers.uv.new("Colores")
    vistos, conteo = set(), {}
    for inicio in bm.faces:
        if inicio.index in vistos:
            continue
        isla, pila = [], [inicio]
        while pila:
            f = pila.pop()
            if f.index in vistos:
                continue
            vistos.add(f.index)
            isla.append(f)
            pila += [g for e in f.edges for g in e.link_faces]
        puntos = [pie.matrix_world @ v.co for f in isla for v in f.verts]
        nombre = tipo_de_pieza([[p[i] for p in puntos] for i in range(3)])
        conteo[nombre] = conteo.get(nombre, 0) + 1
        for f in isla:
            f.material_index = 0
            for lazo in f.loops:
                lazo[capa].uv = celda(CELDAS.index(nombre))
    bm.to_mesh(me)
    bm.free()
    me.uv_layers.remove(me.uv_layers["UVMap"])  # Roblox lee una sola capa
    me.materials.clear()
    me.materials.append(material)
    pie.modifiers.clear()
    print("ZAPATILLA", pie.name, "materiales", len(me.materials), "uv", len(me.uv_layers), "piezas", conteo)


def main():
    bpy.ops.wm.open_mainfile(filepath=os.path.join(ARTE, "blender", "cuerpo-comic.blend"))
    carpeta = os.path.join(ARTE, "blender", "texturas", "zapatillas")
    os.makedirs(carpeta, exist_ok=True)
    img = textura(os.path.join(carpeta, "Zapatillas_color.png"))
    material = bpy.data.materials.new("Zapatillas_Textura")
    material.use_nodes = True
    nodos = material.node_tree
    tex = nodos.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Closest"
    nodos.links.new(tex.outputs["Color"], nodos.nodes["Principled BSDF"].inputs["Base Color"])
    pies = [bpy.data.objects[f"Cuerpo_{n}Foot"] for n in ("Left", "Right")]
    for pie in pies:
        pasar_a_textura(pie, material)

    for o in list(bpy.data.objects):
        if o.type == "LIGHT" or o.name == "Niebla":
            bpy.data.objects.remove(o)
    e = bpy.context.scene
    e.render.engine = "BLENDER_EEVEE"
    e.view_settings.view_transform = "Standard"
    w = bpy.data.worlds.new("Fondo")
    w.use_nodes = True
    w.node_tree.nodes["Background"].inputs[0].default_value = (0.1, 0.12, 0.17, 1)
    w.node_tree.nodes["Background"].inputs[1].default_value = 1.4
    e.world = w
    bpy.ops.object.camera_add()
    cam = bpy.context.object
    cam.data.type, cam.data.ortho_scale = "ORTHO", 0.8
    e.camera = cam
    bpy.ops.object.light_add(type="SUN", location=(-2, -4, 5))
    sol = bpy.context.object
    sol.data.energy = 3
    sol.rotation_euler = (0.8, 0, -0.4)
    e.render.resolution_x, e.render.resolution_y = 480, 400
    for giro, v in ((0, "frente"), (45, "tres"), (90, "costado"), (180, "atras")):
        a = math.radians(giro)
        cam.location = (-5 * math.sin(a), -5 * math.cos(a), 1.0)
        cam.rotation_euler = (Vector((0, 0, 0.15)) - cam.location).to_track_quat("-Z", "Y").to_euler()
        e.render.filepath = os.path.join(ARTE, "renders", f"zapatillas-{v}.png")
        bpy.ops.render.render(write_still=True)

    bpy.ops.object.select_all(action="DESELECT")
    for o in pies:
        o.hide_viewport = False
        o.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(ARTE, "exports", "cuerpo-comic", "Zapatillas.fbx"),
        use_selection=True,
        object_types={"MESH"},
        use_mesh_modifiers=False,
        global_scale=1 / 0.28,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
    )


main()
