---
tags: [personaje, enemigo]
bando: "Cofradía (enemigo común)"
---
# Matón con implantes

**Estado:** Terminado y exportado (FBX en `linajes/arte/exports/enemigo-maton-implantes/`, texturas de 512 px; el brazo va 3 veces, una por metal).
**Bando:** Cofradía (enemigo común de Puerto Óxido y Ciudad Vórtice)

Es el [[Matón del puerto]] (misma campera, pañuelo, jean y borcegos) con el **brazo derecho de metal** (pistón hidráulico del hombro al codo, dedos gruesos) y un **ojo implantado que brilla en rojo** (`neon-aviso`). La cadena pasa a la mano izquierda y el gorro va siempre gris, para distinguirlo del matón común de un vistazo. Tres variantes que solo cambian el metal del brazo: **acero**, **óxido** y **bronce** (las mallas son las mismas).

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí (brazo de acero).

```3D
{
  "models": [
    {
      "name": "enemigo-maton-implantes.glb",
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
### Brazo de acero
![[enemigo-maton-implantes_vistas.png]]
### Brazo de óxido
![[enemigo-maton-implantes_oxido_vistas.png]]
### Brazo de bronce
![[enemigo-maton-implantes_bronce_vistas.png]]

## Primeros planos
![[enemigo-maton-implantes_brazo.png]]
![[enemigo-maton-implantes_brazo_oxido.png]]
![[enemigo-maton-implantes_brazo_bronce.png]]
![[enemigo-maton-implantes_ojo.png]]

## Triángulos

| Pieza | Triángulos | Presupuesto | Mallas |
|---|---|---|---|
| Campera (sin la manga derecha) | 2.348 | 2.400 | Campera, Campera_Acero, 2 mangas |
| Gorro | 1.176 | 1.200 | Gorro |
| Pañuelo | 728 | 800 | Panuelo |
| Cadena | 1.078 | 1.100 | Cadena |
| Pantalón | 1.072 | 1.100 | 4 perneras |
| Botas | 784 | 800 | BotaIzq, BotaDer |
| Brazo de metal | 2.152 | 2.200 | BrazoArriba, BrazoAbajo, BrazoMano (las mismas en los 3 metales) |
| Ojo | 390 | 400 | Ojo, OjoLente (Neon) |
| **Total** | **9.728** | **10.000** | |

Malla más pesada: 1.176 (Roblox acepta hasta 20.000). Las variantes no suman triángulos: en Roblox se sube **un solo brazo** y se le cambia la textura.

## Boceto (aprobado)
![[enemigo-maton-implantes_boceto_vistas.png]]
![[enemigo-maton-implantes_boceto_variantes.png]]

Script: `linajes/arte/scripts/enemigos/maton_implantes.py`. Volver a [[Personajes]]
