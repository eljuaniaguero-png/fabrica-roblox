# Orden de pedidos pendientes

Una sesión nueva por cada pedido, en este orden. Al terminar cada uno, jugá el juego antes de pasar al siguiente, y tachá la casilla.
Si una sesión se pone lenta o deja de saludar con "Hola Juani", cortá al terminar un bloque y seguí en otra sesión diciendo desde dónde seguir.
Si al abrir una sesión aparece la opción de trabajar en una copia aislada (worktree), desactivala.

---

# MUTANT LAB

## [x] 1. Juntar todo y terminar los menús

Primero, porque hay trabajo repartido en copias aisladas y si no se junta se puede perder. Además todo lo que sigue usa los componentes nuevos de la interfaz.

```
Juego: Mutant Lab (carpeta mutant-lab/).

PASO 0 - JUNTAR
Hay trabajo de Mutant Lab repartido en varias worktrees (.claude/worktrees/mutant-lab-*). Lo más nuevo está en mutant-lab-parte-5-5f482d, que ya incluye el rediseño de la interfaz (mutant-lab-ui-redesign-7e533e). La carpeta principal tiene una versión anterior. Juntá todo en la rama principal sin perder nada, confirmá que mutant-lab/src/client/UI e ideas/mutant-lab.md completos están en la carpeta principal, y agregá a git los archivos de ideas/ que todavía no estén. Mostrame qué juntaste antes de seguir. A partir de acá trabajá en la carpeta principal.

OBJETIVO
El rediseño quedó a medias. El HUD, las notificaciones y Menus ya usan los componentes de client/UI. Faltan cuatro pantallas que siguen con el sistema viejo: PanelFusion.luau, Mutadex.client.luau, Tienda.client.luau y Celebracion.luau. Las cuatro todavía dependen de ScreenGui armados a mano en Studio, usan Config.Estilo (menta, rosa, amarillo, violeta), colores escritos a mano (GRIS, ROJO, LILA con fromHex) y la tienda tiene emojis como íconos. Pasalas al sistema nuevo, de a una, con capturas en tamaño computadora y celular al terminar cada una.

REGLAS PARA LAS CUATRO
1. Construí todo con las piezas de client/UI: UI.ventana, UI.pestanas, UI.tarjeta, UI.boton, UI.botonCerrar, UI.casillero, UI.contador, UI.barra, UI.puntosGen, UI.puntoElemento y UI.cartelGrande. Si falta una pieza, agregala a client/UI en vez de armarla suelta en la pantalla.
2. Colores solo de shared/Paleta.luau y medidas solo de UI/Tema.luau. Ningún fromHex ni Color3 suelto en estos archivos.
3. Íconos solo de UI/Iconos.luau. Nada de emojis.
4. Que se abran y cierren a través de UI/Menus, como el resto.
5. Las vistas 3D de criaturas con UI/VistasVisibles, para que solo existan las que están en pantalla.
6. Cuando cada pantalla nueva funcione, borrá su ScreenGui viejo del place por MCP (Fusion, Mutadex, Tienda) y cualquier código que lo buscaba.

PANTALLA 1 - Panel de fusión (PanelFusion.luau)
7. Dos casilleros grandes para los padres, uno a cada lado, con un "+" entre ellos. El de la izquierda con borde verde ácido y el de la derecha magenta.
8. Un casillero más chico arriba para el catalizador, con candado hasta que se desbloquee.
9. Vista previa en el medio: resultado si la combinación ya es conocida, silueta con "?" si no.
10. Botón principal "¡FUSIONAR!" con el costo. Si no alcanza el ADN, deshabilitado y con "Te faltan X ADN". Si la mezcla no reacciona, que lo diga claro antes de apretar.
11. Abajo, mis criaturas en casilleros con el borde del color de su generación, filtrables por elemento con botones redondos de colores.
12. Al elegir una criatura, salta al casillero con una animación corta. Tocar un casillero lleno lo vacía.

PANTALLA 2 - Mutadex (Mutadex.client.luau)
13. Ventana grande con encabezado: título, contador "12 / 50", barra de progreso y ADN.
14. Pestañas por generación y una pestaña "Extras" (vacía por ahora, con un texto que diga que llegan pronto).
15. Grilla: 4 tarjetas por fila en computadora y 3 en celular. Descubierta: criatura, nombre, punto de elemento y borde del color de su generación; si la tengo mutante, una estrella dorada. Sin descubrir: silueta negra con "?" sobre la superficie elevada de la paleta, sin el lila viejo.
16. Al tocar una tarjeta, panel de ficha (al costado en computadora, encima en celular): criatura grande girando, nombre, generación, elemento, personalidad, receta solo si ya la descubrí, y botón de pista para las siluetas con su costo.
17. El progreso del HUD sigue abriendo el Mutadex.

PANTALLA 3 - Tienda (Tienda.client.luau)
18. Pestañas Especies, Mejoras, Catalizadores y Premium, con UI.pestanas. Catalizadores y Premium pueden quedar con un texto de "Próximamente" si todavía no existen.
19. Cada artículo en una tarjeta: vista 3D o ícono, nombre, efecto en una línea, nivel actual si es mejora (por ejemplo "Nivel 2 / 5" con puntos), y botón con el precio.
20. Lo que no alcanza: botón deshabilitado con el precio en el color de error. Lo Premium: borde dorado.
21. Al comprar: destello sobre la tarjeta, sonido y el ADN del encabezado rebotando.
22. Reemplazá los emojis de Corrales, Rápida y Nutrientes por íconos de UI/Iconos (agregalos si no existen).

PANTALLA 4 - Festejos (Celebracion.luau)
23. Confeti y carteles con los colores de la paleta nueva: verde ácido, magenta, dorado y los colores de elemento.
24. Los carteles grandes con UI.cartelGrande, uno por vez, encolados.

AL FINAL
25. Eliminá Config.Estilo de shared/Config.luau y verificá con una búsqueda que nada en mutant-lab/src lo use, ni use fromHex fuera de Paleta.luau.
26. Revisá que los botones de Misiones y Ajustes del HUD abran algo: si todavía no existe ese menú, una ventana simple que diga "Próximamente".
27. Capturas en computadora y celular de: panel de fusión con dos criaturas, Mutadex con pocas y con muchas especies, ficha de una especie, las cuatro pestañas de la tienda y un festejo.
28. stylua y selene sobre mutant-lab/src, consola sin errores, y commit.
```

