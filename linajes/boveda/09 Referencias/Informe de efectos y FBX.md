---
tags: [referencias]
---
# Informe 2: efectos y FBX (6 nov 2026)

Complementa el [[Informe de animación y golpes]]. Los efectos de los reels son referencia de técnica: no se copian diseños, personajes ni texturas.

## Conclusión

Los efectos fuertes tienen una estructura simple y se pueden lograr en Roblox sin modelos pesados: un destello corto, una forma principal, detalles que salen disparados y un resto que tarda en irse. El límite real va a ser el celular, no la idea.

## Qué comunica cada efecto

Un tutorial lo ordena así:

| Elemento | Información |
|---|---|
| Destello | El golpe conectó |
| Partículas y sonido | Dónde conectó |
| Sacudida | Cuán fuerte fue |
| Pausa | Fue un momento importante |

## Anatomía de un efecto

1. **Aviso:** chispa, carga o círculo en el piso.
2. **Destello:** uno a tres cuadros muy claros.
3. **Forma principal:** corte, rayo u onda.
4. **Brillo:** más chico y más fuerte que la forma.
5. **Apoyo:** chispas y fragmentos.
6. **Salida:** se disuelve, se erosiona o sigue el movimiento.
7. **Resto:** humo o marca en el piso.

## Lo que se ve en las imágenes

- **Reel de efectos de 2:52:** cuadros de alto contraste con pocos colores, hasta dos tonos y blanco. Las formas son planas y filosas.
- **Reel de efectos de personaje:** sobre fondo oscuro, el rayo se lee por un centro blanco y un borde de color. Círculos en el piso y domos marcan bien el área.
- **Impacto de un compilado:** una imagen en blanco y negro con rayos radiales y una cruz de luz.

**Para Linajes:**
- Centro casi blanco y borde del color del Linaje.
- Áreas de peligro siempre en el piso, con forma clara.
- En Bajo, mantener forma y aviso, y sacar detalle.

## Herramientas de Roblox

| Herramienta | Uso | Datos oficiales |
|---|---|---|
| `ParticleEmitter` | Chispas, humo, fragmentos | Hasta 400 por segundo, 100 en celular. Vida máxima de 20 s |
| Flipbook | Explosiones y cortes dibujados | 2x2, 4x4 u 8x8. Hasta 30 fps. Deja espacio entre cuadros |
| `Beam` | Rayos, láser, ondas | Usa 2 `Attachment`. Ancho por extremo y curva Bézier |
| `Trail` | Corte, estela, velocidad | Usa 2 `Attachment`. Su separación define el ancho |

Otros datos útiles:
- `LightEmission` en 1 da mezcla aditiva, buena para brillo.
- `Squash` estira partículas.
- `ZOffset` ayuda con el orden.
- Las partículas grandes cuestan más en la placa de video.
- Conviene entrar y salir con transparencia, para que no aparezcan de golpe.

## Recetas para probar

| Efecto | Capas | Modo Bajo |
|---|---|---|
| **Golpe de Puños** | Flipbook 4x4 + 6 a 10 chispas | Flipbook solo |
| **Fuerza Bruta** | Onda en piso + polvo + grieta | Onda + grieta |
| **Velocista** | `Trail` en piernas + `Beam` en piso | `Trail` solo |
| **Electro** | Beams cortos con textura + destello | Un solo Beam |
| **Definitiva** | Aviso + destello + forma + marca | Sin partículas extra |

Son propuestas: no hay cantidades medidas en nuestro juego.

## Destellos y accesibilidad

Un tutorial advierte sobre mareo por sacudida, luces intermitentes y sonido saturado.

- Limitar el flash a golpes fuertes.
- Agregar opción para bajar sacudida y destellos.
- No tapar nunca personajes ni avisos.
- Probar en celular real.

## FBX

La regla del proyecto no cambia: **Claude hace las animaciones en Blender**. Las bibliotecas externas sirven para comparar y aprender.

- **Mejor candidata:** Quaternius UAL 2, de enero de 2026. Tiene más de 130 animaciones, combos de 3 y 4 golpes separados con sus recuperaciones, parkour y FBX, GLB y Blend. Su página dice CC0.
- **Antes de usarla:** revisar qué trae la versión gratis y la licencia del paquete exacto.
- **Trabajo técnico:** adaptar del esqueleto universal a R15 y comprobar en Studio.
- **Mixamo:** no usar para subir a Roblox hasta tener una respuesta clara sobre sus términos.
- **Paquetes pagos:** solo con OK de Juani.

## Plan sugerido

1. Crear la plantilla de impacto con capas y modo Bajo.
2. Conectarla al marcador `Impacto`.
3. Hacer Puños, después Fuerza Bruta y Velocista.
4. Medir en celular real.
5. Decidir si conviene bajar Quaternius para comparar.

## Límites

- No medí rendimiento.
- La charla de GDC sobre efectos usa tecnología propia, que no existe en Roblox. Solo sirve como idea de usar la lógica del juego para animar efectos.
- No pude abrir Real Time VFX, un artículo de sacudida ni una guía de fundamentos de animación.
- De los reels se miraron hojas de muestra, no todos los cuadros.

## Fuentes

- [Reel de efectos de DaDi](https://www.youtube.com/watch?v=Qt4KOrRSQ3I)
- [Efectos de personajes de Motzify](https://www.youtube.com/watch?v=HTPbHeqstT0)
- [GDC: aprendizajes de efectos](https://www.youtube.com/watch?v=qbkb8ap7vts)
- [AnimChallenge Superhero](https://www.youtube.com/watch?v=YhhANSEKsXE)
- [Roblox: partículas](https://create.roblox.com/docs/effects/particle-emitters)
- [Roblox: Beams](https://create.roblox.com/docs/effects/beams)
- [Roblox: Trails](https://create.roblox.com/docs/effects/trails)
- [Uhiyama Lab: respuesta al golpe](https://uhiyama-lab.com/en/notes/unity/unity-game-feel-hit-feedback/)
- [Quaternius UAL 2](https://quaternius.com/packs/universalanimationlibrary2.html)
- [onetupthree: Anatomy Of A Slash](https://www.youtube.com/watch?v=QyI8ZS-G9nw)

Volver a [[Referencias]]
