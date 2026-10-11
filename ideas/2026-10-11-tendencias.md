# Radar de tendencias — 2026-10-11

> Actualización del informe del 07/10 ([2026-10-07-tendencias.md](2026-10-07-tendencias.md), tiene menos de 7 días). Solo cambia lo de "Novedades del 11/10" y la lista de las 3 elegidas; la tabla por mecánica y la alerta de reglas siguen valiendo, con los números nuevos sumados.

## Novedades del 11/10

- **Heavyweight Fishing triplicó**: pasó de 5,9K (07/10) a **19K jugadores y quedó puesto 1 en Trending** (LevelUpPlay, 11/10). Fish It! sigue firme con ~74,9K (Rotrends, 11/10). La pesca es el género que mejor se sostiene: **refuerza fuerte la idea de pesca**.
- **El "+1" se está saliendo del obby**: **+1 Stone Skipping** (creado el 05/09) ya tiene **~37K** (Rotrends, 11/10). Tirás una piedra al agua, cada rebote suma un stat que te deja tirar más lejos, llegás a zonas nuevas, ganás "wins", mascotas y rebirth (Dexerto / TryHard Guides, oct.). También **+1 Loot To Forge** con ~24K (creado el 12/08). Es la mecánica nueva más fácil de construir de todo el radar.
- **+1 Speed Keyboard Escape bajó**: ~58K en Rotrends (11/10) contra 137,9K que daba StudioKrew (01/10). Son fuentes distintas, así que la caída exacta no es segura, pero la tendencia es a la baja. Pisada Sonora ya está en construcción y no depende de ese juego.
- **Huevos por todos lados**: Steal An Egg ~1,11M; aparecieron **Break and Steal an Egg (~98,7K, creado el 05/09)**, Steal Animal Egg (~12,7K), Drill for Eggs (~12,2K) y Lift Rock For Eggs (~13,1K) (Rotrends, 11/10). El género sigue creciendo pero ya está muy saturado de variantes.
- **Huss Valley** sigue subiendo: ~98,8K (antes ~89K). Sigue siendo supervivencia por rondas, que descartamos para una persona sola.
- **Steal ASMR!** (creado en septiembre, ~11,7K): un "robá de bases" con NPCs de comida (Bo3.gg). Por el nombre parece apoyarse en sonidos ASMR, pero **no pude verificar** que el sonido sea parte del juego.
- Otros nuevos con pocas semanas y >15K: Anime Dice (~61,7K, dados = azar, lo evitamos por la regla de ítems aleatorios), Makeup Mania (~29,9K), Firefighting Sim (~17,2K), Build the Pyramid (~15,9K), Hide In Pixels (~15,5K, **no encontré cómo se juega**).
- Search For The Needle volvió a subir un poco con su update de Halloween: ~19,1K (antes ~14K).
- Clarity Over Resonance bajó a 8,1K (puesto 9 en Trending, LevelUpPlay 11/10). Sigo sin verificar bien su mecánica.

## Qué está pasando (agrupado por mecánica, actualizado)

| Mecánica central | Señales nuevas (11/10) | Crecimiento | Facilidad para 1 persona |
|---|---|---|---|
| **Juntar → incubar → robar bases ajenas** | Steal An Egg ~1,11M; Break and Steal an Egg ~98,7K; muchas variantes con huevos | Muy alto, **muy saturado** | Media |
| **Incremental "+1"** (cada acción suma stat) | Stone Skipping ~37K, Loot To Forge ~24K; Keyboard Escape baja a ~58K | Alto, se mueve a acciones nuevas | **Muy alta** |
| **Pesca con progresión** | Heavyweight Fishing 19K y puesto 1 en Trending; Fish It! ~74,9K | **Subiendo y estable** | Media-alta |
| **Supervivencia / persecución por rondas** | Huss Valley ~98,8K | Alto | Baja-media |
| **Búsqueda relajada** | Search For The Needle ~19,1K (rebote por Halloween) | Medio | Muy alta |
| **Peleas anime / shooters** | Anime Dice ~61,7K, Sniper Arena 26,7K en Trending | Alto | Baja |
| **Simuladores de manejo** | Driving Simulator 4,3K (puesto 2 en Trending) | Medio | Media-baja |

### Alerta de reglas de Roblox (sigue vigente, agosto 2026)
Juegos que premian mirar feeds de video con scroll infinito: bloqueados para cuentas Kids y Select. **Ninguna idea nuestra lo usa.**

## Las 3 elegidas

Criterio: crecimiento hoy + que una persona sola lo prototipe en pocos días. **Pisada Sonora ya no entra en la lista porque ya se está construyendo**; su lugar lo toma la mecánica nueva del "+1 con lanzamiento".

---

### 1. Pesca al Compás (se mantiene, más fuerte que el 07/10)

