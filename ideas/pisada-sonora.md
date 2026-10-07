# Pisada Sonora — ficha del prototipo

Origen: [2026-10-06-tendencias.md](2026-10-06-tendencias.md), idea 1.
Estado: **aprobada (2026-10-06)**, versión 2, con los cambios del usuario: melodía clásica de dominio público, checkpoints, consecuencia al caer, consumibles, tienda y conversión de velocidad a monedas.
Versión 3 (2026-10-06): OK del usuario + **nota desafinada al caer** + orden por etapas. Estilo elegido: **A — Neón nocturno**.
Versión 4 (2026-10-06): Etapa 2 con los cambios del usuario: el rebirth da monedas, tienda y conversión **físicas** en el mapa, más sonidos y más variantes de parkour.
Versión 5 (2026-10-06): Etapa 3 con los cambios del usuario: arreglo de la música, piso que se ilumina, niveles por pasos, sensación de velocidad, vendedor y HUD nuevo.
Versión 6 (2026-10-07): Etapa 4, bloques 1 y 2 (pedido del usuario): una canción por zona que sube de dificultad, pasos solo por baldosa apagada, baldosas usadas y zonas bloqueadas.
Versión 7 (2026-10-07): Etapa 4, bloques 3 (tienda con tres pestañas) y 4 (mapa con paleta y cielo por zona).
Próximo punto de control: **prototipo jugable terminado** (Etapas 1 a 4).

## Etapa 4, bloques 3 y 4 (2026-10-07)

Revisión previa con playtest: a ✅, b ✅, d ✅ (canción y cielo cambian al pisar la primera baldosa de otra zona), bloque 1 ✅ (apagado a las 10 baldosas y a los 60 s medidos), bloque 2 ✅. **c** sigue sin hacer por decisión del usuario (zona 1: 41 baldosas y 62 notas; zona 2: 35 y 35; zona 3: 6 y 38). Arreglo: si la red demoraba, el servidor rechazaba la pisada y la baldosa quedaba muda; ahora el cliente reintenta (`Config.Baldosas.ReintentoPisada`).

**Bloque 3 · Tienda** — el menú "Comprar" del vendedor tiene tres pestañas:
- *Mejoras* (varios niveles, precio = base × factor^nivel): Zapatillas, Pisada firme (+1 paso por baldosa, 5 niv.), Turbo (+4 al tope de velocidad, 5 niv.), Combo firme (el combo aguanta 1 error más por nivel, 3 niv.), Apagado rápido (−1 baldosa y −8 s por nivel, 4 niv.: llega a 6 baldosas y 28 s), Bolsillo.
- *Consumibles*: Doble paso, Escudo, Imán (15 s, prende solo de a una las baldosas apagadas a menos de 24 studs) y Reinicio (apaga al instante tus baldosas de la zona donde estás).
- *Cosméticos* (sin ventaja): estelas Fuego, Hielo y Arcoíris; efectos al pisar Chispas, Anillo y Columna. Se compran una vez; tocarlos de nuevo los pone o los saca (uno de cada tipo).
- Lo que no alcanza se ve en gris con el precio. Todo lo valida el servidor.

Decisiones (eran ambiguas, elegí la más simple):
- **Combo** (no existía): pisadas válidas seguidas. Cada una suma +1% de velocidad por paso (tope +50%). Error = pisar una baldosa prendida o caerte sin Escudo. Volver a la baldosa que acabás de prender (menos de 1,5 s) no es error. Se ve en el HUD arriba del inventario.
- El Escudo también salva el combo.
- El Imán cuenta como pisada normal: da pasos, velocidad, nota y combo.
- Para las pruebas automáticas hay un `ServerStorage.Pruebas` que solo existe en Studio (da monedas o pasos).

**Bloque 4 · Mapa** — carpeta `Workspace.Ambiente`:
- Paleta por zona (en `Config.Zonas`): zona 1 cian + violeta, zona 2 rosa + violeta, zona 3 amarillo + rosa. Las baldosas se repintaron en damero con esos dos colores.
- Postes de luz de neón a los costados de las baldosas (20 con luz real, el resto solo neón), columnas oscuras con aros, plataformas flotantes y notas musicales gigantes. Zona 2 suma teclas de piano flotando; zona 3, un pentagrama de luz; zona 1, ondas detrás del spawn.
- Fondo por zona: un disco de luz grande y lejano (`Ambiente.Fondos`, siempre cargado). Cielo por zona (bruma, horizonte, luz ambiente y estrellas) que cambia con fundido en el cliente (`AmbienteZona.client.luau`).
- El piso no cambió de brillo; la decoración está fuera de la pista para que el piso siga siendo lo que más se distingue.
- Rendimiento (antes del ajuste de luz): 339 piezas, ancladas, sin colisión, sin sombras y sin consultas de física; 20 luces sin sombra.

