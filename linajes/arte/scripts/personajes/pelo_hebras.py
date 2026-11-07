"""Pelo de hebras: gorro base, mechones finos en capas y textura con degradé.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/pelo_hebras.py

Sigue la nota "Referencias de pelos" de la bóveda. No toca cuerpo-comic.blend. Hace los peinados
Puntas, Corto y Flequillo. La textura es gris casi blanca:
el color lo pone el juego con SurfaceAppearance.Color. Deja renders pelo-<peinado>-*.png y los FBX
en exports/cuerpo-comic/.
"""

import math
import os
import random
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
Z = 1.363  # centro de la cabeza
CENTRO = Vector((0, 0, Z + 0.02))
CORONILLA = 0.12  # los mechones de arriba salen de atrás del centro
PASOS = 4
MITAD = (0.175, 0.16, 0.168)  # medidas reales de Cuerpo_Head
TIRAS = 4  # variantes de hebras dentro de la textura
COLOR_INICIAL = "#4468AE"  # azul por defecto; el jugador lo cambia en el creador


def superficie(g, s, extra=0.0):
    """Punto sobre la cabeza. g = ángulo (0 = frente), s = 0 arriba, 1 ecuador, más de 1 baja."""
    t = math.radians(g)
    sx, sy = math.sin(t), -math.cos(t)
    a, b, e = MITAD[0] + 0.002 + extra, MITAD[1] + 0.002 + extra, 8  # contorno de la cabeza real
    r = (abs(sx / a) ** e + abs(sy / b) ** e) ** (-1 / e)
    rx, ry = sx * r, sy * r
    if s <= 1:
        f = math.sin(s * math.pi / 2) ** 0.35
        z = (MITAD[2] + 0.002 + extra) * math.cos(s * math.pi / 2) ** 0.35
    else:
        f, z = 1, -(s - 1) * 0.3
    return Vector((rx * f, ry * f, z + Z))


def s_de_altura(z):
    """Inversa de superficie: qué s llega a la altura z."""
    if z <= 0:
        return 1 - z / 0.3
    return math.acos(min(z / 0.17, 1) ** (1 / 0.35)) * 2 / math.pi


def fin_de_pelo(g):
    """Altura donde termina el pelo: frente alta, costados medios, nuca baja."""
    c = (1 + math.cos(math.radians(g))) / 2
    return -0.175 + 0.245 * c**1.6


class Malla:
    def __init__(self):
        self.v, self.f, self.uv = [], [], []
        self.puntas = []

    def mechon(self, g, s0, s1, ancho, alto, giro=0.0, levante=0.05, arriba=0.0, capa="media"):
        """Hoja de sección triangular que sigue la cabeza y se despega hacia la punta."""
        tira = random.randrange(TIRAS) / TIRAS
        puntos = []
        for i in range(PASOS + 1):
            t = i / PASOS
            p = superficie(g + giro * t, s0 + (s1 - s0) * t, alto)
            puntos.append(p + ((p - CENTRO).normalized() * (1 - arriba) + Vector((0, 0, arriba))) * levante * t * t)
        self.tira(puntos, ancho, capa, tira)

    def punta(self, raiz, medio, fin, ancho):
        """Punta grande con recorrido fijo: de raiz a fin, curvada hacia medio (relativos a Z)."""
        a, b, c = (Vector((x, y, z + Z)) for x, y, z in (raiz, medio, fin))
        puntos = [a * (1 - t) ** 2 + b * 2 * t * (1 - t) + c * t * t for t in (i / PASOS for i in range(PASOS + 1))]
        self.tira(puntos, ancho, "puntas", random.randrange(TIRAS) / TIRAS)

    def tira(self, puntos, ancho, capa, tira):
        base = len(self.v)
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
        self.puntas.append((capa, puntos[-2], puntos[-1]))
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
        n, m = 24, 6
        base = len(self.v)
        self.v.append(superficie(0, 0, 0.001))
        self.uv.append((0.1, 0.1))
        for j in range(1, m + 1):
            for i in range(n):
                g = i / n * 360 - 180
                s = s_de_altura(fin_de_pelo(g) + 0.06) * j / m
                self.v.append(superficie(g, s, 0.001))
                self.uv.append((0.1, 0.1))
        for i in range(n):
            self.f.append((base, base + 1 + i, base + 1 + (i + 1) % n))
        for j in range(m - 1):
            a, b = base + 1 + j * n, base + 1 + (j + 1) * n
            for i in range(n):
                k = (i + 1) % n
                self.f.append((a + i, b + i, b + k, a + k))
        fondo = len(self.v)
        self.v.append(Vector((0, 0, Z + 0.05)))
        self.uv.append((0.1, 0.1))
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


