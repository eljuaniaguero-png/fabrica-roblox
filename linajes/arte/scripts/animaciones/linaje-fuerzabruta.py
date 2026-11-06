"""Animaciones de Fuerza Bruta (P27-01), Variante Normal, con el motor de base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/linaje-fuerzabruta.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; después: gifs.py y hoja.py fuerzabruta)

Regla del Linaje: lento antes y después, rápido en el impacto. Sin giros acrobáticos.
"""

import importlib.util
import os
import sys

_spec = importlib.util.spec_from_file_location("anim_base", os.path.join(os.path.dirname(os.path.abspath(__file__)), "base.py"))
A = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(A)

import bpy  # noqa: E402

G = A.GUARDIA
con, actuar, pasarse, onda = A.con, A.actuar, A.pasarse, A.onda

A.BLEND = os.path.join(A.B.BLENDER, "animaciones-linajes.blend")
A.SALIDA_FBX = os.path.join(A.B.ARTE, "animaciones", "linaje-fuerzabruta")

# El cuerpo entero empuja: la cadera manda más tiempo que en un golpe común.
ADELANTO_PESADO = {"raiz": 3, "LowerTorso": 3, "LeftUpperLeg": 3, "RightUpperLeg": 3, "LeftLowerLeg": 3, "RightLowerLeg": 3, "UpperTorso": 1, "Head": -1}


def puno_sismico(t):
    # Derecha cargada, firme: el cuerpo no se tira, se afirma. Los pies no se mueven.
    carga = con(
        G,
        raiz=(0, 0.14, -0.14),
        LowerTorso=(2, 0, -46),
        LeftUpperLeg=(-34, -9, 46),
        RightUpperLeg=(-4, 9, 46),
        LeftLowerLeg=(56, 0, 0),
        RightLowerLeg=(66, 0, 0),
        UpperTorso=(0, 0, -28),
        RightUpperArm=(34, -38, 22),
        RightLowerArm=(-122, 0, 0),
        LeftUpperArm=(-66, 30, -16),
    )
    # El peso pasa al pie de adelante y el puño sale un poco hacia abajo.
    pega = con(
        G,
        raiz=(0, -0.17, -0.16),
        LowerTorso=(8, 0, 26),
        LeftUpperLeg=(-48, -9, -26),
        RightUpperLeg=(18, 9, -26),
        LeftLowerLeg=(70, 0, 0),
        RightLowerLeg=(30, 0, 0),
        RightFoot=(-28, 0, 0),
        UpperTorso=(12, 0, 26),
        Head=(2, 0, -18),
        RightUpperArm=(-68, 4, -8),
        RightLowerArm=(-3, 0, 0),
        LeftUpperArm=(-14, 30, 8),
        LeftLowerArm=(-125, 0, 0),
    )
    queda = con(pega, raiz=(0, -0.15, -0.17), UpperTorso=(16, 0, 22), RightUpperArm=(-60, 4, -8))
    tiempos = {"raiz": 1, "LowerTorso": 1, "LeftUpperLeg": 1, "RightUpperLeg": 1, "Head": -1}
    return actuar(t, 30, [(0, G), (6, carga, "sale"), (10, pasarse(G, carga, 0.08)), (12, pega, "seco"), (18, queda, "sale"), (30, G)], tiempos)


