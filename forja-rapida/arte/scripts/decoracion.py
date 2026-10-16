"""Decoración común de Forja Rápida (sirve en todas las zonas: el juego le pone el color de cada bioma).

Piezas:
  Risco_Escalon  tramo de risco de 16 studs de largo (x), 16 de fondo (y) y 30 de alto: una pared
                 de ladrillos que sube en 4 escalones gruesos, con una franja de pasto arriba de cada
                 escalón (con unas gotitas de pasto que cuelgan). Se pone uno al lado del otro sin
                 que se note la unión: los ladrillos cortados en los bordes no tienen junta del lado
                 del borde y los studs siguen la grilla del mundo (cada 4 studs empieza la textura).
  Pared_Ladrillo tramo de pared recta de 16 studs de largo, 4 de espesor y 24 de alto: ladrillos
                 con juntas marcadas de los dos lados y una tapa de pasto de 2 studs que sale medio
                 stud para cada lado, con gotitas. Encaja sin costura con otro tramo igual (mismo
                 truco que el risco). Mallas Pared y Tapa (la tapa toma el color de cada bioma).

Cada pieza tiene una variante por zona (ZONAS): sus colores y lo que tiene la tapa (pasto con
gotitas; dunas de arena; nieve con carámbanos; ceniza con piedritas y chorros de lava; cristales
estelares). Lo que brilla o es de otro color va en una tercera malla, Detalle.

Estilo de las capturas del juego (arte/referencias/mapa-1.png y mapa-3.png): todo de bloques,
colores planos, studs como textura (texturas/Studs.png, nunca modelados). Dos mallas, un color cada
una: Risco (pared, ladrillos, costados, fondo y base) y Pasto (franjas y gotitas). La textura de
studs es transparente salvo los studs: en Roblox va en TextureID de las dos MeshPart y se ve el
Color de cada una debajo. Las UV van en 0-1: cada cara se corta en cuadrados de 4 studs (lo que
mide la textura), así los studs quedan alineados entre caras y entre piezas.

Reglas (GUIA, sección 5): escala real (1 stud = 0,28 m), pivote en el centro de la base, frente
(la pared de los escalones) hacia -Z de Roblox, un material por malla, como mucho 6.000 triángulos
(el risco) o 2.000 (la pared).

Uso: <python de Blender> forja-rapida/arte/scripts/decoracion.py
  (sin nada: render de frente y de costado de cada pieza al lado de las referencias, y
   triángulos; --pieza <Nombre>: solo esa; --zonas: las 5 variantes de cada pieza en
   arte/renders/deco_zonas.jpg; --exportar: además arma arte/fbx/Deco_Comun.fbx)
"""

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001  (bpy antes que modelos, que usa bmesh)
import bmesh  # noqa: E402
import modelos as M  # noqa: E402

TEJA = 4  # studs que mide la textura de studs (4 x 4 studs en 256 px)

# Una variante por zona: colores (los de las capturas y de mapa.py) y cómo es la tapa.
#   risco/tapa/detalle: color de cada malla (detalle = None: la variante no tiene esa malla)
#   neon: el Detalle brilla (en Roblox, Material Neon)
#   estilo: pasto (gotitas), arena (dunas arriba, chorritos anchos), nieve (montoncitos y
#   carámbanos), ceniza (piedritas arriba y chorros de lava), estelar (cristales arriba)
ZONAS = {
    1: {"nombre": "Pradera", "risco": "#C96F5C", "tapa": "#3DB02A", "detalle": None, "neon": False, "estilo": "pasto"},
    2: {"nombre": "Dunas", "risco": "#D9A05B", "tapa": "#F2D27A", "detalle": None, "neon": False, "estilo": "arena"},
    3: {"nombre": "Glaciar", "risco": "#7FA6C9", "tapa": "#F4FAFF", "detalle": "#A8E6FF", "neon": False, "estilo": "nieve"},
    4: {"nombre": "Volcán", "risco": "#3A2E33", "tapa": "#5A4A50", "detalle": "#FF5A00", "neon": True, "estilo": "ceniza"},
    5: {"nombre": "Abismo", "risco": "#2E2A5C", "tapa": "#4B3F8F", "detalle": "#7CF5FF", "neon": True, "estilo": "estelar"},
}

