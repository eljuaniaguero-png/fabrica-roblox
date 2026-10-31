"""Atalanta: guerrera de la Liga, de las Hespérides (isla griega oculta). Ficha de Juani del 30 oct.

Diseño propio: sin tiara con estrella, sin lazo, sin águila ni "W", sin bustier rojo-azul-dorado.
Silueta: armadura de hoplita de bronce, escudo redondo grande (emblema: manzana dorada con una
hoja) y lanza más alta que ella.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/atalanta.py -- boceto

Paso "boceto": bloques sin detalle de las piezas, render de 3 vistas (renders/atalanta_boceto_vistas.png).
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

NOMBRE = "Atalanta"
BLEND = os.path.join(B.BLENDER, "atalanta.blend")

# Presupuesto de triángulos por pieza (ficha, total ≤ 32.000).
PRESUPUESTO = {
    "Casco": 7000,
    "Coraza": 8000,
    "Capa": 4000,
    "Brazaletes": 2000,
    "Grebas": 4000,
    "Escudo": 5000,
    "Lanza": 2000,
}

ESCUDO_DIAMETRO = 1.8 * B.STUD
LANZA_LARGO = 6.0 * B.STUD


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


# ---------------------------------------------------------------------------
# Boceto (paso 1)
# ---------------------------------------------------------------------------


def casco():
    """Casco corintio abierto: cúpula de bronce que baja a carrilleras, nasal al frente y cresta de
    crin azul liga de la frente a la nuca."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.02, 0.02, 0.02))
    frente = hc.y - m.y

    def cupula(bm):
        T.bloque_redondo(bm, hc + Vector((0, 0.005, 0.01)), m, 0.55, 24, 14)
        for s in (-1, 1):  # carrilleras a los costados de la cara
            T.bloque_redondo(bm, Vector((hc.x + s * m.x * 0.62, frente + 0.01, hc.z - hm.z * 0.35)), Vector((m.x * 0.32, 0.018, hm.z * 0.5)), 0.4, 12, 6)
        T.caja(bm, Vector((hc.x, frente - 0.004, hc.z + hm.z * 0.05)), Vector((0.022, 0.016, hm.z * 0.45)))  # nasal

    def cresta(bm):
        r = m.y * 1.05
        arco = [Vector((hc.x, hc.y + math.cos(a) * r, hmax.z + 0.01 + math.sin(a) * r * 0.55)) for a in (math.pi * (0.95 - 0.9 * i / 12) for i in range(13))]
        arco.append(Vector((hc.x, hc.y + r * 1.05, hc.z - hm.z * 0.2)))  # cae por la nuca
        T.tubo(bm, arco, 0.03, 6)

    return T.pieza(f"{NOMBRE}_Casco", "Head", [("bronce", cupula), ("liga", cresta)])


def coraza():
    """Coraza musculada de bronce (torso y cadera) y falda de tiras de cuero en 2 filas."""
    piezas = []
    _, _, tc, tm = T.caja_parte("UpperTorso")

    def peto(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.03, 0.03, 0.01)), 0.3, 20, 10)
        for s in (-1, 1):  # pectorales marcados
            T.bloque_redondo(bm, Vector((tc.x + s * tm.x * 0.45, tc.y - tm.y - 0.03, tc.z + tm.z * 0.3)), Vector((tm.x * 0.42, 0.02, tm.z * 0.35)), 0.6, 12, 6)

    piezas.append(T.pieza(f"{NOMBRE}_Coraza", "UpperTorso", [("bronce", peto)]))

    lmin, _, lc, lm = T.caja_parte("LowerTorso")

    def cintura(bm):
        T.bloque_redondo(bm, lc + Vector((0, 0, lm.z * 0.3)), Vector((lm.x + 0.03, lm.y + 0.03, lm.z * 0.6)), 0.3, 20, 8)

    def pteruges(bm):
        n = 10
        for fila, (largo, z0, extra) in enumerate(((0.26, lmin.z + 0.06, 0.035), (0.34, lmin.z + 0.02, 0.05))):
            for i in range(n):
                a = 2 * math.pi * (i + 0.5 * fila) / n
                x = lc.x + math.sin(a) * (lm.x + extra)
                y = lc.y - math.cos(a) * (lm.y + extra)
                T.caja(bm, Vector((x, y, z0 - largo / 2 + 0.05)), Vector((0.07, 0.012, largo)), _g(math.degrees(a), "Z"))

    piezas.append(T.pieza(f"{NOMBRE}_Cintura", "LowerTorso", [("bronce", cintura), ("cuero", pteruges)]))
    return piezas


