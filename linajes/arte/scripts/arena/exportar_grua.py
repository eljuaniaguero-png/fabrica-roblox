"""Deja la grúa lista para Roblox: une las piezas en pocas mallas, les saca UV,
hornea las texturas (Color con AO, Normal OpenGL, Rugosidad y Metal a 1024) y
exporta un FBX en studs.

Uso:
    blender.exe -b --python linajes/arte/scripts/arena/exportar_grua.py

Salida: linajes/arte/exports/grua-puerto/ (FBX, PNG y medidas.json).
"""

import json
import math
import os
import sys

import bpy
import numpy as np

AQUI = os.path.dirname(os.path.abspath(__file__))
ARTE = os.path.dirname(os.path.dirname(AQUI))
SALIDA = os.path.join(ARTE, "exports", "grua-puerto")
STUD = 0.28
TAM = 1024
TOPE_TRIANGULOS = 20000

GRUPOS = {
    "Grua_Portico": ("_Riel", "_Carro", "_Pata", "_Cruz", "_Trav", "_TravAlto", "_Peldano",
                     "_Larguero"),
    "Grua_Cuerpo": ("_Plataforma", "_Casa", "_TechoCasa", "_VentanaCasa", "_Baranda", "_Parante",
                    "_CabinaFondo", "_CabinaLado", "_CabinaTecho", "_CabinaBase",
                    "_CabinaAntepecho", "_CabinaDintel", "_CabinaPilar", "_CabinaPiso", "_MarcoH",
                    "_MarcoV", "_Mastil", "_Tirante", "_TiranteCola", "_Contrapluma",
                    "_Contrapeso"),
    "Grua_Brazo": ("_Brazo", "_BrazoBajo", "_Montante", "_Diagonal", "_Polea", "_Cable",
                   "_Motón", "_Gancho", "_GanchoPunta"),
    "Grua_Vidrio": ("_CabinaVidrio",),
    "Grua_Interior": ("_Asiento", "_Respaldo", "_Tablero", "_Palanca"),
}


def correr(archivo, entorno):
    with open(os.path.join(AQUI, archivo), encoding="utf-8") as f:
        exec(f.read(), entorno)


def usar_gpu():
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        for tipo in ("OPTIX", "CUDA"):
            try:
                prefs.compute_device_type = tipo
            except TypeError:
                continue
            prefs.get_devices()
            if any(d.type != "CPU" for d in prefs.devices):
                for d in prefs.devices:
                    d.use = d.type != "CPU"
                bpy.context.scene.cycles.device = "GPU"
                return tipo
    except Exception:
        pass
    return "CPU"


def sufijo(nombre):
    """'Grua_Rueda.003' -> '_Rueda'."""
    base = nombre.split(".")[0]
    return base[len("Grua"):]


def clasificar(ob):
    s = sufijo(ob.name)
    if s == "_Rueda":
        # Las ruedas de abajo son del portico; las de la punta, del brazo.
        return "Grua_Portico" if ob.matrix_world.translation.z < 3.0 else "Grua_Brazo"
    for grupo, sufijos in GRUPOS.items():
        if s in sufijos:
            return grupo
    return None


def seleccionar(objs):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]


