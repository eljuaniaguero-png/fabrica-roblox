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


HOMBRO_Z = 1.215  # nada de pelo por debajo de esto adelante o a los costados (los hombros)
ESPALDA_Y = 0.175  # por debajo de HOMBRO_Z, el pelo va detrás de la espalda


def _empujar(p, margen=SEPARACION):
    """Saca el punto de adentro de la cabeza y lo aleja del cuerpo: así ningún mechón atraviesa
    la cabeza, los hombros ni el pecho."""
    v = p - C.CENTRO
    d = v.normalized()
    minimo = radio_caja(d) + margen
    if v.length < minimo:
        p = C.CENTRO + d * minimo
    if p.z < HOMBRO_Z:
        if p.y < ESPALDA_Y:
            if p.y > 0.0:  # ya está atrás: que pase por detrás de la espalda
                p = Vector((p.x, ESPALDA_Y, p.z))
            else:  # adelante o al costado: se queda arriba del hombro
                p = Vector((p.x, p.y, HOMBRO_Z))
    return p


def sobre(th, fi, alto):
    """Punto a `alto` metros por encima del cráneo, en (th, fi): th 0 = frente, fi 0 = arriba."""
    d = Vector((math.sin(fi) * math.sin(th), -math.sin(fi) * math.cos(th), math.cos(fi)))
    return C.CENTRO + d * (radio_caja(d) + alto)


# Sección del mechón: una lente (gruesa en el medio, fina en los bordes), así se ve como un
# volumen liso y no como un pincho.
SECCION = [(-1.0, 0.0), (-0.55, 0.75), (0.0, 1.0), (0.55, 0.75), (1.0, 0.0), (0.0, -0.35)]


def mechon(bm, th0, fi0, dth, dfi, largo, ancho, alto=0.016, grosor=0.4, pasos=5, cuelga=0.0, caida=(0, 0, -1), curva=0.6, pasos_cuelga=4, punta=1.0):
    """Mechón grueso y liso. Primero sigue el cráneo de (th0, fi0) a (th0+dth, fi0+dfi), pegado a
    `alto` metros; después cuelga `cuelga` metros hacia `caida`, doblándose con la gravedad
    (`curva`). Se afina hasta una punta suave."""
    puntos = [sobre(th0 + dth * i / pasos, fi0 + dfi * i / pasos, alto * (1 - 0.25 * i / pasos)) for i in range(pasos + 1)]
    if cuelga > 0:
        rumbo = (puntos[-1] - puntos[-2]).normalized()
        objetivo = Vector(caida).normalized()
        p = puntos[-1]
        for k in range(pasos_cuelga):
            rumbo = (rumbo + objetivo * curva).normalized()
            p = _empujar(p + rumbo * cuelga / pasos_cuelga, alto * 0.6)
            puntos.append(p)
    n = len(puntos)
    anillos = []
    for i in range(n - 1):
        c = puntos[i]
        t = (puntos[i + 1] - c).normalized()
        radial = (c - C.CENTRO).normalized()
        lado = t.cross(radial)
        lado = lado.normalized() if lado.length > 1e-4 else Vector((1, 0, 0))
        arriba = lado.cross(t).normalized()
        if arriba.dot(radial) < 0:
            arriba = -arriba
        u = i / (n - 1)
        w = ancho * min(1.0, 0.55 + u * 3) * (1 - u) ** (0.6 * punta)
        h = ancho * grosor * (1 - u) ** 0.5
        anillos.append([bm.verts.new(c + lado * sx * w / 2 + arriba * sy * h / 2) for sx, sy in SECCION])
    k = len(SECCION)
    for a, b in zip(anillos, anillos[1:]):
        for i in range(k):
            bm.faces.new((a[i], a[(i + 1) % k], b[(i + 1) % k], b[i]))
    tip = bm.verts.new(puntos[-1])
    for i in range(k):
        bm.faces.new((anillos[-1][i], anillos[-1][(i + 1) % k], tip))
    bm.faces.new(list(reversed(anillos[0])))


def _r(semilla):
    return random.Random(semilla)


