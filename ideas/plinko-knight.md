# Plinko Knight — ficha del prototipo

Origen: `plinko-knight/PLAN-Y-PROMPTS.md` (25/10/2026) + idea de arte aprobada (`plinko-knight/arte/IDEA-DE-ARTE.md`).
Estado: **aprobada por Juani el 25/10/2026** (punto de control 1). Etapas 2 (tablero, puntería y bola), 3 (daño y revisión del servidor), 4 (monstruos y mazmorra) y 5 (mejoras 1 de 3) hechas el 25/10/2026. Juani jugó la prueba de 5 minutos (perdió en el piso 6: "está bueno") y pidió hacerlo **más roguelike, estilo Balatro**. **Rediseño aprobado el 25/10/2026.** Pasos 5a a 5d del rediseño hechos el 25/10; Juani lo jugó 10 minutos y dijo OK. Etapa 6 (guardado) hecha el 25/10; lo próximo es la etapa 7 (pantallas).
Carpeta: `plinko-knight/` (código en `plinko-knight/src/`, Rojo con `rojo serve plinko-knight`, puerto 34876). Place propio: `plinko-knight/PlinkoKnight.rbxl`.

## Rediseño roguelike (aprobado el 25/10/2026)

Después de la prueba de 5 minutos ("perdí en el piso 6, está bueno") pediste que sea **más roguelike, estilo Balatro, con más sinergias y modificadores**. De Balatro se toma **la mecánica, no el contenido**: nada de cartas de póker, ni sus nombres (comodines, ciegas, fichas), ni nada que parezca casino. Sigue siendo un caballero en una mazmorra.

Lo que hace bueno a Balatro, y cómo entra acá:

| En Balatro | En Plinko Knight |
|---|---|
| Fichas × Multi | **Fuerza × Multi**: las clavijas suman Fuerza o Multi, y al final se multiplican |
| Mejoras de cartas del mazo | **Clavijas especiales**: tu tablero es tu mazo y lo vas cambiando durante la partida |
| Comodines (el corazón de las sinergias) | **Reliquias**: hasta 5 a la vez, cada una cambia una regla, y se combinan entre sí |
| Planetas y tarots | **Pergaminos**: se usan cuando querés (suben de nivel un tipo de clavija, convierten clavijas, curan) |
| Tienda con plata e interés | **Tienda con oro** entre peleas; ahorrar da interés |
| Ciegas jefe con reglas raras | **Jefes con maña**: cada jefe rompe una regla y lo sabés antes de pelear |
| Antes que suben | **3 zonas** de 3 peleas cada una; los números crecen mucho de zona en zona |
| Mazos para elegir | **Bolas para elegir** al empezar (Hierro, Fuego, Partida), que se desbloquean |

## Concepto

Un caballero baja por una mazmorra de 3 zonas. Ataca tirando una bola desde arriba de un tablero de clavijas. Cada clavija que toca suma **Fuerza** o **Multi**; cuando cae la bola, **Fuerza × Multi** es el golpe que recibe el monstruo. Entre peleas gasta **oro** en la tienda: **reliquias** que cambian las reglas, **clavijas especiales** para su tablero y **pergaminos**. La gracia es armar una combinación que explote (pasar de golpes de 30 a golpes de 50.000) antes de que la mazmorra te gane. Si perdés, empezás de cero; lo que sí queda son las bolas y reliquias que desbloqueaste.

**No es un juego de apuestas.** Abajo del tablero no hay casilleros con multiplicadores: el Multi sale de las clavijas y de las reliquias. El oro es del juego, se pierde al terminar la partida y **nunca se vende por Robux**. No aparecen palabras de casino ni de premios al azar.

## Loop

**Un tiro (10 segundos):** apuntás, soltás. La bola rebota; cada clavija suma a una de las dos cajas del panel (FUERZA | MULTI). Las reliquias que se activan se sacuden y muestran lo que sumaron. Al caer: las dos cajas chocan, sale el golpe en grande y vuela al monstruo. Si sigue vivo, contraataca.

**Una pelea (30 a 60 segundos):** 2 a 4 tiros. Al ganar: oro, y vas a la tienda.

**Una partida (15 a 20 minutos):** 3 zonas × (2 monstruos + 1 jefe con maña) = 9 peleas. Después de cada jefe, un **cofre**: elegís 1 de 3 reliquias gratis (la pantalla de cartas que ya existe).

## Pantalla de pelea (celular en horizontal, 3 columnas)

| Izquierda | Centro | Derecha |
|---|---|---|
| Vida del caballero, oro, y el **panel de golpe**: FUERZA (azul) × MULTI (rojo) = GOLPE. Abajo, tus pergaminos (2 lugares). | El tablero con tus clavijas especiales, el caballero y el lanzador arriba. Abajo, un piso liso. | El monstruo con su vida. Si es jefe, su maña escrita arriba en un cartel. |

Arriba de todo, la fila de **reliquias** (5 lugares), en orden de izquierda a derecha, y "Zona 2 · Pelea 2 de 3".

## Cómo se calcula el golpe (Fuerza × Multi)

1. Cada tiro arranca con **Fuerza 0 y Multi 1**.
2. Cada clavija gris suma **+2 de Fuerza**. Cada clavija cuenta una vez por bola y por tiro (como ahora).
3. Las clavijas especiales suman Multi, multiplican el Multi o hacen otras cosas (tabla de abajo).
4. Cuando caen todas las bolas, las reliquias que actúan "al final del tiro" se aplican **de izquierda a derecha**. Por eso importa el orden: primero las que suman Multi y después las que lo multiplican. Las reliquias se reordenan arrastrándolas en la tienda.
5. **Golpe = Fuerza × Multi**, redondeado para abajo.

