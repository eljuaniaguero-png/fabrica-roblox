---
tags: [prompt, personaje]
prompt: 9
estado: pendiente
---
# Prompt 9 · Arquitecto
(DC de trabajo: Green Lantern) · Liga · archivo `arquitecto`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/arquitecto/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: an inventor in a grey #3a3f4b space-worker suit with pockets and harness, a large steel gauntlet on the right arm with cyan neon lights, a work helmet with visor, cyan energy constructs. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/arquitecto/ref-2.png`
```
Character turnaround sheet of the same character (an inventor in a grey #3a3f4b space-worker suit with pockets and harness, a large steel gauntlet on the right arm with cyan neon lights, a work helmet with visor, cyan energy constructs): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/arquitecto/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Arquitecto en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/arquitecto/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/arquitecto.blend.

PERSONAJE: Arquitecto. Ingeniero que se fabricó un guantelete que convierte luz en objetos sólidos.
Diseño propio: SIN anillo, SIN verde, SIN linterna, SIN juramento, SIN cuerpo de policía espacial.
SILUETA: traje de obrero espacial con casco de visera, un guantelete enorme en el brazo derecho.
PIEZAS:
1. Casco con visera rebatible (Head) — 6.000 tris: blanco-armadura con franja liga, visera neon-cian.
2. Mameluco técnico (Torso + piernas) — 9.000 tris: gris (#5a606e) con bolsillos, rodilleras, arnés de
   herramientas en la cintura con 4 herramientas chicas.
3. GUANTELETE (RightLowerArm + RightHand) — 9.000 tris: acero, 3 veces más grueso que el brazo, 5 placas
   que se abren (se animan), núcleo prismático neon-cian en el dorso, cables que van al hombro.
4. Guante izquierdo simple (LeftHand) — 1.000 tris.
5. Mochila-generador (UpperTorso, espalda) — 4.000 tris: caja de acero con 2 aletas de disipación y luces cian.
6. EMBLEMA PROPIO en el hombro — 500 tris: un cubo de líneas (estructura de alambre) neon-cian.
7. Botas de obra (Feet) — 2.500 tris el par.
TOTAL ≤ 32.000 tris. Colores: 50 % gris, 30 % acero, 20 % neon-cian y liga.
Primeros planos: guantelete abierto y cerrado, casco, mochila.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/arquitecto/, script en scripts/personajes/arquitecto.py,
commit "Linajes: traje de Arquitecto" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- arquitecto (deja el .glb y los
renders en linajes/boveda/04 Personajes/Arquitecto/) y escribí o actualizá la nota Arquitecto (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P08 Atalanta|← P08 Atalanta]]   ·   [[Todos los prompts]]   ·   [[P10 Bastión|P10 Bastión →]]
