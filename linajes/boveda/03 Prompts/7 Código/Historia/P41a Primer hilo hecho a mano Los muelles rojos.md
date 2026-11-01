---
tags: [prompt, codigo]
beta: "El hilo **completo hasta Remache** (misiones 1 a 7 de la nota). El asalto al barco, Brandt y los finales que cambian el puerto, en la Post beta."
---
# P41a Primer hilo hecho a mano Los muelles rojos

> [!summary] En tres líneas
> La historia de la Beta: Nico desaparece, seguís el cargamento de implantes, arreglás el gancho con Tano, hacés el atraco y terminás peleando con Remache.

> [!info] En la Beta
> El hilo **completo hasta Remache** (misiones 1 a 7 de la nota). El asalto al barco, Brandt y los finales que cambian el puerto, en la Post beta.

## 1. Para qué es
Es el contenido de la Beta: 30 a 45 minutos de historia que terminan en el jefe.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Hilos/MuellesRojos.luau`, diálogos en `src/shared/Dialogos/`, `Config.luau`.

## 2. Qué leer antes
- [[Los muelles rojos]] (manda: misiones, decisiones, finales)
- [[Tano]] · [[El Albatros]] · [[Remache]]
- [[Galpón de Remache]] · [[Taller de Tano]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Mapa del hilo en el puerto** → guardar como `linajes/arte/referencias/gemini/muelles-rojos/mapa.png`
```
Story map of a harbor district with seven numbered mission markers connected by a dotted path: garage, docks, customs warehouse, fish market, rooftop crane, storage warehouse, red boss warehouse; fog and night palette. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Final: pelea con Remache** → guardar como `linajes/arte/referencias/gemini/muelles-rojos/remache.png`
```
A group of three blocky heroes facing a huge piston-armed brute with a red-visor welding helmet inside a red-lit warehouse arena, red glowing tanks, a container being lifted, sparks and steam. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
Seguí la nota Los muelles rojos al pie de la letra (misiones, NPCs, decisiones a ciegas). Es un HILO
del Narrador: se abre con un gancho (Tano preocupado por Nico, o el Albatros cobrándote la deuda), no
es obligatorio. Enemigos ajustados al nivel (±2, mínimo 3).
Cada misión empieza y termina hablando con un NPC (P38), con marcador en el mapa y objetivo arriba.
Beta: misiones 1 a 7, con el atraco de P38d, el gancho de P40 y el jefe Remache (2 fases, 2.000 de vida,
animaciones de P28, cinemáticas de P30c) en el Galpón de Remache. Al vencerlo: rescatás a Nico,
recompensa (XP, dinero, chatarra, 3 Fichas de Eclipse), Mascarada aparece en una pantalla (gancho Post
beta) y cartel "Fin de la Beta: gracias por jugar".
El hilo suma reputación del puerto (Reputacion.Sumar) y confianza con Tano o el Albatros según tus
decisiones. Guardá las decisiones (P34).
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Las decisiones son a ciegas y se guardan.
- El jefe se sincroniza para todos los jugadores de la arena.

## 6. Pasos y puntos de control
### Paso 1: Jugar el hilo
De punta a punta con 1 jugador y después con 2.

**Para dar el OK:**
- [ ] Dura 30-45 min.
- [ ] Nunca te quedás sin saber qué hacer.
- [ ] Remache se siente justo y difícil.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulo del hilo, diálogos y Config.

**Cómo lo probás vos:**
- Jugá el hilo completo y contame dónde te trabaste.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
Leé las secciones 0d y 0f de linajes/ideas/ficha.md. Este es un HILO HECHO A MANO del Narrador (Prompt 41):
no es obligatorio ni va primero; se abre con 3 ganchos distintos (Tano te pide ayuda con un mecánico
desaparecido; el Albatros te ofrece un trabajo si tenés −100 en el puerto; ves desde un techo un cargamento
de implantes). Los enemigos se ajustan al nivel del jugador (±2, mínimo 5).
HILO "Los muelles rojos" en Puerto Óxido, con los modelos de los Prompts 6, 13, 20 y 21:
MISIONES DE HISTORIA (todas empiezan y terminan hablando con un NPC):
1. Rivas: "Algo pasa en el puerto" → investigar 3 galpones (pistas: cajas con logo de Corona Corp).
2. Vega: fotos del cargamento ilegal → descubrís implantes robados.
3. Señal: rescatar a un mecánico secuestrado (pelea contra 6 matones con implantes).
4. Tano: arreglar el gancho para subir a la grúa.
5. Jefe 1: Remache (2 fases, 2.000 de vida, ataques del Prompt 28, arena del muelle).
6. Brandt te ofrece la Transferencia del fragmento de Remache (Linaje secundario: 1 habilidad de
   Fuerza Bruta) si aceptás un trabajo para ella.
7. Evento de grupo: Asalto al barco del Albatros (1 a 8 jugadores, la vida de los enemigos escala con
   la cantidad), oleadas de matones en la cubierta y jefe El Albatros (3.000 de vida, 2 fases).
8. Final del arco: 2 o 3 finales según tu reputación con el puerto y tus decisiones (ver Prompt 41b),
   que cambian quién controla Puerto Óxido en tu partida. Aparece Mascarada en una pantalla gigante y deja
   pistas que llevan a Ciudad Vórtice y al Distrito Corona (sin obligarte a ir a ninguna).
El arco suma reputación con el puerto (Reputacion.Sumar del Prompt 38b) y confianza con Tano, Rivas o el Albatros.
MISIONES DE BANDO (3 por bando): Liga rescata trabajadores; Cofradía roba un cargamento para Mascarada;
Vigilantes sigue a un informante de noche sin ser visto.
Recompensas: XP, dinero, chatarra, fichas de Eclipse, el traje "Cuervo del puerto" para el que termine el arco.
```

---
[[P39 Prólogo tu origen y la Noche del Eclipse|← P39 Prólogo tu origen y la Noche del Eclipse]]   ·   [[Todos los prompts]]   ·   [[P43 Probar, medir y publicar la beta|P43 Probar, medir y publicar la beta →]]
