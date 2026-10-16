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
  Losas_Piedra   montoncito de 2 o 3 losas planas de piedra apiladas un poco corridas
                 (escombros), en tres tamaños por zona: Chica (2 losas), Mediana y Larga (3). Cada
                 losa es un bloque entero (arriba lisa, con studs) y los costados tienen hiladas de
                 ladrillo con juntas finitas. Mallas Piedra y (si la zona tiene) Detalle: musgo,
                 arena, nieve, grietas de lava o cristales (arte/referencias/losas-*.png).
  Nube_Bloques   nube blanca de cubos grandes (4 studs) apilados, plana abajo y con bultos arriba,
                 en tres tamaños: Chica (24 x 16 studs), Mediana (40 x 24) y Grande (56 x 32).
  Arcoiris       medio arco de bloques en escalera (60 studs de ancho, 30 de alto) con las 6
                 franjas (rojo afuera, violeta adentro), una malla por franja, y una nube de
                 bloques en cada punta (malla Nube). Las dos piezas del cielo son las mismas para
                 todas las zonas (arte/referencias/cielo-*.png).

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
#   neon: el Detalle brilla (en Roblox, Material Neon). La lava del Volcán (Detalle de la zona 4,
#   también en las losas) no va Neon: lleva TextureID = texturas/LavaLiquida.png, que ya brilla.
#   estilo: pasto (gotitas), arena (dunas arriba, chorritos anchos), nieve (montoncitos y
#   carámbanos), ceniza (piedritas arriba y ríos de lava líquida), estelar (cristales arriba)
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

# Losas_Piedra, en studs: losas planas apiladas un poco corridas (escombros). Cada losa es
# (x0, x1, y0, y1); van una encima de la otra, de abajo para arriba. Las zonas pares las usan
# espejadas, así no se repiten igual entre zonas.
LOSA_ALTO = 2  # grosor de cada losa (2 hiladas de ladrillo de 1)
LOSA_LADRILLO = 4  # largo de cada ladrillo de los costados
LOSA_RELIEVE = 0.12  # cuánto salen los ladrillos del bloque de la losa
LOSA_JUNTA = 0.1  # junta finita entre ladrillos
MAX_LOSAS = 1500  # por pieza (sumando sus mallas)
LOSAS = {
    "Chica": [(-4, 4, -3, 3), (-3.5, 3, -2.5, 2.5)],
    "Mediana": [(-5, 5, -4, 4), (-4.5, 4.5, -3.5, 3.5), (-3.5, 2.5, -3, 2.5)],
    "Larga": [(-8, 8, -3, 3), (-7.5, 7, -2.5, 2.5), (-5, 3, -2.5, 2)],
}
# Colores de cada zona: piedra y detalle (neon = el detalle brilla)
LOSAS_ZONAS = {
    1: {"piedra": "#686C8A", "detalle": "#3DB02A", "neon": False, "estilo": "musgo"},
    2: {"piedra": "#B08A5E", "detalle": "#F2D27A", "neon": False, "estilo": "arena"},
    3: {"piedra": "#7F95B5", "detalle": "#F4FAFF", "neon": False, "estilo": "nieve"},
    4: {"piedra": "#3A2E33", "detalle": "#FF5A00", "neon": True, "estilo": "lava"},
    5: {"piedra": "#3B3570", "detalle": "#7CF5FF", "neon": True, "estilo": "cristal"},
}

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


