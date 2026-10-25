# Plinko Knight — ficha del prototipo

Origen: `plinko-knight/PLAN-Y-PROMPTS.md` (25/10/2026) + idea de arte aprobada (`plinko-knight/arte/IDEA-DE-ARTE.md`).
Estado: **aprobada por Juani el 25/10/2026** (punto de control 1). Etapas 2 (tablero, puntería y bola), 3 (daño y revisión del servidor) y 4 (monstruos y mazmorra) hechas el 25/10/2026; lo próximo es la etapa 5: mejoras 1 de 3.
Carpeta: `plinko-knight/` (código en `plinko-knight/src/`, Rojo con `rojo serve plinko-knight`, puerto 34876). Place propio: `plinko-knight/PlinkoKnight.rbxl`.

## Concepto

Un caballero baja por una mazmorra. Su ataque es una bola que tira desde arriba de un tablero de clavijas: cada clavija que toca suma daño, y el total le pega al monstruo. Son 6 peleas y un jefe. Después de cada pelea que gana, elige 1 de 3 mejoras. Si pierde, vuelve a bajar desde el principio.

**No es un juego de apuestas.** Abajo del tablero no hay casilleros con multiplicadores: la bola cae a un piso liso. El daño sale solo de las clavijas que toca y de las mejoras. En el juego no aparecen palabras de casino ni de premios al azar.

## Loop de 30 segundos

1. Ves el tablero al centro y el monstruo a la derecha. Apuntás con el mouse o con el dedo (una línea de puntos corta muestra el primer tramo) y soltás.
2. La bola rebota por el tablero. Cada clavija que toca brilla y muestra "+2", y el panel de daño va subiendo.
3. Cuando la bola llega abajo, el total vuela al monstruo y le baja la vida. Si sigue vivo, contraataca y te baja vida a vos.
4. Si lo matás, aparecen 3 cartas de mejora: elegís una y bajás al piso siguiente.

## Pantalla de pelea (celular en horizontal, 3 columnas)

| Izquierda | Centro | Derecha |
|---|---|---|
| Tu vida, la vida del monstruo y el **panel de daño** en dos cajas: daño que se suma \| cuántos ×2 hubo. Abajo, los íconos de tus mejoras. | El tablero, con el caballero y el lanzador arriba. Abajo, un piso liso (sin casilleros). | El monstruo grande, con su barra de vida. El jefe ocupa toda la columna. |

Arriba de todo, una barra fina con el piso ("Pelea 3 de 7") y Ajustes. La cámara está fija, de frente al tablero, y no se camina durante la pelea.

## Sistemas del prototipo

1. **Simulación de la bola** (`shared/Simulacion.luau`): física propia en 2D, con paso fijo y siempre el mismo resultado. Se prueba con Lune.
2. **Tablero y puntería**: cada cliente arma su tablero (no se comparte con los demás jugadores). Apuntás con el mouse o el dedo en un abanico hacia abajo y soltás para tirar.
3. **Daño y revisión del servidor**: cada clavija cuenta una sola vez por tiro. El servidor repite la simulación y, si el número no coincide, usa el suyo.
4. **Monstruos y mazmorra**: 6 peleas y un jefe. El monstruo contraataca después de cada tiro. Si te quedás sin vida perdés, y con un botón grande "Volver a bajar" empezás de nuevo.
5. **Mejoras 1 de 3**: bola de fuego, clavija que duplica y bola que se divide. Si elegís una que ya tenés, mejora.
6. **Guardado** con ProfileStore: mejor piso y bolas desbloqueadas.
7. **Pantallas**: inicio, pelea, mejoras, derrota y victoria, en compu y en celular.

## Números de arranque (en `plinko-knight/src/shared/Config.luau`)

