# Forja Rápida — ficha del prototipo

Origen: documento de diseño de Juani (chat del 14/10/2026, versión 2: geodas, modificadores exóticos y revelación por suerte) + 5 capturas de referencia. Reemplaza a la versión 1 (rocas que daban Fuerza y Banco de Fuerza por Monedas).
Estado: **borrador, esperando OK** (punto de control 1).
Carpeta: `forja-rapida/` (código en `forja-rapida/src/`, Rojo con `rojo serve forja-rapida`, puerto 34874). Place propio en Studio.

## Concepto

Simulador de minería con gacha. En el mapa nacen geodas con vida. Les pegás con el pico hasta romperlas y, al romperse, la geoda tiembla, se pone blanca y revela una gema adentro: Común, Rara, Épica, Legendaria o Mítica. Qué tan rara sale depende de tu Suerte. Algunas geodas nacen "exóticas" (Lava, Neón, Dorada o del Vacío) y dan muchas más gemas. Las gemas se venden en el Banco por Monedas, y con las Monedas comprás Fuerza, amuletos de Suerte y picos. Con más Fuerza se abren biomas nuevos, con geodas más duras pero gemas mucho mejores.

## Loop de 30 segundos

1. Ves una geoda con su cartel ("Geoda Mediana · Exótica de Lava · 28/40 PV") y fuego alrededor. Le pegás: saltan números, baja la barra.
2. Se rompe: tiembla la cámara, destello blanco, aparece la gema con su rareza y "x2,06 Suerte · 1 en 194" con el ícono de trébol.
3. La gema va a la mochila. Cuando querés, vendés todo en el Banco y ves la pila de Monedas.
4. Comprás un nivel de Fuerza, un amuleto o un pico, y volvés a pegarle más fuerte. Arriba, la barra te dice cuánta Fuerza falta para la próxima zona.

## Sistemas del prototipo (6)

1. **Geodas y golpe** (hecho en código, falta probar en Studio; el golpe del cliente y los números flotantes también): `GeodeServerService.luau`. Nacen en los puntos del mapa con tag `PuntoGeoda` (atributo `Zona`, y `Jefe` para el punto de la geoda jefe). Tamaño al azar por peso, modificador exótico al azar. El servidor valida cada golpe: geoda viva, datos del jugador, máximo 8 golpes por segundo (ráfaga de 4), zona abierta para ese jugador y distancia ≤ 12 studs. El daño sale de su Fuerza, nunca del cliente. Al romperse, cada jugador que hizo al menos el 10 % de la vida (y siempre el que la rompió) tira su propia gema con su propia suerte. La gema entra a la mochila en el acto y recién después se manda la animación.
2. **Revelación y efectos** (cliente; hecho en código con el Grupo 1, falta probar en Studio): número flotante por golpe (BillboardGui con TweenService, salta y se desvanece), cartel de la geoda con nombre, modificador y barra de vida, aura del modificador, y al romperse: temblor de la roca, temblor de cámara, destello blanco, la gema girando con su color y rareza, y un cartel de suerte. Las míticas y las del Vacío con algo más grande.
3. **Mochila, Banco y Tienda** (hecho en código: `Economia.luau` en el servidor y los menús Mochila y Tienda; falta probar en Studio): mochila sin límite; Banco con "Vender todo" (muestra el total antes); Tienda con tres pestañas: Fuerza (de a un nivel, muestra "+X Fuerza"), Amuletos (en orden, se suman) y Picos (en orden, siempre usás el mejor, se ve en la mano).
4. **Zonas y puertas**: 5 biomas en fila, separados por barreras con la Fuerza pedida escrita arriba. Si llegás con la Fuerza suficiente se abre para siempre (no se gasta). Si no, te frena y dice "Te faltan X de Fuerza". El mapa se genera por código desde GameConfig. (Hecho: la zona se abre sola apenas tu Fuerza llega, con un cartel "¡Zona nueva!". Falta el mapa con las barreras.)
5. **HUD y guía** (diseñado en Figma, rehecho en código con piezas de ForgeGUI: ver "HUD y menús v3"): Monedas, Suerte y Fuerza arriba a la derecha; barra "Próxima zona" abajo al centro; botones de menús a la izquierda; Índice con las 25 gemas y la tabla de probabilidades con tu suerte actual; flecha en el piso para el jugador nuevo: geoda → banco → tienda → puerta.
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

4. **Pulido.** Número que salta con rebote y se desvanece; destello blanco, temblor y cubitos al pegar; revelación con rayos que giran (arcoíris en las Míticas). Opción "Efectos reducidos" en el panel de Ajustes, abajo a la derecha (se guarda); si nunca se tocó, arranca reducido con la calidad gráfica de Roblox en 3 o menos. Reducido = sin destello ni temblor de cámara, sin anillo ni cubitos neón, 30 % de las partículas y auras solo a 40 studs. Siempre: un solo bucle para todas las animaciones y nada anima lejos de la cámara.

