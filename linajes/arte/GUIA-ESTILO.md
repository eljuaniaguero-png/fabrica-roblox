<!-- ESPEJO EN EL REPO de linajes/boveda/02 Estilo/Guía de estilo.md.
     La copia oficial vive en la bóveda de Obsidian; al cambiar una, actualizá siempre la otra. -->
# Guía de estilo — Biblia visual oficial de Linajes del Eclipse

> [!summary] Identidad gráfica única (en una frase)
> **Cómic Portuario Atmosférico**: cuerpos R15 blocky cómic biselados con líneas de tinta nítidas (`CuerpoComic`), arquitectura y props industriales con desgaste pintado en mundo (`pintura.py`), atmósfera densa con un foco de luz dominante (`@r0aringexe`), efectos de combate de 3 capas con contorno cómic sin blanco quemado, y una interfaz/HUD editorial oscura sin cajas en hueso `#EDE6D6` sobre `#080A0E`.

---

## 0. Qué estaba chocado (y qué manda desde ahora)

Al revisar toda la bóveda y todos los renders/capturas acumulados en `linajes/arte/`, convivían **4 estilos distintos que chocaban entre sí**. Esta tabla cierra cada conflicto de forma definitiva:

| Qué chocaba en el repo / bóveda | Qué se veía en renders y capturas reales | Qué MANDA desde ahora |
|---|---|---|
| **Personajes "plastilina / remache"** (`cuervo_v2`, `centinela`, `atalanta`, `estela`) | Torsos con "almohadones" suaves, ruido procedural que parece estática de TV, negro sobre negro sin lectura | **Estándar `CuerpoComic`**: blocky R15 nítido, chaflán seco de 1 corte, planos limpios sin grano, líneas de tinta pintadas (`2–4 px`) y contraste 60/30/10 con piso `#1D2230`. |
| **Pelos blandos vs angulares** (`pelo-comic-opciones.png` vs `cuerpo-comic-opcion-1.png`) | Mechones inflados tipo banana de goma con brillo plástico | **Mechones poligonales en cuña angular**, `Mark Sharp`, textura de 2–3 bandas limpias, `Roughness 0.62–0.75`. |
| **VFX "bola blanca" + cubos** (`arena-c8-noche-juego.png`, `efecto-bola-fuego.jpg`, `efecto-golpe-piso.jpg`, `EfectosPoder.client.luau`) | `Neon` blanco quemando la forma, disco amarillo liso en el piso, cubos `#3a3f4b` planos y cajas sólidas en `fantasma()` | **VFX en 3 capas**: Mesh/Flipbook con erosión y `Bloom.Threshold >= 1.6`, tinta cómic + micro impact-frame + cuñas poligonales de escombros + silueta real en dashes. |
| **Neon Cyberpunk vs Portuario** (`Plantilla de prompt.md` vs regla del 7 nov) | Prompts pidiendo *"wet night city lit by neon"* y *"heavy rivets"* cuando el 7 nov se prohibió el cyberpunk | **Cero carteles neon cyberpunk.** Neón puntual solo como acento diegético (`< 5%` de superficie, ej. cartel de un bar o visor de Remache). |
| **5 UIs distintas** (`interfaz/01..06` filigrana barroca, `P33c` cian/redondeado/`Saira Condensed`, `BarraMatones` `GothamBlack`, vs `Tema.luau`) | Marcos plateados medievales, tarjetas redondeadas cian, botones gruesos `GothamBlack` al lado del HUD fino `@r0aringexe` | **Editorial Oscuro Único (`Tema.luau` + `@r0aringexe`)**: `Oswald`, hueso `#EDE6D6`, fondo `#080A0E`, líneas `1 px`, rombos `45°` y `0–2 px` de esquina en todo el juego. |

---

## 1. Pilar 1 — Mundo, Iluminación, Atmósfera, Materiales y Assets 3D

### 1.1 Dirección de luz y atmósfera (Motor `Future` + `@r0aringexe`)

La calidad cinematográfica de `@r0aringexe` no viene de poner más luces ni más detalles: viene de **una atmósfera densa, sombras con color frío (nunca negro `#000000`) y 1 solo foco de color dominante por escena**.

