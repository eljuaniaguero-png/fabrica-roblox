---
tags: [ficha, cinematicas]
---
# Cinemáticas (plan completo)

Todas las escenas cortas donde el juego toma la cámara: al entrar, al salir, con los jefes, con los NPCs, al despertar un poder y en la historia. Manda sobre la sección 12 de [[Animaciones (plan completo)]].

## Reglas para todas
- **Cortas:** de 3 a 12 segundos. Solo el prólogo y los finales llegan a 30 o 40.
- **Se pueden saltear:** la primera vez, después de 2 segundos; las siguientes, enseguida. Las que se repiten (entrar a una ciudad, reaparecer) se acortan solas la segunda vez.
- **Multijugador:** casi todas son **solo para vos** (tu cámara, tu pantalla) y el resto del servidor sigue jugando. Mientras dura, nadie te puede pegar ni vos podés pegar. Las de jefe se ven **todos los que están en la arena**, y el jefe espera quieto hasta que terminan.
- **Formato:** franjas negras arriba y abajo, subtítulos abajo (el texto también sirve de doblaje leído), el HUD se esconde, y la música y el sonido bajan o cambian. En celular se ven igual, con el botón "Saltear" grande.
- **Cómo se hacen:**
  - Los cuerpos se mueven con animaciones de Blender (las de [[Animaciones (plan completo)]] o una propia de la escena).
  - **La cámara también se anima en Blender**: un script exporta su recorrido a un archivo de datos (`linajes/arte/cinematicas/<escena>.json`) y Studio lo reproduce tal cual.
  - En Studio, un solo módulo (`linajes/src/client/cinematicas/`) toca cualquier escena desde sus datos: cámara, animaciones, subtítulos, sonidos, efectos y marcadores (`Golpe`, `Destello`, `Sacudida`).
  - Los textos van en `Config.luau`, para poder cambiarlos sin tocar el código.
- **El juego no explica:** en las escenas de poderes y Variantes se ve qué pasa, pero nunca se dice qué hace (regla de [[Poderes, inicio y personalización]]).

## 1. Entrar al juego (6)
| Escena | Duración | Qué se ve |
|---|---|---|
| Logo | 4 s | El eclipse se cierra sobre la bahía y aparece el logo. Solo la primera vez del día. |
| Menú | loop | La cámara gira lento alrededor de tu personaje, con el eclipse atrás. |
| Elegir espacio | 2 s | La cámara pasa de un personaje al otro. |
| Llegar a la ciudad | 6 s | Bajás de un ferry en Puerto Óxido (o de un tren en Corona, o del subte en Vórtice) y la cámara se pone detrás tuyo. |
| Volver al juego | 2 s | Tu personaje se estira y mira la ciudad. |
| Volver después de días | 5 s | Lucía Vega te cuenta en 2 frases qué pasó en la ciudad mientras no estabas (sale de la Crónica). |

## 2. Salir, perder y volver a aparecer (8)
| Escena | Duración | Qué se ve |
|---|---|---|
| Salir del juego | 3 s | Tu personaje saluda o se sube la capucha, y "Progreso guardado". |
| Derrota | 3 s | Cámara lenta, cae, y la pantalla se oscurece. |
| Reaparecer | 3 s | Despertás en la clínica de Kessler o en tu refugio. |
| Te arrestan | 5 s | Esposas, patrullero y la puerta de la celda que se cierra. |
| Islaroca | 6 s | Llegás en lancha al penal bajo la lluvia. |
| Escapar de Islaroca | 6 s | Saltás el muro y caés al agua. |
| Viaje rápido | 2 s | Fundido con una toma aérea del destino. |
| Entrar a tu refugio | 3 s | Se abre la puerta y se encienden las luces de a una. |

## 3. Jefes (por jefe: 5)
| Escena | Duración | Qué se ve |
|---|---|---|
| Entrada | 8 s | Presentación con el nombre en pantalla grande, su tema musical y algo que muestra cómo pelea. Remache rompe la pared del galpón y sus pistones echan vapor. |
| Cambio de fase | 4 s | El jefe cambia: a Remache se le rompen los tubos rojos; Mascarada gira el sombrero y cambia de máscara. |
| Golpe final | 3 s | Cámara lenta en el último golpe, con un destello en el color de tu Linaje. |
| Derrota | 6 s | El jefe cae de rodillas. Después, la decisión de la historia: entregarlo o dejarlo ir. |
| Botín | 3 s | Suelta su Fragmento de Linaje, que flota hacia vos. |

