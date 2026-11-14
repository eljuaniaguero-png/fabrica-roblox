---
tags: [estilo, guia, biblia]
---
# Guía de estilo — Biblia visual oficial de Linajes del Eclipse

> [!summary] Identidad gráfica única (en una frase)
> **Cómic Portuario Atmosférico**: cuerpos R15 blocky cómic biselados con líneas de tinta nítidas (`CuerpoComic`), arquitectura y props industriales con desgaste pintado en mundo (`pintura.py`), atmósfera densa con un foco de luz dominante (`@r0aringexe`), efectos de combate de 3 capas con contorno cómic sin blanco quemado, y una interfaz/HUD editorial oscura sin cajas en hueso `#EDE6D6` sobre `#080A0E`.

> [!note] Sincronización oficial
> Esta es la copia oficial de la bóveda. Su espejo exacto en el código es `linajes/arte/GUIA-ESTILO.md` (siempre actualizar ambos juntos). Manda sobre cualquier contradicción en notas viejas o prompts anteriores de `03 Prompts/`.

![[estilo-01-paleta-luz.png]]

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
4. **Siluetas de horizonte**: los hitos altos de cada ciudad (**Grúa gigante** de Puerto Óxido, **Torre del Reloj** de Vórtice, **Torre Corona**) van oscuros/medios sin luces brillantes arriba para que `Atmosphere` los recorte como siluetas gigantes contra la neblina (referencia: captura `@r0aringexe` #4 y `estilo-01-paleta-luz.png`).
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
- **Ciudad Hundida:** agua `#1F4A5A`, piedra verdosa `#3C5A50`, coral `#D96A5A`, luces cian `#3FE0F0` (referencia directa: captura `@r0aringexe` #1).
- **Cráter del Eclipse / Umbra:** basalto `#0E1016`, tierra quemada `#2A2018`, grietas `#F2652B` / `#C2213A`.
- **Interiores Beta:**
  - *Taller de Tano:* chapa `#4A5560`, piso `#5D5A55` con manchas aceite `#2A1F17`, roble `#6B4426`, auto verde saturado, compu beige `#C9B98F`, silla `#2B3550`, luz sodio `#F2A23A` sobre banco/auto/tablero (`estilo-06-taller.png`).
  - *Galpón de Remache:* arena gris `#2E3138`, chapa roja `#8E2A22`, óxido `#6E4A35`, tanques `#C2213A`, lámpara oscilante focal sobre el ring central.
  - *Galpón del Albatros:* azul marino `#1C2433`, madera `#5A4632`, oficina `#8E2A22`, dorado viejo `#C9962E`, lámpara de escritorio verde focal.

---

## 2. Pilar 2 — Modelos 3D de Personajes (Cuerpo, Ropa, Pelos, Caras y Elenco)

### 2.1 Estándar `CuerpoComic` y la Regla Anti-Plastilina

La referencia visual aprobada para todo humanoide del juego es **`cuerpo-comic-hoja.png` + `muestra-personajes-frente.png` + `estilo-02-protagonista.png` + `estilo-03-personajes.png`**, corrigiendo lo que falló en `atalanta_vistas.png`, `centinela_vistas.png` y `cuervo_v2_vs_v1_primeros_planos.png`:

1. **Base anatómica única (R15 Blocky Cómic):**
   - Rig estándar R15 con las 15 partes (`Head`, `UpperTorso`, `LowerTorso`, manos/brazos/piernas/pies) vistiendo el `CuerpoComic` base soldado por hueso (`CuerpoComic.luau`).
   - Proporción heroica limpia (~`5.8 studs`): cabeza cúbica con arista levemente biselada (`1.2 x 1.2 x 1.2`), torso sólido (`2.0 x 2.0 x 1.0`) cuya cintura se marca **con el corte de la chaqueta/cinturón**, no aplastando el rig en Rthro ni inflando músculos.
   - Jefe pesado (`Remache`) o bajo/ancho (`Albatros`) escalan el mismo esqueleto R15 respetando animaciones (`Albatros 0.9x alto / 1.2x ancho`, `Remache 1.3x–1.35x`), sin agregar huesos extra incompatibles con R15.
2. **PROHIBIDO ("Efecto Plastilina / Estática"):**
   - **Cero** `Subdivision Surface` suave sobre hombreras, pectorales o cinturones (adiós "abdomens de colchón" de `centinela_vistas.png` y `cuervo_v2`).
   - **Cero** remaches o pernos microscópicos repetidos cada `0.05` studs (solo confunden la silueta a 20 studs y vuelven el modelo ruidoso).
   - **Cero** ruido de tela granuloso en `NormalMap`/`ColorMap` (visto en `cuervo_v2_vs_v1_primeros_planos.png`).
3. **OBLIGATORIO ("Cómic Nítido"):**
   - **Chaflán de 1 corte (`0.025–0.04` studs)** + `Auto Smooth 35°` + `Mark Sharp` en bordes de hombreras, solapas, puños, cinturones, placas y suelas.
   - **Tinta de cómic pintada en `ColorMap` (`512` o `1024 px`)**: líneas finas en `#0E1016` (`2–4 px` de espesor en textura a `1024 px`) delimitando solapas de campera, bolsillos, costuras de pantalón, pliegues de bota/rodilla y división de placas (igual que `cuerpo-comic-hoja.png`), más un **aclarado de borde (`+10–14%` valor)** en las aristas de piezas oscuras.
   - **Piso mínimo de oscuridad (`Luma >= 18%`)**: ningún material de tela, cuero o metal "negro" puede usar hex menor a **`#1D2230`** en tono base (y `#2B3242` en placas secundarias, `#3F485C` en correas). Si usás `#080A0E` en el traje bajo iluminación nocturna de `Future`, el personaje se convierte en una mancha negra sin volumen.
   - **Regla 60 / 30 / 10 de silueta a 40 studs**: todo personaje legible debe tener: `60%` cuerpo principal del atuendo, `30%` pieza contrastante que corta la silueta (chaqueta abierta, pechera, cinturón ancho, pantalones de otro tono), `10%` foco cromático brillante o claro (cuello rojo, rayo/banda cian, bufanda blanca, visor).
   - **Capas y telas estilizadas**: las capas se modelan como **láminas sólidas de grosor limpio (`0.08–0.12` studs) con pliegues angulares marcados**, nunca como tres tablas rígidas planas (`centinela_vistas.png`) ni moños arrugados brillantes (`atalanta_vistas.png`).

### 2.2 Pelos (`Pelos`) — Regla estricta contra los "pelos goma"

- **Qué evitar** (visto en `pelo-comic-opciones.png`): mechones redondeados tipo gota/banana con `Shade Smooth` brillante sin quiebres.
- **Cómo se hace todo pelo en Linajes** (referencia `cuerpo-comic-opcion-1.png` y `cuerpo_peinados_v2`):
  - Construido con **cuñas poligonales y láminas prismáticas angulares** con crestas y puntas afiladas (`Mark Sharp` a lo largo de la espina central de cada mechón).
  - Cada peinado es **`1` sola `MeshPart`** soldada a `Head`, cubriendo frente (cerquillo/flequillo que enmarca cejas sin tapar los ojos), laterales (patillas sobre las orejas sugeridas) y nuca (nunca deja el cubo pelado atrás).
  - **Textura de pelo (`512 px`):** degradado limpio en 2–3 valores (raíz `-18%` más oscura / cuerpo tono base / puntas o mecha delantera `+14%` más clara) + líneas finas `#0E1016` entre grandes grupos de mechones. **`Roughness = 0.65–0.75`** (satinado cómic seco, nunca plástico mojado ni brillante).
  - Presupuesto: **`400 a 900 triángulos`** por peinado (`1.400` máximo en rulos complejos).

### 2.3 Caras y Expresiones (`Cara`)

- **Formato:** `Decal` frontal (`256 x 256` RGBA PNG transparente) sobre `Cuerpo_Head` en color piel plano biselado, intercambiable por código (`CuerpoComic.luau` / `P30b-05`).
- **Proporción facial oficial** (ref `cuerpo-comic-opcion-1.png`, `estilo-02`):
  - **Ojos geométricos angulares estilo cómic/anime**: línea superior de pestaña gruesa `#0E1016` (`4–6 px` en 256), borde inferior fino `#0E1016`, **esclerótica en Hueso `#EDE6D6`** (NUNCA `#FFFFFF` puro, porque de noche brilla como linterna), iris de color sólido + 1 punto blanco superior + 1 sombra superior de párpado.
  - **Cejas expresivas** inclinadas sobre los ojos (`#0E1016` o tono del pelo).
  - **Boca mínima** (1 trazo firme `#0E1016`, nunca labios pintados ni sombreados realistas); cicatrices/barbas opcionales con trazo limpio.
- **Set obligatorio por cara:** `8` expresiones (`Neutral`, `Enojado`, `Concentrado`, `Dolor`, `Sorprendido`, `Contento`, `Cansado`, `Derrotado`) + `Parpadeo` (cerrado `0.12s` cada `3–6s` al azar) + `3` visemas de boca al hablar en diálogos.

### 2.4 Atuendo jugador, Bandos y Jerarquía del Elenco

| Categoría | Presupuesto tris (total / tope malla) | ColorMap & Roughness | Silueta y regla de diseño |
|---|---|---|---|
| **Jugador — Base ("Atuendo Básico")** | `4.000 – 8.000` (sobre `CuerpoComic`) | `512 px` · `Roughness 0.78–0.90` | Remera corta bien cortada con cuello/puño contrastante, pantalón urbano con costuras de tinta, zapatillas bicolor. Simple pero con carácter, cero aspecto de "maniquí vacío". |
| **Jugador — Ropa comprable (`Urbano` y conjuntos)** | `8.000 – 18.000` (ropas modulares R15) | `512–1024 px` · albedo gris claro tintable por canal + tinta cómic | Piezas intercambiables por hueso (`Campera`, `Remera`, `Cinturón`, `Pantalón`, `Zapatillas`, `Casco`, `Capa`, `Peto`) con 2–3 canales pintables. **El emblema dorsal es del Bando, NO de la prenda.** |
| **Civiles (Calle viva)** | `1.000 – 3.000` (ropa mod.) | `512 px` · grises `_C1`/`_C2` tintados en Studio | Tonos urbanos apagados para que el jugador resalte encima. Solo el teléfono brilla suave (`#3FE0F0`) cuando filman o llaman. |
| **Enemigos comunes (`Matón`, `Matón implantes`)** | `7.500 – 10.000` (máx `1.200` por malla) | `512 px` · sin granulado | Campera oscura `#262B36`, detalle Cofradía apagado `#8E2A22`, cadena de hierro. El variante con implantes lleva brazo metálico limpio y **un solo punto brillante rojo `#E03A3E`** (ojo biónico) para identificarlo a distancia. |
| **NPCs clave (`Tano`, `Rivas`, `Vega`, `Kessler`)** | `12.000 – 20.000` (máx `3.000` por malla) | `512–1024 px` | Cada uno porta 1 prop característico de silueta clara (llave inglesa y trapo rojo en Tano, placa/impermeable en Rivas, cámara en Vega). |
| **Mentores y Jefes (`Remache`, `Albatros`, `Cuervo`, `Centinela`, `Atalanta`, `Mascarada`, `Estela`)** | `22.000 – 38.000` (límite absoluto Roblox: **`20.000` por `MeshPart`**) | `1024 px` · placas biseladas sin estática + 1–2 acentos `Neon_` chicos | **Refactors prioritarios sobre renders actuales:** quitar torso acolchado y granulado de estática en `Cuervo v2` y `Centinela`; afinar capa de `Atalanta` y `Centinela` a láminas con pliegues cómic; aclarar acero de `Remache` (`#3A4252`) para leer torso y brazos claramente contra su galpón rojo/oscuro. |

---

## 3. Pilar 3 — Efectos Especiales (VFX), Combate y Game Feel

### 3.1 La Regla de las 3 Capas (Reemplazo de bolas blancas y cubos negros)

Todo golpe, habilidad y dash sigue esta anatomía (referencia `estilo-04-poderes.png` y `Referencias de animación.md`). Se prohíbe emitir un simple `Part Neon` esférico o blanco sólido ni cubos lisos de escombros (`EfectosPoder.client.luau` actual).

| Capa | Función | Implementación técnica en Roblox |
|---|---|---|
| **1. Núcleo y Silueta (Forma principal)** | Comunica al instante *qué poder es y hacia dónde va* | **`MeshPart` estilizada** (`DoubleSided = true`, media luna de tajo, domo de choque, espiral de viento, cono de llama, prisma de hielo) con textura **alfa/erosión en scroll** + `ParticleEmitter` **`Grid4x4`** con `LightEmission = 0.45 – 0.70` (NUNCA `1.0` apilado al 100 % porque quema a blanco puro). |
| **2. Tinta Cómic, Impact Frame y Grietas** | Da identidad visual de **Linajes** y peso de golpe | **a)** Anillos y flipbooks de explosión/humo dibujados con **borde oscuro `#0E1016`**. **b)** Golpe 4 de combo, parry o definitiva: micro **Impact Frame (`25–40 ms`)** subiendo `ColorCorrection.Contrast = 0.65` con ligero tinte del Linaje + `Highlight` blanco hueso (`0.06 s`) en el golpeado. **c)** **Grietas del suelo** con `Decal` radial pintado (fade out `2.5–3 s`). **d)** **Escombros:** **3 modelos de cuñas/rocas irregulares poligonales facetadas** (nunca cubos) que giran y desaparecen encogiéndose. |
| **3. Apoyo, Chispas, Humo y Rastros** | Vende velocidad, polvo e integración al escenario | **a)** Chispas elongadas rápidas (`Squash = 1.5`, orientadas `VelocityPerpendicular`). **b)** Humo cómic denso con **`LightInfluence = 0.25`** y **`LightEmission = 0`** (absorbe la luz azul/naranja de la calle). **c)** **Estelas y velocidad:** `Beam` ancho pegado al piso siguiendo las curvas + **post-imágenes de dash** con clones semitransparentes del cuerpo real + `Highlight` sutil (no rectángulos sólidos). |

