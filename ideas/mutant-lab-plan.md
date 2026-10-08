# Mutant Lab — pedidos para Claude Code

Una sesión nueva por cada parte, en orden. Al terminar cada una, jugar lo que haya antes de pasar a la siguiente.
Si una parte queda a medias: "Juego: Mutant Lab. Leé ideas/mutant-lab.md y terminá la Parte N".

Antes de empezar: en Studio abrir un Baseplate nuevo para este juego, y en PowerShell correr `rojo serve mutant-lab` desde la carpeta fabrica-roblox.

## Parte 0 — Diseño (no construye nada)

```
Juego: Mutant Lab (carpeta mutant-lab/). En esta sesión solo diseñás: no construyas nada en Studio ni escribas código del juego.

Idea: un laboratorio donde combino criaturas para descubrir especies nuevas.
Loop: tengo criaturas base → pongo dos en la máquina de fusión → animación de suspenso → aparece una especie nueva → se registra en mi colección → la criatura genera ADN → con ADN compro más criaturas base y mejoras → vuelvo a combinar.

Escribí ideas/mutant-lab.md con:
1. 10 especies base originales, cada una definida por piezas: cabeza, cuerpo, patas, cola o alas, color y un rasgo especial. No uses ni imites personajes, nombres ni memes existentes.
2. La regla fija que decide qué piezas hereda una fusión de cada padre. La misma pareja da siempre el mismo resultado, sin importar el orden ni el jugador.
3. Cómo se genera el nombre (uniendo sílabas de los padres) y 10 ejemplos de fusiones con su nombre.
4. Tres generaciones: base + base da generación 2, generación 2 + base da generación 3. Unas 50 especies descubribles.
5. Versión "mutante": probabilidad baja en cada fusión, solo estética.
6. Economía: fusionar consume ADN y no destruye a los padres. Las criaturas generan ADN por segundo, más las de generación alta.
7. Qué queda afuera del prototipo: intercambio entre jugadores, bosses, eventos, temporadas, criaturas gigantes y rankings.
8. La pregunta que tiene que responder: después de 10 minutos, ¿tengo ganas de probar una combinación más para llenar una silueta?
9. Un plan de construcción con una casilla por parte, para marcar lo que quede hecho:
   Parte 1 - Criaturas por piezas
   Parte 2 - Máquina de fusión
   Parte 3 - Mutadex
   Parte 4 - Laboratorio y economía
   Parte 5 - Guardado, balance y pulido
   Parte 6 - Compras con Robux

Mostrame la ficha, las 10 especies, los 10 ejemplos de fusión y 3 propuestas de estilo visual descritas en texto. Esperá mi OK.
```

## Parte 1 — Criaturas por piezas

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y hacé solo la Parte 1.

1. Guardá las especies base, sus piezas y las reglas de fusión como datos en mutant-lab/src/shared.
2. Escribí el generador que arma el modelo de cualquier criatura a partir de sus piezas, por código. Modelos simples, de pocas partes.
3. Una animación de caminar o rebotar que sirva para todas.
4. En Studio, con el estilo que elegí, mostrá en fila las 10 especies base y 10 fusiones de ejemplo.

Sacá capturas de las 20. Si alguna combinación de piezas queda rota o ilegible, ajustá la regla y anotalo en la ficha. Marcá la Parte 1 como hecha, hacé commit y frená.
```

## Parte 2 — Máquina de fusión

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y hacé solo la Parte 2. La Parte 1 ya está hecha.

1. Una máquina de fusión con dos ranuras. Elijo dos criaturas mías y confirmo.
2. El servidor calcula el resultado con la regla de la ficha y valida que tengo las dos criaturas y el ADN.
3. Animación de 3 a 4 segundos: la máquina tiembla, luces, humo, silueta negra y revelación con nombre y generación. Marcá los sonidos con -- SONIDO:.
4. Si sale mutante, un efecto extra.
5. Para probar, dame las 10 especies base y ADN de sobra al entrar.

Probá 10 fusiones en un playtest, incluida la misma pareja en los dos órdenes. Mostrame una captura de la revelación. Marcá la Parte 2, commit y frená.
```

## Parte 3 — Mutadex

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y hacé solo la Parte 3. Las Partes 1 y 2 ya están hechas.

1. Un "Mutadex" con todas las especies: las descubiertas se ven completas, las no descubiertas como silueta con signo de pregunta.
2. Contador de progreso siempre visible en el HUD, por ejemplo 12 de 50.
3. Cada silueta puede dar una pista corta que se compra con ADN, del tipo "uno de los padres vuela".
4. Premio de ADN al descubrir una especie por primera vez y un premio grande al completar una generación, con cartel y efecto.
5. Tiene que leerse bien en celular.

