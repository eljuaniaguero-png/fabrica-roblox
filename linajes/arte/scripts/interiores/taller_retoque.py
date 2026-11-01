"""Retoque sobre el .blend ya horneado (sin volver a hornear): rincón de la compu de Tano (refs 7 y 8: silla, monitor de
tubo y lámpara articulada) con bevel, subdivisión y curvas; trapo, frazada y mameluco con simulación de tela; y
sombreado suave en todo el taller."""

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
    if o.name.startswith(("Compu_", "Neon_Compu", "Silla", "MesaFabricacion_Manijas")):
        bpy.data.objects.remove(o)
T.escritorio_tano()
for o in list(bpy.data.objects):
    if o.name.startswith("Banco_Trapo"):
        bpy.data.objects.remove(o)
T.trapos()
T.telas_simuladas()
T.retoque_general()
luz = bpy.data.objects.get("LuzFabricar")
if luz:
    a, b = T.P.S(16.35, 9.5, 4.95), T.P.S(16.65, 8.4, 3.3)
    luz.matrix_world = Matrix.Translation(a) @ (b - a).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    luz.data.energy = 220
mallas = [o for o in bpy.data.objects if o.type == "MESH" and not o.hide_render and not o.name.startswith(("Lluvia", "Niebla", "Maniqui"))]
cruces, flotan = T.revisar(mallas)
print("CHEQUEO", cruces, flotan)
bpy.ops.wm.save_mainfile()
print("TRIS silla", sum(len(p.vertices) - 2 for o in bpy.data.objects if o.name.startswith("Silla") for p in o.data.polygons))
print("RENDER", T.camara(T.ARCHIVO + "_rincon_ref7", (11.2, 12.2, 6.9), (17.2, 8.4, 3.0), lente=24))
print("RENDER", T.camara(T.ARCHIVO + "_silla_costado", (14.6, 4.2, 1.9), (14.6, 8.7, 1.4), lente=30))
print("RENDER", T.camara(T.ARCHIVO + "_silla_arriba", (14.62, 8.75, 6.6), (14.6, 8.7, 0.0), lente=28, ocultar=("Silla_Asiento", "Silla_Respaldo")))
print("RENDER", T.camara(T.ARCHIVO + "_monitor_costado", (17.8, 4.6, 5.0), (17.8, 8.4, 4.5), lente=30))
print("RENDER", T.camara(T.ARCHIVO + "_escritorio_camara_juego", (5.5, 9, 7.2), (17.0, 9, 3.4), lente=24, niebla=True))
