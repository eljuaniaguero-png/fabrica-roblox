---
tags: [prompt]
prompt: "06"
estado: pendiente
---
# Prompt 6 Remache (DC de trabajo: Bane) · Cofradía · jefe del Acto 1

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

## Referencias para Gemini
Pegá cada bloque por separado en Gemini. La línea de arriba dice qué tiene que salir. Son **solo referencia**; si sale algo de DC o un logo, pedila de nuevo.

**Referencia 1: Vista general en pose** → guardar como `linajes/arte/referencias/gemini/remache/ref-1.png`
```
Full-body character concept of an original character for a stylized Roblox superhero game: a huge former dockworker 1.6x player size with a V-shaped torso, hydraulic piston arms ending in hammer fists, a welding helmet with a red visor, tubes of glowing red liquid on the back, rust #6e4a35 and steel. Heroic three-quarter pose on a wet harbor rooftop at night under a solar eclipse. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas** → guardar como `linajes/arte/referencias/gemini/remache/ref-2.png`
```
Character turnaround sheet of the same character (a huge former dockworker 1.6x player size with a V-shaped torso, hydraulic piston arms ending in hammer fists, a welding helmet with a red visor, tubes of glowing red liquid on the back, rust #6e4a35 and steel): front, side and back views on plain grey background, same scale, A-pose, stylized blocky Roblox proportions. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/remache/ref-3.png`
```
Detail sheet of the same character with four close-ups pointed by arrows (no text): head or mask, the signature weapon or prop, chest plates with seams and rivets, boots and gloves with wear. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## Bloque para Claude
```
Leé linajes/arte/GUIA-ESTILO.md y la nota de Remache en linajes/boveda/07 NPCs/. Mirá las 3 imágenes de
linajes/arte/referencias/gemini/remache/ (solo referencia, nunca una copia). Abrí kit-base.blend y guardalo como linajes/arte/blender/remache.blend.

PERSONAJE: Remache. Matón enorme del puerto con implantes hidráulicos robados de Corona Corp.
Diseño propio: SIN máscara de luchador, SIN tubos en la cabeza, SIN tanque de "veneno" en la espalda.
ESCALA: el maniquí escalado a 1,6x (es un jefe grande). Las piezas se hacen para ese tamaño.

SILUETA: torso enorme en forma de V, brazos gigantes de pistones, cabeza chica con casco de soldador.

PIEZAS:
1. Casco de soldador (Head) — 5.000 tris: acero oxidado (#6e4a35 mezclado con acero), visor rectangular
   neon-aviso (#ff2a2a), remaches en el borde.
2. Arnés de implantes (UpperTorso) — 9.000 tris: placas de acero sobre musculosa de cuero, columna
   mecánica en la espalda de 6 vértebras con luces neon-cian, 2 tubos con líquido rojo (#c2213a, emission 2)
   que van de la espalda a los hombros.
3. Brazos hidráulicos (UpperArms + LowerArms) — 12.000 tris el par: 2 pistones por brazo (cilindros de
   acero que se van a animar), mangueras negras, codo con engranaje.
4. Puños-martillo (Hands) — 5.000 tris el par: bloques de acero con 4 remaches grandes en los nudillos.
5. Pantalón de trabajo y botas con punta de acero (Legs + Feet) — 6.000 tris.
TOTAL ≤ 37.000 tris. Colores: 50 % acero oxidado, 30 % cuero oscuro, 20 % cofradia y neon.

PASO 1: boceto, 3 vistas al lado del maniquí normal (para ver el tamaño), esperá mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + primeros planos de brazo hidráulico y columna. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/remache/, script en scripts/personajes/remache.py,
commit "Linajes: traje de Remache" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- remache (deja el .glb y los
renders en linajes/boveda/04 Personajes/Remache/) y escribí o actualizá la nota Remache (modelo).md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P05 Mascarada|← P05 Mascarada]]   ·   [[Todos los prompts]]   ·   [[P07 Estela|P07 Estela →]]