Ejemplo: 12 clavijas grises (24 Fuerza) + 2 rojas (+4 Multi, total 5) = 120. Con Corona del Rey Caído (×2 Multi) = 240.

## Clavijas especiales (tu tablero es tu mazo)

El tablero empieza con 52 clavijas grises y es **tuyo durante toda la partida**. En la tienda comprás mejoras de clavija y **vos tocás cuál clavija cambiar**. Cada tipo tiene un color y un nivel (los pergaminos lo suben).

| Clavija | Qué hace (nivel 1) | Al subir de nivel |
|---|---|---|
| Gris | +2 Fuerza | +1 Fuerza |
| Roja | +2 Multi (era +3, ver paso 5a) | +2 Multi |
| Azul (cristal) | ×2 Multi (era ×1,5). Tiene 1 en 4 de romperse y quedar como hueco hasta el final de la partida | +0,5 al × |
| Dorada | +6 Fuerza y +1 oro | +1 oro |
| Verde (resorte) | +10 Fuerza y la bola sale disparada para arriba (toca más clavijas) | +5 Fuerza |
| Violeta (eco) | +2 Fuerza (como una gris) y la próxima clavija que toque esa bola cuenta 2 veces | cuenta 3 veces |

Las clavijas rojas de la etapa 5 (×2 del total) pasan a ser las **azules**; la bola de fuego y la bola que se divide pasan a ser **bolas iniciales y reliquias**.

## Reliquias (las sinergias)

Hasta **5** a la vez. Se compran en la tienda o salen del cofre del jefe; se venden por la mitad de lo que costaron. Hay 3 rarezas: **común** (4 de oro), **rara** (7) y **legendaria** (12). Están pensadas en **familias** que se potencian entre sí. Empezamos con 20; los números son de arranque y se ajustan con pruebas de Lune.

| # | Reliquia | Rareza | Qué hace | Combina con |
|---|---|---|---|---|
| 1 | Brasa | común | +2 Multi por cada clavija roja que haya **en tu tablero** (aunque no la toques; era +1, ver 5d) | comprar rojas, Pergamino rojo |
| 2 | Corazón de Rubí | rara | las rojas dan el doble de Multi | Brasa |
| 3 | Martillo Pesado | común | +30 Fuerza si el tiro tocó 15 clavijas o más | resortes, bola partida |
| 4 | Cadena | común | +2 Multi por cada 5 clavijas tocadas en el tiro | Martillo, bola partida |
| 5 | Gemela | común | la bola se parte en 2 en el toque 6 | Cadena, Martillo, Enjambre |
| 6 | Enjambre | rara | ×1,5 Multi por cada bola extra que haya en el tiro | Gemela, bola Partida |
| 7 | Hoja Afilada | común | las bolas extra suman el doble de Fuerza | Gemela |
| 8 | Bolsa de Cuero | común | el interés de la tienda llega hasta 10 de oro (en vez de 5) | Avaro |
| 9 | Avaro | rara | +1 Multi por cada 2 de oro que tengas guardado (era cada 5, ver 5d) | Bolsa de Cuero, doradas |
| 10 | Toque de Oro | común | las doradas también dan ×1,5 Multi (era +2, ver 5d) | doradas |
| 11 | Trofeo | rara | crece: +1 Multi para siempre cada vez que matás un monstruo de un solo tiro | todo lo que haga golpes grandes |
| 12 | Callo | común | crece: +3 Fuerza para siempre cada vez que se rompe una azul | azules, Vidrio Frágil |
| 13 | Racha | rara | crece: ×0,25 Multi más por cada pelea seguida que ganás sin que te peguen; se reinicia si te pegan | jugar arriesgado |
| 14 | Yesca | rara | la quemadura de la bola de fuego hace tanto daño como tu Multi del último tiro | bola Fuego, rojas |
| 15 | Vidrio Frágil | rara | las azules dan ×3 en vez de ×2, pero se rompen 1 de cada 2 (la azul pasó a ×2 en el 5a) | Callo |
| 16 | Último Aliento | rara | ×3 Multi si te queda menos de 15 de vida | Racha (al revés: riesgo) |
| 17 | Paciencia | rara | el primer tiro de cada pelea no hace daño; el segundo tiene ×4 Multi | jefes con mucha vida |
| 18 | Corona del Rey Caído | legendaria | ×2 Multi en todos los tiros | todo |
| 19 | Eco Infinito | legendaria | las violetas hacen que la próxima clavija cuente 4 veces | violetas en zonas con muchas rojas |
| 20 | Mano de Midas | legendaria | cada clavija que toca la primera bola da +1 oro | Avaro |

## Pergaminos (se usan cuando querés)

Hay **2 lugares**. Se compran en la tienda (3 de oro) y se usan con un toque, entre tiros o en la tienda.

| Pergamino | Qué hace |
|---|---|
| Rojo / Azul / Dorado / Verde / Violeta / Gris | sube 1 nivel ese tipo de clavija, para toda la partida |
| Forja | convierte 2 clavijas que elijas en el tipo que diga el pergamino |
| Martillo | borra 1 clavija que elijas (la deja como hueco: la bola pasa derecho) |
| Vendaje | +15 de vida |
| Furia | el próximo tiro tiene ×2 Multi |

## Tienda (reemplaza a "elegí 1 de 3")

- Aparece después de cada pelea que ganás. Primero te curás 10 (como ahora).
- **Oro:** 3 por monstruo, 5 por jefe. +2 si lo mataste en 1 tiro, +1 si fue en 2. **Interés:** +1 por cada 5 de oro que tengas al entrar, hasta 5 (la Bolsa de Cuero sube el tope).
- Ofrece: **2 reliquias, 2 mejoras de clavija y 1 pergamino**. Botón **Renovar** (2 de oro, y cada vez que lo usás en la misma tienda cuesta 1 más).
- Lo que sale lo elige el servidor con la semilla de la partida. Cada reliquia muestra su rareza; las chances de cada rareza (común 70 %, rara 25 %, legendaria 5 %) se ven en un botón "¿Qué puede salir?". Como el oro **no se vende por Robux**, no cuenta como ítem pago al azar (sección 6 de la GUIA), pero mostramos las chances igual.
- Botón grande **"Bajar"** para ir a la próxima pelea.

