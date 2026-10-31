---
tags: [personaje]
bando: "Liga"
nombre_de_trabajo: "Wonder Woman"
---
# Atalanta

**Estado:** Terminado y exportado.
**Bando:** Liga · **Nombre de trabajo (DC):** Wonder Woman (no va en el juego publicado, ver [[Sobre DC]])

Guerrera de las Hespérides, isla griega oculta. Armadura de hoplita de bronce, escudo redondo grande con una manzana dorada y una hoja, y lanza más alta que ella. Sin tiara con estrella, sin lazo, sin águila ni "W", sin bustier rojo-azul-dorado.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí.

```3D
{
  "models": [
    {
      "name": "atalanta.glb",
      "scale": 1,
      "position": [0, 0, 0],
      "rotation": [0, 0, 0]
    }
  ],
  "camera": {
    "LookatXYZ": [0, 0.9, 0],
    "camPosXYZ": [0, 1.1, 4.2]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [0, 0.006, 0]
  }
}
```

## 3 vistas
![[atalanta_vistas.png]]

## Primeros planos
![[atalanta_casco.png]]
![[atalanta_escudo.png]]
![[atalanta_lanza.png]]

## Boceto (paso 1)
![[atalanta_boceto_vistas.png]]

## Piezas y triángulos
| Pieza | Parte del cuerpo | Triángulos | Presupuesto | Mallas |
|---|---|---|---|---|
| Casco corintio, crin azul liga en mechones | Head | 6.856 | 7.000 | 2 |
| Coraza musculada con olivo grabado + pteruges en 2 filas con tachas | UpperTorso + LowerTorso | 7.832 | 8.000 | 5 |
| Capa corta azul liga (tela simulada), 2 broches de oro | UpperTorso | 3.918 | 4.000 | 2 |
| Brazaletes con meandro (par) | LowerArms | 1.960 | 2.000 | 2 |
| Grebas y sandalias (par) | LowerLegs + Feet | 3.912 | 4.000 | 6 |
| Escudo 1,8 studs, manzana dorada con hoja, borde de oro | LeftHand | 4.896 | 5.000 | 3 |
| Lanza 6 studs, punta de laurel, empuñadura de cuero | RightHand | 1.952 | 2.000 | 4 |
| **Total** | | **31.326** | **32.000** | |

Malla más pesada: 3.782 triángulos (Roblox acepta hasta 20.000).

## Datos
- **Script:** `linajes/arte/scripts/personajes/atalanta.py`
- **Blender:** `linajes/arte/blender/atalanta.blend`
- **Texturas:** `linajes/arte/blender/texturas/atalanta/` (color con desgaste, rugosidad y normal OpenGL, 1024 px)
- **Exportado a Roblox:** `linajes/arte/exports/atalanta/` (24 mallas, un material cada una; la punta de la lanza va aparte)

Volver a [[Personajes]]
