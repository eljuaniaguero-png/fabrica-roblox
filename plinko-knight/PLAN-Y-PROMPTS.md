# Plinko Knight · Plan completo y prompts por etapa (25/10/2026)

Un caballero baja por una mazmorra. Su ataque es una bola que tira desde arriba de un tablero de clavijas: cada clavija que toca suma daño, y el total le pega al monstruo de abajo. 6 peleas y un jefe. Entre peleas elige 1 de 3 mejoras.

Este archivo tiene todo: el plan por etapas, cómo tiene que verlo el jugador, los números de arranque, el arte (con los prompts para Gemini) y **un prompt listo para pegar en Claude Code por cada etapa**.

---

## Cómo usarlo (Juani)

1. Terminá y publicá Forja Rápida primero (es lo que quedó decidido). Plinko Knight es el juego 3 de la lista, después de The Core Collapse y Puerta de Contención. Si querés adelantarlo porque es el más chico, se puede: no comparte código con los otros.
2. En Claude Code, en `fabrica-roblox`, pegá el **Prompt 1** (la ficha). Claude arma la ficha y la carpeta, y **frena para que la apruebes**. No programa nada todavía.
3. Cuando digas "dale" a la ficha, hacé `/clear` y pegá el **Prompt 2**. Después el 3, el 4… **uno por sesión**, y esperá las capturas antes del siguiente.
4. Antes de cada prompt: abrí Roblox Studio con el place de Plinko Knight y conectá Rojo (Plugins → Rojo → Connect). Claude te dice si falta algo.
5. Si algo no te gusta: "Esto no me gusta: …" y lo arregla antes de seguir.

Hay una copia de este archivo en tu PC en `plinko-knight/PLAN-Y-PROMPTS.md`. Todos los prompts le piden a Claude que lea la sección **Reglas** de ese archivo, así no se repiten en cada uno.

### Las etapas

| # | Etapa | Qué tenés al final | Punto de control |
|---|---|---|---|
| 1 | Ficha y carpeta | `ideas/plinko-knight.md` + carpeta que abre en Studio | **Aprobás la ficha** |
| 2 | Tablero y bola | Apuntás, soltás y la bola rebota bien (sin daño) | Capturas |
| 3 | Daño y números | Cada clavija muestra su número; el servidor revisa el total | Capturas |
| 4 | Monstruos y mazmorra | 6 peleas + jefe, contraataque, perder y volver a empezar | Capturas |
| 5 | Mejoras 1 de 3 | Bola de fuego, clavija que duplica, bola que se divide | **Prototipo jugable: probalo 5 minutos** |
| 6 | Guardado | Mejor piso y bolas desbloqueadas con ProfileStore | Salir y volver |
| 7 | Pantallas (lo que ve el jugador) | Inicio, pelea, mejoras, derrota, victoria; compu y celular | Capturas |
| 8 | Elegir estilo visual | 3 muestras de mazmorra y vos elegís una | **Elegís estilo** |
| 9 | Arte final | Mazmorra de piedra, clavijas doradas, monstruos planos de Gemini | Lado a lado |
| 10 | Sensación y sonido | Golpes que se sienten, números que explotan, sonidos | Video corto |
| 11 | Antes de publicar | Tutorial del primer minuto, analítica, checklist | **Publicás vos** |

**La prueba de los 5 minutos (después de la etapa 5):** jugá en gris, sin arte. Si perdés en la pelea 4 y querés empezar de nuevo enseguida, el juego sigue. Si te aburre, se frena ahí y no se gasta tiempo en arte. Por eso el arte va al final.

---

## Cómo lo ve el jugador (pantalla de pelea)

> **Cambio aprobado el 25/10/2026:** la pantalla va en **3 columnas**: panel de vida y daño a la izquierda, tablero al centro y monstruo a la derecha. El panel de daño tiene dos cajas (daño | ×2) y la paleta favorita es "Cripta azul". Ver `plinko-knight/arte/IDEA-DE-ARTE.md`, que manda sobre el dibujo de abajo. Va en la ficha (Prompt 1) y se usa desde la etapa 2 (con los bloques grises).

```
┌──────────────────────────────────────────────┐
│ ♥ 50/50   [Pelea 3 de 7]          ⚙          │  ← vida del caballero, piso, ajustes
│                                              │
│              🛡 caballero + lanzador          │  ← arriba: de acá sale la bola
│              ·  ·  ·  línea de puntería       │
│        ●   ●   ●   ●   ●   ●   ●             │
│          ●   ●   ●   ●   ●   ●               │  ← tablero de clavijas (dorado)
│        ●   ●   ●   ●   ●   ●   ●             │     cada toque: "+2" amarillo flúor
│          ●   ●   ●   ●   ●   ●               │
│        ●   ●   ●   ●   ●   ●   ●             │
│ ═══════════════  TOTAL: 34  ════════════════ │  ← contador que sube mientras rebota
│              👹 MONSTRUO (imagen plana)       │  ← abajo: recibe el total
│              ████████░░░░  60/85             │  ← vida del monstruo
│  Bola: 🔥 Fuego        Mejoras: 🔥 ✖2 ✂       │  ← bola actual y mejoras que tenés
└──────────────────────────────────────────────┘
```

