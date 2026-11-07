---
tags: [ficha, animaciones]
---
# Animaciones (plan completo)

Todo lo que se mueve en el juego, quién lo hace y en qué orden. Manda sobre la lista suelta de los prompts de la Fase E: cuando un prompt y esta nota no coinciden, vale esta nota.

## Reglas para todas
- **Tres tipos**, según qué se mueve:
  | Tipo | Qué es | Quién la hace | Dónde |
  |---|---|---|---|
  | **Cuerpo** | Huesos del esqueleto R15 (personas, jefes, criaturas) | Claude en **Blender**, a 30 fps, con script | `linajes/arte/animaciones/` → Studio → **Publish lo apretás vos** |
  | **Efecto** | Partículas, rayos, haces, Neon, ondas, luz, sacudida de cámara | Claude en **Studio por código** (`src/client/efectos/`) | Plantillas en `ReplicatedStorage`, números en `Config.luau` |
  | **Objeto e interfaz** | Piezas que giran o se abren, botones, barras, ruleta, cámaras | Claude en **Studio por código** (TweenService, un solo bucle del cliente) | `src/client/` |
- Toda animación de cuerpo con golpe lleva marcadores **Impacto** (cuando pega) y, en los enemigos y jefes, **Aviso** 12 cuadros antes (0,4 s, el piso se pone rojo).
- Cada golpe tiene 3 partes: **anticipación** (se prepara), **acción** e **impacto**, y **recuperación**. El efecto, el sonido y la sacudida de cámara salen del marcador Impacto, no de un tiempo fijo.
- Todos usan el [[Cuerpo propio (sin avatar de Roblox)]]: una animación sirve para jugadores, NPCs y enemigos del mismo tamaño.
- Prioridad en Roblox: Core (quieto, caminar) < Idle < Movement < Action (golpes, poderes). Los poderes se mezclan con las piernas: se puede tirar una habilidad corriendo.
- **Celular**: los efectos tienen 2 niveles (Alto y Bajo). En Bajo: la mitad de partículas y sin luces dinámicas.

---

## Rehacer todo (método decidido el 6 nov 2026)
Juani pidió rehacer todas las animaciones. Se hacen por tandas con **poses nuevas en Blender**, sin bibliotecas externas. Ver [[Informe de animación y golpes]].
- **Motor `actuar`** en `linajes/arte/scripts/animaciones/base.py`: cada parte llega a su tiempo (el golpe nace en la cadera y termina en el puño) y cada tramo tiene su curva (`seco`, `sale`, `suave`).
- Se conservan duración y marcador `Impacto`, para no cambiar el combate.
- Los IDs de `Config.luau` cambian recién cuando la tanda esté aprobada, publicada y probada.
- **Orden:** 1. golpes y reacciones · 2. defensa, dash y derrota · 3. locomoción · 4. interacción · 5. Linajes, jefes, NPCs y el resto a medida que se hagan.
- **Tanda 1:** hecha en Blender y sin publicar. Comparación en `linajes/arte/renders/anim-comparacion-tanda1.gif`.
- **Para después: efectos de movimiento.** Van aparte del FBX, en Roblox, y salen de los marcadores. Orden: 1. probar animaciones en Studio · 2. polvo de pasos y aterrizaje, estela de dash e impacto de golpe (P30b-01) · 3. efectos de cada Linaje con su color (P30b-02 en adelante) · 4. Calidad Alta y Baja (P30b-07).
- **Fuerza Bruta:** Z, X, C y Cargar poder hechas en Blender, con FBX, sin publicar. Script `linajes/arte/scripts/animaciones/linaje-fuerzabruta.py`; hoja en `linajes/arte/renders/anim-base-hoja-fuerzabruta.png`. Ajustadas con las notas de Juani: Z gira solo el torso (55°). Embestida son 3 piezas (inicio 0,2 s, carrera en loop, frenada 0,3 s) y Cargar son 2 (inicio 0,3 s y loop). El código encadena las piezas.
- **Publicadas (6 nov):** las 7 de Fuerza Bruta, con IDs en `Config.Animaciones.linaje_fuerzabruta`. De las nuevas del jugador solo `correr-rapido` (135723695428939) y `dash-adelante` (88885509221229): sus IDs todavía no reemplazan a los viejos. Las nuevas están en `ServerStorage.AnimSaves` y las viejas en `AnimSavesViejas`.
- **Variantes de locomoción (pedido de Juani, 6 nov):** quieto, correr y saltar no son únicos. Cambian según Linaje, habilidad activa y si sos héroe o villano. Propuesta: se elige en este orden, y si no hay variante se usa la siguiente: 1. habilidad activa · 2. Linaje · 3. bando o reputación · 4. base. Empezar por Fuerza Bruta con quieto, correr y saltar, más una postura de héroe y una de villano. Sin hacer todavía.
- **Tanda 2:** las 27 restantes del jugador, hechas en Blender y sin publicar. Los loops usan arrastre de cabeza y brazos; trepar y las animaciones de salto sueltas quedan igual. Comparación en `linajes/arte/renders/anim-comparacion-tanda2.gif`.

