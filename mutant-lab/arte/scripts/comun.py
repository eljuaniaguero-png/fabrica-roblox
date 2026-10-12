"""Herramientas comunes para fabricar el arte de Mutant Lab en Blender.

Cada objeto tiene su script en objetos/ y se corre con Blender en segundo plano:
    blender -b --factory-startup --python-exit-code 1 -P mutant-lab/arte/scripts/objetos/<objeto>.py

Reglas (ideas/mutant-lab-arte.md, sección 2):
- 1 unidad de Blender = 1 stud.
- El frente del objeto mira a -Y en Blender (la vista Front). Al exportar llega a Roblox mirando a -Z.
- El origen es el punto de apoyo: el objeto se arma con la base en z = 0, centrado en x = y = 0,
  y todas sus mallas con la transformación en cero (la geometría ya está en su lugar).
- Una malla por zona de color, sin texturas. Nombres Objeto_Parte y sufijos _Neon, _Vidrio, _Anim, _Ojo.
"""

import math
import os
import re

import bmesh
import bpy
from mathutils import Matrix, Vector

ARTE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PALETA_LUAU = os.path.join(os.path.dirname(ARTE), "src", "shared", "Paleta.luau")

NOMBRE_VALIDO = re.compile(r"^[A-Z][A-Za-z0-9]*(_[A-Z][A-Za-z0-9]*)+$")

# ---------------------------------------------------------------------------
# Colores: se leen de shared/Paleta.luau, así hay un solo lugar con los colores.
# Claves con puntos: "Acento", "Catalizadores.Slime", "Elementos.Fuego", "Especies.1.Manchas".
# ---------------------------------------------------------------------------

_HEX = r'Color3\.fromHex\("([0-9A-Fa-f]{6})"\)'


def _leer_paleta():
    colores, locales, pila, cuenta = {}, {}, [], []

    def ruta(clave):
        return ".".join([p for p in pila if p] + [str(clave)])

    with open(PALETA_LUAU, encoding="utf-8") as f:
        for linea in f:
            s = linea.split("--")[0].strip()
            if not s:
                continue
            m = re.match(r"^local\s+(\w+)\s*=\s*" + _HEX, s)
            if m:
                locales[m.group(1)] = m.group(2)
                continue
            m = re.match(r"^(?:local\s+)?(\w+)\s*=\s*\{$", s)
            if m:
                pila.append(None if m.group(1) == "Paleta" else m.group(1))
                cuenta.append(0)
                continue
            if s.startswith("}"):
                pila.pop()
                cuenta.pop()
                continue
            m = re.match(r"^\{(.*)\}\s*,?$", s)
            if m:  # tabla en una línea dentro de una lista: { Color = ..., Manchas = ... }
                cuenta[-1] += 1
                for clave, h in re.findall(r"(\w+)\s*=\s*" + _HEX, m.group(1)):
                    colores[ruta(f"{cuenta[-1]}.{clave}")] = h
                continue
            m = re.match(r"^" + _HEX + r"\s*,?$", s)
            if m:  # elemento suelto de una lista
                cuenta[-1] += 1
                colores[ruta(cuenta[-1])] = m.group(1)
                continue
            m = re.match(r"^(\w+)\s*=\s*" + _HEX, s)
            if m:
                colores[ruta(m.group(1))] = m.group(2)
                continue
            m = re.match(r"^(\w+)\s*=\s*([A-Z_]+)\s*,$", s)
            if m:  # referencia a un local: Texto = TEXTO, Elementos = ELEMENTOS
                clave, local = m.groups()
                if local in locales:
                    colores[ruta(clave)] = locales[local]
                for k, h in list(colores.items()):
                    if k.startswith(local + "."):
                        colores[ruta(clave) + k[len(local) :]] = h
    return colores


PALETA = _leer_paleta()


def hex_de(clave):
    if clave not in PALETA:
        raise KeyError(f"El color '{clave}' no está en Paleta.luau")
    return PALETA[clave]


