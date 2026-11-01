---
tags: [prompt, animaciones]
beta: "No"
---
# P28-05 Animaciones de El Eclipsador

> [!summary] En tres líneas
> Animaciones del jefe **El Eclipsador**: entrada, quieto, caminar, 3 ataques con Aviso e Impacto, cambio de fase, aturdido y derrota.

> [!info] En la Beta
> No

## 1. Para qué es
Los jefes avisan antes de pegar: el marcador Aviso pinta el piso de rojo 0,4 s antes del Impacto.

**Qué tener abierto:** Blender con el conector y Studio para el último paso.

**Dónde queda:** `linajes/arte/blender/eclipsador.blend`, script `scripts/animaciones/eclipsador.py`, FBX en `arte/animaciones/jefes/eclipsador/`.

## 2. Qué leer antes
- [[El Eclipsador]]
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de los 3 ataques** → guardar como `linajes/arte/referencias/gemini/anim-jefe-eclipsador/ataques.png`
```
Boss animation key-pose sheet of a giant of black stone with fiery cracks, an eclipse ring in the chest and a crown of black rays: row 1 Rayos negros de los ojos que barren el piso; row 2 Puño gigante al piso, onda en anillo; row 3 Abre el eclipse del pecho: atrae a todos al centro. Three poses per row (warning, impact, recovery), red warning areas on the floor, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Entrada, cambio de fase y derrota** → guardar como `linajes/arte/referencias/gemini/anim-jefe-eclipsador/fases.png`
```
Key-pose sheet of the same boss (a giant of black stone with fiery cracks, an eclipse ring in the chest and a crown of black rays): dramatic entrance, phase change (Crece y la corona se prende fuego), stunned, defeat. Comic-book exaggeration, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé la nota del jefe en linajes/boveda/07 NPCs/. Mirá las imágenes de linajes/arte/referencias/gemini/anim-jefe-eclipsador/.
Abrí linajes/arte/blender/eclipsador.blend. 30 fps, marcador Impacto en cada golpe y Aviso 12 cuadros antes.
ANIMACIONES: entrada (90), quieto amenazante (loop 60), caminar pesado (loop 40), recibir golpe (20),
aturdido (loop 40), cambio de fase (60), derrota (90) y:
- ATAQUE 1: Rayos negros de los ojos que barren el piso
- ATAQUE 2: Puño gigante al piso, onda en anillo
- ATAQUE 3: Abre el eclipse del pecho: atrae a todos al centro
- CAMBIO DE FASE: Crece y la corona se prende fuego
Script scripts/animaciones/eclipsador.py. Tiras de 3 cuadros → mi OK → FBX → importar en Studio con el
modelo del jefe → decime qué publicar → IDs en Config.luau → commit y push.
```

## 5. Reglas de Roblox que aplican
- 30 fps; Aviso 12 cuadros antes de cada Impacto.
- El jefe usa su propio rig.
- Publicar lo hacés vos; IDs en `Config.luau`.

## 6. Pasos y puntos de control
### Paso 1: Hoja de tiras
Todas las animaciones del jefe.

**Para dar el OK:**
- [ ] Cada ataque se anuncia.
- [ ] Queda una ventana para pegarle.

### Paso 2: Publicar y probar
FBX, importar, IDs.

**Para dar el OK:**
- [ ] Aviso e Impacto llegan al código.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX y hoja de tiras.

**Cómo lo probás vos:**
- En Studio, el jefe hace sus 3 ataques.

---
[[P28-04 Animaciones de Víctor Halden (exoarmadura)|← P28-04 Animaciones de Víctor Halden (exoarmadura)]]   ·   [[P28 Animaciones de un jefe]]
