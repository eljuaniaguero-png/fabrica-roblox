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
CANALES = {"C1": "civil-color1", "C2": "civil-color2", "C1o": "civil-color1"}
# Cuánto se oscurece el Color1 para las costuras, dobladillos y bolsillos (C1o). Igual que
# Config.Civiles.Oscuro en el juego.
OSCURO = 0.55

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


# Capas (cuánto sobresale cada cosa del cuerpo, en metros), para que nada atraviese nada:
# cuerpo < pantalón (≤ CAPA_ABAJO) < prenda de arriba en la cadera (CAPA_CADERA) < accesorios.
CAPA_ABAJO = 0.04  # todo lo del pantalón en la cadera queda adentro de esto
CAPA_CADERA = 0.055  # la prenda de arriba tapa la cadera con esto (abierta abajo)


def caja_tela(bm, mn, mx, abierto_abajo=False, abierto_arriba=False):
    """Caja de `mn` a `mx` (esquinas), con la tapa de abajo o de arriba sacada si se pide: así
    otra tela puede entrar por ahí sin atravesar ninguna cara."""
    v = [bm.verts.new(Vector((x, y, z))) for z in (mn.z, mx.z) for y in (mn.y, mx.y) for x in (mn.x, mx.x)]
    caras = [(0, 1, 5, 4), (1, 3, 7, 5), (3, 2, 6, 7), (2, 0, 4, 6)]
    if not abierto_abajo:
        caras.append((0, 2, 3, 1))
    if not abierto_arriba:
        caras.append((4, 5, 7, 6))
    for f in caras:
        bm.faces.new([v[i] for i in f])


def limites(parte, extra, adentro=None):
    """(mín, máx) en x e y de una tela sobre la parte. `adentro` = cuánto se mete la cara que
    mira al cuerpo (mangas: en el R15 el brazo pisa la cadera, así que la manga no se agranda
    hacia ese lado; se mete en el brazo, donde no se ve)."""
    _, _, c, m = P(parte)
    _, _, tc, _ = P("UpperTorso")
    x0, x1 = c.x - m.x - extra[0], c.x + m.x + extra[0]
    if adentro is not None:
        if c.x > tc.x:
            x0 = c.x - m.x + adentro
        else:
            x1 = c.x + m.x - adentro
    return x0, x1, c.y - m.y - extra[1], c.y + m.y + extra[1]


def forro(parte, extra=(0.03, 0.03, 0.01), redondez=0.35, seg=(16, 8), dz=0.0, alto=1.0, arriba=False, abierto_abajo=False, abierto_arriba=False, adentro=None, z_abajo=None):
    """Tela que envuelve una parte del cuerpo. `alto` < 1 la acorta (desde arriba si `arriba`,
    si no desde abajo: manga corta, bermuda). Es una caja de cantos rectos, como las piezas de
    Roblox (Juani no quiere ropa inflada, 1 nov): el bisel lo pone el paso de detalle y `redondez`
    y `seg` quedan solo por compatibilidad. `abierto_abajo`/`abierto_arriba` sacan esa tapa;
    `adentro` mete el lado que mira al cuerpo; `z_abajo` fija el borde de abajo (en mundo)."""
    del redondez, seg

    def armar(bm):
        _, _, c, m = P(parte)
        mz = m.z * alto
        cz = c.z + (m.z - mz if arriba else mz - m.z) + dz
        x0, x1, y0, y1 = limites(parte, extra, adentro)
        z0 = cz - mz - extra[2] if z_abajo is None else z_abajo
        caja_tela(bm, Vector((x0, y0, z0)), Vector((x1, y1, cz + mz + extra[2])), abierto_abajo, abierto_arriba)

    return armar


def caja(parte, d, tam, giro=None):
    """Caja relativa al centro de una parte: `d` y `tam` en fracciones de las mitades + metros."""

    def armar(bm):
        _, _, c, m = P(parte)
        T.caja(bm, c + Vector(d(m)), Vector(tam(m)) if callable(tam) else Vector(tam), giro)

    return armar


# --- Detalles de costura: van en todas las prendas (Juani pidió ropa con detalle, no lisa) ---


def _osc(canal):
    """Las costuras de una tela C1 van en C1o (Color1 oscuro): se leen como líneas pintadas."""
    return "C1o" if canal == "C1" else canal


def ribete(parte, z, extra, alto=0.024, sobra=0.008, adentro=None):
    """Banda finita alrededor de la parte a la altura `z` (en mundo): dobladillo, puño, cintura.
    Sobresale `sobra` de la tela, así se lee como una tira cosida. Es un anillo (abierto arriba y
    abajo): lo que pasa por adentro no lo atraviesa."""

    def armar(bm):
        _, _, c, m = P(parte)
        x0, x1, y0, y1 = limites(parte, (extra[0] + sobra, extra[1] + sobra), adentro)
        zz = z(c, m)
        caja_tela(bm, Vector((x0, y0, zz - alto / 2)), Vector((x1, y1, zz + alto / 2)), True, True)

    return armar


def costura_lado(parte, extra, cara="afuera", ancho=0.012):
    """Línea de costura vertical sobre una cara de la tela (afuera = el costado que mira lejos
    del cuerpo, frente o espalda)."""

    def armar(bm):
        _, _, c, m = P(parte)
        _, _, tc, _ = P("UpperTorso")
        if cara == "afuera":
            s = 1 if c.x > tc.x else -1
            T.caja(bm, Vector((c.x + s * (m.x + extra[0] + 0.003), c.y, c.z)), Vector((ancho, ancho, m.z * 2)))
        else:
            s = -1 if cara == "frente" else 1
            T.caja(bm, Vector((c.x, c.y + s * (m.y + extra[1] + 0.003), c.z)), Vector((ancho, ancho, m.z * 2)))

    return armar


MANGA_ADENTRO = 0.016  # la manga se mete esto en el brazo del lado del cuerpo


def mangas(canal="C1", largo=True, extra=(0.03, 0.03, 0.01), corta=0.55):
    """Mangas con costura del hombro, costura por afuera del brazo y dobladillo en la punta. Del
    lado del cuerpo no se agrandan (ver `limites`) y no bajan de la muñeca."""
    capas = []
    ad = MANGA_ADENTRO
    for lado in ("Left", "Right"):
        arriba_ = f"{lado}UpperArm"
        capas.append((arriba_, canal, forro(arriba_, extra, alto=1.0 if largo else corta, arriba=True, adentro=ad)))
        capas.append((arriba_, _osc(canal), ribete(arriba_, lambda c, m: c.z + m.z - 0.03, extra, adentro=ad)))
        capas.append((arriba_, _osc(canal), costura_lado(arriba_, extra)))
        if largo:
            abajo_ = f"{lado}LowerArm"
            _, _, ca, ma = P(abajo_)
            capas.append((abajo_, canal, forro(abajo_, extra, adentro=ad, z_abajo=ca.z - ma.z + 0.004)))
            capas.append((abajo_, _osc(canal), costura_lado(abajo_, extra)))
            capas.append((abajo_, _osc(canal), ribete(abajo_, lambda c, m: c.z - m.z + 0.024, extra, alto=0.035, adentro=ad)))
        else:
            capas.append((arriba_, _osc(canal), ribete(arriba_, lambda c, m: c.z + m.z - 2 * m.z * corta + 0.015, extra, adentro=ad)))
    return capas


