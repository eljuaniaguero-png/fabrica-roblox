# Forja Rápida: prompts para que Claude haga modelos con el estilo de tus capturas (16 oct 2026)

Para Juani. Copiás cada bloque gris y lo pegás en Claude Code dentro de `fabrica-roblox`, **de a uno**, con `/clear` entre uno y otro.
Las 4 capturas de referencia ya están copiadas en tu PC en `forja-rapida/arte/referencias/` (estilo-1.png a estilo-4.png), así Claude las puede mirar sin que se las adjuntes.

---

## 1. Qué tienen tus capturas (lo que hay que imitar)

- **Todo está hecho de bloques tipo ladrillo de juguete**, con los **studs** (los circulitos/cuadraditos en relieve) a la vista en el piso, las paredes, los árboles y los cactus.
- **Formas simples y escalonadas**: los árboles son cajas verdes apiladas en escalones, los cactus son columnas de ladrillos con dos brazos, los árboles secos son troncos en "Y" de ladrillos marrón-violeta.
- **Colores planos y vivos**: piso verde lima, paredes coral y arena, cielo celeste con nubes y arcoíris, algún árbol violeta al fondo.
- **Huevos/rocas de vóxeles** (cubitos chiquitos) apoyados en un **nido de ramitas y escombros** marrón.
- **Mascota de bloques**: la gallina es casi toda cubos (cabeza cuadrada, ojos negros cuadrados, pico naranja, moco rojo, patas naranjas en escalón).

## 2. Cómo está Forja Rápida hoy (lo revisé en tu carpeta)

| Qué | Cómo está | ¿Se parece a tus capturas? |
|---|---|---|
| Geodas de los 5 biomas (`arte/renders/geodas_biomas.jpg`) | Vóxeles con nido marrón | **Sí, muy parecido.** Solo falta pulir el nido y los studs |
| Geoda Ancestral, vitrina, tablero, estatuas, gemas | Vóxeles | Bastante. Retoque chico |
| Picos (`picos.jpg`) | Dibujo plano de cubitos, finito | A medias: se ven chatos, en tus capturas todo es más gordo |
| **Decoración del mapa** (`mapa_bioma1.jpg`) | Cubos lisos grandes: árboles de 2 cajas, paredes azul oscuro lisas, sin studs | **No.** Es lo que más diferencia hace |
| **Mascotas** (Topito, Piedrín, Chispa, Musgo, Cuarcito, Glaciel, Magmo, Nébula) | El juego las arma con bolitas y cajas sueltas | **No.** Tendrían que ser como la gallina |

Por eso el orden recomendado es: **1) guía de estilo → 2) studs → 3) decoración del mapa → 4) mascotas → 5) retoques de geodas y picos.**

## 3. Con qué herramienta

**Todo con Claude, sin Gemini ni Meshy.** Este estilo es puro bloque, y armar cosas con cubos es justo lo que Claude hace bien en Blender (ya lo hizo con `rocas.py` y `modelos.py`). Gemini y Meshy hacen formas redondeadas y orgánicas, que acá quedarían fuera de estilo. ForgeGUI no hace falta.

Antes de cada prompt de Blender: **abrí Blender y encendé la conexión del complemento de Claude**.

**Regla de oro (está dentro de cada prompt):** los studs **no se modelan** como bultitos, se ponen como **textura** que se repite. Modelados, cada pared tendría cientos de miles de triángulos y el juego andaría lento en celular.

---

## 4. Los prompts

### Prompt 1: guía de estilo (una sola vez, primero)

```
Mirá las 4 capturas de forja-rapida/arte/referencias/ (son de otro juego: imitamos el
ESTILO, no copiamos personajes, nombres ni íconos). Compará con nuestros renders de
forja-rapida/arte/renders/ (geodas_biomas, mapa_bioma1, picos, eventos_y_exhibicion).

Escribí la guía de estilo de modelos en forja-rapida/arte/estilo-bloques.md con:
- Una "frase de estilo" de una línea para pegar en todos los pedidos de modelos.
- La paleta en hex (piso, paredes de cada bioma, hojas, troncos, nido, cielo).
- Medidas: tamaño del stud (1 stud de Roblox), tamaño del vóxel de rocas y huevos,
  altura de los escalones de árboles y riscos.
- Reglas: formas escalonadas de bloques, colores planos, nada redondo liso, studs como
  textura (nunca como geometría), límites de triángulos (decoración ≤ 2.000 por pieza,
  mascota ≤ 3.000, todo ≤ 20.000).
- Una tabla "hoy vs. cómo tendría que ser" por cada tipo de modelo del juego.
No toques código ni modelos todavía. Mostrame la guía cuando termines.
```

