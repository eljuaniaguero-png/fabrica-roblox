---
tags: [prompt]
prompt: "38e"
estado: pendiente
---
# Prompt 38e Noticias de El Faro y teléfono

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé "Noticias de El Faro" en la sección "Calle viva" de linajes/ideas/ficha.md.
1. GENERADOR DE NOTICIAS: cada evento importante (atraco empezado o frenado, jefe vencido, jugador con
   5 estrellas, Variante descubierta, barrio que cambia de dueño, foto vendida) crea una noticia con
   plantillas de titular por tipo (al menos 6 plantillas por tipo, con nombres del juego). El tono cambia
   con la reputación con la Prensa del protagonista (favorable, neutro, en contra).
2. DÓNDE SE VE: Último momento = cartel arriba de la pantalla 6 s + pantallas gigantes de Corona (SurfaceGui).
   Portada del día (3 más famosos, mejor atraco, mejor captura, sumando todos los servidores con
   MemoryStore) = kioscos, diarieros, teléfono. Buscados con imagen del personaje del juego (ViewportFrame) en carteles
   de la comisaría y de la calle. Barrios y rumores en el teléfono y en la TV de los bares.
3. EFECTOS: "Ola de crimen en [barrio]" → +50 % policía ahí la hora siguiente; "[héroe] salva [lugar]" →
   +reputación de ciudad al héroe; villano en portada → +25 % a su recompensa.
4. REPORTERO: con la cámara del trabajo de Lucía Vega, una foto vale si el delito o la pelea está en cuadro
   y a menos de 30 studs; El Faro la compra según la fama de los que salen y la publica con el nombre del
   fotógrafo.
5. TELÉFONO (botón en el HUD y tecla T): Mapa (barrios por color, estaciones, avisos), Noticias, Contactos
   (llamar a NPCs con confianza ≥ 100 para pedir ayuda o pistas), Tablero de recompensas, Mensajes de NPCs.
   Mismo estilo del Prompt 33.
Probá: robá la joyería, que salga en Último momento, que el héroe que lo frena salga en la portada.
Commit y push.
```

---
[[P38d Atracos|← P38d Atracos]]   ·   [[Todos los prompts]]   ·   [[P39 Prólogo tu origen y la Noche del Eclipse|P39 Prólogo tu origen y la Noche del Eclipse →]]