def piernas(canal="C1", extra=(0.03, 0.03, 0.01), corta=None):
    """Perneras con costura por afuera, costura de la rodilla y dobladillo abajo."""
    capas = []
    for lado in ("Left", "Right"):
        muslo = f"{lado}UpperLeg"
        capas.append((muslo, canal, forro(muslo, extra)))
        capas.append((muslo, _osc(canal), costura_lado(muslo, extra)))
        pierna = f"{lado}LowerLeg"
        if corta is None:
            capas.append((pierna, canal, forro(pierna, extra)))
            capas.append((pierna, _osc(canal), costura_lado(pierna, extra)))
            capas.append((pierna, _osc(canal), ribete(pierna, lambda c, m: c.z - m.z + 0.03, extra, alto=0.03)))
            capas.append((pierna, _osc(canal), ribete(pierna, lambda c, m: c.z + m.z - 0.02, extra, alto=0.014, sobra=0.004)))
        elif corta > 0:
            capas.append((pierna, canal, forro(pierna, extra, alto=corta, arriba=True)))
            capas.append((pierna, _osc(canal), ribete(pierna, lambda c, m: c.z + m.z - 2 * m.z * corta + 0.015, extra, alto=0.03)))
        else:
            capas.append((muslo, _osc(canal), ribete(muslo, lambda c, m: c.z - m.z + 0.02, extra, alto=0.03)))
    return capas


def torso(canal="C1", extra=(0.035, 0.035, 0.015), cadera=True):
    """Torso con costuras de los costados, canesú adelante y atrás, costura de la espalda y
    dobladillo abajo."""
    capas = [("UpperTorso", canal, forro("UpperTorso", extra, abierto_abajo=True))]
    for cara in ("frente", "espalda"):

        def canesu(bm, cara=cara):
            _, mx, c, m = P("UpperTorso")
            s = -1 if cara == "frente" else 1
            T.caja(bm, Vector((c.x, c.y + s * (m.y + extra[1] + 0.003), mx.z - 0.09)), Vector((m.x * 2 + extra[0] * 2, 0.012, 0.012)))

        capas.append(("UpperTorso", _osc(canal), canesu))
    capas.append(("UpperTorso", _osc(canal), costura_lado("UpperTorso", extra, "espalda")))
    for s in (-1, 1):

        def costado(bm, s=s):
            _, _, c, m = P("UpperTorso")
            T.caja(bm, Vector((c.x + s * (m.x + extra[0] - 0.006), c.y + m.y + extra[1] - 0.01, c.z)), Vector((0.012, 0.024, m.z * 2)))

        capas.append(("UpperTorso", _osc(canal), costado))
    if cadera:
        capas += cadera_arriba(canal, max(extra[1], CAPA_CADERA))
    else:
        capas.append(("UpperTorso", _osc(canal), ribete("UpperTorso", lambda c, m: c.z - m.z + 0.025, extra, alto=0.03)))
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


def tapeta(dy=0.045, ancho=0.05):
    """Tira vertical al frente donde van los botones o el cierre, con dos costuras."""

    def armar(bm):
        _, _, c, m = P("UpperTorso")
        y = c.y - m.y - dy
        T.caja(bm, Vector((c.x, y, c.z)), Vector((ancho, 0.012, m.z * 2)))
        for s in (-1, 1):
            T.caja(bm, Vector((c.x + s * ancho / 2, y - 0.007, c.z)), Vector((0.006, 0.006, m.z * 2)))

    return armar


def bolsillos_bajos(dy=0.05, tapa=True):
    """Dos bolsillos en la cadera (LowerTorso) con tapa y botón."""

    def armar(bm):
        _, _, c, m = P("LowerTorso")
        for s in (-1, 1):
            b = Vector((c.x + s * m.x * 0.55, c.y - m.y - dy, c.z - m.z * 0.1))
            T.caja(bm, b, Vector((0.16, 0.012, 0.12)))
            if tapa:
                T.caja(bm, b + Vector((0, -0.01, 0.06)), Vector((0.17, 0.014, 0.04)))
                T.remache(bm, b + Vector((0, -0.02, 0.055)), 0.01)

    return armar


def botones_manga(extra=(0.035, 0.035, 0.01), n=3):
    """Botoncitos en la punta de cada manga, del lado de afuera."""
    capas = []
    for lado in ("Left", "Right"):

        def armar(bm, lado=lado):
            _, _, c, m = P(f"{lado}LowerArm")
            _, _, tc, _ = P("UpperTorso")
            s = 1 if c.x > tc.x else -1
            for k in range(n):
                T.remache(bm, Vector((c.x + s * (m.x + extra[0] + 0.004), c.y + 0.03 - k * 0.03, c.z - m.z + 0.09)), 0.009, (s, 0, 0))

        capas.append((f"{lado}LowerArm", "C1", armar))
    return capas


def presillas(dy=0.012):
    """Presillas del cinturón alrededor de la cadera."""

    def armar(bm):
        _, ltx, c, m = P("LowerTorso")
        z = ltx.z - 0.04
        for x in (-0.8, -0.35, 0.35, 0.8):
            T.caja(bm, Vector((c.x + m.x * x, c.y - m.y - dy - 0.01, z)), Vector((0.02, 0.012, 0.07)))
            T.caja(bm, Vector((c.x + m.x * x, c.y + m.y + dy + 0.01, z)), Vector((0.02, 0.012, 0.07)))

    return armar


def puños(canal="C2", alto=0.05):
    """Puño ancho (campera, buzo): anillo abierto en la punta de la manga."""
    return [
        (f"{lado}LowerArm", _osc(canal), ribete(f"{lado}LowerArm", lambda c, m: c.z - m.z + alto + 0.004, (0.045, 0.045), alto=alto * 2, sobra=0.0, adentro=MANGA_ADENTRO))
        for lado in ("Left", "Right")
    ]


