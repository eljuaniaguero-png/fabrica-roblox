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
        contenedor(
            "%s_%d" % (nombre, i),
            (centro[0] + random.uniform(-0.12, 0.12), centro[1] + random.uniform(-0.12, 0.12), z),
            giro + random.uniform(-0.03, 0.03),
            tono,
            col,
        )


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
        em.inputs[0].default_value = (1.0, 0.62, 0.26, 1)
        em.inputs[1].default_value = 28.0
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
                     mat("MAT_MetalPiso"), col, giro=giro, bisel=0.01)
        emparentar(hueco, paredes)
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
    """Grua de puerto como la de la referencia: patas de celosia, casa de maquinas,
    cabina colgada, pluma y contrapluma de celosia con tirantes, y contrapeso."""
    m = mat("MAT_MetalPiso")
    e = escala
    cx, cy, cz = centro
    co, si = math.cos(giro), math.sin(giro)

    def local(dx, dy, dz):
        return (cx + dx * co - dy * si, cy + dx * si + dy * co, cz + dz)

    piezas = []
    sep = 3.4 * e
    alto_pata = 8.0 * e
    # Patas de celosia inclinadas hacia adentro.
    for sx in (-1, 1):
        for sy in (-1, 1):
            p0 = local(sx * sep, sy * sep, 0.25)
            p1 = local(sx * 1.1 * e, sy * 1.1 * e, alto_pata)
            piezas += celosia(nombre + "_Pata", p0, p1, 0.17 * e, m, col, pasos=5)
            piezas.append(
                caja(nombre + "_Zapata", local(sx * sep, sy * sep, 0.2),
                     (1.4 * e, 1.4 * e, 0.4), mat("MAT_CementoMojado"), col, giro=giro)
            )
    # Anillos horizontales entre patas.
    for z in (0.34, 0.66):
        h = alto_pata * z
        d = sep - (sep - 1.1 * e) * z
        esq = [local(-d, -d, h), local(d, -d, h), local(d, d, h), local(-d, d, h)]
        for i in range(4):
            piezas.append(viga(nombre + "_Anillo", esq[i], esq[(i + 1) % 4], 0.12 * e, m, col))
            medio = tuple((esq[i][k] + esq[(i + 1) % 4][k]) / 2 for k in range(3))
            arriba = (medio[0], medio[1], medio[2] + alto_pata * 0.16)
            piezas.append(viga(nombre + "_V", esq[i], arriba, 0.09 * e, m, col))
            piezas.append(viga(nombre + "_V", esq[(i + 1) % 4], arriba, 0.09 * e, m, col))
    # Plataforma, casa de maquinas y cabina.
    piezas.append(
        caja(nombre + "_Plataforma", local(0, 0, alto_pata + 0.35),
             (5.6 * e, 5.0 * e, 0.6), m, col, giro=giro)
    )
    casa = caja(nombre + "_Casa", local(-1.6 * e, 0, alto_pata + 2.2),
                (4.2 * e, 3.8 * e, 3.0 * e), m, col, giro=giro)
    piezas.append(casa)
    piezas.append(
        caja(nombre + "_Techo", local(-1.6 * e, 0, alto_pata + 3.8),
             (4.4 * e, 4.0 * e, 0.2), m, col, giro=giro)
    )
    cabina = caja(nombre + "_Cabina", local(2.4 * e, -1.9 * e, alto_pata + 1.5),
                  (1.8 * e, 1.5 * e, 1.9 * e), m, col, giro=giro)
    piezas.append(cabina)
    vidrio_cabina = caja(nombre + "_CabinaVidrio",
                         local(3.2 * e, -1.9 * e, alto_pata + 1.7),
                         (0.12, 1.2 * e, 1.1 * e), m, col, giro=giro, bisel=0.01)
    piezas.append(vidrio_cabina)
    # Mastil, pluma y contrapluma, todo de celosia.
    raiz = local(0.8 * e, 0, alto_pata + 1.2)
    punta_mastil = local(-0.6 * e, 0, alto_pata + 9.0 * e)
    punta_pluma = local(13.0 * e, 0, alto_pata + 8.2 * e)
    cola = local(-5.6 * e, 0, alto_pata + 2.6 * e)
    piezas += celosia(nombre + "_Mastil", raiz, punta_mastil, 0.15 * e, m, col,
                      separacion=0.42 * e, pasos=6)
    piezas += celosia(nombre + "_Pluma", raiz, punta_pluma, 0.15 * e, m, col,
                      separacion=0.5 * e, pasos=9)
    piezas += celosia(nombre + "_Cola", raiz, cola, 0.13 * e, m, col,
                      separacion=0.4 * e, pasos=4)
    piezas.append(viga(nombre + "_Tirante1", punta_mastil, punta_pluma, 0.1 * e, m, col))
    piezas.append(viga(nombre + "_Tirante2", punta_mastil, cola, 0.1 * e, m, col))
    # Contrapeso macizo.
    piezas.append(
        caja(nombre + "_Contrapeso", local(-5.6 * e, 0, alto_pata + 1.5 * e),
             (3.2 * e, 3.0 * e, 2.2 * e), m, col, giro=giro)
    )
    # Cable y gancho.
    gancho_z = cz + 2.8 * e
    piezas.append(
        viga(nombre + "_Cable", punta_pluma, (punta_pluma[0], punta_pluma[1], gancho_z),
             0.05 * e, m, col)
    )
    piezas.append(
        caja(nombre + "_Gancho", (punta_pluma[0], punta_pluma[1], gancho_z - 0.55 * e),
             (0.7 * e, 0.7 * e, 1.1 * e), m, col, giro=giro)
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


def armar_arena():
    global FAROLAS, REFLECTORES
    FAROLAS, REFLECTORES = [], []
    limpiar()
    piso = coleccion("Piso")
    carga = coleccion("Carga")
    edificios = coleccion("Edificios")
    maquinas = coleccion("Maquinas")
    luces = coleccion("Luces")
    chatarra = coleccion("Chatarra")

    # Agua: plano grande y oscuro.
    bpy.ops.mesh.primitive_plane_add(size=400, location=(0, 0, -1.6))
    agua = bpy.context.active_object
    agua.name = "Agua"
    m_agua = bpy.data.materials.new("MAT_Agua")
    m_agua.use_nodes = True
    bsdf = next(n for n in m_agua.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (0.012, 0.022, 0.035, 1)
    bsdf.inputs["Roughness"].default_value = 0.03
    if "Metallic" in bsdf.inputs:
        bsdf.inputs["Metallic"].default_value = 0.0
    agua.data.materials.append(m_agua)
    meter(agua, piso)
    # Olas chiquitas.
    mod = agua.modifiers.new("Olas", "DISPLACE")
    tex = bpy.data.textures.new("OlasTex", "CLOUDS")
    tex.noise_scale = 1.6
    mod.texture = tex
    mod.strength = 0.08
    sub = agua.modifiers.new("Sub", "SUBSURF")
    sub.levels = 0
    sub.render_levels = 2

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
    fondo_y = 16.0
    for i, x in enumerate(range(-12, 4, 7)):
        pila_contenedores(
            "ContFondo%d" % i,
            (x, fondo_y, 1.3),
            0.0,
            [TONOS_CONTENEDOR[(i * 2 + k) % len(TONOS_CONTENEDOR)] for k in range(2)],
            2.62,
            carga,
        )
    # Muralla de contenedores a la derecha, de a dos en fondo y de 2 o 3 de alto.
    for i, y in enumerate(range(-17, 13, 6)):
        for j, x in enumerate((24.0, 30.0)):
            pila_contenedores(
                "ContDer%d_%d" % (i, j),
                (x, y, 1.3),
                math.pi / 2,
                [
                    TONOS_CONTENEDOR[(i * 3 + j * 2 + k) % len(TONOS_CONTENEDOR)]
                    for k in range(2 + ((i + j) % 2))
                ],
                2.62,
                carga,
            )
    # Pilas sueltas adelante a la derecha, como en la referencia.
    pila_contenedores("ContFrente1", (17.0, -19.0, 1.3), 0.15,
                      [TONOS_CONTENEDOR[1], TONOS_CONTENEDOR[3], TONOS_CONTENEDOR[0]], 2.62, carga)
    pila_contenedores("ContFrente2", (9.0, -20.0, 1.3), -0.1,
                      [TONOS_CONTENEDOR[2], TONOS_CONTENEDOR[5]], 2.62, carga)

    # Galpones al fondo a la derecha.
    galpon("Galpon1", (13.0, 28.0, 0.0), 11.0, 13.0, 5.4, edificios, giro=-math.pi / 2,
           puerta=True)
    galpon("Galpon2", (27.0, 28.0, 0.0), 10.0, 12.0, 5.0, edificios, giro=-math.pi / 2,
           puerta=True)

    # Grúas sobre el muelle, mirando al agua.
    grua("Grua1", (-14.0, 1.0, 0.0), maquinas, giro=math.pi * 1.06, escala=1.0)
    grua("Grua2", (-13.0, 21.0, 0.0), maquinas, giro=math.pi * 0.97, escala=0.9)

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

    # Chatarra suelta: barriles y cajones en los bordes.
    grupos = [
        (-21.0, -13.0), (-20.0, -10.0), (-22.5, 12.0), (-21.0, 15.0),
        (13.0, 14.0), (16.0, 13.0), (-8.0, -16.0), (-5.0, -17.0),
        (19.0, -6.0), (18.5, 2.0),
    ]
    for i, (x, y) in enumerate(grupos):
        if i % 2 == 0:
            for k in range(3):
                barril("Barril", (x + random.uniform(-0.9, 0.9), y + random.uniform(-0.9, 0.9),
                                  0.56), chatarra, giro=random.uniform(0, 3.1))
        else:
            for k in range(2):
                lado = random.uniform(0.9, 1.3)
                cajon("Cajon", (x + random.uniform(-1.0, 1.0), y + random.uniform(-1.0, 1.0),
                                lado / 2 + 0.12), lado, chatarra, giro=random.uniform(0, 1.5))
    # Fila de barriles y cajones contra el borde del muelle, como en la referencia.
    for i in range(8):
        barril("BarrilFila", (-25.5 + (i % 2) * 0.75, -16.0 + i * 4.2, 0.56), chatarra,
               giro=random.uniform(0, 3.1))
    for i in range(5):
        lado = 1.1
        cajon("CajonFila", (-23.0, -18.0 + i * 8.5, lado / 2 + 0.2), lado, chatarra,
              giro=random.uniform(0, 1.2))

    # Un par de cajones apilados.
    cajon("CajonAlto", (-19.5, -8.0, 0.62), 1.1, chatarra, giro=0.3)
    cajon("CajonAlto2", (-19.5, -8.0, 1.75), 1.0, chatarra, giro=0.8)
    return True


def poner_camara(nombre="CamRef"):
    """Camara del angulo de la referencia: alto, mirando a la plaza desde el agua."""
    cam = bpy.data.objects.get(nombre)
    if cam:
        bpy.data.objects.remove(cam, do_unlink=True)
    bpy.ops.object.camera_add(location=(-45.0, -41.0, 23.0))
    cam = bpy.context.active_object
    cam.name = nombre
    cam.data.lens = 36
    cam.data.sensor_width = 36
    # Apuntar al centro de la plaza (to_track_quat es la forma segura).
    import mathutils

    objetivo = mathutils.Vector((5.0, 6.0, 2.0))
    direccion = objetivo - cam.location
    cam.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
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


def niebla_caja(color, densidad, tam=(260, 260, 60)):
    """Niebla de verdad: una caja grande con Principled Volume alrededor de todo."""
    viejo = bpy.data.objects.get("NieblaCaja")
    if viejo:
        bpy.data.objects.remove(viejo, do_unlink=True)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, tam[2] / 2 - 6))
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
        ("sun_intensity", 1.4),
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
    _sol("SolAtardecer", (1.0, 0.58, 0.30), 4.5, 9.0, 212.0, angulo=3.0)
    cielo_nishita(elevacion=3.0, giro=212.0, polvo=4.0, fuerza=0.35)
    niebla_caja((1.0, 0.78, 0.58, 1), 0.00028)
    bpy.context.scene.view_settings.view_transform = "Standard"
    return True


def luz_noche():
    """Version 4 de la referencia: azul oscuro, niebla y farolas naranjas."""
    _borrar_luces_puntuales()
    ob = bpy.data.objects.get("SolAtardecer")
    if ob:
        bpy.data.objects.remove(ob, do_unlink=True)
    _sol("SolNoche", (0.42, 0.56, 1.0), 0.35, 34.0, 120.0, angulo=8.0)
    _mundo((0.05, 0.085, 0.16, 1), 1.0, niebla=((0.38, 0.50, 0.72, 1), 0.0022))
    for i, pos in enumerate(FAROLAS):
        _lampara("LuzFarola%d" % i, pos, (1.0, 0.58, 0.24), 2600.0, radio=0.16)
    for i, pos in enumerate(REFLECTORES):
        _lampara("LuzReflector%d" % i, pos, (0.84, 0.91, 1.0), 2600.0, radio=0.35)
    # Ventanas de galpon encendidas.
    for pos in ((13.0, 22.0, 2.8), (27.0, 22.0, 2.6)):
        _lampara("LuzGalpon", pos, (1.0, 0.72, 0.38), 700.0, radio=0.5)
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
