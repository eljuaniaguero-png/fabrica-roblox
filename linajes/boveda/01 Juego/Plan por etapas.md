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

### En qué orden (los prompts que se usan)
**Arte:**
1. [[P20f Cuerpo propio del jugador]]
2. [[P13 El Albatros]] (traje de NPC)
3. [[P19 NPCs]]: solo Tano
4. [[P20 Enemigos comunes]]: los 3 matones del puerto y el matón con implantes
5. [[P20b Piezas del creador de personaje]]: solo 4 cascos, 4 capas y 4 petos
6. [[P21 Puerto Óxido]] y, de [[P20e Vehículos y objetos de la calle viva]], solo lo del puerto
7. [[P26 Animaciones base del jugador]] (estilo Puños), [[P27 Animaciones de los 3 primeros Linajes]], [[P28 Animaciones de un jefe]] (Remache), [[P29 Animaciones de NPCs y enemigos]] (Tano, el Albatros y los matones) y [[P29b Animaciones de la calle viva]] (civiles y policía)
8. [[P30 Animaciones de objetos]] y [[P30b Efectos especiales e interfaz]]
9. [[P31 Sonidos de combate y menús]] y [[P32 Ambientes y música]] (solo el puerto)
10. [[P33a Logo, ícono y miniaturas (Gemini)]], [[P33b Íconos de Linajes y habilidades (Gemini)]], [[P33c HUD y menús en Figma]] y [[P33 HUD y menús]]

**Código:**
11. [[P34 Base y guardado]] → [[P35 Combate]] → [[P36 Ruleta Linaje, Variante y Rasgos]] (3 Comunes) → [[P36b Creador de personaje y personalización]] (piezas de arriba) → [[P37 Niveles, árbol y Despertar 1 con ramas]] (sin Despertar)
12. [[P38 Diálogos con NPCs, trabajos y reputación]] (Tano y el Albatros) → [[P38c Calle viva civiles, testigos, policía y vigilancia]] → [[P38d Atracos]] (1 atraco) → [[P39 Prólogo tu origen y la Noche del Eclipse]] (1 inicio) → [[P40 Tecnología e implantes]] (sin implantes) → [[P41a Primer hilo hecho a mano Los muelles rojos]]

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