def unir(nombre, objs):
    for o in objs:
        seleccionar([o])
        for mod in list(o.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                o.modifiers.remove(mod)
    seleccionar(objs)
    if len(objs) > 1:
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    ob.name = nombre
    ob.data.name = nombre
    # Origen en la base, al centro (0,0,0 del mundo): asi todas las mallas comparten pivote.
    bpy.context.scene.cursor.location = (0, 0, 0)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return ob


def triangulos(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def aligerar(ob):
    n = triangulos(ob)
    if n > TOPE_TRIANGULOS:
        mod = ob.modifiers.new("Aligerar", "DECIMATE")
        mod.ratio = (TOPE_TRIANGULOS * 0.95) / n
        seleccionar([ob])
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return triangulos(ob)


def desplegar(ob):
    seleccionar([ob])
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.004,
                             area_weight=0.0, scale_to_bounds=True)
    bpy.ops.object.mode_set(mode="OBJECT")


def imagen(nombre, tam, color=True):
    img = bpy.data.images.get(nombre)
    if img:
        bpy.data.images.remove(img)
    img = bpy.data.images.new(nombre, tam, tam, alpha=False, float_buffer=False)
    img.colorspace_settings.name = "sRGB" if color else "Non-Color"
    return img


def nodo_destino(mat, img):
    nt = mat.node_tree
    nd = nt.nodes.get("DESTINO_BAKE")
    if not nd:
        nd = nt.nodes.new("ShaderNodeTexImage")
        nd.name = "DESTINO_BAKE"
    nd.image = img
    for n in nt.nodes:
        n.select = False
    nd.select = True
    nt.nodes.active = nd
    return nd


def fuente(mat, enchufe):
    """De donde sale un enchufe del Principled (o el nodo COLOR_BAKE del vidrio)."""
    nt = mat.node_tree
    if enchufe == "COLOR_BAKE":
        nd = nt.nodes.get("COLOR_BAKE")
        if nd:
            return next(s for s in nd.outputs if s.identifier == "Result_Color"), None
        return None, (0.5, 0.5, 0.5, 1)
    bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if not bsdf:
        return None, (0.5, 0.5, 0.5, 1)
    s = bsdf.inputs[enchufe]
    if s.links:
        return s.links[0].from_socket, None
    v = s.default_value
    if hasattr(v, "__len__"):
        return None, tuple(v)
    return None, (v, v, v, 1)


def hornear_emision(ob, mat, enchufe, img, margen=8):
    """Hornea un canal pasandolo por una Emision: asi el metal no ennegrece el color."""
    nt = mat.node_tree
    salida = next(n for n in nt.nodes if n.type == "OUTPUT_MATERIAL")
    original = salida.inputs["Surface"].links[0].from_socket if salida.inputs["Surface"].links else None
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs[1].default_value = 1.0
    origen, valor = fuente(mat, enchufe)
    if origen is not None:
        nt.links.new(origen, em.inputs[0])
    else:
        em.inputs[0].default_value = valor
    nt.links.new(em.outputs[0], salida.inputs["Surface"])
    nodo_destino(mat, img)
    seleccionar([ob])
    bpy.ops.object.bake(type="EMIT", margin=margen, use_clear=True)
    if original is not None:
        nt.links.new(original, salida.inputs["Surface"])
    nt.nodes.remove(em)


def hornear_tipo(ob, mat, tipo, img, margen=8):
    nodo_destino(mat, img)
    seleccionar([ob])
    if tipo == "NORMAL":
        bpy.ops.object.bake(type="NORMAL", margin=margen, use_clear=True,
                            normal_space="TANGENT", normal_r="POS_X", normal_g="POS_Y",
                            normal_b="POS_Z")
    else:
        bpy.ops.object.bake(type=tipo, margin=margen, use_clear=True)


def pixeles(img):
    a = np.empty(img.size[0] * img.size[1] * 4, dtype=np.float32)
    img.pixels.foreach_get(a)
    return a.reshape(-1, 4)


def guardar(img, ruta):
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()


def main():
    os.makedirs(SALIDA, exist_ok=True)
    entorno = {"__name__": "mat"}
    correr("materiales.py", entorno)
    entorno["construir_todos"]()
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob, do_unlink=True)

    g = {"__name__": "grua"}
    correr("grua.py", g)
    metal = bpy.data.materials["MAT_Grua"]
    vidrio = bpy.data.materials["MAT_VidrioCabina"]
    interior = bpy.data.materials["MAT_InteriorCabina"]
    _, puntos = g["armar_grua"](nombre="Grua", centro=(0, 0, 0), giro=0.0, escala=1.0, col=None,
                                metal=metal, vidrio=vidrio, interior=interior, emisor_roja=None)

    por_grupo = {k: [] for k in GRUPOS}
    sobrantes = []
    for ob in list(bpy.data.objects):
        if ob.type != "MESH":
            continue
        grupo = clasificar(ob)
        if grupo:
            por_grupo[grupo].append(ob)
        else:
            sobrantes.append(ob.name)
    # La luz de la punta se hace como Part en Studio; lo demas que sobre, se avisa.
    for nombre in sobrantes:
        if "_LuzPunta" not in nombre:
            print("SIN GRUPO:", nombre)
        bpy.data.objects.remove(bpy.data.objects[nombre], do_unlink=True)

    esc = bpy.context.scene
    esc.render.engine = "CYCLES"
    esc.cycles.samples = 24
    esc.cycles.use_denoising = False
    print("DISPOSITIVO:", usar_gpu())

    medidas = {"stud": STUD, "mallas": {}, "luces": {}}
    mallas = []
    for nombre, objs in por_grupo.items():
        if not objs:
            print("GRUPO VACIO:", nombre)
            continue
        ob = unir(nombre, objs)
        tris = aligerar(ob)
        desplegar(ob)
        mallas.append(ob)
        bb = [ob.matrix_world @ __import__("mathutils").Vector(c) for c in ob.bound_box]
        mn = [min(v[i] for v in bb) for i in range(3)]
        mx = [max(v[i] for v in bb) for i in range(3)]
        medidas["mallas"][nombre] = {
            "triangulos": tris,
            "tam_studs": [round((mx[i] - mn[i]) / STUD, 2) for i in range(3)],
            "centro_studs": [round((mx[i] + mn[i]) / 2 / STUD, 2) for i in range(3)],
        }
        print("MALLA:", nombre, tris, "tris")

    # Horneado.
    for ob in mallas:
        mat = ob.data.materials[0]
        nombre = ob.name
        if nombre == "Grua_Interior":
            continue  # color liso: en Studio lleva Color y nada mas
        tam = 256 if nombre == "Grua_Vidrio" else TAM
        if nombre == "Grua_Vidrio":
            color = imagen(nombre + "_color", tam)
            hornear_emision(ob, mat, "COLOR_BAKE", color, margen=4)
            guardar(color, os.path.join(SALIDA, nombre + "_color.png"))
            print("HORNEADO:", nombre)
            continue
        color = imagen(nombre + "_color", tam)
        hornear_emision(ob, mat, "Base Color", color)
        ao = imagen(nombre + "_ao", tam, color=False)
        hornear_tipo(ob, mat, "AO", ao)
        # Color x AO (suavizado: el AO puro ensucia demasiado).
        c = pixeles(color)
        a = pixeles(ao)
        sombra = 0.45 + 0.55 * a[:, :1]
        c[:, :3] *= sombra
        color.pixels.foreach_set(c.reshape(-1))
        guardar(color, os.path.join(SALIDA, nombre + "_color.png"))
        normal = imagen(nombre + "_normal", tam, color=False)
        hornear_tipo(ob, mat, "NORMAL", normal)
        guardar(normal, os.path.join(SALIDA, nombre + "_normal.png"))
        rug = imagen(nombre + "_rugosidad", tam, color=False)
        hornear_emision(ob, mat, "Roughness", rug)
        guardar(rug, os.path.join(SALIDA, nombre + "_rugosidad.png"))
        met = imagen(nombre + "_metal", tam, color=False)
        hornear_emision(ob, mat, "Metallic", met)
        guardar(met, os.path.join(SALIDA, nombre + "_metal.png"))
        print("HORNEADO:", nombre)

    for clave, pos in puntos.items():
        medidas["luces"][clave] = [round(pos[0] / STUD, 2), round(pos[2] / STUD, 2),
                                   round(-pos[1] / STUD, 2)]
    with open(os.path.join(SALIDA, "medidas.json"), "w", encoding="utf-8") as f:
        json.dump(medidas, f, indent=2, ensure_ascii=False)

    seleccionar(mallas)
    ruta = os.path.join(SALIDA, "GruaPuerto.fbx")
    bpy.ops.export_scene.fbx(
        filepath=ruta, use_selection=True, object_types={"MESH"}, global_scale=1 / STUD,
        apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS", axis_forward="Z",
        axis_up="Y", bake_space_transform=True, use_mesh_modifiers=True,
        mesh_smooth_type="FACE", add_leaf_bones=False, bake_anim=False,
    )
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ARTE, "blender", "grua-puerto.blend"))
    print("FBX:", ruta)
    print("LISTO")


main()