## La mazmorra: 3 zonas y jefes con maña

| Zona | Pelea 1 | Pelea 2 | Jefe (con maña) |
|---|---|---|---|
| 1 · Cloacas | Rata de Cloaca | Slime Verde | Rey Rata |
| 2 · Catacumbas | Murciélago | Esqueleto | Goblin con Lanza |
| 3 · Trono de Hueso | Gólem de Piedra | Caballero Hueco | Rey de los Huesos |

- La vida de los monstruos crece mucho de zona en zona (como en Balatro), porque las combinaciones crecen mucho. **Números ajustados en el 5d:** zona 1: 50, 90, 140 · zona 2: 250, 420, 750 · zona 3: 1.500, 2.600, 4.500. Golpes: 4, 5, 7 · 7, 9, 11 · 11, 13, 14. (Los de arranque eran 60/110/200 · 450/800/1.500 · 3.500/6.000/12.000, y así nadie pasaba la zona 2.)
- El caballero sigue con **50 de vida** y se cura 10 entre peleas. Si llegás a 0, perdés.
- Los números grandes se escriben cortos: 12.400 → "12,4 mil", 1.500.000 → "1,5 M". El tope por tiro sube de 999 a 10 millones.

**Mañas de jefe** (el servidor sortea una por jefe con la semilla de la partida; se ve en un cartel antes de tirar):

| Maña | Qué rompe |
|---|---|
| Sangre fría | las rojas no suman |
| Cristal maldito | las azules se rompen siempre |
| Paredes vivas | las 2 columnas de los costados no cuentan |
| Avaricia | te saca 1 de oro por tiro |
| Coraza | solo cuentan los golpes de 40 o más (zona 1), 250 (zona 2) o 1.200 (zona 3) |
| Silencio | la reliquia de la izquierda no funciona |
| Viento | la bola sale más rápida y desviada |
| Rabia | si no lo matás, te pega el doble (se llama Rabia para no confundirla con el pergamino Furia) |

## Bolas para elegir (se desbloquean y se guardan)

Al empezar la partida elegís con qué bola bajás. Cada una cambia el estilo de juego:

| Bola | Qué hace | Cómo se desbloquea |
|---|---|---|
| Hierro | normal; empezás con 4 de oro más | desde el inicio |
| Fuego | +1 Fuerza por clavija; el monstruo se quema (3 por turno, 2 turnos) | llegar a la zona 2 |
| Partida | se parte en 2 en el toque 5 | ganarle a un jefe |
| (después) Cristal, Oro, Eco… | una por familia de reliquias | logros |

**Desbloqueos de reliquias:** de las 20, arrancás con 12; las otras 8 se desbloquean con logros (la lista quedó en la etapa 6). Es el motivo para volver (lo que el algoritmo de Roblox mide a 28 días).

## Sistemas del prototipo (orden nuevo)

1. **Simulación de la bola** (hecho, etapa 2).
2. **Tablero y puntería** (hecho, etapa 2).
3. **Revisión del servidor** (hecho, etapa 3): repite el tiro con las clavijas, reliquias y pergaminos de la partida, que el cliente no manda.
4. **Monstruos y mazmorra** (hecho, etapa 4; pasa a 3 zonas en la 5d).
5. **Rediseño roguelike**, en 4 pasos:
   - **5a · Fuerza × Multi y clavijas especiales.** Panel de dos cajas, 6 tipos de clavija, tablero propio de la partida. Lo de la etapa 5 se convierte (azul, bola de fuego, Gemela).
   - **5b · Oro y tienda.** Oro, interés, tienda con renovar, mejoras de clavija tocando el tablero, pergaminos.
   - **5c · Reliquias.** Las 20, con orden de izquierda a derecha, vender y reordenar. Prueba con Lune de cada una y de combinaciones.
   - **5d · Zonas, jefes con maña y cofre.** 3 zonas, 8 mañas, cofre de 1 de 3 reliquias. Balance con Lune (un bot que compra y elige).
   - **Punto de control:** prototipo jugable de nuevo, con prueba de 10 minutos.
6. **Guardado** con ProfileStore: bolas y reliquias desbloqueadas, logros, mejor zona.
7. **Pantallas**: inicio y elegir bola, pelea, tienda, cofre, derrota y victoria, colección de reliquias.
8. a 11. Estilo, arte (ahora también 20 íconos de reliquias, 6 de clavijas y 10 de pergaminos), sensación y sonido, antes de publicar.

## Números de arranque (en `plinko-knight/src/shared/Config.luau`)

| Qué | Valor |
|---|---|
| Tablero | 7 columnas × 8 filas alternadas (52 clavijas) |
| Golpe | Fuerza × Multi; cada tiro arranca con Fuerza 0 y Multi 1; gris = +2 Fuerza |
| Vida del caballero | 50; se cura 10 entre peleas |
| Lugares | 5 reliquias, 2 pergaminos |
| Oro | 3 por monstruo, 5 por jefe, +2/+1 por matar en 1/2 tiros, interés 1 cada 5 (tope 5) |
| Precios | reliquia 4 / 7 / 12 · mejora de clavija 2 (era 3, ver paso 5b) · pergamino 3 · renovar 2 (+1 cada vez) |
| Chances de rareza | común 70 %, rara 25 %, legendaria 5 % (a la vista en la tienda) |
| Monstruos (vida) | zona 1: 50, 90, 140 · zona 2: 250, 420, 750 · zona 3: 1.500, 2.600, 4.500 (paso 5d) |
| Tope por tiro | 10 millones de golpe; 4 bolas |