# Risco_Escalon, en studs
LARGO = 16  # x, de -8 a 8
ESCALONES_Y = [-8, -4, 0, 4]  # dónde empieza (frente) cada escalón; el fondo está en 8
ALTOS = [8, 15, 22, 29]  # alto de la pared de cada escalón (el pasto va encima)
PASTO = 1  # grosor de la franja de pasto
VUELO = 0.5  # cuánto sale el pasto hacia adelante
LADRILLO = (4, 2)  # ancho y alto de cada ladrillo
RELIEVE = 0.2  # cuánto sobresale cada ladrillo de la junta
JUNTA = 0.25  # ancho de la junta entre ladrillos

# Pared_Ladrillo, en studs (mismo largo, ladrillos y vuelo que el risco)
PARED_ALTO = 22  # ladrillos (11 filas)
PARED_TAPA = 2  # tapa de pasto: 22 + 2 = 24 de alto
PARED_ESPESOR = 4  # y, de -2 a 2
MAX_PARED = 2000


class Malla:
    """Caras rectangulares (alineadas a los ejes, en studs) con UV de studs por cuadrado de TEJA."""

    # ejes (a, b) de cada cara según su normal, con a x b = normal
    EJES = {0: (1, 2), 1: (2, 0), 2: (0, 1)}

    def __init__(self):
        self.bm = bmesh.new()
        self.uv = self.bm.loops.layers.uv.verify()
        self.verts = {}

    def vert(self, p):
        clave = tuple(round(c, 4) for c in p)
        if clave not in self.verts:
            self.verts[clave] = self.bm.verts.new([c * M.STUD for c in p])
        return self.verts[clave]

    def rect(self, eje, signo, fijo, ra, rb):
        """Cara con normal `signo` * eje en eje = fijo, de ra[0] a ra[1] en a y de rb[0] a rb[1] en b.
        Se corta en la grilla de TEJA studs del mundo."""
        a, b = self.EJES[eje]
        for a0, a1 in cortes(*ra):
            for b0, b1 in cortes(*rb):
                ta, tb = math.floor(a0 / TEJA + 1e-6) * TEJA, math.floor(b0 / TEJA + 1e-6) * TEJA
                esquinas = [(a0, b0), (a1, b0), (a1, b1), (a0, b1)]
                if signo < 0:
                    esquinas.reverse()
                vs, uvs = [], []
                for ca, cb in esquinas:
                    p = [0.0, 0.0, 0.0]
                    p[eje], p[a], p[b] = fijo, ca, cb
                    vs.append(self.vert(p))
                    uvs.append(((ca - ta) / TEJA, (cb - tb) / TEJA))
                cara = self.bm.faces.new(vs)
                for loop, uv in zip(cara.loops, uvs):
                    loop[self.uv].uv = uv

    def caja(self, x, y, z, caras="xXyYzZ"):
        """Caja de (x0, x1), (y0, y1), (z0, z1); `caras` dice cuáles se hacen (x = -x, X = +x...)."""
        rangos = (x, y, z)
        for letra in caras:
            eje = "xyz".index(letra.lower())
            signo = 1 if letra.isupper() else -1
            a, b = self.EJES[eje]
            self.rect(eje, signo, rangos[eje][1 if signo > 0 else 0], rangos[a], rangos[b])

    def objeto(self, nombre, mat):
        malla = bpy.data.meshes.new(nombre)
        self.bm.normal_update()
        self.bm.to_mesh(malla)
        self.bm.free()
        malla.materials.append(mat)
        obj = bpy.data.objects.new(nombre, malla)
        bpy.context.scene.collection.objects.link(obj)
        return obj, sum(len(p.vertices) - 2 for p in malla.polygons)


def cortes(v0, v1):
    """Tramos de v0 a v1 cortados en los múltiplos de TEJA."""
    puntos = [v0]
    k = math.floor(v0 / TEJA) + 1
    while k * TEJA < v1 - 1e-6:
        if k * TEJA > v0 + 1e-6:
            puntos.append(k * TEJA)
        k += 1
    puntos.append(v1)
    return list(zip(puntos, puntos[1:]))


