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
| 10b | Pantallas pixel (27/10) | 3 columnas tipo Balatro, tienda aparte, HUD de ForgeGUI | Capturas |
| 10c | Sala neón (27/10) | Damero, paneles, vitrina de reliquias, puerta blindada | Capturas |
| 11 | Antes de publicar | Tutorial del primer minuto, analítica, checklist | **Publicás vos** |

> **Cambio del 25/10/2026:** después de la prueba de 5 minutos, Juani pidió hacerlo más roguelike, estilo Balatro. La ficha (`ideas/plinko-knight.md`, sección "Rediseño roguelike") manda sobre este plan: la etapa 5 sigue con los pasos 5a a 5d (Fuerza × Multi, tienda, reliquias, zonas y jefes con maña) antes del guardado. Los prompts 6 a 11 de abajo se adaptan a eso.

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

**ForgeGUI está habilitada** para este juego: Juani la tiene paga, con **350.000 créditos** (25/10/2026). Es la herramienta principal; **Gemini** queda de reserva, con los prompts de `plinko-knight/PLAN-Y-PROMPTS.md`.

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

---

> **Agregado el 26/10/2026 (desde el proyecto de Claude):** Juani aprobó la sala arcade 3D y pidió que **todos los modelos los haga una IA**. Esta sección se suma al plan; lo que ya está hecho y la ficha mandan sobre lo de arriba.

## APROBADO (26/10): jugar dentro de una máquina arcade, en una sala 3D

Idea de Juani: el tablero se juega dentro de una máquina arcade, como en *CloverPit*. La tienda está aparte y te movés por una sala.

**Cómo quedaría:** una **sala de arcade retro de noche** (no un casino). Caminás con tu avatar entre máquinas con luces de neón, te acercás a la máquina "Plinko Knight" y tocás E (o el botón en celular). La cámara se mete despacio hasta la pantalla, como en CloverPit, y ahí se juega la mazmorra igual que en el plan. **Afuera es el arcade; adentro de la pantalla sigue la mazmorra del caballero.** Al terminar la partida, la cámara se aleja y volvés a caminar.

- **La sala:** una fila de máquinas iguales, una por jugador (hasta 8 por servidor), un mostrador aparte que es la **tienda de la sala** (elegir bola, ver bolas y reliquias desbloqueadas y, después, aspectos; la tienda de oro de cada partida sigue dentro de la máquina para no cortar el ritmo), una pared de récords con el mejor piso de cada uno y luces de neón en carteles que dicen "ARCADE" y "PLINKO KNIGHT".
- **Lo que NO puede haber (regla de apuestas simuladas de Roblox):** tragamonedas, ruletas, fichas, mesas de cartas o dados, carteles de "JACKPOT", premios al azar ni mostrador de premios sorpresa. Si se ve como un casino, Roblox lo puede bajar. Las máquinas de fondo son de juegos de habilidad (naves, autos, laberintos) y están apagadas o en modo demo.
- **Cuándo se hace:** es la **etapa 7b** y va **ahora, antes de la etapa 10** (sensación), porque cambia la cámara y cómo empieza el juego. El tablero, Fuerza × Multi, la tienda de oro, las reliquias y los monstruos no cambian: todo eso sigue pasando dentro de la pantalla de la máquina.
- **Arte (cambiado el 26/10):** **todos los modelos los hace una IA** (ForgeGUI, ya pago). Claude solo arma la sala en gris, escribe los prompts, limpia los modelos en Blender y los coloca. Ver etapa 7b más abajo.

### Referencias y qué tomar de cada una

| Referencia | Qué tomar | Qué NO tomar |
|---|---|---|
| **CloverPit** | Estar sentado frente a UNA máquina; la cámara que se acerca a la pantalla; la máquina como un mueble físico con luces que parpadean; la sala oscura alrededor | Tragamonedas, monedas, deuda, todo lo de apostar |
| **FNAF: Security Breach** (el Pizzaplex, el arcade) | Neón rosa, violeta y cian; alfombra con dibujitos de confeti; pisos brillantes; filas de máquinas arcade con carteles que brillan | Los animatrónicos que asustan y los nombres o personajes de FNAF |
| **Salones arcade reales de los 80 y 90** | Muebles de máquina con dibujo a los costados, el cartel de arriba iluminado, palanca y botones grandes | — |
| **Pantallas de tubo (CRT)** | Líneas horizontales y el borde curvo de la pantalla de la máquina, para que el tablero se vea "adentro" | — |
| **Peglin** | Lo que pasa adentro de la pantalla: el tablero, los monstruos y las mejoras (igual que antes) | — |