| Parámetro en Roblox (`Lighting`) | Puerto Óxido (Noche) | Puerto Óxido (Atardecer) | Ciudad Vórtice (Noche eterna) | Distrito Corona (Día) | Ciudad Hundida (Submarino) | Cráter / Umbra |
|---|---|---|---|---|---|---|
| `Technology` | `Future` | `Future` | `Future` | `Future` | `Future` | `Future` |
| `ClockTime` | `1.0` (ciclo) | `18.0` (ciclo) | `0.5` (fijo) | `14.5` (ciclo) | `12.0` (filtrado) | `19.2` (fijo) |
| `Ambient` | `#2C3754` | `#3A3348` | `#1C2032` | `#7A8EA6` | `#163844` | `#2E1D22` |
| `OutdoorAmbient` | `#46557A` | `#695866` | `#2B324D` | `#A8BDCF` | `#235262` | `#4A2B26` |
| `Brightness` | `1.7` | `2.1` | `1.3` | `2.8` | `1.4` | `1.9` |
| `ExposureCompensation` | `0.0` | `0.05` | `-0.1` | `-0.05` | `-0.15` | `0.0` |
| `Atmosphere.Density` | `0.35` | `0.30` | `0.42` | `0.18` | `0.58` | `0.38` |
| `Atmosphere.Offset` | `0.25` | `0.28` | `0.18` | `0.40` | `0.10` | `0.22` |
| `Atmosphere.Color` | `#2A3550` | `#6E4B42` | `#181B2C` | `#9FC6D9` | `#183E4C` | `#381A18` |
| `Atmosphere.Decay` | `#141A29` | `#2C2233` | `#0C0E16` | `#E8E6E0` | `#0C232B` | `#12090B` |
| `Atmosphere.Haze` | `2.2` | `2.6` | `2.8` | `1.2` | `4.0` | `2.5` |
| `Atmosphere.Glare` | `0.15` | `0.35` | `0.08` | `0.25` | `0.10` | `0.30` |
| `Bloom.Threshold` | **`1.6`** | **`1.6`** | **`1.6`** | **`1.8`** | **`1.6`** | **`1.6`** |
| `Bloom.Intensity` | `0.22` | `0.20` | `0.25` | `0.12` | `0.26` | `0.28` |
| `Bloom.Size` | `22` | `24` | `24` | `18` | `26` | `22` |
| `ColorCorrection.Contrast` | `0.08` | `0.10` | `0.12` | `0.05` | `0.10` | `0.14` |
| `ColorCorrection.Saturation` | `-0.05` | `-0.02` | `-0.12` | `0.0` | `-0.15` | `-0.04` |

**Reglas inquebrantables de escena:**
1. **`Bloom.Threshold` nunca baja de `1.6`**: así los cartelitos, faroles y efectos conservan su color y silueta en lugar de reventar en manchas blancas.
2. **Contraste Frío / Cálido en el puerto e interiores**: el cielo, la niebla y las sombras tiran al azul pizarra (`#2A3550` / `#2C3754`); **los focos de interés jugable** (lámparas sobre el banco de trabajo, entrada del Taller, puerta del Galpón, faroles callejeros) tiran al sodio cálido (`#F29A3A`, `SpotLight 68–75°`) o al color del bando de la escena (`#C2213A` en el Galpón de Remache). Las puertas de salida al exterior reciben contra-luz fría lunar (`#CFE3FF`, `55°`).
3. **DepthOfField**: **`Enabled = false` siempre que el jugador se mueve o pelea** (en combate hay que leer lejos). **`Enabled = true`** (`FocusDistance = 12–18`, `InFocusRadius = 15`, `FarIntensity = 0.35`) únicamente en Menú principal, Creador, Taller y Diálogos con NPC.
4. **Siluetas de horizonte**: los hitos altos de cada ciudad (**Grúa gigante** de Puerto Óxido, **Torre del Reloj** de Vórtice, **Torre Corona**) van oscuros/medios sin luces brillantes arriba para que `Atmosphere` los recorte como siluetas gigantes contra la neblina.
5. **Presupuesto de sombras dinámicas**: máximo **2 o 3 luces con `Shadows = true`** por interior o cuadra abierta. El resto usa `Shadows = false` + calco de sombra de contacto en el suelo.

### 1.2 Materiales, texturas y desgaste pintado en mundo (`pintura.py`)

El acabado correcto ya se demostró en `calle-viva_detalle_calle.png`, `grua-2-tresCuartos.png` y `Taller de Tano.md` (v6–v9): **superficies duras con chaflán limpio + textura horneada direccional sin ruido tipo TV**.

- **Geometría de props y edificios:**
  - Chaflán (`Bevel`) **seco de 1 a 2 segmentos**: `0.03–0.05` studs en objetos chicos/interiores, `0.06–0.08` studs en arquitectura, contenedores y vehículos.
  - Sombreado suave (`Auto Smooth 35°` o `Weighted Normal`), con `Mark Sharp` en todos los cantos de chapas, vigas, marcos y techos.
  - **Cero detalle plano en malla**: grietas de piso, charcos, manchas de aceite, huellas, zócalos sucios y contornos de tablero **van pintados en la textura (`pintura.py` / ColorMap + RoughnessMap)**, nunca como plaquitas flotantes ni extrusiones de `0.02` studs.
- **Reglas de `ColorMap` (Albedo):**
  - Color base siempre ligeramente desaturado para que los poderes y personajes resalten encima.
  - Variación tonal suave entre paneles vecinos (±5–8 % de valor).
  - **Desgaste en aristas convexas**: tono aclarado `10–15 %` o color acero pelado `#6B7380` sobre bordes expuestos.
  - **Gravedad / chorreado en Z mundial**: chorreadas verticales de óxido `#6E4A35` y humedad hacia abajo en juntas, debajo de ventanas y al pie de paredes; AO oscuro `#0E1016` al `35–50%` en esquinas y zócalos.
  - **PROHIBIDO** el ruido procedural de alta frecuencia ("arena/estática de TV") tanto en paredes como en telas. Si se usa textura base, el grano debe ser ancho y pintado a pincelada suave, nunca pixelado.