### Prompt 2: los studs (textura de ladrillo)

```
Leé forja-rapida/arte/estilo-bloques.md.
Armá con Python (como hiciste las texturas de arte/texturas/) una textura de studs
que se repite sin que se note el corte: un stud en relieve pintado (luz arriba a la
izquierda, sombra abajo a la derecha), en gris claro neutro para que en Roblox se
tiña con el color de cada parte. Hacé también la versión "ladrillo" para paredes
(studs + juntas de ladrillo). Guardalas en forja-rapida/arte/texturas/.

Después decime, sin cambiar código todavía, cuál es la forma más simple de que el
piso, los riscos y las paredes del mapa las usen (el mapa sale de arte/scripts/mapa.py
→ src/server/MapaDatos.luau → GeneradorMapa.luau). Que funcione aunque yo todavía no
haya subido la imagen a Roblox (que se vea como hoy hasta que pegue el ID).
Comprobación: un render en Blender de un pedazo de piso y de pared con la textura,
al lado de forja-rapida/arte/referencias/estilo-1.png.
```

Cuando te muestre el plan y te guste, respondé: `Dale, hacelo y probalo con Play. Mostrame una captura del bioma 1.`

### Prompt 3: decoración del mapa, de a un bioma

Empezá por la Pradera. Cuando te guste, repetís el mismo prompt cambiando el bioma y la lista.

```
Leé forja-rapida/arte/estilo-bloques.md y la sección "Mapa" de ideas/forja-rapida.md.
Guardá el .blend antes de empezar.

En Blender, con un script nuevo forja-rapida/arte/scripts/decoracion.py (mismo estilo
que rocas.py), armá la decoración del bioma 1 · Pradera imitando
arte/referencias/estilo-1.png:
- 3 árboles distintos: tronco de bloques marrón y copa de cajas verdes en 2 o 3
  escalones, con alguna caja que sobresale. Uno grande, uno mediano y uno chico.
- 2 árboles secos: tronco en "Y" de ladrillos marrón-violeta con 2 o 3 ramas.
- 2 arbustos chicos de 3 a 5 bloques verdes.
- 2 montoncitos de escombros: lajas grises-azuladas apiladas.
- 2 racimos de cuarzo violeta de bloques (reemplazan a los violetas de ahora).
Cada pieza: colores de la guía, studs como textura, ≤ 2.000 triángulos, pivote en
la base, nombre claro. Exportá a arte/fbx/Deco_Zona1.fbx.

Comprobación: tabla con triángulos por pieza y un render de todas juntas al lado
de la captura de referencia. NO toques el código ni el mapa todavía: primero quiero
ver el render.
```

Cuando apruebes el render:

```
Ahora reemplazá la decoración del bioma 1 en el mapa por estas piezas, usando la
forma más simple que encaje con cómo se arma el mapa hoy (si hace falta cambiar
mapa.py o GeneradorMapa, cambio mínimo). Si el modelo no está importado en Studio,
que siga saliendo la decoración vieja. Decime los pasos para importar el FBX.
Probalo con Play y mostrame capturas en compu y en celular.
```

Listas para los otros biomas (cambiás "bioma 1 · Pradera" y la lista de piezas):

- **2 · Dunas:** 3 cactus de ladrillos verdes (columna con 1 o 2 brazos en escalón), 2 árboles secos, dunas escalonadas color arena, 2 racimos de ámbar, huesos/fósil de bloques claros. Referencia: `estilo-2.png`.
- **3 · Glaciar:** 3 picos de hielo en escalones (blanco y celeste), pinos de bloques con nieve arriba, bloques de hielo sueltos, lago congelado de lajas.
- **4 · Volcán:** columnas de basalto de bloques negros, rocas con grietas naranja, árbol quemado en "Y", el volcán en escalones, piedras de lava.
- **5 · Abismo:** columnas violeta oscuro con estrellitas de bloques, islas flotantes en escalones, cristales rosa y violeta, rocas de meteorito.

### Prompt 4: mascotas de bloques (como la gallina)

