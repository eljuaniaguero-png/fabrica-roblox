"""Renders del mapa (lo llama mapa.py --render con el Python de Blender).

Arma en Blender las mismas cajas y marcadores que va a armar GeneradorMapa en Roblox y saca
fotos: vista general, la plaza, cada bioma, una cámara secreta por dentro y la Dimensión Prisma.
Las geodas se arman con rocas.py (las mismas de arte/fbx/Geodas_*.fbx). 1 stud = 1 unidad;
Roblox (x, y, z) pasa a Blender como (x, -z, y).
"""

import math
import os

import bpy  # noqa: I001  (bpy tiene que ir antes que bmesh)
import bmesh
from mathutils import Matrix, Vector


def hexa(h):
    h = h.lstrip("#")
    return tuple((int(h[i : i + 2], 16) / 255) ** 2.2 for i in (0, 2, 4))


def a_blender(x, y, z):
    return Vector((x, -z, y))


def material(nombre, color, tipo, transp):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    p = m.node_tree.nodes["Principled BSDF"]
    p.inputs["Base Color"].default_value = (*hexa(color), 1)
    p.inputs["Roughness"].default_value = 0.7
    if tipo == "Neon":
        p.inputs["Emission Color"].default_value = (*hexa(color), 1)
        p.inputs["Emission Strength"].default_value = 3.0
    elif tipo in ("Glass", "Ice"):
        p.inputs["Roughness"].default_value = 0.15
        p.inputs["Emission Color"].default_value = (*hexa(color), 1)
        p.inputs["Emission Strength"].default_value = 0.35
    elif tipo == "Foil":
        p.inputs["Metallic"].default_value = 0.9
        p.inputs["Roughness"].default_value = 0.25
    if transp > 0:
        p.inputs["Alpha"].default_value = 1 - transp
        try:
            m.surface_render_method = "BLENDED"
        except AttributeError:
            pass
    return m


def caja(bm, x, y, z, sx, sy, sz):
    """Agrega una caja (studs de Roblox, esquina de abajo) al bmesh."""
    centro = a_blender(x + sx / 2, y + sy / 2, z + sz / 2)
    escala = Matrix.Diagonal((sx, sz, sy, 1))
    bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Translation(centro) @ escala)


def objeto(nombre, bm, mat):
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nombre, me)
    o.data.materials.append(mat)
    bpy.context.scene.collection.objects.link(o)
    return o


def escena(ancho=1280, alto=720):
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o)
    e = bpy.context.scene
    e.render.engine = "CYCLES"
    e.cycles.device = "CPU"
    e.cycles.samples = 24
    e.cycles.use_denoising = True
    e.render.resolution_x = ancho
    e.render.resolution_y = alto
    e.view_settings.view_transform = "Standard"
    e.render.image_settings.file_format = "JPEG"
    e.render.image_settings.quality = 88
    mundo = bpy.data.worlds.new("Cielo")
    e.world = mundo
    fondo = mundo.node_tree.nodes.get("Background") or mundo.node_tree.nodes.new("ShaderNodeBackground")
    fondo.inputs["Color"].default_value = (*hexa("#55B8FF"), 1)
    fondo.inputs["Strength"].default_value = 1.0
    salida = mundo.node_tree.nodes.get("World Output") or mundo.node_tree.nodes.new("ShaderNodeOutputWorld")
    mundo.node_tree.links.new(fondo.outputs["Background"], salida.inputs["Surface"])
    sol = bpy.data.lights.new("Sol", "SUN")
    sol.energy = 4.0
    sol.angle = math.radians(6)
    o = bpy.data.objects.new("Sol", sol)
    o.rotation_euler = (math.radians(50), math.radians(10), math.radians(35))
    e.collection.objects.link(o)
    return e


