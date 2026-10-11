# Mutant Lab — ficha del prototipo

Origen: idea del usuario (2026-10-07). Mecánica de colección + fusión; el contenido (criaturas, nombres, mapa) es todo propio.
Carpeta del juego: `mutant-lab/`.
Estado: versión 1 (2026-10-07), aprobada con el pedido de la Parte 1.
Versión 2 (2026-10-07): **Parte 1 hecha.** Estilo elegido por el usuario: "el que más le gusta a los nenes y el más dopamínico" → **A, Laboratorio caramelo, en versión saturada** (ver "Guía de estilo"). Cambió la regla de colores de la fusión (ver "Ajustes de la Parte 1").
Versión 3 (2026-10-07): **Parte 2 hecha** (máquina de fusión). Ver "Notas de la Parte 2".
Versión 4 (2026-10-07): **Parte 3 hecha** (Mutadex). Ver "Notas de la Parte 3".
Versión 5 (2026-10-08): **Parte 4 hecha** (laboratorio y economía). Ver "Notas de la Parte 4".
Versión 6 (2026-10-08): **guía visual nueva** (laboratorio de caricatura de noche, ver "Guía de estilo") y **mapa nuevo**: plaza en el centro y 6 laboratorios alrededor (pedido del usuario, ver "Notas del mapa nuevo"). Ya tienen el estilo nuevo el mapa, la máquina y las criaturas. **Falta el HUD y los menús**, que siguen con el estilo caramelo.
Versión 7 (2026-10-08): **Parte 5 hecha** (guardado, balance y pulido), sobre la rama de la interfaz nueva (HUD nuevo; la Mutadex, la tienda y el panel de fusión siguen con el estilo viejo hasta los Bloques 3 a 6 del rediseño). Ver "Notas de la Parte 5".
Versión 8 (2026-10-09): **interfaz terminada**: el panel de fusión, la Mutadex, la tienda y los festejos ya usan los componentes de `client/UI` (pedido 1 de `ORDEN-PEDIDOS.md`). Ver "Notas de la interfaz terminada".
Versión 9 (2026-10-09): **Pedidos** (pedido 2 de `ORDEN-PEDIDOS.md`): clientes que piden criaturas, inventario de criaturas y balance nuevo del ADN. Ver "Pedidos".
Versión 10 (2026-10-09): **fracasos útiles, personalidades y catalizadores** (pedido 3 de `ORDEN-PEDIDOS.md`): residuos, personalidades con herencia y efectos en el corral, ranura de catalizador con variantes, y pedidos de personalidad y de variante. Ver "Fracasos útiles, personalidades y catalizadores".
Versión 11 (2026-10-09): **Parte 5 revisada** (pedido 4 de `ORDEN-PEDIDOS.md`): se guarda todo lo nuevo, balance medido hasta completar la Mutadex (suba tardía del 12 % y premios de pedidos más chicos), guía y rendimiento probados. Ver "Revisión de la Parte 5 con pedidos, personalidades y catalizadores".
Versión 12 (2026-10-09): **Parte 7 hecha** (pedido 5 de `ORDEN-PEDIDOS.md`): tres niveles de fusión, "¡NUEVA ESPECIE!" letra por letra, botón Saltear, criaturas que reaccionan al tocarlas y viven según su personalidad, ADN que vuela al contador y destellos de mejoras. Ver "Notas de la Parte 7".
Versión 13 (2026-10-09): **Parte 8 hecha** (pedido 6 de `ORDEN-PEDIDOS.md`): ADN mientras no estás, premio diario de 7 días con la especie especial Estrellín, experimento del día, tres misiones diarias y metas largas con trofeos; las fechas las decide el servidor. Ver "Notas de la Parte 8".
Versión 14 (2026-10-11): **Parte 9 hecha** (pedido 7 de `ORDEN-PEDIDOS.md`): paseos, visitas, ficha de criaturas ajenas, fusión en equipo con 10 especies que solo salen así, tablas de posiciones y "me gusta". Ver "Notas de la Parte 9".
Próximo punto de control: **prototipo jugable** (Partes 1 a 5).

## Guía de estilo: laboratorio de caricatura de noche (versión 6)

Copiada de la guía visual del usuario (`ideas/mutant-lab-visual.md`, 2026-10-08). Reemplaza el estilo A (Laboratorio caramelo), que quedó guardado en Studio por si hace falta volver: el mapa viejo en `ServerStorage > Archivo > MapaCaramelo` y la luz vieja en `ServerStorage > Archivo > LuzCaramelo`.

### 1. Dirección de arte

Concepto: "laboratorio de caricatura de noche". Un laboratorio oscuro y acogedor, lleno de tubos con líquidos que brillan, donde viven criaturas redondas y tiernas. Lo oscuro es el fondo; lo que brilla es lo importante: el ADN, la máquina, las criaturas.

Tres reglas que mandan sobre todo lo demás:
1. Lo jugable brilla, lo decorativo no. Si algo se puede tocar o juntar, tiene un color de acento o luz. La decoración usa colores apagados.
2. Formas redondas y gruesas. Nada filoso ni realista. Bordes redondeados, proporciones exageradas.
3. Se entiende en una pantalla de celular. Si algo no se lee en un teléfono, se agranda o se saca.

### 2. Paleta

| Uso | Color | Hex |
|---|---|---|
| Fondo, paredes y piso del laboratorio | Azul petróleo oscuro | #1B2A3A |
| Sombras y cielo | Violeta noche | #2A1F3D |
| Metal, máquinas y estructuras | Gris azulado | #5C6B7A |
| Acento principal: ADN, slime, botón de fusionar | Verde ácido | #7CFF4F |
| Acento secundario: novedades, alertas | Magenta | #FF4FA3 |
| Premios, raro, dorado | Amarillo dorado | #FFC93C |
| Texto de interfaz | Blanco frío | #F5F7FA |
| Contorno de interfaz y sombra de texto | Casi negro | #10141C |

Colores por elemento (se usan en criaturas, íconos y pistas):

| Elemento | Hex |
|---|---|
| Fuego | #FF6A3D |
| Agua | #3DB8FF |
| Planta | #5DDB6A |
| Eléctrico | #FFE14A |
| Sombra | #8E6BFF |
Los elementos combinados mezclan los dos colores de sus padres.

Colores por generación (borde de tarjetas y anillo bajo la criatura):
- Generación 1: blanco #F5F7FA
- Generación 2: azul #3DB8FF
- Generación 3: violeta #B07CFF
- Mutante: dorado #FFC93C con brillo

### 3. Iluminación y ambiente

- Hora fija de noche, con una luna grande y visible desde el laboratorio.
- Luz ambiente baja y azulada. La luz fuerte sale de los objetos: tubos, máquina, pantallas.
- Atmosphere con un poco de niebla violeta a lo lejos, para que el fondo se pierda y el laboratorio resalte.
- Bloom suave, para que las partes de material Neon brillen. Sin exagerar: el texto tiene que seguir leyéndose.
- ColorCorrection con un poco más de saturación y contraste.
- Para que algo brille, usá primero material Neon. Las luces reales (PointLight, SurfaceLight) solo en la máquina de fusión y en pocos lugares clave: como máximo 12 en todo el laboratorio.

### 4. Mapa

#### Plaza central
- Una plaza circular en el centro del mundo, rodeada por los laboratorios de los jugadores, uno por jugador, como porciones alrededor.
- En el medio, la máquina de fusión en equipo (Parte 9): más grande que las demás, con un tubo de luz que sube al cielo.
- Tablero gigante con el experimento del día (Parte 8) y la tabla de posiciones.
- Faroles verdes, bancos, carteles de neón con flechas hacia cada laboratorio.

#### Laboratorio de cada jugador
Una sala redonda, de unos 80 studs de diámetro, abierta hacia la plaza por un arco con el nombre del jugador en neón.
- Centro: la máquina de fusión. Una cápsula de vidrio alta con dos ranuras de entrada a los lados (una por padre) y una tercera arriba para el catalizador. Tubos que conectan las ranuras con la cápsula. Cuando funciona, el líquido de los tubos se mueve hacia la cápsula.
- Alrededor de la máquina: 4 corrales al principio, hasta 8 con mejoras. Cada corral es una plataforma hexagonal con cúpula de vidrio, borde de neón verde y un cartel con la cantidad de ADN por segundo. Los corrales bloqueados se ven con la cúpula opaca y un candado.
- Pared del fondo: el Mutadex como pantalla gigante, que muestra la cantidad descubierta y la última especie nueva.
- Un costado: mostrador de la tienda con un robot vendedor simpático.
- Otro costado: estante de trofeos (Parte 8), que se va llenando.
- Decoración que llena los huecos: tubos que suben por las paredes con burbujas, frascos de colores en estantes, cables gruesos por el piso, pantallas con gráficos simples, franjas amarillas y negras en el borde de las plataformas, carteles de "¡PELIGRO: TIERNO!".
- Sin espacios vacíos: desde cualquier punto de la sala tiene que verse algo interesante a menos de 15 studs.

#### Reglas del mapa
- Generá el laboratorio por código desde un molde, así cada jugador recibe uno igual y se puede cambiar el diseño en un solo lugar.
- Materiales: SmoothPlastic para casi todo, Metal para máquinas, Glass para cúpulas y cápsulas, Neon para lo que brilla. Nada de texturas realistas.
- Cámara: el jugador tiene que poder ver la máquina y al menos 3 corrales a la vez desde el centro.

### 5. Criaturas

#### Proporciones
- Estilo chibi: la cabeza ocupa la mitad de la altura total.
- Altura de 3 a 5 studs según el tamaño (chico, mediano, grande).
- Patas cortas y gruesas, cuerpo redondo.
- Todas las partes con formas redondeadas: esferas, cilindros y bloques con esquinas suaves.

#### Ojos (lo más importante)
- Todas las criaturas tienen ojos grandes: dos esferas blancas con pupila negra y un punto blanco de brillo.
- Los ojos ocupan cerca de un tercio de la cara.
- La personalidad cambia los ojos: Alegre, ojos arqueados de felicidad; Vaga, párpados a media altura; Peleadora, cejas en ángulo; Miedosa, pupilas chiquitas; Curiosa, un ojo más grande que el otro.

#### Color y materiales
- Dos tonos por criatura: color principal en el cuerpo y color de detalle en panza, orejas o patas.
- Una pieza de material Neon con el color de su elemento: una antena, una cola, una mancha en la espalda o los cuernos.
- SmoothPlastic en todo lo demás.

#### Generación, mutante y tamaño
- Anillo de luz bajo los pies con el color de su generación.
- Mutante: el color principal cambia a una versión brillante, la pieza de elemento pasa a ser más grande, y tiene partículas de brillo dorado alrededor.
- Las de generación 3 tienen una pieza extra: corona, aura o un segundo par de alas.

#### Animación
- Movimiento de rebote con estirar y aplastar: al caer se aplastan un poco, al saltar se estiran.
- Cada personalidad se mueve distinto: la Alegre salta seguido, la Vaga camina lento y se duerme, la Peleadora empuja a las vecinas, la Miedosa se esconde detrás de otras, la Curiosa se acerca al jugador.
- Al tocarla: salta, hace su sonido y muestra un cartelito con nombre, generación, elemento y personalidad.

#### Ícono de personalidad
- Arriba de la cabeza, chico y semitransparente, solo visible a menos de 20 studs.
- Ícono simple dibujado con formas o texto: corazón para Alegre, "Zzz" para Vaga, rayo para Peleadora, gota para Miedosa, signo de pregunta para Curiosa, estrella para Líder, martillo para Trabajadora, cubierto para Glotona.
- Borde verde para personalidades positivas, borde magenta para negativas.

#### Reglas
- Ninguna criatura se parece a personajes, mascotas o memes existentes.
- Máximo 12 partes por criatura.
- Si al combinar piezas algo queda roto o tapado (ojos dentro del cuerpo, patas flotando), el generador lo corrige con reglas de posición, no a mano.

### 6. Interfaz (HUD y menús)

#### Estilo general
- Look de caricatura: tarjetas con esquinas redondeadas (UICorner de 12), contorno grueso casi negro (UIStroke de 3) y fondo azul petróleo semitransparente.
- Botones gruesos con una franja más oscura abajo que simula profundidad. Al apretarlos se hunden un poco.
- Tipografía: Fredoka One para títulos, números y botones; Builder Sans o Gotham para textos chicos. Todo texto blanco con contorno oscuro.
- Íconos simples, de un color, sin degradados.
- Todo con tamaños relativos a la pantalla. Botones de al menos 44 píxeles en celular. Respetá la zona segura de la pantalla.

#### Distribución en pantalla
| Lugar | Qué va |
|---|---|
| Arriba a la izquierda | Contador de ADN: pastilla con un ícono de hélice verde y el número grande |
| Arriba al centro | Progreso del Mutadex: barra con "12 / 50" |
| Arriba a la derecha | Botones redondos: Mutadex, Misiones, Tienda y Ajustes |
| Lado derecho | Notificaciones que entran deslizándose y se van solas |
| Abajo al centro | Acción del momento (por ejemplo "Fusionar" al estar cerca de la máquina) |
| Centro | Libre siempre, salvo en la revelación de una especie nueva |