def capa():
    """Capa corta azul liga hasta la cintura, prendida con 2 broches de oro en los hombros."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    atras = tc.y + tm.y + 0.045

    def tela(bm):
        alto = tmax.z - (lc.z + lm.z * 0.2)
        T.bloque_redondo(bm, Vector((tc.x, atras, tmax.z - alto / 2)), Vector((tm.x * 1.25, 0.012, alto / 2)), 0.15, 20, 6)

    def broches(bm):
        for s in (-1, 1):
            p = Vector((tc.x + s * tm.x * 0.85, tc.y - tm.y - 0.035, tmax.z - 0.05))
            T.cilindro(bm, p + Vector((0, 0.01, 0)), p - Vector((0, 0.012, 0)), 0.04, 16)

    return T.pieza(f"{NOMBRE}_Capa", "UpperTorso", [("liga", tela), ("oro", broches)])


def brazaletes():
    piezas = []
    for lado, hueso in T._lados("LowerArm"):
        _, _, c, m = T.caja_parte(hueso)

        def braza(bm, c=c, m=m):
            T.bloque_redondo(bm, Vector((c.x, c.y, c.z - m.z * 0.1)), Vector((m.x + 0.025, m.y + 0.025, m.z * 0.8)), 0.45, 16, 6)

        piezas.append(T.pieza(f"{NOMBRE}_Brazalete{lado}", hueso, [("bronce", braza)]))
    return piezas


def grebas():
    """Grebas de bronce sobre la pierna y sandalias (suela de cuero y tiras de bronce)."""
    piezas = []
    for lado, hueso in T._lados("LowerLeg"):
        _, _, c, m = T.caja_parte(hueso)

        def greba(bm, c=c, m=m):
            T.bloque_redondo(bm, Vector((c.x, c.y - 0.005, c.z)), Vector((m.x + 0.022, m.y + 0.022, m.z * 0.95)), 0.5, 16, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Greba{lado}", hueso, [("bronce", greba)]))
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)

        def suela(bm, fc=fc, fm=fm, fmin=fmin):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.02, fmin.z + 0.012)), Vector((fm.x + 0.012, fm.y + 0.04, 0.014)), 0.3, 16, 4)

        def tiras(bm, fc=fc, fm=fm):
            for k in (-0.5, 0.1, 0.6):
                T.bloque_redondo(bm, Vector((fc.x, fc.y + k * fm.y, fc.z)), Vector((fm.x + 0.012, 0.012, fm.z + 0.008)), 0.5, 12, 4)

        piezas.append(T.pieza(f"{NOMBRE}_Sandalia{lado}", hueso, [("cuero", suela), ("bronce", tiras)]))
    return piezas


def escudo():
    """Escudo redondo de 1,8 studs en la mano izquierda, mirando al frente y un poco hacia afuera:
    bronce, borde de oro y manzana dorada con una hoja en el centro."""
    _, _, mc, mm = T.caja_parte("LeftHand")
    afuera = 1 if mc.x > 0 else -1
    r = ESCUDO_DIAMETRO / 2
    giro = _g(afuera * -25, "Z")
    normal = giro @ Vector((0, -1, 0))
    centro = mc + Vector((afuera * (mm.x + 0.05), 0, 0)) + normal * 0.08

    def disco(bm):
        T.cilindro(bm, centro - normal * 0.02, centro + normal * 0.03, r, 32, r * 0.9)

    def oro(bm):
        aro = [centro + normal * 0.032 + giro @ Vector((math.cos(a) * r * 0.95, 0, math.sin(a) * r * 0.95)) for a in (2 * math.pi * i / 32 for i in range(33))]
        T.tubo(bm, aro, 0.022, 6, tapas=False)
        T.bloque_redondo(bm, centro + normal * 0.045, Vector((r * 0.32, r * 0.3, r * 0.32)), 0.8, 16, 10)  # manzana
        T.caja(bm, centro + normal * 0.06 + giro @ Vector((r * 0.12, 0, r * 0.4)), Vector((r * 0.2, 0.012, r * 0.09)), giro @ _g(30, "Y"))  # hoja
        T.cilindro(bm, centro + normal * 0.05 + giro @ Vector((0, 0, r * 0.28)), centro + normal * 0.05 + giro @ Vector((0, 0, r * 0.42)), 0.01, 6)  # cabito

    return T.pieza(f"{NOMBRE}_Escudo", "LeftHand", [("bronce", disco), ("oro", oro)])


def lanza():
    """Lanza de 6 studs en la mano derecha, vertical: asta de madera oscura, punta de bronce en hoja
    de laurel y regatón de bronce abajo."""
    _, _, mc, _ = T.caja_parte("RightHand")
    base = Vector((mc.x, mc.y - 0.02, B.caja_de(B.partes())[0].z + 0.02))
    tope = base + Vector((0, 0, LANZA_LARGO * 0.85))

    def asta(bm):
        T.cilindro(bm, base + Vector((0, 0, 0.06)), tope, 0.022, 10)

    def bronce(bm):
        T.cilindro(bm, base, base + Vector((0, 0, 0.07)), 0.012, 10, 0.026)  # regatón
        v = T.punta(bm, tope - Vector((0, 0, 0.02)), base + Vector((0, 0, LANZA_LARGO)), 0.07, 8)
        for p in v:  # hoja de laurel: aplastada al frente
            p.co.y = tope.y + (p.co.y - tope.y) * 0.25

    return T.pieza(f"{NOMBRE}_Lanza", "RightHand", [("madera-oscura", asta), ("bronce", bronce)])


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [casco(), *coraza(), capa(), *brazaletes(), *grebas(), escudo(), lanza()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas("atalanta_boceto", B.partes() + piezas))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------


def _hoja(bm, centro, largo, ancho, direccion, afuera, grosor=0.006):
    """Hoja en relieve (olivo, laurel): rombo alargado con las puntas afinadas, acostado sobre la
    superficie que mira hacia `afuera` y apuntando a `direccion`."""
    d = Vector(direccion).normalized()
    n = Vector(afuera).normalized()
    antes = set(bm.verts)
    perfil = (0.0, 0.55, 0.95, 1.0, 0.8, 0.45, 0.0)  # ancha cerca de la base, fina en la punta
    pts = [centro + d * largo * (i / (len(perfil) - 1) - 0.5) for i in range(len(perfil))]
    T.tubo(bm, pts, [ancho / 2 * r + 0.0005 for r in perfil], 6)
    v = [p for p in bm.verts if p not in antes]
    for p in v:  # aplastada contra la superficie
        p.co = p.co - n * (p.co - centro).dot(n) * (1 - grosor / ancho)
    return v


def _rama(bm, inicio, fin, afuera, hojas=6, largo_hoja=0.035):
    """Rama de olivo grabada: tallo fino con hojas alternadas."""
    inicio, fin = Vector(inicio), Vector(fin)
    eje = fin - inicio
    n = Vector(afuera).normalized()
    lado = n.cross(eje).normalized()
    T.tubo(bm, [inicio, fin], 0.004, 4)
    for k in range(hojas):
        t = (k + 0.7) / (hojas + 0.5)
        s = 1 if k % 2 else -1
        p = inicio + eje * t
        d = (eje.normalized() * 0.8 + lado * s * 0.7).normalized()
        _hoja(bm, p + d * largo_hoja * 0.5 + n * 0.003, largo_hoja, largo_hoja * 0.35, d, n)
    _hoja(bm, fin + eje.normalized() * largo_hoja * 0.4, largo_hoja, largo_hoja * 0.35, eje, n)


def _meandro(bm, centro, ancho, alto, afuera, arriba=(0, 0, 1), vueltas=4, g=0.006):
    """Guarda griega (meandro) en relieve: `vueltas` llaves cuadradas en una tira."""
    n = Vector(afuera).normalized()
    up = Vector(arriba).normalized()
    lado = up.cross(n).normalized()
    giro = Matrix((lado, n, up)).transposed()
    paso = ancho / vueltas

    def barra(x0, z0, x1, z1):
        a = centro + lado * x0 + up * z0
        b = centro + lado * x1 + up * z1
        tam = Vector((abs(x1 - x0) + g, g, abs(z1 - z0) + g))
        T.caja(bm, (a + b) / 2, tam, giro)

    h = alto / 2
    barra(-ancho / 2, -h, ancho / 2, -h)  # filetes de arriba y abajo
    barra(-ancho / 2, h, ancho / 2, h)
    for k in range(vueltas):
        x = -ancho / 2 + k * paso + paso * 0.15
        w = paso * 0.7
        barra(x, -h, x, h * 0.55)
        barra(x, h * 0.55, x + w, h * 0.55)
        barra(x + w, h * 0.55, x + w, -h * 0.25)
        barra(x + w, -h * 0.25, x + w * 0.4, -h * 0.25)


def d_casco():
    """Casco corintio abierto: cúpula con borde levantado, carrilleras con filo y remaches, nasal,
    cejas marcadas, cubrenuca, soporte de la cresta y crin azul liga en mechones de la frente a la
    nuca."""
    _, hmax, hc, hm = T.caja_parte("Head")
    m = hm + Vector((0.028, 0.028, 0.024))
    frente = hc.y - m.y
    cz = hmax.z + 0.03  # altura del soporte de la cresta

    def bronce(bm):
        T.bloque_redondo(bm, hc + Vector((0, 0.005, 0.012)), m, 0.4, 36, 20)  # cúpula
        T.bloque_redondo(bm, Vector((hc.x, hc.y + 0.005, hc.z + hm.z * 0.32)), Vector((m.x + 0.008, m.y + 0.008, 0.012)), 0.6, 36, 4)  # banda de la frente
        for s in (-1, 1):
            c = Vector((hc.x + s * m.x * 0.62, frente + 0.012, hc.z - hm.z * 0.38))
            T.bloque_redondo(bm, c, Vector((m.x * 0.33, 0.02, hm.z * 0.5)), 0.4, 14, 8)  # carrillera
            T.bloque_redondo(bm, c + Vector((s * m.x * 0.1, -0.012, 0)), Vector((m.x * 0.2, 0.01, hm.z * 0.42)), 0.5, 12, 6)  # filo levantado
            T.bloque_redondo(bm, Vector((hc.x + s * m.x * 0.42, frente - 0.004, hc.z + hm.z * 0.2)), Vector((m.x * 0.38, 0.014, 0.016)), 0.5, 12, 4)  # ceja
            for k in range(4):
                T.remache(bm, c + Vector((s * m.x * 0.28, -0.022, hm.z * (0.4 - k * 0.25))), 0.008)
        T.bloque_redondo(bm, Vector((hc.x, frente - 0.006, hc.z + hm.z * 0.0)), Vector((0.016, 0.014, hm.z * 0.38)), 0.5, 8, 8)  # nasal
        T.bloque_redondo(bm, Vector((hc.x, hc.y + m.y + 0.004, hc.z - hm.z * 0.6)), Vector((m.x * 0.85, 0.018, hm.z * 0.28)), 0.5, 20, 6)  # cubrenuca
        for k in range(5):  # soporte de la cresta, con pernos
            y = hc.y - m.y * 0.7 + k * m.y * 0.35
            T.caja(bm, Vector((hc.x, y, cz - 0.008)), Vector((0.03, m.y * 0.3, 0.02)))
            T.remache(bm, Vector((hc.x + 0.016, y, cz - 0.008)), 0.006, (1, 0, 0))

    def crin(bm):
        r = m.y * 1.02
        for k in range(24):
            a = math.pi * (0.95 - 0.9 * k / 23)
            raiz = Vector((hc.x, hc.y + math.cos(a) * r * 0.75, cz))
            alto = 0.11 + 0.04 * math.sin(a)
            for s in (-1, 1):  # mechón partido en dos que se abren un poco
                pts = [raiz + Vector((s * 0.006 * t, math.cos(a) * 0.03 * t, alto * t)) for t in (0, 0.5, 1)]
                T.tubo(bm, pts, [0.012, 0.011, 0.004], 5)
        for k in range(10):  # cola que cae por la nuca
            x = (k - 4.5) * 0.009
            pts = [Vector((hc.x + x, hc.y + r * 0.8, cz)), Vector((hc.x + x * 1.4, hc.y + r * 1.15, cz - 0.08)), Vector((hc.x + x * 1.8, hc.y + r * 1.2, hc.z - hm.z * 0.4))]
            T.tubo(bm, pts, [0.009, 0.008, 0.003], 5)

    return T.pieza_separada(f"{NOMBRE}_Casco", "Head", [("bronce", bronce), ("liga", crin)])


def d_coraza():
    """Coraza musculada: pectorales y abdomen marcados, cuello y sisas con reborde, hombreras
    (epomides) atadas al pecho, ramas de olivo grabadas y bisagras a los costados. Cintura con
    cinturón y falda de pteruges de cuero en 2 filas con tachas de bronce."""
    objs = []
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03
    _, _, ac, am = T.caja_parte("LeftUpperArm")

    def bronce(bm):
        T.bloque_redondo(bm, tc, tm + Vector((0.03, 0.03, 0.01)), 0.3, 28, 14)
        for s in (-1, 1):
            T.bloque_redondo(bm, Vector((tc.x + s * tm.x * 0.45, frente, tc.z + tm.z * 0.32)), Vector((tm.x * 0.42, 0.022, tm.z * 0.33)), 0.65, 16, 8)  # pectoral
            for k in range(3):  # abdomen
                T.bloque_redondo(bm, Vector((tc.x + s * tm.x * 0.2, frente + 0.004, tc.z - tm.z * (0.15 + k * 0.27))), Vector((tm.x * 0.18, 0.014, tm.z * 0.11)), 0.6, 10, 6)
            T.bloque_redondo(bm, Vector((tc.x + s * (abs(ac.x) - am.x * 0.1), tc.y, tmax.z + 0.012)), Vector((am.x * 1.1, tm.y + 0.04, 0.016)), 0.5, 16, 6)  # epomide
            T.cilindro(bm, Vector((tc.x + s * tm.x * 0.75, frente - 0.01, tmax.z - 0.04)), Vector((tc.x + s * tm.x * 0.75, frente - 0.02, tmax.z - 0.04)), 0.018, 12)  # anilla
            for k in range(3):  # bisagras laterales
                p = Vector((tc.x + s * (tm.x + 0.032), tc.y, tc.z + tm.z * (0.5 - k * 0.5)))
                T.cilindro(bm, p - Vector((0, 0, 0.025)), p + Vector((0, 0, 0.025)), 0.012, 8)
                T.remache(bm, p + Vector((0, -0.02, 0)), 0.007)
        T.bloque_redondo(bm, Vector((tc.x, tc.y, tmax.z + 0.008)), Vector((tm.x * 0.45, tm.y * 0.7, 0.014)), 0.6, 20, 4)  # reborde del cuello
        T.bloque_redondo(bm, Vector((tc.x, frente + 0.01, tmin.z + 0.012)), Vector((tm.x + 0.035, 0.016, 0.014)), 0.5, 20, 4)  # reborde de abajo

    def olivo(bm):
        for s in (-1, 1):
            _rama(bm, Vector((tc.x + s * tm.x * 0.12, frente - 0.012, tmin.z + 0.05)), Vector((tc.x + s * tm.x * 0.8, frente - 0.012, tc.z + tm.z * 0.05)), (0, -1, 0), hojas=7)
            _rama(bm, Vector((tc.x + s * tm.x * 0.2, tc.y + tm.y + 0.032, tmin.z + 0.05)), Vector((tc.x + s * tm.x * 0.85, tc.y + tm.y + 0.032, tc.z + tm.z * 0.4)), (0, 1, 0), hojas=6)

    objs += T.pieza_separada(f"{NOMBRE}_Coraza", "UpperTorso", [("bronce", bronce)])
    objs += T.pieza_separada(f"{NOMBRE}_Coraza_Olivo", "UpperTorso", [("oro", olivo)])

    lmin, _, lc, lm = T.caja_parte("LowerTorso")

    def cinturon(bm):
        T.bloque_redondo(bm, lc + Vector((0, 0, lm.z * 0.3)), Vector((lm.x + 0.03, lm.y + 0.03, lm.z * 0.6)), 0.3, 24, 8)
        T.bloque_redondo(bm, lc + Vector((0, 0, lm.z * 0.5)), Vector((lm.x + 0.04, lm.y + 0.04, 0.02)), 0.3, 24, 4)
        T.bloque_redondo(bm, Vector((lc.x, lc.y - lm.y - 0.045, lc.z + lm.z * 0.5)), Vector((0.035, 0.008, 0.03)), 0.6, 12, 4)  # hebilla

    filas = ((0.26, lmin.z + 0.06, 0.035, 12), (0.34, lmin.z + 0.02, 0.055, 12))

    def _tira(fila, i):
        largo, z0, extra, n = filas[fila]
        a = 2 * math.pi * (i + 0.5 * fila) / n
        p = Vector((lc.x + math.sin(a) * (lm.x + extra), lc.y - math.cos(a) * (lm.y + extra), z0 - largo / 2 + 0.05))
        return p, _g(math.degrees(a), "Z"), largo, Vector((math.sin(a), -math.cos(a), 0))

    def pteruges(bm):
        for fila in (0, 1):
            for i in range(filas[fila][3]):
                p, giro, largo, _ = _tira(fila, i)
                v = T.caja(bm, p, Vector((0.06, 0.01, largo)), giro)
                for q in v:  # la punta de abajo, redondeada y un poco abierta
                    if q.co.z < p.z - largo * 0.4:
                        q.co.x += (q.co.x - p.x) * 0.15
                        q.co.y += (q.co.y - p.y) * 0.15

    def tachas(bm):
        for fila in (0, 1):
            for i in range(filas[fila][3]):
                p, _, largo, n = _tira(fila, i)
                for t in (0.25, -0.38):
                    T.remache(bm, p + n * 0.007 + Vector((0, 0, largo * t)), 0.008, n)

    objs += T.pieza_separada(f"{NOMBRE}_Cintura", "LowerTorso", [("bronce", cinturon)])
    objs += T.pieza_separada(f"{NOMBRE}_Cintura_Cuero", "LowerTorso", [("cuero", pteruges)])
    objs += T.pieza_separada(f"{NOMBRE}_Cintura_Tachas", "LowerTorso", [("oro", tachas)])
    return objs


def d_capa():
    """Capa corta azul liga hasta la cintura, simulada (pliegues horneados), prendida con 2 broches
    de oro en forma de flor con anillo."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    _, _, ac, am = T.caja_parte("LeftUpperArm")
    hombro_x = abs(ac.x) + am.x
    largo = tmax.z - (lc.z + lm.z * 0.2)
    tela = T.capa(NOMBRE, "liga", largo=largo, ancho=hombro_x / tm.x * 0.95, vuelo=1.25, pliegues=6, hondo=0.025,
                  columnas=22, filas=24, cuadros=45, grosor=0.01,
                  choques_extra=[o for o in piezas_detalle() if o.name.startswith(f"{NOMBRE}_Coraza")])

    def broches(bm):
        for s in (-1, 1):
            c = Vector((tc.x + s * tm.x * 0.85, tc.y - tm.y - 0.04, tmax.z - 0.05))
            T.cilindro(bm, c + Vector((0, 0.012, 0)), c - Vector((0, 0.008, 0)), 0.04, 20)
            T.cilindro(bm, c - Vector((0, 0.008, 0)), c - Vector((0, 0.016, 0)), 0.018, 16)  # centro
            for k in range(6):  # pétalos
                a = 2 * math.pi * k / 6
                T.remache(bm, c + Vector((math.cos(a) * 0.03, -0.012, math.sin(a) * 0.03)), 0.01)
            T.tubo(bm, [c + Vector((math.cos(a) * 0.045, 0.004, math.sin(a) * 0.045)) for a in (2 * math.pi * i / 20 for i in range(21))], 0.005, 5, tapas=False)

    return [tela] + T.pieza_separada(f"{NOMBRE}_Capa_Oro", "UpperTorso", [("oro", broches)])


