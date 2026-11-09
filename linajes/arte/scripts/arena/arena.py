"""La arena del puerto armada en Blender, con la distribucion de la referencia
(boveda/08 Lugares/renders/arena-gemini-ref-1.png, versiones 1 y 4).

Todo en metros (1 stud = 0,28 m). La plaza de pelea mide 34 x 30 m.

Uso dentro de Blender:
    exec(open(r"...\\materiales.py").read()); construir_todos()
    exec(open(r"...\\arena.py").read()); armar_arena(); luz_atardecer(); poner_camara()
"""

import bpy
import math
import random
import mathutils

random.seed(7)

MAT = {}


def mat(nombre):
    m = bpy.data.materials.get(nombre)
    return m


def limpiar():
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)


def coleccion(nombre):
    col = bpy.data.collections.get(nombre)
    if not col:
        col = bpy.data.collections.new(nombre)
        bpy.context.scene.collection.children.link(col)
    return col


def meter(ob, col):
    for c in list(ob.users_collection):
        c.objects.unlink(ob)
    col.objects.link(ob)


def emparentar(hijo, padre):
    """Colgar sin que la pieza salte: hay que guardar la inversa del padre."""
    if hijo is None or padre is None:
        return
    hijo.parent = padre
    hijo.matrix_parent_inverse = padre.matrix_world.inverted()


def caja(nombre, centro, tam, material=None, col=None, giro=0.0, bisel=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=centro)
    ob = bpy.context.active_object
    ob.name = nombre
    ob.scale = tam
    ob.rotation_euler = (0, 0, giro)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bisel:
        m = ob.modifiers.new("Bisel", "BEVEL")
        m.width = bisel
        m.segments = 2
        m.limit_method = "ANGLE"
        m.angle_limit = math.radians(40)
    if material:
        ob.data.materials.append(material)
    if col:
        meter(ob, col)
    return ob


