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
Los 16 personajes del [[Elenco]] aparecen como NPCs en la ciudad y en la historia: quieto con su pose propia, hablar, aparecer en escena (Cuervo baja de un techo, Centinela aterriza, Estela frena derrapando, etc.) e irse.

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
