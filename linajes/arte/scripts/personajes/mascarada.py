"""Mascarada: traje sobre el maniquí R15 (villano teatral de la Cofradía, ficha de Juani del 30 oct).

Villano teatral y caótico que cambia de "personaje" en cada fase de pelea. Diseño propio: sin
maquillaje de payaso, sin pelo verde, sin traje violeta, sin sonrisa pintada. Silueta: saco largo
de teatro con cola partida, sombrero de copa torcido y una máscara distinta por fase.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/mascarada.py -- boceto

Paso "boceto": bloques sin detalle de las 9 piezas (con la máscara 1 puesta), render de 3 vistas
(renders/mascarada_boceto_vistas.png).

Las 3 máscaras son objetos separados en el mismo lugar; solo una se ve a la vez (mostrar_mascara).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import bpy  # noqa: E402
import centinela as CS  # noqa: E402  (aros)
import cuervo as C  # noqa: E402  (cáscaras y BVH)
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Mascarada"
BLEND = os.path.join(B.BLENDER, "mascarada.blend")
S = B.STUD

# Presupuesto de triángulos por pieza (ficha, total ≤ 35.000).
PRESUPUESTO = {
    "Sombrero": 3000,
    "MascaraTragedia": 3000,
    "MascaraComedia": 3000,
    "MascaraNinguna": 3000,
    "Saco": 10000,
    "Chaleco": 3000,
    "Guantes": 2000,
    "Baston": 3000,
    "Zapatos": 2000,
}
MASCARAS = ("MascaraTragedia", "MascaraComedia", "MascaraNinguna")


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def _arco(bm, centro, radio, desde, hasta, tramos, grosor, alto=0.008):
    """Línea curva de cajitas en el plano XZ (mirando a -Y): ángulos en grados, 0 = derecha."""
    for k in range(tramos):
        a = math.radians(desde + (hasta - desde) * (k + 0.5) / tramos)
        largo = radio * math.radians(abs(hasta - desde)) / tramos * 1.15
        p = centro + Vector((math.cos(a) * radio, 0, math.sin(a) * radio))
        T.caja(bm, p, Vector((largo, alto, grosor)), _g(-math.degrees(a) + 90, "Y"))


def _linea(bm, desde, hasta, grosor, alto=0.008):
    """Cajita fina de `desde` a `hasta` en el plano XZ (grietas, cejas)."""
    desde, hasta = Vector(desde), Vector(hasta)
    d = hasta - desde
    giro = _g(-math.degrees(math.atan2(d.z, d.x)), "Y")
    T.caja(bm, (desde + hasta) / 2, Vector((d.length, alto, grosor)), giro)


# ---------------------------------------------------------------------------
# Boceto de bloques
# ---------------------------------------------------------------------------


def sombrero():
    """Galera negra torcida 14° hacia la derecha del personaje, con cinta cofradía."""
    _, hmax, hc, hm = T.caja_parte("Head")
    eje = _g(-14, "Y") @ _g(-6, "X") @ Vector((0, 0, 1))
    base = Vector((hc.x - 0.02, hc.y + 0.01, hmax.z - 0.015))
    radio = max(hm.x, hm.y) * 0.9

    def galera(bm):
        T.cilindro(bm, base, base + eje * 0.015, radio * 1.6, 24)  # ala
        T.cilindro(bm, base, base + eje * 0.34, radio * 0.92, 24, radio * 1.02)  # copa

    def cinta(bm):
        T.cilindro(bm, base + eje * 0.02, base + eje * 0.075, radio * 0.95, 24)

    return T.pieza(f"{NOMBRE}_Sombrero", "Head", [("negro", galera), ("cofradia", cinta)])


def _placa_mascara(bm, hc, hm):
    T.bloque_redondo(bm, Vector((hc.x, hc.y - hm.y - 0.012, hc.z + hm.z * 0.05)), Vector((hm.x * 0.95, 0.022, hm.z * 0.88)), 0.5, 20, 12)


def mascaras():
    """Las 3 máscaras de fase, en el mismo lugar de la cara."""
    _, _, hc, hm = T.caja_parte("Head")
    y = hc.y - hm.y - 0.036  # frente de la placa
    ojo_z = hc.z + hm.z * 0.25
    ojo_x = hm.x * 0.4
    boca = Vector((hc.x, y, hc.z - hm.z * 0.45))

    # 1. Tragedia: ojos caídos hacia afuera, cejas en ceño triste, boca hacia abajo.
    def tragedia_ojos(bm):
        for s in (-1, 1):
            c = Vector((hc.x + s * ojo_x, y, ojo_z))
            _linea(bm, c + Vector((-s * 0.035, 0, 0.012)), c + Vector((s * 0.035, 0, -0.012)), 0.022)

    def tragedia_trazos(bm):
        for s in (-1, 1):
            c = Vector((hc.x + s * ojo_x, y, ojo_z + 0.05))
            _linea(bm, c + Vector((-s * 0.045, 0, 0.018)), c + Vector((s * 0.04, 0, -0.006)), 0.012)
        _arco(bm, boca + Vector((0, 0, -0.05)), 0.07, 35, 145, 6, 0.014)

    tragedia = T.pieza(
        f"{NOMBRE}_MascaraTragedia",
        "Head",
        [("blanco-armadura", lambda bm: _placa_mascara(bm, hc, hm)), ("neon-aviso", tragedia_ojos), ("negro", tragedia_trazos)],
    )

    # 2. Comedia: ojos en medialuna alegre, sonrisa tallada y grietas.
    def comedia_ojos(bm):
        for s in (-1, 1):
            _arco(bm, Vector((hc.x + s * ojo_x, y, ojo_z - 0.015)), 0.035, 20, 160, 4, 0.014)

    def comedia_trazos(bm):
        _arco(bm, boca + Vector((0, 0, 0.06)), 0.085, 205, 335, 7, 0.018)
        for desde, hasta in (((0.02, 0.17), (0.05, 0.08)), ((0.05, 0.08), (0.03, 0.0)), ((-0.1, -0.12), (-0.06, -0.2))):
            _linea(bm, Vector((hc.x + desde[0], y, hc.z + desde[1])), Vector((hc.x + hasta[0], y, hc.z + hasta[1])), 0.006)

    comedia = T.pieza(
        f"{NOMBRE}_MascaraComedia",
        "Head",
        [("blanco-armadura", lambda bm: _placa_mascara(bm, hc, hm)), ("neon-eclipse", comedia_ojos), ("negro", comedia_trazos)],
    )

    # 3. Ninguna: espejo partido, sin cara, con grietas que brillan.
    def grietas(bm):
        puntos = [(-0.06, 0.18), (-0.01, 0.07), (-0.04, -0.02), (0.02, -0.1), (-0.01, -0.2)]
        for a, b in zip(puntos, puntos[1:]):
            _linea(bm, Vector((hc.x + a[0], y, hc.z + a[1])), Vector((hc.x + b[0], y, hc.z + b[1])), 0.007)
        for a, b in (((-0.01, 0.07), (0.1, 0.12)), ((-0.04, -0.02), (-0.13, 0.02)), ((0.02, -0.1), (0.11, -0.15))):
            _linea(bm, Vector((hc.x + a[0], y, hc.z + a[1])), Vector((hc.x + b[0], y, hc.z + b[1])), 0.005)

    ninguna = T.pieza(
        f"{NOMBRE}_MascaraNinguna",
        "Head",
        [("espejo", lambda bm: _placa_mascara(bm, hc, hm)), ("neon-aviso", grietas)],
    )
    return [tragedia, comedia, ninguna]


def mostrar_mascara(cual):
    """Deja visible solo la máscara `cual` (MascaraTragedia, MascaraComedia o MascaraNinguna)."""
    for m in MASCARAS:
        obj = bpy.data.objects.get(f"{NOMBRE}_{m}")
        if obj:
            obj.hide_render = obj.hide_viewport = m != cual


def saco():
    """Saco de teatro cofradía oscura, abierto adelante, con solapas negras, 6 botones de oro y
    cola larga partida en dos hasta las pantorrillas."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03

    def cuerpo(bm):
        T.caja(bm, tc + Vector((0, 0.005, 0)), tm * 2 + Vector((0.07, 0.05, 0.02)))

    def solapas(bm):
        for s in (-1, 1):
            c = Vector((tc.x + s * tm.x * 0.42, frente - 0.012, tc.z + tm.z * 0.3))
            T.caja(bm, c, Vector((tm.x * 0.42, 0.02, tm.z * 1.3)), _g(s * 18, "Y"))

    def botones(bm):
        for s in (-1, 1):
            for z in (-0.25, -0.55, -0.85):
                p = Vector((tc.x + s * tm.x * 0.62, frente, tc.z + tm.z * z))
                T.cilindro(bm, p, p + Vector((0, -0.012, 0)), 0.016, 10)

    arriba = T.pieza(f"{NOMBRE}_Saco", "UpperTorso", [("cofradia-oscura", cuerpo), ("negro", solapas), ("oro", botones)])

    _, lmax, lc, lm = T.caja_parte("LowerTorso")
    _, _, pc, _ = T.caja_parte("LeftLowerLeg")
    atras = lc.y + lm.y + 0.035

    def faldon(bm):
        T.caja(bm, lc, lm * 2 + Vector((0.07, 0.06, 0.0)))
        alto = lmax.z - pc.z
        for s in (-1, 1):  # las dos colas, separadas abajo
            c = Vector((lc.x + s * lm.x * 0.48, atras + 0.02, lmax.z - alto / 2))
            T.caja(bm, c, Vector((lm.x * 0.92, 0.02, alto)), _g(s * -4, "Y") @ _g(-10, "X"))

    abajo = T.pieza(f"{NOMBRE}_SacoBajo", "LowerTorso", [("cofradia-oscura", faldon)])
    return [arriba, abajo]


