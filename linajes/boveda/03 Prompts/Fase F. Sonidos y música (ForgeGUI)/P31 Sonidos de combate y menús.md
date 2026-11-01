---
tags: [prompt, sonido]
beta: "Todos los de la lista (combate, los 3 Linajes Comunes y menús). Los Linajes nuevos, en la Post beta."
---
# P31 Sonidos de combate y menús

> [!summary] En tres líneas
> Efectos de sonido con ForgeGUI: golpes, bloqueo, parry, dash, aviso del jefe, las 9 habilidades de los 3 Linajes Comunes y los sonidos de menús y ruleta.

> [!info] En la Beta
> Todos los de la lista (combate, los 3 Linajes Comunes y menús). Los Linajes nuevos, en la Post beta.

## 1. Para qué es
El sonido es la mitad del game feel: cada golpe tiene que sonar distinto y con peso. Los de la ruleta crecen según la rareza.

**Qué tener abierto:** Claude Code con el conector de ForgeGUI. Studio con `rojo serve` para el último paso.

**Dónde queda:** `linajes/arte/sonidos/<nombre>.ogg`, lista en `linajes/arte/sonidos/LISTA.md`, IDs en `Config.luau` (tabla Sonidos).

## 2. Qué leer antes
- [[Combate y progresión]]
- [[Fuerza Bruta]] · [[Reflejos]] · [[Piroquinesis]] (sección Cómo se ve y se oye)
- [[Linajes]] (rarezas)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
> [!note] Para sonidos, Gemini se usa para **describir** el sonido de referencia (Gemini no genera audio). Pegá el prompt, copiá la descripción que te dé en `linajes/arte/referencias/gemini/sonidos/` y Claude la usa para pedirle a ForgeGUI.

Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Guía de sonido del combate** → guardar como `linajes/arte/referencias/gemini/sonidos/combate.md`
```
You are a sound designer for an original dark comic-book superhero brawler on Roblox. For each of these sounds write 2 lines: what it is made of (layers, materials, pitch) and how long each layer lasts, so a sound generator can recreate it. Never reference existing films, games or DC/Marvel. Sounds: punch 1, punch 2, punch 3 (each distinct), spinning kick, block, parry (metallic clank with sparkle), dash whoosh, taking a hit, stunned buzz, defeat body fall, boss warning alarm that rises in 0.4 s.
```

**Referencia 2: Guía de sonido de los 3 Linajes y la ruleta** → guardar como `linajes/arte/referencias/gemini/sonidos/linajes.md`
```
You are a sound designer for an original superhero game. Describe in 2 lines each (layers, pitch, length): brute strength stomp with ground tremor, shoulder charge, lift-and-throw; reflexes three-hit flurry, counter kick, shadow step; pyrokinesis fireball cast and impact, fire wall, fire burst. Then 6 reveal stingers for a power roulette, one per rarity (common, uncommon, rare, epic, legendary, mythic), each more epic than the last, 1 to 3 seconds. No references to existing media.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé las guías de linajes/arte/referencias/gemini/sonidos/ (combate.md y linajes.md).
Con ForgeGUI generá estos efectos. Estilo: superhéroe de cómic, golpes con cuerpo y un toque metálico,
nada caricaturesco. Nada que imite sonidos de DC ni de películas.
Guardá cada uno en linajes/arte/sonidos/<nombre>.ogg y anotalo en linajes/arte/sonidos/LISTA.md
(nombre, duración, descripción, para qué es).

COMBATE: golpe-1, golpe-2, golpe-3 (0,3 s, puños secos con eco corto, distintos entre sí),
golpe-4-patada (0,5 s, más grave con barrido), bloqueo (0,3 s, apagado), parry (0,4 s, clank metálico
agudo con brillo), dash (0,3 s, whoosh), recibir-golpe (0,3 s), aturdido (1 s, zumbido), derrota
(1,2 s, caída pesada), aviso-jefe (0,4 s, alarma grave que crece), remache-pistón (0,5 s, hidráulico).
LINAJES (carga 0,3-0,8 s + impacto 0,4-1,2 s): Fuerza Bruta (pisotón con temblor, embestida,
lanzamiento), Reflejos (ráfaga de 3, contraataque, paso sombra), Piroquinesis (bola de fuego, muro,
explosión).
MENÚS: boton (0,1 s), abrir-menu (0,3), cerrar-menu (0,2), ruleta-girando (loop 2 s, clicks que se
frenan), resultado-comun, -poco-comun, -raro, -legendario, -mitico (1 a 3 s, cada uno más épico),
subir-nivel (1,5), punto-habilidad (0,6), dialogo-npc (0,2, blip suave), mision-completa (1,5),
recoger-objeto (0,3), fabricar (1 s, martillazos y chispa).
Después subilos a Roblox (decime qué tengo que tocar) y anotá los IDs en Config.luau (tabla Sonidos).
Probá con Play que cada uno suene en su momento. Commit y push.
```

## 5. Reglas de Roblox que aplican
- Nada de música ni sonidos con derechos de autor ni que imiten a DC o a películas.
- Cada punto de sonido en el código lleva un comentario `-- SONIDO:` y su ID en `Config.luau` (tabla Sonidos), para cambiarlo después.
- Subir audio a Roblox puede necesitar tu cuenta: Claude te dice exactamente qué tocar.
- Formato `.ogg`, mono para efectos, estéreo para música; efectos ≤ 3 s, loops sin corte.

## 6. Pasos y puntos de control
### Paso 1: Generar y escuchar
Todos los sonidos en `LISTA.md`.

**Para dar el OK:**
- [ ] Los 4 golpes del combo suenan distintos.
- [ ] El parry se distingue del bloqueo.
- [ ] La ruleta crece con la rareza.

### Paso 2: Subir y probar
IDs en Config y prueba con Play.

**Para dar el OK:**
- [ ] Cada sonido suena en su momento.
- [ ] Nada se escucha cortado.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- `.ogg` en `arte/sonidos/`, `LISTA.md`, IDs en `Config.luau`.

**Cómo lo probás vos:**
- Escuchá los archivos de `arte/sonidos/`.
- En Play, pegá un combo y tirá la ruleta.

---
[[P30b Efectos especiales e interfaz|← P30b Efectos especiales e interfaz]]   ·   [[Todos los prompts]]   ·   [[P32 Ambientes y música|P32 Ambientes y música →]]
