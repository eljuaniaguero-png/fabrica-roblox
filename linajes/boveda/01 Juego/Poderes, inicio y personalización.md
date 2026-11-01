---
tags: [ficha, poderes]
---
# Poderes, inicio y personalización

> [!summary] En tres líneas
> Cada jugador se arma **su propio** héroe o villano: el elenco son NPCs. Tu poder (Linaje) te toca en una ruleta la Noche del Eclipse, muta en Variantes secretas, evoluciona en 2 Despertares y puede sumar un segundo poder. **El juego no te explica lo que elegís**: se descubre jugando.

> [!info] Dónde está cada detalle
> Cada Linaje (habilidades con números, Variantes, Despertar, movimiento): [[Linajes]] y sus 12 notas. Estadísticas y puntos: [[Estadísticas y movimiento]]. Los inicios: [[Los 6 orígenes]]. Esta nota explica **las reglas generales**.

## Quién es quién
- **El elenco (Cuervo, Centinela Solar, Mascarada…) son NPCs**: dan misiones, entrenan, pelean con vos o contra vos, y algunos son jefes. Ver [[NPCs]].
- **Vos te armás tu personaje desde cero**: cuerpo, traje, emblema, nombre, poderes y bando. Nadie juega "de Cuervo".
- Con Confianza 500 con un NPC ganás una **pieza de traje inspirada** en él (la capa de plumas, la corona solar) para mezclar en tu traje.

## Cómo conseguís tus poderes
1. **Creás tu personaje** con ropa de civil (ver Personalización).
2. **Origen al azar**: dónde estabas la Noche del Eclipse. 6 inicios, 2 por ciudad, cada uno con su tarea corta, su primer NPC y una ventaja chica de arranque. Detalle en [[Los 6 orígenes]]. En la Beta solo está el **Estibador**.
3. **El Eclipse cae**: una esquirla te atraviesa, te desmayás y despertás con un NPC al lado.
4. **La ruleta** te da tu **Linaje** (probabilidades siempre a la vista). Empezás con su **Variante Normal** y **sin Rasgos**.
5. **Primera pelea** antes del minuto 5. Elegís bando más adelante, nunca al principio.

## Las partes de un poder
| Parte | Qué es | Cómo se consigue | Cuántas |
|---|---|---|---|
| **Linaje** | El tipo de poder | Ruleta: Común 55 %, Poco común 28 %, Raro 12 %, Legendario 4 %, Mítico 1 %; seguro cada 40 tiradas | 1 al empezar, 2 al final |
| **Variante** | Cómo se manifiesta; abre 2 habilidades propias | Todos arrancan con la Normal; las otras 3 por **condición secreta** (lugar + acción + a veces un Catalizador) | 4 por Linaje, una puesta a la vez |
| **Rasgo** | Modificador chico con un costo | **Sale de cómo jugás** (no se tira) | 1 en cada Despertar y cada 10 niveles |
| **Rama** | En qué se convierte tu poder | **Despertar 1** (nivel 25): elegís 1 de 2, **a ciegas** | 1 decisión por personaje |
| **Chips de técnica** | Cambian una habilidad (más proyectiles, rebotan, dejan charco) | Caen de jefes y eventos | 2 por habilidad equipada |
| **Segundo poder** | Otro Linaje completo | **Despertar 2** (nivel 60) por 1 de 3 caminos | 1 |
| **Técnica combinada** | Habilidad única de 2 Linajes compatibles (tecla B) | Automática con la combinación | 1 por combinación |

Las Variantes, las ramas y las técnicas de **cada** Linaje están en su nota (ver [[Linajes]]).

## La regla de oro: no se explica, se descubre
- Ramas, caminos al segundo poder, decisiones de historia y Rasgos se muestran **solo con un nombre, un símbolo y una frase misteriosa** del NPC. Nada de números ni descripciones.
- Una habilidad o Rasgo nuevo aparece como **"???"** hasta que lo usás por primera vez.
- Toda decisión que no se puede deshacer avisa eso, y nada más.
- Los NPCs dan **pistas a medias** si les preguntás; El Faro publica rumores sobre Variantes. Así la comunidad descubre las cosas de a poco.

## Rasgos: salen de cómo jugás
El juego anota estadísticas de tu partida y, en cada Despertar y cada 10 niveles, te da el Rasgo que más se ganó tu forma de jugar. No se tiran ni se re-tiran. La lista completa (30) vive en `Config.luau`.

