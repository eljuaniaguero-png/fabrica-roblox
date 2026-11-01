"""Más renders del taller (ángulos nuevos), sin volver a hornear.

Uso:
    <blender.exe> -b --factory-startup linajes/arte/blender/interior-taller.blend -P linajes/arte/scripts/interiores/taller_mas.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bpy  # noqa: E402
import taller as T  # noqa: E402

FRENTE = ("Pared_Frente", "Porton", "Hastial_Frente", "Ondas_Frente", "Ondas_Juntas_Frente")

VISTAS = [
    ("mas01_desde_la_calle", (-10, -30, 6), (-6, 4, 5), 20, (), "desde la calle, mirando por el portón"),
    ("mas02_como_referencia", (-2, -36, 8), (-2, 0, 6.5), 15, FRENTE, "de frente sin la pared, como la referencia"),
    ("mas03_auto_costado", (-2, 2, 6), (-11, -3, 7), 18, (), "el auto de costado, con la rueda sacada"),
    ("mas04_banco_y_tablero", (2, 4, 8), (2, 15, 7), 18, (), "el banco y el tablero de frente"),
    ("mas05_escritorio", (11, 4, 5), (17, 9, 4), 22, (), "el escritorio de la compu con su lámpara"),
    ("mas06_tablero_trabajos", (13, 1, 6), (19, 1, 5.5), 24, (), "el tablero de trabajos de Tano"),
    ("mas07_cama", (13, 6, 12), (16, 13, 9), 22, (), "la cama y la radio arriba del entrepiso"),
    ("mas08_esquina_tambores", (-10, 5, 6), (-17, 12, 2), 20, (), "tambores, neumáticos y bidones"),
    ("mas09_carro_compresor", (6, -4, 5), (14, -13, 2), 20, (), "carro rojo, compresor y locker"),
    ("mas10_portón_desde_adentro", (6, 8, 7), (-10, -16, 5), 16, (), "desde el fondo hacia el portón con la lluvia"),
]

for nombre, desde, hacia, lente, ocultar, _ in VISTAS:
    print("RENDER", T.camara(T.ARCHIVO + "_" + nombre, desde, hacia, lente=lente, niebla=True, ocultar=ocultar))
