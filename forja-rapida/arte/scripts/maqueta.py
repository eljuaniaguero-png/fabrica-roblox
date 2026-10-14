"""Vista previa del HUD y de una ventana con las piezas reales (arte/gui/listas).

Arma, fuera de Roblox, cómo se ven las piezas puestas como en Hud.client.luau y MenuTienda.luau
(mismas medidas, mismo 9-slice y mismos colores), sobre un render de Blender. Sirve para mirar
el estilo sin abrir Studio; lo que vale es lo que se ve en el juego.

Uso: python3 forja-rapida/arte/scripts/maqueta.py <letra.ttf>   (Fredoka, la de Roblox)
Escribe arte/gui/maqueta_hud.png y arte/gui/maqueta_tienda.png.
"""

import json
import os
import sys

from PIL import Image, ImageDraw, ImageEnhance, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
from gui import nueve, tenir  # noqa: E402

RAIZ = os.path.join(os.path.dirname(__file__), "..")
LISTAS = os.path.join(RAIZ, "gui", "listas")
OSC = (27, 31, 59, 255)
M = json.load(open(os.path.join(LISTAS, "medidas.json"), encoding="utf-8"))
HOJA = json.load(open(os.path.join(LISTAS, "HojaIconos.json"), encoding="utf-8"))
ICONOS = Image.open(os.path.join(LISTAS, "HojaIconos.png")).convert("RGBA")
PIEZA = {n: Image.open(os.path.join(LISTAS, n + ".png")).convert("RGBA") for n in M}
LETRA = sys.argv[1] if len(sys.argv) > 1 else None


