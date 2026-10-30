"""Estela: velocista de la Liga (ficha de Juani del 30 oct).

El rayo del eclipse le dio velocidad. Diseño propio: sin rojo, sin rayo en el pecho ni en las
orejas, sin alas en la cabeza. Silueta: traje ajustado y aerodinámico, visor alargado hacia atrás
y líneas de luz cian que recorren el cuerpo como circuitos.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/estela.py -- boceto

Paso "boceto": bloques sin detalle de las piezas, render de 3 vistas (renders/estela_boceto_vistas.png).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Estela"
BLEND = os.path.join(B.BLENDER, "estela.blend")

# Presupuesto de triángulos por pieza (ficha, total ≤ 31.000).
PRESUPUESTO = {
    "Casco": 7000,
    "Traje": 14000,
    "Emblema": 1000,
    "GuantesBotas": 6000,
    "Mochila": 3000,
}

VISOR_ATRAS = 0.5 * B.STUD  # el visor sigue 0,5 studs detrás de la nuca
LINEA = 0.05 * B.STUD  # ancho de las líneas de luz


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def _linea(bm, a, b, ancho=LINEA, alto=LINEA * 0.6):
    """Tira fina de luz de `a` a `b` (una caja alargada)."""
    a, b = Vector(a), Vector(b)
    eje = b - a
    giro = eje.to_track_quat("Z", "Y").to_matrix()
    T.caja(bm, (a + b) / 2, Vector((ancho, alto, eje.length + ancho)), giro)


def _circuito(bm, puntos):
    """Línea de luz que quiebra en ángulo (como pista de circuito)."""
    for a, b in zip(puntos, puntos[1:]):
        _linea(bm, a, b)


# ---------------------------------------------------------------------------
# Boceto (paso 1)
# ---------------------------------------------------------------------------


def casco():
    """Casco violeta oscuro; visor cian que envuelve la cara y se estira hacia atrás; aletas finas
    y bajas en las sienes, pegadas al casco (no son alas)."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.015, 0.015, 0.015))
    vz = hc.z + hm.z * 0.15
    nuca = hc.y + m.y

    def cuerpo(bm):
        T.bloque_redondo(bm, hc, m, 0.45, 24, 14)

    def visor(bm):
        T.caja(bm, Vector((hc.x, hc.y - m.y - 0.008, vz)), Vector((m.x * 1.7, 0.02, hm.z * 0.42)))
        for s in (-1, 1):  # costados: van de la cara a 0,5 studs detrás de la nuca, afinándose
            largo = (nuca + VISOR_ATRAS) - (hc.y - m.y * 0.8)
            v = T.caja(bm, Vector((hc.x + s * (m.x + 0.006), hc.y - m.y * 0.8 + largo / 2, vz)), Vector((0.02, largo, hm.z * 0.42)))
            for p in v:
                if p.co.y > nuca:
                    p.co.z = vz + (p.co.z - vz) * 0.35 + 0.02
                    p.co.x -= s * 0.02

    def aletas(bm):
        for s in (-1, 1):
            base = Vector((hc.x + s * (m.x + 0.01), hc.y + m.y * 0.1, vz + hm.z * 0.45))
            T.punta(bm, base, base + Vector((s * 0.015, 0.16, 0.05)), 0.03, 3)

    return T.pieza(f"{NOMBRE}_Casco", "Head", [("violeta-oscuro", cuerpo), ("visor-cian", visor), ("acero", aletas)])


