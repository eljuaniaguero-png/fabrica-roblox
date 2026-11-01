---
tags: [personaje]
bando: "Cofradía"
nombre_de_trabajo: "Joker"
---
# Mascarada

**Estado:** Terminado y exportado (en 3D se ve con la máscara Tragedia).
**Bando:** Cofradía · **Nombre de trabajo (DC):** Joker (no va en el juego publicado, ver [[Sobre DC]])
**Prompt:** [[P05 Mascarada]]

Villano teatral: saco largo con cola partida, sombrero de copa torcido y una máscara distinta por fase (Tragedia, Comedia y Ninguna). Sin maquillaje de payaso.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí.

```3D
{
  "models": [
    {
      "name": "mascarada.glb",
      "scale": 1,
      "position": [
        0,
        0,
        0
      ],
      "rotation": [
        0,
        0,
        0
      ]
    }
  ],
  "camera": {
    "LookatXYZ": [
      0,
      0.8800000000000001,
      0
    ],
    "camPosXYZ": [
      0,
      1.04,
      4.16
    ]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [
      0,
      0.006,
      0
    ]
  }
}
```

## 3 vistas
![[mascarada_vistas.png]]

## Primeros planos
![[mascarada_mascaras.png]]
![[mascarada_tragedia.png]]
![[mascarada_comedia.png]]
![[mascarada_ninguna.png]]

## Boceto (paso 1)
![[mascarada_boceto_vistas.png]]

## Datos
- **Triángulos:** 30.552 de 32.000 (24.682 puesto, con una máscara a la vez). Ninguna malla pasa los 20.000 que acepta Roblox.
- **Script:** `linajes/arte/scripts/personajes/mascarada.py`
- **Blender:** `linajes/arte/blender/mascarada.blend`
- **Exportado a Roblox:** `linajes/arte/exports/mascarada/`

Volver a [[Personajes]]
