---
tags: [prompt, personaje]
prompt: 13
estado: pendiente
---
# Prompt 13 · El Albatros
(DC de trabajo: Pingüino) · Cofradía · archivo `albatros`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/albatros/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a short wide harbor boss (0.9 tall, 1.2 wide) in a long navy #1c2433 captain's coat to the calves, grey fur collar, white scarf, captain's cap and a harpoon-tipped cane; no tuxedo, no monocle, no umbrella. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/albatros/ref-2.png`
```
Character turnaround sheet of the same character (a short wide harbor boss (0.9 tall, 1.2 wide) in a long navy #1c2433 captain's coat to the calves, grey fur collar, white scarf, captain's cap and a harpoon-tipped cane; no tuxedo, no monocle, no umbrella): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/albatros/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de El Albatros en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/albatros/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/albatros.blend.

PERSONAJE: El Albatros. Jefe mafioso de Puerto Óxido, dueño del contrabando. Diseño propio: SIN smoking con
frac, SIN monóculo, SIN paraguas, SIN nariz ganchuda.
SILUETA: bajo y ancho, abrigo largo de capitán de barco, bastón-arpón, gorra de capitán.
PIEZAS:
1. Gorra de capitán (Head) — 3.000 tris: azul marino oscuro con ancla de oro.
2. Abrigo de capitán (Torso + hasta las pantorrillas) — 11.000 tris: azul marino #1c2433 con cuello de
   piel gris, 2 filas de botones de oro, charreteras con flecos.
3. Bufanda blanca (Head/UpperTorso) — 2.000 tris.
4. Bastón-arpón (RightHand) — 3.000 tris: madera con punta de arpón de acero y cadena enrollada.
5. Guantes de cuero y botas de marinero (Hands + Feet) — 4.000 tris.
6. EMBLEMA PROPIO en la gorra y el abrigo — 500 tris: un albatros con alas abiertas en oro.
Escala del maniquí 0,9x de alto y 1,2x de ancho. TOTAL ≤ 24.000 tris.
Primeros planos: gorra, bastón-arpón, emblema.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/albatros/, script en scripts/personajes/albatros.py,
commit "Linajes: traje de El Albatros" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- albatros (deja el .glb y los
renders en linajes/boveda/04 Personajes/El Albatros/) y escribí o actualizá la nota El Albatros (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P12 Víctor Halden|← P12 Víctor Halden]]   ·   [[Todos los prompts]]   ·   [[P14 Zarpa|P14 Zarpa →]]
