"""Centinela Solar: traje sobre el maniquí R15 (Prompt 4 de linajes/ideas/PROMPTS.md).

Último de un pueblo que nació dentro de una estrella. Diseño propio: sin letra ni escudo en el
pecho, sin la combinación azul-rojo-amarillo, sin rulo en la frente. Silueta: armadura heroica
clara, corona de rayos solares flotando detrás de la cabeza, capa corta.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/centinela.py -- boceto

Paso "boceto": bloques sin detalle de las 7 piezas, render de 3 vistas
(renders/centinela_boceto_vistas.png).
Paso "detalle": las 7 piezas con el NIVEL DE DETALLE OBLIGATORIO (detalle.py), tabla de
triángulos, 3 vistas y primeros planos de corona, emblema y capa.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import cuervo as C  # noqa: E402  (cáscaras, plumas y BVH)
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


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------


def _rayo(bm, base, hacia, cara, largo, ancho, grosor, secciones=6):
    """Rayo o punta de sol: hoja con corte de rombo (filo en el medio de cada cara) que se afina
    hasta la punta. `hacia` es hacia dónde crece y `cara` hacia dónde mira."""
    d = Vector(hacia).normalized()
    w = Vector(cara).normalized()
    w = (w - d * w.dot(d)).normalized()
    v = d.cross(w)
    secs = []
    for k in range(secciones + 1):
        t = k / secciones
        hw = max(ancho / 2 * (1 - t) ** 0.9, ancho * 0.03)
        ht = max(grosor / 2 * (1 - 0.6 * t), grosor * 0.1)
        p = Vector(base) + d * largo * t
        secs.append([bm.verts.new(p + v * hw), bm.verts.new(p + w * ht), bm.verts.new(p - v * hw), bm.verts.new(p - w * ht)])
    for a, b in zip(secs, secs[1:]):
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(list(reversed(secs[0])))
    bm.faces.new(secs[-1])


def _aro(bm, centro, radio, r_radial, r_eje, eje="Y", n=48, lados=8):
    """Aro cerrado (toro) alrededor de `centro`, con corte elíptico: `r_radial` de ancho y
    `r_eje` de espesor. eje "Y" = mira al frente; "Z" = acostado."""
    ax = Vector((0, 1, 0)) if eje == "Y" else Vector((0, 0, 1))
    aros = []
    for i in range(n):
        a = 2 * math.pi * i / n
        d = Vector((math.cos(a), 0, math.sin(a))) if eje == "Y" else Vector((math.cos(a), math.sin(a), 0))
        aros.append(
            [
                bm.verts.new(Vector(centro) + d * (radio + math.cos(b) * r_radial) + ax * math.sin(b) * r_eje)
                for b in (2 * math.pi * k / lados for k in range(lados))
            ]
        )
    for i in range(n):
        a, b = aros[i], aros[(i + 1) % n]
        for k in range(lados):
            q = (k + 1) % lados
            bm.faces.new((a[k], a[q], b[q], b[k]))


def _sobre(arbol, centro, direccion, separacion):
    """Punto sobre la superficie de `arbol` tirando un rayo desde afuera hacia `centro`."""
    d = Vector(direccion).normalized()
    return T.sobre_superficie(arbol, Vector(centro) + d * 1.0, -d, separacion)


def d_casco():
    """Diadema de oro en la frente (con punta en V, bordes levantados y remaches), un sol chico
    con gema de neón al frente y 3 placas finas hacia atrás. La cara queda libre."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.016, 0.016, 0.016))
    z0, z1 = hc.z + hm.z * 0.22, hc.z + hm.z * 0.6
    zm = (z0 + z1) / 2
    frente = hc.y - m.y

    def abajo(p):  # borde de abajo: baja en V en el medio de la frente
        return z0 - 0.045 * max(0.0, 1 - abs(p.x - hc.x) / (m.x * 0.35)) * (p.y < hc.y)

    def diadema(bm):
        C._cascara(bm, hc, m, 0.5, 48, 30, lambda p: abajo(p) < p.z < z1, 0.01)
        # Bordes levantados arriba y abajo (placa en capas).
        mb = m + Vector((0.007, 0.007, 0.007))
        C._cascara(bm, hc, mb, 0.5, 48, 30, lambda p: z1 - 0.012 < p.z < z1 + 0.004, 0.006)
        C._cascara(bm, hc, mb, 0.5, 48, 30, lambda p: abajo(p) - 0.004 < p.z < abajo(p) + 0.012, 0.006)
        # Remaches alrededor (no adelante, donde va el sol).
        arbol = C._bvh(lambda b: T.bloque_redondo(b, hc, m + Vector((0.01, 0.01, 0.01)), 0.5, 48, 30))
        for k in range(14):
            a = 2 * math.pi * k / 14 + math.pi / 14
            d = Vector((math.sin(a), -math.cos(a), 0))
            if d.y < -0.8:
                continue
            p, n = _sobre(arbol, Vector((hc.x, hc.y, zm)), d, 0.001)
            if p:
                T.remache(bm, p, 0.006, n)
        # Sol de la frente: disco y 5 rayos chicos hacia arriba.
        sol = Vector((hc.x, frente - 0.016, zm))
        T.cilindro(bm, sol + Vector((0, 0.008, 0)), sol + Vector((0, -0.006, 0)), 0.03, 20)
        for k in range(5):
            a = math.radians(90 + (k - 2) * 32)
            d = Vector((math.cos(a), 0, math.sin(a)))
            largo = 0.06 if k == 2 else (0.048 if k in (1, 3) else 0.036)
            _rayo(bm, sol + d * 0.024, d, (0, -1, 0), largo, 0.024, 0.012)
        # Tres placas finas hacia atrás: dos en las sienes (como alas) y una arriba.
        for lado in (-1, 1):
            raiz = Vector((hc.x + lado * (m.x + 0.006), hc.y + m.y * 0.15, zm))
            C._pluma_3d(bm, raiz, (lado * 0.35, 1.0, 0.45), (lado, 0, 0.2), 0.2, 0.06, 0.007, curva=0.015, segmentos=8)
        raiz = Vector((hc.x, hc.y - m.y * 0.35, hmax.z + 0.012))
        C._pluma_3d(bm, raiz, (0, 1.0, 0.18), (0, -0.15, 1), 0.24, 0.07, 0.007, curva=-0.02, segmentos=8)

    def gema(bm):
        T.bloque_redondo(bm, Vector((hc.x, frente - 0.024, zm)), Vector((0.016, 0.009, 0.016)), 0.7, 16, 10)

    return T.pieza_separada(f"{NOMBRE}_Casco", "Head", [("oro", diadema), ("neon-eclipse", gema)])


