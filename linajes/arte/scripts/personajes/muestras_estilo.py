"""Tres muestras de acabado para los personajes de Linajes. Son pruebas de estilo, no modelos finales.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/muestras_estilo.py

Escribe renders/muestra-personajes.png. Proporciones R15 en studs, mirando a -Y.
"""

import math
import os

import bpy
from mathutils import Euler, Vector

ARTE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def material(nombre, color, rugosidad=0.62):
    m = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    c = tuple(int(color[i : i + 2], 16) / 255 for i in (1, 3, 5))
    b.inputs["Base Color"].default_value = (*[x**2.2 for x in c], 1)
    b.inputs["Roughness"].default_value = rugosidad
    return m


def contorno():
    m = bpy.data.materials.get("Contorno") or bpy.data.materials.new("Contorno")
    m.use_nodes = True
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.005, 0.005, 0.01, 1)
    m.use_backface_culling = True
    return m


class Muestra:
    def __init__(self, x, borde):
        self.x, self.borde = x, borde

    def poner(self, obj, mat):
        obj.data.materials.append(mat)
        if self.borde:
            obj.data.materials.append(contorno())
            s = obj.modifiers.new("Borde", "SOLIDIFY")
            s.thickness, s.offset = self.borde, 1
            s.use_flip_normals, s.material_offset = True, 1
        return obj

    def caja(self, centro, medida, mat, giro=(0, 0, 0)):
        bpy.ops.mesh.primitive_cube_add(size=1, location=Vector(centro) + Vector((self.x, 0, 0)))
        o = bpy.context.object
        o.scale = medida
        o.rotation_euler = Euler([math.radians(g) for g in giro])
        bpy.ops.object.transform_apply(scale=True)
        return self.poner(o, mat)

    def punta(self, base, hacia, ancho, mat):
        """Mechón filoso de 4 caras desde base hasta la punta."""
        a = Vector(base) + Vector((self.x, 0, 0))
        d = Vector(hacia)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=ancho, depth=d.length, location=a + d / 2)
        o = bpy.context.object
        o.rotation_mode = "QUATERNION"
        o.rotation_quaternion = d.to_track_quat("Z", "Y")
        return self.poner(o, mat)

    def cuerpo(self, piel, arriba, abajo, zapato):
        self.caja((-0.5, 0, 1.15), (0.92, 0.95, 1.7), abajo)
        self.caja((0.5, 0, 1.15), (0.92, 0.95, 1.7), abajo)
        self.caja((-0.5, -0.06, 0.2), (0.96, 1.12, 0.4), zapato)
        self.caja((0.5, -0.06, 0.2), (0.96, 1.12, 0.4), zapato)
        self.caja((0, 0, 2.2), (2, 1, 0.4), abajo)
        self.caja((0, 0, 3.2), (2, 1, 1.65), arriba)
        self.caja((-1.5, 0, 3.05), (0.92, 0.95, 1.95), arriba)
        self.caja((1.5, 0, 3.05), (0.92, 0.95, 1.95), arriba)
        self.caja((-1.5, 0, 1.92), (0.86, 0.88, 0.34), piel)
        self.caja((1.5, 0, 1.92), (0.86, 0.88, 0.34), piel)
        self.caja((0, 0, 4.1), (0.62, 0.62, 0.3), piel)
        self.caja((0, 0, 4.75), (1.28, 1.2, 1.15), piel)

    def cara(self, iris, ceja=None):
        ceja = ceja or material("Ceja", "#16161c")
        blanco = material("Blanco", "#f2f0ea", 0.35)
        for lado in (-1, 1):
            self.caja((0.31 * lado, -0.61, 4.76), (0.36, 0.03, 0.17), blanco, (0, -10 * lado, 0))
            self.caja((0.27 * lado, -0.635, 4.75), (0.15, 0.03, 0.15), material(f"Iris{iris}", iris, 0.25))
            self.caja((0.32 * lado, -0.64, 4.97), (0.5, 0.04, 0.075), ceja, (0, -19 * lado, 0))
        self.caja((0, -0.62, 4.36), (0.28, 0.03, 0.045), ceja)


def muestra_a(x):
    m = Muestra(x, 0.035)
    m.cuerpo(material("PielA", "#d8a06f"), material("CamisaA", "#e6e3da"), material("PantalonA", "#242a39"), material("BotaA", "#7f2831"))
    campera, rojo = material("CamperaA", "#28436f"), material("RojoA", "#c2213a")
    for lado in (-1, 1):
        m.caja((0.72 * lado, -0.03, 3.15), (0.62, 1.13, 1.88), campera)
        m.caja((1.5 * lado, -0.01, 3.42), (1.03, 1.05, 1.28), campera)
        m.caja((0.42 * lado, -0.59, 3.62), (0.2, 0.05, 0.95), rojo, (0, -12 * lado, 0))
    m.caja((0, -0.03, 2.28), (2.05, 1.08, 0.2), rojo)
    m.cara("#39d3ff")
    pelo = material("PeloA", "#12141e")
    m.caja((0, 0.08, 5.3), (1.38, 1.1, 0.42), pelo)
    for bx, hz in [(-0.56, (-0.45, -0.1, 0.35)), (-0.28, (-0.28, -0.25, 0.62)), (0, (0.02, -0.35, 0.72)), (0.3, (0.28, -0.28, 0.58)), (0.58, (0.48, -0.08, 0.3))]:
        m.punta((bx, -0.28, 5.28), hz, 0.34, pelo)
    for bx in (-0.5, 0, 0.5):
        m.punta((bx, 0.34, 5.25), (bx * 0.8, 0.55, 0.42), 0.34, pelo)


