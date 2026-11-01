---
tags: [prompt, sonido]
beta: "**Sí**"
---
# P32-05 Música del jefe Remache

> [!summary] En tres líneas
> **Música del jefe Remache** con ForgeGUI, original.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
**Música del jefe Remache** con ForgeGUI, original.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/sonidos/` y `linajes/src/client/sonido/`

## 2. Qué leer antes
- [[Puerto Óxido]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!note] Gemini **describe** el sonido (no genera audio). Guardá su respuesta como `.md` en la carpeta indicada y Claude se la pasa a ForgeGUI.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Guía de sonido** → guardar como `linajes/arte/referencias/gemini/musica-musicadeljeferemache/guia.md`
```
You are a sound designer for an original dark comic-book superhero game on Roblox. For each sound below write 2 lines: its layers (materials, pitch), length of each layer, and mood, so a sound generator can recreate it. Never reference existing films, games or DC/Marvel. Sounds: industrial boss theme: heavy industrial beat, rhythmic hammer hits, piston hisses, 90 s loop.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/musica-musicadeljeferemache/. Código en linajes/arte/sonidos/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Leé la guía de linajes/arte/referencias/gemini/musica-musicadeljeferemache/guia.md y generá con ForgeGUI cada uno de estos sonidos; guardalos en linajes/arte/sonidos/<nombre>.ogg y anotalos en linajes/arte/sonidos/LISTA.md (nombre, duración, para qué es):
- jefe-remache (loop 90 s)
- La dispara el servidor al empezar la pelea.
- Volúmenes en Config.luau y en Ajustes (música y efectos por separado).
- Subilos a Roblox (decime qué tengo que tocar) y anotá los IDs en Config.luau (tabla Sonidos). Probá con Play que cada uno suene en su momento.

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- Nada con derechos de autor ni que imite DC o películas.
- Cada punto de sonido en el código con `-- SONIDO:` y su ID en `Config.luau`.
- Efectos ≤ 3 s en mono; música en estéreo; loops sin corte.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Suenan distintos entre sí.
- [ ] Nada cortado.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P32-04 Música de pelea|← P32-04 Música de pelea]]   ·   [[P32 Ambientes y música]]   ·   [[P32-06 Música de victoria|P32-06 Música de victoria →]]