def d_brazaletes():
    """Brazaletes de bronce con dos rebordes y una guarda griega en relieve al frente y afuera."""
    objs = []
    for lado, hueso in T._lados("LowerArm"):
        _, _, c, m = T.caja_parte(hueso)
        afuera = 1 if c.x > 0 else -1
        cz = c.z - m.z * 0.1
        mm = Vector((m.x + 0.025, m.y + 0.025, m.z * 0.8))

        def braza(bm, c=c, m=m, cz=cz, mm=mm, afuera=afuera):
            T.bloque_redondo(bm, Vector((c.x, c.y, cz)), mm, 0.45, 20, 8)
            for k in (-1, 1):
                T.bloque_redondo(bm, Vector((c.x, c.y, cz + k * mm.z * 0.85)), Vector((mm.x + 0.01, mm.y + 0.01, 0.012)), 0.45, 20, 4)
            _meandro(bm, Vector((c.x, c.y - mm.y - 0.003, cz)), mm.x * 1.6, mm.z * 1.1, (0, -1, 0), vueltas=3, g=0.007)
            _meandro(bm, Vector((c.x + afuera * (mm.x + 0.003), c.y, cz)), mm.y * 1.6, mm.z * 1.1, (afuera, 0, 0), vueltas=3, g=0.007)

        objs += T.pieza_separada(f"{NOMBRE}_Brazalete{lado}", hueso, [("bronce", braza)])
    return objs


