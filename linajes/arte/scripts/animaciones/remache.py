"""Animaciones de Remache (P28-01), jefe de la Beta, con el motor de base.py.

Uso:
    <blender.exe> -b --factory-startup -P linajes/arte/scripts/animaciones/remache.py -- todo
    (pasos sueltos: acciones, renders, gifs, fbx; después: gifs.py y hoja.py remache)

Usa el esqueleto R15 del modelo, a 1,6x. No pisa remache.blend: guarda en animaciones-remache.blend.
La altura sale de las piernas (postura): los pies quedan en el piso en todas las poses de pie.
Aviso va 12 cuadros antes de cada Impacto. El aviso largo es la pose; Aviso prende la marca roja.
"""

import importlib.util
import math
import os
import sys

_spec = importlib.util.spec_from_file_location("anim_base", os.path.join(os.path.dirname(os.path.abspath(__file__)), "base.py"))
A = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(A)

import bpy  # noqa: E402
from mathutils import Vector  # noqa: E402

con, actuar, pasarse = A.con, A.actuar, A.pasarse
cos, sen, pi = math.cos, math.sin, math.pi

A.CUERPO = os.path.join(A.B.BLENDER, "remache.blend")
A.BLEND = os.path.join(A.B.BLENDER, "animaciones-remache.blend")
A.SALIDA_FBX = os.path.join(A.B.ARTE, "animaciones", "jefe-remache")

MUSLO, CANILLA = 0.48, 0.46  # metros, medidos en el modelo
AJUSTE = 0.03  # las botas bajan apenas más que el pie del maniquí
PESADO = {"raiz": 2, "LowerTorso": 2, "LeftUpperLeg": 2, "RightUpperLeg": 2, "LeftLowerLeg": 2, "RightLowerLeg": 2, "Head": -2}


def postura(izq=(-20, 36), der=(-10, 28), inclina=8, abre=9, giro=0, corre=(0, 0)):
    """Piernas y altura. izq y der son (muslo, rodilla) respecto del mundo, sin importar cuánto se
    incline la cadera. Baja lo justo para que la pierna más larga toque el piso."""
    alto = max(MUSLO * cos(math.radians(a)) + CANILLA * cos(math.radians(a + b)) for a, b in (izq, der))
    (a, b), (c, d) = izq, der
    return {
        "raiz": (corre[0], corre[1], alto - MUSLO - CANILLA + AJUSTE),
        "LowerTorso": (inclina, 0, giro),
        "LeftUpperLeg": (a - inclina, -abre, -giro),
        "RightUpperLeg": (c - inclina, abre, -giro),
        "LeftLowerLeg": (b, 0, 0),
        "RightLowerLeg": (d, 0, 0),
        "LeftFoot": (-(a + b), 0, 0),
        "RightFoot": (-(c + d), 0, 0),
    }


G = {
    **postura(),
    "UpperTorso": (8, 0, 0),
    "Head": (2, 0, 0),
    "LeftUpperArm": (-14, -24, 0),
    "RightUpperArm": (-14, 24, 0),
    "LeftLowerArm": (-46, 0, 0),
    "RightLowerArm": (-46, 0, 0),
}
ARRIBA = {"LeftUpperArm": (-168, 24, 0), "RightUpperArm": (-168, -24, 0), "LeftLowerArm": (-40, 0, 0), "RightLowerArm": (-40, 0, 0)}
ABAJO = {"LeftUpperArm": (-58, -8, 0), "RightUpperArm": (-58, 8, 0), "LeftLowerArm": (-6, 0, 0), "RightLowerArm": (-6, 0, 0)}


