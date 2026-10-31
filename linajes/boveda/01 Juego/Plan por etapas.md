---
tags: [ficha]
seccion: "9"
---
# Plan por etapas

## Primera versión: solo Puerto Óxido (decisión de Juani, 31 oct). MANDA sobre la tabla de abajo

Antes de hacer las 3 ciudades, se arma **un recorte chico y completo**: un barrio que se juega de punta a punta en 15 minutos y que se ve terminado. Sirve para probar si es divertido, grabar clips y mostrarlo. Recién con eso andando se suman las otras ciudades.

### Qué tiene
| Parte | En la primera versión | Queda para después |
|---|---|---|
| Mapa | **Puerto Óxido** entero: muelles, galpones, grúas, callejones, el taller de Tano y el galpón de Remache. Los puentes a Distrito Corona y Ciudad Vórtice, cortados por la policía. | Distrito Corona, Ciudad Vórtice, Islaroca y el resto |
| Personaje | Cuerpo propio y creador con pocas piezas (4 cascos, 4 capas, 4 petos) | El creador completo |
| Poderes | **Fuerza Bruta, Reflejos y Piroquinesis** (los 3 Comunes, ya tienen prompt), con su Variante Normal y la ruleta con % | Los otros 9 Linajes, Variantes secretas, Despertar |
| Combate | Combo, bloqueo, parry con hit-stop, dash, Z X C, cola de teclas | Definitiva V, segundo poder |
| Tecnología | Taller de Tano: 1 traje y 1 gadget (el gancho) | Implantes, transferencias |
| Calle | Crímenes al azar del puerto, 1 atraco chico (almacén del muelle), policía y testigos básicos | Atracos grandes, noticias completas, territorios |
| Jefe | **Remache** en su galpón (ya está modelado) | El resto de los jefes |
| NPCs | **Tano** (taller) y **El Albatros** (contrabando y trabajos) | Los otros NPCs |
| Historia | Prólogo corto (1 inicio) y el hilo "Los muelles rojos" | El Narrador completo, los 6 inicios |
| Bandos | Elegir bando y lista de jugadores por bando | Barrios entre servidores |

### En qué orden
El orden de los prompts está en [[Todos los prompts]], en la lista **BETA** (con lo que se hace de cada uno entre paréntesis).

**Antes de mostrarlo:** los riesgos de [[Riesgos y mejoras (revisión 31 oct)]] que tocan a esta versión (celular a 45 FPS, primer pelea antes del minuto 5, castigo por desconectarse, un solo botón de acción), analítica de los primeros 10 pasos, y prueba con 2 o 3 jugadores en Local Server.

> [!note] Cuando cada prompt dice "todos los Linajes", "todos los NPCs" o las 3 ciudades, en esta versión se hace solo lo de esta tabla. Lo demás se anota como pendiente.


**Cambio pedido por Juani: primero los modelos, después el código.** Etapa M: hojas de concepto en Claude Design → modelos en ForgeGUI → limpieza en Blender, siguiendo el sistema de diseño Linajes del Eclipse 3D. Se empieza por Cuervo, Centinela Solar, Mascarada, 3 matones y la calle del Puerto Óxido. Después siguen las etapas de código de abajo.

### Plan original (sigue valiendo para después de la primera versión)

| Etapa | Qué queda andando |
|---|---|
| 0 | Carpeta `linajes/`, Rojo, ProfileStore copiado de `archivo/`, Config.luau, CLAUDE.md actualizado |
| 1 | Combate graybox: combo, bloqueo/parry, dash, maniquí + enemigo que avisa y pega. **Si no es divertido, no se sigue.** |
| 2 | Menú con 3 espacios + tirada de Linaje con %, 3 Linajes comunes con Z/X/C |
| 3 | Niveles, árbol (6 nodos por Linaje), guardado |
| 4 | Prólogo de historia + elección de bando + lista de jugadores por bando |
| 5 | Tecnología: taller, traje y 1 gadget |
| 6 | Implantes (3 ranuras) y Carga Cibernética |
| 7 | Capítulo 1 + jefe Remache + Transferencia de su fragmento |
| 8 | Despertar 1 |
| 9 | Arte con ForgeGUI (ciudad, enemigos, íconos, sonidos) y prueba con amigos |
| 10 | Analytics, celular, publicar beta |

Volver a [[Ficha del juego]]