---

## 1. Jugador: base (Blender, 70 animaciones)
**Locomoción (14):** quieto (3 variantes que se alternan), caminar, correr, correr rápido, agacharse y caminar agachado, saltar (inicio, aire, caer), doble salto (implante de columna), caída larga y aterrizaje fuerte (rodilla al piso), trepar, colgarse de un borde y subir, nadar (superficie y bajo el agua), deslizarse por una pendiente, volar quieto y volar avanzando (Origen Estelar y vuelo de gadget).

**Movilidad (8):** dash en 4 direcciones, rodar al caer, gancho: tirar, colgarse y balancearse (loop), soltarse y volar en el aire, planear con la capa.

**Defensa y daño (10):** bloqueo (inicio y loop), parry, bloqueo roto (se abre la guardia), recibir golpe liviano, fuerte y desde atrás, salir volando y caer, levantarse, aturdido (loop), derrota y reaparecer.

**Estilos de pelea (5 estilos × 6 = 30):** Puños, Espada, Bastón, Armas no letales y Gadgets. Cada estilo tiene combo de 4 golpes, golpe cargado y golpe en el aire. Cambia la pose de guardia del quieto y del correr.

**Interacción (8):** hablar con un NPC (loop), recoger del piso, abrir una puerta, usar una terminal o una computadora, sentarse (loop), subir y bajar de un vehículo, curarse con un botiquín, usar el teléfono (loop).

## 2. Cara y expresiones (Studio, 12)
Los ojos y la boca son texturas que se cambian por código: neutral, enojado, contento, sorprendido, dolor, concentrado (al cargar un poder), cansado y derrotado. Más parpadeo al azar (cada 3 a 6 s), mover la boca al hablar (sílabas al ritmo del texto) y mirar al que habla. Los NPCs usan las mismas.

## 3. Menús y pantallas (cuerpo en Blender, interfaz en Studio)
**Personaje en el menú (Blender, 8):** pose de héroe, pose de villano, pose de vigilante, pose neutral (una por bando), girar en la pantalla de trajes, mirarse las manos al ponerse un traje nuevo, festejo al ganar un traje y pose de "Espacio vacío" (silueta que respira).

**Creador de personaje (Blender, 4):** pose en T relajada para vestirlo, girar, probar el traje (estira los brazos) y aceptar (asiente).

**Ruleta de Linaje (Blender + Studio):**
- Cuerpo (5): espera nerviosa, y una reacción por rareza: Común (encoge los hombros), Poco común (puño chico), Raro (salta), Legendario o Mítico (cae de rodillas y el poder lo levanta).
- Interfaz: la ruleta frena despacio y rebota, un destello en el color de la rareza, y con Legendario o Mítico, eclipse grande y aviso a todo el servidor.