def quieto(t):
    # Amenaza: respira hondo, abre y cierra los brazos, mira de un lado al otro.
    r, m = cos(2 * pi * t), cos(2 * pi * t + pi / 2)
    return con(
        G,
        UpperTorso=(8 - 3 * r, 0, 3 * m),
        Head=(2 + 2 * r, 0, 16 * m),
        LeftUpperArm=(-14, -24 - 5 * r, 0),
        RightUpperArm=(-14, 24 + 5 * r, 0),
        LeftLowerArm=(-46 - 8 * r, 0, 0),
        RightLowerArm=(-46 - 8 * r, 0, 0),
    )


def caminar(t):
    # Paso pesado: la cadera cae en cada apoyo y los hombros pesan del lado contrario.
    s = sen(2 * pi * t)
    ri = max(cos(2 * pi * t), 0)
    rd = max(-cos(2 * pi * t), 0)
    p = postura(izq=(-16 - 24 * s, 16 + 42 * ri), der=(-16 + 24 * s, 16 + 42 * rd), inclina=10, corre=(0.05 * s, 0))
    return {
        **G,
        **p,
        "UpperTorso": (8, 4 * s, 9 * s),
        "Head": (2, -3 * s, -6 * s),
        "LeftUpperArm": (-14 + 20 * s, -24, 0),
        "RightUpperArm": (-14 - 20 * s, 24, 0),
    }


def recibir_golpe(t):
    pega = {**G, **postura(izq=(-10, 30), der=(-30, 38), inclina=-8, corre=(0, 0.1)), "UpperTorso": (-12, 0, -10), "Head": (-16, 0, 8), "LeftUpperArm": (-30, -40, 0), "RightUpperArm": (-30, 40, 0)}
    return actuar(t, 20, [(0, G), (4, pega, "seco"), (8, pega), (20, G)], {})


def aturdido(t):
    # Doblado, cabeza colgando y brazos muertos, balanceándose.
    b, c = cos(2 * pi * t), cos(4 * pi * t)
    return {
        **G,
        **postura(izq=(-30, 50), der=(-24, 46), inclina=24 + 2 * c, giro=4 * b),
        "UpperTorso": (20 + 3 * c, 5 * b, 0),
        "Head": (24, 10 * b, 0),
        "LeftUpperArm": (-8 + 4 * b, -10, 0),
        "RightUpperArm": (-8 - 4 * b, 10, 0),
        "LeftLowerArm": (-12, 0, 0),
        "RightLowerArm": (-12, 0, 0),
    }


def entrada(t):
    # Sale caminando, se planta, levanta los puños (45) y los choca contra el pecho (60, Impacto).
    planta = {**G, **postura(izq=(-26, 46), der=(-26, 46), abre=14)}
    arriba = {**planta, **ARRIBA, "UpperTorso": (-8, 0, 0), "Head": (-14, 0, 0)}
    choca = {
        **planta,
        "UpperTorso": (14, 0, 0),
        "Head": (8, 0, 0),
        "LeftUpperArm": (-58, 34, -30),
        "RightUpperArm": (-58, -34, 30),
        "LeftLowerArm": (-100, 0, 0),
        "RightLowerArm": (-100, 0, 0),
    }
    return actuar(t, 90, [(0, caminar(0.0)), (18, caminar(0.5)), (30, planta, "sale"), (45, arriba, "sale"), (52, arriba), (60, choca, "seco"), (74, choca), (90, G)], PESADO)


def martillazo(t):
    # Levanta los dos puños y aguanta (Aviso 18), golpe al piso (Impacto 30).
    sube = {**G, **postura(izq=(-16, 28), der=(-10, 22), inclina=-4, abre=12), **ARRIBA, "UpperTorso": (-10, 0, 0), "Head": (-14, 0, 0)}
    pega = {**G, **postura(izq=(-54, 88), der=(-34, 76), inclina=36, abre=12), **ABAJO, "UpperTorso": (20, 0, 0), "Head": (-30, 0, 0)}
    return actuar(t, 60, [(0, G), (16, sube, "sale"), (26, pasarse(G, sube, 0.05)), (30, pega, "seco"), (42, pega), (60, G)], PESADO)


