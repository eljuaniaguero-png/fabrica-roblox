"""Paso 2 de todo modelo: el NIVEL DE DETALLE OBLIGATORIO (GUIA-ESTILO.md, "Nivel de detalle").

Toma las mallas del boceto detallado (una por material) y les hace, en orden:

1. Bisel en los bordes (0,02 a 0,05 studs, 2 segmentos; baja a 1 si no entra en el presupuesto).
2. Ajuste al presupuesto de triángulos (Decimate solo si hace falta).
3. UV dentro de 0-1 (Smart UV Project).
4. Copia de alto poligonaje (subdividida, con remaches modelados) que no se exporta.
5. Horneado en Cycles (GPU si hay) de la copia alta sobre la baja:
   - color con desgaste: bordes más claros, suciedad en las juntas (AO), rayones en el metal;
   - rugosidad;
   - normal map OpenGL (Blender ya usa OpenGL, Y+) con líneas de panel, costuras, remaches,
     trama de tela y grano de cuero.
6. Material final por malla (TEX_<malla>) con esas tres texturas: es lo que va a SurfaceAppearance
   en Roblox (ColorMap, RoughnessMap, NormalMap; Metalness es un número por malla).

Uso desde un script de personaje:

    import detalle as D
    D.terminar(objs, presupuesto={"Cuervo_Capa": 8000, ...}, carpeta="cuervo", recetas={...})
"""

import math
import os
import random

import bmesh
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

import base as B
import trajes as T

TEXTURAS = os.path.join(B.BLENDER, "texturas")
COLECCION_ALTA = "Alto poligonaje"

# Receta de superficie por material: líneas de panel (cada `paso` metros en Z y en X), costuras
# (tela y cuero), remaches (solo metal), rayones y desgaste de bordes.
RECETAS = {
    "acero": {"paneles": (0.07, 0.09), "remaches": True, "rayones": 1.0, "bordes": 0.55, "suciedad": 0.6, "grano": 0.0},
    "tela-oscura": {"costuras": (0.11, 0.0), "trama": 1.0, "rayones": 0.0, "bordes": 0.35, "suciedad": 0.5, "grano": 0.0},
    "cuero": {"costuras": (0.06, 0.0), "trama": 0.0, "rayones": 0.25, "bordes": 0.45, "suciedad": 0.55, "grano": 1.0},
    "vigilantes": {"rayones": 0.3, "bordes": 0.5, "suciedad": 0.3, "grano": 0.0},
}
SIN_HORNEAR = {"neon-cian", "neon-eclipse", "neon-aviso"}  # brillan: se quedan con su material


def _material_base(obj):
    """Nombre de la guía (acero, tela-oscura...) del material de la malla."""
    return obj.data.materials[0].name.removeprefix("MAT_")


# ---------------------------------------------------------------------------
# 1-3. Bisel, presupuesto y UV
# ---------------------------------------------------------------------------


def biselar(obj, ancho=0.03 * B.STUD, segmentos=2, angulo=30):
    """Bisel en los bordes vivos (más de `angulo` grados). Las superficies curvas no se tocan."""
    mod = obj.modifiers.new("Bisel", "BEVEL")
    mod.width = ancho
    mod.segments = segmentos
    mod.limit_method = "ANGLE"
    mod.angle_limit = math.radians(angulo)
    mod.harden_normals = True
    mod.use_clamp_overlap = True
    mod.miter_outer = "MITER_ARC"
    T._aplicar(obj)
    obj.data.shade_smooth()
    obj.data.set_sharp_from_angle(angle=math.radians(60))
    return obj


def reducir(obj, tope):
    """Si la malla pasa `tope` triángulos, la reduce (Decimate) hasta entrar."""
    n = B.triangulos(obj)
    if n <= tope:
        return n
    mod = obj.modifiers.new("Reducir", "DECIMATE")
    mod.ratio = tope / n * 0.98
    mod.use_collapse_triangulate = True
    T._aplicar(obj)
    obj.data.shade_smooth()
    obj.data.set_sharp_from_angle(angle=math.radians(60))
    return B.triangulos(obj)


def desplegar_uv(obj):
    """Un solo set de UV dentro de 0-1."""
    for o in bpy.context.view_layer.objects:
        o.select_set(o == obj)
    bpy.context.view_layer.objects.active = obj
    while obj.data.uv_layers:
        obj.data.uv_layers.remove(obj.data.uv_layers[0])
    obj.data.uv_layers.new(name="UV")
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.004, scale_to_bounds=False)
    bpy.ops.object.mode_set(mode="OBJECT")


