"""Cuervo: traje sobre el maniquí R15 (ficha en la sección Modelos de GUIA-ESTILO.md).

Detective vigilante, tema cuervo (nada de murciélago). Silueta: hombros anchos por la capa de
plumas, cabeza con pico corto, capa hasta los tobillos que se abre en V.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/cuervo.py -- boceto

Paso "boceto": bloques sin detalle de las 8 piezas, render de 3 vistas (renders/cuervo_boceto_vistas.png).
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Cuervo"
BLEND = os.path.join(B.BLENDER, "cuervo.blend")
S = B.STUD  # 1 stud en metros

# Presupuesto de triángulos por pieza (ficha de Juani, total ≤ 36.000).
PRESUPUESTO = {
    "Capucha": 8000,
    "Capa": 8000,
    "Peto": 7000,  # Peto + PetoBajo
    "Hombreras": 3000,
    "Antebrazos": 3000,
    "Guantes": 2000,
    "Cinturon": 2000,
    "Botas": 3000,
    "Mangas": 2000,  # agregadas para marcar músculos (pedido de Juani)
    "Piernas": 2500,
}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


# Contorno de la pluma del emblema (alto 1, centrada; x a la derecha, z arriba). Lado derecho
# con dos muescas, lado izquierdo liso, punta arriba y cañón abajo.
PLUMA = [
    (0.0, -0.5),
    (0.03, -0.36),
    (0.15, -0.26),
    (0.2, -0.06),
    (0.11, -0.02),
    (0.19, 0.1),
    (0.16, 0.24),
    (0.08, 0.21),
    (0.1, 0.34),
    (0.0, 0.5),
    (-0.09, 0.37),
    (-0.16, 0.18),
    (-0.18, -0.06),
    (-0.13, -0.26),
    (-0.03, -0.36),
]


def _pluma_plana(bm, centro, alto, espesor, giro_grados=0.0, crece=0.0):
    """La pluma del emblema extruida hacia atrás (+Y) desde `centro` (que queda al frente).
    `crece` agranda el contorno (para el borde que asoma alrededor)."""
    import bmesh

    giro = _g(giro_grados, "Y")
    escala = alto * (1 + crece)
    frente, atras = [], []
    for x, z in PLUMA:
        p = giro @ Vector((x * escala, 0, z * escala))
        frente.append(bm.verts.new(centro + p))
        atras.append(bm.verts.new(centro + p + Vector((0, espesor, 0))))
    caras = [bm.faces.new(frente), bm.faces.new(list(reversed(atras)))]
    n = len(PLUMA)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((frente[j], frente[i], atras[i], atras[j]))
    bmesh.ops.triangulate(bm, faces=caras, quad_method="BEAUTY", ngon_method="EAR_CLIP")


# ---------------------------------------------------------------------------
# Logo del pecho: figuras planas (contornos de alto 1, x a la derecha, z arriba, en sentido
# antihorario) extruidas hacia atrás, con borde de neón que asoma alrededor.
# ---------------------------------------------------------------------------


def _ensanchar(puntos, d):
    """El contorno corrido `d` hacia afuera (borde parejo, también en las puntas hacia adentro)."""
    n = len(puntos)
    salida = []
    for i in range(n):
        a, p, b = Vector(puntos[i - 1]), Vector(puntos[i]), Vector(puntos[(i + 1) % n])
        e1, e2 = (p - a).normalized(), (b - p).normalized()
        n1, n2 = Vector((e1.y, -e1.x)), Vector((e2.y, -e2.x))
        bis = (n1 + n2).normalized() if (n1 + n2).length > 1e-6 else n1
        salida.append(tuple(p + bis * (d / max(0.35, bis.dot(n1)))))
    return salida


def _plana(bm, puntos, centro, alto, espesor, giro_grados=0.0, ensanche=0.0):
    """Figura plana extruida hacia atrás (+Y) desde `centro`. `ensanche` (en unidades del
    contorno) la agranda parejo para hacer bordes."""
    import bmesh

    if ensanche:
        puntos = _ensanchar(puntos, ensanche)
    giro = _g(giro_grados, "Y")
    frente, atras = [], []
    for x, z in puntos:
        p = giro @ Vector((x * alto, 0, z * alto))
        frente.append(bm.verts.new(centro + p))
        atras.append(bm.verts.new(centro + p + Vector((0, espesor, 0))))
    caras = [bm.faces.new(frente), bm.faces.new(list(reversed(atras)))]
    for i in range(len(puntos)):
        j = (i + 1) % len(puntos)
        bm.faces.new((frente[j], frente[i], atras[i], atras[j]))
    bmesh.ops.triangulate(bm, faces=caras, quad_method="BEAUTY", ngon_method="EAR_CLIP")


def _hoja(largo, ancho, muescas=(), curva=0.0, pasos=10):
    """Contorno de una pluma fina (base abajo en z=-largo/2, punta arriba), con muescas
    [(t, lado, hondo)] y curvada `curva` hacia la derecha."""
    der, izq = [], []
    for k in range(pasos + 1):
        t = k / pasos
        z = -largo / 2 + largo * t
        cx = curva * math.sin(math.pi * t)
        w = ancho / 2 * math.sin(math.pi * min(1.0, 0.15 + t * 0.95)) ** 0.7
        wd = wi = w
        for tm, lado, hondo in muescas:
            if abs(t - tm) < 0.5 / pasos:
                if lado > 0:
                    wd *= 1 - hondo
                else:
                    wi *= 1 - hondo
        der.append((cx + wd, z))
        izq.append((cx - wi, z))
    der[0] = izq[0] = (0.0, -largo / 2)
    return [der[0]] + der[1:-1] + [(0.0, largo / 2)] + list(reversed(izq[1:-1]))


# A: cabeza de cuervo de perfil, mirando a la izquierda, con plumas sueltas en la nuca.
CABEZA = [
    (-0.62, 0.04), (-0.3, -0.06), (-0.05, -0.2), (0.2, -0.32), (0.46, -0.4), (0.36, -0.17),
    (0.54, -0.1), (0.4, 0.05), (0.52, 0.18), (0.36, 0.32), (0.15, 0.44), (-0.08, 0.41),
    (-0.22, 0.25), (-0.36, 0.14),
]
OJO = [(-0.1, 0.17), (-0.02, 0.22), (0.06, 0.17), (-0.02, 0.12)]
PICO_LINEA = [(-0.58, 0.04), (-0.26, 0.03), (-0.26, 0.055), (-0.58, 0.05)]
# B: placa hexagonal alta.
HEXAGONO = [(0.0, 0.5), (-0.32, 0.3), (-0.32, -0.3), (0.0, -0.5), (0.32, -0.3), (0.32, 0.3)]


def logo_capas(variante, centro, alto):
    """Capas (material, función) del logo `variante` ("A", "B" o "C") centrado en `centro`."""
    if variante == "A":

        def relleno(bm):
            _plana(bm, CABEZA, centro, alto, 0.012)

        def neon(bm):
            _plana(bm, CABEZA, centro + Vector((0, 0.006, 0)), alto, 0.008, ensanche=0.035)
            _plana(bm, OJO, centro + Vector((0, -0.003, 0)), alto, 0.006)
            _plana(bm, PICO_LINEA, centro + Vector((0, -0.003, 0)), alto, 0.006)

        return [("vigilantes", relleno), ("neon-cian", neon)]

    if variante == "B":
        pluma = _hoja(0.78, 0.2, muescas=((0.35, 1, 0.55), (0.55, -1, 0.5), (0.72, 1, 0.45)), curva=0.05)

        def placa(bm):
            _plana(bm, HEXAGONO, centro + Vector((0, 0.004, 0)), alto, 0.012, ensanche=0.03)

        def relleno(bm):
            _plana(bm, HEXAGONO, centro, alto, 0.01)

        def neon(bm):
            _plana(bm, pluma, centro + Vector((0, -0.004, 0)), alto, 0.008, giro_grados=-12)

        return [("acero", placa), ("vigilantes", relleno), ("neon-cian", neon)]

    # C: tres plumas que se abren hacia arriba desde un punto, como una cresta.
    plumas = [(-28, 0.7), (0, 0.9), (28, 0.7)]

    def _tres(bm, desplaza, ensanche, espesor):
        for grados, largo in plumas:
            hoja = _hoja(largo, 0.2, muescas=((0.6, 1, 0.5), (0.45, -1, 0.4)))
            hoja = [(x, z + largo / 2 - 0.45) for x, z in hoja]  # la base de todas en el mismo punto
            _plana(bm, hoja, centro + desplaza, alto, espesor, giro_grados=grados, ensanche=ensanche)

    def relleno(bm):
        _tres(bm, Vector((0, 0, 0)), 0.0, 0.012)

    def neon(bm):
        _tres(bm, Vector((0, 0.006, 0)), 0.03, 0.008)

    return [("vigilantes", relleno), ("neon-cian", neon)]


def _pico(bm, base, largo, ancho, alto, caida, anillos=10):
    """Pico de cuervo: sale de `base` hacia adelante (-Y), se afina y la punta se curva hacia
    abajo. Arriba tiene lomo (cresta) y abajo es casi plano."""
    # Corte del pico: (x, z) en unidades de medio ancho / medio alto.
    corte = [(0.0, 1.0), (0.55, 0.6), (1.0, 0.0), (0.7, -0.6), (0.0, -0.75), (-0.7, -0.6), (-1.0, 0.0), (-0.55, 0.6)]
    aros = []
    for k in range(anillos):
        t = k / anillos
        c = Vector(base) + Vector((0, -largo * t, -caida * t**2.2))
        w = ancho / 2 * (1 - t) ** 0.85
        h = alto / 2 * (1 - t) ** 0.7
        aros.append([bm.verts.new(c + Vector((x * w, 0, z * h))) for x, z in corte])
    punta = bm.verts.new(Vector(base) + Vector((0, -largo, -caida)))
    n = len(corte)
    for a, b in zip(aros, aros[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    for i in range(n):
        bm.faces.new((aros[-1][i], aros[-1][(i + 1) % n], punta))
    bm.faces.new(list(reversed(aros[0])))


# ---------------------------------------------------------------------------
# Boceto de bloques
# ---------------------------------------------------------------------------


def capucha():
    _, hmax, hc, hm = T.caja_parte("Head")
    frente = hc.y - hm.y  # cara (mira a -Y)

    def tela(bm):
        # Capucha que cubre cabeza y frente, un poco puntiaguda atrás.
        T.bloque_redondo(bm, hc + Vector((0, 0.01, 0.015)), hm + Vector((0.03, 0.035, 0.035)), 0.5, 24, 14)

    def mascara(bm):
        # Placa sobre la parte de arriba de la cara y pico corto (0,4 studs) hacia adelante.
        y = frente - 0.035
        T.caja(bm, Vector((hc.x, y, hc.z + hm.z * 0.2)), Vector((hm.x * 1.7, 0.03, hm.z * 0.7)))
        # Pico de cuervo: 0,4 studs hacia adelante desde la máscara, con la punta curva.
        # La base nace entre los ojos y el lomo sigue subiendo por la frente.
        base_pico = Vector((hc.x, y + 0.012, hc.z + hm.z * 0.02))
        _pico(bm, base_pico, 0.4 * S + 0.025, hm.x * 0.62, hm.z * 0.62, 0.045)
        lomo = Vector((hc.x, y - 0.004, hc.z + hm.z * 0.42))
        T.caja(bm, lomo, Vector((0.022, 0.016, hm.z * 0.5)), _g(-8, "X"))

    def ojos(bm):
        for lado in (-1, 1):
            T.caja(
                bm,
                Vector((hc.x + lado * hm.x * 0.38, frente - 0.052, hc.z + hm.z * 0.22)),
                Vector((hm.x * 0.45, 0.008, 0.018)),
                _g(lado * -12, "Y"),
            )

    return T.pieza(f"{NOMBRE}_Capucha", "Head", [("tela-oscura", tela), ("acero", mascara), ("neon-cian", ojos)])


def capa():
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, bmax, _, _ = T.caja_parte("LeftFoot")
    _, amax, _, am = T.caja_parte("LeftUpperArm")
    hombro_x = abs(T.caja_parte("LeftUpperArm")[2].x) + am.x  # borde de afuera del hombro
    tobillo = bmax.z + 0.02
    largo = tmax.z - tobillo
    atras = tmax.y + 0.02
    azar = random.Random(7)

    def manto(bm):
        # Manto que cubre los hombros: da los hombros anchos.
        T.bloque_redondo(
            bm,
            Vector((tc.x, tc.y + 0.03, tmax.z - 0.06)),
            Vector((hombro_x + 0.06, tm.y + 0.07, 0.09)),
            0.45,
            24,
            10,
        )

    def plumas(bm):
        # 5 filas de plumas superpuestas; abajo más largas, más separadas y abiertas en V.
        for fila in range(5):
            arriba = tmax.z - 0.04 - fila * largo * 0.19
            largo_pluma = largo * (0.30 + 0.03 * fila)
            if fila == 4:
                largo_pluma = arriba - tobillo
            ancho_fila = (hombro_x + 0.04) * (1.0 + 0.09 * fila)
            n = 6 + fila
            ancho_pluma = ancho_fila * 2 / n * (1.3 - 0.08 * fila)
            for i in range(n):
                s = (i + 0.5) / n * 2 - 1
                x = tc.x + s * ancho_fila
                caida = largo_pluma * (1.0 + (azar.uniform(-0.1, 0.1) if fila >= 3 else 0))
                y = atras + 0.02 + fila * 0.02 + abs(s) * 0.04
                giro = _g(s * (3 + 1.5 * fila), "Y") @ _g(-3 - fila * 1.5, "X")
                T.caja(
                    bm,
                    Vector((x, y, arriba - caida / 2)),
                    Vector((ancho_pluma, 0.02, caida)),
                    giro,
                )

    return T.pieza(f"{NOMBRE}_Capa", "UpperTorso", [("tela-oscura", manto), ("acero", plumas)])


def peto():
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.025

    def placas(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.025, 0.025, 0.01)), 0.25, 24, 12)

    def bordes(bm):
        # Bordes de acero arriba y abajo del peto.
        for z in (tmax.z - 0.03, tc.z - tm.z + 0.03):
            T.caja(bm, Vector((tc.x, tc.y, z)), Vector((tm.x * 2 + 0.07, tm.y * 2 + 0.07, 0.025)))

    # Logo del pecho: pluma de cuervo de 0,9 studs, un poco inclinada, con borde de neón.
    alto_logo = 0.9 * S
    centro_logo = Vector((tc.x, frente - 0.016, tc.z + tm.z * 0.08))

    def emblema(bm):
        _pluma_plana(bm, centro_logo, alto_logo, 0.012, giro_grados=-18)

    def borde_emblema(bm):
        _pluma_plana(bm, centro_logo + Vector((0, 0.006, 0)), alto_logo, 0.008, giro_grados=-18, crece=0.14)

    def canon(bm):
        # Cañón de la pluma: una línea de neón que sube por el medio.
        giro = _g(-18, "Y")
        T.caja(bm, centro_logo + giro @ Vector((0, -0.003, -alto_logo * 0.05)), Vector((0.006, 0.006, alto_logo * 0.85)), giro)

    alto_ = T.pieza(
        f"{NOMBRE}_Peto",
        "UpperTorso",
        [("tela-oscura", placas), ("acero", bordes), ("vigilantes", emblema), ("neon-cian", borde_emblema), ("neon-cian", canon)],
    )
    _, _, lc, lm = T.caja_parte("LowerTorso")

    def bajo(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.02, 0.02, 0.0)), 0.25, 24, 8)

    bajo_ = T.pieza(f"{NOMBRE}_PetoBajo", "LowerTorso", [("tela-oscura", bajo)])
    return [alto_, bajo_]


def hombreras():
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        _, amax, ac, am = T.caja_parte(hueso)
        afuera = 1 if ac.x > 0 else -1

        def abanico(bm, ac=ac, amax=amax, am=am, afuera=afuera):
            # Tres plumas que salen del hombro hacia afuera y abajo, abiertas en abanico.
            for k, (y, inclinacion) in enumerate(((-0.05, 8), (0.0, 22), (0.05, 36))):
                largo = 0.25 - k * 0.02
                raiz = Vector((ac.x, ac.y + y, amax.z + 0.1 - k * 0.012))
                giro = _g(afuera * inclinacion, "Y")
                centro = raiz + giro @ Vector((afuera * largo / 2, 0, 0))
                T.caja(bm, centro, Vector((largo, 0.07, 0.025)), giro)

        piezas.append(T.pieza(f"{NOMBRE}_Hombrera{lado}", hueso, [("acero", abanico)]))
    return piezas


def antebrazos():
    piezas = []
    for lado, hueso in T._lados("LowerArm"):
        _, lmax, lc, lm = T.caja_parte(hueso)
        afuera = 1 if lc.x > 0 else -1

        def brazalete(bm, lc=lc, lm=lm):
            T.bloque_redondo(bm, lc, lm + Vector((0.02, 0.02, -0.02)), 0.4, 20, 10)

        def puas(bm, lc=lc, lm=lm):
            for k in range(3):
                base = Vector((lc.x, lc.y + lm.y + 0.015, lc.z + lm.z * 0.5 - k * lm.z * 0.5))
                T.punta(bm, base, base + Vector((0, 0.07, 0.02)), 0.025, 4)

        capas = [("acero", brazalete), ("acero", puas)]
        if lado == "Der":

            def gancho(bm, lc=lc, lm=lm, afuera=afuera):
                x = lc.x + afuera * (lm.x + 0.04)
                arriba, abajo = lc.z + lm.z * 0.8, lc.z - lm.z * 1.1
                T.caja(bm, Vector((x, lc.y, (arriba + abajo) / 2)), Vector((0.06, 0.06, arriba - abajo)))
                for k in range(3):
                    a = math.radians(k * 120)
                    base = Vector((x, lc.y, abajo))
                    T.punta(bm, base, base + Vector((math.cos(a) * 0.035, math.sin(a) * 0.035, -0.06)), 0.012, 4)

            capas.append(("acero", gancho))
        piezas.append(T.pieza(f"{NOMBRE}_Antebrazo{lado}", hueso, capas))
    return piezas


def guantes():
    piezas = []
    for lado, hueso in T._lados("Hand"):
        _, _, hc, hm = T.caja_parte(hueso)

        def guante(bm, hc=hc, hm=hm):
            T.bloque_redondo(bm, hc, hm + Vector((0.012, 0.012, 0.012)), 0.3, 16, 8)

        def nudillos(bm, hc=hc, hm=hm):
            T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.015, hc.z - hm.z * 0.2)), Vector((hm.x * 1.6, 0.02, hm.z * 0.9)))

        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso, [("cuero", guante), ("acero", nudillos)]))
    return piezas


def cinturon():
    _, lmax, lc, lm = T.caja_parte("LowerTorso")
    z = lc.z + lm.z * 0.3

    def cinto(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, z)), Vector((lm.x + 0.035, lm.y + 0.035, 0.03)), 0.3, 24, 6)

    def bolsillos(bm):
        for s in (-0.8, -0.5, -0.25, 0.25, 0.5, 0.8):
            T.caja(bm, Vector((lc.x + s * lm.x, lc.y - lm.y - 0.05, z - 0.005)), Vector((0.05, 0.035, 0.055)))

    def hebilla(bm):
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.05, z)), Vector((0.035, 0.012, 0.06)), _g(45, "Y") @ Matrix.Diagonal((0.6, 1, 0.6)))

    return T.pieza(
        f"{NOMBRE}_Cinturon", "LowerTorso", [("cuero", cinto), ("acero", bolsillos), ("vigilantes", hebilla)]
    )


def botas():
    piezas = []
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)
        pmin, pmax, pc, pm = T.caja_parte(hueso.replace("Foot", "LowerLeg"))
        alto = (pmax.z - pmin.z) * 0.8

        def bota(bm, fc=fc, fm=fm, pc=pc, pm=pm, pmin=pmin, alto=alto):
            T.bloque_redondo(bm, fc + Vector((0, -0.02, 0)), fm + Vector((0.015, 0.035, 0.015)), 0.3, 16, 8)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + alto / 2)), Vector((pm.x + 0.02, pm.y + 0.02, alto / 2)), 0.35, 16, 8)

        def canillera(bm, pc=pc, pm=pm, pmin=pmin, alto=alto):
            T.caja(bm, Vector((pc.x, pc.y - pm.y - 0.035, pmin.z + alto * 0.55)), Vector((pm.x * 1.3, 0.02, alto * 0.7)))

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("cuero", bota), ("acero", canillera)]))
    return piezas


def boceto():
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    piezas = [capucha(), capa(), *peto(), *hombreras(), *antebrazos(), *guantes(), cinturon(), *botas()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas("cuervo_boceto", B.partes() + piezas))
    cara = [bpy.data.objects[f"{NOMBRE}_Capucha"], bpy.data.objects[f"{NOMBRE}_Peto"]]
    print("Primer plano:", B.render_primer_plano("cuervo_boceto_cara_y_logo", cara))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2). Cada pieza es una malla por material: <Pieza>, <Pieza>_Acero,
# <Pieza>_Neon, <Pieza>_Emblema (en Roblox cada una es un MeshPart con su material).
# ---------------------------------------------------------------------------


def _marco(raiz, abajo, afuera):
    """Matriz que lleva el espacio de una pluma (crece hacia -Z, cara de afuera hacia -Y) al
    mundo: `abajo` es hacia dónde crece y `afuera` hacia dónde mira su cara."""
    z = -Vector(abajo).normalized()
    n = Vector(afuera)
    n = (n - z * n.dot(z)).normalized()
    y = -n
    x = y.cross(z)
    m = Matrix((x, y, z)).transposed().to_4x4()
    m.translation = Vector(raiz)
    return m


def _pluma_3d(bm, raiz, abajo, afuera, largo, ancho, grosor=0.008, curva=0.0, segmentos=7, punta=1.0):
    """Pluma metálica: hoja que se afina hacia la punta, con nervio en el medio y curvada
    hacia afuera (`curva`, en metros). `punta` < 1 la deja cortada (pluma rota)."""
    m = _marco(raiz, abajo, afuera)
    aros = []
    for k in range(segmentos + 1):
        t = k / segmentos * punta
        w = ancho / 2 * (0.6 + 0.4 * math.sin(math.pi * min(t * 1.4, 1.0))) * max(0.0, 1 - t**3) ** 0.5
        w = max(w, ancho * 0.04)
        y = -curva * t * t
        z = -largo * t
        nervio = grosor * 1.6
        corte = [(-w, y), (0, y - nervio), (w, y), (w * 0.8, y + grosor), (-w * 0.8, y + grosor)]
        aros.append([bm.verts.new(m @ Vector((cx, cy, z))) for cx, cy in corte])
    n = 5
    for a, b in zip(aros, aros[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(list(reversed(aros[0])))
    bm.faces.new(aros[-1])


def _cascara(bm, centro, mitades, redondez, seg, anillos, quedarse, grosor):
    """Superelipsoide del que se quedan solo las caras que cumplen `quedarse(centro_cara)`, con
    espesor hacia afuera: cascos, máscaras, placas curvas."""
    import bmesh

    tmp = bmesh.new()
    T.bloque_redondo(tmp, centro, mitades, redondez, seg, anillos)
    sacar = [f for f in tmp.faces if not quedarse(f.calc_center_median())]
    bmesh.ops.delete(tmp, geom=sacar, context="FACES")
    bmesh.ops.recalc_face_normals(tmp, faces=tmp.faces)
    if grosor > 0:
        bmesh.ops.solidify(tmp, geom=tmp.faces[:], thickness=-grosor)
    me = bpy.data.meshes.new("_tmp")
    tmp.to_mesh(me)
    tmp.free()
    bm.from_mesh(me)
    bpy.data.meshes.remove(me)


def _bvh(bm_armar):
    """BVH (para tirar rayos) de la geometría que arma `bm_armar(bm)`."""
    import bmesh
    from mathutils.bvhtree import BVHTree

    tmp = bmesh.new()
    bm_armar(tmp)
    arbol = BVHTree.FromBMesh(tmp)
    tmp.free()
    return arbol


def d_capucha():
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.03, 0.035, 0.035))
    c = hc + Vector((0, 0.01, 0.015))
    frente = c.y - m.y
    mascara_abajo = hc.z - hm.z * 0.2
    mascara_arriba = hc.z + hm.z * 0.55

    def es_cara(p):
        # Hueco de la cara: solo la parte de abajo (la de arriba la tapa la máscara).
        return p.y < c.y - m.y * 0.5 and hc.z - hm.z * 0.8 < p.z < mascara_abajo + 0.01 and abs(p.x - hc.x) < m.x * 0.62

    def capucha_tela(bm):
        _cascara(bm, c, m, 0.62, 40, 26, lambda p: not es_cara(p), 0.012)
        # Cuello de la capucha: una banda de tela que baja y se apoya en los hombros.
        cuello = Vector((hc.x, hc.y + 0.008, hc.z - hm.z - 0.012))
        mc = Vector((m.x * 1.08, m.y * 1.12, 0.05))
        _cascara(bm, cuello, mc, 0.55, 40, 12, lambda p: abs(p.z - cuello.z) < mc.z * 0.75, 0.01)

    arbol = _bvh(lambda bm: T.bloque_redondo(bm, c, m, 0.62, 40, 26))

    def costuras(bm):
        # Tres costuras de adelante hacia atrás por arriba de la cabeza, y una alrededor de la cara.
        for x in (-m.x * 0.55, 0.0, m.x * 0.55):
            camino = []
            for k in range(25):
                a = math.radians(-60 + 230 * k / 24)  # desde la frente, por arriba, hasta la nuca
                d = Vector((0, -math.cos(a), math.sin(a)))
                p, _ = T.sobre_superficie(arbol, c + Vector((x, 0, 0)) + d, -d, 0.002)
                if p and p.z > mascara_arriba - 0.02 or (p and p.y > c.y):
                    camino.append(p)
            if len(camino) > 2:
                T.tubo(bm, camino, 0.0045, 5)

    def mascara(bm):
        mm = m + Vector((0.012, 0.012, 0.012))
        _cascara(
            bm,
            c,
            mm,
            0.5,
            40,
            26,
            lambda p: p.y < c.y - mm.y * 0.4 and mascara_abajo < p.z < mascara_arriba and abs(p.x - c.x) < mm.x * 0.85,
            0.01,
        )
        # Labio levantado en el borde de abajo de la máscara (placa en capas, con grosor).
        ml = mm + Vector((0.006, 0.006, 0.006))
        _cascara(
            bm,
            c,
            ml,
            0.5,
            40,
            26,
            lambda p: p.y < c.y - ml.y * 0.4 and mascara_abajo - 0.004 < p.z < mascara_abajo + 0.012 and abs(p.x - c.x) < ml.x * 0.85,
            0.006,
        )
        # Pico: nace entre los ojos, 0,4 studs hacia adelante, punta curva; cresta por la frente.
        y = frente - 0.022
        _pico(bm, Vector((hc.x, y + 0.012, hc.z + hm.z * 0.02)), 0.4 * S + 0.025, hm.x * 0.62, hm.z * 0.62, 0.045, 14)
        cresta = [Vector((hc.x, frente - 0.02 + 0.004 * k, hc.z + hm.z * (0.1 + 0.11 * k))) for k in range(5)]
        T.tubo(bm, cresta, [0.012, 0.011, 0.009, 0.007, 0.004], 6)

    def ojos(bm):
        for lado in (-1, 1):
            x = hc.x + lado * hm.x * 0.4
            z = hc.z + hm.z * 0.22
            camino = [Vector((x - lado * hm.x * 0.22, frente - 0.04, z - 0.012)), Vector((x + lado * hm.x * 0.22, frente - 0.036, z + 0.01))]
            T.tubo(bm, camino, [0.007, 0.004], 6)

    return T.pieza_separada(
        f"{NOMBRE}_Capucha",
        "Head",
        [("tela-oscura", capucha_tela), ("tela-oscura", costuras), ("acero", mascara), ("neon-cian", ojos)],
    )


def d_capa():
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, bmax, _, _ = T.caja_parte("LeftFoot")
    _, _, ac, am = T.caja_parte("LeftUpperArm")
    hombro_x = abs(ac.x) + am.x
    tobillo = bmax.z + 0.02
    largo = tmax.z - tobillo
    azar = random.Random(7)

    # Tela de la capa: simulada (pliegues horneados), hasta los tobillos y abierta en V.
    tela = T.capa(NOMBRE, "tela-oscura", largo=largo - 0.02, ancho=hombro_x / tm.x * 1.05, vuelo=1.4,
                  pliegues=6, hondo=0.03, columnas=18, filas=28, cuadros=50, grosor=0.01)
    import bmesh

    tela_bm = bmesh.new()
    tela_bm.from_mesh(tela.data)
    tela_bm.transform(tela.matrix_world)
    from mathutils.bvhtree import BVHTree

    arbol = BVHTree.FromBMesh(tela_bm)
    tela_mundo = bpy.data.meshes.new("_tela")
    tela_bm.to_mesh(tela_mundo)
    tela_bm.free()
    bpy.data.objects.remove(tela)

    def tela_y_manto(bm):
        bm.from_mesh(tela_mundo)
        # Manto sobre los hombros: da la silueta ancha.
        T.bloque_redondo(bm, Vector((tc.x, tc.y + 0.03, tmax.z - 0.06)), Vector((hombro_x + 0.06, tm.y + 0.07, 0.09)), 0.45, 32, 12)

    def plumas(bm):
        # 5 filas de plumas de acero encima de la tela. Abajo más largas, más separadas y sueltas.
        for fila in range(5):
            arriba = tmax.z - 0.06 - fila * largo * 0.185
            largo_pluma = largo * (0.3 + 0.035 * fila)
            if fila == 4:
                largo_pluma = arriba - tobillo + 0.01
            ancho_fila = (hombro_x + 0.03) * (1.0 + 0.1 * fila)
            n = 7 + fila
            for i in range(n):
                s = (i + 0.5) / n * 2 - 1
                x = tc.x + s * ancho_fila + azar.uniform(-0.01, 0.01)
                p, normal = T.sobre_superficie(arbol, Vector((x, tc.y + 1.0, arriba)), (0, -1, 0), 0.006 + fila * 0.004)
                if p is None:
                    continue
                suelta = fila >= 3
                caida = largo_pluma * (1 + (azar.uniform(-0.12, 0.1) if suelta else azar.uniform(-0.03, 0.03)))
                abajo = _g(s * (4 + 2 * fila) + (azar.uniform(-5, 5) if suelta else 0), "Y") @ Vector((0, 0.12, -1))
                ancho = ancho_fila * 2 / n * (1.45 - 0.07 * fila)
                _pluma_3d(bm, p, abajo, normal, caida, ancho, 0.006, curva=0.02 + 0.01 * fila,
                          punta=azar.uniform(0.88, 1.0) if suelta else 1.0)

    objs = T.pieza_separada(f"{NOMBRE}_Capa", "UpperTorso", [("tela-oscura", tela_y_manto), ("acero", plumas)])
    bpy.data.meshes.remove(tela_mundo)
    return objs


def d_peto():
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    sup = tc.y - tm.y - 0.02  # frente del peto base
    alto_logo = 0.9 * S
    # El logo va sobre los músculos, entre los pectorales y los abdominales.
    centro_logo = Vector((tc.x, sup - 0.06, tc.z + tm.z * 0.12))

    # Músculos marcados en el traje: (centro x, centro z, medio ancho, medio hondo, medio alto).
    pectorales = [(lado * tm.x * 0.47, tc.z + tm.z * 0.47, tm.x * 0.47, 0.04, tm.z * 0.3) for lado in (-1, 1)]
    abdominales = [
        (lado * tm.x * 0.21, tc.z - tm.z * (0.08 + 0.27 * fila), tm.x * 0.19, 0.026 - 0.003 * fila, tm.z * 0.125)
        for fila in range(3)
        for lado in (-1, 1)
    ]
    oblicuos = [(lado * tm.x * 0.78, tc.z - tm.z * 0.35, tm.x * 0.2, 0.02, tm.z * 0.38) for lado in (-1, 1)]

    def base(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.02, 0.02, 0.008)), 0.25, 24, 12)
        for x, z, w, y, h in pectorales:
            T.bloque_redondo(bm, Vector((tc.x + x, sup - 0.012, z)), Vector((w, y, h)), 0.62, 20, 12)
        for x, z, w, y, h in abdominales:
            T.bloque_redondo(bm, Vector((tc.x + x, sup - 0.004, z)), Vector((w, y, h)), 0.55, 12, 8)
        for x, z, w, y, h in oblicuos:
            T.bloque_redondo(bm, Vector((tc.x + x, sup + 0.004, z)), Vector((w, y, h)), 0.6, 12, 8)
        # Espalda: dorsales anchos (los tapa la capa casi siempre).
        for lado in (-1, 1):
            T.bloque_redondo(bm, Vector((tc.x + lado * tm.x * 0.45, tc.y + tm.y + 0.015, tc.z + tm.z * 0.2)),
                             Vector((tm.x * 0.45, 0.025, tm.z * 0.55)), 0.6, 12, 8)

    def bordes(bm):
        # Placa de acero bajo cada pectoral (asoma como borde), franja del esternón, cuello y ribetes.
        for x, z, w, y, h in pectorales:
            T.bloque_redondo(bm, Vector((tc.x + x * 1.02, sup - 0.002, z + 0.004)), Vector((w + 0.012, 0.03, h + 0.012)), 0.45, 16, 8)
        T.bloque_redondo(bm, Vector((tc.x, sup - 0.018, tc.z - tm.z * 0.3)), Vector((0.012, 0.02, tm.z * 0.42)), 0.4, 8, 6)
        T.bloque_redondo(bm, Vector((tc.x, tc.y - tm.y * 0.15, tmax.z + 0.005)), Vector((tm.x * 0.4, tm.y * 0.95, 0.03)), 0.45, 20, 6)
        for z in (tmax.z - 0.025, tc.z - tm.z + 0.02):
            T.bloque_redondo(bm, Vector((tc.x, tc.y, z)), Vector((tm.x + 0.03, tm.y + 0.03, 0.012)), 0.3, 24, 4)

    arriba = T.pieza_separada(
        f"{NOMBRE}_Peto",
        "UpperTorso",
        [("tela-oscura", base), ("acero", bordes)],
    )
    _, _, lc, lm = T.caja_parte("LowerTorso")

    def bajo(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.02, 0.02, 0.0)), 0.25, 32, 8)

    def ribete(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z - lm.z + 0.01)), Vector((lm.x + 0.028, lm.y + 0.028, 0.01)), 0.3, 32, 6)

    abajo = T.pieza_separada(f"{NOMBRE}_PetoBajo", "LowerTorso", [("tela-oscura", bajo), ("acero", ribete)])
    return arriba + abajo + d_logo(LOGO)


LOGO = "A"  # el que eligió Juani (opciones: A, B, C; ver `opciones_logo`)


def _lugar_logo():
    _, _, tc, tm = T.caja_parte("UpperTorso")
    sup = tc.y - tm.y - 0.02
    return Vector((tc.x, sup - 0.06, tc.z + tm.z * 0.12)), 0.9 * S


def d_logo(variante):
    """Logo del pecho: pieza aparte (Cuervo_Logo, _Neon, _Acero) pegada a UpperTorso."""
    for o in [o for o in bpy.data.objects if o.name.startswith(f"{NOMBRE}_Logo")]:
        bpy.data.objects.remove(o)
    centro, alto = _lugar_logo()
    return T.pieza_separada(f"{NOMBRE}_Logo", "UpperTorso", logo_capas(variante, centro, alto))


def opciones_logo():
    """Renderiza las 3 opciones de logo sobre el pecho (renders/cuervo_logo_<A|B|C>.png)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    for viejo in ("Peto_Emblema", "Peto_Neon"):
        o = bpy.data.objects.get(f"{NOMBRE}_{viejo}")
        if o:
            bpy.data.objects.remove(o)
    torso = [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith((f"{NOMBRE}_Peto", f"{NOMBRE}_Cinturon"))]
    for v in "ABC":
        logo = d_logo(v)
        print(v, B.contar_triangulos(logo)["_total"], B.render_primer_plano(f"cuervo_logo_{v}", torso + logo, giro=12, altura=4, margen=0.75))