**Ajuste de mapa y luz (pedido del usuario, 2026-10-07)**
- Más luz: brillo 1,2 → 2,2, exposición −0,25 → +0,15, luz del cielo sobre los materiales 0,3 → 0,7, bruma menos densa (0,22) y menos haze (0,25), bloom un poco más fuerte, y corrección de color (contraste +0,1, saturación +0,2). Luz ambiente de cada zona más clara. Todo en `Config.Ambiente` y `Config.Zonas`.
- Las baldosas suben un poco (apagada 0,3, prendida 0,6) para que el camino se lea en celular, pero siguen por debajo del entorno.
- Mapa: bordes de luz donde termina el camino (marcan bien el piso), arcos de neón con luz sobre los tramos rectos (uno cada ~40 studs) y un suelo lejano oscuro con cuadrícula de luz del color de la zona, para que no se vea vacío abajo.
- Total de `Workspace.Ambiente`: 582 piezas y 31 luces sin sombra.

## Etapa 4 (pedido del usuario, 2026-10-07)

Revisión previa (playtest + código): estos puntos **no** estaban hechos.
- a. Pasos y velocidad solo al pisar una baldosa apagada → antes se sumaban por distancia caminada en cualquier lado. **Se arregla en el bloque 1.**
- b / d. Una canción por zona, que cambia al pasar de zona → había una sola canción. **Se arregla: una canción por zona, cada puerta abre una más difícil.**
- c. Una baldosa por nota → el usuario decidió que no hace falta; la canción avanza nota por nota con cada pisada válida y da la vuelta al terminar.

**Canciones por zona** (dominio público, una más difícil que la otra)
- Zona 1: *Oda a la Alegría* (Beethoven, 1824) — fácil: notas seguidas, poco salto.
- Zona 2: *Para Elisa* (Beethoven, 1810) — media: semitonos y saltos más grandes.
- Zona 3: *Marcha turca* (Mozart, 1783) — difícil: rápida, cromática y con más registro.

**Bloque 1 · Baldosas usadas**
1. Una baldosa pisada queda prendida y no se puede volver a usar: mientras está prendida no suma paso, no suma velocidad y no suena.
2. Se apaga y vuelve a estar disponible con lo que pase primero: pisaste 10 baldosas más después de ella, o pasó 1 minuto desde que la pisaste.
3. Al apagarse hace un fundido suave.
4. Los dos valores van en `Config.luau` por separado.
5. El estado es por jugador y lo controla el servidor.

**Bloque 2 · Zonas bloqueadas**
6. La zona siguiente no se ve mientras está bloqueada: una pared de niebla opaca detrás de la puerta tapa todo lo que hay atrás.
7. Sobre cada puerta bloqueada, un candado grande con el nivel que pide.
8. Al desbloquearla: el candado se abre con una animación, la niebla se disuelve y se revela la zona.
9. En el HUD, las zonas bloqueadas aparecen con candado.

### Decisiones de la Etapa 4 (eran ambiguas, elegí la más simple)

- Zonas: la 1 va desde la plaza hasta la puerta 1, la 2 hasta la puerta 2 y la 3 es el parkour hasta la meta. Cada baldosa tiene un atributo `Zona`.
- El cliente avisa "pisé esta baldosa"; el servidor valida (que estés encima, que no sea demasiado rápido, que esté apagada para vos) y decide paso, velocidad, nota y cuándo se apaga. Al haber ida y vuelta con el servidor, en un servidor real la nota puede sonar unas centésimas tarde.
- "Pisé 10 baldosas más" cuenta solo pisadas válidas (baldosas apagadas).
- Al entrar a otra zona la canción arranca desde el principio y aparece un aviso con su nombre.
- Cada pisada válida da 1 paso (`Config.PasosPorBaldosa`). Como ahora hay menos pasos que antes (una baldosa mide 8 studs y antes contaba un paso cada 4), los niveles son más baratos: 30 pasos para el nivel 2 y 15 más por cada nivel siguiente.
- La niebla y el candado son visuales y por jugador (cada uno ve los suyos según su nivel). Quién pasa lo siguen decidiendo las puertas en el servidor.
- Si subís de nivel lejos de la puerta, la animación del candado se guarda y se ve cuando te acercás.

