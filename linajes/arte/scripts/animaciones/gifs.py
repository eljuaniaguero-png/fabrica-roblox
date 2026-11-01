"""Junta los cuadros de renders/_gif/<nombre>/ en renders/anim-base-<nombre>.gif (a los cuadros por
segundo de fps.txt, en loop) y borra los cuadros. Se corre con Python común (necesita Pillow), después de
base.py -- gifs."""

import os
import shutil

from PIL import Image

RENDERS = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "renders")
CARPETA = os.path.join(RENDERS, "_gif")

for nombre in sorted(os.listdir(CARPETA)):
    rutas = sorted(r for r in os.listdir(os.path.join(CARPETA, nombre)) if r.endswith(".png"))
    with open(os.path.join(CARPETA, nombre, "fps.txt")) as f:
        fps = int(f.read())
    cuadros = [Image.open(os.path.join(CARPETA, nombre, r)).convert("RGB") for r in rutas]
    cuadros[0].save(
        os.path.join(RENDERS, f"anim-base-{nombre}.gif"),
        save_all=True,
        append_images=cuadros[1:],
        duration=round(1000 / fps),
        loop=0,
    )
shutil.rmtree(CARPETA)
