"""Herramientas comunes para fabricar el arte de Mutant Lab en Blender.

Cada grupo de objetos tiene su script en objetos/ y se corre con Blender en segundo plano:
    blender -b --factory-startup --python-exit-code 1 -P mutant-lab/arte/scripts/objetos/<grupo>.py

Un script de grupo se ve así:
    G = C.Grupo("Plaza")

    @G.objeto("Farol", 3000)
    def farol():
        bm = bmesh.new()
        C.cilindro(bm, 0.3, 8)
        return [G.malla("Poste", bm, "Metal", bisel=0.05)]

    G.terminar()

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
IDENTIDAD = Matrix.Identity(4)

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
    if clave.startswith("#"):  # color suelto (solo vista previa: en Roblox lo pinta el código)
        return clave[1:]
    if clave not in PALETA:
        raise KeyError(f"El color '{clave}' no está en Paleta.luau")
    return PALETA[clave]


def color(clave):
    """Color lineal (RGBA) para Blender a partir de una clave de la paleta (o "#RRGGBB")."""
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
# Formas (todas agregan geometría a un bmesh; después `malla` lo convierte en objeto).
# `matriz` mueve/gira/escala la forma: Matrix.Translation, Matrix.Rotation, etc.
# ---------------------------------------------------------------------------


def mover(x=0.0, y=0.0, z=0.0):
    return Matrix.Translation((x, y, z))


def girar(grados, eje="Z"):
    return Matrix.Rotation(math.radians(grados), 4, eje)


def escalar(x, y=None, z=None):
    return Matrix.Diagonal((x, x if y is None else y, x if z is None else z, 1.0))


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


def anillo_plano(bm, radio_adentro, radio_afuera, z0, z1, segmentos=32, matriz=None, desde=0.0, hasta=360.0):
    """Anillo (o gajo de anillo) macizo entre dos radios y dos alturas: pisos en módulos."""
    perfil = [(radio_adentro, z0), (radio_afuera, z0), (radio_afuera, z1), (radio_adentro, z1)]
    torno(bm, perfil, segmentos, matriz, desde, hasta, cerrado=True)


def torno(bm, perfil, segmentos=16, matriz=None, desde=0.0, hasta=360.0, cerrado=False):
    """Sólido de revolución alrededor del eje Z. `perfil` es una lista de (radio, z) que
    empieza y termina sobre el eje (radio 0), así la malla queda cerrada.
    Con `cerrado` el perfil es un contorno cerrado que no toca el eje (aros, anillos).
    Con `desde`/`hasta` se hace solo un gajo (y se tapan los dos cortes)."""
    matriz = matriz or IDENTIDAD
    completo = abs((hasta - desde) - 360.0) < 1e-6
    n = segmentos if completo else segmentos + 1
    angulos = [math.radians(desde + (hasta - desde) * j / segmentos) for j in range(n)]
    anillos = []
    for r, z in perfil:
        if r < 1e-6:
            anillos.append([bm.verts.new(matriz @ Vector((0, 0, z)))])
        else:
            anillos.append([bm.verts.new(matriz @ Vector((r * math.cos(a), r * math.sin(a), z))) for a in angulos])
    pares = list(zip(anillos, anillos[1:]))
    if cerrado:
        pares.append((anillos[-1], anillos[0]))
    for a, b in pares:
        for j in range(segmentos):
            k = (j + 1) % n
            if len(a) == 1 and len(b) == 1:
                break
            if len(a) == 1:
                bm.faces.new((a[0], b[k], b[j]))
            elif len(b) == 1:
                bm.faces.new((a[j], a[k], b[0]))
            else:
                bm.faces.new((a[j], a[k], b[k], b[j]))
    if not completo:  # tapas de los cortes
        for j in (0, n - 1):
            borde = []
            for anillo in anillos:
                v = anillo[0] if len(anillo) == 1 else anillo[j]
                if not borde or borde[-1] is not v:
                    borde.append(v)
            if len(borde) >= 3:
                bm.faces.new(borde)


def esfera(bm, centro, radios, segmentos=12, anillos=7, matriz=None):
    """Esfera o elipsoide (radios = (x, y, z) o un número)."""
    if not isinstance(radios, (tuple, list)):
        radios = (radios, radios, radios)
    perfil = [(math.sin(math.pi * i / anillos), -math.cos(math.pi * i / anillos)) for i in range(anillos + 1)]
    escala = Matrix.Diagonal((*radios, 1.0))
    torno(bm, perfil, segmentos, (matriz or IDENTIDAD) @ Matrix.Translation(centro) @ escala)


def cilindro(bm, radio, alto, segmentos=16, matriz=None, radio_arriba=None, redondeo=0.0):
    """Cilindro (o cono si `radio_arriba` es distinto) parado sobre z = 0. `redondeo` le
    redondea los bordes de arriba y de abajo."""
    r2 = radio if radio_arriba is None else radio_arriba
    if redondeo > 0:
        d = min(redondeo, alto / 2, radio, r2)
        perfil = [
            (0, 0),
            (radio - d, 0),
            (radio - d * 0.3, d * 0.3),
            (radio, d),
            (r2, alto - d),
            (r2 - d * 0.3, alto - d * 0.3),
            (r2 - d, alto),
            (0, alto),
        ]
    else:
        perfil = [(0, 0), (radio, 0), (r2, alto), (0, alto)]
    torno(bm, perfil, segmentos, matriz)


def caja(bm, centro, tam, matriz=None):
    """Caja de tamaño `tam` (x, y, z) centrada en `centro`. Para bordes redondos, usar
    `bisel` al hacer la malla."""
    hecho = bmesh.ops.create_cube(bm, size=1.0)
    m = (matriz or IDENTIDAD) @ Matrix.Translation(centro) @ Matrix.Diagonal((*tam, 1.0))
    bmesh.ops.transform(bm, matrix=m, verts=hecho["verts"])


def marco(bm, ancho, alto, borde, profundo, matriz=None):
    """Marco rectangular de una pieza (para pantallas y carteles), parado en el plano XZ,
    centrado en el origen y mirando a -Y. `ancho` y `alto` son los del hueco de adentro."""
    matriz = matriz or IDENTIDAD
    ax, az = ancho / 2, alto / 2
    bx, bz = ax + borde, az + borde
    afuera = [(-bx, -bz), (bx, -bz), (bx, bz), (-bx, bz)]
    adentro = [(-ax, -az), (ax, -az), (ax, az), (-ax, az)]

    def vs(puntos, y):
        return [bm.verts.new(matriz @ Vector((x, y, z))) for x, z in puntos]

    of, ob = vs(afuera, -profundo / 2), vs(afuera, profundo / 2)
    inf, inb = vs(adentro, -profundo / 2), vs(adentro, profundo / 2)
    for i in range(4):
        j = (i + 1) % 4
        bm.faces.new((of[i], of[j], inf[j], inf[i]))  # frente
        bm.faces.new((ob[j], ob[i], inb[i], inb[j]))  # atrás
        bm.faces.new((of[j], of[i], ob[i], ob[j]))  # costado de afuera
        bm.faces.new((inf[i], inf[j], inb[j], inb[i]))  # costado del hueco


def abollar(bm, cantidad, escala=1.0, semilla=0, centro=(0, 0, 0)):
    """Deforma toda la geometría con un ruido suave (rocas, troncos, tierra): cada vértice se
    mueve hacia afuera o adentro desde `centro`."""
    from mathutils import noise

    c = Vector(centro)
    desfase = Vector((semilla * 13.7, semilla * 7.3, semilla * 3.1))
    for v in bm.verts:
        d = v.co - c
        if d.length < 1e-6:
            continue
        n = noise.noise(v.co * escala + desfase)
        v.co = v.co + d.normalized() * (n * cantidad)


def asentar(objs):
    """Baja o sube todas las mallas juntas para que la base quede justo en z = 0."""
    minimo, _ = caja_de(objs)
    for o in objs:
        o.data.transform(Matrix.Translation((0, 0, -minimo.z)))
        o.data.update()


def colgar(objs):
    """Mueve todas las mallas juntas para que lo más alto quede justo en z = 0 (cuelgue)."""
    _, maximo = caja_de(objs)
    for o in objs:
        o.data.transform(Matrix.Translation((0, 0, -maximo.z)))
        o.data.update()


def toro(bm, radio, grosor, segmentos=24, lados=8, matriz=None, desde=0.0, hasta=360.0):
    """Aro (rosquilla) acostado en el plano XY, centrado en el origen."""
    matriz = matriz or IDENTIDAD
    completo = abs((hasta - desde) - 360.0) < 1e-6
    n = segmentos if completo else segmentos + 1
    anillos = []
    for j in range(n):
        a = math.radians(desde + (hasta - desde) * j / segmentos)
        anillo = []
        for k in range(lados):
            b = 2 * math.pi * k / lados
            r = radio + grosor * math.cos(b)
            anillo.append(bm.verts.new(matriz @ Vector((r * math.cos(a), r * math.sin(a), grosor * math.sin(b)))))
        anillos.append(anillo)
    for j in range(segmentos):
        a, b = anillos[j], anillos[(j + 1) % n]
        for k in range(lados):
            q = (k + 1) % lados
            bm.faces.new((a[k], a[q], b[q], b[k]))
    if not completo:
        bm.faces.new(list(reversed(anillos[0])))
        bm.faces.new(anillos[-1])


def tubo(bm, camino, radio, lados=8, matriz=None, tapas=True):
    """Tubo que sigue un camino de puntos. `radio` es un número o una lista (uno por punto),
    así se puede afinar (ramas, lianas, chorros)."""
    matriz = matriz or IDENTIDAD
    pts = [Vector(p) for p in camino]
    radios = radio if isinstance(radio, (list, tuple)) else [radio] * len(pts)
    # Marco que se transporta a lo largo del camino (sin giros bruscos).
    tangentes = []
    for i in range(len(pts)):
        t = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
        tangentes.append(t)
    normal = tangentes[0].orthogonal().normalized()
    anillos = []
    for i, p in enumerate(pts):
        t = tangentes[i]
        normal = (normal - t * normal.dot(t)).normalized()
        binormal = t.cross(normal)
        anillo = []
        for k in range(lados):
            a = 2 * math.pi * k / lados
            d = normal * math.cos(a) + binormal * math.sin(a)
            anillo.append(bm.verts.new(matriz @ (p + d * radios[i])))
        anillos.append(anillo)
    for a, b in zip(anillos, anillos[1:]):
        for k in range(lados):
            q = (k + 1) % lados
            bm.faces.new((a[k], a[q], b[q], b[k]))
    if tapas:
        bm.faces.new(list(reversed(anillos[0])))
        bm.faces.new(anillos[-1])


def extruir(bm, puntos, alto, matriz=None, z=0.0):
    """Figura plana (lista de (x, y) en orden antihorario) con espesor `alto` hacia +Z."""
    matriz = matriz or IDENTIDAD
    abajo = [bm.verts.new(matriz @ Vector((x, y, z))) for x, y in puntos]
    arriba = [bm.verts.new(matriz @ Vector((x, y, z + alto))) for x, y in puntos]
    n = len(puntos)
    bm.faces.new(list(reversed(abajo)))
    bm.faces.new(arriba)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((abajo[i], abajo[j], arriba[j], arriba[i]))


def circulo(radio, lados=16, cx=0.0, cy=0.0, desde=0.0, hasta=360.0):
    """Puntos de un círculo (o arco) para `extruir`."""
    completo = abs((hasta - desde) - 360.0) < 1e-6
    n = lados if completo else lados + 1
    return [
        (cx + radio * math.cos(math.radians(desde + (hasta - desde) * i / lados)),
         cy + radio * math.sin(math.radians(desde + (hasta - desde) * i / lados)))
        for i in range(n)
    ]


def estrella(radio, puntas=5, adentro=0.45, cx=0.0, cy=0.0, giro=90.0):
    pts = []
    for i in range(puntas * 2):
        r = radio if i % 2 == 0 else radio * adentro
        a = math.radians(giro + 180.0 * i / puntas)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


# Una metabola de radio r se ve como una esfera de r * 0.575 (umbral 0.6, rigidez 2).
_RADIO_VISIBLE = 0.575


def metabolas(bm, bolas, resolucion=0.04):
    """Formas blandas que se funden entre sí (slime, gotas, masa, copas de árbol). `bolas` es
    una lista de (centro, radio visible). La malla resultante se agrega al bmesh."""
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


# ---------------------------------------------------------------------------
# Mallas
# ---------------------------------------------------------------------------


def malla(nombre, bm, clave_color, angulo_suave=60, bisel=0.0, segmentos_bisel=2, angulo_bisel=35):
    """Convierte el bmesh en una malla con su color de la paleta, normales hacia afuera,
    bisel suave en los bordes filosos (si `bisel` > 0) y sombreado suave."""
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)
    obj["color"] = clave_color
    if bisel > 0:
        mod = obj.modifiers.new("Bisel", "BEVEL")
        mod.width = bisel
        mod.segments = segmentos_bisel
        mod.limit_method = "ANGLE"
        mod.angle_limit = math.radians(angulo_bisel)
        aplicar_modificadores(obj)
    _triangular_poligonos(obj)
    suavizar(obj, angulo_suave)
    return obj


def _triangular_poligonos(obj):
    """Las caras de más de 4 lados se pasan a triángulos acá, así Roblox no las arma raro."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    grandes = [f for f in bm.faces if len(f.verts) > 4]
    if grandes:
        bmesh.ops.triangulate(bm, faces=grandes, quad_method="BEAUTY", ngon_method="EAR_CLIP")
        bm.to_mesh(obj.data)
    bm.free()


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
# Materiales de vista previa (en Roblox el color lo pone el código o el MCP)
# ---------------------------------------------------------------------------


