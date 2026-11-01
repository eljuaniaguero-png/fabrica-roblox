---
tags: [prompt]
prompt: "04"
estado: en curso
---
# Prompt 4 Centinela Solar (DC de trabajo: Superman) · Liga

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/centinela/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a radiant hero in white #e8e6e0 and gold #d9a441 plated armor, a solar crown halo behind the head, a long golden cape, blue #2f6fdb accents at the joints, no letter or symbol on the chest. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/centinela/ref-2.png`
```
Character turnaround sheet of the same character (a radiant hero in white #e8e6e0 and gold #d9a441 plated armor, a solar crown halo behind the head, a long golden cape, blue #2f6fdb accents at the joints, no letter or symbol on the chest): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/centinela/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Centinela Solar en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/centinela/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/centinela.blend.

PERSONAJE: Centinela Solar. Último de un pueblo que nació dentro de una estrella. Vuela, tiene superfuerza
y dispara rayos de luz. Se debilita en la oscuridad del eclipse. Diseño propio: SIN letra ni escudo en el
pecho, SIN la combinación azul-rojo-amarillo, SIN rulo en la frente.

SILUETA: armadura heroica clara, una corona de rayos solares flotando detrás de la cabeza, capa corta.

PIEZAS:
1. Casco abierto (Head) — 7.000 tris: diadema de oro que rodea la frente con 3 placas finas hacia atrás;
   la cara queda libre.
2. Corona solar (flota detrás de Head, a 0,5 studs) — 4.000 tris: anillo de 12 rayos de oro de largos
   alternados (0,6 y 0,9 studs), con un aro interior de neon-eclipse (#f2652b). Se anima girando lento.
3. Peto (UpperTorso + LowerTorso) — 9.000 tris: placas de blanco-armadura con bordes de oro; en el centro,
   EMBLEMA PROPIO: un sol de 8 puntas de 0,7 studs en relieve, oro, con centro neon-eclipse.
4. Hombreras (UpperArms) — 4.000 tris el par: placas redondeadas de blanco-armadura con borde de oro.
5. Capa corta (UpperTorso) — 6.000 tris: tela dorada (#d9a441, roughness 0,6) hasta las rodillas,
   cortada en 3 tiras que se separan abajo, pliegues horneados.
6. Brazaletes y guantes (LowerArms + Hands) — 4.000 tris el par: blanco-armadura con líneas de oro.
7. Grebas y botas (LowerLegs + Feet) — 4.000 tris el par: blanco-armadura, rodilleras de oro.
TOTAL ≤ 38.000 tris. Colores: 60 % blanco-armadura, 30 % oro, 10 % liga (#2f6fdb) en las líneas de las
grebas y neon-eclipse.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + primeros planos de corona, emblema y capa. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/centinela/, script en scripts/personajes/centinela.py,
commit "Linajes: traje de Centinela Solar" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- centinela (deja el .glb y los
renders en linajes/boveda/04 Personajes/Centinela Solar/) y escribí o actualizá la nota Centinela Solar (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P03 Cuervo|← P03 Cuervo]]   ·   [[Todos los prompts]]   ·   [[P05 Mascarada|P05 Mascarada →]]
