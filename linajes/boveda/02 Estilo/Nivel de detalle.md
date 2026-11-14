---
tags: [estilo, modelos, texturas, rendimiento]
---
# Nivel de detalle — Geometría, Texturas y Presupuesto Técnico

> [!note] Regla de oro en estudio y móvil
> Este documento fija los números técnicos obligatorios para modelar en Blender, hornear texturas con `pintura.py`, exportar `.glb` y correr fluidamente tanto en PC (`Alto`) como en celular (`Bajo`), respetando [[Guía de estilo]].

---

## 1. Estándar de Geometría: "Cómic Nítido" (`CuerpoComic`)

| Regla | Personajes y ropa R15 | Pelos (`MeshPart` en `Head`) | Arquitectura, calles y props |
|---|---|---|---|
| **Base / Silueta** | Rig R15 estándar (~`5.8 studs`), piezas soldadas por hueso (`CuerpoComic.luau`). Jefe/mentores escalan el mismo R15 (`Albatros 0.9x/1.2x`, `Remache 1.3x–1.35x`). | **`1` sola `MeshPart`** cubriendo frente (cejas libres), laterales y nuca completa. | Grilla modular de **`4 studs`**. Puerta `5x8`, portón `12–14x10–11`, piso `13`, techo interior `16–22`. |
| **Chaflán (`Bevel`)** | `1` corte seco (`0.025–0.04` studs) en placas, solapas, cinturón, botas y hombreras. | Aristas y crestas en cuña prismática limpia. | `1–2` cortes (`0.03–0.05` studs chico/interior; `0.06–0.08` studs edificios, contenedores y autos). |
| **Sombreado (`Normals`)** | `Auto Smooth 35°` / `Weighted Normal` + `Mark Sharp` en todos los quiebres de ropa, armadura y suelas. | `Mark Sharp` obligatorio a lo largo de la espina central y filo de cada mechón. | `Auto Smooth 35°` + `Mark Sharp` en vigas, chapas, marcos y cantos rectos. |
| **Capas y telas** | Láminas sólidas con grosor **`0.08–0.12` studs** y pliegues angulares esculpidos. | Cuñas poligonales angulares (nunca tubos/bananas redondeadas). | Chapas y toldos con grosor real mínimo `0.06` studs (sin planos de grosor cero salvo calcos). |
| **Prohibido** | `Subdivision Surface` suave sobre torsos/hombreras ("efecto almohadón"), hileras de micro-remaches cada `0.05` studs, grietas flotantes. | Mechones tipo gota con `Shade Smooth` brillante. | Grietas de asfalto, manchas de aceite, charcos o juntas de baldosa modelados como plaquitas `0.02` studs (todo eso va en textura). |

---

## 2. Texturas, `pintura.py` y `SurfaceAppearance`

### Reglas de `ColorMap` (Albedo) y Líneas de Tinta

- **CERO ruido procedural de estática/TV:** ni en camperas (`cuervo_v2`), ni en paredes, ni en pisos. Las superficies llevan planos limpios o pincelada ancha suave.
- **Pintado en mundo (`pintura.py`) para arquitectura y props:**
  - Desaturación ligera del albedo base para que personajes y VFX destaquen encima.
  - Variación tonal entre paneles vecinos (`±5–8 %` de valor).
  - Aclarado en aristas convexas (`+10–15 %` valor o acero pelado `#6B7380`).
  - Chorreadas por gravedad (eje `Z` mundial hacia abajo) de óxido `#6E4A35` y humedad bajo marcos/ventanas + AO oscuro `#0E1016` al `35–50%` en esquinas y zócalos.
- **Líneas de tinta cómic en personajes y props clave:** trazos nítidos en `#0E1016` de **`2–4 px`** (medido sobre mapa `1024 px`) delimitando solapas, bolsillos, costuras de pantalón, pliegues de bota y división de placas + borde aclarado (`+10–14 %`) alrededor de piezas oscuras (`>= #1D2230`).
- **Tamaños y canales por tipo de archivo:**
  - Todo UV dentro de `[0, 1]` sin solapamiento en mallas horneadas.
  - **`NormalMap`:** siempre **OpenGL (`+Y` arriba)** en espacio tangente. Blender hornea con *View Transform = Standard*.
  - **`SurfaceAppearance`:** exactamente **`1`** por `MeshPart`.
  - **Pintura tintable por código:** ropa modular y civiles usan máscaras/canales limpios (`_C1`, `_C2`) en gris neutro claro para colorear en Studio/cliente sin teñir la tinta ni ensuciar el sombreado.

### Valores oficiales de `RoughnessMap` (`0 = espejo`, `1 = tiza mate`)

