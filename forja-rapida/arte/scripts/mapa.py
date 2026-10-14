"""Mapa de Forja Rápida: la plaza, los 5 biomas, las cámaras secretas y la Dimensión Prisma.

El mapa se diseña acá con cubos de 4 studs (vóxeles, el estilo del juego) y sale como datos para
Roblox (src/server/MapaDatos.luau): bloques ya juntados en cajas grandes (así son pocas partes) y
marcadores (puntos de geoda, vitrinas, puertas, cofres, altares, portales...). En el juego lo arma
src/server/GeneradorMapa.luau, así el mapa vive en git y no hay que subir mallas.

Uso (desde la raíz del repositorio):
  python3 forja-rapida/arte/scripts/mapa.py                 solo los datos (necesita NumPy)
  <python de Blender> forja-rapida/arte/scripts/mapa.py --render   datos y renders (arte/renders/mapa_*.jpg)
"""

import json
import math
import os
import random
import sys

import numpy as np

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
SALIDA = os.path.join(RAIZ, "src", "server", "MapaDatos.luau")
RENDERS = os.path.join(RAIZ, "arte", "renders")

V = 4  # studs por cubo

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
LARGO = 168  # largo de cada bioma (studs)
MURO = 8  # muro entre biomas


def inicio_zona(n):
    return 8 + (n - 1) * (LARGO + MURO)


def fin_zona(n):
    return inicio_zona(n) + LARGO


