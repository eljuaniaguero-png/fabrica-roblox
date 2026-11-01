---
tags: [prompt, animaciones]
beta: "No"
---
# P29-07 Animaciones de Ingeniera Okafor

> [!summary] En tres líneas
> Las animaciones de **Ingeniera Okafor**: lo que hace mientras espera y cómo habla o pelea.

> [!info] En la Beta
> No

## 1. Para qué es
Las animaciones de **Ingeniera Okafor**: lo que hace mientras espera y cómo habla o pelea.

**Qué tener abierto:** Blender con el conector y, para el último paso, Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-npcs.blend`, script `linajes/arte/scripts/animaciones/npc-ingenieraokafor.py`, FBX en `linajes/arte/animaciones/npc-ingenieraokafor/`.

## 2. Qué leer antes
- [[Ingeniera Okafor]]
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Poses de Ingeniera Okafor** → guardar como `linajes/arte/referencias/gemini/anim-ingenieraokafor/poses.png`
```
Animation pose sheet of an engineer in a lab coat with a tablet for a stylized Roblox superhero game: Tocar la tablet (loop 90).; Saludar (30).; Hablar (loop 60).. Grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá las imágenes de
linajes/arte/referencias/gemini/anim-ingenieraokafor/. Abrí linajes/arte/blender/animaciones-base.blend y guardalo
como linajes/arte/blender/animaciones-npcs.blend (si ya existe, abrilo). 30 fps sobre el R15 del cuerpo propio.
Cada animación es una Action, generada por linajes/arte/scripts/animaciones/npc-ingenieraokafor.py.

- Tocar la tablet (loop 90).
- Saludar (30).
- Hablar (loop 60).
CIERRE: tira de 3 cuadros clave por animación (anticipación, impacto o pose máxima, recuperación) en
linajes/arte/renders/anim-npc-ingenieraokafor-<animación>.png y una hoja con todas, mandada a la nota de Obsidian
"Animaciones (plan completo)" (sección Hechas: P29-07 Animaciones de Ingeniera Okafor). Esperá mi OK.
Con mi OK: FBX por animación en linajes/arte/animaciones/npc-ingenieraokafor/ (solo esqueleto, 30 fps, Bake
Animation, sin Leaf Bones). En Studio, por MCP, un Dummy en workspace.PruebasAnim y decime exactamente
qué tocar para importar y publicar cada una. Con los IDs: Config.luau (Animaciones.npc_ingenieraokafor),
Play sobre el Dummy (que el marcador llegue al código), consola sin rojo, captura. Commit y push.
```

## 5. Reglas de Roblox que aplican
- 30 fps; los loops terminan en la pose del cuadro 0.
- Esqueleto R15 del cuerpo propio (P20f), sin escalar huesos.
- Prioridades: locomoción Core, combate Action, definitiva Action4.
- Marcador `Impacto` en el cuadro del contacto (el servidor aplica el daño ahí).
- La raíz no se mueve (los desplazamientos los hace el código).
- Publicar en Roblox lo hacés vos; IDs en `Config.luau`.

## 6. Pasos y puntos de control
### Paso 1: Hoja de tiras
Todas las animaciones de este prompt en una hoja.

**Para dar el OK:**
- [ ] Se reconoce quién es por cómo se mueve.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Los marcadores llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `animaciones-npcs.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau`.

**Cómo lo probás vos:**
- Mirá la hoja de tiras en Obsidian.
- En Studio, mirá el Dummy hacer cada una.

---
[[P29-06 Animaciones de Lucía Vega|← P29-06 Animaciones de Lucía Vega]]   ·   [[P29 Animaciones de NPCs y enemigos]]   ·   [[P29-08 Animaciones de Dra. Kessler|P29-08 Animaciones de Dra. Kessler →]]
