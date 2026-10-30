"""Kit de interfaz de Forja Rápida a partir de las piezas de ForgeGUI.

Toma los botones originales de ForgeGUI (arte/gui/original), les saca los restos de fondo (el
borde violeta o verde que deja el recorte), los recorta al borde oscuro y los achica a 160 px de
alto. De esos mismos botones salen los colores que faltan (violeta, rosa, naranja, cian, gris),
el blanco para teñir desde el código y el oscuro de las ventanas y barras. Escribe:

  arte/gui/listas/<Pieza>.png     lo que se sube a Roblox
  arte/gui/listas/medidas.json    ancho, alto y corte 9-slice de cada una (va a GameConfig.Gui)
  arte/gui/kit.png                hoja para mirar todo junto

Uso (desde la raíz del repositorio):  python3 forja-rapida/arte/scripts/gui.py
Necesita Pillow, NumPy y SciPy.
"""

import colorsys
import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

RAIZ = os.path.join(os.path.dirname(__file__), "..")
ORIGINAL = os.path.join(RAIZ, "gui", "original")
LISTAS = os.path.join(RAIZ, "gui", "listas")
ALTO = 160


def limpiar(ruta):
    """Devuelve (imagen RGBA recortada, máscara del borde oscuro)."""
    a = np.array(Image.open(ruta).convert("RGBA")).astype(np.int32)
    r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    borde = (al > 128) & (np.maximum(np.maximum(r, g), b) < 90) & (b >= r - 5)
    # lo de afuera = lo que no es borde y toca el límite de la imagen
    etiquetas, _ = ndimage.label(~borde)
    afuera_ids = set(np.unique(np.concatenate([etiquetas[0], etiquetas[-1], etiquetas[:, 0], etiquetas[:, -1]])))
    afuera = np.isin(etiquetas, list(afuera_ids))
    forma = ~afuera
    ys, xs = np.where(forma)
    y0, y1, x0, x1 = ys.min() - 2, ys.max() + 3, xs.min() - 2, xs.max() + 3
    alfa = Image.fromarray((forma * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.0))
    rgba = a.astype(np.uint8).copy()
    rgba[..., 3] = np.minimum(np.array(alfa), 255)
    img = Image.fromarray(rgba).crop((x0, y0, x1, y1))
    mborde = Image.fromarray((borde * 255).astype(np.uint8)).crop((x0, y0, x1, y1))
    ancho = round(img.width * ALTO / img.height)
    return img.resize((ancho, ALTO), Image.LANCZOS), mborde.resize((ancho, ALTO), Image.LANCZOS)


def recolorear(img, borde, funcion):
    """Aplica funcion(h, s, v) -> (h, s, v) a todo lo que no es el borde oscuro."""
    a = np.array(img).astype(np.float64) / 255
    proteger = np.array(borde) > 100
    salida = a.copy()
    alto, ancho = a.shape[:2]
    for y in range(alto):
        for x in range(ancho):
            if a[y, x, 3] == 0 or proteger[y, x]:
                continue
            h, s, v = colorsys.rgb_to_hsv(*a[y, x, :3])
            salida[y, x, :3] = colorsys.hsv_to_rgb(*funcion(h, s, v))
    return Image.fromarray((np.clip(salida, 0, 1) * 255).astype(np.uint8))


def girar(dh, ds=1.0, dv=1.0, dvmas=0.0):
    return lambda h, s, v: ((h + dh) % 1, min(1, s * ds), min(1, v * dv + dvmas))


def blanco(h, s, v):
    return (h, 0, 0.8 + 0.2 * v)


def gris(h, s, v):
    return (0.6, 0.08, 0.55 + 0.4 * v)


def oscuro(h, s, v):
    return (0.65, 0.45, 0.2 + 0.28 * v)


def medidas(img, escala=None):
    w, h = img.size
    corte = [round(0.32 * h), round(0.4 * h), w - round(0.32 * h), h - round(0.4 * h)]
    m = {"Ancho": w, "Alto": h, "Corte": corte}
    if escala:
        m["Escala"] = escala
    return m


def nueve(img, corte, ancho, alto, escala):
    """Imita el 9-slice de Roblox: las esquinas quedan del tamaño de la imagen x escala."""
    x0, y0, x1, y1 = corte
    w, h = img.size
    cx = [0, x0, x1, w]
    cy = [0, y0, y1, h]
    dx = [0, round(x0 * escala), ancho - round((w - x1) * escala), ancho]
    dy = [0, round(y0 * escala), alto - round((h - y1) * escala), alto]
    salida = Image.new("RGBA", (ancho, alto), (0, 0, 0, 0))
    for i in range(3):
        for j in range(3):
            trozo = img.crop((cx[i], cy[j], cx[i + 1], cy[j + 1]))
            tw, th = dx[i + 1] - dx[i], dy[j + 1] - dy[j]
            if tw > 0 and th > 0:
                salida.alpha_composite(trozo.resize((tw, th), Image.LANCZOS), (dx[i], dy[j]))
    return salida