- **Cámara fija**, mirando el tablero de frente. Nada de mover la cámara ni caminar durante la pelea.
- **Apuntar:** en compu, mover el mouse y clic para soltar. En celular, apoyar el dedo, arrastrar y soltar. Se ve una línea de puntos cortita (solo el primer tramo, no todo el recorrido, así no es trivial).
- **Mientras rebota:** cada clavija tocada brilla, salta un poquito y muestra su número. El TOTAL sube con un sonido que va subiendo de tono.
- **Cuando la bola llega abajo:** el total vuela hacia el monstruo, el monstruo se sacude y pierde vida. Si sigue vivo, contraataca (se agranda, golpe, la pantalla tiembla apenas, baja tu vida).
- **Al ganar una pelea:** aparecen 3 cartas de mejora grandes, tocás una y bajás al siguiente piso.
- **Al perder:** pantalla "Caíste en el piso 4 · Tu mejor: piso 5" con un botón grande "Volver a bajar". Un toque y estás jugando otra vez (eso es lo que hace que se quiera reintentar).
- Todo tiene que leerse en un celular en horizontal: botones grandes, números grandes, poco texto.

---

## Números de arranque (Claude los pasa a `Config.luau` y los ajusta probando)

| Qué | Valor inicial | Por qué |
|---|---|---|
| Tablero | 7 columnas × 8 filas alternadas (unas 52 clavijas) | Entra en pantalla de celular |
| Daño por clavija | 2 | Un tiro normal toca 10 a 18 clavijas → 20 a 36 de daño |
| Cada clavija cuenta | **una vez por tiro** | Que la bola no se quede rebotando en el mismo lugar sumando |
| Vida del caballero | 50, se cura 10 entre peleas | Perder en la pelea 4 a 6 en las primeras partidas |
| Monstruos (vida / golpe) | 1: 40 / 4 · 2: 60 / 5 · 3: 85 / 6 · 4: 115 / 7 · 5: 150 / 8 · 6: 190 / 9 · **Jefe: 320 / 11** | Cada pelea dura 2 a 4 tiros |
| Bola de fuego | +1 daño por clavija; el monstruo se quema 3 por turno durante 2 turnos | Simple de entender |
| Clavija que duplica | 2 clavijas del tablero se vuelven rojas; al tocarla, el total del tiro hasta ese momento ×2 (cada una una vez por tiro) | El momento "¡wow!" de números grandes |
| Bola que se divide | En el 5.º toque la bola se parte en 2; las dos siguen sumando | Mucho movimiento en pantalla |
| Repetir mejora | Cada vez que la elegís de nuevo mejora: fuego +1, una clavija roja más, se divide en el 4.º toque y después en 3 | Que elegir lo mismo también sirva |
| Bolas que se desbloquean (se guardan) | Hierro (desde el inicio) · Fuego (llegar al piso 4) · Partida (ganarle al jefe) | Motivo para volver |

**Importante (regla de Roblox):** abajo del tablero **no hay casilleros con multiplicadores** (×2, ×10, etc.). Eso es lo que hace que un plinko parezca un juego de apuestas. El daño sale solo de las clavijas que toca la bola y de las mejoras.

---

## Qué queda FUERA de la versión mínima

Mazos de bolas, reto diario, ranking, cualquier cosa con Robux, varias mazmorras, multijugador cooperativo, mascotas, tienda. Se anotan en la ficha como "después" y no se programan. Cuando llegue Robux: aspectos de bola y de tablero; si alguna vez hay algo al azar pagado, probabilidades visibles y PolicyService como decidiste para Mutant Lab.

---

## Cómo funciona por dentro (para Claude, resumido)

- **Física propia en 2D, no la de Roblox.** Un módulo compartido (`shared/Simulacion.luau`) calcula el recorrido de la bola en el plano del tablero: gravedad, rebote en clavijas (círculos) y paredes, paso fijo de tiempo. Ventajas: la bola no se puede escapar hacia la cámara, se puede probar con `lune` fuera de Studio, y **el servidor puede repetir el mismo cálculo** para revisar el daño.
- **El cliente** dibuja: mueve la bola y prende las clavijas siguiendo la simulación. El tablero lo arma cada cliente solo para sí (no se replica), así cada jugador tiene el suyo aunque haya 8 en el servidor.
- **El servidor** lleva la partida (piso, vida, mejoras, monstruo). Para cada tiro: le da al cliente una semilla, el cliente manda solo el ángulo y el daño que vio; el servidor corre la misma simulación con ese ángulo y esas mejoras, y si no coincide (margen chico) usa su propio número. Además, un tope de daño por tiro y un límite de frecuencia.
- Es exactamente "la física corre en el cliente y el servidor revisa que el daño sea razonable", pero más seguro y sin lag.

---

## Reglas (Claude: leelas antes de cada prompt de este archivo)

