"""Pelo de hebras: gorro base, mechones finos en capas y textura con degradé.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/pelo_hebras.py

Sigue la nota "Referencias de pelos" de la bóveda. No toca cuerpo-comic.blend. Deja renders
pelo-hebras-*.png, la textura y exports/cuerpo-comic/PeloHebras.fbx.
"""

import math
import os
import random

import bmesh
import bpy
import numpy as np
from mathutils import Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
Z = 1.363  # centro de la cabeza
CENTRO = Vector((0, 0.012, Z + 0.02))
CORONILLA = 0.12  # los mechones de arriba salen de atrás del centro
PASOS = 5
TIRAS = 4  # variantes de hebras dentro de la textura


def superficie(g, s, extra=0.0):
    """Punto sobre la cabeza. g = ángulo (0 = frente), s = 0 arriba, 1 ecuador, más de 1 baja."""
    t = math.radians(g)
    sx, sy = math.sin(t), -math.cos(t)
    a, b, e = 0.2 + extra, 0.19 + extra, 5  # contorno casi cuadrado, repartido parejo por ángulo
    r = (abs(sx / a) ** e + abs(sy / b) ** e) ** (-1 / e)
    rx, ry = sx * r, sy * r
    if s <= 1:
        f = math.sin(s * math.pi / 2) ** 0.55
        z = (0.212 + extra) * math.cos(s * math.pi / 2) ** 0.6
    else:
        f, z = 1, -(s - 1) * 0.3
    return Vector((rx * f, ry * f + 0.012, z + Z))


def s_de_altura(z):
    """Inversa de superficie: qué s llega a la altura z."""
    if z <= 0:
        return 1 - z / 0.3
    return math.acos(min(z / 0.212, 1) ** (1 / 0.6)) * 2 / math.pi


def fin_de_pelo(g):
    """Altura donde termina el pelo: frente alta, costados medios, nuca baja."""
    c = (1 + math.cos(math.radians(g))) / 2
    return -0.175 + 0.245 * c**1.6


class Malla:
    def __init__(self):
        self.v, self.f, self.uv = [], [], []

    def mechon(self, g, s0, s1, ancho, alto, giro=0.0, levante=0.05, arriba=0.0):
        """Hoja de sección triangular que sigue la cabeza y se despega hacia la punta."""
        tira = random.randrange(TIRAS) / TIRAS
        base = len(self.v)
        puntos = []
        for i in range(PASOS + 1):
            t = i / PASOS
            p = superficie(g + giro * t, s0 + (s1 - s0) * t, alto)
            puntos.append(p + ((p - CENTRO).normalized() * (1 - arriba) + Vector((0, 0, arriba))) * levante * t * t)
        for i in range(PASOS):
            t = i / PASOS
            d = (puntos[i + 1] - puntos[i]).normalized()
            n = (puntos[i] - CENTRO).normalized()
            lado = d.cross(n).normalized()
            n = lado.cross(d).normalized()
            w = ancho * (0.55 + 0.45 * math.sin(min(t / 0.4, 1) * math.pi / 2)) * (1 - t**2.4)
            h = w * 0.45
            self.v += [puntos[i] - lado * w - n * h * 0.5, puntos[i] + n * h, puntos[i] + lado * w - n * h * 0.5]
            self.uv += [(tira, t), (tira + 0.5 / TIRAS, t), (tira + 1 / TIRAS, t)]
        self.v.append(puntos[-1])
        self.uv.append((tira + 0.5 / TIRAS, 1))
        self.f.append((base, base + 1, base + 2))
        for i in range(PASOS - 1):
            a, b = base + i * 3, base + i * 3 + 3
            for j in range(3):
                k = (j + 1) % 3
                self.f.append((a + j, a + k, b + k, b + j))
        a, punta = base + (PASOS - 1) * 3, base + PASOS * 3
        for j in range(3):
            self.f.append((a + j, a + (j + 1) % 3, punta))

    def gorro(self):
        """Base cerrada al ras de la cabeza: evita que se vea piel entre mechones."""
        n, m = 32, 8
        base = len(self.v)
        self.v.append(superficie(0, 0, 0.006))
        self.uv.append((0.1, 0.03))
        for j in range(1, m + 1):
            for i in range(n):
                g = i / n * 360 - 180
                s = s_de_altura(fin_de_pelo(g) + 0.012) * j / m
                self.v.append(superficie(g, s, 0.006))
                self.uv.append((0.1, 0.03))
        for i in range(n):
            self.f.append((base, base + 1 + i, base + 1 + (i + 1) % n))
        for j in range(m - 1):
            a, b = base + 1 + j * n, base + 1 + (j + 1) * n
            for i in range(n):
                k = (i + 1) % n
                self.f.append((a + i, b + i, b + k, a + k))
        fondo = len(self.v)
        self.v.append(Vector((0, 0.012, Z + 0.05)))
        self.uv.append((0.1, 0.03))
        a = base + 1 + (m - 1) * n
        for i in range(n):
            self.f.append((a + i, fondo, a + (i + 1) % n))

    def objeto(self, nombre, material):
        me = bpy.data.meshes.new(nombre)
        me.from_pydata([tuple(p) for p in self.v], [], self.f)
        capa = me.uv_layers.new(name="UV")
        for lazo in me.loops:
            capa.data[lazo.index].uv = self.uv[lazo.vertex_index]
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
        return o


