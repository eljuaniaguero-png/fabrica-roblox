"""Interior: Taller de Tano (Puerto Óxido), prompt P25d-01. Se rehizo de cero el 1 nov.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/interiores/taller.py -- boceto

Referencias: linajes/arte/referencias/gemini/interior-taller/ (ref-1 vista, ref-2 planta, ref-3 materiales).
Planta de 40 x 32 studs (el prompt dice 40 x 30; 32 para que entre en la grilla de 4), paredes de chapa de
16 y techo a dos aguas con cumbrera a 22 (entra en el lote de 50 x 22 x 40 del graybox). Frente a la calle
en -Y: portón de 12 x 10 a la izquierda (delante del elevador) y abierto. Oeste: elevador amarillo con
el auto. Fondo: banco de roble con morsa y el gancho a medio armar, tablero de herramientas arriba.
Este: entrepiso de madera con escalera; arriba, la cama y un cajón con la radio; abajo, el escritorio
de la compu pegado a la pared, con su silla.
Tambores en la esquina del fondo al oeste. Esquina del frente al este: carro rojo, compresor y locker verde; puerta lateral en el
este. Piso de losas con rejilla y chapa semilla de melón. Dos lámparas colgantes cálidas.
"""

import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
from mathutils import Matrix  # noqa: E402
import puerto_oxido as P  # noqa: E402

pieza, _barra = P.pieza, P._barra
ARCHIVO = "interior-taller"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")
ANCHO, FONDO, ALTO, CUMBRERA, MOD, G = 40, 32, 16, 22, 4, 0.8
HX, HY = ANCHO / 2, FONDO / 2
PORTON_X = (-16, -4)  # el portón ocupa x de -16 a -4 en el frente
PUERTA_Y = -6  # puerta lateral en la pared este
ENTREPISO = 8  # altura del piso del entrepiso

MARCADORES = {
    "PuntoNPC_Tano": (-8, -4, 0),  # junto al auto
    "PuntoNPC_Nico": (2, 10, 0),  # junto al banco
    "Banco": (14.2, 9, 0),  # silla del escritorio de la compu, abajo del entrepiso
    "Cama": (15.5, 13.1, ENTREPISO),  # cama del entrepiso
    "Salida": (-10, -17, 0),  # portón
    "Salida_Lateral": (21, PUERTA_Y, 0),
    "Spawn_Civil": (-10, -12, 0),  # cliente en la puerta
    "Tablero_Trabajos": (18, 1, 0),  # tablero de trabajos de Tano (pared este)
}

MATS = {
    "chapa": {"hex": "4a5560", "rugosidad": 0.6, "metal": 0.6},
    "concreto": {"hex": "5d5a55", "rugosidad": 0.95},
    "viga": {"hex": "5a3a2a", "rugosidad": 0.7, "metal": 0.6},
    "roble": {"hex": "6b4426", "rugosidad": 0.7},
    "amarillo": {"hex": "c9962e", "rugosidad": 0.5, "metal": 0.4},
    "rojo-herramienta": {"hex": "a8322a", "rugosidad": 0.45, "metal": 0.4},
    "verde-locker": {"hex": "3d5a3a", "rugosidad": 0.55, "metal": 0.5},
    "goma": {"hex": "16171a", "rugosidad": 0.9},
    "madera-entrepiso": {"hex": "5a4632", "rugosidad": 0.8},
    "neon-calido": {"hex": "f2a23a", "brillo": 4.0},
    "neon-gancho": {"hex": "3fe0f0", "brillo": 3.0},
    "vidrio-sucio": {"hex": "6f8fa3", "rugosidad": 0.2, "metal": 0.1, "brillo": 0.5},
    "manguera-amarilla": {"hex": "e0b13a", "rugosidad": 0.55},
    "almohada": {"hex": "e3ddcf", "rugosidad": 0.95},
    "beige-viejo": {"hex": "c9b98f", "rugosidad": 0.6},
    "beige-oscuro": {"hex": "a8996f", "rugosidad": 0.6},
    "pantalla-crt": {"hex": "0f3a2a", "rugosidad": 0.2, "brillo": 0.8},
    "texto-crt": {"hex": "6fe08a", "brillo": 1.4},
    "tela-silla": {"hex": "3a3f4a", "rugosidad": 0.9},
    "frazada": {"hex": "3d5a6e", "rugosidad": 0.95},
    "aceite": {"hex": "2b1d12", "rugosidad": 0.12},
    "aceite-borde": {"hex": "3d2c1e", "rugosidad": 0.45},
    "bateria": {"hex": "1b1d22", "rugosidad": 0.5},
    "borne-rojo": {"hex": "d0202e", "rugosidad": 0.4},
    "filtro": {"hex": "c8ccd2", "rugosidad": 0.25, "metal": 0.9},
    "manguera-naranja": {"hex": "d9762b", "rugosidad": 0.6},
    "papel": {"hex": "ece6d6", "rugosidad": 0.9},
    "papel-amarillo": {"hex": "e8d38a", "rugosidad": 0.9},
    "corcho": {"hex": "a87a4f", "rugosidad": 0.95},
    "mapa": {"hex": "6f8a8f", "rugosidad": 0.8},
    "charco": {"hex": "1a1612", "rugosidad": 0.25},
    "pintura-silueta": {"hex": "e8d38a", "rugosidad": 0.8},
    "tablero-oscuro": {"hex": "2e2a26", "rugosidad": 0.85},
    "faro-apagado": {"hex": "c9c2a8", "rugosidad": 0.2, "metal": 0.3},
    "mango-amarillo": {"hex": "e0b13a", "rugosidad": 0.5},
    "mango-azul": {"hex": "2f6fdb", "rugosidad": 0.5},
    "etiqueta-azul": {"hex": "3a6ea8", "rugosidad": 0.7},
    "etiqueta-verde": {"hex": "4e8a4a", "rugosidad": 0.7},
    "lata": {"hex": "a9b0b8", "rugosidad": 0.35, "metal": 0.8},
    "bidon": {"hex": "b33a2a", "rugosidad": 0.6},
    "mameluco-tano": {"hex": "2d4a73", "rugosidad": 0.85},
    "reloj": {"hex": "ece6d6", "rugosidad": 0.6},
    "calendario": {"hex": "f1ede2", "rugosidad": 0.9},
    "cartel-repuestos": {"hex": "c94a2a", "rugosidad": 0.8},
    "marca-neumatico": {"hex": "3a332c", "rugosidad": 0.9},
    "trapo": {"hex": "8e2a22", "rugosidad": 0.95},
    "radiador": {"hex": "2b2e33", "rugosidad": 0.6, "metal": 0.6},
    "grieta": {"hex": "2e2b28", "rugosidad": 0.95},
    "carton": {"hex": "9a7448", "rugosidad": 0.9},
    "lluvia": {"hex": "9fb4c4", "rugosidad": 0.2},
}


def estructura():
    """Paredes de chapa, piso, techo a dos aguas con cerchas, hastiales y portón."""
    o = []
    # frente (-Y): módulos de pared salvo el hueco del portón; dintel arriba del portón
    for x in range(-18, 19, MOD):
        if PORTON_X[0] < x < PORTON_X[1]:
            continue
        o.append(pieza(f"Pared_Frente_{x}", [((MOD, G, ALTO), (x, -HY + G / 2, ALTO / 2))], "chapa"))
    o.append(pieza("Porton_Dintel", [((12, G, ALTO - 10), ((PORTON_X[0] + PORTON_X[1]) / 2, -HY + G / 2, 10 + (ALTO - 10) / 2))], "chapa"))
    o.append(pieza("Porton_Cortina", [((12, 0.2, 0.55), ((PORTON_X[0] + PORTON_X[1]) / 2, -HY + 0.4, 5.3 + k * 0.6)) for k in range(8)], "chapa"))  # abierto a medias
    o.append(pieza("Porton_Rollo", [], "chapa", cilindros=[(0.9, 12.4, (PORTON_X[0] - 0.2, -HY - 0.6, 10.9), "X", 12)]))
    # fondo (+Y)
    for x in range(-16, 17, 8):  # en tramos de 8 (se hornean a 512)
        o.append(pieza(f"Pared_Fondo_{x}", [((8, G, ALTO), (x, HY - G / 2, ALTO / 2))], "chapa"))
    # oeste (-X), con 2 ventanas; este (+X), con puerta lateral y 1 ventana
    for lado, sx in (("Oeste", -1), ("Este", 1)):
      for tramo in range(4):  # tramos de 8 (2 módulos)
        cajas = []
        for y in (-14 + tramo * 8, -10 + tramo * 8):
            if lado == "Este" and y == PUERTA_Y:
                cajas.append(((G, MOD, ALTO - 7), (sx * (HX - G / 2), y, 7 + (ALTO - 7) / 2)))
            elif (lado == "Oeste" and y in (-6, 6)) or (lado == "Este" and y == 10):
                cajas += [((G, MOD, 6), (sx * (HX - G / 2), y, 3)), ((G, MOD, ALTO - 10), (sx * (HX - G / 2), y, 10 + (ALTO - 10) / 2))]
            else:
                cajas.append(((G, MOD, ALTO), (sx * (HX - G / 2), y, ALTO / 2)))
        o.append(pieza(f"Pared_{lado}_{tramo}", cajas, "chapa"))
    for i, (px, py) in enumerate(((-10, -8), (10, -8), (-10, 8), (10, 8))):  # 4 losas de 20 x 16 (piso a 1024)
        o.append(pieza(f"Piso_{i}", [((20, 16, 0.4), (px, py, -0.2))], "concreto"))
    # techo y cerchas cada 8 studs
    caida = math.degrees(math.atan((CUMBRERA - ALTO) / HX))
    largo = math.hypot(HX, CUMBRERA - ALTO) + 1
    o.append(pieza("Techo", [((largo, FONDO + 2, 0.4), (sx * HX / 2, 0, (ALTO + CUMBRERA) / 2 + 0.3), (0, sx * caida, 0)) for sx in (-1, 1)], "chapa"))
    cer = []
    for y in range(-12, 13, 8):
        cer.append(((ANCHO, 0.6, 0.6), (0, y, ALTO)))
        for sx in (-1, 1):
            cer.append(_barra((sx * HX, y, ALTO), (0, y, CUMBRERA - 0.3), 0.6))
            cer.append(_barra((sx * HX / 2, y, ALTO), (sx * HX / 2, y, ALTO + (CUMBRERA - ALTO) / 2 - 0.3), 0.4))
    o.append(pieza("Cerchas", cer, "viga"))
    v = [(-HX, 0, ALTO), (HX, 0, ALTO), (0, 0, CUMBRERA), (-HX, G, ALTO), (HX, G, ALTO), (0, G, CUMBRERA)]
    caras = [(0, 2, 1), (3, 4, 5), (0, 1, 4, 3), (1, 2, 5, 4), (2, 0, 3, 5)]
    o.append(pieza("Hastial_Fondo", [], "chapa", mallas=[([(x, y + HY - G, z) for x, y, z in v], caras)]))
    o.append(pieza("Hastial_Frente", [], "chapa", mallas=[([(x, y - HY, z) for x, y, z in v], caras)]))
    return o


