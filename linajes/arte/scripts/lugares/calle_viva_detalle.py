"""Calle viva del puerto, paso 2: las piezas del boceto (calle_viva.py) con detalle de forma, los
dibujos de los grafitis y del cartel de BUSCADO, y dos escenas de prueba armadas con el kit de
Puerto Óxido: una calle con el corte de la policía y un callejón de Los Óxido de noche.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/lugares/calle_viva_detalle.py -- detalle [hornear]

Mismos nombres y pivotes que el boceto. Lo chico (letras, estrella, desgaste) va en texturas.
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import calle_viva as C  # noqa: E402
import puerto_oxido as P  # noqa: E402
from mathutils import Vector  # noqa: E402

pieza = P.pieza
_barra = P._barra
azar = random.Random(5)
DECALS = os.path.join(B.EXPORTS, "calle-viva", "decals")

B.MATERIALES.setdefault("neon-azul", {"hex": "2a6bff", "brillo": 6.0})
B.MATERIALES.setdefault("neon-faro", {"hex": "fff1d6", "brillo": 4.0})
B.MATERIALES.setdefault("vidrio-sucio", {"hex": "2a3a40", "rugosidad": 0.15, "metal": 0.3})
for _i in (1, 2, 3):
    B.MATERIALES.setdefault(f"grafiti-{_i}", {"hex": "d2691e", "rugosidad": 0.9})  # se reemplaza por el dibujo
B.MATERIALES["colchon"] = {"hex": "8f8670", "rugosidad": 1.0}  # manchado
B.MATERIALES.setdefault("neon-cofradia", {"hex": "ff2a4a", "brillo": 6.0})
B.MATERIALES.setdefault("carton", {"hex": "9c7a4f", "rugosidad": 1.0})
B.MATERIALES.setdefault("bolsa-negra", {"hex": "16171a", "rugosidad": 0.35})
B.MATERIALES.setdefault("concreto", {"hex": "5d5f63", "rugosidad": 0.95})
B.MATERIALES.setdefault("hilo-rojo", {"hex": "b0182a", "rugosidad": 0.8})

C.PRESUPUESTO.update(
    {
        "Patrulla_Blanco": 1500, "Patrulla_SirenaAzul": 600, "Auto_Vidrios": 400, "Auto_Faros": 300, "Auto_Stop": 100, "Rueda_Llanta": 300,
        "Camara_Lente": 150, "Tablero_Papeles": 400, "Tablero_Hilos": 300,
        "Escalera_Incendio_Colision": 100, "Reja_Deposito_Colision": 12,
        "Canio_Bajada": 600, "Canio_Tramo": 300, "Techo_Ventilacion": 400, "Equipo_AC": 800, "Rejilla_Pared": 300,
        "Puerta_Taller": 1200, "Puerta_Escalones": 100, "Puerta_Luz": 50, "Contenedor_Basura": 1200, "Bolsas_Basura": 600,
        "Cajas_Carton": 300, "Bolardo": 200, "Letrero_Bar": 400, "Letrero_BarLuz": 12, "Patrulla_Texto": 24, "Taxi_Texto": 24,
    }
)


# ---------------------------------------------------------------------------
# Ayudas
# ---------------------------------------------------------------------------


def perfil(puntos, x0, x1):
    """Extruye un perfil (y, z) en sentido horario visto desde +X entre x0 y x1: malla suelta."""
    n = len(puntos)
    v = [(x0, y, z) for y, z in puntos] + [(x1, y, z) for y, z in puntos]
    caras = [tuple(range(n - 1, -1, -1)), tuple(range(n, 2 * n))]
    caras += [(i, (i + 1) % n, n + (i + 1) % n, n + i) for i in range(n)]
    return v, caras


def anillo(cx, cy, cz, r, grosor, n=12, plano="XY"):
    cajas = []
    largo = 2 * r * math.sin(math.pi / n) * 1.1
    for i in range(n):
        a = 2 * math.pi * i / n
        if plano == "XY":
            cajas.append(((largo, grosor, grosor), (cx + r * math.cos(a), cy + r * math.sin(a), cz), (0, 0, math.degrees(a) + 90)))
        else:  # XZ
            cajas.append(((largo, grosor, grosor), (cx + r * math.cos(a), cy, cz + r * math.sin(a)), (0, -math.degrees(a) - 90, 0)))
    return cajas


# ---------------------------------------------------------------------------
# Vehículos (frente hacia -Y). Perfiles laterales (y, z) en studs.
# ---------------------------------------------------------------------------

SEDAN_BAJO = [(-8.2, 1.0), (-8.4, 2.4), (-7.8, 3.3), (-3.6, 3.7), (4.2, 3.7), (7.8, 3.5), (8.3, 2.6), (8.1, 1.0), (5.6, 1.0), (5.0, 2.0), (3.4, 2.0), (2.8, 1.0), (-2.8, 1.0), (-3.4, 2.0), (-5.0, 2.0), (-5.6, 1.0)]
SEDAN_CABINA = [(-3.6, 3.6), (-1.6, 5.5), (2.6, 5.5), (4.4, 3.6)]


def _auto(nombre, mat, bajo, cabina, ancho, extra=()):
    """Carrocería: perfil bajo a lo ancho + techo y parantes (los vidrios van en otra malla)."""
    a = ancho / 2
    mallas = [perfil(bajo, -a, a)]
    ys = [y for y, _ in cabina]
    y0, y1 = min(ys), max(ys)
    z_techo = max(z for _, z in cabina)
    cajas = [((ancho - 0.9, (cabina[2][0] - cabina[1][0]) + 0.3, 0.3), (0, (cabina[1][0] + cabina[2][0]) / 2, z_techo))]
    for sx in (-1, 1):
        x = sx * (a - 0.5)
        cajas += [_barra((x, cabina[0][0], cabina[0][1]), (x, cabina[1][0], cabina[1][1]), 0.35)]  # parante A
        cajas += [_barra((x, cabina[3][0], cabina[3][1]), (x, cabina[2][0], cabina[2][1]), 0.35)]  # parante C
        cajas += [((0.3, 0.3, z_techo - 3.6), (x, (y0 + y1) / 2 + 0.3, (z_techo + 3.6) / 2))]  # parante B
        cajas += [((0.5, 0.6, 0.4), (sx * (a + 0.2), cabina[0][0] + 0.4, 3.9))]  # espejos
        cajas += [((0.1, 0.8, 0.2), (sx * (a + 0.05), y, 3.1)) for y in (-1.5, 2.0)]  # manijas
    cajas += [((ancho + 0.2, 0.9, 0.8), (0, bajo[1][0] - 0.1, 1.5)), ((ancho + 0.2, 0.9, 0.8), (0, bajo[6][0] + 0.1, 1.5))]  # paragolpes
    cajas += [((ancho * 0.45, 0.2, 0.7), (0, bajo[1][0] - 0.05, 2.5)), ((2.2, 0.2, 0.9), (0, bajo[6][0] + 0.15, 2.3))]  # parrilla y patente
    cajas += list(extra)
    return pieza(nombre, cajas, mat, mallas=mallas)


def _vidrios(y_off, cabina, ancho, nombre):
    a = ancho / 2 - 0.55
    pts = [(y + y_off, z) for y, z in cabina]
    return perfil(pts, -a, a)


def vehiculos():
    ancho = 7
    pat = _auto("Patrulla_Carroceria", "patrulla-azul", SEDAN_BAJO, SEDAN_CABINA, ancho)
    blanco = [((0.12, 5.6, 1.6), (s * 3.56, 0.3, 2.6)) for s in (-1, 1)]  # puertas blancas (estrella y texto en textura)
    blanco += [((5.4, 1.4, 0.4), (0, 0.6, 5.85))]  # base de la barra de luces
    blanco += [((ancho - 1, 3.2, 0.12), (0, 1.0, 5.66))]  # techo blanco con número de unidad
    pblanco = pieza("Patrulla_Blanco", blanco, "blanco-armadura")
    sir_r = pieza("Patrulla_Sirena", [((2.2, 1.0, 0.55), (-1.3, 0.6, 6.3)), ((0.5, 0.5, 0.4), (-2.6, -0.1, 3.0))], "neon-sirena")
    sir_a = pieza("Patrulla_SirenaAzul", [((2.2, 1.0, 0.55), (1.3, 0.6, 6.3)), ((0.5, 0.5, 0.4), (2.6, -0.1, 3.0))], "neon-azul")
    vid = pieza("Auto_Vidrios", [], "vidrio-sucio", mallas=[_vidrios(0, [(-3.4, 3.7), (-1.5, 5.35), (2.5, 5.35), (4.2, 3.7)], ancho, "")])
    faros = pieza("Auto_Faros", [((1.4, 0.2, 0.6), (s * 2.5, -8.45, 2.9)) for s in (-1, 1)], "neon-faro")  # adelante (-Y)
    stop = pieza("Auto_Stop", [((1.8, 0.2, 0.55), (s * 2.5, 8.45, 3.0)) for s in (-1, 1)], "neon-sirena")  # atrás, rojas
    rueda_p = pieza("Patrulla_Rueda", [], "goma", cilindros=[(1.35, 1.0, (-0.5, 0, 1.35), "X", 18), (1.0, 1.1, (-0.55, 0, 1.35), "X", 18)])
    llanta = pieza("Rueda_Llanta", [((0.1, 0.3, 1.6), (0.55, 0, 1.35), (a, 0, 0)) for a in (0, 60, 120)], "acero", cilindros=[(0.75, 0.15, (0.48, 0, 1.35), "X", 12)])
    comp = _auto("Compacto_Carroceria", "auto-civil", [(-6.6, 1.0), (-6.8, 2.4), (-6.2, 3.4), (-3.4, 3.8), (5.6, 3.8), (6.6, 3.4), (6.7, 2.6), (6.6, 1.0), (5.2, 1.0), (4.6, 2.0), (3.0, 2.0), (2.4, 1.0), (-2.4, 1.0), (-3.0, 2.0), (-4.6, 2.0), (-5.2, 1.0)], [(-3.4, 3.7), (-1.6, 6.0), (4.6, 6.0), (5.6, 3.7)], 6.6)
    cam_bajo = [(-8.6, 1.2), (-8.8, 2.8), (-8.2, 3.9), (-4.2, 4.2), (8.6, 4.2), (8.8, 1.2), (6.2, 1.2), (5.5, 2.3), (3.7, 2.3), (3.0, 1.2), (-3.0, 1.2), (-3.7, 2.3), (-5.5, 2.3), (-6.2, 1.2)]
    caja = [((0.4, 7.6, 1.8), (s * 3.3, 4.6, 5.1)) for s in (-1, 1)] + [((7, 0.4, 1.8), (0, 8.4, 5.1)), ((7, 0.3, 0.4), (0, 8.5, 4.4))]
    caja += [((6.6, 0.3, 1.2), (0, 0.6, 6.4))]  # protector de luneta
    camioneta = _auto("Camioneta_Carroceria", "auto-civil", cam_bajo, [(-4.2, 4.1), (-2.4, 6.6), (0.4, 6.6), (0.8, 4.1)], 7, extra=caja)
    taxi = _auto("Taxi_Carroceria", "taxi", SEDAN_BAJO, SEDAN_CABINA, ancho)
    cartel = pieza("Taxi_Cartel", [((2.6, 0.9, 0.9), (0, 0.4, 6.0)), ((1.6, 0.4, 0.2), (0, 0.4, 5.6))], "papel")
    rueda_c = pieza("Civil_Rueda", [], "goma", cilindros=[(1.25, 0.9, (-0.45, 0, 1.25), "X", 16), (0.95, 1.0, (-0.5, 0, 1.25), "X", 16)])
    return [pat, pblanco, sir_r, sir_a, vid, faros, stop, rueda_p, llanta, comp, camioneta, taxi, cartel, rueda_c]


# ---------------------------------------------------------------------------
# Vigilancia
# ---------------------------------------------------------------------------


def _camara(x, y, z, inclinar=20, giro_z=0):
    """Carcasa con visera, tapa de atrás y rótula. Devuelve (cajas de la carcasa, punto de la lente)."""
    c = [((0.85, 1.9, 0.8), (x, y - 0.7, z - 0.3), (inclinar, 0, giro_z)), ((1.1, 2.2, 0.12), (x, y - 0.8, z + 0.17), (inclinar, 0, giro_z))]
    c += [((0.95, 0.2, 0.9), (x, y + 0.25, z), (inclinar, 0, giro_z)), ((0.5, 0.5, 0.5), (x, y + 0.45, z + 0.1))]
    t = math.radians(inclinar)
    lente = (x, y - 1.65 * math.cos(t), z - 0.3 - 1.0 * math.sin(t))
    return c, lente


def vigilancia():
    soporte = [((1.1, 0.3, 1.4), (0, 0.65, 8)), _barra((0, 0.6, 8), (0, 0.35, 8), 0.3)] + [((0.15, 0.15, 0.15), (sx * 0.4, 0.45, 8 + sz * 0.5)) for sx in (-1, 1) for sz in (-1, 1)]
    car, lente_p = _camara(0, 0.3, 8)
    pared = pieza("Camara_Pared", soporte + car, "blanco-armadura")
    car2, lente_po = _camara(0, -1.7, 11.6)
    poste = [((0.9, 0.9, 0.5), (0, 0, 0.25)), ((0.6, 0.6, 12), (0, 0, 6.2)), ((0.9, 0.9, 0.6), (0, 0, 11.8)), _barra((0, 0, 11.6), (0, -1.5, 11.6), 0.3), ((1, 0.5, 2), (0, 0.4, 5)), ((0.8, 0.8, 0.2), (0, 0, 12.2))]
    poste = pieza("Camara_Poste", poste + car2, "blanco-armadura")
    car3, _ = _camara(0.4, 0.2, 7.2, inclinar=60, giro_z=25)
    rota = soporte[:2] + [((0.85, 0.9, 0.8), (0.6, -1.0, 6.4), (70, 10, 30))] + car3[:1] + car3[2:]
    rota += [_barra((0.0, 0.4, 7.6), (0.4, 0.0, 6.0), 0.07), _barra((0.4, 0.0, 6.0), (0.2, -0.3, 4.6), 0.07), _barra((-0.1, 0.5, 7.4), (-0.5, 0.2, 5.4), 0.07)]
    rota = pieza("Camara_Rota", rota, "blanco-armadura")
    lentes = pieza("Camara_Lente", [], "goma", cilindros=[(0.3, 0.3, (lente_p[0], lente_p[1] - 0.05, lente_p[2]), "Y", 10), (0.3, 0.3, (lente_po[0], lente_po[1] - 0.05, lente_po[2]), "Y", 10)])
    luz = pieza("Camara_Luz", [((0.18, 0.18, 0.18), (0.3, lente_p[1] + 0.1, lente_p[2] + 0.35)), ((0.18, 0.18, 0.18), (0.3, lente_po[1] + 0.1, lente_po[2] + 0.35))], "neon-sirena")
    # Barrera de corte (caballete): patas en A, dos tablones (franjas en textura) y balizas.
    b = []
    for s in (-1, 1):
        b += [_barra((s * 6, -1.2, 0), (s * 6, 0, 4.2), 0.35), _barra((s * 6, 1.2, 0), (s * 6, 0, 4.2), 0.35), ((0.3, 2.2, 0.3), (s * 6, 0, 1.2))]
        b += [((0.8, 2.8, 0.3), (s * 6, 0, 0.15))]
    b += [((13.4, 0.3, 0.9), (0, -0.35, z)) for z in (2.2, 3.5)]
    barrera = pieza("Barrera", b, "cordon-amarillo")
    luces = pieza("Barrera_Luces", [], "neon-sirena", cilindros=[(0.4, 0.6, (s * 6, 0, 4.3), "Z", 10, 0.3) for s in (-1, 1)])
    return [pared, poste, rota, lentes, luz, barrera, luces]


# ---------------------------------------------------------------------------
# Crimen y atracos, noticias
# ---------------------------------------------------------------------------


def crimen():
    esp = anillo(-0.75, 0, 0.1, 0.4, 0.12) + anillo(0.75, 0, 0.1, 0.4, 0.12)
    esp += [((0.35, 0.25, 0.25), (s * 0.3, 0, 0.1)) for s in (-1, 0, 1)] + [((0.3, 0.3, 0.2), (s * 1.15, 0, 0.1)) for s in (-1, 1)]
    esposas = pieza("Esposas", esp, "acero")
    bolsa = pieza(
        "Bolsa_Botin",
        [((1.2, 0.6, 0.1), (0, -0.95, 0.9))],  # parche del símbolo de moneda
        "lona",
        cilindros=[(1.0, 1.4, (0, 0, 0), "Z", 10, 0.8), (0.5, 0.5, (0, 0, 1.4), "Z", 8, 0.25), (0.35, 0.4, (0, 0, 1.85), "Z", 8, 0.45)],
    )
    al = []
    for z in (0.2, 0.75, 1.3):
        al += [((3, 0.15, 0.5), (0, s * 1.02, z)) for s in (-1, 1)] + [((0.15, 2, 0.5), (s * 1.5, 0, z)) for s in (-1, 1)]
    al += [((3, 2, 0.15), (0, 0, 0.08)), ((3.2, 2.2, 0.2), (0, 0, 1.7)), ((3.0, 2.0, 0.12), (0, 0, 1.85))]
    al += [((0.3, 0.3, 1.9), (sx * 1.5, sy * 1.0, 0.95)) for sx in (-1, 1) for sy in (-1, 1)]  # esquineros
    al += [((0.5, 0.15, 0.8), (0, -1.12, 1.45)), ((0.6, 0.3, 0.6), (0, -1.3, 1.05))]  # aldaba y candado
    al += anillo(0, -1.3, 1.45, 0.22, 0.08, 8, "XZ")[:5]
    alijo = pieza("Alijo", al, "madera-muelle")
    tab = [((8, 0.3, 5), (0, 0, 5.5))] + [((8.4, 0.5, 0.35), (0, 0, z)) for z in (3.0, 8.0)] + [((0.35, 0.5, 5.3), (s * 4.1, 0, 5.5)) for s in (-1, 1)]
    tab += [_barra((s * 3.4, 0.6, 0), (s * 3.6, 0.1, 5.5), 0.3) for s in (-1, 1)] + [_barra((s * 3.4, -0.6, 0), (s * 3.6, -0.1, 5.5), 0.3) for s in (-1, 1)]
    tab += [((8, 0.6, 0.4), (0, -0.4, 3.0))]  # repisa para tizas
    tablero = pieza("Tablero_Golpes", tab, "corcho")
    pap = []
    for x, z, w, h in ((-2.8, 7, 1.4, 1.0), (-1.0, 6.6, 1.2, 1.5), (1.2, 7.1, 1.4, 1.0), (2.9, 6.3, 1.2, 1.5), (-2.4, 4.4, 2.2, 1.4), (0.8, 4.2, 2.8, 1.8), (3.0, 4.4, 1.0, 1.2)):
        pap += [((w, 0.06, h), (x, -0.2, z), (0, azar.uniform(-6, 6), 0)), ((0.18, 0.18, 0.18), (x, -0.28, z + h / 2 - 0.15))]
    papeles = pieza("Tablero_Papeles", pap, "papel")
    hilos = pieza("Tablero_Hilos", [_barra((-2.8, -0.3, 7.35), (-1.0, -0.3, 7.2), 0.05), _barra((-1.0, -0.3, 7.2), (0.8, -0.3, 4.95), 0.05), _barra((1.2, -0.3, 7.45), (0.8, -0.3, 4.95), 0.05), _barra((2.9, -0.3, 6.9), (3.0, -0.3, 4.85), 0.05), _barra((-2.4, -0.3, 4.95), (-1.0, -0.3, 7.2), 0.05)], "hilo-rojo")
    buscado = pieza("Cartel_Buscado", [((2, 0.04, 2.8), (0, 0, 1.4))] + [((0.7, 0.06, 0.25), (sx * 0.85, -0.02, 1.4 + sz * 1.3), (0, sx * sz * 35, 0)) for sx in (-1, 1) for sz in (-1, 1)], "papel")
    return [esposas, bolsa, alijo, tablero, papeles, hilos, buscado]


# ---------------------------------------------------------------------------
# Callejón
# ---------------------------------------------------------------------------


def callejon():
    farola = [((1.4, 1.4, 0.5), (0, 0, 0.25)), ((1, 1, 1), (0, 0, 1)), _barra((0, 0, 1.4), (0, 0, 8.5), 0.4), _barra((0, 0, 8.5), (0.5, -1.4, 10.6), 0.38), _barra((0.5, -1.4, 10.6), (0.7, -2.6, 10.8), 0.3)]
    farola += [((1.3, 1.3, 0.25), (0.75, -2.9, 10.6), (0, 30, 0)), ((0.12, 0.12, 1.2), (0.75, -2.9, 9.8)), ((0.6, 0.6, 0.7), (0.75, -2.9, 9.0), (25, 0, 15))]  # farol colgando de un cable
    farola = pieza("Farola_Rota", farola, "hierro", cilindros=[(0.5, 0.6, (0, 0, 4.5), "Z", 8)])
    # Contenedor de basura volcado de costado: cuerpo, borde, tapas abiertas, ruedas y bolsas.
    bas = [((6, 3.8, 3.6), (0, 0.2, 1.8)), ((6.4, 0.3, 4.0), (0, 2.2, 1.9)), ((6.3, 4.2, 0.3), (0, 0.2, 3.65))]
    bas += [((3.0, 0.2, 3.6), (sx * 1.6, -2.2, 0.6), (-75, 0, sx * 8)) for sx in (-1, 1)]  # tapas caídas
    bas += [((0.4, 0.4, 0.4), (sx * 2.6, 2.4, z)) for sx in (-1, 1) for z in (0.6, 3.2)]  # ruedas
    bas += [((0.3, 0.6, 1.2), (sx * 3.15, 0.2, 2.6)) for sx in (-1, 1)]  # manijas
    basura = pieza("Basura_Volcado", bas, "contenedor-verde", cilindros=[(0.8, 1.2, (x, -2.6 - d, 0), "Z", 8, 0.55) for x, d in ((-2, 0.6), (0.2, 1.6), (2.1, 0.3), (1.0, 2.6))])
    # mitad tirada en el piso y mitad doblada contra la pared (la pared queda en +Y)
    col = [((4, 3.6, 0.9), (0, -1.6, 0.45)), ((4, 0.9, 3.4), (0, 0.9, 1.9), (-22, 0, 0)), ((4.1, 1.0, 1.0), (0, 0.2, 0.6), (-40, 0, 0))]
    col += [((0.25, 0.25, 0.1), (x, y, 0.92)) for x in (-1.2, 0, 1.2) for y in (-2.6, -1.2)]  # botones
    col += [((0.25, 0.1, 0.25), (x, 0.35, z)) for x in (-1.2, 0, 1.2) for z in (1.4, 2.6)]
    colchon = pieza("Colchon", col, "colchon")
    barril = pieza(
        "Barril_Fuego",
        [((0.5, 0.2, 0.4), (math.cos(a) * 0.95, math.sin(a) * 0.95, 0.6), (0, 0, math.degrees(a) + 90)) for a in (0.3, 1.9, 3.5, 5.0)],  # agujeros de aire
        "oxido",
        cilindros=[(0.95, 3, (0, 0, 0), "Z", 14), (1.02, 0.15, (0, 0, 0.7), "Z", 14), (1.02, 0.15, (0, 0, 2.2), "Z", 14), (1.0, 0.12, (0, 0, 2.9), "Z", 14)],
    )
    llamas = pieza("Barril_Llamas", [], "neon-fuego", cilindros=[(0.8, 1.6, (0, 0, 2.9), "Z", 7, 0.05), (0.45, 1.3, (0.35, 0.2, 3.2), "Z", 6, 0.02), (0.4, 1.1, (-0.35, -0.2, 3.2), "Z", 6, 0.02)])
    r = [((0.5, 0.5, 10), (s * 6, 0, 5)) for s in (-1, 1)] + [((12, 0.3, 0.3), (0, 0, z)) for z in (0.4, 5, 9.6)]
    r += [((0.15, 0.15, 9.2), (-5.6 + i * 0.8, 0, 5)) for i in range(15)]
    r += [((0.15, 0.15, 0.6), (-5.6 + i * 0.8, 0, 10.0), (0, 0, 0)) for i in range(15)]
    r += [_barra((s * 6, 0, 10), (s * 6, -1.2, 11), 0.12) for s in (-1, 1)] + [((12, 0.08, 0.08), (0, -0.6 - 0.3 * k, 10.4 + 0.3 * k)) for k in range(3)]  # alambre de púas
    r += [((0.6, 0.5, 0.8), (0.4, -0.35, 4.6)), ((0.2, 0.7, 1.4), (0, 0, 4.6))]  # candado y traba
    reja = pieza("Reja_Deposito", r, "hierro")
    # Escalera de incendio del edificio viejo (pisos de 13; la pared queda en y = 0, sale hacia -Y):
    # balcón de rejilla justo debajo de la ventana del primer piso (centrada en x = 0, entre dos
    # pilastras), baranda en 3 lados, ménsulas, escalera de mano al techo separada de la pared para
    # pasar la cornisa, y escalera corrediza levantada a un costado de la ventana de abajo.
    # Versión vieja: una baranda doblada y falta una tabla de la rejilla.
    zb, ancho, fondo = 14.4, 7.0, 3.4
    a2 = ancho / 2
    e = [((ancho, 0.3, 0.3), (0, -fondo, zb)), ((ancho, 0.3, 0.3), (0, -0.2, zb))]
    e += [((0.3, fondo, 0.3), (sx * a2, -fondo / 2, zb)) for sx in (-1, 1)]
    e += [((0.18, fondo - 0.4, 0.12), (-a2 + 0.3 + k * 0.45, -fondo / 2, zb + 0.1)) for k in range(15) if k != 9]
    for sx in (-1, 1):  # ménsulas en diagonal hasta la pared (entre la ventana y las pilastras)
        e.append(_barra((sx * 2.6, -0.15, zb - 3.0), (sx * 2.6, -fondo + 0.3, zb), 0.25))
        e.append(((0.6, 0.3, 0.6), (sx * 2.6, -0.15, zb - 3.0)))
    # baranda: frente con abertura a la derecha para la escalera corrediza, y costados
    e += [((ancho - 1.0, 0.15, 0.15), (-0.5, -fondo, zb + h)) for h in (1.6, 3.2)]
    e += [((0.12, 0.12, 3.2), (-a2 + 0.1 + k * 0.6, -fondo, zb + 1.6)) for k in range(10)]
    e += [((0.25, 0.25, 3.3), (x, -fondo, zb + 1.65)) for x in (-a2, a2 - 1.0, a2)]
    for sx in (-1, 1):
        e += [((0.15, fondo, 0.15), (sx * a2, -fondo / 2, zb + h)) for h in (1.6, 3.2)]
        e += [((0.12, 0.12, 3.2), (sx * a2, -0.6 - k * 0.7, zb + 1.6)) for k in range(4)]
    e += [_barra((-a2, -fondo, zb + 3.2), (-a2 + 2.0, -fondo - 0.5, zb + 2.6), 0.15)]  # baranda doblada
    # escalera de mano al techo: sale del costado izquierdo del balcón, a 1,4 de la pared, y sube
    # por delante de la cornisa hasta el borde del techo (27,4)
    yt, alto_t = -1.4, 27.4 - zb
    e += [((0.15, 0.15, alto_t), (x, yt, zb + alto_t / 2)) for x in (-a2 - 0.2, -a2 + 0.8)]
    e += [((1.0, 0.12, 0.12), (-a2 + 0.3, yt, zb + 0.8 + k * 0.9)) for k in range(int(alto_t / 0.9))]
    e += [_barra((-a2 + 0.3, yt, zb + alto_t), (-a2 + 0.3, yt + 0.6, zb + alto_t + 0.5), 0.15)]
    # escalera corrediza (levantada) en la abertura, con sus guías: baja a 7,6 del piso
    xc = a2 - 0.4  # al costado de la ventana de abajo, no delante
    e += [((0.15, 0.15, 7.0), (x, -fondo - 0.2, zb - 2.9)) for x in (xc - 0.6, xc + 0.6)]
    e += [((1.2, 0.12, 0.12), (xc, -fondo - 0.2, zb - 6.0 + k * 0.85)) for k in range(8)]
    e += [((0.4, 0.4, 0.4), (x, -fondo - 0.1, zb + 0.4)) for x in (xc - 0.6, xc + 0.6)]
    escalera = pieza("Escalera_Incendio", e, "hierro")
    # Choques (invisibles): piso del balcón y las dos escaleras de mano (en Studio, TrussPart).
    esc_col = pieza(
        "Escalera_Incendio_Colision",
        [((ancho, fondo, 0.4), (0, -fondo / 2, zb)), ((1.4, 0.4, alto_t), (-a2 + 0.3, yt, zb + alto_t / 2)), ((1.4, 0.4, 7.0), (xc, -fondo - 0.2, zb - 2.9))],
        "asfalto",
    )
    reja_col = pieza("Reja_Deposito_Colision", [((12.4, 0.8, 10.4), (0, 0, 5.2))], "asfalto")
    graf = [pieza(f"Grafiti_{i}", [((6, 0.02, 4), (0, 0, 2))], f"grafiti-{i}") for i in (1, 2, 3)]
    return [farola, basura, colchon, barril, llamas, reja, escalera, esc_col, reja_col] + graf


# ---------------------------------------------------------------------------
# Calle: lo que la hace sentir vivida (caños, ventilaciones, puerta, basura, bolardos, cartel)
# Las piezas de pared tienen la pared en y = 0 y salen hacia -Y.
# ---------------------------------------------------------------------------


def calle():
    bajada = pieza(
        "Canio_Bajada",
        [((0.9, 0.3, 0.3), (0, -0.15, z)) for z in (2, 6, 10)] + [((0.5, 0.9, 0.3), (0, -0.55, z)) for z in (2, 6, 10)],
        "acero",
        cilindros=[(0.35, 10.6, (0, -0.8, 0.6), "Z", 10), (0.35, 1.0, (0, -0.8, 11.2), "Y", 10), (0.4, 0.8, (0, -0.8, 0.3), "Y", 10)],
    )
    tramo = pieza("Canio_Tramo", [((0.4, 0.9, 0.3), (x, -0.45, 0)) for x in (-3, 3)], "acero", cilindros=[(0.45, 8, (-4, -0.9, 0), "X", 10)])
    vent = pieza(
        "Techo_Ventilacion",
        [((2.2, 2.2, 0.6), (0, 0, 0.3))],
        "acero",
        cilindros=[(0.75, 1.6, (0, 0, 0.6), "Z", 12), (1.3, 0.5, (0, 0, 2.3), "Z", 12, 0.2), (0.85, 0.1, (0, 0, 2.2), "Z", 12)],
    )
    ac = [((4, 3, 2.4), (0, 0, 1.2)), ((4.2, 3.2, 0.2), (0, 0, 2.5))]
    ac += [((0.1, 3.05, 1.6), (x, 0, 1.2)) for x in (-1.6, -1.2, -0.8, -0.4)]  # rejilla del costado
    ac += anillo(0.9, 0, 2.62, 0.9, 0.12, 12) + [((1.8, 0.1, 0.1), (0.9, 0, 2.62)), ((0.1, 1.8, 0.1), (0.9, 0, 2.62))]
    ac = pieza("Equipo_AC", ac, "acero")
    rej = [((2.6, 0.3, 0.25), (0, -0.15, z)) for z in (0, 3.2)] + [((0.25, 0.3, 3.4), (x, -0.15, 1.6)) for x in (-1.2, 1.2)]
    rej += [((2.2, 0.35, 0.3), (0, -0.25, 0.4 + k * 0.5), (35, 0, 0)) for k in range(6)]
    rejilla = pieza("Rejilla_Pared", rej, "hierro")
    # Puerta de madera (5,4 x 8) con marco, tablas, travesaños en Z, manija y farol arriba
    pt = [((0.5, 0.6, 8.6), (x, -0.3, 4.3)) for x in (-3.0, 3.0)] + [((6.5, 0.6, 0.6), (0, -0.3, 8.6))]
    pt += [((0.86, 0.3, 8.0), (-2.15 + k * 0.86, -0.2, 4.0)) for k in range(6)]
    pt += [((5.2, 0.3, 0.5), (0, -0.45, z)) for z in (1.2, 6.8)] + [_barra((-2.4, -0.45, 1.3), (2.4, -0.45, 6.7), 0.4)]
    pt += [((0.3, 0.4, 0.9), (2.0, -0.6, 4.0)), ((0.8, 0.6, 0.6), (0, -0.4, 9.6)), ((0.2, 0.7, 0.2), (0, -0.7, 9.6))]
    puerta = pieza("Puerta_Taller", pt, "madera-oscura")
    escalones = pieza("Puerta_Escalones", [((7, 2.4, 0.5), (0, -1.2, 0.25)), ((6.4, 1.2, 0.5), (0, -0.6, 0.75))], "concreto")
    puerta_luz = pieza("Puerta_Luz", [((0.6, 0.4, 0.35), (0, -0.75, 9.2))], "neon-farola")
    # Contenedor de basura parado: cuerpo, borde, dos tapas (una entreabierta), ruedas y manijas
    cb = [((6, 3.6, 3.6), (0, 0, 2.2)), ((6.3, 3.9, 0.3), (0, 0, 4.0)), ((6.3, 0.3, 0.6), (0, -1.95, 3.6))]
    cb += [((3.0, 3.8, 0.2), (-1.55, 0, 4.25)), ((3.0, 3.8, 0.2), (1.55, -0.3, 4.6), (18, 0, 0))]
    cb += [((0.6, 0.6, 0.6), (sx * 2.6, sy * 1.5, 0.3)) for sx in (-1, 1) for sy in (-1, 1)]
    cb += [((0.3, 0.6, 1.2), (sx * 3.15, 0, 3.0)) for sx in (-1, 1)] + [((5.8, 0.25, 0.25), (0, -1.95, 2.0))]
    contenedor = pieza("Contenedor_Basura", cb, "contenedor-verde")
    bolsas = pieza(
        "Bolsas_Basura",
        [((0.3, 0.3, 0.4), (x, y, z + 0.1)) for x, y, z in ((0, 0, 1.9), (1.4, 0.5, 1.5), (0.6, -1.2, 1.4))],
        "bolsa-negra",
        cilindros=[(0.85, 1.8, (0, 0, 0), "Z", 8, 0.45), (0.75, 1.4, (1.4, 0.5, 0), "Z", 8, 0.4), (0.7, 1.3, (0.6, -1.2, 0), "Z", 8, 0.35)],
    )
    cajas = [((2, 1.6, 1.6), (0, 0, 0.8)), ((1.6, 1.4, 1.2), (0.1, 0.1, 2.2), (0, 0, 15)), ((1.8, 1.8, 1.4), (2.0, 0.4, 0.7), (0, 0, -10))]
    cajas += [((1.6, 0.05, 0.8), (2.0, -0.5, 1.7), (-40, 0, -10)), ((1.6, 0.05, 0.8), (2.0, 1.3, 1.7), (40, 0, -10))]  # solapas abiertas
    cajas = pieza("Cajas_Carton", cajas, "carton")
    bolardo = pieza("Bolardo", [((0.5, 0.06, 0.4), (0, -0.42, 2.2))], "cordon-amarillo", cilindros=[(0.4, 2.8, (0, 0, 0), "Z", 10), (0.48, 0.25, (0, 0, 2.8), "Z", 10, 0.3)])
    letrero = pieza(
        "Letrero_Bar",
        [((6.4, 0.4, 0.25), (0, -0.9, z)) for z in (0, 2.6)] + [((0.25, 0.4, 2.85), (x, -0.9, 1.3)) for x in (-3.2, 3.2)] + [_barra((x, 0, 2.2), (x, -0.9, 2.4), 0.2) for x in (-2.4, 2.4)] + [_barra((x, 0, 0.4), (x, -0.9, 0.2), 0.2) for x in (-2.4, 2.4)],
        "hierro",
    )
    letrero_luz = pieza("Letrero_BarLuz", [((6.0, 0.05, 2.4), (0, -1.0, 1.3))], "neon-cofradia")
    # Textos de los autos (planos finos; el dibujo va como Decal en Roblox)
    pat_txt = pieza("Patrulla_Texto", [((0.02, 4.6, 1.4), (sx * 3.63, 0.3, 2.6)) for sx in (-1, 1)], "papel")
    taxi_txt = pieza("Taxi_Texto", [((2.4, 0.02, 0.7), (0, 0.4 + sy * 0.46, 6.0)) for sy in (-1, 1)], "papel")
    return [bajada, tramo, vent, ac, rejilla, puerta, escalones, puerta_luz, contenedor, bolsas, cajas, bolardo, letrero, letrero_luz, pat_txt, taxi_txt]


def _rampa_x(x0, x1, y0, y1, z0, z1):
    """Rampa que sube a lo largo de X (de x0, z0 a x1, z1), entre y0 e y1."""
    v = [(x0, y0, z0), (x0, y1, z0), (x1, y1, z1), (x1, y0, z1), (x1, y0, z1 - 0.5), (x1, y1, z1 - 0.5), (x0 + 0.3, y1, z0 - 0.3), (x0 + 0.3, y0, z0 - 0.3)]
    return v, [(0, 1, 2, 3), (7, 4, 5, 6), (0, 3, 4, 7), (1, 6, 5, 2), (3, 2, 5, 4), (0, 7, 6, 1)]


def todas():
    return [vehiculos(), vigilancia(), crimen(), callejon(), calle()]


# ---------------------------------------------------------------------------
# Dibujos: grafitis de Los Óxido y cartel de BUSCADO (texto de Blender renderizado a PNG)
# ---------------------------------------------------------------------------


def _texto(cuerpo, tam, pos, color, extruir=0.0, giro=0.0, contorno=None):
    curva = bpy.data.curves.new("T", "FONT")
    curva.body = cuerpo
    curva.size = tam
    curva.align_x = "CENTER"
    curva.extrude = extruir
    obj = bpy.data.objects.new("T", curva)
    obj.location = pos
    obj.rotation_euler = (0, 0, math.radians(giro))
    bpy.context.scene.collection.objects.link(obj)
    mat = bpy.data.materials.new("T")
    mat.use_nodes = True
    n = mat.node_tree.nodes
    n.remove(n["Principled BSDF"])
    em = n.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = B.color(color)
    mat.node_tree.links.new(em.outputs[0], n["Material Output"].inputs[0])
    curva.materials.append(mat)
    return obj


def _forma(verts, color, z=0.0):
    me = bpy.data.meshes.new("F")
    me.from_pydata([(x, y, z) for x, y in verts], [], [list(range(len(verts)))])
    obj = bpy.data.objects.new("F", me)
    bpy.context.scene.collection.objects.link(obj)
    mat = bpy.data.materials.new("F")
    mat.use_nodes = True
    n = mat.node_tree.nodes
    n.remove(n["Principled BSDF"])
    em = n.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = B.color(color)
    mat.node_tree.links.new(em.outputs[0], n["Material Output"].inputs[0])
    me.materials.append(mat)
    return obj


def dibujos():
    """Hace los PNG con fondo transparente en exports/calle-viva/decals (sirven como Decal en
    Roblox y como textura en los renders). Diseños propios de la pandilla Los Óxido: naranja óxido
    con borde verde petróleo y goteos."""
    os.makedirs(DECALS, exist_ok=True)
    escena = bpy.data.scenes.new("Dibujos")
    ventana_escena = bpy.context.window.scene if bpy.context.window else None
    bpy.context.window.scene = escena if bpy.context.window else None
    escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in {m.identifier for m in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items} else "BLENDER_EEVEE"
    escena.render.film_transparent = True
    escena.render.image_settings.file_format = "PNG"
    escena.render.image_settings.color_mode = "RGBA"
    escena.view_settings.view_transform = "Standard"
    cam_d = bpy.data.cameras.new("CD")
    cam_d.type = "ORTHO"
    cam = bpy.data.objects.new("CD", cam_d)
    escena.collection.objects.link(cam)
    cam.location = (0, 0, 10)
    escena.camera = cam
    rutas = {}

    def limpiar():
        for o in list(escena.collection.objects):
            if o != cam:
                bpy.data.objects.remove(o)

    def sacar(nombre, ancho, alto, escala):
        escena.render.resolution_x, escena.render.resolution_y = ancho, alto
        cam_d.ortho_scale = escala
        ruta = os.path.join(DECALS, nombre + ".png")
        escena.render.filepath = ruta
        bpy.ops.render.render(write_still=True, scene=escena.name)
        rutas[nombre] = ruta

    def con_borde(cuerpo, tam, pos, relleno, borde, giro=0.0):
        for dx, dy in ((-0.12, 0), (0.12, 0), (0, -0.12), (0, 0.12), (0.1, -0.1)):
            o = _texto(cuerpo, tam, (pos[0] + dx, pos[1] + dy, -0.01), borde, giro=giro)
            _mover(o)
        _mover(_texto(cuerpo, tam, pos, relleno, giro=giro))

    def _mover(o):
        for c in o.users_collection:
            c.objects.unlink(o)
        escena.collection.objects.link(o)

    def goteos(x0, x1, y, color, n=7):
        for _ in range(n):
            x = azar.uniform(x0, x1)
            largo = azar.uniform(0.3, 1.1)
            _mover(_forma([(x - 0.05, y), (x + 0.05, y), (x + 0.04, y - largo), (x - 0.04, y - largo)], color))

    # 1: la palabra de la pandilla, gruesa y torcida
    con_borde("ÓXIDO", 1.9, (0, -0.4, 0), "d2691e", "1f4a5a", giro=-6)
    goteos(-2.6, 2.6, -0.5, "d2691e")
    sacar("Grafiti_1", 768, 512, 6.6)
    limpiar()
    # 2: el símbolo: un ancla dentro de un engranaje (ancla del puerto, engranaje del óxido)
    for k in range(10):
        a = 2 * math.pi * k / 10
        cx, cy = math.cos(a) * 1.55, math.sin(a) * 1.55
        _mover(_forma([(cx - 0.3, cy - 0.3), (cx + 0.3, cy - 0.3), (cx + 0.3, cy + 0.3), (cx - 0.3, cy + 0.3)], "1f4a5a"))
    anillo_pts = [(math.cos(2 * math.pi * k / 24) * 1.45, math.sin(2 * math.pi * k / 24) * 1.45) for k in range(24)]
    _mover(_forma(anillo_pts, "1f4a5a", -0.02))
    _mover(_forma([(math.cos(2 * math.pi * k / 24) * 1.15, math.sin(2 * math.pi * k / 24) * 1.15) for k in range(24)], "151515", -0.01))
    _mover(_forma([(-0.12, -0.8), (0.12, -0.8), (0.12, 0.8), (-0.12, 0.8)], "d2691e"))
    _mover(_forma([(-0.5, 0.55), (0.5, 0.55), (0.5, 0.75), (-0.5, 0.75)], "d2691e"))
    _mover(_forma([(-0.75, -0.3), (-0.55, -0.3), (0, -0.85), (0.55, -0.3), (0.75, -0.3), (0, -1.05)], "d2691e"))
    goteos(-1.2, 1.2, -1.7, "1f4a5a", 5)
    sacar("Grafiti_2", 512, 512, 4.6)
    limpiar()
    # 3: firma rápida "LOS OX" con flecha
    con_borde("LOS OX", 1.4, (-0.3, -0.2, 0), "e8e6e0", "d2691e", giro=8)
    _mover(_forma([(-2.6, -1.0), (2.2, -0.6), (2.2, -0.9), (2.9, -0.45), (2.2, 0.0), (2.2, -0.3), (-2.6, -0.7)], "d2691e"))
    sacar("Grafiti_3", 768, 512, 6.6)
    limpiar()
    # Cartel de BUSCADO: papel, recuadro para la foto, texto
    _mover(_forma([(-1.0, -1.4), (1.0, -1.4), (1.0, 1.4), (-1.0, 1.4)], "dcd8cc", -0.05))
    _mover(_texto("BUSCADO", 0.42, (0, 1.0, 0), "1a1a1e"))
    _mover(_forma([(-0.6, -0.35), (0.6, -0.35), (0.6, 0.75), (-0.6, 0.75)], "3a3f4b", -0.02))
    _mover(_forma([(-0.25, -0.35), (0.25, -0.35), (0.3, 0.05), (0.15, 0.25), (0.2, 0.5), (0, 0.62), (-0.2, 0.5), (-0.15, 0.25), (-0.3, 0.05)], "1a1a1e", -0.01))
    _mover(_texto("RECOMPENSA", 0.22, (0, -0.75, 0), "8e2a22"))
    _mover(_texto("$ 5.000", 0.3, (0, -1.15, 0), "1a1a1e"))
    sacar("Cartel_Buscado", 512, 716, 2.8)
    limpiar()
    # Puertas de la patrulla: estrella de 6 puntas propia (dos triángulos) y POLICÍA DE LA BAHÍA
    for ang in (90, 270):
        _mover(_forma([(math.cos(math.radians(ang + k * 120)) * 0.5 - 1.85, math.sin(math.radians(ang + k * 120)) * 0.5) for k in range(3)], "c9a23a"))
    _mover(_texto("POLICÍA", 0.6, (0.75, -0.05, 0), "1f3a5a"))
    _mover(_texto("DE LA BAHÍA", 0.3, (0.75, -0.55, 0), "1f3a5a"))
    sacar("Texto_Policia", 1024, 312, 4.6)
    limpiar()
    _mover(_texto("TAXI", 0.62, (0, -0.2, 0), "1a1a1e"))
    sacar("Texto_Taxi", 512, 150, 2.4)
    limpiar()
    # Cartel de neón del bar (nombre propio): "EL ANCLA" con un ancla
    _mover(_texto("EL ANCLA", 0.8, (0.5, -0.3, 0), "ff3a6a"))
    _mover(_forma([(-2.15, -0.5), (-2.05, -0.5), (-2.05, 0.5), (-2.15, 0.5)], "3fe0f0"))
    _mover(_forma([(-2.45, 0.3), (-1.75, 0.3), (-1.75, 0.4), (-2.45, 0.4)], "3fe0f0"))
    _mover(_forma([(-2.55, -0.3), (-2.45, -0.3), (-2.1, -0.6), (-1.75, -0.3), (-1.65, -0.3), (-2.1, -0.72)], "3fe0f0"))
    sacar("Letrero_Bar", 1024, 410, 6.0)
    limpiar()
    bpy.context.window.scene = ventana_escena if bpy.context.window else None
    bpy.data.scenes.remove(escena)
    return rutas


def aplicar_dibujo(obj, ruta, brilla=0.0):
    """Material con la imagen (con transparencia) para el render; en Roblox va como Decal. Con
    `brilla` la imagen también emite (cartel de neón). La UV se arma por cara, según hacia dónde
    mira, para que el dibujo se lea derecho de los dos lados."""
    mat = bpy.data.materials.new("DIB_" + obj.name)
    mat.use_nodes = True
    n = mat.node_tree.nodes
    bsdf = n["Principled BSDF"]
    tex = n.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(ruta, check_existing=True)
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    mat.node_tree.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Roughness"].default_value = 0.9
    if brilla:
        mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = brilla
    mat.surface_render_method = "BLENDED" if hasattr(mat, "surface_render_method") else None
    mat.use_backface_culling = True  # que no se vea la cara de atrás (al revés) por la transparencia
    if hasattr(mat, "use_backface_culling_shadow"):
        mat.use_backface_culling_shadow = True
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    # UV plana de frente (X, Z) en 0-1
    me = obj.data
    if not me.uv_layers:
        me.uv_layers.new()
    for poly in me.polygons:
        n = poly.normal
        cos = [me.vertices[me.loops[li].vertex_index].co for li in poly.loop_indices]
        if abs(n.x) > abs(n.y):  # mira a ±X: la derecha del que mira es +Y si mira a +X
            us = [c.y if n.x > 0 else -c.y for c in cos]
        else:  # mira a ±Y: la derecha es +X si mira a -Y
            us = [c.x if n.y < 0 else -c.x for c in cos]
        zs = [c.z for c in cos]
        for li, u, z in zip(poly.loop_indices, us, zs):
            me.uv_layers.active.data[li].uv = ((u - min(us)) / max(max(us) - min(us), 1e-6), (z - min(zs)) / max(max(zs) - min(zs), 1e-6))


# ---------------------------------------------------------------------------
# Escenas de prueba con el kit de Puerto Óxido
# ---------------------------------------------------------------------------

DEL_PUERTO = ("Galpon_Techo", "Edificio_ViejoVidrios", "Edificio_ViejoLuces", "Calle_Adoquin", "Calle_Vereda", "Calle_Cordon", "Galpon_Pared", "Galpon_ParedPorton", "Galpon_ParedVentanas", "Prop_Farola", "Prop_MuroLadrillo", "Prop_MuroRemate", "Contenedor_Rojo", "Contenedor_Azul", "Prop_Cajones", "Calle_Charco", "Edificio_Viejo", "Edificio_ViejoTecho")


def traer_kit_puerto():
    ruta = os.path.join(B.BLENDER, "puerto-oxido.blend")
    with bpy.data.libraries.load(ruta, link=False) as (desde, hacia):
        hacia.objects = [n for n in desde.objects if n in DEL_PUERTO]
    k = {}
    for o in hacia.objects:
        if o is None:
            continue
        o.location = (0, 0, -400)  # el original queda lejos; las escenas usan copias
        bpy.context.scene.collection.objects.link(o)
        k[o.name] = o
    return k


def cp(o, x, y, giro=0, z=0):
    return P.copia(o, x, y, giro, z)


def escena_calle(p, k, ox, oy):
    """Calle del puerto cortada por la policía, armada como diorama: galpón de chapa con base de
    ladrillo, caños, ventilaciones y equipo de aire en el techo, puerta de madera con farol, cartel
    de neón del bar; pared del costado con grafitis, rejillas y carteles de BUSCADO; contenedor de
    basura, bolsas, cajas, bolardos; patrulla con la barrera y un taxi. Abajo, base de hormigón."""
    h = []
    paredes = ("Galpon_Pared", "Galpon_ParedVentanas", "Galpon_Pared", "Galpon_Pared", "Galpon_ParedVentanas", "Galpon_Pared")
    yf = oy + 20.2  # pared del galpón
    for i in range(6):
        x = ox + i * 8
        h += [cp(k["Calle_Adoquin"], x, oy), cp(k["Calle_Adoquin"], x, oy + 8), cp(k["Calle_Vereda"], x, oy + 16), cp(k["Calle_Cordon"], x, oy + 16)]
        h += [cp(k[paredes[i]], x, yf), cp(k["Galpon_Techo"], x, yf + 4, 0, 12), cp(k["Galpon_Pared"], x, yf + 8, 180)]
        h += [cp(p["Canio_Tramo"], x, yf - 0.45, 0, 11.6)]
        if i != 2:  # base de ladrillo (salvo donde está la puerta)
            h += [cp(k["Prop_MuroLadrillo"], x, yf - 0.85), cp(k["Prop_MuroRemate"], x, yf - 0.85)]
        h += [cp(k["Calle_Vereda"], x, oy - 8, 180), cp(k["Calle_Cordon"], x, oy - 8, 180), cp(k["Calle_Vereda"], x, oy - 16, 180)]
        h += [cp(k["Prop_MuroLadrillo"], x, oy - 20.4), cp(k["Prop_MuroRemate"], x, oy - 20.4)]
    # la calle sigue hacia la izquierda (fuera del diorama): solo se cierran los costados del galpón
    xl = ox - 4.2
    h += [cp(k["Galpon_Pared"], xl, yf + 4, 90), cp(k["Galpon_Pared"], ox + 44.2, yf + 4, -90)]
    # galpón: puerta, caños, rejilla, cartel de neón
    h += [cp(p["Puerta_Taller"], ox + 16, yf - 0.45), cp(p["Puerta_Escalones"], ox + 16, yf - 0.45), cp(p["Puerta_Luz"], ox + 16, yf - 0.45)]
    h += [cp(p["Canio_Bajada"], ox + 11.4, yf - 0.45), cp(p["Canio_Bajada"], ox + 35.4, yf - 0.45)]
    h += [cp(p["Rejilla_Pared"], ox + 28, yf - 0.45, 0, 6.5), cp(p["Rejilla_Pared"], ox + 36, yf - 0.45, 0, 6.5)]
    h += [cp(p["Letrero_Bar"], ox + 4, yf - 0.45, 0, 7.0), cp(p["Letrero_BarLuz"], ox + 4, yf - 0.45, 0, 7.0)]
    # techo: ventilaciones y equipo de aire
    h += [cp(p["Techo_Ventilacion"], ox + 6, yf + 4, 0, 14.0), cp(p["Techo_Ventilacion"], ox + 34, yf + 4, 0, 14.0)]
    h += [cp(p["Equipo_AC"], ox + 22, yf + 2.4, 0, 12.7)]
    h[-1].rotation_euler.x = math.radians(25)
    # grafitis y carteles en la pared del costado y en el galpón
    gl = [cp(p["Grafiti_3"], ox + 30.5, yf - 0.6, 0, 4.6), cp(p["Grafiti_1"], ox + 41, yf - 0.6, 0, 4.6)]
    for g in gl:
        g.scale = (0.7, 1, 0.7)
    h += gl
    h += [cp(p["Cartel_Buscado"], ox + 22, yf - 0.6, 0, 5.2), cp(p["Cartel_Buscado"], ox + 25, yf - 0.6, 0, 4.8), cp(p["Cartel_Buscado"], ox + 9, yf - 0.6, 0, 5.0)]
    # basura y cosas en la vereda
    h += [cp(p["Contenedor_Basura"], ox + 8, oy + 16.6), cp(p["Bolsas_Basura"], ox + 1.2, oy + 16.6), cp(p["Cajas_Carton"], ox + 24, oy + 16.4)]
    h += [cp(p["Bolsas_Basura"], ox + 40, oy + 16.6, 40), cp(p["Cajas_Carton"], ox + 33, oy + 16.4, 20)]
    h += [cp(p["Bolardo"], ox + x, oy - 5.0) for x in (4, 12, 28, 36)]
    # farolas, autos, barrera y cámaras
    h += [cp(k["Prop_Farola"], ox + 30, oy + 14.5), cp(k["Prop_Farola"], ox + 22, oy - 12), cp(k["Calle_Charco"], ox + 20, oy + 1, 30), cp(k["Calle_Charco"], ox + 34, oy + 10)]
    # los dos autos van hacia la izquierda (frente a -X): la patrulla parada junto al corte con las
    # luces prendidas y el taxi frenado más atrás, esperando
    h += _auto_armado(p, "Patrulla", ox + 14, oy + 0.5, -90)
    h += _auto_armado(p, "Taxi", ox + 35, oy + 7.5, -90)
    for x, y in ((ox - 2, oy + 1), (ox + 3.5, oy + 8)):  # corte de la policía: dos barreras escalonadas
        h += [cp(p["Barrera"], x, y, 90), cp(p["Barrera_Luces"], x, y, 90)]
    h += [cp(p["Camara_Pared"], ox - 2, yf - 1.0, 0), cp(p["Camara_Poste"], ox + 40, oy - 12, 160)]
    # base del diorama (solo para el render)
    base = pieza("_BaseDiorama", [((56, 48, 2), (0, 0, -1))], "concreto")
    base.location = P.S(ox + 20, oy + 4, 0)
    h.append(base)
    for nombre, x, y, z, color, energia in (("Puerta", ox + 16, yf - 1.6, 9.0, "ff9a3a", 120), ("Neon", ox + 4, yf - 2.5, 8.3, "ff3a6a", 160)):
        d = bpy.data.lights.new(nombre, "POINT")
        d.color = B.color(color)[:3]
        d.energy = energia
        luz = bpy.data.objects.new(nombre, d)
        bpy.context.scene.collection.objects.link(luz)
        luz.location = P.S(x, y, z)
    return h


def _auto_armado(p, tipo, x, y, giro):
    """Carrocería + ruedas + vidrios + faros (y sirena o cartel) en (x, y) girado."""
    car = p[f"{tipo}_Carroceria"]
    rueda, a, largo = C.EJES[car.name]
    h = [cp(car, x, y, giro), cp(p["Auto_Vidrios"], x, y, giro), cp(p["Auto_Faros"], x, y, giro), cp(p["Auto_Stop"], x, y, giro)]
    extras = {"Patrulla": ("Patrulla_Blanco", "Patrulla_Sirena", "Patrulla_SirenaAzul", "Patrulla_Texto"), "Taxi": ("Taxi_Cartel", "Taxi_Texto")}.get(tipo, ())
    h += [cp(p[n], x, y, giro) for n in extras]
    g = math.radians(giro)
    for sx in (-1, 1):
        for sy in (-1, 1):
            dx, dy = sx * a, sy * largo
            rx, ry = dx * math.cos(g) - dy * math.sin(g), dx * math.sin(g) + dy * math.cos(g)
            h.append(cp(p[rueda], x + rx, y + ry, giro + (0 if sx > 0 else 180)))
            h.append(cp(p["Rueda_Llanta"], x + rx, y + ry, giro + (0 if sx > 0 else 180)))
    return h


def escena_callejon(p, k, ox, oy):
    """Callejón de 12 studs entre un muro bajo (lado de la cámara) y dos edificios viejos de 2 pisos
    de 13 studs, separados por un pasillo de 2: escalera de incendio con el balcón debajo de una
    ventana del primer piso, grafitis en la franja lisa entre pisos, farola rota en el pasillo,
    basura, colchón, barril con fuego, alijo y una reja que cierra el fondo."""
    h = []
    for i in range(6):
        x = ox + i * 8
        h += [cp(k["Calle_Adoquin"], x, oy), cp(k["Calle_Adoquin"], x, oy + 8)]
        h += [cp(k["Prop_MuroLadrillo"], x, oy - 4.4), cp(k["Prop_MuroRemate"], x, oy - 4.4)]
    for x in (ox + 8, ox + 34):  # frente de los edificios en y = oy + 8,2
        h += [cp(k[n], x, oy + 16.2) for n in ("Edificio_Viejo", "Edificio_ViejoTecho", "Edificio_ViejoVidrios", "Edificio_ViejoLuces")]
    h += [cp(p["Reja_Deposito"], ox + 44, oy + 1.95, 90)]
    h[-1].scale.x = 0.94  # entra justo entre el muro y el edificio
    yg = oy + 8.12  # sobre la pared lisa, entre pilastras, en la franja de arriba de las ventanas de abajo
    gs = [cp(p["Grafiti_1"], ox + 0, yg, 0, 10.4), cp(p["Grafiti_2"], ox + 26, yg, 0, 10.4), cp(p["Grafiti_3"], ox + 42, yg, 0, 10.4)]
    for g in gs:
        g.scale = (0.62, 1, 0.62)
    h += gs
    h += [cp(p["Escalera_Incendio"], ox + 8, oy + 7.55)]  # debajo de la ventana del medio de arriba
    h += [cp(p["Basura_Volcado"], ox + 4, oy - 1.4, 180), cp(p["Colchon"], ox + 30, oy + 5.5)]
    h += [cp(p["Barril_Fuego"], ox + 15, oy + 2.5), cp(p["Barril_Llamas"], ox + 15, oy + 2.5)]
    h += [cp(p["Farola_Rota"], ox + 21, oy + 6.6), cp(p["Alijo"], ox + 38, oy - 1.4, 20), cp(p["Bolsa_Botin"], ox + 35, oy - 2.4)]
    h += [cp(k["Prop_Cajones"], ox + 39, oy + 4.5), cp(k["Calle_Charco"], ox + 12, oy + 3, 40)]
    fuego = bpy.data.lights.new("Fuego", "POINT")
    fuego.color = B.color("ff7a1a")[:3]
    fuego.energy = 900
    luz = bpy.data.objects.new("Fuego", fuego)
    bpy.context.scene.collection.objects.link(luz)
    luz.location = P.S(ox + 15, oy + 2.5, 5)
    return h


def cruces(objs, margen=0.3):
    """Pares de objetos de una escena cuyas cajas se meten más de `margen` studs una en otra (sin
    contar el piso, los decals, los choques ni las mallas de un mismo modelo). Para revisar a ojo."""
    from mathutils import Vector as V

    bpy.context.view_layer.update()
    ignorar = ("_Texto", "Escalones", "_BaseDiorama", "Canio", "Calle_", "Grafiti_", "Rueda", "Llanta", "Vidrios", "Faros", "Sirena", "Blanco", "Cartel", "Lente", "Luz", "Luces", "Llamas", "Remate", "Techo", "Charco")
    cajas = []
    for o in objs:
        if o.type != "MESH" or o.name.endswith("_Colision") or any(t in o.name for t in ignorar):
            continue
        puntos = [o.matrix_world @ V(c) for c in o.bound_box]
        mn = V((min(q.x for q in puntos), min(q.y for q in puntos), min(q.z for q in puntos))) / B.STUD
        mx = V((max(q.x for q in puntos), max(q.y for q in puntos), max(q.z for q in puntos))) / B.STUD
        cajas.append((o.name, mn, mx))
    malos = []
    for a in range(len(cajas)):
        for b in range(a + 1, len(cajas)):
            na, mna, mxa = cajas[a]
            nb, mnb, mxb = cajas[b]
            d = [min(mxa[i], mxb[i]) - max(mna[i], mnb[i]) for i in range(3)]
            if min(d) > margen:
                malos.append((na, nb, round(min(d), 2)))
    return malos


def luces_calle(objs):
    for o in objs:
        if o.name.startswith("Prop_Farola"):
            d = bpy.data.lights.new("Farol", "POINT")
            d.color = B.color("ff9a3a")[:3]
            d.energy = 150
            luz = bpy.data.objects.new("Farol", d)
            bpy.context.scene.collection.objects.link(luz)
            luz.location = o.location + P.S(0, 0, 12.9)
        if "Sirena" in o.name:
            d = bpy.data.lights.new("Sirena", "POINT")
            d.color = B.color("ff2a2a" if "Azul" not in o.name else "2a6bff")[:3]
            d.energy = 60
            luz = bpy.data.objects.new("Sirena", d)
            bpy.context.scene.collection.objects.link(luz)
            luz.location = o.location + P.S(0, 0, 7)


def tabla(cuenta):
    filas = ["| Pieza | Triángulos | Tope |", "|---|---|---|"]
    for n, t in cuenta.items():
        if not n.startswith("_"):
            filas.append(f"| {n} | {t} | {C.PRESUPUESTO.get(n, '-')} |")
    filas.append(f"| **Total** | **{cuenta['_total']}** | |")
    return "\n".join(filas)


def detalle(con_horneado=False):
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    grupos = todas()
    P.ENCIMA = C.P.ENCIMA = (
        "Patrulla_Blanco", "Patrulla_Sirena", "Patrulla_SirenaAzul", "Auto_Vidrios", "Auto_Faros", "Auto_Stop", "Rueda_Llanta", "Taxi_Cartel",
        "Camara_Lente", "Camara_Luz", "Barrera_Luces", "Tablero_Papeles", "Tablero_Hilos", "Barril_Llamas", "Escalera_Incendio_Colision", "Reja_Deposito_Colision",
        "Puerta_Escalones", "Puerta_Luz", "Letrero_BarLuz", "Patrulla_Texto", "Taxi_Texto",
    )
    P.grilla(grupos, separacion=5)
    p = {o.name: o for f in grupos for o in f}
    piezas = list(p.values())
    for o in piezas:
        o.hide_render = o.hide_render or o.name.endswith("_Colision")  # invisibles en el juego
    if con_horneado:
        import detalle as D

        presupuesto = {n: (C.PRESUPUESTO.get(n, 3000), [n]) for n in p if not n.startswith("Grafiti") and not n.endswith(("_Colision", "_Texto", "BarLuz"))}
        lados = {n: (512 if n.endswith("Carroceria") or n == "Tablero_Golpes" else 256) for n in p}
        D.terminar([o for o in piezas if not o.name.startswith("Grafiti") and not o.name.endswith(("_Colision", "_Texto", "BarLuz"))], presupuesto, "calle-viva", lados=lados)
    rutas = dibujos()
    for i in (1, 2, 3):
        aplicar_dibujo(p[f"Grafiti_{i}"], rutas[f"Grafiti_{i}"])
    aplicar_dibujo(p["Cartel_Buscado"], rutas["Cartel_Buscado"])
    aplicar_dibujo(p["Patrulla_Texto"], rutas["Texto_Policia"])
    aplicar_dibujo(p["Taxi_Texto"], rutas["Texto_Taxi"])
    aplicar_dibujo(p["Letrero_BarLuz"], rutas["Letrero_Bar"], brilla=6.0)
    bpy.context.view_layer.update()
    ruedas = C.poner_ruedas(p)
    k = traer_kit_puerto()
    calle = escena_calle(p, k, 200, 0)
    callejon_ = escena_callejon(p, k, 200, 80)
    P.luz_puerto()
    luces_calle(calle + callejon_)
    for nombre, escena in (("calle", calle), ("callejon", callejon_)):
        print("CRUCES", nombre, cruces(escena))
    bpy.ops.wm.save_as_mainfile(filepath=C.BLEND)
    cuenta = B.contar_triangulos(piezas)
    with open(os.path.join(B.RENDERS, "calle-viva_triangulos.md"), "w", encoding="utf-8") as f:
        f.write(tabla(cuenta) + "\n")
    r = [
        P.render_orto("calle-viva_detalle_grilla", piezas + ruedas, giro=-25, altura=40, niebla=False),
        P.render_orto("calle-viva_detalle_calle", calle, giro=-32, altura=32),
        P.render_orto("calle-viva_detalle_callejon", callejon_, giro=-20, altura=28),
    ]
    return cuenta["_total"], r


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "detalle" in pasos:
        print(detalle("hornear" in pasos))
    if "exportar" in pasos:
        bpy.ops.wm.open_mainfile(filepath=C.BLEND)
        grupos = {"vehiculos": vehiculos, "vigilancia": vigilancia, "crimen": crimen, "callejon": callejon, "calle": calle}
        nombres = {g: [o.name.split(".")[0] for o in f()] for g, f in grupos.items()}  # solo para saber los nombres (las copias nuevas se borran abajo)
        for o in list(bpy.data.objects):
            if o.name.endswith(".001") or "." in o.name and o.name.split(".")[0] in C.PRESUPUESTO:
                bpy.data.objects.remove(o)
        total = 0
        for g, ns in nombres.items():
            objs = [bpy.data.objects[n] for n in ns if n in bpy.data.objects]
            total += len(P.exportar_kit(os.path.join("calle-viva", g), objs, ("Patrulla_Carroceria", "Compacto_", "Camioneta_", "Taxi_Carroceria", "Basura_", "Alijo")))
        print("EXPORTADAS", total)
