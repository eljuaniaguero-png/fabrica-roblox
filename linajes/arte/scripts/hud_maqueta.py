"""Maqueta del HUD nuevo en SVG (se arrastra a Figma y queda editable por capas) y una vista previa PNG.

    python linajes/arte/scripts/hud_maqueta.py

Las medidas son para una pantalla de 1920x1080 y son las mismas que usa client/Hud.client.luau
(Config.Hud). Si cambiÃ¡s algo en Figma, pasÃ¡ los nÃºmeros a Config.Hud.
"""

import base64
import subprocess
from pathlib import Path

ARTE = Path(__file__).resolve().parents[1]
HUD = ARTE / "hud"
LISTAS = HUD / "listas"
FONDO = ARTE / "renders" / "arena-c7-noche-juego.png"  # captura del juego sin HUD
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

HUESO = "#EDE6D6"
VIDA = "#B8343A"
DANIO = "#E8C9A0"
LINAJE = "#F2652B"  # Piroquinesis: el Ãºnico color fuerte
XP = "#C9A55A"
W, H = 1920, 1080


def datos(ruta: Path, tipo: str) -> str:
    return f"data:{tipo};base64," + base64.b64encode(ruta.read_bytes()).decode()


def imagen(nombre: str, x: float, y: float, w: float, h: float, extra: str = "") -> str:
    ruta = LISTAS / f"{nombre}.png"
    if not ruta.exists():
        return ""
    return f'<image href="{datos(ruta, "image/png")}" x="{x}" y="{y}" width="{w}" height="{h}" {extra}/>'


def espaciado(texto: str) -> str:
    return texto


def rombo(cx: float, cy: float, r: float, trazo: str, ancho: float, relleno: str = "none") -> str:
    p = f"{cx},{cy - r} {cx + r},{cy} {cx},{cy + r} {cx - r},{cy}"
    return f'<polygon points="{p}" fill="{relleno}" stroke="{trazo}" stroke-width="{ancho}"/>'


def ranura(cx: float, cy: float, tecla: str, icono: str, recarga: str | None) -> str:
    r = 46
    partes = [f'<g id="Ranura {tecla}">']
    partes.append(rombo(cx, cy, r - 6, "none", 0, "rgba(8,10,14,0.55)"))
    marco = imagen("marco-rombo", cx - r, cy - r, r * 2, r * 2)
    partes.append(marco or rombo(cx, cy, r - 4, HUESO, 1.5))
    op = "0.35" if recarga else "1"
    ico = imagen(icono, cx - 29, cy - 29, 58, 58, f'opacity="{op}"')
    partes.append(
        ico
        or f'<text x="{cx}" y="{cy + 8}" text-anchor="middle" class="t" font-size="22" fill="{LINAJE}" opacity="{op}">{tecla}</text>'
    )
    if recarga:
        partes.append(
            f'<text x="{cx}" y="{cy + 11}" text-anchor="middle" class="t" font-size="30" fill="{HUESO}">{recarga}</text>'
        )
    partes.append(
        f'<text x="{cx}" y="{cy + r + 22}" text-anchor="middle" class="t" font-size="14" fill="{HUESO}" opacity="0.7" letter-spacing="2">{tecla}</text>'
    )
    partes.append("</g>")
    return "\n".join(partes)


