---
tags: [personaje]
bando: "Cofradía"
nombre_de_trabajo: "Pingüino"
---
# El Albatros

**Estado:** Terminado y exportado.
**Bando:** Cofradía · **Nombre de trabajo (DC):** Pingüino (no va en el juego publicado, ver [[Sobre DC]])

Jefe mafioso de Puerto Óxido, dueño del contrabando. Bajo y ancho (maniquí a 0,9x de alto y 1,2x de ancho), abrigo largo de capitán de barco hasta las pantorrillas, gorra de capitán y bastón-arpón. Diseño propio: sin smoking ni frac, sin monóculo, sin paraguas, sin nariz ganchuda.

## Modelo 3D
Arrastrá con el mouse para girarlo y usá la rueda para acercarte. Se ve sobre el maniquí.

```3D
{
  "models": [
    {
      "name": "albatros.glb",
      "scale": 1,
      "position": [0, 0, 0],
      "rotation": [0, 0, 0]
    }
  ],
  "camera": {
    "LookatXYZ": [0, 0.75, 0],
    "camPosXYZ": [0, 0.95, 3.6]
  },
  "scene": {
    "backgroundColor": "1b1f2a",
    "autoRotation": [0, 0.006, 0]
  }
}
```

## 3 vistas
![[albatros_vistas.png]]

## Primeros planos
Gorra (ancla en la banda, albatros arriba, cordón doble y visera de charol):
![[albatros_gorra.png]]
Bastón-arpón (punta con dos púas, virola, argolla, cadena enrollada y mango de cuero):
![[albatros_baston.png]]
Emblema propio en la espalda del abrigo:
![[albatros_emblema.png]]

## Triángulos
| Pieza | Triángulos | Presupuesto | Mallas |
|---|---|---|---|
| Gorra | 2.938 | 3.000 | Gorra, Gorra_Charol, Gorra_Oro |
| Abrigo | 10.766 | 11.000 | Abrigo, Abrigo_Cuero, Abrigo_Oro, Abrigo_PielGris, MangaDer, MangaIzq, PunoDer, PunoIzq |
| Bufanda | 1.960 | 2.000 | Bufanda |
| Bastón-arpón | 2.936 | 3.000 | Baston, Baston_Acero, Baston_Cuero |
| Guantes y botas | 3.916 | 4.000 | BotaDer, BotaIzq, GuanteDer, GuanteIzq |
| Emblema | 486 | 500 | Emblema, EmblemaGorra |
| **Total** | **23.002** | **23.500** | |

Malla más pesada: 4.396 (Roblox acepta hasta 20.000). Bisel, normal map OpenGL de 1024 px y desgaste en todo; el emblema va sin bisel porque con bisel no entra en 500 triángulos.

## Boceto (paso 1)
![[albatros_boceto_vistas.png]]

## Datos
- **Script:** `linajes/arte/scripts/personajes/albatros.py`
- **Blender:** `linajes/arte/blender/albatros.blend`
- **Exportado a Roblox:** `linajes/arte/exports/albatros/` (21 mallas FBX, una por material)

Volver a [[Personajes]]
