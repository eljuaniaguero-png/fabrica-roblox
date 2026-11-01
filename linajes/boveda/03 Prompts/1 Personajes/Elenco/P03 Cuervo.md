---
tags: [prompt]
prompt: "03"
estado: en curso
---
# Prompt 3 Cuervo (DC de trabajo: Batman) · Vigilantes

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/cuervo/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a tall lean vigilante with a cape of layered metallic feathers (black #121216 with steel-blue sheen #8a94a6), a mask with a short beak covering the upper face, white pupil-less eyes, a grappling hook on the left forearm, a belt of smoke bombs, violet #6b5ba8 seam accents; no bat motifs, no ears. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/cuervo/ref-2.png`
```
Character turnaround sheet of the same character (a tall lean vigilante with a cape of layered metallic feathers (black #121216 with steel-blue sheen #8a94a6), a mask with a short beak covering the upper face, white pupil-less eyes, a grappling hook on the left forearm, a belt of smoke bombs, violet #6b5ba8 seam accents; no bat motifs, no ears): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/cuervo/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Cuervo en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/cuervo/ (solo referencia, nunca una copia). Abrí linajes/arte/blender/kit-base.blend y guardalo como
linajes/arte/blender/cuervo.blend antes de tocar nada. Usá trajes.py y base.py.

PERSONAJE: Cuervo. Detective vigilante de Ciudad Vórtice, ex policía que perdió a su compañero.
Tema CUERVO (no murciélago). Diseño propio: nada de orejas de murciélago, capa con puntas de murciélago,
emblema de murciélago ni cinturón amarillo.

SILUETA (de lejos tiene que leerse así): hombros anchos por la capa de plumas, cabeza con pico corto,
capa larga hasta los tobillos que se abre en V hacia abajo.

PIEZAS (cada una objeto separado, pegada a su hueso):
1. Capucha-máscara (Head) — 8.000 tris: capucha de tela-oscura que cubre cabeza y frente; máscara de
   acero en la parte de arriba de la cara con un pico corto de 0,4 studs hacia adelante; dos ranuras de
   ojos con neon-cian (#3fe0f0) finas. Costuras visibles en la capucha.
2. Capa de plumas (UpperTorso) — 8.000 tris: 5 filas de plumas metálicas superpuestas (acero, roughness
   0,35) que bajan de los hombros hasta los tobillos; las de abajo más largas y separadas.
   Pliegues de tela horneados. Borde inferior irregular (plumas sueltas), NO en puntas de murciélago.
3. Peto (UpperTorso + LowerTorso) — 7.000 tris: armadura de placas de tela-oscura con bordes de acero;
   en el centro, el EMBLEMA PROPIO: una pluma de cuervo estilizada vertical de 0,6 studs en vigilantes
   (#6b5ba8) con borde neon-cian finito.
4. Hombreras (UpperArms) — 3.000 tris el par: tres plumas de acero en abanico cada una.
5. Antebrazos (LowerArms) — 3.000 tris el par: brazaletes de acero con 3 púas cortas hacia atrás;
   en el derecho, el lanzador de gancho (cilindro de acero con punta de 3 garras).
6. Guantes (Hands) — 2.000 tris el par: cuero negro con nudillos de acero.
7. Cinturón (LowerTorso) — 2.000 tris: cuero con 6 bolsillos de acero oscuro y hebilla con la pluma.
8. Botas (Feet) — 3.000 tris el par: botas altas de cuero con placas de acero en la canilla.
TOTAL ≤ 36.000 tris. Colores: 80 % tela-oscura/cuero, 15 % acero, 5 % vigilantes y neon-cian.

PASO 1: armá un boceto de bloques de todas las piezas (sin detalle) y renderizá las 3 vistas.
Mostramelo y esperá mi OK.
PASO 2: con mi OK, hacé el detalle completo cumpliendo el NIVEL DE DETALLE OBLIGATORIO de la guía. Renderizá las 3 vistas + primeros planos de capucha,
emblema y gancho. Tabla de triángulos por pieza. Mostramelo y esperá mi OK.
PASO 3: exportá cada pieza a linajes/arte/exports/cuervo/<pieza>.fbx. Guardá el script en
linajes/arte/scripts/personajes/cuervo.py. Commit "Linajes: traje de Cuervo" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- cuervo (deja el .glb y los
renders en linajes/boveda/04 Personajes/Cuervo/) y escribí o actualizá la nota Cuervo (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P02 Maniquí R15, materiales, luz y scripts base|← P02 Maniquí R15, materiales, luz y scripts base]]   ·   [[Todos los prompts]]   ·   [[P04 Centinela Solar|P04 Centinela Solar →]]