def ladrillos(m, y, z0, z1, fila0, signo=-1):
    """Pared de ladrillos con relieve en el plano y (mirando a signo * y), de z0 a z1. Las filas
    se corren medio ladrillo; los ladrillos cortados en x = ±8 siguen en la pieza de al lado, por
    eso no tienen junta de ese lado."""
    medio = LARGO / 2
    m.rect(1, signo, y, (z0, z1), (-medio, medio))  # la junta (fondo)
    relieve = (y - RELIEVE, y) if signo < 0 else (y, y + RELIEVE)
    caras = "xXyzZ" if signo < 0 else "xXYzZ"
    ancho, alto = LADRILLO
    j = JUNTA / 2
    for fila in range(round((z1 - z0) / alto)):
        za, zb = z0 + fila * alto + j, z0 + (fila + 1) * alto - j
        corrido = ancho / 2 if (fila0 + fila) % 2 else 0
        x = -medio - corrido
        while x < medio - 1e-6:
            xa, xb = max(x, -medio), min(x + ancho, medio)
            xa += 0 if xa == -medio else j
            xb -= 0 if xb == medio else j
            m.caja((xa, xb), relieve, (za, zb), caras=caras)
            x += ancho


def colgantes(tapa, detalle, rng, estilo, y, alto, signo=-1):
    """Lo que cuelga del vuelo de la tapa, delante de la pared en el plano y (lejos de los bordes,
    así no cortan la unión): gotitas de pasto, chorritos de arena, nieve y carámbanos, o lava."""
    medio = LARGO / 2
    if signo < 0:
        fondo, fino = (y - VUELO, y - RELIEVE - 0.05), (y - RELIEVE - 0.3, y - RELIEVE - 0.02)
    else:
        fondo, fino = (y + RELIEVE + 0.05, y + VUELO), (y + RELIEVE + 0.02, y + RELIEVE + 0.3)
    caras = "xXyYz"
    x = -medio + rng.choice((1, 2))
    while x < medio - 3:
        if estilo == "pasto":
            largo = rng.choice((1, 1, 2))  # en este orden: así queda igual a la aprobada
            ancho = rng.choice((1, 2))
            tapa.caja((x, x + ancho), fondo, (alto - largo, alto), caras=caras)
        elif estilo == "arena":
            ancho, largo = rng.choice((2, 3)), rng.choice((0.5, 1))
            tapa.caja((x, x + ancho), fondo, (alto - largo, alto), caras=caras)
        elif estilo == "nieve":
            ancho = rng.choice((2, 3))
            tapa.caja((x, x + ancho), fondo, (alto - 0.5, alto), caras=caras)
            # carámbano: un tramo de 1 de ancho y la punta más fina
            cx, l1, l2 = x + rng.choice((0, 1)), rng.choice((1, 1.5)), rng.choice((1, 1.5, 2))
            detalle.caja((cx, cx + 1), fondo, (alto - 0.5 - l1, alto - 0.5), caras=caras)
            detalle.caja((cx + 0.25, cx + 0.75), fondo, (alto - 0.5 - l1 - l2, alto - 0.5 - l1), caras=caras)
        elif estilo == "ceniza":
            ancho = 1
            if rng.random() < 0.6:  # chorro de lava pegado a los ladrillos
                largo = rng.choice((2, 3, 4, 5))
                detalle.caja((x, x + ancho), fino, (alto - largo, alto), caras=caras)
        else:  # estelar: gotitas chicas de polvo
            ancho, largo = 1, rng.choice((0.5, 1))
            tapa.caja((x, x + ancho), fondo, (alto - largo, alto), caras=caras)
        x += ancho + rng.choice((2, 3, 4))


def encima(tapa, detalle, rng, estilo, z, y0, y1):
    """Lo que va arriba de la tapa (entre y0 e y1, lejos de los bordes en x): dunas, montoncitos
    de nieve, piedritas de ceniza o cristales. El pasto va liso."""
    caras = "xXyYZ"
    hondo = y1 - y0
    if estilo == "arena":
        x = rng.uniform(-7, -3)
        while x < 2:
            ancho = rng.choice((4, 5))
            d = min(hondo, rng.choice((2.5, 3)))
            yc = rng.uniform(y0, y1 - d)
            tapa.caja((x, x + ancho), (yc, yc + d), (z, z + 0.5), caras=caras)
            tapa.caja((x + 1, x + ancho - 1), (yc + 0.5, yc + d - 0.5), (z + 0.5, z + 1), caras=caras)
            x += ancho + rng.choice((2, 3))
    elif estilo == "nieve":
        x = rng.uniform(-7, -4)
        while x < 4:
            ancho = rng.choice((2, 3))
            d = min(hondo, 2)
            yc = rng.uniform(y0, y1 - d)
            tapa.caja((x, x + ancho), (yc, yc + d), (z, z + rng.choice((0.5, 1))), caras=caras)
            x += ancho + rng.choice((2, 3, 4))
    elif estilo == "ceniza":
        x = rng.uniform(-7, -5)
        while x < 5.5:
            ancho, alto = rng.choice((1, 1.5, 2)), rng.choice((1, 1.5, 2))
            d = min(hondo, rng.choice((1, 1.5)))
            yc = rng.uniform(y0, y1 - d)
            tapa.caja((x, x + ancho), (yc, yc + d), (z, z + alto), caras=caras)
            x += ancho + rng.choice((1.5, 2.5, 3.5))
    elif estilo == "estelar":
        x = rng.uniform(-6.5, -4)
        while x < 4.5:
            yc = rng.uniform(y0, y1 - 1.5)
            for dx, dy, ancho, alto in ((0, 0.3, 1, 3), (1, 0, 0.75, 2), (0.2, 1.1, 0.6, 1.5)):
                alto *= rng.choice((0.8, 1, 1.2))
                detalle.caja((x + dx, x + dx + ancho), (yc + dy, yc + dy + ancho), (z, z + alto), caras=caras)
            x += rng.choice((4, 5, 6))


