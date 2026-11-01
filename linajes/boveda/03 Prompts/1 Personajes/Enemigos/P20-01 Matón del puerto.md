---
tags: [prompt, personajes]
beta: "**Hecho** (registro)"
---
# P20-01 Matón del puerto

> [!summary] En tres líneas
> Modelo de **Matón del puerto** con 3 variantes de color. Tope 8.000 triángulos.

> [!info] En la Beta
> **Hecho** (registro)

## 1. Para qué es
Enemigo común. Campera de cuero, gorro de lana, pañuelo en la cara, cadena. Variantes: gorro rojo, verde, gris.

**Qué tener abierto:** Blender con el conector, Gemini y Obsidian.

**Dónde queda:** `linajes/arte/blender/enemigo-maton.blend`, exports en `linajes/arte/exports/enemigo-maton/`, nota en `04 Personajes/`.

## 2. Qué leer antes
- [[NPCs]] (enemigos comunes)
- [[Calle viva]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Vista general en pose de pelea** → guardar como `linajes/arte/referencias/gemini/enemigo-maton/ref-1.png`
```
Full-body concept of an original enemy for a stylized Roblox superhero brawler: a harbor street thug in a worn leather jacket, a wool beanie, a bandana over the face and a chain in hand. Aggressive fighting stance, foggy wet street at night. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Vistas ortográficas con 3 variantes** → guardar como `linajes/arte/referencias/gemini/enemigo-maton/ref-2.png`
```
Turnaround sheet of the same enemy (a harbor street thug in a worn leather jacket, a wool beanie, a bandana over the face and a chain in hand): front, side and back on grey background, plus three color variants side by side. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 3: Hoja de detalle** → guardar como `linajes/arte/referencias/gemini/enemigo-maton/ref-3.png`
```
Detail sheet with four close-ups pointed by arrows (no text) of the same enemy: head, weapon or signature piece, torso seams and wear, boots. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md. Mirá las imágenes de linajes/arte/referencias/gemini/enemigo-maton/.
Guardá kit-base.blend como linajes/arte/blender/enemigo-maton.blend.
ENEMIGO: Matón del puerto. DETALLES: Campera de cuero, gorro de lana, pañuelo en la cara, cadena. Variantes: gorro rojo, verde, gris. TOPE: 8000 tris total, ≤ 20.000 por malla.
Sobre el maniquí R15 (o rig propio si no es humano). 3 VARIANTES de color: solo cambian materiales.
Boceto → mi OK → detalle + 3 vistas de cada variante + 3 primeros planos → mi OK → exportar a
linajes/arte/exports/enemigo-maton/, script scripts/enemigos/maton.py, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- enemigo-maton (deja el .glb y
los renders junto a la nota) y actualizá la nota "Matón del puerto (modelo)" de la bóveda con el modelo 3D para girar
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
- [ ] Se distingue de los otros enemigos de lejos.

### Paso 2: Detalle
Nivel de detalle completo, texturas y renders con luz de noche.

**Para dar el OK:**
- [ ] Se parece a las referencias de Gemini en lo que importa, sin copiarlas.
- [ ] Topes de triángulos cumplidos.
- [ ] Ninguna textura de 2048.
- [ ] Las 3 variantes se distinguen.

### Paso 3: Entrega
FBX, nota de Obsidian, commit y push.

**Para dar el OK:**
- [ ] FBX con `Neon_`, `Glass_` y `_Colision`.
- [ ] La nota tiene el modelo para girar.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, FBX de las 3 variantes, renders y nota.

**Cómo lo probás vos:**
- Girá el modelo en Obsidian.

---
[[P20 Enemigos comunes]]   ·   [[P20-02 Matón con implantes|P20-02 Matón con implantes →]]