## [x] 2. Pedidos

Lo que más cambia que el juego sea divertido: les da un uso a las criaturas y al ADN.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. El juego se siente aburrido: el jugador descubre especies pero no tiene para qué usarlas, y el ADN le sobra. Vamos a darle un uso a las criaturas. Sumá esto a la ficha como "Pedidos" y hacelo.

1. Un tablero de pedidos en el laboratorio con 3 pedidos activos a la vez, cada uno con un cliente (un personaje simple con nombre gracioso inventado) y un pedido escrito corto.
2. Tipos de pedido, generados solos a partir de las especies que existen:
   - Por rasgo: "algo de fuego que tenga alas", "algo con cuernos y cola larga".
   - Por generación: "una criatura de generación 2 de agua".
   - Por cantidad: "dos criaturas del mismo elemento".
   - Especie exacta, solo si el jugador ya la descubrió.
   - Mutante: "cualquier mutante", con premio grande.
3. Los pedidos se arman con lo que el jugador puede conseguir con lo que ya desbloqueó, más uno que lo obligue a descubrir algo nuevo.
4. Para entregar, elijo criaturas de mi laboratorio que cumplan el pedido. La criatura entregada se va (con una animación de despedida simpática) y cobro el premio: ADN, y a veces un catalizador o una pista gratis.
5. Al entregar, el pedido se reemplaza por otro nuevo. Puedo descartar un pedido que no me gusta, con una espera de 2 minutos.
6. Premio según la dificultad: los fáciles pagan poco, los que piden generación 3 o mutante pagan mucho.
7. Hacé que el ADN sea el límite: subí el costo de las fusiones para que, con los premios de pedidos, el jugador nunca acumule miles de ADN sin uso. Objetivo: que en los primeros 10 minutos nunca tenga más del triple de lo que cuesta su próxima fusión.
8. Avisá en el panel de fusión "Ya la tenés" antes de fusionar una especie conocida, pero dejala fusionar igual, porque ahora sirve para pedidos.
9. Contador en el HUD de pedidos entregados, y un premio cada 10.
10. Todo validado en el servidor y con los números en Config.luau. Usá los componentes de client/UI para el tablero.

Jugá 10 minutos como jugador nuevo y decime: cuántas especies descubrió, cuántos pedidos entregó, cuánto ADN tuvo como máximo, y cuántas veces se quedó sin saber qué hacer. Mostrame capturas del tablero y de una entrega.
```

## [x] 3. Fracasos útiles, personalidades y catalizadores

Da profundidad y variantes. Va después de pedidos porque los pedidos pasan a pedir personalidades y variantes.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Dos de cada tres fusiones dan "No reaccionan" y eso no da nada. Sumá esto a la ficha y hacelo, bloque por bloque.

BLOQUE 1 - Fracasos útiles
1. Cuando una pareja no reacciona, la máquina igual produce algo: un "Residuo" con el color mezclado de los dos, que se guarda en el inventario. No cobra ADN, como hasta ahora.
2. Juntando 5 residuos se fabrica un catalizador al azar entre los que el jugador ya conoce. Así cada intento suma.
3. La máquina dice por qué no reaccionaron en una frase corta que enseñe la regla: "Están muy lejos en la rueda" o "Las tres bases tienen que ser seguidas".

BLOQUE 2 - Personalidades de verdad
4. Toda criatura que nace tiene una personalidad de las 8 de la ficha (4 positivas y 4 negativas), heredada con la tabla fija de la ficha. Si los padres no tienen, sale según una regla fija por especie.
5. Implementá sus efectos en el ADN y en los vecinos del corral, como dice la ficha. Las negativas tienen una ventaja a cambio.
6. Los pedidos pueden pedir personalidad: "algo Alegre de agua".

BLOQUE 3 - Catalizadores
7. Implementá la ranura de catalizador con los 5 catalizadores de la ficha. Se desbloquea a las 10 especies descubiertas, con un cartel que la explica.
8. Cada catalizador crea una variante fija de la especie: otro color, otro rasgo y un apellido en el nombre. Las variantes se registran en la ficha de cada especie del Mutadex.
9. Los pedidos pueden pedir variantes: "un Glumulo de Hielo".

Al terminar cada bloque, jugá 10 minutos y decime qué cambió. Capturas de un residuo, de una criatura con personalidad en el corral y de una fusión con catalizador.
```

