"""Maqueta del Menú Principal (1920x1080 PC y 844x390 Celular) + Hojas de contacto
de todos los íconos, Linajes, emblemas e identidad de Linajes del Eclipse.

Uso:
    python linajes/arte/scripts/menu_maqueta.py
"""

from __future__ import annotations

import base64
import math
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ARTE = Path(__file__).resolve().parents[1]
DOSD = ARTE / "2d"
HUD = ARTE / "hud"
LISTAS = HUD / "listas"
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

HUESO = "#EDE6D6"
GRIS = "#9FA7B5"
APAGADO = "#565E6D"
FONDO = "#080A0E"
MODAL = "rgba(13,16,23,0.88)"
NARANJA = "#F2652B"
COFRADIA = "#C2213A"
ORO = "#D9A441"


def b64(ruta: Path) -> str:
    return "data:image/png;base64," + base64.b64encode(ruta.read_bytes()).decode()


def tag_img(ruta: Path, x: float, y: float, w: float, h: float, extra: str = "") -> str:
    if not ruta.exists():
        return ""
    return f'<image href="{b64(ruta)}" x="{x}" y="{y}" width="{w}" height="{h}" {extra}/>'


def rombo(cx: float, cy: float, r: float, trazo: str, ancho: float, relleno: str = "none") -> str:
    p = f"{cx},{cy - r} {cx + r},{cy} {cx},{cy + r} {cx - r},{cy}"
    return f'<polygon points="{p}" fill="{relleno}" stroke="{trazo}" stroke-width="{ancho}"/>'


