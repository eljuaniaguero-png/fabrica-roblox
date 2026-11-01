---
tags: [prompt, animaciones]
beta: "Solo **Fuerza Bruta, Reflejos y Piroquinesis**, sus 3 habilidades (Z, X, C) en la Variante Normal, **sin definitiva** (no hay Despertar en la Beta). Los otros 9 Linajes, Variantes y definitivas, en la Post beta con el mismo prompt."
---
# P27 Animaciones de los 3 primeros Linajes

> [!summary] En tres líneas
> Las animaciones de las 3 habilidades de cada Linaje Común (9 en total), con su marcador Impacto. Se hacen sobre animaciones-base.blend.

> [!info] En la Beta
> Solo **Fuerza Bruta, Reflejos y Piroquinesis**, sus 3 habilidades (Z, X, C) en la Variante Normal, **sin definitiva** (no hay Despertar en la Beta). Los otros 9 Linajes, Variantes y definitivas, en la Post beta con el mismo prompt.

## 1. Para qué es
Son los poderes que salen en la ruleta de la Beta. Cada habilidad tiene que verse distinta de lejos: Fuerza Bruta pesada, Reflejos rapidísima, Piroquinesis con gestos de lanzar.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-linajes-1.blend`, script `scripts/animaciones/linajes.py`, FBX en `arte/animaciones/linajes/`.

## 2. Qué leer antes
- [[Fuerza Bruta]] · [[Reflejos]] · [[Piroquinesis]] (nombres, daño y recarga de cada habilidad)
- [[Animaciones (plan completo)]] sección 4
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Fuerza Bruta: pisotón, embestida y levantar-tirar** → guardar como `linajes/arte/referencias/gemini/anim-linajes/fuerza-bruta.png`
```
Animation key-pose sheet, 3 rows x 3 poses (anticipation, impact, recovery): a stylized blocky Roblox-proportioned heavy brawler in a plain grey suit. Row 1: raises knee high then stomps the ground creating a cracked shockwave ring. Row 2: lowers shoulder and charges forward like a battering ram. Row 3: grabs an enemy, lifts it overhead, throws it. Heavy weight, wide stance, comic-book exaggeration, dust effects drawn as simple shapes, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Reflejos: ráfaga, contraataque y paso sombra** → guardar como `linajes/arte/referencias/gemini/anim-linajes/reflejos.png`
```
Animation key-pose sheet, 3 rows x 3 poses: a lean stylized blocky Roblox-proportioned martial artist in a plain grey suit. Row 1: three ultra-fast alternating punches with afterimages. Row 2: calm waiting counter stance, then a spinning kick when hit. Row 3: vanishing sideways in a blur and kicking from behind. Speed lines, sharp angles, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: Piroquinesis: bola de fuego, muro y explosión** → guardar como `linajes/arte/referencias/gemini/anim-linajes/piroquinesis.png`
```
Animation key-pose sheet, 3 rows x 3 poses: a stylized blocky Roblox-proportioned fire user in a plain grey suit with orange flame effects. Row 1: hands cupped at the hip gathering fire, then pushing a fireball forward. Row 2: sweeping arm low from left to right raising a wall of flame. Row 3: arms crossed charging, then thrown open releasing a fire burst. Warm orange #f2652b glow, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las notas de linajes/boveda/06 Linajes/ de Fuerza Bruta, Reflejos y Piroquinesis (nombres, alcance y
qué hace cada habilidad) y la sección 4 de Animaciones (plan completo). Mirá las 3 imágenes de
linajes/arte/referencias/gemini/anim-linajes/.
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-linajes-1.blend.
30 fps, prioridad Action, marcador Impacto en cada golpe, script scripts/animaciones/linajes.py.

FUERZA BRUTA (pesada, pies anchos, todo con el cuerpo entero):
- Z "Pisotón" (30): levanta la rodilla alto (0-10), pisa (Impacto 14), se sacude (15-30).
- X "Embestida" (24): agacha el hombro (0-6), carga (el código la mueve 12 studs), Impacto 10.
- C "Levantar y tirar" (40): agarra (Impacto 8), levanta sobre la cabeza (8-24), lanza (Impacto 28).
REFLEJOS (liviana, rapidísima, posturas de artes marciales):
- Z "Ráfaga" (20): 3 golpes alternados, Impactos en 4, 9 y 14.
- X "Contraataque": espera (loop 16) + respuesta (20): gira y patea, Impacto 8.
- C "Paso sombra" (18): se agacha, desaparece hacia un costado (el código mueve), patea por detrás, Impacto 14.
PIROQUINESIS (gestos de lanzar, manos abiertas):
- Z "Bola de fuego" (22): junta las manos en la cadera (0-10), empuja (Impacto 12).
- X "Muro de fuego" (30): barre el brazo a ras del piso de izquierda a derecha (Impacto 16).
- C "Explosión" (40): brazos cruzados (0-14), los abre de golpe (Impacto 18).
Además, para cada Linaje: "cargar poder" (loop 30, para la ruleta y el menú).

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-linajes-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/linajes/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.linajes) y probá
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
Las 9 habilidades + 3 cargas.

**Para dar el OK:**
- [ ] Cada Linaje se distingue por la postura, no solo por el efecto.
- [ ] Impacto en el cuadro que dice la lista.
- [ ] Nada atraviesa el cuerpo.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Impacto llega al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, 12 FBX, hoja de tiras.
- IDs en `Config.luau` (Animaciones.linajes).

**Cómo lo probás vos:**
- Hoja de tiras en Obsidian.
- En Studio, el Dummy hace cada habilidad.

---
[[P26 Animaciones base del jugador|← P26 Animaciones base del jugador]]   ·   [[Todos los prompts]]   ·   [[P28 Animaciones de un jefe|P28 Animaciones de un jefe →]]
