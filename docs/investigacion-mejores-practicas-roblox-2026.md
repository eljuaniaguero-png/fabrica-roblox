# Cómo hacer juegos en Roblox (octubre 2026): scripts, mapas, modelos y flujo de trabajo

**Versión 2** (11 oct 2026): añade la sección 4.4 sobre Claude + Blender, la sección 10 sobre cómo hacerlo todo sin programar, y apunta a `GUIA-PARA-CLAUDE.md`, que es el documento que Claude lee para trabajar.

Investigación hecha el 11 de octubre de 2026 con fuentes oficiales de Roblox (documentación y anuncios del DevForum) y de la comunidad. Cada dato importante lleva su fuente y fecha al final de su sección. Lo que es opinión mía o inferencia está marcado como **(inferido)**.

---

## Resumen en 10 puntos

1. **Lo más importante que cambió en 2026: Roblox Studio ya trae un servidor MCP oficial.** Herramientas como Claude Code, Cursor o Codex pueden conectarse a Studio y leer/editar scripts, ejecutar Luau, insertar o generar modelos, darle a Play, leer la consola y simular al jugador. Esto es la pieza que le faltaba a nuestro sistema automatizado.
2. **El código vive en archivos `.luau` en Git, no solo dentro del `.rbxl`.** Dos caminos: **Rojo** (estándar de la comunidad, el repositorio manda) o **Studio Script Sync** (oficial desde junio 2026, más simple pero solo sincroniza scripts y carpetas).
3. **Arquitectura: un Script de servidor y un LocalScript de cliente que cargan módulos** (Services/Controllers). Knit, el framework más famoso para esto, está archivado desde julio de 2024: se copia el patrón, no la librería.
4. **El servidor decide todo.** Todo lo que llega del cliente se trata como manipulado: tipos, rangos, NaN, distancia, frecuencia.
5. **Datos de jugador: ProfileStore** (sesión con bloqueo, guardado automático), más guardado en compras, al salir, en `BindToClose` y ahora también en `game.ServerRestartScheduled`.
6. **Mapas: primero cajas grises (greybox), después arte.** El juego se prueba con bloques; los modelos finales salen de una biblioteca central de assets reutilizables.
7. **Modelos: máximo 20.000 triángulos por malla, un material por malla, texturas del tamaño justo (512 px suele bastar), subir cada malla una sola vez y duplicarla** para que el motor la instancie.
8. **StreamingEnabled siempre**, con `ModelStreamingMode` bien elegido por modelo y código de cliente que no asume que las cosas existen.
9. **Entrada del jugador con el nuevo Input Action System** (lanzado en junio 2026): una acción, varios controles (teclado, táctil, mando).
10. **El algoritmo de recomendaciones ahora mira retención a 28 días, play-through rate y rebote en la primera partida.** El diseño del primer minuto y del regreso al mes pesa más que antes.

---

## 1. Herramientas y flujo de trabajo

### 1.1 Qué cambió en 2026 (importante para automatizar)

| Novedad | Qué hace | Fecha |
|---|---|---|
| **Servidor MCP de Studio** | Studio expone herramientas a clientes de IA externos: leer/editar/buscar scripts, explorar el árbol de instancias, ejecutar Luau en Edit/Client/Server, Play/Stop, leer la consola, capturar la vista, simular movimiento, teclado y ratón, generar mallas y materiales, buscar e insertar assets. Funciona localmente (stdio). Clientes con conexión rápida: Claude Code, Claude Desktop, Cursor, Codex CLI, Gemini CLI, VS Code. Se activa en Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server. | Docs vigentes (oct 2026); anunciado en abril 2026 |
| **Studio Script Sync** (versión final) | Clic derecho en una carpeta → "Sync to…" → elige carpeta en disco. Sincroniza en ambos sentidos con VS Code/Cursor. Solo Script, LocalScript, ModuleScript y Folder. Hasta 10.000 scripts por instancia raíz y 128 raíces. | 17 jun 2026 |
| **Assistant agéntico** | Modo Planificación (plan en Markdown editable que se aprueba con "Build"), generación de mallas, agente de playtesting (beta) que prueba el juego contra el plan. | 15 abr 2026; planes en la nube jun 2026 |
| **Studio CLI documentada** | `RunScript` ejecuta un `.luau` al abrir un lugar, con `--outputFile` y `--quitAfterExecution`: sirve para pruebas automáticas (Windows y Mac). | jul 2026 |
| **API de depuración** (beta) | `ScriptDebuggerService`: breakpoints y logpoints desde Luau; Assistant puede poner breakpoints y leer el estado en vivo. | jun 2026 |
| **Animation Graphs** | Editor visual para mezclar animaciones del personaje, replicado automáticamente. | jul 2026 |

