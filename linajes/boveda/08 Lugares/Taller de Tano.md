---
tags: [lugar]
tipo: "Interior (Beta)"
---
# Taller de Tano

> [!summary] En tres líneas
> El taller de Tano: tu base en la Beta. Ahí fabricás el traje y el gancho, aceptás trabajos de mecánico y hablás con Tano. **Se rehace con el nuevo prompt** (el anterior se descartó).

| Tipo | Tamaño y dónde | Quién manda | DC (nombre de trabajo) | En la Beta |
|---|---|---|---|---|
| Interior (Beta) | Galpón de 40 x 30 studs, 16 de alto, barrio Galpones | Tano | Batcueva/garaje de Alfred (solo la idea) | **Sí** |

## Cómo se ve
- **Paleta**: paredes de chapa `#4a5560`, piso de cemento manchado `#5d5a55`, madera de banco `#6b4426`, herramientas acero, mameluco azul `#2d4a73`, luz cálida `#f2a23a`.
- **Materiales**: `CorrodedMetal`, `Concrete`, `WoodPlanks`.
- **Luz**: 2 lámparas colgantes cálidas + luz fría de la puerta abierta.
- **Formas**: portón levadizo al frente, banco largo con morsa, tablero de herramientas, auto viejo levantado en el elevador, entrepiso de madera.

## Barrios
—

## Lugares clave
- **Banco de trabajo** (fabricar).
- **Tablero de trabajos**.
- **Elevador con auto**.
- **Entrepiso** con cama (guardar el juego).

## Qué pasa acá
Fabricar, trabajo de mecánico, escenas de Nico y Tano.

## Estado y Beta
Graybox con tag `Lugar`. Modelo nuevo pendiente (P25d rehecho).

## Modelo (P25d-01, rehecho desde cero)
**Estado: paso 2, detalle con texturas horneadas. Espera tu OK.** (El boceto se aprobó el 1 nov.) Planta de **40 x 32 studs** (32 en vez de 30 para que entre en la grilla de 4), paredes de chapa de 16 y techo a dos aguas con la cumbrera a 22 (entra en el lote de 50 x 22 x 40 del graybox). Chequeo de cruces: **0**. Cosas flotando: **0**. Triángulos del boceto: 1.868.

**Detalle (paso 2, versión 4)**: 35.300 triángulos (tope 60.000). Chequeo de cruces: **0**. Cosas flotando: **0**.
Cambios de Juani (1 nov, segunda lista):
- **Luz.** Más luz ambiente, una lámpara chica sobre el banco y renders con 128 muestras para que no tengan grano.
- **Motor.** Ahora se lee: tapa de válvulas roja, filtro de aire cromado y redondo, batería con bornes rojo y negro, y mangueras naranjas.
- **Gancho.** Es la estrella: el doble de grande, solo en su propio panel y con un spot que lo ilumina.
- **Manchas.** Marrón muy oscuro, algo brillantes y con un borde más claro, así ya no parecen agujeros.
- **Ventanas y puerta.** Las ventanas tienen marco y vidrio sucio (antes eran huecos blancos) y la puerta lateral está cerrada.
- **Tablero de trabajos.** Corcho con papeles, notas, un mapa del puerto y chinches, en la pared este (marcador `Tablero_Trabajos`).
- **Chapa por fuera.** Las 4 paredes son de chapa ondulada también por fuera (antes parecían ladrillo).

**Primeros planos:**
![[interior-taller_cerca_banco.png]]
![[interior-taller_cerca_motor.png]]
![[interior-taller_cerca_gancho.png]]

**Recorrido de la sala (6 vistas):**
![[interior-taller_sala1_portón.png]]
![[interior-taller_sala2_esquina_sureste.png]]
![[interior-taller_sala3_fondo.png]]
![[interior-taller_sala4_esquina_noroeste.png]]
![[interior-taller_sala5_entrepiso.png]]
![[interior-taller_sala6_aerea.png]]

**Vista desde el mismo ángulo que la referencia de Gemini:**
![[interior-taller_detalle_como_ref.png]]
![[interior-taller_detalle_auto.png]]
![[interior-taller_detalle_corte.png]]
![[interior-taller_detalle_puerta.png]]
![[interior-taller_detalle_entrepiso.png]]
![[interior-taller_detalle_banco.png]]
![[interior-taller_detalle_planta.png]]
![[interior-taller_detalle_fondo.png]]

**Referencias de Gemini** (vista desde el portón, planta y materiales):
![[taller-gemini-ref-1.jpg]]
![[taller-gemini-ref-2.jpg]]
![[taller-gemini-ref-3.jpg]]

**Boceto**: planta desde arriba, vista desde el portón, vista desde el fondo y corte.
![[interior-taller_boceto_planta.png]]
![[interior-taller_boceto_puerta.png]]
![[interior-taller_boceto_fondo.png]]
![[interior-taller_boceto_corte.png]]
![[interior-taller_boceto_entrepiso.png]]

**Dónde está cada cosa**: elevador con el auto al oeste, detrás del portón. Banco de roble con morsa y el gancho, con el tablero de herramientas arriba, en el fondo. Entrepiso al este: **arriba**, una cama de verdad (marco de hierro con patas y cabecera, colchón, almohada y frazada) y un cajón con la radio; **abajo**, el escritorio de la compu pegado a la pared, con monitor, teclado, cajonera, silla y un foquito (cambios de Juani, 1 nov). Tambores en la esquina del fondo, al oeste. El centro queda libre para pelear. Carro rojo, compresor y locker verde en la esquina del frente, al este, al lado de la puerta lateral. Dos lámparas cálidas cuelgan de las cerchas.
**Puntos para el código**: PuntoNPC_Tano (junto al auto), PuntoNPC_Nico (banco), Banco (silla del escritorio de la compu), Cama (catre), Salida (portón), Salida_Lateral y Spawn_Civil.

## Cómo suena
Radio vieja de fondo, amoladora, goteo.

Volver a [[Lugares]]
