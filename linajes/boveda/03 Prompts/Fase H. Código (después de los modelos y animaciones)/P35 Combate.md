---
tags: [prompt, codigo]
beta: "Completo con el estilo **Puños**, el maniquí de prueba, el matón del puerto y el matón con implantes. Cola de teclas y hit-stop de la revisión del 31 oct."
---
# P35 Combate

> [!summary] En tres líneas
> El combate: combo de 4 golpes, bloqueo, parry, dash, energía y vida, con el servidor decidiendo cada golpe en el marcador Impacto. Enemigos que avisan antes de pegar.

> [!info] En la Beta
> Completo con el estilo **Puños**, el maniquí de prueba, el matón del puerto y el matón con implantes. Cola de teclas y hit-stop de la revisión del 31 oct.

## 1. Para qué es
Es el corazón del juego. Si pelear no se siente bien en el primer minuto, el jugador se va.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Combate/`, `linajes/src/client/Combate/`, `Config.luau` (tabla Combate).

## 2. Qué leer antes
- [[Combate y progresión]] (teclas y números: mandan)
- [[Riesgos y mejoras (revisión 31 oct)]] (cola de teclas, hit-stop)
- [[Matón del puerto (modelo)]] · [[Matón con implantes (modelo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Momento de pelea en el puerto (cómo se tiene que sentir)** → guardar como `linajes/arte/referencias/gemini/combate/pelea.png`
```
Action frame of an original stylized Roblox superhero brawler: a blocky hero landing the fourth hit of a combo (spinning kick) on a harbor thug, hit-stop freeze with a white impact star, slight camera shake lines, a second thug winding up with red warning arrows on the wet floor, foggy harbor at night with cranes. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Diagrama del combo y el parry** → guardar como `linajes/arte/referencias/gemini/combate/combo.png`
```
Clean infographic timeline for a fighting game: four punches in a row with timing bars (0.35 s between hits, combo resets after 0.8 s), a block window, a parry window of 0.2 s highlighted in cyan, a dash with invulnerability frames highlighted, icons only. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
Usá el cuerpo propio con un traje del creador y las animaciones de P26 (IDs en Config.luau).
NÚMEROS (Config.luau, de Combate y progresión): combo 8, 8, 10 y 14; el combo vuelve al golpe 1 si
pasan 0,8 s; el 4.º empuja 6 studs. Bloqueo: frena 70 % de frente y gasta 10 de energía por golpe; no
podés atacar bloqueando. Parry: F en los 0,2 s antes del golpe ⇒ el atacante queda aturdido 1 s.
Dash: 20 studs, recarga 1,5 s, invulnerable 0,25 s. Vida 400 y energía 100 (+8/s sin usar habilidades)
en nivel 1 (las estadísticas las suben, P37).
REGLAS: el cliente reproduce animación y sonido al instante; el SERVIDOR decide en el marcador Impacto:
hitbox GetPartBoundsInBox de 5x5x6 delante del atacante, distancia máx. 8 studs, recargas, energía,
máximo 10 pedidos por segundo. COLA DE TECLAS: guarda 1 tecla apretada en los últimos 0,15 s de una
animación. HIT-STOP: 0,05 s (0,08 en el 4.º golpe) en los dos personajes, solo visual.
ENEMIGOS: maniquí con vida infinita y números de daño; matón del puerto (120 de vida, persigue a 14
studs/s, Aviso rojo 0,4 s antes, pega 12); matón con implantes (200 de vida, puño hidráulico 20).
CELULAR: botones del HUD de P33.
Si pelear no se siente bien, decime qué ajustarías antes de seguir.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- El daño se aplica **solo** en el servidor en el marcador Impacto.

## 6. Pasos y puntos de control
### Paso 1: Pelear
Play contra el maniquí y los 2 matones.

**Para dar el OK:**
- [ ] El combo encadena sin perder teclas.
- [ ] El parry se siente justo.
- [ ] Los matones avisan antes de pegar.
- [ ] En celular se puede pelear con el pulgar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos de combate y números en Config.

**Cómo lo probás vos:**
- En Play, pelea contra 3 matones a la vez.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
Usá el traje de Cuervo y las animaciones base (IDs en Config.luau).
NÚMEROS (en Config.luau): combo 4 golpes de 8, 8, 10 y 14 de daño; 0,35 s entre golpes; el combo se
corta si pasan 1,0 s; el golpe 4 empuja 6 studs. Bloqueo: reduce 80 % del daño, no podés atacar
mientras bloqueás. Parry: si bloqueás en los 0,2 s antes de un golpe, el atacante queda aturdido 1,2 s.
Dash: 14 studs en 0,25 s, recarga 2,5 s, invulnerable los primeros 0,15 s. Vida 100, energía 100,
energía vuelve 8 por segundo.
REGLAS: el cliente reproduce la animación y el sonido al instante; el SERVIDOR decide el golpe en el
marcador Impacto: hitbox con GetPartBoundsInBox de 5x5x6 studs delante del atacante, chequea distancia
(máx. 8 studs), recargas, energía, y un límite de 10 pedidos por segundo por jugador.
ENEMIGOS DE PRUEBA: un maniquí con vida infinita que muestra el número de daño flotando; un matón del
puerto (modelo + animaciones) con 120 de vida que te persigue a 14 studs/s, y antes de pegar muestra
flechas rojas #ff2a2a en el piso 0,4 s (marcador Aviso), pega 12.
CELULAR: botones del HUD del Prompt 33.
Si pelear no se siente bien, decime qué ajustarías antes de seguir.
```

---
[[P34 Base y guardado|← P34 Base y guardado]]   ·   [[Todos los prompts]]   ·   [[P36 Ruleta Linaje, Variante y Rasgos|P36 Ruleta Linaje, Variante y Rasgos →]]