def peinado_puntas():
    """Mechones finos en capas y seis puntas grandes en la coronilla."""
    m = Malla()
    m.gorro()
    azar = random.uniform
    for i in range(36):
        g = i / 36 * 360 - 180 + azar(-3, 3)
        if abs(g) < 50:
            continue
        m.mechon(g, 0.25, s_de_altura(fin_de_pelo(g) + azar(-0.02, 0.03)), 0.07, 0.004, azar(-6, 6), 0.0, capa="abajo")
    for i in range(44):
        g = i / 44 * 360 - 180 + azar(-4, 4)
        fin = fin_de_pelo(g) + azar(0.0, 0.08)
        if abs(g) < 72:
            fin = max(fin, 0.1)
        m.mechon(g, 0.3, s_de_altura(fin), 0.044, 0.014, azar(-12, 12), azar(0.006, 0.03))
    for i in range(22):
        g = i / 22 * 360 - 180 + azar(-6, 6)
        fin = s_de_altura(azar(0.085, 0.13)) if abs(g) < 72 else azar(1.0, 1.3)
        m.mechon(g, 0.1, fin, 0.052, 0.022, azar(-16, 16), 0.012, capa="arriba")
    # Seis puntas de distinto tamaño, en varias filas y asimétricas, inclinadas hacia atrás.
    for x, y, tx, ty, alto, ancho in (
        (-0.03, -0.1, -0.06, 0.0, 0.37, 0.095),
        (0.09, -0.07, 0.15, 0.03, 0.29, 0.075),
        (-0.12, -0.03, -0.15, 0.08, 0.26, 0.07),
        (0.02, 0.02, 0.04, 0.16, 0.33, 0.09),
        (-0.08, 0.08, -0.12, 0.21, 0.28, 0.08),
        (0.11, 0.07, 0.12, 0.22, 0.24, 0.07),
    ):
        m.punta((x, y, 0.1), (x, y + 0.01, alto * 0.65), (tx, ty, alto), ancho)
    for i in range(13):
        g = -68 + i * 11.3 + azar(-2, 2)
        fin = azar(0.075, 0.115) if i % 3 else azar(0.05, 0.07)
        m.mechon(g, 0.4, s_de_altura(fin), 0.034, 0.012, 15 + azar(-5, 5), 0.004, capa="frente")
    # Tapan las esquinas de la frente.
    for g in (-64, -50, 50, 64):
        m.mechon(g, 0.3, s_de_altura(0.09), 0.05, 0.02, 0, 0.004, capa="frente")
    return m


