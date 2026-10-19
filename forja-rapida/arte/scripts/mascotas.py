"""Las 8 mascotas de Forja Rápida (GameConfig.Mascotas), en estilo vóxel y animadas.

Cada mascota es un Empty "Mascota_<Id>" con piezas hijas (cuerpo, cabeza, patas, cola, alas...).
Cada pieza tiene su pivote en la articulación, así la animación solo gira o mueve piezas
enteras (como en Roblox con Motor6D). Una sola acción en bucle por mascota, "Idle": camina en
el lugar, mueve la cola, aletea o gira según el bicho (32 cuadros a 24 fps, 1,33 s).

Exporta a forja-rapida/arte/:
  glb/Mascota_<Id>.glb  con la animación (para el visor y para revisar)
  fbx/Mascota_<Id>.fbx  con la animación (para importar en Studio)
  renders/Mascota_<Id>.png  (si no se pasa --sin-renders)

Cómo correrlo (desde la raíz del repositorio; no toca la escena abierta en Blender):
  blender --background --factory-startup --python forja-rapida/arte/scripts/mascotas.py
  Agregar "-- --sin-renders" para no hacer las imágenes.

Escala: 1 vóxel = 0,5 stud (1 stud = 0,28 m). Pivote en la base, frente hacia -Y de Blender
(sale hacia +Z en glTF y hacia -Z en Roblox). Un material por color.
Colores: los de GameConfig.Mascotas.Lista (cuerpo, detalle) más negro de ojos y blanco.
"""

import math
import sys
from pathlib import Path

import bpy

import bmesh
from mathutils import Matrix, Vector

ARTE = Path(__file__).resolve().parents[1]
GLB = ARTE / "glb"
FBX = ARTE / "fbx"
RENDERS = ARTE / "renders"
STUD = 0.28
V = 0.5 * STUD  # metros por vóxel
CUADROS = 32
FPS = 24

OJO = "#15131C"
BLANCO = "#FFFFFF"


def hex_a_rgb(h):
    h = h.lstrip("#")
    return tuple(((int(h[i : i + 2], 16) / 255) ** 2.2) for i in (0, 2, 4))


_materiales = {}


def material(color, brillo=0.0):
    clave = (color, brillo)
    if clave in _materiales:
        return _materiales[clave]
    m = bpy.data.materials.new(f"M_{color.lstrip('#')}{'_brillo' if brillo else ''}")
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    rgb = (*hex_a_rgb(color), 1)
    bsdf.inputs["Base Color"].default_value = rgb
    bsdf.inputs["Roughness"].default_value = 0.7
    if brillo:
        bsdf.inputs["Emission Color"].default_value = rgb
        bsdf.inputs["Emission Strength"].default_value = brillo
    _materiales[clave] = m
    return m


def pieza(nombre, padre, pivote, cajas):
    """cajas: lista de (x, y, z, ancho, largo, alto, color[, brillo]) en vóxeles, relativas
    al pivote (x, y, z = esquina de abajo, al centro en x/y si se usa c())."""
    bm = bmesh.new()
    mats = []
    for caja in cajas:
        x, y, z, sx, sy, sz, color = caja[:7]
        brillo = caja[7] if len(caja) > 7 else 0.0
        mat = material(color, brillo)
        if mat not in mats:
            mats.append(mat)
        indice = mats.index(mat)
        centro = Vector((x + sx / 2, y + sy / 2, z + sz / 2)) * V
        escala = Matrix.Diagonal((sx * V, sy * V, sz * V, 1))
        res = bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Translation(centro) @ escala)
        for v in res["verts"]:
            for f in v.link_faces:
                f.material_index = indice
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    for m in mats:
        malla.materials.append(m)
    obj = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = padre
    obj.location = Vector(pivote) * V
    obj.rotation_mode = "XYZ"
    return obj


def c(cx, cy, z, sx, sy, sz, color, brillo=0.0):
    """Caja centrada en (cx, cy) en x/y, apoyada en z."""
    return (cx - sx / 2, cy - sy / 2, z, sx, sy, sz, color, brillo)