# ---------------------------------------------------------------------------
# 4. Alto poligonaje
# ---------------------------------------------------------------------------


def _coleccion_alta():
    col = bpy.data.collections.get(COLECCION_ALTA)
    if not col:
        col = bpy.data.collections.new(COLECCION_ALTA)
        bpy.context.scene.collection.children.link(col)
    return col


def _remaches(bm, low, paso_z, separacion=0.032, radio=0.0065):
    """Remaches modelados en filas, justo arriba de cada línea de panel horizontal (z = paso*(k+0,5)):
    rayos desde afuera hacia el eje de la pieza, uno cada `separacion` metros de vuelta."""
    arbol = BVHTree.FromObject(low, bpy.context.evaluated_depsgraph_get())
    minimo, maximo = B.caja_de([low])
    centro = (minimo + maximo) / 2
    radio_caja = max(maximo.x - minimo.x, maximo.y - minimo.y)
    k0, k1 = math.floor(minimo.z / paso_z), math.ceil(maximo.z / paso_z)
    n = 0
    for k in range(k0, k1 + 1):
        z = paso_z * (k + 0.5) + 0.011
        if not (minimo.z + 0.01 < z < maximo.z - 0.01):
            continue
        vueltas = max(6, int(math.pi * radio_caja / separacion))
        for i in range(vueltas):
            a = 2 * math.pi * i / vueltas
            d = Vector((math.cos(a), math.sin(a), 0))
            desde = Vector((centro.x, centro.y, z)) + d * radio_caja * 1.5
            p, normal, _, _ = arbol.ray_cast(desde, -d, radio_caja * 2)
            if p is None:
                continue
            if normal.dot(d) < 0:
                normal = -normal
            if abs(normal.z) > 0.7:  # tapas planas de arriba o abajo: ahí no
                continue
            T.remache(bm, p + normal * 0.0005, radio, normal)
            n += 1
    return n


def copia_alta(low, receta, niveles=2, max_caras=400_000):
    """Copia subdividida de la malla baja (con remaches si la receta los pide). No se renderiza
    ni se exporta: solo sirve para hornear."""
    nombre = low.name + "_Alto"
    viejo = bpy.data.objects.get(nombre)
    if viejo:
        bpy.data.objects.remove(viejo)
    bm = bmesh.new()
    bm.from_mesh(low.data)
    caras = len(bm.faces)
    while niveles > 0 and caras * 4**niveles > max_caras:
        niveles -= 1
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    alto = bpy.data.objects.new(nombre, me)
    _coleccion_alta().objects.link(alto)
    alto.matrix_world = low.matrix_world.copy()
    if niveles:
        sub = alto.modifiers.new("Subdividir", "SUBSURF")
        sub.levels = sub.render_levels = niveles
        sub.boundary_smooth = "PRESERVE_CORNERS"
        T._aplicar(alto)
    alto.data.shade_smooth()
    if receta.get("remaches") and receta.get("paneles"):
        extra = bmesh.new()
        _remaches(extra, low, receta["paneles"][0])
        if extra.verts:
            extra.transform(low.matrix_world.inverted())
            extra.from_mesh(alto.data)
            extra.to_mesh(alto.data)
        extra.free()
        alto.data.shade_smooth()
    return alto


# ---------------------------------------------------------------------------
# 5. Material de horneado (procedural) y horneado
# ---------------------------------------------------------------------------