def chaleco():
    """Chaleco negro en la abertura del saco y moño blanco en el cuello."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.032

    def frente_chaleco(bm):
        T.caja(bm, Vector((tc.x, frente, tc.z - tm.z * 0.1)), Vector((tm.x * 0.75, 0.012, tm.z * 1.75)))

    def mono(bm):
        c = Vector((tc.x, frente - 0.02, tmax.z - 0.04))
        for s in (-1, 1):
            T.punta(bm, c + Vector((s * 0.075, 0, 0)), c, 0.035, 4)
        T.caja(bm, c, Vector((0.025, 0.025, 0.03)))

    return T.pieza(f"{NOMBRE}_Chaleco", "UpperTorso", [("negro", frente_chaleco), ("blanco-armadura", mono)])


def guantes():
    """Guantes blancos con puño ancho."""
    piezas = []
    for lado, hueso in T._lados("Hand"):
        _, mmax, mc, mm = T.caja_parte(hueso)

        def guante(bm, mc=mc, mm=mm, mmax=mmax):
            T.caja(bm, mc, mm * 2 + Vector((0.025, 0.025, 0.02)))
            T.caja(bm, Vector((mc.x, mc.y, mmax.z - 0.01)), Vector((mm.x * 2 + 0.035, mm.y * 2 + 0.035, 0.03)))

        piezas.append(T.pieza(f"{NOMBRE}_Guante{lado}", hueso, [("blanco-armadura", guante)]))
    return piezas


def baston():
    """Bastón negro hasta el piso, puño de oro con forma de máscara y un naipe gigante arriba."""
    mmin, mmax, mc, mm = T.caja_parte("RightHand")
    afuera = 1 if mc.x > 0 else -1
    x = mc.x + afuera * 0.01
    y = mc.y - mm.y - 0.05  # adelante de la mano, para que no lo tape el brazo
    arriba = mc.z

    def vara(bm):
        T.cilindro(bm, Vector((x, y, 0.01)), Vector((x, y, arriba)), 0.018, 10)

    def puno(bm):
        T.bloque_redondo(bm, Vector((x, y, arriba + 0.04)), Vector((0.045, 0.03, 0.05)), 0.5, 12, 8)

    # El naipe sale del puño hacia afuera, como una bandera, y asoma al costado del cuerpo.
    carta = Vector((x + afuera * (mm.x + 0.13), y, arriba + 0.12))
    giro = _g(afuera * -15, "Y")

    def naipe(bm):
        T.caja(bm, carta, Vector((0.19, 0.012, 0.27)), giro)

    def palo(bm):  # rombo cofradía en la cara del naipe
        T.caja(bm, carta + Vector((0, -0.009, 0)), Vector((0.07, 0.006, 0.07)), giro @ _g(45, "Y"))

    return T.pieza(f"{NOMBRE}_Baston", "RightHand", [("negro", vara), ("oro", puno), ("blanco-armadura", naipe), ("cofradia", palo)])


def zapatos():
    """Zapatos de charol con punta alargada."""
    piezas = []
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)

        def zapato(bm, fc=fc, fm=fm):
            T.caja(bm, fc + Vector((0, -0.03, 0)), fm * 2 + Vector((0.025, 0.09, 0.02)))

        piezas.append(T.pieza(f"{NOMBRE}_Zapato{lado}", hueso, [("charol", zapato)]))
    return piezas


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [sombrero(), *mascaras(), *saco(), chaleco(), *guantes(), baston(), *zapatos()]
    mostrar_mascara("MascaraTragedia")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    visibles = [o for o in piezas if not o.hide_render]
    print("Render:", B.render_vistas("mascarada_boceto", B.partes() + visibles))
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------

# Superficie de algunas mallas (las máscaras son de porcelana: sin paneles ni remaches).
PORCELANA = {"rayones": 0.5, "bordes": 0.3, "suciedad": 0.55, "grano": 0.0}
GUANTE = {"costuras": (0.05, 0.0), "trama": 0.6, "rayones": 0.0, "bordes": 0.25, "suciedad": 0.4, "grano": 0.0}


def _placa(bm, puntos, y, grosor):
    """Placa plana con el contorno `puntos` [(x, z)...] mirando al frente (-Y), de `y` a `y + grosor`."""
    frente = [bm.verts.new((x, y, z)) for x, z in puntos]
    atras = [bm.verts.new((x, y + grosor, z)) for x, z in puntos]
    bm.faces.new(frente)
    bm.faces.new(list(reversed(atras)))
    n = len(puntos)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((frente[i], frente[j], atras[j], atras[i]))


def _torno(bm, perfil, lados, m, curva=None, tapas=True):
    """Sólido de revolución: `perfil` [(radio, alto)...] girado alrededor del eje Z local y movido
    con la matriz `m`. `curva(radio, ángulo)` suma altura (para el ala que se levanta a los costados)."""
    aros = []
    for r, z in perfil:
        aro = []
        for k in range(lados):
            a = 2 * math.pi * k / lados
            extra = curva(r, a) if curva else 0.0
            aro.append(bm.verts.new(m @ Vector((math.cos(a) * r, math.sin(a) * r, z + extra))))
        aros.append(aro)
    for a, b in zip(aros, aros[1:]):
        for k in range(lados):
            q = (k + 1) % lados
            bm.faces.new((a[k], a[q], b[q], b[k]))
    if tapas:
        bm.faces.new(list(reversed(aros[0])))
        bm.faces.new(aros[-1])


def _rombo(bm, centro, ancho, alto, grosor):
    _placa(bm, [(centro.x, centro.z + alto / 2), (centro.x + ancho / 2, centro.z), (centro.x, centro.z - alto / 2), (centro.x - ancho / 2, centro.z)], centro.y, grosor)


def d_sombrero():
    """Galera torcida: copa que se abre apenas arriba con borde enrollado, ala que se levanta a los
    costados, cinta cofradía con moño y un naipe metido en la cinta."""
    _, hmax, hc, hm = T.caja_parte("Head")
    base = Vector((hc.x - 0.02, hc.y + 0.01, hmax.z - 0.015))
    m = Matrix.Translation(base) @ (_g(-14, "Y") @ _g(-6, "X")).to_4x4()
    r = max(hm.x, hm.y) * 0.9
    alto = 0.34

    def copa(z):
        return r * (0.92 + 0.1 * (z / alto) ** 1.5)

    def galera(bm):
        perfil = [(r * 0.86, 0.004)] + [(copa(alto * k / 10), alto * k / 10) for k in range(11)]
        perfil += [(copa(alto) - 0.006, alto + 0.006), (copa(alto) - 0.02, alto + 0.008)]
        _torno(bm, perfil, 32, m)
        # Ala: se curva hacia arriba en los costados (cos² del ángulo) y tiene el borde redondeado.
        ala = [(r * 0.9, 0.0), (r * 1.35, 0.0), (r * 1.62, 0.006), (r * 1.66, 0.016), (r * 1.6, 0.02), (r * 1.3, 0.012), (r * 0.9, 0.012)]
        _torno(bm, ala, 40, m, lambda rr, a: 0.06 * math.cos(a) ** 2 * max(0.0, (rr - r * 1.1) / (r * 0.56)) ** 2)

    def cinta(bm):
        _torno(bm, [(copa(0.02) + 0.005, 0.02), (copa(0.075) + 0.005, 0.075)], 32, m, tapas=False)
        _torno(bm, [(copa(0.02) + 0.001, 0.02), (copa(0.02) + 0.005, 0.02)], 32, m, tapas=False)
        _torno(bm, [(copa(0.075) + 0.005, 0.075), (copa(0.075) + 0.001, 0.075)], 32, m, tapas=False)
        # Moño de la cinta, del lado izquierdo del personaje.
        lado = m @ Vector((copa(0.05) + 0.012, 0, 0.048))
        T.bloque_redondo(bm, lado, Vector((0.01, 0.012, 0.014)), 0.5, 10, 6)
        for s in (-1, 1):
            T.tubo(bm, [lado, lado + m.to_3x3() @ Vector((0.004, s * 0.035, 0.008))], [0.012, 0.016], 8)

    def naipe(bm):
        c = m @ Vector((copa(0.05) + 0.01, 0.045, 0.1))
        T.caja(bm, c, Vector((0.006, 0.07, 0.1)), m.to_3x3() @ _g(-15, "X"))

    def palo(bm):
        c = m @ Vector((copa(0.05) + 0.015, 0.045, 0.11))
        T.bloque_redondo(bm, c, Vector((0.002, 0.012, 0.018)), 0.9, 8, 6)

    return T.pieza_separada(
        f"{NOMBRE}_Sombrero", "Head", [("negro", galera), ("cofradia", cinta), ("cofradia", palo), ("blanco-armadura", naipe)]
    )


def _cara():
    """Medidas comunes de las máscaras: centro, mitades de la placa y un BVH de su frente."""
    _, _, hc, hm = T.caja_parte("Head")
    centro = Vector((hc.x, hc.y + 0.005, hc.z + hm.z * 0.05))
    mitades = Vector((hm.x * 0.98, hm.y + 0.03, hm.z * 0.92))
    arbol = C._bvh(lambda bm: T.bloque_redondo(bm, centro, mitades, 0.5, 40, 28))
    return hc, hm, centro, mitades, arbol


def _en(arbol, x, z, sep=0.0):
    """Punto sobre el frente de la máscara (tirando un rayo de adelante hacia atrás)."""
    p, n = T.sobre_superficie(arbol, Vector((x, -5.0, z)), Vector((0, 1, 0)), sep)
    return p, n


def _trazo(bm, arbol, puntos, radio, sep, lados=6):
    """Tubo pegado a la cara de la máscara siguiendo `puntos` [(x, z)...]."""
    camino = [p for p in (_en(arbol, x, z, sep)[0] for x, z in puntos) if p]
    if len(camino) > 1:
        T.tubo(bm, camino, radio, lados)


def _curva(c, radio, desde, hasta, n=8, aplastar=1.0):
    return [
        (c[0] + math.cos(math.radians(desde + (hasta - desde) * k / n)) * radio, c[1] + math.sin(math.radians(desde + (hasta - desde) * k / n)) * radio * aplastar)
        for k in range(n + 1)
    ]


def _placa_cara(bm, centro, mitades, quedarse=None):
    """Placa curva de la máscara: el frente del superelipsoide, con espesor."""
    def adentro(p):
        return p.y < centro.y - mitades.y * 0.55 and (quedarse is None or quedarse(p))

    C._cascara(bm, centro, mitades, 0.5, 40, 28, adentro, 0.012)


def _correa(bm, hc, hm, centro, mitades):
    """Cinta negra que sostiene la máscara, alrededor de la cabeza."""
    z = centro.z + mitades.z * 0.15
    camino = []
    for k in range(13):
        a = math.radians(-60 + 300 * k / 12) - math.pi / 2
        camino.append(Vector((hc.x + math.cos(a) * (hm.x + 0.018), hc.y + math.sin(a) * (hm.y + 0.018), z)))
    T.tubo(bm, camino[1:-1], 0.008, 6, tapas=True)
    # Borde negro alrededor de la máscara: la separa de la cabeza en pantalla chica.
    arbol = C._bvh(lambda b: T.bloque_redondo(b, centro, mitades, 0.5, 40, 28))
    borde = [(centro.x + math.cos(a) * mitades.x * 0.9, centro.z + math.sin(a) * mitades.z * 0.88) for a in (2 * math.pi * k / 40 for k in range(41))]
    _trazo(bm, arbol, borde, 0.007, 0.004, 6)


def d_mascaras():
    hc, hm, centro, mitades, arbol = _cara()
    x0, z0 = hc.x, centro.z
    ox, oz = hm.x * 0.4, z0 + hm.z * 0.22  # ojos
    piezas = []

    # 1. Tragedia: ceño hundido, ojos caídos, mejillas chupadas, boca hacia abajo y una lágrima.
    def t_placa(bm):
        _placa_cara(bm, centro, mitades)
        for s in (-1, 1):
            _trazo(bm, arbol, [(x0 + s * 0.015, oz + 0.09), (x0 + s * ox * 0.6, oz + 0.06), (x0 + s * ox * 1.35, oz + 0.035)], [0.02, 0.016, 0.01], 0.012, 8)
            _trazo(bm, arbol, _curva((x0 + s * ox, oz), 0.05, 200, 340, 6, 0.6), 0.008, 0.005, 6)  # párpado
        _trazo(bm, arbol, [(x0, oz + 0.04), (x0, oz - 0.04), (x0, oz - 0.08)], [0.008, 0.013, 0.02], 0.01, 8)  # nariz
        _trazo(bm, arbol, _curva((x0, z0 - hm.z * 0.75), 0.13, 30, 150, 8), 0.014, 0.008, 8)  # labio

    def t_ojos(bm):
        for s in (-1, 1):
            c = (x0 + s * ox, oz)
            _trazo(bm, arbol, [(c[0] - s * 0.04, c[1] + 0.012), c, (c[0] + s * 0.04, c[1] - 0.016)], [0.008, 0.015, 0.007], 0.012)

    def t_negro(bm):
        _trazo(bm, arbol, _curva((x0, z0 - hm.z * 0.75), 0.115, 35, 145, 8), [0.005, 0.011, 0.015, 0.017, 0.017, 0.017, 0.015, 0.011, 0.005], 0.012)
        _trazo(bm, arbol, [(x0 - ox, oz - 0.04), (x0 - ox - 0.005, oz - 0.1), (x0 - ox + 0.003, oz - 0.15)], [0.005, 0.008, 0.004], 0.008)
        _correa(bm, hc, hm, centro, mitades)

    piezas += T.pieza_separada(f"{NOMBRE}_MascaraTragedia", "Head", [("blanco-armadura", t_placa), ("neon-aviso", t_ojos), ("negro", t_negro)])

    # 2. Comedia: pómulos altos, ojos en medialuna, sonrisa tallada ancha y grietas.
    def c_placa(bm):
        _placa_cara(bm, centro, mitades)
        for s in (-1, 1):
            _trazo(bm, arbol, [(x0 + s * 0.02, oz + 0.06), (x0 + s * ox, oz + 0.1), (x0 + s * ox * 1.45, oz + 0.075)], [0.012, 0.017, 0.009], 0.01, 8)  # ceja alta
            p, _ = _en(arbol, x0 + s * ox * 1.1, z0 - 0.04, 0.004)
            if p:  # pómulo
                T.bloque_redondo(bm, p, Vector((0.035, 0.01, 0.025)), 0.7, 12, 8)
        _trazo(bm, arbol, [(x0, oz + 0.02), (x0, oz - 0.05), (x0 + 0.01, oz - 0.085)], [0.008, 0.013, 0.018], 0.01, 8)
        _trazo(bm, arbol, _curva((x0, z0 - hm.z * 0.05), 0.15, 205, 335, 10), 0.014, 0.008, 8)  # labio de la sonrisa

    def c_ojos(bm):
        for s in (-1, 1):
            _trazo(bm, arbol, _curva((x0 + s * ox, oz - 0.02), 0.042, 20, 160, 6), [0.005, 0.011, 0.014, 0.015, 0.014, 0.011, 0.005], 0.012)

    def c_negro(bm):
        _trazo(bm, arbol, _curva((x0, z0 - hm.z * 0.05), 0.135, 210, 330, 10), [0.005, 0.012, 0.016, 0.019, 0.02, 0.02, 0.02, 0.019, 0.016, 0.012, 0.005], 0.012)
        for grieta in (
            [(x0 + 0.03, oz + 0.15), (x0 + 0.05, oz + 0.08), (x0 + 0.03, oz + 0.04), (x0 + 0.06, oz - 0.01)],
            [(x0 - 0.12, z0 - 0.1), (x0 - 0.08, z0 - 0.17), (x0 - 0.1, z0 - 0.22)],
            [(x0 + 0.13, oz + 0.05), (x0 + 0.1, oz + 0.02)],
        ):
            _trazo(bm, arbol, grieta, 0.005, 0.006, 4)
        _correa(bm, hc, hm, centro, mitades)

    piezas += T.pieza_separada(f"{NOMBRE}_MascaraComedia", "Head", [("blanco-armadura", c_placa), ("neon-eclipse", c_ojos), ("negro", c_negro)])

    # 3. Ninguna: espejo partido en 3 pedazos apenas corridos, sin cara, con grietas que brillan.
    grieta = [(-0.06, 0.2), (-0.01, 0.07), (-0.04, -0.02), (0.02, -0.1), (-0.01, -0.22)]
    rama = [(-0.01, 0.07), (0.1, 0.12), (0.16, 0.1)]

    def x_grieta(z):
        pts = sorted(grieta, key=lambda p: p[1])
        for (xa, za), (xb, zb) in zip(pts, pts[1:]):
            if za <= z <= zb:
                return xa + (xb - xa) * (z - za) / (zb - za)
        return pts[0][0] if z < pts[0][1] else pts[-1][0]

    def lado_de(p):
        izq = p.x - x0 < x_grieta(p.z - z0)
        arriba = (p.z - z0) > 0.07 + (p.x - x0 + 0.01) * 0.45
        return 0 if izq else (1 if arriba else 2)

    def espejo(bm):
        for k, (corre, gira) in enumerate(((Vector((-0.002, 0, 0)), 0), (Vector((0.003, -0.002, 0.003)), 3), (Vector((0.002, 0.001, -0.002)), -2))):
            tmp = bmesh_nuevo()
            _placa_cara(tmp, centro, mitades, lambda p, k=k: lado_de(p) == k)
            mm = Matrix.Translation(centro + corre) @ _g(gira, "Y").to_4x4() @ Matrix.Translation(-centro)
            import bmesh as BM

            BM.ops.transform(tmp, matrix=mm, verts=tmp.verts)
            pasar(tmp, bm)

    def grietas(bm):
        _trazo(bm, arbol, [(x0 + x, z0 + z) for x, z in grieta], [0.005, 0.008, 0.009, 0.008, 0.005], 0.006, 5)
        _trazo(bm, arbol, [(x0 + x, z0 + z) for x, z in rama], [0.008, 0.006, 0.004], 0.006, 5)
        for x, z in ((-0.12, 0.0), (0.09, -0.16)):  # astillas chicas
            _trazo(bm, arbol, [(x0 + x, z0 + z), (x0 + x + 0.04, z0 + z + 0.025)], 0.004, 0.005, 4)

    def n_negro(bm):
        _correa(bm, hc, hm, centro, mitades)

    piezas += T.pieza_separada(f"{NOMBRE}_MascaraNinguna", "Head", [("espejo", espejo), ("neon-aviso", grietas), ("negro", n_negro)])
    return piezas


def bmesh_nuevo():
    import bmesh

    return bmesh.new()


def pasar(origen, destino):
    """Copia la geometría de un bmesh a otro."""
    me = bpy.data.meshes.new("_tmp")
    origen.to_mesh(me)
    origen.free()
    destino.from_mesh(me)
    bpy.data.meshes.remove(me)


def d_saco():
    """Saco de teatro: cuerpo con hombros marcados y cuello alto atrás, solapas negras en punta con
    ribete y una rosa cofradía, 6 botones de oro, bolsillos, y la cola larga partida en dos simulada
    como tela (pliegues horneados)."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    mt = tm + Vector((0.035, 0.03, 0.01))
    frente = tc.y - mt.y

    def cuerpo(bm):
        T.bloque_redondo(bm, tc, mt, 0.28, 28, 16)
        for s in (-1, 1):  # hombreras de sastre
            T.bloque_redondo(bm, Vector((tc.x + s * tm.x * 0.78, tc.y, tmax.z - 0.01)), Vector((tm.x * 0.28, mt.y * 0.95, 0.03)), 0.5, 14, 8)
        C._cascara(bm, Vector((tc.x, tc.y + 0.01, tmax.z + 0.02)), Vector((tm.x * 0.42, tm.y * 0.9, 0.06)), 0.5, 28, 12,
                   lambda p: p.y > tc.y - tm.y * 0.2 and p.z > tmax.z - 0.01, 0.01)  # cuello alto atrás

    def solapa(s):
        fx = [(0.1, tmax.z - 0.012), (0.18, tc.z - tm.z * 0.55), (0.48, tc.z - tm.z * 0.02), (0.62, tc.z + tm.z * 0.38),
              (0.78, tc.z + tm.z * 0.62), (0.55, tc.z + tm.z * 0.5), (0.44, tmax.z - 0.005)]
        return [(tc.x + s * x * tm.x, z) for x, z in fx]

    def solapas(bm):
        for s in (-1, 1):
            pts = solapa(s)
            _placa(bm, pts, frente - 0.014, 0.014)
            ribete = [Vector((x, frente - 0.016, z)) for x, z in pts[1:6]]
            T.tubo(bm, ribete, 0.004, 6)

    def rosa(bm):  # en la solapa izquierda del personaje
        c = Vector((tc.x + tm.x * 0.5, frente - 0.022, tc.z + tm.z * 0.25))
        T.bloque_redondo(bm, c, Vector((0.012, 0.01, 0.012)), 0.7, 10, 6)
        for k in range(6):
            a = 2 * math.pi * k / 6
            T.bloque_redondo(bm, c + Vector((math.cos(a) * 0.016, 0.004, math.sin(a) * 0.016)), Vector((0.011, 0.006, 0.011)), 0.6, 8, 5)

    def botones(bm):
        for s in (-1, 1):
            for z in (-0.25, -0.55, -0.85):
                p = Vector((tc.x + s * tm.x * 0.64, frente + 0.002, tc.z + tm.z * z))
                T.cilindro(bm, p, p + Vector((0, -0.01, 0)), 0.017, 16)
                CS._aro(bm, p + Vector((0, -0.01, 0)), 0.014, 0.003, 0.003, "Y", 16, 4)
                for k in range(4):
                    a = math.pi / 4 + k * math.pi / 2
                    T.remache(bm, p + Vector((math.cos(a) * 0.005, -0.011, math.sin(a) * 0.005)), 0.0025)

    arriba = T.pieza_separada(f"{NOMBRE}_Saco", "UpperTorso", [("cofradia-oscura", cuerpo), ("negro", solapas), ("cofradia", rosa), ("oro", botones)])

    lmin, lmax, lc, lm = T.caja_parte("LowerTorso")
    ml = lm + Vector((0.035, 0.03, 0.0))

    def faldon(bm):
        T.bloque_redondo(bm, lc, ml, 0.28, 28, 8)
        for s in (-1, 1):
            # Delanteros del saco que bajan en punta, abiertos en el medio.
            pts = [(lc.x + s * lm.x * 0.12, lmax.z), (lc.x + s * (ml.x - 0.005), lmax.z), (lc.x + s * (ml.x - 0.005), lmin.z - 0.03), (lc.x + s * lm.x * 0.35, lmin.z - 0.08)]
            _placa(bm, pts, lc.y - ml.y - 0.008, 0.01)
            # Tapa del bolsillo.
            T.bloque_redondo(bm, Vector((lc.x + s * lm.x * 0.6, lc.y - ml.y - 0.014, lc.z + lm.z * 0.2)), Vector((lm.x * 0.26, 0.006, 0.022)), 0.4, 12, 6)

    abajo = T.pieza_separada(f"{NOMBRE}_SacoBajo", "LowerTorso", [("cofradia-oscura", faldon)])

    _, rmax, rc, _ = T.caja_parte("LeftLowerLeg")
    largo = (tmax.z - 0.02) - (rc.z + 0.02)
    cola = T.capa(NOMBRE, "cofradia-oscura", largo=largo, ancho=1.05, vuelo=1.25, pliegues=3, hondo=0.018,
                  columnas=20, filas=34, cuadros=50, grosor=0.01, tiras=2, corte_desde=0.42, choques_extra=arriba + abajo)
    cola.name = cola.data.name = f"{NOMBRE}_SacoCola"
    return arriba + abajo + [cola]