# ---------------------------------------------------------------------------------------------
# Animación: claves de seno en bucle (el primer y el último cuadro coinciden)


def onda(obj, canal, eje, amplitud, fase=0.0, veces=1, base=None):
    datos = getattr(obj, canal)
    inicio = datos[eje] if base is None else base
    for f in range(0, CUADROS + 1, 2):
        t = f / CUADROS
        datos[eje] = inicio + amplitud * math.sin(2 * math.pi * (t * veces + fase))
        obj.keyframe_insert(canal, index=eje, frame=f + 1)
    datos[eje] = inicio


def patas_caminando(patas, grados=25):
    # en diagonal, como un perro: delantera izq con trasera der
    for i, p in enumerate(patas):
        onda(p, "rotation_euler", 0, math.radians(grados), fase=0.5 * (i % 2))


def rebote(raiz, alto=0.35, veces=2):
    z = raiz.location.z
    for f in range(0, CUADROS + 1, 2):
        t = f / CUADROS
        raiz.location.z = z + alto * V * abs(math.sin(math.pi * t * veces))
        raiz.keyframe_insert("location", index=2, frame=f + 1)
    raiz.location.z = z


# ---------------------------------------------------------------------------------------------
# Las mascotas


def raiz(nombre):
    vacio = bpy.data.objects.new(f"Mascota_{nombre}", None)
    bpy.context.scene.collection.objects.link(vacio)
    cuerpo = bpy.data.objects.new(f"{nombre}_Rebote", None)  # lo que rebota, debajo de la raíz
    bpy.context.scene.collection.objects.link(cuerpo)
    cuerpo.parent = vacio
    return vacio, cuerpo


def cuadrupedo(nombre, c1, c2, *, largo=6, ancho=4, alto=3, pata=2, cabeza=4, orejas="punta",
               cola="larga", hocico=None, nariz=None, ojos_brillan=False, cola_punta=None):
    vacio, reb = raiz(nombre)
    z0 = pata
    cuerpo = pieza(f"{nombre}_Cuerpo", reb, (0, 0, z0), [
        c(0, 0, 0, ancho, largo, alto, c1),
        c(0, -largo / 2 + 1.2, 0.01, ancho - 1.2, 2, alto * 0.6, c2),  # pecho
    ])
    # cabeza adelante (-Y)
    cy = -largo / 2 - cabeza / 2 + 1
    cajas = [c(0, 0, 0, cabeza + 0.4, cabeza, cabeza, c1)]
    ojo = OJO if not ojos_brillan else c2
    brillo = 3.0 if ojos_brillan else 0.0
    cajas += [
        c(-1, -cabeza / 2 - 0.05, cabeza * 0.45, 0.8, 0.2, 1, ojo, brillo),
        c(1, -cabeza / 2 - 0.05, cabeza * 0.45, 0.8, 0.2, 1, ojo, brillo),
    ]
    if hocico:
        cajas.append(c(0, -cabeza / 2 - 0.6, 0.3, 2, 1.4, 1.4, hocico))
    if nariz:
        cajas.append(c(0, -cabeza / 2 - (1.4 if hocico else 0.3), 1.2 if hocico else 1.2, 1, 0.6, 0.8, nariz))
    if orejas == "punta":
        cajas += [c(-1.3, 0.3, cabeza, 1.2, 1, 1.6, c1), c(1.3, 0.3, cabeza, 1.2, 1, 1.6, c1),
                  c(-1.3, 0.0, cabeza, 0.6, 0.4, 1.0, c2), c(1.3, 0.0, cabeza, 0.6, 0.4, 1.0, c2)]
    elif orejas == "redonda":
        cajas += [c(-1.4, 0.3, cabeza - 0.3, 1.2, 0.8, 1, c2), c(1.4, 0.3, cabeza - 0.3, 1.2, 0.8, 1, c2)]
    cab = pieza(f"{nombre}_Cabeza", reb, (0, cy, z0 + alto * 0.55), cajas)
    patas = []
    for i, (px, py) in enumerate([(-1, -1), (1, 1), (1, -1), (-1, 1)]):
        x = px * (ancho / 2 - 0.7)
        y = py * (largo / 2 - 0.9)
        patas.append(pieza(f"{nombre}_Pata{i + 1}", vacio, (x, y, pata), [
            c(0, 0, -pata, 1.2, 1.2, pata, c1),
            c(0, -0.1, -pata, 1.3, 1.4, 0.5, c2),
        ]))
    piezas_cola = None
    if cola:
        punta = cola_punta or c2
        if cola == "larga":
            cajas_cola = [c(0, 1.5, 0, 1.4, 3, 1.4, c1), c(0, 3.4, 0.2, 1.6, 1.2, 1.6, punta, 2.0 if cola_punta else 0)]
        else:
            cajas_cola = [c(0, 0.6, 0, 1, 1.2, 1, c1)]
        piezas_cola = pieza(f"{nombre}_Cola", reb, (0, largo / 2, z0 + alto - 1.4), cajas_cola)
        piezas_cola.rotation_euler.x = math.radians(25)
    # animación
    rebote(reb, 0.25)
    patas_caminando(patas)
    onda(cab, "rotation_euler", 0, math.radians(6), veces=2)
    onda(cab, "rotation_euler", 2, math.radians(8), fase=0.25)
    if piezas_cola:
        onda(piezas_cola, "rotation_euler", 2, math.radians(30), veces=2)
    del cuerpo
    return vacio


