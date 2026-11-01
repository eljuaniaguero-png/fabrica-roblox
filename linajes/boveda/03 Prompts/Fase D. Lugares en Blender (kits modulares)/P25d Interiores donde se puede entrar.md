---
tags: [prompt, lugares]
beta: "Solo 3 interiores: el **taller de Tano** (se rehace de cero), el **galpón de Remache** y el **almacén del muelle** (el atraco). Los otros 17 de la tabla, en la Post beta, uno por sesión."
---
# P25d Interiores donde se puede entrar

> [!summary] En tres líneas
> Interiores donde se entra caminando, sin pantalla de carga: el taller de Tano, el galpón de Remache y el almacén del atraco en la Beta. Cada uno se diseña primero con 2 o 3 imágenes de Gemini, después boceto de bloques, detalle y exportación.

> [!info] En la Beta
> Solo 3 interiores: el **taller de Tano** (se rehace de cero), el **galpón de Remache** y el **almacén del muelle** (el atraco). Los otros 17 de la tabla, en la Post beta, uno por sesión.

## 1. Para qué es
Arma por dentro los lugares donde pasa la historia de la Beta. El **taller** es tu base (fabricar traje y gancho, trabajos de mecánico); el **galpón de Remache** es la arena de la pelea final; el **almacén** es el primer atraco. El primer intento del taller se descartó: este prompt lo rehace con referencias de Gemini primero.

**Qué tener abierto:** Blender con el conector de Claude. Gemini en el navegador. Obsidian para ver los renders.

**Dónde queda:** `linajes/arte/blender/interior-<archivo>.blend`, script `linajes/arte/scripts/interiores/<archivo>.py`, exports en `linajes/arte/exports/interior-<archivo>/`, nota en `08 Lugares/<lugar>.md` (sección Modelo).

