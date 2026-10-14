"""Rocas terminadas: una geoda distinta por bioma, más la Geoda Oculta y la Prismática.

Cada bioma tiene su forma de roca y su tipo de cristal (mismo estilo vóxel que modelos.py):
  1 Pradera de Cuarzo   huevo con puntas de cuarzo
  2 Dunas de Ámbar      canto ancho con capas y gotas de ámbar
  3 Glaciar de Zafiro   roca facetada con esquirlas largas
  4 Volcán de Rubí      columnas de basalto con bloques de rubí
  5 Abismo Estelar      roca con un surco y estrellas que flotan
  Oculta                huevo con una veta brillante alrededor (el mineral secreto)
  Prisma                prisma alto con esquirlas de colores
Exporta un FBX por bioma (arte/fbx/Geodas_Zona<N>.fbx, con Pequena, Mediana, Gigante y Jefe
adentro) y uno con las especiales (Geodas_Especiales.fbx). Cada tamaño tiene las mallas Roca,
Cristales, Base, Grietas y Grietas2 (las que pinta ModeloGeoda.luau).

Uso: <python de Blender> forja-rapida/arte/scripts/rocas.py
"""

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001  (bpy antes que modelos, que usa bmesh)
import modelos as M  # noqa: E402

ESTILOS = {
    1: {"forma": "huevo", "cristal": "puntas", "roca": "#6E7487", "cris": "#C77DFF"},
    2: {"forma": "canto", "cristal": "gotas", "roca": "#B07A4A", "cris": "#FFB627"},
    3: {"forma": "facetada", "cristal": "esquirlas", "roca": "#7FA6C9", "cris": "#3D7BFF"},
    4: {"forma": "columnas", "cristal": "bloques", "roca": "#4A3338", "cris": "#FF2E4D"},
    5: {"forma": "surco", "cristal": "estrellas", "roca": "#2E2A5C", "cris": "#7CF5FF"},
}
ESPECIALES = {
    "Oculta": {"forma": "huevo", "cristal": "veta", "roca": "#3A3F66", "cris": "#CFE8FF", "tam": "Mediana", "escala": 1.07},
    "Prisma": {"forma": "prisma", "cristal": "esquirlas", "roca": "#F2F7FF", "cris": "#9CFBFF", "tam": "Gigante", "escala": 0.83},
}


def datos_especial(est):
    """Tamaño de una especial: el de su molde por "escala", para que mida lo mismo que en el juego
    (Tamanos.Oculta.Escala 1,6 y Prisma 1,9 de GameConfig, sobre la Pequeña de 3 studs)."""
    datos = dict(M.GEODAS[est["tam"]])
    datos["diametro"] *= est["escala"]
    return datos


def apoyar(celdas):
    zmin = min(c[2] for c in celdas)
    return {(x, y, z - zmin) for x, y, z in celdas}


# --- formas de roca ---------------------------------------------------------------------------