- **Mecánica que funciona**: pesca con progresión (tirar, sacar, vender, mejorar caña, zonas con peces raros). Heavyweight Fishing triplicó en 4 días y Fish It! tiene sesiones de 91 min: es el loop que más retiene.
- **Giro propio (música/ritmo)**: cada pez se saca siguiendo su ritmo. Un pez lento en 4/4, uno nervioso en semicorcheas, un jefe que cambia de tempo. Acertar el beat tira, errar afloja. Mejores cañas = más margen de error.
- **Loop de 30 segundos**: tirás → esperás la picada → mini-juego de ritmo de 5–10 s → pez al balde → vendés o seguís buscando el raro.
- **Alcance del prototipo**:
  1. Un muelle con agua y un punto de pesca.
  2. Lanzar caña + espera aleatoria de picada.
  3. Mini-juego de ritmo con 3 patrones de peces (validado en el servidor).
  4. Venta de peces por monedas.
  5. Una mejora de caña que agrande la ventana de acierto.
- **Riesgo principal**: latencia entre audio e input, sobre todo en celular. Hay que probar temprano que el ritmo se sienta justo.

---

### 2. Rebote Afinado (nueva)

- **Mecánica que funciona**: "+1" con lanzamiento: tirás algo, cada rebote suma un stat, con más stat tirás más lejos y llegás a zonas nuevas. +1 Stone Skipping llegó a ~37K en un mes. Engancha porque cada tiro es corto, se ve el récord y siempre falta "una boya más".
- **Giro propio (música)**: cada rebote de la piedra toca la nota siguiente de una melodía (dominio público o inventada, con un solo sample y `PlaybackSpeed`). Soltar la piedra justo en el beat da un "rebote afinado" extra. Cada lago es una pieza distinta: cuando un tiro llega a tocar la frase completa, la desbloqueás y suena entera.
- **Loop de 30 segundos**: cargás el tiro → soltás en el beat → la piedra rebota tocando notas → +1 de habilidad por rebote → pasás una boya y ganás premios → mejorás la piedra o hacés rebirth.
- **Alcance del prototipo**:
  1. Lanzamiento con barra de fuerza y de tiempo (el servidor calcula cuántos rebotes y dónde cae; el cliente solo lo anima).
  2. Rebotes que tocan la melodía nota por nota (`-- SONIDO:` marcados).
  3. Stat de habilidad +1 por rebote que alarga los tiros, con su UI.
  4. 3 boyas de distancia que dan premios.
  5. Rebirth simple (resetea habilidad, da multiplicador).
- **Riesgo principal**: se parece mucho a Pisada Sonora (misma fórmula de "+1 + melodía"); podrían competir entre sí. Conviene hacerlo solo si Pisada Sonora ya está cerrada o si se piensa como un modo dentro de ella.

---

### 3. Corral Blindado (se mantiene, riesgo más alto)

- **Mecánica que funciona**: juntar huevos/criaturas que generan plata en tu base y meterte en bases ajenas a robar. Sigue siendo lo que más jugadores mueve (Steal An Egg ~1,11M, Break and Steal an Egg ~98,7K en un mes).
- **Giro propio**: tu base se defiende sola con trampas que ubicás vos (pisos que resbalan, puertas que se cierran, alarmas), así que robar es un mini-atraco con puzzle. Sin velocidad paga y sin feeds de video. Podría reusar las criaturas de Mutant Lab si se piensa como un modo de ese juego.
- **Loop de 30 segundos**: juntás huevos → los dejás incubando → mirás qué base ajena tiene algo raro → esquivás sus trampas y volvés → mejorás tus trampas.
- **Alcance del prototipo**:
  1. 2–4 bases con dueño asignado al entrar.
  2. Huevos que aparecen en el mapa y se llevan a la base.
  3. Huevo que genera monedas por segundo.
  4. Robo de huevo ajeno validado en el servidor.
  5. Una trampa colocable (ej.: piso que empuja).
- **Riesgo principal**: el género está lleno de copias (salieron 4 variantes con huevos en septiembre) y es lo más complejo de las tres (multijugador real, exploits). Hacen falta 2 jugadores para probarlo.

---

## Datos que no pude verificar

- La página de Up-and-Coming de Rotrends no muestra la fecha de sus datos; la tomé como consultada el 11/10.
- La caída de Keyboard Escape compara dos fuentes distintas (StudioKrew vs Rotrends).
- Cómo se juegan **Hide In Pixels** y **Clarity Over Resonance**, y si **Steal ASMR!** usa de verdad el sonido.
- El chart oficial de roblox.com/charts no se puede leer sin JavaScript; usé sitios que lo replican.

## Fuentes

Nuevas del 11/10:
- LevelUpPlay, Trending (datos del 11/10/2026): https://levelupplay.my/charts/trending
- Rotrends, Up-and-Coming (consultado 11/10/2026, sin fecha en la página): https://www.rotrends.com/games/UpAndComing
- Dexerto, +1 Stone Skipping: https://www.dexerto.com/roblox/1-stone-skipping-codes-3416218/
- TryHard Guides, +1 Stone Skipping (octubre 2026): https://tryhardguides.com/1-stone-skipping-codes/
- Bo3.gg, Steal ASMR!: https://bo3.gg/games/articles/steal-asmr-scripts
- Playnews, juegos de otoño 2026: https://www.playnews.gg/en/guides/roblox-10-third-party-games-highlighted-for-fall-2026-from-september-to-october

Fuentes anteriores: ver [2026-10-07-tendencias.md](2026-10-07-tendencias.md) y [2026-10-06-tendencias.md](2026-10-06-tendencias.md).
