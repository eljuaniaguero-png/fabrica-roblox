"""Tano: mecánico del taller, NPC civil (no superhéroe).

Mameluco azul engrasado, delantal de cuero, trapo rojo colgando del bolsillo de atrás, gorra de
trabajo, bigote canoso y llave inglesa en la mano derecha. Presupuesto de NPC con nombre:
12.000 a 20.000 triángulos en total (GUIA-ESTILO), cada malla ≤ 20.000.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/npcs/tano.py -- boceto

Paso "boceto": bloques sin detalle y render de 3 vistas (renders/npc-tano_boceto_vistas.png).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Tano"
ARCHIVO = "npc-tano"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")

# Presupuesto de triángulos por pieza (total 12.000 a 20.000).
PRESUPUESTO = {
    "Mameluco": 8500,
    "Delantal": 3000,
    "Gorra": 2500,
    "Bigote": 1600,
    "Trapo": 800,
    "Llave": 1000,
    "Botas": 2600,
}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def mameluco():
    """Mono enterizo: torso con cuello volcado, cierre al frente, bolsillo en el pecho y cinturón
    de tela. Mangas y perneras aparte (cada una sigue a su hueso)."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    frente = tc.y - tm.y - 0.035

    def torso(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.035, 0.035, 0.02)), 0.3, 20, 12)
        T.bloque_redondo(bm, lc, lm + Vector((0.04, 0.04, 0.02)), 0.3, 20, 10)

    def cuello(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * 0.09, frente - 0.01, tmax.z - 0.05)), Vector((0.12, 0.02, 0.1)), _g(s * 25, "Y"))

    def cierre(bm):
        T.caja(bm, Vector((tc.x, frente - 0.005, tc.z)), Vector((0.025, 0.012, tm.z * 1.9)))

    def bolsillo(bm):
        T.caja(bm, Vector((tc.x - tm.x * 0.5, frente - 0.008, tc.z + tm.z * 0.35)), Vector((0.16, 0.015, 0.16)))

    def cinto(bm):
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.6)), Vector((lm.x + 0.05, lm.y + 0.05, 0.035)), 0.5, 20, 6)

    return T.pieza(
        f"{NOMBRE}_Mameluco",
        "UpperTorso",
        [("mameluco", torso), ("mameluco", cuello), ("acero", cierre), ("mameluco", bolsillo), ("mameluco", cinto)],
    )


def mangas_perneras():
    piezas = []
    for base, nombre in (("UpperArm", "Manga"), ("UpperLeg", "Pernera")):
        for lado, hueso in T._lados(base):
            for parte in (hueso, hueso.replace("Upper", "Lower")):
                _, _, c, m = T.caja_parte(parte)
                extra = Vector((0.035, 0.035, 0.01))
                # Mangas arremangadas: el antebrazo queda con la piel al aire y un rollo de tela.
                if nombre == "Manga" and "Lower" in parte:

                    def rollo(bm, c=c, m=m):
                        z = c.z + m.z * 0.75
                        T.cilindro(bm, Vector((c.x, c.y, z - 0.05)), Vector((c.x, c.y, z + 0.05)), max(m.x, m.y) + 0.05, 14)

                    piezas.append(T.pieza(f"{NOMBRE}_Rollo{lado}", parte, [("mameluco", rollo)]))
                    continue

                def tela(bm, c=c, m=m, extra=extra):
                    T.bloque_redondo(bm, c, m + extra, 0.35, 16, 8)

                sufijo = "Arriba" if "Upper" in parte else "Abajo"
                piezas.append(T.pieza(f"{NOMBRE}_{nombre}{sufijo}{lado}", parte, [("mameluco", tela)]))
    return piezas


