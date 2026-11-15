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


def rayo_cadena(t):
    # Estocada con la mano izquierda: el brazo se recoge al pecho y sale recto (Impacto 10).
    # El cuerpo queda de perfil, flaco, para que el brazo estirado sea toda la silueta.
    recoge = con(
        G,
        raiz=(0, 0.06, -0.15),
        UpperTorso=(4, 0, 30),
        Head=(10, 0, -12),
        LeftUpperArm=(-30, 30, -20),
        LeftLowerArm=(-140, 0, 0),
        RightUpperArm=(30, -10, 10),
        RightLowerArm=(-90, 0, 0),
    )
    dispara = con(
        G,
        raiz=(0, -0.14, -0.17),
        LowerTorso=(10, 0, -30),
        UpperTorso=(4, 0, -52),
        Head=(4, 0, 78),
        LeftUpperArm=(-92, 4, 0),
        LeftLowerArm=(-2, 0, 0),
        RightUpperArm=(50, -14, 10),
        RightLowerArm=(-70, 0, 0),
        LeftUpperLeg=(-48, -6, 30),
        RightUpperLeg=(16, 6, 30),
        LeftLowerLeg=(68, 0, 0),
        RightLowerLeg=(40, 0, 0),
    )
    tiembla = con(dispara, raiz=(0, -0.12, -0.17), LeftUpperArm=(-88, 6, 0), UpperTorso=(4, 0, -48))
    return actuar(t, 24, [(0, G), (6, recoge, "sale"), (10, dispara, "seco"), (15, tiembla, "sale"), (24, G)], {"Head": -1})


def descarga(t):
    # Se cierra sobre sí mismo (brazos cruzados, agachado) y estalla abierto en cruz (Impacto 13).
    cierra = con(
        G,
        raiz=(0, 0, -0.3),
        LowerTorso=(22, 0, 0),
        UpperTorso=(18, 0, 0),
        Head=(26, 0, 0),
        LeftUpperArm=(-50, 46, -20),
        RightUpperArm=(-50, -46, 20),
        LeftLowerArm=(-130, 0, 0),
        RightLowerArm=(-130, 0, 0),
        LeftUpperLeg=(-70, -14, 0),
        RightUpperLeg=(-70, 14, 0),
        LeftLowerLeg=(110, 0, 0),
        RightLowerLeg=(110, 0, 0),
        LeftFoot=(-30, 0, 0),
        RightFoot=(-30, 0, 0),
    )
    estalla = con(
        G,
        raiz=(0, 0, -0.04),
        LowerTorso=(-6, 0, 0),
        UpperTorso=(-16, 0, 0),
        Head=(-22, 0, 0),
        LeftUpperArm=(10, -84, 0),
        RightUpperArm=(10, 84, 0),
        LeftLowerArm=(-6, 0, 0),
        RightLowerArm=(-6, 0, 0),
        LeftUpperLeg=(-10, -22, 0),
        RightUpperLeg=(-10, 22, 0),
        LeftLowerLeg=(14, 0, 0),
        RightLowerLeg=(14, 0, 0),
        LeftFoot=(-4, 0, 0),
        RightFoot=(-4, 0, 0),
    )
    queda = con(estalla, raiz=(0, 0, -0.07), LeftUpperArm=(6, -74, 0), RightUpperArm=(6, 74, 0), Head=(-12, 0, 0))
    return actuar(t, 34, [(0, G), (9, cierra, "sale"), (13, pasarse(cierra, estalla, 0.06), "seco"), (20, queda, "sale"), (34, G)], {"Head": -1})


