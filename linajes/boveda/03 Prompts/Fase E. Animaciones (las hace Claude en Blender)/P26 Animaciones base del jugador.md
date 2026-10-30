---
tags: [prompt]
prompt: "26"
estado: pendiente
---
# Prompt 26 Animaciones base del jugador (las usan todos)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y las secciones 1, 2 y 3 de la nota "Animaciones (plan completo)" de la
bóveda: la lista de abajo es el mínimo, el plan manda (incluye los 5 estilos de pelea y las poses del menú).
Abrí linajes/arte/blender/kit-base.blend y guardalo como
linajes/arte/blender/animaciones-base.blend. Animá el esqueleto R15 del cuerpo propio (P20f) a 30 fps.
Cada animación es una Action separada, con su script en linajes/arte/scripts/animaciones/base.py.

LOCOMOCIÓN (loops):
1. Quieto (60 cuadros): respiración lenta, hombros suben 0,03 studs, peso en una pierna, mira a los costados
   una vez.
2. Caminar (32 cuadros): paso firme, brazos opuestos a las piernas, leve balanceo del torso.
3. Correr (20 cuadros): torso inclinado 15° hacia adelante, brazos doblados a 90°, rodillas altas.
4. Correr rápido / velocista (14 cuadros): torso a 30°, brazos hacia atrás rectos.
5. Saltar (inicio 8 + aire loop 20 + caer 10): se agacha, se estira, rodillas arriba en el aire, amortigua.
6. Trepar (24 cuadros, loop) para paredes con gancho.
7. Volar quieto (60, loop) y volar avanzando (30, loop): cuerpo horizontal, un brazo adelante.

COMBATE (no loop, marcador Impacto donde se indica):
8. Combo golpe 1 (14 cuadros): jab derecho. Anticipación 0-4, Impacto en 6, recuperación 7-14.
9. Combo golpe 2 (14): cross izquierdo. Impacto en 6.
10. Combo golpe 3 (18): gancho ascendente derecho. Impacto en 8.
11. Combo golpe 4 (24): patada giratoria que empuja. Anticipación 0-8, Impacto en 12, cae en guardia.
12. Bloqueo (inicio 4 + loop 30): antebrazos cruzados delante de la cara, rodillas flexionadas.
13. Parry (12): golpe seco con el antebrazo hacia afuera, Impacto en 3, queda abierto y seguro.
14. Dash adelante / atrás / izquierda / derecha (8 cada uno): cuerpo inclinado en la dirección, sin pasos.
15. Recibir golpe liviano (10) y fuerte (18, retrocede 2 studs).
16. Aturdido (loop 40): tambalea, cabeza gira.
17. Derrota (40): cae de rodillas y después de costado. Levantarse (30).

INTERACCIÓN:
18. Hablar con NPC (loop 60): gestos de manos suaves. 19. Recoger del piso (20). 20. Abrir menú de taller (24).
21. Celebrar (40): puño arriba. 22. Saludo (30).

Para cada animación: render de 3 cuadros clave en una tira (linajes/arte/renders/anim-<nombre>.png).
Mostrame una hoja con todas las tiras y esperá mi OK. Con mi OK: exportá cada Action a
linajes/arte/animaciones/base/<nombre>.fbx, importalas en Studio sobre un Dummy R15 y decime exactamente
qué tengo que tocar para publicarlas. Anotá los IDs en Config.luau. Commit y push.
```

---
[[P25d Interiores donde se puede entrar|← P25d Interiores donde se puede entrar]]   ·   [[Todos los prompts]]   ·   [[P26b Animaciones de tecnología, gadgets y vehículos|P26b Animaciones de tecnología, gadgets y vehículos →]]
