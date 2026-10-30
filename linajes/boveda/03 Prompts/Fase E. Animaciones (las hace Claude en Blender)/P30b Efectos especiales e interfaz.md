---
tags: [prompt]
prompt: "30b"
estado: pendiente
---
# Prompt 30b Efectos especiales e interfaz (por código en Studio)

Antes de pegarlo: Studio abierto con el place de Linajes, `rojo serve linajes/linajes.project.json` corriendo, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Colores]] · [[Animaciones (plan completo)]]

```
Leé las secciones 2, 3, 4 (columna Efecto), 13 y 14 de la nota "Animaciones (plan completo)" de la bóveda.
Todo por código, en linajes/src/client/efectos/ (un módulo por tema) con plantillas en ReplicatedStorage
y números en Config.luau. Un solo bucle del cliente para lo que se mueve siempre, pausado si no se ve.

1. EFECTOS GENERALES: golpe, crítico, bloqueo, parry, hit-stop de 0,05 s, sacudida de cámara (3 fuerzas),
   zona roja de Aviso, curarse, subir de nivel, Despertar, aparecer, teletransporte, polvo, charcos, vapor,
   humo, explosión chica y grande, vidrios. Se disparan desde el marcador Impacto de la animación.
2. EFECTOS DE LOS 3 PRIMEROS LINAJES (Fuerza Bruta, Reflejos, Piroquinesis), uno por habilidad.
3. CARA: cambiar expresiones, parpadeo al azar y boca que se mueve al hablar.
4. INTERFAZ: botones, ventanas, barras con rastro, recargas, números de daño, nivel, nodos del árbol,
   "???" que se revela, máquina de escribir, ruleta (frena y rebota, destello del color de la rareza).
5. CALIDAD: opción Alto/Bajo en Ajustes; en celular arranca en Bajo (mitad de partículas, sin luces).
Probá cada efecto con Play en compu y en el emulador de celular. Leé la consola: sin errores.
Captura de cada grupo, mostramelas y esperá mi OK. Commit y push.
```
Para cada Linaje nuevo se repite el punto 2 con sus 3 habilidades, sus Variantes y su definitiva.

---
[[P30 Animaciones de objetos|← P30 Animaciones de objetos]]   ·   [[Todos los prompts]]   ·   [[P31 Sonidos de combate y menús|P31 Sonidos de combate y menús →]]
