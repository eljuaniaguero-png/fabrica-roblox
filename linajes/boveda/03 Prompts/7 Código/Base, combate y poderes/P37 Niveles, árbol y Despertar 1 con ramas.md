---
tags: [prompt, codigo]
beta: "Niveles 1 a 20, árbol de **estadísticas** y **movimiento**, y las 3 ramas del Linaje (Poder, Cuerpo, Técnica). **Sin Despertar** (llega al 25)."
---
# P37 Niveles, árbol y Despertar 1 con ramas

> [!summary] En tres líneas
> Experiencia, niveles, 2 puntos por nivel para las estadísticas y el movimiento, y el árbol de 3 ramas de cada Linaje. El Despertar 1 con ramas a ciegas queda armado para la Post beta.

> [!info] En la Beta
> Niveles 1 a 20, árbol de **estadísticas** y **movimiento**, y las 3 ramas del Linaje (Poder, Cuerpo, Técnica). **Sin Despertar** (llega al 25).

## 1. Para qué es
Es el motivo para volver: cada nivel te hace un poco más fuerte y te deja elegir cómo.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Progreso/`, pantalla del árbol de P33, `Config.luau` (Niveles, Arbol).

## 2. Qué leer antes
- [[Estadísticas y movimiento]] (puntos, topes, movimiento sin límite)
- [[Combate y progresión]]
- Las notas de los 3 Linajes Comunes (árbol y Despertar)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Pantalla del árbol** → guardar como `linajes/arte/referencias/gemini/arbol/arbol.png`
```
Skill tree screen with two tabs: 'stats' showing six stat bars with plus buttons and points left, and 'lineage' showing three vertical branches of square nodes (power, body, technique) connected by lines, unlocked nodes glowing cyan #3fe0f0, locked grey, a mystery node marked with question marks. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Subir de nivel** → guardar como `linajes/arte/referencias/gemini/arbol/nivel.png`
```
Level-up moment in an original superhero game: a blocky hero on a harbor rooftop surrounded by a rising column of cyan and gold light, small floating plus-icons, night fog, eclipse in the sky. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
XP: matón 15, matón con implantes 25, jefe 300, misión 50 a 200, crimen al azar 40, trabajo 20.
Nivel siguiente = 100 x nivel^1,4. Tope de la Beta: nivel 20 (el contenido llega hasta ahí).
PUNTOS: 2 por nivel para el árbol de estadísticas (vida, energía, fuerza, velocidad, defensa, recarga,
10 niveles cada una) y la fila Movimiento (mejoras del movimiento sin límite de tu Linaje), con los
valores y topes de la nota Estadísticas y movimiento.
ÁRBOL DEL LINAJE: 3 ramas (Poder, Cuerpo, Técnica) x 4 nodos en orden, con lo que dice cada nota de
Linaje. Los de Técnica cambian cómo funciona una habilidad. Nodos nuevos como "???" hasta usarlos.
Aviso "Tenés N puntos" (se va a los 4 s). Reinicio gratis del árbol hablando con Tano.
El servidor valida cada punto (que lo tengas, que el nodo anterior esté).
POST BETA (dejá la estructura lista, sin activar): Despertar 1 al nivel 25 con 2 ramas a ciegas (nombre,
símbolo y frase, nada de números), definitiva V propia, aviso de que no se puede deshacer.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.

## 6. Pasos y puntos de control
### Paso 1: Subir y repartir
Llegar a nivel 5 y repartir puntos.

**Para dar el OK:**
- [ ] Los puntos cambian números reales (vida, daño).
- [ ] No se puede trucar desde el cliente.
- [ ] El reinicio con Tano funciona.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos de progreso y pantalla conectada.

**Cómo lo probás vos:**
- En Play, subí a nivel 3 y repartí los puntos.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
XP: matón 15, matón con implantes 25, élite 60, jefe 300, misión 50 a 200, crimen al azar 40.
Nivel siguiente = 100 x nivel^1,4. Niveles 1-60 (el contenido llega al 20 por ahora). 1 punto por nivel.
ÁRBOL por Linaje: 3 ramas (Poder, Cuerpo, Técnica) x 4 nodos, en orden dentro de cada rama.
Los nodos de Técnica cambian cómo funciona una habilidad (ejemplos en la ficha).
DESPERTAR 1 (nivel 25): no es una misión fija. Al llegar al nivel, el Narrador (Prompt 41) manda un gancho
de evolución distinto según tu Linaje y tu historia (tu poder se descontrola en público, un mentor te
encuentra, un villano te quiere reclutar). Mientras no exista el Narrador, dejá un hilo de prueba con el mentor.
El hilo termina en elegir UNA de 2 ramas de evolución de tu Linaje
(Piroquinesis: Fénix o Infierno; Fuerza Bruta: Coloso o Demoledor; Reflejos: Sombra o Maestro).
Cada rama: 4 nodos nuevos, una definitiva V propia y cambio de color del poder.
LA ELECCIÓN ES A CIEGAS: la pantalla muestra solo el nombre de cada rama, su símbolo y una frase misteriosa
del mentor (ej. Fénix: "Lo que arde, vuelve." / Infierno: "Que no quede nada."). Nada de números ni
descripciones. Solo avisa que no se puede deshacer. Los nodos nuevos aparecen como "???" hasta usarlos.
Aviso "Tenés N puntos de habilidad". Reinicio gratis del árbol (no de la rama) hablando con Tano.
```

---
[[P36b Creador de personaje y personalización|← P36b Creador de personaje y personalización]]   ·   [[Todos los prompts]]   ·   [[P38 Diálogos con NPCs, trabajos y reputación|P38 Diálogos con NPCs, trabajos y reputación →]]
