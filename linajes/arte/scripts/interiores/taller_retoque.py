"""Rehace en el .blend ya horneado las garras del gancho y el trapo colgado (sin volver a hornear todo)."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import taller as T  # noqa: E402

B.MATERIALES.update(T.MATS)
for n in ("Gancho_Garras", "Banco_Trapo", "Banco_TrapoBollo"):
    if n in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[n])
T.garras_gancho(-9.5 + 1.7, T.HY - T.G - 1.4, 8.0)
T.trapos()
cruces, flotan = T.revisar([o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith(("Lluvia", "Niebla", "Maniqui"))])
print("CHEQUEO", cruces, flotan)
bpy.ops.wm.save_mainfile()
