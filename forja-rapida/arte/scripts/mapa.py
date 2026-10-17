"""Mapa de Forja Rápida: la plaza, los 5 biomas, las cámaras secretas y la Dimensión Prisma.

El mapa se diseña acá con cubitos de 2 studs (vóxeles, el estilo del juego; el terreno grande va
de a 4) y sale como datos para Roblox (src/server/MapaDatos.luau): bloques ya juntados en cajas
grandes (así son pocas partes) y marcadores (puntos de geoda, vitrinas, puertas, cofres, altares,
portales, la ruleta, carteles...). En el juego lo arma src/server/GeneradorMapa.luau, así el mapa
vive en git y no hay que subir mallas.

Cómo es (x para los costados, z hacia adelante, y para arriba; todo en studs):
  Plaza (z -136 a 0, x -116 a 116): el Spawn al medio; la fuente con las 8 Vitrinas alrededor;
    el Museo a la izquierda; la Ruleta de Mascotas en su escenario a la derecha, mirando al
    Spawn; el Santuario del Renacer al fondo (patio cerrado con una sola entrada, PuertaRenacer,
    y 4 puntos de Geoda Renacida); los 2 Tableros en la pared del fondo; el lugar del Jefe
    Ancestral; carteles de Misiones y de Renacer; faroles, bancos, canteros y árboles.
  5 biomas seguidos (240 de largo, caminables de x -116 a 116), separados por un muro con
    portón. Cada uno: riscos con escalones a los costados (con decoración arriba), unos 23 puntos
    de geoda en filas, el Jefe al fondo, un altar, rocas de decoración con los colores de las 3
    variantes de geoda del bioma y su propia decoración (árboles, pinos, flores, palmeras, oasis,
    cactus, arcos, dunas, picos y lago de hielo, volcán, ríos y charcos de lava, columnas de
    basalto y de cristal, islas flotantes, hongos que brillan). En el risco derecho, la cámara
    secreta con su túnel, la PuertaSecreta, el Cofre, 2 puntos de Geoda Oculta y una pista del
    bioma al lado de la puerta.
  En las Dunas, el Portal detrás de una duna: lleva a la Dimensión Prisma, una isla que flota
    arriba del medio del mapa (y 200), con 5 puntos de Geoda Prismática.

Uso (desde la raíz del repositorio):
  python3 forja-rapida/arte/scripts/mapa.py                 solo los datos (necesita NumPy)
  <python de Blender> forja-rapida/arte/scripts/mapa.py --render   datos y renders (arte/renders/mapa_*.jpg)
"""

import contextlib
import json
import math
import os
import random
import sys

import numpy as np

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
SALIDA = os.path.join(RAIZ, "src", "server", "MapaDatos.luau")
RENDERS = os.path.join(RAIZ, "arte", "renders")

V = 4  # studs del cubo del terreno (riscos, muros, manchas del piso)
F = 2  # studs de cada celda de la grilla (la decoración usa cubitos de 2)

# Materiales: nombre -> (color, material de Roblox, transparencia, choca)
MATERIALES = {
    "Pasto": ("#7ED957", "Grass", 0, True),
    "PastoOscuro": ("#5BB83E", "Grass", 0, True),
    "Tierra": ("#8B5A2B", "Ground", 0, True),
    "Piedra": ("#8D939C", "Slate", 0, True),
    "PiedraClara": ("#B9C2CC", "Slate", 0, True),
    "Arena": ("#F2D27A", "Sand", 0, True),
    "ArenaOscura": ("#E0B65C", "Sand", 0, True),
    "Arenisca": ("#D9A05B", "Sandstone", 0, True),
    "Nieve": ("#F4FAFF", "Snow", 0, True),
    "Hielo": ("#A8E6FF", "Ice", 0, True),
    "RocaHelada": ("#7FA6C9", "Slate", 0, True),
    "Basalto": ("#3A2E33", "Basalt", 0, True),
    "BasaltoClaro": ("#5A4A50", "Basalt", 0, True),
    "Lava": ("#FF5A00", "Neon", 0, True),
    "PiedraEstelar": ("#2E2A5C", "Slate", 0, True),
    "PolvoEstelar": ("#4B3F8F", "Slate", 0, True),
    "CristalCuarzo": ("#C77DFF", "Glass", 0.1, True),
    "CristalAmbar": ("#FFB627", "Glass", 0.1, True),
    "CristalZafiro": ("#3D7BFF", "Glass", 0.1, True),
    "CristalRubi": ("#FF2E4D", "Glass", 0.1, True),
    "CristalEstelar": ("#7CF5FF", "Neon", 0, True),
    "Madera": ("#8A5A2B", "Wood", 0, True),
    "Hojas": ("#4FB34F", "Grass", 0, True),
    "Cactus": ("#3FA34D", "Grass", 0, True),
    "Baldosa": ("#E3E8F2", "Pavement", 0, True),
    "BaldosaOscura": ("#AEB6C4", "Pavement", 0, True),
    "Oro": ("#FFC83D", "Foil", 0, True),
    "Agua": ("#7CC8FF", "Glass", 0.45, False),
    "Muro": ("#3A3F66", "Slate", 0, True),
    "PrismaBlanco": ("#F2F7FF", "Glass", 0.05, True),
    "PrismaRosa": ("#FF9ED8", "Glass", 0.1, True),
    "PrismaCian": ("#9CFBFF", "Glass", 0.1, True),
    "PrismaVioleta": ("#C99BFF", "Neon", 0, True),
    # árboles, plantas y flores (las flores y los tallos no chocan: no traban al caminar)
    "HojasOscuras": ("#2F8F3A", "Grass", 0, True),
    "HojasClaras": ("#8EDB5A", "LeafyGrass", 0, True),
    "Pino": ("#2E8B57", "Grass", 0, True),
    "PinoOscuro": ("#1F6340", "Grass", 0, True),
    "MaderaOscura": ("#5C3A1E", "Wood", 0, True),
    "MaderaQuemada": ("#2B2326", "Wood", 0, True),
    "Palmera": ("#B98A55", "Wood", 0, True),
    "PalmeraHojas": ("#5CC43F", "Grass", 0, True),
    "CactusOscuro": ("#2E7F3B", "Grass", 0, True),
    "Tallo": ("#3E9B3A", "Grass", 0, False),
    "FlorRosa": ("#FF8FD8", "SmoothPlastic", 0, False),
    "FlorAmarilla": ("#FFE14D", "SmoothPlastic", 0, False),
    "FlorBlanca": ("#FFFFFF", "SmoothPlastic", 0, False),
    "FlorRoja": ("#FF5A5F", "SmoothPlastic", 0, False),
    "TalloHongo": ("#E8E0FF", "SmoothPlastic", 0, True),
    # terreno extra
    "AreniscaOscura": ("#B9833F", "Sandstone", 0, True),
    "HieloClaro": ("#D6F3FF", "Glacier", 0, True),
    "HieloOscuro": ("#6FB8E6", "Ice", 0, True),
    "Brasa": ("#FF7A00", "Neon", 0, True),
    # plaza, Ruleta y Santuario
    "Marmol": ("#F4F1EA", "Marble", 0, True),
    "OroViejo": ("#E8A317", "Foil", 0, True),
    "CristalFenix": ("#FF6A3D", "Neon", 0, True),
    "Hierro": ("#3E3A39", "SmoothPlastic", 0, True),
    "Farol": ("#FFE9A8", "Neon", 0, True),
    "Tablas": ("#D9A066", "WoodPlanks", 0, True),
    # rocas de decoración: los colores de las variantes de geoda de cada bioma (GameConfig)
    "RocaCuarzo": ("#6E7487", "Slate", 0, True),
    "RocaMusgosa": ("#5E8C4A", "Slate", 0, True),
    "RocaCaliza": ("#D8D2C0", "Limestone", 0, True),
    "RocaAmbar": ("#B07A4A", "Sandstone", 0, True),
    "RocaArenisca": ("#C4553A", "Sandstone", 0, True),
    "RocaDesertica": ("#E8C98A", "Sand", 0, True),
    "RocaEscarcha": ("#E8F4FF", "Glacier", 0, True),
    "RocaProfunda": ("#2F5D8A", "Slate", 0, True),
    "RocaRubi": ("#4A3338", "Basalt", 0, True),
    "RocaObsidiana": ("#1E1A24", "Basalt", 0, True),
    "RocaAzufre": ("#6B5A2E", "Slate", 0, True),
    "RocaNebulosa": ("#4B2A6B", "Slate", 0, True),
    "RocaMeteorito": ("#3B3B3B", "Basalt", 0, True),
    "CristalRosa": ("#FF8FD8", "Glass", 0.1, True),
    "CristalCielo": ("#7CF5FF", "Glass", 0.1, True),
    "CristalLimon": ("#FFE14D", "Glass", 0.1, True),
    "CristalNaranja": ("#FF8C42", "Glass", 0.1, True),
    "CristalHielo": ("#B8F3FF", "Glass", 0.1, True),
    "CristalAzufre": ("#F5FF4D", "Neon", 0, True),
    "CristalNebulosa": ("#FF6FD8", "Neon", 0, True),
    "CristalMeteorito": ("#FFB347", "Neon", 0, True),
}
NOMBRES = list(MATERIALES)
ID = {n: i + 1 for i, n in enumerate(NOMBRES)}

# Biomas (zona -> materiales)
BIOMAS = {
    1: {"Piso": "Pasto", "Piso2": "PastoOscuro", "Risco": "Piedra", "Tapa": "Pasto", "Cristal": "CristalCuarzo"},
    2: {"Piso": "Arena", "Piso2": "ArenaOscura", "Risco": "Arenisca", "Tapa": "Arena", "Cristal": "CristalAmbar"},
    3: {"Piso": "Nieve", "Piso2": "Hielo", "Risco": "RocaHelada", "Tapa": "Nieve", "Cristal": "CristalZafiro"},
    4: {"Piso": "Basalto", "Piso2": "BasaltoClaro", "Risco": "Basalto", "Tapa": "BasaltoClaro", "Cristal": "CristalRubi"},
    5: {"Piso": "PiedraEstelar", "Piso2": "PolvoEstelar", "Risco": "PiedraEstelar", "Tapa": "PolvoEstelar", "Cristal": "CristalEstelar"},
}
# Rocas de decoración de cada bioma: (piedra, cristal) de sus 3 variantes de geoda
ROCAS = {
    1: [("RocaCuarzo", "CristalCuarzo"), ("RocaMusgosa", "CristalRosa"), ("RocaCaliza", "CristalCielo")],
    2: [("RocaAmbar", "CristalAmbar"), ("RocaArenisca", "CristalLimon"), ("RocaDesertica", "CristalNaranja")],
    3: [("RocaHelada", "CristalZafiro"), ("RocaEscarcha", "CristalCielo"), ("RocaProfunda", "CristalHielo")],
    4: [("RocaRubi", "CristalRubi"), ("RocaObsidiana", "Brasa"), ("RocaAzufre", "CristalAzufre")],
    5: [("PiedraEstelar", "CristalEstelar"), ("RocaNebulosa", "CristalNebulosa"), ("RocaMeteorito", "CristalMeteorito")],
}

