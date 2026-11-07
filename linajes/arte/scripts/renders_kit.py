"""Renders del kit con el color final, para aprobar.
Uso: blender -b --factory-startup -P linajes/arte/scripts/renders_kit.py -- <carpeta>
"""
import math
import os
import sys

import bpy
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import base as B  # noqa: E402

carpeta = sys.argv[sys.argv.index("--") + 1]
TINTES = [
    ("Contenedor", "Contenedor rojo", "#a8342c"),
    ("Contenedor", "Contenedor azul", "#2c5f92"),
    ("Contenedor", "Contenedor verde", "#35785c"),
    ("Contenedor", "Contenedor gris", "#7c838c"),
    ("Prop_Barril", "Barril", "#2f6288"),
    ("Prop_Bita", "Bita", "#3a4048"),
    ("Galpon_Techo", "Techo de chapa", "#a4aab0"),
    ("Prop_Cajones", "Cajones", "#ffffff"),
    ("Prop_Cartel", "Cartel", "#ffffff"),
    ("Prop_MuroLadrillo", "Muro de ladrillo", "#ffffff"),
]

bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, "arena-kit2.blend"))
escena = bpy.context.scene
for o in list(escena.objects):
    if o.type in {"LIGHT", "CAMERA"}:
        bpy.data.objects.remove(o)
    else:
        o.hide_render = True
mundo = bpy.data.worlds.new("Hoja")
mundo.use_nodes = True
mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.34, 0.38, 0.45, 1)
escena.world = mundo
sol = bpy.data.objects.new("Sol", bpy.data.lights.new("Sol", "SUN"))
sol.data.energy = 3.2
sol.rotation_euler = (math.radians(52), 0, math.radians(40))
escena.collection.objects.link(sol)
cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
escena.collection.objects.link(cam)
escena.camera = cam
escena.render.resolution_x = escena.render.resolution_y = 640
escena.view_settings.view_transform = "Standard"


def tenir(o, hexa):
    mat = o.data.materials[0].copy()
    o.data.materials[0] = mat
    nodos = mat.node_tree
    bsdf = nodos.nodes["Principled BSDF"]
    origen = bsdf.inputs["Base Color"].links[0].from_socket
    mezcla = nodos.nodes.new("ShaderNodeMixRGB")
    mezcla.blend_type = "MULTIPLY"
    mezcla.inputs[0].default_value = 1
    c = [(int(hexa[i:i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)]
    mezcla.inputs[2].default_value = (*c, 1)
    nodos.links.new(origen, mezcla.inputs[1])
    nodos.links.new(mezcla.outputs[0], bsdf.inputs["Base Color"])


for i, (nombre, titulo, hexa) in enumerate(TINTES):
    o = bpy.data.objects[nombre].copy()
    o.data = bpy.data.objects[nombre].data.copy()
    escena.collection.objects.link(o)
    tenir(o, hexa)
    o.hide_render = False
    esquinas = [o.matrix_world @ Vector(c) for c in o.bound_box]
    centro = sum(esquinas, Vector()) / 8
    radio = max((c - centro).length for c in esquinas)
    cam.location = centro + Vector((0.95, -0.8, 0.45)).normalized() * radio * 2.7
    cam.rotation_euler = (centro - cam.location).to_track_quat("-Z", "Y").to_euler()
    escena.render.filepath = os.path.join(carpeta, f"{i + 1:02d} {titulo}.png")
    bpy.ops.render.render(write_still=True)
    o.hide_render = True