## 2. Qué leer antes
- [[Taller de Tano]] · [[Galpón de Remache]] · [[Puerto Óxido]] (fachadas y medidas)
- [[Tano]] y [[Remache]] (quién vive ahí, colores)
- [[Los muelles rojos]] (qué misión pasa en cada interior)
- [[Calle viva]] (lugares donde se entra)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: TALLER: vista general desde el portón** → guardar como `linajes/arte/referencias/gemini/interiores/taller/ref-1.png`
```
Interior of a small family-run mechanic garage in a foggy rundown harbor district at night, seen from the open roll-up door at eye level. Footprint 40 x 30 studs, walls 16 studs tall, gabled corrugated-steel roof on rusty I-beam trusses. Left wall: two-post yellow car lift holding a boxy old compact car with its hood open. Back wall: long heavy wooden workbench (dark oak, steel edge banding, dented corners) with a vise, a half-built grappling-hook gadget, scattered bolts, and above it a pegboard with modeled wrenches, pliers, hammers and a coiled hose. Right side: wooden mezzanine with a ladder, a folding cot and a small radio. Center: crafting table with a small cyan screen. Floor of cracked concrete slabs with oil stains, a drain grate and a diamond-plate mat. Two hanging industrial lamps with warm orange light, cold blue-grey light coming from the door. Red tool cart, two rusty oil drums, a red air compressor, a dented green metal locker, a calendar-shaped blank poster. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: TALLER: planta desde arriba con las zonas** → guardar como `linajes/arte/referencias/gemini/interiores/taller/ref-2.png`
```
Top-down orthographic floor plan of a 40 x 30 stud mechanic garage, clean game-design blockout look: roll-up door 12 studs wide on the south wall, side man-door 4 x 7 studs on the east wall, car lift zone (west), workbench and pegboard zone (north wall), crafting table (center), mezzanine with ladder (east), tool cart and compressor (south-east corner), drums and locker (north-west corner). Show 6-stud-wide clear walking lanes between zones, each zone tinted a different muted color, grid lines every 4 studs. No text, use simple icons. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: TALLER: hoja de detalle de materiales** → guardar como `linajes/arte/referencias/gemini/interiores/taller/ref-3.png`
```
Game asset detail sheet on a dark blueprint background, four close-ups pointed with arrows (no text): 1) corrugated steel wall panel with rust streaks, overlapping seams and a bolted horizontal girt, 2) workbench corner: dark oak top with knife marks, steel edge band, a drawer pulled open with tools inside, 3) concrete floor slab with cracks, oil stain and a diamond-plate mat with dirty edges, 4) hanging industrial lamp: enamel shade, cage, chain and a cable running along a beam. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 4: GALPÓN DE REMACHE: arena desde la pasarela** → guardar como `linajes/arte/referencias/gemini/interiores/remache/ref-1.png`
```
Interior of a large red-painted harbor warehouse turned into a boss arena at night, seen from a high catwalk. 60 x 40 studs, 20 studs tall. Clear open fighting floor in the center (no columns), stacked shipping containers along the walls, three tall glass tanks of glowing red liquid connected by thick hoses, a big hanging lamp swinging on a chain, a steel cage in a corner, red tube lights, peeling red paint over rusty corrugated steel, puddles on the concrete floor reflecting the red light. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 5: ALMACÉN DEL MUELLE: planta del atraco** → guardar como `linajes/arte/referencias/gemini/interiores/almacen/ref-1.png`
```
Top-down orthographic plan of a harbor storage warehouse 48 x 32 studs for a small heist mission: two entrances (front roll-up door locked, back door with a padlock), a guard booth, two security cameras with view cones, rows of shelving with crates, a small office with a safe, a skylight on the roof as a stealth entry. Muted zone colors, 4-stud grid, simple icons, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, linajes/boveda/02 Estilo/Reglas de los prompts.md y la nota del lugar
en linajes/boveda/08 Lugares/. Mirá TODAS las imágenes de linajes/arte/referencias/gemini/<archivo>/:
tomá de ellas la distribución, las proporciones y el desgaste, nunca una copia.
Guardá kit-base.blend como linajes/arte/blender/interior-<archivo>.blend.

REGLAS DE INTERIORES
- Van dentro del mismo mapa (sin pantalla de carga): la puerta y las ventanas tienen que coincidir con la
  fachada del kit de Puerto Óxido (P21). Medí la fachada en linajes/arte/blender/puerto-oxido.blend.
- Puertas de 4 x 7 studs, portones de 12 x 10, techos de 16 (galpones) o 12 (locales), pasillos de 6
  studs mínimo (se pelea adentro). Grilla de 4 studs.
- Kit modular: pared, pared con ventana, pared con puerta, piso, techo, viga, escalera, baranda.
- Un material por malla, texturas: piso 1024 px, paredes 512, props 256. NUNCA 2048 (cuelga el horneado).
- Piezas de muchas partes chicas (tablero de herramientas, estantes llenos) y piezas de más de 30 studs
  (vigas, caños, techo): SIN bisel y SIN horneado, solo material.
- Si el horneado no avanza en 5 minutos, frenalo, avisame y bajá la resolución.
- Marcá con Parts vacíos: Spawn_Guardia, Spawn_Civil, Camara, Botin, Salida, PuntoNPC_<nombre>, Banco
  (donde se fabrica), Cama (donde se guarda).
- Topes: ≤ 60.000 triángulos por interior, ≤ 20.000 por malla.

INTERIOR: <pegá la fila de la tabla de abajo>

PASO 1 (boceto): bloques grises de toda la planta con las zonas y los Parts marcados. Renders: planta
desde arriba, vista desde la puerta y vista desde el fondo, con el maniquí de 5 studs. Chequeo de cruces
(BVH) y de cosas flotando: 0. Mandalo a la nota de Obsidian y esperá mi OK.
PASO 2 (detalle): NIVEL DE DETALLE de la guía: paredes con chapas superpuestas, remaches y costuras;
piso con losas, grietas y manchas; vigas con cartelas y bulones; muebles con cajones de verdad y
herramientas modeladas. Luz de la referencia (cálida adentro, fría desde la puerta). 4 renders con luz
+ 2 primeros planos + tabla de triángulos por malla. Chequeo de cruces: 0. Esperá mi OK.
PASO 3 (entrega): exportá FBX a linajes/arte/exports/interior-<archivo>/ con prefijos Neon_ y Glass_ y
mallas _Colision simples (cajas), el script en scripts/interiores/<archivo>.py, el .glb para Obsidian,
actualizá la nota del lugar y tildá el prompt en Todos los prompts. Commit y push.
```

### Tabla de interiores (una fila por sesión)
En la Beta: **taller**, **remache** y **almacen**.