- **Tabla de `RoughnessMap` (0 = espejo, 1 = tiza mate):**

| Familia de material | Roughness objetivo | Notas en Roblox (`SurfaceAppearance`) |
|---|---|---|
| Asfalto / vereda seca | `0.78 – 0.88` | Micro-variación ancha de baldosa/adoquín, sin brillo uniforme |
| Asfalto húmedo (noche/lluvia) | `0.24 – 0.38` | Pintar por zonas bajo faroles; refleja las luces `#F29A3A` |
| Charcos (`calco` o máscara) | `0.06 – 0.12` | Borde orgánico blando (nunca cuadrado), `AlphaMode` limpio |
| Ladrillo y hormigón viejo | `0.82 – 0.92` | `NormalMap` solo para junta de ladrillo y relieve ancho |
| Chapa acanalada pintada | `0.55 – 0.70` | Zonas oxidadas suben a `0.86–0.94`; bordes pelados bajan a `0.32` |
| Acero industrial (grúas, rejas, caños) | `0.35 – 0.52` | `Metalness` alto solo en zonas metálicas reales (`0.75–0.95`) |
| Madera (muelles, cajones, banco) | `0.74 – 0.86` | Veta direccional larga; mancha de aceite baja local a `0.20` |
| Vidrio exterior / ventanas (`Glass_`) | `0.08 – 0.15` | Preferir vidrio tintado oscuro o cálido interior (`#F29A3A` al 40–60 %) antes que cajas huecas |
| Emisivos (`Neon_`) | — | **`< 5 %` del campo visual**. Solo ventanas encendidas, faros, tableros chicos y carteles clave (ej. `"EL ANCLA"`). |

- **Normales, UVs y Resoluciones:**
  - Normal map siempre **OpenGL (`+Y` arriba)** en espacio tangente. Blender hornea con *View Transform = Standard* (nunca *AgX* para mapas de datos/color base sin corregir).
  - Todo UV dentro de `[0, 1]` sin solapamiento en piezas horneadas.
  - Tamaños de textura: `2048 px` piso de arenas/calles repetibles; `1024 px` edificios, hitos, vehículos y ropa héroes; `512 px` props medianos, enemigos y muebles; `256 px` micro-props y partículas.

### 1.3 Escala, grilla, colisiones y sombras de contacto

- **Ancla humana:** jugador R15 = `5.5 a 6.0 studs` de alto.
- **Grilla arquitectónica:** módulos en múltiplos de **`4 studs`**.
- **Medidas obligatorias:** puerta peatonal `5 x 8` studs; portón de galpón `12–14 x 10–11` studs; alto por piso exterior `13` studs; techo libre en interiores jugables `16–22` studs (evita choque de cámara en combate); vereda `8–12` studs de ancho × `0.5` studs de alto; calle estándar `24` studs (Corona `36–48` studs).
- **Colisiones simples:** toda malla compleja (escaleras, rejas, autos, elevadores, estatuas) lleva `CanCollide = false` y se rodea con piezas invisibles `_Colision` (cubos/rampas de `12–36` tris).
- **Sombra de contacto:** todo prop estático pequeño/mediano apoyado al piso (tambores, cajas, faroles, tachos, banco) lleva debajo una placa invisible `SurfaceGui` con `Sombra` `#000000` al `35–45%` para que nunca parezca flotar cuando el celular apaga sombras reales.

### 1.4 Paleta 60 / 30 / 10 e hitos por bioma y sala

- **Puerto Óxido (Beta):** `60%` asfalto húmedo `#2B303A` y madera muelle `#4A3E35`; `30%` chapa oxidada `#6E4A35`, ladrillo `#5A3931`, acero gris `#4A5560`; `10%` rojo Cofradía `#8E2A22`/`#C2213A`, contenedores azul petróleo/verde musgo gastado y sodio `#F29A3A`. *Hito:* Grúa gigante amarilla-óxido `#C98A2B`.
- **Ciudad Vórtice:** `60%` piedra `#4B4F58` / asfalto `#1C2028`; `30%` ladrillo oscuro `#6A3B2E` y hierro negro `#1A1D24`; `10%` faroles ámbar `#F2A23A` + acento Vigilantes `#6B5BA8`. *Hito:* Torre del Reloj.
- **Distrito Corona:** `60%` vidrio celeste `#9FC6D9` y acero `#C7CCD1`; `30%` mármol hueso `#E8E6E0`; `10%` dorado Corona `#D9A441` + azul Liga `#2F6FDB`. *Hito:* Torre Corona Corp.
- **Penal Islaroca:** piedra `#5B5E63`, reja `#16181E`, haz blanco `#F0F0E8`, uniforme naranja `#E07A2F`.
- **Ciudad Hundida:** agua `#1F4A5A`, piedra verdosa `#3C5A50`, coral `#D96A5A`, luces cian `#3FE0F0`.
- **Cráter del Eclipse / Umbra:** basalto `#0E1016`, tierra quemada `#2A2018`, grietas `#F2652B` / `#C2213A`.
- **Interiores Beta:**
  - *Taller de Tano:* chapa `#4A5560`, piso `#5D5A55` con manchas aceite `#2A1F17`, roble `#6B4426`, auto verde saturado, compu beige `#C9B98F`, silla `#2B3550`, luz sodio `#F29A3A` sobre banco/auto/tablero.
  - *Galpón de Remache:* arena gris `#2E3138`, chapa roja `#8E2A22`, óxido `#6E4A35`, tanques `#C2213A`, lámpara oscilante focal sobre el ring central.
  - *Galpón del Albatros:* azul marino `#1C2433`, madera `#5A4632`, oficina `#8E2A22`, dorado viejo `#C9962E`, lámpara de escritorio verde focal.

