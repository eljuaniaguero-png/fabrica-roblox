---
tags: [prompt, animaciones]
beta: "No (Post beta)"
---
# P27-12 Animaciones de Eclipse

> [!summary] En tres líneas
> Las animaciones de las habilidades Z, X y C de **Eclipse** (Variante Normal), más cargar poder. Nombres, alcances y qué hace cada una salen de su nota.

> [!info] En la Beta
> No (Post beta)

## 1. Para qué es
Las animaciones de las habilidades Z, X y C de **Eclipse** (Variante Normal), más cargar poder. Nombres, alcances y qué hace cada una salen de su nota.

**Qué tener abierto:** Blender con el conector y, para el último paso, Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-linajes.blend`, script `linajes/arte/scripts/animaciones/linaje-eclipse.py`, FBX en `linajes/arte/animaciones/linaje-eclipse/`.

## 2. Qué leer antes
- [[Eclipse]] (habilidades: manda)
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Las 3 habilidades de Eclipse** → guardar como `linajes/arte/referencias/gemini/anim-linaje-eclipse/habilidades.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned character in a plain grey suit: superpower 'Eclipse' — row 1: Anillo (Aro de luz que corta a distancia (28)); row 2: Corona (Rayos desde arriba en área (30)); row 3: Cambio (Cambiás de modo: explosión de 15 alrededor). Three poses per action (anticipation, impact, recovery), comic-book line of action, motion arcs as thin cyan curves, neutral grey background. Power effect color Negro `#0e1016` con borde de fuego `#f2652b`. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Cargar poder y pose de presentación** → guardar como `linajes/arte/referencias/gemini/anim-linaje-eclipse/carga.png`
```
Stylized blocky Roblox-proportioned hero in a plain grey suit charging the superpower 'Eclipse' (power-up stance, aura building), and a heroic presentation pose for a menu, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá las imágenes de
linajes/arte/referencias/gemini/anim-linaje-eclipse/. Abrí linajes/arte/blender/animaciones-base.blend y guardalo
como linajes/arte/blender/animaciones-linajes.blend (si ya existe, abrilo). 30 fps sobre el R15 del cuerpo propio.
Cada animación es una Action, generada por linajes/arte/scripts/animaciones/linaje-eclipse.py.

- Z "Anillo" (30 cuadros, Action): Aro de luz que corta a distancia (28). Anticipación hasta el cuadro 10, Impacto en 12, recuperación hasta el final.
- X "Corona" (36 cuadros, Action): Rayos desde arriba en área (30). Anticipación hasta el cuadro 12, Impacto en 16, recuperación hasta el final.
- C "Cambio" (40 cuadros, Action): Cambiás de modo: explosión de 15 alrededor. Anticipación hasta el cuadro 14, Impacto en 18, recuperación hasta el final.
- Cargar poder (loop 30): para la ruleta y el menú.
- POST BETA (no ahora): las 6 de Variantes, 2 definitivas y el Despertar.
CIERRE: tira de 3 cuadros clave por animación (anticipación, impacto o pose máxima, recuperación) en
linajes/arte/renders/anim-linaje-eclipse-<animación>.png y una hoja con todas, mandada a la nota de Obsidian
"Animaciones (plan completo)" (sección Hechas: P27-12 Animaciones de Eclipse). Esperá mi OK.
Con mi OK: FBX por animación en linajes/arte/animaciones/linaje-eclipse/ (solo esqueleto, 30 fps, Bake
Animation, sin Leaf Bones). En Studio, por MCP, un Dummy en workspace.PruebasAnim y decime exactamente
qué tocar para importar y publicar cada una. Con los IDs: Config.luau (Animaciones.linaje_eclipse),
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
- [ ] La postura dice qué Linaje es, aunque no haya efectos.
- [ ] Impacto en el cuadro que dice la lista.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Los marcadores llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `animaciones-linajes.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau`.

**Cómo lo probás vos:**
- Mirá la hoja de tiras en Obsidian.
- En Studio, mirá el Dummy hacer cada una.

---
[[P27-11 Animaciones de Herencia Olímpica|← P27-11 Animaciones de Herencia Olímpica]]   ·   [[P27 Animaciones de los 3 primeros Linajes]]
