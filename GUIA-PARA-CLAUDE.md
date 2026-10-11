# GUIA-PARA-CLAUDE.md — Reglas extra para hacer los juegos de Juani

> **Para Claude:** este archivo complementa a `CLAUDE.md` de `fabrica-roblox`. Si algo choca, **manda `CLAUDE.md`**. Leelo entero antes de cada pedido. Las fuentes de todo lo que dice están en `investigacion-mejores-practicas-roblox-2026.md` (carpeta del proyecto de Claude) y la revisión del código en `revision-fabrica-roblox-2026-10-11.md`.
>
> **Para Juani:** este archivo ya está en `fabrica-roblox/` y tu `CLAUDE.md` lo importa al final con `@GUIA-PARA-CLAUDE.md`, así que Claude Code lo lee siempre. La sección 8 dice qué instalar y la sección 9 tiene el prompt modelo.

Versión 3.1 · 11 oct 2026 · reemplaza al protocolo AutoRoblox-Dev v2

---

## 1. Cómo trabajar con Juani

- Juani **no programa y no quiere programar**. Claude hace todo: código, mundo, modelos, pruebas. Juani da el OK, juega y propone cambios.
- Español rioplatense, corto y claro (ver `CLAUDE.md`). Nada de jerga sin explicarla en media línea.
- **Nunca pedirle que copie o pegue código** ni que edite archivos. Si algo requiere una acción suya (abrir Studio, `rojo serve`, crear un pase en Creator Hub), decirle exactamente qué botón tocar.
- Si falta un detalle, elegir lo más simple, anotarlo en la ficha y seguir (ya lo dice `CLAUDE.md`).
- **No usar worktrees** (copias aisladas). Trabajar siempre en la carpeta principal. Si hay worktrees viejas con trabajo sin juntar, avisar antes de empezar otra cosa.

---

## 2. Principios técnicos (además de los de `CLAUDE.md`)

1. **El servidor decide todo.** En cada `OnServerEvent`, validar: tipo (`typeof`), número finito (`x == x` y distinto de `math.huge`), que la instancia exista y sea del jugador, distancia/permiso/dinero, y frecuencia por jugador.
2. **Datos fuera de la lógica:** números de balance en `Config.luau`; IDs de assets y de productos también en `Config.luau`.
3. **El mapa también es datos:** las piezas con función se marcan con **atributos** o **tags** (`CollectionService`), nunca se buscan por nombre. El proyecto ya lo hace (`Baldosa`, `Vendedor`, `Recolectable`): mantenerlo.
4. **Probado o no está hecho:** Play por MCP, consola sin rojo, simular al jugador, captura.
5. **Todo en git:** commit por cada avance que funciona, en español.

---

## 3. Guardado de datos (lo más delicado)

Reglas para cualquier juego que se vaya a publicar:
- **Bloqueo de sesión:** usar **ProfileStore** (loleris) o un bloqueo propio. Sin esto, salir de un servidor y entrar a otro puede pisar datos o duplicar ítems.
- **Autoguardado** periódico (ProfileStore lo hace cada 300 s; el sistema propio de Mutant Lab cada 60 s).
- Guardar también: al salir, en `BindToClose` (**en paralelo**, con tope de 25 s), al recibir `game.ServerRestartScheduled` y **justo después de cada compra con Robux**.
- **Reintentos** con espera creciente; `UpdateAsync` en vez de `SetAsync`.
- Un error al cargar **no apaga el guardado de los demás jugadores**. Al jugador afectado se le avisa ("No pudimos cargar tu progreso, volvé a entrar") en vez de dejarlo jugar sin guardar.
- `ProcessReceipt` idempotente: guardar los `PurchaseId` ya entregados.
- Cuando cambia la forma de los datos, subir `SchemaVersion` y escribir la migración.

---

## 4. Mundo, mapas y copias de seguridad