| Archivo | Interior | Ciudad | Qué tiene adentro |
|---|---|---|---|
| banco | Banco Central Corona | Corona | Hall de mármol blanco con columnas y 6 ventanillas con vidrio, oficinas arriba, escalera a la bóveda subterránea, puerta de bóveda redonda de 8 studs con mecanismo (malla aparte que gira y se abre), bóveda con cajas de seguridad y pilas de lingotes, 6 cámaras, sala de seguridad con monitores |
| joyeria | Joyería Aurora | Corona | Local chico con 5 vitrinas de vidrio (rompibles: versión entera y rota), caja fuerte chica en la trastienda, alarma roja en la pared, 2 cámaras |
| museo | Museo de la Ciudad | Corona | Hall con esqueleto de criatura abisal, 3 salas (historia de la bahía, Hespérides, el eclipse) con vitrinas y piezas en pedestales con láser rojo, techo de vidrio por donde se entra en silencio |
| faro | Redacción de El Faro | Corona | Escritorios con computadoras, pared de pantallas con noticias (SurfaceGui), oficina de Lucía Vega, cuarto oscuro de fotos, terraza con el faro de luz |
| corona-lobby | Torre Corona Corp: lobby y laboratorio | Corona | Lobby blanco y dorado con molinetes y recepción, ascensor de vidrio, piso de laboratorio con cápsulas de implantes, oficina de Halden con ventanal (acceso por reputación) |
| hospital | Hospital Santa Lumen | Corona | Entrada con camillas, sala de espera, punto de reaparición con luz suave, consultorios |
| comisaria | Comisaría central | Vórtice | Mostrador con policía, tablero de recompensas (pared de corcho con carteles BUSCADO que cambian por código), 4 celdas con rejas, sala de pruebas, oficina de Rivas, escalera al techo con el reflector |
| gargola | Bar La Gárgola | Vórtice | Barra larga de madera oscura, boxes, rockola, TV con noticias, gárgola de piedra sobre la barra, escalera al sótano con ring de peleas clandestinas iluminado desde arriba |
| empeno | Casa de empeño | Vórtice | Mostrador con reja, estantes llenos de cosas viejas (guitarras, relojes, cámaras), caja fuerte, trastienda donde se vende botín |
| teatro | Teatro Ópalo (abandonado) | Vórtice | Sala de butacas rotas, escenario con telón rojo raído, palcos, camarines con máscaras colgadas, fosa de orquesta; luz de escenario fría |
| subte | Subte abandonado | Vórtice | Andén con azulejos rotos, vías, túneles en grilla de 8 studs con 3 bifurcaciones, campamento de pandilla con barriles de fuego, vagón descarrilado |
| mercado-negro | Mercado negro | Puerto | Bajo el mercado de pescado: entrada por cámara frigorífica, 6 puestos con lonas, puesto del Reducidor, mesa de implantes ilegales con luces neon-aviso |
| taller | Taller de Tano | Puerto | Galpón con elevador de autos, banco de trabajo con gadgets a medio armar, pared de herramientas, mesa de fabricación con pantalla |
| clinica | Clínica de la Dra. Kessler | Puerto | Quirófano clandestino con camilla, brazo robótico de cirugía, frascos con implantes, luz verde fría |
| albatros | Galpón del Albatros (interior) | Puerto | Oficina arriba con ventanal, tablero de golpes, mesa de cartas, cajas de contrabando, sala de guarida con sillones (baja la búsqueda) |
| aduana | Bodegas de aduana | Puerto | Depósito de techo alto con contenedores apilados, puente grúa interior, oficina de control, cámaras |
| refugio | Refugio del jugador (3 tipos) | Todas | Departamento de ladrillo (Vórtice), loft de vidrio (Corona), galpón chico (Puerto): perchero de trajes, cofre, mesa de taller chica, pared de trofeos, cama |
| estacion | Estación de subte | Todas | Andén limpio, molinetes, mapa de las líneas en la pared, escaleras a la calle |
| tienda | Tiendas chicas (kiosco, farmacia, ropa) | Todas | Kit de local de 12 x 16 studs: mostrador, caja registradora, estantes, heladera; 3 decoraciones distintas |
| penal | Penal Islaroca (interior) | Penal | Bloque de celdas de 2 pisos, patio con tareas (pesas, lavar), comedor, túnel de escape secreto tras una pared rompible |
| remache | Galpón de Remache | Puerto | Galpón rojo 60 x 40 x 20: arena central sin columnas, contenedores en los bordes (malla aparte cada uno: los tira en fase 2), 3 tanques de vidrio con líquido rojo Neon_, pasarela alta, lámpara grande que se balancea (malla aparte), jaula de Nico en una esquina |
| almacen | Almacén del muelle (atraco) | Puerto | 48 x 32: portón trasero con candado, garita del guardia, 2 cámaras, estanterías con cajas, oficina con caja fuerte chica, claraboya para entrar en silencio |