def mallas(piezas, tope, pieza):
    """Arma los objetos de [(nombre, Malla, material)] y avisa si alguno se pasa de triángulos.
    Las mallas vacías (el Detalle de las zonas que no tienen) no se arman."""
    objs, conteo = [], {}
    for nombre, malla, mat in piezas:
        if not malla.bm.faces:
            malla.bm.free()
            continue
        obj, t = malla.objeto(nombre, mat)
        if t > tope:
            raise RuntimeError(f"{pieza} {nombre}: {t} triángulos (máximo {tope})")
        objs.append(obj)
        conteo[nombre] = t
    return objs, conteo


def risco_escalon(mats, zona=1, semilla=11):
    """Las mallas del Risco_Escalon de una zona: Risco, Tapa y (si tiene) Detalle. La zona 1
    usa la misma semilla de antes, así queda igual a la aprobada."""
    rng = random.Random(semilla + (zona - 1) * 101)
    estilo = ZONAS[zona]["estilo"]
    medio = LARGO / 2
    fondo = medio
    risco, pasto, detalle = Malla(), Malla(), Malla()
    for i, (y, alto) in enumerate(zip(ESCALONES_Y, ALTOS)):
        y_sig = ESCALONES_Y[i + 1] if i + 1 < len(ESCALONES_Y) else fondo
        z0 = 0 if i == 0 else ALTOS[i - 1] + PASTO
        ladrillos(risco, y, z0, alto, i)
        # costados del escalón (tapan la pieza sola; entre dos piezas quedan juntos y no se ven)
        for signo in (-1, 1):
            risco.rect(0, signo, signo * medio, (y, y_sig), (0, alto))
        # franja de pasto: arriba, adelante, abajo del vuelo, costados y (el último) atrás
        caras = "xXyZ" + ("Y" if i + 1 == len(ESCALONES_Y) else "")
        pasto.caja((-medio, medio), (y - VUELO, y_sig), (alto, alto + PASTO), caras=caras)
        pasto.rect(2, -1, alto, (-medio, medio), (y - VUELO, y))
        colgantes(pasto, detalle, rng, estilo, y, alto)
        encima(pasto, detalle, rng, estilo, alto + PASTO, y - VUELO + 0.3, y_sig - 0.6)
    # fondo y base
    risco.rect(1, 1, fondo, (0, ALTOS[-1]), (-medio, medio))
    risco.rect(2, -1, 0, (-medio, medio), (-fondo, fondo))
    piezas = [("Risco", risco, mats["risco"]), ("Tapa", pasto, mats["tapa"]), ("Detalle", detalle, mats["detalle"])]
    return mallas(piezas, 6000, "Risco_Escalon")