def salto_cable(t):
    # Se tira de cabeza convertido en rayo (Sale 4) y llega clavando el hombro izquierdo (Llega 6).
    sale = con(
        G,
        raiz=(0, -0.22, -0.2),
        LowerTorso=(46, 0, -10),
        UpperTorso=(20, 0, -20),
        Head=(-40, 0, 28),
        LeftUpperArm=(-150, 6, 0),
        LeftLowerArm=(-4, 0, 0),
        RightUpperArm=(40, -8, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-70, -6, 10),
        RightUpperLeg=(30, 6, 10),
        LeftLowerLeg=(90, 0, 0),
        RightLowerLeg=(20, 0, 0),
    )
    llega = con(
        G,
        raiz=(0, -0.1, -0.24),
        LowerTorso=(18, 0, -40),
        UpperTorso=(10, 0, -50),
        Head=(-4, 0, 86),
        LeftUpperArm=(-70, -10, 0),
        LeftLowerArm=(-50, 0, 0),
        RightUpperArm=(60, -20, 0),
        RightLowerArm=(-40, 0, 0),
        LeftUpperLeg=(-66, -6, 40),
        RightUpperLeg=(22, 6, 40),
        LeftLowerLeg=(86, 0, 0),
        RightLowerLeg=(52, 0, 0),
    )
    return actuar(t, 20, [(0, G), (4, sale, "seco"), (6, llega, "seco"), (11, con(llega, raiz=(0, -0.08, -0.2)), "sale"), (20, G)], {"Head": -1})


# ---------------------------------------------------------------------------
# Criogenia
# ---------------------------------------------------------------------------


