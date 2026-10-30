---
tags: [prompt]
prompt: "20c"
estado: pendiente
---
# Prompt 20c Mapa del mundo abierto (graybox, antes de los kits)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé la sección 0d de linajes/ideas/ficha.md y linajes/arte/GUIA-ESTILO.md.
En Roblox Studio (no en Blender), armá el MAPA COMPLETO en bloques grises, sin detalle, para probar
tamaños y recorridos antes de modelar:
1. Mapa de 4.000 x 4.000 studs con una bahía en el centro. Alrededor de la bahía:
   - Ciudad Vórtice (noroeste, 1.200 x 1.200): manzanas de 80 x 80 con edificios de 40 a 120 studs de alto,
     callejones, azoteas conectadas para saltar.
   - Distrito Corona (noreste, 1.200 x 1.200): avenidas anchas, rascacielos de 150 a 300 studs, costanera.
   - Puerto Óxido (sur, 1.200 x 1.000): muelles, galpones bajos, grúas, contenedores.
   - Penal Islaroca: isla en el medio de la bahía, 300 x 300.
   - Cráter del Eclipse (oeste, fuera de las ciudades): cráter de 600 studs de diámetro con cristales.
   - Entrada a la Ciudad Hundida: bajo el agua frente al puerto (solo el portal, cerrado).
2. Cada ciudad partida en 5 BARRIOS con nombre, cada uno una carpeta con un Part invisible que marca su
   área (atributos Ciudad y Barrio), para reputación, crímenes y territorios.
3. Conexiones: autopista Vórtice-Corona, puente Corona-Puerto, túnel Puerto-Vórtice, ferry al penal.
   Estaciones de subte (2 por ciudad) y muelles de ferry marcados con Parts con el tag "Estacion".
4. Puntos de aparición de los 6 orígenes repartidos entre las 3 ciudades (2 por ciudad), con tag "Origen".
5. StreamingEnabled en Workspace, StreamingTargetRadius 512, niebla distinta por ciudad.
6. Ciclo de día y noche de 24 minutos (en Vórtice siempre es de noche por el eclipse).
Probá: cruzar de una ciudad a otra a pie y con vuelo; decime cuánto tarda cada recorrido.
Commit "Linajes: mapa graybox del mundo abierto" y push. Mostrame una captura desde arriba.
```

---
[[P20e Vehículos y objetos de la calle viva|← P20e Vehículos y objetos de la calle viva]]   ·   [[Todos los prompts]]   ·   [[P21 Puerto Óxido|P21 Puerto Óxido →]]