Decisiones del Grupo 1:
- Las combinaciones son filas más de la tabla de modificadores (se tiran igual, de la más rara para abajo), así no hay un sistema nuevo.
- La revelación grande (destello, temblor, tarjeta) es para Rara o mejor, o geodas exóticas. La común es un cartelito de un segundo: con una revelación grande cada tres segundos el juego cansaría.
- "Misiones" quedan para otro pedido: los logros y colecciones cumplen ese papel en la cadena.
- Partículas y luces van en el cliente (no en el servidor) para que cada uno pueda reducirlas.

## Grupo 6 — Eventos dinámicos del mundo (pedido del 14/10/2026)

Cada 7 a 12 minutos (el primero a los 4) arranca un evento al azar, con un cartel 20 segundos antes. Nunca se repite el mismo dos veces seguidas. Mientras dura, el cielo cambia de tinte, aparece un cartel arriba con la cuenta regresiva y el mapa hace algo distinto. Todo está en `GameConfig.Eventos` (duración, peso para salir, multiplicadores y premios); `Activos = false` los apaga.

| Evento | Dura | Sale | Qué cambia en el mapa | Premio temático |
|---|---|---|---|---|
| Lluvia de Cristales | 1:30 | 30 % | Caen cristales cerca de los jugadores (uno cada 2,5 s, duran 12 s) | Cada cristal agarrado: 25 × el valor de una gema común de tu mejor zona |
| Erupción Volcánica | 2:00 | 22 % | Bombas de lava, cielo naranja, se renueva el 35 % de las geodas | Lava sale 4 veces más y da el doble de gemas |
| Tormenta Neón | 2:00 | 22 % | Rayos de colores, cielo violeta | Neón sale 4 veces más y da el doble |
| Eclipse del Vacío | 1:30 | 10 % | Todo se oscurece | Vacío sale 6 veces más y +50 % de suerte |
| Fiebre de Minería | 2:30 | 18 % | Barra de meta compartida (40 geodas por jugador, mínimo 60) | Cada geoda da x1,5 y, si llegan, 60 gemas comunes de tu mejor zona para todos |
| Jefe Ancestral | 3:00 | 12 % | Aparece una geoda enorme con runas doradas; su vida crece con la Fuerza de los que están | Cada uno que hizo al menos el 2 % del daño se lleva una gema de su mejor zona con suerte x5 y modificador casi seguro; si no la rompen, se va |

- Las combinaciones que llevan el modificador del evento también suben (por ejemplo Lava+Neón en la Erupción y en la Tormenta).
- Las probabilidades del Índice y de la revelación ya incluyen el evento: siempre suman 100 %.
- Participar (romper algo durante el evento) suma al logro "Cazador de Eventos" (5 eventos).
- En Studio se puede forzar uno para probar: atributo `ForzarEvento` en Workspace con el Id del evento.

## Grupo 7 — Exhibición social (pedido del 14/10/2026)

La regla: lucirse sin molestar. Nada va al chat y nada de esto da premios ni hace falta para avanzar.

- **Vitrinas y estatuas**: cada jugador recibe una vitrina libre al entrar. Arriba gira y flota una estatua de su mejor hallazgo (la gema en grande, del color de su rareza) con un cartel: nombre, título, gema, rareza en degradé y "1 en N". Desde el menú "Mi Vitrina" se elige cuál de tus 5 mejores hallazgos mostrar.
- **Títulos**: 11 títulos que se ganan con logros (Picapiedras, Cazador de Exóticas, Cazador de Jefes, Maestro de Combinaciones, etc.). El elegido se ve arriba de tu cabeza con su degradé. Cada uno puede ocultar los títulos de los demás.
- **Anuncios de hallazgos**: solo gemas Míticas y geodas Vacío o de combinación (las más raras). Salen como cartel arriba de la pantalla (no en el chat), como mucho uno cada 6 segundos y con fila de 4 (lo que sobra se descarta). Ajustes: "Anunciar mis hallazgos" y "Ver hallazgos de otros". Los de eventos y jefes se ven siempre porque son pocos.
- **Clasificación semanal**: 4 tablas (Geodas rotas, Exóticas rotas, Jefes Ancestrales y Hallazgo más raro), top 10, se reinicia cada lunes. Se ve en tableros del mapa y en el menú "Clasificación", con un cartel que dice "solo para lucirse". Sin premios: así no obliga a nadie a competir.
- **Récords de jefes**: al romper un Jefe Ancestral sale el podio de daño (top 3) y cada uno ve su puesto. Se guarda tu mayor daño y tu mejor puesto; si los superás, aparece "¡Nuevo récord personal!".
- **Luz**: `ColorCorrection` en Lighting con Brillo 0,05, Contraste 0,15, Saturación 0,1 y color blanco (lo pediste). Durante los eventos se suma otro tinte suave que se va al terminar.

## HUD y menús v3 — ForgeGUI (pedido del 14/10/2026)