def muestra_b(x):
    m = Muestra(x, 0.02)
    m.cuerpo(material("PielB", "#f0c6a4"), material("TrajeB", "#1f2d3d"), material("PantalonB", "#e8e8ed"), material("BotaB", "#2fa6a0"))
    tapado, acento = material("TapadoB", "#f0f1f4"), material("AcentoB", "#2fa6a0")
    m.caja((0, 0.53, 2.45), (2.08, 0.12, 2.95), tapado)
    for lado in (-1, 1):
        m.caja((0.8 * lado, -0.54, 2.7), (0.42, 0.11, 2.45), tapado)
        m.caja((1.5 * lado, -0.01, 3.35), (1.02, 1.02, 1.4), tapado)
        m.caja((1.5 * lado, -0.01, 2.56), (1.04, 1.04, 0.16), acento)
        m.caja((0.56 * lado, -0.61, 2.7), (0.08, 0.05, 2.45), acento)
    m.caja((0, -0.08, 4.04), (1.45, 1.22, 0.3), acento)
    m.cara("#9d6bff", material("CejaB", "#c9ced8"))
    pelo = material("PeloB", "#d9dee7", 0.45)
    m.caja((0, 0.06, 5.32), (1.38, 1.12, 0.45), pelo)
    for bx, largo in [(-0.65, 1.15), (-0.34, 0.75), (0, 0.9), (0.34, 0.72), (0.65, 1.15)]:
        m.punta((bx, -0.4, 5.35), (bx * 0.25, -0.15, -largo), 0.27, pelo)
    for bx in (-0.5, -0.17, 0.17, 0.5):
        m.punta((bx, 0.28, 5.42), (bx * 0.75, 0.32, 0.78), 0.34, pelo)


def muestra_c(x):
    m = Muestra(x, 0)
    m.cuerpo(material("PielC", "#8b5a3c"), material("ChalecoC", "#3b3a34"), material("PantalonC", "#51483b"), material("BotaC", "#1d1c1a"))
    naranja, venda = material("NaranjaC", "#f2a23a"), material("VendaC", "#d8d0bc")
    for lado in (-1, 1):
        m.caja((1.5 * lado, 0, 3.65), (1.08, 1.08, 0.72), material("HombroC", "#5f6875", 0.42))
        m.caja((1.5 * lado, 0, 2.7), (0.98, 0.98, 1.06), material("PielC", "#8b5a3c"))
        for z in (2.38, 2.65, 2.92):
            m.caja((1.5 * lado, 0, z), (1.0, 1.0, 0.12), venda, (0, 8 * lado, 0))
        m.caja((0.55 * lado, -0.55, 3.15), (0.26, 0.08, 1.55), naranja)
    m.caja((0, -0.54, 2.24), (2.04, 0.08, 0.32), naranja)
    m.cara("#ffb13b")
    pelo = material("PeloC", "#191714")
    for y, largo in [(-0.42, 0.68), (-0.14, 0.86), (0.14, 0.8), (0.42, 0.62)]:
        m.punta((0, y, 5.25), (0, y * 0.45, largo), 0.38, pelo)
    m.caja((0, 0, 5.34), (0.72, 1.18, 0.16), pelo)


def luz(tipo, lugar, energia, color):
    bpy.ops.object.light_add(type=tipo, location=lugar)
    o = bpy.context.object
    o.data.energy, o.data.color = energia, color
    o.rotation_euler = (Vector((0, 0, 3)) - Vector(lugar)).to_track_quat("-Z", "Y").to_euler()


def render(ruta, desde):
    e = bpy.context.scene
    cam = bpy.data.objects.get("Cam")
    if not cam:
        bpy.ops.object.camera_add()
        cam = bpy.context.object
        cam.name = "Cam"
        cam.data.type, cam.data.ortho_scale = "ORTHO", 19
        e.camera = cam
    cam.location = desde
    cam.rotation_euler = (Vector((0, 0, 3)) - Vector(desde)).to_track_quat("-Z", "Y").to_euler()
    e.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def main():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    muestra_a(-5.5)
    muestra_b(0)
    muestra_c(5.5)
    e = bpy.context.scene
    e.render.engine = "BLENDER_EEVEE"
    e.render.resolution_x, e.render.resolution_y = 1500, 760
    e.view_settings.view_transform = "Standard"
    mundo = bpy.data.worlds.new("Mundo")
    mundo.use_nodes = True
    mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.08, 0.1, 0.14, 1)
    mundo.node_tree.nodes["Background"].inputs[1].default_value = 1
    e.world = mundo
    bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, 0))
    bpy.context.object.data.materials.append(material("Piso", "#30343d"))
    luz("SUN", (-8, -14, 18), 4, (1, 0.96, 0.9))
    luz("SUN", (12, 8, 8), 1.4, (0.65, 0.78, 1))
    for nombre, desde in (("frente", (0, -30, 4)), ("tres-cuartos", (-13, -27, 8))):
        render(os.path.join(ARTE, "renders", f"muestra-personajes-{nombre}.png"), desde)


main()
