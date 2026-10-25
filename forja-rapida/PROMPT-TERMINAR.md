# Forja Rápida · Prompt para terminar todo lo que falta (24/10/2026)

## Cómo usarlo (Juani)

1. Abrí Roblox Studio con el place de Forja Rápida, conectá Rojo (Plugins → Rojo → Connect) y, si vas a hacer modelos, abrí Blender con el complemento de Claude.
2. Abrí Claude Code en `fabrica-roblox` y pegá el **Prompt 1** tal cual. Claude revisa el juego de verdad, te arma la lista de lo que falta y no cambia nada todavía.
3. Leé la lista. Si está bien, decile **"dale"**. Si querés sacar o mover algo, decíselo con tus palabras.
4. Desde ahí, cada vez que quieras avanzar: `/clear` y pegá el **Prompt 2**. Hace **un solo pedido** de la lista, lo prueba, guarda en git y te muestra capturas.
5. Si algo no te gusta, antes de seguir decile "Esto no me gusta: …" y lo arregla en el mismo pedido.

Una copia de este archivo está en tu PC en `forja-rapida/PROMPT-TERMINAR.md`. También copié ahí los prompts de las 13 piezas y del lobby (`forja-rapida/arte/prompts-13-piezas.md` y `arte/prompts-lobby.md`), porque el prompt los usa.

---

## Prompt 1 · Revisar y armar la lista (pegalo primero)

```
Juego: Forja Rápida (carpeta forja-rapida/). Quiero terminar el juego: agregar todo lo que falta, sin rehacer nada de lo que ya anda.

PASO 0 · Trabajo sin guardar
Hay cambios sin commit desde el 19/10 (mascotas.py, MascotasRig.luau, Mascotas.client.luau, GameConfig.luau, Hud.client.luau, Estilo.luau, Golpes.client.luau, Eventos.client.luau y otros). Mirá git status y git diff, decime en 3 líneas qué son y, si el juego arranca sin errores en Play, hacé un commit con eso antes de cualquier otra cosa. Si algo está a medias o rompe, avisame y no lo commitees.

PASO 1 · Revisar el estado REAL (no cambies nada)
Leé ideas/forja-rapida.md entera, el código de forja-rapida/src y lo que hay en Studio por MCP (ServerStorage.Modelos, ReplicatedStorage.Mascotas, MaterialService, Workspace). No te fíes de la ficha: la última actualización es del 19/10 y desde ahí cambiaron cosas. Para cada punto de abajo decime HECHO, A MEDIAS o FALTA, con la prueba (archivo, línea o lo que viste en Studio):

A. Modelos importados en Studio: Geodas_Zona1-5, Geodas_Especiales, Gemas_Zona1-5 (60 piedras), Deco_Comun y Deco_Zona1-5, Lobby, Piezas_Juego (cercas, línea de zona segura, cartel colgante, toldos), Mascota_* (8). Para cada uno: ¿está en Studio y el juego lo usa, o sigue la versión de bloques?
B. Mascotas de Blender: ¿se ven las 8 con su animación (MascotasRig) siguiendo al jugador, o salen las de bolitas?
C. Piezas que el mapa todavía arma con partes simples (ficha, "Modelos que faltan"): Ruleta, Altar, Cofre, Puerta secreta, Sala de la cámara secreta, Portón entre zonas, Carteles de dificultad, Portal y Isla de la Dimensión Prisma, Spawn y Arco de entrada.
D. Ya hechos en Blender pero sin usar: Pico_*.fbx (el pico en la mano), Tablero.fbx, Parcela_Exhibicion y Pedestal_Madera/Piedra/Cristal (en vez de Vitrina).
E. Efectos de las piedras (Oro, Sombra, Fuego, Diamante, Arcoíris): La Forja ya los da y cambia el valor. ¿Se VEN en la piedra (revelación, mochila, Museo y exhibición) o solo cambian el nombre y el precio?
F. Exhibición que da dinero por segundo (forja-rapida/arte/prompts-lobby.md, punto 7): ¿existe o las vitrinas solo muestran?
G. Texturas de los modificadores (GameConfig.Modificadores[..].Textura está vacío) y los íconos Libro y Trofeo (siguen los viejos).
H. Pruebas pendientes de la ficha: pruebas/simular después del tope de daño, 2-3 jugadores en Local Server, emulador de celular, ProfileStore guardando de verdad (salir y volver), la forja a medias al salir.
I. Antes de publicar (GUIA, sección 10): game.ServerRestartScheduled, StreamingEnabled probado con radio chico, consola sin rojo, copia .rbxl en backups/, analítica andando.
J. Cualquier otra cosa que la ficha diga "falta" o "pendiente", o que veas rota.

PASO 2 · La lista
Con eso escribí forja-rapida/PENDIENTES.md: una lista numerada de pedidos CHICOS (cada uno se hace en una sesión), solo con lo que está A MEDIAS o FALTA, en este orden salvo que algo dependa de otra cosa:
  1. Lo que ya existe y solo falta meter en Studio (A, B), porque es lo que más cambia cómo se ve.
  2. Piezas con bloques que pasan a modelo de Blender (C), una o dos por pedido. Usá los prompts 1 a 12 y el 14 (conectar al juego) de forja-rapida/arte/prompts-13-piezas.md, con el estilo de arte/prompts-modelos.md y arte/referencias/. Antes de exportar, render para que lo apruebe.
  3. Modelos hechos sin usar (D).
  4. Efectos visibles de las piedras (E).
  5. Dinero por segundo en la exhibición (F): este pedido empieza con un plan de números y lo apruebo yo antes de tocar la economía.
  6. Texturas e íconos (G).
  7. Pruebas y lista de antes de publicar (H, I).
Para cada pedido poné: qué se hace, qué tengo que hacer yo (si hay algo), cómo lo vas a probar y si cambia la economía o los datos guardados.

Mostrame la lista y PARÁ. No arranques ningún pedido hasta que te diga "dale".

REGLAS PARA TODOS LOS PEDIDOS
- No rehagas nada que ya ande. Si algo de la lista ya está hecho, tachalo y pasá al siguiente.
- Mandan CLAUDE.md y GUIA-PARA-CLAUDE.md (no uses setup ni new-system de roblox-dev, ni worktrees).
- El servidor decide todo; números e IDs en GameConfig.luau; las piezas con función se marcan con tags o atributos.
- Studs como textura (MaterialVariant Studs_Liso), nunca como geometría. Triángulos según GUIA, sección 5.
- Si un pedido toca lo que se guarda, subí VERSION en Guardado.luau y escribí la migración.
- Si para algo necesitás que yo haga una acción en Studio o Creator Hub (importar un .fbx, subir una imagen, prender el acceso a la API), primero probá hacerlo vos por MCP; si no se puede, decime exactamente qué botón tocar.
- Nada con Robux. Si algún pedido lo necesitara, paralo y preguntame (GUIA, sección 6).
- Antes de un cambio grande al mapa: commit "antes de …". Al terminar cada pedido: Play por MCP con consola sin rojo, capturas, commit en español, actualizar ideas/forja-rapida.md, tachar el pedido en PENDIENTES.md y guardar copia .rbxl si cambió el mundo.
```

