---
tags: [prompt, animaciones]
beta: "**Sí**"
---
# P28-01 Animaciones de Remache

> [!summary] En tres líneas
> Animaciones del jefe **Remache**: entrada, quieto, caminar, 3 ataques con Aviso e Impacto, cambio de fase, aturdido y derrota.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Los jefes avisan antes de pegar: el marcador Aviso pinta el piso de rojo 0,4 s antes del Impacto.

**Qué tener abierto:** Blender con el conector y Studio para el último paso.

**Dónde queda:** `linajes/arte/blender/remache.blend`, script `scripts/animaciones/remache.py`, FBX en `arte/animaciones/jefes/remache/`.

## 2. Qué leer antes
- [[Remache]]
- [[P28 Animaciones de un jefe]] (reglas comunes)
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de los 3 ataques** → guardar como `linajes/arte/referencias/gemini/anim-jefe-remache/ataques.png`
```
Boss animation key-pose sheet of a huge piston-armed former dockworker with a red-visor welding helmet: row 1 Martillazo doble: levanta los dos puños (Aviso), golpe al piso, círculo de 10 studs (Impacto 30); row 2 Carga hidráulica: los pistones se cargan, embiste 30 studs en línea recta; row 3 Contenedor: lo levanta (40 cuadros) y lo lanza a una zona marcada. Three poses per row (warning, impact, recovery), red warning areas on the floor, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Entrada, cambio de fase y derrota** → guardar como `linajes/arte/referencias/gemini/anim-jefe-remache/fases.png`
```
Key-pose sheet of the same boss (a huge piston-armed former dockworker with a red-visor welding helmet): dramatic entrance, phase change (Se inyecta el líquido rojo, más rápido, los pistones echan vapor), stunned, defeat. Comic-book exaggeration, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé la nota del jefe y P28 (reglas comunes). Mirá las imágenes de linajes/arte/referencias/gemini/anim-jefe-remache/.
Abrí linajes/arte/blender/remache.blend. 30 fps, marcador Impacto en cada golpe y Aviso 12 cuadros antes.
ANIMACIONES: entrada (90), quieto amenazante (loop 60), caminar pesado (loop 40), recibir golpe (20),
aturdido (loop 40), cambio de fase (60), derrota (90) y:
- ATAQUE 1: Martillazo doble: levanta los dos puños (Aviso), golpe al piso, círculo de 10 studs (Impacto 30)
- ATAQUE 2: Carga hidráulica: los pistones se cargan, embiste 30 studs en línea recta
- ATAQUE 3: Contenedor: lo levanta (40 cuadros) y lo lanza a una zona marcada
- CAMBIO DE FASE: Se inyecta el líquido rojo, más rápido, los pistones echan vapor
Script scripts/animaciones/remache.py. Tiras de 3 cuadros → mi OK → FBX → importar en Studio con el
modelo del jefe → decime qué publicar → IDs en Config.luau → commit y push.
```

## 5. Reglas de Roblox que aplican
- 30 fps; Aviso 12 cuadros antes de cada Impacto.
- El jefe usa su propio rig.
- Publicar lo hacés vos; IDs en `Config.luau`.

## 6. Pasos y puntos de control
### Paso 1: Hoja de tiras
Todas las animaciones del jefe.

**Para dar el OK:**
- [ ] Cada ataque se anuncia.
- [ ] Queda una ventana para pegarle.

### Paso 2: Publicar y probar
FBX, importar, IDs.

**Para dar el OK:**
- [ ] Aviso e Impacto llegan al código.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.blend`, script, FBX y hoja de tiras.

**Cómo lo probás vos:**
- En Studio, el jefe hace sus 3 ataques.

---
[[P28 Animaciones de un jefe]]   ·   [[P28-02 Animaciones de El Albatros|P28-02 Animaciones de El Albatros →]]