def color(clave):
    """Color lineal (RGBA) para Blender a partir de una clave de la paleta."""
    h = hex_de(clave)

    def lineal(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return tuple(lineal(int(h[i : i + 2], 16) / 255) for i in (0, 2, 4)) + (1.0,)


# ---------------------------------------------------------------------------
# Escena
# ---------------------------------------------------------------------------


def limpiar_escena():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    unidades = bpy.context.scene.unit_settings
    unidades.system = "METRIC"
    unidades.scale_length = 1.0


# ---------------------------------------------------------------------------
# Formas (todas agregan geometría a un bmesh; después `malla` lo convierte en objeto)
# ---------------------------------------------------------------------------


def suavizar_perfil(puntos, pasos=2):
    """Curva Catmull-Rom que pasa por los puntos: redondea las esquinas de un perfil."""
    if pasos <= 1 or len(puntos) < 3:
        return list(puntos)
    p = [Vector(puntos[0])] + [Vector(q) for q in puntos] + [Vector(puntos[-1])]
    salida = []
    for i in range(1, len(p) - 2):
        p0, p1, p2, p3 = p[i - 1], p[i], p[i + 1], p[i + 2]
        for k in range(pasos):
            t = k / pasos
            t2, t3 = t * t, t * t * t
            q = 0.5 * (
                2 * p1
                + (p2 - p0) * t
                + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
                + (3 * p1 - p0 - 3 * p2 + p3) * t3
            )
            salida.append((q.x, q.y))
    salida.append(tuple(puntos[-1]))
    return salida


def torno(bm, perfil, segmentos=16, matriz=None):
    """Sólido de revolución alrededor del eje Z. `perfil` es una lista de (radio, z) que
    empieza y termina sobre el eje (radio 0), así la malla queda cerrada."""
    matriz = matriz or Matrix.Identity(4)
    angulos = [2 * math.pi * j / segmentos for j in range(segmentos)]
    anillos = []
    for r, z in perfil:
        if r < 1e-6:
            anillos.append([bm.verts.new(matriz @ Vector((0, 0, z)))])
        else:
            anillos.append(
                [bm.verts.new(matriz @ Vector((r * math.cos(a), r * math.sin(a), z))) for a in angulos]
            )
    for a, b in zip(anillos, anillos[1:]):
        for j in range(segmentos):
            k = (j + 1) % segmentos
            if len(a) == 1 and len(b) == 1:
                break
            if len(a) == 1:
                bm.faces.new((a[0], b[k], b[j]))
            elif len(b) == 1:
                bm.faces.new((a[j], a[k], b[0]))
            else:
                bm.faces.new((a[j], a[k], b[k], b[j]))


def esfera(bm, centro, radios, segmentos=12, anillos=7, matriz=None):
    """Esfera o elipsoide (radios = (x, y, z) o un número)."""
    if not isinstance(radios, (tuple, list)):
        radios = (radios, radios, radios)
    perfil = [
        (math.sin(math.pi * i / anillos), -math.cos(math.pi * i / anillos)) for i in range(anillos + 1)
    ]
    escala = Matrix.Diagonal((*radios, 1.0))
    torno(bm, perfil, segmentos, (matriz or Matrix.Identity(4)) @ Matrix.Translation(centro) @ escala)


# Una metabola de radio r se ve como una esfera de r * 0.575 (umbral 0.6, rigidez 2).
_RADIO_VISIBLE = 0.575


def metabolas(bm, bolas, resolucion=0.04):
    """Formas blandas que se funden entre sí (slime, gotas, masa). `bolas` es una lista de
    (centro, radio visible). La malla resultante se agrega al bmesh."""
    datos = bpy.data.metaballs.new("Metabolas")
    datos.resolution = resolucion
    datos.render_resolution = resolucion
    for centro, radio in bolas:
        e = datos.elements.new(type="BALL")
        e.co = Vector(centro)
        e.radius = radio / _RADIO_VISIBLE
    obj = bpy.data.objects.new("Metabolas", datos)
    bpy.context.scene.collection.objects.link(obj)
    grafo = bpy.context.evaluated_depsgraph_get()
    grafo.update()
    me = bpy.data.meshes.new_from_object(obj.evaluated_get(grafo))
    bpy.data.objects.remove(obj)
    bpy.data.metaballs.remove(datos)
    bm.from_mesh(me)
    bpy.data.meshes.remove(me)


def malla(nombre, bm, clave_color, angulo_suave=60):
    """Convierte el bmesh en una malla con su color de la paleta, normales hacia afuera y
    sombreado suave."""
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)
    obj["color"] = clave_color
    suavizar(obj, angulo_suave)
    return obj