- **Greybox primero:** el nivel se arma con bloques simples y se prueba jugando; el arte viene después.
- **Mejor generado por código** (como `GeneradorTorre.luau`): así el mapa vive en git. Lo que se construya a mano por MCP, se guarda.
- **Copia del place:** al terminar cada pedido que cambie el mundo, guardar una copia `.rbxl` en `backups/<juego>-AAAA-MM-DD.rbxl` (fuera de git si pesa mucho).
- **Streaming:** `StreamingEnabled` activado, `ModelStreamingMode` por modelo (Atomic para modelos que un script necesita completos, PersistentPerPlayer para la base de cada jugador). En el cliente, `WaitForChild` con timeout o `FindFirstChild` + chequeo de nil.
- **Rendimiento en celular:** anclar lo que no se mueve; `CanCollide/CanTouch/CanQuery = false` en decoración; pocas luces con sombra; juntar animaciones de cliente en un bucle y pausar lo que no se ve.

---

## 5. Modelos 3D (con o sin Blender)

### De dónde sale cada modelo (en este orden)
| Necesidad | Primera opción | Si no alcanza |
|---|---|---|
| Formas simples, estilo del juego | Partes de Roblox armadas por código o MCP (el estilo actual de los dos juegos) | — |
| Objeto concreto (cofre, máquina, árbol) | Generación de mallas del MCP de Studio | Creator Store gratuita, revisando que no traiga scripts |
| Objeto con estilo propio o criatura | Generador IA (Meshy, Tripo, Hyper3D, Hunyuan3D) → **limpieza en Blender por MCP** → importar | Encargarlo a un modelador |

### Limpieza en Blender (si el MCP de Blender está conectado)
1. Guardar el `.blend` antes de cualquier cambio grande: el código que corre en Blender no tiene red de seguridad.
2. Importar el modelo y revisar: **≤ 20.000 triángulos por malla** (Decimate), escala real (1 stud ≈ 0,28 m), pivote en la base, malla cerrada, normales hacia afuera.
3. **Un material por malla**, un solo set de UV dentro de 0–1. Normal map en formato **OpenGL**.
4. Texturas: 256 px objetos chicos, 512 px la mayoría, 1024 px solo lo grande.
5. Exportar a `modelos/exports/` (`.fbx` o `.glb`) e importar por MCP, o subir con el plugin oficial de Roblox para Blender.
6. **Subir cada malla una vez y duplicarla** dentro de Studio.
7. Guardar el `.blend` en `modelos/blender/` y anotar el ID del asset en `Config.luau`.

---

## 6. Monetización y reglas de Roblox

Además de `ideas/monetizacion.md`:
- **Si una moneda del juego se vende por Robux, todo lo que se compre con ella al azar cuenta como ítem aleatorio pago.** Hay que mostrar las probabilidades en % (que sumen 100 %) antes de comprar, con un botón con texto, y respetar `PolicyService:GetPolicyInfoForPlayerAsync()` (`ArePaidRandomItemsRestricted`, `IsPaidItemTradingAllowed`). Si no se quiere hacer eso, **no vender la moneda por Robux**. Hay que resolverlo antes de implementar compras (ver la revisión, punto 1).
- Los potenciadores de suerte se explican con números y actualizan las probabilidades mostradas.
- Desde junio 2026 el algoritmo de Roblox mide **retención a 28 días**, **play-through rate** y **rebote en la primera partida**: el primer minuto tiene que enganchar y tiene que haber motivos para volver durante semanas.
- Agregar `AnalyticsService` (embudo de los primeros 10 pasos, fuentes y gastos de moneda) antes de publicar.

---

## 7. Herramientas que usa Claude

| Herramienta | Para qué | Si no aparece |
|---|---|---|
| MCP de Roblox Studio (`.mcp.json` → `Roblox_Studio`) | Mundo, playtest, consola, capturas, simular input, generar mallas | Decirle a Juani: Studio → Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server |
| Rojo (`rojo serve` / `rojo serve mutant-lab`) | Sincroniza `src/` con Studio | Pedirle que lo levante y conecte el plugin |
| Selene y StyLua | Revisar y ordenar el código | `rokit install` |
| MCP de Blender (opcional) | Limpiar y exportar modelos | Ver sección 8 |
| Git | Historial | — |

El MCP de Studio y el de Blender **solo funcionan en la computadora de Juani**: Claude Code tiene que correr ahí (app de escritorio de Claude, pestaña Code).

---

## 8. Qué tiene que instalar Juani