def centro_corona():
    _, _, hc, hm = T.caja_parte("Head")
    return Vector((hc.x, hc.y + hm.y + 0.5 * S, hc.z + hm.z * 0.2)), max(hm.x, hm.z) * 1.15


def d_corona():
    """Anillo de 12 rayos de oro de largos alternados (0,6 y 0,9 studs) a 0,5 studs detrás de
    la cabeza, con aro interior de neón eclipse. Pieza aparte con el pivote en el centro, para
    girarla en el juego."""
    centro, radio = centro_corona()

    def oro(bm):
        _aro(bm, centro, radio, 0.012, 0.014, "Y", 64, 8)
        _aro(bm, centro, radio * 0.74, 0.006, 0.01, "Y", 64, 6)
        for k in range(12):
            a = 2 * math.pi * k / 12
            d = Vector((math.cos(a), 0, math.sin(a)))
            largo = (0.9 if k % 2 == 0 else 0.6) * S
            ancho = 0.06 if k % 2 == 0 else 0.045
            _rayo(bm, centro + d * (radio - 0.004), d, (0, -1, 0), largo, ancho, 0.028, 7)
            # Placa de refuerzo en la raíz de cada rayo (capa de abajo, más ancha y corta).
            _rayo(bm, centro + d * (radio - 0.012), d, (0, -1, 0), largo * 0.28, ancho * 1.5, 0.016, 3)
            # Remaches adelante y atrás entre rayo y rayo.
            b = a + math.pi / 12
            e = Vector((math.cos(b), 0, math.sin(b)))
            for lado in (-1, 1):
                T.remache(bm, centro + e * radio + Vector((0, lado * 0.0135, 0)), 0.0055, (0, lado, 0))

    def neon(bm):
        _aro(bm, centro, radio * 0.86, 0.012, 0.007, "Y", 64, 6)

    return T.pieza_separada(f"{NOMBRE}_Corona", "Head", [("oro", oro), ("neon-eclipse", neon)])