### 3.2 Avisos de ataque (`Aviso`) y lectura de combate

- Todo golpe fuerte de enemigo/jefe dispara marcador **`Aviso` `12 cuadros (0.4 s)` antes de `Impacto`**.
- **Forma visual en piso** (`+0.05` studs arriba del suelo): relleno rojo alerta `#D6333A` (`Transparency = 0.72`) con **borde nítido brillante `#FF6B5B` de `2–3 px`** y onda interior que se expande desde el centro hasta tocar el borde exactamente en el frame `Impacto` (referencia `combate/03-zona-roja-dash.png`).

### 3.3 Matriz visual oficial de los 12 Linajes

| Linaje | Color núcleo (brillo) | Color cuerpo / VFX | Color tinta / contraste | Lenguaje de formas y partículas |
|---|---|---|---|---|
| **Fuerza Bruta** | `#FFE09E` | `#F2A23A` + polvo `#B07A4A` | `#2A1F17` | Anillos gruesos fracturados, ondas de piso concéntricas, grietas radiales, cuñas de piedra volando, aire comprimido delante del puño. |
| **Reflejos** | `#E8FBFF` | `#3FE0F0` | `#132638` | Líneas cortas rectas de velocidad (`VelocityPerpendicular`), arcos finos de corte, pos-imágenes nítidas de cuerpo real, destellos en cruz de parry. |
| **Piroquinesis** | `#FFB347` | `#F2652B` → `#8E2A22` | `#161218` (humo denso) | Lenguas helicoidales esculpidas en Mesh/Flipbook con punta afilada + volutas de humo negro con contorno + brasas ascendentes finas. Nunca esfera blanca. |
| **Electro** *(estandarizado)* | `#F0F8FF` | `#4DB8FF` | `#101B2E` | Zigzags quebrados (`Beam` con jitter cada `0.04 s`) conectando puntos de impacto, arcos breves rodeando articulaciones, chispas azules rápidas. |
| **Criogenia** *(estandarizado)* | `#E8FBFF` | `#7CE8FF` → `#3BA3D0` | `#1D3A4F` | Prismas hexagonales puntiagudos brotando del piso, neblina blanca fría rastrera, cristales en triángulo que estallan al romperse. |
| **Telequinesis** *(estandarizado)* | `#E6D4FF` | `#A46CF0` | `#1E132B` | Aros orbitales concéntricos con muescas, contorno `Highlight` violeta en objetos levantados, ondas sutiles de distorsión geométrica. |
| **Velocista Cinético** | `#E8FBFF` / `#D9CCF5` | `#9A82D8` + estela `#3FE0F0` | `#1B1730` | `Beam` serpenteante continuo sobre el suelo detrás de los pies, arcos eléctricos finos entre extremidades, copias fugaces que se disuelven hacia atrás. |
| **Sombra Viva** | `#8E7AE6` (ojos/filos) | `#6B5BA8` | `#0E1016` / `#121216` | Zarcillos negros planos con borde violeta fino saliendo del suelo, humo negro denso mate, disolución en silueta al entrar/salir de sombras. |
| **Sangre Abisal** | `#EDE6D6` (espuma) | `#3FE0F0` / `#1F4A5A` | `#0E232B` | Chorros laminares gruesos con cresta blanca estilizada, anillos de agua en el piso, burbujas angulares y gotas pesadas que caen con gravedad. |
| **Origen Estelar** | `#FFF5D6` | `#F2A23A` → `#E8E6E0` | `#3A2910` | Haces de rayo limpio con anillo expansivo al disparar, motas estelares de 4 puntas alargadas, aura solar tenue sin tapar el cuerpo. |
| **Herencia Olímpica** | `#FFF7DE` | `#D9A441` → `#A0703A` | `#2B1E10` | Armas proyectadas en energía translúcida dorada con borde firme, relámpagos dorados/blancos y pequeñas hojas doradas flotando al caer. |
| **Eclipse** | `#FFB347` (halo) | `#F2652B` | `#0E1016` (núcleo negro) | Núcleo negro absoluto rodeado por un anillo fino incandescente naranja-dorado, grietas oscuras en el aire con resplandor en los labios de la grieta. |

