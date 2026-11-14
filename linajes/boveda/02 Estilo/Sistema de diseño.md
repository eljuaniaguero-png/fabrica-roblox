---
tags: [estilo, ui, hud, diseno]
---
# Sistema de diseño — Interfaz Editorial Oscura (`@r0aringexe`)

> [!note] Principio rector
> Toda la interfaz de **Linajes del Eclipse** (Menú, HUD, Creador, Árbol, Ruleta, Taller, Diálogos, Tab, Ajustes y Avisos) comparte un único lenguaje **editorial oscuro sin cajas pesadas**, implementado en `linajes/src/client/Tema.luau` y parametrizado en `Config.Hud` (`linajes/src/shared/Config.luau`), alineado con [[Guía de estilo]].

---

## 1. Reglas de Superficie, Contorno y Prohibiciones

### Prohibido en toda la UI y HUD

- Cajas opacas con esquinas redondeadas grandes (`UICorner >= 8 px`).
- Marcos barrocos/medievales plateados (`interfaz/03`, `06` históricos).
- Bordes neon cyan estilo cyberpunk o gradientes multicolor.
- Tipografías gruesas cartoon (`GothamBlack`) o fuentes distintas de `Oswald` (`Saira Condensed`, `Barlow`).
- Ventanas opacas cubriendo el HUD o bloqueando la escena de fondo sin aire visual.

### Capas oficiales de superficie

| Tipo de contenedor | Fondo y opacidad | Esquinas | Borde (`UIStroke`) |
|---|---|---|---|
| **HUD y Menú Principal** | Transparente (`BackgroundTransparency = 1`), apoyado en `Vineta` `#080A0E` pegada a los 4 bordes. | Recto (`0 px`) | Ninguno salvo en barras finas y rombos. |
| **Modales y Paneles** (Creador, Árbol, Ruleta, Taller, Ajustes) | `#0D1017` al **88 %** (`BackgroundTransparency = 0.12`). | `0 px` o bisel mínimo `2 px` | `1 px` Hueso `#EDE6D6` al **18 %** (`Transparency = 0.82`). |
| **Tarjeta / Fila interna** | `#141923` (reposo) · `#1D2433` (hover/activo). | `0–2 px` | `1 px` Hueso `18%`; sube a `1.5 px` al `75%` o color del Bando/Linaje al enfocar. |
| **Lista Tab jugadores** | `#0D1017` al **85 %** (`BackgroundTransparency = 0.15`). | `0 px` | `1 px` Hueso `18%` + acento izquierdo de `3 px` por bando. |
| **Cintillo *El Faro*** | `#080A0E` al **82 %** (`BackgroundTransparency = 0.18`). | `0 px` | Doble línea superior/inferior en Hueso tenue (`1 px`). |

---

## 2. Tipografía Única (`Oswald`)

Cargada en `Tema.luau` vía `rbxasset://fonts/families/Oswald.json`. Ningún script cliente puede declarar otra familia tipográfica.

| Peso | Uso obligatorio | Formato | Tracking (`Tema.espaciar`) |
|---|---|---|---|
| **`Oswald SemiBold`** | Títulos principales, nombre de jefe, botones primarios, nivel, temporizadores de recarga, daños. | Siempre **MAYÚSCULAS** en encabezados. | `2` espacios en títulos principales (`L I N A J E S`), `1` espacio en nombres de panel y jefe (`R E M A C H E`). |
| **`Oswald Regular`** | Cuerpo de diálogos NPC, descripciones cortas de habilidades/nodos, costos y números de taller. | Oración normal. | Sin espaciado extra (`0`). |
| **`Oswald Light`** | Subtítulos superiores tenues (estilo menú `@r0aringexe`), metadatos secundarios (Linaje, bando, rango, fama) y etiquetas en `#9FA7B5`. | Mayúsculas espaciadas en micro-subtítulos o normal en metadatos. | `1` en micro-subtítulos. |

### Escala base `1080p` (`UIScale` automático clamped `0.62 – 1.25`)

