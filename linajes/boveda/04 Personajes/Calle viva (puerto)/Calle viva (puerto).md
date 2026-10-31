---
tags: [personaje, objetos]
bando: "Calle viva"
---
# Calle viva (puerto)

**Estado:** Terminado y exportado (56 piezas en `linajes/arte/exports/calle-viva/<grupo>/`).
**Prompt:** [[P20e Vehículos y objetos de la calle viva]] (solo lo de la Beta de Puerto Óxido)

Los vehículos y objetos que hacen que el puerto se sienta vivo: la policía que corta los puentes, autos en la calle, cámaras, lo del atraco chico del almacén del muelle y el callejón peligroso de la pandilla "Los Óxido". Son diseños propios, sin marcas reales de autos.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte.

```3D
{
  "models": [
    {
      "name": "calle-viva.glb",
      "scale": 1,
      "position": [0, 0, 0],
      "rotation": [0, 0, 0]
    }
  ],
  "camera": {
    "LookatXYZ": [12, 0, -8],
    "camPosXYZ": [12, 22, 26]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [0, 0.002, 0]
  }
}
```

## Boceto en grilla
![[calle-viva_boceto_grilla.png]]

## Paso 2: detalle
Calle del puerto cortada por la policía, armada como diorama (referencia de Juani): galpón con base de ladrillo, caños, ventilaciones y aire en el techo, puerta de madera con farol, cartel de neón "EL ANCLA", contenedor de basura, bolsas, cajas, bolardos, carteles de BUSCADO, grafitis, patrulla con "POLICÍA DE LA BAHÍA" y estrella propia de 6 puntas, y taxi. La calle sigue hacia la izquierda y la cierra el corte de la policía (dos barreras); los autos van en la misma mano, con faros blancos adelante y luces rojas atrás:
![[calle-viva_detalle_calle.png]]

Callejón de Los Óxido de noche, entre un muro bajo y dos edificios viejos de 2 pisos de 13 studs (con ventanas encendidas): escalera de incendio con el balcón debajo de una ventana del primer piso, escalera al techo y escalera corrediza levantada; farola rota, basura volcada, colchón, barril con fuego, grafitis, reja que cierra el fondo y alijo:
![[calle-viva_detalle_callejon.png]]

Todas las piezas:
![[calle-viva_detalle_grilla.png]]

Grafitis y cartel: dibujos propios en `linajes/arte/exports/calle-viva/decals/` (van como Decal en Roblox). Las escaleras y la reja tienen malla de choque aparte (`_Colision`, invisible), según las reglas de [[GUIA-ESTILO]].

### Triángulos
| Pieza | Triángulos | Tope |
|---|---|---|
| Patrulla_Carroceria | 2280 | 8000 |
| Patrulla_Blanco | 432 | 1500 |
| Patrulla_Sirena | 216 | 600 |
| Patrulla_SirenaAzul | 216 | 600 |
| Auto_Vidrios | 108 | 400 |
| Auto_Faros | 216 | 300 |
| Auto_Stop | 88 | 100 |
| Patrulla_Rueda | 280 | 400 |
| Rueda_Llanta | 244 | 300 |
| Compacto_Carroceria | 2264 | 6000 |
| Camioneta_Carroceria | 2780 | 6000 |
| Taxi_Carroceria | 2280 | 6000 |
| Taxi_Cartel | 88 | 200 |
| Civil_Rueda | 248 | 300 |
| Camara_Pared | 440 | 800 |
| Camara_Poste | 440 | 800 |
| Camara_Rota | 396 | 800 |
| Camara_Lente | 146 | 150 |
| Camara_Luz | 48 | 50 |
| Barrera | 1080 | 1300 |
| Barrera_Luces | 196 | 200 |
| Esposas | 392 | 400 |
| Bolsa_Botin | 344 | 800 |
| Alijo | 980 | 1000 |
| Tablero_Golpes | 1080 | 2000 |
| Tablero_Papeles | 392 | 400 |
| Tablero_Hilos | 220 | 300 |
| Cartel_Buscado | 196 | 200 |
| Farola_Rota | 1084 | 1500 |
| Basura_Volcado | 852 | 1500 |
| Colchon | 660 | 1500 |
| Barril_Fuego | 1088 | 1300 |
| Barril_Llamas | 196 | 200 |
| Reja_Deposito | 1470 | 1500 |
| Escalera_Incendio | 1470 | 1500 |
| Escalera_Incendio_Colision | 36 | 100 |
| Reja_Deposito_Colision | 12 | 12 |
| Grafiti_1 | 12 | 12 |
| Grafiti_2 | 12 | 12 |
| Grafiti_3 | 12 | 12 |
| Canio_Bajada | 588 | 600 |
| Canio_Tramo | 204 | 300 |
| Techo_Ventilacion | 312 | 400 |
| Equipo_AC | 784 | 800 |
| Rejilla_Pared | 294 | 300 |
| Puerta_Taller | 660 | 1200 |
| Puerta_Escalones | 88 | 100 |
| Puerta_Luz | 44 | 50 |
| Contenedor_Basura | 528 | 1200 |
| Bolsas_Basura | 408 | 600 |
| Cajas_Carton | 220 | 300 |
| Bolardo | 196 | 200 |
| Letrero_Bar | 352 | 400 |
| Letrero_BarLuz | 12 | 12 |
| Patrulla_Texto | 24 | 24 |
| Taxi_Texto | 24 | 24 |
| **Total** | **29732** | |

Grafitis en la franja lisa entre pisos (sin columnas ni marcos). La calle tiene veredas de 16 studs y el galpón del fondo con techo y costados.

Chequeo de cruces: el script avisa si dos piezas se meten una en otra; solo quedan las que van pegadas a propósito (cámara a la pared, edificios lado a lado, reja amurada).

Revisión del 31 oct: adoquines casi planos (los autos no saltan), grafitis despegados de la chapa, lo que brilla se exporta como `Neon_` y los vidrios como `Glass_`.

## Qué entra en la Beta
| Grupo | Piezas | Tope de triángulos |
|---|---|---|
| Vehículos | Auto patrulla (carrocería, barra de luces, rueda), compacto, camioneta y taxi (carrocería y rueda; cartel del taxi) | 10.000 patrulla, 7.000 cada civil |
| Vigilancia | Cámara de pared, de poste y rota (con cables colgando), luz roja; barrera de corte de ruta con luces | 800 cada cámara, 1.500 barrera |
| Atraco chico | Esposas, bolsa de botín, alijo de pandilla, tablero de golpes del Albatros | 400 / 800 / 1.000 / 2.000 |
| Noticias | Cartel de "BUSCADO" | 200 |
| Callejón | Farola rota, contenedor de basura volcado, colchón, barril con fuego, reja de depósito, escalera de incendio rota, 3 grafitis de Los Óxido | 1.500 cada uno |

Boceto: 1.468 triángulos. Detalle: 24.864 en total, todo dentro de su tope.

## Queda para después de la Beta
Helicóptero, camión táctico, blindado de caudales, moto y auto del jugador, subte, ferry, reflector, arco escáner, taladro, cajero, caja de hacker, kiosco, pantalla gigante, TV de bar, radio y los perros (necesitan rig propio).

Volver a [[Personajes]]