def topito(c1, c2):
    return cuadrupedo("Topito", c1, c2, largo=6, ancho=5, alto=3.5, pata=1, cabeza=3.5,
                      orejas=None, cola="corta", hocico=c1, nariz=c2)


def chispa(c1, c2):
    return cuadrupedo("Chispa", c1, c2, largo=6, ancho=3.4, alto=2.6, pata=2.2, cabeza=3.4,
                      orejas="punta", cola="larga", hocico=c2, nariz=OJO)


def nebula(c1, c2):
    return cuadrupedo("Nebula", c1, c2, largo=5.5, ancho=3.2, alto=2.6, pata=2, cabeza=3.4,
                      orejas="punta", cola="larga", ojos_brillan=True, cola_punta=c2)


def musgo(c1, c2):
    # tortuga: caparazón (c2) arriba, cabeza y patas verdes
    vacio, reb = raiz("Musgo")
    cuerpo = pieza("Musgo_Cuerpo", reb, (0, 0, 1.2), [
        c(0, 0, 0, 5, 6, 1, c1),
        c(0, 0, 0.8, 5.6, 6.4, 1.6, c2),
        c(0, 0, 2.3, 4, 4.6, 1.2, c2),
        c(-1, -1, 3.4, 1.2, 1.2, 0.6, c1),  # musguito arriba
        c(1, 1, 3.4, 1.4, 1.2, 0.6, c1),
    ])
    cab = pieza("Musgo_Cabeza", reb, (0, -3.2, 1.6), [
        c(0, -1, 0, 2.4, 2.6, 2.2, c1),
        c(-0.7, -2.35, 1.1, 0.6, 0.2, 0.7, OJO),
        c(0.7, -2.35, 1.1, 0.6, 0.2, 0.7, OJO),
    ])
    patas = []
    for i, (px, py) in enumerate([(-1, -1), (1, 1), (1, -1), (-1, 1)]):
        patas.append(pieza(f"Musgo_Pata{i + 1}", vacio, (px * 2.4, py * 2.2, 1.4), [
            c(0, 0, -1.4, 1.4, 1.4, 1.6, c1)]))
    rebote(reb, 0.15)
    patas_caminando(patas, 18)
    onda(cab, "location", 1, -0.5 * V, base=cab.location.y)  # saca y mete la cabeza
    onda(cab, "rotation_euler", 2, math.radians(10), fase=0.25)
    del cuerpo
    return vacio


