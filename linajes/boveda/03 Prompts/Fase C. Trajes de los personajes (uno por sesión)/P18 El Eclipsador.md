---
tags: [prompt, personaje]
prompt: 18
estado: pendiente
---
# Prompt 18 · El Eclipsador
(DC de trabajo: Darkseid) · jefe final · archivo `eclipsador`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/eclipsador.blend.

PERSONAJE: El Eclipsador. Tirano de Umbra, causó el eclipse. MODELO COMPLETO CON RIG PROPIO (no es un
traje sobre el maniquí). Diseño propio: SIN cara de piedra gris con ojos rojos de Darkseid, SIN falda
azul, SIN "rayos omega" rojos (sus rayos son negros con borde naranja).
ESCALA: 3x el maniquí (≈ 15 studs de alto).
SILUETA: gigante de roca negra volcánica con un eclipse ardiendo en el pecho y una corona de rayos negros.
PIEZAS (cada malla ≤ 20.000 tris, total ≤ 60.000):
1. Cabeza y corona (≤ 12.000): cráneo de roca negra (#15141a) facetada, sin boca visible, 2 ojos neon-eclipse,
   corona de 7 rayos de obsidiana con borde corona (#ffb347).
2. Torso (≤ 18.000): roca con grietas de lava naranja, en el centro un EMBLEMA PROPIO: disco negro con aro
   neon-eclipse (un eclipse), 1,5 studs, que late.
3. Brazos (≤ 14.000 los dos): roca con placas de obsidiana, manos de 4 dedos con garras.
4. Piernas (≤ 12.000 las dos): columnas de roca, pies anchos.
5. Manto de humo sólido (≤ 4.000): tiras de tela negra rígida que caen de los hombros.
RIG: esqueleto propio compatible con Animation Editor de Roblox (raíz HumanoidRootPart, 15 huesos con los
mismos nombres que R15). Pesos limpios en codos, rodillas y cuello.
PASO 1: boceto de bloques al lado del maniquí, esperá mi OK. PASO 2: detalle + 3 vistas + primeros planos
de cara, eclipse del pecho y manos. Probá el rig doblando brazos y piernas en un render. Esperá mi OK.
PASO 3: exportá con el rig a linajes/arte/exports/eclipsador/, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P17 Gorrión|← P17 Gorrión]]   ·   [[Todos los prompts]]   ·   [[P19 NPCs|P19 NPCs →]]
