# Forja Rápida · Un prompt de Blender para cada una de las 13 piezas (18/10/2026)

Revisé tu carpeta antes de escribirlos. Hoy el juego arma casi todas estas cosas **con bloques sueltos desde el código** (`GeneradorMapa.luau`): el altar es una losa gris con una bola amarilla, el cofre una caja marrón, el portal un aro de 8 palitos, el portón un vidrio celeste, la puerta secreta una pared con 3 grietas. Las mascotas salen de `Mascotas.client.luau` armadas con bolitas y cajas. La Ruleta, el Spawn y el Arco **ya tienen modelo** en `Lobby.fbx`, así que sus prompts piden mejorar lo que hay, no empezar de cero.

## Cómo usarlos

- Uno por mensaje, en este orden (lo que más se ve primero). Esperá el render y aprobalo antes del siguiente.
- Todos usan el mismo estilo que lo que ya hicimos: bloques con studs **como textura** (nunca como bloquecitos de verdad), colores vivos, sin texto en el modelo (el texto lo pone el juego).
- Los prompts 1 a 13 solo hacen el modelo y **no tocan el juego**. El prompt 14 del final los conecta todos juntos.
- A dónde va cada cosa:

| Pieza | Script | Archivo |
|---|---|---|
| Ruleta, Spawn, Arco | `arte/scripts/lobby.py` (ya existe) | `arte/fbx/Lobby.fbx` |
| Altar, Cofre, Puerta secreta, Sala secreta, Portón, Carteles, Portal, Isla Prisma | `arte/scripts/piezas_juego.py` (nuevo) | `arte/fbx/Piezas_Juego.fbx` |
| Piso de cada zona | `arte/scripts/decoracion.py` (ya existe) | texturas en `arte/texturas/` y `Deco_Comun.fbx` |
| Las 8 mascotas | `arte/scripts/mascotas.py` (nuevo) | `arte/fbx/Mascotas.fbx` |

---

### 1 · Ruleta de Mascotas nueva

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá arte/referencias/ (lobby-1.png y
lobby-2.png). Guardá el .blend antes de empezar.
Ya existe Ruleta_Mascotas en arte/scripts/lobby.py (escenario violeta de 20 x 12 studs con la
pieza Rueda) y en el juego la rueda que gira la arma GeneradorMapa con 8 gajos. Quiero una
ruleta nueva, más llamativa, que reemplace las dos cosas:
- Escenario de bloques violeta y dorado, con 2 escalones adelante y luces de bloques en el borde
  (Material Neon en Roblox).
- Rueda grande parada, de 16 studs de diámetro, con 8 gajos de colores (uno por mascota, de la
  más común a la más rara), cada gajo con un hueco cuadrado para poner la cara de su mascota
  después. Borde dorado de bloques con 16 lucecitas.
- Flecha dorada arriba que marca el ganador, y 2 columnas de bloques a los costados con una
  geoda chiquita arriba de cada una.
