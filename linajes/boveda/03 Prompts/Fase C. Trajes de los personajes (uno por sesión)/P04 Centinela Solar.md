---
tags: [prompt]
prompt: "04"
estado: en curso
---
# Prompt 4 Centinela Solar (DC de trabajo: Superman) · Liga

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/centinela.blend.

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
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P03 Cuervo|← P03 Cuervo]]   ·   [[Todos los prompts]]   ·   [[P05 Mascarada|P05 Mascarada →]]
