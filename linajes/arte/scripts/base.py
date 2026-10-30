"""Kit base de Linajes del Eclipse en Blender (reglas en linajes/arte/GUIA-ESTILO.md).

Se usa de dos formas:
- Desde otro script:  import base as B; B.cargar_kit(); ...; B.render_vistas("cuervo")
- Para rehacer el kit: <blender.exe> -b --factory-startup -P linajes/arte/scripts/base.py -- kit
  (lee el maniquí exportado de Studio y guarda linajes/arte/blender/kit-base.blend)

Reglas del kit:
- Escala real: 1 unidad de Blender = 1 m, y 1 stud = 0,28 m (STUD).
- El maniquí mira a -Y (vista Front de Blender) y está parado en z = 0.
- El esqueleto se llama "Maniqui" y tiene un hueso por parte del R15 (HUESOS). Cada parte del
  cuerpo es un objeto "Maniqui_<Parte>" pegado a su hueso (como el R15 de bloques de Roblox).
- Un material por color, con nombre MAT_<nombre> (MATERIALES).
"""

import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

ARTE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLENDER = os.path.join(ARTE, "blender")
KIT = os.path.join(BLENDER, "kit-base.blend")
MANIQUI_FBX = os.path.join(BLENDER, "maniqui-r15.fbx")
MANIQUI_DATOS = os.path.join(BLENDER, "maniqui-r15.json")
RENDERS = os.path.join(ARTE, "renders")
EXPORTS = os.path.join(ARTE, "exports")

STUD = 0.28
ESQUELETO = "Maniqui"

# Padre de cada parte en el R15 (LowerTorso es la raíz).
HUESOS = {
    "LowerTorso": None,
    "UpperTorso": "LowerTorso",
    "Head": "UpperTorso",
    "LeftUpperArm": "UpperTorso",
    "LeftLowerArm": "LeftUpperArm",
    "LeftHand": "LeftLowerArm",
    "RightUpperArm": "UpperTorso",
    "RightLowerArm": "RightUpperArm",
    "RightHand": "RightLowerArm",
    "LeftUpperLeg": "LowerTorso",
    "LeftLowerLeg": "LeftUpperLeg",
    "LeftFoot": "LeftLowerLeg",
    "RightUpperLeg": "LowerTorso",
    "RightLowerLeg": "RightUpperLeg",
    "RightFoot": "RightLowerLeg",
}

# ---------------------------------------------------------------------------
# Materiales de la guía. rugosidad = roughness, metal = metallic, brillo = emission strength.
# ---------------------------------------------------------------------------

MATERIALES = {
    "maniqui": {"hex": "b8bcc6", "rugosidad": 1.0},
    "asfalto": {"hex": "3a3f4b", "rugosidad": 0.9},
    "ladrillo": {"hex": "6e3b2e", "rugosidad": 0.85},
    "acero": {"hex": "8a94a6", "rugosidad": 0.35, "metal": 0.8},
    "tela-oscura": {"hex": "1b1f2a", "rugosidad": 0.8},
    "cuero": {"hex": "2a2018", "rugosidad": 0.6},
    "bronce": {"hex": "a0703a", "rugosidad": 0.4, "metal": 0.9},
    "oro": {"hex": "d9a441", "rugosidad": 0.3, "metal": 1.0},
    "blanco-armadura": {"hex": "e8e6e0", "rugosidad": 0.4},
    "neon-cian": {"hex": "3fe0f0", "brillo": 5.0},
    "neon-eclipse": {"hex": "f2652b", "brillo": 5.0},
    "neon-aviso": {"hex": "ff2a2a", "brillo": 6.0},
    "liga": {"hex": "2f6fdb", "rugosidad": 0.5},
    "cofradia": {"hex": "c2213a", "rugosidad": 0.5},
    "vigilantes": {"hex": "6b5ba8", "rugosidad": 0.5},
}

FONDO = "0e1016"
LUZ_PRINCIPAL = {"hex": "9fb4ff", "fuerza": 3.0}
LUZ_BORDE = {"hex": "f2652b", "fuerza": 4.0}
NIEBLA = 0.02
RESOLUCION = (1600, 1000)
LENTE = 50


