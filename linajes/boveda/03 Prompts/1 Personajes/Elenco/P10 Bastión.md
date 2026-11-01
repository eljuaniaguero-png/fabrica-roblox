---
tags: [prompt, personaje]
prompt: 10
estado: pendiente
---
# Prompt 10 · Bastión
(DC de trabajo: Cyborg) · Liga · archivo `bastion`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/bastion/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a hero whose right half is steel plates with cyan neon lines and an arm cannon and a cyan implant eye, the left half human in street clothes. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/bastion/ref-2.png`
```
Character turnaround sheet of the same character (a hero whose right half is steel plates with cyan neon lines and an arm cannon and a cyan implant eye, the left half human in street clothes): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/bastion/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Bastión en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/bastion/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/bastion.blend.

PERSONAJE: Bastión. Ex guardia de seguridad reconstruido con implantes después del eclipse.
Diseño propio: SIN ojo rojo único, SIN el patrón de placas plateadas de Cyborg; mitad máquina asimétrica.
SILUETA: lado izquierdo humano con ropa táctica, lado derecho todo de placas con un cañón en el brazo.
PIEZAS:
1. Media cabeza de placas (Head) — 6.000 tris: lado derecho de acero con 3 lentes neon-cian en triángulo.
2. Torso mitad placas (UpperTorso + LowerTorso) — 9.000 tris: lado derecho placas de acero con
   rejillas neon-cian; lado izquierdo chaleco táctico liga con bolsillos.
3. Brazo-cañón derecho (RightUpperArm + RightLowerArm + RightHand) — 9.000 tris: cilindro de 3 anillos que
   se separan (se anima), boca con neon-cian.
4. Brazo izquierdo con guante táctico (LeftArm) — 3.000 tris.
5. Pierna derecha mecánica y bota (RightLeg + RightFoot) — 5.000 tris: pistones visibles.
6. Pierna izquierda pantalón táctico y bota (LeftLeg + LeftFoot) — 3.000 tris.
7. EMBLEMA PROPIO en el chaleco — 500 tris: escudo de muralla (una torre) en liga.
TOTAL ≤ 36.000 tris. Colores: 45 % acero, 35 % tela táctica oscura, 20 % liga y neon-cian.
Primeros planos: cabeza, cañón abierto, pierna mecánica.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/bastion/, script en scripts/personajes/bastion.py,
commit "Linajes: traje de Bastión" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- bastion (deja el .glb y los
renders en linajes/boveda/04 Personajes/Bastión/) y escribí o actualizá la nota Bastión (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P09 Arquitecto|← P09 Arquitecto]]   ·   [[Todos los prompts]]   ·   [[P11 Heredero Abisal|P11 Heredero Abisal →]]