**Búsquedas útiles:** "CloverPit gameplay", "FNAF Security Breach Fazer Blast arcade", "Pizzaplex arcade screenshot", "retro arcade room night neon", "80s arcade carpet pattern", "arcade cabinet side art", "CRT screen scanlines game".

**Paleta propuesta para la sala:** paredes azul noche `#14112B`, neón rosa `#FF3EA5`, neón cian `#2DE2E6`, violeta `#7A2CF5`. Se mantienen las clavijas doradas `#F5C542` y los números amarillo flúor `#E6FF00`, que resaltan mucho sobre esa sala oscura.

**Un tema aparte:** "Plinko" es una marca registrada (el juego del programa *The Price Is Right*). Para jugar en prueba no pasa nada, pero conviene elegir otro nombre antes de publicar.

### Lo que salió de las 15 capturas de Juani (25/10, en plinko-knight/arte/referencias/)

**Sala (de FNAF, 8 capturas):** casi negro `#0D0A14`, neón magenta `#FF3FD0`, cian `#3FE8FF`, amarillo `#FFE14A` y verde `#7CFF6B`. Piso de damero blanco y negro que refleja como un espejo (`Material = Glass` o `SmoothPlastic` con `Reflectance`) y techos con damero. La luz sale casi toda de los carteles: oscuridad alrededor y neón que marca el camino. Una máquina grande en el centro de la sala como punto de atención.
**Máquina y tienda (de CloverPit, 7 capturas):** primera persona de frente a la máquina, el gabinete como mueble físico sobre una mesa con objetos, un contorno amarillo `#FFE600` en lo que se puede tocar, el HUD en cajas negras con letra blanca en mayúsculas y títulos naranja `#FF8A1E`. Tienda con cajitas de vidrio y un objeto 3D adentro, y cartas negras con título, ícono y descripción (sirve también para las 3 cartas de mejora).
**Queda afuera:** rodillos, palanca, deuda, interés, cajero, cartel de porcentajes, el "666", la sangre, el cartel "PRIZES", los animatrónicos y cualquier nombre o letrero de FNAF.
Esta paleta reemplaza a la de arriba (aprobada el 26/10).

---

## Etapa 7b · Sala arcade 3D con modelos hechos por IA (aprobada el 26/10)

> **Cambio del 26/10 (Juani, después de 7b-3):** ForgeGUI **solo hace el HUD y los íconos**; **los modelos los hace Claude** (con partes de Roblox por código o en Blender). La **sala tiene que ser más chica**. La estética principal es **mezclar CloverPit con algo futurista como FNAF Security Breach**. La pantalla de juego (el plinko) "es muy fea": se rehace con esa estética. Los 13 modelos de IA de 7b-2/7b-3 quedan guardados pero no se usan.


> **Cambio del 26/10 (Juani):** la sala es **en solitario**, servidores de 1 jugador. Una sola máquina Plinko Knight (M1) y máquinas de fondo; la pared de récords muestra tus récords. Donde abajo dice "8 máquinas", "una por jugador" o "2 jugadores", ya no aplica.
>
> **Cambio del 26/10 (Juani):** el caballero sale del juego; el personaje es el avatar del jugador. M14 (figura del caballero) se reemplaza por una estatua de tu avatar hecha por código, y M1 va sin dibujo de caballero.

**Cómo se hace:** primero la sala en bloques grises para probar que caminar, sentarse y jugar se sienta bien (7b-1). Después **todos los modelos los hace una IA**: ForgeGUI, con un mismo estilo para todos (7b-2). Claude no modela a mano: escribe los prompts, revisa, y en Blender solo limpia, achica y exporta (7b-3). Va **antes de la etapa 10**. Dentro de la pantalla se mantiene la Cripta azul; la sala usa la paleta de tus capturas (combinan: las dos son oscuras con cian).