def color(h, alfa=1.0):
    """Hex sRGB ("#3fe0f0" o "3fe0f0") a color lineal RGBA de Blender."""
    h = h.lstrip("#")

    def lineal(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return tuple(lineal(int(h[i : i + 2], 16) / 255) for i in (0, 2, 4)) + (alfa,)


def material(nombre):
    """Devuelve MAT_<nombre> (lo crea si no está)."""
    nombre_mat = "MAT_" + nombre
    mat = bpy.data.materials.get(nombre_mat)
    if mat:
        return mat
    d = MATERIALES[nombre]
    mat = bpy.data.materials.new(nombre_mat)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    c = color(d["hex"])
    mat.diffuse_color = c
    bsdf.inputs["Base Color"].default_value = c
    bsdf.inputs["Roughness"].default_value = d.get("rugosidad", 0.5)
    bsdf.inputs["Metallic"].default_value = d.get("metal", 0.0)
    if "brillo" in d:
        bsdf.inputs["Emission Color"].default_value = c
        bsdf.inputs["Emission Strength"].default_value = d["brillo"]
    if d.get("rugosidad", 0.5) >= 1.0:  # "sin brillo": sin reflejo especular
        bsdf.inputs["Specular IOR Level"].default_value = 0.0
    mat.use_fake_user = True  # que quede guardado aunque nadie lo use
    return mat


def crear_materiales():
    return [material(n) for n in MATERIALES]


def aplicar_material(obj, nombre):
    """Un material por malla: reemplaza los que tenga."""
    obj.data.materials.clear()
    obj.data.materials.append(material(nombre))
    return obj


# ---------------------------------------------------------------------------
# Medidas
# ---------------------------------------------------------------------------


def triangulos(obj):
    """Triángulos de la malla tal como se exporta (con modificadores)."""
    grafo = bpy.context.evaluated_depsgraph_get()
    me = obj.evaluated_get(grafo).to_mesh()
    me.calc_loop_triangles()
    n = len(me.loop_triangles)
    obj.evaluated_get(grafo).to_mesh_clear()
    return n


def contar_triangulos(objs=None, maximo_por_malla=20000):
    """{objeto: triángulos} de las mallas (todas si objs es None), más "_total".
    Avisa en consola las que pasan el límite de Roblox."""
    objs = objs if objs is not None else [o for o in bpy.context.scene.objects if o.type == "MESH" and o.name != "Niebla"]
    cuenta = {}
    for o in objs:
        if o.type != "MESH":
            continue
        cuenta[o.name] = triangulos(o)
        if cuenta[o.name] > maximo_por_malla:
            print(f"AVISO: {o.name} tiene {cuenta[o.name]} triángulos (máximo {maximo_por_malla})")
    cuenta["_total"] = sum(cuenta.values())
    return cuenta


def caja_de(objs):
    puntos = [o.matrix_world @ Vector(c) for o in objs for c in o.bound_box]
    minimo = Vector((min(p.x for p in puntos), min(p.y for p in puntos), min(p.z for p in puntos)))
    maximo = Vector((max(p.x for p in puntos), max(p.y for p in puntos), max(p.z for p in puntos)))
    return minimo, maximo


# ---------------------------------------------------------------------------
# Kit: maniquí + materiales + luz + cámaras
# ---------------------------------------------------------------------------


def cargar_kit():
    """Abre kit-base.blend (descarta lo que haya en la escena)."""
    bpy.ops.wm.open_mainfile(filepath=KIT)
    return esqueleto()


def esqueleto():
    return bpy.data.objects[ESQUELETO]


def parte(nombre):
    """El objeto del cuerpo del maniquí para esa parte (Head, UpperTorso...)."""
    return bpy.data.objects[f"{ESQUELETO}_{nombre}"]


def partes():
    return [parte(n) for n in HUESOS]


def pegar_a_hueso(obj, hueso):
    """Pega el objeto al hueso sin moverlo (sigue al hueso en las animaciones)."""
    arm = esqueleto()
    mundo = obj.matrix_world.copy()
    obj.parent = arm
    obj.parent_type = "BONE"
    obj.parent_bone = hueso
    obj.matrix_parent_inverse = Matrix.Identity(4)
    bpy.context.view_layer.update()
    obj.matrix_world = mundo
    return obj


def _apuntar(obj, desde, hacia):
    obj.location = desde
    obj.rotation_euler = (Vector(hacia) - Vector(desde)).to_track_quat("-Z", "Y").to_euler()


def _sol(nombre, d, fuerza, direccion):
    luz = bpy.data.lights.get(nombre) or bpy.data.lights.new(nombre, "SUN")
    luz.color = color(d["hex"])[:3]
    luz.energy = fuerza
    luz.angle = math.radians(8)
    obj = bpy.data.objects.get(nombre) or bpy.data.objects.new(nombre, luz)
    if obj.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(obj)
    _apuntar(obj, Vector(direccion) * 10, (0, 0, 0))
    return obj


def configurar_luz():
    """Fondo, niebla, luz principal fría (arriba-izquierda, 45°) y luz de borde naranja
    (atrás-derecha). Izquierda y derecha vistas desde la cámara de Frente."""
    escena = bpy.context.scene
    mundo = bpy.data.worlds.get("Noche") or bpy.data.worlds.new("Noche")
    mundo.use_nodes = True
    nodos = mundo.node_tree.nodes
    nodos["Background"].inputs["Color"].default_value = color(FONDO)
    nodos["Background"].inputs["Strength"].default_value = 1.0
    escena.world = mundo
    _niebla()

    e = math.radians(45)
    _sol("LuzPrincipal", LUZ_PRINCIPAL, LUZ_PRINCIPAL["fuerza"], (-math.cos(e) * 0.7071, -math.cos(e) * 0.7071, math.sin(e)))
    _sol("LuzBorde", LUZ_BORDE, LUZ_BORDE["fuerza"], (0.7071, 0.7071, 0.35))

    motores = {m.identifier for m in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in motores else "BLENDER_EEVEE"
    escena.render.resolution_x, escena.render.resolution_y = RESOLUCION
    escena.render.resolution_percentage = 100
    escena.render.film_transparent = False
    escena.render.image_settings.file_format = "PNG"
    escena.render.image_settings.color_mode = "RGB"
    escena.view_settings.view_transform = "AgX"
    escena.eevee.volumetric_end = 30.0


def _niebla(lado=40.0):
    """Caja de niebla alrededor de la escena (en el mundo, Eevee la toma infinita y deja todo
    negro). No se exporta ni cuenta triángulos."""
    if "Niebla" in bpy.data.objects:
        return bpy.data.objects["Niebla"]
    import bmesh

    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=lado)
    me = bpy.data.meshes.new("Niebla")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new("Niebla", me)
    bpy.context.scene.collection.objects.link(obj)
    mat = bpy.data.materials.new("Niebla")
    mat.use_nodes = True
    nodos = mat.node_tree.nodes
    nodos.remove(nodos["Principled BSDF"])
    volumen = nodos.new("ShaderNodeVolumePrincipled")
    volumen.inputs["Density"].default_value = NIEBLA
    volumen.inputs["Color"].default_value = color("3a3f4b")
    mat.node_tree.links.new(volumen.outputs["Volume"], nodos["Material Output"].inputs["Volume"])
    me.materials.append(mat)
    obj.hide_select = True
    obj.display_type = "BOUNDS"
    return obj


VISTAS = {"Frente": 0, "Costado": 90, "Espalda": 180}


def configurar_camaras(objs=None, margen=1.15):
    """Las 3 cámaras (50 mm) a la altura del pecho, mirando al centro de `objs` (por defecto el
    maniquí). Se alejan lo justo para que entre todo en el tercio del medio de la imagen, que es
    lo que usa render_vistas."""
    objs = objs or partes()
    minimo, maximo = caja_de(objs)
    centro = (minimo + maximo) / 2
    pecho = parte("UpperTorso").matrix_world.translation.z if ESQUELETO + "_UpperTorso" in bpy.data.objects else centro.z
    ancho_sensor = 36.0
    alto_sensor = ancho_sensor * RESOLUCION[1] / RESOLUCION[0]
    # Campo visual del tercio del medio (ancho) y de toda la imagen (alto).
    medio_ancho = math.atan((ancho_sensor / 6) / LENTE)
    medio_alto = math.atan((alto_sensor / 2) / LENTE)
    tam = maximo - minimo
    lado = max(tam.x, tam.y) / 2 * margen
    arriba = max(maximo.z - pecho, pecho - minimo.z) * margen
    distancia = max(lado / math.tan(medio_ancho), arriba / math.tan(medio_alto)) + max(tam.x, tam.y) / 2
    camaras = {}
    for nombre, grados in VISTAS.items():
        cam_datos = bpy.data.cameras.get(nombre) or bpy.data.cameras.new(nombre)
        cam_datos.lens = LENTE
        cam_datos.sensor_width = ancho_sensor
        cam_datos.sensor_fit = "HORIZONTAL"
        cam_datos.clip_end = distancia * 4
        cam = bpy.data.objects.get(nombre) or bpy.data.objects.new(nombre, cam_datos)
        if cam.name not in bpy.context.scene.collection.objects:
            bpy.context.scene.collection.objects.link(cam)
        a = math.radians(grados)
        # Frente: la cámara está en -Y (el maniquí mira a -Y); Costado: a su derecha (+X).
        desde = Vector((centro.x + math.sin(a) * distancia, centro.y - math.cos(a) * distancia, pecho))
        _apuntar(cam, desde, (centro.x, centro.y, pecho))
        camaras[nombre] = cam
    bpy.context.scene.camera = camaras["Frente"]
    return camaras


def render_vistas(nombre, objs=None):
    """Renderiza Frente, Costado y Espalda y las junta en renders/<nombre>_vistas.png
    (1600x1000: cada vista es un tercio). `objs` encuadra las cámaras (por defecto el maniquí)."""
    import numpy as np

    escena = bpy.context.scene
    camaras = configurar_camaras(objs)
    os.makedirs(RENDERS, exist_ok=True)
    escena.render.use_border = True
    escena.render.use_crop_to_border = True
    escena.render.border_min_x, escena.render.border_max_x = 1 / 3, 2 / 3
    escena.render.border_min_y, escena.render.border_max_y = 0.0, 1.0
    tiras = []
    try:
        for vista in VISTAS:
            escena.camera = camaras[vista]
            ruta = os.path.join(RENDERS, f"_{nombre}_{vista}.png")
            escena.render.filepath = ruta
            bpy.ops.render.render(write_still=True)
            img = bpy.data.images.load(ruta)
            ancho, alto = img.size
            tiras.append(np.array(img.pixels[:], dtype=np.float32).reshape(alto, ancho, 4))
            bpy.data.images.remove(img)
            os.remove(ruta)
    finally:
        escena.render.use_border = False
        escena.render.use_crop_to_border = False
        escena.camera = camaras["Frente"]
    alto = min(t.shape[0] for t in tiras)
    hoja = np.concatenate([t[:alto] for t in tiras], axis=1)
    ruta = os.path.join(RENDERS, f"{nombre}_vistas.png")
    img = bpy.data.images.new("Vistas", hoja.shape[1], hoja.shape[0], alpha=True)
    img.pixels[:] = hoja.ravel()
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)
    return ruta