## 5. Reglas de Roblox que aplican
- Escala: 1 stud = 0,28 m; jugador de 5 studs; puertas de 4 x 7.
- Choque con mallas `_Colision` de cajas simples, nunca la malla de detalle.
- `Neon_` para lámparas y pantallas, `Glass_` para vidrios.
- Pivote en el piso, en la esquina sur-oeste del interior.
- Caras ocultas borradas (las que tocan el piso o la pared).
- Chequeo automático de cruces y de piezas flotando en 0 antes de cada OK.

## 6. Pasos y puntos de control
### Paso 1: Boceto de bloques
Planta completa en bloques grises con las zonas, los Parts marcados y el maniquí.

**Para dar el OK:**
- [ ] Se reconoce la distribución de la referencia 2 (planta).
- [ ] Pasillos de 6 studs o más y espacio para pelear.
- [ ] La puerta coincide con la fachada del puerto.
- [ ] Nada se cruza ni flota (chequeo en 0).

### Paso 2: Detalle
Nivel de detalle completo, horneado, 4 renders con luz y 2 primeros planos.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa (zonas, luz, desgaste), sin copiarlas.
- [ ] Topes: ≤ 20.000 triángulos por malla, ≤ 60.000 el interior.
- [ ] Ninguna textura de 2048.
- [ ] Chequeo de cruces en 0.
- [ ] Se lee bien de noche y en pantalla chica.

### Paso 3: Entrega
Exportar, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] Están los FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota del lugar tiene el modelo para girar y los renders.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX y texturas en `exports/interior-<archivo>/`.
- Renders en `arte/renders/` y `.glb` en la bóveda.
- Nota del lugar actualizada y prompt tildado.

**Cómo lo probás vos:**
- En Obsidian, girá el modelo 3D y mirá los renders.
- Cuando se importe (P21), caminá adentro en Studio: que la puerta coincida con la fachada.




## Un prompt por cosa
Cada uno está separado, con sus referencias de Gemini y su bloque para Claude. Este prompt queda con las **reglas comunes**.

- [[P25d-01 Taller de Tano]] (**Sí** (se rehace de cero))
- [[P25d-02 Galpón de Remache]] (**Sí**)
- [[P25d-03 Almacén del muelle]] (**Sí** (el atraco))
- [[P25d-04 Banco Central Corona]] (No)
- [[P25d-05 Joyería Aurora]] (No)
- [[P25d-06 Museo de la Ciudad]] (No)
- [[P25d-07 Redacción de El Faro]] (No)
- [[P25d-08 Torre Corona Corp, lobby y laboratorio]] (No)
- [[P25d-09 Hospital Santa Lumen]] (No)
- [[P25d-10 Comisaría central]] (No)
- [[P25d-11 Bar La Gárgola]] (No)
- [[P25d-12 Casa de empeño]] (No)
- [[P25d-13 Teatro Ópalo (abandonado)]] (No)
- [[P25d-14 Subte abandonado]] (No)
- [[P25d-15 Mercado negro]] (No)
- [[P25d-16 Clínica de la Dra. Kessler]] (No)
- [[P25d-17 Galpón del Albatros (interior)]] (No (el exterior está en el kit P21))
- [[P25d-18 Bodegas de aduana]] (No)
- [[P25d-19 Refugio del jugador (3 tipos)]] (No)
- [[P25d-20 Estación de subte]] (No)
- [[P25d-21 Tiendas chicas (kiosco, farmacia, ropa)]] (No)
- [[P25d-22 Penal Islaroca (interior)]] (No)

---
[[Todos los prompts]]   ·   [[P26 Animaciones base del jugador|P26 Animaciones base del jugador →]]