def cilindro(nombre, centro, radio, alto, material=None, col=None, lados=16, giro=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(
        radius=radio, depth=alto, location=centro, vertices=lados, rotation=giro
    )
    ob = bpy.context.active_object
    ob.name = nombre
    bpy.ops.object.shade_auto_smooth(angle=math.radians(35))
    if material:
        ob.data.materials.append(material)
    if col:
        meter(ob, col)
    return ob


def viga(nombre, a, b, grosor, material=None, col=None):
    """Caja estirada entre dos puntos: sirve para las gruas y las torres."""
    a = mathutils.Vector(mathvec(a))
    b = mathutils.Vector(mathvec(b))
    d = b - a
    largo = d.length
    if largo < 1e-6:
        return None
    ob = caja(nombre, (a + b) / 2, (grosor, grosor, largo), material, col, bisel=0.0)
    ob.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    return ob


def mathvec(v):
    return [float(v[0]), float(v[1]), float(v[2])]


# ------------------------------------------------------------------ piezas


CONTENEDOR_MATS = {}


def material_de_contenedor(tono):
    clave = tuple(round(v, 3) for v in tono[:3])
    if clave in CONTENEDOR_MATS:
        return CONTENEDOR_MATS[clave]
    import sys

    fn = globals().get("material_contenedor") or sys.modules["__main__"].__dict__.get(
        "material_contenedor"
    )
    if fn is None:
        m = mat("MAT_ChapaOxidada")
    else:
        m = fn("MAT_Contenedor_%d_%d_%d" % tuple(int(v * 255) for v in clave), clave)
    CONTENEDOR_MATS[clave] = m
    return m


def emisor(nombre, color, fuerza):
    """Material que ilumina (ventanas, lamparas, luces de posicion)."""
    m = bpy.data.materials.get(nombre)
    if m:
        return m
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    nt = m.node_tree
    for nd in list(nt.nodes):
        if nd.type != "OUTPUT_MATERIAL":
            nt.nodes.remove(nd)
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs[0].default_value = color
    em.inputs[1].default_value = fuerza
    salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_MATERIAL")
    nt.links.new(em.outputs[0], salida.inputs["Surface"])
    return m


def contenedor(nombre, centro, giro, tono, col):
    """Contenedor de 6 m x 2,44 m x 2,59 m con puertas."""
    m = material_de_contenedor(tono)
    cuerpo = caja(nombre, centro, (6.0, 2.44, 2.59), m, col, giro=giro, bisel=0.03)
    # Puertas en una punta: dos hojas con manija.
    for lado in (-0.6, 0.6):
        px = centro[0] + math.cos(giro) * 3.02 - math.sin(giro) * lado
        py = centro[1] + math.sin(giro) * 3.02 + math.cos(giro) * lado
        hoja = caja(nombre + "_Puerta", (px, py, centro[2]), (0.06, 1.14, 2.42), m, col,
                    giro=giro, bisel=0.01)
        emparentar(hoja, cuerpo)
    return cuerpo


def pila_contenedores(nombre, centro, giro, tonos, alturas, col):
    for i, tono in enumerate(tonos):
        z = centro[2] + alturas * i
        contenedor("%s_%d" % (nombre, i), (centro[0], centro[1], z), giro, tono, col)


def barril(nombre, centro, col, giro=0.0):
    cuerpo = cilindro(nombre, centro, 0.3, 0.88, mat("MAT_MetalPiso"), col, lados=20)
    cuerpo.rotation_euler = (0, 0, giro)
    for z in (-0.22, 0.0, 0.22):
        aro = cilindro(nombre + "_Aro", (centro[0], centro[1], centro[2] + z), 0.315, 0.05,
                       mat("MAT_MetalPiso"), col, lados=20)
        emparentar(aro, cuerpo)
    return cuerpo


def cajon(nombre, centro, lado, col, giro=0.0):
    cuerpo = caja(nombre, centro, (lado, lado, lado), mat("MAT_MaderaGastada"), col, giro=giro)
    # Listones en cruz en las caras.
    t = lado * 0.08
    for eje in (0, 1):
        for ang in (0.9, -0.9):
            listón = caja(
                nombre + "_Listón",
                centro,
                (lado * 1.3, t, t),
                mat("MAT_MaderaGastada"),
                col,
                bisel=0.005,
            )
            listón.rotation_euler = (
                ang if eje == 0 else 0,
                0 if eje == 0 else ang,
                giro,
            )
            listón.location = (
                centro[0] + (0 if eje == 0 else (lado / 2 + t / 2) * math.cos(giro)),
                centro[1] + ((lado / 2 + t / 2) if eje == 0 else 0),
                centro[2],
            )
            emparentar(listón, cuerpo)
    return cuerpo


def bita(nombre, centro, col):
    base = caja(nombre + "_Base", (centro[0], centro[1], centro[2] + 0.06), (0.7, 0.7, 0.12),
                mat("MAT_CementoMojado"), col)
    cuerpo = cilindro(nombre, (centro[0], centro[1], centro[2] + 0.34), 0.17, 0.46,
                      mat("MAT_MetalPiso"), col, lados=14)
    cabeza = cilindro(nombre + "_Cabeza", (centro[0], centro[1], centro[2] + 0.58), 0.24, 0.12,
                      mat("MAT_MetalPiso"), col, lados=14)
    emparentar(cabeza, cuerpo)
    emparentar(base, cuerpo)
    return cuerpo


def farola(nombre, centro, col, alto=5.4, brazo=1.1, giro=0.0):
    poste = cilindro(nombre, (centro[0], centro[1], centro[2] + alto / 2), 0.09, alto,
                     mat("MAT_MetalPiso"), col, lados=10)
    base = cilindro(nombre + "_Base", (centro[0], centro[1], centro[2] + 0.14), 0.18, 0.28,
                    mat("MAT_MetalPiso"), col, lados=10)
    emparentar(base, poste)
    bx = centro[0] + math.cos(giro) * brazo / 2
    by = centro[1] + math.sin(giro) * brazo / 2
    br = caja(nombre + "_Brazo", (bx, by, centro[2] + alto - 0.06), (brazo, 0.08, 0.08),
              mat("MAT_MetalPiso"), col, giro=giro, bisel=0.01)
    emparentar(br, poste)
    lx = centro[0] + math.cos(giro) * brazo
    ly = centro[1] + math.sin(giro) * brazo
    campana = caja(nombre + "_Campana", (lx, ly, centro[2] + alto - 0.22), (0.34, 0.26, 0.2),
                   mat("MAT_MetalPiso"), col, giro=giro, bisel=0.02)
    emparentar(campana, poste)
    vidrio = caja(nombre + "_Luz", (lx, ly, centro[2] + alto - 0.34), (0.26, 0.2, 0.06),
                  None, col, giro=giro, bisel=0.01)
    emparentar(vidrio, poste)
    emisor = bpy.data.materials.get("MAT_LuzFarola")
    if not emisor:
        emisor = bpy.data.materials.new("MAT_LuzFarola")
        emisor.use_nodes = True
        nt = emisor.node_tree
        for nd in list(nt.nodes):
            if nd.type != "OUTPUT_MATERIAL":
                nt.nodes.remove(nd)
        em = nt.nodes.new("ShaderNodeEmission")
        em.inputs[0].default_value = (1.0, 0.45, 0.10, 1)
        em.inputs[1].default_value = 14.0
        salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_MATERIAL")
        nt.links.new(em.outputs[0], salida.inputs["Surface"])
    vidrio.data.materials.append(emisor)
    return poste, (lx, ly, centro[2] + alto - 0.34)


def galpon(nombre, centro, ancho, largo, alto, col, giro=0.0, puerta=True):
    """Galpon de chapa con techo a dos aguas apoyado arriba de las paredes."""
    paredes = caja(nombre, (centro[0], centro[1], centro[2] + alto / 2), (ancho, largo, alto),
                   mat("MAT_ChapaOxidada"), col, giro=giro, bisel=0.03)
    zocalo = caja(nombre + "_Zocalo", (centro[0], centro[1], centro[2] + 0.3),
                  (ancho + 0.14, largo + 0.14, 0.6), mat("MAT_CementoMojado"), col, giro=giro)
    emparentar(zocalo, paredes)
    # Techo: dos faldones que nacen en el alero y suben hasta la cumbrera.
    pend = math.radians(20)
    medio = largo / 4
    subida = math.tan(pend) * medio
    for lado in (-1, 1):
        dx = -math.sin(giro) * lado * medio
        dy = math.cos(giro) * lado * medio
        faldon = caja(
            nombre + "_Techo",
            (centro[0] + dx, centro[1] + dy, centro[2] + alto + 0.08 + subida / 2),
            (ancho + 0.5, largo / 2 + 0.3, 0.12),
            mat("MAT_ChapaOxidada"),
            col,
            bisel=0.01,
        )
        faldon.rotation_euler = (-lado * pend, 0, giro)
        emparentar(faldon, paredes)
    cumbrera = caja(nombre + "_Cumbrera",
                    (centro[0], centro[1], centro[2] + alto + subida + 0.14),
                    (ancho + 0.55, 0.3, 0.1), mat("MAT_MetalPiso"), col, giro=giro, bisel=0.01)
    emparentar(cumbrera, paredes)
    if puerta:
        px = centro[0] + math.cos(giro) * (ancho / 2 + 0.04)
        py = centro[1] + math.sin(giro) * (ancho / 2 + 0.04)
        hueco = caja(nombre + "_Porton", (px, py, centro[2] + 1.55), (0.1, largo * 0.4, 3.1),
                     None, col, giro=giro, bisel=0.01)
        hueco.data.materials.append(emisor("MAT_LuzPorton", (1.0, 0.66, 0.30, 1), 1.1))
        emparentar(hueco, paredes)
        VENTANAS.append((px, py, centro[2] + 1.6))
        # Dos ventanas cálidas a los costados del portón.
        for lado in (-1, 1):
            vx = px - math.sin(giro) * lado * largo * 0.3
            vy = py + math.cos(giro) * lado * largo * 0.3
            ven = caja(nombre + "_Ventana", (vx, vy, centro[2] + alto * 0.62),
                       (0.1, largo * 0.16, 1.1), None, col, giro=giro, bisel=0.01)
            ven.data.materials.append(emisor("MAT_LuzVentana", (1.0, 0.70, 0.34, 1), 1.5))
            emparentar(ven, paredes)
            VENTANAS.append((vx, vy, centro[2] + alto * 0.62))
    return paredes


def celosia(nombre, a, b, grosor, m, col, separacion=0.0, pasos=6, diagonal=0.12):
    """Tramo de celosia: dos (o cuatro) cordones paralelos con diagonales en zig-zag.
    Es lo que hace que una grua se vea maciza y no de alambre."""
    a = mathutils.Vector(mathvec(a))
    b = mathutils.Vector(mathvec(b))
    eje = (b - a)
    largo = eje.length
    if largo < 1e-6:
        return []
    eje = eje.normalized()
    # Dos vectores perpendiculares al eje.
    arriba = mathutils.Vector((0, 0, 1))
    if abs(eje.dot(arriba)) > 0.95:
        arriba = mathutils.Vector((0, 1, 0))
    u = eje.cross(arriba).normalized()
    v = eje.cross(u).normalized()
    sep = separacion if separacion > 0 else grosor * 2.2
    piezas = []
    esquinas = [u * sep, -u * sep]
    if separacion > 0:
        esquinas = [u * sep + v * sep, u * sep - v * sep, -u * sep + v * sep, -u * sep - v * sep]
    for off in esquinas:
        piezas.append(viga(nombre + "_Cordon", a + off, b + off, grosor, m, col))
    # Diagonales en zig-zag entre los dos primeros cordones.
    for i in range(pasos):
        t0 = i / pasos
        t1 = (i + 1) / pasos
        p0 = a + (b - a) * t0 + esquinas[0]
        p1 = a + (b - a) * t1 + esquinas[1]
        piezas.append(viga(nombre + "_Diag", p0, p1, grosor * diagonal / 0.12 * 0.55, m, col))
        if len(esquinas) == 4:
            q0 = a + (b - a) * t0 + esquinas[2]
            q1 = a + (b - a) * t1 + esquinas[3]
            piezas.append(viga(nombre + "_Diag", q0, q1, grosor * 0.55, m, col))
        # Travesano recto cada tramo.
        r0 = a + (b - a) * t1 + esquinas[0]
        r1 = a + (b - a) * t1 + esquinas[1]
        piezas.append(viga(nombre + "_Trav", r0, r1, grosor * 0.5, m, col))
    return piezas


def grua(nombre, centro, col, giro=0.0, escala=1.0):
    """Grua vieja de puerto, alta: patas gruesas, cuerpo macizo, cabina y un brazo
    pesado en diagonal hacia arriba (45 grados) con el cable y el gancho colgando."""
    m = mat("MAT_MetalPiso")
    e = escala
    cx, cy, cz = centro
    co, si = math.cos(giro), math.sin(giro)

    def local(dx, dy, dz):
        return (cx + dx * co - dy * si, cy + dx * si + dy * co, cz + dz)

    piezas = []
    sep = 4.0 * e
    alto_pata = 12.0 * e

    for sx in (-1, 1):
        for sy in (-1, 1):
            p0 = local(sx * sep, sy * sep, 0.3)
            p1 = local(sx * 1.7 * e, sy * 1.7 * e, alto_pata)
            piezas.append(viga(nombre + "_Pata", p0, p1, 0.8 * e, m, col))
            piezas.append(
                caja(nombre + "_Zapata", local(sx * sep, sy * sep, 0.25),
                     (2.0 * e, 2.0 * e, 0.5), mat("MAT_CementoMojado"), col, giro=giro)
            )
    for sy in (-1, 1):
        piezas.append(
            caja(nombre + "_Riel", local(0, sy * sep, 0.6),
                 (sep * 2.5, 1.2 * e, 0.8 * e), m, col, giro=giro)
        )
    for z in (0.42, 0.72):
        d = sep - (sep - 1.7 * e) * z
        piezas.append(
            caja(nombre + "_Anillo", local(0, 0, alto_pata * z),
                 (d * 2.1, d * 2.1, 0.5 * e), m, col, giro=giro)
        )
    piezas.append(
        caja(nombre + "_Plataforma", local(0, 0, alto_pata + 0.5),
             (7.0 * e, 6.0 * e, 1.0), m, col, giro=giro)
    )
    piezas.append(
        caja(nombre + "_Casa", local(-2.0 * e, 0, alto_pata + 2.9),
             (5.4 * e, 4.8 * e, 4.4 * e), m, col, giro=giro)
    )
    piezas.append(
        caja(nombre + "_Techo", local(-2.0 * e, 0, alto_pata + 5.25),
             (5.8 * e, 5.2 * e, 0.3), m, col, giro=giro)
    )
    # Cabina del operario, del lado del agua.
    cab = local(2.9 * e, -2.4 * e, alto_pata + 1.8)
    piezas.append(caja(nombre + "_Cabina", cab, (2.4 * e, 2.0 * e, 2.4 * e), m, col, giro=giro))
    vidrio_cab = local(4.05 * e, -2.4 * e, alto_pata + 2.1)
    v = caja(nombre + "_CabinaVidrio", vidrio_cab, (0.16, 1.5 * e, 1.4 * e), None, col,
             giro=giro, bisel=0.01)
    v.data.materials.append(emisor("MAT_LuzCabina", (1.0, 0.72, 0.38, 1), 6.0))
    piezas.append(v)
    CABINAS.append(vidrio_cab)

    # Brazo en diagonal hacia arriba, unos 45 grados.
    raiz = local(1.2 * e, 0, alto_pata + 2.2)
    largo = 15.0 * e
    ang = math.radians(44)
    punta = local(1.2 * e + math.cos(ang) * largo, 0, alto_pata + 2.2 + math.sin(ang) * largo)
    piezas.append(viga(nombre + "_Brazo", raiz, punta, 1.0 * e, m, col))
    piezas.append(
        viga(nombre + "_BrazoBajo",
             local(1.2 * e, 0, alto_pata + 1.2),
             (punta[0], punta[1], punta[2] - 1.2 * e), 0.45 * e, m, col)
    )
    piezas.append(caja(nombre + "_Polea", punta, (1.4 * e, 1.6 * e, 1.1 * e), m, col, giro=giro))
    # Luz de posicion en la punta.
    luz_punta = (punta[0], punta[1], punta[2] + 0.9 * e)
    lp = caja(nombre + "_LuzPunta", luz_punta, (0.35 * e, 0.35 * e, 0.35 * e), None, col)
    lp.data.materials.append(emisor("MAT_LuzRoja", (1.0, 0.12, 0.08, 1), 25.0))
    piezas.append(lp)
    PUNTAS.append(luz_punta)

    # Mastil y tirantes que sostienen el brazo.
    mastil = local(-1.0 * e, 0, alto_pata + 11.0 * e)
    piezas.append(viga(nombre + "_Mastil", local(-1.0 * e, 0, alto_pata + 2.6), mastil,
                       0.8 * e, m, col))
    piezas.append(viga(nombre + "_Tirante", mastil, punta, 0.3 * e, m, col))
    cola = local(-7.0 * e, 0, alto_pata + 3.4 * e)
    piezas.append(viga(nombre + "_Cola", mastil, cola, 0.3 * e, m, col))
    piezas.append(
        caja(nombre + "_Contrapeso", local(-7.0 * e, 0, alto_pata + 2.2 * e),
             (3.6 * e, 3.4 * e, 2.6 * e), m, col, giro=giro)
    )
    # Cable largo y gancho colgando cerca del piso.
    gancho_z = cz + 3.5 * e
    piezas.append(
        viga(nombre + "_Cable", (punta[0], punta[1], punta[2] - 0.6 * e),
             (punta[0], punta[1], gancho_z), 0.07 * e, m, col)
    )
    piezas.append(
        caja(nombre + "_Gancho", (punta[0], punta[1], gancho_z - 0.7 * e),
             (0.9 * e, 0.9 * e, 1.4 * e), m, col, giro=giro)
    )
    return piezas


def torre_reflector(nombre, centro, col, alto=9.0):
    m = mat("MAT_MetalPiso")
    for sx in (-1, 1):
        for sy in (-1, 1):
            viga(nombre + "_Pata", (centro[0] + sx * 0.7, centro[1] + sy * 0.7, centro[2]),
                 (centro[0] + sx * 0.18, centro[1] + sy * 0.18, centro[2] + alto), 0.09, m, col)
    cabeza = caja(nombre + "_Cabeza", (centro[0], centro[1], centro[2] + alto + 0.3),
                  (2.2, 0.5, 0.7), m, col, bisel=0.02)
    luces = []
    emisor = bpy.data.materials.get("MAT_LuzReflector")
    if not emisor:
        emisor = bpy.data.materials.new("MAT_LuzReflector")
        emisor.use_nodes = True
        nt = emisor.node_tree
        for nd in list(nt.nodes):
            if nd.type != "OUTPUT_MATERIAL":
                nt.nodes.remove(nd)
        em = nt.nodes.new("ShaderNodeEmission")
        em.inputs[0].default_value = (0.85, 0.92, 1.0, 1)
        em.inputs[1].default_value = 45.0
        salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_MATERIAL")
        nt.links.new(em.outputs[0], salida.inputs["Surface"])
    for i in (-0.7, 0.0, 0.7):
        foco = caja(nombre + "_Foco", (centro[0] + i, centro[1] - 0.3, centro[2] + alto + 0.3),
                    (0.5, 0.08, 0.5), None, col, bisel=0.01)
        foco.data.materials.append(emisor)
        emparentar(foco, cabeza)
        luces.append((centro[0] + i, centro[1] - 0.3, centro[2] + alto + 0.3))
    return luces


# ------------------------------------------------------------------ escena

PLAZA = (34.0, 30.0)
TONOS_CONTENEDOR = [
    (0.420, 0.129, 0.090, 1),   # rojo ladrillo
    (0.098, 0.247, 0.420, 1),   # azul
    (0.094, 0.329, 0.196, 1),   # verde
    (0.545, 0.396, 0.098, 1),   # amarillo gastado
    (0.286, 0.306, 0.325, 1),   # gris acero
    (0.471, 0.235, 0.102, 1),   # naranja oxido
]

FAROLAS = []
REFLECTORES = []
VENTANAS = []
CABINAS = []
PUNTAS = []


def armar_arena():
    global FAROLAS, REFLECTORES, VENTANAS, CABINAS, PUNTAS
    FAROLAS, REFLECTORES = [], []
    VENTANAS, CABINAS, PUNTAS = [], [], []
    limpiar()
    piso = coleccion("Piso")
    carga = coleccion("Carga")
    edificios = coleccion("Edificios")
    maquinas = coleccion("Maquinas")
    luces = coleccion("Luces")
    chatarra = coleccion("Chatarra")

    # Mar: malla con olas suaves, oscura y espejada (refleja el sol del atardecer).
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=220, y_subdivisions=220, size=700,
                                    location=(0, 0, -1.6))
    agua = bpy.context.active_object
    agua.name = "Agua"
    m_agua = bpy.data.materials.get("MAT_Agua")
    if m_agua:
        bpy.data.materials.remove(m_agua)
    m_agua = bpy.data.materials.new("MAT_Agua")
    m_agua.use_nodes = True
    bsdf = next(n for n in m_agua.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (0.010, 0.020, 0.032, 1)
    bsdf.inputs["Roughness"].default_value = 0.055
    if "IOR" in bsdf.inputs:
        bsdf.inputs["IOR"].default_value = 1.33
    agua.data.materials.append(m_agua)
    meter(agua, piso)
    tex = bpy.data.textures.get("OlasTex")
    if tex:
        bpy.data.textures.remove(tex)
    tex = bpy.data.textures.new("OlasTex", "CLOUDS")
    tex.noise_scale = 4.5
    tex.noise_depth = 4
    mod = agua.modifiers.new("Olas", "DISPLACE")
    mod.texture = tex
    mod.strength = 0.5
    mod.mid_level = 0.5
    tex2 = bpy.data.textures.get("OlasFinas")
    if tex2:
        bpy.data.textures.remove(tex2)
    tex2 = bpy.data.textures.new("OlasFinas", "CLOUDS")
    tex2.noise_scale = 0.9
    mod2 = agua.modifiers.new("OlasFinas", "DISPLACE")
    mod2.texture = tex2
    mod2.strength = 0.1
    mod2.mid_level = 0.5
    bpy.ops.object.shade_smooth()

    # Muelle de tablas (el borde que da al agua, a la izquierda y al frente).
    caja("MuelleTablas", (-22.0, 2.0, -0.18), (9.0, 42.0, 0.36), mat("MAT_TablasMuelle"), piso)
    caja("MuelleFrente", (-2.0, -18.5, -0.18), (31.0, 6.0, 0.36), mat("MAT_TablasMuelle"), piso)
    # Vigas de abajo y pilotes.
    for x in range(-26, -16, 3):
        caja("Viga", (x, 2.0, -0.55), (0.3, 42.0, 0.4), mat("MAT_TablasMuelle"), piso, bisel=0.01)
    for x in (-25, -19):
        for y in (-18, -8, 4, 16, 21):
            cilindro("Pilote", (x, y, -1.4), 0.24, 2.4, mat("MAT_TablasMuelle"), piso, lados=10)
    for x in (-12, 0, 12):
        cilindro("Pilote", (x, -19.5, -1.4), 0.24, 2.4, mat("MAT_TablasMuelle"), piso, lados=10)

    # Explanada: todo el hormigon del puerto detras y a la derecha de la plaza.
    caja("Explanada", (10.0, 6.0, -0.06), (50.0, 56.0, 0.38), mat("MAT_CementoMojado"), piso)

    # Plaza de hormigon.
    caja("Plaza", (3.0, 0.0, 0.0), (PLAZA[0], PLAZA[1], 0.5), mat("MAT_CementoMojado"), piso)
    # Marco pintado del borde: cuatro franjas finitas apoyadas en la losa.
    marco = bpy.data.materials.get("MAT_PinturaPiso")
    if not marco:
        marco = bpy.data.materials.new("MAT_PinturaPiso")
        marco.use_nodes = True
        b = next(n for n in marco.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
        b.inputs["Base Color"].default_value = (0.26, 0.25, 0.23, 1)
        b.inputs["Roughness"].default_value = 0.8
    for dx, dy, sx, sy in (
        (0, PLAZA[1] / 2 - 1.2, PLAZA[0] - 2.4, 0.35),
        (0, -(PLAZA[1] / 2 - 1.2), PLAZA[0] - 2.4, 0.35),
        (PLAZA[0] / 2 - 1.2, 0, 0.35, PLAZA[1] - 2.4),
        (-(PLAZA[0] / 2 - 1.2), 0, 0.35, PLAZA[1] - 2.4),
    ):
        caja("PlazaMarco", (3.0 + dx, dy, 0.252), (sx, sy, 0.012), marco, piso, bisel=0.0)
    # Chapa estriada: dos tapas de registro.
    for pos in ((-6.0, 7.0), (9.0, -6.0)):
        caja("Tapa", (pos[0], pos[1], 0.13), (1.6, 1.6, 0.06), mat("MAT_MetalPiso"), piso)

    # Bitas en el borde del muelle.
    for y in (-14.0, -6.0, 2.0, 10.0, 17.0):
        bita("Bita", (-27.5, y, 0.0), chatarra)

    # Contenedores: muralla al fondo y pilas a la derecha.
    # Contenedores: grilla prolija, ninguno encima de otro ni fuera de la explanada.
    # Cada contenedor mide 6,0 x 2,44 x 2,59; la explanada va de x -15 a 35, y -22 a 34.
    LARGO_C, ANCHO_C, ALTO_C = 6.0, 2.44, 2.59

    def fila(nombre, x0, y0, giro, cantidad, paso, alturas, salto=0):
        for i in range(cantidad):
            if giro == 0.0:
                x, y = x0 + i * paso, y0
            else:
                x, y = x0, y0 + i * paso
            pila_contenedores(
                "%s%d" % (nombre, i),
                (x, y, ALTO_C / 2 + 0.2),
                giro,
                [
                    TONOS_CONTENEDOR[(i * 3 + k + salto) % len(TONOS_CONTENEDOR)]
                    for k in range(alturas[i % len(alturas)])
                ],
                ALTO_C + 0.03,
                carga,
            )

    # Fondo: dos hileras, detras de la plaza (la plaza llega a y = 15).
    fila("ContFondoA", -13.0, 18.6, 0.0, 4, LARGO_C + 0.5, [2, 3, 2, 2])
    fila("ContFondoB", -13.0, 21.6, 0.0, 4, LARGO_C + 0.5, [2, 2, 3, 2], salto=2)
    # Derecha: dos hileras de contenedores de punta (la plaza llega a x = 20).
    fila("ContDerA", 24.5, -14.0, math.pi / 2, 5, LARGO_C + 0.5, [2, 3, 2, 3, 2], salto=1)
    fila("ContDerB", 28.0, -14.0, math.pi / 2, 5, LARGO_C + 0.5, [3, 2, 2, 2, 3], salto=4)
    # Un par de pilas sueltas adelante a la derecha, sobre la explanada.
    fila("ContFrente", 8.0, -19.5, 0.0, 2, LARGO_C + 0.6, [2, 3], salto=3)

    # Galpones al fondo a la derecha.
    galpon("Galpon1", (13.0, 28.0, 0.0), 11.0, 13.0, 5.4, edificios, giro=-math.pi / 2,
           puerta=True)
    galpon("Galpon2", (27.0, 28.0, 0.0), 10.0, 12.0, 5.0, edificios, giro=-math.pi / 2,
           puerta=True)

    # Grúas sobre el muelle, mirando al agua.
    # Las dos gruas van sobre el borde del muelle, una detras de la otra, sobre
    # rieles paralelos al borde y con el brazo apuntando al agua (-X).
    grua("Grua1", (-21.5, -2.0, 0.0), maquinas, giro=math.pi, escala=0.85)
    grua("Grua2", (-21.5, 15.0, 0.0), maquinas, giro=math.pi, escala=0.8)

    # Torre de reflectores atras.
    REFLECTORES += torre_reflector("Torre1", (26.0, 20.0, 0.0), maquinas, alto=9.0)
    REFLECTORES += torre_reflector("Torre2", (16.0, 20.0, 0.0), maquinas, alto=8.0)

    # Farolas alrededor de la plaza (version noche de la referencia).
    for pos, giro in (
        ((-14.0, -12.0), 0.0),
        ((-14.0, 10.0), 0.0),
        ((20.0, -12.0), math.pi),
        ((20.0, 12.0), math.pi),
        ((2.0, -17.0), math.pi / 2),
    ):
        _, lamp = farola("Farola", (pos[0], pos[1], 0.12), luces, giro=giro)
        FAROLAS.append(lamp)

    # Chatarra suelta: todo en el borde del muelle, como recien descargado.
    grupos = [
        (-19.5, -14.0), (-19.0, -10.5), (-19.5, 6.0), (-19.0, 9.5),
        (-19.5, 19.0), (-19.0, 21.5), (-24.0, -16.0), (-24.5, 11.0),
    ]
    for i, (x, y) in enumerate(grupos):
        if i % 2 == 0:
            for k in range(3):
                barril("Barril", (x + random.uniform(-0.7, 0.7), y + random.uniform(-0.8, 0.8),
                                  0.56), chatarra, giro=random.uniform(0, 3.1))
        else:
            for k in range(2):
                lado = random.uniform(0.9, 1.3)
                cajon("Cajon", (x + random.uniform(-0.8, 0.8), y + random.uniform(-0.9, 0.9),
                                lado / 2 + 0.12), lado, chatarra, giro=random.uniform(0, 1.5))
    # Fila prolija de barriles contra el borde, como en la referencia.
    for i in range(7):
        barril("BarrilFila", (-25.3 + (i % 2) * 0.72, -12.0 + i * 4.6, 0.56), chatarra,
               giro=random.uniform(0, 3.1))

    # Un par de cajones apilados en el muelle.
    cajon("CajonAlto", (-24.0, 2.0, 0.62), 1.1, chatarra, giro=0.3)
    cajon("CajonAlto2", (-24.0, 2.0, 1.75), 1.0, chatarra, giro=0.8)
    return True


def poner_camara(nombre="CamRef"):
    """Camara del angulo de la referencia: alto, mirando a la plaza desde el agua."""
    cam = bpy.data.objects.get(nombre)
    if cam:
        bpy.data.objects.remove(cam, do_unlink=True)
    bpy.ops.object.camera_add(location=(-58.0, -50.0, 22.0))
    cam = bpy.context.active_object
    cam.name = nombre
    cam.data.lens = 42
    cam.data.sensor_width = 36
    # Apuntar al centro de la plaza (to_track_quat es la forma segura).
    import mathutils

    objetivo = mathutils.Vector((4.0, 10.0, 6.5))
    direccion = objetivo - cam.location
    cam.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam
    return cam


def camara_juego(nombre="CamJuego", pos_personaje=(3.0, -2.0), giro=0.6):
    """Camara como la del juego: detras del personaje, a 8 studs (2,24 m) y a la
    altura de la cabeza. Deja un personaje de prueba para que se vea la escala."""
    alto = 1.6
    px, py = pos_personaje
    viejo = bpy.data.objects.get("PersonajePrueba")
    if viejo:
        bpy.data.objects.remove(viejo, do_unlink=True)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.3, depth=alto, location=(px, py, alto / 2),
                                        vertices=16)
    cuerpo = bpy.context.active_object
    cuerpo.name = "PersonajePrueba"
    m = bpy.data.materials.get("MAT_Personaje")
    if not m:
        m = bpy.data.materials.new("MAT_Personaje")
        m.use_nodes = True
        b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
        b.inputs["Base Color"].default_value = (0.12, 0.14, 0.2, 1)
        b.inputs["Roughness"].default_value = 0.6
    cuerpo.data.materials.append(m)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.28, location=(px, py, alto + 0.22),
                                         segments=20, ring_count=12)
    cabeza = bpy.context.active_object
    cabeza.name = "PersonajePruebaCabeza"
    cabeza.data.materials.append(m)
    meter(cuerpo, coleccion("Luces"))
    meter(cabeza, coleccion("Luces"))

    cam = bpy.data.objects.get(nombre)
    if cam:
        bpy.data.objects.remove(cam, do_unlink=True)
    dist = 8 * 0.28  # 8 studs
    cx = px - math.cos(giro) * dist
    cy = py - math.sin(giro) * dist
    bpy.ops.object.camera_add(location=(cx, cy, alto + 0.55))
    cam = bpy.context.active_object
    cam.name = nombre
    cam.data.lens = 24  # el FOV de Roblox (70 grados) es mas abierto que el de cine
    objetivo = mathutils.Vector((px + math.cos(giro) * 14, py + math.sin(giro) * 14, alto + 0.2))
    d = objetivo - cam.location
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam
    return cam


