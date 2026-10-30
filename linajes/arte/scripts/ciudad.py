"""Edificios y calles de la ciudad (todavía vacío: se llena cuando lleguemos a la ciudad).

Presupuestos de GUIA-ESTILO.md: edificio importante hasta 80.000 triángulos en piezas de
≤ 20.000; edificio de relleno 3.000 a 8.000 en una malla; textura 1024 px / 512 px.

Uso previsto:
    import base as B, ciudad as Ci
    B.cargar_kit()
    piezas = Ci.edificio_relleno("Vortice_Relleno01", pisos=4, material="ladrillo")
    B.render_vistas("vortice_relleno01", piezas)
    B.exportar_piezas("ciudad", piezas)
"""

import base as B  # noqa: F401  (se usa cuando se llenen las funciones)


def edificio_relleno(nombre, pisos=4, ancho=8.0, fondo=8.0, material="ladrillo"):
    """Edificio de relleno de una malla (3.000 a 8.000 triángulos). Devuelve [objetos]."""
    raise NotImplementedError


def edificio_importante(nombre):
    """El Faro, Penal Islaroca, torre Corona: en piezas de ≤ 20.000 triángulos. Devuelve [objetos]."""
    raise NotImplementedError


def calle(nombre, largo=40.0, ancho=12.0, senda=True):
    """Tramo de calle con vereda, cordón y (si `senda`) senda peatonal. Devuelve [objetos]."""
    raise NotImplementedError
