---
tags: [prompt]
prompt: "29b"
estado: pendiente
---
# Prompt 29b Animaciones de la calle viva

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Abrí animaciones-base.blend y guardalo como animaciones-calle.blend. A 30 fps, sobre el esqueleto R15.
Marcá "Impacto" donde haya contacto.
CIVILES: caminar con bolsa (loop 32), caminar mirando el teléfono (loop 32), asustarse (20), huir
corriendo con brazos arriba (loop 20), LLAMAR A LA POLICÍA (saca el teléfono, lo lleva a la oreja, mira
para todos lados: 120 cuadros = 4 s, con marcador "LlamadaHecha" al final), filmar con el teléfono (loop 60),
aplaudir (loop 30), agacharse con manos en la cabeza (loop 40), valiente que se pone en guardia (20).
POLICÍA: patrullar con linterna (loop 40), apuntar con linterna y gritar "alto" (30), correr (loop 20),
esposar (40, con marcador "Esposado"), cubrirse con escudo (táctico, loop 30), golpe de escudo (20, Impacto).
JUGADOR (crimen): ser esposado de rodillas (40), manos arriba rindiéndose (loop 30), cargar bolsa de
botín al hombro (caminar loop 32 y correr loop 20, más lento), tirar la bolsa (15), taladrar o vigilar el
taladro (loop 60), hackear cámara o cajero con la laptop (loop 40), intimidar (señalar y avanzar, 25),
carterista (meter la mano en un bolsillo, 20), forzar una puerta (loop 40), sacarse y ponerse la máscara (30).
PANDILLAS: apoyado en la pared fumando sin cigarrillo (loop 90), emboscada (saltar de un techo bajo, 25).
Cierre igual que el Prompt 26: exportá a linajes/arte/animaciones/calle/<nombre>.fbx, commit y push.
Después, en Studio, importá cada una con el Animation Editor y decime cuáles tengo que publicar yo.
```

---
[[P29 Animaciones de NPCs y enemigos|← P29 Animaciones de NPCs y enemigos]]   ·   [[Todos los prompts]]   ·   [[P30 Animaciones de objetos|P30 Animaciones de objetos →]]
