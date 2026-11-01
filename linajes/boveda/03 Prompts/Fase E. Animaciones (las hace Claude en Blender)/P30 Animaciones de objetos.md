---
tags: [prompt, efectos]
beta: "Solo los **pistones de Remache**, los **objetos para juntar** y la **ruleta de Linaje**. Lo demás, en la Post beta."
---
# P30 Animaciones de objetos

> [!summary] En tres líneas
> Cosas que se mueven por código en Studio (no en Blender): pistones, objetos para juntar, ruleta. Un solo bucle en el cliente, pausado si no se ve.

> [!info] En la Beta
> Solo los **pistones de Remache**, los **objetos para juntar** y la **ruleta de Linaje**. Lo demás, en la Post beta.

## 1. Para qué es
Detalles que dan vida sin costo: los pistones de Remache con cada golpe, la chatarra que brilla para juntar, la ruleta que frena despacio.

**Qué tener abierto:** Roblox Studio con el place de Linajes y `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/objetos/` (un módulo por objeto), números en `Config.luau`.

## 2. Qué leer antes
- [[Linajes]] (la ruleta y los colores de rareza)
- [[Remache (modelo)]] (pistones aparte)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Ruleta de Linaje: cómo se ve girando** → guardar como `linajes/arte/referencias/gemini/objetos/ruleta.png`
```
Game UI concept: a circular roulette wheel for superpower lineages, segments colored by rarity (grey #9aa3ad common, green #4ed68a uncommon, blue #4fb3f2 rare, orange #f2a23a legendary, red #ff4d6d mythic) with simple icons, a pointer at the top, motion blur while spinning, dark eclipse background with a ring of fire. Three frames: spinning fast, slowing down, landing with a glow in the rarity color. No text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Objeto para juntar: chatarra con columna de luz** → guardar como `linajes/arte/referencias/gemini/objetos/juntar.png`
```
Game asset concept: a small pile of rusty scrap parts and a glowing chip floating 1 stud above a wet harbor street, slowly spinning, with a thin vertical beam of cyan light so it can be seen from far away. Three variants: scrap (orange light), chip (cyan light), rare part (gold light). Night, fog. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/boveda/06 Linajes/Linajes.md (ruleta y colores de rareza). Mirá las imágenes de
linajes/arte/referencias/gemini/objetos/.
Todo por código en linajes/src/client/objetos/, un módulo por tema, números en Config.luau.
Un solo bucle del cliente (RunService.RenderStepped) para lo que se mueve siempre, que salta los objetos
fuera de 150 studs o fuera de cámara.

1. PISTONES DE REMACHE: cuando llega el marcador Impacto de su animación, el pistón (malla aparte) se
   estira 0,8 studs en 0,08 s y vuelve en 0,25 s, con vapor (ParticleEmitter, 12 partículas).
2. OBJETOS PARA JUNTAR (tag "Recolectable", atributo Tipo = Chatarra / Chip / Rara): giran 1 vuelta cada
   3 s, suben y bajan 0,3 studs, columna de luz Neon del color del tipo (naranja #f2a23a, cian #3fe0f0,
   dorado #d9a441). Al juntar: se achican en 0,15 s y suena (SONIDO: en Config).
3. RULETA DE LINAJE: giro de 4 s que frena con EasingStyle.Quint Out, rebota 2 veces en el resultado y
   hace un destello del color de la rareza. El resultado lo decide el SERVIDOR antes de girar; el cliente
   solo anima hasta ese segmento.
Probá cada uno con Play (compu y emulador de celular). Consola sin rojo, captura de cada uno.
Commit y push.
```

## 5. Reglas de Roblox que aplican
- Lo que se mueve siempre: un solo bucle en el cliente, pausado si no se ve.
- El resultado de la ruleta lo decide el servidor.
- Los objetos se buscan por **tag**, nunca por nombre.

## 6. Pasos y puntos de control
### Paso 1: Hacer y probar
Los 3 objetos con Play y capturas.

**Para dar el OK:**
- [ ] Los pistones se mueven justo con el golpe.
- [ ] La chatarra se ve de lejos con niebla.
- [ ] La ruleta frena despacio y rebota.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos en `src/client/objetos/` y números en `Config.luau`.
- Capturas.

**Cómo lo probás vos:**
- En Play, juntá chatarra y tirá la ruleta.

---
[[P26b Animaciones de tecnología, gadgets y vehículos|← P26b Animaciones de tecnología, gadgets y vehículos]]   ·   [[Todos los prompts]]   ·   [[P30b Efectos especiales e interfaz|P30b Efectos especiales e interfaz →]]
