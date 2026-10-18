"""Piezas de juego de Forja Rápida (todo de bloques, como lobby.py).

Piezas:
  Cerca_Madera    tramo de cerca de 8 studs de largo y 3 de alto: 2 postes cuadrados (1 stud)
                  con la cabeza un poco más ancha y 2 tablones entre ellos. Mallas Poste y Tablon.
  Cerca_Esquina   esquina en L: poste en la esquina (el pivote) y medio tramo (4 studs) hacia +x
                  y otro hacia +y, cada uno con su poste en la punta.
  Cerca_Puerta    12 studs: un tramo corto de cada lado y un hueco de 4 studs en el medio
                  (entre las caras de los postes de adentro).
  Linea_ZonaSegura  tira plana de 1 stud de ancho y 32 de largo, roja que brilla apenas (Neon en
                  Roblox), y adelante (+y, del lado seguro) un cartel en el piso: marco blanco
                  y un escudo azul de bloques (malla "Linea_Escudo") cuya cara de arriba es donde
                  el juego escribe "Zona segura". Mallas Linea, Linea_Marco y Linea_Escudo.
  Cartel_Colgante cartel de madera rojiza de 40 x 8 studs colgado con cadenas de una viga entre
                  2 postes de ladrillo de 22 studs, cruzando el camino (abajo quedan 11 studs
                  libres). La cara de adelante (malla "Cartel_Cara", lisa) es donde el juego pone
                  el nombre del jefe o evento y el contador. Mallas Ladrillo, Viga, Cadenas,
                  Tablas, Marco y Cartel_Cara.
  Toldo_Puesto / Toldo_Tienda  toldo a rayas de 1 stud que baja en escalones hacia adelante, con
                  flecos alternados en el borde: verde y blanco (12 studs, para Puesto_Vender) y
                  celeste y blanco (16 studs, para Tienda_Forja). Pivote en el centro de la base
                  (la parte de abajo de atrás del toldo). Mallas Color y Blanco.

Reglas (GUIA, sección 5): studs como textura, un color plano por malla, 1 stud = 0,28 m, pivote
en el centro de la base, frente hacia -Y de Blender (-Z de Roblox). Máximo 1.500 triángulos cada
cerca y 4.000 el cartel colgante.

No había arte/estilo-bloques.md: los colores siguen a lobby.py y el render se arma sobre la
Parcela_Exhibicion.

Uso: <python de Blender> forja-rapida/arte/scripts/piezas_juego.py
  (sin nada: render de todo junto en una parcela y triángulos; --exportar: arma
   arte/fbx/Piezas_Juego.fbx con las piezas aprobadas)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bpy  # noqa: E402,I001
import modelos as M  # noqa: E402
import decoracion as D  # noqa: E402
import lobby as L  # noqa: E402

# piezas que Juani ya aprobó: son las que van a Piezas_Juego.fbx
APROBADAS = []

COLORES_CERCA = {"poste": "#7A4A2A", "tablon": "#C98A4E"}
COLORES_LINEA = {"linea": "#FF3B4E", "marco": "#F2F2F2", "escudo": "#2F6FD8"}
COLORES_CARTEL = {
    "ladrillo": "#8A4A32",
    "viga": "#5A3420",
    "cadenas": "#8A8C99",
    "tablas": "#A0482E",  # madera rojiza
    "marco": "#6B2E1E",
    "cara": "#C0684A",  # más clara: ahí va el texto
}
COLORES_TOLDO = {"Puesto": ("#3BB15A", "#F4F4F0"), "Tienda": ("#5BC0F0", "#F4F4F0")}
BRILLAN = {"linea": 0.6}
SIN_STUDS = {"cadenas", "cara", "escudo"}
MAX = {"Cerca_Madera": 1500, "Cerca_Esquina": 1500, "Cerca_Puerta": 1500, "Linea_ZonaSegura": 1500, "Cartel_Colgante": 4000, "Toldo": 2000}
# mallas que el juego busca por su nombre exacto (no llevan el nombre de la pieza adelante)
NOMBRE_FIJO = ("Linea_Escudo", "Cartel_Cara")


def materiales(prefijo, colores, studs=None):
    mats = {}
    for clave, color in colores.items():
        nombre = prefijo + "_" + clave.title()
        if clave in BRILLAN:
            mats[clave] = M.material(nombre, color, brillo=color, fuerza_brillo=BRILLAN[clave] if studs else 0)
        elif studs and clave not in SIN_STUDS:
            mats[clave] = D.material_studs(nombre, color, studs)
        else:
            mats[clave] = M.material(nombre, color)
    return mats


def armar(pieza, piezas, tope):
    objs, conteo = D.mallas(piezas, tope, pieza)
    total = sum(conteo.values())
    if total > tope:
        raise RuntimeError(f"{pieza}: {total} triángulos (máximo {tope})")
    return objs, conteo


# --- cercas ----------------------------------------------------------------------------------

CERCA_ALTO = 3
TABLONES_Z = ((0.9, 1.5), (2.0, 2.6))


def poste_cerca(p, x, y):
    """Poste de 1 x 1 con la cabeza (medio stud) un poco más ancha."""
    p.caja((x - 0.5, x + 0.5), (y - 0.5, y + 0.5), (0, CERCA_ALTO - 0.5), caras="xXyY")
    p.caja((x - 0.65, x + 0.65), (y - 0.65, y + 0.65), (CERCA_ALTO - 0.5, CERCA_ALTO), caras="xXyYzZ")


def tablones(t, a, b, eje="x", fijo=0.0):
    """Dos tablones de `a` a `b` sobre el eje dado, finitos (0,3) y un poco hacia adelante."""
    for z in TABLONES_Z:
        if eje == "x":
            t.caja((a, b), (fijo - 0.3, fijo), z, caras="yYzZ")
        else:
            t.caja((fijo - 0.3, fijo), (a, b), z, caras="xXzZ")


def cerca_madera(mats):
    p, t = D.Malla(), D.Malla()
    for x in (-3.5, 3.5):
        poste_cerca(p, x, 0)
    tablones(t, -3, 3)
    return armar("Cerca_Madera", [("Poste", p, mats["poste"]), ("Tablon", t, mats["tablon"])], MAX["Cerca_Madera"])


def cerca_esquina(mats):
    p, t = D.Malla(), D.Malla()
    for x, y in ((0, 0), (4, 0), (0, 4)):
        poste_cerca(p, x, y)
    tablones(t, 0.5, 3.5, "x", 0.15)
    tablones(t, 0.5, 3.5, "y", 0.15)
    return armar("Cerca_Esquina", [("Poste", p, mats["poste"]), ("Tablon", t, mats["tablon"])], MAX["Cerca_Esquina"])


def cerca_puerta(mats):
    p, t = D.Malla(), D.Malla()
    for x in (-5.5, -2.5, 2.5, 5.5):
        poste_cerca(p, x, 0)
    tablones(t, -5, -3)
    tablones(t, 3, 5)
    return armar("Cerca_Puerta", [("Poste", p, mats["poste"]), ("Tablon", t, mats["tablon"])], MAX["Cerca_Puerta"])


# --- Linea_ZonaSegura ------------------------------------------------------------------------


def linea(mats):
    lin, mar, esc = D.Malla(), D.Malla(), D.Malla()
    lin.caja((-16, 16), (-0.5, 0.5), (0, 0.1), caras="xXyYZ")
    # cartel en el piso del lado seguro: marco blanco y escudo de bloques encima
    mar.caja((-4, 4), (1.5, 6.5), (0, 0.08), caras="xXyYZ")
    escudo = [(-3, 3, 4.5, 6), (-2.5, 2.5, 3.2, 4.5), (-1.7, 1.7, 2.4, 3.2), (-0.8, 0.8, 1.9, 2.4)]
    for x0, x1, y0, y1 in escudo:
        esc.caja((x0, x1), (y0, y1), (0.08, 0.16), caras="xXyYZ")
    return armar(
        "Linea_ZonaSegura",
        [("Linea", lin, mats["linea"]), ("Linea_Marco", mar, mats["marco"]), ("Linea_Escudo", esc, mats["escudo"])],
        MAX["Linea_ZonaSegura"],
    )


# --- Cartel_Colgante -------------------------------------------------------------------------

CARTEL_POSTES_X = 21.5
CARTEL_Z = (11, 19)


def cadena(cad, x, y, z0, z1):
    z, i = z0, 0
    while z < z1 - 1e-6:
        r = 0.2 if i % 2 == 0 else 0.1
        cad.caja((x - r, x + r), (y - r, y + r), (z, min(z + 0.35, z1)), caras="xXyY")
        z += 0.35
        i += 1


def cartel_colgante(mats):
    lad, viga, cad, tab, mar, cara = (D.Malla() for _ in range(6))
    for x in (-CARTEL_POSTES_X, CARTEL_POSTES_X):
        L.poste(lad, x, 0, 2, 21, bloque=1.5)
        lad.caja((x - 1.3, x + 1.3), (-1.3, 1.3), (21, 22))  # cabeza más ancha
    viga.caja((-22.8, 22.8), (-0.6, 0.6), (22, 23))
    z0, z1 = CARTEL_Z
    for x in (-15, 15):
        cadena(cad, x, 0, z1 + 0.5, 22)
    # tablas horizontales de 2 studs, un poco corridas para que se vean las juntas
    for i in range(4):
        r = 0.4 if i % 2 == 0 else 0.35
        tab.caja((-19.5, 19.5), (-r, r), (z0 + 0.5 + i * 1.75, z0 + 0.5 + (i + 1) * 1.75), caras="xXyYzZ")
    mar.caja((-20, 20), (-0.5, 0.5), (z0, z0 + 0.5))
    mar.caja((-20, 20), (-0.5, 0.5), (z1 - 0.5, z1))
    mar.caja((-20, -19.5), (-0.5, 0.5), (z0 + 0.5, z1 - 0.5), caras="xXyY")
    mar.caja((19.5, 20), (-0.5, 0.5), (z0 + 0.5, z1 - 0.5), caras="xXyY")
    cara.caja((-18.5, 18.5), (-0.5, -0.45), (z0 + 1, z1 - 1), caras="yxXzZ")
    return armar(
        "Cartel_Colgante",
        [
            ("Ladrillo", lad, mats["ladrillo"]),
            ("Viga", viga, mats["viga"]),
            ("Cadenas", cad, mats["cadenas"]),
            ("Tablas", tab, mats["tablas"]),
            ("Marco", mar, mats["marco"]),
            ("Cartel_Cara", cara, mats["cara"]),
        ],
        MAX["Cartel_Colgante"],
    )


# --- Toldo_Rayas -----------------------------------------------------------------------------

TOLDO_FONDO = 4  # de y = 2 (atrás) a y = -2 (adelante)
TOLDO_PASOS = 4


def toldo(mats, version):
    col, bla = D.Malla(), D.Malla()
    ancho = 12 if version == "Puesto" else 16
    h = ancho / 2
    paso = TOLDO_FONDO / TOLDO_PASOS
    for i in range(ancho):
        m = col if i % 2 == 0 else bla
        x = (-h + i, -h + i + 1)
        for j in range(TOLDO_PASOS):
            # cada escalón más adelante y medio stud más abajo
            y0 = TOLDO_FONDO / 2 - (j + 1) * paso
            z = (TOLDO_PASOS - 1 - j) * 0.5
            m.caja(x, (y0, y0 + paso + 0.01), (z, z + 0.5), caras="xXyYzZ")
        # flecos: uno sí y uno no cuelgan medio stud más
        if i % 2 == 0:
            m.caja(x, (-TOLDO_FONDO / 2, -TOLDO_FONDO / 2 + 0.3), (-0.5, 0), caras="xXyYz")
    return armar(f"Toldo_{version}", [("Color", col, mats["color"]), ("Blanco", bla, mats["blanco"])], MAX["Toldo"])


def mats_toldo(version, studs=None):
    color, blanco = COLORES_TOLDO[version]
    return materiales(f"Toldo{version}", {"color": color, "blanco": blanco}, studs)


# --- render y exportación --------------------------------------------------------------------

PIEZAS = {
    "Cerca_Madera": (cerca_madera, lambda s=None: materiales("Cerca", COLORES_CERCA, s)),
    "Cerca_Esquina": (cerca_esquina, lambda s=None: materiales("Cerca", COLORES_CERCA, s)),
    "Cerca_Puerta": (cerca_puerta, lambda s=None: materiales("Cerca", COLORES_CERCA, s)),
    "Linea_ZonaSegura": (linea, lambda s=None: materiales("Linea", COLORES_LINEA, s)),
    "Cartel_Colgante": (cartel_colgante, lambda s=None: materiales("Cartel", COLORES_CARTEL, s)),
    "Toldo_Puesto": (lambda m: toldo(m, "Puesto"), lambda s=None: mats_toldo("Puesto", s)),
    "Toldo_Tienda": (lambda m: toldo(m, "Tienda"), lambda s=None: mats_toldo("Tienda", s)),
}


def mover(objs, x, y, z=0.0, giro=0.0):
    import math

    raiz = bpy.data.objects.new("grupo", None)
    bpy.context.scene.collection.objects.link(raiz)
    for o in objs:
        if o.parent is None:
            o.parent = raiz
    raiz.location = (x * M.STUD, y * M.STUD, z * M.STUD)
    raiz.rotation_euler.z = math.radians(giro)


def escena_todo(studs):
    """Una parcela con corral de cercas al costado, la línea en la entrada, el cartel colgante
    cruzando el camino y el puesto y la tienda con su toldo."""
    conteos = {}

    def poner(pieza, x, y, z=0.0, giro=0.0):
        armar_pieza, mats_de = PIEZAS[pieza]
        objs, conteo = armar_pieza(mats_de(studs))
        conteos[pieza] = sum(conteo.values())
        mover(objs, x, y, z, giro)

    L.parcela_render(studs)
    # corral a la derecha de la parcela (x de 22 a 38, y de -8 a 8)
    poner("Cerca_Esquina", 22, -8)
    poner("Cerca_Esquina", 38, -8, giro=90)
    poner("Cerca_Esquina", 38, 8, giro=180)
    poner("Cerca_Esquina", 22, 8, giro=270)
    for y in (-4, 4):
        poner("Cerca_Madera", 22, y, giro=90)
    poner("Cerca_Puerta", 30, -8)
    poner("Cerca_Madera", 26, 8)
    poner("Cerca_Madera", 34, 8)
    poner("Cerca_Madera", 38, -4, giro=90)
    poner("Cerca_Madera", 38, 4, giro=90)
    # línea de zona segura delante de la entrada, con el cartel del lado de la parcela
    poner("Linea_ZonaSegura", 0, -22, giro=180)
    # cartel colgante cruzando el camino, más adelante
    poner("Cartel_Colgante", 0, -30)
    # puesto y tienda con su toldo, a la izquierda
    pv, _ = L.puesto_vender(L.materiales("Puesto", L.COLORES_PUESTO, studs))
    mover(pv, -34, -6)
    poner("Toldo_Puesto", -34, -6 - 5.5, z=7.5)
    tf, _ = L.tienda_forja(L.mats_tienda(studs))
    mover(tf, -34, 14)
    poner("Toldo_Tienda", -34, 14 - 6.5, z=9)
    return conteos


def render():
    conteos = {}
    for vista, giro, ancho, centro in (("todo", -30, 110, (-2, -6, 4)), ("cerca", -30, 48, (-20, -14, 8))):
        M.limpiar_escena()
        escena = M.escena_render(1600, 900)
        conteos = escena_todo(D.textura_studs())
        D.camara_orto(escena, tuple(c * M.STUD for c in centro), ancho * M.STUD, 35, giro)
        M.render(f"piezas_juego_{vista}")
    for pieza, total in conteos.items():
        print("TRIANGULOS", pieza, total)
    bpy.ops.wm.save_as_mainfile(filepath=str(M.ARTE / "blend" / "Piezas_Juego.blend"))


def exportar():
    """Piezas_Juego.fbx: un vacío por pieza aprobada con sus mallas (Cerca_Madera_Poste...)."""
    M.limpiar_escena()
    raices = []
    for pieza in APROBADAS:
        armar_pieza, mats_de = PIEZAS[pieza]
        objs, _ = armar_pieza(mats_de())
        raiz = bpy.data.objects.new(pieza, None)
        bpy.context.scene.collection.objects.link(raiz)
        for o in objs:
            if o.name not in NOMBRE_FIJO:
                o.name = f"{pieza}_{o.name}"
            o.parent = raiz
        raices.append((raiz, objs))
    bpy.ops.object.select_all(action="DESELECT")
    for raiz, objs in raices:
        raiz.select_set(True)
        for o in objs:
            o.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=str(M.FBX / "Piezas_Juego.fbx"),
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
    print("  FBX Piezas_Juego.fbx:", ", ".join(APROBADAS))


if __name__ == "__main__":
    if "--exportar" in sys.argv:
        exportar()
    else:
        render()
    print("Listo")