## [x] 4. Parte 5: guardado, balance y pulido

Va acá porque el balance tiene que medirse con pedidos y catalizadores ya andando. Si se hace antes, hay que rehacerlo.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Parte 5: guardado, balance y pulido, ahora con pedidos, residuos, personalidades y catalizadores. Si una Parte 5 anterior quedó hecha, revisala y ajustala en vez de rehacerla.

1. Guardado en el servidor de todo lo del jugador: especies y variantes descubiertas, ADN, criaturas con su personalidad, residuos, catalizadores, pedidos activos y entregados, mejoras y pistas.
2. Balance, medido jugando como jugador nuevo:
   - Primera fusión en el primer minuto.
   - Unas 10 especies en los primeros 10 minutos (hoy son 17 en 5: es demasiado rápido).
   - El ADN nunca se acumula sin uso: como máximo el triple de lo que cuesta la próxima fusión.
   - Nunca más de 3 minutos sin algo útil que hacer.
   - Completar el Mutadex principal lleva entre 3 y 5 horas.
   Ajustá Config.luau y decime los tiempos reales que mediste.
3. Primeros 30 segundos: revisá la guía de inicio (flecha y cartel a la máquina) con un jugador nuevo de verdad.
4. Rendimiento: 20 criaturas en pantalla, fluido en celular.
5. Consola sin errores, stylua y selene sin avisos.

Mostrame capturas del laboratorio completo y un resumen de qué se puede jugar y qué falta. Marcá la Parte 5 y hacé commit.
```

## [x] 5. Parte 7: que la fusión se sienta increíble

Pulido de sensación sobre un juego que ya está completo.

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

## [x] 6. Parte 8: razones para volver mañana

Retención: recompensa diaria, experimento del día y misiones.

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

## [x] 7. Parte 9: jugar con otros

Lo social, cuando el juego individual ya funciona.

> **Ojo (11 oct):** una sesión vieja dejó este pedido empezado y sin probar (plaza, paseos, ficha ajena, fusión en equipo). Está guardado en la rama `claude/mutant-lab-ui-consolidate-05bd28`. Al arrancar el pedido, Claude lo revisa y decide si lo aprovecha o empieza de cero.

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

## [ ] 7-00. Limpieza de carpetas viejas

Antes de seguir, para trabajar sobre una carpeta ordenada. Lista primero y espera el OK antes de borrar nada.

```
Ordenar la carpeta fabrica-roblox: sacar lo viejo e innecesario sin perder nada que sirva. En esta sesión no se toca código de los juegos.

1. Hacé una lista de candidatos a borrar o archivar, con el tamaño de cada uno y por qué creés que sobra. Revisá al menos:
   - Las worktrees en .claude/worktrees (hoy: mutant-lab-ui-consolidate-05bd28 y roblox-factory-setup-612625) y las ramas de git que ya no se usan.
   - La carpeta backups/ y la carpeta capturas/.
   - Los documentos de ideas/ que quedaron reemplazados: mutant-lab-plan.md (sus partes ya están hechas o pasaron a ORDEN-PEDIDOS.md), mutant-lab-visual.md (reemplazado por estilo-toon.md), pisada-sonora-pendientes.md (repetido en ORDEN-PEDIDOS.md) y los informes de tendencias viejos.
   - En el place de Studio de cada juego: ScreenGui viejos que ya no usa el código y carpetas "Retirado" en ServerStorage.
2. Antes de proponer borrar una worktree o una rama, comprobá con git si tiene trabajo que no está en la rama principal. Si tiene, decime qué es y no la borres.
3. Mostrame la lista y esperá mi OK. No borres nada antes.
4. Con el OK:
   - Worktrees y ramas: borralas con los comandos de git correspondientes (git worktree remove, git branch -d), nunca borrando la carpeta a mano.
   - Documentos de ideas/: no los borres, movelos a ideas/archivo/ y actualizá las referencias que los nombren.
   - backups/: dejá solo el más reciente de cada juego.
   - capturas/: dejá solo las de los últimos 3 días y sumá la carpeta al .gitignore si pesa mucho.
   - En Studio: borrá lo viejo y guardá el place.
