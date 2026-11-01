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
    o.append(pieza("Banco_Gancho", [((1.6, 0.8, 0.6), (bx + 2, by - 0.3, 3.85))], "acero", cilindros=[(0.35, 1.4, (bx + 0.4, by - 0.2, 3.9), "X", 10)]))
    o.append(pieza("Tablero", [((14, 0.3, 5), (bx, HY - G - 0.15, 8.5))], "hierro"))
    o.append(pieza("Ventana_Fondo", [((5, 0.3, 3.4), (bx, HY - G - 0.3, 13.2))], "neon-cian"))  # pantalla/ventana chica de la ref-1
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
    o.append(pieza("Piso_Chapa", [((6, 3.6, 0.06), (9, -5, 0.03))], "hierro"))
    # lámparas colgantes cálidas (cadena + pantalla + foco Neon_)
    for i, x in enumerate((-8, 10)):
        # cuelgan del tirante de la cercha (y = -4, z = 16 - 0,3)
        o.append(pieza(f"Lampara{i}", [((0.15, 0.15, 1.0), (x, -4, ALTO - 0.8))], "hierro", cilindros=[(1.3, 0.8, (x, -4, 14.5), "Z", 12, 0.4)]))
        o.append(pieza(f"Neon_Lampara{i}", [((0.6, 0.6, 0.4), (x, -4, 14.3))], "neon-calido"))
    return o


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
    for n, nuevo in (("Auto_Vidrios", "Glass_Auto_Vidrios"), ("Auto_Faros", "Neon_Auto_Faros"), ("Auto_Stop", "Neon_Auto_Stop")):
        if n in fuente:
            c = P.copia(fuente[n], ex, ey, 0, z)
            c.name = nuevo
            h.append(c)
    for i, (sx, sy) in enumerate(((-1, -1), (-1, 1), (1, -1), (1, 1))):
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
              ("Columnas", "Correas"), ("Entrepiso", "Entrepiso_Baranda"), ("Entrepiso", "Cama"), ("Entrepiso", "Cajon"), ("Cajon", "Radio"),
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
        if not a.startswith(estructura) and not a.startswith(("Neon_", "Lampara", "Tablero", "Ventana", "Entrepiso", "Cama", "Cajon", "Radio", "Escalera", "Banco_", "CarroHerramientas")) and 0.03 < mna[2] < 0.6:
            flotan.append((a, round(mna[2], 2)))
        for b in nombres[i + 1 :]:
            if a.startswith(estructura) and b.startswith(estructura):
                continue
            if a.startswith(("Ondas", "Zocalo")) or b.startswith(("Ondas", "Zocalo")):
                continue
            base_a, base_b = a.split("_")[0], b.split("_")[0]
            if (base_a, base_b) in juntos or (base_b, base_a) in juntos or base_a == base_b or a.startswith(("Neon_", "Glass_")) or b.startswith(("Neon_", "Glass_")):
                continue
            mnb, mxb = cajas[b]
            if min(min(mxa[k], mxb[k]) - max(mna[k], mnb[k]) for k in range(3)) > 0.05 and _arbol(bpy.data.objects[a]).overlap(_arbol(bpy.data.objects[b])):
                cruces.append((a, b))
    return cruces, flotan


