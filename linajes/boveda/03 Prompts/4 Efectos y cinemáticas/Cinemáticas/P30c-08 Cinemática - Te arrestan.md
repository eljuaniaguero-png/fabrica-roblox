---
tags: [prompt, cinematicas]
beta: "**Sí**"
---
# P30c-08 Cinemática - Te arrestan

> [!summary] En tres líneas
> Cinemática **Te arrestan** (8 s).

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Cinemática **Te arrestan** (8 s).

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/cinematicas/`

## 2. Qué leer antes
- [[Cinemáticas (plan completo)]]
- [[Los muelles rojos]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Storyboard: Te arrestan** → guardar como `linajes/arte/referencias/gemini/cine-tearrestan/storyboard.png`
```
Cinematic storyboard in 4 to 6 panels for an original stylized Roblox superhero game: a masked blocky player handcuffed, police lights, a cell door closing. Comic-book framing, black letterbox bars, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/cine-tearrestan/. Código en linajes/src/client/cinematicas/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- ESCENA: Te arrestan (8 s). Qué pasa: Esposado, sirenas, la reja de la celda del puerto se cierra.
- En linajes/arte/blender/cinematicas.blend, escena de Blender "tearrestan" con personajes, cámara animada a 30 fps y marcadores.
- Exportar con linajes/arte/scripts/cinematicas.py a linajes/arte/cinematicas/tearrestan.json.
- Subtítulos en Config.luau (máximo 3 líneas por personaje).
- Tira de 3 cuadros clave en linajes/arte/renders/cine-tearrestan.png, en la nota Cinemáticas (plan completo), sección Hechas.
- Se puede saltear y no se rompe si otro jugador entra.

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- El servidor decide; el cliente solo muestra.
- Un solo bucle del cliente para lo que se mueve siempre, pausado si no se ve.
- Números en `Config.luau`.
- Probado: Play en compu y emulador de celular, consola sin rojo, captura.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Se entiende sin leer mucho.
- [ ] Se puede saltear.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P30c-07 Cinemática - Derrota y reaparecer|← P30c-07 Cinemática - Derrota y reaparecer]]   ·   [[P30c Cinemáticas]]   ·   [[P30c-09 Cinemática - Remache - entrada|P30c-09 Cinemática - Remache - entrada →]]