5. Nunca toques: .git, .claude/skills, .claude/settings.local.json, .mcp.json, CLAUDE.md, GUIA-PARA-CLAUDE.md, ORDEN-PEDIDOS.md, src/, mutant-lab/, ideas/mutant-lab.md, ideas/pisada-sonora.md, ideas/estilo-toon.md ni ideas/mutant-lab-arte.md.
6. Al final, mostrame cómo quedó la carpeta, cuánto espacio se liberó, y hacé commit.
7. Si existe la carpeta C:\Users\eljua\Downloads\juego (una copia vieja del kit de la primera noche), avisame: está afuera del proyecto y la borro yo.
```

## [ ] 7-0. Especies nuevas: animales y objetos que se deforman

Cambia el concepto de las criaturas. Va antes que todo, y antes que el arte en Blender: si hay una sesión haciendo las criaturas viejas en Blender, frenala.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md, ideas/mutant-lab-arte.md, shared/Especies.luau, shared/Piezas.luau, shared/Generador.luau y shared/Fusion.luau. Cambio de concepto de las criaturas: actualizá la ficha y la sección 3 del documento de arte primero.

CONCEPTO NUEVO
Las 10 especies base pasan a ser animales y objetos reales y reconocibles. Las fusiones los van deformando: cuanto más alta la generación, más mutados. Es el corazón del nombre "Mutant Lab".

LAS 10 BASES (alternando animal y objeto en la rueda, así la mayoría de las fusiones mezclan los dos)
1. Gato (Sombra)
2. Tostadora (Fuego)
3. Rana (Agua)
4. Lámpara (Eléctrico)
5. Caracol (Planta)
6. Tetera (Fuego)
7. Pulpo (Agua)
8. Mouse de computadora (Eléctrico)
9. Murciélago (Sombra)
10. Cactus en maceta (Planta)
Si alguno no funciona bien como piezas, proponeme un reemplazo antes de cambiarlo.

CÓMO SE VEN
1. Generación 1, normal: el animal u objeto tal cual, fácil de reconocer, en versión tierna y redondeada. Los objetos tienen ojos y boca, y patitas cortas para caminar. El cable de la tostadora, la lámpara y el mouse hace de cola.
2. Generación 2, mezclado: piezas de los dos padres, más 1 mutación chica (un ojo de más, una parte agrandada, una mancha del color del otro padre).
3. Generación 3, mutado: piezas de los tres, más 3 mutaciones (partes infladas, una pata grande y otra chica, un apéndice extra como tentáculo o segunda cola, venas que brillan, cantidad rara de ojos).
4. Variantes de catalizador: la mutación toma el tema del catalizador (cristales de hielo, grietas de lava, goteo de slime, chispas, humo de sombra).
5. Mutante dorado: la versión más deformada y brillante.
6. Las mutaciones de cada especie son fijas: se calculan a partir de la clave de la especie, así la misma especie siempre se ve igual, para todos.
7. Regla de tono: raro y gracioso, nunca asqueroso. Nada de sangre, heridas, órganos, podredumbre ni cosas que den miedo de verdad. Tiene que dar risa, no impresión.
8. Respetá las reglas de encanto: cabeza grande, ojos grandes hundidos en la cara y mirando al mismo lado, boca simple, patas cortas y gordas, dos tonos, material mate.

NOMBRES
9. Cada base con un nombre simple y su versión en 3 sílabas para las fusiones. Las fusiones unen pedazos de los nombres, que tienen que sonar graciosos y leerse fácil (por ejemplo Gato + Tostadora = "Gatostadora", Rana + Lámpara = "Ranámpara"). Mostrame la lista completa de las 50 antes de aplicarla, y corregí a mano los que suenen mal.

LO QUE NO CAMBIA
10. La rueda, las reglas de qué reacciona, las generaciones, los números de cada base y las claves de las especies se mantienen. Así el progreso guardado de los jugadores sigue valiendo.
11. Revisá todo lo que muestra textos de las especies viejas (pistas, pedidos por rasgo, Mutadex, experimento del día) y pasalo a las nuevas. Las pistas tienen que describir los animales y objetos ("uno de los padres tiene cable").

PROCESO
12. Primero hacé en Studio, con partes básicas, 3 bases (Gato, Tostadora y Rana), la fusión Gato + Tostadora y una generación 3 con esas tres. Capturas y esperá mi OK sobre cómo se ven y cuánto se deforman.
13. Con el OK, hacé las 10 y revisá en el Mutadex las 50 en una captura.
14. Después de esto, el arte en Blender (ideas/mutant-lab-blender.md, pedido 2) se hace sobre estas especies nuevas, con un kit de mutaciones (ojos extra, tentáculos, bultos, venas, púas) que se agrega a las piezas.
```

## [ ] 7-1. Todo el juego en estilo toon (pedidos T0 a T6)

Siete pedidos separados en ideas/mutant-lab-toon-pedidos.md, con la guía en ideas/estilo-toon.md. Van después del 7-0 y antes del arte en Blender. T0 primero.

## [ ] 7a. Personalidades raras y más suaves

Hoy todas las criaturas tienen personalidad y los efectos están demasiado fuertes. Va antes que los huevos, porque al nacer se decide la personalidad.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md, shared/Personalidades.luau y el código que reparte personalidades. Hoy todas las criaturas tienen personalidad y los efectos son demasiado fuertes (por ejemplo Trabajadora +35 %). Cambialo así y actualizá la ficha. Números en Config.luau.

