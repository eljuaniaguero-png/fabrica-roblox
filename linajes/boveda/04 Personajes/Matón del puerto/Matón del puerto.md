---
tags: [personaje, enemigo]
bando: "Cofradía (enemigo común)"
---
# Matón del puerto

**Estado:** Terminado y exportado (17 FBX en `linajes/arte/exports/enemigo-maton/`, texturas de 512 px; el gorro va 3 veces, una por color).
**Bando:** Cofradía (enemigo común de Puerto Óxido, aparece de a muchos)

Campera de cuero negra con el cuello levantado, gorro de lana, pañuelo que tapa nariz y boca, cadena enrollada en la mano derecha, jean y borcegos. Tres variantes que solo cambian el color del gorro: **rojo**, **verde** y **gris** (las mallas son las mismas).

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí (variante roja).

```3D
{
  "models": [
    {
      "name": "enemigo-maton.glb",
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
### Gorro rojo
![[enemigo-maton_vistas.png]]
### Gorro verde
![[enemigo-maton_verde_vistas.png]]
### Gorro gris
![[enemigo-maton_gris_vistas.png]]

## Primeros planos
![[enemigo-maton_cara.png]]
![[enemigo-maton_cara_verde.png]]
![[enemigo-maton_cara_gris.png]]
![[enemigo-maton_campera.png]]
![[enemigo-maton_cadena.png]]

## Triángulos

| Pieza | Triángulos | Presupuesto | Mallas |
|---|---|---|---|
| Campera | 2.932 | 3.000 | Campera, Campera_Acero, 4 mangas |
| Gorro | 1.176 | 1.200 | Gorro (la misma malla en los 3 colores) |
| Pañuelo | 728 | 800 | Panuelo |
| Cadena | 1.078 | 1.100 | Cadena |
| Pantalón | 1.072 | 1.100 | 4 perneras |
| Botas | 784 | 800 | BotaIzq, BotaDer |
| **Total** | **7.770** | **8.000** | |

Malla más pesada: 1.176 (Roblox acepta hasta 20.000). Las variantes no suman triángulos: en Roblox se sube **una sola malla de gorro** y se le cambia la textura.

## Boceto (aprobado)
![[enemigo-maton_boceto_vistas.png]]
![[enemigo-maton_boceto_variantes.png]]

Script: `linajes/arte/scripts/enemigos/maton.py`. Volver a [[Personajes]]
