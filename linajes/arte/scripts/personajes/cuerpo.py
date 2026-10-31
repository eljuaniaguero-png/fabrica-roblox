"""Cuerpo propio de Linajes: el cuerpo que usan todos (jugadores, NPCs, enemigos) en vez del
avatar de Roblox. Nota en la bóveda: 01 Juego/Cuerpo propio (sin avatar de Roblox).md.

Mismo esqueleto R15 que el maniquí (no se mueve ningún hueso): una malla por parte, pegada a su
hueso. Las 3 contexturas son shape keys (Ancha: hombros +20 %; Delgada: hombros y cadera -12 %).

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/cuerpo.py -- boceto      (o detalle)

Paso "detalle": más resolución, cara con textura (caras.py), 12 peinados y hojas de render
(cuerpo_vistas, cuerpo_expresiones, cuerpo_caras, cuerpo_peinados, cuerpo_tonos, cuerpo_marcas).

Paso "boceto": cuerpo de bloques suaves, renders/cuerpo_boceto_vistas.png (maniquí y las 3
contexturas) y renders/cuerpo_boceto_cuervo.png (las 3 con el traje de Cuervo encima).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bmesh  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Cuerpo"
BLEND = os.path.join(B.BLENDER, "cuerpo.blend")
CUERVO = os.path.join(B.BLENDER, "cuervo.blend")

HOMBRO = 0.24  # media espalda en metros (ancho de hombros / 2)
ANCHA = 0.20  # hombros +20 %
DELGADA = 0.12  # hombros y cadera -12 %

# ---------------------------------------------------------------------------
# Formas
# ---------------------------------------------------------------------------


def _anillo(bm, centro, hx, hy, lados, ejes=None, e=0.8):
    """Anillo superelíptico (e < 1 = más cuadrado) en el plano de `ejes` (x, y)."""
    ex, ey = ejes or (Vector((1, 0, 0)), Vector((0, 1, 0)))
    verts = []
    for i in range(lados):
        a = 2 * math.pi * i / lados
        c, s = math.cos(a), math.sin(a)
        x = math.copysign(abs(c) ** e, c) * hx
        y = math.copysign(abs(s) ** e, s) * hy
        verts.append(bm.verts.new(Vector(centro) + ex * x + ey * y))
    return verts


def _coser(bm, anillos):
    for a, b in zip(anillos, anillos[1:]):
        n = len(a)
        for i in range(n):
            bm.faces.new((a[i], a[(i + 1) % n], b[(i + 1) % n], b[i]))
    for anillo, punta in ((anillos[0], True), (anillos[-1], False)):
        centro = sum((v.co for v in anillo), Vector()) / len(anillo)
        c = bm.verts.new(centro)
        n = len(anillo)
        for i in range(n):
            par = (anillo[(i + 1) % n], anillo[i]) if punta else (anillo[i], anillo[(i + 1) % n])
            bm.faces.new((c, *par))


def tronco(bm, perfil, lados=24):
    """Tubo vertical: `perfil` es una lista de (z, hx, hy, cy) de abajo hacia arriba."""
    _coser(bm, [_anillo(bm, (0, cy, z), hx, hy, lados) for z, hx, hy, cy in perfil])


def miembro(bm, desde, hasta, radios, lados=14, aplastar=1.0):
    """Tubo de `desde` a `hasta`; `radios` es una lista de (t, radio) con t de 0 a 1. Las puntas
    se cierran redondeadas. `aplastar` < 1 achata el tubo de adelante hacia atrás."""
    desde, hasta = Vector(desde), Vector(hasta)
    eje = (hasta - desde).normalized()
    ex = eje.cross(Vector((0, 1, 0)))
    ex = ex.normalized() if ex.length > 1e-4 else Vector((1, 0, 0))
    ey = eje.cross(ex).normalized()
    anillos = []
    for t, r in radios:
        p = desde.lerp(hasta, t)
        anillos.append(_anillo(bm, p, r, r * aplastar, lados, (ex, ey), e=1.0))
    _coser(bm, anillos)


def capsula(bm, desde, hasta, r0, r1, lados=14, aplastar=1.0, medio=None):
    """Miembro con las dos puntas redondeadas (r0 arriba, r1 abajo, `medio` = radio a la mitad)."""
    largo = (Vector(hasta) - Vector(desde)).length
    t0, t1 = min(r0, largo * 0.3) / largo, min(r1, largo * 0.3) / largo
    radios = [(t0 * (1 - math.sin(math.radians(g))), r0 * math.cos(math.radians(g))) for g in (70, 45, 20, 0)]
    if medio:
        radios.append((0.45, medio))
    radios += [(1 - t1 * (1 - math.sin(math.radians(g))), r1 * math.cos(math.radians(g))) for g in (0, 20, 45, 70)]
    miembro(bm, desde, hasta, radios, lados, aplastar)


# ---------------------------------------------------------------------------
# Partes: bloques redondeados como los de Roblox (pedido de Juani, 31 oct), sobre las cajas del
# maniquí, un poco más chicos para que los trajes que ya existen entren.
# ---------------------------------------------------------------------------

CABEZA_CENTRO = (0.0, 0.0, 1.370)
CABEZA_MITADES = (0.165, 0.150, 0.162)


def _lado(s):
    return 1 if s == "Left" else -1  # Left = +X (izquierda del personaje)


def _bloque(bm, parte, achicar=(0.97, 0.97, 1.0), redondez=0.18, seg=16, anillos=10, correr=(0, 0, 0)):
    _, _, centro, mitades = T.caja_parte(parte)
    m = Vector((mitades.x * achicar[0], mitades.y * achicar[1], mitades.z * achicar[2]))
    T.bloque_redondo(bm, centro + Vector(correr), m, redondez=redondez, segmentos=seg, anillos=anillos)


def armar_partes():
    """Devuelve {parte: (bmesh, material)}."""
    p = {}
    bm = bmesh.new()
    # Cabeza grande y cuadrada con la mandíbula redondeada (la cara va en la textura).
    T.bloque_redondo(bm, CABEZA_CENTRO, CABEZA_MITADES, redondez=0.32, segmentos=28, anillos=18)
    p["Head"] = (bm, "piel")
    bm = bmesh.new()
    _bloque(bm, "UpperTorso", (0.96, 0.92, 0.99))
    p["UpperTorso"] = (bm, "traje-base")
    bm = bmesh.new()
    _bloque(bm, "LowerTorso", (0.94, 0.90, 1.0), redondez=0.25)
    p["LowerTorso"] = (bm, "traje-base")
    for s in ("Left", "Right"):
        x = _lado(s)
        for nombre, ach in (("UpperArm", (0.92, 0.92, 1.0)), ("LowerArm", (0.88, 0.88, 1.0))):
            bm = bmesh.new()
            _bloque(bm, s + nombre, ach)
            p[s + nombre] = (bm, "traje-base")
        bm = bmesh.new()
        # Mano: bloque con los dedos juntos y el pulgar aparte, adelante y hacia adentro.
        _bloque(bm, s + "Hand", (0.86, 0.80, 1.25), redondez=0.3, seg=12, anillos=8, correr=(0, 0, -0.01))
        T.bloque_redondo(bm, (x * 0.330, -0.105, 0.640), (0.030, 0.026, 0.040), redondez=0.4, segmentos=8, anillos=6)
        p[s + "Hand"] = (bm, "piel")
        for nombre in ("UpperLeg", "LowerLeg"):
            bm = bmesh.new()
            _bloque(bm, s + nombre, (0.92, 0.92, 1.0))
            p[s + nombre] = (bm, "traje-base")
        bm = bmesh.new()
        _bloque(bm, s + "Foot", (0.94, 1.0, 1.0), redondez=0.25, seg=12, anillos=8)
        p[s + "Foot"] = (bm, "traje-base")
    return p


# ---------------------------------------------------------------------------
# Contexturas (shape keys). No se mueven huesos: se ensancha la malla y los brazos se corren.
# ---------------------------------------------------------------------------


def _suave(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)


def _deformar(parte, co, cual):
    """Posición del vértice `co` (mundo) en la contextura `cual` (Ancha o Delgada)."""
    x, y, z = co
    ancha = cual == "Ancha"
    if parte == "UpperTorso":
        w = _suave(0.80, 1.15, z)
        k = 1 + ANCHA * w if ancha else 1 - DELGADA * (0.6 + 0.4 * w)
        return Vector((x * k, y * (1.06 if ancha else 0.94), z))
    if parte == "LowerTorso":
        k = 1.06 if ancha else 1 - DELGADA
        return Vector((x * k, y * (1.04 if ancha else 0.94), z))
    if parte == "Head":
        return Vector(co)
    lado = 1 if x > 0 else -1
    if "Arm" in parte or "Hand" in parte:
        corre = 0.272 * (ANCHA if ancha else -DELGADA)
        grueso = (1.12 if ancha else 0.88) if "Hand" not in parte else 1.0
        eje_x = 0.412 * lado
        return Vector((eje_x + (x - eje_x) * grueso + lado * corre, y * grueso, z))
    corre = 0.012 if ancha else -0.016
    grueso = 1.0 if "Foot" in parte else (1.08 if ancha else 0.90)
    eje_x = 0.14 * lado
    return Vector((eje_x + (x - eje_x) * grueso + lado * corre, y * grueso, z))

def contexturas(obj, parte):
    obj.shape_key_add(name="Normal", from_mix=False)
    for cual in ("Ancha", "Delgada"):
        key = obj.shape_key_add(name=cual, from_mix=False)
        mundo = obj.matrix_world
        inversa = mundo.inverted()
        for v, kv in zip(obj.data.vertices, key.data):
            kv.co = inversa @ _deformar(parte, mundo @ v.co, cual)


def construir():
    piezas = []
    for parte, (bm, mat) in armar_partes().items():
        nombre = f"{NOMBRE}_{parte}"
        piezas.append(T.malla(nombre, bm, mat, parte, suave=60))
    bpy.context.view_layer.update()
    for o in piezas:
        contexturas(o, o.name.split("_", 1)[1])
    return piezas


# ---------------------------------------------------------------------------
# Hoja de comparación (copias quietas al lado, giradas en su lugar para cada vista)
# ---------------------------------------------------------------------------


def _copia(obj, figura, forma=None):
    """Copia horneada (con la contextura `forma`) de `obj`, colgada de la figura `figura`."""
    if forma and obj.data.shape_keys:
        for k in obj.data.shape_keys.key_blocks[1:]:
            k.value = 1.0 if k.name == forma else 0.0
    grafo = bpy.context.evaluated_depsgraph_get()
    grafo.update()
    me = bpy.data.meshes.new_from_object(obj.evaluated_get(grafo))
    nueva = bpy.data.objects.new(f"Comparar_{figura.name}_{obj.name}", me)
    bpy.context.scene.collection.objects.link(nueva)
    nueva.matrix_world = obj.matrix_world.copy()
    mundo = nueva.matrix_world.copy()
    nueva.parent = figura
    nueva.matrix_parent_inverse = figura.matrix_world.inverted()
    nueva.matrix_world = mundo
    if forma and obj.data.shape_keys:
        for k in obj.data.shape_keys.key_blocks[1:]:
            k.value = 0.0
    return nueva


def _figura(nombre, x):
    vacio = bpy.data.objects.new(f"Comparar_{nombre}", None)
    bpy.context.scene.collection.objects.link(vacio)
    return vacio, x


def _traer_cuervo():
    """Agrega las piezas de Cuervo (detalle v2, sin las copias de alto poligonaje)."""
    with bpy.data.libraries.load(CUERVO, link=False) as (desde, hacia):
        hacia.objects = [n for n in desde.objects if n.startswith("Cuervo_") and not n.endswith("_Alto")]
    temporal = bpy.data.collections.new("_CuervoTemporal")
    bpy.context.scene.collection.children.link(temporal)
    for o in hacia.objects:
        temporal.objects.link(o)
        if o.parent and o.parent.name not in temporal.objects:
            temporal.objects.link(o.parent)
    bpy.context.view_layer.update()
    return [o for o in hacia.objects if o.type == "MESH"], temporal


def _render_filas(nombre, figuras, alto_fila=760):
    """Una fila por vista (Frente, Costado, Espalda), con las figuras giradas en su lugar."""
    escena = bpy.context.scene
    objs = [c for f, _ in figuras for c in f.children]
    minimo, maximo = B.caja_de(objs)
    ancho = maximo.x - minimo.x + 0.5
    alto = maximo.z - minimo.z + 0.25
    datos = bpy.data.cameras.new("Hoja")
    datos.type = "ORTHO"
    cam = bpy.data.objects.new("Hoja", datos)
    escena.collection.objects.link(cam)
    centro = (minimo + maximo) / 2
    B._apuntar(cam, (centro.x, -10, centro.z), (centro.x, 0, centro.z))
    res = (int(alto_fila * ancho / alto), alto_fila)
    datos.ortho_scale = ancho
    datos.sensor_fit = "HORIZONTAL"
    antes = (escena.camera, escena.render.resolution_x, escena.render.resolution_y)
    escena.camera = cam
    escena.render.resolution_x, escena.render.resolution_y = res
    luces = [o for o in (bpy.data.objects.get(n) for n in ("LuzPrincipal", "LuzBorde", "LuzRelleno")) if o]
    originales = {o.name: o.matrix_world.copy() for o in luces}
    rutas = []
    try:
        for vista, grados in B.VISTAS.items():
            for f, _ in figuras:
                f.rotation_euler = (0, 0, math.radians(grados))
            for o in luces:
                o.matrix_world = Matrix.Rotation(math.radians(grados), 4, "Z") @ originales[o.name]
            ruta = os.path.join(B.RENDERS, f"_{nombre}_{vista}.png")
            escena.render.filepath = ruta
            bpy.ops.render.render(write_still=True)
            rutas.append([ruta])
    finally:
        for f, _ in figuras:
            f.rotation_euler = (0, 0, 0)
        for o in luces:
            o.matrix_world = originales[o.name]
        escena.camera, escena.render.resolution_x, escena.render.resolution_y = antes
        bpy.data.objects.remove(cam)
        bpy.data.cameras.remove(datos)
    final = B.hoja(rutas, os.path.join(B.RENDERS, f"{nombre}.png"))
    for (r,) in rutas:
        os.remove(r)
    return final


def _limpiar_comparacion():
    for o in list(bpy.data.objects):
        if o.name.startswith("Comparar_"):
            bpy.data.objects.remove(o)


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = construir()
    cuenta = B.contar_triangulos(piezas)
    print("Triángulos:", cuenta)

    paso = 1.25
    maniqui = B.partes()
    # Hoja 1: maniquí | Normal | Ancha | Delgada
    figuras = []
    for i, (titulo, forma) in enumerate((("Maniqui", None), ("Normal", "Normal"), ("Ancha", "Ancha"), ("Delgada", "Delgada"))):
        f, x = _figura(titulo, i * paso)
        f.location = (x, 0, 0)
        bpy.context.view_layer.update()
        for o in maniqui if forma is None else piezas:
            c = _copia(o, f, forma)
            c.matrix_world = Matrix.Translation((x, 0, 0)) @ o.matrix_world
        figuras.append((f, x))
    originales = maniqui + piezas
    for o in originales:
        o.hide_render = True
    hoja1 = _render_filas("cuerpo_boceto_vistas", figuras)
    _limpiar_comparacion()

    # Hoja 2: las 3 contexturas con Cuervo encima (el traje no se deforma: así se ve dónde roza).
    cuervo, temporal = _traer_cuervo()
    figuras = []
    for i, forma in enumerate(("Normal", "Ancha", "Delgada")):
        f, x = _figura(f"Cuervo{forma}", i * 1.9)
        f.location = (x, 0, 0)
        bpy.context.view_layer.update()
        for o in piezas + cuervo:
            c = _copia(o, f, forma if o in piezas else None)
            c.matrix_world = Matrix.Translation((x, 0, 0)) @ o.matrix_world
        figuras.append((f, x))
    for o in cuervo:
        o.hide_render = True
    hoja2 = _render_filas("cuerpo_boceto_cuervo", figuras)
    _limpiar_comparacion()
    for o in list(temporal.objects):
        bpy.data.objects.remove(o)
    bpy.data.collections.remove(temporal)

    # En el .blend queda el cuerpo Normal sobre el esqueleto; el maniquí no sale en el render.
    for o in piezas:
        o.hide_render = False
    for o in maniqui:
        o.hide_render = True
        o.hide_set(True)
    bpy.ops.outliner.orphans_purge(do_recursive=True)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.render_vistas("cuerpo_boceto_solo", piezas)
    print("Hojas:", hoja1, hoja2)
    return piezas


# ---------------------------------------------------------------------------
# Detalle: cara con textura, peinados, tonos de piel y marcas
# ---------------------------------------------------------------------------

CARAS = os.path.join(B.EXPORTS, "cuerpo", "caras")
MARCAS = os.path.join(B.EXPORTS, "cuerpo", "marcas")
Z_ARRIBA, Z_ABAJO = 1.535, 1.205  # igual que caras.py
MEDIO_ANCHO = 0.18  # la textura cubre x de -0,18 a 0,18 (igual que caras.py)
EXPRESIONES = ["neutral", "enojado", "contento", "sorprendido", "dolor", "concentrado", "cansado", "derrotado"]

# Los mismos 10 tonos que Config.luau (Cuerpo.TonosPiel), de claro a oscuro.
TONOS = ["f6d7c3", "eac0a0", "d9a382", "c68a62", "b0744e", "96603f", "7d4f33", "653e28", "4e2f1f", "3a2318"]
COLORES_PELO = ["1c1714", "3a2a20", "6b4426", "a8743a", "d8b878", "8a2c1c", "e8e4dc", "2f6fdb", "6b5ba8", "c2213a", "3fc1b0", "f2652b"]


def uv_cabeza(obj):
    """Proyección de frente: la cara de adelante ocupa la textura; lo de atrás y los costados va
    a una esquina (transparente)."""
    me = obj.data
    capa = me.uv_layers.get("UVMap") or me.uv_layers.new(name="UVMap")
    mundo = obj.matrix_world
    giro = mundo.to_3x3()
    for poli in me.polygons:
        normal = (giro @ poli.normal).normalized()
        for li in poli.loop_indices:
            if normal.y > -0.25:
                capa.data[li].uv = (0.001, 0.001)
                continue
            co = mundo @ me.vertices[me.loops[li].vertex_index].co
            u = 0.5 + co.x / (2 * MEDIO_ANCHO)
            v = (co.z - Z_ABAJO) / (Z_ARRIBA - Z_ABAJO)
            capa.data[li].uv = (min(0.999, max(0.001, u)), min(0.999, max(0.001, v)))


def uv_simple(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(island_margin=0.02)
    bpy.ops.object.mode_set(mode="OBJECT")


def mat_piel(nombre, tono, capas=()):
    """Piel del tono `tono` con las texturas `capas` (cara, marca) encima, en orden."""
    mat = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    mat.use_nodes = True
    nodos, enlaces = mat.node_tree.nodes, mat.node_tree.links
    for n in list(nodos):
        if n.type not in ("BSDF_PRINCIPLED", "OUTPUT_MATERIAL"):
            nodos.remove(n)
    bsdf = nodos["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.6
    salida = None
    color = B.color(tono)
    for ruta in capas:
        img = bpy.data.images.load(ruta, check_existing=True)
        tex = nodos.new("ShaderNodeTexImage")
        tex.image = img
        tex.interpolation = "Cubic"
        mezcla = nodos.new("ShaderNodeMix")
        mezcla.data_type = "RGBA"
        enlaces.new(tex.outputs["Alpha"], mezcla.inputs["Factor"])
        if salida:
            enlaces.new(salida, mezcla.inputs[6])
        else:
            mezcla.inputs[6].default_value = color
        enlaces.new(tex.outputs["Color"], mezcla.inputs[7])
        salida = mezcla.outputs[2]
    if salida:
        enlaces.new(salida, bsdf.inputs["Base Color"])
    else:
        bsdf.inputs["Base Color"].default_value = color
    mat.diffuse_color = color
    return mat


def mat_pelo(nombre, tono):
    mat = B.material("pelo").copy()
    mat.name = nombre
    mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = B.color(tono)
    return mat


def cara(n, gesto="neutral"):
    return os.path.join(CARAS, f"cara_{n:02d}_{gesto}.png")


# --- Peinados -------------------------------------------------------------

CENTRO = Vector((0, 0, 1.370))
RADIOS = Vector((0.165, 0.150, 0.162))
CRANEO = None  # BVH de la cabeza (detalle() lo arma): el pelo se apoya sobre la forma real


def _radio_craneo(d):
    """Distancia de CENTRO a la superficie de la cabeza en la dirección `d`."""
    if CRANEO is None:
        return Vector((d.x * RADIOS.x, d.y * RADIOS.y, d.z * RADIOS.z)).length
    hit = CRANEO.ray_cast(CENTRO + d * 0.5, -d)[0]
    return (hit - CENTRO).length if hit else Vector((d.x * RADIOS.x, d.y * RADIOS.y, d.z * RADIOS.z)).length


def casquete(bm, frente, atras, grosor, lados, anillos, bulto=None):
    """Casco de pelo sobre el cráneo: llega hasta `frente` (z en la frente) y `atras` (z en la
    nuca). El borde se dobla hacia adentro de la cabeza para que no se vea el filo."""
    anillo_previo = None
    filas = []
    for j in range(1, anillos + 1):
        t = j / anillos
        fila = []
        for i in range(lados):
            th = 2 * math.pi * i / lados
            a = abs(math.atan2(math.sin(th), math.cos(th)))
            borde = frente + (atras - frente) * _suave(0.88, 1.10, a)  # derecho en la frente, baja por los costados
            fi_max = math.acos(max(-1.0, min(1.0, (borde - CENTRO.z) / RADIOS.z)))
            fi = t * fi_max
            d = Vector((math.sin(fi) * math.sin(th), -math.sin(fi) * math.cos(th), math.cos(fi)))
            extra = 0.006 + grosor + (bulto(th, fi) if bulto else 0.0)
            fila.append(bm.verts.new(CENTRO + d * (_radio_craneo(d) + extra)))
        filas.append(fila)
    arriba = Vector((0, 0, 1))
    tope = bm.verts.new(CENTRO + arriba * (_radio_craneo(arriba) + 0.006 + grosor + (bulto(0, 0) if bulto else 0.0)))
    for i in range(lados):
        bm.faces.new((tope, filas[0][i], filas[0][(i + 1) % lados]))
    adentro = [bm.verts.new(CENTRO + (v.co - CENTRO) * 0.93) for v in filas[-1]]
    for a, b in zip(filas, filas[1:] + [adentro]):
        for i in range(lados):
            bm.faces.new((a[i], b[i], b[(i + 1) % lados], a[(i + 1) % lados]))
    del anillo_previo


def _bola(bm, centro, r, seg=10, anillos=7):
    T.bloque_redondo(bm, centro, (r, r, r), redondez=1.0, segmentos=seg, anillos=anillos)


def _punta(bm, base, hacia, radio, lados=6, achatar=1.0):
    verts = T.punta(bm, base, hacia, radio, lados)
    if achatar != 1.0:
        c = Vector(base)
        for v in verts:
            v.co.x = c.x + (v.co.x - c.x) * achatar


def _sobre_craneo(th, fi, extra=0.0):
    d = Vector((math.sin(fi) * math.sin(th), -math.sin(fi) * math.cos(th), math.cos(fi)))
    return CENTRO + d * (_radio_craneo(d) + extra), d


def _mechon(bm, th, fi, largo, ancho, caida, abre=0.35, grosor=0.35, curva=0.4):
    """Mechón en punta (pirámide achatada de 2 tramos) que sale del cráneo en (th, fi) y va
    hacia `caida` (vector en metros, se mezcla con la normal). `curva` lo dobla hacia abajo."""
    raiz, n = _sobre_craneo(th, fi, 0.004)
    rumbo = (n * abre + Vector(caida)).normalized()
    punta = raiz + rumbo * largo + Vector((0, 0, -curva * largo * 0.25))
    medio = raiz + rumbo * largo * 0.5 + n * 0.008
    lado = rumbo.cross(n)
    lado = lado.normalized() if lado.length > 1e-4 else Vector((1, 0, 0))
    afuera = lado.cross(rumbo).normalized()
    if afuera.dot(n) < 0:
        afuera = -afuera

    def seccion(c, a):
        return [bm.verts.new(c + lado * sx * a / 2 + afuera * sy * a * grosor / 2) for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))]

    s0, s1 = seccion(raiz - rumbo * 0.01, ancho), seccion(medio, ancho * 0.6)
    tip = bm.verts.new(punta)
    for a, b in ((s0, s1),):
        for i in range(4):
            bm.faces.new((a[i], a[(i + 1) % 4], b[(i + 1) % 4], b[i]))
    for i in range(4):
        bm.faces.new((s1[i], s1[(i + 1) % 4], tip))
    bm.faces.new(list(reversed(s0)))


def _flequillo(bm, n, largo, ancho, desde=-0.9, hasta=0.9, fi=0.55, abre=0.25):
    for k in range(n):
        th = desde + (hasta - desde) * k / max(1, n - 1)
        _mechon(bm, th, fi, largo * (0.85 + 0.3 * ((k * 7) % 5) / 4), ancho, (math.sin(th) * 0.3, -0.5, -1.0), abre=abre, curva=0.2)


def _corona(bm, n, largo, ancho, fi_min, fi_max, arriba=0.4, atras=0.6, abre=0.8):
    """Mechones repartidos por todo el cráneo (de la coronilla para atrás y a los costados)."""
    for k in range(n):
        th = 2 * math.pi * k / n * 1.618
        th = math.fmod(th, 2 * math.pi)
        fi = fi_min + (fi_max - fi_min) * ((k * 5) % n) / n
        if abs(math.atan2(math.sin(th), math.cos(th))) < 0.9 and fi > 0.4:
            continue  # adelante va el flequillo
        _, d = _sobre_craneo(th, fi, 0)
        _mechon(bm, th, fi, largo * (0.8 + 0.4 * ((k * 3) % 4) / 3), ancho, (d.x * 0.5, d.y * 0.5 + atras, arriba), abre=abre)


def peinado(estilo, n):
    """bmesh del peinado `estilo`; `n` sube la resolución del casquete (para llegar a 1.000)."""
    bm = bmesh.new()
    lados, anillos = 16 + 2 * n, 6 + n
    if estilo == "Corto":
        casquete(bm, 1.475, 1.290, 0.008, lados, anillos)
        _corona(bm, 34, 0.055, 0.050, 0.15, 1.6, arriba=0.1, atras=0.7, abre=0.6)
        _flequillo(bm, 7, 0.06, 0.05)
    elif estilo == "Rapado":
        casquete(bm, 1.485, 1.270, 0.003, lados + 8, anillos + 4)
    elif estilo == "Pinchos":
        casquete(bm, 1.470, 1.300, 0.008, lados, anillos)
        _corona(bm, 44, 0.115, 0.060, 0.1, 1.7, arriba=0.7, atras=0.6, abre=0.9)
        _flequillo(bm, 8, 0.10, 0.055)
    elif estilo == "Cresta":
        casquete(bm, 1.480, 1.280, 0.003, lados, anillos)
        for k in range(9):
            fi = -0.9 + k * 0.25
            _mechon(bm, 0 if fi < 0 else math.pi, abs(fi), 0.11, 0.07, (0, 0.6, 0.8), abre=0.9, grosor=0.25)
    elif estilo == "Melena":
        casquete(bm, 1.480, 1.260, 0.012, lados, anillos)
        for k in range(28):
            th = math.pi * (0.35 + 1.3 * k / 27)
            _mechon(bm, th, 1.05 + 0.25 * (k % 3) / 2, 0.30 + 0.04 * (k % 4) / 3, 0.065, (0, 0.15, -1.0), abre=0.12, curva=0.05)
        _flequillo(bm, 9, 0.10, 0.05, -1.1, 1.1)
    elif estilo == "Cola":
        casquete(bm, 1.475, 1.290, 0.010, lados, anillos)
        _flequillo(bm, 7, 0.08, 0.05)
        for k in range(10):
            _mechon(bm, math.pi + (k - 4.5) * 0.06, 0.95, 0.24, 0.05, (0, 0.5, -1.0), abre=0.4, curva=0.3)
        _bola(bm, (0, 0.175, 1.430), 0.026)
    elif estilo == "Rodete":
        casquete(bm, 1.475, 1.290, 0.010, lados, anillos)
        _flequillo(bm, 6, 0.07, 0.05)
        _bola(bm, (0, 0.100, 1.555), 0.060, 14, 10)
    elif estilo == "DosRodetes":
        casquete(bm, 1.475, 1.290, 0.010, lados, anillos)
        _flequillo(bm, 6, 0.07, 0.05)
        for s in (1, -1):
            _bola(bm, (s * 0.115, 0.040, 1.535), 0.050, 14, 10)
    elif estilo == "Afro":
        casquete(bm, 1.470, 1.270, 0.055, lados + 8, anillos + 3, lambda th, fi: 0.010 * math.sin(6 * th) * math.sin(5 * fi) + 0.03 * math.cos(fi))
    elif estilo == "Flequillo":
        casquete(bm, 1.490, 1.290, 0.010, lados, anillos)
        _corona(bm, 30, 0.09, 0.06, 0.1, 1.6, arriba=0.3, atras=0.5)
        # Mechones largos que tapan un ojo (de la derecha de la imagen a la izquierda).
        for k in range(8):
            th = -0.7 + 1.3 * k / 7
            _mechon(bm, th, 0.45, 0.16 + 0.02 * (k % 3), 0.06, (-0.25, -0.45, -1.0), abre=0.2, curva=0.15)
    elif estilo == "PeinadoAtras":
        casquete(bm, 1.495, 1.280, 0.012, lados, anillos)
        for k in range(18):
            th = -1.4 + 2.8 * k / 17
            _mechon(bm, th, 0.35, 0.18, 0.06, (math.sin(th) * 0.2, 1.0, 0.15), abre=0.1, grosor=0.25, curva=0.15)
    elif estilo == "Trenzas":
        casquete(bm, 1.480, 1.290, 0.010, lados, anillos)
        _flequillo(bm, 8, 0.09, 0.05)
        for s in (1, -1):
            for k in range(8):
                t = k / 7
                _bola(bm, (s * (0.150 + 0.01 * t), 0.060 + 0.02 * t, 1.400 - 0.230 * t), 0.026 - 0.007 * t, 8, 6)
    return bm


PEINADOS = ["Corto", "Rapado", "Pinchos", "Cresta", "Melena", "Cola", "Rodete", "DosRodetes", "Afro", "Flequillo", "PeinadoAtras", "Trenzas"]


def armar_peinados():
    """Los 12 peinados, cada uno entre 1.000 y 2.000 triángulos (sube la resolución hasta llegar)."""
    objs = []
    for estilo in PEINADOS:
        for n in range(0, 12):
            obj = T.malla(f"{NOMBRE}_Pelo_{estilo}", peinado(estilo, n), "pelo", "Head", suave=70)
            tris = B.triangulos(obj)
            if tris >= 1000 or n == 11:
                break
        if tris > 2000:
            print(f"AVISO: {estilo} tiene {tris} triángulos")
        objs.append(obj)
    return objs


# --- Hojas en grilla ------------------------------------------------------


def _render_grilla(nombre, celdas, columnas, giro=0.0, paso=(0.42, 0.50), ancho_celda=420):
    """`celdas`: lista de [(objeto, material o None)]. Pone una copia de cada celda en una
    grilla, girada `giro` grados, y saca una sola foto de frente: renders/<nombre>.png."""
    escena = bpy.context.scene
    figuras = []
    for i, celda in enumerate(celdas):
        f, _ = _figura(f"Celda{i}", 0)
        f.location = ((i % columnas) * paso[0], 0, -(i // columnas) * paso[1])
        bpy.context.view_layer.update()
        for o, mat in celda:
            c = _copia(o, f)
            c.matrix_world = Matrix.Translation(f.location) @ o.matrix_world
            c.hide_render = False
            if mat:
                c.data.materials.clear()
                c.data.materials.append(mat)
        f.rotation_euler = (0, 0, math.radians(giro))
        figuras.append(f)
    bpy.context.view_layer.update()
    objs = [c for f in figuras for c in f.children]
    minimo, maximo = B.caja_de(objs)
    ancho = maximo.x - minimo.x + 0.12
    alto = maximo.z - minimo.z + 0.12
    datos = bpy.data.cameras.new("Grilla")
    datos.type = "ORTHO"
    datos.ortho_scale = max(ancho, alto)
    cam = bpy.data.objects.new("Grilla", datos)
    escena.collection.objects.link(cam)
    centro = (minimo + maximo) / 2
    B._apuntar(cam, (centro.x, -10, centro.z), (centro.x, 0, centro.z))
    antes = (escena.camera, escena.render.resolution_x, escena.render.resolution_y)
    escena.camera = cam
    escena.render.resolution_x = int(ancho_celda * columnas)
    escena.render.resolution_y = int(escena.render.resolution_x * alto / ancho)
    if alto > ancho:
        datos.sensor_fit = "VERTICAL"
    ruta = os.path.join(B.RENDERS, f"{nombre}.png")
    escena.render.filepath = ruta
    try:
        bpy.ops.render.render(write_still=True)
    finally:
        escena.camera, escena.render.resolution_x, escena.render.resolution_y = antes
        bpy.data.objects.remove(cam)
        bpy.data.cameras.remove(datos)
        _limpiar_comparacion()
    return ruta


def detalle():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = construir()
    cabeza = bpy.data.objects[f"{NOMBRE}_Head"]
    for o in piezas:
        uv_cabeza(o) if o is cabeza else uv_simple(o)
    piel = mat_piel("MAT_piel", TONOS[3], [cara(1)])
    for o in piezas:
        if o.data.materials and o.data.materials[0].name == "MAT_piel":
            o.data.materials[0] = piel if o is cabeza else mat_piel("MAT_piel_manos", TONOS[3])
    global CRANEO
    from mathutils.bvhtree import BVHTree

    bm = bmesh.new()
    bm.from_mesh(cabeza.data)
    bm.transform(cabeza.matrix_world)
    CRANEO = BVHTree.FromBMesh(bm)
    bm.free()
    pelos = armar_peinados()
    for o in pelos:
        uv_simple(o)
        o.hide_render = o.name != f"{NOMBRE}_Pelo_Corto"
    maniqui = B.partes()
    for o in maniqui:
        o.hide_render = True
        o.hide_set(True)
    cuenta = B.contar_triangulos(piezas)
    pelo_tris = {o.name.split("_")[-1]: B.triangulos(o) for o in pelos}
    print("Triángulos cuerpo:", cuenta)
    print("Triángulos pelo:", pelo_tris)

    # Vistas: Normal, Ancha y Delgada con tonos, caras y peinados distintos.
    paso = 1.25
    figuras = []
    elegidos = (("Normal", 3, 1, "Corto", 1), ("Ancha", 6, 5, "PeinadoAtras", 0), ("Delgada", 1, 4, "Cola", 3))
    for i, (forma, tono, n_cara, estilo, n_pelo) in enumerate(elegidos):
        f, x = _figura(forma, i * paso)
        f.location = (x, 0, 0)
        bpy.context.view_layer.update()
        pelo = bpy.data.objects[f"{NOMBRE}_Pelo_{estilo}"]
        for o in piezas + [pelo]:
            c = _copia(o, f, forma if o in piezas else None)
            c.matrix_world = Matrix.Translation((x, 0, 0)) @ o.matrix_world
            c.hide_render = False
            if o is cabeza:
                c.data.materials[0] = mat_piel(f"_piel_{forma}", TONOS[tono], [cara(n_cara)])
            elif o is pelo:
                c.data.materials[0] = mat_pelo(f"_pelo_{forma}", COLORES_PELO[n_pelo])
            elif o.data.materials[0].name.startswith("MAT_piel"):
                c.data.materials[0] = mat_piel(f"_manos_{forma}", TONOS[tono])
        figuras.append((f, x))
    visibles = [o for o in piezas + pelos if not o.hide_render]
    for o in visibles:
        o.hide_render = True
    vistas = _render_filas("cuerpo_vistas", figuras)
    _limpiar_comparacion()

    # Expresiones (cara 01 y cara 07, tono medio), de frente.
    celdas = []
    for n_cara, tono in ((1, 3), (7, 6)):
        for gesto in EXPRESIONES:
            celdas.append([(cabeza, mat_piel(f"_exp_{n_cara}_{gesto}", TONOS[tono], [cara(n_cara, gesto)]))])
    _render_grilla("cuerpo_expresiones", celdas, 8, ancho_celda=300)

    # Las 12 caras neutrales, con tonos variados.
    celdas = [[(cabeza, mat_piel(f"_cara_{n}", TONOS[(n * 7) % 10], [cara(n + 1)]))] for n in range(12)]
    _render_grilla("cuerpo_caras", celdas, 6, ancho_celda=300)

    # Peinados, girados 35 grados para que se vea el volumen.
    celdas = []
    for i, o in enumerate(pelos):
        celdas.append([(cabeza, mat_piel(f"_pein_{i}", TONOS[(i * 3) % 10], [cara(i % 12 + 1)])), (o, mat_pelo(f"_pelo_{i}", COLORES_PELO[i]))])
    _render_grilla("cuerpo_peinados", celdas, 6, giro=35, paso=(0.46, 0.55), ancho_celda=320)

    # Tonos de piel (10) y marcas (6).
    celdas = [[(cabeza, mat_piel(f"_tono_{i}", t, [cara(1)]))] for i, t in enumerate(TONOS)]
    _render_grilla("cuerpo_tonos", celdas, 10, ancho_celda=220)
    celdas = [
        [(cabeza, mat_piel(f"_marca_{i}", TONOS[(2 + i * 3) % 10], [cara(1 + i), os.path.join(MARCAS, f"marca_{i + 1:02d}.png")]))]
        for i in range(6)
    ]
    _render_grilla("cuerpo_marcas", celdas, 6, giro=15, ancho_celda=300)

    for o in visibles:
        o.hide_render = False
    for m in list(bpy.data.materials):
        if m.name.startswith("_"):
            bpy.data.materials.remove(m)
    bpy.ops.outliner.orphans_purge(do_recursive=True)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.render_primer_plano("cuerpo_cara", [cabeza, bpy.data.objects[f"{NOMBRE}_Pelo_Corto"]], giro=20, margen=1.15)
    B.render_primer_plano("cuerpo_mano", [bpy.data.objects[f"{NOMBRE}_RightHand"]], giro=-40, margen=1.3)
    print("Listo:", vistas)
    return piezas, pelos


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in argumentos:
        boceto()
    if "detalle" in argumentos:
        detalle()
