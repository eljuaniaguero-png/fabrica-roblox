"""Manda un personaje a la bóveda de Obsidian: modelo 3D (.glb) para girarlo en la nota y copia
de sus renders.

Uso:
    <blender.exe> -b -P linajes/arte/scripts/obsidian.py -- <personaje>     (ej.: remache)

Abre linajes/arte/blender/<personaje>.blend y escribe en linajes/boveda/04 Personajes/<Nombre>/:
- <personaje>.glb: el maniquí con todas las piezas que se ven en el render (texturas en JPEG para
  que pese poco). Lo muestra el complemento "Embed 3D" de Obsidian con un bloque ```3D.
- renders/: las imágenes de renders/<personaje>_*.png (sin las de prueba, que empiezan con "_").
La nota del personaje (<Nombre>.md) la escribe Claude; este script solo deja los archivos.
"""

import glob
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import bpy  # noqa: E402

BOVEDA = os.path.join(os.path.dirname(B.ARTE), "boveda", "04 Personajes")
# Archivo .blend -> nombre de la carpeta y la nota (si falta, se usa el archivo con mayúscula).
NOMBRES = {
    "cuervo": "Cuervo",
    "centinela": "Centinela Solar",
    "mascarada": "Mascarada",
    "remache": "Remache",
    "estela": "Estela",
    "atalanta": "Atalanta",
    "arquitecto": "Arquitecto",
    "bastion": "Bastión",
    "heredero": "Heredero Abisal",
    "halden": "Víctor Halden",
    "albatros": "El Albatros",
    "zarpa": "Zarpa",
    "confeti": "Confeti",
    "dualidad": "Dualidad",
    "gorrion": "Gorrión",
    "eclipsador": "El Eclipsador",
    "cuerpo": "Cuerpo propio",
    "npc-tano": "Tano",
    "enemigo-maton": "Matón del puerto",
    "enemigo-maton-implantes": "Matón con implantes",
}


def carpeta(personaje):
    return os.path.join(BOVEDA, NOMBRES.get(personaje, personaje.title()))


def piezas_visibles():
    """Mallas del personaje y del maniquí que salen en el render (sin copias de alto poligonaje,
    niebla ni maniquíes de comparación)."""
    fuera = ("Niebla", "Comparar_")
    return [
        o
        for o in bpy.context.scene.objects
        if o.type == "MESH" and not o.hide_render and not o.name.endswith("_Alto") and not o.name.startswith(fuera)
    ]


def exportar_glb(personaje):
    bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, personaje + ".blend"))
    objs = piezas_visibles()
    for o in bpy.context.scene.objects:
        o.hide_viewport = o.hide_viewport and o not in objs
        o.select_set(o in objs)
    bpy.context.view_layer.objects.active = objs[0]
    destino = carpeta(personaje)
    os.makedirs(destino, exist_ok=True)
    ruta = os.path.join(destino, personaje + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=ruta,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_image_format="JPEG",
        export_jpeg_quality=80,
        export_animations=False,
        export_lights=False,
        export_cameras=False,
    )
    return ruta


def copiar_renders(personaje):
    destino = os.path.join(carpeta(personaje), "renders")
    os.makedirs(destino, exist_ok=True)
    copiadas = []
    for r in sorted(glob.glob(os.path.join(B.RENDERS, personaje + "_*.png"))):
        shutil.copy2(r, destino)
        copiadas.append(os.path.basename(r))
    return copiadas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    for p in argumentos:
        print("GLB:", exportar_glb(p), round(os.path.getsize(os.path.join(carpeta(p), p + ".glb")) / 1e6, 1), "MB")
        print("Renders:", copiar_renders(p))
