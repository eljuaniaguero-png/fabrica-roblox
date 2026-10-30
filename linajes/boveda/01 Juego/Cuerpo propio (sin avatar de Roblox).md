---
tags: [ficha]
---
# Cuerpo propio (sin avatar de Roblox)

> [!important] Cambio de Juani (30 oct). Manda sobre todo lo que diga "avatar"
> El juego **no usa el personaje de Roblox** del jugador. Todos (jugadores, NPCs, enemigos) usan el **cuerpo propio de Linajes**, que se arma en el creador de personaje.

## Cómo es
- **Mismo esqueleto R15** que el maniquí del kit. Por eso los trajes que ya hicimos (Cuervo, Centinela, Mascarada, Remache) y todas las animaciones sirven sin rehacerlos.
- El cuerpo lo hace Claude en Blender, con el estilo de la [[Guía de estilo]]. Es más proporcionado que el de bloques de Roblox, pero simple: el detalle sigue estando en el traje.
- Presupuesto: **cuerpo 4.000 a 6.000 triángulos** (cabeza, torso, brazos, piernas), más pelo de 1.000 a 2.000.

## Qué elegís en el creador
| Opción | Cuántas |
|---|---|
| Contextura | 3: normal, ancha, delgada (cambia el ancho de hombros y cadera, no los huesos) |
| Altura | 3: baja, media, alta (escala de 0,95, 1 y 1,05) |
| Tono de piel | 10 |
| Cara (ojos, cejas, boca) | 12 texturas, con expresiones animadas (ver [[Animaciones (plan completo)]]) |
| Pelo | 12 peinados + color libre |
| Cicatrices y marcas | 6, opcionales |
| Traje | las piezas de [[Poderes, inicio y personalización]] (cascos, capas, petos, etc.) |

## Cómo se hace en Roblox (para Claude)
- `StarterPlayer.StarterCharacter` con el cuerpo propio: Roblox ya no carga el avatar del jugador.
- Al aparecer, el servidor arma el cuerpo con lo que el jugador eligió (guardado en sus datos) y suelda las piezas del traje a sus huesos.
- El script `Animate` de Roblox se reemplaza por el nuestro, con todas las animaciones propias. Los paquetes de animación y los gestos del avatar no se usan.
- En el teléfono, los carteles de "Buscado" y la lista de jugadores, la cara que se ve es la del personaje del juego, no la foto del avatar.
- Los jefes grandes (Remache a 1,6x, El Eclipsador) usan el mismo esqueleto escalado o un esqueleto propio.

Volver a [[Ficha del juego]]