def peinado():
    """Capas de abajo hacia arriba. Los números salen de mirar las hojas de referencia."""
    m = Malla()
    m.gorro()
    azar = random.uniform
    # Capa de abajo: cubre todo el contorno.
    for i in range(42):
        g = i / 42 * 360 - 180 + azar(-3, 3)
        if abs(g) < 50:
            continue
        m.mechon(g, 0.25, s_de_altura(fin_de_pelo(g) + azar(-0.04, 0.03)), 0.066, 0.012, azar(-8, 8), 0.02)
    # Capa media: más despegada y con largos distintos.
    for i in range(44):
        g = i / 44 * 360 - 180 + azar(-4, 4)
        fin = fin_de_pelo(g) + azar(0.0, 0.1)
        if abs(g) < 45:
            fin = max(fin, 0.1)
        m.mechon(g, CORONILLA, s_de_altura(fin), 0.046, 0.03, azar(-12, 12), azar(0.015, 0.045))
    # Capa de arriba: puntas cortas que dibujan la silueta.
    for i in range(24):
        g = i / 24 * 360 - 180 + azar(-6, 6)
        m.mechon(g, 0.0, azar(0.55, 0.85), 0.05, 0.06, azar(-20, 20), azar(0.05, 0.1), 0.3)
    # Frente: fila de mechones barridos que tapan la unión con la piel.
    for i in range(11):
        g = -56 + i * 11 + azar(-2, 2)
        fin = azar(0.0, 0.085) if i % 3 else azar(-0.03, 0.03)
        m.mechon(g, 0.4, s_de_altura(fin), 0.034, 0.03, 15 + azar(-5, 5), 0.015)
    # Hebras sueltas que rompen el contorno.
    for i in range(8):
        g = azar(-180, 180)
        m.mechon(g, 0.2, azar(0.55, 0.8), 0.014, 0.055, azar(-25, 25), azar(0.06, 0.11), 0.4)
    return m


def textura(ruta):
    """Raíz oscura, punta más clara, brillo en banda y líneas de hebras."""
    n = 512
    r = np.random.default_rng(7)
    lineas = np.zeros(n)
    for ancho, peso in ((3, 0.5), (9, 0.35), (25, 0.15)):
        ruido = r.standard_normal(n)
        lineas += peso * np.convolve(np.tile(ruido, 3), np.ones(ancho) / ancho, "same")[n : 2 * n] * math.sqrt(ancho)
    lineas = np.clip(0.5 + lineas * 0.35, 0, 1)[None, :]
    v = np.linspace(0, 1, n)[:, None]
    u = np.linspace(0, 1, n)[None, :]
    borde = np.abs((u * TIRAS) % 1 - 0.5) * 2
    raiz, punta, brillo = (np.array(c) for c in ((0.012, 0.014, 0.03), (0.06, 0.09, 0.2), (0.3, 0.42, 0.72)))
    k = (v**1.3)[..., None]
    color = raiz * (1 - k) + punta * k
    color = color * (0.55 + 0.9 * lineas[..., None])
    banda = (np.exp(-(((v - 0.48) / 0.07) ** 2)) * lineas**2)[..., None]
    color = color + brillo * banda * 0.55
    color = color * (1 - 0.6 * borde**3)[..., None]
    pixeles = np.ones((n, n, 4), dtype=np.float32)
    pixeles[..., :3] = np.clip(color, 0, 1)
    img = bpy.data.images.new("PeloHebras_color", n, n, alpha=False, float_buffer=False)
    img.colorspace_settings.name = "Linear Rec.709"
    img.pixels.foreach_set(pixeles.ravel())
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()
    return img


def medir(me):
    aristas = {}
    for f in me.polygons:
        for k in f.edge_keys:
            aristas[k] = aristas.get(k, 0) + 1
    bm = bmesh.new()
    bm.from_mesh(me)
    print(
        "MALLA triangulos",
        sum(len(f.vertices) - 2 for f in me.polygons),
        "aristas_abiertas",
        sum(1 for c in aristas.values() if c != 2),
        "vertices",
        len(bm.verts),
    )
    bm.free()


def main():
    random.seed(11)
    bpy.ops.wm.open_mainfile(filepath=os.path.join(ARTE, "blender", "cuerpo-comic.blend"))
    for o in list(bpy.data.objects):
        if o.type == "LIGHT" or o.name == "Niebla" or o.name.startswith("Pelo_"):
            bpy.data.objects.remove(o)
    carpeta = os.path.join(ARTE, "blender", "texturas", "pelo")
    os.makedirs(carpeta, exist_ok=True)
    img = textura(os.path.join(carpeta, "PeloHebras_color.png"))
    material = bpy.data.materials.new("PeloHebras")
    material.use_nodes = True
    nodos = material.node_tree
    bsdf = nodos.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.55
    tex = nodos.nodes.new("ShaderNodeTexImage")
    tex.image = img
    nodos.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    pelo = peinado().objeto("PeloHebras", material)
    medir(pelo.data)

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
    e.render.resolution_x, e.render.resolution_y = 480, 520
    for giro, v in ((0, "frente"), (45, "tres"), (90, "costado"), (135, "atras-tres"), (180, "espalda")):
        a = math.radians(giro)
        cam.location = (-5 * math.sin(a), -5 * math.cos(a), 1.75)
        cam.rotation_euler = (Vector((0, 0, 1.47)) - cam.location).to_track_quat("-Z", "Y").to_euler()
        sol.rotation_euler = (Vector((0, 0, 1.4)) - Vector((-2 * math.cos(a) + 4 * math.sin(a), -2 * math.sin(a) - 4 * math.cos(a), 5))).to_track_quat("-Z", "Y").to_euler()
        e.render.filepath = os.path.join(ARTE, "renders", f"pelo-hebras-{v}.png")
        bpy.ops.render.render(write_still=True)
    bpy.ops.object.select_all(action="DESELECT")
    pelo.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(ARTE, "exports", "cuerpo-comic", "PeloHebras.fbx"),
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