def svg() -> str:
    c = []
    c.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">'
        "<style>@import url('https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;600&amp;display=swap');"
        ".t{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:400}"
        ".f{font-family:Oswald,'Arial Narrow',sans-serif;font-weight:300}</style>"
    )
    c.append(f'<g id="Juego (fondo)"><image href="{datos(FONDO, "image/png")}" x="0" y="0" width="{W}" height="{H}" preserveAspectRatio="xMidYMid slice"/></g>')
    vin = imagen("vineta", 0, 0, W, H, 'preserveAspectRatio="none"')
    c.append(f'<g id="Vineta">{vin}</g>')

    # Abajo a la izquierda: nivel, Linaje, vida, energÃ­a y experiencia.
    x0, y0 = 72, 960
    c.append('<g id="Estado">')
    c.append(rombo(x0 + 30, y0 + 22, 30, HUESO, 1.5, "rgba(8,10,14,0.55)"))
    c.append(rombo(x0 + 30, y0 + 22, 24, HUESO, 0.6))
    c.append(f'<text x="{x0 + 30}" y="{y0 + 31}" text-anchor="middle" class="t" font-size="24" fill="{HUESO}">5</text>')
    bx = x0 + 78
    c.append(f'<text x="{bx}" y="{y0 + 2}" class="t" font-size="15" fill="{HUESO}" letter-spacing="4">PIROQUINESIS</text>')
    c.append(f'<text x="{bx + 380}" y="{y0 + 2}" text-anchor="end" class="f" font-size="14" fill="{HUESO}" opacity="0.75">84 / 100</text>')
    c.append(f'<rect x="{bx}" y="{y0 + 12}" width="380" height="7" fill="{HUESO}" opacity="0.12"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 12}" width="{380 * 0.92}" height="7" fill="{DANIO}" opacity="0.85"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 12}" width="{380 * 0.84}" height="7" fill="{VIDA}"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 26}" width="300" height="3" fill="{HUESO}" opacity="0.12"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 26}" width="{300 * 0.62}" height="3" fill="{LINAJE}"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 38}" width="380" height="1" fill="{HUESO}" opacity="0.15"/>')
    c.append(f'<rect x="{bx}" y="{y0 + 38}" width="{380 * 0.5}" height="1" fill="{XP}"/>')
    c.append(f'<text x="{bx}" y="{y0 + 58}" class="f" font-size="12" fill="{HUESO}" opacity="0.55" letter-spacing="3">NIVEL 5  Â·  444 / 878</text>')
    c.append("</g>")

    # Abajo al centro: las tres habilidades en rombos.
    c.append('<g id="Habilidades">')
    cx, cy, paso = W / 2, 978, 112
    orn = imagen("linea-ornamento", cx - 200, cy - 108, 400, 100)
    c.append(orn or f'<rect x="{cx - 160}" y="{cy - 62}" width="320" height="1" fill="{HUESO}" opacity="0.35"/>')
    c.append(ranura(cx - paso, cy, "Z", "icono-bola-fuego", None))
    c.append(ranura(cx, cy, "X", "icono-chorro", "4"))
    c.append(ranura(cx + paso, cy, "C", "icono-muro-fuego", None))
    c.append(f'<text x="{cx + paso * 1.75}" y="{cy + 6}" class="f" font-size="12" fill="{HUESO}" opacity="0.5" letter-spacing="2">T  CAMBIA</text>')
    c.append("</g>")

    # Arriba al centro: el rival que estÃ¡s golpeando (como la barra del jefe de la referencia).
    c.append('<g id="Rival">')
    c.append(f'<text x="{W / 2}" y="70" text-anchor="middle" class="t" font-size="16" fill="{HUESO}" letter-spacing="5">MATÃ“N DEL PUERTO</text>')
    c.append(f'<rect x="{W / 2 - 260}" y="84" width="520" height="3" fill="{HUESO}" opacity="0.15"/>')
    c.append(f'<rect x="{W / 2 - 260}" y="84" width="{520 * 0.45}" height="3" fill="{VIDA}"/>')
    c.append("</g>")

    # Arriba a la derecha: ruleta, sin caja.
    c.append('<g id="Ruleta">')
    c.append(f'<text x="{W - 72}" y="70" text-anchor="end" class="t" font-size="16" fill="{HUESO}" letter-spacing="5">RULETA</text>')
    c.append(f'<rect x="{W - 72 - 120}" y="80" width="120" height="1" fill="{HUESO}" opacity="0.4"/>')
    c.append(f'<text x="{W - 72}" y="100" text-anchor="end" class="f" font-size="13" fill="{HUESO}" opacity="0.6" letter-spacing="2">0 FICHAS</text>')
    c.append("</g>")

    # Derecha: contador de golpes.
    c.append('<g id="Contador">')
    c.append(f'<text x="{W - 96}" y="470" text-anchor="end" class="t" font-size="84" fill="{HUESO}" font-weight="600">7</text>')
    c.append(f'<text x="{W - 96}" y="500" text-anchor="end" class="t" font-size="16" fill="{LINAJE}" letter-spacing="5">GOLPES</text>')
    c.append(f'<text x="{W - 96}" y="524" text-anchor="end" class="f" font-size="14" fill="{HUESO}" opacity="0.6">184 de daÃ±o</text>')
    c.append("</g>")

    c.append(f'<g id="Ayuda"><text x="{W - 72}" y="1018" text-anchor="end" class="f" font-size="12" fill="{HUESO}" opacity="0.45" letter-spacing="2">H  CONTROLES</text></g>')
    c.append("</svg>")
    return "\n".join(c)


def main() -> None:
    HUD.mkdir(exist_ok=True)
    archivo = HUD / "hud-maqueta.svg"
    archivo.write_text(svg(), encoding="utf-8")
    print("SVG:", archivo)
    png = HUD / "hud-maqueta.png"
    subprocess.run(
        [EDGE, "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--window-size={W},{H}",
         f"--screenshot={png}", "--virtual-time-budget=4000", archivo.as_uri()],
        check=False,
        capture_output=True,
    )
    print("PNG:", png, png.exists())


if __name__ == "__main__":
    main()