**Ya lo tenés** (lo vi en tu computadora): Roblox Studio, la app de Claude con Claude Code, Rokit con Rojo/Selene/StyLua, VS Code, Git, el MCP de Studio configurado en `fabrica-roblox/.mcp.json`. El instalador de GitHub Desktop está en Descargas (no sé si lo instalaste).

**Falta, en orden de importancia:**
1. **GitHub Desktop** (instalarlo desde Descargas) y subir `fabrica-roblox` como **repositorio privado**. Es la copia de seguridad de todo el código. Después conectá GitHub en Claude (claude.ai/connect-github) para que el proyecto de Claude en la web también lo vea.
2. **Extensión "Luau Language Server" en VS Code** (opcional): solo si querés mirar el código con colores y avisos.
3. **Para modelos 3D:**
   - **Blender 5.1 o superior** (blender.org, gratis).
   - **Conector de Blender en Claude:** app de Claude → Settings/Customize → Connectors → buscar "Blender" → Add. Después instalar el add-on **Blender MCP Server** de Blender Lab: arrastrar el enlace de instalación a Blender dos veces (la primera permite el repositorio "lab", la segunda instala) y activarlo en Edit → Preferences → Add-ons.
   - Para que lo use **Claude Code** (no solo el chat), hay que registrarlo en `fabrica-roblox` con `claude mcp add --scope project` apuntando al ejecutable `blender-mcp` del add-on. Pedíselo a Claude Code la primera vez: "Conectá el MCP de Blender a este proyecto".
   - **Plugin oficial de Roblox para Blender** (github.com/Roblox/roblox-blender-plugin): sube modelos de Blender a Roblox directo.
   - (Opcional) una cuenta en **Meshy**, **Tripo** o **Hyper3D** para generar modelos. Revisá que el plan permita uso comercial.

**No hace falta:** el `blender-mcp` comunitario y `uv` (el conector oficial lo reemplaza), Knit, TestEZ, Studio Script Sync (ya usás Rojo, que es mejor para tu caso).

---

## 9. Prompt modelo para pedir cualquier cosa

Copiá, completá lo que sepas y borrá lo que no. Va con el formato que ya usás en `ORDEN-PEDIDOS.md`:

```
Juego: [Mutant Lab / Pisada Sonora] (carpeta [mutant-lab/ o la raíz]).
Leé ideas/[ficha].md y el código actual.

QUÉ QUIERO
[Una o dos frases: qué agregar o cambiar.]

CÓMO LO VIVE EL JUGADOR
1. [Qué ve primero]
2. [Qué hace]
3. [Qué gana o qué cambia]

DÓNDE
[Zona del mapa, pantalla o momento del juego.]

NÚMEROS
[Precios, probabilidades, tiempos, recompensas. O "elegí vos y anotalo en Config.luau".]

CÓMO SE VE
[Estilo, colores de la paleta, referencia. O "seguí la guía de estilo de la ficha".]

¿SE PAGA CON ROBUX?
[No / pase / producto. Si hay azar, recordá la sección 6 de la guía.]

¿SE GUARDA?
[Sí / no.]

PRUEBA QUE QUIERO VER
[Ej.: "jugador nuevo hace X; captura en computadora y celular; salir y volver y que siga".]

Sumalo a la ficha, hacelo bloque por bloque, probalo por MCP, commit y mostrame capturas.
```

Para un juego nuevo: `/tendencias`, elegís una idea, y después `/prototipo [nombre]`.

---

## 10. Antes de publicar (checklist)

- [ ] Guardado con bloqueo de sesión, autoguardado, `BindToClose` en paralelo y `ServerRestartScheduled` (sección 3).
- [ ] Consola sin errores en Play y en Local Server con 2–3 jugadores; probado en emulador de celular.
- [ ] Compras de prueba: entregan una sola vez y se guardan.
- [ ] Ítems al azar pagados (directa o indirectamente): probabilidades visibles y `PolicyService` aplicado, o moneda no vendible.
- [ ] `StreamingEnabled` activado y probado con radio chico.
- [ ] Analítica básica funcionando.
- [ ] Copia `.rbxl` del place y commit hechos.
- [ ] Cuestionario de madurez, ícono y miniaturas. **Publicar lo hace Juani** (`CLAUDE.md`).
