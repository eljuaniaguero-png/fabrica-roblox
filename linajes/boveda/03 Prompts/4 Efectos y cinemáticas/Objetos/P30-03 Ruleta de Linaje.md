---
tags: [prompt, efectos]
beta: "**Sí**"
---
# P30-03 Ruleta de Linaje

> [!summary] En tres líneas
> Animación por código de **Ruleta de Linaje**.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Animación por código de **Ruleta de Linaje**.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/objetos/`

## 2. Qué leer antes
- [[Linajes]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Cómo se mueve: Ruleta de Linaje** → guardar como `linajes/arte/referencias/gemini/objeto-ruletadelinaje/ref-1.png`
```
Game motion concept: a circular roulette wheel of superpowers with rarity-colored segments (grey, green, blue, orange, red), spinning fast, slowing, landing with a glow. Dark background, motion lines. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/objeto-ruletadelinaje/. Código en linajes/src/client/objetos/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- El resultado lo decide el SERVIDOR antes de girar.
- Giro de 4 s con EasingStyle.Quint Out que termina en el segmento del resultado.
- 2 rebotes chicos y destello del color de la rareza.
- SONIDO: ruleta-girando y resultado-<rareza> (P31).

PRUEBA: Play en compu y en el emulador de celular (844x390), consola sin rojo, captura. Mostrámela y
esperá mi OK. Commit en español y push.
```

## 5. Reglas de Roblox que aplican
- El servidor decide; el cliente solo muestra.
- Un solo bucle del cliente para lo que se mueve siempre, pausado si no se ve.
- Números en `Config.luau`.
- Probado: Play en compu y emulador de celular, consola sin rojo, captura.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Play y captura.

**Para dar el OK:**
- [ ] Se mueve como dice la lista.
- [ ] No baja los FPS en celular.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P30-02 Objetos para juntar|← P30-02 Objetos para juntar]]   ·   [[P30 Animaciones de objetos]]   ·   [[P30-04 Corona de Centinela Solar|P30-04 Corona de Centinela Solar →]]
