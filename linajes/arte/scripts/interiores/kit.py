"""Kit modular de interiores (P25d): piezas en grilla de 4 studs que comparten todos los interiores.

Reglas del prompt: puertas de 4 x 7, techos de 12 (24 en halls grandes), pasillos de 6 o más de
ancho. La pared tiene su cara de adentro en y = 0 y su espesor hacia +Y (afuera); el pivote va abajo
y al centro. Medidas en studs.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lugares"))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import puerto_oxido as P  # noqa: E402

pieza = P.pieza
MOD = 4  # grilla
ALTO = 12  # altura de piso a techo
GROSOR = 0.8

PRESUPUESTO = {
    "Int_Pared": 200, "Int_ParedVentana": 600, "Int_ParedPuerta": 400, "Int_Piso": 50, "Int_Techo": 50,
    "Int_Escalera": 1200, "Int_Baranda": 300, "Int_Vidrio": 40,
}


def pared(nombre="Int_Pared", alto=ALTO, material="ladrillo"):
    return pieza(nombre, [((MOD, GROSOR, alto), (0, GROSOR / 2, alto / 2))], material)


def pared_ventana(alto=ALTO, material="ladrillo"):
    """Ventana de 2,4 x 3 con el alféizar a 3,5 (se ve la calle sin dejar pasar a nadie)."""
    g = GROSOR
    c = [((MOD, g, 3.5), (0, g / 2, 1.75)), ((MOD, g, alto - 6.5), (0, g / 2, (alto + 6.5) / 2))]
    c += [((0.8, g, 3), (sx * 1.6, g / 2, 5)) for sx in (-1, 1)]
    return pieza("Int_ParedVentana", c, material)


def pared_puerta(alto=ALTO, material="ladrillo"):
    """Hueco de puerta de 4 x 7 (todo el módulo de ancho, dintel arriba)."""
    return pieza("Int_ParedPuerta", [((MOD, GROSOR, alto - 7), (0, GROSOR / 2, (alto + 7) / 2))], material)


def piso(material="concreto"):
    return pieza("Int_Piso", [((MOD, MOD, 0.4), (0, 0, -0.2))], material)


def techo(alto=ALTO, material="concreto"):
    return pieza("Int_Techo", [((MOD, MOD, 0.4), (0, 0, alto + 0.2))], material)


def escalera(alto=ALTO, ancho=MOD):
    """Escalera recta que sube `alto` en 2 x alto de largo (pendiente suave, sin trabas)."""
    n = int(alto / 0.75)
    paso = alto / n
    largo = alto * 1.4
    return pieza("Int_Escalera", [((ancho, largo / n + 0.05, paso * (k + 1)), (0, -largo / 2 + largo / n * (k + 0.5), paso * (k + 1) / 2)) for k in range(n)], "concreto")


def baranda(material="hierro"):
    c = [((MOD, 0.2, 0.2), (0, 0, z)) for z in (1.6, 3.2)] + [((0.2, 0.2, 3.2), (x, 0, 1.6)) for x in (-1.9, 0, 1.9)]
    return pieza("Int_Baranda", c, material)


def todas():
    for n, d in (("concreto", {"hex": "5d5f63", "rugosidad": 0.95}),):
        B.MATERIALES.setdefault(n, d)
    return [pared(), pared_ventana(), pared_puerta(), piso(), techo(), escalera(), baranda()]


# ---------------------------------------------------------------------------
# Paso 2: el mismo kit con detalle (mismos nombres, pivotes y medidas)
# ---------------------------------------------------------------------------


def _zocalo_y_moldura(alto):
    """Zócalo de 0,8 abajo y moldura arriba, del lado de adentro (y < 0)."""
    return [((MOD, 0.2, 0.8), (0, -0.1, 0.4)), ((MOD, 0.25, 0.35), (0, -0.12, alto - 0.6))]


def pared_d(alto=ALTO, material="ladrillo"):
    g = GROSOR
    c = [((MOD, g, alto), (0, g / 2, alto / 2))] + _zocalo_y_moldura(alto)
    return pieza("Int_Pared", c, material)


def pared_ventana_d(alto=ALTO, material="ladrillo"):
    g = GROSOR
    c = [((MOD, g, 3.5), (0, g / 2, 1.75)), ((MOD, g, alto - 6.5), (0, g / 2, (alto + 6.5) / 2))]
    c += [((0.8, g, 3), (sx * 1.6, g / 2, 5)) for sx in (-1, 1)]
    c += [((MOD, 0.2, 0.8), (0, -0.1, 0.4)), ((MOD, 0.25, 0.35), (0, -0.12, alto - 0.6))]
    c += [((2.8, 1.3, 0.25), (0, 0.3, 3.4)), ((2.8, 0.3, 0.3), (0, -0.1, 6.6))]  # alféizar y dintel
    c += [((0.2, 0.3, 3), (x, 0.2, 5)) for x in (-1.2, 0, 1.2)] + [((2.4, 0.3, 0.2), (0, 0.2, 5))]  # marco con cruz
    c += [((0.3, 0.3, 3.2), (x, 0.65, 5)) for x in (-0.9, -0.3, 0.3, 0.9)]  # rejas de afuera
    return pieza("Int_ParedVentana", c, material)


def vidrio_ventana():
    return pieza("Int_Vidrio", [((2.4, 0.06, 3.0), (0, 0.32, 5))], "vidrio-sucio")


def pared_puerta_d(alto=ALTO, material="ladrillo"):
    g = GROSOR
    c = [((MOD, g, alto - 7), (0, g / 2, (alto + 7) / 2)), ((MOD, 0.25, 0.35), (0, -0.12, alto - 0.6))]
    c += [((0.3, g + 0.4, 7.2), (sx * 1.85, g / 2, 3.6)) for sx in (-1, 1)] + [((4, g + 0.4, 0.4), (0, g / 2, 7.2))]  # marco
    return pieza("Int_ParedPuerta", c, material)


def piso_d(material="concreto"):
    c = [((MOD, MOD, 0.4), (0, 0, -0.2))]  # las juntas y las manchas de aceite van en la textura
    return pieza("Int_Piso", c, material)


def escalera_d(alto=ALTO, ancho=MOD):
    n = int(alto / 0.75)
    paso = alto / n
    largo = alto * 1.4
    c = [((ancho, largo / n + 0.05, paso * (k + 1)), (0, -largo / 2 + largo / n * (k + 0.5), paso * (k + 1) / 2)) for k in range(n)]
    c += [((ancho + 0.1, 0.25, 0.08), (0, -largo / 2 + largo / n * (k + 1) - 0.1, paso * (k + 1) + 0.04)) for k in range(n)]  # narices antideslizantes
    return pieza("Int_Escalera", c, "concreto")


def baranda_d(material="hierro"):
    c = [((MOD, 0.25, 0.25), (0, 0, 3.3))] + [((MOD, 0.12, 0.12), (0, 0, z)) for z in (0.5, 1.9)]
    c += [((0.25, 0.25, 3.3), (x, 0, 1.65)) for x in (-1.9, 1.9)] + [((0.1, 0.1, 3.2), (x, 0, 1.6)) for x in (-1.2, -0.4, 0.4, 1.2)]
    return pieza("Int_Baranda", c, material)


def todas_detalle():
    B.MATERIALES.setdefault("concreto", {"hex": "5d5f63", "rugosidad": 0.95})
    B.MATERIALES.setdefault("vidrio-sucio", {"hex": "2a3a40", "rugosidad": 0.15, "metal": 0.3})
    return [pared_d(), pared_ventana_d(), pared_puerta_d(), piso_d(), techo(), escalera_d(), baranda_d(), vidrio_ventana()]
