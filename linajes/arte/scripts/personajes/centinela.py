"""Centinela Solar: traje sobre el maniquí R15 (Prompt 4 de linajes/ideas/PROMPTS.md).

Último de un pueblo que nació dentro de una estrella. Diseño propio: sin letra ni escudo en el
pecho, sin la combinación azul-rojo-amarillo, sin rulo en la frente. Silueta: armadura heroica
clara, corona de rayos solares flotando detrás de la cabeza, capa corta.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/centinela.py -- boceto

Paso "boceto": bloques sin detalle de las 7 piezas, render de 3 vistas
(renders/centinela_boceto_vistas.png). El detalle (paso 2) va con el OK de Juani.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Centinela"
BLEND = os.path.join(B.BLENDER, "centinela.blend")
S = B.STUD  # 1 stud en metros

# Presupuesto de triángulos por pieza (ficha, total ≤ 38.000).
PRESUPUESTO = {
    "Casco": 7000,
    "Corona": 4000,
    "Peto": 9000,
    "Hombreras": 4000,
    "Brazaletes": 4000,
    "Capa": 6000,
    "Grebas": 4000,
}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def _anillo(bm, centro, radio, grosor, alto, lados=24, eje="Y"):
    """Aro plano (como una arandela) alrededor de `centro`, acostado en el plano que mira a `eje`."""
    for k in range(lados):
        a = 2 * math.pi * (k + 0.5) / lados
        tramo = 2 * math.pi * radio / lados * 1.05
        if eje == "Y":
            p = Vector((math.cos(a) * radio, 0, math.sin(a) * radio))
            T.caja(bm, centro + p, Vector((tramo, alto, grosor)), _g(-math.degrees(a) + 90, "Y"))
        else:
            p = Vector((math.cos(a) * radio, math.sin(a) * radio, 0))
            T.caja(bm, centro + p, Vector((grosor, tramo, alto)), _g(math.degrees(a), "Z"))


# ---------------------------------------------------------------------------
# Boceto de bloques
# ---------------------------------------------------------------------------


def casco():
    """Diadema de oro alrededor de la frente con 3 placas finas hacia atrás; la cara libre."""
    _, hmax, hc, hm = T.caja_parte("Head")
    z = hc.z + hm.z * 0.45

    def diadema(bm):
        _anillo(bm, Vector((hc.x, hc.y, z)), max(hm.x, hm.y) * 1.08, 0.02, hm.z * 0.28, 24, "Z")
        # Tres placas que salen de la diadema hacia atrás, abiertas en abanico.
        for k, grados in enumerate((-22, 0, 22)):
            giro = _g(grados, "Z") @ _g(-12, "X")
            largo = 0.11 if k == 1 else 0.09
            centro = Vector((hc.x, hc.y + hm.y + largo * 0.4, z + 0.01)) + _g(grados, "Z") @ Vector((0, 0, 0))
            centro.x += math.sin(math.radians(grados)) * hm.x * 0.9
            T.caja(bm, centro, Vector((0.025, largo, hm.z * 0.22)), giro)

    return T.pieza(f"{NOMBRE}_Casco", "Head", [("oro", diadema)])


def corona():
    """Anillo de 12 rayos de oro de largos alternados (0,6 y 0,9 studs) a 0,5 studs detrás de
    la cabeza, con un aro interior de neón eclipse."""
    _, hmax, hc, hm = T.caja_parte("Head")
    centro = Vector((hc.x, hc.y + hm.y + 0.5 * S, hc.z + hm.z * 0.2))
    radio = max(hm.x, hm.z) * 1.15

    def rayos(bm):
        for k in range(12):
            a = 2 * math.pi * k / 12
            largo = (0.9 if k % 2 == 0 else 0.6) * S
            d = Vector((math.cos(a), 0, math.sin(a)))
            T.punta(bm, centro + d * radio, centro + d * (radio + largo), 0.035, 4)

    def aro(bm):
        _anillo(bm, centro, radio * 0.92, 0.025, 0.02, 24, "Y")

    return T.pieza(f"{NOMBRE}_Corona", "Head", [("oro", rayos), ("neon-eclipse", aro)])


def peto():
    """Placas de blanco-armadura con bordes de oro; en el centro, un sol de 8 puntas (0,7 studs)
    de oro con centro de neón eclipse."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03
    sol = Vector((tc.x, frente - 0.012, tc.z + tm.z * 0.15))
    radio_sol = 0.35 * S

    def placas(bm):
        T.caja(bm, tc, tm * 2 + Vector((0.05, 0.05, 0.02)))

    def bordes(bm):
        for z in (tmax.z - 0.02, tc.z - tm.z + 0.02):
            T.caja(bm, Vector((tc.x, tc.y, z)), Vector((tm.x * 2 + 0.08, tm.y * 2 + 0.08, 0.025)))
        T.caja(bm, Vector((tc.x, frente - 0.004, tc.z)), Vector((0.03, 0.01, tm.z * 2)))
        for k in range(8):  # el sol: 8 puntas
            a = 2 * math.pi * k / 8
            d = Vector((math.cos(a), 0, math.sin(a)))
            T.punta(bm, sol + d * radio_sol * 0.3, sol + d * radio_sol, 0.025, 4)

    def centro_sol(bm):
        T.caja(bm, sol + Vector((0, -0.008, 0)), Vector((radio_sol * 0.55, 0.012, radio_sol * 0.55)), _g(45, "Y"))

    arriba = T.pieza(f"{NOMBRE}_Peto", "UpperTorso", [("blanco-armadura", placas), ("oro", bordes), ("neon-eclipse", centro_sol)])
    _, _, lc, lm = T.caja_parte("LowerTorso")

    def bajo(bm):
        T.caja(bm, lc, lm * 2 + Vector((0.04, 0.04, 0.0)))

    def cinto(bm):
        T.caja(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.5)), Vector((lm.x * 2 + 0.06, lm.y * 2 + 0.06, 0.03)))

    abajo = T.pieza(f"{NOMBRE}_PetoBajo", "LowerTorso", [("blanco-armadura", bajo), ("oro", cinto)])
    return [arriba, abajo]