class _Nodos:
    """Ayuda para armar árboles de nodos sin repetir tanto código."""

    def __init__(self, arbol):
        self.arbol = arbol
        self.n = arbol.nodes
        self.l = arbol.links

    def nodo(self, tipo, **valores):
        nodo = self.n.new(tipo)
        # Primero las propiedades (cambian qué entradas hay), después las entradas.
        for k, v in valores.items():
            if hasattr(nodo, k) and nodo.inputs.get(k) is None:
                setattr(nodo, k, v)
        for k, v in valores.items():
            if nodo.inputs.get(k) is not None:
                nodo.inputs[k].default_value = v
            elif not hasattr(nodo, k):
                raise AttributeError(f"{tipo}: no tiene {k}")
        return nodo

    def unir(self, salida, entrada):
        self.l.new(salida, entrada)

    def mate(self, op, a, b=None, limitar=False):
        nodo = self.nodo("ShaderNodeMath", operation=op, use_clamp=limitar)
        for i, x in enumerate((a, b)):
            if x is None:
                continue
            if isinstance(x, (int, float)):
                nodo.inputs[i].default_value = x
            else:
                self.unir(x, nodo.inputs[i])
        return nodo.outputs[0]

    def rango(self, x, de0, de1, a0=0.0, a1=1.0):
        nodo = self.nodo("ShaderNodeMapRange", clamp=True)
        self.unir(x, nodo.inputs["Value"])
        nodo.inputs["From Min"].default_value = de0
        nodo.inputs["From Max"].default_value = de1
        nodo.inputs["To Min"].default_value = a0
        nodo.inputs["To Max"].default_value = a1
        return nodo.outputs["Result"]

    def mezclar(self, factor, a, b):
        nodo = self.nodo("ShaderNodeMix", data_type="RGBA", blend_type="MIX", clamp_factor=True)
        for entrada, x in ((nodo.inputs[0], factor), (nodo.inputs[6], a), (nodo.inputs[7], b)):
            if isinstance(x, tuple):
                entrada.default_value = x
            elif isinstance(x, (int, float)):
                entrada.default_value = x
            else:
                self.unir(x, entrada)
        return nodo.outputs[2]

    def linea(self, coord, paso, ancho):
        """1 sobre las líneas que se repiten cada `paso` (en coord = z/paso + 0,5 → centro en 0,5),
        0 lejos. Devuelve también la distancia (para costuras a los costados)."""
        f = self.mate("FRACT", self.mate("DIVIDE", coord, paso))
        dist = self.mate("MULTIPLY", self.mate("ABSOLUTE", self.mate("SUBTRACT", f, 0.5)), paso)
        return self.rango(dist, ancho, ancho * 0.35), dist