def piedrin(c1, c2):
    # gólem bípedo con cristales que brillan
    vacio, reb = raiz("Piedrin")
    torso = pieza("Piedrin_Torso", reb, (0, 0, 2.5), [
        c(0, 0, 0, 5, 3.4, 4, c1),
        c(0, 1.7, 2, 1, 0.8, 1.6, c2, 3.0),
        c(-1.4, 1.6, 2.8, 0.8, 0.8, 1.2, c2, 3.0),
        c(1.2, 1.6, 1.0, 0.8, 0.8, 1.0, c2, 3.0),
    ])
    cab = pieza("Piedrin_Cabeza", reb, (0, -0.2, 6.5), [
        c(0, 0, 0, 3.2, 3, 2.6, c1),
        c(-0.8, -1.55, 1.1, 0.8, 0.2, 0.6, c2, 4.0),
        c(0.8, -1.55, 1.1, 0.8, 0.2, 0.6, c2, 4.0),
    ])
    brazos = [
        pieza(f"Piedrin_Brazo{i + 1}", reb, (s * 3.1, 0, 6), [c(0, 0, -3.6, 1.6, 1.8, 3.6, c1),
                                                             c(0, 0, -4.4, 2, 2.2, 1.2, c1)])
        for i, s in enumerate((-1, 1))
    ]
    piernas = [
        pieza(f"Piedrin_Pierna{i + 1}", vacio, (s * 1.3, 0, 2.5), [c(0, 0, -2.5, 1.8, 2, 2.5, c1)])
        for i, s in enumerate((-1, 1))
    ]
    rebote(reb, 0.3)
    for i, b in enumerate(brazos):
        onda(b, "rotation_euler", 0, math.radians(30), fase=0.5 * i)
    for i, p in enumerate(piernas):
        onda(p, "rotation_euler", 0, math.radians(22), fase=0.5 * (1 - i))
    onda(cab, "rotation_euler", 2, math.radians(10), fase=0.25)
    del torso
    return vacio


def glaciel(c1, c2):
    # pingüino: cuerpo oscuro, panza blanca, pico y patas naranjas, aletas
    naranja = "#FFA51F"
    vacio, reb = raiz("Glaciel")
    pieza("Glaciel_Cuerpo", reb, (0, 0, 0.6), [
        c(0, 0, 0, 4, 3.6, 5, c1),
        c(0, -1.75, 0.3, 3, 0.3, 3.8, c2),
    ])
    cab = pieza("Glaciel_Cabeza", reb, (0, 0, 5.6), [
        c(0, 0, 0, 3.4, 3.2, 2.6, c1),
        c(-0.8, -1.65, 1.1, 0.7, 0.2, 0.7, OJO),
        c(0.8, -1.65, 1.1, 0.7, 0.2, 0.7, OJO),
        c(-0.8, -1.62, 1.0, 1.1, 0.15, 1.1, c2),
        c(0.8, -1.62, 1.0, 1.1, 0.15, 1.1, c2),
        c(0, -2.0, 0.5, 1.2, 1, 0.7, naranja),
    ])
    aletas = [
        pieza(f"Glaciel_Aleta{i + 1}", reb, (s * 2.1, 0, 4.6), [c(s * 0.3, 0, -3, 0.6, 2.2, 3, c1)])
        for i, s in enumerate((-1, 1))
    ]
    patas = [
        pieza(f"Glaciel_Pata{i + 1}", vacio, (s * 1, -0.6, 0.6), [c(0, -0.4, -0.6, 1.4, 2, 0.6, naranja)])
        for i, s in enumerate((-1, 1))
    ]
    rebote(reb, 0.3)
    onda(reb, "rotation_euler", 1, math.radians(7))  # se bambolea de costado
    for i, a in enumerate(aletas):
        onda(a, "rotation_euler", 1, math.radians(25) * (1 if i else -1), veces=2)
    for i, p in enumerate(patas):
        onda(p, "rotation_euler", 0, math.radians(15), fase=0.5 * i)
    onda(cab, "rotation_euler", 0, math.radians(5), veces=2)
    return vacio


