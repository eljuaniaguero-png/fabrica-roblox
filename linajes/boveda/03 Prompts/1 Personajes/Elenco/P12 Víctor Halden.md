---
tags: [prompt, personaje]
prompt: 12
estado: pendiente
---
# Prompt 12 · Víctor Halden
(DC de trabajo: Lex Luthor) · Cofradía · archivo `halden`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/halden/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a bald tycoon in a dark grey suit with a gold tie, and for battle a dark green and gold plated exo-armor with thrusters. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/halden/ref-2.png`
```
Character turnaround sheet of the same character (a bald tycoon in a dark grey suit with a gold tie, and for battle a dark green and gold plated exo-armor with thrusters): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/halden/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Víctor Halden en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/halden/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/halden.blend.

PERSONAJE: Víctor Halden. Dueño de Corona Corp, vende implantes ilegales. Dos versiones del mismo
personaje: traje de empresario (NPC) y exoarmadura (jefe). Diseño propio: SIN armadura verde y violeta
de Luthor; la exoarmadura es negra y dorada con líneas cofradia.
PIEZAS VERSIÓN EMPRESARIO (≤ 15.000 tris): traje de tres piezas gris grafito, corbata cofradia, anteojos
finos de oro, reloj, bastón con mango de sol (logo de Corona Corp: una corona de 5 puntas sobre un anillo).
PIEZAS VERSIÓN EXOARMADURA (escala 1,3x, ≤ 38.000 tris):
1. Casco cerrado (Head) — 7.000 tris: negro brillante con visor horizontal de oro.
2. Torso blindado (Torso) — 10.000 tris: placas negras con bordes de oro, reactor en el pecho con la corona
   de Corona Corp en neon-eclipse.
3. Brazos con lanzamisiles en los antebrazos (Arms) — 10.000 tris: 4 tubos por brazo que se abren.
4. Piernas con propulsores en los tobillos (Legs + Feet) — 8.000 tris.
5. Capa corta de placas (espalda) — 3.000 tris.
Primeros planos: casco, reactor, lanzamisiles abiertos. Renderizá las dos versiones lado a lado.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/halden/, script en scripts/personajes/halden.py,
commit "Linajes: traje de Víctor Halden" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- halden (deja el .glb y los
renders en linajes/boveda/04 Personajes/Víctor Halden/) y escribí o actualizá la nota Víctor Halden (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P11 Heredero Abisal|← P11 Heredero Abisal]]   ·   [[Todos los prompts]]   ·   [[P13 El Albatros|P13 El Albatros →]]