def _mundo(color_cielo, fuerza, niebla=None):
    mundo = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = mundo
    mundo.use_nodes = True
    nt = mundo.node_tree
    for nd in list(nt.nodes):
        if nd.type not in ("OUTPUT_WORLD",):
            nt.nodes.remove(nd)
    salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_WORLD")
    fondo = nt.nodes.new("ShaderNodeBackground")
    fondo.inputs[0].default_value = color_cielo
    fondo.inputs[1].default_value = fuerza
    # Degradado: mas claro en el horizonte.
    grad = nt.nodes.new("ShaderNodeTexGradient")
    grad.gradient_type = "LINEAR"
    nt.links.new(fondo.outputs[0], salida.inputs["Surface"])
    if niebla:
        # OJO: un volumen en el World se extiende al infinito y se come el sol.
        # La niebla va en una caja que envuelve la escena.
        niebla_caja(niebla[0], niebla[1])
    else:
        viejo = bpy.data.objects.get("NieblaCaja")
        if viejo:
            bpy.data.objects.remove(viejo, do_unlink=True)
    return mundo


def niebla_caja(color, densidad, tam=(900, 900, 220)):
    """Niebla de verdad: una caja grande con Principled Volume alrededor de todo."""
    viejo = bpy.data.objects.get("NieblaCaja")
    if viejo:
        bpy.data.objects.remove(viejo, do_unlink=True)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, tam[2] / 2 - 20))
    ob = bpy.context.active_object
    ob.name = "NieblaCaja"
    ob.scale = tam
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    ob.visible_shadow = False
    m = bpy.data.materials.get("MAT_Niebla")
    if m:
        bpy.data.materials.remove(m)
    m = bpy.data.materials.new("MAT_Niebla")
    m.use_nodes = True
    nt = m.node_tree
    for nd in list(nt.nodes):
        if nd.type != "OUTPUT_MATERIAL":
            nt.nodes.remove(nd)
    salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_MATERIAL")
    vol = nt.nodes.new("ShaderNodeVolumePrincipled")
    vol.inputs["Color"].default_value = color
    vol.inputs["Density"].default_value = densidad
    if "Anisotropy" in vol.inputs:
        vol.inputs["Anisotropy"].default_value = 0.35
    nt.links.new(vol.outputs[0], salida.inputs["Volume"])
    ob.data.materials.append(m)
    meter(ob, coleccion("Luces"))
    return ob


