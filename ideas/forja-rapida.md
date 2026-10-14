# Forja Rápida — ficha del prototipo

Origen: documento de diseño de Juani (chat del 14/10/2026) + 3 capturas de referencia.
Estado: **borrador, esperando OK** (punto de control 1).
Carpeta: `forja-rapida/` (código en `forja-rapida/src/`, Rojo con `rojo serve forja-rapida`). Place propio en Studio.

## Concepto

Simulador de clics. Golpeás una roca y ganás Fuerza. La Fuerza sirve para dos cosas: abrir puertas a zonas nuevas (hay que *tenerla*) o cambiarla por Monedas en el Banco (100 Fuerza = 1 Moneda) para comprar picos mejores. La gracia es decidir: ¿gasto o guardo para la próxima puerta?

## Loop de 30 segundos

1. Tocás la roca: salta un "+5", la roca se aplasta un poco, vuelan chispas y el personaje pega con el pico.
2. Arriba, la barra hacia la próxima puerta se llena.
3. Cuando te alcanza para un pico, aparece un aviso y una flecha en el piso te lleva al Banco y después a la Tienda.
4. Pico nuevo → cada golpe da mucho más → volvés a la roca o cruzás la puerta hacia una roca que multiplica.

## Sistemas del prototipo (5)

1. **Golpe.** Tocar o clickear la roca. El cliente solo avisa "le pegué a esta roca"; el servidor revisa que sea una roca (tag `Roca`), que estés cerca (≤ 30 studs), que su zona esté abierta para vos y que no pases de 12 golpes por segundo. Suma Fuerza = poder del pico × multiplicador de la zona. Efectos: número que salta, roca que se aplasta, chispas, golpe del pico, `-- SONIDO:` golpe.
2. **Banco y Tienda de picos.** Dos puestos en la plaza de inicio. Banco: "Canjear todo" y "Canjear la mitad" (lo que sobra por debajo de 100 queda como Fuerza); muestra cuánto pide la próxima puerta para que decidas. Tienda: 5 picos que se compran en orden; al comprar se equipa solo (siempre usás el mejor). El pico se ve en la mano.
3. **Zonas y puertas.** 5 zonas en fila, separadas por barreras de energía con el requisito escrito arriba. Si llegás a la barrera con la Fuerza suficiente, se abre para siempre (no gasta la Fuerza). Si no, te frena y dice "Te faltan X". El servidor también controla: si aparecés en una zona que no abriste, volvés a la plaza.
4. **HUD y guía.** Fuerza y Monedas grandes abajo a la izquierda; barra "Próxima puerta" arriba; tres botones de viaje arriba al centro (Banco · Mina · Tienda, donde Mina te lleva a la roca de tu mejor zona); cartel central "¡Golpeá la roca!" y flecha en el piso que guía al jugador nuevo: roca → banco → tienda → puerta. Fuerza y Monedas también en la tabla de jugadores (leaderstats).
5. **Guardado.** ProfileStore (bloqueo de sesión, autoguardado, al salir y al cerrar el servidor). Guarda Fuerza, Monedas, picos, zonas abiertas y Fuerza total histórica (para tablas de récords más adelante).

## Números (van en `Config.luau`)

Son tus números con un ajuste: con +1 por golpe, el Pico de Piedra a 50 Monedas pide 5.000 golpes (unos 17 minutos tocando sin parar) antes de que cambie algo. Roblox mide cuánta gente se va en la primera partida, así que propongo que el primer pico llegue al minuto y que cada paso tarde un poco más que el anterior. Para eso cada zona multiplica lo que da su roca.

| Pico | Fuerza por golpe | Precio en Monedas (tuyo → propuesto) |
|---|---|---|
| Madera | +1 | gratis |
| Piedra | +5 | 50 → **3** |
| Hierro | +20 | 250 → **100** |
| Oro | +100 | 1.000 → **1.500** |
| Legendario | +500 | 5.000 → **12.000** |

| Zona | La roca multiplica | Fuerza para abrir (tuyo → propuesto) |
|---|---|---|
| 1 · Cantera | x1 | abierta |
| 2 · Cañón de Piedra | x2 | 5.000 → **2.500** |
| 3 · Cueva de Hierro | x3 | 50.000 → **40.000** |
| 4 · Mina de Oro | x4 | 250.000 → **400.000** |
| 5 · Cráter Legendario | x5 | 1.000.000 → **3.000.000** |

- Banco: 100 Fuerza = 1 Moneda (sin cambios).
- Tope: 12 golpes por segundo (lo que pase de eso no cuenta).
- Ritmo calculado a 5 golpes por segundo sin parar: Piedra al minuto 1 · Zona 2 al 2:40 · Hierro 5:10 · Zona 3 8:30 · Oro 14:40 · Zona 4 19:00 · Legendario 25:40 · Zona 5 30:40. Jugando normal, más o menos el doble.

## Decisiones (eran ambiguas, elegí lo más simple)

- "Rocas más resistentes": no se rompen; cada zona tiene una roca más grande y vistosa que multiplica. Cualquier pico le pega a cualquier roca.
- Las puertas piden Fuerza **actual** (no la histórica): así existe la decisión de gastar o guardar. Una vez abierta, queda abierta.
- Banco y Tienda están solo en la plaza; los botones de viaje evitan caminar de vuelta.
- El pico no es una herramienta de la mochila: va pegado a la mano, sin equipar ni desequipar.
- En pantalla, los números grandes van cortos: 2,5K · 1,2M.
- El mapa se genera por código (`GeneradorMapa.luau`) desde Config, así vive en git.
- El código sigue la estructura de los otros juegos (Rojo con `src/server`, `src/client`, `src/shared`) en vez de scripts sueltos en Studio como decía el prompt. Remotos: Golpear, Canjear, ComprarPico y Viajar.

## Cómo se ve

De las capturas se toma el estilo general, no el contenido: colores muy saturados, piso con studs, cielo celeste brillante, botones gordos con borde negro y texto blanco con contorno, íconos al lado del texto, contador grande abajo a la izquierda, botones de viaje arriba al centro y flecha guía en el piso. No se copian nombres, íconos ni personajes de esos juegos.

Guía de estilo: **pendiente** (punto de control 2). Tres muestras dentro de esa familia:
- A · Pradera: verde lima, amarillo y celeste (captura 1).
- B · Pileta: rojo, azul y cian (captura 2).
- C · Caramelo: amarillo, rosa y violeta (captura 3).

Modelos: el prototipo va con partes de Roblox (roca, picos, puertas). Blender para la roca y los picos cuando el loop demuestre que es divertido (GUIA, sección 5). Figma no hace falta: el HUD se arma directo en Studio imitando las capturas.

## Afuera del prototipo

- Robux: ni compras ni pases. Como el juego no tiene azar, vender Monedas más adelante no cae en la regla de ítems aleatorios pagos, salvo que se sumen huevos o mascotas.
- Renacer (rebirth), mascotas, auto-clic, tablas de récords, analítica y eventos.
- Sonidos definitivos (quedan marcados con `-- SONIDO:`) y modelos de Blender.

## Prueba que va a hacer Claude

Jugador nuevo: golpea, canjea, compra el Pico de Piedra, abre la Zona 2 y le pega a su roca. No se puede pegarle a la roca de una zona cerrada ni pasar de 12 golpes por segundo. Salir y volver: sigue todo. Captura en compu y en celular.
