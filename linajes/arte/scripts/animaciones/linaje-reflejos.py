"""Animaciones de Reflejos (P27-02), Variante Normal, con el motor de base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/linaje-reflejos.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; después: gifs.py y hoja.py reflejos)

Regla del Linaje: rápido y liviano, al revés que Fuerza Bruta.
"""

import importlib.util
import os
import shutil
import sys

_spec = importlib.util.spec_from_file_location("anim_base", os.path.join(os.path.dirname(os.path.abspath(__file__)), "base.py"))
A = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(A)

import bpy  # noqa: E402

G = A.GUARDIA
con, actuar, pasarse, onda = A.con, A.actuar, A.pasarse, A.onda

A.BLEND = os.path.join(A.B.BLENDER, "animaciones-linajes.blend")
A.SALIDA_FBX = os.path.join(A.B.ARTE, "animaciones", "linaje-reflejos")


def contragolpe(t):
    # Dos tiempos: manotazo afuera con el cuerpo corrido a un costado (0,15 s) y un gancho corto
    # a las costillas en 3 cuadros (Impacto 8). Lo que cambia respecto del jab: brazo doblado.
    desvia = con(
        G,
        raiz=(-0.15, 0.03, -0.17),
        LowerTorso=(8, -10, -30),
        UpperTorso=(4, -6, -22),
        Head=(6, 8, 26),
        LeftUpperArm=(-100, -46, -8),
        LeftLowerArm=(-78, 0, 0),
        RightUpperArm=(-20, -14, 18),
        RightLowerArm=(-140, 0, 0),
    )
    gancho = con(
        G,
        raiz=(-0.05, -0.1, -0.2),
        LowerTorso=(14, 6, -4),
        UpperTorso=(8, 0, 46),
        Head=(8, 0, -14),
        LeftUpperArm=(-60, 18, -16),
        RightUpperArm=(-52, 44, 90),
        RightLowerArm=(-90, 0, 0),
    )
    return actuar(t, 18, [(0, G), (5, desvia, "seco"), (8, gancho, "seco"), (10, pasarse(desvia, gancho, 0.06), "sale"), (18, G)], {})


def paso_fantasma(t):
    # 0,3 s: se agacha, desaparece, y reaparece ya en guardia. El efecto lo pone el código.
    agacha = con(
        G,
        raiz=(0, 0.04, -0.3),
        LowerTorso=(28, 0, -20),
        UpperTorso=(10, 0, 0),
        Head=(-12, 0, 12),
        LeftUpperArm=(14, 18, 0),
        RightUpperArm=(14, -18, 0),
        LeftLowerArm=(-50, 0, 0),
        RightLowerArm=(-50, 0, 0),
        LeftUpperLeg=(-62, -6, 20),
        RightUpperLeg=(-24, 6, 20),
        LeftLowerLeg=(90, 0, 0),
        RightLowerLeg=(84, 0, 0),
    )
    return actuar(t, 9, [(0, G), (3, agacha, "seco"), (5, agacha), (6, pasarse(agacha, G, 0.08), "seco"), (9, G, "sale")], {})


def _pina(lado):
    """Recto bien estirado. lado 1 = derecha, -1 = izquierda; hombros y cadera giran con él."""
    pose = con(
        G,
        raiz=(0, -0.13, -0.15),
        LowerTorso=(16, 0, -20 + 14 * lado),
        UpperTorso=(4, 0, 38 * lado),
        Head=(6, 0, 12 - 30 * lado),
        LeftUpperLeg=(-40, -6, 20 - 14 * lado),
        RightUpperLeg=(14, 6, 20 - 14 * lado),
        LeftLowerLeg=(64, 0, 0),
        RightLowerLeg=(40, 0, 0),
    )
    if lado > 0:
        return con(pose, RightUpperArm=(-90, 2, -8), RightLowerArm=(0, 0, 0), LeftUpperArm=(-30, 20, -16), LeftLowerArm=(-135, 0, 0))
    return con(pose, LeftUpperArm=(-90, -2, 8), LeftLowerArm=(0, 0, 0), RightUpperArm=(-30, -20, 16), RightLowerArm=(-135, 0, 0))


GOLPES_LLUVIA = (3, 8, 13, 18, 23, 28)


