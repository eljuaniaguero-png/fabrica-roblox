# Forja Rápida: prompts del lobby (17 oct 2026)

Para Juani. El lobby es la plaza del principio. Acá van un prompt por cada cosa: la ruleta, el puesto para vender, la tienda para comprar y tu exhibición, más el piso y la entrada. Todo lo hace Claude en Blender con el mismo estilo de bloques.

## Antes de empezar

1. Guardá tus 2 capturas en tu PC en `forja-rapida/arte/referencias/` como `lobby-1.png` (el puesto VENDER) y `lobby-2.png` (la exhibición con pedestales).
2. Blender abierto y el complemento de Claude conectado. Un prompt por vez, con `/clear` entre uno y otro.
3. Orden recomendado: puesto de vender → tienda → exhibición → ruleta → piso y entrada → montar el lobby → (después) el dinero por segundo.

## Ojo: la exhibición que da dinero es nueva

Hoy el juego tiene **vitrinas para mostrar** tus gemas a los demás, pero **no dan dinero**. Hacer el modelo no cambia eso. El último prompt ("Exhibición que da dinero por segundo") es el que lo agrega al juego, y pide plan antes de tocar nada.

---

## 1. Puesto para vender (el Banco)

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá el "Puesto_Vender", copiando la forma de lobby-1.png:
un puestito de feria de 10 x 8 studs: 4 postes gruesos de ladrillo marrón, techo a dos aguas
rojo con borde que sobresale, mostrador de ladrillo marrón al frente, un cartel colgado de dos
cadenitas debajo del techo y una alfombra roja de bloques en el piso adelante (es donde se
para el jugador para vender; que brille apenas en el borde). Atrás del mostrador, un lugar
para el vendedor y una balanza dorada de bloques encima del mostrador.
≤ 4.000 triángulos.
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

## 2. Tienda para comprar (Fuerza, amuletos y picos)

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá la "Tienda_Forja": una herrería de bloques de 14 x 10 studs, más grande que el puesto de
vender y de otro color para no confundirlas: techo azul con studs, postes de piedra gris,
un yunque negro y un horno de ladrillo con fuego naranja que brilla adentro a un costado.
Al frente, un mostrador de madera con 3 estantes cortos atrás donde se ven 3 picos colgados
y 3 amuletos chiquitos (cada uno como pieza aparte para que el juego muestre los que tenés
para comprar). Cartel colgado arriba y alfombra azul adelante.
≤ 6.000 triángulos.
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

## 3. Tu exhibición (la parcela de cada jugador)

Son 2 piezas: la parcela y el pedestal (se repite).

### 3a. Pedestal

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá el "Pedestal_Exhibicion", como los de lobby-2.png: una base cuadrada de 4 x 4 studs y
1,5 de alto, de madera clara con un borde marrón oscuro abajo y arriba, y la tapa crema
donde se apoya la gema. Al frente, separado, un botón verde plano de 3 x 2 studs en el piso
(es donde el jugador pisa para poner o sacar la gema). Hacé 3 versiones del pedestal:
madera (las primeras), piedra con borde dorado (desbloqueables) y cristal con luz (las
mejores).
≤ 800 triángulos cada pedestal.
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

### 3b. Parcela

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá la "Parcela_Exhibicion", copiando la forma de lobby-2.png: un terreno de 40 x 32 studs
un escalón más alto que el piso, color arena con studs, un camino naranja en el medio que
va de la entrada al fondo, y a cada lado una fila de 5 lugares marcados para pedestales
(10 en total; dejá un punto vacío con nombre Lugar01 a Lugar10 donde va cada pedestal).
Borde de ladrillo marrón oscuro todo alrededor, un arco de entrada chiquito y, al lado de
la entrada, un cartel de madera grande para el nombre del dueño (como el que dice
"Ninguno"). Al fondo, un cofre o una caja registradora dorada de bloques con un botón verde
adelante: es donde se cobra la plata juntada.
≤ 6.000 triángulos (sin contar los pedestales).
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

