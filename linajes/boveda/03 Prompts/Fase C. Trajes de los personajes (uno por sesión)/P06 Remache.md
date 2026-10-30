---
tags: [prompt]
prompt: "06"
estado: pendiente
---
# Prompt 6 Remache (DC de trabajo: Bane) · Cofradía · jefe del Acto 1

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/remache.blend.

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
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P05 Mascarada|← P05 Mascarada]]   ·   [[Todos los prompts]]   ·   [[P07 Estela|P07 Estela →]]
