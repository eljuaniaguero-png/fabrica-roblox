---
tags: [prompt]
prompt: "20f"
estado: pendiente
---
# Prompt 20f Cuerpo propio del jugador (reemplaza al avatar de Roblox)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]] · [[Cuerpo propio (sin avatar de Roblox)]]

```
Leé linajes/arte/GUIA-ESTILO.md y la nota "Cuerpo propio (sin avatar de Roblox)" de la bóveda. El juego NO
usa el avatar de Roblox: todos usan este cuerpo. Guardá kit-base.blend como linajes/arte/blender/cuerpo.blend.
Usá EL MISMO esqueleto R15 del maniquí (mismos huesos y mismas posiciones), así los trajes y las
animaciones que ya existen siguen sirviendo.

PIEZAS (una malla por parte del R15, pegada a su hueso, 4.000 a 6.000 tris en total):
1. Cuerpo de cómic, proporcionado (cabeza un poco grande para que se lea en celular), manos con dedos
   juntos (pulgar aparte), sin ropa interior detallada: un traje base liso gris oscuro.
2. 3 contexturas como shape keys: normal, ancha (hombros +20 %), delgada (hombros y cadera -12 %).
3. Cara: 12 texturas de ojos, cejas y boca (en una hoja 4x3) + 8 expresiones (neutral, enojado, contento,
   sorprendido, dolor, concentrado, cansado, derrotado) para cambiarlas por código.
4. 12 peinados (1.000 a 2.000 tris cada uno), un material con color libre.
5. 10 tonos de piel (anotalos en Config.luau) y 6 cicatrices o marcas como calcomanías.

PASO 1: boceto de las 3 contexturas al lado del maniquí, de frente, costado y espalda, con un traje de
Cuervo puesto encima para ver que encaja. Esperá mi OK.
PASO 2: detalle, hoja de caras y expresiones, hoja de peinados. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/cuerpo/. En Studio, por código en linajes/src/: StarterCharacter
con este cuerpo (Roblox deja de cargar el avatar), el servidor lo arma con lo que eligió el jugador y
reemplaza el script Animate por el nuestro. Probalo con Play: que aparezca el cuerpo propio y no el avatar.
Captura, commit y push.
```

---
[[P20e Vehículos y objetos de la calle viva|← P20e Vehículos y objetos de la calle viva]]   ·   [[Todos los prompts]]   ·   [[P20c Mapa del mundo abierto|P20c Mapa del mundo abierto →]]