def _sol(nombre, color, fuerza, altura_grados, giro_grados, angulo=2.5):
    viejo = bpy.data.objects.get(nombre)
    if viejo:
        bpy.data.objects.remove(viejo, do_unlink=True)
    bpy.ops.object.light_add(type="SUN", location=(0, 0, 40))
    sol = bpy.context.active_object
    sol.name = nombre
    sol.data.energy = fuerza
    sol.data.color = color
    sol.data.angle = math.radians(angulo)
    sol.rotation_euler = (
        math.radians(90 - altura_grados),
        0,
        math.radians(giro_grados),
    )
    return sol


def _borrar_luces_puntuales():
    for ob in list(bpy.data.objects):
        if ob.type == "LIGHT" and ob.data.type in ("POINT", "SPOT", "AREA"):
            bpy.data.objects.remove(ob, do_unlink=True)


def _lampara(nombre, pos, color, fuerza, radio=0.25):
    bpy.ops.object.light_add(type="POINT", location=pos)
    luz = bpy.context.active_object
    luz.name = nombre
    luz.data.energy = fuerza
    luz.data.color = color
    luz.data.shadow_soft_size = radio
    col = coleccion("Luces")
    meter(luz, col)
    return luz


def cielo_degradado(elevacion, giro, colores=None, fuerza=1.0, sol_visible=True):
    """Cielo pintado en degrade (nada de franja plana): naranja cerca del horizonte,
    mas claro y rosado arriba, azul en el cenit. El sol es una esfera lejana que
    ademas se refleja en el agua."""
    mundo = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = mundo
    mundo.use_nodes = True
    nt = mundo.node_tree
    for nd in list(nt.nodes):
        if nd.type != "OUTPUT_WORLD":
            nt.nodes.remove(nd)
    salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_WORLD")

    coord = nt.nodes.new("ShaderNodeTexCoord")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(coord.outputs["Generated"], sep.inputs["Vector"])
    # Generated va de 0 a 1; el horizonte queda en 0,5.
    rampa = nt.nodes.new("ShaderNodeValToRGB")
    puntos = colores or [
        (0.30, (0.42, 0.20, 0.12)),   # abajo del horizonte
        (0.498, (1.00, 0.52, 0.20)),  # justo en el horizonte: naranja fuerte
        (0.540, (1.00, 0.62, 0.40)),
        (0.610, (0.92, 0.60, 0.58)),  # rosado
        (0.730, (0.60, 0.50, 0.66)),
        (1.000, (0.26, 0.33, 0.56)),  # cenit azul
    ]
    r = rampa.color_ramp
    while len(r.elements) > 1:
        r.elements.remove(r.elements[-1])
    for i, (pos, col) in enumerate(puntos):
        el = r.elements[0] if i == 0 else r.elements.new(pos)
        el.position = pos
        el.color = (col[0], col[1], col[2], 1.0)
    medio = nt.nodes.new("ShaderNodeMath")
    medio.operation = "MULTIPLY_ADD"
    medio.inputs[1].default_value = 0.5
    medio.inputs[2].default_value = 0.5
    nt.links.new(sep.outputs["Z"], medio.inputs[0])
    nt.links.new(medio.outputs["Value"], rampa.inputs["Fac"])

    fondo = nt.nodes.new("ShaderNodeBackground")
    fondo.inputs[1].default_value = fuerza
    nt.links.new(rampa.outputs["Color"], fondo.inputs["Color"])
    nt.links.new(fondo.outputs[0], salida.inputs["Surface"])

    # Sol visible: esfera emisiva lejana en la direccion del sol.
    viejo = bpy.data.objects.get("SolEsfera")
    if viejo:
        bpy.data.objects.remove(viejo, do_unlink=True)
    if sol_visible:
        acimut = math.radians(giro - 90.0)
        alt = math.radians(elevacion)
        d = 1400.0
        pos = (
            math.cos(acimut) * math.cos(alt) * d,
            math.sin(acimut) * math.cos(alt) * d,
            math.sin(alt) * d,
        )
        bpy.ops.mesh.primitive_uv_sphere_add(radius=34, location=pos, segments=32, ring_count=16)
        esfera = bpy.context.active_object
        esfera.name = "SolEsfera"
        bpy.ops.object.shade_smooth()
        esfera.visible_shadow = False
        m = bpy.data.materials.get("MAT_SolEsfera")
        if m:
            bpy.data.materials.remove(m)
        m = bpy.data.materials.new("MAT_SolEsfera")
        m.use_nodes = True
        nt2 = m.node_tree
        for nd in list(nt2.nodes):
            if nd.type != "OUTPUT_MATERIAL":
                nt2.nodes.remove(nd)
        em = nt2.nodes.new("ShaderNodeEmission")
        em.inputs[0].default_value = (1.0, 0.72, 0.42, 1)
        em.inputs[1].default_value = 90.0
        sal = next(nd for nd in nt2.nodes if nd.type == "OUTPUT_MATERIAL")
        nt2.links.new(em.outputs[0], sal.inputs["Surface"])
        esfera.data.materials.append(m)
        meter(esfera, coleccion("Luces"))
    return mundo


