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

Reglas (GUIA, sección 5): studs como textura (texturas/Studs.png), un color plano por malla,
escala real (1 stud = 0,28 m), pivote en el centro de la base, frente hacia -Y de Blender (-Z de
Roblox).

No había arte/estilo-bloques.md ni arte/referencias/lobby-*.png: la forma sale del pedido y los
colores siguen a los de decoracion.py; el render se compara con estilo-1.png (captura del juego).

Uso: <python de Blender> forja-rapida/arte/scripts/lobby.py
  (sin nada: render de frente y de costado y triángulos; --exportar: además arma
   arte/fbx/Lobby.fbx)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001
import modelos as M  # noqa: E402
import decoracion as D  # noqa: E402

COLORES = {
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
MAX_PUESTO = 4000

# medidas en studs (x de -5 a 5, y de -4 a 4; el frente es -y)
POSTE = 1.5
POSTE_ALTO = 9
TECHO_Z = 9
TECHO_PASOS = 5  # escalones de 1 stud a cada lado del caballete


def poste(m, x, y):
    """Poste de bloques de ladrillo apilados (1,5 studs), cada uno un poquito más angosto o más
    ancho que el de abajo para que se vean las hiladas."""
    h = POSTE / 2
    z = 0.0
    i = 0
    while z < POSTE_ALTO - 1e-6:
        r = h if i % 2 == 0 else h - 0.08
        m.caja((x - r, x + r), (y - r, y + r), (z, min(z + 1.5, POSTE_ALTO)), caras="xXyYzZ")
        z += 1.5
        i += 1


def mostrador(m, tapa):
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


def techo(t, borde):
    """Techo a dos aguas de escalones de bloques (caballete a lo largo de x) y alero oscuro que
    sobresale abajo."""
    borde.caja((-6.25, 6.25), (-5.25, 5.25), (TECHO_Z, TECHO_Z + 0.6))
    for i in range(TECHO_PASOS):
        r = 5 - i
        t.caja((-6, 6), (-r, r), (TECHO_Z + 0.6 + i, TECHO_Z + 1.6 + i))


def cartel(c, cad):
    """Tabla colgada de 2 cadenitas bajo el alero de adelante (la cara de adelante va lisa: ahí
    el juego pone el texto)."""
    y0, y1 = -4.9, -4.5
    c.caja((-3, 3), (y0, y1), (6.4, 8.0))
    for x in (-2.4, 2.4):
        z = 8.0
        i = 0
        while z < TECHO_Z - 1e-6:
            r = 0.15 if i % 2 == 0 else 0.08
            cad.caja((x - r, x + r), (-4.7 - r, -4.7 + r), (z, min(z + 0.25, TECHO_Z)), caras="xXyYzZ")
            z += 0.25
            i += 1


def vendedor(madera):
    """Lugar del vendedor atrás del mostrador: tarima baja y un banquito."""
    madera.caja((-3.5, 3.5), (-1.5, 3), (0, 0.4), caras="xXyYZ")
    madera.caja((-0.75, 0.75), (1, 2.5), (0.4, 2))


def balanza(b):
    """Balanza dorada de bloques encima del mostrador: pie, columna, brazo y dos platitos
    colgados."""
    z0 = 3.5
    x, y = 1.8, -2.75
    b.caja((x - 0.6, x + 0.6), (y - 0.5, y + 0.5), (z0, z0 + 0.3), caras="xXyYZ")
    b.caja((x - 0.2, x + 0.2), (y - 0.2, y + 0.2), (z0 + 0.3, z0 + 2.2), caras="xXyYZ")
    b.caja((x - 1.6, x + 1.6), (y - 0.15, y + 0.15), (z0 + 2.2, z0 + 2.5))
    b.caja((x - 0.25, x + 0.25), (y - 0.25, y + 0.25), (z0 + 2.5, z0 + 2.8), caras="xXyYZ")
    for dx in (-1.4, 1.4):
        b.caja((x + dx - 0.05, x + dx + 0.05), (y - 0.05, y + 0.05), (z0 + 1.1, z0 + 2.2), caras="xXyY")
        b.caja((x + dx - 0.5, x + dx + 0.5), (y - 0.45, y + 0.45), (z0 + 0.9, z0 + 1.1))


def alfombra(a, borde):
    """Alfombra roja de bloques de 2 x 2 studs adelante del puesto, con un marco que brilla."""
    for i in range(3):
        for j in range(2):
            x, y = -3 + i * 2, -7 + j * 1.5
            a.caja((x, x + 2), (y, y + 1.5), (0, 0.2), caras="xXyYZ")
    borde.caja((-3.4, 3.4), (-7.4, -7), (0, 0.25), caras="xXyYZ")
    borde.caja((-3.4, 3.4), (-4, -3.6), (0, 0.25), caras="xXyYZ")
    borde.caja((-3.4, -3), (-7, -4), (0, 0.25), caras="xXyYZ")
    borde.caja((3, 3.4), (-7, -4), (0, 0.25), caras="xXyYZ")


def puesto_vender(mats):
    """Puesto_Vender: devuelve (objetos, triángulos por malla). Pivote en el centro de la base."""
    lad, mad, tec, tb, car, cad, bal, alf, ab = (D.Malla() for _ in range(9))
    for x in (-4.25, 4.25):
        for y in (-3.25, 3.25):
            poste(lad, x, y)
    mostrador(lad, mad)
    techo(tec, tb)
    cartel(car, cad)
    vendedor(mad)
    balanza(bal)
    alfombra(alf, ab)
    piezas = [
        ("Ladrillo", lad, mats["ladrillo"]),
        ("Madera", mad, mats["madera"]),
        ("Techo", tec, mats["techo"]),
        ("TechoBorde", tb, mats["techo_borde"]),
        ("Cartel", car, mats["cartel"]),
        ("Cadenas", cad, mats["cadenas"]),
        ("Balanza", bal, mats["balanza"]),
        ("Alfombra", alf, mats["alfombra"]),
        ("AlfombraBorde", ab, mats["alfombra_borde"]),
    ]
    objs, conteo = D.mallas(piezas, MAX_PUESTO, "Puesto_Vender")
    total = sum(conteo.values())
    if total > MAX_PUESTO:
        raise RuntimeError(f"Puesto_Vender: {total} triángulos (máximo {MAX_PUESTO})")
    return objs, conteo


def mats_puesto(studs=None):
    """Con studs, para el render (el borde de la alfombra brilla); sin, para exportar."""
    mats = {}
    for clave, color in COLORES.items():
        nombre = "Puesto_" + clave.title().replace("_", "")
        if clave == "alfombra_borde":
            mats[clave] = M.material(nombre, color, brillo=color, fuerza_brillo=0.8 if studs else 0)
        elif studs and clave not in ("cadenas", "balanza"):
            mats[clave] = D.material_studs(nombre, color, studs)
        else:
            mats[clave] = M.material(nombre, color)
    return mats


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


def render_puesto():
    conteo = {}
    for vista, giro in (("frente", -20), ("costado", 70)):
        M.limpiar_escena()
        escena = M.escena_render(1280, 720)
        objs, conteo = puesto_vender(mats_puesto(D.textura_studs()))
        D.camara_orto(escena, (0, -1.5 * M.STUD, 7 * M.STUD), 30 * M.STUD, 22, giro)
        M.render(f"puesto_vender_{vista}")
    comparar("Puesto_Vender")
    print("TRIANGULOS Puesto_Vender", conteo, "total", sum(conteo.values()))
    bpy.ops.wm.save_as_mainfile(filepath=str(M.ARTE / "blend" / "Lobby.blend"))


def exportar():
    """Lobby.fbx: un vacío por pieza con sus mallas (Puesto_Vender/Ladrillo...)."""
    M.limpiar_escena()
    objs, _ = puesto_vender(mats_puesto())
    raiz = bpy.data.objects.new("Puesto_Vender", None)
    bpy.context.scene.collection.objects.link(raiz)
    for o in objs:
        o.name = f"Puesto_Vender_{o.name}"
        o.parent = raiz
    D.exportar_grupo(raiz, "Lobby.fbx") if hasattr(D, "exportar_grupo") else None


if __name__ == "__main__":
    render_puesto()
    if "--exportar" in sys.argv:
        exportar()
    print("Listo")