def d_grebas():
    """Grebas de bronce con rodilla y pantorrilla marcadas, reborde y remaches; sandalias de suela de
    cuero con tiras cruzadas y hebillas de bronce."""
    objs = []
    for lado, hueso in T._lados("LowerLeg"):
        _, pmax, c, m = T.caja_parte(hueso)

        def greba(bm, c=c, m=m, pmax=pmax):
            T.bloque_redondo(bm, Vector((c.x, c.y - 0.005, c.z)), Vector((m.x + 0.022, m.y + 0.022, m.z * 0.95)), 0.5, 20, 12)
            T.bloque_redondo(bm, Vector((c.x, c.y - m.y - 0.02, pmax.z - m.z * 0.15)), Vector((m.x * 0.6, 0.02, m.z * 0.22)), 0.7, 14, 8)  # rodilla
            for s in (-1, 1):
                T.bloque_redondo(bm, Vector((c.x + s * m.x * 0.35, c.y + m.y + 0.012, c.z + m.z * 0.15)), Vector((m.x * 0.35, 0.016, m.z * 0.45)), 0.6, 12, 8)  # pantorrilla
                T.bloque_redondo(bm, Vector((c.x + s * m.x * 0.3, c.y - m.y - 0.022, c.z - m.z * 0.2)), Vector((m.x * 0.18, 0.01, m.z * 0.4)), 0.6, 10, 6)  # canilla
            for k in (-1, 1):
                T.bloque_redondo(bm, Vector((c.x, c.y - 0.005, c.z + k * m.z * 0.92)), Vector((m.x + 0.03, m.y + 0.03, 0.01)), 0.5, 20, 4)
            for k in range(5):
                a = math.pi * (0.15 + 0.7 * k / 4)
                T.remache(bm, Vector((c.x + math.cos(a) * (m.x + 0.03), c.y - math.sin(a) * (m.y + 0.03), c.z + m.z * 0.8)), 0.007, (math.cos(a), -math.sin(a), 0))

        objs += T.pieza_separada(f"{NOMBRE}_Greba{lado}", hueso, [("bronce", greba)])
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)

        def suela(bm, fc=fc, fm=fm, fmin=fmin):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.02, fmin.z + 0.012)), Vector((fm.x + 0.012, fm.y + 0.04, 0.014)), 0.3, 20, 4)
            for k in (-0.6, -0.1, 0.4, 0.8):
                T.bloque_redondo(bm, Vector((fc.x, fc.y + k * fm.y, fc.z)), Vector((fm.x + 0.012, 0.01, fm.z + 0.006)), 0.5, 12, 4)
            for s in (-1, 1):  # tiras cruzadas al frente
                _, _, cc, _ = T.caja_parte(hueso)
                a = Vector((fc.x - s * fm.x, fc.y - fm.y * 0.6, fc.z + fm.z * 0.3))
                b = Vector((fc.x + s * fm.x, fc.y + fm.y * 0.3, fc.z + fm.z + 0.004))
                T.tubo(bm, [a, b], 0.007, 4)

        def hebillas(bm, fc=fc, fm=fm):
            for s in (-1, 1):
                T.cilindro(bm, Vector((fc.x + s * (fm.x + 0.01), fc.y + fm.y * 0.4, fc.z)), Vector((fc.x + s * (fm.x + 0.018), fc.y + fm.y * 0.4, fc.z)), 0.014, 10)

        objs += T.pieza_separada(f"{NOMBRE}_Sandalia{lado}", hueso, [("cuero", suela), ("bronce", hebillas)])
    return objs


