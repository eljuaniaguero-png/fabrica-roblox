# Mutant Lab — documento de arte para Blender

Este documento describe todo lo que se modela en Blender para Mutant Lab: cómo tiene que verse, cómo se arma técnicamente y la lista completa de objetos.
Lo lee Claude antes de cada pedido de ideas/archivo/mutant-lab-blender.md (archivado; hoy los pedidos están en PLAN.md). Si algo de acá choca con el código, manda el código: avisá la diferencia y anotala acá.

---

## 1. Dirección de arte: estilo toon

**La guía es `ideas/estilo-toon.md`** (12 oct 2026): reemplaza al "laboratorio de caricatura de noche" en todo lo que choque. En resumen:
1. **Contorno grueso** violeta casi negro alrededor de cada forma.
2. **Colores planos y saturados**, sin reflejos ni texturas; como mucho una sombra de un escalón.
3. **Brillante y alegre:** un atardecer violeta y rosa, no una noche oscura.
4. **Formas geométricas simples** combinadas (bolas, triángulos, rectángulos redondeados, óvalos): gracioso por la forma, no por el detalle.
5. **Todo lo vivo tiene ojos enormes:** blanco, pupila gigante violeta oscura, un puntito de brillo y párpados de color. Criaturas, frutas, huevos a punto de nacer y el robot vendedor tienen cara.
6. **Lo importante resalta por color y contorno,** no por oscuridad alrededor. El neón queda para detalles chicos que tienen que brillar.

Siguen valiendo de antes: **silueta primero** (cada objeto importante se reconoce pintado de un solo color, a 20 studs, en un celular) y **pocas piezas, bien hechas**.

**Colores**
- Los colores exactos están en `mutant-lab/src/shared/Paleta.luau` (`Paleta.Toon` tiene los de la guía; los nombres por uso, como `Acento` o `Elementos.Fuego`, apuntan a ellos). En Blender se usan como vista previa; en Roblox el color lo pone el código.
- Base del mundo: crema durazno (pisos y pedestales), lila grisáceo (paredes y metal), cielo violeta y rosa. Acentos: menta (ADN y laboratorio), rosa chicle (anillos y bordes), amarillo sol (premios y raro).
- Un color por elemento: fuego, agua, planta, eléctrico y sombra (ver `Paleta.Elementos`).

---

## 2. Reglas técnicas

| Tema | Regla |
|---|---|
| Escala | 1 unidad de Blender = 1 stud. Confirmarlo en el pedido 0 y anotar acá el resultado. |
| Orientación | En Roblox el frente de las criaturas mira a -Z (ver Piezas.luau). comun.py convierte los ejes de Blender para que el frente llegue bien. |
| Origen | En el punto de unión o de apoyo: piezas de criatura en su enchufe, muebles en el centro de su base, objetos colgantes en su punto de cuelgue. |
| Mallas por color | Una malla por zona de color, sin texturas. El código pinta cada malla. |
| Nombres de mallas | `Objeto_Parte` y sufijos especiales: `_Neon` (brilla), `_Vidrio` (transparente), `_Anim` (se mueve por código), `_Ojo` (no se pinta). |
| Polígonos | Pieza de criatura: hasta 1.500 triángulos. Fruta, huevo, objeto chico: hasta 1.500. Mueble o decoración: hasta 3.000. Pieza grande de escenario: hasta 8.000; si pasa, se parte en módulos. |
| Terminación | Bisel suave en todos los bordes, normales hacia afuera, sin caras internas ni duplicadas. Formas simples: el detalle lo dan el color y el contorno. |
| Contorno | En Roblox lo pone `shared/Toon.luau` con un casco invertido (copia un poco más grande, del color `Contorno`, con las caras dadas vuelta). Las Part ya lo tienen; las mallas de Blender van a exportar su propio casco (cómo, se define en el pedido de Blender toon). Ver `ideas/estilo-toon.md`, "Decisiones de la base". |
| Colisión | Se resuelve en Roblox con formas simples. Si un objeto necesita una forma de choque especial, se exporta aparte como `Objeto_Colision`. |
| Exportación | FBX, un archivo por objeto, en `mutant-lab/arte/export/<grupo>/`. |
| Vista previa | Cada objeto con un render PNG de fondo transparente en `mutant-lab/arte/renders/`. En estilo toon: sombreado plano con contorno, para que se vea igual que en el juego. |
| En Roblox | Todo lo importado vive en `ReplicatedStorage/Arte/<grupo>`. El código siempre tiene un respaldo con la versión vieja si falta una malla. |