def pared_ladrillo(mats, zona=1, semilla=23):
    """Las mallas de la Pared_Ladrillo de una zona: Pared, Tapa y (si tiene) Detalle. La pared
    tiene ladrillos de los dos lados; la tapa sale VUELO para cada lado y le cuelga lo de la zona
    de los dos lados. Entre todas las mallas no pasan de MAX_PARED triángulos."""
    rng = random.Random(semilla + (zona - 1) * 101)
    estilo = ZONAS[zona]["estilo"]
    medio, e = LARGO / 2, PARED_ESPESOR / 2
    pared, tapa, detalle = Malla(), Malla(), Malla()
    ladrillos(pared, -e, 0, PARED_ALTO, 0, -1)
    ladrillos(pared, e, 0, PARED_ALTO, 1, 1)
    for signo in (-1, 1):
        pared.rect(0, signo, signo * medio, (-e, e), (0, PARED_ALTO))  # puntas (tapadas entre tramos)
    pared.rect(2, -1, 0, (-medio, medio), (-e, e))
    arriba = PARED_ALTO + PARED_TAPA
    tapa.caja((-medio, medio), (-e - VUELO, e + VUELO), (PARED_ALTO, arriba), caras="xXyYZ")
    for y0, y1 in ((-e - VUELO, -e), (e, e + VUELO)):
        tapa.rect(2, -1, PARED_ALTO, (-medio, medio), (y0, y1))
    colgantes(tapa, detalle, rng, estilo, -e, PARED_ALTO, -1)
    colgantes(tapa, detalle, rng, estilo, e, PARED_ALTO, 1)
    encima(tapa, detalle, rng, estilo, arriba, -e - VUELO + 0.3, e + VUELO - 0.3)
    piezas = [("Pared", pared, mats["risco"]), ("Tapa", tapa, mats["tapa"]), ("Detalle", detalle, mats["detalle"])]
    objs, conteo = mallas(piezas, MAX_PARED, "Pared_Ladrillo")
    if sum(conteo.values()) > MAX_PARED:
        raise RuntimeError(f"Pared_Ladrillo: {sum(conteo.values())} triángulos (máximo {MAX_PARED})")
    return objs, conteo


# nombre -> (función, alto total en studs, fondo en studs)
PIEZAS = {
    "Risco_Escalon": (risco_escalon, 30, 16),
    "Pared_Ladrillo": (pared_ladrillo, 24, 4),
}


# --- textura de studs ------------------------------------------------------------------------


def textura_studs(px=256):
    """Studs.png: TEJA x TEJA studs, fondo transparente; cada stud es un círculo con el borde de
    arriba a la izquierda claro y el de abajo a la derecha oscuro (como los studs de Roblox)."""
    import numpy as np

    lado = px // TEJA
    v, u = np.mgrid[0:px, 0:px].astype(np.float32) + 0.5
    cu, cv = (u % lado) - lado / 2, (v % lado) - lado / 2
    r = np.hypot(cu, cv) / lado
    luz = (cu * -0.7 + cv * 0.7) / (lado / 2)  # v crece hacia arriba en la imagen de Blender
    img = np.zeros((px, px, 4), dtype=np.float32)
    aro = (r > 0.25) & (r < 0.33)
    adentro = r <= 0.25
    claro = aro & (luz > 0)
    oscuro = aro & (luz <= 0)
    img[claro] = (1, 1, 1, 0.35)
    img[oscuro] = (0, 0, 0, 0.28)
    img[adentro] = (1, 1, 1, 0.07)
    imagen = bpy.data.images.new("Studs", px, px, alpha=True)
    imagen.pixels.foreach_set(img.ravel())
    imagen.filepath_raw = str(M.TEXTURAS / "Studs.png")
    imagen.file_format = "PNG"
    imagen.save()
    return imagen


def material_studs(nombre, color, studs):
    """Para el render: color plano con la textura de studs encima (como la ve Roblox)."""
    m = M.material(nombre, color, rugoso=0.7)
    nodos, enlaces = m.node_tree.nodes, m.node_tree.links
    tex = nodos.new("ShaderNodeTexImage")
    tex.image = studs
    tex.interpolation = "Closest"
    mezcla = nodos.new("ShaderNodeMix")
    mezcla.data_type = "RGBA"
    mezcla.inputs["A"].default_value = (*M.hex_a_rgb(color), 1)
    enlaces.new(tex.outputs["Alpha"], mezcla.inputs["Factor"])
    enlaces.new(tex.outputs["Color"], mezcla.inputs["B"])
    enlaces.new(mezcla.outputs["Result"], nodos["Principled BSDF"].inputs["Base Color"])
    return m


def mats_render(studs, zona=1):
    z = ZONAS[zona]
    mats = {
        "risco": material_studs(f"Risco{zona}", z["risco"], studs),
        "tapa": material_studs(f"Tapa{zona}", z["tapa"], studs),
        "detalle": None,
    }
    if z["detalle"]:
        if z["neon"]:
            mats["detalle"] = M.material(f"Detalle{zona}", z["detalle"], brillo=z["detalle"], fuerza_brillo=1.2)
        else:
            mats["detalle"] = material_studs(f"Detalle{zona}", z["detalle"], studs)
    return mats


