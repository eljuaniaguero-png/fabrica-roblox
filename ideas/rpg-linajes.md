# Herederos del Eco (nombre provisorio) — ficha del RPG

Pedido de Juani (30/10/2026): "algo estilo Bloodlines y Blox Fruits, pero un poco más narrativo y con combate en tiempo real. Con árbol de habilidades, evoluciona, aleatoriedad, etc."
Estado: **borrador, esperando el OK de Juani (punto de control 1).**
Carpeta (cuando se apruebe): `herederos/` (código en `herederos/src/`, Rojo con `rojo serve herederos`).

De esos juegos se toma **la mecánica, no el contenido**: nada de sus nombres, frutas, clanes, personajes, islas ni estilo de anime. Todo lo de abajo es propio.

## Qué tomamos de cada uno

| Mecánica de moda | Cómo entra acá |
|---|---|
| Linaje al azar al empezar (con rarezas) | **Eco**: un poder heredado que te toca al azar al crear el personaje. Da un bono pasivo y una habilidad propia |
| Poder que se encuentra en el mundo y define tu forma de pelear | **Núcleos**: cristales elementales que sueltan jefes y cofres. Te equipás uno y te da 4 habilidades |
| Subir de nivel haciendo misiones en islas cada vez más difíciles | **Capítulos**: cada isla es un capítulo de la historia con su jefe |
| Maestría que desbloquea habilidades | **Árbol de habilidades** por Núcleo, que se llena usándolo |
| Despertar / evolucionar el poder | **Evolución** del Núcleo en 3 etapas, con cambio de aspecto |
| Combate de acción | **Tiempo real**: combo, 4 habilidades, esquive y bloqueo |

Lo que lo hace distinto: **la historia**. Cada isla es un capítulo con personajes que hablan, decisiones chicas y un jefe que tiene que ver con la trama. Tu Eco tiene un pasado que se va descubriendo.

## Historia (base)

El mundo es un archipiélago que se partió hace siglos. Los que tienen un **Eco** llevan adentro el recuerdo de un guerrero antiguo. Despertás en la isla de inicio sin memoria, con tu Eco recién activado, y una guardiana te pide ayuda porque los **Vacíos** (monstruos sin recuerdos) están borrando las islas.

- Cada capítulo: llegás a una isla, conocés a 2–3 personajes, hacés 5–8 misiones, descubrís un pedazo del pasado de tu Eco y peleás contra el jefe.
- Diálogos con caja de texto y 2 respuestas en momentos clave (cambian una recompensa o un diálogo, no la historia entera; más simple de hacer).
- Fragmentos de memoria escondidos en el mapa: cuentan la historia del mundo y dan puntos de habilidad.

## El personaje (3 capas)

1. **Eco (al azar, al crear el personaje).** Rarezas: Común 60 %, Raro 28 %, Épico 10 %, Legendario 2 %. Cada Eco da un pasivo (ej.: +10 % de velocidad) y una habilidad única (tecla F).
2. **Núcleo (lo que encontrás).** 4 habilidades (teclas Z X C V). Se cambia cuando querés. Primeros elementos: Llama, Marea, Trueno, Sombra (6 en total al final).
3. **Arma o estilo (lo que elegís).** Puños, espada o lanza: cambia el combo básico (clic). Se mejora con la herrería.

## Combate en tiempo real

- **Clic**: combo de 4 golpes. El cuarto empuja.
- **Z X C V**: habilidades del Núcleo, con tiempo de recarga y costo de energía.
- **F**: habilidad del Eco (recarga larga, efecto fuerte).
- **Q**: esquive con invulnerabilidad corta (cuesta aguante).
- **Bloqueo** (mantener una tecla): reduce el daño; bloquear justo a tiempo **desarma** al enemigo un momento (parry).
- En celular: botones grandes a la derecha (como los de los juegos de acción populares de Roblox).
- El servidor decide todo: daño, distancia, recargas y si el golpe acertó.

