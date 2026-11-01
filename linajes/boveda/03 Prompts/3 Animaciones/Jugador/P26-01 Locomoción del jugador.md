---
tags: [prompt, animaciones]
beta: "**Sí**"
---
# P26-01 Locomoción del jugador

> [!summary] En tres líneas
> Quieto, caminar, correr, correr rápido, saltar, trepar, volar y nadar: lo que usa todo jugador para moverse.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Quieto, caminar, correr, correr rápido, saltar, trepar, volar y nadar: lo que usa todo jugador para moverse.

**Qué tener abierto:** Blender con el conector y, para el último paso, Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-base.blend`, script `linajes/arte/scripts/animaciones/base.py`, FBX en `linajes/arte/animaciones/base/`.

## 2. Qué leer antes
- [[Estadísticas y movimiento]] (movimiento sin límite por Linaje)
- [[Cuerpo propio]]
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de locomoción** → guardar como `linajes/arte/referencias/gemini/anim-locomocion/locomocion.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned character in a plain grey suit: idle with weight on one leg, walk contact and passing poses, run leaning 15 degrees with arms at 90 degrees, sprint leaning 30 degrees with arms swept back, jump crouch-stretch-tuck-land, wall climb. Three poses per action (anticipation, impact, recovery), comic-book line of action, motion arcs as thin cyan curves, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Volar y nadar** → guardar como `linajes/arte/referencias/gemini/anim-locomocion/volar-nadar.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned character in a plain grey suit: hover in the air, fly forward with body horizontal and one fist forward, swim freestyle, tread water. Three poses per action (anticipation, impact, recovery), comic-book line of action, motion arcs as thin cyan curves, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá las imágenes de
linajes/arte/referencias/gemini/anim-locomocion/. Abrí linajes/arte/blender/animaciones-base.blend y guardalo
como linajes/arte/blender/animaciones-base.blend (si ya existe, abrilo). 30 fps sobre el R15 del cuerpo propio.
Cada animación es una Action, generada por linajes/arte/scripts/animaciones/base.py.

- Quieto (loop 60, Core): respiración lenta, hombros +0,03 studs, peso en una pierna, mira a los costados una vez.
- Caminar (loop 32): paso firme, brazos opuestos, torso ±3°.
- Correr (loop 20): torso 15°, brazos a 90°, rodillas altas.
- Correr rápido (loop 14): torso 30°, brazos rectos atrás (Velocista y Reflejos).
- Saltar: inicio 8 (se agacha), aire loop 20 (rodillas arriba), caer 10 (amortigua).
- Trepar (loop 24): para el gancho y paredes.
- Volar quieto (loop 60) y volar avanzando (loop 30): cuerpo horizontal, un puño adelante.
- Nadar (loop 40) y flotar (loop 60).
CIERRE: tira de 3 cuadros clave por animación (anticipación, impacto o pose máxima, recuperación) en
linajes/arte/renders/anim-base-<animación>.png y una hoja con todas, mandada a la nota de Obsidian
"Animaciones (plan completo)" (sección Hechas: P26-01 Locomoción del jugador). Esperá mi OK.
Con mi OK: FBX por animación en linajes/arte/animaciones/base/ (solo esqueleto, 30 fps, Bake
Animation, sin Leaf Bones). En Studio, por MCP, un Dummy en workspace.PruebasAnim y decime exactamente
qué tocar para importar y publicar cada una. Con los IDs: Config.luau (Animaciones.base),
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
- [ ] Los loops no saltan al repetirse.
- [ ] Correr y correr rápido se distinguen de lejos.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Los marcadores llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `animaciones-base.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau`.

**Cómo lo probás vos:**
- Mirá la hoja de tiras en Obsidian.
- En Studio, mirá el Dummy hacer cada una.

---
[[P26 Animaciones base del jugador]]   ·   [[P26-02 Combate del jugador (Puños)|P26-02 Combate del jugador (Puños) →]]
