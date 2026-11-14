---
tags: [estilo, colores, paleta]
---
# Colores oficiales de Linajes del Eclipse

> [!note] Fuente única de color
> Todos los códigos hexadecimales de UI/HUD, bandos, rarezas, Linajes y tonos de piel deben definirse en `linajes/src/shared/Config.luau` (`Config.Hud`, `Config.Cuerpo.TonosPiel`) y `linajes/src/shared/Iluminacion.luau`, en sincronía estricta con [[Guía de estilo]].

---

## 1. Interfaz Editorial y HUD (`Config.Hud` + `Tema.luau`)

| Token visual | Hex | Opacidad / Uso exacto |
|---|---|---|
| **Fondo pantalla / viñeta** | `#080A0E` | Tinta base oscura, viñeta de bordes en HUD/menú, texto sobre botón sólido Hueso y sombreado sutil `TextStrokeColor3` (`TextStrokeTransparency = 0.55`). |
| **Fondo modal / overlay** | `#0D1017` | Superficie de Creador, Árbol, Taller, Ruleta, Ajustes y Tab (`BackgroundTransparency = 0.12`, 88 % opaco). |
| **Tarjeta / fila en reposo** | `#141923` | Celda de catálogo, fila de lista y contenedor interno de modal. |
| **Hover / selección activa** | `#1D2433` | Estado al pasar el mouse o enfocar una fila/celda. |
| **Hueso primario** | `#EDE6D6` | Titulares, texto principal, marcos rombo `MarcoRombo`, ornamentos, íconos 2D monocromo (tintados por `ImageColor3`), botón primario sólido y **esclerótica de ojos**. |
| **Borde estructural** | `#EDE6D6` | `UIStroke` de `1 px` al **18 % de opacidad** (`Transparency = 0.82`); sube a `1.5 px` al 75 % en hover/selección. |
| **Tinta secundaria** | `#9FA7B5` | Subtítulos, metadatos, teclas de atajo, descripciones secundarias y texto `Oswald Light`. |
| **Apagado / bloqueado** | `#565E6D` | Nodos del árbol bloqueados, opciones deshabilitadas, recarga base oscurecida. |
| **Vida (barra)** | `#B8343A` | Relleno de vida del jugador, enemigos, rivales y jefes. |
| **Rastro de daño** | `#E8C9A0` | Barra secundaria retardada que cae tras `0.45 s` (`Config.Hud.DanioEspera`) al recibir daño. |
| **XP / progreso** | `#C9A55A` | Barra inferior fina (`2 px`) de experiencia en HUD y progreso de ruleta. |
| **Alerta / Buscado / Peligro** | `#E03A3E` | Estrellas de Buscado (1 a 5), anillo de patrulla en minimapa y ojo biónico de `Matón con implantes`. |
| **Aviso de ataque en piso** | `#D6333A` / `#FF6B5B` | Relleno `#D6333A` (`Transparency = 0.72`) + borde nítido `#FF6B5B` (`2–3 px`) que avisa `12 cuadros (0.4 s)` antes de `Impacto`. |
| **Éxito / listo / equipado** | `#3FA86B` | Confirmación de fabricación, equipamiento activo, indicador positivo. |
| **Oro / divisa** | `#D9A441` | Precios de alto valor, detalles de heráldica Corona y brillos metálicos cálidos. |

---

## 2. Regla del Piso Mínimo de Oscuridad en 3D (`Luma >= 18%`)

En iluminación nocturna `Future`, el negro `#000000` o `#080A0E` destruye el volumen y deja personajes invisibles sobre la calle:

- **Tono base más oscuro permitido para telas, cuero y armadura:** **`#1D2230`** (`60%` de ropa oscura / armaduras nocturnas).
- **Placas secundarias / cortes de campera o pantalón:** **`#2B3242`**.
- **Correas, arneses y aclarado de aristas:** **`#3F485C`** (+ borde aclarado `+10–14 %` valor sobre piezas oscuras).
- **Reservado exclusivamente para `#080A0E` / `#0E1016`:** líneas de tinta cómic pintadas (`2–4 px`), huecos profundos, AO de esquinas, núcleo del poder *Eclipse* y fondos 2D de UI/HUD.
- **Blanco más claro en personajes y ojos:** Hueso **`#EDE6D6`** (NUNCA `#FFFFFF` puro en ropa ni esclerótica ocular para que no brille bajo `Bloom`).