def suavizar(obj, angulo=60):
    obj.data.shade_smooth()
    obj.data.set_sharp_from_angle(angle=math.radians(angulo))


def aplicar_modificadores(obj):
    grafo = bpy.context.evaluated_depsgraph_get()
    grafo.update()
    nueva = bpy.data.meshes.new_from_object(obj.evaluated_get(grafo))
    vieja = obj.data
    obj.modifiers.clear()
    obj.data = nueva
    nombre = vieja.name
    bpy.data.meshes.remove(vieja)
    nueva.name = nombre


def biselar(obj, ancho=0.04, segmentos=3, angulo=30):
    """Bisel suave en los bordes marcados (para piezas con caras planas)."""
    mod = obj.modifiers.new("Bisel", "BEVEL")
    mod.width = ancho
    mod.segments = segmentos
    mod.limit_method = "ANGLE"
    mod.angle_limit = math.radians(angulo)
    aplicar_modificadores(obj)
    suavizar(obj)


def triangulos(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def diezmar(obj, maximo, angulo_suave=60):
    """Baja los triángulos de una malla hasta `maximo` (si se pasa)."""
    actuales = triangulos(obj)
    if actuales <= maximo:
        return
    mod = obj.modifiers.new("Diezmar", "DECIMATE")
    mod.ratio = maximo / actuales
    aplicar_modificadores(obj)
    suavizar(obj, angulo_suave)


# ---------------------------------------------------------------------------
# Materiales de vista previa (en Roblox el color lo pone el código)
# ---------------------------------------------------------------------------


def _entrada(nodo, nombre, valor):
    if nombre in nodo.inputs:
        nodo.inputs[nombre].default_value = valor


def _material(obj):
    clave = obj["color"]
    if obj.name.endswith("_Neon"):
        tipo = "Neon"
    elif obj.name.endswith("_Vidrio"):
        tipo = "Vidrio"
    else:
        tipo = "Normal"
    nombre = f"{tipo}_{clave}"
    mat = bpy.data.materials.get(nombre)
    if mat is None:
        mat = bpy.data.materials.new(nombre)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        c = color(clave)
        mat.diffuse_color = c
        _entrada(bsdf, "Base Color", c)
        _entrada(bsdf, "Roughness", 0.4)
        if tipo == "Neon":
            _entrada(bsdf, "Emission Color", c)
            _entrada(bsdf, "Emission Strength", 1.0)  # más fuerte se lava el color
        elif tipo == "Vidrio":
            # Como lo muestra Roblox: una pieza clara y semitransparente con brillo.
            _entrada(bsdf, "Alpha", 0.3)
            _entrada(bsdf, "Roughness", 0.08)
    obj.data.materials.clear()
    obj.data.materials.append(mat)


# ---------------------------------------------------------------------------
# Revisión (lista de aprobación, sección 12: lo que se puede medir)
# ---------------------------------------------------------------------------


def caja(objs):
    puntos = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
    minimo = Vector((min(p.x for p in puntos), min(p.y for p in puntos), min(p.z for p in puntos)))
    maximo = Vector((max(p.x for p in puntos), max(p.y for p in puntos), max(p.z for p in puntos)))
    return minimo, maximo


def revisar(nombre_objeto, objs, maximo_tris):
    problemas, lineas, total = [], [], 0
    for o in objs:
        if not NOMBRE_VALIDO.match(o.name) or not o.name.startswith(nombre_objeto + "_"):
            problemas.append(f"{o.name}: el nombre no sigue Objeto_Parte[_Sufijo]")
        if o.matrix_world != Matrix.Identity(4):
            problemas.append(f"{o.name}: tiene transformación (tiene que quedar en cero)")
        bm = bmesh.new()
        bm.from_mesh(o.data)
        abiertos = sum(1 for e in bm.edges if not e.is_manifold)
        bm.free()
        if abiertos:
            problemas.append(f"{o.name}: {abiertos} bordes abiertos (la malla no está cerrada)")
        t = triangulos(o)
        total += t
        lineas.append(f"  {o.name}: {t} triángulos, color {o['color']} (#{hex_de(o['color'])})")
    if total > maximo_tris:
        problemas.append(f"{total} triángulos en total: el límite es {maximo_tris}")
    minimo, maximo = caja(objs)
    tam = maximo - minimo
    if abs(minimo.z) > 0.01:
        problemas.append(f"la base está en z = {minimo.z:.3f}, tiene que estar en 0")
    centro = (minimo + maximo) / 2
    if abs(centro.x) > 0.3 or abs(centro.y) > 0.3:
        problemas.append(f"el objeto no está centrado (centro en x={centro.x:.2f}, y={centro.y:.2f})")
    lineas.insert(0, f"{nombre_objeto}: {total}/{maximo_tris} triángulos, tamaño {tam.x:.2f} x {tam.y:.2f} x {tam.z:.2f} studs (ancho x fondo x alto)")
    return problemas, lineas


# ---------------------------------------------------------------------------
# Exportación (configuración de la guía de Roblox para Blender)
# ---------------------------------------------------------------------------


def exportar(nombre, grupo, objs):
    carpeta = os.path.join(ARTE, "export", grupo)
    os.makedirs(carpeta, exist_ok=True)
    ruta = os.path.join(carpeta, nombre + ".fbx")
    for o in bpy.context.scene.objects:
        o.select_set(o in objs)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.export_scene.fbx(
        filepath=ruta,
        use_selection=True,
        object_types={"MESH"},
        global_scale=1.0,
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_UNITS",
        axis_forward="Z",
        axis_up="Y",
        bake_space_transform=True,
        use_mesh_modifiers=True,
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
        bake_anim=False,
    )
    return ruta


# ---------------------------------------------------------------------------
# Render de vista previa: misma cámara (tres cuartos) y misma luz para todos los objetos
# ---------------------------------------------------------------------------

AZIMUT = math.radians(32)  # cámara girada hacia la derecha del frente
ELEVACION = math.radians(22)


def _apuntar(obj, desde, hacia):
    obj.location = desde
    obj.rotation_euler = (hacia - desde).to_track_quat("-Z", "Y").to_euler()


def _luz(nombre, centro, distancia, azimut, elevacion, irradiancia, tam, rgb=(1, 1, 1)):
    datos = bpy.data.lights.new(nombre, "AREA")
    datos.size = tam
    datos.color = rgb
    datos.energy = irradiancia * math.pi * distancia**2
    obj = bpy.data.objects.new(nombre, datos)
    bpy.context.scene.collection.objects.link(obj)
    d = Vector((math.sin(azimut) * math.cos(elevacion), -math.cos(azimut) * math.cos(elevacion), math.sin(elevacion)))
    _apuntar(obj, centro + d * distancia, centro)
    return obj


def preparar_estudio(objs, tam=512, muestras=64):
    escena = bpy.context.scene
    escena.render.engine = "CYCLES"
    escena.cycles.device = "CPU"
    escena.cycles.samples = muestras
    escena.cycles.use_denoising = True
    escena.render.film_transparent = True
    try:
        escena.cycles.film_transparent_glass = True
    except AttributeError:
        pass
    escena.render.resolution_x = tam
    escena.render.resolution_y = tam
    escena.render.resolution_percentage = 100
    escena.render.image_settings.file_format = "PNG"
    escena.render.image_settings.color_mode = "RGBA"
    escena.view_settings.view_transform = "Standard"

    mundo = bpy.data.worlds.new("Noche")
    mundo.use_nodes = True
    fondo = mundo.node_tree.nodes["Background"]
    fondo.inputs["Color"].default_value = color("Noche")
    fondo.inputs["Strength"].default_value = 1.0
    escena.world = mundo

    minimo, maximo = caja(objs)
    centro = (minimo + maximo) / 2
    radio = max((maximo - minimo).length / 2, 0.25)
    lejos = radio * 5

    _luz("Principal", centro, lejos, math.radians(-40), math.radians(50), 2.2, radio * 2.5, (1.0, 0.97, 0.92))
    _luz("Relleno", centro, lejos, math.radians(70), math.radians(15), 0.6, radio * 3, (0.85, 0.9, 1.0))
    _luz("Contraluz", centro, lejos, math.radians(160), math.radians(40), 2.5, radio * 2, (0.9, 0.95, 1.0))

    # Piso invisible, chico, que solo recibe la sombra de apoyo (queda en el PNG transparente).
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=True, segments=32, radius=radio * 1.3)
    me = bpy.data.meshes.new("Piso")
    bm.to_mesh(me)
    bm.free()
    piso = bpy.data.objects.new("Piso", me)
    piso.location.z = minimo.z
    piso.is_shadow_catcher = True
    escena.collection.objects.link(piso)

    camara = bpy.data.cameras.new("Camara")
    camara.lens = 50
    camara.sensor_width = 36
    cam = bpy.data.objects.new("Camara", camara)
    escena.collection.objects.link(cam)
    distancia = radio / math.sin(camara.angle / 2) * 1.08
    d = Vector((math.sin(AZIMUT) * math.cos(ELEVACION), -math.cos(AZIMUT) * math.cos(ELEVACION), math.sin(ELEVACION)))
    _apuntar(cam, centro + d * distancia, centro)
    escena.camera = cam
    return piso


