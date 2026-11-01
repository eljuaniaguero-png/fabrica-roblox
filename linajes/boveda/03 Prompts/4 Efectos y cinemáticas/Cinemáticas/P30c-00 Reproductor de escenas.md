---
tags: [prompt, cinematicas]
beta: "**Sí**"
---
# P30c-00 Reproductor de escenas

> [!summary] En tres líneas
> Sistema **Reproductor de escenas**.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Sistema **Reproductor de escenas**.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/cinematicas/`

## 2. Qué leer antes
- [[Cinemáticas (plan completo)]]
- [[Los muelles rojos]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Storyboard: Reproductor de escenas** → guardar como `linajes/arte/referencias/gemini/cine-reproductordeescenas/storyboard.png`
```
Cinematic storyboard in 4 to 6 panels for an original stylized Roblox superhero game: film strip of a cinematic player UI: black letterbox bars, a skip button, subtitles placeholder. Comic-book framing, black letterbox bars, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/cine-reproductordeescenas/. Código en linajes/src/client/cinematicas/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Módulo en linajes/src/client/cinematicas/ que toca una escena desde sus datos: cámara, animaciones, subtítulos, sonidos, efectos y marcadores (Golpe, Destello, Sacudida). Franjas negras, HUD escondido, botón Saltear (la primera vez a los 2 s), invulnerable. El servidor avisa a todos en la arena de jefe y congela al jefe. Textos y duraciones en Config.luau.
- Escenas desde linajes/arte/cinematicas/<escena>.json (cámara por cuadro y marcadores) exportadas por linajes/arte/scripts/cinematicas.py desde cinematicas.blend.

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
[[P30c Cinemáticas]]   ·   [[P30c-01 Cinemática - Logo|P30c-01 Cinemática - Logo →]]
