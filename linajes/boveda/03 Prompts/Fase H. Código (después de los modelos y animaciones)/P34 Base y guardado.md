---
tags: [prompt, codigo]
beta: "Completo (es la base de todo). Los datos de Post beta se guardan desde ya con valores vacíos."
---
# P34 Base y guardado

> [!summary] En tres líneas
> El guardado con ProfileStore: bloqueo de sesión, autoguardado, guardado al salir y al cerrar el servidor, 3 espacios de personaje y todos los datos del juego.

> [!info] En la Beta
> Completo (es la base de todo). Los datos de Post beta se guardan desde ya con valores vacíos.

## 1. Para qué es
Sin guardado seguro no se puede publicar: si se pierde o se duplica progreso, el jugador no vuelve. Es lo primero del código.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Datos/` (Perfiles.luau, Esquema.luau, Migraciones.luau), `Config.luau`.

## 2. Qué leer antes
- [[Combate y progresión]] · [[Estadísticas y movimiento]] · [[Mundo abierto y reputación]] (qué se guarda)
- GUIA-PARA-CLAUDE sección 3 (guardado)
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Pantalla de carga y de error de guardado** → guardar como `linajes/arte/referencias/gemini/guardado/carga.png`
```
Two mobile game screens for an original superhero game: 1) loading screen with a slowly pulsing solar eclipse (black disc, orange #f2652b ring) over a foggy harbor and a thin progress bar; 2) an error panel 'could not load your progress, rejoin' with one big button, same style. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

**Referencia 2: Selector de 3 espacios de personaje** → guardar como `linajes/arte/referencias/gemini/guardado/espacios.png`
```
Character slot selector: three cards side by side, each with a blocky hero preview, a colored rarity strip, level and faction badge; an empty slot card with a plus sign; dark eclipse background. Dark comic-book game UI, high contrast, rounded shapes, readable on a phone, no readable text (use placeholder lines). Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
Instalá ProfileStore con wally (linajes/wally.toml) si no está.
DATOS POR JUGADOR: espacioActivo (1-3), fichasEclipse (3 al empezar), seguroContador, compras
(PurchaseIds entregados), ajustes (música, efectos, calidad, sensibilidad).
DATOS POR ESPACIO: nombre, cuerpo (contextura, altura, piel, cara, pelo), traje (piezas y colores),
nivel, xp, puntosEstadisticas y estadisticas {vida, energia, fuerza, velocidad, defensa, recarga},
movimiento (mejoras), linaje, variante, rasgos[], nodos[], despertar (0-2), linajeSecundario,
origen, bando, rango, reputacion {ciudades{vortice,corona,puerto}, bandos{liga,cofradia,vigilantes},
grupos{policia,prensa,corona,pandillas,contrabandistas}}, confianza {<npc>: 0-500}, fama,
trabajos {mecanico, contrabandista, ...: nivel, xp}, tecnologia {traje: Mk, gadget: {nombre, Mk}},
implantes {brazo, ojos, columna}, materiales {chatarra, chips, raras}, dinero, dineroSucio,
misiones {activas, completas, decisiones}, hilos del Narrador, estacionesDescubiertas[].
SchemaVersion 1 con Migraciones.luau (vacía, lista para la 2).
REGLAS: bloqueo de sesión (ProfileStore), autoguardado, guardar al salir, en BindToClose en paralelo
con tope de 25 s, al recibir ServerRestartScheduled y justo después de cada compra. Si falla la carga:
pantalla "No pudimos cargar tu progreso, volvé a entrar" y NO dejarlo jugar sin guardar; no apaga el
guardado de los demás. ProcessReceipt idempotente (aunque en la Beta no se vende nada).
Pantalla de 3 espacios (crear, elegir, borrar con confirmación escrita).
PRUEBA: entrar, cambiar cosas, salir, volver; simular una falla de carga (atributo de prueba);
cerrar el servidor en el medio.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- Bloqueo de sesión, autoguardado, `BindToClose` en paralelo (25 s) y `ServerRestartScheduled`.
- `UpdateAsync`, nunca `SetAsync`.

## 6. Pasos y puntos de control
### Paso 1: Guardado andando
Entrar, cambiar, salir, volver; simular fallas.

**Para dar el OK:**
- [ ] El progreso vuelve igual.
- [ ] Con falla de carga, no deja jugar sin guardar.
- [ ] 3 espacios independientes.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos en `src/server/Datos/`, `wally.toml`, `Config.luau`.

**Cómo lo probás vos:**
- Entrá, cambiá de espacio, salí y volvé: todo tiene que seguir.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
Copiá el guardado con ProfileStore del juego archivado más completo (ver archivo/README.md) y adaptalo.
DATOS por jugador: espacioActivo (1-3), fichasEclipse, seguroContador, compras (PurchaseIds entregados).
DATOS por espacio: nombre, nivel, xp, linaje, linajeSecundario, rareza, bando, rango, reputacion
{liga, cofradia, vigilantes}, reputacionNPC {rivas, vega, tano, okafor, kessler, brandt, senal},
trabajos {reportero, mecanico, patrullero, laboratorio, contrabandista} con nivel y xp,
puntosArbol, nodos[], despertar (0-2), implantes {brazo, ojos, columna}, cargaCibernetica,
tecnologia {traje: MkN, gadget: nombre y MkN}, trajes desbloqueados[], trajePuesto, fragmentos[],
misiones {activas, completas}, acto, dinero, chatarra, chips.
SchemaVersion 1. Autoguardado (ProfileStore), guardado al salir, en BindToClose y al recibir
ServerRestartScheduled. Si falla la carga, avisarle al jugador y no dejarlo jugar sin guardar.
Config.luau con TODOS los números de balance de los prompts siguientes.
Probá: entrar, cambiar cosas, salir, volver a entrar; y simular una falla de carga.
```

---
[[P33 HUD y menús|← P33 HUD y menús]]   ·   [[Todos los prompts]]   ·   [[P35 Combate|P35 Combate →]]