**Interfaz (Studio, unas 30):** botones (al pasar, apretar y bloqueado), ventanas que entran y salen (deslizar y desvanecer), barras de vida, energía y escudo (bajan con un rastro blanco que se va), recargas de Z X C V (se llenan en ronda), número de daño que salta, crítico más grande y en `corona`, subir de nivel (anillo de luz), punto de habilidad nuevo, nodos del árbol que se encienden de a uno, "???" que se revela con un brillo, máquina de escribir en los diálogos, eclipse del menú que late cada 4 s, aviso de "Buscado" (estrellas que caen) y noticias de El Faro (titular que entra rodando).

## 4. Poderes (Blender + efectos de Studio)
Cada Linaje lleva, de cuerpo y de efecto:
| Parte | Cuántas por Linaje |
|---|---|
| Habilidades Z, X y C | 3 |
| Habilidades de las 3 Variantes no Normales (2 cada una) | 6 |
| Definitiva V (después del Despertar), con versión de Despertar 2 | 2 |
| Pose de carga del poder (loop) y "aura" del Linaje al estar quieto | 2 |
| Despertar: escena corta en que el poder cambia de aspecto | 1 |
| **Total por Linaje** | **14** |

**12 Linajes × 14 = 168 animaciones de cuerpo**, cada una con su efecto.

| Linaje | Efecto (Studio) |
|---|---|
| Fuerza Bruta | Ondas de choque en el piso, grietas, piedras que saltan, cámara que tiembla |
| Reflejos | Estelas cortas detrás de los golpes, imagen fantasma en el dash |
| Piroquinesis | Fuego `eclipse` y `corona`, humo, brasas, piso quemado que se apaga en 3 s |
| Electro | Rayos que saltan entre puntos, chispas, destello azul |
| Criogenia | Hielo que crece en el piso, escarcha, cristales que se rompen |
| Telequinesis | Objetos que flotan con aura violeta, distorsión del aire |
| Velocista Cinético | Estela de luz en el camino, imágenes repetidas, viento |
| Sombra Viva | Humo negro, sombras que salen del piso, teletransporte en nube |
| Sangre Abisal | Agua, espuma, chorros, tentáculos de agua |
| Origen Estelar | Rayos de energía de los ojos y las manos, estrellas, aura dorada |
| Herencia Olímpica | Relámpagos dorados, armas de luz, escudo con forma de rayo |
| Eclipse | Luz y oscuridad a la vez: anillo de eclipse, rayos negros con borde `corona` |

**Técnicas combinadas (12):** una animación y un efecto propio cada una (Vapor, Plasma, Meteoro, Asesino fantasma, Tormenta en movimiento, Glaciar, Supernova, Sobrecarga y las secretas).

**Mutación de Variante (12):** escena corta, una por Linaje, cuando cumplís la condición secreta.

## 5. Tecnología, implantes y gadgets (Blender + Studio, 22)
- **Gadgets (8):** gancho, granada de humo, dron (lanzarlo y que vuelva), boomerang, red, linterna cegadora, escudo plegable y botiquín. Cada uno con animación de cuerpo y de objeto.
- **Implantes (6):** cañón del brazo (apuntar y disparar), puño hidráulico (pistones que se cargan y pegan), visión de puntos débiles (efecto de pantalla), visión nocturna (filtro), doble salto (columna con luz) y menos recarga (brillo en la columna).
- **Instalar implante (1):** escena en la camilla de la Dra. Kessler.
- **Taller (3):** fabricar en el banco, subir de nivel una pieza (Mk I a Mk V) y probarse el traje nuevo.
- **Transferencia de Linaje (1):** el fragmento flota y entra en el pecho.
- **Piezas que se mueven solas (3):** los pistones de Remache, el guantelete de Arquitecto y el cañón de Bastión, por código.

## 6. Vehículos (Studio + Blender, 10)
Autos de civiles y patrulleros (ruedas, luces, sirena), moto, el vehículo propio del jugador (subir, bajar, derrapar, chocar), barco del Albatros (balanceo) y grúa del puerto. El cuerpo del conductor usa "sentado manejando" y "salir a los tiros" (Blender, 3).