def geodas():
    """Arma una vez (ocultas) las geodas de cada bioma y las especiales con rocas.py, las mismas
    que van en arte/fbx/Geodas_*.fbx, para copiarlas en los puntos del mapa."""
    import modelos as M
    import rocas

    moldes = {}

    def guardar(clave, objs):
        for o in M.sin_grietas(objs):
            o.hide_render = True
            moldes.setdefault(clave, []).append(o)

    for zona, est in rocas.ESTILOS.items():
        mats = rocas.mats_de(est)
        for tam in ("Pequena", "Mediana", "Jefe"):
            datos = M.GEODAS[tam]
            guardar((zona, tam), rocas.armar(f"Zona{zona} {tam}", datos, est, mats, datos["semilla"] + zona * 101))
    for nombre, est in rocas.ESPECIALES.items():
        datos = rocas.datos_especial(est)
        guardar(nombre, rocas.armar(nombre, datos, est, rocas.mats_de(est), datos["semilla"] + 7))
    return moldes


def poner_geoda(moldes, clave, pos, giro):
    # las mallas están en metros (1 stud = 0,28 m) y con la base en el origen
    base = Matrix.Translation(pos) @ Matrix.Rotation(giro, 4, "Z") @ Matrix.Scale(1 / 0.28, 4)
    for o in moldes.get(clave, []):
        c = o.copy()
        c.hide_render = False
        c.matrix_world = base @ o.matrix_world
        bpy.context.scene.collection.objects.link(c)


def marcadores(lista, moldes, mats):
    neon = {}

    def mat(nombre, color, tipo="Neon", transp=0):
        clave = (nombre, color)
        if clave not in neon:
            neon[clave] = material(nombre, color, tipo, transp)
        return neon[clave]

    rng = 0
    for m in lista:
        t, (x, y, z), (sx, sy, sz) = m["Tipo"], m["Pos"], m["Tam"]
        pos = a_blender(x, y, z)
        a = m["Atributos"]
        if t == "PuntoGeoda":
            rng += 1
            zona = a.get("Zona", 1)
            if a.get("Tamano") in ("Oculta", "Prisma"):
                clave = a["Tamano"]
            elif a.get("Jefe"):
                clave = (zona, "Jefe")
            else:
                clave = (zona, "Mediana" if rng % 3 == 0 else "Pequena")
            poner_geoda(moldes, clave, pos, rng * 1.3)
            continue
        bm = bmesh.new()
        if t == "Vitrina":
            caja(bm, x - 2.5, y - 1, z - 2.5, 5, 2, 5)
            o = objeto("Vitrina", bm, mat("Vitrina", "#2A2F4F", "Slate"))
        elif t == "Tablero":
            caja(bm, x - 7, y - 5, z - 0.5, 14, 10, 1)
            o = objeto("Tablero", bm, mat("Tablero", "#7A2FE0", "Slate"))
        elif t == "PuertaZona":
            caja(bm, x - sx / 2, y - sy / 2, z - sz / 2, sx, sy, sz)
            o = objeto("Puerta", bm, mat("PuertaZona", "#9CFBFF", "Glass", 0.45))
        elif t == "PuertaSecreta":
            caja(bm, x - sx / 2, y - sy / 2, z - sz / 2, sx, sy, sz)
            o = objeto("PuertaSecreta", bm, mats["Piedra"])
            bm2 = bmesh.new()
            for k in range(3):
                caja(bm2, x - sx / 2 - 0.1, y - 4 + k * 3, z - 4 + k * 3, 0.3, 2.5, 0.4)
            objeto("Grietas", bm2, mat("Grieta", "#C77DFF"))
        elif t == "Cofre":
            caja(bm, x - 2, y - 1.2, z - 1.5, 4, 2.4, 3)
            o = objeto("Cofre", bm, mats["Madera"])
            bm2 = bmesh.new()
            caja(bm2, x - 2.1, y + 1.2, z - 1.6, 4.2, 0.8, 3.2)
            objeto("Tapa", bm2, mats["Oro"])
        elif t == "Altar":
            caja(bm, x - 2, y - 1.5, z - 2, 4, 3, 4)
            o = objeto("Altar", bm, mats["PiedraClara"])
            bpy.ops.mesh.primitive_uv_sphere_add(radius=1.1, location=a_blender(x, y + 2.6, z))
            bpy.context.active_object.data.materials.append(mat("Orbe", "#FFE45C"))
        elif t == "Portal":
            bpy.ops.mesh.primitive_torus_add(major_radius=5, minor_radius=0.6, location=pos)
            anillo = bpy.context.active_object
            anillo.rotation_euler = (math.radians(90), 0, math.radians(m["Giro"]))
            anillo.data.materials.append(mat("Portal", "#C99BFF"))
            bpy.ops.mesh.primitive_cylinder_add(radius=4.6, depth=0.3, location=pos)
            disco = bpy.context.active_object
            disco.rotation_euler = (math.radians(90), 0, math.radians(m["Giro"]))
            disco.data.materials.append(mat("Disco", "#9CFBFF", "Neon"))
            bm.free()
            continue
        elif t == "Museo":
            caja(bm, x - 1.5, y - 2, z - 1.5, 3, 4, 3)
            o = objeto("Museo", bm, mats["Oro"])
        elif t == "Spawn":
            caja(bm, x - 5, y - 0.5, z - 5, 10, 1, 10)
            o = objeto("Spawn", bm, mat("Spawn", "#FFFFFF", "Pavement"))
        elif t == "Luz":
            bm.free()
            luz = bpy.data.lights.new("Luz", "POINT")
            luz.energy = 2500
            luz.color = hexa(a.get("Color", "#FFFFFF"))
            lo = bpy.data.objects.new("Luz", luz)
            lo.location = pos
            bpy.context.scene.collection.objects.link(lo)
            continue
        else:
            bm.free()
            continue


