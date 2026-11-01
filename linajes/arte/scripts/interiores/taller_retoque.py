"""Retoque sobre el .blend ya horneado (sin volver a hornear): escritorio de Tano nuevo (compu de tubo, torre,
teclado, mouse, lámpara articulada, taza, papeles, destornillador) y silla de oficina vieja."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
from mathutils import Matrix  # noqa: E402
import taller as T  # noqa: E402

B.MATERIALES.update(T.MATS)
T.escritorio_tano_reemplazar(())
for o in list(bpy.data.objects):
    if o.name.startswith(("Compu_", "Neon_Compu", "Silla_", "MesaFabricacion_Manijas")):
        bpy.data.objects.remove(o)
T.escritorio_tano()
luz = bpy.data.objects.get("LuzFabricar")
if luz:
    a, b = T.P.S(16.85, 9.85, 4.6), T.P.S(16.65, 9.4, 3.3)
    luz.matrix_world = Matrix.Translation(a) @ (b - a).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    luz.data.energy = 220
mallas = [o for o in bpy.data.objects if o.type == "MESH" and not o.hide_render and not o.name.startswith(("Lluvia", "Niebla", "Maniqui"))]
cruces, flotan = T.revisar(mallas)
print("CHEQUEO", cruces, flotan)
bpy.ops.wm.save_mainfile()
print("RENDER", T.camara(T.ARCHIVO + "_escritorio_camara_juego", (5.5, 9, 7.2), (17.0, 9, 3.4), lente=24, niebla=True))
print("RENDER", T.camara(T.ARCHIVO + "_escritorio_cerca", (12.5, 6.5, 5.2), (17.5, 9, 3.8), lente=26))