Pedido: rehacer todo el HUD y los menús con ForgeGUI. Así quedó armado:

- **Las piezas son imágenes de ForgeGUI** y están en `GameConfig.Gui`: botones de 7 colores y uno blanco para teñir, la X de cerrar, el panel de las ventanas, la cabecera con rayas, la baldosa (gemas, títulos y filas), el fondo y el relleno de las barras, la píldora del HUD, el globito de aviso, los rayos y el marco "Destacado". Los íconos van en `GameConfig.Iconos`: los 14 de antes más Tienda, Mochila, Libro, Engranaje, Banco, Pico, Candado y Amuleto. Las piezas blancas se pintan desde el código con cualquier color, así no hace falta una imagen por color. Los botones, paneles y barras se estiran sin deformar las esquinas (9-slice), con la medida anotada en `Corte`.
- **Mientras una pieza no esté subida**, el juego la dibuja con degradé, borde oscuro y brillo, como el diseño de Figma. Así todo anda desde ya y cada imagen nueva reemplaza al dibujo sin tocar el código.
- **HUD** (`Hud.client.luau`):
  - Arriba a la derecha: Monedas, Suerte y Fuerza en píldoras que saltan cuando suben, más los botones "Vender todo" y Ajustes.
  - A la izquierda: 6 botones grandes (Tienda, Mochila, Museo, Vitrina, Ranking, Eventos) con globitos. La Tienda muestra "!" si te alcanza para algo, la Mochila cuántas gemas tenés, el Museo "!" si hay una gema nueva y Eventos "!" si hay uno en curso.
  - Abajo al centro: la barra "Próxima zona".
  - En celular los botones van arriba a la izquierda y todo se achica, para no tapar el joystick ni el salto.
- **Ventanas** (`Ventanas.luau`): fondo oscurecido, cabecera de color con rayas, título grande con ícono, X roja y un "pop" al abrir. Se abre una por vez y se cierran tocando afuera.
- **Menús**:
  - Tienda: Fuerza, Amuletos y Picos, con "Destacado".
  - Mochila: la grilla de gemas, el total y "¡Vender todo!".
  - Museo (antes Índice): ver Grupo 3.
  - Eventos: el de ahora o el próximo, con cuenta regresiva, y los 6 eventos.
  - Mi Vitrina: los títulos con candado y la gema que se exhibe.
  - Clasificación: podio, del 4 al 10 y tu puesto. Es solo para lucirse.
  - Ajustes: los 4 interruptores.
- **Servidor** (`Economia.luau`): vender, comprar Fuerza (de a uno o "todo lo que alcance"), el pico siguiente y el amuleto siguiente. Revisa el tipo de pedido, un pedido cada 0,2 s y que te alcancen las monedas, y te avisa cuánto te falta.

Decisiones v3:
- **Vender se puede desde cualquier lado** (el botón "Vender todo" o la Mochila). Es lo más simple; un Banco en el mapa queda para cuando se arme el mapa.
- **Las zonas se abren solas** cuando te alcanza la Fuerza. En el mapa, cada muro tiene una puerta de energía que se abre sola para quien ya tiene la zona.
- **Las gemas del menú son un rombo dibujado** del color de cada gema: son 25, y un ícono por gema sería mucho para ahora.

Estado de ForgeGUI (14/10/2026):
- **ForgeGUI generó 4 botones** (verde, amarillo, azul y rojo); las otras 36 piezas fallaron por falta de créditos. Lo pedido está en `arte/gui/forgegui.json`.
- **Con esos 4 botones se armó todo el kit** (`arte/scripts/gui.py`):
  - Se les limpió el borde violeta que dejaba el recorte y se achicaron a 160 px de alto.
  - De ellos salen los colores que faltaban (violeta, rosa, naranja, cian y gris), el blanco que se pinta desde el código (cabeceras, baldosas, píldoras y barras) y el oscuro de las ventanas.
  - Hoja para mirar el kit: `arte/gui/kit.png`. Cómo se ve puesto: `arte/gui/maqueta_hud.png` y `maqueta_tienda.png`.
- **Íconos:** son los 14 dibujos propios más 8 nuevos (Tienda, Mochila, Libro, Engranaje, Banco, Pico, Candado y Amuleto), todos en una sola hoja (`arte/scripts/iconos`, celdas de 128 px). Cuando haya créditos se pueden cambiar por íconos de ForgeGUI pegándolos en `GameConfig.Iconos`, que tiene prioridad sobre la hoja.
- **Subidas a Roblox:** las 12 imágenes (11 piezas y la hoja de íconos) están en la cuenta de Juani con la conexión de ForgeGUI, todas aprobadas. Los IDs están en `GameConfig` (tabla `IMAGEN`) y en `arte/gui/listas/roblox.json`.
- **Siguen dibujados por código:** la X de cerrar (usa el botón rojo con una X), el globito rojo y el marco dorado de "Destacado".

## Grupo 3 — Exploración, secretos y coleccionismo (pedido del 14/10/2026)

