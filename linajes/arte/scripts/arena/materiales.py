"""Materiales del puerto por nodos (Blender 5.x, Cycles).

Seis materiales: cemento mojado, chapa oxidada, ladrillo, madera gastada,
metal de piso (estriado) y tablas de muelle.

El desgaste sale de la FORMA, no de un dibujo:
  - bordes y uniones: Geometry > Pointiness -> oxido y pintura saltada
  - rincones y abajo: Ambient Occlusion -> suciedad
  - debajo de remaches: chorreados verticales de oxido

Uso dentro de Blender:
    exec(open(r"<ruta>/materiales.py").read())
    MATERIALES = construir_todos()
"""

import bpy

# Paleta (GUIA-ESTILO.md). Lineal aproximado: Blender espera sRGB->lineal, pero
# para un look pintado alcanza con cargar el hex y dejar que Blender lo convierta.
PALETA = {
    "asfalto": (0.227, 0.247, 0.294),
    "ladrillo": (0.431, 0.231, 0.180),
    "acero": (0.541, 0.580, 0.651),
    "oxido": (0.380, 0.212, 0.133),
    "oxido_claro": (0.502, 0.286, 0.157),
    "madera": (0.388, 0.306, 0.231),
    "madera_gris": (0.447, 0.439, 0.420),
    "mugre": (0.118, 0.118, 0.129),
    "mortero": (0.502, 0.482, 0.439),
}


def srgb_a_lineal(c):
    def f(u):
        return u / 12.92 if u <= 0.04045 else ((u + 0.055) / 1.055) ** 2.4

    return (f(c[0]), f(c[1]), f(c[2]), 1.0)


def color(nombre):
    return srgb_a_lineal(PALETA[nombre])


class Constructor:
    """Ayuda para armar arboles de nodos sin repetir codigo."""

    def __init__(self, material):
        self.mat = material
        self.nt = material.node_tree
        self.n = self.nt.nodes
        self.l = self.nt.links
        self.x = -1800
        self.y = 0

    def nodo(self, tipo, x=None, y=None, **props):
        nd = self.n.new(tipo)
        nd.location = (self.x if x is None else x, self.y if y is None else y)
        for k, v in props.items():
            if "." in k:
                a, b = k.split(".")
                setattr(getattr(nd, a), b, v)
            else:
                setattr(nd, k, v)
        return nd

    @staticmethod
    def _enchufe(coleccion, nodo, nombre):
        """Los nodos Mix tienen A/B/Result repetidos (numero, vector y color):
        hay que agarrar el del tipo correcto por identificador, no por nombre."""
        if nodo.bl_idname == "ShaderNodeMix" and nombre in ("A", "B", "Result"):
            sufijo = {"RGBA": "_Color", "VECTOR": "_Vector", "FLOAT": "_Float"}[nodo.data_type]
            buscado = nombre + sufijo
            for s in coleccion:
                if s.identifier == buscado:
                    return s
        if isinstance(nombre, int):
            return coleccion[nombre]
        for s in coleccion:
            if s.name == nombre or s.identifier == nombre:
                return s
        return coleccion[nombre]

    def unir(self, a, sa, b, sb):
        self.l.new(self._enchufe(a.outputs, a, sa), self._enchufe(b.inputs, b, sb))

    def val(self, nodo, entrada, valor):
        self._enchufe(nodo.inputs, nodo, entrada).default_value = valor

    def rampa(self, x, y, puntos):
        """ColorRamp con puntos [(pos, valor_o_color), ...]."""
        nd = self.nodo("ShaderNodeValToRGB", x, y)
        ramp = nd.color_ramp
        while len(ramp.elements) > 1:
            ramp.elements.remove(ramp.elements[-1])
        for i, (pos, v) in enumerate(puntos):
            el = ramp.elements[0] if i == 0 else ramp.elements.new(pos)
            el.position = pos
            el.color = v if len(v) == 4 else (v[0], v[1], v[2], 1.0)
        return nd

    def mezcla(self, x, y, modo="MIX", factor=0.5):
        nd = self.nodo("ShaderNodeMix", x, y, data_type="RGBA", blend_type=modo)
        nd.inputs["Factor"].default_value = factor
        nd.clamp_factor = True
        return nd

    def ruido(self, x, y, escala=8.0, detalle=8.0, aspereza=0.6, distorsion=0.0):
        nd = self.nodo("ShaderNodeTexNoise", x, y)
        self.val(nd, "Scale", escala)
        self.val(nd, "Detail", detalle)
        self.val(nd, "Roughness", aspereza)
        self.val(nd, "Distortion", distorsion)
        return nd

    def coords_objeto(self, x=-2200, y=0, escala=(1, 1, 1)):
        tex = self.nodo("ShaderNodeTexCoord", x, y)
        mapa = self.nodo("ShaderNodeMapping", x + 200, y)
        mapa.inputs["Scale"].default_value = escala
        self.unir(tex, "Object", mapa, "Vector")
        return mapa