def render(ruta, tam=512, muestras=64):
    escena = bpy.context.scene
    escena.render.resolution_x = tam
    escena.render.resolution_y = tam
    escena.cycles.samples = muestras
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def silueta(ruta_render, ruta_silueta):
    """La silueta pintada de negro sobre blanco, para revisar que se reconozca de lejos."""
    import numpy as np

    img = bpy.data.images.load(ruta_render)
    px = np.array(img.pixels[:], dtype=np.float32).reshape(-1, 4)
    tapa = np.clip(px[:, 3] * 4, 0, 1)
    px[:, 0] = px[:, 1] = px[:, 2] = 1 - tapa
    px[:, 3] = 1
    img.pixels[:] = px.ravel()
    img.filepath_raw = ruta_silueta
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def sobre_fondo(ruta_render, ruta_vista, clave_fondo="Fondo"):
    """El render apoyado sobre el fondo del juego (azul petróleo), para revisar cómo se ve."""
    import numpy as np

    img = bpy.data.images.load(ruta_render)
    img.colorspace_settings.name = "Non-Color"  # los valores tal cual están en el PNG
    px = np.array(img.pixels[:], dtype=np.float32).reshape(-1, 4)
    h = hex_de(clave_fondo)
    fondo = np.array([int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)], dtype=np.float32)
    a = px[:, 3:4]
    px[:, :3] = px[:, :3] * a + fondo * (1 - a)
    px[:, 3] = 1
    img.pixels[:] = px.ravel()
    img.filepath_raw = ruta_vista
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


