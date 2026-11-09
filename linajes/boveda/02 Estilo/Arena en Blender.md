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

## Segunda vuelta (8 nov): lo que se acercó
1. **Grúas de celosía**: cordones paralelos con diagonales en zig-zag (`celosia()`), casa de máquinas grande, cabina colgada con vidrio y contrapeso macizo.
2. **Explanada de hormigón** detrás y a la derecha de la plaza: antes los contenedores flotaban sobre el agua.
3. **Piso ocre cálido** como la referencia (antes gris azulado).
4. **Más contenedores**, en dos hileras de fondo a la derecha y colores vivos (rojo, azul, verde, amarillo, gris, naranja).
5. **Muelle de tablas más angosto** y cámara más cerca y más baja.

Otro arreglo importante: las coordenadas de objeto están en **metros**, así que un ruido con escala 2,2 sobre una plaza de 34 m daba charcos de 45 cm que se veían como puntitos blancos ("nieve"). Los ruidos del piso van entre 0,2 y 6.

## Lo que todavía se puede acercar
- El cielo del atardecer de la referencia tiene nubes; el nuestro es un degradé limpio.
- Las grúas de la referencia tienen más piezas chicas (poleas, escaleras, barandas).
- Falta el camino de sol sobre el agua bien marcado.

## Lo que falta del pedido
Hornear Color + AO, Normal (OpenGL) y Roughness a 1024, exportar con `SurfaceAppearance` y comparar en Studio desde el mismo ángulo.

## Tercera vuelta (8 nov): los 8 puntos de Juani
1. **Mar de verdad:** malla de 700 m con 220 subdivisiones y dos Displace de nubes (olas grandes y finas), agua casi negra con roughness 0,055. El sol bajo deja su camino de luz sobre el agua.
2. **Atardecer:** sol a 6,5° de altura, color (1 / 0,46 / 0,18), fuerza 3,4 y angulo 1,2° (sombras largas y duras). Cielo fisico con elevacion 3,2°, polvo 5. Exposicion −0,7.
3. **Texturas con desgaste en todo:** contenedores, gruas, galpones y barriles. El piso perdio la cuadricula de azulejos: ahora es cemento manchado.
4. **Farolas de sodio:** color exacto #f29a3a, 5200 W, charcos grandes en el piso.
5. **Niebla de noche:** caja volumetrica azul #2a3550 con densidad 0,0085: las luces tienen halo y el fondo se funde.
6. **Gruas macizas:** cuatro patas gruesas, rieles, anillo, casa de maquinas grande, cabina con vidrio, brazo pesado y contrapeso. Se fue el reticulado fino.
7. **Contenedores en grilla:** `fila()` los coloca sin temblequeo; ninguno flota, se cruza ni sobresale de la explanada.
8. **Camara:** 42 mm a 27 m de alto, como el angulo de la referencia.

**El bicho de esta vuelta:** todos los ruidos de los materiales estaban pensados para un cubo de 1 m. Sobre piezas de 6 m se promediaban y las texturas se veian lisas. Ahora las escalas estan en metros (oxido 0,7-1,3; chorreados 0,5-0,7).

## Renderizar sin abrir Blender
Blender se cerro a mitad de camino, asi que ahora los renders salen por consola (mas rapido: 30 s con OPTIX):

```
"C:\Program Files\Blender Foundation\Blender 5.2lender.exe" -b --python linajes/arte/scripts/arena/render_arena.py -- atardecer salida.png 96 [guardar.blend]
```