def peinado_flequillo():
    """Mechones anchos con flequillo que cae sobre los ojos."""
    m = Malla()
    m.gorro()
    azar = random.uniform
    for i in range(34):
        g = i / 34 * 360 - 180 + azar(-3, 3)
        if abs(g) < 50:
            continue
        m.mechon(g, 0.25, s_de_altura(fin_de_pelo(g) + azar(-0.02, 0.03)), 0.08, 0.004, azar(-6, 6), 0.0, capa="abajo")
    for i in range(30):
        g = i / 30 * 360 - 180 + azar(-4, 4)
        fin = fin_de_pelo(g) + azar(0.0, 0.07)
        if abs(g) < 45:
            fin = max(fin, 0.1)
        m.mechon(g, CORONILLA, s_de_altura(fin), 0.066, 0.018, azar(-10, 10), azar(0.004, 0.016))
    for i in range(20):
        g = i / 20 * 360 - 180 + azar(-6, 6)
        m.mechon(g, 0.0, azar(1.03, 1.2), 0.064, 0.036, azar(-16, 16), 0.006, capa="arriba")
    for i in range(9):
        g = -54 + i * 13.5 + azar(-2, 2)
        fin = azar(0.0, 0.085) if i % 3 else azar(-0.03, 0.03)
        m.mechon(g, 0.4, s_de_altura(fin), 0.044, 0.012, 15 + azar(-5, 5), 0.004, capa="frente")
    return m


def peinado_corto():
    """Capas de abajo hacia arriba. Todos los mechones pasan el borde de la cabeza y caen."""
    m = Malla()
    m.gorro()
    azar = random.uniform
    # Capa de abajo: pegada a la cabeza, sin levante.
    for i in range(34):
        g = i / 34 * 360 - 180 + azar(-3, 3)
        if abs(g) < 50:
            continue
        m.mechon(g, 0.25, s_de_altura(fin_de_pelo(g) + azar(-0.02, 0.03)), 0.08, 0.004, azar(-6, 6), 0.0, capa="abajo")
    # Capa media: largos distintos, apenas despegada.
    for i in range(30):
        g = i / 30 * 360 - 180 + azar(-4, 4)
        fin = fin_de_pelo(g) + azar(0.0, 0.07)
        if abs(g) < 72:
            fin = max(fin, 0.1)
        m.mechon(g, CORONILLA, s_de_altura(fin), 0.066, 0.018, azar(-10, 10), azar(0.006, 0.028))
    # Capa de arriba: da volumen y cae por el borde, nunca sale horizontal.
    for i in range(20):
        g = i / 20 * 360 - 180 + azar(-6, 6)
        fin = s_de_altura(azar(0.085, 0.13)) if abs(g) < 72 else azar(1.0, 1.32)
        m.mechon(g, 0.0, fin, 0.064, 0.036, azar(-16, 16), 0.012, capa="arriba")
    # Frente: fila de mechones barridos que tapan la unión con la piel.
    for i in range(9):
        g = -54 + i * 13.5 + azar(-2, 2)
        fin = azar(0.075, 0.115) if i % 3 else azar(0.05, 0.07)
        m.mechon(g, 0.4, s_de_altura(fin), 0.044, 0.012, 15 + azar(-5, 5), 0.004, capa="frente")
    return m


def textura(ruta):
    """Cómic: tres grises claros planos. Multiplicados por el color del jugador dan los tonos."""
    n = 512
    lin = lambda c: np.array(c) ** 2.2
    oscuro, medio, claro = lin((0.68,) * 3), lin((0.86,) * 3), lin((1.0,) * 3)
    v = np.linspace(0, 1, n)[:, None]
    u = np.linspace(0, 1, n)[None, :]
    f = (u * TIRAS) % 1  # posición a lo ancho del mechón
    corte = 0.3 + 0.1 * np.sin(u * 37)  # sombra de raíz con borde dentado
    color = np.where((v < corte)[..., None], oscuro, medio)
    luz = (np.abs(f - 0.42) < 0.09 + 0.05 * np.sin(v * 9)) & (v > 0.5) & (v < 0.82)
    color = np.where(luz[..., None], claro, color)
    color = np.where((np.abs(f - 0.5) > 0.42)[..., None], oscuro, color)
    pixeles = np.ones((n, n, 4), dtype=np.float32)
    pixeles[..., :3] = color
    img = bpy.data.images.new("PeloHebras_color", n, n, alpha=False, float_buffer=False)
    img.colorspace_settings.name = "Linear Rec.709"
    img.pixels.foreach_set(pixeles.ravel())
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()
    return img


