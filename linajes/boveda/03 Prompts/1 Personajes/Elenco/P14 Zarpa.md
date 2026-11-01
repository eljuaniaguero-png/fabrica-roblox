---
tags: [prompt, personaje]
prompt: 14
estado: pendiente
---
# Prompt 14 · Zarpa
(DC de trabajo: Catwoman) · Neutral · archivo `zarpa`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/zarpa/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a master thief in a tight black suit with retractable claws, round amber-lens goggles, a coiled cable tail and soft-soled boots. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/zarpa/ref-2.png`
```
Character turnaround sheet of the same character (a master thief in a tight black suit with retractable claws, round amber-lens goggles, a coiled cable tail and soft-soled boots): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/zarpa/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Zarpa en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/zarpa/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/zarpa.blend.

PERSONAJE: Zarpa. Ladrona que trabaja para quien pague más. Diseño propio: SIN orejas de gato, SIN látigo,
SIN traje de cuero negro brillante entero.
SILUETA: ladrona ágil con capucha corta, antiparras grandes, garras retráctiles en los guantes.
PIEZAS:
1. Capucha corta y antiparras (Head) — 6.000 tris: capucha gris neutral, antiparras de 2 lentes redondas
   ámbar (#f2a23a, emission 1) con correa.
2. Chaqueta corta con bufanda (UpperTorso) — 7.000 tris: gris oscuro con parches, bufanda larga que flota.
3. Guantes con garras (Hands) — 4.000 tris el par: 4 garras de acero retráctiles (se animan).
4. Pantalón con rodilleras y riñonera de herramientas de ladrón (LowerTorso + Legs) — 6.000 tris.
5. Botas silenciosas (Feet) — 2.000 tris el par.
6. EMBLEMA PROPIO en la riñonera — 500 tris: tres arañazos paralelos.
TOTAL ≤ 26.000 tris. Primeros planos: antiparras, garras afuera, bufanda.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/zarpa/, script en scripts/personajes/zarpa.py,
commit "Linajes: traje de Zarpa" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- zarpa (deja el .glb y los
renders en linajes/boveda/04 Personajes/Zarpa/) y escribí o actualizá la nota Zarpa (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P13 El Albatros|← P13 El Albatros]]   ·   [[Todos los prompts]]   ·   [[P15 Confeti|P15 Confeti →]]