def golpe_piso(t):
    agacha = con(
        G,
        raiz=(0, 0.04, -0.29),
        LowerTorso=(30, 0, 0),
        UpperTorso=(14, 0, 0),
        Head=(-18, 0, 0),
        LeftUpperArm=(18, -18, 0),
        RightUpperArm=(18, 18, 0),
        LeftLowerArm=(-55, 0, 0),
        RightLowerArm=(-55, 0, 0),
        LeftUpperLeg=(-72, -10, 0),
        RightUpperLeg=(-62, 10, 0),
        LeftLowerLeg=(112, 0, 0),
        RightLowerLeg=(112, 0, 0),
        LeftFoot=(-34, 0, 0),
        RightFoot=(-34, 0, 0),
    )
    arriba = {
        "raiz": (0, -0.02, 0.3),
        "LowerTorso": (-12, 0, 0),
        "UpperTorso": (-10, 0, 0),
        "Head": (-14, 0, 0),
        "LeftUpperArm": (-168, 24, 0),
        "RightUpperArm": (-168, -24, 0),
        "LeftLowerArm": (-42, 0, 0),
        "RightLowerArm": (-42, 0, 0),
        "LeftUpperLeg": (-62, -8, 0),
        "RightUpperLeg": (-44, 8, 0),
        "LeftLowerLeg": (92, 0, 0),
        "RightLowerLeg": (86, 0, 0),
        "LeftFoot": (22, 0, 0),
        "RightFoot": (22, 0, 0),
    }
    abajo = {
        "raiz": (0, -0.1, -0.29),
        "LowerTorso": (56, 0, 0),
        "UpperTorso": (18, 0, 0),
        "Head": (-34, 0, 0),
        "LeftUpperArm": (-34, 12, 0),
        "RightUpperArm": (-34, -12, 0),
        "LeftLowerArm": (-4, 0, 0),
        "RightLowerArm": (-4, 0, 0),
        "LeftUpperLeg": (-104, -14, 0),
        "RightUpperLeg": (-74, 14, 0),
        "LeftLowerLeg": (118, 0, 0),
        "RightLowerLeg": (128, 0, 0),
        "LeftFoot": (-14, 0, 0),
        "RightFoot": (24, 0, 0),
    }
    levanta = con(abajo, raiz=(0, -0.06, -0.29), LowerTorso=(42, 0, 0), Head=(-20, 0, 0), LeftLowerArm=(-28, 0, 0), RightLowerArm=(-28, 0, 0))
    return actuar(
        t,
        36,
        [(0, G), (8, agacha, "sale"), (13, arriba, "sale"), (16, abajo, "seco"), (24, levanta), (36, G)],
        {"LeftLowerArm": -1, "RightLowerArm": -1, "Head": -1},
    )


def embestida(t):
    # Como un toro: hombro izquierdo adelante y bajo, cabeza detrás del hombro, pasos largos.
    toro = {
        "LowerTorso": (36, 0, -52),
        "UpperTorso": (8, 0, -8),
        "Head": (-12, 0, 44),
        "LeftUpperArm": (-72, 22, -10),
        "LeftLowerArm": (-138, 0, 0),
        "RightUpperArm": (12, -22, 18),
        "RightLowerArm": (-104, 0, 0),
    }
    arranque = con(
        G,
        raiz=(0, 0.14, -0.2),
        LeftUpperLeg=(-52, -9, 52),
        RightUpperLeg=(-14, 9, 52),
        LeftLowerLeg=(82, 0, 0),
        RightLowerLeg=(70, 0, 0),
        **toro,
    )
    paso_a = con(
        arranque,
        raiz=(0, -0.02, -0.18),
        LeftUpperLeg=(-82, -7, 52),
        RightUpperLeg=(24, 7, 52),
        LeftLowerLeg=(62, 0, 0),
        RightLowerLeg=(24, 0, 0),
    )
    paso_b = con(
        arranque,
        raiz=(0, -0.1, -0.21),
        LeftUpperLeg=(16, -7, 52),
        RightUpperLeg=(-84, 7, 52),
        LeftLowerLeg=(30, 0, 0),
        RightLowerLeg=(66, 0, 0),
    )
    choca = con(
        paso_a,
        raiz=(0, -0.28, -0.3),
        LowerTorso=(42, 0, -60),
        LeftUpperLeg=(-86, -7, 60),
        RightUpperLeg=(30, 7, 60),
        LeftUpperArm=(-52, 22, -10),
    )
    frena = con(
        G,
        raiz=(0, 0.02, -0.34),
        LowerTorso=(-8, 0, -20),
        UpperTorso=(-6, 0, 0),
        LeftUpperLeg=(-68, -16, 20),
        RightUpperLeg=(26, 16, 20),
        LeftLowerLeg=(44, 0, 0),
        RightLowerLeg=(92, 0, 0),
        LeftFoot=(26, 0, 0),
    )
    return actuar(
        t,
        40,
        [(0, G), (7, arranque, "sale"), (11, paso_a), (15, paso_b), (18, choca, "seco"), (28, frena, "sale"), (40, G)],
        {"raiz": 1, "LowerTorso": 1, "Head": -1},
    )


