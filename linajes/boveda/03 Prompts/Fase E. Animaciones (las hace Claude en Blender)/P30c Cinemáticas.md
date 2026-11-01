---
tags: [prompt, cinematicas]
beta: "El **reproductor** y las **22 escenas de la Beta** (logo, llegar al puerto, Tano, el Albatros, atraco, ruleta, prólogo, Remache y fin de *Los muelles rojos*). Las demás, en la Post beta."
---
# P30c Cinemáticas

> [!summary] En tres líneas
> Un reproductor de escenas en Studio y las cámaras animadas en Blender, exportadas como datos. Escenas cortas, que se pueden saltear.

> [!info] En la Beta
> El **reproductor** y las **22 escenas de la Beta** (logo, llegar al puerto, Tano, el Albatros, atraco, ruleta, prólogo, Remache y fin de *Los muelles rojos*). Las demás, en la Post beta.

## 1. Para qué es
Cuentan la historia de la Beta sin cortar el juego: la llegada al puerto, Tano y Nico, la deuda con el Albatros, la ruleta y la entrada de Remache.

**Qué tener abierto:** Blender con el conector (cámaras) y Studio con `rojo serve` (reproductor).

**Dónde queda:** Reproductor en `linajes/src/client/cinematicas/`, `linajes/arte/blender/cinematicas.blend`, script `scripts/cinematicas.py`, datos en `linajes/arte/cinematicas/<escena>.json`.

## 2. Qué leer antes
- [[Cinemáticas (plan completo)]] (reglas, lista, cuáles van en la Beta)
- [[Los muelles rojos]] · [[La Noche del Eclipse]]
- [[Tano]] · [[El Albatros]] · [[Remache]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Storyboard: llegada al puerto** → guardar como `linajes/arte/referencias/gemini/cinematicas/llegada.png`
```
Six-panel cinematic storyboard for a stylized Roblox superhero game: 1) wide shot of a foggy harbor at night under a solar eclipse ring of fire, 2) a ferry arriving at wooden docks, 3) cranes and stacked containers in silhouette, 4) close-up of a blocky player character stepping off, 5) a red-lit warehouse in the distance, 6) the player looking up at the eclipse. Comic-book framing, wide-screen black bars, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Storyboard: entrada de Remache** → guardar como `linajes/arte/referencias/gemini/cinematicas/remache.png`
```
Six-panel cinematic storyboard: a huge piston-armed brute with a red-visor welding helmet in a red warehouse. 1) back turned working, 2) slow turn, 3) close-up of the red visor lighting up, 4) pistons hiss steam, 5) he slams his fists together, 6) low-angle hero shot of him over the player. Comic-book framing, black bars, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/boveda/01 Juego/Cinemáticas (plan completo).md (reglas, lista y cuáles van en la Beta).
Mirá los storyboards de linajes/arte/referencias/gemini/cinematicas/.

1. REPRODUCTOR (una vez) en linajes/src/client/cinematicas/: toca una escena desde sus datos: recorrido de
   cámara, animaciones de cada personaje, subtítulos, sonidos, efectos y marcadores (Golpe, Destello,
   Sacudida). Franjas negras, HUD escondido, botón "Saltear" (la primera vez aparece a los 2 s),
   invulnerable mientras dura. El servidor avisa a todos los de la arena cuando empieza una escena de
   jefe y congela al jefe hasta que termina. Textos y duraciones en Config.luau.
2. CÁMARAS EN BLENDER: linajes/arte/blender/cinematicas.blend, una escena por cinemática con los
   personajes, la cámara animada a 30 fps y los marcadores. linajes/arte/scripts/cinematicas.py exporta
   la cámara (posición, giro y lente por cuadro, en studs) y los marcadores a
   linajes/arte/cinematicas/<escena>.json.
3. ESCENAS DE LA BETA: las 22 de "Cuáles van en la Beta". Ninguna dura más de 20 s; las de diálogo,
   máximo 3 líneas por personaje.
Para cada escena: 3 cuadros clave en una tira (linajes/arte/renders/cine-<escena>.png) en la nota de
Cinemáticas (sección "Hechas"). Esperá mi OK.
Con mi OK: probalas con Play en compu y celular (que se puedan saltear, que no se rompa si otro jugador
entra en el medio), consola sin rojo, captura. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Escenas cortas (≤ 20 s) y siempre salteables.
- El servidor sincroniza las escenas de jefe.
- Nada de texto copiado de DC.

## 6. Pasos y puntos de control
### Paso 1: Tiras de cada escena
Las 22 escenas con 3 cuadros cada una.

**Para dar el OK:**
- [ ] Se entiende la historia sin leer mucho.
- [ ] Remache tiene una entrada épica.

### Paso 2: Probar
Play en compu y celular.

**Para dar el OK:**
- [ ] Se saltean.
- [ ] No se rompe con 2 jugadores.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Reproductor, `.blend`, script, 22 JSON, tiras.
- Textos en `Config.luau`.

**Cómo lo probás vos:**
- En Play, mirá la llegada al puerto y la entrada de Remache; probá Saltear.

---
[[P32 Ambientes y música|← P32 Ambientes y música]]   ·   [[Todos los prompts]]   ·   [[P33a Logo, ícono y miniaturas (Gemini)|P33a Logo, ícono y miniaturas (Gemini) →]]
