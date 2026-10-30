"""Remache: jefe de la Cofradía (matón enorme del puerto, ficha de Juani del 30 oct).

Implantes hidráulicos robados de Corona Corp. Diseño propio: sin máscara de luchador, sin tubos
en la cabeza, sin tanque en la espalda. Silueta: torso enorme en V, brazos gigantes de pistones,
cabeza chica con casco de soldador. Es un jefe: el maniquí va escalado a 1,6x (ESCALA) y todas las
piezas se hacen para ese tamaño.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/remache.py -- boceto

Paso "boceto": bloques sin detalle de las piezas, render de 3 vistas con un maniquí normal al
costado para comparar el tamaño (renders/remache_boceto_vistas.png).
Paso "detalle": piezas con el nivel de detalle de la guía (bisel, normal map horneado, desgaste),
3 vistas + primeros planos del brazo hidráulico y la columna, y la tabla de triángulos.
Paso "exportar": un FBX por malla en exports/remache/.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import cuervo as C  # noqa: E402  (_miles)
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Remache"
BLEND = os.path.join(B.BLENDER, "remache.blend")
ESCALA = 1.6

# Presupuesto de triángulos por pieza (ficha, total ≤ 37.000).
PRESUPUESTO = {
    "Casco": 5000,
    "Arnes": 9000,
    "Brazos": 12000,
    "Punos": 5000,
    "Piernas": 6000,
}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def agrandar():
    """Escala el esqueleto (las partes del cuerpo lo siguen porque están pegadas a los huesos)."""
    B.esqueleto().scale = (ESCALA,) * 3
    bpy.context.view_layer.update()


def maniqui_normal(corrida=-1.5):
    """Copia del maniquí a tamaño normal, corrida a la izquierda, solo para comparar en el render."""
    copias = []
    for o in B.partes():
        c = o.copy()
        c.data = o.data.copy()
        c.name = "Comparar_" + o.name
        c.parent = None
        bpy.context.scene.collection.objects.link(c)
        c.matrix_world = Matrix.Translation((corrida, 0, 0)) @ Matrix.Scale(1 / ESCALA, 4) @ o.matrix_world
        copias.append(c)
    return copias


def _trapecio(bm, centro, ancho_arriba, ancho_abajo, prof, alto):
    """Caja más ancha arriba que abajo (el torso en V)."""
    hechos = T.caja(bm, centro, Vector((1, prof, alto)))
    for v in hechos:
        arriba = v.co.z > centro.z
        v.co.x = centro.x + (0.5 if v.co.x > centro.x else -0.5) * (ancho_arriba if arriba else ancho_abajo)


# ---------------------------------------------------------------------------
# Boceto (paso 1)
# ---------------------------------------------------------------------------


def casco():
    """Casco de soldador chico de acero oxidado, visor rectangular rojo y remaches en el borde."""
    _, hmax, hc, hm = T.caja_parte("Head")
    frente = hc.y - hm.y - 0.025

    def cuerpo(bm):
        T.bloque_redondo(bm, hc + Vector((0, 0.005, 0.01)), hm + Vector((0.012, 0.015, 0.012)), 0.3, 24, 14)

    def visor(bm):
        T.caja(bm, Vector((hc.x, frente - 0.01, hc.z + hm.z * 0.1)), Vector((hm.x * 1.4, 0.02, hm.z * 0.38)))

    def remaches(bm):
        for i in range(10):
            a = 2 * math.pi * i / 10
            p = Vector((hc.x + math.cos(a) * (hm.x + 0.03), hc.y + math.sin(a) * (hm.y + 0.035), hc.z - hm.z * 0.7))
            T.remache(bm, p, 0.014, (math.cos(a), math.sin(a), 0))

    return T.pieza(f"{NOMBRE}_Casco", "Head", [("oxido", cuerpo), ("neon-aviso", visor), ("acero", remaches)])


def arnes():
    """Musculosa de cuero, placas de acero en el pecho y la panza, columna de 6 vértebras con luz
    cian en la espalda y 2 tubos de líquido rojo de la espalda a los hombros."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03
    atras = tc.y + tm.y + 0.03

    def musculosa(bm):
        _trapecio(bm, tc, tm.x * 2 + 0.16, tm.x * 2 + 0.02, tm.y * 2 + 0.05, tm.z * 2 + 0.02)

    def trapecios(bm):  # los hombros suben y se abren: la V se lee aunque los brazos estén abajo
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * (tm.x + 0.04), tc.y, tmax.z + 0.02)), Vector((tm.x * 1.1, tm.y * 2 + 0.12, 0.12)), _g(s * -14, "Y"))

    def placas(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * tm.x * 0.5, frente - 0.01, tc.z + tm.z * 0.4)), Vector((tm.x * 0.85, 0.03, tm.z * 0.6)), _g(s * -8, "Y"))
        T.caja(bm, Vector((tc.x, frente - 0.005, tc.z - tm.z * 0.45)), Vector((tm.x * 1.0, 0.025, tm.z * 0.5)))

    def columna(bm):
        for i in range(6):
            z = tmax.z - 0.06 - i * (tm.z * 1.8 / 6)
            T.caja(bm, Vector((tc.x, atras + 0.02, z)), Vector((0.11, 0.05, 0.06)))

    def luces(bm):
        for i in range(6):
            z = tmax.z - 0.06 - i * (tm.z * 1.8 / 6)
            T.caja(bm, Vector((tc.x, atras + 0.048, z)), Vector((0.06, 0.008, 0.02)))

    def tubos(bm):
        for s in (-1, 1):
            hombro = Vector((tc.x + s * (tm.x + 0.06), tc.y, tmax.z + 0.02))
            camino = [
                Vector((tc.x + s * 0.07, atras + 0.03, tc.z - tm.z * 0.2)),
                Vector((tc.x + s * tm.x * 0.6, atras + 0.06, tc.z + tm.z * 0.5)),
                Vector((tc.x + s * tm.x * 0.9, tc.y + tm.y * 0.4, tmax.z + 0.05)),
                hombro,
            ]
            T.tubo(bm, camino, 0.03, 8)

    return T.pieza(
        f"{NOMBRE}_Arnes",
        "UpperTorso",
        [("cuero", musculosa), ("oxido", trapecios), ("oxido", placas), ("acero", columna), ("neon-cian", luces), ("liquido-rojo", tubos)],
    )