def d_hombreras():
    objs = []
    for lado, hueso in T._lados("UpperArm"):
        _, amax, ac, am = T.caja_parte(hueso)
        afuera = 1 if ac.x > 0 else -1

        def abanico(bm, ac=ac, amax=amax, am=am, afuera=afuera):
            # Hombrera curva: dos placas en capas (la de arriba más chica), con grosor.
            for k, (crece, sube) in enumerate(((0.03, 0.0), (0.012, 0.022))):
                c = Vector((ac.x + afuera * 0.01, ac.y, amax.z - am.z * 0.25 + sube))
                mh = Vector((am.x + crece, am.y + crece, am.z * 0.42 - k * 0.02))
                _cascara(bm, c, mh, 0.6, 24, 14, lambda p, c=c, mh=mh: p.z > c.z - mh.z * 0.15, 0.009)
            # Tres plumas en abanico, abiertas hacia afuera y arriba, con la cara mirando al
            # frente: así se leen de frente y de espalda (hombros anchos de cuervo).
            for k, (y, angulo) in enumerate(((-0.03, 38), (0.0, 16), (0.03, -6))):
                largo = 0.27 - k * 0.025
                raiz = Vector((ac.x - afuera * am.x * 0.2, ac.y + y, amax.z + 0.08))
                a = math.radians(angulo)
                abajo = Vector((afuera * math.cos(a), 0, math.sin(a)))
                _pluma_3d(bm, raiz, abajo, (0, -1, 0), largo, 0.09, 0.008, curva=0.02, segmentos=8)

        objs.append(T.pieza(f"{NOMBRE}_Hombrera{lado}", hueso, [("acero", abanico)]))
    return objs