TORO = {
    "UpperTorso": (18, 0, 0),
    "Head": (-24, 0, 0),
    "LeftUpperArm": (-72, -10, 0),
    "RightUpperArm": (-72, 10, 0),
    "LeftLowerArm": (-30, 0, 0),
    "RightLowerArm": (-30, 0, 0),
}


def carga_carrera(t):
    s = sen(2 * pi * t)
    ri = max(cos(2 * pi * t), 0)
    rd = max(-cos(2 * pi * t), 0)
    return {**G, **postura(izq=(-34 - 34 * s, 40 + 52 * ri), der=(-34 + 34 * s, 40 + 52 * rd), inclina=26), **TORO, "UpperTorso": (18, 0, 8 * s)}


def carga_inicio(t):
    # Los brazos se comprimen hacia atrás como pistones (Aviso 18) y sale disparado.
    comprime = {
        **G,
        **postura(izq=(-40, 66), der=(-8, 42), inclina=20),
        "UpperTorso": (10, 0, 0),
        "Head": (-16, 0, 0),
        "LeftUpperArm": (34, -18, 0),
        "RightUpperArm": (34, 18, 0),
        "LeftLowerArm": (-112, 0, 0),
        "RightLowerArm": (-112, 0, 0),
    }
    return actuar(t, 30, [(0, G), (14, comprime, "sale"), (24, pasarse(G, comprime, 0.05)), (30, carga_carrera(0.0), "seco")], PESADO)


def carga_frenada(t):
    # Clava los pies y queda expuesto un momento (Impacto 3).
    frena = {**G, **postura(izq=(-58, 50), der=(14, 44), inclina=-2), "UpperTorso": (-8, 0, 0), "Head": (-4, 0, 0)}
    agotado = {**G, **postura(izq=(-34, 58), der=(-20, 50), inclina=26), "UpperTorso": (18, 0, 0), "Head": (18, 0, 0), "LeftLowerArm": (-14, 0, 0), "RightLowerArm": (-14, 0, 0)}
    return actuar(t, 45, [(0, carga_carrera(0.0)), (6, frena, "seco"), (14, agotado, "sale"), (32, agotado), (45, G)], PESADO)


def contenedor(t):
    # Agarra del piso (16), levanta hasta el cuadro 40 y lo tira (Aviso 44, Impacto 56).
    agarra = {**G, **postura(izq=(-62, 96), der=(-56, 92), inclina=30, abre=14), **ABAJO, "UpperTorso": (18, 0, 0), "Head": (-24, 0, 0)}
    arriba = {**G, **postura(izq=(-20, 34), der=(-12, 26), inclina=-4, abre=14), **ARRIBA, "UpperTorso": (-8, 0, 0), "Head": (-10, 0, 0)}
    atras = con(arriba, UpperTorso=(-18, 0, 0), Head=(-4, 0, 0), LeftUpperArm=(-186, 22, 0), RightUpperArm=(-186, -22, 0))
    tira = {
        **G,
        **postura(izq=(-44, 64), der=(6, 34), inclina=20, abre=14),
        "UpperTorso": (20, 0, 0),
        "Head": (-20, 0, 0),
        "LeftUpperArm": (-112, 10, 0),
        "RightUpperArm": (-112, -10, 0),
        "LeftLowerArm": (-8, 0, 0),
        "RightLowerArm": (-8, 0, 0),
    }
    return actuar(t, 80, [(0, G), (16, agarra, "sale"), (22, agarra), (40, arriba, "suave"), (50, atras, "sale"), (56, tira, "seco"), (64, tira), (80, G)], PESADO)