def nuevo_material(nombre):
    mat = bpy.data.materials.get(nombre)
    if mat:
        bpy.data.materials.remove(mat)
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    nt = mat.node_tree
    for nd in list(nt.nodes):
        if nd.type != "OUTPUT_MATERIAL":
            nt.nodes.remove(nd)
    return mat


def principled(c, x=300, y=0):
    """Principled + salida, devuelve el nodo para conectarle cosas."""
    bsdf = c.nodo("ShaderNodeBsdfPrincipled", x, y)
    salida = next(nd for nd in c.n if nd.type == "OUTPUT_MATERIAL")
    salida.location = (x + 400, y)
    c.unir(bsdf, "BSDF", salida, "Surface")
    for nombre, valor in (("Specular IOR Level", 0.4), ("IOR", 1.45), ("Metallic", 0.0)):
        if nombre in bsdf.inputs:
            bsdf.inputs[nombre].default_value = valor
    return bsdf


def mascara_bordes(c, x=-1600, y=600, fuerza=0.9, radio=0.035, rango=(0.80, 0.985)):
    """1 en los bordes y uniones. Compara la normal suavizada (Bevel) con la real:
    donde difieren hay un canto. Pointiness no sirve en esta version de Blender."""
    geo = c.nodo("ShaderNodeNewGeometry", x, y)
    bevel = c.nodo("ShaderNodeBevel", x, y - 200)
    c.val(bevel, "Radius", radio)
    bevel.samples = 8
    punto = c.nodo("ShaderNodeVectorMath", x + 200, y - 100, operation="DOT_PRODUCT")
    c.l.new(bevel.outputs["Normal"], punto.inputs[0])
    c.l.new(geo.outputs["Normal"], punto.inputs[1])
    rampa = c.rampa(
        x + 400, y - 100, [(rango[0], (fuerza, fuerza, fuerza)), (rango[1], (0, 0, 0))]
    )
    c.l.new(punto.outputs["Value"], rampa.inputs["Fac"])
    return rampa


def mascara_rincones(c, x=-1600, y=250, distancia=0.35):
    """1 en los rincones y debajo: suciedad acumulada."""
    ao = c.nodo("ShaderNodeAmbientOcclusion", x, y)
    ao.samples = 16
    ao.only_local = True
    c.val(ao, "Distance", distancia)
    invertir = c.rampa(x + 220, y, [(0.25, (1, 1, 1)), (0.85, (0, 0, 0))])
    c.unir(ao, "AO", invertir, "Fac")
    return invertir


def mascara_abajo(c, x=-1600, y=-150, desde=-0.35, hasta=0.15):
    """1 en las caras que miran para abajo (donde se junta la mugre).
    La normal Z va de -1 a 1 y la rampa necesita 0 a 1: se convierte con Z*0.5+0.5."""
    geo = c.nodo("ShaderNodeNewGeometry", x, y)
    sep = c.nodo("ShaderNodeSeparateXYZ", x + 180, y)
    c.unir(geo, "Normal", sep, "Vector")
    medio = c.nodo("ShaderNodeMath", x + 340, y, operation="MULTIPLY_ADD")
    c.l.new(sep.outputs["Z"], medio.inputs[0])
    medio.inputs[1].default_value = 0.5
    medio.inputs[2].default_value = 0.5
    rampa = c.rampa(
        x + 520, y, [(desde * 0.5 + 0.5, (1, 1, 1)), (hasta * 0.5 + 0.5, (0, 0, 0))]
    )
    c.l.new(medio.outputs["Value"], rampa.inputs["Fac"])
    return rampa


def mascara_altura(c, mapa, x=-1600, y=-350, desde=0.0, hasta=0.35):
    """1 abajo del objeto y 0 arriba: humedad del zocalo. Usa la coordenada Z."""
    sep = c.nodo("ShaderNodeSeparateXYZ", x, y)
    c.unir(mapa, "Vector", sep, "Vector")
    rampa = c.rampa(x + 200, y, [(desde, (1, 1, 1)), (hasta, (0, 0, 0))])
    c.l.new(sep.outputs["Z"], rampa.inputs["Fac"])
    return rampa