Objetivo de balance: con un bot que compra al azar, perder casi siempre en la zona 2; con un bot que arma una familia, ganarle al jefe de la zona 2 seguido y a veces al de la 3. Una partida ganada dura 15 a 20 minutos.

## Cómo funciona por dentro

- **La física es propia y en 2D, no la de Roblox.** La bola nunca es una pieza con física: el cliente solo la dibuja siguiendo la simulación. Así no se escapa hacia la cámara y se puede probar fuera de Studio.
- **El servidor lleva la partida** (zona, pelea, vida, oro, tablero con sus clavijas especiales, reliquias, pergaminos y monstruo). La tienda, el cofre y las mañas salen de la semilla de la partida, que tiene el servidor; el cliente solo pide ("comprar la reliquia 2", "mejorar la clavija 17") y el servidor valida oro, lugares libres y que el ítem esté en la tienda.
- **El servidor lleva la pelea** En cada tiro le da al cliente una semilla, y el cliente manda solo el ángulo y el daño que vio. El servidor corre la misma simulación con ese ángulo; si el daño no coincide (con un margen chico), usa el suyo. Además tiene un tope de daño por tiro, un límite de frecuencia y revisa que el tiro sea del turno actual. Valida tipos y números finitos.
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

Dificultades extra después de ganar (como las apuestas de color de Balatro, acá serían "profundidades"), más bolas y reliquias, reto diario con semilla fija, ranking, **cualquier cosa con Robux**, varias mazmorras, multijugador cooperativo, mascotas y tienda con Robux (la tienda de oro sí entra). Se anotan acá y no se programan. Cuando llegue Robux: aspectos de bola y de tablero. Si alguna vez hay algo al azar que se pague, van las probabilidades a la vista y PolicyService (sección 6 de la GUIA).

## Cambios respecto del plan

- **El monstruo va a la derecha, no abajo del tablero.** Lo aprobaste el 25/10 en la idea de arte: en un celular horizontal el tablero y el monstruo no entran uno arriba del otro.
- **El panel de daño tiene dos cajas** (daño | ×2). La regla de la clavija roja no cambia: solo se muestra separado.
- **Rediseño roguelike (25/10, propuesto):** el daño pasa a ser Fuerza × Multi, el "elegí 1 de 3" se cambia por una tienda con oro (el 1 de 3 queda para el cofre de cada jefe), aparecen reliquias, pergaminos, clavijas especiales, 3 zonas y jefes con maña. Las etapas 5a a 5d reemplazan a la etapa 5 del plan; las etapas 6 a 11 siguen, con más pantallas y más arte.

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

### Etapa 5 · Mejoras: elegí 1 de 3 (25/10/2026)

- **Todo pasa en `shared/Simulacion.luau`**, así el servidor repite el tiro igual: el daño por clavija con fuego, el ×2 de las rojas y la bola que se divide. Los niveles y las clavijas rojas los pone el servidor desde la partida: el cliente no los manda. Módulos nuevos: `shared/Mejoras.luau` (cuánto vale cada nivel, qué clavijas son rojas, qué cartas salen, texto de las cartas) y `shared/Azar.luau` (el generador con semilla, que ahora comparten la simulación y las mejoras).
- **Bola de fuego:** +1 por clavija (3 en vez de 2) y deja al monstruo quemándose: le saca la quemadura en el mismo turno del tiro y en el siguiente; cada tiro con fuego la vuelve a prender.
- **Clavija que duplica:** al empezar cada pelea el servidor elige las rojas con una semilla nueva, entre las filas 3 y 7 (en la primera sería ×2 de casi nada). No se mueven en toda la pelea. Al tocar una, el daño del tiro hasta ese momento se duplica; cada roja duplica una vez por tiro aunque la toquen las dos bolas.
- **Bola que se divide:** en el toque N la bola se parte en 2 con una abertura de 24° ± 8° (sale de la semilla). Las dos se simulan a la vez, paso por paso, y el tiro termina cuando caen todas. **Decisión:** cada bola suma cada clavija una vez (si las dos tocan la misma, suman las dos); si no, la segunda bola casi no sumaba.
- **Topes** (en `Config.luau`): `TopeBolas = 4` y `TopeDanioTiro = 999` por tiro.
- **Pantalla de mejoras:** al ganar una pelea salen 3 cartas grandes (nombre, una frase con los números y "Nueva" o "Nivel 2"). El servidor elige cuáles (con 3 mejoras, siempre las 3) y `ElegirMejora` solo acepta una de las ofrecidas, en la fase "eligiendo". "¡Piso N!" sale después de elegir.
- **En pantalla (graybox):** abajo, la fila "Fuego · Nv 2", "×2 · Nv 1", "Divide · Nv 1". Con fuego la bola es naranja y brilla, y la quemadura salta "+3 fuego" sobre el monstruo. Las clavijas rojas se ven rojas y al tocarlas sale un "×2" rojo grande al lado del TOTAL (1,2 s). Con la división se ven las dos bolas.
- **Comando de prueba, solo en Studio:** además de 1 a 7 y 0, las teclas **Z, X y C** suben un nivel Fuego, ×2 y Divide.
- **Prueba con Lune** (`lune run plinko-knight/pruebas/mejoras`): cada mejora en sus 3 primeros niveles, las tres juntas hasta nivel 8 (nunca más de 4 bolas ni más de 999), el servidor coincide en todos los tiros, elegir solo acepta cartas ofrecidas y la quemadura dura lo que tiene que durar.
- **En Studio:** una mazmorra eligiendo Fuego, ×2, Fuego y Divide hasta la pelea 5 jugando normal; después, con las teclas de prueba, la 6 y el jefe con las tres mejoras. En todos los tiros el daño del cliente y el del servidor coincidieron, y el servidor rechazó elegir una carta fuera de turno, una que no existe y un dato raro.

