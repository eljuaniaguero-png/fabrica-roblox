---
tags: [prompt]
prompt: "30c"
estado: pendiente
---
# Prompt 30c Cinemáticas

Antes de pegarlo: Blender abierto con el conector de Claude, Studio con el place de Linajes y `rojo serve linajes/linajes.project.json` corriendo, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Hacé antes las animaciones y los sonidos que usa cada escena. Reglas: [[Cinemáticas (plan completo)]] · [[Colores]]

```
Leé la nota "Cinemáticas (plan completo)" de la bóveda (reglas, lista y cuáles van en la Beta).

1. MÓDULO (una sola vez): en linajes/src/client/cinematicas/ un reproductor que toca una escena desde
   sus datos: recorrido de cámara, animaciones de cada personaje, subtítulos, sonidos, efectos y
   marcadores (Golpe, Destello, Sacudida). Franjas negras, HUD escondido, botón "Saltear" (la primera vez
   aparece a los 2 s), invulnerable mientras dura. El servidor avisa cuándo empieza una escena de jefe a
   todos los de la arena y congela al jefe hasta que termina. Textos y duraciones en Config.luau.
2. CÁMARA EN BLENDER: en linajes/arte/blender/cinematicas.blend, una escena de Blender por cinemática
   con los personajes, la cámara animada a 30 fps y los marcadores. Script en
   linajes/arte/scripts/cinematicas.py que exporta el recorrido de la cámara (posición, giro y lente por
   cuadro, en studs) y los marcadores a linajes/arte/cinematicas/<escena>.json.
3. ESCENAS: [pegá la lista: para la Beta, la de "Cuáles van en la Beta"; después, la parte que toque].
Para cada escena: 3 cuadros clave en una tira (linajes/arte/renders/cine-<escena>.png) y mandalas a la
nota de Obsidian "Cinemáticas (plan completo)" en una sección "Hechas". Esperá mi OK.
Con mi OK: probalas con Play en compu y en el emulador de celular (que se puedan saltear, que no se rompa
si otro jugador entra en el medio), consola sin rojo, captura. Commit y push.
```

---
[[P30b Efectos especiales e interfaz|← P30b Efectos especiales e interfaz]]   ·   [[Todos los prompts]]   ·   [[P31 Sonidos de combate y menús|P31 Sonidos de combate y menús →]]