RAREZA
1. La mayoría de las criaturas no tiene personalidad: son "Normales", sin ícono y con los ojos comunes.
2. Al nacer, una criatura tiene un 12 % de chance de tener personalidad. Si tiene, se elige con estas probabilidades: comunes (Alegre, Vaga, Curiosa, Glotona) 70 % entre las cuatro, raras (Trabajadora, Miedosa, Peleadora) 25 % entre las tres, y Líder 5 %.
3. Herencia: si uno de los padres tiene personalidad, la chance de pasarla es del 30 %. Si no la pasa, se tira normal como en el punto 2.
4. Catalizadores: en vez de forzar una personalidad, la hacen más probable (por ejemplo Rayo sube la chance de Peleadora al 30 %).
5. Cuando nace una con personalidad, un festejo chico y un cartel con su nombre, para que se sienta especial. Si es Líder, festejo grande.
6. Esta tirada es al azar pero nunca se paga ni se puede comprar más chance.

EFECTOS MÁS SUAVES
7. Ningún efecto de personalidad puede pasar de +10 % para la criatura ni de +5 % para sus vecinas del corral. Ajustá todas a ese tope. Ejemplos: Trabajadora +10 %, Curiosa +6 %, Alegre +3 % a las vecinas, Líder +5 % a las vecinas.
8. Las negativas pierden poco y tienen algo raro y gracioso a cambio, en vez de un número grande. Por ejemplo: Vaga produce 10 % menos pero duerme y ronca; Peleadora quita 3 % a sus vecinas pero a veces encuentra un residuo; Miedosa se esconde y produce 5 % menos, pero encuentra frutas en el Jardín si la llevás de acompañante; Glotona come de a dos pero sube de nivel más rápido.
9. La personalidad se tiene que notar más en cómo se mueve y en los ojos que en los números.

CONEXIONES
10. Pedidos: los que piden personalidad pasan a ser raros y pagan más, porque ahora cuesta conseguirla. Nunca más de uno de los tres pedidos activos puede pedir personalidad.
11. Mutadex: los sellos de personalidad de cada especie quedan como colección para quien quiera completarla, no como requisito.
12. Criaturas que el jugador ya tiene: no les quites la personalidad que ya tienen, pero aplicales los efectos nuevos.

Jugá 15 minutos y decime: cuántas criaturas nacieron, cuántas con personalidad, y cuánto cambió el ADN por segundo comparado con antes. Capturas de una Normal y de una con personalidad en el mismo corral.
```

## [ ] 7b. Guardado seguro para los dos juegos (Mutant Lab hecho el 11 oct; falta Pisada Sonora)

Antes de publicar cualquiera de los dos (lo pide la revisión del 11 oct, puntos 2 a 5).

```
Juego: Mutant Lab y Pisada Sonora, uno por vez (primero Mutant Lab). Leé la sección 3 de GUIA-PARA-CLAUDE.md y los puntos 2 a 5 de ideas/revision-2026-10-11.md.

1. Pasá el guardado a ProfileStore (bloqueo de sesión), instalado con Wally o copiado como módulo, sin perder los datos que ya existen (migración con SchemaVersion).
2. Autoguardado, guardado al salir, en BindToClose en paralelo (tope 25 s), en game.ServerRestartScheduled y después de cada compra con Robux.
3. Si falla la carga, que el jugador vea "No pudimos cargar tu progreso, volvé a entrar" en vez de jugar sin guardar. Un error no apaga el guardado de los demás.
4. Probalo: guardar, salir y volver; dos jugadores; cortar Studio en medio de un guardado.
5. StreamingEnabled está apagado en el place de Mutant Lab (lo vi el 11 oct). Activalo, ajustá el cliente para que no asuma que todo está cargado y probalo con radio chico (sección 4 de la GUIA).

Commit por juego y mostrame la prueba de salir y volver.
```

## [ ] 7c. Huevos e incubadoras

La fusión da un huevo que hay que esperar. Va primero porque cambia lo que pasa al fusionar, y lo demás se apoya en eso.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá a la ficha la sección "Huevos e incubadoras" y hacela. Todo lo nuevo se guarda con el sistema de guardado del juego (si ya está ProfileStore, con un campo nuevo y SchemaVersion). Números en Config.luau.

1. Una fusión que reacciona ya no da la criatura: da un huevo. El huevo tiene los colores mezclados de los padres, manchas del color de su elemento y un tamaño según la generación. Si va a salir mutante, no se nota hasta que nace.
2. Incubadoras en el laboratorio (pieza nueva, en el estilo de la guía): se empieza con 2 y se compran más con ADN, hasta 6. Los huevos que no entran esperan en un nido con lugar para 10.
3. Tiempos: generación 2, 2 minutos; generación 3, 8 minutos. Los 3 primeros huevos de un jugador nuevo nacen en 15 segundos, para que entienda la mecánica sin esperar.
4. La incubación sigue aunque el jugador salga del juego. El servidor guarda la hora de inicio; nunca se usa el reloj del jugador.
5. Cuenta regresiva sobre cada huevo y un aviso en el HUD cuando uno está por nacer.
6. Calentar: tocar un huevo le resta un 5% del tiempo que le falta, con una espera de 10 segundos entre toques y un tope de 50% por huevo. Así esperar también es jugar.
7. Al nacer: en el último 10% el huevo tiembla cada vez más, aparecen grietas, se rompe y sale la criatura con la revelación de la Parte 7 (especie nueva, conocida o mutante). La especie se registra en el Mutadex recién al nacer.
8. Los pedidos y las misiones pueden pedir huevos: "incubá 3 huevos", "hacé nacer uno de generación 3".
9. No agregues nada pago todavía. Anotá en ideas/monetizacion.md, sección Mutant Lab, un producto "Incubación instantánea" para la Parte 6.

Jugá 10 minutos como jugador nuevo y decime: en qué momentos se quedó esperando sin nada que hacer y cuánto tiempo. Si pasa de 1 minuto seguido, ajustá tiempos o incubadoras iniciales. Capturas de las incubadoras con huevos, de calentar un huevo y de un nacimiento.
```

