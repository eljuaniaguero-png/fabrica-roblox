# Mutant Lab — pedidos para pasar todo al estilo toon

Una sesión nueva por cada pedido, en orden. Todos usan la guía ideas/estilo-toon.md.
T0 va primero porque crea la paleta y el sistema de contorno que usan los demás.
Conviene hacerlos después del 7-0 (especies nuevas) y antes del arte en Blender.
Al abrir la sesión de T0, adjuntale a Claude la imagen de referencia del estilo.

## [x] T0 — Base del estilo (va primero)

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md entero. Vamos a pasar TODO el juego a este estilo toon, más brillante. En esta sesión armamos la base que van a usar todas las demás.

1. Actualizá shared/Paleta.luau con la paleta nueva de la guía. Mantené los nombres que usa el código cuando se pueda, para no romper nada; si un nombre ya no tiene sentido, cambialo en todos los archivos.
2. Creá shared/Toon.luau: una función que a cualquier modelo le aplique material plano, colores de la paleta y contorno. Probá el contorno por casco invertido y por Highlight, y elegí el que funcione con 20 criaturas y un laboratorio lleno en celular. Explicame la elección.
3. Iluminación nueva: cielo con degradé violeta a rosa, luna grande de caricatura, luz ambiente alta, sin reflejos especulares, ColorCorrection más brillante y saturada.
4. Armá una sala de muestra con: una criatura, un huevo, una fruta, la máquina de fusión, un pedazo de piso y pared, y el HUD. Capturas de cerca y de lejos, en computadora y celular. Esperá mi OK.
5. Con el OK, actualizá la guía de estilo de ideas/mutant-lab.md y las secciones 1 y 2 de ideas/mutant-lab-arte.md para que digan "estilo toon" y apunten a ideas/estilo-toon.md.

No cambies todavía el resto del juego: eso va en los pedidos siguientes.
```

## [ ] T1 — Criaturas

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md y shared/Toon.luau. Si ya hiciste el pedido de estilo toon para las criaturas junto con las especies nuevas (7-0), solo revisá que use Toon.luau y la paleta nueva, y saltá al final.

1. Pasá todas las piezas de criaturas (shared/Piezas.luau y el generador) al estilo: formas simples, colores planos, contorno con Toon.luau.
2. Ojos según la guía: blanco, pupila gigante violeta oscura, puntito de brillo y párpados de color. La personalidad se nota en los párpados y la forma del ojo.
3. Nariz o boca mínima: un círculo de color o una línea.
4. Las mutaciones (ojos extra, bultos, tentáculos, venas) en el mismo estilo: formas simples con contorno, venas como líneas de color que brillan apenas.
5. Mutante dorado: amarillo sol con brillo y estrellitas.
6. Capturas: las 10 bases, 10 fusiones, 3 de generación 3, 2 mutantes y una de nivel 10, todas juntas sobre el piso nuevo. Probá 20 en pantalla en celular.
```

## [ ] T2 — Mapa: plaza, laboratorio y Jardín

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md y shared/Toon.luau. Pasá todo el escenario al estilo toon, más brillante. Un área por vez, con capturas al terminar cada una.

PLAZA
1. Piso crema durazno con un dibujo grande de hélice de ADN en rosa y menta. Bordes redondeados con contorno.
2. Faroles, bancos y carteles como formas simples de colores, con contorno.
3. La máquina de fusión en equipo como pieza central, la más colorida de la plaza.

LABORATORIO
4. Sala clara: piso crema o lila suave con un patrón simple, paredes lila grisáceo con formas redondeadas, franjas de color en los bordes.
5. Que se vea alegre y prolijo, como un laboratorio de dibujo animado, no oscuro ni industrial.
6. Más luz y color: el laboratorio tiene que verse bien sin depender del neón.

JARDÍN SALVAJE
7. Selva de caricatura al atardecer: árboles con copas redondas de colores fuertes, hongos gigantes con lunares, suelo verde menta y lila.
8. Caminos claros que se distinguen del resto, charcos de slime verde menta brillante, arbustos redondos.
9. Que se lea a dónde se puede ir y a dónde no, de un vistazo.

