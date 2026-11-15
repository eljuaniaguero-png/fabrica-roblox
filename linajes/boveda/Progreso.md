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
| Ruleta con los 6 Linajes y % a la vista; la primera tirada es gratis | `src/server/Ruleta.server.luau` | 14 nov |
| Creador de personaje (piel, cara, pelo, ropa, bando) guardado | `src/client/Creador.client.luau` | 14 nov |
| Guardado con ProfileStore: Linaje, nivel, apariencia, monedas, estadísticas | `src/server/Perfiles.luau` | 14 nov |
| Árbol de estadísticas: 1 punto por nivel, 6 estadísticas, tope 40 | `src/shared/Estadisticas.luau` | 15 nov |
| Menú principal animado y HUD editorial | `src/client/Menu.client.luau` y otros | 14 nov |
| [[Primer minuto]]: 5 pasos con premio y baliza | `src/client/Minuto1.client.luau` | 15 nov |
| Arena: matones, maniquí, cajas y barriles, muro de hielo rompible | `src/server/ArenaSueltos.server.luau` y otros | 15 nov |
| Elenco de 8 personajes en estilo cómic, ajustado a sus fichas (sin importar a Studio) | [[Personajes]] | 14 nov |

## Falta para lanzar el sandbox
1. **Duelos 1 contra 1** por invitación (el círculo del centro existe, el sistema no).
2. **Sonidos y música** (ForgeGUI): golpes, parry, poderes, ruleta, menú y ambiente.
3. **Tienda y pases**: pack fundador, estilos de Linaje, espacios, servidores privados. Los pases los creás vos en Creator Hub.
4. **Algo en qué gastar la Chatarra** (hoy se gana y no se usa).
5. **Prueba con 2 o 3 jugadores** en Local Server y en celular (45 FPS o más).
6. **Analítica** (`AnalyticsService`) del primer minuto.
7. **Antes de publicar**: apagar las teclas de prueba (`Config.PruebaTeclas.Activas`, `Config.Poderes.CambioLibre`), copia `.rbxl`, cuestionario, ícono y miniaturas. **Publicar lo hacés vos.**

## Pendiente de arte (frenado hasta que ande el sandbox)
- [[Auditoría visual de personajes y plan de mejoras]]: fases 1 y 2.
- Re-exportar e importar a Studio el elenco nuevo.

## Dónde ver los resultados
- En tu PC: `C:\Users\eljua\fabrica-roblox\linajes\arte\renders`.
- En Obsidian: cada modelo en [[Personajes]].
- En GitHub: repo `eljuaniaguero-png/fabrica-roblox`.
- Notas viejas: [[Archivo]] (nada se borra).

Volver a [[00 Inicio]]
