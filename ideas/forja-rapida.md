# Forja Rápida — ficha del prototipo

Origen: documento de diseño de Juani (chat del 14/10/2026, versión 2: geodas, modificadores exóticos y revelación por suerte) + 5 capturas de referencia. Reemplaza a la versión 1 (rocas que daban Fuerza y Banco de Fuerza por Monedas).
Estado: **borrador, esperando OK** (punto de control 1).
Carpeta: `forja-rapida/` (código en `forja-rapida/src/`, Rojo con `rojo serve forja-rapida`, puerto 34874). Place propio en Studio.

## Concepto

Simulador de minería con gacha. En el mapa nacen geodas con vida. Les pegás con el pico hasta romperlas y, al romperse, la geoda tiembla, se pone blanca y revela una gema adentro: Común, Rara, Épica, Legendaria o Mítica. Qué tan rara sale depende de tu Suerte. Algunas geodas nacen "exóticas" (Lava, Neón, Dorada o del Vacío) y dan muchas más gemas. Las gemas se venden en el Banco por Monedas, y con las Monedas comprás Fuerza, amuletos de Suerte y picos. Con más Fuerza se abren biomas nuevos, con geodas más duras pero gemas mucho mejores.

## Loop de 30 segundos

1. Ves una geoda con su cartel ("Geoda Mediana · Exótica de Lava · 28/40 PV") y fuego alrededor. Le pegás: saltan números, baja la barra.
2. Se rompe: tiembla la cámara, destello blanco, aparece la gema con su rareza y "🍀 x2,06 Suerte · 1 en 194".
3. La gema va a la mochila. Cuando querés, vendés todo en el Banco y ves la pila de Monedas.
4. Comprás un nivel de Fuerza, un amuleto o un pico, y volvés a pegarle más fuerte. Arriba, la barra te dice cuánta Fuerza falta para la próxima zona.

## Sistemas del prototipo (6)

1. **Geodas y golpe** (hecho en código, falta probar en Studio; el golpe del cliente y los números flotantes también): `GeodeServerService.luau`. Nacen en los puntos del mapa con tag `PuntoGeoda` (atributo `Zona`, y `Jefe` para el punto de la geoda jefe). Tamaño al azar por peso, modificador exótico al azar. El servidor valida cada golpe: geoda viva, datos del jugador, máximo 8 golpes por segundo (ráfaga de 4), zona abierta para ese jugador y distancia ≤ 12 studs. El daño sale de su Fuerza, nunca del cliente. Al romperse, cada jugador que hizo al menos el 10 % de la vida (y siempre el que la rompió) tira su propia gema con su propia suerte. La gema entra a la mochila en el acto y recién después se manda la animación.
2. **Revelación y efectos** (cliente; hecho en código con el Grupo 1, falta probar en Studio): número flotante por golpe (BillboardGui con TweenService, salta y se desvanece), cartel de la geoda con nombre, modificador y barra de vida, aura del modificador, y al romperse: temblor de la roca, temblor de cámara, destello blanco, la gema girando con su color y rareza, y un cartel de suerte. Las míticas y las del Vacío con algo más grande.
3. **Mochila, Banco y Tienda**: mochila sin límite; Banco con "Vender todo" (muestra el total antes); Tienda con tres pestañas: Fuerza (de a un nivel, muestra "+X Fuerza"), Amuletos (en orden, se suman) y Picos (en orden, siempre usás el mejor, se ve en la mano).
4. **Zonas y puertas**: 5 biomas en fila, separados por barreras con la Fuerza pedida escrita arriba. Si llegás con la Fuerza suficiente se abre para siempre (no se gasta). Si no, te frena y dice "Te faltan X de Fuerza". El mapa se genera por código desde GameConfig.
5. **HUD y guía** (diseñado en Figma): Fuerza, Suerte y Monedas abajo a la izquierda; barra "Próxima zona" arriba; botones de viaje arriba al centro (Banco · Mina · Tienda); botones Tienda, Mochila e Índice a la izquierda; Índice con las 25 gemas y la tabla de probabilidades con tu suerte actual; flecha en el piso para el jugador nuevo: geoda → banco → tienda → puerta.
6. **Guardado**: ProfileStore (bloqueo de sesión, autoguardado, al salir y al cerrar el servidor). Guarda Monedas, nivel de Fuerza, pico, amuletos, mochila, Índice, zonas abiertas y geodas rotas.

