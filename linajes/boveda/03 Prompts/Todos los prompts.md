---
tags: [prompts]
---
# Todos los prompts

Uno por sesión, en este orden. Cuando termina uno, mirás los renders o probás, y recién ahí pasás al siguiente. Marcá la casilla cuando lo apruebes.


## Fase A. Preparar

- [x] [[P01 Carpeta del juego y reglas de estilo]]

## Fase B. Kit base en Blender (una vez)

- [x] [[P02 Maniquí R15, materiales, luz y scripts base]]

## Fase C. Trajes de los personajes (uno por sesión)

Cada prompt sigue el mismo orden: **1) boceto de bloques → aprobar silueta, 2) detalle → aprobar, 3) exportar**. No se pasa al detalle sin tu OK.

- [ ] [[P03 Cuervo]]
- [x] [[P04 Centinela Solar]]
- [x] [[P05 Mascarada]]
- [x] [[P06 Remache]]
- [ ] [[P07 Estela]]
- [ ] [[P08 Atalanta]]
- [ ] [[P09 Arquitecto]]
- [ ] [[P10 Bastión]]
- [ ] [[P11 Heredero Abisal]]
- [ ] [[P12 Víctor Halden]]
- [ ] [[P13 El Albatros]]
- [ ] [[P14 Zarpa]]
- [ ] [[P15 Confeti]]
- [ ] [[P16 Dualidad]]
- [ ] [[P17 Gorrión]]
- [ ] [[P18 El Eclipsador]]
- [ ] [[P19 NPCs]]
- [ ] [[P20 Enemigos comunes]]
- [ ] [[P20b Piezas del creador de personaje]]
- [ ] [[P20d Civiles y testigos]]
- [ ] [[P20e Vehículos y objetos de la calle viva]]

## Fase D. Lugares en Blender (kits modulares)

- [ ] [[P20c Mapa del mundo abierto]]
- [ ] [[P21 Puerto Óxido]]
- [ ] [[P22-25 Los otros lugares]]
- [ ] [[P25d Interiores donde se puede entrar]]

## Fase E. Animaciones (las hace Claude en Blender)

**Cómo se hacen:** Claude anima en Blender sobre el esqueleto R15 del maniquí (o el rig propio del jefe), a **30 cuadros por segundo**, con un script por animación en `linajes/arte/scripts/animaciones/`. Exporta FBX a `linajes/arte/animaciones/`. Después, en Studio: **Animation Editor → ⋯ → Import → From FBX Animation**, y **Publish to Roblox**. Ese último botón lo tenés que tocar vos (Roblox lo pide desde tu cuenta); Claude te dice cuál en cada caso y anota los IDs en `Config.luau`.

**Reglas de todas las animaciones:**
- Exageradas, estilo cómic: anticipación (se carga hacia atrás), golpe rápido, pausa corta en el final del golpe, recuperación.
- Las que se repiten (quieto, caminar, correr) terminan igual que empiezan (loop perfecto).
- Prioridades de Roblox: quieto/caminar/correr = Core; combate = Action; definitiva = Action4.
- Cada golpe marca el **cuadro de impacto** con un marcador (Animation Event) llamado `Impacto`, para que el código haga el daño justo ahí.

- [ ] [[P26 Animaciones base del jugador]]
- [ ] [[P27 Animaciones de los 3 primeros Linajes]]
- [ ] [[P28 Animaciones de un jefe]]
- [ ] [[P29 Animaciones de NPCs y enemigos]]
- [ ] [[P29b Animaciones de la calle viva]]
- [ ] [[P30 Animaciones de objetos]]

## Fase F. Sonidos y música (ForgeGUI)

- [ ] [[P31 Sonidos de combate y menús]]
- [ ] [[P32 Ambientes y música]]

## Fase G. Pantallas (las hace Claude en Studio)

- [ ] [[P33 HUD y menús]]

## Fase H. Código (después de los modelos y animaciones)

Todos empiezan con: `Leé linajes/ideas/ficha.md, linajes/arte/GUIA-ESTILO.md y GUIA-PARA-CLAUDE.md.` Todos terminan con: `Play por MCP, consola sin rojo, captura. Commit en español y push. Decime qué tengo que probar yo y cómo.`

- [ ] [[P34 Base y guardado]]
- [ ] [[P35 Combate]]
- [ ] [[P36 Ruleta Linaje, Variante y Rasgos]]
- [ ] [[P36b Creador de personaje y personalización]]
- [ ] [[P37 Niveles, árbol y Despertar 1 con ramas]]
- [ ] [[P37b Chips de técnica, segundo poder y técnicas combinadas]]
- [ ] [[P37c Rasgos por estadísticas y Variantes secretas]]
- [ ] [[P38 Diálogos con NPCs, trabajos y reputación]]
- [ ] [[P38b Reputación de ciudad, fama, búsqueda y territorios]]
- [ ] [[P38c Calle viva civiles, testigos, policía y vigilancia]]
- [ ] [[P38d Atracos]]
- [ ] [[P38e Noticias de El Faro y teléfono]]
- [ ] [[P39 Prólogo tu origen y la Noche del Eclipse]]
- [ ] [[P40 Tecnología e implantes]]
- [ ] [[P41 El Narrador ganchos e hilos]]
- [ ] [[P41a Primer hilo hecho a mano Los muelles rojos]]
- [ ] [[P41b Que cada partida sea distinta]]
- [ ] [[P41c La agenda de los villanos y la Crónica de la ciudad]]
- [ ] [[P42 Piezas de traje de los NPCs y pantalla de trajes]]
- [ ] [[P43 Probar, medir y publicar la beta]]
- [ ] [[P44 Actos después de la beta]]