def flequillo(bm, r, n, desde, hasta, largo=0.05, ancho=0.075, fi_fin=0.78, lado=0.0, alto=0.022):
    """Mechones que bajan de la coronilla a la frente y quedan arriba de las cejas."""
    for k in range(n):
        th = desde + (hasta - desde) * k / max(1, n - 1)
        mechon(bm, th - lado * 0.4, 0.15 + r.uniform(0, 0.08), lado * 0.4 + r.uniform(-0.06, 0.06), fi_fin - 0.15, 0, ancho * r.uniform(0.9, 1.15), alto=alto, cuelga=largo * r.uniform(0.8, 1.2), caida=(lado * 0.3, -0.35, -1), curva=0.5)


def capa(bm, r, n, th_desde, th_hasta, fi_fin, cuelga, ancho, alto=0.02, caida_atras=0.0, curva=0.6):
    """Una vuelta de mechones que salen de la coronilla y bajan por el cráneo (costados y atrás)."""
    for k in range(n):
        th = th_desde + (th_hasta - th_desde) * (k + r.uniform(-0.2, 0.2)) / max(1, n - 1)
        _, d = sobre(th, 1.0, 0), None
        caida = (math.sin(th) * 0.25, -math.cos(th) * 0.25 + caida_atras, -1)
        mechon(bm, th, 0.12 + r.uniform(0, 0.06), r.uniform(-0.05, 0.05), fi_fin - 0.12, 0, ancho * r.uniform(0.9, 1.15), alto=alto, cuelga=cuelga * r.uniform(0.85, 1.15), caida=caida, curva=curva)


def puntas(bm, r, n, largo, ancho, fi_min=0.15, fi_max=1.3, sube=0.6, alto=0.02):
    """Mechones de anime que se levantan hacia afuera y atrás (la frente queda para el flequillo)."""
    for k in range(n):
        th = r.uniform(-math.pi, math.pi)
        fi = r.uniform(fi_min, fi_max)
        if abs(th) < 0.75 and fi > 0.35:
            th = math.copysign(r.uniform(0.75, math.pi), th)
        d = sobre(th, fi, 0) - C.CENTRO
        d.normalize()
        caida = (d.x, d.y + 0.5, d.z * 0.3 + sube)
        mechon(bm, th, fi, 0, 0.12, 0, ancho * r.uniform(0.85, 1.2), alto=alto, pasos=2, cuelga=largo * r.uniform(0.8, 1.25), caida=caida, curva=0.25)