def cadera_arriba(canal="C1", y_extra=CAPA_CADERA, x_extra=0.062, baja=0.03):
    """La prenda de arriba sobre la cadera: tubo abierto arriba y abajo que pasa por fuera del
    pantalón y baja `baja` sobre las perneras. Hacia los costados tapa justo las perneras (la
    parte que queda debajo de la manga es de la misma prenda)."""
    _, _, lc, lm = P("LowerTorso")
    ext = (x_extra, y_extra, 0.0)
    return [
        ("LowerTorso", canal, forro("LowerTorso", ext, z_abajo=lc.z - lm.z - baja, abierto_abajo=True, abierto_arriba=True)),
        ("LowerTorso", _osc(canal), ribete("LowerTorso", lambda c, m: c.z - m.z - baja + 0.013, (x_extra, y_extra), alto=0.024, sobra=0.006)),
    ]


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
        ("UpperTorso", "C1o", bolsillo_pecho(-1, 0.05)),
        ("UpperTorso", "C1o", bolsillo_pecho(1, 0.05)),
        ("UpperTorso", "C1o", tapeta(0.042)),
        ("LowerTorso", "C1o", bolsillos_bajos(0.065, tapa=False)),
        *puños("C1o"),
    ]

    def camisa_corbata(bm):
        T.caja(bm, Vector((uc.x, f - 0.035, uc.z + um.z * 0.45)), Vector((0.14, 0.012, um.z * 0.9)))
        T.caja(bm, Vector((uc.x, f - 0.044, utx.z - 0.045)), Vector((0.05, 0.012, 0.04)))  # nudo
        T.caja(bm, Vector((uc.x, f - 0.044, (utx.z - 0.065 + uc.z - um.z * 0.4) / 2)), Vector((0.07, 0.008, utx.z - 0.065 - uc.z + um.z * 0.4)))

    piezas["SacoOficina"] = [
        ("UpperTorso", "C1", forro("UpperTorso", (0.04, 0.04, 0.02), abierto_abajo=True)),
        *cadera_arriba("C1", CAPA_CADERA, baja=0.03),
        ("UpperTorso", "C1", solapas),
        ("UpperTorso", "C2", camisa_corbata),
        ("LowerTorso", "C1o", botones("LowerTorso", 2, 0.0, 0.06, 0.012, 0.6, 0.2)),
        ("LowerTorso", "C1o", bolsillos_bajos(0.065)),
        ("UpperTorso", "C1o", bolsillo_pecho(1, 0.045)),
        ("LowerTorso", "C1o", costura_lado("LowerTorso", (0.05, 0.05), "espalda")),  # tajo de atrás
        *mangas(extra=(0.035, 0.035, 0.01)),
        *botones_manga(),
    ]

    def capucha(bm):
        # Capucha bajada: un rollo de tela detrás del cuello (no sube a la cabeza).
        T.caja(bm, Vector((uc.x, uc.y + um.y * 0.75, utx.z + 0.02)), Vector((um.x * 0.7, um.y * 0.55, 0.025)) * 2)

    def canguro(bm):
        T.caja(bm, Vector((uc.x, f - 0.045, uc.z - um.z * 0.45)), Vector((um.x * 1.2, 0.02, um.z * 0.6)))
        for s in (-1, 1):
            T.cilindro(bm, Vector((uc.x + s * 0.05, f - 0.04, utx.z - 0.02)), Vector((uc.x + s * 0.05, f - 0.045, utx.z - 0.2)), 0.008, 5)

    def elastico(bm):
        # Cintura elástica del buzo: anillos finitos (el tejido acanalado) sobre el borde de abajo.
        z0 = lc.z - lm.z - 0.03
        for k in range(4):
            z = z0 + 0.03 + k * 0.014
            caja_tela(bm, Vector((lc.x - lm.x - 0.068, lc.y - lm.y - 0.061, z)), Vector((lc.x + lm.x + 0.068, lc.y + lm.y + 0.061, z + 0.005)), True, True)

    piezas["BuzoCapucha"] = torso(extra=(0.045, 0.045, 0.02)) + mangas(extra=(0.04, 0.04, 0.01)) + [
        ("UpperTorso", "C1", capucha),
        ("UpperTorso", "C2", canguro),
        ("LowerTorso", "C1o", elastico),
        *puños("C1o"),
    ]

    def cuadros_torso(bm):
        for k in range(4):
            z = uc.z + um.z * (-0.75 + k * 0.5)
            T.caja(bm, Vector((uc.x, uc.y, z)), Vector((um.x + 0.042, um.y + 0.042, 0.012)) * 2)
        for k in range(5):
            x = uc.x + um.x * (-0.8 + k * 0.4)
            T.caja(bm, Vector((x, f - 0.037, uc.z)), Vector((0.022, 0.006, um.z * 2.0)))

    def cuadros_brazos(lado):
        def armar(bm):
            _, _, c, m = P(f"{lado}UpperArm")
            for k in range(2):
                T.caja(bm, Vector((c.x, c.y, c.z + m.z * (-0.4 + k * 0.8))), Vector((m.x + 0.037, m.y + 0.037, 0.012)) * 2)

        return armar

    piezas["CamisaCuadros"] = torso() + mangas() + [
        ("UpperTorso", "C1", cuello_volcado(0.04)),
        ("UpperTorso", "C2", cuadros_torso),
        ("LeftUpperArm", "C2", cuadros_brazos("Left")),
        ("RightUpperArm", "C2", cuadros_brazos("Right")),
        ("UpperTorso", "C1o", botones("UpperTorso", 5, 0.0, 0.04, 0.009, 0.7, -0.9)),
    ]

    def falda(bm):
        # Faldón del piloto: un solo tubo que cae sobre las dos piernas hasta la rodilla (abierto
        # arriba y abajo), apenas más ancho que la cadera para no pisar los brazos.
        _, _, pc, pm = P("LeftUpperLeg")
        caja_tela(bm, Vector((lc.x - lm.x - 0.073, lc.y - lm.y - 0.13, pc.z - pm.z)), Vector((lc.x + lm.x + 0.073, lc.y + lm.y + 0.13, lc.z - lm.z - 0.012)), True, True)

    def cinto(bm):
        caja_tela(bm, Vector((lc.x - lm.x - 0.075, lc.y - lm.y - 0.075, lc.z - 0.015)), Vector((lc.x + lm.x + 0.075, lc.y + lm.y + 0.075, lc.z + 0.015)), True, True)
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.082, lc.z)), Vector((0.07, 0.012, 0.05)))  # hebilla

    def charreteras(bm):
        # Tiritas en los hombros con un botón, como los pilotos de lluvia.
        for s in (-1, 1):
            p = Vector((uc.x + s * um.x * 0.7, uc.y, utx.z + 0.022))
            T.caja(bm, p, Vector((0.16, 0.06, 0.012)))
            T.remache(bm, p + Vector((-s * 0.06, 0, 0.007)), 0.01, (0, 0, 1))

    piezas["PilotoLargo"] = [
        ("UpperTorso", "C1", forro("UpperTorso", (0.045, 0.045, 0.02), abierto_abajo=True)),
        *cadera_arriba("C1", 0.065, baja=0.025),
        ("UpperTorso", "C1", solapas),
        ("UpperTorso", "C1", cuello_volcado(0.06)),
        ("LowerTorso", "C1", falda),
        ("LowerTorso", "C2", cinto),
        ("UpperTorso", "C2", botones("UpperTorso", 3, -0.09, 0.06, 0.012, 0.5, -0.6)),
        ("UpperTorso", "C2", botones("UpperTorso", 3, 0.09, 0.06, 0.012, 0.5, -0.6)),
        ("UpperTorso", "C1o", charreteras),
        ("LowerTorso", "C1o", bolsillos_bajos(0.075)),
        *mangas(extra=(0.04, 0.04, 0.01)),
        *botones_manga((0.04, 0.04, 0.01), 2),
    ]

    def chaleco(bm):
        # Dos paneles adelante (abiertos al medio) y uno atrás, con ribete en el borde.
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * um.x * 0.55, f - 0.05, uc.z - 0.02)), Vector((um.x * 0.85, 0.02, um.z * 2.0)))
        T.caja(bm, Vector((uc.x, uc.y + um.y + 0.05, uc.z - 0.02)), Vector((um.x * 2.0, 0.02, um.z * 2.0)))
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * um.x * 0.14, f - 0.062, uc.z - 0.02)), Vector((0.014, 0.008, um.z * 2.0)))

    def reflectivas(bm):
        # Bandas reflectivas solo sobre los paneles (no dan la vuelta al cuerpo).
        for z in (-0.45, 0.15):
            for s in (-1, 1):
                T.caja(bm, Vector((uc.x + s * um.x * 0.55, f - 0.063, uc.z + um.z * z)), Vector((um.x * 0.85, 0.008, 0.05)))
            T.caja(bm, Vector((uc.x, uc.y + um.y + 0.063, uc.z + um.z * z)), Vector((um.x * 2.0, 0.008, 0.05)))

    piezas["ChalecoObra"] = torso() + mangas(largo=False) + [("UpperTorso", "C2", chaleco), ("UpperTorso", "acero", reflectivas)]

    def estampa(bm):
        # Estampa propia: un eclipse (aro grueso con un disco corrido) y una barra abajo.
        c = Vector((uc.x, f - 0.04, uc.z + um.z * 0.25))
        pasos = 20
        T.tubo(bm, [c + Vector((math.cos(a) * 0.09, 0, math.sin(a) * 0.09)) for a in [2 * math.pi * i / pasos for i in range(pasos + 1)]], 0.02, 4, False)
        T.cilindro(bm, c + Vector((0.025, 0.004, 0.02)), c + Vector((0.025, -0.006, 0.02)), 0.06, 14)
        T.caja(bm, c + Vector((0, 0, -0.17)), Vector((0.22, 0.008, 0.035)))

    def cuello_redondo(bm):
        # Ribete del cuello: 3 tiras que rodean el cuello por arriba del torso.
        z = utx.z + 0.012
        T.caja(bm, Vector((uc.x, f - 0.01, z)), Vector((0.24, 0.035, 0.022)))
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * 0.12, uc.y - um.y * 0.3, z)), Vector((0.035, um.y * 1.2, 0.022)))

    piezas["RemeraEstampa"] = torso() + mangas(largo=False) + [("UpperTorso", "C2", estampa), ("UpperTorso", "C1o", cuello_redondo)]

    def cuello_v(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((uc.x + s * 0.04, f - 0.04, utx.z - 0.08)), Vector((0.03, 0.012, 0.16)), _g(-s * 28, "Y"))

    def bolsillo_enf(bm):
        b = Vector((uc.x + um.x * 0.5, f - 0.045, uc.z + um.z * 0.2))
        T.caja(bm, b, Vector((0.13, 0.014, 0.12)))
        for k in range(2):  # lapiceras
            T.cilindro(bm, b + Vector((-0.03 + k * 0.03, 0, 0.03)), b + Vector((-0.03 + k * 0.03, 0, 0.1)), 0.008, 6)
        T.caja(bm, Vector((uc.x - um.x * 0.5, f - 0.045, uc.z + um.z * 0.35)), Vector((0.09, 0.008, 0.04)))  # credencial

    piezas["UniformeEnfermeria"] = torso() + mangas(largo=False) + [
        ("UpperTorso", "C2", cuello_v),
        ("UpperTorso", "C2", bolsillo_enf),
        ("LowerTorso", "C1o", bolsillos_bajos(0.065, tapa=False)),
    ]
    return {k: ("arriba", v) for k, v in piezas.items()}


