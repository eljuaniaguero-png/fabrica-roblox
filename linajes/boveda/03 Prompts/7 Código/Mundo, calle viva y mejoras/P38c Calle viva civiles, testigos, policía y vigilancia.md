---
tags: [prompt, codigo]
beta: "En el **puerto**: civiles (20 cerca del jugador), testigos que llaman, cámaras, policía hasta **3 estrellas**, identidad secreta, arresto simple y un callejón peligroso (Los Óxido). Jugadores policía, nivel de crimen por barrio y estrellas 4-5, en la Post beta."
---
# P38c Calle viva civiles, testigos, policía y vigilancia

> [!summary] En tres líneas
> La ciudad reacciona: civiles que caminan, testigos que llaman a la policía, cámaras, búsqueda con estrellas, máscara e identidad secreta, arresto y callejones peligrosos.

> [!info] En la Beta
> En el **puerto**: civiles (20 cerca del jugador), testigos que llaman, cámaras, policía hasta **3 estrellas**, identidad secreta, arresto simple y un callejón peligroso (Los Óxido). Jugadores policía, nivel de crimen por barrio y estrellas 4-5, en la Post beta.

## 1. Para qué es
Hace que el puerto se sienta vivo y que portarse mal tenga consecuencias que se ven.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/CalleViva/` (Civiles, Testigos, Camaras, Policia, Arresto, Callejones), `Config.luau` (CalleViva).

## 2. Qué leer antes
- [[Calle viva]] (manda)
- [[Puerto Óxido]] (barrios, callejón de Los Óxido)
- [[Calle viva (puerto)]] (modelos)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Testigo llamando a la policía** → guardar como `linajes/arte/referencias/gemini/calle-viva/testigo.png`
```
A frightened civilian on a foggy harbor street at night holding a phone to their ear and looking around, while a masked blocky thief runs away with a bag in the background; a small floating phone icon with a 4-second circular timer above the civilian. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Mapa de búsqueda** → guardar como `linajes/arte/referencias/gemini/calle-viva/busqueda.png`
```
Minimap overlay of a harbor district showing a shrinking red search circle, three red wanted stars at the top, police car icons approaching, a blue camera view cone. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
1. CIVILES: 20 cerca de cada jugador en el puerto (máx. 60 por servidor), ropa al azar con el kit de
   P20d, caminan por Parts con tag "Vereda", se van y vuelven (nunca aparecen delante de un jugador).
2. TESTIGOS: un delito (Reputacion.Sumar con motivo de delito) crea un evento con posición. Civiles con
   línea de vista a menos de 60 studs se asustan; el más cercano llama (animación de P29b, 4 s, marcador
   LlamadaHecha). Se corta alejándote a más de 80 studs o si un héroe lo protege. Tipos: valiente (5 %),
   curioso que filma (10 %).
3. CÁMARAS (tag "Camara"): cono de 40 studs y 60°: aviso inmediato. Romperlas también es delito.
4. BÚSQUEDA (Beta, hasta 3 estrellas): 1 patrullero, 2 patrullas, 3 tablero de recompensas. Nadie muere:
   "fuera de combate". Policía: investigar, perseguir, esposar de cerca. Zona de búsqueda que se achica.
   Perderla: sacarte la máscara sin testigos, guarida del Albatros, o 3 min por estrella sin delitos.
5. IDENTIDAD SECRETA: atributo "Enmascarado"; si te ven ponértela o sacártela, quedás expuesto en esa ciudad.
6. ARRESTO: esposado ⇒ pierde botín, dinero sucio y 15 % del dinero en mano; aparece en una celda del puerto
   (el Penal está cerrado en la Beta) y sale con 2 min de tareas.
7. CALLEJÓN DE LOS ÓXIDO (tag "Callejon"): emboscada según la hora; si lo limpian, seguro 30 min.
PRUEBA con 2 jugadores: uno roba en el puerto, un civil llama, sube a 3 estrellas y la policía lo esposa.
POST BETA: estrellas 4-5, jugadores policía, nivel de crimen por barrio, Interferidor, Intimidar.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Civiles y policía solo cerca de jugadores (rendimiento en celular).
- Nadie muere: fuera de combate.

## 6. Pasos y puntos de control
### Paso 1: Crimen y castigo
Prueba con 2 jugadores.

**Para dar el OK:**
- [ ] El testigo llama y se puede frenar.
- [ ] Las estrellas suben y bajan.
- [ ] La máscara funciona.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos de calle viva y Config.

**Cómo lo probás vos:**
- En Play, robá algo frente a un civil y escapate.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda). Las referencias a la ficha vieja ya están cambiadas por las notas de la bóveda.

```
Leé linajes/boveda/01 Juego/Calle viva.md. Todo lo decide el servidor, números en Config.luau.
1. CIVILES: spawner por barrio con densidad según ciudad y hora (Corona de día 40 civiles cerca del
   jugador, Vórtice 15, Puerto 20), ropa armada al azar con el kit del Prompt 20d. Caminan por puntos de
   vereda (Parts con tag "Vereda"), se van a casa y vuelven (no aparecen de la nada delante de un jugador).
   Máximo 60 civiles activos por servidor, solo cerca de jugadores.
