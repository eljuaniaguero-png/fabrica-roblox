"""Un solo FBX con las piezas del puerto que usa la arena del sandbox.
Uso: blender -b --factory-startup -P linajes/arte/scripts/paquete_arena.py
"""
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import base as B  # noqa: E402

NOMBRES = [
    "Contenedor_Azul", "Contenedor_Gris", "Contenedor_Rojo", "Contenedor_Verde",
    "Prop_Barril", "Prop_Cajones", "Prop_Farola", "Prop_Bita", "Prop_MuroLadrillo",
    "Prop_MuroRemate", "Prop_Alambrado", "Prop_Reja", "Prop_Poste", "Prop_Cartel", "Prop_Red",
    "Grua_Estructura", "Grua_Cabina", "Galpon_Pared", "Galpon_ParedPorton", "Galpon_Techo",
]

bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, "puerto-oxido.blend"))
objs = []
for n in NOMBRES:
    o = bpy.data.objects.get(n)
    if o is None or o.type != "MESH":
        print("FALTA", n, [x.name for x in bpy.data.objects if x.name.startswith(n)][:4])
    else:
        objs.append(o)
for o in bpy.context.scene.objects:
    o.select_set(False)
for o in objs:
    o.hide_viewport = o.hide_render = False
    o.hide_set(False)
    o.select_set(True)
    print("OK", o.name, len(o.data.polygons), [round(d, 1) for d in o.dimensions])
bpy.context.view_layer.objects.active = objs[0]
ruta = os.path.join(B.EXPORTS, "puerto-oxido", "_PaqueteArena.fbx")
bpy.ops.export_scene.fbx(
    filepath=ruta, use_selection=True, object_types={"MESH"}, global_scale=1 / B.STUD,
    apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS", axis_forward="Z", axis_up="Y",
    bake_space_transform=True, use_mesh_modifiers=True, mesh_smooth_type="FACE",
    add_leaf_bones=False, bake_anim=False, path_mode="COPY", embed_textures=True,
)
print("Paquete:", ruta, len(objs))
