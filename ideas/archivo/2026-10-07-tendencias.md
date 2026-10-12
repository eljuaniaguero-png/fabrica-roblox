# Radar de tendencias — 2026-10-07

> Actualización del informe del 06/10 (tiene menos de 7 días). Abajo solo cambió lo marcado en "Novedades del 07/10"; el resto se mantiene.

## Novedades del 07/10

- **Huss Valley** apareció en Up-and-Coming con ~89K CCU (Rotrends, 07/10; creado el 31/08/2026). Es **supervivencia/persecución por rondas**: un pueblo tranquilo que de golpe se vuelve una cacería y hay que escapar o esconderse hasta que termine la ronda. Ojo: según PCGamesN usa perseguidores tipo Spider-Man o el Grinch, o sea personajes con marca; eso no lo copiamos. Para 1 persona: media (rondas + IA de persecución).
- **Simuladores de manejo** suben en Trending: Driving Simulator (6,2K, puesto 1) y Drag Drive Simulator (26,8K) (LevelUpPlay, 07/10). Para 1 persona: media-baja (física de autos).
- **Clarity Over Resonance** sigue en Trending y subió a 9,6K (LevelUpPlay, 07/10). Sigo sin poder verificar bien cómo se juega.
- **Heavyweight Fishing** sigue firme en Trending (5,9K, puesto 2, 07/10): refuerza la idea de pesca.
- Steal An Egg baja apenas (~1,035M, Rotrends 07/10) pero sigue arriba de todo. Fish It! estable (~69,6K).

**Conclusión**: las 3 ideas de ayer siguen siendo las mejores para una persona sola. Huss Valley es la novedad fuerte, pero entra en "supervivencia por rondas", que ya habíamos descartado por ser difícil de balancear solo.

## Qué está pasando (agrupado por mecánica)

| Mecánica central | Señales (con fecha) | Crecimiento | Facilidad para 1 persona |
|---|---|---|---|
| **Juntar → incubar → robar bases ajenas** (tycoon de "robo") | Steal An Egg: 1,6M CCU, +468% vs agosto (StudioKrew, 01/10). Rotrends lo muestra con ~1,06M al 06/10. Ride A Pet: 208K CCU (StudioKrew, 01/10). Steal a Brainrot sigue con ~103K (Rotrends, 06/10). | Muy alto, pero género saturado | Media (multijugador + bases) |
| **Incremental "+1" con obby** (cada paso suma stat) | +1 Speed Keyboard Escape: 137,9K CCU, puesto 8 (StudioKrew, 01/10). Parte del gancho es el sonido "ASMR" de teclas. | Alto | Alta |
| **Pesca con progresión** | Fish It!: ~70–76K CCU y sesión promedio de **91 min** (Rotrends / LevelUpPlay, 06/10). Fisch ~60K. Heavyweight Fishing en Trending (6K, 06/10). | Estable y largo | Media-alta |
| **Búsqueda relajada / objeto escondido** | Search For The Needle: pico 86K en septiembre, hoy ~14K (RoWatcher, sin fecha exacta del dato actual). | En caída (moda corta) | Muy alta |
| **Armar vehículo + recorrer hasta quedarse sin nafta** | Build and Kill Zombies: ~15K CCU (Playnews, sept.). | Medio | Media |
| **Supervivencia cooperativa / terror** | 99 Nights in the Forest 146,9K (StudioKrew, 01/10). Monster in the Mansion lanzado en septiembre. | Alto | Baja-media |
| **Peleas anime / shooters competitivos** | Jujutsu Shenanigans 117K, RIVALS 151K (StudioKrew, 01/10). Prime Heroes, Nemesis en el calendario de otoño. | Alto | Baja (mucho contenido y balance) |
| **Social / batallas de sonido** | Clarity Over Resonance en Trending con 9,1K (LevelUpPlay, 06/10), ~4× su base (RoWatcher). **No pude verificar bien cómo se juega**: una sola fuente dice que se arman "arreglos de sonido" para batallar. | Pico reciente | ? |
| **Música / ritmo** (género) | Señalado como emergente y con poca competencia (Rolearn, informe del 06/03/2026 — **dato viejo**, 7 meses). | Moderado | Media |

