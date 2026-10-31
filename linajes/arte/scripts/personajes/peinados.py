"""Peinados del cuerpo propio, versión 2 (pedido de Juani, 31 oct): el cuerpo es el de Roblox
(las piezas del maniquí R15), así que el pelo se apoya sobre su cabeza. Más complejo que la v1:
mechones curvos en capas, con puntas, que se despegan del cráneo y caen con la gravedad.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/personajes/peinados.py

Deja los 12 peinados en arte/blender/peinados.blend, el render renders/cuerpo_peinados_v2.png
y el FBX exports/cuerpo/Peinados.fbx con la cabeza clásica ("Head_Clasica", con la UV de la cara)
y los 12 peinados hechos sobre ella.
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bmesh  # noqa: E402
import bpy  # noqa: E402
import cuerpo as C  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Vector  # noqa: E402

BLEND = os.path.join(B.BLENDER, "peinados.blend")
SEPARACION = 0.010  # el pelo nunca se acerca a menos de esto del cráneo


MEDIA = Vector((0.172, 0.172, 0.172))  # caja redondeada que envuelve la cabeza de Roblox (con bisel)
POTENCIA = 6.0  # más alto = más cuadrada


CABEZA_R, CABEZA_H, CABEZA_E = 0.168, 0.170, 0.45  # radio, media altura, redondez de arriba y abajo


def cabeza_clasica(centro):
    """Cabeza con la forma clásica de Roblox: cilindro con arriba y abajo redondeados. La cara
    va con proyección de frente (cuerpo.uv_cabeza), así el decal de la cara se ve derecho."""
    bm = bmesh.new()
    lados, anillos = 32, 18
    filas = []
    for j in range(anillos + 1):
        fi = -math.pi / 2 + math.pi * j / anillos
        c, s_ = math.cos(fi), math.sin(fi)
        h = abs(c) ** CABEZA_E
        v = math.copysign(abs(s_) ** CABEZA_E, s_)
        if j in (0, anillos):
            filas.append([bm.verts.new(centro + Vector((0, 0, v * CABEZA_H)))])
            continue
        filas.append([bm.verts.new(centro + Vector((math.sin(2 * math.pi * i / lados) * h * CABEZA_R, -math.cos(2 * math.pi * i / lados) * h * CABEZA_R, v * CABEZA_H))) for i in range(lados)])
    for a, b in zip(filas, filas[1:]):
        if len(a) == 1:
            for i in range(lados):
                bm.faces.new((a[0], b[(i + 1) % lados], b[i]))
        elif len(b) == 1:
            for i in range(lados):
                bm.faces.new((a[i], a[(i + 1) % lados], b[0]))
        else:
            for i in range(lados):
                bm.faces.new((a[i], a[(i + 1) % lados], b[(i + 1) % lados], b[i]))
    obj = T.malla("Head_Clasica", bm, "piel", "Head", suave=80)
    return obj


def radio_caja(d):
    """Distancia del centro a la superficie de la cabeza clásica en la dirección `d` (más un
    margen para que las caras planas de la malla no corten la curva)."""
    hit = C.CRANEO.ray_cast(C.CENTRO + d * 0.6, -d)[0]
    return (hit - C.CENTRO).length + 0.003 if hit else 0.17


def _empujar(p):
    """Si el punto quedó adentro o pegado a la cabeza, lo saca hacia afuera."""
    v = p - C.CENTRO
    d = v.normalized()
    minimo = radio_caja(d) + SEPARACION
    return C.CENTRO + d * minimo if v.length < minimo else p


def mechon(bm, th, fi, largo, ancho, caida, segs=4, curva=0.5, grosor=0.35, abre=0.3, giro=0.0):
    """Mechón curvo: sale del cráneo en (th, fi), va hacia `caida` y se dobla con la gravedad
    (`curva`). Sección de rombo que se afina hasta la punta."""
    raiz, d = C._sobre_craneo(th, fi, 0.002)
    paso = largo / segs
    rumbo = (d * abre + Vector(caida)).normalized()
    puntos = [raiz]
    p = raiz
    for _ in range(segs):
        rumbo = (rumbo + Vector((0, 0, -curva * 0.35))).normalized()
        p = _empujar(p + rumbo * paso)
        puntos.append(p)
    anillos = []
    for i, c in enumerate(puntos[:-1]):
        t = (puntos[i + 1] - c).normalized()
        radial = (c - C.CENTRO).normalized()
        lado = t.cross(radial)
        lado = lado.normalized() if lado.length > 1e-4 else Vector((1, 0, 0))
        afuera = lado.cross(t).normalized()
        if afuera.dot(radial) < 0:
            afuera = -afuera
        a = math.radians(giro)
        lado, afuera = lado * math.cos(a) + afuera * math.sin(a), afuera * math.cos(a) - lado * math.sin(a)
        w = ancho * (1 - i / segs) ** 0.7
        h = w * grosor
        anillos.append([bm.verts.new(c + v) for v in (-lado * w / 2, -afuera * h / 2, lado * w / 2, afuera * h / 2)])
    for a, b in zip(anillos, anillos[1:]):
        for i in range(4):
            bm.faces.new((a[i], a[(i + 1) % 4], b[(i + 1) % 4], b[i]))
    punta = bm.verts.new(puntos[-1])
    for i in range(4):
        bm.faces.new((anillos[-1][i], anillos[-1][(i + 1) % 4], punta))
    bm.faces.new(list(reversed(anillos[0])))


def _r(semilla):
    return random.Random(semilla)


def flequillo(bm, r, n, largo, ancho, desde=-0.85, hasta=0.85, fi=0.62, lado=0.0, curva=0.3):
    for k in range(n):
        th = desde + (hasta - desde) * (k + r.uniform(-0.3, 0.3)) / max(1, n - 1)
        largo_k = largo * r.uniform(0.8, 1.2)
        mechon(bm, th, fi + r.uniform(-0.08, 0.08), largo_k, ancho * r.uniform(0.85, 1.15), (lado + math.sin(th) * 0.4, -0.45, -1.0), segs=4, curva=curva, abre=0.15, giro=r.uniform(-15, 15))


def corona(bm, r, n, largo, ancho, fi_min, fi_max, arriba=0.3, atras=0.5, abre=0.8, curva=0.4, frente_libre=0.9, segs=4):
    """Mechones repartidos por la coronilla, la nuca y los costados (la frente queda libre)."""
    for k in range(n):
        th = r.uniform(-math.pi, math.pi)
        fi = r.uniform(fi_min, fi_max)
        if abs(th) < frente_libre and fi > 0.45:
            th = math.copysign(r.uniform(frente_libre, math.pi), th)
        _, d = C._sobre_craneo(th, fi, 0)
        caida = (d.x * 0.6, d.y * 0.6 + atras, arriba)
        mechon(bm, th, fi, largo * r.uniform(0.75, 1.25), ancho * r.uniform(0.8, 1.2), caida, segs=segs, curva=curva, abre=abre, giro=r.uniform(-25, 25))


def cortina(bm, r, n, largo, ancho, th_desde, th_hasta, fi=1.0, curva=0.1):
    """Pelo largo que cae derecho (melena, cola)."""
    for k in range(n):
        th = th_desde + (th_hasta - th_desde) * (k + r.uniform(-0.4, 0.4)) / max(1, n - 1)
        _, d = C._sobre_craneo(th, fi, 0)
        mechon(bm, th, fi + r.uniform(-0.15, 0.15), largo * r.uniform(0.85, 1.1), ancho * r.uniform(0.85, 1.2), (d.x * 0.25, d.y * 0.25, -1.0), segs=5, curva=curva, abre=0.25, giro=r.uniform(-10, 10))


def peinado(estilo, n):
    bm = bmesh.new()
    r = _r(PEINADOS.index(estilo) * 7 + 1)
    lados, anillos = 16 + 2 * n, 6 + n
    cas = C.casquete
    if estilo == "Corto":
        cas(bm, 1.470, 1.290, 0.006, lados, anillos)
        corona(bm, r, 30, 0.07, 0.055, 0.05, 1.5, arriba=0.3, atras=0.45, abre=0.9, curva=0.2)
        flequillo(bm, r, 8, 0.07, 0.05)
    elif estilo == "Rapado":
        cas(bm, 1.480, 1.270, 0.003, lados + 10, anillos + 6)
        corona(bm, r, 18, 0.025, 0.04, 0.1, 1.5, arriba=0.2, atras=0.5, abre=0.9, curva=0.1, segs=3)
    elif estilo == "Pinchos":
        cas(bm, 1.470, 1.300, 0.006, lados, anillos)
        corona(bm, r, 40, 0.14, 0.065, 0.05, 1.6, arriba=0.8, atras=0.5, abre=1.0, curva=0.15)
        flequillo(bm, r, 7, 0.10, 0.055, curva=0.2)
    elif estilo == "Cresta":
        cas(bm, 1.480, 1.280, 0.003, lados, anillos)
        for k in range(11):
            fi = -1.0 + k * 0.22
            mechon(bm, 0 if fi < 0 else math.pi, abs(fi) + 0.01, 0.13 * r.uniform(0.85, 1.15), 0.075, (0, 0.5, 0.9), segs=4, curva=0.1, abre=1.0, grosor=0.22)
        corona(bm, r, 14, 0.03, 0.04, 0.6, 1.5, arriba=0.0, atras=0.3, abre=0.9, curva=0.1, segs=3)
    elif estilo == "Melena":
        cas(bm, 1.480, 1.260, 0.010, lados, anillos)
        cortina(bm, r, 18, 0.40, 0.075, math.pi * 0.42, math.pi * 1.58, fi=1.0)
        cortina(bm, r, 12, 0.33, 0.070, math.pi * 0.55, math.pi * 1.45, fi=0.55)
        for s in (1, -1):  # mechones que enmarcan la cara
            for k in range(3):
                mechon(bm, s * (0.95 + k * 0.12), 0.85, 0.30, 0.06, (s * 0.1, -0.15, -1.0), segs=5, curva=0.05, abre=0.2)
        flequillo(bm, r, 10, 0.09, 0.05, -1.0, 1.0)
    elif estilo == "Cola":
        cas(bm, 1.475, 1.290, 0.008, lados, anillos)
        flequillo(bm, r, 8, 0.08, 0.05)
        for k in range(14):
            th = math.pi + r.uniform(-0.18, 0.18)
            mechon(bm, th, r.uniform(0.85, 1.0), 0.30 * r.uniform(0.85, 1.1), 0.05, (r.uniform(-0.1, 0.1), 0.7, -0.6), segs=5, curva=0.45, abre=0.3)
        C._bola(bm, (0, 0.180, 1.440), 0.028)
    elif estilo == "Rodete":
        cas(bm, 1.475, 1.290, 0.008, lados, anillos)
        flequillo(bm, r, 7, 0.08, 0.05)
        C._bola(bm, (0, 0.090, 1.560), 0.065, 16, 10)
        corona(bm, r, 10, 0.06, 0.04, 0.9, 1.5, arriba=-0.3, atras=0.2, curva=0.4)
    elif estilo == "DosRodetes":
        cas(bm, 1.475, 1.290, 0.008, lados, anillos)
        flequillo(bm, r, 7, 0.08, 0.05)
        for s in (1, -1):
            C._bola(bm, (s * 0.125, 0.030, 1.545), 0.052, 14, 10)
            for k in range(4):
                mechon(bm, s * (1.3 + k * 0.1), 1.05, 0.16, 0.045, (s * 0.2, 0, -1.0), segs=4, curva=0.1, abre=0.3)
    elif estilo == "Afro":
        cas(bm, 1.470, 1.270, 0.050, lados + 8, anillos + 3, lambda th, fi: 0.010 * math.sin(6 * th) * math.sin(5 * fi) + 0.03 * math.cos(fi))
        for k in range(26):
            th, fi = r.uniform(-math.pi, math.pi), r.uniform(0.05, 1.5)
            if abs(th) < 0.8 and fi > 0.6:
                continue
            p, d = C._sobre_craneo(th, fi, 0.05 + 0.03 * math.cos(fi))
            C._bola(bm, p, r.uniform(0.025, 0.04), 8, 6)
    elif estilo == "Flequillo":
        cas(bm, 1.490, 1.290, 0.008, lados, anillos)
        corona(bm, r, 34, 0.11, 0.065, 0.05, 1.6, arriba=0.35, atras=0.45, abre=0.9, curva=0.2)
        for k in range(9):  # mechones largos que tapan un ojo
            th = -0.75 + 1.35 * k / 8 + r.uniform(-0.05, 0.05)
            mechon(bm, th, 0.5, 0.17 + 0.03 * r.random(), 0.065, (-0.25, -0.5, -1.0), segs=5, curva=0.15, abre=0.2, giro=r.uniform(-15, 15))
    elif estilo == "PeinadoAtras":
        cas(bm, 1.495, 1.280, 0.010, lados, anillos)
        for k in range(26):
            th = -1.5 + 3.0 * k / 25
            mechon(bm, th + r.uniform(-0.05, 0.05), 0.30, 0.20 * r.uniform(0.9, 1.1), 0.06, (math.sin(th) * 0.25, 1.0, 0.2), segs=5, curva=0.25, abre=0.08, grosor=0.25)
    elif estilo == "Trenzas":
        cas(bm, 1.480, 1.290, 0.008, lados, anillos)
        flequillo(bm, r, 8, 0.09, 0.05)
        for s in (1, -1):
            for k in range(9):
                t = k / 8
                C._bola(bm, (s * (0.175 + 0.01 * t), 0.050 + 0.02 * t, 1.400 - 0.250 * t), 0.028 - 0.008 * t, 8, 6)
    return bm


PEINADOS = C.PEINADOS


def armar():
    objs = []
    for estilo in PEINADOS:
        for n in range(12):
            obj = T.malla(f"Pelo_{estilo}", peinado(estilo, n), "pelo", "Head", suave=50)
            tris = B.triangulos(obj)
            if tris >= 1000 or n == 11:
                break
        if tris > 2000:
            print(f"AVISO: {estilo} tiene {tris} triángulos")
        objs.append(obj)
    return objs


def main():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    minimo, maximo = B.caja_de([B.parte("Head")])
    C.CENTRO = (minimo + maximo) / 2
    C.RADIOS = Vector((CABEZA_R, CABEZA_R, CABEZA_H))
    B.parte("Head").hide_render = True
    cabeza = cabeza_clasica(C.CENTRO)
    from mathutils.bvhtree import BVHTree

    bm = bmesh.new()
    bm.from_mesh(cabeza.data)
    bm.transform(cabeza.matrix_world)
    C.CRANEO = BVHTree.FromBMesh(bm)
    bm.free()
    C._radio_craneo = radio_caja
    pelos = armar()
    print("Triángulos:", {o.name: B.triangulos(o) for o in pelos})

    # Render: cabeza de Roblox con cara y tono distintos, pelo de 12 colores.
    C.uv_cabeza(cabeza)
    for o in B.partes():
        o.hide_render = True
    for o in pelos:
        o.hide_render = True
    cabeza.hide_render = True  # si no, se superpone con la copia de la primera celda
    celdas = []
    for i, o in enumerate(pelos):
        piel = C.mat_piel(f"_p{i}", C.TONOS[(i * 3) % 10], [C.cara(i % 12 + 1)])
        celdas.append([(cabeza, piel), (o, C.mat_pelo(f"_c{i}", C.COLORES_PELO[i]))])
    C._render_grilla("cuerpo_peinados_v2", celdas, 6, giro=30, paso=(0.50, 0.62), ancho_celda=340)
    celdas = []
    for i, o in enumerate(pelos):
        piel = C.mat_piel(f"_q{i}", C.TONOS[(i * 3) % 10], [C.cara(i % 12 + 1)])
        celdas.append([(cabeza, piel), (o, C.mat_pelo(f"_d{i}", C.COLORES_PELO[i]))])
    C._render_grilla("cuerpo_peinados_v2_espalda", celdas, 6, giro=180, paso=(0.50, 0.62), ancho_celda=340)

    # FBX para Studio: los 12 peinados y la cabeza como referencia de posición.
    ref = cabeza  # la cabeza clásica va en el mismo FBX: es la cabeza del personaje y la referencia
    for o in bpy.context.scene.objects:
        o.select_set(o in pelos or o is ref)
    bpy.context.view_layer.objects.active = ref
    ruta = os.path.join(B.EXPORTS, "cuerpo", "Peinados.fbx")
    bpy.ops.export_scene.fbx(filepath=ruta, use_selection=True, object_types={"MESH"}, global_scale=1 / B.STUD, apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS", axis_forward="Z", axis_up="Y", bake_space_transform=True, mesh_smooth_type="FACE", add_leaf_bones=False, bake_anim=False)
    for o in pelos:
        o.hide_render = False
    for m in list(bpy.data.materials):
        if m.name.startswith("_"):
            bpy.data.materials.remove(m)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Listo:", ruta)


if __name__ == "__main__":
    main()