def brazos():
    """Mangas de acero oxidado gruesas, 2 pistones por brazo (uno en el brazo, uno en el antebrazo),
    mangueras negras y un engranaje en el codo."""
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        amin, amax, ac, am = T.caja_parte(hueso)
        bajo = hueso.replace("Upper", "Lower")
        bmin, bmax, bc, bm_ = T.caja_parte(bajo)
        afuera = 1 if ac.x > 0 else -1
        x_piston = ac.x + afuera * (am.x + 0.09)

        def arriba(bm, ac=ac, am=am):
            T.bloque_redondo(bm, ac, am + Vector((0.05, 0.05, 0.02)), 0.4, 20, 12)

        def piston_arriba(bm, amin=amin, amax=amax, ac=ac, x=x_piston):
            T.cilindro(bm, Vector((x, ac.y, amax.z - 0.03)), Vector((x, ac.y, ac.z)), 0.075, 12)
            T.cilindro(bm, Vector((x, ac.y, ac.z)), Vector((x, ac.y, amin.z + 0.02)), 0.04, 10)

        def manguera(bm, ac=ac, am=am, amax=amax, bc=bc, afuera=afuera):
            y = ac.y + am.y + 0.04
            T.tubo(bm, [Vector((ac.x, y, amax.z)), Vector((ac.x + afuera * 0.03, y + 0.03, ac.z)), Vector((bc.x, y, bc.z + 0.05))], 0.018, 6)

        piezas.append(T.pieza(f"{NOMBRE}_Brazo{lado}", hueso, [("oxido", arriba), ("acero", piston_arriba), ("negro", manguera)]))

        def abajo(bm, bc=bc, bm_=bm_):
            T.bloque_redondo(bm, bc, bm_ + Vector((0.06, 0.06, 0.02)), 0.4, 20, 12)

        def engranaje(bm, bmax=bmax, bc=bc, bm_=bm_, afuera=afuera):
            p = Vector((bc.x + afuera * (bm_.x + 0.05), bc.y, bmax.z - 0.02))
            T.cilindro(bm, p - Vector((afuera * 0.02, 0, 0)), p + Vector((afuera * 0.03, 0, 0)), 0.08, 12)

        def piston_abajo(bm, bmin=bmin, bmax=bmax, bc=bc, bm_=bm_):
            y = bc.y - bm_.y - 0.06
            T.cilindro(bm, Vector((bc.x, y, bmax.z - 0.06)), Vector((bc.x, y, bc.z - 0.02)), 0.075, 12)
            T.cilindro(bm, Vector((bc.x, y, bc.z - 0.02)), Vector((bc.x, y, bmin.z + 0.02)), 0.04, 10)

        piezas.append(T.pieza(f"{NOMBRE}_Antebrazo{lado}", bajo, [("oxido", abajo), ("acero", engranaje), ("acero", piston_abajo)]))
    return piezas