LARGO = 240  # largo de cada bioma
MURO = 8  # muro entre biomas
XMIN, XMAX = -88, 88  # zona caminable (17/10, plan v5: más angosto)
X0, X1 = XMIN - 36, XMAX + 52  # la grilla: el risco derecho es más grueso (ahí van las cámaras)
Y0, Y1 = -4, 92
PLAZA = -136  # la plaza va de z -136 a 0
Z0 = PLAZA - 8  # pared del fondo

# Plaza
SPAWN = (0, -14)
FUENTE = (0, -70)
SANTUARIO = (-44, -136, 44, -100)  # x0, z0, x1, z1 (z1 = cara de afuera de la pared con la puerta)
# piezas de arte/fbx/Lobby.fbx (las pone GeneradorMapa si están en ServerStorage > Modelos > Lobby)
# como el dibujo de Juani (17/10): parcelas al fondo, Ruleta en el medio, Banco y Tienda a los
# costados y el Spawn adelante, cerca del arco. Lo demás (Museo, Santuario, tableros, vitrinas y
# el Jefe Ancestral) va en el patio de la izquierda.
ESCALA_TIENDAS = 1.3  # el Banco y la Tienda, un poco más grandes que la pieza
# plan v5 (17/10): Banco y Tienda al frente (cerca de la puerta) mirando al medio, la Ruleta en
# el centro del lobby, 4 parcelas en fila al fondo y 1 a cada costado. Sin Museo ni Santuario.
PUESTO = (-50, -24)  # Puesto_Vender (el Banco)
TIENDA = (50, -24)  # Tienda_Forja
RULETA = (0, -70)  # Ruleta_Mascotas en el centro, mirando al Spawn
RUEDA_ALTO = 10.5  # centro de su rueda (lobby.py: RUEDA_Z)
ARCO = (0, -2)  # Arco_Entrada, adelante del arco de piedra hacia la Pradera
# calle de las parcelas de exhibición, saliendo por un pasillo en la pared izquierda
ESCALA_PARCELAS = 1.0  # parcelas de 40 x 32
# (x, z, giro): 4 en fila contra la pared del fondo (entrada hacia +z) y 1 a cada costado
# (entrada hacia el medio)
PARCELAS = (
    (-66, -118, 180),
    (-22, -118, 180),
    (22, -118, 180),
    (66, -118, 180),
    (-72, -66, 270),
    (72, -66, 90),
)
PATIO_X0 = -320  # patio de la izquierda: de x -320 a -136
DX_SANTUARIO = -200  # el Santuario y el Museo se arman como antes, corridos en x
DX_MUSEO = -170
PASILLO = (-136, 0)  # la pared izquierda se saca entera: plaza y parcelas son un solo campo
MUSEO = (-116, -100, -80, -52)
ANCESTRAL = (-200, -40)

DIFICULTAD = {2: "MEDIO", 3: "DIFÍCIL", 4: "MUY DIFÍCIL", 5: "EXTRA DIFÍCIL"}

# Puntos de geoda de cada bioma (15 por bioma, plan v5): (distancia desde el comienzo del bioma, columnas x)
FILAS_GEODAS = (
    (30, (-64, -36, 36, 64)),
    (76, (-50, 50)),
    (118, (-64, -36, 36, 64)),
    (160, (-50, 50)),
    (200, (-62, -36, 48)),
)


def inicio_zona(n):
    return 8 + (n - 1) * (LARGO + MURO)


def fin_zona(n):
    return inicio_zona(n) + LARGO


def puerta_secreta_z(n):
    """z de la puerta secreta del bioma n (las impares más al fondo)."""
    return inicio_zona(n) + 80 + (n % 2) * 56


Z1 = fin_zona(5) + MURO


def par(v):
    """Redondea a un número par de studs (la grilla es de 2)."""
    return int(round(v / 2)) * 2


def mirar(desde, hacia):
    """Giro (grados) para que el frente de una parte (su -Z) mire de `desde` hacia `hacia` (x, z)."""
    dx, dz = hacia[0] - desde[0], hacia[1] - desde[1]
    return round(math.degrees(math.atan2(-dx, -dz))) % 360