```
REGLAS DE PLINKO KNIGHT
1. Mandan CLAUDE.md y GUIA-PARA-CLAUDE.md. Nada de worktrees ni de setup/new-system de
   roblox-dev. Juego: Plinko Knight, carpeta plinko-knight/, ficha ideas/plinko-knight.md.
2. Antes de tocar nada: git status. Si hay cambios sin commit de OTRO juego, decime qué son en
   3 líneas y no los mezcles con los de este. Después commit "antes de <etapa>".
3. Solo se toca plinko-knight/ (y la fila de la tabla de CLAUDE.md). Nunca src/, mutant-lab/,
   forja-rapida/ ni pesca-compas/. Antes de construir por MCP, confirmá que el Studio abierto es
   el place de Plinko Knight; si es otro, frená y avisá.
4. Rojo: rojo serve plinko-knight. Chequeos: stylua plinko-knight/src y selene
   plinko-knight/src. Tests de lógica: lune run plinko-knight/pruebas/<nombre>.
5. NADA de casino ni apuestas: ni las palabras casino, apuesta, ficha, jackpot, pachinko, premio
   al azar; ni casilleros con multiplicadores abajo del tablero; ni tragamonedas o ruletas.
   Es un caballero que pelea en una mazmorra. El daño sale de clavijas y mejoras.
6. El servidor decide todo: valida tipos, números finitos, frecuencia y que el tiro sea del
   turno actual. Todos los números en plinko-knight/src/shared/Config.luau.
7. Física de la bola: solo el módulo shared/Simulacion.luau (2D, paso fijo, determinista).
   Nada de BasePart con física de Roblox para la bola. El servidor repite la simulación.
8. Graybox hasta la etapa 8: bloques grises, sin arte. Colores solo para distinguir cosas
   (clavija normal gris claro, clavija que duplica rojo, bola blanca).
9. Celular: todo se prueba también en el emulador de celular de Studio, en horizontal, a 30 FPS
   o más. Botones de 44 px o más. Respetá "Efectos reducidos" si existe en Ajustes.
10. Nada con Robux. Si una etapa cambia lo que se guarda, subí VERSION con su migración.
11. Al terminar: Play por MCP con consola sin rojo, capturas en compu y celular, commit en
   español (y git push origin master), actualizar la ficha (qué se hizo y qué números quedaron)
   y copia .rbxl en backups/plinko-knight-AAAA-MM-DD.rbxl si cambió el mundo.
```

---

## Prompt 1 · Ficha y carpeta (no programa la mecánica)

Es tu prompt de arranque, con lo que aprendí mirando tu carpeta (Forja usa wally para ProfileStore, puerto propio de Rojo y una fila en la tabla de CLAUDE.md).

```
Juego nuevo: Plinko Knight (carpeta plinko-knight/, al lado de los otros juegos).
Leé GUIA-PARA-CLAUDE.md y las Reglas de plinko-knight/PLAN-Y-PROMPTS.md (ese archivo ya
está en la carpeta; no lo borres).

QUÉ QUIERO
Armá la ficha en ideas/plinko-knight.md (1 o 2 páginas) con la VERSIÓN MÍNIMA:
mi ataque es una bola que tiro desde arriba de un tablero de clavijas; cada clavija que toca
suma daño y el total le pega al monstruo de abajo. Entre peleas elijo 1 de 3 mejoras.
IMPORTANTE: nada de casino ni apuestas (Roblox no permite apuestas simuladas). Es un caballero
que pelea en una mazmorra. Abajo del tablero NO hay casilleros con multiplicadores.
Usá las secciones "Cómo lo ve el jugador", "Números de arranque", "Qué queda FUERA" y "Cómo
funciona por dentro" de PLAN-Y-PROMPTS.md como base; si cambiás algo, decime por qué.

CARPETA (todavía NO programes la mecánica)
- plinko-knight/default.project.json igual que el de forja-rapida (Shared, Server,
  ServerPackages, Client) pero con "name": "plinko-knight" y un servePort que no use ningún
  otro juego (revisá los otros default.project.json).
- plinko-knight/src/{client,server,shared}, con un Main.server.luau y un cliente vacíos que solo
  imprimen "Plinko Knight arrancó", y shared/Config.luau con los números de la ficha.
- wally.toml con ProfileStore (copiá el de forja-rapida), wally install, selene.toml y
  stylua.toml iguales a los de forja-rapida, carpeta pruebas/ vacía.
- Place nuevo: pedime que en Studio haga File → New → Baseplate y lo guarde como
  plinko-knight/PlinkoKnight.rbxl (decime cada botón). Si lo podés crear vos por MCP, mejor.
- Sumá la fila de Plinko Knight a la tabla "Varios juegos en esta carpeta" de CLAUDE.md y una
  línea como la de Forja (rojo serve plinko-knight, stylua/selene plinko-knight/src, números en
  plinko-knight/src/shared/Config.luau). No cambies nada más de CLAUDE.md.

CÓMO LO VIVE EL JUGADOR
1. Ve el tablero y el monstruo. Apunta con el dedo o el mouse y suelta.
2. La bola rebota (solo en el plano del tablero) y cada clavija muestra un número.
3. El monstruo recibe el total y contraataca. 6 peleas y un jefe.
4. Entre peleas elige 1 de 3 mejoras: bola de fuego, clavija que duplica, bola que se divide.
5. Si pierde, vuelve a empezar la mazmorra.

NÚMEROS
Los de la tabla "Números de arranque", anotados en Config.luau.

TÉCNICO
La física de la bola corre en el cliente con shared/Simulacion.luau; el servidor repite la
simulación y revisa que el daño sea razonable.

CÓMO SE VE
Prototipo en bloques grises. Anotá para después: mazmorra de piedra, clavijas doradas #F5C542,
números de daño amarillo flúor, monstruos como imágenes planas.

¿SE PAGA CON ROBUX?
No.

¿SE GUARDA?
Sí, mejor piso y bolas desbloqueadas, con ProfileStore.

PRUEBA QUE QUIERO VER
Que la ficha diga qué queda FUERA (mazos, reto diario, ranking, Robux) y que la carpeta nueva
abra en Studio sin romper los otros juegos: rojo serve plinko-knight conecta, Play imprime
"Plinko Knight arrancó" sin rojo, y rojo build de forja-rapida y mutant-lab sigue andando.

Mostrame la ficha para aprobarla antes de programar. Commit al terminar.
```

