"""Primeros planos de objetos, piso y paredes del taller (sin volver a hornear).

Uso:
    <blender.exe> -b --factory-startup linajes/arte/blender/interior-taller.blend -P linajes/arte/scripts/interiores/taller_cerca.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lugares"))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

import taller as T  # noqa: E402

E = T.ENTREPISO
VISTAS = [
    # (archivo, desde, hacia, lente)
    ("pp01_computadora", (13.8, 7.6, 4.6), (17.6, 9.2, 4.2), 30),
    ("pp02_silla", (12.2, 5.6, 4.0), (14.6, 9.0, 1.9), 26),
    ("pp03_lampara_escritorio", (14.2, 8.0, 5.6), (17.0, 9.4, 5.0), 32),
    ("pp04_piso_manchas", (-9.0, -9.5, 4.5), (-9.0, -6.0, 0.0), 28),
    ("pp05_piso_charco_huellas", (-7.0, -16.0, 4.5), (-8.0, -11.0, 0.0), 26),
    ("pp06_piso_grietas", (2.0, 1.0, 4.0), (2.0, 4.0, 0.0), 28),
    ("pp07_pared_oxido", (-14.5, -8.5, 3.2), (-19.2, -10.5, 2.2), 30),
    ("pp08_pared_juntas", (-12.0, 4.0, 7.5), (-12.0, 15.2, 6.5), 30),
    ("pp09_motor", (-8.5, -10.0, 9.5), (-9.8, -7.0, 6.6), 30),
    ("pp10_morsa_y_latas", (0.0, 10.0, 5.2), (1.5, 13.5, 3.7), 30),
    ("pp11_engranaje_carburador", (3.5, 10.8, 5.0), (4.2, 13.3, 3.7), 32),
    ("pp12_trapo", (-0.8, 9.6, 3.6), (0.4, 12.4, 2.8), 32),
    ("pp13_tablero_trabajos", (16.0, 0.8, 5.6), (19.2, 0.8, 5.6), 34),
    ("pp14_mameluco", (14.5, 0.0, 8.5), (14.5, 3.9, 8.2), 30),
    ("pp15_cama_almohada", (16.0, 9.5, E + 4.2), (17.6, 12.8, E + 1.9), 30),
    ("pp16_radio_cajas", (13.5, 4.8, E + 3.4), (14.0, 9.6, E + 1.2), 28),
    ("pp17_tambores_bidones", (-12.0, 9.0, 3.5), (-15.5, 12.8, 1.5), 28),
    ("pp18_compresor", (10.5, -10.0, 3.5), (13.8, -13.5, 1.8), 30),
    ("pp19_rueda_y_columna", (-12.0, -9.5, 3.0), (-15.6, -6.3, 1.4), 30),
    ("pp20_calendario_reloj", (-14.0, 10.0, 9.0), (-19.2, 11.0, 8.0), 28),
]

for nombre, desde, hacia, lente in VISTAS:
    print("RENDER", T.camara(T.ARCHIVO + "_" + nombre, desde, hacia, lente=lente, niebla=False))
