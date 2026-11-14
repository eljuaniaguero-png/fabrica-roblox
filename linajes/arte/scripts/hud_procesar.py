"""Pasa las imÃ¡genes del HUD de arte/hud/fuente/ (Gemini, fondo negro) a PNG con transparencia.

El negro se vuelve transparente y el dibujo queda blanco puro, asÃ­ en Roblox se tiÃ±e con
ImageColor3. TambiÃ©n dibuja la viÃ±eta de pantalla. Correr desde la raÃ­z del repo:
    python linajes/arte/scripts/hud_procesar.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps

RAIZ = Path(__file__).resolve().parents[1] / "hud"
FUENTE = RAIZ / "fuente"
SALIDA = RAIZ / "listas"

# Tamaños final de cada tipo (Roblox achica todo a 1024 como máximo).
TAMANOS = {
    "marco-rombo": (512, 512),
    "linea-ornamento": (1024, 256),
    "rueda-ruleta": (512, 512),
}
TAMANO_ICONO = (256, 256)
UMBRAL_NEGRO = 18  # todo lo mÃ¡s oscuro que esto es fondo


def a_transparente(ruta: Path) -> Image.Image:
    gris = ImageOps.grayscale(Image.open(ruta).convert("RGB"))
    # El brillo pasa a ser opacidad: bordes suaves sin halo negro.
    alfa = gris.point(lambda v: 0 if v < UMBRAL_NEGRO else min(255, int((v - UMBRAL_NEGRO) * 1.25)))
    caja = alfa.getbbox()
    blanco = Image.new("RGBA", gris.size, (255, 255, 255, 0))
    blanco.putalpha(alfa)
    return blanco.crop(caja) if caja else blanco


def encajar(img: Image.Image, tam: tuple[int, int], margen: float = 0.06) -> Image.Image:
    lienzo = Image.new("RGBA", tam, (255, 255, 255, 0))
    ancho = int(tam[0] * (1 - margen * 2))
    alto = int(tam[1] * (1 - margen * 2))
    img = img.copy()
    img.thumbnail((ancho, alto), Image.LANCZOS)
    lienzo.paste(img, ((tam[0] - img.width) // 2, (tam[1] - img.height) // 2), img)
    return lienzo


def vineta() -> Image.Image:
    # Bordes oscuros que llevan la vista al centro, como en las capturas de referencia.
    tam = 512
    mascara = Image.new("L", (tam, tam), 0)
    ImageDraw.Draw(mascara).ellipse((30, 10, tam - 30, tam - 10), fill=255)
    mascara = mascara.filter(ImageFilter.GaussianBlur(120))
    img = Image.new("RGBA", (tam, tam), (0, 0, 0, 255))
    img.putalpha(ImageOps.invert(mascara).point(lambda v: int(v * 0.85)))
    return img


def main() -> None:
    SALIDA.mkdir(parents=True, exist_ok=True)
    for ruta in sorted(FUENTE.glob("*.png")):
        nombre = ruta.stem
        tam = TAMANOS.get(nombre, TAMANO_ICONO)
        margen = 0.02 if nombre in TAMANOS else 0.08
        encajar(a_transparente(ruta), tam, margen).save(SALIDA / f"{nombre}.png")
        print("listo", nombre)
    vineta().save(SALIDA / "vineta.png")
    print("listo vineta")


if __name__ == "__main__":
    main()