def punos():
    """Bloques de acero con 4 remaches grandes en los nudillos."""
    piezas = []
    for lado, hueso in T._lados("Hand"):
        mmin, _, mc, mm = T.caja_parte(hueso)

        def bloque(bm, mc=mc, mm=mm):
            T.bloque_redondo(bm, mc, mm + Vector((0.09, 0.09, 0.06)), 0.2, 16, 10)

        def nudillos(bm, mc=mc, mm=mm, mmin=mmin):
            for i in range(4):
                x = mc.x + (i - 1.5) * (mm.x * 2 + 0.08) / 4.5
                T.remache(bm, Vector((x, mc.y - mm.y - 0.09, mmin.z + 0.08)), 0.035)

        piezas.append(T.pieza(f"{NOMBRE}_Puno{lado}", hueso, [("acero", bloque), ("oxido", nudillos)]))
    return piezas


def piernas():
    """Pantalón de trabajo oscuro y botas negras con punta de acero."""
    piezas = []
    _, _, lc, lm = T.caja_parte("LowerTorso")

    def cadera(bm):
        T.caja(bm, lc, lm * 2 + Vector((0.05, 0.05, 0.02)))

    piezas.append(T.pieza(f"{NOMBRE}_Cadera", "LowerTorso", [("tela-oscura", cadera)]))
    for lado, hueso in T._lados("UpperLeg"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)

            def pierna(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.03, 0.03, 0.01)), 0.3, 16, 8)

            nombre = "Muslo" if "Upper" in parte else "Pierna"
            piezas.append(T.pieza(f"{NOMBRE}_{nombre}{lado}", parte, [("tela-oscura", pierna)]))
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)

        def bota(bm, fc=fc, fm=fm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.01)), fm + Vector((0.03, 0.06, 0.03)), 0.25, 16, 10)

        def punta(bm, fc=fc, fm=fm, fmin=fmin):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - fm.y - 0.06, fmin.z + 0.06)), Vector((fm.x + 0.035, 0.05, 0.06)), 0.4, 16, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota), ("acero", punta)]))
    return piezas


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    agrandar()
    piezas = [casco(), arnes(), *brazos(), *punos(), *piernas()]
    normal = maniqui_normal()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas("remache_boceto", B.partes() + piezas + normal))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------


def _anillo_remaches(bm, centro, rx, ry, z, n, radio=0.012):
    for i in range(n):
        a = 2 * math.pi * i / n
        T.remache(bm, Vector((centro.x + math.cos(a) * rx, centro.y + math.sin(a) * ry, z)), radio, (math.cos(a), math.sin(a), 0))


def _placa(bm, centro, tam, giro=None, borde=0.012):
    """Placa en dos capas: base y una más chica encima (borde levantado)."""
    giro = giro or Matrix.Identity(3)
    T.caja(bm, centro, tam, giro)
    afuera = giro @ Vector((0, -1, 0))
    T.caja(bm, centro + afuera * (tam.y / 2 + borde / 2), Vector((tam.x - borde * 3, borde, tam.z - borde * 3)), giro)


