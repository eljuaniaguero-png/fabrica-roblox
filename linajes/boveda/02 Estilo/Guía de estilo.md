---
tags: [estilo]
---
# Guía de estilo

Copia de `linajes/arte/GUIA-ESTILO.md` (la que lee Claude), al día al 1 nov 2026. Si cambia una, se cambia la otra.

Copia del sistema de diseño https://claude.ai/artifact/WJxLkCEZEGJWzWzuyeU49y (30 oct 2026).


La guía para hacer los modelos 3D de Linajes del Eclipse: superhéroes de cómic oscuro en una ciudad nocturna, con mucho detalle de forma. Sirve para pedir un modelo nuevo y revisar que quede igual que los demás.

## Dirección de arte (decisión de Juani, 7 nov). MANDA sobre todo lo de abajo

> [!important] Mundo como Deepwoken, poderes como Shindo Life
> **El mundo** es oscuro, con niebla y colores apagados (óxido, gris, azul noche), y luz dramática que sale de fuentes reales. **Los poderes** son lo único muy saturado y brillante, para que cada pelea resalte contra el mundo apagado.

Referencias de Juani: **Deepwoken** (atmósfera, niebla, luz), **Shindo Life** y **Bloodlines** (efectos de poderes anime, espectáculo).

### Frase de estilo (nueva)
> Puerto oxidado de noche, con niebla azulada y luz dramática de farolas de sodio, reflectores y ventanas; colores apagados y gastados. Personajes cómic con acentos de color del bando. Los poderes son la única parte saturada y brillante: volumen, partículas, luz y temblor de cámara.

### El mundo
- **Nunca negro puro.** El fondo siempre tiene niebla azulada (`Atmosphere`) que se ve iluminada a lo lejos.
- **La luz sale de cosas reales del lugar:** farolas naranjas de sodio, reflectores blancos fríos de la grúa, ventanas cálidas de galpones, luces de barcos, la luz roja de altura de la grúa. Contraste frío/cálido.
- **Luz con forma:** conos de las farolas y rayos de los reflectores que se ven atravesando la niebla, charcos de luz en el piso.
- **Piso mojado** que refleja un poco las luces.
- **Nada de carteles de neón ni estética cyberpunk.** Si hay carteles, de chapa pintada y gastada, apagados o con una sola lamparita.
- **Texturas pintadas a mano, gastadas pero legibles:** óxido en bordes y uniones, pintura descascarada, suciedad abajo. Nada de ruido fotográfico.
- **Colores del mundo apagados** (ver [[Colores]]): óxido, gris acero, azul noche, madera gastada. El color fuerte queda reservado para los poderes y los acentos de bando.

### Los personajes
- Cuerpo cómic de bloques con contorno, como el personaje del jugador.
- Ropa de colores oscuros con **acentos claros** (bando, franjas, cuello) para que se lean de noche.
- El personaje se tiene que leer siempre contra el fondo: luz de borde o una luz suave que lo acompañe.

### Los poderes (lo que más tiene que brillar)
- **Colores muy saturados**, uno por Linaje (naranja fuego, celeste rayo, violeta sombra, etc.).
- **Volumen y capas:** centro brillante, cuerpo del efecto, humo o restos y partículas que salen volando. Nada de una imagen 2D plana.
- **Luz propia:** cada poder ilumina el piso, las paredes y a los personajes cercanos.
- **Impacto en pantalla:** temblor de cámara, destello corto y hit-stop en los golpes fuertes.
- **Sonido propio** en cada habilidad (carga, lanzamiento e impacto).
- Que no tapen la cámara: los efectos grandes aparecen delante del jugador, no pegados a la cámara.

### Cómo se prueba
Antes de cambiar todo el juego, se hace **un rincón lindo**: un pedazo chico del puerto con su luz, su piso, su niebla y sus objetos, pulido hasta que a Juani le guste. Si ese rincón queda bien, el resto repite la receta.

## Frase de estilo anterior (reemplazada el 7 nov)

> ~~Cómic oscuro en 3D: siluetas heroicas y exageradas, mucho detalle de forma (placas, costuras, pliegues de capa, cables), ciudad mojada de noche con neón; el color del bando va en los acentos, el resto es oscuro.~~

Pegala en cada pedido de modelo, con la ficha del personaje de **Modelos**.

## Cómo sale un modelo (en este orden)

**Todos los diseños y modelos los hace Claude en Blender** (decisión de Juani, 30 oct). Los sonidos y la música salen de ForgeGUI.

