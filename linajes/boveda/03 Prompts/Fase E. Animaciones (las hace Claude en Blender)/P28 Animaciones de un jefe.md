---
tags: [prompt]
prompt: "28"
estado: pendiente
---
# Prompt 28 Animaciones de un jefe (uno por jefe)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Abrí linajes/arte/blender/[jefe].blend. Animá su esqueleto a 30 fps, marcador Impacto en cada golpe y
marcador Aviso [N] cuadros antes de cada Impacto (es cuando el piso se pone rojo, 0,4 s = 12 cuadros).
Script en linajes/arte/scripts/animaciones/[jefe].py.
ANIMACIONES: quieto amenazante (loop 60), caminar pesado (loop 40), entrada (90, presentación del jefe),
3 ataques (abajo), recibir golpe fuerte (20), aturdido (loop 40), cambio de fase (60), derrota (90).
ATAQUES DE [JEFE]: [pegá la fila de la tabla]
Cierre igual que el Prompt 26.
```
| Jefe | Ataque 1 | Ataque 2 | Ataque 3 | Cambio de fase |
|---|---|---|---|---|
| Remache | Martillazo doble: levanta los dos puños (Aviso), golpea el piso, círculo de 10 studs (Impacto 30) | Carga hidráulica: los pistones se cargan, embiste en línea recta 30 studs | Tira un contenedor: lo levanta (40 cuadros), lo lanza a una zona marcada | Los tubos rojos se rompen, se pone más rápido y los pistones echan vapor |
| El Albatros | Arponazo: tira el arpón en línea recta y tira de la cadena hacia él | Barrido con el bastón en círculo de 6 studs | Llama a 3 matones con un silbido | Se sube a la grúa y tira barriles |
| Mascarada | Fase 1 Tragedia: lanza 3 naipes en abanico | Fase 2 Comedia: se ríe, se duplica en 3 copias (una es real) | Fase 3 Ninguna: explota la máscara-espejo, rayos en cruz por el piso | Cambia de máscara girando el sombrero (por eso cada fase tiene su animación de cambio) |
| Víctor Halden (exoarmadura) | Lluvia de misiles a 6 zonas marcadas | Puñetazo propulsado: vuela hasta un jugador | Escudo del reactor: se cubre y descarga una onda | Se saca la capa y los propulsores quedan siempre prendidos |
| El Eclipsador | Rayos negros desde los ojos que barren el piso | Puño gigante al piso, onda en anillo | Abre el eclipse del pecho: atrae a todos al centro | Crece y la corona se prende fuego (fase final) |

---
[[P27 Animaciones de los 3 primeros Linajes|← P27 Animaciones de los 3 primeros Linajes]]   ·   [[Todos los prompts]]   ·   [[P29 Animaciones de NPCs y enemigos|P29 Animaciones de NPCs y enemigos →]]