def render_primer_plano(nombre, objs, giro=25.0, altura=10.0, margen=1.25):
    """Primer plano de `objs` desde adelante, girado `giro` grados hacia la derecha del
    personaje y `altura` grados desde arriba: renders/<nombre>.png (1000x1000)."""
    escena = bpy.context.scene
    minimo, maximo = caja_de(objs)
    centro = (minimo + maximo) / 2
    radio = (maximo - minimo).length / 2 * margen
    datos = bpy.data.cameras.new("PrimerPlano")
    datos.lens = LENTE
    cam = bpy.data.objects.new("PrimerPlano", datos)
    escena.collection.objects.link(cam)
    distancia = radio / math.tan(datos.angle / 2)
    a, e = math.radians(giro), math.radians(altura)
    desde = centro + Vector((-math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e))) * distancia
    _apuntar(cam, desde, centro)
    antes = (escena.camera, escena.render.resolution_x, escena.render.resolution_y)
    escena.camera = cam
    escena.render.resolution_x = escena.render.resolution_y = 1000
    ruta = os.path.join(RENDERS, f"{nombre}.png")
    escena.render.filepath = ruta
    try:
        bpy.ops.render.render(write_still=True)
    finally:
        escena.camera, escena.render.resolution_x, escena.render.resolution_y = antes
        bpy.data.objects.remove(cam)
        bpy.data.cameras.remove(datos)
    return ruta


