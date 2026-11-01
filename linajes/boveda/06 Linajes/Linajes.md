---
tags: [linajes, indice]
---
# Linajes

> [!summary] En tres líneas
> Un **Linaje** es el poder que te despertó la esquirla del Eclipse. Te toca **al azar** en una ruleta con las probabilidades a la vista. Arranca en su **Variante Normal**, se transforma en 2 Despertares, y al final podés sumar un **segundo poder** y una **Técnica combinada**.

## La ruleta
| Rareza | % total | Linajes | % de cada uno | Color de rareza |
|---|---|---|---|---|
| Común | 55 % | [[Fuerza Bruta]], [[Reflejos]], [[Piroquinesis]] | 18,33 % | `#9aa3ad` |
| Poco común | 28 % | [[Electro]], [[Criogenia]], [[Telequinesis]] | 9,33 % | `#4ed68a` |
| Raro | 12 % | [[Velocista Cinético]], [[Sombra Viva]], [[Sangre Abisal]] | 4 % | `#4fb3f2` |
| Legendario | 4 % | [[Origen Estelar]], [[Herencia Olímpica]] | 2 % | `#f2a23a` |
| Mítico | 1 % | [[Eclipse]] | 1 % | `#ff4d6d` |

- Las probabilidades **siempre se ven** y suman 100 %.
- **Seguro de mala suerte**: cada 40 tiradas sin Raro o mejor, la siguiente es Raro o mejor.
- Las tiradas son **Fichas de Eclipse** y se ganan jugando. Si algún día se venden por Robux: probabilidades a la vista con un botón con texto antes de comprar y `PolicyService` (ver las reglas de monetización). Nada de casino.
- **Sin poder fuerte también se puede**: la tecnología y los implantes te hacen fuerte igual (el "camino del vigilante").
- **En la Beta salen solo los 3 Comunes** (un tercio cada uno).

## Las partes de un poder
| Parte | Qué es | Cómo se consigue |
|---|---|---|
| **Linaje** | El tipo de poder | Ruleta |
| **Variante** | Cómo se manifiesta: cambia los efectos y abre 2 habilidades propias. Cada Linaje tiene 4. | Todos arrancan con la **Normal**. Las otras 3 tienen una **condición secreta** (un lugar + una acción + a veces un **Catalizador**). Al cumplirla, tu poder "muta" en una escena corta. Mutar a otra reemplaza la anterior. |
| **Rasgos** | Modificadores chicos con un costo | **Salen de cómo jugás**: en cada Despertar y cada 10 niveles, el juego te da el Rasgo que más se ganó tu forma de jugar. No se tiran. Ver [[Poderes, inicio y personalización]]. |
| **Rama de evolución** | En qué se convierte tu poder | **Despertar 1** (nivel 25): elegís 1 de 2 ramas, **a ciegas** (solo nombre, símbolo y una frase). |
| **Chips de técnica** | Cambian una habilidad (más proyectiles, rebotan, dejan charco) | Caen de jefes y eventos |
| **Segundo poder** | Otro Linaje completo | **Despertar 2** (nivel 60), por 1 de 3 caminos: Transferencia (Brandt), Resonancia (Señal y Atalanta) o Núcleo artificial (Kessler y Okafor) |
| **Técnica combinada** | Habilidad única de 2 Linajes compatibles (tecla B) | Automática al tener la combinación |

## Teclas
| Tecla | Qué es |
|---|---|
| Clic | Combo de 4 golpes (según tu estilo de pelea) |
| F | Bloqueo y parry |
| Q | Dash |
| **Z, X, C** | Las 3 habilidades que equipes (del Linaje, la Variante, el árbol o los mentores) |
| **V** | Definitiva (después del Despertar 1) |
| G | Gadget |
| **B** | Técnica combinada (con 2 Linajes compatibles) |

## Números de referencia (iniciales; los reales viven en `Config.luau`)
- Jugador nivel 1: **400 de vida**, **100 de energía** (se recupera 8 por segundo sin usar habilidades).
- Combo de 4 golpes: 8, 8, 10 y 14 de daño.
- Habilidad básica: 20 a 35 de daño, 6 a 12 s de recarga, 15 a 30 de energía.
- Definitiva: 100 a 150 de daño, 60 s de recarga, toda la energía.
- Remache (jefe de la Beta): 2.000 de vida.

## Cómo es cada nota de Linaje
Todas tienen las mismas partes: cómo se siente, las 3 habilidades base con números, las 4 Variantes con sus condiciones secretas, las 2 ramas del Despertar 1 con su definitiva, los Linajes compatibles y sus Técnicas combinadas, el árbol (3 ramas: **Poder**, **Cuerpo** y **Técnica**), y cómo se ve y se oye (colores, efectos, animaciones y sonidos).

## Técnicas combinadas (las 12 del lanzamiento)
| Poder 1 + Poder 2 | Técnica | Qué hace |
|---|---|---|
| Piroquinesis + Criogenia | **Vapor** | Nube que ciega y quema |
| Piroquinesis + Electro | **Plasma** | Rayo de fuego que atraviesa |
| Fuerza Bruta + Telequinesis | **Meteoro** | Levantás un auto y lo estrellás desde el cielo |
| Reflejos + Sombra Viva | **Asesino fantasma** | 5 golpes teletransportados |
| Electro + Velocista Cinético | **Tormenta en movimiento** | Dejás rayos por donde corrés |
| Criogenia + Sangre Abisal | **Glaciar** | El piso se congela en un círculo enorme |
| Origen Estelar + Eclipse | **Supernova** | Solo existe con Legendario + Mítico |
| Fuerza Bruta + Herencia Olímpica | **Martillo del trueno** (propuesta) | Salto y golpe con rayo en área |
| Telequinesis + Sombra Viva | **Marionetas** (propuesta) | Controlás las sombras de 3 enemigos 3 s |
| Reflejos + Velocista Cinético | **Mil cortes** (propuesta) | 12 golpes en 1 s alrededor tuyo |
| Sangre Abisal + Electro | **Tormenta marina** (propuesta) | Lluvia eléctrica en un área mojada |
| Cualquiera + Núcleo artificial | **Sobrecarga** | Tu poder se mezcla con tecnología (efecto distinto por Linaje) |

Algunas son **secretas**: no se muestran hasta que alguien las descubre en el servidor, con aviso a todos.

Volver a [[Ficha del juego]] · Prompts: [[P36 Ruleta Linaje, Variante y Rasgos]] · [[P37 Niveles, árbol y Despertar 1 con ramas]] · [[P37b Chips de técnica, segundo poder y técnicas combinadas]] · [[P37c Rasgos por estadísticas y Variantes secretas]]