#### Menú de fusión
- Se abre al acercarse a la máquina.
- Dos casilleros grandes para los padres con un "+" en el medio, y un casillero más chico arriba para el catalizador (con candado hasta desbloquearlo).
- Abajo, la vista previa: si la combinación ya se conoce, muestra el resultado; si no, una silueta con "?".
- Costo en ADN a la vista. Botón grande verde ácido "¡FUSIONAR!". Si no alcanza el ADN, el botón se ve gris y dice cuánto falta.
- Lista de criaturas del jugador abajo, en tarjetas con su color de generación, filtrables por elemento.

#### Mutadex
- Grilla de tarjetas, 4 por fila en computadora y 3 en celular.
- Especie descubierta: la criatura de cuerpo entero, nombre, elemento y borde con el color de su generación.
- No descubierta: silueta negra con un "?" grande y el botón de pista.
- Pestañas por generación, y una pestaña "Extras" para las especies exclusivas.
- Al abrir una especie: vista grande que gira, casilleros de variantes por catalizador y sellos de personalidades conseguidas.

#### Tienda
- Pestañas: Especies, Mejoras, Catalizadores y Premium.
- Cada artículo en una tarjeta con su ilustración, nombre, efecto en una línea y precio.
- Lo que no alcanza se ve en gris con el precio. Lo que es Premium tiene borde dorado.

#### Carteles grandes
- Especie nueva, nivel completado y premios: cartel en el centro con el título en Fredoka One, entrada con rebote y salida automática a los 3 segundos o al tocar.
- Nunca más de un cartel grande a la vez: si hay varios, se encolan.

### 7. Efectos visuales

- Fusión (tres niveles, según la Parte 7): conocida, corta; nueva, completa con silueta y revelación; mutante o generación 3, la más grande, con la cámara temblando un poco y luces de todo el laboratorio.
- Partículas de ADN: pequeñas hélices verdes que salen de las criaturas y vuelan hacia el contador.
- Número que salta y se desvanece cada vez que se suma ADN.
- Destello al comprar o mejorar algo, sobre el objeto que cambió.
- Burbujas constantes en los tubos y la cápsula.
- Todos los efectos del lado del cliente. Con 20 criaturas en pantalla, el juego tiene que seguir fluido en celular.

### 8. Sonido (puntos a marcar)

Marcá con -- SONIDO: cada uno de estos lugares, aunque por ahora no tengan audio: burbujas del laboratorio, máquina arrancando, suspenso de la fusión, revelación normal, revelación de especie nueva, revelación mutante, sonido propio de cada especie, juntar ADN, comprar, abrir menú, cerrar menú, botón apretado, misión completada, música de fondo del laboratorio.

### 9. Cómo aplicarla

1. Antes de construir todo, armá una sala de muestra: un corral con 3 criaturas (una común, una generación 2 y una mutante), la máquina de fusión y el HUD con valores de ejemplo. Sacá capturas desde lejos, de cerca y del HUD en tamaño celular. Esperá el OK.
2. Con el OK, aplicá la guía al laboratorio completo, a todas las criaturas y a todos los menús.
3. Recorré todo con capturas y comprobá: que lo jugable brilla y lo decorativo no, que no hay espacios vacíos, que todo se lee en celular y que el juego sigue fluido.
4. Guardá los colores de la paleta en un módulo en mutant-lab/src/shared, para que cambiar un color sea cambiar una línea.

### Decisiones al aplicar la guía (versión 6)

Cosas que la guía no definía o que chocaban con el juego actual. Elegí lo más simple; se pueden cambiar.

- **Elemento de cada especie base** (provisorio, 2 por elemento, hasta diseñar las Variantes): Agua: Glupona y Brinoza. Planta: Rámulo y Sutomi. Fuego: Chisparo y Dunaqui. Eléctrico: Zoplito y Fotina. Sombra: Rocote y Nerulo. Las fusiones mezclan los colores de sus bases promediando el tono, así la mezcla sigue siendo un color vivo y no un gris.
- **Pieza de Neon del elemento**: es una gema redonda sobre el lomo, igual para todas. Las otras piezas que antes brillaban (cuernos de brasa, antenas, alas) pasaron a plástico, para que lo único que brille sea la gema.
- **Personalidades** (provisorio): positivas Alegre, Curiosa, Líder y Trabajadora; negativas Vaga, Peleadora, Miedosa y Glotona. Desde la versión 10 las tiene cada criatura y cambian el ADN del corral (ver "Fracasos útiles, personalidades y catalizadores").
- **Mutantes**: dorados, como pide la guía. Se apagó el cambio de colores tornasolado (`Config.Animacion.Tornasol`).
- **Vidrio**: cúpulas, cápsulas y tubos son plástico transparente con un poco de brillo, no material Glass. En Roblox, Glass no deja ver lo transparente que tiene detrás, y escondía los anillos de las criaturas, los carteles y las burbujas.
- **Franjas amarillas y negras**: un solo cuadro con degradado a escalones por cara. Es liviano para celular.
- **Fuente**: Fredoka One siempre sin negrita (con negrita no carga y el texto no aparece).
- **Corrales**: 4 por laboratorio y arrancás con 1 abierto, como en la economía de la Parte 4 (la guía dice de 4 a 8).
- **Tamaño del laboratorio**: 68 studs de diámetro (la guía dice unos 80). Con 4 corrales, 80 dejaba huecos.
- **Pendiente: máximo 12 partes por criatura.** Hoy tienen entre 25 y 40, porque solo los ojos ya son 8 partes. Hay que simplificar patas y colas sin cambiar las siluetas.

## Ajustes de la Parte 1 (después de mirar las capturas)

1. **Colores de las fusiones (cambio de regla).** Con la regla original, toda la fusión salía del color del primer padre y Glumulo o Roparo parecían una sola especie de un color. Ahora **cada pieza conserva el color del padre que la trae**, y sus manchas llevan el color del padre siguiente. En gen 2, las piezas del primero tienen manchas del segundo y al revés. En gen 3 las manchas van en ronda: primero → medio → último → primero. Esto reemplaza "color principal", "manchas" y "brillo" de las tablas del punto 2. La mezcla se ve de un vistazo.
2. **Ojos con borde oscuro.** En cabezas blancas (Brinoza) los ojos blancos no se veían. Ahora todos los ojos llevan un borde oscuro.
3. **Cara del hongo color crema.** La cara de Sutomi era blanca con ojos blancos; ahora es crema y lleva el sombrero del color del padre.
4. **Raíces y patas de insecto inclinadas hacia adentro.** Antes se abrían desde arriba y parecían palitos sueltos.
5. **Alas de membrana en abanico de frente.** Las alas de Nerulo quedaban de canto y desde adelante solo se veía un palito; ahora son tres "dedos" abiertos hacia los costados. Las alas transparentes (Fotina) también se abrían hacia adentro y se cruzaban; se dieron vuelta y se hicieron menos transparentes.
6. **Proyecto aparte.** Mutant Lab tiene su propio proyecto de Rojo en `mutant-lab/` (puerto **34873**), para no pisar Pisada Sonora (34872). El lugar de Studio es `mutant-lab/MutantLab.rbxlx` y no se sube a git.

## Notas de la Parte 2 (máquina de fusión)

- **Cómo se usa**: la máquina está frente al punto de aparición. Te acercás a la consola (a la derecha), apretás **E** y se abre el panel. Tocás dos tarjetas (la primera va a la ranura menta y la segunda a la rosa), ves el precio y apretás **¡FUSIONAR!**. Tocar una ranura o una tarjeta elegida la saca.
- **Servidor**: el cliente solo manda las dos claves. El servidor revisa que tengas las dos criaturas y el ADN, que la máquina no esté ocupada, calcula la especie con la regla fija, cobra, tira el mutante y responde. Si no reaccionan, no cobra.
- **Animación (unos 3,3 s + 2,5 s de cartel)**: la cámara va a la máquina y tu personaje se esconde (solo para vos). Las cápsulas se llenan del color de cada padre; después la máquina tiembla, las luces parpadean, salen humo de colores y los tubos brillan. Aparece la silueta negra con el cartel "¿Qué será?" y llega la revelación: destello, la criatura real en la cúpula y el cartel con "¡ESPECIE NUEVA!" o "Ya la tenías", el nombre y la generación. La criatura queda en la cúpula hasta la próxima fusión y el panel vuelve a abrirse.
- **Mutante**: papelitos de colores, un segundo destello dorado, cartel "⭐ ¡MUTANTE! ⭐" con arcoíris que gira y una escalera de notas agudas. La criatura mutante tiene estrellitas y colores que cambian lento. En el nombre se usa **⭐** en lugar de ✦, porque la fuente del juego no tiene ese símbolo.
- **Sonidos**: todos salen del mismo sample de piano (`Config.SonidoNotaId`) cambiando el tono. Están marcados con `-- SONIDO:` en `EfectosMaquina.luau` y `PanelFusion.luau`: elegir, burbujeo, zumbido, suspenso, revelación, mutante y no reaccionan.
- **Precio en el botón**: si la mezcla de generaciones nunca reacciona (gen 2 + gen 2, o cualquier cosa con gen 3), el botón dice "gratis", porque no se cobra.
- **Modo prueba** (`Config.Prueba`, **hay que apagarlo antes de la Parte 5**): al entrar tenés las 10 bases y 100.000 de ADN, y el mutante sale 1 de cada 4 veces (en el juego real es 1 de cada 40).
- **Probado en playtest**: 10 fusiones, entre ellas Glupona + Rámulo y Rámulo + Glupona (las dos dan Glumulo; la segunda dice "Ya la tenías"), la gen 3 por los dos órdenes (Glumulo + Sutomi y Sutomi + Glumulo dan Glumumi) y una pareja que no reacciona (no cobró ADN). También se probó que el servidor rechaza una criatura que no tenés y un pedido con la máquina ocupada.

## Notas de la Parte 3 (Mutadex)

- **Dónde está**: arriba al centro, debajo del ADN, hay un botón siempre visible con "📖 12 / 50" y una barrita. Al tocarlo se abre la Mutadex; si estaba abierto el panel de la máquina, se cierra.
- **Cómo se ve**: a la izquierda, las 50 tarjetas en tres secciones (gen 1 en el orden de la rueda, gen 2 y gen 3), cada una con una nota corta de la regla. Las descubiertas se ven en 3D con su nombre. Las que faltan son una **silueta negra sobre lila con un "?" chiquito en la esquina**: el signo no tapa la forma, porque la forma es la pista. Arriba se repiten el contador, la barra y el ADN. Las mutantes llevan ⭐.
- **Ficha**: a la derecha. Si la especie es tuya, dice con qué bases se hace. Si es una silueta, muestra las pistas compradas y el botón para comprar la siguiente.
- **Cambio frente al plan original**: en lugar de las 50 siluetas alrededor de una rueda, van en una grilla por generación, que se lee mejor en el celular. El "Escáner" pasó a ser **pistas por silueta** (pedido del usuario).
- **Pistas**: cada pista cuenta algo de una de las bases que la forman, sin decir el nombre ("Viene de una criatura que tiene pico y vuela"). Una gen 2 tiene 2 pistas y una gen 3 tiene 3. Cuestan 100 × (pistas que ya compraste + 1). El servidor valida que no la tengas, que queden pistas y que te alcance el ADN. Las frases están en `Especies.luau` (campo `Pista`).
- **Premios** (en `Config.Premios`):
  - Descubrir una especie nueva devuelve **la mitad de lo que costó la fusión** (mínimo 25 ADN), y se ve en el cartel de la revelación. Se probó primero con el doble, pero sobraba tanto ADN que las pistas y el precio dejaban de importar. Se revisa en la Parte 5.
  - Completar una generación paga un premio grande: **1.000 / 10.000 / 25.000 ADN** por la gen 1, 2 y 3, con un cartel amarillo, lluvia de papelitos y una fanfarria. Al completar las 50 dice "¡MUTADEX COMPLETA!". En modo prueba la gen 1 no paga, porque viene regalada.
- **Celular**: se probó simulando una pantalla de 844×390 apaisada. Las tarjetas (86×106), los nombres y el botón de pista se leen bien, y la lista se desplaza.
- **Herramienta de prueba**: en modo prueba existe `ServerStorage.Prueba.DarEspecies` para darle especies a un jugador sin fusionar. Sirvió para probar la Mutadex con muchas especies y desaparece al apagar el modo prueba.
- **Probado en playtest**: con pocas especies (11 y 12 de 50) y con muchas (47 de 50). Se completó la gen 2 con una fusión real (premio de 10.000 y cartel) y después la gen 3, hasta el cartel de Mutadex completa en 50 / 50.

## Notas de la Parte 4 (laboratorio y economía)

