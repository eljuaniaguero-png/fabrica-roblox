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
    "vidrio-sucio": {"hex": "55625e", "rugosidad": 0.25, "metal": 0.1},
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
    "charco": {"hex": "1f2a33", "rugosidad": 0.02, "metal": 0.3},
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
    o.append(pieza("Banco_Morsa", [((1.2, 1.4, 1.0), (bx - 6, by - 0.6, 4.05))], "acero"))
    # pieza a medio desarmar (un alternador abierto con sus partes alrededor) y latas de pintura y aceite
    o.append(pieza("Banco_Pieza", [((1.2, 1.0, 0.7), (bx + 1.4, by - 0.2, 3.9)), ((0.5, 0.3, 0.12), (bx + 0.2, by - 0.6, 3.61)), ((0.3, 0.3, 0.3), (bx + 2.6, by - 0.7, 3.7))], "acero",
                   cilindros=[(0.45, 0.8, (bx + 2.0, by + 0.4, 3.55), "Z", 12), (0.2, 0.15, (bx + 0.8, by - 0.9, 3.55), "Z", 8), (0.15, 0.1, (bx + 3.0, by + 0.2, 3.55), "Z", 8)]))
    o.append(pieza("Banco_Latas", [], "rojo-herramienta", cilindros=[(0.35, 0.8, (bx + x, by + 0.6, 3.55), "Z", 12) for x in (4.0, 4.8)] + [(0.3, 0.6, (bx + 4.4, by - 0.2, 3.55), "Z", 12)]))
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
    o.append(pieza("Cama_Almohada", [((1.2, 2.2, 0.4), (kx + 2.4, ky, ENTREPISO + 2.0))], "maniqui"))
    o.append(pieza("Cama_Frazada", [((4.2, 3.3, 0.2), (kx - 1.1, ky, ENTREPISO + 1.9))], "porton-verde"))
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
    """Vano del motor que se ve con el capó abierto: fondo oscuro, block con tapa de válvulas con nervios,
    filtro de aire redondo, batería, radiador adelante y el disco de freno de la rueda sacada."""
    piezas = [pieza("Auto_MotorFondo", [((5.8, 3.2, 0.2), (ex, ey - 5.0, z + 1.2))], "goma")]
    blk = [((3.0, 1.8, 1.1), (ex - 0.4, ey - 4.8, z + 1.85)), ((2.6, 1.2, 0.3), (ex - 0.4, ey - 4.8, z + 2.55))]
    blk += [((2.4, 0.12, 0.12), (ex - 0.4, ey - 4.8 + d, z + 2.75)) for d in (-0.4, -0.13, 0.13, 0.4)]  # nervios de la tapa
    blk += [((5.4, 0.25, 1.4), (ex, ey - 6.45, z + 1.9))]  # radiador
    piezas.append(pieza("Auto_Motor", blk[:1] + blk[-1:], "hierro", cilindros=[(0.7, 0.4, (ex - 3.4 + 0.5, ey - 4.2, z + 1.25), "X", 12)]))
    piezas.append(pieza("Auto_TapaValvulas", blk[1:-1], "rojo-herramienta"))
    piezas.append(pieza("Auto_Filtro", [], "filtro", cilindros=[(0.85, 0.35, (ex + 1.6, ey - 4.4, z + 2.4), "Z", 18), (0.25, 0.25, (ex + 1.6, ey - 4.4, z + 2.75), "Z", 10)]))
    piezas.append(pieza("Auto_FiltroBase", [], "negro", cilindros=[(0.7, 0.3, (ex + 1.6, ey - 4.4, z + 2.1), "Z", 14)]))
    piezas.append(pieza("Auto_Bateria", [((1.2, 0.9, 0.9), (ex + 2.0, ey - 5.75, z + 1.75))], "bateria"))
    piezas.append(pieza("Auto_Borne_Rojo", [], "borne-rojo", cilindros=[(0.14, 0.22, (ex + 1.65, ey - 5.75, z + 2.2), "Z", 8)]))
    piezas.append(pieza("Auto_Borne_Negro", [], "negro", cilindros=[(0.14, 0.22, (ex + 2.35, ey - 5.75, z + 2.2), "Z", 8)]))
    piezas.append(pieza("Auto_Mangueras", [_barra((ex + 0.6, ey - 4.8, z + 2.2), (ex + 1.4, ey - 6.25, z + 2.3), 0.2), _barra((ex - 1.9, ey - 4.8, z + 1.7), (ex - 2.2, ey - 6.25, z + 2.2), 0.2)], "manguera-naranja"))
    return piezas


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
    h.append(capo)
    h += motor(ex, ey, z)
    h.append(pieza("Neon_Auto_Faros", [((1.2, 0.1, 0.5), (ex + sx * 2.4, ey - 6.95, z + 2.0)) for sx in (-1, 1)], "neon-calido"))
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
              ("Columnas", "Correas"), ("GanchoPanel", "Gancho"), ("GanchoPanel", "GanchoPanel_Soportes"), ("Gancho", "GanchoPanel_Soportes"), ("TableroTrabajos", "TableroTrabajos"), ("Ventanas", "Glass"), ("Puerta", "Pared"), ("Cables", "Cerchas"), ("Auto", "Glass"), ("Tablero", "Tablero_Gancho"), ("Banco", "Banco_Pieza"), ("Banco", "Banco_Latas"), ("Entrepiso", "Cajas"), ("Ventana", "Glass"), ("Entrepiso", "Entrepiso_Baranda"), ("Entrepiso", "Cama"), ("Entrepiso", "Cajon"), ("Cajon", "Radio"),
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
        if not a.startswith(estructura) and not a.startswith(("Neon_", "Lampara", "Tablero", "Ventana", "Entrepiso", "Cama", "Cajon", "Radio", "Escalera", "Banco_", "CarroHerramientas", "Cajas", "Glass_", "Cables", "Ventanas", "Gancho", "TableroTrabajos", "Puerta")) and 0.03 < mna[2] < 0.6:
            flotan.append((a, round(mna[2], 2)))
        for b in nombres[i + 1 :]:
            if a.startswith(estructura) and b.startswith(estructura):
                continue
            libres = ("Ondas", "Zocalo", "Piso_Manchas", "Piso_Charco", "Piso_Grietas", "Ventanas_Marcos", "Puerta_Lateral")
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
                for lista, w0, w1 in ((oxido, z0, min(z1, 3)), (cajas, max(z0, 3), z1)):
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
        o.append(pieza(nombre.replace("Ondas_", "Ondas_Oxido_"), oxido, "oxido"))
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
    # tablero: llaves con boca abierta (de mayor a menor), martillos con mango de madera, pinzas, serrucho y manguera
    bx, ty = 2, HY - G - 0.4
    her, mangos = [], []
    for k in range(9):
        largo = 1.0 + k * 0.12
        x = bx - 6.2 + k * 0.5
        her += [((0.18, 0.12, largo), (x, ty, 9.2 + largo / 2)), ((0.12, 0.12, 0.35), (x - 0.14, ty, 9.35 + largo)), ((0.12, 0.12, 0.35), (x + 0.14, ty, 9.35 + largo))]
    for k in range(3):
        x = bx - 0.8 + k * 1.0
        mangos.append(((0.22, 0.14, 1.5), (x, ty, 7.25)))
        her.append(((0.8, 0.22, 0.38), (x, ty - 0.02, 8.15)))
    for k in range(3):
        x = bx + 2.4 + k * 0.6
        her += [((0.12, 0.12, 0.9), (x - 0.09, ty, 7.2), (0, 6, 0)), ((0.12, 0.12, 0.9), (x + 0.09, ty, 7.2), (0, -6, 0)), ((0.3, 0.12, 0.35), (x, ty, 7.8))]
    her.append(((3.0, 0.06, 0.8), (bx + 4.4, ty, 9.9)))
    mangos.append(((0.8, 0.14, 0.7), (bx + 6.1, ty, 9.9)))
    o.append(pieza("Tablero_Herramientas", her, "acero"))
    # el gancho de Tano: la estrella de la Beta, solo en su propio panel a la izquierda del tablero, el doble de grande
    gx, gz, gy = -9.5, 8.0, HY - G - 0.45
    o.append(pieza("GanchoPanel", [((4.4, 0.25, 4.6), (gx, HY - G - 0.15, gz))], "madera-entrepiso"))
    o.append(pieza("GanchoPanel_Soportes", [((0.15, 0.5, 0.15), (gx + d, gy - 0.05, gz - 0.95)) for d in (-0.9, 0.9)], "hierro"))
    gan = [((2.8, 0.7, 1.6), (gx - 0.3, gy - 0.6, gz)), ((0.5, 0.5, 0.5), (gx - 1.9, gy - 0.6, gz + 1.0)), ((1.0, 0.5, 0.5), (gx - 0.6, gy - 0.6, gz - 1.05))]
    gan += [((0.3, 0.4, 1.3), (gx + 2.2, gy - 0.6, gz + d), (0, a, 0)) for d, a in ((0.6, -35), (0, 0), (-0.6, 35))]
    o.append(pieza("Gancho", gan, "acero", cilindros=[(0.42, 1.6, (gx + 1.1, gy - 0.6, gz), "X", 14), (0.6, 0.5, (gx - 0.3, gy - 0.6, gz + 0.9), "Y", 14)]))
    o.append(pieza("Neon_Gancho", [((2.2, 0.06, 0.2), (gx - 0.3, gy - 0.97, gz - 0.35)), ((0.06, 0.4, 0.5), (gx + 1.0, gy - 0.6, gz + 0.45))], "neon-gancho"))
    o.append(pieza("Tablero_Mangos", mangos, "roble"))
    o.append(pieza("Tablero_Manguera", [], "goma", cilindros=[(0.9, 0.25, (bx - 5.6, ty, 7.0), "Y", 14, 0.9)]))
    # banco: frentes de cajones con manijas, mango de la morsa y trapo rojo
    by = HY - G - 1.6
    caj = [((3.4, 0.15, 1.1), (bx - 5.4 + k * 3.6, by - 1.62, 2.2 - j * 1.3)) for k in range(4) for j in range(2)]
    caj += [((1.0, 0.25, 0.18), (bx - 5.4 + k * 3.6, by - 1.75, 2.3 - j * 1.3)) for k in range(4) for j in range(2)]
    o.append(pieza("Banco_Cajones", caj, "roble"))
    o.append(pieza("Banco_MorsaMango", [((0.15, 1.6, 0.15), (bx - 6, by - 1.6, 4.0))], "hierro"))
    o.append(pieza("Banco_Trapo", [((1.0, 0.7, 0.08), (bx + 5.5, by, 3.6))], "cofradia"))
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
    o.append(pieza("Compresor_Detalle", [((0.15, 1.4, 0.15), (15.9, -13.5, 2.6))], "hierro", cilindros=[(0.3, 0.15, (14.8, -12.4, 1.7), "Y", 10)]))  # manija y manómetro
    # tambores: aros
    o.append(pieza("Tambores_Aros", [], "hierro", cilindros=[(1.25, 0.15, (x, y, z), "Z", 14) for x, y in ((-17.6, 12.4), (-15, 13)) for z in (1.1, 2.4, 3.45)]))
    # escritorio: manijas de la cajonera, mouse, taza y papeles
    dx, dy = HX - G - 1.6, 9
    det = [((0.2, 0.8, 0.15), (dx - 1.32, dy + 1.8, 2.4 - k * 0.7)) for k in range(3)] + [((0.3, 0.45, 0.12), (dx - 0.6, dy - 1.6, 3.36)), ((1.6, 1.1, 0.04), (dx - 0.2, dy + 2.0, 3.32))]
    o.append(pieza("MesaFabricacion_Detalle", det, "hierro", cilindros=[(0.25, 0.5, (dx - 0.4, dy - 2.4, 3.3), "Z", 10)]))
    # cama: frazada doblada al pie
    kx, ky = (11 + HX - G) / 2 + 0.4, HY - G - 2.1
    o.append(pieza("Cama_Pie", [((0.8, 3.3, 0.35), (kx - 2.8, ky, ENTREPISO + 2.0))], "porton-verde"))
    cab = []
    for y, x0, x1, caida in ((4, -16, -6, 1.2), (12, 2, 10, 0.9), (-12, 4, 14, 1.0)):
        pts = [(x0 + (x1 - x0) * s / 6, y + 0.35, ALTO - 0.35 - caida * 4 * (s / 6) * (1 - s / 6)) for s in range(7)]
        cab += [_barra(pts[s], pts[s + 1], 0.1) for s in range(6)]
    o.append(pieza("Cables", cab, "goma"))
    # piso: manchas de aceite irregulares, un charco cerca del portón y grietas finas (todo apoyado, como calcomanías)
    import random

    random.seed(7)

    def mancha(cx, cy, r, lados=14):
        vs = []
        for k in range(lados):
            a = 2 * math.pi * k / lados
            rr = r * random.uniform(0.6, 1.15)
            vs.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr * 0.8, 0.012))
        return (vs, [tuple(range(lados))])

    manchas = ((-9, -6, 1.8), (-12, 2, 1.3), (5, -2, 0.9), (-4, 8, 1.1), (12, -8, 0.8))
    bordes = []
    for x, y, r in manchas:
        vs, f = mancha(x, y, r * 1.35, 16)
        bordes.append(([(a, b, 0.008) for a, b, _ in vs], f))
    o.append(pieza("Piso_Manchas_Borde", [], "aceite-borde", mallas=bordes))
    o.append(pieza("Piso_Manchas", [], "aceite", mallas=[mancha(x, y, r) for x, y, r in manchas]))
    o.append(pieza("Piso_Charco", [], "charco", mallas=[mancha(-8, -12.5, 2.2, 18)]))
    gri = []
    for x, y, a0 in ((-14, -2, 20), (2, 4, 110), (8, -12, 60), (-2, 12, 150)):
        px, py, a = x, y, math.radians(a0)
        for s in range(5):
            a += random.uniform(-0.6, 0.6)
            nx, ny = px + math.cos(a) * 0.9, py + math.sin(a) * 0.9
            gri.append(((0.06, 0.95, 0.01), ((px + nx) / 2, (py + ny) / 2, 0.006), (0, 0, math.degrees(a) - 90)))
            px, py = nx, ny
    o.append(pieza("Piso_Grietas", gri, "grieta"))
    o.append(pieza("Piso_RejillaBarras", [((0.15, 1.3, 0.1), (-3.2 + k * 0.4, -9, 0.11)) for k in range(7)], "hierro"))
    return o


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
    todo = est + mue + det
    cruces, flotan = revisar(todo)
    print("CHEQUEO", cruces, flotan, flush=True)
    if "solo-chequeo" in sys.argv:
        return {"cruces": cruces, "flotan": flotan}
    # sin bisel ni horneado: piezas de más de 30 studs, de muchas partes chicas o finitas, y lo que brilla
    largas = ("Techo", "Cerchas", "Hastial", "Ondas", "Zocalo", "Porton_Rollo", "Porton_Dintel", "Porton_Cortina", "Auto_", "Cables")
    chicas = ("Tablero_Herramientas", "Banco_", "CarroHerramientas_Cajones", "Locker_Detalle", "Piso_Manchas", "Piso_Grietas", "Piso_Rejilla", "Piso_Chapa",
              "Escalera", "Entrepiso_Baranda", "Elevador_Tacos", "Tambores_Aros", "MesaFabricacion_", "CarroHerramientas_",
              "Compresor_Detalle", "Neumaticos", "Lampara", "Radio", "Silla", "Cama", "Porton_Guias", "Tablero", "Piso_Charco", "Ventana_Marco", "Cajas",
              "Ventanas_Marcos", "Puerta_Lateral_Manija", "TableroTrabajos_", "GanchoPanel_Soportes", "Gancho")
    hornear = [o for o in todo if not o.name.startswith(("Neon_", "Auto_", "Glass_")) and o.name != "MesaFabricacion_Pantalla"]
    sin = tuple(o.name for o in hornear if o.name.startswith(largas + chicas))
    def lado(n):
        if n.startswith("Piso_") and n[5:].isdigit():
            return 1024
        return 512 if n.startswith(("Pared", "Elevador", "Auto", "Banco", "Entrepiso", "MesaFabricacion")) else 256
    lados = {o.name: lado(o.name) for o in hornear}
    presupuesto = {o.name: (500 if o.name.startswith(("Pared", "Piso_")) else 4000, [o.name]) for o in hornear}
    print("HORNEAR", len(hornear) - len(sin), "piezas; sin hornear", len(sin), flush=True)
    D.terminar(hornear, presupuesto, ARCHIVO, lados=lados, sin_bisel=sin, sin_hornear=sin)
    man = maniqui()
    P.luz_puerto()
    # 1) dos lámparas cálidas con cono marcado (spots + niebla adentro), luz fría azul entrando por el portón y lluvia afuera
    for nombre, (x, y, z), energia in (("Luz0", (-8, -4, 13.9), 2600), ("Luz1", (10, -4, 13.9), 2600)):
        d = bpy.data.lights.new(nombre, "SPOT")
        d.color = B.color("f2a23a")[:3]
        d.energy = energia
        d.spot_size = math.radians(75)
        d.spot_blend = 0.35
        luz = bpy.data.objects.new(nombre, d)
        bpy.context.scene.collection.objects.link(luz)
        luz.location = P.S(x, y, z)
    d = bpy.data.lights.new("LuzEscritorio", "POINT")
    d.color = B.color("ffc27a")[:3]
    d.energy = 150
    luz = bpy.data.objects.new("LuzEscritorio", d)
    bpy.context.scene.collection.objects.link(luz)
    luz.location = P.S(16, 9, ENTREPISO - 1.2)
    for nombre, desde, hacia, energia, color in (("LuzBanco", (2, 11.5, 12.5), (2, 14, 3.5), 900, "ffc27a"), ("LuzGancho", (-9.5, 9, 12.5), (-9.5, 15, 8), 700, "fff0d8")):
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
