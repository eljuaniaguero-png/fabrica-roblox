---
tags: [prompt]
prompt: "03"
estado: en curso
---
# Prompt 3 Cuervo (DC de trabajo: Batman) · Vigilantes

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí linajes/arte/blender/kit-base.blend y guardalo como
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
```

---
[[P02 Maniquí R15, materiales, luz y scripts base|← P02 Maniquí R15, materiales, luz y scripts base]]   ·   [[Todos los prompts]]   ·   [[P04 Centinela Solar|P04 Centinela Solar →]]