def d_mangas():
    """Mangas del traje sobre UpperArm, con deltoides, bíceps y tríceps marcados."""
    objs = []
    for lado, hueso in T._lados("UpperArm"):
        _, amax, ac, am = T.caja_parte(hueso)
        afuera = 1 if ac.x > 0 else -1

        def manga(bm, ac=ac, amax=amax, am=am, afuera=afuera):
            T.bloque_redondo(bm, ac, am + Vector((0.012, 0.012, 0.004)), 0.4, 16, 10)
            # Deltoides arriba y afuera, bíceps adelante, tríceps atrás.
            T.bloque_redondo(bm, Vector((ac.x + afuera * am.x * 0.3, ac.y, amax.z - am.z * 0.32)),
                             Vector((am.x * 0.78, am.y * 0.98, am.z * 0.38)), 0.65, 16, 10)
            T.bloque_redondo(bm, Vector((ac.x, ac.y - am.y * 0.55, ac.z - am.z * 0.2)),
                             Vector((am.x * 0.62, am.y * 0.55, am.z * 0.42)), 0.65, 14, 8)
            T.bloque_redondo(bm, Vector((ac.x, ac.y + am.y * 0.5, ac.z - am.z * 0.1)),
                             Vector((am.x * 0.6, am.y * 0.5, am.z * 0.45)), 0.65, 12, 8)

        objs.append(T.pieza(f"{NOMBRE}_Manga{lado}", hueso, [("tela-oscura", manga)]))
    return objs