def material_horneo(nombre, base, receta, semilla=0):
    """Material procedural de la copia alta. Tiene tres salidas, que se conectan de a una para
    hornear: color con desgaste, rugosidad y la superficie con relieve (para el normal map)."""
    d = B.MATERIALES[base]
    mat = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    mat.use_nodes = True
    N = _Nodos(mat.node_tree)
    N.n.clear()
    salida = N.nodo("ShaderNodeOutputMaterial")
    coords = N.nodo("ShaderNodeTexCoord").outputs["Object"]
    xyz = N.nodo("ShaderNodeSeparateXYZ")
    N.unir(coords, xyz.inputs[0])
    x, y, z = xyz.outputs

    alto = []  # (salida 0-1, profundidad en metros): relieve
    color = N.nodo("ShaderNodeRGB")
    color.outputs[0].default_value = B.color(d["hex"])
    col = color.outputs[0]
    rug = N.nodo("ShaderNodeValue")
    rug.outputs[0].default_value = d.get("rugosidad", 0.5)
    rug = rug.outputs[0]

    # Variación suave del color (manchas grandes).
    ruido = N.nodo("ShaderNodeTexNoise", **{"Scale": 9.0, "Detail": 4.0, "W": float(semilla)}, noise_dimensions="4D")
    N.unir(coords, ruido.inputs["Vector"])
    col = N.mezclar(N.rango(ruido.outputs["Fac"], 0.3, 0.7, 0.0, 0.18), col, B.color("0b0c10"))

    # Líneas de panel (metal): surcos cada paso en Z y en X.
    lineas = None
    if receta.get("paneles"):
        pz, px = receta["paneles"]
        lz, _ = N.linea(z, pz, 0.0022)
        lx, _ = N.linea(N.mate("ADD", x, N.mate("MULTIPLY", z, 0.0)), px, 0.0022)
        lineas = N.mate("MAXIMUM", lz, lx)
        alto.append((N.mate("SUBTRACT", 1.0, lineas), 0.0016))

    # Costuras (tela y cuero): pespunte doble a los costados de cada línea, en guiones.
    if receta.get("costuras"):
        pz, _ = receta["costuras"]
        _, dist = N.linea(z, pz, 0.002)
        surco = N.rango(dist, 0.0018, 0.0006)
        lado = N.rango(N.mate("ABSOLUTE", N.mate("SUBTRACT", dist, 0.0045)), 0.0012, 0.0004)
        guion = N.rango(N.mate("FRACT", N.mate("DIVIDE", N.mate("ADD", x, y), 0.007)), 0.55, 0.45)
        punto = N.mate("MULTIPLY", lado, guion)
        alto.append((N.mate("SUBTRACT", 1.0, surco), 0.0012))
        alto.append((punto, 0.0007))
        lineas = surco
        col = N.mezclar(N.mate("MULTIPLY", punto, 0.6), col, B.color("5a5f6e"))

    # Trama de tela: dos ondas finas cruzadas.
    if receta.get("trama"):
        for eje in ((1, 0, 0.6), (0, 1, 0.6)):
            onda = N.nodo("ShaderNodeTexWave", wave_type="BANDS", bands_direction="DIAGONAL", **{"Scale": 220.0, "Distortion": 0.0})
            mapeo = N.nodo("ShaderNodeMapping")
            mapeo.inputs["Rotation"].default_value = (0, 0, math.radians(45 if eje[0] else -45))
            N.unir(coords, mapeo.inputs["Vector"])
            N.unir(mapeo.outputs[0], onda.inputs["Vector"])
            alto.append((onda.outputs["Fac"], 0.00025 * receta["trama"]))

    # Grano de cuero.
    if receta.get("grano"):
        celdas = N.nodo("ShaderNodeTexVoronoi", feature="DISTANCE_TO_EDGE", **{"Scale": 160.0})
        N.unir(coords, celdas.inputs["Vector"])
        alto.append((N.rango(celdas.outputs["Distance"], 0.0, 0.08), 0.0004 * receta["grano"]))
        arruga = N.nodo("ShaderNodeTexNoise", **{"Scale": 40.0, "Detail": 6.0, "Roughness": 0.65})
        N.unir(coords, arruga.inputs["Vector"])
        alto.append((arruga.outputs["Fac"], 0.0012 * receta["grano"]))

    # Rayones: ruido estirado en una dirección, recortado finito.
    rayon = None
    if receta.get("rayones"):
        mapeo = N.nodo("ShaderNodeMapping")
        mapeo.inputs["Scale"].default_value = (1.0, 1.0, 22.0)
        mapeo.inputs["Rotation"].default_value = (math.radians(70), math.radians(20), math.radians(semilla * 37 % 180))
        N.unir(coords, mapeo.inputs["Vector"])
        r = N.nodo("ShaderNodeTexNoise", **{"Scale": 55.0, "Detail": 2.0, "W": float(semilla) + 3}, noise_dimensions="4D")
        N.unir(mapeo.outputs[0], r.inputs["Vector"])
        manchas = N.nodo("ShaderNodeTexNoise", **{"Scale": 6.0, "Detail": 2.0, "W": float(semilla) + 7}, noise_dimensions="4D")
        N.unir(coords, manchas.inputs["Vector"])
        rayon = N.mate(
            "MULTIPLY",
            N.rango(N.mate("ABSOLUTE", N.mate("SUBTRACT", r.outputs["Fac"], 0.5)), 0.012, 0.0),
            N.mate("MULTIPLY", N.rango(manchas.outputs["Fac"], 0.45, 0.65), receta["rayones"]),
        )
        alto.append((N.mate("SUBTRACT", 1.0, rayon), 0.0003))

    # Bordes gastados: donde la normal biselada se aparta de la normal real, es borde.
    bisel = N.nodo("ShaderNodeBevel", samples=8, **{"Radius": 0.006})
    geo = N.nodo("ShaderNodeNewGeometry")
    punto_b = N.nodo("ShaderNodeVectorMath", operation="DOT_PRODUCT")
    N.unir(bisel.outputs[0], punto_b.inputs[0])
    N.unir(geo.outputs["Normal"], punto_b.inputs[1])
    borde = N.rango(punto_b.outputs["Value"], 0.985, 0.9)
    gasto = N.nodo("ShaderNodeTexNoise", **{"Scale": 30.0, "Detail": 8.0, "W": float(semilla) + 11}, noise_dimensions="4D")
    N.unir(coords, gasto.inputs["Vector"])
    borde = N.mate("MULTIPLY", borde, N.rango(gasto.outputs["Fac"], 0.35, 0.6), limitar=True)
    claro = (1.0, 1.0, 1.0, 1.0)
    col = N.mezclar(N.mate("MULTIPLY", borde, receta.get("bordes", 0.4)), col, claro)
    rug = N.mate("SUBTRACT", rug, N.mate("MULTIPLY", borde, 0.2), limitar=True)
    if rayon is not None:
        col = N.mezclar(N.mate("MULTIPLY", rayon, 0.55), col, claro)
        rug = N.mate("SUBTRACT", rug, N.mate("MULTIPLY", rayon, 0.15), limitar=True)

    # Suciedad en las juntas: oclusión ambiental + líneas de panel.
    oclusion = N.nodo("ShaderNodeAmbientOcclusion", samples=16, only_local=False, **{"Distance": 0.035})
    sucio = N.mate("SUBTRACT", 1.0, oclusion.outputs["AO"])
    if lineas is not None:
        sucio = N.mate("MAXIMUM", sucio, N.mate("MULTIPLY", lineas, 0.8))
    mugre = N.nodo("ShaderNodeTexNoise", **{"Scale": 14.0, "Detail": 6.0, "W": float(semilla) + 5}, noise_dimensions="4D")
    N.unir(coords, mugre.inputs["Vector"])
    sucio = N.mate("MULTIPLY", sucio, N.rango(mugre.outputs["Fac"], 0.3, 0.7, 0.6, 1.0), limitar=True)
    col = N.mezclar(N.mate("MULTIPLY", sucio, receta.get("suciedad", 0.5)), col, B.color("07080b"))
    rug = N.mate("ADD", rug, N.mate("MULTIPLY", sucio, 0.15), limitar=True)

    # Relieve: suma de alturas -> nodo Bump con distancia en metros.
    normal = None
    for valor, profundidad in alto:
        bump = N.nodo("ShaderNodeBump", **{"Strength": 1.0, "Distance": profundidad})
        N.unir(valor, bump.inputs["Height"])
        if normal is not None:
            N.unir(normal, bump.inputs["Normal"])
        normal = bump.outputs["Normal"]

    sup = N.nodo("ShaderNodeBsdfPrincipled")
    if normal is not None:
        N.unir(normal, sup.inputs["Normal"])
    em_color = N.nodo("ShaderNodeEmission")
    N.unir(col, em_color.inputs["Color"])
    em_rug = N.nodo("ShaderNodeEmission")
    N.unir(rug, em_rug.inputs["Color"])
    mat["_salidas"] = {"color": em_color.name, "rugosidad": em_rug.name, "normal": sup.name}
    N.unir(sup.outputs[0], salida.inputs["Surface"])
    return mat