La rueda tiene que ser un objeto aparte "Rueda" con el pivote en su eje (para que el juego la
haga girar) y cada gajo una malla "Gajo1" a "Gajo8". Pivote del resto en el centro de la base,
frente hacia -Z, ≤ 8.000 triángulos en total.
Comprobación: render de frente y de 3/4, y triángulos. Si te la apruebo, reemplazá
Ruleta_Mascotas en Lobby.fbx. No toques el código del juego.
```

### 2 · Altar de ofrendas (uno por zona)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá arte/referencias/. Guardá el .blend
antes de empezar.
Con arte/scripts/piezas_juego.py (si no existe, crealo con el mismo estilo que lobby.py), armá
el altar donde el jugador ofrece 5 gemas comunes de la zona y recibe suerte (hoy en el juego es
una losa gris con una bola amarilla). Un modelo base con 5 versiones de color, una por zona:
Altar_Pradera (piedra gris con musgo y cuarzo violeta), Altar_Dunas (arenisca con ámbar),
Altar_Glaciar (hielo celeste con zafiro), Altar_Volcan (basalto negro con rubí y grietas de lava)
y Altar_Abismo (piedra violeta oscura con estrellitas).
Forma: base de 3 escalones de bloques de 6 x 6 studs, una columna corta en el medio con un cuenco
arriba donde caen las ofrendas, y un cristal grande de su zona flotando arriba del cuenco (objeto
aparte "Altar_Orbe", para que el juego lo haga brillar y girar). 4 velitas de bloques en las
esquinas con la llama aparte ("Altar_Llama"). 6 studs de alto sin contar el cristal.
Pivote en el centro de la base, ≤ 4.000 triángulos cada uno.
Comprobación: render de los 5 en fila y triángulos. Si te los apruebo, exportá a
arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 3 · Cofre de la cámara secreta

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá "Cofre_Secreto": cofre del tesoro de bloques de 5 x 3,5
studs y 3,5 de alto, madera marrón con bordes y esquinas de oro, una cerradura con forma de
gema violeta al frente y la tapa curva en escalones. La tapa es un objeto aparte "Cofre_Tapa"
con el pivote en la bisagra de atrás (para que el juego la abra girándola). Adentro, objeto
aparte "Cofre_Tesoro": montañita de monedas de oro y 3 gemitas de colores, que se ve solo cuando
se abre. Una versión cerrada y otra con la tapa abierta para el render.
Pivote en el centro de la base, ≤ 3.000 triángulos.
Comprobación: render cerrado y abierto, y triángulos. Si te lo apruebo, sumalo a
arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 4 · Puerta secreta

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá Risco_Escalon y Pared_Ladrillo en
arte/fbx/Deco_Comun.fbx. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá la puerta secreta (hoy es una pared gris con 3 grietas).
Tiene que parecer parte del risco de la zona para que cueste encontrarla, pero con pistas:
pared de bloques de piedra de 10 x 12 studs y 3 de fondo, igual al risco, con una grieta en
forma de arco de puerta que brilla apenas violeta (malla "Puerta_Grieta", Neon en Roblox), unas
runas cuadradas chiquitas a los costados y unos cristalitos violetas asomando abajo.
La parte que se abre es un objeto aparte "Puerta_Hoja" (las dos mitades "Puerta_HojaIzq" y
"Puerta_HojaDer", con el pivote en el borde de afuera para que el juego las abra). 5 versiones
de color de la piedra, una por zona, igual que el risco de cada zona (Puerta_Pradera ...
Puerta_Abismo).
Pivote en el centro de la base, ≤ 3.000 triángulos cada una.
Comprobación: render cerrada y abierta de una zona, al lado del risco de esa zona, y triángulos.
Si te la apruebo, sumala a arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 5 · Sala de la cámara secreta

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá en arte/scripts/mapa.py de qué tamaño
son hoy las cámaras secretas detrás de cada puerta. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá "Camara_Secreta": la cueva que está detrás de la puerta
secreta, del mismo tamaño que la de mapa.py (si no hay, 24 x 24 studs y 12 de alto). Piso de
losas con studs, paredes de bloques de piedra oscura, el techo abierto en el centro con una luz
que entra (rayo de luz hecho de bloques transparentes, malla "Camara_Luz"), muchos cristales
grandes de la zona saliendo de paredes y esquinas, una tarima en el fondo para el Cofre_Secreto
y antorchas de bloques con la llama aparte. La entrada coincide con el hueco de la Puerta
secreta. 5 versiones de color, una por zona (Camara_Pradera ... Camara_Abismo).
Pivote en el centro del piso, ≤ 12.000 triángulos cada una.
Comprobación: render desde la entrada y desde arriba sin techo, con el cofre puesto, y
triángulos. Si te la apruebo, sumala a arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 6 · Portón entre zonas

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá Arco_Entrada en arte/scripts/lobby.py
para que combine. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá el portón que separa una zona de la siguiente (hoy es un
vidrio celeste). Mirá en mapa.py el tamaño de las PuertaZona y hacelo de ese tamaño: dos torres
de bloques de piedra a los costados con almenas arriba, un arco de bloques entre las dos, y en
el medio una reja de barrotes dorados (objeto aparte "Porton_Reja", con el pivote abajo, para
que el juego la suba cuando abrís la zona) y detrás un velo de luz (malla "Porton_Velo", Neon
transparente). Arriba del arco, un escudo vacío (malla "Porton_Escudo") donde el juego pone el
precio. Las torres llevan los colores de la zona a la que entrás: Porton_Dunas, Porton_Glaciar,
Porton_Volcan y Porton_Abismo.
Pivote en el centro de la base, ≤ 5.000 triángulos cada uno.
Comprobación: render cerrado y abierto, y triángulos. Si te lo apruebo, sumalo a
arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 7 · Carteles (dificultad y Misiones)

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá los carteles (hoy son placas azul oscuro con marco
dorado). Sin texto: el texto lo pone el juego encima de la malla "Cartel_Cara".
- Cartel_Poste: tablón de madera de bloques de 8 x 4 studs con borde de madera más oscura,
  clavado en un poste de bloques, con un pastito de bloques en la base.
- Cartel_Pared: el mismo tablón sin poste, con 2 soportes para colgarlo del risco (para los de
  dificultad).
- Cartel_Misiones: más grande (10 x 6), tablero de corcho con papelitos de colores pinchados,
  un techito de tejas en escalones y un signo de exclamación amarillo de bloques arriba (malla
  "Cartel_Exclamacion", para que el juego lo haga saltar).
- Cartel_Dificultad: el de pared con 5 calaveritas o estrellitas de bloques abajo (mallas
  "Cartel_Nivel1" a "Cartel_Nivel5") para que el juego prenda las que corresponden.
La cara del cartel tiene que ser plana y lisa (sin studs) para que se lea el texto.
Pivote en el centro de la base, ≤ 2.000 triángulos cada uno.
Comprobación: render de los 4 en fila y triángulos. Si te los apruebo, sumalos a
arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 8 · Portal a la Dimensión Prisma

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá "Portal_Prisma" (hoy es un aro de 8 palitos con un disco).
Marco de bloques parado, de 14 studs de alto y 12 de ancho, en escalones, hecho de cristal
transparente que pasa por todos los colores del arcoíris, cubito por cubito. Base de 2 escalones
de piedra blanca con studs, y 4 prismas de cristal flotando alrededor del marco (objetos aparte
"Portal_Prisma1" a "Portal_Prisma4", para que el juego los haga girar). En el medio, un disco
plano parado (malla "Portal_Disco", Neon transparente) que es lo que el jugador toca para viajar;
tiene que medir como el disco de hoy (9,4 studs) para que siga funcionando igual.
Hacé también "Portal_Vuelta": el mismo portal en blanco y dorado, para volver desde la isla.
Pivote en el centro de la base, frente hacia -Z, ≤ 5.000 triángulos cada uno.
Comprobación: render de frente y de 3/4, y triángulos. Si te lo apruebo, sumalo a
arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 9 · Isla de la Dimensión Prisma

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá en arte/scripts/mapa.py dónde está y
qué tamaño tiene hoy la Dimensión Prisma y qué marcadores tiene (destino del portal, geodas,
etc.). Guardá el .blend antes de empezar.
En arte/scripts/piezas_juego.py armá "Isla_Prisma": isla flotante del mismo tamaño que la de
mapa.py, piso de losas blancas con studs y caminitos de colores arcoíris, el borde de abajo en
escalones que se achican como una roca colgando, con cristales de colores colgando. Arriba:
árboles de cristal en escalones (cada uno de un color), columnas de prisma, un lago chiquito
de cristal y 3 islitas más chicas flotando alrededor (solo de fondo). Dejá libres los lugares
donde van los puntos de geoda y el Portal_Vuelta (mirá los marcadores de mapa.py).
Separá el piso ("Isla_Piso", el que se pisa) de la decoración ("Isla_Deco") para que el juego
le ponga colisión solo al piso. ≤ 20.000 triángulos en total.
Comprobación: render desde arriba y a la altura del jugador, y triángulos. Si te la apruebo,
sumala a arte/fbx/Piezas_Juego.fbx. No toques el código del juego.
```