def mats_export(zona):
    """Sin textura (el juego pone el color y TextureID = Studs.png); el nombre dice la zona."""
    z = ZONAS[zona]
    mats = {"risco": M.material(f"Risco_Zona{zona}", z["risco"]), "tapa": M.material(f"Tapa_Zona{zona}", z["tapa"])}
    mats["detalle"] = M.material(f"Detalle_Zona{zona}", z["detalle"]) if z["detalle"] else None
    return mats


# --- render y exportación --------------------------------------------------------------------


def camara_orto(escena, centro, ancho, elevacion, giro):
    cam = bpy.data.cameras.new("Camara")
    cam.type = "ORTHO"
    cam.ortho_scale = ancho
    obj = bpy.data.objects.new("Camara", cam)
    escena.collection.objects.link(obj)
    e, g = math.radians(elevacion), math.radians(giro)
    d = 60
    obj.location = (
        centro[0] + d * math.cos(e) * math.sin(g),
        centro[1] - d * math.cos(e) * math.cos(g),
        centro[2] + d * math.sin(e),
    )
    obj.rotation_euler = (math.pi / 2 - e, 0, g)
    escena.camera = obj


# capturas del juego con las que se compara cada pieza (arte/referencias/)
REFERENCIAS = {
    "Risco_Escalon": ("mapa-1.png", "mapa-3.png"),
    "Pared_Ladrillo": ("pared-1.png", "pared-2.png"),
}


def render(pieza):
    """De frente: 3 piezas seguidas (para ver que no se nota la unión). De costado: una sola.
    Después, las dos al lado de las referencias."""
    crear, alto, _ = PIEZAS[pieza]
    alto *= M.STUD
    archivo = pieza.lower()
    conteo = {}
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        mats = mats_render(textura_studs())
        copias = (-1, 0, 1) if vista == "frente" else (0,)
        for k in copias:
            objs, conteo = crear(mats)
            M.mover(objs, k * LARGO * M.STUD)
        if vista == "frente":
            camara_orto(escena, (0, 0, alto / 2), max(3 * LARGO * M.STUD, alto * 16 / 9) * 1.35, 16, 0)
        else:
            camara_orto(escena, (0, 0, alto / 2), alto * 2.1, 10, 68)
        M.render(f"{archivo}_{vista}")
    comparar(pieza)
    print("TRIANGULOS", pieza, conteo, "total", sum(conteo.values()))


def render_zonas():
    """deco_zonas.jpg: arriba los 5 Risco_Escalon, abajo las 5 Pared_Ladrillo (zona 1 a 5, de
    izquierda a derecha), vistos de tres cuartos. Lo de Neon brilla, como en el juego."""
    import numpy as np

    paso = (LARGO + 6) * M.STUD
    filas = []
    for pieza in PIEZAS:
        crear, alto, _ = PIEZAS[pieza]
        M.limpiar_escena()
        alto_px = round(2000 * alto * M.STUD * 1.65 / (5 * paso + 1))
        escena = M.escena_render(2000, alto_px)
        studs = textura_studs()
        for zona, z in ZONAS.items():
            objs, conteo = crear(mats_render(studs, zona), zona)
            M.mover(objs, (zona - 3) * paso)
            t = M.etiqueta(f"{zona} {z['nombre']}", (zona - 3) * paso, -LARGO * M.STUD * 0.75, tam=0.6, color="#1B1F3B")
            t.rotation_euler.x = math.radians(70)
            print("TRIANGULOS", pieza, f"zona {zona}", conteo, "total", sum(conteo.values()))
        camara_orto(escena, (0, -1, alto * M.STUD * 0.62), 5 * paso + 1, 14, -18)
        M.render(f"deco_zonas_{pieza.lower()}")
        filas.append(cargar(M.RENDERS / f"deco_zonas_{pieza.lower()}.jpg", 2000, alto_px))
    # en Blender la fila 0 es la de abajo: la pared primero
    junto = np.concatenate([filas[1], np.ones((12, 2000, 4), dtype=np.float32), filas[0]], axis=0)
    salida = bpy.data.images.new("zonas", junto.shape[1], junto.shape[0])
    salida.pixels.foreach_set(junto.ravel())
    salida.filepath_raw = str(M.RENDERS / "deco_zonas.jpg")
    salida.file_format = "JPEG"
    salida.save()
    print("  Render deco_zonas.jpg")


