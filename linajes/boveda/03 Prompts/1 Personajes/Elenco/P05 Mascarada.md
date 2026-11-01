---
tags: [prompt]
prompt: "05"
estado: pendiente
---
# Prompt 5 Mascarada (DC de trabajo: Joker) · Cofradía · jefe

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/mascarada/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a theatrical villain in a black patent-leather stage suit, white gloves, interchangeable original masks (tragedy, comedy, fury), crimson #c2213a accents; no clown makeup, no painted smile. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/mascarada/ref-2.png`
```
Character turnaround sheet of the same character (a theatrical villain in a black patent-leather stage suit, white gloves, interchangeable original masks (tragedy, comedy, fury), crimson #c2213a accents; no clown makeup, no painted smile): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/mascarada/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Mascarada en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/mascarada/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/mascarada.blend.

PERSONAJE: Mascarada. Villano teatral y caótico que cambia de "personaje" en cada fase de pelea.
Diseño propio: SIN maquillaje de payaso, SIN pelo verde, SIN traje violeta, SIN sonrisa pintada.

SILUETA: saco largo de teatro con cola, sombrero de copa torcido, una máscara distinta por fase.

PIEZAS:
1. Sombrero de copa torcido (Head) — 3.000 tris: negro con cinta cofradia (#c2213a).
2. Máscara 1 "Tragedia" (Head) — 3.000 tris: blanco-armadura, ceño triste, ojos neon-aviso.
3. Máscara 2 "Comedia" (Head) — 3.000 tris: blanco-armadura con grietas, sonrisa tallada, ojos neon-eclipse.
4. Máscara 3 "Ninguna" (Head) — 3.000 tris: espejo partido (acero, roughness 0,1) con grietas neon-aviso.
   Las 3 máscaras como objetos separados en el mismo lugar; solo una visible a la vez.
5. Saco de teatro (UpperTorso + LowerTorso) — 10.000 tris: tela cofradia oscura (#7a1424) con solapas
   negras, 6 botones de oro, cola larga partida en dos hasta las pantorrillas, pliegues horneados.
6. Chaleco y corbata de moño (UpperTorso) — 3.000 tris: chaleco negro a rayas finas, moño blanco.
7. Guantes blancos (Hands) — 2.000 tris el par.
8. Bastón con naipe gigante (RightHand) — 3.000 tris: bastón negro con punta de oro con forma de máscara.
9. Zapatos de charol (Feet) — 2.000 tris el par.
TOTAL ≤ 35.000 tris. Colores: 50 % negro, 35 % cofradia, 15 % blanco-armadura, oro y neon.

PASO 1: boceto, 3 vistas con la máscara 1, esperá mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + un render por máscara. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/mascarada/, script en scripts/personajes/mascarada.py,
commit "Linajes: traje de Mascarada" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- mascarada (deja el .glb y los
renders en linajes/boveda/04 Personajes/Mascarada/) y escribí o actualizá la nota Mascarada (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P04 Centinela Solar|← P04 Centinela Solar]]   ·   [[Todos los prompts]]   ·   [[P06 Remache|P06 Remache →]]
