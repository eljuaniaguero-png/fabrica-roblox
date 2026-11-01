---
tags: [prompt, codigo]
beta: "Solo **Tano** y **el Albatros**, con los trabajos de **Mecánico** y **Contrabandista**, confianza con los 2 y reputación de bando básica."
---
# P38 Diálogos con NPCs, trabajos y reputación

> [!summary] En tres líneas
> Sistema de diálogos como datos (nunca mezclados en el código), trabajos repetibles con 5 niveles, confianza con cada NPC y rangos de bando.

> [!info] En la Beta
> Solo **Tano** y **el Albatros**, con los trabajos de **Mecánico** y **Contrabandista**, confianza con los 2 y reputación de bando básica.

## 1. Para qué es
Para avanzar hay que hablar con NPCs. En la Beta, Tano te da trabajo de mecánico y el Albatros de contrabandista, y no se llevan bien.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/shared/Dialogos/<npc>.luau`, `linajes/src/server/Dialogos/`, `linajes/src/server/Trabajos/`.

## 2. Qué leer antes
- [[Tano]] · [[El Albatros]] (frases, qué dan, confianza)
- [[NPCs]] (tabla de confianza y trabajos)
- [[Los muelles rojos]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Diálogo con Tano en el taller** → guardar como `linajes/arte/referencias/gemini/dialogos/dialogo.png`
```
Dialogue scene in a mechanic garage at night: an old mechanic NPC with a grey mustache and blue overalls in the background, a dialogue box at the bottom with a name tab, typewriter text lines and four answer buttons, the last one being a goodbye. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Minijuego de mecánico** → guardar como `linajes/arte/referencias/gemini/dialogos/mecanico.png`
```
Mini-game UI over a car engine bay: five glowing numbered parts to tap in order, a 15-second timer ring, a wrench cursor, success sparks. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
DIÁLOGOS como datos en linajes/src/shared/Dialogos/<npc>.luau (nodos: texto, respuestas, condiciones,
acciones). Condiciones: nivel, bando, rango, reputación, confianza, trabajo y nivel, misión activa o
completa. Acciones: dar/completar misión, dar trabajo, dar dinero u objetos, sumar reputación/confianza,
enseñar nodo, abrir taller, mover al jugador. El servidor ejecuta las acciones, nunca el cliente.
Las frases salen de las notas de cada NPC.
TRABAJOS (Beta), 5 niveles de Aprendiz a Experto:
- MECÁNICO con Tano: arreglar un auto (tocar 5 piezas en orden antes de 15 s). Paga chatarra y chips.
- CONTRABANDISTA con el Albatros: llevar un paquete a un punto del puerto sin que te vea la policía ni
  una cámara. Paga dinero y reputación Cofradía +20.
CONFIANZA (0 a 500) con Tano y el Albatros: 100 trabajo, 250 te enseña o acompaña, 400 hilo secreto.
Subir con el Albatros baja con Rivas (tabla de rivales en Config).
RANGO DE BANDO: Novato (0), C (150), B (350), A (600), S (900); en la Beta solo Novato → C, con la
prueba del líder (Cofradía: el Albatros).
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Los diálogos son **datos**, no código.
- Las acciones de diálogo las ejecuta el servidor.

## 6. Pasos y puntos de control
### Paso 1: Hablar y trabajar
Hablar con los 2 y hacer un trabajo de cada uno.

**Para dar el OK:**
- [ ] El texto sale de las notas.
- [ ] La confianza sube y se guarda.
- [ ] Subir con uno baja con su rival.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Datos de diálogo y módulos.

**Cómo lo probás vos:**
- En Play, hacé un trabajo con Tano y uno con el Albatros.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda). Las referencias a la ficha vieja ya están cambiadas por las notas de la bóveda.

```
SISTEMA DE DIÁLOGO (pantalla del Prompt 33): los diálogos viven en linajes/src/shared/Dialogos/<npc>.luau
como datos (nodos con texto, respuestas, condiciones y acciones), nunca mezclados en el código.
Condiciones posibles: nivel, bando, rango, reputación, trabajo y nivel de trabajo, misión activa o completa.
Acciones: dar misión, completar misión, dar trabajo, dar dinero/objetos, sumar reputación, enseñar nodo,
abrir tienda (taller, clínica), mover al jugador.
TRABAJOS (cada uno con una tarea corta repetible de 1 a 3 minutos, 5 niveles Aprendiz → Experto):
- Reportero con Lucía Vega: sacar 3 fotos de peleas o crímenes marcados (botón de cámara, la foto vale si
  el objetivo está en cuadro y a menos de 30 studs). Paga 40 + 10 por nivel. Da rumores = misiones.
- Mecánico con Tano: arreglar un auto (minijuego: tocar 5 piezas en orden antes de 15 s). Paga chatarra.
- Patrullero con Comisaria Rivas: recorrer 4 puntos y detener 3 matones. +20 reputación Liga.
- Laboratorio con Ingeniera Okafor: probar un prototipo (llegar a 3 blancos con el gancho). Da planos.
- Contrabandista con El Albatros: llevar un paquete a un punto sin que te vea un dron. +20 Cofradía.
PEDIR AYUDA: "¿Qué hago ahora?" en Señal y en la comisaría dice la próxima misión y a quién ir;
Tano y Atalanta enseñan un nodo extra si cumplís su prueba; con reputación ≥ 300 con un héroe, podés
pedirle que te acompañe en una misión (NPC aliado que pelea).
REPUTACIÓN Y RANGO: 0 a 1000 por bando. Rangos: Novato (0), Clase C (150), B (350), A (600), S (900).
Para subir hay que tener la reputación Y hablar con el líder del bando (Liga: Centinela Solar;
Cofradía: Mascarada; Vigilantes: Cuervo), que da una prueba (pelea o misión corta).
```

---
[[P37 Niveles, árbol y Despertar 1 con ramas|← P37 Niveles, árbol y Despertar 1 con ramas]]   ·   [[Todos los prompts]]   ·   [[P38c Calle viva civiles, testigos, policía y vigilancia|P38c Calle viva civiles, testigos, policía y vigilancia →]]