1. **Kit base**: maniquí R15 de bloques exportado de Studio, materiales `MAT_<nombre>` con estos colores, luz de noche y scripts en `linajes/arte/scripts/`.
2. **Boceto de bloques** de todas las piezas sobre el maniquí, 3 vistas (frente, costado, espalda). Juani aprueba la silueta.
3. **Detalle** con el presupuesto de triángulos de abajo: cada malla ≤ 20.000, un material por malla, UV en 0 a 1, normal map OpenGL, pivote en la base, escala real (1 stud = 0,28 m). Render de 3 vistas + primeros planos. Juani aprueba.
4. **Animaciones** en Blender sobre el esqueleto R15 a 30 fps, con marcadores `Impacto` y `Aviso`.
5. **Studio**: importar, `RenderFidelity = Automatic` en lo pesado, probar en compu y celular.

Cada modelo y animación se hace con un script para poder rehacerlo cambiando números. Los prompts detallados de cada pieza están en `linajes-guia-y-prompts-en-orden-2026-10-30.md`.

## Nivel de detalle (lo que separa un boceto de un modelo terminado)

El boceto de bloques es a propósito simple: sirve para aprobar la forma. Un modelo terminado cumple todo esto:

- Bisel en todos los bordes (0,02 a 0,05 studs, 2 segmentos).
- Placas en capas, con grosor y borde levantado, nunca un color pintado sobre una caja.
- Líneas de panel, costuras, remaches y tornillos (mínimo 10 detalles chicos por pieza grande).
- Curvas donde corresponde (hombreras, cascos, músculos del peto).
- Telas con simulación de tela horneada.
- Versión esculpida de mucho detalle horneada como normal map (OpenGL, 1024 px) sobre la versión del presupuesto.
- Texturas con desgaste: rayones, bordes claros, suciedad en las juntas.

## Triángulos: complejo, pero que corra

**El cuerpo es el cuerpo propio de Linajes** (esqueleto R15, el cuerpo de bloques de Roblox con cabeza clásica, cara estilo anime, remera y pantalón clásicos y pelo de mechones en capas, cambio de Juani del 31 oct; el juego no usa el avatar de Roblox, cambio de Juani del 30 oct) **y el detalle va en el traje**: casco o capucha, capa con pliegues, peto, hombreras, guantes, botas y accesorios, cada uno una pieza 3D con textura (líneas que brillan, costuras, placas). Así los jugadores se arman su héroe y se ponen los trajes sobre ese cuerpo.

Roblox acepta como máximo **20.000 triángulos por malla**, así que lo pesado se reparte en varias piezas.

| Pieza | Total | Mallas | Textura |
|---|---|---|---|
| Cuerpo propio (jugadores, NPCs, enemigos) | 4.000 a 6.000 + pelo 1.000 a 2.000 | 1 por parte del R15 | 1024 px |
| Traje de héroe o villano (sobre el cuerpo propio) | 20.000 a 40.000 | 5 a 8 piezas (casco 6.000 a 10.000, capa 4.000 a 8.000, peto y hombreras 6.000 a 12.000, guantes y botas 2.000 a 4.000 cada par) | 1024 px |
| Jefe gigante que no es humano (El Eclipsador, robots, criaturas) | 40.000 a 60.000 | 4 a 6, con rig propio | 1024 px |
| NPC con nombre (comisaria, cirujana, periodista) | 12.000 a 20.000 | 2 a 3 | 512 px |
| Enemigo común (matón, dron, robot) | 6.000 a 10.000 | 1 a 2 | 512 px |
| Edificio importante (El Faro, Penal Islaroca, torre Corona) | hasta 80.000 | en piezas de ≤ 20.000 | 1024 px |
| Edificio de relleno | 3.000 a 8.000 | 1 | 512 px |
| Prop (auto, farola, cartel, caja) | 500 a 3.000 | 1 | 256 px |
| Gadget o implante (se ve de cerca) | 2.000 a 5.000 | 1 | 512 px |

- En pantalla, apuntar a **≤ 500.000 triángulos visibles** en celular. Los enemigos comunes van livianos porque aparecen de a muchos.
- Los poderes (fuego, hielo, rayo, luz sólida) son **partículas y Neon**, no mallas.
- Los jugadores usan **el cuerpo propio de Linajes, nunca su avatar de Roblox**; los trajes, la tecnología y los implantes van encima como piezas (las del traje según la tabla, gadgets e implantes ≤ 5.000 cada uno).