def lluvia_de_golpes(t):
    # Loop de 1 s: 6 piñas alternadas, 5 cuadros cada una. Empieza y termina en la misma pose.
    medio = {n: tuple((x + y) / 2 for x, y in zip(_pina(1)[n], _pina(-1)[n])) for n in _pina(1) if not n.startswith("_")}
    claves = [(0, medio)]
    for i, f in enumerate(GOLPES_LLUVIA):
        claves.append((f, _pina(1 if i % 2 == 0 else -1), "seco"))
    claves.append((30, medio, "sale"))
    return actuar(t, 30, claves, {})


def cargar_poder(t):
    # Rebota en las puntas de los pies como un boxeador: puños sueltos y cabeza que vigila.
    # Todo es periódico en t: el loop cierra sin salto.
    rebote = onda(t * 2)
    lado = onda(t)
    return {
        "raiz": (0.03 * lado, 0, -0.07 + 0.035 * rebote),
        "LowerTorso": (5, 0, -14 + 6 * lado),
        "UpperTorso": (3 - 2 * rebote, 0, 7 * lado),
        "Head": (8, 0, 14 - 22 * onda(t, 0.2)),
        "LeftUpperArm": (-28 + 4 * rebote, 22, -14),
        "RightUpperArm": (-26 - 4 * rebote, -22, 14),
        "LeftLowerArm": (-88 + 7 * lado, 0, 0),
        "RightLowerArm": (-88 - 7 * lado, 0, 0),
        "LeftUpperLeg": (-24 - 5 * rebote, -5, 14),
        "RightUpperLeg": (-8 - 5 * rebote, 5, 14),
        "LeftLowerLeg": (38 - 9 * rebote, 0, 0),
        "RightLowerLeg": (32 - 9 * rebote, 0, 0),
        "LeftFoot": (10 + 8 * rebote, 0, 0),
        "RightFoot": (10 + 8 * rebote, 0, 0),
    }


def cargar_inicio(t):
    return actuar(t, 8, [(0, G), (8, cargar_poder(0.0), "sale")], {})


NUEVAS = {
    "reflejos-contragolpe": (contragolpe, 18, False, "Action", (5, 8, 13)),
    "reflejos-paso-fantasma": (paso_fantasma, 9, False, "Action", (3, 6, 9)),
    "reflejos-lluvia-golpes": (lluvia_de_golpes, 30, True, "Action", (3, 8, 13)),
    "reflejos-cargar-inicio": (cargar_inicio, 8, False, "Action", (0, 4, 8)),
    "reflejos-cargar-loop": (cargar_poder, 30, True, "Action", (0, 7, 22)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["reflejos"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "reflejos-contragolpe": "Z Contragolpe",
        "reflejos-paso-fantasma": "X Paso/fantasma",
        "reflejos-lluvia-golpes": "C Lluvia/de golpes",
        "reflejos-cargar-inicio": "Cargar/inicio",
        "reflejos-cargar-loop": "Cargar/loop",
    }
)
A.MARCADORES.update(
    {
        "reflejos-contragolpe": [(8, "Impacto")],
        "reflejos-paso-fantasma": [(3, "Desaparece"), (6, "Aparece")],
        "reflejos-lluvia-golpes": [(f, "Impacto") for f in GOLPES_LLUVIA],
    }
)
A.GIRO_CAMARA.update({n: 60 for n in NUEVAS})
A.B.LENTE *= 0.8
A.GIF_VISTAS.update({n: {"costado": 90, "atras": 135} for n in NUEVAS})


def acciones():
    """Parte del cuerpo actual y conserva las acciones que ya estaban (otros Linajes)."""
    bpy.ops.wm.open_mainfile(filepath=A.CUERPO)
    copia = A.BLEND + ".leer.blend"  # Blender no deja pisar un archivo del que acaba de leer
    shutil.copyfile(A.BLEND, copia)
    with bpy.data.libraries.load(copia) as (origen, destino):
        destino.actions = [a for a in origen.actions if not a.startswith("reflejos")]
    for accion in bpy.data.actions:
        accion.use_fake_user = True
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
        print(f"CRUCES {nombre}: {A.chequear_cruces(arm, nombre)[:6]}")
    arm.animation_data.action = bpy.data.actions["reflejos-cargar-loop"]
    bpy.ops.wm.save_as_mainfile(filepath=A.BLEND)
    os.remove(copia)


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        A.renders("reflejos")
    if paso in ("gifs", "todo"):
        A.cuadros_gif("reflejos")
    if paso in ("fbx", "todo"):
        A.fbx("reflejos")