#### Balance con mejoras (lune, 300 mazmorras con tiros al azar)

Con los números de la etapa 4, las mejoras hacían todo muy fácil: eligiendo cartas al azar se ganaba el **98 %**, y eligiendo siempre fuego, el 100 % (el +1 por clavija repetido se multiplicaba con el ×2). Cambios:

- **Fuego repetido** ya no suma +1 por clavija cada vez: sube la quemadura (3 → 6 → 9).
- **Monstruos** más fuertes desde la pelea 2: 60/6, 100/7, 150/9, 210/10, 280/12 y el **jefe 380/12** (era 240/8, el que aprobaste en la etapa 4 para jugar sin mejoras).

| Cómo elige | Dónde se cae | Mazmorras ganadas |
|---|---|---|
| Sin mejoras | 81 % en la pelea 4, el resto en la 5 | 0 % |
| Cartas al azar | 7 % en la 5, 30 % en la 6, 36 % en el jefe | **27 %** |
| Siempre fuego | mitad en la 5, mitad en la 6 | 0 % |
| Siempre ×2 | 51 % en la 5, 42 % en la 6 | 1 % |
| Siempre divide | 64 % en la 5, 36 % en la 6 | 0 % |

Cada pelea dura 2 a 3 tiros de promedio. Mezclar mejoras es lo que gana (las tres se potencian entre sí). Falta que Juani lo juegue y diga qué ajustar.

### Paso 5a · Fuerza × Multi y clavijas especiales (25/10/2026)

- **Golpe = Fuerza × Multi.** Cada tiro arranca con Fuerza 0 y Multi 1. La simulación (`shared/Simulacion.luau`) suma cada clavija a su caja según el tipo y devuelve Fuerza, Multi, golpe, oro y las azules que se rompieron. El servidor repite el tiro con el tablero, los niveles y la bola de la partida (el cliente no los manda), y en todos los tiros probados coincidió.
- **Módulo nuevo `shared/Clavijas.luau`** (reemplaza a `Mejoras.luau`): lo que da cada tipo según su nivel, el tablero de la partida, convertir clavijas, las cartas y los números cortos ("12,4 mil", "1,5 M").
- **El tablero es de la partida:** una lista con el tipo de cada una de las 52 clavijas. Empieza todo gris y se reinicia al "Volver a bajar". Las azules que se rompen quedan como **hueco** (la bola pasa derecho) hasta el final de la partida.
- **Cartas, mientras no hay tienda:** al ganar una pelea salen 3 tipos de clavija distintos. Elegir uno convierte **2 grises al azar** (las elige el servidor) en ese tipo, y brillan un momento. La carta muestra una clavija de muestra, qué hace y cuántas tenés. En el paso 5b la tienda reemplaza a esta pantalla y ahí sí vas a tocar qué clavija cambiar.
- **Bolas:** la de fuego (+1 Fuerza por clavija y quemadura) y la partida (se parte en el toque 5) son las mejoras de la etapa 5 convertidas. La que se elige al empezar llega con las pantallas (etapa 7); por ahora se arranca con Hierro. "Clavija que duplica" pasó a ser la azul.
- **En pantalla (graybox):** a la izquierda, el panel **FUERZA** (azul) **×** **MULTI** (rojo) y abajo "= golpe" cuando cae la bola. Cada clavija tiene el color de su tipo, y al tocarla salta lo que sumó ("+2", "+2 Multi", "×2", "+6 +1 oro", "eco ×2: …", "¡se rompió!"). Arriba a la izquierda, el oro. Abajo, la bola y cuántas clavijas de cada tipo tenés.
- **Comandos de prueba, solo en Studio:** 1 a 7 y 0 como antes; **Z** cambia de bola, **X** convierte 2 grises (cada vez un tipo distinto), **C** sube 1 nivel todos los tipos. Ojo: si se aprietan con la bola en juego, ese tiro se anula.
- **Prueba con Lune** (`lune run plinko-knight/pruebas/clavijas`, reemplaza a `pruebas/mejoras`): cada tipo (lo que suma y que las cajas cierren), la violeta, los huecos, el resorte, la azul que se rompe, los niveles, las dos bolas, todo mezclado hasta nivel 10 (nunca pasa los topes) y que el servidor coincida en golpe, oro y rotas. `pruebas/mazmorra` ahora mide el balance con cartas de clavijas y acepta otras vidas de monstruos sin tocar Config (`lune run plinko-knight/pruebas/mazmorra 40,80,150,250,400,600,900 100`).
- **Topes nuevos:** golpe de 10 millones por tiro, Multi de 1 millón, 4 bolas.

#### Ajustes de balance del paso 5a (lune, 150 mazmorras)

- **Roja: +2 Multi** (era +3). Con +3, eligiéndola siempre se ganaba el 60 % y con los otros tipos, 5 a 18 %.
- **Azul: ×2** (era ×1,5). Con ×1,5 y la rotura casi no servía (2 %). Es lo mismo que el vidrio de Balatro: ×2 y 1 en 4 de romperse.
- **Violeta: también +2 Fuerza.** Sola sumaba menos que una gris.
- Monstruos sin cambios: el balance de verdad va en el paso 5d, con las 3 zonas. Medido ahora: cartas al azar con bola de hierro, se gana **9 %**; con fuego, 39 %; con la partida, 69 % (por eso se desbloquea tarde). La dorada todavía no sirve: el oro se usa recién en la tienda (5b).

### Paso 5b · Oro y tienda (25/10/2026)