## 7. NPCs con nombre (Blender, 7 × 6 = 42)
Comisaria Rivas, Lucía Vega, Tano, Ingeniera Okafor, Dra. Kessler, Directora Brandt y Señal. Cada uno tiene: tarea propia (loop), saludar, hablar (loop), contento, enojado y una reacción especial (Rivas golpea la mesa, Vega saca una foto, Tano tira la llave, Okafor se acomoda los lentes, Kessler se saca los guantes, Brandt corta la llamada y Señal se saca los auriculares).

## 8. Calle viva (Blender, unas 45)
Ya están listadas en [[P29b Animaciones de la calle viva]]: civiles (caminar con bolsa, con teléfono, asustarse, huir, llamar a la policía, filmar, aplaudir, agacharse, el valiente), policía (patrullar, gritar "alto", correr, esposar, escudo), jugador en crímenes (esposado, rendirse, cargar botín, taladrar, hackear, intimidar, carterista, forzar puerta, máscara) y pandillas. Se suman:
- **Civiles (6):** charlar de a dos (loop), comprar en un puesto, sacar foto a un héroe, pedir autógrafo, señalar al buscado y pasear al perro (con el perro, 2).
- **Vida de la ciudad (por código):** semáforos, carteles de neón que parpadean, lluvia y charcos, vapor de alcantarillas, palomas que se vuelan, puertas automáticas y persianas de negocios.

## 9. Enemigos comunes (Blender, 7 × 8 = 56)
Matón del puerto, matón con implantes, dron Corona, robot centinela, preso fugado, soldado de Umbra y criatura abisal. Cada uno: quieto, patrullar, perseguir, 2 ataques (con Aviso), recibir golpe, aturdido y derrota. Los **enemigos de élite** usan las mismas, con un efecto encima según su modificador (Rápido: estela; Blindado: brillo de metal; Explota al morir: parpadeo rojo; Invoca drones: antena).

## 10. Jefes (Blender + efectos, 9 × 12 = 108)
Remache, El Albatros, Mascarada, Víctor Halden, Dualidad, Zarpa, Confeti, Cuervo y Centinela Solar (cuando pelean contra el jugador) y El Eclipsador. Cada jefe tiene: entrada (presentación con nombre en pantalla), quieto amenazante, caminar, 3 ataques (con Aviso), cambio de fase, ataque nuevo de la fase 2, recibir golpe fuerte, aturdido, derrota y "rendirse o huir" (según la decisión de la historia). Los ataques están en [[P28 Animaciones de un jefe]]. Mascarada tiene además un cambio de máscara por fase.

## 11. Héroes y villanos del elenco como NPC (Blender, 16 × 4 = 64)
Los 16 personajes del [[Sobre DC]] aparecen como NPCs en la ciudad y en la historia: quieto con su pose propia, hablar, aparecer en escena (Cuervo baja de un techo, Centinela aterriza, Estela frena derrapando, etc.) e irse.

## 12. Escenas de historia (Blender + cámara en Studio, 15)
> [!note] Todas las cinemáticas (entrar, salir, jefes, NPCs, poderes, historia y eventos) están ahora en [[Cinemáticas (plan completo)]], que manda sobre esta sección.

Prólogo "La Noche del Eclipse" (6 inicios distintos, 1 escena cada uno), el eclipse que despierta los poderes, entrada a cada ciudad (3), final de cada acto (6), Renacer y los 3 finales por bando (se arman con animaciones que ya existen más cámaras por código). La cámara de cada escena se mueve por código (`src/client/escenas/`).

## 13. Mundo y objetos (Studio, unos 25)
Objetos para juntar (giran, suben y bajan, columna de luz), puertas, ascensores, persianas, cofres de botín, cajas fuertes de los atracos (taladro que gira, chispas), barreras de policía, grúas y contenedores del puerto, faro de El Faro (luz que gira), torre del reloj (agujas), cámaras de seguridad (giran y te siguen), banderas de territorio (cambian de color al conquistar), eventos de servidor (Apagón: luces que se van apagando; Lluvia de esquirlas: esquirlas que caen; Invasión de Umbra: portal), y la base propia (trofeos que giran).

