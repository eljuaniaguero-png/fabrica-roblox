"""Renders del escritorio de Tano: desde la cámara del juego, de cerca, de costado (profundidad del monitor) y la silla."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import taller as T  # noqa: E402

print("RENDER", T.camara(T.ARCHIVO + "_rincon_ref7", (11.2, 12.2, 6.9), (17.2, 8.4, 3.0), lente=24))
print("RENDER", T.camara(T.ARCHIVO + "_silla_costado", (14.6, 4.2, 1.9), (14.6, 8.7, 1.4), lente=30))
print("RENDER", T.camara(T.ARCHIVO + "_silla_arriba", (14.62, 8.75, 6.6), (14.6, 8.7, 0.0), lente=28, ocultar=("Silla_Asiento", "Silla_Respaldo")))
print("RENDER", T.camara(T.ARCHIVO + "_monitor_costado", (17.8, 4.6, 5.0), (17.8, 8.4, 4.5), lente=30))
print("RENDER", T.camara(T.ARCHIVO + "_escritorio_camara_juego", (5.5, 9, 7.2), (17.0, 9, 3.4), lente=24, niebla=True))