La regla: los secretos premian al curioso pero **nunca hacen falta para avanzar**. Las zonas se siguen abriendo solo con Fuerza; ninguna colección ni secreto da Fuerza ni abre zonas.

**Museo de minerales** (reemplaza al Índice: botón "Museo" del HUD y un cartel dorado en la plaza, a la izquierda del spawn):
- **Minerales**: los 31 (25 de los biomas y 6 secretos), agrupados por bioma. De cada uno muestra rareza, cuántos encontraste, de dónde sale y tu **primer hallazgo** (fecha). Los que no encontraste se ven como una silueta oscura con "???" y una pista de dónde salen.
- **Colecciones**: completas e incompletas, con barra de progreso, dificultad (Fácil, Media, Difícil, Leyenda) y premio.
- **Cosméticos**: lo que ganaste, para equiparlo. Lo bloqueado dice qué colección lo da.
- **Probabilidades**: la tabla con tu suerte actual, que suma 100 % (GUIA, sección 6).

| Colección | Dificultad | Qué pide | Premio |
|---|---|---|---|
| Primeros Hallazgos | Fácil | 3 minerales distintos | 50 monedas y el título "Curioso" |
| Pradera Brillante | Fácil | Cuarzo, Jaspe y Amatista | 150 monedas y la decoración Flores |
| Colección de la Pradera | Fácil | las 5 de la zona 1 | 500 monedas, +0,1 de suerte y Aura Destellos de Cuarzo |
| Museo en Marcha | Media | 10 minerales distintos | decoración Cristalitos |
| Cazarrarezas | Media | una Rara, una Épica y una Legendaria | título "Cazarrarezas" |
| Explorador | Media | tu primer mineral secreto | Aura Runas Arcanas y título "Explorador" |
| Colección de las Dunas | Media | las 5 de la zona 2 | 8.000 monedas, +0,1 de suerte y Pico de Ámbar |
| Colección del Glaciar | Media | las 5 de la zona 3 | 250.000 monedas, +0,15 de suerte y Vitrina de Hielo |
| Coleccionista Exótico | Media | los 4 modificadores | +0,25 de suerte y decoración Llamitas |
| Colección del Volcán | Difícil | las 5 de la zona 4 | 4 M de monedas, +0,2 de suerte y Aura Chispas de Magma |
| Guardián de Secretos | Difícil | los 6 minerales secretos | Vitrina Arcana y título |
| Colección del Abismo | Leyenda | las 5 de la zona 5 | 60 M de monedas, +0,3 de suerte y Pico Estelar |
| Maestro de las Combinaciones | Leyenda | las 4 combinaciones | +1 de suerte y Aura Arcoíris |
| Curador Legendario | Leyenda | los 31 minerales | Vitrina Dorada y título |

- **Cosméticos** (solo se ven, no dan ventaja): auras alrededor del personaje (las ven todos), diseños del pico que llevás en la mano, estilos de vitrina y decoraciones alrededor de tu vitrina. Se equipan desde el Museo.

**Habitaciones secretas** (una por bioma, más la Dimensión Prisma):
- **Llaves**: al romper geodas de un bioma hay 1 en 35 de encontrar su llave (si todavía no abriste esa puerta).
- **Puertas secretas**: una pared del color del risco con grietas que brillan apenas, en el risco derecho de cada bioma. Con la llave se abre para siempre (solo para vos). Sin llave dice "Suena hueca...".
- **Cámaras de tesoro**: un túnel lleva a una sala con cristales y luces del bioma, un **cofre** (se abre una vez: 120 veces el valor de una gema común del bioma) y **dos vetas exclusivas** con Geodas Ocultas.
- **Geodas Ocultas**: solo nacen en las cámaras, dan 4 gemas con suerte ×2 y 1 en 6 de soltar el **mineral secreto** de su bioma (Cuarzo Lunar, Ámbar Fósil, Zafiro Boreal, Rubí de Magma, Ópalo Estelar).
- **Altares misteriosos**: uno por bioma. Ofrecés 5 gemas comunes del bioma y te da una bendición de suerte ×1,5 por 3 minutos (una vez cada 10 minutos). Además te susurra una pista de dónde está la puerta secreta.
- **Portal dimensional**: en las Dunas, escondido detrás de una duna. Lleva a la **Dimensión Prisma**, una isla flotante con 5 Geodas Prismáticas (1 en 8 de soltar la Prismita). Pide tener abierta la zona 2.
- **Pistas en el mapa** junto a cada puerta: una cascada de cristal (1), la duna más alta (2), picos de hielo (3), un río de lava (4) y un rincón oscuro sin cristales (5).

Decisiones del Grupo 3:
- **El Museo reemplaza al Índice** (era lo mismo pero con menos datos). El "primer hallazgo" guarda la fecha en que lo encontraste vos. El primero de todo el servidor queda afuera porque necesita guardado global.
- **Las puertas secretas se abren solo para quien tiene la llave.** Cada jugador ve su puerta abierta o cerrada; nadie entra "colado" detrás de otro.
- **Los minerales secretos no salen nunca en geodas comunes**, así la tabla de probabilidades de los biomas no cambia.