def _entrada(nodo, nombre, valor):
    if nombre in nodo.inputs:
        nodo.inputs[nombre].default_value = valor


def _material(obj):
    clave = obj["color"]
    partes = obj.name.split("_")[1:]
    if "Neon" in partes:
        tipo = "Neon"
    elif "Vidrio" in partes:
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
            _entrada(bsdf, "Alpha", 0.45)
            _entrada(bsdf, "Roughness", 0.08)
    obj.data.materials.clear()
    obj.data.materials.append(mat)


# ---------------------------------------------------------------------------
# Revisión (lista de aprobación, sección 12: lo que se puede medir)
# ---------------------------------------------------------------------------


def caja_de(objs):
    puntos = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
    minimo = Vector((min(p.x for p in puntos), min(p.y for p in puntos), min(p.z for p in puntos)))
    maximo = Vector((max(p.x for p in puntos), max(p.y for p in puntos), max(p.z for p in puntos)))
    return minimo, maximo


def revisar(nombre_objeto, objs, maximo_tris, apoyo="base"):
    """`apoyo`: "base" (apoyado en el piso), "cuelga" (el origen arriba) o "libre" (piezas de
    criatura y módulos: el origen lo decide el script)."""
    problemas, lineas, total = [], [], 0
    for o in objs:
        if not NOMBRE_VALIDO.match(o.name) or not o.name.startswith(nombre_objeto + "_"):
            problemas.append(f"{o.name}: el nombre no sigue Objeto_Parte[_Sufijo]")
        if o.matrix_world != IDENTIDAD:
            problemas.append(f"{o.name}: tiene transformación (tiene que quedar en cero)")
        bm = bmesh.new()
        bm.from_mesh(o.data)
        abiertos = sum(1 for e in bm.edges if not e.is_manifold)
        bm.free()
        if abiertos:
            problemas.append(f"{o.name}: {abiertos} bordes abiertos (la malla no está cerrada)")
        t = triangulos(o)
        total += t
        if t > 20000:
            problemas.append(f"{o.name}: {t} triángulos (Roblox acepta hasta 20.000 por malla)")
        lineas.append(f"    {o.name}: {t} tri, {o['color']}")
    if total > maximo_tris:
        problemas.append(f"{total} triángulos en total: el límite es {maximo_tris}")
    minimo, maximo = caja_de(objs)
    tam = maximo - minimo
    if apoyo == "base":
        if abs(minimo.z) > 0.02:
            problemas.append(f"la base está en z = {minimo.z:.3f}, tiene que estar en 0")
        centro = (minimo + maximo) / 2
        if abs(centro.x) > max(0.3, tam.x * 0.2) or abs(centro.y) > max(0.3, tam.y * 0.2):
            problemas.append(f"el objeto no está centrado (centro en x={centro.x:.2f}, y={centro.y:.2f})")
    elif apoyo == "cuelga" and abs(maximo.z) > 0.02:
        problemas.append(f"el punto de cuelgue está en z = {maximo.z:.3f}, tiene que estar en 0")
    lineas.insert(0, f"{nombre_objeto}: {total}/{maximo_tris} tri, {tam.x:.2f} x {tam.y:.2f} x {tam.z:.2f} studs")
    return problemas, lineas, total


