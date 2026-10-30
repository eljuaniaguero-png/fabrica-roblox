---
tags: [prompt]
prompt: "38c"
estado: pendiente
---
# Prompt 38c Calle viva: civiles, testigos, policía y vigilancia

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé la sección "Calle viva" de linajes/ideas/ficha.md. Todo lo decide el servidor, números en Config.luau.
1. CIVILES: spawner por barrio con densidad según ciudad y hora (Corona de día 40 civiles cerca del
   jugador, Vórtice 15, Puerto 20), ropa armada al azar con el kit del Prompt 20d. Caminan por puntos de
   vereda (Parts con tag "Vereda"), se van a casa y vuelven (no aparecen de la nada delante de un jugador).
   Máximo 60 civiles activos por servidor, solo cerca de jugadores.
2. TESTIGOS: un crimen (cualquier acción con motivo de delito en Reputacion.Sumar) genera un evento con
   posición. Civiles con línea de vista a menos de 60 studs se asustan; el más cercano llama a la policía
   (animación del Prompt 29b, 4 s). Sin señal (subte, callejones) corre a un teléfono público o botón
   de alarma. Un héroe cerca puede protegerlo para que termine la llamada. Si termina: aviso con descripción (nombre de héroe si tenía máscara,
   "un civil" si no). Cortar la llamada: alejarse a más de 80 studs, gadget Interferidor, o Intimidar
   (solo jugadores de la Cofradía o Neutral; −10 reputación de ciudad). Tipos raros: valiente (5 %),
   curioso que filma (10 %, suma fama y crea material para El Faro), informante (5 %).
3. CÁMARAS (tag "Camara"): cono de 40 studs y 60°; si ven un delito, aviso inmediato. Hackear (minijuego
   5 s) las apaga 2 minutos; romperlas también es delito.
4. BÚSQUEDA (sigue el Prompt 38b): estrellas por ciudad con la escalera de la ficha (1 patrullero,
   2 patrullas, 3 tablero + drones, 4 Unidad Táctica + helicóptero + cortes de ruta en puentes y túneles,
   5 Escuadra Halcón + un héroe NPC). Nadie muere: los vencidos quedan "fuera de combate". Policía con IA simple: investigar el lugar, perseguir, esposar a corta distancia.
   Modo "buscando" cuando pierden la vista: zona de búsqueda visible en el mapa que se achica.
   Perder la búsqueda: sacarse la máscara sin testigos, guarida de la Cofradía, pagar a un contacto, o
   3 min por estrella sin delitos.
5. IDENTIDAD SECRETA: atributo "Enmascarado". Si un testigo te ve ponerte o sacarte la máscara, tu identidad
   queda expuesta en esa ciudad (los civiles te reconocen sin máscara).
6. ARRESTO: esposado → Penal Islaroca, pierde botín, dinero sucio y 15 % del dinero en mano. Salir: 2 min
   de tareas, fianza, minijuego de escape, o rescate de otro jugador. Policías corruptos en el puerto
   (coima si Contrabandistas ≥ 200).
7. JUGADORES POLICÍA: trabajo de Patrullero: radio con la lista de avisos (lugar, tipo, descripción),
   esposas, auto patrulla. Esposar a un NPC o jugador buscado le da reputación con la Policía.
8. NIVEL DE CRIMEN POR BARRIO (0 a 100): sube con delitos, baja al frenarlos, cambia cuántos crímenes NPC
   salen (carteristas, robo de autos, asaltos, cobro de protección, vendedores ilegales).
9. CALLEJONES PELIGROSOS (tag "Callejon"): emboscada al entrar (chance según nivel de crimen y hora),
   alijos, teniente; si lo vencen: luces arregladas y callejón seguro 30 min para todo el servidor.
Probá con 2 jugadores: uno roba un kiosco en Corona, un civil llama, sube a 3 estrellas y el otro, de
Patrullero, lo esposa. Commit y push.
```

---
[[P38b Reputación de ciudad, fama, búsqueda y territorios|← P38b Reputación de ciudad, fama, búsqueda y territorios]]   ·   [[Todos los prompts]]   ·   [[P38d Atracos|P38d Atracos →]]
