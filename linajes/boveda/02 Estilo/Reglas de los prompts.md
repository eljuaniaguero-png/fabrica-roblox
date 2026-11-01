---
tags: [estilo, prompts]
---
# Reglas de los prompts

Todos los prompts siguen la [[Plantilla de prompt]]. Estas reglas valen para **todos** y cada prompt copia adentro las que le tocan, para que no se pierdan.

## Dónde y cómo
- Todos se pegan en 💻 **Claude Code en tu PC** (`C:\Users\eljua\fabrica-roblox`).
- Modelos y animaciones: **Blender** abierto con el conector de Claude. Claude trabaja con scripts en `linajes/arte/scripts/`, así todo se puede rehacer cambiando números.
- Importar y código: **Roblox Studio** abierto y `rojo serve linajes/linajes.project.json` corriendo (uno solo a la vez).
- **Un prompt por sesión.** Si el prompt dice "esperá mi OK", Claude se frena ahí. Vos revisás la lista **Para dar el OK** del prompt antes de contestar.
- Antes de cada prompt de arte: **las imágenes de Gemini** (mínimo 2) del propio prompt, guardadas en `linajes/arte/referencias/gemini/<archivo>/`. Son solo referencia.

## Escala y medidas
- 1 stud = 0,28 m en Blender. Un jugador mide **5 studs** de alto y 3 de ancho.
- Pivote **abajo y al centro** (z = 0) en cada pieza. Frente hacia -Y en Blender (queda -Z en Roblox).
- Puertas de **5 x 7** como mínimo; pasillos y callejones de **6** de ancho libre y 7 de alto; portones de autos de **10 a 12** de ancho y 8 a 10 de alto; autos de **6** de ancho o más.
- Interiores: paredes de 12 (24 en halls), grilla de 4, ≤ 60.000 triángulos armados.

## Mallas
- Cada malla ≤ **20.000 triángulos**, un material por malla, UV dentro de 0-1, normales hacia afuera, normal map OpenGL.
- Texturas: 1024 px trajes, jefes y edificios importantes; 512 px casi todo; 256 px props chicos. **El piso de un interior puede ir a 1024; nunca 2048** (se cuelga el horneado por memoria).
- **Lo que brilla** (faros, focos, neón, pantallas, fuego) va en su malla y se exporta como `Neon_<Pieza>`. **Los vidrios** como `Glass_<Pieza>`. **Lo que se mueve** (puertas, ruedas, persianas, rotores) va aparte.

> [!note] Modelos hechos antes del 1 nov (revisado)
> - **Personajes con luces** (Centinela 3 piezas, Mascarada 3, Remache 2, Estela 17): las piezas que brillan se exportaron con el sufijo `_Neon` (por ejemplo `Centinela_Casco_Neon`) en vez del prefijo `Neon_`. El importador de Studio tiene que aceptar **los dos**; los personajes nuevos usan el prefijo.
> - **Personajes sin `_Colision`**: está bien. Van pegados al esqueleto con `CanCollide = false`; choca la cápsula del Humanoid.
> - **Puerto Óxido y calle viva** ya siguen las reglas (`Neon_`, `Glass_` y `_Colision`).
- **Choque**: lo que tiene piezas finas (escaleras, rejas, barandas) se ve pero no choca; al lado va `<Pieza>_Colision`, invisible y simple (cajas y rampas en cuña). Escaleras de mano: TrussPart en Studio.
- Al exportar se borran las **caras que nunca se ven** (base de edificios y muros, panza de autos, abajo de las calles).
- Edificios con **zócalo** abajo para que no floten.

## Chequeos automáticos (antes de mostrar un render)
- **Cruces**: el script compara las mallas de verdad (no las cajas) y avisa si dos piezas se meten una en otra. Solo se aceptan las uniones a propósito (algo atornillado a una pared).
- **Flotando**: nada que vaya en el piso puede quedar entre 0,03 y 0,6 studs arriba.
- **Topes**: tabla de triángulos por pieza y total armado.

## Horneado (lo que aprendimos con el taller)
- Piezas de **muchas partes chicas** (placas con remaches, chapa estriada, grietas, tableros perforados, rejillas): **sin bisel y sin hornear**. El detalle va en la forma. Si se hornean sin bisel, la copia suavizada sale redonda y la textura queda con manchas ovaladas.
- Piezas **muy largas** (más de 30 studs: vigas, cañerías, conductos, techos): **sin hornear**, porque cuelgan el horneado.
- Si el horneado no avanza en 5 minutos, se frena, se busca qué pieza lo trabó y se saca.
- **Nada de juntitas o líneas modeladas sobre pisos y paredes**: van en la textura.

## Diseño
- Nada de logos, emblemas, trajes, colores exactos, frases ni música de DC. Los nombres de DC son **de trabajo** y no van en el juego publicado.
- De las referencias (capturas y Gemini) se toman **ideas**, nunca personajes, logos, nombres ni diseños tal cual.

## Al terminar
- `.blend` guardado antes de cada cambio grande.
- Commit en español y push.
- Obsidian al día: la nota del modelo o lugar, su fila en la lista y el prompt tildado.

Ver también: [[Plantilla de prompt]] · [[Nivel de detalle]] · [[Colores]] · [[Guía de estilo]]