## 14. Efectos especiales generales (Studio, unos 30)
Golpe que conecta (chispa y aplastamiento chico), crítico, bloqueo y parry (chispa de metal), hit-stop (el golpe se congela 0,05 s), sacudida de cámara en 3 fuerzas, zona roja de Aviso en el piso, curarse, subir de nivel, Despertar (columna de luz en el color de la rareza), aparecer y reaparecer, teletransporte, polvo al aterrizar, salpicadura en charcos, huellas en el agua (nada de sangre: los golpes sacan chispas, para que sea apto para todo público), vapor de los pistones, humo de granada, explosión chica y grande, fuego que se apaga, vidrios que se rompen y destellos de las cámaras de fotos.

---

## Total aproximado
| Grupo | Animaciones |
|---|---|
| Cuerpo en Blender | **unas 650** |
| Efectos de Studio | **unos 230** (uno por poder + generales) |
| Objetos e interfaz de Studio | **unos 70** |

## En qué orden (sigue los prompts)
1. [[P20f Cuerpo propio del jugador]] (el cuerpo y las caras, antes que cualquier animación).
2. [[P26 Animaciones base del jugador]]: secciones 1, 2 y 3 de esta nota.
3. [[P27 Animaciones de los 3 primeros Linajes]]: sección 4, de a 3 Linajes por sesión. Después las técnicas combinadas.
4. [[P26b Animaciones de tecnología, gadgets y vehículos]]: secciones 5 y 6.
5. [[P29 Animaciones de NPCs y enemigos]]: secciones 7, 9 y 11.
6. [[P29b Animaciones de la calle viva]]: sección 8.
7. [[P28 Animaciones de un jefe]]: sección 10, un jefe por sesión.
8. [[P30 Animaciones de objetos]] y [[P30b Efectos especiales e interfaz]]: secciones 2, 3 (interfaz), 13 y 14.
9. Las cinemáticas van en [[P30c Cinemáticas]], después de las animaciones y los sonidos (ver [[Cinemáticas (plan completo)]]).

Volver a [[Ficha del juego]]

---

## Hechas

### P26-01 Locomoción del jugador (1 nov, APROBADA y publicada)
12 animaciones de cuerpo a 30 fps sobre el R15 del [[Cuerpo propio (sin avatar de Roblox)]], hechas con `linajes/arte/scripts/animaciones/base.py` (una Action cada una en `linajes/arte/blender/animaciones-base.blend`).

| Animación | Cuadros | Loop | Prioridad | Qué hace |
|---|---|---|---|---|
| quieto | 60 | sí | Core | respira lento, hombros +0,03 studs, peso en la pierna izquierda, mira a un costado y al otro |
| caminar | 32 | sí | Movement | paso firme, brazos opuestos, torso ±3° (marcador `Paso`) |
| correr | 20 | sí | Movement | torso 15°, codos a 90°, rodillas altas (`Paso`) |
| correr-rapido | 14 | sí | Movement | torso 30°, brazos rectos atrás: Velocista y Reflejos (`Paso`) |
| saltar-inicio | 8 | no | Movement | se agacha y empuja con los brazos |
| saltar-aire | 20 | sí | Movement | rodillas arriba, brazos abiertos |
| saltar-caer | 10 | no | Movement | amortigua y se para (`Paso` en el cuadro 3) |
| trepar | 24 | sí | Movement | de frente a la pared, torso 8° hacia ella; manos contra la pared al ancho de los hombros: la de arriba se agarra, la de abajo tira con el codo pegado hasta el pecho; sube la rodilla contraria. Chequeado por script: ninguna mano entra en la cabeza |
| volar-quieto | 60 | sí | Movement | flota casi parado, sube y baja; brazos y piernas siguen con atraso (manos abiertas) |
| volar-avanzando | 30 | sí | Movement | cuerpo horizontal, los dos brazos atrás pegados al cuerpo, balanceo de costado de 7° y piernas que ondulan (pose propia, sin puño adelante) |
| nadar | 40 | sí | Movement | crol con patada |
| flotar | 60 | sí | Movement | brazos y piernas en ochos lentos |

