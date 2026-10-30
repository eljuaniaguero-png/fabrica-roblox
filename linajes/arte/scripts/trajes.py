"""Piezas de traje sobre el maniquí R15 del kit (reglas en linajes/arte/GUIA-ESTILO.md).

Cada pieza es un objeto aparte, llamado <Personaje>_<Pieza>, con un material MAT_ y pegado al
hueso que le corresponde, así sigue al cuerpo en las animaciones y se exporta sola como accesorio:

    casco -> Head          peto -> UpperTorso      hombreras -> Left/RightUpperArm
    guantes -> Left/RightHand    botas -> Left/RightFoot    capa -> UpperTorso

Uso (desde un script de personaje en linajes/arte/scripts/):

    import base as B, trajes as T
    B.cargar_kit()
    piezas = [
        T.casco("Cuervo", "tela-oscura"),
        T.peto("Cuervo", "acero"),
        *T.hombreras("Cuervo", "acero"),
        *T.guantes("Cuervo", "cuero"),
        *T.botas("Cuervo", "cuero"),
        T.capa("Cuervo", "tela-oscura"),
    ]
    print(B.contar_triangulos(piezas))
    B.render_vistas("cuervo", B.partes() + piezas)
    B.exportar_piezas("cuervo", piezas)

Las medidas salen de la caja de cada parte del maniquí: si cambia el maniquí, las piezas se
acomodan solas. Todas las funciones devuelven la malla terminada (sin modificadores pendientes).
"""

import math

import bmesh
import bpy
from mathutils import Matrix, Vector

import base as B

# ---------------------------------------------------------------------------
# Ayudas
# ---------------------------------------------------------------------------


def caja_parte(nombre):
    """(mínimo, máximo, centro, mitades) de la parte del maniquí, en metros."""
    minimo, maximo = B.caja_de([B.parte(nombre)])
    return minimo, maximo, (minimo + maximo) / 2, (maximo - minimo) / 2


def bloque_redondo(bm, centro, mitades, redondez=0.35, segmentos=24, anillos=16):
    """Superelipsoide: una caja con las esquinas redondeadas (redondez 0 = caja, 1 = esfera)."""
    e = max(0.05, redondez)
    hecho = bmesh.ops.create_uvsphere(bm, u_segments=segmentos, v_segments=anillos, radius=1.0)
    for v in hecho["verts"]:
        x, y, z = v.co
        v.co = Vector(
            (
                math.copysign(abs(x) ** e, x) * mitades[0] + centro[0],
                math.copysign(abs(y) ** e, y) * mitades[1] + centro[1],
                math.copysign(abs(z) ** e, z) * mitades[2] + centro[2],
            )
        )
    return hecho["verts"]


def malla(nombre, bm, material, hueso, grosor=0.0, suave=40):
    """Pasa el bmesh a un objeto con su material, le da espesor (si `grosor` > 0, hacia afuera),
    lo pega al hueso y le aplica todo."""
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.get(nombre)
    if obj:  # rehacer una pieza reemplaza la anterior
        bpy.data.objects.remove(obj)
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)
    if grosor > 0:
        mod = obj.modifiers.new("Espesor", "SOLIDIFY")
        mod.thickness = grosor
        mod.offset = 1.0
        _aplicar(obj)
    obj.data.shade_smooth()
    obj.data.set_sharp_from_angle(angle=math.radians(suave))
    B.aplicar_material(obj, material)
    B.pegar_a_hueso(obj, hueso)
    return obj


def _aplicar(obj):
    grafo = bpy.context.evaluated_depsgraph_get()
    grafo.update()
    nueva = bpy.data.meshes.new_from_object(obj.evaluated_get(grafo))
    vieja = obj.data
    obj.modifiers.clear()
    obj.data = nueva
    nombre = vieja.name
    bpy.data.meshes.remove(vieja)
    nueva.name = nombre