# ---------------------------------------------------------------------------
# Todo el camino para un objeto
# ---------------------------------------------------------------------------


def fabricar(nombre, grupo, construir, maximo_tris):
    """Arma el objeto con `construir()` (devuelve sus mallas), lo revisa, lo exporta a
    export/<grupo>/<nombre>.fbx y saca el render y la silueta en renders/<grupo>/."""
    limpiar_escena()
    objs = construir()
    for o in objs:
        _material(o)

    problemas, lineas = revisar(nombre, objs, maximo_tris)
    ruta_fbx = exportar(nombre, grupo, objs)

    carpeta = os.path.join(ARTE, "renders", grupo)
    os.makedirs(carpeta, exist_ok=True)
    ruta_png = os.path.join(carpeta, nombre + ".png")
    piso = preparar_estudio(objs)
    render(ruta_png)
    sobre_fondo(ruta_png, os.path.join(carpeta, nombre + "_vista.png"))
    # Silueta chica, como se vería en un celular a unos 20 studs.
    piso.hide_render = True
    ruta_tmp = os.path.join(carpeta, nombre + "_tmp.png")
    render(ruta_tmp, tam=128, muestras=4)
    silueta(ruta_tmp, os.path.join(carpeta, nombre + "_silueta.png"))
    os.remove(ruta_tmp)
    piso.hide_render = False

    carpeta_blend = os.path.join(ARTE, "blend", grupo)
    os.makedirs(carpeta_blend, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(carpeta_blend, nombre + ".blend"))

    print("=== REVISIÓN ===")
    for linea in lineas:
        print(linea)
    print(f"  FBX: {ruta_fbx}")
    print(f"  Render: {ruta_png}")
    if problemas:
        print("PROBLEMAS:")
        for p in problemas:
            print("  - " + p)
    else:
        print("Sin problemas.")