Mostrame capturas del Mutadex con pocas y con muchas especies descubiertas. Marcá la Parte 3, commit y frená.
```

## Parte 4 — Laboratorio y economía

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y hacé solo la Parte 4. Las Partes 1 a 3 ya están hechas.

1. Cada jugador tiene su laboratorio: la máquina en el centro, corrales donde se ven sus criaturas caminando y una tienda de especies base.
2. Las criaturas en los corrales generan ADN por segundo según su generación. Hay un tope de criaturas activas.
3. Tienda de especies base, con precio creciente.
4. Mejoras con ADN: más corrales, fusión más rápida, más ADN por segundo.
5. Sacá el ADN de regalo de la Parte 2: el jugador nuevo empieza con 2 especies base y poco ADN.
6. Construí el laboratorio en Studio con el estilo elegido. Todos los números en Config.luau.

Jugá los primeros 5 minutos como jugador nuevo y decime cuántas especies se descubren en ese tiempo. Marcá la Parte 4, commit y frená.
```

## Parte 5 — Guardado, balance y pulido

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y hacé solo la Parte 5. Las Partes 1 a 4 ya están hechas.

1. Guardado en el servidor: especies descubiertas, ADN, criaturas y mejoras de cada jugador.
2. Balance: en el primer minuto tiene que haber una fusión, en los primeros 10 minutos unas 10 especies descubiertas, y nunca más de 3 minutos sin poder fusionar. Ajustá Config.luau y decime los tiempos que mediste.
3. Primeros 30 segundos: una flecha y un cartel corto que lleven a la máquina.
4. Efectos: número de ADN que salta, rebote del contador y efecto al comprar.
5. Rendimiento: probá con 20 criaturas en pantalla.
6. Repasá la consola: cero errores.

Mostrame capturas del laboratorio completo y un resumen de qué se puede jugar y qué falta. Marcá la Parte 5 y hacé commit.
```

## Parte 6 — Compras con Robux (después de jugarlo y ajustarlo)

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md e ideas/monetizacion.md y hacé solo la Parte 6. Las Partes 1 a 5 ya están hechas.

1. Implementá la sección "Mutant Lab" de ideas/monetizacion.md completa: pack de inicio, pases, productos repetibles, especies y cosméticos, y la tabla de dónde aparece cada oferta.
2. Respetá todos los "Límites para que no arruine el juego" de ese documento.
3. Las especies exclusivas van en una página "Extras" del Mutadex, separada de las 50 principales.
4. Una pestaña "Premium" en la tienda del laboratorio, separada de lo que se compra con ADN.
5. Botón para probar cada cosmético 20 segundos.
6. Dejá los IDs de pases y productos vacíos en Config.luau: los creo yo en el panel de Roblox. Hasta entonces los botones dicen "Próximamente" y no fallan. No crees productos ni toques nada de la cuenta.

Mostrame capturas de la pestaña Premium y de cada oferta contextual. Marcá la Parte 6 y hacé commit.
```

## Agregado a la ficha — Variantes (pegar en la Parte 0, o después como "sumá esto a la ficha")

```
Juego: Mutant Lab. Sumá esto a ideas/mutant-lab.md.

1b. Cada especie tiene además: un elemento (fuego, agua, planta, eléctrico o sombra), un tamaño, una personalidad que define cómo se mueve en el corral, y un sonido propio marcado con -- SONIDO:. Definí qué elemento nuevo sale de cada par de elementos. Cada especie base tiene que reconocerse por una sola pieza y tener una silueta distinta a las demás.

VARIANTES
A. Catalizadores: la máquina tiene una tercera ranura opcional. Definí 5 catalizadores (por ejemplo rayo, hielo, slime, cristal y sombra). Cada uno modifica el resultado de una fusión de forma fija: cambia color, rasgo especial, elemento y agrega un apellido al nombre. La misma pareja con el mismo catalizador da siempre lo mismo. Se consiguen con ADN y como premio por descubrimientos.

B. Personalidades: cada criatura tiene una. Definí 4 positivas y 4 negativas que afecten la producción de ADN propia o de las vecinas del corral. Las negativas tienen que tener una ventaja a cambio, para que convenga ubicarlas bien en vez de descartarlas. Cada personalidad se nota en cómo se mueve la criatura y en un ícono sobre ella.

C. Herencia de personalidad: una tabla fija dice qué personalidad sale de cada par de personalidades de los padres. Algunos catalizadores la cambian. Mostrame la tabla.

D. Mutadex por variantes: cada especie tiene su página con casilleros para cada catalizador y un sello por cada personalidad conseguida. Premio al completar una especie entera.

E. Aparición gradual: al principio solo fusión de dos. Las personalidades aparecen a las 5 especies descubiertas y la ranura de catalizador a las 10, cada una con un cartel corto que la explica.

F. Todo esto va como datos en mutant-lab/src/shared, para sumar catalizadores o personalidades sin tocar el código.
```

