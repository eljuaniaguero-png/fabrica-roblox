"""Kit de la arena: piezas nuevas y arreglos pedidos por Juani (7 nov).
Uso: blender -b --factory-startup -P linajes/arte/scripts/arena_kit.py -- <carpeta de renders>
Texturas: tablas de tonos con ruido y óxido, sin imágenes de afuera. Medidas en metros.
"""
import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import base as B  # noqa: E402

SALIDA = os.path.join(B.EXPORTS, "arena-kit")
os.makedirs(SALIDA, exist_ok=True)
LADO = 512
CELDAS = 4


def _ruido(semilla):
    r = random.Random(semilla)
    base = [[r.random() for _ in range(33)] for _ in range(33)]

    def valor(u, v, f):
        x, y = (u * f) % 32, (v * f) % 32
        i, j = int(x), int(y)
        a, b = x - i, y - j
        a, b = a * a * (3 - 2 * a), b * b * (3 - 2 * b)
        return (
            base[i][j] * (1 - a) * (1 - b) + base[i + 1][j] * a * (1 - b)
            + base[i][j + 1] * (1 - a) * b + base[i + 1][j + 1] * a * b
        )

    return lambda u, v: valor(u, v, 5) * 0.55 + valor(u, v, 13) * 0.3 + valor(u, v, 29) * 0.15


def _hex(c):
    return [int(c[i:i + 2], 16) / 255 for i in (1, 3, 5)]


