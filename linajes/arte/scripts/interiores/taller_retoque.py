"""Retoques sobre el .blend ya horneado (sin volver a hornear): gancho de la hoja de objetos, barrotes de la
cama y silueta repintada en el panel del gancho."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import taller as T  # noqa: E402

B.MATERIALES.update(T.MATS)
for o in list(bpy.data.objects):
    if o.name.startswith(("Gancho", "Neon_Gancho", "Cama_Barrotes")) and o.name != "GanchoPanel":
        bpy.data.objects.remove(o)
T.gancho_tano(-9.5, 8.0)
T.cama_barrotes()
print("PINTADAS", T.pintar_taller(solo=("GanchoPanel",)))
cruces, flotan = T.revisar([o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith(("Lluvia", "Niebla", "Maniqui"))])
print("CHEQUEO", cruces, flotan)
print("TRIS", sum(len(o.data.polygons) for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith(("Lluvia", "Niebla", "Maniqui"))))
bpy.ops.wm.save_mainfile()