---

## Prompt 2 · Tablero, puntería y bola (sin daño todavía)

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha.
Etapa 2: tablero, puntería y bola. Todavía sin daño ni monstruos.

1) shared/Simulacion.luau, lógica pura sin Instances: recibe el tablero (lista de clavijas con
   posición 2D, radio y tipo), el ángulo de tiro, la bola y las mejoras, y devuelve el
   recorrido (posiciones cada paso) y la lista ordenada de toques (qué clavija, en qué paso).
   Paso fijo 1/120 s, gravedad, rebote con restitución (arrancá con 0,65 y un poquito de
   fricción), paredes a los costados, la bola termina al cruzar el borde de abajo.
   Anti-trabas: si en 2 s casi no baja, un empujón chico hacia abajo; tope 15 s por tiro.
   Determinista: mismo tablero + ángulo + semilla = mismo resultado. Nada de math.random
   suelto: Random.new(semilla).
2) shared/Tablero.luau: genera el tablero de la ficha (7 × 8 alternado) como datos.
3) pruebas/simulacion.luau con lune: 200 tiros a ángulos distintos, ninguno se traba ni sale
   por los costados, el mismo tiro da siempre lo mismo, y cuántas clavijas toca en promedio
   (tiene que dar 10 a 18; si no, ajustá separación o rebote y anotalo en Config).
4) Cliente: arma el tablero en Workspace SOLO para ese jugador (no replicado), con partes
   grises ancladas sin colisión, frente a una cámara fija (Scriptable, de frente, FOV bajo para
   que se vea casi plano). Arriba el lanzador (un bloque), abajo un bloque gris donde irá el
   monstruo. Que entre entero en celular horizontal y en compu.
5) Puntería: mouse o dedo mueve el ángulo (limitado a un abanico hacia abajo), línea de puntos
   solo del primer tramo, soltar dispara. No se puede tirar otra bola hasta que termine.
   Usá el Input Action System si ya lo usan los otros juegos; si no, UserInputService.
6) La bola (esfera blanca) sigue el recorrido de la simulación, interpolada para que se vea
   suave a cualquier FPS. Cada clavija tocada brilla 0,15 s.
Probalo en Play: 10 tiros en compu y 10 en el emulador de celular, captura a mitad de un
rebote. Decime el promedio de clavijas tocadas. Commit "tablero y bola".
```

---

## Prompt 3 · Daño, números y revisión del servidor

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha.
Etapa 3: daño por clavija, números en pantalla y el servidor que revisa.

1) Simulacion devuelve también el daño: Config.DanioPorClavija por toque, cada clavija una
   sola vez por tiro (la segunda vez rebota pero no suma ni brilla).
2) Números: cada toque hace saltar "+2" sobre la clavija (BillboardGui o SurfaceGui, en
   amarillo de prueba), que sube y se desvanece en 0,5 s. Un TOTAL grande entre el tablero y el
   monstruo que va subiendo con cada toque, con un pequeño "pop" de tamaño.
3) Servidor (server/Partida.luau y server/Tiros.luau):
   - Lleva la partida de cada jugador: piso, vida, mejoras, número de tiro, semilla del tiro.
   - Remoto PedirTiro: el servidor responde con la semilla y el número de tiro.
   - Remoto Tirar(numeroTiro, angulo, danioVisto): validá tipos, número finito, ángulo dentro
     del abanico, que sea el tiro que corresponde y frecuencia (no más de 1 cada
     Config.TiempoMinimoEntreTiros). Corré la misma Simulacion con ese ángulo, la semilla y
     las mejoras que el SERVIDOR sabe que tiene. Si danioVisto difiere más del 5 %, usá el del
     servidor y anotalo en la consola de Studio (no castigar al jugador). Tope de daño por tiro
     en Config por si algo sale mal.
   - Devuelve el daño final al cliente.
4) Prueba con lune: el daño de la simulación coincide en cliente y servidor (es el mismo
   módulo), y un danioVisto falso de 9999 termina usando el del servidor.
Probalo en Play: 5 tiros, captura con varios "+2" en el aire, y probá desde la barra de comandos
mandar un tiro con daño falso: el servidor lo corrige. Commit "daño y revisión".
```

