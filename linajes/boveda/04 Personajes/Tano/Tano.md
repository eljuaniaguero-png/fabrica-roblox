---
tags: [personaje, npc]
bando: "Civil (NPC)"
---
# Tano

**Estado:** Terminado y exportado (20 FBX en `linajes/arte/exports/npc-tano/`, texturas de 512 px).
**Bando:** Civil (NPC, no es superhéroe)

Mecánico del taller: mameluco azul engrasado con las mangas arremangadas, delantal de cuero con herramientas en el bolsillo, trapo rojo colgando del bolsillo de atrás, gorra de trabajo, bigote canoso y llave inglesa en la mano derecha.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí.

```3D
{
  "models": [
    {
      "name": "npc-tano.glb",
      "scale": 1,
      "position": [0, 0, 0],
      "rotation": [0, 0, 0]
    }
  ],
  "camera": {
    "LookatXYZ": [0, 1.0, 0],
    "camPosXYZ": [0, 1.2, 4.6]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [0, 0.006, 0]
  }
}
```

## 3 vistas
![[npc-tano_vistas.png]]

## Primeros planos
![[npc-tano_cara.png]]
![[npc-tano_delantal.png]]
![[npc-tano_llave.png]]
![[npc-tano_trapo.png]]

## Triángulos
| Pieza | Triángulos | Presupuesto |
|---|---|---|
| Mameluco (torso, mangas, perneras, cierre) | 8.317 | 8.500 |
| Delantal (cuero y herrajes) | 2.936 | 3.000 |
| Gorra | 2.450 | 2.500 |
| Bigote | 1.568 | 1.600 |
| Trapo | 784 | 800 |
| Llave inglesa | 980 | 1.000 |
| Botines | 2.544 | 2.600 |
| **Total** | **19.579** | **20.000** (rango NPC: 12.000 a 20.000) |

La malla más pesada tiene menos de 3.000 (tope de Roblox: 20.000 por malla). Un material por malla.

## Boceto (paso 1)
![[npc-tano_boceto_vistas.png]]

Script: `linajes/arte/scripts/npcs/tano.py`. Volver a [[Personajes]]
