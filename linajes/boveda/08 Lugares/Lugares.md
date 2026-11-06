---
tags: [lugares, indice]
---
# Lugares

> [!summary] En tres líneas
> Un solo mapa de unos **4.000 x 4.000 studs** por servidor: la bahía en el centro, tres ciudades alrededor, una isla cárcel, un cráter, una ciudad bajo el agua y otro mundo aparte. **La Beta es solo Puerto Óxido.** Cada nota dice cómo se ve (colores, materiales, luz), los barrios, los lugares clave y qué pasa ahí.

| Lugar | Tipo | Quién manda | En la Beta |
|---|---|---|---|
| [[Puerto Óxido]] | Ciudad | Cofradía Carmesí | **Sí: es todo el mapa de la Beta** |
| [[Ciudad Vórtice]] | Ciudad | Vigilantes | No |
| [[Distrito Corona]] | Ciudad | Liga de Guardianes | No |
| [[Penal Islaroca]] | Isla | Nadie (raid) | No |
| [[Cráter del Eclipse]] | Zona libre | Nadie (PvP libre) | No |
| [[Ciudad Hundida]] | Bajo el agua | El Heredero Abisal | No |
| [[Umbra]] | Otro mundo | El Eclipsador | No |
| [[Taller de Tano]] | Interior (Beta) | Tano | **Sí** |
| [[Galpón de Remache]] | Interior (Beta) | Remache | **Sí** |
| [[Galpón del Albatros]] | Interior (Beta) | El Albatros | **Sí** |

## Mapas 2D
Las posiciones de Vórtice, Corona y el Cráter están decididas. Lo punteado y lo marcado como propuesta todavía no. El reparto de barrios dentro de Vórtice y Corona sigue siendo propuesta. Se regeneran con `linajes/arte/scripts/mapa_2d.py`.

![[mapa-mundo.png]]

![[mapa-puerto-oxido.png]]

## Reglas del mapa
- Ejes: **+Z es el sur**. El mapa va de −2.000 a 2.000 en X y Z; la bahía está en el centro.
- `StreamingEnabled` con radio 512. Las piezas con función se marcan con **tags y atributos** (`Barrio`, `Lugar`, `Estacion`, `Origen`), nunca por nombre.
- Cada ciudad tiene **5 barrios** que cambian de bando según los jugadores (ver [[Mundo abierto y reputación]]).
- Te movés a pie, con tu poder ([[Estadísticas y movimiento]]), en vehículo, subte y ferry.

## Diseño de ciudades (a probar)
Ideas sacadas de [[Referencias de ciudades]]. No se copian mapas, edificios ni nombres de otros juegos ni de DC.
- **Hito por ciudad, visible desde lejos:** una grúa gigante en Puerto Óxido, la torre de reloj en Vórtice y la torre de cristal en Corona.
- **Una actividad única por barrio:** si un barrio no tiene algo que no esté en otro, se achica o se saca.
- **Tres alturas:** calle, techos y cielo, cada una con recorridos y secretos propios.
- **Color en el puerto:** contenedores y carteles carmesí en cada calle, para que no quede un puerto gris y vacío.
- **Carteles que cuentan quién manda:** cambian según qué bando controla el barrio.
- **Vida barata:** ferry, grúas en movimiento, semáforos y luces, todo en un solo bucle del cliente.

Volver a [[00 Inicio]]
