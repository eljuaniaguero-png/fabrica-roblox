"""Pinta detalles planos (manchas, grietas, huellas, óxido, siluetas) directo en las texturas horneadas.

La idea: todo lo plano va en la textura, no como malla. Para cada triángulo de la malla se recorre su
lugar en el mapa UV y se calcula en qué punto del mundo cae cada píxel (coordenadas baricéntricas).
Así cada efecto se escribe como una función del punto del mundo (x, y, z en studs) y de la normal.
"""

import math
import os

import bpy
import numpy as np

STUD = 0.28


def _hash(x, y, s=0.0):
    v = np.sin(x * 127.1 + y * 311.7 + s * 74.7) * 43758.5453
    return v - np.floor(v)


def ruido(x, y, escala=1.0, s=0.0):
    """Ruido de valor suave (0-1) en 2D, vectorizado."""
    x, y = x / escala, y / escala
    xi, yi = np.floor(x), np.floor(y)
    xf, yf = x - xi, y - yi
    u, v = xf * xf * (3 - 2 * xf), yf * yf * (3 - 2 * yf)
    a, b = _hash(xi, yi, s), _hash(xi + 1, yi, s)
    c, d = _hash(xi, yi + 1, s), _hash(xi + 1, yi + 1, s)
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v


def fbm(x, y, escala=1.0, s=0.0):
    return 0.5 * ruido(x, y, escala, s) + 0.3 * ruido(x, y, escala / 2.3, s + 3) + 0.2 * ruido(x, y, escala / 5.1, s + 7)


def hexa(h):
    h = h.lstrip("#")
    return np.array([int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)])


def dist_polilinea(px, py, pts):
    """Distancia de cada punto (px, py) a una polilínea."""
    d = np.full(px.shape, 1e9)
    for (ax, ay), (bx, by) in zip(pts[:-1], pts[1:]):
        vx, vy = bx - ax, by - ay
        t = np.clip(((px - ax) * vx + (py - ay) * vy) / max(vx * vx + vy * vy, 1e-9), 0, 1)
        d = np.minimum(d, np.hypot(px - (ax + t * vx), py - (ay + t * vy)))
    return d


def muestras(obj, lado):
    """Para cada píxel cubierto por la malla en el UV: índice (fila, col), punto del mundo en studs y normal."""
    me = obj.data
    me.calc_loop_triangles()
    uv = me.uv_layers.active.data
    mw = obj.matrix_world
    rot = mw.to_3x3()
    filas, cols, pts, nors = [], [], [], []
    for tri in me.loop_triangles:
        uvs = np.array([uv[li].uv[:] for li in tri.loops]) * lado
        ws = np.array([(mw @ me.vertices[vi].co)[:] for vi in tri.vertices]) / STUD
        n = np.array((rot @ tri.normal).normalized()[:])
        x0, y0 = np.floor(uvs.min(0)).astype(int)
        x1, y1 = np.ceil(uvs.max(0)).astype(int)
        if x1 <= x0 or y1 <= y0:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1) + 0.5, np.arange(y0, y1) + 0.5)
        (ax, ay), (bx, by), (cx, cy) = uvs
        det = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy)
        if abs(det) < 1e-9:
            continue
        l1 = ((by - cy) * (gx - cx) + (cx - bx) * (gy - cy)) / det
        l2 = ((cy - ay) * (gx - cx) + (ax - cx) * (gy - cy)) / det
        l3 = 1 - l1 - l2
        m = (l1 >= -0.02) & (l2 >= -0.02) & (l3 >= -0.02)
        if not m.any():
            continue
        p = l1[m, None] * ws[0] + l2[m, None] * ws[1] + l3[m, None] * ws[2]
        filas.append(np.clip(gy[m].astype(int), 0, lado - 1))
        cols.append(np.clip(gx[m].astype(int), 0, lado - 1))
        pts.append(p)
        nors.append(np.repeat(n[None], m.sum(), 0))
    if not pts:
        return None
    return np.concatenate(filas), np.concatenate(cols), np.concatenate(pts), np.concatenate(nors)


def pintar(obj, color_fn, rugosidad_fn=None, carpeta=None, imagen_color=None, imagen_rug=None):
    """color_fn(p, n, base) -> rgb nuevo; rugosidad_fn(p, n, base) -> valor nuevo. p y n son arrays (N, 3)."""
    img = imagen_color or bpy.data.images.get(f"{obj.name}_color")
    if img is None:
        return 0
    lado = img.size[0]
    s = muestras(obj, lado)
    if s is None:
        return 0
    f, c, p, n = s
    px = np.array(img.pixels[:], dtype=np.float32).reshape(lado, lado, 4)
    px[f, c, :3] = np.clip(color_fn(p, n, px[f, c, :3]), 0, 1)
    img.pixels.foreach_set(px.ravel())
    img.update()
    if img.filepath_raw:
        img.save()
    rug = imagen_rug or bpy.data.images.get(f"{obj.name}_rugosidad")
    if rugosidad_fn and rug is not None:
        lr = rug.size[0]
        s2 = muestras(obj, lr)
        if s2 is not None:
            f2, c2, p2, n2 = s2
            rp = np.array(rug.pixels[:], dtype=np.float32).reshape(lr, lr, 4)
            nuevo = np.clip(rugosidad_fn(p2, n2, rp[f2, c2, 0]), 0, 1)
            rp[f2, c2, 0] = rp[f2, c2, 1] = rp[f2, c2, 2] = nuevo
            rug.pixels.foreach_set(rp.ravel())
            rug.update()
            if rug.filepath_raw:
                rug.save()
    return len(f)


def textura_lisa(obj, lado, base_hex, carpeta_texturas, rugosidad=0.6, metal=0.0):
    """Para piezas que no se hornean: UV nuevo, imagen de color lisa y material que la usa.
    Después se le pinta encima con pintar()."""
    for o in bpy.context.view_layer.objects:
        o.select_set(o == obj)
    bpy.context.view_layer.objects.active = obj
    while obj.data.uv_layers:
        obj.data.uv_layers.remove(obj.data.uv_layers[0])
    obj.data.uv_layers.new(name="UV")
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.004, scale_to_bounds=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    nombre = f"{obj.name}_color"
    vieja = bpy.data.images.get(nombre)
    if vieja:
        bpy.data.images.remove(vieja)
    img = bpy.data.images.new(nombre, lado, lado, alpha=False)
    col = list(hexa(base_hex)) + [1.0]
    img.pixels.foreach_set(np.tile(np.array(col, dtype=np.float32), lado * lado))
    os.makedirs(carpeta_texturas, exist_ok=True)
    img.filepath_raw = os.path.join(carpeta_texturas, nombre + ".png")
    img.file_format = "PNG"
    img.save()
    mat = bpy.data.materials.new("MAT_" + obj.name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rugosidad
    bsdf.inputs["Metallic"].default_value = metal
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    return img


def mezclar(base, color, alfa):
    a = np.clip(alfa, 0, 1)[:, None]
    return base * (1 - a) + np.asarray(color)[None] * a
