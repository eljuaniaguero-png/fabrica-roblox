"""Piezas del lobby de Forja Rápida (todo de bloques, como decoracion.py).

Piezas:
  Puesto_Vender  el Banco: puestito de feria de 10 x 8 studs (sin contar la alfombra) y 14 de
                 alto: 4 postes gruesos de ladrillo marrón, techo a dos aguas rojo en escalones
                 de bloques con un borde más oscuro que sobresale, mostrador de ladrillo al frente
                 con tapa de madera, cartel colgado de 2 cadenitas bajo el alero de adelante (sin
                 texto: lo pone el juego), lugar para el vendedor atrás del mostrador (tarima y
                 banquito) y una balanza dorada de bloques encima del mostrador. Adelante, una
                 alfombra roja de bloques (donde se para el jugador para vender) con un borde que
                 brilla apenas (en Roblox, Material Neon con Transparency 0,4). La alfombra sale
                 3 studs hacia adelante del puesto.
                 Mallas Ladrillo, Madera, Techo, TechoBorde, Cartel, Cadenas, Balanza, Alfombra y
                 AlfombraBorde.
  Tienda_Forja   la tienda (Fuerza, amuletos y picos): herrería de 14 x 10 studs y 17 de alto
                 (más la chimenea), de otro color para no confundirla con el puesto: techo azul en
                 escalones con alero azul oscuro, 4 postes de piedra gris, un horno de ladrillo
                 con fuego naranja que brilla en la boca (en Roblox, Material Neon) y chimenea al
                 costado derecho, un yunque negro al costado izquierdo, mostrador de madera al
                 frente y atrás un panel con 3 estantes cortos: en cada uno un amuleto chiquito y
                 arriba un pico colgado. Cartel colgado del alero y alfombra azul adelante (sale
                 3 studs del frente).
                 Mallas Piedra, Techo, TechoBorde, Ladrillo, Fuego, Yunque, Madera, MaderaClara,
                 Cartel, Cadenas, Alfombra y AlfombraBorde; cada pico (Pico_1..3, mallas Mango y
                 Cabeza) y cada amuleto (Amuleto_1..3) es un objeto aparte para que el juego
                 muestre solo los que se pueden comprar.

Reglas (GUIA, sección 5): studs como textura (texturas/Studs.png), un color plano por malla,
escala real (1 stud = 0,28 m), pivote en el centro de la base, frente hacia -Y de Blender (-Z de
Roblox).

No había arte/estilo-bloques.md ni arte/referencias/lobby-*.png: la forma sale del pedido y los
colores siguen a los de decoracion.py; el render se compara con estilo-1.png (captura del juego).

Uso: <python de Blender> forja-rapida/arte/scripts/lobby.py
  (sin nada: render de frente y de costado de cada pieza y triángulos; --pieza <Nombre>: solo
   esa; --exportar: solo arma arte/fbx/Lobby.fbx con las piezas aprobadas, sin renders)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001
import modelos as M  # noqa: E402
import decoracion as D  # noqa: E402

# piezas que Juani ya aprobó: son las que van a Lobby.fbx
APROBADAS = ["Puesto_Vender"]

COLORES_PUESTO = {
    "ladrillo": "#9A5B3A",  # marrón ladrillo
    "madera": "#C98A4E",  # tapa del mostrador, tarima y banquito
    "techo": "#D93A2E",  # rojo
    "techo_borde": "#9E2420",  # rojo oscuro del alero
    "cartel": "#E8C27A",  # madera clara (el juego pone el texto encima)
    "cadenas": "#8A8C99",
    "balanza": "#FFC83D",  # dorado
    "alfombra": "#C8202C",
    "alfombra_borde": "#FF6B5E",  # brilla apenas
}
COLORES_TIENDA = {
    "piedra": "#8E929C",  # postes de piedra gris
    "techo": "#2F6FD8",  # azul
    "techo_borde": "#1E4A9A",
    "ladrillo": "#A4553A",  # horno y chimenea
    "fuego": "#FF8A1F",  # brilla (Neon)
    "yunque": "#2A2A30",
    "madera": "#7A4A2A",  # mostrador, panel y estantes
    "madera_clara": "#C98A4E",  # tapa del mostrador
    "cartel": COLORES_PUESTO["cartel"],
    "cadenas": COLORES_PUESTO["cadenas"],
    "alfombra": "#2456C8",
    "alfombra_borde": "#6FB8FF",  # brilla apenas
    "mango": "#9A6A3A",
    "cabeza": "#B8BCC8",
}
# un color por amuleto (rojo, verde y violeta)
AMULETOS = ["#FF3B4E", "#3BD16F", "#A65BFF"]
# brillo de cada material en el render (en Roblox, Neon)
BRILLAN = {"alfombra_borde": 0.8, "fuego": 3.0}
SIN_STUDS = {"cadenas", "balanza", "fuego", "mango", "cabeza"}
MAX = {"Puesto_Vender": 4000, "Tienda_Forja": 6000}


# --- ayudas ----------------------------------------------------------------------------------


def poste(m, x, y, lado, alto, bloque=1.5):
    """Poste de bloques apilados (de `bloque` studs), cada uno un poquito más angosto o más ancho
    que el de abajo para que se vean las hiladas."""
    h = lado / 2
    z = 0.0
    i = 0
    while z < alto - 1e-6:
        r = h if i % 2 == 0 else h - 0.08
        m.caja((x - r, x + r), (y - r, y + r), (z, min(z + bloque, alto)), caras="xXyYzZ")
        z += bloque
        i += 1


def techo(t, borde, z0, ancho, fondo, pasos):
    """Techo a dos aguas de escalones de bloques (caballete a lo largo de x) y alero oscuro que
    sobresale abajo. `ancho` y `fondo`: medio largo en x y medio fondo en y del primer escalón."""
    borde.caja((-ancho - 0.25, ancho + 0.25), (-fondo - 0.25, fondo + 0.25), (z0, z0 + 0.6))
    paso = fondo / pasos
    for i in range(pasos):
        r = fondo - i * paso
        t.caja((-ancho, ancho), (-r, r), (z0 + 0.6 + i, z0 + 1.6 + i))


def cartel(c, cad, x0, x1, y, z0, z1, tope):
    """Tabla colgada de 2 cadenitas (la cara de adelante va lisa: ahí el juego pone el texto)."""
    c.caja((x0, x1), (y - 0.2, y + 0.2), (z0, z1))
    for x in (x0 + 0.6, x1 - 0.6):
        z = z1
        i = 0
        while z < tope - 1e-6:
            r = 0.15 if i % 2 == 0 else 0.08
            cad.caja((x - r, x + r), (y - r, y + r), (z, min(z + 0.25, tope)), caras="xXyYzZ")
            z += 0.25
            i += 1


def alfombra(a, borde, y0, y1):
    """Alfombra de bloques de 2 x 1,5 studs (de x = -3 a 3, de y0 a y1) con un marco que brilla."""
    filas = round((y1 - y0) / 1.5)
    for i in range(3):
        for j in range(filas):
            x, y = -3 + i * 2, y0 + j * 1.5
            a.caja((x, x + 2), (y, y + 1.5), (0, 0.2), caras="xXyYZ")
    borde.caja((-3.4, 3.4), (y0 - 0.4, y0), (0, 0.25), caras="xXyYZ")
    borde.caja((-3.4, 3.4), (y1, y1 + 0.4), (0, 0.25), caras="xXyYZ")
    borde.caja((-3.4, -3), (y0, y1), (0, 0.25), caras="xXyYZ")
    borde.caja((3, 3.4), (y0, y1), (0, 0.25), caras="xXyYZ")


def materiales(prefijo, colores, studs=None):
    """Con studs, para el render (lo que es Neon brilla); sin, para exportar."""
    mats = {}
    for clave, color in colores.items():
        nombre = prefijo + "_" + clave.title().replace("_", "")
        if clave in BRILLAN:
            mats[clave] = M.material(nombre, color, brillo=color, fuerza_brillo=BRILLAN[clave] if studs else 0)
        elif studs and clave not in SIN_STUDS:
            mats[clave] = D.material_studs(nombre, color, studs)
        else:
            mats[clave] = M.material(nombre, color)
    return mats


def armar(pieza, piezas):
    objs, conteo = D.mallas(piezas, MAX[pieza], pieza)
    return objs, conteo


# --- Puesto_Vender ---------------------------------------------------------------------------


def mostrador_ladrillo(m, tapa):
    """Mostrador de ladrillo al frente (entre los postes) con tapa de madera que sobresale."""
    z = 0.0
    fila = 0
    while z < 3 - 1e-6:
        # hiladas de ladrillos de 2 studs, corridas medio ladrillo
        x = -4.25 + (1 if fila % 2 else 0)
        if fila % 2:
            m.caja((-4.25, x), (-3.5, -2), (z, z + 1), caras="xXyYzZ")
        while x < 4.25 - 1e-6:
            x1 = min(x + 2, 4.25)
            m.caja((x + 0.05, x1 - 0.05), (-3.5, -2), (z, z + 1), caras="xXyYzZ")
            x = x1
        z += 1
        fila += 1
    tapa.caja((-4.6, 4.6), (-3.8, -1.7), (3, 3.5))


def balanza(b):
    """Balanza dorada de bloques encima del mostrador: pie, columna, brazo y dos platitos."""
    z0 = 3.5
    x, y = 1.8, -2.75
    b.caja((x - 0.6, x + 0.6), (y - 0.5, y + 0.5), (z0, z0 + 0.3), caras="xXyYZ")
    b.caja((x - 0.2, x + 0.2), (y - 0.2, y + 0.2), (z0 + 0.3, z0 + 2.2), caras="xXyYZ")
    b.caja((x - 1.6, x + 1.6), (y - 0.15, y + 0.15), (z0 + 2.2, z0 + 2.5))
    b.caja((x - 0.25, x + 0.25), (y - 0.25, y + 0.25), (z0 + 2.5, z0 + 2.8), caras="xXyYZ")
    for dx in (-1.4, 1.4):
        b.caja((x + dx - 0.05, x + dx + 0.05), (y - 0.05, y + 0.05), (z0 + 1.1, z0 + 2.2), caras="xXyY")
        b.caja((x + dx - 0.5, x + dx + 0.5), (y - 0.45, y + 0.45), (z0 + 0.9, z0 + 1.1))


def puesto_vender(mats):
    """Puesto_Vender: devuelve (objetos, triángulos por malla). Pivote en el centro de la base."""
    lad, mad, tec, tb, car, cad, bal, alf, ab = (D.Malla() for _ in range(9))
    for x in (-4.25, 4.25):
        for y in (-3.25, 3.25):
            poste(lad, x, y, 1.5, 9)
    mostrador_ladrillo(lad, mad)
    techo(tec, tb, 9, 6, 5, 5)
    cartel(car, cad, -3, 3, -4.7, 6.4, 8.0, 9)
    # lugar del vendedor: tarima baja y un banquito
    mad.caja((-3.5, 3.5), (-1.5, 3), (0, 0.4), caras="xXyYZ")
    mad.caja((-0.75, 0.75), (1, 2.5), (0.4, 2))
    balanza(bal)
    alfombra(alf, ab, -7, -4)
    return armar(
        "Puesto_Vender",
        [
            ("Ladrillo", lad, mats["ladrillo"]),
            ("Madera", mad, mats["madera"]),
            ("Techo", tec, mats["techo"]),
            ("TechoBorde", tb, mats["techo_borde"]),
            ("Cartel", car, mats["cartel"]),
            ("Cadenas", cad, mats["cadenas"]),
            ("Balanza", bal, mats["balanza"]),
            ("Alfombra", alf, mats["alfombra"]),
            ("AlfombraBorde", ab, mats["alfombra_borde"]),
        ],
    )


# --- Tienda_Forja ----------------------------------------------------------------------------
# x de -7 a 7, y de -5 a 5; el frente es -y


def horno(lad, fuego):
    """Horno de ladrillo al costado derecho (x de 3,5 a 6,5, y de 0,5 a 4,5) con la boca de
    fuego adelante y chimenea que sale por el techo."""
    x0, x1, y0, y1 = 3.5, 6.5, 0.5, 4.5
    z = 0.0
    fila = 0
    while z < 6 - 1e-6:
        r = 0 if fila % 2 == 0 else 0.1  # hiladas un poquito metidas
        lad.caja((x0 + r, x1 - r), (y0 + r, y1 - r), (z, z + 1), caras="xXyYzZ")
        z += 1
        fila += 1
    # boca: marco de ladrillo que sale y el fuego adentro, apenas hundido
    lad.caja((x0 + 0.3, x1 - 0.3), (y0 - 0.4, y0), (0.6, 1.0), caras="xXyzZ")
    lad.caja((x0 + 0.3, x1 - 0.3), (y0 - 0.4, y0), (3.4, 3.8), caras="xXyzZ")
    lad.caja((x0 + 0.3, x0 + 0.7), (y0 - 0.4, y0), (1.0, 3.4), caras="xXy")
    lad.caja((x1 - 0.7, x1 - 0.3), (y0 - 0.4, y0), (1.0, 3.4), caras="xXy")
    fuego.caja((x0 + 0.7, x1 - 0.7), (y0 - 0.2, y0), (1.0, 3.4), caras="y")
    # brasas que asoman en la boca
    fuego.caja((x0 + 0.9, x0 + 1.5), (y0 - 0.35, y0), (1.0, 1.4), caras="xXyZ")
    fuego.caja((x1 - 1.6, x1 - 1.0), (y0 - 0.35, y0), (1.0, 1.6), caras="xXyZ")
    # chimenea: de la tapa del horno hasta arriba del techo
    poste(lad, 5, 2.5, 1.8, 18, bloque=2)


def yunque(y):
    """Yunque negro de bloques al costado izquierdo: pie, cintura, mesa y cuerno."""
    cx, cy = -4.5, 1.5
    y.caja((cx - 1, cx + 1), (cy - 0.8, cy + 0.8), (0, 0.6), caras="xXyYZ")
    y.caja((cx - 0.5, cx + 0.5), (cy - 0.45, cy + 0.45), (0.6, 1.8), caras="xXyY")
    y.caja((cx - 1.3, cx + 1.3), (cy - 0.6, cy + 0.6), (1.8, 2.6))
    y.caja((cx + 1.3, cx + 2.1), (cy - 0.35, cy + 0.35), (2.0, 2.6), caras="xXyYzZ")
    y.caja((cx + 2.1, cx + 2.5), (cy - 0.2, cy + 0.2), (2.2, 2.6), caras="xXyYzZ")


def mostrador_madera(mad, clara):
    """Mostrador de tablas verticales al frente con tapa de madera clara."""
    x = -5.0
    i = 0
    while x < 3 - 1e-6:
        sale = 0.1 if i % 2 else 0
        mad.caja((x, x + 1), (-3.6 - sale, -2.2), (0, 3), caras="xXyYz")
        x += 1
        i += 1
    clara.caja((-5.4, 3.4), (-3.9, -1.9), (3, 3.5))


def estantes(mad):
    """Panel de madera atrás y 3 estantes cortos (uno por amuleto, con el pico arriba)."""
    mad.caja((-5, 2), (4, 4.6), (0, 9))
    for cx in ESTANTES_X:
        mad.caja((cx - 0.9, cx + 0.9), (3, 4), (3.2, 3.5))
        mad.caja((cx - 0.15, cx + 0.15), (3.7, 4), (2.6, 3.2), caras="xXyz")  # ménsula
        mad.caja((cx - 0.1, cx + 0.1), (3.5, 4), (7.8, 8.0), caras="xXyzZ")  # gancho del pico


ESTANTES_X = (-3.5, -1.5, 0.5)


def pico(mats, n, cx):
    """Pico_n colgado del gancho: mango de madera y cabeza de metal con dos puntas."""
    mango, cabeza = D.Malla(), D.Malla()
    y0, y1 = 3.45, 3.75
    mango.caja((cx - 0.15, cx + 0.15), (y0, y1), (4.4, 7.6))
    cabeza.caja((cx - 0.9, cx + 0.9), (y0 - 0.05, y1 + 0.05), (7.0, 7.5))
    cabeza.caja((cx - 1.3, cx - 0.9), (y0, y1), (6.6, 7.2), caras="xXyYzZ")
    cabeza.caja((cx + 0.9, cx + 1.3), (y0, y1), (6.6, 7.2), caras="xXyYzZ")
    return D.mallas(
        [(f"Pico_{n}_Mango", mango, mats["mango"]), (f"Pico_{n}_Cabeza", cabeza, mats["cabeza"])],
        MAX["Tienda_Forja"],
        f"Pico_{n}",
    )


def amuleto(mat, n, cx):
    """Amuleto_n arriba de su estante: gema de cubitos con un aro arriba."""
    a = D.Malla()
    y = 3.5
    z = 3.5
    a.caja((cx - 0.35, cx + 0.35), (y - 0.25, y + 0.25), (z, z + 0.15), caras="xXyYZ")
    a.caja((cx - 0.25, cx + 0.25), (y - 0.2, y + 0.2), (z + 0.15, z + 0.75))
    a.caja((cx - 0.12, cx + 0.12), (y - 0.08, y + 0.08), (z + 0.75, z + 1.05), caras="xXyYZ")
    return D.mallas([(f"Amuleto_{n}", a, mat)], MAX["Tienda_Forja"], f"Amuleto_{n}")


def tienda_forja(mats):
    """Tienda_Forja: devuelve (objetos, triángulos por malla). Pivote en el centro de la base."""
    pie, tec, tb, lad, fue, yun, mad, cla, car, cad, alf, ab = (D.Malla() for _ in range(12))
    for x in (-6.25, 6.25):
        for y in (-4.25, 4.25):
            poste(pie, x, y, 1.5, 10, bloque=2)
    techo(tec, tb, 10, 8, 6, 6)
    horno(lad, fue)
    yunque(yun)
    mostrador_madera(mad, cla)
    estantes(mad)
    cartel(car, cad, -3.5, 3.5, -5.7, 8.6, 9.7, 10)
    alfombra(alf, ab, -8, -5)
    objs, conteo = armar(
        "Tienda_Forja",
        [
            ("Piedra", pie, mats["piedra"]),
            ("Techo", tec, mats["techo"]),
            ("TechoBorde", tb, mats["techo_borde"]),
            ("Ladrillo", lad, mats["ladrillo"]),
            ("Fuego", fue, mats["fuego"]),
            ("Yunque", yun, mats["yunque"]),
            ("Madera", mad, mats["madera"]),
            ("MaderaClara", cla, mats["madera_clara"]),
            ("Cartel", car, mats["cartel"]),
            ("Cadenas", cad, mats["cadenas"]),
            ("Alfombra", alf, mats["alfombra"]),
            ("AlfombraBorde", ab, mats["alfombra_borde"]),
        ],
    )
    for n, cx in enumerate(ESTANTES_X, 1):
        for o, c in (pico(mats, n, cx), amuleto(mats[f"amuleto{n}"], n, cx)):
            objs += o
            conteo.update(c)
    total = sum(conteo.values())
    if total > MAX["Tienda_Forja"]:
        raise RuntimeError(f"Tienda_Forja: {total} triángulos (máximo {MAX['Tienda_Forja']})")
    return objs, conteo


def mats_tienda(studs=None):
    mats = materiales("Tienda", COLORES_TIENDA, studs)
    for n, color in enumerate(AMULETOS, 1):
        mats[f"amuleto{n}"] = M.material(f"Tienda_Amuleto{n}", color, brillo=color, fuerza_brillo=0.6 if studs else 0)
    return mats


# --- render y exportación --------------------------------------------------------------------

# nombre -> (armar, materiales, centro de la cámara en studs, ancho de la cámara en studs,
#   elevación de la cámara en grados)
PIEZAS = {
    "Puesto_Vender": (puesto_vender, lambda s=None: materiales("Puesto", COLORES_PUESTO, s), (0, -1.5, 7), 30, 22),
    "Tienda_Forja": (tienda_forja, mats_tienda, (0, -1.5, 9.5), 40, 12),
}


def comparar(pieza, referencia="estilo-1.png"):
    """<pieza>_vs_referencia.jpg: arriba la captura del juego, abajo frente y costado."""
    import numpy as np

    w, h = 960, 540
    archivo = pieza.lower()
    ref = D.cargar(M.ARTE / "referencias" / referencia, 2 * w + 12, h)
    frente = D.cargar(M.RENDERS / f"{archivo}_frente.jpg", w, h)
    costado = D.cargar(M.RENDERS / f"{archivo}_costado.jpg", w, h)
    abajo = np.concatenate([frente, np.ones((h, 12, 4), dtype=np.float32), costado], axis=1)
    junto = np.concatenate([abajo, np.ones((12, abajo.shape[1], 4), dtype=np.float32), ref], axis=0)
    salida = bpy.data.images.new("comparacion", junto.shape[1], junto.shape[0])
    salida.pixels.foreach_set(junto.ravel())
    salida.filepath_raw = str(M.RENDERS / f"{archivo}_vs_referencia.jpg")
    salida.file_format = "JPEG"
    salida.save()


def render(pieza):
    armar_pieza, mats_de, centro, ancho, elevacion = PIEZAS[pieza]
    conteo = {}
    for vista, giro in (("frente", -20), ("costado", 70)):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        _, conteo = armar_pieza(mats_de(D.textura_studs()))
        D.camara_orto(escena, tuple(c * M.STUD for c in centro), ancho * M.STUD, elevacion, giro)
        M.render(f"{pieza.lower()}_{vista}")
    comparar(pieza)
    print("TRIANGULOS", pieza, conteo, "total", sum(conteo.values()))
    bpy.ops.wm.save_as_mainfile(filepath=str(M.ARTE / "blend" / f"{pieza}.blend"))


def exportar():
    """Lobby.fbx: un vacío por pieza aprobada con sus mallas (Puesto_Vender_Ladrillo...)."""
    M.limpiar_escena()
    raices = []
    for pieza in APROBADAS:
        armar_pieza, mats_de = PIEZAS[pieza][:2]
        objs, _ = armar_pieza(mats_de())
        raiz = bpy.data.objects.new(pieza, None)
        bpy.context.scene.collection.objects.link(raiz)
        for o in objs:
            if not o.name.startswith(("Pico_", "Amuleto_")):
                o.name = f"{pieza}_{o.name}"
            o.parent = raiz
        raices.append((raiz, objs))
    bpy.ops.object.select_all(action="DESELECT")
    for raiz, objs in raices:
        raiz.select_set(True)
        for o in objs:
            o.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Lobby.fbx"),
        use_selection=True,
        object_types={"MESH", "EMPTY"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        bake_space_transform=True,
        add_leaf_bones=False,
    )
    print("  FBX Lobby.fbx:", ", ".join(APROBADAS))


if __name__ == "__main__":
    if "--exportar" in sys.argv:
        exportar()
    else:
        for pieza in PIEZAS:
            if "--pieza" not in sys.argv or pieza in sys.argv:
                render(pieza)
    print("Listo")