## Árbol de habilidades

- Cada Núcleo tiene su árbol con ~12 nodos en 3 ramas (ej. Llama: **Brasa** = daño en el tiempo, **Erupción** = área, **Fénix** = curación y supervivencia).
- Los puntos salen de usar ese Núcleo (maestría), de subir de nivel y de los fragmentos de memoria.
- Se puede reiniciar el árbol gratis una vez y después con oro del juego.
- El nivel del personaje (1 a 100 en el primer lanzamiento) sube la vida y desbloquea islas.

## Evolución

- Cada Núcleo evoluciona 2 veces: **Despierto** (maestría 100) y **Ascendido** (maestría 300 + objeto del jefe del capítulo).
- Al evolucionar: las habilidades cambian de aspecto, una se reemplaza por una nueva más fuerte y el personaje cambia de aura.
- El Eco también evoluciona una vez, al terminar su historia personal (misión especial en el capítulo 3).

## Aleatoriedad (y sus reglas)

- **Eco al azar** al crear el personaje. Se puede volver a tirar con **Piedras de Eco**.
- **Núcleos al azar**: los jefes y los cofres de las islas sueltan un Núcleo según una tabla con probabilidades.
- **Botín de equipo** con rarezas y una propiedad extra al azar.
- **Regla (de `ideas/monetizacion.md`): nada al azar se paga con Robux.** Las Piedras de Eco y el oro **solo se ganan jugando** (misiones, jefes, recompensa diaria) y **nunca se venden por Robux**. Igual se muestran las probabilidades en % en cada tirada, con un botón "Ver probabilidades".
- Protección contra la mala suerte: cada 30 tiradas sin un Épico o mejor, la siguiente es Épico seguro.

## Mapa del primer lanzamiento

| Isla | Capítulo | Nivel | Jefe |
|---|---|---|---|
| Isla del Despertar | Prólogo (tutorial, 5 min) | 1–10 | Vacío Guardián |
| Bosque de Cenizas | Capítulo 1 | 10–30 | Por definir en la ficha del capítulo |
| Puerto Sumergido | Capítulo 2 | 30–60 | Por definir |
| Ciudadela Rota | Capítulo 3 | 60–100 | Por definir |

Entre islas se viaja con un bote o un portal (lo más simple: portal desbloqueado al ganarle al jefe).
Las islas se arman **por código** (como el generador de Pisada Sonora), así el mapa vive en git.

## Prototipo jugable (lo primero que construyo)

Solo el **prólogo y el capítulo 1**, para probar si el combate engancha:

1. Personaje con Eco al azar (3 Ecos de prueba) y pantalla de tirada con probabilidades.
2. Combate: combo, esquive, bloqueo con parry, 1 Núcleo (Llama) con 4 habilidades.
3. 3 tipos de enemigo + el jefe del prólogo.
4. Misiones con diálogos (5 misiones de prólogo).
5. Árbol de Llama con 6 nodos y la primera evolución (Despierto).
6. Guardado con ProfileStore (copiado de `archivo/plinko-knight/src/server/Guardado.luau`).
7. Interfaz para computadora y celular.

Después: el segundo Núcleo, el capítulo 1 completo, PvP opcional.

## Monetización (borrador, según `ideas/monetizacion.md`)

- Pases: XP x2 (149), Lugares extra de Núcleo guardado (149), VIP (399, aura y etiqueta + 10 % de oro).
- Cosméticos: auras, colores de habilidades, ropa (25 a 199).
- **No se vende**: Piedras de Eco, Núcleos, oro ni nada al azar.

## Decisiones que tomé solo (cambialas si querés)

- Nombre provisorio "Herederos del Eco".
- Primero solo contra monstruos (PvE); el PvP queda para después del prototipo.
- Estilo visual: se elige después de aprobar la ficha (3 propuestas, como siempre).
