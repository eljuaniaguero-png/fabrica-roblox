# Orden de pedidos pendientes

Una sesión nueva por cada pedido, en este orden. Al terminar cada uno, jugá el juego antes de pasar al siguiente, y tachá la casilla.
Si una sesión se pone lenta o deja de saludar con "Hola Juani", cortá al terminar un bloque y seguí en otra sesión diciendo desde dónde seguir.
Si al abrir una sesión aparece la opción de trabajar en una copia aislada (worktree), desactivala.

---

# MUTANT LAB

## [ ] 1. Juntar todo y terminar los menús

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

## [ ] 2. Pedidos

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

## [ ] 3. Fracasos útiles, personalidades y catalizadores

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

## [ ] 4. Parte 5: guardado, balance y pulido

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

## [ ] 5. Parte 7: que la fusión se sienta increíble

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

## [ ] 6. Parte 8: razones para volver mañana

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

## [ ] 7. Parte 9: jugar con otros

Lo social, cuando el juego individual ya funciona.

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
