# Referencias de jefes

> Solo para ideas: se toma la mecánica, nunca personajes, escenarios ni imágenes. Las hojas de cuadros están en `imagenes/jefes/` y no van a git.

Revisión del 7 de noviembre de 2026, antes de animar a [[Remache]].

## Qué se miró

- **Deepwoken:** pelea contra Knell.
- **Elden Ring:** Commander O'Neil y una secuencia de tres martillazos.
- **Design Doc:** video de diseño de jefes, primera parte de los subtítulos.
- **Artículos:** Game Developer, Game Maker's Toolkit, DevForum de Roblox y notas de diseño.
- Se bajaron también Shogun (Deepwoken) y Beastman (Elden Ring), sin revisar a fondo.

## Lo que se repite

1. **Cada ataque avisa de una forma propia.** La preparación se distingue a simple vista, así el jugador aprende a leerla.
2. **El aviso no depende solo del cuerpo.** Conviene sumar marca en el piso, sonido y color. En Roblox la cámara suele estar lejos y arriba.
3. **La duración del aviso define la dificultad.** Más largo es más fácil. Si el jugador mata antes de que termine, el aviso no sirve.
4. **Los golpes dejan el piso marcado.** En Knell se ven anillos y rayos; en los martillazos, grietas y círculos que crecen.
5. **Los ataques en cadena cambian el ritmo.** Dos golpes iguales y un tercero distinto castigan al que memoriza mal.
6. **Hay una ventana para pegarle.** Después de un ataque grande, el jefe queda expuesto.
7. **El cambio de fase es corto y tiene firma propia.** Unos segundos, con un sonido o efecto que solo usa ese jefe.
8. **La fase nueva cambia la pelea.** Suma ataques o peligros; no alcanza con más vida y daño.
9. **Las reglas no se rompen.** Un ataque sin aviso se siente injusto.
10. **Un jefe cumple un rol:** prueba de habilidad, momento de historia o cambio de ritmo.

## Cómo aplica a Remache

| Parte | Idea |
|---|---|
| Martillazo doble | Puños bien arriba y quietos un instante; círculo de 10 studs en el piso durante el aviso; grietas después |
| Carga hidráulica | Pistones que se comprimen y línea marcada de 30 studs; al frenar queda expuesto |
| Contenedor | Levantarlo ya es el aviso: 40 cuadros; zona marcada donde va a caer |
| Cambio de fase | Inyección y vapor en pocos segundos; que suene distinto a todo lo demás |
| Fase 2 | Encadenar ataques, no solo acelerarlos |

## Para decidir

- ¿Cuánto dura cada aviso en la fase 1 y en la 2? El prompt pide 12 cuadros (0,4 s), que es poco para un ataque grande. La [[Guía de estilo]] usa 0,4 s para el brillo rojo del piso: se puede sumar la pose larga antes de ese brillo.

## Fuentes

- [Enemy attacks and telegraphing](https://gamedeveloper.com/design/enemy-attacks-and-telegraphing)
- [How to design enemy attack telegraphs](https://bugnet.io/blog/how-to-design-enemy-attack-telegraphs)
- [How to design a boss that teaches its own pattern](https://bugnet.io/blog/how-to-design-a-boss-that-teaches-its-own-pattern)
- [How Cuphead's Bosses Try to Kill You](https://amara.org/subtitles/TbmQ6Ac3Z6pb/en/1/download/How%20Cupheads%20Bosses%20Try%20to%20Kill%20You%20%20Game%20Makers%20Toolkit.en.srt)
- [Crafting Legendary Boss Battles](https://www.wayline.io/blog/crafting-legendary-boss-battles)
- [Design deep dive: Angelical Echo boss fight](https://www.gamedeveloper.com/design/design-deep-dive-angelical-echo-boss-fight)
- [Making Boss Battles Correctly (DevForum)](https://devforum.roblox.com/t/making-boss-battles-correctly/861910)
- [Boss Fight System (DevForum)](https://devforum.roblox.com/t/5-attacks-boss-fight-system-control-bosses-from-1-script-easy-customization-free-premade-abilities-and-more/4039013)
- [Knell, Deepwoken](https://www.youtube.com/watch?v=SD-H3x5Nbd8)
- [Shogun, Deepwoken](https://www.youtube.com/watch?v=QrCPJjHlIHE)
- [Triple Hammer Slams, Elden Ring](https://www.youtube.com/watch?v=s48tEVm4Z6I)
- [Commander O'Neil, Elden Ring](https://www.youtube.com/watch?v=B05tAR6oZYM)
- [Beastman of Farum Azula, Elden Ring](https://www.youtube.com/watch?v=vtoQZh5dhfQ)
- [Boss Battle Design, Design Doc](https://www.youtube.com/watch?v=wUPugc51udc)
