"""Civiles de la calle viva: kit de ropa para mezclar por código + 3 civiles especiales.

Los civiles aparecen de a muchos, así que todo va liviano. Cada pieza tiene 2 canales de color:
las mallas `..._C1` usan MAT_civil-color1 y las `..._C2` MAT_civil-color2, los dos gris claro, y el
juego les pone el color con MeshPart.Color (la textura horneada es gris: solo trae costuras, trama
y desgaste). Una malla por parte del R15 que toca la pieza, así la ropa sigue a los huesos.

Topes (GUIA-ESTILO + pedido de Juani): arriba ≤ 2.500, abajo ≤ 1.500, cabeza ≤ 1.500,
accesorio ≤ 800, teléfono ≤ 300; un civil armado (ropa + accesorio, sin contar el cuerpo propio)
≤ 6.000; civiles especiales completos (con carrito o instrumento) ≤ 8.000.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/civiles.py -- boceto
Pasos: "boceto" (grilla de piezas + 6 civiles de ejemplo), "detalle" (bisel, horneado y vereda
con 12 civiles), "exportar" (exports/civiles/<tipo>/<pieza>.fbx).
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

ARCHIVO = "civiles"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")
PREFIJO = "Civ"
CANALES = {"C1": "civil-color1", "C2": "civil-color2"}

TOPES = {"arriba": 2500, "abajo": 1500, "cabeza": 1500, "accesorio": 800, "telefono": 300, "especial": 8000}
# Los rulos tapan toda la cabeza con ~40 mechones: Juani los quiere llenos (1 nov). 1.900 es lo
# máximo que entra para que el civil más pesado (camisa + jogging + rulos + mochila) siga ≤ 6.000.
TOPES_PIEZA = {"Rulos": 1900}
TOPE_CIVIL = 6000


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def P(nombre):
    """(mínimo, máximo, centro, mitades) de una parte del maniquí."""
    return T.caja_parte(nombre)


def forro(parte, extra=(0.03, 0.03, 0.01), redondez=0.35, seg=(16, 8), dz=0.0, alto=1.0, arriba=False):
    """Tela que envuelve una parte del cuerpo. `alto` < 1 la acorta (desde arriba si `arriba`,
    si no desde abajo: manga corta, bermuda)."""

    def armar(bm):
        _, _, c, m = P(parte)
        mz = m.z * alto
        cz = c.z + (m.z - mz if arriba else mz - m.z)
        T.bloque_redondo(bm, Vector((c.x, c.y, cz + dz)), Vector((m.x + extra[0], m.y + extra[1], mz + extra[2])), redondez, *seg)

    return armar


def caja(parte, d, tam, giro=None):
    """Caja relativa al centro de una parte: `d` y `tam` en fracciones de las mitades + metros."""

    def armar(bm):
        _, _, c, m = P(parte)
        T.caja(bm, c + Vector(d(m)), Vector(tam(m)) if callable(tam) else Vector(tam), giro)

    return armar


def mangas(canal="C1", largo=True, extra=(0.03, 0.03, 0.01), corta=0.55):
    capas = []
    for lado in ("Left", "Right"):
        capas.append((f"{lado}UpperArm", canal, forro(f"{lado}UpperArm", extra, alto=1.0 if largo else corta, arriba=True)))
        if largo:
            capas.append((f"{lado}LowerArm", canal, forro(f"{lado}LowerArm", extra)))
    return capas


def piernas(canal="C1", extra=(0.03, 0.03, 0.01), corta=None):
    capas = []
    for lado in ("Left", "Right"):
        capas.append((f"{lado}UpperLeg", canal, forro(f"{lado}UpperLeg", extra)))
        if corta is None:
            capas.append((f"{lado}LowerLeg", canal, forro(f"{lado}LowerLeg", extra)))
        elif corta > 0:
            capas.append((f"{lado}LowerLeg", canal, forro(f"{lado}LowerLeg", extra, alto=corta, arriba=True)))
    return capas


def torso(canal="C1", extra=(0.035, 0.035, 0.015), cadera=True):
    capas = [("UpperTorso", canal, forro("UpperTorso", extra, 0.3))]
    if cadera:
        capas.append(("LowerTorso", canal, forro("LowerTorso", (extra[0] + 0.005, extra[1] + 0.005, 0.0), 0.3, (16, 6), dz=0.02, alto=0.7, arriba=False)))
    return capas


def frente_torso(dy=0.0):
    _, _, c, m = P("UpperTorso")
    return c.y - m.y - 0.04 - dy


def botones(parte, n, x=0.0, dy=0.045, radio=0.012, z0=0.8, z1=-0.8):
    def armar(bm):
        _, _, c, m = P(parte)
        for k in range(n):
            z = c.z + m.z * (z0 + (z1 - z0) * k / max(1, n - 1))
            T.remache(bm, Vector((c.x + x, c.y - m.y - dy, z)), radio)

    return armar


def cuello_volcado(dy=0.04):
    def armar(bm):
        _, mx, c, m = P("UpperTorso")
        for s in (-1, 1):
            T.caja(bm, Vector((c.x + s * 0.08, c.y - m.y - dy, mx.z - 0.06)), Vector((0.12, 0.018, 0.1)), _g(s * 28, "Y") @ _g(-8, "X"))

    return armar


def bolsillo_pecho(s=-1, dy=0.045):
    def armar(bm):
        _, _, c, m = P("UpperTorso")
        b = Vector((c.x + s * m.x * 0.5, c.y - m.y - dy, c.z + m.z * 0.35))
        T.caja(bm, b, Vector((0.12, 0.014, 0.13)))
        T.caja(bm, b + Vector((0, -0.01, 0.06)), Vector((0.13, 0.016, 0.04)))

    return armar


def puños(canal="C2", alto=0.05):
    capas = []
    for lado in ("Left", "Right"):

        def armar(bm, lado=lado):
            _, _, c, m = P(f"{lado}LowerArm")
            T.bloque_redondo(bm, Vector((c.x, c.y, c.z - m.z + alto)), Vector((m.x + 0.045, m.y + 0.045, alto)), 0.6, 14, 4)

        capas.append((f"{lado}LowerArm", canal, armar))
    return capas


# ---------------------------------------------------------------------------
# Piezas: nombre -> (tipo, [(hueso, canal, armar)])
# ---------------------------------------------------------------------------


def arriba():
    _, utx, uc, um = P("UpperTorso")
    _, _, lc, lm = P("LowerTorso")
    f = uc.y - um.y
    piezas = {}

    def solapas(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * 0.1, f - 0.05, uc.z + um.z * 0.35)), Vector((0.1, 0.015, um.z * 1.0)), _g(s * 16, "Y"))

    piezas["CamperaJean"] = torso() + mangas() + [
        ("UpperTorso", "C1", cuello_volcado(0.05)),
        ("UpperTorso", "C2", botones("UpperTorso", 5, 0.0, 0.05, 0.013, 0.7, -0.9)),
        ("UpperTorso", "C1", bolsillo_pecho(-1, 0.05)),
        ("UpperTorso", "C1", bolsillo_pecho(1, 0.05)),
        *puños("C1"),
    ]

    def camisa_corbata(bm):
        T.caja(bm, Vector((uc.x, f - 0.035, uc.z + um.z * 0.45)), Vector((0.14, 0.012, um.z * 0.9)))
        T.cilindro(bm, Vector((uc.x, f - 0.045, utx.z - 0.03)), Vector((uc.x, f - 0.06, uc.z - um.z * 0.4)), 0.03, 4, 0.045)

    piezas["SacoOficina"] = [
        ("UpperTorso", "C1", forro("UpperTorso", (0.04, 0.04, 0.02), 0.25)),
        ("LowerTorso", "C1", forro("LowerTorso", (0.05, 0.05, 0.0), 0.25, (16, 6), dz=-0.06, alto=1.0)),
        ("UpperTorso", "C1", solapas),
        ("UpperTorso", "C2", camisa_corbata),
        ("LowerTorso", "C1", botones("LowerTorso", 2, 0.0, 0.06, 0.012, 0.6, 0.2)),
        *mangas(extra=(0.035, 0.035, 0.01)),
    ]

    def capucha(bm):
        T.bloque_redondo(bm, Vector((uc.x, uc.y + um.y * 0.6, utx.z + 0.03)), Vector((um.x * 0.75, um.y * 0.7, 0.09)), 0.6, 16, 6)

    def canguro(bm):
        T.caja(bm, Vector((uc.x, f - 0.045, uc.z - um.z * 0.45)), Vector((um.x * 1.2, 0.02, um.z * 0.6)))
        for s in (-1, 1):
            T.cilindro(bm, Vector((uc.x + s * 0.05, f - 0.04, utx.z - 0.02)), Vector((uc.x + s * 0.05, f - 0.045, utx.z - 0.2)), 0.008, 5)

    piezas["BuzoCapucha"] = torso(extra=(0.045, 0.045, 0.02)) + mangas(extra=(0.04, 0.04, 0.01)) + [
        ("UpperTorso", "C1", capucha),
        ("UpperTorso", "C2", canguro),
        *puños("C1"),
    ]

    def cuadros_torso(bm):
        for k in range(4):
            z = uc.z + um.z * (-0.75 + k * 0.5)
            T.bloque_redondo(bm, Vector((uc.x, uc.y, z)), Vector((um.x + 0.042, um.y + 0.042, 0.012)), 0.3, 16, 2)
        for k in range(5):
            x = uc.x + um.x * (-0.8 + k * 0.4)
            T.caja(bm, Vector((x, f - 0.037, uc.z)), Vector((0.022, 0.006, um.z * 2.0)))

    def cuadros_brazos(lado):
        def armar(bm):
            _, _, c, m = P(f"{lado}UpperArm")
            for k in range(2):
                T.bloque_redondo(bm, Vector((c.x, c.y, c.z + m.z * (-0.4 + k * 0.8))), Vector((m.x + 0.037, m.y + 0.037, 0.012)), 0.4, 12, 2)

        return armar

    piezas["CamisaCuadros"] = torso() + mangas() + [
        ("UpperTorso", "C1", cuello_volcado(0.04)),
        ("UpperTorso", "C2", cuadros_torso),
        ("LeftUpperArm", "C2", cuadros_brazos("Left")),
        ("RightUpperArm", "C2", cuadros_brazos("Right")),
        ("UpperTorso", "C1", botones("UpperTorso", 5, 0.0, 0.04, 0.009, 0.7, -0.9)),
    ]

    def falda_piloto(lado):
        def armar(bm):
            _, _, c, m = P(f"{lado}UpperLeg")
            T.bloque_redondo(bm, Vector((c.x, c.y, c.z + 0.02)), Vector((m.x + 0.06, m.y + 0.06, m.z + 0.03)), 0.3, 12, 6)

        return armar

    def cinto(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.5)), Vector((lm.x + 0.07, lm.y + 0.07, 0.03)), 0.5, 16, 2)
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.08, lc.z + lm.z * 0.5)), Vector((0.07, 0.015, 0.05)))

    piezas["PilotoLargo"] = [
        ("UpperTorso", "C1", forro("UpperTorso", (0.045, 0.045, 0.02), 0.25)),
        ("LowerTorso", "C1", forro("LowerTorso", (0.06, 0.06, 0.02), 0.25, (16, 6))),
        ("UpperTorso", "C1", solapas),
        ("UpperTorso", "C1", cuello_volcado(0.06)),
        ("LeftUpperLeg", "C1", falda_piloto("Left")),
        ("RightUpperLeg", "C1", falda_piloto("Right")),
        ("LowerTorso", "C2", cinto),
        ("UpperTorso", "C2", botones("UpperTorso", 3, -0.09, 0.06, 0.012, 0.5, -0.6)),
        *mangas(extra=(0.04, 0.04, 0.01)),
    ]

    def chaleco(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * um.x * 0.55, f - 0.05, uc.z - 0.02)), Vector((um.x * 0.8, 0.02, um.z * 2.0)))
            T.caja(bm, Vector((uc.x + s * um.x * 0.55, uc.y + um.y + 0.05, uc.z - 0.02)), Vector((um.x * 0.8, 0.02, um.z * 2.0)))
        for z in (-0.4, 0.2):  # bandas reflectivas
            T.bloque_redondo(bm, Vector((uc.x, uc.y, uc.z + um.z * z)), Vector((um.x + 0.06, um.y + 0.065, 0.025)), 0.3, 16, 2)

    piezas["ChalecoObra"] = torso() + mangas(largo=False) + [("UpperTorso", "C2", chaleco)]

    def estampa(bm):
        # Estampa propia: un eclipse (aro grueso con un disco corrido) y una barra abajo.
        c = Vector((uc.x, f - 0.04, uc.z + um.z * 0.25))
        pasos = 20
        T.tubo(bm, [c + Vector((math.cos(a) * 0.09, 0, math.sin(a) * 0.09)) for a in [2 * math.pi * i / pasos for i in range(pasos + 1)]], 0.02, 4, False)
        T.cilindro(bm, c + Vector((0.025, 0.004, 0.02)), c + Vector((0.025, -0.006, 0.02)), 0.06, 14)
        T.caja(bm, c + Vector((0, 0, -0.17)), Vector((0.22, 0.008, 0.035)))

    piezas["RemeraEstampa"] = torso() + mangas(largo=False) + [("UpperTorso", "C2", estampa)]

    def cuello_v(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * 0.04, f - 0.04, utx.z - 0.08)), Vector((0.03, 0.012, 0.16)), _g(-s * 28, "Y"))

    def bolsillo_enf(bm):
        b = Vector((uc.x + um.x * 0.5, f - 0.045, uc.z + um.z * 0.2))
        T.caja(bm, b, Vector((0.13, 0.014, 0.12)))
        for k in range(2):  # lapiceras
            T.cilindro(bm, b + Vector((-0.03 + k * 0.03, 0, 0.03)), b + Vector((-0.03 + k * 0.03, 0, 0.1)), 0.008, 6)
        T.caja(bm, Vector((uc.x - um.x * 0.5, f - 0.045, uc.z + um.z * 0.35)), Vector((0.09, 0.008, 0.04)))  # credencial

    piezas["UniformeEnfermeria"] = torso() + mangas(largo=False) + [("UpperTorso", "C2", cuello_v), ("UpperTorso", "C2", bolsillo_enf)]
    return {k: ("arriba", v) for k, v in piezas.items()}


def abajo():
    _, ltx, lc, lm = P("LowerTorso")
    piezas = {}

    def cinturon(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, ltx.z - 0.04)), Vector((lm.x + 0.05, lm.y + 0.05, 0.028)), 0.5, 16, 2)
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.06, ltx.z - 0.04)), Vector((0.06, 0.015, 0.045)))

    cadera = ("LowerTorso", "C1", forro("LowerTorso", (0.04, 0.04, 0.01), 0.3, (16, 6)))

    def costura(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg",):
                _, _, c, m = P(parte)
                x = c.x + (1 if c.x > lc.x else -1) * (m.x + 0.034)
                T.caja(bm, Vector((x, c.y, c.z)), Vector((0.012, 0.012, m.z * 2)))

        return armar

    piezas["Jean"] = [cadera, ("LowerTorso", "C2", cinturon), *piernas(), ("LeftUpperLeg", "C1", costura("Left")), ("RightUpperLeg", "C1", costura("Right"))]

    def raya(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg", f"{lado}LowerLeg"):
                _, _, c, m = P(parte)
                T.caja(bm, Vector((c.x, c.y - m.y - 0.032, c.z)), Vector((0.01, 0.01, m.z * 2)))

        return armar

    piezas["PantalonVestir"] = [cadera, ("LowerTorso", "C2", cinturon), *piernas(extra=(0.035, 0.035, 0.01)), ("LeftUpperLeg", "C1", raya("Left")), ("RightUpperLeg", "C1", raya("Right"))]

    def pollera(bm):
        _, _, pc, pm = P("LeftUpperLeg")
        arriba_z, abajo_z = ltx.z, pc.z - pm.z * 0.6
        T.cilindro(bm, Vector((lc.x, lc.y, arriba_z)), Vector((lc.x, lc.y, abajo_z)), lm.x + 0.05, 16, lm.x + 0.13)

    medias = [(f"{lado}LowerLeg", "C2", forro(f"{lado}LowerLeg", (0.012, 0.012, 0.0), 0.35, (12, 6))) for lado in ("Left", "Right")]
    piezas["Pollera"] = [("LowerTorso", "C1", pollera), ("LowerTorso", "C1", forro("LowerTorso", (0.04, 0.04, 0.0), 0.3, (12, 4))), *medias]

    def franja(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg", f"{lado}LowerLeg"):
                _, _, c, m = P(parte)
                x = c.x + (1 if c.x > lc.x else -1) * (m.x + 0.044)
                T.caja(bm, Vector((x, c.y, c.z)), Vector((0.012, 0.05, m.z * 2)))

        return armar

    def cordon(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, ltx.z - 0.04)), Vector((lm.x + 0.055, lm.y + 0.055, 0.04)), 0.5, 16, 2)
        for s in (-1, 1):
            T.cilindro(bm, Vector((lc.x + s * 0.025, lc.y - lm.y - 0.07, ltx.z - 0.05)), Vector((lc.x + s * 0.03, lc.y - lm.y - 0.07, ltx.z - 0.18)), 0.007, 5)

    puños_j = []
    for lado in ("Left", "Right"):

        def puño_pierna(bm, lado=lado):
            _, _, c, m = P(f"{lado}LowerLeg")
            T.bloque_redondo(bm, Vector((c.x, c.y, c.z - m.z + 0.04)), Vector((m.x + 0.05, m.y + 0.05, 0.04)), 0.6, 12, 2)

        puños_j.append((f"{lado}LowerLeg", "C1", puño_pierna))
    piezas["Jogging"] = [cadera, ("LowerTorso", "C2", cordon), *piernas(extra=(0.04, 0.04, 0.01)), *puños_j, ("LeftUpperLeg", "C2", franja("Left")), ("RightUpperLeg", "C2", franja("Right"))]
    piezas["Bermuda"] = [cadera, ("LowerTorso", "C2", cinturon), *piernas(extra=(0.045, 0.045, 0.01), corta=0.3)]

    _, utx, uc, um = P("UpperTorso")

    def pechera(bm):
        T.caja(bm, Vector((uc.x, uc.y - um.y - 0.045, uc.z - um.z * 0.3)), Vector((um.x * 1.2, 0.02, um.z * 1.3)))
        T.caja(bm, Vector((uc.x, uc.y - um.y - 0.06, uc.z - um.z * 0.1)), Vector((um.x * 0.6, 0.012, um.z * 0.5)))

    def tirantes(bm):
        for s in (-1, 1):
            x = uc.x + s * um.x * 0.45
            T.tubo(bm, [Vector((x, uc.y - um.y - 0.06, uc.z + um.z * 0.3)), Vector((x, uc.y - um.y * 0.5, utx.z + 0.03)), Vector((x, uc.y + um.y * 0.6, utx.z + 0.03)), Vector((uc.x + s * 0.03, uc.y + um.y + 0.05, uc.z - um.z * 0.3))], 0.02, 4)
            T.remache(bm, Vector((x, uc.y - um.y - 0.065, uc.z + um.z * 0.25)), 0.015)

    piezas["Mameluco"] = [cadera, ("UpperTorso", "C1", pechera), ("UpperTorso", "C2", tirantes), *piernas(extra=(0.045, 0.045, 0.01))]
    return {k: ("abajo", v) for k, v in piezas.items()}


def cabezas():
    _, hx, hc, hm = P("Head")
    f = hc.y - hm.y
    r, ry = hm.x + 0.03, hm.y + 0.03
    piezas = {}

    def copa(z0, alto, redondez=0.6, seg=(18, 8), dy=0.0):
        def armar(bm):
            T.bloque_redondo(bm, Vector((hc.x, hc.y + dy, z0)), Vector((r, ry, alto)), redondez, *seg)

        return armar

    def visera(bm):
        T.caja(bm, Vector((hc.x, f - 0.11, hx.z - hm.z * 0.45)), Vector((hm.x * 1.4, 0.2, 0.02)), _g(6, "X"))

    zg = hx.z - hm.z * 0.25
    piezas["Gorra"] = [("Head", "C1", copa(zg, hm.z * 0.45, 0.7)), ("Head", "C2", visera)]

    def borde_lana(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, hx.z - hm.z * 0.55)), Vector((r + 0.02, ry + 0.02, 0.07)), 0.6, 18, 4)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, hx.z + hm.z * 0.25)), Vector((0.06, 0.06, 0.06)), 0.9, 10, 6)  # pompón

    piezas["GorroLana"] = [("Head", "C1", copa(hx.z - hm.z * 0.15, hm.z * 0.6, 0.85)), ("Head", "C2", borde_lana)]

    def pelo_base(alto=0.45, dy=0.015, extra=0.0):
        def armar(bm):
            T.bloque_redondo(bm, Vector((hc.x, hc.y + dy, hx.z - hm.z * alto + 0.02)), Vector((r + extra, ry + extra, hm.z * alto + 0.02)), 0.6, 18, 8)

        return armar

    def flequillo(bm):
        for k in range(3):
            T.bloque_redondo(bm, Vector((hc.x - 0.08 + k * 0.08, f - 0.015, hx.z - 0.01)), Vector((0.055, 0.035, 0.045)), 0.6, 8, 4)

    piezas["PeloCorto"] = [("Head", "C1", pelo_base()), ("Head", "C2", flequillo)]

    def cola(bm):
        T.tubo(bm, [Vector((hc.x, hc.y + hm.y + 0.06, hc.z + hm.z * 0.3)), Vector((hc.x, hc.y + hm.y + 0.12, hc.z - hm.z * 0.2)), Vector((hc.x, hc.y + hm.y + 0.1, hc.z - hm.z * 0.9))], [0.06, 0.055, 0.02], 8)

    def gomita(bm):
        T.cilindro(bm, Vector((hc.x, hc.y + hm.y + 0.05, hc.z + hm.z * 0.38)), Vector((hc.x, hc.y + hm.y + 0.08, hc.z + hm.z * 0.3)), 0.05, 10)

    piezas["PeloLargoAtado"] = [("Head", "C1", pelo_base(0.55)), ("Head", "C1", cola), ("Head", "C2", gomita)]

    def rulos(bm):
        """Mechones enrulados en espiral (como resortes gruesos) que salen del cuero y caen hacia
        afuera y abajo: sobre la frente, los costados y la nuca. Abajo hay una base pegada a la
        cabeza, tapada por los mechones, para que entre rulo y rulo no se vea la piel."""
        # Base pegada a la cabeza (sobresale 1 cm): tapa arriba, los costados hasta la oreja y la
        # nuca. Es del color del pelo y queda debajo de los rulos, así entre rulo y rulo no se ve piel.
        z0 = hc.z - hm.z * 0.1
        T.caja(bm, Vector((hc.x, hc.y + 0.01, (z0 + hx.z + 0.02) / 2)), Vector(((hm.x + 0.01) * 2, (hm.y + 0.005) * 2, hx.z + 0.02 - z0)))
        z1 = hc.z - hm.z * 0.75
        T.caja(bm, Vector((hc.x, hc.y + hm.y * 0.5 + 0.005, (z1 + z0) / 2 + 0.01)), Vector(((hm.x + 0.01) * 2, hm.y + 0.01, z0 - z1 + 0.02)))  # nuca
        rng = random.Random(4)

        def afuera_de_la_cabeza(camino, grosor):
            """Ningún rulo atraviesa la cabeza: el punto que queda adentro de la caja de la cabeza
            (más el grosor del rulo) se empuja hacia la cara más cercana (costado, frente, nuca o
            arriba)."""
            out = []
            for p, g in zip(camino, grosor):
                m = g + 0.006
                dx, dy, dz = hm.x + m - abs(p.x - hc.x), hm.y + m - abs(p.y - hc.y), hx.z + m - p.z
                if dx > 0 and dy > 0 and dz > 0:
                    p = p.copy()
                    menor = min(dx, dy, dz)
                    if menor == dx:
                        p.x += math.copysign(dx, p.x - hc.x)
                    elif menor == dy:
                        p.y += math.copysign(dy, p.y - hc.y)
                    else:
                        p.z += dz
                out.append(p)
            return out

        # (elevación, cantidad): de la coronilla para abajo; adelante los rulos son cortos (flequillo).
        for e, n in ((1.45, 4), (1.1, 8), (0.75, 9), (0.4, 9), (0.05, 7)):
            for k in range(n):
                a = 2 * math.pi * (k + 0.5 * (n % 2)) / n + rng.uniform(-0.15, 0.15)
                frente = -math.sin(a)  # 1 = mira a la cara
                cuadro = max(abs(math.cos(a)), abs(math.sin(a)))  # la cabeza es cuadrada: raíz en su borde
                raiz = Vector((hc.x + math.cos(a) / cuadro * r * math.cos(e) * 0.95, hc.y + math.sin(a) / cuadro * ry * math.cos(e) * 0.95, hx.z - hm.z * 0.3 + math.sin(e) * hm.z * 0.5))
                afuera = Vector((math.cos(a), math.sin(a), 0))
                largo = rng.uniform(0.13, 0.2) * (0.55 if frente > 0.45 else 1.0)  # flequillo corto: no tapa los ojos
                caida = Vector((0, 0, -1)) * largo + afuera * largo * (0.35 + 0.4 * math.sin(e))
                lado = afuera.cross(Vector((0, 0, 1))).normalized()
                vueltas, radio, fase = rng.uniform(1.2, 1.7), 0.022, rng.uniform(0, 6.28)
                pasos = 5
                camino = []
                for i in range(pasos):
                    t = i / (pasos - 1)
                    giro = fase + t * vueltas * 2 * math.pi
                    camino.append(raiz + caida * t + (lado * math.cos(giro) + afuera * math.sin(giro)) * radio * (0.4 + t))
                grosor = [0.046 - 0.018 * (i / (pasos - 1)) for i in range(pasos)]
                T.tubo(bm, afuera_de_la_cabeza(camino, grosor), grosor, 5)
        for k in range(4):  # flequillo: 4 rulos cortos que tapan el borde de la base sobre la frente
            x = hc.x - r * 0.75 + k * r * 0.5
            raiz = Vector((x, hc.y - ry + 0.01, hx.z - hm.z * 0.3))
            fase = rng.uniform(0, 6.28)
            camino = [raiz + Vector((0, -0.02 - 0.03 * t, -0.07 * t)) + Vector((math.cos(fase + t * 9), 0, math.sin(fase + t * 9) * 0.5)) * 0.018 for t in [i / 4 for i in range(5)]]
            grosor = [0.04, 0.038, 0.034, 0.03, 0.024]
            T.tubo(bm, afuera_de_la_cabeza(camino, grosor), grosor, 5)

    def hebilla(bm):
        """Hebilla a un costado, por fuera de los rulos (el segundo color: siempre uno que
        contraste con el pelo, ver PALETA_ACCESORIO_PELO)."""
        c = Vector((hc.x + r + 0.075, hc.y - 0.03, hx.z - hm.z * 0.15))
        T.bloque_redondo(bm, c, Vector((0.014, 0.06, 0.022)), 0.5, 10, 4)

    piezas["Rulos"] = [("Head", "C1", rulos), ("Head", "C2", hebilla)]

    def barba(bm):
        T.bloque_redondo(bm, Vector((hc.x, f + 0.03, hc.z - hm.z * 0.6)), Vector((hm.x + 0.015, 0.08, hm.z * 0.4)), 0.6, 14, 6)
        T.bloque_redondo(bm, Vector((hc.x, f - 0.025, hc.z - hm.z * 0.2)), Vector((0.1, 0.025, 0.03)), 0.6, 10, 4)  # bigote
        for s in (-1, 1):  # cejas
            T.caja(bm, Vector((hc.x + s * 0.08, f - 0.008, hc.z + hm.z * 0.35)), Vector((0.08, 0.015, 0.02)))

    def anteojos(bm):
        for s in (-1, 1):
            c = Vector((hc.x + s * 0.08, f - 0.025, hc.z + hm.z * 0.15))
            T.tubo(bm, [c + Vector((math.cos(a) * 0.055, 0, math.sin(a) * 0.045)) for a in [2 * math.pi * i / 12 for i in range(13)]], 0.008, 4, False)
            T.caja(bm, Vector((hc.x + s * (hm.x + 0.01), hc.y - 0.02, hc.z + hm.z * 0.15)), Vector((0.012, hm.y * 1.9, 0.012)))
        T.caja(bm, Vector((hc.x, f - 0.025, hc.z + hm.z * 0.18)), Vector((0.05, 0.01, 0.01)))

    piezas["PeladoBarba"] = [("Head", "C1", barba), ("Head", "C2", anteojos)]

    def sombrero(bm):
        T.cilindro(bm, Vector((hc.x, hc.y, hx.z - hm.z * 0.35)), Vector((hc.x, hc.y, hx.z - hm.z * 0.32)), r * 1.75, 20)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, hx.z - hm.z * 0.05)), Vector((r * 0.95, ry * 0.95, hm.z * 0.35)), 0.55, 18, 6)

    def cinta(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, hx.z - hm.z * 0.25)), Vector((r * 0.97, ry * 0.97, 0.03)), 0.55, 18, 2)

    piezas["Sombrero"] = [("Head", "C1", sombrero), ("Head", "C2", cinta)]

    def vincha_aur(bm):
        T.tubo(bm, [Vector((hc.x + math.cos(a) * (r + 0.03), hc.y, hc.z + math.sin(a) * (hm.z + 0.05))) for a in [math.radians(x) for x in range(0, 181, 15)]], 0.02, 6)

    def copas(bm):
        for s in (-1, 1):
            T.cilindro(bm, Vector((hc.x + s * (hm.x + 0.005), hc.y, hc.z)), Vector((hc.x + s * (hm.x + 0.06), hc.y, hc.z)), 0.08, 14)

    piezas["Auriculares"] = [("Head", "C1", vincha_aur), ("Head", "C2", copas)]
    return {k: ("cabeza", v) for k, v in piezas.items()}


def mano(lado="Right"):
    """Punto de agarre (centro abajo de la mano) y la parte."""
    _, _, c, m = P(f"{lado}Hand")
    return f"{lado}Hand", Vector((c.x, c.y, c.z - m.z * 0.3)), m


def accesorios():
    piezas = {}
    hueso, g, _ = mano("Right")

    def maletin(bm):
        T.bloque_redondo(bm, g + Vector((0, 0, -0.2)), Vector((0.06, 0.2, 0.15)), 0.2, 12, 6)

    def manija(bm):
        T.tubo(bm, [g + Vector((0, -0.06, -0.05)), g + Vector((0, -0.05, 0.0)), g + Vector((0, 0.05, 0.0)), g + Vector((0, 0.06, -0.05))], 0.012, 5)
        for s in (-1, 1):
            T.caja(bm, g + Vector((-0.062, s * 0.12, -0.08)), Vector((0.01, 0.04, 0.03)))

    piezas["Maletin"] = [(hueso, "C1", maletin), (hueso, "C2", manija)]

    hi, gi, _ = mano("Left")

    def bolsa(bm):
        T.cilindro(bm, gi + Vector((0, 0, -0.42)), gi + Vector((0, 0, -0.12)), 0.13, 8, 0.15)

    def manijas_bolsa(bm):
        for s in (-1, 1):
            T.tubo(bm, [gi + Vector((0, s * 0.1, -0.13)), gi + Vector((0, s * 0.04, 0.0)), gi + Vector((0, -s * 0.02, 0.0))], 0.008, 4)
        T.cilindro(bm, gi + Vector((0.03, 0.03, -0.2)), gi + Vector((0.06, 0.08, 0.05)), 0.03, 6)  # pan
        T.bloque_redondo(bm, gi + Vector((-0.04, -0.04, -0.1)), Vector((0.05, 0.05, 0.05)), 0.9, 8, 4)  # manzana

    piezas["BolsaCompras"] = [(hi, "C1", bolsa), (hi, "C2", manijas_bolsa)]

    _, utx, uc, um = P("UpperTorso")
    at = uc.y + um.y

    def mochila(bm):
        T.bloque_redondo(bm, Vector((uc.x, at + 0.13, uc.z - 0.02)), Vector((um.x * 0.75, 0.1, um.z * 0.9)), 0.4, 14, 8)
        T.bloque_redondo(bm, Vector((uc.x, at + 0.24, uc.z - um.z * 0.4)), Vector((um.x * 0.55, 0.04, um.z * 0.35)), 0.4, 10, 4)

    def tiras(bm):
        for s in (-1, 1):
            x = uc.x + s * um.x * 0.45
            T.tubo(bm, [Vector((x, at + 0.05, utx.z - 0.02)), Vector((x, uc.y - um.y * 0.4, utx.z + 0.02)), Vector((x, uc.y - um.y - 0.05, uc.z)), Vector((x, uc.y + um.y * 0.2, uc.z - um.z * 0.9))], 0.02, 4)

    piezas["Mochila"] = [("UpperTorso", "C1", mochila), ("UpperTorso", "C2", tiras)]

    def caño(bm, largo):
        T.cilindro(bm, g + Vector((0, 0, -0.05)), g + Vector((0, 0, largo)), 0.012, 6)
        T.tubo(bm, [g + Vector((0, 0, -0.05)), g + Vector((0, 0, -0.12)), g + Vector((0, -0.05, -0.15)), g + Vector((0, -0.08, -0.12))], 0.015, 5, False)

    def tela_abierta(bm):
        tope = g + Vector((0, 0, 1.3))
        n = 8
        borde = [tope + Vector((math.cos(2 * math.pi * k / n) * 0.55, math.sin(2 * math.pi * k / n) * 0.55, -0.22)) for k in range(n)]
        centro = bm.verts.new(tope)
        aro = [bm.verts.new(p) for p in borde]
        aro_dentro = [bm.verts.new(p + Vector((0, 0, -0.01))) for p in borde]
        centro_dentro = bm.verts.new(tope + Vector((0, 0, -0.01)))
        for k in range(n):
            q = (k + 1) % n
            bm.faces.new((centro, aro[k], aro[q]))
            bm.faces.new((centro_dentro, aro_dentro[q], aro_dentro[k]))
            bm.faces.new((aro[k], aro_dentro[k], aro_dentro[q], aro[q]))

    piezas["ParaguasAbierto"] = [(hueso, "C1", tela_abierta), (hueso, "C2", lambda bm: caño(bm, 1.33))]

    def tela_cerrada(bm):
        T.cilindro(bm, g + Vector((0, 0, -0.75)), g + Vector((0, 0, -0.15)), 0.004, 8, 0.045)

    def caño_cerrado(bm):
        T.cilindro(bm, g + Vector((0, 0, -0.85)), g + Vector((0, 0, 0.05)), 0.01, 6)
        T.tubo(bm, [g + Vector((0, 0, 0.05)), g + Vector((0, 0, 0.12)), g + Vector((0, -0.05, 0.15)), g + Vector((0, -0.08, 0.12))], 0.015, 5, False)

    piezas["ParaguasCerrado"] = [(hueso, "C1", tela_cerrada), (hueso, "C2", caño_cerrado)]

    _, _, mc, mm = P("RightHand")
    va = Vector((mc.x, mc.y - mm.y - 0.05, mc.z))

    def vaso(bm):
        T.cilindro(bm, va + Vector((0, 0, -0.1)), va + Vector((0, 0, 0.08)), 0.04, 12, 0.05)

    def tapa(bm):
        T.cilindro(bm, va + Vector((0, 0, 0.08)), va + Vector((0, 0, 0.11)), 0.054, 12, 0.045)
        T.cilindro(bm, va + Vector((0, 0, -0.03)), va + Vector((0, 0, 0.03)), 0.048, 12, 0.05)  # faja

    piezas["Cafe"] = [(hueso, "C1", vaso), (hueso, "C2", tapa)]

    def correa(bm):
        piso = Vector((gi.x + 0.1, gi.y - 0.9, 0.25))
        pts = [gi + (piso - gi) * t + Vector((0, 0, -math.sin(t * math.pi) * 0.15)) for t in [k / 8 for k in range(9)]]
        T.tubo(bm, pts, 0.008, 4)
        T.cilindro(bm, piso + Vector((0, 0, -0.02)), piso + Vector((0, 0, 0.02)), 0.025, 8)  # mosquetón del collar

    def manija_correa(bm):
        T.bloque_redondo(bm, gi + Vector((0, 0, 0.02)), Vector((0.04, 0.06, 0.06)), 0.6, 10, 4)

    piezas["CorreaPerro"] = [(hi, "C1", correa), (hi, "C2", manija_correa)]
    out = {k: ("accesorio", v) for k, v in piezas.items()}

    # El teléfono y el café se sostienen adelante de la mano (la mano del R15 es un bloque grueso).
    _, _, mc, mm = P("RightHand")
    adelante = Vector((mc.x, mc.y - mm.y - 0.03, mc.z))

    def carcasa(bm):
        T.bloque_redondo(bm, adelante + Vector((0, 0, 0.03)), Vector((0.04, 0.008, 0.08)), 0.3, 8, 4)

    def camara(bm):
        T.cilindro(bm, adelante + Vector((0.02, 0.008, 0.09)), adelante + Vector((0.02, 0.012, 0.09)), 0.008, 6)

    def pantalla(bm):
        T.caja(bm, adelante + Vector((0, -0.009, 0.03)), Vector((0.066, 0.002, 0.14)))

    out["Telefono"] = ("telefono", [(hueso, "C1", carcasa), (hueso, "C2", camara), (hueso, "Pantalla", pantalla)])
    return out


# ---------------------------------------------------------------------------
# Construcción
# ---------------------------------------------------------------------------


def construir(nombre, capas):
    """Junta las capas por (hueso, canal): una malla cada una, pegada a su hueso."""
    grupos = {}
    for hueso, canal, armar in capas:
        grupos.setdefault((hueso, canal), []).append(armar)
    objs = []
    for (hueso, canal), lista in grupos.items():
        mat = CANALES.get(canal, "neon-cian")
        nombre_obj = f"{PREFIJO}_{nombre}_{hueso}_{canal}"
        objs.append(T.pieza(nombre_obj, hueso, [(mat, a) for a in lista]))
    return objs


def catalogo():
    return {**arriba(), **abajo(), **cabezas(), **accesorios()}


def construir_todo():
    piezas = {}
    for nombre, (tipo, capas) in catalogo().items():
        piezas[nombre] = (tipo, construir(nombre, capas))
    piezas.update(especiales())
    return piezas


# ---------------------------------------------------------------------------
# Civiles especiales: carrito de diarios, carrito de panchos, guitarra y estuche
# ---------------------------------------------------------------------------


def _objeto(nombre, capas, en=None):
    """Prop suelto (no sigue a un hueso): capas = [(canal, armar)], una malla por canal."""
    grupos = {}
    for canal, armar in capas:
        grupos.setdefault(canal, []).append(armar)
    objs = []
    for canal, lista in grupos.items():
        mat = CANALES.get(canal, canal)
        bm_nombre = f"{PREFIJO}_{nombre}_{canal}"
        o = T.pieza(bm_nombre, "LowerTorso", [(mat, a) for a in lista])
        o.parent = None
        o.matrix_world = Matrix.Identity(4)
        objs.append(o)
    return objs


def _rueda(bm, c, r=0.12, ancho=0.04):
    T.cilindro(bm, c - Vector((ancho / 2, 0, 0)), c + Vector((ancho / 2, 0, 0)), r, 14)


def carrito_diarios():
    """Carrito de diarios de El Faro, a la derecha del diarero: caja con 3 pilas de diarios, dos
    ruedas, manija y un cartel con el faro (silueta propia) arriba."""
    o = Vector((-0.75, -0.1, 0))

    def cuerpo(bm):
        T.bloque_redondo(bm, o + Vector((0, 0, 0.55)), Vector((0.25, 0.375, 0.225)), 0.15, 16, 8)
        T.tubo(bm, [o + Vector((-0.2, 0.38, 0.75)), o + Vector((-0.2, 0.55, 1.0)), o + Vector((0.2, 0.55, 1.0)), o + Vector((0.2, 0.38, 0.75))], 0.018, 6)
        T.cilindro(bm, o + Vector((0, -0.15, 0.78)), o + Vector((0, -0.15, 1.45)), 0.02, 6)
        T.caja(bm, o + Vector((0, -0.15, 1.6)), Vector((0.6, 0.03, 0.32)))
        for x in (-0.27, 0.27):
            T.caja(bm, o + Vector((x, -0.3, 0.2)), Vector((0.03, 0.03, 0.3)))

    def ruedas(bm):
        for x in (-0.28, 0.28):
            _rueda(bm, o + Vector((x, 0.25, 0.12)))

    def diarios(bm):
        for k, y in enumerate((-0.22, 0.0, 0.22)):
            for capa in range(3 + k):
                T.caja(bm, o + Vector((random.uniform(-0.01, 0.01), y, 0.79 + capa * 0.045)), Vector((0.36, 0.2, 0.04)), _g(random.uniform(-6, 6), "Z"))

    def faro(bm):
        c = o + Vector((0, -0.17, 1.6))
        T.cilindro(bm, c + Vector((-0.12, 0, -0.12)), c + Vector((-0.12, 0, 0.06)), 0.035, 8, 0.025)
        T.caja(bm, c + Vector((-0.12, 0, 0.09)), Vector((0.06, 0.012, 0.05)))
        for s in (-1, 1):
            T.caja(bm, c + Vector((-0.12 + s * 0.09, 0, 0.09)), Vector((0.14, 0.008, 0.02)), _g(s * 12, "Y"))
        for k in range(3):  # renglones del cartel
            T.caja(bm, c + Vector((0.12, 0, 0.08 - k * 0.07)), Vector((0.26, 0.008, 0.025)))

    random.seed(7)
    return _objeto("CarritoDiarios", [("C1", cuerpo), ("C2", ruedas), ("diario", diarios), ("C2", faro)])


def carrito_panchos():
    """Carrito de panchos: caja térmica con tapa, plancha, 3 panchos arriba, sombrilla a rayas
    (2 canales), ruedas y manija."""
    o = Vector((-0.85, -0.05, 0))

    def caja_(bm):
        T.bloque_redondo(bm, o + Vector((0, 0, 0.6)), Vector((0.32, 0.55, 0.3)), 0.25, 16, 8)
        T.caja(bm, o + Vector((0, 0, 0.93)), Vector((0.62, 1.05, 0.04)))
        T.tubo(bm, [o + Vector((-0.2, 0.55, 0.75)), o + Vector((-0.2, 0.75, 0.95)), o + Vector((0.2, 0.75, 0.95)), o + Vector((0.2, 0.55, 0.75))], 0.02, 6)
        T.cilindro(bm, o + Vector((0, 0, 0.95)), o + Vector((0, 0, 1.85)), 0.018, 6)
        for x in (-0.25, 0.25):
            T.caja(bm, o + Vector((x, -0.4, 0.17)), Vector((0.03, 0.03, 0.34)))

    def sombrilla(bm, par):
        tope = o + Vector((0, 0, 2.0))
        n = 8
        for k in range(n):
            if k % 2 != par:
                continue
            a0, a1 = 2 * math.pi * k / n, 2 * math.pi * (k + 1) / n
            v = [bm.verts.new(tope), bm.verts.new(tope + Vector((math.cos(a0) * 0.8, math.sin(a0) * 0.8, -0.3))), bm.verts.new(tope + Vector((math.cos(a1) * 0.8, math.sin(a1) * 0.8, -0.3)))]
            bm.faces.new(v)
            w = [bm.verts.new(p.co + Vector((0, 0, -0.012))) for p in v]
            bm.faces.new(list(reversed(w)))
            for i in range(3):
                j = (i + 1) % 3
                bm.faces.new((v[i], w[i], w[j], v[j]))

    def ruedas(bm):
        for x in (-0.36, 0.36):
            _rueda(bm, o + Vector((x, 0.35, 0.15)), 0.15)

    def panchos(bm):
        for k in range(3):
            p = o + Vector((-0.12 + k * 0.12, -0.2, 0.98))
            T.bloque_redondo(bm, p, Vector((0.04, 0.12, 0.03)), 0.7, 10, 4)

    def salchichas(bm):
        for k in range(3):
            p = o + Vector((-0.12 + k * 0.12, -0.2, 1.01))
            T.cilindro(bm, p - Vector((0, 0.14, 0)), p + Vector((0, 0.14, 0)), 0.018, 6)

    return _objeto(
        "CarritoPanchos",
        [("C1", caja_), ("C1", lambda bm: sombrilla(bm, 0)), ("C2", lambda bm: sombrilla(bm, 1)), ("C2", ruedas), ("pan", panchos), ("salchicha", salchichas)],
    )


def guitarra():
    """Guitarra criolla colgada adelante (sigue al torso): caja de dos lóbulos, boca, puente,
    mástil con clavijero y correa."""
    _, utx, uc, um = P("UpperTorso")
    c = Vector((uc.x + 0.05, uc.y - um.y - 0.12, uc.z - um.z * 0.6))
    giro = _g(-50, "Y")

    def caja_(bm):
        for dz, r in ((-0.1, 0.19), (0.12, 0.15)):
            bmesh_cilindro(bm, c + giro @ Vector((0, 0, dz)), r)

    def detalles(bm):
        T.cilindro(bm, c + giro @ Vector((0, -0.06, 0.08)), c + giro @ Vector((0, -0.065, 0.08)), 0.05, 12)  # boca
        T.caja(bm, c + giro @ Vector((0, -0.06, -0.17)), Vector((0.15, 0.02, 0.03)), giro)  # puente
        a, b = c + giro @ Vector((0, -0.02, 0.25)), c + giro @ Vector((0, -0.02, 0.72))
        T.caja(bm, (a + b) / 2, Vector((0.05, 0.03, 0.5)), giro)  # mástil
        T.caja(bm, c + giro @ Vector((0, -0.02, 0.8)), Vector((0.07, 0.025, 0.16)), giro)  # clavijero
        T.tubo(bm, [c + giro @ Vector((0, 0.04, -0.28)), Vector((uc.x - um.x * 0.9, uc.y, uc.z - um.z)), Vector((uc.x - um.x * 0.6, uc.y + um.y + 0.04, uc.z)), Vector((uc.x + um.x * 0.5, uc.y, utx.z + 0.03)), a + Vector((0, 0.04, 0))], 0.015, 4)

    return [
        *construir("Guitarra", [("UpperTorso", "C1", caja_), ("UpperTorso", "C2", detalles)]),
    ]


def bmesh_cilindro(bm, centro, r, grosor=0.09):
    """Disco grueso con la cara mirando a -Y (caja de la guitarra)."""
    return T.cilindro(bm, centro + Vector((0, grosor / 2, 0)), centro - Vector((0, grosor / 2, 0)), r, 16)


def estuche():
    """Estuche de guitarra abierto en el piso, a los pies del músico, con monedas adentro."""
    o = Vector((-0.2, -0.75, 0))

    def cuerpo(bm):
        T.bloque_redondo(bm, o + Vector((0, 0, 0.05)), Vector((0.5, 0.2, 0.05)), 0.4, 16, 4)
        T.bloque_redondo(bm, o + Vector((0, 0.27, 0.22)), Vector((0.5, 0.03, 0.18)), 0.4, 16, 4)  # tapa abierta

    def forro_(bm):
        T.bloque_redondo(bm, o + Vector((0, 0, 0.09)), Vector((0.45, 0.16, 0.012)), 0.4, 12, 2)

    def monedas(bm):
        random.seed(5)
        for _ in range(7):
            p = o + Vector((random.uniform(-0.3, 0.3), random.uniform(-0.1, 0.1), 0.105))
            T.cilindro(bm, p, p + Vector((0, 0, 0.006)), 0.018, 8)

    return _objeto("EstucheGuitarra", [("C1", cuerpo), ("C2", forro_), ("acero", monedas)])


def especiales():
    """Los 3 civiles especiales: (tipo, objetos propios). La ropa sale del kit (ESPECIALES)."""
    return {
        "Diarero": ("especial", carrito_diarios()),
        "Vendedor": ("especial", carrito_panchos()),
        "Musico": ("especial", guitarra() + estuche()),
    }


# Civiles especiales completos: piezas del kit + sus props, con colores fijos.
ESPECIALES = {
    "Diarero": (["CamisaCuadros", "Jean", "Gorra", "Diarero"], {"CamisaCuadros": ("2f5d8c", "c9c6c0"), "Jean": ("2c3546", "3a2a20"), "Gorra": ("1b1f2a", "f2652b"), "Diarero": ("2f6fdb", "e9e7e2")}),
    "Vendedor": (["RemeraEstampa", "PantalonVestir", "Gorra", "Vendedor"], {"RemeraEstampa": ("e9e7e2", "c2213a"), "PantalonVestir": ("3a3f4b", "121216"), "Gorra": ("c2213a", "e9e7e2"), "Vendedor": ("c0c4cc", "f2a23a")}),
    "Musico": (["CamperaJean", "Jogging", "GorroLana", "Musico"], {"CamperaJean": ("4a6a90", "b8bcc6"), "Jogging": ("1b1f2a", "e9e7e2"), "GorroLana": ("6b5ba8", "e9e7e2"), "Musico": ("8a5a2e", "2a2018")}),
}

# 6 civiles de ejemplo (paso 1) y 12 para la vereda (paso 2): piezas + colores (C1, C2).
EJEMPLOS = [
    ["SacoOficina", "PantalonVestir", "PeloCorto", "Maletin"],
    ["BuzoCapucha", "Jogging", "Auriculares", "Cafe"],
    ["PilotoLargo", "Pollera", "PeloLargoAtado", "ParaguasAbierto"],
    ["ChalecoObra", "Mameluco", "Gorra", "Telefono"],
    ["UniformeEnfermeria", "Jean", "Rulos", "BolsaCompras"],
    ["RemeraEstampa", "Bermuda", "PeladoBarba", "CorreaPerro"],
]
VEREDA = EJEMPLOS + [
    ["CamperaJean", "Jean", "GorroLana", "Mochila"],
    ["CamisaCuadros", "PantalonVestir", "Sombrero", "ParaguasCerrado"],
    ["SacoOficina", "Pollera", "Rulos", "Telefono"],
    ["BuzoCapucha", "Bermuda", "Gorra", "Mochila"],
    ["PilotoLargo", "PantalonVestir", "PeladoBarba", "Maletin"],
    ["RemeraEstampa", "Jogging", "PeloLargoAtado", "Cafe"],
]

PALETA_ROPA = ["2c3546", "3a3f4b", "6e3b2e", "8a5a2e", "2f5d8c", "4a6a90", "c2213a", "3d6b3f", "6b5ba8", "c9c6c0", "e9e7e2", "1b1f2a", "a3312a", "d9a441", "4ed68a", "7a7d84"]
PALETA_PELO = ["1a1410", "3a2a20", "6e4a35", "b08a5a", "c9c6c0"]
FLUOR = "e8f04a"
# Hebillas, gomitas y anteojos: colores vivos que nunca se confunden con el pelo.
PALETA_ACCESORIO_PELO = ["f2a23a", "3fe0f0", "ff4d6d", "4ed68a", "e9e7e2", "a15cf0"]


def colores_al_azar(piezas, semilla):
    rng = random.Random(semilla)
    out = {}
    for p in piezas:
        tipo = TIPOS[p]
        if tipo == "cabeza" and p in ("PeloCorto", "PeloLargoAtado", "Rulos", "PeladoBarba"):
            out[p] = (rng.choice(PALETA_PELO), rng.choice(PALETA_ACCESORIO_PELO))
        elif p == "ChalecoObra":
            out[p] = (rng.choice(PALETA_ROPA), FLUOR)
        else:
            out[p] = (rng.choice(PALETA_ROPA), rng.choice(PALETA_ROPA))
    return out


TIPOS = {}


# ---------------------------------------------------------------------------
# Materiales de color (para los renders: el juego pinta con MeshPart.Color)
# ---------------------------------------------------------------------------


def material_tenido(base, hex_):
    """Copia de `base` multiplicada por un color (sirve para el gris liso y para el horneado)."""
    nombre = f"{base.name}__{hex_}"
    mat = bpy.data.materials.get(nombre)
    if mat:
        return mat
    mat = base.copy()
    mat.name = nombre
    arbol = mat.node_tree
    bsdf = next(n for n in arbol.nodes if n.type == "BSDF_PRINCIPLED")
    entrada = bsdf.inputs["Base Color"]
    mezcla = arbol.nodes.new("ShaderNodeMix")
    mezcla.data_type = "RGBA"
    mezcla.blend_type = "MULTIPLY"
    mezcla.inputs["Factor"].default_value = 1.0
    mezcla.inputs[7].default_value = B.color(hex_)
    if entrada.is_linked:
        origen = entrada.links[0].from_socket
        arbol.links.remove(entrada.links[0])
        arbol.links.new(origen, mezcla.inputs[6])
    else:
        mezcla.inputs[6].default_value = entrada.default_value
    arbol.links.new(mezcla.outputs[2], entrada)
    return mat


def _canal(o):
    for c in CANALES:
        if o.name.endswith("_" + c):
            return c
    return None


def civil(piezas_kit, nombre_piezas, colores, x=0.0, y=0.0, giro=0.0):
    """Copia del maniquí con esas piezas, movido a (x, y). Las mallas se comparten."""
    arm = B.esqueleto()
    nuevo = arm.copy()
    bpy.context.scene.collection.objects.link(nuevo)
    nuevo.location = arm.location + Vector((x, y, 0))
    nuevo.rotation_euler = (0, 0, math.radians(giro))
    objs = [nuevo]
    for o in B.partes() + [ob for n in nombre_piezas for ob in piezas_kit[n][1]]:
        c = o.copy()
        bpy.context.scene.collection.objects.link(c)
        if o.parent == arm:
            c.parent = nuevo
        else:
            c.matrix_world = Matrix.Translation((x, y, 0)) @ Matrix.Rotation(math.radians(giro), 4, "Z") @ o.matrix_world
        c.hide_render = c.hide_viewport = False
        canal = _canal(o)
        if canal:
            dueño = next(n for n in nombre_piezas if o in piezas_kit[n][1])
            hex_ = colores.get(dueño, ("c9c6c0", "7a7d84"))[0 if canal == "C1" else 1]
            c.material_slots[0].link = "OBJECT"
            c.material_slots[0].material = material_tenido(o.material_slots[0].material, hex_)
        objs.append(c)
    return objs


def mostrar_en_glb(piezas_kit, nombres=("CamisaCuadros", "Jean", "Gorra", "Diarero")):
    """Deja visible solo al diarero (el .glb de Obsidian lleva lo que se renderiza)."""
    esconder_kit(piezas_kit)
    for n in nombres:
        for o in piezas_kit[n][1]:
            o.hide_render = o.hide_viewport = False


def esconder_kit(piezas_kit, visible=False):
    for _, objs in piezas_kit.values():
        for o in objs:
            o.hide_render = o.hide_viewport = not visible


# ---------------------------------------------------------------------------
# Renders
# ---------------------------------------------------------------------------


def render_ancho(nombre, objs, resolucion=(2400, 900), altura=4.0, giro=0.0, margen=1.08):
    """Cámara de frente que encuadra `objs` en una imagen ancha: renders/<nombre>.png."""
    escena = bpy.context.scene
    bpy.context.view_layer.update()
    minimo, maximo = B.caja_de([o for o in objs if o.type == "MESH"])
    centro = (minimo + maximo) / 2
    datos = bpy.data.cameras.new("Ancha")
    datos.lens = B.LENTE
    datos.sensor_fit = "HORIZONTAL"
    cam = bpy.data.objects.new("Ancha", datos)
    escena.collection.objects.link(cam)
    aspecto = resolucion[0] / resolucion[1]
    tam = maximo - minimo
    medio_h = math.atan(datos.sensor_width / 2 / datos.lens)
    medio_v = math.atan(math.tan(medio_h) / aspecto)
    dist = max(tam.x / 2 / math.tan(medio_h), tam.z / 2 / math.tan(medio_v)) * margen + tam.y / 2
    a, e = math.radians(giro), math.radians(altura)
    desde = centro + Vector((-math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e))) * dist
    B._apuntar(cam, desde, centro)
    antes = (escena.camera, escena.render.resolution_x, escena.render.resolution_y)
    escena.camera = cam
    escena.render.resolution_x, escena.render.resolution_y = resolucion
    ruta = os.path.join(B.RENDERS, f"{nombre}.png")
    escena.render.filepath = ruta
    try:
        bpy.ops.render.render(write_still=True)
    finally:
        escena.camera, escena.render.resolution_x, escena.render.resolution_y = antes
        bpy.data.objects.remove(cam)
        bpy.data.cameras.remove(datos)
    return ruta


def _borrar(objs):
    for o in objs:
        bpy.data.objects.remove(o)


def render_grilla(prefijo, piezas_kit):
    """Cada pieza sola sobre el maniquí (con colores de muestra), en filas por tipo:
    renders/<prefijo>_grilla.png. Los props de los especiales no van (salen en los ejemplos)."""
    esconder_kit(piezas_kit)
    for p in B.partes():
        p.hide_render = True
    filas = []
    temporales = []
    for tipo in ("arriba", "abajo", "cabeza", "accesorio", "telefono"):
        fila = []
        for i, (nombre, (t, objs)) in enumerate(piezas_kit.items()):
            if t != tipo:
                continue
            copias = civil(piezas_kit, [nombre], colores_al_azar([nombre], i))
            bpy.context.view_layer.update()
            ruta = B.render_primer_plano(f"_{prefijo}_pieza_{nombre}", [o for o in copias if o.type == "MESH"], giro=25, altura=8, margen=1.15)
            fila.append(ruta)
            temporales.append(ruta)
            _borrar(copias)
        filas.append(fila)
    ruta = os.path.join(B.RENDERS, f"{prefijo}_grilla.png")
    B.hoja(filas, ruta, reducir=3)
    for r in temporales:
        os.remove(r)
    for p in B.partes():
        p.hide_render = False
    return ruta


def render_ejemplos(prefijo, piezas_kit):
    esconder_kit(piezas_kit)
    for p in B.partes():
        p.hide_render = True
    copias = []
    for i, nombres in enumerate(EJEMPLOS):
        copias += civil(piezas_kit, nombres, colores_al_azar(nombres, 10 + i), x=-i * 1.7)
    ruta = render_ancho(f"{prefijo}_ejemplos", copias, altura=6)
    _borrar(copias)
    copias = []
    for i, (nombre, (nombres, colores)) in enumerate(ESPECIALES.items()):
        copias += civil(piezas_kit, nombres, colores, x=-i * 2.6)
    ruta2 = render_ancho(f"{prefijo}_especiales", copias, altura=8, giro=20)
    _borrar(copias)
    for p in B.partes():
        p.hide_render = False
    return ruta, ruta2


def render_vereda(prefijo, piezas_kit):
    """Vereda de noche con 12 civiles mezclados caminando para los dos lados."""
    esconder_kit(piezas_kit)
    for p in B.partes():
        p.hide_render = True
    random.seed(12)
    copias = []
    for i, nombres in enumerate(VEREDA):
        x = -i * 0.75 + random.uniform(-0.1, 0.1)
        y = random.choice((-0.6, 0.0, 0.6)) + random.uniform(-0.1, 0.1)
        copias += civil(piezas_kit, nombres, colores_al_azar(nombres, 100 + i), x=x, y=y, giro=random.choice((0, 180, 15, -20, 160)))
    escena = bpy.context.scene
    bpy.context.view_layer.update()
    minimo, maximo = B.caja_de([o for o in copias if o.type == "MESH"])
    me = bpy.data.meshes.new("Vereda")
    bmv = __import__("bmesh").new()
    T.caja(bmv, Vector(((minimo.x + maximo.x) / 2, 0.2, minimo.z - 0.05)), Vector((maximo.x - minimo.x + 2.0, 3.0, 0.1)))
    for k in range(12):  # baldosas
        T.caja(bmv, Vector((minimo.x - 1 + k * (maximo.x - minimo.x + 2) / 11, 0.2, minimo.z + 0.001)), Vector((0.02, 3.0, 0.004)))
    T.caja(bmv, Vector(((minimo.x + maximo.x) / 2, -1.35, minimo.z - 0.12)), Vector((maximo.x - minimo.x + 2.0, 0.15, 0.25)))  # cordón
    bmv.to_mesh(me)
    bmv.free()
    vereda = bpy.data.objects.new("Vereda", me)
    escena.collection.objects.link(vereda)
    me.materials.append(B.material("asfalto"))
    pared = bpy.data.objects.new("Pared", bpy.data.meshes.new("Pared"))
    bmp = __import__("bmesh").new()
    T.caja(bmp, Vector(((minimo.x + maximo.x) / 2, 1.9, minimo.z + 1.5)), Vector((maximo.x - minimo.x + 2.0, 0.2, 3.2)))
    bmp.to_mesh(pared.data)
    bmp.free()
    pared.data.materials.append(B.material("ladrillo"))
    escena.collection.objects.link(pared)
    ruta = render_ancho(f"{prefijo}_vereda", copias, resolucion=(2400, 1000), altura=10, giro=-15, margen=1.0)
    _borrar(copias + [vereda, pared])
    for p in B.partes():
        p.hide_render = False
    return ruta


# ---------------------------------------------------------------------------
# Triángulos
# ---------------------------------------------------------------------------


def _miles(n):
    return f"{n:,}".replace(",", ".")


def tabla_triangulos(piezas_kit):
    filas = ["| Pieza | Tipo | Triángulos | Tope | Mallas |", "|---|---|---|---|---|"]
    cuenta = {}
    for nombre, (tipo, objs) in piezas_kit.items():
        n = sum(B.triangulos(o) for o in objs)
        cuenta[nombre] = n
        if tipo == "especial":
            continue
        tope = TOPES_PIEZA.get(nombre, TOPES[tipo])
        marca = "" if n <= tope else " ⚠"
        filas.append(f"| {nombre} | {tipo} | {_miles(n)}{marca} | {_miles(tope)} | {len(objs)} |")
    filas += ["", "| Civil | Piezas | Triángulos | Tope |", "|---|---|---|---|"]
    for i, nombres in enumerate(VEREDA):
        n = sum(cuenta[p] for p in nombres)
        filas.append(f"| Ejemplo {i + 1} | {', '.join(nombres)} | {_miles(n)}{'' if n <= TOPE_CIVIL else ' ⚠'} | {_miles(TOPE_CIVIL)} |")
    for nombre, (nombres, _) in ESPECIALES.items():
        n = sum(cuenta[p] for p in nombres)
        filas.append(f"| {nombre} (especial) | {', '.join(nombres)} | {_miles(n)}{'' if n <= TOPES['especial'] else ' ⚠'} | {_miles(TOPES['especial'])} |")
    peor = max(sum(cuenta[p] for p in combo) for combo in _peores_combos(piezas_kit, cuenta))
    filas += ["", f"Civil más pesado posible (la combinación más cara de arriba + abajo + cabeza + accesorio): {_miles(peor)} triángulos."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, ARCHIVO + "_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Civiles: triángulos por pieza\n\n" + texto + "\n")
    return texto


def _peores_combos(piezas_kit, cuenta):
    mayor = {}
    for nombre, (tipo, _) in piezas_kit.items():
        if tipo in ("arriba", "abajo", "cabeza", "accesorio") and cuenta[nombre] > cuenta.get(mayor.get(tipo), -1):
            mayor[tipo] = nombre
    return [list(mayor.values())]


# ---------------------------------------------------------------------------
# Pasos
# ---------------------------------------------------------------------------


def armar():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for nombre in CANALES.values():
        B.material(nombre)
    piezas = construir_todo()
    TIPOS.update({k: t for k, (t, _) in piezas.items()})
    return piezas


def boceto():
    piezas = armar()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    print("Grilla:", render_grilla(ARCHIVO + "_boceto", piezas))
    print("Ejemplos:", render_ejemplos(ARCHIVO + "_boceto", piezas))
    mostrar_en_glb(piezas)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)


def render_primeros_planos(prefijo, piezas_kit):
    """Piezas chicas de cerca: café, teléfono, mochila de atrás, carritos y guitarra."""
    esconder_kit(piezas_kit)
    planos = [
        ("cafe", ["Cafe", "SacoOficina"], 30, 10, 1.0, ["RightHand", "RightLowerArm"]),
        ("telefono", ["Telefono", "ChalecoObra"], 35, 10, 1.0, ["RightHand", "RightLowerArm"]),
        ("mochila", ["Mochila", "BuzoCapucha"], 160, 10, 1.15, None),
        ("cabezas", ["Rulos"], 25, 8, 1.4, ["Head"]),
        ("diarero", ESPECIALES["Diarero"][0], 25, 12, 1.05, None),
        ("vendedor", ESPECIALES["Vendedor"][0], 25, 12, 1.05, None),
        ("musico", ESPECIALES["Musico"][0], 25, 12, 1.05, None),
    ]
    rutas = []
    for nombre, nombres, giro, altura, margen, foco in planos:
        colores = ESPECIALES[nombre.title()][1] if nombre.title() in ESPECIALES else colores_al_azar(nombres, len(rutas) + 40)
        copias = civil(piezas_kit, nombres, colores)
        bpy.context.view_layer.update()
        if foco:
            mira = [o for o in copias if o.type == "MESH" and (o.parent_bone in foco or any(n in o.name for n in nombres[:1]))]
        else:
            mira = [o for o in copias if o.type == "MESH"]
        rutas.append(B.render_primer_plano(f"{prefijo}_{nombre}", mira, giro=giro, altura=altura, margen=margen))
        _borrar(copias)
    return rutas


def _presupuesto(piezas_kit):
    """Tope de cada pieza con bisel: el del tipo, pero sin pasar 1,3 veces el boceto, así el civil
    más pesado sigue debajo de 6.000."""
    grupos = {}
    for nombre, (tipo, objs) in piezas_kit.items():
        base = sum(B.triangulos(o) for o in objs)
        grupos[nombre] = (min(TOPES_PIEZA.get(nombre, TOPES[tipo]), int(base * 1.3)), [o.name for o in objs])
    return grupos


def detalle():
    import detalle as D

    piezas = armar()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    objs = [o for _, lista in piezas.values() for o in lista]
    chicas = {"cabeza", "accesorio", "telefono"}
    lados = {o.name: (256 if t in chicas else 512) for t, lista in piezas.values() for o in lista}
    D.terminar(objs, _presupuesto(piezas), ARCHIVO, lados=lados)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    print("Grilla:", render_grilla(ARCHIVO, piezas))
    print("Ejemplos:", render_ejemplos(ARCHIVO, piezas))
    print("Primeros planos:", render_primeros_planos(ARCHIVO, piezas))
    print("Vereda:", render_vereda(ARCHIVO, piezas))
    mostrar_en_glb(piezas)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)


def exportar():
    """exports/civiles/<tipo>/<pieza>.fbx: una carpeta por tipo y una por pieza (cada malla, un
    FBX: <Pieza>_<Hueso>_<Canal>.fbx)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    total = 0
    for nombre, (tipo, _) in catalogo_tipos().items():
        for prefijo in PROPS.get(nombre, [nombre]):
            objs = [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(f"{PREFIJO}_{prefijo}_") and not o.name.endswith("_Alto")]
            for o in objs:
                o.hide_render = o.hide_viewport = False
                archivo = o.name.replace(f"{PREFIJO}_", "") if nombre in PROPS else o.name.replace(f"{PREFIJO}_{nombre}_", "")
                B.exportar_fbx(o, os.path.join(B.EXPORTS, ARCHIVO, tipo, nombre, archivo + ".fbx"))
                total += 1
    print("Exportadas:", total)


