"""Render de cada pieza del paquete de la arena, para aprobarlas.
Uso: blender -b --factory-startup -P linajes/arte/scripts/hoja_arena.py -- <carpeta de salida>
"""
import math
import os
import sys

import bpy
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import base as B  # noqa: E402

NOMBRES = [
    "Contenedor_Azul", "Contenedor_Gris", "Contenedor_Rojo", "Contenedor_Verde",
    "Prop_Barril", "Prop_Cajones", "Prop_Farola", "Prop_Bita", "Prop_MuroLadrillo",
    "Prop_MuroRemate", "Prop_Alambrado", "Prop_Reja", "Prop_Poste", "Prop_Cartel", "Prop_Red",
    "Grua_Estructura", "Grua_Cabina", "Galpon_Pared", "Galpon_ParedPorton", "Galpon_Techo",
]
salida = sys.argv[sys.argv.index("--") + 1]
bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, "puerto-oxido.blend"))
escena = bpy.context.scene
for o in list(escena.objects):
    if o.type in {"LIGHT", "CAMERA"}:
        bpy.data.objects.remove(o)
    else:
        o.hide_render = True
mundo = bpy.data.worlds.new("Hoja")
mundo.use_nodes = True
mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.6, 0.68, 1)
mundo.node_tree.nodes["Background"].inputs[1].default_value = 1.1
escena.world = mundo
sol = bpy.data.objects.new("Sol", bpy.data.lights.new("Sol", "SUN"))
sol.data.energy = 3.5
sol.rotation_euler = (math.radians(50), 0, math.radians(35))
escena.collection.objects.link(sol)
cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
cam.data.lens = 50
escena.collection.objects.link(cam)
escena.camera = cam
escena.render.resolution_x = escena.render.resolution_y = 420
escena.render.image_settings.file_format = "PNG"
try:
    escena.view_settings.view_transform = "Standard"
except TypeError:
    pass
for n in NOMBRES:
    o = bpy.data.objects[n]
    o.hide_render = False
    esquinas = [o.matrix_world @ Vector(c) for c in o.bound_box]
    centro = sum(esquinas, Vector()) / 8
    radio = max((c - centro).length for c in esquinas)
    direccion = Vector((0.75, -1, 0.55)).normalized()
    cam.location = centro + direccion * radio * 3.0
    cam.rotation_euler = (centro - cam.location).to_track_quat("-Z", "Y").to_euler()
    escena.render.filepath = os.path.join(salida, n + ".png")
    bpy.ops.render.render(write_still=True)
    o.hide_render = True
