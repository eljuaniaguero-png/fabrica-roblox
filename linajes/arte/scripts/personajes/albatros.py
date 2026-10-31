"""El Albatros: jefe mafioso de Puerto Óxido, dueño del contrabando (ficha de Juani del 31 oct).

Diseño propio: sin smoking ni frac, sin monóculo, sin paraguas, sin nariz ganchuda. Silueta: bajo y
ancho, abrigo largo de capitán de barco hasta las pantorrillas, gorra de capitán y bastón-arpón.
El maniquí va escalado 1,2x de ancho y 0,9x de alto (ESCALA) y las piezas se hacen para ese tamaño.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/albatros.py -- boceto

Paso "boceto": bloques sin detalle, render de 3 vistas con un maniquí normal al costado para
comparar (renders/albatros_boceto_vistas.png).
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

NOMBRE = "Albatros"
BLEND = os.path.join(B.BLENDER, "albatros.blend")
ESCALA = (1.2, 1.2, 0.9)  # ancho, profundidad, alto

# Presupuesto de triángulos por pieza (ficha, total ≤ 24.000).
PRESUPUESTO = {
    "Gorra": 3000,
    "Abrigo": 11000,
    "Bufanda": 2000,
    "Baston": 3000,
    "GuantesBotas": 4000,
    "Emblema": 500,
}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def achaparrar():
    """Escala el esqueleto: más ancho y más bajo (las partes del cuerpo siguen a los huesos)."""
    B.esqueleto().scale = ESCALA
    bpy.context.view_layer.update()


def maniqui_normal(corrida=-0.9):
    """Copia del maniquí a tamaño normal, corrida a la izquierda, solo para comparar en el render."""
    inversa = Matrix.Diagonal((*(1 / e for e in ESCALA), 1))
    copias = []
    for o in B.partes():
        c = o.copy()
        c.data = o.data.copy()
        c.name = "Comparar_" + o.name
        c.parent = None
        bpy.context.scene.collection.objects.link(c)
        c.matrix_world = Matrix.Translation((corrida, 0, 0)) @ inversa @ o.matrix_world
        copias.append(c)
    return copias


def _ovalo(bm, base, hacia, rx_abajo, rx_arriba, prof):
    """Cono truncado de sección ovalada (prof = cuánto se achata en Y, 1 = redondo)."""
    hechos = T.cilindro(bm, base, hacia, rx_abajo, 24, rx_arriba)
    for v in hechos:
        v.co.y = base[1] + (v.co.y - base[1]) * prof
    return hechos


def _albatros(bm, centro, ancho, giro=None):
    """Emblema propio: albatros visto de frente con las alas abiertas y largas, un poco caídas en
    la punta (forma de M aplanada). `giro` lo orienta (por defecto mira a -Y)."""
    giro = giro or Matrix.Identity(3)
    g = ancho / 2
    T.caja(bm, centro, Vector((g * 0.14, 0.012, g * 0.5)), giro)  # cuerpo
    T.caja(bm, centro + giro @ Vector((0, 0, g * 0.32)), Vector((g * 0.12, 0.012, g * 0.12)), giro)  # cabeza
    for s in (-1, 1):
        T.caja(bm, centro + giro @ Vector((s * g * 0.32, 0, g * 0.08)), Vector((g * 0.55, 0.012, g * 0.12)), giro @ _g(s * -12, "Y"))
        T.caja(bm, centro + giro @ Vector((s * g * 0.76, 0, g * 0.04)), Vector((g * 0.48, 0.012, g * 0.09)), giro @ _g(s * 14, "Y"))


# ---------------------------------------------------------------------------
# Boceto (paso 1)
# ---------------------------------------------------------------------------


def gorra():
    """Gorra de capitán: copa ancha y plana, banda, visera negra y ancla de oro al frente."""
    _, hmax, hc, hm = T.caja_parte("Head")
    z_banda = hmax.z - hm.z * 0.35

    def copa(bm):
        _ovalo(bm, Vector((hc.x, hc.y, z_banda)), Vector((hc.x, hc.y, hmax.z + 0.09)), hm.x + 0.02, hm.x + 0.09, 1.0)

    def banda(bm):
        T.cilindro(bm, Vector((hc.x, hc.y, z_banda - 0.02)), Vector((hc.x, hc.y, z_banda + 0.05)), hm.x + 0.03, 24)

    def visera(bm):
        T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.06, z_banda - 0.01)), Vector((hm.x * 1.7, 0.14, 0.025)), _g(-12, "X"))

    def ancla(bm):
        f = Vector((hc.x, hc.y - hm.x - 0.05, z_banda + 0.1))
        T.caja(bm, f, Vector((0.018, 0.015, 0.09)))
        T.caja(bm, f + Vector((0, 0, 0.03)), Vector((0.06, 0.015, 0.015)))
        T.caja(bm, f - Vector((0, 0, 0.045)), Vector((0.07, 0.015, 0.018)))

    return T.pieza(f"{NOMBRE}_Gorra", "Head", [("azul-marino-oscuro", copa), ("negro", banda), ("negro", visera), ("oro", ancla)])


def abrigo():
    """Abrigo de capitán: torso ancho, cuello de piel gris, 2 filas de botones de oro, charreteras
    con flecos y faldón hasta las pantorrillas. Mangas aparte."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    lmin, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, pc, _ = T.caja_parte("LeftLowerLeg")
    frente = tc.y - tm.y - 0.05

    def torso(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.06, 0.06, 0.03)), 0.3, 20, 12)

    def cuello(bm):
        T.tubo(bm, [Vector((tc.x + math.cos(a) * (tm.x + 0.05), tc.y + math.sin(a) * (tm.y + 0.07), tmax.z + 0.01)) for a in [i * math.pi / 8 for i in range(17)]], 0.07, 10, False)

    def botones(bm):
        for s in (-1, 1):
            for i in range(4):
                T.remache(bm, Vector((tc.x + s * tm.x * 0.38, frente - 0.005, tmax.z - 0.12 - i * tm.z * 0.42)), 0.025)

    def charreteras(bm):
        for s in (-1, 1):
            h = Vector((tc.x + s * (tm.x + 0.08), tc.y, tmax.z + 0.02))
            T.bloque_redondo(bm, h, Vector((0.13, 0.12, 0.03)), 0.4, 16, 8)
            for i in range(7):  # flecos
                a = math.pi * i / 6
                p = h + Vector((s * math.sin(a) * 0.12, math.cos(a) * 0.11, -0.02))
                T.cilindro(bm, p, p - Vector((0, 0, 0.08)), 0.012, 6)

    def faldon(bm):
        abajo = pc.z - 0.05
        _ovalo(bm, Vector((lc.x, lc.y, abajo)), Vector((lc.x, lc.y, lmin.z + lm.z * 2 + 0.02)), lm.x + 0.24, lm.x + 0.08, 0.75)

    return T.pieza(
        f"{NOMBRE}_Abrigo",
        "UpperTorso",
        [("azul-marino", torso), ("azul-marino", faldon), ("piel-gris", cuello), ("oro", botones), ("oro", charreteras)],
    )