def camara(e, desde, hacia, lente=35):
    cam = bpy.data.cameras.new("Camara")
    cam.lens = lente
    cam.clip_end = 5000
    o = bpy.data.objects.new("Camara", cam)
    e.collection.objects.link(o)
    o.location = a_blender(*desde)
    o.rotation_euler = (a_blender(*hacia) - o.location).to_track_quat("-Z", "Y").to_euler()
    e.camera = o
    return o


def renderizar(cajas, lista, MATERIALES, renders):
    e = escena()
    mats = {n: material(n, c, t, tr) for n, (c, t, tr, _) in MATERIALES.items()}
    por_mat = {}
    for c in cajas:
        por_mat.setdefault(c[0], []).append(c)
    objetos = {}
    for n, lista_cajas in por_mat.items():
        bm = bmesh.new()
        for (_, x, y, z, sx, sy, sz) in lista_cajas:
            caja(bm, x, y, z, sx, sy, sz)
        objetos[n] = objeto(n, bm, mats[n])
    moldes = geodas()
    marcadores(lista, moldes, mats)
    os.makedirs(renders, exist_ok=True)

    def foto(nombre, desde, hacia, lente=35):
        cam = camara(e, desde, hacia, lente)
        e.render.filepath = os.path.join(renders, f"mapa_{nombre}.jpg")
        bpy.ops.render.render(write_still=True)
        bpy.data.objects.remove(cam)
        print("  render", nombre)

    import mapa

    foto("general", (420, 420, -260), (0, 0, 380), 24)
    foto("plaza", (70, 70, 20), (0, 0, -36), 30)
    for n in range(1, 6):
        zs = mapa.inicio_zona(n)
        foto(f"bioma{n}", (64, 78, zs + 2), (-8, 0, zs + 104), 26)
    # cámara secreta del bioma 1, por dentro: se saca el techo del risco encima de la cámara
    zd = mapa.inicio_zona(1) + 56 + 40
    sin_techo = set()
    for lista_cajas in por_mat.values():
        for c in lista_cajas:
            _, x, y, z, sx, sy, sz = c
            if x + sx > 84 and y + sy > 16 and z < zd + 28 and z + sz > zd - 24:
                sin_techo.add(c)
    for o in objetos.values():
        o.hide_render = True
    for n, lista_cajas in por_mat.items():
        bm = bmesh.new()
        for c in lista_cajas:
            if c not in sin_techo:
                caja(bm, *c[1:])
        objeto(n + "_corte", bm, mats[n])
    foto("camara_secreta", (60, 70, zd - 40), (112, 0, zd + 2), 30)
    foto("dimension_prisma", (90, 260, 330), (0, 200, 428), 28)
