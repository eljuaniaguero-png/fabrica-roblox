# Monetización — reglas y ofertas de los dos juegos

Documento de diseño para Pisada Sonora y Mutant Lab. Lo lee Claude Code antes de tocar cualquier cosa que se pague con Robux.
Los precios son un punto de partida sin probar: se ajustan mirando qué se vende de verdad.

## Idea central

Una compra tienta cuando el jugador ya está disfrutando algo y le ofrecés más de eso, en el momento en que lo quiere.
Una compra arruina el juego cuando el que no paga se queda sin poder jugar, o cuando el que paga ya no tiene nada que hacer.

## Qué hace tentadora una oferta

1. Se ve antes de comprar: probar una estela 20 segundos, ver el pet caminando al lado.
2. La ven los demás: estelas, pets, zapatillas y etiquetas se muestran a otros jugadores.
3. Aparece cuando hace falta: al faltar poco para una puerta, al cortarse un combo, al llenarse los corrales.
4. El precio de entrada es bajo: siempre hay algo de menos de 50 Robux.
5. El paquete vale más que las partes: los bundles tienen un descuento real y se muestra la cuenta.
6. Se prueba gratis una vez: un minuto de "x2" de regalo para que se note la diferencia cuando se termina.
7. Se puede regalar: comprar un pase para un amigo que está en el servidor.

## Límites para que no arruine el juego

- Todo el juego se termina sin pagar. Pagar acelera, nunca desbloquea contenido obligatorio.
- Ningún multiplicador pago pasa de x2, y no se acumulan entre sí más allá de x4.
- Nada con azar se compra con Robux. Los huevos y las mutaciones al azar son solo con moneda del juego.
- Nada de contadores falsos ni "última oportunidad" que vuelve a aparecer. Lo que es por tiempo limitado, lo es de verdad.
- Las ofertas son un botón chico y fácil de cerrar. Nunca tapan la pantalla ni frenan el juego.
- Como máximo una oferta cada 3 minutos, y ninguna en los primeros 3 minutos de un jugador nuevo.
- Las tablas de posiciones que se agreguen después separan o marcan a quienes usan multiplicadores pagos.
- Todas las compras se validan y se guardan en el servidor, con el método oficial de Roblox, antes de entregar el beneficio.
- Los IDs de pases y productos van vacíos en Config.luau. Los crea el usuario en el panel de Roblox. Sin ID, el botón dice "Próximamente".

## Escalera de precios (en Robux)

| Tramo | Precio | Para qué |
|---|---|---|
| Impulso | 25 a 49 | Primera compra: pack de inicio, cosmético simple |
| Base | 99 a 199 | Pases permanentes que más se venden |
| Grande | 299 a 499 | VIP y bundles |
| Tope | 799 | Bundle con todo |

## Pisada Sonora

### Pack de inicio (una sola vez por jugador, 49)
Se ofrece al pasar la primera puerta. Trae: monedas para dos mejoras, una estela exclusiva y un pet común exclusivo (el "Compasito").
Es la oferta más importante: convierte al jugador en comprador con un precio bajo y mucho valor.

### Pases permanentes
| Pase | Precio | Qué da | Por qué no rompe |
|---|---|---|---|
| Pasos x2 | 149 | Doble de pasos por baldosa | Acelera, la curva de niveles sigue |
| Monedas x2 | 149 | Doble de monedas al vender y en rebirth | Igual |
| Auto-venta | 99 | Vende los pasos solo al llegar al tope | Comodidad pura |
| Tercer pet | 199 | Un lugar más de pet equipado | Bonus acotado |
| Teletransporte libre | 99 | Usar el teletransporte desde cualquier lado, solo a puertas ya abiertas | No saltea progreso |
| VIP | 399 | Estela y etiqueta exclusivas, zona VIP con una canción extra, +10% de monedas | La zona es extra, no parte del camino |
| Bundle Todo | 799 | Todos los pases (por separado suman 1094) | Descuento real a la vista |

### Productos repetibles
| Producto | Precio | Regla |
|---|---|---|
| Pack de monedas chico, medio y grande | 25, 99, 299 | El grande rinde más por Robux |
| Turbo de 15 minutos | 39 | x2 de velocidad de progreso; no se acumula con otro turbo |
| Recuperar combo | 19 | Se ofrece solo al cortarse un combo de más de 25 |
| Empujón de puerta | 49 a 149 | Solo si ya tenés al menos el 70% de los pasos del nivel; el precio sube con la zona |

