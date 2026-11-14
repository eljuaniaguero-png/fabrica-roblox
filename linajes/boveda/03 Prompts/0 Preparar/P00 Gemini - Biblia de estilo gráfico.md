---
tags: [prompt, estilo, gemini]
herramienta: Gemini (generación de imágenes)
creado: 2026-11-14
---
# P00 Gemini: biblia de estilo gráfico de Linajes del Eclipse

Prompt para que Gemini arme **la biblia visual del juego**: 10 láminas, una por mensaje, todas con el mismo estilo. Sale de mirar las 116 referencias del proyecto (las 8 de `02 Estilo/referencias`, mundo, anime, NPCs, interfaz, combate, trajes, portadas, r0aring y las hojas de Gemini que ya aprobaste) y de [[Guía de estilo]], [[Colores]], [[Referencias de estética]] y [[Arena en Blender]].

> [!warning] Antes de usarlo
> - Lo que salga es **referencia para Claude**, no arte final: no se suben estas imágenes a Roblox ni se usan como texturas (Juani no quiere texturas de Gemini).
> - Si adjuntás capturas de otros juegos, son solo para el clima. Gemini no puede copiar personajes, logos, trajes ni mapas de nadie.
> - Pegá **primero el bloque "Contexto"** y después **una lámina por mensaje**. Si una sale mal, pedí "rehacé la lámina N respetando el contexto" en vez de empezar de cero.

## Qué adjuntar en el primer mensaje
1. `02 Estilo/referencias/estilo-02-protagonista.png` (el protagonista aprobado).
2. `02 Estilo/referencias/estilo-01-paleta-luz.png` (las 6 luces del puerto).
3. `02 Estilo/referencias/estilo-05-materiales.png` (nivel de desgaste).
4. `02 Estilo/referencias/estilo-04-poderes.png` (los 6 Linajes).
5. `08 Lugares/renders/arena-gemini-ref-1.png` (distribución de la arena).
6. `arte/renders/grua-4-vistas.png` (la grúa aprobada).

---

## Bloque 1: Contexto (pegar primero, una sola vez)

