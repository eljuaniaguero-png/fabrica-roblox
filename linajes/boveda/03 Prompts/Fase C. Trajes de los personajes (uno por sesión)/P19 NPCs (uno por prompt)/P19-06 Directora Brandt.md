---
tags: [prompt, personajes]
beta: "No"
---
# P19-06 Directora Brandt

> [!summary] En tres líneas
> Modelo de **Directora Brandt**: civil, no superhéroe, sobre el cuerpo R15. 12.000 a 20.000 triángulos.

> [!info] En la Beta
> No

## 1. Para qué es
NPC con el que hablás y trabajás. Ropa: Traje sastre negro, auricular, carpeta con sello (ojo en triángulo invertido), pelo corto.

**Qué tener abierto:** Blender con el conector, Gemini y Obsidian.

**Dónde queda:** `linajes/arte/blender/npc-brandt.blend`, exports en `linajes/arte/exports/npc-brandt/`, nota en `04 Personajes/Directora Brandt/`.

## 2. Qué leer antes
- [[Directora Brandt]] (cómo es y cómo habla)
- [[P19 NPCs]] (reglas comunes)
- [[Cuerpo propio]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/npc-brandt/ref-1.png`
```
Full-body character concept of an original NPC for a stylized Roblox superhero game: a stern government director with short hair, a sharp black suit, an earpiece and a folder with an original seal of an eye inside an inverted triangle. Three-quarter view, relaxed pose, standing on a foggy harbor street at night. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/npc-brandt/ref-2.png`
```
Character turnaround sheet of the same NPC (a stern government director with short hair, a sharp black suit, an earpiece and a folder with an original seal of an eye inside an inverted triangle): front, side and back views on a plain grey background, same scale, neutral A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/npc-brandt/ref-3.png`
```
Detail sheet with four close-ups pointed by arrows (no text) of the same NPC: face and hair, the main garment's seams and wear, the signature prop, shoes and hands. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Directora Brandt. Mirá las imágenes de
linajes/arte/referencias/gemini/npc-brandt/. Abrí kit-base.blend y guardalo como linajes/arte/blender/npc-brandt.blend.
NPC: Directora Brandt. ROPA Y DETALLES: Traje sastre negro, auricular, carpeta con sello (ojo en triángulo invertido), pelo corto.
Modelá la ropa sobre el maniquí R15 (cuerpo propio): 12.000 a 20.000 tris total, ≤ 20.000 por malla,
un material por malla. Props en mallas aparte. Cara con la textura de expresiones del cuerpo propio.
PASO 1 boceto + 3 vistas → mi OK. PASO 2 detalle (costuras, desgaste, pliegues) + 3 vistas con luz + 3
primeros planos → mi OK. PASO 3 exportá a linajes/arte/exports/npc-brandt/, script scripts/npcs/brandt.py,
commit y push.
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
- [ ] Se reconoce quién es por la silueta.
- [ ] Nada de DC.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Los colores son los de su nota.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, FBX, renders y nota.

**Cómo lo probás vos:**
- Girá el modelo en Obsidian.

---
[[P19-05 Dra. Kessler|← P19-05 Dra. Kessler]]   ·   [[P19 NPCs]]   ·   [[P19-07 Señal|P19-07 Señal →]]