GENERAL
10. Contorno en las siluetas grandes y en todo lo que se toca. En decoración chica y lejana, sin contorno si baja el rendimiento.
11. Sin espacios vacíos: llenalos con decoración simple de colores.
12. Capturas de cada área desde arriba y a la altura del jugador, en computadora y celular. Probá rendimiento.
```

## [ ] T3 — Objetos

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md y shared/Toon.luau. Pasá todos los objetos al estilo toon. Si un objeto tiene partes que se animan, mantené sus nombres para no romper el código.

1. Máquina de fusión: la estrella del laboratorio. Formas gordas y redondeadas, cápsula de vidrio celeste, líquido menta, luces de colores, contorno grueso.
2. Corrales: base de color con borde rosa y cúpula celeste. El cerrado con un candado grande de caricatura.
3. Incubadoras, nido y huevos: huevos con manchas de colores y contorno, grietas como líneas violetas.
4. Mostrador y robot vendedor: el robot con cara de pantalla y ojos enormes como los de las criaturas.
5. Tablero de pedidos, pantalla del Mutadex y estante de trofeos.
6. Catalizadores (rayo, hielo, slime, lava, sombra), residuo, ADN, pista y trofeos: cada uno con una silueta clara y un color fuerte.
7. Clientes de los pedidos, con los mismos ojos que las criaturas.
8. Todo el catálogo de decoración del laboratorio.
9. Capturas por grupo, con un objeto al lado de una criatura para comparar tamaño y estilo.
```

## [ ] T4 — Comida

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md y shared/Toon.luau. Pasá toda la comida al estilo toon.

1. Las 5 frutas vivas (fuego, agua, planta, eléctrico, sombra) con cara: ojos enormes como los de las criaturas, boquita, patitas de bolita y contorno. Cada una con una silueta distinta y un color fuerte.
2. Expresiones: contenta quieta, asustada cuando escapa (ojos más abiertos, boca en "o"), y mareada cuando la atrapás.
3. Fruta Dorada: amarillo sol, con alitas y estrellitas alrededor.
4. Fruta Gigante: enorme, con cara de susto y dos tallos gruesos para tirar.
5. Semillas y las 3 etapas de las plantas de la huerta, con contorno y colores fuertes.
6. Los íconos de comida del HUD con el mismo aspecto.
7. Capturas de las 5 frutas juntas con sus tres expresiones, de la Dorada y la Gigante, y de una ronda del Jardín en movimiento.
```

## [ ] T5 — Interfaz

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md y client/UI (Tema.luau, init.luau, Iconos.luau). Pasá toda la interfaz al estilo toon, más brillante. Cambiá las piezas de client/UI, así todas las pantallas cambian juntas.

1. Paneles claros (blanco o crema) con contorno grueso violeta casi negro, esquinas bien redondeadas y una sombra plana desplazada abajo.
2. Botones gordos de colores fuertes (menta para la acción principal, rosa, amarillo) con contorno grueso y una franja más oscura abajo. Al apretarlos se hunden y rebotan.
3. Tipografía gruesa y redondeada para títulos y números, con contorno.
4. Íconos dibujados en el mismo estilo: formas simples, color plano y contorno.
5. Barras de progreso gordas con contorno, y el relleno con un brillo que se mueve.
6. Revisá el HUD, el panel de fusión, el Mutadex, la tienda, los pedidos, el tablero, las incubadoras, la comida y el modo decorar.
7. Capturas de todas las pantallas en computadora y celular.
```

## [ ] T6 — Efectos y repaso final

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/estilo-toon.md. Último pedido del cambio de estilo.

EFECTOS
1. Pasá todos los efectos a estilo caricatura: nubecitas de "puf" con contorno, estrellitas, líneas de velocidad, corazones, confeti de colores planos, signos de exclamación sobre la cabeza.
2. Fusión, nacimiento de huevo, subida de nivel, entrega de pedido, compra y fruta atrapada: cada uno con su efecto en este estilo.
3. Nada de partículas realistas (humo realista, chispas realistas) que choquen con el estilo.

REPASO
4. Recorré todo el juego con capturas: plaza, laboratorio, Jardín, todos los menús y todos los momentos importantes.
5. Hacé una lista de lo que todavía no está en estilo toon o no combina, y arreglalo.
6. Verificá que no queden colores sueltos fuera de Paleta.luau ni contornos hechos fuera de Toon.luau.
7. Rendimiento en celular con 2 jugadores, 20 criaturas y una ronda del Jardín. Si algo lo baja, simplificalo.
8. Capturas finales: las 5 mejores vistas del juego, para usar después como miniatura y en videos.
```