---

## 2. Pilar 2 — Modelos 3D de Personajes (Cuerpo, Ropa, Pelos, Caras y Elenco)

### 2.1 Estándar `CuerpoComic` y la Regla Anti-Plastilina

La referencia visual aprobada para todo humanoide del juego es **`cuerpo-comic-hoja.png` + `muestra-personajes-frente.png`**, corrigiendo lo que falló en `atalanta_vistas.png`, `centinela_vistas.png` y `cuervo_v2_vs_v1_primeros_planos.png`:

1. **Base anatómica única (R15 Blocky Cómic):**
   - Rig estándar R15 con las 15 partes (`Head`, `UpperTorso`, `LowerTorso`, manos/brazos/piernas/pies) vistiendo el `CuerpoComic` base soldado por hueso (`CuerpoComic.luau`).
   - Proporción heroica limpia (~`5.8 studs`): cabeza cúbica con arista levemente biselada (`1.2 x 1.2 x 1.2`), torso sólido (`2.0 x 2.0 x 1.0`) cuya cintura se marca **con el corte de la chaqueta/cinturón**, no aplastando el rig en Rthro ni inflando músculos.
   - Jefe pesado (`Remache`) o bajo/ancho (`Albatros`) escalan el mismo esqueleto R15 respetando animaciones (`Albatros 0.9x alto / 1.2x ancho`, `Remache 1.3x–1.35x`), sin agregar huesos extra incompatibles con R15.
2. **PROHIBIDO ("Efecto Plastilina / Estática"):**
   - **Cero** `Subdivision Surface` suave sobre hombreras, pectorales o cinturones (adiós "abdomens de colchón").
   - **Cero** remaches o pernos microscópicos repetidos cada `0.05` studs.
   - **Cero** ruido de tela granuloso en `NormalMap`/`ColorMap` (parece estática de TV en primer plano).
3. **OBLIGATORIO ("Cómic Nítido"):**
   - **Chaflán de 1 corte (`0.025–0.04` studs)** + `Auto Smooth 35°` + `Mark Sharp` en bordes de hombreras, solapas, puños, cinturones, placas y suelas.
   - **Tinta de cómic pintada en `ColorMap` (`512` o `1024 px`)**: líneas finas en `#0E1016` (`2–4 px` de espesor en textura a `1024 px`) delimitando solapas de campera, bolsillos, costuras de pantalón, pliegues de bota/rodilla y división de placas, más un **aclarado de borde (`+10–14%` valor)** en las aristas de piezas oscuras.
   - **Piso mínimo de oscuridad (`Luma >= 18%`)**: ningún material de tela, cuero o metal "negro" puede usar hex menor a **`#1D2230`** en tono base (y `#2B3242` en placas secundarias, `#3F485C` en correas).
   - **Regla 60 / 30 / 10 de silueta a 40 studs**: `60%` cuerpo principal del atuendo, `30%` pieza contrastante que corta la silueta, `10%` foco cromático brillante o claro.
   - **Capas y telas estilizadas**: las capas se modelan como **láminas sólidas de grosor limpio (`0.08–0.12` studs) con pliegues angulares marcados**, nunca como tres tablas rígidas planas ni moños inflados.

### 2.2 Pelos (`Pelos`) — Regla estricta contra los "pelos goma"

- **Qué evitar** (visto en `pelo-comic-opciones.png`): mechones redondeados tipo gota/banana con `Shade Smooth` brillante sin quiebres.
- **Cómo se hace todo pelo en Linajes** (referencia `cuerpo-comic-opcion-1.png` y `cuerpo_peinados_v2`):
  - Construido con **cuñas poligonales y láminas prismáticas angulares** con crestas y puntas afiladas (`Mark Sharp` a lo largo de la espina central de cada mechón).
  - Cada peinado es **`1` sola `MeshPart`** soldada a `Head`, cubriendo frente, laterales y nuca.
  - **Textura de pelo (`512 px`):** degradado limpio en 2–3 valores (raíz `-18%` más oscura / cuerpo tono base / puntas o mecha delantera `+14%` más clara) + líneas finas `#0E1016` entre grandes grupos de mechones. **`Roughness = 0.65–0.75`**.
  - Presupuesto: **`400 a 900 triángulos`** por peinado (`1.400` máximo en rulos complejos).

### 2.3 Caras y Expresiones (`Cara`)

