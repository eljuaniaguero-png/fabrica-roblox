"""Renders del mapa (lo llama mapa.py --render con el Python de Blender).

Arma en Blender las mismas cajas y marcadores que va a armar GeneradorMapa en Roblox y saca
fotos: vista general, la plaza, la Ruleta de Mascotas, el Santuario del Renacer, cada bioma, una
cámara secreta por dentro y la Dimensión Prisma. Las geodas se arman con rocas.py (las mismas de
arte/fbx/Geodas_*.fbx): cada punto lleva una de las 3 variantes de su bioma (según su número). La
rueda, la puerta del Santuario y los carteles los arma el juego; acá se dibujan parecidos.
1 stud = 1 unidad; Roblox (x, y, z) pasa a Blender como (x, -z, y), y un Giro de Roblox es un giro
igual alrededor del eje Z de Blender.
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
    """Arma una vez (ocultas) las geodas de cada bioma (sus 3 variantes) y las especiales con
    rocas.py, las mismas que van en arte/fbx/Geodas_*.fbx, para copiarlas en los puntos."""
    import modelos as M
    import rocas

    moldes = {}

    def guardar(clave, objs):
        for o in M.sin_grietas(objs):
            o.hide_render = True
            moldes.setdefault(clave, []).append(o)

    for zona, v, est in rocas.variantes():
        mats = rocas.mats_de(est)
        for tam in ("Pequena", "Mediana", "Jefe") if v == 1 else ("Pequena", "Mediana"):
            datos = M.GEODAS[tam]
            nombre = f"Zona{zona} {rocas.nombre_tamano(tam, v)}"
            guardar((zona, v, tam), rocas.armar(nombre, datos, est, mats, rocas.semilla_de(datos, zona, v)))
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


COLORES_RUEDA = ["#FF4D6D", "#FFB627", "#FFE14D", "#5CE07A", "#3DD6FF", "#3D7BFF", "#C77DFF", "#FF8FD8"]


def rueda(pos, giro, radio, grosor, mat):
    """La Ruleta: disco de 8 colores con aro dorado, centro y flecha arriba. Se arma de frente
    (cara hacia +Y de Blender = el -Z de Roblox) y se gira con el Giro del marcador."""
    base = Matrix.Translation(pos) @ Matrix.Rotation(giro, 4, "Z")
    for k in range(8):
        bm = bmesh.new()
        puntos = [(0.0, 0.0)] + [
            (radio * math.cos((k + t / 8) * math.tau / 8), radio * math.sin((k + t / 8) * math.tau / 8)) for t in range(9)
        ]
        frente = [bm.verts.new((x, grosor / 2, z)) for x, z in puntos]
        atras = [bm.verts.new((x, -grosor / 2, z)) for x, z in puntos]
        bm.faces.new(frente)
        bm.faces.new(list(reversed(atras)))
        for i in range(len(puntos)):
            j = (i + 1) % len(puntos)
            bm.faces.new([frente[i], atras[i], atras[j], frente[j]])
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        o = objeto("Gajo", bm, mat(f"Gajo{k}", COLORES_RUEDA[k], "SmoothPlastic"))
        o.matrix_world = base
    piezas = []
    bpy.ops.mesh.primitive_torus_add(major_radius=radio, minor_radius=0.55, location=(0, 0, 0))
    piezas.append((bpy.context.active_object, mat("AroRueda", "#FFC83D", "Foil")))
    bpy.ops.mesh.primitive_cylinder_add(radius=1.6, depth=grosor + 0.6, location=(0, 0, 0))
    piezas.append((bpy.context.active_object, mat("CentroRueda", "#FFFFFF", "SmoothPlastic")))
    for o, m in piezas:
        o.data.materials.append(m)
        o.matrix_world = base @ Matrix.Rotation(math.radians(90), 4, "X")  # de pie, de frente
    bm = bmesh.new()  # flecha arriba, apuntando para abajo
    v = [bm.verts.new(p) for p in ((-1.2, grosor, radio + 2.2), (1.2, grosor, radio + 2.2), (0, grosor, radio - 1.0))]
    w = [bm.verts.new((p.co.x, p.co.y + 0.6, p.co.z)) for p in v]
    bm.faces.new(v)
    bm.faces.new(list(reversed(w)))
    for i in range(3):
        j = (i + 1) % 3
        bm.faces.new([v[i], v[j], w[j], w[i]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    objeto("Flecha", bm, mat("Flecha", "#FF2E4D", "SmoothPlastic")).matrix_world = base


def texto(cuerpo, pos, giro, tam, color, mat):
    curva = bpy.data.curves.new("Texto", "FONT")
    curva.body = cuerpo
    curva.size = tam
    curva.align_x = "CENTER"
    curva.align_y = "CENTER"
    curva.extrude = 0.05
    o = bpy.data.objects.new("Texto", curva)
    o.data.materials.append(mat("Texto" + color, color, "Neon"))
    o.location = pos
    o.rotation_euler = (math.radians(90), 0, math.radians(180) + giro)  # de pie, mirando a +Y y girado
    bpy.context.scene.collection.objects.link(o)


def marcadores(lista, moldes, mats):
    propios = {}

    def mat(nombre, color, tipo="Neon", transp=0):
        clave = (nombre, color)
        if clave not in propios:
            propios[clave] = material(nombre, color, tipo, transp)
        return propios[clave]

    i = 0
    for m in lista:
        t, (x, y, z), (sx, sy, sz) = m["Tipo"], m["Pos"], m["Tam"]
        pos = a_blender(x, y, z)
        giro = math.radians(m["Giro"])
        a = m["Atributos"]
        if t == "PuntoGeoda":
            i += 1
            zona = a.get("Zona", 1)
            if a.get("Tamano") in ("Oculta", "Prisma", "Renacida"):
                clave = a["Tamano"]
            elif a.get("Jefe"):
                clave = (zona, 1, "Jefe")
            else:
                clave = (zona, 1 + i % 3, "Mediana" if (i // 3) % 3 == 0 else "Pequena")
            poner_geoda(moldes, clave, pos, i * 1.3)
            continue
        bm = bmesh.new()
        if t == "Vitrina":
            caja(bm, x - 2.5, y - 1, z - 2.5, 5, 2, 5)
            objeto("Vitrina", bm, mat("Vitrina", "#2A2F4F", "Slate"))
        elif t == "Tablero":
            caja(bm, x - 7, y - 5, z - 0.5, 14, 10, 1)
            objeto("Tablero", bm, mat("Tablero", "#7A2FE0", "Slate"))
        elif t == "PuertaZona":
            caja(bm, x - sx / 2, y - sy / 2, z - sz / 2, sx, sy, sz)
            objeto("Puerta", bm, mat("PuertaZona", "#9CFBFF", "Glass", 0.45))
        elif t == "PuertaRenacer":
            caja(bm, -sx / 2, -sy / 2, -sz / 2, sx, sy, sz)
            o = objeto("PuertaRenacer", bm, mat("PuertaRenacer", "#FFD23F", "Glass", 0.4))
            o.matrix_world = Matrix.Translation(pos) @ Matrix.Rotation(giro, 4, "Z")
        elif t == "PuertaSecreta":
            caja(bm, x - sx / 2, y - sy / 2, z - sz / 2, sx, sy, sz)
            objeto("PuertaSecreta", bm, mats["Piedra"])
            bm2 = bmesh.new()
            for k in range(3):
                caja(bm2, x - sx / 2 - 0.1, y - 4 + k * 3, z - 4 + k * 3, 0.3, 2.5, 0.4)
            objeto("Grietas", bm2, mat("Grieta", "#C77DFF"))
        elif t == "Cofre":
            caja(bm, x - 2, y - 1.2, z - 1.5, 4, 2.4, 3)
            objeto("Cofre", bm, mats["Madera"])
            bm2 = bmesh.new()
            caja(bm2, x - 2.1, y + 1.2, z - 1.6, 4.2, 0.8, 3.2)
            objeto("Tapa", bm2, mats["Oro"])
        elif t == "Altar":
            caja(bm, x - 2, y - 1.5, z - 2, 4, 3, 4)
            objeto("Altar", bm, mats["PiedraClara"])
            bpy.ops.mesh.primitive_uv_sphere_add(radius=1.1, location=a_blender(x, y + 2.6, z))
            bpy.context.active_object.data.materials.append(mat("Orbe", "#FFE45C"))
        elif t == "Portal":
            bm.free()
            bpy.ops.mesh.primitive_torus_add(major_radius=5, minor_radius=0.6, location=pos)
            anillo = bpy.context.active_object
            anillo.rotation_euler = (math.radians(90), 0, giro)
            anillo.data.materials.append(mat("Portal", "#C99BFF"))
            bpy.ops.mesh.primitive_cylinder_add(radius=4.6, depth=0.3, location=pos)
            disco = bpy.context.active_object
            disco.rotation_euler = (math.radians(90), 0, giro)
            disco.data.materials.append(mat("Disco", "#9CFBFF", "Neon"))
        elif t == "Ruleta":
            bm.free()
            rueda(pos, giro, sx / 2, sz, mat)
        elif t == "Cartel":
            # tabla de madera con el frente oscuro, dos patas y el texto (lo arma el juego)
            caja(bm, -sx / 2, -sy / 2, -sz / 2, sx, sy, sz)
            for px in (-sx / 2 + 0.6, sx / 2 - 1.2):
                caja(bm, px, -y, -0.3, 0.6, y - sy / 2, 0.6)
            base = Matrix.Translation(pos) @ Matrix.Rotation(giro, 4, "Z")
            objeto("Cartel", bm, mats["Madera"]).matrix_world = base
            bm2 = bmesh.new()
            caja(bm2, -sx / 2 + 0.4, -sy / 2 + 0.4, -sz / 2 - 0.1, sx - 0.8, sy - 0.8, 0.2)
            objeto("Frente", bm2, mat("FrenteCartel", "#1B1F3B", "Slate")).matrix_world = base
            frente = base @ Vector((0, sz / 2 + 0.25, 0))
            texto(a.get("Texto", ""), frente, giro, 1.3, "#FFE45C", mat)
        elif t == "Museo":
            caja(bm, x - 1.5, y - 2, z - 1.5, 3, 4, 3)
            objeto("Museo", bm, mats["Oro"])
        elif t == "Spawn":
            caja(bm, x - 5, y - 0.5, z - 5, 10, 1, 10)
            objeto("Spawn", bm, mat("Spawn", "#FFFFFF", "Pavement"))
        elif t == "Luz":
            bm.free()
            luz = bpy.data.lights.new("Luz", "POINT")
            luz.energy = 2500 if 0 < z and y < 100 else 500  # en la plaza y en el Prisma, más suave
            luz.color = hexa(a.get("Color", "#FFFFFF"))
            lo = bpy.data.objects.new("Luz", luz)
            lo.location = pos
            bpy.context.scene.collection.objects.link(lo)
        else:
            bm.free()


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


def renderizar(cajas, lista, MATERIALES, renders, solo=None):
    """Arma todo y saca las fotos (con solo = lista de nombres, saca solo esas)."""
    import mapa

    e = escena()
    mats = {n: material(n, c, t, tr) for n, (c, t, tr, _) in MATERIALES.items()}
    por_mat = {}
    for c in cajas:
        por_mat.setdefault(c[0], []).append(c)
    objetos = {}
    for n, lista_cajas in por_mat.items():
        bm = bmesh.new()
        for _, x, y, z, sx, sy, sz in lista_cajas:
            caja(bm, x, y, z, sx, sy, sz)
        objetos[n] = objeto(n, bm, mats[n])
    moldes = geodas()
    marcadores(lista, moldes, mats)
    os.makedirs(renders, exist_ok=True)

    def foto(nombre, desde, hacia, lente=35):
        if solo and nombre not in solo:
            return
        cam = camara(e, desde, hacia, lente)
        e.render.filepath = os.path.join(renders, f"mapa_{nombre}.jpg")
        bpy.ops.render.render(write_still=True)
        bpy.data.objects.remove(cam)
        print("  render", nombre)

    foto("general", (430, 400, -230), (-20, 0, 500), 22)
    foto("plaza", (0, 150, 64), (0, 0, -66), 24)
    rx, ry, rz = mapa.RUEDA
    foto("ruleta", (rx - 66, ry + 18, rz - 20), (rx, ry - 2, rz), 30)
    foto("santuario", (0, 120, -44), (0, 0, -116), 30)
    for n in range(1, 6):
        zs = mapa.inicio_zona(n)
        foto(f"bioma{n}", (96, 104, zs - 6), (-12, 0, zs + 132), 24)
    foto("dimension_prisma", (100, 262, mapa.PRISMA[2] - 100), mapa.PRISMA, 28)
    # cámara secreta del bioma 1, por dentro: se saca el risco que está encima de la cámara
    if solo and "camara_secreta" not in solo:
        return
    zd = mapa.puerta_secreta_z(1)
    sin_techo = set()
    for lista_cajas in por_mat.values():
        for c in lista_cajas:
            _, x, y, z, sx, sy, sz = c
            if x + sx > mapa.XMAX and y + sy > 16 and z < zd + 28 and z + sz > zd - 24:
                sin_techo.add(c)
    for o in objetos.values():
        o.hide_render = True
    for n, lista_cajas in por_mat.items():
        bm = bmesh.new()
        for c in lista_cajas:
            if c not in sin_techo:
                caja(bm, *c[1:])
        objeto(n + "_corte", bm, mats[n])
    foto("camara_secreta", (mapa.XMAX - 30, 74, zd - 44), (mapa.XMAX + 28, 0, zd + 2), 30)
