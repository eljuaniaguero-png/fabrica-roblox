---
tags: [prompt, efectos]
beta: "**Sí**"
---
# P30-01 Pistones de Remache

> [!summary] En tres líneas
> Animación por código de **Pistones de Remache**.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
Animación por código de **Pistones de Remache**.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/objetos/`

## 2. Qué leer antes
- [[NPCs]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Cómo se mueve: Pistones de Remache** → guardar como `linajes/arte/referencias/gemini/objeto-pistonesderemache/ref-1.png`
```
Game motion concept: close-up of a huge hydraulic piston arm extending with a burst of steam at the moment of impact, three frames. Dark background, motion lines. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/objeto-pistonesderemache/. Código en linajes/src/client/objetos/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Con el marcador Impacto de su animación, el pistón (malla aparte) se estira 0,8 studs en 0,08 s y vuelve en 0,25 s.
- Vapor: ParticleEmitter de 12 partículas grises, 0,4 s.
- SONIDO: remache-piston (P31).

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
[[P30 Animaciones de objetos]]   ·   [[P30-02 Objetos para juntar|P30-02 Objetos para juntar →]]
