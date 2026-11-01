"""Animaciones base del jugador (locomoción, P26-01) sobre el R15 del cuerpo propio.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/base.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; con grupo, ej.: -- todo combate;
    después de gifs: python gifs.py)

- acciones: abre blender/cuerpo.blend, crea una Action por animación (30 fps) y guarda
  blender/animaciones-base.blend (cuerpo.blend no se toca).
- renders: una tira de 3 cuadros clave por animación (renders/anim-base-<nombre>.png) y la hoja
  con todas (renders/anim-base-hoja.png).
- fbx: un FBX por animación en animaciones/base/ (solo esqueleto, bake, sin leaf bones).

Cada pose se escribe con giros en los ejes del mundo (grados), relativos al padre:
  X = adelante/atrás: en piernas y brazos (apuntan abajo) negativo = la punta va adelante; en
  torso y cabeza (apuntan arriba) positivo = se inclina adelante. Rodilla: positivo dobla.
  Codo: negativo dobla. Y = abrir de costado. Z = girar. El personaje mira a -Y; su izquierda
  es +X.
Las animaciones con loop son funciones de la fase t (0 a 1) que vuelven al mismo lugar en t = 1.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
from mathutils import Euler, Matrix, Vector  # noqa: E402

FPS = 30
CUERPO = os.path.join(B.BLENDER, "cuerpo.blend")
BLEND = os.path.join(B.BLENDER, "animaciones-base.blend")
SALIDA_FBX = os.path.join(B.ARTE, "animaciones", "base")
PASO_CLAVE = 1  # una clave por cuadro: los loops quedan suaves y sin cortes

sen, cos, pi = math.sin, math.cos, math.pi


def onda(t, fase=0.0):
    return sen(2 * pi * (t + fase))


def pos(x):
    return max(0.0, x)


# ---------------------------------------------------------------------------
# Animaciones: cada una devuelve {hueso: (x, y, z) grados} y "raiz": (x, y, z) metros.
# ---------------------------------------------------------------------------


def quieto(t):
    r = onda(t)  # una respiración lenta por loop (2 s)
    # Mira a un costado y al otro una sola vez (de 0,3 a 0,8 del loop).
    m = 0.0
    if 0.3 < t < 0.8:
        m = sen(2 * pi * (t - 0.3) / 0.5) * 25
    return {
        "raiz": (0.02, 0, -0.01 + r * 0.004),  # peso en la pierna izquierda
        "LowerTorso": (0, -3, 0),
        "UpperTorso": (r * 1.5, 3, 0),
        "Head": (0, 0, m),
        "LeftUpperArm": (-3, -6 - r * 1, 0),
        "RightUpperArm": (-3, 6 + r * 1, 0),
        "LeftLowerArm": (-8, 0, 0),
        "RightLowerArm": (-8, 0, 0),
        "LeftUpperLeg": (0, 3, 0),
        "RightUpperLeg": (-6, -4, 0),
        "RightLowerLeg": (10, 0, 0),
        "RightFoot": (-4, 0, 0),
        "_hombros": 0.03 * B.STUD * (r + 1) / 2,
    }


def caminar(t):
    s = onda(t)
    rebote = abs(cos(2 * pi * t))
    return {
        "raiz": (0, 0, -0.015 + rebote * 0.015),
        "LowerTorso": (0, 0, s * 4),
        "UpperTorso": (3, 0, -s * 7 + s * 0),
        "Head": (-2, 0, s * 2),
        "LeftUpperLeg": (-s * 28, 0, 0),
        "RightUpperLeg": (s * 28, 0, 0),
        "LeftLowerLeg": (pos(sen(2 * pi * t - 0.6)) * 35 + 5, 0, 0),
        "RightLowerLeg": (pos(-sen(2 * pi * t - 0.6)) * 35 + 5, 0, 0),
        "LeftFoot": (s * 8, 0, 0),
        "RightFoot": (-s * 8, 0, 0),
        "LeftUpperArm": (s * 24, -5, 0),
        "RightUpperArm": (-s * 24, 5, 0),
        "LeftLowerArm": (-15 - pos(-s) * 15, 0, 0),
        "RightLowerArm": (-15 - pos(s) * 15, 0, 0),
    }


def correr(t):
    s = onda(t)
    rebote = abs(cos(2 * pi * t))
    return {
        "raiz": (0, 0, -0.04 + rebote * 0.05),
        "LowerTorso": (15, 0, s * 6),
        "UpperTorso": (0, 0, -s * 10),
        "Head": (-12, 0, s * 3),
        "LeftUpperLeg": (-s * 50 - 10, 0, 0),
        "RightUpperLeg": (s * 50 - 10, 0, 0),
        "LeftLowerLeg": (pos(sen(2 * pi * t - 0.9)) * 85 + 15, 0, 0),
        "RightLowerLeg": (pos(-sen(2 * pi * t - 0.9)) * 85 + 15, 0, 0),
        "LeftFoot": (s * 15, 0, 0),
        "RightFoot": (-s * 15, 0, 0),
        "LeftUpperArm": (s * 50, -8, 0),
        "RightUpperArm": (-s * 50, 8, 0),
        "LeftLowerArm": (-90, 0, 0),
        "RightLowerArm": (-90, 0, 0),
    }


def correr_rapido(t):
    s = onda(t)
    rebote = abs(cos(2 * pi * t))
    return {
        "raiz": (0, 0, -0.06 + rebote * 0.06),
        "LowerTorso": (30, 0, s * 5),
        "UpperTorso": (0, 0, -s * 6),
        "Head": (-25, 0, 0),
        "LeftUpperLeg": (-s * 60 - 15, 0, 0),
        "RightUpperLeg": (s * 60 - 15, 0, 0),
        "LeftLowerLeg": (pos(sen(2 * pi * t - 0.9)) * 100 + 20, 0, 0),
        "RightLowerLeg": (pos(-sen(2 * pi * t - 0.9)) * 100 + 20, 0, 0),
        "LeftFoot": (s * 20, 0, 0),
        "RightFoot": (-s * 20, 0, 0),
        # Brazos rectos hacia atrás (estilo velocista).
        "LeftUpperArm": (55 + s * 4, -10, 0),
        "RightUpperArm": (55 - s * 4, 10, 0),
        "LeftLowerArm": (-5, 0, 0),
        "RightLowerArm": (-5, 0, 0),
        "LeftHand": (15, 0, 0),
        "RightHand": (15, 0, 0),
    }


def _mezcla(a, b, u):
    u = u * u * (3 - 2 * u)
    claves = set(a) | set(b)
    out = {}
    for k in claves:
        va, vb = a.get(k, (0, 0, 0)), b.get(k, (0, 0, 0))
        if isinstance(va, float) or isinstance(vb, float):
            continue
        out[k] = tuple(x + (y - x) * u for x, y in zip(va, vb))
    return out


AGACHADO = {
    "raiz": (0, 0, -0.16),
    "LowerTorso": (25, 0, 0),
    "UpperTorso": (5, 0, 0),
    "Head": (-20, 0, 0),
    "LeftUpperLeg": (-60, 0, 0),
    "RightUpperLeg": (-60, 0, 0),
    "LeftLowerLeg": (85, 0, 0),
    "RightLowerLeg": (85, 0, 0),
    "LeftFoot": (-25, 0, 0),
    "RightFoot": (-25, 0, 0),
    "LeftUpperArm": (40, -10, 0),
    "RightUpperArm": (40, 10, 0),
    "LeftLowerArm": (-20, 0, 0),
    "RightLowerArm": (-20, 0, 0),
}
DE_PIE = {"raiz": (0, 0, 0)}


def saltar_inicio(t):
    # Se agacha (0 a 0,6) y empuja con los brazos para arriba (0,6 a 1).
    if t < 0.6:
        return _mezcla(DE_PIE, AGACHADO, t / 0.6)
    arriba = {
        "raiz": (0, 0, 0.03),
        "LowerTorso": (-5, 0, 0),
        "Head": (8, 0, 0),
        "LeftUpperArm": (-150, -10, 0),
        "RightUpperArm": (-150, 10, 0),
        "LeftFoot": (35, 0, 0),
        "RightFoot": (35, 0, 0),
    }
    return _mezcla(AGACHADO, arriba, (t - 0.6) / 0.4)


def saltar_aire(t):
    s = onda(t)
    return {
        "raiz": (0, 0, 0.0),
        "LowerTorso": (8, 0, 0),
        "Head": (-5, 0, 0),
        "LeftUpperLeg": (-70 + s * 6, 0, 0),
        "RightUpperLeg": (-35 - s * 6, 0, 0),
        "LeftLowerLeg": (95, 0, 0),
        "RightLowerLeg": (70, 0, 0),
        "LeftFoot": (20, 0, 0),
        "RightFoot": (20, 0, 0),
        "LeftUpperArm": (-110 + s * 8, -25, 0),
        "RightUpperArm": (-110 - s * 8, 25, 0),
        "LeftLowerArm": (-30, 0, 0),
        "RightLowerArm": (-30, 0, 0),
    }


def saltar_caer(t):
    golpe = dict(AGACHADO)
    golpe["LeftUpperArm"] = (-20, -35, 0)
    golpe["RightUpperArm"] = (-20, 35, 0)
    if t < 0.35:
        return _mezcla(saltar_aire(0), golpe, t / 0.35)
    return _mezcla(golpe, DE_PIE, (t - 0.35) / 0.65)


def _tramo(x):
    """Onda de -1 a 1 que se queda un rato en cada punta: el brazo llega, se agarra y recién
    ahí tira (en vez de ir y venir como un péndulo)."""
    return math.tanh(2.2 * x) / math.tanh(2.2)


def trepar(t):
    """De frente a la pared (adelante), torso inclinado 8° hacia ella. Las dos manos van contra
    la pared, al ancho de los hombros. La de arriba se estira y se agarra; la de abajo tira con
    el codo pegado al cuerpo hasta la altura del pecho. La rodilla contraria a la mano de arriba
    sube y la otra pierna empuja. El cuerpo da un tirón para arriba por lado."""
    s = _tramo(onda(t))  # +1: arriba la izquierda; -1: arriba la derecha
    empuje = abs(cos(2 * pi * t))  # 1 justo cuando cambia de lado (el momento de subir)
    izq, der = (s + 1) / 2, (1 - s) / 2  # cuánto está estirado cada brazo (0 a 1)

    def brazo(arriba, lado):
        # Arriba: casi vertical y un poco adelante (contra la pared), sin abrir al costado.
        # Abajo: brazo pegado al torso y antebrazo adelante: la mano queda a la altura del pecho.
        return (
            (-15 - 150 * arriba, lado * -4 * (1 - arriba), 0),
            (-100 * (1 - arriba) - 6, 0, 0),
            (-25 * arriba + 10 * (1 - arriba), 0, 0),
        )

    li, ld = brazo(izq, 1), brazo(der, -1)
    return {
        "raiz": (0, 0, -0.05 + empuje * 0.06),
        "LowerTorso": (8, s * 3, 0),
        "UpperTorso": (0, 0, s * 4),
        "Head": (-14, 0, s * 5),
        "LeftUpperArm": li[0],
        "RightUpperArm": ld[0],
        "LeftLowerArm": li[1],
        "RightLowerArm": ld[1],
        "LeftHand": li[2],
        "RightHand": ld[2],
        # Pierna con la rodilla arriba (la contraria al brazo estirado) y la otra empuja.
        "LeftUpperLeg": (-8 - 62 * der, -3, 0),
        "RightUpperLeg": (-8 - 62 * izq, 3, 0),
        "LeftLowerLeg": (12 + 90 * der, 0, 0),
        "RightLowerLeg": (12 + 90 * izq, 0, 0),
        "LeftFoot": (-15 * der, 0, 0),
        "RightFoot": (-15 * izq, 0, 0),
    }


def volar_quieto(t):
    """Flota casi parado: sube y baja suave, y brazos y piernas siguen el movimiento con un
    poco de atraso (se ve como si el aire lo meciera). Manos abiertas, nada de puño."""
    s = onda(t)
    tarde = onda(t, -0.12)  # lo que sigue al cuerpo con atraso
    mas_tarde = onda(t, -0.22)
    return {
        "raiz": (0, 0, 0.30 + s * 0.05),
        "LowerTorso": (8 + tarde * 2, s * 1.5, 0),
        "UpperTorso": (2 - tarde * 2, 0, 0),
        "Head": (-6 + mas_tarde * 2, 0, 0),
        "LeftUpperArm": (-8 + tarde * 6, -20 - tarde * 6, 0),
        "RightUpperArm": (-8 + tarde * 6, 20 + tarde * 6, 0),
        "LeftLowerArm": (-22 + mas_tarde * 8, 0, 0),
        "RightLowerArm": (-22 + mas_tarde * 8, 0, 0),
        "LeftHand": (mas_tarde * 10, 0, 0),
        "RightHand": (mas_tarde * 10, 0, 0),
        "LeftUpperLeg": (-32 + tarde * 8, -4, 0),
        "RightUpperLeg": (-10 + tarde * 6, 4, 0),
        "LeftLowerLeg": (55 - mas_tarde * 10, 0, 0),
        "RightLowerLeg": (28 - mas_tarde * 8, 0, 0),
        "LeftFoot": (30 + mas_tarde * 8, 0, 0),
        "RightFoot": (30 + mas_tarde * 8, 0, 0),
    }


def volar_avanzando(t):
    """Cuerpo horizontal y estirado, los dos brazos atrás pegados al cuerpo (como alas
    cerradas), un balanceo de costado y las piernas que ondulan detrás con atraso."""
    s = onda(t)
    tarde = onda(t, -0.15)
    mas_tarde = onda(t, -0.3)
    return {
        "raiz": (0, 0, 0.35 + s * 0.03),
        "LowerTorso": (82 + s * 2, s * 7, 0),  # 7° de balanceo sobre el eje de vuelo
        "UpperTorso": (-tarde * 3, 0, -s * 3),
        "Head": (-58 - tarde * 3, 0, 0),
        "LeftUpperArm": (12 + tarde * 4, -14 - tarde * 4, 0),
        "RightUpperArm": (12 - tarde * 4, 14 - tarde * 4, 0),
        "LeftLowerArm": (-6, 0, 0),
        "RightLowerArm": (-6, 0, 0),
        "LeftHand": (15 + mas_tarde * 8, 0, 0),
        "RightHand": (15 - mas_tarde * 8, 0, 0),
        "LeftUpperLeg": (-2 + tarde * 7, -2, 0),
        "RightUpperLeg": (2 - tarde * 7, 2, 0),
        "LeftLowerLeg": (12 + pos(mas_tarde) * 14, 0, 0),
        "RightLowerLeg": (12 + pos(-mas_tarde) * 14, 0, 0),
        "LeftFoot": (40 + mas_tarde * 6, 0, 0),
        "RightFoot": (40 - mas_tarde * 6, 0, 0),
    }


def nadar(t):
    s = onda(t)
    c = cos(2 * pi * t)
    patada = sen(4 * pi * t)
    return {
        "raiz": (0, 0, 0.1 + s * 0.02),
        "LowerTorso": (80, 0, s * 12),
        "UpperTorso": (0, 0, -s * 8),
        "Head": (-50, 0, s * 20),
        # Crol: un brazo pasa por arriba mientras el otro tira para atrás.
        "LeftUpperArm": (-90 - 90 * c, -15 - 20 * pos(s), 0),
        "RightUpperArm": (-90 + 90 * c, 15 + 20 * pos(-s), 0),
        "LeftLowerArm": (-30 * pos(s), 0, 0),
        "RightLowerArm": (-30 * pos(-s), 0, 0),
        "LeftUpperLeg": (patada * 15, 0, 0),
        "RightUpperLeg": (-patada * 15, 0, 0),
        "LeftLowerLeg": (10 + pos(patada) * 15, 0, 0),
        "RightLowerLeg": (10 + pos(-patada) * 15, 0, 0),
        "LeftFoot": (40, 0, 0),
        "RightFoot": (40, 0, 0),
    }


def flotar(t):
    s = onda(t)
    s2 = onda(t * 2)
    return {
        "raiz": (0, 0, s * 0.03),
        "LowerTorso": (10, 0, 0),
        "Head": (-8, 0, s * 5),
        # Brazos abiertos, dibujando ochos para mantenerse.
        "LeftUpperArm": (-20 + s2 * 15, -55, s * 15),
        "RightUpperArm": (-20 - s2 * 15, 55, -s * 15),
        "LeftLowerArm": (-25, 0, 0),
        "RightLowerArm": (-25, 0, 0),
        "LeftUpperLeg": (-25 + s * 20, 5, 0),
        "RightUpperLeg": (-25 - s * 20, -5, 0),
        "LeftLowerLeg": (45 - s * 15, 0, 0),
        "RightLowerLeg": (45 + s * 15, 0, 0),
        "LeftFoot": (30, 0, 0),
        "RightFoot": (30, 0, 0),
    }


# ---------------------------------------------------------------------------
# Combate del jugador, estilo Puños (P26-02). Cada animación es una lista de poses clave
# (cuadro, pose) que se mezclan suave; GUARDIA es la pose de pelea de la que salen y a la que
# vuelven. Torso Z negativo = gira a su derecha (adelanta el hombro izquierdo).
# ---------------------------------------------------------------------------


def secuencia(t, cuadros, claves):
    """Pose en la fase t (0 a 1) mezclando las poses clave [(cuadro, pose), ...]."""
    f = t * cuadros
    for (f0, p0), (f1, p1) in zip(claves, claves[1:]):
        if f <= f1:
            return _mezcla(p0, p1, 0.0 if f1 == f0 else (f - f0) / (f1 - f0))
    return _mezcla(claves[-1][1], claves[-1][1], 0)


def con(base, **cambios):
    """Copia de una pose con algunos huesos cambiados."""
    p = dict(base)
    p.update(cambios)
    return p


GUARDIA = {
    "raiz": (0, 0, -0.14),
    "LowerTorso": (8, 0, -20),
    "UpperTorso": (4, 0, 0),
    # Cabeza apenas agachada, detrás de los puños.
    "Head": (12, 0, 12),
    # Codos pegados al cuerpo (cuidan las costillas) y puños a la altura del mentón. En reposo el
    # brazo del maniquí ya sale abierto: +Y cierra el izquierdo hacia el cuerpo, -Y el derecho.
    "LeftUpperArm": (-44, 34, -16),
    "RightUpperArm": (-36, -34, 18),
    "LeftLowerArm": (-138, 0, 0),
    "RightLowerArm": (-145, 0, 0),
    # Pierna izquierda adelante, derecha atrás, rodillas bien flexionadas (lista para moverse).
    # El giro Z de las piernas compensa el de la cadera: los pies siguen mirando adelante.
    "LeftUpperLeg": (-36, -6, 20),
    "RightUpperLeg": (4, 6, 20),
    "LeftLowerLeg": (58, 0, 0),
    "RightLowerLeg": (55, 0, 0),
    "LeftFoot": (-18, 0, 0),
    "RightFoot": (-22, 0, 0),
}


def _giro_arriba(z, base=GUARDIA):
    """Giro de los hombros (UpperTorso) sin mover la cadera: los pies quedan como en la guardia."""
    x, y, _ = base["UpperTorso"]
    return (x, y, z)


def golpe_1(t):
    # Jab derecho: carga (0-4), estira (6, Impacto) y vuelve (7-14).
    # Los pies no se mueven: gira solo el torso y el peso pasa al pie de adelante (la cadera
    # se corre adelante y la rodilla de adelante se dobla un poco más).
    carga = con(
        GUARDIA,
        UpperTorso=_giro_arriba(-10),
        RightUpperArm=(-22, -22, 18),
        RightLowerArm=(-145, 0, 0),
    )
    pega = con(
        GUARDIA,
        raiz=(0, -0.06, -0.16),
        LowerTorso=(14, 0, -20),
        UpperTorso=_giro_arriba(32),
        RightUpperArm=(-88, 4, -8),
        RightLowerArm=(-4, 0, 0),
        LeftLowerLeg=(66, 0, 0),
        RightLowerLeg=(40, 0, 0),
    )
    return secuencia(t, 14, [(0, GUARDIA), (4, carga), (6, pega), (8, pega), (14, GUARDIA)])


def golpe_2(t):
    # Cross izquierdo: gira la cadera y estira el brazo izquierdo (Impacto 6).
    carga = con(GUARDIA, UpperTorso=_giro_arriba(12), LeftUpperArm=(-32, 20, -15), LeftLowerArm=(-145, 0, 0))
    pega = con(
        GUARDIA,
        raiz=(0, -0.05, -0.06),
        LowerTorso=(12, 0, -20),
        UpperTorso=_giro_arriba(-30),
        LeftUpperArm=(-88, -4, 10),
        LeftLowerArm=(-4, 0, 0),
        RightUpperArm=(-35, 14, 20),
        RightUpperLeg=(16, 6, 30),
        RightFoot=(-25, 0, 0),
    )
    return secuencia(t, 14, [(0, GUARDIA), (4, carga), (6, pega), (8, pega), (14, GUARDIA)])


def golpe_3(t):
    # Gancho ascendente derecho: se agacha y sube con todo el cuerpo (Impacto 8).
    abajo = con(
        GUARDIA,
        raiz=(0, 0, -0.15),
        LowerTorso=(18, 0, -20),
        UpperTorso=_giro_arriba(-12),
        RightUpperArm=(-5, 18, 10),
        RightLowerArm=(-95, 0, 0),
        LeftUpperLeg=(-40, -6, 20),
        RightUpperLeg=(-5, 6, 20),
        LeftLowerLeg=(60, 0, 0),
        RightLowerLeg=(55, 0, 0),
    )
    arriba = con(
        GUARDIA,
        raiz=(0, -0.04, 0.04),
        LowerTorso=(-8, 0, -20),
        UpperTorso=_giro_arriba(30),
        Head=(-15, 0, 5),
        RightUpperArm=(-150, 18, -5),
        RightLowerArm=(-60, 0, 0),
        LeftUpperLeg=(-15, -6, 15),
        RightUpperLeg=(5, 6, 15),
        LeftLowerLeg=(8, 0, 0),
        RightLowerLeg=(8, 0, 0),
        RightFoot=(-30, 0, 0),
    )
    return secuencia(t, 18, [(0, GUARDIA), (5, abajo), (8, arriba), (10, arriba), (18, GUARDIA)])


def golpe_4(t):
    # Patada giratoria que empuja: carga (0-8), da la vuelta y patea con la derecha (12,
    # Impacto), termina la vuelta y cae en guardia (24).
    carga = con(
        GUARDIA,
        raiz=(0, 0, -0.1),
        LowerTorso=(10, 0, 30),
        LeftUpperArm=(-30, -30, 0),
        RightUpperArm=(-30, 30, 0),
        LeftLowerLeg=(45, 0, 0),
        RightLowerLeg=(40, 0, 0),
    )
    patada = {
        "raiz": (0, 0, 0.02),
        "LowerTorso": (0, -28, 180),
        "UpperTorso": (0, 8, 0),
        "Head": (0, 15, 0),
        "LeftUpperArm": (-20, -55, 0),
        "RightUpperArm": (-20, 60, 0),
        "LeftLowerArm": (-60, 0, 0),
        "RightLowerArm": (-60, 0, 0),
        "LeftUpperLeg": (0, 6, 0),
        "LeftLowerLeg": (12, 0, 0),
        "RightUpperLeg": (-25, 95, 0),
        "RightLowerLeg": (5, 0, 0),
        "RightFoot": (30, 0, 0),
    }
    sigue = con(patada, LowerTorso=(5, -10, 270), RightUpperLeg=(-10, 40, 0), RightLowerLeg=(40, 0, 0))
    fin = con(GUARDIA, LowerTorso=(6, 0, 340))
    return secuencia(t, 24, [(0, GUARDIA), (8, carga), (12, patada), (14, patada), (18, sigue), (24, fin)])


def golpe_aire(t):
    """Ataque desde arriba (golpe en el aire): sube las rodillas, junta los puños sobre la
    cabeza y los baja de un martillazo (Impacto 12); cae en guardia."""
    # Preparación: se estira para arriba (puntas de pie, torso largo), puños arriba y abiertos
    # hacia afuera (con el brazo arriba, +Y abre el izquierdo): no cruzan la cabeza.
    arriba = {
        "raiz": (0, 0.02, 0.07),
        "LowerTorso": (-6, 0, 0),
        "UpperTorso": (-6, 0, 0),
        "Head": (-14, 0, 0),
        "LeftUpperArm": (-168, 22, 0),
        "RightUpperArm": (-168, -22, 0),
        "LeftLowerArm": (-35, 0, 0),
        "RightLowerArm": (-35, 0, 0),
        "LeftUpperLeg": (-4, -3, 0),
        "RightUpperLeg": (4, 3, 0),
        "LeftFoot": (45, 0, 0),
        "RightFoot": (45, 0, 0),
    }
    # Golpe: cae con todo, rodillas bien dobladas, torso adelante y los puños terminan abajo,
    # cerca del piso.
    abajo = {
        "raiz": (0, -0.08, -0.36),
        "LowerTorso": (50, 0, 0),
        "UpperTorso": (15, 0, 0),
        "Head": (-30, 0, 0),
        "LeftUpperArm": (-35, 10, 0),
        "RightUpperArm": (-35, -10, 0),
        "LeftLowerArm": (-5, 0, 0),
        "RightLowerArm": (-5, 0, 0),
        "LeftUpperLeg": (-95, -8, 0),
        "RightUpperLeg": (-60, 8, 0),
        "LeftLowerLeg": (110, 0, 0),
        "RightLowerLeg": (120, 0, 0),
        "LeftFoot": (-15, 0, 0),
        "RightFoot": (25, 0, 0),
    }
    return secuencia(t, 22, [(0, GUARDIA), (8, arriba), (12, abajo), (15, abajo), (22, GUARDIA)])


BLOQUEO = con(
    GUARDIA,
    raiz=(0, 0, -0.1),
    LowerTorso=(10, 0, -10),
    Head=(10, 0, 5),
    # Antebrazos cruzados delante de la cara.
    LeftUpperArm=(-55, -8, -40),
    RightUpperArm=(-55, 8, 40),
    LeftLowerArm=(-95, 0, -35),
    RightLowerArm=(-95, 0, 35),
    LeftLowerLeg=(40, 0, 0),
    RightLowerLeg=(35, 0, 0),
)


def bloqueo_inicio(t):
    return secuencia(t, 4, [(0, GUARDIA), (4, BLOQUEO)])


def bloqueo(t):
    s = onda(t)
    return con(BLOQUEO, raiz=(0, 0, -0.1 + s * 0.008), UpperTorso=(4 + s * 1.5, 0, 0))


def parry(t):
    # Corto y seco (distinto del bloqueo, que se queda quieto): en 3 cuadros los dos antebrazos
    # empujan hacia afuera y adelante y el cuerpo da medio paso adelante (Impacto 3); aguanta
    # hasta el 5 y vuelve a la guardia.
    empuja = con(
        GUARDIA,
        raiz=(0, -0.12, -0.15),
        LowerTorso=(14, 0, -20),
        Head=(4, 0, 12),
        LeftUpperArm=(-75, -18, -20),
        RightUpperArm=(-75, 18, 20),
        LeftLowerArm=(-45, 0, 0),
        RightLowerArm=(-45, 0, 0),
        LeftHand=(0, -15, 0),
        RightHand=(0, 15, 0),
        LeftUpperLeg=(-48, -6, 20),
        LeftLowerLeg=(62, 0, 0),
        RightUpperLeg=(14, 6, 20),
    )
    return secuencia(t, 12, [(0, GUARDIA), (3, empuja), (5, empuja), (12, GUARDIA)])


def _dash(lean, brazos, piernas):
    """Pose máxima de un dash: el cuerpo se inclina hacia donde va, brazos y piernas quedan
    atrás (sin pasos: los pies juntos se deslizan)."""
    return con(
        GUARDIA,
        raiz=(0, 0, -0.08),
        LowerTorso=lean,
        LeftUpperArm=brazos[0],
        RightUpperArm=brazos[1],
        LeftLowerArm=(-60, 0, 0),
        RightLowerArm=(-60, 0, 0),
        LeftUpperLeg=piernas,
        RightUpperLeg=piernas,
        LeftLowerLeg=(30, 0, 0),
        RightLowerLeg=(30, 0, 0),
    )


DASH = {
    "adelante": _dash((30, 0, 0), ((40, -10, 0), (40, 10, 0)), (15, 0, 0)),
    "atras": _dash((-18, 0, 0), ((-55, -20, 0), (-55, 20, 0)), (-25, 0, 0)),
    "izquierda": _dash((5, 22, 0), ((-30, -45, 0), (-10, 10, 0)), (5, 18, 0)),
    "derecha": _dash((5, -22, 0), ((-10, -10, 0), (-30, 45, 0)), (5, -18, 0)),
}


def _hacer_dash(lado):
    def dash(t):
        return secuencia(t, 8, [(0, GUARDIA), (2, DASH[lado]), (5, DASH[lado]), (8, GUARDIA)])

    return dash


def golpe_liviano(t):
    tira = con(
        GUARDIA,
        raiz=(0, 0.04, -0.05),
        LowerTorso=(-6, 0, -25),
        UpperTorso=(-8, 0, 0),
        Head=(-25, 0, 20),
    )
    return secuencia(t, 10, [(0, GUARDIA), (2, tira), (4, tira), (10, GUARDIA)])


def golpe_fuerte(t):
    vuela = con(
        GUARDIA,
        raiz=(0, 0.15, -0.08),
        LowerTorso=(-25, 0, -10),
        UpperTorso=(-12, 0, 0),
        Head=(-30, 0, 0),
        LeftUpperArm=(-70, -60, 0),
        RightUpperArm=(-70, 60, 0),
        LeftLowerArm=(-20, 0, 0),
        RightLowerArm=(-20, 0, 0),
        LeftUpperLeg=(-35, -8, 0),
        RightUpperLeg=(-10, 8, 0),
        LeftLowerLeg=(30, 0, 0),
    )
    retoma = con(
        GUARDIA,
        raiz=(0, 0.25, -0.14),
        LowerTorso=(25, 0, -15),
        LeftLowerLeg=(55, 0, 0),
        RightLowerLeg=(50, 0, 0),
    )
    return secuencia(t, 18, [(0, GUARDIA), (3, vuela), (7, vuela), (12, retoma), (18, GUARDIA)])


def aturdido(t):
    s, c = onda(t), cos(2 * pi * t)
    return {
        "raiz": (0, 0, -0.05 + abs(s) * 0.01),
        "LowerTorso": (12 + c * 4, s * 6, 0),
        "UpperTorso": (8, 0, 0),
        "Head": (20 + c * 6, -s * 10, s * 8),
        "LeftUpperArm": (5 + c * 6, -4, 0),
        "RightUpperArm": (5 - c * 6, 4, 0),
        "LeftLowerArm": (-15, 0, 0),
        "RightLowerArm": (-15, 0, 0),
        "LeftUpperLeg": (-8, -s * 4, 0),
        "RightUpperLeg": (4, -s * 4, 0),
        "LeftLowerLeg": (20 + c * 6, 0, 0),
        "RightLowerLeg": (14 - c * 6, 0, 0),
    }


RODILLAS = {
    "raiz": (0, 0, -0.33),
    "LowerTorso": (35, 0, 0),
    "UpperTorso": (15, 0, 0),
    "Head": (5, 0, 0),
    "LeftUpperArm": (-40, -8, 0),
    "RightUpperArm": (-40, 8, 0),
    "LeftLowerArm": (-10, 0, 0),
    "RightLowerArm": (-10, 0, 0),
    "LeftUpperLeg": (-35, -6, 0),
    "RightUpperLeg": (-35, 6, 0),
    "LeftLowerLeg": (125, 0, 0),
    "RightLowerLeg": (125, 0, 0),
    "LeftFoot": (35, 0, 0),
    "RightFoot": (35, 0, 0),
}
# En el piso en cuatro patas (manos apoyadas, cabeza gacha).
CUATRO = con(
    RODILLAS,
    raiz=(0, 0, -0.38),
    LowerTorso=(70, 0, 0),
    UpperTorso=(10, 0, 0),
    Head=(-15, 0, 0),
    LeftUpperArm=(-70, -8, 0),
    RightUpperArm=(-70, 8, 0),
    LeftLowerArm=(0, 0, 0),
    RightLowerArm=(0, 0, 0),
    LeftUpperLeg=(-60, -6, 0),
    RightUpperLeg=(-60, 6, 0),
    LeftLowerLeg=(120, 0, 0),
    RightLowerLeg=(120, 0, 0),
)
EN_EL_PISO = con(CUATRO, Head=(-5, 0, 0))


def derrota(t):
    tambalea = con(
        GUARDIA,
        LowerTorso=(-12, 10, 0),
        Head=(-25, 0, 10),
        LeftUpperArm=(5, -20, 0),
        RightUpperArm=(5, 20, 0),
        LeftLowerArm=(-10, 0, 0),
        RightLowerArm=(-10, 0, 0),
    )
    return secuencia(t, 40, [(0, GUARDIA), (8, tambalea), (20, RODILLAS), (30, CUATRO), (40, EN_EL_PISO)])


def levantarse(t):
    una = con(
        RODILLAS,
        raiz=(0, 0, -0.2),
        LowerTorso=(30, 0, 0),
        LeftUpperLeg=(-85, -6, 0),
        LeftLowerLeg=(90, 0, 0),
        LeftFoot=(-5, 0, 0),
        LeftUpperArm=(-30, -10, 0),
        RightUpperArm=(-10, 10, 0),
    )
    return secuencia(t, 30, [(0, EN_EL_PISO), (10, RODILLAS), (18, una), (26, GUARDIA), (30, GUARDIA)])


# nombre: (función, cuadros, loop, prioridad en Roblox, cuadros clave para la tira)
ANIMACIONES = {
    "quieto": (quieto, 60, True, "Core", (0, 27, 45)),
    "caminar": (caminar, 32, True, "Movement", (0, 8, 16)),
    "correr": (correr, 20, True, "Movement", (0, 5, 10)),
    "correr-rapido": (correr_rapido, 14, True, "Movement", (0, 4, 7)),
    "saltar-inicio": (saltar_inicio, 8, False, "Movement", (0, 5, 8)),
    "saltar-aire": (saltar_aire, 20, True, "Movement", (0, 5, 10)),
    "saltar-caer": (saltar_caer, 10, False, "Movement", (0, 4, 10)),
    "trepar": (trepar, 24, True, "Movement", (6, 12, 18)),
    "volar-quieto": (volar_quieto, 60, True, "Movement", (0, 15, 45)),
    "volar-avanzando": (volar_avanzando, 30, True, "Movement", (0, 8, 15)),
    "nadar": (nadar, 40, True, "Movement", (0, 10, 20)),
    "flotar": (flotar, 60, True, "Movement", (0, 15, 30)),
    # Combate (Puños).
    "golpe-1": (golpe_1, 14, False, "Action", (4, 6, 11)),
    "golpe-2": (golpe_2, 14, False, "Action", (4, 6, 11)),
    "golpe-3": (golpe_3, 18, False, "Action", (5, 8, 14)),
    "golpe-4": (golpe_4, 24, False, "Action", (8, 12, 20)),
    "golpe-aire": (golpe_aire, 22, False, "Action", (8, 12, 18)),
    "bloqueo-inicio": (bloqueo_inicio, 4, False, "Action", (0, 2, 4)),
    "bloqueo": (bloqueo, 30, True, "Action", (0, 8, 15)),
    "parry": (parry, 12, False, "Action", (1, 3, 8)),
    "dash-adelante": (_hacer_dash("adelante"), 8, False, "Action", (1, 3, 7)),
    "dash-atras": (_hacer_dash("atras"), 8, False, "Action", (1, 3, 7)),
    "dash-izquierda": (_hacer_dash("izquierda"), 8, False, "Action", (1, 3, 7)),
    "dash-derecha": (_hacer_dash("derecha"), 8, False, "Action", (1, 3, 7)),
    "golpe-liviano": (golpe_liviano, 10, False, "Action", (0, 3, 7)),
    "golpe-fuerte": (golpe_fuerte, 18, False, "Action", (2, 5, 13)),
    "aturdido": (aturdido, 40, True, "Action", (0, 10, 20)),
    "derrota": (derrota, 40, False, "Action", (8, 20, 40)),
    "levantarse": (levantarse, 30, False, "Action", (0, 18, 30)),
}

# Nombre que se lee en la columna de la hoja (hoja.py); "/" corta la línea.
ETIQUETAS = {
    "golpe-1": "Golpe 1/jab derecho",
    "golpe-2": "Golpe 2/cross izquierdo",
    "golpe-3": "Golpe 3/gancho ascendente",
    "golpe-4": "Golpe 4/patada giratoria",
    "golpe-aire": "Ataque desde/arriba",
    "bloqueo-inicio": "Bloqueo/(inicio)",
    "bloqueo": "Bloqueo/(loop)",
    "parry": "Parry",
    "dash-adelante": "Dash/adelante",
    "dash-atras": "Dash/atrás",
    "dash-izquierda": "Dash/izquierda",
    "dash-derecha": "Dash/derecha",
    "golpe-liviano": "Recibe golpe/liviano",
    "golpe-fuerte": "Recibe golpe/fuerte",
    "aturdido": "Aturdido",
    "derrota": "Derrota",
    "levantarse": "Levantarse",
}

# Grupos para renders, GIFs y FBX (`-- renders combate`); sin grupo, todas.
_COMBATE = ("golpe", "bloqueo", "parry", "dash", "aturdido", "derrota", "levantarse")
GRUPOS = {
    "locomocion": [n for n in ANIMACIONES if not n.startswith(_COMBATE)],
    "combate": [n for n in ANIMACIONES if n.startswith(_COMBATE)],
}

# Trepar se ve desde atrás, como lo ve el jugador con la cámara del juego.
GIRO_CAMARA = {"trepar": 150}
# En el juego la cámara va detrás del personaje: el combate se mira de espaldas, un poco
# corrido a su derecha para que se vea hasta dónde llega el golpe.
GIRO_CAMARA.update({n: 135 for n in GRUPOS["combate"]})
# GIFs a 30 fps (un cuadro por cuadro) y desde varias vistas: nombre -> {vista: giro de cámara}.
GIF_VISTAS = {"trepar": {"atras": 150, "costado": 90}}
GIF_VISTAS.update({n: {"atras": 135} for n in GRUPOS["combate"]})

# Marcadores: "Paso" (polvo y sonido de pisada) e "Impacto" (cuando pega: daño, efecto, sonido
# y sacudida de cámara salen de acá, no de un tiempo fijo).
MARCADORES = {
    "caminar": [(0, "Paso"), (16, "Paso")],
    "correr": [(0, "Paso"), (10, "Paso")],
    "correr-rapido": [(0, "Paso"), (7, "Paso")],
    "saltar-caer": [(4, "Paso")],
    "golpe-1": [(6, "Impacto")],
    "golpe-2": [(6, "Impacto")],
    "golpe-3": [(8, "Impacto")],
    "golpe-4": [(12, "Impacto")],
    "golpe-aire": [(12, "Impacto")],
    "parry": [(3, "Impacto")],
}


def _a_local(pb, giro_mundo):
    """Giro en ejes del mundo (alrededor de la cabeza del hueso) -> giro local del pose bone."""
    m = pb.bone.matrix_local.to_3x3()
    return (m.inverted() @ giro_mundo.to_matrix() @ m).to_quaternion()


def poner_pose(arm, pose):
    for pb in arm.pose.bones:
        x, y, z = pose.get(pb.name, (0, 0, 0))
        e = Euler((math.radians(x), math.radians(y), math.radians(z)), "ZYX")
        pb.rotation_mode = "QUATERNION"
        pb.rotation_quaternion = _a_local(pb, e)
        pb.location = (0, 0, 0)
    raiz = arm.pose.bones["LowerTorso"]
    raiz.location = raiz.bone.matrix_local.to_3x3().inverted() @ Vector(pose.get("raiz", (0, 0, 0)))
    if "_hombros" in pose:  # sube los hombros sin mover el torso
        sube = Vector((0, 0, pose["_hombros"]))
        for n in ("LeftUpperArm", "RightUpperArm"):
            pb = arm.pose.bones[n]
            pb.location = pb.bone.matrix_local.to_3x3().inverted() @ sube


def crear_accion(arm, nombre):
    funcion, cuadros, loop, prioridad, _ = ANIMACIONES[nombre]
    viejo = bpy.data.actions.get(nombre)
    if viejo:
        bpy.data.actions.remove(viejo)
    accion = bpy.data.actions.new(nombre)
    accion.use_fake_user = True
    accion.use_frame_range = True
    accion.frame_start, accion.frame_end = 0, cuadros
    accion.use_cyclic = loop
    accion["loop"] = loop
    accion["prioridad"] = prioridad
    arm.animation_data_create()
    arm.animation_data.action = accion
    cuadros_clave = sorted(set(list(range(0, cuadros, PASO_CLAVE)) + [cuadros]))
    for f in cuadros_clave:
        t = f / cuadros
        poner_pose(arm, funcion(0.0 if (loop and f == cuadros) else t))
        for pb in arm.pose.bones:
            pb.keyframe_insert("rotation_quaternion", frame=f)
            pb.keyframe_insert("location", frame=f)
    for f, marca in MARCADORES.get(nombre, ()):
        accion.pose_markers.new(marca).frame = f
    return accion


def chequear_cruces(arm, nombre):
    """Devuelve los cuadros en que alguna mano se mete en la cabeza (caja de la cabeza con
    3 cm de margen, en los ejes de la cabeza)."""
    escena = bpy.context.scene
    cabeza = bpy.data.objects["Cuerpo_Head"]
    lado = Vector(cabeza.dimensions) / 2 + Vector((0.03, 0.03, 0.03))
    malos = []
    for f in range(0, ANIMACIONES[nombre][1] + 1):
        escena.frame_set(f)
        inversa = cabeza.matrix_world.inverted()
        for mano in ("Cuerpo_LeftHand", "Cuerpo_RightHand", "Cuerpo_LeftLowerArm", "Cuerpo_RightLowerArm"):
            obj = bpy.data.objects[mano]
            for v in obj.bound_box:
                p = inversa @ (obj.matrix_world @ Vector(v))
                if abs(p.x) < lado.x and abs(p.y) < lado.y and abs(p.z) < lado.z:
                    malos.append((f, mano))
                    break
    return malos


def acciones():
    bpy.ops.wm.open_mainfile(filepath=CUERPO)
    escena = bpy.context.scene
    escena.render.fps = FPS
    escena.render.fps_base = 1
    arm = B.esqueleto()
    for nombre in ANIMACIONES:
        crear_accion(arm, nombre)
        cruces = chequear_cruces(arm, nombre)
        print(f"CRUCES {nombre}: {len(cruces)} {cruces[:6]}")
    arm.animation_data.action = bpy.data.actions["quieto"]
    escena.frame_start, escena.frame_end = 0, 60
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)


# ---------------------------------------------------------------------------
# Renders
# ---------------------------------------------------------------------------


def _camara(giro=60):
    datos = bpy.data.cameras.get("CamAnim") or bpy.data.cameras.new("CamAnim")
    datos.lens = B.LENTE
    cam = bpy.data.objects.get("CamAnim") or bpy.data.objects.new("CamAnim", datos)
    if cam.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(cam)
    # Tres cuartos de costado (desde la derecha del personaje), un poco desde arriba.
    centro = Vector((0, -0.05, 0.75))
    a, e = math.radians(giro), math.radians(8)
    desde = centro + Vector((-math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e))) * 3.3
    B._apuntar(cam, desde, centro)
    return cam


def _mirar_desde(escena, nombre):
    """Pone la cámara de la animación y gira las luces con ella (si no, desde atrás la luz
    naranja de borde le pega de frente)."""
    giro = GIRO_CAMARA.get(nombre, 60)
    escena.camera = _camara(giro)
    for o in (bpy.data.objects.get(n) for n in ("LuzPrincipal", "LuzBorde", "LuzRelleno")):
        if o:
            if "original" not in o:
                o["original"] = [v for fila in o.matrix_world for v in fila]
            m = Matrix([o["original"][i : i + 4] for i in range(0, 16, 4)])
            o.matrix_world = Matrix.Rotation(math.radians(60 - giro), 4, "Z") @ m


def renders(grupo=None):
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    escena = bpy.context.scene
    B.configurar_luz()
    escena.camera = _camara()
    escena.render.resolution_x, escena.render.resolution_y = 520, 640
    escena.view_settings.exposure = 1.2  # el cuerpo es azul oscuro: se pierde con la luz de los trajes
    arm = B.esqueleto()
    tiras = []
    for nombre in GRUPOS.get(grupo, ANIMACIONES):
        clave = ANIMACIONES[nombre][4]
        arm.animation_data.action = bpy.data.actions[nombre]
        _mirar_desde(escena, nombre)
        cuadros = []
        for i, f in enumerate(clave):
            escena.frame_set(f)
            ruta = os.path.join(B.RENDERS, f"_anim-base-{nombre}-{i}.png")
            escena.render.filepath = ruta
            bpy.ops.render.render(write_still=True)
            cuadros.append(ruta)
        tira = B.hoja([cuadros], os.path.join(B.RENDERS, f"anim-base-{nombre}.png"))
        for r in cuadros:
            os.remove(r)
        tiras.append(tira)
    # Hoja: 2 animaciones por fila (6 cuadros), a la mitad de tamaño.
    filas = [tiras[i : i + 2] for i in range(0, len(tiras), 2)]
    sufijo = "" if grupo in (None, "locomocion") else f"-{grupo}"
    # Lista para hoja.py, que arma la hoja con una columna de nombres a la izquierda.
    with open(os.path.join(B.RENDERS, f"_hoja{sufijo}.txt"), "w", encoding="utf-8") as fh:
        for nombre in GRUPOS.get(grupo, ANIMACIONES):
            fh.write(f"{nombre}|{ETIQUETAS.get(nombre, nombre)}\n")
    B.hoja(filas, os.path.join(B.RENDERS, f"anim-base-hoja{sufijo}.png"), reducir=2)
    if grupo == "combate":
        render_guardia()


def render_guardia():
    """La guardia quieta en 3 vistas (frente, costado y espalda): renders/anim-base-guardia.png."""
    escena = bpy.context.scene
    arm = B.esqueleto()
    arm.animation_data.action = None
    poner_pose(arm, GUARDIA)
    cuadros = []
    for i, giro in enumerate((0, 90, 180)):
        GIRO_CAMARA["_vista"] = giro
        _mirar_desde(escena, "_vista")
        ruta = os.path.join(B.RENDERS, f"_anim-base-guardia-{i}.png")
        escena.render.filepath = ruta
        bpy.ops.render.render(write_still=True)
        cuadros.append(ruta)
    B.hoja([cuadros], os.path.join(B.RENDERS, "anim-base-guardia.png"))
    for r in cuadros:
        os.remove(r)


def cuadros_gif(grupo=None):
    """Cuadros chicos de cada animación (uno cada 2: 15 por segundo; las de GIF_VISTAS, todos
    los cuadros y una carpeta por vista) en renders/_gif/<nombre>/.
    Después gifs.py (Python común, con Pillow) los junta en renders/anim-base-<nombre>.gif."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    escena = bpy.context.scene
    B.configurar_luz()
    escena.camera = _camara()
    escena.render.resolution_x, escena.render.resolution_y = 300, 370
    escena.view_settings.exposure = 1.2
    arm = B.esqueleto()
    for nombre in GRUPOS.get(grupo, ANIMACIONES):
        _, cuadros, loop, _, _ = ANIMACIONES[nombre]
        arm.animation_data.action = bpy.data.actions[nombre]
        fin = cuadros if loop else cuadros + 1  # el loop no repite el último (es igual al primero)
        vistas = GIF_VISTAS.get(nombre)
        for vista, giro in (vistas or {"": GIRO_CAMARA.get(nombre, 60)}).items():
            GIRO_CAMARA["_gif"] = giro
            _mirar_desde(escena, "_gif")
            carpeta = os.path.join(B.RENDERS, "_gif", nombre + (f"-{vista}" if vista else ""))
            os.makedirs(carpeta, exist_ok=True)
            paso = 1 if vistas else 2
            with open(os.path.join(carpeta, "fps.txt"), "w") as f:
                f.write(str(FPS // paso))
            for f in range(0, fin, paso):
                escena.frame_set(f)
                escena.render.filepath = os.path.join(carpeta, f"{f:03d}.png")
                bpy.ops.render.render(write_still=True)


# ---------------------------------------------------------------------------
# FBX para Studio
# ---------------------------------------------------------------------------


def fbx(grupo=None):
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    escena = bpy.context.scene
    arm = B.esqueleto()
    os.makedirs(SALIDA_FBX, exist_ok=True)
    for o in escena.objects:
        o.select_set(o == arm)
    bpy.context.view_layer.objects.active = arm
    for nombre in GRUPOS.get(grupo, ANIMACIONES):
        cuadros = ANIMACIONES[nombre][1]
        arm.animation_data.action = bpy.data.actions[nombre]
        escena.frame_start, escena.frame_end = 0, cuadros
        bpy.ops.export_scene.fbx(
            filepath=os.path.join(SALIDA_FBX, f"{nombre}.fbx"),
            use_selection=True,
            object_types={"ARMATURE"},
            global_scale=1 / B.STUD,
            apply_unit_scale=True,
            apply_scale_options="FBX_SCALE_UNITS",
            axis_forward="Z",
            axis_up="Y",
            add_leaf_bones=False,
            bake_anim=True,
            bake_anim_use_all_actions=False,
            bake_anim_use_nla_strips=False,
            bake_anim_step=1.0,
            bake_anim_simplify_factor=0.0,
        )


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    grupo = pasos[1] if len(pasos) > 1 else None
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        renders(grupo)
    if paso in ("gifs", "todo"):
        cuadros_gif(grupo)
    if paso == "fbx":
        fbx(grupo)