def caja(bm, centro, tam, giro=None):
    """Caja de tamaño `tam` centrada en `centro`, girada con la matriz `giro` (3x3 o 4x4)."""
    hecho = bmesh.ops.create_cube(bm, size=1.0)
    m = Matrix.Translation(centro) @ (giro.to_4x4() if giro else Matrix.Identity(4)) @ Matrix.Diagonal((*tam, 1.0))
    bmesh.ops.transform(bm, matrix=m, verts=hecho["verts"])
    return hecho["verts"]


def punta(bm, base, hacia, radio, lados=4):
    """Cono (pirámide si `lados` = 4) con la base centrada en `base` y la punta en `hacia`."""
    base, hacia = Vector(base), Vector(hacia)
    eje = hacia - base
    hecho = bmesh.ops.create_cone(
        bm, cap_ends=True, segments=lados, radius1=radio, radius2=0.0, depth=eje.length
    )
    giro = eje.to_track_quat("Z", "Y").to_matrix().to_4x4()
    m = Matrix.Translation(base + eje / 2) @ giro
    bmesh.ops.transform(bm, matrix=m, verts=hecho["verts"])
    return hecho["verts"]


def pieza(nombre, hueso, capas, suave=40):
    """Pieza armada por capas: `capas` es una lista de (material, función(bm)). Cada capa agrega
    su geometría y queda con su material. Devuelve el objeto pegado al hueso."""
    bm = bmesh.new()
    materiales = []
    for mat, armar in capas:
        antes = set(bm.faces)
        armar(bm)
        if mat not in materiales:
            materiales.append(mat)
        for f in bm.faces:
            if f not in antes:
                f.material_index = materiales.index(mat)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    viejo = bpy.data.objects.get(nombre)
    if viejo:
        bpy.data.objects.remove(viejo)
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)
    for mat in materiales:
        me.materials.append(B.material(mat))
    me.shade_smooth()
    me.set_sharp_from_angle(angle=math.radians(suave))
    B.pegar_a_hueso(obj, hueso)
    return obj


