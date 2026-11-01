---
tags: [prompt, pantallas]
beta: "Logo, ícono, **3 miniaturas** y los **4 emblemas de bando**."
---
# P33a Logo, ícono y miniaturas (Gemini)

> [!summary] En tres líneas
> Vos generás con Gemini el logo, el ícono, las miniaturas y los emblemas; Claude los limpia (fondo verde fuera, tamaños de Roblox) y los deja listos para subir.

> [!info] En la Beta
> Logo, ícono, **3 miniaturas** y los **4 emblemas de bando**.

## 1. Para qué es
Es lo primero que ve un jugador en Roblox: el ícono y las miniaturas deciden si entra. Tienen que leerse en un celular.

**Qué tener abierto:** Gemini en el navegador. Claude Code para limpiar.

**Dónde queda:** Originales en `linajes/arte/referencias/gemini/logo/`, limpios en `linajes/arte/2d/` (logo.png, icono-512.png, miniatura-1..3.png, emblema-<bando>.png).

## 2. Qué leer antes
- [[Guía de estilo]] y [[Colores]]
- [[Bandos]]
- [[Sobre DC]] (nada de logos ni símbolos de DC)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!tip] Acá Gemini **hace la imagen final** (no solo referencia), y después Claude la limpia. Pedí 4 versiones de cada una y quedate con la mejor. El fondo verde `#00FF00` es para que Claude lo saque fácil.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: LOGO del juego (16:9, fondo verde)** → guardar como `linajes/arte/referencias/gemini/logo/logo.png`
```
Game logo for a Roblox superhero RPG called "LINAJES DEL ECLIPSE". Dark comic-book style. The words "LINAJES DEL ECLIPSE" in bold condensed uppercase letters, metallic steel (#8a94a6) with a hot orange edge glow (#f2652b). Behind the text, a solar eclipse: a black disc with a thin burning ring of orange (#f2652b) and gold (#ffb347) light. Small cracks of light coming out of the letters. Clean vector look, strong silhouette that reads at small size on a phone. Flat solid #00FF00 green background, no other background elements. No existing superhero logos, no capes, no bats, no "S" shields. Wide format 16:9, high resolution.
```

**Referencia 2: ÍCONO del juego (1:1)** → guardar como `linajes/arte/referencias/gemini/logo/icono.png`
```
Square game icon for a Roblox superhero game, 1:1. Close-up of a mysterious masked hero in dark armor with glowing cyan (#3fe0f0) eye lights, looking at the viewer, a huge solar eclipse behind the head (black disc with orange #f2652b and gold #ffb347 ring). Foggy harbor with cranes and neon in the background, rain. Dramatic orange rim light. Comic-book shading, bold shapes, very readable at small size. Original character design, not resembling any DC or Marvel hero. No text.
```

**Referencia 3: MINIATURA 1: el jefe del puerto** → guardar como `linajes/arte/referencias/gemini/logo/miniatura-1.png`
```
Roblox game thumbnail, 16:9, dark comic-book style. Three blocky stylized heroes jumping toward a huge mechanical brute with hydraulic piston arms and a welding helmet with a red visor, at a rusty foggy harbor with cranes and stacked containers. Wet night, neon signs in cyan (#3fe0f0), a giant solar eclipse in the sky with an orange and gold burning ring. Detailed armor, strong contrast, action pose, motion lines, sparks. Original designs only, nothing from DC or Marvel. No text.
```

**Referencia 4: MINIATURA 2: la ruleta de poderes** → guardar como `linajes/arte/referencias/gemini/logo/miniatura-2.png`
```
Roblox game thumbnail, 16:9, dark comic-book style. A blocky stylized hero on a harbor rooftop at night spinning a glowing wheel of powers (fire, raw strength shockwave, speed afterimages) that float around their hands, solar eclipse with a burning ring in the sky, cyan neon below, rain. Original designs only. No text.
```

**Referencia 5: MINIATURA 3: la calle viva** → guardar como `linajes/arte/referencias/gemini/logo/miniatura-3.png`
```
Roblox game thumbnail, 16:9, dark comic-book style. A masked blocky villain running across a wet harbor street carrying a loot bag while police lights flash blue and red, a civilian filming with a phone, a hero landing in front of him with a grappling hook cable. Eclipse in the sky. Original designs only. No text.
```

**Referencia 6: EMBLEMAS de bando (uno por pedido)** → guardar como `linajes/arte/referencias/gemini/logo/emblema-<bando>.png`
```
Flat emblem icon for a faction in a superhero game, 1:1, on flat solid #00FF00 green background. [BANDO]. Simple bold vector shape, one main color plus dark outline (#0e1016), readable at 64 pixels. Original design, no existing logos. No text.
[BANDO] = Faction "Liga": a rising sun inside a shield, main color blue #2f6fdb
        | Faction "Cofradia": a crimson diamond cut by a dagger, main color #c2213a
        | Faction "Vigilantes": an open eye inside a crescent, main color violet #6b5ba8
        | Faction "Neutral": two crossed keys inside a circle, main color grey #b8bcc6
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md. En linajes/arte/referencias/gemini/logo/ dejé las imágenes que
elegí de Gemini (logo, icono, miniatura-1..3, emblema-liga/cofradia/vigilantes/neutral).
1. Revisá cada una: que no tenga nada de DC ni de otro juego, ni texto raro (el logo sí lleva el
   nombre: revisá que diga exactamente LINAJES DEL ECLIPSE). Si algo falla, decime cuál pedir de nuevo.
2. Limpiá con Python (Pillow): sacá el fondo #00FF00 con borde suave (sin halo verde), recortá al
   contenido con 4 % de margen.
3. Tamaños de Roblox: logo 1920x1080 (transparente), icono 512x512 (sin transparencia, esquinas
   rectas: Roblox las redondea), miniaturas 1920x1080, emblemas 256x256 y 64x64.
4. Mostrame una hoja con todo, al lado de cómo se ve el ícono a 64 px y una miniatura a 320 px.
Con mi OK: guardá en linajes/arte/2d/, script en linajes/arte/scripts/limpiar_2d.py. El ícono y las
miniaturas los subís vos en Creator Hub (te digo dónde); los emblemas se suben por MCP y van a
Config.luau. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Ícono 512x512 sin texto chico; miniaturas 1920x1080.
- Nada de logos, símbolos ni personajes de DC o Marvel.
- Subir el ícono y las miniaturas al juego lo hacés **vos** en Creator Hub.

## 6. Pasos y puntos de control
### Paso 1: Elegir en Gemini
4 versiones de cada una, elegís la mejor.

**Para dar el OK:**
- [ ] El logo dice LINAJES DEL ECLIPSE sin errores.
- [ ] El ícono se entiende a 64 px.

### Paso 2: Limpiar
Hoja con todo limpio.

**Para dar el OK:**
- [ ] Sin halo verde.
- [ ] Tamaños correctos.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- PNG limpios en `arte/2d/` y el script.

**Cómo lo probás vos:**
- Mirá la hoja: el ícono chiquito tiene que seguir leyéndose.

---
[[P30c Cinemáticas|← P30c Cinemáticas]]   ·   [[Todos los prompts]]   ·   [[P33b Íconos de Linajes y habilidades (Gemini)|P33b Íconos de Linajes y habilidades (Gemini) →]]