def delantal():
    """Delantal de cuero: pechera desde el pecho hasta las rodillas, tira al cuello y bolsillo
    grande con herramientas asomando."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, pc, _ = T.caja_parte("LeftUpperLeg")
    frente = tc.y - tm.y - 0.06
    arriba = tmax.z - 0.12
    abajo = pc.z - 0.15

    def pechera(bm):
        T.caja(bm, Vector((tc.x, frente, (arriba + tc.z) / 2)), Vector((tm.x * 1.3, 0.02, arriba - tc.z)))
        alto = tc.z - abajo
        T.caja(bm, Vector((tc.x, frente - 0.03, tc.z - alto / 2)), Vector((tm.x * 2.0, 0.02, alto)), _g(-6, "X"))

    def tiras(bm):
        T.tubo(bm, [Vector((tc.x + math.cos(a) * 0.16, tc.y + math.sin(a) * (tm.y + 0.05), tmax.z + 0.02)) for a in [math.pi + i * math.pi / 8 for i in range(-1, 10)]], 0.015, 6, False)

    def bolsillo(bm):
        T.caja(bm, Vector((tc.x, frente - 0.06, tc.z - (tc.z - abajo) * 0.35)), Vector((tm.x * 1.2, 0.025, 0.2)), _g(-6, "X"))
        for i, dx in enumerate((-0.12, -0.04, 0.06)):  # mangos de herramientas
            T.cilindro(bm, Vector((tc.x + dx, frente - 0.065, tc.z - 0.06)), Vector((tc.x + dx, frente - 0.065, tc.z + 0.04 + i * 0.03)), 0.018, 8)

    return T.pieza(f"{NOMBRE}_Delantal", "UpperTorso", [("cuero-claro", pechera), ("cuero-claro", tiras), ("cuero-claro", bolsillo)])


def trapo():
    """Trapo rojo metido en el bolsillo de atrás del lado derecho, colgando."""
    _, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, rc, _ = T.caja_parte("RightUpperLeg")
    atras = lc.y + lm.y + 0.05

    def tela(bm):
        T.caja(bm, Vector((rc.x, atras, lc.z - 0.12)), Vector((0.16, 0.02, 0.32)), _g(8, "Y") @ _g(10, "X"))
        T.caja(bm, Vector((rc.x + 0.02, atras + 0.01, lc.z + 0.06)), Vector((0.1, 0.03, 0.06)))

    return T.pieza(f"{NOMBRE}_Trapo", "LowerTorso", [("trapo-rojo", tela)])


def gorra():
    """Gorra de trabajo: copa redondeada, visera curva hacia adelante y botón arriba."""
    _, hmax, hc, hm = T.caja_parte("Head")
    z0 = hmax.z - hm.z * 0.3

    def copa(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, z0 + hm.z * 0.3)), Vector((hm.x + 0.025, hm.y + 0.025, hm.z * 0.42)), 0.7, 20, 10)

    def visera(bm):
        T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.08, z0 + 0.02)), Vector((hm.x * 1.5, 0.17, 0.02)), _g(8, "X"))

    def boton(bm):
        T.remache(bm, Vector((hc.x, hc.y, hmax.z + 0.07)), 0.02, (0, 0, 1))

    return T.pieza(f"{NOMBRE}_Gorra", "Head", [("mameluco", copa), ("mameluco", visera), ("mameluco", boton)])


def bigote():
    """Bigote canoso tupido, con las puntas caídas."""
    _, _, hc, hm = T.caja_parte("Head")
    y = hc.y - hm.y - 0.015
    z = hc.z - hm.z * 0.3

    def pelo(bm):
        for s in (-1, 1):
            T.bloque_redondo(bm, Vector((hc.x + s * 0.06, y, z)), Vector((0.07, 0.025, 0.03)), 0.6, 12, 6)
            T.bloque_redondo(bm, Vector((hc.x + s * 0.12, y + 0.005, z - 0.04)), Vector((0.025, 0.02, 0.04)), 0.6, 10, 6)

    return T.pieza(f"{NOMBRE}_Bigote", "Head", [("canoso", pelo)])


def llave():
    """Llave inglesa grande en la mano derecha, apuntando hacia abajo."""
    _, _, mc, mm = T.caja_parte("RightHand")
    arriba = Vector((mc.x, mc.y - 0.02, mc.z + 0.05))
    abajo = arriba - Vector((0, 0, 0.5))

    def mango(bm):
        T.caja(bm, (arriba + abajo) / 2, Vector((0.05, 0.03, 0.5)))

    def boca(bm):
        T.caja(bm, abajo - Vector((0, 0, 0.03)), Vector((0.16, 0.035, 0.06)))
        for s in (-1, 1):
            T.caja(bm, abajo + Vector((s * 0.06, 0, -0.09)), Vector((0.04, 0.035, 0.1)))

    return T.pieza(f"{NOMBRE}_Llave", "RightHand", [("acero", mango), ("acero", boca)])


def botas():
    piezas = []
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)

        def bota(bm, fc=fc, fm=fm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.01)), fm + Vector((0.03, 0.05, 0.03)), 0.3, 16, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("cuero", bota)]))
    return piezas


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [mameluco(), *mangas_perneras(), delantal(), trapo(), gorra(), bigote(), llave(), *botas()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas(ARCHIVO + "_boceto", B.partes() + piezas))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------

# Prefijo del nombre de la malla -> pieza del presupuesto.
PIEZAS = (
    ("Mameluco", "Mameluco"),
    ("Manga", "Mameluco"),
    ("Rollo", "Mameluco"),
    ("Pernera", "Mameluco"),
    ("Delantal", "Delantal"),
    ("Gorra", "Gorra"),
    ("Bigote", "Bigote"),
    ("Trapo", "Trapo"),
    ("Llave", "Llave"),
    ("Bota", "Botas"),
)


def _pieza_de(nombre_obj):
    """Tano_MangaArribaIzq -> Mameluco (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for prefijo, clave in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def _aro(bm, centro, radio, grosor, normal=(0, 0, 1), lados=6, pasos=24, escala_y=1.0):
    """Anillo cerrado (dobladillo, banda, ojal) alrededor de `normal`."""
    giro = Vector((0, 0, 1)).rotation_difference(Vector(normal)).to_matrix()
    camino = [
        Vector(centro) + giro @ Vector((math.cos(a) * radio, math.sin(a) * radio * escala_y, 0))
        for a in [2 * math.pi * i / pasos for i in range(pasos + 1)]
    ]
    T.tubo(bm, camino, grosor, lados, False)


def _lamina(bm, punto, nu, nv, grosor, afuera=(0, -1, 0)):
    """Lámina con espesor (cuero, tela): `punto(u, v)` con u, v en 0-1 da la cara de afuera; la de
    adentro se corre `grosor` hacia el lado contrario de `afuera`. Bordes cerrados."""
    atras = -Vector(afuera) * grosor
    frente = [[bm.verts.new(punto(i / nu, j / nv)) for i in range(nu + 1)] for j in range(nv + 1)]
    dorso = [[bm.verts.new(v.co + atras) for v in fila] for fila in frente]
    for j in range(nv):
        for i in range(nu):
            bm.faces.new((frente[j][i], frente[j][i + 1], frente[j + 1][i + 1], frente[j + 1][i]))
            bm.faces.new((dorso[j][i], dorso[j + 1][i], dorso[j + 1][i + 1], dorso[j][i + 1]))
    borde = [(0, i) for i in range(nu)] + [(j, nu) for j in range(nv)] + [(nv, i) for i in range(nu, 0, -1)] + [(j, 0) for j in range(nv, 0, -1)]
    for k, (j, i) in enumerate(borde):
        j2, i2 = borde[(k + 1) % len(borde)]
        bm.faces.new((frente[j][i], dorso[j][i], dorso[j2][i2], frente[j2][i2]))


def _contorno(punto, nu, nv, adentro=0.0):
    """Puntos del borde de una lámina, un poco hacia adentro (para la costura que la rodea)."""
    a = adentro
    uv = [(a + (1 - 2 * a) * k / nu, a) for k in range(nu + 1)]
    uv += [(1 - a, a + (1 - 2 * a) * k / nv) for k in range(1, nv + 1)]
    uv += [(1 - a - (1 - 2 * a) * k / nu, 1 - a) for k in range(1, nu + 1)]
    uv += [(a, 1 - a - (1 - 2 * a) * k / nv) for k in range(1, nv + 1)]
    return [punto(u, v) for u, v in uv]


def d_mameluco():
    """Mono enterizo: torso y cadera redondeados, cuello volcado, cierre con dientes y tirador,
    bolsillo de pecho con tapa y botón, canesú atrás, cinturón de tela con presillas y hebilla."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    frente = tc.y - tm.y - 0.035
    zc = lc.z + lm.z * 0.6
    bp = Vector((tc.x - tm.x * 0.78, frente - 0.01, tc.z + tm.z * 0.3))

    def tela(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.035, 0.035, 0.02)), 0.3, 32, 16)
        T.bloque_redondo(bm, lc, lm + Vector((0.04, 0.04, 0.02)), 0.3, 32, 12)
        for s in (-1, 1):  # cuello volcado: dos puntas que caen sobre el pecho
            T.caja(bm, Vector((tc.x + s * 0.09, frente - 0.012, tmax.z - 0.05)), Vector((0.13, 0.018, 0.11)), _g(s * 28, "Y") @ _g(-8, "X"))
        T.tubo(bm, [Vector((tc.x + math.cos(a) * (tm.x * 0.55), tc.y + math.sin(a) * (tm.y + 0.04), tmax.z + 0.01)) for a in [i * 2 * math.pi / 20 for i in range(21)]], 0.025, 8, False)
        T.caja(bm, bp, Vector((0.13, 0.015, 0.15)))  # bolsillo de pecho con tapa y pespunte
        T.caja(bm, bp + Vector((0, -0.012, 0.065)), Vector((0.14, 0.02, 0.05)), _g(-10, "X"))
        T.tubo(bm, _contorno(lambda u, v: bp + Vector((-0.06 + 0.12 * u, -0.009, -0.07 + 0.11 * v)), 4, 4), 0.004, 4, False)
        T.bloque_redondo(bm, Vector((lc.x, lc.y, zc)), Vector((lm.x + 0.05, lm.y + 0.05, 0.035)), 0.5, 32, 6)  # cinturón
        for a in (0.6, 2.54, 3.74, 5.68):  # presillas
            p = Vector((lc.x + math.cos(a) * (lm.x + 0.06), lc.y + math.sin(a) * (lm.y + 0.06), zc))
            T.caja(bm, p, Vector((0.025, 0.012, 0.09)), _g(math.degrees(a) + 90, "Z"))
        canesu = [Vector((tc.x + x, tc.y + tm.y + 0.04, tmax.z - 0.12 - abs(x) * 0.25)) for x in [tm.x * (-0.95 + 1.9 * k / 10) for k in range(11)]]
        T.tubo(bm, canesu, 0.006, 4)
        for s in (-1, 1):  # costuras de los costados
            T.tubo(bm, [Vector((tc.x + s * (tm.x + 0.05), tc.y, z)) for z in (tmax.z - 0.15, tc.z, tmin.z + 0.02)], 0.006, 4)

    def metal(bm):
        z0, z1 = tmax.z - 0.04, lc.z
        T.caja(bm, Vector((tc.x, frente - 0.004, (z0 + z1) / 2)), Vector((0.03, 0.012, z0 - z1)))
        n = 22
        for i in range(n):  # dientes del cierre
            z = z1 + (z0 - z1) * (i + 0.5) / n
            T.caja(bm, Vector((tc.x + (0.008 if i % 2 else -0.008), frente - 0.012, z)), Vector((0.02, 0.008, 0.009)))
        t = Vector((tc.x, frente - 0.02, z0 - 0.09))  # tirador
        T.caja(bm, t, Vector((0.025, 0.012, 0.035)))
        T.caja(bm, t - Vector((0, 0.006, 0.045)), Vector((0.02, 0.008, 0.05)))
        T.remache(bm, bp + Vector((0, -0.028, 0.06)), 0.014)  # botón del bolsillo
        h = Vector((lc.x, lc.y - lm.y - 0.095, zc))  # hebilla
        for dz in (-0.035, 0.035):
            T.caja(bm, h + Vector((0, 0, dz)), Vector((0.12, 0.015, 0.015)))
        for s in (-1, 1):
            T.caja(bm, h + Vector((s * 0.053, 0, 0)), Vector((0.015, 0.015, 0.085)))
        T.caja(bm, h, Vector((0.012, 0.018, 0.075)))

    return T.pieza_separada(f"{NOMBRE}_Mameluco", "UpperTorso", [("mameluco", tela), ("acero", metal)])


def d_mangas_perneras():
    """Mangas arremangadas (rollo grueso de tela en el codo) y perneras con rodilleras cosidas,
    bolsillo en el muslo derecho y dobladillo sobre el botín."""
    piezas = []
    for lado, hueso in T._lados("UpperArm"):
        _, _, c, m = T.caja_parte(hueso)

        def manga(bm, c=c, m=m):
            T.bloque_redondo(bm, c + Vector((0, 0, 0.01)), m + Vector((0.035, 0.035, 0.0)), 0.35, 24, 12)

        piezas.append(T.pieza(f"{NOMBRE}_MangaArriba{lado}", hueso, [("mameluco", manga)]))
        abajo = hueso.replace("Upper", "Lower")
        _, _, c, m = T.caja_parte(abajo)

        def rollo(bm, c=c, m=m):
            z = c.z + m.z - 0.05
            T.bloque_redondo(bm, Vector((c.x, c.y, z)), Vector((m.x + 0.05, m.y + 0.05, 0.05)), 0.7, 24, 8)
            _aro(bm, Vector((c.x, c.y, z - 0.01)), max(m.x, m.y) + 0.06, 0.012, pasos=24)  # pliegue del rollo

        piezas.append(T.pieza(f"{NOMBRE}_Rollo{lado}", abajo, [("mameluco", rollo)]))
    for lado, hueso in T._lados("UpperLeg"):
        _, _, c, m = T.caja_parte(hueso)
        lado_x = 1 if c.x > 0 else -1

        def muslo(bm, c=c, m=m, lado_x=lado_x):
            T.bloque_redondo(bm, c, m + Vector((0.04, 0.04, 0.01)), 0.35, 24, 12)
            b = Vector((c.x + lado_x * (m.x + 0.05), c.y, c.z - 0.02))  # bolsillo lateral con tapa
            T.caja(bm, b, Vector((0.02, 0.16, 0.2)))
            T.caja(bm, b + Vector((lado_x * 0.01, 0, 0.09)), Vector((0.025, 0.17, 0.05)))

        piezas.append(T.pieza(f"{NOMBRE}_PerneraArriba{lado}", hueso, [("mameluco", muslo)]))
        abajo = hueso.replace("Upper", "Lower")
        _, _, c, m = T.caja_parte(abajo)

        def pierna(bm, c=c, m=m):
            T.bloque_redondo(bm, c, m + Vector((0.04, 0.04, 0.01)), 0.35, 24, 12)
            T.bloque_redondo(bm, c + Vector((0, -m.y - 0.045, m.z * 0.6)), Vector((m.x * 0.8, 0.015, 0.1)), 0.5, 12, 6)  # rodillera
            _aro(bm, Vector((c.x, c.y, c.z - m.z + 0.05)), max(m.x, m.y) + 0.05, 0.014, pasos=24)  # dobladillo

        piezas.append(T.pieza(f"{NOMBRE}_PerneraAbajo{lado}", abajo, [("mameluco", pierna)]))
    return piezas


def d_delantal():
    """Delantal de cuero curvado sobre el cuerpo: pechera, falda hasta las rodillas que se abre
    abajo, pespunte en todo el borde, bolsillo partido con 3 herramientas, tira al cuello, tira a la
    cintura con moño atrás, hebillas y remaches de acero."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, pc, _ = T.caja_parte("LeftUpperLeg")
    y0 = tc.y - tm.y - 0.055
    arriba = tmax.z - 0.12
    medio = tc.z - 0.05
    abajo = pc.z - 0.18
    zc = lc.z + lm.z * 0.6

    def pechera_p(u, v):
        x = (u - 0.5) * tm.x * 1.0
        return Vector((tc.x + x, y0 + x * x * 0.3, medio + (arriba - medio) * v))

    def falda_p(u, v):
        x = (u - 0.5) * tm.x * 2.05
        return Vector((tc.x + x, y0 - 0.03 - (1 - v) * 0.06 + x * x * 0.3, abajo + (medio - abajo) * v))

    def bolsillo_p(u, v):
        x = (u - 0.5) * tm.x * 1.3
        return Vector((tc.x + x, y0 - 0.062 - 0.01 * (1 - v) + x * x * 0.3, zc - 0.22 + 0.2 * v))

    laminas = ((pechera_p, 8, 6), (falda_p, 10, 10), (bolsillo_p, 8, 4))

    def cuero(bm):
        for punto, nu, nv in laminas:
            _lamina(bm, punto, nu, nv, 0.014)
            T.tubo(bm, [p + Vector((0, -0.004, 0)) for p in _contorno(punto, nu, nv, 0.04)], 0.004, 4, False)
        T.tubo(bm, [bolsillo_p(0.5, v) + Vector((0, -0.004, 0)) for v in (0.05, 0.5, 0.95)], 0.004, 4)
        for s in (-1, 1):  # tira al cuello
            esquina = pechera_p(0.5 + s * 0.45, 1.0)
            T.tubo(bm, [esquina, Vector((tc.x + s * 0.13, tc.y - tm.y * 0.4, tmax.z + 0.03)), Vector((tc.x + s * 0.1, tc.y + tm.y * 0.6, tmax.z + 0.03))], 0.012, 6)
        T.tubo(bm, [Vector((tc.x + math.cos(a) * 0.1, tc.y + tm.y * 0.6 + math.sin(a) * 0.02, tmax.z + 0.03)) for a in [math.pi * k / 6 for k in range(7)]], 0.012, 6)
        cintura = [Vector((lc.x + math.cos(a) * (lm.x + 0.07), lc.y + math.sin(a) * (lm.y + 0.07), zc + 0.05)) for a in [math.radians(x) for x in range(-10, 191, 10)]]
        T.tubo(bm, cintura, 0.01, 6)
        m = Vector((lc.x, lc.y + lm.y + 0.08, zc + 0.05))  # moño
        for s in (-1, 1):
            T.bloque_redondo(bm, m + Vector((s * 0.04, 0, 0)), Vector((0.04, 0.015, 0.025)), 0.6, 10, 6)
            T.caja(bm, m + Vector((s * 0.025, 0.005, -0.08)), Vector((0.025, 0.008, 0.13)), _g(s * 12, "Y"))

    def acero(bm):
        for s in (-1, 1):
            h = pechera_p(0.5 + s * 0.45, 0.93) + Vector((0, -0.012, 0))
            T.caja(bm, h, Vector((0.04, 0.008, 0.035)))
            T.remache(bm, h + Vector((0, -0.006, 0)), 0.008)
            for v in (0.1, 0.9):
                T.remache(bm, bolsillo_p(0.5 + s * 0.47, v) + Vector((0, -0.006, 0)), 0.007)
        for x, alto, ancho in ((-0.13, 0.11, 0.022), (-0.05, 0.09, 0.016), (0.08, 0.14, 0.02)):  # herramientas
            b = bolsillo_p(0.5 + x / (tm.x * 1.3), 0.85) + Vector((0, 0.008, 0))
            T.cilindro(bm, b, b + Vector((0, 0, alto)), ancho, 8)
            T.cilindro(bm, b + Vector((0, 0, alto)), b + Vector((0, 0, alto + 0.04)), ancho * 0.4, 6)

    return T.pieza_separada(f"{NOMBRE}_Delantal", "UpperTorso", [("cuero-claro", cuero), ("acero", acero)])


def d_trapo():
    """Trapo rojo metido en el bolsillo de atrás: arriba arrugado, cae ondulado con la punta corrida."""
    _, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, rc, _ = T.caja_parte("RightUpperLeg")
    y0 = lc.y + lm.y + 0.055
    z0 = lc.z + 0.04

    def p(u, v):
        x = (u - 0.5) * 0.16 * (1 - 0.25 * (1 - v))
        onda = math.sin(u * math.pi * 3 + v * 2) * 0.012 + (1 - v) ** 2 * 0.03
        return Vector((rc.x + x + (1 - v) * 0.03, y0 + onda, z0 - (1 - v) * 0.36))

    def tela(bm):
        _lamina(bm, p, 8, 10, 0.006, (0, 1, 0))
        for k in range(3):  # pliegues arrugados saliendo del bolsillo
            T.bloque_redondo(bm, Vector((rc.x - 0.05 + k * 0.05, y0 + 0.008, z0 + 0.025 + (k % 2) * 0.01)), Vector((0.03, 0.015, 0.03)), 0.7, 10, 6)

    return T.pieza(f"{NOMBRE}_Trapo", "LowerTorso", [("trapo-rojo", tela)])


def d_gorra():
    """Gorra de trabajo: copa de 6 gajos con costuras, botón arriba, banda, ojales de ajuste en la
    nuca y visera curva con espesor y doble pespunte."""
    _, hmax, hc, hm = T.caja_parte("Head")
    zb = hmax.z - hm.z * 0.3
    r = hm.x + 0.03
    ry = hm.y + 0.03
    cz, az = zb + hm.z * 0.12, hm.z * 0.5

    def copa(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, cz)), Vector((r, ry, az)), 0.55, 32, 14)
        for i in range(6):  # costuras de los gajos
            a = 2 * math.pi * i / 6 + math.pi / 2
            T.tubo(bm, [Vector((hc.x + math.cos(a) * r * math.cos(t) * 1.01, hc.y + math.sin(a) * ry * math.cos(t) * 1.01, cz + az * math.sin(t) * 1.01)) for t in [math.radians(x) for x in range(10, 81, 10)]], 0.004, 4)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, cz + az)), Vector((0.025, 0.025, 0.012)), 0.8, 10, 6)  # botón
        _aro(bm, Vector((hc.x, hc.y, zb - 0.005)), r + 0.003, 0.012, pasos=32, escala_y=ry / r)  # banda
        for k in range(4):  # ojales de ajuste
            T.bloque_redondo(bm, Vector((hc.x - 0.06 + k * 0.04, hc.y + ry + 0.01, zb + 0.03)), Vector((0.01, 0.006, 0.01)), 0.8, 8, 4)
        adentro, afuera = [], []
        for i in range(17):  # visera: se arquea hacia abajo en los costados
            a = math.radians(-70 + i * 140 / 16)
            sale = 0.16 * math.cos(a) ** 1.2
            caida = 0.03 * abs(math.sin(a))
            adentro.append(Vector((hc.x + math.sin(a) * r, hc.y - math.cos(a) * (ry + 0.005), zb - caida)))
            afuera.append(Vector((hc.x + math.sin(a) * (r + sale * 0.4), hc.y - math.cos(a) * (ry + 0.005 + sale), zb - caida - 0.025 - sale * 0.1)))
        sup, inf = ([bm.verts.new(q + Vector((0, 0, dz))) for q in adentro + afuera[::-1]] for dz in (0.0, -0.016))
        bm.faces.new(sup)
        bm.faces.new(list(reversed(inf)))
        for k in range(len(sup)):
            q = (k + 1) % len(sup)
            bm.faces.new((sup[q], sup[k], inf[k], inf[q]))
        for f in (0.35, 0.7):  # doble pespunte
            T.tubo(bm, [a_ + (b_ - a_) * f + Vector((0, 0, 0.001)) for a_, b_ in zip(adentro, afuera)], 0.0025, 4)

    return T.pieza(f"{NOMBRE}_Gorra", "Head", [("mameluco", copa)])