## [ ] 7d. Comida y niveles

Jardín Salvaje con frutas que escapan, alimentar y subir de nivel. Les da un uso a las criaturas que ya tenés.

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá a la ficha la sección "Comida y niveles" y hacela por bloques, con un playtest al terminar cada uno. Todo se guarda con el sistema de guardado del juego. Números en Config.luau.

BLOQUE 1 - Jardín Salvaje (cómo se consigue la comida)
1. Cinco comidas, una por elemento, con nombres inventados y simpáticos (por ejemplo Ají Lava para fuego, Alga Burbuja para agua, Hongo Brote para planta, Chispafruta para eléctrico, Ciruela Sombra para sombra). Las frutas tienen ojos y cara: están vivas.
2. Un portal en la plaza lleva al Jardín Salvaje: una zona aparte, una selva mutante de noche con plataformas, hongos que rebotan, lianas para cruzar, charcos de slime que frenan y arbustos. En el estilo de la guía visual.
3. Rondas de 90 segundos. Al entrar arranca tu ronda; si entran amigos juntos, comparten la ronda.
4. Las frutas brotan del suelo y escapan corriendo cuando te acercás. Cada tipo escapa distinto: unas corren en zigzag, otras saltan entre plataformas, otras se esconden en arbustos y otras desaparecen y reaparecen cerca. Se atrapan tocándolas, con un sonido y un "+1" que salta.
5. Una vez por ronda aparece la Fruta Dorada: muy rápida, deja una estela, vale por 10 y da un festejo grande al atraparla.
6. Combo: atrapar frutas seguidas, sin dejar pasar más de 3 segundos, sube un multiplicador de x1 a x3. Caer en slime o al vacío lo corta.
7. Tu criatura acompañante (la que sacás a pasear) te ayuda con una habilidad según su elemento, con un botón y una recarga:
   - Fuego: carrera rápida por 3 segundos.
   - Agua: una burbuja que atrae las frutas cercanas.
   - Planta: hace brotar 3 frutas extra a tu alrededor.
   - Eléctrico: un rayo que deja quietas las frutas cercanas por 2 segundos.
   - Sombra: muestra dónde están las frutas escondidas.
   Cuanto más nivel tiene la criatura, más fuerte es la habilidad. Sin acompañante se puede jugar igual.
8. Fruta gigante: a veces aparece una enorme que necesita 2 jugadores tirando de ella a la vez. Da un premio grande a los dos.
9. Cada jugador ve y atrapa sus propias frutas comunes, así nadie le roba a nadie. La dorada y la gigante son de la ronda: cobran todos los que participan.
10. Al terminar: pantalla de resultados con lo atrapado, el mejor combo y tu récord, y un botón "Otra ronda". Tabla del servidor con el mejor combo del día.
11. Una huerta chica en el laboratorio (2 macetas) como fuente tranquila: se plantan semillas que se atrapan en el Jardín y crecen solas, incluso con el jugador afuera. Es un complemento; la fuente principal es el Jardín.
12. Los pedidos, las misiones y la recompensa diaria también pueden dar comida.
13. Inventario de comida visible en el HUD, con tope de 50 por tipo.
14. Controles cómodos en celular: botón grande de habilidad abajo a la derecha. Todo validado en el servidor (que la fruta exista, que estés cerca, que la ronda esté activa) para que no se pueda hacer trampa.

BLOQUE 2 - Alimentar y subir de nivel
6. Tocar una criatura del corral abre su ficha con un botón "Alimentar" y las comidas que tengo.
7. Cada comida da experiencia. La comida de su mismo elemento es su favorita y da el doble, con una reacción feliz.
8. Niveles del 1 al 10, cada uno pide más experiencia que el anterior. Cada nivel sube su producción de ADN un 20%.
9. Al subir de nivel: efecto, sonido y número de nivel nuevo sobre la cabeza. En nivel 5 crece un 10%; en nivel 10 gana un aura brillante.
10. Barriga llena: después de comer produce un 25% más durante 10 minutos, con un ícono que lo muestra. No hay hambre como castigo: nunca pierde niveles, nunca se enferma y nunca baja su producción por no comer.
11. Personalidades: la Glotona come de a dos y sube más rápido; la Trabajadora aprovecha mejor la barriga llena. Sumalo a la tabla de personalidades.

BLOQUE 3 - Conexión con lo que ya existe
12. Pedidos: entregar una criatura de nivel alto paga más. Algunos pedidos piden "nivel 3 o más". Antes de entregar una criatura de nivel 3 o más, pedí confirmación mostrando su nivel.
13. El nivel se ve en la ficha del Mutadex, en el panel de fusión y en el cartel sobre la criatura.
14. Balance: revisá que el ADN siga teniendo uso y no sobre, y que la comida no se acumule sin uso. Medilo jugando 15 minutos y decime los números.

