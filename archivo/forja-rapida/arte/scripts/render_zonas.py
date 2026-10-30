"""Renders por zona, separados: las 12 piedras que te pueden tocar (gemas.py) y las 5 geodas que
se rompen (rocas.py). Salen en arte/renders/zona<N>_piedras.jpg y arte/renders/zona<N>_geodas.jpg.

Uso (desde la raíz del repositorio):
  blender -b --factory-startup --python forja-rapida/arte/scripts/render_zonas.py -- [zonas...]
Sin zonas, hace las 5.
"""

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402

import gemas as G  # noqa: E402
import modelos as M  # noqa: E402
import rocas as R  # noqa: E402

NOMBRES_ZONA = {1: "Pradera", 2: "Dunas", 3: "Glaciar", 4: "Volcán", 5: "Abismo"}


def camara_orto(escena, ancho, centro, elevacion):
    """Cámara ortográfica casi de frente: todo se ve del mismo tamaño."""
    cam = bpy.data.cameras.new("Camara")
    cam.type = "ORTHO"
    cam.sensor_fit = "HORIZONTAL"
    cam.ortho_scale = ancho
    obj = bpy.data.objects.new("Camara", cam)
    escena.collection.objects.link(obj)
    obj.location = (centro[0], centro[1] - 40 * math.cos(elevacion), centro[2] + 40 * math.sin(elevacion))
    obj.rotation_euler = (math.pi / 2 - elevacion, 0, 0)
    escena.camera = obj


def rotulo(texto, x, y, elevacion, tam=0.13):
    t = M.etiqueta(texto, x, y, z=0.05, tam=tam, color="#1B1F3B")
    t.rotation_euler.x = math.pi / 2 - elevacion
    t.visible_shadow = False


def piedras(zona):
    """Las 12 piedras de la zona en 2 filas de 6, de Común a Celestial (en studs reales)."""
    M.limpiar_escena()
    nombres = [n for n, d in G.PIEDRAS.items() if d[0] == zona]
    paso_x, paso_y, elevacion = 1.6, 4.5, math.radians(32)
    ancho = 6 * paso_x + 0.4
    escena = M.escena_render(1800, round(1800 * (paso_y * math.sin(elevacion) + 2.6) / ancho))
    for i, n in enumerate(nombres):
        fila, col = divmod(i, 6)
        x, y = (col - 2.5) * paso_x, (0.5 - fila) * paso_y
        objs, tri, _ = G.armar(n)
        M.mover(objs, x, y, giro=math.radians(-20))
        rotulo(n, x, y - 0.8, elevacion, tam=0.15)  # el orden marca la rareza: de Común a Celestial
    camara_orto(escena, ancho, (0, -0.5, 0.55), elevacion)
    M.render(f"zona{zona}_piedras")


def geodas(zona):
    """Las 5 geodas de la zona (tamaño Mediana) en una fila, con sus colores del juego."""
    M.limpiar_escena()
    paso_x, elevacion = 2.0, math.radians(24)
    ancho = 5 * paso_x + 0.6
    escena = M.escena_render(1800, round(1800 * 3.2 / ancho))
    datos = M.GEODAS["Mediana"]
    for z, v, est in R.variantes():
        if z != zona:
            continue
        x = (v - 3) * paso_x
        objs = R.armar(f"{z}.{v} {est['nombre']}", datos, est, R.mats_de(est), R.semilla_de(datos, z, v))
        objs = M.sin_grietas(objs)
        M.mover(objs, x, 0)
        rotulo(est["nombre"], x, -1.15, elevacion, tam=0.22)
    camara_orto(escena, ancho, (0, -0.5, 0.8), elevacion)
    M.render(f"zona{zona}_geodas")


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    for zona in [int(a) for a in args] or list(NOMBRES_ZONA):
        piedras(zona)
        geodas(zona)
    print("Listo")
