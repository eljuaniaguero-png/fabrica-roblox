"""Procesa las imágenes de identidad y menú (logo, eclipse, emblemas, ícono y miniaturas)
de Linajes del Eclipse hacia linajes/arte/2d/ y genera la maqueta del Menú Principal
y hojas de inspección visual.

Uso desde la raíz del repo:
    python linajes/arte/scripts/menu_procesar.py
"""

from __future__ import annotations

import base64
import shutil
import subprocess
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ARTE = Path(__file__).resolve().parents[1]
HUD_LISTAS = ARTE / "hud" / "listas"
DOSD = ARTE / "2d"
FUENTE = DOSD / "fuente"
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

HUESO = "#EDE6D6"
FONDO = "#080A0E"
NARANJA = "#F2652B"
DORADO = "#FFB347"


def _a_b64(img: Image.Image) -> str:
    from io import BytesIO

    buf = BytesIO()
    img.save(buf, format="PNG")
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()


def encajar(img: Image.Image, tam: tuple[int, int], margen: float = 0.06, crop: bool = True) -> Image.Image:
    if crop:
        bbox = img.getbbox()
        if bbox:
            img = img.crop(bbox)
    lienzo = Image.new("RGBA", tam, (0, 0, 0, 0))
    ancho = max(1, int(tam[0] * (1 - margen * 2)))
    alto = max(1, int(tam[1] * (1 - margen * 2)))
    copia = img.copy()
    copia.thumbnail((ancho, alto), Image.LANCZOS)
    lienzo.paste(copia, ((tam[0] - copia.width) // 2, (tam[1] - copia.height) // 2), copia)
    return lienzo


def limpiar_chroma(ruta: Path, tam: tuple[int, int] = (512, 512), margen: float = 0.06) -> Image.Image:
    """Quita fondo chroma verde #00FF00 con antialiasing suave y supresión de halo verde."""
    arr = np.asarray(Image.open(ruta).convert("RGB"), dtype=np.float32)
    r, g, b = arr[..., 0], arr[..., 1], arr[..., 2]
    max_rb = np.maximum(r, b)
    exceso_verde = g - max_rb

    # Fondo verde claro/puro -> alpha 0; bordes transición -> alfa gradual; interior sin verde -> 255
    es_fondo = (exceso_verde > 18.0) & (g > 70.0)
    alfa = np.where(es_fondo, 1.0 - np.clip((exceso_verde - 18.0) / 55.0, 0.0, 1.0), 1.0)

    # Suprime contaminación verde en bordes semitransparentes o sombras
    necesita_despill = exceso_verde > 0.0
    g_limpio = np.where(necesita_despill, np.minimum(g, max_rb), g)

    out = np.stack([r, g_limpio, b, np.clip(alfa * 255.0, 0.0, 255.0)], axis=-1).astype(np.uint8)
    return encajar(Image.fromarray(out, mode="RGBA"), tam, margen=margen, crop=True)


def limpiar_eclipse(ruta: Path, tam: tuple[int, int] = (512, 512)) -> Image.Image:
    """Convierte fondo negro exterior a transparente manteniendo sólido (#080A0E) el disco interior del eclipse."""
    rgb = np.asarray(Image.open(ruta).convert("RGB"), dtype=np.float32)
    h, w, _ = rgb.shape
    luma = rgb.max(axis=2)

    # Anillo brillante del eclipse (barrera entre exterior transparente y disco interior opaco)
    anillo = luma >= 50.0
    exterior = np.zeros((h, w), dtype=bool)
    cola: deque[tuple[int, int]] = deque()

    for x in range(w):
        for y in (0, h - 1):
            if not anillo[y, x] and not exterior[y, x]:
                exterior[y, x] = True
                cola.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if not anillo[y, x] and not exterior[y, x]:
                exterior[y, x] = True
                cola.append((y, x))

    while cola:
        cy, cx = cola.popleft()
        for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
            if 0 <= ny < h and 0 <= nx < w and not exterior[ny, nx] and not anillo[ny, nx]:
                exterior[ny, nx] = True
                cola.append((ny, nx))

    # Exterior: opacidad smoothstep desde piso de compresión JPEG (16) hasta borde brillante (56),
    # restando el ruido grisáceo del fondo antes de desmultiplicar para evitar halo sucio en fondos claros.
    t = np.clip((luma - 16.0) / 40.0, 0.0, 1.0)
    alfa_ext = t * t * (3.0 - 2.0 * t)
    alfa = np.where(exterior, alfa_ext, 1.0)
    rgb_limpio = np.where(exterior[..., None], np.maximum(rgb - 12.0, 0.0), rgb)
    out_rgb = np.where(exterior[..., None] & (alfa[..., None] > 0.02), rgb_limpio / np.maximum(alfa[..., None], 0.14), rgb_limpio)
    out_rgb = np.clip(out_rgb, 0.0, 255.0)
    out = np.dstack([out_rgb, np.clip(alfa * 255.0, 0.0, 255.0)]).astype(np.uint8)
    return encajar(Image.fromarray(out, mode="RGBA"), tam, margen=0.04, crop=True)


def render_svg_transparente(svg_interior: str, w: int, h: int, salida: Path) -> Image.Image:
    """Renderiza SVG con fuente Oswald en Edge sobre fondo negro y blanco para recuperar RGBA exacto sin halos."""
    tmp_dir = DOSD / "_tmp"
    tmp_dir.mkdir(parents=True, exist_ok=True)
    fondo_negro = tmp_dir / "bg_black.png"
    fondo_blanco = tmp_dir / "bg_white.png"

    for bg, destino in (("#000000", fondo_negro), ("#FFFFFF", fondo_blanco)):
        svg_txt = (
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<rect width="100%" height="100%" fill="{bg}"/>'
            f"{svg_interior}"
            "</svg>"
        )
        svg_path = tmp_dir / f"{destino.stem}.svg"
        svg_path.write_text(svg_txt, encoding="utf-8")
        subprocess.run(
            [
                EDGE,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                f"--window-size={w},{h}",
                f"--screenshot={destino}",
                "--virtual-time-budget=4000",
                svg_path.as_uri(),
            ],
            check=False,
            capture_output=True,
        )

    b_arr = np.asarray(Image.open(fondo_negro).convert("RGB"), dtype=np.float32)
    w_arr = np.asarray(Image.open(fondo_blanco).convert("RGB"), dtype=np.float32)
    alfa = np.clip(1.0 - np.mean((w_arr - b_arr) / 255.0, axis=2), 0.0, 1.0)
    # Limpia píxeles casi vacíos
    alfa = np.where(alfa < 0.015, 0.0, alfa)
    rgb = np.where(alfa[..., None] > 1e-3, np.clip(b_arr / np.maximum(alfa[..., None], 1e-3), 0.0, 255.0), 0.0)
    img = Image.fromarray(np.dstack([rgb, alfa * 255.0]).astype(np.uint8), mode="RGBA")
    img.save(salida)
    shutil.rmtree(tmp_dir, ignore_errors=True)
    return img


def construir_logo(eclipse_img: Image.Image) -> Image.Image:
    """Compone el logo oficial LINAJES DEL ECLIPSE con Oswald SemiBold + disco Eclipse + grieta #F2652B."""
    w, h = 1600, 900
    eclipse_small = eclipse_img.resize((540, 540), Image.LANCZOS)
    eclipse_b64 = _a_b64(eclipse_small)
    orn_path = HUD_LISTAS / "linea-ornamento.png"
    orn_tag = ""
    if orn_path.exists():
        orn_b64 = _a_b64(Image.open(orn_path).convert("RGBA"))
        orn_tag = f'<image href="{orn_b64}" x="{w/2 - 300}" y="704" width="600" height="100" opacity="0.9"/>'

    svg = (
        "<style>"
        "@import url('https://fonts.googleapis.com/css2?family=Oswald:wght@300;600;700&amp;display=swap');"
        ".tit{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:700;letter-spacing:16px;}"
        ".sub{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:300;letter-spacing:9px;}"
        "</style>"
        "<defs>"
        "<linearGradient id='acero' x1='0' y1='0' x2='0' y2='1'>"
        "<stop offset='0%' stop-color='#EDE6D6'/>"
        "<stop offset='68%' stop-color='#D8D2C5'/>"
        "<stop offset='100%' stop-color='#9FA7B5'/>"
        "</linearGradient>"
        "<linearGradient id='grieta' x1='0' y1='0' x2='1' y2='0'>"
        "<stop offset='0%' stop-color='#F2652B' stop-opacity='0'/>"
        "<stop offset='18%' stop-color='#F2652B' stop-opacity='1'/>"
        "<stop offset='50%' stop-color='#FFB347' stop-opacity='1'/>"
        "<stop offset='82%' stop-color='#F2652B' stop-opacity='1'/>"
        "<stop offset='100%' stop-color='#F2652B' stop-opacity='0'/>"
        "</linearGradient>"
        "</defs>"
        f'<image href="{eclipse_b64}" x="{w/2 - eclipse_small.width/2}" y="{h/2 - eclipse_small.height/2 - 28}" '
        f'width="{eclipse_small.width}" height="{eclipse_small.height}" opacity="0.98"/>'
        f'<text x="{w/2 + 6}" y="468" text-anchor="middle" class="tit" font-size="136" fill="#080A0E" opacity="0.92">LINAJES</text>'
        f'<text x="{w/2}" y="462" text-anchor="middle" class="tit" font-size="136" fill="url(#acero)" stroke="#080A0E" stroke-width="5" paint-order="stroke">LINAJES</text>'
        f'<polygon points="240,418 610,412 710,422 930,408 1360,417 1360,421 930,413 710,427 610,417 240,421" fill="url(#grieta)"/>'
        f'<text x="{w/2}" y="544" text-anchor="middle" class="sub" font-size="38" fill="#EDE6D6" stroke="#080A0E" stroke-width="4" paint-order="stroke">DEL ECLIPSE</text>'
        f"{orn_tag}"
    )
    img = render_svg_transparente(svg, w, h, DOSD / "logo.png")
    bbox = img.getbbox()
    if bbox:
        pad = 24
        x0 = max(0, bbox[0] - pad)
        y0 = max(0, bbox[1] - pad)
        x1 = min(img.width, bbox[2] + pad)
        y1 = min(img.height, bbox[3] + pad)
        img = img.crop((x0, y0, x1, y1))
        img.save(DOSD / "logo.png")
    return img


def main() -> None:
    DOSD.mkdir(parents=True, exist_ok=True)
    FUENTE.mkdir(parents=True, exist_ok=True)

    # 1. Emblemas de bandos (chroma verde -> RGBA limpio)
    for nombre in ("emblema-liga", "emblema-cofradia", "emblema-vigilantes", "emblema-neutral"):
        src = FUENTE / f"{nombre}.png"
        if src.exists():
            limpio = limpiar_chroma(src, (512, 512), margen=0.06)
            limpio.save(DOSD / f"{nombre}.png")
            limpio.resize((256, 256), Image.LANCZOS).save(HUD_LISTAS / f"{nombre}.png")
            print("listo", nombre)

    # 2. Eclipse puro para el Menú Principal
    eclipse_src = FUENTE / "eclipse-menu.png"
    eclipse_img = None
    if eclipse_src.exists():
        eclipse_img = limpiar_eclipse(eclipse_src, (512, 512))
        eclipse_img.save(DOSD / "eclipse-menu.png")
        print("listo eclipse-menu")

    # 3. Fondo de Menú, Ícono y 3 Miniaturas
    copies = {
        "menu-fondo": (1920, 1080),
        "icono-juego": (512, 512),
        "miniatura-1-jefe": (1920, 1080),
        "miniatura-2-ruleta": (1920, 1080),
        "miniatura-3-calle": (1920, 1080),
    }
    for nombre, (tw, th) in copies.items():
        src = FUENTE / f"{nombre}.png"
        if src.exists():
            im = Image.open(src).convert("RGBA")
            im = im.resize((tw, th), Image.LANCZOS)
            im.save(DOSD / f"{nombre}.png")
            print("listo", nombre)

    # 4. Logo oficial PNG transparente con Oswald + Eclipse
    if eclipse_img is not None:
        construir_logo(eclipse_img)
        print("listo logo")


if __name__ == "__main__":
    main()
