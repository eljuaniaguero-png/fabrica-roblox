# Plinko Knight · Prompts de ForgeGUI (etapa 7b-2, modelos de la sala)

Estilo de ForgeGUI: **"Plinko Knight - Sala arcade"** (id `fb49b64e-b456-470a-80ce-6085099f9a1f`, versión 1), creado el 26/10/2026.
Solo con texto (la frase de estilo del plan): no se usaron las capturas de Juani como imágenes de estilo porque casi todas tienen nombres o personajes de FNAF o tragamonedas de CloverPit, y la IA los podría copiar.

| # | Modelo | Paso | Prompt | Id de ForgeGUI | Estado |
|---|---|---|---|---|---|
| M1 | maquina-principal | Concepto (3 opciones) | Concept for a 3D game asset: a tall standing retro arcade cabinet, chunky and toy-like. Large wide glowing screen showing a dark blue dungeon with rows of small golden pegs. A blank lit marquee panel on top with no text. Control panel with a short joystick and three big round arcade buttons (yellow, magenta, cyan). Side panels decorated with a simple painted cartoon knight helmet and stone bricks, no text. Neon magenta and cyan trim lines along the edges. Whole cabinet visible, standing on the floor, front three-quarter view, isolated. | `3c74838d-f815-4dd2-b18e-57a3bc4f023f` | Se trabó (tipo "mixed", más de 6 min sin avanzar): se rehízo abajo |
| M1 | maquina-principal | Concepto (3 opciones, tipo icon_gfx, fondo gris) | El mismo, con "on a plain dark grey studio background" y "Whole cabinet visible from top to floor" | `284d133b-a3e4-4c90-99a7-1a7ee51d688e` | 3 opciones en `arte/forgegui/sala/m1-conceptos.png`. Juani eligió la **C** sin el caballero |
| M1 | maquina-principal | Concepto C sin caballero (edición de la C) | Same arcade cabinet as the reference image, keep its shape, colors, neon magenta and cyan trims, wide glowing screen with the dungeon pegs, white screen bezel, blank marquee, joystick and three buttons exactly the same. Only change: the side panel has NO character and NO helmet at all, only the painted stone bricks pattern covering the whole side. Plain dark grey studio background, whole cabinet visible from top to floor, front three-quarter view, centered, no text. | `8ca7dc0c-ead3-4932-b34f-243a4289716b` (opción 1) | Quedó (`arte/forgegui/sala/m1-c-sin-caballero.png`) |
| M1 | maquina-principal | 3D (quality high, Meshy por ForgeGUI) | A standing retro arcade cabinet, exactly like the reference image: chunky toy-like body, wide screen with a white bezel, blank lit marquee on top, control panel with a joystick and three round buttons (yellow, magenta, cyan), side panels painted with stone bricks, neon magenta and cyan trim lines along the edges. Game-ready single object, flat bottom standing on the floor, no text. | `81965f8d-1a56-4f63-b582-eb7c78b6273c` | Quedó: `modelos/ia/maquina-principal.glb`, 11.916 triángulos, 1 malla, 1 material, mide 0,96 × 1,90 × 1,08 m (escalar a ~7 studs en 7b-3). No subido a Roblox todavía |

**Cambio respecto del plan:** la pantalla de M1 es **ancha** (el plan decía vertical), porque la cámara entra en la pantalla y adentro la mazmorra se ve ancha (3 columnas).

## Tanda M2 a M8 (conceptos, 26/10/2026)

Todos con el estilo "Plinko Knight - Sala arcade", tipo icon_gfx, 1 opción cada uno. Hoja: `arte/forgegui/sala/m2-m8-conceptos.png`. Empiezan todos con "Concept for a 3D game asset on a plain dark grey studio background:" y terminan con "front three-quarter view, centered, no text".

