---
tags: [prompt, personaje]
prompt: 17
estado: pendiente
---
# Prompt 17 · Gorrión
(DC de trabajo: Robin) · Vigilantes · archivo `gorrion`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/gorrion/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a short agile sidekick with a short feathered cape #3a3f4b, a domino mask, a padded vest, bolas at the waist, sneakers and violet #6b5ba8 accents. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/gorrion/ref-2.png`
```
Character turnaround sheet of the same character (a short agile sidekick with a short feathered cape #3a3f4b, a domino mask, a padded vest, bolas at the waist, sneakers and violet #6b5ba8 accents): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/gorrion/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Gorrión en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/gorrion/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/gorrion.blend.

PERSONAJE: Gorrión. Aprendiz de Cuervo, chico de la calle. Diseño propio: SIN "R" en el pecho, SIN capa
amarilla, SIN traje rojo-verde.
SILUETA: ágil, capa corta de plumas pardas, antifaz, boleadoras en el cinturón.
PIEZAS:
1. Antifaz y capucha corta (Head) — 4.000 tris: antifaz de acero oscuro, ojos neon-cian.
2. Chaqueta de plumas pardas (#7a5a3a) con capa corta (UpperTorso) — 8.000 tris.
3. Pantalón con rodilleras y cinturón con boleadoras (LowerTorso + Legs) — 5.000 tris: 3 bolas de acero
   unidas con cuerdas.
4. Guantes sin dedos y zapatillas (Hands + Feet) — 3.000 tris.
5. EMBLEMA PROPIO — 500 tris: una pluma chica de gorrión en vigilantes.
TOTAL ≤ 21.000 tris. Primeros planos: antifaz, boleadoras, capa.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/gorrion/, script en scripts/personajes/gorrion.py,
commit "Linajes: traje de Gorrión" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- gorrion (deja el .glb y los
renders en linajes/boveda/04 Personajes/Gorrión/) y escribí o actualizá la nota Gorrión (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P16 Dualidad|← P16 Dualidad]]   ·   [[Todos los prompts]]   ·   [[P18 El Eclipsador|P18 El Eclipsador →]]
