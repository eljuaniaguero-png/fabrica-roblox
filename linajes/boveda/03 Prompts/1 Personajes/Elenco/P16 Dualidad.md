---
tags: [prompt, personaje]
prompt: 16
estado: pendiente
---
# Prompt 16 · Dualidad
(DC de trabajo: Dos Caras) · Cofradía · archivo `dualidad`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/dualidad/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a former prosecutor in a suit split in two materials: one half neat light-grey prosecutor suit, the other half burnt leather #2a2018; one side of the face clean, the other with a metal plate; a two-sided die in hand. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/dualidad/ref-2.png`
```
Character turnaround sheet of the same character (a former prosecutor in a suit split in two materials: one half neat light-grey prosecutor suit, the other half burnt leather #2a2018; one side of the face clean, the other with a metal plate; a two-sided die in hand): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/dualidad/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Dualidad en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/dualidad/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/dualidad.blend.

PERSONAJE: Dualidad. Ex fiscal partido por un experimento del eclipse: cada mitad es de un material.
Diseño propio: SIN cara quemada, SIN moneda, SIN traje blanco y negro mitad y mitad clásico.
SILUETA: traje partido en vertical: mitad izquierda traje de fiscal azul marino, mitad derecha cristal
oscuro facetado con grietas de luz.
PIEZAS:
1. Cabeza (Head) — 5.000 tris: mitad izquierda pelo peinado, mitad derecha facetas de cristal negro
   (#1a1530, roughness 0,1) con grietas neon-eclipse.
2. Traje partido (Torso + brazos + piernas) — 15.000 tris: mitad tela azul marino, mitad cristal facetado.
3. Dado de dos caras (LeftHand) — 1.500 tris: un octaedro de cristal con un ojo grabado en cada mitad.
4. Zapatos (Feet) — 2.000 tris: uno de cuero, uno de cristal.
TOTAL ≤ 24.000 tris. Primeros planos: cara de frente, dado, línea de corte en el pecho.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/dualidad/, script en scripts/personajes/dualidad.py,
commit "Linajes: traje de Dualidad" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- dualidad (deja el .glb y los
renders en linajes/boveda/04 Personajes/Dualidad/) y escribí o actualizá la nota Dualidad (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P15 Confeti|← P15 Confeti]]   ·   [[Todos los prompts]]   ·   [[P17 Gorrión|P17 Gorrión →]]
