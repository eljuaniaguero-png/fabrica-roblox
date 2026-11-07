---
tags: [ficha]
---
# Cuerpo propio (sin avatar de Roblox)

> [!important] Cambio de Juani (30 oct). Manda sobre todo lo que diga "avatar"
> El juego **no usa el personaje de Roblox** del jugador. Todos (jugadores, NPCs, enemigos) usan el **cuerpo propio de Linajes**, que se arma en el creador de personaje.

> [!important] Cuerpo oficial (Juani, 6 nov): cómic urbano
> El cuerpo, los peinados y las caras viejos se descartan (quedan en git). El personaje de pelo en puntas y campera azul con cuello rojo es el cuerpo oficial.
> - **Corrección (Juani, 6 nov):** su ropa NO es el atuendo inicial. Es el **primer conjunto comprable (Urbano)**, con plata del juego. Todos arrancan con un atuendo básico. El pelo y la cara se eligen gratis. Ver [[Ropa y tienda]].
> - Mismo esqueleto R15 de 15 partes: `linajes/arte/blender/cuerpo.blend` queda solo como fuente del esqueleto.
> - Modelo: `linajes/arte/blender/cuerpo-comic.blend`, hecho con `scripts/personajes/cuerpo_comic.py`.
> - Piezas con color propio: Cuerpo, Remera, Campera (incluye cuello), Cinturon, Pantalon, Zapatillas. FBX en `linajes/arte/exports/cuerpo-comic/`.
> - 3 peinados: Puntas, Flequillo y Cresta. 3 caras en `exports/cuerpo-comic/caras/`.
> - Falta pasarlo a Studio: `StarterCharacter` todavía usa el cuerpo viejo.

> [!important] Acabado elegido por Juani (6 nov): A, cómic urbano
> Manda sobre el acabado anterior. Mismo esqueleto R15 y mismas animaciones. Muestra: `linajes/arte/renders/muestra-personajes-frente.png`.
> - Bloques rectos, con muy poco redondeo.
> - Ropa en capas: al menos 3 zonas de color y una prenda grande.
> - Pelo filoso, más grande que la cabeza.
> - Cara fina con cejas y ojos angulosos.
> - Borde negro marcado si rinde bien en celular; si no, se resuelve con textura.
> - Referencias: [[Referencias de personajes]].

## Cómo es
- **Mismo esqueleto R15** que el maniquí del kit. Por eso los trajes que ya hicimos (Cuervo, Centinela, Mascarada, Remache) y todas las animaciones sirven sin rehacerlos.
- El cuerpo lo hace Claude en Blender, con el estilo de la [[Guía de estilo]]. **Estilo (Juani, 31 oct):** el cuerpo de bloques de Roblox tal cual (piezas R15 del maniquí) con cabeza clásica, remera de manga corta y pantalón como ropa clásica, cara anime (delineado grueso en punta, iris grande, cejas finas, nariz con sombra y brillo) y pelo de mechones en capas y en punta. Referencias en `arte/referencias/anime/` (de otro juego: solo ideas). El detalle sigue estando en el traje.
- Presupuesto: **cuerpo 4.000 a 6.000 triángulos** (cabeza, torso, brazos, piernas), más pelo de 1.000 a 2.000.

## Qué elegís en el creador
| Opción | Cuántas |
|---|---|
| Contextura | 3: normal, ancha, delgada (cambia el ancho de hombros y cadera, no los huesos) |
| Altura | 3: baja, media, alta (escala de 0,95, 1 y 1,05) |
| Tono de piel | 10 |
| Cara (ojos, cejas, boca) | 3 texturas por ahora (meta: 12), con expresiones animadas (ver [[Animaciones (plan completo)]]) |
| Pelo | 3 peinados por ahora (meta: 12) + color libre |
| Cicatrices y marcas | 6, opcionales |
| Traje | las piezas de [[Poderes, inicio y personalización]] (cascos, capas, petos, etc.) |

## Cómo se hace en Roblox (para Claude)
- `StarterPlayer.StarterCharacter` con el cuerpo propio: Roblox ya no carga el avatar del jugador.
- Al aparecer, el servidor arma el cuerpo con lo que el jugador eligió (guardado en sus datos) y suelda las piezas del traje a sus huesos.
- El script `Animate` de Roblox se reemplaza por el nuestro, con todas las animaciones propias. Los paquetes de animación y los gestos del avatar no se usan.
- En el teléfono, los carteles de "Buscado" y la lista de jugadores, la cara que se ve es la del personaje del juego, no la foto del avatar.
- Los jefes grandes (Remache a 1,6x, El Eclipsador) usan el mismo esqueleto escalado o un esqueleto propio.

Volver a [[Ficha del juego]]

## Peinados aprobados (7 nov)

| Peinado | Forma | Triángulos | Archivo |
|---|---|---|---|
| **Puntas** | Mechones finos y 6 puntas grandes hacia arriba y atrás | 2.840 | `PeloPuntas.fbx` |
| **Corto** | Mechones anchos, sin puntas | 2.136 | `PeloCorto.fbx` |
| **Flequillo** | Mechones anchos con flequillo sobre los ojos | 2.136 | `PeloFlequillo.fbx` |

- La forma es el peinado; el color lo elige el jugador. Azul por defecto: `#4468AE`.
- La textura es gris casi blanca y el juego la tiñe con `SurfaceAppearance.Color`.
- Script: `arte/scripts/personajes/pelo_hebras.py`. Reemplazan a los peinados Puntas, Flequillo y Cresta de antes cuando pasen a Studio.
- Pendiente: los tres pasan el tope de 2.000 triángulos de la guía; hay que recortarlos o subir el tope.

## Zapatillas (7 nov)

Una malla cerrada por pie (168 triángulos): suela continua y capellada, con punta apenas redondeada. Línea de suela y cordones van en la textura `blender/texturas/zapatillas/Zapatillas_color.png`. El dobladillo del pantalón termina arriba de la zapatilla. Pendiente: que el jugador pueda teñir la capellada.