## Grupo 1 — Efectos visuales y descubrimientos épicos (pedido del 14/10/2026)

Se suma a lo de arriba sin cambiar el loop: el servidor sigue decidiendo todo y el cliente solo muestra.

1. **Señales de las geodas especiales.** Cada geoda de Blender tiene dos mallas de grietas (`Grietas` y `Grietas2`) que en las exóticas se ven en Neon del color del modificador y laten. La roca de las exóticas usa una textura de cubitos (en `arte/texturas/`), imitando tus referencias: rayas de lava naranja-amarilla (la vaca de lava), cuadritos de todos los colores sobre violeta (el gato neón), oro con destellos (el cocodrilo de oro) y negro-violeta con estrellas (vacío). Aura en el cliente: Lava = chispas que suben + anillo de cubitos que gira; Neón = cubitos que cambian de color + destellos; Dorada = destellos dorados + motitas verdes; Vacío = motas violetas + estrellitas. Todo sale del atributo `Modificador` que pone el servidor.
2. **Combinaciones exóticas** (más raras que cualquier exótica simple; nombre, colores, textura, sonido y premio en `GameConfig.Modificadores`):

| Combinación | Junta | Nace | Gemas |
|---|---|---|---|
| Magma Eléctrico | Lava + Neón | 1 en 2.500 | ×15 |
| Relámpago Dorado | Dorada + Neón | 1 en 6.000 | ×50 |
| Eclipse de Lava | Vacío + Lava | 1 en 15.000 | ×75 |
| Vacío Dorado | Vacío + Dorada | 1 en 40.000 | ×250 |

3. **Descubrimiento en cadena.** Geoda especial → revelación de la gema → colección o logro → premio, todo en la misma revelación y mostrado en fila. Cada logro se marca como cobrado antes de pagarse (nunca se paga dos veces). Cuando nace una geoda del Vacío o una combinación, o alguien encuentra una gema Mítica, se avisa a todo el servidor.

| Logro | Cómo | Premio |
|---|---|---|
| Picapiedras | 100 geodas | 300 Monedas |
| ¡Brilla! | primera exótica | 200 Monedas |
| Coleccionista Exótico | una de Lava, Neón, Dorada y Vacío (las combinaciones cuentan para sus partes) | +0,25 Suerte |
| ¡Doble Exótica! | primera combinación | +0,25 Suerte |
| Maestro de las Combinaciones | las 4 combinaciones | +1 Suerte |
| Leyenda | primera Legendaria | 1.000 Monedas |
| ¡Mítico! | primera Mítica | +0,2 Suerte |
| Minero Imparable | 2.000 geodas | +0,15 Suerte |
| Colecciones 1 a 5 | las 5 gemas de una zona | 500 / 8.000 / 250K / 4M / 60M Monedas y +0,1 a +0,3 Suerte |

4. **Pulido.** Número que salta con rebote y se desvanece; destello blanco, temblor y cubitos al pegar; revelación con rayos que giran (arcoíris en las Míticas). Botón "✨ Efectos: completos / reducidos" abajo a la derecha (se guarda); si nunca se tocó, arranca reducido con la calidad gráfica de Roblox en 3 o menos. Reducido = sin destello ni temblor de cámara, sin anillo ni cubitos neón, 30 % de las partículas y auras solo a 40 studs. Siempre: un solo bucle para todas las animaciones y nada anima lejos de la cámara.

Decisiones del Grupo 1:
- Las combinaciones son filas más de la tabla de modificadores (se tiran igual, de la más rara para abajo), así no hay un sistema nuevo.
- La revelación grande (destello, temblor, tarjeta) es para Rara o mejor, o geodas exóticas. La común es un cartelito de un segundo: con una revelación grande cada tres segundos el juego cansaría.
- "Misiones" quedan para otro pedido: los logros y colecciones cumplen ese papel en la cadena.
- Partículas y luces van en el cliente (no en el servidor) para que cada uno pueda reducirlas.

## Números (en `forja-rapida/src/shared/GameConfig.luau`)