def cielo_nishita(elevacion, giro, polvo=2.2, fuerza=1.0):
    """Cielo fisico: da el degrade del atardecer y el sol sobre el agua."""
    mundo = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = mundo
    mundo.use_nodes = True
    nt = mundo.node_tree
    for nd in list(nt.nodes):
        if nd.type != "OUTPUT_WORLD":
            nt.nodes.remove(nd)
    salida = next(nd for nd in nt.nodes if nd.type == "OUTPUT_WORLD")
    fondo = nt.nodes.new("ShaderNodeBackground")
    fondo.inputs[1].default_value = fuerza
    cielo = nt.nodes.new("ShaderNodeTexSky")
    cielo.sky_type = "MULTIPLE_SCATTERING"
    cielo.sun_elevation = math.radians(elevacion)
    cielo.sun_rotation = math.radians(giro)
    for campo, valor in (
        ("dust_density", polvo),
        ("sun_disc", True),
        ("sun_intensity", 2.5),
        ("air_density", 1.4),
        ("altitude", 20.0),
    ):
        if hasattr(cielo, campo):
            setattr(cielo, campo, valor)
    nt.links.new(cielo.outputs[0], fondo.inputs[0])
    nt.links.new(fondo.outputs[0], salida.inputs["Surface"])
    return mundo


