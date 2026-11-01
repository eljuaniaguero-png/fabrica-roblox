---
tags: [prompt, pantallas]
beta: "**Sí**"
---
# P33a-01 Logo del juego

> [!summary] En tres líneas
> **Logo del juego**: lo generás vos en Gemini y Claude lo limpia.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
**Logo del juego**: lo generás vos en Gemini y Claude lo limpia.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/arte/2d/`

## 2. Qué leer antes
- [[Guía de estilo]]
- [[Sobre DC]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!tip] Acá Gemini hace la **imagen final**. Pedí 4 versiones y quedate con la mejor.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Logo del juego (imagen final, 4 versiones)** → guardar como `linajes/arte/referencias/gemini/logo/logo.png`
```
Game logo for a Roblox superhero RPG called "LINAJES DEL ECLIPSE". Dark comic-book style. Bold condensed uppercase letters, metallic steel (#8a94a6) with a hot orange edge glow (#f2652b). Behind the text a solar eclipse: black disc with a thin burning ring of orange (#f2652b) and gold (#ffb347). Small cracks of light coming out of the letters. Clean vector look that reads at small size on a phone. Wide 16:9, high resolution, no capes, no bats, no shields. Flat solid #00FF00 green background. Original design, no existing logos, nothing from DC or Marvel.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/logo/. Código en linajes/arte/2d/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Revisá linajes/arte/referencias/gemini/logo/logo.png: nada de DC, de otro juego ni texto raro. Si falla, decime que lo pida de nuevo.
- Sacá el fondo #00FF00 con borde suave (sin halo) con linajes/arte/scripts/limpiar_2d.py (Pillow) y recortá con 4 % de margen.
- Tamaño: 1920x1080 transparente; revisá que diga exactamente LINAJES DEL ECLIPSE.
- Guardá en linajes/arte/2d/logo.png. Mostrame cómo se ve a tamaño real de Roblox.
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
[[P33a Logo, ícono y miniaturas (Gemini)]]   ·   [[P33a-02 Ícono del juego|P33a-02 Ícono del juego →]]