def camara(nombre, desde, hacia, lente=22):
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
        nb.hide_render = True
    bpy.ops.render.render(write_still=True)
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
    "concreto": {"paneles": (0.5, 0.5), "rayones": 0.1, "bordes": 0.3, "suciedad": 1.0, "grano": 0.7},
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
    def nervios(nombre, eje, fijo, desde, hasta, huecos):
        cajas = []
        k = desde + 0.5
        while k < hasta:
            tramos = [(1, ALTO)]
            for a, b, z0, z1 in huecos:
                if a <= k <= b:
                    tramos = [(z, w) for z, w in ((1, z0), (z1, ALTO)) if w - z > 0.5]
            for z0, z1 in tramos:
                tam = (0.35, 0.15, z1 - z0) if eje == "x" else (0.15, 0.35, z1 - z0)
                pos = (k, fijo, (z0 + z1) / 2) if eje == "x" else (fijo, k, (z0 + z1) / 2)
                cajas.append((tam, pos))
            k += 1
        o.append(pieza(nombre, cajas, "chapa"))

    nervios("Ondas_Frente", "x", -HY + G + 0.075, -HX + G, HX - G, [(PORTON_X[0], PORTON_X[1], 0, 10)])
    nervios("Ondas_Fondo", "x", HY - G - 0.075, -HX + G, HX - G, [])
    nervios("Ondas_Oeste", "y", -HX + G + 0.075, -HY + G, HY - G, [(-8, -4, 6, 10), (4, 8, 6, 10)])
    nervios("Ondas_Este", "y", HX - G - 0.075, -HY + G, HY - G, [(PUERTA_Y - 2, PUERTA_Y + 2, 0, 7), (8, 12, 6, 10)])
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
    # piso: manchas de aceite, grietas y barras de la rejilla (finitas, apoyadas)
    man = [((r, r * 0.8, 0.02), (x, y, 0.01)) for x, y, r in ((-9, -6, 3.2), (-12, 2, 2.4), (5, -2, 1.6), (-4, 8, 2.0), (12, -9, 1.4))]
    o.append(pieza("Piso_Manchas", man, "goma"))
    gri = [((0.12, 3 + k % 3, 0.02), (-15 + k * 4.3, -12 + (k * 7) % 22, 0.012), (0, 0, 20 + k * 37)) for k in range(8)]
    o.append(pieza("Piso_Grietas", gri, "goma"))
    o.append(pieza("Piso_RejillaBarras", [((0.15, 1.3, 0.1), (-3.2 + k * 0.4, -9, 0.11)) for k in range(7)], "hierro"))
    return o


def detalle():
    import detalle as D

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
    largas = ("Techo", "Cerchas", "Hastial", "Ondas", "Zocalo", "Porton_Rollo", "Porton_Dintel", "Auto_")
    chicas = ("Tablero_Herramientas", "Banco_", "CarroHerramientas_Cajones", "Locker_Detalle", "Piso_Manchas", "Piso_Grietas", "Piso_Rejilla", "Piso_Chapa",
              "Escalera", "Entrepiso_Baranda", "Elevador_Tacos", "Tambores_Aros", "MesaFabricacion_", "CarroHerramientas_",
              "Compresor_Detalle", "Neumaticos", "Lampara", "Radio", "Silla", "Cama", "Porton_Guias", "Tablero")
    hornear = [o for o in todo if not o.name.startswith(("Neon_", "Auto_", "Glass_")) and o.name not in ("MesaFabricacion_Pantalla", "Ventana_Fondo")]
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
    for nombre, (x, y, z), energia in (("Luz0", (-8, -4, 13.6), 700), ("Luz1", (10, -4, 13.6), 700), ("LuzEscritorio", (16, 9, ENTREPISO - 1.2), 150)):
        d = bpy.data.lights.new(nombre, "POINT")
        d.color = B.color("ffc27a")[:3]
        d.energy = energia
        luz = bpy.data.objects.new(nombre, d)
        bpy.context.scene.collection.objects.link(luz)
        luz.location = P.S(x, y, z)
    marcadores()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    sin_techo = [o for o in est if not o.name.startswith(("Techo", "Hastial", "Cerchas"))] + mue + det + [man]
    rs = [
        P.render_orto(ARCHIVO + "_detalle_planta", [o for o in sin_techo if not o.name.startswith(("Lampara", "Neon_", "Glass_"))], giro=0, altura=89, niebla=False, solo=True),
        camara(ARCHIVO + "_detalle_puerta", (-9, -15, 6.5), (6, 10, 4.5), lente=16),
        camara(ARCHIVO + "_detalle_fondo", (-17, 14, 10), (8, -10, 3), lente=16),
        P.render_orto(ARCHIVO + "_detalle_corte", [o for o in sin_techo if not o.name.startswith(("Pared_Frente", "Ondas_Frente", "Porton", "Lampara", "Neon_"))], giro=-25, altura=35, niebla=False, solo=True),
        camara(ARCHIVO + "_detalle_banco", (2, 6, 6), (2, 15, 6), lente=24),
        camara(ARCHIVO + "_detalle_entrepiso", (3, -6, 7), (17, 9, 4), lente=20),
    ]
    return {"cruces": cruces, "flotan": flotan, "triangulos": B.contar_triangulos(todo), "renders": rs}


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in pasos:
        print("RESULTADO", boceto())
    if "detalle" in pasos:
        print("RESULTADO", detalle())