## Cuarta vuelta (8 nov): los 6 puntos
1. **Camara** a 22 m, 42 mm, inclinada apenas hacia abajo: el horizonte queda en el tercio de arriba y entran el cielo y el camino del sol.
2. **Contraste de atardecer**: la luz de relleno del cielo baja a 0,30 y el render pasa por una curva en S (negros al 0,09, medios al 0,72). Sombras largas y casi negras. La curva se aplica solo de dia.
3. **Sol** a 4,2 de fuerza con color (1 / 0,52 / 0,26): dora sin quemar, y los contenedores siguen leyendose rojos, azules y verdes.
4. **Farolas naranjas**: el truco es al reves de lo que parece: menos potencia (1300 W), color mas saturado (1 / 0,33 / 0,04) y radio grande. Con mucha potencia el charco sale blanco.
5. **Gruas altas**: patas de 12 m, brazo en diagonal a 44 grados de 15 m, cable largo y gancho colgando. Duplican la altura de las pilas de contenedores.
6. **Luces de noche**: ventanas y porton de cada galpon, vidrio de la cabina de la grua y luz roja de posicion en la punta del brazo. Las posiciones se guardan en las listas VENTANAS, CABINAS y PUNTAS cuando se arma la escena.

**Otro bicho:** la caja de niebla medía 260 m y se veia como una franja marron arriba del horizonte. Ahora mide 900 m, y la densidad de noche bajo a 0,0020.

## Lo que sigue sin parecerse
- La grua de adelante ocupa el tercio izquierdo; en la referencia las dos gruas estan mas lejos y se ven enteras.
- Los charcos de las farolas tiran a crema; en la referencia son naranjas fuertes.
- De noche nuestra plaza esta mas iluminada que la de la referencia.

## Quinta vuelta (8 nov): composicion con logica y grua aparte
**Composicion** (como en la referencia): las dos gruas van sobre el borde del muelle, una detras de la otra, sobre rieles paralelos al borde y con el brazo apuntando al agua; no tocan ni la plaza ni los contenedores. Los contenedores quedan del lado opuesto al agua y al fondo, junto a los galpones. Barriles y cajones en el borde del muelle. La plaza central, libre.

**Grua como pieza aparte**: `linajes/arte/scripts/arena/grua.py`, con las reglas de modelado (bisel en todo, tubos redondos, pivote abajo). Lleva portico de 4 patas sobre rieles con carros y ruedas, cruces de San Andres, casa de maquinas con ventanas, cabina con vidrio iluminado, escalera de gato, baranda, brazo de 22 m a 45 grados con montantes, poleas, cable, moton y gancho, mastil con tirantes y contrapeso. Material propio `MAT_Grua` (metal pintado comido por el oxido).

Las 4 vistas salen con:
```
blender.exe -b --python linajes/arte/scripts/arena/render_grua.py -- renders/grua.png 64
```
Mientras Juani no apruebe la grua nueva, el mapa sigue con la grua vieja de cajas.

## Sexta vuelta (8 nov): cielo, camara del juego y grua aparte
**Juani frena los ciclos de composicion**: el mapa lo acomoda el a mano (gruas, contenedores y galpones). Los scripts no vuelven a mover nada de lugar.

- **Cielo en degrade**: `cielo_degradado()` arma el mundo con una rampa sobre la Z de la direccion de vista (naranja fuerte en el horizonte, rosado arriba, azul en el cenit) y agrega una **esfera emisiva** a 1400 m en la direccion del sol, asi se ve el disco y su reflejo en el agua. Se fue la franja naranja plana. Ojo: el vector Generated del mundo va de -1 a 1, hay que llevarlo a 0..1 antes de la rampa.
- **Camara del juego**: `camara_juego()` deja un personaje de prueba (1,60 m) y pone la camara 8 studs (2,24 m) detras, a la altura de la cabeza, con lente 24 mm (el FOV de Roblox es mas abierto que el de cine). `render_arena.py` saca siempre las dos capturas: `<salida>.png` (aerea) y `<salida>-juego.png`.
- **Grua**: material `MAT_Grua` pasa a pintura gastada gris verdosa con parches rojo oxido (nada de amarillo saturado; el amarillo del mapa era el sol quemando el render). Sigue esperando el OK de Juani para entrar al mapa.
- La referencia `08 Lugares/renders/grua-gemini-ref.png` todavia no esta en la carpeta.