| Qué | Valor |
|---|---|
| Tablero | 7 columnas × 8 filas alternadas (unas 52 clavijas) |
| Daño por clavija | 2 (cada clavija cuenta una vez por tiro) |
| Vida del caballero | 50; se cura 10 entre peleas |
| Monstruos (vida / golpe) | 1: 40 / 4 · 2: 60 / 5 · 3: 85 / 6 · 4: 115 / 7 · 5: 150 / 8 · 6: 190 / 9 · **Jefe: 240 / 8** (era 320 / 11; cambiado el 25/10, ver etapa 4) |
| Bola de fuego | +1 de daño por clavija; el monstruo se quema 3 por turno durante 2 turnos. Repetida: +1 más |
| Clavija que duplica | 2 clavijas rojas; al tocar una, el daño que llevás en ese tiro se duplica (cada una, una vez por tiro). Repetida: una clavija roja más |
| Bola que se divide | En el 5.º toque se parte en 2 y las dos siguen sumando. Repetida: en el 4.º toque, y después en el 3.º |
| Bolas que se desbloquean | Hierro (desde el inicio) · Fuego (llegar al piso 4) · Partida (ganarle al jefe) |

Objetivo de balance: un tiro normal toca entre 10 y 18 clavijas (20 a 36 de daño), cada pelea dura 2 a 4 tiros y en las primeras partidas se pierde entre la pelea 4 y la 6.

## Cómo funciona por dentro

- **La física es propia y en 2D, no la de Roblox.** La bola nunca es una pieza con física: el cliente solo la dibuja siguiendo la simulación. Así no se escapa hacia la cámara y se puede probar fuera de Studio.
- **El servidor lleva la partida** (piso, vida, mejoras y monstruo). En cada tiro le da al cliente una semilla, y el cliente manda solo el ángulo y el daño que vio. El servidor corre la misma simulación con ese ángulo; si el daño no coincide (con un margen chico), usa el suyo. Además tiene un tope de daño por tiro, un límite de frecuencia y revisa que el tiro sea del turno actual. Valida tipos y números finitos.
- **Guardado:** ProfileStore con `VERSION` y migración cada vez que cambie lo que se guarda.

## Cómo se ve

- **Hasta la etapa 8, todo en bloques grises.** Los colores solo distinguen cosas: clavija normal gris claro, clavija que duplica roja y bola blanca.
- **Para después (etapas 8 y 9):** mazmorra de piedra, clavijas doradas `#F5C542`, números de daño amarillo flúor y monstruos como imágenes planas. La paleta favorita es "Cripta azul" (fondo `#151B2E`, piedra `#2F3B57`, rubí `#E2323F`, cian `#4FE3F0`). Todo el detalle está en `plinko-knight/arte/IDEA-DE-ARTE.md`.

## Herramientas de arte y sonido

**ForgeGUI está habilitada** para este juego: Juani la tiene paga, con **350.000 créditos** (25/10/2026). Es la herramienta principal; **Gemini** queda de reserva, con los prompts de `plinko-knight/PLAN-Y-PROMPTS.md`.

- **Etapa 9 (arte final):** monstruos, caballero, íconos de mejoras y de bolas, y fondo de mazmorra.
  - Primero se crea un **estilo de ForgeGUI** con la guía de estilo de la ficha (la que se elija en la etapa 8) y se usa en **todas** las imágenes, así salen parecidas entre sí.
  - El fondo se saca con color key (un color de fondo liso que después se borra).
  - Se sube a Roblox con la conexión de ForgeGUI, y el ID de cada asset va en `Config.luau`.
- **Etapa 10 (sensación y sonido):** efectos de sonido y música hechos con ForgeGUI y subidos a Roblox. Siguen las reglas de Audio de `CLAUDE.md`: nada con derechos de autor y cada punto marcado con `-- SONIDO:`.
- **Antes de usarlo:** confirmar que lo que se genera con el plan pago es privado y se puede usar comercialmente. Si no, se frena y se le avisa a Juani.
- **Cada vez que una etapa necesite arte o sonido con IA, avisarle a Juani antes de generar** (qué se va a hacer, con qué herramienta y cuántos créditos gasta, más o menos).

## Qué queda FUERA de la versión mínima ("después")

Mazos de bolas, reto diario, ranking, **cualquier cosa con Robux**, varias mazmorras, multijugador cooperativo, mascotas y tienda. Se anotan acá y no se programan. Cuando llegue Robux: aspectos de bola y de tablero. Si alguna vez hay algo al azar que se pague, van las probabilidades a la vista y PolicyService (sección 6 de la GUIA).