def mangas():
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)
            extra = Vector((0.04, 0.04, 0.01)) if "Upper" in parte else Vector((0.06, 0.06, 0.0))

            def manga(bm, c=c, m=m, extra=extra):
                T.bloque_redondo(bm, c, m + extra, 0.35, 16, 8)

            nombre = "Manga" if "Upper" in parte else "Puno"
            piezas.append(T.pieza(f"{NOMBRE}_{nombre}{lado}", parte, [("azul-marino", manga)]))
    return piezas


def bufanda():
    """Bufanda blanca: vuelta al cuello y dos puntas que caen por delante, sobre el abrigo."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")

    def vuelta(bm):
        T.tubo(bm, [Vector((tc.x + math.cos(a) * (tm.x * 0.42), tc.y + math.sin(a) * (tm.y * 0.75), tmax.z + 0.05)) for a in [i * 2 * math.pi / 16 for i in range(17)]], 0.045, 10, False)

    def puntas(bm):
        for s, largo in ((-1, 0.42), (1, 0.32)):
            T.caja(bm, Vector((tc.x + s * 0.07, tc.y - tm.y - 0.09, tmax.z - largo / 2)), Vector((0.11, 0.025, largo)), _g(s * 6, "Y"))

    return T.pieza(f"{NOMBRE}_Bufanda", "UpperTorso", [("tela-blanca", vuelta), ("tela-blanca", puntas)])


def baston():
    """Bastón-arpón en la mano derecha: asta de madera hasta el piso, punta de arpón de acero con
    dos púas arriba y cadena enrollada en el tercio de arriba."""
    _, _, mc, mm = T.caja_parte("RightHand")
    afuera = 1 if mc.x > 0 else -1
    abajo = Vector((mc.x + afuera * 0.06, mc.y - 0.16, 0.0))
    arriba = Vector((abajo.x, abajo.y, mc.z + 0.75))

    def asta(bm):
        T.cilindro(bm, abajo, arriba, 0.04, 10)

    def arpon(bm):
        T.punta(bm, arriba, arriba + Vector((0, 0, 0.3)), 0.07, 4)
        for s in (-1, 1):
            T.punta(bm, arriba + Vector((s * 0.04, 0, 0.08)), arriba + Vector((s * 0.13, 0, -0.05)), 0.03, 4)
        T.cilindro(bm, arriba - Vector((0, 0, 0.06)), arriba, 0.04, 10)

    def cadena(bm):
        n = 40
        T.tubo(bm, [arriba - Vector((0, 0, 0.1 + 0.3 * i / n)) + Vector((math.cos(i * 0.9) * 0.045, math.sin(i * 0.9) * 0.045, 0)) for i in range(n + 1)], 0.012, 6)

    return T.pieza(f"{NOMBRE}_Baston", "RightHand", [("madera-oscura", asta), ("acero", arpon), ("acero", cadena)])


def guantes_botas():
    piezas = []
    for lado, hueso in T._lados("Hand"):
        _, _, c, m = T.caja_parte(hueso)

        def guante(bm, c=c, m=m):
            T.bloque_redondo(bm, c, m + Vector((0.025, 0.025, 0.02)), 0.4, 14, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso, [("cuero", guante)]))
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)
        _, _, pc, pm = T.caja_parte(hueso.replace("Foot", "LowerLeg"))

        def bota(bm, fc=fc, fm=fm, pc=pc, pm=pm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.01)), fm + Vector((0.03, 0.06, 0.03)), 0.3, 16, 8)
            T.bloque_redondo(bm, pc - Vector((0, 0, pm.z * 0.3)), Vector((pm.x + 0.04, pm.y + 0.04, pm.z * 0.75)), 0.4, 16, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota)]))
    return piezas


def emblema():
    """Albatros de oro en la espalda del abrigo (el de la gorra va en la gorra, en lugar del ancla
    si Juani prefiere: por ahora se ven los dos)."""
    _, _, tc, tm = T.caja_parte("UpperTorso")

    def espalda(bm):
        _albatros(bm, Vector((tc.x, tc.y + tm.y + 0.075, tc.z + tm.z * 0.25)), tm.x * 1.6, _g(180, "Z"))

    def pecho(bm):  # chico, en el pecho izquierdo
        _albatros(bm, Vector((tc.x + tm.x * 0.6, tc.y - tm.y - 0.075, tc.z + tm.z * 0.55)), 0.16)

    def gorra(bm):
        _, hmax, hc, hm = T.caja_parte("Head")
        _albatros(bm, Vector((hc.x, hc.y - hm.x - 0.07, hmax.z + 0.02)), 0.2)

    return [
        T.pieza(f"{NOMBRE}_Emblema", "UpperTorso", [("oro", espalda), ("oro", pecho)]),
        T.pieza(f"{NOMBRE}_EmblemaGorra", "Head", [("oro", gorra)]),
    ]


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    achaparrar()
    piezas = [gorra(), abrigo(), *mangas(), bufanda(), baston(), *guantes_botas(), *emblema()]
    normal = maniqui_normal()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas("albatros_boceto", B.partes() + piezas + normal))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------

# Prefijo del nombre de la malla -> pieza del presupuesto.
PIEZAS = (
    ("EmblemaGorra", "Emblema"),
    ("Emblema", "Emblema"),
    ("Gorra", "Gorra"),
    ("Abrigo", "Abrigo"),
    ("Manga", "Abrigo"),
    ("Puno", "Abrigo"),
    ("Bufanda", "Bufanda"),
    ("Baston", "Baston"),
    ("Guante", "GuantesBotas"),
    ("Bota", "GuantesBotas"),
)


def _pieza_de(nombre_obj):
    """Albatros_Gorra_Oro -> Gorra (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for prefijo, clave in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def _aro(bm, centro, radio, grosor, normal=(0, 0, 1), lados=8, pasos=16, escala_y=1.0):
    """Anillo cerrado (eslabón, ribete, galón) alrededor de `normal`."""
    giro = Vector((0, 0, 1)).rotation_difference(Vector(normal)).to_matrix()
    camino = [
        Vector(centro) + giro @ Vector((math.cos(a) * radio, math.sin(a) * radio * escala_y, 0))
        for a in [2 * math.pi * i / pasos for i in range(pasos + 1)]
    ]
    T.tubo(bm, camino, grosor, lados, False)


def _albatros_d(bm, centro, ancho, giro=None, grosor=0.012):
    """Emblema con detalle: cuerpo, cabeza con pico, cola en abanico y alas largas de dos tramos
    con 2 plumas separadas en cada punta (plano, sin bisel: entra en 500 triángulos)."""
    giro = giro or Matrix.Identity(3)
    g = ancho / 2

    def plancha(c, tam, rot=None):
        rot = rot or Matrix.Identity(3)
        T.caja(bm, centro + giro @ c, Vector((tam[0], grosor, tam[1])), giro @ rot)

    plancha(Vector((0, 0, 0)), (g * 0.16, g * 0.42))  # cuerpo
    plancha(Vector((0, 0, g * 0.3)), (g * 0.13, g * 0.13))  # cabeza
    T.punta(bm, centro + giro @ Vector((0, 0, g * 0.36)), centro + giro @ Vector((0, 0, g * 0.5)), g * 0.04, 4)  # pico
    for s in (-1, 0, 1):  # cola
        plancha(Vector((s * g * 0.06, 0, -g * 0.28)), (g * 0.07, g * 0.16), _g(s * 18, "Y"))
    for s in (-1, 1):
        plancha(Vector((s * g * 0.3, 0, g * 0.1)), (g * 0.5, g * 0.13), _g(s * -14, "Y"))
        plancha(Vector((s * g * 0.68, 0, g * 0.05)), (g * 0.36, g * 0.1), _g(s * 10, "Y"))
        for k in range(2):  # plumas de la punta
            plancha(Vector((s * g * (0.88 + k * 0.05), 0, -g * (0.03 + k * 0.05))), (g * 0.2, g * 0.04), _g(s * (22 + k * 14), "Y"))


def d_gorra():
    """Gorra de capitán: copa ovalada que se ensancha con costuras, ribete arriba, banda de charol,
    visera curva con borde, cordón de oro con dos botones, y ancla de oro con cepo y argolla."""
    _, hmax, hc, hm = T.caja_parte("Head")
    zb = hmax.z - hm.z * 0.22
    alto = hmax.z + 0.11
    frente = hc.y - hm.x - 0.035

    def copa(bm):
        _ovalo(bm, Vector((hc.x, hc.y, zb + 0.04)), Vector((hc.x, hc.y, alto - 0.03)), hm.x + 0.03, hm.x + 0.1, 0.95)
        T.bloque_redondo(bm, Vector((hc.x, hc.y + 0.005, alto - 0.02)), Vector((hm.x + 0.1, (hm.x + 0.1) * 0.95, 0.03)), 0.6, 32, 10)
        for i in range(8):  # costuras de la copa (gajos)
            a = 2 * math.pi * i / 8
            p0 = Vector((hc.x + math.cos(a) * (hm.x + 0.035), hc.y + math.sin(a) * (hm.x + 0.035) * 0.95, zb + 0.045))
            p1 = Vector((hc.x + math.cos(a) * (hm.x + 0.105), hc.y + math.sin(a) * (hm.x + 0.105) * 0.95, alto - 0.035))
            T.tubo(bm, [p0, p1], 0.005, 4)

    def charol(bm):
        T.cilindro(bm, Vector((hc.x, hc.y, zb - 0.02)), Vector((hc.x, hc.y, zb + 0.05)), hm.x + 0.035, 32)
        # visera: media luna lisa con espesor, que sale de la banda y cae un poco hacia adelante
        r = hm.x + 0.035
        adentro, afuera = [], []
        for i in range(17):
            a = math.radians(-75 + i * 150 / 16)
            sale = 0.13 * math.cos(a) ** 1.5
            adentro.append(Vector((hc.x + math.sin(a) * r, hc.y - math.cos(a) * r, zb - 0.015)))
            afuera.append(Vector((hc.x + math.sin(a) * (r + sale), hc.y - math.cos(a) * (r + sale), zb - 0.015 - sale * 0.3)))
        capas = []
        for dz in (0.0, -0.018):
            capas.append([bm.verts.new(p + Vector((0, 0, dz))) for p in adentro] + [bm.verts.new(p + Vector((0, 0, dz))) for p in reversed(afuera)])
        arriba, abajo = capas
        bm.faces.new(arriba)
        bm.faces.new(list(reversed(abajo)))
        for k in range(len(arriba)):
            q = (k + 1) % len(arriba)
            bm.faces.new((arriba[q], arriba[k], abajo[k], abajo[q]))
        T.tubo(bm, [p + Vector((0, 0, -0.009)) for p in afuera], 0.011, 6)  # borde de la visera

    def oro(bm):
        _aro(bm, Vector((hc.x, hc.y, alto - 0.035)), hm.x + 0.1, 0.008, pasos=32, escala_y=0.95)  # ribete
        for s in (-1, 1):  # cordón doble a cada lado del ancla, con botón en la punta
            camino = [Vector((hc.x + s * k * (hm.x + 0.03), frente + 0.005 + k * k * 0.04, zb + 0.03)) for k in (1, 0.6, 0.25)]
            T.tubo(bm, camino, 0.007, 6)
            T.tubo(bm, [p + Vector((0, 0, -0.016)) for p in camino], 0.007, 6)
            T.remache(bm, camino[0] + Vector((s * 0.01, 0, -0.008)), 0.016, (s, -0.3, 0))
        f = Vector((hc.x, frente - 0.012, zb + 0.015))  # ancla chica en la banda (arriba va el albatros)
        T.cilindro(bm, f + Vector((0, 0, 0.03)), f - Vector((0, 0, 0.03)), 0.006, 8)
        T.caja(bm, f + Vector((0, 0, 0.018)), Vector((0.035, 0.008, 0.008)))
        _aro(bm, f + Vector((0, 0, 0.038)), 0.008, 0.003, (0, 1, 0), 5, 10)
        T.tubo(bm, [f + Vector((math.sin(a) * 0.028, -0.004, -0.014 - math.cos(a) * 0.018)) for a in [math.radians(x) for x in range(-80, 81, 20)]], 0.005, 6)
        for s in (-1, 1):
            T.punta(bm, f + Vector((s * 0.027, -0.004, -0.018)), f + Vector((s * 0.031, -0.004, 0.0)), 0.007, 4)

    return T.pieza_separada(f"{NOMBRE}_Gorra", "Head", [("azul-marino-oscuro", copa), ("charol", charol), ("oro", oro)])


def d_abrigo():
    """Abrigo cruzado de capitán: torso con solapas en capas, faldón hasta las pantorrillas con
    abertura adelante, tajo atrás y bolsillos con tapa, cinturón de cuero, cuello alto de piel
    gris, 2 filas de 5 botones de oro, charreteras con flecos y galones de oro en los puños."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    lmin, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, pc, _ = T.caja_parte("LeftLowerLeg")
    frente = tc.y - tm.y - 0.06
    atras = tc.y + tm.y + 0.06
    abajo = pc.z - 0.05
    z_cint = lmin.z + lm.z * 2 + 0.01

    def torso(bm):
        T.bloque_redondo(bm, tc + Vector((0, 0, 0.01)), tm + Vector((0.06, 0.06, 0.04)), 0.3, 32, 18)
        for s in (-1, 1):  # solapas: dos capas cruzadas
            T.caja(bm, Vector((tc.x + s * tm.x * 0.42, frente - 0.012, tmax.z - tm.z * 0.45)), Vector((tm.x * 0.5, 0.02, tm.z * 0.85)), _g(s * -16, "Y"))
            T.caja(bm, Vector((tc.x + s * tm.x * 0.48, frente - 0.025, tmax.z - tm.z * 0.3)), Vector((tm.x * 0.36, 0.012, tm.z * 0.45)), _g(s * -22, "Y"))
        T.caja(bm, Vector((tc.x + tm.x * 0.05, frente - 0.006, tc.z)), Vector((0.02, 0.012, tm.z * 1.9)))  # borde cruzado

    def faldon(bm):
        hechos = _ovalo(bm, Vector((lc.x, lc.y, abajo)), Vector((lc.x, lc.y, z_cint)), lm.x + 0.25, lm.x + 0.08, 0.78)
        for v in hechos:  # ondas suaves de la tela
            if v.co.z < z_cint - 0.05:
                a = math.atan2(v.co.y - lc.y, v.co.x - lc.x)
                v.co += Vector((math.cos(a), math.sin(a), 0)) * 0.018 * math.sin(a * 7)
        for s in (-1, 1):  # bordes de la abertura, tajo de atrás y tapas de los bolsillos
            T.caja(bm, Vector((lc.x + s * 0.035, lc.y - (lm.y + 0.14), (abajo + z_cint) / 2)), Vector((0.025, 0.02, z_cint - abajo)), _g(s * 6, "Y") @ _g(-12, "X"))
            T.caja(bm, Vector((lc.x + s * 0.02, lc.y + lm.y + 0.13, (abajo + z_cint) / 2 - 0.05)), Vector((0.02, 0.02, (z_cint - abajo) * 0.7)), _g(12, "X"))
            T.caja(bm, Vector((lc.x + s * (lm.x + 0.06), lc.y - lm.y - 0.12, z_cint - 0.1)), Vector((0.16, 0.02, 0.06)), _g(-14, "X") @ _g(s * -20, "Z"))
        _aro(bm, Vector((lc.x, lc.y, abajo + 0.02)), lm.x + 0.26, 0.012, pasos=40, escala_y=0.78)  # dobladillo

    def cuero(bm):
        _aro(bm, Vector((lc.x, lc.y, z_cint)), lm.x + 0.08, 0.03, lados=4, pasos=32, escala_y=0.82)

    def piel(bm):
        pts = []
        for i in range(25):
            a = -math.pi * 0.1 + i * math.pi * 1.2 / 24
            pts.append(Vector((tc.x + math.cos(a) * (tm.x + 0.04), tc.y + math.sin(a) * (tm.y + 0.08), tmax.z + 0.03 + 0.04 * math.sin(a))))
        T.tubo(bm, pts, [0.06 + 0.015 * math.sin(i * 1.7) for i in range(25)], 12, True)
        T.tubo(bm, [p + Vector((0, 0, 0.06)) for p in pts[3:22]], [0.045 + 0.01 * math.cos(i * 2.1) for i in range(19)], 10, True)
        for s in (-1, 1):  # el cuello baja por las solapas
            camino = [
                Vector((tc.x + s * tm.x * 0.6, frente + 0.01, tmax.z)),
                Vector((tc.x + s * tm.x * 0.45, frente - 0.02, tmax.z - tm.z * 0.6)),
                Vector((tc.x + s * tm.x * 0.3, frente - 0.02, tc.z - tm.z * 0.2)),
            ]
            T.tubo(bm, camino, [0.05, 0.035, 0.015], 10)

    def oro(bm):
        for s in (-1, 1):
            for i in range(5):
                p = Vector((tc.x + s * tm.x * 0.42, frente - 0.025, tmax.z - 0.14 - i * tm.z * 0.36))
                T.cilindro(bm, p + Vector((0, 0.006, 0)), p - Vector((0, 0.006, 0)), 0.024, 8)
                T.remache(bm, p - Vector((0, 0.008, 0)), 0.015)
            h = Vector((tc.x + s * (tm.x + 0.08), tc.y, tmax.z + 0.03))  # charretera
            T.bloque_redondo(bm, h, Vector((0.13, 0.12, 0.025)), 0.5, 20, 8)
            _aro(bm, h + Vector((0, 0, 0.02)), 0.1, 0.01, pasos=20)
            T.remache(bm, h + Vector((-s * 0.06, 0, 0.03)), 0.018, (0, 0, 1))
            for i in range(8):  # flecos
                a = math.pi * i / 7
                p = h + Vector((s * math.sin(a) * 0.125, math.cos(a) * 0.115, -0.015))
                T.tubo(bm, [p, p + Vector((s * 0.01, 0, -0.05)), p + Vector((s * 0.015, 0, -0.1))], [0.009, 0.008, 0.006], 4)
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.1, z_cint)), Vector((0.08, 0.02, 0.07)))  # hebilla
        for s in (-1, 1):  # botones del tajo de atrás
            T.remache(bm, Vector((lc.x + s * 0.06, atras + 0.02, z_cint - 0.02)), 0.02, (0, 1, 0))
        for _, hueso in T._lados("LowerArm"):  # galones del puño
            bmin, _, bc, bm_ = T.caja_parte(hueso)
            for k in range(2):
                _aro(bm, Vector((bc.x, bc.y, bmin.z + 0.05 + k * 0.04)), max(bm_.x, bm_.y) + 0.075, 0.009, lados=5, pasos=14)

    return T.pieza_separada(
        f"{NOMBRE}_Abrigo",
        "UpperTorso",
        [("azul-marino", torso), ("azul-marino", faldon), ("piel-gris", piel), ("oro", oro), ("cuero", cuero)],
    )


def d_mangas():
    """Mangas anchas con pliegues en el codo y puño vuelto."""
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            pmin, _, c, m = T.caja_parte(parte)
            arriba = "Upper" in parte

            def manga(bm, c=c, m=m, pmin=pmin, arriba=arriba):
                extra = Vector((0.045, 0.045, 0.01)) if arriba else Vector((0.06, 0.06, 0.0))
                T.bloque_redondo(bm, c, m + extra, 0.35, 16, 10)
                if arriba:
                    for k in range(3):  # pliegues del codo
                        _aro(bm, Vector((c.x, c.y, pmin.z + 0.03 + k * 0.035)), max(m.x, m.y) + 0.05, 0.012, lados=6, pasos=12)
                else:  # puño vuelto
                    T.bloque_redondo(bm, Vector((c.x, c.y, pmin.z + 0.06)), Vector((m.x + 0.08, m.y + 0.08, 0.06)), 0.5, 16, 8)

            nombre = "Manga" if arriba else "Puno"
            piezas.append(T.pieza(f"{NOMBRE}_{nombre}{lado}", parte, [("azul-marino", manga)]))
    return piezas


def d_bufanda():
    """Bufanda blanca de lana: dos vueltas al cuello con nudo, puntas de distinto largo con ondas
    y flecos."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.09

    def lana(bm):
        for k, (r, z) in enumerate(((0.42, 0.05), (0.38, 0.1))):
            pts = [
                Vector((tc.x + math.cos(a) * tm.x * r, tc.y + math.sin(a) * tm.y * 0.75, tmax.z + z + 0.012 * math.sin(a * 3 + k)))
                for a in [i * 2 * math.pi / 20 for i in range(21)]
            ]
            T.tubo(bm, pts, 0.042, 8, False)
        T.bloque_redondo(bm, Vector((tc.x + 0.03, frente - 0.02, tmax.z + 0.02)), Vector((0.06, 0.04, 0.05)), 0.5, 12, 8)  # nudo
        for s, largo in ((-1, 0.42), (1, 0.3)):
            centro = Vector((tc.x + s * 0.06, frente - 0.03, tmax.z - 0.02 - largo / 2))
            for v in T.bloque_redondo(bm, centro, Vector((0.055, 0.016, largo / 2)), 0.25, 12, 14):
                t = (centro.z + largo / 2 - v.co.z) / largo  # 0 arriba, 1 abajo: ondas de la tela
                v.co.x += s * 0.02 * math.sin(t * 5)
                v.co.y -= 0.02 * math.sin(t * 3)
                v.co.x = centro.x + (v.co.x - centro.x) * (1 + 0.15 * t)
            for f in range(6):  # flecos
                p = Vector((tc.x + s * 0.06 + (f - 2.5) * 0.018, frente - 0.03, tmax.z - 0.02 - largo))
                T.tubo(bm, [p, p - Vector((0, 0, 0.05))], 0.005, 4)

    return T.pieza(f"{NOMBRE}_Bufanda", "UpperTorso", [("tela-blanca", lana)])


def d_baston():
    """Bastón-arpón: asta de madera con mango forrado en cuero, regatón de acero abajo, virola,
    punta de arpón con nervio y dos púas hacia atrás, argolla y cadena de eslabones enrollada."""
    _, _, mc, _ = T.caja_parte("RightHand")
    afuera = 1 if mc.x > 0 else -1
    abajo = Vector((mc.x + afuera * 0.06, mc.y - 0.16, 0.0))
    arriba = Vector((abajo.x, abajo.y, mc.z + 0.75))

    def asta(bm):
        T.cilindro(bm, abajo + Vector((0, 0, 0.06)), arriba - Vector((0, 0, 0.06)), 0.04, 14, 0.034)

    def cuero(bm):
        for k in range(6):  # mango forrado (vueltas inclinadas)
            _aro(bm, Vector((abajo.x, abajo.y, mc.z - 0.1 + k * 0.04)), 0.042, 0.01, (0.15, 0, 1), 5, 10)

    def acero(bm):
        T.cilindro(bm, abajo, abajo + Vector((0, 0, 0.07)), 0.03, 14, 0.043)  # regatón
        T.cilindro(bm, arriba - Vector((0, 0, 0.08)), arriba, 0.042, 14)  # virola
        for z in (-0.075, -0.005):
            _aro(bm, arriba + Vector((0, 0, z)), 0.045, 0.006, pasos=14)
        T.cilindro(bm, arriba, arriba + Vector((0, 0, 0.06)), 0.03, 12, 0.022)
        T.punta(bm, arriba + Vector((0, 0, 0.06)), arriba + Vector((0, 0, 0.34)), 0.07, 4)  # hoja
        T.caja(bm, arriba + Vector((0, 0, 0.14)), Vector((0.012, 0.03, 0.14)))  # nervio
        for s in (-1, 1):
            T.punta(bm, arriba + Vector((s * 0.045, 0, 0.1)), arriba + Vector((s * 0.15, 0, -0.04)), 0.028, 4)
        _aro(bm, arriba + Vector((-afuera * 0.06, 0, 0.0)), 0.025, 0.007, (0, 1, 0), 6, 12)  # argolla
        n = 12  # cadena: eslabones alternados en espiral alrededor del asta
        for i in range(n):
            a = i * 0.85
            p = arriba - Vector((0, 0, 0.12 + 0.36 * i / n)) + Vector((math.cos(a) * 0.05, math.sin(a) * 0.05, 0))
            radial = Vector((math.cos(a), math.sin(a), 0))
            tangente = Vector((-math.sin(a), math.cos(a), -0.3)).normalized()
            _aro(bm, p, 0.02, 0.006, tangente.cross(radial) if i % 2 else radial, 4, 8, 1.5)
        for k in range(4):  # cadena que cuelga de la argolla
            p = arriba - Vector((0, 0, 0.5 + k * 0.045)) + Vector((-afuera * 0.06, 0, 0))
            _aro(bm, p, 0.02, 0.006, (1, 0, 0) if k % 2 else (0, 1, 0), 4, 8, 1.5)

    return T.pieza_separada(f"{NOMBRE}_Baston", "RightHand", [("madera-oscura", asta), ("cuero", cuero), ("acero", acero)])


def d_guantes_botas():
    """Guantes de cuero con puño ancho y nudillos; botas de marinero altas con suela, caña
    doblada, cordones y punta reforzada."""
    piezas = []
    for lado, hueso in T._lados("Hand"):
        mmin, mmax, c, m = T.caja_parte(hueso)

        def guante(bm, c=c, m=m, mmin=mmin, mmax=mmax):
            T.bloque_redondo(bm, c, m + Vector((0.025, 0.025, 0.02)), 0.4, 16, 8)
            r = max(m.x, m.y)
            T.cilindro(bm, Vector((c.x, c.y, mmax.z - 0.01)), Vector((c.x, c.y, mmax.z + 0.07)), r + 0.04, 16, r + 0.06)
            _aro(bm, Vector((c.x, c.y, mmax.z + 0.07)), r + 0.06, 0.01, lados=5, pasos=12)
            for k in range(4):  # nudillos
                T.remache(bm, Vector((c.x + (k - 1.5) * m.x * 0.5, c.y - m.y - 0.025, mmin.z + 0.07)), 0.02)

        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso, [("cuero", guante)]))
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)
        _, _, pc, pm = T.caja_parte(hueso.replace("Foot", "LowerLeg"))

        def bota(bm, fc=fc, fm=fm, fmin=fmin, pc=pc, pm=pm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.015)), fm + Vector((0.03, 0.06, 0.025)), 0.35, 16, 10)
            T.bloque_redondo(bm, pc - Vector((0, 0, pm.z * 0.3)), Vector((pm.x + 0.04, pm.y + 0.04, pm.z * 0.75)), 0.4, 16, 10)
            T.bloque_redondo(bm, pc + Vector((0, 0, pm.z * 0.45)), Vector((pm.x + 0.055, pm.y + 0.055, 0.04)), 0.5, 16, 6)  # caña doblada
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.03, fmin.z + 0.012)), Vector((fm.x + 0.04, fm.y + 0.075, 0.014)), 0.15, 16, 4)  # suela
            T.bloque_redondo(bm, Vector((fc.x, fc.y - fm.y - 0.07, fmin.z + 0.05)), Vector((fm.x + 0.03, 0.03, 0.04)), 0.5, 12, 6)  # punta
            for k in range(4):  # cordones
                T.caja(bm, Vector((fc.x, pc.y - pm.y - 0.045, fmin.z + 0.08 + k * 0.04)), Vector((pm.x * 1.1, 0.008, 0.008)), _g(20 if k % 2 else -20, "Y"))

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota)]))
    return piezas


