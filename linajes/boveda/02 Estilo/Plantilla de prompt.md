---
tags: [estilo, prompts, plantilla]
---
# Plantilla de prompt

Todos los prompts de [[Todos los prompts]] siguen esta plantilla, en este orden. Así cada prompt trae **todo** lo que Claude necesita y vos sabés exactamente qué esperar y cómo aprobarlo.

> [!tip] Cómo se usa un prompt
> 1. Leé **Para qué es** y **Qué tener abierto**.
> 2. Copiá los **prompts de Gemini** de a uno en Gemini y guardá las imágenes en `linajes/arte/referencias/gemini/<archivo>/` con el nombre que dice cada uno (`ref-1.png`, `ref-2.png`...).
> 3. Copiá el **bloque para Claude** entero y pegalo en Claude Code en tu PC.
> 4. En cada **punto de control**, revisá la lista de "Para dar el OK" antes de contestar.

---

## 1. Para qué es
Dos o tres líneas: qué se hace, para qué sirve en el juego y en qué parte de la Beta entra.

**Qué tener abierto:** Blender con el conector de Claude / Roblox Studio con `rojo serve linajes/linajes.project.json` / Obsidian. Lo que haga falta, nada más.

**Dónde queda:** archivo `.blend`, script, carpeta de exports, nota de Obsidian.

## 2. Qué leer antes
Enlaces a las notas que Claude y vos tienen que tener frescas: el personaje o lugar en `04 Personajes`, `07 NPCs` o `08 Lugares`, la historia en `05 Historia` si importa, [[Guía de estilo]], [[Nivel de detalle]], [[Colores]] y [[Reglas de los prompts]].

## 3. Referencias para Gemini (mínimo 2)
Cada prompt de Gemini va en un bloque aparte, **en inglés** (Gemini responde mejor así), con una línea arriba en castellano que dice **qué tiene que salir**. Todos incluyen, al final, la **cola fija**:

```
Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale where it makes sense.
```

Tipos de imagen (se eligen 2 o más según el prompt):
- **Vista general**: el personaje entero en pose neutra, el lugar entero en isométrica o la habitación desde la puerta.
- **Hoja de detalle**: primeros planos de piezas, materiales y desgaste, rotulados con flechas y sin texto inventado.
- **Vistas ortográficas** (personajes y props): frente, costado y espalda en fondo gris liso, misma escala.
- **Planta** (lugares e interiores): vista desde arriba con las zonas.
- **Luz y clima**: el mismo lugar de noche con la paleta del juego.

> [!warning] Las imágenes de Gemini son **solo referencia**: nunca se suben a Roblox ni se copian tal cual. Si una imagen trae algo de DC, de otro juego o un logo, se descarta y se pide de nuevo.

## 4. El bloque para Claude
Un solo bloque de código con:
- **Archivo y arranque**: qué `.blend` abrir y con qué nombre guardar, qué script crear (`linajes/arte/scripts/...`).
- **Medidas generales** en studs (alto, ancho, fondo) y la **escala**: 1 stud = 0,28 m, un jugador mide 5 studs.
- **Lista de piezas**, una por renglón, cada una con:
  `Nombre_Pieza` · forma (qué es y cómo se arma) · medidas en studs · posición (respecto del pivote) · material de la guía y **color en hex** · **tope de triángulos** · si **brilla** (`Neon_`), si es **vidrio** (`Glass_`), si **se mueve** (malla aparte) o si lleva **choque** (`_Colision`).
- **Detalle obligatorio** de cada pieza grande: qué capas, costuras, remaches, bordes, desgaste.
- **Total de triángulos** y tope por malla (≤ 20.000).
- **Lo que NO lleva** (para que no aparezca nada de DC ni de las referencias).

## 5. Reglas de Roblox que aplican
Copiadas de [[Reglas de los prompts]], solo las que tocan a este prompt: escala y medidas para jugar, choques, `Neon_`/`Glass_`, pivote, caras ocultas, chequeo de cruces y de cosas flotando, piezas largas y memoria del horneado.

## 6. Pasos y puntos de control
- **PASO 1, boceto**: bloques sin detalle y renders. **Para dar el OK**: lista concreta (silueta, medidas, que se lea a la distancia de juego, que nada se cruce).
- **PASO 2, detalle**: el [[Nivel de detalle]] completo, texturas horneadas y renders con luz. **Para dar el OK**: lista concreta (topes de triángulos, chequeo de cruces en cero, se parece a las referencias de Gemini en lo que importa, nada copiado).
- **PASO 3, entrega**: exportar, nota de Obsidian, commit y push.

## 7. Qué se entrega y cómo lo probás
- Archivos: `.blend`, script, FBX (con `Neon_`, `Glass_` y `_Colision`), texturas, renders y tabla de triángulos.
- Obsidian: nota del modelo o lugar con el modelo 3D para girar, los renders, la tabla y el estado; la fila en su lista; y el prompt tildado en [[Todos los prompts]].
- **Cómo lo probás vos**: qué mirar en Obsidian, y si ya se puede, qué hacer en Studio.

---

## Ejemplo de prompts de Gemini (taller de Tano)

Vista general, desde la puerta (que se vea la distribución y la luz):
```
Interior of a small mechanic garage in a rundown harbor district at night, seen from the entrance at eye level. 48 x 40 studs footprint, 12-stud walls of dark brick reinforced with riveted steel plates, exposed I-beams and crossing rusty pipes and cable trays on the ceiling, hanging industrial lamps with warm light, a cold cyan neon tube above the roll-up door. Two-post yellow car lift with a boxy compact car raised on it, a mechanic creeper under it. Back wall: heavy wooden workbench with steel edge banding, real drawers (one open), a vise, a half-built grappling-hook gadget, pegboard with modeled wrenches, pliers and hammers. A crafting table with a cyan screen in the middle. Concrete floor with oil stains, cracks and diamond-plate steel mats. Red tool cart, rusty drums, red air compressor, metal locker. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

Hoja de detalle (materiales y piezas, con flechas y sin texto):
```
Game asset detail sheet on a dark blueprint background: four labeled-by-arrow close-ups (no text) of the same mechanic garage: 1) wall module of dark brick with overlapping riveted steel plates and a bolted cover strip, 2) ceiling junction of two I-beams with a pipe cluster and a hanging cable tray, 3) floor: cracked concrete slabs with oil stains and a diamond-plate steel mat with dirty seams, 4) workbench with steel edge banding, dented corners, deep drawers and modeled hand tools. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

Volver a [[Reglas de los prompts]] · [[Todos los prompts]]
