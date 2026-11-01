---
tags: [prompt, animaciones]
beta: "Solo el estilo de pelea **Puños** (las 22 animaciones de la lista). Los otros 4 estilos y las poses del menú, en la Post beta."
---
# P26 Animaciones base del jugador

> [!summary] En tres líneas
> Las animaciones que usa todo jugador: quieto, caminar, correr, saltar, trepar, volar, el combo de 4 golpes, bloqueo, parry, dash, recibir golpes, derrota e interacción. Claude las hace en Blender sobre el cuerpo propio R15 y vos las publicás en Roblox.

> [!info] En la Beta
> Solo el estilo de pelea **Puños** (las 22 animaciones de la lista). Los otros 4 estilos y las poses del menú, en la Post beta.

## 1. Para qué es
Sin estas el juego no se mueve. Son la base del combate (P35) y de todo lo demás. Estilo cómic: anticipación marcada, golpe rápido, pausa corta y recuperación.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-base.blend`, script `linajes/arte/scripts/animaciones/base.py`, FBX en `linajes/arte/animaciones/base/`, IDs en `Config.luau`.

## 2. Qué leer antes
- [[Animaciones (plan completo)]] secciones 1, 2 y 3
- [[Combate y progresión]] (teclas y tiempos del combo)
- [[Cuerpo propio]] (el esqueleto)
- [[Estadísticas y movimiento]] (correr, volar, trepar)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de poses clave del combo de 4 golpes** → guardar como `linajes/arte/referencias/gemini/anim-base/combo.png`
```
Character animation key-pose sheet, 4 rows (one per attack), 3 poses per row: anticipation, impact, recovery. A stylized blocky Roblox-proportioned brawler in a plain grey suit performs: row 1 right jab, row 2 left cross, row 3 rising right uppercut, row 4 spinning roundhouse kick that ends back in guard. Strong silhouettes, exaggerated comic-book line of action, motion arcs drawn as thin cyan curves, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Hoja de locomoción (quieto, caminar, correr, volar)** → guardar como `linajes/arte/referencias/gemini/anim-base/locomocion.png`
```
Animation reference sheet of a stylized blocky Roblox-proportioned hero in a plain grey suit: idle with weight on one leg, walk contact and passing poses, run with torso leaning 15 degrees and arms at 90 degrees, sprint with torso at 30 degrees and arms swept back, jump crouch-stretch-tuck-land, wall climb, hover in the air and fly forward with body horizontal and one fist forward. Side view silhouettes in a row, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: Bloqueo, parry, dash, golpe recibido y derrota** → guardar como `linajes/arte/referencias/gemini/anim-base/defensa.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned fighter in a plain grey suit: block with forearms crossed in front of the face, parry snapping the forearm outward, dash leaning in four directions with no steps, light hit flinch, heavy hit knocked back, stunned wobble, defeat falling to knees then to the side, getting up. Three-quarter view, neutral grey background, comic-book exaggeration. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las secciones 1, 2 y 3 de linajes/boveda/01 Juego/Animaciones (plan completo).md
(la lista de abajo es el mínimo de la Beta; el plan manda en lo demás). Mirá las 3 imágenes de
linajes/arte/referencias/gemini/anim-base/ para las poses clave.
Abrí linajes/arte/blender/kit-base.blend y guardalo como linajes/arte/blender/animaciones-base.blend.
Animá el esqueleto R15 del cuerpo propio (P20f) a 30 fps. Cada animación es una Action separada,
generada por linajes/arte/scripts/animaciones/base.py (que se pueda volver a correr).

