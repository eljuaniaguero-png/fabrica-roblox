---
tags: [prompt]
prompt: "31"
estado: pendiente
---
# Prompt 31 Sonidos de combate y menús

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Con ForgeGUI generá estos efectos de sonido para Linajes del Eclipse. Estilo: superhéroe de cómic,
golpes con cuerpo y un toque metálico, nada caricaturesco. Nada que imite sonidos de DC.
Guardá cada uno en linajes/arte/sonidos/<nombre>.ogg y una tabla en linajes/arte/sonidos/LISTA.md
(nombre, duración, descripción).
COMBATE: golpe-1, golpe-2, golpe-3 (0,3 s cada uno, golpes secos de puño con eco corto, distintos),
golpe-4-patada (0,5 s, más grave con barrido), bloqueo (0,3 s, impacto apagado), parry (0,4 s, clank
metálico agudo con brillo), dash (0,3 s, whoosh), recibir-golpe (0,3 s), aturdido (1 s, zumbido),
derrota (1,2 s, caída pesada), aviso-jefe (0,4 s, alarma grave que crece).
LINAJES: por cada uno de Fuerza Bruta, Reflejos y Piroquinesis: Z, X y C con carga (0,3 a 0,8 s) y
disparo/impacto (0,4 a 1,2 s) según la animación (pisotón con temblor, embestida, lanzamiento;
ráfaga de 3 golpes, contraataque, paso sombra; bola de fuego, muro de fuego, explosión).
MENÚS: botón (0,1 s), abrir-menú (0,3 s), cerrar-menú (0,2 s), ruleta-girando (loop 2 s, clicks que se
frenan), resultado-comun, resultado-poco-comun, resultado-raro, resultado-epico, resultado-legendario,
resultado-mitico (1 a 3 s, cada uno más épico que el anterior), subir-nivel (1,5 s), punto-habilidad
(0,6 s), dialogo-npc (0,2 s, blip suave), mision-completa (1,5 s), recoger-objeto (0,3 s).
Después subilos a Roblox (decime si necesito tocar algo) y anotá los IDs en linajes/src/shared/Config.luau.
Commit y push.
```

---
[[P30c Cinemáticas|← P30c Cinemáticas]]   ·   [[Todos los prompts]]   ·   [[P32 Ambientes y música|P32 Ambientes y música →]]