## Mapa (hecho en Blender, 14/10/2026)

- **Cómo se arma**: el mapa se diseña con cubos de 4 studs en `arte/scripts/mapa.py`. El script junta los cubos en cajas grandes (unas 1.700 partes en total) y escribe `src/server/MapaDatos.luau`. Al arrancar el servidor, `GeneradorMapa.luau` arma las partes y los lugares con su tag. Así el mapa vive en git y no hay que subir mallas. Si en Studio ya hay un `Workspace.Mapa`, no hace nada.
- **Orden**:
  - Plaza: spawn, 8 vitrinas, 2 tableros, el Museo a la izquierda y el lugar del Jefe Ancestral.
  - Arco de entrada y los 5 biomas en fila, de 168 studs de largo cada uno, separados por muros con su puerta de zona.
  - Cada bioma tiene riscos con escalones a los costados, 15 o 16 puntos de geoda en 4 filas, el Jefe al fondo, el altar, la decoración propia y la cámara secreta en el risco derecho.
  - Lejos de todo flota la Dimensión Prisma.
- **Decoración por bioma**:
  - Pradera: árboles y racimos de cuarzo.
  - Dunas: dunas, cactus y racimos de ámbar.
  - Glaciar: picos de hielo y un lago congelado.
  - Volcán: un volcán, ríos de lava y columnas de basalto.
  - Abismo: columnas con estrellas e islas flotantes.
- Fotos: `arte/renders/mapa_*.jpg` (general, plaza, cada bioma, una cámara secreta por dentro y la Dimensión Prisma).

## Rocas por bioma (Blender, 14/10/2026)

Cada bioma tiene su propia geoda (`arte/scripts/rocas.py`, foto en `arte/renders/geodas_biomas.jpg`):

| Bioma | Forma de la roca | Cristales |
|---|---|---|
| 1 · Pradera | huevo | puntas de cuarzo |
| 2 · Dunas | canto ancho con capas | gotas de ámbar |
| 3 · Glaciar | roca facetada | esquirlas largas de zafiro |
| 4 · Volcán | columnas de basalto | bloques de rubí |
| 5 · Abismo | roca con un surco | estrellas que flotan |
| Oculta | huevo oscuro | una veta que brilla alrededor |
| Prismática | prisma alto de vidrio | esquirlas de colores |

- **Archivos**: `arte/fbx/Geodas_Zona1.fbx` a `Geodas_Zona5.fbx`, cada uno con los 4 tamaños adentro (Pequena, Mediana, Gigante y Jefe), y `Geodas_Especiales.fbx` con la Oculta y la Prismática. Cada tamaño trae las mallas Roca, Cristales, Base, Grietas y Grietas2, que el juego pinta según el modificador.
- **Cómo entran al juego**: `ModeloGeoda.luau` busca en `ServerStorage > Modelos > Geodas` la carpeta del bioma (`Zona1`… o `Geodas_Zona1`…) y adentro el tamaño. Las especiales las busca en `Especiales` o `Geodas_Especiales`. Si no las encuentra, usa la geoda general y, si tampoco está, la de bloques simples.
- **Pendiente para Juani**: importar los 6 FBX en Studio (los pasos están en el informe). Claude no puede subir mallas desde la nube.

## Grupo 4 — Progresión y objetivos a largo plazo (pedido del 14/10/2026)

La regla: lo que se ve y lo que da poder van separados. Las evoluciones del pico, las auras y los títulos solo se ven; la Fuerza sale del pico comprado, la suerte de amuletos, logros, mascotas y el árbol de Esencia.

**Evolución visual de los picos** (Museo → Cosméticos → "Evoluciones del pico"). Son partículas, estelas, fuego, luces y cristalitos en la cabeza del pico que tenés en la mano, y los ven todos. Con "Efectos reducidos" se apagan en los picos de los demás.

| Evolución | Cómo se gana | De dónde viene |
|---|---|---|
| Brillo Metálico | conseguir el Pico de Hierro (logro Forjador) | progreso |
| Cristales Luminosos | completar 4 colecciones del Museo (Brillo Interior) | colecciones |
| Runas Mágicas | cumplir 10 misiones (Aprendiz de Runas) | misiones |
| Estela de Fuego | jugar 5 eventos (Cazador de Eventos) | eventos |
| Descargas Eléctricas | ayudar a romper 10 Geodas Ancestrales | eventos de jefe |
| Energía Cósmica | conseguir el Pico Cósmico (Forja Cósmica) | progreso |
| Fénix | renacer 2 veces | prestigio |
| Eclipse | renacer 5 veces | prestigio |