def d_bigote():
    """Bigote canoso tupido de morsa: 4 mechones grandes por lado que caen sobre la boca y se abren en las puntas."""
    _, _, hc, hm = T.caja_parte("Head")
    y = hc.y - hm.y - 0.012
    z = hc.z - hm.z * 0.28

    def pelo(bm):
        T.bloque_redondo(bm, Vector((hc.x, y - 0.008, z + 0.01)), Vector((0.05, 0.028, 0.045)), 0.6, 14, 8)
        for s in (-1, 1):
            for k in range(4):
                t = k / 3
                c = Vector((hc.x + s * (0.035 + t * 0.1), y - 0.012 + t * 0.012, z + 0.01 - t * t * 0.055))
                T.bloque_redondo(bm, c, Vector((0.045, 0.026, 0.05 - t * 0.012)), 0.6, 14, 8)

    return T.pieza(f"{NOMBRE}_Bigote", "Head", [("canoso", pelo)])


def d_llave():
    """Llave inglesa grande: mango con rebordes y agujero para colgarla, cabeza con mandíbula fija
    y móvil, tornillo sin fin con roscas."""
    _, _, mc, _ = T.caja_parte("RightHand")
    arriba = Vector((mc.x, mc.y - 0.02, mc.z + 0.06))
    abajo = arriba - Vector((0, 0, 0.48))
    centro = (arriba + abajo) / 2

    def metal(bm):
        T.caja(bm, centro + Vector((0, 0, 0.02)), Vector((0.055, 0.03, 0.44)))
        for s in (-1, 1):
            T.caja(bm, centro + Vector((0, s * 0.018, 0.04)), Vector((0.035, 0.008, 0.32)))
        _aro(bm, arriba, 0.016, 0.006, (0, 1, 0), 6, 12)
        cab = abajo - Vector((0, 0, 0.02))
        T.caja(bm, cab, Vector((0.17, 0.038, 0.07)))
        T.caja(bm, cab + Vector((0.06, 0, -0.1)), Vector((0.045, 0.036, 0.13)))  # mandíbula fija
        T.caja(bm, cab + Vector((-0.045, 0, -0.085)), Vector((0.045, 0.034, 0.1)))  # mandíbula móvil
        t = cab + Vector((-0.01, 0, -0.06))
        T.cilindro(bm, t + Vector((0, -0.022, 0)), t + Vector((0, 0.022, 0)), 0.018, 12)
        for k in range(5):  # roscas
            _aro(bm, t + Vector((0, -0.016 + k * 0.008, 0)), 0.019, 0.003, (0, 1, 0), 4, 12)

    return T.pieza(f"{NOMBRE}_Llave", "RightHand", [("acero", metal)])