def peinado(estilo, n):
    """bmesh del peinado `estilo`. `n` sube la resolución del casquete (para llegar a 1.000)."""
    bm = bmesh.new()
    r = _r(PEINADOS.index(estilo) * 7 + 1)
    lados, anillos = 18 + 2 * n, 7 + n
    cas = C.casquete
    if estilo == "Corto":  # mechones lisos que bajan desde la coronilla, flequillo de costado
        cas(bm, 1.465, 1.290, 0.012, lados, anillos)
        capa(bm, r, 10, 0.9, 2 * math.pi - 0.9, 1.25, 0.03, 0.10)
        flequillo(bm, r, 5, -0.7, 0.7, largo=0.04, lado=0.6)
    elif estilo == "Rapado":
        cas(bm, 1.480, 1.270, 0.005, lados + 10, anillos + 6)
    elif estilo == "Pinchos":  # puntas grandes hacia arriba y atrás
        cas(bm, 1.465, 1.300, 0.012, lados, anillos)
        puntas(bm, r, 14, 0.12, 0.10, sube=0.9)
        flequillo(bm, r, 5, -0.6, 0.6, largo=0.05)
    elif estilo == "Cresta":
        cas(bm, 1.480, 1.280, 0.004, lados, anillos)
        for k in range(7):
            fi = -0.95 + k * 0.32
            th = 0 if fi < 0 else math.pi
            mechon(bm, th, abs(fi) + 0.01, 0, 0.05, 0, 0.11, alto=0.01, grosor=0.3, pasos=2, cuelga=0.12, caida=(0, 0.4, 1), curva=0.2)
    elif estilo == "Melena":  # raya al medio, mechones grandes que enmarcan la cara, largo atrás
        cas(bm, 1.470, 1.260, 0.014, lados, anillos)
        for s in (1, -1):
            for k in range(3):  # de la raya hacia los costados de la cara
                mechon(bm, s * 0.05, 0.12, s * (0.75 + 0.2 * k), 0.85 + 0.12 * k, 0, 0.11, alto=0.024, pasos=6, cuelga=0.10 + 0.04 * k, caida=(s * 0.15, -0.1, -1), curva=0.7)
        capa(bm, r, 9, 1.6, 2 * math.pi - 1.6, 1.4, 0.24, 0.12, caida_atras=0.4, curva=0.8)
    elif estilo == "Cola":
        cas(bm, 1.470, 1.290, 0.012, lados, anillos)
        flequillo(bm, r, 5, -0.6, 0.6, largo=0.04)
        for k in range(7):  # todo el pelo se junta atrás
            th = 1.2 + (2 * math.pi - 2.4) * k / 6
            mechon(bm, th, 0.15, math.pi - th, 0.75, 0, 0.11, alto=0.018, pasos=6)
        for k in range(5):
            mechon(bm, math.pi + (k - 2) * 0.08, 0.95, 0, 0.05, 0, 0.07, alto=0.03, pasos=2, cuelga=0.28, caida=(0, 0.9, -0.6), curva=0.5)
        C._bola(bm, (0, 0.185, 1.430), 0.03)
    elif estilo == "Rodete":
        cas(bm, 1.470, 1.290, 0.012, lados, anillos)
        flequillo(bm, r, 5, -0.6, 0.6, largo=0.04)
        C._bola(bm, (0, 0.100, 1.565), 0.068, 16, 10)
    elif estilo == "DosRodetes":
        cas(bm, 1.470, 1.290, 0.012, lados, anillos)
        flequillo(bm, r, 5, -0.6, 0.6, largo=0.04)
        for s in (1, -1):
            C._bola(bm, (s * 0.135, 0.030, 1.548), 0.056, 14, 10)
    elif estilo == "Afro":
        cas(bm, 1.470, 1.270, 0.050, lados + 8, anillos + 3, lambda th, fi: 0.010 * math.sin(6 * th) * math.sin(5 * fi) + 0.03 * math.cos(fi))
        for k in range(22):
            th, fi = r.uniform(-math.pi, math.pi), r.uniform(0.05, 1.5)
            if abs(th) < 0.8 and fi > 0.6:
                continue
            p = sobre(th, fi, 0.05 + 0.03 * math.cos(fi))
            C._bola(bm, p, r.uniform(0.028, 0.042), 8, 6)
    elif estilo == "Flequillo":  # puntas atrás y mechones largos que tapan un ojo
        cas(bm, 1.480, 1.290, 0.012, lados, anillos)
        puntas(bm, r, 10, 0.09, 0.10, fi_min=0.5, sube=0.4)
        for k in range(5):
            th = -0.55 + 0.27 * k
            mechon(bm, th + 0.35, 0.12, -0.35, 0.62, 0, 0.10, alto=0.026, pasos=5, cuelga=0.08 + 0.03 * (k % 2), caida=(-0.3, -0.4, -1), curva=0.6)
    elif estilo == "PeinadoAtras":  # todo hacia atrás, por encima del cráneo
        cas(bm, 1.490, 1.280, 0.012, lados, anillos)
        for k in range(9):
            th = -0.9 + 1.8 * k / 8
            mechon(bm, th, 0.75, -th * 0.4, -1.6, 0, 0.11, alto=0.02, pasos=7, cuelga=0.05, caida=(0, 1, -0.6), curva=0.4)
    elif estilo == "Trenzas":
        cas(bm, 1.475, 1.290, 0.012, lados, anillos)
        flequillo(bm, r, 5, -0.6, 0.6, largo=0.04)
        for s in (1, -1):
            for k in range(7):
                t = k / 6
                C._bola(bm, (s * 0.15, 0.10 + 0.07 * t, 1.330 - 0.120 * t), 0.030 - 0.008 * t, 8, 6)
    return bm


PEINADOS = C.PEINADOS


def armar():
    objs = []
    for estilo in PEINADOS:
        for n in range(12):
            obj = T.malla(f"Pelo_{estilo}", peinado(estilo, n), "pelo", "Head", suave=180)
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
