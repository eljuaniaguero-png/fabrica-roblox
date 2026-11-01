---
tags: [prompt, animaciones]
beta: "**Sí**"
---
# P29b-02 Animaciones de policía

> [!summary] En tres líneas
> Animaciones de la calle viva: **Policía**.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Animaciones de la calle viva: **Policía**.

**Qué tener abierto:** Blender con el conector y, para el último paso, Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-calle.blend`, script `linajes/arte/scripts/animaciones/calle.py`, FBX en `linajes/arte/animaciones/calle/`.

## 2. Qué leer antes
- [[Calle viva]]
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Poses: Policía** → guardar como `linajes/arte/referencias/gemini/anim-calle-polica/poses.png`
```
Animation pose sheet of an original harbor police officer with a flashlight and riot shield for a stylized Roblox game: Patrullar con linterna (loop 40).; Apuntar y gritar alto (30).; Correr (loop 20).; Esposar (40, marcador Esposado).; Escudo (loop 30).; Golpe de escudo (20, Aviso 6, Impacto 12).. Grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá las imágenes de
linajes/arte/referencias/gemini/anim-calle-polica/. Abrí linajes/arte/blender/animaciones-base.blend y guardalo
como linajes/arte/blender/animaciones-calle.blend (si ya existe, abrilo). 30 fps sobre el R15 del cuerpo propio.
Cada animación es una Action, generada por linajes/arte/scripts/animaciones/calle.py.

- Patrullar con linterna (loop 40).
- Apuntar y gritar alto (30).
- Correr (loop 20).
- Esposar (40, marcador Esposado).
- Escudo (loop 30).
- Golpe de escudo (20, Aviso 6, Impacto 12).
CIERRE: tira de 3 cuadros clave por animación (anticipación, impacto o pose máxima, recuperación) en
linajes/arte/renders/anim-calle-<animación>.png y una hoja con todas, mandada a la nota de Obsidian
"Animaciones (plan completo)" (sección Hechas: P29b-02 Animaciones de policía). Esperá mi OK.
Con mi OK: FBX por animación en linajes/arte/animaciones/calle/ (solo esqueleto, 30 fps, Bake
Animation, sin Leaf Bones). En Studio, por MCP, un Dummy en workspace.PruebasAnim y decime exactamente
qué tocar para importar y publicar cada una. Con los IDs: Config.luau (Animaciones.calle),
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
- [ ] Se lee de lejos qué está pasando.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Los marcadores llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `animaciones-calle.blend`, script, FBX y hoja de tiras.
- IDs en `Config.luau`.

**Cómo lo probás vos:**
- Mirá la hoja de tiras en Obsidian.
- En Studio, mirá el Dummy hacer cada una.

---
[[P29b-01 Animaciones de civiles|← P29b-01 Animaciones de civiles]]   ·   [[P29b Animaciones de la calle viva]]   ·   [[P29b-03 Animaciones de jugador en un crimen|P29b-03 Animaciones de jugador en un crimen →]]