# ---------------------------------------------------------------------------
# Exportación (configuración de la guía de Roblox para Blender)
# ---------------------------------------------------------------------------


def exportar(ruta, objs):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
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


def _direccion(azimut, elevacion):
    return Vector(
        (math.sin(azimut) * math.cos(elevacion), -math.cos(azimut) * math.cos(elevacion), math.sin(elevacion))
    )


def _luz(nombre, centro, distancia, azimut, elevacion, irradiancia, tam, rgb=(1, 1, 1)):
    datos = bpy.data.lights.new(nombre, "AREA")
    datos.size = tam
    datos.color = rgb
    datos.energy = irradiancia * math.pi * distancia**2
    obj = bpy.data.objects.new(nombre, datos)
    bpy.context.scene.collection.objects.link(obj)
    _apuntar(obj, centro + _direccion(azimut, elevacion) * distancia, centro)
    return obj


def configurar_render(tam=512, muestras=48):
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
    if escena.world is None:
        mundo = bpy.data.worlds.new("Noche")
        mundo.use_nodes = True
        fondo = mundo.node_tree.nodes["Background"]
        fondo.inputs["Color"].default_value = color("Noche")
        fondo.inputs["Strength"].default_value = 1.0
        escena.world = mundo


def preparar_estudio(objs, azimut=AZIMUT, elevacion=ELEVACION, piso=True):
    """Luces, cámara y piso de sombra para encuadrar `objs`. Devuelve lo creado (para borrarlo)."""
    configurar_render()
    escena = bpy.context.scene
    minimo, maximo = caja_de(objs)
    centro = (minimo + maximo) / 2
    radio = max((maximo - minimo).length / 2, 0.25)
    lejos = radio * 5
    creado = [
        _luz("Principal", centro, lejos, math.radians(-40), math.radians(50), 2.2, radio * 2.5, (1.0, 0.97, 0.92)),
        _luz("Relleno", centro, lejos, math.radians(70), math.radians(15), 0.6, radio * 3, (0.85, 0.9, 1.0)),
        _luz("Contraluz", centro, lejos, math.radians(160), math.radians(40), 2.5, radio * 2, (0.9, 0.95, 1.0)),
    ]
    if piso:
        # Piso invisible, chico, que solo recibe la sombra de apoyo (queda en el PNG transparente).
        bm = bmesh.new()
        bmesh.ops.create_circle(bm, cap_ends=True, segments=32, radius=radio * 1.3)
        me = bpy.data.meshes.new("Piso")
        bm.to_mesh(me)
        bm.free()
        p = bpy.data.objects.new("Piso", me)
        p.location = (centro.x, centro.y, minimo.z)
        p.is_shadow_catcher = True
        escena.collection.objects.link(p)
        creado.append(p)
    camara = bpy.data.cameras.new("Camara")
    camara.lens = 50
    camara.sensor_width = 36
    cam = bpy.data.objects.new("Camara", camara)
    escena.collection.objects.link(cam)
    distancia = radio / math.sin(camara.angle / 2) * 1.08
    camara.clip_end = distancia + radio * 4
    _apuntar(cam, centro + _direccion(azimut, elevacion) * distancia, centro)
    escena.camera = cam
    creado.append(cam)
    return creado


