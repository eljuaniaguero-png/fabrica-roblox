"""Peinados de mechones anchos y curvos para el cuerpo cómic. Prueba de 3 opciones.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/pelo_comic.py

Renderiza renders/pelo-comic-opciones.png sin tocar cuerpo-comic.blend. Un mechón es una tira
ancha que se afina hasta una punta siguiendo una curva: se ve como pelo dibujado.
"""

import math
import os

import bpy
from mathutils import Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
Z = 1.363  # centro de la cabeza


def mat(nombre, h):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*[(int(h[i : i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)], 1)
    b.inputs["Roughness"].default_value = 0.5
    return m


def mechon(nombre, p0, p1, p2, ancho, grosor, material, afuera=(0, -1, 0.3), pasos=6):
    """Tira de sección rectangular de p0 a p2, curvada hacia p1. afuera marca hacia dónde mira."""
    a, b, c = (Vector((x, y, z + Z)) for x, y, z in (p0, p1, p2))
    verts, caras = [], []
    frente = Vector(afuera).normalized()
    for i in range(pasos + 1):
        t = i / pasos
        p = a * (1 - t) ** 2 + b * 2 * t * (1 - t) + c * t * t
        d = (2 * (1 - t) * (b - a) + 2 * t * (c - b)).normalized()
        lado = d.cross(frente).normalized()
        n = lado.cross(d).normalized()
        w = ancho * (1 - t**1.6) * (0.75 + 0.5 * math.sin(min(t * 2.2, 1) * math.pi / 2)) + 0.0015
        g = grosor * (1 - t) + 0.001
        for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
            verts.append(p + lado * w * sx + n * g * sy)
    for i in range(pasos):
        k = i * 4
        for j in range(4):
            caras.append((k + j, k + (j + 1) % 4, k + 4 + (j + 1) % 4, k + 4 + j))
    caras.append((0, 3, 2, 1))
    caras.append(tuple(pasos * 4 + j for j in range(4)))
    me = bpy.data.meshes.new(nombre)
    me.from_pydata([tuple(v) for v in verts], [], caras)
    me.polygons.foreach_set("use_smooth", [True] * len(me.polygons))
    me.materials.append(material)
    o = bpy.data.objects.new(nombre, me)
    bpy.context.collection.objects.link(o)
    s = o.modifiers.new("Borde", "SOLIDIFY")
    s.thickness, s.offset, s.use_flip_normals, s.material_offset = 0.006, 1, True, 1
    me.materials.append(bpy.data.materials["Contorno"])
    return o


def casco(nombre, material, alto=0.1):
    """Base al ras de la cabeza y nuca: no se ve como gorra, solo evita que asome piel."""
    for sufijo, lugar, medida in (("T", (0, 0, Z + 0.165), (0.345, 0.315, 0.02)), ("N", (0, 0.15, Z + 0.05), (0.345, 0.025, 0.25)), ("I", (-0.165, 0.06, Z + 0.09), (0.02, 0.2, 0.15)), ("D", (0.165, 0.06, Z + 0.09), (0.02, 0.2, 0.15))):
        bpy.ops.mesh.primitive_cube_add(size=1, location=lugar)
        o = bpy.context.object
        o.name = nombre + sufijo
        o.scale = medida
        o.data.materials.append(material)


def barrido(n, oscuro, luz):
    """Opción 1: flequillo barrido a un costado, en dos capas."""
    casco(n, oscuro)
    for i, x in enumerate((-0.17, -0.1, -0.03, 0.04, 0.11, 0.17)):
        mechon(f"{n}F{i}", (x, -0.15, 0.2), (x + 0.1, -0.2, 0.1), (x + 0.15, -0.165, -0.03 - 0.03 * (i % 2)), 0.055, 0.016, oscuro)
    for i, x in enumerate((-0.13, -0.05, 0.03, 0.11)):
        mechon(f"{n}L{i}", (x, -0.1, 0.25), (x + 0.1, -0.2, 0.22), (x + 0.16, -0.19, 0.08), 0.04, 0.013, luz)
    for i, x in enumerate((-0.15, -0.05, 0.05, 0.15)):
        mechon(f"{n}A{i}", (x, 0.08, 0.26), (x * 1.5, 0.28, 0.2), (x * 1.3, 0.24, -0.04), 0.062, 0.02, oscuro, (0, 1, 0.3))
    for lado in (-1, 1):
        for i, y in enumerate((-0.09, 0.02, 0.1)):
            mechon(f"{n}C{lado}{i}", (0.17 * lado, y, 0.15), (0.22 * lado, y + 0.02, 0.05), (0.19 * lado, y + 0.03, -0.07), 0.05, 0.016, oscuro, (lado, 0, 0.2))


def atras(n, oscuro, luz):
    """Opción 2: todo peinado hacia atrás y arriba, con mucho volumen."""
    casco(n, oscuro)
    for i, x in enumerate((-0.16, -0.09, -0.02, 0.05, 0.12, 0.17)):
        mechon(f"{n}F{i}", (x, -0.15, 0.16), (x * 1.15, -0.12, 0.34), (x * 1.3, 0.1, 0.4 - abs(x) * 0.5), 0.06, 0.02, oscuro, (0, -0.4, 1))
    for i, x in enumerate((-0.11, -0.03, 0.05, 0.12)):
        mechon(f"{n}L{i}", (x, -0.05, 0.25), (x * 1.2, 0, 0.38), (x * 1.5, 0.21, 0.32), 0.04, 0.014, luz, (0, -0.2, 1))
    for i, x in enumerate((-0.16, -0.06, 0.06, 0.16)):
        mechon(f"{n}A{i}", (x, 0.1, 0.22), (x * 1.5, 0.3, 0.14), (x * 1.35, 0.3, -0.05), 0.06, 0.02, oscuro, (0, 1, 0.3))
    for lado in (-1, 1):
        for i, y in enumerate((-0.07, 0.05)):
            mechon(f"{n}C{lado}{i}", (0.17 * lado, y, 0.13), (0.23 * lado, y + 0.08, 0.18), (0.22 * lado, y + 0.2, 0.08), 0.05, 0.016, oscuro, (lado, 0, 0.3))


def rebelde(n, oscuro, luz):
    """Opción 3: mechones grandes abiertos, puntas pocas y marcadas."""
    casco(n, oscuro)
    datos = [(-0.17, -0.25, 0.22), (-0.09, -0.12, 0.3), (0.0, 0.04, 0.34), (0.09, 0.15, 0.3), (0.17, 0.27, 0.2)]
    for i, (x, tx, alto) in enumerate(datos):
        mechon(f"{n}F{i}", (x, -0.13, 0.17), (x * 1.1, -0.17, alto), (tx, -0.1, alto + 0.08), 0.075, 0.022, oscuro, (0, -1, 0.4))
    for i, x in enumerate((-0.12, -0.04, 0.05, 0.13)):
        mechon(f"{n}G{i}", (x, -0.155, 0.19), (x + 0.03, -0.19, 0.08), (x + 0.015, -0.165, -0.02 - 0.05 * (i % 2)), 0.045, 0.014, luz)
    for i, x in enumerate((-0.16, -0.05, 0.06, 0.17)):
        mechon(f"{n}A{i}", (x, 0.08, 0.22), (x * 1.4, 0.27, 0.16), (x * 1.3, 0.25, -0.06), 0.07, 0.02, oscuro, (0, 1, 0.4))
    for lado in (-1, 1):
        mechon(f"{n}C{lado}", (0.17 * lado, 0, 0.16), (0.22 * lado, 0.02, 0.14), (0.24 * lado, 0.03, 0.02), 0.06, 0.018, oscuro, (lado, 0, 0.3))
        mechon(f"{n}D{lado}", (0.17 * lado, 0.09, 0.08), (0.22 * lado, 0.12, 0.02), (0.2 * lado, 0.14, -0.1), 0.05, 0.016, oscuro, (lado, 0, 0.2))


def main():
    bpy.ops.wm.open_mainfile(filepath=os.path.join(ARTE, "blender", "cuerpo-comic.blend"))
    for o in list(bpy.data.objects):
        if o.type == "LIGHT" or o.name == "Niebla" or o.name.startswith("Pelo_"):
            bpy.data.objects.remove(o)
    oscuro, luz = mat("PeloNuevo", "#171a28"), mat("PeloNuevoLuz", "#28365a")
    e = bpy.context.scene
    e.render.engine = "BLENDER_EEVEE"
    e.view_settings.view_transform = "Standard"
    w = bpy.data.worlds.new("Fondo")
    w.use_nodes = True
    w.node_tree.nodes["Background"].inputs[0].default_value = (0.1, 0.12, 0.17, 1)
    w.node_tree.nodes["Background"].inputs[1].default_value = 1.2
    e.world = w
    bpy.ops.object.camera_add()
    cam = bpy.context.object
    cam.data.type, cam.data.ortho_scale = "ORTHO", 0.92
    e.camera = cam
    bpy.ops.object.light_add(type="SUN", location=(-2, -4, 5))
    sol = bpy.context.object
    sol.data.energy = 3.2
    sol.rotation_euler = (Vector((0, 0, 1.4)) - sol.location).to_track_quat("-Z", "Y").to_euler()
    e.render.resolution_x, e.render.resolution_y = 480, 520
    for i, f in enumerate((barrido, atras, rebelde), 1):
        antes = set(bpy.data.objects)
        f(f"Op{i}_", oscuro, luz)
        nuevos = set(bpy.data.objects) - antes
        for giro, v in ((0, "frente"), (45, "tres"), (180, "espalda")):
            a = math.radians(giro)
            cam.location = (-5 * math.sin(a), -5 * math.cos(a), 1.75)
            cam.rotation_euler = (Vector((0, 0, 1.47)) - cam.location).to_track_quat("-Z", "Y").to_euler()
            sol.rotation_euler = (Vector((0, 0, 1.4)) - Vector((-2 * math.cos(a) + 4 * math.sin(a), -2 * math.sin(a) - 4 * math.cos(a), 5))).to_track_quat("-Z", "Y").to_euler()
            e.render.filepath = os.path.join(ARTE, "renders", f"pelo-comic-{i}-{v}.png")
            bpy.ops.render.render(write_still=True)
        for o in nuevos:
            bpy.data.objects.remove(o)


main()
