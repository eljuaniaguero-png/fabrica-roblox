"""Animaciones de Reflejos (P27-02), Variante Normal, con el motor de base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/linaje-reflejos.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; después: gifs.py y hoja.py reflejos)

Regla del Linaje: rápido y preciso, poco recorrido, sin peso. Nada de cargar el golpe de lejos.
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

LIVIANO = {"raiz": 1, "LowerTorso": 1, "Head": -1}


def _derecha(alto=-88, giro=30, base=G):
    """Recto de derecha, corto: el peso apenas va adelante."""
    return con(
        base,
        raiz=(0, -0.08, -0.16),
        LowerTorso=(14, 0, -20),
        UpperTorso=(4, 0, giro),
        RightUpperArm=(alto, 4, -8),
        RightLowerArm=(-5, 0, 0),
        LeftUpperArm=(-40, 18, -16),
    )


def _izquierda(alto=-88, giro=-26, base=G):
    """Recto de izquierda, corto."""
    return con(
        base,
        raiz=(0, -0.1, -0.17),
        LowerTorso=(16, 0, -22),
        UpperTorso=(4, 0, giro),
        LeftUpperArm=(alto, 0, 10),
        LeftLowerArm=(-4, 0, 0),
        RightUpperArm=(-34, -20, 18),
    )


def contragolpe(t):
    # Postura atenta (0-6), esquive de costado (10) y tres golpes: Impacto 12, 17 y 22.
    postura = con(
        G,
        raiz=(0, 0.06, -0.15),
        LowerTorso=(2, 0, -20),
        UpperTorso=(-3, 0, -8),
        Head=(8, 0, 16),
        LeftUpperArm=(-70, -6, -12),
        LeftLowerArm=(-70, 0, 0),
        RightUpperArm=(-34, -20, 18),
    )
    esquiva = con(
        G,
        raiz=(-0.14, 0.03, -0.2),
        LowerTorso=(10, -14, -20),
        UpperTorso=(8, -8, -14),
        Head=(10, 10, 16),
    )
    return actuar(
        t,
        30,
        [
            (0, G),
            (6, postura, "sale"),
            (8, postura),
            (10, esquiva, "seco"),
            (12, _derecha(), "seco"),
            (14, pasarse(esquiva, _derecha(), 0.05), "sale"),
            (17, _izquierda(), "seco"),
            (19, pasarse(G, _izquierda(), 0.05), "sale"),
            (22, _derecha(-80, 36), "seco"),
            (24, pasarse(G, _derecha(-80, 36), 0.05), "sale"),
            (30, G),
        ],
        LIVIANO,
    )


def paso_fantasma(t):
    # Se tira adelante (0-12), pasa de largo y gira media vuelta (14) y pega con un revés por la
    # espalda del rival (Impacto 16). Sigue el giro hasta volver a mirar adelante.
    agacha = con(
        G,
        raiz=(0, 0.1, -0.27),
        LowerTorso=(30, 0, -20),
        UpperTorso=(10, 0, 0),
        Head=(-14, 0, 12),
        LeftUpperArm=(26, 18, 0),
        RightUpperArm=(26, -18, 0),
        LeftLowerArm=(-40, 0, 0),
        RightLowerArm=(-40, 0, 0),
        LeftUpperLeg=(-56, -6, 20),
        RightUpperLeg=(-16, 6, 20),
        LeftLowerLeg=(80, 0, 0),
        RightLowerLeg=(76, 0, 0),
    )
    pasa = con(
        agacha,
        raiz=(0, -0.2, -0.2),
        LowerTorso=(42, 0, -110),
        Head=(-24, 0, 60),
        LeftUpperArm=(40, 12, 0),
        RightUpperArm=(30, 30, 0),
        LeftUpperLeg=(-60, -6, 0),
        RightUpperLeg=(24, 6, 0),
        LeftLowerLeg=(50, 0, 0),
        RightLowerLeg=(70, 0, 0),
    )
    pega = con(
        _derecha(-90, 24),
        raiz=(0, -0.14, -0.17),
        LowerTorso=(10, 0, -200),
        LeftUpperLeg=(-40, -6, 20),
        RightUpperLeg=(8, 6, 20),
        Head=(6, 0, 10),
    )
    sigue = con(pasarse(G, pega, 0.05), LowerTorso=(10, 0, -214))
    fin = con(G, LowerTorso=(8, 0, -380))
    return actuar(t, 36, [(0, G), (9, agacha, "sale"), (12, pasarse(G, agacha, 0.06)), (14, pasa, "seco"), (16, pega, "seco"), (20, sigue, "sale"), (24, sigue), (36, fin)], LIVIANO)


def lluvia_de_golpes(t):
    # Junta aire y encoge los hombros (0-14); seis rectos alternados: Impacto 18, 21, 24, 27, 30 y 33.
    carga = con(
        G,
        raiz=(0, 0.06, -0.19),
        LowerTorso=(10, 0, -20),
        UpperTorso=(8, 0, -12),
        LeftUpperArm=(-22, 22, -16),
        RightUpperArm=(-18, -22, 18),
        LeftLowerArm=(-140, 0, 0),
        RightLowerArm=(-140, 0, 0),
    )
    claves = [(0, G), (10, carga, "sale"), (14, pasarse(G, carga, 0.08))]
    golpes = [_derecha(-92, 22), _izquierda(-80, -20), _derecha(-78, 24), _izquierda(-94, -18), _derecha(-86, 28), _izquierda(-84, -30)]
    for i, pose in enumerate(golpes):
        claves.append((18 + 3 * i, pose, "seco"))
    claves += [(35, pasarse(G, golpes[-1], 0.05), "sale"), (40, G)]
    return actuar(t, 40, claves, {})


def cargar_poder(t):
    # Calma atenta, no tensión: erguido, manos abiertas y bajas, pulso rápido y mirada que barre.
    respira = onda(t)
    pulso = onda(t * 3)
    return {
        "raiz": (0.012 * onda(t, 0.25), 0, -0.08 + 0.018 * respira),
        "_hombros": 0.04 * A.B.STUD * (respira + 1) / 2,
        "LowerTorso": (3, 0, 4 * onda(t, 0.25)),
        "UpperTorso": (2 - 2 * respira, 0, -3 * onda(t, 0.25)),
        "Head": (6, 0, 14 * onda(t, 0.1)),
        "LeftUpperArm": (-26 + 1.5 * pulso, 22, -8),
        "RightUpperArm": (-26 - 1.5 * pulso, -22, 8),
        "LeftLowerArm": (-52, 0, 0),
        "RightLowerArm": (-52, 0, 0),
        "LeftUpperLeg": (-22, -8, 0),
        "RightUpperLeg": (-12, 8, 0),
        "LeftLowerLeg": (34, 0, 0),
        "RightLowerLeg": (28, 0, 0),
        "LeftFoot": (-12, 0, 0),
        "RightFoot": (-16, 0, 0),
    }


NUEVAS = {
    "reflejos-contragolpe": (contragolpe, 30, False, "Action", (8, 12, 22)),
    "reflejos-paso-fantasma": (paso_fantasma, 36, False, "Action", (12, 16, 26)),
    "reflejos-lluvia-golpes": (lluvia_de_golpes, 40, False, "Action", (14, 18, 36)),
    "reflejos-cargar": (A._con_arrastre(cargar_poder, 30), 30, True, "Action", (0, 7, 22)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["reflejos"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "reflejos-contragolpe": "Z Contragolpe",
        "reflejos-paso-fantasma": "X Paso/fantasma",
        "reflejos-lluvia-golpes": "C Lluvia/de golpes",
        "reflejos-cargar": "Cargar/poder",
    }
)
A.MARCADORES.update(
    {
        "reflejos-contragolpe": [(12, "Impacto"), (17, "Impacto"), (22, "Impacto")],
        "reflejos-paso-fantasma": [(16, "Impacto")],
        "reflejos-lluvia-golpes": [(18 + 3 * i, "Impacto") for i in range(6)],
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
    arm.animation_data.action = bpy.data.actions["reflejos-cargar"]
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