def cargar(ruta, ancho, alto):
    import numpy as np

    img = bpy.data.images.load(str(ruta))
    w, h = img.size
    px = np.empty(w * h * 4, dtype=np.float32)
    img.pixels.foreach_get(px)
    px = px.reshape(h, w, 4)
    # recorte al centro con la proporción pedida y escala sencilla (vecino más cercano)
    if w / h > ancho / alto:
        nw = round(h * ancho / alto)
        px = px[:, (w - nw) // 2 : (w - nw) // 2 + nw]
    else:
        nh = round(w * alto / ancho)
        px = px[(h - nh) // 2 : (h - nh) // 2 + nh]
    fy = (np.arange(alto) * px.shape[0] / alto).astype(int)
    fx = (np.arange(ancho) * px.shape[1] / ancho).astype(int)
    return px[fy][:, fx]


def comparar(pieza):
    """<pieza>_vs_referencia.jpg: arriba las capturas del juego, abajo frente y costado."""
    import numpy as np

    w, h = 960, 540
    ref = M.ARTE / "referencias"
    archivo = pieza.lower()
    cuadros = [
        *(cargar(ref / r, w, h) for r in REFERENCIAS[pieza]),
        cargar(M.RENDERS / f"{archivo}_frente.jpg", w, h),
        cargar(M.RENDERS / f"{archivo}_costado.jpg", w, h),
    ]
    blanco_v = np.ones((h, 12, 4), dtype=np.float32)
    # en Blender la fila 0 es la de abajo: los renders van primero
    abajo = np.concatenate([cuadros[2], blanco_v, cuadros[3]], axis=1)
    arriba = np.concatenate([cuadros[0], blanco_v, cuadros[1]], axis=1)
    junto = np.concatenate([abajo, np.ones((12, abajo.shape[1], 4), dtype=np.float32), arriba], axis=0)
    salida = bpy.data.images.new("comparacion", junto.shape[1], junto.shape[0])
    salida.pixels.foreach_set(junto.ravel())
    salida.filepath_raw = str(M.RENDERS / f"{archivo}_vs_referencia.jpg")
    salida.file_format = "JPEG"
    salida.save()
    print(f"  Render {archivo}_vs_referencia.jpg")


def exportar():
    """Deco_Comun.fbx: Zona1..Zona5, cada una con un vacío por pieza (Risco_Escalon_Zona2...) y
    sus mallas (Risco_Zona2, Risco_Tapa_Zona2, Pared_Detalle_Zona2...), sin textura: el juego
    pone el color y TextureID = Studs.png."""
    M.limpiar_escena()
    raiz = bpy.data.objects.new("Deco_Comun", None)
    bpy.context.scene.collection.objects.link(raiz)
    for zona in ZONAS:
        carpeta = bpy.data.objects.new(f"Zona{zona}", None)
        bpy.context.scene.collection.objects.link(carpeta)
        carpeta.parent = raiz
        for nombre, (crear, _, _) in PIEZAS.items():
            vacio = bpy.data.objects.new(f"{nombre}_Zona{zona}", None)  # nombres únicos (si no, Blender pone .001)
            bpy.context.scene.collection.objects.link(vacio)
            vacio.parent = carpeta
            objs, _ = crear(mats_export(zona), zona)
            for o in objs:
                o.parent = vacio
                malla, pieza = o.name.split(".")[0], nombre.split("_")[0]
                # Risco_Zona2, Risco_Tapa_Zona2, Pared_Detalle_Zona2...
                o.name = o.data.name = f"{malla if malla == pieza else pieza + '_' + malla}_Zona{zona}"
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Deco_Comun.fbx"),
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
    print("  FBX Deco_Comun.fbx")


if __name__ == "__main__":
    if "--exportar" in sys.argv:
        M.FBX.mkdir(parents=True, exist_ok=True)
        exportar()
    # --pieza <Nombre>: solo esa (si no, todas)
    elegidas = [sys.argv[sys.argv.index("--pieza") + 1]] if "--pieza" in sys.argv else list(PIEZAS)
    if "--zonas" in sys.argv:
        render_zonas()
        elegidas = []
    for pieza in elegidas:
        render(pieza)
    print("Listo")
