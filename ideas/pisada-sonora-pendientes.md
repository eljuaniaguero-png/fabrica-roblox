# Pisada Sonora — pedidos pendientes

Tres pedidos para Claude Code, en orden. Una sesión nueva por cada uno. Jugar el juego entre uno y otro.

## Pedido 1 — Bugs del piso

```
Leé la ficha de Pisada Sonora y el código actual. Hay bugs al pisar el piso: algunas baldosas no suenan y otras no responden bien. No agregues nada nuevo en esta sesión, solo arreglá.

1. Reproducilo vos: en un playtest recorré todas las baldosas de cada zona, primero caminando y después a la velocidad máxima de ese nivel. Registrá en la consola, por cada baldosa, si detectó la pisada, si sumó el paso y si sonó.
2. Decime cuántas fallaron, en qué zona y en qué condición (velocidad alta, al saltar, al pisar dos a la vez, baldosas cortas, etc.).
3. Buscá la causa real antes de cambiar código. Revisá sobre todo: si la detección de pisadas se pierde a velocidad alta, si el sonido no llegó a cargar, si muchas notas seguidas se cortan entre sí, y si una baldosa queda marcada como prendida cuando no debería.
4. Arreglalo y repetí el mismo recorrido. Necesito que el 100% de las baldosas apagadas detecte, sume y suene, también a velocidad máxima.
5. Mostrame la tabla de antes y después.
```

## Pedido 2 — Mundo y sensación

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

## Pedido 3 — Pets, zapatillas y compras

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