def tenir(img, arriba, abajo):
    """Multiplica la pieza blanca por un degradé (como UIGradient en Roblox)."""
    a = np.array(img).astype(np.float64)
    alto = a.shape[0]
    c1, c2 = np.array(arriba, dtype=np.float64), np.array(abajo, dtype=np.float64)
    for y in range(alto):
        t = y / max(1, alto - 1)
        a[y, :, :3] *= (c1 * (1 - t) + c2 * t) / 255
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def vista_previa(piezas, m):
    hoja = Image.new("RGBA", (1280, 720), (85, 184, 255, 255))
    d = ImageDraw.Draw(hoja)
    d.rectangle((0, 340, 1280, 720), fill=(110, 205, 70, 255))
    # ventana
    p = piezas["PanelOscuro"]
    hoja.alpha_composite(nueve(p, m["PanelOscuro"]["Corte"], 620, 400, 0.6), (330, 160))
    cab = tenir(piezas["BotonBlanco"], (255, 158, 216), (224, 48, 143))
    hoja.alpha_composite(nueve(cab, m["BotonBlanco"]["Corte"], 604, 90, 90 / 160), (338, 168))
    # baldosas teñidas
    for i, (c1, c2) in enumerate([((227, 232, 242), (141, 147, 156)), ((143, 211, 255), (22, 115, 224)), ((217, 168, 255), (122, 47, 224)), ((255, 228, 92), (232, 137, 12)), ((255, 158, 216), (155, 77, 255))]):
        t = tenir(piezas["BotonBlanco"], c1, c2)
        hoja.alpha_composite(nueve(t, m["BotonBlanco"]["Corte"], 100, 120, 0.42), (360 + i * 112, 290))
    # barra
    fondo = nueve(p, m["PanelOscuro"]["Corte"], 460, 44, 44 / 160)
    hoja.alpha_composite(fondo, (360, 440))
    relleno = tenir(piezas["BotonBlanco"], (255, 138, 148), (214, 40, 57))
    hoja.alpha_composite(nueve(relleno, m["BotonBlanco"]["Corte"], 280, 38, 38 / 160), (363, 443))
    # botones de colores, a la izquierda (cuadrados) y abajo (anchos)
    colores = ["BotonVerde", "BotonNaranja", "BotonRosa", "BotonVioleta", "BotonAmarillo", "BotonAzul"]
    for i, n in enumerate(colores):
        x, y = 16 + (i % 2) * 106, 150 + (i // 2) * 106
        hoja.alpha_composite(nueve(piezas[n], m[n]["Corte"], 96, 96, 96 / 160), (x, y))
    for i, n in enumerate(["BotonVerde", "BotonAmarillo", "BotonAzul", "BotonRojo", "BotonVioleta", "BotonRosa", "BotonNaranja", "BotonCian", "BotonGris"]):
        x, y = 16 + (i % 5) * 250, 560 + (i // 5) * 74
        hoja.alpha_composite(nueve(piezas[n], m[n]["Corte"], 230, 64, 64 / 160), (x, y))
    # píldoras del HUD
    for i, (c1, c2) in enumerate([((255, 228, 92), (245, 158, 0)), ((140, 255, 90), (31, 163, 58)), ((255, 122, 134), (209, 31, 58))]):
        t = tenir(piezas["BotonBlanco"], c1, c2)
        hoja.alpha_composite(nueve(t, m["BotonBlanco"]["Corte"], 230, 56, 56 / 160), (1030, 16 + i * 66))
    return hoja


def main():
    os.makedirs(LISTAS, exist_ok=True)
    base = {n: limpiar(os.path.join(ORIGINAL, n + ".png")) for n in ["BotonVerde", "BotonAmarillo", "BotonAzul", "BotonRojo"]}
    piezas = {n: img for n, (img, _) in base.items()}
    azul, bazul = base["BotonAzul"]
    rojo, brojo = base["BotonRojo"]
    amarillo, bamarillo = base["BotonAmarillo"]
    piezas["BotonVioleta"] = recolorear(azul, bazul, girar(0.17, 0.9))
    piezas["BotonCian"] = recolorear(azul, bazul, girar(-0.06, 0.85, 1.0, 0.05))
    piezas["BotonRosa"] = recolorear(rojo, brojo, girar(-0.07, 0.75, 1.0, 0.08))
    piezas["BotonNaranja"] = recolorear(amarillo, bamarillo, girar(-0.045, 1.0))
    piezas["BotonGris"] = recolorear(azul, bazul, gris)
    piezas["BotonBlanco"] = recolorear(azul, bazul, blanco)
    piezas["PanelOscuro"] = recolorear(azul, bazul, oscuro)
    todas = {}
    for n, img in piezas.items():
        img.save(os.path.join(LISTAS, n + ".png"))
        todas[n] = medidas(img)
    with open(os.path.join(LISTAS, "medidas.json"), "w", encoding="utf-8") as f:
        json.dump(todas, f, indent=1)
    hoja = vista_previa(piezas, todas)
    hoja.save(os.path.join(RAIZ, "gui", "kit.png"))
    print("listo", len(piezas), "piezas")


if __name__ == "__main__":
    main()
