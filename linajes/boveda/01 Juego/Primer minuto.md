---
tags: [juego, sandbox, tutorial]
---
# Primer minuto (qué hace el jugador al entrar)

> [!summary] En tres líneas
> Del menú a la primera pelea en **menos de 2 minutos**, sin pantallas que bloqueen el juego. El jugador arma su personaje, gira la Ruleta gratis y aprende a pelear con **5 pasos marcados** que dan un premio. Al terminar sube a nivel 2 y gasta su primer punto: ya tiene **3 motivos para seguir** (subir, ganar Fichas, probar otro Linaje).

Decidido el 15 nov 2026. Código: `client/Minuto1.client.luau`, `server/Minuto1.server.luau`, números en `Config.Minuto1`.

## Paso a paso (jugador nuevo)

| Tiempo | Qué ve | Qué hace | Qué gana |
|---|---|---|---|
| 0–10 s | **Menú** con el puerto de fondo, brasas y eclipse | Toca **CONTINUAR** (o M) | — |
| 10–40 s | **Creador** con su personaje a la derecha | Elige piel, cara, pelo, ropa y bando (o "al azar") y **CONFIRMAR** | Su personaje propio, guardado |
| 40–50 s | Aviso arriba: *"Noche del Eclipse · Puerto Óxido"* y la lista **PRIMEROS PASOS** arriba a la izquierda | Va a la **Ruleta** (arriba a la derecha) y tira **gratis** | Su **Linaje** (uno de 6, con % a la vista) |
| 50–70 s | Una baliza **"PROBÁ TUS GOLPES"** lo lleva al maniquí | Pega con **click** (combo) y usa **Q** (dash) o **F** (bloqueo) | Pasos 2 y 3 tildados |
| 70–90 s | Sus poderes Z X C abajo al centro, con nombre | Usa un poder | Paso 4 |
| 90–120 s | La baliza cambia a **"OBJETIVO: MATÓN"** | Pelea con un matón del puerto | Paso 5 |
| Al terminar | Cartel **"¡Listo para el puerto!"** | — | **+50 Chatarra y +100 XP → nivel 2 → 1 punto** para el árbol |

Los 5 pasos: **Despertar** (Ruleta) · **Combate** (un golpe) · **Defensa** (dash o bloqueo) · **Poder** (Z, X o C) · **Matón**. Se puede **saltar** (botón en la lista). El servidor marca cada paso cuando pasa de verdad y entrega el premio **una sola vez** (queda guardado).

## Reglas del primer minuto
- **Nada bloquea**: la lista y los avisos no tapan el centro de la pantalla ni piden cerrar ventanas.
- **Un solo objetivo por vez**: la baliza siempre apunta a lo siguiente.
- **La zona segura** (círculo celeste) es para elegir y mirar; para pelear hay que salir.
- **Lo pago no aparece** en el primer minuto.

## Después del primer minuto (por qué vuelve)
1. **Subir de nivel**: cada baja da XP; cada nivel da 1 punto en el [[Estadísticas y movimiento|árbol de estadísticas]].
2. **Fichas de Eclipse**: 1 cada 5 bajas → otra tirada de Ruleta para buscar otro Linaje.
3. **Racha y bajas**: se ven en la lista de jugadores (Tab) y en el menú.

## Pendiente
- **Chatarra no tiene en qué gastarse todavía** (va al Taller / tienda de estilos). Hasta entonces, el premio de Chatarra no motiva.
- Probar el recorrido entero con un jugador nuevo de verdad (cuenta sin datos) y medir cuánto tarda.
- En celular: confirmar que la lista y la baliza no tapen los botones táctiles.

Ver también: [[Plan por etapas]] · [[Poderes, inicio y personalización]] · [[Sistema de diseño]] (mapa del HUD).

Volver a [[Ficha del juego]]