def abajo():
    _, ltx, lc, lm = P("LowerTorso")
    piezas = {}

    def cinturon(bm):
        # Cinturón: hacia los costados no sale del cuerpo (ahí se apoyan los brazos).
        caja_tela(bm, Vector((lc.x - lm.x - 0.003, lc.y - lm.y - 0.025, ltx.z - 0.068)), Vector((lc.x + lm.x + 0.003, lc.y + lm.y + 0.025, ltx.z - 0.012)), True, True)
        T.caja(bm, Vector((lc.x, lc.y - lm.y - 0.03, ltx.z - 0.04)), Vector((0.06, 0.012, 0.045)))  # hebilla

    cadera = ("LowerTorso", "C1", forro("LowerTorso", (0.0, 0.02, 0.0)))

    def costura(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg",):
                _, _, c, m = P(parte)
                x = c.x + (1 if c.x > lc.x else -1) * (m.x + 0.034)
                T.caja(bm, Vector((x, c.y, c.z)), Vector((0.012, 0.012, m.z * 2)))

        return armar

    _, lpx, lpc, lpm = P("LeftUpperLeg")
    frente_p = lpc.y - lpm.y - 0.03 - 0.006  # cara de adelante de la pernera
    atras_p = lpc.y + lpm.y + 0.03 + 0.006
    zb = lpx.z - 0.07  # justo debajo del borde de la prenda de arriba

    def bolsillos_jean(bm):
        # Adelante: boca del bolsillo en diagonal y monedero; atrás: bolsillos con pespunte.
        for sx in (-1, 1):
            x = lc.x + sx * lm.x * 0.55
            T.caja(bm, Vector((x, frente_p, zb - 0.02)), Vector((0.14, 0.012, 0.016)), _g(sx * 35, "Y"))
            T.caja(bm, Vector((x, atras_p, zb - 0.07)), Vector((0.15, 0.012, 0.15)))
            T.caja(bm, Vector((x, atras_p + 0.008, zb - 0.01)), Vector((0.15, 0.006, 0.008)))
        T.caja(bm, Vector((lc.x + lm.x * 0.35, frente_p, zb - 0.06)), Vector((0.06, 0.012, 0.05)))

    def remaches_jean(bm):
        for sx in (-1, 1):
            T.remache(bm, Vector((lc.x + sx * lm.x * 0.85, frente_p - 0.006, zb - 0.01)), 0.009)

    piezas["Jean"] = [
        cadera,
        ("LowerTorso", "C2", cinturon),
        ("LowerTorso", "C1o", presillas()),
        ("LowerTorso", "C1o", bolsillos_jean),
        ("LowerTorso", "acero", remaches_jean),
        *piernas(),
        ("LeftUpperLeg", "C1o", costura("Left")),
        ("RightUpperLeg", "C1o", costura("Right")),
    ]

    def raya(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg", f"{lado}LowerLeg"):
                _, _, c, m = P(parte)
                T.caja(bm, Vector((c.x, c.y - m.y - 0.032, c.z)), Vector((0.01, 0.01, m.z * 2)))

        return armar

    def bolsillos_vestir(bm):
        # Bolsillos de ojal (tajos finitos con botón) atrás y al costado adelante.
        for sx in (-1, 1):
            b = Vector((lc.x + sx * lm.x * 0.5, atras_p, zb - 0.03))
            T.caja(bm, b, Vector((0.13, 0.012, 0.014)))
            T.remache(bm, b + Vector((0, 0.01, -0.025)), 0.008, (0, 1, 0))
            T.caja(bm, Vector((lc.x + sx * lm.x * 0.8, frente_p, zb - 0.06)), Vector((0.012, 0.012, 0.14)), _g(sx * 15, "Y"))

    piezas["PantalonVestir"] = [
        cadera,
        ("LowerTorso", "C2", cinturon),
        ("LowerTorso", "C1o", presillas()),
        ("LowerTorso", "C1o", bolsillos_vestir),
        *piernas(extra=(0.035, 0.035, 0.01)),
        ("LeftUpperLeg", "C1o", raya("Left")),
        ("RightUpperLeg", "C1o", raya("Right")),
    ]

    def _anillos_pollera():
        # Tubo de 3 anillos: arriba recto (metido adentro de la prenda de arriba) y abajo se abre
        # hasta la rodilla. (z, mitad x, mitad y)
        _, _, pc, pm = P("LeftUpperLeg")
        return [(lc.z - lm.z * 0.3, lm.x + 0.002, lm.y + 0.04), (lc.z - lm.z - 0.04, lm.x + 0.002, lm.y + 0.04), (pc.z - pm.z * 0.6, lm.x + 0.05, lm.y + 0.1)]

    def pollera(bm):
        aros = []
        for z, hx_, hy_ in _anillos_pollera():
            aros.append([bm.verts.new(Vector((lc.x + sx * hx_, lc.y + sy * hy_, z))) for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))])
        for a, b in zip(aros, aros[1:]):
            for k in range(4):
                q = (k + 1) % 4
                bm.faces.new((a[k], a[q], b[q], b[k]))

    medias = [(f"{lado}LowerLeg", "C2", forro(f"{lado}LowerLeg", (0.012, 0.012, 0.0), 0.35, (12, 6))) for lado in ("Left", "Right")]
    def tablas(bm):
        # Pliegues (tablas): tiras sobre la parte que se abre, adelante, atrás y a los costados.
        (_, _, _), (z1, x1, y1), (z2, x2, y2) = _anillos_pollera()
        for k in range(5):
            t = -0.8 + k * 0.4
            for sy in (-1, 1):
                T.tubo(bm, [Vector((lc.x + t * x1, lc.y + sy * (y1 + 0.006), z1)), Vector((lc.x + t * x2, lc.y + sy * (y2 + 0.006), z2))], 0.01, 4)
        for sx in (-1, 1):
            T.tubo(bm, [Vector((lc.x + sx * (x1 + 0.006), lc.y, z1)), Vector((lc.x + sx * (x2 + 0.006), lc.y, z2))], 0.01, 4)
        # Dobladillo abajo.
        caja_tela(bm, Vector((lc.x - x2 - 0.006, lc.y - y2 - 0.006, z2 + 0.004)), Vector((lc.x + x2 + 0.006, lc.y + y2 + 0.006, z2 + 0.028)), True, True)

    piezas["Pollera"] = [("LowerTorso", "C1", pollera), ("LowerTorso", "C1o", tablas), *medias]

    def franja(lado):
        def armar(bm):
            for parte in (f"{lado}UpperLeg", f"{lado}LowerLeg"):
                _, _, c, m = P(parte)
                x = c.x + (1 if c.x > lc.x else -1) * (m.x + 0.044)
                T.caja(bm, Vector((x, c.y, c.z)), Vector((0.012, 0.05, m.z * 2)))

        return armar

    def cordon(bm):
        caja_tela(bm, Vector((lc.x - lm.x - 0.003, lc.y - lm.y - 0.025, ltx.z - 0.08)), Vector((lc.x + lm.x + 0.003, lc.y + lm.y + 0.025, ltx.z)), True, True)
        for s in (-1, 1):
            T.cilindro(bm, Vector((lc.x + s * 0.025, lc.y - lm.y - 0.034, ltx.z - 0.03)), Vector((lc.x + s * 0.03, lc.y - lm.y - 0.034, ltx.z - 0.07)), 0.006, 5)

    puños_j = []
    for lado in ("Left", "Right"):

        def puño_pierna(bm, lado=lado):
            _, _, c, m = P(f"{lado}LowerLeg")
            T.caja(bm, Vector((c.x, c.y, c.z - m.z + 0.04)), Vector((m.x + 0.05, m.y + 0.05, 0.04)) * 2)

        puños_j.append((f"{lado}LowerLeg", "C1o", puño_pierna))
    piezas["Jogging"] = [cadera, ("LowerTorso", "C2", cordon), *piernas(extra=(0.04, 0.04, 0.01)), *puños_j, ("LeftUpperLeg", "C2", franja("Left")), ("RightUpperLeg", "C2", franja("Right"))]
    def cargo(lado):
        # Bolsillo cargo al costado del muslo, con tapa y botón.
        def armar(bm):
            _, _, c, m = P(f"{lado}UpperLeg")
            s_ = 1 if c.x > lc.x else -1
            b = Vector((c.x + s_ * (m.x + 0.045), c.y, c.z - m.z * 0.4))
            T.caja(bm, b, Vector((0.025, 0.17, 0.18)))
            T.caja(bm, b + Vector((s_ * 0.005, 0, 0.085)), Vector((0.03, 0.18, 0.05)))
            T.remache(bm, b + Vector((s_ * 0.022, 0, 0.075)), 0.01, (s_, 0, 0))

        return armar

    piezas["Bermuda"] = [
        cadera,
        ("LowerTorso", "C2", cinturon),
        ("LowerTorso", "C1o", presillas()),
        *piernas(extra=(0.045, 0.045, 0.01), corta=0.3),
        ("LeftUpperLeg", "C1o", cargo("Left")),
        ("RightUpperLeg", "C1o", cargo("Right")),
    ]

    _, utx, uc, um = P("UpperTorso")

    def pechera(bm):
        # Va por fuera de cualquier prenda de arriba (botones y bolsillos llegan a 7 cm).
        T.caja(bm, Vector((uc.x, uc.y - um.y - 0.085, uc.z - um.z * 0.25)), Vector((um.x * 1.2, 0.02, um.z * 1.1)))
        T.caja(bm, Vector((uc.x, uc.y - um.y - 0.1, uc.z - um.z * 0.15)), Vector((um.x * 0.6, 0.012, um.z * 0.5)))

    def tirantes(bm):
        for s in (-1, 1):
            x = uc.x + s * um.x * 0.45
            T.tubo(bm, [Vector((x, uc.y - um.y - 0.09, uc.z + um.z * 0.25)), Vector((x, uc.y - um.y - 0.09, utx.z + 0.03)), Vector((x, uc.y - um.y * 0.4, utx.z + 0.09)), Vector((x, uc.y + um.y * 0.4, utx.z + 0.09)), Vector((x, uc.y + um.y + 0.088, utx.z + 0.09)), Vector((x, uc.y + um.y + 0.088, utx.z + 0.02)), Vector((uc.x + s * 0.04, uc.y + um.y + 0.088, uc.z - um.z * 0.6))], 0.012, 4)
            T.remache(bm, Vector((x, uc.y - um.y - 0.11, uc.z + um.z * 0.25)), 0.015)

    def rodilleras(lado):
        # Parche cosido en la rodilla (el mameluco de trabajo se gasta ahí).
        def armar(bm):
            _, _, c, m = P(f"{lado}LowerLeg")
            T.caja(bm, Vector((c.x, c.y - m.y - 0.058, c.z + m.z * 0.6)), Vector((m.x * 1.5, 0.014, 0.16)))

        return armar

    piezas["Mameluco"] = [
        cadera,
        ("UpperTorso", "C1", pechera),
        ("UpperTorso", "C2", tirantes),
        *piernas(extra=(0.045, 0.045, 0.01)),
        ("LeftLowerLeg", "C1o", rodilleras("Left")),
        ("RightLowerLeg", "C1o", rodilleras("Right")),
    ]
    return {k: ("abajo", v) for k, v in piezas.items()}