### 10 · Piso de cada zona (losas o textura)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá Losas_Piedra en Deco_Comun.fbx y la
textura de studs que ya usás. Guardá el .blend antes de empezar.
Quiero que el piso de cada zona se vea de bloques con studs, como en arte/referencias/mapa-1.png.
Recomendación: textura y no modelos (un piso de modelos tiene demasiados triángulos para el
celular). Hacé con decoracion.py:
1) Una textura de piso por zona de 512 x 512 que se repita sin cortes: ladrillos con studs en
   2 o 3 tonos (Pradera verde lima con pastito, Dunas arena, Glaciar hielo celeste con nieve,
   Volcán gris oscuro con grietas naranjas, Abismo violeta con puntitos blancos), y otra de
   camino (losas grises más claras). Guardalas en arte/texturas/Piso_<Zona>.png y
   arte/texturas/Piso_Camino.png.
2) "Losa_Borde": tiras de losas de bloques de 1 stud de alto para el borde de los caminos y
   alrededor de los puntos de geoda, 4 piezas que encajan (recta, esquina, curva y final).
Comprobación: render de un cuadrado de 40 x 40 studs de cada zona con su textura, un camino y
las losas de borde, y triángulos de las losas. Si te lo apruebo, sumá Losa_Borde a
Deco_Comun.fbx. No toques el código del juego.
```

### 11 · Plataforma del spawn

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Guardá el .blend antes de empezar.
Ya existe "Spawn" en arte/scripts/lobby.py (piedra y oro, con Spawn_Cristal flotando). Mejoralo
para que sea lo primero que ve un jugador nuevo: plataforma redonda en escalones (en bloques) de
16 studs de diámetro, piedra blanca con studs y un anillo de oro, un mosaico de bloques en el
piso con la forma de una geoda, 4 farolitos de bloques con luz (malla "Spawn_Luz", Neon), y el
cristal grande flotando en el medio (sigue siendo "Spawn_Cristal" aparte, con el pivote en su
centro para que gire). Que tenga una flecha de bloques en el piso apuntando hacia el
Arco_Entrada.
Pivote en el centro de la base, ≤ 5.000 triángulos.
Comprobación: render desde arriba y a la altura del jugador, y triángulos. Si te lo apruebo,
reemplazá Spawn en Lobby.fbx. No toques el código del juego.
```

