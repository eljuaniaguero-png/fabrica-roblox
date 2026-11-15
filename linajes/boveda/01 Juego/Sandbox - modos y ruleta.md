---
tags: [juego, sandbox, modos, ruleta]
---
# Sandbox: modos y ruleta

> [!summary] En tres líneas
> Al entrar ves **MODOS**: en la Beta solo está **SANDBOX**, con **Free for all** y **1 V 1**. Al elegir uno tirás la **ruleta gratis**; si no te gusta, otra tirada o un Linaje directo se pagan con **Chatarra** (que ganás por cada baja y también al caer). Con **5 bajas seguidas** se habilita el **Despertar** (G).

Decidido el 15 nov 2026 por Juani. Reemplaza al menú con Espacios, Árbol y tarjeta de bando. Números en `Config.Sandbox`.

## Flujo
1. Menú: **SANDBOX** → **FREE FOR ALL** o **1 V 1**. Debajo, Ajustes y Personaje. Historia y ranked: "pronto".
2. Se abre la **ruleta**: la primera tirada de cada partida es **gratis**.
3. Después: **Otra tirada** (40 Chatarra) o **comprar un Linaje** de la lista por **una sola vida** (60 Común, 120 Poco común). Al caer, volvés al Linaje de la ruleta.
4. **IR A PELEAR** (Free for all) o **BUSCAR RIVAL 1 V 1**.

## Monedas
- Se usa la **Chatarra**: +10 por baja, +4 al caer.
- **La Chatarra nunca se vende por Robux**: compra tiradas al azar y eso sería un ítem aleatorio pago (Guía §6).
- **Linaje permanente con Robux**: pendiente. Lo hace un pase que creás vos en Creator Hub; solo da el Linaje elegido, sin azar.

## Variante
- **5 %** de que la ruleta te dé tu Linaje en **Variante**: otro color de efectos y **+10 % de daño**. El % se ve en la ruleta.
- Colores: Fuerza Bruta rosa, Reflejos verde, Piroquinesis fuego azul, Electro magenta, Criogenia menta, Telequinesis dorado.

## Despertar
- Con **5 bajas seguidas sin caer** se enciende el rombo **G** (abajo, al lado de los poderes).
- Dura **25 s**: **+30 % de daño** y **recargas a la mitad**, con pilar de luz y aura del color del Linaje.
- Cada 5 bajas más se vuelve a habilitar. Al caer se pierde la racha.

## 1 V 1
- Fila de espera: cuando hay dos, los lleva a un **ring aparte** (flotando, lejos de la arena). 3 segundos quietos y a pelear.
- Solo se pueden pegar entre ellos. El que gana se lleva **30 Chatarra** y vuelve a la arena.

## Qué se sacó del sandbox
- **NPCs** (matones y jefe El Capataz): apagados con `Config.Enemigos.Activos = false`. El código queda para otros modos. El **maniquí** de práctica sigue.
- **Árbol de estadísticas**: apagado (`Config.Estadisticas.Activas = false`). Todos pelean con las mismas estadísticas.
- **Espacios** y la **tarjeta de bando, Chatarra, Chips y Fichas** del menú.
- El paso 5 del [[Primer minuto]] ahora es "golpe fuerte al maniquí".

## Pendiente
- Pase de Robux para Linaje permanente.
- Probar el 1 V 1 con 2 jugadores (Local Server).
- Los niveles y la XP siguen contando por bajas, pero no dan nada: decidir si se muestran o se sacan.

Ver también: [[Enemigos del sandbox]] · [[Plan por etapas]] · [[Primer minuto]]

Volver a [[Ficha del juego]]
