---
tags: [plan]
---
# Plan de reescritura de la bóveda (1 nov 2026)

Pedido de Juani: que **todos los prompts** sean muy específicos, hasta el mínimo detalle; que cada uno traiga **al menos 2 prompts para Gemini** que armen imágenes de referencia; **depurar lo viejo** de la bóveda y **actualizar todo con mucha información** (historia, Linajes, NPCs, modelos, todo), muy explicado.

## Lo que hay hoy
- 109 notas: 22 del juego, 6 de estilo, 65 prompts, 13 carpetas de personajes, `Progreso` (viejo, del 30 oct), `00 Inicio` (novedades del 31 oct) y una nota suelta `Linajes/Bienvenido.md` (la que crea Obsidian por defecto).
- La ficha (`ideas/ficha.md`, unas 15.700 palabras) tiene secciones nuevas que **mandan** sobre las viejas (0b a 0h). En la bóveda conviven las dos versiones y eso confunde.
- Los prompts son de 10 a 30 líneas. Faltan medidas exactas por pieza, criterios para aprobar y las reglas de Roblox de hoy (escala, choques, `Neon_`, chequeo de cruces).

## Cómo va a quedar

### 1. Depurar (sin borrar nada)
- Todo lo viejo o pisado por decisiones nuevas pasa a `99 Archivo/`, con una línea arriba que dice qué lo reemplazó y cuándo. Nada se borra; se puede volver atrás.
- Cada tema queda en **una sola nota**, la vigente. Si la ficha dice "MANDA sobre…", la nota vieja se archiva.
- `Progreso` y `00 Inicio` se rehacen con el estado real de hoy: qué está hecho, qué está a medias y qué sigue.
- Se borra `Linajes/Bienvenido.md` (es la nota de ejemplo de Obsidian, no tiene nada nuestro). **Es lo único que se borra.**

### 2. La información del juego, muy explicada
Carpetas nuevas, una nota por cosa:

| Carpeta | Qué tiene |
|---|---|
| `01 Juego` | Qué es el juego, el bucle de juego minuto a minuto, combate, progresión, reputación, calle viva, economía y monetización. |
| `05 Historia` | El mundo y su pasado, el Eclipse, los 6 orígenes, los arcos de cada ciudad, "Los muelles rojos" paso a paso, el Narrador y los ganchos, las Revelaciones y la agenda de los villanos. |
| `06 Linajes` | Una nota por Linaje (12): rareza y %, de dónde viene, las 4 Variantes, las habilidades Z/X/C/V con números, el árbol, el Despertar, los colores del poder, los efectos y las animaciones que necesita. |
| `07 NPCs` | Una nota por NPC con nombre: quién es, cómo se ve (con colores), cómo habla (frases de ejemplo), dónde está, qué te da, sus misiones, la confianza y su secreto. |
| `04 Personajes` | Una nota por modelo: estado, triángulos, renders, modelo 3D para girar y en qué prompt se hizo. |
| `08 Lugares` | Una nota por zona e interior: medidas, barrios, qué hay, quién manda, crímenes, marcadores para el código. |

Cada nota arranca con un resumen de 3 líneas y después va al detalle. Al final tiene los enlaces a todo lo relacionado.

### 3. Prompts nuevos (plantilla única)
Cada prompt tiene estas partes, siempre en el mismo orden:
1. **Para qué es** (2 líneas) y **qué tenés que tener abierto**.
2. **Qué leer antes** (notas y archivos, con enlaces).
3. **Referencias para Gemini**: **2 prompts como mínimo**, listos para copiar. Uno de la vista general (la habitación, el personaje entero o el lugar) y otro de detalle (materiales, piezas o expresiones). Si sirve, uno más de colores y luz. Van en inglés, que es como mejor responde Gemini, con una línea en castellano que explica qué tiene que salir. Todos con reglas fijas: diseño propio, nada de DC ni de otros juegos, sin texto ni logos, el estilo de nuestra guía y una figura de escala de Roblox.
4. **El bloque para Claude**: cada pieza con sus medidas exactas en studs, la posición, la forma, el material, el color en hex, el tope de triángulos y si brilla, se mueve o choca.
5. **Reglas de Roblox** que aplican (escala, `_Colision`, `Neon_`/`Glass_`, pivote, caras ocultas, chequeo de cruces y de cosas flotando).
6. **Pasos con lo que tiene que estar bien para que des el OK** (por ejemplo: "ninguna pieza se cruza", "debajo de 60.000", "4 renders con luz").
7. **Qué se entrega** (archivos, Obsidian, commit) y **cómo lo probás vos**.

### 4. Orden de trabajo
1. **Tanda 1**: plantilla, depuración, `00 Inicio`, `Progreso` y estilo actualizado (con las reglas de Roblox y lo aprendido con el taller: piezas largas y la memoria del horneado).
2. **Tanda 2**: historia completa (`05 Historia`).
3. **Tanda 3**: los 12 Linajes (`06 Linajes`).
4. **Tanda 4**: NPCs y personajes (`07 NPCs` y `04 Personajes`).
5. **Tanda 5**: lugares (`08 Lugares`).
6. **Tanda 6**: los prompts que faltan de la **Beta** (unos 25), reescritos con la plantilla y sus prompts de Gemini.
7. **Tanda 7**: los prompts del **Post Beta**.
8. **Tanda 8**: los prompts **ya hechos**, actualizados con cómo quedaron (como registro).

Después de cada tanda: commit y una revisión tuya en Obsidian antes de seguir.

## Decisiones de Juani (1 nov)
- **Lo viejo se borra** (no se archiva). Queda en el historial de git por si hace falta.
- **Prompts de Gemini en inglés**, con una línea en castellano que explica qué tiene que salir.
- **El taller de Tano se rehace** con el prompt nuevo: primero las imágenes de Gemini y después el modelo.

Volver a [[00 Inicio]]
