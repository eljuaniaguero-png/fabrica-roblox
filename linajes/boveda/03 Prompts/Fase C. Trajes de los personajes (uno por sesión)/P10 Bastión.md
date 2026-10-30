---
tags: [prompt, personaje]
prompt: 10
estado: pendiente
---
# Prompt 10 · Bastión
(DC de trabajo: Cyborg) · Liga · archivo `bastion`

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

Copiá el bloque entero y pegalo:

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/bastion.blend.

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
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P09 Arquitecto|← P09 Arquitecto]]   ·   [[Todos los prompts]]   ·   [[P11 Heredero Abisal|P11 Heredero Abisal →]]
