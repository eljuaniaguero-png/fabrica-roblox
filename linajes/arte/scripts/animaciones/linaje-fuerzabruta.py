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
    # Derecha cargada, firme. Cadera y piernas siguen mirando al rival: solo gira el torso (55°).
    carga = con(
        G,
        raiz=(0, 0.14, -0.14),
        LowerTorso=(2, 0, -20),
        LeftUpperLeg=(-34, -9, 20),
        RightUpperLeg=(-4, 9, 20),
        LeftLowerLeg=(56, 0, 0),
        RightLowerLeg=(66, 0, 0),
        UpperTorso=(0, 0, -25),
        Head=(12, 0, 37),
        RightUpperArm=(34, -38, 22),
        RightLowerArm=(-122, 0, 0),
        LeftUpperArm=(-66, 30, -16),
    )
    # El peso pasa al pie de adelante y el puño sale un poco hacia abajo.
    pega = con(
        G,
        raiz=(0, -0.17, -0.16),
        LowerTorso=(8, 0, -20),
        LeftUpperLeg=(-48, -9, 20),
        RightUpperLeg=(18, 9, 20),
        LeftLowerLeg=(70, 0, 0),
        RightLowerLeg=(30, 0, 0),
        RightFoot=(-28, 0, 0),
        UpperTorso=(12, 0, 30),
        Head=(2, 0, -18),
        RightUpperArm=(-68, 4, -8),
        RightLowerArm=(-3, 0, 0),
        LeftUpperArm=(-14, 30, 8),
        LeftLowerArm=(-125, 0, 0),
    )
    queda = con(pega, raiz=(0, -0.15, -0.17), UpperTorso=(16, 0, 27), RightUpperArm=(-60, 4, -8))
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


# Embestida en 3 piezas que encadena el juego: inicio, carrera (loop) y frenada.
# Como un toro: hombro izquierdo adelante y bajo, cabeza detrás del hombro.
TORO = {
    "LowerTorso": (36, 0, -52),
    "UpperTorso": (8, 0, -8),
    "Head": (-12, 0, 44),
    "LeftUpperArm": (-72, 22, -10),
    "LeftLowerArm": (-138, 0, 0),
    "RightUpperArm": (12, -22, 18),
    "RightLowerArm": (-104, 0, 0),
}


def embestida_carrera(t):
    paso = onda(t)
    rodilla = A.cos(2 * A.pi * t)
    return con(
        TORO,
        # Altura medida para que el pie de apoyo quede en el piso durante toda la zancada.
        raiz=(0, -0.02, -0.2225 - 0.085 * rodilla + 0.06 * paso + 0.0925 * onda(t * 2, 0.25)),
        LeftUpperLeg=(-30 - 56 * paso, -7, 52),
        RightUpperLeg=(-30 + 56 * paso, 7, 52),
        LeftLowerLeg=(50 + 38 * rodilla, 0, 0),
        RightLowerLeg=(50 - 38 * rodilla, 0, 0),
        LeftFoot=(-12, 0, 0),
        RightFoot=(-12, 0, 0),
        RightUpperArm=(12 + 7 * paso, -22, 18),
    )


def embestida_inicio(t):
    return actuar(t, 6, [(0, G), (6, embestida_carrera(0.0), "sale")], {"raiz": 1, "LowerTorso": 1, "Head": -1})


def embestida_frenada(t):
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
    return actuar(t, 9, [(0, embestida_carrera(0.0)), (4, frena, "sale"), (9, G)], {"raiz": 1, "LowerTorso": 1, "Head": -1})


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


CARGA_LOOP = A._con_arrastre(cargar_poder, 30)


def cargar_inicio(t):
    # Termina exactamente en el primer cuadro del loop.
    return actuar(t, 9, [(0, G), (9, CARGA_LOOP(0.0), "sale")], {"raiz": 1, "LowerTorso": 1, "Head": -2})


NUEVAS = {
    "fuerzabruta-puno-sismico": (puno_sismico, 30, False, "Action", (10, 12, 18)),
    "fuerzabruta-golpe-piso": (golpe_piso, 36, False, "Action", (8, 13, 16)),
    "fuerzabruta-embestida-inicio": (embestida_inicio, 6, False, "Action", (0, 3, 6)),
    "fuerzabruta-embestida-carrera": (A._con_arrastre(embestida_carrera, 20), 20, True, "Action", (0, 5, 15)),
    "fuerzabruta-embestida-frenada": (embestida_frenada, 9, False, "Action", (0, 4, 9)),
    "fuerzabruta-cargar-inicio": (cargar_inicio, 9, False, "Action", (0, 5, 9)),
    "fuerzabruta-cargar-loop": (CARGA_LOOP, 30, True, "Action", (0, 7, 22)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["fuerzabruta"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "fuerzabruta-puno-sismico": "Z Puño/sísmico",
        "fuerzabruta-golpe-piso": "X Golpe/al piso",
        "fuerzabruta-embestida-inicio": "C Embestida/inicio",
        "fuerzabruta-embestida-carrera": "C Embestida/carrera",
        "fuerzabruta-embestida-frenada": "C Embestida/frenada",
        "fuerzabruta-cargar-inicio": "Cargar/inicio",
        "fuerzabruta-cargar-loop": "Cargar/loop",
    }
)
A.MARCADORES.update(
    {
        "fuerzabruta-puno-sismico": [(12, "Impacto")],
        "fuerzabruta-golpe-piso": [(16, "Impacto")],
        "fuerzabruta-embestida-carrera": [(5, "Paso"), (15, "Paso")],
        "fuerzabruta-embestida-frenada": [(2, "Impacto")],
    }
)
A.GIRO_CAMARA.update({n: 90 for n in NUEVAS})
A.B.LENTE *= 0.68  # más lejos: entra el salto de Golpe al piso
A.GIF_VISTAS.update({n: {"costado": 90, "atras": 135} for n in NUEVAS})


def acciones():
    bpy.ops.wm.open_mainfile(filepath=A.CUERPO)
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
        print(f"CRUCES {nombre}: {A.chequear_cruces(arm, nombre)[:6]}")
    arm.animation_data.action = bpy.data.actions["fuerzabruta-cargar-loop"]
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