def chorreados(c, mapa, x=-1600, y=-520, escala=(3.0, 3.0, 0.25), fuerza=(0.45, 0.78)):
    """Oxido que chorrea para abajo: ruido estirado en Z."""
    estirar = c.nodo("ShaderNodeMapping", x, y)
    estirar.inputs["Scale"].default_value = escala
    c.unir(mapa, "Vector", estirar, "Vector")
    ruido = c.ruido(x + 200, y, escala=10.0, detalle=6.0, aspereza=0.75)
    c.unir(estirar, "Vector", ruido, "Vector")
    rampa = c.rampa(x + 400, y, [(fuerza[0], (0, 0, 0)), (fuerza[1], (1, 1, 1))])
    c.unir(ruido, "Fac", rampa, "Fac")
    return rampa


def escalar(c, nodo, salida, k, x, y):
    """Multiplica una mascara por un factor, para que no se coma todo."""
    nd = c.nodo("ShaderNodeMath", x, y, operation="MULTIPLY", use_clamp=True)
    c.l.new(c._enchufe(nodo.outputs, nodo, salida), nd.inputs[0])
    nd.inputs[1].default_value = k
    return nd


def sumar(c, a, sa, b, sb, x, y, factor=1.0, modo="ADD"):
    nd = c.nodo("ShaderNodeMath", x, y, operation=modo, use_clamp=True)
    c.l.new(c._enchufe(a.outputs, a, sa), nd.inputs[0])
    c.l.new(c._enchufe(b.outputs, b, sb), nd.inputs[1])
    if modo == "MULTIPLY_ADD":
        nd.inputs[2].default_value = factor
    return nd


# ---------------------------------------------------------------- materiales