- **Mapa** (reemplazado en la versión 6 por la plaza con 6 laboratorios): una calle con 4 laboratorios en fila (`Laboratorios > Lab1..Lab4`) sobre un suelo lavanda. Cada laboratorio tiene la máquina en el centro, 4 corrales (2 a cada lado), una tienda con toldo a rayas, el lugar donde aparecés y un arco en la entrada con el cartel "Laboratorio de (tu nombre)". La vitrina y la máquina sueltas de las partes anteriores quedaron guardadas en `ServerStorage > Archivo`.
- **Un laboratorio por jugador**: el servidor le da al que entra el primer laboratorio libre, lo lleva a la entrada y pone su nombre en el cartel. Cuando se va, el laboratorio queda libre. Cada jugador solo puede usar su máquina y su tienda. El servidor debería ser de **4 jugadores como máximo**: eso lo cambia el usuario en la configuración del juego.
- **Corrales**: las criaturas que trabajan caminan por su corral (van a un punto al azar, paran un rato y siguen). Hay un **tope**: 4 criaturas por corral y arrancás con 1 corral abierto. Trabajan las de mayor generación; las demás quedan en la colección (Mutadex y panel). Los corrales cerrados se ven grises con un cartel "🔒 Se abre en la tienda".
- **ADN por segundo**: 1 por base, 2 por gen 2 y 6 por gen 3, solo de las que trabajan. Se ve en el HUD ("+9/s") y con un "+N" que sube sobre cada criatura cada 3 segundos.
- **Tienda** (mostrador con la E): pestaña **Especies base**, donde elegís cuál comprar (sin azar) y el precio sube con cada una: 50, 120, 300, 800, 2.000, 5.000, 12.000 y 30.000. Pestaña **Mejoras**: *Más corrales* (150 / 1.500 / 8.000), *Fusión rápida* (250 / 1.500 / 6.000, la máquina dura 80 %, 65 % y 50 %) y *Nutrientes* (+25 % de ADN por nivel: 200 / 800 / 3.000 / 10.000 / 30.000). Todo está en `Config.luau`.
- **Arranque nuevo**: se apagó el modo prueba. El jugador nuevo empieza con **2 bases (Glupona y Rámulo) y 30 ADN**. El premio mínimo por descubrir bajó a 10, para que la primera fusión no deje ganancia.
- **Arreglo**: las criaturas que crea el servidor a veces avisaban que llegaron antes que sus piezas y arrancaban a caminar desde el centro del mapa. Ahora el cliente espera la pieza raíz antes de animarlas.

### Prueba de 5 minutos como jugador nuevo (2026-10-08)

La jugó un jugador automático que **no conoce la regla**: prueba al azar parejas que todavía no probó (solo mezclas de generaciones que pueden reaccionar), compra la base vecina cuando le alcanza, abre un corral cuando se llena y tarda 3 segundos en elegir cada fusión, además de mirar la animación entera. Arrancó con unos 20 ADN extra, porque el juego ya corría unos segundos antes de que empezara.

| Minuto | Especies | ADN | ADN/s | Trabajan |
|---|---|---|---|---|
| 1 | 6 | 203 | 9 | 6 de 8 |
| 2 | 10 | 625 | 22 | 8 de 8 |
| 3 | 13 | 1.628 | 24 | 8 de 8 |
| 4 | 16 | 1.854 | 35 | 12 de 12 |
| 5 | **17** | 2.739 | 35 | 12 de 12 |

- **17 especies a los 5 minutos**: 6 bases compradas o iniciales, 8 de gen 2 y 3 de gen 3 (la 18.ª salió a los 5:00,3).
- Hizo 42 intentos de fusión: 12 especies nuevas, 3 repetidas y 27 que no reaccionaron. Compró 6 cosas: 4 bases y 2 corrales.
- **Lo que mostró**:
  - Al jugador nuevo no lo frena el ADN, lo frena saber qué combinar: le sobraron unos 2.700 ADN. Eso es bueno para la pregunta del prototipo, pero entonces las pistas tienen que ser la salida natural de ese ADN. Revisar en la Parte 5 si conviene subir precios o hacer más visible el botón de pistas.
  - Dos de cada tres intentos no reaccionaron, sobre todo los de gen 2 + base. Leer la nota de la rueda en la Mutadex ayuda mucho.
  - Pagó 3 veces por una gen 3 que ya tenía, llegando por otro camino (por ejemplo Ratomi + Glupona después de Glumulo + Sutomi). Idea para la Parte 5: que el panel avise "ya la tenés" antes de fusionar.
  - El piso crema del laboratorio se ve casi blanco con esta luz: revisar en el pulido.

## Notas del mapa nuevo (versión 6)

Reemplaza la calle con 4 laboratorios de la Parte 4.

- **Plaza** (`Workspace > Plaza`, armada en Studio): un círculo en el centro del mundo con la **máquina de fusión en equipo**, más grande que las demás y con un tubo de luz que sube al cielo. Hay dos tableros gigantes (**experimento del día** y **tabla de posiciones**), 12 faroles verdes, 4 bancos, una flecha de neón por laboratorio con el nombre del dueño (o "Libre") y cristales apagados entre los laboratorios para que afuera no quede vacío. Los jugadores aparecen en la plaza (`Llegada`) y el servidor los lleva a su laboratorio.
  - La máquina en equipo y los dos tableros **todavía no funcionan** (son de las Partes 8 y 9). Por eso dicen "¡Muy pronto!".
- **6 laboratorios** alrededor de la plaza, a 80 studs del centro, con la entrada mirando a la plaza. **No están armados en Studio**: el servidor los genera al arrancar clonando el molde `ServerStorage > Moldes > Laboratorio`, como pide la guía. Para cambiar el diseño se cambia el molde y salen todos iguales. Las posiciones están en `Config.Mapa` y la cantidad en `Config.CantidadLaboratorios` (6).
- **Cada laboratorio** (68 studs de diámetro): pared alta atrás y baranda baja adelante, con el arco y el nombre del dueño en neón. Adentro están la máquina en el centro, 4 corrales hexagonales con cúpula, la Mutadex como pantalla gigante en la pared del fondo, la tienda con el robot a la izquierda, el estante de trofeos a la derecha (vacío hasta la Parte 8), tubos con burbujas, estantes con frascos, pantallas, carteles graciosos, cables y cajas.
- **La máquina nueva**: una cápsula de vidrio alta en el medio, dos ranuras a los costados (una por padre) con tubos de líquido verde hacia la cápsula, y arriba la ranura del catalizador con candado. La animación de la Parte 2 sigue igual: se llenan las ranuras con el color de cada padre, los tubos toman ese color, tiembla, sale humo, aparece la silueta y la criatura nueva se revela adentro de la cápsula.
- **Corrales**: el abierto tiene cúpula de vidrio, borde de neón verde, luz y un cartel con su ADN por segundo. El cerrado tiene cúpula opaca, borde de metal, candado y el cartel "Se abre en la tienda". Los laboratorios libres se ven como uno nuevo: solo el primer corral abierto.
- **Pantalla de la Mutadex**: muestra cuántas especies descubriste y la última especie nueva, con el borde del color de su generación. Se actualiza después de la revelación, para no adelantar la sorpresa.
- **Luces**: 7 por laboratorio (la guía permite hasta 12) y 7 en la plaza. Cada laboratorio tiene unas 460 partes, sin contar las criaturas.
- **El servidor debería ser de 6 jugadores como máximo.** Eso lo cambia el usuario en la configuración del juego (hoy está en 60).
- **Probado en playtest** (2026-10-08): se generan los 6 laboratorios, el jugador recibe el Lab1 con su nombre en el arco y en la flecha de la plaza, y hay 2 criaturas en el corral 1. Se probó una fusión real (Glupona + Rámulo = Glumulo): se ve la animación entera con la máquina nueva, la Mutadex de la pared pasa a 3 / 50 con la tarjeta de Glumulo y el corral pasa a +4 ADN/s. La consola quedó sin errores.

## Notas de la Parte 5 (guardado, balance y pulido)

### Guardado
- `server/Guardado.luau` guarda en el DataStore `MutantLab_v1` (nombre en `Config.Guardado`): ADN, especies descubiertas (son las criaturas: hay una de cada especie), mutantes, pistas compradas, premios de generación ya cobrados y niveles de las mejoras. Al volver, los corrales se arman solos con esas especies.
- Se guarda al salir, cada 60 segundos y al cerrar el servidor. Si Roblox no responde, reintenta 3 veces.
- Lo que viene guardado se revisa antes de usarlo: solo pasan especies que existen y niveles válidos.
- **Si la carga falla, se juega igual pero no se guarda nada**, para no pisar los datos buenos con un laboratorio vacío.
- Falta (decisión mía, lo más simple): bloqueo de sesión (si alguien entra a dos servidores a la vez, gana el último que guarda) y ADN ganado sin estar conectado.
- **Probado sin acceso**: si Studio no tiene acceso al DataStore, el juego avisa una vez en la consola y sigue andando sin guardar.
- **Probado con acceso** (2026-10-08, el usuario activó Game Settings > Security > "Enable Studio Access to API Services"): se le cargaron a un jugador 8 especies, 4.321 de ADN y mejoras (corrales 2, rapidez 1, nutrientes 3), se guardó, se salió y se volvió a entrar. Volvió todo: especies, mejoras, las 8 criaturas en los corrales, la guía apagada y el ADN en 4.685 (más de lo guardado a mano, así que también guardó al salir). Una pista comprada también volvió después de salir y entrar. Los mutantes van por el mismo camino que las especies, pero no se probaron aparte. Consola sin errores.
- Ojo: en Studio, con el acceso prendido, se usa el DataStore real del juego. El jugador de prueba (la cuenta del usuario) quedó con esos datos de prueba guardados.
- Para probar a mano: `ServerStorage.Prueba.Guardar` guarda en el momento.

### Balance (los números están en `Config.luau`)
| Qué | Antes | Ahora |
|---|---|---|
| ADN inicial | 30 | 100 (justo la primera fusión) |
| Fusión gen 2 | 20, +10 % por especie | 100, +30 % por especie |
| Fusión gen 3 | ×5 | ×3 |
| Bases (3.ª a 10.ª) | 50, 120, 300, 800, 2.000… | 450, 1.350, 3.200, 6.800, 16.000, 36.000, 80.000, 180.000 |
| Más corrales | 150 / 1.500 / 8.000 | 300 / 5.000 / 25.000 |
| Fusión rápida | 250 / 1.500 / 6.000 | 500 / 3.000 / 12.000 |
| Nutrientes | 200 / 800 / 3.000 / 10.000 / 30.000 | 600 / 2.500 / 8.000 / 25.000 / 70.000 |

- Por qué: con los números viejos un jugador llegaba a 17 especies en 5 minutos y le sobraba ADN. Cada base nueva abre de golpe 3 a 5 fusiones; ahora cada fusión cuesta más o menos lo que se junta en medio minuto, así las especies salen de a una y no en ráfagas.
- Primero se ajustó con un simulador (usa los módulos reales del juego, 20 partidas por variante) y después se midió en Studio con un jugador automático que juega 10 minutos reales: tarda 3 s en elegir cada fusión, mira la animación entera, prueba parejas al azar (incluso las que no reaccionan), compra la base vecina cuando le alcanza y abre un corral cuando se llena.
- **Tiempos medidos (playtest real de 10 minutos)**:
  - Primera fusión: a los **15 segundos** (Glupona + Rámulo, con los 100 ADN del arranque).
  - Especies por minuto: 3 · 3 · 5 · 6 · 7 · 8 · **10** (minuto 7) · 11 · 12 · **12** (minuto 10).
  - Especies nuevas en: 0:15, 2:18, 2:47, 3:05, 4:51, 5:58, 6:24, 6:42, 7:04 y 8:58.
  - **Hueco más largo sin especie nueva: 2:18** (entre la primera fusión y la 3.ª base). Nunca pasó de 3 minutos.
  - Hizo 6 intentos que no reaccionaron (gratis) y le quedaban 2.785 ADN al minuto 10 (la 5.ª base cuesta 3.200).
- El simulador da lo mismo (unas 13 especies a los 10 minutos, hueco máximo de 2:30). Un jugador de verdad va un poco más lento que el automático, así que debería andar por **10 a 12 especies a los 10 minutos**.
- **Panel de fusión**: si la pareja da una especie que ya tenés, avisa "Ya tenés a (nombre): solo sirve para buscar el mutante" antes de cobrar (la idea de la Parte 4). Solo lo dice de las que ya tenés, así no adelanta especies nuevas. Sin este aviso, el jugador automático gastaba en repetidas y los huecos llegaban a 4 minutos.

