---
tags: [prompt, lugares]
beta: "**Sí** (el atraco)"
---
# P25d-03 Almacén del muelle

> [!summary] En tres líneas
> Interior de **Almacén del muelle** (Puerto), 48 x 32 studs, 16 de alto. Se entra caminando, sin pantalla de carga. Primero 3 referencias de Gemini, después boceto, detalle y entrega.

> [!info] En la Beta
> **Sí** (el atraco)

## 1. Para qué es
Arma por dentro Almacén del muelle. Luz fría y oscura con un haz de luna; chapa gris, madera de cajas.

**Qué tener abierto:** Blender con el conector de Claude, Gemini en el navegador y Obsidian.

**Dónde queda:** `linajes/arte/blender/interior-almacen.blend`, script `linajes/arte/scripts/interiores/almacen.py`, exports en `linajes/arte/exports/interior-almacen/`, nota en [[Puerto Óxido]].

## 2. Qué leer antes
- [[Puerto Óxido]]
- [[P25d Interiores donde se puede entrar]] (reglas comunes de interiores)
- [[Calle viva]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Vista general desde la puerta** → guardar como `linajes/arte/referencias/gemini/interior-almacen/ref-1.png`
```
Interior of a harbor storage warehouse at night, 48 x 32 studs, 16 studs tall, seen from the skylight above: rows of steel shelving full of wooden and cardboard crates, a small guard booth with a lit window, two security cameras on the walls, a small office in the corner with a heavy old safe, a padlocked back roll-up door, moonlight falling through the skylight, dusty air. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Planta desde arriba con las zonas** → guardar como `linajes/arte/referencias/gemini/interior-almacen/ref-2.png`
```
Top-down orthographic floor plan of this interior (48 x 32 studs), clean game-design blockout look: two entrances (front roll-up door locked, back door with padlock), guard booth near the front, two camera view cones, four rows of shelving, office with a safe in the north-east corner, skylight over the central aisle. Clear 6-stud walking lanes, each zone tinted a different muted color, 4-stud grid lines, simple icons, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: Hoja de detalle de materiales y piezas** → guardar como `linajes/arte/referencias/gemini/interior-almacen/ref-3.png`
```
Game asset detail sheet on a dark blueprint background with four close-ups pointed by arrows (no text) of the four most important pieces of this interior (walls, floor, the main furniture and the signature object), taken from this description: Interior of a harbor storage warehouse at night, 48 x 32 studs, 16 studs tall, seen from the skylight above: rows of steel shelving full of wooden and cardboard crates, a small guard booth with a lit window, two security cameras on the walls, a small office in the corner with a heavy old safe, a padlocked back roll-up door, moonlight falling through the skylight, dusty air. Show seams, rivets, bevels, wear and grime. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, linajes/boveda/02 Estilo/Reglas de los prompts.md, la nota
Puerto Óxido de linajes/boveda/08 Lugares/ (o 01 Juego) y las REGLAS COMUNES de
linajes/boveda/03 Prompts/Fase D.../P25d Interiores donde se puede entrar.md.
Mirá las 3 imágenes de linajes/arte/referencias/gemini/interior-almacen/ (distribución, proporciones y
desgaste; nunca una copia). Guardá kit-base.blend como linajes/arte/blender/interior-almacen.blend.

INTERIOR: Almacén del muelle (Puerto). MEDIDAS: 48 x 32 studs, 16 de alto. LUZ: fría y oscura con un haz de luna; chapa gris, madera de cajas.
PIEZAS (cada una con medidas en studs, material de la guía, color en hex y tope de triángulos):
- Portón trasero con candado (malla aparte)
- Claraboya en el techo para entrar en silencio (`Glass_`, malla aparte que se abre)
- Garita del guardia con ventanita y silla
- 2 cámaras (Parts `Camara`)
- 4 filas de estanterías con cajas (sin horneado)
- Oficina chica con caja fuerte (dial malla aparte) y escritorio
- Parts `Spawn_Guardia`, `Botin` y `Salida`
Parts vacíos para el código: Spawn_Guardia, Spawn_Civil, Camara, Botin, Salida, PuntoNPC_<nombre>
(los que apliquen). Tope ≤ 60.000 triángulos el interior, ≤ 20.000 por malla.

PASO 1: boceto de bloques + planta desde arriba + vista desde la puerta + vista desde el fondo, con el
maniquí. Chequeo de cruces y flotantes en 0. Esperá mi OK.
PASO 2: detalle completo (chapas, remaches, grietas, desgaste; muebles con cajones de verdad), 4 renders
con luz, 2 primeros planos, tabla de triángulos. Si el horneado no avanza en 5 min, frenalo y avisame.
Esperá mi OK.
PASO 3: FBX en linajes/arte/exports/interior-almacen/ (Neon_, Glass_, _Colision), script en
scripts/interiores/almacen.py, nota actualizada, prompt tildado. Commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y
los renders en la carpeta de la nota) y actualizá la nota con el modelo 3D para girar (bloque ```3D),
los renders, la tabla de triángulos y el estado. Abrí la nota con el conector y avisame.
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
- [ ] La puerta coincide con la fachada de su ciudad.
- [ ] Pasillos de 6 studs o más.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Se lee bien de noche y en celular.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script y FBX de Almacén del muelle.
- Renders y nota actualizada.

**Cómo lo probás vos:**
- Girá el modelo en Obsidian.
- Cuando se importe, caminá adentro en Studio.

---
[[P25d-02 Galpón de Remache|← P25d-02 Galpón de Remache]]   ·   [[P25d Interiores donde se puede entrar]]   ·   [[P25d-04 Banco Central Corona|P25d-04 Banco Central Corona →]]
