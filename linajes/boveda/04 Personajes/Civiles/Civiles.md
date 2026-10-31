---
tags: [personaje, civil]
bando: "Civiles (calle viva)"
---
# Civiles

**Estado:** Terminado y exportado (136 FBX en `linajes/arte/exports/civiles/<tipo>/<pieza>/`, una malla por parte del cuerpo y canal de color).
**Bando:** Civiles de la calle viva (ver la sección 0e de la ficha)

Kit de ropa para mezclar por código: **8 de arriba, 6 de abajo, 8 de cabeza, 7 accesorios** (el paraguas va abierto y cerrado) y el **teléfono** con pantalla `neon-cian`. Además, 3 civiles especiales: **diarero** con carrito de El Faro, **vendedor de panchos** con carrito y sombrilla, y **músico** con guitarra y estuche abierto.

**2 canales de color:** cada pieza tiene mallas `_C1` y `_C2` en gris claro; el juego las pinta con `MeshPart.Color` (los colores de los renders son de muestra). Una malla por parte del cuerpo, así la ropa sigue a los huesos.

## Modelo 3D
El diarero con su carrito (en gris, sin pintar). Arrastrá para girarlo.

```3D
{
  "models": [
    {
      "name": "civiles.glb",
      "scale": 1,
      "position": [0, 0, 0],
      "rotation": [0, 0, 0]
    }
  ],
  "camera": {
    "LookatXYZ": [0, 1.0, 0],
    "camPosXYZ": [0, 1.4, 5.2]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [0, 0.006, 0]
  }
}
```

## Vereda con 12 civiles mezclados
![[civiles_vereda.png]]

## Todas las piezas
Filas: arriba · abajo · cabeza · accesorios · teléfono.
![[civiles_grilla.png]]

## 6 civiles de ejemplo
![[civiles_ejemplos.png]]

## Civiles especiales
![[civiles_especiales.png]]

## Primeros planos
![[civiles_cabezas.png]]
![[civiles_telefono.png]]
![[civiles_cafe.png]]
![[civiles_mochila.png]]
![[civiles_diarero.png]]
![[civiles_vendedor.png]]
![[civiles_musico.png]]

## Triángulos
"Civil" cuenta la ropa y el accesorio; el cuerpo propio va aparte (es el mismo para todos). Los **rulos** tienen tope 1.900 (no 1.500): Juani los quiso llenos, y 1.900 es lo máximo para que el civil más pesado siga debajo de 6.000.

| Pieza | Tipo | Triángulos | Tope | Mallas |
|---|---|---|---|---|
| CamperaJean | arriba | 2.154 | 2.500 | 7 |
| SacoOficina | arriba | 1.776 | 2.500 | 7 |
| BuzoCapucha | arriba | 2.094 | 2.500 | 7 |
| CamisaCuadros | arriba | 2.238 | 2.500 | 9 |
| PilotoLargo | arriba | 2.176 | 2.500 | 10 |
| ChalecoObra | arriba | 1.194 | 2.500 | 5 |
| RemeraEstampa | arriba | 1.338 | 2.500 | 5 |
| UniformeEnfermeria | arriba | 1.164 | 2.500 | 5 |
| Jean | abajo | 1.424 | 1.500 | 6 |
| PantalonVestir | abajo | 1.452 | 1.500 | 6 |
| Pollera | abajo | 466 | 1.500 | 3 |
| Jogging | abajo | 1.462 | 1.500 | 8 |
| Bermuda | abajo | 1.394 | 1.500 | 6 |
| Mameluco | abajo | 1.460 | 1.500 | 7 |
| Gorra | cabeza | 334 | 1.500 | 2 |
| GorroLana | cabeza | 582 | 1.500 | 2 |
| PeloCorto | cabeza | 502 | 1.500 | 2 |
| PeloLargoAtado | cabeza | 420 | 1.500 | 2 |
| Rulos | cabeza | 1.858 | 1.900 | 2 |
| PeladoBarba | cabeza | 572 | 1.500 | 2 |
| Sombrero | cabeza | 368 | 1.500 | 2 |
| Auriculares | cabeza | 322 | 1.500 | 2 |
| Maletin | accesorio | 226 | 800 | 2 |
| BolsaCompras | accesorio | 170 | 800 | 2 |
| Mochila | accesorio | 394 | 800 | 2 |
| ParaguasAbierto | accesorio | 132 | 800 | 2 |
| ParaguasCerrado | accesorio | 95 | 800 | 2 |
| Cafe | accesorio | 164 | 800 | 2 |
| CorreaPerro | accesorio | 194 | 800 | 2 |
| Telefono | telefono | 114 | 300 | 3 |

| Civil | Piezas | Triángulos | Tope |
|---|---|---|---|
| Ejemplo 1 | SacoOficina, PantalonVestir, PeloCorto, Maletin | 3.956 | 6.000 |
| Ejemplo 2 | BuzoCapucha, Jogging, Auriculares, Cafe | 4.042 | 6.000 |
| Ejemplo 3 | PilotoLargo, Pollera, PeloLargoAtado, ParaguasAbierto | 3.194 | 6.000 |
| Ejemplo 4 | ChalecoObra, Mameluco, Gorra, Telefono | 3.102 | 6.000 |
| Ejemplo 5 | UniformeEnfermeria, Jean, Rulos, BolsaCompras | 4.616 | 6.000 |
| Ejemplo 6 | RemeraEstampa, Bermuda, PeladoBarba, CorreaPerro | 3.498 | 6.000 |
| Ejemplo 7 | CamperaJean, Jean, GorroLana, Mochila | 4.554 | 6.000 |
| Ejemplo 8 | CamisaCuadros, PantalonVestir, Sombrero, ParaguasCerrado | 4.153 | 6.000 |
| Ejemplo 9 | SacoOficina, Pollera, Rulos, Telefono | 4.214 | 6.000 |
| Ejemplo 10 | BuzoCapucha, Bermuda, Gorra, Mochila | 4.216 | 6.000 |
| Ejemplo 11 | PilotoLargo, PantalonVestir, PeladoBarba, Maletin | 4.426 | 6.000 |
| Ejemplo 12 | RemeraEstampa, Jogging, PeloLargoAtado, Cafe | 3.384 | 6.000 |
| Diarero (especial) | CamisaCuadros, Jean, Gorra, Diarero | 4.846 | 8.000 |
| Vendedor (especial) | RemeraEstampa, PantalonVestir, Gorra, Vendedor | 4.050 | 8.000 |
| Musico (especial) | CamperaJean, Jogging, GorroLana, Musico | 5.018 | 8.000 |

Civil más pesado posible (la combinación más cara de arriba + abajo + cabeza + accesorio): 5.952 triángulos.

## Reglas para el código
- Color1 y Color2 se ponen con `MeshPart.Color`. En pelos, Color2 (hebilla, gomita, anteojos) sale de una paleta de colores vivos para que no se confunda con el pelo.
- Un civil lleva 1 de arriba + 1 de abajo + 1 de cabeza + 0 o 1 accesorio. El teléfono aparece solo cuando llama a la policía.

## Bocetos (aprobados)
![[civiles_boceto_grilla.png]]
![[civiles_boceto_ejemplos.png]]

Script: `linajes/arte/scripts/civiles.py`. Volver a [[Personajes]]