def cabezas():
    _, hx, hc, hm = P("Head")
    f = hc.y - hm.y
    r, ry = hm.x + 0.03, hm.y + 0.03
    piezas = {}

    def copa(z0, alto, dy=0.0, ancho=0.0):
        # Copa de cantos rectos (mitad de alto `alto`), apenas más grande que la cabeza.
        def armar(bm):
            caja_tela(bm, Vector((hc.x - r - ancho, hc.y + dy - ry - ancho, z0 - alto)), Vector((hc.x + r + ancho, hc.y + dy + ry + ancho, z0 + alto)))

        return armar

    def visera(bm):
        T.caja(bm, Vector((hc.x, f - 0.12, hx.z - hm.z * 0.48)), Vector((hm.x * 1.6, 0.2, 0.02)), _g(6, "X"))
        T.caja(bm, Vector((hc.x, hc.y, hx.z + hm.z * 0.2 + 0.006)), Vector((0.04, 0.04, 0.012)))  # botón

    def costuras_gorra(bm):
        # Gajos de la gorra: 3 costuras que cruzan la copa de adelante para atrás.
        for k in (-1, 0, 1):
            T.caja(bm, Vector((hc.x + k * r * 0.5, hc.y, hx.z + hm.z * 0.2)), Vector((0.01, ry * 2 + 0.01, 0.008)))
        T.caja(bm, Vector((hc.x, hc.y - ry - 0.004, hx.z - hm.z * 0.25)), Vector((r * 2, 0.008, 0.02)))  # banda

    zg = hx.z - hm.z * 0.25
    piezas["Gorra"] = [("Head", "C1", copa(zg, hm.z * 0.45)), ("Head", "C1o", costuras_gorra), ("Head", "C2", visera)]

    def borde_lana(bm):
        # Borde doblado (anillo abierto, la copa pasa por adentro) y pompón de cantos rectos.
        caja_tela(bm, Vector((hc.x - r - 0.02, hc.y - ry - 0.02, hx.z - hm.z * 0.55 - 0.07)), Vector((hc.x + r + 0.02, hc.y + ry + 0.02, hx.z - hm.z * 0.55 + 0.07)), True, True)
        T.caja(bm, Vector((hc.x, hc.y, hx.z + hm.z * 0.48 + 0.05)), Vector((0.12, 0.12, 0.1)))  # pompón

    def tejido(bm):
        # Costillas del tejido: líneas verticales finitas en la copa, por encima del borde.
        for k in range(-3, 4):
            for sy in (-1, 1):
                T.caja(bm, Vector((hc.x + k * r * 0.28, hc.y + sy * (ry + 0.002), hx.z - hm.z * 0.05)), Vector((0.01, 0.006, hm.z * 0.75)))

    piezas["GorroLana"] = [("Head", "C1", copa(hx.z - hm.z * 0.15, hm.z * 0.63)), ("Head", "C1o", tejido), ("Head", "C2", borde_lana)]

    def pelo_base(alto=0.45, dy=0.015, extra=0.0):
        # Casco de pelo de cantos rectos (arriba y a los costados; la cara queda libre).
        def armar(bm):
            caja_tela(bm, Vector((hc.x - r - extra, hc.y + dy - ry - extra, hx.z - 2 * hm.z * alto)), Vector((hc.x + r + extra, hc.y + dy + ry + extra, hx.z + 0.04)))

        return armar

    def flequillo(bm):
        # Mechones del flequillo en escalón (segundo color: reflejos).
        for k in range(4):
            T.caja(bm, Vector((hc.x - 0.12 + k * 0.08, f - 0.024, hx.z - 0.02 - (k % 2) * 0.025)), Vector((0.075, 0.02, 0.06 + (k % 2) * 0.03)))

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
        z1 = hc.z - hm.z * 0.6
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
                p = Vector((p.x, p.y, max(p.z, hc.z - hm.z * 0.4)))
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
        """Barba en U de cantos rectos (mentón + patillas hasta la oreja), bigote recto con las
        puntas caídas y la boca libre entre los dos (Juani: el bigote redondo se veía raro)."""
        boca = hc.z - hm.z * 0.42
        abajo_ = hc.z - hm.z + 0.045  # no baja de la cabeza: no pisa cuellos ni capuchas
        prof = hm.y * 1.2  # cubre la mandíbula hasta la mitad de la cabeza
        T.caja(bm, Vector((hc.x, f + prof / 2 - 0.022, (boca - 0.03 + abajo_) / 2)), Vector((hm.x * 2 + 0.03, prof, boca - 0.03 - abajo_)))
        for s in (-1, 1):  # patillas
            T.caja(bm, Vector((hc.x + s * (hm.x + 0.008), f + 0.09, (boca + hc.z + hm.z * 0.15) / 2)), Vector((0.02, 0.16, hc.z + hm.z * 0.15 - boca)))
            T.caja(bm, Vector((hc.x + s * (hm.x * 0.78), f - 0.012, boca - 0.02)), Vector((hm.x * 0.42, 0.024, 0.09)))  # mejillas
        T.caja(bm, Vector((hc.x, f - 0.02, hc.z - hm.z * 0.22)), Vector((0.2, 0.03, 0.045)))  # bigote
        for s in (-1, 1):
            T.caja(bm, Vector((hc.x + s * 0.11, f - 0.02, hc.z - hm.z * 0.3)), Vector((0.045, 0.03, 0.07)), _g(s * 20, "Y"))
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


