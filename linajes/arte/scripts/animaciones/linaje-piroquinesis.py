"""Animaciones de Piroquinesis (P27-03), Variante Normal, con el motor de base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/linaje-piroquinesis.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; después: gifs.py y hoja.py piroquinesis)

Regla del Linaje: pelea a distancia. Plantado, manos abiertas y el fuego sale de la palma.
Cadera a 20-30° con las piernas mirando al rival: el giro lo hace el torso.
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
con, actuar, pasarse = A.con, A.actuar, A.pasarse

A.BLEND = os.path.join(A.B.BLENDER, "animaciones-linajes.blend")
A.SALIDA_FBX = os.path.join(A.B.ARTE, "animaciones", "linaje-piroquinesis")


def bola_de_fuego(t):
    # Junta el fuego en la mano derecha al lado de la cadera y lo empuja de palma (Impacto 12).
    carga = con(
        G,
        raiz=(0, 0.1, -0.16),
        LowerTorso=(4, 0, -24),
        LeftUpperLeg=(-34, -6, 24),
        RightUpperLeg=(0, 6, 24),
        UpperTorso=(2, 0, -26),
        Head=(10, 0, 42),
        RightUpperArm=(24, 10, 0),
        RightLowerArm=(-92, 0, 0),
        LeftUpperArm=(-62, 12, -14),
        LeftLowerArm=(-58, 0, 0),
    )
    lanza = con(
        G,
        raiz=(0, -0.13, -0.16),
        LowerTorso=(10, 0, -20),
        UpperTorso=(6, 0, 72),
        Head=(4, 0, -56),
        RightUpperArm=(-90, 2, -8),
        RightLowerArm=(-2, 0, 0),
        LeftUpperArm=(-16, 14, 6),
        LeftLowerArm=(-118, 0, 0),
        LeftUpperLeg=(-44, -6, 20),
        RightUpperLeg=(14, 6, 20),
        LeftLowerLeg=(66, 0, 0),
        RightLowerLeg=(38, 0, 0),
    )
    queda = con(lanza, raiz=(0, -0.11, -0.16), UpperTorso=(6, 0, 62), Head=(4, 0, -46), RightUpperArm=(-80, 2, -8))
    return actuar(t, 30, [(0, G), (7, carga, "sale"), (10, pasarse(G, carga, 0.06)), (12, lanza, "seco"), (17, queda, "sale"), (30, G)], {"Head": -1})


def chorro(t):
    # Las dos palmas juntas adelante y aguanta el retroceso del lanzallamas (Impacto 16).
    junta = con(
        G,
        raiz=(0, 0.1, -0.2),
        LowerTorso=(6, 0, -20),
        UpperTorso=(2, 0, 6),
        LeftUpperArm=(-24, 24, -12),
        RightUpperArm=(-24, -24, 12),
        LeftLowerArm=(-122, 0, 0),
        RightLowerArm=(-122, 0, 0),
    )
    suelta = con(
        G,
        raiz=(0, -0.08, -0.15),
        LowerTorso=(12, 0, -20),
        UpperTorso=(4, 0, 20),
        Head=(4, 0, -2),
        LeftUpperArm=(-84, 12, 0),
        RightUpperArm=(-84, -12, 0),
        LeftLowerArm=(-8, 0, 0),
        RightLowerArm=(-8, 0, 0),
        LeftUpperLeg=(-46, -6, 20),
        RightUpperLeg=(8, 6, 20),
        LeftLowerLeg=(70, 0, 0),
        RightLowerLeg=(46, 0, 0),
    )
    atras = con(suelta, raiz=(0, -0.03, -0.145), LowerTorso=(7, 0, -20), LeftUpperArm=(-90, 12, 0), RightUpperArm=(-90, -12, 0))
    return actuar(t, 36, [(0, G), (9, junta, "sale"), (12, pasarse(G, junta, 0.06)), (16, suelta, "seco"), (20, atras, "sale"), (24, suelta), (28, atras), (36, G)], {})


def muro_de_fuego(t):
    # Se agacha y clava la palma derecha en el piso (Impacto 18); el fuego sale de ahí.
    prepara = con(
        G,
        raiz=(0, 0.04, -0.2),
        LowerTorso=(6, 0, -20),
        UpperTorso=(-4, 0, -22),
        Head=(14, 0, 30),
        RightUpperArm=(-150, -18, 0),
        RightLowerArm=(-50, 0, 0),
        LeftUpperArm=(-40, 26, -14),
    )
    clava = con(
        G,
        raiz=(0, -0.1, -0.22),
        LowerTorso=(34, 0, -20),
        UpperTorso=(16, 0, 26),
        Head=(-32, 0, -12),
        RightUpperArm=(-62, 6, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperArm=(10, 34, 0),
        LeftLowerArm=(-60, 0, 0),
        LeftUpperLeg=(-98, -8, 20),
        RightUpperLeg=(-52, 8, 20),
        LeftLowerLeg=(112, 0, 0),
        RightLowerLeg=(118, 0, 0),
        LeftFoot=(-14, 0, 0),
        RightFoot=(-20, 0, 0),
    )
    sube = con(clava, raiz=(0, -0.07, -0.19), LowerTorso=(26, 0, -20), Head=(-20, 0, -12))
    return actuar(t, 40, [(0, G), (10, prepara, "sale"), (14, pasarse(G, prepara, 0.06)), (18, clava, "seco"), (25, sube, "sale"), (40, G)], {"Head": -1})


def cargar_poder(t):
    # Plantado y tranquilo: las palmas suben como sosteniendo una llama y la cabeza se levanta.
    # Todo es coseno en t: en la unión del loop nada va rápido.
    respira = A.cos(2 * A.pi * t)
    lento = A.cos(2 * A.pi * t)
    return {
        "raiz": (0, 0, -0.022 + 0.006 * respira),
        "_hombros": 0.05 * A.B.STUD * (respira + 1) / 2,
        "LowerTorso": (2, 0, 0),
        "UpperTorso": (-3 - 3 * respira, 0, 0),
        "Head": (-6 - 5 * respira, 0, 0),
        "LeftUpperArm": (-34 - 7 * lento, 24, -18),
        "RightUpperArm": (-34 - 7 * lento, -24, 18),
        "LeftLowerArm": (-72 - 8 * lento, 0, 0),
        "RightLowerArm": (-72 - 8 * lento, 0, 0),
        "LeftUpperLeg": (-24, -12, 0),
        "RightUpperLeg": (-24, 12, 0),
        "LeftLowerLeg": (44, 0, 0),
        "RightLowerLeg": (44, 0, 0),
        "LeftFoot": (-20, 0, 0),
        "RightFoot": (-20, 0, 0),
    }


def cargar_inicio(t):
    return actuar(t, 10, [(0, G), (10, cargar_poder(0.0), "sale")], {})


NUEVAS = {
    "piroquinesis-bola-fuego": (bola_de_fuego, 30, False, "Action", (10, 12, 20)),
    "piroquinesis-chorro": (chorro, 36, False, "Action", (12, 16, 28)),
    "piroquinesis-muro-fuego": (muro_de_fuego, 40, False, "Action", (14, 18, 28)),
    "piroquinesis-cargar-inicio": (cargar_inicio, 10, False, "Action", (0, 5, 10)),
    "piroquinesis-cargar-loop": (cargar_poder, 30, True, "Action", (0, 7, 15)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["piroquinesis"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "piroquinesis-bola-fuego": "Z Bola/de fuego",
        "piroquinesis-chorro": "X Chorro",
        "piroquinesis-muro-fuego": "C Muro/de fuego",
        "piroquinesis-cargar-inicio": "Cargar/inicio",
        "piroquinesis-cargar-loop": "Cargar/loop",
    }
)
A.MARCADORES.update(
    {
        "piroquinesis-bola-fuego": [(12, "Impacto")],
        "piroquinesis-chorro": [(16, "Impacto")],
        "piroquinesis-muro-fuego": [(18, "Impacto")],
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
        destino.actions = [a for a in origen.actions if not a.startswith("piroquinesis")]
    for accion in bpy.data.actions:
        accion.use_fake_user = True
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
        print(f"CRUCES {nombre}: {A.chequear_cruces(arm, nombre)[:6]}")
    arm.animation_data.action = bpy.data.actions["piroquinesis-cargar-loop"]
    bpy.ops.wm.save_as_mainfile(filepath=A.BLEND)
    os.remove(copia)


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        A.renders("piroquinesis")
    if paso in ("gifs", "todo"):
        A.cuadros_gif("piroquinesis")
    if paso in ("fbx", "todo"):
        A.fbx("piroquinesis")