def cemento_mojado():
    """Baldosas grandes de cemento con juntas, charcos y manchas."""
    mat = nuevo_material("MAT_CementoMojado")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    # Juntas: cuadricula de 1,4 m (5 studs) con el nodo Brick en cuadrado.
    juntas = c.nodo("ShaderNodeTexBrick", -1500, 950, offset=0.0, squash=1.0)
    c.val(juntas, "Scale", 0.7)
    c.val(juntas, "Mortar Size", 0.012)
    c.val(juntas, "Mortar Smooth", 0.1)
    c.val(juntas, "Color1", (1, 1, 1, 1))
    c.val(juntas, "Color2", (1, 1, 1, 1))
    c.val(juntas, "Mortar", (0, 0, 0, 1))
    c.unir(mapa, "Vector", juntas, "Vector")

    grano = c.ruido(-1500, 700, escala=6.0, detalle=10.0, aspereza=0.65)
    c.unir(mapa, "Vector", grano, "Vector")
    manchas = c.ruido(-1500, 450, escala=0.25, detalle=5.0, aspereza=0.55)
    c.unir(mapa, "Vector", manchas, "Vector")

    bordes = mascara_bordes(c, -1500, 150, fuerza=0.0, radio=0.01)
    rincones = mascara_rincones(c, -1500, -150, distancia=0.5)

    base = c.mezcla(-1000, 800, "MIX", 0.5)
    c.val(base, "A", srgb_a_lineal((0.459, 0.420, 0.345)))
    c.val(base, "B", srgb_a_lineal((0.549, 0.498, 0.396)))
    c.unir(manchas, "Fac", base, "Factor")

    con_grano = c.mezcla(-800, 800, "MULTIPLY", 0.22)
    c.unir(base, "Result", con_grano, "A")
    c.unir(grano, "Color", con_grano, "B")

    # Juntas oscuras.
    con_juntas = c.mezcla(-600, 800, "MULTIPLY", 1.0)
    c.unir(con_grano, "Result", con_juntas, "A")
    juntas_tono = c.rampa(-800, 1000, [(0.0, (0.35, 0.35, 0.38)), (0.35, (1, 1, 1))])
    c.unir(juntas, "Color", juntas_tono, "Fac")
    c.unir(juntas_tono, "Color", con_juntas, "B")

    # Cantos gastados: el cemento se despunta y se ve mas claro.
    cantos = c.mezcla(-400, 800, "MIX", 1.0)
    c.unir(con_juntas, "Result", cantos, "A")
    c.val(cantos, "B", srgb_a_lineal((0.565, 0.525, 0.435)))
    c.unir(bordes, "Color", cantos, "Factor")

    # Mugre en los rincones.
    sucio = c.mezcla(-200, 800, "MIX", 1.0)
    c.unir(cantos, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    mugre_suave = c.nodo("ShaderNodeMath", -400, 500, operation="MULTIPLY")
    c.unir(rincones, "Color", mugre_suave, 0)
    mugre_suave.inputs[1].default_value = 0.45
    c.unir(mugre_suave, "Value", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    # Charcos: zonas lisas y oscuras donde el ruido es bajo.
    charcos = c.ruido(-1500, -450, escala=0.22, detalle=4.0, aspereza=0.5)
    c.unir(mapa, "Vector", charcos, "Vector")
    mascara_charco = c.rampa(-1300, -450, [(0.30, (0.8, 0.8, 0.8)), (0.40, (0, 0, 0))])
    c.unir(charcos, "Fac", mascara_charco, "Fac")
    # Solo arriba (caras horizontales).
    arriba = mascara_abajo(c, -1500, -700, desde=0.85, hasta=0.45)
    charco_final = c.nodo("ShaderNodeMath", -1000, -550, operation="MULTIPLY", use_clamp=True)
    c.unir(mascara_charco, "Color", charco_final, 0)
    c.unir(arriba, "Color", charco_final, 1)

    rug = c.rampa(-800, -550, [(0.0, (0.86, 0.86, 0.86)), (1.0, (0.3, 0.3, 0.3))])
    c.unir(charco_final, "Value", rug, "Fac")
    c.unir(rug, "Color", bsdf, "Roughness")

    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.25)
    c.unir(con_juntas, "Result", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def chapa_oxidada():
    """Chapa acanalada con oxido en los bordes y chorreados."""
    mat = nuevo_material("MAT_ChapaOxidada")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    # Acanalado: onda en X.
    onda = c.nodo("ShaderNodeTexWave", -1500, 950, bands_direction="X", wave_profile="SIN")
    c.val(onda, "Scale", 9.0)
    c.val(onda, "Distortion", 0.0)
    c.unir(mapa, "Vector", onda, "Vector")

    oxido_ruido = c.ruido(-1500, 650, escala=6.0, detalle=10.0, aspereza=0.7)
    c.unir(mapa, "Vector", oxido_ruido, "Vector")
    pintura = c.ruido(-1500, 400, escala=14.0, detalle=8.0, aspereza=0.75)
    c.unir(mapa, "Vector", pintura, "Vector")

    bordes = mascara_bordes(c, -1500, 120, fuerza=0.9)
    rincones = mascara_rincones(c, -1500, -180, distancia=0.3)
    chorro = chorreados(c, mapa, -1500, -520)

    # Mascara de oxido = bordes + chorreados + manchas de ruido.
    manchas = c.rampa(-1300, 650, [(0.47, (0, 0, 0)), (0.64, (0.95, 0.95, 0.95))])
    c.unir(oxido_ruido, "Fac", manchas, "Fac")
    b_esc = escalar(c, bordes, "Color", 0.85, -1100, -60)
    ch_esc = escalar(c, chorro, "Color", 0.45, -1100, -200)
    m_esc = escalar(c, manchas, "Color", 0.8, -1100, -340)
    ox1 = sumar(c, b_esc, "Value", ch_esc, "Value", -900, -140)
    ox2 = sumar(c, ox1, "Value", m_esc, "Value", -740, -140)

    base = c.mezcla(-1000, 900, "MIX", 0.5)
    c.val(base, "A", srgb_a_lineal((0.482, 0.506, 0.529)))
    c.val(base, "B", srgb_a_lineal((0.369, 0.392, 0.420)))
    c.unir(pintura, "Fac", base, "Factor")

    # El acanalado oscurece los valles.
    con_onda = c.mezcla(-800, 900, "MULTIPLY", 0.6)
    c.unir(base, "Result", con_onda, "A")
    onda_tono = c.rampa(-1300, 950, [(0.0, (0.28, 0.28, 0.3)), (0.5, (0.75, 0.75, 0.78)), (1.0, (1.25, 1.25, 1.25))])
    c.unir(onda, "Fac", onda_tono, "Fac")
    c.unir(onda_tono, "Color", con_onda, "B")

    # Oxido en dos tonos.
    tono_ox = c.mezcla(-600, 600, "MIX", 0.5)
    c.val(tono_ox, "A", color("oxido"))
    c.val(tono_ox, "B", color("oxido_claro"))
    c.unir(manchas, "Color", tono_ox, "Factor")

    con_oxido = c.mezcla(-400, 900, "MIX", 1.0)
    c.unir(con_onda, "Result", con_oxido, "A")
    c.unir(tono_ox, "Result", con_oxido, "B")
    c.unir(ox2, "Value", con_oxido, "Factor")

    sucio = c.mezcla(-200, 900, "MIX", 1.0)
    c.unir(con_oxido, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    mugre = c.nodo("ShaderNodeMath", -400, 400, operation="MULTIPLY")
    c.unir(rincones, "Color", mugre, 0)
    mugre.inputs[1].default_value = 0.5
    c.unir(mugre, "Value", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    # El oxido no brilla; la chapa sana si.
    rug = c.rampa(-200, 300, [(0.0, (0.45, 0.45, 0.45)), (1.0, (0.92, 0.92, 0.92))])
    c.unir(ox2, "Value", rug, "Fac")
    c.unir(rug, "Color", bsdf, "Roughness")
    metal = c.rampa(-200, 100, [(0.0, (0.85, 0.85, 0.85)), (1.0, (0.05, 0.05, 0.05))])
    c.unir(ox2, "Value", metal, "Fac")
    c.unir(metal, "Color", bsdf, "Metallic")

    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.85)
    alto = c.mezcla(-100, -300, "MIX", 0.25)
    c.unir(onda, "Fac", alto, "A")
    c.unir(ox2, "Value", alto, "B")
    c.unir(alto, "Result", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def ladrillo():
    """Pared de ladrillo viejo con mortero gastado y humedad abajo."""
    mat = nuevo_material("MAT_Ladrillo")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    ladrillos = c.nodo("ShaderNodeTexBrick", -1500, 900, offset=0.5, squash=1.0)
    c.val(ladrillos, "Scale", 2.6)
    c.val(ladrillos, "Mortar Size", 0.028)
    c.val(ladrillos, "Mortar Smooth", 0.12)
    c.val(ladrillos, "Bias", 0.0)
    c.val(ladrillos, "Brick Width", 0.5)
    c.val(ladrillos, "Row Height", 0.22)
    c.val(ladrillos, "Color1", color("ladrillo"))
    c.val(ladrillos, "Color2", srgb_a_lineal((0.278, 0.157, 0.137)))
    c.val(ladrillos, "Mortar", srgb_a_lineal((0.278, 0.263, 0.239)))
    c.unir(mapa, "Vector", ladrillos, "Vector")

    variacion = c.ruido(-1500, 620, escala=18.0, detalle=8.0, aspereza=0.7)
    c.unir(mapa, "Vector", variacion, "Vector")
    musgo_ruido = c.ruido(-1500, 380, escala=7.0, detalle=8.0, aspereza=0.75)
    c.unir(mapa, "Vector", musgo_ruido, "Vector")

    rincones = mascara_rincones(c, -1500, 80, distancia=0.4)
    abajo = mascara_altura(c, mapa, -1500, -220, desde=-0.5, hasta=-0.26)
    bordes = mascara_bordes(c, -1500, -520, fuerza=0.8)

    con_var = c.mezcla(-1000, 900, "MULTIPLY", 0.55)
    c.unir(ladrillos, "Color", con_var, "A")
    c.unir(variacion, "Color", con_var, "B")

    # Musgo/humedad verdosa, mas abajo.
    musgo_mask = c.rampa(-1250, 380, [(0.58, (0, 0, 0)), (0.76, (0.75, 0.75, 0.75))])
    c.unir(musgo_ruido, "Fac", musgo_mask, "Fac")
    musgo_abajo = c.nodo("ShaderNodeMath", -1000, 380, operation="MULTIPLY", use_clamp=True)
    c.unir(musgo_mask, "Color", musgo_abajo, 0)
    c.unir(abajo, "Color", musgo_abajo, 1)
    con_musgo = c.mezcla(-800, 900, "MIX", 1.0)
    c.unir(con_var, "Result", con_musgo, "A")
    c.val(con_musgo, "B", srgb_a_lineal((0.247, 0.302, 0.192)))
    c.unir(musgo_abajo, "Value", con_musgo, "Factor")

    # Ladrillos despuntados en los bordes del muro.
    cantos = c.mezcla(-600, 900, "MIX", 1.0)
    c.unir(con_musgo, "Result", cantos, "A")
    c.val(cantos, "B", srgb_a_lineal((0.459, 0.396, 0.353)))
    c.unir(bordes, "Color", cantos, "Factor")

    sucio = c.mezcla(-400, 900, "MIX", 1.0)
    c.unir(cantos, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    c.unir(rincones, "Color", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    c.val(bsdf, "Roughness", 0.88)
    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.55)
    c.val(relieve, "Distance", 0.012)
    c.unir(ladrillos, "Fac", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def madera_gastada():
    """Madera de cajones: vetas, tablas y bordes comidos."""
    mat = nuevo_material("MAT_MaderaGastada")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    # Vetas: onda muy estirada + distorsion.
    vetas = c.nodo("ShaderNodeTexWave", -1500, 950, bands_direction="Z", wave_profile="SIN")
    c.val(vetas, "Scale", 2.2)
    c.val(vetas, "Distortion", 12.0)
    c.val(vetas, "Detail", 6.0)
    c.unir(mapa, "Vector", vetas, "Vector")

    tablas = c.nodo("ShaderNodeTexBrick", -1500, 650, offset=0.0, squash=1.0)
    c.val(tablas, "Scale", 1.6)
    c.val(tablas, "Mortar Size", 0.008)
    c.val(tablas, "Brick Width", 1.6)
    c.val(tablas, "Row Height", 0.16)
    c.val(tablas, "Color1", (1, 1, 1, 1))
    c.val(tablas, "Color2", (0.72, 0.72, 0.72, 1))
    c.val(tablas, "Mortar", (0.05, 0.05, 0.05, 1))
    c.unir(mapa, "Vector", tablas, "Vector")

    gris = c.ruido(-1500, 380, escala=4.0, detalle=8.0, aspereza=0.7)
    c.unir(mapa, "Vector", gris, "Vector")
    bordes = mascara_bordes(c, -1500, 100, fuerza=0.9)
    rincones = mascara_rincones(c, -1500, -200, distancia=0.3)

    base = c.mezcla(-1000, 950, "MIX", 0.5)
    c.val(base, "A", srgb_a_lineal((0.278, 0.212, 0.153)))
    c.val(base, "B", srgb_a_lineal((0.361, 0.282, 0.200)))
    c.unir(vetas, "Fac", base, "Factor")

    # Zonas grisadas por el sol y la sal.
    con_gris = c.mezcla(-800, 950, "MIX", 1.0)
    c.unir(base, "Result", con_gris, "A")
    c.val(con_gris, "B", color("madera_gris"))
    gris_mask = c.rampa(-1250, 380, [(0.45, (0, 0, 0)), (0.75, (0.85, 0.85, 0.85))])
    c.unir(gris, "Fac", gris_mask, "Fac")
    c.unir(gris_mask, "Color", con_gris, "Factor")

    con_tablas = c.mezcla(-600, 950, "MULTIPLY", 1.0)
    c.unir(con_gris, "Result", con_tablas, "A")
    c.unir(tablas, "Color", con_tablas, "B")

    cantos = c.mezcla(-400, 950, "MIX", 1.0)
    c.unir(con_tablas, "Result", cantos, "A")
    c.val(cantos, "B", srgb_a_lineal((0.435, 0.369, 0.282)))
    c.unir(bordes, "Color", cantos, "Factor")

    sucio = c.mezcla(-200, 950, "MIX", 1.0)
    c.unir(cantos, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    c.unir(rincones, "Color", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    c.val(bsdf, "Roughness", 0.85)
    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.4)
    alto = c.mezcla(-100, -250, "MIX", 0.4)
    c.unir(tablas, "Fac", alto, "A")
    c.unir(vetas, "Fac", alto, "B")
    c.unir(alto, "Result", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def metal_piso():
    """Chapa estriada del piso, oxidada en los bordes."""
    mat = nuevo_material("MAT_MetalPiso")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    # Estrias de diamante: dos ondas en diagonal, una para cada lado.
    def onda_diagonal(giro_z, y_nodo):
        giro = c.nodo("ShaderNodeMapping", -1750, y_nodo)
        giro.inputs["Rotation"].default_value = (0, 0, giro_z)
        c.unir(mapa, "Vector", giro, "Vector")
        onda = c.nodo("ShaderNodeTexWave", -1550, y_nodo, bands_direction="X", wave_profile="SAW")
        c.val(onda, "Scale", 22.0)
        c.val(onda, "Distortion", 0.0)
        c.unir(giro, "Vector", onda, "Vector")
        rampa = c.rampa(-1350, y_nodo, [(0.25, (0, 0, 0)), (0.42, (1, 1, 1)), (0.62, (0, 0, 0))])
        c.unir(onda, "Fac", rampa, "Fac")
        return rampa

    a = onda_diagonal(0.785, 1150)
    b = onda_diagonal(-0.785, 900)
    estrias = c.nodo("ShaderNodeMath", -1150, 1020, operation="MAXIMUM", use_clamp=True)
    c.l.new(a.outputs["Color"], estrias.inputs[0])
    c.l.new(b.outputs["Color"], estrias.inputs[1])

    oxido_ruido = c.ruido(-1500, 620, escala=5.0, detalle=10.0, aspereza=0.72)
    c.unir(mapa, "Vector", oxido_ruido, "Vector")
    bordes = mascara_bordes(c, -1500, 320, fuerza=0.9)
    rincones = mascara_rincones(c, -1500, 20, distancia=0.25)
    chorro = chorreados(c, mapa, -1500, -300, escala=(4.0, 4.0, 0.3))

    manchas = c.rampa(-1250, 620, [(0.56, (0, 0, 0)), (0.74, (0.8, 0.8, 0.8))])
    c.unir(oxido_ruido, "Fac", manchas, "Fac")
    b_esc = escalar(c, bordes, "Color", 0.6, -1050, 420)
    m_esc = escalar(c, manchas, "Color", 0.35, -1050, 280)
    ch_esc = escalar(c, chorro, "Color", 0.3, -1050, 140)
    ox1 = sumar(c, b_esc, "Value", m_esc, "Value", -880, 300)
    ox2 = sumar(c, ox1, "Value", ch_esc, "Value", -720, 300)

    base = c.mezcla(-1000, 950, "MIX", 0.7)
    c.val(base, "A", srgb_a_lineal((0.247, 0.263, 0.286)))
    c.val(base, "B", srgb_a_lineal((0.467, 0.502, 0.561)))
    c.unir(estrias, "Value", base, "Factor")

    con_oxido = c.mezcla(-600, 950, "MIX", 1.0)
    c.unir(base, "Result", con_oxido, "A")
    c.val(con_oxido, "B", color("oxido"))
    c.unir(ox2, "Value", con_oxido, "Factor")

    sucio = c.mezcla(-400, 950, "MIX", 1.0)
    c.unir(con_oxido, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    c.unir(rincones, "Color", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    rug = c.rampa(-200, 500, [(0.0, (0.35, 0.35, 0.35)), (1.0, (0.9, 0.9, 0.9))])
    c.unir(ox2, "Value", rug, "Fac")
    c.unir(rug, "Color", bsdf, "Roughness")
    metal = c.rampa(-200, 300, [(0.0, (0.9, 0.9, 0.9)), (1.0, (0.05, 0.05, 0.05))])
    c.unir(ox2, "Value", metal, "Fac")
    c.unir(metal, "Color", bsdf, "Metallic")

    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 1.0)
    c.val(relieve, "Distance", 0.035)
    c.unir(estrias, "Value", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def tablas_muelle():
    """Tablas largas del muelle: mas grises, con juntas abiertas y sal."""
    mat = nuevo_material("MAT_TablasMuelle")
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    tablas = c.nodo("ShaderNodeTexBrick", -1500, 950, offset=0.0, squash=1.0)
    c.val(tablas, "Scale", 0.9)
    c.val(tablas, "Mortar Size", 0.02)
    c.val(tablas, "Mortar Smooth", 0.05)
    c.val(tablas, "Brick Width", 4.0)
    c.val(tablas, "Row Height", 0.22)
    c.val(tablas, "Color1", (1, 1, 1, 1))
    c.val(tablas, "Color2", (0.82, 0.82, 0.82, 1))
    c.val(tablas, "Mortar", (0.05, 0.05, 0.05, 1))
    c.unir(mapa, "Vector", tablas, "Vector")

    vetas = c.nodo("ShaderNodeTexWave", -1500, 650, bands_direction="Y", wave_profile="SIN")
    c.val(vetas, "Scale", 3.0)
    c.val(vetas, "Distortion", 14.0)
    c.val(vetas, "Detail", 8.0)
    c.unir(mapa, "Vector", vetas, "Vector")

    sal = c.ruido(-1500, 400, escala=6.0, detalle=8.0, aspereza=0.7)
    c.unir(mapa, "Vector", sal, "Vector")
    bordes = mascara_bordes(c, -1500, 100, fuerza=0.85)
    rincones = mascara_rincones(c, -1500, -200, distancia=0.3)

    base = c.mezcla(-1000, 950, "MIX", 0.5)
    c.val(base, "A", srgb_a_lineal((0.278, 0.255, 0.220)))
    c.val(base, "B", srgb_a_lineal((0.361, 0.353, 0.333)))
    c.unir(vetas, "Fac", base, "Factor")

    con_sal = c.mezcla(-800, 950, "MIX", 1.0)
    c.unir(base, "Result", con_sal, "A")
    c.val(con_sal, "B", srgb_a_lineal((0.545, 0.541, 0.510)))
    sal_mask = c.rampa(-1250, 400, [(0.5, (0, 0, 0)), (0.78, (0.8, 0.8, 0.8))])
    c.unir(sal, "Fac", sal_mask, "Fac")
    c.unir(sal_mask, "Color", con_sal, "Factor")

    con_tablas = c.mezcla(-600, 950, "MULTIPLY", 1.0)
    c.unir(con_sal, "Result", con_tablas, "A")
    c.unir(tablas, "Color", con_tablas, "B")

    cantos = c.mezcla(-400, 950, "MIX", 1.0)
    c.unir(con_tablas, "Result", cantos, "A")
    c.val(cantos, "B", srgb_a_lineal((0.467, 0.455, 0.427)))
    c.unir(bordes, "Color", cantos, "Factor")

    sucio = c.mezcla(-200, 950, "MIX", 1.0)
    c.unir(cantos, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    c.unir(rincones, "Color", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    c.val(bsdf, "Roughness", 0.9)
    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.5)
    c.val(relieve, "Distance", 0.01)
    alto = c.mezcla(-100, -250, "MIX", 0.35)
    c.unir(tablas, "Fac", alto, "A")
    c.unir(vetas, "Fac", alto, "B")
    c.unir(alto, "Result", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


def material_contenedor(nombre, tono):
    """Contenedor: color propio, nervaduras verticales y oxido en los cantos."""
    mat = nuevo_material(nombre)
    c = Constructor(mat)
    bsdf = principled(c)
    mapa = c.coords_objeto(escala=(1, 1, 1))

    nervio = c.nodo("ShaderNodeTexWave", -1500, 950, bands_direction="X", wave_profile="SIN")
    c.val(nervio, "Scale", 7.0)
    c.val(nervio, "Distortion", 0.0)
    c.unir(mapa, "Vector", nervio, "Vector")

    sucio_ruido = c.ruido(-1500, 650, escala=5.0, detalle=9.0, aspereza=0.7)
    c.unir(mapa, "Vector", sucio_ruido, "Vector")
    bordes = mascara_bordes(c, -1500, 300, fuerza=0.95)
    rincones = mascara_rincones(c, -1500, 0, distancia=0.3)
    chorro = chorreados(c, mapa, -1500, -300, escala=(5.0, 5.0, 0.35), fuerza=(0.55, 0.82))

    manchas = c.rampa(-1250, 650, [(0.55, (0, 0, 0)), (0.74, (0.85, 0.85, 0.85))])
    c.unir(sucio_ruido, "Fac", manchas, "Fac")
    b_esc = escalar(c, bordes, "Color", 0.9, -1050, 420)
    m_esc = escalar(c, manchas, "Color", 0.5, -1050, 280)
    ch_esc = escalar(c, chorro, "Color", 0.5, -1050, 140)
    ox1 = sumar(c, b_esc, "Value", m_esc, "Value", -880, 300)
    ox2 = sumar(c, ox1, "Value", ch_esc, "Value", -720, 300)

    base = c.mezcla(-1000, 950, "MULTIPLY", 0.5)
    c.val(base, "A", srgb_a_lineal(tono))
    nervio_tono = c.rampa(-1250, 950, [(0.0, (0.55, 0.55, 0.55)), (1.0, (1.2, 1.2, 1.2))])
    c.unir(nervio, "Fac", nervio_tono, "Fac")
    c.unir(nervio_tono, "Color", base, "B")

    con_oxido = c.mezcla(-600, 950, "MIX", 1.0)
    c.unir(base, "Result", con_oxido, "A")
    tono_ox = c.mezcla(-800, 600, "MIX", 0.5)
    c.val(tono_ox, "A", color("oxido"))
    c.val(tono_ox, "B", color("oxido_claro"))
    c.unir(manchas, "Color", tono_ox, "Factor")
    c.unir(tono_ox, "Result", con_oxido, "B")
    c.unir(ox2, "Value", con_oxido, "Factor")

    sucio = c.mezcla(-400, 950, "MIX", 1.0)
    c.unir(con_oxido, "Result", sucio, "A")
    c.val(sucio, "B", color("mugre"))
    mugre = escalar(c, rincones, "Color", 0.7, -600, 400)
    c.unir(mugre, "Value", sucio, "Factor")
    c.unir(sucio, "Result", bsdf, "Base Color")

    rug = c.rampa(-200, 500, [(0.0, (0.55, 0.55, 0.55)), (1.0, (0.95, 0.95, 0.95))])
    c.unir(ox2, "Value", rug, "Fac")
    c.unir(rug, "Color", bsdf, "Roughness")

    relieve = c.nodo("ShaderNodeBump", 100, -400)
    c.val(relieve, "Strength", 0.55)
    c.unir(nervio, "Fac", relieve, "Height")
    c.unir(relieve, "Normal", bsdf, "Normal")
    return mat


CONSTRUCTORES = {
    "MAT_CementoMojado": cemento_mojado,
    "MAT_ChapaOxidada": chapa_oxidada,
    "MAT_Ladrillo": ladrillo,
    "MAT_MaderaGastada": madera_gastada,
    "MAT_MetalPiso": metal_piso,
    "MAT_TablasMuelle": tablas_muelle,
}


def construir_todos():
    hechos = {}
    for nombre, fn in CONSTRUCTORES.items():
        hechos[nombre] = fn()
    return hechos
