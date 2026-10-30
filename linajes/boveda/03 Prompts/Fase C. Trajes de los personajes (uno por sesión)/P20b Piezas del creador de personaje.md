---
tags: [prompt]
prompt: "20b"
estado: pendiente
---
# Prompt 20b Piezas del creador de personaje (para los jugadores)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y la sección 0c de linajes/ideas/ficha.md. Los personajes principales son NPCs:
los jugadores se arman SU PROPIO héroe con piezas que se mezclan. Guardá kit-base.blend como
linajes/arte/blender/creador.blend.
Modelá, sobre el maniquí R15, piezas genéricas (no copias de ningún personaje) que encajen entre sí:
- 8 cascos/máscaras (≤ 6.000 tris c/u): antifaz, capucha, casco cerrado con visor, casco abierto con cresta,
  máscara de placas, gorra con antiparras, yelmo con cuernos cortos, media máscara de respirador.
- 8 capas (≤ 6.000): corta, larga, partida en 2, en tiras, con cuello alto, bufanda larga, gabardina, ninguna (solo cuello).
- 8 petos (≤ 7.000): tela simple, placas, chaleco táctico, armadura ligera, traje ajustado con líneas,
  cota de escamas, chaqueta de cuero, uniforme con cinturón cruzado.
- 6 hombreras, 6 guantes, 6 botas (≤ 3.000 el par).
REGLAS: cada pieza con 3 canales de color (3 materiales separados llamados Color1, Color2, Color3, para
cambiarlos por código) y un hueco plano de 0,6 studs en el pecho del peto y en la capa para el emblema.
Todas tienen que verse bien combinadas con cualquiera de las otras.
PASO 1: bocetos de todas en una grilla, mi OK. PASO 2: detalle y 6 combinaciones de ejemplo armadas,
mi OK. PASO 3: exportá a linajes/arte/exports/creador/<tipo>/<pieza>.fbx. Además, 20 formas de emblema en
2D (SVG simple, una sola tinta) en linajes/arte/emblemas/. Commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P20 Enemigos comunes|← P20 Enemigos comunes]]   ·   [[Todos los prompts]]   ·   [[P20d Civiles y testigos|P20d Civiles y testigos →]]
