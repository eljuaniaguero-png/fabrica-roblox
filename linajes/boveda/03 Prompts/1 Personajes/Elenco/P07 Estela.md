---
tags: [prompt, personaje]
prompt: 7
estado: pendiente
---
# Prompt 7 · Estela
(DC de trabajo: Flash) · Liga · archivo `estela`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/estela/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a speedster in an aerodynamic violet #5a3fa0 suit with thin plates, a helmet with a long cyan visor, cyan #3fe0f0 light lines along the sides, an original emblem of three slanted lines over a light-violet diamond; no red, no lightning bolt. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/estela/ref-2.png`
```
Character turnaround sheet of the same character (a speedster in an aerodynamic violet #5a3fa0 suit with thin plates, a helmet with a long cyan visor, cyan #3fe0f0 light lines along the sides, an original emblem of three slanted lines over a light-violet diamond; no red, no lightning bolt): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/estela/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Estela en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/estela/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/estela.blend.

PERSONAJE: Estela. Velocista: el rayo del eclipse le dio velocidad. Diseño propio: SIN rojo, SIN rayo en el
pecho ni en las orejas, SIN alas en la cabeza.
SILUETA: traje ajustado y aerodinámico, visor alargado hacia atrás, líneas de luz que recorren el cuerpo.
PIEZAS:
1. Casco con visor (Head) — 7.000 tris: violeta oscuro (#3d2a6b), visor cian translúcido que se alarga 0,5
   studs hacia atrás, aletas finas en las sienes.
2. Traje ajustado (Torso + brazos + piernas, una pieza por parte del cuerpo) — 14.000 tris total:
   violeta (#5a3fa0) con placas finas en pecho, hombros y muslos; LÍNEAS DE LUZ neon-cian de 0,05 studs
   que bajan por los costados, brazos y piernas como circuitos.
3. EMBLEMA PROPIO en el pecho — 1.000 tris: tres líneas paralelas inclinadas (estela de velocidad)
   neon-cian sobre un rombo violeta claro.
4. Guantes y botas aerodinámicos (Hands + Feet) — 6.000 tris: suela gruesa con 3 ranuras neon-cian.
5. Mochila-condensador chica (UpperTorso, espalda) — 3.000 tris: acero con anillo neon-cian.
TOTAL ≤ 31.000 tris. Colores: 70 % violetas, 20 % acero, 10 % neon-cian.
Primeros planos del PASO 2: casco, emblema, botas.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/estela/, script en scripts/personajes/estela.py,
commit "Linajes: traje de Estela" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- estela (deja el .glb y los
renders en linajes/boveda/04 Personajes/Estela/) y escribí o actualizá la nota Estela (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P06 Remache|← P06 Remache]]   ·   [[Todos los prompts]]   ·   [[P08 Atalanta|P08 Atalanta →]]
