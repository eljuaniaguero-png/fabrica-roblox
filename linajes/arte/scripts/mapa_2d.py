"""Dibuja los mapas 2D de Linajes para la bóveda (no es arte del juego).

Uso: uv run --python 3.12 --with pillow python linajes/arte/scripts/mapa_2d.py

Puerto Óxido sale de linajes/herramientas/GrayboxPuerto.luau. Lo punteado es
propuesta: la bóveda no fija esa posición. +Z es el sur, así que el norte queda arriba.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

SALIDA = Path(__file__).resolve().parents[2] / "boveda" / "08 Lugares" / "renders"
ESCALA = 2  # se dibuja al doble y se achica para suavizar los bordes
FONDO, TIERRA, AGUA = "#101319", "#272c35", "#17324a"
TEXTO, SUAVE, ACENTO = "#f2f0ea", "#aab2bf", "#f2a23a"
CARMESI, AZUL, VIOLETA = "#c2213a", "#2f6fdb", "#6b5ba8"


def fuente(tam: int, negrita: bool = False) -> ImageFont.FreeTypeFont:
    nombre = "arialbd.ttf" if negrita else "arial.ttf"
    return ImageFont.truetype(f"C:/Windows/Fonts/{nombre}", tam * ESCALA)


class Lienzo:
    def __init__(self, x0: float, z0: float, x1: float, z1: float, ancho: int, margen: int = 90):
        self.x0, self.z0, self.m = x0, z0, margen * ESCALA
        self.k = (ancho - 2 * margen) * ESCALA / (x1 - x0)
        alto = int((z1 - z0) * self.k) + 2 * self.m + 90 * ESCALA
        self.img = Image.new("RGB", (ancho * ESCALA, alto), FONDO)
        self.d = ImageDraw.Draw(self.img)

    def p(self, x: float, z: float) -> tuple[float, float]:
        return self.m + (x - self.x0) * self.k, self.m + 40 * ESCALA + (z - self.z0) * self.k

    def rect(self, x: float, z: float, ancho: float, largo: float, relleno=None, borde=None, grosor=2):
        a = self.p(x - ancho / 2, z - largo / 2)
        b = self.p(x + ancho / 2, z + largo / 2)
        self.d.rectangle([a, b], fill=relleno, outline=borde, width=grosor * ESCALA)

    def linea(self, puntos, color, grosor=3, punteada=False):
        pts = [self.p(*q) for q in puntos]
        if not punteada:
            self.d.line(pts, fill=color, width=grosor * ESCALA, joint="curve")
            return
        paso, largo = 26 * ESCALA, 15 * ESCALA
        for a, b in zip(pts, pts[1:]):
            dist = ((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2) ** 0.5
            for t in range(0, int(dist), paso):
                f0, f1 = t / dist, min(t + largo, dist) / dist
                self.d.line(
                    [(a[0] + (b[0] - a[0]) * f0, a[1] + (b[1] - a[1]) * f0),
                     (a[0] + (b[0] - a[0]) * f1, a[1] + (b[1] - a[1]) * f1)],
                    fill=color, width=grosor * ESCALA,
                )

    def circulo(self, x, z, radio_px, relleno=None, borde=None, grosor=2):
        cx, cy = self.p(x, z)
        r = radio_px * ESCALA
        self.d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=relleno, outline=borde, width=grosor * ESCALA)

    def texto(self, x, z, cadena, tam=18, color=TEXTO, negrita=False):
        self.d.multiline_text(
            self.p(x, z), cadena, font=fuente(tam, negrita), fill=color, anchor="mm", align="center",
            stroke_width=3 * ESCALA, stroke_fill=FONDO, spacing=3 * ESCALA,
        )

    def titulo(self, cadena, bajada):
        self.d.text((self.m, 26 * ESCALA), cadena, font=fuente(32, True), fill=TEXTO)
        self.d.text((self.m, 66 * ESCALA), bajada, font=fuente(17), fill=SUAVE)

    def leyenda(self, items):
        x = self.m
        y = self.img.height - 44 * ESCALA
        for color, nombre, punteada in items:
            if punteada:
                for i in range(3):
                    self.d.line([(x + i * 13 * ESCALA, y), (x + (i * 13 + 8) * ESCALA, y)], fill=color, width=4 * ESCALA)
            else:
                self.d.line([(x, y), (x + 34 * ESCALA, y)], fill=color, width=5 * ESCALA)
            x += 44 * ESCALA
            self.d.text((x, y), nombre, font=fuente(16), fill=SUAVE, anchor="lm")
            x += self.d.textlength(nombre, font=fuente(16)) + 34 * ESCALA

    def guardar(self, nombre):
        final = self.img.resize((self.img.width // ESCALA, self.img.height // ESCALA), Image.LANCZOS)
        final.save(SALIDA / nombre)


def barrios(c: Lienzo, lista, color):
    for nombre, x, z, ancho, largo in lista:
        c.rect(x, z, ancho, largo, relleno="#333945", borde=color, grosor=2)
        c.texto(x, z, nombre, 15)


def mapa_mundo():
    c = Lienzo(-2000, -2000, 2000, 2000, 1500)
    c.titulo("Linajes del Eclipse: mapa del mundo", "4.000 x 4.000 studs. Norte arriba. Solo Puerto Óxido está en la Beta.")
    c.rect(0, 0, 4000, 4000, relleno=TIERRA)
    bahia = [(-600, 900), (600, 900), (1150, 500), (1200, -200), (560, -500), (0, -900), (-560, -500), (-1100, -200), (-1050, 500)]
    c.d.polygon([c.p(*q) for q in bahia], fill=AGUA)
    for v in range(-1500, 2000, 500):
        c.linea([(v, -2000), (v, 2000)], "#3a404b", 1)
        c.linea([(-2000, v), (2000, v)], "#3a404b", 1)

    barrios(c, [("Los Altos", -1200, -1550, 1200, 500), ("Ópalo", -1600, -1100, 400, 400),
                ("Centro Viejo", -1200, -1100, 400, 400), ("La Gárgola", -800, -1100, 400, 400),
                ("Subte Muerto", -1200, -750, 1200, 300)], VIOLETA)
    barrios(c, [("Barrio Prensa", 900, -1550, 600, 500), ("Distrito Médico", 1500, -1550, 600, 500),
                ("Centro Corona", 1200, -1100, 1200, 400), ("Costanera", 900, -750, 600, 300),
                ("Terrenos\nGanados", 1500, -750, 600, 300)], AZUL)
    barrios(c, [("Muelles", -300, 1025, 600, 250), ("Aduana", 300, 1025, 600, 250),
                ("Galpones", -350, 1525, 500, 750), ("Mercado\nde Pescado", 100, 1525, 400, 750),
                ("La Feria", 450, 1525, 300, 750)], CARMESI)
    c.texto(-1200, -1890, "CIUDAD VÓRTICE (posición propuesta)", 21, negrita=True)
    c.texto(1200, -1890, "DISTRITO CORONA (posición propuesta)", 21, negrita=True)
    c.texto(0, 1950, "PUERTO ÓXIDO", 21, negrita=True)

    radio = 300 * c.k / ESCALA
    c.circulo(-1500, 650, radio, relleno="#2b1c33", borde=VIOLETA, grosor=3)
    c.texto(-1500, 650, "CRÁTER DEL ECLIPSE\nPvP libre\n(posición propuesta)", 16)
    c.rect(0, 0, 300, 300, relleno="#4b4f58", borde=TEXTO)
    c.texto(0, 0, "PENAL\nISLAROCA", 16, negrita=True)
    c.texto(0, -360, "BAHÍA", 26, "#7fb3d5", True)
    c.circulo(0, 600, 12, borde="#38d6d6", grosor=4)
    c.texto(280, 600, "Portal a la Ciudad Hundida", 15, "#7fe5e5")

    c.linea([(0, 720), (0, 150)], "#e8e6e0", 3, True)
    c.texto(-120, 430, "Ferry", 15)
    c.linea([(600, 1040), (815, 656)], ACENTO, 7)
    c.linea([(815, 656), (1250, -600)], ACENTO, 5, True)
    c.texto(1290, 150, "Puente a Corona\n(cortado)", 15, ACENTO)
    c.linea([(-600, 1300), (-1120, 900), (-1120, -600)], ACENTO, 5, True)
    c.texto(-870, 1210, "Túnel a Vórtice\n(cortado)", 15, ACENTO)
    c.texto(1500, 1500, "UMBRA es otro mundo:\nno está en este mapa", 17, SUAVE)
    for x, z, nombre in [(-1200, -1260, "Torre del Reloj"), (1200, -1260, "Torre Corona")]:
        c.circulo(x, z, 8, relleno=ACENTO)
        c.texto(x, z + 60, nombre, 14, ACENTO)
    c.leyenda([(TEXTO, "Definido en bóveda o código", False), (ACENTO, "Propuesta o tramo por construir", True),
               (CARMESI, "Cofradía", False), (VIOLETA, "Vigilantes", False), (AZUL, "Liga", False)])
    c.guardar("mapa-mundo.png")


def mapa_puerto():
    c = Lienzo(-720, 620, 860, 1960, 1500)
    c.titulo("Puerto Óxido: mapa de la Beta", "Posiciones tomadas del graybox. Norte arriba: la bahía y el penal están hacia arriba.")
    c.rect(70, 1290, 1580, 1340, relleno=TIERRA)
    c.rect(70, 760, 1580, 280, relleno=AGUA)

    for nombre, x, z, ancho, largo, color in [("Muelles", -300, 1025, 600, 250, "#3b3530"), ("Aduana", 300, 1025, 600, 250, "#34404f"),
                                              ("Galpones", -350, 1525, 500, 750, "#413129"), ("Mercado", 100, 1525, 400, 750, "#2e4238"),
                                              ("Feria", 450, 1525, 300, 750, "#4a2c35")]:
        c.rect(x, z, ancho, largo, relleno=color, borde=CARMESI)
    for x in range(-500, 501, 100):
        c.linea([(x, 1150), (x, 1900)], "#20242c", 5)
    for z in range(1150, 1851, 100):
        c.linea([(-600, z), (600, z)], "#20242c", 5)

    for i in range(6):
        x = -550 + i * 110
        c.rect(x, 830, 36, 140, relleno="#6e3b2e")
        c.rect(x, 940, 28, 20, relleno=ACENTO)
    c.rect(0, 800, 30, 200, relleno="#6e3b2e")
    for x in range(60, 541, 60):
        for z in range(930, 1111, 45):
            c.rect(x, z, 22, 36, relleno=["#8e2a22", "#2d4a73", "#3d5a3a", "#c9962e"][(x // 60 + z // 45) % 4])

    c.texto(-300, 1000, "MUELLES\nGalpón del Albatros (lugar exacto a definir)", 17, negrita=True)
    c.texto(300, 1125, "ADUANA", 18, negrita=True)
    c.texto(-350, 1600, "GALPONES\nCallejón de Los Óxido", 18, negrita=True)
    c.texto(100, 1560, "MERCADO DE PESCADO\nClínica de Kessler", 17, negrita=True)
    c.texto(450, 1600, "LA FERIA", 18, negrita=True)
    c.texto(380, 760, "BAHÍA", 24, "#7fb3d5", True)

    for x, z, nombre, color in [(-150, 1400, "Taller de Tano", "#4ed68a"), (-150, 1800, "Galpón de Remache", "#ff4d6d"),
                                (-120, 1060, "Almacén del muelle", ACENTO), (450, 1350, "Vuelta al mundo", "#e8e6e0")]:
        c.circulo(x, z, 10, relleno=color, borde=FONDO)
        c.texto(x, z + 34, nombre, 16, color, True)
    for x, z, nombre in [(-350, 1650, "Subte Galpones"), (450, 1850, "Subte Feria"), (0, 720, "Ferry al penal")]:
        c.circulo(x, z, 11, relleno=AZUL, borde=TEXTO)
        c.texto(x + 8, z + 34, nombre, 16)

    c.linea([(600, 1040), (815, 656)], ACENTO, 9)
    c.texto(760, 960, "Puente a Corona\n(corte policial)", 16, ACENTO)
    c.circulo(600, 1040, 9, relleno=AZUL, borde=TEXTO)
    c.linea([(-600, 1300), (-700, 1300)], ACENTO, 9)
    c.circulo(-560, 1300, 9, relleno=AZUL, borde=TEXTO)
    c.texto(-610, 1250, "Túnel a Vórtice", 15, ACENTO)
    c.circulo(-300, 890, 18, borde=ACENTO, grosor=4)
    c.texto(-300, 755, "Grúa gigante\n(propuesta)", 16, ACENTO)
    c.leyenda([(ACENTO, "Grúas, puente y túnel", False), ("#6e3b2e", "Muelles", False), (AZUL, "Estación o corte", False),
               ("#20242c", "Calles cada 100 studs", False)])
    c.guardar("mapa-puerto-oxido.png")


if __name__ == "__main__":
    mapa_mundo()
    mapa_puerto()
