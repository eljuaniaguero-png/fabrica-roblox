"""Texturas de studs como las referencias (pedido D3, 25/10/2026).

En estilo-1, lobby-1 y lobby-2 cada stud es un cuadradito con el borde apenas más oscuro (no un
círculo), y el piso tiene un damero muy suave de baldosas de 4 x 4 studs. Reemplaza a las
texturas de piso de decoracion.py (texturas_piso), que tenían studs redondos y un damero fuerte.

Sale a arte/texturas/:
  Piso_<Zona>_Damero.png  512 px = 8 x 8 studs (las dos baldosas cruzadas), StudsPerTile 8
  Studs_Liso.png          512 px = 4 x 4 studs blanco (toma el color de la parte), StudsPerTile 4

Uso (no necesita Blender):  python forja-rapida/arte/scripts/texturas_studs.py
"""

from pathlib import Path

import numpy as np
from PIL import Image

SALIDA = Path(__file__).resolve().parents[1] / "texturas"

# zona: color de la baldosa A (medido en las referencias y corregido por la luz "Referencia",
# que aclara y satura un poco: ver GameConfig.Paleta). La baldosa B es DAMERO veces más oscura.
PISOS = {
    "Pradera": "#72B530",
    "Dunas": "#EDAE55",
    "Glaciar": "#E8F0FA",
    "Volcan": "#5A4E4E",
    "Abismo": "#4B3A78",
    "Camino": "#B9C2CC",
}
LISO = "#E6E6E6"
DAMERO = 0.94  # la referencia casi no se nota: 6 % más oscura

LADO_STUD = 0.56  # lado del cuadradito, en fracción de la celda del stud
ANCHO_BORDE = 0.075  # grosor del borde oscuro
OSCURO = 0.80  # cuánto oscurece el borde
CLARO = 1.07  # filo claro arriba e izquierda, adentro del borde (da un poco de relieve)
JUNTA = 0.96  # línea entre baldosas, casi invisible


def color(hexa):
    return np.array([int(hexa[i : i + 2], 16) / 255 for i in (1, 3, 5)], dtype=np.float32)


def baldosa(base, px=512, studs=4):
    """Baldosa de studs x studs: fondo liso y un cuadradito con borde oscuro por stud."""
    celda = px / studs
    v, u = np.mgrid[0:px, 0:px].astype(np.float32) + 0.5
    cu, cv = (u % celda) / celda - 0.5, (v % celda) / celda - 0.5
    # distancia "cuadrada" con las esquinas apenas redondeadas
    d = (np.abs(cu) ** 6 + np.abs(cv) ** 6) ** (1 / 6)
    afuera = LADO_STUD / 2
    adentro = afuera - ANCHO_BORDE
    luz = np.ones((px, px), dtype=np.float32)
    borde = (d <= afuera) & (d > adentro)
    luz[borde] = OSCURO
    filo = (d <= adentro) & (d > adentro - ANCHO_BORDE * 0.6) & ((cu < -0.1) | (cv < -0.1))
    luz[filo] = CLARO
    junta = 0.008 * px
    luz[(u < junta) | (u > px - junta) | (v < junta) | (v > px - junta)] *= JUNTA
    return np.clip(base * luz[..., None], 0, 1)


def guardar(nombre, img):
    Image.fromarray((img * 255 + 0.5).astype(np.uint8), "RGB").save(SALIDA / f"{nombre}.png")


def main():
    for zona, hexa in PISOS.items():
        a = baldosa(color(hexa), 256)
        b = baldosa(color(hexa) * DAMERO, 256)
        damero = np.concatenate([np.concatenate([a, b], 1), np.concatenate([b, a], 1)], 0)
        guardar(f"Piso_{zona}_Damero", damero)
    guardar("Studs_Liso", baldosa(color(LISO)))
    print("listo:", ", ".join(f"Piso_{z}_Damero" for z in PISOS), "y Studs_Liso")


if __name__ == "__main__":
    main()