---

## 3. Criaturas (por piezas)

**No se modelan criaturas enteras.** El juego arma más de 50 especies combinando piezas de las 10 bases. Se modelan las piezas, con los mismos enchufes que usa `shared/Piezas.luau`:

| Enchufe | Posición |
|---|---|
| Patas | desde el piso (y = 0) hasta y = 1,7 |
| Cuerpo | centrado en (0; 2,5; 0), unos 3 de largo |
| Cabeza | centrada en (0; 3,9; -1,7) |
| Cola | sale de (0; 2,8; 1,55) |
| Alas | a los costados del lomo (ver AlturaLomo en Piezas.luau) |

**Escala:** las piezas se modelan en estas medidas, sin achicar. El juego después escala el cuerpo, las patas, la cola y las alas (×0,78), agranda la cabeza (×1,45) y achica la criatura entera (×0,85). Esos números están en `Config.luau` (Criaturas: `EscalaCuerpo`, `EscalaCabeza`, `Escala`), así que no hay que aplicarlos en Blender.

**Lo que pone Roblox (no se modela):** la gema de neón con el color del elemento sobre el lomo (más grande si es mutante) y el anillo de luz en el piso con el color de la generación (`Generador.luau`).

**Las 10 especies base** (descripciones tomadas de Piezas.luau; tema y elemento de Especies.luau)

| # | Especie | Tema / elemento | Cabeza | Cuerpo | Patas | Cola o alas |
|---|---|---|---|---|---|---|
| 1 | Glupona | Agua / agua | Gota con dos ojos grandes | Bola gelatinosa translúcida | Cuatro patitas de ventosa | Cola de renacuajo |
| 2 | Rámulo | Musgo / planta | Óvalo con dos brotes de hojas | Tronco corto cubierto de musgo | Seis raíces cortas | Cola de enredadera enrollada |
| 3 | Sutomi | Hongo / planta | Sombrero de hongo con lunares | Tallo petiso y gordito | Dos patas gruesas | Cola corta en bolita de esporas |
| 4 | Rocote | Roca / sombra | Bloque cuadrado con cejas de piedra | Caparazón de lajas | Cuatro patas cortas tipo columna | Cola de maza (bola de piedra) |
| 5 | Chisparo | Fuego / fuego | Triangular con cuernitos de brasa | Torso de lagarto con escamas | Cuatro patas de lagartija abiertas | Cola con una llama en la punta |
| 6 | Dunaqui | Arena / fuego | Hocico largo y orejas enormes | Cuerpo con joroba | Patas anchas en forma de pala | Cola en espiral |
| 7 | Zoplito | Viento / eléctrico | Pico redondo con penacho | Cuerpo de plumas, liviano | Dos patas finas de ave | Alas grandes y redondas |
| 8 | Brinoza | Hielo / agua | Redonda con cuernos de carámbano | Pelaje esponjoso | Patas peludas con garritas | Cola de cristales de hielo |
| 9 | Fotina | Luz / eléctrico | Alargada con antenas de bombita | Cuerpo de insecto en segmentos | Seis patitas de insecto | Alas transparentes, dos pares |
| 10 | Nerulo | Noche / sombra | Tres ojitos y orejas puntiagudas | Cuerpo largo y flexible | Cuatro patas largas y sigilosas | Alas de membrana |