def _mano(lado):
    """Datos de la mano para colgar o sostener cosas sin que se metan en la mano ni en la manga:
    (hueso, centro, mitades, abajo, adelante, afuera)."""
    _, _, c, m = P(f"{lado}Hand")
    _, _, tc, _ = P("UpperTorso")
    return f"{lado}Hand", c, m, c.z - m.z, c.y - m.y, 1 if c.x > tc.x else -1


def accesorios():
    """Accesorios que cuelgan debajo de la mano o se sostienen adelante, por fuera de la manga, de
    las perneras y de la pollera (los revisa `choques`)."""
    piezas = {}
    hd, cd, md, abajo_d, adelante_d, sd = _mano("Right")
    hi, ci, mi, abajo_i, adelante_i, si = _mano("Left")

    # Maletín: cuelga de la manija, que toca la mano por abajo.
    mx_ = Vector((cd.x + sd * 0.025, cd.y, abajo_d - 0.06))

    def maletin(bm):
        caja_tela(bm, mx_ + Vector((-0.06, -0.2, -0.3)), mx_ + Vector((0.06, 0.2, 0.0)))
        T.caja(bm, mx_ + Vector((0, 0, -0.15)), Vector((0.13, 0.41, 0.012)))  # costura del medio

    def herrajes(bm):
        T.tubo(bm, [mx_ + Vector((0, -0.07, 0.0)), mx_ + Vector((0, -0.06, 0.035)), Vector((cd.x + sd * 0.025, cd.y, abajo_d - 0.015)), mx_ + Vector((0, 0.07, 0.0))], 0.012, 5)
        for sy in (-1, 1):
            T.caja(bm, mx_ + Vector((0, sy * 0.13, -0.02)), Vector((0.135, 0.04, 0.03)))  # cierres
            T.caja(bm, mx_ + Vector((0, sy * 0.2, -0.15)), Vector((0.13, 0.012, 0.31)))  # cantoneras

    piezas["Maletin"] = [(hd, "C1", maletin), (hd, "C2", herrajes)]

    # Bolsa de compras: cuelga hacia afuera de la mano izquierda.
    bi = Vector((ci.x + si * 0.13, ci.y, abajo_i))

    def bolsa(bm):
        caja_tela(bm, bi + Vector((-0.11, -0.15, -0.42)), bi + Vector((0.11, 0.15, -0.12)), abierto_arriba=True)
        T.caja(bm, bi + Vector((0, 0, -0.41)), Vector((0.2, 0.28, 0.01)))  # fondo

    def manijas_bolsa(bm):
        for sy in (-1, 1):
            T.tubo(bm, [bi + Vector((sy * 0.06, -0.15, -0.12)), Vector((ci.x + si * 0.02, ci.y - 0.03, abajo_i - 0.01)), bi + Vector((sy * 0.06, 0.15, -0.12))], 0.008, 4)
        T.cilindro(bm, bi + Vector((0.03, 0.05, -0.3)), bi + Vector((0.05, 0.09, -0.02)), 0.03, 6)  # pan
        T.bloque_redondo(bm, bi + Vector((-0.04, -0.06, -0.14)), Vector((0.05, 0.05, 0.05)), 0.9, 8, 4)  # manzana

    piezas["BolsaCompras"] = [(hi, "C1", bolsa), (hi, "C2", manijas_bolsa)]

    _, utx, uc, um = P("UpperTorso")
    at = uc.y + um.y

    # Mochila: separada de la espalda lo justo para no pisar capucha, chaleco ni tiradores.
    def mochila(bm):
        caja_tela(bm, Vector((uc.x - um.x * 0.72, at + 0.105, uc.z - um.z * 0.85)), Vector((uc.x + um.x * 0.72, at + 0.28, uc.z + um.z * 0.85)))
        caja_tela(bm, Vector((uc.x - um.x * 0.5, at + 0.28, uc.z - um.z * 0.75)), Vector((uc.x + um.x * 0.5, at + 0.34, uc.z - um.z * 0.05)))  # bolsillo
        T.caja(bm, Vector((uc.x, at + 0.345, uc.z - um.z * 0.1)), Vector((um.x * 0.9, 0.012, 0.03)))  # tapa del bolsillo

    def tiras(bm):
        for sx in (-1, 1):
            x = uc.x + sx * um.x * 0.8
            T.tubo(
                bm,
                [
                    Vector((x, uc.y - um.y - 0.095, uc.z - um.z * 0.3)),
                    Vector((x, uc.y - um.y - 0.095, utx.z + 0.05)),
                    Vector((x, uc.y - um.y * 0.3, utx.z + 0.05)),
                    Vector((x, at + 0.07, utx.z + 0.05)),
                    Vector((x, at + 0.15, utx.z - 0.03)),
                ],
                0.018,
                4,
            )
            T.caja(bm, Vector((x, uc.y - um.y - 0.105, uc.z + um.z * 0.1)), Vector((0.045, 0.012, 0.03)))  # hebilla
        # Tira del pecho.
        T.tubo(bm, [Vector((uc.x - um.x * 0.7, uc.y - um.y - 0.11, uc.z + um.z * 0.35)), Vector((uc.x + um.x * 0.7, uc.y - um.y - 0.11, uc.z + um.z * 0.35))], 0.01, 4)

    piezas["Mochila"] = [("UpperTorso", "C1", mochila), ("UpperTorso", "C2", tiras)]

    # Paraguas abierto: el palo va adelante de la mano y de la manga; la tela queda sobre la cabeza.
    pd = Vector((cd.x, adelante_d - 0.075, abajo_d))

    def tela_abierta(bm):
        tope = pd + Vector((0, 0, 1.36))
        n = 8
        borde = [tope + Vector((math.cos(2 * math.pi * k / n) * 0.58, math.sin(2 * math.pi * k / n) * 0.58, -0.24)) for k in range(n)]
        centro = bm.verts.new(tope)
        aro = [bm.verts.new(p) for p in borde]
        aro_dentro = [bm.verts.new(p + Vector((0, 0, -0.012))) for p in borde]
        centro_dentro = bm.verts.new(tope + Vector((0, 0, -0.012)))
        for k in range(n):
            q = (k + 1) % n
            bm.faces.new((centro, aro[k], aro[q]))
            bm.faces.new((centro_dentro, aro_dentro[q], aro_dentro[k]))
            bm.faces.new((aro[k], aro_dentro[k], aro_dentro[q], aro[q]))

    def caño(bm):
        T.cilindro(bm, pd + Vector((0, 0, -0.04)), pd + Vector((0, 0, 1.4)), 0.012, 6)
        T.tubo(bm, [pd + Vector((0, 0, -0.04)), pd + Vector((0, 0, -0.1)), pd + Vector((0, -0.05, -0.13)), pd + Vector((0, -0.08, -0.1))], 0.015, 5, False)
        for k in range(8):  # varillas
            a = 2 * math.pi * k / 8
            T.tubo(bm, [pd + Vector((0, 0, 1.34)), pd + Vector((math.cos(a) * 0.56, math.sin(a) * 0.56, 1.11))], 0.005, 3)

    piezas["ParaguasAbierto"] = [(hd, "C1", tela_abierta), (hd, "C2", caño)]

    # Paraguas cerrado: cuelga de la mano hasta casi el piso, por fuera de la pierna.
    pc_ = Vector((cd.x + sd * 0.02, cd.y, abajo_d))

    def tela_cerrada(bm):
        T.cilindro(bm, pc_ + Vector((0, 0, 0.1 - pc_.z)), pc_ + Vector((0, 0, -0.12)), 0.004, 8, 0.042)
        T.caja(bm, pc_ + Vector((0, 0, -0.3)), Vector((0.07, 0.025, 0.03)))  # cinta que la cierra

    def caño_cerrado(bm):
        T.cilindro(bm, pc_ + Vector((0, 0, 0.05 - pc_.z)), pc_ + Vector((0, 0, -0.005)), 0.009, 6)

    piezas["ParaguasCerrado"] = [(hd, "C1", tela_cerrada), (hd, "C2", caño_cerrado)]

    # Café: adelante de la mano y más abajo que la manga.
    va = Vector((cd.x, adelante_d - 0.062, abajo_d - 0.04))

    def vaso(bm):
        T.cilindro(bm, va + Vector((0, 0, -0.1)), va + Vector((0, 0, 0.08)), 0.04, 12, 0.05)

    def tapa(bm):
        T.cilindro(bm, va + Vector((0, 0, 0.08)), va + Vector((0, 0, 0.11)), 0.054, 12, 0.045)
        T.cilindro(bm, va + Vector((0, 0, -0.03)), va + Vector((0, 0, 0.03)), 0.048, 12, 0.05)  # faja

    piezas["Cafe"] = [(hd, "C1", vaso), (hd, "C2", tapa)]

    # Correa del perro: sale de adelante de la mano izquierda y baja hacia adelante.
    ci0 = Vector((ci.x, adelante_i - 0.035, abajo_i - 0.025))

    def correa(bm):
        piso = Vector((ci.x + si * 0.1, ci.y - 0.9, 0.25))
        pts = [ci0 + (piso - ci0) * t + Vector((0, 0, -math.sin(t * math.pi) * 0.15)) for t in [k / 8 for k in range(9)]]
        T.tubo(bm, pts, 0.008, 4)
        T.cilindro(bm, piso + Vector((0, 0, -0.02)), piso + Vector((0, 0, 0.02)), 0.025, 8)  # mosquetón del collar

    def manija_correa(bm):
        T.caja(bm, ci0, Vector((0.07, 0.03, 0.08)))

    piezas["CorreaPerro"] = [(hi, "C1", correa), (hi, "C2", manija_correa)]
    out = {k: ("accesorio", v) for k, v in piezas.items()}

    # Teléfono: adelante de la mano, más abajo que la manga (en el juego, mientras llama, se
    # oculta lo que tenga en la mano derecha).
    adelante = Vector((cd.x, adelante_d - 0.022, abajo_d - 0.01))

    def carcasa(bm):
        T.bloque_redondo(bm, adelante, Vector((0.04, 0.008, 0.08)), 0.3, 8, 4)

    def camara(bm):
        T.cilindro(bm, adelante + Vector((0.02, 0.008, 0.06)), adelante + Vector((0.02, 0.012, 0.06)), 0.008, 6)

    def pantalla(bm):
        T.caja(bm, adelante + Vector((0, -0.009, 0.0)), Vector((0.066, 0.002, 0.14)))

    out["Telefono"] = ("telefono", [(hd, "C1", carcasa), (hd, "C2", camara), (hd, "Pantalla", pantalla)])
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
        mat = CANALES.get(canal, "neon-cian" if canal == "Pantalla" else canal)
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
    o = Vector((-1.0, -0.1, 0))

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
    o = Vector((-1.15, -0.05, 0))

    def caja_(bm):
        T.caja(bm, o + Vector((0, 0, 0.6)), Vector((0.64, 1.1, 0.6)))
        for y in (-0.28, 0.28):  # puertas de la caja térmica
            T.caja(bm, o + Vector((0.325, y, 0.6)), Vector((0.012, 0.46, 0.46)))
            T.caja(bm, o + Vector((0.335, y + (0.18 if y < 0 else -0.18), 0.6)), Vector((0.012, 0.03, 0.12)))  # manija
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
    c = Vector((uc.x + 0.05, uc.y - um.y - 0.155, uc.z - um.z * 0.6))  # adelante de cualquier detalle
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
        # Correa: del mástil sube por el hombro izquierdo y baja en diagonal por la espalda.
        x = uc.x + um.x * 0.75
        T.tubo(bm, [a + Vector((0, 0.04, 0)), Vector((x, uc.y - um.y - 0.1, utx.z + 0.02)), Vector((x, uc.y - um.y * 0.3, utx.z + 0.05)), Vector((x, uc.y + um.y + 0.08, utx.z + 0.03)), Vector((uc.x - um.x * 0.5, uc.y + um.y + 0.08, uc.z - um.z * 0.7))], 0.015, 4)

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
        caja_tela(bm, o + Vector((-0.5, -0.2, 0.0)), o + Vector((0.5, 0.2, 0.1)), abierto_arriba=True)
        T.caja(bm, o + Vector((0, 0.235, 0.24)), Vector((1.0, 0.03, 0.36)), _g(-10, "X"))  # tapa abierta
        for x in (-0.3, 0.0, 0.3):
            T.caja(bm, o + Vector((x, 0.2, 0.09)), Vector((0.06, 0.03, 0.04)))  # bisagras
            T.caja(bm, o + Vector((x, -0.205, 0.07)), Vector((0.05, 0.012, 0.04)))  # cierres

    def forro_(bm):
        T.caja(bm, o + Vector((0, 0, 0.02)), Vector((0.96, 0.36, 0.02)))  # forro del fondo

    def monedas(bm):
        random.seed(5)
        for _ in range(7):
            p = o + Vector((random.uniform(-0.3, 0.3), random.uniform(-0.1, 0.1), 0.031))
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
    for c in sorted(CANALES, key=len, reverse=True):
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
            par = colores.get(dueño, ("c9c6c0", "7a7d84"))
            hex_ = par[1] if canal == "C2" else par[0]
            if canal == "C1o":  # tono de detalle, como lo calcula el juego (Civiles.luau)
                rgb = [int(hex_[i : i + 2], 16) for i in (0, 2, 4)]
                if max(rgb) / 255 < 0.22:  # prenda muy oscura: el detalle va más claro
                    rgb = [v + (255 - v) * 0.35 for v in rgb]
                else:
                    rgb = [v * (1 - OSCURO) for v in rgb]
                hex_ = "".join(f"{int(v):02x}" for v in rgb)
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