### Cómo quedó en el mapa (Etapa 4)

- `Pista.Bloqueos` > `Bloqueo1` y `Bloqueo2` (Models con streaming Persistent): `Niebla` (pared de neón violeta oscuro de 520 × 300 studs, 2,5 studs detrás de la puerta), `Bruma` (humo que se mueve delante de la pared) y `Candado` (cuerpo con "NIVEL N" y arco de neón rosa que gira sobre su pata izquierda).
- El cartel de cada puerta subió por encima del candado: dice qué zona abre y cuántos pasos te faltan.
- HUD: debajo de la tarjeta, `Zonas` con tres fichas. Las bloqueadas muestran candado y "NIV N"; la zona donde estás, con borde amarillo.
- Cada baldosa tiene el atributo `Zona`: 41 en la zona 1, 35 en la 2 y 6 en la 3.

## Etapa 3 (pedido del usuario) — se hace por bloques, con un playtest por bloque

**Bloque 1 · Arreglos**
1. La música tiene que sonar desde el primer paso en todas las baldosas.
2. Bajar el brillo de las baldosas y del ambiente para que no encandile.

**Bloque 2 · Piso que se ilumina**
3. Las baldosas arrancan apagadas. Al pisarla se enciende con un fundido suave y queda encendida.
4. Cada baldosa se apaga sola 5 minutos después de la última pisada, también con fundido.

**Bloque 3 · Niveles**
5. Cada nivel pide una cantidad de pasos totales acumulados, que crece de un nivel al siguiente.
6. El nivel sale de los pasos totales históricos: nunca baja.
7. Las puertas piden un nivel mínimo (no velocidad). El nivel requerido se ve sobre cada puerta.
8. Al subir de nivel: efecto alrededor del personaje, sonido y cartel en pantalla.

**Bloque 4 · Sensación de velocidad**
9. Más rápido = animación de correr más rápida, estela detrás del personaje y cámara un poco más abierta.
10. 4 tramos de velocidad, cada uno con estela de otro color y partículas más intensas.
11. Al cruzar una puerta: destello, partículas y sonido.

**Bloque 5 · Tienda con vendedor**
12. Un vendedor en la plaza reemplaza a los puestos. Te acercás, aparece "Hablar" y se abre un menú: "Vender pasos" y "Comprar".
13. Vender pasos: los **pasos disponibles** (saldo aparte de los pasos totales) se cambian por monedas. Vender no baja el nivel.
14. Comprar: las mejoras y los consumibles de la Etapa 2.
15. Toda compra y venta se valida en el servidor.

**Bloque 6 · HUD**
16. HUD nuevo con la guía de estilo: nivel con barra al siguiente, velocidad, pasos disponibles y monedas. Legible en celular y sin tapar el centro.

Todos los números nuevos van en `Config.luau`. Cada sonido nuevo queda marcado con `-- SONIDO:`.

### Decisiones de la Etapa 3 (eran ambiguas, elegí la más simple)