---

## 3. Bandos (4) y Rarezas (5)

### Bandos

| Bando | Hex oficial | Uso principal (acento 10 % y barras `3 px` en UI) |
|---|---|---|
| **Liga de Guardianes** | `#2F6FDB` | Emblema escudo hexagonal, barras de bando en Tab/Diálogo, iluminación/detalles Distrito Corona. |
| **Cofradía Carmesí** | `#C2213A` (y `#8E2A22` en calle/óxido) | Emblema rombo partido por hoja, tanques y chapa de Remache, acento de matones (`#8E2A22`). |
| **Vigilantes** | `#6B5BA8` | Emblema en V de alas plegadas, acento nocturno de Ciudad Vórtice. |
| **Neutral** | `#8A8F99` | Emblema aro incompleto con disco eclipse, personajes y jugadores sin bando. |

### Rarezas de Linaje y Equipamiento

| Rareza | Hex | Donde se aplica |
|---|---|---|
| **Común** | `#8A94A6` | Barra `3 px` de lista en Ruleta, etiqueta de tier y pulso al desbloquear. |
| **Poco Común** | `#3FA86B` | Barra `3 px` de lista y acento de categoría. |
| **Raro** | `#3FE0F0` | Barra `3 px` de lista y destello breve al frenar ruleta. |
| **Legendario** | `#F2A23A` | Barra `3 px` de lista y acento de alta rareza. |
| **Mítico** | `#C2213A` | Barra `3 px` de lista y revelación mítica. |

---

## 4. Matriz de Color de los 12 Linajes

Para que los efectos de combate nunca quemen a blanco sólido y conserven lectura de tinta cómic en móvil y PC, cada Linaje separa **3 tonos**:

| # | Linaje | Núcleo (brillo controlado) | Cuerpo / VFX principal | Tinta / Contraste |
|---|---|---|---|---|
| 1 | **Fuerza Bruta** | `#FFE09E` | `#F2A23A` + polvo `#B07A4A` | `#2A1F17` |
| 2 | **Reflejos** | `#E8FBFF` | `#3FE0F0` | `#132638` |
| 3 | **Piroquinesis** | `#FFB347` | `#F2652B` → `#8E2A22` | `#161218` (humo) |
| 4 | **Electro** | `#F0F8FF` | `#4DB8FF` | `#101B2E` |
| 5 | **Criogenia** | `#E8FBFF` | `#7CE8FF` → `#3BA3D0` | `#1D3A4F` |
| 6 | **Telequinesis** | `#E6D4FF` | `#A46CF0` | `#1E132B` |
| 7 | **Velocista Cinético** | `#E8FBFF` / `#D9CCF5` | `#9A82D8` + estela `#3FE0F0` | `#1B1730` |
| 8 | **Sombra Viva** | `#8E7AE6` | `#6B5BA8` | `#0E1016` / `#121216` |
| 9 | **Sangre Abisal** | `#EDE6D6` (espuma) | `#3FE0F0` / `#1F4A5A` | `#0E232B` |
| 10 | **Origen Estelar** | `#FFF5D6` | `#F2A23A` → `#E8E6E0` | `#3A2910` |
| 11 | **Herencia Olímpica** | `#FFF7DE` | `#D9A441` → `#A0703A` | `#2B1E10` |
| 12 | **Eclipse** | `#FFB347` (halo) | `#F2652B` | `#0E1016` (núcleo negro) |

---

## 5. Paletas de Mundo — 7 Biomas y 3 Interiores Beta

Regla **60 / 30 / 10**: `60%` base desaturada (piso/cemento/piedra), `30%` arquitectura y material medio, `10%` foco cromático o luz dominante.