def muebles():
    o = []
    # elevador amarillo de dos columnas a los costados del auto, brazos con tacos bajo los zócalos del auto
    ex, ey = -10, -2
    elev = [((1.4, 1.4, 12), (ex + sx * 5.6, ey, 6)) for sx in (-1, 1)] + [((2.6, 2.6, 0.3), (ex + sx * 5.6, ey, 0.15)) for sx in (-1, 1)]
    elev += [((1.8, 1.8, 1.0), (ex + sx * 5.6, ey, 3.9)) for sx in (-1, 1)]  # carros que suben por las columnas
    elev += [_barra((ex + sx * 5.6, ey, 4.0), (ex + sx * 2.6, ey + sy * 4.0, 4.0), 0.4) for sx in (-1, 1) for sy in (-1, 1)]
    elev += [((12.6, 0.8, 0.8), (ex, ey, 12.4))]  # travesaño de arriba
    o.append(pieza("Elevador", elev, "amarillo"))
    o.append(pieza("Elevador_Tacos", [((1.0, 1.0, 0.4), (ex + sx * 2.6, ey + sy * 4.0, 4.4)) for sx in (-1, 1) for sy in (-1, 1)], "goma"))
    # banco de roble contra el fondo, con morsa y el gancho; tablero de herramientas arriba
    bx, by = 2, HY - G - 1.6
    o.append(pieza("Banco", [((16, 3.2, 0.5), (bx, by, 3.3)), ((15.6, 3, 3), (bx, by + 0.1, 1.5))], "roble"))
    # morsa: base atornillada, mordaza fija, mordaza móvil, tornillo y manija en T
    mx, my, mz = bx - 6, by - 0.6, 3.55
    o.append(pieza("Banco_Morsa", [((1.3, 1.2, 0.25), (mx, my, mz + 0.125)), ((0.9, 0.5, 0.7), (mx, my + 0.35, mz + 0.6)), ((0.9, 0.4, 0.55), (mx, my - 0.55, mz + 0.53)),
                                   ((1.1, 0.15, 0.3), (mx, my + 0.05, mz + 0.95)), ((1.1, 0.15, 0.3), (mx, my - 0.33, mz + 0.95))], "mango-azul",
                   cilindros=[(0.1, 1.2, (mx, my - 1.6, mz + 0.5), "Y", 8)]))
    # engranaje grande con dientes, un carburador a medio desarmar y sus tornillos sueltos
    ex_, ey_ = bx + 1.6, by - 0.1
    dientes = [((0.18, 0.28, 0.2), (ex_ + math.cos(math.radians(a)) * 0.62, ey_ + math.sin(math.radians(a)) * 0.62, 3.65), (0, 0, a)) for a in range(0, 360, 30)]
    o.append(pieza("Banco_Engranaje", dientes, "acero", cilindros=[(0.55, 0.2, (ex_, ey_, 3.55), "Z", 16), (0.15, 0.3, (ex_, ey_, 3.55), "Z", 8)]))
    o.append(pieza("Banco_Carburador", [((0.8, 0.7, 0.6), (bx + 3.2, by + 0.3, 3.85)), ((0.25, 0.9, 0.25), (bx + 3.2, by - 0.4, 3.85))], "filtro",
                   cilindros=[(0.35, 0.4, (bx + 3.2, by + 0.3, 4.15), "Z", 12), (0.08, 0.1, (bx + 2.3, by - 0.8, 3.55), "Z", 6), (0.08, 0.1, (bx + 2.6, by - 0.95, 3.55), "Z", 6)]))
    o.append(pieza("Banco_Latas", [], "lata", cilindros=[(0.38, 0.9, (bx + 4.6, by + 0.6, 3.55), "Z", 14), (0.32, 0.7, (bx + 5.4, by + 0.7, 3.55), "Z", 14),
                                                      (0.36, 0.06, (bx + 4.6, by + 0.6, 4.45), "Z", 14), (0.3, 0.06, (bx + 5.4, by + 0.7, 4.25), "Z", 14)]))
    o.append(toro("Banco_LatasAro1", (bx + 4.6, by + 0.6, 4.45), "Z", 0.37, 0.035, "lata", 14, 4))
    o.append(toro("Banco_LatasAro2", (bx + 5.4, by + 0.7, 4.25), "Z", 0.31, 0.035, "lata", 14, 4))
    o.append(pieza("Banco_Latas_EtiquetaAzul", [], "etiqueta-azul", cilindros=[(0.4, 0.35, (bx + 4.6, by + 0.6, 3.8), "Z", 14)]))
    o.append(pieza("Banco_Latas_EtiquetaVerde", [], "etiqueta-verde", cilindros=[(0.34, 0.28, (bx + 5.4, by + 0.7, 3.75), "Z", 14)]))
    o.append(pieza("Tablero", [((14, 0.3, 5), (bx, HY - G - 0.15, 8.5))], "hierro"))
    o.append(pieza("Ventana_Marco", [((5, 0.3, 0.3), (bx, HY - G - 0.25, z)) for z in (11.65, 14.75)] + [((0.3, 0.3, 3.4), (bx + sx * 2.35, HY - G - 0.25, 13.2)) for sx in (-1, 1)] + [((0.15, 0.3, 2.8), (bx, HY - G - 0.25, 13.2))], "hierro"))
    o.append(pieza("Glass_Ventana_Fondo", [((4.4, 0.1, 2.8), (bx, HY - G - 0.2, 13.2))], "vidrio-sucio"))  # ventanita sucia
    # escritorio de la compu contra la pared este, abajo del entrepiso, con silla (la compu mira al taller)
    dx, dy = HX - G - 1.6, 9  # escritorio de 3,2 de fondo x 6 de largo, pegado a la pared
    esc = [((3.2, 6, 0.3), (dx, dy, 3.15))]  # tapa
    esc += [((0.3, 0.3, 3.0), (dx + sx * 1.4, dy + sy * 2.8, 1.5)) for sx in (-1, 1) for sy in (-1, 1)]  # patas
    esc += [((2.8, 2, 2.2), (dx + 0.1, dy + 1.8, 1.9))]  # cajonera
    o.append(pieza("MesaFabricacion", esc, "roble"))
    o.append(pieza("MesaFabricacion_Monitor", [((0.4, 2.8, 1.8), (dx + 0.6, dy, 4.6)), ((0.3, 0.3, 0.8), (dx + 0.8, dy, 3.7)), ((1, 1.2, 0.1), (dx + 0.8, dy, 3.35))], "hierro"))
    o.append(pieza("MesaFabricacion_Pantalla", [((0.1, 2.5, 1.5), (dx + 0.35, dy, 4.6))], "neon-cian"))
    o.append(pieza("MesaFabricacion_Teclado", [((0.8, 2, 0.12), (dx - 0.6, dy, 3.36))], "hierro"))
    silla = [((2, 2, 0.3), (dx - 3.2, dy, 2.0)), ((0.3, 2, 2.4), (dx - 4.1, dy, 3.35))]  # asiento y respaldo
    silla += [((0.3, 0.3, 1.85), (dx - 3.2 + sx * 0.8, dy + sy * 0.8, 0.925)) for sx in (-1, 1) for sy in (-1, 1)]
    o.append(pieza("Silla", silla, "hierro"))
    # entrepiso este: piso de madera sobre 2 postes, baranda, escalera, catre y radio
    ex0, ex1, ey0, ey1 = 11, HX - G, 4, HY - G
    cx, cy = (ex0 + ex1) / 2, (ey0 + ey1) / 2
    ent = [((ex1 - ex0, ey1 - ey0, 0.6), (cx, cy, ENTREPISO - 0.3))]
    ent += [((0.8, 0.8, ENTREPISO - 0.6), (ex0 + 0.4, y, (ENTREPISO - 0.6) / 2)) for y in (ey0 + 0.4, ey1 - 0.4)]
    o.append(pieza("Entrepiso", ent, "madera-entrepiso"))
    bar = [((ex1 - ex0, 0.3, 0.3), (cx, ey0 + 0.15, ENTREPISO + 3)), ((0.3, ey1 - ey0 - 3, 0.3), (ex0 + 0.15, cy + 1.5, ENTREPISO + 3))]
    bar += [((0.3, 0.3, 3), (x, ey0 + 0.15, ENTREPISO + 1.5)) for x in (ex0 + 0.15, cx, ex1 - 0.3)]
    o.append(pieza("Entrepiso_Baranda", bar, "hierro"))
    esc = [((0.3, 0.3, ENTREPISO + 3), (ex0 - 0.4, y, (ENTREPISO + 3) / 2)) for y in (ey0 + 0.8, ey0 + 2.6)]
    esc += [((0.3, 1.8, 0.25), (ex0 - 0.4, ey0 + 1.7, z)) for z in range(1, ENTREPISO + 2)]
    o.append(pieza("Escalera", esc, "madera-entrepiso"))
    # cama de verdad arriba del entrepiso: marco con patas, colchón, almohada y frazada; cajón con la radio al lado
    kx, ky = cx + 0.4, ey1 - 2.1
    marco = [((7, 3.4, 0.4), (kx, ky, ENTREPISO + 1.0))] + [((0.4, 0.4, 0.8), (kx + sx * 3.3, ky + sy * 1.5, ENTREPISO + 0.4)) for sx in (-1, 1) for sy in (-1, 1)]
    marco += [((0.4, 3.4, 1.8), (kx + 3.3, ky, ENTREPISO + 1.7))]  # cabecera
    o.append(pieza("Cama", marco, "hierro"))
    o.append(pieza("Cama_Colchon", [((6.4, 3.2, 0.6), (kx - 0.1, ky, ENTREPISO + 1.5))], "maniqui"))

    o.append(pieza("Cajon", [((1.6, 1.6, 1.6), (ex0 + 1.4, ky - 3.2, ENTREPISO + 0.8))], "madera-entrepiso"))
    o.append(pieza("Radio", [((1.4, 0.7, 0.9), (ex0 + 1.4, ky - 3.2, ENTREPISO + 2.05))], "acero"))
    # 5) cajas de cartón en el entrepiso
    o.append(pieza("Cajas", [((2.2, 2.0, 1.6), (16.4, 6.6, ENTREPISO + 0.8)), ((1.6, 1.6, 1.2), (16.6, 6.8, ENTREPISO + 2.2)), ((1.8, 1.8, 1.4), (18.2, 7.0, ENTREPISO + 0.7))], "carton"))
    o.append(pieza("Tambores", [], "oxido", cilindros=[(1.2, 3.6, (x, y, 0), "Z", 14) for x, y in ((-17.6, 12.4), (-15, 13))]))
    # esquina del frente al este: carro rojo, compresor y locker verde
    # carro de herramientas rojo con ruedas de verdad (los cajones miran al taller)
    car = [((3, 2, 3.0), (9, -11, 2.1)), ((3.3, 2.3, 0.2), (9, -11, 3.7)), ((3.3, 0.15, 0.5), (9, -12.1, 3.95))]  # cuerpo, tapa y borde
    car += [((0.25, 0.25, 0.3), (9 + sx * 1.2, -11 + sy * 0.7, 0.45)) for sx in (-1, 1) for sy in (-1, 1)]  # horquillas
    o.append(pieza("CarroHerramientas", car, "rojo-herramienta"))
    o.append(pieza("CarroHerramientas_Ruedas", [], "goma", cilindros=[(0.3, 0.2, (9 + sx * 1.2 - 0.1, -11 + sy * 0.7, 0.3), "X", 10) for sx in (-1, 1) for sy in (-1, 1)]))
    # compresor: tanque horizontal sobre patas, motor y cubrecorrea arriba
    cmp = [((0.5, 1.8, 0.5), (x, -13.5, 0.25)) for x in (12.8, 15.0)]
    cmp += [((1.3, 1.2, 1.1), (13.4, -13.5, 3.0)), ((0.35, 1.3, 1.1), (14.5, -13.5, 3.0))]
    o.append(pieza("Compresor", cmp, "rojo-herramienta", cilindros=[(1.0, 3.4, (12.2, -13.5, 1.4), "X", 14)]))
    o.append(pieza("Locker", [((3, 2.2, 7), (HX - G - 1.5, -HY + G + 1.2, 3.5))], "verde-locker"))
    # piso: rejilla y chapa semilla de melón (finitas, apoyadas)
    o.append(pieza("Piso_Rejilla", [((3, 1.4, 0.08), (-2, -9, 0.04))], "hierro"))
    # lámparas colgantes cálidas (cadena + pantalla + foco Neon_)
    for i, x in enumerate((-8, 10)):
        # cuelgan del tirante de la cercha (y = -4, z = 16 - 0,3)
        o.append(pieza(f"Lampara{i}", [((0.15, 0.15, 1.0), (x, -4, ALTO - 0.8))], "hierro", cilindros=[(1.3, 0.8, (x, -4, 14.5), "Z", 12, 0.4)]))
        o.append(pieza(f"Neon_Lampara{i}", [((0.6, 0.6, 0.4), (x, -4, 14.3))], "neon-calido"))
    return o


def abrir_capo(car, ey, z):
    """Saca las caras de arriba del capó (de y < -3,5 respecto del centro del auto) para que se vea el motor."""
    import bmesh

    bpy.context.view_layer.update()  # sin esto matrix_world todavía no tiene la posición nueva
    car.data = car.data.copy()
    bm = bmesh.new()
    bm.from_mesh(car.data)
    bm.normal_update()
    mw = car.matrix_world
    borrar = []
    for f in bm.faces:
        c = mw @ f.calc_center_median()
        n = (mw.to_3x3() @ f.normal).normalized()
        if c.y / B.STUD - ey < -3.4 and abs(n.z) > 0.4 and c.z / B.STUD - z > 2.2:  # la malla puede tener normales dadas vuelta
            borrar.append(f)
    bmesh.ops.delete(bm, geom=borrar, context="FACES")
    bm.to_mesh(car.data)
    bm.free()
    return len(borrar)


def lluvia_afuera(objeto):
    """Deja solo las gotas que caen afuera del galpón (a los costados y adelante del frente)."""
    import bmesh

    bm = bmesh.new()
    bm.from_mesh(objeto.data)
    adentro = [v for v in bm.verts if abs(v.co.x / B.STUD) < HX + 1.5 and v.co.y / B.STUD > -HY - 1.0]
    bmesh.ops.delete(bm, geom=adentro, context="VERTS")
    bm.to_mesh(objeto.data)
    bm.free()