def hexa(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def letra(tam):
    f = ImageFont.truetype(LETRA, tam) if LETRA else ImageFont.load_default()
    try:
        f.set_variation_by_name("Bold")
    except Exception:
        pass
    return f


def texto(lienzo, xy, s, tam, color=(255, 255, 255), ancla="la", borde=None):
    d = ImageDraw.Draw(lienzo)
    d.text(xy, s, font=letra(tam), fill=color + (255,), anchor=ancla, stroke_width=borde or max(2, tam // 9), stroke_fill=OSC)


def icono(lienzo, nombre, x, y, tam):
    cx, cy = HOJA["Lugar"][nombre]
    c = HOJA["Celda"]
    lienzo.alpha_composite(ICONOS.crop((cx, cy, cx + c, cy + c)).resize((tam, tam), Image.LANCZOS), (int(x), int(y)))


def boton(lienzo, color, x, y, w, h):
    n = "Boton" + color
    lienzo.alpha_composite(nueve(PIEZA[n], M[n]["Corte"], w, h, h / 160), (int(x), int(y)))


def tenido(lienzo, colores, x, y, w, h, escala=None, pieza="BotonBlanco"):
    t = tenir(PIEZA[pieza], hexa(colores[0]), hexa(colores[1]))
    lienzo.alpha_composite(nueve(t, M[pieza]["Corte"], w, h, escala or h / 160), (int(x), int(y)))


def oscuro(lienzo, x, y, w, h, escala=0.55):
    lienzo.alpha_composite(nueve(PIEZA["PanelOscuro"], M["PanelOscuro"]["Corte"], w, h, escala), (int(x), int(y)))


def globito(lienzo, x, y, s, tam=34):
    d = ImageDraw.Draw(lienzo)
    d.ellipse((x - tam / 2, y - tam / 2, x + tam / 2, y + tam / 2), fill=(255, 59, 78, 255), outline=OSC, width=3)
    texto(lienzo, (x, y), s, int(tam * 0.62), ancla="mm", borde=2)


def barra(lienzo, x, y, w, h, parte, colores, rotulo):
    oscuro(lienzo, x, y, w, h, h / 160)
    if parte > 0:
        tenido(lienzo, colores, x + 3, y + 3, max(h - 6, int((w - 6) * parte)), h - 6)
    texto(lienzo, (x + w / 2, y + h / 2), rotulo, int(h * 0.6), ancla="mm")


def fondo():
    img = Image.open(os.path.join(RAIZ, "renders", "geodas_exoticas.jpg")).convert("RGBA")
    return img.resize((1280, 720), Image.LANCZOS)


def hud(lienzo):
    # izquierda: menús
    menus = [("Tienda", "Tienda", "Verde", "!"), ("Mochila", "Mochila", "Naranja", "34"), ("Índice", "Libro", "Rosa", None),
             ("Vitrina", "Corona", "Violeta", None), ("Ranking", "Trofeo", "Amarillo", None), ("Eventos", "Reloj", "Azul", "!")]
    y0 = int(720 * 0.45 - (3 * 96 + 24) / 2)
    for i, (t, ic, c, g) in enumerate(menus):
        x, y = 16 + (i % 2) * 108, y0 + (i // 2) * 108
        boton(lienzo, c, x, y, 96, 96)
        icono(lienzo, ic, x + 18, y + 6, 60)
        texto(lienzo, (x + 48, y + 80), t, 20, ancla="mm")
        if g:
            globito(lienzo, x + 90, y + 6, g)
    # derecha: recursos
    filas = [("Moneda", ["#FFE45C", "#F59E00"], "12,4K", 250, 60), ("Trebol", ["#8CFF5A", "#1FA33A"], "x2,06", 210, 52), ("Fuerza", ["#FF7A86", "#D11F3A"], "87", 210, 52)]
    y = 12
    for ic, cols, s, w, h in filas:
        x = 1280 - 16 - w
        tenido(lienzo, cols, x, y, w, h)
        icono(lienzo, ic, x + h * 0.3 - h * 0.62, y + h / 2 - h * 0.62, int(h * 1.25))
        texto(lienzo, (x + w / 2 + h * 0.4, y + h / 2), s, int(h * 0.6), ancla="mm")
        y += h + 10
    boton(lienzo, "Amarillo", 1280 - 16 - 268, y, 200, 58)
    icono(lienzo, "Banco", 1280 - 16 - 268 + 18, y + 10, 38)
    texto(lienzo, (1280 - 16 - 268 + 118, y + 29), "Vender todo", 22, ancla="mm")
    boton(lienzo, "Azul", 1280 - 16 - 58, y, 58, 58)
    icono(lienzo, "Engranaje", 1280 - 16 - 58 + 6, y + 6, 46)
    # abajo: próxima zona
    x = (1280 - (52 + 10 + 460 + 10 + 210)) // 2
    icono(lienzo, "Fuerza", x, 720 - 16 - 50, 52)
    barra(lienzo, x + 62, 720 - 16 - 48, 460, 44, 87 / 700, ["#FF8A94", "#D62839"], "87 / 700 de Fuerza")
    texto(lienzo, (x + 62 + 470, 720 - 16 - 26), "Glaciar de Zafiro", 24, hexa("#3D7BFF"), ancla="lm")


def ventana_tienda(lienzo):
    velo = Image.new("RGBA", lienzo.size, (14, 18, 48, 140))
    lienzo.alpha_composite(velo)
    W, H = 1100, 660
    x0, y0 = (1280 - W) // 2, int(720 * 0.52 - H / 2)
    oscuro(lienzo, x0, y0, W, H)
    tenido(lienzo, ["#8CFF5A", "#1FA33A"], x0 + 8, y0 + 8, W - 16, 96)
    # rayas de la cabecera
    rayas = Image.new("RGBA", (W - 16, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(rayas)
    for i, a in enumerate([40, 20, 40, 20]):
        bx = int((W - 16) * (0.52 + i * 0.12))
        d.polygon([(bx, 96), (bx + a, 96), (bx + a + 45, 0), (bx + 45, 0)], fill=(255, 255, 255, 50))
    mascara = nueve(PIEZA["BotonBlanco"], M["BotonBlanco"]["Corte"], W - 16, 96, 96 / 160).split()[3]
    rayas.putalpha(Image.fromarray(__import__("numpy").minimum(__import__("numpy").array(rayas.split()[3]), __import__("numpy").array(mascara))))
    lienzo.alpha_composite(rayas, (x0 + 8, y0 + 8))
    icono(lienzo, "Tienda", x0 + 30, y0 + 20, 70)
    texto(lienzo, (x0 + 110, y0 + 56), "Tienda", 58, ancla="lm", borde=6)
    boton(lienzo, "Rojo", x0 + W - 84, y0 + 24, 64, 64)
    texto(lienzo, (x0 + W - 52, y0 + 54), "X", 34, ancla="mm")
    cx, cy = x0 + 24, y0 + 120
    for i, (t, ic, c) in enumerate([("Fuerza", "Fuerza", "Rojo"), ("Amuletos", "Trebol", "Gris"), ("Picos", "Pico", "Gris")]):
        bx = cx + i * 240
        boton(lienzo, c, bx, cy, 230, 64)
        icono(lienzo, ic, bx + 22, cy + 10, 42)
        texto(lienzo, (bx + 135, cy + 32), t, 27, ancla="mm")
    ay = cy + 84
    AH = H - 140 - 84
    tenido(lienzo, ["#5A2A3A", "#2A1A2E"], cx, ay, 500, AH, 0.42)
    icono(lienzo, "Fuerza", cx + 190, ay + 18, 120)
    texto(lienzo, (cx + 250, ay + 162), "Nivel 12", 44, ancla="mm")
    texto(lienzo, (cx + 250, ay + 220), "87  >  92 Fuerza", 40, ancla="mm")
    boton(lienzo, "Verde", cx + 24, ay + 280, 220, 76)
    icono(lienzo, "Moneda", cx + 54, ay + 293, 50)
    texto(lienzo, (cx + 160, ay + 318), "1,2K", 32, ancla="mm")
    boton(lienzo, "Azul", cx + 256, ay + 280, 220, 76)
    texto(lienzo, (cx + 366, ay + 318), "Máximo x5", 28, ancla="mm")
    oscuro(lienzo, cx + 520, ay, W - 48 - 520, AH)
    rx = cx + 520 + (W - 48 - 520) // 2
    icono(lienzo, "Trofeo", rx - 140, ay + 40, 40)
    texto(lienzo, (rx + 20, ay + 60), "Próxima zona", 34, ancla="mm")
    texto(lienzo, (rx, ay + 120), "Glaciar de Zafiro", 40, hexa("#3D7BFF"), ancla="mm")
    barra(lienzo, rx - 226, ay + 160, 452, 46, 87 / 700, ["#FF8A94", "#D62839"], "87 / 700 Fuerza")
    texto(lienzo, (rx, ay + 260), "Cada nivel suma +1 de Fuerza", 24, ancla="mm")
    texto(lienzo, (rx, ay + 292), "y un 2,5 % más de todo.", 24, ancla="mm")


def main():
    a = fondo()
    hud(a)
    a.convert("RGB").save(os.path.join(RAIZ, "gui", "maqueta_hud.png"))
    b = fondo()
    hud(b)
    ventana_tienda(b)
    b.convert("RGB").save(os.path.join(RAIZ, "gui", "maqueta_tienda.png"))
    print("listo")


if __name__ == "__main__":
    main()