- Música: la causa era que las 76 baldosas de los primeros tramos no tenían el atributo `Baldosa = true` (solo las del tramo 3). Se les puso y además el sample se precarga al entrar, para que suene desde la primera pisada.
- El brillo de las baldosas lo pone el código (`Config.Baldosas`), sobre el color del estilo guardado en cada baldosa. El ambiente (luz, bloom, bruma) sale de `Config.Ambiente` y lo aplica el servidor al arrancar.
- El piso iluminado es tuyo: cada jugador ve encendidas las baldosas que pisó él. Es solo visual.
- Los 5 minutos se cuentan desde la **última** pisada de esa baldosa. Si la baldosa sale y vuelve por streaming, recuerda su estado.
- Niveles: arrancás en el nivel 1. Para pasar del nivel n al n+1 hacen falta `50 + 25 × (n − 1)` pasos (50, 75, 100...). Los números están en `Config.Niveles`.
- Un paso es distancia real recorrida (4 studs). El Doble paso sigue duplicando la velocidad, no los pasos.
- Puertas: la 1 pide nivel 3 y la 2 pide nivel 5 (`Config.NivelPuertas`). Como el nivel no baja, una puerta que abriste queda abierta para siempre, también después del rebirth.
- El rebirth sigue igual (velocidad → monedas). Ahora hay dos formas de ganar monedas: rebirth y vender pasos.
- Vender pasos: un solo botón "Vender todo", 2 pasos = 1 moneda (`Config.PasosPorMoneda`).
- Los 4 puestos de la tienda se guardaron en `ServerStorage.Retirado_PuestosTienda` (no se borraron) y el vendedor ocupa su lugar. El cartel "TIENDA" queda sobre el vendedor.
- El servidor solo acepta compras y ventas si estás cerca del vendedor.
- Tramos de velocidad: se miden con la rapidez real del personaje (no la de la stat), así la estela aparece solo cuando corrés.
- Estela y partículas se ven en todos los jugadores (cada cliente las dibuja). El cartel y el sonido de subir de nivel son solo para vos; el efecto alrededor del personaje lo ven todos.
- El efecto de cruzar una puerta es local (lo ves vos).
- La tabla de jugadores suma la columna Nivel.

## Etapa 1 (núcleo) — se prueba primero

1. Las baldosas tocan una melodía clásica de dominio público, nota por nota, con un solo sample de piano.
2. Un checkpoint después de cada puerta.
3. Al caerte: suena una nota desafinada (mismo sample, tono corrido medio semitono), perdés 10% de la velocidad y reaparecés en el último checkpoint.

## Etapa 2 (pedido del usuario)

5. El rebirth convierte tu velocidad en monedas y además sube el multiplicador.
6. Una tienda donde las monedas compran mejoras permanentes.
7. Dos consumibles en la tienda: Escudo (perdona una caída) y Doble paso (30 s).
8. Tienda y conversión físicas (puestos en el mapa, no botones del HUD).
9. Que se escuche: efectos con el mismo sample de piano.
10. Más variantes de parkour.

Todos los precios y valores van en `Config.luau`.

## Concepto en una línea

Obby incremental: cada paso te da velocidad y pasos, cada baldosa que pisás se ilumina y toca la siguiente nota de una melodía clásica, y los pasos totales te suben de nivel (abre puertas). En el portal de rebirth tu velocidad se convierte en monedas; al vendedor le vendés pasos y le comprás mejoras y consumibles.

## Loop de 30 segundos

1. Corrés por el anillo: cada paso suma velocidad y la melodía avanza nota por nota.
2. Llegás a una puerta que pide un nivel mínimo; si te falta, das otra vuelta (el cartel dice cuántos pasos faltan).
3. Pasás, tocás el checkpoint y encarás el tramo de saltos. Si te caés, perdés un poco de velocidad y volvés al checkpoint.
4. En el camino agarrás consumibles (Doble paso, Escudo).
5. Decidís: ¿hago rebirth ya (menos monedas) o sigo juntando velocidad para pasar la próxima puerta?

## Sistemas