def motor(ex, ey, z):
    """Vano del motor con el capó abierto: block, tapa de válvulas con nervios, filtro de aire con tuercas,
    radiador con panal, 2 mangueras curvas negras, correa con poleas, batería con bornes y el cable rojo colgando."""
    piezas = [pieza("Auto_MotorFondo", [((5.8, 3.2, 0.2), (ex, ey - 5.0, z + 1.2))], "goma")]
    piezas.append(pieza("Auto_Motor", [((2.8, 1.8, 1.0), (ex - 0.4, ey - 4.8, z + 1.8))], "hierro"))
    tapa = [((2.6, 1.2, 0.3), (ex - 0.4, ey - 4.8, z + 2.45))] + [((2.4, 0.12, 0.12), (ex - 0.4, ey - 4.8 + d, z + 2.65)) for d in (-0.4, -0.13, 0.13, 0.4)]
    piezas.append(pieza("Auto_TapaValvulas", tapa, "rojo-herramienta"))
    fx, fy, fz = ex + 1.6, ey - 4.4, z + 2.2
    piezas.append(pieza("Auto_FiltroBase", [], "negro", cilindros=[(0.7, 0.25, (fx, fy, fz - 0.25), "Z", 14)]))
    piezas.append(pieza("Auto_Filtro", [], "filtro", cilindros=[(0.85, 0.35, (fx, fy, fz), "Z", 18), (0.2, 0.2, (fx, fy, fz + 0.35), "Z", 8)]
                        + [(0.07, 0.08, (fx + math.cos(a) * 0.6, fy + math.sin(a) * 0.6, fz + 0.35), "Z", 6) for a in (0.4, 2.0, 3.6, 5.2)]))
    # radiador al frente: marco y panal (barras finas cruzadas)
    ry_ = ey - 6.45
    rad = [((5.4, 0.25, 0.2), (ex, ry_, z + 2.5)), ((5.4, 0.25, 0.2), (ex, ry_, z + 1.3)), ((0.2, 0.25, 1.4), (ex - 2.6, ry_, z + 1.9)), ((0.2, 0.25, 1.4), (ex + 2.6, ry_, z + 1.9))]
    rad += [((0.05, 0.12, 1.0), (ex - 2.3 + k * 0.32, ry_ - 0.08, z + 1.9)) for k in range(15)] + [((5.0, 0.12, 0.05), (ex, ry_ - 0.08, z + 1.5 + k * 0.2)) for k in range(5)]
    piezas.append(pieza("Auto_Radiador", rad, "radiador"))
    # 2 mangueras curvas negras del radiador al motor
    for x0, x1, z0, z1 in ((ex + 1.0, ex - 0.6, z + 2.3, z + 2.2), (ex - 1.8, ex - 1.4, z + 1.5, z + 1.5)):
        pts = [(x0, ry_ + 0.15, z0), ((x0 + x1) / 2 + 0.3, ry_ + 0.5, z0 + 0.35), (x1, ey - 5.75, z1 + 0.1)]
        piezas.append(pieza(f"Auto_Manguera{int(x0 > ex)}", [_barra(pts[0], pts[1], 0.2), _barra(pts[1], pts[2], 0.2)], "negro"))
    # correa con poleas en la cara de adelante del block
    py_ = ey - 5.78
    poleas = [(ex - 1.2, z + 1.5, 0.38), (ex - 0.2, z + 2.0, 0.26), (ex - 0.1, z + 1.3, 0.22)]
    piezas.append(pieza("Auto_Poleas", [], "acero", cilindros=[(r, 0.12, (x, py_, zz), "Y", 12) for x, zz, r in poleas]))
    piezas.append(pieza("Auto_Correa", [_barra((poleas[0][0], py_ - 0.06, poleas[0][1] + poleas[0][2]), (poleas[1][0], py_ - 0.06, poleas[1][1] + poleas[1][2]), 0.06),
                                         _barra((poleas[1][0] + poleas[1][2], py_ - 0.06, poleas[1][1]), (poleas[2][0] + poleas[2][2], py_ - 0.06, poleas[2][1]), 0.06),
                                         _barra((poleas[2][0], py_ - 0.06, poleas[2][1] - poleas[2][2]), (poleas[0][0], py_ - 0.06, poleas[0][1] - poleas[0][2]), 0.06)], "negro"))
    # batería con bornes y el cable rojo que cuelga hasta abajo con su pinza
    piezas.append(pieza("Auto_Bateria", [((1.2, 0.9, 0.9), (ex + 2.0, ey - 5.75, z + 1.75))], "bateria"))
    piezas.append(pieza("Auto_Borne_Rojo", [], "borne-rojo", cilindros=[(0.14, 0.22, (ex + 1.65, ey - 5.75, z + 2.2), "Z", 8)]))
    piezas.append(pieza("Auto_Borne_Negro", [], "negro", cilindros=[(0.14, 0.22, (ex + 2.35, ey - 5.75, z + 2.2), "Z", 8)]))
    cab = [_barra((ex + 1.65, ey - 5.75, z + 2.3), (ex + 3.2, ey - 6.3, z + 2.6), 0.08), _barra((ex + 3.2, ey - 6.3, z + 2.6), (ex + 3.9, ey - 6.6, z + 0.6), 0.08),
           _barra((ex + 3.9, ey - 6.6, z + 0.6), (ex + 4.1, ey - 6.9, z - 1.4), 0.08)]
    piezas.append(pieza("Auto_CableBateria", cab, "borne-rojo"))
    piezas.append(pieza("Auto_CableBateria_Pinza", [((0.25, 0.4, 0.5), (ex + 4.1, ey - 6.9, z - 1.65))], "borne-rojo"))
    return piezas


def trapos():
    """El trapo rojo de Tano con simulación de tela de Blender: uno colgando del borde del banco y otro hecho un
    bollo arriba (esfera con ruido fuerte). Después se aplica todo y quedan mallas fijas."""
    bx, by = 2, HY - G - 1.6
    banco = bpy.data.objects["Banco"]
    banco.modifiers.new("Choque", "COLLISION")
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=12, y_subdivisions=16, size=1)
    tela = bpy.context.active_object
    tela.name = "Banco_Trapo"
    tela.scale = (1.0 * B.STUD, 1.6 * B.STUD, 1)
    tela.location = P.S(bx - 1.6, by - 1.6 - 0.2, 3.62)
    bpy.ops.object.transform_apply(scale=True)
    grupo = tela.vertex_groups.new(name="Fijo")
    fijos = [v.index for v in tela.data.vertices if v.co.y > 0.55 * B.STUD]  # el borde que queda arriba del banco
    grupo.add(fijos, 1.0, "REPLACE")
    tela.location.y += 0.0
    sim = tela.modifiers.new("Tela", "CLOTH")
    sim.settings.vertex_group_mass = "Fijo"
    sim.settings.quality = 6
    sim.collision_settings.distance_min = 0.004
    escena = bpy.context.scene
    escena.frame_start, escena.frame_end = 1, 45
    sim.point_cache.frame_start, sim.point_cache.frame_end = 1, 45
    for f in range(1, 46):
        escena.frame_set(f)
        bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    simulada = bpy.data.meshes.new_from_object(tela.evaluated_get(dg))
    tela.modifiers.clear()
    vieja, tela.data = tela.data, simulada
    bpy.data.meshes.remove(vieja)
    zs = [v.co.z for v in tela.data.vertices]
    if max(zs) - min(zs) < 0.3 * B.STUD:  # la simulación no corrió (pasa en modo sin ventana): pliegue a mano
        borde = (by - 1.6) * B.STUD
        for v in tela.data.vertices:
            mundo = tela.matrix_world @ v.co
            fuera = borde - mundo.y
            if fuera > 0:
                mundo.z -= fuera
                mundo.y = borde - 0.03 * B.STUD + 0.05 * B.STUD * math.sin(mundo.x / B.STUD * 9)
                mundo.x += 0.04 * B.STUD * math.sin(fuera / B.STUD * 7)
                v.co = tela.matrix_world.inverted() @ mundo
        print("TRAPO: plegado a mano", flush=True)
    else:
        print("TRAPO: simulado", flush=True)
    banco.modifiers.remove(banco.modifiers["Choque"])
    escena.frame_set(1)
    B.aplicar_material(tela, "trapo")
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.5 * B.STUD)
    bollo = bpy.context.active_object
    bollo.name = "Banco_TrapoBollo"
    bollo.scale = (1.0, 0.8, 0.5)
    bollo.location = P.S(bx + 0.2, by + 0.4, 3.55 + 0.24)
    tex = bpy.data.textures.new("Arrugas", "CLOUDS")
    tex.noise_scale = 0.06
    d = bollo.modifiers.new("Arrugas", "DISPLACE")
    d.texture = tex
    d.strength = 0.07
    bpy.context.view_layer.objects.active = bollo
    bpy.ops.object.modifier_apply(modifier="Arrugas")
    bpy.ops.object.transform_apply(scale=True)
    B.aplicar_material(bollo, "trapo")
    return [tela, bollo]


def pintar_auto(*objs):
    """Pinta el auto de verde oliva gastado: multiplica la textura horneada (casi blanca) por el color,
    así se conservan la suciedad y los rayones del horneado."""
    for o in objs:
        mat = o.active_material.copy()
        mat.name = "MAT_auto-oliva"
        nt = mat.node_tree
        bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
        entrada = bsdf.inputs["Base Color"]
        mezcla = nt.nodes.new("ShaderNodeMix")
        mezcla.data_type = "RGBA"
        mezcla.blend_type = "MULTIPLY"
        mezcla.inputs["Factor"].default_value = 1.0
        mezcla.inputs[7].default_value = B.color("6c9a5e")
        if entrada.links:
            nt.links.new(entrada.links[0].from_socket, mezcla.inputs[6])
        else:
            mezcla.inputs[6].default_value = entrada.default_value
        nt.links.new(mezcla.outputs[2], entrada)
        o.data.materials.clear()
        o.data.materials.append(mat)


def auto():
    """El compacto de la calle viva (ya horneado) arriba del elevador, con sus 4 ruedas."""
    with bpy.data.libraries.load(os.path.join(B.BLENDER, "calle-viva.blend"), link=False) as (desde, hacia):
        hacia.objects = [n for n in desde.objects if n in ("Compacto_Carroceria", "Civil_Rueda", "Auto_Vidrios", "Auto_Faros", "Auto_Stop")]
    fuente = {o.name: o for o in hacia.objects if o}
    for o in fuente.values():
        bpy.context.scene.collection.objects.link(o)
        o.location = (0, 0, -400)
    ex, ey, z = -10, -2, 4.6
    h = [P.copia(fuente["Compacto_Carroceria"], ex, ey, 0, z)]
    h[0].name = "Auto_Carroceria"
    for n, nuevo in (("Auto_Vidrios", "Glass_Auto_Vidrios"),):
        if n in fuente:
            c = P.copia(fuente[n], ex, ey, 0, z)
            c.name = nuevo
            h.append(c)
    # capó abierto: se sacan las caras de arriba del capó y se agrega la tapa levantada con el mismo material
    car = h[0]
    abrir_capo(car, ey, z)
    capo = pieza("Auto_Capo", [((6.2, 3.3, 0.15), (ex, ey - 3.5 - 0.56, z + 3.8 + 1.55), (-70, 0, 0))], "hierro")
    capo.data.materials.clear()
    capo.data.materials.append(car.active_material)
    pintar_auto(car, capo)
    h.append(capo)
    h += motor(ex, ey, z)
    h.append(pieza("Auto_Faros", [((1.2, 0.1, 0.5), (ex + sx * 2.4, ey - 6.95, z + 2.0)) for sx in (-1, 1)], "faro-apagado"))  # apagados: el auto está en reparación
    for i, (sx, sy) in enumerate(((-1, -1), (-1, 1), (1, -1), (1, 1))):
        if i == 0:  # la de adelante a la izquierda está desmontada, apoyada en la columna del elevador
            r = P.copia(fuente["Civil_Rueda"], ex - 5.6, ey - 4.3, 0, 0.2)
            r.rotation_euler.x -= 0.16
        else:
            r = P.copia(fuente["Civil_Rueda"], ex + sx * 3.4, ey + sy * 4.2, 0 if sx > 0 else 180, z)
        r.name = f"Auto_Rueda{i}"
        h.append(r)
    for o in fuente.values():
        bpy.data.objects.remove(o)
    return h


def marcadores():
    for n, (x, y, z) in MARCADORES.items():
        e = bpy.data.objects.new(n, None)
        e.empty_display_type = "ARROWS"
        e.empty_display_size = 2 * B.STUD
        e.location = P.S(x, y, z)
        bpy.context.scene.collection.objects.link(e)
    destino = os.path.join(B.EXPORTS, ARCHIVO)
    os.makedirs(destino, exist_ok=True)
    with open(os.path.join(destino, "marcadores.json"), "w", encoding="utf-8") as f:
        json.dump({n: {"x": x, "y": z, "z": -y} for n, (x, y, z) in MARCADORES.items()}, f, indent=2, ensure_ascii=False)


def maniqui():
    """Maniquí de 5 studs para la escala, al lado del elevador (como en la ref-1)."""
    return pieza("Maniqui_Escala", [((2, 1, 2), (-3, -8, 1)), ((2, 1, 2), (-3, -8, 3)), ((1.2, 1.2, 1), (-3, -8, 4.5))], "maniqui")


_arboles = {}