def _escudo_marco():
    _, _, mc, mm = T.caja_parte("LeftHand")
    afuera = 1 if mc.x > 0 else -1
    giro = _g(afuera * -25, "Z")
    normal = giro @ Vector((0, -1, 0))
    centro = mc + Vector((afuera * (mm.x + 0.11), 0, 0)) + normal * 0.08
    return centro, giro, normal


def d_escudo():
    """Escudo redondo (aspis) de 1,8 studs: cara abombada de bronce con un anillo interior, borde de
    oro con remaches, emblema propio en relieve (manzana dorada con hoja y cabito) y atrás el
    brazal y la empuñadura de cuero."""
    centro, giro, normal = _escudo_marco()
    r = ESCUDO_DIAMETRO / 2

    def P(x, z, y=0.0):
        return centro + giro @ Vector((x, 0, z)) + normal * y

    def bronce(bm):
        T.cilindro(bm, centro - normal * 0.02, centro + normal * 0.03, r * 0.97, 40, r * 0.82)  # cara abombada
        T.cilindro(bm, centro - normal * 0.03, centro - normal * 0.02, r * 0.97, 40)  # dorso
        aro = [P(math.cos(a) * r * 0.62, math.sin(a) * r * 0.62, 0.033) for a in (2 * math.pi * i / 40 for i in range(41))]
        T.tubo(bm, aro, 0.008, 5, tapas=False)  # anillo interior

    def oro(bm):
        aro = [P(math.cos(a) * r * 0.95, math.sin(a) * r * 0.95, 0.01) for a in (2 * math.pi * i / 48 for i in range(49))]
        T.tubo(bm, aro, 0.026, 8, tapas=False)  # borde
        for k in range(16):
            a = 2 * math.pi * k / 16
            T.remache(bm, P(math.cos(a) * r * 0.86, math.sin(a) * r * 0.86, 0.022), 0.01, normal)
        # Manzana: dos lóbulos y hundido arriba, en relieve sobre la cara.
        for s in (-1, 1):
            T.bloque_redondo(bm, P(s * r * 0.13, 0, 0.05), Vector((r * 0.27, r * 0.1, r * 0.33)), 0.85, 20, 12)
        T.bloque_redondo(bm, P(0, -r * 0.1, 0.06), Vector((r * 0.3, r * 0.1, r * 0.27)), 0.85, 20, 12)
        T.cilindro(bm, P(0, r * 0.25, 0.08), P(r * 0.04, r * 0.45, 0.08), 0.014, 8)  # cabito
        _hoja(bm, P(r * 0.2, r * 0.44, 0.085), r * 0.32, r * 0.14, giro @ Vector((0.85, 0, 0.5)), normal, 0.012)

    def cuero(bm):
        T.bloque_redondo(bm, centro - normal * 0.06, Vector((r * 0.25, 0.025, 0.03)), 0.5, 12, 4)  # brazal (porpax)
        T.tubo(bm, [P(r * 0.6, -r * 0.1, -0.035), P(r * 0.7, 0, -0.07), P(r * 0.6, r * 0.1, -0.035)], 0.012, 6)  # empuñadura

    return T.pieza_separada(f"{NOMBRE}_Escudo", "LeftHand", [("bronce", bronce), ("oro", oro), ("cuero", cuero)])


