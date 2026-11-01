---
tags: [prompt, codigo]
beta: "Cuerpo propio completo + las piezas de la Beta (4 cascos, 4 capas, 4 petos), 3 colores por pieza, nombre de héroe y armado de habilidades Z/X/C. Emblema, estilos de pelea y base propia, en la Post beta."
---
# P36b Creador de personaje y personalización

> [!summary] En tres líneas
> El creador de personaje sobre el cuerpo propio (nunca el avatar de Roblox): cuerpo, cara, pelo, piezas de traje con colores, nombre y armado de habilidades.

> [!info] En la Beta
> Cuerpo propio completo + las piezas de la Beta (4 cascos, 4 capas, 4 petos), 3 colores por pieza, nombre de héroe y armado de habilidades Z/X/C. Emblema, estilos de pelea y base propia, en la Post beta.

## 1. Para qué es
Cada jugador se arma su héroe o villano. Es lo segundo que hace después de entrar.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/client/ui/Creador.luau`, `linajes/src/server/Personaje/`, piezas en `ReplicatedStorage.Piezas`.

## 2. Qué leer antes
- [[Cuerpo propio]] y [[Cuerpo propio (sin avatar de Roblox)]]
- [[Poderes, inicio y personalización]] (personalización)
- P20b (piezas exportadas)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Pantalla del creador** → guardar como `linajes/arte/referencias/gemini/creador/creador.png`
```
Character creator screen: a blocky stylized hero rotating on a pedestal in the center, left tabs (body, face, hair, helmet, cape, chest), a grid of piece thumbnails, right a color wheel plus 12 preset swatches for 3 color slots, name field at the top, confirm button. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Hoja de combinaciones de traje** → guardar como `linajes/arte/referencias/gemini/creador/combinaciones.png`
```
Six original blocky Roblox-proportioned superheroes and villains standing in a row, each built from simple swappable parts (helmet, cape, chest plate) in different color combinations, harbor-themed palette with neon accents, front view on grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
Usá las piezas de P20b (Beta: 4 cascos, 4 capas, 4 petos) y el cuerpo de P20f.
1. CUERPO: contextura, altura (3 tamaños), piel (tonos de la nota), cara (expresiones), pelo. NUNCA el
   avatar de Roblox: el personaje se arma con nuestras mallas al aparecer.
2. TRAJE: casco, capa, peto; 3 colores por pieza (rueda + 12 de la guía); vista que gira.
3. NOMBRE DE HÉROE: filtrado con TextService:FilterStringAsync.
4. ARMADO DE HABILIDADES: arrastrar a Z, X, C (V y B aparecen bloqueadas con "???").
El servidor valida que cada pieza exista y esté desbloqueada. Guardado por espacio (P34).
POST BETA (no hacer ahora): hombreras, guantes, botas, materiales, emblema de 20 formas, títulos,
estilos de pelea (Espada, Bastón, Armas no letales, Gadgets) y base propia.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Nombres filtrados con `TextService`.
- Nunca se usa el avatar de Roblox.

## 6. Pasos y puntos de control
### Paso 1: Creador
Armar 3 personajes distintos.

**Para dar el OK:**
- [ ] Se ven distintos de lejos.
- [ ] El nombre se filtra.
- [ ] Al volver a entrar, el personaje sigue igual.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Pantalla y módulos del creador.

**Cómo lo probás vos:**
- Creá un personaje, salí y volvé.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda). Las referencias a la ficha vieja ya están cambiadas por las notas de la bóveda.

```
Leé linajes/boveda/01 Juego/Poderes, inicio y personalización.md y las notas de linajes/boveda/06 Linajes/. Usá las piezas del Prompt 20b.
1. CREADOR (al crear un espacio y después en tu base): elegir casco, capa, peto, hombreras, guantes, botas
   sobre el cuerpo propio (P20f: contextura, altura, piel, cara, pelo; NUNCA el avatar de Roblox); 3 colores por pieza con selector libre (rueda de color + 12 colores de la guía);
   material por pieza (tela, cuero, metal, neon); largo de capa; vista girando.
2. EMBLEMA: 20 formas, color, borde y brillo; se ve en el peto, la capa y la bandera de la base.
3. NOMBRE DE HÉROE + TÍTULO (lista de títulos ganados).
4. ESTILO DE PELEA: Puños, Espada, Bastón, Armas no letales, Gadgets; cada uno cambia el combo de 4 golpes
   (daño en Config.luau: Puños rápido y bajo, Espada medio, Bastón con alcance, Armas a distancia,
   Gadgets con efectos). Cada estilo necesita su set de 4 animaciones (pedírselas al Prompt 26 con el
   mismo formato).
5. ARMADO DE HABILIDADES: pantalla con todas las habilidades abiertas; arrastrar a Z, X, C, V (y B si hay
   Técnica combinada). Guardado por espacio.
6. BASE PROPIA: elegir escondite (galpón, azotea, cueva), colocar 20 muebles y trofeos de jefes en una
   grilla, colgar trajes guardados. Privada por jugador (PersistentPerPlayer).
Guardar todo en el perfil. Commit y push.
```

---
[[P36 Ruleta Linaje, Variante y Rasgos|← P36 Ruleta Linaje, Variante y Rasgos]]   ·   [[Todos los prompts]]   ·   [[P37 Niveles, árbol y Despertar 1 con ramas|P37 Niveles, árbol y Despertar 1 con ramas →]]