### Guía de los primeros segundos
- Si el jugador todavía no fusionó nunca (atributo `Guia` que pone el servidor), aparecen: una **flecha magenta que salta sobre la máquina**, un **camino de luz verde** desde los pies del personaje hasta la consola y un cartel abajo al centro: "¡Seguí la flecha hasta la máquina y fusioná 2 criaturas!" (texto en `Config.Guia`).
- Todo se va la primera vez que abre la máquina. Al que vuelve con datos guardados ya no le aparece.
- La flecha es magenta (el color de "novedades" de la guía) porque verde sobre la cápsula verde no se veía. El cartel va abajo porque arriba tapaba la flecha.

### Efectos
- **Número que salta**: cada vez que cambia el ADN, al lado del contador sale "+N" verde (o dorado y más grande desde 50, por ejemplo premios) que sube y se desvanece; al gastar sale "-N" en rojo.
- **Rebote del contador**: un saltito con el ADN de cada segundo y un rebote fuerte con los premios (ya venía en el HUD nuevo).
- **Destello al comprar**: esfera de luz que crece, chispas y un acorde. Va sobre lo que cambió: la criatura nueva (bases), el corral que se abrió (Más corrales) o el mostrador de la tienda (otras mejoras y pistas). El servidor avisa con el remoto `Compra` solo si la compra salió bien. Marcado con `-- SONIDO:`.

### Rendimiento (20 criaturas)
- En Studio, con 20 criaturas caminando en el laboratorio: animarlas cuesta **1,1 ms por cuadro**; dibujar todo, unos **5 ms de CPU y 4 ms de placa de video**. Sobra para 60 cuadros por segundo en computadora.
- El riesgo en celular era otro: con 6 laboratorios llenos hay casi **100 criaturas** y cada celular animaba todas (4,3 ms por cuadro). Ahora solo se animan las que están a menos de 80 studs de la cámara (`Config.Animacion.DistanciaAnimar`): con 100 en el mapa se animan unas 44 y cuesta 1,8 ms.
- Ojo: cada criatura tiene entre 26 y 39 partes (la guía pide 12 como máximo). Hoy no es un problema, pero si en celular anda lento, juntar piezas es lo primero para mirar.
- No se pudo probar en un celular de verdad: eso lo tiene que hacer el usuario.

### Otros arreglos
- La interfaz nueva había dejado colgada la Mutadex vieja (esperaba el botón de progreso del HUD viejo) y los botones Mutadex y Tienda del HUD no abrían nada. Ahora abren la Mutadex y la tienda viejas (puente **temporal** en `UI/Menus.luau`, hasta rehacerlas). Abrir una cierra las otras, y abrir la máquina o el mostrador también.
- `HerramientasPrueba` ahora también existe jugando en Studio (en el juego publicado no): `DarEspecies`, `PonerDatos` (ADN y mejoras) y `Guardar`.

### Revisión de la Parte 5 con pedidos, personalidades y catalizadores (versión 11)
Pedido 4 de `ORDEN-PEDIDOS.md`. Se revisó lo de arriba en vez de rehacerlo.

**Guardado** (`server/Guardado.luau`, versión 2 del guardado; los de la versión 1 se convierten solos)
- Se guarda todo lo del jugador: ADN, especies descubiertas, mutantes, **cada criatura con su personalidad y su variante**, las variantes conseguidas y los sellos de personalidades (Mutadex), residuos, catalizadores (los que tenés y los que conocés), los pedidos del tablero (con su premio de pista o catalizador) y cuántos entregaste, niveles de las mejoras, pistas compradas y gratis, y premios de generación cobrados.
- Todo lo que vuelve del DataStore se revisa: especies, personalidades, variantes y catalizadores que no existen se descartan; a las criaturas de guardados viejos les toca la personalidad de su especie.
- **Probado** (2026-10-09): un jugador con 10 especies, un "Glumulo de Rayo" (variante, Peleadora), 11 sellos, un residuo, 2 catalizadores de Hielo, 3 pedidos (dos con catalizador de premio), 2 corrales y Nutrientes 1. Se guardó, se salió y se volvió a entrar: volvió todo igual, la variante apareció en su corral con su color y sus cejas, y el ADN un poco más alto (también guardó al salir).
- Sigue afuera (decisión de antes): el bloqueo de sesión. El ADN ganado sin estar conectado llega en el pedido 6.

**Balance** (números en `Config.luau`)

| Qué | Antes | Ahora | Por qué |
|---|---|---|---|
| Suba del costo de fusión | 40 % por especie, siempre | 40 % hasta las 12 especies, **12 %** después (`EspeciesSubaTardia`, `SubaTardia`) | Con 40 % siempre, a las 25 especies una fusión costaba 250.000 ADN y en 6 horas no pasaba de 26 especies. |
| Premio de pedido medio | 1,2 fusiones | 1,1 | Con los premios grandes el ADN pasaba del triple de la próxima fusión justo después de cobrar. |
| Premio de pedido difícil | 2 | 1,5 | (ídem) |
| Premio de "Cualquier mutante" | 4 | 3 | (ídem) |
| Premio cada 10 pedidos | 2 | 1 | (ídem: coincidía con el cobro de un pedido) |

Los primeros 10 minutos no cambiaron: la suba nueva empieza a las 12 especies.

**Medido** con el simulador (`ServerStorage.Prueba.Simular`, el jugador automático con las reglas de verdad, tiempo simulado) y en Studio en tiempo real:

| Meta del pedido | Medido |
|---|---|
| Primera fusión en el primer minuto | A los 3 segundos (jugador automático). A mano, como jugador nuevo: a los ~30 segundos de entrar, siguiendo la flecha. |
| Unas 10 especies en los primeros 10 minutos | 11 (simulador, 30 partidas: entre 11 y 13). En Studio, en tiempo real: **11**, nuevas en 0:03, 0:45, 1:27, 2:05, 4:30, 6:23, 7:01, 7:33 y 8:12 (más dos bases compradas); el hueco más largo sin especie nueva fue de 2:25. Entregó 16 pedidos, el ADN llegó a 2.243 y **nunca pasó del triple** de la próxima fusión, y hasta sacó una variante de Hielo. |
| El ADN, como máximo el triple de la próxima fusión | Primeros 10 minutos: 3,0 en promedio como máximo (la peor partida 3,6, unos 2 segundos justo después de cobrar). Hasta completar la Mutadex: 3,6 (peor 4,6), unos 15 segundos en 4 horas. Nunca se acumula: lo gasta enseguida. |
| Nunca más de 3 minutos sin algo útil | El rato más largo sin fusionar, comprar, entregar ni hacer un residuo: 107 segundos en promedio (peor 111). |
| Completar la Mutadex principal en 3 a 5 horas | El jugador automático la completa en **2,4 a 4,3 horas** (8 partidas de 7 horas). Una persona juega más lento (mira, piensa, camina), así que debería caer entre 3 y 5 horas. |

- **Arreglos del jugador automático** que salieron de medir partidas largas: descartaba pedidos imposibles solo si no tenía nada más que hacer, pero un residuo siempre se puede hacer, así que nunca descartaba y a las 4 horas dejaba de entregar (ahora descarta antes de hacer residuos). Y al hacer una copia para un pedido, si tiene un catalizador, aprovecha para probar una variante nueva.
- En 7 horas el jugador automático hace unas 290 fusiones con catalizador, consigue 165 variantes, entrega 37 pedidos de personalidad y 125 de variante.

**Guía de los primeros 30 segundos**: probada con un jugador nuevo de verdad (datos guardados de jugador nuevo, saliendo y entrando): flecha magenta sobre la máquina y el cartel "¡Seguí la flecha hasta la máquina y fusioná 2 criaturas!". Caminando hasta la consola y fusionando Glupona + Rámulo, la primera especie salió a los ~30 segundos y la guía se fue sola. Si se reinicia un jugador sin salir del juego la guía no vuelve a aparecer (solo pasa con la herramienta de prueba).

**Rendimiento**: los 4 corrales llenos (16 criaturas, varias de generación 3 con aura y dos mutantes) más las 2 de las cápsulas, con 15 emisores de partículas: **60 cuadros por segundo** en Studio, el peor cuadro de 18 ms. Las variantes suman un emisor de partículas por criatura (como el aura). Sigue sin probarse en un celular de verdad.

**Consola** sin errores; `stylua` y `selene` sin avisos.

**Qué se puede jugar hoy**: fusionar las 50 especies con la regla de la rueda, residuos y catalizadores cuando no reaccionan, personalidades que se heredan y cambian el ADN del corral, variantes con la ranura de catalizador, la Mutadex con sellos y variantes, pistas, tienda de bases, copias y mejoras, 4 corrales, pedidos de 7 tipos con clientes, premios cada 10 pedidos, guía de inicio y guardado de todo.
**Qué falta** (pedidos que vienen): el espectáculo de la fusión y la vida en el corral (pedido 5), ADN sin conexión, premio diario y misiones (pedido 6), la plaza y el juego con otros (pedido 7), y lo que cuesta Robux (pedido 8, después de publicar). La pestaña Extras de la Mutadex sigue vacía.

## Notas de la interfaz terminada (versión 8)

Toda la interfaz se arma por código con las piezas de `client/UI` (colores de `Paleta.luau`, medidas de `UI/Tema.luau`, íconos de `UI/Iconos.luau`) y se abre y cierra con `UI/Menus`. Ya no hay ScreenGui armados a mano en Studio: se borraron `Fusion`, `Mutadex`, `Tienda` y `Revelacion`. No quedan colores con `fromHex` fuera de `Paleta.luau` ni `Config.Estilo`.

- **Panel de fusión**: casilleros de los padres (izquierda verde ácido, derecha magenta) con un "+" entre ellos, el catalizador arriba con candado, "=" y la vista previa. Abajo, tus criaturas con el borde de su generación, el punto de su elemento y la estrella si la tenés mutante, filtrables con botones redondos de cada elemento. Tocar una criatura la hace saltar al casillero; tocar un casillero lleno lo vacía.
  - Vista previa: si el resultado es una especie que ya tenés, la muestra; si es nueva, "?" verde con "¡Nueva!"; si la pareja no reacciona, "×" rojo.
  - Botón "¡FUSIONAR!" con el costo. Si falta ADN, apagado y "Te faltan X ADN" en rojo. **Decisión**: si la pareja no reacciona, el botón queda apagado y lo dice antes de apretar (hasta ahora te dejaba probar gratis). Cuando existan los residuos (pedido 3) se vuelve a prender.
- **Mutadex**: encabezado con "12 / 50", barra y ADN; pestañas Gen 1, Gen 2 y Gen 3 con su conteo, y Extras ("llegan pronto"). Arriba de cada grilla queda la nota de la regla. Las siluetas tienen el "?" en una esquina, para no tapar la forma.
  - Ficha: al costado en computadora; en celular tapa la grilla, en dos columnas, y se cierra con su X. Tiene la criatura grande girando, generación, elemento, personalidad, la receta (si ya la descubriste) y las pistas con su botón.
  - **Decisión: personalidad por especie** (reemplazada en la versión 10 por los sellos de las personalidades conseguidas). Todavía ninguna criatura tenía personalidad propia, así que cada especie tenía una fija (`Personalidades.deEspecie`, a partir de sus bases). Se muestra con su ícono, verde si es positiva y magenta si es negativa. Sirve como "regla fija por especie" para el pedido 3.
- **Tienda**: pestañas Especies, Mejoras, Catalizadores ("llegan pronto") y Premium. En Premium se ven los 7 pases de `Config.Premium` con borde dorado y el precio en Robux, apagados y con "Próximamente" hasta que tengan ID. Las mejoras muestran "Nivel 2 / 4" con puntos. Al comprar: destello sobre la tarjeta, sonido y el ADN del encabezado rebota.
- **Festejos**: generación completa y Mutadex completa usan el cartel grande de `UI/Carteles` (uno por vez, en cola) con papelitos verde ácido, magenta, dorado y de los 5 elementos. La revelación de la máquina usa el mismo cartel, fijo arriba para no tapar la cúpula.
- **Misiones y Ajustes**: ventana chica con "llegan pronto". Ajustes ya trae el interruptor del sonido.
- **Piezas nuevas en `client/UI`**: casillero con vista prestada (`VistasVisibles`), estrella y punto de elemento; lista que se desplaza; grilla; puntos de nivel; insignia; destello; papelitos. Íconos nuevos: estrella, corazón, martillo, rayo, cubierto, "Zzz", "?" e "=".
- **Arreglos**: los avisos que empiezan con "¡" ahora salen como éxito (verde) y el ícono de los botones de alto relativo (las pestañas) ya no sale diminuto.
- **Herramientas de prueba nuevas** (solo en Studio): `DarMutantes` y `Reiniciar` (vuelve a jugador nuevo).
- **Pendiente**: quedan emojis en carteles del mundo (corrales "🧬 +N" y "🔒 Se abre en la tienda", "⭐" en la pantalla de la Mutadex de la pared) y en los íconos de personalidad sobre la cabeza (que todavía no se usan). Con un menú abierto, tocar un botón del HUD primero cierra el menú.
- **Probado** (2026-10-09) en computadora y en celular simulado (844 × 390): fusión real con las cuatro situaciones del botón, compra de pista, compra de base y de mejora, festejos encolados, Misiones y Ajustes. Consola sin errores. Capturas en `capturas/pedido-1/final`.