def _piston(bm, base, hacia, radio):
    """Pistón: camisa gruesa con dos aros, vástago fino y dos orejas de anclaje."""
    base, hacia = Vector(base), Vector(hacia)
    medio = base.lerp(hacia, 0.55)
    T.cilindro(bm, base, medio, radio, 16)
    for t in (0.08, 0.47):
        p = base.lerp(hacia, t)
        T.cilindro(bm, p, p + (hacia - base).normalized() * 0.02, radio * 1.18, 16)
    T.cilindro(bm, medio, hacia, radio * 0.5, 12)
    for p, r in ((base, radio * 0.9), (hacia, radio * 0.7)):
        T.bloque_redondo(bm, p, Vector((r, r * 0.6, r * 0.6)), 0.5, 10, 6)


def _engranaje(bm, centro, eje, radio, dientes=12, ancho=0.05):
    eje = Vector(eje).normalized()
    T.cilindro(bm, centro - eje * ancho / 2, centro + eje * ancho / 2, radio, 24)
    T.cilindro(bm, centro + eje * ancho / 2, centro + eje * (ancho / 2 + 0.015), radio * 0.4, 12)
    giro = eje.to_track_quat("Z", "Y").to_matrix()
    for i in range(dientes):
        a = 2 * math.pi * i / dientes
        d = giro @ Vector((math.cos(a), math.sin(a), 0))
        T.caja(bm, centro + d * radio, Vector((0.03, 0.03, ancho * 0.9)), giro @ _g(math.degrees(a), "Z"))


