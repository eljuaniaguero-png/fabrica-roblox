---
tags: [prompt, pantallas]
beta: "**Sí**"
---
# P33a-03 Miniatura 1 - el jefe del puerto

> [!summary] En tres líneas
> **Miniatura 1: el jefe del puerto**: lo generás vos en Gemini y Claude lo limpia.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
**Miniatura 1: el jefe del puerto**: lo generás vos en Gemini y Claude lo limpia.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/2d/`

## 2. Qué leer antes
- [[Guía de estilo]]
- [[Sobre DC]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!tip] Acá Gemini hace la **imagen final**. Pedí 4 versiones y quedate con la mejor.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Miniatura 1: el jefe del puerto (imagen final, 4 versiones)** → guardar como `linajes/arte/referencias/gemini/logo/miniatura-1.png`
```
Roblox thumbnail 16:9, dark comic-book style: three blocky heroes jumping toward a huge brute with hydraulic piston arms and a red-visor welding helmet at a rusty foggy harbor with cranes and containers, giant solar eclipse in the sky, cyan neon, sparks, motion lines. Original designs only. No text.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/logo/. Código en linajes/arte/2d/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Revisá linajes/arte/referencias/gemini/logo/miniatura-1.png: nada de DC, de otro juego ni texto raro. Si falla, decime que lo pida de nuevo.
- Sacá el fondo #00FF00 con borde suave (sin halo) con linajes/arte/scripts/limpiar_2d.py (Pillow) y recortá con 4 % de margen.
- Tamaño: 1920x1080.
- Guardá en linajes/arte/2d/miniatura-1.png. Mostrame cómo se ve a tamaño real de Roblox.
- Ícono y miniaturas los subís vos en Creator Hub (te digo dónde); emblemas por MCP con su ID en Config.luau.

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- Nada de logos ni símbolos de DC o Marvel.
- Subir el ícono y las miniaturas lo hacés vos.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Se lee en chico.
- [ ] Sin halo verde.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P33a-02 Ícono del juego|← P33a-02 Ícono del juego]]   ·   [[P33a Logo, ícono y miniaturas (Gemini)]]   ·   [[P33a-04 Miniatura 2 - la ruleta de poderes|P33a-04 Miniatura 2 - la ruleta de poderes →]]