def traje():
    """Una pieza por parte del cuerpo: violeta ajustado, placas finas de acero en pecho, hombros y
    muslos, y líneas de luz cian por los costados, brazos y piernas."""
    piezas = []
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.012

    def torso(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.012, 0.012, 0.006)), 0.3, 20, 10)

    def placas_pecho(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * tm.x * 0.5, frente - 0.006, tc.z + tm.z * 0.45)), Vector((tm.x * 0.8, 0.012, tm.z * 0.4)), _g(s * -6, "Y"))

    def luces_torso(bm):
        for s in (-1, 1):
            x = tc.x + s * (tm.x + 0.013)
            _circuito(bm, [Vector((x, tc.y - tm.y * 0.3, tmax.z - 0.03)), Vector((x, tc.y - tm.y * 0.3, tc.z)), Vector((x, tc.y + tm.y * 0.3, tc.z - tm.z * 0.3)), Vector((x, tc.y + tm.y * 0.3, tmin.z))])

    piezas.append(T.pieza(f"{NOMBRE}_Torso", "UpperTorso", [("violeta", torso), ("acero", placas_pecho), ("neon-cian", luces_torso)]))

    lmin, lmax, lc, lm = T.caja_parte("LowerTorso")

    def cadera(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.012, 0.012, 0.004)), 0.3, 20, 8)

    def luces_cadera(bm):
        for s in (-1, 1):
            x = lc.x + s * (lm.x + 0.013)
            _linea(bm, Vector((x, lc.y + lm.y * 0.3, lmax.z)), Vector((x, lc.y + lm.y * 0.3, lmin.z)))

    piezas.append(T.pieza(f"{NOMBRE}_Cadera", "LowerTorso", [("violeta", cadera), ("neon-cian", luces_cadera)]))

    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            pmin, pmax, c, m = T.caja_parte(parte)
            afuera = 1 if c.x > 0 else -1
            arriba = "Upper" in parte

            def manga(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.01, 0.01, 0.004)), 0.35, 16, 8)

            def hombrera(bm, c=c, m=m, pmax=pmax, afuera=afuera):
                T.bloque_redondo(bm, Vector((c.x + afuera * 0.01, c.y, pmax.z - m.z * 0.25)), Vector((m.x + 0.025, m.y + 0.025, m.z * 0.3)), 0.6, 16, 8)

            def luz(bm, c=c, m=m, pmin=pmin, pmax=pmax, afuera=afuera):
                x = c.x + afuera * (m.x + 0.012)
                _linea(bm, Vector((x, c.y, pmax.z - 0.02)), Vector((x, c.y, pmin.z + 0.02)))

            capas = [("violeta", manga)] + ([("acero", hombrera)] if arriba else []) + [("neon-cian", luz)]
            piezas.append(T.pieza(f"{NOMBRE}_{'Brazo' if arriba else 'Antebrazo'}{lado}", parte, capas))

    for lado, hueso in T._lados("UpperLeg"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            pmin, pmax, c, m = T.caja_parte(parte)
            afuera = 1 if c.x > 0 else -1
            arriba = "Upper" in parte

            def pierna(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.01, 0.01, 0.004)), 0.35, 16, 8)

            def placa_muslo(bm, c=c, m=m):
                T.caja(bm, Vector((c.x, c.y - m.y - 0.014, c.z + m.z * 0.15)), Vector((m.x * 1.4, 0.012, m.z * 1.0)))

            def luz(bm, c=c, m=m, pmin=pmin, pmax=pmax, afuera=afuera):
                x = c.x + afuera * (m.x + 0.012)
                _circuito(bm, [Vector((x, c.y - m.y * 0.3, pmax.z - 0.01)), Vector((x, c.y - m.y * 0.3, c.z)), Vector((x, c.y + m.y * 0.3, c.z - m.z * 0.3)), Vector((x, c.y + m.y * 0.3, pmin.z + 0.01))])

            capas = [("violeta", pierna)] + ([("acero", placa_muslo)] if arriba else []) + [("neon-cian", luz)]
            piezas.append(T.pieza(f"{NOMBRE}_{'Muslo' if arriba else 'Pierna'}{lado}", parte, capas))
    return piezas


def emblema():
    """Rombo violeta claro con tres líneas paralelas inclinadas de luz (estela de velocidad)."""
    _, _, tc, tm = T.caja_parte("UpperTorso")
    c = Vector((tc.x, tc.y - tm.y - 0.03, tc.z + tm.z * 0.1))
    lado = tm.x * 0.75

    def rombo(bm):
        T.caja(bm, c, Vector((lado, 0.012, lado)), _g(45, "Y"))

    def lineas(bm):
        for k in (-1, 0, 1):
            centro = c + Vector((k * lado * 0.08, -0.01, k * lado * 0.24))
            _linea(bm, centro + Vector((-lado * 0.32, 0, -lado * 0.1)), centro + Vector((lado * 0.32, 0, lado * 0.1)), ancho=LINEA * 1.4)

    return T.pieza(f"{NOMBRE}_Emblema", "UpperTorso", [("violeta-claro", rombo), ("neon-cian", lineas)])


