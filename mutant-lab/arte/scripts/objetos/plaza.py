"""Plaza central (ideas/mutant-lab-arte.md, sección 7).

Las medidas copian las de la plaza que ya está en Studio (Workspace > Plaza), así cada pieza
reemplaza a las partes básicas sin mover nada que use el código (pantallas, carteles,
pedestales y ranuras quedan como están).
En Roblox: x de Roblox = -x de Blender, y de Roblox = z de Blender, z de Roblox = y de Blender.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import bmesh  # noqa: E402

import comun as C  # noqa: E402
from comun import girar, mover  # noqa: E402

G = C.Grupo("Plaza")

PISO_CENTRO = "#26405a"  # los colores del piso que ya tiene la plaza
PISO_ADENTRO = "#22364a"
PISO_ANILLO = "#3b454f"
PISO_AFUERA = "#1a2636"
METAL_OSCURO = "#404a55"


# ---------------------------------------------------------------------------
# Piso
# ---------------------------------------------------------------------------


@G.objeto("PlazaCentro", 8000, apoyo="libre", elevacion=math.radians(55))
def plaza_centro():
    """Círculo del centro (radio 15) con una hélice de ADN de neón que da la vuelta alrededor
    de la máquina de equipo. El origen es el centro del piso, arriba (y = 0 en Roblox)."""
    bm = bmesh.new()
    C.cilindro(bm, 15, 1, segmentos=48, matriz=mover(z=-1), redondeo=0.15)
    piso = G.malla("Piso", bm, PISO_CENTRO)

    bm = bmesh.new()
    vueltas, pasos = 8, 128
    for fase in (0, math.pi):
        camino = []
        for i in range(pasos + 1):
            a = 2 * math.pi * i / pasos
            r = 12.6 + 1.1 * math.sin(vueltas * a + fase)
            camino.append((r * math.cos(a), r * math.sin(a), 0.0))
        C.tubo(bm, camino, 0.2, lados=6)
    for i in range(64):  # peldaños entre las dos hebras
        a = 2 * math.pi * (i + 0.5) / 64
        abre = 1.1 * abs(math.sin(vueltas * a))
        if abre < 0.45:
            continue
        p1 = ((12.6 - abre + 0.15) * math.cos(a), (12.6 - abre + 0.15) * math.sin(a), 0.0)
        p2 = ((12.6 + abre - 0.15) * math.cos(a), (12.6 + abre - 0.15) * math.sin(a), 0.0)
        C.tubo(bm, [p1, p2], 0.11, lados=5)
    helice = G.malla("Helice_Neon", bm, "Acento")
    return [piso, helice]


@G.objeto("PlazaGajo", 3000, apoyo="libre", elevacion=math.radians(55))
def plaza_gajo():
    """Un gajo de 30 grados del piso (radio 15 a 42). Doce gajos arman el círculo. El origen
    es el centro de la plaza, arriba del piso."""
    zonas = [
        ("Adentro", 15, 30, PISO_ADENTRO),
        ("Anillo", 30, 31, PISO_ANILLO),
        ("Afuera", 31, 41.2, PISO_AFUERA),
        ("Borde", 41.2, 42, "Contorno"),
    ]
    objs = []
    for parte, r1, r2, col in zonas:
        bm = bmesh.new()
        C.anillo_plano(bm, r1, r2, -1, 0, segmentos=12, desde=-15, hasta=15)
        objs.append(G.malla(parte, bm, col))
    bm = bmesh.new()  # franjas de seguridad en el borde
    for i in range(10):
        a = -15 + 3 * i + 0.75
        C.anillo_plano(bm, 41.3, 41.9, -0.2, 0.04, segmentos=2, desde=a, hasta=a + 1.5)
    objs.append(G.malla("Franjas", bm, "Dorado"))
    return objs


@G.objeto("Baranda", 3000)
def baranda():
    """Tramo de baranda baja de 6 studs con franjas de seguridad (solo decoración: en Roblox
    no choca)."""
    bm = bmesh.new()
    for x in (-2.7, 2.7):
        C.cilindro(bm, 0.32, 0.18, segmentos=12, matriz=mover(x), redondeo=0.06)
        C.cilindro(bm, 0.16, 2.05, segmentos=10, matriz=mover(x))
        C.esfera(bm, (x, 0, 2.15), 0.24, segmentos=10, anillos=6)
    C.tubo(bm, [(-2.7, 0, 0.95), (2.7, 0, 0.95)], 0.09, lados=8)
    estructura = G.malla("Postes", bm, "Metal")
    bm_a, bm_b = bmesh.new(), bmesh.new()
    n = 6
    for i in range(n):
        x0 = -2.55 + 5.1 * i / n
        x1 = -2.55 + 5.1 * (i + 1) / n
        C.caja(bm_a if i % 2 == 0 else bm_b, ((x0 + x1) / 2, 0, 1.85), (x1 - x0, 0.26, 0.3))
    franja_a = G.malla("FranjaClara", bm_a, "Dorado", bisel=0.05)
    franja_b = G.malla("FranjaOscura", bm_b, "Contorno", bisel=0.05)
    return [estructura, franja_a, franja_b]


# ---------------------------------------------------------------------------
# Muebles de la plaza
# ---------------------------------------------------------------------------


@G.objeto("Farol", 3000)
def farol():
    """Farol de laboratorio de 9 studs: poste de metal, globo de vidrio y foco verde."""
    bm = bmesh.new()
    C.cilindro(bm, 0.78, 0.35, segmentos=16, redondeo=0.12)
    C.cilindro(bm, 0.5, 0.6, segmentos=14, matriz=mover(z=0.33), radio_arriba=0.28, redondeo=0.06)
    C.cilindro(bm, 0.17, 6.1, segmentos=10, matriz=mover(z=0.9))
    C.toro(bm, 0.2, 0.08, segmentos=14, lados=6, matriz=mover(z=3.7))
    C.cilindro(bm, 0.64, 0.2, segmentos=16, matriz=mover(z=6.9), redondeo=0.07)
    for k in range(4):
        a = math.radians(45 + 90 * k)
        C.tubo(bm, [(0.56 * math.cos(a), 0.56 * math.sin(a), 7.05), (0.56 * math.cos(a), 0.56 * math.sin(a), 8.4)], 0.06, lados=5)
    C.cilindro(bm, 0.82, 0.5, segmentos=16, matriz=mover(z=8.35), radio_arriba=0.22, redondeo=0.08)
    C.esfera(bm, (0, 0, 8.98), 0.16, segmentos=10, anillos=6)
    metal = G.malla("Poste", bm, "Metal")

    bm = bmesh.new()
    C.cilindro(bm, 0.5, 1.3, segmentos=16, matriz=mover(z=7.07), redondeo=0.16)
    globo = G.malla("Globo_Vidrio", bm, "Laboratorio.CupulaAbierta")

    bm = bmesh.new()
    C.esfera(bm, (0, 0, 7.72), 0.32, segmentos=12, anillos=7)
    C.toro(bm, 0.66, 0.06, segmentos=20, lados=5, matriz=mover(z=8.36))
    foco = G.malla("Foco_Neon", bm, "Acento")
    return [metal, globo, foco]


@G.objeto("Banco", 3000)
def banco():
    """Banco redondeado de metal, 6 de largo. El frente (donde uno se sienta) mira a -Y."""
    bm = bmesh.new()
    for y in (-0.62, 0.0, 0.62):
        C.caja(bm, (0, y, 1.6), (5.9, 0.58, 0.34))
    for z in (2.45, 3.2):
        C.caja(bm, (0, 1.0 + (z - 2.45) * 0.17, z), (5.9, 0.3, 0.62))
    tablas = G.malla("Tablas", bm, "SuperficieClara", bisel=0.13, segmentos_bisel=3)

    bm = bmesh.new()
    for x in (-2.35, 2.35):
        C.tubo(bm, [(x, -0.78, 0.05), (x, -0.78, 1.4), (x, 0.82, 1.4), (x, 0.95, 2.0), (x, 1.15, 3.5)], 0.17, lados=8)
        C.tubo(bm, [(x, 0.82, 0.05), (x, 0.82, 1.4)], 0.17, lados=8)
        for y in (-0.78, 0.82):
            C.cilindro(bm, 0.22, 0.1, segmentos=10, matriz=mover(x, y), redondeo=0.04)
    patas = G.malla("Patas", bm, "Metal")
    return [tablas, patas]


@G.objeto("CartelFlecha", 3000)
def cartel_flecha():
    """Cartel con flecha de neón que apunta a un laboratorio. El cartel con el texto (una parte
    de Roblox con SurfaceGui, 6,4 x 2,6) va adentro del marco, centrado a 5,6 de alto."""
    alto, ancho, z = 2.6, 6.4, 5.6
    bm = bmesh.new()
    g = 0.32
    C.marco(bm, ancho, alto, g, 0.5, matriz=mover(z=z))
    for s in (-1, 1):
        C.cilindro(bm, 0.2, z - alto / 2 - g + 0.05, segmentos=10, matriz=mover(s * (ancho / 2 + g / 2)))
        C.cilindro(bm, 0.42, 0.22, segmentos=12, matriz=mover(s * (ancho / 2 + g / 2)), redondeo=0.08)
    C.cilindro(bm, 0.12, 0.45, segmentos=8, matriz=mover(0, 0, z + alto / 2 + g))
    marco = G.malla("Marco", bm, "Metal", bisel=0.08)

    bm = bmesh.new()
    C.caja(bm, (0, 0.2, z), (ancho, 0.1, alto))
    fondo = G.malla("Fondo", bm, "Contorno")

    bm = bmesh.new()
    flecha = [(-1.3, 0.0), (0.0, 1.2), (1.3, 0.0), (0.8, 0.0), (0.0, 0.72), (-0.8, 0.0)]
    C.extruir(bm, flecha, 0.22, matriz=mover(0, 0.11, z + alto / 2 + g + 0.4) @ girar(90, "X"))
    neon = G.malla("Flecha_Neon", bm, "Acento", bisel=0.04)
    return [marco, fondo, neon]


@G.objeto("TableroPlaza", 8000)
def tablero_plaza():
    """Soporte con pantalla grande (tabla de posiciones y experimento del día). La pantalla
    (parte de Roblox con SurfaceGui, 18 x 9,5) va adentro del marco, centrada a 11 de alto."""
    alto, ancho, z = 9.5, 18.0, 11.0
    bm = bmesh.new()
    g = 0.7
    C.marco(bm, ancho, alto, g, 1.0, matriz=mover(z=z))
    for s in (-1, 1):
        C.cilindro(bm, 0.45, z - alto / 2 - g + 0.1, segmentos=12, matriz=mover(s * 6.06))
        C.caja(bm, (s * 6.06, 0, 0.25), (1.8, 2.4, 0.5))
    marco = G.malla("Marco", bm, "Metal", bisel=0.18)

    bm = bmesh.new()
    C.caja(bm, (0, 0.4, z), (ancho, 0.15, alto))
    fondo = G.malla("Fondo", bm, "Contorno")

    bm = bmesh.new()
    C.tubo(bm, [(-ancho / 2 + 0.6, -0.52, z + alto / 2 + g / 2), (ancho / 2 - 0.6, -0.52, z + alto / 2 + g / 2)], 0.13, lados=8)
    for s in (-1, 1):
        C.esfera(bm, (s * (ancho / 2 + g / 2), -0.5, z + alto / 2 + g / 2), 0.32, segmentos=10, anillos=6)
    luz = G.malla("Luz_Neon", bm, "Acento")
    return [marco, fondo, luz]


@G.objeto("MarcoDestacado", 8000)
def marco_destacado():
    """Cartel del laboratorio destacado: marco dorado con una placa oscura para el nombre
    (en Roblox la placa lleva el SurfaceGui) y una estrella arriba."""
    alto, ancho, z = 3.0, 8.0, 5.0
    bm = bmesh.new()
    g = 0.45
    C.marco(bm, ancho, alto, g, 0.6, matriz=mover(z=z))
    for s in (-1, 1):
        for dz in (-1, 1):
            C.esfera(bm, (s * (ancho / 2 + g / 2), -0.1, z + dz * (alto / 2 + g / 2)), 0.42, segmentos=10, anillos=6)
    C.extruir(bm, C.estrella(1.0, 5, 0.45), 0.35, matriz=mover(0, 0.17, z + alto / 2 + g + 0.95) @ girar(90, "X"))
    oro = G.malla("Marco", bm, "Dorado", bisel=0.08)

    bm = bmesh.new()
    for s in (-1, 1):
        C.cilindro(bm, 0.22, z - alto / 2 - g + 0.05, segmentos=10, matriz=mover(s * 3.0))
    C.cilindro(bm, 3.8, 0.3, segmentos=24, matriz=None, redondeo=0.1)
    soporte = G.malla("Soporte", bm, "Metal")

    bm = bmesh.new()
    C.caja(bm, (0, 0.15, z), (ancho, 0.2, alto))
    placa = G.malla("Placa", bm, "Contorno")
    return [oro, soporte, placa]


# ---------------------------------------------------------------------------
# Máquina de fusión en equipo (centro de la plaza)
# ---------------------------------------------------------------------------


def _tubo_estacion(bm, x, radio):
    """Caño que sube desde la ranura de un costado y entra a la cápsula del centro."""
    s = 1 if x > 0 else -1
    camino = [(x, 0, 8.5), (x, 0, 11.6)]
    for i in range(1, 7):  # codo redondeado de radio 1.4
        a = math.radians(90 * i / 6)
        camino.append((x - s * 1.4 * (1 - math.cos(a)), 0, 11.6 + 1.4 * math.sin(a)))
    camino.append((s * 4.0, 0, 13.0))
    C.tubo(bm, camino, radio, lados=10, tapas=True)


@G.objeto("MaquinaEquipo", 8000, elevacion=math.radians(25))
def maquina_equipo():
    """La máquina grande de la plaza. Reemplaza la base hexagonal, los anillos, la tapa y los
    caños; la cápsula, el líquido, las ranuras, los pedestales y los carteles siguen siendo
    las partes de Roblox que usa el código."""
    bm = bmesh.new()  # base hexagonal (lados que miran al frente y atrás, como en Studio)
    C.extruir(bm, C.circulo(11.0, lados=6), 1.8)
    for x in (-13, 13):
        C.cilindro(bm, 2.35, 3.2, segmentos=20, matriz=mover(x), radio_arriba=2.15, redondeo=0.25)
    base = G.malla("Base", bm, METAL_OSCURO, bisel=0.18)

    bm = bmesh.new()
    C.cilindro(bm, 5.1, 1.6, segmentos=32, matriz=mover(z=1.8), redondeo=0.3)  # anillo de la cápsula
    C.cilindro(bm, 5.2, 1.3, segmentos=32, matriz=mover(z=18.35), radio_arriba=4.4, redondeo=0.35)  # tapa
    C.cilindro(bm, 2.3, 2.0, segmentos=20, matriz=mover(z=19.5), redondeo=0.2)  # cuello
    for x in (-13, 13):
        C.cilindro(bm, 2.3, 0.7, segmentos=20, matriz=mover(x, 0, 7.85), redondeo=0.2)  # tapas de las ranuras
        C.cilindro(bm, 1.0, 0.55, segmentos=12, matriz=mover(x, 0, 8.45), redondeo=0.12)
        s = 1 if x > 0 else -1
        for px in (x, s * 4.4):  # abrazaderas
            pz = 10.0 if px == x else 13.0
            eje = girar(90, "Y") if px != x else None
            m = mover(px, 0, pz) @ (eje if eje is not None else girar(0)) @ mover(z=-0.25)
            C.cilindro(bm, 0.95, 0.5, segmentos=14, matriz=m, redondeo=0.12)
    metal = G.malla("Metal", bm, "Metal", bisel=0.0)

    bm = bmesh.new()
    for x in (-13, 13):
        _tubo_estacion(bm, x, 0.75)
    tubos = G.malla("Tubos_Vidrio", bm, "Laboratorio.CupulaAbierta")

    bm = bmesh.new()
    for x in (-13, 13):
        _tubo_estacion(bm, x, 0.38)
        C.toro(bm, 1.95, 0.09, segmentos=24, lados=6, matriz=mover(x, 0, 3.25))  # luz de la ranura
    C.toro(bm, 4.7, 0.12, segmentos=40, lados=6, matriz=mover(z=3.45))  # luz del anillo
    C.toro(bm, 2.35, 0.1, segmentos=24, lados=6, matriz=mover(z=20.6))  # luz del cuello
    hexa = C.circulo(10.85, lados=6)
    for i in range(6):  # borde de neón arriba de la base
        a, b = hexa[i], hexa[(i + 1) % 6]
        C.tubo(bm, [(a[0], a[1], 1.86), (b[0], b[1], 1.86)], 0.12, lados=6)
    luces = G.malla("Luces_Neon", bm, "Acento")
    return [base, metal, tubos, luces]


# ---------------------------------------------------------------------------
# Portal al Jardín Salvaje (también sirve de portal de regreso)
# ---------------------------------------------------------------------------


@G.objeto("PortalJardin", 8000)
def portal_jardin():
    """Arco de raíces retorcidas con hongos, y un remolino verde que gira (por código)."""
    bm = bmesh.new()
    radio_arco, alto_pie = 5.0, 5.5
    for k, fase in enumerate((0.0, 2.1, 4.2)):
        camino, radios = [], []
        n = 60
        for i in range(n + 1):
            t = i / n
            if t < 0.2:  # pie izquierdo: sube derecho
                u = t / 0.2
                cx, cz = -radio_arco, alto_pie * u
            elif t > 0.8:
                u = (t - 0.8) / 0.2
                cx, cz = radio_arco, alto_pie * (1 - u)
            else:
                u = (t - 0.2) / 0.6
                a = math.pi * (1 - u)
                cx, cz = radio_arco * math.cos(a), alto_pie + radio_arco * math.sin(a)
            giro = 14 * t * math.pi + fase
            camino.append((cx + 0.45 * math.cos(giro), 0.45 * math.sin(giro), cz))
            radios.append(0.42 - 0.1 * math.sin(math.pi * t) + (0.25 if t < 0.05 or t > 0.95 else 0))
        C.tubo(bm, camino, radios, lados=7)
    for s in (-1, 1):  # raíces del pie que se abren en el piso
        for k in range(3):
            a = math.radians(-60 + 60 * k + (0 if s < 0 else 180))
            C.tubo(
                bm,
                [(s * radio_arco, 0, 1.2), (s * radio_arco + 1.0 * math.cos(a), 1.0 * math.sin(a), 0.3), (s * radio_arco + 1.9 * math.cos(a), 1.9 * math.sin(a), 0.05)],
                [0.38, 0.25, 0.1],
                lados=6,
            )
    raices = G.malla("Raices", bm, "#5a3d2b")

    sombreros, pies, lunares = bmesh.new(), bmesh.new(), bmesh.new()
    hongos = [(-5.4, 7.0, 1.1, 30), (4.1, 9.6, 0.8, -40), (5.6, 3.2, 0.7, -70), (-1.5, 10.6, 0.6, 10)]
    for hx, hz, tam, inclina in hongos:
        m = mover(hx, -0.3, hz) @ girar(inclina, "Y")
        C.cilindro(pies, 0.28 * tam, 0.7 * tam, segmentos=10, matriz=m, redondeo=0.08 * tam)
        C.esfera(sombreros, (0, 0, 0.75 * tam), (1.0 * tam, 1.0 * tam, 0.55 * tam), segmentos=14, anillos=6, matriz=m)
        for j in range(4):
            a = math.radians(90 * j + 20)
            C.esfera(lunares, (0.6 * tam * math.cos(a), 0.6 * tam * math.sin(a), 1.1 * tam), 0.16 * tam, segmentos=8, anillos=5, matriz=m)
    objs = [
        raices,
        G.malla("Pies", pies, "Piezas.Crema"),
        G.malla("Sombreros", sombreros, "Alerta"),
        G.malla("Lunares_Neon", lunares, "Texto"),
    ]

    bm = bmesh.new()  # remolino: tres brazos en espiral, planos, en el hueco del arco
    for k in range(3):
        brazo = []
        for i in range(40):
            t = i / 39
            a = 2 * math.pi * k / 3 + t * 3.2 * math.pi
            r = 0.3 + 4.2 * t
            brazo.append((r * math.cos(a), 0.0, alto_pie + r * math.sin(a) * 0.95))
        C.tubo(bm, brazo, [0.12 + 0.3 * (i / 39) for i in range(40)], lados=6)
    C.esfera(bm, (0, 0, alto_pie), 0.6, segmentos=12, anillos=6)
    objs.append(G.malla("Remolino_Neon_Anim", bm, "Acento"))
    C.asentar(objs)
    return objs


G.terminar()