def d_casco():
    """Casco de soldador: cáscara oxidada, marco del visor levantado, mentonera, bisagras a los
    costados, cresta arriba, cubrenuca atrás y remaches en el borde y en el marco."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.012, 0.015, 0.012))
    frente = hc.y - m.y
    vz = hc.z + hm.z * 0.1

    def cascara(bm):
        T.bloque_redondo(bm, hc + Vector((0, 0.005, 0.01)), m, 0.3, 32, 20)
        T.caja(bm, Vector((hc.x, hc.y + 0.01, hmax.z + 0.02)), Vector((0.05, m.y * 1.7, 0.035)))  # cresta
        T.caja(bm, Vector((hc.x, hc.y + m.y + 0.01, hc.z - m.z * 0.75)), Vector((m.x * 1.6, 0.03, m.z * 0.5)), _g(-15, "X"))  # cubrenuca
        for s in (-1, 1):  # marco del visor
            T.caja(bm, Vector((hc.x + s * hm.x * 0.78, frente - 0.012, vz)), Vector((0.04, 0.03, hm.z * 0.55)))
            T.caja(bm, Vector((hc.x, frente - 0.012, vz + s * hm.z * 0.25)), Vector((hm.x * 1.6, 0.03, 0.04)))
        T.caja(bm, Vector((hc.x, frente - 0.006, hc.z - hm.z * 0.5)), Vector((hm.x * 1.2, 0.03, hm.z * 0.35)))  # mentonera

    def visor(bm):
        T.caja(bm, Vector((hc.x, frente - 0.01, vz)), Vector((hm.x * 1.4, 0.02, hm.z * 0.38)))

    def metal(bm):
        _anillo_remaches(bm, hc, m.x + 0.002, m.y + 0.002, hc.z - m.z * 0.7, 16, 0.014)
        for sx in (-1, 1):
            for sz in (-1, 1):
                T.remache(bm, Vector((hc.x + sx * hm.x * 0.78, frente - 0.03, vz + sz * hm.z * 0.25)), 0.013)
            p = Vector((hc.x + sx * (m.x + 0.005), hc.y, vz))
            T.cilindro(bm, p, p + Vector((sx * 0.035, 0, 0)), 0.045, 16)  # bisagra
            T.remache(bm, p + Vector((sx * 0.037, 0, 0)), 0.02, (sx, 0, 0))

    return T.pieza_separada(f"{NOMBRE}_Casco", "Head", [("oxido", cascara), ("neon-aviso", visor), ("acero", metal)])


def d_arnes():
    """Musculosa de cuero con correas cruzadas; placas oxidadas en capas (pecho, panza, trapecios);
    columna de 6 vértebras con aletas y luz cian; 2 tubos de líquido rojo con abrazaderas."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03
    atras = tc.y + tm.y + 0.03
    vertebras = [tmax.z - 0.06 - i * (tm.z * 1.8 / 6) for i in range(6)]
    caminos = []
    for s in (-1, 1):
        caminos.append(
            [
                Vector((tc.x + s * 0.07, atras + 0.03, tc.z - tm.z * 0.2)),
                Vector((tc.x + s * tm.x * 0.35, atras + 0.07, tc.z + tm.z * 0.15)),
                Vector((tc.x + s * tm.x * 0.6, atras + 0.06, tc.z + tm.z * 0.5)),
                Vector((tc.x + s * tm.x * 0.85, tc.y + tm.y * 0.7, tmax.z + 0.04)),
                Vector((tc.x + s * tm.x * 0.95, tc.y + tm.y * 0.2, tmax.z + 0.06)),
                Vector((tc.x + s * (tm.x + 0.06), tc.y, tmax.z + 0.02)),
            ]
        )

    def musculosa(bm):
        _trapecio(bm, tc, tm.x * 2 + 0.16, tm.x * 2 + 0.02, tm.y * 2 + 0.05, tm.z * 2 + 0.02)
        for s in (-1, 1):  # correas en X por delante y por detrás
            for y in (frente - 0.035, atras + 0.005):
                T.caja(bm, Vector((tc.x, y, tc.z)), Vector((0.06, 0.015, tm.z * 2.2)), _g(s * 32, "Y"))

    def placas(bm):
        for s in (-1, 1):
            _placa(bm, Vector((tc.x + s * tm.x * 0.5, frente - 0.04, tc.z + tm.z * 0.4)), Vector((tm.x * 0.85, 0.03, tm.z * 0.6)), _g(s * -8, "Y"))
            for k, d in enumerate((0.0, 0.06)):  # trapecios en dos capas
                c = Vector((tc.x + s * (tm.x + 0.04 - d), tc.y, tmax.z + 0.02 + k * 0.03))
                T.caja(bm, c, Vector((tm.x * (1.1 - k * 0.3), tm.y * 2 + 0.12 - k * 0.04, 0.08)), _g(s * -14, "Y"))
        for k in range(3):  # panza en 3 tiras
            _placa(bm, Vector((tc.x, frente - 0.035, tc.z - tm.z * (0.2 + k * 0.28))), Vector((tm.x * (1.1 - k * 0.12), 0.025, tm.z * 0.22)))

    def metal(bm):
        for z in vertebras:
            T.caja(bm, Vector((tc.x, atras + 0.02, z)), Vector((0.12, 0.05, 0.065)))
            for s in (-1, 1):
                T.punta(bm, Vector((tc.x + s * 0.06, atras + 0.03, z)), Vector((tc.x + s * 0.13, atras + 0.025, z - 0.015)), 0.025, 4)
            T.cilindro(bm, Vector((tc.x, atras + 0.02, z - 0.035)), Vector((tc.x, atras + 0.02, z - 0.075)), 0.025, 10)
        for s in (-1, 1):  # remaches de las placas del pecho
            for dx in (-0.35, 0.35):
                for dz in (0.15, 0.62):
                    T.remache(bm, Vector((tc.x + s * tm.x * (0.5 + dx), frente - 0.075, tc.z + tm.z * dz)), 0.012)
        for camino in caminos:  # abrazaderas de los tubos
            for t in (1, 3, 4):
                d = (camino[t + 1] - camino[t]).normalized()
                T.cilindro(bm, camino[t] - d * 0.015, camino[t] + d * 0.015, 0.042, 12)
        T.bloque_redondo(bm, Vector((tc.x, atras + 0.04, tc.z - tm.z * 0.2)), Vector((0.1, 0.035, 0.06)), 0.4, 12, 8)  # bomba

    def luces(bm):
        for z in vertebras:
            T.caja(bm, Vector((tc.x, atras + 0.05, z)), Vector((0.07, 0.008, 0.022)))

    def liquido(bm):
        for camino in caminos:
            T.tubo(bm, camino, 0.03, 12)

    return T.pieza_separada(
        f"{NOMBRE}_Arnes",
        "UpperTorso",
        [("cuero", musculosa), ("oxido", placas), ("acero", metal), ("neon-cian", luces), ("liquido-rojo", liquido)],
    )