## 4. Ruleta de mascotas

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá la "Ruleta_Mascotas": un escenario de bloques de 16 x 10 studs con 2 escalones adelante,
y arriba una rueda grande parada de 12 studs de diámetro sobre un soporte de ladrillo.
La rueda va como pieza aparte llamada "Rueda" (el juego la hace girar), con el centro
dorado y el borde de bloques blancos; las porciones NO las pintes: el juego las dibuja según
la chance de cada mascota. Arriba de la rueda, una flecha roja de bloques que marca el
premio (pieza fija). Focos de colores en el borde del escenario que brillan, y 2 pedestales
chiquitos a los costados para mostrar mascotas. Alfombra violeta adelante.
≤ 6.000 triángulos.
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

## 5. Piso y entrada del lobby

```
Leé forja-rapida/arte/estilo-bloques.md si existe. Mirá forja-rapida/arte/referencias/
(lobby-1.png y lobby-2.png). Guardá el .blend antes de empezar.
En Blender, con forja-rapida/arte/scripts/lobby.py (si no existe, crealo con el mismo estilo
que rocas.py), armá el "Arco_Entrada": un arco grande de bloques de 20 studs de ancho por donde se pasa del
lobby a la zona 1, con columnas de ladrillo gris, la parte de arriba en escalones con un
lugar para cartel en el medio y 2 antorchas de bloques a los costados.
Y el "Spawn": una plataforma redonda en escalones (3 anillos) de 12 studs, piedra clara con
un borde dorado y un cristal flotando arriba que brilla.
≤ 4.000 triángulos cada uno.
Reglas: todo de bloques con studs como textura (nunca modelados), colores planos de la guía,
pivote en el centro de la base, escala de Roblox. Carteles sin texto en el modelo: el texto lo
pone el juego encima (así se puede traducir y cambiar).
Comprobación: render de frente y de costado al lado de la referencia, y triángulos.
Si te lo apruebo, sumalo a arte/fbx/Lobby.fbx. No toques el código del juego.
```

## 6. Montar el lobby (cuando estén todas las piezas)

```
Leé la sección "Mapa" de ideas/forja-rapida.md. Rearmá la plaza del lobby con las piezas de
arte/fbx/Lobby.fbx: el Spawn en el centro, el Puesto_Vender y la Tienda_Forja a la vista
apenas aparecés (uno a cada lado, para que el jugador nuevo los encuentre), la Ruleta al
fondo, el Arco_Entrada hacia la zona 1, y las parcelas de exhibición en fila a un costado
(una por jugador del servidor, con sus 10 pedestales). Respetá lo que ya está en la plaza
(Museo, tableros, Santuario del Renacer, lugar del Jefe Ancestral) y que la flecha del
jugador nuevo siga funcionando. Cambio mínimo en mapa.py o GeneradorMapa; si el FBX no está
importado en Studio, que siga como está. Decime los pasos para importar.
Probalo con Play y mostrame capturas en compu y en celular.
```

## 7. Exhibición que da dinero por segundo (cambia el juego)

```
Quiero que cada jugador tenga su exhibición en el lobby (la Parcela_Exhibicion con 10
pedestales): pone sus gemas más valiosas en los pedestales y cada gema le da monedas por
segundo según su valor y rareza. La plata se junta en la caja del fondo y se cobra pisando
el botón verde. Las primeras 3 pedestales vienen abiertas y las otras se compran con monedas.
Primero plan, sin cambiar nada: cómo encaja con las vitrinas que ya existen (¿las reemplaza?),
cuánto da cada rareza por segundo sin romper la economía (que no convenga más esperar que
romper geodas), qué pasa cuando no estás conectado, cómo se guarda y qué tiene que validar el
servidor. Cuando apruebe el plan, hacelo y probalo con Play.
Actualizá ideas/forja-rapida.md.
```
