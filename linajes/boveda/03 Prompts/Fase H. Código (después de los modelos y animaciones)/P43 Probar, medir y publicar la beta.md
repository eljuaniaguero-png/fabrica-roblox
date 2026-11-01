---
tags: [prompt, codigo]
beta: "Todo: es el cierre de la Beta."
---
# P43 Probar, medir y publicar la beta

> [!summary] En tres líneas
> Analítica, celular a 45 FPS, prueba con 2 o 3 jugadores, guardado bajo fallas, limpiar nombres de DC y la lista exacta para que vos publiques.

> [!info] En la Beta
> Todo: es el cierre de la Beta.

## 1. Para qué es
Antes de mostrarle la Beta a nadie, que ande bien en celular, que mida dónde se van los jugadores y que no tenga nada de DC.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Analitica/`, informe en `linajes/boveda/Progreso.md`.

## 2. Qué leer antes
- GUIA-PARA-CLAUDE sección 10 (checklist)
- [[Sobre DC]] (tabla de nombres)
- [[Plan por etapas]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Miniatura de anuncio de la Beta** → guardar como `linajes/arte/referencias/gemini/beta/anuncio.png`
```
Roblox game thumbnail 16:9, dark comic-book style: three blocky heroes on a foggy harbor dock at night under a burning solar eclipse, a huge piston-armed brute silhouette behind red-lit warehouse windows, cranes, cyan neon. Original designs only, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Panel de métricas (para entender el embudo)** → guardar como `linajes/arte/referencias/gemini/beta/embudo.png`
```
Analytics funnel chart: ten steps as decreasing horizontal bars (join, roll power, first fight, choose path, first job, level 5, first mission, heist, boss, level 10), plus small cards for currency sources and sinks. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
1. ANALÍTICA (AnalyticsService): embudo de 10 pasos (entrar, tirar Linaje, primera pelea, primer
   trabajo, nivel 5, primera misión, gancho, atraco, Remache, nivel 10), fuentes y gastos de dinero,
   chatarra, chips y fichas.
2. CELULAR: emulador 844x390, botones de 48 px, sin texto cortado, 45 FPS o más en Bajo.
3. RENDIMIENTO: Local Server con 3 jugadores en el puerto; StreamingEnabled (radio 512), Atomic en
   Remache, PersistentPerPlayer en lo del jugador; ≤ 500.000 triángulos en pantalla.
4. GUARDADO: simulá caídas de DataStore y cierre del servidor (P34).
5. NOMBRES: buscá en todo linajes/ (código, diálogos, Config, nombres de modelos y animaciones) los
   nombres de DC de la tabla de Sobre DC y reemplazalos por los finales. Pasame la lista.
6. Guardá una copia del place en backups/linajes-AAAA-MM-DD.rbxl.
7. Decime paso a paso qué tocar en Creator Hub para publicar privado y después público
   (cuestionario de madurez, ícono y miniaturas de P33a). PUBLICAR LO HACÉS VOS.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Publicar y cambiar la audiencia lo hace **Juani**, nunca Claude.
- Nada de nombres de DC en el juego publicado.

## 6. Pasos y puntos de control
### Paso 1: Checklist
Los 7 puntos con capturas.

**Para dar el OK:**
- [ ] 45 FPS en celular.
- [ ] El embudo registra los 10 pasos.
- [ ] Cero nombres de DC.
- [ ] Copia del place hecha.

### Paso 2: Publicar (vos)
Seguís la lista de Claude en Creator Hub.

**Para dar el OK:**
- [ ] El juego abre en privado.
- [ ] Probaste con 2 amigos.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Analítica, informe en Progreso, copia `.rbxl`, lista de nombres cambiados.

**Cómo lo probás vos:**
- Jugá la Beta entera en el celular de verdad.

---
[[P41a Primer hilo hecho a mano Los muelles rojos|← P41a Primer hilo hecho a mano Los muelles rojos]]   ·   [[Todos los prompts]]