def cambio_fase(t):
    # Se clava la jeringa del pecho (Inyecta 20), se estremece y abre los brazos (Vapor 38).
    inyecta = {
        **G,
        **postura(izq=(-30, 52), der=(-24, 48), inclina=22),
        "UpperTorso": (18, 0, 0),
        "Head": (18, 0, 0),
        "RightUpperArm": (-52, -32, 30),
        "RightLowerArm": (-112, 0, 0),
        "LeftUpperArm": (-24, -18, 0),
    }
    temblor = con(inyecta, UpperTorso=(14, 3, 0), Head=(10, -4, 0), LeftUpperArm=(-20, -24, 0))
    grita = {**G, **postura(izq=(-22, 40), der=(-16, 34), inclina=-6, abre=14), "UpperTorso": (-14, 0, 0), "Head": (-24, 0, 0), "LeftUpperArm": (-40, -72, 0), "RightUpperArm": (-40, 72, 0), "LeftLowerArm": (-70, 0, 0), "RightLowerArm": (-70, 0, 0)}
    return actuar(t, 60, [(0, G), (14, inyecta, "sale"), (20, inyecta), (24, temblor), (28, inyecta), (32, temblor), (38, grita, "seco"), (50, grita), (60, G)], {})


def derrota(t):
    # Tambalea, cae de rodillas (40) y se desploma hacia adelante (75).
    tambalea = {**G, **postura(izq=(-34, 52), der=(-12, 40), inclina=16, giro=10), "UpperTorso": (10, 8, 0), "Head": (18, 8, 0), "LeftLowerArm": (-14, 0, 0), "RightLowerArm": (-14, 0, 0)}
    rodillas = {
        "raiz": (0, 0, -0.44),
        "LowerTorso": (10, 0, 0),
        "UpperTorso": (16, 0, 0),
        "Head": (22, 0, 0),
        "LeftUpperArm": (-6, -12, 0),
        "RightUpperArm": (-6, 12, 0),
        "LeftLowerArm": (-10, 0, 0),
        "RightLowerArm": (-10, 0, 0),
        "LeftUpperLeg": (-10, -9, 0),
        "RightUpperLeg": (-10, 9, 0),
        "LeftLowerLeg": (90, 0, 0),
        "RightLowerLeg": (90, 0, 0),
        "LeftFoot": (30, 0, 0),
        "RightFoot": (30, 0, 0),
    }
    cae = con(rodillas, raiz=(0, -0.2, -0.42), LowerTorso=(58, 0, 0), UpperTorso=(6, 0, 0), Head=(-12, 0, 18), LeftUpperLeg=(-66, -9, 0), RightUpperLeg=(-66, 9, 0), LeftUpperArm=(-34, -36, 0), RightUpperArm=(-34, 36, 0))
    return actuar(t, 90, [(0, G), (18, tambalea, "sale"), (30, tambalea), (40, rodillas, "seco"), (58, rodillas), (75, cae, "seco"), (90, cae)], PESADO)


