---
tags: [prompt, lugares]
beta: "No"
---
# P25d-13 Teatro Ópalo (abandonado)

> [!summary] En tres líneas
> Interior de **Teatro Ópalo (abandonado)** (Vórtice), Sala 48 x 40 x 28. Se entra caminando, sin pantalla de carga. Primero 3 referencias de Gemini, después boceto, detalle y entrega.

> [!info] En la Beta
> No

## 1. Para qué es
Arma por dentro Teatro Ópalo (abandonado). Luz luz de escenario fría y polvo.

**Qué tener abierto:** Blender con el conector de Claude, Gemini en el navegador y Obsidian.

**Dónde queda:** `linajes/arte/blender/interior-teatro.blend`, script `linajes/arte/scripts/interiores/teatro.py`, exports en `linajes/arte/exports/interior-teatro/`, nota en [[Ciudad Vórtice]].

## 2. Qué leer antes
- [[Ciudad Vórtice]]
- [[Calle viva]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Vista general desde la puerta** → guardar como `linajes/arte/referencias/gemini/interior-teatro/ref-1.png`
```
Interior of an abandoned ornate theater at night: rows of broken red velvet seats, a stage with a torn red curtain, gilded balconies with peeling paint, dressing rooms with original theatrical masks hanging (not clown masks), an orchestra pit, a cold white stage spotlight cutting through dust. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Planta desde arriba con las zonas** → guardar como `linajes/arte/referencias/gemini/interior-teatro/ref-2.png`
```
Top-down orthographic floor plan of this interior (Sala 48 x 40 x 28), clean game-design blockout look: entrance south, seating center, stage north, balconies on east and west, dressing rooms behind the stage, orchestra pit. Clear 6-stud walking lanes, each zone tinted a different muted color, 4-stud grid lines, simple icons, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 3: Hoja de detalle de materiales y piezas** → guardar como `linajes/arte/referencias/gemini/interior-teatro/ref-3.png`
```
Game asset detail sheet on a dark blueprint background with four close-ups pointed by arrows (no text) of the four most important pieces of this interior (walls, floor, the main furniture and the signature object), taken from this description: Interior of an abandoned ornate theater at night: rows of broken red velvet seats, a stage with a torn red curtain, gilded balconies with peeling paint, dressing rooms with original theatrical masks hanging (not clown masks), an orchestra pit, a cold white stage spotlight cutting through dust. Show seams, rivets, bevels, wear and grime. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, linajes/boveda/02 Estilo/Reglas de los prompts.md y la nota
"Ciudad Vórtice" de la bóveda. Mirá las 3 imágenes de linajes/arte/referencias/gemini/interior-teatro/
(ref-1 vista general, ref-2 planta, ref-3 materiales): tomá la distribución, las proporciones y el
desgaste, nunca una copia. Guardá kit-base.blend como linajes/arte/blender/interior-teatro.blend.

INTERIOR: Teatro Ópalo (abandonado) (Vórtice). MEDIDAS: Sala 48 x 40 x 28. LUZ: luz de escenario fría y polvo.
PIEZAS (para cada una decidí y anotá en el script: medidas en studs, material de la guía, color en hex
y tope de triángulos):
- Sala de butacas rotas
- Escenario con telón rojo raído
- Palcos
- Camarines con máscaras colgadas
- Fosa de orquesta

REGLAS DE ESTE INTERIOR
- Va dentro del mapa, sin pantalla de carga: la puerta y las ventanas tienen que coincidir con la fachada del kit de Ciudad Vórtice (P22-01); si todavía no existe, dejá la fachada como pieza aparte con las medidas anotadas.
- Puertas de 4 x 7 studs, portones de 12 x 10, pasillos de 6 studs mínimo (se pelea adentro), grilla
  de 4 studs. Kit propio de este interior: pared, pared con ventana, pared con puerta, piso, techo, viga,
  escalera y baranda, todo con el mismo material para que encaje.
- Un material por malla. Texturas: piso 1024 px, paredes 512, props 256. NUNCA 2048 (cuelga el horneado).
- Sin bisel y sin horneado (solo material): estantes llenos, tableros con muchas piezas chicas y toda pieza de más de 30 studs (vigas, caños, techo).
- Si el horneado no avanza en 5 minutos, frenalo, avisame y bajá la resolución.
- Parts vacíos (anclados, invisibles, sin choque) para el código: Spawn_Guardia x6 (Máscaras Rotas), PuntoNPC_Mascarada (escenario), Salida.
- Topes: ≤ 60.000 triángulos todo el interior, ≤ 20.000 por malla.

PASO 1: boceto de bloques + planta desde arriba + vista desde la puerta + vista desde el fondo, con el
maniquí. Chequeo de cruces y flotantes en 0. Esperá mi OK.
PASO 2: detalle completo (chapas, remaches, grietas, desgaste; muebles con cajones de verdad), 4 renders
con luz, 2 primeros planos, tabla de triángulos. Si el horneado no avanza en 5 min, frenalo y avisame.
Esperá mi OK.
PASO 3: FBX en linajes/arte/exports/interior-teatro/ (Neon_, Glass_, _Colision), script en
scripts/interiores/teatro.py, nota actualizada, prompt tildado. Commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- interior-teatro (deja el .glb y
los renders junto a la nota) y actualizá la nota "Ciudad Vórtice" de la bóveda con el modelo 3D para girar
(bloque ```3D), los renders, la tabla de triángulos y el estado. Abrí la nota con el conector de
Obsidian y avisame que la mire ahí.
```

## 5. Reglas de Roblox que aplican
- Escala: 1 stud = 0,28 m; jugador de 5 studs; puertas de 4 x 7.
- Choque con mallas `_Colision` simples (cajas), nunca la malla de detalle.
- `Neon_` para lo que brilla, `Glass_` para vidrios; un material por malla; ≤ 20.000 triángulos por malla.
- Texturas: piso 1024, paredes 512, props 256; **nunca 2048**. Piezas de muchas partes chicas o de más de 30 studs: sin bisel ni horneado.
- Pivote en la base; caras ocultas borradas; chequeo de cruces y de cosas flotando en 0 antes de cada OK.
- Nada de logos, trajes, colores exactos ni nombres de DC; las imágenes de Gemini son solo referencia.

## 6. Pasos y puntos de control
### Paso 1: Boceto de bloques
Bloques grises sin detalle, renders con el maniquí de 5 studs.

**Para dar el OK:**
- [ ] La silueta y las medidas se leen a la distancia de juego.
- [ ] Nada se cruza ni flota (chequeo en 0).
- [ ] La puerta coincide con la fachada de su ciudad.
- [ ] Pasillos de 6 studs o más.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Se lee bien de noche y en celular.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script y FBX de Teatro Ópalo (abandonado).
- Renders y nota actualizada.

**Cómo lo probás vos:**
- Girá el modelo en Obsidian.
- Cuando se importe, caminá adentro en Studio.

---
[[P25d-12 Casa de empeño|← P25d-12 Casa de empeño]]   ·   [[P25d Interiores donde se puede entrar]]   ·   [[P25d-14 Subte abandonado|P25d-14 Subte abandonado →]]