def d_lanza():
    """Lanza de 6 studs: asta de madera oscura con empuñadura de cuero, anillos de bronce, punta en
    hoja de laurel con nervio central y regatón de bronce."""
    _, _, mc, _ = T.caja_parte("RightHand")
    base = Vector((mc.x, mc.y - 0.02, B.caja_de(B.partes())[0].z + 0.02))
    tope = base + Vector((0, 0, LANZA_LARGO * 0.82))
    punta = base + Vector((0, 0, LANZA_LARGO))
    z_mano = mc.z

    def asta(bm):
        T.cilindro(bm, base + Vector((0, 0, 0.1)), tope, 0.022, 12, 0.019)

    def cuero(bm):
        pts = [Vector((base.x + math.cos(a) * 0.024, base.y + math.sin(a) * 0.024, z_mano - 0.1 + a * 0.004)) for a in (i * 0.5 for i in range(0, 100))]
        T.tubo(bm, pts, 0.005, 4)  # tira enrollada

    def bronce(bm):
        T.cilindro(bm, base, base + Vector((0, 0, 0.1)), 0.008, 10, 0.026)  # regatón
        for z in (base.z + 0.11, z_mano - 0.12, z_mano + 0.12, tope.z - 0.06):
            T.cilindro(bm, Vector((base.x, base.y, z)), Vector((base.x, base.y, z + 0.018)), 0.027, 12)

    def hoja_punta(bm):
        T.cilindro(bm, tope - Vector((0, 0, 0.06)), tope + Vector((0, 0, 0.03)), 0.026, 12, 0.02)  # cubo
        _hoja(bm, (tope + punta) / 2 + Vector((0, 0, 0.02)), (punta - tope).length, 0.1, (0, 0, 1), (0, -1, 0), 0.02)
        T.tubo(bm, [tope + Vector((0, -0.011, 0.02)), punta - Vector((0, 0.011, 0.04))], [0.006, 0.002], 4)  # nervio
        T.tubo(bm, [tope + Vector((0, 0.011, 0.02)), punta - Vector((0, -0.011, 0.04))], [0.006, 0.002], 4)

    return T.pieza_separada(f"{NOMBRE}_Lanza", "RightHand", [("madera-oscura", asta), ("cuero", cuero), ("bronce", bronce)]) + T.pieza_separada(
        f"{NOMBRE}_LanzaPunta", "RightHand", [("bronce", hoja_punta)]
    )