def guantes_botas():
    """Guantes aerodinámicos con una aleta en la muñeca; botas con suela gruesa de acero y 3 ranuras
    de luz a cada lado."""
    piezas = []
    for lado, hueso in T._lados("Hand"):
        _, mmax, mc, mm = T.caja_parte(hueso)
        afuera = 1 if mc.x > 0 else -1

        def guante(bm, mc=mc, mm=mm):
            T.bloque_redondo(bm, mc, mm + Vector((0.018, 0.018, 0.01)), 0.35, 16, 8)

        def aleta(bm, mc=mc, mm=mm, mmax=mmax, afuera=afuera):
            base = Vector((mc.x + afuera * (mm.x + 0.012), mc.y, mmax.z))
            T.punta(bm, base, base + Vector((afuera * 0.01, 0.08, 0.04)), 0.025, 3)

        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso, [("violeta-oscuro", guante), ("acero", aleta)]))

    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)
        suela_z = fmin.z + 0.03

        def bota(bm, fc=fc, fm=fm):
            T.bloque_redondo(bm, fc + Vector((0, -0.02, 0.02)), fm + Vector((0.018, 0.05, 0.01)), 0.35, 16, 10)

        def suela(bm, fc=fc, fm=fm, z=suela_z):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.02, z)), Vector((fm.x + 0.025, fm.y + 0.065, 0.032)), 0.3, 16, 6)

        def ranuras(bm, fc=fc, fm=fm, z=suela_z):
            for s in (-1, 1):
                for k in (-1, 0, 1):
                    y = fc.y - 0.02 + k * fm.y * 0.55
                    T.caja(bm, Vector((fc.x + s * (fm.x + 0.026), y, z)), Vector((0.006, fm.y * 0.35, LINEA)))

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("violeta-oscuro", bota), ("acero", suela), ("neon-cian", ranuras)]))
    return piezas


def mochila():
    """Condensador chico en la espalda: caja de acero redondeada con un anillo de luz atrás."""
    _, _, tc, tm = T.caja_parte("UpperTorso")
    c = Vector((tc.x, tc.y + tm.y + 0.06, tc.z + tm.z * 0.15))

    def caja(bm):
        T.bloque_redondo(bm, c, Vector((tm.x * 0.45, 0.05, tm.z * 0.5)), 0.45, 20, 10)

    def anillo(bm):
        p = c + Vector((0, 0.052, 0))
        r = tm.x * 0.3
        aro = [p + Vector((math.cos(a) * r, 0, math.sin(a) * r)) for a in (2 * math.pi * i / 24 for i in range(25))]
        T.tubo(bm, aro, 0.012, 6, tapas=False)

    return T.pieza(f"{NOMBRE}_Mochila", "UpperTorso", [("acero", caja), ("neon-cian", anillo)])


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [casco(), *traje(), emblema(), *guantes_botas(), mochila()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas("estela_boceto", B.partes() + piezas))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------


def _placa(bm, centro, tam, giro=None, borde=0.008):
    """Placa fina en dos capas: base y una más chica encima (borde levantado)."""
    giro = giro or Matrix.Identity(3)
    T.caja(bm, centro, tam, giro)
    afuera = giro @ Vector((0, -1, 0))
    T.caja(bm, centro + afuera * (tam.y / 2 + borde / 2), Vector((tam.x - borde * 3, borde, tam.z - borde * 3)), giro)


def _nodo(bm, p, afuera):
    """Cuadradito donde quiebra una línea de luz (el "pad" del circuito)."""
    giro = Vector((0, -1, 0)).rotation_difference(Vector(afuera)).to_matrix()
    T.caja(bm, p, Vector((LINEA * 2.2, LINEA * 0.7, LINEA * 2.2)), giro)


def _circuito_nodos(bm, puntos, afuera):
    _circuito(bm, puntos)
    for p in puntos[1:-1]:
        _nodo(bm, p, afuera)
    _nodo(bm, puntos[-1], afuera)


