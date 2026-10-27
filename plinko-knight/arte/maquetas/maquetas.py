"""Maquetas de la etapa 12a: cómo se verían la pelea, la tienda y el cofre con el kit de Forja.

Usa las piezas reales del kit (forja-rapida/arte/gui/listas, las mismas imágenes que están en
Config.Kit.Gui), con el mismo 9-slice y los mismos colores, más los dibujos de Plinko
(arte/forgegui/originales) y una captura del tablero. Pantalla de 1280 x 720, como Config.Kit.Diseno.
Es para mirar el estilo antes de cambiar el juego: lo que vale es lo que se ve en Studio.

Uso (desde la raíz del repo):
    python plinko-knight/arte/maquetas/maquetas.py <Fredoka.ttf>
Escribe 12a-pelea.png, 12a-tienda.png y 12a-cofre.png al lado de este archivo.
"""

import json
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

AQUI = Path(__file__).parent
PLINKO = AQUI.parent.parent
RAIZ = PLINKO.parent
LISTAS = RAIZ / "forja-rapida" / "arte" / "gui" / "listas"
ARTE = PLINKO / "arte" / "forgegui"
CAPTURA = PLINKO / "publicar" / "capturas" / "tablero-lleno.jpg"
LETRA = sys.argv[1] if len(sys.argv) > 1 else None
OSC = (27, 31, 59)
ANCHO, ALTO = 1280, 720

# Medidas de las piezas: las de Config.Kit.Gui (las de medidas.json de Forja quedaron viejas).
CONFIG = (PLINKO / "src" / "shared" / "Config.luau").read_text(encoding="utf-8")
GUI = CONFIG[CONFIG.index("Config.Kit = {") :]
CORTE = {
    n: [int(v) for v in c.split(",")]
    for n, c in re.findall(r"\t\t(\w+) = \{[^}]*?Corte = \{ ([\d, ]+) \}", GUI)
}
ESCALA = {n: float(e) for n, e in re.findall(r"\t\t(\w+) = \{[^}]*?Escala = ([\d.]+)", GUI)}
PIEZA = {p.stem: Image.open(p).convert("RGBA") for p in LISTAS.glob("*.png")}
HOJA = json.load(open(LISTAS / "HojaIconos.json", encoding="utf-8"))
COLORES = {
    "Verde": ("#8CFF5A", "#1FA33A"),
    "Amarillo": ("#FFE45C", "#F59E00"),
    "Azul": ("#6CCBFF", "#1673E0"),
    "Rojo": ("#FF7A86", "#D11F3A"),
    "Violeta": ("#C99BFF", "#6E22D6"),
    "Gris": ("#D5DAE1", "#8D939C"),
    "Noche": ("#2E3358", "#1E2240"),
}
RAREZA = {
    "comun": ("#E3E8F2", "#8D939C", "Común"),
    "rara": ("#8FD3FF", "#1673E0", "Rara"),
    "legendaria": ("#FFE45C", "#E8890C", "Legendaria"),
}


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


# Piezas ------------------------------------------------------------------------------------


def nueve(img, corte, ancho, alto, escala):
    """El 9-slice de Roblox: las esquinas quedan del tamaño de la imagen x escala."""
    x0, y0, x1, y1 = corte
    w, h = img.size
    cx, cy = [0, x0, x1, w], [0, y0, y1, h]
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
    """La pieza blanca por un degradé de arriba a abajo (como UIGradient)."""
    a = np.array(img).astype(np.float64)
    t = np.linspace(0, 1, a.shape[0])[:, None, None]
    c = np.array(rgb(arriba)) * (1 - t) + np.array(rgb(abajo)) * t
    a[:, :, :3] *= c / 255
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def pieza(lienzo, nombre, x, y, w, h, colores=None):
    img = PIEZA[nombre]
    if colores:
        img = tenir(img, *colores)
    escala = ESCALA.get(nombre, h / img.size[1])
    lienzo.alpha_composite(nueve(img, CORTE[nombre], int(w), int(h), escala), (int(x), int(y)))