Por cada especie: 4 piezas (cabeza, cuerpo, patas, cola o alas), cada una partida en mallas por zona de color (color principal y manchas). Las piezas translúcidas (Glupona, alas de Fotina) llevan `_Vidrio`. Las piezas que brillan (llama de Chisparo, bombitas de Fotina) llevan `_Neon`.

**Ojos (kit compartido)**
- Ojo base: esfera blanca, pupila negra y punto de brillo, en mallas separadas con sufijo `_Ojo`.
- Variantes por personalidad (Personalidades.luau): Alegre (arqueados de felicidad), Vaga (párpado a media altura), Peleadora (ceja en ángulo), Miedosa (pupila chiquita), Curiosa (un ojo más grande), Líder (ceja firme y brillo extra), Trabajadora (mirada decidida), Glotona (ojos grandes y brillosos).
- Los ojos de Nerulo son tres; los de Glupona, extra grandes.

**Extras**
- Generación 3: corona chica, segundo par de alas genérico y anillo de aura (el aura puede quedar como efecto de Roblox).
- Pieza de elemento brillante: un adorno neón por elemento (llamita, gota, hoja, rayito, medialuna) que se apoya en el lomo.
- Nivel 10: aura del nivel (puede quedar como efecto de Roblox; si se modela, un anillo flotante).
- Lo que ya es efecto de partículas en Roblox (burbujas, esporas, chispas, escarcha, brillo mutante) no se modela.

---

## 4. Huevos

| Objeto | Descripción |
|---|---|
| Huevo gen 2 | Ovalado y rechoncho, de unos 1,6 de alto. Mallas: cáscara base y manchas, para pintar con los colores de los dos padres. |
| Huevo gen 3 | Más grande (unos 2,2) y con una franja en relieve. Mismas mallas más la franja `_Neon` del color del elemento. |
| Grietas | Tres etapas de grietas para cada tamaño, como mallas superpuestas `_Anim` que el código va mostrando. |
| Fragmentos | 6 pedazos de cáscara para la animación de nacimiento. |
| Nido | Canasta redonda acolchada con lugar para 10 huevos, en fila curva. |

Los huevos no tienen cara, salvo un par de ojitos que se asoman por una grieta en la última etapa.

---

## 5. Comida: frutas vivas

Cinco frutas, una por elemento. Todas tienen cara (ojos `_Ojo` y boca), patitas cortas para correr y un tamaño de 1 a 1,5 studs. Se tienen que reconocer por la silueta.

| Fruta | Elemento | Forma |
|---|---|---|
| Ají Lava | Fuego | Ají curvo con la punta en llama `_Neon` |
| Alga Burbuja | Agua | Bola de algas con burbujas pegadas |
| Hongo Brote | Planta | Hongo chiquito con dos hojitas |
| Chispafruta | Eléctrico | Fruta en forma de estrella con un rayito `_Neon` |
| Ciruela Sombra | Sombra | Ciruela oscura con un brillo violeta y ojos que brillan |

Además:
- **Fruta Dorada:** forma de fruta genérica brillante, con alitas chicas y estela (la estela es efecto de Roblox).
- **Fruta Gigante:** 4 veces más grande, con dos tallos gruesos a los costados para que dos jugadores tiren, y una cara de susto.
- **Semillas:** 5 semillas chicas, una por fruta, con el color de su elemento.
- **Planta de huerta:** 3 etapas por fruta (brote, planta, planta con fruto), en una maceta.

Las frutas se animan por código (correr, saltar, temblar), así que las patitas van en mallas `_Anim` separadas.

---

## 6. Laboratorio de cada jugador

Sala redonda de 68 studs de diámetro, abierta hacia la plaza (la ficha la achicó de 80 a 68 porque con 4 corrales quedaban huecos). Hoy se arma clonando el molde `ServerStorage > Moldes > Laboratorio`.

