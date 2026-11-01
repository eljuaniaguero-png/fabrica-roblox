"""6 renders que recorren toda la sala del taller (sin hornear de nuevo).

Uso:
    <blender.exe> -b --factory-startup linajes/arte/blender/interior-taller.blend -P linajes/arte/scripts/interiores/taller_sala.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bpy  # noqa: E402
import taller as T  # noqa: E402

VISTAS = [
    ("sala1_portón", (-12, -14, 7), (6, 10, 4), "desde el portón hacia el fondo"),
    ("sala2_esquina_sureste", (17, -13, 9), (-8, 8, 3), "desde la puerta lateral: auto, banco y entrepiso"),
    ("sala3_fondo", (-2, 13, 9), (-2, -12, 4), "desde el banco hacia el portón"),
    ("sala4_esquina_noroeste", (-17, 13, 10), (10, -8, 3), "desde los tambores: compresor, locker y entrepiso"),
    ("sala5_entrepiso", (14, 8, ENT := T.ENTREPISO + 4.5), (-10, -4, 4), "desde arriba del entrepiso"),
    ("cerca_banco", (2, 7, 7), (3, 15, 5), "el banco con la lámpara chica"),
    ("cerca_motor", (-6, -13, 13), (-10, -7, 7), "el motor con el capó abierto"),
    ("cerca_gancho", (-8, 3, 8), (-9.5, 15, 8), "el gancho en su panel"),
]

for nombre, desde, hacia, _ in VISTAS:
    ruta = T.camara(T.ARCHIVO + "_" + nombre, desde, hacia, lente=24 if nombre.startswith("cerca") else 14, niebla=True)
    print("RENDER", ruta)

# vista aérea sin techo (las cerchas tapaban la cámara de adentro)
sin_techo = [o for o in bpy.data.objects if o.type == "MESH" and not o.hide_render and not o.name.startswith(("Techo", "Hastial", "Cerchas", "Cables", "Lluvia", "Niebla", "Lampara", "Neon_Lampara"))]
print("RENDER", T.P.render_orto(T.ARCHIVO + "_sala6_aerea", sin_techo, giro=-35, altura=55, niebla=False, solo=True))