| # | Modelo | Prompt (lo del medio) | Id de ForgeGUI | Estado |
|---|---|---|---|---|
| M2 | maquina-fondo-naves | background retro arcade cabinet for a space shooter game, screen in attract mode with a tiny pixel spaceship and stars, joystick and two buttons, side panels with planets and stars, neon cyan trim | `8c3bc166-e8af-4747-af8f-79a4b9cdfd53` | Concepto aprobado; 3D hecho (ver abajo) |
| M3 | maquina-fondo-autos | sit-down racing cabinet with a small steering wheel and a pedal, screen with a simple road and a tiny car, checkered racing stripes, neon magenta trim | `f5f542b9-287b-467b-865b-9c18abc97f88` | Concepto aprobado; 3D hecho (ver abajo) |
| M4 | maquina-fondo-laberinto | short squat cabinet, screen with only abstract glowing shapes and diagonal neon lines (no characters, no maze, no dots, no ghosts), zigzag side panels, "not based on any existing game" | `9426c1f7-c1a0-4f82-986a-1fcbbfca16a1` | Concepto aprobado; 3D hecho (ver abajo). **Se rehízo:** la primera (`a4f61147-…`) tenía fantasmas como los de Pac-Man |
| M5 | banqueta | round arcade stool, padded navy cushion, chrome pole, round base, neon magenta ring | `20319b2e-0ae0-4413-ae22-21c2aaef24de` | Concepto aprobado; 3D hecho (ver abajo) |
| M6 | mesa-objetos | small side table with neon cyan edge; soda cup, plain cardboard box with no print, rounded generic controller with magenta and cyan buttons (not a real brand), rubber duck; no logos | `24ab3d65-a8c6-42c8-847b-b097166da093` | Concepto aprobado; 3D hecho (ver abajo). **Se rehízo:** la primera (`3838b0b8-…`) tenía un joystick de Nintendo y una caja con etiqueta. Sin muñequito de caballero (el caballero salió del juego) |
| M7 | mostrador-tienda | long low counter with a glass showcase and three small empty glass boxes, neon strips, no cash register, no coins, no prizes | `cbf22a22-a65a-4c98-85c0-0b9e30911997` | Concepto aprobado; 3D hecho (ver abajo) |
| M8 | cajita-vidrio | glass cube on a short dark metal base, neon cyan strip at the bottom, empty | `5952d9f1-91b3-420e-9c4e-2d8ebe09a36a` | Concepto aprobado; 3D hecho (ver abajo) |

## Tanda M2 a M8 (3D, 26/10/2026)

Juani aprobó los 7 conceptos. 3D con ForgeGUI (Meshy, quality high), cada uno con su concepto como referencia y el prompt "…exactly like the reference image…". Bajados a `plinko-knight/modelos/ia/` (no subidos a Roblox todavía). Hoja con los 8: `modelos/ia/todos-los-modelos.png`.

| # | Archivo | Id de ForgeGUI | Triángulos | Máx. del plan | Mide (m) |
|---|---|---|---|---|---|
| M1 | maquina-principal.glb | `81965f8d-1a56-4f63-b582-eb7c78b6273c` | 11.916 | 15.000 | 0,96 × 1,90 × 1,08 |
| M2 | maquina-fondo-naves.glb | `88376c4f-10e7-4607-96c3-683bbc4da7e1` | 13.517 | 6.000 | 1,06 × 1,90 × 1,35 |
| M3 | maquina-fondo-autos.glb | `058fd58b-fdf5-441e-98c4-67ec93b4b0c5` | 12.285 | 6.000 | 0,92 × 1,90 × 1,21 |
| M4 | maquina-fondo-laberinto.glb | `c04da74b-56d1-46bd-97b0-75e6c064f43a` | 14.411 | 6.000 | 1,11 × 1,90 × 1,32 |
| M5 | banqueta.glb | `44b9cc1a-acca-4257-8896-55d3329f0b06` | 14.282 | 1.500 | 1,69 × 1,90 × 1,69 |
| M6 | mesa-objetos.glb | `b2717f50-ac81-4682-a216-a35c19671836` | 13.933 | 6.000 | 1,81 × 1,90 × 1,81 |
| M7 | mostrador-tienda.glb | `797b2bd4-a58a-47e5-9525-ff60ff5fa856` | 9.733 | 8.000 | 1,90 × 0,68 × 0,64 |
| M8 | cajita-vidrio.glb | `c1aef3d9-8fdf-4f1b-bdae-bf2bb7bd2679` | 10.118 | 1.500 | 1,26 × 1,90 × 1,26 |

Todos: 1 malla y 1 material. La IA los entrega con el lado más largo en 1,9 m, así que **en 7b-3 hay que escalarlos** (máquina ~7 studs, banqueta 2,5) y **bajar triángulos en Blender** a los máximos del plan (salvo M1).

## Tanda M9 a M13 (conceptos, 26/10/2026)

Mismo estilo y formato que M2 a M8 (icon_gfx, 1 opción cada uno). Hoja: `arte/forgegui/sala/m9-m13-conceptos.png`. M14 (figura del caballero) ya no va: la estatua es tu avatar, hecha por código.