## Pedidos (versión 9)

El jugador descubría especies pero no tenía para qué usarlas, y el ADN le sobraba. Ahora las criaturas sirven para cumplir pedidos de clientes, y el ADN es el límite.

### Criaturas y Mutadex (cambio de fondo)
- **La Mutadex es lo que descubriste y nunca se pierde.** Aparte, tenés **criaturas** en el laboratorio, una por una: la primera de cada especie y cada copia que hagas.
- Cada fusión que sale bien suma una criatura, **también si la especie ya la tenías** (el panel avisa "Ya la tenés: sale otro ... para tus pedidos", pero deja fusionar).
- Para fusionar hace falta tener al menos una criatura de cada padre (los padres no se gastan). Las que trabajan en los corrales son las de mayor generación, hasta el tope, y puede haber varias iguales.
- En la tienda, las bases que ya descubriste se compran como **copias** (0,6 fusiones): sirven para pedidos o para reponer una que entregaste.
- El panel de fusión muestra cuántas tenés de cada una ("Glumulo ×2") y la ficha de la Mutadex dice "En tu laboratorio: N".
- Los guardados viejos se convierten solos: una criatura por especie descubierta (guardado versión 2).

### El tablero
- Un **tablero de pedidos** en cada laboratorio (cerca de la entrada, al costado del camino a la máquina), con pantalla, borde de neón verde y la E para abrirlo. También se abre tocando el **contador de pedidos del HUD** (debajo del ADN), que muestra cuántos entregaste y cuántos faltan para el premio.
- **3 pedidos activos**, cada uno con un **cliente** inventado (Doña Burbuja, Profe Tornillo, Tía Gelatina, Don Pepino, Capitana Grumo, Lola Chispitas, Tito Pegote, Señor Calcetín, Abuela Fideo, Mister Pompón, Chef Albóndiga y Baronesa Merengue), un muñequito de color, lo que pide, el premio y cuántas criaturas tuyas sirven.
- **Tipos de pedido** (salen solos de las 50 especies):
  - Por rasgo: "Algo de tipo fuego con alas", "Algo con cuernos y con cola". Los rasgos salen de las piezas: hojas, hongo, cuernos, orejas enormes, pico, antenas, tres ojos, cola, alas, dos patas y seis patas (`shared/Rasgos.luau`).
  - Por generación: "Una criatura de generación 2 de tipo agua".
  - Por cantidad: "Dos criaturas de tipo planta" (se entregan dos).
  - Especie exacta: "Un Glumulo", solo de especies que ya descubriste.
  - Mutante: "Cualquier mutante", desde las 8 especies y con premio grande.
- **Uno de los tres pide algo nuevo** (cartel "¡Algo nuevo!"): una especie que podés hacer con tus bases pero todavía no descubriste, pedida de forma que ninguna de las tuyas sirva. Los otros dos se arman con lo que ya tenés o podés hacer.
- **Decisión**: nunca se pide como única opción la base de la que tenés una sola (la necesitás para fusionar); de esas solo se piden "dos de tipo ...".
- **Entregar**: se elige en una lista de las criaturas que sirven (si hay una sola, ya queda elegida). Avisa si es tu última de esa especie. La criatura **se despide**: salta dos veces en el globo del pedido, vuela hacia el cliente, que dice "¡Gracias!" y le sale un corazón. Después llega otro pedido.
- **Premio** según la dificultad, medido en fusiones de gen 2 (así crece con el juego): fácil 0,9; media 1,2; difícil 2; mutante 4; los de dos criaturas x1,2. Los que no son fáciles a veces traen **una pista gratis** (la próxima pista no se cobra). Los catalizadores como premio no hicieron falta: en la versión 10 se arman con residuos.
- **Descartar**: la X de cada pedido. El lugar queda vacío 2 minutos, con cuenta regresiva.
- **Cada 10 pedidos**, un premio extra de 2 fusiones con su cartel y papelitos.
- Todo se valida en el servidor (`server/Tablero.luau`): que el pedido exista, que las criaturas cumplan y que las tengas. Los números están en `Config.Pedidos`.

### Que el ADN sea el límite
- **Todo lo que se compra cuesta "fusiones"**: un número x lo que cuesta ahora una fusión de gen 2. Base nueva: 2,5. Copia de base: 0,6. Más corrales: 2 / 2,5 / 3. Fusión rápida: 1,5 / 2 / 2,5. Nutrientes: 1 / 1,5 / 2 / 2,5 / 3. Antes había precios fijos (hasta 180.000) y para comprar una base o un corral había que juntar mucho más que el triple de una fusión.
- **Fusiones más caras**: 150 (antes 100) y suben 40 % por especie (antes 30 %). La de generación 3 cuesta el doble de una de gen 2 (antes el triple), para que sus pedidos convengan. El ADN inicial pasa a 150, justo la primera fusión.
- Se ajustó con un **simulador** (`server/Simulador.luau`, `ServerStorage.Prueba.Simular`): juega partidas de 10 minutos con el jugador automático y las reglas de verdad, y prueba variantes de Config sin reiniciar. Con los números elegidos (30 partidas): 11 especies, 14 pedidos entregados, el ADN pasa del triple de la próxima fusión unos 10 segundos por partida (justo después de cobrar un premio) y nunca se queda sin nada útil para hacer.
- **El jugador automático** (`server/Robot.luau`) juega como uno nuevo que no conoce la regla: mira parejas en el panel (que le dice si reaccionan y si son nuevas), fusiona lo nuevo, entrega pedidos sin dar su última criatura de cada especie, compra copias y bases, abre corrales y, si le sobra ADN, compra mejoras. Tarda 3 s en pensar, 7 s por fusión (mira la animación), 5 s por entrega y 6 s por compra (camina a la tienda).

### Prueba de 10 minutos como jugador nuevo (2026-10-09, en Studio, tiempo real)
Con `ServerStorage.Prueba.Jugar` el jugador automático jugó 10 minutos con las funciones de verdad del servidor (se ven las animaciones, las despedidas y los festejos):

| Minuto | Especies | ADN | ADN/s | Entregados | Próxima fusión |
|---|---|---|---|---|---|
| 1 | 4 | 163 | 5 | 2 | 210 |
| 2 | 5 | 1 | 6 | 3 | 294 |
| 3 | 6 | 303 | 7 | 6 | 412 |
| 4 | 7 | 199 | 12 | 8 | 576 |
| 5 | 8 | 785 | 12 | 10 | 807 |
| 6 | 9 | 350 | 12 | 12 | 1.129 |
| 7 | 10 | 573 | 12 | 13 | 1.581 |
| 8 | 11 | 1.180 | 12 | 14 | 2.214 |
| 9 | 11 | 572 | 12 | 14 | 2.214 |

- **Especies**: 11 (9 descubiertas). Nuevas en 0:03, 0:48, 1:29, 2:33, 3:51, 4:53, 5:02, 6:09 y 7:44.
- **Pedidos entregados**: 14 (y cobró el premio de los 10). Hizo 11 fusiones, 21 compras (casi todas copias de bases para pedidos) y descartó 3 pedidos.
- **ADN máximo**: 2.129. El ADN pasó el triple de la próxima fusión 10 segundos en total (máximo 3,7 veces, justo después de cobrar un pedido).
- **Veces sin saber qué hacer**: 0. Ojo: el jugador automático siempre tiene parejas para mirar en el panel; una persona que no prueba sistemáticamente puede trabarse más.
- **Para mirar**: el ADN por segundo quedó en 12 desde el minuto 4: gastó todo en copias y pedidos y no abrió el segundo corral. Si en el juego de verdad se siente lento, bajar el precio del 2.º corral.
- El guardado (versión 2) se probó cerrando y abriendo: volvieron las criaturas (con su mutante), los pedidos, los entregados y las pistas gratis.

## Fracasos útiles, personalidades y catalizadores (versión 10)

Dos de cada tres fusiones daban "No reaccionan" y eso no daba nada. Ahora cada intento suma, cada criatura tiene personalidad y aparece la tercera ranura de la máquina. Pedido 3 de `ORDEN-PEDIDOS.md`, hecho en tres bloques.

### Bloque 1: fracasos útiles
- Si una pareja no reacciona, la máquina igual produce un **residuo** con el color mezclado de los dos padres: una gota en la cápsula y en la vista previa del panel. No cobra ADN (como antes) y se guarda.
- **Con 5 residuos se arma un catalizador** al azar entre los que conocés (`Config.Residuos.ParaCatalizador`). El casillero de la ranura muestra "Residuos 3/5".
- **Decisión: qué catalizadores "conocés".** El de cada elemento del que ya descubriste una especie (Hielo = agua, Slime = planta, Lava = fuego, Rayo = eléctrico, Sombra = sombra), más los que ya tuviste. Arrancás conociendo Hielo y Slime (Glupona es de agua y Rámulo de planta) y se suman al descubrir bases. Antes de esta decisión salía siempre el mismo.
- **La máquina dice por qué no reaccionaron**, en una frase que enseña la regla (`Fusion.motivo`): "Son la misma especie: hacen falta dos distintas", "Las de generación 3 ya no se fusionan", "Dos de generación 2 no reaccionan: probá una gen 2 con una base", "Están muy lejos en la rueda: tienen que estar a 3 lugares o menos", "Esa base ya está en la mezcla: probá con otra" y "Las tres bases tienen que quedar seguidas en la rueda". Se ve antes de apretar (en el panel) y en el cartel de la máquina.

### Bloque 2: personalidades de verdad
- **Toda criatura tiene una de las 8 personalidades.** Cambia sus ojos, el ícono sobre su cabeza (borde verde si es positiva, magenta si es negativa) y el ADN que dan ella y las demás de su corral (`Config.Personalidades`). Las negativas pierden algo pero tienen una ventaja.

| Personalidad | Tipo | Efecto en el corral | Ícono |
|---|---|---|---|
| Alegre | positiva | las demás de su corral dan +10 % | corazón |
| Curiosa | positiva | da +20 % | "?" |
| Líder | positiva | las demás de su corral dan +15 % | estrella |
| Trabajadora | positiva | da +35 % | martillo |
| Vaga | negativa | da la mitad, pero las demás dan +10 % (las tranquiliza) | "Zzz" |
| Peleadora | negativa | da +80 %, pero las demás dan −20 % | rayo |
| Miedosa | negativa | da −30 %, pero con una Líder en su corral da +50 % | gota |
| Glotona | negativa | da +60 %, pero las demás dan −10 % | cubierto |

- **Herencia (tabla fija):** la personalidad de la cría sale de la de los dos padres, sin azar. Mismo con mismo da lo mismo, salvo dos Líderes, que se pelean.

| Padres | Alegre | Curiosa | Líder | Trabajadora | Vaga | Peleadora | Miedosa | Glotona |
|---|---|---|---|---|---|---|---|---|
| **Alegre** | Alegre | Curiosa | Líder | Alegre | Alegre | Peleadora | Alegre | Glotona |
| **Curiosa** | Curiosa | Curiosa | Curiosa | Trabajadora | Curiosa | Peleadora | Miedosa | Curiosa |
| **Líder** | Líder | Curiosa | Peleadora | Líder | Trabajadora | Líder | Miedosa | Líder |
| **Trabajadora** | Alegre | Trabajadora | Líder | Trabajadora | Vaga | Trabajadora | Trabajadora | Glotona |
| **Vaga** | Alegre | Curiosa | Trabajadora | Vaga | Vaga | Vaga | Miedosa | Glotona |
| **Peleadora** | Peleadora | Peleadora | Líder | Trabajadora | Vaga | Peleadora | Peleadora | Glotona |
| **Miedosa** | Alegre | Miedosa | Miedosa | Trabajadora | Miedosa | Peleadora | Miedosa | Vaga |
| **Glotona** | Glotona | Curiosa | Líder | Glotona | Glotona | Glotona | Vaga | Glotona |

- **Regla fija por especie** (cuando no hay padres: las bases que se compran y las criaturas de los guardados viejos): suma = cantidad de bases + cada base × (2 × su lugar − 1); sale la personalidad número (suma mod 8) + 1 de la lista de arriba (`Personalidades.deEspecie`). Las bases: Glupona Líder, Rámulo Trabajadora, Sutomi Vaga, Rocote Peleadora, Chisparo Miedosa, Dunaqui Glotona, Zoplito Alegre, Brinoza Curiosa, Fotina Líder y Nerulo Trabajadora.
- **Elegís con qué criatura fusionar**: el panel muestra una tarjeta por especie y personalidad, con su sello ("Glumulo ×2" con el "?" de Curiosa). Antes de apretar, la máquina dice cómo va a salir la cría ("Va a ser Líder: las demás de su corral dan +15 %."). El cartel de la revelación también la dice ("Generación 2 · Líder").
- **Los efectos valen dentro de cada corral** (4 criaturas). **Decisión:** el servidor las acomoda solo entre los corrales para que rindan más (prueba cambios de lugar mientras suba el ADN total), así el jugador no tiene que mover criaturas. El cartel del corral y el "+N" que flota sobre cada criatura muestran lo que produce de verdad.
- **Mutadex:** la ficha de cada especie tiene los **sellos** de las personalidades que ya conseguiste ("3/8") y las nombra.
- **Pedidos de personalidad:** "Una criatura Alegre de tipo agua". Salen en 3 de cada 10 pedidos comunes, solo con personalidades que tenés en esa especie (de una base, solo si tenés dos), y pagan como dificultad media o más.
- Los guardados guardan la personalidad de cada criatura y los sellos; los viejos reciben la de su especie.

