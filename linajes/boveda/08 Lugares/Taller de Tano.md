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

**Detalle (paso 2, versión 5)**: 36.916 triángulos (tope 60.000). Chequeo de cruces: **0**. Cosas flotando: **0**.
Cambios de Juani (1 nov, tercera lista):
- **Gancho.** Tiene 3 garras abiertas con uña, el rollo de cable al costado y una empuñadura con gatillo. Está sobre un panel oscuro con su silueta pintada en amarillo y un spot propio.
- **Auto.** Pintado de verde oliva gastado (conserva la suciedad del horneado). Los faros están apagados, se ve el cable de la batería colgando con su pinza y la rueda está desmontada contra la columna. El charco ahora es oscuro y chato (antes parecía vidrio celeste).
- **Banco.** La morsa tiene forma de morsa. Hay 2 latas con etiqueta azul y verde (sin marcas), un engranaje y un carburador a medio desarmar, y el trapo rojo cuelga del borde.
- **Tablero.** Herramientas distintas: llaves de varios tamaños (una torcida), llave inglesa, destornilladores amarillos y azules, un martillo grande y uno chico, una pinza y el serrucho. Cada una tiene su silueta pintada y hay un hueco vacío para la llave que Tano tiene en la mano.
- **Paredes.** Parches con más óxido, un calendario viejo, un reloj de pared y un cartel de repuestos inventado, sin letras.
- **Esquina de los tambores.** Neumáticos apilados y 2 bidones rojos.
- **Entrepiso.** El mameluco de Tano cuelga de la baranda y la punta de la frazada asoma por el borde.
- **Piso.** Grietas más marcadas y huellas de neumático que van del elevador al portón.
- **Luz.** Conos de luz con el borde suave y una lámpara articulada propia sobre el banco de fabricar.

**Para cuando se lleve a Studio (anotado):**
- Las luces se rearman en Studio con iluminación Future: SpotLight en el portón, en las 2 lámparas, en el banco, en el gancho y en el banco de fabricar. Solo 2 o 3 con sombra, porque en celular cada una cuesta.
- Colisiones simples, con cajas `_Colision` para el auto, el elevador y el banco, nunca con la malla entera.
- Los 3 lugares que se usan (Tano junto al auto, el banco de fabricar y el tablero de trabajos) llevan luz propia para distinguirse de un vistazo.
- Sonido: la radio vieja de fondo y un goteo cerca del portón (`-- SONIDO:` con su ID en `Config.luau`).

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
