"""Matón del puerto: enemigo común de Puerto Óxido.

Campera de cuero con cuello levantado, gorro de lana, pañuelo que tapa nariz y boca, cadena
enrollada en la mano derecha, jean y borcegos. Presupuesto de enemigo común: 8.000 triángulos en
total (GUIA-ESTILO), cada malla ≤ 20.000. Tres variantes que solo cambian el material del gorro
(rojo, verde, gris): las mallas son las mismas.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/enemigos/maton.py -- boceto

Paso "boceto": bloques sin detalle, render de 3 vistas (renders/enemigo-maton_boceto_vistas.png) y
frente de las 3 variantes (renders/enemigo-maton_boceto_variantes.png).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import base as B  # noqa: E402
import bpy  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "Maton"
ARCHIVO = "enemigo-maton"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")

# Presupuesto de triángulos por pieza (total 8.000).
PRESUPUESTO = {
    "Campera": 3000,
    "Gorro": 1200,
    "Panuelo": 800,
    "Cadena": 1100,
    "Pantalon": 1100,
    "Botas": 800,
}

# Variante -> material del gorro (lo único que cambia).
VARIANTES = {"Rojo": "lana-roja", "Verde": "lana-verde", "Gris": "lana-gris"}


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def campera():
    """Campera de cuero abierta adelante: torso ancho (hombros cargados), cuello levantado,
    solapas, cintura elástica. Mangas aparte (siguen a su hueso)."""
    _, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    frente = tc.y - tm.y - 0.04

    def torso(bm):
        T.bloque_redondo(bm, tc + Vector((0, 0, 0.01)), tm + Vector((0.06, 0.05, 0.03)), 0.3, 20, 12)
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.4)), Vector((lm.x + 0.06, lm.y + 0.06, lm.z * 0.6)), 0.3, 20, 8)

    def cuello(bm):
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * 0.13, tc.y - tm.y * 0.3, tmax.z + 0.04)), Vector((0.06, tm.y * 1.4, 0.14)), _g(-s * 10, "Y"))
            T.caja(bm, Vector((tc.x + s * 0.12, frente - 0.01, tc.z + tm.z * 0.3)), Vector((0.12, 0.02, tm.z * 1.0)), _g(s * 12, "Y"))

    piezas = [T.pieza(f"{NOMBRE}_Campera", "UpperTorso", [("campera", torso), ("campera", cuello)])]
    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)

            def manga(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.045, 0.045, 0.01)), 0.35, 16, 8)

            sufijo = "Arriba" if "Upper" in parte else "Abajo"
            piezas.append(T.pieza(f"{NOMBRE}_Manga{sufijo}{lado}", parte, [("campera", manga)]))
    return piezas


def gorro():
    """Gorro de lana ajustado con el borde doblado, tapa las orejas por arriba."""
    _, hmax, hc, hm = T.caja_parte("Head")
    zb = hmax.z - hm.z * 0.55

    def lana(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, zb + hm.z * 0.45)), Vector((hm.x + 0.03, hm.y + 0.03, hm.z * 0.6)), 0.75, 20, 10)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, zb + 0.03)), Vector((hm.x + 0.045, hm.y + 0.045, 0.05)), 0.6, 20, 4)

    return T.pieza(f"{NOMBRE}_Gorro", "Head", [("lana-roja", lana)])


def panuelo():
    """Pañuelo atado que tapa nariz y boca, con la punta cayendo sobre el pecho."""
    _, _, hc, hm = T.caja_parte("Head")
    z = hc.z - hm.z * 0.3

    def tela(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, z)), Vector((hm.x + 0.02, hm.y + 0.02, hm.z * 0.4)), 0.6, 20, 6)
        T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.04, z - hm.z * 0.5)), Vector((0.2, 0.02, 0.18)), _g(-15, "X"))

    return T.pieza(f"{NOMBRE}_Panuelo", "Head", [("panuelo", tela)])


def cadena():
    """Cadena enrollada en el puño derecho que cuelga hasta la rodilla."""
    _, _, mc, _ = T.caja_parte("RightHand")

    def eslabones(bm):
        for k in range(9):
            p = Vector((mc.x + math.sin(k * 0.6) * 0.03, mc.y - 0.02, mc.z - 0.05 - k * 0.07))
            T.caja(bm, p, Vector((0.035, 0.015, 0.06)), _g(90 * (k % 2), "Z"))

    return T.pieza(f"{NOMBRE}_Cadena", "RightHand", [("acero", eslabones)])


def pantalon_botas():
    piezas = []
    for lado, hueso in T._lados("UpperLeg"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)

            def jean(bm, c=c, m=m):
                T.bloque_redondo(bm, c, m + Vector((0.035, 0.035, 0.01)), 0.35, 16, 8)

            sufijo = "Arriba" if "Upper" in parte else "Abajo"
            piezas.append(T.pieza(f"{NOMBRE}_Pantalon{sufijo}{lado}", parte, [("jean", jean)]))
    for lado, hueso in T._lados("Foot"):
        _, _, fc, fm = T.caja_parte(hueso)

        def bota(bm, fc=fc, fm=fm):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.04)), fm + Vector((0.035, 0.05, 0.06)), 0.3, 16, 8)

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota)]))
    return piezas


def poner_variante(piezas, variante):
    for o in piezas:
        if o.name.startswith(f"{NOMBRE}_Gorro"):
            o.data.materials.clear()
            o.data.materials.append(B.material(VARIANTES[variante]))


def render_variantes(prefijo, piezas):
    """Frente de cada variante en una sola hoja: renders/<prefijo>_variantes.png."""
    rutas = []
    for v in VARIANTES:
        poner_variante(piezas, v)
        rutas.append(B.render_primer_plano(f"_{prefijo}_{v}", B.partes() + piezas, giro=20, altura=5, margen=1.0))
    poner_variante(piezas, "Rojo")
    ruta = os.path.join(B.RENDERS, f"{prefijo}_variantes.png")
    B.hoja([rutas], ruta)
    for r in rutas:
        os.remove(r)
    return ruta


def boceto():
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    B.configurar_luz()
    piezas = [*campera(), gorro(), panuelo(), cadena(), *pantalon_botas()]
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print("Triángulos:", B.contar_triangulos(piezas))
    print("Render:", B.render_vistas(ARCHIVO + "_boceto", B.partes() + piezas))
    print("Variantes:", render_variantes(ARCHIVO + "_boceto", piezas))
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


# ---------------------------------------------------------------------------
# Detalle (paso 2)
# ---------------------------------------------------------------------------

PIEZAS = (
    ("Campera", "Campera"),
    ("Manga", "Campera"),
    ("Gorro", "Gorro"),
    ("Panuelo", "Panuelo"),
    ("Cadena", "Cadena"),
    ("Pantalon", "Pantalon"),
    ("Bota", "Botas"),
)


def _pieza_de(nombre_obj):
    """Maton_MangaArribaIzq -> Campera (para el presupuesto)."""
    base = nombre_obj.split("_")[1]
    for prefijo, clave in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def _gorro_de(variante):
    return f"{NOMBRE}_Gorro" + ("" if variante == "Rojo" else f"_{variante}")


def _aro(bm, centro, radio, grosor, normal=(0, 0, 1), lados=6, pasos=24, escala_y=1.0):
    """Anillo cerrado (puño, pliegue, eslabón) alrededor de `normal`."""
    giro = Vector((0, 0, 1)).rotation_difference(Vector(normal)).to_matrix()
    camino = [
        Vector(centro) + giro @ Vector((math.cos(a) * radio, math.sin(a) * radio * escala_y, 0))
        for a in [2 * math.pi * i / pasos for i in range(pasos + 1)]
    ]
    T.tubo(bm, camino, grosor, lados, False)


def d_campera():
    """Campera de cuero abierta: hombros cargados, cuello levantado, solapas, dos hileras de dientes
    de cierre, bolsillos con cierre en diagonal, broches, cintura elástica, canesú y costuras de
    espalda. Mangas con costura, pliegue en el codo y puño elástico."""
    tmin, tmax, tc, tm = T.caja_parte("UpperTorso")
    _, _, lc, lm = T.caja_parte("LowerTorso")
    frente = tc.y - tm.y - 0.05
    atras = tc.y + tm.y + 0.05

    def cuero(bm):
        T.bloque_redondo(bm, tc + Vector((0, 0, 0.01)), tm + Vector((0.06, 0.05, 0.03)), 0.3, 16, 8)
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z + lm.z * 0.4)), Vector((lm.x + 0.06, lm.y + 0.06, lm.z * 0.6)), 0.3, 16, 6)
        for s in (-1, 1):
            T.caja(bm, Vector((tc.x + s * 0.14, tc.y - tm.y * 0.2, tmax.z + 0.05)), Vector((0.05, tm.y * 1.5, 0.16)), _g(-s * 12, "Y"))
            T.caja(bm, Vector((tc.x + s * 0.12, frente - 0.012, tc.z + tm.z * 0.35)), Vector((0.13, 0.022, tm.z * 1.0)), _g(s * 14, "Y"))
            T.caja(bm, Vector((tc.x + s * tm.x * 0.55, frente - 0.006, tc.z - tm.z * 0.45)), Vector((0.03, 0.02, 0.2)), _g(s * 25, "Y"))
        T.bloque_redondo(bm, Vector((lc.x, lc.y, lc.z - lm.z * 0.15)), Vector((lm.x + 0.075, lm.y + 0.075, 0.05)), 0.5, 16, 4)
        canesu = [Vector((tc.x + x, atras + 0.004, tmax.z - 0.14 - abs(x) * 0.3)) for x in [tm.x * (-1 + 2 * k / 8) for k in range(9)]]
        T.tubo(bm, canesu, 0.007, 4)
        for s in (-1, 1):
            T.tubo(bm, [Vector((tc.x + s * 0.12, atras + 0.004, z)) for z in (tmax.z - 0.18, tc.z, tmin.z)], 0.006, 4)

    def metal(bm):
        z0, z1 = tc.z + tm.z * 0.6, lc.z - lm.z * 0.1
        for s in (-1, 1):
            for i in range(12):  # dientes del cierre abierto
                z = z1 + (z0 - z1) * (i + 0.5) / 12
                T.caja(bm, Vector((tc.x + s * 0.045, frente - 0.01, z)), Vector((0.016, 0.008, 0.012)))
            T.caja(bm, Vector((tc.x + s * tm.x * 0.55, frente - 0.02, tc.z - tm.z * 0.3)), Vector((0.018, 0.01, 0.04)))
            for k in range(3):  # broches de las solapas
                T.remache(bm, Vector((tc.x + s * 0.1, frente - 0.03, tc.z + tm.z * (0.75 - k * 0.3))), 0.011)

    piezas = T.pieza_separada(f"{NOMBRE}_Campera", "UpperTorso", [("campera", cuero), ("acero", metal)])
    for lado, hueso in T._lados("UpperArm"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)
            abajo = "Lower" in parte

            def manga(bm, c=c, m=m, abajo=abajo):
                T.bloque_redondo(bm, c, m + Vector((0.045, 0.045, 0.01)), 0.35, 14, 6)
                if abajo:
                    T.bloque_redondo(bm, Vector((c.x, c.y, c.z - m.z + 0.05)), Vector((m.x + 0.055, m.y + 0.055, 0.045)), 0.6, 14, 4)
                    _aro(bm, Vector((c.x, c.y, c.z + m.z * 0.6)), max(m.x, m.y) + 0.05, 0.01, pasos=14)
                else:
                    T.tubo(bm, [Vector((c.x, c.y - m.y - 0.047, z)) for z in (c.z - m.z, c.z, c.z + m.z)], 0.006, 4)

            sufijo = "Abajo" if abajo else "Arriba"
            piezas.append(T.pieza(f"{NOMBRE}_Manga{sufijo}{lado}", parte, [("campera", manga)]))
    return piezas


def d_gorro():
    """Gorro de lana alto y ajustado: copa redonda que cae un poco hacia atrás, borde doblado grueso
    con su pliegue y costura cruzada arriba. El tejido lo pone la textura."""
    _, hmax, hc, hm = T.caja_parte("Head")
    zb = hmax.z - hm.z * 0.55
    r, ry = hm.x + 0.035, hm.y + 0.035

    def lana(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y + 0.02, zb + hm.z * 0.55)), Vector((r, ry, hm.z * 0.8)), 0.9, 28, 14)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, zb + 0.06)), Vector((r + 0.025, ry + 0.025, 0.085)), 0.6, 28, 6)
        T.bloque_redondo(bm, Vector((hc.x, hc.y, zb + 0.06)), Vector((r + 0.03, ry + 0.03, 0.01)), 0.6, 28, 2)  # pliegue
        for giro in (0, 90):  # costura cruzada arriba
            T.caja(bm, Vector((hc.x, hc.y + 0.02, zb + hm.z * 1.33)), Vector((r * 0.9, 0.015, 0.012)), _g(giro, "Z"))

    return T.pieza(f"{NOMBRE}_Gorro", "Head", [("lana-roja", lana)])


def d_panuelo():
    """Pañuelo que tapa nariz y boca: banda sobre la cara con pliegues, triángulo que cae al pecho
    y nudo con dos puntas en la nuca."""
    _, _, hc, hm = T.caja_parte("Head")
    z = hc.z - hm.z * 0.3

    def tela(bm):
        T.bloque_redondo(bm, Vector((hc.x, hc.y, z)), Vector((hm.x + 0.025, hm.y + 0.025, hm.z * 0.4)), 0.6, 16, 4)
        for k in range(3):  # pliegues sobre la nariz y la boca
            T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.03, z - hm.z * 0.2 + k * 0.06)), Vector((hm.x * 1.6, 0.012, 0.012)), _g((k - 1) * 4, "Y"))
        T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.05, z - hm.z * 0.55)), Vector((0.24, 0.02, 0.2)), _g(-18, "X"))
        T.caja(bm, Vector((hc.x, hc.y - hm.y - 0.075, z - hm.z * 0.95)), Vector((0.1, 0.018, 0.1)), _g(-25, "X") @ _g(45, "Y"))
        n = Vector((hc.x, hc.y + hm.y + 0.04, z))
        T.bloque_redondo(bm, n, Vector((0.04, 0.03, 0.035)), 0.7, 10, 6)
        for s in (-1, 1):
            T.caja(bm, n + Vector((s * 0.035, 0.01, -0.08)), Vector((0.04, 0.012, 0.13)), _g(s * 15, "Y"))

    return T.pieza(f"{NOMBRE}_Panuelo", "Head", [("panuelo", tela)])


def d_cadena():
    """Cadena gruesa: dos vueltas en el puño derecho y 10 eslabones colgando hasta la rodilla,
    alternados a 90 grados, con un candado en la punta."""
    _, _, mc, mm = T.caja_parte("RightHand")

    def eslabones(bm):
        for v in (-0.03, 0.02):
            _aro(bm, Vector((mc.x, mc.y, mc.z + v)), max(mm.x, mm.y) + 0.03, 0.012, pasos=12)
        for k in range(10):
            p = Vector((mc.x + math.sin(k * 0.5) * 0.04, mc.y - 0.03, mc.z - 0.09 - k * 0.065))
            _aro(bm, p, 0.03, 0.009, (1, 0, 0) if k % 2 else (0, 1, 0), 4, 8)
        c = Vector((mc.x + math.sin(5) * 0.04, mc.y - 0.03, mc.z - 0.8))
        T.caja(bm, c, Vector((0.06, 0.03, 0.06)))
        _aro(bm, c + Vector((0, 0, 0.045)), 0.02, 0.006, (0, 1, 0), 4, 10)

    return T.pieza(f"{NOMBRE}_Cadena", "RightHand", [("acero", eslabones)])


def d_pantalon_botas():
    """Jean con costura lateral, bolsillos de atrás y rodilla gastada; borcegos con cordones,
    suela gruesa y ranuras."""
    piezas = []
    for lado, hueso in T._lados("UpperLeg"):
        for parte in (hueso, hueso.replace("Upper", "Lower")):
            _, _, c, m = T.caja_parte(parte)
            arriba = "Upper" in parte
            lx = 1 if c.x > 0 else -1

            def jean(bm, c=c, m=m, arriba=arriba, lx=lx):
                T.bloque_redondo(bm, c, m + Vector((0.035, 0.035, 0.01)), 0.35, 14, 6)
                T.tubo(bm, [Vector((c.x + lx * (m.x + 0.037), c.y, z)) for z in (c.z - m.z, c.z, c.z + m.z)], 0.006, 4)
                if arriba:
                    T.caja(bm, Vector((c.x, c.y + m.y + 0.04, c.z + m.z * 0.4)), Vector((m.x * 1.4, 0.012, 0.16)))
                else:
                    T.bloque_redondo(bm, Vector((c.x, c.y - m.y - 0.04, c.z + m.z * 0.6)), Vector((m.x * 0.7, 0.01, 0.09)), 0.6, 10, 4)

            sufijo = "Arriba" if arriba else "Abajo"
            piezas.append(T.pieza(f"{NOMBRE}_Pantalon{sufijo}{lado}", parte, [("jean", jean)]))
    for lado, hueso in T._lados("Foot"):
        fmin, _, fc, fm = T.caja_parte(hueso)

        def bota(bm, fc=fc, fm=fm, fmin=fmin):
            T.bloque_redondo(bm, fc + Vector((0, -0.03, 0.05)), fm + Vector((0.035, 0.05, 0.07)), 0.35, 14, 6)
            T.bloque_redondo(bm, Vector((fc.x, fc.y - 0.03, fmin.z + 0.01)), Vector((fm.x + 0.045, fm.y + 0.075, 0.03)), 0.3, 14, 4)
            for k in range(5):  # ranuras de la suela
                T.caja(bm, Vector((fc.x, fc.y - fm.y - 0.07 + k * 0.05, fmin.z - 0.02)), Vector((fm.x * 2 + 0.08, 0.015, 0.015)))
            f = fc.y - fm.y - 0.05
            for k in range(4):  # cordones
                z = fc.z + fm.z * (0.1 + k * 0.4)
                T.tubo(bm, [Vector((fc.x - 0.04, f + k * 0.01, z)), Vector((fc.x + 0.04, f + k * 0.01, z + 0.02))], 0.006, 4)

        piezas.append(T.pieza(f"{NOMBRE}_Bota{lado}", hueso, [("negro", bota)]))
    return piezas


def piezas_detalle():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


def _miles(n):
    return f"{n:,}".replace(",", ".")


def tabla_triangulos(objs):
    """Cuenta un solo gorro: los otros colores son la misma malla con otra textura."""
    objs = [o for o in objs if not o.name.startswith(f"{NOMBRE}_Gorro_")]
    cuenta = B.contar_triangulos(objs)
    por_pieza = {}
    for nombre, n in cuenta.items():
        if nombre != "_total":
            por_pieza[_pieza_de(nombre)] = por_pieza.get(_pieza_de(nombre), 0) + n
    filas = ["| Pieza | Triángulos | Presupuesto | Mallas |", "|---|---|---|---|"]
    for clave, tope in PRESUPUESTO.items():
        mallas = ", ".join(sorted(n.replace(NOMBRE + "_", "") for n in cuenta if n != "_total" and _pieza_de(n) == clave))
        marca = "" if por_pieza.get(clave, 0) <= tope else " ⚠"
        filas.append(f"| {clave} | {_miles(por_pieza.get(clave, 0))}{marca} | {_miles(tope)} | {mallas} |")
    filas.append(f"| **Total** | **{_miles(cuenta['_total'])}** | **{_miles(sum(PRESUPUESTO.values()))}** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {_miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, ARCHIVO + "_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Matón del puerto: triángulos por pieza\n\n" + texto + "\n")
    return texto


def armar_detalle():
    """Solo la geometría (sin bisel ni horneado), para revisar rápido."""
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    for armar in (d_campera, d_gorro, d_panuelo, d_cadena, d_pantalon_botas):
        armar()
    return piezas_detalle()


def gorros_variantes():
    """Copias del gorro terminado (misma malla) con la lana verde y la gris."""
    rojo = bpy.data.objects[_gorro_de("Rojo")]
    copias = []
    for v, mat in list(VARIANTES.items())[1:]:
        o = rojo.copy()
        o.data = rojo.data.copy()
        o.name = _gorro_de(v)
        rojo.users_collection[0].objects.link(o)
        B.aplicar_material(o, mat)
        copias.append(o)
    return copias


def mostrar_variante(variante):
    """Deja visible solo el gorro de `variante`."""
    for v in VARIANTES:
        o = bpy.data.objects.get(_gorro_de(v))
        if o:
            o.hide_render = o.hide_viewport = v != variante


def _renders(piezas, prefijo):
    resto = [o for o in piezas if _pieza_de(o.name) != "Gorro"]
    cara = [o for o in resto if _pieza_de(o.name) == "Panuelo"] + [B.parte("Head")]
    vistas = []
    for v in VARIANTES:
        mostrar_variante(v)
        g = bpy.data.objects[_gorro_de(v)]
        sufijo = "" if v == "Rojo" else "_" + v.lower()
        vistas.append(B.render_vistas(prefijo + sufijo, B.partes() + resto + [g]))
        B.render_primer_plano(f"{prefijo}_cara{sufijo}", cara + [g], giro=25, altura=8, margen=1.3)
    mostrar_variante("Rojo")
    B.hoja([[r] for r in vistas], os.path.join(B.RENDERS, f"{prefijo}_variantes.png"), reducir=2)
    B.render_primer_plano(f"{prefijo}_cadena", [o for o in resto if _pieza_de(o.name) == "Cadena"] + [B.parte("RightHand")], giro=-35, altura=8, margen=1.1)
    B.render_primer_plano(f"{prefijo}_campera", [o for o in resto if _pieza_de(o.name) == "Campera"], giro=20, altura=6, margen=1.05)


def prueba():
    armar_detalle()
    gorros_variantes()
    piezas = piezas_detalle()
    print(tabla_triangulos(piezas))
    _renders(piezas, "_enemigo-maton_prueba")


def detalle():
    import detalle as D

    piezas = armar_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, ARCHIVO, lados={o.name: 512 for o in piezas})  # enemigo común: 512 px
    # El gorro verde y el gris son la misma malla horneada con otra lana.
    D.preparar_cycles()
    for i, o in enumerate(gorros_variantes()):
        receta = D.RECETAS.get(VARIANTES[o.name.split("_")[-1]], {})
        D.hornear(o, D.copia_alta(o, receta), ARCHIVO, 512, semilla=100 + i, receta=receta)
    motores = {m.identifier for m in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in motores else "BLENDER_EEVEE"
    piezas = piezas_detalle()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas))
    _renders(piezas, ARCHIVO)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    return piezas


def exportar():
    """Un FBX por malla en exports/enemigo-maton/ (el gorro, una vez por color)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    for v in VARIANTES:
        o = bpy.data.objects[_gorro_de(v)]
        o.hide_render = o.hide_viewport = False
    rutas = B.exportar_piezas(ARCHIVO, piezas_detalle())
    print("Exportadas:", len(rutas))
    return rutas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if "boceto" in argumentos:
        boceto()
    for paso in ("prueba", "detalle", "exportar"):
        if paso in argumentos:
            globals()[paso]()