def borrar(objetos):
    for o in objetos:
        datos = o.data
        bpy.data.objects.remove(o)
        if datos is not None and datos.users == 0:
            if isinstance(datos, bpy.types.Mesh):
                bpy.data.meshes.remove(datos)
            elif isinstance(datos, bpy.types.Light):
                bpy.data.lights.remove(datos)
            elif isinstance(datos, bpy.types.Camera):
                bpy.data.cameras.remove(datos)


def render(ruta, tam=512, muestras=48):
    escena = bpy.context.scene
    escena.render.resolution_x = tam
    escena.render.resolution_y = tam
    escena.cycles.samples = muestras
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def _pixeles(ruta):
    import numpy as np

    img = bpy.data.images.load(ruta)
    img.colorspace_settings.name = "Non-Color"  # los valores tal cual están en el PNG
    ancho, alto = img.size
    px = np.array(img.pixels[:], dtype=np.float32).reshape(alto, ancho, 4)
    bpy.data.images.remove(img)
    return px


def _guardar(px, ruta):
    alto, ancho = px.shape[:2]
    img = bpy.data.images.new("Temporal", ancho, alto, alpha=True)
    img.colorspace_settings.name = "Non-Color"
    img.pixels[:] = px.ravel()
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def silueta(ruta_render, ruta_silueta):
    """La silueta pintada de negro sobre blanco, para revisar que se reconozca de lejos."""
    import numpy as np

    px = _pixeles(ruta_render)
    tapa = np.clip(px[..., 3] * 4, 0, 1)
    px[..., 0] = px[..., 1] = px[..., 2] = 1 - tapa
    px[..., 3] = 1
    _guardar(px, ruta_silueta)


