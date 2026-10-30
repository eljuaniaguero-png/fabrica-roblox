---
tags: [prompt]
prompt: "41"
estado: pendiente
---
# Prompt 41 El Narrador: ganchos e hilos (la historia viva)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé la sección 0f de linajes/ideas/ficha.md. Todo en el servidor, números en Config.luau.
1. DATOS DEL JUGADOR (ProfileStore, por espacio): hilos activos (máx. 2 impuestos + los que pidió), ganchos
   vistos, rivales (máx. 5, cada uno con nombre, qué pasó la última vez, mejora nueva), deudas y favores con
   otros jugadores, pactos, Fragmentos de verdad (de 40), Revelaciones vistas (de 8), capítulos de Tu crónica.
2. GANCHOS: módulo Narrador.luau con una lista de ganchos en linajes/src/shared/Historia/Ganchos/*.luau
   (datos, no código). Cada gancho tiene: condiciones (origen, reputaciones, Rasgos, Linaje, nivel, ciudad,
   hora, rivales, hechos recientes, jugadores cerca), peso, forma de llegar (llamada al teléfono, NPC que te
   para en la calle, nota en el refugio, emboscada, noticia de El Faro), hilo que abre, vencimiento y qué pasa
   si vence. Al lanzar: al menos 20 ganchos de los 6 tipos de la ficha.
3. RITMO: cada 8 a 12 minutos de juego activo el Narrador elige un gancho entre los que cumplen condiciones
   (al azar con pesos, sin repetir los últimos 10). Si el jugador peleó más de 5 minutos seguidos, prefiere
   uno tranquilo (charla, trabajo, pista). Nunca más de 2 hilos impuestos a la vez. El jugador puede pedir
   uno llamando a un contacto, en La Gárgola o en El Faro.
4. HILOS: definidos como datos en linajes/src/shared/Historia/Hilos/*.luau: pasos (hablar con, ir a, vencer,
   proteger, seguir sin ser visto, conseguir, elegir a ciegas), variables a llenar (civil, barrio, pandilla,
   objeto, rival) y consecuencias (reputación, confianza, rival nuevo, Fragmento, favor, ganchos nuevos).
   Al lanzar: 10 plantillas armadas por el sistema (después llegan a 40) + los hilos hechos a mano.
5. RIVALES: cuando un enemigo con nombre escapa, lo dejás ir o sale del penal, se agrega a tus rivales con
   una mejora al azar de una lista (implante, banda, cicatriz) y vuelve en un gancho con una frase sobre la
   última vez. Con 3 encuentros, puede ofrecer un trato.
6. EL MISTERIO: 40 Fragmentos (lista en Config con dónde puede salir cada uno); cada 5 se dispara una
   Revelación (escena corta). Tablero de pistas en el teléfono: unir 3 fragmentos correctos adelanta una.
7. GANCHOS ENTRE JUGADORES: si dos jugadores cumplen condiciones opuestas en el mismo lugar, el mismo
   gancho les llega a los dos desde lados distintos. Deudas: si un jugador te ayuda en un hilo, queda un
   favor que puede cobrar con un gancho. Rival jugador: si otro jugador te vence o te arruina un hilo,
   puede volverse tu rival (los dos reciben ganchos).
8. TU CRÓNICA: cada consecuencia importante escribe una línea con plantillas de texto; cada 5 líneas se
   cierra un capítulo con título. Pantalla en el teléfono, botón para compartir.
Probá con 2 jugadores de orígenes distintos durante 30 minutos: anotá qué ganchos les tocaron a cada uno
y mostrame que fueron distintos. Commit y push.
```

---
[[P40 Tecnología e implantes|← P40 Tecnología e implantes]]   ·   [[Todos los prompts]]   ·   [[P41a Primer hilo hecho a mano Los muelles rojos|P41a Primer hilo hecho a mano Los muelles rojos →]]
