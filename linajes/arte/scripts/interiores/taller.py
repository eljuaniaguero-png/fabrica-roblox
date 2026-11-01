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
    o.append(pieza("Pared_Fondo", [((ANCHO, G, ALTO), (0, HY - G / 2, ALTO / 2))], "chapa"))
    # oeste (-X), con 2 ventanas; este (+X), con puerta lateral y 1 ventana
    for lado, sx in (("Oeste", -1), ("Este", 1)):
        cajas = []
        for y in range(-14, 15, MOD):
            if lado == "Este" and y == PUERTA_Y:
                cajas.append(((G, MOD, ALTO - 7), (sx * (HX - G / 2), y, 7 + (ALTO - 7) / 2)))
            elif (lado == "Oeste" and y in (-6, 6)) or (lado == "Este" and y == 10):
                cajas += [((G, MOD, 6), (sx * (HX - G / 2), y, 3)), ((G, MOD, ALTO - 10), (sx * (HX - G / 2), y, 10 + (ALTO - 10) / 2))]
            else:
                cajas.append(((G, MOD, ALTO), (sx * (HX - G / 2), y, ALTO / 2)))
        o.append(pieza(f"Pared_{lado}", cajas, "chapa"))
    o.append(pieza("Piso", [((ANCHO, FONDO, 0.4), (0, 0, -0.2))], "concreto"))
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
    # elevador amarillo de dos columnas con el auto (bloque), oeste
    ex, ey = -10, -2
    elev = [((1.4, 1.4, 12), (ex + sx * 6.5, ey, 6)) for sx in (-1, 1)] + [((2.6, 2.6, 0.4), (ex + sx * 6.5, ey, 0.2)) for sx in (-1, 1)]
    elev += [_barra((ex + sx * 6.5, ey, 4.4), (ex + sx * 2.4, ey + sy * 4.5, 4.4), 0.4) for sx in (-1, 1) for sy in (-1, 1)]
    elev += [((14.4, 0.8, 0.8), (ex, ey, 12.2))]
    o.append(pieza("Elevador", elev, "amarillo"))
    o.append(pieza("Auto", [((7, 13, 2.6), (ex, ey, 6.2)), ((6, 7, 2.2), (ex, ey + 1, 8.6)), ((6.6, 4, 0.3), (ex, ey - 6.5, 8.8), (-55, 0, 0))], "porton-verde"))  # capó abierto
    o.append(pieza("Auto_Ruedas", [], "goma", cilindros=[(1.2, 1.0, (ex + sx * 3.7, ey + sy * 4.3, 4.9), "X", 12) for sx in (-1, 1) for sy in (-1, 1)]))
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
    o.append(pieza("CarroHerramientas", [((3, 2, 3.4), (9, -11, 1.9)), ((3.2, 2.2, 0.2), (9, -11, 3.7))], "rojo-herramienta", cilindros=[(0.3, 0.3, (9 + sx * 1.2, -11 + sy * 0.8, 0), "Z", 8) for sx in (-1, 1) for sy in (-1, 1)]))
    o.append(pieza("Compresor", [((3, 1.6, 0.4), (14.5, -13.5, 0.2))], "rojo-herramienta", cilindros=[(1.1, 3.2, (13, -13.5, 1.5), "X", 12)]))
    o.append(pieza("Locker", [((3, 2.2, 7), (HX - G - 1.5, -HY + G + 1.2, 3.5))], "verde-locker"))
    # piso: rejilla y chapa semilla de melón (finitas, apoyadas)
    o.append(pieza("Piso_Rejilla", [((3, 1.4, 0.08), (-2, -9, 0.04))], "hierro"))
    o.append(pieza("Piso_Chapa", [((6, 3.6, 0.08), (9, -5, 0.04))], "acero"))
    # lámparas colgantes cálidas (cadena + pantalla + foco Neon_)
    for i, x in enumerate((-8, 10)):
        # cuelgan del tirante de la cercha (y = -4, z = 16 - 0,3)
        o.append(pieza(f"Lampara{i}", [((0.15, 0.15, 1.0), (x, -4, ALTO - 0.8))], "hierro", cilindros=[(1.3, 0.8, (x, -4, 14.5), "Z", 12, 0.4)]))
        o.append(pieza(f"Neon_Lampara{i}", [((0.6, 0.6, 0.4), (x, -4, 14.3))], "neon-calido"))
    return o


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
              ("Entrepiso", "Entrepiso_Baranda"), ("Entrepiso", "Cama"), ("Entrepiso", "Cajon"), ("Cajon", "Radio"),
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
        if not a.startswith(estructura) and not a.startswith(("Neon_", "Lampara", "Tablero", "Ventana", "Entrepiso", "Cama", "Cajon", "Radio", "Escalera")) and 0.03 < mna[2] < 0.6:
            flotan.append((a, round(mna[2], 2)))
        for b in nombres[i + 1 :]:
            if a.startswith(estructura) and b.startswith(estructura):
                continue
            base_a, base_b = a.split("_")[0], b.split("_")[0]
            if (base_a, base_b) in juntos or (base_b, base_a) in juntos or base_a == base_b or a.startswith("Neon_") or b.startswith("Neon_"):
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
    r1 = P.render_orto(ARCHIVO + "_boceto_planta", [o for o in sin_techo if not o.name.startswith(("Lampara", "Neon_"))], giro=0, altura=89, niebla=False, solo=True)
    r2 = camara(ARCHIVO + "_boceto_puerta", (-9, -15, 6.5), (6, 10, 4.5), lente=16)
    r3 = camara(ARCHIVO + "_boceto_fondo", (-17, 14, 10), (8, -10, 3), lente=16)
    r4 = P.render_orto(ARCHIVO + "_boceto_corte", [o for o in sin_techo if not o.name.startswith(("Pared_Frente", "Porton", "Lampara", "Neon_"))], giro=-25, altura=35, niebla=False, solo=True)
    r5 = camara(ARCHIVO + "_boceto_entrepiso", (3, -6, 7), (17, 9, 4), lente=20)
    return {"cruces": cruces, "flotan": flotan, "triangulos": B.contar_triangulos(est + mue), "renders": [r1, r2, r3, r4, r5]}


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in pasos:
        print("RESULTADO", boceto())
