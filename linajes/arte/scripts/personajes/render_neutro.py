"""Render de control con luz neutra (blanca y pareja) de un personaje ya terminado.

En el juego no hay contraluz naranja: este render muestra los colores como se van a leer.
No guarda el .blend (solo cambia luces en memoria).

Uso:
    <blender.exe> -b -P linajes/arte/scripts/personajes/render_neutro.py -- <archivo.blend> <nombre>
Sale en renders/<nombre>_neutra_vistas.png.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402

argumentos = sys.argv[sys.argv.index("--") + 1 :]
archivo, nombre = argumentos[0], argumentos[1]
bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, archivo))
for luz, fuerza in (("LuzBorde", 0.4), ("LuzPrincipal", 1.6), ("LuzRelleno", 1.6)):
    o = bpy.data.objects.get(luz)
    if o:
        o.data.color = (1.0, 1.0, 1.0)
        o.data.energy *= fuerza
# Solo el personaje: el maniquí y lo que cuelga de él (la caja de niebla y el piso arruinan el encuadre).
visibles = B.partes() + [
    o for o in bpy.data.objects
    if o.type == "MESH" and o.parent is not None and not o.hide_render and o not in B.partes() and not o.name.endswith("_Alto")
]
print("Neutra:", B.render_vistas(f"{nombre}_neutra", visibles))
