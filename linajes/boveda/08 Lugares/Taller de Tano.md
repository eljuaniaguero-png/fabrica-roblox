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

**Detalle (paso 2, versión 6: pasada de texturas)**: 35.414 triángulos (tope 60.000). Chequeo de cruces: **0**. Cosas flotando: **0**.
**Regla nueva:** todo lo plano va pintado en la textura horneada, no como malla. Lo que tiene volumen y se mira de cerca se modela con detalle. El pintado lo hace `linajes/arte/scripts/interiores/pintura.py`: calcula en qué punto del mundo cae cada píxel de la textura y le aplica el efecto. Se pintaron 43 piezas.
- **Piso (4 losas a 1024).** Manchas de aceite `#2a1f17` con borde suave y más brillo, grietas finas con ramas, 2 huellas de neumático curvas del elevador al portón, suciedad en las esquinas y junto a las paredes, y un charco con reflejo cerca del portón. Se borraron todas las mallas de manchas, grietas, huellas y parches.
- **Chapa (paredes y nervios).** Óxido que chorrea hacia abajo, más fuerte en la franja de abajo, manchas de agua y chorreadas debajo de las juntas, y algunos paneles con otro tono.
- **Tablero de herramientas.** Agujeritos y la silueta de cada herramienta como contorno fino pintado (ya no son placas).
- **Panel del gancho.** El contorno del gancho pintado.
- **Banco.** Quemaduras, rayones y una mancha de aceite en la madera.
- **Gancho (modelado).** Caño con empuñadura, gatillo y guardamonte. Rollo de cable con 3 vueltas de cable visibles. Anillo en la punta con 3 garras curvas iguales a 120°, unidas al anillo. Cable fino del rollo a la punta y la luz de carga celeste al costado. Se reconoce a 20 studs (ver el render).
- **Motor (modelado).** Block, tapa de válvulas con nervios, filtro de aire con 4 tuercas, radiador con panal al frente, 2 mangueras curvas negras, correa con 3 poleas, batería con bornes rojo y negro, y el cable rojo colgando con su pinza.
- **Trapo rojo `#8e2a22`.** Uno hecho un bollo arrugado arriba del banco y otro colgando del borde. *La simulación de tela de Blender no corre en el modo sin ventana que uso, así que el que cuelga se plegó a mano sobre el borde.* Para una tela simulada de verdad, hay que correrla con Blender abierto.
- **Morsa, latas y engranaje.** Bordes biselados. Las latas tienen tapa y aro.
- **Auto.** Verde más claro y saturado.

![[interior-taller_gancho_a_20_studs.png]]

**Para cuando se lleve a Studio (anotado):**
- Las luces se rearman en Studio con iluminación Future: SpotLight en el portón, en las 2 lámparas, en el banco, en el gancho y en el banco de fabricar. Solo 2 o 3 con sombra, porque en celular cada una cuesta.
- Colisiones simples, con cajas `_Colision` para el auto, el elevador y el banco, nunca con la malla entera.
- Los 3 lugares que se usan (Tano junto al auto, el banco de fabricar y el tablero de trabajos) llevan luz propia para distinguirse de un vistazo.
- Sonido: la radio vieja de fondo y un goteo cerca del portón (`-- SONIDO:` con su ID en `Config.luau`).

**Más vistas (10):**
![[interior-taller_mas01_desde_la_calle.png]]
![[interior-taller_mas02_como_referencia.png]]
![[interior-taller_mas03_auto_costado.png]]
![[interior-taller_mas04_banco_y_tablero.png]]
![[interior-taller_mas05_escritorio.png]]
![[interior-taller_mas06_tablero_trabajos.png]]
![[interior-taller_mas07_cama.png]]
![[interior-taller_mas08_esquina_tambores.png]]
![[interior-taller_mas09_carro_compresor.png]]
![[interior-taller_mas10_portón_desde_adentro.png]]

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

**Referencias nuevas de Gemini (1 nov, tarde)**: vista de frente y hoja de objetos.
![[taller-gemini-ref-4.jpg]]
![[taller-gemini-ref-6.jpg]]
- **Se tomó:** el gancho de la hoja (carrete con el cable enrollado atrás, caño con la luz celeste, empuñadura de madera con gatillo, anillo con 3 garras curvas y el cable que cuelga hasta la punta), la cama con barrotes y el clima general.
- **No se copió** (aviso de Juani): el auto apoyado en el piso (sigue en el elevador de dos columnas), el gancho chiquito tipo perchero de la pared (va el lanzador), la planta de la imagen 2 (sigue la aprobada), y la morsa y el engranaje repetidos y la sierra dibujada adentro del tablero (errores de Gemini).

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
