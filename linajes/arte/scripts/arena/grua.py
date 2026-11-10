"""Grúa de pórtico del puerto, como pieza aparte.

Se usa sola (para aprobarla en 4 vistas) y también desde arena.py para ponerla
en el mapa. Reglas de modelado de la GUIA: bisel en todos los bordes, tubos
redondos donde corresponde, pivote abajo y al centro, un material por malla.

Medidas (metros, 1 stud = 0,28 m):
  - trocha de los rieles: 9 m        - alto del portico: 13 m
  - brazo: 22 m a 45 grados          - contrapluma: 8 m
"""

import math

import bpy
import mathutils


def _bisel(ob, ancho=0.04, segmentos=2):
    m = ob.modifiers.new("Bisel", "BEVEL")
    m.width = ancho
    m.segments = segmentos
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(42)
    return m


def caja(nombre, centro, tam, material, col, giro=0.0, bisel=0.04, inclina=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=centro)
    ob = bpy.context.active_object
    ob.name = nombre
    ob.scale = tam
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    ob.rotation_euler = (0, 0, giro) if inclina is None else inclina
    if bisel:
        _bisel(ob, bisel)
    if material:
        ob.data.materials.append(material)
    if col:
        for c in list(ob.users_collection):
            c.objects.unlink(ob)
        col.objects.link(ob)
    return ob


def tubo(nombre, a, b, radio, material, col, lados=12):
    a = mathutils.Vector(a)
    b = mathutils.Vector(b)
    d = b - a
    largo = d.length
    if largo < 1e-6:
        return None
    bpy.ops.mesh.primitive_cylinder_add(radius=radio, depth=largo, location=(a + b) / 2,
                                        vertices=lados)
    ob = bpy.context.active_object
    ob.name = nombre
    ob.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    bpy.ops.object.shade_auto_smooth(angle=math.radians(35))
    _bisel(ob, 0.02, 1)
    if material:
        ob.data.materials.append(material)
    if col:
        for c in list(ob.users_collection):
            c.objects.unlink(ob)
        col.objects.link(ob)
    return ob


def viga(nombre, a, b, grosor, material, col, ancho=None):
    """Viga de caja entre dos puntos, con bisel."""
    a = mathutils.Vector(a)
    b = mathutils.Vector(b)
    d = b - a
    largo = d.length
    if largo < 1e-6:
        return None
    ob = caja(nombre, (a + b) / 2, (ancho or grosor, grosor, largo), material, col, bisel=0.03)
    ob.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    return ob