def cargar_poder(t):
    # Tensión: agachado, puños apretados delante del pecho, respiración fuerte y temblor.
    respira = onda(t)
    tiembla = onda(t * 5)
    return {
        "raiz": (0.006 * tiembla, 0, -0.21 + 0.04 * respira),
        "_hombros": 0.09 * A.B.STUD * (respira + 1) / 2,
        "LowerTorso": (16, 1.2 * tiembla, 0),
        "UpperTorso": (14 - 7 * respira, -1.5 * tiembla, 0),
        "Head": (24 - 18 * respira, 0, 1.5 * tiembla),
        "LeftUpperArm": (-46 + 2 * tiembla, 28, -18),
        "RightUpperArm": (-46 - 2 * tiembla, -28, 18),
        "LeftLowerArm": (-122, 0, 0),
        "RightLowerArm": (-122, 0, 0),
        "LeftUpperLeg": (-52, -18, 0),
        "RightUpperLeg": (-52, 18, 0),
        "LeftLowerLeg": (84, 0, 0),
        "RightLowerLeg": (84, 0, 0),
        "LeftFoot": (-30, 0, 0),
        "RightFoot": (-30, 0, 0),
    }


NUEVAS = {
    "fuerzabruta-puno-sismico": (puno_sismico, 30, False, "Action", (10, 12, 18)),
    "fuerzabruta-golpe-piso": (golpe_piso, 36, False, "Action", (8, 13, 16)),
    "fuerzabruta-embestida": (embestida, 40, False, "Action", (7, 15, 18)),
    "fuerzabruta-cargar": (A._con_arrastre(cargar_poder, 30), 30, True, "Action", (0, 7, 22)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["fuerzabruta"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "fuerzabruta-puno-sismico": "Z Puño/sísmico",
        "fuerzabruta-golpe-piso": "X Golpe/al piso",
        "fuerzabruta-embestida": "C Embestida",
        "fuerzabruta-cargar": "Cargar/poder",
    }
)
A.MARCADORES.update(
    {
        "fuerzabruta-puno-sismico": [(12, "Impacto")],
        "fuerzabruta-golpe-piso": [(16, "Impacto")],
        "fuerzabruta-embestida": [(11, "Paso"), (15, "Paso"), (18, "Impacto")],
    }
)
A.GIRO_CAMARA.update({n: 90 for n in NUEVAS})
A.GIRO_CAMARA["fuerzabruta-cargar"] = 30
A.B.LENTE *= 0.68  # más lejos: entra el salto de Golpe al piso
A.GIF_VISTAS.update({n: {"costado": 90, "atras": 135} for n in NUEVAS})
A.GIF_VISTAS["fuerzabruta-cargar"] = {"frente": 30, "costado": 90}


def acciones():
    bpy.ops.wm.open_mainfile(filepath=A.CUERPO)
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
        print(f"CRUCES {nombre}: {A.chequear_cruces(arm, nombre)[:6]}")
    arm.animation_data.action = bpy.data.actions["fuerzabruta-cargar"]
    bpy.ops.wm.save_as_mainfile(filepath=A.BLEND)


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        A.renders("fuerzabruta")
    if paso in ("gifs", "todo"):
        A.cuadros_gif("fuerzabruta")
    if paso in ("fbx", "todo"):
        A.fbx("fuerzabruta")
