"""Chequeo automático de piezas separadas en todas las animaciones.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/chequeo_piezas.py

Para cada cuadro compara cada pieza con su hueso. Si la pieza sigue bien a su hueso, la
distancia entre los dos no cambia nunca. También mide si el pie se abre del tobillo.
Reporta 0 si ninguna pieza se separa. Además lista qué mallas forman el calzado.
"""

import os

import bpy
from mathutils import Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BLENDER = os.path.join(ARTE, "blender")
TOLERANCIA = 0.002  # 2 mm


def actualizar(escena, f):
    escena.frame_set(f)
    bpy.context.view_layer.update()


bpy.ops.wm.open_mainfile(filepath=os.path.join(BLENDER, "animaciones-base.blend"))
with bpy.data.libraries.load(os.path.join(BLENDER, "animaciones-linajes.blend")) as (src, dst):
    dst.actions = [a for a in src.actions if a.startswith("fuerzabruta")]
arm = bpy.data.objects["Maniqui"]
e = bpy.context.scene
piezas = [o for o in e.objects if o.type == "MESH" and o.parent == arm and o.parent_type == "BONE" and o.visible_get()]

for o in piezas:
    if "Foot" in o.parent_bone or "Zapa" in o.name:
        print("CALZADO", o.name, "hueso", o.parent_bone, "caras", len(o.data.polygons), "materiales", [m.name for m in o.data.materials if m])

arm.animation_data.action = None
for b in arm.pose.bones:
    b.matrix_basis.identity()
bpy.context.view_layer.update()
base = {o.name: arm.pose.bones[o.parent_bone].matrix.inverted() @ o.matrix_world for o in piezas}
total = 0
for a in sorted(bpy.data.actions, key=lambda x: x.name):
    arm.animation_data.action = a
    malos = {}
    tobillo = 0.0
    for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
        actualizar(e, f)
        for o in piezas:
            rel = arm.pose.bones[o.parent_bone].matrix.inverted() @ o.matrix_world
            d = (rel.translation - base[o.name].translation).length
            if d > TOLERANCIA:
                malos[o.name] = max(malos.get(o.name, 0), round(d, 4))
        for lado in ("Left", "Right"):
            pie = arm.pose.bones[f"{lado}Foot"].head
            pierna = arm.pose.bones[f"{lado}LowerLeg"].tail
            tobillo = max(tobillo, (pie - pierna).length)
    total += len(malos)
    print("PIEZAS", a.name, "separadas", len(malos), "tobillo", round(tobillo, 4), list(malos.items())[:4])
print("TOTAL_SEPARADAS", total)