### Bloque 3: catalizadores
- **La ranura de catalizador** (arriba de la máquina y en el panel) se abre a las **10 especies descubiertas**, con un cartel que la explica. Hasta entonces tiene candado. En el mundo, el candado se va y la ranura toma el color del catalizador elegido.
- **Tocar la ranura** pasa por los catalizadores que tenés (y después del último queda vacía). Muestra el ícono y cuántos te quedan ("Hielo ×2").
- **Cada catalizador crea una variante fija** de la especie que sale: otro color (la criatura toma 55 % del color del catalizador y su gema), otro rasgo (partículas propias) y un apellido. Algunos además cambian la personalidad. La variante es la misma especie: produce lo mismo y sirve para los pedidos de su especie.

| Catalizador | Lo conocés al descubrir | Color | Rasgo | Nombre | Personalidad |
|---|---|---|---|---|---|
| Rayo | eléctrico | amarillo | chispas | "Glumulo de Rayo" | la hace Peleadora |
| Hielo | agua | celeste | escarcha que cae | "Glumulo de Hielo" | la hace Miedosa |
| Slime | planta | verde ácido | goteo | "Glumulo de Slime" | la de sus padres |
| Lava | fuego | naranja | brasas | "Glumulo de Lava" | la de sus padres |
| Sombra | sombra | violeta | humo | "Glumulo de Sombra" | la hace Vaga |

- El catalizador **solo se gasta si la pareja reacciona**. Con una especie que ya tenés, la vista previa muestra la variante; la primera de cada una dice "¡Variante nueva!" y el cartel de la máquina también.
- **Mutadex:** la ficha de cada especie tiene una fila con los 5 catalizadores (de color los que ya conseguiste, en gris los que faltan, "1/5") y nombra las variantes.
- **Pedidos de variante:** "Un Glumulo de Hielo". Salen en 1 de cada 4 pedidos comunes, solo de variantes que ya conseguiste y que tenés o podés volver a hacer (tenés el catalizador). Son difíciles (pagan 2 fusiones). Si no tenés una, la tarjeta dice "Fusionalo con un catalizador de Hielo".
- **Catalizadores como premio** (lo que había quedado del pedido 2): los pedidos que no son fáciles y no traen pista a veces pagan un catalizador de los que conocés (1 de cada 4, `Config.Pedidos.ProbabilidadCatalizador`). La tarjeta lo muestra con su ícono ("+1 Hielo").
- Nunca hay dos pedidos de "Cualquier mutante" a la vez (en la prueba del bloque 2 quedaron dos sin poder cumplirse).
- La pestaña Catalizadores de la tienda explica que no se compran: se arman con residuos (o vienen de pedidos).

### Pruebas de 10 minutos (jugador automático, en Studio, tiempo real)
Al terminar cada bloque, el jugador automático jugó 10 minutos como jugador nuevo, con las funciones de verdad del servidor. Aprendió dos cosas nuevas: probar parejas que no reaccionan para juntar residuos y, con la ranura abierta, usar catalizadores (para pedidos de variante o para probar una variante nueva si le sobra ADN).

| | Antes (versión 9) | Bloque 1 | Bloque 2 | Bloque 3 |
|---|---|---|---|---|
| Especies | 11 | 11 | 11 | 12 |
| Pedidos entregados | 14 | 15 | 18 | 17 |
| ADN por segundo al minuto 9 | 12 | 12 | 16,3 | 16,3 |
| ADN máximo | 2.129 | 2.434 | 4.145 | 4.710 |
| ADN / próxima fusión, máximo | 3,7 | 4,2 | 3,8 | 3,9 |
| Segundos con más del triple | 10 | 10 | 10 | 10 |
| Veces sin saber qué hacer | 0 | 0 | 0 | 0 |
| Residuos | — | 44 | 40 | 38 |
| Catalizadores juntados | — | 8 (todos Slime) | 8 (Hielo, Slime y Sombra) | 7 (Hielo, Slime y Sombra) |

- **Bloque 1**: cada intento suma. Los ratos libres que antes eran espera ahora son residuos (44 en 10 minutos). Todos los catalizadores salieron de Slime porque el primero era al azar y después solo "conocía" ese: de ahí la decisión de conocerlos por elemento.
- **Bloque 2**: con personalidades el laboratorio rinde más (16,3 ADN por segundo contra 12), porque el corral se acomoda solo y las positivas suman. Entregó 3 pedidos más y el ADN llegó más alto, pero sin pasar el triple de la próxima fusión más que 10 segundos.
- **Bloque 3**: la ranura se abrió en el minuto 7 (11 especies). En los 3 minutos que quedaban no le alcanzó el ADN para una fusión con catalizador (cuestan unos 2.200). Entregó un pedido de personalidad. Las fusiones con catalizador se probaron a mano (capturas).
- **Simulador, 20 minutos** (10 partidas, tiempo simulado): 13,5 especies, 19 pedidos, 0,6 fusiones con catalizador por partida, 1 pedido de personalidad y ninguno de variante. Después del minuto 10 el ADN se junta (hasta 4 a 5 veces la próxima fusión). **Para el pedido 4 (balance):** que los catalizadores y las variantes aparezcan más en los primeros 20 minutos y que el ADN no se acumule.

Capturas en `capturas/pedido-3/`: residuo en el panel y en la máquina, corral con personalidades, herencia en el panel, cría Líder, catalizador en el panel, fusión con catalizador, Mutadex con variantes y sellos, el cartel de la ranura y pedidos que pagan un catalizador.

## Notas de la Parte 7: que la fusión se sienta increíble (versión 12)

Pedido 5 de `ORDEN-PEDIDOS.md`. No hay sistemas nuevos: solo cambia cómo se siente lo que ya existía. Todo es del lado del cliente.

### Tres niveles de fusión (`client/EfectosMaquina.luau`)
- **Nivel 1, especie que ya tenías** (~1 segundo): las cápsulas se llenan rápido, un temblor corto, destello y la cría ya está afuera con un cartel chico ("Ya la tenías · Glumulo · Generación 2 · Líder").
- **Nivel 2, especie o variante nueva** (la completa): cápsulas, temblor y humo, la silueta negra con "¿Qué será?" y la revelación.
- **Nivel 3, mutante o generación 3 nueva** (la más grande): lo mismo más la cámara que tiembla, **las luces de todo el laboratorio** cambiando de color (neón y luces del edificio, sin la máquina ni las criaturas), papelitos y una fanfarria.
- **"¡NUEVA ESPECIE!"**: el nombre aparece **letra por letra** con un tic que sube (`Carteles` con `LetraPorLetra`, `Config.Interfaz.PausaLetra`).
- **El contador de la Mutadex del HUD espera a la revelación** para subir, con un rebote más grande (antes subía al apretar "Fusionar" y adelantaba la sorpresa).
- **Botón "Saltear"** abajo a la derecha mientras se anima una especie que ya conocías: corta las esperas.

### Criaturas con vida (`shared/Animacion.luau`, `client/AnimarCriaturas.client.luau`)
- **Tocar una criatura** (mouse o dedo): salta alto, da una vuelta, "dice" dos notas (según su primera base; más grave si es de más generación) y muestra un cartelito con su nombre y su personalidad ("Miedosa: da -30 %, pero con una Líder en su corral da +50 %"). **Decisión:** las piezas de las criaturas no frenan rayos (así no molestan a la cámara), así que el toque se busca comparando posiciones en la pantalla.
- **En el corral, cada personalidad tiene su vida**: cuando están quietas **se miran entre sí**; la **Alegre** pega saltos grandes cada 2,5 a 5 segundos; la **Vaga** camina a la mitad y cada tanto **se duerme con una "Z"** que sube y se desvanece; la **Peleadora** va hasta una vecina y **la empuja** (la otra sale con un saltito); la **Miedosa** se queda pegada a otra; la **Curiosa** se acerca al jugador si está cerca del corral. Los números están en `Config.Animacion.Vida`.

### ADN y compras
- **El ADN vuela al contador**: el "+N" salta sobre cada criatura del corral y después viaja por la pantalla hasta el contador de ADN (como mucho 10 a la vez, `Config.Efectos`).
- **Destello al comprar una mejora en lo que mejoró**: Más corrales, en el corral nuevo (ya estaba); **Fusión rápida, en la máquina**; **Nutrientes, en cada corral abierto**, uno atrás del otro; las pistas, en el mostrador.

### Sonidos
Todos los nuevos están marcados con `-- SONIDO:` (fusión corta, fanfarria del nivel 3, cada letra del nombre, la voz de cada criatura y el destello). Usan el sample de `Sonidos.luau` cambiando el tono.

### Probado (2026-10-09, en Studio, como jugador)
- Glupona + Rámulo (ya conocida): a los 0,6 segundos ya estaba el Glumulo afuera con el cartel corto y el botón "Saltear".
- Rocote + Chisparo (gen 2 nueva): la completa, con "¡NUEVA ESPECIE! Roparo" letra por letra.
- Ratomi + Rocote (gen 3 nueva): papelitos, luces del laboratorio y cámara temblando, "¡NUEVA ESPECIE! Ratote".
- Tocar a Chisparo en el corral: salto, vuelta y su cartelito.
- **Rendimiento**: 16 criaturas con su vida, los números que vuelan y las partículas: **60 cuadros por segundo** en Studio (peor cuadro 18 ms). Consola sin errores.
- Capturas en `capturas/pedido-5/`.

## Notas de la Parte 8: razones para volver mañana (versión 13)

Pedido 6 de `ORDEN-PEDIDOS.md`. Todos los números están en `Config.luau` (`Regreso`, `Diario`, `Experimento`, `Misiones`, `Metas`). Nada se paga con Robux ni tiene contadores falsos.

### Las fechas las decide el servidor
- `server/Reloj.luau`: la hora es la del servidor en **UTC**; el día cambia a las 0:00 UTC (las 21:00 en Argentina). El reloj del jugador no se usa para nada que importe; el cliente solo muestra cuánto falta ("cambian en 2 h 39 min").
- Cada 15 segundos el servidor se fija si cambió el día: misiones nuevas, otro experimento y el premio diario disponible, con un aviso.

### 1. ADN mientras no estás
- Al guardar se anota la hora del servidor. Al volver, un cartel "**¡VOLVISTE!** +24.385 ADN · Tus criaturas trabajaron 3 h 0 min mientras no estabas".
- **Decisión de balance:** cuenta hasta **8 horas**, a **un cuarto** de lo que producen los corrales jugando, y como mucho **5 fusiones** de ADN. Si no, 8 horas afuera valían más que todo el juego activo (a 50 ADN por segundo son 1,4 millones) y el ADN dejaba de ser el límite.

### 2. Premio diario de 7 días
- Día 1: 1 fusión de ADN · día 2: 1,5 · día 3: un catalizador · día 4: 2 fusiones · día 5: dos catalizadores · día 6: 3 fusiones · **día 7: la especie especial Estrellín** y 2 fusiones. Los catalizadores son de los que conocés.
- Si cobrás todos los días, la racha sube; **si faltás un día, vuelve al día 1**; después del 7 vuelve a empezar.
- Se cobra con el botón "¡Cobrar el día N!" del menú Misiones, que **se abre solo al entrar** si hay premio para cobrar.
- **La especie especial (Estrellín)**: no está en la rueda ni entre las 50, no se fusiona y no se compra; la única forma de tenerla es el día 7. Está hecha con piezas de las bases (cabeza de Fotina, cuerpo de Glupona, patas de Zoplito, cola de Brinoza), toda dorada y con aura. En el corral rinde como una de generación 3 y tiene prioridad para entrar. Está en la pestaña **Extras** de la Mutadex (silueta hasta que la tenés).

### 3. Experimento del día
- `shared/Experimento.luau`: una especie de generación 2 o 3 sale del número de día (mezclado), así es **la misma para todos los jugadores** y se arma sola.
- En el menú Misiones, pestaña Experimento: su silueta y **tres pistas** (el elemento, un rasgo de su forma y algo de una de sus bases).
- Quien la fusiona ese día gana **3 fusiones de ADN y un catalizador** ("¡EXPERIMENTO DEL DÍA!"). Si ya la conocías, se ve con colores y vale hacer otra.

