"""Matón con implantes: enemigo común de Puerto Óxido y Ciudad Vórtice.

Es el Matón del puerto (misma campera, gorro, pañuelo, jean y borcegos, ver maton.py) con el brazo
derecho cambiado por uno de metal con un pistón en el codo y un ojo implantado que brilla en
neon-aviso. La cadena pasa a la mano izquierda. Presupuesto de enemigo común: 10.000 triángulos
(GUIA-ESTILO). Tres variantes que solo cambian el material del brazo (acero, óxido, bronce): las
mallas son las mismas. El gorro va siempre gris para que no se confunda con el matón común.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/enemigos/maton_implantes.py -- boceto

Pasos: "boceto" (brazo y ojo de bloques), "prueba" (detalle sin hornear), "detalle", "exportar".
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import base as B  # noqa: E402
import bpy  # noqa: E402
import maton as M  # noqa: E402
import trajes as T  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

NOMBRE = "MatonImp"
ARCHIVO = "enemigo-maton-implantes"
BLEND = os.path.join(B.BLENDER, ARCHIVO + ".blend")
M.NOMBRE = NOMBRE  # las piezas del matón salen con este prefijo

# Presupuesto de triángulos por pieza (total 10.000).
PRESUPUESTO = {
    "Campera": 2400,
    "Gorro": 1200,
    "Panuelo": 800,
    "Cadena": 1100,
    "Pantalon": 1100,
    "Botas": 800,
    "Brazo": 2200,
    "Ojo": 400,
}

# Variante -> material del brazo (lo único que cambia).
VARIANTES = {"Acero": "acero", "Oxido": "oxido", "Bronce": "bronce"}
BRAZO = ("RightUpperArm", "RightLowerArm", "RightHand")
NOMBRES_BRAZO = {"RightUpperArm": "BrazoArriba", "RightLowerArm": "BrazoAbajo", "RightHand": "BrazoMano"}

PIEZAS = (*M.PIEZAS, ("Brazo", "Brazo"), ("Ojo", "Ojo"))


def _g(grados, eje):
    return Matrix.Rotation(math.radians(grados), 3, eje)


def _pieza_de(nombre_obj):
    base = nombre_obj.split("_")[1]
    for prefijo, clave in PIEZAS:
        if base.startswith(prefijo):
            return clave
    return base


def _nombre_brazo(hueso, variante="Acero"):
    return f"{NOMBRE}_{NOMBRES_BRAZO[hueso]}" + ("" if variante == "Acero" else f"_{variante}")


def brazo(detalle=False):
    """Brazo de metal: hombro con anillo atornillado, brazo de placas con pistón hidráulico que
    baja hasta el antebrazo, antebrazo con nervios y mano de dedos gruesos. Una malla por hueso."""
    piezas = []
    _, _, uc, um = T.caja_parte("RightUpperArm")
    _, _, fc, fm = T.caja_parte("RightLowerArm")
    _, _, hc, hm = T.caja_parte("RightHand")
    afuera = 1 if uc.x > 0 else -1
    seg = (20, 8) if detalle else (12, 4)

    def arriba(bm):
        T.bloque_redondo(bm, uc + Vector((0, 0, 0.02)), um + Vector((0.03, 0.03, 0.04)), 0.45, *seg)
        T.bloque_redondo(bm, Vector((uc.x, uc.y, uc.z + um.z)), Vector((um.x + 0.07, um.y + 0.07, 0.07)), 0.6, *seg)  # hombro
        a = Vector((uc.x + afuera * (um.x + 0.05), uc.y + 0.02, uc.z + um.z * 0.5))
        b = Vector((fc.x + afuera * (fm.x + 0.05), fc.y + 0.02, fc.z))
        medio = (a + b) / 2
        T.cilindro(bm, a, medio, 0.065, 12 if detalle else 8)  # camisa del pistón
        T.cilindro(bm, medio, b, 0.032, 10 if detalle else 6)  # vástago
        if detalle:
            for k in range(6):  # tornillos del anillo del hombro
                ang = 2 * math.pi * k / 6
                T.remache(bm, Vector((uc.x + math.cos(ang) * (um.x + 0.07), uc.y + math.sin(ang) * (um.y + 0.07), uc.z + um.z + 0.05)), 0.014, (0, 0, 1))
            for z in (0.3, -0.1, -0.5):  # juntas entre placas
                T.bloque_redondo(bm, Vector((uc.x, uc.y, uc.z + um.z * z)), Vector((um.x + 0.04, um.y + 0.04, 0.012)), 0.5, 20, 2)
            for t in (0.1, 0.45):  # abrazaderas de la camisa
                p = a + (medio - a) * t
                T.cilindro(bm, p - Vector((0, 0, 0.015)), p + Vector((0, 0, 0.015)), 0.077, 12)
            T.cilindro(bm, b - Vector((0, 0.035, 0)), b + Vector((0, 0.035, 0)), 0.035, 10)  # perno del codo

    def abajo(bm):
        T.bloque_redondo(bm, fc, fm + Vector((0.04, 0.04, 0.02)), 0.4, *seg)
        T.cilindro(bm, Vector((fc.x - fm.x - 0.06, fc.y, fc.z + fm.z)), Vector((fc.x + fm.x + 0.06, fc.y, fc.z + fm.z)), 0.07, 12 if detalle else 8)  # codo
        if detalle:
            for k in range(3):  # nervios del antebrazo
                T.caja(bm, Vector((fc.x, fc.y - fm.y - 0.045, fc.z + fm.z * (0.5 - k * 0.45))), Vector((fm.x * 1.6, 0.02, 0.025)))
            for s in (-1, 1):
                for k in range(3):
                    T.remache(bm, Vector((fc.x + s * fm.x * 0.8, fc.y - fm.y - 0.045, fc.z + fm.z * (0.75 - k * 0.6))), 0.01)
            T.bloque_redondo(bm, Vector((fc.x, fc.y, fc.z - fm.z)), Vector((fm.x + 0.06, fm.y + 0.06, 0.03)), 0.5, 20, 2)  # muñeca

    def mano(bm):
        T.bloque_redondo(bm, hc + Vector((0, 0, 0.02)), hm + Vector((0.035, 0.035, 0.0)), 0.4, *seg)
        for k in range(4):  # dedos gruesos
            x = hc.x - hm.x * 0.75 + k * hm.x * 0.5
            T.caja(bm, Vector((x, hc.y - 0.01, hc.z - hm.z - 0.06)), Vector((0.05, 0.06, 0.12)), _g(-10, "X"))
            if detalle:
                T.caja(bm, Vector((x, hc.y - 0.035, hc.z - hm.z - 0.03)), Vector((0.055, 0.02, 0.02)))
        T.caja(bm, Vector((hc.x - afuera * (hm.x + 0.04), hc.y - 0.02, hc.z - 0.02)), Vector((0.05, 0.05, 0.1)), _g(afuera * 20, "Y"))  # pulgar

    for hueso, armar in zip(BRAZO, (arriba, abajo, mano)):
        piezas.append(T.pieza(_nombre_brazo(hueso), hueso, [("acero", armar)]))
    return piezas


def ojo(detalle=False):
    """Ojo implantado en el lado derecho de la cara: aro de acero atornillado, lente que brilla en
    neon-aviso y una placa con un cable que se mete bajo el gorro."""
    _, _, hc, hm = T.caja_parte("Head")
    lado = 1 if T.caja_parte("RightHand")[2].x > 0 else -1
    c = Vector((hc.x + lado * hm.x * 0.42, hc.y - hm.y - 0.01, hc.z + hm.z * 0.12))

    def aro(bm):
        T.cilindro(bm, c + Vector((0, 0.01, 0)), c - Vector((0, 0.03, 0)), 0.075, 16 if detalle else 10)
        T.caja(bm, c + Vector((lado * 0.07, 0.0, 0.08)), Vector((0.07, 0.02, 0.1)))  # placa hacia la sien
        if detalle:
            for k in range(4):
                ang = math.pi / 4 + k * math.pi / 2
                T.remache(bm, c + Vector((math.cos(ang) * 0.06, -0.032, math.sin(ang) * 0.06)), 0.009)
            T.tubo(bm, [c + Vector((lado * 0.09, 0.0, 0.12)), Vector((hc.x + lado * (hm.x + 0.01), hc.y - hm.y * 0.3, hc.z + hm.z * 0.5)), Vector((hc.x + lado * (hm.x + 0.02), hc.y, hc.z + hm.z * 0.7))], 0.01, 6)

    def lente(bm):
        T.cilindro(bm, c - Vector((0, 0.03, 0)), c - Vector((0, 0.045, 0)), 0.05, 16 if detalle else 10)

    return [T.pieza(f"{NOMBRE}_Ojo", "Head", [("acero", aro)]), T.pieza(f"{NOMBRE}_OjoLente", "Head", [("neon-aviso", lente)])]


def cuerpo_maton():
    """Las piezas aprobadas del matón, sin las mangas derechas, con la cadena en la otra mano y el
    gorro gris."""
    M.d_campera()
    for parte in ("MangaArribaDer", "MangaAbajoDer"):
        bpy.data.objects.remove(bpy.data.objects[f"{NOMBRE}_{parte}"])
    B.aplicar_material(M.d_gorro(), "lana-gris")
    M.d_panuelo()
    M.d_cadena("LeftHand")
    M.d_pantalon_botas()


def piezas_todas():
    return [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith(NOMBRE + "_") and not o.name.endswith("_Alto")]


def variantes_brazo():
    """Copias del brazo terminado (mismas mallas) con el óxido y el bronce."""
    copias = []
    for v, mat in list(VARIANTES.items())[1:]:
        for hueso in BRAZO:
            base = bpy.data.objects[_nombre_brazo(hueso)]
            o = base.copy()
            o.data = base.data.copy()
            o.name = _nombre_brazo(hueso, v)
            base.users_collection[0].objects.link(o)
            B.aplicar_material(o, mat)
            copias.append(o)
    return copias


def mostrar_variante(variante):
    for v in VARIANTES:
        for hueso in BRAZO:
            o = bpy.data.objects.get(_nombre_brazo(hueso, v))
            if o:
                o.hide_render = o.hide_viewport = v != variante


def _es_variante(o):
    return any(o.name.endswith("_" + v) for v in list(VARIANTES)[1:])


def tabla_triangulos(objs):
    """Cuenta un solo brazo: los otros colores son las mismas mallas con otra textura."""
    objs = [o for o in objs if not _es_variante(o)]
    cuenta = B.contar_triangulos(objs)
    por_pieza = {}
    for nombre, n in cuenta.items():
        if nombre != "_total":
            por_pieza[_pieza_de(nombre)] = por_pieza.get(_pieza_de(nombre), 0) + n
    filas = ["| Pieza | Triángulos | Presupuesto | Mallas |", "|---|---|---|---|"]
    for clave, tope in PRESUPUESTO.items():
        mallas = ", ".join(sorted(n.replace(NOMBRE + "_", "") for n in cuenta if n != "_total" and _pieza_de(n) == clave))
        marca = "" if por_pieza.get(clave, 0) <= tope else " ⚠"
        filas.append(f"| {clave} | {M._miles(por_pieza.get(clave, 0))}{marca} | {M._miles(tope)} | {mallas} |")
    filas.append(f"| **Total** | **{M._miles(cuenta['_total'])}** | **{M._miles(sum(PRESUPUESTO.values()))}** | |")
    mayor = max((n for k, n in cuenta.items() if k != "_total"), default=0)
    filas += ["", f"Malla más pesada: {M._miles(mayor)} triángulos (Roblox acepta hasta 20.000 por malla)."]
    texto = "\n".join(filas)
    with open(os.path.join(B.RENDERS, ARCHIVO + "_triangulos.md"), "w", encoding="utf-8") as f:
        f.write("# Matón con implantes: triángulos por pieza\n\n" + texto + "\n")
    return texto


def _renders(prefijo, primeros_planos=True):
    piezas = piezas_todas()
    resto = [o for o in piezas if _pieza_de(o.name) != "Brazo"]
    vistas = []
    for v in VARIANTES:
        mostrar_variante(v)
        brazo_v = [bpy.data.objects[_nombre_brazo(h, v)] for h in BRAZO]
        sufijo = "" if v == "Acero" else "_" + v.lower()
        vistas.append(B.render_vistas(prefijo + sufijo, B.partes() + resto + brazo_v))
        if primeros_planos:
            B.render_primer_plano(f"{prefijo}_brazo{sufijo}", brazo_v + [B.parte(h) for h in BRAZO], giro=70, altura=8, margen=1.1)
    mostrar_variante("Acero")
    B.hoja([[r] for r in vistas], os.path.join(B.RENDERS, f"{prefijo}_variantes.png"), reducir=2)
    if primeros_planos:
        cara = [o for o in resto if _pieza_de(o.name) in ("Ojo", "Gorro", "Panuelo")] + [B.parte("Head")]
        B.render_primer_plano(f"{prefijo}_ojo", cara, giro=-25, altura=8, margen=1.3)


def armar(detalle):
    bpy.ops.wm.open_mainfile(filepath=B.KIT)
    B.configurar_luz()
    cuerpo_maton()
    brazo(detalle)
    ojo(detalle)


def boceto():
    armar(False)
    variantes_brazo()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas_todas()))
    _renders(ARCHIVO + "_boceto", primeros_planos=False)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)


def prueba():
    armar(True)
    variantes_brazo()
    print(tabla_triangulos(piezas_todas()))
    _renders("_" + ARCHIVO + "_prueba")


def detalle():
    import detalle as D

    armar(True)
    piezas = piezas_todas()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    grupos = {clave: (tope, [o.name for o in piezas if _pieza_de(o.name) == clave]) for clave, tope in PRESUPUESTO.items()}
    D.terminar(piezas, grupos, ARCHIVO, lados={o.name: 512 for o in piezas})  # enemigo común: 512 px
    # El brazo de óxido y el de bronce son las mismas mallas horneadas con otro metal.
    D.preparar_cycles()
    for i, o in enumerate(variantes_brazo()):
        receta = D.RECETAS.get(VARIANTES[o.name.split("_")[-1]], {})
        D.hornear(o, D.copia_alta(o, receta), ARCHIVO, 512, semilla=100 + i, receta=receta)
    motores = {m.identifier for m in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in motores else "BLENDER_EEVEE"
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)
    print(tabla_triangulos(piezas_todas()))
    _renders(ARCHIVO)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND)


def exportar():
    """Un FBX por malla en exports/enemigo-maton-implantes/ (el brazo, una vez por color)."""
    bpy.ops.wm.open_mainfile(filepath=BLEND)
    for o in piezas_todas():
        o.hide_render = o.hide_viewport = False
    rutas = B.exportar_piezas(ARCHIVO, piezas_todas())
    print("Exportadas:", len(rutas))
    return rutas


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    for paso in ("boceto", "prueba", "detalle", "exportar"):
        if paso in argumentos:
            globals()[paso]()
