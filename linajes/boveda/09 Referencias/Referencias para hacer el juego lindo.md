---
tags: [referencias, estilo, luz, hud]
---
# Referencias para hacer el juego lindo (15 nov 2026)

> [!summary] En tres líneas
> Completa lo que ya juntó Gemini ([[Referencias de estética]], [[Referencias de mapas del sandbox]], [[Referencias de efectos]]) con lo que faltaba: **recetas de luz de Roblox**, **cómo se logra el look de cómic en escenarios**, **piso mojado falso** y **HUD de rachas para celular**. Además, un **límite técnico** de Roblox que nos afecta: solo se ven **31 Highlights** a la vez. Solo se toman ideas y técnicas, nunca diseños.

## Cómo se ve hoy (captura del 15 nov)
- El piso de la zona segura es **cian liso y muy saturado**: compite con los personajes y no parece puerto.
- Los contenedores son **bloques planos azul y verde** sin desgaste ni línea de tinta. El cómic está en los personajes, pero el escenario no.
- Cielo **negro con el eclipse rojo**: lindo, pero no tiene degradé ni nubes, y el horizonte desaparece.
- Pocas luces cálidas: no hay **un foco** que guíe la vista al centro de la pelea.

## 1. Luz (lo que más cambia con menos trabajo)
| Fuente | Qué aporta |
|---|---|
| [Roblox: Future lighting en exteriores](https://create.roblox.com/docs/tutorials/3D-art/enhancing-outdoor-environments-with-future-lighting) | Guía oficial. `EnvironmentDiffuseScale` y `EnvironmentSpecularScale` en 1 para que el metal refleje el cielo. `OutdoorAmbient` pinta lo que ve el cielo y `Ambient` lo techado: sirven para tintar las sombras de azul en vez de negro. |
| [DevForum: trucos de luz](https://devforum.roblox.com/t/tips-tricks-for-improving-your-game-using-lighting/1062421) | Mezclar SpotLight, SurfaceLight y PointLight; ColorCorrection para el look estilizado; el Bloom solo luce si hay piezas Neon. |
| [DevForum: guía de luz](https://devforum.roblox.com/t/guide-to-lighting/2764787) | De noche no conviene fiarse solo de `ClockTime`: a medianoche todo queda negro y no se ve. Hay que subir el ambiente y poner luces cálidas. |
| [Unified Lighting](https://devforum.roblox.com/t/let-there-be-unified-light-unified-lighting-is-fully-live/3401512) | Desde 2025 la luz se ve parecida en todos los niveles de calidad: lo que armemos en PC también se va a ver en celular. |

**Para Linajes:** ya tenemos la tabla de la [[Guía de estilo]] (Puerto Óxido de noche). Falta aplicarla bien: sombras azul pizarra, **un solo foco cálido sodio** en el centro de la arena, y los bordes más oscuros.

## 2. Escenario de cómic (no solo los personajes)
| Fuente | Qué aporta |
|---|---|
| [80 Level: el look de Hi-Fi Rush](https://80.lv/articles/the-making-of-hi-fi-rush-s-3d-toon-rendering-style) y [charla de GDC](https://gdcvault.com/play/1034330/3D-Toon-Rendering-in-Hi) | Personajes **y escenario** con el mismo tratamiento de cómic. Si solo los personajes tienen tinta, el mundo parece de otro juego. |
| [Puntos de trama (halftone) en Blender](https://80.lv/articles/3d-artist-showcasd-halftone-effect-made-with-blender-viewport) y [nota técnica](https://alexanderameye.github.io/notes/halftone-shader/) | La trama de puntos de imprenta en las sombras. En Roblox no hay shaders: **se pinta en la textura en Blender** (horneada) para paredes, contenedores y piso. |
| [CG Magazine: estética de cómic en juegos](https://www.cgmagonline.com/articles/comic-book-aesthetics-gaming/) | Línea negra gruesa en los bordes y sombras planas, como un filtro sobre todo. |

**Para Linajes:** a los contenedores, galpones y grúas les falta **línea de tinta pintada en la textura** (como ya hacemos con `pintura.py`) y **2 o 3 tonos planos** en vez de un color liso.

## 3. Piso mojado falso
| Fuente | Qué aporta |
|---|---|
| [DevForum: superficies mojadas (con materiales)](https://devforum.roblox.com/t/how-to-make-surfaces-appear-wet-material-pack-incl/2476461) | MaterialVariant con poca rugosidad para asfalto mojado. |
| [DevForum: efecto charco](https://devforum.roblox.com/t/how-to-figure-out-a-way-to-achieve-a-puddle-effect/464107) | Pieza transparente con textura de charcos encima del piso. |
| [DevForum: piso mojado](https://devforum.roblox.com/t/how-to-make-a-wet-floor-effect/892585) | `Reflectance` solo funciona en Plastic y SmoothPlastic; Roblox refleja el cielo, no las luces. |

**Para Linajes:** el reflejo de neón **hay que pintarlo**: franjas de color debajo de cada luz (ya hay `CharcoBrillo` en `Iluminacion.luau`; falta aplicarlo con más fuerza y en más lugares).

## 4. Límite técnico: 31 Highlights
- [Documentación de Roblox](https://create.roblox.com/docs/reference/engine/classes/Highlight): **solo se dibujan 31 Highlights a la vez**; los que sobran **no se ven y no avisa**. Uno desactivado también ocupa lugar.
- Hoy usamos Highlights para destellos de golpe, borde de enemigos, aura del Despertar y más. **Con 8 jugadores peleando, algunos efectos van a desaparecer.**
- Arreglo: **un Highlight por personaje**, que cambie de color según el momento (golpe, aura, Variante), en vez de crear uno nuevo por cada efecto. Para contornos de escenario: tinta pintada en la textura ([alternativa con SelectionBox](https://devforum.roblox.com/t/highlight-instance-alternative/3080226)).

## 5. HUD de rachas y bajas (celular)
| Fuente | Qué aporta |
|---|---|
| [Roblox: diseño de UI y UX](https://create.roblox.com/docs/en-us/production/game-design/ui-ux-design) | Guía oficial: botones grandes y nada encimado en celular. |
| [HUD para la vista periférica](https://gamedeveloper.com/design/perceiving-without-looking-designing-huds-for-peripheral-vision) | Lo importante se entiende por color y forma, sin leer. |
| [7 errores de HUD](https://bootcamp.uxdesign.cc/7-obvious-beginner-mistakes-with-your-games-hud-from-a-ui-ux-art-director-d852e255184a) | Poco texto, contraste alto y espacio libre alrededor. |
| [Lista de bajas (kill feed)](https://app.studyraid.com/en/read/99448/4464005/implementing-kill-feed-and-combat-reports) | Pila corta que se borra sola, solo con bajas confirmadas por el servidor. |

**Para Linajes:** falta **lista de bajas** arriba a la derecha, **cartel de racha** ("RACHA 3", "¡DESPERTAR LISTO!") y que el rombo **G** brille más cuando está listo.

## Plan propuesto, por impacto
1. **Luz y cielo de Puerto Óxido** según la Guía: sombras azules, foco sodio en el centro, cielo con degradé y nubes.
2. **Piso**: sacar el cian liso de la zona segura y usar asfalto mojado con charcos de color.
3. **Contenedores y props con tinta y desgaste** (textura horneada en Blender, 2 o 3 tonos).
4. **Un Highlight por personaje** (no pasarse de 31).
5. **HUD de racha y lista de bajas.**
6. **Un lugar memorable** en el centro (Gemini propuso barco encallado o grúa caída).

Ver también: [[Referencias de estética]] · [[Referencias de mapas del sandbox]] · [[Referencias de efectos]] · [[Guía de estilo]]

Volver a [[Referencias]]