## Reglas para jugar en Roblox (escala, choques y luces)

Sumadas el 31 oct a partir de consejos que juntó Juani. Valen para mundo, vehículos y objetos.

- **Escala del jugador:** un avatar mide unos 5 studs de alto y 3 de ancho. Puertas de por lo menos **5 x 7 studs**; pasillos y callejones de **6 studs** o más de ancho libre y 7 de alto (si no, la cámara choca con las paredes); portones por donde entran autos de **10 a 12 de ancho** y 8 a 10 de alto; autos de **6 studs** o más de ancho.
- **La malla que se ve no es la que choca:** lo que tiene muchas piezas finas (escaleras, rejas, barandas, escaleras de incendio, grúas) va con `CanCollide = false`, y al lado una **malla de choque** simple e invisible, de nombre `<Pieza>_Colision`: cajas y una rampa en cuña en vez de escalones, para que el jugador no se trabe.
- **Lo que brilla, en su malla:** faros, focos, neón, pantallas y fuego van en una malla aparte con material Neon, con su `PointLight` o `SpotLight` en ese lugar. Las partes que se mueven (persianas, puertas, ruedas, rotores) también van separadas.
- **Pivote abajo y al centro** (z = 0) en cada pieza.
- **Sin caras que nunca se ven:** al exportar se borra la base de edificios y muros apoyados en el piso y la panza de los autos.
- **Que no flote:** los edificios llevan zócalo de hormigón abajo.
- **Horneado**: las piezas de muchas partes chicas (placas con remaches, chapa estriada, grietas, tableros perforados) van sin bisel y sin hornear; las piezas de más de 30 studs (vigas, cañerías, techos) tampoco se hornean, porque cuelgan el proceso. Pisos de interior a 1024 px como máximo. Las juntitas de pisos y paredes van en la textura, no modeladas.
- **Chequeo automático** antes de cada render: ninguna malla se cruza con otra (salvo uniones a propósito) y nada que va en el piso flota.
- No se usa el estilo de paleta plana low-poly (un PNG de colores para todo): nuestra guía es cómic oscuro con detalle y texturas con desgaste. El rendimiento se cuida con los topes de triángulos de arriba y probando en celular.

## Color y material

- La ciudad es oscura: `asfalto`, `ladrillo`, `acero`. La luz viene de `neon-cian` (carteles, tecnología) y del eclipse (`eclipse`, `corona`).
- Cada bando tiene un acento: `liga` (azul), `cofradia` (carmesí), `vigilantes` (violeta), `neutral` (gris). Va en capas, emblemas propios, luces del traje, nunca en todo el cuerpo.
- La rareza del Linaje se ve en el color del poder: `rareza-comun` a `rareza-mitico`, los mismos colores de la lista de probabilidades.
- Lo que brilla es Neon. Metal de implantes: `acero` con detalle `neon-cian` encendido.
- Un material por malla. Normal map en formato OpenGL.

## Interfaz (de las capturas de referencia)

Las 5 capturas que mandó Juani son de otro juego de Roblox: se toma **la idea de cada pantalla**, nunca sus nombres, íconos ni textos.

| Pantalla | Cómo va en el nuestro |
|---|---|
| Menú con personaje al centro y "Espacio 1" | Fondo `fondo` con el eclipse (`eclipse`, `corona`) atrás; 3 espacios; datos en `cuerpo`, nombre del Linaje en su color de rareza |
| Lista de Linajes con % | Cabecera de rareza en `titulo-m` con su color; nombres en `cuerpo` |
| Árbol de habilidades de nodos | Nodos cuadrados `radio-s` sobre `superficie`; encendido = borde `neon-cian`; apagado = borde `acero` |
| Barras de vida | `vida`, `energia`, `escudo`, sobre `superficie`, cortes rectos (`radio-0`) |
| Lista de jugadores por pueblo | Cabecera por bando con su color; rango (Novato, Clase C a S) en `etiqueta` |

## Mundo (de las referencias)

- **Niebla** que tapa el fondo en Puerto Óxido y Ciudad Vórtice: da clima y ahorra en celular.
- Texturas sucias de piedra, óxido y ladrillo; telarañas y basura como detalle.
- Objetos para juntar (fragmentos, chatarra, chips) que **brillan** en el piso con Neon y una columna de luz.
- Distrito Corona: calles reales con senda peatonal, semáforos, líneas amarillas y rascacielos de vidrio junto al agua.
- Avisos de ataque: **flechas o zonas rojas** (`aviso`) en el piso antes del golpe.
- Pantalla de trajes: personaje girando sobre un degradado oscuro de `fondo` a `vigilantes`.