def d_emblema():
    """Albatros de oro: grande en la espalda, chico en el pecho y en la gorra (sobre el ancla)."""
    _, _, tc, tm = T.caja_parte("UpperTorso")
    _, hmax, hc, hm = T.caja_parte("Head")

    def torso(bm):
        _albatros_d(bm, Vector((tc.x, tc.y + tm.y + 0.075, tc.z + tm.z * 0.25)), tm.x * 1.6, _g(180, "Z"))
        _albatros_d(bm, Vector((tc.x + tm.x * 0.62, tc.y - tm.y - 0.075, tc.z + tm.z * 0.6)), 0.15, grosor=0.008)

    def gorra(bm):
        _albatros_d(bm, Vector((hc.x, hc.y - (hm.x + 0.07) * 0.95 - 0.006, hmax.z - hm.z * 0.22 + 0.085)), 0.17, grosor=0.008)

    return [
        T.pieza(f"{NOMBRE}_Emblema", "UpperTorso", [("oro", torso)]),
        T.pieza(f"{NOMBRE}_EmblemaGorra", "Head", [("oro", gorra)]),
    ]


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
    with open(os.path.join(B.RENDERS, "albatros_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# El Albatros: triángulos por pieza\n\nEscala: 1,2x de ancho y 0,9x de alto el maniquí R15.\n\n" + texto + "\n")
    return texto


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    achaparrar()
    for armar in (d_gorra, d_abrigo, d_mangas, d_bufanda, d_baston, d_guantes_botas, d_emblema):
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    gorra = [o for o in piezas if _pieza_de(o.name) == "Gorra" or "EmblemaGorra" in o.name] + [B.parte("Head")]
    B.render_primer_plano(f"{prefijo}_gorra", gorra, giro=25, altura=12, margen=1.3)
    arpon = [o for o in piezas if _pieza_de(o.name) == "Baston" and o.name != f"{NOMBRE}_Baston"]  # punta, cadena y mango
    B.render_primer_plano(f"{prefijo}_baston", arpon, giro=-35, altura=8, margen=1.0)
    espalda = [o for o in piezas if o.name == f"{NOMBRE}_Emblema"] + [B.parte("UpperTorso")]
    B.render_primer_plano(f"{prefijo}_emblema", espalda, giro=180, altura=8, margen=1.15)
    print("Render:", B.render_vistas(prefijo, B.partes() + piezas))


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_albatros_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    # El emblema es una plancha fina de oro: sin bisel (con bisel no entra en 500 triángulos).
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items() if clave != "Emblema"}
    D.terminar(piezas, grupos, "albatros")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, "albatros")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/albatros/."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    rutas = B.exportar_piezas("albatros", piezas_detalle())
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