**Herramientas, en este orden:**
1. **ForgeGUI** (ya lo tenés pago): imagen de concepto → modelo 3D con texturas → lo sube a Roblox. Guarda el estilo "Plinko Knight - Sala arcade" para que todos los modelos salgan parecidos.
2. **Reserva**, si ForgeGUI no da buen resultado en algún modelo: imagen en Gemini → Meshy (imagen a 3D) → limpieza en Blender.
3. **Claude en Blender**: solo limpiar, bajar triángulos, centrar el pivote, poner escala y exportar. No esculpe.

**Regla de ForgeGUI:** Claude te avisa antes de cada tanda de modelos, te dice cuántos va a generar, te muestra la imagen de concepto y espera tu "dale" antes de pasarla a 3D. Si ForgeGUI dice que no quedan créditos, frena y te avisa.

### Lista de modelos (los que hace la IA)

| # | Archivo | Qué es | Triángulos máx. |
|---|---|---|---|
| M1 | `maquina-principal` | **La máquina Plinko Knight**: gabinete arcade alto, pantalla grande vertical (ahí va el tablero), cartel arriba sin texto, botones grandes, costados con dibujo de caballero y mazmorra | 15.000 |
| M2 | `maquina-fondo-naves` | Máquina de fondo, juego de naves (apagada o en demo) | 6.000 |
| M3 | `maquina-fondo-autos` | Máquina de fondo, juego de autos con volante | 6.000 |
| M4 | `maquina-fondo-laberinto` | Máquina de fondo, juego de laberinto, más baja | 6.000 |
| M5 | `banqueta` | Banqueta redonda de arcade con tapizado | 1.500 |
| M6 | `mesa-objetos` | Mesita al lado de la máquina con objetos (vaso de gaseosa, caja de pizza, joystick viejo, muñequito de caballero), al estilo CloverPit pero sin nada feo | 6.000 |
| M7 | `mostrador-tienda` | Mostrador de la tienda con vidriera, luces de neón en el borde | 8.000 |
| M8 | `cajita-vidrio` | Cajita de vidrio con base de metal, donde se exhibe cada bola en la tienda | 1.500 |
| M9 | `pared-records` | Marco grande con luces para la pared de récords (los nombres los pone el juego) | 3.000 |
| M10 | `molinete-entrada` | Molinete de entrada de metal | 3.000 |
| M11 | `maceta-planta` | Maceta con planta tropical | 3.000 |
| M12 | `tacho-basura` | Tacho de basura de shopping | 1.500 |
| M13 | `poste-neon` | Columna con anillo de neón en la base (como la de tu captura 181825) | 2.000 |
| M14 | `figura-caballero` | Estatua grande del caballero en el centro de la sala (lo que te llama la atención al entrar) | 15.000 |

**Lo que NO hace la IA (lo arma Claude con partes de Roblox, porque sale mejor y pesa menos):** paredes, piso de damero que refleja, techo, los tubos de neón y los carteles con texto ("ARCADE", "PLINKO KNIGHT", "TIENDA", "RÉCORDS": la IA no escribe bien letras). La alfombra con confeti es una textura (ForgeGUI, ruta de textura).

**Frase de estilo para los modelos 3D (va en el estilo de ForgeGUI y en cada prompt):**
> Stylized game-ready 3D asset for a kids' Roblox game set in a retro arcade at night. Chunky, slightly toy-like proportions, clean readable shapes, simple flat colors with a light low-resolution PS1-style texture. Dark navy and black body #14112B / #0D0A14, glowing neon trims in magenta #FF3FD0 and cyan #3FE8FF, small yellow #FFE14A accents. Single object, centered, front three-quarter view, no text, no letters, no logos, no casino or gambling elements, no blood.

### Prompt 7b-1 · Sala en gris y sentarse en la máquina

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la sección
"APROBADO (26/10): jugar dentro de una máquina arcade" con "Lo que salió de las 15 capturas".
Mirá las capturas de plinko-knight/arte/referencias/ (las 8 de FNAF y las 7 de CloverPit) y
escribime 8 observaciones antes de empezar. Etapa 7b-1: la sala en bloques grises.