def tubo(bm, camino, radio, lados=8, tapas=True):
    """Tubo que sigue un camino de puntos. `radio` es un número o una lista (uno por punto),
    así se puede afinar (garras, costuras, cables)."""
    pts = [Vector(p) for p in camino]
    radios = radio if isinstance(radio, (list, tuple)) else [radio] * len(pts)
    tangentes = [(pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized() for i in range(len(pts))]
    normal = tangentes[0].orthogonal().normalized()
    aros = []
    for i, p in enumerate(pts):
        t = tangentes[i]
        normal = (normal - t * normal.dot(t)).normalized()
        binormal = t.cross(normal)
        aros.append(
            [
                bm.verts.new(p + (normal * math.cos(2 * math.pi * k / lados) + binormal * math.sin(2 * math.pi * k / lados)) * radios[i])
                for k in range(lados)
            ]
        )
    for a, b in zip(aros, aros[1:]):
        for k in range(lados):
            q = (k + 1) % lados
            bm.faces.new((a[k], a[q], b[q], b[k]))
    if tapas:
        bm.faces.new(list(reversed(aros[0])))
        bm.faces.new(aros[-1])


def cilindro(bm, base, hacia, radio, lados=12, radio_fin=None):
    """Cilindro (o cono truncado) de `base` a `hacia`."""
    base, hacia = Vector(base), Vector(hacia)
    eje = hacia - base
    hecho = bmesh.ops.create_cone(
        bm, cap_ends=True, segments=lados, radius1=radio, radius2=radio if radio_fin is None else radio_fin, depth=eje.length
    )
    m = Matrix.Translation(base + eje / 2) @ eje.to_track_quat("Z", "Y").to_matrix().to_4x4()
    bmesh.ops.transform(bm, matrix=m, verts=hecho["verts"])
    return hecho["verts"]


def remache(bm, centro, radio=0.007, afuera=(0, -1, 0)):
    """Remache o tornillo: media esfera achatada que mira hacia `afuera`."""
    hecho = bmesh.ops.create_uvsphere(bm, u_segments=6, v_segments=4, radius=radio)
    giro = Vector((0, 0, 1)).rotation_difference(Vector(afuera)).to_matrix().to_4x4()
    m = Matrix.Translation(centro) @ giro @ Matrix.Diagonal((1, 1, 0.45, 1))
    bmesh.ops.transform(bm, matrix=m, verts=hecho["verts"])
    return hecho["verts"]


def sobre_superficie(bvh, desde, hacia_adentro, separacion=0.0):
    """Punto y normal de la superficie que encuentra un rayo (para pegar detalles encima)."""
    d = Vector(hacia_adentro).normalized()
    punto, normal, _, _ = bvh.ray_cast(Vector(desde), d)
    if punto is None:
        return None, None
    if normal.dot(d) > 0:
        normal = -normal
    return punto + normal * separacion, normal


SUFIJOS = {
    "acero": "Acero",
    "neon-cian": "Neon",
    "neon-eclipse": "Neon",
    "vigilantes": "Emblema",
    "cuero": "Cuero",
    "tela-oscura": "Tela",
    "tela-dorada": "Tela",
    "oro": "Oro",
    "neon-aviso": "Neon",
    "blanco-armadura": "Armadura",
    "liga": "Liga",
    "visor-cian": "Visor",
    "violeta-claro": "Rombo",
}


def pieza_separada(nombre, hueso, capas, suave=40):
    """Como `pieza`, pero una malla por material (Roblox: un material por malla, y el Neon tiene
    que ser su propia pieza). La del primer material se llama `nombre`; las otras,
    `nombre_<Sufijo>` (Acero, Neon, Emblema...). Devuelve la lista de objetos."""
    grupos = {}
    for mat, armar in capas:
        grupos.setdefault(mat, []).append((mat, armar))
    objs = []
    for i, (mat, lista) in enumerate(grupos.items()):
        sufijo = "" if i == 0 else "_" + SUFIJOS.get(mat, mat.replace("-", " ").title().replace(" ", ""))
        objs.append(pieza(nombre + sufijo, hueso, lista, suave))
    return objs


def _lados(nombre):
    """("Izq", "LeftX"), ("Der", "RightX") para las piezas de a pares."""
    return (("Izq", "Left" + nombre), ("Der", "Right" + nombre))


# ---------------------------------------------------------------------------
# Piezas
# ---------------------------------------------------------------------------


def casco(personaje, material, margen=0.025, redondez=0.45, cara_abierta=True, grosor=0.012):
    """Casco o capucha sobre Head. Con `cara_abierta` deja el hueco de la cara (frente, -Y)."""
    _, _, centro, mitades = caja_parte("Head")
    bm = bmesh.new()
    m = mitades + Vector((margen, margen, margen))
    bloque_redondo(bm, centro + Vector((0, 0, margen * 0.5)), m, redondez, 32, 20)
    if cara_abierta:
        cara = [
            f
            for f in bm.faces
            if f.calc_center_median().y < centro.y - m.y * 0.55
            and centro.z - m.z * 0.75 < f.calc_center_median().z < centro.z + m.z * 0.35
            and abs(f.calc_center_median().x - centro.x) < m.x * 0.62
        ]
        bmesh.ops.delete(bm, geom=cara, context="FACES")
    return malla(f"{personaje}_Casco", bm, material, "Head", grosor)


def peto(personaje, material, margen=0.03, redondez=0.25, placa=True):
    """Peto sobre UpperTorso, con una placa más gruesa al frente si `placa`."""
    _, _, centro, mitades = caja_parte("UpperTorso")
    bm = bmesh.new()
    bloque_redondo(bm, centro, mitades + Vector((margen, margen, margen * 0.5)), redondez, 32, 16)
    if placa:
        frente = centro + Vector((0, -(mitades.y + margen), mitades.z * 0.15))
        bloque_redondo(bm, frente, Vector((mitades.x * 0.6, margen * 0.8, mitades.z * 0.55)), 0.3, 24, 12)
    return malla(f"{personaje}_Peto", bm, material, "UpperTorso")


def hombreras(personaje, material, margen=0.03, alto=0.55):
    """Dos cúpulas sobre los hombros (UpperArm). `alto` = parte del brazo que cubren."""
    piezas = []
    for lado, hueso in _lados("UpperArm"):
        minimo, maximo, centro, mitades = caja_parte(hueso)
        bm = bmesh.new()
        r = Vector((mitades.x + margen * 1.6, mitades.y + margen * 1.6, mitades.z * alto + margen))
        bloque_redondo(bm, Vector((centro.x, centro.y, maximo.z - r.z * 0.55)), r, 0.6, 24, 14)
        # Solo la mitad de arriba (la de abajo queda dentro del brazo).
        corte = maximo.z - r.z * 0.9
        bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < corte], context="VERTS")
        piezas.append(malla(f"{personaje}_Hombrera{lado}", bm, material, hueso, grosor=0.015))
    return piezas