def luz_atardecer():
    """Version 1 de la referencia: sol bajo y naranja sobre el agua."""
    _borrar_luces_puntuales()
    ob = bpy.data.objects.get("SolNoche")
    if ob:
        bpy.data.objects.remove(ob, do_unlink=True)
    _sol("SolAtardecer", (1.0, 0.56, 0.30), 8.0, 10.0, 138.0, angulo=1.2)
    cielo_degradado(elevacion=5.5, giro=138.0, fuerza=1.7)
    niebla_caja((1.0, 0.72, 0.48, 1), 0.00035)
    bpy.context.scene.view_settings.view_transform = "Standard"
    return True


def luz_noche():
    """Version 4 de la referencia: azul oscuro, niebla y farolas naranjas."""
    _borrar_luces_puntuales()
    ob = bpy.data.objects.get("SolAtardecer")
    if ob:
        bpy.data.objects.remove(ob, do_unlink=True)
    _sol("SolNoche", (0.42, 0.56, 1.0), 0.35, 34.0, 120.0, angulo=8.0)
    _mundo((0.055, 0.090, 0.17, 1), 1.8, niebla=((0.165, 0.208, 0.314, 1), 0.0020))
    for i, pos in enumerate(FAROLAS):
        _lampara("LuzFarola%d" % i, pos, (1.0, 0.33, 0.04), 1300.0, radio=0.45)
    for i, pos in enumerate(REFLECTORES):
        _lampara("LuzReflector%d" % i, pos, (0.80, 0.88, 1.0), 2400.0, radio=0.5)
    # Ventanas de galpon encendidas.
    for i, pos in enumerate(VENTANAS):
        _lampara("LuzVentana%d" % i, pos, (1.0, 0.60, 0.26), 700.0, radio=0.6)
    for i, pos in enumerate(CABINAS):
        _lampara("LuzCabina%d" % i, pos, (1.0, 0.66, 0.32), 220.0, radio=0.4)
    for i, pos in enumerate(PUNTAS):
        _lampara("LuzPunta%d" % i, pos, (1.0, 0.15, 0.10), 160.0, radio=0.3)
    esc = bpy.context.scene
    esc.view_settings.view_transform = "Standard"
    return True


def ajustes_render(muestras=96, ancho=1280, alto=720):
    esc = bpy.context.scene
    esc.render.engine = "CYCLES"
    try:
        esc.cycles.device = "GPU"
    except Exception:
        pass
    esc.cycles.samples = muestras
    esc.cycles.use_denoising = True
    esc.cycles.volume_step_rate = 4.0
    esc.cycles.volume_max_steps = 256
    esc.render.resolution_x = ancho
    esc.render.resolution_y = alto
    esc.render.resolution_percentage = 100
    esc.render.image_settings.file_format = "PNG"
    return True