### Alerta de reglas de Roblox (agosto 2026)
Después de Steal An Egg, Roblox restringió los juegos que **premian mirar feeds de video con autoplay/scroll infinito** (el "treadmill" de videos): quedan bloqueados para cuentas Kids (5–8) y Select (9–15). Los anuncios con recompensa siguen permitidos. **Ninguna idea nuestra usa esa mecánica.**

## Las 3 elegidas

Criterio: buen crecimiento hoy + que una sola persona lo pueda prototipar en pocos días. Descarté peleas/shooters (demasiado contenido), terror cooperativo (difícil de balancear solo) y la búsqueda relajada (la moda ya está bajando).

---

### 1. Pisada Sonora

- **Mecánica que funciona**: incremental "+1": cada paso te da +1 de velocidad, con eso llegás más lejos en un obby largo y desbloqueás multiplicadores. Engancha porque el progreso es visible a cada segundo y siempre hay "un tramo más".
- **Giro propio (música)**: el piso es un instrumento. Cada baldosa que pisás toca una nota; cuanto más rápido vas, más rápido suena la melodía. Cada zona del mapa es un tema musical tuyo que se "completa" a medida que lo recorrés. Llegar a una zona nueva = desbloquear una canción nueva.
- **Loop de 30 segundos**: corrés → juntás velocidad → intentás pasar el próximo tramo → si caés, volvés al inicio de la zona más rápido que antes → canjeás velocidad por un multiplicador.
- **Alcance del prototipo**:
  1. Contador de velocidad +1 por paso (servidor) y su UI.
  2. Un obby de 1 zona con baldosas que disparan sonido (`-- SONIDO:` marcados).
  3. Puertas que piden velocidad mínima para pasar.
  4. Un rebirth simple (resetea velocidad, da multiplicador).
  5. Guardado de datos básico.
- **Riesgo principal**: que se sienta igual al juego de las teclas. Hay que apostar fuerte a lo musical (que el jugador *escuche* su avance) y a una estética propia, no a un mundo de teclado.

---

### 2. Pesca al Compás

- **Mecánica que funciona**: pesca con progresión: tirás la caña, sacás un pez, lo vendés, mejorás caña y carnada, accedés a zonas con peces más raros. Fish It! tiene sesiones de 91 minutos: es de los loops que más retienen en Roblox.
- **Giro propio (música/ritmo)**: para sacar el pez tenés que seguir su ritmo. Cada especie tiene un patrón propio (un pez lento en 4/4, uno nervioso en semicorcheas, un jefe que cambia de tempo). Acertar el beat tira del pez; errar lo afloja. Las cañas mejores te dan más margen de error.
- **Loop de 30 segundos**: tirás → esperás la picada → mini-juego de ritmo de 5–10 s → pez al balde → vendés o seguís pescando para conseguir el raro.
- **Alcance del prototipo**:
  1. Un muelle con agua y un punto de pesca.
  2. Lanzar caña + espera aleatoria de picada.
  3. Mini-juego de ritmo con 3 patrones de peces (validado en el servidor).
  4. Venta de peces por monedas.
  5. Una mejora de caña que agrande la ventana de acierto.
- **Riesgo principal**: sincronizar audio y input en Roblox (latencia, sobre todo en celular). Hay que testear temprano que el ritmo se sienta justo.

---

### 3. Corral Blindado