def chorro_lava(det, rng, c, plano, signo, z_arriba, z_fin, charco, ancho0=None):
    """Chorro de lava líquida que baja por la pared (el plano y = plano, mirando a signo) desde
    z_arriba hasta z_fin: tramos de 1 stud que se van angostando y ondulando. Termina en un charco
    que se desparrama (charco=True) o en una gota gorda colgando. Devuelve el ancho de arriba."""
    grueso = 0.3
    capa = (plano - grueso, plano) if signo < 0 else (plano, plano + grueso)
    frente = "y" if signo < 0 else "Y"
    ancho0 = ancho0 or rng.choice((2, 2.5))
    fase = rng.uniform(0, 6.3)
    z, k, ancho = z_arriba, 0, ancho0
    while z > z_fin + 1e-6:
        z0 = max(z_fin, z - 1)
        ancho = max(1.2, ancho0 - 0.15 * k + 0.35 * math.sin(k * 1.7 + fase))
        det.caja((c - ancho / 2, c + ancho / 2), capa, (z0, z), caras=frente + "xXz")
        z, k = z0, k + 1
    if charco:  # se desparrama en el piso de abajo
        lejos = (plano - 1.6, plano) if signo < 0 else (plano, plano + 1.6)
        det.caja((c - ancho / 2 - 1, c + ancho / 2 + 1), lejos, (z_fin, z_fin + 0.15), caras="xXyYZ")
        cerca = (plano - 0.9, plano) if signo < 0 else (plano, plano + 0.9)
        det.caja((c - ancho / 2 - 0.3, c + ancho / 2 + 0.3), cerca, (z_fin + 0.15, z_fin + 0.3), caras="xXyYZ")
    else:  # gota gorda en la punta
        gota = (plano - grueso - 0.1, plano) if signo < 0 else (plano, plano + grueso + 0.1)
        det.caja((c - ancho / 2 - 0.25, c + ancho / 2 + 0.25), gota, (z_fin - 0.8, z_fin), caras=frente + "xXzZ")
    return ancho0


def rio_de_lava(det, rng, c, y, signo, alto, tope, bajo):
    """Lava que se junta arriba de la tapa, se derrama por el borde y baja por los ladrillos (ver
    chorro_lava). Con bajo (el piso del escalón de abajo) a veces llega y hace un charco."""
    ancho0 = rng.choice((2, 2.5))
    s = signo
    adentro = (y - VUELO, y - VUELO + 1.6) if s < 0 else (y + VUELO - 1.6, y + VUELO)
    borde = (y - VUELO - 0.15, y - VUELO) if s < 0 else (y + VUELO, y + VUELO + 0.15)
    frente = "y" if s < 0 else "Y"
    # charquito arriba de la tapa y el derrame por el borde (tapa el frente del vuelo)
    det.caja((c - ancho0 / 2 - 0.5, c + ancho0 / 2 + 0.5), adentro, (tope, tope + 0.12), caras="xXyYZ")
    det.caja((c - ancho0 / 2, c + ancho0 / 2), borde, (alto - 0.4, tope + 0.12), caras=frente + "xXzZ")
    charco = bajo is not None and bajo > 0 and rng.random() < 0.75
    fin = bajo if charco else max((bajo or 0) + 1, alto - rng.choice((3, 4, 5)))
    plano = y - RELIEVE if s < 0 else y + RELIEVE
    chorro_lava(det, rng, c, plano, s, alto - 0.4, fin, charco, ancho0)


def colgantes(tapa, detalle, rng, estilo, y, alto, signo=-1, tope=None, bajo=None):
    """Lo que cuelga del vuelo de la tapa, delante de la pared en el plano y (lejos de los bordes,
    así no cortan la unión): gotitas de pasto, chorritos de arena, nieve y carámbanos, o ríos de
    lava (tope: arriba de la tapa; bajo: el piso de abajo, donde la lava puede hacer charco)."""
    medio = LARGO / 2
    fondo = (y - VUELO, y - RELIEVE - 0.05) if signo < 0 else (y + RELIEVE + 0.05, y + VUELO)
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
            ancho = 2
            if rng.random() < 0.6:  # río de lava líquida
                rio_de_lava(detalle, rng, x + 1.5, y, signo, alto, tope, bajo)
                ancho = 3
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
        colgantes(pasto, detalle, rng, estilo, y, alto, -1, alto + PASTO, z0)
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
    colgantes(tapa, detalle, rng, estilo, -e, PARED_ALTO, -1, PARED_ALTO + PARED_TAPA)
    colgantes(tapa, detalle, rng, estilo, e, PARED_ALTO, 1, PARED_ALTO + PARED_TAPA)
    encima(tapa, detalle, rng, estilo, arriba, -e - VUELO + 0.3, e + VUELO - 0.3)
    piezas = [("Pared", pared, mats["risco"]), ("Tapa", tapa, mats["tapa"]), ("Detalle", detalle, mats["detalle"])]
    objs, conteo = mallas(piezas, MAX_PARED, "Pared_Ladrillo")
    if sum(conteo.values()) > MAX_PARED:
        raise RuntimeError(f"Pared_Ladrillo: {sum(conteo.values())} triángulos (máximo {MAX_PARED})")
    return objs, conteo


