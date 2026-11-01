---
tags: [prompt, personaje]
prompt: 11
estado: pendiente
---
# Prompt 11 · Heredero Abisal
(DC de trabajo: Aquaman) · Liga · archivo `heredero`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/heredero/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: an undersea prince in dark coral and scale armor #1f4a5a, a two-pronged harpoon, greenish skin highlights, a cape of seaweed, cyan bioluminescent lights. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/heredero/ref-2.png`
```
Character turnaround sheet of the same character (an undersea prince in dark coral and scale armor #1f4a5a, a two-pronged harpoon, greenish skin highlights, a cape of seaweed, cyan bioluminescent lights): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/heredero/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Heredero Abisal en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/heredero/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/heredero.blend.

PERSONAJE: Heredero Abisal. Príncipe de la Ciudad Hundida bajo Puerto Óxido. Controla presión y corrientes.
Diseño propio: SIN escamas naranjas, SIN pantalón verde, SIN tridente de 3 puntas (usa arpón de 2 puntas).
SILUETA: armadura de coral oscuro con aletas en antebrazos, pelo largo atado, arpón doble.
PIEZAS:
1. Corona de coral (Head) — 4.000 tris: coral negro-azulado (#1f3a4a) con puntas y bioluminiscencia
   neon-cian en las puntas.
2. Coraza de escamas (Torso) — 10.000 tris: escamas superpuestas azul petróleo (#22505e, roughness 0,3)
   con placas de coral en hombros.
3. Aletas de antebrazo (LowerArms) — 4.000 tris el par: membrana translúcida con nervaduras.
4. Cinturón de conchas (LowerTorso) — 2.000 tris.
5. Grebas de coral y pies descalzos con aletas cortas (Legs + Feet) — 5.000 tris.
6. Arpón de dos puntas (RightHand) — 3.000 tris: 5 studs, asta de hueso, dos puntas de coral negro.
7. EMBLEMA PROPIO en el cinturón — 500 tris: una ola encerrada en un círculo.
TOTAL ≤ 29.000 tris. Colores: 60 % azul petróleo, 30 % coral oscuro, 10 % neon-cian.
Primeros planos: corona, aleta, arpón.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/heredero/, script en scripts/personajes/heredero.py,
commit "Linajes: traje de Heredero Abisal" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- heredero (deja el .glb y los
renders en linajes/boveda/04 Personajes/Heredero Abisal/) y escribí o actualizá la nota Heredero Abisal (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P10 Bastión|← P10 Bastión]]   ·   [[Todos los prompts]]   ·   [[P12 Víctor Halden|P12 Víctor Halden →]]
