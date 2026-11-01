---
tags: [prompt, sonido]
beta: "Solo el **ambiente del puerto** y la música del **menú**, **exploración**, **pelea**, **jefe Remache** y **victoria**. Las demás ciudades, en la Post beta."
---
# P32 Ambientes y música

> [!summary] En tres líneas
> Loops de ambiente y música original con ForgeGUI. En la Beta, el puerto y 5 temas.

> [!info] En la Beta
> Solo el **ambiente del puerto** y la música del **menú**, **exploración**, **pelea**, **jefe Remache** y **victoria**. Las demás ciudades, en la Post beta.

## 1. Para qué es
La niebla, las gaviotas y la chapa del puerto; una música que sube en la pelea y un tema industrial para Remache.

**Qué tener abierto:** Claude Code con el conector de ForgeGUI y Studio con `rojo serve`.

**Dónde queda:** `linajes/arte/sonidos/`, `LISTA.md`, IDs en `Config.luau`, cambio de música por zona en `linajes/src/client/musica/`.

## 2. Qué leer antes
- [[Puerto Óxido]] (cómo suena)
- [[Galpón de Remache]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!note] Gemini **describe** la música de referencia; ForgeGUI la genera.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Guía del ambiente del puerto** → guardar como `linajes/arte/referencias/gemini/musica/puerto.md`
```
Describe, as a sound designer, a 60-second seamless ambient loop for a foggy rundown harbor at night in an original superhero game: list every layer (waves against wooden piles, distant gulls, chains, creaking corrugated steel in the wind, a ship horn every 2 minutes, a distant radio), its volume, stereo position and how often it repeats. No references to existing media.
```

**Referencia 2: Guía de los 5 temas musicales** → guardar como `linajes/arte/referencias/gemini/musica/temas.md`
```
Describe 5 original music loops for a dark comic-book superhero game, each with tempo (BPM), key, instruments, structure and mood, so a music generator can create them: main menu (dark epic orchestra, slow drums, low choir, 120 s), night exploration (dark synths with strings, calm but tense, 120 s), combat (fast percussion, staccato strings, brass, 90 s), industrial boss (heavy industrial, rhythmic hammer hits, piston hisses, 90 s), victory fanfare (8 s). Do not imitate any existing film or game score.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las guías de linajes/arte/referencias/gemini/musica/. Con ForgeGUI generá (nada que imite música
de películas o juegos de DC):
AMBIENTE: puerto-oxido (loop de 60 s sin corte: olas contra el muelle, gaviotas, cadenas, chapa que
cruje, bocina de barco lejos).
MÚSICA (loops sin corte): menu-principal (120 s), exploracion-noche (120 s), pelea (90 s),
jefe-remache (90 s, industrial con martillazos), victoria (8 s, no loop).
Guardá en linajes/arte/sonidos/, agregá a LISTA.md, subilos y anotá los IDs.
Código en linajes/src/client/musica/: el ambiente suena según el Barrio (tag) donde estás; la música de
pelea entra con fundido de 1 s cuando hay enemigos a menos de 40 studs y sale 4 s después; la de jefe la
dispara el servidor. Volúmenes en Config.luau y en Ajustes (música y efectos por separado).
Probá con Play. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Nada de música ni sonidos con derechos de autor ni que imiten a DC o a películas.
- Cada punto de sonido en el código lleva un comentario `-- SONIDO:` y su ID en `Config.luau` (tabla Sonidos), para cambiarlo después.
- Subir audio a Roblox puede necesitar tu cuenta: Claude te dice exactamente qué tocar.
- Formato `.ogg`, mono para efectos, estéreo para música; efectos ≤ 3 s, loops sin corte.

## 6. Pasos y puntos de control
### Paso 1: Generar y escuchar
Ambiente y 5 temas.

**Para dar el OK:**
- [ ] Los loops no tienen corte.
- [ ] La pelea sube la tensión sin tapar los golpes.

### Paso 2: Probar en el juego
Play caminando por el puerto.

**Para dar el OK:**
- [ ] La música cambia con fundido.
- [ ] Ajustes de volumen funcionan.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.ogg`, `LISTA.md`, IDs, módulo `musica`.

**Cómo lo probás vos:**
- En Play, caminá por el puerto y pelea con un matón.

---
[[P31 Sonidos de combate y menús|← P31 Sonidos de combate y menús]]   ·   [[Todos los prompts]]   ·   [[P30c Cinemáticas|P30c Cinemáticas →]]