def hiladas(m, eje, signo, fijo, r0, r1, z0, abajo, corrido):
    """Ladrillos (plaquitas de LOSA_RELIEVE) sobre un costado de la losa: el plano eje = fijo,
    mirando a signo, de r0 a r1 a lo largo del costado, dos hiladas de 1 de alto."""
    j = LOSA_JUNTA / 2
    afuera = (fijo, fijo + LOSA_RELIEVE) if signo > 0 else (fijo - LOSA_RELIEVE, fijo)
    for fila in range(round(LOSA_ALTO)):
        za, zb = z0 + fila + j, z0 + fila + 1 - j
        if fila == 0 and abajo:
            za = z0  # la hilada de abajo de todo apoya en el piso
        r = r0 - (LOSA_LADRILLO / 2 if (fila + corrido) % 2 else 0)
        while r < r1 - 1e-6:
            ra, rb = max(r, r0) + j, min(r + LOSA_LADRILLO, r1) - j
            if rb - ra > 0.5:
                letra = "xX"[signo > 0] if eje == 0 else "yY"[signo > 0]
                lados = "yY" if eje == 0 else "xX"
                caras = letra + lados + "Z" + ("" if za == z0 and abajo else "z")
                if eje == 0:
                    m.caja(afuera, (ra, rb), (za, zb), caras=caras)
                else:
                    m.caja((ra, rb), afuera, (za, zb), caras=caras)
            r += LOSA_LADRILLO


def adorno(det, rng, estilo, x0, x1, y0, y1, z, grande):
    """Detalle de la zona sobre la parte de arriba (x0..x1, y0..y1) a la altura z. grande: la
    losa de arriba de todo (lleva más); si no, es el borde libre de una losa de abajo."""
    w, d = x1 - x0, y1 - y0
    if w < 1 or d < 1:
        return
    caras = "xXyYZ"

    def lugar(a, b):
        a, b = min(a, w), min(b, d)
        xa, ya = rng.uniform(x0, x1 - a), rng.uniform(y0, y1 - b)
        return (xa, xa + a), (ya, ya + b)

    if estilo == "musgo":
        for k in range(3 if grande else 1):  # alturas distintas: si se pisan, no se mezclan
            rx, ry = lugar(rng.choice((1.5, 2, 3)), rng.choice((1, 1.5, 2)))
            det.caja(rx, ry, (z, z + 0.2 + 0.08 * k), caras=caras)
    elif estilo == "arena":
        if grande:
            rx, ry = lugar(rng.choice((3, 4)), rng.choice((2.5, 3)))
            det.caja(rx, ry, (z, z + 0.5), caras=caras)
            det.caja((rx[0] + 0.75, rx[1] - 0.75), (ry[0] + 0.6, ry[1] - 0.6), (z + 0.5, z + 1), caras=caras)
        else:
            rx, ry = lugar(2, 1.5)
            det.caja(rx, ry, (z, z + 0.5), caras=caras)
    elif estilo == "nieve":
        if grande:  # capa que tapa toda la losa de arriba, con un montoncito
            det.caja((x0 - 0.15, x1 + 0.15), (y0 - 0.15, y1 + 0.15), (z, z + 0.4), caras="xXyYzZ")
            rx, ry = lugar(2, 1.5)
            det.caja(rx, ry, (z + 0.4, z + 0.9), caras=caras)
        else:
            rx, ry = lugar(w, min(d, 1.5))
            det.caja(rx, ry, (z, z + 0.3), caras=caras)
    elif estilo == "cristal":
        rx, ry = lugar(1.6, 1.6)
        piezas = ((0, 0, 0.8, 2.2), (0.8, 0.3, 0.6, 1.4), (0.2, 0.9, 0.5, 1)) if grande else ((0, 0, 0.6, 1.2),)
        for dx, dy, a, h in piezas:
            h *= rng.choice((0.8, 1, 1.2))
            det.caja((rx[0] + dx, rx[0] + dx + a), (ry[0] + dy, ry[0] + dy + a), (z, z + h), caras=caras)


