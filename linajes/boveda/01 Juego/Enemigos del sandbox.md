---
tags: [juego, sandbox, enemigos]
---
# Enemigos del sandbox

> [!summary] En tres líneas
> La arena tiene **3 zonas de enemigos**, cada una con su rango de nivel: cuanto más lejos de la zona segura, más difíciles. Los enemigos aparecen solos, te atacan si te acercás y, al derrotarlos, dan **XP y Chatarra** según su nivel. Así subís de nivel peleando contra NPCs mientras compartís el servidor con jugadores reales.

Decidido el 15 nov 2026 (pedido de Juani: "NPCs que te atacan para que los mates y subas de nivel"). Números en `Config.Enemigos`; código en `server/Combate.server.luau`.

## Zonas (arena de Puerto Óxido)
| Zona | Nivel de los enemigos | Quiénes aparecen | Cuántos a la vez |
|---|---|---|---|
| **Muelle** | 1 a 6 | Matón, Carterista | 4 |
| **Contenedores** | 6 a 15 | Matón, Carterista, Matón pesado | 5 |
| **Grúas** | 15 a 30 | Matón pesado, Matón | 4 |

Cuando hay más mapas, cada mapa tiene sus propias zonas.

## Tipos
| Tipo | Cómo pelea | Vida (nv 1) | Daño | Velocidad | Premio (nv 1) |
|---|---|---|---|---|---|
| **Matón** | Combo de 2 o 3 golpes, embestida, a veces bloquea | 180 | 10 | 18 | 60 XP · 6 Chatarra |
| **Carterista** | Chico y rápido, embiste seguido, casi no bloquea | 120 | 7 | 24 | 50 XP · 5 Chatarra |
| **Matón pesado** | Grande y lento, pega fuerte y bloquea mucho | 320 | 16 | 14 | 110 XP · 12 Chatarra |

**Por nivel**: +7 % de vida, +4 % de daño y +8 % de premio. Se ven distintos por **tamaño**, **gorro** y **color del borde**, y arriba de la cabeza dicen su **nombre y nivel**.

## Reglas
- No entran a la zona segura ni atacan ahí.
- Si no hay nadie cerca vuelven a su lugar; al morir, a los 6 s aparece otro en la zona.
- El servidor decide todo (vida, daño y premio).

## Pendiente
- **Matón con implantes** (modelo listo en `arte/exports/enemigo-maton-implantes/`, falta importarlo a Studio) para las Grúas.
- Drones y robots de seguridad (modelos sin hacer).
- Aviso en pantalla de en qué zona estás y su nivel.

Ver también: [[Primer minuto]] · [[Plan por etapas]] · [[Arena del sandbox]]

Volver a [[Ficha del juego]]