| # | Modelo | Prompt (lo del medio) | Id de ForgeGUI | Estado |
|---|---|---|---|---|
| M9 | pared-records | large wall-mounted frame for a high-score board, round marquee bulbs around the border, neon strips, plain flat empty dark panel inside, no numbers or letters | `5cdd9b7e-3216-497e-b22d-d6e19d5bda4a` | Concepto aprobado; 3D hecho (ver abajo) |
| M10 | molinete-entrada | waist-high metal turnstile with three rotating arms, neon cyan strip and a small green arrow light, no card reader, no coin slot | `360778a2-0079-4315-aeea-45c917e680bd` | Concepto aprobado; 3D hecho (ver abajo) |
| M11 | maceta-planta | big round dark navy planter with a neon magenta ring and a lush tropical plant | `a69afa59-0aaa-48c5-8adb-f7e85cb563df` | Concepto aprobado; 3D hecho (ver abajo) |
| M12 | tacho-basura | rounded mall trash bin, domed lid with swinging flap, neon cyan band, empty and tidy, no symbols | `e6784746-4c44-47b3-ac51-c3a71375c97e` | Concepto aprobado; 3D hecho (ver abajo) |
| M13 | poste-neon | tall dark round pillar, glowing neon magenta ring at the base, thin vertical cyan stripe | `ae3b6fe8-5684-4a04-b02f-e714cdbcb922` | Concepto aprobado; 3D hecho (ver abajo) |

## Tanda M9 a M13 (3D, 26/10/2026)

Juani aprobó los 5 conceptos. Igual que la tanda anterior (Meshy por ForgeGUI, quality high, el concepto como referencia). Hoja con los 13: `modelos/ia/todos-los-modelos.png`.

| # | Archivo | Id de ForgeGUI | Triángulos | Máx. del plan | Mide (m) |
|---|---|---|---|---|---|
| M9 | pared-records.glb | `1801bc3a-1623-4c29-aa9a-0156679c6c71` | 10.126 | 3.000 | 1,90 × 1,34 × 0,22 |
| M10 | molinete-entrada.glb | `c8844e1f-b1cc-4748-8c05-47bff0c3a30e` | 12.115 | 3.000 | 1,52 × 1,90 × 1,85 |
| M11 | maceta-planta.glb | `0337f0c0-0419-43fe-9b42-eb045fdc2b56` | 13.781 | 3.000 | 1,76 × 1,54 × 1,90 |
| M12 | tacho-basura.glb | `c6051010-0861-4c07-8fbe-4d97efc1e9aa` | 14.275 | 1.500 | 1,38 × 1,90 × 1,33 |
| M13 | poste-neon.glb | `a4b8755c-8717-4aba-a9eb-fd6b269dc1b9` | 9.580 | 2.000 | 0,81 × 1,90 × 0,82 |

**Etapa 7b-2 terminada:** 13 modelos (M1 a M13); M14 no va. Todos de 1 malla y 1 material. En 7b-3: escalar, bajar triángulos en Blender a los máximos y subirlos a Roblox.

## Etapa 7b-3 · Limpieza (remesh) y subida a Roblox (26/10/2026)

Remesh de ForgeGUI (topología triángulos) al máximo del plan; después publicados como Model en la cuenta de Juani. Glb limpios en `modelos/limpios/`.

| # | Remesh (id) | Triángulos | Id de Roblox |
|---|---|---|---|
| M1 | (sin remesh, 11.916) | — | 128668549733552 |
| M2 | `3de60c85-2460-477c-aae7-557b46fc54cd` | 6.000 | 117819448578361 |
| M3 | `043e0587-b43a-4a2e-9cbe-77911ce82e86` | 6.000 | 119557592984296 |
| M4 | `f213cc4d-6a02-400b-8ead-e3206c9d489a` | 6.000 | 131991761922226 |
| M5 | `ed9e1a54-5b4e-43b7-9172-cecdf2f5b65e` | 1.500 | 113006751369088 |
| M6 | `cf8b0927-e158-466b-9035-f316f1188ec9` | 6.000 | 120712174872373 |
| M7 | `04e5d16f-9c57-400d-8172-a1c05aeef13f` | 8.000 | 112597161912739 |
| M8 | `2d9c7320-5af2-4d0c-8a8b-44649df56cbf` | 1.500 | 94618219124890 |
| M9 | `13157409-4a00-492c-81e6-ca7c9ef3316d` | 3.000 | 130935584485110 |
| M10 | `a04d406a-cd16-4d3b-aae4-42f03adb2185` | 3.000 | 137841564443967 |
| M11 | `c7a1af7b-e305-409a-a4da-060d02ab6707` | 3.000 | 105932246266763 |
| M12 | `11b63e6c-21d3-47c2-854c-db44338b6d5b` | 1.500 | 75610856010776 |
| M13 | `5bce06ba-ec59-470e-b1a7-7d822b28b6bf` | 2.000 | 79663817756766 |