def lanza_hielo(t):
    # Jabalina: el brazo derecho sube atrás de la cabeza y tira por arriba (Impacto 10). El
    # izquierdo apunta adelante para equilibrar y baja al tirar.
    arma = con(
        G,
        raiz=(0, 0.12, -0.12),
        LowerTorso=(-6, 0, -34),
        UpperTorso=(-12, 0, -40),
        Head=(4, 0, 70),
        RightUpperArm=(-150, -30, 30),
        RightLowerArm=(-96, 0, 0),
        LeftUpperArm=(-84, 10, 0),
        LeftLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-22, -6, 34),
        RightUpperLeg=(12, 6, 34),
    )
    tira = con(
        G,
        raiz=(0, -0.16, -0.16),
        LowerTorso=(12, 0, -10),
        UpperTorso=(12, 0, 56),
        Head=(-10, 0, -44),
        RightUpperArm=(-74, 6, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperArm=(34, 24, 0),
        LeftLowerArm=(-60, 0, 0),
        LeftUpperLeg=(-62, -6, 10),
        RightUpperLeg=(24, 6, 10),
        LeftLowerLeg=(84, 0, 0),
        RightLowerLeg=(36, 0, 0),
    )
    sigue = con(tira, raiz=(0, -0.14, -0.18), RightUpperArm=(-40, 10, 0), UpperTorso=(16, 0, 62), Head=(-12, 0, -50))
    return actuar(t, 32, [(0, G), (7, arma, "sale"), (10, tira, "seco"), (16, sigue, "sale"), (32, G)], {"Head": -1})


def muro_hielo(t):
    # Levanta el muro del piso: se agacha con las palmas abajo y se para tirando de los dos
    # brazos hacia arriba (Impacto 15), como quien levanta una persiana pesada.
    abajo = con(
        G,
        raiz=(0, -0.04, -0.34),
        LowerTorso=(40, 0, 0),
        UpperTorso=(20, 0, 0),
        Head=(-30, 0, 0),
        LeftUpperArm=(-40, -10, 0),
        RightUpperArm=(-40, 10, 0),
        LeftLowerArm=(-10, 0, 0),
        RightLowerArm=(-10, 0, 0),
        LeftUpperLeg=(-96, -14, 0),
        RightUpperLeg=(-96, 14, 0),
        LeftLowerLeg=(124, 0, 0),
        RightLowerLeg=(124, 0, 0),
        LeftFoot=(-26, 0, 0),
        RightFoot=(-26, 0, 0),
    )
    arriba = con(
        G,
        raiz=(0, 0.04, -0.02),
        LowerTorso=(-8, 0, 0),
        UpperTorso=(-14, 0, 0),
        Head=(-10, 0, 0),
        LeftUpperArm=(-150, -16, 0),
        RightUpperArm=(-150, 16, 0),
        LeftLowerArm=(-30, 0, 0),
        RightLowerArm=(-30, 0, 0),
        LeftUpperLeg=(-8, -14, 0),
        RightUpperLeg=(-8, 14, 0),
        LeftLowerLeg=(12, 0, 0),
        RightLowerLeg=(12, 0, 0),
        LeftFoot=(-4, 0, 0),
        RightFoot=(-4, 0, 0),
    )
    sostiene = con(arriba, raiz=(0, 0.03, -0.05), LeftUpperArm=(-138, -16, 0), RightUpperArm=(-138, 16, 0))
    return actuar(t, 40, [(0, G), (9, abajo, "sale"), (15, pasarse(abajo, arriba, 0.05), "seco"), (24, sostiene, "sale"), (40, G)], {"Head": -1})


def pista_helada(t):
    # Patinador de velocidad: muy bajo, torso casi horizontal, un brazo barre el piso adelante
    # (Impacto 4) y el otro va atrás. Se sostiene deslizando 0,6 s y se endereza.
    patina = con(
        G,
        raiz=(0, -0.08, -0.26),
        LowerTorso=(34, 0, -10),
        UpperTorso=(14, 0, 24),
        Head=(-36, 0, -14),
        RightUpperArm=(-100, 6, 0),
        RightLowerArm=(-6, 0, 0),
        LeftUpperArm=(70, 14, 0),
        LeftLowerArm=(-14, 0, 0),
        LeftUpperLeg=(-92, -6, 10),
        RightUpperLeg=(6, 10, 10),
        LeftLowerLeg=(100, 0, 0),
        RightLowerLeg=(30, 0, 0),
        LeftFoot=(-10, 0, 0),
        RightFoot=(20, 0, 0),
    )
    cambia = con(patina, raiz=(0.03, -0.08, -0.24), UpperTorso=(18, 0, 14), RightUpperArm=(-90, 6, 0), LeftUpperArm=(60, 14, 0))
    return actuar(t, 30, [(0, G), (4, patina, "seco"), (12, cambia), (20, patina), (30, G, "sale")], {"Head": -1})


# ---------------------------------------------------------------------------
# Telequinesis
# ---------------------------------------------------------------------------

# Mano izquierda a la sien: es la marca del Linaje en las tres habilidades.
SIEN = {"LeftUpperArm": (-70, 34, -30), "LeftLowerArm": (-150, 0, 0)}
PARADO = con(
    G,
    raiz=(0, 0, -0.04),
    LowerTorso=(2, 0, -10),
    UpperTorso=(-2, 0, 0),
    Head=(8, 0, 10),
    LeftUpperLeg=(-12, -6, 10),
    RightUpperLeg=(2, 6, 10),
    LeftLowerLeg=(18, 0, 0),
    RightLowerLeg=(14, 0, 0),
    LeftFoot=(-6, 0, 0),
    RightFoot=(-8, 0, 0),
)


def lanzar(t):
    # El brazo derecho se abre al costado, palma arriba, "agarrando" el objeto (6) y barre en
    # horizontal hasta apuntar al rival (Impacto 12). El cuerpo apenas gira.
    agarra = con(
        PARADO,
        UpperTorso=(-4, 0, -24),
        Head=(4, 0, 34),
        RightUpperArm=(-10, 86, 0),
        RightLowerArm=(-20, 0, 0),
        **SIEN,
    )
    tira = con(
        PARADO,
        raiz=(0, -0.05, -0.06),
        UpperTorso=(4, 0, 34),
        Head=(8, 0, -24),
        RightUpperArm=(-90, -14, 0),
        RightLowerArm=(-2, 0, 0),
        **SIEN,
    )
    queda = con(tira, UpperTorso=(4, 0, 28), RightUpperArm=(-84, -10, 0))
    return actuar(t, 30, [(0, G), (6, agarra, "sale"), (12, pasarse(agarra, tira, 0.05), "seco"), (18, queda, "sale"), (30, G)], {"Head": -1})


def levantar(t):
    # La mano derecha sube despacio con la palma arriba y el rival sube con ella (Impacto 10).
    # Lo sostiene temblando 2 s y baja el brazo de un tirón: ahí cae (Suelta 70).
    f = t * 84
    tiembla = A.cos(2 * A.pi * f / 5) if 16 < f < 68 else 0.0
    toma = con(PARADO, RightUpperArm=(-50, -6, 0), RightLowerArm=(-30, 0, 0), **SIEN)
    sube = con(
        PARADO,
        raiz=(0, 0.03, -0.02),
        UpperTorso=(-10, 0, 0),
        Head=(-14 + 1.5 * tiembla, 0, 10),
        RightUpperArm=(-134 + 2.5 * tiembla, -10, 0),
        RightLowerArm=(-24, 0, 0),
        **SIEN,
    )
    baja = con(
        PARADO,
        raiz=(0, -0.06, -0.2),
        LowerTorso=(24, 0, -10),
        UpperTorso=(20, 0, 20),
        Head=(-6, 0, -10),
        RightUpperArm=(-34, -4, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperLeg=(-50, -6, 10),
        RightUpperLeg=(-30, 6, 10),
        LeftLowerLeg=(70, 0, 0),
        RightLowerLeg=(70, 0, 0),
        LeftFoot=(-16, 0, 0),
        RightFoot=(-24, 0, 0),
        **SIEN,
    )
    return actuar(t, 84, [(0, G), (10, toma, "sale"), (18, sube, "suave"), (66, sube), (70, baja, "seco"), (76, baja), (84, G)], {"Head": -1})


def onda(t):
    # Las dos palmas se juntan a la cadera derecha (5) y empujan adelante con un paso (Impacto 9).
    junta = con(
        G,
        raiz=(0, 0.08, -0.18),
        LowerTorso=(6, 0, -36),
        UpperTorso=(4, 0, -34),
        Head=(10, 0, 62),
        RightUpperArm=(30, -4, 0),
        RightLowerArm=(-100, 0, 0),
        LeftUpperArm=(-20, 60, 0),
        LeftLowerArm=(-90, 0, 0),
    )
    empuja = con(
        G,
        raiz=(0, -0.18, -0.18),
        LowerTorso=(10, 0, -10),
        UpperTorso=(6, 0, 10),
        Head=(-6, 0, 0),
        LeftUpperArm=(-98, 14, 0),
        RightUpperArm=(-98, -14, 0),
        LeftLowerArm=(-4, 0, 0),
        RightLowerArm=(-4, 0, 0),
        LeftUpperLeg=(-66, -6, 10),
        RightUpperLeg=(26, 6, 10),
        LeftLowerLeg=(86, 0, 0),
        RightLowerLeg=(30, 0, 0),
        RightFoot=(10, 0, 0),
    )
    queda = con(empuja, raiz=(0, -0.16, -0.18), LeftUpperArm=(-92, 14, 0), RightUpperArm=(-92, -14, 0))
    return actuar(t, 27, [(0, G), (5, junta, "sale"), (9, pasarse(junta, empuja, 0.05), "seco"), (15, queda, "sale"), (27, G)], {"Head": -1})


NUEVAS = {
    "electro-rayo-cadena": (rayo_cadena, 24, False, "Action", (6, 10, 15)),
    "electro-descarga": (descarga, 34, False, "Action", (9, 13, 20)),
    "electro-salto-cable": (salto_cable, 20, False, "Action", (4, 6, 11)),
    "criogenia-lanza-hielo": (lanza_hielo, 32, False, "Action", (7, 10, 16)),
    "criogenia-muro-hielo": (muro_hielo, 40, False, "Action", (9, 15, 24)),
    "criogenia-pista-helada": (pista_helada, 30, False, "Action", (4, 12, 20)),
    "telequinesis-lanzar": (lanzar, 30, False, "Action", (6, 12, 18)),
    "telequinesis-levantar": (levantar, 84, False, "Action", (10, 40, 72)),
    "telequinesis-onda": (onda, 27, False, "Action", (5, 9, 15)),
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
        "criogenia-pista-helada": [(4, "Impacto")],
        "telequinesis-lanzar": [(6, "Agarra"), (12, "Impacto")],
        "telequinesis-levantar": [(10, "Impacto"), (70, "Suelta")],
        "telequinesis-onda": [(9, "Impacto")],
    }
)
A.GIRO_CAMARA.update({n: 60 for n in NUEVAS})
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