def d_botas():
    """Botines de trabajo: capellada con puntera redonda y costura, cordones cruzados, suela
    gruesa con ranuras y taco."""
    piezas = []
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)

        def cuero(bm, fc=fc, fm=fm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.015)), fm + Vector((0.03, 0.05, 0.02)), 0.35, 24, 12)
            T.bloque_redondo(bm, fc + Vector((0, -fm.y - 0.04, 0.0)), Vector((fm.x + 0.025, 0.06, fm.z * 0.75)), 0.6, 16, 8)
            f = fc.y - fm.y * 0.3
            for k in range(4):  # cordones cruzados
                z = fc.z + fm.z * (0.2 + k * 0.35)
                yk = f - 0.07 + k * 0.012
                T.tubo(bm, [Vector((fc.x - 0.045, yk, z)), Vector((fc.x + 0.045, yk, z + 0.02))], 0.006, 4)
                T.tubo(bm, [Vector((fc.x + 0.045, yk, z)), Vector((fc.x - 0.045, yk, z + 0.02))], 0.006, 4)
            T.tubo(bm, [Vector((fc.x + math.sin(a) * (fm.x + 0.035), fc.y - fm.y - 0.04 - math.cos(a) * 0.045, fc.z + 0.01)) for a in [math.radians(x) for x in range(-90, 91, 15)]], 0.004, 4)

        def suela(bm, fc=fc, fm=fm, fmin=fmin):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.03, fmin.z + 0.015)), Vector((fm.x + 0.04, fm.y + 0.075, 0.025)), 0.3, 20, 4)
            T.caja(bm, Vector((fc.x, fc.y + fm.y * 0.55, fmin.z)), Vector((fm.x * 2 + 0.06, fm.y * 0.6, 0.03)))  # taco
            for k in range(6):  # ranuras
                T.caja(bm, Vector((fc.x, fc.y - fm.y - 0.06 + k * 0.05, fmin.z - 0.005)), Vector((fm.x * 2 + 0.05, 0.012, 0.012)))

        piezas += T.pieza_separada(f"{NOMBRE}_Bota{lado}", hueso, [("cuero", cuero), ("negro", suela)])
    return piezas


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


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
    filas.append(f"| **Total** | **{_miles(cuenta['_total'])}** | **{_miles(sum(PRESUPUESTO.values()))}** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {_miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, ARCHIVO + "_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Tano: triángulos por pieza\n\n" + texto + "\n")
    return texto


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_mameluco, d_mangas_perneras, d_delantal, d_trapo, d_gorra, d_bigote, d_llave, d_botas):
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    cara = [o for o in piezas if _pieza_de(o.name) in ("Gorra", "Bigote")] + [B.parte("Head")]
    B.render_primer_plano(f"{prefijo}_cara", cara, giro=25, altura=8, margen=1.3)
    llave_ = [o for o in piezas if _pieza_de(o.name) == "Llave"] + [B.parte("RightHand")]
    B.render_primer_plano(f"{prefijo}_llave", llave_, giro=-35, altura=8, margen=1.1)
    pecho = [o for o in piezas if _pieza_de(o.name) == "Delantal"] + [B.parte("UpperTorso"), B.parte("LowerTorso")]
    B.render_primer_plano(f"{prefijo}_delantal", pecho, giro=20, altura=6, margen=1.1)
    atras = [o for o in piezas if _pieza_de(o.name) == "Trapo"] + [B.parte("LowerTorso")]
    B.render_primer_plano(f"{prefijo}_trapo", atras, giro=160, altura=6, margen=1.4)
    print("Render:", B.render_vistas(prefijo, B.partes() + piezas))


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_npc-tano_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, ARCHIVO, lados={o.name: 512 for o in piezas})  # NPC: texturas de 512 px
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, ARCHIVO)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/npc-tano/."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    rutas = B.exportar_piezas(ARCHIVO, piezas_detalle())
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