def magmo(c1, c2):
    vacio = cuadrupedo("Magmo", c1, c2, largo=6.4, ancho=3.6, alto=3, pata=2, cabeza=3.6,
                       orejas=None, cola="larga", hocico=c1, cola_punta=c2)
    reb = bpy.data.objects["Magmo_Rebote"]
    # cuernos
    pieza("Magmo_Cuernos", bpy.data.objects["Magmo_Cabeza"], (0, 0.6, 3.6), [
        c(-1.1, 0, 0, 0.7, 0.7, 1.4, c2), c(1.1, 0, 0, 0.7, 0.7, 1.4, c2)])
    # púas en el lomo
    pieza("Magmo_Puas", bpy.data.objects["Magmo_Cuerpo"], (0, 0, 3), [
        c(0, -1.5, 0, 0.8, 1, 0.8, c2), c(0, 0, 0, 0.8, 1, 1.0, c2), c(0, 1.5, 0, 0.8, 1, 0.8, c2)])
    alas = []
    for i, s in enumerate((-1, 1)):
        a = pieza(f"Magmo_Ala{i + 1}", reb, (s * 1.8, -0.5, 4.6), [
            c(s * 1.6, 0, 0, 3.2, 2.6, 0.4, c1),
            c(s * 3.6, 0.6, 0, 1.6, 1.6, 0.4, c2),
        ])
        alas.append(a)
        onda(a, "rotation_euler", 1, math.radians(35) * s, veces=2)
    return vacio


def cuarcito(c1, c2):
    # cristal flotante con carita: gira y flota
    vacio, reb = raiz("Cuarcito")
    reb.location.z = 1.5 * V
    cristal = pieza("Cuarcito_Cristal", reb, (0, 0, 0), [
        c(0, 0, 0, 1.6, 1.6, 1, c1, 0.8),
        c(0, 0, 1, 3.2, 3.2, 3, c1, 0.8),
        c(0, 0, 4, 2.2, 2.2, 1.4, c1, 0.8),
        c(0, 0, 5.4, 1, 1, 1, c2, 2.0),
        c(-0.7, -1.65, 2.6, 0.6, 0.15, 0.8, OJO),
        c(0.7, -1.65, 2.6, 0.6, 0.15, 0.8, OJO),
    ])
    trozos = pieza("Cuarcito_Orbita", reb, (0, 0, 2.5), [
        c(2.8, 0, 0, 0.8, 0.8, 0.8, c2, 2.0),
        c(-2.8, 0, 0.6, 0.6, 0.6, 0.6, c1, 1.0),
        c(0, 2.8, -0.4, 0.7, 0.7, 0.7, c1, 1.0),
    ])
    sombra = pieza("Cuarcito_Sombra", vacio, (0, 0, 0), [c(0, 0, 0, 2.4, 2.4, 0.1, "#3A2A55")])
    onda(reb, "location", 2, 0.5 * V, base=reb.location.z)
    onda(cristal, "rotation_euler", 2, math.radians(12))
    for f in range(0, CUADROS + 1, 2):  # la órbita da una vuelta entera
        trozos.rotation_euler.z = 2 * math.pi * f / CUADROS
        trozos.keyframe_insert("rotation_euler", index=2, frame=f + 1)
    trozos.rotation_euler.z = 0
    for f in range(0, CUADROS + 1, 2):
        s = 1 - 0.15 * math.sin(2 * math.pi * f / CUADROS)
        sombra.scale = (s, s, 1)
        sombra.keyframe_insert("scale", frame=f + 1)
    return vacio


