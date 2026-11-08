"""Hoja de muestra de los 6 materiales del puerto, para comparar con
boveda/02 Estilo/referencias/estilo-05-materiales.png.

Uso dentro de Blender:
    exec(open(r"<ruta>/materiales.py").read())
    exec(open(r"<ruta>/muestra_materiales.py").read())
    armar_muestra(); render_muestra(r"<ruta>/renders/muestra-materiales.png")
"""

import bpy
import math

NOMBRES = [
    "MAT_CementoMojado",
    "MAT_ChapaOxidada",
    "MAT_Ladrillo",
    "MAT_MaderaGastada",
    "MAT_MetalPiso",
    "MAT_TablasMuelle",
]


def limpiar_escena():
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)


def cubo(nombre, pos, tam=(0.5, 0.5, 0.5), bisel=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    ob = bpy.context.active_object
    ob.name = nombre
    ob.scale = tam
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    mod = ob.modifiers.new("Bisel", "BEVEL")
    mod.width = bisel
    mod.segments = 3
    mod.harden_normals = False
    bpy.ops.object.shade_auto_smooth(angle=math.radians(40))
    return ob


def armar_muestra():
    limpiar_escena()
    materiales = {n: bpy.data.materials[n] for n in NOMBRES if n in bpy.data.materials}
    for i, nombre in enumerate(NOMBRES):
        fila, col = divmod(i, 3)
        ob = cubo(
            nombre.replace("MAT_", "Muestra_"),
            (col * 1.3 - 1.3, -fila * 1.3 + 0.65, 0.5),
        )
        if nombre in materiales:
            ob.data.materials.append(materiales[nombre])

    # Piso neutro gris, como el fondo de la hoja de referencia.
    bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 0, 0))
    piso = bpy.context.active_object
    piso.name = "PisoMuestra"
    mat = bpy.data.materials.new("MAT_FondoMuestra")
    mat.use_nodes = True
    bsdf = next(nd for nd in mat.node_tree.nodes if nd.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (0.055, 0.055, 0.06, 1)
    bsdf.inputs["Roughness"].default_value = 0.95
    piso.data.materials.append(mat)

    # Luz: un sol tibio de tres cuartos y un relleno frio, como el atardecer.
    bpy.ops.object.light_add(type="SUN", location=(4, -3, 6))
    sol = bpy.context.active_object
    sol.data.energy = 1.9
    sol.data.angle = math.radians(8)
    sol.data.color = (1.0, 0.82, 0.62)
    sol.rotation_euler = (math.radians(52), 0, math.radians(38))

    bpy.ops.object.light_add(type="AREA", location=(-4, -4, 3))
    relleno = bpy.context.active_object
    relleno.data.energy = 70
    relleno.data.size = 6
    relleno.data.color = (0.55, 0.68, 1.0)
    relleno.rotation_euler = (math.radians(65), 0, math.radians(-45))

    bpy.ops.object.camera_add(location=(0, -6.2, 4.4))
    cam = bpy.context.active_object
    cam.name = "CamMuestra"
    cam.data.lens = 52
    cam.rotation_euler = (math.radians(60), 0, 0)
    bpy.context.scene.camera = cam

    mundo = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = mundo
    mundo.use_nodes = True
    fondo = next(nd for nd in mundo.node_tree.nodes if nd.type == "BACKGROUND")
    fondo.inputs[0].default_value = (0.03, 0.035, 0.05, 1)
    fondo.inputs[1].default_value = 0.6
    return True


def render_muestra(ruta, muestras=96, ancho=1280, alto=720):
    esc = bpy.context.scene
    # Sin AgX: para pintar texturas hay que ver el color como es.
    esc.view_settings.view_transform = "Standard"
    esc.view_settings.look = "None"
    esc.view_settings.exposure = 0.0
    esc.render.engine = "CYCLES"
    try:
        esc.cycles.device = "GPU"
    except Exception:
        pass
    esc.cycles.samples = muestras
    esc.cycles.use_denoising = True
    esc.render.resolution_x = ancho
    esc.render.resolution_y = alto
    esc.render.resolution_percentage = 100
    esc.render.image_settings.file_format = "PNG"
    esc.render.filepath = ruta
    bpy.ops.render.render(write_still=True)
    return ruta