class Grilla:
    """Cubos de 4 studs. Las coordenadas son studs del mundo (múltiplos de 4)."""

    def __init__(self, x0, y0, z0, nx, ny, nz):
        self.x0, self.y0, self.z0 = x0, y0, z0
        self.c = np.zeros((nx, ny, nz), dtype=np.uint8)

    def rango(self, a0, a1, b0, n):
        i0 = max(0, (a0 - b0) // V)
        i1 = min(n, -(-(a1 - b0) // V))
        return i0, i1

    def poner(self, x0, y0, z0, x1, y1, z1, mat):
        nx, ny, nz = self.c.shape
        i0, i1 = self.rango(x0, x1, self.x0, nx)
        j0, j1 = self.rango(y0, y1, self.y0, ny)
        k0, k1 = self.rango(z0, z1, self.z0, nz)
        if i0 < i1 and j0 < j1 and k0 < k1:
            self.c[i0:i1, j0:j1, k0:k1] = 0 if mat is None else ID[mat]

    def cubo(self, x, y, z, mat):
        self.poner(x, y, z, x + V, y + V, z + V, mat)

    def columna(self, x, z, y0, y1, mat):
        self.poner(x, y0, z, x + V, y1, z + V, mat)

    def cajas(self):
        """Junta cubos iguales en cajas grandes (greedy meshing en 3D)."""
        c = self.c
        nx, ny, nz = c.shape
        usado = np.zeros_like(c, dtype=bool)
        salida = []
        for j in range(ny):
            for k in range(nz):
                for i in range(nx):
                    m = c[i, j, k]
                    if m == 0 or usado[i, j, k]:
                        continue
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
                        (
                            NOMBRES[m - 1],
                            self.x0 + i * V,
                            self.y0 + j * V,
                            self.z0 + k * V,
                            a * V,
                            h * V,
                            b * V,
                        )
                    )
        return salida


marcadores = []


def marcador(tipo, pos, tam=(2, 0.2, 2), giro=0, **atributos):
    marcadores.append({"Tipo": tipo, "Pos": [round(p, 2) for p in pos], "Tam": list(tam), "Giro": giro, "Atributos": atributos})


# --- piezas de decoración -----------------------------------------------------------------------


def arbol(g, x, z, alto=3):
    g.poner(x, 0, z, x + V, alto * V, z + V, "Madera")
    g.poner(x - V, alto * V, z - V, x + 2 * V, alto * V + 2 * V, z + 2 * V, "Hojas")
    g.cubo(x, alto * V + 2 * V, z, "Hojas")


def racimo(g, x, z, mat, rng, base=0):
    alturas = [3, 2, 2, 1]
    rng.shuffle(alturas)
    for (dx, dz), h in zip([(0, 0), (V, 0), (0, V), (-V, 0)], alturas):
        g.columna(x + dx, z + dz, base, base + h * V, mat)


def cactus(g, x, z, rng):
    h = rng.choice([3, 4])
    g.columna(x, z, 0, h * V, "Cactus")
    lado = rng.choice([-1, 1])
    g.columna(x + lado * V, z, V, 2 * V, "Cactus")
    g.columna(x + lado * V, z, 2 * V, 3 * V, "Cactus")


def duna(g, x, z, radio, alto, mat, mat2):
    for dx in range(-radio, radio + 1, V):
        for dz in range(-radio, radio + 1, V):
            d = math.hypot(dx, dz * 1.4) / radio
            if d <= 1:
                h = int(round((1 - d * d) * alto / V)) * V
                if h > 0:
                    g.poner(x + dx, 0, z + dz, x + dx + V, h, z + dz + V, mat if (dx // V + dz // V) % 3 else mat2)


def pico_hielo(g, x, z, alto):
    g.columna(x, z, 0, alto * V, "Hielo")
    g.columna(x + V, z, 0, max(1, alto - 2) * V, "Hielo")
    g.columna(x, z + V, 0, max(1, alto - 3) * V, "RocaHelada")


def isla_flotante(g, x, y, z, mat, cristal):
    g.poner(x - V, y, z - V, x + 2 * V, y + V, z + 2 * V, mat)
    g.poner(x, y - V, z, x + V, y, z + V, mat)
    g.columna(x, z, y + V, y + 3 * V, cristal)


# --- el mundo -----------------------------------------------------------------------------------


def armar(semilla=7):
    rng = random.Random(semilla)
    X0, Y0, Z0 = -104, -4, -80
    NX, NY = 60, 16
    zfin = fin_zona(5) + MURO
    NZ = (zfin - Z0) // V
    g = Grilla(X0, Y0, Z0, NX, NY, NZ)
    XMIN, XMAX = -84, 84  # zona caminable

    # piso
    g.poner(X0, -4, Z0, X0 + NX * V, 0, Z0 + NZ * V, "Tierra")

    # --- plaza (z -80 .. 0) ---
    for xi in range(XMIN, XMAX, 16):
        for zi in range(-72, 0, 16):
            g.poner(xi, -4, zi, xi + 16, 0, zi + 16, "Baldosa" if ((xi + zi) // 16) % 2 == 0 else "BaldosaOscura")
    g.poner(X0, 0, Z0, X0 + NX * V, 40, -72, "Piedra")  # fondo
    for lado in (-1, 1):
        x0 = X0 if lado < 0 else XMAX
        x1 = XMIN if lado < 0 else X0 + NX * V
        g.poner(x0, 0, -72, x1, 28, 8, "Piedra")
        g.poner(x0, 28, -72, x1, 32, 8, "Pasto")
    # Museo de minerales (a la izquierda)
    g.poner(-80, 0, -64, -48, 24, -28, "Baldosa")
    g.poner(-80, 24, -64, -48, 28, -28, "Oro")
    for zc in range(-64, -28, 8):
        g.poner(-48, 0, zc, -44, 24, zc + 4, "PiedraClara")  # columnas
    g.poner(-48, 24, -64, -44, 28, -28, "Oro")
    marcador("Museo", (-40, 2, -46), (3, 4, 3), 0)
    # arco hacia la Pradera
    g.poner(XMIN, 0, 0, -24, 32, 8, "Muro")
    g.poner(24, 0, 0, XMAX, 32, 8, "Muro")
    g.poner(-24, 24, 0, 24, 32, 8, "Muro")
    g.poner(-28, 32, 0, 28, 36, 8, "Oro")
    # spawn, vitrinas, tableros y lugar del Jefe Ancestral
    marcador("Spawn", (0, 0.5, -16), (10, 1, 10), 0)
    for i in range(8):
        fila, col = divmod(i, 4)
        marcador("Vitrina", (-4 + col * 14, 1, -58 + fila * 14), (2, 5, 5), 0, Numero=i + 1)
    marcador("Tablero", (-20, 7, -69), (14, 10, 1), 180, Tabla="Geodas")
    marcador("Tablero", (60, 7, -69), (14, 10, 1), 180, Tabla="Hallazgo")
    marcador("PuntoAncestral", (52, 0.1, -24), (4, 0.2, 4), 0)
    for x, z in [(-70, -8), (74, -8), (74, -40)]:
        arbol(g, x, z, 3)

    # --- biomas ---
    for n in range(1, 6):
        b = BIOMAS[n]
        zs, ze = inicio_zona(n), fin_zona(n)
        # piso con manchas
        g.poner(XMIN, -4, zs, XMAX, 0, ze, b["Piso"])
        for _ in range(14):
            px = rng.randrange(XMIN, XMAX - 16, V)
            pz = rng.randrange(zs, ze - 16, V)
            g.poner(px, -4, pz, px + rng.choice([8, 12, 16]), 0, pz + rng.choice([8, 12, 16]), b["Piso2"])
        # riscos a los costados (el de la derecha es más grueso: ahí está la cámara secreta)
        for z in range(zs - MURO, ze + MURO, V):
            hi = 7 + int(3 * (math.sin(z * 0.05 + n) + 1) / 2) + rng.randint(0, 1)
            hd = 10 + int(3 * (math.sin(z * 0.04 + n * 2) + 1) / 2) + rng.randint(0, 1)
            g.poner(X0, 0, z, XMIN, hi * V, z + V, b["Risco"])
            g.poner(X0, hi * V, z, XMIN, hi * V + V, z + V, b["Tapa"])
            g.poner(XMAX, 0, z, X0 + NX * V, hd * V, z + V, b["Risco"])
            g.poner(XMAX, hd * V, z, X0 + NX * V, hd * V + V, z + V, b["Tapa"])
            # escalones en el borde de adentro, para que no sea una pared lisa
            if rng.random() < 0.35:
                g.poner(XMIN, 0, z, XMIN + V, rng.randint(1, 3) * V, z + V, b["Risco"])
            if rng.random() < 0.35:
                g.poner(XMAX - V, 0, z, XMAX, rng.randint(1, 3) * V, z + V, b["Risco"])
        # muro con portón al final del bioma (el último no tiene portón)
        g.poner(XMIN, 0, ze, XMAX, 40, ze + MURO, "Muro")
        g.poner(XMIN, 40, ze, XMAX, 44, ze + MURO, b["Tapa"])
        if n < 5:
            g.poner(-12, 0, ze, 12, 20, ze + MURO, None)
            g.poner(-16, 20, ze, 16, 24, ze + MURO, "Oro")
            marcador("PuertaZona", (0, 10, ze + 4), (24, 20, 2), 0, Zona=n + 1)

        # lugares reservados: camino central, puntos de geoda, jefe
        reservados = []
        puntos = []
        filas = [zs + 22, zs + 50, zs + 78, zs + 106]
        for fi, zf in enumerate(filas):
            for xc in (-60, -36, 36, 60):
                if fi == 3 and xc in (-36, 36) and n % 2 == 0:
                    continue  # los biomas pares dejan lugar al fondo
                x = xc + rng.randint(-3, 3)
                z = zf + rng.randint(-3, 3)
                puntos.append((x, z))
        for x, z in puntos:
            marcador("PuntoGeoda", (x, 0.1, z), (2, 0.2, 2), 0, Zona=n)
            reservados.append((x, z, 9))
        jefe = (0, ze - 30)
        marcador("PuntoGeoda", (jefe[0], 0.1, jefe[1]), (2, 0.2, 2), 0, Zona=n, Jefe=True)
        reservados.append((jefe[0], jefe[1], 16))

        def libre(x, z, r=6):
            if -16 <= x <= 16:
                return False  # camino al portón
            if x < XMIN + 8 or x > XMAX - 12 or z < zs + 8 or z > ze - 10:
                return False
            return all(math.hypot(x - a, z - c) > rr + r for a, c, rr in reservados)

        def lugar(r=6, intentos=60):
            for _ in range(intentos):
                x = rng.randrange(XMIN + 8, XMAX - 12, V)
                z = rng.randrange(zs + 8, ze - 10, V)
                if libre(x, z, r):
                    reservados.append((x, z, r))
                    return x, z
            return None

        # lugares grandes que se reservan antes de repartir lo demás
        volcan = (-56, ze - 36)
        portal = (XMIN + 14, ze - 22)
        if n == 4:
            reservados.append((volcan[0], volcan[1], 28))
        if n == 2:
            reservados.append((portal[0] + 10, portal[1], 24))

        # --- cámara secreta (en el risco derecho) ---
        zd = zs + 56 + (n % 2) * 40
        g.poner(XMAX, 0, zd - 4, XMAX + 16, 12, zd + 8, None)  # túnel
        g.poner(100, 0, zd - 12, 128, 16, zd + 16, None)  # cámara
        g.poner(100, -4, zd - 12, 128, 0, zd + 16, "BaldosaOscura")
        g.poner(XMAX, -4, zd - 4, XMAX + 16, 0, zd + 8, "BaldosaOscura")
        for cx, cz in [(100, zd - 12), (124, zd - 12), (100, zd + 12), (124, zd + 12)]:
            g.columna(cx, cz, 0, 12, b["Cristal"])
            marcador("Luz", (cx + 2, 10, cz + 2), (1, 1, 1), 0, Color=MATERIALES[b["Cristal"]][0])
        risco = MATERIALES[b["Risco"]]
        marcador("PuertaSecreta", (XMAX + 2, 6, zd + 2), (4, 12, 12), 0, Zona=n, Color=risco[0], Material=risco[1])
        marcador("Cofre", (122, 1.2, zd + 2), (4, 2.4, 3), 90, Zona=n, Id="Camara%d" % n)
        marcador("PuntoGeoda", (108, 0.1, zd - 6), (2, 0.2, 2), 0, Zona=n, Tamano="Oculta", Secreto=n)
        marcador("PuntoGeoda", (108, 0.1, zd + 10), (2, 0.2, 2), 0, Zona=n, Tamano="Oculta", Secreto=n)
        reservados.append((XMAX - 6, zd + 2, 10))
        # que nada tape la entrada del túnel
        if n != 1:
            g.poner(XMAX - 8, 0, zd - 4, XMAX, 40, zd + 8, None)
        # pista de cada bioma junto a la puerta
        if n == 1:  # cascada de cristal
            g.poner(XMAX - V, 0, zd - 4, XMAX, 40, zd + 8, "Agua")
            g.poner(XMAX - 12, -4, zd - 8, XMAX, 0, zd + 12, "Agua")
        elif n == 2:  # la duna más alta
            duna(g, XMAX - 24, zd + 2, 20, 14, "Arena", "ArenaOscura")
            g.poner(XMAX - 8, 0, zd - 4, XMAX, 16, zd + 8, None)
        elif n == 3:  # picos de hielo a los dos lados
            pico_hielo(g, XMAX - 8, zd - 12, 7)
            pico_hielo(g, XMAX - 8, zd + 12, 6)
        elif n == 4:  # río de lava que llega a la puerta
            g.poner(-4, -4, zd + 2, XMAX - 8, 0, zd + 6, "Lava")
        # (5: rincón oscuro, sin cristales cerca)

        # --- altar ---
        al = lugar(6)
        if al:
            ax, az = al
            g.poner(ax - V, 0, az - V, ax + 2 * V, V, az + 2 * V, b["Piso2"])
            marcador("Altar", (ax + 2, V + 1.5, az + 2), (4, 3, 4), 0, Zona=n)

        # --- portal a la Dimensión Prisma (en las Dunas, detrás de una duna) ---
        if n == 2:
            px, pz = portal
            duna(g, px + 20, pz - 2, 18, 16, "Arena", "ArenaOscura")
            g.poner(px - 8, 0, pz - 12, px + 8, 16, pz + 12, None)
            marcador("Portal", (px, 7, pz), (1, 12, 9), 90, Destino="Prisma", Zona=2)
            marcador("DestinoPortal", (px + 8, 0.5, pz), (4, 1, 4), 0, Nombre="Dunas")

        # --- decoración de cada bioma ---
        if n == 1:
            for _ in range(10):
                p = lugar(6)
                if p:
                    arbol(g, p[0], p[1], rng.choice([3, 4]))
            for _ in range(9):
                p = lugar(4)
                if p:
                    racimo(g, p[0], p[1], b["Cristal"], rng)
        elif n == 2:
            for _ in range(5):
                p = lugar(14)
                if p:
                    duna(g, p[0], p[1], 14, rng.choice([8, 12]), "Arena", "ArenaOscura")
            for _ in range(10):
                p = lugar(4)
                if p:
                    cactus(g, p[0], p[1], rng)
            for _ in range(6):
                p = lugar(4)
                if p:
                    racimo(g, p[0], p[1], b["Cristal"], rng)
        elif n == 3:
            for _ in range(12):
                p = lugar(5)
                if p:
                    pico_hielo(g, p[0], p[1], rng.choice([4, 5, 6, 7]))
            lago = lugar(14)
            if lago:
                g.poner(lago[0] - 12, -4, lago[1] - 12, lago[0] + 12, 0, lago[1] + 12, "Hielo")
            for _ in range(6):
                p = lugar(4)
                if p:
                    racimo(g, p[0], p[1], b["Cristal"], rng)
        elif n == 4:
            # volcán al fondo a la izquierda
            vx, vz = volcan
            for r in range(6, 0, -1):
                g.poner(vx - r * V, 0, vz - r * V, vx + r * V, (7 - r) * V * 2, vz + r * V, "Basalto")
            g.poner(vx - V, 40, vz - V, vx + V, 48, vz + V, "Lava")
            for rx in (-72, -44, -20):  # ríos de lava entre las filas de geodas
                g.poner(rx, -4, zs + 8, rx + V, 0, ze - 8, "Lava")
            for _ in range(8):
                p = lugar(4)
                if p:
                    racimo(g, p[0], p[1], b["Cristal"], rng)
            for _ in range(8):
                p = lugar(5)
                if p:
                    g.poner(p[0], 0, p[1], p[0] + 2 * V, rng.choice([2, 3]) * V, p[1] + V, "BasaltoClaro")
        elif n == 5:
            for _ in range(8):
                p = lugar(5)
                if p and not (p[0] > 40 and abs(p[1] - zd) < 30):
                    g.columna(p[0], p[1], 0, rng.choice([3, 5, 7]) * V, "PolvoEstelar")
                    g.cubo(p[0], 7 * V + V * rng.randint(0, 2), p[1], "CristalEstelar")
            for _ in range(7):
                p = lugar(4)
                if p and not (p[0] > 40 and abs(p[1] - zd) < 30):
                    racimo(g, p[0], p[1], b["Cristal"], rng)
            for i in range(6):
                isla_flotante(g, rng.randrange(-60, 40, V), 32 + (i % 3) * 4, rng.randrange(zs + 16, ze - 16, V), "PiedraEstelar", "CristalEstelar")

    cajas = g.cajas()

    # --- Dimensión Prisma (isla flotante lejos de todo) ---
    d = Grilla(-48, 176, 380, 24, 16, 24)
    cx, cy, cz = 0, 200, 428
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
        d.poner(x, cy, z, x + V, cy + (3 + i % 3) * V, z + V, ["PrismaRosa", "PrismaCian", "PrismaVioleta"][i % 3])
    cajas += d.cajas()
    for i in range(5):
        a = i / 5 * math.tau + 0.3
        marcador("PuntoGeoda", (cx + math.cos(a) * 18, cy + 0.1, cz + math.sin(a) * 18), (2, 0.2, 2), 0, Zona=2, Tamano="Prisma")
    marcador("DestinoPortal", (cx, cy + 0.5, cz - 26), (4, 1, 4), 0, Nombre="Prisma")
    marcador("Portal", (cx, cy + 7, cz - 34), (1, 12, 9), 0, Destino="Dunas", Zona=2)
    marcador("Luz", (cx, cy + 14, cz), (1, 1, 1), 0, Color="#FFFFFF")
    return cajas


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
