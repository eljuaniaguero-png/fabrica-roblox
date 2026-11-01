"""Vuelve a renderizar el taller ya horneado (sin hornear de nuevo).

Uso:
    <blender.exe> -b linajes/arte/blender/interior-taller.blend -P linajes/arte/scripts/interiores/taller_render.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bpy  # noqa: E402
import taller as T  # noqa: E402
import base as B  # noqa: E402

B.MATERIALES.update(T.MATS)

FRENTE = ("Pared_Frente", "Porton", "Hastial_Frente", "Ondas_Frente", "Ondas_Oxido_Frente", "Ondas_Juntas_Frente")

# luz fría más suave, menos niebla y lluvia más fina (para que se vea el taller)
bpy.data.objects["LuzCalle"].data.energy = 2500
nb = bpy.data.objects.get("Niebla")
if nb:
    nb.data.materials[0].node_tree.nodes["Principled Volume"].inputs["Density"].default_value = 0.008
ll = bpy.data.objects.get("Lluvia")
if ll:
    T.lluvia_afuera(ll)
    ll.scale = (1, 1, 1)
print("CAPO", T.abrir_capo(bpy.data.objects["Auto_Carroceria"], -2, 4.6))
for n in ("Auto_Motor", "Auto_MotorFondo", "Auto_Bateria", "Auto_Mangueras"):
    if n in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[n])
T.motor(-10, -2, 4.6)
bpy.ops.wm.save_mainfile()

print("RENDER", T.camara(T.ARCHIVO + "_detalle_como_ref", (-2, -36, 8), (-2, 0, 6.5), lente=15, niebla=True, ocultar=FRENTE))
print("RENDER", T.camara(T.ARCHIVO + "_detalle_puerta", (-9, -15, 6.5), (6, 10, 4.5), lente=16, niebla=True))
print("RENDER", T.camara(T.ARCHIVO + "_detalle_auto", (-2, -12, 9), (-11, -4, 6), lente=20, niebla=True))
print("RENDER", T.camara(T.ARCHIVO + "_detalle_banco", (2, 6, 6), (4, 15, 6), lente=22))
print("RENDER", T.camara(T.ARCHIVO + "_detalle_entrepiso", (3, -6, 9), (17, 9, 7), lente=20, niebla=True))