def d_chaleco():
    """Chaleco negro a rayas finas con 4 botones y puntas abajo, pechera y cuello de camisa
    blancos, y moño blanco."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    frente = tc.y - tm.y - 0.03
    arriba = tmax.z - 0.09
    abajo = tc.z - tm.z * 0.95
    w = tm.x * 0.42

    def chaleco(bm):
        pts = [(tc.x - w * 0.55, tmax.z - 0.02), (tc.x, arriba - 0.02), (tc.x + w * 0.55, tmax.z - 0.02), (tc.x + w, tmax.z - 0.04),
               (tc.x + w, abajo + 0.02), (tc.x + w * 0.45, abajo - 0.035), (tc.x, abajo), (tc.x - w * 0.45, abajo - 0.035),
               (tc.x - w, abajo + 0.02), (tc.x - w, tmax.z - 0.04)]
        _placa(bm, pts, frente - 0.006, 0.008)
        T.bloque_redondo(bm, Vector((tc.x, frente - 0.007, abajo + 0.03)), Vector((w * 0.98, 0.003, 0.006)), 0.4, 16, 4)  # pretina

    def rayas(bm):
        for k in range(-5, 6):
            x = tc.x + k * w / 5.5
            tope = arriba - 0.02 + abs(k) / 5.5 * 0.06
            T.tubo(bm, [Vector((x, frente - 0.0075, tope)), Vector((x, frente - 0.0075, abajo + 0.04))], 0.0018, 4)

    def botones(bm):
        for k in range(4):
            p = Vector((tc.x, frente - 0.006, arriba - 0.06 - k * (arriba - abajo - 0.12) / 3))
            T.bloque_redondo(bm, p, Vector((0.009, 0.004, 0.009)), 0.7, 10, 6)

    def camisa(bm):
        _placa(bm, [(tc.x - w * 0.55, tmax.z - 0.008), (tc.x + w * 0.55, tmax.z - 0.008), (tc.x, arriba - 0.03)], frente - 0.004, 0.004)
        for s in (-1, 1):  # puntas del cuello
            _placa(bm, [(tc.x + s * 0.012, tmax.z - 0.02), (tc.x + s * 0.06, tmax.z + 0.005), (tc.x + s * 0.045, tmax.z - 0.05)], frente - 0.012, 0.004)
        c = Vector((tc.x, frente - 0.024, tmax.z - 0.03))
        T.bloque_redondo(bm, c, Vector((0.014, 0.011, 0.015)), 0.5, 12, 8)
        for s in (-1, 1):
            T.tubo(bm, [c, c + Vector((s * 0.035, 0.002, 0.012)), c + Vector((s * 0.065, 0.004, 0.0)), c + Vector((s * 0.035, 0.002, -0.014)), c],
                   [0.006, 0.014, 0.012, 0.014, 0.006], 8)
            T.tubo(bm, [c + Vector((s * 0.008, 0, -0.01)), c + Vector((s * 0.025, 0.003, -0.045))], [0.007, 0.005], 6)  # puntas que cuelgan

    return T.pieza_separada(f"{NOMBRE}_Chaleco", "UpperTorso", [("negro", chaleco), ("asfalto", rayas), ("oro", botones), ("blanco-armadura", camisa)])


def d_guantes():
    """Guantes blancos con puño acampanado, 3 costuras en el dorso y un botón en el puño."""
    objs = []
    for lado, hueso in T._lados("Hand"):
        _, hmax, hc, hm = T.caja_parte(hueso)
        afuera = 1 if hc.x > 0 else -1

        def guante(bm, hc=hc, hm=hm, hmax=hmax, afuera=afuera):
            T.bloque_redondo(bm, hc, hm + Vector((0.012, 0.012, 0.012)), 0.3, 16, 10)
            T.cilindro(bm, Vector((hc.x, hc.y, hmax.z - 0.02)), Vector((hc.x, hc.y, hmax.z + 0.03)), max(hm.x, hm.y) + 0.014, 16, max(hm.x, hm.y) + 0.03)
            for k in (-1, 0, 1):
                y = hc.y + k * hm.y * 0.45
                T.tubo(bm, [Vector((hc.x + afuera * (hm.x + 0.013), y, hmax.z - 0.03)), Vector((hc.x + afuera * (hm.x + 0.013), y, hc.z - hm.z * 0.3))], 0.0035, 4)
            T.bloque_redondo(bm, Vector((hc.x + afuera * (hm.x + 0.03), hc.y, hmax.z + 0.005)), Vector((0.004, 0.008, 0.008)), 0.7, 8, 6)

        objs += T.pieza_separada(f"{NOMBRE}_Guante{lado}", hueso, [("blanco-armadura", guante)])
    return objs


def d_baston():
    """Bastón negro con anillos y regatón de oro; puño de oro con forma de máscara (cejas, nariz y
    ojos hundidos) y un naipe gigante de esquinas redondeadas con rombos cofradía."""
    mmin, mmax, mc, mm = T.caja_parte("RightHand")
    afuera = 1 if mc.x > 0 else -1
    x = mc.x + afuera * 0.01
    y = mc.y - mm.y - 0.05
    arriba = mc.z
    pm = Vector((x, y, arriba + 0.045))  # puño
    carta = Vector((x + afuera * (mm.x + 0.13), y, arriba + 0.12))
    giro = _g(afuera * -15, "Y")

    def vara(bm):
        T.cilindro(bm, Vector((x, y, 0.05)), Vector((x, y, arriba)), 0.017, 12, 0.019)
        for k in range(2):  # ojos del puño
            T.bloque_redondo(bm, pm + Vector((afuera * -0.017 * (1 - 2 * k), -0.03, 0.01)), Vector((0.009, 0.004, 0.006)), 0.6, 8, 6)

    def oro(bm):
        T.cilindro(bm, Vector((x, y, 0.005)), Vector((x, y, 0.05)), 0.012, 12, 0.019)
        for z in (0.35, arriba - 0.02):
            CS._aro(bm, Vector((x, y, z)), 0.019, 0.006, 0.006, "Z", 16, 6)
        T.bloque_redondo(bm, pm, Vector((0.045, 0.03, 0.055)), 0.55, 16, 12)
        T.tubo(bm, [pm + Vector((-0.035, -0.028, 0.025)), pm + Vector((0, -0.032, 0.03)), pm + Vector((0.035, -0.028, 0.025))], 0.006, 6)
        T.tubo(bm, [pm + Vector((0, -0.032, 0.015)), pm + Vector((0, -0.036, -0.012))], [0.005, 0.008], 6)
        T.tubo(bm, [pm + Vector((-0.018, -0.028, -0.03)), pm + Vector((0, -0.031, -0.025)), pm + Vector((0.018, -0.028, -0.03))], 0.004, 6)
        T.tubo(bm, [pm + Vector((0, 0, 0.05)), carta + giro @ Vector((-afuera * 0.09, 0, -0.1))], 0.006, 6)  # broche del naipe

    def naipe(bm):
        tmp = bmesh_nuevo()
        T.bloque_redondo(tmp, Vector((0, 0, 0)), Vector((0.095, 0.006, 0.135)), 0.12, 24, 12)
        import bmesh as BM

        BM.ops.transform(tmp, matrix=Matrix.Translation(carta) @ giro.to_4x4(), verts=tmp.verts)
        pasar(tmp, bm)

    def rombos(bm):
        for cara in (-1, 1):
            for desplaza, tam in ((Vector((0, 0, 0)), 0.09), (Vector((-0.065, 0, 0.1)), 0.025), (Vector((0.065, 0, -0.1)), 0.025)):
                tmp = bmesh_nuevo()
                _rombo(tmp, Vector((desplaza.x, cara * 0.0065 - (0.003 if cara > 0 else 0), desplaza.z)), tam * 0.7, tam, 0.003)
                import bmesh as BM

                BM.ops.transform(tmp, matrix=Matrix.Translation(carta) @ giro.to_4x4(), verts=tmp.verts)
                pasar(tmp, bm)

    return T.pieza_separada(f"{NOMBRE}_Baston", "RightHand", [("negro", vara), ("oro", oro), ("blanco-armadura", naipe), ("cofradia", rombos)])


def d_zapatos():
    """Zapatos de charol de punta alargada con suela y taco negros y capellada cosida."""
    objs = []
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)
        piso = fc.z - fm.z

        def charol(bm, fc=fc, fm=fm, piso=piso):
            T.bloque_redondo(bm, fc + Vector((0, -0.02, 0.004)), fm + Vector((0.012, 0.035, 0.01)), 0.35, 20, 10)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - fm.y - 0.05, piso + fm.z * 0.6)), Vector((fm.x * 0.85, 0.04, fm.z * 0.6)), 0.45, 16, 8)  # punta
            T.tubo(bm, _arco_y(fc, fm, piso), 0.0035, 5)  # costura de la capellada

        def suela(bm, fc=fc, fm=fm, piso=piso):
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.035, piso + 0.004)), Vector((fm.x + 0.016, fm.y + 0.06, 0.007)), 0.3, 20, 4)
            T.bloque_redondo(bm, Vector((fc.x, fc.y + fm.y * 0.7, piso + 0.012)), Vector((fm.x + 0.01, fm.y * 0.3, 0.014)), 0.35, 12, 4)

        objs += T.pieza_separada(f"{NOMBRE}_Zapato{lado}", hueso, [("charol", charol), ("negro", suela)])
    return objs


def _arco_y(fc, fm, piso):
    """Línea en U sobre el empeine (la costura de la capellada)."""
    pts = []
    for k in range(9):
        a = math.radians(180 * k / 8)
        pts.append(Vector((fc.x + math.cos(a) * (fm.x + 0.012), fc.y - fm.y * 0.35 - math.sin(a) * 0.05, piso + fm.z * 1.6 + math.sin(a) * 0.012)))
    return pts


PIEZAS = (("MascaraTragedia", "MascaraTragedia"), ("MascaraComedia", "MascaraComedia"), ("MascaraNinguna", "MascaraNinguna"),
          ("Sombrero", "Sombrero"), ("Saco", "Saco"), ("Chaleco", "Chaleco"), ("Guantes", "Guante"), ("Baston", "Baston"),
          ("Zapatos", "Zapato"))


def _pieza_de(nombre_obj):
    """Mascarada_SacoCola -> Saco (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for clave, prefijo in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


def mostrar_mascara_detalle(cual):
    for o in piezas_detalle():
        if _pieza_de(o.name) in MASCARAS:
            o.hide_render = o.hide_viewport = _pieza_de(o.name) != cual


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
    puesto = cuenta["_total"] - sum(por_pieza.get(m, 0) for m in MASCARAS[1:])
    filas.append(f"| Puesto (una máscara a la vez) | {C._miles(puesto)} | | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {C._miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, "mascarada_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Mascarada: triángulos por pieza\n\n" + texto + "\n\n"
                "Texturas por malla (1024 px color y normal OpenGL, 512 px rugosidad) en "
                "linajes/arte/blender/texturas/mascarada/. Las de neón no llevan textura.\n")
    return texto


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_sombrero, d_mascaras, d_saco, d_chaleco, d_guantes, d_baston, d_zapatos):
        armar()
    return piezas_detalle()