- **Oro al ganar una pelea:** 3 (5 si es jefe), +2 si lo mataste en 1 tiro y +1 si fue en 2. Después, **interés**: +1 por cada 5 de oro que tengas, hasta 5. La dorada sigue dando oro en cada tiro. El oro es del juego, se pierde al terminar la partida y nunca se vende por Robux.
- **La tienda reemplaza a las cartas del 5a.** Se abre al ganar cada pelea, en la columna derecha (tapa al monstruo y deja el tablero libre). Ofrece **2 mejoras de clavija y 1 pergamino** (las reliquias se suman en el 5c). Arriba dice cuánto oro ganaste y por qué. Tiene **Renovar** (2 de oro, +1 cada vez en la misma tienda), **"¿Qué sale?"** con las chances de todo lo que puede salir, y **Bajar** para ir a la próxima pelea ("¡Piso N!").
- **Mejora de clavija:** la tocás en la tienda, aparece arriba "tocá 1 clavija" (con Cancelar), tocás la que quieras del tablero y se convierte. No vale un hueco ni una del mismo tipo.
- **Pergaminos** (2 lugares, a la izquierda debajo del oro; se usan tocándolos, en la pelea entre tiros o en la tienda):
  - **Pergamino de rojas / azules / doradas / verdes / violetas / grises:** sube 1 nivel ese tipo para toda la partida.
  - **Forja (de un tipo):** tocás 2 clavijas y se vuelven de ese tipo.
  - **Martillo:** tocás 1 clavija y la borrás (queda hueco).
  - **Vendaje:** +15 de vida.
  - **Furia:** el próximo tiro tiene ×2 Multi al final.

  Chances en la tienda: cada pergamino de nivel y cada forja 5,9 %; martillo, vendaje y furia 11,8 % cada uno. Cada tipo de mejora de clavija, 20 %.
- **Todo lo decide el servidor** (`shared/Tienda.luau`, remotos `Tienda` y `UsarPergamino`): qué sale (con su semilla), que haya oro, que el ítem esté y no se haya vendido, que haya lugar para el pergamino y que las clavijas elegidas existan, no sean hueco y no estén repetidas. Tiene un límite de 1 acción cada 0,15 s. Si algo no se puede, devuelve el motivo ("No te alcanza el oro") y el cliente lo muestra. Usar un pergamino anula el tiro pedido (si había) para que el servidor no repita el tiro con otro tablero.
- **Comandos de prueba, solo en Studio:** además de los anteriores, **8** da 20 de oro y **9** agrega un pergamino (cada vez uno distinto).
- **Prueba con Lune** (`lune run plinko-knight/pruebas/tienda`): el oro (base, bonus, interés y tope), qué sale en la tienda (con 3000 semillas salen todos los ítems), comprar y sus validaciones (sin oro, vendido, sin lugar, clavija que no existe, hueco, mismo tipo, índices raros), renovar, bajar, cada pergamino y la furia (con el servidor coincidiendo).
- **En Studio:** gané la primera pelea, compré una clavija azul tocando el tablero, renové, miré las chances y bajé. Después usé una forja roja (2 clavijas) y una furia: 24 × 6 = 144, igual en cliente y servidor, y como lo maté de un tiro la tienda mostró "+3 por ganar, +2 rápido, +1 interés".

#### Balance del paso 5b (lune, 150 mazmorras, un bot que compra)

- Con la mejora de clavija a 3 de oro, comprando al azar con hierro se ganaba el 3 % (en el 5a, con 2 clavijas gratis por pelea, era 9 %). Con 4 de oro por monstruo se ganaba el 29 %. Quedó **3 de oro por monstruo y la mejora a 2**: comprando al azar se gana el **21 %** con hierro, 55 % con fuego y 83 % con la partida. Comprando siempre un solo tipo casi no se gana: conviene mezclar, y las reliquias del 5c van a premiar armar una familia.
- El bot de `pruebas/mazmorra` ahora compra en la tienda: sin comprar, al azar (con cada bola), todo lo que puede o siempre un tipo. Usa los pergaminos enseguida, menos el martillo.

### Paso 5c · Reliquias (25/10/2026)

- **Las 20 reliquias de la tabla** (números en `Config.Reliquias`). Hay **5 lugares**, arriba a la derecha, en el orden en que se aplican. Tocar una abre su **ficha**: qué hace, su rareza y su lugar. En la tienda, la ficha tiene **Mover a la izquierda / a la derecha** y **Vender** (la mitad de lo que pagaste). **Decisión:** se mueven con botones y no arrastrando, porque es más fácil con el dedo en un celular.
- **Cómo actúan** (`shared/Simulacion.luau`, así el servidor las repite igual):
  - **En cada toque:** Corazón de Rubí, Toque de Oro, Vidrio Frágil, Eco Infinito, Hoja Afilada, Mano de Midas y Gemela (con Gemela, también las bolas nuevas se parten, hasta 4).
  - **Al final del tiro, de izquierda a derecha:** Brasa, Martillo Pesado, Cadena, Enjambre, Avaro, Trofeo, Callo, Racha, Último Aliento, Paciencia y Corona. Después va la furia, y la Yesca cambia la quemadura. Cuando actúan, la reliquia salta y muestra lo que hizo ("+6 Multi", "×2"); después el panel muestra la Fuerza y el Multi finales.
  - **En la partida** (`shared/Mazmorra.luau`): el Trofeo crece al matar de un tiro, el Callo con cada azul rota y la Racha con cada pelea ganada sin que te peguen (se reinicia si te pegan). La Bolsa de Cuero sube el tope del interés a 10.