| Objeto | Descripción y mallas |
|---|---|
| Piso | Módulos en gajos para armar el círculo, con borde de franjas de seguridad. |
| Pared | Módulos curvos, con huecos para estantes y pantallas. |
| Arco de entrada | Arco con un cartel `_Neon` donde va el nombre del jugador. |
| Techo | Anillo con claraboya de vidrio y luna visible. |
| Máquina de fusión | Base metálica, cápsula `_Vidrio`, líquido `_Anim`, dos ranuras laterales para los padres, ranura de catalizador arriba con tapa `_Anim`, tubos con líquido `_Anim` y luces `_Neon`. Es la pieza estrella: la más detallada del juego. |
| Corral | Base hexagonal, cúpula `_Vidrio`, borde `_Neon`, cartel de ADN por segundo. Versión cerrada con cúpula opaca y candado. |
| Incubadora | Base calefactora con resistencias `_Neon`, campana `_Vidrio` y un soporte para el huevo. |
| Huerta | 2 macetas grandes con tierra. Las plantas son las de la sección 5. |
| Mostrador de tienda | Mostrador redondeado con pantalla de precios. |
| Robot vendedor | Personaje: cabeza-pantalla con cara (ojos `_Neon` en la pantalla), cuerpo redondo, dos brazos y una rueda. Partes separadas `_Anim` para saludar y girar. |
| Tablero de pedidos | Panel con 3 lugares para los pedidos y un banquito para los clientes. |
| Pantalla del Mutadex | Pantalla gigante con marco, en la pared del fondo. |
| Estante de trofeos | Estante de tres niveles. |
| Puntos de decoración | Marcas discretas en piso y paredes para el modo decorar (pueden ser solo de Roblox). |

---

## 7. Plaza central

| Objeto | Descripción |
|---|---|
| Piso | Círculo por módulos, con un dibujo de hélice de ADN en el centro. |
| Borde | Baranda con franjas de seguridad. |
| Faroles | Farol verde de laboratorio, con foco `_Neon`. |
| Bancos | Banco redondeado de metal. |
| Carteles con flecha | Cartel de neón apuntando a cada laboratorio. |
| Máquina de fusión en equipo | Versión grande de la máquina, con dos ranuras enfrentadas y un tubo de luz que sube al cielo. |
| Tablero del experimento del día | Pantalla grande con la silueta del día. |
| Tabla de posiciones | Soporte con pantalla. |
| Cartel del laboratorio destacado | Marco dorado con lugar para el nombre. |
| Portal al Jardín Salvaje | Arco de raíces y hongos con un remolino verde `_Anim`. |

---

## 8. Jardín Salvaje

Selva mutante de noche, separada del laboratorio. Pensada para correr: caminos claros, obstáculos que se leen de lejos.

| Objeto | Descripción |
|---|---|
| Suelo | Módulos de tierra con pasto oscuro, en varias formas para armar caminos y desniveles. |
| Plataformas | Hongos planos de distintas alturas para saltar. |
| Hongo rebote | Hongo con sombrero esponjoso y lunares `_Neon`. Su sombrero se aplasta `_Anim`. |
| Lianas | Liana colgante para cruzar, con punto de agarre. |
| Charco de slime | Charco verde brillante que frena. Plano, con burbujas. |
| Arbustos | Arbusto redondo donde se esconden frutas, con hojas que se mueven `_Anim`. |
| Árboles mutantes | Árboles grandes de fondo, con tronco retorcido y copas de colores. Solo decoración. |
| Rocas | Tres rocas redondeadas de distintos tamaños. |
| Portal de regreso | Igual al de la plaza. |
| Cartel de récords | Cartel de madera con pantalla. |

---

## 9. Objetos sueltos