def _arbol(o):
    from mathutils.bvhtree import BVHTree

    if o.name not in _arboles:
        dg = bpy.context.evaluated_depsgraph_get()
        me = o.evaluated_get(dg).to_mesh()
        vs = [o.matrix_world @ v.co for v in me.vertices]
        _arboles[o.name] = BVHTree.FromPolygons(vs, [tuple(p.vertices) for p in me.polygons])
        o.evaluated_get(dg).to_mesh_clear()
    return _arboles[o.name]


def revisar(objs):
    """Cruces entre mallas (BVH) sin contar la estructura entre sí, y muebles de piso que flotan."""
    from mathutils import Vector as V

    bpy.context.view_layer.update()
    estructura = ("Pared", "Piso", "Techo", "Cerchas", "Hastial", "Porton")
    juntos = {("Elevador", "Auto"), ("Elevador", "Auto_Ruedas"), ("Auto", "Auto_Ruedas"), ("Banco", "Banco_Morsa"), ("Banco", "Banco_Gancho"),
              ("Columnas", "Correas"), ("MesaFabricacion", "Compu"), ("Compresor", "Compresor_Manguera"), ("Compresor_Manguera", "Compresor_MangueraRollo"), ("Tablero", "Tablero_MangueraGancho"), ("Tablero", "Tablero_Manguera0"), ("Tablero_Manguera0", "Tablero_Manguera1"), ("Tablero_Manguera1", "Tablero_Manguera2"), ("Tablero_Manguera2", "Tablero_Manguera3"), ("Tablero_MangueraGancho", "Tablero_Manguera0"), ("GanchoPanel", "Gancho"), ("Gancho", "Gancho_Empunadura"), ("Gancho", "Gancho_Rollo"), ("Gancho_Rollo", "Gancho_Cable"), ("Gancho", "Gancho_Cable"), ("GanchoPanel", "GanchoPanel_Silueta"), ("GanchoPanel_Silueta", "Gancho"), ("GanchoPanel_Silueta", "GanchoPanel_Soportes"), ("GanchoPanel_Silueta", "Gancho_Empunadura"),
              ("Tablero", "Tablero_Siluetas"), ("Tablero_Siluetas", "Tablero_Herramientas"), ("Tablero_Siluetas", "Tablero_Mangos"), ("Tablero_Siluetas", "Tablero_MangosAzules"), ("Tablero_Herramientas", "Tablero_MangosAzules"),
              ("Banco", "Banco_Engranaje"), ("Banco", "Banco_Carburador"), ("Banco", "Banco_Trapo"), ("Banco_Latas", "Banco_Latas_EtiquetaAzul"), ("Banco_Latas", "Banco_Latas_EtiquetaVerde"), ("Banco_Cajones", "Banco_Trapo"),
              ("Auto", "Auto_CableBateria"), ("Auto_Bateria", "Auto_CableBateria"), ("Auto_Borne_Rojo", "Auto_CableBateria"), ("Auto_CableBateria", "Auto_CableBateria_Pinza"), ("Elevador", "Auto_CableBateria"),
              ("Calendario", "Calendario_Cabecera"), ("Reloj", "Reloj_Agujas"), ("CartelRepuestos", "CartelRepuestos_Dibujo"), ("Entrepiso_Baranda", "Baranda_Mameluco"), ("Entrepiso", "Cama_FrazadaAsoma"), ("GanchoPanel", "Gancho"), ("GanchoPanel", "GanchoPanel_Soportes"), ("Gancho", "GanchoPanel_Soportes"), ("TableroTrabajos", "TableroTrabajos"), ("Ventanas", "Glass"), ("Puerta", "Pared"), ("Cables", "Cerchas"), ("Auto", "Glass"), ("Tablero", "Tablero_Gancho"), ("Banco", "Banco_Pieza"), ("Banco", "Banco_Latas"), ("Entrepiso", "Cajas"), ("Ventana", "Glass"), ("Entrepiso", "Entrepiso_Baranda"), ("Entrepiso", "Cama"), ("Entrepiso", "Cajon"), ("Cajon", "Radio"),
              ("Entrepiso", "Escalera"), ("CarroHerramientas", "CarroHerramientas"), ("Compresor", "Compresor")}
    cajas = {}
    for o in objs:
        if o.type == "MESH":
            pts = [o.matrix_world @ V(c) for c in o.bound_box]
            cajas[o.name] = ([min(q[i] for q in pts) / B.STUD for i in range(3)], [max(q[i] for q in pts) / B.STUD for i in range(3)])
    nombres = list(cajas)
    cruces, flotan = [], []
    for i, a in enumerate(nombres):
        mna, mxa = cajas[a]
        if not a.startswith(estructura) and not a.startswith(("Neon_", "Lampara", "Tablero", "Ventana", "Entrepiso", "Cama", "Cajon", "Radio", "Escalera", "Banco_", "CarroHerramientas", "Compu", "Silla", "Cajas", "Glass_", "Cables", "Compresor_Manguera", "Ventanas", "Gancho", "TableroTrabajos", "Puerta", "Calendario", "Reloj", "CartelRepuestos", "Baranda_", "Cama_", "Auto_CableBateria")) and 0.03 < mna[2] < 0.6:
            flotan.append((a, round(mna[2], 2)))
        for b in nombres[i + 1 :]:
            if a.startswith(estructura) and b.startswith(estructura):
                continue
            libres = ("Ondas", "Zocalo", "Piso_Manchas", "Piso_Charco", "Piso_Grietas", "Piso_MarcasNeumatico", "Ventanas_Marcos", "Puerta_Lateral", "Calendario", "Reloj", "CartelRepuestos")
            if a.startswith(libres) or b.startswith(libres):
                continue
            base_a, base_b = a.split("_")[0], b.split("_")[0]
            if (base_a, base_b) in juntos or (base_b, base_a) in juntos or base_a == base_b or a.startswith(("Neon_", "Glass_")) or b.startswith(("Neon_", "Glass_")):
                continue
            mnb, mxb = cajas[b]
            if min(min(mxa[k], mxb[k]) - max(mna[k], mnb[k]) for k in range(3)) > 0.05 and _arbol(bpy.data.objects[a]).overlap(_arbol(bpy.data.objects[b])):
                cruces.append((a, b))
    return cruces, flotan


def camara(nombre, desde, hacia, lente=22, niebla=False, ocultar=()):
    escena = bpy.context.scene
    datos = bpy.data.cameras.new("Adentro")
    datos.lens = lente
    cam = bpy.data.objects.new("Adentro", datos)
    escena.collection.objects.link(cam)
    a, b = P.S(*desde), P.S(*hacia)
    cam.matrix_world = Matrix.Translation(a) @ (b - a).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    escena.camera = cam
    escena.render.resolution_x, escena.render.resolution_y = 1600, 1000
    ruta = os.path.join(B.RENDERS, nombre + ".png")
    escena.render.filepath = ruta
    nb = bpy.data.objects.get("Niebla")
    if nb:
        nb.hide_render = not niebla
    escondidos = [o for o in escena.objects if ocultar and o.name.startswith(ocultar) and not o.hide_render]
    for o in escondidos:
        o.hide_render = True
    bpy.ops.render.render(write_still=True)
    for o in escondidos:
        o.hide_render = False
    bpy.data.objects.remove(cam)
    return ruta


def boceto():
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    for k, v in MATS.items():
        B.MATERIALES[k] = v
    B.MATERIALES.setdefault("porton-verde", {"hex": "2f5d5a", "rugosidad": 0.6, "metal": 0.5})
    B.MATERIALES.setdefault("hierro", {"hex": "3a3d42", "rugosidad": 0.6, "metal": 0.7})
    est = estructura()
    mue = muebles()
    man = maniqui()
    marcadores()
    P.luz_puerto()
    for i, x in enumerate((-8, 10)):
        d = bpy.data.lights.new(f"Luz{i}", "POINT")
        d.color = B.color("ffc27a")[:3]
        d.energy = 600
        luz = bpy.data.objects.new(f"Luz{i}", d)
        bpy.context.scene.collection.objects.link(luz)
        luz.location = P.S(x, -4, 13.6)
    d = bpy.data.lights.new("LuzEscritorio", "POINT")  # foquito bajo el entrepiso
    d.color = B.color("ffc27a")[:3]
    d.energy = 150
    luz = bpy.data.objects.new("LuzEscritorio", d)
    bpy.context.scene.collection.objects.link(luz)
    luz.location = P.S(16, 9, ENTREPISO - 1.2)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    cruces, flotan = revisar(est + mue)
    sin_techo = [o for o in est if not o.name.startswith(("Techo", "Hastial", "Cerchas"))] + mue + [man]
    r1 = P.render_orto(ARCHIVO + "_boceto_planta", [o for o in sin_techo if not o.name.startswith(("Lampara", "Neon_", "Glass_"))], giro=0, altura=89, niebla=False, solo=True)
    r2 = camara(ARCHIVO + "_boceto_puerta", (-9, -15, 6.5), (6, 10, 4.5), lente=16)
    r3 = camara(ARCHIVO + "_boceto_fondo", (-17, 14, 10), (8, -10, 3), lente=16)
    r4 = P.render_orto(ARCHIVO + "_boceto_corte", [o for o in sin_techo if not o.name.startswith(("Pared_Frente", "Ondas_Frente", "Porton", "Lampara", "Neon_"))], giro=-25, altura=35, niebla=False, solo=True)
    r5 = camara(ARCHIVO + "_boceto_entrepiso", (3, -6, 7), (17, 9, 4), lente=20)
    return {"cruces": cruces, "flotan": flotan, "triangulos": B.contar_triangulos(est + mue), "renders": [r1, r2, r3, r4, r5]}


# ---------------------------------------------------------------------------
# Paso 2: detalle (lo que se suma al boceto) y horneado con límites seguros
# ---------------------------------------------------------------------------

RECETAS_TALLER = {
    "chapa": {"paneles": (0.6, 0.0), "remaches": True, "rayones": 0.6, "bordes": 0.6, "suciedad": 0.9, "grano": 0.4},
    "concreto": {"rayones": 0.3, "bordes": 0.3, "suciedad": 1.0, "grano": 0.8},
    "roble": {"rayones": 0.5, "bordes": 0.5, "suciedad": 0.6, "grano": 1.0},
    "amarillo": {"paneles": (0.5, 0.5), "remaches": True, "rayones": 0.8, "bordes": 0.7, "suciedad": 0.7, "grano": 0.3},
    "rojo-herramienta": {"rayones": 0.8, "bordes": 0.6, "suciedad": 0.5, "grano": 0.2},
    "verde-locker": {"rayones": 0.9, "bordes": 0.7, "suciedad": 0.7, "grano": 0.3},
    "madera-entrepiso": {"rayones": 0.4, "bordes": 0.5, "suciedad": 0.8, "grano": 1.0},
    "viga": {"remaches": True, "rayones": 0.6, "bordes": 0.6, "suciedad": 0.9, "grano": 0.4},
    "porton-verde": {"paneles": (0.25, 0.4), "rayones": 0.7, "bordes": 0.6, "suciedad": 0.7, "grano": 0.2},
}


def tubo(nombre, puntos, radio, material, radio_punta=None):
    """Tubo liso que sigue una curva suave por los puntos (en studs). Si hay radio_punta, se afina hacia el final."""
    datos = bpy.data.curves.new(nombre, "CURVE")
    datos.dimensions = "3D"
    datos.resolution_u = 6
    datos.bevel_depth = radio * B.STUD
    datos.bevel_resolution = 2
    datos.use_fill_caps = True
    sp = datos.splines.new("NURBS")
    sp.points.add(len(puntos) - 1)
    for i, pt in enumerate(puntos):
        sp.points[i].co = (*P.S(*pt), 1.0)
        if radio_punta is not None:
            sp.points[i].radius = 1.0 + (radio_punta / radio - 1.0) * i / (len(puntos) - 1)
    sp.use_endpoint_u = True
    sp.order_u = 3
    ob = bpy.data.objects.new(nombre, datos)
    bpy.context.scene.collection.objects.link(ob)
    malla = bpy.data.meshes.new_from_object(ob.evaluated_get(bpy.context.evaluated_depsgraph_get()))
    bpy.data.objects.remove(ob)
    bpy.data.curves.remove(datos)
    nuevo = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(nuevo)
    B.aplicar_material(nuevo, material)
    return nuevo


def toro(nombre, centro, eje, radio, grosor, material, lados=16, anillo=6):
    """Toro (aro) como malla: para el rollo de cable y el anillo de la punta del gancho."""
    cx, cy, cz = centro
    vs, fs = [], []
    for i in range(lados):
        a = 2 * math.pi * i / lados
        for j in range(anillo):
            b = 2 * math.pi * j / anillo
            r = radio + grosor * math.cos(b)
            u, v, w = r * math.cos(a), r * math.sin(a), grosor * math.sin(b)
            if eje == "X":
                vs.append((cx + w, cy + u, cz + v))
            elif eje == "Y":
                vs.append((cx + u, cy + w, cz + v))
            else:
                vs.append((cx + u, cy + v, cz + w))
    for i in range(lados):
        for j in range(anillo):
            a, b = i * anillo + j, ((i + 1) % lados) * anillo + j
            c, d = ((i + 1) % lados) * anillo + (j + 1) % anillo, i * anillo + (j + 1) % anillo
            fs.append((a, b, c, d))
    return pieza(nombre, [], material, mallas=[(vs, fs)])