Fórmulas (en `Reglas.luau`):
- Fuerza (daño por golpe) = (1 + nivel) × 1,025^nivel × multiplicador del pico.
- Vida de una geoda = vida del tamaño × dureza de la zona.
- Suerte de una tirada = (1 + amuletos) × suerte de la zona × suerte del tamaño.
- Gema: se prueba de la más rara a la más común; cada una sale si el azar < Suerte ÷ "1 en N". Con suerte ×2, "1 en 400" pasa a "1 en 200". Siempre suma 100 % (probado con 500.000 tiradas).
- Gemas que te llevás = unidades del tamaño × premio del modificador. Monedas al vender = gemas × valor de la zona × valor de la rareza.

| Rareza | Sale con suerte ×1 | Valor |
|---|---|---|
| Común | 77,8 % | ×1 |
| Rara | 1 en 5 (19,4 %) | ×3 |
| Épica | 1 en 40 (2,5 %) | ×12 |
| Legendaria | 1 en 400 (0,25 %) | ×60 |
| Mítica | 1 en 5.000 (0,02 %) | ×500 |

| Modificador | Nace | Gemas |
|---|---|---|
| Normal | 87,1 % | ×1 |
| 🔥 Exótica de Lava | 1 en 10 | ×3 |
| ⚡ Exótica Neón | 1 en 40 | ×5 |
| 🌟 Exótica Dorada | 1 en 150 | ×10 |
| 🌌 Exótica del Vacío | 1 en 1.000 | ×25 |

| Tamaño | Vida (zona 1) | Gemas | Suerte | Aparece |
|---|---|---|---|---|
| Pequeña | 10 | 1 | ×1 | 65 % |
| Mediana | 35 | 3 | ×1,25 | 28 % |
| Gigante | 130 | 10 | ×1,6 | 7 % |
| JEFE | 1.500 | 80 | ×3 | un punto propio por zona, renace cada 90 s |

| Zona | Fuerza para abrir | Dureza | Valor | Suerte | Gemas (común → mítica) |
|---|---|---|---|---|---|
| 1 · Pradera de Cuarzo | abierta | ×1 | 1 | ×1 | Cuarzo, Jaspe, Amatista, Esmeralda, Corazón de la Pradera |
| 2 · Dunas de Ámbar | 25 | ×8 | 10 | ×1,5 | Ámbar, Citrino, Topacio, Ojo de Tigre, Sol de las Dunas |
| 3 · Glaciar de Zafiro | 700 | ×120 | 300 | ×2,5 | Cristal de Hielo, Aguamarina, Zafiro, Diamante Azul, Lágrima del Glaciar |
| 4 · Volcán de Rubí | 6.000 | ×1.100 | 4.000 | ×4 | Obsidiana, Granate, Rubí, Ópalo de Fuego, Corazón del Volcán |
| 5 · Abismo Estelar | 40.000 | ×8.000 | 50.000 | ×7 | Meteorita, Ópalo Negro, Cuarzo Estelar, Nebulita, Núcleo Galáctico |

| Tienda | Precios en Monedas |
|---|---|
| Fuerza | 10 el primer nivel, cada uno 12 % más caro (máximo 200 niveles) |
| Picos | Madera ×1 (gratis) · Piedra ×2 (25) · Hierro ×4 (5.000) · Oro ×8 (250.000) · Cósmico ×16 (8 M) |
| Amuletos | Trébol de Hierro +0,25 (300) · Herradura de Cobre +0,5 (20.000) · Estrella Fugaz +1 (1,5 M) · Ojo de Dragón +2 (60 M) · Corona Cósmica +5 (3.000 M) |

Ritmo medido con `lune run forja-rapida/pruebas/simular` (un jugador que no para, compra lo que más le rinde por moneda y vende al toque, con 15 % de tiempo extra por viajes):

| Hito | A 4 golpes/s | A 2 golpes/s |
|---|---|---|
| Pico de Piedra | 1:12 | 2:06 |
| Zona 2 | 2:11 | 3:23 |
| Trébol de Hierro | 3:01 | 4:36 |
| Pico de Hierro | 5:23 | 7:41 |
| Zona 3 | 12:00 | 15:30 |
| Pico de Oro | 14:20 | 18:50 |
| Zona 4 | 31:40 | 39:40 |
| Pico Cósmico | 35:00 | 44:40 |
| Zona 5 | 1:14 h | 1:34 h |
| Corona Cósmica | 2:10 h | 2:46 h |