def d_brazos():
    """Por brazo: manga oxidada con aros, pistón grande afuera del brazo y otro adelante del
    antebrazo (cada pistón es su propia malla, para animarlo), engranaje en el codo y mangueras."""
    objs = []
    for lado, hueso in T._lados("UpperArm"):
        amin, amax, ac, am = T.caja_parte(hueso)
        bajo = hueso.replace("Upper", "Lower")
        bmin, bmax, bc, bm_ = T.caja_parte(bajo)
        afuera = 1 if ac.x > 0 else -1
        x = ac.x + afuera * (am.x + 0.09)
        yb = bc.y - bm_.y - 0.08

        def manga(bm, ac=ac, am=am, amin=amin, amax=amax):
            T.bloque_redondo(bm, ac, am + Vector((0.05, 0.05, 0.02)), 0.4, 24, 14)
            for z in (amax.z - 0.05, amin.z + 0.05):
                T.cilindro(bm, Vector((ac.x, ac.y, z - 0.02)), Vector((ac.x, ac.y, z + 0.02)), max(am.x, am.y) + 0.075, 20)

        def piston(bm, amin=amin, amax=amax, ac=ac, x=x):
            _piston(bm, Vector((x, ac.y, amax.z - 0.04)), Vector((x, ac.y, amin.z + 0.02)), 0.075)

        def metal(bm, ac=ac, am=am, amax=amax, afuera=afuera):
            for dz in (0.25, -0.25):
                for dy in (-1, 1):
                    T.remache(bm, Vector((ac.x + afuera * (am.x + 0.06), ac.y + dy * am.y * 0.6, ac.z + am.z * dz)), 0.014, (afuera, 0, 0))
            for zz in (amax.z - 0.04, ac.z - am.z * 0.9):  # soportes del pistón
                T.caja(bm, Vector((ac.x + afuera * (am.x + 0.06), ac.y, zz)), Vector((0.06, 0.05, 0.035)))

        def manguera(bm, ac=ac, am=am, amax=amax, bc=bc, bm_=bm_, afuera=afuera):
            y = ac.y + am.y + 0.05
            for k in (-1, 1):
                xx = ac.x + k * 0.04
                camino = [
                    Vector((xx, y - 0.02, amax.z)),
                    Vector((xx + afuera * 0.02, y + 0.04, ac.z + 0.1)),
                    Vector((xx + afuera * 0.03, y + 0.05, ac.z - 0.1)),
                    Vector((bc.x + k * 0.04, bc.y + bm_.y + 0.05, bc.z + 0.05)),
                ]
                T.tubo(bm, camino, 0.018, 8)

        objs += T.pieza_separada(f"{NOMBRE}_Brazo{lado}", hueso, [("oxido", manga), ("negro", manguera), ("acero", metal)])
        objs += T.pieza_separada(f"{NOMBRE}_PistonBrazo{lado}", hueso, [("acero", piston)])

        def manga_baja(bm, bc=bc, bm_=bm_, bmin=bmin):
            T.bloque_redondo(bm, bc, bm_ + Vector((0.06, 0.06, 0.02)), 0.4, 24, 14)
            T.cilindro(bm, Vector((bc.x, bc.y, bmin.z + 0.02)), Vector((bc.x, bc.y, bmin.z + 0.07)), max(bm_.x, bm_.y) + 0.085, 20)
            _placa(bm, Vector((bc.x, bc.y - bm_.y - 0.065, bc.z + bm_.z * 0.3)), Vector((bm_.x * 1.4, 0.02, bm_.z * 0.8)))

        def metal_bajo(bm, bmax=bmax, bc=bc, bm_=bm_, afuera=afuera):
            _engranaje(bm, Vector((bc.x + afuera * (bm_.x + 0.07), bc.y, bmax.z - 0.02)), (afuera, 0, 0), 0.085)
            for dz in (-0.6, 0.0):  # soportes del pistón
                T.caja(bm, Vector((bc.x, bc.y - bm_.y - 0.08, bc.z + bm_.z * dz)), Vector((0.11, 0.04, 0.03)))

        def piston_bajo(bm, bmin=bmin, bmax=bmax, bc=bc, y=yb):
            _piston(bm, Vector((bc.x, y - 0.03, bmax.z - 0.06)), Vector((bc.x, y - 0.03, bmin.z + 0.03)), 0.07)

        objs += T.pieza_separada(f"{NOMBRE}_Antebrazo{lado}", bajo, [("oxido", manga_baja), ("acero", metal_bajo)])
        objs += T.pieza_separada(f"{NOMBRE}_PistonAntebrazo{lado}", bajo, [("acero", piston_bajo)])
    return objs