Cada fila de la hoja son 2 animaciones, 3 cuadros cada una (inicio, pose máxima, recuperación), en el orden de la tabla:

![[anim-base-hoja.png]]

**En movimiento** (GIFs en loop, 15 cuadros por segundo; el personaje anima en el lugar, el avance lo pone el juego):

![[anim-base-quieto.gif]] ![[anim-base-caminar.gif]] ![[anim-base-correr.gif]] ![[anim-base-correr-rapido.gif]]
![[anim-base-saltar-inicio.gif]] ![[anim-base-saltar-aire.gif]] ![[anim-base-saltar-caer.gif]] ![[anim-base-trepar-atras.gif]] ![[anim-base-trepar-costado.gif]]
![[anim-base-volar-quieto.gif]] ![[anim-base-volar-avanzando.gif]] ![[anim-base-nadar.gif]] ![[anim-base-flotar.gif]]

Publicadas en Roblox (IDs en `Config.Animaciones.base`). FBX en `linajes/arte/animaciones/base/`; en Studio se armaron como KeyframeSequence con `arte/scripts/animaciones/roblox.py` (mismas poses). Probado sobre el Dummy de `workspace.PruebasAnim`: cargan las 12 y el marcador `Paso` llega al código.

Pendiente: conectarlas al Animate del cuerpo propio (hoy usa las de Roblox) y probar que los pies no patinen al caminar y correr (se ajusta la velocidad de la animación a la WalkSpeed).

### P26-02 Combate del jugador (Puños) (1 nov, APROBADA y publicada con las correcciones de la cuarta vuelta)
17 animaciones a 30 fps, mismo script y mismo `.blend` que la locomoción. Todas salen de la **guardia** y vuelven a ella: pierna izquierda adelante, rodillas bien flexionadas, codos pegados al cuerpo (cuidan las costillas), puños a la altura del mentón y la cabeza apenas agachada detrás. Se muestran **de espaldas** (un poco corridas a la derecha), como las ve el jugador con la cámara del juego. El script revisó cuadro por cuadro: ninguna mano entra en la cabeza.

| Animación | Cuadros | Loop | Marcador | Qué hace |
|---|---|---|---|---|
| golpe-1 | 14 | no | Impacto 6 | jab derecho: carga 0-4, estira, vuelve 7-14; los pies no se mueven (gira solo el torso) y el peso pasa al pie de adelante |
| golpe-2 | 14 | no | Impacto 6 | cross izquierdo, más fuerte que el jab: cadera girada 48° y hombros 25° más, brazo entero estirado, peso al pie de adelante, pies en guardia |
| golpe-3 | 18 | no | Impacto 8 | se agacha bien (rodillas dobladas, puño bajo) y explota hacia arriba con el gancho derecho; pies en guardia |
| golpe-4 | 24 | no | Impacto 12 | carga 0-8, gira hacia su derecha y patea con la derecha; en el impacto la pierna apunta al rival (medido: 86 % hacia adelante y 50 % hacia arriba); cae en guardia |
| golpe-aire | 22 | no | Impacto 12 | ataque desde arriba: se estira en puntas de pie con los puños arriba y cae con todo, rodillas bien dobladas, torso adelante y puños cerca del piso |
| bloqueo-inicio | 4 | no | — | sube los antebrazos |
| bloqueo | 30 | sí | — | más agachado que la guardia, cabeza escondida, codos juntos y antebrazos verticales cruzados delante de la cara; respira |
| parry | 12 | no | Impacto 3 | corto y seco: en 3 cuadros los dos antebrazos empujan afuera y adelante con medio paso adelante, aguanta hasta el 5 y vuelve a la guardia |
| dash-adelante / atras / izquierda / derecha | 8 c/u | no | — | se inclina hacia donde va, sin pasos |
| golpe-liviano | 10 | no | — | la cabeza y el torso se van para atrás |
| golpe-fuerte | 18 | no | — | lo empujan, abre los brazos, retoma agachado |
| aturdido | 40 | sí | — | cabeza en círculos lentos, el cuerpo se mece de lado a lado, rodillas que se aflojan, brazos colgando |
| derrota | 40 | no | — | tambalea, cae de rodillas y queda en cuatro patas |
| levantarse | 30 | no | — | de cuatro patas a una rodilla y a la guardia: dura 1 s (30 cuadros); el GIF también dura 0,94 s, si se ve más lento es el visor |