## Lo que no se hace

- Nada de logos, emblemas, trajes ni frases de DC. Los nombres de DC de **Modelos** son nombres de trabajo y se cambian antes de publicar; el **diseño** tiene que ser nuestro desde la primera hoja de concepto, porque un traje igual al de Batman sigue siendo Batman aunque se llame distinto.
- Ningún personaje con la silueta y los colores exactos de uno de DC: cambiar al menos tema visual, colores y forma de la capa o la máscara.

## Colores (hex)

| Token | Noche | Día | Uso |
|---|---|---|---|
| fondo | #0e1016 | #f1efe9 | Fondo de la guía y de los menús del juego (el menú de espacios va siempre en Noche). |
| superficie | #1b1f2a | #e2dfd6 | Paneles, fichas de modelo, marco de los nodos del árbol. |
| tinta | #eef0f4 | #14161d | Texto principal sobre `fondo` y `superficie`. |
| tinta-suave | #a3a9b6 | #4a4f5c | Texto secundario y medidas sobre `fondo` y `superficie`. |
| eclipse | #f2652b | #c94a15 | Color de marca: el anillo del eclipse, títulos destacados, botón principal. En Día se oscurece para leerse sobre `fondo`. |
| corona | #ffb347 | #ffb347 | Borde brillante del eclipse y Neon de los poderes de luz. |
| asfalto | #3a3f4b | #3a3f4b | Material base de la ciudad: calles, techos, concreto mojado. |
| ladrillo | #6e3b2e | #6e3b2e | Fachadas viejas de Ciudad Vórtice y Puerto Óxido. |
| acero | #8a94a6 | #8a94a6 | Metal de implantes, gadgets, rejas y estructuras del Distrito Corona. |
| neon-cian | #3fe0f0 | #3fe0f0 | Carteles, luces de tecnología e implantes encendidos (material Neon). |
| liga | #2f6fdb | #2f6fdb | Bando Liga de Guardianes: capas, banderas, cabecera en la lista de jugadores. |
| cofradia | #c2213a | #c2213a | Bando Cofradía Carmesí: detalles de villanos, banderas, cabecera en la lista. |
| vigilantes | #6b5ba8 | #6b5ba8 | Bando Vigilantes: detalles violeta oscuro, cabecera en la lista. |
| neutral | #b8bcc6 | #b8bcc6 | Bando Neutral (todos al empezar). |
| rareza-comun | #9aa3ad | #9aa3ad | Linajes Comunes en la lista de probabilidades y en sus efectos 3D. |
| rareza-poco-comun | #4ed68a | #4ed68a | Linajes Poco comunes. |
| rareza-raro | #4fb3f2 | #4fb3f2 | Linajes Raros. |
| rareza-epico | #a15cf0 | #a15cf0 | Linajes Épicos. |
| rareza-legendario | #f2a23a | #f2a23a | Linajes Legendarios. |
| rareza-mitico | #ff4d6d | #ff4d6d | Linaje Mítico (Eclipse). |
| vida | #d23a4a | #d23a4a | Barra de vida. |
| energia | #2c7be5 | #2c7be5 | Barra de energía de habilidades. |
| escudo | #3fc1b0 | #3fc1b0 | Barra de escudo (viene del traje tecnológico). |
| aviso | #ff2a2a | #ff2a2a | Brillo rojo en el piso antes de un ataque de jefe (Neon, 0,4 s antes del golpe). |

# Modelos

La lista de todo lo que hay que modelar, en el orden en que conviene hacerlo. La columna **DC (nombre de trabajo)** es la referencia que pidió Juani; antes de publicar se usa solo **Nombre final**.

## Personajes principales (héroes y villanos)