def d_punos():
    """Puño-martillo de acero con ranuras de dedos y muñequera, placa oxidada en los nudillos y
    4 remaches grandes."""
    objs = []
    for lado, hueso in T._lados("Hand"):
        mmin, mmax, mc, mm = T.caja_parte(hueso)
        delante = mc.y - mm.y - 0.09

        def bloque(bm, mc=mc, mm=mm, mmin=mmin, mmax=mmax, delante=delante):
            T.bloque_redondo(bm, mc, mm + Vector((0.09, 0.09, 0.06)), 0.2, 20, 12)
            for k in (-1, 0, 1):  # ranuras entre los dedos
                T.caja(bm, Vector((mc.x + k * mm.x * 0.6, delante - 0.005, mc.z - mm.z * 0.3)), Vector((0.012, 0.02, mm.z * 1.1)))
            T.cilindro(bm, Vector((mc.x, mc.y, mmax.z + 0.02)), Vector((mc.x, mc.y, mmax.z + 0.08)), max(mm.x, mm.y) + 0.1, 20)
            for i in range(4):
                x = mc.x + (i - 1.5) * (mm.x * 2 + 0.08) / 4.5
                T.remache(bm, Vector((x, delante - 0.03, mmin.z + 0.08)), 0.035)

        def nudillos(bm, mc=mc, mm=mm, mmin=mmin, delante=delante):
            _placa(bm, Vector((mc.x, delante - 0.012, mmin.z + 0.08)), Vector((mm.x * 2 + 0.12, 0.025, 0.11)))

        objs += T.pieza_separada(f"{NOMBRE}_Puno{lado}", hueso, [("acero", bloque), ("oxido", nudillos)])
    return objs