def lava_losas(det, rng, losas):
    """Lava de las losas del Volcán: un charco arriba de la losa de más arriba que se derrama por
    el frente (y-) y baja por cada losa; en cada escalón se junta en un charquito y sigue, y al
    llegar abajo queda colgando una gota (no se sale de la base)."""
    tx0, tx1, ty0, _ = losas[-1]
    ancho0 = 2
    c = rng.uniform(tx0 + 1.8, tx1 - 1.8)
    ztop = len(losas) * LOSA_ALTO
    # charco arriba y derrame por el borde
    det.caja((c - 1.6, c + 1.6), (ty0, ty0 + 2.2), (ztop, ztop + 0.12), caras="xXyYZ")
    det.caja((c - 0.7, c + 1.9), (ty0 + 1.2, ty0 + 3), (ztop, ztop + 0.12), caras="xXyYZ")
    det.caja((c - ancho0 / 2, c + ancho0 / 2), (ty0 - LOSA_RELIEVE - 0.15, ty0), (ztop - 0.4, ztop + 0.12), caras="yxXzZ")
    for i in range(len(losas) - 1, -1, -1):
        y0 = losas[i][2]
        plano = y0 - LOSA_RELIEVE
        z0, z1 = i * LOSA_ALTO, (i + 1) * LOSA_ALTO
        arriba = z1 - 0.4 if i == len(losas) - 1 else z1
        if i == 0:
            chorro_lava(det, rng, c, plano, -1, arriba, 0.9, False, ancho0)
        else:
            chorro_lava(det, rng, c, plano, -1, arriba, z0, False, ancho0)
            # charquito en el escalón de abajo (si sobresale) que une con el chorro siguiente
            y_abajo = losas[i - 1][2] - LOSA_RELIEVE
            if plano - 0.3 - y_abajo > 0.05:
                det.caja((c - ancho0 / 2 - 0.6, c + ancho0 / 2 + 0.6), (y_abajo - 0.15, plano - 0.3), (z0, z0 + 0.15), caras="xXyYZ")


def losas_piedra(mats, tam, zona=1):
    """El montoncito de losas de un tamaño (Chica, Mediana o Larga) para una zona: mallas Piedra
    y (si la zona tiene) Detalle. Cada losa es un bloque entero (arriba lisa, así se lee como
    una sola piedra) con hiladas de ladrillo en los costados. Pivote en el centro de la base."""
    rng = random.Random(f"{tam}{zona}")
    espejo = -1 if zona % 2 == 0 else 1
    losas = [(min(espejo * a, espejo * b), max(espejo * a, espejo * b), y0, y1) for a, b, y0, y1 in LOSAS[tam]]
    # centrar: el centro de lo que ocupa el montón queda en x = 0, y = 0
    cx = (min(l[0] for l in losas) + max(l[1] for l in losas)) / 2
    cy = (min(l[2] for l in losas) + max(l[3] for l in losas)) / 2
    losas = [(x0 - cx, x1 - cx, y0 - cy, y1 - cy) for x0, x1, y0, y1 in losas]
    estilo = LOSAS_ZONAS[zona]["estilo"]
    piedra, det = Malla(), Malla()
    for i, (x0, x1, y0, y1) in enumerate(losas):
        z0, z1 = i * LOSA_ALTO, (i + 1) * LOSA_ALTO
        abajo = i == 0
        # el bloque de la losa (arriba entero) y los ladrillos de los 4 costados
        # (sin base: la de abajo apoya en el piso y las demás apoyan enteras sobre la anterior)
        piedra.caja((x0, x1), (y0, y1), (z0, z1), caras="xXyYZ")
        hiladas(piedra, 0, -1, x0, y0, y1, z0, abajo, i)
        hiladas(piedra, 0, 1, x1, y0, y1, z0, abajo, i + 1)
        hiladas(piedra, 1, -1, y0, x0, x1, z0, abajo, i + 1)
        hiladas(piedra, 1, 1, y1, x0, x1, z0, abajo, i)
        if i + 1 < len(losas):
            # borde libre más ancho de esta losa (lo que no tapa la de arriba)
            ux0, ux1, uy0, uy1 = losas[i + 1]
            bordes = [(x0, ux0, y0, y1), (ux1, x1, y0, y1), (x0, x1, y0, uy0), (x0, x1, uy1, y1)]
            bx0, bx1, by0, by1 = max(bordes, key=lambda b: min(b[1] - b[0], b[3] - b[2]))
            adorno(det, rng, estilo, bx0 + 0.2, bx1 - 0.2, by0 + 0.2, by1 - 0.2, z1, False)
        else:
            adorno(det, rng, estilo, x0 + 0.3, x1 - 0.3, y0 + 0.3, y1 - 0.3, z1, True)
    if estilo == "lava":
        lava_losas(det, rng, losas)
    nombre = f"Losas_{tam}"
    objs, conteo = mallas([("Piedra", piedra, mats["piedra"]), ("Detalle", det, mats["detalle"])], MAX_LOSAS, nombre)
    if sum(conteo.values()) > MAX_LOSAS:
        raise RuntimeError(f"{nombre} zona {zona}: {sum(conteo.values())} triángulos (máximo {MAX_LOSAS})")
    return objs, conteo