1) Sala de unos 60 × 40 studs, generada por código (server/GeneradorSala.luau) para que viva en
   git: entrada con molinete, estatua del caballero al centro, una fila de 8 máquinas Plinko
   Knight (una por jugador), 3 máquinas de fondo, mostrador de tienda en un costado, pared de
   récords enfrente. Todo con bloques grises y partes con tags (Maquina, Tienda, Records).
2) Al entrar, cada jugador tiene asignada una máquina libre (atributo Dueno). Se acerca, ve
   "E: jugar" (en celular un botón) y al tocarlo: se sienta en la banqueta, la cámara pasa a
   Scriptable y se acerca en 0,8 s hasta quedar de frente a la pantalla, en primera persona,
   como en CloverPit. Todo lo que ya existe (tablero, panel FUERZA × MULTI, monstruo, tienda de
   oro, cofre, derrota y victoria) se juega dentro de esa pantalla: mismo código, ahora ubicado
   en la pantalla de su máquina y solo para ese jugador. Las 3 columnas tienen que entrar en la
   pantalla de la máquina; si no entran, proponeme cómo antes de achicar nada.
3) Al terminar o con "Salir", la cámara se aleja y vuelve a caminar.
4) Mostrador de la sala: acercarse abre la parte de "elegir bola" de la pantalla de Inicio y lo
   desbloqueado (bolas y reliquias), con el estilo CloverPit: cajitas, cartas negras con título
   naranja, borde amarillo en lo elegido. La bola elegida es con la que arrancás en tu máquina.
   La tienda de oro de la partida NO se mueve: sigue dentro de la pantalla de la máquina.
5) Pared de récords: el mejor piso de los jugadores del servidor (no es un ranking global).
6) Las máquinas de fondo no se juegan: muestran una pantalla de demo con colores que cambian.
7) Nada de casino (Reglas, punto 5). Ni tragamonedas, ni ruletas, ni fichas, ni "jackpot".
Probalo en Play y en Local Server con 2 jugadores (cada uno en su máquina sin ver la del otro).
Capturas: entrar a la sala, sentarse, jugando, tienda. Compu y celular. Commit "sala en gris".
```

### Prompt 7b-2 · Modelos hechos por IA con ForgeGUI

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la sección "Etapa 7b"
(lista de modelos M1 a M14 y la frase de estilo). Etapa 7b-2: que la IA haga los modelos.

1) Revisá que tengas las herramientas de ForgeGUI. Si no aparecen, frená y decime (puedo
   activarlas o los hacemos desde el chat del proyecto de Claude).
2) Creá en ForgeGUI el estilo "Plinko Knight - Sala arcade" (aparte del de Cripta azul) con la frase de estilo y 2 a 4 de mis
   capturas de referencia como imágenes de estilo (las de neón y damero de FNAF y la máquina de
   CloverPit). Es gratis.
3) AVISAME antes de gastar créditos: decime cuántos modelos vas a hacer en esta tanda.
   Empezá solo con M1 (la máquina principal): primero una imagen de concepto con ese estilo,
   mostrámela, y con mi "dale" pasala a 3D (quality high, con la imagen de concepto como
   referencia). No publiques a Roblox todavía: bajá el .glb a plinko-knight/modelos/ia/.
4) Con M1 aprobado, hacé el resto en 2 tandas (M2-M8 y M9-M14), igual: conceptos primero, los
   mostrás todos juntos en una imagen, yo digo cuáles van, y después 3D.
5) Para cada modelo anotá en plinko-knight/arte/prompts.md el prompt exacto, el id de ForgeGUI y
   si quedó o se rehízo. Si uno sale mal 2 veces, pasalo a la reserva: imagen en Gemini (decime
   el prompt y la hago yo) → Meshy → Blender.
6) Ningún modelo puede tener texto, logos, sangre ni nada de casino. Si aparece, rehacelo.
Mostrame una imagen con todos los modelos lado a lado. Commit "modelos IA de la sala".
```

### Prompt 7b-3 · Limpiar, importar y luces de la sala

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md y la sección 5 de la
GUIA (modelos 3D). Etapa 7b-3: pasar los modelos de la IA al juego y dejar la sala como mis
capturas.

