---
tags: [ficha, revision]
---
# Riesgos y mejoras (revisión del 31 oct)

Juani pasó una revisión hecha con Gemini. Claude la comparó con las reglas del proyecto. Lo que está en **Se hace** pasa a ser parte del juego. Lo de **Lo decidís vos** espera el OK de Juani. Lo de **No se hace** choca con una regla.

## Se hace

### Mundo abierto y reputación
| Riesgo | Qué se hace |
|---|---|
| **Salir del juego para escapar de la policía** (cambiarse de servidor con búsqueda 5) | Si cerrás el juego en pelea o con búsqueda activa, tu personaje se queda **10 s** en el servidor. Si te derrotan en ese tiempo, o si volvés con la búsqueda sin cumplir, aparecés en las celdas de **Islaroca**. |
| **Un bando se queda con todos los barrios** (efecto bola de nieve) | El bando que tiene menos barrios gana **más reputación y botín** al disputar uno dominado (hasta +50 %). Si un bando tiene más del 60 % de los jugadores, los bonos de su barrio bajan. Cambiarse de bando cuesta reputación y tiene espera de 7 días. |
| **Escapar de Islaroca solo** | Siempre se puede escapar solo (más lento o más riesgoso). Que otro jugador te ayude acelera, pero nunca es obligatorio. |
| **Guardar tanta cosa** (5 reputaciones, confianza con NPCs, refugio, barrios entre servidores) | Un solo perfil por jugador con ProfileStore (guardado cada 5 min y al salir). Los barrios se cuentan entre servidores con **MemoryStore** y se pasan al DataStore cada pocos minutos. Nunca se guarda en cada golpe ni en cada paso. |

### Combate y sensación de golpe
- **Golpes sin demora:** el cliente muestra el efecto (chispa, sacudida, hit-stop) al instante, y el servidor revisa la distancia, el estado y la recarga antes de aplicar el daño real. Ya estaba en [[Combate]]; ahora se suma el efecto inmediato.
- **Cola de teclas de 0,15 s:** si apretás dash o golpe sobre el final de una animación, se ejecuta apenas termina. Así no se siente rígido.
- **Golpe que rompe la guardia:** sacudida corta y seca más hit-stop de 0,05 s en los dos personajes.

### Celular (más del 70 % de los jugadores)
- **Un solo botón de acción** que cambia según dónde estés (Hablar, Abrir, Frenar el crimen, Subir). Así no se llena la pantalla de botones.
- Sombras apagadas en objetos chicos (farolas, tachos, barandas). Los carteles de neón usan material Neon sin luz aparte.
- Interiores con `ModelStreamingMode` que solo se cargan al entrar.
- **Meta: 45 FPS o más** en un celular de gama media con 24 jugadores. Si los efectos de un Linaje bajan de eso, se simplifican.

### Los primeros 10 minutos
- Antes del **minuto 5**, el jugador nuevo tiene que haber peleado en la calle y visto su poder. El prólogo de [[Poderes, inicio y personalización]] se mide con `AnalyticsService` (embudo de 10 pasos) antes de publicar.

### Motivos para volver cada día
- **Edición del día de El Faro:** cada mañana sale un diario con 1 contrato diario, el estado de los barrios y 2 o 3 avisos con hora ("asalto al banco del puerto en 15 minutos"). Premia entrar 2 o 3 veces al día en partidas cortas.
- **Taller con tiempo:** en el refugio, el banco fabrica gadgets o refina chatarra en **2 a 4 horas**, aunque no estés conectado. Volvés a buscarlo y a cargar otro.

### Modelos (sobre los 4 trajes que ya están)
- Capas y piezas que cuelgan: `CanCollide`, `CanTouch` y `CanQuery` apagados.
- Cuervo y Mascarada: `Attachment` limpios en cadera y manos para enganchar gadgets y naipes por código.
- Plumas de la capa de Cuervo: revisar al animar que no parpadeen (piezas encimadas) ni se muevan como un bloque. Se resuelve con buenos pesos en los huesos.
- Pliegues de las telas: siempre horneados en el normal map, nunca con más polígonos. Ya lo dice el [[Nivel de detalle]].

## Lo decidís vos
| Propuesta | Qué opina Claude |
|---|---|
| **Beta de pago** (Paid Access de 350 a 400 Robux) y después gratis | Puede servir para juntar plata con poca gente y filtrar tramposos. El riesgo es que, con pocos jugadores, los servidores de 24 se ven vacíos y el mundo abierto no luce. Antes de decidir hay que revisar las reglas actuales de Roblox para el acceso pago (requisitos de la cuenta y cuánto se lleva Roblox). |
| **Pack de fundador** (150 Robux: título "Fundador", color de traje, espacio extra) | Va bien con [[Plan por etapas]] y con la regla de vender solo lo que no da poder. |
| **Vender el 2.º y 3.er espacio de personaje** | Hoy la ficha dice que los 3 espacios son gratis. Venderlos da plata y no rompe la pelea, pero es un cambio de diseño. Sugerencia: el 2.º gratis y el 3.º pago. |
| **Compras que activan un evento para todo el servidor** ("Llamado de emergencia", 20 minutos) | Buena idea: el que paga gana reconocimiento y todos juegan el evento. Con límite de una cada 30 minutos por servidor. |
| **Primera versión solo con Puerto Óxido** (2 Linajes, Remache, Tano y el Albatros) | Coincide con hacer el juego por etapas. Es la forma más rápida de tener algo para mostrar y probar. |

## No se hace
- **Ruleta de cosméticos con Robux** (auras o colores al azar pagando): es una caja de botín paga y CLAUDE.md la prohíbe. Los cosméticos se venden **directo**, viendo qué comprás. Las auras de Linaje especiales se ganan jugando o se compran sin azar.
- **Los números de jugadores y de plata de la revisión** (de 12.000 a 30.000 jugadores a la vez el primer mes): son el caso de los juegos más exitosos de Roblox, no lo esperable. La cuenta realista está en el mensaje de Claude del 31 oct y en [[Plan por etapas]].

Volver a [[Ficha del juego]]