### 4. Misiones del día
- **Tres por día**, siempre las mismas para un jugador ese día. Tipos: descubrí 1 o 2 especies nuevas, hacé 4 a 8 fusiones, entregá 2 a 4 pedidos, hacé 3 a 5 residuos, usá un catalizador de (uno que conocés, con la ranura abierta) y conseguí una criatura (una personalidad que puede salir de juntar las que tenés).
- Premio chico por cada una (media fusión de ADN, con aviso "¡Misión cumplida!") y uno grande por las tres (2 fusiones y un catalizador, con cartel).

### 5. Metas largas con trofeos
- Nueve metas siempre a la vista (pestaña Metas): las 10 bases, las 30 de generación 2, las 10 de generación 3, 100 fusiones, 100 pedidos, las 5 variantes de una especie, las 8 personalidades, 10 especies mutantes y la especie especial.
- Cada una paga 5 fusiones (las de generación ya pagan su festejo) y deja un **trofeo** en el estante "Trofeos" del laboratorio: una copa del color de la meta en su lugar (Hueco1 a Hueco9), con su nombre de cerca.

### Probado (2026-10-09, en Studio, como jugador)
- **Siete días simulados** (`ServerStorage.Prueba.PasarDias`): el menú se abrió solo, se cobró cada día con el botón y en el día 7 llegó "¡ESPECIE ESPECIAL! Estrellín", la meta "Especial" se cumplió y apareció su trofeo en el estante. Con un día salteado la racha volvió al día 1. Las misiones cambiaron cada día.
- **Regreso** (`Prueba.Volver`, 3 horas afuera): cartel con +24.385 ADN (el tope de 5 fusiones).
- **Experimento**: fusionando Dunaqui + Fotina con un catalizador de Lava salió Dutina (la de ese día): "¡EXPERIMENTO DEL DÍA!" y, de paso, "¡Misión cumplida! Usá un catalizador de Lava".
- Consola sin errores. Capturas en `capturas/pedido-6/`.
- Herramientas de prueba nuevas: `PasarDias`, `Volver`, `Experimento`.

## Notas de la Parte 9: jugar con otros (versión 14)

Pedido 7 de `ORDEN-PEDIDOS.md`. Una sesión vieja lo había dejado empezado y sin probar (rama `claude/mutant-lab-ui-consolidate-05bd28`); se revisó, se juntó en master y se probó con dos jugadores (Studio, "Servidor y clientes").

- **Plaza**: los jugadores aparecen en la plaza y desde ahí caminan a su laboratorio; se ven todos.
- **Paseos** (`server/Paseos.luau`): en la ficha de la Mutadex de una especie que tenés, botón "Sacar a pasear". Una criatura tuya de esa especie (la más vistosa: con variante o mutante) te sigue por todo el mapa con un cartel "Glumulo · Gen 2 / de Juani" que ven todos. Una por jugador. **Decisión**: la criatura no sale del corral (es una copia que te acompaña), así no deja de producir. Si entregás la última de esa especie, vuelve sola.
- **Visitas**: en un laboratorio ajeno se puede entrar y mirar (criaturas, trofeos, tablero), pero los botones de su máquina, tienda y tablero están apagados para el visitante. Igual, el servidor nunca toca los datos de otro: cada remoto actúa solo sobre los del que lo manda.
- **Ficha ajena** (`client/FichaAjena.client.luau`): a menos de 10 studs de una criatura de otro jugador (de paseo, en su corral o en la máquina de equipo) aparece abajo su ficha: nombre, generación, elemento, personalidad y de quién es. Si no la descubriste, la ves completa pero dice "¡No la descubriste! La receta es un secreto." y **no se marca en tu Mutadex** (es solo pantalla, no le avisa nada al servidor).
- **Fusión en equipo** (`server/Equipo.luau`, `client/MaquinaEquipo.client.luau`): la máquina grande de la plaza tiene dos pedestales. Cada jugador aprieta E en uno, elige una criatura suya (va una copia: nadie pierde la suya) y después los dos aprietan E en el cartel. Cada uno paga su fusión, los dos reciben la cría y los dos la descubren. Además de lo que sale en una máquina común, **dos bases a 4 lugares en la rueda** (que en la común no reaccionan) dan una de las **10 especies de equipo**: Gluparo, Ranaqui, Suplito, Ronoza, Chistina, Durulo, Zopona, Brimulo, Fotomi y Necote. Van en la pestaña **Extras** de la Mutadex (no cuentan en las 50). Si un jugador se aleja más de 40 studs, su criatura vuelve.
- **Tablas de posiciones**: en el tablero de la plaza y en la lista de jugadores de Roblox. "En este servidor" y "En todo el juego" (OrderedDataStore, se actualiza cada 2 minutos): más especies descubiertas (las 50 y las especiales) y más variantes. Los jugadores de prueba de Studio no van a la global.
- **Me gusta**: cartel con corazón en la entrada de cada laboratorio. Un visitante aprieta E y suma uno (uno por día a cada laboratorio; el dueño no puede darse a sí mismo). El contador se guarda.
- **Sin intercambio ni regalos**: no existe ninguna forma de pasar criaturas o ADN entre jugadores. Nadie escribe texto propio (los nombres salen de sílabas fijas), así que no hace falta el filtro de texto.
- **Seguridad**: todo lo valida el servidor (que la criatura sea tuya, que estés cerca, que el lado sea tuyo, que te alcance el ADN) y los remotos nuevos tienen freno contra el spam (`server/Frecuencia.luau`, 0,5 s).
- **Probado** (2026-10-11, dos jugadores): Player1 sacó a pasear un Glumulo y Player2 lo vio seguirlo, con su ficha ("¡No la descubriste!"); Player2 entró al laboratorio de Player1 (solo el "me gusta" encendido) y le dio me gusta (el segundo del día dice "Ya le diste me gusta hoy"); dos fusiones en equipo (Dunaqui + Rámulo = Ranaqui y Sutomi + Zoplito = Suplito, "¡FUSIÓN EN EQUIPO! … especie de equipo: solo sale así"), cada uno con su cría y su ADN cobrado; la Mutadex de Player2 mostró Extras 3/11. Consola sin errores en el servidor y los dos clientes. Las especies de equipo tienen su chequeo en `Pruebas.server.luau`.

## La idea en una línea

Un laboratorio donde combinás criaturas para descubrir especies nuevas y llenar las siluetas de tu Mutadex.

## Loop

1. Tenés criaturas base en tu laboratorio.
2. Ponés dos en la máquina de fusión.
3. Animación de suspenso (unos 4 s): las cápsulas se llenan del color de cada padre, la máquina tiembla, destello.
4. Aparece la especie nueva y se registra en la Mutadex (su silueta se llena).
5. La criatura nueva se suma al laboratorio y genera ADN por segundo.
6. Con ADN comprás más criaturas base y mejoras.
7. Volvés a combinar.

---

## 1. Las 10 especies base

Cada criatura se arma con 6 piezas: **cabeza, cuerpo, patas, cola o alas, color y rasgo especial**. Todas las piezas son formas simples (esferas, cilindros, cuñas) para que se lean bien en celular.
El rasgo especial es un efecto visual o una animación de reposo. En el prototipo **no** cambia nada del juego.

Las 10 están ordenadas en una **rueda** (el número es su lugar en la rueda; después del 10 vuelve el 1). La rueda es la regla de todo el juego y se ve en la Mutadex.

| # | Nombre (sílabas) | Tema | Cabeza | Cuerpo | Patas | Cola o alas | Color | Rasgo especial |
|---|---|---|---|---|---|---|---|---|
| 1 | **Glupona** (Glu-po-na) | Agua | Gota con dos ojos grandes | Bola gelatinosa translúcida | 4 patitas de ventosa | Cola de renacuajo | Celeste | Suelta burbujas al moverse |
| 2 | **Rámulo** (Ra-mu-lo) | Musgo | Óvalo con dos brotes de hojas | Tronco corto cubierto de musgo | 6 raíces cortas | Cola de enredadera enrollada | Verde musgo | Le brotan florcitas cuando está quieto |
| 3 | **Sutomi** (Su-to-mi) | Hongo | Sombrero de hongo con lunares | Tallo petiso y gordito | 2 patas gruesas | Cola corta en bolita de esporas | Magenta | Larga esporas que brillan al saltar |
| 4 | **Rocote** (Ro-co-te) | Roca | Bloque cuadrado con cejas de piedra | Caparazón de lajas | 4 patas cortas tipo columna | Cola de maza (bola de piedra) | Gris pizarra | Se hace bolita y rueda un poco |
| 5 | **Chisparo** (Chis-pa-ro) | Fuego | Triangular con cuernitos de brasa | Torso de lagarto con escamas | 4 patas de lagartija | Cola con una llama en la punta | Rojo | Deja chispas al caminar |
| 6 | **Dunaqui** (Du-na-qui) | Arena | Hocico largo y orejas enormes | Cuerpo con joroba | Patas anchas en forma de pala | Cola en espiral | Ocre | Se entierra y vuelve a asomar |
| 7 | **Zoplito** (Zo-pli-to) | Viento | Pico redondo con penacho | Cuerpo de plumas, liviano | 2 patas finas de ave | **Alas** grandes y redondas | Lila | Flota un poquito sobre el piso |
| 8 | **Brinoza** (Bri-no-za) | Hielo | Redonda con cuernos de carámbano | Pelaje esponjoso | Patas peludas con garritas | Cola de cristales de hielo | Blanco hielo | Deja escarcha donde pisa |
| 9 | **Fotina** (Fo-ti-na) | Luz | Alargada con antenas de bombita | Cuerpo de insecto en segmentos | 6 patitas de insecto | **Alas** transparentes | Amarillo | Brilla con luz propia |
| 10 | **Nerulo** (Ne-ru-lo) | Noche | Tres ojitos y orejas puntiagudas | Cuerpo largo y flexible | 4 patas largas y sigilosas | **Alas** de membrana | Azul noche | Se vuelve semitransparente a ratos |

Rueda: 1 Agua → 2 Musgo → 3 Hongo → 4 Roca → 5 Fuego → 6 Arena → 7 Viento → 8 Hielo → 9 Luz → 10 Noche → (vuelve a 1).

---

## 2. La regla de fusión (fija)

### Qué se puede combinar

- **Base + base**: reaccionan si están a **1, 2 o 3 lugares** en la rueda (por el camino más corto). Dan una especie de **generación 2**. Hay 30 parejas así.
- **Generación 2 + base**: reaccionan si las **tres bases** involucradas quedan **seguidas** en la rueda (por ejemplo 1-2-3 o 9-10-1). Dan una especie de **generación 3**. Hay 10 tríos así.
- Todo lo demás (bases a 4 o 5 lugares, gen 2 + gen 2, cualquier cosa con gen 3, una criatura consigo misma) **no reacciona**: la máquina dice "No reaccionan", **no cobra ADN** y tacha la pareja en el cuaderno del laboratorio para no repetirla.

### Por qué siempre da lo mismo

La especie se identifica por el **conjunto de bases** que la forman, no por el orden ni por el jugador.
- Glupona + Rámulo = Rámulo + Glupona = la misma especie.
- Una gen 3 se puede conseguir por tres caminos (por ejemplo para el trío 1-2-3: Glumulo + Sutomi, Ratomi + Glupona o Glutomi + Rámulo) y siempre sale la misma.
- El servidor calcula el resultado con una tabla fija. Lo único al azar es la versión mutante (punto 5), que es solo estética.

### Qué pieza hereda de quién

**Generación 2 (dos bases).** El "primero" es el que está antes en la rueda yendo en sentido de las agujas del reloj por el camino corto (en 9 + 1, el primero es 9).

| Pieza | La pone |
|---|---|
| Cabeza | el primero |
| Patas | el primero |
| Color principal | el primero |
| Cuerpo | el segundo |
| Cola o alas | el segundo |
| Rasgo especial | el segundo |
| Manchas | color del segundo |

**Generación 3 (tres bases seguidas: primero, medio, último).**

| Pieza | La pone |
|---|---|
| Cabeza | el primero |
| Cuerpo | el del medio |
| Rasgo especial | el del medio |
| Patas | el último |
| Cola o alas | el último |
| Color principal | el del medio |
| Manchas | color del primero |
| Brillo en la cola o alas | color del último |

Además, toda gen 3 tiene un **aura de partículas** alrededor, para que se note de lejos que es de la generación más alta.

Truco para el jugador: **la primera sílaba del nombre te dice de quién es la cabeza.**

---

## 3. Cómo se arma el nombre

Cada base tiene 3 sílabas (S1-S2-S3).

- **Gen 2** = S1 del primero + S2 y S3 del segundo. Glu(pona) + (Rá)mulo → **Glumulo**.
- **Gen 3** = S1 del primero + S2 del medio + S3 del último. Glu(pona) + (Ra)mu(lo) + (Suto)mi → **Glumumi**.

Revisé las 50: no se repite ningún nombre y ninguno es una palabra común (por eso Setomi pasó a Sutomi, Brinoca a Brinoza y Nebrilo a Nerulo).