GRUPOS = (
    ("Casco", ("Casco",)),
    ("Coraza", ("Coraza", "Cintura")),
    ("Capa", ("Capa",)),
    ("Brazaletes", ("Brazalete",)),
    ("Grebas", ("Greba", "Sandalia")),
    ("Escudo", ("Escudo",)),
    ("Lanza", ("Lanza",)),
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
    with open(os.path.join(B.RENDERS, "atalanta_triangulos.md"), "w", encoding="utf-8") as f:
        f.write(
            "# Atalanta: triángulos por pieza\n\n" + texto + "\n\n"
            "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
            "linajes/arte/blender/texturas/atalanta/.\n"
        )
    return texto


def armar_detalle():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_casco, d_coraza, d_brazaletes, d_grebas, d_escudo, d_lanza, d_capa):  # la capa al final: choca con la coraza
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    casco = [o for o in piezas if _pieza_de(o.name) == "Casco"] + [B.parte("Head")]
    B.render_primer_plano(f"{prefijo}_casco", casco, giro=-35, altura=10, margen=1.3)
    escudo = [o for o in piezas if _pieza_de(o.name) == "Escudo"]
    B.render_primer_plano(f"{prefijo}_escudo", escudo, giro=30, altura=5, margen=1.2)
    punta = [o for o in piezas if o.name.startswith(f"{NOMBRE}_LanzaPunta")]
    B.render_primer_plano(f"{prefijo}_lanza", punta, giro=-30, altura=5, margen=1.4)
    print("Render:", B.render_vistas(prefijo, B.partes() + piezas))


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_atalanta_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, "atalanta")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, "atalanta")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/atalanta/."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    rutas = B.exportar_piezas("atalanta", piezas_detalle())
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
