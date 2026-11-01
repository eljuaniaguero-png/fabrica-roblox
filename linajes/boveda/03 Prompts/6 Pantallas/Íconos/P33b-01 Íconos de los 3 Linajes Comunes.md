---
tags: [prompt, pantallas]
beta: "**Sí**"
---
# P33b-01 Íconos de los 3 Linajes Comunes

> [!summary] En tres líneas
> **Íconos de los 3 Linajes Comunes**, en una sola conversación de Gemini para que salgan con el mismo estilo.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
**Íconos de los 3 Linajes Comunes**, en una sola conversación de Gemini para que salgan con el mismo estilo.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/2d/iconos/`

## 2. Qué leer antes
- [[Linajes]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!tip] Pegá primero las **reglas** y esperá "ok". Después pedí cada ícono con su línea y guardalo con el nombre que dice al final.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Reglas (pegar primero, una vez)** → guardar como `linajes/arte/referencias/gemini/iconos/—`
```
You will draw a set of game icons for a dark comic-book superhero game on Roblox. Rules for EVERY icon: 1:1 square, 512x512, flat solid #00FF00 green background, one centered symbol, thick dark outline (#0e1016), bold simple shapes readable at 48 pixels on a phone, soft inner glow, no text, no letters, no existing logos, nothing from DC or Marvel. Reply "ok" and wait for my icon requests.
```

**Referencia 2: Un pedido por ícono (una línea cada uno)** → guardar como `linajes/arte/referencias/gemini/iconos/ver nombre al final de cada línea`
```
Icon: a cracked fist hitting the ground, main color #9aa3ad -> linaje-fuerza-bruta
Icon: an eye with three motion lines, main color #9aa3ad -> linaje-reflejos
Icon: a flame shaped like a hand, main color #9aa3ad -> linaje-piroquinesis
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/iconos/. Código en linajes/arte/2d/iconos/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Revisá cada ícono de linajes/arte/referencias/gemini/iconos/ con el nombre de la lista.
- Limpiá con limpiar_2d.py: fondo fuera sin halo, 6 % de margen, 256 y 128 px.
- Hoja de prueba a 48 px sobre #0e1016 y en gris (recarga).
- Con mi OK: linajes/arte/2d/iconos/, subilos por MCP, IDs en Config.luau (Iconos).

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- Mismo estilo: una conversación de Gemini.
- Nada de logos.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Se distinguen a 48 px.
- [ ] Mismo grosor de borde en todos.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P33b Íconos de Linajes y habilidades (Gemini)]]   ·   [[P33b-02 Íconos de habilidades de Fuerza Bruta|P33b-02 Íconos de habilidades de Fuerza Bruta →]]