SILUETAS_TABLERO = []


def garras_gancho(ax_, gc, gz):
    """3 garras curvas iguales a 120°, unidas al anillo, abiertas hacia afuera y con la uña apenas doblada."""
    garras = []
    for ang in (90, 210, 330):
        a = math.radians(ang)
        cy_, sz_ = math.cos(a), math.sin(a)
        pts = [(ax_, 0.45), (ax_ + 0.4, 0.75), (ax_ + 0.85, 1.0), (ax_ + 1.3, 1.05), (ax_ + 1.6, 0.85)]
        pts = [(x, gc + cy_ * r, gz + sz_ * r) for x, r in pts]
        garras += [_barra(pts[i], pts[i + 1], 0.17 if i < 3 else 0.13) for i in range(4)]
    return pieza("Gancho_Garras", garras, "acero")  # (versión vieja, ya no se usa)


def gancho_tano(gx, gz):
    """El gancho como en la hoja de objetos (ref-6): carrete con el cable enrollado atrás, caño con la luz
    celeste, empuñadura de madera con gatillo, anillo en la punta con 3 garras curvas iguales a 120°
    (unidas al anillo) y el cable que cuelga de la empuñadura a la punta."""
    gc = HY - G - 1.4  # eje del gancho, a 1,4 studs del panel
    pared = HY - G - 0.275
    o = []
    o.append(pieza("GanchoPanel_Soportes", [((0.18, pared - (gc + 0.6), 0.18), (gx - 1.3, (pared + gc + 0.6) / 2, gz - 0.74)),
                                            ((0.18, pared - (gc + 0.3), 0.18), (gx + 0.6, (pared + gc + 0.3) / 2, gz - 0.41))], "hierro"))
    o.append(pieza("Gancho", [], "acero", cilindros=[(0.75, 0.12, (gx - 1.95, gc, gz), "X", 18), (0.75, 0.12, (gx - 0.83, gc, gz), "X", 18), (0.4, 1.0, (gx - 1.85, gc, gz), "X", 12),
                                                     (0.32, 2.2, (gx - 0.71, gc, gz), "X", 16), (0.4, 0.28, (gx + 1.49, gc, gz), "X", 16), (0.18, 0.2, (gx + 1.77, gc, gz), "X", 10)]))
    for k in range(6):  # el cable enrollado en el carrete, vuelta por vuelta
        o.append(toro(f"Gancho_Vuelta{k}", (gx - 1.75 + k * 0.17, gc, gz), "X", 0.56, 0.08, "goma", 16, 6))
    o.append(pieza("Gancho_Empunadura", [((0.5, 0.45, 1.2), (gx - 1.4, gc, gz - 1.25), (0, -14, 0))], "roble"))
    o.append(pieza("Gancho_Gatillo", [((0.16, 0.2, 0.42), (gx - 0.95, gc, gz - 0.55)), _barra((gx - 1.15, gc, gz - 0.85), (gx - 0.75, gc, gz - 0.85), 0.07), _barra((gx - 0.75, gc, gz - 0.85), (gx - 0.75, gc, gz - 0.32), 0.07)], "hierro"))
    ax_ = gx + 2.0
    o.append(toro("Gancho_Anillo", (ax_, gc, gz), "X", 0.42, 0.11, "acero"))
    for k, ang in enumerate((90, 210, 330)):
        a = math.radians(ang)
        cy_, sz_ = math.cos(a), math.sin(a)
        pts = [(ax_ - 0.05, 0.4), (ax_ + 0.3, 0.78), (ax_ + 0.75, 1.02), (ax_ + 1.1, 0.95), (ax_ + 1.25, 0.7), (ax_ + 1.12, 0.48)]
        o.append(tubo(f"Gancho_Garra{k}", [(x, gc + cy_ * r, gz + sz_ * r) for x, r in pts], 0.13, "acero", radio_punta=0.06))
    cab = [(gx - 1.55, gc, gz - 1.85), (gx - 0.9, gc, gz - 2.35), (gx + 0.2, gc, gz - 2.45), (gx + 1.2, gc, gz - 2.0), (ax_, gc, gz - 0.55)]
    o.append(tubo("Gancho_CableFino", cab, 0.045, "goma"))
    o.append(pieza("Neon_Gancho", [((1.7, 0.08, 0.16), (gx + 0.4, gc - 0.32, gz + 0.05))], "neon-gancho"))
    return o


def cama_blanda():
    """Almohada blanda (esfera aplastada con arrugas) y frazada arrugada que cubre la cama y cae por el costado."""
    import random

    random.seed(5)
    kx, ky = (11 + HX - G) / 2 + 0.4, HY - G - 2.1
    arriba = ENTREPISO + 1.8  # tapa del colchón
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0)
    alm = bpy.context.active_object
    alm.name = "Cama_Almohada"
    alm.scale = (0.6 * B.STUD, 1.05 * B.STUD, 0.22 * B.STUD)
    alm.location = P.S(kx + 2.5, ky, arriba + 0.2)
    bpy.ops.object.transform_apply(scale=True)
    for v in alm.data.vertices:
        v.co.z += random.uniform(-0.02, 0.02) * B.STUD
    B.aplicar_material(alm, "almohada")
    # frazada: grilla de 18 x 12 sobre el colchón; lo que sobra del costado de adelante (y chico) cae hacia abajo
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=18, y_subdivisions=12, size=1)
    fr = bpy.context.active_object
    fr.name = "Cama_Frazada"
    largo, ancho = 4.6, 4.3
    fr.scale = (largo * B.STUD, ancho * B.STUD, 1)
    fr.location = P.S(kx - 1.0, ky - 0.45, arriba + 0.06)
    bpy.ops.object.transform_apply(scale=True, location=False)
    borde = (ky - 1.62) * B.STUD  # costado de adelante del colchón
    mw = fr.matrix_world
    inv = mw.inverted()
    for v in fr.data.vertices:
        m = mw @ v.co
        ondas = math.sin(m.x / B.STUD * 3.1) * 0.05 + math.sin((m.x + m.y) / B.STUD * 5.3) * 0.03
        m.z += (ondas + random.uniform(0, 0.03)) * B.STUD
        fuera = borde - m.y
        if fuera > 0:  # cae por el costado
            m.z -= fuera
            m.y = borde - 0.08 * B.STUD - 0.06 * B.STUD * abs(math.sin(m.x / B.STUD * 4))
        v.co = inv @ m
    sol = fr.modifiers.new("Grosor", "SOLIDIFY")
    sol.thickness = 0.06 * B.STUD
    bpy.context.view_layer.objects.active = fr
    bpy.ops.object.modifier_apply(modifier="Grosor")
    B.aplicar_material(fr, "frazada")
    return [alm, fr]


ESCRITORIO_VIEJO = ("MesaFabricacion_Monitor", "MesaFabricacion_Pantalla", "MesaFabricacion_Teclado", "Silla", "MesaFabricacion_Lampara",
                    "Neon_MesaFabricacion_Foco", "MesaFabricacion_Detalle")


def escritorio_tano():
    """Escritorio de Tano: compu vieja de tubo con su torre, teclado beige con teclas, mouse con cable, lámpara
    articulada al costado del monitor, taza, papeles con grasa, destornillador y una silla de oficina gastada."""
    dx, dy, tapa = HX - G - 1.6, 9, 3.3  # el escritorio mira al taller (hacia -x)
    o = []
    # monitor de tubo: frente con borde grueso, caja que se achica hacia atrás, pie
    mx, my = dx + 0.35, dy - 0.6
    crt = [((0.5, 2.1, 1.75), (mx - 0.45, my, tapa + 0.25 + 0.875)), ((0.9, 1.7, 1.45), (mx + 0.25, my, tapa + 0.25 + 0.8)), ((0.6, 1.1, 0.95), (mx + 0.95, my, tapa + 0.25 + 0.7)),
           ((0.9, 1.2, 0.25), (mx + 0.1, my, tapa + 0.125))]
    o.append(pieza("Compu_Monitor", crt, "beige-viejo"))
    o.append(pieza("Compu_MarcoPantalla", [((0.06, 1.75, 1.35), (mx - 0.72, my, tapa + 1.13))], "negro"))
    o.append(pieza("Neon_Compu_Pantalla", [((0.05, 1.55, 1.15), (mx - 0.75, my, tapa + 1.13))], "pantalla-crt"))
    o.append(pieza("Neon_Compu_Texto", [((0.02, 0.9 - k * 0.12, 0.06), (mx - 0.78, my - 0.25 + k * 0.06, tapa + 1.55 - k * 0.2)) for k in range(5)], "texto-crt"))
    # torre beige debajo del escritorio, con disquetera y botón
    tx, ty = dx + 0.3, dy - 1.9
    o.append(pieza("Compu_Torre", [((1.8, 0.8, 1.9), (tx, ty, 0.95))], "beige-viejo"))
    o.append(pieza("Compu_TorreFrente", [((0.04, 0.5, 0.08), (tx - 0.92, ty, 1.55)), ((0.04, 0.5, 0.08), (tx - 0.92, ty, 1.35)), ((0.05, 0.12, 0.12), (tx - 0.92, ty, 0.6))], "negro"))
    # teclado beige con teclas marcadas, mouse con cable
    kx, ky = dx - 0.95, dy - 0.6
    o.append(pieza("Compu_Teclado", [((0.75, 2.0, 0.12), (kx, ky, tapa + 0.06))], "beige-viejo"))
    o.append(pieza("Compu_Teclas", [((0.12, 0.13, 0.06), (kx - 0.25 + f * 0.17, ky - 0.85 + c * 0.155, tapa + 0.15)) for f in range(4) for c in range(12)], "beige-oscuro"))
    o.append(pieza("Compu_Mouse", [((0.35, 0.25, 0.12), (kx + 0.1, ky + 1.45, tapa + 0.06))], "beige-viejo"))
    o.append(tubo("Compu_CableMouse", [(kx + 0.28, ky + 1.45, tapa + 0.04), (kx + 0.7, ky + 1.5, tapa + 0.03), (mx + 0.5, my + 0.9, tapa + 0.03), (mx + 0.9, my + 0.5, tapa + 0.3)], 0.025, "negro"))
    # lámpara articulada de metal oscuro, apoyada al costado derecho del monitor; la pantalla alumbra el teclado
    lx, ly = dx + 0.6, dy + 1.4
    o.append(pieza("Compu_LamparaBase", [], "hierro", cilindros=[(0.35, 0.12, (lx, ly, tapa), "Z", 14)]))
    o.append(tubo("Compu_LamparaBrazo", [(lx, ly, tapa + 0.1), (lx + 0.1, ly - 0.1, tapa + 1.4), (lx - 0.5, ly - 0.35, tapa + 2.2), (lx - 1.3, ly - 0.55, tapa + 1.9)], 0.06, "hierro"))
    o.append(pieza("Compu_LamparaPantalla", [], "hierro", cilindros=[(0.32, 0.4, (lx - 1.35, ly - 0.55, tapa + 1.45), "Z", 12, 0.12)]))
    o.append(pieza("Neon_Compu_LamparaFoco", [], "neon-calido", cilindros=[(0.12, 0.08, (lx - 1.35, ly - 0.55, tapa + 1.42), "Z", 8)]))
    # cosas de Tano: taza con asa, papeles con manchas de grasa y un destornillador
    o.append(pieza("Compu_Taza", [], "almohada", cilindros=[(0.18, 0.35, (dx - 1.1, dy + 1.9, tapa), "Z", 12)]))
    o.append(toro("Compu_TazaAsa", (dx - 1.1, dy + 2.12, tapa + 0.18), "X", 0.1, 0.03, "almohada", 10, 4))
    o.append(pieza("Compu_Papeles", [((1.0, 0.75, 0.02), (dx - 0.6, dy + 2.2, tapa + 0.01), (0, 0, 8)), ((0.9, 0.7, 0.02), (dx - 0.4, dy + 2.4, tapa + 0.03), (0, 0, -12))], "papel"))
    o.append(pieza("Compu_PapelesGrasa", [((0.3, 0.25, 0.01), (dx - 0.55, dy + 2.3, tapa + 0.045)), ((0.2, 0.18, 0.01), (dx - 0.2, dy + 2.55, tapa + 0.045))], "aceite"))
    o.append(pieza("Compu_Destornillador", [((0.5, 0.12, 0.12), (dx - 1.5, dy + 1.1, tapa + 0.06), (0, 0, 30))], "mango-amarillo"))
    o.append(pieza("Compu_DestornilladorPunta", [((0.55, 0.04, 0.04), (dx - 1.95, dy + 0.84, tapa + 0.06), (0, 0, 30))], "acero"))
    # manijas de la cajonera (antes iban en MesaFabricacion_Detalle)
    o.append(pieza("MesaFabricacion_Manijas", [((0.2, 0.8, 0.15), (dx - 1.32, dy + 1.8, 2.4 - k * 0.7)) for k in range(3)], "hierro"))
    # silla de oficina vieja: 5 patas con ruedas, columna, asiento acolchado a la altura de la rodilla (1,5) y respaldo bajo y curvo
    sx, sy = dx - 3.1, dy - 0.3
    patas = [_barra((sx, sy, 0.35), (sx + math.cos(math.radians(a)) * 0.95, sy + math.sin(math.radians(a)) * 0.95, 0.3), 0.12) for a in range(18, 378, 72)]
    o.append(pieza("Silla", patas, "negro", cilindros=[(0.12, 0.9, (sx, sy, 0.35), "Z", 10), (0.75, 0.12, (sx, sy, 1.18), "Z", 16)]))
    o.append(pieza("Silla_Ruedas", [], "negro", cilindros=[(0.12, 0.12, (sx + math.cos(math.radians(a)) * 0.95 - 0.06, sy + math.sin(math.radians(a)) * 0.95, 0.12), "X", 8) for a in range(18, 378, 72)]))
    o.append(pieza("Silla_Asiento", [], "tela-silla", cilindros=[(0.85, 0.22, (sx, sy, 1.28), "Z", 18, 0.8)]))
    o.append(pieza("Silla_Respaldo", [((0.18, 0.55, 1.0), (sx - 0.82 + abs(d) * 0.18, sy + d, 2.35), (0, 0, -d * 30)) for d in (-0.5, 0.0, 0.5)], "tela-silla"))
    o.append(pieza("Silla_Soporte", [((0.14, 0.2, 0.75), (sx - 0.75, sy, 1.7))], "negro"))
    return o