2. TESTIGOS: un crimen (cualquier acción con motivo de delito en Reputacion.Sumar) genera un evento con
   posición. Civiles con línea de vista a menos de 60 studs se asustan; el más cercano llama a la policía
   (animación del Prompt 29b, 4 s). Sin señal (subte, callejones) corre a un teléfono público o botón
   de alarma. Un héroe cerca puede protegerlo para que termine la llamada. Si termina: aviso con descripción (nombre de héroe si tenía máscara,
   "un civil" si no). Cortar la llamada: alejarse a más de 80 studs, gadget Interferidor, o Intimidar
   (solo jugadores de la Cofradía o Neutral; −10 reputación de ciudad). Tipos raros: valiente (5 %),
   curioso que filma (10 %, suma fama y crea material para El Faro), informante (5 %).
3. CÁMARAS (tag "Camara"): cono de 40 studs y 60°; si ven un delito, aviso inmediato. Hackear (minijuego
   5 s) las apaga 2 minutos; romperlas también es delito.
4. BÚSQUEDA (sigue el Prompt 38b): estrellas por ciudad con la escalera de la ficha (1 patrullero,
   2 patrullas, 3 tablero + drones, 4 Unidad Táctica + helicóptero + cortes de ruta en puentes y túneles,
   5 Escuadra Halcón + un héroe NPC). Nadie muere: los vencidos quedan "fuera de combate". Policía con IA simple: investigar el lugar, perseguir, esposar a corta distancia.
   Modo "buscando" cuando pierden la vista: zona de búsqueda visible en el mapa que se achica.
   Perder la búsqueda: sacarse la máscara sin testigos, guarida de la Cofradía, pagar a un contacto, o
   3 min por estrella sin delitos.
5. IDENTIDAD SECRETA: atributo "Enmascarado". Si un testigo te ve ponerte o sacarte la máscara, tu identidad
   queda expuesta en esa ciudad (los civiles te reconocen sin máscara).
6. ARRESTO: esposado → Penal Islaroca, pierde botín, dinero sucio y 15 % del dinero en mano. Salir: 2 min
   de tareas, fianza, minijuego de escape, o rescate de otro jugador. Policías corruptos en el puerto
   (coima si Contrabandistas ≥ 200).
7. JUGADORES POLICÍA: trabajo de Patrullero: radio con la lista de avisos (lugar, tipo, descripción),
   esposas, auto patrulla. Esposar a un NPC o jugador buscado le da reputación con la Policía.
8. NIVEL DE CRIMEN POR BARRIO (0 a 100): sube con delitos, baja al frenarlos, cambia cuántos crímenes NPC
   salen (carteristas, robo de autos, asaltos, cobro de protección, vendedores ilegales).
9. CALLEJONES PELIGROSOS (tag "Callejon"): emboscada al entrar (chance según nivel de crimen y hora),
   alijos, teniente; si lo vencen: luces arregladas y callejón seguro 30 min para todo el servidor.
Probá con 2 jugadores: uno roba un kiosco en Corona, un civil llama, sube a 3 estrellas y el otro, de
Patrullero, lo esposa. Commit y push.
```

---
[[P38 Diálogos con NPCs, trabajos y reputación|← P38 Diálogos con NPCs, trabajos y reputación]]   ·   [[Todos los prompts]]   ·   [[P38b Reputación de ciudad, fama, búsqueda y territorios|P38b Reputación de ciudad, fama, búsqueda y territorios →]]