Prioridad en Roblox: Action en todas. La guardia en 3 vistas (frente, costado y espalda):

![[anim-base-guardia.png]]

Una animación por fila, con su nombre a la izquierda (3 cuadros: anticipación, impacto o pose máxima, recuperación):

![[anim-base-hoja-combate.png]]

**En movimiento, de espaldas a 30 fps** (como la cámara del juego):

![[anim-base-golpe-1-atras.gif]] ![[anim-base-golpe-2-atras.gif]] ![[anim-base-golpe-3-atras.gif]] ![[anim-base-golpe-4-atras.gif]]
![[anim-base-golpe-aire-atras.gif]] ![[anim-base-bloqueo-inicio-atras.gif]] ![[anim-base-bloqueo-atras.gif]] ![[anim-base-parry-atras.gif]]
![[anim-base-dash-adelante-atras.gif]] ![[anim-base-dash-atras-atras.gif]] ![[anim-base-dash-izquierda-atras.gif]] ![[anim-base-dash-derecha-atras.gif]]
![[anim-base-golpe-liviano-atras.gif]] ![[anim-base-golpe-fuerte-atras.gif]] ![[anim-base-aturdido-atras.gif]] ![[anim-base-derrota-atras.gif]]
![[anim-base-levantarse-atras.gif]]

Publicadas en Roblox (IDs en `Config.Animaciones.base`, de `Golpe1` a `Levantarse`). FBX en `linajes/arte/animaciones/base/`. Probado sobre el Dummy: cargan las 29 animaciones base y el marcador `Impacto` llega al código (Golpe 4 a los 0,40 s, Parry a los 0,12 s).

### P26-03 Interacción del jugador (1 nov, segunda vuelta, esperando OK)
5 animaciones a 30 fps, mismo script y `.blend`. Salen de la pose parada (el cuadro 0 de `quieto`) y vuelven a ella. Ninguna mano entra en la cabeza. Las referencias de Gemini (`anim-interaccion/`) no estaban: se hicieron sin ellas.

| Animación | Cuadros | Loop | Marcador | Qué hace |
|---|---|---|---|---|
| hablar | 60 | sí | — | antebrazos arriba, las manos explican una y después la otra; la cabeza asiente dos veces |
| recoger | 27 (0,9 s) | no | Agarrar 13 | se agacha flexionando las rodillas con la espalda casi derecha, la mano derecha llega al piso (10), agarra (13) y se para con el objeto contra el pecho |
| banco | 48 | sí | — | la izquierda sostiene la pieza sobre el banco y la derecha martilla 3 veces (golpes en 10, 20 y 30); pausa corta mirando la pieza de cerca (36-44) |
| celebrar | 40 | no | — | se agacha cargando el puño y lo sube bien arriba (14-28), vuelve parado |
| saludar | 30 | no | — | brazo derecho bien abierto al costado y arriba; la mano va de un lado al otro 3 veces. Chequeo de cruces con el brazo entero: nada toca la cabeza |

Prioridad en Roblox: Action. Una por fila (anticipación, pose máxima, recuperación):

![[anim-base-hoja-interaccion.png]]

**Las corregidas en movimiento** (3/4 adelante y de atrás, 30 fps):

![[anim-base-recoger-frente.gif]] ![[anim-base-recoger-atras.gif]]
![[anim-base-banco-frente.gif]] ![[anim-base-banco-atras.gif]]
![[anim-base-saludar-frente.gif]] ![[anim-base-saludar-atras.gif]]