def _renders(piezas, prefijo):
    cabeza = [o for o in piezas if _pieza_de(o.name) in ("Sombrero", "MascaraTragedia")] + [B.parte("Head")]
    for m in MASCARAS:
        mostrar_mascara_detalle(m)
        B.render_primer_plano(f"{prefijo}_{m.removeprefix('Mascara').lower()}", cabeza, giro=20, altura=6, margen=1.1)
    mostrar_mascara_detalle("MascaraTragedia")
    visibles = [o for o in piezas if not o.hide_render]
    print("Render:", B.render_vistas(prefijo, B.partes() + visibles))


def prueba():
    piezas = armar_detalle()
    print(B.contar_triangulos(piezas))
    _renders(piezas, "_mascarada_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    recetas = {o.name: PORCELANA for o in piezas if _pieza_de(o.name) in MASCARAS or o.name.endswith("_Armadura") and _pieza_de(o.name) != "Chaleco"}
    recetas.update({o.name: GUANTE for o in piezas if _pieza_de(o.name) == "Guantes"})
    D.terminar(piezas, grupos, "mascarada", recetas=recetas)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, "mascarada")
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/mascarada/ (las 3 máscaras incluidas)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    piezas = piezas_detalle()
    for o in piezas:
        o.hide_viewport = False  # las máscaras escondidas no se pueden seleccionar
    rutas = B.exportar_piezas("mascarada", piezas)
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