---

## Prompt 4 · Monstruos, contraataque y la mazmorra

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha.
Etapa 4: monstruos, peleas por turnos, 6 peleas + jefe, perder y volver a empezar.

1) Config.Monstruos: lista de 7 (6 + jefe) con nombre, vida y golpe de la tabla de la ficha.
   Nombres de prueba: Rata de Cloaca, Slime Verde, Murciélago, Esqueleto, Goblin con Lanza,
   Gólem de Piedra y el jefe Rey de los Huesos.
2) Monstruo en graybox: un cartel plano (una Part fina) con un rectángulo de color distinto
   para cada uno y su nombre, abajo del tablero. Barra de vida arriba del cartel.
3) Turno: el jugador tira → el total vuela hacia el monstruo (una bolita de luz del TOTAL al
   cartel, 0,3 s) → el monstruo se sacude y baja su barra → si sigue vivo, contraataca: el
   cartel se agranda y vuelve, la pantalla tiembla apenas y baja la vida del caballero.
   Todo lo decide el servidor; el cliente solo muestra.
4) Caballero: vida en Config.VidaCaballero, se cura Config.CuraEntrePeleas al ganar.
   En graybox es un bloque al lado del lanzador.
5) Mazmorra: al ganar, "¡Piso 2!" y pasa a la siguiente pelea (por ahora sin mejoras, eso es la
   etapa 5). Al ganarle al jefe: pantalla simple "¡Ganaste la mazmorra!" y botón volver.
6) Perder: pantalla "Caíste en el piso N" con botón grande "Volver a bajar" que arranca una
   mazmorra nueva al toque (menos de 1 s entre el toque y estar jugando).
7) Comando de prueba solo en Studio para saltar al piso que quiera (para probar el jefe).
Probalo en Play: una mazmorra entera con el comando, perder a propósito y volver, ganarle al
jefe. Decime cuántos tiros tardó cada pelea y si los números de la ficha andan o hay que
cambiarlos (proponé, no cambies la ficha sin decirme). Commit "monstruos y mazmorra".
```

---

## Prompt 5 · Mejoras: elegí 1 de 3 (y después lo probás vos)

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha.
Etapa 5: entre peleas el jugador elige 1 de 3 mejoras.

1) Config.Mejoras con las 3 de la ficha y cómo mejoran al repetirlas:
   - Bola de fuego: +1 daño por clavija y quemadura (daño por turno al monstruo, X turnos).
   - Clavija que duplica: N clavijas del tablero se vuelven rojas; al tocar una, el total del
     tiro hasta ese momento ×2 (cada una una vez por tiro). Las elige el servidor con la
     semilla de la pelea y no se mueven durante la pelea.
   - Bola que se divide: en el toque N la bola se parte en 2 (la segunda sale con un ángulo
     un poco distinto, sacado de la semilla). Las dos suman; el tiro termina cuando caen todas.
2) Todo pasa dentro de Simulacion (así el servidor lo repite igual). Agregá pruebas con lune
   para cada mejora y para las 3 juntas (que no explote: tope de bolas y de daño en Config).
3) Pantalla de mejoras al ganar una pelea: 3 cartas grandes una al lado de la otra (en graybox:
   rectángulo, nombre, una frase de qué hace y si es "Nivel 2"). El servidor elige qué 3
   aparecen (cuando hay solo 3 mejoras, siempre las 3) y valida que la elegida sea una de esas.
4) Abajo de la pantalla de pelea, una fila con las mejoras que tenés (con su nivel).
5) Tirar con fuego: la bola se pone naranja. Clavija que duplica: el TOTAL hace "×2" grande.
   Bola dividida: se ven las dos. Esto es graybox: solo color y texto, el lindo es la etapa 10.
Probalo en Play: una mazmorra entera eligiendo cada mejora, captura de un tiro con las tres.
Después frená: es el PUNTO DE CONTROL del prototipo jugable. Mostrame 1 captura y un resumen de
3 líneas, y decime: "Jugalo 5 minutos: si perdés en la pelea 4 y querés empezar de nuevo
enseguida, seguimos". Commit "mejoras 1 de 3".
```

**Ahora te toca a vos:** jugalo 5 minutos en gris. Contale a Claude qué te aburrió, qué fue fácil o difícil, y qué mejora nunca elegiste. Con eso ajusta los números (pegá: "Ajustá los números: …").

---

## Prompt 6 · Guardado con ProfileStore

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la
sección 3 de GUIA-PARA-CLAUDE.md (guardado).
Etapa 6: guardar mejor piso y bolas desbloqueadas.