def sobre_fondo(ruta_render, ruta_vista, clave_fondo="Fondo"):
    """El render apoyado sobre el fondo del juego (azul petróleo), para revisar cómo se ve."""
    import numpy as np

    px = _pixeles(ruta_render)
    h = hex_de(clave_fondo)
    fondo = np.array([int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)], dtype=np.float32)
    a = px[..., 3:4]
    px[..., :3] = px[..., :3] * a + fondo * (1 - a)
    px[..., 3] = 1
    _guardar(px, ruta_vista)


def hoja(rutas, ruta_hoja, columnas=6, celda=256):
    """Junta varias imágenes en una hoja (para revisar un grupo entero de un vistazo)."""
    import numpy as np

    filas = (len(rutas) + columnas - 1) // columnas
    lienzo = np.zeros((filas * celda, columnas * celda, 4), dtype=np.float32)
    lienzo[..., 3] = 1
    for i, ruta in enumerate(rutas):
        px = _pixeles(ruta)
        paso = max(1, px.shape[0] // celda)
        chico = px[::paso, ::paso][:celda, :celda]
        f, c = divmod(i, columnas)
        # Las filas de Blender van de abajo hacia arriba: la primera imagen queda arriba a la izquierda.
        y0 = (filas - 1 - f) * celda
        lienzo[y0 : y0 + chico.shape[0], c * celda : c * celda + chico.shape[1]] = chico
    _guardar(lienzo, ruta_hoja)


def escribir_colores_luau():
    """Junta los colores.json de todos los grupos en shared/ArteColores.luau, que usa
    shared/Arte.luau para pintar cada malla en Roblox (Rojo lo sincroniza a Studio)."""
    import json

    filas = []
    carpeta_export = os.path.join(ARTE, "export")
    for grupo in sorted(os.listdir(carpeta_export)):
        ruta = os.path.join(carpeta_export, grupo, "colores.json")
        if not os.path.isfile(ruta):
            continue
        with open(ruta, encoding="utf-8") as f:
            datos = json.load(f)
        filas.append(f"\t-- {grupo}")
        for nombre in sorted(datos):
            d = datos[nombre]
            filas.append(f'\t{nombre} = {{ Color = "{d["Color"].upper()}", Clave = "{d["Clave"]}", Tipo = "{d["Tipo"]}" }},')
    texto = (
        "--!strict\n"
        "-- Generado por mutant-lab/arte/scripts/comun.py: no editar a mano (se pisa en cada corrida).\n"
        "-- Color y tipo de cada malla del arte de Blender. Clave es la de Paleta.luau (o \"#hex\").\n\n"
        "export type Dato = { Color: string, Clave: string, Tipo: string }\n\n"
        "local Colores: { [string]: Dato } = {\n" + "\n".join(filas) + "\n}\n\nreturn Colores\n"
    )
    ruta_luau = os.path.join(os.path.dirname(ARTE), "src", "shared", "ArteColores.luau")
    with open(ruta_luau, "w", encoding="utf-8", newline="\n") as f:
        f.write(texto)


# ---------------------------------------------------------------------------
# Grupo: fabrica varios objetos en una sola corrida de Blender
# ---------------------------------------------------------------------------


class Grupo:
    """Un grupo de objetos (Plaza, Jardin, Criaturas...). Cada objeto se exporta solo
    (export/<grupo>/<Objeto>.fbx) y además todos juntos en un paquete
    (export/<grupo>/_Paquete<grupo>.fbx), que se importa a Studio de una sola vez."""

    def __init__(self, nombre, renders=True):
        limpiar_escena()
        self.nombre = nombre
        self.renders = renders
        self.actual = None
        self.objetos = []  # (nombre, mallas, opciones de render)
        self.problemas = []
        self.lineas = []

    def malla(self, parte, bm, clave_color, **opciones):
        return malla(f"{self.actual}_{parte}", bm, clave_color, **opciones)

    def objeto(self, nombre, maximo_tris, apoyo="base", azimut=AZIMUT, elevacion=ELEVACION):
        def registrar(construir):
            self.actual = nombre
            objs = construir()
            self.actual = None
            # Lo que sobresale un poco (raíces, abolladuras) no puede hundir el objeto en el piso.
            if apoyo == "base":
                asentar(objs)
            elif apoyo == "cuelga":
                colgar(objs)
            coleccion = bpy.data.collections.new(nombre)
            bpy.context.scene.collection.children.link(coleccion)
            for o in objs:
                for c in o.users_collection:
                    c.objects.unlink(o)
                coleccion.objects.link(o)
                _material(o)
            problemas, lineas, _ = revisar(nombre, objs, maximo_tris, apoyo)
            self.problemas += [f"{nombre}: {p}" for p in problemas]
            self.lineas += lineas
            exportar(os.path.join(ARTE, "export", self.nombre, nombre + ".fbx"), objs)
            self.objetos.append((nombre, objs, (azimut, elevacion, apoyo != "cuelga")))
            print(f"  hecho: {nombre}", flush=True)
            return construir

        return registrar

    def terminar(self):
        import json

        todos = [o for _, objs, _ in self.objetos for o in objs]
        exportar(os.path.join(ARTE, "export", self.nombre, f"_Paquete{self.nombre}.fbx"), todos)
        # Color de cada malla, para pintarlas en Studio después de importar (el FBX no lo lleva).
        colores = {}
        for o in todos:
            partes = o.name.split("_")[1:]
            tipo = "Neon" if "Neon" in partes else "Vidrio" if "Vidrio" in partes else "Normal"
            colores[o.name] = {"Color": hex_de(o["color"]), "Clave": o["color"], "Tipo": tipo}
        with open(os.path.join(ARTE, "export", self.nombre, "colores.json"), "w", encoding="utf-8") as f:
            json.dump(colores, f, ensure_ascii=False, indent=1, sort_keys=True)
        escribir_colores_luau()
        carpeta = os.path.join(ARTE, "renders", self.nombre)
        os.makedirs(carpeta, exist_ok=True)
        vistas = []
        if self.renders:
            for nombre, objs, (azimut, elevacion, piso) in self.objetos:
                for c in bpy.data.collections:
                    c.hide_render = c.name != nombre
                estudio = preparar_estudio(objs, azimut, elevacion, piso)
                ruta_png = os.path.join(carpeta, nombre + ".png")
                render(ruta_png)
                ruta_vista = os.path.join(carpeta, nombre + "_vista.png")
                sobre_fondo(ruta_png, ruta_vista)
                vistas.append(ruta_vista)
                piso_obj = [o for o in estudio if o.name.startswith("Piso")]
                for p in piso_obj:
                    p.hide_render = True
                ruta_tmp = os.path.join(carpeta, nombre + "_tmp.png")
                render(ruta_tmp, tam=128, muestras=4)
                silueta(ruta_tmp, os.path.join(carpeta, nombre + "_silueta.png"))
                os.remove(ruta_tmp)
                borrar(estudio)
                print(f"  render: {nombre}", flush=True)
            for c in bpy.data.collections:
                c.hide_render = False
            hoja(vistas, os.path.join(carpeta, "_hoja.png"))

        carpeta_blend = os.path.join(ARTE, "blend")
        os.makedirs(carpeta_blend, exist_ok=True)
        bpy.ops.wm.save_as_mainfile(filepath=os.path.join(carpeta_blend, self.nombre + ".blend"))

        print("=== REVISIÓN ===")
        print("Orden en la hoja: " + ", ".join(n for n, _, _ in self.objetos))
        for linea in self.lineas:
            print(linea)
        if self.problemas:
            print("PROBLEMAS:")
            for p in self.problemas:
                print("  - " + p)
        else:
            print("Sin problemas.")