def d_casco():
    """Casco aerodinámico: cáscara con cresta baja, mentonera y protectores de mandíbula; marco de
    acero alrededor del visor, visor envolvente que se estira hacia atrás; respiraderos redondos en
    las orejas (con 3 rejillas, sin rayos); aletas finas en dos capas; línea de luz en la cresta."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.015, 0.015, 0.015))
    vz = hc.z + hm.z * 0.15
    nuca = hc.y + m.y
    frente = hc.y - m.y

    def cascara(bm):
        T.bloque_redondo(bm, hc, m + Vector((0.006, 0.006, 0.006)), 0.3, 40, 24)  # tapa las esquinas de la cabeza
        T.bloque_redondo(bm, Vector((hc.x, hc.y + 0.01, hmax.z + 0.008)), Vector((0.022, m.y * 0.85, 0.014)), 0.5, 16, 8)  # cresta
        T.bloque_redondo(bm, Vector((hc.x, frente + 0.005, hc.z - hm.z * 0.62)), Vector((hm.x * 0.6, 0.02, hm.z * 0.25)), 0.5, 20, 8)  # mentonera
        for s in (-1, 1):  # mandíbula
            T.bloque_redondo(bm, Vector((hc.x + s * (m.x - 0.005), hc.y - m.y * 0.35, hc.z - hm.z * 0.45)), Vector((0.015, m.y * 0.5, hm.z * 0.3)), 0.5, 16, 8)
        T.bloque_redondo(bm, Vector((hc.x, nuca + 0.004, hc.z - hm.z * 0.55)), Vector((m.x * 0.8, 0.015, hm.z * 0.3)), 0.5, 20, 8)  # cubrenuca

    def visor(bm):
        largo = (nuca + VISOR_ATRAS) - (hc.y - m.y * 0.8)
        T.bloque_redondo(bm, Vector((hc.x, frente - 0.006, vz)), Vector((m.x * 0.88, 0.012, hm.z * 0.2)), 0.6, 24, 8)
        for s in (-1, 1):
            v = T.caja(bm, Vector((hc.x + s * (m.x + 0.006), hc.y - m.y * 0.8 + largo / 2, vz)), Vector((0.016, largo, hm.z * 0.4)))
            for p in v:
                if p.co.y > nuca:
                    p.co.z = vz + (p.co.z - vz) * 0.35 + 0.02
                    p.co.x -= s * 0.02

    def metal(bm):
        T.bloque_redondo(bm, Vector((hc.x, frente + 0.002, vz)), Vector((m.x * 0.93, 0.012, hm.z * 0.25)), 0.6, 24, 8)  # marco del visor
        for s in (-1, 1):
            oreja = Vector((hc.x + s * (m.x + 0.01), hc.y + m.y * 0.15, hc.z - hm.z * 0.15))
            T.cilindro(bm, oreja - Vector((s * 0.01, 0, 0)), oreja + Vector((s * 0.012, 0, 0)), 0.05, 20)
            for k in (-1, 0, 1):  # rejillas del respiradero
                T.caja(bm, oreja + Vector((s * 0.014, 0, k * 0.022)), Vector((0.008, 0.07, 0.008)))
            for a in range(4):  # tornillos alrededor
                ang = math.pi / 4 + a * math.pi / 2
                T.remache(bm, oreja + Vector((s * 0.013, math.cos(ang) * 0.04, math.sin(ang) * 0.04)), 0.006, (s, 0, 0))
            base = Vector((hc.x + s * (m.x + 0.004), hc.y - m.y * 0.2, vz + hm.z * 0.3))
            for k, largo in enumerate((0.15, 0.1)):  # aletas finas en dos capas, pegadas y hacia atrás
                b = base + Vector((s * 0.004 * k, 0.01 * k, -0.012 * k))
                v = T.punta(bm, b, b + Vector((0, largo, 0.012)), 0.018 - 0.004 * k, 3)
                for p in v:  # aplastadas contra el casco
                    p.co.x = b.x + (p.co.x - b.x) * 0.35
            T.remache(bm, base + Vector((s * 0.006, 0.0, 0)), 0.007, (s, 0, 0))

    def luces(bm):
        _linea(bm, Vector((hc.x, frente + 0.07, hmax.z + 0.022)), Vector((hc.x, nuca - 0.07, hmax.z + 0.022)))
        for s in (-1, 1):
            x = hc.x + s * (m.x + 0.004)
            _circuito(bm, [Vector((x, frente + 0.04, hc.z - hm.z * 0.62)), Vector((x, hc.y - m.y * 0.05, hc.z - hm.z * 0.62)), Vector((x, hc.y + m.y * 0.5, hc.z - hm.z * 0.8))])

    return T.pieza_separada(f"{NOMBRE}_Casco", "Head", [("violeta-oscuro", cascara), ("visor-cian", visor), ("acero", metal), ("neon-cian", luces)])


def d_traje():
    """Torso con cuello, costuras levantadas en la panza y placas finas de pecho en capas;
    hombreras de dos láminas; codo y rodilla con placa; muslos con placa atornillada; líneas de luz
    tipo circuito (con nodos donde quiebran) por costados, brazos y piernas."""
    objs = []
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.012

    def torso(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.012, 0.012, 0.006)), 0.3, 40, 20)
        T.cilindro(bm, Vector((tc.x, tc.y, tmax.z - 0.01)), Vector((tc.x, tc.y, tmax.z + 0.03)), tm.y * 0.75, 24)  # cuello
        for k in range(3):  # costuras de la panza
            z = tc.z - tm.z * (0.25 + k * 0.22)
            T.caja(bm, Vector((tc.x, frente - 0.002, z)), Vector((tm.x * 1.3, 0.008, 0.008)))
        T.caja(bm, Vector((tc.x, frente - 0.002, tc.z - tm.z * 0.5)), Vector((0.008, 0.008, tm.z * 0.8)))

    def placas(bm):
        for s in (-1, 1):
            _placa(bm, Vector((tc.x + s * tm.x * 0.5, frente - 0.006, tc.z + tm.z * 0.45)), Vector((tm.x * 0.8, 0.012, tm.z * 0.4)), _g(s * -6, "Y"))
            for dx in (-0.3, 0.3):
                T.remache(bm, Vector((tc.x + s * tm.x * (0.5 + dx), frente - 0.022, tc.z + tm.z * 0.62)), 0.007)
        for s in (-1, 1):  # placas de la espalda a los costados de la mochila
            _placa(bm, Vector((tc.x + s * tm.x * 0.7, tc.y + tm.y + 0.018, tc.z - tm.z * 0.4)), Vector((tm.x * 0.4, 0.012, tm.z * 0.5)), _g(180, "Z"))

    def luces_torso(bm):
        for s in (-1, 1):
            x = tc.x + s * (tm.x + 0.013)
            _circuito_nodos(bm, [Vector((x, tc.y - tm.y * 0.3, tmax.z - 0.03)), Vector((x, tc.y - tm.y * 0.3, tc.z)), Vector((x, tc.y + tm.y * 0.3, tc.z - tm.z * 0.3)), Vector((x, tc.y + tm.y * 0.3, tmin.z + 0.01))], (s, 0, 0))
            _circuito(bm, [Vector((tc.x + s * tm.x * 0.95, frente - 0.002, tmin.z + 0.02)), Vector((tc.x + s * tm.x * 0.7, frente - 0.002, tc.z - tm.z * 0.2)), Vector((tc.x + s * tm.x * 0.7, frente - 0.002, tc.z + tm.z * 0.05))])

    objs += T.pieza_separada(f"{NOMBRE}_Torso", "UpperTorso", [("violeta", torso), ("acero", placas), ("neon-cian", luces_torso)])

    lmin, lmax, lc, lm = T.caja_parte("LowerTorso")

    def cadera(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.012, 0.012, 0.004)), 0.3, 32, 12)
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lmax.z - 0.02)), Vector((lm.x + 0.02, lm.y + 0.02, 0.018)), 0.3, 32, 6)  # cinturón

    def hebilla(bm):
        _placa(bm, Vector((lc.x, lc.y - lm.y - 0.03, lmax.z - 0.02)), Vector((0.09, 0.012, 0.045)), borde=0.006)
        for s in (-1, 1):
            T.remache(bm, Vector((lc.x + s * 0.035, lc.y - lm.y - 0.045, lmax.z - 0.02)), 0.006)

    def luces_cadera(bm):
        for s in (-1, 1):
            x = lc.x + s * (lm.x + 0.013)
            _linea(bm, Vector((x, lc.y + lm.y * 0.3, lmax.z - 0.04)), Vector((x, lc.y + lm.y * 0.3, lmin.z)))
        _linea(bm, Vector((lc.x - 0.015, lc.y - lm.y - 0.042, lmax.z - 0.02)), Vector((lc.x + 0.015, lc.y - lm.y - 0.042, lmax.z - 0.02)))

    objs += T.pieza_separada(f"{NOMBRE}_Cadera", "LowerTorso", [("violeta", cadera), ("acero", hebilla), ("neon-cian", luces_cadera)])

    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            pmin, pmax, c, m = T.caja_parte(parte)
            afuera = 1 if c.x > 0 else -1
            arriba = "Upper" in parte

            def manga(bm, c=c, m=m, pmin=pmin, arriba=arriba):
                T.bloque_redondo(bm, c, m + Vector((0.01, 0.01, 0.004)), 0.35, 28, 12)
                if not arriba:  # puño de la manga
                    T.cilindro(bm, Vector((c.x, c.y, pmin.z + 0.01)), Vector((c.x, c.y, pmin.z + 0.035)), max(m.x, m.y) + 0.016, 20)

            def metal(bm, c=c, m=m, pmax=pmax, afuera=afuera, arriba=arriba):
                if arriba:  # hombrera de dos láminas
                    for k in range(2):
                        T.bloque_redondo(bm, Vector((c.x + afuera * 0.01, c.y, pmax.z - m.z * (0.22 + k * 0.28))), Vector((m.x + 0.025 - k * 0.006, m.y + 0.025 - k * 0.006, m.z * 0.16)), 0.6, 24, 8)
                    for dy in (-1, 1):
                        T.remache(bm, Vector((c.x + afuera * (m.x + 0.038), c.y + dy * m.y * 0.5, pmax.z - m.z * 0.22)), 0.007, (afuera, 0, 0))
                else:  # codera
                    _placa(bm, Vector((c.x, c.y + m.y + 0.014, pmax.z - m.z * 0.15)), Vector((m.x * 1.2, 0.012, m.z * 0.35)), _g(180, "Z"))

            def luz(bm, c=c, m=m, pmin=pmin, pmax=pmax, afuera=afuera, arriba=arriba):
                x = c.x + afuera * (m.x + 0.012)
                arriba_z = pmax.z - (m.z * 0.75 if arriba else 0.02)
                _circuito_nodos(bm, [Vector((x, c.y - m.y * 0.25, arriba_z)), Vector((x, c.y - m.y * 0.25, c.z - m.z * 0.2)), Vector((x, c.y + m.y * 0.25, c.z - m.z * 0.5)), Vector((x, c.y + m.y * 0.25, pmin.z + 0.04))], (afuera, 0, 0))

            objs += T.pieza_separada(f"{NOMBRE}_{'Brazo' if arriba else 'Antebrazo'}{lado}", parte, [("violeta", manga), ("acero", metal), ("neon-cian", luz)])

    for lado, hueso in T._lados("UpperLeg"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            pmin, pmax, c, m = T.caja_parte(parte)
            afuera = 1 if c.x > 0 else -1
            arriba = "Upper" in parte

            def pierna(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.01, 0.01, 0.004)), 0.35, 28, 12)

            def metal(bm, c=c, m=m, pmax=pmax, arriba=arriba):
                y = c.y - m.y - 0.014
                if arriba:
                    _placa(bm, Vector((c.x, y, c.z + m.z * 0.15)), Vector((m.x * 1.4, 0.012, m.z * 1.0)))
                    for dx in (-0.55, 0.55):
                        for dz in (-0.3, 0.6):
                            T.remache(bm, Vector((c.x + m.x * dx, y - 0.016, c.z + m.z * dz)), 0.007)
                else:  # rodillera
                    T.bloque_redondo(bm, Vector((c.x, y, pmax.z - m.z * 0.2)), Vector((m.x * 0.8, 0.02, m.z * 0.25)), 0.55, 20, 8)

            def luz(bm, c=c, m=m, pmin=pmin, pmax=pmax, afuera=afuera):
                x = c.x + afuera * (m.x + 0.012)
                _circuito_nodos(bm, [Vector((x, c.y - m.y * 0.3, pmax.z - 0.01)), Vector((x, c.y - m.y * 0.3, c.z)), Vector((x, c.y + m.y * 0.3, c.z - m.z * 0.3)), Vector((x, c.y + m.y * 0.3, pmin.z + 0.01))], (afuera, 0, 0))

            objs += T.pieza_separada(f"{NOMBRE}_{'Muslo' if arriba else 'Pierna'}{lado}", parte, [("violeta", pierna), ("acero", metal), ("neon-cian", luz)])
    return objs


def d_emblema():
    """Rombo violeta claro en dos capas con borde biselado y tres líneas inclinadas de luz."""
    _, _, tc, tm = T.caja_parte("UpperTorso")
    c = Vector((tc.x, tc.y - tm.y - 0.03, tc.z + tm.z * 0.1))
    lado = tm.x * 0.75

    def rombo(bm):
        T.caja(bm, c, Vector((lado, 0.012, lado)), _g(45, "Y"))
        T.caja(bm, c + Vector((0, -0.009, 0)), Vector((lado * 0.82, 0.008, lado * 0.82)), _g(45, "Y"))
        for k in range(4):  # puntas levantadas en los vértices
            a = k * math.pi / 2
            p = c + Vector((math.cos(a) * lado * 0.66, -0.012, math.sin(a) * lado * 0.66))
            T.caja(bm, p, Vector((0.012, 0.01, 0.012)), _g(45, "Y"))

    def lineas(bm):
        for k in (-1, 0, 1):
            centro = c + Vector((k * lado * 0.08, -0.016, k * lado * 0.24))
            largo = 0.32 - abs(k) * 0.05
            _linea(bm, centro + Vector((-lado * largo, 0, -lado * 0.1)), centro + Vector((lado * largo, 0, lado * 0.1)), ancho=LINEA * 1.4)

    return T.pieza_separada(f"{NOMBRE}_Emblema", "UpperTorso", [("violeta-claro", rombo), ("neon-cian", lineas)])


def d_guantes_botas():
    """Guantes con placas de nudillos, puño acampanado y aleta en la muñeca; botas con caña,
    puntera, talón con aleta, suela gruesa de acero y 3 ranuras de luz por lado."""
    objs = []
    for lado, hueso in T._lados("Hand"):
        mmin, mmax, mc, mm = T.caja_parte(hueso)
        afuera = 1 if mc.x > 0 else -1

        def guante(bm, mc=mc, mm=mm, mmax=mmax):
            T.bloque_redondo(bm, mc, mm + Vector((0.018, 0.018, 0.01)), 0.35, 24, 12)
            T.cilindro(bm, Vector((mc.x, mc.y, mmax.z - 0.01)), Vector((mc.x, mc.y, mmax.z + 0.04)), max(mm.x, mm.y) + 0.02, 20, max(mm.x, mm.y) + 0.035)

        def metal(bm, mc=mc, mm=mm, mmin=mmin, mmax=mmax, afuera=afuera):
            for k in range(4):  # nudillos
                x = mc.x + (k - 1.5) * mm.x * 0.5
                T.bloque_redondo(bm, Vector((x, mc.y - mm.y - 0.02, mmin.z + mm.z * 0.6)), Vector((mm.x * 0.2, 0.01, 0.018)), 0.5, 10, 6)
            base = Vector((mc.x + afuera * (mm.x + 0.02), mc.y, mmax.z + 0.02))
            T.punta(bm, base, base + Vector((afuera * 0.01, 0.09, 0.04)), 0.025, 3)
            T.remache(bm, base, 0.007, (afuera, 0, 0))

        def luz(bm, mc=mc, mm=mm, mmax=mmax):
            _linea(bm, Vector((mc.x, mc.y + mm.y + 0.02, mmax.z)), Vector((mc.x, mc.y + mm.y + 0.02, mc.z - mm.z * 0.3)))

        objs += T.pieza_separada(f"{NOMBRE}_Guante{lado}", hueso, [("violeta-oscuro", guante), ("acero", metal), ("neon-cian", luz)])

    for lado, hueso in T._lados("Foot"):
        fmin, fmax, fc, fm = T.caja_parte(hueso)
        z = fmin.z + 0.03

        def bota(bm, fc=fc, fm=fm, fmax=fmax):
            T.bloque_redondo(bm, fc + Vector((0, -0.02, 0.02)), fm + Vector((0.018, 0.05, 0.01)), 0.35, 28, 14)
            T.cilindro(bm, Vector((fc.x, fc.y, fmax.z - 0.01)), Vector((fc.x, fc.y, fmax.z + 0.035)), max(fm.x, fm.y) + 0.025, 20)  # caña

        def metal(bm, fc=fc, fm=fm, z=z):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.02, z)), Vector((fm.x + 0.025, fm.y + 0.065, 0.032)), 0.3, 28, 8)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - fm.y - 0.06, z + 0.045)), Vector((fm.x * 0.85, 0.035, 0.03)), 0.5, 20, 8)  # puntera
            talon = Vector((fc.x, fc.y + fm.y + 0.03, z + 0.05))
            T.punta(bm, talon, talon + Vector((0, 0.07, 0.05)), 0.03, 3)  # aleta del talón
            for s in (-1, 1):
                T.remache(bm, Vector((fc.x + s * (fm.x + 0.02), fc.y + fm.y * 0.7, z + 0.06)), 0.007, (s, 0, 0))

        def ranuras(bm, fc=fc, fm=fm, z=z):
            for s in (-1, 1):
                for k in (-1, 0, 1):
                    T.caja(bm, Vector((fc.x + s * (fm.x + 0.026), fc.y - 0.02 + k * fm.y * 0.55, z)), Vector((0.008, fm.y * 0.35, LINEA)))

        objs += T.pieza_separada(f"{NOMBRE}_Bota{lado}", hueso, [("violeta-oscuro", bota), ("acero", metal), ("neon-cian", ranuras)])
    return objs


def d_mochila():
    """Condensador: carcasa redondeada con dos tapas laterales, aletas de ventilación, cuatro
    tornillos y anillo de luz con núcleo."""
    _, _, tc, tm = T.caja_parte("UpperTorso")
    c = Vector((tc.x, tc.y + tm.y + 0.06, tc.z + tm.z * 0.15))
    r = tm.x * 0.3

    def carcasa(bm):
        T.bloque_redondo(bm, c, Vector((tm.x * 0.45, 0.05, tm.z * 0.5)), 0.45, 28, 14)
        for s in (-1, 1):
            p = c + Vector((s * tm.x * 0.45, 0, 0))
            T.cilindro(bm, p, p + Vector((s * 0.02, 0, 0)), 0.035, 16)
            for k in range(3):  # aletas de ventilación
                T.caja(bm, c + Vector((s * tm.x * 0.3, 0.045, -tm.z * 0.32 - k * 0.02)), Vector((0.05, 0.012, 0.006)))
        for sx in (-1, 1):
            for sz in (-1, 1):
                T.remache(bm, c + Vector((sx * tm.x * 0.36, 0.05, sz * tm.z * 0.4)), 0.008, (0, 1, 0))
        T.cilindro(bm, c + Vector((0, 0.04, 0)), c + Vector((0, 0.06, 0)), r * 1.25, 28)  # marco del anillo

    def luz(bm):
        p = c + Vector((0, 0.064, 0))
        aro = [p + Vector((math.cos(a) * r, 0, math.sin(a) * r)) for a in (2 * math.pi * i / 32 for i in range(33))]
        T.tubo(bm, aro, 0.012, 8, tapas=False)
        T.cilindro(bm, p - Vector((0, 0.004, 0)), p + Vector((0, 0.004, 0)), r * 0.35, 16)  # núcleo

    return T.pieza_separada(f"{NOMBRE}_Mochila", "UpperTorso", [("acero", carcasa), ("neon-cian", luz)])


GRUPOS = (
    ("Casco", ("Casco",)),
    ("Traje", ("Torso", "Cadera", "Brazo", "Antebrazo", "Muslo", "Pierna")),
    ("Emblema", ("Emblema",)),
    ("GuantesBotas", ("Guante", "Bota")),
    ("Mochila", ("Mochila",)),
)


def _pieza_de(nombre_obj):
    base = nombre_obj.split("_")[1]
    for clave, prefijos in GRUPOS:
        if base.startswith(prefijos):
            return clave
    return base


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


def tabla_triangulos(objs):
    import cuervo as C

    cuenta = B.contar_triangulos(objs)
    por_pieza = {}
    for nombre, n in cuenta.items():
        if nombre != "_total":
            por_pieza[_pieza_de(nombre)] = por_pieza.get(_pieza_de(nombre), 0) + n
    filas = ["| Pieza | Triángulos | Presupuesto | Mallas |", "|---|---|---|---|"]
    for clave, tope in PRESUPUESTO.items():
        mallas = sum(1 for n in cuenta if n != "_total" and _pieza_de(n) == clave)
        marca = "" if por_pieza.get(clave, 0) <= tope else " ⚠"
        filas.append(f"| {clave} | {C._miles(por_pieza.get(clave, 0))}{marca} | {C._miles(tope)} | {mallas} |")
    filas.append(f"| **Total** | **{C._miles(cuenta['_total'])}** | **{C._miles(sum(PRESUPUESTO.values()))}** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {C._miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, "estela_triangulos.md"), "w", encoding="utf-8") as f:
        f.write(
            "# Estela: triángulos por pieza\n\n" + texto + "\n\n"
            "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
            "linajes/arte/blender/texturas/estela/. El neón y el visor translúcido no llevan textura.\n"
        )
    return texto


def armar_detalle():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_casco, d_traje, d_emblema, d_guantes_botas, d_mochila):
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    casco = [o for o in piezas if _pieza_de(o.name) == "Casco"] + [B.parte("Head")]
    B.render_primer_plano(f"{prefijo}_casco", casco, giro=-55, altura=12, margen=1.4)
    pecho = [o for o in piezas if _pieza_de(o.name) == "Emblema"]
    B.render_primer_plano(f"{prefijo}_emblema", pecho + [B.parte("UpperTorso")], giro=12, altura=5, margen=0.75)
    botas = [o for o in piezas if "Bota" in o.name] + [B.parte(n) for n in ("LeftFoot", "RightFoot")]
    B.render_primer_plano(f"{prefijo}_botas", botas, giro=-40, altura=25, margen=1.7)
    print("Render:", B.render_vistas(prefijo, B.partes() + piezas))


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_estela_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, "estela")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, "estela")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/estela/."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    rutas = B.exportar_piezas("estela", piezas_detalle())
    print("Exportadas:", len(rutas))
    return rutas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in argumentos:
        boceto()
    if "prueba" in argumentos:
        prueba()
    if "detalle" in argumentos:
        detalle()
    if "exportar" in argumentos:
        exportar()
