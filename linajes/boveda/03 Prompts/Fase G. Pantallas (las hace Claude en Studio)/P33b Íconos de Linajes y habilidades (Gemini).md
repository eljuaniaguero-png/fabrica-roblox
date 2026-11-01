---
tags: [prompt, pantallas]
beta: "Los **3 Linajes Comunes**, sus **9 habilidades**, el **gancho** y las **monedas** (chatarra, chips, Fichas de Eclipse). Los demás, en la Post beta."
---
# P33b Íconos de Linajes y habilidades (Gemini)

> [!summary] En tres líneas
> Íconos de Linajes, habilidades, gadgets y monedas hechos con Gemini en una sola conversación (para que salgan con el mismo estilo) y limpiados por Claude.

> [!info] En la Beta
> Los **3 Linajes Comunes**, sus **9 habilidades**, el **gancho** y las **monedas** (chatarra, chips, Fichas de Eclipse). Los demás, en la Post beta.

## 1. Para qué es
Son los botones Z, X, C y G del HUD, la ruleta y el inventario. Tienen que leerse a 48 px en un celular.

**Qué tener abierto:** Gemini en el navegador (una sola conversación para todos). Claude Code para limpiar.

**Dónde queda:** Originales en `linajes/arte/referencias/gemini/iconos/`, limpios en `linajes/arte/2d/iconos/`, IDs en `Config.luau`.

## 2. Qué leer antes
- [[Linajes]] (colores de rareza)
- [[Fuerza Bruta]] · [[Reflejos]] · [[Piroquinesis]] (nombres de habilidades)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!tip] Primero pegá el **bloque de reglas** y esperá que Gemini diga "ok". Después pedí cada ícono con una línea: `Icon: <símbolo>, main color <hex>`. Guardá cada uno con el nombre del archivo de la tabla.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: REGLAS (se pega una sola vez)** → guardar como `linajes/arte/referencias/gemini/iconos/—`
```
You will draw a set of game icons for a dark comic-book superhero game on Roblox. Rules for EVERY icon: 1:1 square, 512x512, flat solid #00FF00 green background, one centered symbol, thick dark outline (#0e1016), bold simple shapes readable at 48 pixels on a phone, soft inner glow, no text, no letters, no existing logos or brands, nothing from DC or Marvel. Reply "ok" and wait for my icon requests.
```

**Referencia 2: LISTA de la Beta (una línea por ícono)** → guardar como `linajes/arte/referencias/gemini/iconos/ver tabla`
```
Icon: a cracked fist hitting the ground, main color #9aa3ad   -> linaje-fuerza-bruta
Icon: an eye with three motion lines, main color #9aa3ad   -> linaje-reflejos
Icon: a flame shaped like a hand, main color #9aa3ad   -> linaje-piroquinesis
Icon: a boot stomping a shockwave ring, main color #b07a4a   -> hab-pisoton
Icon: a shoulder charging with speed lines, main color #b07a4a   -> hab-embestida
Icon: two hands lifting a boulder overhead, main color #b07a4a   -> hab-levantar
Icon: three fists in a fast blur, main color #e8e6e0   -> hab-rafaga
Icon: a curved arrow bouncing back from a shield, main color #e8e6e0   -> hab-contraataque
Icon: a fading silhouette stepping sideways, main color #e8e6e0   -> hab-paso-sombra
Icon: a ball of fire, main color #f2652b   -> hab-bola-fuego
Icon: a low wall of flames, main color #f2652b   -> hab-muro-fuego
Icon: a radial fire burst, main color #f2652b   -> hab-explosion
Icon: a wrist grappling hook with cable, main color #3fe0f0   -> gadget-gancho
Icon: a pile of rusty bolts and gears, main color #f2a23a   -> moneda-chatarra
Icon: a glowing microchip, main color #3fe0f0   -> moneda-chip
Icon: a black coin with a burning eclipse ring, main color #f2652b   -> moneda-ficha-eclipse
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
En linajes/arte/referencias/gemini/iconos/ dejé los íconos de Gemini con el nombre de la lista.
1. Revisá cada uno (nada de DC, ni texto, ni logos). Decime cuáles pedir de nuevo.
2. Limpiá con linajes/arte/scripts/limpiar_2d.py: fondo #00FF00 fuera sin halo, recorte con 6 % de
   margen, 256x256 y 128x128.
3. Hoja de prueba: todos a 48 px sobre el fondo del HUD (#0e1016) y en gris (para ver la recarga).
Con mi OK: guardá en linajes/arte/2d/iconos/, subilos por MCP y anotá los IDs en Config.luau
(tabla Iconos). Commit y push.
```

## 5. Reglas de Roblox que aplican
- Mismo estilo en todos: una sola conversación de Gemini.
- Se leen a 48 px y en gris.
- Nada de logos ni símbolos de otros.

## 6. Pasos y puntos de control
### Paso 1: Generar y limpiar
16 íconos y hoja de prueba.

**Para dar el OK:**
- [ ] Se distinguen entre sí a 48 px.
- [ ] Mismo grosor de borde en todos.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- PNG en `arte/2d/iconos/`, IDs en `Config.luau`.

**Cómo lo probás vos:**
- Mirá la hoja de prueba a 48 px.

---
[[P33a Logo, ícono y miniaturas (Gemini)|← P33a Logo, ícono y miniaturas (Gemini)]]   ·   [[Todos los prompts]]   ·   [[P33c HUD y menús en Figma|P33c HUD y menús en Figma →]]