| # | Sistema | Dónde | Qué hace |
|---|---|---|---|
| 1 | **Pasos y velocidad** | servidor + UI | Cuenta pasos por distancia (validada en el servidor). Cada paso suma 1 a los **pasos totales** (dan el nivel) y a los **pasos disponibles** (se venden), y suma velocidad: `PuntosPorPaso × multiplicador de rebirth × bonus de zapatillas × doble paso`. Ajusta `WalkSpeed` con un tope. |
| 2 | **Piso que se ilumina y melodía** | cliente | Las baldosas arrancan apagadas. Cada baldosa que pisás se enciende con fundido y toca **la siguiente nota** de la melodía (Oda a la Alegría, Beethoven, 1824, de dominio público) con **un solo sample de piano**. Se apaga sola 5 minutos después de la última pisada. |
| 3 | **Niveles** | servidor + UI | El nivel sale de los pasos totales y nunca baja (`Niveles.luau`). Al subir: onda de luz y chispas alrededor del personaje (las ven todos), cartel "¡NIVEL N!" y sonido. |
| 4 | **Puertas, checkpoints y caídas** | servidor | Puertas por **nivel mínimo** (colisión por jugador), con el nivel que piden y los pasos que te faltan encima de cada una. Un checkpoint detrás de cada puerta. **Al caer**: volvés al último checkpoint y perdés el 10% de la velocidad, salvo que tengas un Escudo. |
| 5 | **Rebirth (portal)** | servidor + mapa | Portal en la plaza del inicio (ProximityPrompt). Pide 150 de velocidad: toda tu velocidad pasa a monedas (1 a 1, +20% por nivel de Bolsillo), la velocidad y el checkpoint vuelven a 0 y el multiplicador sube +0,5. El nivel no cambia. |
| 6 | **Vendedor (Don Compás)** | servidor + mapa + UI | Personaje en la plaza con "Hablar". Menú con **Vender pasos** (2 pasos disponibles = 1 moneda, botón "Vender todo") y **Comprar**: Zapatillas, Bolsillo, Doble paso y Escudo. El servidor valida cercanía, espera entre pedidos y saldo. |
| 7 | **Consumibles** | servidor + UI | **Doble paso**: cada paso vale doble de velocidad durante 30 s (botón del HUD). **Escudo**: te perdona una caída (se usa solo). Se compran al vendedor o se agarran en el mapa (reaparecen cada 30 s). |
| 8 | **Sensación de velocidad** | cliente | 4 tramos de rapidez (desde 20, 28, 36 y 44 studs/s) con estela y chispas cian, violeta, rosa y amarilla. Animación de correr hasta 40% más rápida y cámara que se abre hasta 14°. Al cruzar una puerta: destello, chispas y sonido. |
| 9 | **HUD** | UI | Tarjeta arriba a la izquierda: nivel con barra al siguiente, velocidad, pasos disponibles y monedas (aviso de "Rebirth listo" debajo cuando corresponde). Se escala con el alto de la pantalla. Consumibles abajo al centro. |
| 10 | **Guardado** | servidor | Velocidad, pasos totales, pasos disponibles, rebirths, checkpoint, monedas, mejoras e inventario. DataStore solo funciona en lugares publicados: mientras tanto se guarda en memoria y avisa por consola. |
| 11 | **Sonidos** | cliente | Todos los efectos salen del mismo sample de piano: checkpoint, compra, rebirth, recoger, usar, escudo, trampolín, subir de nivel, cruzar puerta, hablar, vender, error y caída (notas desafinadas). Cada efecto es una lista de notas en `Config.Efectos`. |
| 12 | **Parkour** | cliente | Plataformas que se mueven, baldosas que desaparecen, trampolín, cinta que te tira para atrás, barra giratoria que empuja y viga angosta. Las mueve cada cliente con el reloj del servidor, así el personaje viaja suave encima. |

## Decisiones tomadas (eran ambiguas, elegí la más simple)

- "Al caerte pase algo" → perdés el 10% de la velocidad, con un aviso en pantalla. El Escudo te salva.
- La melodía avanza por pasos, no por baldosa fija: camines para donde camines, suena la melodía en orden. El ritmo lo ponés vos con tu velocidad.
- Rebirth y conversión son una sola cosa (el portal). Se sacaron el botón Convertir y la tienda del HUD.
- Se sacaron Turbo y Resorte: la tienda tiene solo los dos consumibles pedidos. El trampolín reemplaza al salto alto.
- Segunda mejora permanente: Bolsillo (más monedas por rebirth), para que haya una elección en la tienda.
- Rebirth más barato (150) y multiplicador +0,5, porque ahora el rebirth también es la forma de ganar monedas.
- El parkour se mueve en el cliente (si lo moviera el servidor, el personaje no viajaría encima).
- La barra giratoria no choca: al tocarte te da un empujón fijo (`Config.Parkour`). Con choque físico te podía mandar a volar lejos.
- Los checkpoints del parkour no piden velocidad (no tienen puerta).
- El juego usa streaming: los scripts del cliente registran también las partes que llegan después.
- Sonido: el sample carga y suena (medido en el playtest). Si no se oye, revisar que Studio o Windows no estén silenciados.
- Los consumibles del mapa son para todos: cuando alguien agarra uno, desaparece y reaparece a los 30 s.
- Inventario: máximo 9 de cada consumible.
- Comprar y agarrar consumibles es determinista: nada de cajas ni azar.

## Mundo