def mats_losas(zona, studs=None):
    """Materiales de las losas de una zona; con studs, para el render (y lo Neon brilla)."""
    z = LOSAS_ZONAS[zona]
    if studs is None:
        return {"piedra": M.material(f"Losas_Zona{zona}", z["piedra"]), "detalle": M.material(f"Losas_Detalle_Zona{zona}", z["detalle"])}
    if z["estilo"] == "lava":
        det = material_lava(f"LDet{zona}")
    elif z["neon"]:
        det = M.material(f"LDet{zona}", z["detalle"], brillo=z["detalle"], fuerza_brillo=1.2)
    else:
        det = material_studs(f"LDet{zona}", z["detalle"], studs)
    return {"piedra": material_studs(f"Losas{zona}", z["piedra"], studs), "detalle": det}


# --- cielo: nubes y arcoíris --------------------------------------------------------------------

COLOR_NUBE = "#F4F6FF"
NUBE_CUBO = 4  # studs de cada cubo de la nube
# tamaño -> (radio en x, radio en y, cantidad de bultos), en cubos
NUBES = {"Chica": (3, 2, 2), "Mediana": (5, 3, 3), "Grande": (7, 4, 4)}
MAX_CIELO = {"Nube_Bloques": 1500, "Arcoiris": 3000}
ARCO_CUBO = (2, 3, 2)  # studs de cada bloque del arcoíris (x, fondo, alto)
ARCO_RADIO = 30  # radio de afuera, en studs
ARCO_FRANJAS = [  # de afuera para adentro, 1 bloque (2 studs) cada una
    ("Rojo", "#FF4D4D"),
    ("Naranja", "#FF9A3C"),
    ("Amarillo", "#FFE14D"),
    ("Verde", "#5BD45B"),
    ("Azul", "#3FA9FF"),
    ("Violeta", "#B04DFF"),
]


def voxeles_malla(m, celdas, tam, origen=(0, 0, 0)):
    """Agrega a la Malla m las caras de afuera de las celdas (x, y, z enteros; cada una mide tam
    studs y la celda 0 empieza en origen). Las caras vecinas que miran para el mismo lado se
    juntan en tiras (menos triángulos)."""
    for eje in range(3):
        for signo in (-1, 1):
            vecino = [0, 0, 0]
            vecino[eje] = signo
            caras = [c for c in celdas if (c[0] + vecino[0], c[1] + vecino[1], c[2] + vecino[2]) not in celdas]
            a, b = Malla.EJES[eje]
            tira = 0 if eje != 0 else 2  # se juntan a lo largo de x (o de z en las caras de x)
            otro = b if tira == a else a
            grupos = {}
            for c in caras:
                grupos.setdefault((c[eje], c[otro]), []).append(c[tira])
            for (fijo, o), lista in grupos.items():
                lista.sort()
                ini = prev = lista[0]
                for v in lista[1:] + [None]:
                    if v is not None and v == prev + 1:
                        prev = v
                        continue
                    r = {tira: (ini, prev + 1), otro: (o, o + 1)}
                    rango = {k: (origen[k] + r[k][0] * tam[k], origen[k] + r[k][1] * tam[k]) for k in r}
                    plano = origen[eje] + (fijo + (1 if signo > 0 else 0)) * tam[eje]
                    m.rect(eje, signo, plano, rango[a], rango[b])
                    if v is not None:
                        ini = prev = v


