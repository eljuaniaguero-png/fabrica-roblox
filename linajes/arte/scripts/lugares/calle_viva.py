"""Calle viva (P20e), solo lo de la Beta de Puerto Óxido: vehículos de la calle, vigilancia, lo del
atraco chico, el cartel de BUSCADO y el callejón peligrosos de "Los Óxido".

Queda para después (resto del prompt): helicóptero, camión táctico, blindado de caudales, moto y auto
del jugador, subte, ferry, reflector, arco escáner, taladro, cajero, caja de hacker, kiosco, pantalla
gigante, TV de bar, radio y perros (los perros necesitan rig propio).

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/lugares/calle_viva.py -- boceto

Medidas en studs; un jugador mide unos 5 studs. Diseños propios: ninguna marca real de autos.
Ruedas aparte (una malla por tipo de rueda, se copia 4 veces y gira en Roblox).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import puerto_oxido as P  # noqa: E402

pieza = P.pieza
_barra = P._barra
ARCHIVO = "calle-viva"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")

B.MATERIALES.setdefault("patrulla-azul", {"hex": "1f4a5a", "rugosidad": 0.35, "metal": 0.6})
B.MATERIALES.setdefault("auto-civil", {"hex": "8a8f99", "rugosidad": 0.35, "metal": 0.6})  # 4 colores por código
B.MATERIALES.setdefault("taxi", {"hex": "b8922e", "rugosidad": 0.35, "metal": 0.6})
B.MATERIALES.setdefault("goma", {"hex": "16171a", "rugosidad": 0.9})
B.MATERIALES.setdefault("neon-sirena", {"hex": "ff2a2a", "brillo": 6.0})
B.MATERIALES.setdefault("neon-fuego", {"hex": "ff7a1a", "brillo": 8.0})
B.MATERIALES.setdefault("lona", {"hex": "6b6450", "rugosidad": 1.0})
B.MATERIALES.setdefault("corcho", {"hex": "9a6b3f", "rugosidad": 1.0})
B.MATERIALES.setdefault("papel", {"hex": "dcd8cc", "rugosidad": 1.0})
B.MATERIALES.setdefault("contenedor-verde", {"hex": "3d5a3a", "rugosidad": 0.6, "metal": 0.5})
B.MATERIALES.setdefault("colchon", {"hex": "b0a690", "rugosidad": 1.0})

PRESUPUESTO = {
    "Patrulla_Carroceria": 8000, "Patrulla_Rueda": 400, "Patrulla_Sirena": 600,
    "Compacto_Carroceria": 6000, "Camioneta_Carroceria": 6000, "Taxi_Carroceria": 6000, "Civil_Rueda": 300, "Taxi_Cartel": 200,
    "Camara_Pared": 800, "Camara_Poste": 800, "Camara_Rota": 800, "Camara_Luz": 50,
    "Barrera": 1300, "Barrera_Luces": 200,
    "Esposas": 400, "Bolsa_Botin": 800, "Alijo": 1000, "Tablero_Golpes": 2000,
    "Cartel_Buscado": 200,
    "Farola_Rota": 1500, "Basura_Volcado": 1500, "Colchon": 1500, "Barril_Fuego": 1300, "Barril_Llamas": 200,
    "Reja_Deposito": 1500, "Escalera_Incendio": 1500, "Grafiti_1": 12, "Grafiti_2": 12, "Grafiti_3": 12,
}
P.ENCIMA = ("Patrulla_Sirena", "Taxi_Cartel", "Camara_Luz", "Barrera_Luces", "Barril_Llamas")


# ---------------------------------------------------------------------------
# Vehículos (frente hacia -Y)
# ---------------------------------------------------------------------------


def _sedan(largo=16, ancho=7, techo=5.4):
    """Sedán anguloso: chasis, capó y baúl inclinados, cabina con parantes."""
    a = ancho / 2
    c = [((ancho, largo, 2.2), (0, 0, 1.9)), ((ancho - 0.2, 4.2, 0.6), (0, -largo / 2 + 2.1, 3.2), (-5, 0, 0))]
    c += [((ancho - 0.2, 3.4, 0.6), (0, largo / 2 - 1.7, 3.2), (4, 0, 0))]
    c += [((ancho - 0.6, 7, techo - 3.5), (0, 0.4, (3 + techo) / 2 + 0.2))]  # cabina
    c += [((ancho + 0.3, 1.0, 0.8), (0, s * (largo / 2 + 0.2), 1.2)) for s in (-1, 1)]  # paragolpes
    return c


def vehiculos():
    pat = pieza("Patrulla_Carroceria", _sedan(), "patrulla-azul")
    sir = pieza("Patrulla_Sirena", [((5, 1.2, 0.6), (0, 0.4, 5.9))], "neon-sirena")
    rueda_p = pieza("Patrulla_Rueda", [], "goma", cilindros=[(1.3, 1.0, (-0.5, 0, 1.3), "X", 16)])
    comp = pieza("Compacto_Carroceria", _sedan(13, 6.6, 6), "auto-civil")
    cam = [((7, 17, 2.4), (0, 0, 2.0)), ((6.8, 6, 3.4), (0, -3.5, 4.9)), ((6.8, 1, 0.6), (0, -6.7, 3.6), (-30, 0, 0))]
    cam += [((0.4, 8, 1.6), (s * 3.3, 4.4, 4.0)) for s in (-1, 1)] + [((7, 0.4, 1.6), (0, 8.3, 4.0))]
    camioneta = pieza("Camioneta_Carroceria", cam, "auto-civil")
    taxi = pieza("Taxi_Carroceria", _sedan(), "taxi")
    cartel = pieza("Taxi_Cartel", [((2.4, 0.8, 0.8), (0, 0.4, 6.0))], "papel")
    rueda_c = pieza("Civil_Rueda", [], "goma", cilindros=[(1.2, 0.9, (-0.45, 0, 1.2), "X", 14)])
    return [pat, sir, rueda_p, comp, camioneta, taxi, cartel, rueda_c]


# ---------------------------------------------------------------------------
# Vigilancia
# ---------------------------------------------------------------------------


def _carcasa(x, y, z, inclinada=20):
    return [((0.8, 1.8, 0.8), (x, y - 0.6, z - 0.3), (inclinada, 0, 0)), ((1.0, 2.0, 0.12), (x, y - 0.6, z + 0.2), (inclinada, 0, 0))]


def vigilancia():
    pared = pieza("Camara_Pared", [((1, 0.3, 1.2), (0, 0.6, 8)), _barra((0, 0.5, 8), (0, -0.6, 8), 0.25)] + _carcasa(0, -0.6, 8), "blanco-armadura")
    poste = pieza(
        "Camara_Poste",
        [((0.5, 0.5, 12), (0, 0, 6)), _barra((0, 0, 11.5), (0, -2, 11.5), 0.3)] + _carcasa(0, -2, 11.3),
        "blanco-armadura",
    )
    rota = [((1, 0.3, 1.2), (0, 0.6, 8)), _barra((0, 0.5, 8), (0, -0.4, 7.6), 0.25), ((0.8, 1.8, 0.8), (0.3, -0.6, 6.9), (55, 0, 25))]
    rota += [_barra((0.1, 0, 7.4), (0.5, -0.2, 5.4), 0.08), _barra((-0.1, 0, 7.4), (-0.4, 0.1, 5.9), 0.08)]  # cables colgando
    rota = pieza("Camara_Rota", rota, "blanco-armadura")
    luz = pieza("Camara_Luz", [((0.2, 0.2, 0.2), (0.3, -1.4, 7.6))], "neon-sirena")
    barrera = [((1.2, 1.2, 3.4), (s * 6, 0, 1.7)) for s in (-1, 1)] + [((2.4, 1.6, 0.4), (s * 6, 0, 0.2)) for s in (-1, 1)]
    barrera += [((13.2, 0.4, 1.0), (0, 0, z)) for z in (2.0, 3.4)]
    barrera = pieza("Barrera", barrera, "cordon-amarillo")
    luces = pieza("Barrera_Luces", [((0.7, 0.7, 0.7), (s * 6, 0, 4.0)) for s in (-1, 1)], "neon-sirena")
    return [pared, poste, rota, luz, barrera, luces]


# ---------------------------------------------------------------------------
# Crimen y atracos, noticias
# ---------------------------------------------------------------------------


def crimen():
    esp = pieza("Esposas", [_barra((-0.5, 0, 0.1), (0.5, 0, 0.1), 0.08)], "acero", cilindros=[(0.35, 0.1, (s * 0.7, 0, 0.05), "Z", 12) for s in (-1, 1)])
    bolsa = pieza("Bolsa_Botin", [((2.2, 1.6, 1.4), (0, 0, 0.7)), ((0.6, 0.6, 0.8), (0, 0, 1.7))], "lona")
    alijo = pieza("Alijo", [((3, 2, 1.8), (0, 0, 0.9)), ((3.1, 2.1, 0.3), (0, 0, 1.95)), ((0.6, 0.3, 0.7), (0, -1.15, 1.3))], "madera-muelle")
    tab = [((8, 0.4, 5), (0, 0, 5.5)), ((8.3, 0.5, 0.3), (0, 0, 8.1)), ((8.3, 0.5, 0.3), (0, 0, 2.9))]
    tab += [((0.3, 0.3, 4), (s * 3.6, 0.2, 2)) for s in (-1, 1)]
    tablero = pieza("Tablero_Golpes", tab, "corcho")
    buscado = pieza("Cartel_Buscado", [((2, 0.05, 2.8), (0, 0, 1.4))], "papel")
    return [esp, bolsa, alijo, tablero, buscado]


# ---------------------------------------------------------------------------
# Callejón peligroso
# ---------------------------------------------------------------------------


def callejon():
    farola = pieza(
        "Farola_Rota",
        [((1.2, 1.2, 0.8), (0, 0, 0.4)), _barra((0, 0, 0.8), (0, 0, 9), 0.4), _barra((0, 0, 9), (0.6, -1.8, 11.4), 0.4), ((1.2, 1.2, 0.8), (0.7, -2.2, 11.4), (0, 0, 0))],
        "hierro",
    )
    basura = [((6, 3.4, 4), (0, 0, 1.7), (0, 0, 0)), ((6.2, 0.3, 3.6), (0, -2.4, 1.0), (60, 0, 0))]
    basura = [((6, 4, 3.4), (0, 0, 1.7)), ((6.2, 3.8, 0.3), (0, -3.6, 0.6), (-70, 0, 0))]  # volcado, tapa abierta
    basura += [((1.6, 1.4, 1.2), (x, -3.4 - d, 0.6)) for x, d in ((-1.8, 0.5), (0.4, 1.4), (2.2, 0.2))]  # bolsas
    basura = pieza("Basura_Volcado", basura, "contenedor-verde")
    colchon = pieza("Colchon", [((4, 6, 0.9), (0, 0, 2.5), (60, 0, 0))], "colchon")
    barril = pieza("Barril_Fuego", [], "oxido", cilindros=[(1, 3, (0, 0, 0), "Z", 12)])
    llamas = pieza("Barril_Llamas", [((1.2, 1.2, 1.6), (0, 0, 3.6), (0, 0, 20)), ((0.8, 0.8, 1.4), (0.2, 0.1, 4.4), (0, 0, 50))], "neon-fuego")
    reja = [((0.4, 0.4, 10), (s * 6, 0, 5)) for s in (-1, 1)] + [((12, 0.3, 0.3), (0, 0, z)) for z in (0.4, 9.6)]
    reja += [((0.15, 0.15, 9.2), (-5.6 + i * 0.8, 0, 5)) for i in range(15)]
    reja += [((0.6, 0.6, 0.8), (0.4, -0.3, 4.6))]  # candado
    reja = pieza("Reja_Deposito", reja, "hierro")
    esc = [((6, 3, 0.3), (0, -1.5, z)) for z in (10, 20)]
    esc += [((6, 0.15, 1.2), (0, -3, z + 0.6)) for z in (10, 20)]
    esc += [_barra((-2.4, -0.5, 10), (2.4, -2.5, 19.6), 0.3), _barra((2.6, -2.8, 9.8), (3.2, -3.4, 4.5), 0.25)]  # tramo y escalera rota colgando
    esc += [((0.2, 0.2, 3), (3, -3.2, 6.5), (0, 25, 0))]
    escalera = pieza("Escalera_Incendio", esc, "hierro")
    grafitis = [pieza(f"Grafiti_{i}", [((6, 0.02, 4), (0, 0, 2))], "papel") for i in (1, 2, 3)]
    return [farola, basura, colchon, barril, llamas, reja, escalera] + grafitis


# Dónde van las 4 ruedas de cada auto: (rueda, medio ancho, medio largo)
EJES = {
    "Patrulla_Carroceria": ("Patrulla_Rueda", 3.6, 5.2),
    "Taxi_Carroceria": ("Civil_Rueda", 3.6, 5.2),
    "Compacto_Carroceria": ("Civil_Rueda", 3.4, 4.2),
    "Camioneta_Carroceria": ("Civil_Rueda", 3.6, 5.6),
}


def poner_ruedas(p):
    """Copias de las ruedas en su lugar (solo para ver los autos armados; en Roblox giran aparte)."""
    hechas = []
    for auto, (rueda, a, l) in EJES.items():
        base = p[auto].location / B.STUD
        for sx in (-1, 1):
            for sy in (-1, 1):
                hechas.append(P.copia(p[rueda], base.x + sx * a + (0.5 if sx < 0 else -0.5) * 0, base.y + sy * l, 0 if sx > 0 else 180))
    p["Patrulla_Rueda"].hide_render = p["Civil_Rueda"].hide_render = False
    return hechas


def todas():
    return [vehiculos(), vigilancia(), crimen(), callejon()]


def boceto():
    B.cargar_kit()
    for o in list(bpy.data.objects):
        if o.name.startswith(B.ESQUELETO):
            bpy.data.objects.remove(o)
    grupos = todas()
    P.grilla(grupos, separacion=5)
    piezas = [o for f in grupos for o in f]
    bpy.context.view_layer.update()
    ruedas = poner_ruedas({o.name: o for o in piezas})
    P.luz_puerto()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    cuenta = B.contar_triangulos(piezas)
    r = P.render_orto(ARCHIVO + "_boceto_grilla", piezas + ruedas, giro=-25, altura=40, niebla=False)
    return cuenta, r


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in pasos:
        print(boceto())
