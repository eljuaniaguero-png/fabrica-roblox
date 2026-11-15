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
| **Muelle** | 1 a 6 | Matón, Carterista | 2 |
| **Contenedores** | 6 a 15 | Matón, Carterista, Matón pesado | 3 |
| **Grúas** | 15 a 30 | Matón pesado, Matón | 2 |

Cuando hay más mapas, cada mapa tiene sus propias zonas.

## Tipos
| Tipo | Cómo pelea | Vida (nv 1) | Daño | Velocidad | Premio (nv 1) |
|---|---|---|---|---|---|
| **Matón** | Combo de 2 o 3 golpes, embestida, a veces bloquea | 180 | 10 | 18 | 60 XP · 6 Chatarra |
| **Carterista** | Chico y rápido, embiste seguido, casi no bloquea | 120 | 7 | 24 | 50 XP · 5 Chatarra |
| **Matón pesado** | Grande y lento, pega fuerte y bloquea mucho | 320 | 16 | 14 | 110 XP · 12 Chatarra |

**Por nivel**: +7 % de vida, +4 % de daño y +8 % de premio. Se ven distintos por **tamaño**, **gorro** y **color del borde**, y arriba de la cabeza dicen su **nombre y nivel**.

## Jefe que aparece cada tanto: El Capataz
- Aparece **cada 6 minutos** (el primero a los 2) en Contenedores o en Grúas, con un **cartel para todo el servidor**.
- Es un matón enorme (1,7 de tamaño), nivel 20, unos **3.000 de vida**. Además del combo, tiene el **golpazo**: marca un **círculo rojo en el piso**, avisa 1,1 s y pega 35 a todos los que quedan adentro.
- **Premio para todos los que le pegaron** (no solo el que lo remata): **700 XP, 80 Chatarra y 1 Ficha** para la Ruleta.
- Si nadie lo derrota en **4 minutos**, se va ("vuelve en unos minutos").
- Es un jefe de la arena, no Remache: Remache sigue siendo el jefe de la historia y entra cuando se importe su modelo.

## Reglas
- No entran a la zona segura ni atacan ahí.
- Si no hay nadie cerca vuelven a su lugar; al morir, a los 10 s aparece otro en la zona (con un sello en el piso).
- **Efectos en violeta**: los golpes, tajos y la muerte de los enemigos son violetas (el jefe, naranja), para no confundirlos con los tuyos, que son del color de tu Linaje. Al morir estallan en esquirlas y al que lo derrotó le flota "+XP" y "+Chatarra".
- Menos enemigos a la vez (7 en total, antes 13), pedido de Juani el 15 nov.
- El servidor decide todo (vida, daño y premio).

## Pendiente
- **Matón con implantes** (modelo listo en `arte/exports/enemigo-maton-implantes/`, falta importarlo a Studio) para las Grúas.
- Drones y robots de seguridad (modelos sin hacer).
- Aviso en pantalla de en qué zona estás y su nivel.

Ver también: [[Primer minuto]] · [[Plan por etapas]] · [[Arena del sandbox]]

Volver a [[Ficha del juego]]
