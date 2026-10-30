"""Objetos sueltos de la ciudad (todavía vacío: se llena cuando hagan falta).

Presupuestos de GUIA-ESTILO.md: prop 500 a 3.000 triángulos, una malla, textura 256 px;
gadget o implante 2.000 a 5.000 triángulos, textura 512 px. Lo que brilla es MAT_neon-*.

Uso previsto:
    import base as B, props as P
    B.cargar_kit()
    farola = P.farola("Prop_Farola")
    B.render_vistas("farola", [farola])
    B.exportar_piezas("props", [farola])
"""

import base as B  # noqa: F401  (se usa cuando se llenen las funciones)


def farola(nombre, alto=4.5):
    raise NotImplementedError


def cartel_neon(nombre, ancho=2.0, alto=0.8, material="neon-cian"):
    raise NotImplementedError


def caja(nombre, lado=0.8):
    raise NotImplementedError


def auto(nombre):
    raise NotImplementedError


def fragmento_brillante(nombre, material="neon-cian"):
    """Objeto para juntar: brilla en el piso con una columna de luz (ver GUIA-ESTILO, Mundo)."""
    raise NotImplementedError
