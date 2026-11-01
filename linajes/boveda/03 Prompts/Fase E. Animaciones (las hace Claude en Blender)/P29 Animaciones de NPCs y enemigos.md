---
tags: [prompt, animaciones]
beta: "Solo **Tano**, **el Albatros**, los **3 matones del puerto** y el **matón con implantes**. Los demás NPCs y enemigos, en la Post beta."
---
# P29 Animaciones de NPCs y enemigos

> [!summary] En tres líneas
> Loops de vida de los NPCs (qué hacen mientras esperan), saludar y hablar; y las animaciones de pelea de los enemigos comunes con Aviso e Impacto.

> [!info] En la Beta
> Solo **Tano**, **el Albatros**, los **3 matones del puerto** y el **matón con implantes**. Los demás NPCs y enemigos, en la Post beta.

## 1. Para qué es
Hace que el puerto se sienta vivo: Tano trabaja en el taller, el Albatros espera en su oficina, los matones patrullan y pelean.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-npcs.blend`, script `scripts/animaciones/npcs.py`, FBX en `arte/animaciones/npcs/`.

## 2. Qué leer antes
- [[Tano]] · [[El Albatros]] (cómo hablan y se mueven)
- [[Matón del puerto (modelo)]] · [[Matón con implantes (modelo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Tano y el Albatros: poses de vida** → guardar como `linajes/arte/referencias/gemini/anim-npcs/npcs-vida.png`
```
Character pose sheet of two original stylized blocky Roblox-proportioned NPCs. Left: an old harbor mechanic with a grey mustache, greasy blue overalls, leather apron and a red rag, tightening a bolt with a wrench, wiping his hands, waving hello, gesturing while talking. Right: a short wide harbor boss in a long navy captain's coat with a grey fur collar, captain's cap and a harpoon-tipped cane, leaning on the cane, tapping it, counting coins, pointing while talking. Four poses each, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Matones: perseguir y pelear** → guardar como `linajes/arte/referencias/gemini/anim-npcs/matones.png`
```
Animation key-pose sheet of an original harbor thug (hoodie, work boots, chain) and a cyber-implant thug with a hydraulic arm: patrol walk, chase run, two attacks each with a wind-up warning pose and an impact pose, hit flinch, defeat. Comic-book exaggeration, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las notas de Tano y el Albatros en linajes/boveda/07 NPCs/ y las de los matones en 04 Personajes/.
Mirá las imágenes de linajes/arte/referencias/gemini/anim-npcs/.
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-npcs.blend. 30 fps, R15.

TANO: trabajar con la llave inglesa sobre el auto (loop 120), limpiarse las manos con el trapo (loop 60),
saludar al jugador (30, levanta la llave), hablar (loop 60, gesticula con la mano libre), preocupado
(loop 60, mano en la nuca: para la escena de Nico).
EL ALBATROS: apoyado en el bastón-arpón (loop 90), contar monedas (loop 60), saludar (30, se toca la gorra),
hablar (loop 60, señala con el bastón), enojado (30, golpea el piso con el bastón).
MATÓN DEL PUERTO (3 variantes usan las mismas): patrullar (loop 32), alerta (20), perseguir (loop 20),
golpe 1 (20: Aviso 4, Impacto 12), golpe 2 con cadena (28: Aviso 8, Impacto 18), recibir golpe (10),
derrota (40), rendirse (loop 30, manos arriba).
MATÓN CON IMPLANTES: igual que el matón + "puño hidráulico" (36: Aviso 14, carga, Impacto 24).

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-npcs-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/npcs/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.npcs) y probá
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
Las animaciones de los 2 NPCs y los 2 tipos de matón.

**Para dar el OK:**
- [ ] Tano y el Albatros se distinguen por cómo se paran.
- [ ] Los matones avisan antes de pegar.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Aviso e Impacto llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau` (Animaciones.npcs).

**Cómo lo probás vos:**
- Hoja de tiras en Obsidian.
- En Studio, Tano trabaja en el taller y un matón pelea con el Dummy.

---
[[P28 Animaciones de un jefe|← P28 Animaciones de un jefe]]   ·   [[Todos los prompts]]   ·   [[P29b Animaciones de la calle viva|P29b Animaciones de la calle viva →]]