**Misiones dinámicas** (botón "Misiones" y cartel en la plaza; seguimiento a la derecha de la pantalla):
- Siempre hay una **Fácil, una Media y una Difícil**. Desde el primer Renacer se suma una de **Prestigio**, que da Esencia.
- Se eligen al azar entre las que podés hacer de verdad. Por ejemplo, "Rompé Geodas Ocultas" solo te toca si ya abriste una puerta secreta, "Completá la colección X" solo si vas por la mitad o más, y la Legendaria solo desde la zona 2.
- **Tipos de misión:**
  - romper geodas (de un tamaño o en tu mejor zona)
  - encontrar gemas de una rareza o mejor
  - romper exóticas
  - llevarte gema de una Geoda Jefe
  - hacer una ofrenda en un altar
  - cruzar el portal
  - abrir una puerta secreta
  - descubrir un mineral nuevo
  - completar una colección
  - romper Geodas Renacidas
- Se siguen y se pagan solas. **Premio** = monedas por dificultad (40 / 150 / 500 / 800) × lo que vale una gema común de tu mejor zona, así sirve igual en la Pradera que en el Abismo.
- A los 2 segundos aparece otra misión en ese lugar. Podés **cambiar** una gratis cada 1:30.
- Logros por misiones cumplidas:
  - 3 misiones: 150 monedas.
  - 10 misiones: Runas Mágicas y +0,1 de suerte.
  - 40 misiones: +0,25 de suerte y el título "Maestro de Misiones".

**Renacer (prestigio)** (botón "Renacer" y cartel junto al Santuario):
- **Qué pide:** el 1° renacer pide abrir el Glaciar (zona 3), el 2° el Volcán y del 3° en adelante el Abismo.
- **Qué se reinicia:** Monedas, niveles de Fuerza, picos (volvés al de Madera), amuletos, zonas abiertas y gemas sin vender.
- **Qué se conserva:**
  - Museo, colecciones y logros (con su suerte)
  - títulos, cosméticos y evoluciones del pico
  - mascotas
  - puertas secretas y llaves
  - Esencia y ramas
  - récords, vitrina y misiones cumplidas
- **Qué da:**
  - Esencia: tu mejor zona menos 1, o sea 2 a 4.
  - Bonos para siempre: +10 % de monedas al vender y +5 % de Fuerza por cada renacer, hasta 10 renaceres.
  - Te lleva de vuelta a la plaza con misiones nuevas.
- **Cada renacer estrena algo:**
  1. La misión de Prestigio, el Santuario del Renacer, el árbol de Esencia (Golpe Firme, Mercader y Buen Ojo), el aura Llamas del Renacer y el título Renacido.
  2. La evolución Fénix y las ramas Rastreador e Inicio Rápido.
  3. La Vitrina Renacida y el título Leyenda Renacida.
  4. La rama Domador (más lugares de mascota).
  5. La evolución Eclipse y el título Eterno.
- **Árbol de Esencia** (mejoras permanentes moderadas):
  - Golpe Firme: +5 % de Fuerza por nivel, 5 niveles.
  - Mercader: +8 % de monedas por nivel, 5 niveles.
  - Buen Ojo: +0,05 de suerte por nivel, 5 niveles.
  - Rastreador: llaves 25 % más seguido por nivel, 3 niveles.
  - Inicio Rápido: arrancás cada renacer con 5 niveles de Fuerza por nivel, 4 niveles.
  - Domador: +1 lugar de mascota por nivel, 2 niveles.
- **Santuario del Renacer** (contenido de prestigio, en la plaza): un patio cerrado con una puerta dorada que solo se abre si renaciste.
  - Adentro hay 4 Geodas Renacidas (doradas).
  - Dan 12 gemas de tu mejor zona, con suerte ×2, y 1 en 25 de soltar 1 de Esencia.
  - Su vida sigue al más fuerte que ya renació (unos 20 golpes), así no se rompen de un golpe.

**Ruleta de Mascotas** (escenario en la plaza; botón "Mascotas"):
- **Cómo se paga:** solo con Monedas del juego, nunca con Robux. Las Monedas no se venden por Robux (ver `ideas/monetizacion.md`: "Nada con azar se compra con Robux").
- **Precio:** 150 × lo que vale una gema común de tu mejor zona.
- **Cómo funciona:** cada tirada da una mascota. La rueda tiene cada porción del tamaño de su chance, y al lado están todas las probabilidades en %, que suman 100.

| Mascota | Rareza | Chance | Bono |
|---|---|---|---|
| Topito | Común | 30 % | +5 % monedas |
| Piedrín | Común | 30 % | +0,05 suerte |
| Chispa | Rara | 14 % | +10 % monedas |
| Musgo | Rara | 14 % | +0,1 suerte |
| Cuarcito | Épica | 4,5 % | +20 % monedas |
| Glaciel | Épica | 4,5 % | +0,2 suerte |
| Magmo | Legendaria | 2,6 % | +35 % monedas y +0,2 suerte |
| Nébula | Mítica | 0,4 % | +60 % monedas y +0,5 suerte |