## Cambios respecto del plan

- **El monstruo va a la derecha, no abajo del tablero.** Lo aprobaste el 25/10 en la idea de arte: en un celular horizontal el tablero y el monstruo no entran uno arriba del otro.
- **El panel de daño tiene dos cajas** (daño | ×2). La regla de la clavija roja no cambia: solo se muestra separado.
- Lo demás (números, mejoras, lo que queda fuera y cómo funciona por dentro) es igual al plan.

## Avance

### Etapa 2 · Tablero, puntería y bola (25/10/2026)

- `shared/Tablero.luau` arma las 52 clavijas como datos; `shared/Simulacion.luau` calcula el tiro en 2D (paso de 1/120 s, rebote 0,65, fricción 0,04, anti-trabas a los 2 s y tope de 15 s). El cliente arma el tablero solo para él, con cámara fija (FOV 20) y el lugar del monstruo a la derecha.
- **Medidas ajustadas:** con separación 4 y la bola chica tocaba solo 6,6 clavijas por tiro. Quedó: separación 3,25 entre clavijas y 3,5 entre filas, clavija de radio 0,7, bola de radio 0,6 y 1,3 de hueco junto a las paredes (si el hueco es más chico que la bola, se traba).
- **Prueba con Lune** (`lune run plinko-knight/pruebas/simulacion`): 200 tiros, ninguno se traba ni sale por los costados, y el mismo tiro da siempre lo mismo. Promedio: **14 clavijas** (de 5 a 21), unos 5 s por tiro.
- **En Studio:** 10 tiros con el mouse a los dos lados, con un promedio de **14,7 clavijas**. Todos terminan abajo y no se puede tirar otra bola mientras rebota.
- **Pendiente:** la prueba en el emulador de celular (10 tiros y captura). Juani la salteó por ahora; hacerla antes de la etapa 7 (pantallas).
- **Decisión:** el azar del rebote usa un generador propio con semilla, no `Random.new`, porque `Random` no existe en Lune. Así las pruebas y el juego dan exactamente los mismos números.
- Cada rebote contra una clavija tiene un desvío chico (hasta 4°) que sale de la semilla: el mismo ángulo no da siempre el mismo recorrido. Por ahora la semilla sale del reloj; desde la etapa 3 la da el servidor.

### Etapa 3 · Daño, números y revisión del servidor (25/10/2026)

- **Daño:** la simulación suma `Config.Danio.PorClavija` (2) por cada clavija, **una sola vez por tiro**. La segunda vez la bola rebota pero no suma ni brilla.
- **Números en pantalla:** cada toque hace saltar un "+2" amarillo que sube y se desvanece en 0,5 s (se ve entero la primera mitad; si se desvanece desde el arranque, casi no se lee). El **TOTAL** va **arriba del lugar del monstruo**, porque entre el tablero y el monstruo hay solo 3 studs y no entra. Sube con cada toque con un "pop".
- **Servidor** (`server/Partida.luau` y `server/Tiros.luau`): lleva la partida de cada jugador (piso, vida, mejoras, número de tiro y semilla). `PedirTiro` da el número y la semilla; si se pide otra vez sin tirar, devuelve la misma (así no se puede "volver a sortear" la semilla). `Tirar` valida tipos, números finitos, el tiro que corresponde, el ángulo dentro del abanico y que haya pasado 1 s desde el anterior (`Config.Servidor.TiempoMinimoEntreTiros`).
- **Revisión** (`shared/Revision.luau`): repite la simulación y **el daño que vale es siempre el del servidor** (con tope de 2000). Como es el mismo módulo, en un tiro normal coincide con el del cliente. Si el del cliente difiere más del 5 %, se avisa en la consola, sin castigar al jugador.
- **Prueba con Lune:** en los 200 tiros cliente y servidor coinciden, y un daño falso de 9999 termina usando el del servidor.
- **En Studio:** 5 tiros con daño de 20 a 30, todos iguales en cliente y servidor. Un tiro mandado a mano con 9999 se corrigió a 26 con aviso en la consola. Repetir el tiro, un ángulo de 85° y un número inválido (NaN) se rechazan.

