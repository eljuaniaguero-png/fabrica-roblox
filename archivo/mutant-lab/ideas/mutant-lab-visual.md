# Mutant Lab — guía visual completa

Juego: Mutant Lab (carpeta mutant-lab/). Esta guía define todo el aspecto visual del juego y reemplaza la elección de 3 estilos. Leela entera antes de construir. Copiala como sección "Guía de estilo" en ideas/mutant-lab.md y respetala en todas las partes.

## 1. Dirección de arte

Concepto: "laboratorio de caricatura de noche". Un laboratorio oscuro y acogedor, lleno de tubos con líquidos que brillan, donde viven criaturas redondas y tiernas. Lo oscuro es el fondo; lo que brilla es lo importante: el ADN, la máquina, las criaturas.

Tres reglas que mandan sobre todo lo demás:
1. Lo jugable brilla, lo decorativo no. Si algo se puede tocar o juntar, tiene un color de acento o luz. La decoración usa colores apagados.
2. Formas redondas y gruesas. Nada filoso ni realista. Bordes redondeados, proporciones exageradas.
3. Se entiende en una pantalla de celular. Si algo no se lee en un teléfono, se agranda o se saca.

## 2. Paleta

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

## 3. Iluminación y ambiente

- Hora fija de noche, con una luna grande y visible desde el laboratorio.
- Luz ambiente baja y azulada. La luz fuerte sale de los objetos: tubos, máquina, pantallas.
- Atmosphere con un poco de niebla violeta a lo lejos, para que el fondo se pierda y el laboratorio resalte.
- Bloom suave, para que las partes de material Neon brillen. Sin exagerar: el texto tiene que seguir leyéndose.
- ColorCorrection con un poco más de saturación y contraste.
- Para que algo brille, usá primero material Neon. Las luces reales (PointLight, SurfaceLight) solo en la máquina de fusión y en pocos lugares clave: como máximo 12 en todo el laboratorio.

## 4. Mapa

### Plaza central
- Una plaza circular en el centro del mundo, rodeada por los laboratorios de los jugadores, uno por jugador, como porciones alrededor.
- En el medio, la máquina de fusión en equipo (Parte 9): más grande que las demás, con un tubo de luz que sube al cielo.
- Tablero gigante con el experimento del día (Parte 8) y la tabla de posiciones.
- Faroles verdes, bancos, carteles de neón con flechas hacia cada laboratorio.

### Laboratorio de cada jugador
Una sala redonda, de unos 80 studs de diámetro, abierta hacia la plaza por un arco con el nombre del jugador en neón.
- Centro: la máquina de fusión. Una cápsula de vidrio alta con dos ranuras de entrada a los lados (una por padre) y una tercera arriba para el catalizador. Tubos que conectan las ranuras con la cápsula. Cuando funciona, el líquido de los tubos se mueve hacia la cápsula.
- Alrededor de la máquina: 4 corrales al principio, hasta 8 con mejoras. Cada corral es una plataforma hexagonal con cúpula de vidrio, borde de neón verde y un cartel con la cantidad de ADN por segundo. Los corrales bloqueados se ven con la cúpula opaca y un candado.
- Pared del fondo: el Mutadex como pantalla gigante, que muestra la cantidad descubierta y la última especie nueva.
- Un costado: mostrador de la tienda con un robot vendedor simpático.
- Otro costado: estante de trofeos (Parte 8), que se va llenando.
- Decoración que llena los huecos: tubos que suben por las paredes con burbujas, frascos de colores en estantes, cables gruesos por el piso, pantallas con gráficos simples, franjas amarillas y negras en el borde de las plataformas, carteles de "¡PELIGRO: TIERNO!".
- Sin espacios vacíos: desde cualquier punto de la sala tiene que verse algo interesante a menos de 15 studs.

### Reglas del mapa
- Generá el laboratorio por código desde un molde, así cada jugador recibe uno igual y se puede cambiar el diseño en un solo lugar.
- Materiales: SmoothPlastic para casi todo, Metal para máquinas, Glass para cúpulas y cápsulas, Neon para lo que brilla. Nada de texturas realistas.
- Cámara: el jugador tiene que poder ver la máquina y al menos 3 corrales a la vez desde el centro.

## 5. Criaturas

### Proporciones
- Estilo chibi: la cabeza ocupa la mitad de la altura total.
- Altura de 3 a 5 studs según el tamaño (chico, mediano, grande).
- Patas cortas y gruesas, cuerpo redondo.
- Todas las partes con formas redondeadas: esferas, cilindros y bloques con esquinas suaves.

### Ojos (lo más importante)
- Todas las criaturas tienen ojos grandes: dos esferas blancas con pupila negra y un punto blanco de brillo.
- Los ojos ocupan cerca de un tercio de la cara.
- La personalidad cambia los ojos: Alegre, ojos arqueados de felicidad; Vaga, párpados a media altura; Peleadora, cejas en ángulo; Miedosa, pupilas chiquitas; Curiosa, un ojo más grande que el otro.

### Color y materiales
- Dos tonos por criatura: color principal en el cuerpo y color de detalle en panza, orejas o patas.
- Una pieza de material Neon con el color de su elemento: una antena, una cola, una mancha en la espalda o los cuernos.
- SmoothPlastic en todo lo demás.

### Generación, mutante y tamaño
- Anillo de luz bajo los pies con el color de su generación.
- Mutante: el color principal cambia a una versión brillante, la pieza de elemento pasa a ser más grande, y tiene partículas de brillo dorado alrededor.
- Las de generación 3 tienen una pieza extra: corona, aura o un segundo par de alas.