- **Titular Menú / Jefe grande:** `32 – 42 px`
- **Título de panel / Modal:** `22 – 26 px`
- **Diálogo en cinemática:** `20 px` (`Oswald Regular`, máx. `2` líneas de `~42` caracteres)
- **Botón / Pestaña / Opción de diálogo:** `16 – 18 px`
- **Cuerpo de lectura:** `15 – 16 px`
- **Micro-etiqueta / Tecla / Nombre flotante de matón:** `12 – 13 px`
- **Sombra de legibilidad universal:** `TextStrokeColor3 = #080A0E`, `TextStrokeTransparency = 0.55` (prohibido contorno negro duro de `Transparency = 0`).

---

## 3. Componentes Geométricos y Estados Interactivos

### Piezas distintivas (`Tema.luau`)

- **Rombo `45°` (`Tema.rombo`):** símbolo transversal del juego.
  - Rombo de Nivel HUD: `64 x 64 px`, relleno `#080A0E` 55 %, borde Hueso `1.5 px`, número `SemiBold`.
  - Slots de poder HUD (PC): **`92 px`** para `Z`, `X`, `C`, `V` (`separación = 112 px` entre centros); **`68 px`** satélite para Gadget `G`.
  - Nodos del Árbol de Linaje: rombos `45°` unidos por conectores rectos de **`1.5 px`**.
  - Perilla de sliders en Ajustes: rombo `14 px` sobre barra de `2 px`.
  - Viñetas / punteros de lista en Menú y Diálogos: prefijo `◇`.
- **Ornamento (`Tema.ornamento`):** línea horizontal fina que se desvanece hacia ambos extremos con un pequeño rombo central (`arte/hud/listas/`). Divide títulos principales y secciones sin crear cajas cerradas.
- **Botón de acción primaria (`CONFIRMAR`, `GIRAR`, `FABRICAR`, `DESBLOQUEAR`):** rectángulo angular `0–2 px`, relleno Hueso sólido **`#EDE6D6`** con texto **`#080A0E`** en `Oswald SemiBold` espaciado.

### Tabla de estados visuales

| Estado | Fondo / Borde | Ícono / Contenido |
|---|---|---|
| **Reposo** | `#141923` · borde `1 px` `#EDE6D6` (`18%`) | Tinta Hueso `#EDE6D6` / secundario `#9FA7B5`. |
| **Hover / Foco** | `#1D2433` · borde `1.5 px` `#EDE6D6` (`75%`) o color Bando/Linaje | Escala `1.03` en `0.16 s` (`Quart.Out`), texto pasa a Hueso puro. |
| **Activo / Equipado** | `#1D2433` + barra lateral `3 px` en color de Linaje o `#3FA86B` | Ícono tintado en color de Linaje (`ImageColor3`). |
| **Bloqueado / No disponible** | `#0D1017` · borde `1 px` `#565E6D` (`35%`) | Tinta e ícono apagados en `#565E6D`. |
| **Poder en Recarga (HUD)** | Rombo oscurecido (`0.65` opacidad) | Velo/barra vertical de progreso + contador `Oswald SemiBold` encima. |

---

## 4. Timings de Animación y Feedback

- **Transición UI estándar (abrir/cerrar panel, hover, pestaña):** `TweenService` `Enum.EasingStyle.Quart`, `Enum.EasingDirection.Out`, **`0.16 s`**.
- **Rastro de daño en barras de vida (`Config.Hud.DanioEspera`):** barra `#E8C9A0` aguarda **`0.45 s`** y luego desliza hasta la vida restante.
- **Desvanecimiento de barra contextual (enemigo/jefe):** desaparece a los **`4 s`** sin combate activo.
- **Máquina de escribir en diálogos:** **`40 caracteres/s`** (clic o toque completa la línea al instante).
- **Cinemáticas:** franjas negras `#080A0E` de **`10%`** arriba y abajo con `Tween 0.35 s`; botón `S A L T E A R` habilitado tras **`2 s`**.

---

## 5. Reglas Celular (`844 x 390`) y Ergonomía Táctil