def paquete():
    """Un solo FBX para que Juani importe en Studio (exports/civiles/_PaqueteCiviles.fbx): todas
    las mallas del kit y de los especiales, más copias del maniquí llamadas Ref_<Parte>. En Studio,
    cada malla se ubica respecto de su Ref_ (así el código sabe dónde pegarla en cada civil)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    objs = [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(PREFIJO + "_") and not o.name.endswith("_Alto")]
    refs = []
    for p in B.partes():
        c = p.copy()
        c.data = p.data.copy()
        bpy.context.scene.collection.objects.link(c)
        c.matrix_world = p.matrix_world.copy()
        c.name = "Ref_" + p.name.replace(B.ESQUELETO + "_", "")
        refs.append(c)
    for o in bpy.context.scene.objects:
        o.hide_viewport = o.hide_render = False
        o.hide_set(False)
        o.select_set(o in objs or o in refs)
    bpy.context.view_layer.objects.active = objs[0]
    ruta = os.path.join(B.EXPORTS, ARCHIVO, "_PaqueteCiviles.fbx")
    bpy.ops.export_scene.fbx(
        filepath=ruta,
        use_selection=True,
        object_types={"MESH"},
        global_scale=1 / B.STUD,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
        bake_space_transform=True,
        use_mesh_modifiers=True,
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
        bake_anim=False,
    )
    print("Paquete:", ruta, len(objs), "mallas +", len(refs), "referencias")
    return ruta


def catalogo_tipos():
    """Nombre -> (tipo, None), sin construir nada (para exportar desde el .blend guardado)."""
    tipos = {}
    for nombre in list(EJEMPLOS_TODOS) + list(ESPECIALES):
        tipos[nombre] = ("especial" if nombre in ESPECIALES else _TIPO_FIJO[nombre], None)
    return tipos


_TIPO_FIJO = {
    **{n: "arriba" for n in ("CamperaJean", "SacoOficina", "BuzoCapucha", "CamisaCuadros", "PilotoLargo", "ChalecoObra", "RemeraEstampa", "UniformeEnfermeria")},
    **{n: "abajo" for n in ("Jean", "PantalonVestir", "Pollera", "Jogging", "Bermuda", "Mameluco")},
    **{n: "cabeza" for n in ("Gorra", "GorroLana", "PeloCorto", "PeloLargoAtado", "Rulos", "PeladoBarba", "Sombrero", "Auriculares")},
    **{n: "accesorio" for n in ("Maletin", "BolsaCompras", "Mochila", "ParaguasAbierto", "ParaguasCerrado", "Cafe", "CorreaPerro")},
    "Telefono": "telefono",
}
EJEMPLOS_TODOS = list(_TIPO_FIJO)
# Civil especial -> nombres de sus props dentro del .blend (la ropa sale del kit).
PROPS = {"Diarero": ["CarritoDiarios"], "Vendedor": ["CarritoPanchos"], "Musico": ["Guitarra", "EstucheGuitarra"]}


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    for paso in ("boceto", "detalle", "exportar", "paquete"):
        if paso in argumentos:
            globals()[paso]()
