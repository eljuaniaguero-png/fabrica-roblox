"""Puerto Óxido, paso 2: las mismas piezas del boceto (puerto_oxido.py) con detalle de forma.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/lugares/puerto_detalle.py -- detalle
    (agregar "hornear" para bisel + UV + texturas con desgaste de detalle.py; tarda)

Mismos nombres, pivotes y medidas que el boceto (grilla de 8 studs), así la calle de muestra y el
mapa de Studio no cambian. Medidas en studs. Lo chico (tornillos, vetas, óxido) va en el normal map.
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import puerto_oxido as P  # noqa: E402

pieza = P.pieza
_barra = P._barra
azar = random.Random(21)

# Materiales nuevos del paso 2
B.MATERIALES.setdefault("neon-cofradia", {"hex": "ff2a4a", "brillo": 6.0})  # letrero del Albatros
B.MATERIALES.setdefault("porton-verde", {"hex": "2f5d5a", "rugosidad": 0.6, "metal": 0.5})  # cortinas y puertas del Albatros
B.MATERIALES.setdefault("vidrio-sucio", {"hex": "2a3a40", "rugosidad": 0.15, "metal": 0.3})

P.PRESUPUESTO.update(
    {
        "Calle_Charco": 200,
        "Albatros_Letrero": 1500,
        "Albatros_Oficina": 8000,
        "Albatros_Herreria": 6000,
        "Albatros_Vidrios": 100,
        "Albatros_Portones": 6000,
        "Albatros_Seguridad": 1500,
        "Albatros_Luces": 200,
        "Albatros_Zocalo": 300,
        "Albatros_Colision": 50,
        "Albatros_Equipos": 1500,
        "Albatros_Camaras": 1500,
        "Grua_Cabina": 6000,
    }
)


# ---------------------------------------------------------------------------
# Ayudas de forma
# ---------------------------------------------------------------------------


def arco(cx, cy, z0, r_in, r_out, prof, n=10, eje="Y"):
    """Medio anillo (0 a 180°) de `n` dovelas, centrado en (cx, cy, z0). Con eje "Y" el arco se ve
    de frente desde -Y; con "X", desde -X."""
    cajas = []
    rm = (r_in + r_out) / 2
    largo = 2 * rm * math.sin(math.pi / (2 * n)) * 1.08
    for i in range(n):
        a = math.pi * (i + 0.5) / n
        if eje == "Y":
            cajas.append(((largo, prof, r_out - r_in), (cx + rm * math.cos(a), cy, z0 + rm * math.sin(a)), (0, -math.degrees(a) - 90, 0)))
        else:
            cajas.append(((prof, largo, r_out - r_in), (cx, cy + rm * math.cos(a), z0 + rm * math.sin(a)), (math.degrees(a) + 90, 0, 0)))
    return cajas


def chapa(ancho, alto, x0, y, z0, paso=0.5, prof=0.18, eje="X"):
    """Chapa ondulada: costillas verticales cada `paso` studs sobre un panel liso."""
    cajas = []
    n = int(ancho / paso)
    for i in range(n):
        c = x0 - ancho / 2 + paso * (i + 0.5)
        if eje == "X":
            cajas.append(((paso * 0.45, prof, alto), (c, y - prof / 2, z0 + alto / 2)))
        else:
            cajas.append(((prof, paso * 0.45, alto), (y - prof / 2, c, z0 + alto / 2)))
    return cajas


def tornillos(puntos, lado=0.22):
    return [((lado, lado, lado), p) for p in puntos]


def caja_poli(ancho, fondo, alto, x, y, z, techo=0.0):
    """Malla suelta de una caja con el techo inclinado `techo` (para remates)."""
    a, f = ancho / 2, fondo / 2
    v = [(x - a, y - f, z), (x + a, y - f, z), (x + a, y + f, z), (x - a, y + f, z)]
    v += [(x - a, y - f, z + alto), (x + a, y - f, z + alto), (x + a, y + f, z + alto + techo), (x - a, y + f, z + alto + techo)]
    caras = [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
    return v, caras


# ---------------------------------------------------------------------------
# Kit chico
# ---------------------------------------------------------------------------


def _tablones(bordes=False):
    cajas = []
    for i in range(6):
        x = -3.4 + i * 1.36
        dz = azar.uniform(-0.06, 0.04)
        cajas.append(((1.2, 8 - azar.uniform(0, 0.3), 0.4), (x, azar.uniform(-0.1, 0.1), -0.2 + dz), (0, 0, azar.uniform(-0.8, 0.8))))
    cajas += [((8, 0.8, 0.8), (0, y, -0.85)) for y in (-3, 3)]  # largueros de abajo
    cajas += tornillos([(-3.4 + i * 1.36, y, 0.02) for i in range(6) for y in (-3, 3)], 0.16)
    return cajas


def _postes(con_soga):
    cil = []
    for x in (-3.6, 3.6):
        for y in (-3.6, 3.6):
            cil.append((0.45, 5.5, (x, y, -4.5), "Z", 8))
            if con_soga:
                cil.append((0.55, 0.3, (x, y, -1.6), "Z", 8))
                cil.append((0.55, 0.3, (x, y, -1.1), "Z", 8))
    return cil


def muelle_recto():
    return pieza("Muelle_Recto", _tablones(), "madera-muelle", cilindros=_postes(True))


def muelle_esquina():
    cajas = _tablones() + [((8, 0.7, 0.7), (0, -3.65, 0.35)), ((0.7, 7.3, 0.7), (3.65, 0.35, 0.35))]
    cil = _postes(True) + [(0.6, 1.6, (3.2, -3.2, 0), "Z", 8)]
    return pieza("Muelle_Esquina", cajas, "madera-muelle", cilindros=cil)


def galpon_pared(tipo):
    cajas = [((8, 0.15, 12), (0, 0.1, 6))]  # panel de atrás
    cajas += [((8, 0.5, 0.5), (0, -0.1, z)) for z in (0.25, 6, 11.75)]  # largueros
    cajas += [((0.5, 0.5, 12), (x, -0.1, 6)) for x in (-3.75, 3.75)]  # columnas
    if tipo == "Lisa":
        cajas += chapa(7, 11.4, 0, -0.35, 0.3)
        cajas += tornillos([(x, -0.5, z) for x in (-3, -1, 1, 3) for z in (0.25, 6, 11.75)])
    elif tipo == "Porton":
        cajas += chapa(7, 1.6, 0, -0.35, 10.1)
        cajas += [((5.8, 0.4, 0.4), (0, -0.6, 9.9))]  # riel
        cajas += [((5.4, 0.25, 9.4), (0.4, -0.9, 4.9))] + chapa(5.2, 9.2, 0.4, -1.0, 0.3, 0.6)
        cajas += [((0.3, 0.5, 1.6), (-2, -1.3, 4.5)), ((0.6, 0.6, 0.6), (-2.2, -0.8, 9.6)), ((0.6, 0.6, 0.6), (2.8, -0.8, 9.6))]
    else:  # ventanas, algunas rotas
        cajas += chapa(7, 6, 0, -0.35, 0.3) + chapa(7, 1.6, 0, -0.35, 10.1)
        for x in (-1.9, 1.9):
            cajas += [((3.2, 0.5, 0.3), (x, -0.4, 6.4)), ((3.2, 0.5, 0.3), (x, -0.4, 9.9)), ((0.3, 0.5, 3.8), (x - 1.45, -0.4, 8.15)), ((0.3, 0.5, 3.8), (x + 1.45, -0.4, 8.15))]
            cajas += [((0.15, 0.3, 3.4), (x, -0.4, 8.15)), ((2.8, 0.3, 0.15), (x, -0.4, 8.15))]
        cajas += [((0.8, 0.1, 1.2), (-2.5, -0.3, 7.2), (0, 20, 0)), ((1.1, 0.1, 0.7), (1.2, -0.3, 9.4), (0, -35, 0))]  # vidrios rotos
    return pieza("Galpon_Pared" + ("" if tipo == "Lisa" else tipo), cajas, "chapa-oxido")


def galpon_techo():
    cajas = []
    for lado in (-1, 1):
        g = -25 * lado
        cajas.append(((8, 4.6, 0.12), (0, 2 * lado, 1), (g, 0, 0)))
        for i in range(10):
            x = -3.6 + i * 0.8
            cajas.append(((0.35, 4.6, 0.15), (x, 2 * lado, 1.12), (g, 0, 0)))
        cajas.append(((8.2, 0.3, 0.3), (0, 4.2 * lado, 0.05)))  # canaleta
    cajas.append(((8.2, 0.8, 0.4), (0, 0, 2.05)))  # cumbrera
    return pieza("Galpon_Techo", cajas, "chapa-oxido")


def calle(vias):
    """Adoquines sueltos (1 x 0,9 studs) con algo de desnivel. Con vías: rieles con perfil y
    durmientes, los adoquines dejan la franja libre."""
    cajas = []
    for fila in range(7):
        y = -4 + 0.57 + fila * 1.143
        if vias and -2.4 < y < 2.4:
            continue
        corr = 0.5 if fila % 2 else 0
        for col in range(6 if not corr else 7):
            x = -4 + corr * -0.667 + col * 1.333 + 0.667
            ancho = 1.24
            if x - ancho / 2 < -4:
                ancho, x = ancho - (-4 - (x - ancho / 2)), -4 + (ancho - (-4 - (x - ancho / 2))) / 2
            if x + ancho / 2 > 4:
                ancho = 4 - (x - ancho / 2)
                x = 4 - ancho / 2
            if ancho < 0.2:
                continue
            cajas.append(((ancho, 1.05, 0.3), (x, y, 0.25 + azar.uniform(-0.04, 0.03))))
    cajas.append(((8, 8, 0.12), (0, 0, 0.06)))
    if vias:
        cajas += [((0.9, 5.2, 0.3), (x, 0, 0.3)) for x in (-3.2, -1.6, 0, 1.6, 3.2)]  # durmientes
        for y in (-1.6, 1.6):
            cajas += [((8, 0.5, 0.12), (0, y, 0.5)), ((8, 0.14, 0.4), (0, y, 0.75)), ((8, 0.32, 0.18), (0, y, 1.0))]
        cajas += [((7.6, 3.6, 0.15), (0, 0, 0.22))]  # balasto
        return pieza("Calle_Vias", cajas, "adoquin")
    return pieza("Calle_Adoquin", cajas, "adoquin")


def charco():
    """Charco suelto (espejo suave) para tirar sobre las calles."""
    n = 10
    v = [(0, 0, 0.42)]
    for i in range(n):
        a = 2 * math.pi * i / n
        r = 1.6 * azar.uniform(0.7, 1.2)
        v.append((math.cos(a) * r * 1.4, math.sin(a) * r, 0.42))
    caras = [(0, 1 + i, 1 + (i + 1) % n) for i in range(n)]
    return pieza("Calle_Charco", [], "charco", mallas=[(v, caras)])


def vereda():
    cajas = [((8, 8, 0.6), (0, 0, 0.3))]
    cajas += [((0.08, 8, 0.1), (x, 0, 0.62)) for x in (-2, 0, 2)]  # juntas de baldosas
    cajas += [((8, 0.08, 0.1), (0, y, 0.62)) for y in (-2, 0, 2)]
    v = pieza("Calle_Vereda", cajas, "adoquin")
    c = pieza("Calle_Cordon", [((8, 0.6, 0.9), (0, -3.7, 0.45)), ((8, 0.2, 0.2), (0, -4.0, 0.85), (45, 0, 0))], "cordon-amarillo")
    return [v, c]


def contenedor(color):
    """Contenedor de 4 x 10 x 4: costillas a los lados, esquineros, puertas con barras y trabas."""
    cajas = [((3.8, 9.8, 3.8), (0, 0, 2))]
    for i in range(14):  # costillas laterales y del techo
        y = -4.4 + i * 0.68
        cajas += [((4.1, 0.3, 3.5), (0, y, 2))]
        cajas += [((3.5, 0.3, 0.1), (0, y, 3.95))]
    for x in (-1.9, 1.9):  # esquineros
        for y in (-4.85, 4.85):
            cajas += [((0.4, 0.4, 4), (x, y, 2))]
    cajas += [((4, 0.3, 0.4), (0, y, z)) for y in (-4.85, 4.85) for z in (0.2, 3.8)]
    cajas += [((0.15, 0.25, 3.4), (x, 5.05, 2)) for x in (-1.4, -0.5, 0.5, 1.4)]  # barras de traba
    cajas += [((0.6, 0.3, 0.2), (x, 5.1, 1.6)) for x in (-1.4, -0.5, 0.5, 1.4)]
    cajas += [((0.05, 0.2, 3.4), (0, 5.0, 2))]  # junta de puertas
    return pieza("Contenedor_" + color.capitalize(), cajas, "cont-" + color)


def props():
    farola = pieza(
        "Prop_Farola",
        [((1.4, 1.4, 0.4), (0, 0, 0.2)), ((1, 1, 1), (0, 0, 0.9)), ((1.4, 1.4, 0.2), (0, 0, 12)), ((1.7, 1.7, 0.25), (0, 0, 13.85))]
        + [((0.12, 0.12, 1.7), (x, y, 12.95)) for x in (-0.6, 0.6) for y in (-0.6, 0.6)],
        "hierro",
        cilindros=[(0.25, 10.6, (0, 0, 1.4), "Z", 8), (0.35, 0.4, (0, 0, 6), "Z", 8), (0.9, 0.7, (0, 0, 13.9), "Z", 4, 0.1)],
    )
    bita = pieza(
        "Prop_Bita",
        [((2.2, 2.2, 0.3), (0, 0, 0.15))] + tornillos([(x, y, 0.35) for x in (-0.85, 0.85) for y in (-0.85, 0.85)]),
        "acero",
        cilindros=[(0.6, 1.4, (0, 0, 0.3), "Z", 10, 0.5), (0.95, 0.35, (0, 0, 1.7), "Z", 10), (0.25, 1.2, (0, 0, 1.2), "X", 8)],
    )
    caj = []
    for cx, cy, cz in ((0, 0, 0), (2.1, 0.3, 0), (1, 0, 2)):
        caj += [((2, 2, 0.12), (cx, cy, cz + 0.06)), ((2, 2, 0.12), (cx, cy, cz + 1.94))]
        caj += [((2, 0.12, 0.5), (cx, cy + s, cz + z)) for s in (-0.94, 0.94) for z in (0.4, 1.0, 1.6)]
        caj += [((0.12, 1.8, 0.5), (cx + s, cy, cz + z)) for s in (-0.94, 0.94) for z in (0.4, 1.0, 1.6)]
    cajones = pieza("Prop_Cajones", caj, "madera-muelle")
    barril = pieza(
        "Prop_Barril",
        [],
        "oxido",
        cilindros=[(0.95, 3, (0, 0, 0), "Z", 12), (1.02, 0.15, (0, 0, 0.6), "Z", 12), (1.02, 0.15, (0, 0, 2.3), "Z", 12), (0.25, 0.1, (0.5, 0, 3), "Z", 6)],
    )
    red = []
    for i in range(7):  # malla de la red, en rombos
        red.append(_barra((-2 + i * 0.66, 0, 2.5), (-2 + i * 0.66 + 0.66, 0, 5.5), 0.06))
        red.append(_barra((-2 + i * 0.66 + 0.66, 0, 2.5), (-2 + i * 0.66, 0, 5.5), 0.06))
    red += [((0.3, 0.3, 6), (-2.2, 0, 3)), ((0.3, 0.3, 6), (2.2, 0, 3)), ((4.7, 0.25, 0.25), (0, 0, 5.8))]
    red += [((0.4, 0.4, 0.4), (-1.2 + i * 1.2, 0, 2.4)) for i in range(3)]  # flotadores
    red = pieza("Prop_Red", red, "soga")
    # Cartel roto "PUERTO ÓXIDO": tablas, una caída; el texto va en una textura aparte.
    cart = [((10, 0.3, 0.9), (0, 0, 8.9 - i * 0.95), (0, 6, 0)) for i in range(3)]
    cart += [((4, 0.3, 0.9), (-2.6, -0.1, 6.1), (0, 18, 0)), ((10.4, 0.4, 0.3), (0, 0, 9.5), (0, 6, 0))]
    cart += [((0.4, 0.4, 7.5), (-4, 0, 3.75)), ((0.4, 0.4, 5), (4, 0, 2.5)), _barra((-4, 0.2, 2), (-1, 0.2, 7), 0.2)]
    cartel = pieza("Prop_Cartel", cart, "oxido")
    v, c = [], []
    for k, (y, w, z) in enumerate(((-4, 0.2, 1.0), (-3, 1.1, 0.4), (-1, 1.5, 0.1), (2, 1.5, 0.1), (4, 1.2, 0.3))):
        v += [(-w, y, 1.4), (-w * 0.7, y, z + 0.3), (0, y, z), (w * 0.7, y, z + 0.3), (w, y, 1.4)]
    for k in range(4):
        for j in range(4):
            a = k * 5 + j
            c.append((a, a + 1, a + 6, a + 5))
    c.append((20, 21, 22, 23, 24))
    bote = pieza("Prop_Bote", [((2.4, 0.3, 0.2), (0, y, 1.0)) for y in (-1.5, 1.2)], "madera-muelle", mallas=[(v, c)])
    # Muro: ladrillos en hileras corridas (cada hilera un bloque con las juntas marcadas).
    m = []
    for fila in range(7):
        z = 0.3 + fila * 0.55
        corr = 0.5 if fila % 2 else 0
        m.append(((8, 0.7, 0.48), (0, 0, z)))
        m += [((0.5, 0.74, 0.48), (-3.75 + corr * 0.5 + i * 2.5, 0, z)) for i in range(4)]
    muro = pieza("Prop_MuroLadrillo", m, "ladrillo")
    remate = pieza("Prop_MuroRemate", [((8.3, 1.3, 0.25), (0, 0, 4.05)), ((8.1, 1.0, 0.25), (0, 0, 4.3))], "piedra-clara", mallas=[caja_poli(7.9, 0.9, 0.1, 0, 0, 4.42, 0.08)])
    reja = [((8, 0.2, 0.2), (0, 0, z)) for z in (0.5, 3.6)]
    reja += [((0.14, 0.14, 3.6), (-3.8 + i * 0.6, 0, 2.0)) for i in range(13)]
    reja += [((0.3, 0.3, 0.4), (-3.8 + i * 0.6, 0, 4.0), (0, 45, 0)) for i in range(13)]  # puntas
    reja += [((0.3, 0.3, 4.4), (x, 0, 2.2)) for x in (-4, 4)]
    reja = pieza("Prop_Reja", reja, "hierro")
    poste = pieza(
        "Prop_Poste",
        [((5, 0.4, 0.4), (0, 0, 20)), ((3, 0.3, 0.3), (0, 0, 18.6)), _barra((-1.2, 0, 18.6), (0, 0, 17), 0.2), _barra((1.2, 0, 18.6), (0, 0, 17), 0.2)]
        + [((0.3, 0.5, 0.5), (x, 0, 20.4)) for x in (-2.2, -0.8, 0.8, 2.2)],
        "hierro",
        cilindros=[(0.35, 22, (0, 0, 0), "Z", 8, 0.25), (0.5, 1.2, (0, 0, 13), "Z", 8)],
    )
    return [farola, bita, cajones, barril, red, cartel, bote, muro, remate, reja, poste]


def tunel_arco():
    """Boca de túnel de piedra: arco de dovelas con clave, pilastras, impostas y cornisa."""
    cajas = [((3, 4, 9), (-6.5, 0, 4.5)), ((3, 4, 9), (6.5, 0, 4.5))]
    cajas += [((3.6, 4.4, 0.6), (x, 0, 9.1)) for x in (-6.5, 6.5)]  # impostas
    cajas += [((3.4, 4.2, 0.8), (x, 0, 0.4)) for x in (-6.5, 6.5)]  # zócalos
    cajas += arco(0, 0, 9.4, 5, 7, 4, 13)
    cajas += [((1.6, 4.4, 2.4), (0, -0.1, 16.6))]  # clave
    cajas += [((16, 4, 3), (0, 0, 17.5)), ((4, 4, 6), (-6, 0, 13)), ((4, 4, 6), (6, 0, 13))]  # tímpano
    cajas += [((16.8, 4.6, 0.6), (0, 0, 19.2)), ((16.4, 4.3, 0.5), (0, 0, 19.7))]  # cornisa
    return pieza("Tunel_Arco", cajas, "piedra-clara")


def _ventana_arco(x, y, z, ancho=3, alto=5):
    r = ancho / 2
    c = [((0.35, 0.5, alto - r), (x - r, y, z + (alto - r) / 2)), ((0.35, 0.5, alto - r), (x + r, y, z + (alto - r) / 2))]
    c += arco(x, y, z + alto - r, r - 0.2, r + 0.15, 0.5, 6)
    c += [((ancho + 0.6, 0.8, 0.3), (x, y - 0.2, z - 0.15))]  # alféizar
    c += [((0.12, 0.2, alto - 0.3), (x, y + 0.1, z + (alto - 0.3) / 2)), ((ancho, 0.2, 0.12), (x, y + 0.1, z + alto * 0.55))]
    return c


def edificio_viejo():
    """Dos pisos de piedra: ventanas altas en arco con alféizar y parteluz, pilastras, faja entre
    pisos, cornisa en dos escalones, puerta en arco y techo de tejas en hileras."""
    cajas = [((24, 16, 18), (0, 0, 9)), ((24.6, 16.6, 1.2), (0, 0, 0.6))]
    cajas += [((24.8, 16.8, 0.6), (0, 0, 9)), ((25.2, 17.2, 0.6), (0, 0, 18.1)), ((25.6, 17.6, 0.5), (0, 0, 18.6))]
    for x in (-12, -4, 4, 12):  # pilastras del frente
        cajas.append(((0.9, 0.5, 17), (x, -8.2, 9)))
    for x in (-8, 8):
        cajas += _ventana_arco(x, -8.25, 2.2, 3, 5.2)
        cajas += _ventana_arco(x, -8.25, 11, 3, 5.5)
    cajas += _ventana_arco(0, -8.25, 11, 3, 5.5)
    cajas += _ventana_arco(0, -8.3, 1.2, 3.4, 6.2)  # puerta
    for y in (-4, 4):  # costados
        cajas += _ventana_arco(-12.25, y, 11, 3, 5.5) if False else []
    cuerpo = pieza("Edificio_Viejo", cajas, "piedra-clara")
    techo = []
    for lado in (-1, 1):
        g = 28 * -lado
        techo.append(((25, 9.4, 0.3), (0, 4 * lado, 21.2), (g, 0, 0)))
        for k in range(8):  # hileras de tejas
            d = -4.2 + k * 1.15
            techo.append(((25, 0.9, 0.35), (0, (4 + d * math.cos(math.radians(28))) * lado - 0, 21.2 + 0.2 - d * math.sin(math.radians(28))), (g, 0, 0)))
    techo.append(((25.2, 0.9, 0.7), (0, 0, 23.6)))
    techo += [((1.6, 1.6, 4), (x, 2, 24)) for x in (-7, 6)]  # chimeneas
    return [cuerpo, pieza("Edificio_ViejoTecho", techo, "teja")]


def arcada():
    cajas = [((1.5, 1.2, 7), (-3.25, 0, 3.5)), ((1.5, 1.2, 7), (3.25, 0, 3.5))]
    cajas += [((1.9, 1.5, 0.4), (x, 0, 7.1)) for x in (-3.25, 3.25)]
    cajas += arco(0, 0, 7.3, 2.5, 3.6, 1.2, 9)
    cajas += [((1.5, 1.2, 4.2), (x, 0, 9.6)) for x in (-3.4, 3.4)]
    cajas += [((8, 1.2, 1.4), (0, 0, 11.3)), ((0.9, 1.4, 1.4), (0, -0.1, 10.6))]
    cajas += [((8.4, 1.6, 0.4), (0, 0, 12.2)), ((8.2, 1.4, 0.3), (0, 0, 12.5))]
    return pieza("Arcada", cajas, "piedra-clara")


def alambrado():
    c = [((0.3, 0.3, 8), (x, 0, 4)) for x in (-4, 4)] + [((0.25, 0.25, 8), (0, 0, 4))]
    c += [((8, 0.2, 0.2), (0, 0, z)) for z in (0.3, 7.8)]
    for i in range(9):
        x = -4 + i
        c.append(_barra((x, 0, 0.3), (x + 1, 0, 7.8), 0.05) if x + 1 <= 4 else ((0.01, 0.01, 0.01), (0, 0, 0)))
        c.append(_barra((x + 1, 0, 0.3), (x, 0, 7.8), 0.05) if x + 1 <= 4 else ((0.01, 0.01, 0.01), (0, 0, 0)))
    c += [_barra((-4, 0, 8), (-4, -1.2, 9), 0.1), _barra((4, 0, 8), (4, -1.2, 9), 0.1)]  # brazos del alambre de púas
    return pieza("Prop_Alambrado", c, "hierro")


# ---------------------------------------------------------------------------
# Grandes
# ---------------------------------------------------------------------------


def grua():
    """Grúa torre: la del boceto con chapas de unión, escalera interna, pasarela en la pluma con
    baranda, carro del gancho y poleas. Cabina con ventanas, carro y gancho de verdad."""
    alto, lado, tramo = 48, 6, 6
    h = lado / 2
    cajas = [((0.9, 0.9, alto), (x, y, alto / 2)) for x in (-h, h) for y in (-h, h)]
    for k in range(alto // tramo):
        z0, z1 = k * tramo, (k + 1) * tramo
        sube = k % 2 == 0
        for x in (-h, h):
            cajas.append(_barra((x, -h, z0 if sube else z1), (x, h, z1 if sube else z0), 0.3))
        for y in (-h, h):
            cajas.append(_barra((-h, y, z0 if sube else z1), (h, y, z1 if sube else z0), 0.3))
        cajas += [((lado, 0.3, 0.3), (0, s, z1)) for s in (-h, h)] + [((0.3, lado, 0.3), (s, 0, z1)) for s in (-h, h)]
        cajas += [((1.3, 1.3, 0.8), (x, y, z1)) for x in (-h, h) for y in (-h, h)]  # chapas de unión
        cajas += [((1.2, 0.12, 0.12), (0, h - 0.6, z0 + j * 0.75)) for j in range(8)]  # escalera
    cajas += [((0.12, 0.12, alto), (s, h - 0.6, alto / 2)) for s in (-0.6, 0.6)]
    cajas += [((8, 8, 0.4), (0, 0, 0.2)), ((2, 2, 1.2), (0, 0, 0.6))]
    zp = alto + 2
    for x in (-1.2, 1.2):
        cajas.append(((0.45, 66, 0.45), (x, -17, zp)))
    cajas.append(((0.45, 66, 0.45), (0, -17, zp + 2.5)))
    for k in range(33):
        y0 = 16 - k * 2
        cajas.append(_barra((-1.2, y0, zp), (0, y0 - 2, zp + 2.5) if k % 2 == 0 else (0, y0, zp + 2.5), 0.22))
        cajas.append(_barra((1.2, y0, zp), (0, y0 - 2, zp + 2.5) if k % 2 == 0 else (0, y0, zp + 2.5), 0.22))
        cajas.append(((2.4, 0.2, 0.2), (0, y0, zp)))
    cajas += [((1.6, 64, 0.12), (2.2, -17, zp - 0.2))] + [((0.1, 64, 0.1), (3, -17, zp + 1))]  # pasarela y baranda
    cajas += [((0.1, 0.1, 1.2), (3, y, zp + 0.4)) for y in range(-48, 16, 4)]
    cajas += [((4.4, 6, 4.2), (0, 13, zp - 1))] + [((4.6, 0.2, 0.3), (0, 13 + d, zp + 1.2)) for d in (-2, 0, 2)]  # contrapeso
    cajas += [((1.4, 1.4, 12), (0, 0, zp + 6)), ((2, 2, 0.6), (0, 0, zp + 12.2))]
    cajas += [_barra((0, 0, zp + 12), (0, -48, zp + 2.5), 0.22), _barra((0, 0, zp + 12), (0, 16, zp + 2.5), 0.22)]
    cajas += [_barra((0, 0, zp + 12), (0, -24, zp + 2.5), 0.18)]
    est = pieza("Grua_Estructura", cajas, "grua-amarillo", cilindros=[(4, 1.2, (0, 0, alto), "Z", 16), (3.2, 0.8, (0, 0, alto + 1.2), "Z", 16)])
    cab = [((4, 4, 3.6), (-4, -2, alto)), ((4.3, 4.3, 0.3), (-4, -2, alto + 1.95)), ((3, 0.1, 1.6), (-4, -4.05, alto + 0.6))]
    cab += [((0.1, 3, 1.6), (-6.05, -2, alto + 0.6)), ((0.2, 0.2, 2), (-6.05, -3.9, alto + 0.6))]
    cab += [((2.4, 2.4, 0.8), (0, -40, zp - 0.6)), ((0.4, 0.4, 0.4), (-0.8, -40, zp - 0.1)), ((0.4, 0.4, 0.4), (0.8, -40, zp - 0.1))]  # carro
    cab += [((1.6, 1.0, 1.2), (0, -40, zp - 21.4))]  # aparejo
    cab += [_barra((0, -40, zp - 22), (0, -40, zp - 23.6), 0.45), _barra((0, -40, zp - 23.6), (0, -40.9, zp - 24.4), 0.4)]
    cab += [_barra((0, -40.9, zp - 24.4), (0, -41.7, zp - 23.6), 0.35), _barra((0, -41.7, zp - 23.6), (0, -41.6, zp - 23.0), 0.3)]
    cil = [(0.12, 20.5, (s, -40, zp - 21), "Z", 6) for s in (-0.3, 0.3)] + [(0.5, 0.3, (0, -40, zp - 0.1), "X", 10)]
    return [est, pieza("Grua_Cabina", cab, "cofradia", cilindros=cil)]


# Galpón del Albatros: dos naves de 32 x 40 (paredes de 22 de alto) y la oficina como edificio
# aparte de dos pisos pegado a la derecha. La escalera de afuera sube a la puerta del piso de arriba.
NAVE_ANCHO, NAVE_FONDO, NAVE_ALTO, TECHO_GRADOS = 32, 40, 22, 20
OFI_X0, OFI_X1, OFI_Y0, OFI_Y1, OFI_ALTO, OFI_PISO = 32, 48, -20, -6, 27, 13.5


def _pared_chapa(largo, centro, y, z0, alto, eje="X", afuera=-1):
    """Pared cerrada de chapa: panel liso + costillas cada 1,2 studs del lado de afuera."""
    if eje == "X":
        cajas = [((largo, 0.3, alto), (centro, y, z0 + alto / 2))]
    else:
        cajas = [((0.3, largo, alto), (y, centro, z0 + alto / 2))]
    n = int(largo / 1.2)
    for i in range(n):
        c = centro - largo / 2 + 1.2 * (i + 0.5)
        if eje == "X":
            cajas.append(((0.5, 0.35, alto), (c, y + afuera * 0.3, z0 + alto / 2)))
        else:
            cajas.append(((0.35, 0.5, alto), (y + afuera * 0.3, c, z0 + alto / 2)))
    return cajas


def _hastial(xc, y, ancho, base, alto):
    """Triángulo del frente (arriba de la pared, bajo el techo a dos aguas)."""
    a = ancho / 2
    v = [(xc - a, y - 0.15, base), (xc + a, y - 0.15, base), (xc, y - 0.15, base + alto), (xc - a, y + 0.15, base), (xc + a, y + 0.15, base), (xc, y + 0.15, base + alto)]
    return v, [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]


def galpon_albatros():
    """Galpón doble cerrado (sin huecos), portones corredizos, techo de chapa a dos aguas con
    cumbrera y canaletas, hastiales y columnas. Malla 2: oficina de ladrillo carmesí de dos pisos
    con ventanal al puerto, escalera exterior con descanso y puerta arriba. Malla 3: letrero neón."""
    g = []
    h = NAVE_FONDO / 2
    sube = NAVE_ANCHO / 2 * math.tan(math.radians(TECHO_GRADOS))
    mallas = []
    for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2):
        for y, afuera in ((-h, -1), (h, 1)):
            if y < 0:  # frente: pared alrededor del portón (14 x 16)
                g += _pared_chapa(9, nave - 11.5, y, 0, NAVE_ALTO, afuera=afuera)
                g += _pared_chapa(9, nave + 11.5, y, 0, NAVE_ALTO, afuera=afuera)
                g += _pared_chapa(14, nave, y, 16, NAVE_ALTO - 16, afuera=afuera)
                f = y - 0.6
                g += [((1.2, 1.4, 16.6), (nave + sx * 7.6, f, 8.3)) for sx in (-1, 1)]  # jambas
                g += [((16.4, 1.4, 1.4), (nave, f, 16.7))]  # dintel
            else:
                g += _pared_chapa(NAVE_ANCHO, nave, y, 0, NAVE_ALTO, afuera=afuera)
            mallas.append(_hastial(nave, y, NAVE_ANCHO, NAVE_ALTO, sube))
        for lado in (-1, 1):  # faldones del techo
            largo = NAVE_ANCHO / 2 / math.cos(math.radians(TECHO_GRADOS)) + 1.2
            cx = nave + lado * NAVE_ANCHO / 4
            cz = NAVE_ALTO + sube / 2 + 0.3
            g.append(((largo, NAVE_FONDO + 2, 0.3), (cx, 0, cz), (0, TECHO_GRADOS * lado, 0)))
            for d in range(-6, 7, 2):
                dx = d * math.cos(math.radians(TECHO_GRADOS))
                g.append(((0.5, NAVE_FONDO + 2, 0.35), (cx + dx, 0, cz + 0.3 - lado * d * math.sin(math.radians(TECHO_GRADOS))), (0, TECHO_GRADOS * lado, 0)))
            g.append(((0.6, NAVE_FONDO + 2, 0.6), (nave + lado * (NAVE_ANCHO / 2 + 0.6), 0, NAVE_ALTO - 0.2)))  # canaleta
        g.append(((1.4, NAVE_FONDO + 2.4, 1), (nave, 0, NAVE_ALTO + sube + 0.6)))  # cumbrera
    for x, afuera in ((-NAVE_ANCHO, -1), (NAVE_ANCHO, 1)):  # paredes de los costados
        g += _pared_chapa(NAVE_FONDO, 0, x, 0, NAVE_ALTO, eje="Y", afuera=afuera)
    g += [((1.4, 1.4, NAVE_ALTO + 0.5), (x, y, NAVE_ALTO / 2)) for x in (-NAVE_ANCHO, 0, NAVE_ANCHO) for y in (-h, h)]
    g += [((NAVE_ANCHO * 2, 1, 1), (0, y, NAVE_ALTO)) for y in (-h, h)]
    g += [((NAVE_ANCHO * 2 + 2, NAVE_FONDO + 2, 0.6), (0, 0, 0.3))]  # platea
    g += tornillos([(x, -h - 0.7, NAVE_ALTO) for x in range(-30, 32, 4)], 0.3)
    galpon = pieza("Albatros_Galpon", g, "chapa-oxido", mallas=mallas)

    # Oficina: edificio de ladrillo de dos pisos pegado a la derecha (16 x 14 x 27). Las paredes
    # se arman en tramos alrededor de las aberturas, así puerta y ventanas quedan hundidas.
    x0, x1, y0, y1, alto, piso = OFI_X0, OFI_X1, OFI_Y0, OFI_Y1, OFI_ALTO, OFI_PISO
    xc, yc = (x0 + x1) / 2, (y0 + y1) / 2
    ancho, fondo = x1 - x0, y1 - y0
    e = 0.8  # grosor de pared

    def tramo_frente(xa, xb, za, zb):
        return ((xb - xa, e, zb - za), ((xa + xb) / 2, y0, (za + zb) / 2))

    def tramo_der(ya, yb, za, zb):
        return ((e, yb - ya, zb - za), (x1, (ya + yb) / 2, (za + zb) / 2))

    pu = (34.8, 39.8, 0.4, 8.2)  # puerta de abajo (5 x 7,8: entra un jugador): x0, x1, z0, z1
    ve = (42, 46, 3.6, 8.6)  # ventana de abajo
    vt = (33.6, 46.4, piso + 1.6, alto - 2.6)  # ventanal de arriba
    pa = (y1 - 9.5, y1 - 4.5, piso + 0.4, piso + 8.2)  # puerta de arriba (5 x 7,8) (pared derecha): y0, y1, z0, z1
    o = [
        tramo_frente(x0, pu[0], 0, piso), tramo_frente(pu[1], ve[0], 0, piso), tramo_frente(ve[1], x1, 0, piso),
        tramo_frente(pu[0], pu[1], pu[3], piso), tramo_frente(ve[0], ve[1], ve[3], piso), tramo_frente(ve[0], ve[1], 0, ve[2]),
        tramo_frente(x0, vt[0], piso, alto), tramo_frente(vt[1], x1, piso, alto),
        tramo_frente(vt[0], vt[1], piso, vt[2]), tramo_frente(vt[0], vt[1], vt[3], alto),
        tramo_der(y0, y1, 0, piso), tramo_der(y0, pa[0], piso, alto), tramo_der(pa[1], y1, piso, alto), tramo_der(pa[0], pa[1], pa[3], alto),
        ((ancho, e, alto), (xc, y1, alto / 2)), ((e, fondo, alto), (x0 + 0.4, yc, alto / 2)),
        ((ancho, fondo, 0.6), (xc, yc, piso)), ((ancho, fondo, 0.6), (xc, yc, alto - 0.3)),
    ]
    o += [((1.0, 1.0, alto), (x, y0 - 0.1, alto / 2)) for x in (x0 + 0.5, x1 - 0.5)]  # pilastras de esquina
    o += [((ancho + 0.6, 1.2, 0.6), (xc, y0 - 0.1, piso)), ((ancho + 1.4, fondo + 1.4, 0.7), (xc, yc, alto + 0.35))]  # faja y cornisa
    o += [((ancho + 0.6, 0.7, 1.6), (xc, y0 + 0.1, alto + 1.5)), ((0.7, fondo, 1.6), (x1 - 0.1, yc, alto + 1.5))]  # parapeto
    o += [((ancho + 0.6, 1.0, 1.0), (xc, y0 - 0.1, 0.5))]  # zócalo
    o += [((pu[1] - pu[0] + 1.6, 0.6, 0.6), ((pu[0] + pu[1]) / 2, y0 - 0.2, pu[3] + 0.3))]  # dintel de ladrillo
    o += [((ve[1] - ve[0] + 1.2, 0.6, 0.6), ((ve[0] + ve[1]) / 2, y0 - 0.2, ve[3] + 0.3))]
    o += [((ve[1] - ve[0] + 0.8, 1.2, 0.35), ((ve[0] + ve[1]) / 2, y0 - 0.3, ve[2] - 0.15))]  # alféizar
    o += [((pu[1] - pu[0] + 1.4, 1.6, 0.4), ((pu[0] + pu[1]) / 2, y0 - 1.0, 0.2))]  # escalón
    ofi = pieza("Albatros_Oficina", o, "ladrillo")

    # Herrería del bando (carmesí): puertas, marcos, toldo, farol, escalera y barandas.
    hz = []
    cx_pu = (pu[0] + pu[1]) / 2
    hz += [((0.35, 0.5, pu[3] - pu[2] + 0.35), (x, y0 - 0.3, (pu[2] + pu[3]) / 2 + 0.1)) for x in (pu[0], pu[1])]  # marco
    hz += [((pu[1] - pu[0] + 0.35, 0.5, 0.35), (cx_pu, y0 - 0.3, pu[3]))]
    hz += [((pu[1] - pu[0] + 1.6, 2.4, 0.25), (cx_pu, y0 - 1.3, pu[3] + 1.4), (-12, 0, 0))]  # toldo
    hz += [_barra((x, y0 - 0.3, pu[3] + 0.4), (x, y0 - 2.3, pu[3] + 1.0), 0.18) for x in (pu[0] - 0.4, pu[1] + 0.4)]
    hz += [((0.8, 0.8, 0.2), (pu[1] + 1.3, y0 - 0.6, pu[3] + 0.85)), ((0.3, 0.8, 0.3), (pu[1] + 1.3, y0 - 0.2, pu[3] + 0.9))]  # farol
    for (a, b, za, zb), n_parte in ((ve, 2), (vt, 6)):  # marcos de ventanas con parteluces y travesaño
        hz += [((b - a + 0.4, 0.45, 0.35), ((a + b) / 2, y0 - 0.3, z)) for z in (za, zb)]
        hz += [((0.35, 0.45, zb - za), (a + k * (b - a) / n_parte, y0 - 0.3, (za + zb) / 2)) for k in range(n_parte + 1)]
        hz += [((b - a, 0.35, 0.25), ((a + b) / 2, y0 - 0.25, za + (zb - za) * 0.62))]
    # puerta de arriba en la pared derecha
    cy_pa = (pa[0] + pa[1]) / 2
    hz += [((0.5, 0.35, pa[3] - pa[2] + 0.3), (x1 + 0.3, y, (pa[2] + pa[3]) / 2)) for y in (pa[0], pa[1])]
    hz += [((0.5, pa[1] - pa[0] + 0.35, 0.35), (x1 + 0.3, cy_pa, pa[3]))]
    # escalera: sube por la pared derecha desde el fondo hasta un descanso frente a esa puerta
    xe = x1 + 2.0
    y_pie, y_tope, n = 12.0, pa[1], 16
    for k in range(n):
        hz.append(((2.8, 1.25, 0.3), (xe, y_pie - (k + 0.5) * (y_pie - y_tope) / n, (k + 1) * piso / n - 0.15)))
    for x in (xe - 1.5, xe + 1.5):
        hz.append(_barra((x, y_pie, 0), (x, y_tope, piso), 0.4))
    hz.append(_barra((xe + 1.5, y_pie, 3.4), (xe + 1.5, y_tope, piso + 3.4), 0.2))
    hz += [((0.18, 0.18, 3.4), (xe + 1.5, y_pie - k * 3.4, k * 3.4 * piso / (y_pie - y_tope) + 1.7)) for k in range(5)]
    hz += [((3.2, pa[1] - pa[0] + 2, 0.5), (xe, cy_pa, piso))]  # descanso
    hz += [((0.18, pa[1] - pa[0] + 2, 0.18), (xe + 1.6, cy_pa, piso + 3.4)), ((3.2, 0.18, 0.18), (xe, pa[0] - 1, piso + 3.4))]
    hz += [((0.18, 0.18, 3.4), (xe + 1.6, y, piso + 1.7)) for y in (pa[0] - 1, pa[1] + 1)] + [((0.18, 0.18, 3.4), (x1 + 0.6, pa[0] - 1, piso + 1.7))]
    hz += [_barra((xe, cy_pa - 1, piso - 0.3), (x1 + 0.5, cy_pa - 1, piso - 2.6), 0.25), _barra((xe, cy_pa + 1, piso - 0.3), (x1 + 0.5, cy_pa + 1, piso - 2.6), 0.25)]  # ménsulas
    herreria = pieza("Albatros_Herreria", hz, "cofradia-oscura")
    # Cortinas metálicas de los portones (verde petróleo) y las puertas de la oficina, del mismo color.
    pt = []
    for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2):
        f = -h - 0.6
        pt += [((14.2, 0.3, 15.4), (nave, f + 0.2, 8.1))]
        for k in range(19):  # tablillas
            pt += [((14.2, 0.45, 0.62), (nave, f - 0.15 - 0.08 * (k % 2), 0.75 + k * 0.8))]
        pt += [((14.4, 0.7, 0.6), (nave, f - 0.35, 0.4))]  # zócalo de la cortina
        pt += [((0.8, 0.9, 0.5), (nave + sx * 4, f - 0.6, 0.95)) for sx in (-1, 1)]  # manijas para levantarla
        pt += [((0.7, 1.0, 15.8), (nave + sx * 7.2, f - 0.4, 8.0)) for sx in (-1, 1)]  # guías
        pt += [((15.6, 2.4, 2.2), (nave, f - 1.0, 17.2)), ((15.8, 2.6, 0.3), (nave, f - 1.0, 18.35))]  # caja del rollo
        pt += [((0.6, 0.6, 0.6), (nave + 7.4, f - 1.6, 10)), ((0.3, 0.3, 7), (nave + 7.4, f - 1.6, 13.6))]  # botonera y caño
    pt += [((pu[1] - pu[0] - 0.2, 0.25, pu[3] - pu[2]), (cx_pu, y0 + 0.25, (pu[2] + pu[3]) / 2))]
    pt += [((pu[1] - pu[0] - 1.2, 0.35, 2.6), (cx_pu, y0 + 0.05, z)) for z in (2.0, 5.6)]
    pt += [((0.3, 0.5, 0.5), (pu[1] - 0.8, y0 - 0.05, 4.0)), ((pu[1] - pu[0] - 0.2, 0.3, 0.5), (cx_pu, y0 + 0.05, 0.65))]
    pt += [((0.25, pa[1] - pa[0] - 0.2, pa[3] - pa[2]), (x1 - 0.25, cy_pa, (pa[2] + pa[3]) / 2))]
    pt += [((0.35, 2.6, 2.4), (x1 - 0.05, cy_pa, pa[2] + z)) for z in (1.8, 5.2)] + [((0.5, 0.3, 0.5), (x1 + 0.1, pa[0] + 0.7, pa[2] + 3.6))]
    portones = pieza("Albatros_Portones", pt, "porton-verde")
    # Seguridad (amarillo): postes contra choques a los lados de cada portón y guardacantos.
    sg = []
    for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2):
        sg += [((0.4, 0.4, 4), (nave + sx * 8.4, -h - 1.4, 2)) for sx in (-1, 1)]  # guardacantos
    cil = [(0.55, 3.6, (nave + sx * 9.6, -h - 2.4, 0), "Z", 10) for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2) for sx in (-1, 1)]
    cil += [(0.6, 0.3, (nave + sx * 9.6, -h - 2.4, 3.6), "Z", 10) for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2) for sx in (-1, 1)]
    sg += [((0.25, 0.5, 2.8), (xe + 1.5, y_pie - 0.2, 1.4))]  # pie del pasamanos
    seguridad = pieza("Albatros_Seguridad", sg, "cordon-amarillo", cilindros=cil)
    # Lámparas de pared (brazo y pantalla de hierro) sobre cada portón, y cámaras de seguridad en
    # las esquinas apuntando a los portones y a la puerta de la oficina.
    eq, cil_eq, focos, leds = [], [], [], []
    for nave in (-NAVE_ANCHO / 2, NAVE_ANCHO / 2):
        yw, z = -h - 0.7, 20.6
        eq += [((1.2, 0.3, 1.4), (nave, yw - 0.1, z)), _barra((nave, yw - 0.2, z + 0.3), (nave, yw - 2.4, z + 0.3), 0.25)]
        eq += [_barra((nave, yw - 0.2, z - 0.5), (nave, yw - 1.6, z + 0.3), 0.15)]  # tirante
        cil_eq.append((1.1, 0.7, (nave, yw - 2.6, z - 0.4), "Z", 12, 0.35))  # pantalla
        focos.append(((0.6, 0.6, 0.4), (nave, yw - 2.6, z - 0.45)))

    def camara(x, y, z, giro):
        """Soporte en la pared + brazo + carcasa inclinada 20° hacia abajo, mirando a `giro`
        (0 = hacia -Y, 90 = hacia +X)."""
        dx, dy = math.sin(math.radians(giro)), -math.cos(math.radians(giro))
        punta = (x + dx * 1.2, y + dy * 1.2, z)
        c = [((0.9, 0.9, 0.3), (x, y, z), (90, 0, giro)), _barra((x, y, z), punta, 0.25)]
        centro = (punta[0] + dx * 0.5, punta[1] + dy * 0.5, z - 0.35)
        c += [((0.7, 1.7, 0.7), centro, (20, 0, giro)), ((0.95, 1.9, 0.12), (centro[0], centro[1], centro[2] + 0.45), (20, 0, giro))]
        leds.append(((0.18, 0.18, 0.18), (centro[0] + dx * 0.88, centro[1] + dy * 0.88, centro[2] - 0.35)))
        return c

    cams = camara(-NAVE_ANCHO - 0.8, -h - 0.8, 21, 35) + camara(0, -h - 0.9, 24.5, 0) + camara(x1 + 0.6, y0 - 0.6, 12.4, -30)
    equipos = pieza("Albatros_Equipos", eq, "hierro", cilindros=cil_eq)
    camaras = pieza("Albatros_Camaras", cams, "blanco-armadura")
    # Luces cálidas (neón naranja): focos de las lámparas, el farol de la puerta y el de arriba.
    lz = focos + [((0.6, 0.6, 0.6), (pu[1] + 1.3, y0 - 0.6, pu[3] + 0.45)), ((0.6, 0.6, 0.6), (x1 + 0.6, pa[1] + 1.5, pa[3] + 0.6))]
    luces = pieza("Albatros_Luces", lz, "neon-farola")
    # Letrero neón: un albatros de alas abiertas sobre el frente, entre los dos portones.
    pts = [(-5, 0), (-2.8, 0.7), (-0.8, 0.25), (0.8, 0.25), (2.8, 0.7), (5, 0)]
    yl, zl = -h - 1.1, 18.8
    tubos = [_barra((pts[i][0], yl, zl + pts[i][1] * 2.6), (pts[i + 1][0], yl, zl + pts[i + 1][1] * 2.6), 0.3) for i in range(5)]
    tubos += [_barra((-1.2, yl, zl - 0.3), (1.2, yl, zl - 0.3), 0.3), _barra((1.2, yl, zl - 0.3), (2, yl, zl + 0.2), 0.3)]
    tubos += [_barra((-1.2, yl, zl - 0.3), (-2.2, yl, zl - 0.8), 0.3), _barra((-3.2, yl, zl + 0.8), (-2.2, yl, zl - 0.8), 0.25)]
    tubos += [((12, 0.4, 0.4), (0, yl + 0.3, zl + y)) for y in (-1.6, 2.6)]  # soporte del letrero
    tubos += leds  # LED rojo de las cámaras
    letrero = pieza("Albatros_Letrero", tubos, "neon-cofradia")
    # Zócalo de hormigón alrededor del galpón y la oficina (que no parezca flotando).
    zc = [((NAVE_ANCHO * 2 + 2.4, 1.0, 1.2), (0, y, 0.6)) for y in (-h - 0.5, h + 0.5)]
    zc += [((1.0, NAVE_FONDO + 2, 1.2), (x, 0, 0.6)) for x in (-NAVE_ANCHO - 0.5,)]
    zc += [((ancho + 1.2, 1.0, 1.2), (xc, y0 - 0.6, 0.6)), ((1.0, fondo + 1, 1.2), (x1 + 0.6, yc, 0.6)), ((1.0, NAVE_FONDO + 2 - fondo, 1.2), (NAVE_ANCHO + 0.5, (y1 + h) / 2, 0.6))]
    zocalo = pieza("Albatros_Zocalo", zc, "asfalto")
    # Choque: la escalera se ve pero no choca; el jugador sube por esta rampa invisible + descanso.
    colision = pieza(
        "Albatros_Colision",
        [((3.2, pa[1] - pa[0] + 2, 0.5), (xe, cy_pa, piso))],
        "asfalto",
        mallas=[P.cuna(xe - 1.4, xe + 1.4, y_pie, y_tope, 0, piso)],
    )
    # Vidrios (sucios, con algo de reflejo)
    vid = [((b - a, 0.1, zb - za), ((a + b) / 2, y0 + 0.15, (za + zb) / 2)) for a, b, za, zb in (ve, vt)]
    vidrios = pieza("Albatros_Vidrios", vid, "vidrio-sucio")
    return [galpon, ofi, herreria, portones, seguridad, equipos, camaras, luces, vidrios, letrero, zocalo, colision]


# Carguero: popa en -Y, proa en +Y. (y, medio ancho, quilla, borda): la borda sube en la popa
# (castillo de popa) y en la proa (castillo de proa).
SECCIONES_BARCO = [
    (-48, 8, 3, 18), (-45, 8.8, 1, 18), (-38, 9, 0, 18), (-36, 9, 0, 15), (32, 9, 0, 15), (36, 8.8, 0.3, 17.5),
    (41, 7.4, 1, 17.8), (45, 4.8, 2.5, 18.2), (48, 2, 4, 18.6), (49.5, 0.3, 5.5, 18.8),
]
CUBIERTA_BARCO = 15  # altura de la cubierta del medio
TAPAS_BARCO = (-17, -1, 15)
# Contenedores sobre cada tapa: (x, piso, color). 3 de ancho, hasta 3 de alto.
CARGA_BARCO = {
    -17: [(-4.4, 0, "Rojo"), (0, 0, "Azul"), (4.4, 0, "Gris"), (-4.4, 1, "Verde"), (0, 1, "Rojo")],
    -1: [(-4.4, 0, "Azul"), (0, 0, "Verde"), (4.4, 0, "Rojo"), (0, 1, "Gris"), (4.4, 1, "Azul"), (4.4, 2, "Verde")],
    15: [(-4.4, 0, "Gris"), (0, 0, "Rojo"), (4.4, 0, "Azul"), (-4.4, 1, "Rojo")],
}


def _casco():
    """Casco: anillos de 6 puntos por sección (borda, pantoque, quilla) unidos, con tapas."""
    v, c = [], []
    for y, w, quilla, borda in SECCIONES_BARCO:
        v += [(-w, y, borda), (-w, y, quilla + 4), (-w * 0.55, y, quilla), (w * 0.55, y, quilla), (w, y, quilla + 4), (w, y, borda)]
    for k in range(len(SECCIONES_BARCO) - 1):
        for j in range(5):
            a = k * 6 + j
            c.append((a, a + 6, a + 7, a + 1))
        a = k * 6
        c.append((a, a + 5, a + 11, a + 6))  # cubierta
    c.append(tuple(range(5, -1, -1)))
    n = (len(SECCIONES_BARCO) - 1) * 6
    c.append(tuple(range(n, n + 6)))
    return v, c


def barco_albatros():
    """Carguero viejo de 100 studs (más grande que el prompt, cambio de Juani): casco con castillos
    de popa y proa, ojos de buey, línea de flotación, baranda, anclas y bitas. Cubierta (otra
    malla): superestructura de 3 pisos con puente y alerones, chimenea, 2 mástiles de carga con
    plumas y 3 tapas de bodega donde van los contenedores del kit."""
    k = []
    k += [((0.7, 0.15, 0.7), (s * 9.05, y, 11)) for s in (-1, 1) for y in range(-34, 32, 5)]  # ojos de buey
    k += [((18.4, 82, 0.6), (0, -4, 4.5))]  # línea de flotación
    for s in (-1, 1):
        k += [((0.25, 68, 0.25), (s * 8.9, -2, CUBIERTA_BARCO + 2.6))]  # pasamanos
        k += [((0.2, 0.2, 2.6), (s * 8.9, y, CUBIERTA_BARCO + 1.3)) for y in range(-35, 33, 3)]
        k += [((0.6, 1.6, 2.4), (s * 7.8, 40, 13)), _barra((s * 7.8, 40.6, 14), (s * 6.6, 41, 17.4), 0.3)]  # anclas
    k += [((17, 0.6, 3), (0, -36, 16.5)), ((15.5, 0.6, 3), (0, 32, 16.3))]  # mamparos de los castillos
    k += [((1.4, 0.8, 1.4), (s * 6, y, 18.5)) for s in (-1, 1) for y in (-44, 42)]  # bitas
    casco = pieza("Barco_Casco", k, "oxido", mallas=[_casco()])
    z = CUBIERTA_BARCO
    c = []
    c += [((15, 9, 5), (0, -41, 20.5)), ((15.6, 9.6, 0.4), (0, -41, 23.2))]
    c += [((13, 8, 4.4), (0, -41.5, 25.6)), ((13.6, 8.6, 0.4), (0, -41.5, 28))]
    c += [((20, 6, 3.6), (0, -40, 30)), ((20.6, 6.6, 0.5), (0, -40, 32.1))]  # puente con alerones
    c += [((1.6, 0.2, 1.6), (-8.5 + i * 2, -36.95, 30.3)) for i in range(9)]  # ventanas del puente
    c += [((0.9, 0.2, 1.2), (-5.5 + i * 2.2, -36.45, f)) for i in range(6) for f in (20.8, 25.8)]
    c += [((0.2, 0.2, 2.4), (x, -40, 33.4)) for x in (-4, 4)] + [((1.4, 1.4, 0.3), (0, -40, 34.6))]  # radar
    c += [((4, 4, 9), (0, -46, 31)), ((4.4, 4.4, 0.6), (0, -46, 35.8)), ((4.2, 1, 1), (0, -46, 33))]  # chimenea
    for lado in (-1, 1):
        c.append(_barra((lado * 7.8, -36.5, 18), (lado * 7.8, -38.5, 23.4), 0.4))  # escaleras entre pisos
    for y in (-28, 24):  # mástiles de carga con pluma
        hacia = 8 if y < 0 else -8
        c += [((1, 1, 16), (0, y, z + 8)), ((8, 0.6, 0.6), (0, y, z + 14)), ((1.6, 1.6, 0.6), (0, y, z + 16.3))]
        c += [_barra((0, y, z + 1), (0, y + hacia, z + 12), 0.4)]
        c += [_barra((x, y, z + 14), (x, y + hacia, z), 0.12) for x in (-4, 4)]
    for y in TAPAS_BARCO:  # tapas de bodega
        c += [((15, 14, 1.2), (0, y, z + 0.6))] + [((15.4, 0.3, 0.3), (0, y + d, z + 1.3)) for d in (-6.5, -3, 0, 3, 6.5)]
    c += [((2, 4, 1.6), (0, 38, 18.6))]  # cabrestante
    cubierta = pieza("Barco_Cubierta", c, "acero")
    return [casco, cubierta]


def cargar_barco(p, casco):
    """Copias de los contenedores del kit sobre las tapas de bodega (en Studio se ponen los mismos
    contenedores del kit, no van dentro de la malla del barco)."""
    hechos = []
    base = casco.location / B.STUD
    for y, pila in CARGA_BARCO.items():
        for x, piso, color in pila:
            k = P.copia(p["Contenedor_" + color], base.x + x, base.y + y, 0, z=CUBIERTA_BARCO + 1.2 + piso * 4.05)
            k.name = "Carga_" + color
            hechos.append(k)
    return hechos


def todas():
    grandes = [tunel_arco()] + edificio_viejo() + grua() + galpon_albatros() + barco_albatros()
    return [
        [muelle_recto(), muelle_esquina(), calle(False), calle(True)] + vereda() + [galpon_techo(), charco()],
        [galpon_pared("Lisa"), galpon_pared("Porton"), galpon_pared("Ventanas"), arcada(), alambrado()],
        [contenedor(c) for c in ("rojo", "azul", "verde", "gris")],
        props(),
        grandes,
    ]


P.ENCIMA = P.ENCIMA + ("Albatros_Herreria", "Albatros_Portones", "Albatros_Seguridad", "Albatros_Equipos", "Albatros_Camaras", "Albatros_Luces", "Albatros_Vidrios", "Albatros_Letrero", "Albatros_Zocalo", "Albatros_Colision")


def luces_calle(muestra):
    """Luces de punto naranjas en los faroles y la ventana del Albatros (en Roblox: PointLight)."""
    for o in muestra:
        if o.name.startswith("Prop_Farola"):
            d = bpy.data.lights.new("Farol", "POINT")
            d.color = B.color("ff9a3a")[:3]
            d.energy = 120
            d.shadow_soft_size = 0.3
            luz = bpy.data.objects.new("Farol", d)
            bpy.context.scene.collection.objects.link(luz)
            luz.location = o.location + P.S(0, 0, 12.9)


def tirar_charcos(p, muestra, ox):
    hechos = []
    for x, y, g in ((ox + 6, 1, 10), (ox + 30, -1.5, 70), (ox + 46, 2, 0)):
        hechos.append(P.copia(p["Calle_Charco"], x, y, g))
    return hechos


def tabla(cuenta):
    filas = ["| Pieza | Triángulos | Tope |", "|---|---|---|"]
    for n, t in cuenta.items():
        if n.startswith("_"):
            continue
        tope = P.PRESUPUESTO.get(n, "-")
        filas.append(f"| {n} | {t} | {tope} |")
    filas.append(f"| **Total del kit** | **{cuenta['_total']}** | |")
    return "\n".join(filas)


def detalle(con_horneado=False):
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    grupos = todas()
    P.grilla(grupos)
    p = {o.name: o for fila in grupos for o in fila}
    piezas = list(p.values())
    for o in piezas:
        o.hide_render = o.hide_render or o.name.endswith("_Colision")  # invisibles en el juego
    bpy.context.view_layer.update()
    carga = cargar_barco(p, p["Barco_Casco"])
    if con_horneado:
        import detalle as D

        presupuesto = {n: (P.PRESUPUESTO.get(n, 20000), [n]) for n in p if not n.endswith("_Colision")}
        lados = {n: (256 if n.startswith(("Prop_", "Calle_", "Contenedor_")) else 1024 if n.startswith(("Albatros", "Barco", "Grua")) else 512) for n in p}
        D.terminar([o for o in piezas if not o.name.endswith("_Colision")], presupuesto, "puerto-oxido", lados=lados)
    bpy.context.view_layer.update()
    ancho = max(o.location.x + o.dimensions.x / 2 for o in piezas) / B.STUD
    ox = ancho + 60
    muestra = P.calle_muestra(p, ox)
    muestra += tirar_charcos(p, muestra, ox)
    muestra.append(P.copia(p["Albatros_Galpon"], ox + 120, 30))
    muestra.append(P.copia(p["Albatros_Oficina"], ox + 120, 30))
    for n in ("Albatros_Herreria", "Albatros_Portones", "Albatros_Seguridad", "Albatros_Equipos", "Albatros_Camaras", "Albatros_Luces", "Albatros_Vidrios", "Albatros_Letrero", "Albatros_Zocalo", "Albatros_Colision"):
        muestra.append(P.copia(p[n], ox + 120, 30))
    P.luz_puerto()
    luces_calle(muestra)
    bpy.ops.wm.save_as_mainfile(filepath=P.BLEND)
    cuenta = B.contar_triangulos(piezas)
    with open(os.path.join(B.RENDERS, "puerto-oxido_triangulos.md"), "w", encoding="utf-8") as f:
        f.write(tabla(cuenta) + "\n")
    chicas = [o for fila in grupos[:-1] for o in fila]
    r = [
        P.render_orto("puerto-oxido_detalle_kit", chicas, giro=0, altura=50, niebla=False),
        P.render_orto("puerto-oxido_detalle_grandes", grupos[-1] + carga, giro=25, altura=25, niebla=False),
        P.render_orto("puerto-oxido_detalle_oficina", [p[n] for n in ("Albatros_Galpon", "Albatros_Oficina", "Albatros_Herreria", "Albatros_Portones", "Albatros_Seguridad", "Albatros_Equipos", "Albatros_Camaras", "Albatros_Luces", "Albatros_Vidrios", "Albatros_Letrero", "Albatros_Zocalo", "Albatros_Colision")], giro=-10, altura=8, niebla=False, solo=True),
        P.render_orto("puerto-oxido_detalle_barco", [p["Barco_Casco"], p["Barco_Cubierta"]] + carga, giro=-40, altura=18, niebla=False, solo=True),
        P.render_orto("puerto-oxido_detalle_escalera", [p[n] for n in ("Albatros_Galpon", "Albatros_Oficina", "Albatros_Herreria", "Albatros_Portones", "Albatros_Seguridad", "Albatros_Equipos", "Albatros_Camaras", "Albatros_Luces", "Albatros_Vidrios", "Albatros_Letrero", "Albatros_Zocalo", "Albatros_Colision")], giro=-35, altura=14, niebla=False, solo=True),
        P.render_orto("puerto-oxido_detalle_calle", muestra, giro=-30, altura=28),
    ]
    return cuenta, r


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "detalle" in pasos:
        print(detalle("hornear" in pasos))
    if "exportar" in pasos:
        bpy.ops.wm.open_mainfile(filepath=P.BLEND)
        kit = [o for o in bpy.data.objects if o.type == "MESH" and o.name in P.PRESUPUESTO and o.name != "Niebla"]
        sin_base = ("Galpon_", "Albatros_Galpon", "Albatros_Oficina", "Albatros_Zocalo", "Edificio_", "Tunel_", "Arcada", "Prop_Muro", "Contenedor_")
        print("EXPORTADAS", len(P.exportar_kit("puerto-oxido", kit, sin_base)))
