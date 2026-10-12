"""Catalizador Slime (ideas/mutant-lab-arte.md, sección 9): frasco que gotea slime verde.

Frasco rechoncho de cuello largo, lleno de slime hasta la mitad. El slime desborda por la boca,
levanta la tapa y chorrea por los costados. Mallas: frasco (_Vidrio), slime (_Neon, lo jugable
brilla) y tapa (metal).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bmesh  # noqa: E402
from mathutils import Matrix  # noqa: E402

import comun as C  # noqa: E402

NOMBRE = "CatalizadorSlime"

# Perfil de afuera del frasco (radio, altura), de la base hasta el borde de la boca.
AFUERA = [
    (0.0, 0.0),
    (0.26, 0.0),
    (0.38, 0.03),
    (0.52, 0.15),
    (0.60, 0.36),
    (0.58, 0.56),
    (0.48, 0.72),
    (0.32, 0.82),
    (0.22, 0.88),
    (0.19, 0.95),
    (0.19, 1.15),
    (0.25, 1.20),
    (0.25, 1.27),
]
# La boca: el borde se redondea hacia adentro y baja un poco (el slime la llena).
BOCA = [(0.21, 1.31), (0.15, 1.29), (0.14, 1.18), (0.0, 1.16)]
BORDE = 1.27  # altura del borde de la boca

# Slime de adentro: hasta la mitad, separado del vidrio para que el vidrio se vea.
RELLENO = [(0.0, 0.05), (0.24, 0.05), (0.34, 0.08), (0.46, 0.18), (0.53, 0.36), (0.52, 0.48), (0.3, 0.53), (0.0, 0.54)]


def radio_frasco(z):
    """Radio de afuera del frasco a la altura z (para que los chorros se peguen al vidrio)."""
    for (r0, z0), (r1, z1) in zip(AFUERA[1:], AFUERA[2:]):
        if z0 <= z <= z1:
            return r0 + (r1 - r0) * (z - z0) / max(z1 - z0, 1e-6)
    return AFUERA[-1][0]


def chorro(angulo_grados, z_final, grosor=0.08):
    """Un chorro de slime que baja pegado al frasco desde la boca, se afina y termina en una
    gota gorda."""
    a = math.radians(angulo_grados)
    bolas = []
    z = BORDE - 0.04
    while z > z_final + 0.05:
        t = (BORDE - z) / (BORDE - z_final)
        g = grosor * (1.0 - 0.3 * t)  # más finito a medida que baja
        r = radio_frasco(z)  # medio hundido en el vidrio: se ve pegado
        bolas.append(((r * math.cos(a), r * math.sin(a), z), g))
        z -= 0.02
    for dz, escala, afuera in ((0.03, 1.1, 0.02), (-0.025, 1.45, 0.035)):  # la gota
        r = radio_frasco(z_final + dz) + afuera
        bolas.append(((r * math.cos(a), r * math.sin(a), z_final + dz), grosor * escala))
    return bolas


def construir():
    # Frasco
    bm = bmesh.new()
    C.torno(bm, AFUERA + BOCA, segmentos=20)
    frasco = C.malla(f"{NOMBRE}_Frasco_Vidrio", bm, "Laboratorio.CupulaAbierta")

    # Slime: el que llena el frasco + el que desborda por la boca y chorrea.
    bm = bmesh.new()
    C.torno(bm, RELLENO, segmentos=20)
    # Lo que desborda: una cúpula en la boca (más alta del lado de la tapa levantada) y un
    # rollo parejo que cae por encima del borde.
    bolas = [((0.0, 0.0, BORDE + 0.01), 0.17), ((0.07, 0.0, BORDE + 0.08), 0.14)]
    for i in range(16):
        a = 2 * math.pi * i / 16
        bolas.append(((0.24 * math.cos(a), 0.24 * math.sin(a), BORDE - 0.02), 0.08))
    # El frente mira a -Y (ángulo -90). Chorros adelante a la derecha, adelante a la izquierda y al costado.
    bolas += chorro(-60, 0.5) + chorro(-128, 0.88, 0.07) + chorro(12, 0.42)
    C.metabolas(bm, bolas, resolucion=0.04)
    slime = C.malla(f"{NOMBRE}_Slime_Neon", bm, "Catalizadores.Slime", angulo_suave=180)
    C.diezmar(slime, 640, angulo_suave=180)

    # Tapa de metal, torcida y levantada por el slime del lado derecho.
    bm = bmesh.new()
    perfil = [
        (0.0, 0.0),
        (0.22, 0.0),
        (0.27, 0.03),
        (0.28, 0.08),
        (0.27, 0.13),
        (0.23, 0.16),
        (0.11, 0.17),
        (0.09, 0.19),
        (0.10, 0.24),
        (0.065, 0.28),
        (0.0, 0.28),
    ]
    lugar = Matrix.Translation((-0.02, 0.0, BORDE + 0.13)) @ Matrix.Rotation(math.radians(-20), 4, "Y")
    C.torno(bm, perfil, segmentos=12, matriz=lugar)
    tapa = C.malla(f"{NOMBRE}_Tapa", bm, "Metal")

    return [frasco, slime, tapa]


C.fabricar(NOMBRE, "Objetos", construir, maximo_tris=1500)