```
Vas a ser el director de arte de un videojuego de Roblox llamado "Linajes del Eclipse". Te voy a pedir 10 láminas de una biblia de estilo, una por mensaje. Todas tienen que verse como parte del mismo libro: mismo trazo, misma paleta, misma luz, misma tipografía de rótulos. Las imágenes que te adjunto son el estilo YA APROBADO: respetalas al pie de la letra y construí sobre ellas, no inventes otro estilo.

QUÉ JUEGO ES
RPG de superhéroes con combate en tiempo real, multijugador, para Roblox (se juega mucho en celular). Los jugadores tienen un "Linaje" (un poder heredado) y pelean en un puerto industrial abandonado llamado Puerto Óxido, siempre de atardecer o de noche. Tono: cómic urbano oscuro pero divertido y "dopamínico": el mundo es apagado y sucio, los poderes son lo único que explota de color.

LA FRASE QUE MANDA SOBRE TODO
"Mundo apagado, poderes brillantes." Puerto oxidado con niebla azulada y luz dramática que sale de cosas reales (farolas de sodio, reflectores, ventanas, fuego). Colores del mundo gastados: óxido, gris acero, azul noche, madera vieja. Solo los poderes, las luces y los acentos de bando son saturados.

TÉCNICA DE DIBUJO (para TODAS las láminas)
- Ilustración digital estilo "concept art de juego estilizado": formas en bloque, pintado a mano, con contorno de tinta oscuro (#14161d) de grosor medio en las siluetas y más fino adentro.
- Sombreado por planos en 3 valores (luz, medio, sombra) con un poco de degradé suave, NO fotorrealista y NO cel-shading plano.
- Desgaste dibujado a mano y legible: óxido en bordes y uniones, pintura saltada en las esquinas, chorreados de óxido debajo de remaches, mugre acumulada abajo y en los rincones. Nada de ruido fotográfico.
- Iluminación de cine: luz de borde (rim light) en los personajes, contraste frío/cálido, sombras largas y oscuras pero nunca negro puro (siempre un poco de azul o violeta en la sombra).
- Fondo de las láminas de diseño: gris neutro medio (#4a4d55) con viñeta suave. Fondo de las láminas de escena: la escena misma.
- Rótulos en español, en mayúsculas, tipografía sans-serif condensada y gruesa, blanca, con número de lámina arriba a la izquierda ("LÁMINA 3 · MATERIALES"). Textos cortos y legibles.
- Formato horizontal 16:9, alta resolución, sin marca de agua ni firma.

LA FORMA DE LOS PERSONAJES (regla de Roblox, no negociable)
- Cuerpo de bloques tipo Roblox R15 (rectángulos con bordes apenas redondeados): torso cuadrado, brazos y piernas rectos de 2 piezas, cabeza cilíndrica/cuadrada grande.
- Proporción "chibi heroico": cabeza grande (1/4 del alto), hombros anchos, manos en bloque.
- Cara estilo anime dibujada sobre la cabeza: ojos grandes y angulosos con delineado negro grueso, cejas expresivas, nariz chica en una línea, boca simple; marcas de rasguño opcionales en las mejillas.
- Pelo en mechones filosos en capas (puntas, flequillo o corto), con brillo en franjas.
- Ropa en capas pegadas al bloque (campera, remera, pantalón, zapatillas), colores oscuros con acentos claros en cuello, franjas y suela para que se lean de noche.
- El protagonista de referencia: pelo azul en puntas, campera azul marino con cuello y franjas rojas, remera blanca, pantalón negro con franja roja, zapatillas blancas y rojas. Mantenelo idéntico cada vez que aparezca.

PALETA (usá estos hex exactos)
Mundo: fondo #0e1016 · superficie #1b1f2a · asfalto #3a3f4b · ladrillo #6e3b2e · acero #8a94a6 · óxido #613621 · óxido claro #804925 · madera gastada #4f3b29 · niebla de noche #2a3550.
Luz: sodio (farolas) #f29a3a · reflector frío #cfe3ff · ventana cálida #f2a23a · cielo de atardecer: horizonte #ff8a3a → medio #f0a07a → arriba rosado #d9a0b0 → cenit #6d7fb0 · noche: cielo #0b1020 con estrellas tenues.
Marca: eclipse #f2652b con corona dorada #ffb347.
Bandos (solo en acentos): Liga #2f6fdb · Cofradía #c2213a · Vigilantes #6b5ba8 · Neutral #b8bcc6.
Rareza de los poderes: común #9aa3ad · poco común #4ed68a · raro #4fb3f2 · épico #a15cf0 · legendario #f2a23a · mítico #ff4d6d.
Aviso de ataque: rojo #ff2a2a.

PROHIBIDO
- Logos, emblemas, trajes, personajes o nombres de DC, Marvel o de cualquier otro juego o película. Todo tiene que ser diseño propio.
- Carteles de neón, estética cyberpunk o ciudad futurista. Si hay carteles, son de chapa pintada, gastados y apagados.
- Negro puro de fondo, colores pastel, look de plástico brillante, fotorrealismo, estilo acuarela, estilo pixel art, cuerpos realistas o musculosos humanos.
- Sangre, armas de fuego realistas o cualquier cosa no apta para todo público.

Respondé "Listo" y esperá la lámina 1.
```

---

## Bloque 2: Las 10 láminas (una por mensaje)

### Lámina 1: Portada y frase de estilo
```
LÁMINA 1 · PORTADA. Ilustración principal del juego, como un póster: el protagonista de la referencia en primer plano, en pose de pelea con los puños apretados y fuego naranja (#f2652b) saliendo de una mano, de espaldas a medias mirando al espectador por encima del hombro. Detrás, Puerto Óxido al atardecer: dos grúas de pórtico oxidadas recortadas contra el cielo, pilas de contenedores, niebla dorada, y en el cielo un eclipse enorme (disco oscuro con corona dorada #ffb347 y halo naranja #f2652b). Abajo, la frase rotulada: "MUNDO APAGADO · PODERES BRILLANTES". Sin título del juego (lo diseñamos aparte).
```