def chequear(m):
    """Mechones horizontales en la coronilla y distancia de cada punta baja a la cabeza."""
    planos, lejos = 0, {}
    for capa, a, b in m.puntas:
        d = (b - a).normalized()
        if b.z > Z + 0.1 and abs(d.z) < 0.35:
            planos += 1
        q = b - Vector((0, 0, Z))
        fuera = Vector([max(abs(q[i]) - MITAD[i], 0) for i in range(3)]).length
        lejos[capa] = max(lejos.get(capa, 0), fuera)
    print("CHEQUEO mechones", len(m.puntas), "planos_arriba", planos, "punta_a_cabeza", {k: round(v, 3) for k, v in lejos.items()})


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
    bsdf.inputs["Roughness"].default_value = 0.62
    tex = nodos.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tinte = nodos.nodes.new("ShaderNodeVectorMath")
    tinte.operation = "MULTIPLY"
    tinte.inputs[1].default_value = [(int(COLOR_INICIAL[i : i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)]
    nodos.links.new(tex.outputs["Color"], tinte.inputs[0])
    nodos.links.new(tinte.outputs[0], bsdf.inputs["Base Color"])
    borde = bpy.data.materials.new("PeloContorno")
    borde.use_nodes = True
    borde.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.012, 0.022, 0.05, 1)
    borde.use_backface_culling = True  # si no, la cáscara del contorno tapa el color del pelo

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

    pedidos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []  # vacío = todos
    for nombre, armar in (("puntas", peinado_puntas), ("corto", peinado_corto), ("flequillo", peinado_flequillo)):
        if pedidos and nombre not in pedidos:
            continue
        random.seed(11)
        datos = armar()
        print("PEINADO", nombre)
        chequear(datos)
        pelo = datos.objeto("Pelo" + nombre.capitalize(), material)
        medir(pelo.data)
        pelo.data.materials.append(borde)
        contorno = pelo.modifiers.new("Borde", "SOLIDIFY")
        contorno.thickness, contorno.offset, contorno.use_flip_normals, contorno.material_offset = 0.005, 1, True, 1
        for giro, v in ((0, "frente"), (45, "tres"), (90, "costado"), (135, "atras-tres"), (180, "espalda")):
            a = math.radians(giro)
            cam.location = (-5 * math.sin(a), -5 * math.cos(a), 1.75)
            cam.rotation_euler = (Vector((0, 0, 1.47)) - cam.location).to_track_quat("-Z", "Y").to_euler()
            sol.rotation_euler = (Vector((0, 0, 1.4)) - Vector((-2 * math.cos(a) + 4 * math.sin(a), -2 * math.sin(a) - 4 * math.cos(a), 5))).to_track_quat("-Z", "Y").to_euler()
            e.render.filepath = os.path.join(ARTE, "renders", f"pelo-{nombre}-{v}.png")
            bpy.ops.render.render(write_still=True)
        cam.location = (0, -0.01, 6)
        cam.rotation_euler = (0, 0, 0)
        sol.rotation_euler = (0.4, 0.2, 0)
        e.render.filepath = os.path.join(ARTE, "renders", f"pelo-{nombre}-arriba.png")
        bpy.ops.render.render(write_still=True)
        bpy.ops.object.select_all(action="DESELECT")
        pelo.select_set(True)
        bpy.ops.export_scene.fbx(
            filepath=os.path.join(ARTE, "exports", "cuerpo-comic", f"Pelo{nombre.capitalize()}.fbx"),
            use_selection=True,
            object_types={"MESH"},
            use_mesh_modifiers=False,
            global_scale=1 / 0.28,
            apply_unit_scale=True,
            apply_scale_options="FBX_SCALE_UNITS",
            axis_forward="Z",
            axis_up="Y",
        )
        bpy.data.objects.remove(pelo)


main()
