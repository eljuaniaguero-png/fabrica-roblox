---
tags: [progreso]
---
# Progreso

Actualizado: **15 nov 2026**. Esta nota resume **dónde estamos**. El plan está en [[Plan por etapas]]; los prompts, en [[Todos los prompts]].

## Etapa actual: sandbox de pelea (Fase 1)
El juego sale primero como **sandbox de pelea gratis con 6 Linajes** en la arena de Puerto Óxido. El arte nuevo está frenado hasta que el sandbox ande; la regla es **"si la pelea no es divertida, no se lanza"**.

## Hecho y probado en Studio
| Qué | Dónde | Desde |
|---|---|---|
| Combate: combo, bloqueo, parry, dash, cámara de combate e impactos | `src/server/Combate.server.luau`, `src/client/Combate.client.luau` | 14 nov |
| **6 Linajes** con Z X C: Fuerza Bruta, Reflejos, Piroquinesis, Electro, Criogenia y Telequinesis (pasivas incluidas) | `src/server/Poderes.server.luau`, `Config.Poderes` | 14 nov |
| Animaciones propias de los 6 Linajes (los 3 Poco comunes, con lenguaje propio) | `arte/scripts/animaciones/` | 15 nov |
| [[Sandbox - modos y ruleta]]: menú de MODOS (Free for all y 1 V 1), ruleta gratis por partida, otra tirada y Linaje por una vida con Chatarra, Variante 5 % | `src/server/Ruleta.server.luau`, `src/client/Ruleta.client.luau` | 15 nov |
| Despertar con 5 bajas seguidas (G) | `src/server/Despertar.server.luau` | 15 nov |
| Linaje para siempre con Robux (pases; faltan los IDs) | `Config.Sandbox.PasesLinaje` | 15 nov |
| Analítica: embudo del primer minuto y entradas y salidas de Chatarra | `src/server/Analitica.luau` | 15 nov |
| Creador de personaje (piel, cara, pelo, ropa, bando) guardado | `src/client/Creador.client.luau` | 14 nov |
| Guardado con ProfileStore: Linaje, nivel, apariencia, monedas | `src/server/Perfiles.luau` | 14 nov |
| Menú principal animado y HUD editorial | `src/client/Menu.client.luau` y otros | 14 nov |
| [[Primer minuto]]: 5 pasos con premio y baliza | `src/client/Minuto1.client.luau` | 15 nov |
| Arena: maniquí, cajas y barriles, muro de hielo rompible (NPCs y jefe apagados) | `src/server/ArenaSueltos.server.luau` y otros | 15 nov |
| Elenco de 8 personajes en estilo cómic, ajustado a sus fichas (sin importar a Studio) | [[Personajes]] | 14 nov |

## Hecho, falta probar
- **1 V 1** con ring aparte: la fila anda; la pelea necesita 2 jugadores en Local Server.

## Falta para lanzar el sandbox
1. **Crear los 6 pases de Linaje** en Creator Hub (Monetización → Pases; sugerido 99 R$ los Comunes y 199 R$ los Poco comunes) y pasarle los IDs a Claude. **Lo hacés vos.**
2. **Sonidos y música** (ForgeGUI): golpes, parry, poderes, ruleta, Despertar, menú y ambiente.
3. **Prueba con 2 o 3 jugadores** en Local Server (incluye el 1 V 1) y en celular (45 FPS o más).
4. **Hacer el juego lindo**: luces, modelos, VFX y HUD.
5. Decidir si se muestran el nivel y la XP (hoy suben con las bajas pero no dan nada).
6. **Antes de publicar**: apagar las teclas de prueba (`Config.PruebaTeclas.Activas`, `Config.Poderes.CambioLibre`), copia `.rbxl`, cuestionario, ícono y miniaturas. **Publicar lo hacés vos.**

## Pendiente de arte (frenado hasta que ande el sandbox)
- [[Auditoría visual de personajes y plan de mejoras]]: fases 1 y 2.
- Re-exportar e importar a Studio el elenco nuevo.

## Dónde ver los resultados
- En tu PC: `C:\Users\eljua\fabrica-roblox\linajes\arte\renders`.
- En Obsidian: cada modelo en [[Personajes]].
- En GitHub: repo `eljuaniaguero-png/fabrica-roblox`.
- Notas viejas: [[Archivo]] (nada se borra).

Volver a [[00 Inicio]]