# ---------------------------------------------------------------------------
# Exportar a Roblox
# ---------------------------------------------------------------------------


def exportar_fbx(obj, ruta):
    """Exporta una malla sola, en studs, con los ejes que espera Roblox (frente a -Z)."""
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    for o in bpy.context.scene.objects:
        o.select_set(o == obj)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.fbx(
        filepath=ruta,
        use_selection=True,
        object_types={"MESH"},
        global_scale=1 / STUD,  # metros de Blender -> studs
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
        bake_space_transform=True,
        use_mesh_modifiers=True,
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
        bake_anim=False,
    )
    return ruta


def exportar_piezas(nombre, objs):
    """Un FBX por pieza en exports/<nombre>/<pieza>.fbx. Devuelve las rutas."""
    return [exportar_fbx(o, os.path.join(EXPORTS, nombre, o.name + ".fbx")) for o in objs if o.type == "MESH"]


# ---------------------------------------------------------------------------
# Armar el kit desde el maniquí de Studio
# ---------------------------------------------------------------------------


def _studio_a_blender(p):
    """Studio: Y arriba, frente a -Z, derecha del personaje a +X. Blender (acá): Z arriba,
    frente a -Y, derecha del personaje a -X. Es un giro (no espeja nada)."""
    return Vector((-p[0], p[2], p[1]))


