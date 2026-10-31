---
tags: [personaje]
bando: "Todos"
---
c# Cuerpo propio

**Estado:** Paso 3: en el juego. En Studio es el StarterCharacter (Roblox ya no carga el avatar) y el servidor lo arma con la apariencia del jugador.
**Ficha:** [[Cuerpo propio (sin avatar de Roblox)]] · **Prompt:** [[P20f Cuerpo propio del jugador]]

El cuerpo que usan todos en vez del avatar de Roblox. **Estilo nuevo (pedido del 31 oct):** bloques redondeados como Roblox, cabeza cuadrada grande, cara anime y pelo de mechones en punta. Mismo esqueleto R15 del maniquí: no se movió ningún hueso.

## En el juego (Play en Studio)
Un jugador con apariencia al azar: contextura Normal, altura Baja, tono 6, cara 12, peinado Rapado y marca 4.

![[cuerpo_studio.png]]

## Modelo 3D
Arrastrá con el mouse para girarlo. Contextura Normal, cara 01, peinado Corto.

```3D
{
  "models": [
    {
      "name": "cuerpo.glb",
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

## Vistas
Filas: frente, costado, espalda. Columnas: Normal, Ancha (hombros +20 %) y Delgada (hombros y cadera -12 %), cada una con otro tono, cara y peinado.

![[cuerpo_vistas.png]]

## Caras (12) y expresiones (8)
Las 12 caras neutrales (las texturas están en `arte/exports/cuerpo/caras/`, con la hoja 4x3 `hoja_caras.png`):

![[cuerpo_caras.png]]

Las 8 expresiones (neutral, enojado, contento, sorprendido, dolor, concentrado, cansado, derrotado), en la cara 01 y la 07. En el juego se cambian por código, cambiando la textura de la cabeza.

![[cuerpo_expresiones.png]]

## Peinados (12)
Corto, Rapado, Pinchos, Cresta, Melena, Cola, Rodete, Dos rodetes, Afro, Flequillo, Peinado atrás y Trenzas. Un material, color libre.

![[cuerpo_peinados.png]]

## Tonos de piel (10) y marcas (6)
Los tonos están en `src/shared/Config.luau` (`Config.Cuerpo.TonosPiel`).

![[cuerpo_tonos.png]]

Marcas: cicatriz en el ojo, tajo en la mejilla, cruz en la nariz, quemadura, rayas pintadas y cortes en la sien.

![[cuerpo_marcas.png]]

## Triángulos
| Pieza | Triángulos |
|---|---|
| Cabeza | 952 |
| Torso (arriba + abajo) | 576 |
| Brazos (4 piezas) | 1.152 |
| Manos (con pulgar) | 496 |
| Piernas (4 piezas) | 1.152 |
| Pies | 336 |
| **Cuerpo** | **4.664 de 4.000 a 6.000** |
| Peinados | 1.006 a 1.600 cada uno (de 1.000 a 2.000) |

## Notas
- Referencias del estilo en `arte/referencias/anime/` (capturas de otro juego: solo ideas, no se suben ni se copian).
- Las contexturas son shape keys: cambian el ancho, no los huesos.
- Boceto anterior (cuerpo redondo, descartado): ![[cuerpo_boceto_vistas.png]]
- **En Studio (paso 3):** `StarterPlayer.StarterCharacter` con nuestras mallas y articulaciones Motor6D del R15; `LoadCharacterAppearance` apagado. Los peinados son accesorios en `ServerStorage.Cuerpo.Peinados`. La cara y la marca son decals en el frente de la cabeza (IDs en `Config.Cuerpo.Caras` y `Config.Cuerpo.Marcas`). La contextura ensancha el torso y corre las articulaciones. La altura usa `ScaleTo`.
- Código: `src/server/Apariencia.luau` (arma el cuerpo y cambia la expresión), `src/server/Cuerpo.server.luau` y `src/character/Animate.client.luau` (nuestro Animate).
- Pendiente: las animaciones son por ahora las de base de Roblox para R15 (se cambian en `Config.Animaciones`). La apariencia sale al azar fija por jugador hasta que exista el creador de personaje con guardado.

Volver a [[Personajes]]
