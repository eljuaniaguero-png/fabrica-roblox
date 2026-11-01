---
tags: [prompt, pantallas]
beta: "**Sí**"
---
# P33-05 Roblox - Árbol

> [!summary] En tres líneas
> Pasar a Roblox la pantalla **Árbol** aprobada en Figma, igualita.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Pasar a Roblox la pantalla **Árbol** aprobada en Figma, igualita.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/ui/`

## 2. Qué leer antes
- [[P33c-06 Figma - Árbol]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Cómo se ve en el juego: Árbol** → guardar como `linajes/arte/referencias/gemini/interfaz/arbol-juego.png`
```
In-game screenshot mockup on a phone of an original dark superhero Roblox game showing: skill tree with stats tab and three-branch lineage tree. No readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/interfaz/. Código en linajes/src/client/ui/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Mirá la página "Árbol" del Figma y linajes/arte/2d/figma/medidas.md: Roblox tiene que quedar igual (si este texto y Figma no coinciden, manda Figma).
- Módulo linajes/src/client/ui/arbol.luau. Contenido: pestaña Estadísticas (6 barras con +, puntos) y pestaña Linaje (3 ramas Poder, Cuerpo, Técnica, nodos apagados #8a94a6, encendidos #3fe0f0, ??? sin usar), botón Desbloquear.
- Frames, UICorner, UIStroke y UIGradient donde se pueda; imágenes subidas por MCP solo donde no, con ID en Config.luau.
- Fuentes parecidas a Saira Condensed y Barlow con Font.new.
- Captura en 1920x1080 y 844x390 al lado del marco de Figma.

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- Anclas y escala: igual en 1920x1080 y 844x390.
- Botones de celular de 48 px mínimo.
- El servidor decide; la pantalla solo pide.
- Nada de textos ni íconos de otros juegos.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Igual a Figma.
- [ ] Se usa con el pulgar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P33-04 Roblox - HUD de pelea|← P33-04 Roblox - HUD de pelea]]   ·   [[P33 HUD y menús]]   ·   [[P33-06 Roblox - Diálogo con NPC|P33-06 Roblox - Diálogo con NPC →]]
