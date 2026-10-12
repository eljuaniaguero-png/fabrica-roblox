"""Pasa las mallas del contorno toon (export/Toon/CascosToon.obj, de toon_base.py) a un FBX con
una malla por objeto: Studio junta en una sola malla todo lo que viene en un OBJ, y el FBX lo
importa por separado (CascoEsfera, CascoCaja, CascoCilindro y CascoCunia).

Corre en Blender sin abrir la ventana, así no toca la escena que esté abierta:
    "C:\\Program Files\\Blender Foundation\\Blender 5.2\\blender.exe" -b --factory-startup ^
        --python mutant-lab/arte/scripts/toon_fbx.py

Los ejes ida y vuelta son los mismos que usa comun.py, así las mallas llegan a Roblox como están
en el OBJ (el cilindro a lo largo de X y la cuña alta hacia +Z, como las Part de Roblox).
"""

import os

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))
CARPETA = os.path.join(AQUI, "..", "export", "Toon")
OBJ = os.path.join(CARPETA, "CascosToon.obj")
FBX = os.path.join(CARPETA, "_PaqueteToon.fbx")
NOMBRES = {"CascoEsfera", "CascoCaja", "CascoCilindro", "CascoCunia"}

bpy.ops.wm.read_factory_settings(use_empty=True)
# El OBJ está en ejes de Roblox (Y arriba, frente a -Z): Blender lo pasa a los suyos (Z arriba).
bpy.ops.wm.obj_import(filepath=OBJ, forward_axis="NEGATIVE_Z", up_axis="Y")

objetos = [o for o in bpy.context.scene.objects if o.type == "MESH"]
nombres = {o.name for o in objetos}
if nombres != NOMBRES:
    raise SystemExit(f"Esperaba {sorted(NOMBRES)} y llegaron {sorted(nombres)}")
for o in objetos:
    o.data.name = o.name
    o.select_set(True)

bpy.ops.export_scene.fbx(
    filepath=FBX,
    use_selection=True,
    object_types={"MESH"},
    global_scale=1.0,
    apply_unit_scale=True,
    apply_scale_options="FBX_SCALE_UNITS",
    axis_forward="Z",
    axis_up="Y",
    bake_space_transform=True,
    mesh_smooth_type="FACE",
    add_leaf_bones=False,
    bake_anim=False,
)
print("Listo:", FBX)