### Etapa 4 · Monstruos, contraataque y la mazmorra (25/10/2026)

- **Reglas** (`shared/Mazmorra.luau`, sin Roblox, se prueba con Lune): el daño del tiro le pega al monstruo; si sigue vivo, contraataca con su golpe. Al ganar pasás al piso siguiente y te curás `Config.CuraEntrePeleas` (10) sin pasarte del máximo. Al ganarle al jefe termina la mazmorra. Lo decide todo el servidor: `Tirar` devuelve qué pasó en el turno y el cliente solo lo anima.
- **Números en `Config.luau`:** `Config.VidaCaballero` (50), `Config.CuraEntrePeleas` (10) y `Config.Monstruos` con los 7 de la tabla (nombres de prueba: Rata de Cloaca, Slime Verde, Murciélago, Esqueleto, Goblin con Lanza, Gólem de Piedra y el jefe Rey de los Huesos). Cada uno tiene un color de graybox. Los tiempos de la animación están en `Config.Turno`.
- **Graybox:** el monstruo es un cartel fino a la derecha del tablero (no abajo: así quedó en la ficha), con un rectángulo de su color, su nombre abajo y la barra de vida arriba. El caballero es un bloque azul a la izquierda del lanzador. Arriba: "Vida 46/50" a la izquierda y "Pelea 3 de 7" al centro.
- **Turno:** una bolita de luz va del TOTAL al cartel (0,3 s), el cartel se sacude y baja su barra. Si sigue vivo, se agranda y vuelve, la pantalla tiembla apenas, el caballero se pone rojo y baja tu vida.
- **Pantallas:** "¡Piso N!" al ganar una pelea. "Caíste en el piso N" con un botón grande "Volver a bajar", y "¡Ganaste la mazmorra!" con "Volver". Volver a bajar tarda **65 ms** entre el toque y estar jugando.
- **Arreglo:** tocar el botón de volver también soltaba una bola. Ahora, mientras está la pantalla final y hasta 0,3 s después de cerrarla, los clics no apuntan ni tiran.
- **Comando de prueba, solo en Studio:** las teclas **1 a 7** saltan a esa pelea y la **0** te pone 999 de vida (para llegar al jefe sin mejoras). Es con teclas y no con el chat porque este place usa el chat viejo, que Roblox ya no carga. El remoto `Prueba` solo existe en Studio.
- **Prueba con Lune** (`lune run plinko-knight/pruebas/mazmorra`): las reglas andan, y además juega 500 mazmorras con tiros al azar, sin mejoras.

#### Balance medido (sin mejoras, como queda en esta etapa)

| Pelea | Vida / golpe | Tiros en Studio | Tiros con Lune (2000 mazmorras) |
|---|---|---|---|
| 1 · Rata de Cloaca | 40 / 4 | 2 | 2,0 |
| 2 · Slime Verde | 60 / 5 | 3 | 2,7 |
| 3 · Murciélago | 85 / 6 | 4 | 3,6 |
| 4 · Esqueleto | 115 / 7 | 6 | 4,8 |
| 5 · Goblin con Lanza | 150 / 8 | caí al 3.er tiro | 5,0 (el 97,5 % cae acá) |
| 6 · Gólem de Piedra | 190 / 9 | — | nadie llega a ganarla |
| 7 · Rey de los Huesos | 320 / 11 | 13 y 12 (con vida 999) | 12,2 (con vida de sobra) |

- Sin mejoras se pierde en el piso 5, dentro del objetivo (pisos 4 a 6). Desde la pelea 4 se pasa de los 2 a 4 tiros por pelea, pero eso lo tienen que bajar las mejoras de la etapa 5.
- **El jefe, como está, no se puede ganar.** Tarda unos 12 tiros y te pega 11 por tiro: con 50 de vida caés en 5. Aun con el doble de daño por las mejoras, son 6 tiros y 66 de daño.
- **Cambio aprobado por Juani (25/10/2026):** el jefe pasa a **240 de vida y 8 de golpe**. Hay que volver a medir todo al terminar la etapa 5, con mejoras.

