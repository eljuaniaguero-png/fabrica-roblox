---
tags: [estilo, arena]
---
# Arena en Blender (método nuevo, 8 nov)

Cambio de Juani: **el arte se hace en Blender, no por código en Studio**, y nada de texturas de Gemini. La referencia de distribución y luz es `08 Lugares/renders/arena-gemini-ref-1.png` (versión 1 = atardecer, versión 4 = noche), el nivel de desgaste es `02 Estilo/referencias/estilo-05-materiales.png` y los colores de luz, `estilo-01-paleta-luz.png`.

## Dónde está todo
- Escena: `linajes/arte/blender/arena-puerto.blend`
- Scripts (rehacen todo desde cero): `linajes/arte/scripts/arena/materiales.py`, `arena.py`, `muestra_materiales.py`
- Renders: `linajes/arte/renders/arena-blender-atardecer.png`, `arena-blender-noche.png`, `arena-comparacion.png`, `muestra-materiales.png`

## Los 6 materiales (por nodos, sin dibujar patrones a mano)
`MAT_CementoMojado`, `MAT_ChapaOxidada`, `MAT_Ladrillo`, `MAT_MaderaGastada`, `MAT_MetalPiso`, `MAT_TablasMuelle`, más `material_contenedor(tono)` para los contenedores.

El desgaste sale de la forma de la pieza:
- **Bordes y uniones:** se compara la normal suavizada (nodo Bevel) con la normal real; donde difieren hay un canto → óxido y pintura saltada. (Ojo: `Geometry > Pointiness` devuelve 1 en Blender 5.2, no sirve.)
- **Rincones y abajo:** nodo `Ambient Occlusion` → suciedad acumulada.
- **Debajo de remaches:** ruido estirado en Z → chorreados de óxido.
- **Zócalo húmedo:** máscara por altura del objeto (ladrillo).

## Luz medida en Blender (para copiar a Studio)
| Qué | Atardecer (v1) | Noche (v4) |
|---|---|---|
| Sol | color (1,00 / 0,58 / 0,30), fuerza 4,5, altura 9°, giro 212° | color (0,42 / 0,56 / 1,00), fuerza 0,35, altura 34° |
| Cielo | Sky físico, elevación 3°, polvo 4, fuerza 0,35 | fondo liso #0d1629, fuerza 1 |
| Niebla | caja de 260 m, color (1,00 / 0,78 / 0,58), densidad 0,00028 | color (0,38 / 0,50 / 0,72), densidad 0,0022 |
| Farolas | apagadas | punto naranja (1,00 / 0,58 / 0,24), 2600 W, radio 0,16 |
| Reflectores | apagados | punto frío (0,84 / 0,91 / 1,00), 2600 W |
| Ventanas de galpón | apagadas | (1,00 / 0,72 / 0,38), 700 W |
| Exposición | −0,2 | 0 |
| Vista | Standard (nunca AgX: desteñía todo) | Standard |

## Ciclos de comparación hechos
Atardecer: 5 vueltas. Noche: 3 vueltas. Lo que se corrigió en el camino: el volumen de niebla iba en el World y se comía el sol (pasó a una caja), el parentado movía las piezas (faltaba `matrix_parent_inverse`), las grúas se armaban con vigas mal orientadas (ahora con `to_track_quat`), el cemento salía blanco como nieve (eran los cantos del Bevel y los charcos espejados).

## Lo que todavía no se parece (siguiente vuelta)
1. Las grúas se ven de alambre: faltan celosía, cabina grande y contrapeso macizo.
2. La cámara está más lejos y alta que la de la referencia.
3. La plaza es gris azulada; la referencia es ocre cálido tipo arena.
4. Faltan contenedores: la referencia tiene más pilas y colores más vivos.
5. El muelle de tablas es demasiado ancho.

## Lo que falta del pedido
Hornear Color + AO, Normal (OpenGL) y Roughness a 1024, exportar con `SurfaceAppearance` y comparar en Studio desde el mismo ángulo.
