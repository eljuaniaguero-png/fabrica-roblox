"""Kit de la arena con texturas compartidas (color, normal, rugosidad), para SurfaceAppearance.
Uso: blender -b --factory-startup -P linajes/arte/scripts/arena_kit2.py -- <carpeta de renders>
"""
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import arena_kit as A  # noqa: E402
import base as B  # noqa: E402

A.CELDAS = 2
JUEGO = {}


def imagen(juego, tipo):
    ruta = os.path.join(A.SALIDA, f"K_{juego}_{tipo}.png")
    img = bpy.data.images.load(ruta, check_existing=True)
    if tipo != "color":
        img.colorspace_settings.name = "Non-Color"
    return img


def por_nombre(nombre, _tonos=None):
    if nombre.startswith("Contenedor"):
        juego = "contenedor"
    elif nombre in ("Prop_Cartel", "Prop_Cajones"):
        juego = "madera"
    else:
        juego = "metal"
    JUEGO[nombre] = juego
    return imagen(juego, "color")


def muro_imagen(nombre):
    JUEGO[nombre] = "ladrillo"
    return imagen("ladrillo", "color")


A.tabla = por_nombre
A.ladrillos = muro_imagen


def completar(o):
    """Suma relieve y rugosidad al material para que Roblox arme el SurfaceAppearance."""
    mat = o.data.materials[0]
    juego = JUEGO[o.name]
    mat.name = "K_" + juego
    nodos = mat.node_tree
    bsdf = nodos.nodes["Principled BSDF"]
    rug = nodos.nodes.new("ShaderNodeTexImage")
    rug.image = imagen(juego, "rough")
    nodos.links.new(rug.outputs["Color"], bsdf.inputs["Roughness"])
    nor = nodos.nodes.new("ShaderNodeTexImage")
    nor.image = imagen(juego, "normal")
    mapa = nodos.nodes.new("ShaderNodeNormalMap")
    nodos.links.new(nor.outputs["Color"], mapa.inputs["Color"])
    nodos.links.new(mapa.outputs["Normal"], bsdf.inputs["Normal"])
    return o


def cajones():
    p = A.Pieza("Prop_Cajones", por_nombre("Prop_Cajones"))

    def cajon(x, y, z, lado):
        p.caja((x, y, z + lado / 2), (lado - 0.08, lado - 0.08, lado - 0.08), 1)
        for i in range(4):
            alto = z + 0.1 + i * (lado - 0.2) / 3
            for sy in (-1, 1):
                p.caja((x, y + sy * lado / 2, alto), (lado, 0.04, lado / 4.6), i % 2 * 2)
                p.caja((x + sy * lado / 2, y, alto), (0.04, lado, lado / 4.6), i % 2 * 2)
        for sx in (-1, 1):
            for sy in (-1, 1):
                p.caja((x + sx * (lado / 2 - 0.03), y + sy * (lado / 2 - 0.03), z + lado / 2), (0.1, 0.1, lado), 2)
        p.caja((x, y, z + lado), (lado, lado, 0.05), 0)

    cajon(-0.62, 0, 0, 1.15)
    cajon(0.62, 0.12, 0, 1.15)
    cajon(0, 0.05, 1.2, 1.05)
    return p.terminar()


bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, "arena-kit.blend"))
for n in ("Contenedor_Azul", "Contenedor_Gris", "Contenedor_Rojo", "Contenedor_Verde"):
    bpy.data.objects.remove(bpy.data.objects[n])
nuevas = [
    A.contenedor("Contenedor", "#ffffff"), A.barril(), A.bita(), A.techo(), A.cartel(), cajones(),
    A.muro(),
]
for o in nuevas:
    completar(o)
A.CELDAS = 4
extras = [bpy.data.objects[n] for n in (
    "Grua_Portico", "Grua_Estructura", "Grua_Cabina", "Prop_Farola", "Prop_Reja", "Prop_Alambrado",
    "Galpon_Pared", "Galpon_ParedPorton", "Prop_Red",
)]
A.exportar(nuevas + extras, "_PaqueteArena.fbx")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(B.BLENDER, "arena-kit2.blend"))
A.renders(nuevas, sys.argv[sys.argv.index("--") + 1])