- **Tienda:** ahora ofrece **2 reliquias**, 2 mejoras de clavija y 1 pergamino. Primero se sortea la rareza (común 70 %, rara 25 %, legendaria 5 %, a la vista en "¿Qué sale?") y después una de esa rareza que no tengas. Precios: 4, 7 y 12. El servidor valida que haya lugar y que no la tengas. Vender y mover, solo en la tienda.
- **Desbloqueos:** 12 reliquias están desde el principio y 8 se desbloquean con logros (en `Config.Reliquias`, campo `Desbloqueo`). Hasta que llegue el guardado (etapa 6), **las 20 pueden salir en la tienda**.
- **Arreglo del azar:** la prueba de reliquias encontró que las rarezas salían 85/12/3 en vez de 70/25/5. Pasaba con semillas chicas, porque los primeros números del generador salían muy bajos. Ahora `shared/Azar.luau` tira los primeros 12 números de cada semilla. Los recorridos de la bola cambiaron un poco (todas las pruebas siguen pasando: 13,8 clavijas por tiro de promedio).
- **Comando de prueba, solo en Studio:** además de los anteriores, **R** te da una reliquia (cada vez una distinta).
- **Prueba con Lune** (`lune run plinko-knight/pruebas/reliquias`): cada reliquia sola (el mismo tiro con y sin ella), las que crecen, la Bolsa, que el orden importa (Brasa antes de Corona da más que después), 200 combinaciones de 5 reliquias al azar (nunca pasan los topes y el servidor coincide), las chances de rareza (70/25/5 con 4000 tiendas) y comprar, vender y mover con sus validaciones.
- **En Studio:** con Brasa, Cadena, Gemela y Corona y 6 rojas, un tiro de 4 bolas hizo **58 × 54 = 3132**, igual en el servidor. Brasa sumó +6, Cadena +12 y Corona ×2, en orden. En la tienda salieron 2 reliquias; moví la Corona un lugar a la izquierda y vendí la Gemela (+2 de oro).

#### Balance del paso 5c (lune, 150 mazmorras)

| Cómo compra el bot | Mazmorras ganadas |
|---|---|
| Al azar sin reliquias (como el 5b) | 16 % |
| Al azar con reliquias, bola de hierro | 37 % |
| Al azar, bola de fuego / partida | 68 % / 81 % |
| Familia de las rojas (rojas + Brasa, Rubí, Corona, Cadena, Trofeo) | **65 %** |
| Familia de las bolas (verdes + Gemela, Enjambre, Hoja, Cadena, Martillo) | **60 %** |
| Familia del oro (doradas + Toque de Oro, Avaro, Bolsa, Midas, Corona) | 7 % |
| Siempre un solo tipo de clavija, sin reliquias | 0 a 4 % |

Armar una familia rinde mucho más que comprar al azar: las sinergias funcionan. Ahora es demasiado fácil (37 % al azar con hierro) porque los monstruos son los de la etapa 4; eso se corrige en el **5d**, con las 3 zonas y sus vidas. También queda para el 5d mejorar la familia del oro, que casi no sube el golpe.

### Paso 5d · Zonas, jefes con maña, cofre y balance (25/10/2026)

- **3 zonas de 3 peleas** (`Config.Zonas` y `Config.Monstruos`): Cloacas (Rata, Slime, **Rey Rata**), Catacumbas (Murciélago, Esqueleto, **Goblin con Lanza**) y Trono de Hueso (Gólem, Caballero Hueco, **Rey de los Huesos**). Arriba dice "Zona 2 · Catacumbas · Pelea 1 de 3" o "Jefe · Zona 2 · Catacumbas".
- **Mañas de jefe** (`Config.Manias`): al empezar la partida, el servidor sortea una distinta para cada jefe. Se ven **antes** de pelear (en la tienda: "Próximo: Goblin con Lanza (750 de vida) · Coraza: …") y **durante** la pelea, en un cartel rojo debajo de la zona.
  - En el tiro (`Simulacion`): Sangre fría, Cristal maldito, Paredes vivas (la primera y la última clavija de cada fila no cuentan), Silencio (la reliquia de la izquierda no existe) y Viento (bola 30 % más rápida y el triple de desvío).
  - En el turno (`Mazmorra`): Avaricia (−1 de oro por tiro), Coraza (golpes chicos no hacen daño) y Rabia (te pega el doble).
- **Cofre:** al ganarle al jefe de las zonas 1 y 2, la tienda abre una pantalla con **3 reliquias que no tenés** (con las mismas chances de rareza que la tienda) y te llevás **una gratis**. "Saltear" la cierra; el botón **Cofre** de la tienda la vuelve a abrir mientras no hayas elegido. Si tenés los 5 lugares llenos, vendés una y volvés a abrirlo. El servidor valida todo (`Tienda.tomarCofre`). Renovar no cambia el cofre. Si una reliquia de la tienda ya la tenés (por ejemplo, la sacaste del cofre), dice "La tenés".
- **Ajustes de reliquias para que las familias rindan parecido:** Brasa +2 Multi por roja (era +1), Avaro +1 Multi cada 2 de oro (era cada 5) y Toque de Oro ×1,5 Multi por dorada (era +2). Coraza: 40 / 250 / 1.200 según la zona (con 100 en la zona 1, el primer jefe mataba demasiado).
- **Prueba con Lune** (`lune run plinko-knight/pruebas/zonas`): las zonas, que las mañas salgan distintas y solo en jefes, cada maña haciendo lo suyo, y el cofre (aparece solo después de un jefe, no trae repetidas ni las que tenés, se toma una sola, con lugar lleno no deja y después de vender sí, el último jefe termina la mazmorra). `pruebas/mazmorra` ahora acepta `rapido` para medir solo 4 formas de jugar.
- **En Studio:** salté al Rey Rata (Avaricia, en el cartel) y le gané de un tiro (22 × 14 = 308, igual en el servidor). Cobré +5 por ser jefe, se abrió el cofre (Martillo Pesado, Cadena, Callo) y me llevé la Cadena. La tienda mostró "Próximo: Murciélago (250 de vida)". Después, el Goblin con Lanza con su maña en el cartel.