def d_piernas():
    """Pantalón del traje sobre UpperLeg con cuádriceps marcados; funda de acero en el muslo
    derecho (correa de cuero)."""
    objs = []
    for lado, hueso in T._lados("UpperLeg"):
        lmin, lmax, lc, lm = T.caja_parte(hueso)
        afuera = 1 if lc.x > 0 else -1

        def pierna(bm, lc=lc, lm=lm, afuera=afuera):
            T.bloque_redondo(bm, lc, lm + Vector((0.012, 0.012, 0.004)), 0.35, 16, 10)
            # Cuádriceps: dos bultos adelante; isquios atrás.
            T.bloque_redondo(bm, Vector((lc.x + afuera * lm.x * 0.3, lc.y - lm.y * 0.5, lc.z + lm.z * 0.05)),
                             Vector((lm.x * 0.5, lm.y * 0.55, lm.z * 0.62)), 0.65, 14, 10)
            T.bloque_redondo(bm, Vector((lc.x - afuera * lm.x * 0.3, lc.y - lm.y * 0.5, lc.z - lm.z * 0.3)),
                             Vector((lm.x * 0.45, lm.y * 0.5, lm.z * 0.45)), 0.65, 14, 8)
            T.bloque_redondo(bm, Vector((lc.x, lc.y + lm.y * 0.5, lc.z)), Vector((lm.x * 0.8, lm.y * 0.5, lm.z * 0.6)), 0.6, 12, 8)

        capas = [("tela-oscura", pierna)]
        if lado == "Der":

            def correas(bm, lc=lc, lm=lm):
                for z in (lc.z + lm.z * 0.35, lc.z - lm.z * 0.05):
                    T.bloque_redondo(bm, Vector((lc.x, lc.y, z)), Vector((lm.x + 0.03, lm.y + 0.03, 0.012)), 0.4, 20, 4)

            def funda(bm, lc=lc, lm=lm, afuera=afuera):
                x = lc.x + afuera * (lm.x + 0.035)
                T.bloque_redondo(bm, Vector((x, lc.y - lm.y * 0.15, lc.z + lm.z * 0.15)), Vector((0.025, lm.y * 0.55, lm.z * 0.42)), 0.35, 12, 8)
                T.bloque_redondo(bm, Vector((x + afuera * 0.004, lc.y - lm.y * 0.15, lc.z + lm.z * 0.5)), Vector((0.028, lm.y * 0.58, 0.012)), 0.4, 12, 4)

            capas += [("cuero", correas), ("acero", funda)]
        objs += T.pieza_separada(f"{NOMBRE}_Pierna{lado}", hueso, capas)
    return objs