### 12 · Arco de entrada a la Pradera

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá arte/referencias/ (mapa-1.png y
lobby-1.png). Guardá el .blend antes de empezar.
Ya existe "Arco_Entrada" en arte/scripts/lobby.py (20 de ancho, 3 de fondo, 20 de alto).
Mejoralo para que se note que es la entrada a la Pradera: dos columnas de piedra con musgo y
flores de bloques trepando, el arco de arriba con forma de escalones y una geoda de Pradera
grande en el centro (con sus cristales violetas), enredaderas de hojas cuadradas colgando,
arbustos y racimos de cuarzo en la base, y un cartel vacío colgando del arco (malla
"Arco_Cartel") donde el juego escribe "PRADERA". Mismo tamaño de hueco para que el camino siga
pasando igual.
Pivote en el centro de la base, ≤ 6.000 triángulos.
Comprobación: render de frente y de 3/4, y triángulos. Si te lo apruebo, reemplazá
Arco_Entrada en Lobby.fbx. No toques el código del juego.
```

### 13 · Las 8 mascotas

Una por mensaje: pegá este prompt cambiando la línea de la mascota.

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá arte/referencias/estilo-2.png (la
gallina de bloques). Mirá también GameConfig.Mascotas.Lista para los colores. Guardá el .blend
antes de empezar.
Con arte/scripts/mascotas.py (si no existe, crealo con el mismo estilo que lobby.py), armá la
mascota de abajo: hecha de bloques como la gallina de la referencia, gordita, cabeza grande
(la mitad del cuerpo), ojos de bloques negros con un brillito blanco, patitas cortas. 3 studs
de alto (las raras un poco más grandes, hasta 4). Las partes que se mueven son objetos aparte
con el pivote en la unión: "Cabeza", "PataIzq", "PataDer" y, si tiene, "Cola" y "AlaIzq"/"AlaDer".
Pivote en el centro de la base, frente hacia -Z, ≤ 2.500 triángulos (las legendarias y míticas
hasta 4.000).
MASCOTA: [pegá una línea de la lista]
Comprobación: render de frente, de costado y al lado de un personaje de Roblox para ver el
tamaño, y triángulos. Si te la apruebo, sumala a arte/fbx/Mascotas.fbx y sacá un render
cuadrado de 512 px con fondo transparente para el menú en arte/iconos/mascotas/<Id>.png.
No toques el código del juego.
```