- **Hitbox mínimo universal:** **`48 x 48 px` físicos** en todo botón, nodo, pestaña, rombo u opción de diálogo, incluso si el dibujo o el texto ocupan menos visualmente.
- **Zonas reservadas:**
  - **Esquina inferior izquierda:** reservada para el joystick virtual (la barra de vida/XP compactada no debe invadir la zona táctil del pulgar).
  - **Esquina inferior derecha:** arco ergonómico del pulgar derecho para `Ataque básico` y rombos `Z`, `X`, `C`, `V`, `G`, `Dash`, `Bloqueo` sin superposiciones.
- **Botón táctil de diálogo / cinemática:** altura mínima `48 px` con separación mínima de `8 px` entre opciones.

---

## 6. Inventario de las 10 Pantallas y Deuda de Migración

| # | Pantalla / Módulo | Disposición resumida | Estado actual en código / prompts |
|---|---|---|---|
| 1 | **Menú Principal** | Cámara orbital puerto/Eclipse (`DepthOfField` ON), título espaciado + `Ornamento` arriba izq., lista `◇` sin cajas abajo izq. | Diseño definido; código por construir. |
| 2 | **Creador (`P33-02` / `P36b`)** | Personaje 55 % izq. · panel `#0D1017` 88 % der. (`CUERPO · CARA · PELO · ROPA`), 10 tonos `TonosPiel`, 12 colores, botón `#EDE6D6`. | Prompt de referencia debe actualizarse de `Saira`/`Barlow` a `Oswald`. |
| 3 | **Ruleta de Linaje** | Anillos finos Hueso + puntero rombo izq.; lista de rarezas con barra `3 px` der.; `S E G U R O N/40`; botón `GIRAR`. | Migrado a `Tema.luau` en `Ruleta.client.luau`. |
| 4 | **HUD de Pelea** | `Vineta`, Nivel+Vida/Energía/XP abajo izq., Jefe/Rival abajo centro (`4 s`), 4 rombos poderes + `G` abajo der., barra matón `86x4 px` `< 35 studs`. | `Estado`, `Poderes`, `Combate` en `Tema.luau`; **`BarraMatones.client.luau` pendiente** (aún usa `GothamBlack`). |
| 5 | **Árbol (`ESTADÍSTICAS` \| `LINAJE`)** | 6 barras `4 px` con `+` en rombo; mapa nodos `45°` conectados por rectas `1.5 px` en 3 ramas + fila `Movimiento`. | Diseño definido; reemplazar concepto viejo de `P33c-05`. |
| 6 | **Diálogo NPC** | Sin HUD, `DepthOfField` ON, viñeta inferior densa, nombre con barra `3 px` de bando + `Ornamento` izq., hasta `4` opciones `◇` der. | Diseño definido; reemplazar caja vieja de `P33c-06`. |
| 7 | **Taller (`Tano` / Refugio)** | Lista izq. (`Traje`, `Gadgets`, `Vehículo` `Mk I–V`), visor 3D libre centro, costos `Tengo / Necesito` + `FABRICAR` der. | Diseño definido; limpiar concepto `P33c-07`. |
| 8 | **Lista Jugadores (`Tab`)** | Tarjeta compacta arriba der. (`#0D1017` 85 %), agrupada por los 4 bandos con barra vertical `3 px`. | Diseño definido; limpiar concepto `P33c-08`. |
| 9 | **Ajustes** | Panel centrado: 3 sliders barra `2 px` + rombo `14 px`, selector `CALIDAD: ALTO / BAJO`, toggle `Sacudida de cámara`. | Diseño definido; limpiar concepto `P33c-09`. |
| 10 | **Buscado + *El Faro*** | `1–5` estrellas angulares `#E03A3E` + anillo rojo sobre minimapa; cintillo superior negro 82 % para noticias. | Diseño definido; limpiar conceptos `P33c-10/11`. |

---

**Notas conectadas:** [[Guía de estilo]] · [[Colores]] · [[Nivel de detalle]]