1) Blender (solo limpieza, no modelar): por cada .glb de plinko-knight/modelos/ia/, revisar
   triángulos (máximo de la tabla de la etapa 7b), escala (la máquina mide unos 7 studs de alto,
   la banqueta 2,5), pivote en la base, normales, un material por malla, texturas de 512 px
   (1024 solo M1 y M14). Guardar .blend en plinko-knight/modelos/blender/ y exportar a
   plinko-knight/modelos/exports/. Si el conector de Blender no está, usá la preparación de
   modelos de ForgeGUI para escala y pivote.
2) Subir cada modelo UNA vez (ForgeGUI a Roblox o por MCP) y duplicarlo en Studio. IDs en
   Config.Assets. Reemplazar los bloques grises de 7b-1 por los modelos, manteniendo los tags.
3) La pantalla de M1: el tablero tiene que quedar justo dentro de la pantalla del modelo. Si el
   modelo no tiene una pantalla plana usable, poné una Part plana encima con el tablero.
4) Sala con mis capturas: casi negro #0D0A14, neón magenta #FF3FD0, cian #3FE8FF, amarillo
   #FFE14A, verde #7CFF6B (Parts Neon), piso de damero que refleja, alfombra con confeti en el
   pasillo, la luz sale casi toda de los carteles. Pocas luces con sombra (celular).
5) Carteles con texto hechos con partes y TextLabels: ARCADE, PLINKO KNIGHT, TIENDA, RÉCORDS.
6) Comparación lado a lado con mis capturas (misma cámara) en arte/comparaciones/, tabla de
   diferencias, corregir hasta 3 veces.
