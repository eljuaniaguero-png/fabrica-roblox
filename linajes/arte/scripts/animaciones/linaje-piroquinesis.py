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
    # Una mano: el brazo derecho va atrás, la bola nace en esa mano (Enciende 7) y sale con el
    # giro del torso (Lanza 12). La izquierda queda en guardia y las piernas plantadas.
    carga = con(
        G,
        raiz=(0, 0.1, -0.16),
        LowerTorso=(4, 0, -24),
        LeftUpperLeg=(-34, -6, 24),
        RightUpperLeg=(0, 6, 24),
        UpperTorso=(2, 0, -26),
        Head=(10, 0, 42),
        RightUpperArm=(46, 16, 0),
        RightLowerArm=(-58, 0, 0),
    )
    lanza = con(
        G,
        raiz=(0, -0.13, -0.16),
        LowerTorso=(10, 0, -20),
        UpperTorso=(6, 0, 72),
        Head=(4, 0, -56),
        RightUpperArm=(-90, 2, -8),
        RightLowerArm=(-2, 0, 0),
        LeftUpperLeg=(-44, -6, 20),
        RightUpperLeg=(14, 6, 20),
        LeftLowerLeg=(66, 0, 0),
        RightLowerLeg=(38, 0, 0),
    )
    queda = con(lanza, raiz=(0, -0.11, -0.16), UpperTorso=(6, 0, 62), Head=(4, 0, -46), RightUpperArm=(-80, 2, -8))
    return actuar(t, 30, [(0, G), (7, carga, "sale"), (10, pasarse(G, carga, 0.06)), (12, lanza, "seco"), (17, queda, "sale"), (30, G)], {"Head": -1})


def chorro_loop(t):
    # El fuego lo empuja: se resiste tirado apenas para atrás y tiembla. Frecuencias enteras: cierra.
    tiembla = A.cos(2 * A.pi * 6 * t)
    fino = A.cos(2 * A.pi * 9 * t)
    empuje = A.cos(2 * A.pi * t)
    return con(
        G,
        raiz=(0.004 * fino, 0.05 + 0.012 * empuje + 0.004 * tiembla, -0.15),
        LowerTorso=(2 + 1.2 * tiembla, 0, -20),
        UpperTorso=(-5 + 1.5 * empuje + 1.2 * fino, 0, 20),
        Head=(6 + 1.5 * tiembla, 0, -2),
        LeftUpperArm=(-84 + 1.8 * tiembla, 12, 0),
        RightUpperArm=(-84 - 1.8 * fino, -12, 0),
        LeftLowerArm=(-8, 0, 0),
        RightLowerArm=(-8, 0, 0),
        LeftUpperLeg=(-46, -6, 20),
        RightUpperLeg=(8, 6, 20),
        LeftLowerLeg=(70, 0, 0),
        RightLowerLeg=(46, 0, 0),
    )


def chorro_inicio(t):
    # 0,2 s: las palmas salen adelante y se enciende al llegar (Enciende 6).
    return actuar(t, 6, [(0, G), (6, chorro_loop(0.0), "seco")], {})


def chorro_fin(t):
    # 0,3 s: vuelve a la guardia.
    return actuar(t, 9, [(0, chorro_loop(0.0)), (9, G, "sale")], {})


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


MANOS = 3.6  # grados de apertura de los brazos: separa y junta las manos


def cargar_poder(t):
    # Calor: llama entre las manos. Loop de 1,8 s: dos respiraciones de 0,9 s y un balanceo entero.
    # Todo es coseno con vueltas enteras: el primer cuadro y el último son iguales.
    respira = A.cos(4 * A.pi * t)
    balancea = A.cos(2 * A.pi * t)
    return {
        "raiz": (0.012 * balancea, 0, -0.022 + 0.004 * respira),
        "_hombros": 0.09 * A.B.STUD * (respira + 1) / 2,
        "LowerTorso": (2, 0, 0),
        "UpperTorso": (-2 - 3 * respira, 6 * balancea, 0),
        "Head": (10 - 8 * balancea, -3 * balancea, 0),
        "LeftUpperArm": (-34 - 2 * respira, 28 - MANOS * respira, -36),
        "RightUpperArm": (-34 - 2 * respira, -28 + MANOS * respira, 36),
        "LeftLowerArm": (-76, 0, 0),
        "RightLowerArm": (-76, 0, 0),
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
    "piroquinesis-chorro-inicio": (chorro_inicio, 6, False, "Action", (0, 3, 6)),
    "piroquinesis-chorro-loop": (chorro_loop, 30, True, "Action", (0, 8, 20)),
    "piroquinesis-chorro-fin": (chorro_fin, 9, False, "Action", (0, 4, 9)),
    "piroquinesis-muro-fuego": (muro_de_fuego, 40, False, "Action", (14, 18, 28)),
    "piroquinesis-cargar-inicio": (cargar_inicio, 10, False, "Action", (0, 5, 10)),
    "piroquinesis-cargar-loop": (cargar_poder, 54, True, "Action", (0, 13, 27)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["piroquinesis"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "piroquinesis-bola-fuego": "Z Bola/de fuego",
        "piroquinesis-chorro-inicio": "X Chorro/inicio",
        "piroquinesis-chorro-loop": "X Chorro/loop",
        "piroquinesis-chorro-fin": "X Chorro/fin",
        "piroquinesis-muro-fuego": "C Muro/de fuego",
        "piroquinesis-cargar-inicio": "Cargar/inicio",
        "piroquinesis-cargar-loop": "Cargar/loop",
    }
)
A.MARCADORES.update(
    {
        "piroquinesis-bola-fuego": [(7, "Enciende"), (12, "Lanza")],
        "piroquinesis-chorro-inicio": [(6, "Enciende")],
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