#### Balance del paso 5d (lune, 150 mazmorras con tiros al azar)

| Cómo compra el bot | Dónde cae casi siempre | Gana |
|---|---|---|
| Sin comprar | pelea 4 (77 %) | 0 % |
| Al azar, bola de hierro | zona 2 (61 %) | **7 %** |
| Al azar, bola de fuego / partida | zona 2 y 3 | 24 % / 34 % |
| Al azar sin reliquias | zona 2 (83 %) | 0 % |
| Familia de las rojas | jefe de la zona 2 (29 %) y zona 3 | 0 % |
| Familia de las bolas | repartido | **13 %** |
| Familia del oro | pelea 4 (54 %); si pasa la zona 2 casi no pierde | 0 % |
| Siempre un solo tipo de clavija | pelea 4 o 5 | 0 % |

- Se cumple lo que pedía la ficha: comprando al azar se pierde casi siempre en la zona 2. Armando una familia se le gana al jefe de la zona 2 alrededor de la mitad de las veces, y a veces se gana todo.
- El bot tira a cualquier lado; una persona apunta, así que debería irle mejor. **Lo que falta saber jugando:** si la zona 3 es demasiado dura para la familia de las rojas, y si la del oro es demasiado lenta al principio.

### Etapa 6 · Guardado (25/10/2026)

- **`server/Guardado.luau` con ProfileStore**, con la misma forma que el de Forja Rápida:
  - Bloqueo de sesión: si otro servidor toma tu sesión, te saca de este.
  - Autoguardado cada 300 s y guardado al salir.
  - Al cerrar el servidor, ProfileStore guarda a todos en paralelo.
  - Cuando Roblox avisa que reinicia el servidor (`ServerRestartScheduled`), se guarda a todos.
  - Si falla la carga: "No pudimos cargar tu progreso, volvé a entrar", sin dejarte jugar sin guardar.
  - Almacén: `Config.Guardado.Almacen` ("PlinkoKnight_Jugadores_v1").
- **Qué se guarda** (`shared/Progreso.luau`, `Config.VERSION = 1`): mejor pelea, mejor zona, mejor golpe, bolas y reliquias desbloqueadas, logros, bola elegida, partidas jugadas y ganadas, y jefes vencidos. **La partida en curso no se guarda**: si salís a la mitad, la próxima vez empezás de cero. La migración (`Progreso.migrar`) completa lo que falte, descarta lo que ya no existe y los números rotos.
- **Pantalla de inicio**, antes de cada partida (al entrar y después de perder o ganar): tu mejor pelea, jefes vencidos y partidas ganadas, y elegir la bola. Las bloqueadas aparecen en gris y dicen cómo se consiguen. La elegida queda marcada (y guardada). El servidor solo te deja bajar con una bola desbloqueada.
- **Logros y desbloqueos** (los revisa el servidor después de cada tiro y cada turno; números en `Config.Logros`):

| Desbloquea | Cómo |
|---|---|
| Bola de fuego | llegar a la zona 2 |
| Bola partida | ganarle a un jefe |
| Enjambre | tener 4 bolas en juego en un tiro |
| Avaro | terminar una zona con 20 de oro o más |
| Racha | ganar 3 peleas seguidas sin que te peguen |
| Yesca | ganarle a un jefe con la bola de fuego |
| Último Aliento | ganar una pelea con menos de 10 de vida |
| Corona del Rey Caído | hacer un golpe de 10.000 o más |
| Eco Infinito | que una clavija cuente 3 veces |
| Mano de Midas | juntar 40 de oro en una partida |

  Al desbloquear sale un aviso grande ("¡Nueva bola: Fuego!") cuando termina la animación del turno, por encima de todo (también del cofre). La tienda y el cofre solo ofrecen reliquias desbloqueadas. Un desbloqueo se guarda enseguida.
- **Arreglos que salieron probando:**
  - Al salir, la partida se borraba antes del guardado final y se perdía lo último (por ejemplo, la bola elegida). Ahora los datos se copian en el momento de salir.
  - La pantalla de inicio se dibujaba con el progreso viejo. Ahora el servidor manda primero el progreso y la pantalla se redibuja cuando llega.
  - El aviso de desbloqueo quedaba tapado por el cofre y salía antes de que terminara el tiro.
- **Comando de prueba, solo en Studio:** **L** hace como si salieras y volvieras a entrar: cierra tu sesión guardando y la vuelve a cargar del almacén.
- **Prueba con Lune** (`lune run plinko-knight/pruebas/progreso`): jugador nuevo, migración de datos rotos o viejos, cada logro una sola vez, tienda y cofre solo con desbloqueadas, y 40 partidas del bot donde el mejor piso guardado coincide con el jugado.
- **En Studio:** entré con solo Hierro; el servidor rechazó bajar con Fuego y con un dato raro. Le gané al Rey Rata: se desbloquearon Fuego y Partida. Con L (salir y volver), la partida empezó de cero pero quedaron el mejor piso 3, 1 jefe, las 3 bolas y la bola elegida (Fuego).
- **Pendiente (no se pudo probar acá):**
  - **Guardado de verdad entre sesiones:** este place no está publicado, así que Studio usa la versión de prueba de ProfileStore ("data will not be saved"). Cuando Juani lo publique: Game Settings → Security → Enable Studio Access to API Services, y probar salir y volver de verdad.
  - **Local Server con 2 jugadores:** el MCP no puede abrirlo. Cada jugador usa su propia clave ("Jugador_" + UserId), así que no se mezclan, pero hay que probarlo: Studio → Test → Clients and Servers → 2 jugadores → Start.