def armar_grua(nombre="Grua", centro=(0, 0, 0), giro=0.0, escala=1.0, col=None,
               metal=None, vidrio=None, interior=None, emisor_roja=None):
    """Arma la grúa. El brazo apunta al +X local; `giro` la orienta en el mapa.
    Devuelve (piezas, puntos) con las posiciones de la cabina y la punta."""
    e = escala
    cx, cy, cz = centro
    co, si = math.cos(giro), math.sin(giro)

    def L(dx, dy, dz):
        return (cx + dx * e * co - dy * e * si, cy + dx * e * si + dy * e * co, cz + dz * e)

    piezas = []
    P = piezas.append

    TROCHA = 4.5      # media distancia entre rieles
    ALTO = 13.0       # alto del portico
    PATA = 0.9        # grosor de las patas

    # --- Rieles y carros ----------------------------------------------------
    # Los rieles corren paralelos al borde del muelle (eje Y local); el brazo
    # apunta al agua (eje X local), cruzado a los rieles.
    for sx in (-1, 1):
        P(caja(nombre + "_Riel", L(sx * TROCHA, 0, 0.12), (0.5 * e, 16.0 * e, 0.24 * e),
               metal, col, giro=giro, bisel=0.02))
        for dy in (-3.6, 3.6):
            P(caja(nombre + "_Carro", L(sx * TROCHA, dy, 0.55), (1.2 * e, 2.6 * e, 0.7 * e),
                   metal, col, giro=giro))
            for rueda in (-0.9, 0.9):
                P(tubo(nombre + "_Rueda", L(sx * TROCHA - 0.62, dy + rueda, 0.42),
                       L(sx * TROCHA + 0.62, dy + rueda, 0.42), 0.34 * e, metal, col, lados=16))

    # --- Patas del portico, en A hacia adentro -----------------------------
    for sx in (-1, 1):
        for sy in (-1, 1):
            P(viga(nombre + "_Pata", L(sx * TROCHA, sy * 3.6, 0.9),
                   L(sx * 1.9, sy * 1.5, ALTO), PATA * e, metal, col))
        # Cruz de San Andres en el plano del portico (el que cruza el muelle).
        P(viga(nombre + "_Cruz", L(sx * TROCHA, -3.6, 2.2), L(sx * 1.9, 1.5, ALTO - 1.2),
               0.26 * e, metal, col))
        P(viga(nombre + "_Cruz", L(sx * TROCHA, 3.6, 2.2), L(sx * 1.9, -1.5, ALTO - 1.2),
               0.26 * e, metal, col))
    # Travesanos horizontales.
    for sy in (-1, 1):
        P(viga(nombre + "_Trav", L(-(TROCHA - 0.6), sy * 3.0, 6.0),
               L(TROCHA - 0.6, sy * 3.0, 6.0), 0.3 * e, metal, col))
    P(viga(nombre + "_TravAlto", L(0, -2.1, ALTO - 0.4), L(0, 2.1, ALTO - 0.4), 0.45 * e,
           metal, col))

    # --- Cuerpo giratorio: plataforma y casa de maquinas -------------------
    P(caja(nombre + "_Plataforma", L(0, 0, ALTO + 0.4), (7.2 * e, 6.0 * e, 0.8 * e),
           metal, col, giro=giro))
    casa = caja(nombre + "_Casa", L(-1.6, 0, ALTO + 2.9), (5.2 * e, 4.6 * e, 4.2 * e),
                metal, col, giro=giro, bisel=0.08)
    P(casa)
    P(caja(nombre + "_TechoCasa", L(-1.6, 0, ALTO + 5.15), (5.6 * e, 5.0 * e, 0.3 * e),
           metal, col, giro=giro, bisel=0.05))
    # Ventanas de la casa de maquinas.
    for sy in (-1, 1):
        for dx in (-2.6, -0.6):
            P(caja(nombre + "_VentanaCasa", L(dx, sy * 2.33, ALTO + 3.6),
                   (1.3 * e, 0.08 * e, 1.0 * e), metal, col, giro=giro, bisel=0.02))
    # Escalera de gato hasta la plataforma.
    for i in range(10):
        P(tubo(nombre + "_Peldano", L(-3.9, -0.5, 2.0 + i * 1.1), L(-3.9, 0.5, 2.0 + i * 1.1),
               0.05 * e, metal, col, lados=8))
    for lado in (-0.5, 0.5):
        P(tubo(nombre + "_Larguero", L(-3.9, lado, 1.9), L(-3.9, lado, ALTO + 0.4), 0.07 * e,
               metal, col, lados=8))
    # Baranda de la plataforma.
    for sy in (-1, 1):
        P(tubo(nombre + "_Baranda", L(-3.4, sy * 2.9, ALTO + 1.75), L(3.4, sy * 2.9, ALTO + 1.75),
               0.06 * e, metal, col, lados=8))
        for dx in (-3.4, -1.1, 1.1, 3.4):
            P(tubo(nombre + "_Parante", L(dx, sy * 2.9, ALTO + 0.8),
                   L(dx, sy * 2.9, ALTO + 1.8), 0.05 * e, metal, col, lados=8))

    # --- Cabina del operario, del lado del agua ----------------------------
    # Es una caja hueca: paredes, techo y un frente con el hueco de la ventana.
    # Adentro hay asiento y tablero oscuros, y una lampara calida: asi el vidrio
    # deja ver un interior y no es un cuadrado blanco plano.
    CX, CY, CZ = 3.1, -2.4, ALTO + 1.9
    G = 0.12  # grosor de chapa
    P(caja(nombre + "_CabinaFondo", L(CX - 1.14, CY, CZ), (G * e, 2.1 * e, 2.5 * e), metal, col,
           giro=giro, bisel=0.03))
    for sy in (-1, 1):
        P(caja(nombre + "_CabinaLado", L(CX, CY + sy * 0.99, CZ), (2.4 * e, G * e, 2.5 * e),
               metal, col, giro=giro, bisel=0.03))
    P(caja(nombre + "_CabinaTecho", L(CX, CY, CZ + 1.22), (2.6 * e, 2.3 * e, G * e), metal, col,
           giro=giro, bisel=0.04))
    P(caja(nombre + "_CabinaBase", L(CX, CY, CZ - 1.19), (2.4 * e, 2.1 * e, G * e), metal, col,
           giro=giro, bisel=0.03))
    # Frente: antepecho, dintel y dos pilares; en el medio queda el hueco.
    FX = CX + 1.14
    P(caja(nombre + "_CabinaAntepecho", L(FX, CY, CZ - 0.8), (G * e, 2.1 * e, 0.9 * e), metal,
           col, giro=giro, bisel=0.03))
    P(caja(nombre + "_CabinaDintel", L(FX, CY, CZ + 1.1), (G * e, 2.1 * e, 0.3 * e), metal, col,
           giro=giro, bisel=0.03))
    for sy in (-1, 1):
        P(caja(nombre + "_CabinaPilar", L(FX, CY + sy * 0.9, CZ + 0.3), (G * e, 0.3 * e, 1.3 * e),
               metal, col, giro=giro, bisel=0.03))
    # Marco de la ventana, sobresaliendo, con un parante al medio.
    MX = FX + 0.07
    for dz in (-0.37, 0.97):
        P(caja(nombre + "_MarcoH", L(MX, CY, CZ + dz), (0.1 * e, 1.66 * e, 0.09 * e), metal, col,
               giro=giro, bisel=0.02))
    for dy in (-0.79, 0.0, 0.79):
        P(caja(nombre + "_MarcoV", L(MX, CY + dy, CZ + 0.3), (0.1 * e, 0.08 * e, 1.34 * e), metal,
               col, giro=giro, bisel=0.02))
    # Vidrio (va en su propia malla).
    vidrio_pos = L(FX + 0.01, CY, CZ + 0.3)
    v = caja(nombre + "_CabinaVidrio", vidrio_pos, (0.04 * e, 1.5 * e, 1.26 * e), None, col,
             giro=giro, bisel=0.0)
    if vidrio:
        v.data.materials.append(vidrio)
    P(v)
    # Interior oscuro: asiento, respaldo, tablero y dos palancas.
    oscuro = interior or metal
    P(caja(nombre + "_Asiento", L(CX - 0.35, CY, CZ - 0.75), (0.55 * e, 0.6 * e, 0.5 * e), oscuro,
           col, giro=giro, bisel=0.04))
    P(caja(nombre + "_Respaldo", L(CX - 0.6, CY, CZ + 0.05), (0.14 * e, 0.62 * e, 1.25 * e), oscuro,
           col, giro=giro, bisel=0.04))
    P(caja(nombre + "_Tablero", L(CX + 0.72, CY, CZ - 0.3), (0.45 * e, 1.6 * e, 0.6 * e), oscuro,
           col, giro=giro, bisel=0.04))
    for dy in (-0.4, 0.4):
        P(tubo(nombre + "_Palanca", L(CX + 0.7, CY + dy, CZ - 0.05), L(CX + 0.5, CY + dy, CZ + 0.42),
               0.035 * e, oscuro, col, lados=8))
    lampara_cabina = L(CX - 0.2, CY, CZ + 0.95)
    P(caja(nombre + "_CabinaPiso", L(3.1, -2.4, ALTO + 0.62), (2.8 * e, 2.5 * e, 0.2 * e),
           metal, col, giro=giro))

    # --- Brazo a 45 grados --------------------------------------------------
    ang = math.radians(45)
    raiz = L(1.2, 0, ALTO + 2.0)
    largo = 22.0
    punta = L(1.2 + math.cos(ang) * largo, 0, ALTO + 2.0 + math.sin(ang) * largo)
    P(viga(nombre + "_Brazo", raiz, punta, 1.0 * e, metal, col, ancho=1.3 * e))
    # Cordon de abajo y montantes, para que no sea un palo liso.
    raiz_b = L(1.2, 0, ALTO + 0.9)
    punta_b = (punta[0], punta[1], punta[2] - 1.5 * e)
    P(viga(nombre + "_BrazoBajo", raiz_b, punta_b, 0.45 * e, metal, col))
    tramos = (0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    for t in tramos[1:-1]:
        a = mathutils.Vector(raiz).lerp(mathutils.Vector(punta), t)
        b = mathutils.Vector(raiz_b).lerp(mathutils.Vector(punta_b), t)
        P(viga(nombre + "_Montante", a, b, 0.2 * e, metal, col))
    # Refuerzos diagonales entre montantes (5 piezas: casi no suma triangulos).
    for t0, t1 in zip(tramos[:-1], tramos[1:]):
        a = mathutils.Vector(raiz).lerp(mathutils.Vector(punta), t0)
        b = mathutils.Vector(raiz_b).lerp(mathutils.Vector(punta_b), t1)
        P(viga(nombre + "_Diagonal", a, b, 0.14 * e, metal, col))
    # Punta: poleas.
    P(caja(nombre + "_Polea", punta, (1.6 * e, 1.8 * e, 1.2 * e), metal, col, giro=giro,
           bisel=0.06))
    for sy in (-0.55, 0.55):
        P(tubo(nombre + "_Rueda", (punta[0], punta[1] + sy * e, punta[2] - 0.2 * e),
               (punta[0], punta[1] + sy * e, punta[2] - 0.2 * e + 0.12 * e), 0.5 * e,
               metal, col, lados=16))
    luz_punta = (punta[0], punta[1], punta[2] + 1.0 * e)
    lp = caja(nombre + "_LuzPunta", luz_punta, (0.3 * e, 0.3 * e, 0.3 * e), None, col, bisel=0.05)
    if emisor_roja:
        lp.data.materials.append(emisor_roja)
    P(lp)

    # --- Mastil, tirantes y contrapeso -------------------------------------
    mastil = L(-1.2, 0, ALTO + 11.5)
    P(viga(nombre + "_Mastil", L(-1.2, 0, ALTO + 2.4), mastil, 0.8 * e, metal, col))
    P(tubo(nombre + "_Tirante", mastil, punta, 0.14 * e, metal, col, lados=8))
    cola = L(-8.0, 0, ALTO + 3.4)
    P(tubo(nombre + "_TiranteCola", mastil, cola, 0.14 * e, metal, col, lados=8))
    P(viga(nombre + "_Contrapluma", L(-1.6, 0, ALTO + 2.6), cola, 0.5 * e, metal, col))
    P(caja(nombre + "_Contrapeso", L(-8.0, 0, ALTO + 2.3), (3.4 * e, 3.2 * e, 2.6 * e),
           metal, col, giro=giro, bisel=0.08))

    # --- Cable y gancho -----------------------------------------------------
    gancho_z = cz + 3.2 * e
    P(tubo(nombre + "_Cable", (punta[0], punta[1], punta[2] - 0.7 * e),
           (punta[0], punta[1], gancho_z + 1.0 * e), 0.05 * e, metal, col, lados=6))
    P(caja(nombre + "_Motón", (punta[0], punta[1], gancho_z + 0.6 * e),
           (0.7 * e, 0.5 * e, 0.9 * e), metal, col, giro=giro, bisel=0.05))
    gancho = tubo(nombre + "_Gancho", (punta[0], punta[1], gancho_z + 0.2 * e),
                  (punta[0], punta[1], gancho_z - 0.8 * e), 0.16 * e, metal, col, lados=10)
    P(gancho)
    P(tubo(nombre + "_GanchoPunta", (punta[0], punta[1], gancho_z - 0.8 * e),
           (punta[0] + 0.45 * e, punta[1], gancho_z - 0.45 * e), 0.15 * e, metal, col, lados=10))

    return [x for x in piezas if x], {"cabina": lampara_cabina, "punta": luz_punta}