def d_peto():
    """Peto blanco con pectorales y abdominales en placas, bordes de oro, cuello de oro y el sol
    de 8 puntas (pieza Emblema) en el medio."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    sup = tc.y - tm.y - 0.02
    pectorales = [(lado * tm.x * 0.47, tc.z + tm.z * 0.47, tm.x * 0.47, 0.04, tm.z * 0.3) for lado in (-1, 1)]
    abdominales = [
        (lado * tm.x * 0.21, tc.z - tm.z * (0.12 + 0.27 * fila), tm.x * 0.19, 0.026 - 0.003 * fila, tm.z * 0.12)
        for fila in range(3)
        for lado in (-1, 1)
    ]
    costados = [(lado * tm.x * 0.78, tc.z - tm.z * 0.35, tm.x * 0.2, 0.02, tm.z * 0.38) for lado in (-1, 1)]

    def base(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.02, 0.02, 0.008)), 0.25, 24, 12)
        for x, z, w, y, h in pectorales:
            T.bloque_redondo(bm, Vector((tc.x + x, sup - 0.014, z)), Vector((w, y, h)), 0.6, 20, 12)
        for x, z, w, y, h in abdominales:
            T.bloque_redondo(bm, Vector((tc.x + x, sup - 0.004, z)), Vector((w, y, h)), 0.5, 12, 8)
        for x, z, w, y, h in costados:
            T.bloque_redondo(bm, Vector((tc.x + x, sup + 0.004, z)), Vector((w, y, h)), 0.55, 12, 8)
        for lado in (-1, 1):  # espalda: dos placas chatas (las tapa la capa)
            T.bloque_redondo(bm, Vector((tc.x + lado * tm.x * 0.45, tc.y + tm.y + 0.012, tc.z + tm.z * 0.2)),
                             Vector((tm.x * 0.43, 0.012, tm.z * 0.55)), 0.6, 12, 8)

    def bordes(bm):
        # Placa de oro bajo cada pectoral y abdominal (asoma como borde), esternón, cuello y ribetes.
        for x, z, w, y, h in pectorales:
            T.bloque_redondo(bm, Vector((tc.x + x * 1.02, sup - 0.002, z + 0.002)), Vector((w + 0.012, 0.03, h + 0.012)), 0.45, 18, 8)
        for x, z, w, y, h in abdominales:
            T.bloque_redondo(bm, Vector((tc.x + x, sup + 0.006, z)), Vector((w + 0.007, y, h + 0.007)), 0.45, 12, 6)
        T.bloque_redondo(bm, Vector((tc.x, sup - 0.016, tc.z - tm.z * 0.42)), Vector((0.01, 0.02, tm.z * 0.32)), 0.4, 8, 6)
        T.bloque_redondo(bm, Vector((tc.x, tc.y, tmax.z + 0.006)), Vector((tm.x * 0.42, tm.y * 0.95, 0.032)), 0.45, 24, 6)
        for z in (tmax.z - 0.025, tc.z - tm.z + 0.02):
            T.bloque_redondo(bm, Vector((tc.x, tc.y, z)), Vector((tm.x + 0.03, tm.y + 0.03, 0.012)), 0.3, 28, 4)

    arriba = T.pieza_separada(f"{NOMBRE}_Peto", "UpperTorso", [("blanco-armadura", base), ("oro", bordes)])

    lmin, _, lc, lm = T.caja_parte("LowerTorso")

    def bajo(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.02, 0.02, 0.0)), 0.25, 32, 8)
        # Faldones: dos placas adelante y una a cada costado.
        for lado in (-1, 1):
            T.bloque_redondo(bm, Vector((lc.x + lado * lm.x * 0.48, lc.y - lm.y - 0.02, lmin.z - 0.03)),
                             Vector((lm.x * 0.38, 0.012, 0.075)), 0.4, 12, 8)
            T.bloque_redondo(bm, Vector((lc.x + lado * (lm.x + 0.03), lc.y, lmin.z - 0.02)),
                             Vector((0.012, lm.y * 0.7, 0.06)), 0.4, 10, 8)

    def cinto(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.4)), Vector((lm.x + 0.035, lm.y + 0.035, 0.03)), 0.3, 32, 8)
        T.bloque_redondo(bm, Vector((lc.x, lc.y - lm.y - 0.035, lc.z + lm.z * 0.4)), Vector((0.04, 0.012, 0.04)), 0.45, 14, 8)
        for lado in (-1, 1):  # ribete de oro abajo de cada faldón
            T.bloque_redondo(bm, Vector((lc.x + lado * lm.x * 0.48, lc.y - lm.y - 0.025, lmin.z - 0.1)),
                             Vector((lm.x * 0.4, 0.014, 0.01)), 0.4, 12, 4)
            for k in (-1, 1):
                T.remache(bm, Vector((lc.x + lado * lm.x * 0.48 + k * lm.x * 0.25, lc.y - lm.y - 0.034, lmin.z + 0.02)), 0.005)

    abajo = T.pieza_separada(f"{NOMBRE}_PetoBajo", "LowerTorso", [("blanco-armadura", bajo), ("oro", cinto)])
    return arriba + abajo + d_emblema()


def lugar_emblema():
    _, _, tc, tm = T.caja_parte("UpperTorso")
    sup = tc.y - tm.y - 0.02
    return Vector((tc.x, sup - 0.058, tc.z + tm.z * 0.3)), 0.35 * S


def d_emblema():
    """EMBLEMA PROPIO: sol de 8 puntas de 0,7 studs en relieve, de oro, con centro de neón."""
    c, radio = lugar_emblema()

    def sol(bm):
        T.cilindro(bm, c + Vector((0, 0.03, 0)), c + Vector((0, -0.004, 0)), radio * 0.42, 32)
        _aro(bm, c + Vector((0, -0.006, 0)), radio * 0.3, 0.007, 0.008, "Y", 40, 6)
        for k in range(8):
            a = 2 * math.pi * k / 8 + math.pi / 2
            d = Vector((math.cos(a), 0, math.sin(a)))
            largo = radio * (0.64 if k % 2 == 0 else 0.48)
            _rayo(bm, c + d * radio * 0.36, d, (0, -1, 0), largo, radio * 0.32, 0.026, 6)
        for k in range(8):  # remaches entre punta y punta
            a = 2 * math.pi * (k + 0.5) / 8 + math.pi / 2
            T.remache(bm, c + Vector((math.cos(a), 0, math.sin(a))) * radio * 0.38 + Vector((0, -0.006, 0)), 0.005)

    def centro(bm):
        T.bloque_redondo(bm, c + Vector((0, -0.006, 0)), Vector((radio * 0.24, 0.012, radio * 0.24)), 0.6, 24, 10)

    return T.pieza_separada(f"{NOMBRE}_Emblema", "UpperTorso", [("oro", sol), ("neon-eclipse", centro)])


def d_hombreras():
    """Dos placas curvas en capas de blanco-armadura, cada una con su borde de oro, una línea de
    oro por arriba y remaches."""
    objs = []
    for lado, hueso in T._lados("UpperArm"):
        _, amax, ac, am = T.caja_parte(hueso)
        afuera = 1 if ac.x > 0 else -1
        capas = []
        for k, (crece, sube) in enumerate(((0.03, 0.0), (0.012, 0.024))):
            c = Vector((ac.x + afuera * 0.01, ac.y, amax.z - am.z * 0.25 + sube))
            capas.append((c, Vector((am.x + crece, am.y + crece, am.z * 0.42 - k * 0.02))))

        def placas(bm, capas=capas):
            for c, mh in capas:
                C._cascara(bm, c, mh, 0.6, 28, 16, lambda p, c=c, mh=mh: p.z > c.z - mh.z * 0.15, 0.009)

        def oro(bm, capas=capas, afuera=afuera):
            for c, mh in capas:
                borde = c.z - mh.z * 0.15
                C._cascara(bm, c, mh + Vector((0.005, 0.005, 0.005)), 0.6, 28, 16,
                           lambda p, borde=borde: borde - 0.002 < p.z < borde + 0.014, 0.006)
            c, mh = capas[1]
            arbol = C._bvh(lambda b: T.bloque_redondo(b, c, mh + Vector((0.009, 0.009, 0.009)), 0.6, 28, 16))
            camino = []
            for k in range(13):
                a = math.radians(-70 + 140 * k / 12)
                p, _ = _sobre(arbol, c + Vector((afuera * mh.x * 0.25, 0, 0)), (0, math.sin(a), math.cos(a)), 0.002)
                if p:
                    camino.append(p)
            if len(camino) > 2:
                T.tubo(bm, camino, 0.006, 6)
            c0, mh0 = capas[0]
            arbol0 = C._bvh(lambda b: T.bloque_redondo(b, c0, mh0 + Vector((0.009, 0.009, 0.009)), 0.6, 28, 16))
            for k in range(5):
                a = math.radians(-60 + 30 * k)
                p, n = _sobre(arbol0, c0 + Vector((0, 0, 0.004)), (afuera * math.cos(a), math.sin(a), 0.35), 0.001)
                if p:
                    T.remache(bm, p, 0.0055, n)

        objs += T.pieza_separada(f"{NOMBRE}_Hombrera{lado}", hueso, [("blanco-armadura", placas), ("oro", oro)])
    return objs


def d_brazaletes():
    """Brazaletes (LowerArm) y guantes (Hand) de blanco-armadura con líneas de oro."""
    objs = []
    for lado, hueso in T._lados("LowerArm"):
        _, _, lc, lm = T.caja_parte(hueso)
        mano = hueso.replace("LowerArm", "Hand")
        _, hmax, hc, hm = T.caja_parte(mano)
        afuera = 1 if lc.x > 0 else -1

        def brazalete(bm, lc=lc, lm=lm, afuera=afuera):
            T.bloque_redondo(bm, lc + Vector((0, 0, -lm.z * 0.1)), Vector((lm.x + 0.02, lm.y + 0.02, lm.z * 0.85)), 0.4, 24, 12)
            # Placa de afuera, en capa sobre el brazalete.
            T.bloque_redondo(bm, Vector((lc.x + afuera * (lm.x + 0.022), lc.y, lc.z - lm.z * 0.1)),
                             Vector((0.012, lm.y * 0.75, lm.z * 0.65)), 0.45, 12, 10)

        def lineas(bm, lc=lc, lm=lm, afuera=afuera):
            for z in (lc.z + lm.z * 0.72, lc.z - lm.z * 0.9):
                T.bloque_redondo(bm, Vector((lc.x, lc.y, z)), Vector((lm.x + 0.03, lm.y + 0.03, 0.012)), 0.35, 24, 6)
            # Dos chevrones de oro en la placa de afuera.
            x = lc.x + afuera * (lm.x + 0.036)
            for k in range(2):
                z = lc.z + lm.z * (0.25 - 0.45 * k)
                T.tubo(bm, [Vector((x, lc.y - lm.y * 0.6, z + 0.035)), Vector((x, lc.y, z - 0.01)),
                            Vector((x, lc.y + lm.y * 0.6, z + 0.035))], 0.0045, 6)
            for k in range(4):
                T.remache(bm, Vector((lc.x + (k % 2 - 0.5) * lm.x, lc.y - lm.y - 0.022, lc.z + lm.z * (0.4 - 0.9 * (k // 2)))), 0.006)

        objs += T.pieza_separada(f"{NOMBRE}_Brazalete{lado}", hueso, [("blanco-armadura", brazalete), ("oro", lineas)])

        def guante(bm, hc=hc, hm=hm):
            T.bloque_redondo(bm, hc, hm + Vector((0.012, 0.012, 0.012)), 0.3, 20, 10)

        def guante_oro(bm, hc=hc, hm=hm, hmax=hmax, afuera=afuera):
            T.bloque_redondo(bm, Vector((hc.x, hc.y, hmax.z + 0.012)), Vector((hm.x + 0.024, hm.y + 0.024, 0.016)), 0.35, 20, 6)
            for k in range(4):  # nudillos
                y = hc.y - hm.y * 0.75 + k * hm.y * 0.5
                T.bloque_redondo(bm, Vector((hc.x + afuera * (hm.x + 0.014), y, hc.z - hm.z * 0.35)),
                                 Vector((0.007, hm.y * 0.2, hm.z * 0.4)), 0.4, 10, 6)

        objs += T.pieza_separada(f"{NOMBRE}_Guante{lado}", mano, [("blanco-armadura", guante), ("oro", guante_oro)])
    return objs


def d_grebas():
    """Grebas (LowerLeg) y botas (Foot) de blanco-armadura, rodilleras y anillos de oro, dos
    líneas liga en la canillera."""
    objs = []
    for lado, hueso in T._lados("LowerLeg"):
        pmin, pmax, pc, pm = T.caja_parte(hueso)
        _, _, fc, fm = T.caja_parte(hueso.replace("LowerLeg", "Foot"))
        alto = (pmax.z - pmin.z) * 0.86
        cc = Vector((pc.x, pc.y, pmin.z + alto * 0.55))  # canillera
        mc = Vector((pm.x + 0.034, pm.y + 0.034, alto * 0.42))

        def bota(bm, pc=pc, pm=pm, pmin=pmin, fc=fc, fm=fm, alto=alto, cc=cc, mc=mc):
            T.bloque_redondo(bm, fc + Vector((0, -0.025, 0.004)), fm + Vector((0.016, 0.04, 0.012)), 0.32, 16, 8)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.025, fc.z - fm.z - 0.004)), Vector((fm.x + 0.02, fm.y + 0.045, 0.008)), 0.3, 16, 4)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + alto / 2)), Vector((pm.x + 0.022, pm.y + 0.022, alto / 2)), 0.35, 16, 8)
            C._cascara(bm, cc, mc, 0.45, 20, 12, lambda p: p.y < cc.y - mc.y * 0.3, 0.008)

        def oro(bm, pc=pc, pm=pm, pmin=pmin, pmax=pmax, fc=fc, fm=fm, alto=alto):
            T.bloque_redondo(bm, Vector((pc.x, pc.y - pm.y - 0.032, pmax.z - 0.008)), Vector((pm.x * 0.62, 0.024, 0.046)), 0.5, 16, 10)
            T.bloque_redondo(bm, Vector((pc.x, pc.y - pm.y - 0.052, pmax.z - 0.008)), Vector((pm.x * 0.3, 0.008, 0.03)), 0.5, 12, 6)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + alto)), Vector((pm.x + 0.03, pm.y + 0.03, 0.013)), 0.35, 20, 4)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + 0.02)), Vector((pm.x + 0.028, pm.y + 0.028, 0.01)), 0.35, 20, 4)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - fm.y - 0.055, fc.z + 0.004)), Vector((fm.x * 0.8, 0.02, fm.z * 0.8)), 0.5, 14, 8)
            for k in range(4):
                T.remache(bm, Vector((pc.x + (k % 2 - 0.5) * pm.x * 1.25, pc.y - pm.y - 0.046, pmin.z + alto * (0.25 + 0.5 * (k // 2)))), 0.006)

        def liga(bm, pc=pc, pm=pm, pmin=pmin, alto=alto, cc=cc, mc=mc):
            arbol = C._bvh(lambda b: T.bloque_redondo(b, cc, mc, 0.45, 20, 12))
            for x in (-0.25, 0.25):
                camino = []
                for k in range(8):
                    z = pmin.z + alto * (0.3 + 0.5 * k / 7)
                    p, _ = _sobre(arbol, Vector((pc.x + x * pm.x, cc.y, z)), (0, -1, 0), 0.002)
                    if p:
                        camino.append(p)
                if len(camino) > 2:
                    T.tubo(bm, camino, 0.0045, 6)

        objs += T.pieza_separada(f"{NOMBRE}_Greba{lado}", hueso, [("blanco-armadura", bota), ("oro", oro), ("liga", liga)])
    return objs


def d_capa():
    """Capa corta de tela dorada hasta las rodillas, cortada en 3 tiras que se separan abajo,
    simulada (pliegues horneados). Broches de oro en los hombros."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, ac, am = T.caja_parte("LeftUpperArm")
    hombro_x = abs(ac.x) + am.x
    tela = T.capa(NOMBRE, "tela-dorada", ancho=hombro_x / tm.x * 0.92, vuelo=1.5, pliegues=5, hondo=0.028,
                  columnas=24, filas=32, cuadros=55, grosor=0.01, tiras=3, corte_desde=0.4,
                  choques_extra=[o for o in piezas_detalle() if o.name.startswith(f"{NOMBRE}_Peto")])
    atras = tmax.y + 0.03

    def broches(bm):
        T.bloque_redondo(bm, Vector((tc.x, atras + 0.01, tmax.z - 0.03)), Vector((hombro_x * 0.85, 0.014, 0.018)), 0.4, 28, 6)
        for lado in (-1, 1):
            c = Vector((tc.x + lado * hombro_x * 0.72, tc.y - tm.y * 0.2, tmax.z + 0.012))
            T.cilindro(bm, c - Vector((0, 0, 0.008)), c + Vector((0, 0, 0.01)), 0.035, 20)
            for k in range(8):
                a = 2 * math.pi * k / 8
                d = Vector((math.cos(a), math.sin(a), 0))
                _rayo(bm, c + d * 0.03 + Vector((0, 0, 0.004)), d, (0, 0, 1), 0.022, 0.016, 0.01, 3)

    return [tela] + T.pieza_separada(f"{NOMBRE}_Capa_Oro", "UpperTorso", [("oro", broches)])