def celdas_nube(rx, ry, bultos, semilla, dx=0):
    """Celdas de una nube: una base chata (elipse de rx x ry cubos, 1 de alto) y bultos redondos
    arriba, sin salirse de la base (abajo queda plana). dx corre la nube en x (en cubos)."""
    rng = random.Random(semilla)
    base = set()
    for x in range(-rx, rx):
        for y in range(-ry, ry):
            if ((x + 0.5) / rx) ** 2 + ((y + 0.5) / ry) ** 2 <= 1.05:
                base.add((x, y))
    celdas = {(x + dx, y, 0) for x, y in base}
    # segundo piso un poco más angosto: redondea el borde
    for x, y in base:
        if ((x + 0.5) / (rx - 0.8)) ** 2 + ((y + 0.5) / max(1, ry - 0.6)) ** 2 <= 1:
            celdas.add((x + dx, y, 1))
    escala = 1 + (rx - 3) / 8
    for k in range(bultos):
        cx = -rx * 0.55 + (2 * rx * 0.55) * (k / max(1, bultos - 1)) if bultos > 1 else 0
        cx += rng.uniform(-0.6, 0.6)
        cy = rng.uniform(-ry * 0.25, ry * 0.25)
        radio = rng.uniform(1.9, 2.4) * escala
        if k in (bultos // 2, (bultos - 1) // 2):
            radio += 0.7  # el del medio más alto
        for x, y in base:
            for z in range(1, int(radio) + 3):
                if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 + (z - 0.2) ** 2 <= radio * radio:
                    celdas.add((x + dx, y, z))
    return celdas


def nube_bloques(mats, tam):
    """Una nube (malla Nube_<tam>), pivote en el centro de la base."""
    rx, ry, bultos = NUBES[tam]
    m = Malla()
    voxeles_malla(m, celdas_nube(rx, ry, bultos, f"nube{tam}"), (NUBE_CUBO,) * 3)
    return mallas([(f"Nube_{tam}", m, mats["nube"])], MAX_CIELO["Nube_Bloques"], f"Nube_Bloques {tam}")


def arcoiris(mats):
    """Medio arco en escalera (una malla por franja) y una nube en cada punta (malla Nube),
    parados en el piso; pivote en el centro de la base."""
    sx, sy, sz = ARCO_CUBO
    franjas = [set() for _ in ARCO_FRANJAS]
    n = ARCO_RADIO // sx
    for i in range(-n, n):
        for k in range(1, ARCO_RADIO // sz):  # la fila de abajo queda adentro de las nubes
            r = math.hypot((i + 0.5) * sx, (k + 0.5) * sz)
            f = int((ARCO_RADIO - r) // sx)
            if 0 <= f < len(ARCO_FRANJAS):
                franjas[f].add((i, 0, k))
    piezas = []
    for (nombre, _), celdas in zip(ARCO_FRANJAS, franjas):
        m = Malla()
        voxeles_malla(m, celdas, ARCO_CUBO, (0, -sy / 2, 0))
        piezas.append((f"Arcoiris_{nombre}", m, mats[nombre]))
    # una nube chica en cada punta, centrada en el pie del arco
    pie = round((ARCO_RADIO - len(ARCO_FRANJAS) * sx / 2) / NUBE_CUBO)
    nube = Malla()
    celdas = celdas_nube(3, 2, 2, "arco1", dx=-pie) | celdas_nube(3, 2, 2, "arco2", dx=pie)
    voxeles_malla(nube, celdas, (NUBE_CUBO,) * 3)
    piezas.append(("Arcoiris_Nube", nube, mats["nube"]))
    objs, conteo = mallas(piezas, MAX_CIELO["Arcoiris"], "Arcoiris")
    if sum(conteo.values()) > MAX_CIELO["Arcoiris"]:
        raise RuntimeError(f"Arcoiris: {sum(conteo.values())} triángulos (máximo {MAX_CIELO['Arcoiris']})")
    return objs, conteo


def mats_cielo(studs=None):
    """Materiales de la nube y de las 6 franjas; con studs, para el render."""
    hacer = (lambda n, c: material_studs(n, c, studs)) if studs else (lambda n, c: M.material(n, c))
    mats = {nombre: hacer(f"Arcoiris_{nombre}", color) for nombre, color in ARCO_FRANJAS}
    mats["nube"] = hacer("Nube", COLOR_NUBE)
    return mats


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


def textura_lava(px=256):
    """LavaLiquida.png: lava derretida que se repite sin costura (TEJA x TEJA studs): manchas
    naranjas y rojas con vetas amarillas brillantes entre ellas (como la lava de las capturas)."""
    import numpy as np

    rng = np.random.default_rng(7)
    puntos = rng.uniform(0, px, (14, 2))
    v, u = np.mgrid[0:px, 0:px].astype(np.float32) + 0.5
    d1 = np.full((px, px), 1e9, dtype=np.float32)
    d2 = np.full((px, px), 1e9, dtype=np.float32)
    for pu, pv in puntos:
        for du in (-px, 0, px):  # copias alrededor: así se repite sin costura
            for dv in (-px, 0, px):
                d = np.hypot(u - pu - du, v - pv - dv)
                d2 = np.where(d < d1, d1, np.minimum(d2, d))
                d1 = np.minimum(d1, d)
    veta = np.clip(1 - (d2 - d1) / 9, 0, 1) ** 1.5  # 1 en el borde entre manchas
    centro = np.clip(d1 / 38, 0, 1)  # 0 en el medio de cada mancha
    rojo, naranja, amarillo = np.array([0.55, 0.06, 0.0]), np.array([1.0, 0.36, 0.0]), np.array([1.0, 0.9, 0.3])
    base = rojo * (1 - centro[..., None]) + naranja * centro[..., None]
    color = base * (1 - veta[..., None]) + amarillo * veta[..., None]
    img = np.ones((px, px, 4), dtype=np.float32)
    img[..., :3] = color
    imagen = bpy.data.images.new("LavaLiquida", px, px)
    imagen.pixels.foreach_set(img.ravel())
    imagen.filepath_raw = str(M.TEXTURAS / "LavaLiquida.png")
    imagen.file_format = "PNG"
    imagen.save()
    return imagen


def material_lava(nombre):
    """Para el render: la textura de lava, que además brilla (en Roblox la textura va en
    TextureID del Detalle; ver ZONAS)."""
    m = M.material(nombre, "#FF5A00", rugoso=0.3)
    nodos, enlaces = m.node_tree.nodes, m.node_tree.links
    tex = nodos.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.get("LavaLiquida") or textura_lava()
    bsdf = nodos["Principled BSDF"]
    enlaces.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    enlaces.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = 1.4
    return m


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
        if z["estilo"] == "ceniza":
            mats["detalle"] = material_lava(f"Detalle{zona}")
        elif z["neon"]:
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
    "Nube_Bloques": ("cielo-1.png", "cielo-2.png"),
    "Arcoiris": ("cielo-1.png", "cielo-2.png"),
    "Losas_Piedra": ("losas-1.png", "losas-2.png"),
    "Risco_Escalon": ("mapa-1.png", "mapa-3.png"),
    "Pared_Ladrillo": ("pared-1.png", "pared-2.png"),
}


def render_cielo(pieza):
    """Nube_Bloques (los 3 tamaños en fila) o Arcoiris, de frente y de costado, al lado de las
    referencias. La cámara mira casi horizontal, con el cielo atrás."""
    conteo = {}
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        for o in [o for o in escena.objects if o.name.startswith("Plane")]:
            bpy.data.objects.remove(o)  # sin el piso: van en el cielo
        bpy.data.lights["Sol"].energy = 2.6  # menos sol: si no, el blanco se quema
        mats = mats_cielo(textura_studs())
        if pieza == "Nube_Bloques":
            x, ancho_total = 0.0, 0.0
            anchos = [2 * NUBES[t][0] * NUBE_CUBO for t in NUBES]
            ancho_total = sum(anchos) + 8 * (len(anchos) - 1)
            x = -ancho_total / 2
            for tam, ancho in zip(NUBES, anchos):
                objs, c = nube_bloques(mats, tam)
                conteo.update(c)
                M.mover(objs, (x + ancho / 2) * M.STUD)
                x += ancho + 8
            alto = 4 * NUBE_CUBO
        else:
            objs, conteo = arcoiris(mats)
            ancho_total, alto = 2 * ARCO_RADIO + 2 * 3 * NUBE_CUBO, ARCO_RADIO
        if vista == "frente":
            camara_orto(escena, (0, 0, alto * M.STUD / 2), ancho_total * M.STUD * 1.08, 10, -22)
        else:
            camara_orto(escena, (0, 0, alto * M.STUD / 2), ancho_total * M.STUD * 1.08, 14, 62)
        M.render(f"{pieza.lower()}_{vista}")
    comparar(pieza)
    print("TRIANGULOS", pieza, conteo, "total", sum(conteo.values()))


def render_losas():
    """Losas_Piedra de la zona 1 (chica, mediana y larga en fila) de frente y de costado, al lado
    de las referencias; y losas_zonas.jpg con las 3 de cada zona (una fila por zona)."""
    import numpy as np

    paso = 18 * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        mats = mats_losas(1, textura_studs())
        for k, tam in enumerate(LOSAS):
            objs, _ = losas_piedra(mats, tam, 1)
            M.mover(objs, (k - 1) * paso if vista == "frente" else 0, 0 if vista == "frente" else (k - 1) * paso)
        giro = -12 if vista == "frente" else 78
        camara_orto(escena, (0, 0, 1.6 * LOSA_ALTO * M.STUD), 3 * paso, 26, giro)
        M.render(f"losas_piedra_{vista}")
    comparar("Losas_Piedra")
    # todas las zonas: una imagen por zona y después juntas, de arriba (zona 1) para abajo
    filas = []
    for zona in LOSAS_ZONAS:
        M.limpiar_escena()
        escena = M.escena_render(1800, 520)
        mats = mats_losas(zona, textura_studs())
        for k, tam in enumerate(LOSAS):
            objs, conteo = losas_piedra(mats, tam, zona)
            M.mover(objs, (k - 1) * paso)
            print("TRIANGULOS Losas", f"zona {zona}", tam, conteo, "total", sum(conteo.values()))
        t = M.etiqueta(f"Zona {zona}", -1.5 * paso - 0.6, -2.2, tam=0.5, color="#1B1F3B")
        t.rotation_euler.x = math.radians(64)
        camara_orto(escena, (0, 0, 1.2 * LOSA_ALTO * M.STUD), 3.2 * paso, 26, -12)
        M.render(f"losas_zona{zona}")
        filas.append(cargar(M.RENDERS / f"losas_zona{zona}.jpg", 1800, 520))
        (M.RENDERS / f"losas_zona{zona}.jpg").unlink()
    blanco = np.ones((10, 1800, 4), dtype=np.float32)
    partes = []
    for fila in reversed(filas):  # en Blender la fila 0 es la de abajo
        partes += [fila, blanco]
    junto = np.concatenate(partes[:-1], axis=0)
    salida = bpy.data.images.new("losas", junto.shape[1], junto.shape[0])
    salida.pixels.foreach_set(junto.ravel())
    salida.filepath_raw = str(M.RENDERS / "losas_zonas.jpg")
    salida.file_format = "JPEG"
    salida.save()
    print("  Render losas_zonas.jpg")

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
    sus mallas (Risco_Zona2, Risco_Tapa_Zona2, Pared_Detalle_Zona2...), y las 3 losas
    (Losas_Chica_Zona2... con Losas_Chica_Piedra_Zona2 y Losas_Chica_Detalle_Zona2); y el cielo,
    igual para todas: Nube_Bloques (Nube_Chica, Nube_Mediana, Nube_Grande) y Arcoiris
    (Arcoiris_Rojo... Arcoiris_Violeta y Arcoiris_Nube). Sin
    textura: el juego pone el color y TextureID = Studs.png."""
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
        for tam in LOSAS:
            vacio = bpy.data.objects.new(f"Losas_{tam}_Zona{zona}", None)
            bpy.context.scene.collection.objects.link(vacio)
            vacio.parent = carpeta
            objs, _ = losas_piedra(mats_losas(zona), tam, zona)
            for o in objs:
                o.parent = vacio
                o.name = o.data.name = f"Losas_{tam}_{o.name.split('.')[0]}_Zona{zona}"
    # el cielo (igual para todas las zonas): Nube_Bloques con Nube_Chica... y Arcoiris
    mats = mats_cielo()
    for nombre, objs in (
        ("Nube_Bloques", [o for tam in NUBES for o in nube_bloques(mats, tam)[0]]),
        ("Arcoiris", arcoiris(mats)[0]),
    ):
        vacio = bpy.data.objects.new(nombre, None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        for o in objs:
            o.parent = vacio
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
    elegidas = [e for e in elegidas if e in PIEZAS]  # las Losas_Piedra van aparte (sin zonas)
    if "--zonas" in sys.argv:
        render_zonas()
        elegidas = []
    for pieza in elegidas:
        render(pieza)
    if "--pieza" not in sys.argv or "Losas_Piedra" in sys.argv:
        render_losas()
    for pieza in ("Nube_Bloques", "Arcoiris"):
        if "--pieza" not in sys.argv or pieza in sys.argv:
            render_cielo(pieza)
    print("Listo")
