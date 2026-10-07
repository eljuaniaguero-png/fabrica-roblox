---
name: prototipo
description: Construye en Roblox Studio el prototipo jugable de una idea elegida y lo prueba. Usar cuando el usuario elige una idea o pide armar, construir o prototipar el juego.
---

# Construir prototipo

Argumento: la idea a construir (nombre o número del último informe de `ideas/`). Si no viene, preguntá cuál.

## Antes de empezar

1. Leé la idea en `ideas/`. Si no existe, pedile al usuario que corra `/tendencias` o que te la describa.
2. Escribí la ficha `ideas/<nombre>.md`: loop de 30 segundos, lista de sistemas (máximo 5) y qué queda afuera del prototipo. Mostrásela y esperá el OK.
3. Chequeá el entorno: `rojo --version`, que el usuario tenga `rojo serve` corriendo con el plugin conectado, y que las herramientas MCP de Roblox Studio respondan (listá los Studios conectados). Si algo falta, frená y decile exactamente qué hacer.

## Construcción

Trabajá de a un sistema por vez, en este orden:

1. `src/shared/Config.luau` con todos los números de balance.
2. Lógica de servidor en `src/server`.
3. Cliente e interfaz en `src/client`.
4. Después de cada sistema: `stylua src` y `selene src`, sin warnings.
5. Mundo por MCP: un mapa chico y legible, con partes simples. Assets de la Creator Store solo gratuitos y revisados.

## Prueba

1. Arrancá el playtest por MCP.
2. Leé la consola: cero errores en rojo antes de seguir.
3. Mové al personaje y recorré el loop completo simulando input.
4. Sacá una captura y describí lo que se ve.
5. Frená el playtest.

## Cierre

- Commit de git con lo que funciona.
- Informe corto al usuario: qué se puede jugar, qué falta, y 3 cosas puntuales para que pruebe él (ritmo, claridad, diversión).
- Listá los puntos marcados con `-- SONIDO:` para que sepa qué audios producir.
- No publiques nada.