### 3.4 Game Feel y Regla Celular (`Alto` vs `Bajo`)

- **Hit-Stop (solo cliente, congelando `AnimationTrack.Speed = 0` de atacante y víctima):** golpe liviano `0.04 s`, golpe fuerte / habilidad `0.08 s`, golpe 4 / parry / remate `0.12 s`. No retrasa ni cambia los frames del servidor.
- **Sacudida de cámara (`Camara.client.luau`):** golpe normal `0.12` studs (`0.12 s`); golpe fuerte / habilidad `0.30–0.42` studs (`0.22 s`); definitiva / golpe de jefe `0.60` studs (`0.32 s`). Se apaga si el jugador desactiva sacudida en Ajustes.
- **Modo `Bajo` (Celular):** `Rate * 0.5`, **0 luces `PointLight` dinámicas en proyectiles o partículas**, `Impact Frame` desactivado, vida del humo `-35%`. **Se mantienen intactos al 100 %:** el `Aviso` rojo de piso del enemigo y el anillo principal de impacto para no perjudicar la jugabilidad.

---

## 4. Pilar 4 — Interfaz de Usuario (UI — Sistema Editorial Oscuro `@r0aringexe`)

### 4.1 Filosofía y reglas de forma

La interfaz toma el lenguaje de **`Tema.luau`, `Config.Hud`, `hud-maqueta.svg` y el menú de `@r0aringexe` (#2)**: **editorial oscura, geométrica, silenciosa y sin ruido visual**, para que el combate y la atmósfera de la ciudad respiren.

- **Prohibido en toda UI del juego:** cajas opacas redondeadas (`UICorner >= 8 px`), bordes cyan ciberpunk gruesos, marcos plateados barrocos/medievales (`interfaz/03, 06`), gradientes arcoíris y fuentes gruesas tipo cartoon (`GothamBlack` en `BarraMatones.client.luau`).
- **Superficies:**
  - **En HUD y Menú Principal:** **sin cajas de fondo** (`BackgroundTransparency = 1`), apoyado en `Vineta` sutil en los bordes y sombra suave detrás del texto.
  - **En ventanas modales (Creador, Árbol, Taller, Ruleta, Ajustes):** fondo plano `#0D1017` al `88%` de opacidad (`BackgroundTransparency = 0.12`), esquinas rectas **`0 px` o bisel mínimo `2 px`**, **borde estructural `UIStroke` de `1 px` en Hueso `#EDE6D6` al `18%` de opacidad** (`Transparency = 0.82`). Al pasar/seleccionar sube a `1.5 px` al `75%` o toma el color del bando/Linaje activo.
  - **Motivo geométrico propio:** el **rombo girado `45°`** (`Tema.rombo`) para slots de poder, nodos del árbol, punteros de lista y niveles; y la **línea fina que se desvanece hacia los extremos con rombito central** (`Tema.ornamento`) para separar secciones y encabezados.

### 4.2 Tipografía oficial única (`Oswald`)

- **Única fuente del juego:** `Oswald` (`rbxasset://fonts/families/Oswald.json`), ya cargada en `Tema.luau`.
  - **`Oswald SemiBold`:** títulos principales, nombres de jefes, acciones primarias (`CONFIRMAR`, `GIRAR`, `FABRICAR`), números clave (nivel, cooldown, daños críticos). Siempre en **MAYÚSCULAS** para encabezados con **tracking espaciado (`Tema.espaciar(..., 2)` en títulos grandes, `1` en subtítulos/etiquetas)**.
  - **`Oswald Regular`:** cuerpo de diálogos NPC, descripciones cortas de habilidades/nodos, respuestas, valores de taller.
  - **`Oswald Light`:** metadatos sutiles (nivel/bando/ciudad debajo del nombre, subtítulos arriba del título principal como en el menú de `@r0aringexe`), textos secundarios en gris `#9FA7B5`.
- **Escala base (`1080p`, escalada automáticamente por `UIScale` clamped `0.62–1.25`):** Titular menú/jefe `32–42 px` · Título panel `22–26 px` · Botón/pestaña `16–18 px` · Cuerpo legible `15–16 px` · Micro-etiqueta / tecla `12–13 px`.
- **Legibilidad sin contorno duro:** `TextStrokeColor3 = #080A0E`, `TextStrokeTransparency = 0.55` (sombra suave, nunca borde grueso negro).

### 4.3 Reglas móviles (`844 x 390`) y tiempos de animación

- Todo elemento tocable tiene **área mínima de toque de `48 x 48 px`** reales aunque su dibujo visual sea un rombo fino o una línea de texto.
- En celular (`844 x 390`), **zona izquierda inferior reservada para joystick virtual** y **zona derecha inferior reservada para arco de pulgar derecho**. Los paneles modales no deben tapar los controles cuando están pensados como superposición rápida.
- **Animación estándar UI:** aperturas y hovers con `TweenService` `Quart.Out` de **`0.16 s`**; barras con marca de daño `#E8C9A0` tras **`0.45 s`** de espera (`Config.Hud.DanioEspera`); máquina de escribir de diálogos `40 caracteres/s` con salto instantáneo al tocar.

### 4.4 Plano unificado de las 10 Pantallas (`P33c` / `P33`)

1. **Menú principal (referencia directa: menú de `@r0aringexe` #2):** cámara lenta orbitando alrededor del personaje en el muelle frente al Eclipse con `DepthOfField` activo. Arriba izquierda: subtítulo tenue + `L I N A J E S   D E L   E C L I P S E` + `Ornamento`. Debajo en columna **sin cajas**: `◇ CONTINUAR` (con nombre, Linaje en su color, bando y nivel en `Light` gris abajo), `◇ ESPACIOS  ◀ 1 / 3 ▶`, `◇ AJUSTES`, `◇ CRÉDITOS`.
2. **Creador de personaje:** personaje en vivo al 55 % izquierdo con iluminación de puerto; panel único `#0D1017` al 88 % a la derecha con pestañas subrayadas (`CUERPO · CARA · PELO · ROPA`), grilla de celdas cuadradas con borde fino (`2 px`), selector de `10` tonos de piel (`Config.Cuerpo.TonosPiel`) + paletas rápidas, campo de nombre con línea inferior única de `1 px` y botón angular sólido en Hueso `#EDE6D6` con texto `#080A0E` (`CONFIRMAR`).
3. **Ruleta de Linaje:** rueda concéntrica minimalista de anillos finos Hueso con marcas radiales y puntero rombo arriba (izquierda); lista derecha de Linajes por rareza con `%` y barra vertical de color de rareza de `3 px`; arriba `S E G U R O   N / 4 0`; abajo botón `GIRAR (1 FICHA)`. Al frenar, pulso breve en el color de la rareza obtenida.
4. **HUD de pelea:** ver Sección 5.
5. **Árbol (`ESTADÍSTICAS` | `LINAJE`):** dos pestañas subrayadas arriba. En *Estadísticas*: 6 barras finas `4 px` estilo HUD con `+` en rombo chico y puntos arriba (`N / 40`). En *Linaje*: mapa de **nodos rombo `45°` unidos por líneas rectas de `1.5 px`** (`Poder`, `Cuerpo`, `Técnica` + fila horizontal inferior `Movimiento`). Nodo apagado `#565E6D`, disponible `#EDE6D6` con pulso lento, desbloqueado `[Color del Linaje]`, variante oculta `???` difuso. Ficha compacta a la derecha con botón `DESBLOQUEAR`.
6. **Diálogo con NPC:** oculta el HUD, activa `DepthOfField` y acerca la cámara en 3/4 sobre el NPC. Abajo izquierda/centro sin caja pesada (viñeta inferior más densa): nombre del hablante espaciado con acento `3 px` de su bando + `Ornamento`, texto de diálogo de `2–3` líneas máximo. Abajo derecha: hasta `4` opciones en lista editorial con rombo `◇` (la última siempre `ADIÓS`).
7. **Taller (Tano / Refugio):** lista vertical izquierda de fabricables (`Traje`, `Gadgets`, `Vehículo`, niveles `Mk I–V`), visor 3D libre del objeto al centro (sin recuadro opaco), columna derecha con costos `Tengo / Necesito` en números tabulares (`Chatarra`, `Chips`, `Piezas raras`) y botón `FABRICAR`.
8. **Lista de jugadores (Tab):** tarjeta estrecha arriba a la derecha (`#0D1017` al `85%`, borde `1 px` Hueso `18%`), agrupada por `LIGA`, `COFRADÍA`, `VIGILANTES` y `NEUTRAL`; cada grupo abre solo con barra vertical de `3 px` del color del bando + nombre de bando espaciado; debajo, jugador + rango + fama en `Light`.
9. **Ajustes:** panel centrado con 3 deslizadores de barra fina `2 px` + perilla en rombo `14 px` (`Música`, `Efectos`, `Sensibilidad cámara`), selector binario `CALIDAD: ALTO / BAJO` y toggle `Sacudida de cámara`.
10. **Aviso de Buscado y Noticias El Faro:** arriba derecha `1 a 5` estrellas angulares en rojo `#E03A3E` (solo visibles cuando Buscado > 0 o en alerta) + anillo translúcido rojo sobre minimapa cuando patrullas buscan tu zona; arriba centro cintillo angosto negro translúcido `82%` con doble línea Hueso tenue para titulares de última hora de *El Faro*.

---

## 5. Pilar 5 — HUD de Pelea, Emblemas, Íconos 2D y Cinemáticas

### 5.1 Disposición exacta del HUD (`Config.Hud` + `hud-maqueta.svg`)

El HUD base ya sigue a `@r0aringexe` (`Tema.luau`, `Estado.client.luau`, `Poderes.client.luau`, `Combate.client.luau`):

- **Marco ambiental (`Vineta`):** viñeta negra `#080A0E` sutil pegada a los 4 bordes para que las barras y el hueso `#EDE6D6` lean sobre explosiones o cielo de Corona sin encajonar nada.
- **Abajo izquierda (`Margen = 72 px` en 1080p):**
  - Rombo de Nivel (`64 px` a `45°`, fondo `#080A0E` al `55%`, borde `1.5 px` `#EDE6D6`, número `SemiBold`).
  - Barras horizontales paralelas a la derecha: **Vida** (`380 x 5 px`, `#B8343A` con rastro retardado `#E8C9A0` a los `0.45 s`) · **Energía** (`300 x 3 px`, en `[Color del Linaje]`) · **XP** (`300 x 2 px`, `#C9A55A`) + línea de texto en `12 px` espaciado con Linaje y Bando.
- **Abajo centro (contextual — desaparece a los `4 s` sin combate):**
  - **Enemigo / Rival o Jefe:** barra centrada (`340 x 4 px` enemigo, `540 x 5 px` jefe) en `#B8343A` con rastro `#E8C9A0`, nombre espaciado arriba en `SemiBold` (`R E M A C H E`), título de fase a la derecha y muescas finas verticales marcando cambios de fase.
- **Abajo derecha (Poderes y Gadget):**
  - **PC:** 4 rombos `45°` (`TamRombo = 92 px`, separación `112 px` entre centros) para `Z`, `X`, `C`, `V` + rombo satélite (`68 px`) para `G` (Gadget/Gancho). Marco `MarcoRombo` en Hueso; adentro **ícono monocromo Hueso tintado con el color del Linaje cuando está listo**, y en recarga oscurecido `0.65` con contador numérico `SemiBold` encima y barra/velo vertical de progreso. Tecla indicada abajo en rombo/badge mínimo `12 px`.
  - **Celular (`<= 844x390`):** grupo inferior derecho organizado en arco ergonómico para el pulgar derecho (botón ataque básico abajo esquina, rombos `Z`, `X`, `C`, `G`, `Dash`, `Bloqueo` sin superponerse, mínimo `48 px` físicos).
- **Barras flotantes sobre enemigos (`BarraMatones.client.luau` — migración pendiente):**
  - Reemplazar las cajas actuales (`GothamBlack` y rojo sólido viejo) por barra editorial ultra-fina (`86 x 4 px`, fondo `#080A0E` al `65%`, relleno `#B8343A` + rastro `#E8C9A0`, nombre en `Oswald Light 12 px` Hueso `#EDE6D6` con sombra suave), visible únicamente a `< 35 studs` o tras recibir daño.

### 5.2 Íconos 2D, Logo y Emblemas de Bandos

- **Íconos de habilidades, Linajes y Gadgets (`arte/hud/listas/`):**
  - Dibujados en **monocromo Hueso `#EDE6D6` puro con cortes negativos limpios**, sin contorno negro de caricatura ni neones internos, sobre alfa limpio (`hud_procesar.py`).
  - **¿Por qué monocromo?** Permite que el código (`Tema.luau` / `Poderes.client.luau`) aplique `ImageColor3` al color exacto de cada Linaje, pase a gris apagado en recarga y brille en Hueso puro en los rombos del HUD (`hud-maqueta.png`) con coherencia absoluta.
  - Tamaño fuente `512 x 512`, margen `6%`, subidos a Roblox en `256 x 256` o `128 x 128`, legibles en prueba de `42 x 42 px`.
- **Emblemas de los 4 Bandos (prohibido usar rombo igual para todos — regla de `Ropa y tienda.md`):**
  - **Liga de Guardianes (`#2F6FDB`):** escudo hexagonal angosto con rayo/sol calado.
  - **Cofradía Carmesí (`#C2213A`):** rombo alargado vertical partido diagonalmente por una hoja/daga.
  - **Vigilantes (`#6B5BA8`):** emblema en V vertical de dos alas/plumas angulares plegadas.
  - **Neutral (`#8A8F99`):** aro incompleto rodeando un disco partido de eclipse.
- **Logo oficial (`LINAJES DEL ECLIPSE`):** letras condensadas monumentales tipo `Oswald SemiBold` en Hueso/acero claro `#EDE6D6` con una grieta fina naranja Eclipse `#F2652B`, eclipsando detrás el disco negro `#080A0E` bordeado por halo controlado naranja-dorado (`#F2652B` / `#FFB347`), sin capas, murciélagos ni neones ciberpunk.

### 5.3 Cinemáticas

- Franjas negras `#080A0E` arriba y abajo del **`10%`** de alto (`Tween 0.35 s`), ocultando todo el HUD.
- Subtítulos centrados abajo dentro de la franja o justo arriba: nombre del hablante en `Oswald SemiBold 13 px` espaciado con el color de su bando, línea de diálogo debajo en `Oswald Regular 20 px` Hueso `#EDE6D6` (máximo 2 líneas, `~42` caracteres por línea).
- Botón discreto `S A L T E A R  [ESPACIO]` / táctil grande en inferior derecha habilitado a los **`2 s`**.

---

## 6. Sufijos estándar para Gemini (reemplazo del bloque viejo de `Plantilla de prompt.md`)

> [!warning] Regla para próximos prompts
> El sufijo viejo de `Plantilla de prompt.md` (`"wet night city lit by neon... heavy shape detail (layered plates, seams, rivets, bevels)"`) está **obsoleto** porque generaba placas acolchadas remachadas y estética cyberpunk. Usar estos 3 bloques unificados según el caso:

- **Bloque A — Personajes y Assets 3D:**
  `Style: stylized dark graphic-novel comic 3D game art, crisp blocky Roblox R15 proportions, clean flat beveled planes with sharp edges and subtle painted ink seam lines (NO rounded pillows, NO noisy rivets, NO clay surface), muted weathered industrial harbor palette illuminated by directional sodium-orange glow against cool slate fog, high value separation, zero cyberpunk neon signs. Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.`
- **Bloque B — Hojas de VFX / Poderes:**
  `Style: stylized 3D game VFX concept sheet, bold directional silhouettes with dark comic ink outlines and crisp cel-shaded energy cores (NO blurry white glow blobs, NO generic spark stars), dark moody slate background #080A0E, legible at phone scale, no text, no watermarks.`
- **Bloque C — Íconos de HUD y UI:**
  `Style: ultra-minimal dark editorial game UI, pure solid monochrome bone-white #EDE6D6 sharp geometric glyph centered with 6% margin on clean #00FF00 chroma green background, sharp angular negative-space cuts, NO outer black cartoon stroke, NO glow haze, legible at 42 pixels, no text, no logos.`

---

## 7. Reglas técnicas y legales (no negociables)

- **Nada de DC ni Marvel:** cero nombres, logos, símbolos, trajes ni frases de Warner/DC o Marvel en nada exportado o subido (ver [[Sobre DC]]).
- **No copiar assets ni texturas** de capturas de otros juegos: se toman técnicas y clima, todo diseño nace propio.
- **Presupuesto Roblox y celular:** tope absoluto **`20.000` triángulos por malla individual**, **`1` material (`SurfaceAppearance`) por `MeshPart`**, `StreamingEnabled` radio `512`, texturas de `256 / 512 / 1024 px` (`2048 px` solo piso base).
- **Monetización limpia:** ni Linajes ni ropa ni implantes ni ventajas de pelea se venden como cajas aleatorias o pay-to-win por Robux.
- **Todo número ajustable vive en `Config.luau` / `Iluminacion.luau`**: jamás desperdigar hexes o tiempos sueltos en scripts cliente/servidor.

---

**Notas conectadas:** [[Colores]] · [[Sistema de diseño]] · [[Nivel de detalle]] · [[Arena en Blender]] · [[Referencias analizadas]] · [[Sobre DC]] · [[Lugares]] · [[Bandos]] · [[Linajes]]