| Orden | DC (nombre de trabajo) | Nombre final | Bando | Diseño propio (lo que lo separa del original) | Triángulos del traje |
|---|---|---|---|---|---|
| 1 | Batman | Cuervo | Vigilantes | Tema cuervo: capa de plumas metálicas en capas, máscara con pico corto, gancho en el antebrazo | 40.000 |
| 2 | Superman | Centinela Solar | Liga | Armadura blanca y dorada con placas, corona solar detrás de la cabeza, sin letra en el pecho | 40.000 |
| 3 | Joker | Mascarada | Cofradía | Traje de teatro, máscaras intercambiables (una por fase del jefe), sin maquillaje de payaso | 35.000 |
| 4 | Wonder Woman | Atalanta | Liga | Armadura griega de bronce, lanza y escudo redondo, capa corta | 35.000 |
| 5 | Flash | Estela | Liga | Traje violeta aerodinámico, visor, estelas de luz | 30.000 |
| 6 | Green Lantern | Arquitecto | Liga | Guantelete tecnológico grande, traje de obrero espacial, constructos cian | 35.000 |
| 7 | Aquaman | Heredero Abisal | Liga | Armadura de coral y escamas oscuras, arpón de dos puntas | 35.000 |
| 8 | Cyborg | Bastión | Liga | Medio cuerpo de placas `acero` y `neon-cian`, cañón en el brazo | 40.000 |
| 9 | Lex Luthor | Víctor Halden | Cofradía | Traje de empresario + exoarmadura verde oscura y dorada para la pelea final | 30.000 |
| 10 | Darkseid | El Eclipsador | Cofradía (jefe final) | Gigante de piedra negra con un eclipse en el pecho, corona de rayos | 60.000 (modelo completo) |
| 11 | Bane | Remache | Cofradía | Matón enorme con implantes hidráulicos en brazos y espalda | 45.000 |
| 12 | Catwoman | Zarpa | Neutral | Ladrona con garras retráctiles y antiparras | 30.000 |
| 13 | Harley Quinn | Confeti | Cofradía | Acróbata con mazo de resorte y colores de feria | 30.000 |
| 14 | Pingüino | El Albatros | Cofradía | Jefe mafioso del puerto, abrigo largo y bastón-arpón | 30.000 |
| 15 | Dos Caras | Dualidad | Cofradía | Traje partido en dos materiales, dado de dos caras | 30.000 |
| 16 | Robin | Gorrión | Vigilantes | Aprendiz de Cuervo, capa corta, boleadoras | 25.000 |

## NPCs (historia, trabajos y ayuda)

| DC (nombre de trabajo) | Nombre final | Dónde | Para qué |
|---|---|---|---|
| Comisionado Gordon | Comisaria Rivas | Comisaría de Vórtice | Trabajos de patrulla, pistas de la historia |
| Lois Lane | Lucía Vega | Diario El Faro | Trabajos de reportero (fotos de crímenes), rumores = misiones |
| Alfred | Tano | Taller del puerto | Mentor: tecnología, gadgets, consejos |
| Lucius Fox | Ingeniera Okafor | Corona Corp (laboratorio) | Fabricar trajes y gadgets |
| (sin equivalente) | Dra. Kessler | Clínica clandestina | Implantes |
| Amanda Waller | Directora Brandt | Agencia secreta | Transferencias de Linaje, misiones grises |
| Oráculo | Señal | Radio pirata | Pide ayuda por radio, guía a los nuevos |

## Lugares

| DC (nombre de trabajo) | Nombre final | Edificios principales |
|---|---|---|
| Gotham | Ciudad Vórtice | Comisaría, Penal Islaroca, callejones, torre del reloj |
| Metrópolis | Distrito Corona | Torre Corona Corp, El Faro, plaza central |
| Muelles de Gotham | Puerto Óxido | Galpones, grúas, barco del Albatros |
| Arkham | Penal Islaroca | Penal en una isla, raid de fuga |
| Temiscira | Hespérides | Isla griega oculta |
| Atlántida | Ciudad Hundida | Bajo Puerto Óxido |
| Apokolips | Umbra | Mundo del Eclipsador (acto final) |
| Atalaya / Salón de la Justicia | Faro Orbital | Base de la Liga |
| Batcueva | El Nido | Base de los Vigilantes |
| Salón del Mal | La Fundición | Base de la Cofradía |

## Enemigos comunes

| Nombre | Dónde | Triángulos |
|---|---|---|
| Matón del puerto (3 variantes) | Puerto Óxido | 8.000 |
| Matón con implantes | Puerto Óxido, Vórtice | 10.000 |
| Dron de seguridad Corona | Distrito Corona | 6.000 |
| Robot centinela Corona | Distrito Corona | 10.000 |
| Preso fugado | Penal Islaroca | 8.000 |
| Soldado de Umbra | Umbra | 10.000 |
| Criatura abisal | Ciudad Hundida | 10.000 |


Ver también: [[Reglas de los prompts]] · [[Plantilla de prompt]] · [[Nivel de detalle]] · [[Colores]]
