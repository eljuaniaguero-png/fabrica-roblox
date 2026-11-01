---
tags: [prompt, codigo]
beta: "Solo los **3 Comunes** (un tercio cada uno, y la pantalla lo dice), Variante Normal, sin Rasgos todavía. Los 12 Linajes, en la Post beta."
---
# P36 Ruleta Linaje, Variante y Rasgos

> [!summary] En tres líneas
> La ruleta de Linaje con las probabilidades a la vista, el seguro de mala suerte, las Fichas de Eclipse y las habilidades Z, X, C de cada Linaje Común.

> [!info] En la Beta
> Solo los **3 Comunes** (un tercio cada uno, y la pantalla lo dice), Variante Normal, sin Rasgos todavía. Los 12 Linajes, en la Post beta.

## 1. Para qué es
Es el momento más emocionante del inicio. Todo lo aleatorio lo tira el servidor y las probabilidades siempre se ven.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Linajes/` (Ruleta.luau, un módulo por Linaje), `Config.luau` (Linajes).

## 2. Qué leer antes
- [[Linajes]] (ruleta, seguro, fichas)
- [[Fuerza Bruta]] · [[Reflejos]] · [[Piroquinesis]] (habilidades con números: mandan)
- Monetización: nada aleatorio con Robux
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Pantalla de ruleta con probabilidades** → guardar como `linajes/arte/referencias/gemini/ruleta/ruleta.png`
```
Power roulette screen: big spinning wheel on the left, right column listing rarities with their percentages as colored bars (grey, green, blue, orange, red), a pity counter, a button to spin with a token icon, a small note area saying only commons are available in this version (placeholder lines). Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Revelación del Linaje** → guardar como `linajes/arte/referencias/gemini/ruleta/revelacion.png`
```
Reveal moment for a superpower in an original superhero game: a blocky hero kneeling on a wet harbor dock as a burst of orange fire erupts around their hands, solar eclipse overhead, rarity-colored light rays, dramatic low angle. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
Conectá la pantalla de ruleta de P33 y la animación de P30.
1. LINAJE (lo tira el SERVIDOR): tabla completa en Config (Común 55, Poco común 28, Raro 12, Legendario 4,
   Mítico 1) pero en la Beta solo están activos Fuerza Bruta, Reflejos y Piroquinesis (33,3 % cada uno) y
   la pantalla lo muestra así. Seguro: 40 tiradas sin Raro o mejor ⇒ la siguiente es Raro o mejor (se
   guarda, aunque en la Beta no aplica). Fichas de Eclipse: 3 al empezar, 1 por nivel, 1 por misión,
   3 por jefe. Nada aleatorio se compra con Robux.
2. VARIANTE: todos con la Normal. 3. RASGOS: no se tiran (P37c, Post beta).
4. HABILIDADES: un módulo por Linaje con Z, X y C con los números de su nota de la bóveda (daño,
   recarga, energía, alcance). Validadas en el servidor igual que el combo, con el marcador Impacto.
5. Lo nuevo aparece como "???" hasta usarlo por primera vez.
PRUEBA: 1.000 tiradas simuladas en el servidor y mostrame que los % dan bien; probá las 9 habilidades
contra el maniquí.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Probabilidades visibles y que sumen 100 %.
- Nada aleatorio pagado con Robux (`ideas/monetizacion.md`).

## 6. Pasos y puntos de control
### Paso 1: Ruleta y habilidades
1.000 tiradas y las 9 habilidades.

**Para dar el OK:**
- [ ] Los % dan bien.
- [ ] Las 9 habilidades hacen el daño de su nota.
- [ ] El resultado no se puede trucar desde el cliente.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos de Linajes y Config.

**Cómo lo probás vos:**
- En Play, tirá la ruleta y probá las 3 habilidades contra un matón.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda). Las referencias a la ficha vieja ya están cambiadas por las notas de la bóveda.

```
Leé linajes/boveda/01 Juego/Poderes, inicio y personalización.md y las notas de linajes/boveda/06 Linajes/. Conectá la ruleta del Prompt 33 al guardado.
TODO LO ALEATORIO LO TIRA EL SERVIDOR, nunca el cliente, y las probabilidades se ven siempre en pantalla.
1. LINAJE: Común 55, Poco común 28, Raro 12, Legendario 4, Mítico 1. Seguro: 40 tiradas sin Raro o mejor ⇒
   la siguiente es Raro o mejor. Fichas de Eclipse: 3 al empezar, 1 por nivel, 1 por misión, 3 por jefe.
2. VARIANTE: todos empiezan con la Variante Normal de su Linaje (NO hay ruleta de Variante).
   Las otras Variantes se consiguen por condiciones secretas (Prompt 37c).
3. RASGOS: NO se tiran. Salen de cómo jugás (Prompt 37c).
4. NADA DE EXPLICAR LO QUE CONLLEVA UNA ELECCIÓN: habilidades y Rasgos nuevos aparecen como "???" en el menú
   hasta que los usás por primera vez.
Sin compras con Robux de nada aleatorio.
LINAJES INICIALES con sus Variantes (habilidades base del Prompt 27 + 2 habilidades propias por Variante,
según la tabla de la ficha): Fuerza Bruta, Reflejos, Piroquinesis. Números base:
- Fuerza Bruta: Z Pisotón 25 daño círculo 8 studs, 30 energía, 6 s · X Embestida 20 + empuje, 25, 5 s ·
  C Levantar y tirar 35, 40, 10 s.
- Reflejos: Z Ráfaga 3x8, 20, 4 s · X Contraataque 30 si te pegan en 1 s, 25, 8 s · C Paso sombra 12 studs +
  patada 22, 30, 7 s.
- Piroquinesis: Z Bola de fuego 20 + quemadura 3/s 3 s, 25, 3 s · X Muro de fuego 8/s 4 s, 35, 9 s ·
  C Explosión 40 círculo 10 studs, 50, 14 s.
- Habilidades de Variante (se usan cuando la consigas): 15 a 45 de daño según recarga (4 a 14 s); Claude propone los números en
  Config.luau y me muestra la tabla.
Todo validado en el servidor igual que el combo. Probá 1.000 tiradas simuladas y mostrame que los % dan bien.
```

---
[[P35 Combate|← P35 Combate]]   ·   [[Todos los prompts]]   ·   [[P36b Creador de personaje y personalización|P36b Creador de personaje y personalización →]]
