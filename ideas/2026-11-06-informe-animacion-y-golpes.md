# Informe 1: animación y golpes (6 nov 2026)

Amplía [las referencias de animación](2026-11-06-referencias-animacion.md). Solo se toman técnicas: ningún movimiento, personaje o arte se copia.

## Conclusión

Lo que más puede mejorar el combate de Linajes no es sumar animaciones, sino tres cosas:

1. Hacer que el impacto dure un instante.
2. Dar a cada golpe una reacción clara del enemigo.
3. Decidir cuánto se mueven atacante y víctima, para que el combo no se desarme.

## Evidencia

| Fuente | Tipo | Qué aporta |
|---|---|---|
| Charla GDC sobre combate en un juego de acción | Estudio profesional, subtítulos parciales | Avance de ataques, reacciones, corrección hacia el objetivo |
| Columna de Sakurai | Diseñador de juegos de pelea | Pausa, vibración y sus límites |
| Capcom | Oficial | Ejemplo de pausa por fuerza |
| critpoints | Análisis independiente | Por qué sin pausa los golpes se leen peor |
| Uhiyama Lab | Tutorial, valores sugeridos | Presets de partida y qué comunica cada efecto |
| Roblox Docs | Oficial | Editor, marcadores, prioridades, reproducción |
| 3 reels y 1 clip de Roblox | Imágenes | Poses, exageración y lectura |

## 1. Pausa de impacto

- Hace que el ojo confirme el choque y que el golpe parezca frenado por el objetivo.
- Atacante y víctima se frenan el mismo tiempo. Crece con el daño, pero tiene un tope.
- Los proyectiles usan menos pausa.
- Durante la pausa, la víctima vibra: de costado en el piso y vertical en el aire. La vibración baja con el tiempo.
- El atacante puede seguir moviéndose casi nada para que no parezca muerto.
- En combos, un tutorial sugiere pausar solo el primer y el último golpe.
- Sakurai advierte que no se alarga más porque un tercer jugador puede meterse durante la pausa. **Esto importa mucho en Linajes**, con hasta 24 jugadores.

**Valores iniciales para probar**, no definitivos:

| Golpe | Pausa | Sacudida |
|---|---|---|
| Combo 1 a 3 | 0,03 s | Muy baja |
| Combo 4 | 0,07 s | Media |
| Definitiva | 0,12 s | Alta, con tope |

Salen de los presets de Uhiyama, más cortos que el ejemplo de Capcom. Un juego multijugador no puede congelar el mundo. La pausa debe ser solo visual, sobre las animaciones involucradas, nunca `timeScale` ni demoras en el servidor.

## 2. Avance y reacción

La charla de GDC explica una relación clave:

- Los ataques fuertes avanzan al personaje. Las víctimas retroceden, y por eso el atacante sigue avanzando.
- Si ambos se mueven demasiado, el combo cruza la pantalla. El estudio redujo el retroceso de las reacciones básicas y parte del avance de los ataques.
- Usaron una corrección hacia el objetivo para llegar en un momento exacto de la animación. Con ángulos grandes redujeron el alcance, para que no se vea un tirón lateral.
- También orientaban la reacción para que la víctima no saliera de cámara.
- Tardaron años de pruebas, y programación y diseño trabajaron juntos.

**Para Linajes:**
- Dejar el avance y el retroceso como números en `Config.luau`.
- Corrección corta en el servidor, limitada por distancia y ángulo.
- El 4.º golpe es el único que empuja fuerte, como dice la ficha.
- No aplicar lo mismo al PvP sin probarlo: una corrección puede sentirse injusta.

## 3. Lo que se ve en las imágenes

- **Clip de Roblox, 16 cuadros de 2 segundos:** los cuerpos giran mucho, las piernas abren una base ancha y el torso se inclina. El rig de colores ayuda a controlar poses y direcciones.
- **Reel de juegos profesionales:** cada personaje se reconoce por silueta, incluso sobre fondo gris. Hay un derribo entre dos personajes con la pose bien legible.
- **Compilado de superhéroes:** aparecen vuelo horizontal, primer plano y un impacto en blanco y negro. Son más cine que juego.

**Regla práctica:** cada golpe debe entenderse si le sacás color y efectos. Si solo se entiende con partículas, hay que mejorar la pose.

## 4. Cómo hacerlo en Roblox

- El editor trabaja a 30 cuadros por segundo: `0:15` son 0,5 s.
- Los marcadores se escuchan con `GetMarkerReachedSignal`. Encajan con `Impacto` y `Aviso`.
- Prioridades, de mayor a menor: Action4, Action3, Action2, Action, Movement, Idle, Core. Hay más niveles que los cuatro de nuestro plan.
- `Constant` corta sin transición, útil para cambios secos.
- En los loops, el último cuadro debe repetir el primero.
- Para cambiar animaciones por defecto, detener las pistas activas antes.
- Las variantes de quieto se eligen por peso.

## 5. Lista de control para cada golpe

1. ¿Se entiende en silueta?
2. ¿La anticipación es breve pero visible?
3. ¿El marcador `Impacto` cae en el contacto?
4. ¿La víctima tiene reacción y dirección?
5. ¿Cuánto avanza cada uno?
6. ¿La pausa es solo visual?
7. ¿El servidor sigue decidiendo daño y distancia?

## Plan sugerido

1. Prototipo de pausa y vibración en el combo de Puños.
2. Tres reacciones: liviana, fuerte y desde atrás.
3. Avance y retroceso en `Config.luau`.
4. Corrección corta hacia el objetivo.
5. Prueba con 2 o 3 jugadores.

## Límites

Los valores no están probados en Linajes. La charla se leyó por partes y sus subtítulos son automáticos. La charla sobre animación de un juego de pelea no pudo leerse: YouTube la bloqueó.

## Fuentes

- [GDC: combate para una nueva perspectiva](https://www.youtube.com/watch?v=hE5tWF-Ou2k)
- [Reel de Kyle Dahl](https://www.youtube.com/watch?v=CEGUh_Ux8-0)
- [Reel de criaturas de Michele Le](https://www.youtube.com/watch?v=vosSPhkS0Fg)
- [AnimChallenge Superhero](https://www.youtube.com/watch?v=YhhANSEKsXE)
- [Combate cuerpo a cuerpo en Roblox](https://www.youtube.com/watch?v=79HRSEXQboY)
- [Capcom: hit stop](https://game.capcom.com/cfn/sfv/column/131545?lang=en)
- [Sakurai sobre hit stop](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/)
- [critpoints: hitstop](https://critpoints.net/2017/05/17/hitstophitfreezehitlaghitpausehitshit/)
- [Uhiyama Lab: respuesta al golpe](https://uhiyama-lab.com/en/notes/unity/unity-game-feel-hit-feedback/)
- [Roblox: animación](https://create.roblox.com/docs/animation)
- [Roblox: editor](https://create.roblox.com/docs/animation/editor)
- [Roblox: eventos](https://create.roblox.com/docs/animation/events)
- [Roblox: usar animaciones](https://create.roblox.com/docs/animation/using)
- [Quaternius UAL 2](https://quaternius.com/packs/universalanimationlibrary2.html)
