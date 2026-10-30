---
tags: [prompt, personaje]
prompt: 9
estado: pendiente
---
# Prompt 9 · Arquitecto
(DC de trabajo: Green Lantern) · Liga · archivo `arquitecto`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/arquitecto.blend.

PERSONAJE: Arquitecto. Ingeniero que se fabricó un guantelete que convierte luz en objetos sólidos.
Diseño propio: SIN anillo, SIN verde, SIN linterna, SIN juramento, SIN cuerpo de policía espacial.
SILUETA: traje de obrero espacial con casco de visera, un guantelete enorme en el brazo derecho.
PIEZAS:
1. Casco con visera rebatible (Head) — 6.000 tris: blanco-armadura con franja liga, visera neon-cian.
2. Mameluco técnico (Torso + piernas) — 9.000 tris: gris (#5a606e) con bolsillos, rodilleras, arnés de
   herramientas en la cintura con 4 herramientas chicas.
3. GUANTELETE (RightLowerArm + RightHand) — 9.000 tris: acero, 3 veces más grueso que el brazo, 5 placas
   que se abren (se animan), núcleo prismático neon-cian en el dorso, cables que van al hombro.
4. Guante izquierdo simple (LeftHand) — 1.000 tris.
5. Mochila-generador (UpperTorso, espalda) — 4.000 tris: caja de acero con 2 aletas de disipación y luces cian.
6. EMBLEMA PROPIO en el hombro — 500 tris: un cubo de líneas (estructura de alambre) neon-cian.
7. Botas de obra (Feet) — 2.500 tris el par.
TOTAL ≤ 32.000 tris. Colores: 50 % gris, 30 % acero, 20 % neon-cian y liga.
Primeros planos: guantelete abierto y cerrado, casco, mochila.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + los primeros planos que dice arriba. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/arquitecto/, script en scripts/personajes/arquitecto.py,
commit "Linajes: traje de Arquitecto" y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P08 Atalanta|← P08 Atalanta]]   ·   [[Todos los prompts]]   ·   [[P10 Bastión|P10 Bastión →]]