| Lugar | 60 % Base | 30 % Secundario | 10 % Acento / Luz dominante |
|---|---|---|---|
| **Puerto Óxido (Beta)** | Asfalto húmedo `#2B303A`, madera muelle `#4A3E35` | Chapa oxidada `#6E4A35`, ladrillo `#5A3931`, acero `#4A5560` | Rojo Cofradía `#8E2A22` / `#C2213A`, sodio `#F29A3A`, hito grúa `#C98A2B` |
| **Ciudad Vórtice** | Piedra `#4B4F58`, basalto `#121216` | Ladrillo oscuro `#6A3B2E`, hierro | Ámbar faroles `#F2A23A`, Vigilantes `#6B5BA8` |
| **Distrito Corona** | Vidrio celeste `#9FC6D9`, acero `#C7CCD1` | Mármol hueso `#E8E6E0` | Dorado `#D9A441`, Liga `#2F6FDB` |
| **Penal Islaroca** | Piedra gris `#5B5E63` | Hormigón / reja oscura | Haces blancos `#F0F0E8`, uniforme `#E07A2F` |
| **Ciudad Hundida** | Agua abisal `#1F4A5A` | Piedra verdosa `#3C5A50`, coral `#D96A5A` | Luces bioluminiscentes `#3FE0F0` |
| **Cráter del Eclipse** | Basalto `#0E1016` | Tierra quemada `#2A2018` | Grietas naranjas `#F2652B` |
| **Umbra** | Obsidiana `#0E1016` | Roca oscura desaturada | Brasa / falla Eclipse `#F2652B` |
| **Taller de Tano (Interior)** | Piso `#5D5A55` + aceite `#2A1F17`, chapa `#4A5560` | Madera roble `#6B4426`, metal/pintura `#2D4A73`, silla `#2B3550`, PC `#C9B98F` | Luz sodio `#F2A23A`, trapo rojo `#8E2A22` |
| **Galpón de Remache (Interior)** | Arena hormigón gris `#2E3138`, óxido `#6E4A35` | Chapa roja `#8E2A22` | Tanques y luz foco Cofradía `#C2213A` |
| **Galpón del Albatros (Interior)** | Azul marino `#1C2433` | Madera `#5A4632`, oficina `#8E2A22` | Dorado envejecido `#C9962E` |

### Temperaturas de iluminación clave (`Lighting`)

- **Sombras y atmósfera nocturna del puerto:** azul pizarra frío (`Ambient #2C3754`, `OutdoorAmbient #46557A`, `Atmosphere.Color #2A3550`, `Decay #141A29`). **Nunca negro puro `#000000` en sombras.**
- **Foco jugable cálido (faroles, bancos de trabajo, entradas):** sodio naranja `#F29A3A`.
- **Contraluz lunar de salida en interiores:** azul luna pálido `#CFE3FF`.

---

## 6. Tonos de Piel (`Config.Cuerpo.TonosPiel`) y Paleta Rápida de Ropa

### 10 Tonos de piel oficiales (de claro a oscuro)

1. `#F6D7C3`
2. `#EAC0A0`
3. `#D9A382`
4. `#C68A62`
5. `#B0744E`
6. `#96603F`
7. `#7D4F33`
8. `#653E28`
9. `#4E2F1F`
10. `#3A2318`

### 12 Colores rápidos de personalización de ropa

`#1D2230` (Carbón Puerto) · `#2B3242` (Pizarra) · `#EDE6D6` (Hueso) · `#8A8F99` (Acero Neutro) · `#6E4A35` (Cuero Óxido) · `#8E2A22` (Carmesí Gastado) · `#C2213A` (Rojo Cofradía) · `#2F6FDB` (Azul Liga) · `#3FE0F0` (Cian Reflejos) · `#F2A23A` (Ámbar Solar) · `#6B5BA8` (Violeta Vigilante) · `#3FA86B` (Verde Muelle)

---

**Notas conectadas:** [[Guía de estilo]] · [[Sistema de diseño]] · [[Nivel de detalle]] · [[Cuerpo propio]] · [[Lugares]]