def svg_menu(w: int, h: int, movil: bool = False) -> str:
    s = h / 1080.0
    if movil:
        s = 0.56
    mx = int(84 * s) if not movil else 36
    top_y = int(170 * s) if not movil else 42

    partes: list[str] = [
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
        "<style>"
        "@import url('https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;600;700&amp;display=swap');"
        ".b{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:600;}"
        ".r{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:400;}"
        ".l{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:300;}"
        "</style>"
    ]

    # Fondo portuario atmosférico + Eclipse detrás + Viñeta oscura a la izquierda
    fondo = DOSD / "menu-fondo.png"
    vineta = LISTAS / "vineta.png"
    if fondo.exists():
        partes.append(tag_img(fondo, 0, 0, w, h, 'preserveAspectRatio="xMidYMid slice"'))
    else:
        partes.append(f'<rect width="{w}" height="{h}" fill="{FONDO}"/>')

    partes.append(
        "<defs><linearGradient id='gradIzq' x1='0' y1='0' x2='1' y2='0'>"
        "<stop offset='0%' stop-color='#080A0E' stop-opacity='0.94'/>"
        "<stop offset='42%' stop-color='#080A0E' stop-opacity='0.72'/>"
        "<stop offset='100%' stop-color='#080A0E' stop-opacity='0.12'/>"
        "</linearGradient></defs>"
        f'<rect width="{w}" height="{h}" fill="url(#gradIzq)"/>'
    )
    if vineta.exists():
        partes.append(tag_img(vineta, 0, 0, w, h, 'preserveAspectRatio="none" opacity="0.85"'))

    # Columna izquierda editorial (sin cajas)
    partes.append(
        f'<text x="{mx}" y="{top_y}" class="l" font-size="{int(13*s)}" fill="{GRIS}" '
        f'letter-spacing="{int(5*s)}">PUERTO ÓXIDO  ·  SECTOR PORTUARIO</text>'
    )
    partes.append(
        f'<text x="{mx}" y="{top_y + int(56*s)}" class="b" font-size="{int(52*s)}" fill="{HUESO}" '
        f'letter-spacing="{int(6*s)}">LINAJES DEL ECLIPSE</text>'
    )
    partes.append(tag_img(LISTAS / "linea-ornamento.png", mx - int(20 * s), top_y + int(46 * s), int(380 * s), int(76 * s)))

    items_y = top_y + int(170 * s)
    paso_y = int(78 * s) if not movil else 46

    # 1. CONTINUAR (activo)
    partes.append(rombo(mx + int(10 * s), items_y - int(7 * s), int(8 * s), HUESO, 1.5, HUESO))
    partes.append(
        f'<text x="{mx + int(32*s)}" y="{items_y}" class="b" font-size="{int(24*s)}" fill="{HUESO}" '
        f'letter-spacing="{int(4*s)}">CONTINUAR</text>'
    )
    partes.append(
        f'<text x="{mx + int(32*s)}" y="{items_y + int(22*s)}" class="l" font-size="{int(13*s)}" fill="{GRIS}" '
        f'letter-spacing="{int(2*s)}">KAI VARGA  ·  <tspan fill="{NARANJA}">PIROQUINESIS</tspan>  ·  COFRADÍA  ·  NIVEL 12</text>'
    )

    # 2. ESPACIOS < 1 / 3 >
    y2 = items_y + int(paso_y * 1.15)
    partes.append(rombo(mx + int(10 * s), y2 - int(7 * s), int(7 * s), GRIS, 1.4))
    partes.append(
        f'<text x="{mx + int(32*s)}" y="{y2}" class="r" font-size="{int(21*s)}" fill="{HUESO}" opacity="0.88" '
        f'letter-spacing="{int(4*s)}">ESPACIOS</text>'
    )
    flecha = LISTAS / "flecha-menu.png"
    fx = mx + int(215 * s)
    partes.append(tag_img(flecha, fx, y2 - int(17 * s), int(18 * s), int(18 * s), f'transform="rotate(180 {fx + 9*s} {y2 - 8*s})" opacity="0.75"'))
    partes.append(
        f'<text x="{fx + int(42*s)}" y="{y2 - int(1*s)}" text-anchor="middle" class="b" font-size="{int(16*s)}" fill="{HUESO}" letter-spacing="2">1 / 3</text>'
    )
    partes.append(tag_img(flecha, fx + int(68 * s), y2 - int(17 * s), int(18 * s), int(18 * s), 'opacity="0.75"'))

    # 3..5 Opciones secundarias
    otros = [
        ("ÁRBOL Y PODERES", LISTAS / "icono-arbol.png"),
        ("AJUSTES", LISTAS / "icono-ajustes.png"),
        ("CRÉDITOS", None),
    ]
    for idx, (label, ico_path) in enumerate(otros, start=2):
        yi = items_y + int(paso_y * (0.15 + idx))
        partes.append(rombo(mx + int(10 * s), yi - int(7 * s), int(6.5 * s), GRIS, 1.2))
        partes.append(
            f'<text x="{mx + int(32*s)}" y="{yi}" class="r" font-size="{int(20*s)}" fill="{GRIS}" '
            f'letter-spacing="{int(4*s)}">{label}</text>'
        )
        if ico_path and ico_path.exists():
            partes.append(tag_img(ico_path, mx + int(285 * s), yi - int(18 * s), int(20 * s), int(20 * s), 'opacity="0.55"'))

    # Panel derecho editorial discreto: resumen personaje, emblema bando e íconos monedas
    pw = int(380 * s) if not movil else 270
    ph = int(280 * s) if not movil else 190
    px = w - mx - pw
    py = h - (int(84 * s) if not movil else 28) - ph
    partes.append(f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="{MODAL}" stroke="{HUESO}" stroke-opacity="0.18" stroke-width="1"/>')
    partes.append(f'<rect x="{px}" y="{py}" width="3" height="{ph}" fill="{COFRADIA}"/>')

    emblema = DOSD / "emblema-cofradia.png"
    lin_ico = LISTAS / "linaje-piroquinesis.png"
    partes.append(tag_img(emblema, px + int(22 * s), py + int(22 * s), int(58 * s), int(58 * s)))
    partes.append(
        f'<text x="{px + int(94*s)}" y="{py + int(44*s)}" class="b" font-size="{int(18*s)}" fill="{HUESO}" letter-spacing="3">COFRADÍA CARMESÍ</text>'
    )
    partes.append(
        f'<text x="{px + int(94*s)}" y="{py + int(66*s)}" class="l" font-size="{int(12*s)}" fill="{GRIS}" letter-spacing="2">CLASE B  ·  REPUTACIÓN 420</text>'
    )
    partes.append(f'<line x1="{px + int(22*s)}" y1="{py + int(96*s)}" x2="{px + pw - int(22*s)}" y2="{py + int(96*s)}" stroke="{HUESO}" stroke-opacity="0.15" stroke-width="1"/>')
    partes.append(tag_img(lin_ico, px + int(24 * s), py + int(112 * s), int(46 * s), int(46 * s)))
    partes.append(
        f'<text x="{px + int(82*s)}" y="{py + int(132*s)}" class="b" font-size="{int(16*s)}" fill="{NARANJA}" letter-spacing="3">PIROQUINESIS</text>'
    )
    partes.append(
        f'<text x="{px + int(82*s)}" y="{py + int(152*s)}" class="l" font-size="{int(12*s)}" fill="{GRIS}" letter-spacing="1">3 / 3 HABILIDADES  ·  GANCHO MK II</text>'
    )

    # Fila inferior de monedas
    my = py + int(198 * s)
    monedas = [
        (LISTAS / "moneda-chatarra.png", "340"),
        (LISTAS / "moneda-chip.png", "18"),
        (LISTAS / "moneda-ficha-eclipse.png", "4"),
    ]
    step_mx = (pw - int(44 * s)) // 3
    for i, (mpath, val) in enumerate(monedas):
        cx = px + int(26 * s) + i * step_mx
        partes.append(tag_img(mpath, cx, my, int(24 * s), int(24 * s), 'opacity="0.88"'))
        partes.append(f'<text x="{cx + int(32*s)}" y="{my + int(18*s)}" class="b" font-size="{int(15*s)}" fill="{HUESO}" letter-spacing="1">{val}</text>')

    partes.append("</svg>")
    return "\n".join(partes)


def capturar_svg(svg_text: str, svg_out: Path, png_out: Path, w: int, h: int) -> None:
    svg_out.write_text(svg_text, encoding="utf-8")
    subprocess.run(
        [
            EDGE,
            "--headless=new",
            "--disable-gpu",
            "--hide-scrollbars",
            f"--window-size={w},{h}",
            f"--screenshot={png_out}",
            "--virtual-time-budget=4000",
            svg_out.as_uri(),
        ],
        check=False,
        capture_output=True,
    )


def hacer_hoja(items: list[tuple[str, Path]], destino: Path, cols: int = 6, fondo: tuple[int, int, int] = (13, 16, 23)) -> None:
    """Genera hoja de contacto con vista grande (128 px) y prueba móvil (48 px) lado a lado."""
    if not items:
        return
    cw, ch = 220, 210
    rows = math.ceil(len(items) / cols)
    pad = 24
    canvas = Image.new("RGB", (cols * cw + pad * 2, rows * ch + pad * 2), fondo)
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", 14)
    except OSError:
        font = ImageFont.load_default()

    for idx, (label, ruta) in enumerate(items):
        r, c = divmod(idx, cols)
        x0 = pad + c * cw
        y0 = pad + r * ch
        draw.rectangle((x0 + 6, y0 + 6, x0 + cw - 6, y0 + ch - 6), fill=(20, 25, 35), outline=(45, 52, 68), width=1)
        im = Image.open(ruta).convert("RGBA")

        grande = im.copy()
        grande.thumbnail((116, 116), Image.LANCZOS)
        canvas.paste(grande, (x0 + 18, y0 + 22), grande)

        chico = im.copy()
        chico.thumbnail((48, 48), Image.LANCZOS)
        draw.rectangle((x0 + 148, y0 + 54, x0 + 196, y0 + 102), fill=(8, 10, 14), outline=(70, 78, 92), width=1)
        canvas.paste(chico, (x0 + 148 + (48 - chico.width) // 2, y0 + 54 + (48 - chico.height) // 2), chico)

        draw.text((x0 + 14, y0 + ch - 34), label[:26], fill=(237, 230, 214), font=font)

    canvas.save(destino)


def main() -> None:
    DOSD.mkdir(parents=True, exist_ok=True)
    capturar_svg(svg_menu(1920, 1080, False), DOSD / "menu-maqueta.svg", DOSD / "menu-maqueta.png", 1920, 1080)
    capturar_svg(svg_menu(844, 390, True), DOSD / "menu-maqueta-movil.svg", DOSD / "menu-maqueta-movil.png", 844, 390)

    hud_items = [(p.stem, p) for p in sorted(LISTAS.glob("*.png")) if p.stem != "vineta"]
    hacer_hoja(hud_items, HUD / "hoja-iconos.png", cols=6)

    dosd_items = [
        (p.stem, p)
        for p in sorted(DOSD.glob("*.png"))
        if p.stem in {
            "emblema-liga",
            "emblema-cofradia",
            "emblema-vigilantes",
            "emblema-neutral",
            "eclipse-menu",
            "icono-juego",
            "logo",
            "miniatura-1-jefe",
            "miniatura-2-ruleta",
            "miniatura-3-calle",
        }
    ]
    hacer_hoja(dosd_items, DOSD / "hoja-2d-menu.png", cols=5)
    print("listo maquetas y hojas")


if __name__ == "__main__":
    main()
