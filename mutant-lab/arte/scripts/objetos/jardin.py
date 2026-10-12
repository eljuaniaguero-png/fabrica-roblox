"""Jardín Salvaje (ideas/mutant-lab-arte.md, sección 8): selva mutante de noche para correr.

Caminos claros, obstáculos que se leen de lejos y la decoración en tonos apagados. Lo que se
usa para jugar (hongo rebote, liana, charco) lleva neón.
Los módulos de suelo tienen el origen arriba, en el centro (y = 0 en Roblox es el piso).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bmesh  # noqa: E402
from mathutils import Matrix  # noqa: E402

import comun as C  # noqa: E402
from comun import girar, mover  # noqa: E402

G = C.Grupo("Jardin")

TIERRA = "#4a3326"
PASTO = "#24452f"
PASTO_CLARO = "#2f5c3c"
CORTEZA = "#5a3d2b"
HOJAS = "#2e6b3f"
ROCA = "#5d6675"
MADERA = "#7a5235"


# ---------------------------------------------------------------------------
# Suelo por módulos (12 x 12, para armar caminos y desniveles)
# ---------------------------------------------------------------------------


def _matas(bm, puntos, alto=1.0):
    """Matitas de pasto (conos chicos) para que el borde no quede liso."""
    for i, (x, y, z) in enumerate(puntos):
        for k in range(4):
            a = math.radians(90 * k + i * 37)
            m = mover(x + 0.3 * math.cos(a), y + 0.3 * math.sin(a), z - 0.05) @ girar(22, "X" if k % 2 else "Y") @ girar(25 * (k - 1.5), "Z")
            C.cilindro(bm, 0.24, alto * (0.6 + 0.2 * (k % 3)), segmentos=5, matriz=m, radio_arriba=0.01)


@G.objeto("SueloRecto", 3000, apoyo="libre", elevacion=math.radians(35))
def suelo_recto():
    bm = bmesh.new()
    C.caja(bm, (0, 0, -1.3), (11.8, 11.8, 2.2))
    tierra = G.malla("Tierra", bm, TIERRA, bisel=0.3)
    bm = bmesh.new()
    C.caja(bm, (0, 0, -0.22), (12.2, 12.2, 0.44))
    pasto = G.malla("Pasto", bm, PASTO, bisel=0.18)
    bm = bmesh.new()
    _matas(bm, [(-5.5, -5.5, 0), (5.4, -4.6, 0), (5.5, 5.5, 0), (-5.1, 4.9, 0), (0.5, -5.6, 0), (-5.6, 0.6, 0), (2.8, 5.6, 0), (5.6, 1.0, 0)])
    matas = G.malla("Matas", bm, PASTO_CLARO)
    return [tierra, pasto, matas]


@G.objeto("SueloCurva", 3000, apoyo="libre", elevacion=math.radians(45))
def suelo_curva():
    """Curva de 90 grados de un camino de 12 de ancho (radio de adentro 6, de afuera 18).
    El origen es el centro de la curva."""
    bm = bmesh.new()
    C.anillo_plano(bm, 6.1, 17.9, -2.4, -0.2, segmentos=12, desde=0, hasta=90)
    tierra = G.malla("Tierra", bm, TIERRA, bisel=0.3)
    bm = bmesh.new()
    C.anillo_plano(bm, 5.9, 18.1, -0.44, 0, segmentos=12, desde=0, hasta=90)
    pasto = G.malla("Pasto", bm, PASTO, bisel=0.18)
    bm = bmesh.new()
    _matas(bm, [(17.6 * math.cos(math.radians(a)), 17.6 * math.sin(math.radians(a)), 0) for a in (10, 40, 70)])
    matas = G.malla("Matas", bm, PASTO_CLARO)
    return [tierra, pasto, matas]


@G.objeto("SueloRampa", 3000, apoyo="libre", elevacion=math.radians(25))
def suelo_rampa():
    """Rampa de 12 de largo que sube 4 hacia +Y (atrás). El origen es el centro del borde bajo
    de arriba: así se pega a un SueloRecto."""
    # El perfil se dibuja en (y, z) y se estira a lo ancho (x).
    de_lado = Matrix(((0, 0, 1, 0), (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
    bm = bmesh.new()
    C.extruir(bm, [(-6.0, -2.4), (6.0, -2.4), (6.0, 3.8), (-6.0, -0.2)], 11.8, matriz=mover(-5.9) @ de_lado)
    tierra = G.malla("Tierra", bm, TIERRA, bisel=0.3)
    bm = bmesh.new()
    C.extruir(bm, [(-6.1, -0.44), (6.1, 3.56), (6.1, 4.0), (-6.1, 0.0)], 12.2, matriz=mover(-6.1) @ de_lado)
    pasto = G.malla("Pasto", bm, PASTO, bisel=0.15)
    return [tierra, pasto]


@G.objeto("SueloIsla", 4000, apoyo="libre", elevacion=math.radians(15))
def suelo_isla():
    """Isla flotante redonda (radio 6) para saltar, con raíces colgando abajo."""
    bm = bmesh.new()
    perfil = C.suavizar_perfil([(0, -7.5), (1.2, -7.0), (3.2, -5.0), (5.0, -2.6), (5.9, -1.0), (5.9, -0.3), (0, -0.3)], 2)
    C.torno(bm, perfil, segmentos=20)
    C.abollar(bm, 0.7, escala=0.35, semilla=3)
    tierra = G.malla("Tierra", bm, TIERRA)
    bm = bmesh.new()
    C.cilindro(bm, 6.2, 0.5, segmentos=24, matriz=mover(z=-0.5), redondeo=0.2)
    pasto = G.malla("Pasto", bm, PASTO)
    bm = bmesh.new()
    for k in range(6):
        a = math.radians(60 * k + 10)
        x, y = 3.4 * math.cos(a), 3.4 * math.sin(a)
        camino = [(x * (1 - 0.15 * t) + 0.4 * math.sin(t * 5 + k), y * (1 - 0.15 * t) + 0.4 * math.cos(t * 4 + k), -3.6 - t * (3.5 + k % 3)) for t in [i / 7 for i in range(8)]]
        C.tubo(bm, camino, [0.32 - 0.04 * i for i in range(8)], lados=6)
    raices = G.malla("Raices", bm, CORTEZA)
    return [tierra, pasto, raices]


# ---------------------------------------------------------------------------
# Hongos
# ---------------------------------------------------------------------------


def _hongo_plataforma(alto, radio):
    bm = bmesh.new()
    C.cilindro(bm, radio * 0.32, alto - 0.8, segmentos=14, radio_arriba=radio * 0.22, redondeo=0.2)
    C.cilindro(bm, radio * 0.45, 0.6, segmentos=14, radio_arriba=radio * 0.32, redondeo=0.2)
    C.abollar(bm, 0.12, escala=1.2, semilla=int(alto))
    pie = G.malla("Pie", bm, "Piezas.Crema")
    bm = bmesh.new()
    perfil = [(0, alto - 1.0), (radio * 0.5, alto - 1.0), (radio * 0.92, alto - 0.75), (radio, alto - 0.35), (radio * 0.96, alto - 0.05), (radio * 0.85, alto), (0, alto)]
    C.torno(bm, C.suavizar_perfil(perfil, 2), segmentos=24)
    sombrero = G.malla("Sombrero", bm, "Especies.7.Color")
    bm = bmesh.new()
    for k in range(7):
        a = math.radians(360 / 7 * k + 12)
        C.esfera(bm, (radio * 0.93 * math.cos(a), radio * 0.93 * math.sin(a), alto - 0.45), (0.32, 0.32, 0.2), segmentos=8, anillos=5)
    lunares = G.malla("Lunares", bm, "Texto")
    return [pie, sombrero, lunares]


@G.objeto("HongoPlataformaChico", 3000)
def hongo_chico():
    return _hongo_plataforma(4.0, 3.0)


@G.objeto("HongoPlataformaMediano", 3000)
def hongo_mediano():
    return _hongo_plataforma(7.0, 3.5)


@G.objeto("HongoPlataformaAlto", 3000)
def hongo_alto():
    return _hongo_plataforma(10.0, 4.0)


@G.objeto("HongoRebote", 3000)
def hongo_rebote():
    """Hongo con sombrero esponjoso que se aplasta (por código) y lunares de neón."""
    bm = bmesh.new()
    C.cilindro(bm, 0.9, 1.6, segmentos=14, radio_arriba=0.7, redondeo=0.25)
    pie = G.malla("Pie", bm, "Piezas.Crema")
    bm = bmesh.new()
    perfil = [(0, 1.3), (1.6, 1.3), (2.8, 1.6), (3.2, 2.1), (3.0, 2.7), (2.2, 3.3), (1.0, 3.6), (0, 3.65)]
    C.torno(bm, C.suavizar_perfil(perfil, 2), segmentos=24)
    sombrero = G.malla("Sombrero_Anim", bm, "Alerta")
    bm = bmesh.new()
    for anillo, (r, z, cuantos) in enumerate(((2.75, 2.55, 8), (1.7, 3.3, 5))):
        for k in range(cuantos):
            a = math.radians(360 / cuantos * k + anillo * 20)
            C.esfera(bm, (r * math.cos(a), r * math.sin(a), z), (0.36, 0.36, 0.22), segmentos=8, anillos=5)
    C.esfera(bm, (0, 0, 3.62), (0.4, 0.4, 0.15), segmentos=8, anillos=5)
    lunares = G.malla("Lunares_Neon_Anim", bm, "Acento")
    return [pie, sombrero, lunares]


# ---------------------------------------------------------------------------
# Obstáculos y cosas para jugar
# ---------------------------------------------------------------------------


@G.objeto("Liana", 3000, apoyo="cuelga", elevacion=math.radians(10))
def liana():
    """Liana colgante de 12 studs. El origen es el punto de donde cuelga (arriba); abajo tiene
    un aro de neón para agarrarse."""
    bm = bmesh.new()
    camino = [(0.25 * math.sin(i * 0.9), 0.15 * math.cos(i * 0.7), -i * 0.6) for i in range(19)]
    C.tubo(bm, camino, [0.22 - 0.006 * i for i in range(19)], lados=7)
    tallo = G.malla("Tallo", bm, "#2f6b3a")
    bm = bmesh.new()
    for i in range(1, 17, 2):
        x, y, z = camino[i]
        lado = 1 if i % 4 == 1 else -1
        hoja = [(0, 0), (0.5, 0.18), (0.9, 0.0), (0.5, -0.18)]
        C.extruir(bm, hoja, 0.06, matriz=mover(x, y, z) @ girar(90 * lado + 30 * i, "Z") @ girar(-25, "Y"))
    hojas = G.malla("Hojas", bm, "#3e8f4a", bisel=0.02)
    bm = bmesh.new()
    x, y, z = camino[-1]
    C.toro(bm, 0.55, 0.13, segmentos=18, lados=7, matriz=mover(x, y, z - 0.5) @ girar(90, "X"))
    agarre = G.malla("Agarre_Neon", bm, "Acento")
    return [tallo, hojas, agarre]


@G.objeto("CharcoSlime", 3000)
def charco_slime():
    """Charco verde que frena. Plano y con burbujas."""
    bm = bmesh.new()
    forma = []
    for i in range(24):
        a = 2 * math.pi * i / 24
        r = 3.3 + 0.6 * math.sin(3 * a + 0.5) + 0.35 * math.sin(5 * a)
        forma.append((r * math.cos(a) * 1.15, r * math.sin(a) * 0.85))
    C.extruir(bm, forma, 0.18)
    charco = G.malla("Charco_Neon", bm, "Catalizadores.Slime", bisel=0.08, angulo_bisel=20)
    bm = bmesh.new()
    for x, y, r in ((-1.2, 0.4, 0.45), (1.0, -0.6, 0.32), (2.2, 0.9, 0.25), (-2.4, -1.0, 0.3), (0.2, 1.4, 0.2)):
        C.esfera(bm, (x, y, 0.12 + 0.6 * r), r, segmentos=10, anillos=6)
    burbujas = G.malla("Burbujas_Vidrio", bm, "Piezas.Burbujas")
    return [charco, burbujas]


@G.objeto("Arbusto", 3000)
def arbusto():
    """Arbusto redondo donde se esconden las frutas. Las hojas se mueven por código."""
    bm = bmesh.new()
    bolas = [((0, 0, 1.3), 1.5), ((1.2, 0.3, 1.0), 1.1), ((-1.2, -0.2, 1.0), 1.1), ((0.3, -1.0, 1.0), 1.0), ((-0.2, 1.0, 1.1), 1.0), ((0.4, 0.2, 2.2), 1.0)]
    C.metabolas(bm, bolas, resolucion=0.25)
    C.abollar(bm, 0.15, escala=1.5, semilla=5)
    hojas = G.malla("Hojas_Anim", bm, HOJAS, angulo_suave=180)
    C.diezmar(hojas, 1800, angulo_suave=180)
    bm = bmesh.new()
    for x, y, z in ((1.5, -0.9, 1.6), (-1.0, -1.3, 1.9), (0.3, -0.6, 3.0), (-1.9, 0.4, 1.4), (1.2, 1.2, 2.2)):
        for k in range(5):
            a = math.radians(72 * k)
            C.esfera(bm, (x + 0.16 * math.cos(a), y - 0.05, z + 0.16 * math.sin(a)), 0.12, segmentos=6, anillos=4)
        C.esfera(bm, (x, y - 0.1, z), 0.09, segmentos=6, anillos=4)
    flores = G.malla("Flores_Anim", bm, "Piezas.Flores")
    C.asentar([hojas, flores])
    return [hojas, flores]


# ---------------------------------------------------------------------------
# Decoración de fondo
# ---------------------------------------------------------------------------


def _tronco(bm, base, alto, giro, grosor, semilla):
    camino, radios = [], []
    n = 14
    for i in range(n + 1):
        t = i / n
        camino.append((base[0] + giro * math.sin(t * 2.4 + semilla) * t, base[1] + giro * 0.6 * math.cos(t * 1.7 + semilla) * t, alto * t))
        radios.append(grosor * (1.25 - 0.6 * t) + (0.5 * grosor if i == 0 else 0))
    C.tubo(bm, camino, radios, lados=9)
    return camino[-1]


@G.objeto("ArbolMutanteA", 8000, elevacion=math.radians(12))
def arbol_a():
    """Árbol alto de tronco retorcido con tres copas redondas (turquesa)."""
    bm = bmesh.new()
    punta = _tronco(bm, (0, 0), 16, 2.2, 1.6, 1.0)
    ramas = [((-4.5, 0.5, 14.5), (punta[0] * 0.5, 0, 11)), ((4.0, -0.8, 17.0), (punta[0] * 0.7, 0, 13))]
    for fin, inicio in ramas:
        C.tubo(bm, [inicio, ((inicio[0] + fin[0]) / 2, (inicio[1] + fin[1]) / 2, (inicio[2] + fin[2]) / 2 + 0.8), fin], [0.55, 0.4, 0.25], lados=7)
    for k in range(4):
        a = math.radians(90 * k + 20)
        C.tubo(bm, [(0, 0, 1.0), (1.6 * math.cos(a), 1.6 * math.sin(a), 0.4), (2.8 * math.cos(a), 2.8 * math.sin(a), 0.0)], [0.7, 0.45, 0.15], lados=6)
    C.abollar(bm, 0.12, escala=0.8, semilla=2)
    tronco = G.malla("Tronco", bm, CORTEZA)
    bm = bmesh.new()
    copas = [((punta[0], punta[1], punta[2] + 2.0), 3.6), ((-4.8, 0.6, 15.5), 2.8), ((4.3, -0.8, 18.0), 2.6)]
    bolas = []
    for (cx, cy, cz), r in copas:
        bolas += [((cx, cy, cz), r), ((cx + r * 0.5, cy, cz - r * 0.2), r * 0.7), ((cx - r * 0.5, cy + 0.3, cz - r * 0.15), r * 0.7)]
    C.metabolas(bm, bolas, resolucion=0.45)
    copa = G.malla("Copas", bm, "#2aa58f", angulo_suave=180)
    C.diezmar(copa, 3500, angulo_suave=180)
    return [tronco, copa]


@G.objeto("ArbolMutanteB", 8000, elevacion=math.radians(12))
def arbol_b():
    """Árbol torcido con copas en forma de sombrero de hongo (violeta)."""
    bm = bmesh.new()
    punta = _tronco(bm, (0, 0), 12, 3.2, 0.9, 4.0)
    rama = (punta[0] - 5.0, punta[1] + 0.5, 9.0)
    C.tubo(bm, [(punta[0] * 0.4, 0, 6.0), (punta[0] * 0.2 - 2.5, 0.3, 8.0), rama], [0.5, 0.35, 0.22], lados=7)
    C.abollar(bm, 0.1, escala=0.8, semilla=6)
    tronco = G.malla("Tronco", bm, CORTEZA)
    bm = bmesh.new()
    for (cx, cy, cz), r in (((punta[0], punta[1], punta[2] - 0.3), 4.2), ((rama[0], rama[1], rama[2] - 0.2), 2.8)):
        perfil = [(0, -0.3 * r), (r * 0.6, -0.3 * r), (r, -0.1 * r), (r * 0.95, 0.15 * r), (r * 0.6, 0.45 * r), (0, 0.55 * r)]
        C.torno(bm, C.suavizar_perfil(perfil, 2), segmentos=20, matriz=mover(cx, cy, cz))
    copa = G.malla("Copas", bm, "#7a4fd1")
    bm = bmesh.new()
    for (cx, cy, cz), r in (((punta[0], punta[1], punta[2] - 0.3), 4.2), ((rama[0], rama[1], rama[2] - 0.2), 2.8)):
        for k in range(6):
            a = math.radians(60 * k + 15)
            C.esfera(bm, (cx + 0.75 * r * math.cos(a), cy + 0.75 * r * math.sin(a), cz + 0.12 * r), 0.16 * r, segmentos=8, anillos=5)
    lunares = G.malla("Lunares", bm, "#b9a2f0")
    return [tronco, copa, lunares]


def _roca(tam, semilla, bultos):
    """Roca redondeada y chata hecha con bultos que se funden (cada tamaño con su forma).
    Gris piedra: que no se confunda con una fruta."""
    bm = bmesh.new()
    C.metabolas(bm, [((x * tam, y * tam, z * tam), r * tam) for x, y, z, r in bultos], resolucion=tam * 0.16)
    bmesh.ops.scale(bm, vec=(1.0, 1.0, 0.72), verts=bm.verts)
    C.abollar(bm, tam * 0.09, escala=2.2 / tam, semilla=semilla, centro=(0, 0, tam * 0.2))
    roca = G.malla("Piedra", bm, ROCA, angulo_suave=50)
    C.diezmar(roca, 700, angulo_suave=50)
    return [roca]


@G.objeto("RocaChica", 1500)
def roca_chica():
    return _roca(1.6, 1, [(0, 0, 0.35, 0.42), (0.35, 0.1, 0.25, 0.3)])


@G.objeto("RocaMediana", 3000)
def roca_mediana():
    return _roca(3.2, 2, [(0, 0, 0.42, 0.45), (-0.3, 0.15, 0.3, 0.32), (0.25, -0.1, 0.22, 0.28)])


@G.objeto("RocaGrande", 3000)
def roca_grande():
    return _roca(6.0, 3, [(-0.1, 0, 0.3, 0.42), (0.35, 0.1, 0.22, 0.32), (-0.45, -0.1, 0.18, 0.26), (0.1, 0.3, 0.2, 0.3)])


@G.objeto("CartelRecords", 3000)
def cartel_records():
    """Cartel de madera con pantalla (6 x 3,5, centrada a 4,6 de alto) para los récords."""
    ancho, alto, z = 6.0, 3.5, 4.6
    bm = bmesh.new()
    C.marco(bm, ancho, alto, 0.45, 0.5, matriz=mover(z=z))
    for s in (-1, 1):
        C.cilindro(bm, 0.3, z - alto / 2, segmentos=8, matriz=mover(s * (ancho / 2 + 0.22)), radio_arriba=0.26)
    techo = [(-ancho / 2 - 0.9, 0), (0, 1.3), (ancho / 2 + 0.9, 0), (ancho / 2 + 0.6, -0.15), (0, 1.0), (-ancho / 2 - 0.6, -0.15)]
    C.extruir(bm, techo, 1.0, matriz=mover(0, 0.5, z + alto / 2 + 0.4) @ girar(90, "X"))
    C.abollar(bm, 0.04, escala=2.0, semilla=8)
    madera = G.malla("Madera", bm, MADERA, bisel=0.06)
    bm = bmesh.new()
    C.caja(bm, (0, 0.15, z), (ancho, 0.15, alto))
    pantalla = G.malla("Pantalla", bm, "Contorno")
    bm = bmesh.new()
    C.esfera(bm, (0, -0.15, z + alto / 2 + 1.0), 0.28, segmentos=10, anillos=6)
    luz = G.malla("Luz_Neon", bm, "Dorado")
    return [madera, pantalla, luz]


G.terminar()
