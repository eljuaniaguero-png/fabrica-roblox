---
tags: [personaje, civil]
bando: "Civiles (calle viva)"
---
# Civiles

**Estado:** Retocado (1 nov) y en Studio: cantos rectos, detalles modelados, 0 choques entre piezas. Probado en Play con 9 civiles.
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
"Civil" cuenta la ropa y el accesorio; el cuerpo propio va aparte (es el mismo para todos).

| Pieza | Tipo | Triángulos | Tope | Mallas |
|---|---|---|---|---|
| CamperaJean | arriba | 542 | 2.500 | 7 |
| SacoOficina | arriba | 658 | 2.500 | 7 |
| BuzoCapucha | arriba | 318 | 2.500 | 7 |
| CamisaCuadros | arriba | 574 | 2.500 | 9 |
| PilotoLargo | arriba | 806 | 2.500 | 8 |
| ChalecoObra | arriba | 298 | 2.500 | 6 |
| RemeraEstampa | arriba | 426 | 2.500 | 5 |
| UniformeEnfermeria | arriba | 278 | 2.500 | 5 |
| Jean | abajo | 436 | 1.500 | 7 |
| PantalonVestir | abajo | 424 | 1.500 | 6 |
| Pollera | abajo | 192 | 1.500 | 3 |
| Jogging | abajo | 252 | 1.500 | 8 |
| Bermuda | abajo | 336 | 1.500 | 6 |
| Mameluco | abajo | 364 | 1.500 | 7 |
| Gorra | cabeza | 84 | 1.500 | 2 |
| GorroLana | cabeza | 200 | 1.500 | 2 |
| PeloCorto | cabeza | 60 | 1.500 | 2 |
| PeloLargoAtado | cabeza | 92 | 1.500 | 2 |
| Rulos | cabeza | 1.858 | 1.900 | 2 |
| PeladoBarba | cabeza | 348 | 1.500 | 2 |
| Sombrero | cabeza | 292 | 1.500 | 2 |
| Auriculares | cabeza | 256 | 1.500 | 2 |
| Maletin | accesorio | 108 | 800 | 2 |
| BolsaCompras | accesorio | 130 | 800 | 2 |
| Mochila | accesorio | 144 | 800 | 2 |
| ParaguasAbierto | accesorio | 146 | 800 | 2 |
| ParaguasCerrado | accesorio | 60 | 800 | 2 |
| Cafe | accesorio | 132 | 800 | 2 |
| CorreaPerro | accesorio | 108 | 800 | 2 |
| Telefono | telefono | 80 | 300 | 3 |

| Civil | Piezas | Triángulos | Tope |
|---|---|---|---|
| Ejemplo 1 | SacoOficina, PantalonVestir, PeloCorto, Maletin | 1.250 | 6.000 |
| Ejemplo 2 | BuzoCapucha, Jogging, Auriculares, Cafe | 958 | 6.000 |
| Ejemplo 3 | PilotoLargo, Pollera, PeloLargoAtado, ParaguasAbierto | 1.236 | 6.000 |
| Ejemplo 4 | ChalecoObra, Mameluco, Gorra, Telefono | 826 | 6.000 |
| Ejemplo 5 | UniformeEnfermeria, Jean, Rulos, BolsaCompras | 2.702 | 6.000 |
| Ejemplo 6 | RemeraEstampa, Bermuda, PeladoBarba, CorreaPerro | 1.218 | 6.000 |
| Ejemplo 7 | CamperaJean, Jean, GorroLana, Mochila | 1.322 | 6.000 |
| Ejemplo 8 | CamisaCuadros, PantalonVestir, Sombrero, ParaguasCerrado | 1.350 | 6.000 |
| Ejemplo 9 | SacoOficina, Pollera, Rulos, Telefono | 2.788 | 6.000 |
| Ejemplo 10 | BuzoCapucha, Bermuda, Gorra, Mochila | 882 | 6.000 |
| Ejemplo 11 | PilotoLargo, PantalonVestir, PeladoBarba, Maletin | 1.686 | 6.000 |
| Ejemplo 12 | RemeraEstampa, Jogging, PeloLargoAtado, Cafe | 902 | 6.000 |
| Diarero (especial) | CamisaCuadros, Jean, Gorra, Diarero | 1.766 | 8.000 |
| Vendedor (especial) | RemeraEstampa, PantalonVestir, Gorra, Vendedor | 1.502 | 8.000 |
| Musico (especial) | CamperaJean, Jogging, GorroLana, Musico | 1.532 | 8.000 |

Civil más pesado posible (la combinación más cara de arriba + abajo + cabeza + accesorio): 3.246 triángulos.

## Cómo se armó (1 nov)
- **Estilo:** ropa de cantos rectos pegada al cuerpo de bloques, con costuras, dobladillos, bolsillos, botones y presillas modelados (referencias de estilo de Juani, sin copiar diseños).
- **Nada atraviesa nada:** `civiles.py -- chequear` arma todas las combinaciones posibles y cuenta piezas que se cruzan. Da **0**. Capas: cuerpo → pantalón → prenda de arriba → accesorios. Las mangas no se agrandan hacia el cuerpo (en el R15 el brazo pisa la cadera) y las telas de la cadera son tubos abiertos.
- **Sin horneado ni bisel:** en el juego van con color liso (`MeshPart.Color`) y cantos rectos; el horneado ensuciaba las telas abiertas.
- **Teléfono:** mientras el civil llama, se oculta lo que tenga en la mano derecha.

## Reglas para el código
- Color1 y Color2 se ponen con `MeshPart.Color`. En pelos, Color2 (hebilla, gomita, anteojos) sale de una paleta de colores vivos para que no se confunda con el pelo.
- Un civil lleva 1 de arriba + 1 de abajo + 1 de cabeza + 0 o 1 accesorio. El teléfono aparece solo cuando llama a la policía.

## Bocetos (aprobados)
![[civiles_boceto_grilla.png]]
![[civiles_boceto_ejemplos.png]]

Script: `linajes/arte/scripts/civiles.py`. Volver a [[Personajes]]
