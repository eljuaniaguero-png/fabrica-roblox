"""Saca el color de cada malla de la decoración (Deco_Comun y Deco_Zona1..5) y escribe
src/server/DecoColores.luau. El FBX llega a Studio sin colores, así que GeneradorMapa pinta cada
malla con esto. Las que van en Neon (lava, cristales, estrellas) y las transparentes (agua,
hielo) se eligen por el nombre del material de Blender (decoracion.py).

Uso: <blender.exe> -b --factory-startup --python forja-rapida/arte/scripts/deco_colores.py
"""

import os

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))
FBX = os.path.join(AQUI, "..", "fbx")
SALIDA = os.path.join(AQUI, "..", "..", "src", "server", "DecoColores.luau")
ARCHIVOS = ["Deco_Comun"] + ["Deco_Zona%d" % n for n in range(1, 6)]
NEON = {
    "AmbarBrillo", "ArbolEstrellas", "Estrellas", "Cuarzo", "CuarzoPunta", "IslaCristal",
    "MeteoritoEstrella", "MeteoritoNucleo", "QuemadoBrasa", "RacimoRosa", "RacimoVioleta",
    "RioAmarilla", "RioNaranja", "RocaLavaCristal", "RocaLavaGrieta", "BasaltoLava", "VolcanLava",
    "Detalle_Zona4", "Detalle_Zona5", "Losas_Detalle_Zona4", "Losas_Detalle_Zona5",
}
TRANSPARENTE = {"CascadaAgua": 0.35, "Lago_hielo": 0.15}


def hexa(c):
    return "#%02X%02X%02X" % tuple(round(max(0.0, min(1.0, x)) ** (1 / 2.2) * 255) for x in c[:3])


colores = {}
for nombre in ARCHIVOS:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=os.path.join(FBX, nombre + ".fbx"))
    for o in bpy.data.objects:
        m = o.active_material if o.type == "MESH" else None
        if not (m and o.parent):
            continue
        base = m.node_tree.nodes.get("Principled BSDF") if m.node_tree else None
        c = base.inputs["Base Color"].default_value if base else m.diffuse_color
        mat = m.name.split(".")[0]
        colores[o.name.split(".")[0]] = (hexa(c), mat in NEON, TRANSPARENTE.get(mat, 0))

lineas = [
    "--!strict",
    "-- Generado por forja-rapida/arte/scripts/deco_colores.py (no editar a mano).",
    "-- Color de cada malla de la decoración: malla -> { Color, Neon, Transparencia }.",
    "",
    "export type Color = { Color: string, Neon: boolean, Transparencia: number }",
    "",
    "local colores: { [string]: Color } = {",
]
for k in sorted(colores):
    c, neon, t = colores[k]
    lineas.append('\t%s = { Color = "%s", Neon = %s, Transparencia = %s },' % (k, c, "true" if neon else "false", t))
lineas += ["}", "", "return colores"]
with open(SALIDA, "w", encoding="utf-8") as f:
    f.write("\n".join(lineas) + "\n")
print("COLORES", len(colores))
