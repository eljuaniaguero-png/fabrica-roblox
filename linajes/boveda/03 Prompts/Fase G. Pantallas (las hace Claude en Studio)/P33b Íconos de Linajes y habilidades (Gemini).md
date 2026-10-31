---
tags: [prompt, gemini]
prompt: "33b"
estado: pendiente
---
# Prompt 33b Íconos de Linajes, habilidades, gadgets e implantes (Gemini)

**Dónde va:** en **Gemini**. Mismas reglas que [[P33a Logo, ícono y miniaturas (Gemini)]]: fondo verde #00FF00, guardar en `linajes/arte/2d/gemini/` con el nombre que se indica, y después pedirle a Claude que los limpie y los suba.
**Truco para que todos salgan iguales:** hacé los íconos en **un solo chat** de Gemini. El primer mensaje es el bloque "Estilo"; después pedís cada ícono con una línea.

## Estilo (primer mensaje del chat)
```
You will draw a set of game icons for a dark comic-book superhero game on Roblox. Rules for EVERY icon:
1:1 square, 512x512, flat solid #00FF00 green background, one centered symbol, thick dark outline
(#0e1016), bold simple shapes readable at 48 pixels on a phone, soft inner glow, no text, no letters,
no existing logos or brands, nothing from DC or Marvel. Reply "ok" and wait for my icon requests.
```

## Linajes (12): guardalos como `linaje-<nombre>.png`
Pedí cada uno así: `Icon: <símbolo>, glow color <color>.` El color del brillo es el de su rareza (ver [[Colores]]).
| Archivo | Símbolo | Color |
|---|---|---|
| linaje-fuerza-bruta | a cracked fist hitting the ground | #9aa3ad |
| linaje-reflejos | an eye with three motion lines | #9aa3ad |
| linaje-piroquinesis | a flame shaped like a hand | #9aa3ad |
| linaje-electro | a lightning bolt splitting in two | #4ed68a |
| linaje-criogenia | a snowflake made of ice shards | #4ed68a |
| linaje-telequinesis | a floating rock with violet waves | #4ed68a |
| linaje-velocista | a running shoe with a light trail | #4fb3f2 |
| linaje-sombra | a dark smoky silhouette with two eyes | #4fb3f2 |
| linaje-sangre-abisal | a water drop with a trident inside | #4fb3f2 |
| linaje-origen-estelar | a star with a glowing core | #f2a23a |
| linaje-herencia-olimpica | a laurel crown with a lightning bolt | #f2a23a |
| linaje-eclipse | a solar eclipse ring, half light half dark | #ff4d6d |

## Habilidades de los 3 primeros Linajes (9): `hab-<nombre>.png`
Pisotón, Embestida, Levantar y tirar (Fuerza Bruta) · Ráfaga, Contraataque, Paso sombra (Reflejos) · Bola de fuego, Muro de fuego, Explosión (Piroquinesis). Pedí: `Icon for the ability "<nombre en inglés>": <qué pasa>, glow color <color del Linaje>.`

## Gadgets (8) e implantes (6): `gadget-<nombre>.png` / `implante-<nombre>.png`
Gancho, granada de humo, dron, boomerang, red, linterna, escudo plegable, botiquín · cañón de brazo, puño hidráulico, ojos de puntos débiles, visión nocturna, doble salto, columna de recarga. Brillo `#3fe0f0` (tecnología).

## Monedas y objetos (5): `item-<nombre>.png`
Ficha de Eclipse (moneda negra con anillo naranja), Esquirla (cristal naranja), chatarra, chip, Fragmento de Linaje (piedra con luz adentro).

---
[[P33a Logo, ícono y miniaturas (Gemini)|← P33a Logo, ícono y miniaturas (Gemini)]]   ·   [[Todos los prompts]]   ·   [[P33c HUD y menús en Figma|P33c HUD y menús en Figma →]]