# Id, armado y colores (los de GameConfig.Mascotas.Lista)
MASCOTAS = [
    ("Topito", topito, "#8A5A2B", "#FFB3C7"),
    ("Piedrin", piedrin, "#8D939C", "#7CF5FF"),
    ("Chispa", chispa, "#FF8C42", "#FFF3E0"),
    ("Musgo", musgo, "#5E8C4A", "#B07A4A"),
    ("Cuarcito", cuarcito, "#C77DFF", "#FFFFFF"),
    ("Glaciel", glaciel, "#2F5D8A", "#E8F4FF"),
    ("Magmo", magmo, "#FF3B1F", "#FFE14D"),
    ("Nebula", nebula, "#4B2A6B", "#7CF5FF"),
]


def limpiar():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _materiales.clear()
    escena = bpy.context.scene
    escena.render.fps = FPS
    escena.frame_start = 1
    escena.frame_end = CUADROS


def lineal(vacio):
    """Interpolación lineal y una sola acción por objeto, con el nombre de la mascota."""
    for obj in [vacio, *vacio.children_recursive]:
        ad = obj.animation_data
        if ad and ad.action:
            ad.action.name = f"{obj.name}_Idle"
            for capa in getattr(ad.action, "layers", []):
                for tira in capa.strips:
                    for bolsa in tira.channelbags:
                        for curva in bolsa.fcurves:
                            for k in curva.keyframe_points:
                                k.interpolation = "LINEAR"
            for curva in getattr(ad.action, "fcurves", []):
                for k in curva.keyframe_points:
                    k.interpolation = "LINEAR"


def seleccionar(vacio):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in [vacio, *vacio.children_recursive]:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = vacio


def exportar(nombre, vacio):
    seleccionar(vacio)
    bpy.ops.export_scene.gltf(
        filepath=str(GLB / f"Mascota_{nombre}.glb"),
        export_format="GLB",
        use_selection=True,
        export_animations=True,
        export_animation_mode="SCENE",
        export_force_sampling=True,
        export_frame_range=True,
        export_apply=True,
    )
    seleccionar(vacio)
    bpy.ops.export_scene.fbx(
        filepath=str(FBX / f"Mascota_{nombre}.fbx"),
        use_selection=True,
        object_types={"EMPTY", "MESH"},
        bake_anim=True,
        bake_anim_use_all_actions=False,
        bake_anim_use_nla_strips=False,
        axis_forward="Z",
        axis_up="Y",
    )


def render(nombre, vacio):
    escena = bpy.context.scene
    mundo = bpy.data.worlds.new("Cielo")
    mundo.use_nodes = True
    mundo.node_tree.nodes["Background"].inputs["Color"].default_value = (*hex_a_rgb("#55B8FF"), 1)
    mundo.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.8
    escena.world = mundo
    bpy.ops.mesh.primitive_plane_add(size=40 * V)
    bpy.context.object.data.materials.append(material("#7ED957"))
    sol = bpy.data.objects.new("Sol", bpy.data.lights.new("Sol", "SUN"))
    sol.data.energy = 3.5
    sol.rotation_euler = (math.radians(50), 0, math.radians(30))
    escena.collection.objects.link(sol)
    cam = bpy.data.objects.new("Camara", bpy.data.cameras.new("Camara"))
    escena.collection.objects.link(cam)
    cam.location = Vector((9, -14, 9)) * V
    direccion = Vector((0, 0, 3)) * V - cam.location
    cam.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 40
    escena.camera = cam
    escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in [
        e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items
    ] else "BLENDER_EEVEE"
    escena.render.resolution_x = escena.render.resolution_y = 512
    escena.frame_set(8)
    escena.render.filepath = str(RENDERS / f"Mascota_{nombre}.png")
    bpy.ops.render.render(write_still=True)


def main():
    sin_renders = "--sin-renders" in sys.argv
    for carpeta in (GLB, FBX, RENDERS):
        carpeta.mkdir(parents=True, exist_ok=True)
    for nombre, armar, c1, c2 in MASCOTAS:
        limpiar()
        vacio = armar(c1, c2)
        lineal(vacio)
        exportar(nombre, vacio)
        if not sin_renders:
            render(nombre, vacio)
        print(f"Mascota lista: {nombre}")


main()