- **Mecánica que funciona**: juntar criaturas/huevos, que generen plata en tu base, y meterte en bases ajenas a llevarte lo mejor. Es el género que más creció en el año (Steal An Egg +468% en un mes). Engancha por el riesgo/recompensa entre jugadores.
- **Giro propio**: tu base se defiende sola con trampas que vos ubicás (pisos que resbalan, puertas que se cierran, alarmas), así que robar es un mini-atraco con puzzle, no solo una carrera. Sin velocidad pagada y sin feeds de video: la velocidad se gana armando bien la defensa y la ruta.
- **Loop de 30 segundos**: salís a juntar huevos → los dejás incubando en tu corral → mirás qué base ajena tiene algo raro → intentás esquivar sus trampas y volver → mejorás tus propias trampas con lo ganado.
- **Alcance del prototipo**:
  1. 2–4 bases con dueño asignado al entrar.
  2. Huevos que aparecen en el mapa y se llevan a la base.
  3. Huevo que genera monedas por segundo.
  4. Robo: agarrar un huevo ajeno y llevarlo a tu base (todo validado en el servidor).
  5. Una trampa colocable (ej.: piso que empuja).
- **Riesgo principal**: género muy saturado y es el más complejo de las tres (multijugador real, prevención de exploits). Para probarlo bien hacen falta al menos 2 jugadores.

---

## Datos que no pude verificar

- El chart oficial de roblox.com/charts no cargó (se arma con JavaScript), así que usé fuentes que lo replican (LevelUpPlay, Rotrends).
- Las cifras de CCU de Steal An Egg varían según la fuente y el momento (1,6M vs 1,06M).
- La mecánica real de Clarity Over Resonance: solo una fuente la describe.
- El dato de música/ritmo como género emergente es de marzo de 2026.

## Fuentes

Nuevas del 07/10:
- LevelUpPlay, Trending (datos del 07/10/2026): https://levelupplay.my/charts/trending
- Rotrends, Up-and-Coming (consultado 07/10/2026): https://www.rotrends.com/games/UpAndComing
- RoWatcher, Huss Valley: https://rowatcher.com/games/10764627709/huss-valley
- PCGamesN, Escape Huss Valley: https://www.pcgamesn.com/escape-huss-valley-codes

Del informe del 06/10:

- StudioKrew, "Top Roblox Games September 2026" (publicado 01/10/2026): https://studiokrew.com/blog/top-roblox-games-september-2026/
- Rotrends, Up-and-Coming (consultado 06/10/2026): https://www.rotrends.com/games/UpAndComing
- LevelUpPlay, Trending (datos del 06/10/2026): https://levelupplay.my/charts/trending
- Roblox Newsroom, Fall Games Preview (sept. 2026): https://about.roblox.com/newsroom/2026/09/roblox-fall-games-preview
- Playnews, juegos de otoño 2026: https://www.playnews.gg/en/guides/roblox-10-third-party-games-highlighted-for-fall-2026-from-september-to-october
- RoWatcher, Search For The Needle: https://rowatcher.com/games/10756011174/search-for-the-needle
- RoWatcher, Clarity Over Resonance: https://rowatcher.com/news/clarity-over-resonance-hits-8k-players-4-its-normal-baseline
- Beebom, Ride A Pet: https://beebom.com/ride-a-pet-wiki/
- TechSpot, restricción a juegos de "doomscrolling" (agosto 2026): https://www.techspot.com/news/113630-roblox-cracking-down-games-reward-kids-doomscrolling.html
- Inven Global, misma política: https://www.invenglobal.com/articles/25146/roblox-blocks-rewarded-infinite-scroll-on-kids-accounts
- Player.One, Steal An Egg (~1,3M al 09/09): https://www.player.one/robloxs-steal-egg-beating-some-platforms-biggest-games-164086
- PCGamesN, Heavyweight Fishing: https://www.pcgamesn.com/roblox/heavyweight-fishing-codes
- Rolearn, géneros emergentes Q2 2026 (06/03/2026): https://rolearn.dev/trend-reports/emerging-roblox-game-genres-q2-2026