def escritorio_tano_reemplazar(listas):
    """Saca el escritorio viejo de las listas y de la escena."""
    for lista in listas:
        for ob in [x for x in lista if x.name in ESCRITORIO_VIEJO]:
            lista.remove(ob)
    for n in ESCRITORIO_VIEJO:
        if n in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[n])


def cama_barrotes():
    """Pie de cama con barrotes de hierro, como en la referencia."""
    kx, ky = (11 + HX - G) / 2 + 0.4, HY - G - 2.1
    x = kx - 3.42
    bar = [((0.14, 3.4, 0.14), (x, ky, ENTREPISO + 2.75))] + [((0.12, 0.12, 1.4), (x, ky + d, ENTREPISO + 2.05)) for d in (-1.4, -0.7, 0, 0.7, 1.4)]
    return [pieza("Cama_Barrotes", bar, "hierro")]


def detalles():
    """Piezas que suman detalle modelado: columnas y correas, herramientas, cajones, motor del auto,
    manchas, etc. Las de muchas partes chicas no se biselan ni se hornean (solo material)."""
    o = []
    # chapa ondulada: nervios verticales cada 1 stud en la cara de adentro (cortados en portón, puerta y ventanas) y zócalo de cemento
    def nervios(nombre, eje, fijo, desde, hasta, huecos, adentro=True):
        cajas, oxido, juntas = [], [], []
        k = desde + 0.5
        while k < hasta:
            tramos = [(1, ALTO)]
            for a, b, z0, z1 in huecos:
                if a <= k <= b:
                    tramos = [(z, w) for z, w in ((1, z0), (z1, ALTO)) if w - z > 0.5]
            for z0, z1 in tramos:
                for lista, w0, w1 in ((cajas, z0, z1),):
                    if w1 - w0 > 0.3:
                        tam = (0.35, 0.15, w1 - w0) if eje == "x" else (0.15, 0.35, w1 - w0)
                        pos = (k, fijo, (w0 + w1) / 2) if eje == "x" else (fijo, k, (w0 + w1) / 2)
                        lista.append((tam, pos))
                for zj in (6.5, 11.5):  # juntas de paneles con un remache por nervio
                    if z0 < zj < z1:
                        f2 = fijo + (0.1 if (fijo < 0) == adentro else -0.1)
                        tam = (1.0, 0.08, 0.3) if eje == "x" else (0.08, 1.0, 0.3)
                        pos = (k, f2, zj) if eje == "x" else (f2, k, zj)
                        juntas.append((tam, pos))
                        f3 = fijo + (0.16 if (fijo < 0) == adentro else -0.16)
                        juntas.append(((0.14, 0.08, 0.14), (k, f3, zj)) if eje == "x" else ((0.08, 0.14, 0.14), (f3, k, zj)))
            k += 1
        o.append(pieza(nombre, cajas, "chapa"))
        o.append(pieza(nombre.replace("Ondas_", "Ondas_Juntas_"), juntas, "hierro"))

    nervios("Ondas_Frente", "x", -HY + G + 0.075, -HX + G, HX - G, [(PORTON_X[0], PORTON_X[1], 0, 10)])
    nervios("Ondas_Fondo", "x", HY - G - 0.075, -HX + G, HX - G, [])
    nervios("Ondas_Oeste", "y", -HX + G + 0.075, -HY + G, HY - G, [(-8, -4, 6, 10), (4, 8, 6, 10)])
    nervios("Ondas_Este", "y", HX - G - 0.075, -HY + G, HY - G, [(PUERTA_Y - 2, PUERTA_Y + 2, 0, 7), (8, 12, 6, 10)])
    nervios("Ondas_Frente_Ext", "x", -HY - 0.075, -HX, HX, [(PORTON_X[0], PORTON_X[1], 0, 10)], adentro=False)
    nervios("Ondas_Fondo_Ext", "x", HY + 0.075, -HX, HX, [], adentro=False)
    nervios("Ondas_Oeste_Ext", "y", -HX - 0.075, -HY, HY, [(-8, -4, 6, 10), (4, 8, 6, 10)], adentro=False)
    nervios("Ondas_Este_Ext", "y", HX + 0.075, -HY, HY, [(PUERTA_Y - 2, PUERTA_Y + 2, 0, 7), (8, 12, 6, 10)], adentro=False)
    # ventanas con marco y vidrio sucio (antes eran huecos que brillaban blancos) y la puerta lateral cerrada
    marcos, vidrios = [], []
    for sx, y in ((-1, -6), (-1, 6), (1, 10)):
        x = sx * (HX - G / 2)
        marcos += [((G + 0.2, 4, 0.3), (x, y, z)) for z in (6.15, 9.85)] + [((G + 0.2, 0.3, 4), (x, y + d, 8)) for d in (-1.85, 1.85)] + [((G + 0.2, 0.15, 3.4), (x, y, 8))]
        vidrios.append(((0.1, 3.4, 3.4), (x, y, 8)))
    o.append(pieza("Ventanas_Marcos", marcos, "hierro"))
    o.append(pieza("Glass_Ventanas", vidrios, "vidrio-sucio"))
    o.append(pieza("Puerta_Lateral", [((0.3, 3.8, 6.9), (HX - G / 2, PUERTA_Y, 3.45))], "verde-locker"))
    o.append(pieza("Puerta_Lateral_Manija", [((0.3, 0.15, 0.7), (HX - G - 0.15, PUERTA_Y - 1.4, 3.4))], "acero"))
    # tablero de trabajos de Tano (pared este): corcho con papeles, fotos, un mapa del puerto y chinches
    tx = HX - G - 0.4
    o.append(pieza("TableroTrabajos", [((0.15, 4.4, 3.2), (tx + 0.1, 0.8, 5.6))], "corcho"))
    o.append(pieza("TableroTrabajos_Mapa", [((0.06, 1.8, 1.4), (tx - 0.02, 1.8, 6.1))], "mapa"))
    o.append(pieza("TableroTrabajos_Papeles", [((0.05, 0.7, 0.9), (tx - 0.02, y, z)) for y, z in ((-0.6, 6.3), (0.2, 6.5), (-0.4, 5.0), (0.5, 5.1), (2.0, 4.7))], "papel"))
    o.append(pieza("TableroTrabajos_Notas", [((0.05, 0.5, 0.5), (tx - 0.03, y, z)) for y, z in ((1.0, 4.6), (2.6, 5.0), (-1.0, 4.6))], "papel-amarillo"))
    o.append(pieza("TableroTrabajos_Chinches", [((0.08, 0.12, 0.12), (tx - 0.07, y, z)) for y, z in ((-0.6, 6.7), (0.2, 6.9), (1.8, 6.75), (-0.4, 5.4), (0.5, 5.5), (1.0, 4.8), (2.6, 5.2))], "borne-rojo"))
    zoc = [((PORTON_X[0] + HX - G, 0.3, 1), ((PORTON_X[0] - HX + G) / 2, -HY + G + 0.15, 0.5)), ((HX - G - PORTON_X[1], 0.3, 1), ((PORTON_X[1] + HX - G) / 2, -HY + G + 0.15, 0.5))]
    zoc += [((ANCHO - 2 * G, 0.3, 1), (0, HY - G - 0.15, 0.5)), ((0.3, FONDO - 2 * G, 1), (-HX + G + 0.15, 0, 0.5))]
    zoc += [((0.3, PUERTA_Y - 2 + HY - G, 1), (HX - G - 0.15, (PUERTA_Y - 2 - HY + G) / 2, 0.5)), ((0.3, HY - G - PUERTA_Y - 2, 1), (HX - G - 0.15, (PUERTA_Y + 2 + HY - G) / 2, 0.5))]
    o.append(pieza("Zocalo", zoc, "concreto"))
    o.append(pieza("Porton_Guias", [((0.5, 0.6, 10), (x, -HY + G + 0.3, 5)) for x in (PORTON_X[0] + 0.25, PORTON_X[1] - 0.25)], "hierro"))
    # tablero: herramientas distintas y no tan ordenadas, con su silueta pintada; una falta (Tano la está usando)
    bx, ty = 2, HY - G - 0.4
    her, mangos, mangos_az, silu = [], [], [], []
    for k, largo in enumerate((1.0, 1.25, 1.5, 1.7, 2.0)):  # llaves combinadas de menor a mayor; la 3.ª torcida
        x = bx - 6.2 + k * 0.6
        giro = (0, 8, 0) if k == 2 else (0, 0, 0)
        her += [((0.18, 0.12, largo), (x, ty, 9.0 + largo / 2), giro), ((0.14, 0.12, 0.35), (x - 0.15, ty, 9.15 + largo)), ((0.14, 0.12, 0.35), (x + 0.15, ty, 9.15 + largo))]
        silu.append(((0.4, 0.04, largo + 0.5), (x, ty + 0.12, 9.1 + largo / 2)))
    her += [((0.3, 0.12, 2.2), (bx - 2.6, ty, 8.6), (0, -6, 0)), ((0.7, 0.12, 0.5), (bx - 2.75, ty, 9.8)), ((0.25, 0.14, 0.3), (bx - 2.55, ty, 9.45))]  # llave inglesa
    silu.append(((1.0, 0.04, 2.8), (bx - 2.65, ty + 0.12, 8.8)))
    for k, (largo, col) in enumerate(((0.9, mangos), (1.1, mangos_az), (0.8, mangos), (1.2, mangos_az))):  # destornilladores
        x = bx - 1.2 + k * 0.45
        her.append(((0.08, 0.08, largo), (x, ty, 7.2 - largo / 2)))
        col.append(((0.22, 0.2, 0.7), (x, ty, 7.55)))
        silu.append(((0.34, 0.04, largo + 0.9), (x, ty + 0.12, 7.45 - largo / 2)))
    mangos.append(((0.26, 0.16, 1.9), (bx + 1.4, ty, 7.0)))  # martillo grande
    her.append(((1.0, 0.24, 0.45), (bx + 1.4, ty - 0.02, 8.1)))
    mangos.append(((0.18, 0.14, 1.1), (bx + 2.4, ty, 7.2)))  # martillo chico
    her.append(((0.6, 0.2, 0.3), (bx + 2.4, ty - 0.02, 7.85)))
    silu += [((1.3, 0.04, 2.6), (bx + 1.4, ty + 0.12, 7.4)), ((0.9, 0.04, 1.6), (bx + 2.4, ty + 0.12, 7.4))]
    silu.append(((0.5, 0.04, 2.4), (bx + 3.4, ty + 0.12, 7.6)))  # hueco: la llave grande que Tano tiene en la mano
    her += [((0.12, 0.12, 0.9), (bx + 4.2 - 0.09, ty, 7.2), (0, 6, 0)), ((0.12, 0.12, 0.9), (bx + 4.2 + 0.09, ty, 7.2), (0, -6, 0)), ((0.3, 0.12, 0.35), (bx + 4.2, ty, 7.8))]  # pinza
    silu.append(((0.6, 0.04, 1.6), (bx + 4.2, ty + 0.12, 7.4)))
    her.append(((3.0, 0.06, 0.8), (bx + 4.4, ty, 9.9)))  # serrucho
    mangos.append(((0.8, 0.14, 0.7), (bx + 6.1, ty, 9.9)))
    silu.append(((4.0, 0.04, 1.2), (bx + 4.7, ty + 0.12, 9.9)))
    o.append(pieza("Tablero_Herramientas", her, "acero"))
    SILUETAS_TABLERO[:] = [(c[0], c[2], s[0], s[2]) for s, c in silu]  # (x, z, ancho, alto) pintados en la textura del tablero
    o.append(pieza("Tablero_MangosAzules", mangos_az, "mango-azul"))
    # el gancho de Tano: la estrella de la Beta, solo en su propio panel a la izquierda del tablero, el doble de grande
    gx, gz, gy = -9.5, 8.0, HY - G - 0.45
    o.append(pieza("GanchoPanel", [((5.2, 0.25, 5.0), (gx, HY - G - 0.15, gz))], "tablero-oscuro"))
    o += gancho_tano(gx, gz)
    o.append(pieza("Tablero_Mangos", mangos, "mango-amarillo"))
    for k in range(4):  # manguera amarilla enrollada, colgada de un gancho del tablero
        o.append(toro(f"Tablero_Manguera{k}", (bx - 5.5 + k * 0.06, ty - 0.2 - k * 0.09, 7.0 - k * 0.04), "Y", 0.75, 0.09, "manguera-amarilla", 16, 6))
    o.append(pieza("Tablero_MangueraGancho", [((0.12, 0.5, 0.12), (bx - 5.5, ty - 0.2, 7.78))], "hierro"))
    # banco: frentes de cajones con manijas, mango de la morsa y trapo rojo
    by = HY - G - 1.6
    caj = [((3.4, 0.15, 1.1), (bx - 5.4 + k * 3.6, by - 1.62, 2.2 - j * 1.3)) for k in range(4) for j in range(2)]
    caj += [((1.0, 0.25, 0.18), (bx - 5.4 + k * 3.6, by - 1.75, 2.3 - j * 1.3)) for k in range(4) for j in range(2)]
    o.append(pieza("Banco_Cajones", caj, "roble"))
    pass  # el trapo rojo se hace con simulación de tela (ver trapos()) 
    # pila de neumáticos al lado del portón (como en la ref-1)
    o.append(pieza("Neumaticos", [], "goma", cilindros=[(1.3, 0.9, (-17.7, -12.3, z * 0.9), "Z", 14) for z in range(4)]))
    # carro rojo: frentes de cajones con manijas
    o.append(pieza("CarroHerramientas_Cajones", [((2.8, 0.08, 0.75), (9, -9.96, 1.05 + k * 0.85)) for k in range(4)], "rojo-herramienta"))
    o.append(pieza("CarroHerramientas_Manijas", [((1.4, 0.15, 0.12), (9, -9.84, 1.3 + k * 0.85)) for k in range(4)], "acero"))
    # locker: rejillas y manija
    lx, ly = HX - G - 1.5, -HY + G + 1.2
    lok = [((2.0, 0.1, 0.12), (lx, ly + 1.15, 6.0 - k * 0.3)) for k in range(4)] + [((0.15, 0.2, 0.9), (lx - 1.0, ly + 1.2, 3.8))]
    o.append(pieza("Locker_Detalle", lok, "hierro"))
    # compresor: motor arriba y manómetro
    o.append(tubo("Compresor_Manguera", [(12.3, -12.6, 1.4), (11.9, -11.8, 0.9), (12.4, -10.4, 0.16), (13.6, -9.6, 0.16)], 0.12, "manguera-amarilla"))
    o.append(toro("Compresor_MangueraRollo", (13.6, -9.0, 0.14), "Z", 0.7, 0.12, "manguera-amarilla", 18, 6))
    o.append(pieza("Compresor_Detalle", [((0.15, 1.4, 0.15), (15.9, -13.5, 2.6))], "hierro", cilindros=[(0.3, 0.15, (14.8, -12.4, 1.7), "Y", 10)]))  # manija y manómetro
    # tambores: aros
    o.append(pieza("Tambores_Aros", [], "hierro", cilindros=[(1.25, 0.15, (x, y, z), "Z", 14) for x, y in ((-17.6, 12.4), (-15, 13)) for z in (1.1, 2.4, 3.45)]))
    # escritorio: manijas de la cajonera, mouse, taza y papeles
    dx, dy = HX - G - 1.6, 9
    det = [((0.2, 0.8, 0.15), (dx - 1.32, dy + 1.8, 2.4 - k * 0.7)) for k in range(3)] + [((0.3, 0.45, 0.12), (dx - 0.6, dy - 1.6, 3.36)), ((1.6, 1.1, 0.04), (dx - 0.2, dy + 2.0, 3.32))]
    # lámpara articulada sobre el escritorio de fabricar: base, dos brazos y pantalla con foco
    o.append(pieza("MesaFabricacion_Lampara", [((0.6, 0.6, 0.12), (dx + 0.9, dy + 0.8, 3.36)), _barra((dx + 0.9, dy + 0.8, 3.4), (dx + 1.0, dy + 0.6, 5.2), 0.1), _barra((dx + 1.0, dy + 0.6, 5.2), (dx - 0.2, dy + 0.4, 5.8), 0.1)],
                   "rojo-herramienta", cilindros=[(0.45, 0.5, (dx - 0.3, dy + 0.4, 5.3), "Z", 12, 0.2)]))
    o.append(pieza("Neon_MesaFabricacion_Foco", [((0.3, 0.3, 0.1), (dx - 0.3, dy + 0.4, 5.3))], "neon-calido"))
    o.append(pieza("MesaFabricacion_Detalle", det, "hierro", cilindros=[(0.25, 0.5, (dx - 0.4, dy - 2.4, 3.3), "Z", 10)]))
    # cama: frazada doblada al pie
    kx, ky = (11 + HX - G) / 2 + 0.4, HY - G - 2.1
    o.append(pieza("Calendario", [((0.06, 1.6, 2.2), (-HX + G + 0.25, 11, 7.5))], "calendario"))
    o.append(pieza("Calendario_Cabecera", [((0.07, 1.6, 0.5), (-HX + G + 0.27, 11, 8.85))], "cartel-repuestos"))
    o.append(pieza("Reloj", [], "reloj", cilindros=[(0.75, 0.12, (-14, HY - G - 0.3, 12), "Y", 18)]))
    o.append(pieza("Reloj_Agujas", [((0.06, 0.05, 0.55), (-14, HY - G - 0.45, 12.25)), ((0.4, 0.05, 0.06), (-13.8, HY - G - 0.45, 12))], "negro", cilindros=[(0.85, 0.1, (-14, HY - G - 0.25, 12), "Y", 18)]))
    cartel = [((4.0, 0.06, 2.4), (3, -HY + G + 0.25, 8))]  # cartel de repuestos inventado: franjas y un dibujo de bujía, sin letras
    o.append(pieza("CartelRepuestos", cartel, "cartel-repuestos"))
    o.append(pieza("CartelRepuestos_Dibujo", [((3.4, 0.07, 0.25), (3, -HY + G + 0.28, 8.9)), ((3.4, 0.07, 0.25), (3, -HY + G + 0.28, 7.1)), ((0.3, 0.07, 1.2), (2.2, -HY + G + 0.28, 8)), ((0.6, 0.07, 0.4), (2.2, -HY + G + 0.28, 7.5))], "reloj"))
    o.append(pieza("Neumaticos_Fondo", [], "goma", cilindros=[(1.3, 0.9, (-17.8, 9.3, z * 0.9), "Z", 14) for z in range(5)]))
    o.append(pieza("Bidones", [((1.2, 0.8, 1.6), (-12.8, 14.1, 0.8)), ((1.2, 0.8, 1.6), (-11.4, 14.2, 0.8)), ((0.3, 0.2, 0.3), (-12.8, 14.1, 1.75)), ((0.3, 0.2, 0.3), (-11.4, 14.2, 1.75))], "bidon"))
    o.append(pieza("Baranda_Mameluco", [((1.6, 0.25, 2.2), (14.5, 3.85, ENTREPISO + 1.7)), ((0.45, 0.25, 1.4), (13.95, 3.85, ENTREPISO + 0.0)), ((0.45, 0.25, 1.4), (15.05, 3.85, ENTREPISO + 0.0))], "mameluco-tano"))

    cab = []
    for y, x0, x1, caida in ((4, -16, -6, 1.2), (12, 2, 10, 0.9), (-12, 4, 14, 1.0)):
        pts = [(x0 + (x1 - x0) * s / 6, y + 0.35, ALTO - 0.35 - caida * 4 * (s / 6) * (1 - s / 6)) for s in range(7)]
        cab += [_barra(pts[s], pts[s + 1], 0.1) for s in range(6)]
    o.append(pieza("Cables", cab, "goma"))
    # piso: manchas, charco, grietas y huellas van pintados en la textura (ver pintar_taller)
    o.append(pieza("Piso_RejillaBarras", [((0.15, 1.3, 0.1), (-3.2 + k * 0.4, -9, 0.11)) for k in range(7)], "hierro"))
    return o


