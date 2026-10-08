# Mutant Lab — ficha del prototipo

Origen: idea del usuario (2026-10-07). Mecánica de colección + fusión; el contenido (criaturas, nombres, mapa) es todo propio.
Carpeta del juego: `mutant-lab/`.
Estado: versión 1 (2026-10-07), aprobada con el pedido de la Parte 1.
Versión 2 (2026-10-07): **Parte 1 hecha.** Estilo elegido por el usuario: "el que más le gusta a los nenes y el más dopamínico" → **A, Laboratorio caramelo, en versión saturada** (ver "Guía de estilo"). Cambió la regla de colores de la fusión (ver "Ajustes de la Parte 1").
Versión 3 (2026-10-07): **Parte 2 hecha** (máquina de fusión). Ver "Notas de la Parte 2".
Próximo punto de control: **Parte 3, Mutadex** (esperando el OK del usuario).

## Guía de estilo (elegida: A, Laboratorio caramelo saturado)

- **Paleta**: piso crema `#FFF4E0`, menta `#3EE6B5`, rosa chicle `#FF5FA2`, amarillo `#FFD23F`, violeta oscuro `#4B2C83`. Están en `mutant-lab/src/shared/Config.luau` (`Config.Estilo`).
- **Materiales**: SmoothPlastic en todo; Glass solo para cosas de agua o hielo; Neon solo para chispas, luces y brasas.
- **Iluminación**: de día (ClockTime 14), Brightness 2,2 con exposición −0,35, Atmosphere rosada suave, ColorCorrection con +20 % de saturación y un Bloom leve.
- **Formas**: redondeadas y gordas, ojos grandes con borde oscuro. Las criaturas se muestran sobre pedestales violeta con un borde amarillo para que resalten (sobre todo las blancas).
- **Textos**: fuente FredokaOne en blanco con borde violeta.

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

Moneda única: **ADN**. Todos los números van a `Config.luau` y se ajustan en la Parte 5.

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
- [ ] **Parte 3 - Mutadex**: UI con las 50 siluetas alrededor de la rueda, generación, casilla mutante, cuaderno de parejas tachadas y escáner.
- [ ] **Parte 4 - Laboratorio y economía**: el mapa del laboratorio, criaturas paseando, ADN por segundo, terminal para comprar bases y mejoras.
- [ ] **Parte 5 - Guardado, balance y pulido**: DataStore, ajuste de números con playtest de 10 minutos, sonidos (`-- SONIDO:`), legibilidad en celular.
- [ ] **Parte 6 - Compras con Robux**: solo cosas que no son azar. Ideas: pase "Doble ADN", pase "Segunda máquina" (dos fusiones a la vez), colores del laboratorio. Nada de cajas sorpresa ni subir la chance de mutante. Es punto de control: los pases los crea y les pone precio el usuario.

Puntos de control: esta ficha → estilo visual → prototipo jugable (Partes 1 a 5) → Parte 6.

---

## Propuestas de estilo visual (para elegir antes de construir)

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