### Lámina 2: Paleta y luz
```
LÁMINA 2 · PALETA Y LUZ. Una misma vista aérea del puerto (la de la referencia de la arena) repetida en 4 horas, en una grilla 2x2: ATARDECER (sol bajo sobre el mar, cielo en degradé naranja → rosado → azul, sombras largas casi negras, todo bañado en dorado), CREPÚSCULO (violeta y ámbar, primeras farolas encendidas), NOCHE (azul #0b1020, niebla #2a3550, charcos naranjas de las farolas #f29a3a con halo en la niebla, reflectores fríos #cfe3ff con conos visibles), NOCHE DE PELEA (igual que noche, pero con dos personajes peleando en el centro y un estallido de fuego que ilumina el piso). Debajo de cada escena, una fila de 5 muestras de color con su hex escrito. Al pie, una regla: "LA LUZ SALE DE COSAS REALES: FAROLAS, REFLECTORES, VENTANAS, FUEGO".
```

### Lámina 3: Materiales
```
LÁMINA 3 · MATERIALES. Hoja de muestras sobre fondo gris, en 2 filas. Arriba, 6 objetos con el desgaste aplicado: contenedor rojo, contenedor azul, contenedor verde (todos con nervaduras verticales, óxido en cantos y chorreados bajo remaches, una puerta entreabierta en uno), cajón de madera con listones en X, barril metálico con aros, bita de amarre con soga. Abajo, 6 cuadrados de textura que se repiten sin costura: CHAPA ACANALADA OXIDADA, LADRILLO VIEJO CON MUSGO ABAJO, CEMENTO MOJADO CON MANCHAS DE ACEITE (sin juntas de baldosa), CHAPA ESTRIADA DE PISO, TABLAS DE MUELLE GRISES DE SAL, MADERA GASTADA. Cada muestra con un círculo de zoom que muestre el detalle del borde gastado. Rótulo al pie: "DESGASTE: ÓXIDO EN BORDES · MUGRE ABAJO · CHORREADOS BAJO REMACHES".
```

### Lámina 4: El protagonista y el cuerpo
```
LÁMINA 4 · CUERPO Y PROTAGONISTA. Hoja de modelo del protagonista de la referencia, idéntico: vista de frente, tres cuartos, perfil y espalda, en fila, con una línea de altura marcada en "studs" a la izquierda (5 studs de alto). Debajo, una fila con el cuerpo base desnudo de bloques en gris (como un maniquí) para mostrar las piezas: cabeza, torso, brazo superior e inferior, mano, pierna superior e inferior, pie. A la derecha, un recuadro "CARAS": 6 expresiones anime de la misma cara (determinado, sonrisa confiada, enojado gritando, sorprendido, cansado con rasguño, burlón), dibujadas sobre la cabeza de bloque.
```

### Lámina 5: Personajes y bandos
```
LÁMINA 5 · ELENCO Y BANDOS. Fila de 8 personajes con el mismo cuerpo de bloques y la misma altura de cabeza, parados sobre una línea de piso: el protagonista, un mecánico viejo con delantal y llave inglesa, un capitán de barco con gorra y arpón, un pibe de la calle con gorra y campera universitaria, un matón del puerto con chaleco de obra, un matón grande con implantes mecánicos en un brazo, una piloto con campera de aviadora, y un jefe enorme (el doble de alto) con brazo hidráulico oxidado. Ropa en colores apagados con acentos claros. Debajo, 4 insignias de bando diseñadas desde cero, de chapa pintada y gastada, cada una con su color: LIGA (#2f6fdb, escudo con ala), COFRADÍA (#c2213a, máscara partida), VIGILANTES (#6b5ba8, ojo con capucha), NEUTRAL (#b8bcc6, ancla rota). Que ninguna se parezca a un logo existente.
```

### Lámina 6: Poderes
```
LÁMINA 6 · PODERES. Grilla 3x2 con los 6 Linajes del lanzamiento, el mismo protagonista ejecutando cada uno sobre el piso mojado del puerto de noche: FUERZA BRUTA (golpe al piso que agrieta el cemento, polvo y ondas doradas), REFLEJOS (ráfaga de puños con estelas de imagen, cian y amarillo), PIROQUINESIS (bola de fuego naranja con núcleo blanco, humo y brasas), ELECTRO (rayos celestes que se ramifican y chispean contra el metal), CRIOGENIA (estalactitas de hielo y vaho blanco, reflejo frío en el piso), TELEQUINESIS (cajones y barriles flotando rodeados de energía violeta). Reglas visibles en cada recuadro: centro brillante, cuerpo del efecto, humo o restos y partículas; el poder ilumina el piso, las paredes y al personaje; un borde de color de rareza en el marco del recuadro. Rótulo al pie: "EL PODER ES LO ÚNICO SATURADO DE LA PANTALLA".
```

