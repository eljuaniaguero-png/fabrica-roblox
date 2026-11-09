"""Arma la arena y la renderiza SIN abrir Blender (modo consola).

Uso:
    "C:\\Program Files\\Blender Foundation\\Blender 5.2\\blender.exe" -b ^
        --python linajes/arte/scripts/arena/render_arena.py -- atardecer salida.png [muestras]

El primer argumento después de "--" es la luz (atardecer o noche), el segundo la ruta
de salida y el tercero, opcional, la cantidad de muestras.
"""

import os
import sys

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))


def argumentos():
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    return []


def correr(archivo, entorno):
    with open(os.path.join(AQUI, archivo), encoding="utf-8") as f:
        exec(f.read(), entorno)


def usar_gpu():
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        for tipo in ("OPTIX", "CUDA", "HIP", "ONEAPI"):
            try:
                prefs.compute_device_type = tipo
            except TypeError:
                continue
            prefs.get_devices()
            prendidas = 0
            for d in prefs.devices:
                d.use = d.type != "CPU"
                prendidas += 1 if d.use else 0
            if prendidas:
                bpy.context.scene.cycles.device = "GPU"
                return tipo
    except Exception:
        pass
    return "CPU"


def posproducción(luz):
    """Bloom (glow en lo emisivo) y color grading. En Roblox esto es
    BloomEffect + ColorCorrectionEffect + SunRaysEffect."""
    esc = bpy.context.scene
    # Blender 5: el compositor es un grupo de nodos (scene.compositing_node_group).
    grupo = bpy.data.node_groups.get("PostArena")
    if grupo:
        bpy.data.node_groups.remove(grupo)
    grupo = bpy.data.node_groups.new("PostArena", "CompositorNodeTree")
    esc.compositing_node_group = grupo
    nt = grupo
    for nd in list(nt.nodes):
        nt.nodes.remove(nd)
    entrada = nt.nodes.new("NodeGroupInput")
    entrada.location = (-800, 0)
    if not grupo.interface.items_tree:
        grupo.interface.new_socket("Image", in_out="INPUT", socket_type="NodeSocketColor")
        grupo.interface.new_socket("Image", in_out="OUTPUT", socket_type="NodeSocketColor")
    rl = nt.nodes.new("CompositorNodeRLayers")
    rl.location = (-600, 0)
    glare = nt.nodes.new("CompositorNodeGlare")
    glare.location = (-300, 0)

    def poner(nodo, nombre, valor, indice=0):
        """En Blender 5 los ajustes del Glare y del ColorBalance son enchufes."""
        encontrados = [i for i in nodo.inputs if i.name == nombre]
        if not encontrados:
            return
        encontrados[min(indice, len(encontrados) - 1)].default_value = valor

    poner(glare, "Type", "Bloom")
    poner(glare, "Quality", "High")
    poner(glare, "Threshold", 1.0 if luz == "noche" else 1.7)
    poner(glare, "Size", 0.5)
    poner(glare, "Strength", 0.35 if luz == "noche" else 0.13)
    poner(glare, "Smoothness", 0.35)

    balance = nt.nodes.new("CompositorNodeColorBalance")
    balance.location = (0, 0)
    poner(balance, "Type", "Lift/Gamma/Gain")
    if luz == "noche":
        poner(balance, "Lift", (0.97, 0.99, 1.06, 1.0), indice=1)
        poner(balance, "Gain", (1.0, 1.0, 1.06, 1.0), indice=1)
    else:
        poner(balance, "Lift", (1.03, 0.99, 1.08, 1.0), indice=1)
        poner(balance, "Gain", (1.09, 1.02, 0.90, 1.0), indice=1)

    salida = nt.nodes.new("NodeGroupOutput")
    salida.location = (320, 0)
    nt.links.new(rl.outputs["Image"], glare.inputs["Image"])
    nt.links.new(glare.outputs["Image"], balance.inputs["Image"])
    nt.links.new(balance.outputs["Image"], salida.inputs[0])
    return True


def main():
    args = argumentos()
    luz = args[0] if args else "atardecer"
    salida = args[1] if len(args) > 1 else os.path.join(AQUI, "arena.png")
    muestras = int(args[2]) if len(args) > 2 else 64

    entorno = {"__name__": "arena_escena"}
    correr("materiales.py", entorno)
    entorno["construir_todos"]()
    correr("arena.py", entorno)
    entorno["armar_arena"]()
    entorno["poner_camara"]()
    if luz == "noche":
        entorno["luz_noche"]()
        bpy.context.scene.view_settings.exposure = 0.25
    else:
        entorno["luz_atardecer"]()
        bpy.context.scene.view_settings.exposure = -0.6
    entorno["pelea_central"]()
    entorno["ajustes_render"](muestras=muestras, ancho=1280, alto=720)
    posproducción(luz)
    dispositivo = usar_gpu()
    vista = bpy.context.scene.view_settings
    vista.view_transform = "Standard"
    vista.use_curve_mapping = False
    # Curva en S solo de dia: de noche hundiria todo en negro.
    vista.use_curve_mapping = luz != "noche"
    curva = vista.curve_mapping.curves[3]
    while len(curva.points) > 2:
        curva.points.remove(curva.points[1])
    curva.points[0].location = (0.0, 0.0)
    curva.points[1].location = (1.0, 1.0)
    curva.points.new(0.22, 0.09)
    curva.points.new(0.62, 0.72)
    vista.curve_mapping.update()
    bpy.context.scene.render.filepath = salida
    print("RENDER: luz=%s dispositivo=%s objetos=%d" % (luz, dispositivo, len(bpy.data.objects)))
    bpy.ops.render.render(write_still=True)
    entorno["poner_camara"]()
    bpy.context.scene.render.filepath = salida
    if len(args) > 3 and args[3]:
        bpy.ops.wm.save_as_mainfile(filepath=args[3])
        print("GUARDADO:", args[3])
    # Segunda captura: desde la camara del juego, detras del personaje.
    entorno["camara_juego"]()
    raiz, ext = os.path.splitext(salida)
    bpy.context.scene.render.filepath = raiz + "-juego" + ext
    bpy.ops.render.render(write_still=True)
    print("JUEGO:", raiz + "-juego" + ext)
    print("LISTO:", salida)


main()