def d_antebrazos():
    objs = []
    for lado, hueso in T._lados("LowerArm"):
        _, lmax, lc, lm = T.caja_parte(hueso)
        afuera = 1 if lc.x > 0 else -1

        def brazalete(bm, lc=lc, lm=lm):
            T.bloque_redondo(bm, lc + Vector((0, 0, -lm.z * 0.1)), Vector((lm.x + 0.02, lm.y + 0.02, lm.z * 0.85)), 0.4, 24, 12)
            for z in (lc.z + lm.z * 0.72, lc.z - lm.z * 0.9):
                T.bloque_redondo(bm, Vector((lc.x, lc.y, z)), Vector((lm.x + 0.03, lm.y + 0.03, 0.012)), 0.35, 24, 6)
            for k in range(4):
                T.remache(bm, Vector((lc.x + (k % 2 - 0.5) * lm.x, lc.y - lm.y - 0.022, lc.z + lm.z * (0.4 - 0.9 * (k // 2)))), 0.006)
            # Tres púas cortas hacia atrás.
            for k in range(3):
                base = Vector((lc.x, lc.y + lm.y + 0.015, lc.z + lm.z * 0.45 - k * lm.z * 0.5))
                T.punta(bm, base, base + Vector((0, 0.075, 0.025)), 0.02, 6)

        capas = [("acero", brazalete)]
        if lado == "Der":

            def gancho(bm, lc=lc, lm=lm, afuera=afuera):
                # Lanzador de gancho: cilindro por fuera del antebrazo con 3 garras en la punta.
                x = lc.x + afuera * (lm.x + 0.045)
                arriba, abajo = lc.z + lm.z * 0.75, lc.z - lm.z * 1.05
                T.cilindro(bm, (x, lc.y, abajo), (x, lc.y, arriba), 0.032, 16)
                for z in (arriba - 0.02, (arriba + abajo) / 2, abajo + 0.015):
                    T.cilindro(bm, (x, lc.y, z - 0.008), (x, lc.y, z + 0.008), 0.038, 16)
                T.cilindro(bm, (x, lc.y, abajo), (x, lc.y, abajo - 0.025), 0.02, 12, 0.024)
                # Soportes que lo unen al brazalete.
                for z in (arriba - 0.04, abajo + 0.04):
                    T.caja(bm, Vector((x - afuera * 0.03, lc.y, z)), Vector((0.035, 0.03, 0.02)))
                centro = Vector((x, lc.y, abajo - 0.025))
                for k in range(3):
                    a = math.radians(k * 120 + 90)
                    d = Vector((math.cos(a), math.sin(a), 0))
                    camino = [centro + d * 0.012, centro + d * 0.035 + Vector((0, 0, -0.025)),
                              centro + d * 0.04 + Vector((0, 0, -0.055)), centro + d * 0.02 + Vector((0, 0, -0.075))]
                    T.tubo(bm, camino, [0.009, 0.008, 0.006, 0.002], 6)

            capas.append(("acero", gancho))
        objs.append(T.pieza(f"{NOMBRE}_Antebrazo{lado}", hueso, capas))
    return objs


def d_guantes():
    objs = []
    for lado, hueso in T._lados("Hand"):
        _, hmax, hc, hm = T.caja_parte(hueso)
        afuera = 1 if hc.x > 0 else -1

        def guante(bm, hc=hc, hm=hm, hmax=hmax):
            T.bloque_redondo(bm, hc, hm + Vector((0.012, 0.012, 0.012)), 0.3, 20, 10)
            T.bloque_redondo(bm, Vector((hc.x, hc.y, hmax.z + 0.012)), Vector((hm.x + 0.022, hm.y + 0.022, 0.018)), 0.35, 20, 6)

        def nudillos(bm, hc=hc, hm=hm, afuera=afuera):
            # Cuatro placas en el dorso (el lado de afuera), abajo.
            for k in range(4):
                y = hc.y - hm.y * 0.75 + k * hm.y * 0.5
                T.bloque_redondo(bm, Vector((hc.x + afuera * (hm.x + 0.016), y, hc.z - hm.z * 0.35)),
                                 Vector((0.008, hm.y * 0.2, hm.z * 0.45)), 0.4, 10, 6)

        objs += T.pieza_separada(f"{NOMBRE}_Guante{lado}", hueso, [("cuero", guante), ("acero", nudillos)])
    return objs


def d_cinturon():
    _, lmax, lc, lm = T.caja_parte("LowerTorso")
    z = lc.z + lm.z * 0.3
    frente = lc.y - lm.y - 0.035

    def cinto(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, z)), Vector((lm.x + 0.035, lm.y + 0.035, 0.032)), 0.3, 32, 8)

    def bolsillos(bm):
        for s in (-0.85, -0.55, -0.27, 0.27, 0.55, 0.85):
            x = lc.x + s * lm.x
            T.bloque_redondo(bm, Vector((x, frente - 0.016, z - 0.008)), Vector((0.026, 0.017, 0.03)), 0.3, 10, 7)
            T.bloque_redondo(bm, Vector((x, frente - 0.02, z + 0.02)), Vector((0.029, 0.019, 0.008)), 0.4, 10, 4)
        # Hebilla: marco de acero.
        T.bloque_redondo(bm, Vector((lc.x, frente - 0.012, z)), Vector((0.032, 0.008, 0.042)), 0.35, 12, 8)

    def hebilla(bm):
        _pluma_plana(bm, Vector((lc.x, frente - 0.024, z)), 0.075, 0.006, giro_grados=-18)

    return T.pieza_separada(f"{NOMBRE}_Cinturon", "LowerTorso", [("cuero", cinto), ("acero", bolsillos), ("vigilantes", hebilla)])


def d_botas():
    objs = []
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)
        pmin, pmax, pc, pm = T.caja_parte(hueso.replace("Foot", "LowerLeg"))
        alto = (pmax.z - pmin.z) * 0.82

        def bota(bm, fc=fc, fm=fm, pc=pc, pm=pm, pmin=pmin, alto=alto):
            T.bloque_redondo(bm, fc + Vector((0, -0.025, 0.004)), fm + Vector((0.016, 0.04, 0.012)), 0.32, 16, 8)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.025, fc.z - fm.z - 0.004)), Vector((fm.x + 0.02, fm.y + 0.045, 0.008)), 0.3, 16, 4)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + alto / 2)), Vector((pm.x + 0.022, pm.y + 0.022, alto / 2)), 0.35, 16, 8)
            T.bloque_redondo(bm, Vector((pc.x, pc.y, pmin.z + alto)), Vector((pm.x + 0.03, pm.y + 0.03, 0.015)), 0.35, 16, 4)
            for z in (pmin.z + alto * 0.3, pmin.z + alto * 0.62):
                T.bloque_redondo(bm, Vector((pc.x, pc.y, z)), Vector((pm.x + 0.028, pm.y + 0.028, 0.008)), 0.35, 16, 4)

        def canillera(bm, pc=pc, pm=pm, pmin=pmin, alto=alto):
            c = Vector((pc.x, pc.y, pmin.z + alto * 0.55))
            _cascara(bm, c, Vector((pm.x + 0.035, pm.y + 0.035, alto * 0.42)), 0.45, 16, 10,
                     lambda p: p.y < c.y - (pm.y + 0.035) * 0.35, 0.008)
            for k in range(4):
                T.remache(bm, Vector((pc.x + (k % 2 - 0.5) * pm.x * 1.1, pc.y - pm.y - 0.045, pmin.z + alto * (0.3 + 0.45 * (k // 2)))), 0.006)
            # Rodillera.
            T.bloque_redondo(bm, Vector((pc.x, pc.y - pm.y - 0.03, pmax.z - 0.01)), Vector((pm.x * 0.6, 0.02, 0.04)), 0.5, 14, 8)

        objs += T.pieza_separada(f"{NOMBRE}_Bota{lado}", hueso, [("cuero", bota), ("acero", canillera)])
    return objs


def _pieza_de(nombre_obj):
    """Cuervo_HombreraIzq_Acero -> Hombreras; Cuervo_PetoBajo -> Peto (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for clave, prefijo in (("Hombreras", "Hombrera"), ("Antebrazos", "Antebrazo"), ("Guantes", "Guante"),
                           ("Botas", "Bota"), ("Peto", "Peto"), ("Peto", "Logo"), ("Mangas", "Manga"), ("Piernas", "Pierna")):
        if base.startswith(prefijo):
            return clave
    return base


def _miles(n):
    return f"{n:,}".replace(",", ".")


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
        filas.append(f"| {clave} | {_miles(por_pieza.get(clave, 0))}{marca} | {_miles(tope)} | {mallas} |")
    total = cuenta["_total"]
    filas.append(f"| **Total** | **{_miles(total)}** | **36.000** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas.append("")
    filas.append(f"Malla más pesada: {_miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla).")
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, "cuervo_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Cuervo: triángulos por pieza\n\n" + texto + "\n")
    return texto


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_")]


def detalle():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    d_capucha()
    d_capa()
    d_peto()
    d_hombreras()
    d_mangas()
    d_piernas()
    d_antebrazos()
    d_guantes()
    d_cinturon()
    d_botas()
    piezas = piezas_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    print("Render:", B.render_vistas("cuervo", B.partes() + piezas))
    capucha_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_Capucha")]
    emblema_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_Logo")]
    gancho_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_AntebrazoDer")] + [B.parte("RightHand")]
    print(B.render_primer_plano("cuervo_capucha", capucha_, giro=30, margen=1.1))
    print(B.render_primer_plano("cuervo_emblema", emblema_, giro=10, margen=1.8))
    print(B.render_primer_plano("cuervo_gancho", gancho_, giro=70, margen=1.15))
    return piezas


# ---------------------------------------------------------------------------
# Detalle v2: NIVEL DE DETALLE OBLIGATORIO (bisel, horneado, texturas con desgaste) con detalle.py
# ---------------------------------------------------------------------------

# Topes por pieza para que el total quede ≤ 36.000 (con el bisel la malla crece).
PRESUPUESTO_V2 = {
    "Capucha": 7000,
    "Capa": 7400,
    "Peto": 6500,
    "Hombreras": 2600,
    "Antebrazos": 2800,
    "Guantes": 1900,
    "Cinturon": 1800,
    "Botas": 2800,
    "Mangas": 1500,
    "Piernas": 1600,
}
# Triángulos del primer detalle (v1), para la tabla.
V1 = {"Capucha": 4888, "Capa": 6248, "Peto": 4996, "Hombreras": 964, "Antebrazos": 2516, "Guantes": 1920,
      "Cinturon": 1752, "Botas": 2568, "Mangas": 1880, "Piernas": 2288}


def tabla_v2(objs):
    cuenta = B.contar_triangulos(objs)
    por_pieza = {}
    for nombre, n in cuenta.items():
        if nombre != "_total":
            por_pieza[_pieza_de(nombre)] = por_pieza.get(_pieza_de(nombre), 0) + n
    filas = ["| Pieza | v1 | v2 | Tope v2 | Mallas |", "|---|---|---|---|---|"]
    for clave, tope in PRESUPUESTO_V2.items():
        mallas = ", ".join(sorted(n.replace(NOMBRE + "_", "") for n in cuenta if n != "_total" and _pieza_de(n) == clave))
        filas.append(f"| {clave} | {_miles(V1[clave])} | {_miles(por_pieza.get(clave, 0))} | {_miles(tope)} | {mallas} |")
    filas.append(f"| **Total** | **{_miles(sum(V1.values()))}** | **{_miles(cuenta['_total'])}** | **36.000** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {_miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, "cuervo_v2_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Cuervo v2: triángulos por pieza\n\n" + texto + "\n\n"
                "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
                "linajes/arte/blender/texturas/cuervo/.\n")
    return texto


def detalle_v2():
    import detalle as D

    v1 = {n: os.path.join(B.RENDERS, f"cuervo_{n}.png") for n in ("vistas", "capucha", "emblema", "gancho")}
    copias = {}
    for n, ruta in v1.items():  # el render anterior se guarda para comparar
        copias[n] = os.path.join(B.RENDERS, f"_v1_{n}.png")
        if os.path.exists(ruta):
            with open(ruta, "rb") as a, open(copias[n], "wb") as b:
                b.write(a.read())
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    for armar in (d_capucha, d_capa, d_peto, d_hombreras, d_mangas, d_piernas, d_antebrazos, d_guantes, d_cinturon, d_botas):
        armar()
    piezas = piezas_detalle()
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO_V2.items()}
    # Las plumas de la capa no llevan líneas de panel ni remaches: solo rayones y bordes gastados.
    plumas = {"rayones": 1.0, "bordes": 0.6, "suciedad": 0.5}
    D.terminar(piezas, grupos, "cuervo", recetas={f"{NOMBRE}_Capa_Acero": plumas})
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_v2(piezas))
    print("Render:", B.render_vistas("cuervo_v2", B.partes() + piezas))
    capucha_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_Capucha")]
    emblema_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_Logo")]
    gancho_ = [o for o in piezas if o.name.startswith(f"{NOMBRE}_AntebrazoDer")] + [B.parte("RightHand")]
    B.render_primer_plano("cuervo_v2_capucha", capucha_, giro=30, margen=1.1)
    B.render_primer_plano("cuervo_v2_emblema", emblema_, giro=10, margen=1.8)
    B.render_primer_plano("cuervo_v2_gancho", gancho_, giro=70, margen=1.15)
    # Comparación: arriba v1, abajo v2; y los primeros planos v1 | v2.
    R = B.RENDERS
    B.hoja([[copias["vistas"]], [os.path.join(R, "cuervo_v2_vistas.png")]], os.path.join(R, "cuervo_v2_vs_v1.png"))
    B.hoja(
        [[copias[n], os.path.join(R, f"cuervo_v2_{n}.png")] for n in ("capucha", "emblema", "gancho")],
        os.path.join(R, "cuervo_v2_vs_v1_primeros_planos.png"),
        reducir=2,
    )
    for ruta in copias.values():
        if os.path.exists(ruta):
            os.remove(ruta)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "v2" in argumentos:
        detalle_v2()
    if "boceto" in argumentos:
        boceto()
    if "detalle" in argumentos:
        detalle()
    if "logos" in argumentos:
        opciones_logo()