Probalo: FPS en emulador de celular (30 o más), consola sin rojo, 2 jugadores. Copia .rbxl en
backups/. Commit "sala arcade con modelos".
```

---

> **Agregado el 27/10/2026 (Juani, con propuestas de Gemini):** "quiero más pixel art, como Balatro; mejorá la distribución de las pantallas; la tienda en una pantalla aparte; el HUD y las imágenes con ForgeGUI, vos las animaciones y los modelos. Sigue siendo feo". Juani pasó una captura armada por Gemini (3 columnas) y dos textos de Gemini: uno del HUD y otro de la sala. Acá queda **lo que se toma y lo que no**. Van como **etapas 10b y 10c, antes de la 11**, un prompt por sesión.

## Filtro de las propuestas de Gemini (reglas de apuestas de Roblox y regla 5)

| Gemini propuso | Se hace así | Por qué |
|---|---|---|
| Ficha de póker en el "Objetivo" | Ícono de calavera o del monstruo | Fichas = casino |
| "Meta 50.000 / Actual 18.433" | Vida del monstruo: barra y "18.433 / 50.000" | El objetivo ya existe: bajarle la vida |
| Cajero ATM de deuda, "rondas restantes / deuda", ranura de tarjeta | **Terminal de la tienda** con display "PELEAS 3/9" y ranura de bolas | Nada de deuda ni dinero |
| "Slot machine console", "game odds" en la pantalla | Máquina arcade con el logo y una demo del tablero | Tragamonedas prohibidas |
| Puerta que se abre "al liquidar la deuda" | Puerta blindada que **se abre al ganar la mazmorra** (adorno: luces verdes y sube) | Mismo efecto, sin deuda |
| Mesa de amuletos | **Vitrina de tus reliquias** (las de la partida, en 3D chiquitas) | Encaja con las reliquias |
| Clavijas golpeadas que se desintegran (Peglin) | Durante el tiro, la clavija tocada queda con un aro oscuro; vuelve al terminar | Acá se pueden volver a tocar |
| Fondo de mesa verde (Balatro) | Fondo oscuro de mazmorra con un remolino lento violeta y cian | El paño verde parece mesa de casino |

## Etapa 10b · Pantallas en pixel art, tipo Balatro (27/10)

**Lo que ya se hizo (27/10, antes de frenar):** estilo de ForgeGUI **"Plinko Knight - Pixel mazmorra"** (id `d3da0e22-4d00-42cb-9a61-0ff5537197a1`, versión 1) y 9 imágenes generadas, todavía sin subir ni usar (ids de trabajo de ForgeGUI):

| Pieza | Job |
|---|---|
| Panel | `98a23356-9b8b-487b-8302-2da375690b6e` |
| Botón | `f5b41844-0425-4ff7-851c-a3e2bc20708f` |
| Casillero | `8feb336d-bae6-4f37-af18-c8ec3ac06b07` |
| Corazón | `a9393fbf-b648-4faf-8774-f5670bdb815b` |
| Moneda | `35011646-e319-43d1-a6b4-df9461407473` |
| Engranaje | `8e8ebeb8-698a-432e-9055-6c37f177bfff` |
| Puerta (salir) | `46483bdb-efee-4de1-93f5-1077939d8ed7` |
| Espada (Fuerza) | `25bd60ff-e9ae-4a89-ae1f-878d297f27c8` |
| Llama (Multi) | `4fd00267-5e17-4e67-aa3e-e47f5dbb4178` |

**Distribución (3 columnas + bandeja):**
```
┌────────────────┬──────────────────────────┬────────────────┐
│ IZQUIERDA      │ CENTRO: TABLERO          │ DERECHA        │
│ Pelea 5 de 9   │ (más ancho, con aire,    │ [Salir] [⚙]    │
│ Zona 2         │  marco fino)             │ Monstruo       │
│ ♥ vida (verde) │                          │ (cartel 3D,    │
│ ● oro          │                          │  vida y maña)  │
│ ──────────     │                          │                │
│ FUERZA × MULTI │                          │                │
│ (azul) (rojo)  │                          │                │
│ = GOLPE grande │                          │                │
│ tus clavijas   │                          │                │
├────────────────┴──────────────────────────┴────────────────┤
│ BANDEJA: [bola] [perg.] [perg.] [rel][rel][rel][rel][rel]   │
└─────────────────────────────────────────────────────────────┘
```
- **Tienda en pantalla aparte:** al ganar una pelea, la pantalla cambia entera a la tienda (como Balatro), con cartas grandes en fila, precio dorado, "Renovar", "¿Qué sale?" y el botón **BAJAR** enorme abajo a la derecha. Si comprás una mejora de clavija, la tienda se corre, aparece el tablero para tocar las clavijas y después vuelve.
- **Paleta:** verde menta = vida y cosas buenas; azul = Fuerza; rojo = Multi y daño; dorado = oro y tienda; magenta y cian = neón de adorno.
- **Letra pixel** en todo (Arcade de Roblox; si se ve chica, otra pixel de Roblox), números grandes con borde oscuro.

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la sección
"Agregado el 27/10" (filtro de Gemini y etapa 10b). Si está la skill game-ui-ux, usala de apoyo.
Etapa 10b: pantallas en pixel art tipo Balatro. ForgeGUI hace el HUD y los íconos; Claude hace
el código, las animaciones y lo 3D.

1) Imágenes: usá las 9 ya generadas con el estilo "Plinko Knight - Pixel mazmorra" (si alguna
   no sirve, generala de nuevo con el mismo estilo; avisame cuántas antes). Los marcos tienen que
   tener el centro transparente para ir encima de los botones (9-slice). Subilas a Roblox con la
   conexión de ForgeGUI y anotá los IDs en Config.Assets.Hud.
2) Estilo.luau: variante "D · Pixel" en Config.Pantalla (letra pixel, paneles con marco pixel,
   botones con labio oscuro abajo que se hunden al tocarlos, sombra dura). Que cambiar la
   variante siga cambiando todo.
3) Distribución en 3 columnas + bandeja (dibujo de la etapa 10b). El panel FUERZA × MULTI pasa
   de cartel 3D a la columna izquierda (2D): caja azul, ×, caja roja y "= GOLPE" grande. La
   cámara del tablero usa el espacio libre del centro.
4) Tienda como pantalla aparte, con cartas que se balancean y se inclinan hacia el mouse, precio
   dorado y BAJAR enorme. Si hay que tocar clavijas, se corre y vuelve.
5) Números como Balatro/Peglin: "+2" blanco con borde azul que salta de la clavija; los ×Multi
   en un cartelito rojo inclinado ("×2 MULTI") que crece 20 % y sube; cada toque hace saltar la
   caja azul o la roja (1,1 y vuelve). Al caer la bola: golpe seco, las dos cajas se juntan en
   una cifra gigante que vuela al monstruo.
6) Clavijas por estado: las normales doradas con brillo; las especiales con borde que late o
   runa; las tocadas en este tiro con un aro oscuro hasta que termina.
7) Fondo: remolino lento violeta y cian detrás del tablero (pixelado, en la pared del fondo).
8) Inicio, final, cofre, ajustes y ficha de reliquia con el mismo estilo.
Probalo: una pelea entera, una compra con clavijas y un cofre; capturas antes/después en
plinko-knight/arte/comparaciones/v4/. Consola sin rojo. Commit "pantallas pixel".
```