def guantes(personaje, material, margen=0.015, puno=True):
    """Guante sobre cada mano, con puño que sube por el antebrazo si `puno`."""
    piezas = []
    for lado, hueso in _lados("Hand"):
        minimo, maximo, centro, mitades = caja_parte(hueso)
        bm = bmesh.new()
        bloque_redondo(bm, centro, mitades + Vector((margen, margen, margen)), 0.3, 20, 12)
        if puno:
            r = Vector((mitades.x + margen * 2.5, mitades.y + margen * 2.5, mitades.z * 0.45))
            bloque_redondo(bm, Vector((centro.x, centro.y, maximo.z + r.z * 0.6)), r, 0.4, 20, 10)
        piezas.append(malla(f"{personaje}_Guante{lado}", bm, material, hueso))
    return piezas


def botas(personaje, material, margen=0.015, cana=0.6):
    """Bota sobre cada pie, con caña que sube por la pierna (`cana` = parte de LowerLeg)."""
    piezas = []
    for lado, hueso in _lados("Foot"):
        minimo, maximo, centro, mitades = caja_parte(hueso)
        bm = bmesh.new()
        # El pie se alarga un poco hacia adelante (-Y): punta de bota.
        bloque_redondo(
            bm,
            centro + Vector((0, -margen * 1.5, 0)),
            mitades + Vector((margen, margen * 2.5, margen)),
            0.3,
            20,
            12,
        )
        if cana > 0:
            pierna = hueso.replace("Foot", "LowerLeg")
            pmin, pmax, pcentro, pmitades = caja_parte(pierna)
            alto = (pmax.z - pmin.z) * cana / 2
            bloque_redondo(
                bm,
                Vector((pcentro.x, pcentro.y, pmin.z + alto)),
                Vector((pmitades.x + margen * 2, pmitades.y + margen * 2, alto)),
                0.35,
                20,
                10,
            )
        piezas.append(malla(f"{personaje}_Bota{lado}", bm, material, hueso))
    return piezas


