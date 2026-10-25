"""Ícono de zapatilla para el botón de correr (pedido A1, 25/10/2026): estilo de los íconos del
HUD (colores planos, contorno oscuro grueso, brillo arriba). Sale a arte/iconos/Zapatilla.png.
Uso: python forja-rapida/arte/scripts/icono_zapatilla.py"""

from pathlib import Path

from PIL import Image, ImageDraw

SALIDA = Path(__file__).resolve().parents[1] / "iconos" / "Zapatilla.png"
OSCURO = (27, 31, 59, 255)  # Estilo.Oscuro
ESCALA = 4  # se dibuja grande y se achica (bordes suaves)


def main():
    t = 256 * ESCALA
    im = Image.new("RGBA", (t, t), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    s = ESCALA
    borde = 14 * s
    # cuerpo de la zapatilla (de perfil, punta a la derecha)
    cuerpo = [(40, 170), (40, 70), (92, 64), (110, 104), (160, 118), (206, 134), (222, 160), (222, 182), (40, 182)]
    cuerpo = [(x * s, y * s) for x, y in cuerpo]
    d.polygon(cuerpo, fill=OSCURO)
    d.line(cuerpo + [cuerpo[0]], fill=OSCURO, width=borde * 2, joint="curve")
    interior = [(48, 168), (48, 78), (86, 74), (104, 112), (156, 126), (198, 140), (212, 162), (212, 168)]
    d.polygon([(x * s, y * s) for x, y in interior], fill=(255, 64, 80, 255))
    # suela blanca
    d.rounded_rectangle((34 * s, 168 * s, 228 * s, 206 * s), radius=14 * s, fill=OSCURO)
    d.rounded_rectangle((46 * s, 176 * s, 216 * s, 196 * s), radius=8 * s, fill=(255, 255, 255, 255))
    # rayas de los cordones
    for x in (100, 122, 144):
        d.line(((x * s, (112 + (x - 100) // 4) * s), ((x + 10) * s, (96 + (x - 100) // 4) * s)), fill=(255, 255, 255, 255), width=8 * s)
    # brillo
    d.ellipse((58 * s, 86 * s, 76 * s, 126 * s), fill=(255, 170, 178, 255))
    # rayitas de velocidad
    for y, largo in ((96, 26), (128, 34), (156, 22)):
        d.rounded_rectangle(((10) * s, (y - 5) * s, (10 + largo) * s, (y + 5) * s), radius=5 * s, fill=(255, 255, 255, 255), outline=OSCURO, width=4 * s)
    im.resize((256, 256), Image.LANCZOS).save(SALIDA)
    print("listo:", SALIDA)


if __name__ == "__main__":
    main()
