---
tags: [prompt, animaciones]
beta: "**Sí**"
---
# P26-02 Combate del jugador (Puños)

> [!summary] En tres líneas
> El combo de 4 golpes, bloqueo, parry, dash, recibir golpes, aturdido, derrota y levantarse.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
El combo de 4 golpes, bloqueo, parry, dash, recibir golpes, aturdido, derrota y levantarse.

**Qué tener abierto:** Blender con el conector y, para el último paso, Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-base.blend`, script `linajes/arte/scripts/animaciones/base.py`, FBX en `linajes/arte/animaciones/base/`.

## 2. Qué leer antes
- [[Combate y progresión]] (tiempos del combo)
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Combo de 4 golpes** → guardar como `linajes/arte/referencias/gemini/anim-combate/combo.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned character in a plain grey suit: row 1 right jab, row 2 left cross, row 3 rising right uppercut, row 4 spinning roundhouse kick ending in guard. Three poses per action (anticipation, impact, recovery), comic-book line of action, motion arcs as thin cyan curves, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Defensa y daño** → guardar como `linajes/arte/referencias/gemini/anim-combate/defensa.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned character in a plain grey suit: block with forearms crossed, parry snapping the forearm outward, dash leaning in four directions without steps, light flinch, heavy hit knockback, stunned wobble, defeat falling to knees then to the side, getting up. Three poses per action (anticipation, impact, recovery), comic-book line of action, motion arcs as thin cyan curves, neutral grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá las imágenes de
linajes/arte/referencias/gemini/anim-combate/. Abrí linajes/arte/blender/animaciones-base.blend y guardalo
como linajes/arte/blender/animaciones-base.blend (si ya existe, abrilo). 30 fps sobre el R15 del cuerpo propio.
Cada animación es una Action, generada por linajes/arte/scripts/animaciones/base.py.

- Golpe 1 (14, Action): jab derecho; anticipación 0-4, Impacto 6, recuperación 7-14.
- Golpe 2 (14): cross izquierdo, Impacto 6.
- Golpe 3 (18): gancho ascendente derecho, Impacto 8.
- Golpe 4 (24): patada giratoria que empuja; anticipación 0-8, Impacto 12, cae en guardia.
- Bloqueo: inicio 4 + loop 30, antebrazos cruzados delante de la cara.
- Parry (12): antebrazo hacia afuera, Impacto 3.
- Dash adelante, atrás, izquierda y derecha (8 cada uno), sin pasos.
- Recibir golpe liviano (10) y fuerte (18).
- Aturdido (loop 40).
- Derrota (40) y levantarse (30).
CIERRE: tira de 3 cuadros clave por animación (anticipación, impacto o pose máxima, recuperación) en
linajes/arte/renders/anim-base-<animación>.png y una hoja con todas, mandada a la nota de Obsidian
"Animaciones (plan completo)" (sección Hechas: P26-02 Combate del jugador (Puños)). Esperá mi OK.
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
- [ ] Cada golpe tiene anticipación clara y pausa al final.
- [ ] El parry se lee distinto del bloqueo.

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
[[P26-01 Locomoción del jugador|← P26-01 Locomoción del jugador]]   ·   [[P26 Animaciones base del jugador]]   ·   [[P26-03 Interacción del jugador|P26-03 Interacción del jugador →]]