- **Formato:** `Decal` frontal (`256 x 256` RGBA PNG transparente) sobre `Cuerpo_Head` en color piel plano biselado, intercambiable por código (`CuerpoComic.luau`).
- **Proporción facial oficial** (ref `cuerpo-comic-opcion-1.png`): ojos geométricos angulares estilo cómic/anime con línea superior gruesa `#0E1016`, borde inferior fino `#0E1016`, **esclerótica en Hueso `#EDE6D6`** (NUNCA `#FFFFFF` puro), iris sólido con 1 punto blanco superior + cejas expresivas inclinadas + boca mínima en 1 trazo `#0E1016`.
- **Set obligatorio por cara:** `8` expresiones (`Neutral`, `Enojado`, `Concentrado`, `Dolor`, `Sorprendido`, `Contento`, `Cansado`, `Derrotado`) + `Parpadeo` (cerrado `0.12s` cada `3–6s`) + `3` visemas de boca al hablar.

### 2.4 Atuendo jugador, Bandos y Jerarquía del Elenco

| Categoría | Presupuesto tris (total / tope malla) | ColorMap & Roughness | Silueta y regla de diseño |
|---|---|---|---|
| **Jugador — Base ("Atuendo Básico")** | `4.000 – 8.000` (sobre `CuerpoComic`) | `512 px` · `Roughness 0.78–0.90` | Remera corta bien cortada con cuello/puño contrastante, pantalón urbano con costuras de tinta, zapatillas bicolor. Simple pero con carácter. |
| **Jugador — Ropa comprable (`Urbano` y conjuntos)** | `8.000 – 18.000` (ropas modulares R15) | `512–1024 px` · albedo gris claro tintable por canal + tinta cómic | Piezas intercambiables por hueso (`Campera`, `Remera`, `Cinturón`, `Pantalón`, `Zapatillas`, `Casco`, `Capa`, `Peto`) con 2–3 canales pintables. **El emblema dorsal es del Bando, NO de la prenda.** |
| **Civiles (Calle viva)** | `1.000 – 3.000` (ropa mod.) | `512 px` · grises `_C1`/`_C2` tintados en Studio | Tonos urbanos apagados. Solo el teléfono brilla suave (`#3FE0F0`) cuando filman o llaman. |
| **Enemigos comunes (`Matón`, `Matón implantes`)** | `7.500 – 10.000` (máx `1.200` por malla) | `512 px` · sin granulado | Campera oscura `#262B36`, detalle Cofradía `#8E2A22`, cadena de hierro. Variante con implantes: brazo metálico limpio + **un solo punto brillante rojo `#E03A3E`** (ojo biónico). |
| **NPCs clave (`Tano`, `Rivas`, `Vega`, `Kessler`)** | `12.000 – 20.000` (máx `3.000` por malla) | `512–1024 px` | Cada uno porta 1 prop característico de silueta clara (llave inglesa y trapo rojo en Tano, etc.). |
| **Mentores y Jefes (`Remache`, `Albatros`, `Cuervo`, `Centinela`, `Atalanta`, `Mascarada`, `Estela`)** | `22.000 – 38.000` (límite absoluto Roblox: **`20.000` por `MeshPart`**) | `1024 px` · placas biseladas sin estática + 1–2 acentos `Neon_` chicos | **Refactors prioritarios:** quitar torso acolchado y granulado de estática en `Cuervo v2` y `Centinela`; afinar capa de `Atalanta` y `Centinela` a láminas con pliegues cómic; aclarar acero de `Remache` (`#3A4252`) para lectura clara en su galpón. |

---

## 3. Pilar 3 — Efectos Especiales (VFX), Combate y Game Feel

### 3.1 La Regla de las 3 Capas (Reemplazo de bolas blancas y cubos negros)

Todo golpe, habilidad y dash sigue esta anatomía. Se prohíbe emitir un simple `Part Neon` esférico/blanco sólido ni cubos lisos de escombros (`EfectosPoder.client.luau` actual).

| Capa | Función | Implementación técnica en Roblox |
|---|---|---|
| **1. Núcleo y Silueta (Forma principal)** | Comunica al instante *qué poder es y hacia dónde va* | **`MeshPart` estilizada** (`DoubleSided = true`, media luna de tajo, domo de choque, espiral de viento, cono de llama, prisma de hielo) con textura **alfa/erosión en scroll** + `ParticleEmitter` **`Grid4x4`** con `LightEmission = 0.45 – 0.70` (NUNCA `1.0` apilado al 100 % porque quema a blanco puro). |
| **2. Tinta Cómic, Impact Frame y Grietas** | Da identidad visual de **Linajes** y peso de golpe | **a)** Anillos y flipbooks de explosión/humo dibujados con **borde oscuro `#0E1016`**. **b)** Golpe 4 de combo, parry o definitiva: micro **Impact Frame (`25–40 ms`)** subiendo `ColorCorrection.Contrast = 0.65` + `Highlight` blanco hueso (`0.06 s`) en el golpeado. **c)** **Grietas del suelo** con `Decal` radial pintado (fade out `2.5–3 s`). **d)** **Escombros:** **3 modelos de cuñas/rocas irregulares poligonales facetadas** (nunca cubos) que giran y desaparecen encogiéndose. |
| **3. Apoyo, Chispas, Humo y Rastros** | Vende velocidad, polvo e integración al escenario | **a)** Chispas elongadas rápidas (`Squash = 1.5`, orientadas `VelocityPerpendicular`). **b)** Humo cómic denso con **`LightInfluence = 0.25`** y **`LightEmission = 0`**. **c)** **Estelas y velocidad:** `Beam` ancho pegado al piso siguiendo las curvas + **post-imágenes de dash** con clones semitransparentes del cuerpo real + `Highlight` sutil (no rectángulos sólidos). |