def capa(
    personaje,
    material,
    largo=None,
    ancho=1.5,
    vuelo=1.35,
    pliegues=7,
    hondo=0.035,
    columnas=28,
    filas=40,
    cuadros=45,
    grosor=0.012,
    tiras=1,
    corte_desde=0.45,
    choques_extra=(),
):
    """Capa colgada de los hombros por la espalda (+Y), simulada como tela y horneada a malla.

    - `largo`: metros desde los hombros (por defecto hasta las rodillas).
    - `ancho`: veces el ancho del torso arriba; `vuelo`: cuánto se abre abajo.
    - `pliegues` y `hondo`: tablas de la tela arriba (las arrastra la gravedad y salen pliegues).
    - `cuadros`: cuadros de simulación (más = más asentada).
    - `tiras`: la capa se corta en tantas tiras desde `corte_desde` (0 = arriba, 1 = abajo) antes de
      simular, así se separan solas al caer. `choques_extra`: más objetos con los que choca.
    """
    tmin, tmax, tcentro, tmitades = caja_parte("UpperTorso")
    if largo is None:
        rodilla = B.caja_de([B.parte("LeftLowerLeg")])[1].z
        largo = tmax.z - rodilla
    arriba = tmax.z - 0.02
    atras = tmax.y + 0.03
    medio_ancho = tmitades.x * ancho

    bm = bmesh.new()
    filas_v = []
    for j in range(filas + 1):
        t = j / filas
        fila = []
        for i in range(columnas + 1):
            s = i / columnas * 2 - 1
            x = tcentro.x + s * medio_ancho * (1 + (vuelo - 1) * t)
            ola = hondo * math.sin((s + 1) * math.pi * pliegues) * (1 - 0.6 * t)
            fila.append(bm.verts.new((x, atras + ola + 0.02 * t, arriba - t * largo)))
        filas_v.append(fila)
    cortes = {k * columnas // tiras for k in range(1, tiras)}
    for j in range(filas):
        for i in range(columnas):
            if i in cortes and j >= corte_desde * filas:
                continue
            bm.faces.new((filas_v[j][i], filas_v[j][i + 1], filas_v[j + 1][i + 1], filas_v[j + 1][i]))
    me = bpy.data.meshes.new(f"{personaje}_Capa")
    bm.to_mesh(me)
    bm.free()
    nombre = f"{personaje}_Capa"
    viejo = bpy.data.objects.get(nombre)
    if viejo:
        bpy.data.objects.remove(viejo)
    obj = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(obj)

    # La fila de arriba queda fija (prendida a los hombros).
    grupo = obj.vertex_groups.new(name="Prendida")
    grupo.add(list(range(columnas + 1)), 1.0, "REPLACE")

    tela = obj.modifiers.new("Tela", "CLOTH")
    ajustes = tela.settings
    ajustes.quality = 6
    ajustes.mass = 0.4
    ajustes.tension_stiffness = 20
    ajustes.compression_stiffness = 20
    ajustes.bending_stiffness = 0.6
    ajustes.air_damping = 1.5
    ajustes.vertex_group_mass = "Prendida"
    tela.collision_settings.distance_min = 0.008
    tela.collision_settings.use_self_collision = True
    tela.collision_settings.self_distance_min = 0.005
    tela.point_cache.frame_start = 1
    tela.point_cache.frame_end = cuadros

    # El cuerpo (y `choques_extra`, ej. el peto) choca con la tela mientras se simula.
    choques = []
    for p in B.partes() + list(choques_extra):
        if not any(m.type == "COLLISION" for m in p.modifiers):
            p.modifiers.new("Choque", "COLLISION")
            p.collision.thickness_outer = 0.01
            choques.append(p)

    escena = bpy.context.scene
    inicio = escena.frame_current
    for f in range(1, cuadros + 1):
        escena.frame_set(f)
    grafo = bpy.context.evaluated_depsgraph_get()
    horneada = bpy.data.meshes.new_from_object(obj.evaluated_get(grafo))
    escena.frame_set(inicio)

    for p in choques:
        for m in [m for m in p.modifiers if m.type == "COLLISION"]:
            p.modifiers.remove(m)
    obj.modifiers.clear()
    vieja = obj.data
    obj.data = horneada
    bpy.data.meshes.remove(vieja)
    horneada.name = nombre
    obj.vertex_groups.clear()

    # Espesor y sombreado; queda pegada a UpperTorso.
    mod = obj.modifiers.new("Espesor", "SOLIDIFY")
    mod.thickness = grosor
    mod.offset = 0.0
    _aplicar(obj)
    obj.data.shade_smooth()
    B.aplicar_material(obj, material)
    B.pegar_a_hueso(obj, "UpperTorso")
    return obj
