---
tags: [prompt]
prompt: "26b"
estado: pendiente
---
# Prompt 26b Animaciones de tecnología, gadgets y vehículos

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Animaciones (plan completo)]]

```
Leé las secciones 5 y 6 de la nota "Animaciones (plan completo)" de la bóveda. Abrí animaciones-base.blend
y guardalo como linajes/arte/blender/animaciones-tecnologia.blend. 30 fps sobre el cuerpo propio (R15),
marcador Impacto en cada golpe o disparo. Script en linajes/arte/scripts/animaciones/tecnologia.py.

GADGETS (cuerpo + objeto): gancho (tirar, colgarse en loop, soltarse), granada de humo (tirar), dron
(lanzar y recibir), boomerang (tirar y atrapar), red (disparar), linterna cegadora (apuntar),
escudo plegable (abrir, loop, cerrar), botiquín (curarse).
IMPLANTES: cañón del brazo (apuntar loop y disparar), puño hidráulico (cargar y pegar), doble salto.
ESCENAS: instalar implante en la camilla (Kessler y el jugador), fabricar en el banco del taller,
probarse un traje nuevo, transferencia de Linaje (el fragmento entra en el pecho).
VEHÍCULOS: subir, bajar, manejar (loop), salir corriendo de un choque.

Lo que no es cuerpo (ruedas, sirenas, pistones, dron volando) va por código en linajes/src/client/,
con los números en Config.luau.
Cierre igual que el Prompt 26: tiras de cuadros → mi OK → exportá a linajes/arte/animaciones/tecnologia/
→ importá en Studio → decime qué publicar → IDs en Config.luau → commit y push.
```

---
[[P26 Animaciones base del jugador|← P26 Animaciones base del jugador]]   ·   [[Todos los prompts]]   ·   [[P27 Animaciones de los 3 primeros Linajes|P27 Animaciones de los 3 primeros Linajes →]]