### 3.2 Avisos de ataque (`Aviso`) y lectura de combate

- Todo golpe fuerte de enemigo/jefe dispara marcador **`Aviso` `12 cuadros (0.4 s)` antes de `Impacto`**.
- **Forma visual en piso** (`+0.05` studs arriba del suelo): relleno rojo alerta `#D6333A` (`Transparency = 0.72`) con **borde nítido brillante `#FF6B5B` de `2–3 px`** y onda interior que se expande desde el centro hasta tocar el borde exactamente en `Impacto`.

### 3.3 Matriz visual oficial de los 12 Linajes

| Linaje | Color núcleo (brillo) | Color cuerpo / VFX | Color tinta / contraste | Lenguaje de formas y partículas |
|---|---|---|---|---|
| **Fuerza Bruta** | `#FFE09E` | `#F2A23A` + polvo `#B07A4A` | `#2A1F17` | Anillos gruesos fracturados, ondas de piso concéntricas, grietas radiales, cuñas de piedra volando. |
| **Reflejos** | `#E8FBFF` | `#3FE0F0` | `#132638` | Líneas cortas rectas de velocidad, arcos finos de corte, pos-imágenes nítidas de cuerpo real, destellos en cruz de parry. |
| **Piroquinesis** | `#FFB347` | `#F2652B` → `#8E2A22` | `#161218` | Lenguas helicoidales esculpidas en Mesh/Flipbook con punta afilada + humo negro con contorno + brasas finas. |
| **Electro** *(estandarizado)* | `#F0F8FF` | `#4DB8FF` | `#101B2E` | Zigzags quebrados (`Beam` con jitter cada `0.04 s`), arcos breves rodeando articulaciones, chispas azules rápidas. |
| **Criogenia** *(estandarizado)* | `#E8FBFF` | `#7CE8FF` → `#3BA3D0` | `#1D3A4F` | Prismas hexagonales puntiagudos brotando del piso, neblina fría rastrera, cristales en triángulo. |
| **Telequinesis** *(estandarizado)* | `#E6D4FF` | `#A46CF0` | `#1E132B` | Aros orbitales concéntricos con muescas, contorno `Highlight` violeta en objetos levantados. |
| **Velocista Cinético** | `#E8FBFF` / `#D9CCF5` | `#9A82D8` + estela `#3FE0F0` | `#1B1730` | `Beam` serpenteante continuo sobre el suelo detrás de los pies, arcos eléctricos finos, copias fugaces atrás. |
| **Sombra Viva** | `#8E7AE6` | `#6B5BA8` | `#0E1016` / `#121216` | Zarcillos negros planos con borde violeta fino saliendo del suelo, humo negro denso mate. |
| **Sangre Abisal** | `#EDE6D6` (espuma) | `#3FE0F0` / `#1F4A5A` | `#0E232B` | Chorros laminares gruesos con cresta blanca estilizada, anillos de agua en piso, gotas pesadas. |
| **Origen Estelar** | `#FFF5D6` | `#F2A23A` → `#E8E6E0` | `#3A2910` | Haces de rayo limpio con anillo expansivo al disparar, motas estelares de 4 puntas alargadas. |
| **Herencia Olímpica** | `#FFF7DE` | `#D9A441` → `#A0703A` | `#2B1E10` | Armas de energía translúcida dorada con borde firme, relámpagos dorados/blancos, hojas doradas. |
| **Eclipse** | `#FFB347` (halo) | `#F2652B` | `#0E1016` | Núcleo negro absoluto rodeado por un anillo fino incandescente naranja-dorado, grietas oscuras en el aire. |

### 3.4 Game Feel y Regla Celular (`Alto` vs `Bajo`)

- **Hit-Stop (solo cliente, congelando `AnimationTrack.Speed = 0` de atacante y víctima):** liviano `0.04 s`, fuerte/habilidad `0.08 s`, remate/parry `0.12 s`.
- **Sacudida de cámara (`Camara.client.luau`):** normal `0.12` studs (`0.12 s`); fuerte `0.30–0.42` studs (`0.22 s`); definitiva/jefe `0.60` studs (`0.32 s`).
- **Modo `Bajo` (Celular):** `Rate * 0.5`, **0 luces `PointLight` dinámicas en proyectiles o partículas**, `Impact Frame` desactivado, vida del humo `-35%`. Se mantienen al 100 % el `Aviso` rojo enemigo y el anillo principal de impacto.

---

## 4. Pilar 4 — Interfaz de Usuario (UI — Sistema Editorial Oscuro `@r0aringexe`)

### 4.1 Filosofía y reglas de forma

