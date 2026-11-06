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


def solido(nombre, material):
    """Pelo como UNA superficie continua alrededor de la cabeza: cerrada, sin huecos posibles.

    Es una grilla de N columnas (vuelta a la cabeza) por M filas (de la coronilla al borde).
    El borde tiene dientes y las puntas de arriba son bultos de la misma superficie.
    """
    N, M = 150, 24
    centro = Vector((0, 0.012, Z + 0.04))
    # Puntas: ángulo (0 = frente), fila, altura, ancho, hacia dónde se barren.
    puntas = [
        (-165, 0.34, 0.1, 0.3, (-0.2, 0.75, 0.25)),
        (165, 0.34, 0.1, 0.3, (0.2, 0.75, 0.25)),
        (-125, 0.34, 0.11, 0.3, (-0.6, 0.45, 0.35)),
        (125, 0.34, 0.11, 0.3, (0.6, 0.45, 0.35)),
        (-82, 0.34, 0.12, 0.3, (-0.85, 0, 0.45)),
        (82, 0.34, 0.12, 0.3, (0.85, 0, 0.45)),
        (-45, 0.33, 0.13, 0.28, (-0.55, -0.15, 0.7)),
        (45, 0.33, 0.13, 0.28, (0.55, -0.15, 0.7)),
        (-14, 0.3, 0.15, 0.27, (-0.15, -0.2, 0.9)),
        (18, 0.3, 0.15, 0.27, (0.2, -0.2, 0.9)),
        (-90, 0.2, 0.12, 0.26, (-0.35, 0.1, 0.8)),
        (70, 0.2, 0.13, 0.26, (0.35, 0, 0.8)),
        (180, 0.2, 0.12, 0.26, (0, 0.45, 0.75)),
    ]

    def borde(g):
        """Altura del borde según el ángulo: frente alta, costado medio, nuca baja, con dientes."""
        c = (1 + math.cos(math.radians(g))) / 2
        base = -0.085 + 0.205 * c**1.1
        dientes = 15
        fase = (g / 360 * dientes) % 1
        tri = abs(fase * 2 - 1)
        return base - (0.065 + 0.035 * (1 - c)) * (1 - tri) ** 0.9

    def punto(g, v):
        t = math.radians(g)
        sx, sy = math.sin(t), -math.cos(t)
        e = 0.22  # casi cuadrado, como la cabeza: cubre las esquinas
        rx = math.copysign(abs(sx) ** e, sx) * 0.195
        ry = math.copysign(abs(sy) ** e, sy) * 0.18
        ancho = math.sin(min(v * 2.6, 1) * math.pi / 2) ** 0.55
        z = 0.205 + (borde(g) - 0.205) * v**1.2
        p = Vector((rx * ancho, ry * ancho + 0.012, z + Z))
        n = (p - centro).normalized()
        for pg, pv, h, w, barre in puntas:
            dg = math.radians((g - pg + 180) % 360 - 180) * (0.2 + pv)
            d = math.sqrt(dg * dg + ((v - pv) * 1.7) ** 2) / w
            if d < 1:
                k = (1 - d) ** 2.2
                p = p + (n * 0.35 + Vector(barre)) * h * k * 1.05
        return p

    verts = [Vector((0, 0.012, Z + 0.205))]
    for j in range(1, M + 1):
        for i in range(N):
            verts.append(punto(i / N * 360 - 180, j / M))
    caras = []
    for i in range(N):
        caras.append((0, 1 + i, 1 + (i + 1) % N))
    for j in range(M - 1):
        a0, a1 = 1 + j * N, 1 + (j + 1) * N
        for i in range(N):
            k = (i + 1) % N
            caras.append((a0 + i, a1 + i, a1 + k, a0 + k))
    # Tapa interna, dentro de la cabeza: cierra la malla sin que se vea.
    ultimo = 1 + (M - 1) * N
    interno = len(verts)
    for i in range(N):
        verts.append(Vector((verts[ultimo + i].x * 0.72, verts[ultimo + i].y * 0.72, verts[ultimo + i].z + 0.01)))
    fondo = len(verts)
    verts.append(Vector((0, 0.012, Z + 0.04)))
    for i in range(N):
        k = (i + 1) % N
        caras.append((ultimo + i, interno + i, interno + k, ultimo + k))
        caras.append((interno + i, fondo, interno + k))
    me = bpy.data.meshes.new(nombre)
    me.from_pydata([tuple(v) for v in verts], [], caras)
    me.update()
    o = bpy.data.objects.new(nombre, me)
    bpy.context.collection.objects.link(o)
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.shade_smooth()
    me.materials.append(material)
    me.materials.append(bpy.data.materials["Contorno"])
    b = o.modifiers.new("Borde", "SOLIDIFY")
    b.thickness, b.offset, b.use_flip_normals, b.material_offset = 0.006, 1, True, 1
    return o


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
    pelo = solido("PeloSolido", oscuro)
    me = pelo.data
    aristas = {}
    for f in me.polygons:
        for k in f.edge_keys:
            aristas[k] = aristas.get(k, 0) + 1
    abiertas = sum(1 for v in aristas.values() if v != 2)
    import bmesh

    bm = bmesh.new()
    bm.from_mesh(me)
    islas, vistos = 0, set()
    for v in bm.verts:
        if v.index in vistos:
            continue
        islas += 1
        pila = [v]
        while pila:
            u = pila.pop()
            if u.index in vistos:
                continue
            vistos.add(u.index)
            pila += [e2.other_vert(u) for e2 in u.link_edges]
    print("MALLA triangulos", sum(len(f.vertices) - 2 for f in me.polygons), "aristas_abiertas", abiertas, "piezas_sueltas", islas)
    for giro, v in ((0, "frente"), (45, "tres"), (90, "costado"), (135, "atras-tres"), (180, "espalda")):
        a = math.radians(giro)
        cam.location = (-5 * math.sin(a), -5 * math.cos(a), 1.75)
        cam.rotation_euler = (Vector((0, 0, 1.47)) - cam.location).to_track_quat("-Z", "Y").to_euler()
        sol.rotation_euler = (Vector((0, 0, 1.4)) - Vector((-2 * math.cos(a) + 4 * math.sin(a), -2 * math.sin(a) - 4 * math.cos(a), 5))).to_track_quat("-Z", "Y").to_euler()
        e.render.filepath = os.path.join(ARTE, "renders", f"pelo-solido-{v}.png")
        bpy.ops.render.render(write_still=True)
    bpy.ops.object.select_all(action="DESELECT")
    pelo.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(ARTE, "exports", "cuerpo-comic", "PeloSolido.fbx"),
        use_selection=True,
        object_types={"MESH"},
        use_mesh_modifiers=False,
        global_scale=1 / 0.28,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
    )


main()
