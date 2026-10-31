"""Puerto Óxido: kit modular (grilla de 8 studs) y dos edificios importantes.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/lugares/puerto_oxido.py -- boceto

Paso "boceto": bloques sin detalle de todas las piezas en una grilla + una calle armada de muestra,
guardado en blender/puerto-oxido.blend y renders/puerto-oxido_boceto_{grilla,calle}.png.
Medidas en studs (S convierte a metros). Cada pieza tiene el pivote en la base.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bmesh  # noqa: E402
import bpy  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

ARCHIVO = "puerto-oxido"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")
NIEBLA_PUERTO = "7f9a96"

# Presupuesto de triángulos por pieza (del prompt P21).
PRESUPUESTO = {
    "Muelle_Recto": 1500,
    "Muelle_Esquina": 1500,
    "Galpon_Pared": 1200,
    "Galpon_ParedPorton": 2000,
    "Galpon_ParedVentanas": 2000,
    "Galpon_Techo": 1000,
    "Calle_Adoquin": 800,
    "Calle_Vias": 1200,
    "Grua_Estructura": 12000,
    "Grua_Cabina": 6000,
    "Contenedor_Rojo": 600,
    "Contenedor_Azul": 600,
    "Contenedor_Verde": 600,
    "Contenedor_Gris": 600,
    "Prop_Farola": 500,
    "Prop_Bita": 500,
    "Prop_Cajones": 500,
    "Prop_Barril": 500,
    "Prop_Red": 500,
    "Prop_Cartel": 500,
    "Prop_Bote": 500,
    "Calle_Vereda": 800,
    "Calle_Cordon": 300,
    "Prop_MuroLadrillo": 500,
    "Prop_MuroRemate": 300,
    "Prop_Reja": 500,
    "Prop_Poste": 500,
    "Tunel_Arco": 3000,
    "Edificio_Viejo": 6000,
    "Edificio_ViejoTecho": 2000,
    "Arcada": 1500,
    "Prop_Alambrado": 300,
    "Albatros_Galpon": 15000,
    "Albatros_Oficina": 10000,
    "Barco_Casco": 18000,
    "Barco_Cubierta": 12000,
}

# Piezas que van encima de la anterior (segunda malla del mismo modelo).
ENCIMA = ("Edificio_ViejoTecho", "Grua_Cabina", "Albatros_Oficina", "Barco_Cubierta")


def S(*v):
    """Studs a metros."""
    return Vector(v) * B.STUD


def pieza(nombre, cajas, material, cilindros=(), mallas=()):
    """Un objeto con varias cajas (tam, centro[, giro xyz en grados]), cilindros (radio, alto,
    base, eje[, lados[, radio_arriba]]) y mallas sueltas (vértices, caras) en studs, todo en una
    malla. Pivote en (0, 0, 0) = la base."""
    bm = bmesh.new()
    for verts, caras in mallas:
        vs = [bm.verts.new(S(*v)) for v in verts]
        for f in caras:
            bm.faces.new([vs[i] for i in f])
    for c in cajas:
        tam, centro = c[0], c[1]
        giro = c[2] if len(c) > 2 else (0, 0, 0)
        m = (
            Matrix.Translation(S(*centro))
            @ Matrix.Rotation(math.radians(giro[2]), 4, "Z")
            @ Matrix.Rotation(math.radians(giro[1]), 4, "Y")
            @ Matrix.Rotation(math.radians(giro[0]), 4, "X")
            @ Matrix.Diagonal(S(*tam).to_4d())
        )
        m[3][3] = 1
        bmesh.ops.create_cube(bm, size=1.0, matrix=m)
    for c in cilindros:
        radio, alto, base, eje = c[:4]
        lados = c[4] if len(c) > 4 else 12
        radio2 = c[5] if len(c) > 5 else radio
        rot = {"Z": Matrix.Identity(4), "X": Matrix.Rotation(math.radians(90), 4, "Y"), "Y": Matrix.Rotation(math.radians(-90), 4, "X")}[eje]
        m = Matrix.Translation(S(*base)) @ rot @ Matrix.Translation((0, 0, alto * B.STUD / 2))
        bmesh.ops.create_cone(bm, cap_ends=True, segments=lados, radius1=radio * B.STUD, radius2=radio2 * B.STUD, depth=alto * B.STUD, matrix=m)
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)
    B.aplicar_material(obj, material)
    return obj


def cuna(x0, x1, y_pie, y_tope, z_pie, z_tope):
    """Rampa en cuña (malla suelta) entre x0 y x1: sube de (y_pie, z_pie) a (y_tope, z_tope).
    Para las mallas de choque de las escaleras."""
    v = [(x0, y_pie, z_pie), (x1, y_pie, z_pie), (x1, y_tope, z_pie), (x0, y_tope, z_pie), (x1, y_tope, z_tope), (x0, y_tope, z_tope)]
    a, b = (0, 1, 4, 5), (5, 4, 1, 0)
    caras = [(0, 3, 2, 1), (3, 5, 4, 2), (0, 5, 3), (1, 2, 4), (0, 1, 4, 5)]
    if (y_tope - y_pie) * 1 < 0:
        caras = [tuple(reversed(c)) for c in caras]
    return v, caras


def prefijo(obj):
    """Neon_ para lo que brilla y Glass_ para los vidrios: así en Studio se reconocen al toque."""
    mat = obj.data.materials[0].name if obj.data.materials else ""
    if "neon" in mat:
        return "Neon_"
    if "vidrio" in mat:
        return "Glass_"
    return ""


def borrar_caras_ocultas(obj, altura=0.05, todas=False):
    """Borra las caras que miran para abajo apoyadas en el piso (z < `altura` studs): la base de
    edificios y muros y la panza de los autos nunca se ven."""
    import bmesh as _bm

    bm = _bm.new()
    bm.from_mesh(obj.data)
    tope = altura * B.STUD
    fuera = [f for f in bm.faces if f.normal.z < -0.95 and (todas or f.calc_center_median().z < tope)]
    _bm.ops.delete(bm, geom=fuera, context="FACES")
    bm.to_mesh(obj.data)
    bm.free()
    return len(fuera)


def exportar_kit(carpeta, objs, sin_base=()):
    """Un FBX por pieza en exports/<carpeta>/, con el pivote en el origen y sin las caras de
    abajo en las piezas cuyo nombre empieza con algo de `sin_base`."""
    rutas = []
    for o in objs:
        if o.type != "MESH":
            continue
        loc = o.location.copy()
        o.location = (0, 0, 0)
        if o.name.startswith(tuple(sin_base)):
            borrar_caras_ocultas(o, todas=o.name.startswith("Calle_"))  # en la calle no se ve nada de abajo
        rutas.append(B.exportar_fbx(o, os.path.join(B.EXPORTS, carpeta, prefijo(o) + o.name + ".fbx")))
        o.location = loc
    return rutas


# ---------------------------------------------------------------------------
# Piezas (boceto)
# ---------------------------------------------------------------------------


def muelle_recto():
    tablones = [((1.4, 8, 0.5), (-3.2 + i * 1.6, 0, -0.25)) for i in range(5)]
    postes = [((0.8, 0.8, 4), (x, y, -1)) for x in (-3.6, 3.6) for y in (-3.6, 3.6)]
    return pieza("Muelle_Recto", tablones + postes, "madera-muelle")


def muelle_esquina():
    tablones = [((1.4, 8, 0.5), (-3.2 + i * 1.6, 0, -0.25)) for i in range(5)]
    borde = [((8, 0.8, 1), (0, -3.6, 0.5)), ((0.8, 8, 1), (3.6, 0, 0.5))]
    postes = [((0.8, 0.8, 4), (x, y, -1)) for x in (-3.6, 3.6) for y in (-3.6, 3.6)]
    return pieza("Muelle_Esquina", tablones + borde + postes, "madera-muelle")


def galpon_pared(tipo):
    if tipo == "Porton":
        cajas = [((1.5, 0.4, 12), (-3.25, 0, 6)), ((1.5, 0.4, 12), (3.25, 0, 6)), ((5, 0.4, 3), (0, 0, 10.5)), ((5.4, 0.3, 9), (0, -0.4, 4.5))]
    elif tipo == "Ventanas":
        cajas = [((8, 0.4, 6), (0, 0, 3)), ((8, 0.4, 2), (0, 0, 11)), ((1.5, 0.4, 4), (-3.25, 0, 8)), ((2, 0.4, 4), (0, 0, 8)), ((1.5, 0.4, 4), (3.25, 0, 8))]
    else:
        cajas = [((8, 0.4, 12), (0, 0, 6))]
    nombre = "Galpon_Pared" + ("" if tipo == "Lisa" else tipo)
    return pieza(nombre, cajas, "chapa-oxido")


def galpon_techo():
    cajas = [((8, 4.6, 0.3), (0, -2, 1), (-25, 0, 0)), ((8, 4.6, 0.3), (0, 2, 1), (25, 0, 0))]
    return pieza("Galpon_Techo", cajas, "chapa-oxido")


def calle(vias):
    cajas = [((8, 8, 0.4), (0, 0, 0.2))]
    if vias:
        cajas += [((8, 0.4, 0.4), (0, y, 0.5)) for y in (-1.6, 1.6)]
        cajas += [((0.8, 4.4, 0.2), (x, 0, 0.45)) for x in (-3, -1, 1, 3)]
        return pieza("Calle_Vias", cajas, "adoquin")
    return pieza("Calle_Adoquin", cajas, "adoquin")


def _barra(a, b, grosor=0.4):
    """Caja fina de `a` a `b` (studs, en el plano YZ o XZ)."""
    a, b = Vector(a), Vector(b)
    d = b - a
    if abs(d.x) > abs(d.y):  # en el plano XZ: largo en X, giro sobre Y
        return ((d.length, grosor, grosor), tuple((a + b) / 2), (0, -math.degrees(math.atan2(d.z, d.x)), 0))
    return ((grosor, d.length, grosor), tuple((a + b) / 2), (math.degrees(math.atan2(d.z, d.y)), 0, 0))


def grua():
    """Grúa torre de celosía: torre de 6x6 con cruces, pluma de 50 studs hacia el agua, contrapluma
    con contrapeso, mástil con tensores. Cabina roja, gancho y cadena en la segunda malla."""
    alto, lado, tramo = 48, 6, 6
    h = lado / 2
    cajas = [((0.8, 0.8, alto), (x, y, alto / 2)) for x in (-h, h) for y in (-h, h)]
    for k in range(alto // tramo):
        z0, z1 = k * tramo, (k + 1) * tramo
        sube = k % 2 == 0
        for x in (-h, h):  # caras en X: cruz en el plano YZ
            cajas.append(_barra((x, -h, z0 if sube else z1), (x, h, z1 if sube else z0), 0.3))
        for y in (-h, h):
            cajas.append(_barra((-h, y, z0 if sube else z1), (h, y, z1 if sube else z0), 0.3))
        cajas.append(((lado, 0.3, 0.3), (0, -h, z1)))
        cajas.append(((lado, 0.3, 0.3), (0, h, z1)))
    zp = alto + 2
    # Pluma (hacia -Y) y contrapluma (+Y): dos cordones abajo, uno arriba, diagonales
    for x in (-1.2, 1.2):
        cajas.append(((0.4, 66, 0.4), (x, -17, zp)))
    cajas.append(((0.4, 66, 0.4), (0, -17, zp + 2.5)))
    for k in range(0, 33):
        y0 = 16 - k * 2
        cajas.append(_barra((0, y0, zp), (0, y0 - 2, zp + 2.5) if k % 2 == 0 else (0, y0 - 2, zp), 0.25))
    cajas.append(((4, 6, 4), (0, 13, zp - 1)))  # contrapeso
    cajas += [((1.2, 1.2, 12), (0, 0, zp + 6))]  # mástil
    cajas.append(_barra((0, 0, zp + 12), (0, -48, zp + 2.5), 0.25))
    cajas.append(_barra((0, 0, zp + 12), (0, 16, zp + 2.5), 0.25))
    est = pieza("Grua_Estructura", cajas, "grua-amarillo", cilindros=[(4, 1.2, (0, 0, alto), "Z")])
    cab = pieza(
        "Grua_Cabina",
        [((4, 4, 4), (-4, -2, alto - 1)), ((1.6, 1.6, 1), (0, -40, zp - 22)), ((0.4, 1.4, 1.4), (0, -40.6, zp - 23.2))],
        "cofradia",
        cilindros=[(0.15, 21, (0, -40, zp - 21.5), "Z")],
    )
    return [est, cab]


def contenedor(color):
    """Contenedor con costillas en los lados y puertas con barras verticales (atrás, +Y)."""
    cajas = [((4, 10, 4), (0, 0, 2))]
    cajas += [((4.2, 0.2, 3.6), (0, -4.6 + i * 1.15, 2)) for i in range(9)]
    cajas += [((0.15, 0.2, 3.6), (x, 5.05, 2)) for x in (-1.4, -0.6, 0.6, 1.4)]
    return pieza("Contenedor_" + color.capitalize(), cajas, "cont-" + color)


def arcada():
    """Tramo de arcada de 8 studs: pared con un arco grande (pasaje o mercado), cornisa arriba."""
    cajas = [((1.5, 1, 10), (-3.25, 0, 5)), ((1.5, 1, 10), (3.25, 0, 5)), ((8, 1, 2), (0, 0, 11)), ((8.4, 1.4, 0.6), (0, 0, 12.3))]
    for ancho, z in ((5, 9.6), (3.4, 8.9), (1.8, 8.4)):
        lado = (5 - ancho) / 2 + 0.01
        if lado > 0.05:
            cajas += [((lado, 1, 0.8), (-2.5 + lado / 2, 0, z)), ((lado, 1, 0.8), (2.5 - lado / 2, 0, z))]
    return pieza("Arcada", cajas, "piedra-clara")


def alambrado():
    postes = [((0.3, 0.3, 8), (x, 0, 4)) for x in (-4, 0, 4)]
    return pieza("Prop_Alambrado", postes + [((8, 0.05, 7), (0, 0, 4)), ((8, 0.3, 0.3), (0, 0, 7.8))], "hierro")


def props():
    # Farola de hierro con farol; la luz naranja va como PointLight en Roblox.
    farola = pieza(
        "Prop_Farola",
        [((1, 1, 1), (0, 0, 0.5)), ((0.4, 0.4, 11), (0, 0, 6.5)), ((1.2, 1.2, 1.6), (0, 0, 12.6)), ((1.5, 1.5, 0.3), (0, 0, 13.5))],
        "hierro",
    )
    bita = pieza("Prop_Bita", [], "acero", cilindros=[(0.7, 1.6, (0, 0, 0), "Z"), (1, 0.4, (0, 0, 1.6), "Z")])
    cajones = pieza("Prop_Cajones", [((2, 2, 2), (0, 0, 1)), ((2, 2, 2), (2.1, 0.3, 1)), ((2, 2, 2), (1, 0, 3))], "madera-muelle")
    barril = pieza("Prop_Barril", [], "oxido", cilindros=[(1, 3, (0, 0, 0), "Z")])
    red = pieza("Prop_Red", [((4, 0.2, 3), (0, 0, 4)), ((0.3, 0.3, 6), (-2, 0, 3)), ((0.3, 0.3, 6), (2, 0, 3))], "soga")
    cartel = pieza("Prop_Cartel", [((10, 0.4, 3), (0, 0, 8), (0, 6, 0)), ((0.4, 0.4, 7), (-4, 0, 3.5)), ((0.4, 0.4, 5), (4, 0, 2.5))], "oxido")
    bote = pieza("Prop_Bote", [((3, 8, 1.4), (0, 0, 0.7)), ((2, 2, 1.2), (0, 4.4, 0.6), (0, 0, 45))], "madera-muelle")
    muro = pieza("Prop_MuroLadrillo", [((8, 0.8, 4), (0, 0, 2))], "ladrillo")
    remate = pieza("Prop_MuroRemate", [((8.2, 1.2, 0.4), (0, 0, 4.2))], "piedra-clara")
    reja = pieza("Prop_Reja", [((8, 0.2, 0.2), (0, 0, z)) for z in (0.5, 3.8)] + [((0.15, 0.15, 3.6), (-3.8 + i * 0.8, 0, 2.1)) for i in range(10)], "hierro")
    # Poste de luz con travesaño; los cables colgando van como Beams en Roblox.
    poste = pieza("Prop_Poste", [((0.6, 0.6, 22), (0, 0, 11)), ((5, 0.4, 0.4), (0, 0, 20))], "hierro")
    return [farola, bita, cajones, barril, red, cartel, bote, muro, remate, reja, poste]


def vereda():
    return [
        pieza("Calle_Vereda", [((8, 8, 0.8), (0, 0, 0.4))], "adoquin"),
        pieza("Calle_Cordon", [((8, 0.6, 0.9), (0, -3.7, 0.45))], "cordon-amarillo"),
    ]


def tunel_arco():
    """Boca de túnel en arco para las vías (16 de ancho, hueco de 10)."""
    cajas = [((3, 4, 14), (-6.5, 0, 7)), ((3, 4, 14), (6.5, 0, 7)), ((16, 4, 3), (0, 0, 15.5))]
    for i, (ancho, z) in enumerate(((10, 13.4), (8, 12.6), (6, 12.0))):
        lado = (10 - ancho) / 2 + 0.5
        cajas += [((lado, 4, 0.8), (-5 + lado / 2 - 0.5, 0, z)), ((lado, 4, 0.8), (5 - lado / 2 + 0.5, 0, z))]
    return pieza("Tunel_Arco", cajas, "piedra-clara")


def edificio_viejo():
    """Edificio de relleno del puerto: dos pisos, ventanas altas en arco, cornisa y techo de tejas."""
    cajas = [((24, 16, 18), (0, 0, 9)), ((25, 17, 0.8), (0, 0, 9)), ((25, 17, 1), (0, 0, 18.5))]
    for x in (-8, -2.7, 2.7, 8):
        for z in (4, 13):
            cajas += [((3, 0.4, 5), (x, -8.1, z)), ((2, 0.4, 1), (x, -8.1, z + 3))]
    cuerpo = pieza("Edificio_Viejo", cajas, "piedra-clara")
    techo = pieza("Edificio_ViejoTecho", [((25, 9.4, 0.6), (0, -4, 21.2), (28, 0, 0)), ((25, 9.4, 0.6), (0, 4, 21.2), (-28, 0, 0))], "teja")
    return [cuerpo, techo]


def galpon_albatros():
    galpon = pieza(
        "Albatros_Galpon",
        [((48, 32, 18), (0, 0, 9)), ((24, 34, 0.6), (-12, 0, 21), (0, -20, 0)), ((24, 34, 0.6), (12, 0, 21), (0, 20, 0))],
        "chapa-oxido",
    )
    ofi = pieza(
        "Albatros_Oficina",
        [((16, 10, 8), (12, -12, 22)), ((14, 0.3, 4), (12, -17.2, 22)), ((10, 0.6, 4), (-10, -16.5, 20))],
        "cofradia",
    )
    return [galpon, ofi]


def barco_albatros():
    casco = pieza(
        "Barco_Casco",
        [((14, 50, 10), (0, 0, 5)), ((10, 10, 10), (0, 25, 5), (0, 0, 45)), ((14, 6, 4), (0, -22, 12))],
        "oxido",
    )
    cub = pieza(
        "Barco_Cubierta",
        [((10, 8, 10), (0, -20, 15)), ((12, 4, 2), (0, -20, 21)), ((4, 10, 4), (-3, 4, 12)), ((4, 10, 4), (3, 4, 12)), ((4, 10, 4), (0, 4, 16))],
        "acero",
    )
    return [casco, cub]


def todas():
    return [
        [muelle_recto(), muelle_esquina(), calle(False), calle(True)] + vereda() + [galpon_techo()],
        [galpon_pared("Lisa"), galpon_pared("Porton"), galpon_pared("Ventanas"), arcada(), alambrado()],
        [contenedor(c) for c in ("rojo", "azul", "verde", "gris")],
        props(),
        [tunel_arco()] + edificio_viejo() + grua() + galpon_albatros() + barco_albatros(),
    ]


def _poner(obj, x, y, giro=0):
    obj.location = S(x, y, 0)
    obj.rotation_euler = (0, 0, math.radians(giro))


def grilla(grupos, separacion=14):
    """Cada grupo en una fila (eje Y), separadas por su tamaño."""
    y = 0
    for fila in grupos:
        x = 0
        x_ant = 0
        ancho_fila = 0
        for o in fila:
            bpy.context.view_layer.update()
            if o.name in ENCIMA:
                _poner(o, x_ant, y)
                continue
            dx = o.dimensions.x / B.STUD
            dy = o.dimensions.y / B.STUD
            x_ant = x + dx / 2
            _poner(o, x_ant, y + dy / 2)
            x += dx + separacion
            ancho_fila = max(ancho_fila, dy)
        for o in fila:
            if o.name in ENCIMA:
                o.location.y = fila[fila.index(o) - 1].location.y
        y += ancho_fila + 8


def copia(o, x, y, giro=0, z=0):
    c = o.copy()
    c.name = o.name + "_muestra"
    bpy.context.scene.collection.objects.link(c)
    _poner(c, x, y, giro)
    c.location.z = z * B.STUD
    return c


def calle_muestra(p, ox):
    """Una calle del puerto armada con el kit: muelle al agua, calle con vías, galpones del otro
    lado, farolas, props, contenedores y una grúa sobre el muelle."""
    hechas = []
    paredes = ["Galpon_Pared", "Galpon_ParedPorton", "Galpon_ParedVentanas"]
    for i in range(8):
        x = ox + i * 8
        hechas.append(copia(p["Muelle_Esquina" if i == 7 else "Muelle_Recto"], x, -8))
        hechas.append(copia(p["Calle_Vias" if i % 3 == 1 else "Calle_Adoquin"], x, 0))
        hechas.append(copia(p["Calle_Vereda"], x, 8))
        hechas.append(copia(p["Calle_Cordon"], x, 8))
        hechas.append(copia(p["Prop_MuroLadrillo"], x, -12.4))
        hechas.append(copia(p["Prop_MuroRemate"], x, -12.4))
        hechas.append(copia(p[paredes[i % 3]], x, 12.2))
        hechas.append(copia(p["Galpon_Techo"], x, 16.2, z=12))
    for i in (1, 5):
        hechas.append(copia(p["Prop_Farola"], ox + i * 8, 6))
    for i in (0, 3, 6):
        hechas.append(copia(p["Prop_Poste"], ox + i * 8 + 4, 10.5))
    hechas.append(copia(p["Prop_Reja"], ox + 60, 4, 90))
    hechas.append(copia(p["Tunel_Arco"], ox - 8, 0, 90))
    hechas.append(copia(p["Edificio_Viejo"], ox + 84, 14))
    hechas.append(copia(p["Edificio_ViejoTecho"], ox + 84, 14))
    hechas += [
        copia(p["Prop_Bita"], ox + 10, -6),
        copia(p["Prop_Bita"], ox + 34, -6),
        copia(p["Prop_Cajones"], ox + 20, 8),
        copia(p["Prop_Barril"], ox + 44, 9),
        copia(p["Prop_Red"], ox + 26, 11.5),
        copia(p["Prop_Cartel"], ox - 6, 6),
        copia(p["Prop_Bote"], ox + 50, -10, 30),
    ]
    for j, c in enumerate(("Rojo", "Azul", "Verde", "Gris")):
        hechas.append(copia(p["Contenedor_" + c], ox + 66, -2 + j * 4.5, 90))
    hechas.append(copia(p["Contenedor_Rojo"], ox + 66, 0.25, 90, z=4))
    hechas.append(copia(p["Grua_Estructura"], ox + 28, -6))
    hechas.append(copia(p["Grua_Cabina"], ox + 28, -6))
    for k in range(3):
        hechas.append(copia(p["Arcada"], ox - 24 + k * 8, 14))
    for k in range(3):
        hechas.append(copia(p["Prop_Alambrado"], ox + 62 + k * 8, -14))
    return hechas


def luz_puerto():
    """Luz de noche del kit con niebla verde-gris del puerto."""
    B.configurar_luz()
    niebla = bpy.data.objects["Niebla"]
    niebla.scale = (12, 12, 3)
    vol = niebla.data.materials[0].node_tree.nodes["Principled Volume"]
    vol.inputs["Color"].default_value = B.color(NIEBLA_PUERTO)
    vol.inputs["Density"].default_value = 0.004
    bpy.context.scene.eevee.volumetric_end = 200.0
    bpy.data.worlds["Noche"].node_tree.nodes["Background"].inputs["Color"].default_value = B.color("1c2426")


def render_orto(nombre, objs, giro=30.0, altura=50.0, niebla=True, solo=False):
    """Render ortográfico (1600x1000) que encuadra justo `objs`: renders/<nombre>.png."""
    escena = bpy.context.scene
    minimo, maximo = B.caja_de(objs)
    centro = (minimo + maximo) / 2
    radio = (maximo - minimo).length / 2
    datos = bpy.data.cameras.new("Orto")
    datos.type = "ORTHO"
    datos.ortho_scale = radio * 1.9
    datos.clip_end = radio * 10
    cam = bpy.data.objects.new("Orto", datos)
    escena.collection.objects.link(cam)
    a, e = math.radians(giro), math.radians(altura)
    desde = centro + Vector((-math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e))) * radio * 4
    cam.matrix_world = Matrix.Translation(desde) @ (centro - desde).to_track_quat("-Z", "Y").to_matrix().to_4x4()
    nb = bpy.data.objects["Niebla"]
    nb.hide_render = not niebla
    escena.camera = cam
    ocultos = [o for o in escena.objects if solo and o.type == "MESH" and o not in objs and not o.hide_render and o.name != "Niebla"]
    for o in ocultos:
        o.hide_render = True
    escena.render.resolution_x, escena.render.resolution_y = 1600, 1000
    ruta = os.path.join(B.RENDERS, nombre + ".png")
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam)
    nb.hide_render = False
    for o in ocultos:
        o.hide_render = False
    return ruta


def boceto():
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    grupos = todas()
    grilla(grupos)
    p = {o.name: o for fila in grupos for o in fila}
    bpy.context.view_layer.update()
    ancho = max(o.location.x + o.dimensions.x / 2 for o in p.values()) / B.STUD
    muestra = calle_muestra(p, ancho + 60)
    luz_puerto()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    cuenta = B.contar_triangulos(list(p.values()))
    chicas = [o for fila in grupos[:-1] for o in fila]
    r1 = render_orto(ARCHIVO + "_boceto_kit", chicas, giro=0, altura=50, niebla=False)
    r3 = render_orto(ARCHIVO + "_boceto_grandes", grupos[-1], giro=20, altura=25, niebla=False)
    r2 = render_orto(ARCHIVO + "_boceto_calle", muestra, giro=-30, altura=30)
    return cuenta, r1, r2, r3


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in pasos:
        print(boceto())