- **Prohibido en toda UI del juego:** cajas opacas redondeadas (`UICorner >= 8 px`), bordes cyan ciberpunk gruesos, marcos plateados barrocos/medievales (`interfaz/03, 06`) y fuentes gruesas tipo cartoon (`GothamBlack` en `BarraMatones.client.luau`).
- **Superficies:**
  - **En HUD y Menú Principal:** **sin cajas de fondo** (`BackgroundTransparency = 1`), apoyado en `Vineta` sutil y sombra suave detrás del texto.
  - **En ventanas modales:** fondo plano `#0D1017` al `88%` de opacidad (`BackgroundTransparency = 0.12`), esquinas rectas **`0 px` o bisel mínimo `2 px`**, **borde `UIStroke` de `1 px` en Hueso `#EDE6D6` al `18%` de opacidad** (`Transparency = 0.82`). Al pasar/seleccionar sube a `1.5 px` al `75%` o toma el color del bando/Linaje activo.
  - **Motivo geométrico propio:** el **rombo girado `45°`** (`Tema.rombo`) y la **línea fina con rombito central** (`Tema.ornamento`).

### 4.2 Tipografía oficial única (`Oswald`)

- **Única fuente:** `Oswald` (`rbxasset://fonts/families/Oswald.json`) en `Tema.luau`:
  - **`Oswald SemiBold`:** títulos principales, nombres de jefes, acciones primarias, números clave. Siempre en **MAYÚSCULAS** para encabezados con **tracking espaciado (`Tema.espaciar(..., 2)` en títulos grandes, `1` en subtítulos/etiquetas)**.
  - **`Oswald Regular`:** cuerpo de diálogos, descripciones cortas de habilidades/nodos, respuestas, valores de taller.
  - **`Oswald Light`:** metadatos sutiles, textos secundarios en gris `#9FA7B5`.
- **Escala base (`1080p`, `UIScale` clamped `0.62–1.25`):** Titular `32–42 px` · Título panel `22–26 px` · Botón/pestaña `16–18 px` · Cuerpo `15–16 px` · Micro-etiqueta `12–13 px`.
- **Legibilidad:** `TextStrokeColor3 = #080A0E`, `TextStrokeTransparency = 0.55`.

### 4.3 Reglas móviles (`844 x 390`) y tiempos de animación

- Todo elemento tocable tiene **área mínima de toque de `48 x 48 px`** reales.
- En celular (`844 x 390`), **zona izquierda inferior reservada para joystick virtual** y **zona derecha inferior reservada para arco de pulgar derecho**.
- **Animación UI:** `TweenService` `Quart.Out` de **`0.16 s`**; barras con marca de daño `#E8C9A0` tras **`0.45 s`**; máquina de escribir `40 car/s`.

### 4.4 Plano unificado de las 10 Pantallas

1. **Menú principal:** cámara lenta orbitando al personaje en el muelle frente al Eclipse con `DepthOfField`. Arriba izquierda: subtítulo tenue + `L I N A J E S   D E L   E C L I P S E` + `Ornamento`. Columna sin cajas (`◇ CONTINUAR`, `◇ ESPACIOS  ◀ 1 / 3 ▶`, `◇ AJUSTES`, `◇ CRÉDITOS`).
2. **Creador de personaje:** personaje en vivo al 55 % izquierdo; panel `#0D1017` al 88 % derecho con pestañas subrayadas (`CUERPO · CARA · PELO · ROPA`), grilla `2 px`, 10 tonos de piel (`Config.Cuerpo.TonosPiel`) + paletas rápidas, nombre y botón sólido Hueso `#EDE6D6` / texto `#080A0E`.
3. **Ruleta de Linaje:** rueda concéntrica minimalista Hueso con puntero rombo arriba; lista derecha de Linajes por rareza con `%` y barra `3 px`; contador `S E G U R O   N / 4 0`; botón `GIRAR (1 FICHA)`.
4. **HUD de pelea:** ver Sección 5.
5. **Árbol (`ESTADÍSTICAS` | `LINAJE`):** 6 barras finas `4 px` con `+` + nodos rombo `45°` conectados por líneas rectas `1.5 px` en 3 ramas (`Poder`, `Cuerpo`, `Técnica`) y fila `Movimiento`. Apagado `#565E6D`, disponible `#EDE6D6`, encendido `[Color Linaje]`, secreto `???`.
6. **Diálogo con NPC:** oculta HUD, activa `DepthOfField`, cámara 3/4. Franja inferior con nombre del NPC con acento de su bando + `Ornamento`, texto `2–3` líneas y hasta `4` respuestas editoriales con `◇` (última `ADIÓS`).
7. **Taller:** lista vertical izquierda, objeto 3D libre al centro, columna derecha `Tengo / Necesito` + `FABRICAR`.
8. **Lista de jugadores (Tab):** tarjeta arriba derecha agrupada por los 4 bandos con barra vertical `3 px` de color de bando + nombre, rango y fama.
9. **Ajustes:** panel centrado con 3 sliders de barra fina `2 px` + rombo `14 px`, selector `CALIDAD: ALTO / BAJO` y toggle `Sacudida de cámara`.
10. **Aviso de Buscado y Noticias El Faro:** estrellas `#E03A3E` arriba derecha + anillo de búsqueda rojo en minimapa; cintillo superior angosto negro translúcido para *El Faro*.