## Etapa 10c · Sala neón: CloverPit + arcade de los 80 (27/10)

Sala en primera persona, chica y cerrada, con la máquina en el centro. Todo con partes por código (vive en git), sin modelos de IA.

- **Máquina (centro):** silueta de CloverPit (palanca al costado, bandeja abajo) en carcasa arcade con bordes de luz cian y fucsia; pantalla CRT con letra pixel naranja o amarilla, el logo y una demo del tablero. *(Ya hecha en parte el 27/10: gabinete con marquesina, botones y bisel.)*
- **Terminal de la tienda (izquierda):** metal satinado, franja LED magenta vertical, display "PELEAS 3/9" y "MEJOR 5/9", botón grande de confirmar y ranura de bolas. *(Ya hecho en parte: kiosco con vitrina de bolas.)*
- **Vitrina de reliquias (derecha):** mesa con cajas de vidrio iluminadas por dentro; en cada una, una reliquia de las que tenés en la partida (modelito simple que gira) y un monitor chico con botones de arcade.
- **Piso:** baldosas oscuras en damero que reflejan un poco las luces de neón.
- **Paredes:** paneles acústicos oscuros en relieve con tubos de neón que forman flechas hacia la máquina y siluetas simples (una espada, una calavera).
- **Columnas de neón:** verticales en las esquinas, que laten.
- **Puerta blindada (al fondo):** compuerta con franjas amarillas y negras iluminadas por detrás y luces rojas; **al ganar la mazmorra** se ponen verdes y la puerta sube (solo adorno).
- **Ambiente:** niebla suave y luz que sale casi toda del neón.

```
Juego: Plinko Knight. Leé las Reglas de plinko-knight/PLAN-Y-PROMPTS.md, la ficha y la sección
"Agregado el 27/10" (filtro de Gemini y etapa 10c).
Etapa 10c: la sala neón, en primera persona, todo con partes por código en GeneradorSala.

1) Piso de damero oscuro que refleja; paredes con paneles acústicos y flechas/siluetas de neón;
   columnas de neón en las esquinas que laten (cliente).
2) Terminal de la tienda: franja LED magenta vertical y display con PELEAS y MEJOR (datos de tu
   progreso), además de lo que ya tiene.
3) Vitrina de reliquias a la derecha: cajas de vidrio con luz adentro; cada reliquia que tenés en
   la partida aparece como un modelito simple que gira (forma y color de su rareza).
4) Puerta blindada al fondo con franjas iluminadas y luces rojas; al ganar la mazmorra, verdes y
   se levanta (cliente, solo adorno).
5) Niebla suave y luz del neón. Pocas luces con sombra.
6) Nada de cajero, deuda, monedas, fichas ni "odds" (ver el filtro).
Probalo: caminar la sala, sentarse y levantarse, ganar la mazmorra (con los atajos de prueba) y
ver la puerta; capturas en plinko-knight/arte/comparaciones/v4/. 60 FPS en compu, consola sin
rojo. Copia .rbxl en backups/ si cambia el place. Commit "sala neón".
```

### Más ideas de Gemini para después de 10b y 10c (no entran todavía)
- Cuando el golpe es enorme, la pantalla CRT de la sala muestra la cifra (se ve al levantarte).
- Sonido "seco" para el golpe final y un "ding" más agudo para cada ×Multi.
- Contadores digitales en la máquina con tus récords en vivo.