Para la primera versión: Remache. Después, los otros 9 jefes de [[Animaciones (plan completo)]] (sección 10).

## 4. NPCs e interacciones (unas 25)
- **Conocer a cada NPC con nombre** (7, de 6 s): Tano sale de abajo de un auto con la llave inglesa, Vega te saca una foto, Rivas te mira por encima de los papeles, etc. Solo la primera vez.
- **Elenco** (16, de 5 s): la primera vez que ves a Cuervo, Centinela, Estela y los demás aparecer en la ciudad.
- **Entrar a un bando** (4, de 6 s): ceremonia corta en la base del bando (el Faro Orbital, el Nido, la Fundición o un callejón para los neutrales).
- **Tecnología:** primer traje fabricado (5 s), instalar un implante en la camilla de Kessler (6 s), transferencia de Linaje con Brandt (8 s).
- **Calle:** empieza un atraco (4 s, la alarma y la cámara de seguridad que te mira), termina el atraco (4 s), llegás a búsqueda 5 (4 s, el helicóptero te ilumina), tu cara sale en la tapa de El Faro (3 s).

## 5. Poderes (unas 60)
| Escena | Cuántas | Duración | Qué se ve |
|---|---|---|---|
| Te toca un Linaje en la ruleta | 5 (una por rareza) | 4 a 8 s | Común: el poder te sale de las manos. Poco común: una onda alrededor. Raro: te elevás. Legendario y Mítico: el eclipse se abre en el cielo y **todo el servidor ve un aviso**. |
| Despertar 1 | 12 (una por Linaje) | 10 s | Pelea contra tu sombra, el poder te envuelve, tu aspecto cambia y aparece el nombre de la rama que elegiste (sin explicar). |
| Despertar 2 | 12 | 12 s | Igual, más grande, con el eclipse detrás. |
| Mutación de Variante | 12 | 6 s | El poder se quiebra y vuelve distinto (otro color u otra forma). Solo aparecen el nombre y "???". |
| Segundo poder | 1 | 8 s | Los dos poderes chocan en tus manos y se mezclan. |
| Técnica combinada descubierta | 12 | 5 s | La primera vez en el servidor: aviso a todos con el nombre de quien la descubrió. |
| Definitiva | 12 | 2 s | Toma corta de cámara antes de la definitiva (se puede apagar en Ajustes). |

## 6. Historia (unas 35)
- **Prólogo "La Noche del Eclipse"** (6 inicios, de 30 s): cada uno muestra de dónde venís y el eclipse que despierta tu poder.
- **Fin de un hilo** (1 por hilo, de 6 s), como "Los muelles rojos", que termina con Remache.
- **Revelaciones del misterio** (8, de 10 s): cada vez que juntás los Fragmentos de una Revelación.
- **La agenda de los villanos** (1 por semana, de 6 s): el lunes, el villano de la semana anuncia su plan en las pantallas de la ciudad.
- **Final de acto** (6) y **finales por bando** (3 por bando, de 30 a 40 s).
- **Renacer** (8 s): tu personaje deja su traje en el refugio y empieza de nuevo.

## 7. Mundo y eventos del servidor (8, para todos)
Apagón (las luces de la ciudad se apagan barrio por barrio), Lluvia de esquirlas, Fuga del penal (sirenas, reflectores), Invasión de Umbra (se abre el portal), un bando conquista un barrio (cambian las banderas), el eclipse de cada noche (la cámara mira al cielo 2 s, solo la primera vez).

---

## Total aproximado
**Unas 170 escenas.** La mayoría reusa animaciones que ya existen: lo nuevo de cada una es la cámara, los subtítulos y el sonido.

## Cuáles van en la Beta (Puerto Óxido)
Logo, menú, elegir espacio, llegar en ferry al puerto, volver al juego, salir, derrota y reaparecer, te arrestan (celda de la comisaría del puerto), las 5 de **Remache**, conocer a **Tano** y al **Albatros**, primer traje, empieza y termina el atraco, la ruleta (Común), el prólogo (1 inicio) y el fin del hilo "Los muelles rojos". **Son unas 22.**

## En qué orden
1. [[P30c Cinemáticas]] arma el módulo que toca escenas y hace las de la Beta, después de que existen las animaciones (Fase E) y los sonidos (Fase F).
2. Las de la Post beta se hacen con el mismo prompt, al terminar cada parte que las necesita (un jefe nuevo, un Linaje nuevo, un acto).

Volver a [[Ficha del juego]]