### 10 ejemplos de fusión

| # | Fusión | Nombre | Gen | Cómo se ve |
|---|---|---|---|---|
| 1 | Glupona + Rámulo | **Glumulo** | 2 | Cabeza de gota sobre un tronco con musgo, patitas de ventosa, cola de enredadera. Celeste con manchas verdes. Le brotan flores. |
| 2 | Rocote + Chisparo | **Roparo** | 2 | Cabeza de bloque de piedra, torso de lagarto, patas de columna, cola con llama. Gris con manchas rojas. Deja chispas. |
| 3 | Chisparo + Zoplito | **Chisplito** | 2 | Cabeza con cuernitos de brasa, cuerpo de plumas, patas de lagartija, alas redondas. Rojo con manchas lila. Flota. |
| 4 | Sutomi + Dunaqui | **Sunaqui** | 2 | Sombrero de hongo, cuerpo con joroba, 2 patas gruesas, cola en espiral. Magenta con manchas ocre. Se entierra. |
| 5 | Dunaqui + Fotina | **Dutina** | 2 | Hocico largo y orejas enormes, cuerpo de insecto, patas de pala, alas transparentes. Ocre con manchas amarillas. Brilla. |
| 6 | Brinoza + Glupona | **Bripona** | 2 | Cuernos de carámbano, cuerpo gelatinoso, patas peludas, cola de renacuajo. Blanco con manchas celestes. Suelta burbujas. |
| 7 | Zoplito + Nerulo | **Zorulo** | 2 | Pico con penacho, cuerpo largo y flexible, patas de ave, alas de membrana. Lila con manchas azul noche. Se vuelve transparente. |
| 8 | Nerulo + Sutomi | **Netomi** | 2 | Tres ojitos, tallo petiso, patas largas, cola de esporas. Azul noche con manchas magenta. Larga esporas. |
| 9 | Glumulo + Sutomi (trío 1-2-3) | **Glumumi** | 3 | Cabeza de gota, tronco con musgo, 2 patas gruesas, cola de esporas. Verde con manchas celestes y brillo magenta. Florcitas + aura. |
| 10 | Zonoza + Fotina (trío 7-8-9) | **Zonona** | 3 | Pico con penacho, pelaje esponjoso, 6 patitas de insecto, alas transparentes. Blanco con manchas lila y brillo amarillo. Escarcha + aura. |

---

## 4. Las tres generaciones (50 especies)

| Generación | Cómo se consigue | Cantidad |
|---|---|---|
| 1 · Base | Se compran con ADN | 10 |
| 2 | Base + base (a 1, 2 o 3 lugares en la rueda) | 30 |
| 3 | Gen 2 + base (tres bases seguidas en la rueda) | 10 |
| **Total** | | **50** |

Lista completa:
- **Gen 2**: Glumulo, Glutomi, Glucote, Ratomi, Racote, Raparo, Sucote, Suparo, Sunaqui, Roparo, Ronaqui, Roplito, Chisnaqui, Chisplito, Chisnoza, Duplito, Dunoza, Dutina, Zonoza, Zotina, Zorulo, Britina, Brirulo, Bripona, Forulo, Fopona, Fomulo, Nepona, Nemulo, Netomi.
- **Gen 3**: Glumumi (1-2-3), Ratote (2-3-4), Sucoro (3-4-5), Ropaqui (4-5-6), Chisnato (5-6-7), Dupliza (6-7-8), Zonona (7-8-9), Britilo (8-9-10), Foruna (9-10-1), Nepolo (10-1-2).

### La Mutadex (las siluetas)

- 50 casillas ordenadas alrededor de la rueda. Las no descubiertas muestran **la silueta negra** de la criatura.
- Como la forma sale de las piezas, la silueta es una **pista**: si ves una cabeza de sombrero de hongo, sabés que el primero es Sutomi. Es un pequeño puzzle de deducción.
- Cada casilla dice su generación (1, 2 o 3 puntitos).
- Mejora **Escáner** (ver economía): revela uno de los padres de una silueta.

---

## 5. Versión mutante

- En **cada fusión que reacciona** hay **1 en 40 (2,5 %)** de que salga la versión mutante. También vale volver a fusionar una pareja que ya conocés: es la forma de buscar mutantes.
- El resultado mutante es **la misma especie**: mismas piezas, mismo nombre (con una ⭐ adelante).
- Solo cambia la estética: colores tornasolados (cambian de tono lento), partículas de estrellitas y borde dorado en la Mutadex.
- **No** genera más ADN, **no** cuenta para las 50 y **no** se puede comprar ni subir su probabilidad con Robux.
- Si ya tenés la especie y te sale mutante, tu criatura pasa a ser mutante (podés volver a la versión normal con un botón).

---

## 6. Economía

Moneda única: **ADN**. Todos los números van a `Config.luau`. **Los de abajo son los del plan original: los actuales están en "Notas de la Parte 5".**

**Arranque**: 3 bases seguidas en la rueda (Glupona, Rámulo, Sutomi) y 50 ADN. Así la primera fusión se puede hacer en el segundo 1 y hay una gen 3 al alcance en el primer minuto.

**Fusionar**
- Consume ADN y **no destruye a los padres**.
- Costo gen 2: 20 ADN, que sube un 10 % por cada especie que ya tenés.
- Costo gen 3: 5 veces el costo de gen 2.
- Volver a fusionar una pareja conocida cuesta lo mismo (solo sirve para buscar el mutante).
- Si no reaccionan: gratis.

**Generación de ADN** (cada especie que tenés es una criatura en el laboratorio)

| Generación | ADN por segundo |
|---|---|
| Base | 1 |
| Gen 2 | 2 |
| Gen 3 | 6 |

**Comprar bases**: elegís cuál (sin azar, sin huevos sorpresa). El precio depende de cuántas tenés: la 4.ª cuesta 100, después 300, 800, 2.000, 5.000, 12.000 y 30.000. Elegir cuál comprar es la decisión estratégica: conviene la vecina de las que ya tenés en la rueda.

**Mejoras**
- **Nutrientes**: +25 % de ADN por nivel, 5 niveles (200 / 800 / 3.000 / 10.000 / 30.000).
- **Escáner**: revela un padre de una silueta. Cuesta 100 × (escaneos usados + 1).

**Ritmo esperado** (simulación con juego perfecto): 15 especies en el minuto 1, 33 en el minuto 5, 40 en el minuto 8 y las 50 en unos 17 minutos. Un jugador real tarda más (prueba combinaciones, mira, explora), así que a los 10 minutos debería tener unas **25 a 35 especies y quedarle siluetas difíciles a la vista**. Eso es justo lo que queremos medir.

---

## 7. Qué queda afuera del prototipo

- Intercambio entre jugadores.
- Bosses.
- Eventos.
- Temporadas.
- Criaturas gigantes.
- Rankings.
- También afuera (decisión mía, lo más simple): gen 2 + gen 2, gen 4 en adelante, que los rasgos especiales tengan efecto en el juego, y criaturas repetidas (tenés una de cada especie).

---

## 8. La pregunta que tiene que responder

> **Después de 10 minutos, ¿tengo ganas de probar una combinación más para llenar una silueta?**

Cómo lo vamos a mirar en el playtest:
- A los 10 minutos, ¿quedan siluetas que sé cómo buscar (por la forma o el escáner) pero me falta ADN o una base? Eso es "una más".
- ¿La animación de suspenso sigue dando ganas de mirar, o ya la quiero saltear?
- ¿Las fusiones que no reaccionan frustran o ayudan a entender la rueda?

---

## 9. Plan de construcción

- [x] **Parte 1 - Criaturas por piezas** (hecha el 2026-10-07): carpeta del juego, módulo de especies (tabla de las 10 bases y regla de herencia), armado de una criatura a partir de sus piezas, las 50 generadas y revisadas en una captura.
- [x] **Parte 2 - Máquina de fusión** (hecha el 2026-10-07): dos cápsulas, validación en el servidor (reacciona / no reacciona), animación de suspenso, aparición de la especie y tirada del mutante.
- [x] **Parte 3 - Mutadex** (hecha el 2026-10-07): UI con las 50 siluetas alrededor de la rueda, generación, casilla mutante, cuaderno de parejas tachadas y escáner.
- [x] **Parte 4 - Laboratorio y economía** (hecha el 2026-10-08): el mapa del laboratorio, criaturas paseando, ADN por segundo, terminal para comprar bases y mejoras.
- [x] **Parte 5 - Guardado, balance y pulido** (hecha el 2026-10-08): DataStore, balance medido con un playtest de 10 minutos, guía de los primeros segundos, efectos (número de ADN, rebote, destello al comprar), prueba con 20 criaturas y consola limpia. Ver "Notas de la Parte 5". **Revisada el 2026-10-09** con pedidos, residuos, personalidades y catalizadores: guardado de todo, balance medido hasta completar la Mutadex, guía y rendimiento (versión 11).
- [ ] **Parte 6 - Compras con Robux**: solo cosas que no son azar. Ideas: pase "Doble ADN", pase "Segunda máquina" (dos fusiones a la vez), colores del laboratorio. Nada de cajas sorpresa ni subir la chance de mutante. Es punto de control: los pases los crea y les pone precio el usuario.
- [x] **Parte 7 - Que la fusión se sienta increíble** (hecha el 2026-10-09): tres niveles de espectáculo, nombre letra por letra, saltear, criaturas que reaccionan al tocarlas y viven según su personalidad, ADN que vuela al contador y destellos de mejoras. Ver "Notas de la Parte 7".
- [x] **Parte 8 - Razones para volver mañana** (hecha el 2026-10-09): ADN sin conexión (hasta 8 horas), premio diario de 7 días (el 7, la especie especial), experimento del día, misiones diarias y metas con trofeos. Ver "Notas de la Parte 8".
- [x] **Parte 9 - Jugar con otros** (hecha el 2026-10-11): plaza, paseos, visitas, ficha ajena, fusión en equipo con 10 especies propias, tablas de posiciones y "me gusta". Ver "Notas de la Parte 9".

Puntos de control: esta ficha → estilo visual → prototipo jugable (Partes 1 a 5) → Parte 6.

---

## Propuestas de estilo visual (para elegir antes de construir)

> Historial. Se eligió A en la versión 2 y la versión 6 la reemplazó por la guía visual del usuario (ver "Guía de estilo").

### A — Laboratorio caramelo
- **Paleta**: crema #F4EFE6 (piso), menta #7FD8BE (máquinas), rosa chicle #FF8FB1 (detalles), amarillo #FFD25A (luces y botones), violeta oscuro #3B2A5C (paredes y contornos).
- **Materiales**: SmoothPlastic en todo, Glass para las cápsulas.
- **Iluminación**: de día, luz blanda y pareja (ClockTime 13, Brightness alto), Atmosphere con poca bruma, sombras suaves.
- **Formas**: todo redondeado: esferas, cilindros, bordes gordos. La máquina de fusión parece una batidora gigante de juguete.
- **Lectura en celular**: las criaturas se paran sobre pedestales violeta oscuro para que resalten (sobre todo Brinoza, que es blanca).

### B — Acuario bioluminiscente
- **Paleta**: azul abismo #0A1A2F (fondo), verde azulado #12424A (piso), cian #22E1FF (tubos y líquido), verde ácido #9BFF3C (ADN y botones), coral #FF6B6B (alertas y la máquina).
- **Materiales**: Slate en el piso, Glass para tanques y cápsulas, Neon en los tubos de ADN.
- **Iluminación**: laboratorio bajo el mar, ambiente oscuro azulado, Bloom suave, cada criatura con una lucecita propia. Burbujas subiendo por los tanques.
- **Formas**: tanques cilíndricos, tubos curvos, ventanales redondos con "agua" afuera.
- **Lectura en celular**: las criaturas brillan sobre el fondo oscuro; ojo con que no se parezca a Pisada Sonora (allá es noche con neón de ciudad, acá es agua y tubos).

### C — Taller de inventor
- **Paleta**: madera nogal #6B4226 (piso), cobre #C97B3A (máquinas), verde oliva #5E8C61 (paredes), papel crema #EFE3C8 (UI y carteles), carbón #2B2B2B (contornos y sombras).
- **Materiales**: WoodPlanks en el piso, Metal en la máquina y los tubos, Fabric en cortinas.
- **Iluminación**: atardecer cálido entrando por ventanales (ClockTime 17,5), lámparas colgantes amarillas.
- **Formas**: cuadradas y robustas, con remaches y engranajes grandes. La máquina es una caldera con dos campanas de vidrio. La Mutadex es un libro gordo sobre un atril.
- **Lectura en celular**: fondo cálido y medio oscuro, criaturas de colores saturados adelante.

Mi recomendación: **A**, porque es la que mejor muestra los 10 colores de las criaturas y la más apta para todo público. Las tres se van a construir como muestra chica en Studio (unas baldosas, la máquina y el cielo) cuando apruebes la ficha.