---

## Prompt 2 · Hacer el próximo pedido (pegalo cada vez, después de `/clear`)

```
Juego: Forja Rápida (carpeta forja-rapida/). Leé forja-rapida/PENDIENTES.md y hacé SOLO el primer pedido que no esté tachado, siguiendo las reglas de la lista.
Antes de cambiar nada, revisá en el código y en Studio que de verdad falte; si ya está hecho, tachalo y decime cuál sigue.
Si el pedido cambia la economía o los datos guardados, mostrame primero el plan con los números y esperá mi "dale".
Al terminar: probalo con Play por MCP, mostrame capturas (en computadora y, si toca pantalla, en el emulador de celular), commit, actualizá la ficha, tachalo en PENDIENTES.md y decime en una línea cuál es el próximo.
```

---

## Lo que vi en tu carpeta hoy (para que sepas qué esperar)

Esto lo revisé el 24/10 mirando tus archivos, sin abrir Studio. La Claude de tu PC lo confirma en el Prompt 1.

**Ya está hecho** (no hace falta pedirlo): las 60 piedras con íconos, las geodas nuevas de las 5 zonas, la decoración de las zonas, el lobby, la luz y el piso a cuadros con studs, las cercas, la zona segura, el cartel colgante y los toldos, la animación nueva del pico y los golpes, La Forja con las monedas "?", el punto débil, el dash, el menú Viajar, el guardado con ProfileStore, la analítica y los sonidos (elegidos el 23/10). Las 8 mascotas ya están hechas en Blender.

**Lo que probablemente falta:**
- Hay trabajo sin guardar en git desde el 19/10, sobre todo de las mascotas. Es lo primero.
- Meter las mascotas de Blender en el juego (el código ya las busca en `ReplicatedStorage.Mascotas`).
- Las piezas que el mapa todavía arma con bloques: ruleta, altares, cofres, puertas secretas, salas secretas, portones, carteles, el portal y la isla Prisma, el spawn y el arco.
- Usar los picos, el tablero, la parcela y los pedestales que ya están hechos en Blender.
- Que los efectos Oro, Sombra, Fuego, Diamante y Arcoíris se vean en la piedra.
- Que la exhibición dé dinero por segundo.
- Las texturas de las geodas exóticas y los íconos de Libro y Trofeo.
- Las pruebas con 2 o 3 jugadores, en celular y de que guarda de verdad, y la lista de antes de publicar.

**Publicar lo hacés vos** (lo dice tu CLAUDE.md): cuestionario de madurez, ícono y miniaturas. El último pedido de la lista te deja todo listo para eso.
