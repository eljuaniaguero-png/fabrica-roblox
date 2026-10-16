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
  Columna_Estelar  solo Abismo (zona 5): columna alta de bloques de 2 studs violeta muy oscuro,
                 un poco torcida (cada capa se corre un bloque en una curva suave), con pie ancho
                 y punta angosta, y estrellitas blancas (cruces de cubitos, Neon) pegadas en las
                 paredes. Dos alturas: Alta (44 studs) y Baja (28). Mallas Columna y Estrellas.
  Isla_Flotante  solo Abismo: isla chica de bloques de 2 studs, arriba plana con pasto violeta
                 (con gotitas en el borde) y cristales rosas (Neon); abajo roca oscura en
                 escalones hasta una punta de 2 x 2 bloques. Tres tamaños: Chica (12 studs de
                 ancho), Mediana (20) y Grande (28). Mallas Roca, Pasto y Cristales; pivote en el
                 centro de la punta de abajo.
  Cristales_Abismo solo Abismo: racimo de 6 cristales de cubitos de 1 stud (rosas y violetas,
                 Neon), el del medio recto y los otros inclinados hacia afuera en escalones,
                 saliendo de una roca oscura de bloques de 2 studs (10 x 10 studs de base).
                 Mallas Roca, CristalRosa y CristalVioleta.
  Arbol_Nebuloso solo Abismo: árbol de cajas como los del juego (arte/referencias/arbol-1.png):
                 tronco violeta oscuro en escalones con raíces, losa de sombra abajo de la copa y
                 copa de cajas fucsia y lila encimadas en escalones (32 studs de alto, 31 de
                 ancho), con estrellitas blancas (Neon) cerca de donde se juntan las cajas.
                 Mallas Tronco, Sombra, CopaFucsia, CopaLila y Estrellas.
  Arbol_Grande   Pradera (zona 1): tronco grueso bordó en escalones que se abre en 2 ramas, losa
                 verde oscuro de sombra y copa de 4 cajas verdes corridas en escalones, una que
                 sobresale de costado (14 studs de alto). Mallas Tronco, Sombra y Copa.
  Arbol_Mediano  Pradera: como el grande, con tronco recto y 2 cajas de copa en escalón (9 studs
                 de alto). Mismas mallas.
  Arbol_Rosa     Pradera (va al fondo): el mediano como un cerezo de bloques: tronco marrón rojizo,
                 caja de abajo fucsia y escalón violeta. Mallas Tronco, Sombra, CopaFucsia y
                 CopaVioleta.
  Arbol_Seco     Pradera: tronco de ladrillos marrón violeta con base en escalones y 3 ramas de
                 cajas inclinadas que terminan en punta, sin hojas (16 studs de alto; referencia
                 arte/referencias/arbol-seco-*.png). Malla Tronco.
  Arbusto        Pradera: arbustito de 3 a 5 bloques verdes apilados y corridos (5 studs de
                 alto). Malla Hojas.
  Racimo_Cuarzo  Pradera: 4 cristales de cuarzo violeta (cajas inclinadas con la punta más angosta
                 y clara, Neon suave en Roblox) que salen de una base de losas de piedra gris (9 x 7
                 studs de base, 10 de alto). Mallas Piedra, Cuarzo y CuarzoPunta.
  Cascada_Cristal  Pradera (la pista de la puerta secreta de la zona 1): cascada chica de bloques
                 celestes transparentes que baja en escalera por 3 escalones de risco (con pasto
                 arriba) y cae en una pileta de bloques con espuma blanca (10 x 13 studs de base, 15
                 de alto; la espalda se apoya contra el risco). Mallas Risco, Pasto, Agua y Espuma.
  Piramide       Dunas (zona 2), la montaña del fondo: pirámide de 10 escalones anchos de 3 studs
                 de alto, color arena (el risco de las Dunas), 64 x 64 studs de base y 30 de alto
                 (arte/referencias/mapa-2.png). Malla Piramide.
                 Cada árbol de la Pradera (y el arbusto) tiene 3 variantes (Arbol_Grande_1, _2 y _3...).
  Roca_Meteorito solo Abismo: media bola chata de bloques de 2 studs azul noche, con un cráter
                 arriba (corrido a un costado) que brilla violeta en el fondo y estrellitas lilas
                 (Neon) en los costados (arte/referencias/abismo-1.png). Dos tamaños: Chico (12
                 studs de ancho) y Grande (20). Mallas Roca, Nucleo y Estrellas.

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
   arte/renders/deco_zonas.jpg; --exportar: además arma arte/fbx/Deco_Comun.fbx;
   --pieza Columna_Estelar / Isla_Flotante / Cristales_Abismo / Arbol_Nebuloso /
   Roca_Meteorito: render de esa pieza del Abismo; --exportar-zona5: solo arma
   arte/fbx/Deco_Zona5.fbx con las piezas del Abismo, sin renders; --pieza Arbol_Grande y
   --exportar-zona1: lo mismo con las piezas de la Pradera y arte/fbx/Deco_Zona1.fbx;
   --exportar-zona2: arte/fbx/Deco_Zona2.fbx con las piezas de las Dunas)
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
                try:
                    cara = self.bm.faces.new(vs)
                except ValueError:  # dos cajas pegadas con la misma cara: queda adentro, no se ve
                    continue
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

    def caja_girada(self, base, largo, ancho, rumbo, inclinacion):
        """Caja de ancho x ancho x largo que sale de `base` (centro de su cara de abajo, en studs)
        inclinada `inclinacion` grados desde la vertical hacia `rumbo` (grados en el piso, 0 = +x).
        Los studs siguen a la caja (sus UV se cortan cada TEJA studs desde su propia esquina)."""
        from mathutils import Matrix, Vector

        giro = Matrix.Rotation(math.radians(rumbo), 3, "Z") @ Matrix.Rotation(math.radians(inclinacion), 3, "Y")
        h = ancho / 2
        rangos = ((-h, h), (-h, h), (0, largo))
        for eje in range(3):
            a, b = self.EJES[eje]
            for signo in (-1, 1):
                fijo = rangos[eje][1 if signo > 0 else 0]
                # en la caja, los cortes de la textura empiezan en su esquina
                for a0, a1 in cortes(0, rangos[a][1] - rangos[a][0]):
                    for b0, b1 in cortes(0, rangos[b][1] - rangos[b][0]):
                        ta, tb = math.floor(a0 / TEJA + 1e-6) * TEJA, math.floor(b0 / TEJA + 1e-6) * TEJA
                        esquinas = [(a0, b0), (a1, b0), (a1, b1), (a0, b1)]
                        if signo < 0:
                            esquinas.reverse()
                        vs, uvs = [], []
                        for ca, cb in esquinas:
                            p = Vector((0.0, 0.0, 0.0))
                            p[eje], p[a], p[b] = fijo, ca + rangos[a][0], cb + rangos[b][0]
                            q = Vector(base) + giro @ p
                            vs.append(self.bm.verts.new([c * M.STUD for c in q]))
                            uvs.append(((ca - ta) / TEJA, (cb - tb) / TEJA))
                        cara = self.bm.faces.new(vs)
                        for loop, uv in zip(cara.loops, uvs):
                            loop[self.uv].uv = uv

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


# --- Abismo (zona 5): Columna_Estelar -----------------------------------------------------------

COLUMNA_COLOR = "#2E1660"  # violeta muy oscuro (más oscuro que el risco del Abismo)
ESTRELLA_COLOR = "#F4F6FF"  # en Roblox, Material Neon
COLUMNA_CUBO = 2  # studs de cada bloque de la columna
# alto -> (capas de bloques, estrellas, semilla): Alta 44 studs, Baja 28
COLUMNAS = {"Alta": (22, 12, 5), "Baja": (14, 8, 9)}
ESTRELLA_PX = 0.6  # studs de cada cubito de la estrella
ESTRELLA_SALE = 0.3  # cuánto sale de la pared
MAX_COLUMNA = 2000  # por pieza (sumando sus mallas)