```
Leé forja-rapida/arte/estilo-bloques.md y la tabla de mascotas de ideas/forja-rapida.md.
Mirá la gallina de arte/referencias/estilo-1.png y estilo-4.png: cabeza grande casi
cúbica, ojos negros cuadrados, pico de bloques, patas en escalón, todo cajas.
Guardá el .blend antes de empezar.

En Blender, con un script nuevo arte/scripts/mascotas.py, armá las 8 mascotas en ese
estilo, cada una con una forma que se reconozca desde lejos:
- Topito (común): topo marrón gordito, nariz rosa, garras claras.
- Piedrín (común): piedrita gris con ojos y patitas.
- Chispa (rara): bichito amarillo-naranja con chispa en la cabeza.
- Musgo (rara): bicho de musgo verde con una florcita.
- Cuarcito (épica): criatura de cuarzo violeta con puntas de cristal.
- Glaciel (épica): pingüino o zorrito de hielo blanco y celeste.
- Magmo (legendaria): bicho de roca negra con grietas de lava naranja.
- Nébula (mítica): gatito o búho violeta oscuro con estrellas.
Todas: cabeza grande (cerca de la mitad del cuerpo, se ven más tiernas), ojos negros
cuadrados de bloques, 1 a 1,8 studs de alto, ≤ 3.000 triángulos, pivote en el centro,
partes que se animan separadas (cuerpo, patas, alas o cola). Las legendarias y
míticas con alguna pieza que brille (Neon en Roblox).
Exportá a arte/fbx/Mascotas.fbx.

Comprobación: render de las 8 en fila al lado de la gallina de referencia y tabla
de triángulos. No toques código hasta que apruebe el render.
```

Cuando apruebes:

```
Ahora hacé que Mascotas.client.luau use estos modelos si están en
ServerStorage > Modelos > Mascotas, y si no, que siga armándolas con piezas como hoy.
Cambio mínimo. Agregá un saltito y una inclinación al caminar con tweens.
Decime los pasos para importar el FBX. Probalo con Play y mostrame captura.
```

### Prompt 5: retoques de geodas y picos

```
Leé forja-rapida/arte/estilo-bloques.md. Guardá el .blend antes de empezar.
Compará arte/renders/geodas_biomas.jpg con arte/referencias/estilo-3.png y estilo-4.png.
1. Nido: que se parezca más al de la referencia (ramitas y escombros marrón claro y
   oscuro, más bajito y más ancho que la roca), en rocas.py.
2. Picos (modelos.py): hacelos más gordos y en 3D (2 o 3 cubitos de grosor, cabeza más
   grande), mismos colores y nombres, ≤ 2.000 triángulos cada uno.
No cambies los nombres de las mallas (Roca, Cristales, Base, Grietas, Grietas2): el
juego las busca por nombre.
Comprobación: render antes/después de 3 geodas y de los 5 picos, y triángulos.
Reexportá los FBX que cambien y decime cuáles tengo que volver a importar.
```

### Prompt para cualquier modelo nuevo (plantilla)

```
Leé forja-rapida/arte/estilo-bloques.md. Guardá el .blend antes de empezar.
Armá en Blender un/una [QUÉ ES], estilo [FRASE DE ESTILO de la guía],
de [TAMAÑO] studs, ≤ [2.000] triángulos, studs como textura, pivote en la base.
Referencia: arte/referencias/[estilo-X.png].
Comprobación: render de frente y de costado al lado de la referencia y triángulos.
Si te lo apruebo, exportalo a arte/fbx/[Nombre].fbx.
```

---

## 5. Consejos para que salga bien

- **Primero el render, después el juego.** Todos los prompts piden ver el modelo antes de tocar el código. Si no te gusta, decile qué cambiar y qué dejar igual: *"Dejá todo igual, solo hacé la copa del árbol más alta y con un escalón más."*
- **Si lo corregiste dos veces y sigue mal**, `/clear` y volvé a pegar el prompt sumando lo que aprendiste.
- **Importar los FBX en Studio lo hacés vos** (Claude te da los pasos). Todavía te faltan los 6 FBX de geodas de antes: aprovechá y hacelos juntos.
- **Las texturas de studs hay que subirlas a Roblox** y pegar el ID donde Claude te diga. Hasta entonces el juego se ve como ahora, no se rompe.
- Las capturas son de otro juego: se imita el estilo, **no se copian** la gallina, la esfinge ni los nombres.
