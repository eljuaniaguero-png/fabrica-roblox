"""Exporta Fuerza Bruta a JSON para armar KeyframeSequences en Studio (como roblox.py)."""

import importlib.util
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))


def cargar(nombre, archivo):
    spec = importlib.util.spec_from_file_location(nombre, os.path.join(AQUI, archivo))
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


R = cargar("anim_roblox", "roblox.py")
F = cargar("anim_fb", "linaje-fuerzabruta.py")
R.A = F.A
R.exportar(sys.argv[sys.argv.index("--") + 1])