- **Lugares:** te acompañan hasta 3 mascotas (Domador suma 2 lugares más). Se pueden repetir si tenés copias.
- **Cómo se ven:** te siguen flotando y las ven todos. Las de Legendaria y Mítica se anuncian en el servidor.
- **Menú "Mis mascotas":** elegís cuáles te acompañan.

**Rocas:** cada bioma tiene 3 rocas distintas (forma, colores y material). Cada geoda nace con una al azar y su cartel dice cuál es ("Musgosa", "de Obsidiana"...). Solo cambia cómo se ve.

| Bioma | Roca 1 | Roca 2 | Roca 3 |
|---|---|---|---|
| Pradera | Cuarzo (gris y violeta) | Musgosa (verde y rosa) | Caliza (crema y cian) |
| Dunas | de Ámbar | de Arenisca Roja (roja y amarilla) | Desértica (arena y naranja) |
| Glaciar | de Zafiro | de Escarcha (blanca y cian) | de Glaciar Profundo (azul y celeste) |
| Volcán | de Rubí | de Obsidiana (negra y naranja) | de Azufre (ocre y amarillo) |
| Abismo | Estelar | Nebulosa (violeta y rosa) | Meteorito (gris y naranja) |

**HUD:**
- 9 botones en 3 columnas: Tienda, Mochila, Museo, Vitrina, Ranking, Eventos, Misiones, Mascotas y Renacer.
- Íconos nuevos en la hoja: Mascota, Misión, Renacer y Esencia.
- Globitos:
  - Mascotas: "!" si te alcanza para la ruleta.
  - Renacer: "!" si podés renacer o mejorar una rama.
  - Misiones: "!" cuando cumplís una.

Decisiones del Grupo 4:
- **Las misiones se pagan solas** (sin botón de cobrar): es lo más simple y no se pierde nada si te olvidás.
- **La ruleta muestra las porciones del tamaño real de cada chance.** Una rueda con porciones iguales y chances distintas engañaría.
- **La Esencia sale solo de renacer, de las misiones de Prestigio y (poco) del Santuario.** Así renacer sigue siendo la fuente principal.
- **Los bonos del Renacer tienen tope** (10 renaceres). Más allá, solo suma Esencia para el árbol, que también tiene tope.
- **Los datos siguen viviendo en memoria** (como todo el prototipo): el guardado con ProfileStore queda para antes de publicar.

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
| Exótica de Lava | 1 en 10 | ×3 |
| Exótica Neón | 1 en 40 | ×5 |
| Exótica Dorada | 1 en 150 | ×10 |
| Exótica del Vacío | 1 en 1.000 | ×25 |

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

De las capturas se toma el estilo, no el contenido: cielo celeste brillante, piso verde lima con studs, rocas tipo vóxel (cubitos) apoyadas en un nido de escombros, cartel arriba de cada geoda con nombre, rareza y barra de vida ("2/10 PV"), destello blanco al revelar con el cartel de suerte (ícono de trébol + "x2,06 Suerte"), botones gordos con borde oscuro y texto blanco con contorno, contador grande abajo a la izquierda con el "+X" que salta, barra de progreso arriba al centro. No se copian nombres, íconos ni personajes de esos juegos. Sin emojis: todos los íconos son dibujos propios (`arte/iconos/`, 14 PNG) y, mientras no estén subidos, el juego dibuja una insignia de color en su lugar.