Fuentes: [Roblox Studio is Going Agentic, 15 abr 2026](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic) · [Conectar el servidor MCP de Studio (docs)](https://create.roblox.com/docs/en-us/studio/mcp) · [Full Release: Studio Script Sync, 17 jun 2026](https://devforum.roblox.com/t/full-release-studio-script-sync/4688454) · [Weekly Recap 15–18 jun 2026](https://devforum.roblox.com/t/weekly-recap-june-15-june-18-2026/4691531) · [Weekly Recap 13–17 jul 2026](https://devforum.roblox.com/t/weekly-recap-july-13-%E2%80%93-17-animation-graphs-go-live-5%C3%97-more-data-store-storage/4743286) · [Studio CLI (docs)](https://create.roblox.com/docs/en-us/studio/command-line-interface)

### 1.2 Rojo o Script Sync

| | **Rojo** | **Studio Script Sync** |
|---|---|---|
| Quién manda | Los archivos del repositorio | Studio y disco por igual |
| Qué sincroniza | Scripts y también modelos (`.rbxm`), JSON, configuraciones del proyecto | Solo scripts y carpetas |
| Paquetes (Wally) | Sí | No de forma nativa |
| Construir el `.rbxl` desde cero (CI) | Sí (`rojo build`) | No |
| Instalación | Rojo CLI + plugin | Nada, viene en Studio |
| Riesgo | Hay que aprender `default.project.json` | Dos personas editando el mismo script se pisan |

**Recomendación para nuestro sistema:** Rojo en modo *parcialmente gestionado* (el código y las configs en Git; el mapa y los modelos grandes siguen en el archivo del lugar) + el servidor MCP de Studio para probar el juego. Script Sync es el plan B si el usuario no quiere instalar nada. Según la propia web de Rojo, es "el estándar de facto" y casi todas las alternativas antiguas están abandonadas; las que siguen vivas son Argon y Lync, con otras restricciones de diseño.

Fuentes: [Rojo: alternativas (docs v7)](https://rojo.space/docs/v7/rojo-alternatives/) · [Script Sync, 17 jun 2026](https://devforum.roblox.com/t/full-release-studio-script-sync/4688454)

### 1.3 Caja de herramientas recomendada (todas gratis)

| Herramienta | Para qué |
|---|---|
| **Rokit** | Fija las versiones de todas las herramientas en `rokit.toml` |
| **Rojo** | Sincroniza archivos ↔ Studio, construye el `.rbxl` |
| **Wally** | Gestor de paquetes Luau |
| **luau-lsp** (extensión de VS Code) | Autocompletado y comprobación de tipos fuera de Studio |
| **Selene** | Linter con soporte de la API de Roblox |
| **StyLua** | Formateador (`--check` en CI) |
| **Lune** | Ejecuta Luau fuera de Studio: scripts de build, validar configs en CI |
| **Jest-Lua** | Tests unitarios (ver nota en §7 sobre TestEZ) |

Fuente: [Toolchain Luau 2026, oflight, 17 abr 2026](https://www.oflight.co.jp/en/columns/luau-developer-toolchain-rojo-selene-wally-2026)

### 1.4 Publicar sin abrir Studio (Open Cloud)

`POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published` con una API key con permiso **universe-places → Write**, enviando el `.rbxl`. Devuelve el número de versión.

**Trampa:** la API **no actualiza** `SurfaceAppearance`, `EditableImage`, `EditableMesh`, `PartOperation` (uniones/negaciones) ni `BaseWrap`. Si el juego los usa, esa publicación se hace desde Studio. **(inferido)** Por eso conviene publicar por API solo un `.rbxl` construido con Rojo a partir del lugar base, o publicar desde Studio vía MCP.

Fuente: [Place publishing (docs Open Cloud)](https://create.roblox.com/docs/en-us/cloud/guides/usage-place-publishing)

### 1.5 Flujo de trabajo recomendado (de idea a publicación)

1. **Diseño en una página:** gancho de 10 segundos, loop corto/medio/largo, por qué vuelve mañana y dentro de un mes.
2. **Prototipo gris** (mapa de bloques + sistemas mínimos) en un lugar de pruebas.
3. **Playtest** (Local Server con 2–3 jugadores, emulador móvil, y prueba automática vía MCP o el agente de playtesting).
4. **Arte:** reemplazar los bloques por la biblioteca de assets.
5. **Optimizar** (streaming, draw calls, memoria).
6. **Publicar en un lugar de pruebas privado → publicar en producción.** Dos lugares/universos separados (dev y prod) para no romper el juego en vivo **(inferido, práctica común)**.
7. **Medir** con Creator Analytics y `AnalyticsService` y volver al paso 1.

---

## 2. Cómo estructurar los scripts

### 2.1 Dónde va cada cosa

| Contenedor | Qué poner | Lo ve el cliente |
|---|---|---|
| `ServerScriptService` | Script `Main` del servidor y los Services | No |
| `ServerStorage` | Plantillas solo del servidor (enemigos, recompensas, mapas que se clonan) | No |
| `ReplicatedStorage` | Módulos compartidos (Configs, Net, tipos, utilidades), plantillas que el cliente necesita | Sí |
| `StarterPlayerScripts` | LocalScript `Main` del cliente y los Controllers | Sí |
| `StarterGui` | UI (o se crea por código) | Sí |
| `Workspace` | Solo el mundo físico; **nunca** scripts de lógica sueltos | Sí |

Regla: cualquier cosa en `ReplicatedStorage` o `Workspace` la puede leer un exploiter. Precios y probabilidades de servidor pueden estar ahí (el cliente las necesita para mostrar), pero la **decisión** siempre en el servidor.

### 2.2 Patrón de un solo punto de entrada (Services / Controllers)

- Un único `Script` de servidor y un único `LocalScript` de cliente. Cada uno hace `require` de todos los módulos de su carpeta, llama a `:Init()` en todos (preparar, sin depender de otros) y después a `:Start()` en todos (ya pueden usarse entre sí).
- Un ModuleScript por responsabilidad (`DataService`, `ShopService`, `UIController`…).
- **Knit está archivado desde el 31 de julio de 2024** y ya no recibe actualizaciones. El patrón sigue siendo bueno; lo recomendable es un cargador propio de ~30 líneas en vez de depender de Knit. Hay derivados de la comunidad (p. ej. OwlKnit) pero no hacen falta.

Fuentes: [Repositorio de Knit (archivado)](https://github.com/Sleitnick/Knit) · [DevForum: single script architecture](https://devforum.roblox.com/t/2530875)

### 2.3 Red (RemoteEvents)

- Remotes definidos en un solo módulo (`Net`), nunca creados sueltos por todo el código.
- Para juegos con mucho tráfico (combate, muchos jugadores), librerías que empaquetan en `buffer`: **Blink** (compilador de un archivo de definición a código Luau tipado), **Zap** o **ByteNet**. Para un juego normal, Remotes con validación bastan **(inferido)**.
- Enviar solo lo necesario, cuando cambia, con menos frecuencia; los efectos visuales y los tweens van en el cliente.

Fuentes: [Blink (DevForum)](https://devforum.roblox.com/t/blink-an-idl-compiler-written-in-luau-for-roblox-buffer-networking-0185/2959671) · [ByteNet (GitHub)](https://github.com/ffrostfall/ByteNet) · [Mejorar rendimiento (docs)](https://create.roblox.com/docs/en-us/performance-optimization/improve)

### 2.4 Seguridad (lo que más se rompe)

Roblox lo dice así: *"Asume que todo dato enviado por el cliente ha sido manipulado, fabricado o enviado con mala intención"*, y los exploiters pueden disparar Remotes "a cualquier frecuencia con argumentos arbitrarios".

Checklist por cada Remote:
1. ¿El tipo es el esperado? (`typeof`)
2. ¿Número finito y en rango? (`x == x` descarta NaN; comprobar `math.huge`)
3. ¿La instancia existe y pertenece a ese jugador?
4. ¿Está cerca / tiene permiso / tiene el dinero?
5. ¿Cuántas veces por segundo lo ha llamado? (rate limit)
6. El cliente nunca dice "dame 100 monedas"; dice "quiero comprar el ítem X" y el servidor calcula.
7. Ojo con la propiedad de red: el exploiter controla la física de su personaje y de las piezas sueltas de las que es dueño.

Fuente: [Security tactics (docs)](https://create.roblox.com/docs/en-us/scripting/security/security-tactics)

### 2.5 Guardado de datos

- **ProfileStore** (loleris, sucesor de ProfileService, oct 2024): bloqueo de sesión para evitar duplicación de ítems, guardado automático cada **300 s** (antes 30), tipos de Luau, `MessageAsync` para mensajes entre servidores (regalos). API: `ProfileStore.New(nombre, plantilla)`, `StartSessionAsync`, `Reconcile`, `OnSessionEnd`, `EndSession`. **No sirve** para leaderboards ni estado global.
- Recomendaciones oficiales: pocos DataStores y una clave por jugador (hasta 4 MB), claves con el `UserId` (nunca el nombre), `UpdateAsync` en vez de `SetAsync` cuando varios servidores escriben, reintentos con espera exponencial y `pcall`, MemoryStore para datos temporales, borrar datos de eventos viejos, configurar el borrado de datos por petición del jugador (RTBF).
- **Límites nuevos (jul 2026):** almacenamiento base de 100 MB → **500 MB** por experiencia; las peticiones de juego y de Open Cloud pasan a compartir **un único presupuesto por experiencia**.
- **Nuevo evento `game.ServerRestartScheduled`** (jun 2026): avisa antes de un reinicio programado; usarlo para guardar y avisar a los jugadores, además de `BindToClose`.
- Con el autosave a 5 minutos, **forzar un guardado tras cada compra con Robux** (ProfileStore permite `Profile:Save()`) **(inferido)**.

Fuentes: [ProfileStore (DevForum, 11 oct 2024)](https://devforum.roblox.com/t/profilestore/3190543) · [Data stores best practices (docs)](https://create.roblox.com/docs/en-us/cloud-services/data-stores/best-practices) · [Weekly Recap 13–17 jul 2026](https://devforum.roblox.com/t/weekly-recap-july-13-%E2%80%93-17-animation-graphs-go-live-5%C3%97-more-data-store-storage/4743286) · [Weekly Recap 15–18 jun 2026](https://devforum.roblox.com/t/weekly-recap-june-15-june-18-2026/4691531)

### 2.6 Entrada del jugador: Input Action System

Lanzado oficialmente el **11 de junio de 2026**. Se definen **acciones** (`InputAction`: "Saltar", "Atacar"), se les asignan **controles** (`InputBinding`: espacio, botón táctil, botón A) y se agrupan en **contextos** (`InputContext`: "En combate", "En menú") que se activan y desactivan. Un solo código sirve para PC, móvil y consola. Los PlayerScripts por defecto migrarán a IAS: opcional ahora, por defecto a principios de 2027 y obligatorio a mediados de 2027. Hay un editor visual en beta (Input Action Manager).

Fuente: [Full Release: Input Action System, 11 jun 2026](https://devforum.roblox.com/t/full-release-input-action-system-ias-newly-converted-player-scripts/4678416)

### 2.7 Estilo de código Luau

- `--!strict` y tipos en módulos de lógica.
- `task.wait/task.spawn/task.delay`, nunca `wait/spawn/delay`.
- Los métodos que esperan se están renombrando con sufijo `Async` (p. ej. `LoadCharacterAsync`); los nombres viejos siguen funcionando como alias (dic 2025).
- Desconectar conexiones al terminar y limpiar tablas por jugador al salir (fuga de memoria número uno).
- Nada de `while true do` por jugador ni lógica pesada en `Heartbeat`; repartir trabajo entre frames y usar Actors (paralelismo) para cálculos que no tocan instancias.

Fuentes: [Release Notes 702, 9 dic 2025](https://devforum.roblox.com/t/release-notes-for-702/4138975) · [Mejorar rendimiento (docs)](https://create.roblox.com/docs/en-us/performance-optimization/improve)

---

## 3. Cómo hacer los mapas

### 3.1 Proceso oficial de Roblox (currículo de arte de entornos)
1. **Greybox:** bloquear el espacio con formas simples y probar la jugabilidad **antes** de invertir en arte.
2. **Crear assets pulidos** (Blender u otra herramienta).
3. **Armar una biblioteca de assets** en un solo lugar del juego, fácil de encontrar y reutilizar.
4. **Construir el mundo** a partir de esa biblioteca.
5. **Optimizar** para dispositivos con poca memoria.

Fuente: [Environmental art curriculum (docs)](https://create.roblox.com/docs/en-us/tutorials/curriculums/environmental-art)

### 3.2 Reglas prácticas
- **Kits modulares en una cuadrícula** (p. ej. piezas de 4 o 8 studs) que encajan entre sí: suelo, pared, esquina, puerta. Así un generador por código puede armar niveles combinando piezas **(inferido, práctica común)**.
- **La jugabilidad se marca con Tags y Attributes, no con nombres.** Una pieza con tag `KillBrick` o `Checkpoint` y atributo `Index = 3`; un servicio usa `CollectionService` para encontrarlas. Esto es lo que hace que el mapa sea "data-driven" y que la IA pueda generar mapas sin tocar código **(inferido)**.
- **Zonas como Models** con `ModelStreamingMode` adecuado y un `PrimaryPart`/pivote claro.
- **Colisiones simples:** `CollisionFidelity` Box o Hull donde no se note; paredes invisibles de bloques para mallas complejas; `CanCollide = false` y `CanQuery/CanTouch = false` en decoración.
- **Anclar** todo lo que no se mueve.
- **Iluminación:** pocas luces, rango corto, sin sombras en luces pequeñas o móviles; evitar muchas capas transparentes.
- **Terreno vs piezas:** terreno para paisajes naturales grandes; piezas y mallas para todo lo construido **(inferido)**.

### 3.3 Streaming (obligatorio para mapas medianos o grandes)
- `StreamingIntegrityMode = PauseOutsideLoadedArea`, `StreamingMinRadius = 64`, `StreamingTargetRadius = 1024`, `StreamOutBehavior = Opportunistic`, `ModelStreamingBehavior = Improved`.
- Por modelo: **Atomic** si los scripts necesitan todas sus partes; **Persistent** solo si siempre deben existir (gasta memoria); **PersistentPerPlayer** para cosas pequeñas y críticas como la parcela de cada jugador.
- En el cliente: `WaitForChild` con timeout cuando no puede seguir sin la instancia; `FindFirstChild` + comprobación de nil cuando sí. `GetDescendants` y los raycasts solo ven lo que está cargado, así que los recorridos completos van en el servidor. `RequestStreamAroundAsync` antes de teletransportar.
- Probar con `StreamingTargetRadius = 64` para destapar errores. Existe una skill `rbx-convert-to-streaming` para Assistant/MCP que convierte un juego existente.

Fuente: [Streaming techniques (docs)](https://create.roblox.com/docs/en-us/workspace/streaming/techniques)

---

## 4. Cómo hacer los modelos

### 4.1 Especificaciones oficiales
- **Máximo 20.000 triángulos por malla.** Mallas cerradas (watertight), con volumen, quads mejor que n-gons.
- **Un solo material por malla**, un solo set de UV, UVs dentro de 0–1 (pueden solaparse).
- **Texturas** PNG/JPG/TGA/BMP. Tamaño orientativo: 256 px para objetos de ~5 studs, 512 para ~10, 1024 para ~20. En rendimiento Roblox recomienda ~512 para la mayoría y 256 para lo secundario.
- **PBR con SurfaceAppearance:** Albedo (RGB), Normal (RGB, **formato OpenGL tangent space**), Roughness, Metalness y Emissive (escala de grises).
- Rigs: máximo 4 huesos por vértice, escala 1,1,1, raíz en 0,0,0.

Fuentes: [Specifications (docs)](https://create.roblox.com/docs/en-us/art/modeling/specifications) · [Texture specifications (docs)](https://create.roblox.com/docs/en-us/art/modeling/texture-specifications)

### 4.2 Rendimiento de modelos
- **Subir cada malla una vez y duplicarla en Studio**: el motor la instancia (menos draw calls y memoria). Importar un mapa entero como un bloque crea IDs duplicados y es más pesado.
- **Trim sheets / atlas** de texturas compartidas entre muchos modelos.
- `RenderFidelity` en Automatic o Performance.
- NPCs: Humanoid solo si hace falta; `AnimationController` para NPCs estáticos; animaciones en el cliente; aparecer solo cerca de jugadores; reutilizar (pool).

Fuente: [Mejorar rendimiento (docs)](https://create.roblox.com/docs/en-us/performance-optimization/improve)

### 4.3 Generación con IA
- **Assistant / servidor MCP:** genera mallas texturizadas desde texto (Cube 3D), y "Procedural Models" (modelos controlados por código con atributos ajustables, p. ej. número de estantes) anunciados como próximos en abril 2026. Las mallas generadas van al inventario del creador.
- La API en juego (`GenerationService`) salió en beta en marzo 2025 con límite de 5 generaciones por minuto por experiencia y objetos sueltos; la escala hay que ajustarla a mano.
- Herramientas externas (Meshy, Nilo, etc.) sirven, pero hay que reducir triángulos y respetar las especificaciones de arriba.

Fuentes: [Roblox Studio is Going Agentic, 15 abr 2026](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic) · [Beta Cube 3D Generation, 20 mar 2025](https://devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947) · [Nilo: optimizar modelos para Roblox, ago 2026](https://nilo.io/articles/optimize-model-for-roblox-export)

### 4.4 ¿Conviene conectar Claude con Blender? Sí, como taller de limpieza

**Qué existe (oct 2026):**

| Opción | Qué es | Requisitos | Notas |
|---|---|---|---|
| **Conector oficial de Blender en Claude** (Anthropic + Blender Lab, anunciado 28 abr 2026) | Claude controla tu Blender abierto mediante el servidor MCP oficial de Blender Lab | Blender 5.1+ (la academia de Claude dice 4.2+, el add-on pide 5.1+), app de escritorio de Claude, cualquier plan | Inspecciona la escena, cambia objetos en bloque, escribe Python que corre dentro de Blender. Para Claude Code hay que registrar a mano el ejecutable `blender-mcp` del add-on con `claude mcp add --scope project` |
| **blender-mcp comunitario** (ahujasid, MIT, ~28k estrellas) | Lo mismo, más integraciones: Poly Haven, Sketchfab, Poly Pizza, Hyper3D Rodin, Hunyuan3D; exporta GLB/FBX | Blender 3.0+, `uv`; en Claude Code: `claude mcp add blender uvx blender-mcp` | Socket sin autenticación (solo localhost), telemetría activada por defecto, modo seguro opcional |
| **3D-Agent** | Agente de pago (19–89 USD/mes) que trabaja en Blender y Roblox Studio | Blender 4.2+, internet | La comparación que lo recomienda es de su propia web |

**Qué hace bien:** revisar y arreglar modelos (contar triángulos, escala, pivotes, normales), aplicar cambios a muchos objetos, materiales simples, kits modulares geométricos (paredes, suelos, rampas), exportar. Un artículo de prueba (abr 2026) encontró que inspeccionar y hacer cambios masivos funcionaba bien y rápido.

**Qué no hace bien:** modelado orgánico detallado, UVs finas, rigging y animación. Todas las fuentes coinciden en que acelera el trabajo estructural pero no reemplaza a un artista. Las peticiones complejas salen mejor en pasos pequeños.

**Riesgo:** el código que Claude ejecuta en Blender corre "sin ninguna protección"; puede colgar Blender o romper la escena. Guardar antes de cada operación grande.

**Conclusión para Juan (inferido):** conectar Blender **sí conviene**, pero no como el lugar donde nacen los modelos. El flujo con menos esfuerzo es:
1. Objetos simples → generación de mallas de Roblox (Assistant/MCP de Studio), que ya salen dentro de Roblox.
2. Objetos con estilo propio → generador IA (Meshy, Tripo, Hyper3D, Hunyuan3D) → **Blender vía Claude para limpiarlos** (≤20.000 triángulos, un material, escala, pivote, texturas 512 px) → importar a Studio o subir con el plugin oficial de Roblox para Blender.
3. Kits modulares de mapa → Blender vía Claude o directamente con piezas de Roblox.

Fuentes: [Claude Academy: Blender connector](https://academy.claude.com/tutorials/using-the-blender-connector-in-claude) · [Classmethod: conector de Blender en Claude Desktop y Claude Code, 30 abr 2026](https://dev.classmethod.jp/en/articles/claude-blender-connector-desktop-and-code/) · [blender-mcp (GitHub)](https://github.com/ahujasid/blender-mcp) · [AI Architects: Blender MCP con Claude Code, act. 28 jul 2026](https://theaiarchitects.com/blog/blender-mcp) · [3D-Agent: opciones de Blender MCP, act. 25 sep 2026](https://3d-agent.com/blender-mcp) · [Plugin de Roblox para Blender (docs)](https://create.roblox.com/docs/en-us/art/modeling/roblox-blender-plugin)

### 4.5 Organización
- Plantillas en `ReplicatedStorage/Assets` (las que el cliente necesita) o `ServerStorage/Assets` (las que solo clona el servidor), con nombres estables.
- Los IDs `rbxassetid://` en Configs, nunca dentro de la lógica.
- Paquetes (Packages) para piezas que se repiten entre lugares o juegos: se actualizan en todas partes a la vez **(inferido)**.

---

## 5. UI

- Diseñar primero para **móvil**: botones grandes, `UIScale`/`UIAspectRatioConstraint`, zonas seguras. **(inferido; no encontré una cifra oficial actual del % de jugadores en móvil)**.
- Para UI compleja, frameworks declarativos (React-lua de Roblox, Fusion, Vide). Para un juego simple, ScreenGuis hechos en Studio y un `UIController` que los conecta **(inferido)**.
- Clipping de elementos rotados: `StarterGui.ClipsDescendantsSupportsRotation` será el comportamiento por defecto desde agosto 2026.
- Traducción automática: los jugadores pueden activar traducción automática; desactivar `AutoLocalize` en nombres propios.

Fuentes: [Weekly Recap 13–17 jul 2026](https://devforum.roblox.com/t/weekly-recap-july-13-%E2%80%93-17-animation-graphs-go-live-5%C3%97-more-data-store-storage/4743286) · [Weekly Recap 15–18 jun 2026](https://devforum.roblox.com/t/weekly-recap-june-15-june-18-2026/4691531)

---

## 6. Monetización y descubrimiento

### 6.1 Ítems aleatorios de pago (huevos, cajas, tiradas)
- Mostrar **todas** las probabilidades en porcentaje que sumen 100 % **antes** de comprar. Si la lista es larga, un pop-up con texto descriptivo (un simple "(i)" no vale).
- Cuenta como pago aleatorio también lo que se compra con **moneda del juego que se puede comprar con Robux** (llaves, tickets, re-rolls).
- Si un ítem solo se puede ganar una vez, recalcular las probabilidades restantes; los potenciadores de suerte deben explicar su efecto con números y actualizar las probabilidades mostradas.
- `PolicyService:GetPolicyInfoForPlayerAsync()`: si `ArePaidRandomItemsRestricted` es verdadero, ofrecer otra vía (gratis, orden fijo, compra directa, ocultar o bloquear). Si `IsPaidItemTradingAllowed` es falso, no permitir intercambiar ítems pagados.
- Página actualizada el **8 oct 2026**: revisarla antes de cada lanzamiento.

Fuente: [Paid random items policy (docs)](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)

### 6.2 Precios y descubrimiento (jun 2026)
- **Managed Pricing** une precios regionales y optimización de precios con pruebas automáticas.
- **Recomendaciones "Para ti"**: ahora usan retención a **28 días** (antes 7) y sustituyen QPTR por **play-through rate** y **tasa de rebote en la primera partida**. Consecuencia práctica: el primer minuto tiene que enganchar y el juego necesita motivos para volver durante semanas, no solo mañana.

Fuente: [Weekly Recap 15–18 jun 2026](https://devforum.roblox.com/t/weekly-recap-june-15-june-18-2026/4691531)

---

## 7. Pruebas

- **Manual en Studio:** Play Solo, Local Server con 2–3 jugadores, emulador de móvil, compras de prueba.
- **Automáticas:**
  - Lógica pura (economía, RNG, validación de configs) con **Jest-Lua** y/o **Lune** en CI.
  - Pruebas dentro de Studio vía **servidor MCP** (Play, leer consola, simular input) o el **agente de playtesting** de Assistant.
  - `Studio CLI --task RunScript --quitAfterExecution --outputFile` para smoke tests.
- Casos de abuso: spam de remotes, números negativos/NaN, compras dobles, salir durante el guardado, reinicio de servidor.
- **Nota sobre TestEZ:** la guía de oflight (abr 2026) todavía lo recomienda, pero Roblox desarrolla activamente Jest-Lua como sucesor **(inferido; no verifiqué el estado de mantenimiento de TestEZ en esta búsqueda)**.

---

## 8. Correcciones y mejoras al protocolo AutoRoblox-Dev v2

El protocolo v2 está bien encaminado (servidor autoritativo, configs separadas, Services/Controllers, ProfileStore, Rojo + Git). Lo que hay que corregir o añadir:

| # | Qué dice el v2 | Qué cambiar | Por qué |
|---|---|---|---|
| 1 | Rojo + Git, o copiar y pegar en Studio | **Añadir el servidor MCP de Studio** como vía principal para que Claude edite, ejecute y pruebe directamente en Studio, y Script Sync como alternativa sin instalación | Nuevo en 2026; elimina el copiar y pegar |
| 2 | "Triángulos por MeshPart" sin cifra | **20.000 triángulos por malla, 1 material, UVs 0–1, normal OpenGL** | Especificación oficial |
| 3 | Retención D1/D7 | **Añadir D28, play-through rate y rebote de primera partida** | El algoritmo cambió en jun 2026 |
| 4 | Guardar en `BindToClose` | **Añadir `game.ServerRestartScheduled`** y guardado forzado tras compras (autosave de ProfileStore = 300 s) | Nuevo evento jun 2026 |
| 5 | `InputController` genérico | **Usar Input Action System** | Lanzado jun 2026; los PlayerScripts migran en 2027 |
| 6 | Probabilidades visibles + `PolicyService` | **Incluir moneda comprable con Robux, recálculo de odds, boosts con números, `IsPaidItemTradingAllowed`** | Política actual (8 oct 2026) |
| 7 | "Más del 50% móvil" como dato | Marcarlo como **supuesto** | No encontré fuente oficial actual |
| 8 | TestEZ o Jest-Lua | **Jest-Lua primero** | (inferido) |
| 9 | Sin mención de streaming por modelo | **Elegir `ModelStreamingMode` por modelo y código de cliente a prueba de streaming** | Docs de streaming |
| 10 | Mapas no tratados | **Mapas data-driven con Tags/Attributes + kits modulares en cuadrícula** | Permite que la IA genere niveles sin tocar lógica |
| 11 | Publicación manual | **Open Cloud para publicar**, avisando de que no actualiza SurfaceAppearance ni uniones | Docs Open Cloud |
| 12 | DataStore genérico | **Límites jul 2026: 500 MB y presupuesto de peticiones compartido con Open Cloud**; scripts de Open Cloud con rate limit propio | Recap jul 2026 |
| 13 | `Main` carga módulos | Bien; aclarar **no usar Knit** (archivado 2024), cargador propio con `Init`/`Start` | Repositorio de Knit |

---

## 9. Arquitectura propuesta para el sistema automatizado (resumen)

> **Actualización v2:** Juan ya usa este esquema en `fabrica-roblox` (Rojo + Rokit + Selene + StyLua + MCP de Studio + git, con Claude Code en su PC). No hay que migrar nada; ver `GUIA-PARA-CLAUDE.md` y `revision-fabrica-roblox-2026-10-11.md`.

```
Repositorio Git (fuente de verdad)
├── rokit.toml               versiones de rojo, wally, selene, stylua, lune
├── default.project.json     mapeo de carpetas → Studio (Rojo)
├── src/
│   ├── shared/              Configs/, Net, Types, Util   → ReplicatedStorage
│   ├── server/              Main.server.luau, Services/   → ServerScriptService
│   └── client/              Main.client.luau, Controllers/ → StarterPlayerScripts
├── assets/                  .rbxm de kits de mapa y modelos pequeños (opcional)
├── tests/                   Jest-Lua / Lune
└── MANIFEST.md              versión, sistemas, SchemaVersion, changelog
Lugar .rbxl (mapa y modelos pesados) ← no gestionado por Rojo
```

Ciclo de una orden ("Añade un sistema de mascotas"):
1. Claude lee `MANIFEST.md` y las configs.
2. Escribe el código y la config en el repositorio; CI ejecuta Selene, StyLua y los tests de configs.
3. Con Studio abierto y el MCP conectado: sincroniza, da Play, lee la consola, simula al jugador y corrige.
4. Publica en el lugar de pruebas; tras revisión, en producción.
5. Actualiza `MANIFEST.md` y el changelog.

**Requisitos para empezar:** conectar GitHub en el proyecto y que el usuario tenga Studio abierto con "Enable Studio as MCP server" activado en un ordenador desde el que Claude pueda trabajar.

---

## 10. Hacerlo todo con IA sin programar

**Lo que hace falta para que Claude trabaje solo (inferido a partir de las fuentes de arriba):**
- **Claude Code corriendo en la computadora de Juan** (app de escritorio de Claude, pestaña Code). Los servidores MCP de Studio y de Blender son locales: una sesión en la nube no los alcanza.
- **Studio abierto con el servidor MCP activado.** Con eso Claude escribe scripts, arma mapas ejecutando Luau, inserta y genera modelos, le da a Play, lee errores y simula al jugador.
- **Blender abierto con el add-on MCP** cuando haya que limpiar modelos.
- **La carpeta `fabrica-roblox`** con `CLAUDE.md` + `GUIA-PARA-CLAUDE.md`, el código sincronizado con Rojo y git para poder volver atrás (ya existe).

**Qué sigue necesitando a Juan:** probar si el juego es divertido, decidir el estilo, aprobar publicaciones y gastos, crear gamepasses/productos en Creator Hub (o darle a Claude una API key de Open Cloud con permisos limitados), y guardar en Studio si el MCP no lo hace.

**Limitaciones honestas:** el agente de playtesting de Roblox está en beta; la generación 3D da objetos sueltos que hay que escalar; los modelos orgánicos de calidad siguen necesitando un artista o assets comprados; la diversión no se puede comprobar automáticamente.
