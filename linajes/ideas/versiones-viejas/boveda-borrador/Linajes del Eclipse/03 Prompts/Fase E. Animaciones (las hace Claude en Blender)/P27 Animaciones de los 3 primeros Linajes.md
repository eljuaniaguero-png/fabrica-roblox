---
tags: [prompt]
prompt: "27"
estado: pendiente
---
# Prompt 27 Animaciones de los 3 primeros Linajes

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-linajes-1.blend.
30 fps, marcador Impacto en cada golpe, script en linajes/arte/scripts/animaciones/linajes.py.

FUERZA BRUTA (común):
- Z "Pisotón" (30): levanta la rodilla alto (0-10), pisa fuerte (Impacto 14), onda de choque, se recupera.
- X "Embestida" (24): agacha el hombro y carga 12 studs hacia adelante (Impacto 10 al chocar).
- C "Levantar y tirar" (40): agarra (Impacto 8), levanta sobre la cabeza (8-24), lanza (Impacto 28).
REFLEJOS (común):
- Z "Ráfaga" (20): 3 golpes rapidísimos alternados (Impactos 4, 9, 14).
- X "Contraataque" (16 + 20): pose de espera; si lo golpean, gira y patea (Impacto 8 de la segunda parte).
- C "Paso sombra" (18): desaparece hacia un costado (dash largo) y patea por detrás (Impacto 14).
PIROQUINESIS (común):
- Z "Bola de fuego" (22): junta las manos en la cadera (0-10), empuja hacia adelante (Impacto 12).
- X "Muro de fuego" (30): barre el brazo de izquierda a derecha a ras del piso (Impacto 16).
- C "Explosión" (40): brazos cruzados (0-14), los abre de golpe hacia los costados (Impacto 18).
DEFINITIVA genérica (V, después del Despertar) (60): se eleva 1 stud, energía se carga (0-30), descarga
con los brazos abiertos (Impacto 36), aterriza.

Mismo cierre que el Prompt 26: tiras de cuadros → mi OK → exportar a linajes/arte/animaciones/linajes/ →
importar en Studio → decime qué publicar → IDs en Config.luau → commit y push.
```
Para cada Linaje nuevo (Electro, Criogenia, Telequinesis, Velocista Cinético, Sombra Viva, Sangre Abisal, Origen Estelar, Herencia Olímpica, Eclipse) se usa el mismo prompt cambiando el bloque: **3 habilidades (Z, X, C), cada una con cuadros de anticipación, Impacto y recuperación, y qué hace el cuerpo**.

---
[[P26 Animaciones base del jugador|← P26 Animaciones base del jugador]]   ·   [[Todos los prompts]]   ·   [[P28 Animaciones de un jefe|P28 Animaciones de un jefe →]]
