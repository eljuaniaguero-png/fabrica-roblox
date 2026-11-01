"""Pasa las animaciones de base.py a datos para armar KeyframeSequences en Studio (sin importar
FBX a mano): un JSON por animación con, cada 2 cuadros, el CFrame de cada articulación del R15
(Motor6D.Transform: posición en studs y giro, en los ejes de Roblox).

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/roblox.py -- <carpeta>

Después, por MCP, Studio lee cada JSON y arma la KeyframeSequence (Loop, Priority y marcadores
Paso incluidos). Usa las mismas funciones de pose que el FBX, así que salen iguales.
"""

import json
import math
import os
import sys

import importlib.util  # noqa: E402

# animaciones/base.py se carga con otro nombre: "base" ya es el kit de scripts/base.py.
_spec = importlib.util.spec_from_file_location("anim_base", os.path.join(os.path.dirname(os.path.abspath(__file__)), "base.py"))
A = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(A)

from mathutils import Euler, Matrix, Vector  # noqa: E402

STUD = A.B.STUD
_CAMBIO = Matrix(((-1, 0, 0), (0, 0, 1), (0, 1, 0)))  # Blender (Z arriba) -> Roblox (Y arriba)


def _roblox(v):
    return [round(x, 4) for x in (_CAMBIO @ Vector(v)) / STUD]


def articulaciones(pose):
    """{Parte: [x, y, z, r00, r01, ..., r22]} para cada parte del R15."""
    out = {}
    for parte in A.B.HUESOS:
        x, y, z = pose.get(parte, (0, 0, 0))
        giro = Euler((math.radians(x), math.radians(y), math.radians(z)), "ZYX").to_matrix()
        r = _CAMBIO @ giro @ _CAMBIO
        p = [0.0, 0.0, 0.0]
        if parte == "LowerTorso":
            p = _roblox(pose.get("raiz", (0, 0, 0)))
        elif parte in ("LeftUpperArm", "RightUpperArm") and "_hombros" in pose:
            p = _roblox((0, 0, pose["_hombros"]))
        out[parte] = p + [round(r[i][j], 5) for i in range(3) for j in range(3)]
    return out


def exportar(carpeta):
    os.makedirs(carpeta, exist_ok=True)
    for nombre, (funcion, cuadros, loop, prioridad, _) in A.ANIMACIONES.items():
        claves = []
        for f in sorted(set(list(range(0, cuadros, 2)) + [cuadros])):
            t = 0.0 if (loop and f == cuadros) else f / cuadros
            claves.append({"t": round(f / A.FPS, 4), "j": articulaciones(funcion(t))})
        datos = {
            "nombre": nombre,
            "loop": loop,
            "prioridad": prioridad,
            "marcadores": [[round(f / A.FPS, 4), "Paso"] for f in A.PASOS.get(nombre, ())],
            "claves": claves,
        }
        with open(os.path.join(carpeta, f"{nombre}.json"), "w", encoding="utf-8") as fh:
            json.dump(datos, fh, separators=(",", ":"))


if __name__ == "__main__":
    exportar(sys.argv[sys.argv.index("--") + 1])