def celdas_columna(capas, semilla):
    """Columna de bloques de 2 studs: pie ancho (6 x 6 con las puntas cortadas), cuerpo de 4 x 4
    sin esquinas que se va corriendo en x e y al subir (torcida en una curva suave) y punta de
    2 x 2. Devuelve las celdas y el corrimiento (cx, cy) de cada capa."""
    rng = random.Random(semilla)
    fase, giro = rng.uniform(0, math.pi), rng.choice((-1, 1))
    celdas, centros = set(), []
    for k in range(capas):
        t = k / (capas - 1)
        # se inclina para un lado y vuelve un poco arriba, con un vaivén suave en el otro eje
        cx = round(2.2 * math.sin(math.pi * t * 0.75) * giro)
        cy = round(0.9 * math.sin(math.pi * t * 1.6 + fase))
        if k < 2:
            cx = cy = 0  # el pie, centrado en el pivote
        centros.append((cx, cy))
        if k == 0:
            lado = 6
        elif k >= capas - 2:
            lado = 2
        elif k == 1:
            lado = 5
        elif k >= capas - 3:
            lado = 3
        else:
            lado = 4
        for i in range(lado):
            for j in range(lado):
                esquina = i in (0, lado - 1) and j in (0, lado - 1)
                if esquina and lado >= 4:
                    continue
                celdas.add((cx + i - lado // 2, cy + j - lado // 2, k))
    return celdas, centros


def estrella(m, eje, signo, plano, a, b, grande):
    """Estrellita de cubitos pegada a una pared: una cruz (brazos de 1 o 2 cubitos) centrada en
    (a, b), saliendo ESTRELLA_SALE de la pared en eje = plano."""
    brazo = 2 if grande else 1
    cruz = {(0, 0)} | {(d * s, 0) for d in range(1, brazo + 1) for s in (-1, 1)}
    cruz |= {(0, d * s) for d in range(1, brazo + 1) for s in (-1, 1)}
    ea, eb = Malla.EJES[eje]
    tam, origen, celdas = [0.0] * 3, [0.0] * 3, set()
    tam[eje], tam[ea], tam[eb] = ESTRELLA_SALE, ESTRELLA_PX, ESTRELLA_PX
    origen[eje] = plano if signo > 0 else plano - ESTRELLA_SALE
    origen[ea], origen[eb] = a - ESTRELLA_PX / 2, b - ESTRELLA_PX / 2
    for u, v in cruz:
        c = [0, 0, 0]
        c[ea], c[eb] = u, v
        celdas.add(tuple(c))
    voxeles_malla(m, celdas, tam, origen)


def columna_estelar(mats, alto="Alta"):
    """Columna_Estelar_<alto>: mallas Columna (bloques) y Estrellas (cruces blancas que brillan,
    pegadas en las paredes de afuera). Pivote en el centro de la base."""
    capas, cantidad, semilla = COLUMNAS[alto]
    celdas, centros = celdas_columna(capas, semilla)
    s = COLUMNA_CUBO
    col = Malla()
    voxeles_malla(col, celdas, (s, s, s))
    rng = random.Random(semilla * 7)
    est, usadas = Malla(), set()
    intentos = 0
    while len(usadas) < cantidad and intentos < 500:
        intentos += 1
        k = rng.randrange(2, capas - 2)
        eje, signo = rng.choice(((0, 1), (0, -1), (1, 1), (1, -1)))
        otro = 1 - eje
        # cara de afuera: la celda más lejana de la capa k en esa dirección
        fila = [c for c in celdas if c[2] == k]
        borde = max(c[eje] * signo for c in fila) * signo
        caras = [c for c in fila if c[eje] == borde]
        c = rng.choice(caras)
        if (k // 2, eje, signo) in usadas:  # repartidas: una por cada 2 capas y lado
            continue
        usadas.add((k // 2, eje, signo))
        plano = (c[eje] + (1 if signo > 0 else 0)) * s
        centro_otro = (c[otro] + 0.5) * s + rng.uniform(-0.3, 0.3)
        centro_z = (k + 0.5) * s + rng.uniform(-0.3, 0.3)
        a, b = (centro_otro, centro_z) if Malla.EJES[eje][0] == otro else (centro_z, centro_otro)
        estrella(est, eje, signo, plano, a, b, rng.random() < 0.35)
    objs, conteo = mallas(
        [(f"Columna_{alto}", col, mats["columna"]), (f"Estrellas_{alto}", est, mats["estrellas"])],
        MAX_COLUMNA,
        f"Columna_Estelar {alto}",
    )
    if sum(conteo.values()) > MAX_COLUMNA:
        raise RuntimeError(f"Columna_Estelar {alto}: {sum(conteo.values())} triángulos (máximo {MAX_COLUMNA})")
    return objs, conteo


# Isla_Flotante: arriba pasto violeta (como los árboles violetas de estilo-1.png), abajo roca
# del Abismo en escalones que terminan en punta, y cristales rosas que brillan
ISLA_PASTO = "#8A4FD8"
ISLA_ROCA = "#2E2A5C"  # el risco del Abismo
ISLA_CRISTAL = "#FF3FC0"  # en Roblox, Material Neon
ISLA_CUBO = 2  # studs de cada bloque
# tamaño -> (radio arriba en bloques, capas de roca, cristales, semilla)
ISLAS = {"Chica": (3, 4, 1, 3), "Mediana": (5, 6, 2, 8), "Grande": (7, 8, 3, 13)}
CRISTAL_PX = 1.0  # studs de cada cubito del cristal
MAX_ISLA = 3000  # por pieza (sumando sus mallas)


def celdas_isla(radio, capas, semilla):
    """Celdas (x, y, z) de bloques de ISLA_CUBO: la capa de arriba (z = capas) es el pasto, un
    disco con el borde un poco mordido; abajo, capas de roca cada vez más angostas (escalones)
    hasta una punta de 1 bloque en z = 0. Algunas gotitas de pasto cuelgan en el borde de la
    primera capa de roca. Devuelve (roca, pasto)."""
    rng = random.Random(semilla)
    pasto, roca = set(), set()
    for x in range(-radio, radio):
        for y in range(-radio, radio):
            d = math.hypot(x + 0.5, y + 0.5) / radio
            if d <= 1.0 - (rng.random() < 0.25) * 0.12:
                pasto.add((x, y, capas))
    for k in range(capas):
        # z = capas - 1 (bajo el pasto) hasta z = 0 (la punta)
        z = capas - 1 - k
        t = (k + 1) / capas
        r = max(0.75, radio * (1 - t) ** 0.85 + 0.6)
        for x, y, _ in pasto:
            d = math.hypot(x + 0.5, y + 0.5)
            if d <= r + rng.uniform(-0.45, 0.35):
                roca.add((x, y, z))
    for x in (-1, 0):  # la punta, siempre: 2 x 2 bloques centrados en el pivote
        for y in (-1, 0):
            roca |= {(x, y, 0), (x, y, 1)}
    # gotitas: celdas del borde de la primera capa de roca que pasan a ser pasto
    for x, y, z in list(roca):
        if z == capas - 1 and math.hypot(x + 0.5, y + 0.5) > radio - 1.6 and rng.random() < 0.35:
            roca.discard((x, y, z))
            pasto.add((x, y, z))
    return roca, pasto


def cristal(m, x, y, z, alto):
    """Cristal de cubitos parado en (x, y, z) (studs, centro de la base): 2 x 2 cubitos de alto
    `alto`, y uno solo arriba de punta."""
    c = CRISTAL_PX
    celdas = {(i, j, k) for i in (0, 1) for j in (0, 1) for k in range(alto)} | {(0, 0, alto)}
    voxeles_malla(m, celdas, (c, c, c), (x - c, y - c, z))


def isla_flotante(mats, tam="Mediana"):
    """Isla_Flotante_<tam>: mallas Roca, Pasto y Cristales. Pivote en el centro de la base (la
    punta de abajo)."""
    radio, capas, cristales, semilla = ISLAS[tam]
    roca, pasto = celdas_isla(radio, capas, semilla)
    s = (ISLA_CUBO,) * 3
    m_roca, m_pasto, m_cris = Malla(), Malla(), Malla()
    voxeles_malla(m_roca, roca, s, (0, 0, 0))
    voxeles_malla(m_pasto, pasto, s, (0, 0, 0))
    rng = random.Random(semilla * 3)
    arriba = (capas + 1) * ISLA_CUBO
    lugares = [(x, y) for x, y, z in pasto if z == capas and math.hypot(x + 0.5, y + 0.5) < radio - 1.2]
    rng.shuffle(lugares)
    usados = []
    for x, y in lugares:
        if len(usados) == cristales:
            break
        if any(abs(x - u) + abs(y - v) < 3 for u, v in usados):
            continue
        usados.append((x, y))
        cristal(m_cris, (x + 0.5) * ISLA_CUBO, (y + 0.5) * ISLA_CUBO, arriba, rng.choice((3, 4, 5)))
    objs, conteo = mallas(
        [(f"Roca_{tam}", m_roca, mats["roca"]), (f"Pasto_{tam}", m_pasto, mats["pasto"]),
         (f"Cristales_{tam}", m_cris, mats["cristales"])],
        MAX_ISLA,
        f"Isla_Flotante {tam}",
    )
    if sum(conteo.values()) > MAX_ISLA:
        raise RuntimeError(f"Isla_Flotante {tam}: {sum(conteo.values())} triángulos (máximo {MAX_ISLA})")
    return objs, conteo


# Cristales_Abismo: racimo de cristales rosas y violetas (Neon) saliendo de una roca oscura
RACIMO_ROSA = ISLA_CRISTAL
RACIMO_VIOLETA = "#7A2CFF"
RACIMO_ROCA = ISLA_ROCA
RACIMO_CUBO = 2  # studs de cada bloque de la roca
RACIMO_PX = 1  # studs de cada cubito de los cristales
# cada cristal: (x, y) donde nace, en studs; dirección hacia donde se inclina (dx, dy);
# alto en cubitos; cada cuántos cubitos se corre 1 hacia afuera; ancho (2: 2 x 2, 3: 3 x 3)
RACIMO = [
    ((0, 0), (0, 0), 11, 99, 3),  # el del medio, recto y grueso
    ((-2, 1), (-1, 0), 8, 3, 2),
    ((2, 1), (1, 1), 7, 3, 2),
    ((1, -2), (0, -1), 6, 2, 2),
    ((-2, -2), (-1, -1), 5, 2, 2),
    ((3, -1), (1, 0), 4, 2, 2),
]
MAX_RACIMO = 1500  # por pieza (sumando sus mallas)


def celdas_cristal(x0, y0, dx, dy, alto, paso, ancho):
    """Cubitos de un cristal: columna de ancho x ancho que se corre 1 hacia (dx, dy) cada `paso`
    cubitos y termina en punta (las 2 capas de arriba más angostas)."""
    celdas = set()
    for k in range(alto):
        corre = min(k, alto - 3) // paso  # la punta ya no se corre: queda pegada
        cx, cy = x0 + dx * corre, y0 + dy * corre
        lado = ancho if k < alto - 2 else max(1, ancho - (k - (alto - 3)))
        for i in range(lado):
            for j in range(lado):
                celdas.add((cx + i - lado // 2, cy + j - lado // 2, k))
    return celdas


def cristales_abismo(mats):
    """Cristales_Abismo: mallas Roca (bloques de 2 studs: base de 5 x 5 sin esquinas y una
    segunda capa más chica) y CristalRosa y CristalVioleta (cubitos de 1 stud, Neon), que nacen
    un bloque adentro de la roca. Pivote en el centro de la base."""
    roca = {(x, y, 0) for x in range(-3, 2) for y in range(-3, 2) if not (x in (-3, 1) and y in (-3, 1))}
    roca |= {(x, y, 1) for x in range(-2, 1) for y in range(-2, 1)} | {(1, -1, 1), (-3, 0, 1)}
    s = RACIMO_CUBO
    m_roca = Malla()
    voxeles_malla(m_roca, roca, (s, s, s), (s / 2, s / 2, 0))  # la base de 5 x 5 queda centrada
    rosa, violeta = set(), set()
    for n, ((x, y), (dx, dy), alto, paso, ancho) in enumerate(RACIMO):
        (rosa if n % 2 == 0 else violeta).update(celdas_cristal(x, y, dx, dy, alto, paso, ancho))
    violeta -= rosa
    nace = s + 0.5  # medio stud arriba de la primera capa: nacen adentro de la segunda
    m_rosa, m_violeta = Malla(), Malla()
    voxeles_malla(m_rosa, rosa, (RACIMO_PX,) * 3, (0, 0, nace))
    voxeles_malla(m_violeta, violeta, (RACIMO_PX,) * 3, (0, 0, nace))
    objs, conteo = mallas(
        [("Roca", m_roca, mats["roca"]), ("CristalRosa", m_rosa, mats["rosa"]),
         ("CristalVioleta", m_violeta, mats["violeta"])],
        MAX_RACIMO,
        "Cristales_Abismo",
    )
    if sum(conteo.values()) > MAX_RACIMO:
        raise RuntimeError(f"Cristales_Abismo: {sum(conteo.values())} triángulos (máximo {MAX_RACIMO})")
    return objs, conteo


def mats_racimo(studs=None):
    """Con studs, para el render (los cristales brillan); sin, para exportar."""
    if studs:
        return {
            "roca": material_studs("RacimoRoca", RACIMO_ROCA, studs),
            "rosa": M.material("RacimoRosa", RACIMO_ROSA, brillo=RACIMO_ROSA, fuerza_brillo=0.45),
            "violeta": M.material("RacimoVioleta", RACIMO_VIOLETA, brillo=RACIMO_VIOLETA, fuerza_brillo=0.45),
        }
    return {
        "roca": M.material("RacimoRoca", RACIMO_ROCA),
        "rosa": M.material("RacimoRosa", RACIMO_ROSA),
        "violeta": M.material("RacimoVioleta", RACIMO_VIOLETA),
    }


# Arbol_Nebuloso: como los árboles de cajas del juego (arte/referencias/arbol-1.png): tronco en
# escalones con raíces, una losa de sombra abajo de la copa y cajas grandes encimadas
ARBOL_TRONCO = COLUMNA_COLOR  # violeta oscuro
ARBOL_SOMBRA = "#4B3F8F"  # la tapa del Abismo
ARBOL_FUCSIA = "#E23DBE"
ARBOL_LILA = "#B57BE8"  # como los árboles violetas de estilo-1.png
# cajas en studs: ((x0, x1), (y0, y1), (z0, z1))
ARBOL_CAJAS = {
    "tronco": [
        ((-6, 6), (-5, 5), (0, 2)),  # raíces
        ((-5, 4), (-4, 4), (2, 4)),
        ((-3, 3), (-3, 3), (4, 9)),
        ((-2, 4), (-3, 3), (9, 14)),  # el tronco se corre un escalón
    ],
    "sombra": [((-9, 9), (-8, 8), (13, 15))],
    "fucsia": [((-11, 9), (-9, 9), (15, 27)), ((-16, -8), (-5, 5), (16, 24))],
    "lila": [((5, 15), (-6, 6), (13, 24)), ((-7, 5), (-6, 6), (27, 32))],
}
ARBOL_ESTRELLAS = 16
MAX_ARBOL = 2500  # por pieza (sumando sus mallas)


def arbol_nebuloso(mats, semilla=21):
    """Arbol_Nebuloso: mallas Tronco, Sombra, CopaFucsia, CopaLila y Estrellas (cruces de cubitos,
    Neon, sobre las caras de afuera de la copa, casi siempre cerca de donde se juntan dos cajas).
    Pivote en el centro de la base."""
    piezas = []
    for clave, nombre in (("tronco", "Tronco"), ("sombra", "Sombra"), ("fucsia", "CopaFucsia"), ("lila", "CopaLila")):
        m = Malla()
        for x, y, z in ARBOL_CAJAS[clave]:
            m.caja(x, y, z)
        piezas.append((nombre, m, mats[clave]))
    copa = ARBOL_CAJAS["fucsia"] + ARBOL_CAJAS["lila"]

    def tapado(p):  # el punto queda adentro (o muy cerca) de otra caja
        return any(all(c[i][0] - 0.4 < p[i] < c[i][1] + 0.4 for i in range(3)) for c in copa)

    rng = random.Random(semilla)
    est, puestas, intentos = Malla(), [], 0
    while len(puestas) < ARBOL_ESTRELLAS and intentos < 2000:
        intentos += 1
        caja = rng.choice(copa)
        eje, signo = rng.choice(((0, 1), (0, -1), (1, 1), (1, -1), (1, -1), (1, -1), (2, 1)))  # más al frente
        plano = caja[eje][1 if signo > 0 else 0]
        a, b = Malla.EJES[eje]
        p = [0.0, 0.0, 0.0]
        p[eje] = plano + 0.6 * signo  # apenas afuera de la cara, para ver si otra caja la tapa
        for k in (a, b):
            lo, hi = caja[k][0] + 1.5, caja[k][1] - 1.5
            if rng.random() < 0.6:  # cerca de un borde (donde se juntan las cajas)
                p[k] = rng.choice((lo + rng.uniform(0, 1.5), hi - rng.uniform(0, 1.5)))
            else:
                p[k] = rng.uniform(lo, hi)
        if tapado(p) or any(math.dist(p, q) < 4 for q in puestas):
            continue
        puestas.append(p)
        estrella(est, eje, signo, plano, p[a], p[b], rng.random() < 0.35)
    piezas.append(("Estrellas", est, mats["estrellas"]))
    objs, conteo = mallas(piezas, MAX_ARBOL, "Arbol_Nebuloso")
    if sum(conteo.values()) > MAX_ARBOL:
        raise RuntimeError(f"Arbol_Nebuloso: {sum(conteo.values())} triángulos (máximo {MAX_ARBOL})")
    return objs, conteo


def mats_arbol(studs=None):
    """Con studs, para el render (las estrellas brillan); sin, para exportar."""
    colores = {"tronco": ARBOL_TRONCO, "sombra": ARBOL_SOMBRA, "fucsia": ARBOL_FUCSIA, "lila": ARBOL_LILA}
    if studs:
        mats = {k: material_studs(f"Arbol_{k}", c, studs) for k, c in colores.items()}
        mats["estrellas"] = M.material("ArbolEstrellas", ESTRELLA_COLOR, brillo=ESTRELLA_COLOR, fuerza_brillo=2.5)
        return mats
    mats = {k: M.material(f"Arbol_{k}", c) for k, c in colores.items()}
    mats["estrellas"] = M.material("ArbolEstrellas", ESTRELLA_COLOR)
    return mats


# Árboles de la Pradera (zona 1), como los de las capturas (arte/referencias/estilo-1.png y
# mapa-1.png): cajas en studs ((x0, x1), (y0, y1), (z0, z1)), una lista por malla. Cada tipo tiene
# 3 variantes; pivote en el centro de la base.
#   Arbol_Grande  (14 studs) tronco grueso bordó que se abre en ramas, losa de sombra y copa de
#                 4 cajas verdes corridas en escalones, alguna que sobresale.
#   Arbol_Mediano (9) tronco recto y 2 cajas de copa en escalón.
#   Arbol_Rosa    (9) el mediano como un cerezo de bloques: abajo fucsia, el escalón violeta.
#   Arbusto       (5) 3 a 5 bloques verdes apilados y corridos (malla Hojas).
#   Arbol_Seco    (16) tronco de ladrillos marrón violeta en punta, con base en escalones y 3 ramas
#                 de cajas inclinadas que terminan en punta, sin hojas (arte/referencias/arbol-seco-*.png).
GRANDE_TRONCO = "#B0414E"  # bordó, como los troncos del juego
GRANDE_SOMBRA = "#2F8F3A"  # HojasOscuras de mapa.py
GRANDE_COPA = "#66C23A"
GRANDES = [
    {  # 1: se abre en V, la copa sobresale a la izquierda
        "tronco": [
            ((-4, 4), (-3, 3), (0, 1)),  # raíces
            ((-3, 3), (-2.5, 2.5), (1, 2)),
            ((-2, 2), (-2, 2), (2, 5)),
            ((-3.5, -0.5), (-1.5, 1.5), (5, 6.5)),  # rama izquierda
            ((-5, -2), (-1.5, 1.5), (6.5, 8.5)),
            ((0.5, 3.5), (-1.5, 1.5), (5, 6.5)),  # rama derecha
            ((2, 5), (-1.5, 1.5), (6.5, 8.5)),
        ],
        "sombra": [((-6, 6), (-3.5, 3), (8, 9))],
        "copa": [
            ((-7, 0.5), (-4, 4.5), (8.5, 13)),  # la grande de la izquierda
            ((-1, 7.5), (-5, 3), (9, 12.5)),  # la de la derecha, más baja y corrida al frente
            ((-4.5, 2.5), (-3, 3), (12.5, 14)),  # escalón de arriba
            ((-10, -6), (-2.5, 2), (9.5, 12)),  # la que sobresale de costado
        ],
    },
    {  # 2: el tronco se corre a la derecha, una rama sola a la izquierda, sobresale a la derecha
        "tronco": [
            ((-4, 4), (-3, 3), (0, 1)),
            ((-3, 3), (-2.5, 2.5), (1, 2.5)),
            ((-2, 2), (-2, 2), (2.5, 6)),
            ((-1, 3), (-2, 2), (6, 8.5)),
            ((-4, -1.5), (-1, 1), (4.5, 6.5)),  # rama izquierda
            ((-5.5, -3), (-1, 1), (6.5, 8.5)),
        ],
        "sombra": [((-6, 6.5), (-3.5, 3.5), (8, 9))],
        "copa": [
            ((-6.5, 3), (-4.5, 4), (8.5, 12)),
            ((1.5, 9.5), (-3.5, 3.5), (9.5, 12)),  # la que sobresale de costado
            ((-4, 4), (-3, 3), (11.5, 14)),  # escalón de arriba
            ((-8.5, -4.5), (-2.5, 2.5), (9, 11)),
        ],
    },
    {  # 3: copa ancha y chata en dos pisos, con una caja que sale al frente
        "tronco": [
            ((-3.5, 3.5), (-3.5, 3.5), (0, 1)),
            ((-2.5, 2.5), (-2, 2), (1, 6.5)),
            ((-4, -1), (-1.5, 1.5), (6, 7.5)),  # rama izquierda
            ((-5.5, -2.5), (-1.5, 1.5), (7.5, 9)),
            ((1, 4), (-1.5, 1.5), (6, 7.5)),  # rama derecha
            ((2.5, 5.5), (-1.5, 1.5), (7.5, 9)),
        ],
        "sombra": [((-7, 7), (-3.5, 3.5), (8.5, 9.5))],
        "copa": [
            ((-8, 8), (-4, 4), (9, 12)),
            ((-5, 2.5), (-3, 3.5), (12, 14)),  # escalón de arriba, corrido a la izquierda
            ((2.5, 6), (-2, 2.5), (11.5, 13)),
            ((-2.5, 2.5), (-6, -3.5), (9.5, 11.5)),  # la que sale al frente
        ],
    },
]
MEDIANOS = [
    {  # 1: abajo a la izquierda, el escalón a la derecha
        "tronco": [((-3, 3), (-2, 2), (0, 1)), ((-2, 2), (-1.5, 1.5), (1, 5))],
        "sombra": [((-4, 4), (-3, 2.5), (4.5, 5.5))],
        "copa": [((-5, 1.5), (-3.5, 3.5), (5, 7.5)), ((-1, 5), (-3, 2.5), (6.5, 9))],
    },
    {  # 2: al revés, y el tronco con un escalón
        "tronco": [((-3, 3), (-2, 2), (0, 1)), ((-2, 2), (-1.5, 1.5), (1, 3)), ((-1.5, 2), (-1.5, 1.5), (3, 5))],
        "sombra": [((-4, 4.5), (-2.5, 3), (4.5, 5.5))],
        "copa": [((-1.5, 5), (-3.5, 3.5), (5, 7.5)), ((-5, 1), (-2.5, 3), (6.5, 9))],
    },
    {  # 3: en pirámide, el escalón centrado y corrido atrás
        "tronco": [((-2.5, 2.5), (-2.5, 2.5), (0, 1)), ((-1.5, 1.5), (-1.5, 1.5), (1, 5))],
        "sombra": [((-4, 4), (-3, 3), (4.5, 5.5))],
        "copa": [((-4.5, 4.5), (-3.5, 3.5), (5, 7.5)), ((-2.5, 2.5), (-2, 3), (7, 9))],
    },
]
# el rosa: la caja de abajo fucsia y el escalón violeta
ROSAS = [{"tronco": m["tronco"], "sombra": m["sombra"], "fucsia": m["copa"][:1], "violeta": m["copa"][1:]} for m in MEDIANOS]


def rama_seca(base, rumbo, tramos):
    """Rama de cajas inclinadas (arte/referencias/arbol-seco-*.png): sale de `base` (studs) hacia
    `rumbo` (grados en el piso, 0 = +x) y cada tramo (inclinación desde la vertical, largo,
    ancho) arranca cerca de la punta del anterior; el último, más angosto, es la punta."""
    x, y, z = base
    cajas = []
    for inclinacion, largo, ancho in tramos:
        cajas.append(("girada", (x, y, z), largo, ancho, rumbo, inclinacion))
        t, r = math.radians(inclinacion), math.radians(rumbo)
        sigue = largo - ancho * 0.4
        x += sigue * math.sin(t) * math.cos(r)
        y += sigue * math.sin(t) * math.sin(r)
        z += sigue * math.cos(t)
    return cajas


SECOS = [
    {  # 1: tronco alto en punta, una rama larga a cada lado y una chica al frente
        "tronco": [
            ((-4, 4), (-3.5, 3.5), (0, 2)),  # base en escalones
            ((-5, -3), (-2, 1), (0, 1)),
            ((3, 5), (-1, 2), (0, 1.5)),
            ((-1, 2), (-4.5, -3.5), (0, 1)),
            ((-3, 3), (-3, 3), (2, 5)),
            ((-2, 2), (-2, 2), (5, 13)),
            ((-1.5, 1.5), (-1.5, 1.5), (13, 15)),
            ((-1, 1), (-1, 1), (15, 16)),  # punta
            *rama_seca((-1, 0, 7), 180, [(50, 7, 2.5), (30, 5, 2)]),
            *rama_seca((1, 0.3, 8), 0, [(45, 6, 2.2), (25, 4, 1.8)]),
            *rama_seca((0.5, -1, 10.5), -60, [(35, 3.5, 1.6)]),
        ],
    },
    {  # 2: tronco más fino, dos ramas a la derecha y una a la izquierda
        "tronco": [
            ((-3.5, 3.5), (-3, 3), (0, 1.5)),
            ((-2.5, 2.5), (-2.5, 2.5), (1.5, 4.5)),
            ((2, 4), (-2, 0), (0, 2.5)),
            ((-4, -2.5), (0, 2), (0, 1)),
            ((-1.5, 1.5), (-1.5, 1.5), (4.5, 14)),
            ((-1, 1), (-1, 1), (14, 16)),  # punta
            *rama_seca((1, 0, 6), 10, [(55, 6, 2), (30, 5, 1.6)]),
            *rama_seca((1, 0, 10), -10, [(40, 4, 1.8)]),
            *rama_seca((-1, 0, 8), 190, [(40, 6, 2), (20, 4, 1.6)]),
        ],
    },
    {  # 3: Y: tronco corto que se abre en dos brazos gruesos, y uno chico al frente
        "tronco": [
            ((-4, 4), (-3.5, 3.5), (0, 1.5)),
            ((-3, 3), (-3, 3), (1.5, 4)),
            ((3, 4.5), (-2, 1), (0, 1)),
            ((-1.5, 1), (-4.5, -3.5), (0, 1)),
            ((-2, 2), (-2, 2), (4, 7)),
            *rama_seca((-0.5, 0, 6), 180, [(20, 5, 3), (35, 4, 2.4), (15, 3, 1.8)]),
            *rama_seca((0.5, 0, 6), 0, [(25, 5, 3), (10, 4, 2.4)]),
            *rama_seca((0, -0.5, 8), -90, [(40, 3.5, 1.6)]),
        ],
    },
]
ARBUSTOS = [  # columnitas de bloques verdes de 2 studs apilados y corridos, como en las capturas
    {  # 1: 3 bloques en una torre que se corre
        "hojas": [((-1.5, 0.5), (-1, 1), (0, 2)), ((-1, 1), (-0.5, 1.5), (2, 4)), ((-0.5, 1.5), (-1, 1), (4, 5))],
    },
    {  # 2: 4 bloques en dos columnas
        "hojas": [
            ((-3, -1), (-1, 1), (0, 2)),
            ((-2.5, -0.5), (-1, 1), (2, 4)),
            ((0, 2), (-0.5, 1.5), (0, 2)),
            ((0.5, 2.5), (-0.5, 1.5), (2, 3.5)),
        ],
    },
    {  # 3: 5 bloques: dos columnas sobre un bloque bajo y uno chico al costado
        "hojas": [
            ((-2, 1.5), (-1.5, 1), (0, 1.5)),
            ((-2, 0), (-1, 1), (1.5, 3.5)),
            ((-1.5, 0.5), (-1, 1), (3.5, 5)),
            ((0.5, 2.5), (-1, 1), (1.5, 3)),
            ((2, 4), (-0.5, 1.5), (0, 1.5)),
        ],
    },
]
COLORES_VERDE = {"tronco": GRANDE_TRONCO, "sombra": GRANDE_SOMBRA, "copa": GRANDE_COPA}
COLORES_ROSA = {"tronco": "#8E4A42", "sombra": "#8A2C9E", "fucsia": "#E05CEB", "violeta": "#B04DFF"}  # violeta del arcoíris
COLORES_SECO = {"tronco": "#7A5A5C"}  # marrón violeta, como los árboles secos del juego
# nombre de cada malla
MALLAS_ARBOL = {"hojas": "Hojas", "tronco": "Tronco", "sombra": "Sombra", "copa": "Copa", "fucsia": "CopaFucsia", "violeta": "CopaVioleta"}
# tipo -> (variantes, alto en studs, máximo de triángulos, colores, prefijo de los materiales)
ARBOLES_PRADERA = {
    "Arbol_Grande": (GRANDES, 14, 3000, COLORES_VERDE, "Grande"),
    "Arbol_Mediano": (MEDIANOS, 9, 2000, COLORES_VERDE, "Grande"),
    "Arbol_Rosa": (ROSAS, 9, 2000, COLORES_ROSA, "Rosa"),
    "Arbol_Seco": (SECOS, 16, 2500, COLORES_SECO, "Seco"),
    "Arbusto": (ARBUSTOS, 5, 600, {"hojas": GRANDE_COPA}, "Arbusto"),
}


def arbol_pradera(mats, pieza="Arbol_Grande", variante=1):
    """Una variante (1, 2 o 3) de un árbol de ARBOLES_PRADERA: una malla por clave de sus cajas
    (Tronco, Sombra y Copa; CopaFucsia y CopaVioleta en el rosa; solo Tronco en el seco)."""
    variantes, _, tope, _, _ = ARBOLES_PRADERA[pieza]
    piezas = []
    for clave, lista in variantes[variante - 1].items():
        m = Malla()
        for c in lista:
            if c[0] == "girada":
                m.caja_girada(*c[1:])
            else:
                m.caja(*c)
        piezas.append((MALLAS_ARBOL[clave], m, mats[clave]))
    nombre = f"{pieza}_{variante}"
    objs, conteo = mallas(piezas, tope, nombre)
    if sum(conteo.values()) > tope:
        raise RuntimeError(f"{nombre}: {sum(conteo.values())} triángulos (máximo {tope})")
    return objs, conteo


def mats_pradera(pieza, studs=None):
    """Con studs, para el render; sin, para exportar."""
    _, _, _, colores, prefijo = ARBOLES_PRADERA[pieza]
    if studs:
        return {k: material_studs(f"{prefijo}_{k}", c, studs) for k, c in colores.items()}
    return {k: bpy.data.materials.get(f"{prefijo}_{k}") or M.material(f"{prefijo}_{k}", c) for k, c in colores.items()}


# Racimo_Cuarzo (Pradera): 4 cristales de cuarzo violeta (cajas inclinadas con una punta más
# angosta y clara, Neon suave en Roblox) que salen de una base de piedra gris de losas apiladas
CUARZO_PIEDRA = LOSAS_ZONAS[1]["piedra"]  # la piedra de las losas de la Pradera
CUARZO = COLORES_ROSA["violeta"]  # el violeta del arcoíris
CUARZO_PUNTA = "#D9A8FF"
# cada cristal: (x, y, z) donde nace (adentro de la piedra), rumbo, inclinación, largo, ancho
CRISTALES_CUARZO = [
    ((-0.3, 0.2, 2.5), 200, 8, 7.5, 2.4),  # el del medio, casi recto
    ((1.2, -0.6, 2.5), -20, 34, 5, 1.8),
    ((-1.5, -1.2, 2.2), 230, 30, 4.5, 1.6),
    ((0.6, 1.6, 2.3), 75, 40, 3.5, 1.4),
]
MAX_CUARZO = 1500  # por pieza (sumando sus mallas)


def racimo_cuarzo(mats):
    """Racimo_Cuarzo: mallas Piedra (2 losas corridas y un bloquecito al costado, con studs),
    Cuarzo (el cuerpo de cada cristal) y CuarzoPunta (la punta, más angosta). Pivote en el
    centro de la base."""
    piedra, cuerpo, punta = Malla(), Malla(), Malla()
    piedra.caja((-4, 4), (-3.5, 3.5), (0, 1.5))
    piedra.caja((-3, 3), (-2.5, 2.5), (1.5, 3))
    piedra.caja((2.5, 4.5), (0.5, 3), (0, 2))
    for base, rumbo, inclinacion, largo, ancho in CRISTALES_CUARZO:
        (b, p) = rama_seca(base, rumbo, [(inclinacion, largo, ancho), (inclinacion, ancho * 0.9, ancho * 0.6)])
        cuerpo.caja_girada(*b[1:])
        punta.caja_girada(*p[1:])
    objs, conteo = mallas(
        [("Piedra", piedra, mats["piedra"]), ("Cuarzo", cuerpo, mats["cuarzo"]), ("CuarzoPunta", punta, mats["punta"])],
        MAX_CUARZO,
        "Racimo_Cuarzo",
    )
    if sum(conteo.values()) > MAX_CUARZO:
        raise RuntimeError(f"Racimo_Cuarzo: {sum(conteo.values())} triángulos (máximo {MAX_CUARZO})")
    return objs, conteo


def mats_cuarzo(studs=None):
    """Con studs, para el render (el cuarzo brilla poquito); sin, para exportar."""
    if studs:
        return {
            "piedra": material_studs("CuarzoPiedra", CUARZO_PIEDRA, studs),
            "cuarzo": M.material("Cuarzo", CUARZO, brillo=CUARZO, fuerza_brillo=0.35),
            "punta": M.material("CuarzoPunta", CUARZO_PUNTA, brillo=CUARZO_PUNTA, fuerza_brillo=0.35),
        }
    return {
        "piedra": M.material("CuarzoPiedra", CUARZO_PIEDRA),
        "cuarzo": M.material("Cuarzo", CUARZO),
        "punta": M.material("CuarzoPunta", CUARZO_PUNTA),
    }


# Cascada_Cristal (Pradera, pista de la puerta secreta): agua celeste transparente en escalera
# sobre escalones del risco de la Pradera, y una pileta con espuma. Frente hacia -y (como el risco).
CASCADA_RISCO = ZONAS[1]["risco"]
CASCADA_PASTO = ZONAS[1]["tapa"]
CASCADA_AGUA = "#7FD8FF"  # en Roblox, Transparency 0.35 (o Material Glass)
CASCADA_ESPUMA = "#F4FAFF"
CASCADA_TRANSPARENCIA = 0.35
MAX_CASCADA = 3000  # por pieza (sumando sus mallas)
CASCADA_Y = 1.5  # corre todo para que el centro de la base quede en y = 0 (va de -8 a 5)


def cascada_cristal(mats):
    """Cascada_Cristal: mallas Risco (3 escalones y el borde de la pileta, con studs), Pasto
    (las tapas de los escalones a los costados del agua), Agua (la tirada de arriba, una
    cortina por escalón y la pileta) y Espuma (bloquecitos blancos donde cae). Pivote en el
    centro de la base."""
    d = CASCADA_Y

    def y(a, b):
        return (a + d, b + d)

    risco, pasto, agua, espuma = Malla(), Malla(), Malla(), Malla()
    # escalones de risco: el de atrás es el más alto (z, desde dónde empieza en y)
    escalones = [((-4, 4), y(3, 5), (0, 13)), ((-3.5, 3.5), y(1, 3), (0, 9)), ((-3, 3), y(-1, 1), (0, 5))]
    for ex, ey, ez in escalones:
        risco.caja(ex, ey, ez)
        # pasto arriba, a los dos costados del agua (el agua tiene 4 de ancho)
        for px in ((ex[0], -2), (2, ex[1])):
            pasto.caja(px, (ey[0] - 0.3, ey[1]), (ez[1], ez[1] + 1))
    # el agua: tirada arriba del escalón de atrás y, en cada uno, una cortina que baja por el
    # frente y una lámina arriba del escalón de abajo
    agua.caja((-2, 2), y(3.5, 5), (13, 13.5))
    for (ex, ey, ez), sigue in zip(escalones, [9, 5, 1.2]):
        agua.caja((-2, 2), (ey[0] - 0.6, ey[0]), (sigue, ez[1] + 0.5))
        if sigue > 2:
            agua.caja((-2.2, 2.2), (ey[0] - 2, ey[0] - 0.6), (sigue, sigue + 0.5))
    # la pileta: borde de 1 stud de risco y el agua adentro
    risco.caja((-5, 5), y(-8, -7), (0, 1.5))
    risco.caja((-5, -4), y(-7, -1), (0, 1.5))
    risco.caja((4, 5), y(-7, -1), (0, 1.5))
    agua.caja((-4, 4), y(-7, -1), (0, 1.2), caras="xXyYZ")
    # espuma donde cae el agua
    for bx, by, bz in (((-2.5, 2.5), (-2.4, -1.6), (1.2, 1.7)), ((-1.5, 0.5), (-3.2, -2.4), (1.2, 1.5)),
                       ((1, 2), (-3, -2.4), (1.2, 1.6)), ((-3.2, -2.2), (-2, -1.4), (1.2, 1.5))):
        espuma.caja(bx, y(*by), bz)
    objs, conteo = mallas(
        [("Risco", risco, mats["risco"]), ("Pasto", pasto, mats["pasto"]), ("Agua", agua, mats["agua"]),
         ("Espuma", espuma, mats["espuma"])],
        MAX_CASCADA,
        "Cascada_Cristal",
    )
    if sum(conteo.values()) > MAX_CASCADA:
        raise RuntimeError(f"Cascada_Cristal: {sum(conteo.values())} triángulos (máximo {MAX_CASCADA})")
    return objs, conteo


def mats_cascada(studs=None):
    """Con studs, para el render (el agua se ve a través); sin, para exportar."""
    if studs:
        agua = material_studs("CascadaAgua", CASCADA_AGUA, studs)
        agua.node_tree.nodes["Principled BSDF"].inputs["Alpha"].default_value = 1 - CASCADA_TRANSPARENCIA
        return {
            "risco": material_studs("CascadaRisco", CASCADA_RISCO, studs),
            "pasto": material_studs("CascadaPasto", CASCADA_PASTO, studs),
            "agua": agua,
            "espuma": material_studs("CascadaEspuma", CASCADA_ESPUMA, studs),
        }
    return {
        "risco": M.material("CascadaRisco", CASCADA_RISCO),
        "pasto": M.material("CascadaPasto", CASCADA_PASTO),
        "agua": M.material("CascadaAgua", CASCADA_AGUA),
        "espuma": M.material("CascadaEspuma", CASCADA_ESPUMA),
    }


# Piramide (Dunas): escalones cuadrados que se achican 3 studs por lado en cada piso
PIRAMIDE_COLOR = ZONAS[2]["risco"]
PIRAMIDE_ESCALONES = 10
PIRAMIDE_ALTO = 3  # studs de alto de cada escalón (10 x 3 = 30)
PIRAMIDE_PASO = 3  # cuánto se mete cada escalón por lado
PIRAMIDE_BASE = 64  # studs de lado del escalón de abajo
MAX_PIRAMIDE = 4000


def piramide(mats):
    """Piramide: una sola malla con los costados de cada escalón y, arriba, solo el anillo que
    queda a la vista (lo que tapa el escalón de arriba no se hace: ahorra triángulos). Sin
    piso. Pivote en el centro de la base."""
    m = Malla()
    for k in range(PIRAMIDE_ESCALONES):
        h = PIRAMIDE_BASE / 2 - k * PIRAMIDE_PASO
        z0, z1 = k * PIRAMIDE_ALTO, (k + 1) * PIRAMIDE_ALTO
        m.caja((-h, h), (-h, h), (z0, z1), caras="xXyY")
        if k == PIRAMIDE_ESCALONES - 1:
            m.rect(2, 1, z1, (-h, h), (-h, h))
            continue
        a = h - PIRAMIDE_PASO  # el escalón de arriba
        m.rect(2, 1, z1, (-h, h), (-h, -a))
        m.rect(2, 1, z1, (-h, h), (a, h))
        m.rect(2, 1, z1, (-h, -a), (-a, a))
        m.rect(2, 1, z1, (a, h), (-a, a))
    objs, conteo = mallas([("Piramide", m, mats["piramide"])], MAX_PIRAMIDE, "Piramide")
    return objs, conteo


def mats_piramide(studs=None):
    """Con studs, para el render; sin, para exportar."""
    if studs:
        return {"piramide": material_studs("Piramide", PIRAMIDE_COLOR, studs)}
    return {"piramide": M.material("Piramide", PIRAMIDE_COLOR)}


# Roca_Meteorito: roca azul noche de bloques con un cráter que brilla violeta adentro y
# estrellitas lilas en los costados (como el cielo del Abismo, arte/referencias/abismo-1.png;
# el naranja quedaba de la zona de lava)
METEORITO_ROCA = "#262A63"
METEORITO_NUCLEO = "#7B3CFF"  # en Roblox, Neon
METEORITO_ESTRELLA = "#D6CCFF"  # en Roblox, Neon
METEORITO_CUBO = 2  # studs de cada bloque
# tamaño -> (radio en bloques, alto en bloques, estrellas en los costados, semilla)
METEORITOS = {"Chico": (3, 3, 3, 4), "Grande": (5, 5, 5, 17)}
MAX_METEORITO = 1500  # por pieza (sumando sus mallas)


def celdas_meteorito(radio, alto, semilla):
    """Media bola chata de bloques (abajo plana, con el borde un poco mordido) con un cráter
    corrido para un costado. El fondo del cráter es el núcleo que brilla.
    Devuelve (roca, nucleo)."""
    rng = random.Random(semilla)
    roca = set()
    for x in range(-radio, radio):
        for y in range(-radio, radio):
            for z in range(alto):
                d = ((x + 0.5) / radio) ** 2 + ((y + 0.5) / radio) ** 2 + ((z + 0.3) / alto) ** 2
                if d <= 1 + rng.uniform(-0.12, 0.08):
                    roca.add((x, y, z))
    # cráter: un tazón arriba, corrido hacia un costado
    cx, cy = rng.uniform(-0.3, 0.3) * radio, rng.uniform(-0.3, 0.3) * radio
    rc = radio * 0.6
    fondo = alto - 2
    for c in list(roca):
        d = math.hypot(c[0] + 0.5 - cx, c[1] + 0.5 - cy) / rc
        if d < 1 and c[2] > fondo + d * d * 2.2:
            roca.discard(c)
    nucleo = set()
    for x, y, z in roca:
        d = math.hypot(x + 0.5 - cx, y + 0.5 - cy) / rc
        if d < 0.8 and (x, y, z + 1) not in roca:
            nucleo.add((x, y, z))
    return roca - nucleo, nucleo


def roca_meteorito(mats, tam="Grande"):
    """Roca_Meteorito_<tam>: mallas Roca, Nucleo y Estrellas (cruces de cubitos pegadas en las
    paredes de afuera, a media altura). Pivote en el centro de la base."""
    radio, alto, estrellas, semilla = METEORITOS[tam]
    roca, nucleo = celdas_meteorito(radio, alto, semilla)
    c = METEORITO_CUBO
    m_roca, m_nucleo, m_est = Malla(), Malla(), Malla()
    voxeles_malla(m_roca, roca, (c, c, c))
    voxeles_malla(m_nucleo, nucleo, (c, c, c))
    rng = random.Random(semilla * 5)
    todas = roca | nucleo
    caras = []  # (celda, eje, signo) de las paredes de afuera
    for x, y, z in roca:
        if 0 < z < alto - 1:
            for eje, signo in ((0, 1), (0, -1), (1, 1), (1, -1)):
                v = [x, y, z]
                v[eje] += signo
                if tuple(v) not in todas:
                    caras.append(((x, y, z), eje, signo))
    rng.shuffle(caras)
    puestas = []
    for celda, eje, signo in caras:
        if len(puestas) == estrellas:
            break
        centro = [(k + 0.5) * c for k in celda]
        if any(math.dist(centro, q) < 3.5 * c for q in puestas):
            continue
        puestas.append(centro)
        a, b = Malla.EJES[eje]
        plano = (celda[eje] + (1 if signo > 0 else 0)) * c
        estrella(m_est, eje, signo, plano, centro[a], centro[b], rng.random() < 0.4)
    objs, conteo = mallas(
        [(f"Roca_{tam}", m_roca, mats["roca"]), (f"Nucleo_{tam}", m_nucleo, mats["nucleo"]),
         (f"Estrellas_{tam}", m_est, mats["estrellas"])],
        MAX_METEORITO,
        f"Roca_Meteorito {tam}",
    )
    if sum(conteo.values()) > MAX_METEORITO:
        raise RuntimeError(f"Roca_Meteorito {tam}: {sum(conteo.values())} triángulos (máximo {MAX_METEORITO})")
    return objs, conteo


def mats_meteorito(studs=None):
    """Con studs, para el render (núcleo y estrellas brillan); sin, para exportar."""
    if studs:
        return {
            "roca": material_studs("MeteoritoRoca", METEORITO_ROCA, studs),
            "nucleo": M.material("MeteoritoNucleo", METEORITO_NUCLEO, brillo=METEORITO_NUCLEO, fuerza_brillo=0.8),
            "estrellas": M.material("MeteoritoEstrella", METEORITO_ESTRELLA, brillo=METEORITO_ESTRELLA, fuerza_brillo=2.0),
        }
    return {
        "roca": M.material("MeteoritoRoca", METEORITO_ROCA),
        "nucleo": M.material("MeteoritoNucleo", METEORITO_NUCLEO),
        "estrellas": M.material("MeteoritoEstrella", METEORITO_ESTRELLA),
    }


def mats_isla(studs=None):
    """Con studs, para el render (los cristales brillan); sin, para exportar."""
    if studs:
        return {
            "roca": material_studs("IslaRoca", ISLA_ROCA, studs),
            "pasto": material_studs("IslaPasto", ISLA_PASTO, studs),
            "cristales": M.material("IslaCristal", ISLA_CRISTAL, brillo=ISLA_CRISTAL, fuerza_brillo=1.0),
        }
    return {
        "roca": M.material("IslaRoca", ISLA_ROCA),
        "pasto": M.material("IslaPasto", ISLA_PASTO),
        "cristales": M.material("IslaCristal", ISLA_CRISTAL),
    }


def mats_columna(studs=None):
    """Con studs, para el render (las estrellas brillan); sin, para exportar."""
    if studs:
        return {
            "columna": material_studs("Columna", COLUMNA_COLOR, studs),
            "estrellas": M.material("Estrellas", ESTRELLA_COLOR, brillo=ESTRELLA_COLOR, fuerza_brillo=2.5),
        }
    return {"columna": M.material("Columna", COLUMNA_COLOR), "estrellas": M.material("Estrellas", ESTRELLA_COLOR)}


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
    # la captura entera y un acercamiento a los árboles violetas del fondo
    "Columna_Estelar": ("estilo-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    "Isla_Flotante": ("estilo-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    "Cristales_Abismo": ("estilo-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    "Roca_Meteorito": ("abismo-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    "Arbol_Nebuloso": ("arbol-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    # acercamientos al árbol de la izquierda de cada captura
    "Arbol_Grande": (("estilo-1.png", (0.18, 0.38, 0.32, 0.64)), ("mapa-1.png", (0.19, 0.40, 0.32, 0.64))),
    "Arbol_Mediano": (("estilo-1.png", (0.18, 0.38, 0.32, 0.64)), ("mapa-1.png", (0.19, 0.40, 0.32, 0.64))),
    # la captura entera (los árboles rosas del fondo) y un acercamiento
    "Arbol_Rosa": ("estilo-1.png", ("estilo-1.png", (0.40, 0.33, 0.60, 0.58))),
    # los árboles secos de la derecha de cada captura
    "Arbol_Seco": ("arbol-seco-1.png", "arbol-seco-2.png"),
    # los arbustitos de la izquierda de cada captura
    "Arbusto": (("estilo-1.png", (0.18, 0.52, 0.36, 0.70)), ("mapa-1.png", (0.18, 0.47, 0.36, 0.62))),
    # la captura entera y las losas de piedra gris de la izquierda
    "Racimo_Cuarzo": ("estilo-1.png", ("mapa-1.png", (0.10, 0.45, 0.35, 0.62))),
    # la captura entera y el risco con pasto de la derecha
    "Cascada_Cristal": ("estilo-1.png", ("mapa-1.png", (0.62, 0.30, 0.95, 0.62))),
    # la pirámide de las Dunas y la captura de la zona
    "Piramide": ("mapa-2.png", "estilo-2.png"),
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


def render_columna():
    """Columna_Estelar Alta y Baja de frente y de costado, al lado de la referencia
    (estilo-1.png y un acercamiento a sus árboles violetas)."""
    conteo = {}
    paso = 16 * M.STUD
    alto = COLUMNAS["Alta"][0] * COLUMNA_CUBO * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        mats = mats_columna(textura_studs())
        for k, tam in enumerate(COLUMNAS):
            objs, c = columna_estelar(mats, tam)
            conteo.update(c)
            M.mover(objs, (k - 0.5) * paso if vista == "frente" else 0, 0 if vista == "frente" else (k - 0.5) * paso)
        giro = -14 if vista == "frente" else 76
        camara_orto(escena, (0, 0, alto * 0.5), alto * 1.25 * 16 / 9, 10, giro)
        M.render(f"columna_estelar_{vista}")
    comparar("Columna_Estelar")
    print("TRIANGULOS Columna_Estelar", conteo, "Alta", sum(v for k, v in conteo.items() if "Alta" in k),
          "Baja", sum(v for k, v in conteo.items() if "Baja" in k))


def render_isla():
    """Isla_Flotante Chica, Mediana y Grande en fila (flotando un poco sobre el piso) de frente
    y de costado, al lado de la referencia."""
    conteo = {}
    anchos = [2 * ISLAS[t][0] * ISLA_CUBO for t in ISLAS]
    total = sum(anchos) + 8 * (len(anchos) - 1)
    alto = (ISLAS["Grande"][1] + 1) * ISLA_CUBO + 5
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        mats = mats_isla(textura_studs())
        x = -total / 2
        for tam, ancho in zip(ISLAS, anchos):
            objs, c = isla_flotante(mats, tam)
            conteo[tam] = c
            pos = (x + ancho / 2) * M.STUD
            M.mover(objs, pos if vista == "frente" else 0, 0 if vista == "frente" else pos)
            for o in objs:
                o.location.z += 6 * M.STUD  # flotando
            x += ancho + 8
        giro = -14 if vista == "frente" else 76
        camara_orto(escena, (0, 0, (alto / 2 + 6) * M.STUD), total * M.STUD * 1.15, 14, giro)
        M.render(f"isla_flotante_{vista}")
    comparar("Isla_Flotante")
    for tam, c in conteo.items():
        print("TRIANGULOS Isla_Flotante", tam, c, "total", sum(c.values()))


def render_racimo():
    """Cristales_Abismo de frente y de costado, al lado de la referencia."""
    alto = 18 * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = cristales_abismo(mats_racimo(textura_studs()))
        giro = -20 if vista == "frente" else 70
        camara_orto(escena, (0, 0, alto * 0.45), alto * 1.3 * 16 / 9, 12, giro)
        M.render(f"cristales_abismo_{vista}")
    comparar("Cristales_Abismo")
    print("TRIANGULOS Cristales_Abismo", conteo, "total", sum(conteo.values()))


def render_arbol():
    """Arbol_Nebuloso de frente y de costado, al lado de las referencias."""
    alto = 32 * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = arbol_nebuloso(mats_arbol(textura_studs()))
        giro = -18 if vista == "frente" else 72
        camara_orto(escena, (0, 0, alto * 0.5), alto * 1.25 * 16 / 9, 10, giro)
        M.render(f"arbol_nebuloso_{vista}")
    comparar("Arbol_Nebuloso")
    print("TRIANGULOS Arbol_Nebuloso", conteo, "total", sum(conteo.values()))


def render_arbol_pradera(pieza):
    """Las 3 variantes de un árbol de la Pradera en fila (1, 2, 3 de izquierda a derecha), de
    frente y de costado, al lado de las referencias."""
    variantes, alto, *_ = ARBOLES_PRADERA[pieza]
    alto *= M.STUD
    paso = {"Arbol_Grande": 22, "Arbol_Seco": 17, "Arbusto": 9}.get(pieza, 15)  # studs entre variantes
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        mats = mats_pradera(pieza, textura_studs())
        conteos = []
        for i in range(len(variantes)):
            objs, conteo = arbol_pradera(mats, pieza, i + 1)
            M.mover(objs, (i - 1) * paso * M.STUD)
            conteos.append(conteo)
        giro = -18 if vista == "frente" else 72
        ancho = max(alto * 1.25 * 16 / 9, 3.2 * paso * M.STUD)
        camara_orto(escena, (0, 0, alto * 0.5), ancho, 10, giro)
        M.render(f"{pieza.lower()}_{vista}")
    comparar(pieza)
    for i, conteo in enumerate(conteos):
        print("TRIANGULOS", f"{pieza}_{i + 1}", conteo, "total", sum(conteo.values()))


def render_cuarzo():
    """Racimo_Cuarzo de frente y de costado, al lado de las referencias."""
    alto = 11 * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = racimo_cuarzo(mats_cuarzo(textura_studs()))
        giro = -20 if vista == "frente" else 70
        camara_orto(escena, (0, 0, alto * 0.45), alto * 1.3 * 16 / 9, 12, giro)
        M.render(f"racimo_cuarzo_{vista}")
    comparar("Racimo_Cuarzo")
    print("TRIANGULOS Racimo_Cuarzo", conteo, "total", sum(conteo.values()))


def render_cascada():
    """Cascada_Cristal de frente y de costado, al lado de las referencias."""
    alto = 15 * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = cascada_cristal(mats_cascada(textura_studs()))
        giro = -20 if vista == "frente" else 70
        camara_orto(escena, (0, 0, alto * 0.45), alto * 1.3 * 16 / 9, 14, giro)
        M.render(f"cascada_cristal_{vista}")
    comparar("Cascada_Cristal")
    print("TRIANGULOS Cascada_Cristal", conteo, "total", sum(conteo.values()))


def render_piramide():
    """Piramide de frente y de costado, al lado de las referencias."""
    alto = PIRAMIDE_ESCALONES * PIRAMIDE_ALTO * M.STUD
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = piramide(mats_piramide(textura_studs()))
        giro = -20 if vista == "frente" else 70
        camara_orto(escena, (0, 0, alto * 0.45), PIRAMIDE_BASE * M.STUD * 1.6, 12, giro)
        M.render(f"piramide_{vista}")
    comparar("Piramide")
    print("TRIANGULOS Piramide", conteo, "total", sum(conteo.values()))


def noche_abismo(escena):
    """Cambia el cielo y el piso del render por la noche del Abismo (abismo-1.png): fondo azul
    muy oscuro, piso azul noche y un sol más flojo, para ver bien lo que brilla."""
    escena.world.node_tree.nodes["Background"].inputs["Color"].default_value = (*M.hex_a_rgb("#0E1338"), 1)
    sol = bpy.data.lights["Sol"]
    sol.energy, sol.color = 2.2, M.hex_a_rgb("#C9C2FF")
    tablero = bpy.data.materials["Piso"].node_tree.nodes["Checker Texture"]
    tablero.inputs["Color1"].default_value = (*M.hex_a_rgb("#1E2A66"), 1)
    tablero.inputs["Color2"].default_value = (*M.hex_a_rgb("#1A2459"), 1)


def render_meteorito():
    """Roca_Meteorito Chico y Grande en fila, de frente y de costado (un poco desde arriba, para
    ver el cráter) en la noche del Abismo, al lado de la referencia."""
    conteo = {}
    anchos = [2 * METEORITOS[t][0] * METEORITO_CUBO for t in METEORITOS]
    total = sum(anchos) + 6
    for vista in ("frente", "costado"):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        noche_abismo(escena)
        mats = mats_meteorito(textura_studs())
        x = -total / 2
        for tam, ancho in zip(METEORITOS, anchos):
            objs, c = roca_meteorito(mats, tam)
            conteo[tam] = c
            pos = (x + ancho / 2) * M.STUD
            M.mover(objs, pos if vista == "frente" else 0, 0 if vista == "frente" else pos)
            x += ancho + 6
        giro = -14 if vista == "frente" else 76
        camara_orto(escena, (0, 0, 4 * M.STUD), total * M.STUD * 1.3, 30, giro)
        M.render(f"roca_meteorito_{vista}")
    comparar("Roca_Meteorito")
    for tam, c in conteo.items():
        print("TRIANGULOS Roca_Meteorito", tam, c, "total", sum(c.values()))


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


def cargar(ruta, ancho, alto, recorte=None):
    """recorte: (x0, y0, x1, y1) en fracciones de la imagen, y = 0 arriba."""
    import numpy as np

    img = bpy.data.images.load(str(ruta))
    w, h = img.size
    px = np.empty(w * h * 4, dtype=np.float32)
    img.pixels.foreach_get(px)
    px = px.reshape(h, w, 4)
    if recorte:
        x0, y0, x1, y1 = recorte  # en Blender la fila 0 es la de abajo
        px = px[round(h * (1 - y1)) : round(h * (1 - y0)), round(w * x0) : round(w * x1)]
        h, w = px.shape[:2]
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
        *(cargar(ref / r, w, h) if isinstance(r, str) else cargar(ref / r[0], w, h, r[1]) for r in REFERENCIAS[pieza]),
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


def exportar_zona5():
    """Deco_Zona5.fbx: piezas que son solo del Abismo. Raíz Deco_Zona5 con un vacío por alto
    (Columna_Estelar_Alta, Columna_Estelar_Baja) y sus mallas (Columna_Alta y Estrellas_Alta...),
    y uno por tamaño de isla (Isla_Flotante_Chica...) con Roca_Chica, Pasto_Chica y
    Cristales_Chica; y Cristales_Abismo con Cristales_Abismo_Roca, Cristales_Abismo_CristalRosa y
    Cristales_Abismo_CristalVioleta; y Arbol_Nebuloso con Arbol_Nebuloso_Tronco, _Sombra,
    _CopaFucsia, _CopaLila y _Estrellas; y Roca_Meteorito_Chico y _Grande con
    Meteorito_Roca_Chico, Meteorito_Nucleo_Chico y Meteorito_Estrellas_Chico (las dos últimas
    en Neon). Sin textura: el juego pone el color, TextureID =
    Studs.png en Columna, Roca, Pasto, Tronco, Sombra y Copa, y Material Neon en las estrellas y
    en los cristales."""
    M.limpiar_escena()
    raiz = bpy.data.objects.new("Deco_Zona5", None)
    bpy.context.scene.collection.objects.link(raiz)
    mats = mats_columna()
    for alto in COLUMNAS:
        vacio = bpy.data.objects.new(f"Columna_Estelar_{alto}", None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        objs, conteo = columna_estelar(mats, alto)
        for o in objs:
            o.parent = vacio
        print("TRIANGULOS", f"Columna_Estelar_{alto}", conteo, "total", sum(conteo.values()))
    mats = mats_isla()
    for tam in ISLAS:
        vacio = bpy.data.objects.new(f"Isla_Flotante_{tam}", None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        objs, conteo = isla_flotante(mats, tam)
        for o in objs:
            o.parent = vacio
        print("TRIANGULOS", f"Isla_Flotante_{tam}", conteo, "total", sum(conteo.values()))
    vacio = bpy.data.objects.new("Cristales_Abismo", None)
    bpy.context.scene.collection.objects.link(vacio)
    vacio.parent = raiz
    objs, conteo = cristales_abismo(mats_racimo())
    for o in objs:
        o.parent = vacio
        o.name = o.data.name = f"Cristales_Abismo_{o.name.split('.')[0]}"  # Roca solo se repite
    print("TRIANGULOS Cristales_Abismo", conteo, "total", sum(conteo.values()))
    vacio = bpy.data.objects.new("Arbol_Nebuloso", None)
    bpy.context.scene.collection.objects.link(vacio)
    vacio.parent = raiz
    objs, conteo = arbol_nebuloso(mats_arbol())
    for o in objs:
        o.parent = vacio
        o.name = o.data.name = f"Arbol_Nebuloso_{o.name.split('.')[0]}"
    print("TRIANGULOS Arbol_Nebuloso", conteo, "total", sum(conteo.values()))
    mats = mats_meteorito()
    for tam in METEORITOS:
        vacio = bpy.data.objects.new(f"Roca_Meteorito_{tam}", None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        objs, conteo = roca_meteorito(mats, tam)
        for o in objs:
            o.parent = vacio
            # Roca_Grande ya es de la isla: Meteorito_Roca_Grande, Meteorito_Nucleo_Grande...
            o.name = o.data.name = f"Meteorito_{o.name.split('.')[0]}"
        print("TRIANGULOS", f"Roca_Meteorito_{tam}", conteo, "total", sum(conteo.values()))
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Deco_Zona5.fbx"),
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
    print("  FBX Deco_Zona5.fbx")


EXPORTAR_ZONA1 = ["Arbol_Grande", "Arbol_Mediano", "Arbol_Rosa", "Arbol_Seco", "Arbusto"]  # los tipos aprobados


def exportar_zona1():
    """Deco_Zona1.fbx: piezas que son solo de la Pradera. Raíz Deco_Zona1 con un vacío por
    variante de cada árbol (Arbol_Grande_1, _2, _3...) y sus mallas (Arbol_Grande_1_Tronco,
    _Sombra, _Copa...), Racimo_Cuarzo con Racimo_Cuarzo_Piedra, _Cuarzo y _CuarzoPunta, y
    Cascada_Cristal con Cascada_Cristal_Risco, _Pasto, _Agua y _Espuma. Sin textura: el juego
    pone el color y TextureID = Studs.png en todas, salvo el Cuarzo y la CuarzoPunta, que van en
    Material Neon; el Agua lleva además Transparency = CASCADA_TRANSPARENCIA."""
    M.limpiar_escena()
    raiz = bpy.data.objects.new("Deco_Zona1", None)
    bpy.context.scene.collection.objects.link(raiz)
    for pieza in EXPORTAR_ZONA1:
        for v in range(1, len(ARBOLES_PRADERA[pieza][0]) + 1):
            nombre = f"{pieza}_{v}"
            vacio = bpy.data.objects.new(nombre, None)
            bpy.context.scene.collection.objects.link(vacio)
            vacio.parent = raiz
            objs, conteo = arbol_pradera(mats_pradera(pieza), pieza, v)
            for o in objs:
                o.parent = vacio
                o.name = o.data.name = f"{nombre}_{o.name.split('.')[0]}"
            print("TRIANGULOS", nombre, conteo, "total", sum(conteo.values()))
    for nombre, crear, mats in (
        ("Racimo_Cuarzo", racimo_cuarzo, mats_cuarzo()),
        ("Cascada_Cristal", cascada_cristal, mats_cascada()),
    ):
        vacio = bpy.data.objects.new(nombre, None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        objs, conteo = crear(mats)
        for o in objs:
            o.parent = vacio
            o.name = o.data.name = f"{nombre}_{o.name.split('.')[0]}"
        print("TRIANGULOS", nombre, conteo, "total", sum(conteo.values()))
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Deco_Zona1.fbx"),
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
    print("  FBX Deco_Zona1.fbx")


def exportar_zona2():
    """Deco_Zona2.fbx: piezas que son solo de las Dunas. Raíz Deco_Zona2 con un vacío Piramide y
    su malla Piramide_Piramide. Sin textura: el juego pone el color y TextureID = Studs.png."""
    M.limpiar_escena()
    raiz = bpy.data.objects.new("Deco_Zona2", None)
    bpy.context.scene.collection.objects.link(raiz)
    for nombre, crear, mats in (("Piramide", piramide, mats_piramide()),):
        vacio = bpy.data.objects.new(nombre, None)
        bpy.context.scene.collection.objects.link(vacio)
        vacio.parent = raiz
        objs, conteo = crear(mats)
        for o in objs:
            o.parent = vacio
            o.name = o.data.name = f"{nombre}_{o.name.split('.')[0]}"
        print("TRIANGULOS", nombre, conteo, "total", sum(conteo.values()))
    bpy.ops.object.select_all(action="DESELECT")
    for o in [raiz, *raiz.children_recursive]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Deco_Zona2.fbx"),
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
    print("  FBX Deco_Zona2.fbx")


if __name__ == "__main__":
    if "--exportar-zona2" in sys.argv:
        M.FBX.mkdir(parents=True, exist_ok=True)
        exportar_zona2()
        sys.argv.append("--solo-fbx")
    if "--exportar-zona1" in sys.argv:
        M.FBX.mkdir(parents=True, exist_ok=True)
        exportar_zona1()
        sys.argv.append("--solo-fbx")
    if "--exportar-zona5" in sys.argv:
        M.FBX.mkdir(parents=True, exist_ok=True)
        exportar_zona5()
        sys.argv.append("--solo-fbx")
    if "--solo-fbx" in sys.argv:
        print("Listo")
        sys.exit(0)
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
    if "--pieza" not in sys.argv or "Columna_Estelar" in sys.argv:
        render_columna()
    if "--pieza" not in sys.argv or "Isla_Flotante" in sys.argv:
        render_isla()
    if "--pieza" not in sys.argv or "Cristales_Abismo" in sys.argv:
        render_racimo()
    if "--pieza" not in sys.argv or "Arbol_Nebuloso" in sys.argv:
        render_arbol()
    for pieza in ARBOLES_PRADERA:
        if "--pieza" not in sys.argv or pieza in sys.argv:
            render_arbol_pradera(pieza)
    if "--pieza" not in sys.argv or "Roca_Meteorito" in sys.argv:
        render_meteorito()
    if "--pieza" not in sys.argv or "Racimo_Cuarzo" in sys.argv:
        render_cuarzo()
    if "--pieza" not in sys.argv or "Cascada_Cristal" in sys.argv:
        render_cascada()
    if "--pieza" not in sys.argv or "Piramide" in sys.argv:
        render_piramide()
    print("Listo")