1) server/Guardado.luau con ProfileStore (ServerPackages), mirá cómo lo hizo
   forja-rapida/src/server/Guardado.luau y copiá la forma (no el código del otro juego tal
   cual). Datos: VERSION = 1, MejorPiso, BolasDesbloqueadas {Hierro = true}, BolaElegida,
   PartidasJugadas, JefesVencidos. Bloqueo de sesión, autoguardado, BindToClose en paralelo y
   ServerRestartScheduled. Si falla la carga, avisarle al jugador "No pudimos cargar tu
   progreso, volvé a entrar" y no dejarlo jugar sin guardar. Un error de uno no apaga a los
   demás.
2) Desbloqueos de Config: Bola de fuego al llegar al piso 4, Bola partida al ganarle al jefe.
   Al desbloquear: aviso grande "¡Nueva bola: Fuego!".
3) Antes de bajar a la mazmorra, el jugador elige con qué bola empieza entre las desbloqueadas
   (la bola elegida arranca con esa mejora en nivel 1). Validado en el servidor.
4) La partida en curso NO se guarda: si sale a la mitad, la próxima vez empieza de cero.
Probalo: Play, llegar al piso 4 con el comando, salir, volver a entrar y que siga el mejor piso
y la bola de fuego. Local Server con 2 jugadores: cada uno lo suyo. Commit "guardado".
```

---

## Prompt 7 · Pantallas: lo que ve el jugador

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha.
Etapa 7: todas las pantallas ordenadas, todavía en graybox pero bien acomodadas. Seguí el
dibujo de "Cómo lo ve el jugador" de PLAN-Y-PROMPTS.md.

Pantallas:
1) Inicio: título "Plinko Knight", botón grande "Bajar a la mazmorra", tu mejor piso, elegir
   bola (las bloqueadas se ven con candado y dicen cómo se consiguen), botón Ajustes.
2) Pelea: vida del caballero arriba a la izquierda, "Pelea 3 de 7" arriba al centro, Ajustes
   arriba a la derecha, TOTAL entre tablero y monstruo, barra de vida del monstruo, fila de
   mejoras abajo. Nada tapa el tablero.
3) Mejoras: las 3 cartas, se elige con un toque, sin botón de confirmar.
4) Derrota y Victoria: piso alcanzado, mejor piso, bola desbloqueada si hubo, botón grande
   "Volver a bajar".
5) Ajustes: sonido sí/no, música sí/no, efectos reducidos (menos temblor y partículas).
Reglas: un solo módulo de estilo (client/Estilo.luau) con colores, fuentes y tamaños, así el
arte de la etapa 9 se cambia en un solo lugar. Todo con UIScale/escala para que se vea igual
en compu, tablet y celular; nada de texto chico; botones de 44 px o más. Mientras la bola
rebota no hay que tocar nada más. Escondé el chat y la lista de jugadores durante la pelea
solo si no rompe nada de Roblox (el botón del menú de Roblox siempre se ve).
Probalo: capturas de las 5 pantallas en compu y en celular horizontal. Una partida entera solo
con el dedo en el emulador. Commit "pantallas".
```

---

## Prompt 8 · Elegir el estilo visual (punto de control)

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la
sección "Estilo visual" de CLAUDE.md.
Etapa 8: 3 propuestas de estilo para la mazmorra, y yo elijo.

Las 3 tienen que respetar lo que ya decidí: mazmorra de piedra, clavijas doradas #F5C542,
números de daño amarillo flúor, monstruos como imágenes planas. Lo que cambia entre ellas:
A) "Mazmorra de juguete": piedra en bloques grandes de colores cálidos, antorchas con llama
   caricatura, luz cálida y sombras suaves, muy saturado (lo más parecido a Forja).
B) "Cripta azul": piedra gris azulada, velas y cristales que brillan cian, niebla baja, el
   dorado y el amarillo flúor resaltan mucho sobre fondo frío.
C) "Libro de cuentos": paredes con textura de ilustración pintada (una imagen de fondo plana),
   tablero de madera oscura con marco de hierro, todo con borde negro grueso tipo dibujo.
