---
tags: [prompt, personaje]
prompt: 8
estado: pendiente
---
# Prompt 8 · Atalanta
(DC de trabajo: Wonder Woman) · Liga · archivo `atalanta`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/atalanta/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a warrior in bronze #a0703a hoplite armor with a large round shield bearing a golden apple and leaf, a spear taller than her, a short cape; no tiara, no lasso, no eagle. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/atalanta/ref-2.png`
```
Character turnaround sheet of the same character (a warrior in bronze #a0703a hoplite armor with a large round shield bearing a golden apple and leaf, a spear taller than her, a short cape; no tiara, no lasso, no eagle): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/atalanta/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Atalanta en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/atalanta/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/atalanta.blend.

PERSONAJE: Atalanta. Guerrera de las Hespérides, isla griega oculta. Diseño propio: SIN tiara con
estrella, SIN lazo, SIN águila ni "W", SIN combinación rojo-azul-dorado de bustier.
SILUETA: armadura griega de hoplita, escudo redondo grande, lanza más alta que ella.
PIEZAS:
1. Casco corintio abierto (Head) — 7.000 tris: bronce con cresta de crin azul liga (#2f6fdb) de punta a nuca.
2. Coraza musculada (UpperTorso + LowerTorso) — 8.000 tris: bronce con grabado de ramas de olivo; falda de
   tiras de cuero (pteruges) en 2 filas.
3. Capa corta (UpperTorso) — 4.000 tris: azul liga hasta la cintura, prendida con 2 broches de oro.
4. Brazaletes (LowerArms) — 2.000 tris el par: bronce con meandro griego.
5. Grebas y sandalias (LowerLegs + Feet) — 4.000 tris el par: bronce.
6. Escudo redondo (LeftHand) — 5.000 tris: 1,8 studs de diámetro, bronce con EMBLEMA PROPIO: una manzana
   dorada con una hoja (las Hespérides) en relieve, borde de oro.
7. Lanza (RightHand) — 2.000 tris: 6 studs de largo, asta de madera oscura, punta de bronce en hoja de laurel.
TOTAL ≤ 32.000 tris. Colores: 60 % bronce, 20 % cuero, 20 % liga y oro.
Primeros planos: casco, escudo, punta de lanza.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/atalanta/, script en scripts/personajes/atalanta.py,
commit "Linajes: traje de Atalanta" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- atalanta (deja el .glb y los
renders en linajes/boveda/04 Personajes/Atalanta/) y escribí o actualizá la nota Atalanta (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P07 Estela|← P07 Estela]]   ·   [[Todos los prompts]]   ·   [[P09 Arquitecto|P09 Arquitecto →]]
