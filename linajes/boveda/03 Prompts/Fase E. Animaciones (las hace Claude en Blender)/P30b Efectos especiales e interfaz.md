---
tags: [prompt, efectos]
beta: "Efectos **generales**, los de **Fuerza Bruta, Reflejos y Piroquinesis**, cara e interfaz. Los Linajes nuevos, en la Post beta (punto 2 para cada uno)."
---
# P30b Efectos especiales e interfaz

> [!summary] En tres líneas
> Todos los efectos por código: golpes, hit-stop, sacudidas, zona roja de aviso, efectos de los 3 Linajes Comunes, expresiones de la cara y animaciones de la interfaz.

> [!info] En la Beta
> Efectos **generales**, los de **Fuerza Bruta, Reflejos y Piroquinesis**, cara e interfaz. Los Linajes nuevos, en la Post beta (punto 2 para cada uno).

## 1. Para qué es
Es lo que hace que pegar se sienta bien (game feel). Se disparan desde los marcadores de las animaciones.

**Qué tener abierto:** Roblox Studio con `rojo serve linajes/linajes.project.json`.

**Dónde queda:** `linajes/src/client/efectos/` (un módulo por tema), plantillas en `ReplicatedStorage.Efectos`, números en `Config.luau`.

## 2. Qué leer antes
- [[Animaciones (plan completo)]] secciones 2, 3, 4, 13 y 14
- [[Fuerza Bruta]] · [[Reflejos]] · [[Piroquinesis]] (colores y cómo se ven)
- [[Riesgos y mejoras (revisión 31 oct)]] (hit-stop)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Hoja de efectos de impacto** → guardar como `linajes/arte/referencias/gemini/efectos/impactos.png`
```
VFX concept sheet for a stylized Roblox superhero brawler at night: light hit spark (white star), critical hit (bigger star with red ring), blocked hit (cyan hexagon shield flash), parry (sharp white ring), red danger zone on the floor that fills before a boss attack, level-up column of light, dust puff, water splash in a puddle, steam burst, small and big explosion, shattered glass. Simple bold shapes, comic-book style, dark background. No text. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Efectos de los 3 Linajes Comunes** → guardar como `linajes/arte/referencias/gemini/efectos/linajes.png`
```
VFX concept sheet with three columns: brute strength (cracked ground shockwave ring, flying rocks, dust, brown and grey), reflexes (white afterimages, speed lines, a blur dash trail), pyrokinesis (fireball with orange #f2652b core and yellow edge, low wall of flame, radial fire burst). Bold stylized shapes readable on a phone screen, dark wet street background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las secciones 2, 3, 4 (columna Efecto), 13 y 14 de Animaciones (plan completo) y las notas de
Fuerza Bruta, Reflejos y Piroquinesis. Mirá las imágenes de linajes/arte/referencias/gemini/efectos/.
Todo por código en linajes/src/client/efectos/ (un módulo por tema), plantillas de partículas en
ReplicatedStorage.Efectos y números en Config.luau. Un solo bucle del cliente para lo que se mueve
siempre, pausado si no se ve.

1. GENERALES: golpe, crítico, bloqueo, parry, hit-stop de 0,05 s (0,08 en el 4.º golpe), sacudida de
   cámara en 3 fuerzas (0,2 / 0,5 / 1 stud), zona roja de Aviso (se llena en 0,4 s), curarse, subir de
   nivel, aparecer, polvo, charcos, vapor, humo, explosión chica y grande, vidrios. Se disparan desde los
   marcadores Impacto y Aviso.
2. LOS 3 LINAJES COMUNES, un efecto por habilidad (Pisotón, Embestida, Levantar y tirar; Ráfaga,
   Contraataque, Paso sombra; Bola de fuego, Muro de fuego, Explosión), con los colores de su nota.
3. CARA: expresiones (normal, enojado, dolor, contento), parpadeo al azar cada 2-6 s, boca al hablar.
4. INTERFAZ: botones que se achican al tocar, ventanas que entran con rebote, barras con rastro blanco,
   recargas en círculo, números de daño que saltan, subir de nivel, "???" que se revela, máquina de
   escribir para diálogos.
5. CALIDAD: Ajustes con Alto/Bajo; en celular arranca en Bajo (mitad de partículas, sin luces).
Probá cada efecto con Play en compu y en el emulador de celular. Consola sin rojo. Captura de cada
grupo, mostrámelas y esperá mi OK. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Partículas: máximo 50 por efecto en Alto, 25 en Bajo.
- Nada de luces con sombra en efectos.
- El daño lo decide el servidor; el efecto es solo visual.

## 6. Pasos y puntos de control
### Paso 1: Capturas por grupo
Los 5 grupos con Play.

**Para dar el OK:**
- [ ] Pegar se siente fuerte (hit-stop y sacudida).
- [ ] La zona roja avisa con tiempo.
- [ ] Los 3 Linajes se distinguen por color y forma.
- [ ] En celular se ve fluido.

### Paso 2: Entrega
Commit y push.

**Para dar el OK:**
- [ ] Consola sin rojo.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos en `src/client/efectos/`, plantillas, números en `Config.luau`.
- Capturas.

**Cómo lo probás vos:**
- En Play, pegale a un matón con cada Linaje y mirá los efectos.

---
[[P30 Animaciones de objetos|← P30 Animaciones de objetos]]   ·   [[Todos los prompts]]   ·   [[P31 Sonidos de combate y menús|P31 Sonidos de combate y menús →]]