Capturas del Jardín Salvaje, de una fruta escapando, de una habilidad de criatura en uso, de la pantalla de resultados, de alimentar una criatura y de una subida a nivel 5.
```

## [ ] 7e. Personalización del laboratorio

Un uso nuevo del ADN, que además le da sentido a las visitas y los "me gusta".

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y el código actual. Sumá a la ficha la sección "Personalización del laboratorio" y hacela. Es un uso nuevo del ADN, puramente estético: no da ventajas. Todo se guarda con el sistema de guardado del juego. Números y precios en Config.luau.

1. Modo decorar: un botón en el HUD que solo aparece dentro de tu laboratorio. Al activarlo, la cámara se aleja un poco y se ven puntos de colocación en el piso y las paredes.
2. Colocar, mover, girar y guardar decoraciones en esos puntos, con una vista previa antes de confirmar. El servidor valida que el lugar sea tuyo y que tengas el objeto. Tope de 40 decoraciones por laboratorio, por rendimiento.
3. Catálogo que se compra con ADN, en una pestaña "Decorar" de la tienda:
   - Temas de sala (6): cambian piso y paredes juntos, siempre con colores de la paleta.
   - Color de las luces del laboratorio (5).
   - Decoraciones sueltas: frascos, plantas mutantes, tubos, carteles de neón, alfombras, peceras, estatuas de tus especies favoritas.
   - Aspectos de corrales, de la máquina de fusión y del arco de entrada con tu nombre.
4. Precios en escalones: cosas baratas para empezar y piezas caras para quien juega mucho.
5. Algunas piezas no se compran: se ganan con trofeos y metas (completar una generación, 100 fusiones, una criatura nivel 10). Mostralas en el catálogo con candado y cómo conseguirlas.
6. Una estatua de cualquier especie que hayas descubierto, para presumir tu favorita.
7. Lo social: quienes visitan tu laboratorio ven la decoración, y el laboratorio con más "me gusta" del servidor aparece como "Laboratorio destacado" en un cartel de la plaza.
8. Usá los componentes de client/UI para el catálogo y los controles del modo decorar, y que funcione bien en celular.
9. No agregues nada pago. Anotá en ideas/monetizacion.md ideas de temas premium para la Parte 6.

Capturas del modo decorar, de un laboratorio decorado y del cartel de laboratorio destacado.
```

## [ ] 8. Parte 6: compras con Robux

Al final de todo, cuando el juego ya retiene jugadores. Antes de esto, publicalo para mayores de 16 y probalo con gente real.

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

---

# PISADA SONORA (cuando vuelvas a ese juego)

## [ ] 9. Bugs del piso

Antes que cualquier cosa nueva.

> **Ojo (11 oct):** una sesión vieja dejó un arreglo empezado y sin probar (reintento de pisada y cupo anti-trampa en `Baldosas.client.luau`, `Pisadas.luau` y `Config.luau`). Está en la rama `claude/pisada-sonora-baldosas-bugs-ee9942`. Claude lo revisa al arrancar el pedido, pero igual tiene que medir el antes y el después.

```
Leé la ficha de Pisada Sonora y el código actual. Hay bugs al pisar el piso: algunas baldosas no suenan y otras no responden bien. No agregues nada nuevo en esta sesión, solo arreglá.

1. Reproducilo vos: en un playtest recorré todas las baldosas de cada zona, primero caminando y después a la velocidad máxima de ese nivel. Registrá en la consola, por cada baldosa, si detectó la pisada, si sumó el paso y si sonó.
2. Decime cuántas fallaron, en qué zona y en qué condición (velocidad alta, al saltar, al pisar dos a la vez, baldosas cortas, etc.).
3. Buscá la causa real antes de cambiar código. Revisá sobre todo: si la detección de pisadas se pierde a velocidad alta, si el sonido no llegó a cargar, si muchas notas seguidas se cortan entre sí, y si una baldosa queda marcada como prendida cuando no debería.
4. Arreglalo y repetí el mismo recorrido. Necesito que el 100% de las baldosas apagadas detecte, sume y suene, también a velocidad máxima.
5. Mostrame la tabla de antes y después.
```

## [ ] 10. Mundo y sensación

Más zonas, teletransporte, consumibles, mapa y efectos.