def _arbol(objs):
    """BVH en coordenadas de mundo de varias mallas juntas (para buscar choques)."""
    from mathutils.bvhtree import BVHTree

    verts, caras = [], []
    for o in objs:
        base = len(verts)
        m = o.matrix_world
        verts += [m @ v.co for v in o.data.vertices]
        caras += [[base + i for i in p.vertices] for p in o.data.polygons]
    return BVHTree.FromPolygons(verts, caras) if caras else None


# Pares de tipos que se usan juntos en un mismo civil (los de un mismo tipo nunca van juntos).
JUNTOS = [("arriba", "abajo"), ("arriba", "cabeza"), ("arriba", "accesorio"), ("abajo", "accesorio"), ("cabeza", "accesorio"), ("arriba", "telefono"), ("abajo", "telefono")]


def choques(piezas_kit):
    """Lista de (pieza A, pieza B, triángulos que se cruzan) para todas las piezas que pueden ir
    juntas en un civil, más accesorios y props contra el cuerpo. Vacía = nada atraviesa nada."""
    bpy.context.view_layer.update()
    arboles = {n: _arbol(objs) for n, (_, objs) in piezas_kit.items()}
    cuerpo = _arbol(B.partes())
    tipo = {n: t for n, (t, _) in piezas_kit.items()}
    out = []
    nombres = list(piezas_kit)
    for i, a in enumerate(nombres):
        for b in nombres[i + 1 :]:
            par = (tipo[a], tipo[b])
            if par not in JUNTOS and par[::-1] not in JUNTOS:
                continue
            n = len(arboles[a].overlap(arboles[b])) if arboles[a] and arboles[b] else 0
            if n:
                out.append((a, b, n))
    for nombre, (nombres_esp, _) in ESPECIALES.items():
        for p in nombres_esp[:-1]:
            n = len(arboles[nombre].overlap(arboles[p]))
            if n:
                out.append((nombre, p, n))
    for n_, t in tipo.items():
        if t in ("accesorio", "telefono", "especial") and arboles[n_]:
            n = len(arboles[n_].overlap(cuerpo))
            if n:
                out.append((n_, "Cuerpo", n))
    return out


def chequear():
    piezas = armar()
    lista = choques(piezas)
    for a, b, n in sorted(lista, key=lambda x: -x[2]):
        print(f"CHOQUE {a} x {b}: {n}")
    print("Choques:", len(lista))
    return lista


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
    # Sin horneado ni bisel (1 nov): en el juego los civiles van con color liso (MeshPart.Color,
    # 2 canales) y cantos rectos como el cuerpo de Roblox. El horneado ensuciaba las telas
    # abiertas y el bisel les sacaba aletas en los bordes. Solo se reduce la pieza que se pase.
    for tope, nombres in _presupuesto(piezas).values():
        grupo = [bpy.data.objects[n] for n in nombres]
        total = sum(B.triangulos(o) for o in grupo)
        if total > tope:
            for o in grupo:
                D.reducir(o, int(B.triangulos(o) * tope / total))
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
    for paso in ("chequear", "boceto", "detalle", "exportar", "paquete"):
        if paso in argumentos:
            globals()[paso]()