def tabla(nombre, tonos):
    """Imagen de 4x4 celdas. Cada tono: (color, óxido de 0 a 1)."""
    img = bpy.data.images.new("TEX_" + nombre, LADO, LADO, alpha=False)
    ruido = _ruido(len(nombre) * 7 + 3)
    oxido = _hex("#7a3f22")
    pix = [0.0] * (LADO * LADO * 4)
    celda = LADO // CELDAS
    for y in range(LADO):
        for x in range(LADO):
            n = min((y // celda) * CELDAS + x // celda, len(tonos) - 1)
            color, cantidad = tonos[n]
            c = _hex(color)
            valor = ruido(x / LADO, y / LADO)
            luz = 0.86 + valor * 0.28
            mezcla = 1.0 if valor > 1 - cantidad * 0.62 else 0.0
            i = (y * LADO + x) * 4
            for k in range(3):
                pix[i + k] = (c[k] * (1 - mezcla) + oxido[k] * mezcla) * luz
            pix[i + 3] = 1
    img.pixels = pix
    img.filepath_raw = os.path.join(SALIDA, "TEX_" + nombre + ".png")
    img.file_format = "PNG"
    img.save()
    return img


def ladrillos(nombre):
    img = bpy.data.images.new("TEX_" + nombre, LADO, LADO, alpha=False)
    r = random.Random(9)
    filas, cols, junta = 12, 6, 5
    alto, ancho = LADO // filas, LADO // cols
    ruido = _ruido(5)
    tonos = {}
    pix = [0.0] * (LADO * LADO * 4)
    for y in range(LADO):
        fila = y // alto
        corrido = (ancho // 2) if fila % 2 else 0
        for x in range(LADO):
            col = ((x + corrido) // ancho) % cols
            enjunta = y % alto < junta or (x + corrido) % ancho < junta
            if enjunta:
                c = (0.62, 0.6, 0.55)
            else:
                t = tonos.setdefault((fila, col), r.uniform(0.72, 1.08))
                c = (0.46 * t, 0.2 * t, 0.14 * t)
            luz = 0.88 + ruido(x / LADO, y / LADO) * 0.24
            i = (y * LADO + x) * 4
            pix[i:i + 4] = [c[0] * luz, c[1] * luz, c[2] * luz, 1]
    img.pixels = pix
    img.filepath_raw = os.path.join(SALIDA, "TEX_" + nombre + ".png")
    img.file_format = "PNG"
    img.save()
    return img


class Pieza:
    def __init__(self, nombre, imagen):
        self.nombre, self.imagen = nombre, imagen
        self.bm = bmesh.new()
        self.caras = []  # (cara, celda)
        self.plano = None

    def _marcar(self, geom, celda):
        for c in {f for v in geom for f in v.link_faces}:
            self.caras.append((c, celda))

    def caja(self, centro, tam, celda=0, giro=None):
        m = Matrix.Translation(centro)
        if giro:
            m = m @ giro
        m = m @ Matrix.Diagonal((tam[0], tam[1], tam[2], 1))
        r = bmesh.ops.create_cube(self.bm, size=1, matrix=m)
        self._marcar(r["verts"], celda)

    def barra(self, a, b, grueso, celda=0):
        a, b = Vector(a), Vector(b)
        d = b - a
        giro = d.to_track_quat("Z", "Y").to_matrix().to_4x4()
        self.caja((a + b) / 2, (grueso, grueso, d.length), celda, giro)

    def cilindro(self, centro, radio, alto, celda=0, lados=16, giro=None, radio2=None):
        m = Matrix.Translation(centro)
        if giro:
            m = m @ giro
        r = bmesh.ops.create_cone(
            self.bm, cap_ends=True, segments=lados, radius1=radio,
            radius2=radio if radio2 is None else radio2, depth=alto, matrix=m,
        )
        self._marcar(r["verts"], celda)

    def terminar(self, entera=False):
        bm = self.bm
        uv = bm.loops.layers.uv.new("UVMap")
        lo = Vector((min(v.co[i] for v in bm.verts) for i in range(3)))
        hi = Vector((max(v.co[i] for v in bm.verts) for i in range(3)))
        tam = hi - lo
        margen = 0.03
        for cara, celda in self.caras:
            n = cara.normal
            eje = max(range(3), key=lambda i: abs(n[i]))
            if self.plano is not None:
                eje = self.plano(cara, eje)
            a, b = [(1, 2), (0, 2), (0, 1)][eje]
            cu, cv = (celda % CELDAS) / CELDAS, (celda // CELDAS) / CELDAS
            ancho = 1 if entera else 1 / CELDAS
            for lp in cara.loops:
                p = lp.vert.co
                u = (p[a] - lo[a]) / max(tam[a], 1e-4)
                v = (p[b] - lo[b]) / max(tam[b], 1e-4)
                lp[uv].uv = (
                    cu + (margen + u * (1 - 2 * margen)) * ancho,
                    cv + (margen + v * (1 - 2 * margen)) * ancho,
                )
        viejo = bpy.data.objects.get(self.nombre)
        if viejo:
            bpy.data.objects.remove(viejo)
        malla = bpy.data.meshes.new(self.nombre)
        bm.to_mesh(malla)
        bm.free()
        mat = bpy.data.materials.new("MAT_" + self.nombre)
        mat.use_nodes = True
        nodos = mat.node_tree
        tex = nodos.nodes.new("ShaderNodeTexImage")
        tex.image = self.imagen
        bsdf = nodos.nodes["Principled BSDF"]
        bsdf.inputs["Roughness"].default_value = 0.7
        nodos.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        malla.materials.append(mat)
        o = bpy.data.objects.new(self.nombre, malla)
        bpy.context.scene.collection.objects.link(o)
        return o


def contenedor(nombre, pintura):
    L, W, H = 5.6, 2.24, 2.52
    img = tabla(nombre, [(pintura, 0.18), (pintura, 0.45), ("#5a5f66", 0.12), ("#22252b", 0)])
    p = Pieza(nombre, img)
    p.caja((0, 0, H / 2), (L - 0.1, W - 0.12, H - 0.1), 0)
    n = 22
    for i in range(n):
        x = -L / 2 + 0.3 + i * (L - 0.6) / (n - 1)
        for lado in (-1, 1):
            p.caja((x, lado * (W / 2 - 0.03), H / 2), (0.14, 0.09, H - 0.34), 1 if i % 5 == 0 else 0)
        p.caja((x, 0, H - 0.02), (0.14, W - 0.3, 0.06), 0)
    for sx in (-1, 1):
        for sy in (-1, 1):
            p.caja((sx * (L / 2 - 0.07), sy * (W / 2 - 0.07), H / 2), (0.14, 0.14, H), 1)
    for z in (0.08, H - 0.08):
        for sy in (-1, 1):
            p.caja((0, sy * (W / 2 - 0.05), z), (L, 0.1, 0.16), 1)
        for sx in (-1, 1):
            p.caja((sx * (L / 2 - 0.05), 0, z), (0.1, W, 0.16), 1)
    x = L / 2 - 0.02
    for lado in (-1, 1):  # dos puertas cerradas
        p.caja((x, lado * (W / 4 - 0.01), H / 2), (0.05, W / 2 - 0.2, H - 0.34), 0)
        for z in (0.5, H / 2, H - 0.5):
            p.caja((x + 0.03, lado * 0.98, z), (0.03, 0.09, 0.14), 2)
    for y in (-0.72, -0.26, 0.26, 0.72):  # 4 barras de cierre
        p.cilindro((x + 0.07, y, H / 2), 0.024, H - 0.3, 2, lados=8)
        p.caja((x + 0.08, y + 0.08, 1.1), (0.03, 0.2, 0.05), 2)
    p.caja((x + 0.01, 0, H / 2), (0.05, 0.03, H - 0.34), 3)
    # Las costillas se pintan como una sola pared: sin esto sus caras salen negras.
    p.plano = lambda cara, eje: 1 if eje == 0 and abs(cara.calc_center_median().x) < L / 2 - 0.2 else eje
    for i in range(9):  # otra punta, acanalada
        y = -W / 2 + 0.3 + i * (W - 0.6) / 8
        p.caja((-L / 2 + 0.03, y, H / 2), (0.09, 0.14, H - 0.34), 0)
    return p.terminar()


def barril():
    img = tabla("Prop_Barril", [("#2f5a78", 0.85), ("#2a3a48", 0.95), ("#55585e", 0.5)])
    p = Pieza("Prop_Barril", img)
    p.cilindro((0, 0, 0.45), 0.29, 0.86, 0, 20)
    for z in (0.02, 0.3, 0.6, 0.88):
        p.cilindro((0, 0, z), 0.305, 0.04, 1, 20)
    p.cilindro((0.14, 0.06, 0.9), 0.04, 0.03, 2, 10)
    return p.terminar()


def bita():
    img = tabla("Prop_Bita", [("#23272e", 0.34), ("#30353d", 0.55), ("#8f7a2e", 0.3)])
    p = Pieza("Prop_Bita", img)
    p.caja((0, 0, 0.04), (0.6, 0.6, 0.08), 1)
    p.cilindro((0, 0, 0.3), 0.14, 0.46, 0, 16)
    p.cilindro((0, 0, 0.56), 0.26, 0.09, 0, 16)
    giro = Matrix.Rotation(math.radians(90), 4, "X")
    p.cilindro((0, -0.19, 0.33), 0.07, 0.24, 0, 12, giro)
    for x, y in ((-0.22, -0.22), (0.22, -0.22), (-0.22, 0.22), (0.22, 0.22)):
        p.cilindro((x, y, 0.09), 0.03, 0.04, 2, 6)
    return p.terminar()


def muro():
    p = Pieza("Prop_MuroLadrillo", ladrillos("Prop_MuroLadrillo"))
    p.caja((0, 0, 0.55), (2.3, 0.22, 1.1), 0)
    return p.terminar(entera=True)


def red():
    img = tabla("Prop_Red", [("#c9b98a", 0.08), ("#4a505c", 0.3), ("#d0632a", 0.02)])
    p = Pieza("Prop_Red", img)
    for x in (-1.15, 1.15):
        p.barra((x, 0, 0), (x, 0, 1.15), 0.07, 1)
    p.barra((-1.2, 0, 1.12), (1.2, 0, 1.12), 0.06, 1)
    cols, filas = 13, 11

    def punto(i, j):
        x = -1.05 + i * 2.1 / (cols - 1)
        caida = 1.1 - j * 0.1
        y = 0.05 + 0.06 * math.sin(i * 0.9 + j) + (0.05 * j if j > 7 else 0)
        return (x + 0.03 * math.sin(j * 1.7), y, max(caida + 0.05 * math.sin(i * 1.3), 0.03))

    for i in range(cols):
        for j in range(filas):
            if i + 1 < cols:
                p.barra(punto(i, j), punto(i + 1, j), 0.016, 0)
            if j + 1 < filas:
                p.barra(punto(i, j), punto(i, j + 1), 0.016, 0)
    for i in range(0, cols, 3):
        a = punto(i, 5)
        p.cilindro((a[0], a[1] + 0.03, a[2]), 0.05, 0.1, 2, 8)
    return p.terminar()


def cartel():
    img = tabla("Prop_Cartel", [("#6b4a2f", 0.12), ("#4f3522", 0.2), ("#8a8f99", 0.2)])
    p = Pieza("Prop_Cartel", img)
    giro = Matrix.Rotation(math.radians(8), 4, "Y")
    for i in range(4):
        p.caja((0.0, 0, 1.0 + i * 0.26 - i * 0.03), (2.5, 0.05, 0.22), i % 2, giro)
    p.barra((-1.0, 0.05, 0), (-1.0, 0.05, 2.0), 0.13, 1)  # pata sana
    p.barra((1.05, 0.05, 0), (1.0, 0.05, 0.86), 0.13, 1)  # muñón roto que sostiene
    p.barra((-1.0, 0.08, 0.2), (-0.1, 0.08, 1.05), 0.08, 1)
    p.barra((0.75, -0.6, 0.07), (1.95, -0.2, 0.07), 0.13, 1)  # pata rota en el piso
    return p.terminar()


def techo():
    img = tabla("Galpon_Techo", [("#6a4a3a", 0.4), ("#7a5442", 0.55), ("#3a3d44", 0.2)])
    p = Pieza("Galpon_Techo", img)
    ancho, media, alto, n = 2.3, 1.2, 0.7, 28
    for lado in (-1, 1):
        a, b = (0, lado * media, 0.0), (0, 0, alto)
        angulo = math.atan2(alto, media) * -lado
        giro = Matrix.Rotation(angulo, 4, "X")
        p.caja((0, lado * media / 2, alto / 2), (ancho, math.hypot(media, alto), 0.025), 0, giro)
        for i in range(n):
            x = -ancho / 2 + 0.08 + i * (ancho - 0.16) / (n - 1)
            p.barra((x, a[1], a[2] + 0.03), (x, b[1], b[2] + 0.02), 0.045, 1 if i % 7 == 0 else 0)
    p.caja((0, 0, alto + 0.05), (ancho + 0.04, 0.22, 0.05), 2)
    return p.terminar()


def grua_cabina():
    o = bpy.data.objects["Grua_Estructura"]
    puntos = [o.matrix_world @ v.co for v in o.data.vertices]
    alto = max(q.z for q in puntos)
    bajos = [q for q in puntos if q.z < alto * 0.3]
    torre = sum(bajos, Vector()) / len(bajos)
    arriba = [q for q in puntos if q.z > alto * 0.72]
    punta = max(arriba, key=lambda q: (q.x - torre.x) ** 2 + (q.y - torre.y) ** 2)
    nivel = min(q.z for q in arriba)
    rumbo = Vector((punta.x - torre.x, punta.y - torre.y, 0)).normalized()
    lado = rumbo.cross(Vector((0, 0, 1)))
    img = tabla("Grua_Cabina", [("#d9a52e", 0.15), ("#20262e", 0), ("#c8352c", 0.1), ("#3a3d44", 0.2)])
    p = Pieza("Grua_Cabina", img)
    centro = Vector((torre.x, torre.y, nivel - 0.6)) + lado * 1.15
    p.caja(centro, (1.5, 1.5, 1.6), 0)
    p.caja(centro + lado * 0.76 + Vector((0, 0, 0.2)), (1.1, 0.06, 0.7), 1)
    p.barra(centro - lado * 0.7, (torre.x, torre.y, centro.z), 0.25, 3)
    carro = torre + rumbo * 9
    cerca = [q for q in puntos if q.z > alto * 0.6 and (q.xy - carro.xy).length < 1.5]
    carro.z = min(q.z for q in cerca) - 0.15
    p.caja(carro, (0.9, 0.9, 0.35), 3)
    bajo = Vector((carro.x, carro.y, alto * 0.32))
    for d in (-0.14, 0.14):
        p.barra(carro + lado * d, bajo + lado * d, 0.04, 3)
    p.caja(bajo, (0.55, 0.55, 0.42), 2)
    p.cilindro(bajo - Vector((0, 0, 0.42)), 0.14, 0.42, 3, 8)
    return p.terminar()


def portico():
    img = tabla("Grua_Portico", [("#2f6f9f", 0.16), ("#c8352c", 0.14), ("#c9c6bc", 0.12), ("#2a2d33", 0.08)])
    p = Pieza("Grua_Portico", img)
    alto = 30
    for x in (-9, 9):
        for y in (-7, 7):
            p.caja((x, y, alto / 2), (1.5, 1.5, alto), 0)
            p.caja((x, y, 0.6), (2.5, 3.2, 1.2), 3)
        p.barra((x, -7, 10), (x, 7, 10), 0.9, 0)
        p.barra((x, -7, 12), (x, 7, 24), 0.5, 0)
    for y in (-7, 7):
        p.barra((-9, y, 16), (9, y, 16), 0.9, 0)
        p.barra((-9, y, alto), (9, y, alto), 1.5, 0)
    # pluma sobre el agua
    p.caja((12, 0, alto + 1.2), (70, 3.2, 2.4), 1)
    p.caja((-14, 0, alto + 3.2), (10, 7, 4), 2)
    for y in (-3.5, 3.5):
        p.barra((-6, y, alto), (0, y * 0.4, alto + 15), 0.8, 1)
        p.barra((6, y, alto), (0, y * 0.4, alto + 15), 0.8, 1)
        p.barra((0, y * 0.4, alto + 15), (44, y * 0.3, alto + 2.4), 0.3, 3)
        p.barra((0, y * 0.4, alto + 15), (-18, y * 0.5, alto + 5), 0.3, 3)
    carro = Vector((30, 0, alto - 0.2))
    p.caja(carro, (4, 4, 1.2), 2)
    colgado = Vector((30, 0, 12))
    for x, y in ((-1.4, -1), (1.4, -1), (-1.4, 1), (1.4, 1)):
        p.barra(carro + Vector((x, y, 0)), colgado + Vector((x, y, 0)), 0.09, 3)
    p.caja(colgado, (6.2, 2.5, 0.5), 3)
    return p.terminar()


def construir():
    bpy.ops.wm.open_mainfile(filepath=os.path.join(B.BLENDER, "puerto-oxido.blend"))
    nuevos = [
        contenedor("Contenedor_Azul", "#264f78"), contenedor("Contenedor_Gris", "#6a7078"),
        contenedor("Contenedor_Rojo", "#8e2f2a"), contenedor("Contenedor_Verde", "#2f6650"),
        barril(), bita(), muro(), red(), cartel(), techo(), grua_cabina(), portico(),
    ]
    for o in nuevos:
        print("NUEVA", o.name, len(o.data.polygons) * 2, [round(d, 1) for d in o.dimensions])
    return nuevos


def exportar(objs, archivo):
    for o in bpy.context.scene.objects:
        o.select_set(False)
    for o in objs:
        o.hide_viewport = o.hide_render = False
        o.hide_set(False)
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(SALIDA, archivo), use_selection=True, object_types={"MESH"},
        global_scale=1 / B.STUD, apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z", axis_up="Y", bake_space_transform=True, use_mesh_modifiers=True,
        mesh_smooth_type="FACE", add_leaf_bones=False, bake_anim=False,
        path_mode="COPY", embed_textures=True,
    )


def renders(objs, carpeta):
    escena = bpy.context.scene
    for o in list(escena.objects):
        if o.type in {"LIGHT", "CAMERA"}:
            bpy.data.objects.remove(o)
        else:
            o.hide_render = True
    mundo = bpy.data.worlds.new("Hoja")
    mundo.use_nodes = True
    mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.6, 0.68, 1)
    escena.world = mundo
    sol = bpy.data.objects.new("Sol", bpy.data.lights.new("Sol", "SUN"))
    sol.data.energy = 3.5
    sol.rotation_euler = (math.radians(50), 0, math.radians(35))
    escena.collection.objects.link(sol)
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    escena.collection.objects.link(cam)
    escena.camera = cam
    escena.render.resolution_x = escena.render.resolution_y = 420
    escena.view_settings.view_transform = "Standard"
    for o in objs:
        o.hide_render = False
        esquinas = [o.matrix_world @ Vector(c) for c in o.bound_box]
        centro = sum(esquinas, Vector()) / 8
        radio = max((c - centro).length for c in esquinas)
        cam.location = centro + Vector((0.95, -0.8, 0.5)).normalized() * radio * 3
        cam.rotation_euler = (centro - cam.location).to_track_quat("-Z", "Y").to_euler()
        escena.render.filepath = os.path.join(carpeta, o.name + ".png")
        bpy.ops.render.render(write_still=True)
        o.hide_render = True


if __name__ == "__main__":
    carpeta = sys.argv[sys.argv.index("--") + 1]
    piezas = construir()
    grua = bpy.data.objects["Grua_Estructura"]
    viejos = [
        bpy.data.objects[n] for n in (
            "Prop_Cajones", "Prop_Farola", "Prop_Reja", "Prop_Alambrado", "Galpon_Pared",
            "Galpon_ParedPorton", "Prop_MuroRemate", "Prop_Poste",
        )
    ]
    exportar(piezas + viejos + [grua], "_PaqueteArena.fbx")
    prueba = [bpy.data.objects[n] for n in ("Contenedor_Rojo", "Prop_Cajones", "Prop_Barril")]
    exportar(prueba, "_PruebaEstilo.fbx")
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(B.BLENDER, "arena-kit.blend"))
    renders(piezas, carpeta)
    cabina = bpy.data.objects["Grua_Cabina"]
    cabina.hide_render = False
    renders_una = bpy.context.scene
    renders_una.render.filepath = os.path.join(carpeta, "Grua_Completa.png")
    grua.hide_render = False
    cam = renders_una.camera
    esquinas = [grua.matrix_world @ Vector(c) for c in grua.bound_box]
    centro = sum(esquinas, Vector()) / 8
    cam.location = centro + Vector((1, -0.7, 0.35)).normalized() * 42
    cam.rotation_euler = (centro - cam.location).to_track_quat("-Z", "Y").to_euler()
    bpy.ops.render.render(write_still=True)
