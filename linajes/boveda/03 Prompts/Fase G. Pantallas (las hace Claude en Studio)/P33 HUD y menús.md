---
tags: [prompt, pantallas]
beta: "Las pantallas de la Beta aprobadas en Figma (P33c)."
---
# P33 HUD y menús

> [!summary] En tres líneas
> Claude pasa a Roblox, por código, las pantallas aprobadas en Figma, igualitas, en compu y celular.

> [!info] En la Beta
> Las pantallas de la Beta aprobadas en Figma (P33c).

## 1. Para qué es
Es lo que el jugador toca todo el tiempo: HUD, ruleta, árbol, diálogos, taller.

**Qué tener abierto:** Studio con `rojo serve linajes/linajes.project.json` y el conector de Figma.

**Dónde queda:** `linajes/src/client/ui/` (un módulo por pantalla), IDs de imágenes en `Config.luau`.

## 2. Qué leer antes
- [[P33c HUD y menús en Figma]] (lo aprobado)
- [[Combate y progresión]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Cómo se ve el HUD en el juego (para comparar)** → guardar como `linajes/arte/referencias/gemini/interfaz/hud-juego.png`
```
In-game screenshot mockup of an original dark superhero Roblox game on a phone: a blocky hero fighting a harbor thug on a wet street at night, HUD with health and energy bars bottom-center, round ability buttons bottom-right with cooldown sweeps, red wanted stars top-center, a dialogue box at the bottom with a speaker tab and four answer buttons faded in the background. No readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Ventana del taller (referencia)** → guardar como `linajes/arte/referencias/gemini/interfaz/taller-ui.png`
```
UI mockup of a crafting window for an original superhero game: left a list of craftable items (suit, grappling hook) with icons, center a 3D preview of the selected item on a dark workbench, right the required materials (scrap, chips) with have/need counts and a big craft button; dark theme with cyan #3fe0f0 highlights. No readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md y linajes/arte/2d/figma/medidas.md. El diseño aprobado está en el
archivo de Figma "Linajes del Eclipse - Interfaz" (miralo con el conector): Roblox tiene que quedar
igual; si este texto y Figma no coinciden, manda Figma.
Subí las imágenes de linajes/arte/2d/ con el MCP de Studio y anotá cada ID en Config.luau.
Armá las pantallas por código en linajes/src/client/ui/ (un módulo por pantalla; Frames, UICorner,
UIStroke y UIGradient donde se pueda, imágenes solo donde no), con anclas y escalas. Fuentes: las más
parecidas a Saira Condensed y Barlow con Font.new.
CONTENIDO MÍNIMO:
1. MENÚ: fondo #0e1016, eclipse que late cada 4 s, personaje girando, 3 espacios con flechas, datos
   (nombre, Linaje en su color de rareza, bando, rango, nivel), botones Jugar, Ajustes, Créditos.
2. RULETA: lista por rareza con su % (Común 55, Poco común 28, Raro 12, Legendario 4, Mítico 1; en la
   Beta solo salen los 3 Comunes y se dice), contador "Seguro: N/40", botón "Tirar (1 ficha)".
3. HUD: vida #d23a4a, energía #2c7be5, escudo #3fc1b0, Z X C con recarga, G, Q, F; en celular botones
   redondos abajo a la derecha. Estrellas de búsqueda arriba al centro.
4. ÁRBOL: estadísticas (6) y Linaje (Poder, Cuerpo, Técnica), nodos apagados #8a94a6 y encendidos
   #3fe0f0, botón "Desbloquear" (lo decide el servidor).
5. DIÁLOGO: recuadro abajo, pestaña con el nombre, máquina de escribir, hasta 4 respuestas, la última
   siempre "Adiós".
6. TALLER: lista, vista del objeto, materiales tengo/necesito, "Fabricar".
7. LISTA DE JUGADORES por bando con su color y rango.
8. AJUSTES: música, efectos, calidad Alto/Bajo, sensibilidad de cámara.
Probá 1920x1080 y 844x390. Captura de cada pantalla al lado de su marco de Figma. Esperá mi OK.
Commit y push.
```

## 5. Reglas de Roblox que aplican
- Anclas y `UIScale`/`Scale` para que se vea igual en 1920x1080 y 844x390.
- Botones de celular de 48 px mínimo; el de ataque, el más grande, abajo a la derecha, fuera de los bordes seguros.
- El cliente solo muestra y pide; el servidor decide (ruleta, desbloquear, comprar).
- Imágenes subidas una vez, IDs en `Config.luau`.
- Nada de textos ni íconos de otros juegos.

## 6. Pasos y puntos de control
### Paso 1: Pantallas en Studio
Las 8 pantallas con capturas al lado de Figma.

**Para dar el OK:**
- [ ] Igual a Figma.
- [ ] En celular todo se toca con el pulgar.
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos en `src/client/ui/`, IDs en `Config.luau`, capturas.

**Cómo lo probás vos:**
- En Play, abrí cada pantalla en compu y en el emulador de celular.

---
[[P33c HUD y menús en Figma|← P33c HUD y menús en Figma]]   ·   [[Todos los prompts]]   ·   [[P34 Base y guardado|P34 Base y guardado →]]
