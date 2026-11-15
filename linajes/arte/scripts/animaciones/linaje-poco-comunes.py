"""Animaciones de Electro, Criogenia y Telequinesis (P27-04/05/06), Variante Normal, con base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/linaje-poco-comunes.py -- todo
    (pasos sueltos: acciones, renders; después: hoja.py electro | criogenia | telequinesis)

Reglas de cada Linaje (notas de la bóveda, 06 Linajes):
- Electro: rápido y nervioso. Gestos cortos y secos, con la mano IZQUIERDA estirada (dedos).
- Criogenia: lento pero seguro. Gestos amplios con peso, de abajo hacia arriba.
- Telequinesis: casi no se mueve. Una mano a la sien y la otra dirige, palma abierta.
Los tiempos de Impacto coinciden con Config.Poderes (30 cuadros por segundo).
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

# ---------------------------------------------------------------------------
# Electro
# ---------------------------------------------------------------------------
# Lenguaje: nervioso y rápido. Torso torcido, un brazo tenso tirado para atrás, rodillas
# flexionadas y cortes secos (sin pasos suaves entre poses). La cara siempre despejada.

E = con(
    G,
    raiz=(0, 0, -0.18),
    LowerTorso=(10, 0, -26),
    UpperTorso=(8, 0, -18),
    Head=(6, 0, 30),
    RightUpperArm=(46, -34, 10),  # brazo de atrás, tenso
    RightLowerArm=(-24, 0, 0),
    LeftUpperArm=(-40, 26, -10),
    LeftLowerArm=(-96, 0, 0),
)


def rayo_cadena(t):
    # Prepara: se carga torcido para atrás, la mano izquierda recogida al hombro (no tapa la cara).
    carga = con(
        E,
        raiz=(0, 0.1, -0.22),
        UpperTorso=(4, 0, 38),
        Head=(4, 0, -26),
        LeftUpperArm=(-10, 50, -30),
        LeftLowerArm=(-130, 0, 0),
        RightUpperArm=(60, -40, 10),
    )
    # Golpe: estocada larga, brazo izquierdo recto y el derecho latigueado atrás.
    dispara = con(
        E,
        raiz=(0, -0.2, -0.24),
        LowerTorso=(14, 0, -40),
        UpperTorso=(10, 0, -56),
        Head=(-2, 0, 84),
        LeftUpperArm=(-94, 2, 0),
        LeftLowerArm=(0, 0, 0),
        RightUpperArm=(70, -50, 20),
        RightLowerArm=(-4, 0, 0),
        LeftUpperLeg=(-60, -8, 34),
        RightUpperLeg=(26, 8, 34),
        LeftLowerLeg=(72, 0, 0),
        RightLowerLeg=(30, 0, 0),
    )
    # Recupera: el rayo lo sacude; hombros arriba, brazo cae flojo, torso vuelve de golpe.
    sacude = con(
        E,
        raiz=(0, -0.06, -0.14),
        UpperTorso=(-8, 0, 16),
        Head=(-12, 0, 10),
        LeftUpperArm=(-40, -16, 0),
        LeftLowerArm=(-40, 0, 0),
        RightUpperArm=(20, -20, 0),
        RightLowerArm=(-110, 0, 0),
    )
    return actuar(t, 24, [(0, G), (6, carga, "seco"), (10, dispara, "seco"), (16, sacude, "seco"), (24, G, "sale")], {"Head": -1})


def descarga(t):
    # Prepara: agachado, puños a la cadera y cabeza abajo (junta la carga).
    junta = con(
        E,
        raiz=(0, 0, -0.34),
        LowerTorso=(26, 0, 0),
        UpperTorso=(22, 0, 0),
        Head=(30, 0, 0),
        LeftUpperArm=(30, 22, 0),
        RightUpperArm=(30, -22, 0),
        LeftLowerArm=(-100, 0, 0),
        RightLowerArm=(-100, 0, 0),
        LeftUpperLeg=(-76, -16, 0),
        RightUpperLeg=(-76, 16, 0),
        LeftLowerLeg=(116, 0, 0),
        RightLowerLeg=(116, 0, 0),
        LeftFoot=(-30, 0, 0),
        RightFoot=(-30, 0, 0),
    )
    # Golpe: se para de un salto con los dos brazos abiertos en diagonal HACIA ABAJO (simétrico,
    # cabeza derecha y mentón arriba: nada de dab).
    estalla = con(
        G,
        raiz=(0, 0, 0.06),
        LowerTorso=(-8, 0, 0),
        UpperTorso=(-20, 0, 0),
        Head=(-18, 0, 0),
        LeftUpperArm=(20, -50, 0),
        RightUpperArm=(20, 50, 0),
        LeftLowerArm=(-10, 0, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-6, -24, 0),
        RightUpperLeg=(-6, 24, 0),
        LeftLowerLeg=(8, 0, 0),
        RightLowerLeg=(8, 0, 0),
        LeftFoot=(-2, 0, 0),
        RightFoot=(-2, 0, 0),
    )
    # Recupera: cae sobre una rodilla, las manos todavía chispeando a los costados.
    cae = con(
        E,
        raiz=(0, -0.04, -0.4),
        LowerTorso=(30, 0, -10),
        UpperTorso=(24, 0, 10),
        Head=(-10, 0, 0),
        LeftUpperArm=(10, -30, 0),
        RightUpperArm=(10, 30, 0),
        LeftLowerArm=(-60, 0, 0),
        RightLowerArm=(-60, 0, 0),
        LeftUpperLeg=(-90, -10, 10),
        RightUpperLeg=(0, 10, 10),
        LeftLowerLeg=(90, 0, 0),
        RightLowerLeg=(120, 0, 0),
        RightFoot=(40, 0, 0),
    )
    return actuar(t, 34, [(0, G), (9, junta, "seco"), (13, estalla, "seco"), (22, cae, "sale"), (34, G)], {"Head": -1})


def salto_cable(t):
    # Prepara (Sale 4): se tira de cabeza; Golpe (Llega 6): clava el hombro; Recupera: se
    # endereza de un tirón y sacude la cabeza.
    sale = con(
        E,
        raiz=(0, -0.22, -0.2),
        LowerTorso=(50, 0, -10),
        UpperTorso=(20, 0, -20),
        Head=(-44, 0, 28),
        LeftUpperArm=(-150, 6, 0),
        LeftLowerArm=(-4, 0, 0),
        RightUpperArm=(60, -30, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-70, -6, 10),
        RightUpperLeg=(40, 6, 10),
        LeftLowerLeg=(90, 0, 0),
        RightLowerLeg=(16, 0, 0),
    )
    llega = con(
        E,
        raiz=(0, -0.14, -0.28),
        LowerTorso=(22, 0, -46),
        UpperTorso=(14, 0, -56),
        Head=(-6, 0, 88),
        LeftUpperArm=(-60, -14, 0),
        LeftLowerArm=(-60, 0, 0),
        LeftUpperLeg=(-70, -6, 44),
        RightUpperLeg=(26, 6, 44),
        LeftLowerLeg=(90, 0, 0),
        RightLowerLeg=(56, 0, 0),
    )
    endereza = con(E, raiz=(0, 0.02, -0.1), UpperTorso=(-12, 0, 20), Head=(-16, 0, -20), LeftUpperArm=(-20, -10, 0))
    return actuar(t, 20, [(0, G), (4, sale, "seco"), (6, llega, "seco"), (13, endereza, "seco"), (20, G, "sale")], {"Head": -1})


# ---------------------------------------------------------------------------
# Criogenia
# ---------------------------------------------------------------------------
# Lenguaje: pesado, pies plantados y piernas abiertas. Barridos amplios con todo el brazo, como
# si el hielo pesara. Las poses llegan "sale" (se frenan con peso), nunca de golpe.

PLANTADO = {
    "LeftUpperLeg": (-40, -28, 0),
    "RightUpperLeg": (-40, 28, 0),
    "LeftLowerLeg": (64, 0, 0),
    "RightLowerLeg": (64, 0, 0),
    "LeftFoot": (-24, 0, 0),
    "RightFoot": (-24, 0, 0),
}
C = con(G, raiz=(0, 0, -0.3), LowerTorso=(10, 0, 0), UpperTorso=(6, 0, 0), Head=(8, 0, 0), **PLANTADO)


def lanza_hielo(t):
    # Prepara: el brazo derecho cruza el cuerpo y baja hasta la cadera izquierda (junta el frío).
    junta = con(
        C,
        UpperTorso=(14, 0, 40),
        Head=(14, 0, -30),
        RightUpperArm=(-30, -70, 0),
        RightLowerArm=(-30, 0, 0),
        LeftUpperArm=(10, 30, 0),
        LeftLowerArm=(-60, 0, 0),
    )
    # Golpe: barrido enorme hacia afuera y adelante; el brazo termina abierto a la altura del hombro.
    barre = con(
        C,
        raiz=(0, -0.06, -0.34),
        UpperTorso=(0, 0, -48),
        Head=(4, 0, 40),
        RightUpperArm=(-84, 50, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperArm=(30, -40, 0),
        LeftLowerArm=(-20, 0, 0),
    )
    # Recupera: el peso se va a la pierna derecha y el brazo baja despacio, abierto.
    asienta = con(
        C,
        raiz=(0.05, 0, -0.32),
        UpperTorso=(10, 0, -30),
        Head=(10, 0, 26),
        RightUpperArm=(-30, 64, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperArm=(20, -10, 0),
        LeftLowerArm=(-50, 0, 0),
    )
    return actuar(t, 32, [(0, G), (7, junta, "sale"), (10, barre, "seco"), (18, asienta, "sale"), (32, G, "suave")], {"Head": -1})


def muro_hielo(t):
    # Prepara: sentadilla abierta, las dos palmas apoyadas en el piso adelante.
    apoya = con(
        C,
        raiz=(0, -0.02, -0.46),
        LowerTorso=(46, 0, 0),
        UpperTorso=(22, 0, 0),
        Head=(-26, 0, 0),
        LeftUpperArm=(-36, -8, 0),
        RightUpperArm=(-36, 8, 0),
        LeftLowerArm=(-6, 0, 0),
        RightLowerArm=(-6, 0, 0),
        LeftUpperLeg=(-100, -30, 0),
        RightUpperLeg=(-100, 30, 0),
        LeftLowerLeg=(120, 0, 0),
        RightLowerLeg=(120, 0, 0),
    )
    # Golpe: se levanta empujando con las dos manos juntas hacia adelante (el muro sale del piso).
    empuja = con(
        C,
        raiz=(0, -0.08, -0.22),
        LowerTorso=(-4, 0, 0),
        UpperTorso=(-8, 0, 0),
        Head=(-4, 0, 0),
        LeftUpperArm=(-100, 14, 0),
        RightUpperArm=(-100, -14, 0),
        LeftLowerArm=(-6, 0, 0),
        RightLowerArm=(-6, 0, 0),
    )
    # Recupera: sostiene el muro, codos flexionados y el peso echado para atrás.
    sostiene = con(
        C,
        raiz=(0, 0, -0.26),
        LowerTorso=(0, 0, 0),
        UpperTorso=(-16, 0, 0),
        Head=(4, 0, 0),
        LeftUpperArm=(-70, 20, 0),
        RightUpperArm=(-70, -20, 0),
        LeftLowerArm=(-60, 0, 0),
        RightLowerArm=(-60, 0, 0),
    )
    return actuar(t, 40, [(0, G), (9, apoya, "sale"), (15, empuja, "seco"), (26, sostiene, "sale"), (40, G, "suave")], {"Head": -1})


def pista_helada(t):
    # Prepara: se agacha abierto con los dos brazos tirados atrás. Golpe: el brazo derecho barre
    # el piso adelante (la pista nace ahí). Recupera: desliza en la otra pierna, brazos cambiados.
    carga = con(
        C,
        raiz=(0, 0, -0.38),
        LowerTorso=(24, 0, 0),
        UpperTorso=(20, 0, 0),
        Head=(-10, 0, 0),
        LeftUpperArm=(50, 10, 0),
        RightUpperArm=(50, -10, 0),
        LeftLowerArm=(-10, 0, 0),
        RightLowerArm=(-10, 0, 0),
    )
    barre = con(
        C,
        raiz=(0, -0.08, -0.34),
        LowerTorso=(34, 0, -16),
        UpperTorso=(16, 0, 20),
        Head=(-30, 0, -10),
        RightUpperArm=(-70, 20, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperArm=(70, -10, 0),
        LeftLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-90, -24, 10),
        RightUpperLeg=(0, 24, 10),
        LeftLowerLeg=(100, 0, 0),
        RightLowerLeg=(30, 0, 0),
    )
    desliza = con(
        C,
        raiz=(0, -0.06, -0.32),
        LowerTorso=(30, 0, 16),
        UpperTorso=(14, 0, -20),
        Head=(-26, 0, 10),
        LeftUpperArm=(-60, -20, 0),
        LeftLowerArm=(-4, 0, 0),
        RightUpperArm=(60, 10, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperLeg=(0, -24, -10),
        RightUpperLeg=(-90, 24, -10),
        LeftLowerLeg=(30, 0, 0),
        RightLowerLeg=(100, 0, 0),
    )
    return actuar(t, 30, [(0, G), (3, carga, "sale"), (5, barre, "seco"), (18, desliza, "sale"), (30, G, "suave")], {"Head": -1})


# ---------------------------------------------------------------------------
# Telequinesis
# ---------------------------------------------------------------------------
# Lenguaje: controlado y sin esfuerzo. Cuerpo erguido y casi quieto, cabeza apenas inclinada,
# brazos abiertos con las palmas hacia afuera. Lo que se mueve es lo que controla, no él.

T = con(
    G,
    raiz=(0, 0, -0.03),
    LowerTorso=(0, 0, 0),
    UpperTorso=(-4, 0, 0),
    Head=(4, 10, 0),  # cabeza inclinada de costado
    LeftUpperArm=(-20, -40, 0),
    RightUpperArm=(-20, 40, 0),
    LeftLowerArm=(-20, 0, 0),
    RightLowerArm=(-20, 0, 0),
    LeftUpperLeg=(-8, -6, 0),
    RightUpperLeg=(-8, 6, 0),
    LeftLowerLeg=(12, 0, 0),
    RightLowerLeg=(12, 0, 0),
    LeftFoot=(-4, 0, 0),
    RightFoot=(-4, 0, 0),
)


def lanzar(t):
    # Prepara: abre los dos brazos a los costados (agarra el objeto con la mente, Agarra 6).
    abre = con(T, Head=(0, 14, 0), LeftUpperArm=(-30, -76, 0), RightUpperArm=(-30, 76, 0), LeftLowerArm=(-8, 0, 0), RightLowerArm=(-8, 0, 0))
    # Golpe: un solo brazo apunta al rival con la palma; el otro queda abierto. El cuerpo no se mueve.
    apunta = con(T, Head=(0, -10, 0), RightUpperArm=(-92, 4, 0), RightLowerArm=(0, 0, 0), LeftUpperArm=(-30, -70, 0), LeftLowerArm=(-8, 0, 0))
    # Recupera: baja los brazos despacio y queda flotando apenas.
    flota = con(T, raiz=(0, 0, 0.03), Head=(-4, 12, 0), LeftUpperArm=(-10, -30, 0), RightUpperArm=(-40, 30, 0))
    return actuar(t, 30, [(0, G), (6, abre, "suave"), (12, apunta, "sale"), (20, flota, "suave"), (30, G, "suave")], {"Head": -1})


def levantar(t):
    # Prepara: palmas para abajo a la altura de la cintura. Golpe (10): sube las dos manos abiertas
    # hasta los hombros y se eleva en puntas de pie; sostiene 2 s. Suelta (70): las abre hacia afuera.
    f = t * 84
    tiembla = A.cos(2 * A.pi * f / 6) if 16 < f < 68 else 0.0
    baja = con(T, LeftUpperArm=(-30, -20, 0), RightUpperArm=(-30, 20, 0), LeftLowerArm=(-30, 0, 0), RightLowerArm=(-30, 0, 0))
    sube = con(
        T,
        raiz=(0, 0, 0.04),
        Head=(-8, 10 + 2 * tiembla, 0),
        LeftUpperArm=(-90 + 2 * tiembla, -30, 0),
        RightUpperArm=(-90 - 2 * tiembla, 30, 0),
        LeftLowerArm=(-10, 0, 0),
        RightLowerArm=(-10, 0, 0),
        LeftFoot=(20, 0, 0),
        RightFoot=(20, 0, 0),
    )
    suelta = con(T, raiz=(0, 0, -0.06), Head=(6, -8, 0), LeftUpperArm=(0, -70, 0), RightUpperArm=(0, 70, 0), LeftLowerArm=(-4, 0, 0), RightLowerArm=(-4, 0, 0))
    return actuar(t, 84, [(0, G), (6, baja, "suave"), (10, sube, "sale"), (66, sube), (70, suelta, "seco"), (76, suelta), (84, G, "suave")], {"Head": -1})


def onda(t):
    # Prepara: junta las palmas frente al pecho (abajo de la cara). Golpe: las abre de golpe en
    # abanico, hacia adelante y afuera. Recupera: deja los brazos abiertos y la cabeza ladeada.
    junta = con(T, Head=(10, 0, 0), LeftUpperArm=(-60, 30, 0), RightUpperArm=(-60, -30, 0), LeftLowerArm=(-70, 0, 0), RightLowerArm=(-70, 0, 0))
    abre = con(
        T,
        raiz=(0, 0, -0.02),
        UpperTorso=(-10, 0, 0),
        Head=(-6, 0, 0),
        LeftUpperArm=(-70, -64, 0),
        RightUpperArm=(-70, 64, 0),
        LeftLowerArm=(-2, 0, 0),
        RightLowerArm=(-2, 0, 0),
    )
    queda = con(T, Head=(2, 16, 0), LeftUpperArm=(-36, -54, 0), RightUpperArm=(-36, 54, 0), LeftLowerArm=(-10, 0, 0), RightLowerArm=(-10, 0, 0))
    return actuar(t, 27, [(0, G), (5, junta, "sale"), (9, abre, "seco"), (17, queda, "suave"), (27, G, "suave")], {"Head": -1})


NUEVAS = {
    "electro-rayo-cadena": (rayo_cadena, 24, False, "Action", (6, 10, 16)),
    "electro-descarga": (descarga, 34, False, "Action", (9, 13, 22)),
    "electro-salto-cable": (salto_cable, 20, False, "Action", (4, 6, 13)),
    "criogenia-lanza-hielo": (lanza_hielo, 32, False, "Action", (7, 10, 18)),
    "criogenia-muro-hielo": (muro_hielo, 40, False, "Action", (9, 15, 26)),
    "criogenia-pista-helada": (pista_helada, 30, False, "Action", (3, 5, 18)),
    "telequinesis-lanzar": (lanzar, 30, False, "Action", (6, 12, 20)),
    "telequinesis-levantar": (levantar, 84, False, "Action", (10, 40, 72)),
    "telequinesis-onda": (onda, 27, False, "Action", (5, 9, 17)),
}
LINAJES = ("electro", "criogenia", "telequinesis")
A.ANIMACIONES = NUEVAS
for _linaje in LINAJES:
    A.GRUPOS[_linaje] = [n for n in NUEVAS if n.startswith(_linaje)]
A.ETIQUETAS.update(
    {
        "electro-rayo-cadena": "Z Rayo/en cadena",
        "electro-descarga": "X Descarga",
        "electro-salto-cable": "C Salto/de cable",
        "criogenia-lanza-hielo": "Z Lanza/de hielo",
        "criogenia-muro-hielo": "X Muro/de hielo",
        "criogenia-pista-helada": "C Pista/helada",
        "telequinesis-lanzar": "Z Lanzar",
        "telequinesis-levantar": "X Levantar",
        "telequinesis-onda": "C Onda",
    }
)
A.MARCADORES.update(
    {
        "electro-rayo-cadena": [(10, "Impacto")],
        "electro-descarga": [(13, "Impacto")],
        "electro-salto-cable": [(4, "Sale"), (6, "Llega")],
        "criogenia-lanza-hielo": [(10, "Impacto")],
        "criogenia-muro-hielo": [(15, "Impacto")],
        "criogenia-pista-helada": [(5, "Impacto")],
        "telequinesis-lanzar": [(6, "Agarra"), (12, "Impacto")],
        "telequinesis-levantar": [(10, "Impacto"), (70, "Suelta")],
        "telequinesis-onda": [(9, "Impacto")],
    }
)
A.GIRO_CAMARA.update({n: 60 for n in NUEVAS})
A.GIF_VISTAS.update({n: {"frente": 30} for n in NUEVAS})
A.B.LENTE *= 0.8


def acciones():
    """Parte del cuerpo actual y conserva las acciones que ya estaban (otros Linajes)."""
    bpy.ops.wm.open_mainfile(filepath=A.CUERPO)
    copia = A.BLEND + ".leer.blend"  # Blender no deja pisar un archivo del que acaba de leer
    shutil.copyfile(A.BLEND, copia)
    with bpy.data.libraries.load(copia) as (origen, destino):
        destino.actions = [a for a in origen.actions if not a.startswith(LINAJES)]
    for accion in bpy.data.actions:
        accion.use_fake_user = True
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
        print(f"CRUCES {nombre}: {A.chequear_cruces(arm, nombre)[:6]}")
    bpy.ops.wm.save_as_mainfile(filepath=A.BLEND)
    os.remove(copia)


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        for linaje in LINAJES:
            A.renders(linaje)
    if paso in ("gifs", "todo"):
        for linaje in LINAJES:
            A.cuadros_gif(linaje)