Para cada una: paleta de 5 colores en hex, materiales de Roblox, Lighting y Atmosphere, y una
muestra chica en Studio (el tablero, 2 antorchas, la pared de atrás y un cartel de monstruo
gris). Usá materiales de Roblox y luces antes que modelos. Captura de cada una con la cámara de
la pelea, en compu y en celular. Mostrame las 3 capturas y preguntá cuál. Guardá la elegida en
la ficha como "Guía de estilo". Commit "muestras de estilo".
```

---

## Prompt 9 · Arte final

Antes de este prompt, hacé las imágenes con Gemini (ver la sección **Prompts para Gemini** más abajo) y guardalas en `plinko-knight/arte/gemini/` con el nombre que dice cada una.

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la "Guía de estilo"
de la ficha. Etapa 9: pasar el juego de gris al estilo elegido.

1) Imágenes de Gemini en plinko-knight/arte/gemini/: abrí cada una y revisala. Sacá el fondo
   verde o magenta con un script de Python (chroma key con borde suave, sin halo), recortá al
   contenido, dejalas en 512 × 512 (monstruos y jefe 1024) y guardalas en arte/listas/.
   Si alguna tiene texto, marcas raras o no sigue la frase de estilo, decime cuál rehacer.
2) Subilas a Roblox (por MCP si se puede; si no, decime cada botón) y anotá los IDs en
   Config.Assets.
3) Mundo con el estilo: pared y piso de la mazmorra, antorchas a los costados del tablero,
   marco del tablero, clavijas doradas #F5C542 (Neon apenas, o metal brillante: probá las dos y
   mostrame), clavija que duplica en rojo rubí, números en amarillo flúor con borde oscuro,
   monstruos como imagen plana en su cartel (una SurfaceGui/Decal, sin esqueleto), el caballero
   como imagen plana al lado del lanzador. Fondo de mazmorra de Gemini detrás de todo.
4) Cartas de mejora, botones y barras con el estilo (íconos de Gemini en las cartas).
5) Todo lo que no se toca: CanCollide/CanTouch/CanQuery = false. Pocas luces con sombra.
Probalo: captura de una pelea normal, del jefe y de la pantalla de mejoras, en compu y en
celular, y medí los FPS en el emulador de celular (30 o más). Copia .rbxl en backups/.
Commit "arte final".
```

---

## Prompt 10 · Sensación y sonido (que pegue)

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la ficha. Si está
la skill game-feel, usala como apoyo.
Etapa 10: que cada tiro se sienta bien. Todo con Config.Feel para poder ajustarlo.

1) Clavijas: al tocarla se aplasta un poco y vuelve (0,12 s), destello blanco y 3 a 5 chispas
   doradas. Sonido "tink" corto con tono que SUBE con cada toque del mismo tiro (PlaybackSpeed
   de 1,0 a 1,8), como una escala. Un solo sample, según la regla de audio de CLAUDE.md.
2) Números: "+2" con rebote de tamaño; cuando el total pasa de 50, 100 y 200, el TOTAL cambia
   de tamaño y de brillo, y un sonido distinto. "×2" de la clavija roja: congelá la bola 0,08 s
   (hit-stop), número enorme y sacudida chica.
3) Golpe al monstruo: el total vuela, impacto con flash blanco en el cartel, el cartel se
   inclina y vuelve, número de daño grande que cae. Si lo mata: el cartel se rompe en pedazos
   planos y caen. Jefe: entrada con la pantalla oscura y su nombre.
4) Contraataque: el cartel se acerca a la cámara, temblor corto, borde rojo en la pantalla.
5) Mejoras: las cartas entran una por una con un "whoosh"; al elegir, se agranda y vuela a la
   fila de mejoras.
6) Música: una melodía inventada o de dominio público, tranquila en peleas y más intensa con el
   jefe (con el mismo sample o sonidos gratuitos de Roblox sin derechos). Marcá cada sonido con
   -- SONIDO: y los IDs en Config.Sonidos.
7) "Efectos reducidos" apaga temblores, hit-stop y la mitad de las partículas.
Probalo: grabá o capturá un tiro bueno de principio a fin (es el clip para redes) y mirá que en
celular siga a 30 FPS o más. Commit "sensación y sonido".
```

---

## Prompt 11 · Antes de publicar

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la
sección 10 de GUIA-PARA-CLAUDE.md (checklist antes de publicar).
Etapa 11: dejarlo listo para que yo lo publique.

1) Primer minuto: la primera vez que entra, una mano animada muestra "arrastrá y soltá" y la
   primera pelea es fácil (monstruo de práctica con poca vida, que no cuenta como piso).
   En menos de 15 segundos desde que carga, el jugador ya tiró su primera bola.
2) Analítica con AnalyticsService: embudo de los primeros pasos (entró, primer tiro, ganó
   pelea 1, eligió mejora, piso 3, piso 5, jefe, volvió a bajar), en qué piso se pierde más y
   qué mejora se elige más.
3) Recorré el checklist de la sección 10 de la GUIA y decime cada punto: hecho, no aplica
   (por ejemplo compras) o falta.
4) Local Server con 3 jugadores: cada uno juega su mazmorra sin trabarse los otros.
5) Ícono 512 × 512 y 3 miniaturas: hacé capturas lindas del juego (un tiro con muchos números,
   el jefe, la pantalla de mejoras) y armá las miniaturas sin texto chico. Si querés usar
   Gemini para el ícono, decime el prompt y lo hago yo.
6) Revisá textos y nombres: que no aparezca nada de casino ni apuestas en el juego, en la
   descripción ni en las miniaturas. Escribime una descripción corta para la página del juego.
NO publiques: eso lo hago yo. Decime exactamente qué botones tocar para publicarlo para mayores
de 13 o de 16 (el cuestionario de madurez lo completo yo). Commit "listo para publicar".
```

---

## Herramientas de arte y sonido

Juani ya tiene **ForgeGUI** (suscripción paga, 25/10/2026). Es la herramienta principal; **Gemini** queda de reserva, con los prompts de `plinko-knight/PLAN-Y-PROMPTS.md`.