Líneas para pegar (los colores son los que ya usa el juego):

1. `Topito (Común): topo marrón #8A5A2B con nariz y manitos rosas #FFB3C7, un casquito de minero amarillo con una lucecita.`
2. `Piedrin (Común): golem chiquito de piedra gris #8D939C con cristales celestes #7CF5FF en la espalda y ojos que brillan celeste.`
3. `Chispa (Rara): zorrito naranja #FF8C42 con pecho, punta de cola y orejas por dentro crema #FFF3E0, y chispitas en la cola.`
4. `Musgo (Rara): tortuga con caparazón de musgo verde #5E8C4A en escalones con una florcita arriba, y cuerpo marrón #B07A4A.`
5. `Cuarcito (Épica): bichito hecho de cristal violeta #C77DFF medio transparente, con puntas de cristal en la cabeza y centro blanco #FFFFFF que brilla.`
6. `Glaciel (Épica): pingüino azul oscuro #2F5D8A con panza blanca #E8F4FF, bufanda de bloques celeste y cristalitos de hielo en la cabeza.`
7. `Magmo (Legendaria): dragoncito de roca negra con grietas de lava roja #FF3B1F, panza y llamita de la cola amarilla #FFE14D, alitas cortas.`
8. `Nebula (Mítica): gato violeta oscuro #4B2A6B con manchas de estrellitas celestes #7CF5FF que brillan, ojos celestes y un aro de luz flotando arriba de la cabeza (objeto aparte "Aro").`

---

### 14 · Conectar todo al juego (cuando tengas las piezas aprobadas)

```
Hacé un commit de git con todo como está, mensaje "antes de conectar piezas nuevas".
Decime paso a paso cómo importo yo en Studio arte/fbx/Piezas_Juego.fbx, Mascotas.fbx y el
Lobby.fbx nuevo, y dónde los dejo. Después, en GeneradorMapa.luau y Mascotas.client.luau, que
cuando esté el modelo se use el modelo, y si no está siga saliendo lo de ahora: Altar, Cofre,
PuertaSecreta, PuertaZona, Cartel, Portal, Ruleta, Spawn y las 8 mascotas; y las cámaras
secretas, la Isla Prisma y el piso de cada zona en mapa.py. Que todo siga funcionando igual:
mismos tags, atributos, ProximityPrompts, distancias y lo que valida el servidor. Las partes
que se mueven (rueda, tapa del cofre, hojas de la puerta, reja del portón, orbe del altar,
prismas del portal, patas y cabeza de las mascotas) que se animen.
Primero plan corto; cuando lo apruebe, hacelo de a una pieza, probalo con Play y mostrame
capturas en compu y celular. Commit después de cada pieza que funcione.
```