## Parte 7 — Que la fusión se sienta increíble

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá la Parte 7 al plan de la ficha y hacela. No agregues sistemas nuevos: solo mejorá cómo se siente lo que ya existe.

1. Fusión con tres niveles de espectáculo según lo que salga: especie ya conocida (corta, 1 segundo), especie nueva (la completa, con silueta y revelación) y mutante o generación 3 (la más grande: la cámara tiembla un poco, luces de todo el laboratorio, confeti).
2. En una especie nueva, cartel grande de "¡NUEVA ESPECIE!" con el nombre apareciendo letra por letra y el contador del Mutadex subiendo con un rebote.
3. Botón para saltear la animación en especies ya conocidas.
4. Cada criatura reacciona al tocarla: salta, hace su sonido y muestra su nombre y personalidad.
5. Las criaturas del corral tienen vida: se miran entre sí, las Alegres saltan, las Vagas duermen con una "Z", las Peleadoras se empujan.
6. El ADN se junta con números que saltan y vuelan hacia el contador.
7. Comprar una mejora: destello en lo que mejoró y sonido.
8. Todo sonido nuevo marcado con -- SONIDO:. Los efectos van del lado del cliente y no pueden bajar el rendimiento con 20 criaturas en pantalla.

Mostrame capturas de los tres niveles de fusión y del corral con criaturas de distintas personalidades. Marcá la Parte 7 y hacé commit.
```

## Parte 8 — Razones para volver mañana

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá la Parte 8 al plan de la ficha y hacela, con un playtest al terminar cada punto. Todos los números en Config.luau.

1. ADN mientras no estás: al volver, un cartel muestra cuánto produjeron tus criaturas, con un tope de 8 horas.
2. Recompensa diaria de 7 días que crece: ADN, catalizadores y, el día 7, una especie base especial que no se consigue de otra forma y no se compra.
3. Experimento del día: una silueta misteriosa igual para todos los jugadores, con tres pistas. Quien la descubre ese día gana un premio. Se arma sola a partir de las especies que existen.
4. Misiones cortas, tres por día: por ejemplo "descubrí 2 especies", "usá un catalizador de hielo", "conseguí una criatura Alegre". Premio chico por cada una y uno más grande por las tres.
5. Metas largas visibles: completar cada generación, completar una especie con todas sus variantes, llegar a 100 fusiones. Cada una con su premio y un trofeo que queda exhibido en el laboratorio.
6. Las fechas y los reinicios diarios los decide el servidor, nunca el reloj del jugador.
7. Nada de esto se paga con Robux ni tiene contadores falsos.

Probá simulando el paso de un día y de siete. Mostrame capturas del cartel de regreso, la recompensa diaria, el experimento del día y las misiones. Marcá la Parte 8 y hacé commit.
```

## Parte 9 — Jugar con otros

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá la Parte 9 al plan de la ficha y hacela, con un playtest de dos jugadores al terminar cada punto.

1. Plaza central entre los laboratorios, donde se ven los demás jugadores.
2. Cada jugador puede sacar a pasear una criatura, que lo sigue y la ven todos, con un cartel con su nombre y generación.
3. Visitar laboratorios ajenos: se pueden mirar las criaturas y los trofeos, pero no tocar ni llevarse nada.
4. Al acercarme a la criatura de otro jugador, veo su ficha. Si es una especie que no descubrí, la veo completa pero NO se revela la receta ni se marca en mi Mutadex.
5. Fusión en equipo: dos jugadores ponen una criatura cada uno en una máquina especial de la plaza. Los dos descubren el resultado, ninguno pierde su criatura, y hay unas 10 especies que solo salen así.
6. Tabla de posiciones del servidor y global: más especies descubiertas y más variantes completas.
7. Botón de "me gusta" para laboratorios, con un contador a la vista.
8. Nada de intercambio de criaturas ni de regalos entre jugadores en esta parte.
9. Todo lo que hace un jugador sobre otro se valida en el servidor. Los nombres generados pasan por el filtro de texto de Roblox si en algún momento el jugador puede escribir algo propio.

Mostrame capturas de la plaza con dos jugadores, una visita a un laboratorio ajeno y una fusión en equipo. Marcá la Parte 9 y hacé commit.
```

## Orden recomendado

Partes 0 a 5, jugar y ajustar, después 7, 8 y 9. La Parte 6 (compras con Robux) va al final de todo, cuando el juego ya retenga jugadores.
