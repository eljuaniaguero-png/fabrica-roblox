---
tags: [prompt, personajes]
beta: "No"
---
# P20d-07 Vendedor de panchos

> [!summary] En tres líneas
> Civil especial: vendedor con carrito de panchos.

> [!info] En la Beta
> No

## 1. Para qué es
Civil especial: vendedor con carrito de panchos.

**Qué tener abierto:** Blender con el conector, Gemini y Obsidian.

**Dónde queda:** `linajes/arte/blender/civiles.blend`, exports en `linajes/arte/exports/civiles/`.

## 2. Qué leer antes
- [[Calle viva]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de todas las piezas** → guardar como `linajes/arte/referencias/gemini/civil-vendedor/ref-1.png`
```
Asset sheet of original modular pieces for a stylized blocky Roblox character creator: a street food vendor with a hot dog cart with an umbrella. Each piece shown front and side on grey background, consistent style. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Combinaciones de ejemplo** → guardar como `linajes/arte/referencias/gemini/civil-vendedor/ref-2.png`
```
Six blocky Roblox-proportioned characters wearing different combinations of these pieces (a street food vendor with a hot dog cart with an umbrella) in harbor colors with neon accents, front view, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y las notas de "Qué leer antes". Mirá linajes/arte/referencias/gemini/civil-vendedor/.
Abrí linajes/arte/blender/civiles.blend (o guardá kit-base.blend con ese nombre).
PIEZAS, cada una sobre el maniquí R15, con su tope:
- Vendedor ≤ 8.000
- Carrito con sombrilla y plancha
REGLAS: canales de color como materiales separados (Color1, Color2 y Color3 si dice) para cambiarlos por
código; tienen que verse bien con cualquier otra pieza; tope 8.000.
PASO 1: bocetos en grilla + 6 combinaciones, mi OK. PASO 2: detalle + 6 combinaciones con luz, mi OK.
PASO 3: FBX en linajes/arte/exports/civiles/<pieza>.fbx, script scripts/civiles.py, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- civiles (deja el .glb y
los renders junto a la nota) y actualizá la nota "Personajes" de la bóveda con el modelo 3D para girar
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
- [ ] Las piezas encajan entre sí.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Las combinaciones se ven bien.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, FBX de cada pieza, renders.

**Cómo lo probás vos:**
- Mirá las combinaciones en Obsidian.

---
[[P20d-06 Diarero|← P20d-06 Diarero]]   ·   [[P20d Civiles y testigos]]   ·   [[P20d-08 Músico callejero|P20d-08 Músico callejero →]]
