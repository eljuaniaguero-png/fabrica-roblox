---
tags: [prompt, codigo]
beta: "**1 atraco chico**: el **almacén del muelle** (1 a 2 jugadores), con su interior de P25d. Medianos y grandes, en la Post beta."
---
# P38d Atracos

> [!summary] En tres líneas
> El primer atraco: entrar al almacén del muelle, evitar cámaras y guardia, abrir la caja fuerte y escapar con la bolsa; dinero sucio que se lava.

> [!info] En la Beta
> **1 atraco chico**: el **almacén del muelle** (1 a 2 jugadores), con su interior de P25d. Medianos y grandes, en la Post beta.

## 1. Para qué es
Es la misión 5 de Los muelles rojos y el primer gusto del lado villano.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Atracos/` (un módulo por atraco), `Config.luau` (Atracos).

## 2. Qué leer antes
- [[Calle viva]] (Atracos)
- [[Los muelles rojos]] (misión del almacén)
- P25d (Parts Spawn_Guardia, Camara, Botin, Salida)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Atraco al almacén: plan visto desde arriba** → guardar como `linajes/arte/referencias/gemini/atracos/almacen.png`
```
Top-down heist planning view of a small harbor warehouse: skylight entry, guard patrol path, two camera view cones, safe location, loot bag icon, escape route arrow to a back alley; tactical blue-print style. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Escape con la bolsa** → guardar como `linajes/arte/referencias/gemini/atracos/escape.png`
```
A masked blocky thief jumping from a harbor warehouse skylight onto a wet rooftop at night carrying a heavy loot bag, police lights flashing below, fog and cranes. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
ATRACO DEL ALMACÉN DEL MUELLE (1 a 2 jugadores), con los Parts del interior de P25d:
1. ENTRADA: portón trasero con candado (forzar 5 s, animación de P29b) o claraboya (silencioso).
2. CÁMARAS (2) y GUARDIA (Spawn_Guardia, patrulla): si te ven, alarma y 2 estrellas.
3. CAJA FUERTE: minijuego de 20 s (girar el dial hasta 3 marcas). Bolsa de botín en Botin.
4. ESCAPE: la bolsa baja la velocidad 25 %, se puede tirar y pasar; entregarla en el mercado de pescado.
5. DINERO SUCIO (dinero del juego, nunca Robux): se lava en el mercado negro perdiendo 20 %; si te
   arrestan, lo perdés todo. Recarga del atraco: 20 min por servidor.
Para Los muelles rojos: el atraco puede hacerse "del lado héroe" (frenar a los ladrones NPC).
POST BETA: atracos medianos y grandes en 4 etapas, alertas a héroes, PvP en la zona.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- El botín es dinero del juego, nunca Robux.

## 6. Pasos y puntos de control
### Paso 1: Atraco completo
Entrar, robar, escapar.

**Para dar el OK:**
- [ ] Hay 2 formas de entrar.
- [ ] Las cámaras y el guardia se pueden evitar.
- [ ] La bolsa pesa y se nota.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulo del atraco y Config.

**Cómo lo probás vos:**
- En Play, hacé el atraco sin que suene la alarma.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda). Las referencias a la ficha vieja ya están cambiadas por las notas de la bóveda.

```
Leé la parte "Atracos" de linajes/boveda/01 Juego/Calle viva.md. Todo en el servidor, números en Config.
1. ATRACOS CHICOS (1 jugador): carterista (minijuego de 3 s), kiosco y tiendas (forzar la caja 5 s),
   cajero (hackeo 8 s), robar un auto. Botín chico en dinero, delito para la búsqueda.
2. ATRACOS MEDIANOS (1 a 4): Joyería Aurora (romper vitrinas, caja fuerte 30 s), Casa de empeño,
   camión blindado en movimiento (evento: hay que frenarlo y abrir la puerta 45 s), Bodegas de aduana
   (usar el puente grúa para bajar un contenedor).
3. ATRACOS GRANDES (4 a 6), en 4 etapas: PLANEAR en el tablero de golpes del Albatros (elegir golpe,
   roles Hacker/Músculo/Conductor/Vigía y modo Silencio o Ruido); PREPARAR (misiones cortas para conseguir
   planos o tarjeta: sin eso, la entrada es más difícil); GOLPE (entrada, cámaras y guardias de los Parts
   "Spawn_Guardia" del Prompt 25d, taladro en la bóveda que hay que defender 90 s, bolsas en los Parts
   "Botin"); ESCAPE (bolsas pesadas que bajan la velocidad, se pasan entre jugadores, entregar al Reducidor
   del mercado negro o a la casa de empeño). Banco Central, Museo, laboratorio de Corona Corp, cargamento
   del Albatros. Un atraco grande cada 30 min por servidor.
4. HÉROES: al empezar un atraco mediano o grande, alerta "Atraco en curso en [lugar]" para Liga y
   Vigilantes. Durante el atraco, PvP entre atacantes y defensores dentro de la zona. Recuperar bolsas
   y devolverlas a la policía da mucha reputación.
5. Botín = DINERO SUCIO (dinero del juego, nunca Robux): se lava en el mercado negro o la casa de empeño
   perdiendo 20 %; si te arrestan con dinero sucio, lo perdés todo. Las bolsas recuperadas por héroes no se pierden del mundo:
   vuelven al banco.
Probá un atraco grande con 4 jugadores atacando y 2 defendiendo. Commit y push.
```

---
[[P38b Reputación de ciudad, fama, búsqueda y territorios|← P38b Reputación de ciudad, fama, búsqueda y territorios]]   ·   [[Todos los prompts]]   ·   [[P40 Tecnología e implantes|P40 Tecnología e implantes →]]