### Lámina 7: La arena del puerto
```
LÁMINA 7 · LA ARENA. Vista aérea de 3/4 de la arena de pelea en Puerto Óxido, de noche, como en la referencia de la arena: plaza central de cemento LIBRE para pelear, con manchas de aceite, charcos y líneas pintadas gastadas; a la izquierda el borde del muelle sobre el agua, con dos grúas de pórtico oxidadas una detrás de la otra sobre rieles paralelos al borde y el brazo hacia el agua (como la grúa de referencia, con cabina de ventana cálida y luz roja en la punta); al fondo y a la derecha, pilas prolijas de contenedores de colores y dos galpones de chapa con portones y ventanas encendidas; barriles y cajones recién descargados en el borde del muelle; 5 farolas de sodio con conos de luz en la niebla; 2 torres de reflectores. Rotulá con flechas finas: ZONA SEGURA, CÍRCULO DE DUELO, MUELLE, GRÚAS, CARGA, GALPONES.
```

### Lámina 8: Lugares
```
LÁMINA 8 · LUGARES. Grilla 2x2 de escenas a la altura del jugador (cámara detrás del personaje, de 8 studs): EL TALLER (galpón de mecánico por dentro, auto levantado, banco de herramientas, entrepiso con escalera, monitor viejo verde, luz cálida colgante y portón abierto a la noche azul), LA CALLE (callejón de ladrillo mojado con escaleras de incendio, farolas, un patrullero a lo lejos con luces rojas y azules en la niebla), EL GALPÓN DEL JEFE (galpón enorme oxidado, contraluz por el portón, chispas y polvo, el jefe de brazo hidráulico esperando), EL MUELLE AL AMANECER (tablas mojadas, sogas, bitas, gaviotas, la grúa recortada contra un cielo rosado). Mismo estilo, misma paleta.
```

### Lámina 9: Interfaz
```
LÁMINA 9 · INTERFAZ. Maqueta de pantallas para celular horizontal, sobria y legible: paneles oscuros #1b1f2a con borde fino de 1 px y esquinas rectas, texto blanco #eef0f4, acentos naranja eclipse #f2652b. Mostrá: (a) HUD de pelea con barra de vida #d23a4a, energía #2c7be5 y escudo #3fc1b0 arriba a la izquierda, tres botones de habilidad Z X C redondos abajo a la derecha con ícono y tiempo de recarga, un botón grande de golpe; (b) la RULETA DE LINAJE con la lista de probabilidades en porcentaje, cada rareza en su color, y un botón "TIRAR"; (c) MENÚ PRINCIPAL cinematográfico: el puerto de fondo, título del juego con un eclipse, opciones chicas a la izquierda; (d) pantalla al perder, con texto grande "CAÍSTE". Íconos de línea simples, nada de brillos de plástico.
```

### Lámina 10: Reglas y lo que no se hace
```
LÁMINA 10 · REGLAS. Lámina de "sí / no" en dos columnas con ejemplos dibujados chicos: SÍ (niebla azul con luces que tienen halo · poderes saturados con capas · desgaste en bordes · personajes con luz de borde que se leen contra el fondo · plaza libre para pelear · objetos apoyados con sombra de contacto) y NO (negro puro · carteles de neón · todo del mismo brillo · piso que parece nieve por charcos con mucho contraste · cuadrado blanco en vez de ventana · efectos planos de un solo color · personajes que se pierden en la oscuridad). Cada ejemplo con una tilde verde o una cruz roja y una frase corta.
```

---

## Cuando estén las 10
1. Guardalas en `02 Estilo/referencias/` como `biblia-01-portada.png` … `biblia-10-reglas.png`.
2. Pedile a Claude: "Leé la biblia de estilo y actualizá la Guía de estilo con lo que te sirva". Claude toma las ideas y hace los modelos en Blender, como siempre.

Volver a [[Todos los prompts]]