def _conectar_salida(mat, cual):
    arbol = mat.node_tree
    nodo = arbol.nodes[mat["_salidas"][cual]]
    salida = next(n for n in arbol.nodes if n.type == "OUTPUT_MATERIAL")
    arbol.links.new(nodo.outputs[0], salida.inputs["Surface"])


def preparar_cycles(muestras=24):
    escena = bpy.context.scene
    escena.render.engine = "CYCLES"
    escena.cycles.samples = muestras
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        for tipo in ("OPTIX", "CUDA"):
            try:
                prefs.compute_device_type = tipo
                prefs.get_devices()
                gpus = [d for d in prefs.devices if d.type == tipo]
                if gpus:
                    for d in prefs.devices:
                        d.use = d.type == tipo
                    escena.cycles.device = "GPU"
                    return tipo
            except TypeError:
                continue
    except KeyError:
        pass
    escena.cycles.device = "CPU"
    return "CPU"


def _imagen(nombre, lado, no_color):
    img = bpy.data.images.get(nombre)
    if img:
        bpy.data.images.remove(img)
    img = bpy.data.images.new(nombre, lado, lado, alpha=False, float_buffer=False)
    img.colorspace_settings.name = "Non-Color" if no_color else "sRGB"
    return img


def hornear(low, alto, carpeta, lado=1024, semilla=0, receta=None):
    """Hornea color, rugosidad y normal de `alto` sobre `low` y le arma el material final.
    Las texturas quedan en blender/texturas/<carpeta>/<malla>_{color,rugosidad,normal}.png."""
    base = _material_base(low)
    receta = receta if receta is not None else RECETAS.get(base, {})
    mat_alto = material_horneo("HORNEO_" + low.name, base, receta, semilla)
    alto.data.materials.clear()
    alto.data.materials.append(mat_alto)

    # Material final de la malla baja: lo que se ve en el render y lo que va a Roblox.
    d = B.MATERIALES[base]
    mat = bpy.data.materials.get("TEX_" + low.name) or bpy.data.materials.new("TEX_" + low.name)
    mat.use_nodes = True
    N = _Nodos(mat.node_tree)
    N.n.clear()
    salida = N.nodo("ShaderNodeOutputMaterial")
    sup = N.nodo("ShaderNodeBsdfPrincipled", **{"Metallic": d.get("metal", 0.0)})
    N.unir(sup.outputs[0], salida.inputs["Surface"])
    imgs = {
        "color": _imagen(f"{low.name}_color", lado, False),
        "rugosidad": _imagen(f"{low.name}_rugosidad", lado // 2, True),
        "normal": _imagen(f"{low.name}_normal", lado, True),
    }
    texs = {}
    for cual, img in imgs.items():
        tex = N.nodo("ShaderNodeTexImage")
        tex.image = img
        texs[cual] = tex
    N.unir(texs["color"].outputs["Color"], sup.inputs["Base Color"])
    N.unir(texs["rugosidad"].outputs["Color"], sup.inputs["Roughness"])
    mapa = N.nodo("ShaderNodeNormalMap", space="TANGENT")
    N.unir(texs["normal"].outputs["Color"], mapa.inputs["Color"])
    N.unir(mapa.outputs["Normal"], sup.inputs["Normal"])
    low.data.materials.clear()
    low.data.materials.append(mat)

    for o in bpy.context.view_layer.objects:
        o.select_set(o in (low, alto))
    bpy.context.view_layer.objects.active = low
    alto.hide_set(False)
    escena = bpy.context.scene
    ajustes = escena.render.bake
    ajustes.use_selected_to_active = True
    ajustes.cage_extrusion = 0.012
    ajustes.max_ray_distance = 0.03
    ajustes.margin = 8
    ajustes.target = "IMAGE_TEXTURES"
    os.makedirs(os.path.join(TEXTURAS, carpeta), exist_ok=True)
    for cual, img in imgs.items():
        mat.node_tree.nodes.active = texs[cual]
        if cual == "normal":
            _conectar_salida(mat_alto, "normal")
            escena.cycles.samples = 4
            bpy.ops.object.bake(type="NORMAL", normal_space="TANGENT", normal_r="POS_X", normal_g="POS_Y", normal_b="POS_Z")
        else:
            _conectar_salida(mat_alto, cual)
            escena.cycles.samples = 24
            bpy.ops.object.bake(type="EMIT")
        img.filepath_raw = os.path.join(TEXTURAS, carpeta, f"{img.name}.png")
        img.file_format = "PNG"
        img.save()
        img.filepath = bpy.path.relpath(img.filepath_raw)
    _conectar_salida(mat_alto, "normal")
    alto.hide_set(True)
    alto.hide_render = True
    return imgs


# ---------------------------------------------------------------------------
# Todo junto
# ---------------------------------------------------------------------------


def terminar(objs, presupuesto, carpeta, ancho=0.03 * B.STUD, lados=None, recetas=None):
    """Aplica todo el nivel de detalle a `objs`. `presupuesto` = {pieza: (tope, [mallas])}: si una
    pieza se pasa con bisel de 2 segmentos, prueba con 1 y después reduce cada malla en proporción.
    `lados` = {malla: px} para cambiar el tamaño de textura (por defecto 1024).
    `recetas` = {malla: receta} para cambiar la superficie de una malla (ej. plumas sin paneles)."""
    lados = lados or {}
    recetas = recetas or {}
    originales = {o.name: o.data.copy() for o in objs}
    for tope, nombres in presupuesto.values():
        grupo = [bpy.data.objects[n] for n in nombres if n in bpy.data.objects]
        for segmentos in (2, 1):
            for o in grupo:
                o.data = originales[o.name].copy()
                biselar(o, ancho, segmentos)
            total = sum(B.triangulos(o) for o in grupo)
            if total <= tope:
                break
        if total > tope:
            for o in grupo:
                reducir(o, int(B.triangulos(o) * tope / total))
    for me in originales.values():
        bpy.data.meshes.remove(me)
    dispositivo = preparar_cycles()
    print("Horneando con", dispositivo)
    altos = []
    for i, o in enumerate(objs):
        desplegar_uv(o)
        if _material_base(o) in SIN_HORNEAR:
            continue
        receta = recetas.get(o.name, RECETAS.get(_material_base(o), {}))
        alto = copia_alta(o, receta)
        hornear(o, alto, carpeta, lados.get(o.name, 1024), semilla=i, receta=receta)
        altos.append(alto)
        print("  horneada", o.name)
    motores = {m.identifier for m in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in motores else "BLENDER_EEVEE"
    random.seed(0)
    return altos