---

## 5. Pilar 5 — HUD de Pelea, Emblemas, Íconos 2D y Cinemáticas

### 5.1 Disposición exacta del HUD (`Config.Hud` + `hud-maqueta.svg`)

- **`Vineta`:** viñeta radial `#080A0E` pegada a los bordes.
- **Abajo izquierda (`Margen = 72 px` en 1080p):** Rombo de Nivel (`64 px` a `45°`) + **Vida** (`380 x 5 px`, `#B8343A` + rastro `#E8C9A0` tras `0.45 s`), **Energía** (`300 x 3 px`, `[Color Linaje]`), **XP** (`300 x 2 px`, `#C9A55A`) + línea Linaje/Bando en `12 px`.
- **Abajo centro (contextual, `4 s` sin combate):** barra de Rival (`340 x 4 px`) o **Jefe** (`540 x 5 px`, `#B8343A` + rastro `#E8C9A0`, nombre espaciado `SemiBold`, muescas de fase).
- **Abajo derecha:** 4 rombos `45°` (`TamRombo = 92 px`, separación `112 px`) para `Z`, `X`, `C`, `V` + rombo `G` (`68 px`). En celular, arco ergonómico para pulgar derecho (`>= 48 px` físicos).
- **Barras flotantes sobre enemigos (`BarraMatones.client.luau` — migración pendiente):** reemplazar `GothamBlack` y caja gris por barra `86 x 4 px` `#080A0E` 65% / `#B8343A` + rastro `#E8C9A0` y nombre `Oswald Light 12 px` Hueso `#EDE6D6`, visible a `< 35 studs` o tras golpe.

### 5.2 Íconos 2D, Logo y Emblemas de Bandos

- **Íconos (`arte/hud/listas/`):** **monocromo Hueso `#EDE6D6` con cortes negativos limpios**, sin contorno negro grueso ni glow, alfa limpio (`hud_procesar.py`), para que `Tema.luau` aplique `ImageColor3` al color de cada Linaje/recarga. Fuente `512 px`, subida `256 / 128 px`, margen `6%`, legible a `42 px`.
- **Emblemas de los 4 Bandos (cada uno forma distinta):** **Liga `#2F6FDB`** (escudo hexagonal con rayo/sol calado) · **Cofradía `#C2213A`** (rombo alargado partido por hoja/daga) · **Vigilantes `#6B5BA8`** (V vertical de alas angulares) · **Neutral `#8A8F99`** (aro incompleto con disco eclipse).
- **Logo (`LINAJES DEL ECLIPSE`):** `Oswald SemiBold` monumental en Hueso/acero `#EDE6D6` con grieta fina `#F2652B`, eclipsando detrás el disco `#080A0E` con halo controlado `#F2652B`/`#FFB347`.

### 5.3 Cinemáticas

- Franjas negras `#080A0E` arriba y abajo del **`10%`** (`Tween 0.35 s`), HUD oculto.
- Subtítulos centrados abajo: hablante en `Oswald SemiBold 13 px` espaciado con color de bando + diálogo `Oswald Regular 20 px` Hueso `#EDE6D6` (máx. 2 líneas).
- Botón `S A L T E A R` a los `2 s`.

---

## 6. Sufijos estándar para Gemini (reemplazo del bloque viejo)

- **Personajes y Assets 3D:**
  `Style: stylized dark graphic-novel comic 3D game art, crisp blocky Roblox R15 proportions, clean flat beveled planes with sharp edges and subtle painted ink seam lines (NO rounded pillows, NO noisy rivets, NO clay surface), muted weathered industrial harbor palette illuminated by directional sodium-orange glow against cool slate fog, high value separation, zero cyberpunk neon signs. Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.`
- **Hojas de VFX / Poderes:**
  `Style: stylized 3D game VFX concept sheet, bold directional silhouettes with dark comic ink outlines and crisp cel-shaded energy cores (NO blurry white glow blobs, NO generic spark stars), dark moody slate background #080A0E, legible at phone scale, no text, no watermarks.`
- **Íconos de HUD y UI:**
  `Style: ultra-minimal dark editorial game UI, pure solid monochrome bone-white #EDE6D6 sharp geometric glyph centered with 6% margin on clean #00FF00 chroma green background, sharp angular negative-space cuts, NO outer black cartoon stroke, NO glow haze, legible at 42 pixels, no text, no logos.`

---

## 7. Reglas técnicas y legales (no negociables)

- **Nada de DC ni Marvel** en ningún modelo, textura, texto ni ícono.
- **No copiar assets ni texturas** de capturas de otros juegos.
- **Tope Roblox:** `<= 20.000` tris por `MeshPart`, `1` material (`SurfaceAppearance`) por malla, UV `[0,1]`, Normal OpenGL `+Y`, `StreamingEnabled 512`, texturas `256/512/1024 px` (`2048 px` piso base).
- **Sin Robux pay-to-win ni loot boxes.**
- **Todo número ajustable vive en `Config.luau` / `Iluminacion.luau`.**