def d_piernas():
    """Pantalón de trabajo con rodilleras de cuero y bolsillos, cinturón con hebilla, botas con
    suela gruesa, cordones y punta de acero remachada."""
    objs = []
    _, lmax, lc, lm = T.caja_parte("LowerTorso")

    def cadera(bm):
        T.bloque_redondo(bm, lc, lm + Vector((0.025, 0.025, 0.01)), 0.25, 20, 10)

    def cinturon(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lmax.z - 0.035)), Vector((lm.x + 0.035, lm.y + 0.035, 0.03)), 0.3, 24, 6)

    def hebilla(bm):
        _placa(bm, Vector((lc.x, lc.y - lm.y - 0.06, lmax.z - 0.035)), Vector((0.12, 0.02, 0.07)), borde=0.008)

    objs += T.pieza_separada(f"{NOMBRE}_Cadera", "LowerTorso", [("tela-oscura", cadera)])
    objs += T.pieza_separada(f"{NOMBRE}_Cinturon", "LowerTorso", [("cuero", cinturon), ("acero", hebilla)])
    for lado, hueso in T._lados("UpperLeg"):
        _, _, c, m = T.caja_parte(hueso)
        afuera = 1 if c.x > 0 else -1

        def muslo(bm, c=c, m=m, afuera=afuera):
            T.bloque_redondo(bm, c, m + Vector((0.03, 0.03, 0.01)), 0.3, 20, 10)
            T.caja(bm, Vector((c.x + afuera * (m.x + 0.035), c.y, c.z - m.z * 0.1)), Vector((0.03, m.y * 1.3, m.z * 0.8)))  # bolsillo

        objs += T.pieza_separada(f"{NOMBRE}_Muslo{lado}", hueso, [("tela-oscura", muslo)])
        bajo = hueso.replace("Upper", "Lower")
        _, pmax, pc, pm = T.caja_parte(bajo)

        def pierna(bm, pc=pc, pm=pm):
            T.bloque_redondo(bm, pc, pm + Vector((0.03, 0.03, 0.01)), 0.3, 20, 10)

        def rodillera(bm, pc=pc, pm=pm, pmax=pmax):
            T.bloque_redondo(bm, Vector((pc.x, pc.y - pm.y - 0.04, pmax.z - 0.06)), Vector((pm.x * 0.9, 0.03, 0.09)), 0.5, 16, 8)

        objs += T.pieza_separada(f"{NOMBRE}_Pierna{lado}", bajo, [("tela-oscura", pierna), ("cuero", rodillera)])
    for lado, hueso in T._lados("Foot"):
        fmin, fmax, fc, fm = T.caja_parte(hueso)

        def bota(bm, fc=fc, fm=fm, fmin=fmin, fmax=fmax):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.01)), fm + Vector((0.03, 0.06, 0.03)), 0.25, 20, 12)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.03, fmin.z + 0.015)), Vector((fm.x + 0.045, fm.y + 0.085, 0.02)), 0.3, 20, 4)  # suela
            for k in range(4):  # cordones
                z = fmax.z - 0.02 - k * 0.035
                T.caja(bm, Vector((fc.x, fc.y - fm.y - 0.035, z)), Vector((fm.x * 0.9, 0.015, 0.012)), _g(15 if k % 2 else -15, "Y"))

        def punta(bm, fc=fc, fm=fm, fmin=fmin):
            p = Vector((fc.x, fc.y - fm.y - 0.06, fmin.z + 0.07))
            T.bloque_redondo(bm, p, Vector((fm.x + 0.04, 0.055, 0.06)), 0.45, 20, 10)
            for dx in (-0.6, 0.0, 0.6):
                T.remache(bm, p + Vector((dx * fm.x, -0.055, 0.02)), 0.012)

        objs += T.pieza_separada(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota), ("acero", punta)])
    return objs


PIEZAS = (
    ("Casco", "Casco"),
    ("Arnes", "Arnes"),
    ("Brazos", "Brazo"),
    ("Brazos", "Antebrazo"),
    ("Brazos", "Piston"),
    ("Punos", "Puno"),
    ("Piernas", "Cadera"),
    ("Piernas", "Cinturon"),
    ("Piernas", "Muslo"),
    ("Piernas", "Pierna"),
    ("Piernas", "Bota"),
)


def _pieza_de(nombre_obj):
    """Remache_PistonBrazoIzq -> Brazos (para el presupuesto)."""
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
    with open(os.path.join(B.RENDERS, "remache_triangulos.md"), "w", encoding="utf-8") as f:
        f.write(
            "# Remache: triángulos por pieza\n\nEscala del jefe: 1,6x el maniquí R15.\n\n" + texto + "\n\n"
            "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
            "linajes/arte/blender/texturas/remache/. Las de neón y el líquido rojo no llevan textura.\n"
            "Los pistones son mallas aparte (PistonBrazo, PistonAntebrazo) para poder animarlos.\n"
        )
    return texto


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    agrandar()
    for armar in (d_casco, d_arnes, d_brazos, d_punos, d_piernas):
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    brazo = [o for o in piezas if _pieza_de(o.name) in ("Brazos", "Punos") and "Der" in o.name]
    brazo += [B.parte(n) for n in ("RightUpperArm", "RightLowerArm", "RightHand")]
    B.render_primer_plano(f"{prefijo}_brazo", brazo, giro=-70, altura=10, margen=1.6)
    espalda = [o for o in piezas if _pieza_de(o.name) == "Arnes"] + [B.parte("UpperTorso")]
    B.render_primer_plano(f"{prefijo}_columna", espalda, giro=200, altura=15, margen=1.0)
    normal = maniqui_normal()
    print("Render:", B.render_vistas(prefijo, B.partes() + piezas + normal))
    for o in normal:
        bpy.data.objects.remove(o)


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_remache_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, "remache")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, "remache")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/remache/."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    rutas = B.exportar_piezas("remache", piezas_detalle())
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