```
Leé la ficha de Pisada Sonora y el código actual. Actualizá la ficha y hacé estos cambios en orden, con un playtest al terminar cada bloque. Todos los números en Config.luau.

BLOQUE 1 - Más niveles
1. Sumá zonas nuevas hasta llegar a 8, cada una con su canción de dominio público, su paleta y su ambiente. Decime las canciones antes de construir.
2. Extendé la tabla de niveles del jugador para cubrir las 8 zonas, manteniendo la curva de 50% más pasos por nivel.

BLOQUE 2 - Teletransporte en las puertas
3. En cada puerta hay un teletransportador. Al usarlo se abre un menú con la lista de todas las puertas del juego.
4. Las que ya desbloqueé se pueden elegir y me llevan ahí al instante.
5. Las que no desbloqueé aparecen con un candado y el nivel que piden, y no se pueden elegir.
6. El servidor valida que la puerta esté desbloqueada antes de moverme.
7. Sumá un destino fijo a la plaza del vendedor.

BLOQUE 3 - Más consumibles
8. Agregá a la tienda: salto doble por 30 segundos, baldosas doradas que valen por 5 durante 20 segundos, congelar el combo por 20 segundos (no se corta aunque me saltee una), y turbo de velocidad por 15 segundos.
9. Mostrá en el HUD los consumibles activos con su tiempo restante.

BLOQUE 4 - Mapa sin huecos y mejor iluminado
10. Recorré el mapa sacando capturas y marcá los espacios vacíos. Llenalos con decoración acorde a cada zona.
11. Subí la iluminación del entorno: luces de colores a lo largo de la pista, carteles luminosos, fondo con más elementos. Que nunca haya una parte del recorrido donde no se vea por dónde seguir.
12. El piso sigue siendo lo más distinguible: las baldosas disponibles tienen que resaltar contra todo lo demás.
13. Cuidá el rendimiento en celular.

BLOQUE 5 - Que se sienta más
14. Cada baldosa pisada: número "+1" que salta y se desvanece, destello de luz y un pequeño rebote de la baldosa.
15. Combo: a los 10, 25 y 50 seguidos, un efecto cada vez más grande (partículas, color de la estela, sonido que sube de tono).
16. Subir de nivel: fanfarria, explosión de partículas y un cartel grande.
17. Completar una canción: lluvia de monedas que vuelan hacia el contador y un sonido de premio.
18. Abrir una puerta: el candado se rompe, destello y las nubes se abren.
19. Monedas y pasos del HUD: el número crece con un rebote cada vez que sube.
20. Todos estos efectos van del lado del cliente y no pueden bajar el rendimiento.

AL FINAL
Mostrame capturas de cada zona, del menú de teletransporte con candados y de un combo alto en acción.
```

## [ ] 11. Pets, zapatillas y compras

Al final, como en Mutant Lab.

```
Leé la ficha de Pisada Sonora, ideas/monetizacion.md y el código actual. Actualizá la ficha y hacé estos cambios en orden, con un playtest al terminar cada bloque. Todos los números en Config.luau.

BLOQUE 1 - Pets
1. Agregá mascotas que siguen al jugador y dan bonus (más pasos por baldosa, más monedas, combo que aguanta más).
2. Estilo: humor absurdo tipo "brainrot", con personajes 100% originales. Cada pet es una mezcla de animal con instrumento u objeto musical, con un nombre inventado, rítmico y ridículo (por ejemplo: Pianopótamo, Maraca Macaca, Trompetigre). No uses ni imites ningún personaje, nombre o meme existente.
3. Diseñá 12 pets en 4 rarezas: común, raro, épico y legendario. Mostrame la lista con nombre, mezcla y bonus antes de modelarlos, y esperá mi OK.
4. Modelos simples y exagerados, de pocas partes, con una animación de rebote al caminar y un sonido propio corto al aparecer (marcado con -- SONIDO:).
5. Se consiguen de dos formas: completando canciones sin cortar el combo, y con huevos que se compran SOLO con monedas del juego. Cada huevo muestra las probabilidades de cada rareza antes de comprarlo.
6. Abrir un huevo tiene animación: tiembla, se rompe, destello y aparece el pet con su nombre y rareza.
7. Inventario de pets, con hasta 2 equipados a la vez. Tres pets iguales se fusionan en uno de versión mejorada.
8. Dos pets distintos se pueden combinar en uno nuevo: la misma pareja da siempre el mismo resultado, y hay una colección con siluetas de los que faltan descubrir.

BLOQUE 2 - Zapatillas
9. Las Zapatillas ya existen como mejora. Convertilas en objetos equipables: 8 modelos en orden de precio creciente, cada uno con un aspecto distinto que se ve en los pies y un color de estela propio.
10. Dan mejoras de tope de velocidad, pasos por baldosa y altura de salto. Solo un par equipado a la vez.
11. Se compran con monedas a Don Compás, en una pestaña nueva. Cada una se mejora 5 veces pagando monedas.
12. Sumá una mesa de exhibición en la plaza donde se ven los modelos.

BLOQUE 3 - Compras con Robux
13. Implementá la sección "Pisada Sonora" de ideas/monetizacion.md completa: pack de inicio, pases, productos repetibles, cosméticos, lo gratis que ayuda a vender y la tabla de dónde aparece cada oferta.
14. Respetá todos los "Límites para que no arruine el juego" de ese documento.
15. Pestaña "Premium" en la tienda de Don Compás, separada de lo que se compra con monedas.
16. Botón "Probar 20 segundos" en cada cosmético.
17. Dejá los IDs de pases y productos vacíos en Config.luau: los creo yo en el panel de Roblox. Hasta entonces los botones dicen "Próximamente" y no fallan. No crees productos ni toques nada de la cuenta.

AL FINAL
Mostrame capturas de: los 12 pets, la apertura de un huevo, la colección de combinaciones, la pestaña de zapatillas, la pestaña Premium y cada oferta contextual.
```