| Si hacés mucho esto | Rasgo que te sale |
|---|---|
| Muchos dash y esquives | Pies ligeros (dash más largo) |
| Muchos parry | Precisión (crítico tras parry) |
| Ganás peleas con poca vida | Calle (más daño con poca vida) |
| Jugás de noche (hora del juego) | Nocturno |
| Muchos trabajos de mecánico o laboratorio | Mente técnica (implantes cuestan menos) |
| Ayudás en muchos crímenes al azar | Protector (aliados cerca reciben menos daño) |
| Ayudás a los criminales | Despiadado (más daño a enemigos aturdidos) |
| Usás mucho una sola habilidad | Especialista (esa habilidad +15 %) |
| Usás todas parejo | Versátil (recargas −8 %) |
| Te derrotan mucho | Terco (la primera caída te levantás con 20 % de vida) |
| Hablás con muchos NPCs | Carismático (más reputación) |
| Recorrés mucho el mapa | Explorador (ves objetos para juntar de más lejos) |

## Variantes: mutan con condiciones secretas
- Cada Linaje tiene 4: **Normal** (al empezar), dos **Raras** y una **Única**. Las condiciones de cada una están en la nota del Linaje.
- Una condición mezcla **un lugar + una acción + a veces un Catalizador** (objeto raro que cae poco, en lugares específicos, y se puede intercambiar).
- Al cumplirla, tu poder **muta** en una escena corta. Mutar a otra Variante **reemplaza** la anterior: también es una decisión a ciegas.

## Evolución hasta 2 poderes
1. **Despertar 1 (nivel 25)**: el Narrador te manda un gancho según tu Linaje y tu historia (tu poder se descontrola en público, un mentor te encuentra, un villano te quiere reclutar). Termina en elegir **una de 2 ramas**, a ciegas. Abre la definitiva (V) de esa rama y cambia el color del poder.
2. **Despertar 2 (nivel 60): segundo poder**, por uno de 3 caminos (cada NPC lo ofrece con una frase, sin decir qué da):
   - **Transferencia** ([[Directora Brandt]]): absorbés el fragmento de un jefe que venciste y te queda **ese** Linaje.
   - **Resonancia** ([[Señal]] y [[Atalanta]]): tu poder despierta uno afín; ruleta solo entre los compatibles (más chance de Técnica combinada).
   - **Núcleo artificial** ([[Dra. Kessler]] e [[Ingeniera Okafor]]): un implante que funciona como segundo poder tecnológico. Más estable, pero ocupa toda la Carga Cibernética.
3. **Con 2 poderes** equipás Z, X, C de cualquiera de los dos + la V de uno, y la **B** si son compatibles. Las 12 técnicas del lanzamiento están en [[Linajes]].

## Personalización
- **Cuerpo propio** (nunca el avatar de Roblox, ver [[Cuerpo propio (sin avatar de Roblox)]]): contextura, altura, piel, cara y pelo.
- **Piezas de traje** para mezclar: 8 cascos y máscaras, 8 capas, 8 petos, 6 hombreras, 6 guantes, 6 botas al empezar (en la Beta: 4 cascos, 4 capas y 4 petos). **3 canales de color** por pieza, material (tela, cuero, metal, neon) y largo de capa.
- **Emblema propio**: 20 formas, color, borde y brillo; va en el pecho, la capa y la bandera de tu base.
- **Nombre de héroe + título** ganado ("El que venció a Remache", "Rey del puerto").
- **Estilo de pelea**: Puños (en la Beta), Espada, Bastón, Armas no letales, Gadgets. Cambia el combo de 4 golpes.
- **Armado de habilidades**: elegís qué va en Z, X, C, V y B, y les ponés Chips.
- **Base propia**: escondite que decorás con muebles y trofeos, y donde guardás trajes.
- **3 espacios de personaje**, cada uno con su Linaje, su inicio y su historia.

## Que cada partida sea distinta
- **6 inicios**, Linaje al azar, Variantes y Rasgos que salen de cómo jugás: casi ningún personaje sale igual.
- **Decisiones a ciegas** en cada arco de ciudad que cambian qué NPC te ayuda, quién se vuelve villano y qué final ves (2 o 3 por arco). Ver [[Los arcos de ciudad]].
- **Crímenes al azar** cada 3 a 5 minutos en un barrio al azar. Ver [[Calle viva]].
- **Enemigos de élite** con 1 o 2 modificadores (Rápido, Blindado, Explota al morir, Invoca drones) y mejor botín.
- **Rumores de El Faro** que cambian cada día.
- **Eventos de servidor**: Apagón, Lluvia de esquirlas, Fuga del penal, Invasión de Umbra.
- **Renacer** al terminar la historia: nuevo inicio y nuevo Linaje, pero te quedás con piezas, títulos, la base y un **Legado** (bono chico permanente por Renacer).

Volver a [[Ficha del juego]]