- Anillo 1 (36 baldosas) con el spawn al sur.
- Camino → Puerta 1 (nivel 3) → Checkpoint 1.
- Tramo de saltos (5 plataformas).
- Anillo 2 (28 baldosas).
- Plaza del inicio (al sur del spawn): vendedor Don Compás con su mostrador (bajo el cartel "TIENDA"), una luz suave encima (`LuzVendedor`, para que se vea de noche) y portal de rebirth. Los 4 puestos viejos están en `ServerStorage.Retirado_PuestosTienda`.
- Tramo de saltos: la plataforma 2 se mueve de costado y la 4 desaparece al pisarla.
- Camino → Puerta 2 (nivel 5) → Checkpoint 2.
- Tramo 3 (parkour): cinta → trampolín → Checkpoint 3 (arriba) → 4 baldosas que desaparecen → plaza con barra giratoria → 2 plataformas móviles → viga angosta → Meta.
- Consumibles: Doble paso en el anillo 1 y en el anillo 2, Escudo antes de los saltos.
- El trazado está pintado con el estilo Neón nocturno (2026-10-06). HUD en `StarterGui.HUD` (Tarjeta, Inventario, Aviso, CartelNivel, Destello) y menú en `StarterGui.MenuVendedor`, con fuente Michroma. El panel viejo del HUD está en `ServerStorage.Retirado_HUDViejo`.

## Audio (todo en `Config.luau`)

- Nota de piano: "Piano Note C4", gratuita en la Creator Store (ID 96243649310055). Reemplazable.
- Melodía: Oda a la Alegría (Beethoven), escrita en semitonos dentro de `Config.Melodia`.
- Efectos nuevos de la Etapa 3 (mismo sample, marcados con `-- SONIDO:`): SubirNivel, Puerta, Hablar y Vender.
- Partículas: textura de chispas que viene con Roblox (`rbxasset://textures/particles/sparkles_main.dds`), sin assets externos.
- El vendedor usa la animación "quieto" por defecto de Roblox.

## Queda AFUERA del prototipo

- Más de tres zonas o canciones.
- Mascotas, Robux, gamepasses, tablas de posiciones.
- Efectos visuales elaborados más allá de estelas, chispas y destellos (Etapa 3).

## Pregunta que tiene que responder el prototipo

¿Escuchar la melodía mientras corrés, y elegir entre rebirth y tienda, dan ganas de dar "una vuelta más"?

## Guía de estilo

**Elegida: A — Neón nocturno.** Respetarla en todo el juego:

- Paleta: #FF3CAC rosa, #2BD2FF cian, #7B2FF7 violeta, #FFE45E amarillo, #14112B fondo.
- Baldosas: cuadradas y finas, material Neon sobre base de vidrio oscuro.
- Puertas y checkpoints: marcos de neón (puertas rosa, checkpoints cian, meta amarilla).
- Luz: noche (ClockTime 0), bruma violeta, mucho bloom.
- Fuente de la UI: Michroma.
- Cada zona usa dos colores de la paleta (zona 1 cian + violeta, zona 2 rosa + violeta, zona 3 amarillo + rosa) y su propio cielo.

Las muestras quedaron guardadas en `ServerStorage.MuestrasEstilo` (fuera del mapa). Puertas: rosa si te falta velocidad, cian si ya pasás. Bases de vidrio oscuro debajo de cada baldosa en `Pista.Bases`.

Propuestas:

| | A — Neón nocturno | B — Pastel de día | C — Madera al atardecer |
|---|---|---|---|
| Paleta | #FF3CAC rosa, #2BD2FF cian, #7B2FF7 violeta, #FFE45E amarillo, #14112B fondo | #4FCFA8 menta, #FF9461 durazno, #9C7DFF lila, #FFD43B manteca, #2E3A59 azul marino | #D9643A terracota, #E8B23A mostaza, #6B8F3E oliva, #F2E3C6 crema, #3B2A20 marrón |
| Materiales | Neon sobre base de vidrio oscuro | SmoothPlastic mate | WoodPlanks sobre marco de Wood |
| Luz | Noche (ClockTime 0), bruma violeta, mucho bloom | Mediodía, cielo celeste, bruma suave | Atardecer, bruma naranja cálida |
| Formas | Baldosas cuadradas finas, marcos de neón | Discos redondos con borde azul, postes con bolitas | Tablones cuadrados gruesos, marcos de madera |
| Fuente | Michroma | FredokaOne | Bangers |
