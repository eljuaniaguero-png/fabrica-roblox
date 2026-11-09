"""Hoja de 4 vistas de la grúa sola, para que Juani la apruebe.

Uso:
    blender.exe -b --python linajes/arte/scripts/arena/render_grua.py -- salida_base.png
Genera salida_base-1.png .. -4.png (frente, costado, tres cuartos, atras).
"""

import math
import os
import sys

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))


def correr(archivo, entorno):
    with open(os.path.join(AQUI, archivo), encoding="utf-8") as f:
        exec(f.read(), entorno)


def limpiar():
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)


def usar_gpu():
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        for tipo in ("OPTIX", "CUDA", "HIP", "ONEAPI"):
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


def emisor(nombre, color, fuerza):
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


def escenario():
    """Piso neutro y luz de estudio: tres luces y un cielo gris."""
    bpy.ops.mesh.primitive_plane_add(size=300, location=(0, 0, 0))
    piso = bpy.context.active_object
    m = bpy.data.materials.new("MAT_PisoEstudio")
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Base Color"].default_value = (0.055, 0.058, 0.065, 1)
    b.inputs["Roughness"].default_value = 0.9
    piso.data.materials.append(m)

    mundo = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = mundo
    mundo.use_nodes = True
    fondo = next(nd for nd in mundo.node_tree.nodes if nd.type == "BACKGROUND")
    fondo.inputs[0].default_value = (0.09, 0.10, 0.12, 1)
    fondo.inputs[1].default_value = 1.6

    bpy.ops.object.light_add(type="SUN", location=(0, 0, 60))
    sol = bpy.context.active_object
    sol.data.energy = 5.5
    sol.data.angle = math.radians(6)
    sol.data.color = (1.0, 0.93, 0.84)
    sol.rotation_euler = (math.radians(52), 0, math.radians(35))

    bpy.ops.object.light_add(type="AREA", location=(-30, -25, 24))
    relleno = bpy.context.active_object
    relleno.data.energy = 26000
    relleno.data.size = 28
    relleno.data.color = (0.6, 0.72, 1.0)
    relleno.rotation_euler = (math.radians(62), 0, math.radians(-50))


def camara(nombre, pos, objetivo, lente=50):
    import mathutils

    bpy.ops.object.camera_add(location=pos)
    cam = bpy.context.active_object
    cam.name = nombre
    cam.data.lens = lente
    d = mathutils.Vector(objetivo) - mathutils.Vector(pos)
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
    return cam


def main():
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    base = args[0] if args else os.path.join(AQUI, "grua.png")
    muestras = int(args[1]) if len(args) > 1 else 64

    entorno = {"__name__": "mat"}
    correr("materiales.py", entorno)
    entorno["construir_todos"]()
    limpiar()
    escenario()

    g = {"__name__": "grua"}
    correr("grua.py", g)
    metal = bpy.data.materials.get("MAT_Grua") or bpy.data.materials["MAT_MetalPiso"]
    g["armar_grua"](
        nombre="Grua",
        centro=(0, 0, 0),
        giro=0.0,
        escala=1.0,
        col=None,
        metal=metal,
        emisor_cabina=emisor("MAT_LuzCabina", (1.0, 0.76, 0.46, 1), 1.2),
        emisor_roja=emisor("MAT_LuzRoja", (1.0, 0.12, 0.08, 1), 4.0),
    )

    esc = bpy.context.scene
    esc.render.engine = "CYCLES"
    esc.cycles.samples = muestras
    esc.cycles.use_denoising = True
    esc.render.resolution_x = 900
    esc.render.resolution_y = 1100
    esc.view_settings.view_transform = "Standard"
    usar_gpu()

    centro = (4, 0, 15)
    vistas = [
        ("1-costado", (2, -54, 16)),
        ("2-tresCuartos", (38, -40, 22)),
        ("3-frente", (54, 2, 16)),
        ("4-atras", (-46, -24, 20)),
    ]
    raiz, ext = os.path.splitext(base)
    for nombre, pos in vistas:
        cam = camara("Cam_" + nombre, pos, centro, lente=50)
        esc.camera = cam
        esc.render.filepath = "%s-%s%s" % (raiz, nombre, ext)
        bpy.ops.render.render(write_still=True)
        print("VISTA:", esc.render.filepath)
    print("LISTO")


main()
