---
tags: [personaje]
bando: "Cofradía (jefe)"
nombre_de_trabajo: "Bane"
---
# Remache

**Estado:** Terminado y exportado. Jefe a 1,6 veces el tamaño de un jugador.
**Bando:** Cofradía (jefe) · **Nombre de trabajo (DC):** Bane (no va en el juego publicado, ver [[Sobre DC]])
**Prompt:** [[P06 Remache]]

Matón enorme del puerto con implantes hidráulicos robados de Corona Corp: torso en V, brazos de pistones, puños-martillo y casco de soldador con visor rojo. Sin máscara de luchador ni tanque en la espalda.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí.

```3D
{
  "models": [
    {
      "name": "remache.glb",
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
      1.32,
      0
    ],
    "camPosXYZ": [
      0,
      1.56,
      6.24
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
![[remache_vistas.png]]

## Primeros planos
![[remache_brazo.png]]
![[remache_columna.png]]

## Boceto (paso 1)
![[remache_boceto_vistas.png]]

## Datos
- **Triángulos:** 29.222 de 37.000. Ninguna malla pasa los 20.000 que acepta Roblox.
- **Script:** `linajes/arte/scripts/personajes/remache.py`
- **Blender:** `linajes/arte/blender/remache.blend`
- **Exportado a Roblox:** `linajes/arte/exports/remache/` (los 4 pistones son mallas aparte, para animarlos)

Volver a [[Personajes]]
