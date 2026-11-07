"""Exporta Remache a JSON para armar KeyframeSequences (como roblox.py).

Abre el .blend antes: en_el_piso necesita el modelo para medir las botas.
"""

import importlib.util
import os
import sys

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))


def cargar(nombre, archivo):
    spec = importlib.util.spec_from_file_location(nombre, os.path.join(AQUI, archivo))
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


R = cargar("anim_roblox", "roblox.py")
F = cargar("anim_remache", "remache.py")
R.A = F.A
bpy.ops.wm.open_mainfile(filepath=F.A.BLEND)
arm = bpy.data.objects["Maniqui"]
arm.animation_data.action = None
print("ESCALA", arm.matrix_world.to_scale(), arm.matrix_world.to_euler())
R.exportar(sys.argv[sys.argv.index("--") + 1])

# El modelo está a 1,6x: en Roblox las posiciones van en studs reales, no en los del esqueleto.
import json  # noqa: E402

carpeta = sys.argv[sys.argv.index("--") + 1]
escala = arm.matrix_world.to_scale().z
for nombre in F.NUEVAS:
    ruta = os.path.join(carpeta, nombre + ".json")
    with open(ruta, encoding="utf-8") as fh:
        datos = json.load(fh)
    for clave in datos["claves"]:
        for valores in clave["j"].values():
            valores[:3] = [round(v * escala, 4) for v in valores[:3]]
    with open(ruta, "w", encoding="utf-8") as fh:
        json.dump(datos, fh, separators=(",", ":"))