_CAMBIO = Matrix(((-1, 0, 0), (0, 0, 1), (0, 1, 0)))


def _giro(m):
    """Matriz de rotación de Studio (fila por fila, 3x3) pasada a ejes de Blender."""
    r = Matrix(((m[0], m[1], m[2]), (m[3], m[4], m[5]), (m[6], m[7], m[8])))
    return (_CAMBIO @ r @ _CAMBIO).to_4x4()


def _armar_maniqui():
    """Arma el maniquí R15 de bloques con los datos sacados de Studio (maniqui-r15.json):
    la malla exacta de cada parte, su lugar y las uniones (RigAttachments) para el esqueleto.
    Si una parte no trae malla (Roblox no deja leer la de la cabeza), va un bloque redondeado
    con sus medidas exactas."""
    import json

    import bmesh

    with open(MANIQUI_DATOS, encoding="utf-8") as f:
        datos = json.load(f)["partes"]

    def punto(p):
        return _studio_a_blender(p) * STUD

    # El maniquí queda parado en z = 0.
    piso = min(
        (Matrix.Translation(punto(d["centro"])) @ _giro(d["giro"]) @ (_studio_a_blender(v) * STUD)).z
        for d in datos.values()
        for v in d.get("verts", [[0, -d["tam"][1] / 2, 0]])
    )
    sube = Vector((0, 0, -piso))

    arm_datos = bpy.data.armatures.new(ESQUELETO)
    arm = bpy.data.objects.new(ESQUELETO, arm_datos)
    bpy.context.scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    for n, padre in HUESOS.items():
        d = datos[n]
        hueso = arm_datos.edit_bones.new(n)
        # Cabeza del hueso: la unión con el padre. Cola: la unión con el hijo (o la punta).
        cabeza = punto(d["union"]) + sube
        cola = punto(d["cola"]) + sube
        if (cola - cabeza).length < 0.02:
            cola = cabeza + Vector((0, 0, 0.1))
        hueso.head, hueso.tail = cabeza, cola
        if padre:
            hueso.parent = arm_datos.edit_bones[padre]
    bpy.ops.object.mode_set(mode="OBJECT")

    for n in HUESOS:
        d = datos[n]
        nombre = f"{ESQUELETO}_{n}"
        me = bpy.data.meshes.new(nombre)
        if "verts" in d:
            me.from_pydata([_studio_a_blender(v) * STUD for v in d["verts"]], [], d["caras"])
            me.validate()
        else:
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            tam = Vector((d["tam"][0], d["tam"][2], d["tam"][1])) * STUD
            bmesh.ops.scale(bm, vec=tam, verts=bm.verts)
            bmesh.ops.bevel(bm, geom=bm.edges[:] + bm.verts[:], offset=min(tam) * 0.12, segments=3, affect="EDGES")
            bm.to_mesh(me)
            bm.free()
        me.shade_smooth()
        me.set_sharp_from_angle(angle=math.radians(30))
        obj = bpy.data.objects.new(nombre, me)
        bpy.context.scene.collection.objects.link(obj)
        obj.matrix_world = Matrix.Translation(punto(d["centro"]) + sube) @ _giro(d["giro"])
        aplicar_material(obj, "maniqui")
        pegar_a_hueso(obj, n)
    return arm


def exportar_maniqui():
    """Guarda el maniquí con su esqueleto en blender/maniqui-r15.fbx (en studs, ejes de Roblox)."""
    objs = [esqueleto()] + partes()
    for o in bpy.context.scene.objects:
        o.select_set(o in objs)
    bpy.context.view_layer.objects.active = esqueleto()
    bpy.ops.export_scene.fbx(
        filepath=MANIQUI_FBX,
        use_selection=True,
        object_types={"ARMATURE", "MESH"},
        global_scale=1 / STUD,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
        bake_space_transform=False,
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
        primary_bone_axis="Y",
        secondary_bone_axis="X",
        bake_anim=False,
    )
    return MANIQUI_FBX


def crear_kit():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    escena = bpy.context.scene
    escena.unit_settings.system = "METRIC"
    escena.unit_settings.scale_length = 1.0
    crear_materiales()
    _armar_maniqui()
    configurar_luz()
    configurar_camaras()
    os.makedirs(BLENDER, exist_ok=True)
    exportar_maniqui()
    bpy.ops.wm.save_as_mainfile(filepath=KIT)
    print("Kit guardado en", KIT)
    print("Triángulos:", contar_triangulos())
    print("Render:", render_vistas("maniqui"))


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "kit" in argumentos:
        crear_kit()