def pintar_taller(solo=None):
    """Todo lo plano va en la textura: piso, chapa, banco, tablero de herramientas y panel del gancho."""
    import numpy as np
    import random

    import detalle as D
    import pintura as T

    carpeta = os.path.join(D.TEXTURAS, ARCHIVO)
    random.seed(11)

    # piso: manchas marrón oscuro con borde suave y brillo, grietas ramificadas, 2 huellas de neumático, suciedad
    # en las esquinas y junto a las paredes, y un charco con reflejo cerca del portón
    manchas = ((-9, -6, 1.8), (-12, 2, 1.3), (5, -2, 0.9), (-4, 8, 1.1), (12, -8, 0.8), (-2, -11, 0.7))
    grietas = []
    for x, y, a0 in ((-14, -2, 20), (2, 4, 110), (8, -12, 60), (-2, 12, 150), (14, 4, 200)):
        pts, a = [(x, y)], math.radians(a0)
        for s in range(9):
            a += random.uniform(-0.5, 0.5)
            pts.append((pts[-1][0] + math.cos(a) * 0.7, pts[-1][1] + math.sin(a) * 0.7))
            if s in (3, 6):  # rama
                b, rama = a + random.choice((-1, 1)) * 0.9, [pts[-1]]
                for _ in range(3):
                    rama.append((rama[-1][0] + math.cos(b) * 0.5, rama[-1][1] + math.sin(b) * 0.5))
                grietas.append(rama)
        grietas.append(pts)
    huellas = []
    for x0 in (-12.6, -7.4):
        huellas.append([(x0, -6.2), (x0 + 0.4, -9), (x0 + 1.2, -12), (x0 + 2.2, -16)])

    def piso(p, n, base):
        x, y = p[:, 0], p[:, 1]
        arriba = (n[:, 2] > 0.5).astype(float)
        c = base.copy()
        borde = np.clip(1 - np.minimum(HX - np.abs(x), HY - np.abs(y)) / 3.5, 0, 1) ** 1.5
        c = T.mezclar(c, T.hexa("1f1a16"), arriba * borde * (0.35 + 0.35 * T.fbm(x, y, 1.5)))
        c = T.mezclar(c, T.hexa("4a453f"), arriba * 0.18 * (T.fbm(x, y, 3.0, 9) > 0.62))
        for cx, cy, r in manchas:
            d = np.hypot(x - cx, (y - cy) / 0.8) / (r * (0.75 + 0.5 * T.fbm(x, y, 0.7, cx)))
            c = T.mezclar(c, T.hexa("2a1f17"), arriba * np.clip((1.15 - d) / 0.4, 0, 1) * 0.9)
        for g in grietas:
            d = T.dist_polilinea(x, y, g)
            c = T.mezclar(c, T.hexa("3a342e"), arriba * (np.clip((0.035 - d) / 0.025, 0, 1) * 0.55 + np.clip((0.12 - d) / 0.08, 0, 1) * 0.12))
        for h in huellas:
            d = T.dist_polilinea(x, y, h)
            banda = np.clip((0.4 - d) / 0.12, 0, 1) * (0.55 + 0.45 * (np.sin(y * 14) > 0)) * np.clip((y + 16.5) / 2, 0, 1)
            c = T.mezclar(c, T.hexa("2b2622"), arriba * banda * 0.55)
        dc = np.hypot((x + 8) / 1.9, (y + 12.6) / 1.2) / (0.8 + 0.35 * T.fbm(x, y, 0.8, 4))
        c = T.mezclar(c, T.hexa("1b2026"), arriba * np.clip((1.05 - dc) / 0.25, 0, 1) * 0.85)
        return c

    def piso_rug(p, n, base):
        x, y = p[:, 0], p[:, 1]
        r = base.copy()
        for cx, cy, rad in manchas:
            d = np.hypot(x - cx, (y - cy) / 0.8) / (rad * (0.75 + 0.5 * T.fbm(x, y, 0.7, cx)))
            r = np.where(d < 1.0, np.minimum(r, 0.3), r)
        dc = np.hypot((x + 8) / 1.9, (y + 12.6) / 1.2) / (0.8 + 0.35 * T.fbm(x, y, 0.8, 4))
        return np.where(dc < 1.0, 0.05, r)

    # chapa: óxido corrido hacia abajo (fuerte en la franja de abajo), manchas de agua y chorreadas bajo las juntas,
    # y 2 o 3 paneles con otro tono
    def chapa(p, n, base):
        x, y, z = p[:, 0], p[:, 1], p[:, 2]
        u = np.where(np.abs(n[:, 1]) > np.abs(n[:, 0]), x, y)
        c = base.copy()
        panel = np.floor(u / 4)
        tono = T._hash(panel, np.sign(n[:, 0] + n[:, 1] * 2), 3.0)
        c = T.mezclar(c, T.hexa("5d6670"), (tono > 0.82) * 0.45)
        c = T.mezclar(c, T.hexa("454a44"), ((tono > 0.65) & (tono < 0.78)) * 0.4)
        oxido = np.clip((3.4 - z) / 2.6, 0, 1) ** 1.3 * (0.55 + 0.45 * T.fbm(u, z, 0.8, 2))
        c = T.mezclar(c, T.hexa("7a4a2c"), oxido * 0.85)
        for j in (6.5, 11.5):
            debajo = (z < j) * np.exp(-(j - z) / 0.9)
            c = T.mezclar(c, T.hexa("2f3236"), debajo * 0.3)
            chorro = (T._hash(np.floor(u * 1.3), j) > 0.72) * (z < j) * np.exp(-(j - z) / 2.6)
            c = T.mezclar(c, T.hexa("8a4f2a"), chorro * 0.55)
        return c

    # banco: quemaduras, rayones y aceite en la madera (arriba)
    quemaduras = [(-3.0, 13.4, 0.35), (4.5, 13.0, 0.25), (6.8, 13.6, 0.3)]
    rayones = [((-5 + k * 1.4, 12.6 + (k % 3) * 0.4), (-4.2 + k * 1.4, 13.2 + (k % 2) * 0.5)) for k in range(9)]

    def banco(p, n, base):
        x, y = p[:, 0], p[:, 1]
        arriba = (n[:, 2] > 0.5).astype(float)
        c = base.copy()
        for cx, cy, r in quemaduras:
            d = np.hypot(x - cx, y - cy) / r
            c = T.mezclar(c, T.hexa("1a1410"), arriba * np.clip((1.0 - d) / 0.3, 0, 1) * 0.85)
            c = T.mezclar(c, T.hexa("3a2416"), arriba * np.clip((1.4 - d) / 0.3, 0, 1) * 0.35)
        for a, b in rayones:
            d = T.dist_polilinea(x, y, [a, b])
            c = T.mezclar(c, T.hexa("c9a27a"), arriba * np.clip((0.03 - d) / 0.02, 0, 1) * 0.6)
        d = np.hypot(x - 0.5, (y - 13.0) / 0.7) / (0.9 * (0.75 + 0.5 * T.fbm(x, y, 0.5, 6)))
        return T.mezclar(c, T.hexa("2a1f17"), arriba * np.clip((1.1 - d) / 0.3, 0, 1) * 0.7)

    # tablero de herramientas: agujeritos y contorno fino pintado de cada herramienta
    def tablero(p, n, base):
        x, z = p[:, 0], p[:, 2]
        c = base.copy()
        agujero = (np.hypot((x * 2) % 1 - 0.5, (z * 2) % 1 - 0.5) < 0.12).astype(float)
        c = T.mezclar(c, T.hexa("15161a"), agujero * 0.8)
        for sx, sz, w, h in SILUETAS_TABLERO:
            dx, dz = np.abs(x - sx) - w / 2, np.abs(z - sz) - h / 2
            borde = np.abs(np.maximum(dx, dz))
            c = T.mezclar(c, T.hexa("e8d38a"), (borde < 0.05).astype(float))
        return c

    # panel del gancho: silueta del gancho como contorno pintado
    gx, gz = -9.5, 8.0

    def panel(p, n, base):
        x, z = p[:, 0], p[:, 2]
        c = base.copy()
        cuerpo = np.minimum(T.dist_polilinea(x, z, [(gx - 1.9, gz), (gx - 0.9, gz)]) - 0.95, T.dist_polilinea(x, z, [(gx - 0.9, gz), (gx + 3.3, gz)]) - 0.6)
        mango = T.dist_polilinea(x, z, [(gx - 1.35, gz - 0.6), (gx - 1.55, gz - 1.9)]) - 0.45
        sdf = np.minimum(cuerpo, mango)
        return T.mezclar(c, T.hexa("e8d38a"), (np.abs(sdf) < 0.07).astype(float))

    hechos = 0
    for o in list(bpy.data.objects):
        if o.type != "MESH" or (solo and o.name not in solo):
            continue
        if o.name.startswith("Piso_") and o.name[5:].isdigit():
            hechos += T.pintar(o, piso, piso_rug) > 0
        elif o.name.startswith("Pared_"):
            hechos += T.pintar(o, chapa) > 0
        elif o.name.startswith("Ondas_"):
            T.textura_lisa(o, 256, "4a5560", carpeta, rugosidad=0.55, metal=0.5)
            hechos += T.pintar(o, chapa) > 0
        elif o.name == "Banco":
            hechos += T.pintar(o, banco) > 0
        elif o.name == "Tablero":
            T.textura_lisa(o, 512, "3a3d42", carpeta, rugosidad=0.7, metal=0.3)
            hechos += T.pintar(o, tablero) > 0
        elif o.name == "GanchoPanel":
            T.textura_lisa(o, 512, "2e2a26", carpeta, rugosidad=0.85)
            hechos += T.pintar(o, panel) > 0
    return hechos