## Decisiones (eran ambiguas, elegí lo más simple)

- **Fuerza = daño por golpe.** Es un solo número: las mejoras de Fuerza lo suben, el pico lo multiplica y las puertas lo piden. Cada nivel suma +1 y además un 2,5 % de todo (si no, no alcanza para zonas que piden 10 veces más).
- **Las geodas son compartidas.** Si varios le pegan a la misma, cada uno que hizo al menos el 10 % de la vida se lleva su propia gema con su suerte. Así nadie te "roba" un Jefe y jugar juntos conviene.
- **El modificador exótico multiplica la cantidad de gemas** (una Dorada da 10 gemas en vez de 1), no el valor. Así la mochila guarda solo "gema → cantidad" (25 tipos como máximo).
- **Cada zona tiene sus 5 gemas** (25 en total) y mejor suerte. Las zonas altas dan gemas más valiosas y más raras.
- **Los modificadores no dependen de tu suerte**: la geoda ya nace exótica y la ven todos.
- **La gema entra a la mochila antes de la animación**: si salís en medio, no la perdés.
- **Los picos y amuletos se compran en orden**, y siempre usás el mejor pico.
- **Los números grandes se muestran cortos**: 2,5K · 1,2M · 3B.
- El módulo de números se llama `GameConfig.luau` (como lo pediste); cumple el papel del `Config.luau` de los otros juegos. Los colores van en hex para que las pruebas con Lune lo puedan leer.
- Nombres en código: `GeodeServerService` (como lo pediste); el resto de los módulos en español como en los otros juegos.

## Cómo se ve

De las capturas se toma el estilo, no el contenido: cielo celeste brillante, piso verde lima con studs, rocas tipo vóxel (cubitos) apoyadas en un nido de escombros, cartel arriba de cada geoda con nombre, rareza y barra de vida ("2/10 PV"), destello blanco al revelar con el cartel de suerte ("🍀 x2,06 Suerte"), botones gordos con borde oscuro y texto blanco con contorno, contador grande abajo a la izquierda con el "+X" que salta, barra de progreso arriba al centro. No se copian nombres, íconos ni personajes de esos juegos.

- **Modelos 3D**: hechos en Blender con `forja-rapida/arte/scripts/modelos.py`, estilo vóxel. Cada geoda tiene cinco mallas (Roca, Cristales, Base, Grietas y Grietas2) para que el juego las pinte según la zona y el modificador; las exóticas suman una textura de cubitos (`arte/texturas/`). Las auras (chispas, anillo, destellos) son efectos de Roblox. Muestras en `arte/renders/`.
- **HUD y menús**: diseñados en Figma (link en el chat del 14/10/2026), con tres paletas para elegir.

Guía de estilo: **pendiente** (punto de control 2: elegir paleta en Figma).

## Afuera del prototipo

- Robux: ni compras ni pases. **Si alguna vez se venden Monedas por Robux**: romper geodas es gratis (no se paga por tirar), pero igual el Índice muestra siempre la tabla de probabilidades con tu suerte actual (GUIA, sección 6), así queda cubierto. Antes de vender Monedas, revisar la regla de ítems aleatorios pagos.
- Renacer (rebirth), mascotas, auto-golpe, límite de mochila, tablas de récords, analítica y eventos.
- Sonidos definitivos (quedan marcados con `-- SONIDO:` y los IDs vacíos en GameConfig: golpe, romper, revelación, revelación rara, logro, anuncio y un aura por modificador).
- Subir las texturas de `arte/texturas/` y pegar los IDs en `GameConfig.Modificadores[..].Textura`. Mientras tanto, las exóticas se ven con color, material, grietas y aura.

## Prueba que va a hacer Claude

Jugador nuevo: rompe geodas de la zona 1, ve la revelación, vende, compra el Pico de Piedra y niveles de Fuerza, abre la Zona 2. No puede pegarle a una geoda de una zona cerrada, ni desde lejos, ni más de 8 veces por segundo. Dos jugadores rompen un Jefe juntos y los dos reciben gema. Salir y volver: sigue todo. Captura en compu y en celular.
