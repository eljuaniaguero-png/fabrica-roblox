---
tags: [prompt]
prompt: "38b"
estado: pendiente
---
# Prompt 38b Reputación de ciudad, fama, búsqueda y territorios

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé la sección 0d de linajes/ideas/ficha.md. Todos los números van en Config.luau. Todo lo decide el servidor.
1. DATOS (en el guardado de ProfileStore, por espacio): reputación con cada ciudad (−1000 a +1000),
   con cada bando (0 a 1000), con cada grupo (Policía, Prensa, Corona Corp, Pandillas, Contrabandistas:
   −500 a +500), confianza con cada NPC importante (0 a 500), fama (0 a 10.000),
   nivel de búsqueda por ciudad (0 a 5, NO se guarda: se reinicia al salir).
2. MÓDULO Reputacion.luau con una sola función para sumar: Reputacion.Sumar(jugador, motivo), donde
   motivo es una clave de la tabla de Config ("FrenarCrimen", "SalvarCivil", "Robar", "LastimarCivil",
   "RomperObjeto", "VencerBuscado", "AtacarInocente", "TerminarTrabajo", "TerminarArco"...), con los
   valores de la tabla de la ficha. La ciudad sale del barrio donde está el jugador (Parts del Prompt 20c).
   Los NPCs enemistados: subir confianza con uno baja con su rival (tabla en Config).
3. EFECTOS de la reputación de ciudad: Ídolo/Respetado/Desconocido/Temido/Enemigo público con los
   descuentos, tiendas que cierran, civiles que aplauden o huyen (animación), policía que te ataca y
   recompensa automática. Los diálogos (Prompt 38) pueden pedir cualquier reputación como condición.
4. FAMA: título sobre la cabeza que todos ven (BillboardGui) a partir de 1.000, elegido de una lista según
   lo que más hiciste (ej. "El Fantasma de Vórtice", "Azote del Puerto"); portada de El Faro con los 3
   jugadores con más fama del servidor.
5. BÚSQUEDA: crímenes suben estrellas en esa ciudad; bajan 1 cada 3 minutos sin crímenes o al entrar a una
   guarida de la Cofradía. Con 3 o más: aparece en el Tablero de recompensas; un jugador de la Liga o de los
   Vigilantes acepta el contrato y ve un círculo de 150 studs donde está el buscado. Si lo vence: el buscado
   pierde 15 % del dinero que lleva (nunca objetos), aparece en el Penal Islaroca y puede escaparse con un
   minijuego o con ayuda. Contratos del Albatros contra héroes con fama ≥ 3.000.
6. PVP: solo entre bandos enemigos, contra buscados o dentro del Cráter del Eclipse. En el resto, el daño
   entre jugadores es 0. Marcá en la interfaz quién te puede atacar (borde rojo en el nombre).
7. TERRITORIOS: cada acción suma puntos al bando del jugador en ese barrio (DataStore de conteo semanal,
   con MemoryStore para no pasar el límite de pedidos, actualizado cada 5 min). El bando con más puntos
   controla el barrio: cambian color de luces y carteles, qué crímenes salen y precios (−10 % para ese bando).
   Reinicio los lunes. El Faro muestra el estado.
8. PANTALLA "Reputación" en el menú (Prompt 33): barras con título y SIN números exactos para las
   3 ciudades, los 3 bandos (con rango), los 5 grupos, los NPCs (corazones) y la fama; mapa de barrios por color.
9. ARCOS: el NPC que abre cada arco solo te habla con reputación +100 o −100 en esa ciudad.
Probá con 2 jugadores: uno roba en Corona hasta tener 3 estrellas y el otro, de la Liga, lo caza.
Commit y push.
```

---
[[P38 Diálogos con NPCs, trabajos y reputación|← P38 Diálogos con NPCs, trabajos y reputación]]   ·   [[Todos los prompts]]   ·   [[P38c Calle viva civiles, testigos, policía y vigilancia|P38c Calle viva civiles, testigos, policía y vigilancia →]]
