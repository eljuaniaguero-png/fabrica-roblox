# Arma el icono (512 x 512) y las 3 miniaturas (1920 x 1080) de la pagina del juego, con las
# capturas de Studio (publicar/capturas) y el arte original de ForgeGUI. Sin texto agregado.
# Se corre desde la raiz del repo:  python plinko-knight/publicar/armar.py
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

AQUI = Path(__file__).parent
CAP = AQUI / "capturas"
ARTE = AQUI.parent / "arte" / "forgegui" / "originales"
ANCHO, ALTO = 1920, 1080


def abrir(nombre: str) -> Image.Image:
    """Una captura, sin el busto del avatar del jugador (se tapa con la grilla vacia de al lado):
    en la pagina del juego no va la cara de nadie."""
    img = Image.open(CAP / nombre).convert("RGBA")
    if nombre != "cofre.jpg":
        img.paste(img.crop((690, 70, 760, 168)), (552, 70))
    return img


def fondo_borroso(img: Image.Image) -> Image.Image:
    """La captura entera, estirada a 1920 x 1080, borrosa y oscura (para los costados)."""
    f = img.resize((ANCHO, ALTO), Image.LANCZOS).filter(ImageFilter.GaussianBlur(28))
    return ImageEnhance.Brightness(f).enhance(0.45)


def con_sombra(img: Image.Image, radio: int = 24, color=(0, 0, 0, 200)) -> Image.Image:
    """Agrega un halo alrededor de una imagen con transparencia (contorno que se lee en celular)."""
    margen = radio * 2
    lienzo = Image.new("RGBA", (img.width + margen * 2, img.height + margen * 2), (0, 0, 0, 0))
    alfa = img.split()[-1]
    halo = Image.new("RGBA", img.size, color)
    halo.putalpha(alfa)
    capa = Image.new("RGBA", lienzo.size, (0, 0, 0, 0))
    capa.paste(halo, (margen, margen), halo)
    capa = capa.filter(ImageFilter.GaussianBlur(radio))
    lienzo = Image.alpha_composite(lienzo, capa)
    lienzo.paste(img, (margen, margen), img)
    return lienzo


def recortar_alfa(img: Image.Image) -> Image.Image:
    return img.crop(img.getbbox())


def bola(diametro: int, color=(255, 255, 255)) -> Image.Image:
    """Bola que brilla, con estela, como la del juego."""
    lado = diametro * 4
    capa = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    c = lado // 2
    for i in range(10, 0, -1):  # estela hacia arriba a la izquierda
        r = diametro // 2 * i // 10
        x = c - (10 - i) * diametro // 7
        y = c - (10 - i) * diametro // 7
        d.ellipse((x - r, y - r, x + r, y + r), fill=color + (int(25 * i / 10),))
    halo = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    ImageDraw.Draw(halo).ellipse(
        (c - diametro, c - diametro, c + diametro, c + diametro), fill=(120, 230, 255, 160)
    )
    capa = Image.alpha_composite(halo.filter(ImageFilter.GaussianBlur(diametro // 3)), capa)
    d = ImageDraw.Draw(capa)
    r = diametro // 2
    d.ellipse((c - r, c - r, c + r, c + r), fill=color + (255,))
    return capa


def pegar_centrado(base: Image.Image, img: Image.Image, cx: int, cy: int):
    base.alpha_composite(img, (cx - img.width // 2, cy - img.height // 2))


def icono():
    captura = abrir("tablero-lleno.jpg")
    # Solo el tablero de clavijas de colores, cuadrado.
    tablero = captura.crop((478, 175, 815, 512)).resize((512, 512), Image.LANCZOS)
    tablero = ImageEnhance.Brightness(tablero).enhance(0.7)
    lienzo = tablero.copy()
    # Viñeta: bordes oscuros, así el monstruo resalta.
    vin = Image.new("L", (512, 512), 0)
    ImageDraw.Draw(vin).ellipse((-90, -90, 602, 602), fill=255)
    vin = vin.filter(ImageFilter.GaussianBlur(70))
    negro = Image.new("RGBA", (512, 512), (8, 6, 20, 255))
    lienzo = Image.composite(lienzo, negro, vin)
    jefe = recortar_alfa(Image.open(ARTE / "monstruo-jefe.png").convert("RGBA"))
    jefe.thumbnail((400, 400), Image.LANCZOS)
    jefe = con_sombra(jefe, 14, (255, 63, 208, 230))  # halo magenta del neón
    pegar_centrado(lienzo, jefe, 300, 300)
    pegar_centrado(lienzo, bola(56), 80, 80)
    lienzo.convert("RGB").save(AQUI / "icono-512.png")


def miniatura_tiro():
    captura = abrir("tiro-jefe.jpg")
    lienzo = fondo_borroso(captura)
    # Panel de golpe, tablero y jefe (sin la bandeja de abajo, que tiene letra chica).
    # La caja de la maña queda cortada en el borde: se tapa con las rayas del fondo.
    for x in range(940, 1000, 40):
        captura.paste(captura.crop((880, 140, 920, 248)), (x, 140))
    juego = captura.crop((0, 0, 1000, 618))
    juego = juego.resize((round(juego.width * ALTO / juego.height), ALTO), Image.LANCZOS)
    lienzo.alpha_composite(juego, ((ANCHO - juego.width) // 2, 0))
    lienzo.convert("RGB").save(AQUI / "miniatura-1-tiro.png")


def miniatura_jefe():
    captura = abrir("tablero-lleno.jpg")
    lienzo = fondo_borroso(captura)
    # Tinte rojo violeta de jefe.
    tinte = Image.new("RGBA", (ANCHO, ALTO), (120, 20, 90, 90))
    lienzo = Image.alpha_composite(lienzo, tinte)
    tablero = captura.crop((455, 40, 840, 625))
    tablero = tablero.resize((round(tablero.width * 1000 / tablero.height), 1000), Image.LANCZOS)
    lienzo.alpha_composite(con_sombra(tablero, 20, (63, 232, 255, 200)), (60, 0))
    jefe = recortar_alfa(Image.open(ARTE / "monstruo-jefe.png").convert("RGBA"))
    jefe.thumbnail((1050, 950), Image.LANCZOS)
    jefe = con_sombra(jefe, 30, (255, 63, 208, 220))
    pegar_centrado(lienzo, jefe, 1350, 560)
    lienzo.convert("RGB").save(AQUI / "miniatura-2-jefe.png")


def miniatura_mejoras():
    captura = abrir("cofre.jpg")
    lienzo = fondo_borroso(abrir("tablero-lleno.jpg"))
    cofre = captura.crop((55, 160, 1235, 562))  # solo las 3 cartas (atrás se transparenta la tienda)
    cofre = cofre.resize((1840, round(cofre.height * 1840 / cofre.width)), Image.LANCZOS)
    lienzo.alpha_composite(cofre, ((ANCHO - cofre.width) // 2, (ALTO - cofre.height) // 2))
    lienzo.convert("RGB").save(AQUI / "miniatura-3-mejoras.png")


if __name__ == "__main__":
    icono()
    miniatura_tiro()
    miniatura_jefe()
    miniatura_mejoras()
    print("Listo:", sorted(p.name for p in AQUI.glob("*.png")))
