---
tags: [prompt, personaje]
prompt: 18
estado: pendiente
---
# Prompt 18 · El Eclipsador
(DC de trabajo: Darkseid) · jefe final · archivo `eclipsador`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/eclipsador/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a giant of black stone #0e1016 with fiery cracks #f2652b, an eclipse ring of fire in the chest and a crown of black rays. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/eclipsador/ref-2.png`
```
Character turnaround sheet of the same character (a giant of black stone #0e1016 with fiery cracks #f2652b, an eclipse ring of fire in the chest and a crown of black rays): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/eclipsador/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de El Eclipsador en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/eclipsador/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/eclipsador.blend.

PERSONAJE: El Eclipsador. Tirano de Umbra, causó el eclipse. MODELO COMPLETO CON RIG PROPIO (no es un
traje sobre el maniquí). Diseño propio: SIN cara de piedra gris con ojos rojos de Darkseid, SIN falda
azul, SIN "rayos omega" rojos (sus rayos son negros con borde naranja).
ESCALA: 3x el maniquí (≈ 15 studs de alto).
SILUETA: gigante de roca negra volcánica con un eclipse ardiendo en el pecho y una corona de rayos negros.
PIEZAS (cada malla ≤ 20.000 tris, total ≤ 60.000):
1. Cabeza y corona (≤ 12.000): cráneo de roca negra (#15141a) facetada, sin boca visible, 2 ojos neon-eclipse,
   corona de 7 rayos de obsidiana con borde corona (#ffb347).
2. Torso (≤ 18.000): roca con grietas de lava naranja, en el centro un EMBLEMA PROPIO: disco negro con aro
   neon-eclipse (un eclipse), 1,5 studs, que late.
3. Brazos (≤ 14.000 los dos): roca con placas de obsidiana, manos de 4 dedos con garras.
4. Piernas (≤ 12.000 las dos): columnas de roca, pies anchos.
5. Manto de humo sólido (≤ 4.000): tiras de tela negra rígida que caen de los hombros.
RIG: esqueleto propio compatible con Animation Editor de Roblox (raíz HumanoidRootPart, 15 huesos con los
mismos nombres que R15). Pesos limpios en codos, rodillas y cuello.
PASO 1: boceto de bloques al lado del maniquí, esperá mi OK. PASO 2: detalle + 3 vistas + primeros planos
de cara, eclipse del pecho y manos. Probá el rig doblando brazos y piernas en un render. Esperá mi OK.
PASO 3: exportá con el rig a linajes/arte/exports/eclipsador/, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- eclipsador (deja el .glb y los
renders en linajes/boveda/04 Personajes/El Eclipsador/) y escribí o actualizá la nota El Eclipsador (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P17 Gorrión|← P17 Gorrión]]   ·   [[Todos los prompts]]   ·   [[P19 NPCs|P19 NPCs →]]
