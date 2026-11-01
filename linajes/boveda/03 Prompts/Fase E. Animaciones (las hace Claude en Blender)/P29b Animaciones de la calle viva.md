---
tags: [prompt, animaciones]
beta: "Civiles y policía **del puerto**, y el jugador en crímenes **chicos** (bolsa de botín, forzar puerta, rendirse, ser esposado). Lo demás, en la Post beta."
---
# P29b Animaciones de la calle viva

> [!summary] En tres líneas
> Civiles que caminan, se asustan, huyen y llaman a la policía; policías que patrullan y esposan; y el jugador cuando comete un crimen.

> [!info] En la Beta
> Civiles y policía **del puerto**, y el jugador en crímenes **chicos** (bolsa de botín, forzar puerta, rendirse, ser esposado). Lo demás, en la Post beta.

## 1. Para qué es
La calle viva del puerto: si hacés algo malo, un civil llama a la policía (4 s para frenarlo) y te buscan. Estas animaciones lo hacen legible.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-calle.blend`, script `scripts/animaciones/calle.py`, FBX en `arte/animaciones/calle/`.

## 2. Qué leer antes
- [[Calle viva]] (testigos, policía, atracos)
- [[Calle viva (puerto)]] (lo exportado)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Civiles: caminar, asustarse, llamar a la policía** → guardar como `linajes/arte/referencias/gemini/anim-calle/civiles.png`
```
Animation pose sheet of original stylized blocky Roblox-proportioned harbor civilians: walking with a shopping bag, walking while looking at a phone, startled jump, fleeing with arms up, taking out a phone and calling with it at the ear while looking around nervously, filming with the phone, crouching with hands on head, a brave one raising fists. Grey background, comic-book clarity. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Policía y jugador en un crimen** → guardar como `linajes/arte/referencias/gemini/anim-calle/policia.png`
```
Animation pose sheet: an original harbor police officer (blue uniform, flashlight, riot shield) patrolling with a flashlight, pointing and shouting stop, running, handcuffing a kneeling suspect, shield bash; and a masked suspect carrying a loot bag on the shoulder, dropping it, forcing a door, hands up surrendering. Grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/boveda/01 Juego/Calle viva.md. Mirá las imágenes de linajes/arte/referencias/gemini/anim-calle/.
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-calle.blend. 30 fps, R15.

CIVILES: caminar con bolsa (loop 32), caminar mirando el teléfono (loop 32), asustarse (20), huir con los
brazos arriba (loop 20), LLAMAR A LA POLICÍA (120 = 4 s: saca el teléfono, lo lleva a la oreja, mira para
todos lados; marcador LlamadaHecha en el cuadro 120), filmar (loop 60), aplaudir (loop 30), agacharse con
las manos en la cabeza (loop 40), valiente en guardia (20).
POLICÍA: patrullar con linterna (loop 40), apuntar y gritar "alto" (30), correr (loop 20), esposar (40,
marcador Esposado), escudo (loop 30), golpe de escudo (20, Aviso 6, Impacto 12).
JUGADOR EN CRIMEN (Beta): ser esposado de rodillas (40), manos arriba (loop 30), bolsa de botín al hombro
(caminar loop 32 y correr loop 20, más pesado), tirar la bolsa (15), forzar una puerta (loop 40),
ponerse y sacarse la máscara (30).

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-calle-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/calle/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.calle) y probá
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
Civiles, policía y jugador.

**Para dar el OK:**
- [ ] Llamar a la policía dura justo 4 s y se entiende de lejos.
- [ ] Huir se distingue de caminar desde 50 studs.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] LlamadaHecha y Esposado llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau` (Animaciones.calle).

**Cómo lo probás vos:**
- Hoja de tiras en Obsidian.
- En Studio, un civil del puerto llama a la policía.

---
[[P29 Animaciones de NPCs y enemigos|← P29 Animaciones de NPCs y enemigos]]   ·   [[Todos los prompts]]   ·   [[P26b Animaciones de tecnología, gadgets y vehículos|P26b Animaciones de tecnología, gadgets y vehículos →]]