| Superficie | Roughness | Metalness / Notas |
|---|---|---|
| **Asfalto / vereda seca** | `0.78 – 0.88` | `0.0`. Micro-variación ancha de adoquín/losa. |
| **Asfalto húmedo (bajo faroles)** | `0.24 – 0.38` | `0.0`. Refleja focos `#F29A3A` sin mojar toda la manzana por igual. |
| **Charcos (calco o máscara)** | `0.06 – 0.12` | Borde orgánico suave (nunca rectángulo duro). |
| **Ladrillo y hormigón viejo** | `0.82 – 0.92` | `0.0`. `NormalMap` solo para juntas anchas. |
| **Chapa acanalada pintada** | `0.55 – 0.70` | Partes oxidadas suben a `0.86–0.94`; bordes pelados bajan a `0.32`. |
| **Acero industrial (grúas, caños)** | `0.35 – 0.52` | `Metalness 0.75 – 0.95` únicamente en metal expuesto. |
| **Madera (muelle, banco, cajones)** | `0.74 – 0.86` | `0.0`. Manchas de aceite puntuales bajan a `0.20`. |
| **Vidrio exterior (`Glass_`)** | `0.08 – 0.15` | Tintado oscuro o cálido interior (`#F29A3A` 40–60 %) antes que cajas huecas costosas. |
| **Ropa / tela estándar** | `0.78 – 0.90` | `0.0`. Mismo acabado mate satinado en base y conjuntos. |
| **Pelo poligonal** | `0.65 – 0.75` | `0.0`. Degradado en `2–3` valores + trazos `#0E1016` entre grandes mechones. |
| **Emisivos (`Neon_`)** | — | **`< 5 %` del campo visual total** (ventanas, faros, tableros chicos, cartel puntual). |

---

## 3. Presupuesto de Triángulos y Resoluciones

**Límite absoluto de Roblox Studio:** ninguna `MeshPart` individual puede superar **`20.000` triángulos**. Los modelos que pasan de `20.000` en total se exportan divididos por hueso/módulo (`Torso`, `Abrigo`, `Cabeza`, `Arma`, etc.).

| Categoría | Presupuesto total (referencia verificada) | Tope por `MeshPart` | Resolución textura |
|---|---|---|---|
| **Cara (`Decal` en `Head`)** | — (`Head` biselado) | — | `256 x 256` RGBA PNG (`8` expresiones + parpadeo + `3` visemas). |
| **Pelo (`MeshPart`)** | `400 – 900` tris (máx. `1.400`) | `1.400` | `512 x 512` |
| **Jugador — Base ("Atuendo Básico")** | `4.000 – 8.000` tris | `<= 3.000` | `512 x 512` |
| **Jugador — Ropa comprable (`Urbano` y sets)** | `8.000 – 18.000` tris | `<= 6.000` | `512 – 1024 px` |
| **Civiles (`Calle viva`)** | `1.000 – 3.000` tris | `<= 1.500` | `512 x 512` |
| **Enemigos comunes (`Matón`, implantes)** | `7.500 – 10.000` tris (ej. *Matón implantes*: `9.728`) | `<= 3.000` (objetivo `1.200` en piezas chicas) | `512 x 512` |
| **NPCs clave (`Tano`, `Rivas`, etc.)** | `12.000 – 20.000` tris (ej. *Tano*: `19.579`) | `<= 3.000 – 8.000` | `512 – 1024 px` |
| **Mentores y Jefes** | `22.000 – 38.000` tris (ej. *Albatros*: `23.002`, *Mascarada*: `30.552`, *Atalanta*: `31.326`, *Centinela*: `35.266`) | `<= 20.000` (ej. abrigo *Albatros* `10.766 / 11.000`) | `1024 x 1024` |
| **Interiores / Talleres / Bloques de calle** | `~40.000` tris por interior completo | `<= 20.000` por malla | `2048 px` piso repetible · `1024 px` arquitectura/hitos · `512 px` muebles · `256 px` micro-props |
| **Íconos 2D de HUD / UI** | — | — | Fuente `512 x 512` (`6%` margen), subida `256 / 128 px`, legible a `42 px`. |

---

## 4. Colisiones, Sombras y Modo `Alto` vs `Bajo` (Celular)

### Colisiones y contacto con el suelo

- Toda malla arquitectónica compleja (escaleras, barandas, grúas, autos, elevadores, estatuas) lleva **`CanCollide = false`** y usa piezas invisibles `_Colision` (`12–36` tris) para física limpia sin trabas.
- Todo prop estático pequeño o mediano apoyado (tambores, cajas, tachos, faroles, banco) lleva debajo una placa `SurfaceGui` con sombra de contacto (`#000000` al `35–45 %`) para seguir anclado al piso cuando se apagan sombras dinámicas.

### Iluminación y Streaming

- `Lighting.Technology = Future`, `Bloom.Threshold >= 1.6`, `DepthOfField` apagado durante exploración/combate.
- Máximo **`2–3` luces con `Shadows = true`** por interior o cuadra abierta; el resto de focos secundarios usa `Shadows = false`.
- `Workspace.StreamingEnabled = true`, radio objetivo **`512` studs**.

### Calidad `Alto` (PC) vs `Bajo` (Celular — `Ajustes`)

| Sistema | `Alto` (PC / gama alta) | `Bajo` (Celular) |
|---|---|---|
| **Emisión de partículas (`ParticleEmitter.Rate`)** | `100 %` (`1.0x`) | **`50 %` (`Rate * 0.5`)** |
| **Luces dinámicas en VFX (`PointLight`)** | Activas con fade breve | **`0` luces dinámicas en proyectiles o partículas** |
| **Impact Frame (`ColorCorrection`)** | Activo (`25–40 ms` en golpe 4 / parry / ult) | **Desactivado** |
| **Duración de humo / polvo** | `100 %` | **`-35 %`** |
| **Lectura de combate (`Aviso` rojo en piso y anillo de impacto)** | `100 %` | **`100 %` intacto (nunca se simplifica ni se oculta)** |

---

**Notas conectadas:** [[Guía de estilo]] · [[Colores]] · [[Sistema de diseño]] · [[Cuerpo propio]] · [[Arena en Blender]]