| Objeto | Descripción |
|---|---|
| Catalizador Rayo | Pila de cristal amarillo con un rayo adentro `_Neon`. |
| Catalizador Hielo | Cubo de hielo con escarcha. |
| Catalizador Slime | Frasco que gotea slime verde. |
| Catalizador Lava | Piedra negra con grietas de lava `_Neon`. |
| Catalizador Sombra | Orbe oscuro con humo violeta adentro. |
| Residuo | Mancha gelatinosa de dos colores, con ojitos confundidos. |
| ADN | Hélice de ADN chica `_Neon`, para lo que flota y se junta. |
| Pista | Lupa con un papelito. |
| Trofeos | 9, uno por meta de `server/Metas.luau` (el estante tiene 9 lugares): bases, generación 2, generación 3, fusiones, pedidos, variantes, personalidades, mutantes y especial. Formas: copa, medalla, estrella, huevo dorado, frasco dorado, hélice dorada, catalizador dorado, máscara de teatro y criatura dorada. |
| Clientes de pedidos | 6 personajes originales y simpáticos con siluetas bien distintas (por ejemplo un robot cartero, una señora planta, un científico con anteojos enormes, un pulpo en traje, un fantasmita, un caracol con mochila). Partes separadas para saludar. |
| Pedestal de estatua | Pedestal con placa. La estatua se arma en Roblox con las piezas de la criatura en material de piedra. |

---

## 10. Catálogo de decoración (personalización)

| Grupo | Objetos |
|---|---|
| Temas de sala (6) | Azulejo de laboratorio, metal industrial, madera oscura, caramelo, cristal y selva. Cambian piso y paredes: se modelan solo los módulos que cambian de forma; los demás son cambio de color o material. |
| Frascos | Chico, mediano y grande, con líquido `_Neon`. |
| Plantas mutantes | Tres plantas en maceta, una con dientes de mentira. |
| Tubos | Recto, codo y vertical con burbujas. |
| Carteles de neón | Hélice de ADN, corazón, rayo y hongo. |
| Alfombras | Redonda, hexagonal y con forma de huevo. |
| Muebles | Sillón redondo, lámpara de lava, pecera con burbujas, robotito de adorno, pila de cajas y barril de peligro. |
| Aspectos de corral | Tres: burbuja, jaula de madera y cápsula espacial. |
| Aspectos de máquina | Tres: clásica, steampunk con engranajes y cristal flotante. |
| Aspectos de arco | Tres: metal, hongos y neón. |

---

## 11. Íconos (renders para la interfaz)

Se modelan en 3D y se renderizan como imagen. La lista exacta sale de `client/UI/Iconos.luau`, más estos:
ADN, pista, los 5 catalizadores, residuo, los 5 elementos, las 5 comidas, Fruta Dorada, huevo, incubadora, mejoras de la tienda, Mutadex, tienda, pedidos, misiones, ajustes, trofeo, candado, decorar, Jardín Salvaje y monedas premium.

- PNG de 512x512 con fondo transparente.
- Misma cámara en tres cuartos, misma luz y un contorno oscuro grueso en todos, para que se vean como un juego.
- Una versión gris de cada uno para "bloqueado" o "no alcanza".
- Guardados en `mutant-lab/arte/iconos/`.

---

## 12. Lista de aprobación

Antes de dar por terminado cualquier objeto, Claude revisa con el render:
- ¿Se reconoce la silueta pintada de negro?
- ¿Respeta las cinco reglas de la dirección de arte?
- ¿Tiene una malla por color, nombres correctos y sufijos donde corresponde?
- ¿El origen está en el punto de unión o apoyo?
- ¿Está dentro del límite de polígonos?
- ¿Combina con los objetos ya aprobados? (render al lado de uno aprobado)

---

## 13. Registro

Claude anota acá, al terminar cada pedido: qué se hizo, qué se cambió de este documento y por qué, y cualquier dato técnico descubierto (escala real, pasos de importación que funcionaron).

### 12 oct 2026 — revisión contra el código
Diferencias encontradas (manda el código, así que se corrigió el documento):
- Laboratorio: 68 studs de diámetro, no 80 (sección 6).
- Trofeos: 9, uno por meta, no 6 (sección 9).
- Escala de criaturas: el juego escala las piezas después de armarlas; se modelan en las medidas de los enchufes (sección 3).
- Gema del elemento y anillo de generación: los pone Roblox, no se modelan (sección 3).
- Pendiente: huevos, incubadoras, frutas, Jardín Salvaje y decoración todavía no existen en el juego (pedidos 7c, 7d y 7e). Su arte se puede hacer antes, pero se conecta cuando esos pedidos estén hechos.