def detalle():
    import detalle as D
    import random

    for k, v in RECETAS_TALLER.items():
        D.RECETAS[k] = v
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    for k, v in MATS.items():
        B.MATERIALES[k] = v
    B.MATERIALES.setdefault("porton-verde", {"hex": "2f5d5a", "rugosidad": 0.6, "metal": 0.5})
    B.MATERIALES.setdefault("hierro", {"hex": "3a3d42", "rugosidad": 0.6, "metal": 0.7})
    est, mue, det = estructura(), muebles() + auto(), detalles()
    det += trapos() + cama_barrotes() + cama_blanda()
    escritorio_tano_reemplazar((mue, det))
    det += escritorio_tano()
    todo = est + mue + det
    cruces, flotan = revisar(todo)
    print("CHEQUEO", cruces, flotan, flush=True)
    if "solo-chequeo" in sys.argv:
        return {"cruces": cruces, "flotan": flotan}
    # sin bisel ni horneado: piezas de más de 30 studs, de muchas partes chicas o finitas, y lo que brilla
    largas = ("Techo", "Cerchas", "Hastial", "Ondas", "Zocalo", "Porton_Rollo", "Porton_Dintel", "Porton_Cortina", "Auto_", "Cables")
    chicas = ("Tablero_Herramientas", "Banco_", "CarroHerramientas_Cajones", "Locker_Detalle", "Piso_Manchas", "Piso_Grietas", "Piso_Rejilla", "Piso_Chapa",
              "Escalera", "Entrepiso_Baranda", "Elevador_Tacos", "Tambores_Aros", "MesaFabricacion_", "CarroHerramientas_", "Banco_Cajones", "Banco_Carburador", "Banco_LatasAro", "Banco_Latas_Etiqueta", "Banco_Trapo",
              "Compresor_Detalle", "Neumaticos", "Lampara", "Radio", "Silla", "Cama", "Porton_Guias", "Tablero", "Piso_Charco", "Ventana_Marco", "Cajas",
              "Ventanas_Marcos", "Puerta_Lateral_Manija", "TableroTrabajos_", "GanchoPanel_Soportes", "Gancho", "Compresor_Manguera", "Tablero_Manguera", "GanchoPanel_Silueta", "Calendario", "Reloj",
              "CartelRepuestos_Dibujo", "GanchoPanel", "Neumaticos_Fondo", "Bidones", "Baranda_Mameluco", "Piso_MarcasNeumatico", "Auto_")
    hornear = [o for o in todo if not o.name.startswith(("Neon_", "Auto_", "Glass_")) and o.name != "MesaFabricacion_Pantalla"]
    sin = tuple(o.name for o in hornear if o.name.startswith(largas + chicas))
    def lado(n):
        if n.startswith("Piso_") and n[5:].isdigit():
            return 1024
        if n.startswith("Banco_"):
            return 256
        return 512 if n.startswith(("Pared", "Elevador", "Auto", "Banco", "Entrepiso", "MesaFabricacion")) else 256
    lados = {o.name: lado(o.name) for o in hornear}
    presupuesto = {o.name: (500 if o.name.startswith(("Pared", "Piso_")) else 4000, [o.name]) for o in hornear}
    print("HORNEAR", len(hornear) - len(sin), "piezas; sin hornear", len(sin), flush=True)
    D.terminar(hornear, presupuesto, ARCHIVO, lados=lados, sin_bisel=sin, sin_hornear=sin)
    print("PINTADAS", pintar_taller(), flush=True)
    man = maniqui()
    P.luz_puerto()
    # 1) dos lámparas cálidas con cono marcado (spots + niebla adentro), luz fría azul entrando por el portón y lluvia afuera
    for nombre, (x, y, z), energia in (("Luz0", (-8, -4, 13.9), 2600), ("Luz1", (10, -4, 13.9), 2600)):
        d = bpy.data.lights.new(nombre, "SPOT")
        d.color = B.color("f2a23a")[:3]
        d.energy = energia
        d.spot_size = math.radians(80)
        d.spot_blend = 0.85
        luz = bpy.data.objects.new(nombre, d)
        bpy.context.scene.collection.objects.link(luz)
        luz.location = P.S(x, y, z)
    d = bpy.data.lights.new("LuzEscritorio", "POINT")
    d.color = B.color("ffc27a")[:3]
    d.energy = 150
    luz = bpy.data.objects.new("LuzEscritorio", d)
    bpy.context.scene.collection.objects.link(luz)
    luz.location = P.S(16, 9, ENTREPISO - 1.2)
    d = bpy.data.lights.new("LuzCama", "POINT")  # lamparita sobre la cama
    d.color = B.color("ffc27a")[:3]
    d.energy = 260
    luz = bpy.data.objects.new("LuzCama", d)
    bpy.context.scene.collection.objects.link(luz)
    luz.location = P.S(15, 12, ENTREPISO + 4.5)
    for nombre, desde, hacia, energia, color in (("LuzBanco", (2, 11.5, 12.5), (2, 14, 3.5), 900, "ffc27a"), ("LuzGancho", (-9.5, 9, 12.5), (-9.5, 15, 8), 700, "fff0d8"),
                                                 ("LuzFabricar", (16.85, 9.85, 4.6), (16.65, 9.4, 3.3), 220, "ffd9a0")):
        d = bpy.data.lights.new(nombre, "SPOT")
        d.color = B.color(color)[:3]
        d.energy = energia
        d.spot_size = math.radians(55)
        d.spot_blend = 0.4
        luz = bpy.data.objects.new(nombre, d)
        bpy.context.scene.collection.objects.link(luz)
        a, b = P.S(*desde), P.S(*hacia)
        luz.matrix_world = Matrix.Translation(a) @ (b - a).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    fondo = bpy.data.worlds["Noche"].node_tree.nodes["Background"]
    fondo.inputs["Color"].default_value = B.color("39444a")
    fondo.inputs["Strength"].default_value = 2.5
    bpy.context.scene.eevee.taa_render_samples = 128
    d = bpy.data.lights.new("LuzCalle", "AREA")
    d.color = B.color("4fb3f2")[:3]
    d.energy = 2500
    d.size = 12 * B.STUD
    fria = bpy.data.objects.new("LuzCalle", d)
    bpy.context.scene.collection.objects.link(fria)
    a, b = P.S(-10, -26, 12), P.S(-6, -6, 0)
    fria.matrix_world = Matrix.Translation(a) @ (b - a).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    random.seed(3)
    gotas = [(random.uniform(-30, 30), random.uniform(-26, 14)) for _ in range(500)]
    gotas = [(x, y) for x, y in gotas if abs(x) > HX + 1.5 or y < -HY - 1.0][:220]
    pieza("Lluvia", [((0.025, 0.025, 1.4), (x, y, random.uniform(0, 22)), (8, 0, 0)) for x, y in gotas], "lluvia")
    nb = bpy.data.objects.get("Niebla")
    if nb:
        nb.data.materials[0].node_tree.nodes["Principled Volume"].inputs["Density"].default_value = 0.01
    marcadores()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    sin_techo = [o for o in est if not o.name.startswith(("Techo", "Hastial", "Cerchas"))] + mue + det + [man]
    lluvia_afuera(bpy.data.objects["Lluvia"])
    rs = [P.render_orto(ARCHIVO + "_detalle_planta", [o for o in sin_techo if not o.name.startswith(("Lampara", "Neon_", "Glass_"))], giro=0, altura=89, niebla=False, solo=True)]
    return {"cruces": cruces, "flotan": flotan, "triangulos": B.contar_triangulos(todo), "renders": rs}


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in pasos:
        print("RESULTADO", boceto())
    if "detalle" in pasos:
        print("RESULTADO", detalle())