- **Etapa 9 (arte final):** monstruos, caballero, íconos de mejoras y de bolas, y fondo de mazmorra.
  - Primero se crea un **estilo de ForgeGUI** con la guía de estilo de la ficha (la que se elija en la etapa 8) y se usa en **todas** las imágenes, así salen parecidas entre sí.
  - El fondo se saca con color key (un color de fondo liso que después se borra).
  - Se sube a Roblox con la conexión de ForgeGUI, y el ID de cada asset va en `Config.luau`.
- **Etapa 10 (sensación y sonido):** efectos de sonido y música hechos con ForgeGUI y subidos a Roblox. Siguen las reglas de Audio de `CLAUDE.md`: nada con derechos de autor y cada punto marcado con `-- SONIDO:`.
- **Antes de usarlo:** confirmar que lo que se genera con el plan pago es privado y se puede usar comercialmente. Si no, se frena y se le avisa a Juani.
- **Cada vez que una etapa necesite arte o sonido con IA, avisarle a Juani antes de generar** (qué se va a hacer, con qué herramienta y cuántos créditos gasta, más o menos).

## Prompts para Gemini (arte de la etapa 9)

Usalos en Gemini (Nano Banana). Pegá **la frase de estilo y después el prompt**. Guardá cada imagen en `plinko-knight/arte/gemini/` con el nombre en negrita. Si en la etapa 8 elegiste B o C, cambiá la frase de estilo por la que Claude te anote en la ficha.

**Frase de estilo (va siempre primero):**
> Cute chunky cartoon game art for a kids' dungeon adventure, bold clean shapes, thick dark outline, soft cel shading, saturated warm colors, gold accents #F5C542, front view, centered, no text, no letters, no numbers, no logo, isolated on a flat pure green #00FF00 background.

### Monstruos (imágenes planas, de frente, cuerpo entero)
1. **monstruo-1-rata.png** · A giant sewer rat monster standing on two legs, chubby, big front teeth, torn ear, holding a small wooden club, mischievous but not scary.
2. **monstruo-2-slime.png** · A round green slime monster with a jelly body, little bubbles inside, two big shiny eyes and a cheeky grin, a tiny rusty helmet sinking into its head.
3. **monstruo-3-murcielago.png** · A purple cave bat monster with wide wings open, big ears, small fangs, glowing yellow eyes, flying pose.
4. **monstruo-4-esqueleto.png** · A friendly-looking skeleton warrior with a cracked round shield and a short sword, bones slightly yellowed, one eye socket glowing blue, cartoon proportions with big skull.
5. **monstruo-5-goblin.png** · A green goblin with a long spear, leather armor with patches, big pointy ears, sly smile, standing in an attack pose.
6. **monstruo-6-golem.png** · A stone golem made of big blocky grey rocks with moss on top, glowing orange cracks, heavy fists, wide sturdy stance.
7. **jefe-rey-de-los-huesos.png** · Boss monster: a huge skeleton king with a golden crown #F5C542, a purple tattered cape, a big bone scepter, glowing purple eyes, imposing pose, larger and more detailed than normal monsters.

### Caballero
8. **caballero.png** · A small brave knight hero seen from the front, round helmet with a red plume, silver armor with gold trims, holding a glowing metal ball in one raised hand ready to throw, determined smile visible through the visor.

### Íconos de mejoras (para las cartas)
9. **mejora-fuego.png** · Game icon: a round metal ball wrapped in bright orange and yellow flames, small sparks around.
10. **mejora-duplica.png** · Game icon: a shiny ruby red round peg glowing, with two small golden light rays crossing behind it like an X, energy sparkles.
11. **mejora-divide.png** · Game icon: one metal ball splitting into two balls with a white light crack between them, motion lines.

### Bolas (para elegir antes de bajar)
12. **bola-hierro.png** · Game icon: a simple polished iron ball with a soft highlight, small dents.
13. **bola-fuego.png** · Game icon: a dark iron ball with glowing orange lava cracks and a small flame on top.
14. **bola-partida.png** · Game icon: an iron ball made of two halves held together by a glowing cyan seam.

### Fondo de la mazmorra (este va SIN fondo verde)
15. **fondo-mazmorra.png** · Cute chunky cartoon game background for a kids' dungeon adventure, front view of a stone dungeon wall made of big rounded grey-brown blocks, two lit torches with warm cartoon flames, some moss and chains, a dark arched doorway in the center, soft warm light, saturated colors, empty center area, no characters, no text, wide 16:9.

**Consejos:** pedí 4 versiones y quedate con la que tenga el contorno más limpio. Si sale texto o números, agregá al final "absolutely no text". Si el verde se mete en el monstruo (por ejemplo el slime), usá fondo magenta #FF00FF en ese.

---

## Después de publicar (ideas que quedaron FUERA)

En este orden, solo si la gente juega y vuelve: más mazmorras con monstruos nuevos, más mejoras (bola de hielo que congela un turno, clavija que cura, bola rebotona), reto diario con la misma semilla para todos, ranking de mejor piso, aspectos de bola y de tablero por Robux. Cada una se pide con el prompt modelo de la GUIA, sección 9.
