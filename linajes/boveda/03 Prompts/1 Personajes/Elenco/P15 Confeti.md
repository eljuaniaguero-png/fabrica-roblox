---
tags: [prompt, personaje]
prompt: 15
estado: pendiente
---
# Prompt 15 · Confeti
(DC de trabajo: Harley Quinn) · Cofradía · archivo `confeti`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/confeti/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: an acrobat in a harlequin-free diamond pattern suit in fair colors (amber #f2a23a, cyan, crimson), a giant spring mallet, pigtails and a sequined domino mask. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/confeti/ref-2.png`
```
Character turnaround sheet of the same character (an acrobat in a harlequin-free diamond pattern suit in fair colors (amber #f2a23a, cyan, crimson), a giant spring mallet, pigtails and a sequined domino mask): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/confeti/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Confeti en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/confeti/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/confeti.blend.

PERSONAJE: Confeti. Acróbata de feria que se unió a Mascarada. Diseño propio: SIN rombos rojo y negro,
SIN coletas bicolores, SIN bate de béisbol, SIN gorro de bufón.
SILUETA: acróbata con chaqueta de feria, mazo enorme de resorte, rodete alto.
PIEZAS:
1. Pelo en rodete alto con cintas (Head) — 4.000 tris: rubio con cintas turquesa y rosa.
2. Chaqueta de domadora de circo (UpperTorso) — 7.000 tris: turquesa (#2bb3a6) y rosa (#e05a8a) con
   botones dorados y hombreras con flecos.
3. Short y medias rayadas horizontales (LowerTorso + Legs) — 5.000 tris.
4. Mazo de resorte (RightHand) — 6.000 tris: mango largo, cabeza de mazo de feria con un resorte gigante
   entre mango y cabeza (se anima), pintado con estrellas.
5. Botas de acróbata (Feet) — 2.000 tris.
6. EMBLEMA PROPIO en la chaqueta — 500 tris: un confeti de 5 papelitos en estrella.
TOTAL ≤ 25.000 tris. Primeros planos: mazo, rodete, chaqueta.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/confeti/, script en scripts/personajes/confeti.py,
commit "Linajes: traje de Confeti" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- confeti (deja el .glb y los
renders en linajes/boveda/04 Personajes/Confeti/) y escribí o actualizá la nota Confeti (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P14 Zarpa|← P14 Zarpa]]   ·   [[Todos los prompts]]   ·   [[P16 Dualidad|P16 Dualidad →]]