### P27-02 Animaciones de Reflejos (7 nov, APROBADA y publicada)

Rápidas y livianas, al revés que Fuerza Bruta. Hechas con `linaje-reflejos.py`, en `animaciones-linajes.blend`.

| Animación | Cuadros | Loop | Marcadores | Qué hace |
|---|---|---|---|---|
| reflejos-contragolpe | 18 | no | `Impacto` 8 | manotazo afuera y gancho corto; cadera fija a 20-24°, torso gira hasta 57° |
| reflejos-paso-fantasma | 9 | no | `Desaparece` 3, `Aparece` 6 | se agacha y reaparece en guardia; el efecto lo pone el código |
| reflejos-lluvia-golpes | 30 | sí | `Impacto` 3, 8, 13, 18, 23, 28 | 6 piñas por segundo, brazos estirados, torso gira con cada golpe |
| reflejos-cargar-inicio | 8 | no | no | entra al rebote |
| reflejos-cargar-loop | 30 | sí | no | rebota en las puntas (±0,1 studs), puños sueltos, cabeza atenta |

El avance de Lluvia de golpes lo tiene que hacer el código: la animación solo inclina el cuerpo.

![[anim-linaje-reflejos-hoja.png]]

![[anim-linaje-reflejos-contragolpe-atras.gif]] ![[anim-linaje-reflejos-paso-fantasma-atras.gif]] ![[anim-linaje-reflejos-lluvia-golpes-atras.gif]] ![[anim-linaje-reflejos-cargar-loop-atras.gif]]

### P27-03 Animaciones de Piroquinesis (7 nov, APROBADA y publicada)

Plantado y a distancia. Hechas con `linaje-piroquinesis.py`, en `animaciones-linajes.blend`.

| Animación | Cuadros | Loop | Marcadores | Qué hace |
|---|---|---|---|---|
| piroquinesis-bola-fuego | 30 | no | `Enciende` 7, `Lanza` 12 | una mano: brazo atrás y lanza con el giro del torso |
| piroquinesis-chorro-inicio | 6 | no | `Enciende` 6 | dos palmas adelante |
| piroquinesis-chorro-loop | 30 | sí | no | se resiste hacia atrás y tiembla |
| piroquinesis-chorro-fin | 9 | no | no | vuelve a la guardia |
| piroquinesis-muro-fuego | 40 | no | `Impacto` 18 | aprobado: clava la palma derecha |
| piroquinesis-cargar-inicio | 10 | no | no | entra a la carga |
| piroquinesis-cargar-loop | 54 | sí | no | llama entre las manos, dos respiraciones de 0,9 s, balanceo de ±6° |

![[anim-linaje-piroquinesis-hoja.png]]

![[anim-linaje-piroquinesis-bola-fuego-atras.gif]] ![[anim-linaje-piroquinesis-chorro-inicio-atras.gif]] ![[anim-linaje-piroquinesis-chorro-loop-atras.gif]] ![[anim-linaje-piroquinesis-chorro-fin-atras.gif]] ![[anim-linaje-piroquinesis-cargar-loop-atras.gif]]

### P28-01 Animaciones de Remache (7 nov, esperando OK de Juani)

12 animaciones en `animaciones-remache.blend`, hechas con `remache.py`. Carga hidráulica en 3 piezas. `Aviso` 12 cuadros antes de cada `Impacto`.

![[anim-jefe-remache-hoja.png]]

Ajustes del 7 nov: preparaciones de 0,8 s con `Aviso` al inicio, caminar de 64 cuadros, carrera con ariete, cambio de fase con golpe al pecho y pausa. La altura sale de medir las botas en cada pose.

![[anim-jefe-remache-jugador-martillazo.gif]] ![[anim-jefe-remache-jugador-carga.gif]] ![[anim-jefe-remache-jugador-contenedor.gif]] ![[anim-jefe-remache-jugador-cambio-fase.gif]]