### Animación
- Movimiento de rebote con estirar y aplastar: al caer se aplastan un poco, al saltar se estiran.
- Cada personalidad se mueve distinto: la Alegre salta seguido, la Vaga camina lento y se duerme, la Peleadora empuja a las vecinas, la Miedosa se esconde detrás de otras, la Curiosa se acerca al jugador.
- Al tocarla: salta, hace su sonido y muestra un cartelito con nombre, generación, elemento y personalidad.

### Ícono de personalidad
- Arriba de la cabeza, chico y semitransparente, solo visible a menos de 20 studs.
- Ícono simple dibujado con formas o texto: corazón para Alegre, "Zzz" para Vaga, rayo para Peleadora, gota para Miedosa, signo de pregunta para Curiosa, estrella para Líder, martillo para Trabajadora, cubierto para Glotona.
- Borde verde para personalidades positivas, borde magenta para negativas.

### Reglas
- Ninguna criatura se parece a personajes, mascotas o memes existentes.
- Máximo 12 partes por criatura.
- Si al combinar piezas algo queda roto o tapado (ojos dentro del cuerpo, patas flotando), el generador lo corrige con reglas de posición, no a mano.

## 6. Interfaz (HUD y menús)

### Estilo general
- Look de caricatura: tarjetas con esquinas redondeadas (UICorner de 12), contorno grueso casi negro (UIStroke de 3) y fondo azul petróleo semitransparente.
- Botones gruesos con una franja más oscura abajo que simula profundidad. Al apretarlos se hunden un poco.
- Tipografía: Fredoka One para títulos, números y botones; Builder Sans o Gotham para textos chicos. Todo texto blanco con contorno oscuro.
- Íconos simples, de un color, sin degradados.
- Todo con tamaños relativos a la pantalla. Botones de al menos 44 píxeles en celular. Respetá la zona segura de la pantalla.

### Distribución en pantalla
| Lugar | Qué va |
|---|---|
| Arriba a la izquierda | Contador de ADN: pastilla con un ícono de hélice verde y el número grande |
| Arriba al centro | Progreso del Mutadex: barra con "12 / 50" |
| Arriba a la derecha | Botones redondos: Mutadex, Misiones, Tienda y Ajustes |
| Lado derecho | Notificaciones que entran deslizándose y se van solas |
| Abajo al centro | Acción del momento (por ejemplo "Fusionar" al estar cerca de la máquina) |
| Centro | Libre siempre, salvo en la revelación de una especie nueva |

### Menú de fusión
- Se abre al acercarse a la máquina.
- Dos casilleros grandes para los padres con un "+" en el medio, y un casillero más chico arriba para el catalizador (con candado hasta desbloquearlo).
- Abajo, la vista previa: si la combinación ya se conoce, muestra el resultado; si no, una silueta con "?".
- Costo en ADN a la vista. Botón grande verde ácido "¡FUSIONAR!". Si no alcanza el ADN, el botón se ve gris y dice cuánto falta.
- Lista de criaturas del jugador abajo, en tarjetas con su color de generación, filtrables por elemento.

### Mutadex
- Grilla de tarjetas, 4 por fila en computadora y 3 en celular.
- Especie descubierta: la criatura de cuerpo entero, nombre, elemento y borde con el color de su generación.
- No descubierta: silueta negra con un "?" grande y el botón de pista.
- Pestañas por generación, y una pestaña "Extras" para las especies exclusivas.
- Al abrir una especie: vista grande que gira, casilleros de variantes por catalizador y sellos de personalidades conseguidas.

### Tienda
- Pestañas: Especies, Mejoras, Catalizadores y Premium.
- Cada artículo en una tarjeta con su ilustración, nombre, efecto en una línea y precio.
- Lo que no alcanza se ve en gris con el precio. Lo que es Premium tiene borde dorado.

### Carteles grandes
- Especie nueva, nivel completado y premios: cartel en el centro con el título en Fredoka One, entrada con rebote y salida automática a los 3 segundos o al tocar.
- Nunca más de un cartel grande a la vez: si hay varios, se encolan.

## 7. Efectos visuales

- Fusión (tres niveles, según la Parte 7): conocida, corta; nueva, completa con silueta y revelación; mutante o generación 3, la más grande, con la cámara temblando un poco y luces de todo el laboratorio.
- Partículas de ADN: pequeñas hélices verdes que salen de las criaturas y vuelan hacia el contador.
- Número que salta y se desvanece cada vez que se suma ADN.
- Destello al comprar o mejorar algo, sobre el objeto que cambió.
- Burbujas constantes en los tubos y la cápsula.
- Todos los efectos del lado del cliente. Con 20 criaturas en pantalla, el juego tiene que seguir fluido en celular.

## 8. Sonido (puntos a marcar)

Marcá con -- SONIDO: cada uno de estos lugares, aunque por ahora no tengan audio: burbujas del laboratorio, máquina arrancando, suspenso de la fusión, revelación normal, revelación de especie nueva, revelación mutante, sonido propio de cada especie, juntar ADN, comprar, abrir menú, cerrar menú, botón apretado, misión completada, música de fondo del laboratorio.

## 9. Cómo aplicarla

1. Antes de construir todo, armá una sala de muestra: un corral con 3 criaturas (una común, una generación 2 y una mutante), la máquina de fusión y el HUD con valores de ejemplo. Sacá capturas desde lejos, de cerca y del HUD en tamaño celular. Esperá el OK.
2. Con el OK, aplicá la guía al laboratorio completo, a todas las criaturas y a todos los menús.
3. Recorré todo con capturas y comprobá: que lo jugable brilla y lo decorativo no, que no hay espacios vacíos, que todo se lee en celular y que el juego sigue fluido.
4. Guardá los colores de la paleta en un módulo en mutant-lab/src/shared, para que cambiar un color sea cambiar una línea.