class Grilla:
    """Cubitos de 2 studs. Las coordenadas son studs del mundo (pares)."""

    def __init__(self, x0, y0, z0, x1, y1, z1):
        self.x0, self.y0, self.z0 = x0, y0, z0
        self.c = np.zeros(((x1 - x0) // F, (y1 - y0) // F, (z1 - z0) // F), dtype=np.uint8)
        self.dy = 0  # ver subir()

    @staticmethod
    def rango(a0, a1, b0, n):
        i0 = max(0, int((a0 - b0) // F))
        i1 = min(n, int(-(-(a1 - b0) // F)))
        return i0, i1

    def poner(self, x0, y0, z0, x1, y1, z1, mat):
        """Llena la caja de (x0, y0, z0) a (x1, y1, z1) con un material (None la vacía)."""
        nx, ny, nz = self.c.shape
        i0, i1 = self.rango(x0, x1, self.x0, nx)
        j0, j1 = self.rango(y0 + self.dy, y1 + self.dy, self.y0, ny)
        k0, k1 = self.rango(z0, z1, self.z0, nz)
        if i0 < i1 and j0 < j1 and k0 < k1:
            self.c[i0:i1, j0:j1, k0:k1] = 0 if mat is None else ID[mat]

    def columna(self, x, z, y0, y1, mat, lado=V):
        self.poner(x, y0, z, x + lado, y1, z + lado, mat)

    @contextlib.contextmanager
    def subir(self, dy):
        """Lo que se pone adentro queda dy studs más arriba (arriba de un risco o del escenario)."""
        antes, self.dy = self.dy, dy
        try:
            yield
        finally:
            self.dy = antes

    def cajas(self):
        """Junta cubitos iguales en cajas grandes (greedy meshing en 3D). Recorre solo las celdas
        llenas de cada capa, así una grilla grande y casi vacía no tarda."""
        c = self.c
        nx, ny, nz = c.shape
        usado = np.zeros(c.shape, dtype=bool)
        salida = []
        for j in range(ny):
            ks, iss = np.nonzero(c[:, j, :].T)  # ordenadas por z y después por x
            for k, i in zip(ks.tolist(), iss.tolist()):
                if usado[i, j, k]:
                    continue
                m = c[i, j, k]
                a = 1
                while i + a < nx and c[i + a, j, k] == m and not usado[i + a, j, k]:
                    a += 1
                b = 1
                while k + b < nz and np.all(c[i : i + a, j, k + b] == m) and not np.any(usado[i : i + a, j, k + b]):
                    b += 1
                h = 1
                while j + h < ny and np.all(c[i : i + a, j + h, k : k + b] == m) and not np.any(usado[i : i + a, j + h, k : k + b]):
                    h += 1
                usado[i : i + a, j : j + h, k : k + b] = True
                salida.append(
                    (NOMBRES[m - 1], self.x0 + i * F, self.y0 + j * F, self.z0 + k * F, a * F, h * F, b * F)
                )
        return salida


class Suelo:
    """Lo ocupado en el piso, visto de arriba (celdas de 2 studs): los puntos de geoda, el camino,
    las puertas y cada decoración marcan su lugar, así nada se pisa."""

    def __init__(self, g):
        self.x0, self.z0 = g.x0, g.z0
        self.o = np.zeros((g.c.shape[0], g.c.shape[2]), dtype=bool)

    def _r(self, x0, z0, x1, z1):
        nx, nz = self.o.shape
        return (
            max(0, int((x0 - self.x0) // F)),
            min(nx, int(-(-(x1 - self.x0) // F))),
            max(0, int((z0 - self.z0) // F)),
            min(nz, int(-(-(z1 - self.z0) // F))),
        )

    def marcar(self, x0, z0, x1, z1):
        i0, i1, k0, k1 = self._r(x0, z0, x1, z1)
        self.o[i0:i1, k0:k1] = True

    def libre(self, x0, z0, x1, z1):
        i0, i1, k0, k1 = self._r(x0, z0, x1, z1)
        return not self.o[i0:i1, k0:k1].any()


# Piezas de Blender (arte/fbx/Deco_Comun y Deco_Zona1..5): ancho x alto x fondo en studs (de los
# FBX). GeneradorMapa las copia de ServerStorage.Modelos.Deco y las apoya con el centro de su base en
# el marcador; el frente mira a -z con giro 0.
PIEZAS = {
    "Arbol_Grande": (17, 14, 10), "Arbol_Mediano": (10, 9, 7), "Arbol_Rosa": (10, 9, 7),
    "Arbol_Seco": (16, 16, 8), "Arbusto": (6, 5, 3), "Racimo_Cuarzo": (9, 11, 9),
    "Cascada_Cristal": (10, 14, 13),
    "Arbol_Seco_Desierto": (18, 22, 8), "Cactus_Chico": (3, 4, 2), "Cactus_Mediano": (6, 7, 3),
    "Cactus_Grande": (9, 11, 4), "Duna_Chica": (16, 3, 10), "Duna_Mediana": (28, 5, 16),
    "Duna_Grande": (44, 9, 24), "Esqueleto": (16, 11, 9), "Piramide": (64, 30, 64),
    "Racimo_Ambar": (9, 4, 7),
    "Escalones_Nevados_1": (12, 10, 9), "Escalones_Nevados_2": (11, 5, 7), "Hielo_Suelto": (8, 3, 5),
    "Lago_Congelado": (24, 2, 16), "Monte_Nevado_Chico": (16, 10, 10),
    "Monte_Nevado_Mediano": (28, 18, 16), "Monte_Nevado_Grande": (40, 24, 24),
    "Pico_Hielo": (11, 11, 8), "Pino_Nevado_Chico": (10, 11, 10), "Pino_Nevado_Grande": (15, 19, 14),
    "Arbol_Quemado": (11, 17, 9), "Columnas_Basalto_1": (10, 14, 7), "Columnas_Basalto_2": (13, 16, 7),
    "Rio_Lava_Curva": (14, 3, 14), "Rio_Lava_Recto": (16, 3, 12), "Roca_Lava_Chica": (9, 8, 8),
    "Roca_Lava_Mediana": (12, 10, 12), "Roca_Lava_Grande": (20, 12, 21), "Volcan": (60, 40, 56),
    "Arbol_Nebuloso": (31, 32, 19), "Columna_Estelar_Alta": (14, 44, 12),
    "Columna_Estelar_Baja": (14, 28, 13), "Cristales_Abismo": (10, 14, 10),
    "Isla_Flotante_Chica": (12, 16, 12), "Isla_Flotante_Mediana": (20, 20, 20),
    "Isla_Flotante_Grande": (28, 24, 28), "Roca_Meteorito_Chico": (12, 6, 12),
    "Roca_Meteorito_Grande": (20, 10, 21),
    "Losas_Chica": (8, 5, 6), "Losas_Mediana": (10, 7, 8), "Losas_Larga": (16, 7, 6),
    "Pared_Ladrillo": (16, 24, 5), "Risco_Escalon": (16, 30, 17), "Arcoiris": (72, 30, 16),
    "Nube_Bloques": (56, 20, 32),
}
# las que no se atraviesan (lo chico y las plantas no traban al caminar)
CHOCAN = ("Piramide", "Volcan", "Monte_Nevado", "Pared_Ladrillo", "Risco_Escalon", "Columna",
          "Roca_Lava_Grande", "Roca_Meteorito_Grande", "Escalones_Nevados", "Duna_Grande")


def tipo_pieza(nombre):
    """"Arbol_Grande_2" -> "Arbol_Grande"; "Pared_Ladrillo_Zona3" -> "Pared_Ladrillo"."""
    for k in sorted(PIEZAS, key=len, reverse=True):
        if nombre.startswith(k):
            return k
    raise KeyError(nombre)


def deco(nombre, x, z, giro=0, y=0, escala=1):
    tam = PIEZAS[tipo_pieza(nombre)]
    choca = any(nombre.startswith(c) for c in CHOCAN)
    marcador("Deco", (x, y, z), tuple(round(v * escala, 1) for v in tam), giro, Nombre=nombre, Escala=escala, Choca=choca)


def radio(nombre, escala=1):
    tam = PIEZAS[tipo_pieza(nombre)]
    return int(max(tam[0], tam[2]) * escala / 2) + 2


def poner_deco(s, rng, area, nombres, cuantas, valido=None, escala=1, intentos=120):
    """Reparte piezas al azar por el piso libre del bioma (cada una ocupa su lugar)."""
    for i in range(cuantas):
        nombre = nombres[i % len(nombres)] if isinstance(nombres, list) else nombres
        p = lugar(s, rng, area, radio(nombre, escala), intentos=intentos, valido=valido)
        if p:
            deco(nombre, p[0], p[1], rng.choice([0, 90, 180, 270]), escala=escala)


def lugar(s, rng, area, r, intentos=80, valido=None, rz=None):
    """Busca un lugar libre dentro de area = (x0, z0, x1, z1): un rectángulo de radio r en x (y rz
    en z, si no es el mismo). Lo marca y devuelve (x, z), o None si no hay. Entre las filas de
    puntos de geoda quedan franjas libres de 28 studs: lo grande va acostado a lo largo de x."""
    x0, z0, x1, z1 = area
    rx, rz = par(r), par(r if rz is None else rz)
    if x1 - x0 <= 2 * rx + 2 or z1 - z0 <= 2 * rz + 2:
        return None
    for _ in range(intentos):
        x = rng.randrange(par(x0) + rx, par(x1) - rx, 2)
        z = rng.randrange(par(z0) + rz, par(z1) - rz, 2)
        if (valido is None or valido(x, z)) and s.libre(x - rx, z - rz, x + rx, z + rz):
            s.marcar(x - rx, z - rz, x + rx, z + rz)
            return x, z
    return None


marcadores = []


def marcador(tipo, pos, tam=(2, 0.2, 2), giro=0, **atributos):
    marcadores.append({"Tipo": tipo, "Pos": [round(p, 2) for p in pos], "Tam": list(tam), "Giro": giro, "Atributos": atributos})


# --- formas básicas (studs; x, z sobre las líneas de la grilla) --------------------------------


def losa(g, cx, cz, y0, y1, mx, mz, mat, corte=2):
    """Rectángulo de 2*mx por 2*mz centrado en (cx, cz), con las esquinas cortadas."""
    if corte and mx > corte and mz > corte:
        g.poner(cx - mx + corte, y0, cz - mz, cx + mx - corte, y1, cz + mz, mat)
        g.poner(cx - mx, y0, cz - mz + corte, cx + mx, y1, cz + mz - corte, mat)
    else:
        g.poner(cx - mx, y0, cz - mz, cx + mx, y1, cz + mz, mat)


def disco(g, cx, cz, y0, y1, radio, mat, achatado=1.0):
    """Círculo de cubitos (lagos, charcos); con achatado < 1 queda una elipse más corta en z."""
    for x in range(cx - radio, cx + radio, F):
        for z in range(cz - radio, cz + radio, F):
            if math.hypot(x + 1 - cx, (z + 1 - cz) / achatado) <= radio:
                g.poner(x, y0, z, x + F, y1, z + F, mat)


def rama(g, x, z, y, d, mat, sale=2, sube=4):
    """Rama que sale del tronco (de 4 x 4 centrado en x, z) hacia d y después sube.
    Devuelve la esquina (x, y, z) de la punta."""
    dx, dz = d
    if dx:
        a = x + 2 if dx > 0 else x - 2 - sale
        g.poner(a, y, z - 2, a + sale, y + 2, z, mat)
        b = a + sale if dx > 0 else a - 2
        g.poner(b, y, z - 2, b + 2, y + 2 + sube, z, mat)
        return b, y + 2 + sube, z - 2
    a = z + 2 if dz > 0 else z - 2 - sale
    g.poner(x - 2, y, a, x, y + 2, a + sale, mat)
    b = a + sale if dz > 0 else a - 2
    g.poner(x - 2, y, b, x, y + 2 + sube, b + 2, mat)
    return x - 2, y + 2 + sube, b


LADOS = [(1, 0), (-1, 0), (0, 1), (0, -1)]


# --- decoración ----------------------------------------------------------------------------------


def arbol(g, x, z, rng):
    """Árbol de copa redonda: tronco con raíces y una rama, copa en capas de tres verdes. Radio 10."""
    alto = rng.choice([8, 10, 12])
    g.poner(x - 2, 0, z - 2, x + 2, alto + 2, z + 2, "Madera")
    g.poner(x - 4, 0, z - 2, x + 4, 2, z + 2, "Madera")  # raíces
    g.poner(x - 2, 0, z - 4, x + 2, 2, z + 4, "Madera")
    rama(g, x, z, alto - 4, rng.choice(LADOS), "Madera")
    dx, dz = rng.choice([-2, 0, 2]), rng.choice([-2, 0, 2])
    losa(g, x, z, alto, alto + 4, 8, 8, "HojasOscuras", 4)
    losa(g, x + dx, z + dz, alto + 4, alto + 10, 10, 10, "Hojas", 4)
    losa(g, x + dx, z + dz, alto + 10, alto + 14, 6, 6, "HojasClaras", 2)
    g.poner(x - 2, alto + 14, z - 2, x + 2, alto + 16, z + 2, "HojasClaras")


def pino(g, x, z, rng, nevado=False):
    """Pino de pisos, cada uno más angosto; el nevado tiene nieve en el borde de cada piso. Radio 10."""
    pisos = rng.choice([3, 4])
    g.poner(x - 2, 0, z - 2, x + 2, 4, z + 2, "MaderaOscura")
    y = 4
    for i in range(pisos):
        m = 2 * (pisos - i) + 2
        g.poner(x - m, y, z - m, x + m, y + 4, z + m, "PinoOscuro" if i % 2 == 0 else "Pino")
        if nevado:
            g.poner(x - m, y + 4, z - m, x + m, y + 6, z + m, "Nieve")  # el piso de arriba la tapa al medio
        y += 4
    g.poner(x - 2, y, z - 2, x + 2, y + 4, z + 2, "Pino")
    if nevado:
        g.poner(x - 2, y + 4, z - 2, x + 2, y + 6, z + 2, "Nieve")


def arbusto(g, x, z, rng, flores=()):
    """Arbusto de dos verdes, con flores si se le pasan colores. Radio 4."""
    losa(g, x, z, 0, 4, 4, 4, "HojasOscuras", 2)
    dx, dz = rng.choice([-2, 0]), rng.choice([-2, 0])
    g.poner(x - 2 + dx, 4, z - 2 + dz, x + 2 + dx, 6, z + 2 + dz, "Hojas")
    if flores:
        g.poner(x - 4, 4, z - 2, x - 2, 6, z, rng.choice(flores))
        g.poner(x + 2, 4, z, x + 4, 6, z + 2, rng.choice(flores))


def flores(g, x, z, rng, colores):
    """Mancha de flores con tallo (no chocan). Radio 6."""
    for _ in range(rng.randint(4, 7)):
        fx, fz = x + rng.randrange(-6, 5, 2), z + rng.randrange(-6, 5, 2)
        alto = rng.choice([0, 2])
        if alto:
            g.poner(fx, 0, fz, fx + 2, alto, fz + 2, "Tallo")
        g.poner(fx, alto, fz, fx + 2, alto + 2, fz + 2, rng.choice(colores))


def roca(g, x, z, rng, estilo):
    """Roca de decoración con los colores de una variante de geoda y cristales que asoman. Radio 8."""
    piedra, cristal = estilo
    grande = rng.random() < 0.45
    mx, mz = (6, 4) if grande else (4, 4)
    if rng.random() < 0.5:
        mx, mz = mz, mx
    alto = 6 if grande else 4
    losa(g, x, z, 0, alto, mx, mz, piedra, 2)
    cx, cz = x + rng.choice([-2, 0]), z + rng.choice([-2, 0])
    arriba = alto + (4 if grande else 2)
    losa(g, cx, cz, alto, arriba, mx - 2, mz - 2, piedra, 2 if min(mx, mz) > 4 else 0)
    g.poner(cx - 2, arriba - 2, cz - 2, cx, arriba + (6 if grande else 4), cz, cristal)
    g.poner(cx, arriba - 2, cz, cx + 2, arriba + 2, cz + 2, cristal)
    if grande:
        g.poner(x + mx - 2, 2, z - 2, x + mx, alto + 2, z, cristal)


def racimo(g, x, z, rng, cristal):
    """Racimo de cristales: uno alto con punta y tres más chicos alrededor, algo inclinados. Radio 6."""
    h = rng.choice([10, 12, 14])
    g.poner(x - 2, 0, z - 2, x + 2, h, z + 2, cristal)
    g.poner(x - 2, h, z - 2, x, h + 2, z, cristal)
    for (dx, dz), hh in zip(rng.sample([(2, -2), (-4, 0), (0, 2), (-2, -4)], 3), (8, 6, 4)):
        g.poner(x + dx, 0, z + dz, x + dx + 2, hh, z + dz + 2, cristal)
        ox = 2 if dx > 0 else (-2 if dx < -2 else 0)
        oz = 2 if dz > 0 else (-2 if dz < -2 else 0)
        g.poner(x + dx + ox, hh - 2, z + dz + oz, x + dx + ox + 2, hh + 2, z + dz + oz + 2, cristal)


def palmera(g, x, z, rng):
    """Palmera de tronco curvo con anillos, hojas en cruz que caen en la punta y cocos. Radio 12."""
    d = rng.choice(LADOS)
    px, pz, y = x, z, 0
    for i in range(5):
        g.poner(px - 2, y, pz - 2, px + 2, y + 4, pz + 2, "Palmera" if i % 2 == 0 else "Madera")
        y += 4
        if i in (1, 3):
            px, pz = px + 2 * d[0], pz + 2 * d[1]
    g.poner(px - 2, y, pz - 2, px + 2, y + 2, pz + 2, "PalmeraHojas")
    for dx, dz in LADOS:
        if dx:
            a = px + 2 if dx > 0 else px - 10
            g.poner(a, y, pz - 2, a + 8, y + 2, pz + 2, "PalmeraHojas")
            b = a + 8 if dx > 0 else a - 4
            g.poner(b, y - 2, pz - 2, b + 4, y, pz + 2, "PalmeraHojas")
        else:
            a = pz + 2 if dz > 0 else pz - 10
            g.poner(px - 2, y, a, px + 2, y + 2, a + 8, "PalmeraHojas")
            b = a + 8 if dz > 0 else a - 4
            g.poner(px - 2, y - 2, b, px + 2, y, b + 4, "PalmeraHojas")
    for sx, sz in ((1, 1), (-1, -1), (1, -1), (-1, 1)):  # hojas cortas en diagonal, más arriba
        ax = px + 2 if sx > 0 else px - 6
        az = pz + 2 if sz > 0 else pz - 6
        g.poner(ax, y + 2, az, ax + 4, y + 4, az + 4, "PalmeraHojas")
    g.poner(px - 2, y - 2, pz - 2, px, y, pz, "MaderaOscura")  # cocos
    g.poner(px, y - 2, pz, px + 2, y, pz + 2, "MaderaOscura")


def cactus(g, x, z, rng):
    """Cactus con dos brazos y una flor arriba. Radio 10."""
    h = rng.choice([12, 14, 16])
    g.poner(x - 2, 0, z - 2, x + 2, h, z + 2, "Cactus")
    g.poner(x - 2, 0, z - 2, x, h - 2, z, "CactusOscuro")  # una costilla más oscura
    for (dx, dz), ya in zip(rng.sample(LADOS, 2), (rng.choice([4, 6]), rng.choice([6, 8]))):
        sube = rng.choice([4, 6, 8])
        if dx:
            a = x + 2 if dx > 0 else x - 6
            g.poner(a, ya, z - 2, a + 4, ya + 4, z + 2, "Cactus")
            b = a + 4 if dx > 0 else a - 4
            g.poner(b, ya, z - 2, b + 4, ya + 4 + sube, z + 2, "Cactus")
        else:
            a = z + 2 if dz > 0 else z - 6
            g.poner(x - 2, ya, a, x + 2, ya + 4, a + 4, "Cactus")
            b = a + 4 if dz > 0 else a - 4
            g.poner(x - 2, ya, b, x + 2, ya + 4 + sube, b + 4, "Cactus")
    g.poner(x - 2, h, z, x, h + 2, z + 2, rng.choice(["FlorRosa", "FlorAmarilla", "FlorRoja"]))


def cactus_bola(g, x, z, rng):
    """Cactus chiquito y redondo con flor. Radio 4."""
    g.poner(x - 2, 0, z - 2, x + 2, 4, z + 2, "Cactus")
    g.poner(x - 2, 4, z - 2, x, 6, z, rng.choice(["FlorRosa", "FlorAmarilla"]))


def arco(g, x, z, rng, largo_x=True):
    """Arco de arenisca con vetas oscuras, a lo largo de x (o de z). Mide 28 x 6."""

    def caja(a0, y0, b0, a1, y1, b1, mat):
        if largo_x:
            g.poner(x + a0, y0, z + b0, x + a1, y1, z + b1, mat)
        else:
            g.poner(x + b0, y0, z + a0, x + b1, y1, z + a1, mat)

    alto = rng.choice([14, 16, 18])
    for a in (-14, 8):
        caja(a, 0, -4, a + 6, alto, 2, "Arenisca")
        caja(a, 6, -4, a + 6, 8, 2, "AreniscaOscura")
    caja(-14, alto, -4, 14, alto + 6, 2, "Arenisca")
    caja(-8, alto - 2, -4, -6, alto, 2, "Arenisca")  # el arco por dentro
    caja(6, alto - 2, -4, 8, alto, 2, "Arenisca")
    caja(-14, alto + 2, -4, 14, alto + 4, 2, "AreniscaOscura")
    caja(-10, alto + 6, -2, 10, alto + 8, 2, "Arenisca")


def duna(g, x, z, rng, largo, alto, viento=1):
    """Duna en terrazas: losas cada vez más chicas, corridas hacia donde sopla el viento.
    Radio largo + 2."""
    pisos = max(1, alto // 4)
    for i in range(pisos):
        f = 1 - i / (pisos + 0.5)
        mx, mz = max(4, par(largo * f)), max(4, par(largo * 0.7 * f))
        losa(g, x + viento * par(i * 3), z, i * 4, i * 4 + 4, mx, mz, "Arena" if i % 2 == 0 else "ArenaOscura", 4 if min(mx, mz) > 8 else 2)


def oasis(g, s, x, z, rng):
    """Charco de agua con borde de arena, juncos, flores y dos palmeras en las puntas. Mide 56 x 24."""
    losa(g, x, z, -4, 0, 16, 10, "ArenaOscura", 4)
    losa(g, x, z, -2, 0, 12, 6, "Agua", 4)  # el agua no choca: se pisa el fondo
    for jx, jz in ((-12, -4), (10, 4), (-4, 6), (6, -8)):
        g.poner(x + jx, 0, z + jz, x + jx + 2, 4, z + jz + 2, "PalmeraHojas")
    for fx, fz in ((-16, 8), (14, -10), (0, 10)):
        g.poner(x + fx, 0, z + fz, x + fx + 2, 2, z + fz + 2, "FlorRosa")
    palmera(g, x - 20, z - 2, rng)
    palmera(g, x + 20, z + 2, rng)


def pico_hielo(g, x, z, rng, alto=None):
    """Pico de hielo en capas: base oscura, cuerpo, punta clara y un pico chico al costado. Radio 6."""
    alto = alto or rng.choice([12, 16, 20, 24])
    g.poner(x - 4, 0, z - 4, x + 4, par(alto * 0.3), z + 4, "HieloOscuro")
    g.poner(x - 2, 0, z - 4, x + 4, par(alto * 0.65), z + 2, "Hielo")
    g.poner(x - 2, 0, z - 2, x + 2, alto, z + 2, "HieloClaro")
    g.poner(x, alto, z - 2, x + 2, alto + 2, z, "HieloClaro")
    g.poner(x - 6, 0, z, x - 4, par(alto * 0.45), z + 2, "Hielo")


def lago_helado(g, x, z, rng):
    """Lago congelado (a ras del piso) con una mancha oscura, bloques de hielo y nieve en el borde.
    Mide 44 x 24."""
    disco(g, x, z, -4, 0, 20, "Hielo", achatado=0.5)
    disco(g, x + 6, z - 2, -2, 0, 6, "HieloOscuro", achatado=0.6)
    g.poner(x - 8, 0, z + 2, x - 4, 2, z + 6, "HieloClaro")
    g.poner(x + 10, 0, z, x + 12, 2, z + 4, "HieloClaro")
    for bx, bz, ax, az in ((-20, -4, 4, 8), (18, -6, 4, 8), (-6, 8, 12, 4)):
        g.poner(x + bx, 0, z + bz, x + bx + ax, 2, z + bz + az, "Nieve")


def ventisquero(g, x, z, rng):
    """Montoncito de nieve en capas. Radio 8."""
    losa(g, x, z, 0, 2, 8, 6, "Nieve", 2)
    losa(g, x + 2, z, 2, 4, 6, 4, "Nieve", 2)
    g.poner(x, 4, z - 2, x + 6, 6, z + 2, "HieloClaro" if rng.random() < 0.3 else "Nieve")


def arbol_quemado(g, x, z, rng):
    """Árbol quemado: tronco negro, ramas peladas y una brasa en la punta de una rama. Radio 6."""
    h = rng.choice([10, 12, 14])
    g.poner(x - 2, 0, z - 2, x + 2, h, z + 2, "MaderaQuemada")
    g.poner(x - 4, 0, z - 2, x + 4, 2, z + 2, "MaderaQuemada")
    for i, d in enumerate(rng.sample(LADOS, 3)):
        px, py, pz = rama(g, x, z, h - 8 + i * 2, d, "MaderaQuemada", sube=rng.choice([2, 4]))
        if i == 0:
            g.poner(px, py, pz, px + 2, py + 2, pz + 2, "Brasa")
    g.poner(x - 2, 4, z - 2, x, 6, z, "Brasa")  # grieta que brilla en el tronco


def basalto(g, x, z, rng):
    """Grupo de columnas de basalto de distintas alturas. Radio 8."""
    lugares = [(0, 0), (4, 0), (-4, 0), (0, 4), (0, -4), (4, 4), (-4, -4), (4, -4)]
    for i, (dx, dz) in enumerate(lugares[: rng.randint(5, 8)]):
        h = 16 if i == 0 else rng.choice([4, 6, 8, 10, 12])
        g.poner(x + dx - 2, 0, z + dz - 2, x + dx + 2, h, z + dz + 2, "Basalto" if i % 2 else "BasaltoClaro")


def charco_lava(g, x, z, rng):
    """Charco de lava con borde alto de basalto y brasas. Radio 10."""
    m = rng.choice([6, 8])
    losa(g, x, z, 0, 2, m + 2, m + 2, "BasaltoClaro", 4)
    losa(g, x, z, 0, 2, m, m, None, 2)
    losa(g, x, z, -4, 0, m, m, "Lava", 2)
    g.poner(x + m, 2, z - 2, x + m + 2, 4, z + 2, "BasaltoClaro")
    g.poner(x - 2, 0, z - 2, x + 2, 2, z, "Brasa")


def volcan(g, cx, cz, rng):
    """Volcán en terrazas con cráter de lava y dos ríos de lava que bajan por las caras que se
    ven (hacia +x y hacia -z). Radio 32."""
    radios = [30, 26, 22, 18, 14, 10]
    for i, r in enumerate(radios):
        losa(g, cx, cz, i * 8, i * 8 + 8, r, r, "Basalto" if i % 2 == 0 else "BasaltoClaro", (r // 4) // 2 * 2)
    losa(g, cx, cz, 40, 48, 6, 6, None, 2)  # cráter
    losa(g, cx, cz, 38, 44, 6, 6, "Lava", 2)
    for eje, d in (("x", 1), ("z", -1)):
        corrido = 0
        for i in range(len(radios) - 1, 0, -1):
            r, r_abajo = radios[i], radios[i - 1]
            corrido = max(-6, min(6, corrido + rng.choice([-2, 0, 2])))
            a = cx + corrido if eje == "z" else cz + corrido
            if eje == "x":
                g.poner(cx + r - 2, i * 8, a - 2, cx + r, i * 8 + 8, a + 2, "Lava")  # por la pared
                g.poner(cx + r, i * 8 - 2, a - 2, cx + r_abajo, i * 8, a + 2, "Lava")  # por el escalón
            else:
                g.poner(a - 2, i * 8, cz - r, a + 2, i * 8 + 8, cz - r + 2, "Lava")
                g.poner(a - 2, i * 8 - 2, cz - r_abajo, a + 2, i * 8, cz - r, "Lava")
        if eje == "x":
            g.poner(cx + radios[0] - 2, 0, a - 2, cx + radios[0], 8, a + 2, "Lava")
        else:
            g.poner(a - 2, 0, cz - radios[0], a + 2, 8, cz - radios[0] + 2, "Lava")


def rio(g, s, puntos, mat="Lava", ancho=4):
    """Río de lava que une los puntos con tramos rectos (en x o en z), hecho con la pieza
    Rio_Lava_Recto (16 de largo) y Rio_Lava_Curva en cada esquina."""
    for (xa, za), (xb, zb) in zip(puntos, puntos[1:]):
        largo = abs(xb - xa) + abs(zb - za)
        pasos = max(1, round(largo / 16))
        for i in range(pasos):
            f = (i + 0.5) / pasos
            deco("Rio_Lava_Recto", xa + (xb - xa) * f, za + (zb - za) * f, 0 if za == zb else 90)
        s.marcar(min(xa, xb) - 7, min(za, zb) - 7, max(xa, xb) + 7, max(za, zb) + 7)
    for x, z in puntos[1:-1]:
        deco("Rio_Lava_Curva", x, z, 0)


def columna_cristal(g, x, z, rng, cristal):
    """Columna alta de cristal con base de piedra y cristales chicos al costado. Radio 6."""
    h = rng.choice([14, 18, 22, 26])
    losa(g, x, z, 0, 2, 4, 4, "PiedraEstelar", 2)
    g.poner(x - 2, 2, z - 2, x + 2, h, z + 2, cristal)
    g.poner(x - 2, h, z, x, h + 4, z + 2, cristal)
    g.poner(x + 2, 2, z - 2, x + 4, par(h * 0.5), z, cristal)
    g.poner(x - 4, 2, z, x - 2, par(h * 0.35), z + 2, cristal)


def isla(g, x, y, z, rng, cristal):
    """Isla que flota, con la panza en punta y cristales arriba."""
    losa(g, x, z, y, y + 4, 8, 8, "PiedraEstelar", 4)
    losa(g, x, z, y + 4, y + 6, 6, 6, "PolvoEstelar", 2)
    losa(g, x, z, y - 4, y, 4, 4, "PiedraEstelar", 2)
    g.poner(x - 2, y - 8, z - 2, x + 2, y - 4, z + 2, "PolvoEstelar")
    g.poner(x - 2, y + 6, z - 2, x + 2, y + 14, z + 2, cristal)
    g.poner(x + 2, y + 6, z, x + 4, y + 10, z + 2, cristal)
    g.poner(x - 4, y + 6, z - 4, x - 2, y + 8, z - 2, cristal)


def hongos(g, x, z, rng):
    """Dos o tres hongos de sombrero que brilla. Radio 10."""
    for i, (dx, dz) in enumerate([(0, 0), (6, 2), (-4, 6)][: rng.randint(2, 3)]):
        grande = i == 0
        h = rng.choice([6, 8, 10]) if grande else rng.choice([2, 4])
        m = 4 if grande else 2
        sombrero = rng.choice(["CristalNebulosa", "CristalEstelar"])
        if grande:
            g.poner(x + dx - 2, 0, z + dz - 2, x + dx + 2, h, z + dz + 2, "TalloHongo")
        else:
            g.poner(x + dx - 2, 0, z + dz - 2, x + dx, h, z + dz, "TalloHongo")
        losa(g, x + dx, z + dz, h, h + 2, m + 2, m + 2, sombrero, 2)
        losa(g, x + dx, z + dz, h + 2, h + 4, m, m, sombrero, 0)


def farol(g, x, z, luz=True):
    """Farol de plaza: base de piedra, poste de hierro y la luz arriba (el poste ocupa x..x+2)."""
    g.poner(x - 2, 0, z - 2, x + 4, 2, z + 4, "PiedraClara")
    g.poner(x, 2, z, x + 2, 12, z + 2, "Hierro")
    g.poner(x - 2, 12, z - 2, x + 4, 14, z + 4, "Hierro")
    g.poner(x - 2, 14, z - 2, x + 4, 18, z + 4, "Farol")
    g.poner(x, 18, z, x + 2, 20, z + 2, "Hierro")
    if luz:
        marcador("Luz", (x + 1, 16 + g.dy, z + 1), (1, 1, 1), 0, Color="#FFE9A8")


def banco(g, x, z, mira):
    """Banco de madera de 12 de largo; el que se sienta mira hacia `mira` (el respaldo va atrás)."""
    dx, dz = mira
    if dx:
        for pz in (z - 6, z + 4):
            g.poner(x, 0, pz, x + 4, 2, pz + 2, "Hierro")
        g.poner(x, 2, z - 6, x + 4, 4, z + 6, "Tablas")
        rx = x - 2 if dx > 0 else x + 4
        g.poner(rx, 2, z - 6, rx + 2, 8, z + 6, "Tablas")
    else:
        for px in (x - 6, x + 4):
            g.poner(px, 0, z, px + 2, 2, z + 4, "Hierro")
        g.poner(x - 6, 2, z, x + 6, 4, z + 4, "Tablas")
        rz = z - 2 if dz > 0 else z + 4
        g.poner(x - 6, 2, rz, x + 6, 8, rz + 2, "Tablas")


def cantero(g, x0, z0, x1, z1, rng, colores):
    """Cantero de piedra con pasto y flores."""
    g.poner(x0, 0, z0, x1, 2, z1, "PiedraClara")
    g.poner(x0 + 2, 0, z0 + 2, x1 - 2, 2, z1 - 2, "PastoOscuro")
    for fx in range(x0 + 2, x1 - 2, 4):
        for fz in range(z0 + 2, z1 - 2, 4):
            if rng.random() < 0.7:
                g.poner(fx, 2, fz, fx + 2, 4, fz + 2, rng.choice(colores))


def fuente(g, cx, cz):
    """Fuente redonda: anillo dorado en el piso, pileta con agua y un pilar con una taza y un gran
    cristal arriba. Radio 16."""
    losa(g, cx, cz, -2, 0, 16, 16, "Oro", 6)
    losa(g, cx, cz, -2, 0, 14, 14, "BaldosaOscura", 6)
    losa(g, cx, cz, 0, 2, 12, 12, "PiedraClara", 4)
    losa(g, cx, cz, -2, 2, 10, 10, "Agua", 4)
    losa(g, cx, cz, -2, 4, 4, 4, "PiedraClara", 2)
    g.poner(cx - 2, 4, cz - 2, cx + 2, 10, cz + 2, "PiedraClara")
    losa(g, cx, cz, 10, 12, 6, 6, "Oro", 2)
    losa(g, cx, cz, 12, 14, 4, 4, "Agua", 0)
    g.poner(cx - 2, 12, cz - 2, cx + 2, 20, cz + 2, "CristalCuarzo")
    g.poner(cx - 2, 20, cz - 2, cx, 24, cz, "CristalCuarzo")
    for ax, az in ((cx + 6, cz - 2), (cx - 8, cz), (cx - 2, cz + 6), (cx, cz - 8)):  # chorritos de la taza
        g.poner(ax, 2, az, ax + 2, 10, az + 2, "Agua")


# --- plaza ---------------------------------------------------------------------------------------


def plaza(g, s, rng):
    z0 = PLAZA
    # piso de baldosas
    for xi in range(XMIN, XMAX, 16):
        for zi in range(z0, 0, 16):
            g.poner(xi, -4, zi, xi + 16, 0, zi + 16, "Pasto" if ((xi + zi) // 16) % 2 == 0 else "PastoOscuro")
    # paredes: fondo y costados, con pasto arriba
    g.poner(X0, 0, Z0, X1, 40, z0, "Piedra")
    g.poner(X0, 40, Z0, X1, 44, z0, "Pasto")
    for xa, xb in ((X0, XMIN), (XMAX, X1)):
        g.poner(xa, 0, z0, xb, 28, 8, "Piedra")
        g.poner(xa, 28, z0, xb, 32, 8, "Pasto")
    s.marcar(XMIN, z0, XMAX, z0 + 2)
    # paredes de ladrillo en los costados y árboles arriba (piezas de Blender)
    arboles = ["Arbol_Grande_1", "Arbol_Rosa_1", "Arbol_Grande_2", "Arbol_Mediano_2", "Arbol_Grande_3"]
    for i, z in enumerate(range(z0, 0, 16)):
        deco("Pared_Ladrillo_Zona1", XMIN - 2, z + 8, 270)
        deco("Pared_Ladrillo_Zona1", XMAX + 2, z + 8, 90)
        if i % 2 == 0:
            deco(arboles[i // 2 % 5], XMIN - 12, z + 8, rng.choice([0, 90, 180, 270]), y=32)
            deco(arboles[(i // 2 + 2) % 5], XMAX + 12, z + 8, rng.choice([0, 90, 180, 270]), y=32)
    # arco hacia la Pradera, con pilares y cristales
    # puerta grande (17/10): 64 de ancho y 36 de alto
    g.poner(XMIN, 0, 0, -32, 40, 8, "Muro")
    g.poner(32, 0, 0, XMAX, 40, 8, "Muro")
    g.poner(-32, 36, 0, 32, 40, 8, "Muro")
    g.poner(XMIN, 40, 0, XMAX, 42, 8, "Oro")
    g.poner(-36, 40, -2, 36, 44, 10, "Oro")
    for x in (-40, 32):
        g.poner(x, 0, -2, x + 8, 46, 10, "PiedraClara")
        g.poner(x, 46, -2, x + 8, 48, 10, "Oro")
        g.poner(x + 2, 48, 2, x + 6, 58, 6, "CristalCuarzo")
        g.poner(x + 2, 58, 2, x + 4, 62, 4, "CristalCuarzo")
    s.marcar(XMIN, -2, XMAX, 8)
    s.marcar(-16, z0, 16, 0)  # camino del Santuario al arco
    marcador("Pieza", (ARCO[0], 0, ARCO[1]), (40, 36, 6), 0, Nombre="Arco_Entrada", Escala=1.8)
    # los 2 tableros en la pared de adelante, a los lados de la puerta, mirando a la plaza
    marcador("Tablero", (-68, 9, -1), (16, 12, 1), 0, Tabla="Geodas")
    marcador("Tablero", (68, 9, -1), (16, 12, 1), 0, Tabla="Hallazgo")

    # spawn, con un anillo dorado en el piso
    sx, sz = SPAWN
    losa(g, sx, sz, -2, 0, 10, 10, "Oro", 4)
    losa(g, sx, sz, -2, 0, 8, 8, "Baldosa", 2)
    marcador("Spawn", (sx, 0.5, sz), (10, 1, 10), 0)
    marcador("Pieza", (sx, 0, sz), (12, 8, 12), 0, Nombre="Spawn")
    s.marcar(sx - 12, sz - 12, sx + 12, sz + 12)
    marcador("Cartel", (-24, 4, -14), (8, 5, 1), mirar((-24, -14), SPAWN), Menu="Misiones", Texto="MISIONES")
    # el Banco y la Tienda a los costados, de frente al que aparece
    for nombre, (px, pz), giro in (("Puesto_Vender", PUESTO, 0), ("Tienda_Forja", TIENDA, 0)):
        marcador("Pieza", (px, 0, pz), (14, 14, 12), giro, Nombre=nombre, Escala=ESCALA_TIENDAS)
        s.marcar(px - 8, pz - 7, px + 8, pz + 7)
    ruleta(g, s)
    # las parcelas: 4 al fondo y 1 a cada costado, con la entrada hacia el medio
    for n, (px, pz, giro) in enumerate(PARCELAS, 1):
        marcador("Pieza", (px, 0, pz), (40, 8, 32), giro, Nombre="Parcela_Exhibicion", Numero=n, Escala=ESCALA_PARCELAS)
        s.marcar(px - 20, pz - 20, px + 20, pz + 20)


class Corrido:
    """Grilla y suelo corridos dx studs en x (para armar el Santuario y el Museo en el patio)."""

    def __init__(self, g, dx):
        self.g, self.dx = g, dx

    def poner(self, x0, y0, z0, x1, y1, z1, mat):
        self.g.poner(x0 + self.dx, y0, z0, x1 + self.dx, y1, z1, mat)

    def marcar(self, *_):
        pass


def corrido(armar_algo, g, dx):
    antes = len(marcadores)
    c = Corrido(g, dx)
    armar_algo(c, c)
    for m in marcadores[antes:]:
        m["Pos"][0] = round(m["Pos"][0] + dx, 2)


def patio():
    """Patio de la izquierda (sin pared con la plaza): el Santuario del Renacer y el Museo (los
    mismos de antes, corridos) y los 2 tableros. Sin vitrinas ni lugar del Jefe Ancestral (17/10:
    el evento usa el punto del Jefe de la zona 1)."""
    x0, x1 = PATIO_X0, X0
    d = Grilla(x0 - 8, -4, PLAZA - 8, x1, 60, 8)
    for xi in range(x0, x1, 16):  # el mismo piso de baldosas que la plaza
        for zi in range(PLAZA, 0, 16):
            d.poner(xi, -4, zi, xi + 16, 0, zi + 16, "Baldosa" if ((xi + zi) // 16) % 2 == 0 else "BaldosaOscura")
    for za, zb in ((PLAZA - 8, PLAZA), (0, 8)):  # paredes
        d.poner(x0 - 8, 0, za, x1, 28, zb, "Piedra")
        d.poner(x0 - 8, 28, za, x1, 32, zb, "Pasto")
    d.poner(x0 - 8, 0, PLAZA, x0, 28, 0, "Piedra")
    d.poner(x0 - 8, 28, PLAZA, x0, 32, 0, "Pasto")
    corrido(santuario, d, DX_SANTUARIO)
    corrido(museo, d, DX_MUSEO)
    marcador("Tablero", (x0 + 20, 7, PLAZA + 3), (14, 10, 1), 180, Tabla="Geodas")
    marcador("Tablero", (x0 + 40, 7, PLAZA + 3), (14, 10, 1), 180, Tabla="Hallazgo")
    return d.cajas()


def museo(g, s):
    """Museo de minerales: templo de columnas con frontón escalonado, mirando a la plaza (+x)."""
    x0, z0, x1, z1 = MUSEO
    g.poner(x0, 0, z0, x1, 2, z1, "PiedraClara")
    g.poner(x0, 2, z0 + 2, x1 - 2, 4, z1 - 2, "PiedraClara")
    g.poner(x0, 4, z0 + 6, x1 - 10, 22, z1 - 6, "Baldosa")
    g.poner(x1 - 10, 4, -82, x1 - 8, 16, -70, "Muro")  # la puerta
    g.poner(x1 - 10, 16, -84, x1 - 8, 18, -68, "Oro")
    for zc in (z0 + 2, z0 + 10, z1 - 14, z1 - 6):  # columnas (dejan ver la puerta)
        g.poner(x1 - 6, 4, zc, x1 - 2, 20, zc + 4, "PiedraClara")
        g.poner(x1 - 8, 20, zc - 2, x1, 22, zc + 6, "Baldosa")
    g.poner(x0, 22, z0, x1, 24, z1, "Oro")
    g.poner(x0, 24, z0, x1, 26, z1, "Baldosa")
    for k in range(5):
        g.poner(x0, 26 + 2 * k, z0 + 2 + 4 * k, x1, 28 + 2 * k, z1 - 2 - 4 * k, "PiedraClara" if k % 2 else "Baldosa")
    g.poner(x1 - 6, 36, -78, x1 - 2, 44, -74, "CristalCuarzo")
    g.poner(x1 - 6, 44, -78, x1 - 4, 46, -76, "CristalCuarzo")
    marcador("Museo", (x1 + 6, 2, -76), (3, 4, 3), 0)
    s.marcar(x0, z0, x1 + 12, z1)


def santuario(g, s):
    """Santuario del Renacer: patio de mármol cerrado (paredes de 20 studs, no se saltan) con una
    sola entrada, la PuertaRenacer. Adentro, 4 puntos de Geoda Renacida, un fénix dorado en la
    pared del fondo y braseros de cristal."""
    x0, z0, x1, z1 = SANTUARIO
    alto = 20
    g.poner(x0, -4, z0, x1, 0, z1, "Marmol")
    g.poner(-2, -2, z0, 2, 0, z1, "Oro")  # camino dorado de la puerta al fénix
    for x0p, x1p in ((x0, x0 + 4), (x1 - 4, x1)):
        g.poner(x0p, 0, z0, x1p, alto, z1, "Marmol")
        g.poner(x0p, alto, z0, x1p, alto + 2, z1, "Oro")
    g.poner(x0, 0, z1 - 4, x1, alto, z1, "Marmol")
    g.poner(x0, alto, z1 - 4, x1, alto + 2, z1, "Oro")
    g.poner(x0, 0, z0, x1, alto, z0 + 2, "Marmol")  # forro de la pared del fondo
    g.poner(-8, 0, z1 - 4, 8, 16, z1, None)  # la entrada
    g.poner(-10, 16, z1 - 6, 10, 18, z1 + 2, "Oro")
    for xa in range(x0, x1, 8):  # almenas
        g.poner(xa, alto + 2, z1 - 4, xa + 4, alto + 4, z1, "Marmol")
    for za in range(z0 + 4, z1 - 4, 8):
        g.poner(x0, alto + 2, za, x0 + 4, alto + 4, za + 4, "Marmol")
        g.poner(x1 - 4, alto + 2, za, x1, alto + 4, za + 4, "Marmol")
    # pilares en las esquinas y a los lados de la entrada, con cristal de fénix arriba
    for px, pz in ((x0 - 2, z1 - 6), (x1 - 6, z1 - 6), (-14, z1 - 6), (8, z1 - 6)):
        ancho = 6 if abs(px) < 20 else 8
        g.poner(px, 0, pz, px + ancho, 24, pz + 8, "Marmol")
        g.poner(px, 24, pz, px + ancho, 26, pz + 8, "Oro")
        g.poner(px + 2, 26, pz + 2, px + ancho - 2, 32, pz + 6, "CristalFenix")
        g.poner(px + 2, 32, pz + 2, px + 4, 34, pz + 4, "CristalFenix")
    # fénix dorado en la pared del fondo
    fz = z0 + 2
    g.poner(-2, 6, fz, 2, 22, fz + 2, "OroViejo")
    g.poner(-4, 22, fz, 4, 26, fz + 2, "OroViejo")
    g.poner(-2, 26, fz, 2, 30, fz + 2, "CristalFenix")
    g.poner(-4, 2, fz, 4, 6, fz + 2, "CristalFenix")
    for k, (y0, y1) in enumerate(((12, 18), (14, 22), (16, 26), (20, 30))):  # alas, en escalones
        xa = 2 + 4 * k
        g.poner(xa, y0, fz, xa + 4, y1, fz + 2, "OroViejo")
        g.poner(-xa - 4, y0, fz, -xa, y1, fz + 2, "OroViejo")
    # braseros: uno al fondo y uno en cada rincón
    for bx, bz in ((0, z0 + 10), (x0 + 8, z0 + 8), (x1 - 8, z0 + 8), (x0 + 8, z1 - 8), (x1 - 8, z1 - 8)):
        losa(g, bx, bz, 0, 2, 4, 4, "OroViejo", 2)
        g.poner(bx - 2, 2, bz - 2, bx + 2, 6, bz + 2, "CristalFenix")
        g.poner(bx - 2, 6, bz - 2, bx, 8, bz, "CristalFenix")
    # los 4 puntos de Geoda Renacida, cada uno con un anillo dorado en el piso
    for x in (-30, -10, 10, 30):
        losa(g, x, -118, -2, 0, 8, 8, "Oro", 2)
        losa(g, x, -118, -2, 0, 6, 6, "Marmol", 2)
        marcador("PuntoGeoda", (x, 0.1, -118), (2, 0.2, 2), 0, Zona=1, Tamano="Renacida", Renacer=1)
    marcador("PuertaRenacer", (0, 8, z1 - 2), (16, 16, 2), 0, Renacer=1)
    marcador("Luz", (0, 14, -118), (1, 1, 1), 0, Color="#FFD23F")
    marcador("Luz", (0, 10, z0 + 12), (1, 1, 1), 0, Color="#FFD23F")
    marcador("Cartel", (22, 4, z1 + 4), (8, 5, 1), mirar((22, z1 + 4), SPAWN), Menu="Renacer", Texto="RENACER")
    s.marcar(x0 - 4, z0, x1 + 4, z1 + 8)


def ruleta(g, s):
    """Ruleta de Mascotas al fondo: el escenario es la pieza Ruleta_Mascotas de Lobby.fbx; la rueda
    que gira (y abre el menú) la arma el juego en el marcador, donde va la rueda de la pieza."""
    rx, rz = RULETA
    marcador("Pieza", (rx, 0, rz), (20, 20, 16), 180, Nombre="Ruleta_Mascotas")
    marcador("Ruleta", (rx, RUEDA_ALTO, rz), (16, 16, 2), 0)
    marcador("Luz", (rx, RUEDA_ALTO + 4, rz + 10), (1, 1, 1), 0, Color="#FFFFFF")
    s.marcar(rx - 12, rz - 10, rx + 12, rz + 12)


# --- biomas --------------------------------------------------------------------------------------


def bioma(g, s, rng, n):
    b = BIOMAS[n]
    zs, ze = inicio_zona(n), fin_zona(n)
    zd = puerta_secreta_z(n)
    # piso con manchas
    g.poner(XMIN, -4, zs, XMAX, 0, ze, b["Piso"])
    for _ in range(24):
        px = rng.randrange(XMIN, XMAX - 16, V)
        pz = rng.randrange(zs, ze - 16, V)
        g.poner(px, -4, pz, px + rng.choice([8, 12, 16]), 0, pz + rng.choice([8, 12, 16]), b["Piso2"])
    # riscos a los costados (el de la derecha es más grueso: ahí está la cámara secreta)
    alto_izq, alto_der = {}, {}
    for z in range(zs - MURO, ze + MURO, V):
        hi = 7 + int(3 * (math.sin(z * 0.035 + n) + 1) / 2) + rng.randint(0, 1)
        hd = 10 + int(3 * (math.sin(z * 0.03 + n * 2) + 1) / 2) + rng.randint(0, 1)
        g.poner(X0, 0, z, XMIN - 16, hi * V, z + V, b["Risco"])
        g.poner(X0, hi * V, z, XMIN - 16, hi * V + V, z + V, b["Tapa"])
        g.poner(XMAX + 16, 0, z, X1, hd * V, z + V, b["Risco"])
        g.poner(XMAX + 16, hd * V, z, X1, hd * V + V, z + V, b["Tapa"])
        alto_izq[z], alto_der[z] = hi * V + V, hd * V + V
    # adelante, los riscos de ladrillo en escalones (piezas de 16 de largo, mirando al camino);
    # en el derecho queda el hueco del túnel de la cámara secreta
    for z in range(zs, ze, 16):
        deco("Risco_Escalon_Zona%d" % n, XMIN - 8, z + 8, 270)
        if abs(z + 8 - (zd + 2)) > 14:
            deco("Risco_Escalon_Zona%d" % n, XMAX + 8, z + 8, 90)
        else:
            g.poner(XMAX, 0, z, XMAX + 16, 28, z + 16, b["Risco"])
    s.marcar(XMIN, zs, XMIN + 6, ze)
    s.marcar(XMAX - 6, zs, XMAX, ze)
    # muro con portón al final del bioma (el último no tiene portón)
    g.poner(XMIN, 0, ze, XMAX, 40, ze + MURO, "Muro")
    g.poner(XMIN, 40, ze, XMAX, 44, ze + MURO, b["Tapa"])
    if n < 5:
        g.poner(-12, 0, ze, 12, 20, ze + MURO, None)
        g.poner(-16, 20, ze, 16, 24, ze + MURO, "Oro")
        for x in (-20, 16):  # pilares de cristal a los lados del portón
            g.poner(x, 0, ze - 4, x + 4, 28, ze, b["Cristal"])
            g.poner(x, 28, ze - 4, x + 4, 30, ze, "Oro")
        marcador("PuertaZona", (0, 10, ze + 4), (24, 20, 2), 0, Zona=n + 1)
        # cartel de dificultad arriba del portón (plan v5)
        marcador("Cartel", (0, 34, ze - 1), (26, 6, 1), 0, Texto=DIFICULTAD[n + 1], SinPoste=True)
    for x in (-80, -76, -60, -44, -28, 28, 44, 60, 76, 80):
        deco("Pared_Ladrillo_Zona%d" % n, x, ze - 2, 0)
        if n < 5:
            deco("Pared_Ladrillo_Zona%d" % (n + 1), x, ze + MURO + 2, 180)
    s.marcar(XMIN, ze - 8, XMAX, ze)
    s.marcar(-18, zs, 18, ze)  # el camino al portón queda libre

    camara_secreta(g, s, n, zs, zd)
    pista(g, s, rng, n, zd)

    # lugares grandes que se reservan antes de repartir los puntos
    volcan_c = (XMIN + 32, ze - 44)
    portal = (XMIN + 18, ze - 30)
    if n == 4:
        deco("Volcan", volcan_c[0], volcan_c[1], 0)
        s.marcar(volcan_c[0] - 32, volcan_c[1] - 32, volcan_c[0] + 32, volcan_c[1] + 32)
        cx = volcan_c[0]
        rio(g, s, [(cx + 6, volcan_c[1] - 30), (cx + 6, zs + 136), (XMAX - 30, zs + 136), (XMAX - 30, zs + 128)])
        rio(g, s, [(XMIN + 6, zs + 50), (-40, zs + 50), (-40, zs + 54), (-22, zs + 54)])
    if n == 2:
        px, pz = portal
        deco("Duna_Grande", px + 30, pz, 90)
        for dz in (-8, 6):  # pilares de arenisca con cristales del prisma
            g.poner(px - 2, 0, pz + dz, px + 2, 14, pz + dz + 2, "Arenisca")
            g.poner(px - 2, 14, pz + dz, px + 2, 18, pz + dz + 2, "PrismaRosa" if dz < 0 else "PrismaCian")
        marcador("Portal", (px, 7, pz), (1, 12, 9), 90, Destino="Prisma", Zona=2)
        marcador("DestinoPortal", (px + 8, 0.5, pz), (4, 1, 4), 0, Nombre="Dunas")
        s.marcar(px - 12, pz - 24, px + 44, pz + 22)

    # puntos de geoda en filas y el Jefe al fondo
    for dz, columnas in FILAS_GEODAS:
        for xc in columnas:
            x = xc + rng.randint(-3, 3)
            z = zs + dz + rng.randint(-3, 3)
            for ox, oz in ((0, 0), (0, -12), (0, 12), (-10, 0), (10, 0), (0, -20), (0, 20), (-10, -12), (10, 12)):
                px, pz = x + ox, z + oz
                if zs + 12 <= pz <= ze - 14 and abs(px) >= 26 and s.libre(px - 7, pz - 7, px + 7, pz + 7):
                    marcador("PuntoGeoda", (px, 0.1, pz), (2, 0.2, 2), 0, Zona=n)
                    s.marcar(px - 7, pz - 7, px + 7, pz + 7)
                    break
    jefe = (0, ze - 34)
    marcador("PuntoGeoda", (jefe[0], 0.1, jefe[1]), (2, 0.2, 2), 0, Zona=n, Jefe=True)
    s.marcar(jefe[0] - 16, jefe[1] - 16, jefe[0] + 16, jefe[1] + 16)

    area = (XMIN + 6, zs + 6, XMAX - 6, ze - 8)

    # altar
    al = lugar(s, rng, area, 8)
    if al:
        ax, az = al
        losa(g, ax, az, 0, 2, 6, 6, b["Piso2"], 2)
        losa(g, ax, az, 2, 4, 4, 4, "PiedraClara", 0)
        for sx, sz in ((-6, -6), (4, -6), (-6, 4), (4, 4)):
            g.poner(ax + sx, 2, az + sz, ax + sx + 2, 8, az + sz + 2, b["Cristal"])
        marcador("Altar", (ax, 4 + 1.5, az), (4, 3, 4), 0, Zona=n)

    # decoración de cada bioma y rocas con los colores de sus 3 variantes de geoda
    DECORACION[n](g, s, rng, n, area, zs, ze, zd)
    poner_deco(s, rng, area, ["Losas_%s_Zona%d" % (t, n) for t in ("Chica", "Mediana", "Larga")], 9)
    cimas(g, rng, n, zs, ze, alto_izq, alto_der)


def camara_secreta(g, s, n, zs, zd):
    """Túnel y cámara en el risco derecho, con 4 columnas de cristal, el cofre y 2 Ocultas."""
    b = BIOMAS[n]
    cx0, cx1 = XMAX + 16, XMAX + 44  # la cámara
    g.poner(XMAX, 0, zd - 4, cx0, 12, zd + 8, None)  # túnel
    g.poner(cx0, 0, zd - 12, cx1, 16, zd + 16, None)
    g.poner(cx0, -4, zd - 12, cx1, 0, zd + 16, "BaldosaOscura")
    g.poner(XMAX, -4, zd - 4, cx0, 0, zd + 8, "BaldosaOscura")
    g.poner(cx0 + 4, -2, zd, cx1 - 4, 0, zd + 4, "Oro")  # alfombra dorada hasta el cofre
    for x, z in ((cx0, zd - 12), (cx1 - 4, zd - 12), (cx0, zd + 12), (cx1 - 4, zd + 12)):
        g.columna(x, z, 0, 12, b["Cristal"])
        marcador("Luz", (x + 2, 10, z + 2), (1, 1, 1), 0, Color=MATERIALES[b["Cristal"]][0])
    for x in (cx0 + 8, cx0 + 18):  # cristalitos metidos en las paredes
        g.poner(x, 4, zd - 14, x + 2, 10, zd - 12, b["Cristal"])
        g.poner(x, 4, zd + 16, x + 2, 10, zd + 18, b["Cristal"])
    risco = MATERIALES[b["Risco"]]
    marcador("PuertaSecreta", (XMAX + 2, 6, zd + 2), (4, 12, 12), 0, Zona=n, Color=risco[0], Material=risco[1])
    marcador("Cofre", (cx1 - 6, 1.2, zd + 2), (4, 2.4, 3), 90, Zona=n, Id="Camara%d" % n)
    marcador("PuntoGeoda", (cx0 + 8, 0.1, zd - 6), (2, 0.2, 2), 0, Zona=n, Tamano="Oculta", Secreto=n)
    marcador("PuntoGeoda", (cx0 + 8, 0.1, zd + 10), (2, 0.2, 2), 0, Zona=n, Tamano="Oculta", Secreto=n)
    # que nada tape la entrada del túnel
    if n != 1:
        g.poner(XMAX - 8, 0, zd - 4, XMAX, 40, zd + 8, None)
    s.marcar(XMAX - 16, zd - 8, XMAX, zd + 12)


def pista(g, s, rng, n, zd):
    """La pista de cada bioma junto a la puerta secreta."""
    if n == 1:  # cascada de cristal (el agua no choca; abajo hay piso)
        g.poner(XMAX - V, 0, zd - 4, XMAX, 40, zd + 8, "Agua")
        g.poner(XMAX - 12, -2, zd - 8, XMAX, 0, zd + 12, "Agua")
        g.poner(XMAX - 6, 0, zd - 8, XMAX - 4, 6, zd - 6, "CristalCuarzo")
        g.poner(XMAX - 6, 0, zd + 10, XMAX - 4, 8, zd + 12, "CristalCuarzo")
        s.marcar(XMAX - 16, zd - 12, XMAX, zd + 16)
    elif n == 2:  # la duna más alta
        duna(g, XMAX - 24, zd + 2, rng, 20, 20, viento=-1)
        g.poner(XMAX - 8, 0, zd - 4, XMAX, 24, zd + 8, None)
        s.marcar(XMAX - 46, zd - 14, XMAX, zd + 18)
    elif n == 3:  # picos de hielo a los dos lados
        pico_hielo(g, XMAX - 10, zd - 12, rng, 28)
        pico_hielo(g, XMAX - 10, zd + 14, rng, 24)
        s.marcar(XMAX - 18, zd - 18, XMAX, zd + 22)
    elif n == 4:  # río de lava que llega a la puerta
        rio(g, s, [(-4, zd + 4), (XMAX - 8, zd + 4)])
    # (5: rincón oscuro, sin cristales cerca)


def lejos_de_la_puerta(n, zd):
    """En el Abismo, la pista es que cerca de la puerta secreta no hay cristales."""
    if n != 5:
        return None
    return lambda x, z: not (x > 60 and abs(z - zd) < 40)


def deco_pradera(g, s, rng, n, area, zs, ze, zd):
    poner_deco(s, rng, area, ["Arbol_Grande_1", "Arbol_Grande_2", "Arbol_Grande_3"], 6)
    poner_deco(s, rng, area, ["Arbol_Mediano_1", "Arbol_Rosa_1", "Arbol_Mediano_2", "Arbol_Rosa_2", "Arbol_Mediano_3", "Arbol_Rosa_3"], 10)
    poner_deco(s, rng, area, ["Arbol_Seco_1", "Arbol_Seco_2", "Arbol_Seco_3"], 3)
    poner_deco(s, rng, area, ["Arbusto_1", "Arbusto_2", "Arbusto_3"], 12)
    poner_deco(s, rng, area, "Racimo_Cuarzo", 5)


def deco_dunas(g, s, rng, n, area, zs, ze, zd):
    poner_deco(s, rng, area, "Piramide", 1, intentos=600)
    poner_deco(s, rng, area, ["Duna_Mediana", "Duna_Chica"], 6, intentos=300)
    poner_deco(s, rng, area, ["Cactus_Grande", "Cactus_Mediano", "Cactus_Chico"], 14)
    poner_deco(s, rng, area, ["Arbol_Seco_Desierto_1", "Arbol_Seco_Desierto_2"], 4)
    poner_deco(s, rng, area, "Esqueleto", 2)
    poner_deco(s, rng, area, "Racimo_Ambar", 6)


def deco_glaciar(g, s, rng, n, area, zs, ze, zd):
    poner_deco(s, rng, area, "Lago_Congelado", 1, intentos=400)
    poner_deco(s, rng, area, ["Monte_Nevado_Grande", "Monte_Nevado_Mediano", "Monte_Nevado_Chico"], 3, intentos=300)
    poner_deco(s, rng, area, ["Pino_Nevado_Grande", "Pino_Nevado_Chico"], 12)
    poner_deco(s, rng, area, "Pico_Hielo", 8)
    poner_deco(s, rng, area, ["Escalones_Nevados_1", "Escalones_Nevados_2"], 3)
    poner_deco(s, rng, area, "Hielo_Suelto", 8)


def deco_volcan(g, s, rng, n, area, zs, ze, zd):
    poner_deco(s, rng, area, ["Roca_Lava_Grande", "Roca_Lava_Mediana", "Roca_Lava_Chica"], 6)
    poner_deco(s, rng, area, "Arbol_Quemado", 8)
    poner_deco(s, rng, area, ["Columnas_Basalto_1", "Columnas_Basalto_2"], 6)


def deco_abismo(g, s, rng, n, area, zs, ze, zd):
    lejos = lejos_de_la_puerta(n, zd)
    poner_deco(s, rng, area, "Arbol_Nebuloso", 3, valido=lejos)
    poner_deco(s, rng, area, ["Columna_Estelar_Alta", "Columna_Estelar_Baja"], 6, valido=lejos)
    poner_deco(s, rng, area, "Cristales_Abismo", 8, valido=lejos)
    poner_deco(s, rng, area, ["Roca_Meteorito_Grande", "Roca_Meteorito_Chico"], 5, valido=lejos)
    # islas que flotan (no ocupan piso)
    islas = ["Isla_Flotante_Chica", "Isla_Flotante_Mediana", "Isla_Flotante_Grande"]
    for i in range(6):
        x = rng.randrange(XMIN + 20, XMAX - 20, 2)
        z = rng.randrange(zs + 20, ze - 24, 2)
        if lejos(x, z):
            deco(islas[i % 3], x, z, rng.choice([0, 90, 180, 270]), y=36 + (i % 3) * 8)


DECORACION = {1: deco_pradera, 2: deco_dunas, 3: deco_glaciar, 4: deco_volcan, 5: deco_abismo}


CIMAS = {
    1: ["Arbol_Grande_1", "Arbol_Rosa_2", "Arbol_Grande_3", "Arbol_Mediano_1"],
    2: ["Cactus_Grande", "Arbol_Seco_Desierto_1", "Cactus_Mediano", "Arbol_Seco_Desierto_2"],
    3: ["Pino_Nevado_Grande", "Pino_Nevado_Chico"],
    4: ["Columnas_Basalto_1", "Arbol_Quemado", "Columnas_Basalto_2"],
    5: ["Columna_Estelar_Baja", "Arbol_Nebuloso", "Cristales_Abismo"],
}


def cimas(g, rng, n, zs, ze, alto_izq, alto_der):
    """Piezas arriba de los riscos (se ven desde el bioma, como en las referencias), y en el cielo
    un arcoíris y nubes de bloques."""
    for lado, x, altos in ((-1, (X0 + XMIN - 16) // 2, alto_izq), (1, XMAX + 30, alto_der)):
        for i in range(6):
            z = par(zs + 20 + i * 40 + rng.randint(-6, 6))
            filas = [altos[f] for f in altos if z - 8 <= f <= z + 8]
            if filas:
                deco(CIMAS[n][i % len(CIMAS[n])], x, z, rng.choice([0, 90, 180, 270]), y=min(filas))
    deco("Arcoiris", rng.choice([-1, 1]) * 40, ze - 60, 0, y=70)
    for i in range(2):
        deco("Nube_Bloques", rng.randint(-60, 60), zs + 60 + i * 110, rng.choice([0, 180]), y=80 + i * 12)


# --- Dimensión Prisma ------------------------------------------------------------------------------

PRISMA = (0, 200, 620)  # centro de la isla (arriba del Glaciar, lejos de todo)


def dimension_prisma():
    cx, cy, cz = PRISMA
    d = Grilla(cx - 48, cy - 24, cz - 48, cx + 48, cy + 40, cz + 48)
    for dx in range(-40, 41, V):
        for dz in range(-40, 41, V):
            r = math.hypot(dx, dz)
            if r <= 40:
                prof = int((1 - r / 40) * 4) + 1
                mat = "PrismaBlanco" if r < 26 else ("PrismaCian" if (dx + dz) // V % 2 else "PrismaRosa")
                d.poner(cx + dx, cy - 4 * prof, cz + dz, cx + dx + V, cy, cz + dz + V, mat)
    for i in range(10):
        a = i / 10 * math.tau
        x = cx + int(round(math.cos(a) * 34 / V)) * V
        z = cz + int(round(math.sin(a) * 34 / V)) * V
        mat = ["PrismaRosa", "PrismaCian", "PrismaVioleta"][i % 3]
        d.poner(x, cy, z, x + V, cy + (3 + i % 3) * V, z + V, mat)
        d.poner(x + 2, cy + (3 + i % 3) * V, z + 2, x + 4, cy + (3 + i % 3) * V + 4, z + 4, mat)
    # espiral al centro
    losa(d, cx, cz, cy, cy + 2, 4, 4, "PrismaVioleta", 2)
    d.poner(cx - 2, cy + 2, cz - 2, cx + 2, cy + 16, cz + 2, "PrismaBlanco")
    d.poner(cx - 2, cy + 16, cz - 2, cx, cy + 20, cz, "PrismaVioleta")
    for i in range(5):
        a = i / 5 * math.tau + 0.3
        marcador("PuntoGeoda", (cx + math.cos(a) * 18, cy + 0.1, cz + math.sin(a) * 18), (2, 0.2, 2), 0, Zona=2, Tamano="Prisma")
    marcador("DestinoPortal", (cx, cy + 0.5, cz - 26), (4, 1, 4), 0, Nombre="Prisma")
    marcador("Portal", (cx, cy + 7, cz - 34), (1, 12, 9), 0, Destino="Dunas", Zona=2)
    marcador("Luz", (cx, cy + 24, cz), (1, 1, 1), 0, Color="#FFFFFF")
    return d.cajas()


# --- el mundo ------------------------------------------------------------------------------------


def armar(semilla=7):
    rng = random.Random(semilla)
    g = Grilla(X0, Y0, Z0, X1, Y1, Z1)
    s = Suelo(g)
    g.poner(X0, -4, Z0, X1, 0, Z1, "Tierra")
    plaza(g, s, rng)
    for n in range(1, 6):
        bioma(g, s, rng, n)
    return g.cajas() + dimension_prisma()


def escribir(cajas):
    usados = sorted({c[0] for c in cajas}, key=NOMBRES.index)
    idx = {n: i + 1 for i, n in enumerate(usados)}
    lineas = [
        "--!strict",
        "-- Generado por forja-rapida/arte/scripts/mapa.py (no editar a mano: cambiar el script y",
        "-- volver a correrlo). Lo arma GeneradorMapa.luau.",
        "-- Bloques: \"material,x,y,z,ancho,alto,largo\" separados por \";\" (studs; x,y,z = esquina",
        "-- de abajo). Marcadores: lugares con función (Tipo, Pos = centro, Tam, Giro en grados y",
        "-- Atributos que se le ponen a la parte).",
        "",
        "return {",
        "\tMateriales = {",
    ]
    for n in usados:
        color, mat, transp, choca = MATERIALES[n]
        lineas.append(
            '\t\t{ Nombre = "%s", Color = "%s", Material = "%s", Transparencia = %s, Choca = %s },'
            % (n, color, mat, transp, "true" if choca else "false")
        )
    lineas.append("\t},")
    datos = ";".join("%d,%d,%d,%d,%d,%d,%d" % (idx[c[0]], *c[1:]) for c in cajas)
    lineas.append('\tBloques = "%s",' % datos)
    lineas.append("\tMarcadores = {")
    for m in marcadores:
        attrs = []
        for k, v in m["Atributos"].items():
            if isinstance(v, bool):
                attrs.append("%s = %s" % (k, "true" if v else "false"))
            elif isinstance(v, (int, float)):
                attrs.append("%s = %s" % (k, v))
            else:
                attrs.append('%s = "%s"' % (k, v))
        lineas.append(
            '\t\t{ Tipo = "%s", Pos = { %s }, Tam = { %s }, Giro = %s, Atributos = { %s } },'
            % (m["Tipo"], ", ".join(str(p) for p in m["Pos"]), ", ".join(str(t) for t in m["Tam"]), m["Giro"], ", ".join(attrs))
        )
    lineas.append("\t},")
    lineas.append("}")
    with open(SALIDA, "w", encoding="utf-8") as f:
        f.write("\n".join(lineas) + "\n")


def main():
    cajas = armar()
    escribir(cajas)
    tipos = {}
    for m in marcadores:
        tipos[m["Tipo"]] = tipos.get(m["Tipo"], 0) + 1
    print("bloques:", len(cajas), "| marcadores:", json.dumps(tipos))
    if "--render" in sys.argv:
        import mapa_render

        mapa_render.renderizar(cajas, marcadores, MATERIALES, RENDERS)


if __name__ == "__main__":
    main()
