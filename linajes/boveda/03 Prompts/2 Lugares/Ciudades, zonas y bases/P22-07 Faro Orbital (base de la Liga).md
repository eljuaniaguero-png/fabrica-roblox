---
tags: [prompt, lugares]
beta: "No (Post beta)"
---
# P22-07 Faro Orbital (base de la Liga)

> [!summary] En tres líneas
> Kit modular de **Faro Orbital (base de la Liga)**: piezas que se repiten para armar el lugar entero, más los edificios importantes.

> [!info] En la Beta
> No (Post beta)

## 1. Para qué es
Kit: Estación con ventanal a la Tierra. Importantes: Sala de reuniones, hangar, mirador. Clima: Interior, azul `#2f6fdb` y dorado.

**Qué tener abierto:** Blender con el conector, Gemini y Obsidian.

**Dónde queda:** `linajes/arte/blender/faro-orbital.blend`, exports en `linajes/arte/exports/faro-orbital/`, nota de lugar.

## 2. Qué leer antes
- [[Centinela Solar]]
- [[Lugares]]
- [[P21 Puerto Óxido]] (cómo se hizo el kit del puerto)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Vista general isométrica** → guardar como `linajes/arte/referencias/gemini/lugar-faro-orbital/ref-1.png`
```
Isometric game-environment concept of a bright orbital station headquarters of a hero league: a round meeting room with a huge window showing the Earth, white and gold panels, blue accent lights, a small hangar. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Calle a la altura del jugador** → guardar como `linajes/arte/referencias/gemini/lugar-faro-orbital/ref-2.png`
```
Eye-level street view inside the same place (a bright orbital station headquarters of a hero league: a round meeting room with a huge window showing the Earth, white and gold panels, blue accent lights, a small hangar), showing how modular pieces repeat. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja del kit modular** → guardar como `linajes/arte/referencias/gemini/lugar-faro-orbital/ref-3.png`
```
Modular kit sheet on a dark blueprint background: each repeating piece of the same place shown separately on a 4-stud grid (walls, corners, doors, windows, roofs, props), pointed by arrows, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, la nota Centinela Solar y P21 Puerto Óxido (cómo se armó el kit del puerto:
mismas reglas). Mirá las imágenes de linajes/arte/referencias/gemini/lugar-faro-orbital/.
Guardá kit-base.blend como linajes/arte/blender/faro-orbital.blend.
LUGAR: Faro Orbital (base de la Liga). KIT MODULAR (grilla de 4 studs): Estación con ventanal a la Tierra. EDIFICIOS IMPORTANTES: Sala de reuniones, hangar, mirador. CLIMA: Interior, azul `#2f6fdb` y dorado.
Cada pieza: medidas en studs, material de la guía, color en hex, tope de triángulos, Neon_/Glass_/_Colision.
PASO 1 boceto de todas las piezas + una manzana armada → mi OK. PASO 2 detalle + renders con su luz
+ una manzana armada de detalle → mi OK. PASO 3 exportar a linajes/arte/exports/faro-orbital/, script
scripts/lugares/faro-orbital.py, nota actualizada, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- faro-orbital (deja el .glb y
los renders junto a la nota) y actualizá la nota "Centinela Solar" de la bóveda con el modelo 3D para girar
(bloque ```3D), los renders, la tabla de triángulos y el estado. Abrí la nota con el conector de
Obsidian y avisame que la mire ahí.
```

## 5. Reglas de Roblox que aplican
- Escala: 1 stud = 0,28 m; jugador de 5 studs; puertas de 4 x 7.
- Choque con mallas `_Colision` simples (cajas), nunca la malla de detalle.
- `Neon_` para lo que brilla, `Glass_` para vidrios; un material por malla; ≤ 20.000 triángulos por malla.
- Texturas: piso 1024, paredes 512, props 256; **nunca 2048**. Piezas de muchas partes chicas o de más de 30 studs: sin bisel ni horneado.
- Pivote en la base; caras ocultas borradas; chequeo de cruces y de cosas flotando en 0 antes de cada OK.
- Nada de logos, trajes, colores exactos ni nombres de DC; las imágenes de Gemini son solo referencia.

## 6. Pasos y puntos de control
### Paso 1: Boceto de bloques
Bloques grises sin detalle, renders con el maniquí de 5 studs.

**Para dar el OK:**
- [ ] La silueta y las medidas se leen a la distancia de juego.
- [ ] Nada se cruza ni flota (chequeo en 0).
- [ ] Las piezas encajan en la grilla de 4 studs.
- [ ] Una manzana armada se ve variada.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Se lee bien su paleta y su clima.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, FBX del kit, renders y nota.

**Cómo lo probás vos:**
- Mirá la manzana armada en Obsidian.

---
[[P22-06 El Nido (base de los Vigilantes)|← P22-06 El Nido (base de los Vigilantes)]]   ·   [[P22-25 Los otros lugares]]   ·   [[P22-08 La Fundición (base de la Cofradía)|P22-08 La Fundición (base de la Cofradía) →]]