NUEVAS = {
    "remache-entrada": (entrada, 90, False, "Action", (30, 45, 60)),
    "remache-quieto": (quieto, 60, True, "Idle", (0, 15, 30)),
    "remache-caminar": (caminar, 40, True, "Movement", (0, 10, 20)),
    "remache-recibir-golpe": (recibir_golpe, 20, False, "Action", (0, 4, 12)),
    "remache-aturdido": (aturdido, 40, True, "Action", (0, 10, 20)),
    "remache-cambio-fase": (cambio_fase, 60, False, "Action", (20, 32, 42)),
    "remache-derrota": (derrota, 90, False, "Action", (22, 45, 88)),
    "remache-martillazo": (martillazo, 60, False, "Action", (18, 30, 46)),
    "remache-carga-inicio": (carga_inicio, 30, False, "Action", (14, 24, 30)),
    "remache-carga-carrera": (carga_carrera, 24, True, "Action", (0, 6, 18)),
    "remache-carga-frenada": (carga_frenada, 45, False, "Action", (6, 14, 36)),
    "remache-contenedor": (contenedor, 80, False, "Action", (16, 40, 56)),
}
A.ANIMACIONES = NUEVAS
A.GRUPOS["remache"] = list(NUEVAS)
A.ETIQUETAS.update(
    {
        "remache-entrada": "Entrada",
        "remache-quieto": "Quieto",
        "remache-caminar": "Caminar",
        "remache-recibir-golpe": "Recibir/golpe",
        "remache-aturdido": "Aturdido",
        "remache-cambio-fase": "Cambio/de fase",
        "remache-derrota": "Derrota",
        "remache-martillazo": "Martillazo/doble",
        "remache-carga-inicio": "Carga/inicio",
        "remache-carga-carrera": "Carga/carrera",
        "remache-carga-frenada": "Carga/frenada",
        "remache-contenedor": "Contenedor",
    }
)
A.MARCADORES.update(
    {
        "remache-entrada": [(48, "Aviso"), (60, "Impacto")],
        "remache-caminar": [(10, "Paso"), (30, "Paso")],
        "remache-cambio-fase": [(20, "Inyecta"), (38, "Vapor")],
        "remache-martillazo": [(18, "Aviso"), (30, "Impacto")],
        "remache-carga-inicio": [(18, "Aviso")],
        "remache-carga-carrera": [(6, "Paso"), (18, "Paso")],
        "remache-carga-frenada": [(3, "Impacto")],
        "remache-contenedor": [(44, "Aviso"), (56, "Impacto")],
    }
)
A.GIRO_CAMARA.update({n: 60 for n in NUEVAS})
A.GIF_VISTAS.update({n: {"costado": 90, "atras": 135} for n in NUEVAS})
_lente = A.B.LENTE
A.B.LENTE *= 0.62


def _camara(giro=60):
    datos = bpy.data.cameras.get("CamAnim") or bpy.data.cameras.new("CamAnim")
    datos.lens = A.B.LENTE
    cam = bpy.data.objects.get("CamAnim") or bpy.data.objects.new("CamAnim", datos)
    if cam.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(cam)
    centro = Vector((0, -0.15, 1.2))
    a, e = math.radians(giro), math.radians(8)
    A.B._apuntar(cam, centro + Vector((-sen(a) * cos(e), -cos(a) * cos(e), sen(e))) * 3.3, centro)
    return cam


A._camara = _camara


def medir():
    """Altura de las botas: de pie, tienen que quedar cerca de 0."""
    arm = A.B.esqueleto()
    escena = bpy.context.scene
    botas = [o for o in bpy.data.objects if o.name in ("Remache_BotaIzq", "Remache_BotaDer")]
    piezas = [o for o in bpy.data.objects if o.type == "MESH" and o.visible_get() and o.name.startswith("Remache") and o.parent != arm]
    print("SUELTAS", [o.name for o in piezas][:10])
    for nombre, (_, cuadros, *_r) in NUEVAS.items():
        arm.animation_data.action = bpy.data.actions[nombre]
        z = []
        for f in range(0, cuadros + 1, 3):
            escena.frame_set(f)
            bpy.context.view_layer.update()
            z.append(min((o.matrix_world @ v.co).z for o in botas for v in o.data.vertices))
        print("BOTAS", nombre, round(min(z), 3), round(max(z), 3))


def acciones():
    bpy.ops.wm.open_mainfile(filepath=A.CUERPO)
    escena = bpy.context.scene
    escena.render.fps, escena.render.fps_base = A.FPS, 1
    arm = A.B.esqueleto()
    for nombre in NUEVAS:
        A.crear_accion(arm, nombre)
    arm.animation_data.action = bpy.data.actions["remache-quieto"]
    medir()
    bpy.ops.wm.save_as_mainfile(filepath=A.BLEND)


if __name__ == "__main__":
    pasos = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else ["todo"]
    paso = pasos[0] if pasos else "todo"
    if paso in ("acciones", "todo"):
        acciones()
    if paso in ("renders", "todo"):
        A.renders("remache")
    if paso in ("gifs", "todo"):
        A.cuadros_gif("remache")
    if paso in ("fbx", "todo"):
        A.fbx("remache")
