---
tags: [prompt, animaciones]
beta: "Solo el **gancho** (tirar, colgarse, soltarse) y **fabricar en el banco del taller**. Los demás gadgets, implantes, vehículos y escenas, en la Post beta."
---
# P26b Animaciones de tecnología, gadgets y vehículos

> [!summary] En tres líneas
> Animaciones del cuerpo con gadgets, implantes y vehículos. En la Beta, el gancho y el banco del taller.

> [!info] En la Beta
> Solo el **gancho** (tirar, colgarse, soltarse) y **fabricar en el banco del taller**. Los demás gadgets, implantes, vehículos y escenas, en la Post beta.

## 1. Para qué es
El gancho es el gadget de la Beta (lo arreglás con Tano) y la forma de subir a los techos del puerto. Fabricar en el banco es el momento de recompensa del taller.

**Qué tener abierto:** Blender con el conector de Claude (puerto 9876) y Claude Code en `fabrica-roblox`. Para el último paso, Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/blender/animaciones-tecnologia.blend`, script `scripts/animaciones/tecnologia.py`, FBX en `arte/animaciones/tecnologia/`.

## 2. Qué leer antes
- [[Mejoras (tecnología, implantes, transferencias)]]
- [[Animaciones (plan completo)]] secciones 5 y 6
- [[Taller de Tano]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Gancho: tirar, colgarse y soltarse** → guardar como `linajes/arte/referencias/gemini/anim-tecnologia/gancho.png`
```
Animation key-pose sheet of a stylized blocky Roblox-proportioned hero in a plain grey suit using a wrist-mounted grappling hook: aiming up, firing the hook, being pulled up with legs tucked, hanging and swinging from the rope, letting go and landing in a crouch. Thin cyan cable, harbor rooftop edge hinted, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Fabricar en el banco del taller** → guardar como `linajes/arte/referencias/gemini/anim-tecnologia/banco.png`
```
Pose sheet of the same hero at a heavy wooden workbench: putting parts on the bench, hammering, welding with a small torch (orange sparks), holding up a finished gadget proudly. Grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las secciones 5 y 6 de Animaciones (plan completo) y la nota del Taller de Tano. Mirá las
imágenes de linajes/arte/referencias/gemini/anim-tecnologia/.
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-tecnologia.blend. 30 fps, R15.

GANCHO (Beta): apuntar (8), disparar (10, marcador Disparo en 6), subir tirado (loop 16, piernas
recogidas), colgarse (loop 40, balanceo), soltarse (12), caer en cuclillas (10).
BANCO DEL TALLER (Beta): apoyar piezas (20), martillar (loop 24, marcador Golpe en 12), soldar (loop 32,
marcador Chispa), mostrar lo fabricado (40).
POST BETA (no hacer ahora): granada de humo, dron, boleadoras, red, linterna cegadora, escudo plegable,
botiquín, implantes (cañón, puño hidráulico, doble salto), escenas (implante, traje, transferencia) y
vehículos (subir, bajar, manejar, salir de un choque).
Lo que no es cuerpo (el cable, chispas) va por código en linajes/src/client/, números en Config.luau.

CIERRE (igual para todas):
- Para cada animación: tira de 3 cuadros clave (anticipación, impacto o pose máxima, recuperación) en
  linajes/arte/renders/anim-tecnologia-<nombre>.png, y una HOJA con todas las tiras juntas. Mandá la hoja a
  la nota de Obsidian del grupo de animaciones (sección "Hechas"). Esperá mi OK.
- Con mi OK: exportá cada Action como FBX a linajes/arte/animaciones/tecnologia/<nombre>.fbx (solo el
  esqueleto, sin malla, 30 fps, 'Bake Animation' activado, 'Add Leaf Bones' apagado).
- En Studio, por MCP: insertá un Dummy R15 en workspace.PruebasAnim, y decime exactamente qué tengo que
  tocar para importar y publicar cada una (Animation Editor → ⋯ → Import → From FBX Animation → Publish).
- Cuando te pase los IDs, anotalos en linajes/src/shared/Config.luau (tabla Animaciones.tecnologia) y probá
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
Gancho y banco.

**Para dar el OK:**
- [ ] El gancho se entiende sin efectos.
- [ ] Fabricar se siente como una recompensa.

### Paso 2: Publicar y probar
FBX, importar, publicar, IDs.

**Para dar el OK:**
- [ ] Disparo y Golpe llegan al código.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX, hoja de tiras.
- IDs en `Config.luau`.

**Cómo lo probás vos:**
- En Studio, el Dummy usa el gancho.

---
[[P29b Animaciones de la calle viva|← P29b Animaciones de la calle viva]]   ·   [[Todos los prompts]]   ·   [[P30 Animaciones de objetos|P30 Animaciones de objetos →]]