def forma(nombre, r, semilla):
    rng = random.Random(semilla)
    if nombre == "huevo":
        return M.celdas_roca(r, semilla)
    celdas = set()
    if nombre == "canto":
        rx, ry, rz = r * 1.2, r * 1.1, r * 0.82
        for x in range(-r - 3, r + 4):
            for y in range(-r - 3, r + 4):
                for z in range(-r - 2, r + 2):
                    cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                    d = (cx / rx) ** 2 + (cy / ry) ** 2 + (cz / rz) ** 2 + 0.18 * M.ruido(cx, cy, cz, 0.3, semilla)
                    if d <= 1 and cz > -rz * 0.6:
                        # capas: cada 3 filas, el borde se mete un cubito
                        if z % 3 == 0 and d > 0.78:
                            continue
                        celdas.add((x, y, z))
    elif nombre == "facetada":
        rx, ry, rz = r * 0.95, r * 0.9, r * 1.3
        for x in range(-r - 2, r + 3):
            for y in range(-r - 2, r + 3):
                for z in range(-int(rz) - 2, int(rz) + 2):
                    cx, cy, cz = x + 0.5, y + 0.5, z + 0.5
                    octa = (abs(cx) / rx + abs(cy) / ry) * 0.62 + abs(cz) / rz
                    esf = (cx / rx) ** 2 + (cy / ry) ** 2 + (cz / rz) ** 2
                    d = 0.6 * octa + 0.4 * esf + 0.1 * M.ruido(cx, cy, cz, 0.5, semilla)
                    if d <= 1 and cz > -rz * 0.55:
                        celdas.add((x, y, z))
    elif nombre == "columnas":
        for cx in range(-r, r + 1, 2):
            for cy in range(-r, r + 1, 2):
                dist = math.hypot(cx, cy)
                if dist > r + 0.5:
                    continue
                alto = int(r * (1.7 - 0.9 * dist / r)) + rng.randint(-1, 1)
                for dx in range(2):
                    for dy in range(2):
                        for z in range(max(2, alto)):
                            celdas.add((cx + dx, cy + dy, z))
    elif nombre == "surco":
        base = M.celdas_roca(r, semilla)
        zmax = max(c[2] for c in base)
        medio = zmax * 0.55
        for x, y, z in base:
            borde = any((x + dx, y + dy, z) not in base for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if abs(z - medio) < 1 and borde:
                continue  # el surco alrededor
            celdas.add((x, y, z))
        # piedritas que flotan arriba
        for i in range(3):
            a = i / 3 * math.tau + semilla
            px, py = int(math.cos(a) * r * 0.9), int(math.sin(a) * r * 0.9)
            celdas.add((px, py, zmax + 3 + i % 2))
        return celdas
    elif nombre == "prisma":
        rz = r * 1.8
        for x in range(-r - 1, r + 2):
            for y in range(-r - 1, r + 2):
                for z in range(int(rz)):
                    hexa = max(abs(x + 0.5), (abs(x + 0.5) * 0.5 + abs(y + 0.5) * 0.87))
                    punta = 1 - max(0, (z - rz * 0.7) / (rz * 0.3)) * 0.6
                    if hexa <= r * 0.85 * punta:
                        celdas.add((x, y, z))
    return apoyar(celdas)


# --- cristales (en la grilla el doble de fina) -------------------------------------------------


def arriba(roca, rng, cantidad, minimo=0.62, separacion=3):
    alto = {}
    for x, y, z in roca:
        alto[(x, y)] = max(alto.get((x, y), -1), z)
    zmax = max(alto.values())
    lugares = [(xy, z) for xy, z in alto.items() if z >= zmax * minimo]
    rng.shuffle(lugares)
    elegidos = []
    for xy, z in lugares:
        if all(abs(xy[0] - e[0][0]) + abs(xy[1] - e[0][1]) >= separacion for e in elegidos):
            elegidos.append((xy, z))
        if len(elegidos) >= cantidad:
            break
    return elegidos, zmax


def cristales(nombre, roca, cantidad, semilla):
    rng = random.Random(semilla)
    if nombre == "puntas":
        return M.celdas_cristales(roca, cantidad, semilla)
    celdas = set()
    if nombre == "gotas":
        for i, ((x, y), z) in enumerate(arriba(roca, rng, cantidad + 3, 0.45, 3)[0]):
            bx, by, bz = x * 2, y * 2, z * 2 + 1
            radio = 3 if i == 0 else 2
            for dx in range(-radio, radio + 1):
                for dy in range(-radio, radio + 1):
                    for dz in range(0, radio + 2):
                        if dx * dx + dy * dy + (dz - 1) ** 2 <= radio * radio + 1:
                            celdas.add((bx + dx, by + dy, bz + dz))
    elif nombre == "esquirlas":
        for i, ((x, y), z) in enumerate(arriba(roca, rng, cantidad + 2, 0.5, 2)[0]):
            bx, by, bz = x * 2, y * 2, z * 2 + 1
            h = rng.randint(8, 12) + (3 if i == 0 else 0)
            incl = (math.copysign(1, x) if x else rng.choice([-1, 1]), math.copysign(1, y) if y else 0)
            for k in range(h):
                ox, oy = bx + int(incl[0]) * (k // 2), by + int(incl[1]) * (k // 2)
                grosor = 2 if k < 3 else 1
                for dx in range(grosor):
                    for dy in range(grosor):
                        celdas.add((ox + dx, oy + dy, bz + k))
    elif nombre == "bloques":
        for (x, y), z in arriba(roca, rng, cantidad + 2, 0.4, 2)[0]:
            bx, by, bz = x * 2, y * 2, z * 2 + 1
            ancho = rng.choice([2, 3, 3])
            h = rng.randint(5, 9)
            for dx in range(ancho):
                for dy in range(ancho):
                    for k in range(h - (1 if (dx + dy) % 2 else 0)):
                        celdas.add((bx + dx, by + dy, bz + k))
    elif nombre == "estrellas":
        elegidos, zmax = arriba(roca, rng, cantidad, 0.45)
        for (x, y), z in elegidos:
            cx, cy, cz = x * 2, y * 2, z * 2 + 4  # flotan un poco arriba de la roca
            for dx in range(-2, 3):
                for dy in range(-2, 3):
                    for dz in range(-2, 3):
                        if abs(dx) + abs(dy) + abs(dz) <= 2:
                            celdas.add((cx + dx, cy + dy, cz + dz))
    elif nombre == "veta":
        # una banda que asoma alrededor de la roca a media altura, y unas puntitas
        zmax = max(c[2] for c in roca)
        medio = int(zmax * 0.5)
        for x, y, z in roca:
            if z in (medio, medio + 1):
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if (x + dx, y + dy, z) not in roca:
                        fx, fy = (x + dx) * 2, (y + dy) * 2
                        for a in range(2):
                            for b in range(2):
                                for c in range(2):
                                    celdas.add((fx + a - dx, fy + b - dy, z * 2 + c))
        celdas |= M.celdas_cristales(roca, 2, semilla)
    return celdas


# --- armar y exportar -------------------------------------------------------------------------


def armar(nombre, datos, estilo, mats, semilla):
    r = datos["radio"]
    lado = datos["diametro"] * M.STUD / (2 * r)
    roca = forma(estilo["forma"], r, semilla)
    o_roca = (0, 0, lado * 0.5)
    obj_roca, t1 = M.voxeles("Roca", roca, lado, mats["roca"], origen=o_roca, atlas=True)
    cris = cristales(estilo["cristal"], roca, datos["cristales"], semilla)
    obj_cris, t2 = M.voxeles("Cristales", cris, lado / 2, mats["cristal"], origen=o_roca)
    obj_base, t3 = M.voxeles("Base", M.celdas_base(r, semilla), lado, mats["base"])
    largo = r * 3
    obj_g1, t4 = M.grietas("Grietas", roca, lado, mats["grieta"], o_roca, semilla, 3, largo)
    obj_g2, t5 = M.grietas("Grietas2", roca, lado, mats["grieta2"], o_roca, semilla + 1000, 3, largo)
    total = t1 + t2 + t3 + t4 + t5
    # cada malla ya se revisa contra el máximo de Roblox (modelos.objeto_desde_bmesh)
    print(f"  {nombre}: {total} triángulos en 5 mallas")
    return [obj_roca, obj_cris, obj_base, obj_g1, obj_g2]


def mats_de(estilo):
    # nombres distintos por color: modelos.material reusa el material si el nombre ya existe
    return {
        "roca": M.material("Roca" + estilo["roca"], estilo["roca"]),
        "cristal": M.material("Cristales" + estilo["cris"], estilo["cris"], rugoso=0.2),
        "base": M.material("Base", M.COLOR_BASE),
        "grieta": M.material("Grietas" + estilo["cris"], estilo["cris"]),
        "grieta2": M.material("Grietas2", "#2EF2FF"),
    }


def agrupar(nombre, objetos, padre=None):
    vacio = bpy.data.objects.new(nombre, None)
    bpy.context.scene.collection.objects.link(vacio)
    vacio.parent = padre
    for o in objetos:
        o.parent = vacio
    return vacio


def exportar_grupo(raiz, archivo):
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / archivo),
        use_selection=True,
        object_types={"MESH", "EMPTY"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        bake_space_transform=True,
        add_leaf_bones=False,
    )
    print("  FBX", archivo)


def exportar():
    M.limpiar_escena()
    for zona, est in ESTILOS.items():
        raiz = bpy.data.objects.new(f"Zona{zona}", None)
        bpy.context.scene.collection.objects.link(raiz)
        mats = mats_de(est)
        for tam, datos in M.GEODAS.items():
            objs = armar(f"Zona{zona} {tam}", datos, est, mats, datos["semilla"] + zona * 101)
            agrupar(tam, objs, raiz)
        exportar_grupo(raiz, f"Geodas_Zona{zona}.fbx")
        M.limpiar_escena()
    raiz = bpy.data.objects.new("Especiales", None)
    bpy.context.scene.collection.objects.link(raiz)
    for nombre, est in ESPECIALES.items():
        datos = datos_especial(est)
        objs = armar(nombre, datos, est, mats_de(est), datos["semilla"] + 7)
        agrupar(nombre, objs, raiz)
    exportar_grupo(raiz, "Geodas_Especiales.fbx")
    M.limpiar_escena()


def render():
    M.limpiar_escena()
    escena = M.escena_render(1600, 760)
    filas = [(f"{z} {n}", est) for z, (n, est) in enumerate(
        [("Pradera", ESTILOS[1]), ("Dunas", ESTILOS[2]), ("Glaciar", ESTILOS[3]), ("Volcán", ESTILOS[4]), ("Abismo", ESTILOS[5])], 1
    )]
    filas += [("Oculta", ESPECIALES["Oculta"]), ("Prismática", ESPECIALES["Prisma"])]
    for i, (texto, est) in enumerate(filas):
        datos = M.GEODAS["Mediana"]
        objs = armar(texto, datos, est, mats_de(est), datos["semilla"] + (i + 1) * 101)
        if est["cristal"] in ("veta", "estrellas") or texto == "Prismática":
            for o in objs:
                if o.name.startswith("Cristales"):
                    o.data.materials.clear()
                    o.data.materials.append(M.material(f"Brillo{i}", est["cris"], brillo=est["cris"], fuerza_brillo=2.5))
        objs = M.sin_grietas(objs)
        x = (i - 3) * 1.85
        M.mover(objs, x, giro=0.4 + 0.3 * i)
        M.etiqueta(texto, x, -1.2, tam=0.24)
    M.camara(escena, (-0.3, 0, 0.7), 11.0, 2.8, lente=30, giro=-6)
    M.render("geodas_biomas")


if __name__ == "__main__":
    M.FBX.mkdir(parents=True, exist_ok=True)
    if "--solo-render" not in sys.argv:
        exportar()
    render()
    print("Listo")
