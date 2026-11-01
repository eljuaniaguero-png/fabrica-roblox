---
tags: [prompt, codigo]
beta: "Solo el módulo **Reputacion.Sumar**, la reputación del **puerto**, la **búsqueda** y el **castigo por desconectarse** buscado. Fama, territorios, tablero de recompensas entre jugadores y PvP, en la Post beta."
---
# P38b Reputación de ciudad, fama, búsqueda y territorios

> [!summary] En tres líneas
> Una sola función para mover toda la reputación, sus efectos en la ciudad, la búsqueda, y el castigo por salir del juego estando buscado.

> [!info] En la Beta
> Solo el módulo **Reputacion.Sumar**, la reputación del **puerto**, la **búsqueda** y el **castigo por desconectarse** buscado. Fama, territorios, tablero de recompensas entre jugadores y PvP, en la Post beta.

## 1. Para qué es
Todo lo que hacés mueve tu reputación con el puerto y eso cambia cómo te trata el mundo.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Reputacion/Reputacion.luau`, `Config.luau` (tabla de motivos).

## 2. Qué leer antes
- [[Mundo abierto y reputación]] (tabla de acciones: manda)
- [[Puerto Óxido]] (barrios)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Pantalla de reputación** → guardar como `linajes/arte/referencias/gemini/reputacion/reputacion.png`
```
Reputation screen: three city bars with titles and no numbers (only the harbor active, the other two locked), three faction bars with rank badges, five group bars, NPC trust shown as hearts, fame meter; harbor map split into five districts colored by faction. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Civiles que aplauden o huyen** → guardar como `linajes/arte/referencias/gemini/reputacion/reaccion.png`
```
Split image: left, harbor civilians cheering a blocky hero on a wet street at night; right, the same civilians fleeing in fear from a masked villain with red wanted stars over their head. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
1. DATOS (P34): reputación con ciudades, bandos, grupos, confianza, fama. Búsqueda por ciudad (0-5),
   NO se guarda... salvo el castigo (punto 4).
2. Reputacion.Sumar(jugador, motivo): motivo es una clave de Config ("FrenarCrimen", "SalvarCivil",
   "Robar", "LastimarCivil", "RomperObjeto", "TerminarTrabajo", "TerminarArco"...) con los valores de la
   tabla de Mundo abierto y reputación. La ciudad sale del Barrio (tag) donde está el jugador.
3. EFECTOS en el puerto: Ídolo / Respetado / Desconocido / Temido / Enemigo público con descuentos,
   tiendas que cierran, civiles que aplauden o huyen.
4. CASTIGO POR DESCONECTARSE buscado (3+ estrellas): al volver, aparece en la celda y pierde lo mismo que
   si lo arrestaban.
POST BETA: fama y títulos, tablero de recompensas entre jugadores, contratos del Albatros, PvP por
bandos y Cráter, territorios con MemoryStore, pantalla completa.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Una sola función para sumar reputación (nada de sumas sueltas).

## 6. Pasos y puntos de control
### Paso 1: Reputación andando
Hacer cosas buenas y malas en el puerto.

**Para dar el OK:**
- [ ] La barra se mueve.
- [ ] Los civiles reaccionan.
- [ ] Salir buscado tiene castigo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `Reputacion.luau` y la tabla en Config.

**Cómo lo probás vos:**
- En Play, frená un crimen y después robá: mirá la barra.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
Leé la sección 0d de linajes/ideas/ficha.md. Todos los números van en Config.luau. Todo lo decide el servidor.
1. DATOS (en el guardado de ProfileStore, por espacio): reputación con cada ciudad (−1000 a +1000),
   con cada bando (0 a 1000), con cada grupo (Policía, Prensa, Corona Corp, Pandillas, Contrabandistas:
   −500 a +500), confianza con cada NPC importante (0 a 500), fama (0 a 10.000),
   nivel de búsqueda por ciudad (0 a 5, NO se guarda: se reinicia al salir).
2. MÓDULO Reputacion.luau con una sola función para sumar: Reputacion.Sumar(jugador, motivo), donde
   motivo es una clave de la tabla de Config ("FrenarCrimen", "SalvarCivil", "Robar", "LastimarCivil",
   "RomperObjeto", "VencerBuscado", "AtacarInocente", "TerminarTrabajo", "TerminarArco"...), con los
   valores de la tabla de la ficha. La ciudad sale del barrio donde está el jugador (Parts del Prompt 20c).
   Los NPCs enemistados: subir confianza con uno baja con su rival (tabla en Config).
3. EFECTOS de la reputación de ciudad: Ídolo/Respetado/Desconocido/Temido/Enemigo público con los
   descuentos, tiendas que cierran, civiles que aplauden o huyen (animación), policía que te ataca y
   recompensa automática. Los diálogos (Prompt 38) pueden pedir cualquier reputación como condición.
4. FAMA: título sobre la cabeza que todos ven (BillboardGui) a partir de 1.000, elegido de una lista según
   lo que más hiciste (ej. "El Fantasma de Vórtice", "Azote del Puerto"); portada de El Faro con los 3
   jugadores con más fama del servidor.
5. BÚSQUEDA: crímenes suben estrellas en esa ciudad; bajan 1 cada 3 minutos sin crímenes o al entrar a una
   guarida de la Cofradía. Con 3 o más: aparece en el Tablero de recompensas; un jugador de la Liga o de los
   Vigilantes acepta el contrato y ve un círculo de 150 studs donde está el buscado. Si lo vence: el buscado
   pierde 15 % del dinero que lleva (nunca objetos), aparece en el Penal Islaroca y puede escaparse con un
   minijuego o con ayuda. Contratos del Albatros contra héroes con fama ≥ 3.000.
6. PVP: solo entre bandos enemigos, contra buscados o dentro del Cráter del Eclipse. En el resto, el daño
   entre jugadores es 0. Marcá en la interfaz quién te puede atacar (borde rojo en el nombre).
7. TERRITORIOS: cada acción suma puntos al bando del jugador en ese barrio (DataStore de conteo semanal,
   con MemoryStore para no pasar el límite de pedidos, actualizado cada 5 min). El bando con más puntos
   controla el barrio: cambian color de luces y carteles, qué crímenes salen y precios (−10 % para ese bando).
   Reinicio los lunes. El Faro muestra el estado.
8. PANTALLA "Reputación" en el menú (Prompt 33): barras con título y SIN números exactos para las
   3 ciudades, los 3 bandos (con rango), los 5 grupos, los NPCs (corazones) y la fama; mapa de barrios por color.
9. ARCOS: el NPC que abre cada arco solo te habla con reputación +100 o −100 en esa ciudad.
Probá con 2 jugadores: uno roba en Corona hasta tener 3 estrellas y el otro, de la Liga, lo caza.
Commit y push.
```

---
[[P38c Calle viva civiles, testigos, policía y vigilancia|← P38c Calle viva civiles, testigos, policía y vigilancia]]   ·   [[Todos los prompts]]   ·   [[P38d Atracos|P38d Atracos →]]
