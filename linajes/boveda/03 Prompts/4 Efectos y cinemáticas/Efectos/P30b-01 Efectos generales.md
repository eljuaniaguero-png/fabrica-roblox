---
tags: [prompt, efectos]
beta: "**Sí**"
---
# P30b-01 Efectos generales

> [!summary] En tres líneas
> **Efectos generales** por código, disparados desde los marcadores de las animaciones.

> [!info] En la Beta
> **Sí**

## 1. Para qué es
**Efectos generales** por código, disparados desde los marcadores de las animaciones.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/efectos/`

## 2. Qué leer antes
- [[Combate y progresión]]
- [[Animaciones (plan completo)]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de efectos: Efectos generales** → guardar como `linajes/arte/referencias/gemini/efecto-efectosgenerales/ref-1.png`
```
VFX concept sheet for a stylized Roblox superhero brawler at night: impact star, critical hit, cyan hexagon block flash, white parry ring, red danger zone filling on the floor, level-up light column, dust, splash, steam, small and big explosion, shattered glass. Bold simple shapes readable on a phone, dark background, no text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de "Qué leer antes". Mirá las
imágenes de linajes/arte/referencias/gemini/efecto-efectosgenerales/. Código en linajes/src/client/efectos/ (--!strict),
números en linajes/src/shared/Config.luau, stylua y selene sin errores.

- Golpe, crítico, bloqueo, parry: desde el marcador Impacto.
- Hit-stop 0,05 s (0,08 en el 4.º golpe), solo visual.
- Sacudida de cámara en 3 fuerzas: 0,2 / 0,5 / 1 stud.
- Zona roja de Aviso que se llena en 0,4 s.
- Curarse, subir de nivel, aparecer, polvo, charcos, vapor, humo, explosión chica y grande, vidrios.
- Máximo 50 partículas por efecto en Alto, 25 en Bajo.

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
- [ ] Pegar se siente fuerte.
- [ ] Fluido en celular.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Código y números en `Config.luau`.
- Captura.

**Cómo lo probás vos:**
- En Play, mirá que funcione como dice la lista.

---
[[P30b Efectos especiales e interfaz]]   ·   [[P30b-02 Efectos de Fuerza Bruta|P30b-02 Efectos de Fuerza Bruta →]]