def hombreras():
    """Placas redondeadas de blanco-armadura con borde de oro."""
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        _, amax, ac, am = T.caja_parte(hueso)
        afuera = 1 if ac.x > 0 else -1
        c = Vector((ac.x + afuera * 0.015, ac.y, amax.z - am.z * 0.2))

        def placa(bm, c=c, am=am):
            T.bloque_redondo(bm, c, Vector((am.x + 0.04, am.y + 0.04, am.z * 0.35)), 0.6, 16, 8)

        def borde(bm, c=c, am=am):
            T.caja(bm, c + Vector((0, 0, -am.z * 0.3)), Vector((am.x * 2 + 0.1, am.y * 2 + 0.1, 0.02)))

        piezas.append(T.pieza(f"{NOMBRE}_Hombrera{lado}", hueso, [("blanco-armadura", placa), ("oro", borde)]))
    return piezas


def capa():
    """Capa corta de tela dorada hasta las rodillas, en 3 tiras que se separan abajo."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, rmax, _, _ = T.caja_parte("LeftLowerLeg")
    arriba, abajo = tmax.z - 0.02, rmax.z
    largo = arriba - abajo
    atras = tc.y + tm.y + 0.04

    def tiras(bm):
        ancho = tm.x * 2 * 0.36
        for k, s in enumerate((-1, 0, 1)):
            giro = _g(s * 6, "Y") @ _g(-6, "X")
            centro = Vector((tc.x + s * ancho * 1.05, atras + 0.03, arriba - largo / 2))
            T.caja(bm, centro, Vector((ancho, 0.015, largo * (0.95 if k != 1 else 1.0))), giro)
        T.caja(bm, Vector((tc.x, atras - 0.005, arriba - 0.02)), Vector((tm.x * 2 + 0.06, 0.03, 0.05)))

    return T.pieza(f"{NOMBRE}_Capa", "UpperTorso", [("tela-dorada", tiras)])


def brazaletes():
    """Brazaletes (LowerArm) y guantes (Hand) de blanco-armadura con líneas de oro."""
    piezas = []
    for lado, hueso in T._lados("LowerArm"):
        _, _, lc, lm = T.caja_parte(hueso)
        _, _, mc, mm = T.caja_parte(hueso.replace("LowerArm", "Hand"))

        def brazalete(bm, lc=lc, lm=lm):
            T.caja(bm, lc, lm * 2 + Vector((0.04, 0.04, -0.02)))

        def lineas(bm, lc=lc, lm=lm):
            for z in (lc.z + lm.z * 0.6, lc.z - lm.z * 0.6):
                T.caja(bm, Vector((lc.x, lc.y, z)), Vector((lm.x * 2 + 0.05, lm.y * 2 + 0.05, 0.015)))

        def guante(bm, mc=mc, mm=mm):
            T.caja(bm, mc, mm * 2 + Vector((0.025, 0.025, 0.025)))

        piezas.append(T.pieza(f"{NOMBRE}_Brazalete{lado}", hueso, [("blanco-armadura", brazalete), ("oro", lineas)]))
        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso.replace("LowerArm", "Hand"), [("blanco-armadura", guante)]))
    return piezas


def grebas():
    """Grebas (LowerLeg) y botas (Foot) de blanco-armadura, rodilleras de oro y líneas liga."""
    piezas = []
    for lado, hueso in T._lados("LowerLeg"):
        pmin, pmax, pc, pm = T.caja_parte(hueso)
        _, _, fc, fm = T.caja_parte(hueso.replace("LowerLeg", "Foot"))

        def greba(bm, pc=pc, pm=pm, fc=fc, fm=fm):
            T.caja(bm, pc, pm * 2 + Vector((0.04, 0.04, 0.0)))
            T.caja(bm, fc + Vector((0, -0.02, 0)), fm * 2 + Vector((0.03, 0.07, 0.03)))

        def rodillera(bm, pc=pc, pm=pm, pmax=pmax):
            T.caja(bm, Vector((pc.x, pc.y - pm.y - 0.03, pmax.z - 0.02)), Vector((pm.x * 1.5, 0.03, 0.08)))

        def linea(bm, pc=pc, pm=pm):
            T.caja(bm, Vector((pc.x, pc.y - pm.y - 0.025, pc.z - pm.z * 0.15)), Vector((0.018, 0.01, pm.z * 1.3)))

        piezas.append(
            T.pieza(f"{NOMBRE}_Greba{lado}", hueso, [("blanco-armadura", greba), ("oro", rodillera), ("liga", linea)])
        )
    return piezas


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [casco(), corona(), *peto(), *hombreras(), capa(), *brazaletes(), *grebas()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    cuenta = B.contar_triangulos(piezas)
    print("Triángulos:", cuenta)
    print("Render:", B.render_vistas("centinela_boceto", B.partes() + piezas))
    return piezas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in argumentos:
        boceto()