PIEZAS = (("Casco", "Casco"), ("Corona", "Corona"), ("Peto", "Peto"), ("Peto", "Emblema"), ("Hombreras", "Hombrera"),
          ("Capa", "Capa"), ("Brazaletes", "Brazalete"), ("Brazaletes", "Guante"), ("Grebas", "Greba"))


def _pieza_de(nombre_obj):
    """Centinela_HombreraIzq_Oro -> Hombreras (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for clave, prefijo in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


def tabla_triangulos(objs):
    cuenta = B.contar_triangulos(objs)
    por_pieza = {}
    for nombre, n in cuenta.items():
        if nombre != "_total":
            por_pieza[_pieza_de(nombre)] = por_pieza.get(_pieza_de(nombre), 0) + n
    filas = ["| Pieza | Triángulos | Presupuesto | Mallas |", "|---|---|---|---|"]
    for clave, tope in PRESUPUESTO.items():
        mallas = ", ".join(sorted(n.replace(NOMBRE + "_", "") for n in cuenta if n != "_total" and _pieza_de(n) == clave))
        marca = "" if por_pieza.get(clave, 0) <= tope else " ⚠"
        filas.append(f"| {clave} | {C._miles(por_pieza.get(clave, 0))}{marca} | {C._miles(tope)} | {mallas} |")
    filas.append(f"| **Total** | **{C._miles(cuenta['_total'])}** | **{C._miles(sum(PRESUPUESTO.values()))}** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {C._miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, "centinela_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Centinela Solar: triángulos por pieza\n\n" + texto + "\n\n"
                "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
                "linajes/arte/blender/texturas/centinela/. Las de neón no llevan textura.\n")
    return texto


def pivote_corona():
    """La corona gira sobre su centro: el pivote de sus mallas va ahí."""
    centro, _ = centro_corona()
    bpy.context.scene.cursor.location = centro
    for o in piezas_detalle():
        if o.name.startswith(f"{NOMBRE}_Corona"):
            for x in bpy.context.view_layer.objects:
                x.select_set(x == o)
            bpy.context.view_layer.objects.active = o
            bpy.ops.object.origin_set(type="ORIGIN_CURSOR")


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_casco, d_corona, d_peto, d_hombreras, d_capa, d_brazaletes, d_grebas):
        armar()
    return piezas_detalle()


def _primeros_planos(piezas, prefijo):
    def de(*nombres):
        return [o for o in piezas if o.name.startswith(tuple(f"{NOMBRE}_{n}" for n in nombres))]

    B.render_primer_plano(f"{prefijo}_corona", de("Corona", "Casco") + [B.parte("Head")], giro=150, altura=12, margen=1.05)
    B.render_primer_plano(f"{prefijo}_emblema", de("Emblema"), giro=10, margen=1.9)
    B.render_primer_plano(f"{prefijo}_capa", de("Capa"), giro=160, altura=8, margen=1.05)


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas)["_total"])
    print("Render:", B.render_vistas("_centinela_prueba", B.partes() + piezas))
    _primeros_planos(piezas, "_centinela_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, "centinela")
    pivote_corona()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    print("Render:", B.render_vistas("centinela", B.partes() + piezas))
    _primeros_planos(piezas, "centinela")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in argumentos:
        boceto()
    if "detalle" in argumentos:
        detalle()
    if "prueba" in argumentos:
        prueba()