- **Modelos 3D**: hechos en Blender con `forja-rapida/arte/scripts/modelos.py`, estilo vóxel. Cada geoda tiene cinco mallas (Roca, Cristales, Base, Grietas y Grietas2) para que el juego las pinte según la zona y el modificador; las exóticas suman una textura de cubitos (`arte/texturas/`). Las auras (chispas, anillo, destellos) son efectos de Roblox. Muestras en `arte/renders/`. Para los grupos 6 y 7 se sumaron la Geoda Ancestral (con runas doradas), la vitrina, el tablero de la clasificación, el cristal de la lluvia, la bomba de lava y una estatua por rareza (`eventos_y_exhibicion.jpg`).
- **HUD y menús**: diseñados en Figma, archivo "Forja Rápida · HUD y menús" (https://www.figma.com/design/DZ114Em8TCx2WZPzRiPAeL). Pantallas: HUD de compu (1920×1080) y de celular (844×390, sin tapar el joystick ni el salto de Roblox), revelación Épica con aviso en cadena, Tienda (Fuerza, Amuletos con "qué cambia" en números, Picos), Mochila/Banco, Índice con probabilidades (suman 100 %), avisos, carteles por modificador, botón de efectos y tres paletas para elegir. Letra: Lilita One en Figma; en Roblox, FredokaOne (la más parecida que trae Roblox).
- **HUD y menús v2** (página "v2 · Eventos y social" del mismo archivo, con el estilo de tus últimas capturas): HUD de compu más colorido (botones con globitos, bonos activos, cartel del evento), Geoda Ancestral con podio de daño, Índice, Tienda con "Destacado", Eventos, Mi Vitrina (títulos y ajustes), Clasificación semanal y HUD de celular v2. Los 14 íconos están como componentes en esa página.

Guía de estilo: **pendiente** (punto de control 2: elegir paleta A · Pradera, B · Caramelo o C · Noche volcánica en Figma). Hasta que elijas, todo usa la A, que es la de tus capturas.

## Afuera del prototipo

- Robux: ni compras ni pases. **Si alguna vez se venden Monedas por Robux**: romper geodas es gratis (no se paga por tirar), pero igual el Índice muestra siempre la tabla de probabilidades con tu suerte actual (GUIA, sección 6), así queda cubierto. Antes de vender Monedas, revisar la regla de ítems aleatorios pagos.
- Renacer (rebirth), mascotas, auto-golpe, límite de mochila y analítica.
- Sonidos definitivos (quedan marcados con `-- SONIDO:` y los IDs vacíos en GameConfig: golpe, romper, revelación, revelación rara, logro, anuncio, un aura por modificador y los de eventos: empieza, cristal, trueno y jefe).
- Subir los íconos de `arte/iconos/` y pegar los IDs en `GameConfig.Iconos`.
- Guardado con ProfileStore: por ahora los datos viven en memoria (la clasificación semanal sí usa su propio almacén).
- Importar en Studio las rocas por bioma (`arte/fbx/Geodas_Zona1..5.fbx` y `Geodas_Especiales.fbx`): mientras no estén, el juego usa la geoda general.
- Récord de "primer descubrimiento del servidor": necesita guardado global, queda para cuando esté ProfileStore.
- Subir las texturas de `arte/texturas/` y pegar los IDs en `GameConfig.Modificadores[..].Textura`. Mientras tanto, las exóticas se ven con color, material, grietas y aura.

## Prueba que va a hacer Claude

Jugador nuevo: rompe geodas de la zona 1, ve la revelación, vende, compra el Pico de Piedra y niveles de Fuerza, abre la Zona 2. No puede pegarle a una geoda de una zona cerrada, ni desde lejos, ni más de 8 veces por segundo. Dos jugadores rompen un Jefe juntos y los dos reciben gema. Salir y volver: sigue todo. Captura en compu y en celular.

## Prueba en Studio (16/10/2026)

Primera vez que el juego corre en Studio (place 97540910093969, con Rojo). Consola del servidor y del cliente sin errores del juego (solo avisos internos de Roblox).

Probado y anda:
- **Geodas y golpe**: clic real sostenido y golpes por remoto. El servidor frena todo lo que tiene que frenar: ráfaga (de 30 juntos cuentan 4), tope de unos 8 por segundo, desde lejos, zona cerrada y datos basura.
- **Revelación**: común chica; rara o exótica grande, con suerte, "1 en N", modificador, "¡NUEVA!" y misión cumplida en cadena.
- **Mochila y venta**: la venta da el total justo y vacía la mochila.
- **Tienda**: Fuerza, Máximo, Pico y Amuleto con sus precios; avisa cuánto falta.
- **Zona 2**: se abre sola con 25 de Fuerza; la puerta frena al que no la tiene y deja pasar al que sí.
- **Grupo 3**: puerta secreta (sin llave "Suena hueca…", con llave se abre y gasta la llave), cofre (una sola vez), altar (bendición x1,5, pista y espera de 10 min), veta oculta, Dimensión Prisma y Museo con 31 minerales.
- **Grupo 4**: renacer (pide el Glaciar; reinicia y conserva lo que dice la ficha), árbol de Esencia, Santuario, ruleta (precio, espera y mascotas que siguen) y misiones (cambio con espera de 1:30).
- **Grupo 6**: Jefe Ancestral forzado (se rompe y premia) y Lluvia de Cristales (+25 por cristal).

Arreglado en esta prueba:
- **Portal de las Dunas**: el disco quedaba acostado arriba de las cabezas y el anillo girado contra los pilares, así que no se podía cruzar. Ahora se cruza caminando ida y vuelta (`GeneradorMapa.luau`).
- **Cartel de los eventos**: crecía sin fin (132.000 píxeles) y tapaba la pantalla, porque las rayas de luz median 3 veces su alto (`Eventos.client.luau`).
- **"¡COMúN!" → "¡COMÚN!"**: mayúsculas con tilde (`Formato.mayusculas`, con test en `pruebas/reglas`).
- **"¡NUEVA EN EL ÍNDICE!" → "¡NUEVA EN EL MUSEO!"**.
- **Herramientas de prueba** (`HerramientasPrueba.luau`): solo existen en Studio, en `ServerStorage.Prueba` (Leer, Poner, Reiniciar).

Para mirar más adelante:
- Una Geoda Renacida tiene como mínimo 400 de vida: recién renacido (Fuerza 1) son unos 400 golpes.
- Falta la prueba con dos jugadores y en celular, y el guardado sigue en memoria (sistema 6).
