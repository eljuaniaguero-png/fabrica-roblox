---
tags: [prompt, codigo]
beta: "**1 inicio** del puerto (Estibador; el Acróbata si sobra tiempo) y **primera pelea antes del minuto 5**. Los 6 inicios, en la Post beta."
---
# P39 Prólogo tu origen y la Noche del Eclipse

> [!summary] En tres líneas
> Los primeros 5 minutos: creás tu personaje, vivís tu vida normal en el puerto, cae el Eclipse, despertás tu Linaje y peleás por primera vez.

> [!info] En la Beta
> **1 inicio** del puerto (Estibador; el Acróbata si sobra tiempo) y **primera pelea antes del minuto 5**. Los 6 inicios, en la Post beta.

## 1. Para qué es
El algoritmo de Roblox mide el rebote del primer minuto: tiene que enganchar ya.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Prologo/`, cinemáticas de P30c, `Config.luau` (Prologo).

## 2. Qué leer antes
- [[La Noche del Eclipse]] · [[Los 6 orígenes]] (Estibador)
- [[El Albatros]] (te saca del agua)
- [[Señal]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: La Noche del Eclipse en el puerto** → guardar como `linajes/arte/referencias/gemini/prologo/eclipse.png`
```
Cinematic wide shot: a harbor at dusk as a solar eclipse covers the sun, the sky turns black with a burning orange ring, shards of black light rain down over cranes and containers, a blocky dockworker looking up holding a crate. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Despertar en el muelle** → guardar como `linajes/arte/referencias/gemini/prologo/despertar.png`
```
A blocky dockworker waking up soaked on a wooden pier at night, a short wide harbor boss in a long navy captain's coat and cap leaning on a harpoon cane above them, fog, eclipse ring in the sky. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
INICIO ESTIBADOR (Beta), con origen en el Part tag "Origen" Origen=Estibador:
1. Creador (P36b) con ropa de civil. (0:00-1:00)
2. Vida normal: descargar 3 cajas del barco (tutorial de moverse y agarrar). (1:00-2:00)
3. El Eclipse: cinemática de 15 s (P30c); una esquirla te tira al agua.
4. Despertás en el muelle con el Albatros al lado ("Te saqué del agua. Me debés una."). Ruleta (P36)
   como visión del poder. (2:30-3:30)
5. Señal por radio: "Si me escuchás, no estás solo." Pelea guiada contra 3 matones del puerto (combo,
   bloqueo, dash, Z) antes del minuto 5. (3:30-5:00)
6. El Albatros te manda con Tano o te ofrece trabajo: desde ahí no hay misión obligatoria.
Medí con AnalyticsService cada paso (P43). Todo salteable si ya lo jugaste en otro espacio.
POST BETA: los otros 5 inicios en sus ciudades, reclutamiento de los 3 líderes.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Primera pelea antes del minuto 5.
- Cada paso medido con AnalyticsService.

## 6. Pasos y puntos de control
### Paso 1: Jugar el inicio
Entrar con un espacio nuevo y cronometrar.

**Para dar el OK:**
- [ ] Se pelea antes del minuto 5.
- [ ] Se entiende qué pasó sin leer mucho.
- [ ] Se puede saltear la segunda vez.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos del prólogo.

**Cómo lo probás vos:**
- Creá un espacio nuevo y cronometrá hasta la primera pelea.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
Leé la sección 0c de linajes/ideas/ficha.md.
1. Creador de personaje (Prompt 36b) con ropa de civil.
2. ORIGEN AL AZAR (servidor): uno de 6 inicios (Estibador, Pasante, Repartidor, Fotógrafo, Preso, Acróbata),
   cada uno en su lugar del mapa (tags "Origen" del Prompt 20c: 2 por ciudad, así cada jugador arranca
   en una ciudad distinta), con 1 tarea corta de su vida normal (descargar 3 cajas, ordenar el
   laboratorio, entregar 2 paquetes, sacar 2 fotos, salir al patio, hacer un salto en la feria) y su
   primer NPC. El inicio no da Rasgo: suma estadísticas de arranque (ej. el Acróbata empieza con saltos
   anotados) que pesan en el primer Rasgo.
3. EL ECLIPSE: cámara cinemática de 15 s: la luna se tapa, la ciudad se apaga, una esquirla de luz negra
   cae y te atraviesa, te desmayás (animación) y la pantalla se va a negro.
4. DESPERTAR: abrís los ojos en otro lugar con un NPC al lado (distinto por inicio). Ruleta de Linaje
   (Prompt 36) como "visión" del poder. Empezás con su Variante Normal y sin Rasgos (salen jugando).
5. Señal por radio: "Si me escuchás, no estás solo." Pelea guiada contra 3 matones (combo, bloqueo, dash, Z).
6. En la plaza, Centinela Solar, Mascarada y Cuervo (NPCs) ofrecen reclutarte, cada uno con 3 líneas propias
   que cambian según tu inicio. Elegís bando o seguís Neutral.
7. Te manda con tu primer NPC de trabajo según el bando. Desde ahí no hay más misión obligatoria: el Narrador
   (Prompt 41) empieza a repartir ganchos. El primero llega a los 3 minutos y depende de tu origen.
Probá los 6 inicios. Commit y push.
```

---
[[P40 Tecnología e implantes|← P40 Tecnología e implantes]]   ·   [[Todos los prompts]]   ·   [[P41a Primer hilo hecho a mano Los muelles rojos|P41a Primer hilo hecho a mano Los muelles rojos →]]