LOCOMOCIÓN (loops, prioridad Core):
1. Quieto (60): respiración lenta, hombros suben 0,03 studs, peso en una pierna, mira a los costados una vez.
2. Caminar (32): paso firme, brazos opuestos a las piernas, balanceo leve del torso (±3°).
3. Correr (20): torso inclinado 15°, brazos doblados a 90°, rodillas altas.
4. Correr rápido (14): torso a 30°, brazos hacia atrás rectos (Velocista Cinético y Reflejos).
5. Saltar: inicio (8, se agacha) + aire (loop 20, rodillas arriba) + caer (10, amortigua).
6. Trepar (loop 24) para el gancho y las paredes.
7. Volar quieto (loop 60) y volar avanzando (loop 30): cuerpo horizontal, un puño adelante.
8. Nadar (loop 40, Sangre Abisal y el agua del puerto).

COMBATE (no loop, prioridad Action, marcador Impacto):
9. Golpe 1 (14): jab derecho. Anticipación 0-4, Impacto 6, recuperación 7-14.
10. Golpe 2 (14): cross izquierdo. Impacto 6.
11. Golpe 3 (18): gancho ascendente derecho. Impacto 8.
12. Golpe 4 (24): patada giratoria que empuja. Anticipación 0-8, Impacto 12, cae en guardia.
13. Bloqueo: inicio (4) + loop (30): antebrazos cruzados delante de la cara, rodillas flexionadas.
14. Parry (12): antebrazo hacia afuera de golpe, Impacto 3.
15. Dash adelante, atrás, izquierda y derecha (8 cada uno): inclinado, sin pasos.
16. Recibir golpe liviano (10) y fuerte (18, retrocede).
17. Aturdido (loop 40): tambalea, la cabeza gira.
18. Derrota (40): de rodillas y después de costado. Levantarse (30).

INTERACCIÓN:
19. Hablar con NPC (loop 60). 20. Recoger del piso (20). 21. Usar el banco del taller (loop 48).
22. Celebrar (40, puño arriba). 23. Saludar (30).

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-base-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/base/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.base) y probá
  cada una con Play sobre el Dummy: que el marcador Impacto llegue al código (print temporal), consola sin
  rojo, captura. Borrá los prints. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- **30 cuadros por segundo**; las que se repiten (loops) terminan exactamente en la pose del cuadro 0.
- Esqueleto **R15** del cuerpo propio (P20f): nombres de huesos de Roblox (`UpperTorso`, `LeftUpperArm`…), sin escalar huesos (Roblox no lo importa bien).
- Prioridades: quieto, caminar y correr = **Core**; combate = **Action**; definitiva = **Action4**.
- Marcador **`Impacto`** en el cuadro exacto del contacto: el servidor aplica el daño ahí. Los jefes además llevan **`Aviso`** 12 cuadros (0,4 s) antes.
- La raíz (`HumanoidRootPart`) **no se mueve** en las animaciones (salvo dash y embestidas, que mueve el código): si no, el personaje se 'teletransporta' al terminar.
- Publicar la animación en Roblox lo hacés **vos** (Animation Editor → Publish to Roblox); Claude anota los IDs en `Config.luau`.

## 6. Pasos y puntos de control
### Paso 1: Hoja de tiras
Las 23 animaciones con sus 3 cuadros clave en una hoja.

**Para dar el OK:**
- [ ] Cada golpe tiene anticipación clara y pausa al final.
- [ ] Los loops no saltan al repetirse.
- [ ] La raíz no se mueve (salvo dash).
- [ ] Se parecen en fuerza a las poses de Gemini.

### Paso 2: Publicar y probar
FBX, importar en Studio, vos publicás, IDs en Config.

**Para dar el OK:**
- [ ] El marcador Impacto llega al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, 23 FBX y la hoja de tiras.
- IDs en `Config.luau` (Animaciones.base).

**Cómo lo probás vos:**
- Mirá la hoja de tiras en Obsidian.
- En Studio, con Play, mirá el Dummy hacer cada animación.

---
[[P25d Interiores donde se puede entrar|← P25d Interiores donde se puede entrar]]   ·   [[Todos los prompts]]   ·   [[P27 Animaciones de los 3 primeros Linajes|P27 Animaciones de los 3 primeros Linajes →]]