"Empujón de puerta" reemplaza a "saltear puerta": saltear una zona entera sin jugarla deja al jugador sin nada que hacer.

### Cosméticos (se ven en todos los servidores)
- Estelas, efectos de pisada y colores de baldosa: 25 a 149.
- Instrumentos: cambian el sonido de todas las baldosas para el jugador (cuerdas, campanas, sintetizador, 8 bits): 99 cada uno. Es lo más propio del juego.
- Zapatillas de diseño: mismo bonus que las normales del mismo nivel, otro aspecto: 49 a 199.
- Pet exclusivo de compra directa, con el bonus a la vista: 249.
- Cada cosmético se puede probar 20 segundos gratis desde la tienda.

### Gratis que ayuda a vender
- Un minuto de Pasos x2 de regalo en la primera sesión.
- Recompensa diaria, con un cosmético al séptimo día.
- Pet gratis por unirse al grupo de Roblox del juego.
- Anuncio con recompensa: turbo de 5 minutos, como máximo 3 por día.

### Dónde aparece cada oferta
| Momento | Oferta |
|---|---|
| Pasa la primera puerta | Pack de inicio |
| Llega a una puerta con 70% o más del nivel | Empujón de puerta |
| Se corta un combo de más de 25 | Recuperar combo |
| Se termina el minuto de x2 de regalo | Pase Pasos x2 |
| Se llena el tope de pasos disponibles | Auto-venta |
| Ve a otro jugador con estela o instrumento | Botón "Probar" sobre ese jugador |

## Mutant Lab

### Pack de inicio (una sola vez, 49)
Se ofrece después de la tercera especie descubierta. Trae: ADN para unas 10 fusiones, una especie base exclusiva y un aspecto de máquina.

### Pases permanentes
| Pase | Precio | Qué da | Por qué no rompe |
|---|---|---|---|
| ADN x2 | 149 | Doble de ADN por segundo | Acelera, no descubre nada solo |
| Fusión instantánea | 99 | Saltea la espera entre fusiones; la animación de revelación queda | El descubrimiento sigue igual |
| Corrales extra | 149 | +5 criaturas activas | Bonus acotado |
| Recolección automática | 99 | Junta el ADN de los corrales solo | Comodidad |
| Pistas del día | 99 | 3 pistas gratis por día | Ayuda sin revelar la receta completa |
| VIP | 399 | Aura y etiqueta exclusivas, sala extra en el laboratorio, +10% de ADN | Extra, no obligatorio |
| Bundle Todo | 799 | Todos los pases | Descuento real a la vista |

No se vende "revelar todo el Mutadex": descubrir es el juego, y venderlo lo termina.

### Productos repetibles
| Producto | Precio | Regla |
|---|---|---|
| Pack de ADN chico, medio y grande | 25, 99, 299 | El grande rinde más |
| Suero mutante | 39 | La próxima fusión sale en versión mutante, seguro. Solo estético |
| Turbo de laboratorio, 15 minutos | 39 | x2 de ADN; no se acumula |

El Suero mutante es la compra más tentadora: da un resultado vistoso, seguro y sin azar, y no cambia el progreso.

### Especies y cosméticos
- Especies base exclusivas de compra directa (149 cada una): cada una abre unas 10 combinaciones nuevas, en una página aparte del Mutadex llamada "Extras". Las 50 especies del Mutadex principal se consiguen sin pagar.
- Aspectos de máquina de fusión, temas de laboratorio y auras para criaturas: 49 a 199.
- Sacar a pasear una criatura fuera del laboratorio, donde la ven los demás: gratis para una, pase de 99 para tres.

### Dónde aparece cada oferta
| Momento | Oferta |
|---|---|
| Tercera especie descubierta | Pack de inicio |
| Falta ADN para una fusión ya elegida | Pack de ADN chico |
| Corrales llenos | Corrales extra |
| Sale un mutante por primera vez | Suero mutante |
| Descubre una silueta con una especie exclusiva como padre | Ver esa especie en la tienda |

## Cómo medir si funciona
- Porcentaje de jugadores que compran algo, y cuál es la primera compra.
- Robux por jugador.
- Si los que compran siguen jugando al día siguiente. Si una compra hace que dejen de jugar, esa compra está mal diseñada y se cambia.