def boton(lienzo, color, x, y, w, h, txt=None, icono_=None, tam=None):
    nombre = "Boton" + color
    if nombre in PIEZA:
        pieza(lienzo, nombre, x, y, w, h)
    else:
        pieza(lienzo, "BotonBlanco", x, y, w, h, COLORES[color])
    tam = tam or int(h * 0.42)
    ancho_txt = medir(txt, tam) if txt else 0
    lado = int(h * (0.66 if txt else 0.8)) if icono_ else 0
    total = ancho_txt + lado + (8 if txt and icono_ else 0)
    x0 = x + (w - total) / 2
    if icono_:
        icono(lienzo, icono_, x0, y + (h - lado) / 2, lado)
        x0 += lado + 8
    if txt:
        texto(lienzo, (x0, y + h / 2), txt, tam, ancla="lm")


def rayas(lienzo, x, y, w, h, opacidad=55):
    capa = Image.new("RGBA", (int(w), int(h)), (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    for i in range(4):
        cx = w * (0.55 + i * 0.12)
        a = w * (0.05 if i % 2 == 0 else 0.025)
        d.polygon([(cx, 0), (cx + a, 0), (cx + a - h * 0.47, h), (cx - h * 0.47, h)], fill=(255, 255, 255, opacidad))
    mascara = Image.new("L", capa.size, 0)
    ImageDraw.Draw(mascara).rounded_rectangle((6, 6, w - 6, h - 6), radius=int(h * 0.3), fill=255)
    capa.putalpha(Image.fromarray(np.minimum(np.array(capa.split()[-1]), np.array(mascara))))
    lienzo.alpha_composite(capa, (int(x), int(y)))


def panel(lienzo, x, y, w, h, borde=14):
    """Panel de Forja (borde celeste con brillo) con el centro oscuro, para el clima de la mazmorra.
    En Roblox: la pieza Panel y un Frame "Noche" con degradé adentro."""
    pieza(lienzo, "Panel", x, y, w, h)
    capa = Image.new("RGBA", (int(w), int(h)), (0, 0, 0, 0))
    a = np.zeros((int(h) - 2 * borde, int(w) - 2 * borde, 4), np.uint8)
    t = np.linspace(0, 1, a.shape[0])[:, None]
    a[:, :, 0] = (46 * (1 - t) + 30 * t).astype(np.uint8)
    a[:, :, 1] = (51 * (1 - t) + 34 * t).astype(np.uint8)
    a[:, :, 2] = (88 * (1 - t) + 64 * t).astype(np.uint8)
    a[:, :, 3] = 255
    centro = Image.fromarray(a, "RGBA")
    mascara = Image.new("L", centro.size, 0)
    ImageDraw.Draw(mascara).rounded_rectangle((0, 0, centro.width - 1, centro.height - 1), radius=18, fill=255)
    capa.paste(centro, (borde, borde), mascara)
    lienzo.alpha_composite(capa, (int(x), int(y)))


def cabecera(lienzo, x, y, w, h, colores):
    pieza(lienzo, "Cabecera", x, y, w, h, colores)
    rayas(lienzo, x, y, w, h)


# Texto e íconos ----------------------------------------------------------------------------


def letra(tam):
    f = ImageFont.truetype(LETRA, tam) if LETRA else ImageFont.load_default()
    try:
        f.set_variation_by_name("Bold")
    except Exception:
        pass
    return f


def medir(s, tam):
    return ImageDraw.Draw(Image.new("RGBA", (1, 1))).textlength(s, font=letra(tam))


def texto(lienzo, xy, s, tam, color="#FFFFFF", ancla="la", borde=None):
    d = ImageDraw.Draw(lienzo)
    d.text(xy, s, font=letra(tam), fill=rgb(color) + (255,), anchor=ancla,
           stroke_width=borde if borde is not None else max(2, tam // 9), stroke_fill=OSC)


def ajustado(lienzo, xy, s, tam, ancho, ancla="ma"):
    """Texto que se achica de a 1 si no entra (Estilo.ajustar en el juego)."""
    while medir(s, tam) > ancho and tam > 14:
        tam -= 1
    texto(lienzo, xy, s, tam, ancla=ancla, borde=max(2, tam // 7))


def parrafo(lienzo, cx, y, s, tam, ancho, color="#FFFFFF"):
    """Texto centrado que se corta en líneas dentro de `ancho`."""
    lineas, actual = [], ""
    for palabra in s.split():
        prueba = (actual + " " + palabra).strip()
        if medir(prueba, tam) > ancho and actual:
            lineas.append(actual)
            actual = palabra
        else:
            actual = prueba
    lineas.append(actual)
    for i, linea in enumerate(lineas):
        texto(lienzo, (cx, y + i * tam * 1.2), linea, tam, color, "ma", max(2, tam // 10))


def icono(lienzo, nombre, x, y, tam):
    if nombre in HOJA["Lugar"]:
        cx, cy = HOJA["Lugar"][nombre]
        c = HOJA["Celda"]
        img = PIEZA["HojaIconos"].crop((cx, cy, cx + c, cy + c))
    else:
        img = Image.open(nombre).convert("RGBA")
        img = img.crop(img.getbbox())
    img = img.copy()
    img.thumbnail((int(tam), int(tam)), Image.LANCZOS)
    lienzo.alpha_composite(img, (int(x + (tam - img.width) / 2), int(y + (tam - img.height) / 2)))


def dibujo(nombre):
    return str(ARTE / "originales" / (nombre + ".png"))


def pixel(nombre):
    return str(ARTE / "pixel" / "limpias" / (nombre + ".png"))


def halo(lienzo, cx, cy, radio, color, fuerza=150):
    capa = Image.new("RGBA", lienzo.size, (0, 0, 0, 0))
    ImageDraw.Draw(capa).ellipse((cx - radio, cy - radio, cx + radio, cy + radio), fill=rgb(color) + (fuerza,))
    lienzo.alpha_composite(capa.filter(ImageFilter.GaussianBlur(radio * 0.45)))


def rayos(lienzo, cx, cy, radio, color="#FFE45C", n=12):
    capa = Image.new("RGBA", lienzo.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    for i in range(n):
        a0 = np.radians(i * 360 / n)
        a1 = a0 + np.radians(360 / n / 2)
        d.polygon([(cx, cy), (cx + radio * np.cos(a0), cy + radio * np.sin(a0)),
                   (cx + radio * np.cos(a1), cy + radio * np.sin(a1))], fill=rgb(color) + (70,))
    lienzo.alpha_composite(capa.filter(ImageFilter.GaussianBlur(3)))


def pildora(lienzo, icono_, colores, x, y, w, h, txt):
    pieza(lienzo, "Pildora", x, y, w, h, colores)
    lado = int(h * 1.25)
    icono(lienzo, icono_, x + h * 0.3 - lado / 2, y + h / 2 - lado / 2, lado)
    texto(lienzo, (x + w / 2 + h * 0.4, y + h / 2), txt, int(h * 0.56), ancla="mm")


def barra(lienzo, x, y, w, h, parte, colores, txt):
    pieza(lienzo, "BarraFondo", x, y, w, h)
    relleno = max(h - 6, int((w - 6) * parte))
    pieza(lienzo, "Pildora", x + 3, y + 3, relleno, h - 6, colores)
    texto(lienzo, (x + w / 2, y + h / 2), txt, int(h * 0.58), ancla="mm")


def baldosa(lienzo, rareza, x, y, w, h):
    c = RAREZA[rareza]
    pieza(lienzo, "Baldosa", x, y, w, h, (c[0], c[1]))


def hueco(lienzo, x, y, lado):
    """Casillero vacío: un hueco oscuro, sin texto."""
    capa = Image.new("RGBA", lienzo.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    d.rounded_rectangle((x, y, x + lado, y + lado), radius=lado * 0.18, fill=(14, 18, 48, 170))
    for k in range(0, int(lado * 4), 14):  # borde punteado
        t = k / (lado * 4)
        lado_i, f = int(t * 4), (t * 4) % 1
        px, py = [(x + f * lado, y), (x + lado, y + f * lado), (x + lado - f * lado, y + lado), (x, y + lado - f * lado)][lado_i]
        d.ellipse((px - 2, py - 2, px + 2, py + 2), fill=(201, 214, 238, 120))
    lienzo.alpha_composite(capa)


# Fondo y pelea -------------------------------------------------------------------------------


def fondo():
    """Violeta oscuro con rayitas de monitor, como el juego."""
    a = np.zeros((ALTO, ANCHO, 4), np.uint8)
    t = np.linspace(0, 1, ALTO)[:, None]
    a[:, :, 0] = (38 * (1 - t) + 22 * t).astype(np.uint8)
    a[:, :, 1] = (18 * (1 - t) + 12 * t).astype(np.uint8)
    a[:, :, 2] = (62 * (1 - t) + 40 * t).astype(np.uint8)
    a[:, :, 3] = 255
    a[::6, :, :3] = np.minimum(a[::6, :, :3].astype(int) + 14, 255).astype(np.uint8)
    lienzo = Image.fromarray(a, "RGBA")
    halo(lienzo, 640, 360, 420, "#7A2CF5", 60)
    return lienzo


def tablero(lienzo):
    cap = Image.open(CAPTURA).convert("RGBA")
    cap.paste(cap.crop((690, 70, 760, 168)), (552, 70))  # sin el busto del avatar
    t = cap.crop((455, 40, 840, 625))
    t = t.resize((round(t.width * 520 / t.height), 520), Image.LANCZOS)
    x = (ANCHO - t.width) // 2 - 20
    lienzo.alpha_composite(t, (x, 72))
    texto(lienzo, (x + t.width / 2, 40), "COMBO ×7", 38, "#3FE8FF", "mm", 4)
    return x, t.width


def pelea():
    l = fondo()
    tx, tw = tablero(l)

    # Arriba a la izquierda: 3 píldoras.
    pildora(l, pixel("corazon"), COLORES["Rojo"], 34, 22, 170, 46, "42/50")
    pildora(l, "Moneda", COLORES["Amarillo"], 34, 80, 170, 46, "12")
    pildora(l, "Corona", COLORES["Violeta"], 34, 138, 170, 46, "JEFE 9/9")

    # Panel Fuerza × Multi.
    pieza(l, "Panel", 22, 200, 330, 230)
    for i, (nombre, valor, col) in enumerate([("FUERZA", "144", "Azul"), ("MULTI", "20", "Rojo")]):
        x = 40 + i * 160
        pieza(l, "Baldosa", x, 216, 136, 128, COLORES[col])
        texto(l, (x + 68, 238), nombre, 22, ancla="mm")
        texto(l, (x + 68, 292), valor, 52, ancla="mm", borde=5)
    texto(l, (187, 280), "×", 34, ancla="mm")
    texto(l, (187, 392), "= 2.916", 56, "#FFE45C", "mm", 5)

    # Clavijas especiales: bolitas de color con su número.
    for i, c in enumerate(["#E2323F", "#3FA9FF", "#F5A623", "#3FD06B", "#B04DFF"]):
        cx = 52 + i * 62
        ImageDraw.Draw(l).ellipse((cx - 20, 452, cx + 20, 492), fill=rgb(c) + (255,), outline=OSC, width=4)
        texto(l, (cx, 512), "4", 24, ancla="mm")

    # Arriba a la derecha: Salir y Ajustes.
    boton(l, "Rojo", 1100, 20, 70, 62, icono_=pixel("puerta"))
    boton(l, "Gris", 1186, 20, 70, 62, icono_="Engranaje")

    # Derecha: cinta de la maña, monstruo grande y su vida.
    cx = (tx + tw + 1280) / 2 + 10
    cabecera(l, cx - 175, 98, 350, 64, COLORES["Rojo"])
    texto(l, (cx, 118), "RABIA", 32, ancla="mm", borde=4)
    texto(l, (cx, 147), "Si no lo matás, te pega el doble", 17, ancla="mm")
    halo(l, cx, 330, 170, "#B04DFF", 110)
    rayos(l, cx, 330, 210, "#FFE45C", 14)
    icono(l, dibujo("monstruo-jefe"), cx - 160, 180, 320)
    texto(l, (cx, 512), "Rey de los Huesos", 30, ancla="mm", borde=4)
    barra(l, cx - 150, 536, 300, 40, 0.92, COLORES["Rojo"], "4.126 / 4.500")

    # Bandeja de abajo: bola, 2 pergaminos y 5 reliquias, sin letras.
    panel(l, 22, 598, 1236, 110, 10)
    baldosa(l, "comun", 40, 612, 82, 82)
    icono(l, dibujo("bola-hierro"), 46, 618, 70)
    pieza(l, "Baldosa", 150, 612, 82, 82, COLORES["Violeta"])
    icono(l, "Libro", 160, 622, 62)
    hueco(l, 246, 612, 82)
    reliquias = [("rara", "cadena"), ("comun", "brasa"), ("legendaria", "corona")]
    for i in range(5):
        x = 760 + i * 98
        if i < len(reliquias):
            rareza, rid = reliquias[i]
            baldosa(l, rareza, x, 612, 82, 82)
            icono(l, dibujo("reliquia-" + rid), x + 8, 620, 66)
        else:
            hueco(l, x, 612, 82)
    globo(l, 228, 616, "2")
    return l


def globo(lienzo, cx, cy, s):
    g = PIEZA["Globito"].resize((34, 34), Image.LANCZOS)
    lienzo.alpha_composite(g, (int(cx - 17), int(cy - 17)))
    texto(lienzo, (cx, cy), s, 20, ancla="mm", borde=2)


# Ventanas ----------------------------------------------------------------------------------


def con_velo(base):
    l = base.copy()
    l.alpha_composite(Image.new("RGBA", l.size, (14, 18, 48, 150)))
    return l


def ventana(l, x, y, w, h, titulo, icono_, colores):
    panel(l, x, y, w, h)
    cabecera(l, x + 8, y + 8, w - 16, 96, colores)
    icono(l, icono_, x + 28, y + 22, 66)
    texto(l, (x + 106, y + 56), titulo, 54, ancla="lm", borde=6)
    l.alpha_composite(PIEZA["Cerrar"].resize((64, 64), Image.LANCZOS), (x + w - 84, y + 24))


def carta(l, x, y, w, h, rareza, icono_, nombre, desc, pie):
    baldosa(l, rareza, x, y, w, h)
    icono(l, icono_, x + w / 2 - 60, y + 18, 120)
    ajustado(l, (x + w / 2, y + 152), nombre, 26, w - 24)
    parrafo(l, x + w / 2, y + 190, desc, 18, w - 30)
    pie(x, y, w, h)


def tienda(base):
    l = con_velo(base)
    x, y, w, h = 70, 40, 1140, 650
    ventana(l, x, y, w, h, "Tienda", "Tienda", COLORES["Verde"])
    pildora(l, "Moneda", COLORES["Amarillo"], x + 330, y + 34, 200, 46, "12")
    texto(l, (x + 545, y + 57), "+5 por ganar", 22, "#B8FF6A", "lm")
    # Pestañas.
    for i, (txt, ic, col) in enumerate([("Reliquias", "Corona", "Amarillo"), ("Clavijas", "Chispa", "Gris"), ("Pergaminos", "Libro", "Gris")]):
        boton(l, col, x + 24 + i * 214, y + 122, 200, 58, txt, ic, 24)
    # Cartas (3) a la izquierda.
    cartas = [
        ("rara", "cadena", "Cadena", "+2 Multi cada 5 clavijas que toca la bola", 7, True),
        ("comun", "brasa", "Brasa", "Al final: +2 Multi por cada roja de tu tablero", 4, True),
        ("legendaria", "corona", "Corona del Rey Caído", "Al final del tiro: ×2 Multi", 12, False),
    ]
    for i, (rareza, rid, nombre, desc, precio, alcanza) in enumerate(cartas):
        cx = x + 24 + i * 236

        def pie(px, py, pw, ph, precio=precio, alcanza=alcanza):
            if alcanza:
                boton(l, "Verde", px + 22, py + ph - 76, pw - 44, 58, str(precio), "Moneda", 28)
            else:
                boton(l, "Gris", px + 22, py + ph - 76, pw - 44, 58, str(precio), "Candado", 28)

        if rareza == "legendaria":
            pieza(l, "MarcoDestacado", cx - 10, y + 188, 240, 430)
        carta(l, cx, y + 198, 220, 410, rareza, dibujo("reliquia-" + rid), nombre, desc, pie)
    # Columna derecha: próximo monstruo, renovar, qué sale y BAJAR.
    px = x + 760
    panel(l, px, y + 122, 356, 330)
    texto(l, (px + 178, y + 150), "Próximo", 28, ancla="mm", borde=4)
    halo(l, px + 178, y + 270, 90, "#3FD06B", 90)
    icono(l, dibujo("monstruo-slime"), px + 103, y + 180, 150)
    texto(l, (px + 178, y + 352), "Slime Verde", 26, ancla="mm")
    barra(l, px + 40, y + 380, 276, 36, 1, COLORES["Rojo"], "90")
    boton(l, "Azul", px, y + 468, 190, 58, "Renovar · 2", None, 24)
    boton(l, "Gris", px + 202, y + 468, 154, 58, "¿Qué sale?", None, 20)
    boton(l, "Amarillo", px, y + 540, 356, 90, "BAJAR", None, 46)
    return l


def cofre(base):
    l = con_velo(base)
    x, y, w, h = 140, 30, 1000, 660
    ventana(l, x, y, w, h, "¡Cofre del jefe!", "Cofre", COLORES["Amarillo"])
    texto(l, (x + w / 2, y + 138), "Elegí una reliquia", 30, ancla="mm", borde=4)
    cartas = [
        ("comun", "hoja", "Hoja Afilada", "Las bolas extra suman ×2 Fuerza"),
        ("rara", "cadena", "Cadena", "+2 Multi cada 5 clavijas que toca la bola"),
        ("legendaria", "corona", "Corona del Rey Caído", "Al final del tiro: ×2 Multi"),
    ]
    for i, (rareza, rid, nombre, desc) in enumerate(cartas):
        cx, cy, cw, ch = x + 40 + i * 316, y + 172, 280, 404
        c = RAREZA[rareza]
        if rareza == "legendaria":
            rayos(l, cx + cw / 2, cy + ch / 2, 280, "#FFE45C", 16)
            pieza(l, "MarcoDestacado", cx - 12, cy - 12, cw + 24, ch + 24)
        baldosa(l, rareza, cx, cy, cw, ch)
        pieza(l, "Pildora", cx + cw / 2 - 80, cy + 18, 160, 36, (c[0], c[1]))
        texto(l, (cx + cw / 2, cy + 36), c[2], 20, ancla="mm")
        icono(l, dibujo("reliquia-" + rid), cx + cw / 2 - 66, cy + 64, 132)
        ajustado(l, (cx + cw / 2, cy + 206), nombre, 28, cw - 24)
        parrafo(l, cx + cw / 2, cy + 246, desc, 20, cw - 40)
        boton(l, "Verde", cx + 30, cy + ch - 80, cw - 60, 62, "Elegir", None, 30)
    boton(l, "Gris", x + w / 2 - 110, y + h - 72, 220, 54, "Más tarde", None, 24)
    return l


if __name__ == "__main__":
    p = pelea()
    p.convert("RGB").save(AQUI / "12a-pelea.png")
    tienda(p).convert("RGB").save(AQUI / "12a-tienda.png")
    cofre(p).convert("RGB").save(AQUI / "12a-cofre.png")
    print("Listo: 12a-pelea.png, 12a-tienda.png, 12a-cofre.png")
