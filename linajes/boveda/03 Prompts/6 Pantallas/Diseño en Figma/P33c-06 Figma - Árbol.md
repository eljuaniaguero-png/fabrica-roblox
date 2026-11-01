---
tags: [prompt, pantallas]
beta: "**Sí**"
---
# P33c-06 Figma - Árbol

> [!summary] En tres líneas
> Diseño en Figma de **Árbol**, en compu (1920x1080) y celular (844x390).

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Diseño en Figma de **Árbol**, en compu (1920x1080) y celular (844x390).

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/2d/figma/`

## 2. Qué leer antes
- [[Combate y progresión]]
- [[Guía de estilo]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Referencia: Árbol** → guardar como `linajes/arte/referencias/gemini/interfaz/arbol.png`
```
UI mockup for an original dark comic-book superhero game: skill tree with stats tab and three-branch lineage tree. High contrast, rounded shapes, readable on a phone, no readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/interfaz/. Código en linajes/arte/2d/figma/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- En el archivo de Figma "Linajes del Eclipse - Interfaz" (crealo si no existe, con el conector de Figma), página "Árbol".
- Contenido: pestaña Estadísticas (6 barras con +, puntos) y pestaña Linaje (3 ramas Poder, Cuerpo, Técnica, nodos apagados #8a94a6, encendidos #3fe0f0, ??? sin usar), botón Desbloquear.
- Dos marcos: compu 1920x1080 y celular 844x390 con los bordes seguros marcados.
- Usá los componentes del Sistema de diseño (P33c-01) y los íconos de linajes/arte/2d/.
- Mostrame capturas y el link. Con mi OK: piezas que no se hagan con Frames como PNG @2x en linajes/arte/2d/figma/ y medidas en linajes/arte/2d/figma/medidas.md.

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
- [ ] En celular nada queda bajo el pulgar.
- [ ] Usa el sistema de diseño.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P33c-05 Figma - HUD de pelea|← P33c-05 Figma - HUD de pelea]]   ·   [[P33c HUD y menús en Figma]]   ·   [[P33c-07 Figma - Diálogo con NPC|P33c-07 Figma - Diálogo con NPC →]]
