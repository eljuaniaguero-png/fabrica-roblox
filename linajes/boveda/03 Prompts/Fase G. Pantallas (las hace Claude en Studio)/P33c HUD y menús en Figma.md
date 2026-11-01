---
tags: [prompt, pantallas]
beta: "Las pantallas de la Beta: menú principal, creador de personaje, ruleta, HUD de pelea, árbol (sin Despertar), diálogo con NPC, taller, lista de jugadores, ajustes y aviso de "Buscado"."
---
# P33c HUD y menús en Figma

> [!summary] En tres líneas
> Claude diseña todas las pantallas en Figma (compu y celular), con un sistema de colores y componentes. Vos las aprobás ahí; después P33 las pasa a Roblox igual.

> [!info] En la Beta
> Las pantallas de la Beta: menú principal, creador de personaje, ruleta, HUD de pelea, árbol (sin Despertar), diálogo con NPC, taller, lista de jugadores, ajustes y aviso de "Buscado".

## 1. Para qué es
Diseñar en Figma es más rápido de cambiar que en Roblox. Una vez aprobado, Roblox tiene que quedar idéntico.

**Qué tener abierto:** Claude Code con el conector de Figma. Gemini para las referencias.

**Dónde queda:** Archivo de Figma "Linajes del Eclipse - Interfaz", piezas PNG en `linajes/arte/2d/figma/`, medidas en `linajes/arte/2d/figma/medidas.md`.

## 2. Qué leer antes
- [[Combate y progresión]] (teclas y pantallas)
- [[Guía de estilo]] (colores y letras)
- [[Linajes]] (ruleta)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: HUD de pelea en celular (referencia)** → guardar como `linajes/arte/referencias/gemini/interfaz/hud-celular.png`
```
Mobile game HUD mockup for an original dark superhero brawler, landscape 844x390 phone screen over a foggy harbor street at night: bottom-center a health bar (red #d23a4a) and energy bar (blue #2c7be5) meeting at a diamond with a faction emblem, a thin teal shield bar (#3fc1b0) above health; bottom-right a big round attack button and smaller round buttons for three abilities, dash, block and gadget with cooldown sweeps; top-right a small player list; top-left a minimap. Clean, high contrast, rounded shapes, no readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Menú principal (referencia)** → guardar como `linajes/arte/referencias/gemini/interfaz/menu.png`
```
Main menu mockup for an original dark comic-book superhero game, 1920x1080: dark background #0e1016 with a huge solar eclipse (black disc, burning orange #f2652b and gold ring) behind a blocky hero character standing in the center, left column of large condensed buttons, right panel with character info rows and three character slots with arrows. Subtle rain, cinematic. No readable text, use placeholder lines. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: Ruleta y árbol (referencia)** → guardar como `linajes/arte/referencias/gemini/interfaz/ruleta-arbol.png`
```
Two UI mockups side by side for a superhero game: left, a power roulette screen with a spinning wheel and a list of rarities with colored bars (grey, green, blue, orange, red) and a pity counter; right, a skill tree with three vertical branches of square nodes connected by lines, unlocked nodes glowing cyan #3fe0f0, locked nodes grey #8a94a6. Dark theme, no readable text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md (colores y letras: títulos Saira Condensed, texto Barlow) y
linajes/boveda/01 Juego/Combate y progresión.md. Mirá las referencias de
linajes/arte/referencias/gemini/interfaz/ (solo como idea de distribución).
Creá un archivo de Figma "Linajes del Eclipse - Interfaz".
1. SISTEMA: variables de color (fondo #0e1016, superficie, tinta, eclipse #f2652b, corona #ffb347,
   vida #d23a4a, energía #2c7be5, escudo #3fc1b0, bandos y rarezas), estilos de texto (título,
   subtítulo, cuerpo, etiqueta) y componentes con variantes: botón (normal, encima, apretado,
   bloqueado), barra (vida, energía, escudo), ícono de habilidad con recarga, nodo del árbol (apagado,
   disponible, encendido), pestaña, ventana, fila de jugador, aviso.
2. PANTALLAS DE LA BETA, cada una en compu 1920x1080 y celular 844x390 (bordes seguros marcados):
   menú principal, creador de personaje, ruleta, HUD de pelea, árbol, diálogo con NPC, taller (fabricar),
   lista de jugadores, ajustes y aviso de "Buscado" (estrellas rojas).
3. Usá los íconos de linajes/arte/2d/ y el logo. Botones de celular de 48 px mínimo; ataque el más
   grande, abajo a la derecha.
Mostrame capturas de cada pantalla y el link. Esperá mi OK o mis cambios.
Con mi OK: exportá las piezas que no se puedan hacer con un Frame como PNG @2x a linajes/arte/2d/figma/
y anotá en medidas.md posiciones, tamaños y anclas de cada pantalla. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Anclas y `UIScale`/`Scale` para que se vea igual en 1920x1080 y 844x390.
- Botones de celular de 48 px mínimo; el de ataque, el más grande, abajo a la derecha, fuera de los bordes seguros.
- El cliente solo muestra y pide; el servidor decide (ruleta, desbloquear, comprar).
- Imágenes subidas una vez, IDs en `Config.luau`.
- Nada de textos ni íconos de otros juegos.

## 6. Pasos y puntos de control
### Paso 1: Diseño en Figma
Sistema + 10 pantallas en 2 tamaños.

**Para dar el OK:**
- [ ] En celular nada queda tapado por el pulgar.
- [ ] Se leen los colores de rareza y de bando.
- [ ] Todo usa los componentes del sistema.

### Paso 2: Exportar
Piezas PNG y medidas.md.

**Para dar el OK:**
- [ ] Cada pantalla tiene sus medidas anotadas.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Archivo de Figma, PNG en `arte/2d/figma/`, `medidas.md`.

**Cómo lo probás vos:**
- Abrí el link de Figma y mirá cada pantalla en los dos tamaños.

---
[[P33b Íconos de Linajes y habilidades (Gemini)|← P33b Íconos de Linajes y habilidades (Gemini)]]   ·   [[Todos los prompts]]   ·   [[P33 HUD y menús|P33 HUD y menús →]]