### 12 oct 2026 — pedido 0: el camino completo con el Catalizador Slime
- Blender 5.2.2 LTS en `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`.
- Cada objeto es un script en `mutant-lab/arte/scripts/objetos/` que usa `comun.py`. Se corre en segundo plano (unos 10 segundos por objeto):
  `blender -b --factory-startup --python-exit-code 1 -P mutant-lab/arte/scripts/objetos/catalizador_slime.py`
- `comun.py` lee los colores de `Paleta.luau` (claves como `Catalizadores.Slime`), arma formas (torno, esferas, metabolas para lo blando), revisa nombres, triángulos, mallas cerradas, transformaciones y origen, exporta el FBX y saca tres imágenes en `renders/<grupo>/`: el render transparente, `_vista` (sobre el fondo del juego) y `_silueta` (negra y chica, como en un celular).
- Los `.blend` se guardan en `mutant-lab/arte/blend/` (fuera de git: se regeneran con los scripts).
- Exportación FBX (guía oficial de Roblox para Blender): Apply Scalings = FBX Units Scale, escala 1, Forward = Z, Up = Y, Apply Transform activado. En Blender el frente mira a -Y (vista Front).
- Vista previa del vidrio: semitransparente (alpha 0,3), como se ve en Roblox, no vidrio realista. El neón con fuerza 1: más fuerte se lava el color.
- Catalizador Slime: 1.456 triángulos, 1,34 x 1,26 x 1,69 studs. Mallas `CatalizadorSlime_Frasco_Vidrio`, `CatalizadorSlime_Slime_Neon` y `CatalizadorSlime_Tapa`.
- **Comprobado en Studio:**
  - **Escala:** 1 unidad de Blender = 1 stud, sin ajustes. El importador mostró 1,34 × 1,69 × 1,26, igual que Blender.
  - **Ejes:** el frente de Blender (-Y) llega a Roblox mirando a -Z, y +X de Blender queda en -X de Roblox (es un giro, no un espejo: la derecha del objeto sigue siendo su derecha).
  - **Pivote:** queda en el origen de Blender, o sea en la base del objeto, gracias a "Fijar pivote a origen de escena".
- **Pasos de importación que funcionaron** (Studio en español):
  1. Abrí el panel "Importar cola" y tocá el ícono de carpeta. Si había algo de antes en la cola, vaciala primero con "Borrar cola".
  2. Elegí el `.fbx` de `mutant-lab/arte/export/<grupo>/`. Se abre "Importar vista previa".
  3. Dejá: "Importar Solo como Modelo", "Cargar a Roblox", "Añadir a Workspace" y "Fijar pivote a origen de escena" prendidos. Prendé "Anclado".
  4. Revisá en Geometría del archivo: "Unidad de escala" en Stud, "Factor de escala" en 1 y "Combinar mallas" apagado. En Transformación: Frontal y Superior.
  5. Tocá Importar. Después, por MCP: mover el modelo a `ReplicatedStorage/Arte/<grupo>`, `PivotTo(CFrame.new())` y pintar.
- **Cómo se pinta en Roblox:**
  - `_Neon`: material Neon con el color de Paleta.
  - `_Vidrio`: SmoothPlastic, Transparency 0,45 y Reflectance 0,1 (`Config.Arte.Vidrio`). Con el material Glass casi no se veía de noche.
  - El resto: SmoothPlastic.
  - En todas las mallas: CanCollide, CanQuery y CanTouch apagados.
- IDs de las mallas en `Config.Arte.Mallas`. Copia del place en `backups/mutant-lab-2026-10-12.rbxl`.
- Para guardar la copia del place: Archivo → "Descargar una copia" (no cambia el juego en Roblox).

