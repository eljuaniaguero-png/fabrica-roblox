---
tags: [prompt, animaciones]
beta: "Solo **Remache** (2 fases). Los demás jefes de la tabla, en la Post beta, uno por sesión."
---
# P28 Animaciones de un jefe

> [!summary] En tres líneas
> Animaciones de un jefe con su propio esqueleto: entrada, quieto, caminar, 3 ataques con Aviso e Impacto, cambio de fase, aturdido y derrota. En la Beta, Remache.

> [!info] En la Beta
> Solo **Remache** (2 fases). Los demás jefes de la tabla, en la Post beta, uno por sesión.

## 1. Para qué es
La pelea final de la Beta. Los jefes **avisan antes de pegar**: el marcador `Aviso` pinta el piso de rojo 0,4 s antes del `Impacto`, así la pelea es justa.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/remache.blend` (el modelo exportado), script `scripts/animaciones/remache.py`, FBX en `arte/animaciones/jefes/remache/`.

## 2. Qué leer antes
- [[Remache]] (fases, frases, 2.000 de vida)
- [[Remache (modelo)]] (el rig: jefe a 1,6x, pistones aparte)
- [[Galpón de Remache]] (la arena)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Remache: hoja de ataques** → guardar como `linajes/arte/referencias/gemini/anim-jefes/remache-ataques.png`
```
Boss animation key-pose sheet: a huge stylized blocky former dockworker (1.6x player size) with hydraulic piston arms ending in hammer fists, a welding helmet with a red visor, red-liquid tubes on his back, rust and steel colors. Row 1: raises both fists overhead then slams the ground making a 10-stud red ring. Row 2: pistons charge with steam, then he rams forward in a straight line. Row 3: lifts a shipping container overhead and throws it. Three poses per row (warning, impact, recovery), red warning circles on the floor, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Remache: cambio de fase y derrota** → guardar como `linajes/arte/referencias/gemini/anim-jefes/remache-fase.png`
```
Boss key-pose sheet of the same piston-armed brute: phase change where he injects glowing red liquid from a back tube, roars, steam bursts from the pistons and the red glow intensifies; then defeat: knees buckle, one arm sparks, he collapses forward on his fists. Comic-book exaggeration, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las notas linajes/boveda/07 NPCs/Remache.md y 04 Personajes/Remache/Remache (modelo).md y mirá las
imágenes de linajes/arte/referencias/gemini/anim-jefes/.
Abrí linajes/arte/blender/remache.blend. Animá su esqueleto a 30 fps (prioridad Action; la entrada y
el cambio de fase en Action4). Marcador Impacto en cada golpe y marcador Aviso 12 cuadros (0,4 s)
antes de cada Impacto. Los pistones son mallas aparte: animalas con el hueso de cada antebrazo
(se estiran 0,8 studs al golpear). Script en linajes/arte/scripts/animaciones/remache.py.

ANIMACIONES DE REMACHE
- Entrada (90): está de espaldas trabajando; se da vuelta, golpea los puños, vapor de los pistones.
- Quieto amenazante (loop 60): respira pesado, los pistones suben y bajan.
- Caminar pesado (loop 40): cada paso sacude (marcador Paso para la sacudida de cámara).
- Ataque 1 "Martillazo doble" (48): levanta los dos puños (Aviso 18), golpe al piso (Impacto 30),
  círculo de 10 studs, se queda trabado 10 cuadros (ventana para pegarle).
- Ataque 2 "Carga hidráulica" (inicio 24 + loop 16 + choque 20): se agacha (Aviso 12), corre en línea
  recta 30 studs (lo mueve el código), Impacto al chocar; si choca con la pared, queda aturdido.
- Ataque 3 "Contenedor" (70, solo fase 2): lo levanta (0-40, Aviso 28), lo lanza (Impacto 40).
- Recibir golpe fuerte (20). Aturdido (loop 40).
- Cambio de fase (60, a 50 % de vida): se inyecta el líquido rojo por un tubo, ruge, vapor.
- Derrota (90): las rodillas ceden, un brazo echa chispas, cae sobre los puños. Frase final.

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-jefes/remache-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/jefes/remache/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.jefes/remache) y probá
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
- El jefe usa **su propio rig**, no el R15; probalo en Studio con el modelo de Remache, no con el Dummy.

## 6. Pasos y puntos de control
### Paso 1: Hoja de tiras
Las 9 animaciones de Remache.

**Para dar el OK:**
- [ ] Cada ataque se anuncia (Aviso) y se entiende qué va a hacer.
- [ ] Queda una ventana para pegarle después del martillazo.
- [ ] Los pistones se mueven con los golpes.

### Paso 2: Publicar y probar
FBX, importar con el modelo, publicar, IDs.

**Para dar el OK:**
- [ ] Aviso e Impacto llegan al código.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, 9 FBX y hoja de tiras.
- IDs en `Config.luau` (Animaciones.jefes.remache).

**Cómo lo probás vos:**
- Hoja de tiras en Obsidian.
- En Studio, Remache hace la entrada y los 3 ataques.




## Un prompt por cosa
Cada uno está separado, con sus referencias de Gemini y su bloque para Claude. Este prompt queda con las **reglas comunes**.

- [[P28-01 Animaciones de Remache]] (**Sí**)
- [[P28-02 Animaciones de El Albatros]] (No)
- [[P28-03 Animaciones de Mascarada]] (No)
- [[P28-04 Animaciones de Víctor Halden (exoarmadura)]] (No)
- [[P28-05 Animaciones de El Eclipsador]] (No)

---
[[P27 Animaciones de los 3 primeros Linajes|← P27 Animaciones de los 3 primeros Linajes]]   ·   [[Todos los prompts]]   ·   [[P29 Animaciones de NPCs y enemigos|P29 Animaciones de NPCs y enemigos →]]
