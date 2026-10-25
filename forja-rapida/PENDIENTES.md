# Forja Rápida · Pendientes

Se hacen de a uno, en orden. Cuando un pedido dice "Prompt: X de PROMPTS-SECTORES.md", se usa el texto de ese prompt (con sus Reglas y "Cómo se hacen las animaciones").

## Sectores 25/10

- [x] ~~**D1 · Diagnóstico lado a lado** (no cambia nada)~~ hecho 25/10
  - Qué se hace: capturas del juego con las mismas cámaras que 9 referencias, lado a lado, y tabla de diferencias ordenada por lo que más se nota (luz, colores, studs, tamaños, fondo, HUD).
  - Qué hacés vos: abrir Studio con Forja Rápida y conectar Rojo. Mirar la tabla.
  - Cómo lo pruebo: Play por MCP, capturas en `arte/comparaciones/diagnostico-<n>.png`.
  - Prompt: D1 de PROMPTS-SECTORES.md

- [x] ~~**D2 · Luz y cielo** (reemplaza al prompt A de "mapa como la referencia" del 18/10)~~ hecho 25/10 (falta probar en emulador de celular)
  - Qué se hace: estilo de luz "Referencia" (tu luz queda guardada como "Juani"), cielo celeste de dibujo con nubes y 2 arcoíris de bloques lejos.
  - Qué hacés vos: Blender abierto para el arcoíris; si hay que subir las caras del cielo, te digo qué botón tocar.
  - Cómo lo pruebo: Play, lado a lado con estilo-1, mapa-3 y lobby-2 hasta 3 veces; eventos que tiñen la luz siguen andando.
  - Prompt: D2 de PROMPTS-SECTORES.md

- [ ] **D3 · Colores, studs y materiales de todo el mapa**
  - Qué se hace: colores medidos de las referencias en `GameConfig.Paleta`, studs del tamaño y contraste de la referencia en todo lo opaco, sin brillos de plástico. Lista de proporciones para que la apruebes.
  - Qué hacés vos: aprobar la lista de tamaños antes de que los cambie.
  - Cómo lo pruebo: lado a lado de Pradera, Dunas, Glaciar y lobby.
  - Prompt: D3 de PROMPTS-SECTORES.md

- [ ] **E1 · Bordes cerrados en todo el mapa**
  - Qué se hace: paredes altas con "cresta" de pasto y árboles, anillo de terreno afuera, piso de abajo, paredes invisibles y vuelta al último lugar seguro; lobby cerrado.
  - Qué hacés vos: nada (solo mirar).
  - Cómo lo pruebo: capturas desde 8 puntos por zona con zoom máximo, antes y después; FPS en emulador de celular; copia .rbxl.
  - Prompt: E1 de PROMPTS-SECTORES.md

- [ ] **E2 · La zona siguiente se ve atrás** (solo si después de E1 todavía hace falta)
  - Qué se hace: escalón entre zonas y montañas de fondo (prompt C de "mapa como la referencia" del 18/10).
  - Qué hacés vos: decirme si querés hacerlo después de ver E1.
  - Cómo lo pruebo: lado a lado con mapa-1 y mapa-3.
  - Prompt: E2 de PROMPTS-SECTORES.md

- [ ] **A1 · Correr con Shift en vez del dash**
  - Qué se hace: se saca el dash; Shift (L3 en joystick, botón zapatilla en celular) = correr ×1,6, con FOV y polvo. El servidor controla la velocidad.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: caminar, correr, saltar corriendo, con bonos, celular, y 2 jugadores en Local Server.
  - Prompt: A1 de PROMPTS-SECTORES.md

- [ ] **B1 · Animación de correr** (necesita A1)
  - Qué se hace: animación de Roblox propia, estilo caricatura, ≥ 10 poses, con arranque, frenada y markers de pisada (polvo y sonido según el piso).
  - Qué hacés vos: publicar la animación si no puedo hacerlo yo (te paso los botones).
  - Cómo lo pruebo: tiras de 8 capturas (costado, frente, cámara lenta) y lado a lado en el juego.
  - Prompt: B1 de PROMPTS-SECTORES.md

- [ ] **B2 · Animación de picar**
  - Qué se hace: golpes A, B y C fuerte de cuerpo entero, guardia y pico al hombro; reemplaza el giro de brazo por código. Estela y temblor en el "Impacto". Anda con los 5 picos.
  - Qué hacés vos: publicar las animaciones si no puedo yo.
  - Cómo lo pruebo: 3 tiras de capturas, lado a lado con estilo-4, celular y 2 jugadores.
  - Prompt: B2 de PROMPTS-SECTORES.md

- [ ] **B3 · Geoda para romper (modelo)**
  - Qué se hace: en Blender, cada geoda partida en pedazos de bloques más el interior con cristales, por zona.
  - Qué hacés vos: Blender abierto; aprobar el render; importar el .fbx si no puedo por MCP.
  - Cómo lo pruebo: render entera y "explotada" por zona.
  - Prompt: B3 de PROMPTS-SECTORES.md

- [ ] **B4 · Eclosión de la geoda (animación)** (necesita B3)
  - Qué se hace: 5 tiempos en el mundo (aviso, grieta, explosión, gema que sube con pilar de luz, cierre) y después La Forja como hoy. Versión corta para Común y para efectos reducidos.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: tiras por rareza (Común, Rara, Mítica), lado a lado con estilo-4, 5 geodas a la vez en celular.
  - Prompt: B4 de PROMPTS-SECTORES.md

- [ ] **F1 · Modelo del candado**
  - Qué se hace: en Blender, candado grande dorado con arco aparte, tramo de cadena y candado en pedazos.
  - Qué hacés vos: Blender abierto; aprobar el render; importar el .fbx si no puedo por MCP.
  - Cómo lo pruebo: render del candado puesto en un portón.
  - Prompt: F1 de PROMPTS-SECTORES.md

- [ ] **F2 · Candados en el juego y animación de abrir** (necesita F1)
  - Qué se hace: candado con cadenas en X y cartel "Necesitás X de Fuerza" en cada puerta cerrada, por jugador; al desbloquear se abre, cae y se rompe. También en puertas secretas y Santuario.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: jugador nuevo, subir la Fuerza con HerramientasPrueba, tira de capturas, celular y 2 jugadores con zonas distintas.
  - Prompt: F2 de PROMPTS-SECTORES.md

- [ ] **C1 · Modelo nuevo de la ruleta** (reemplaza al prompt 1 de "13 piezas" del 18/10: queda uno solo)
  - Qué se hace: ruleta grande de bloques en Blender: escenario con 24 luces, rueda con 8 gajos del tamaño de las chances, lengüeta, clavos, palanca, pedestal y cartel de chances.
  - Qué hacés vos: Blender abierto; aprobar el render; importar si no puedo por MCP.
  - Cómo lo pruebo: render de frente, 3/4 y lengüeta, lado a lado con lobby-1.
  - Prompt: C1 de PROMPTS-SECTORES.md

- [ ] **C2 · Animación de la ruleta** (necesita C1 en Studio)
  - Qué se hace: 6 tiempos (palanca, arranque, giro con tic-tic, suspenso, premio con confeti, la mascota salta a seguirte). El servidor decide antes; el cartel muestra las chances reales.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: muchas tiradas con HerramientasPrueba, chequear que el gajo coincida siempre con lo que entrega el servidor; tira de capturas, celular y 2 jugadores.
  - Prompt: C2 de PROMPTS-SECTORES.md

- [ ] **G1 · HUD v3 en Figma**
  - Qué se hace: página "v3 · Como las referencias" en tu archivo de Figma, con medidas, componentes y pantallas de compu y celular.
  - Qué hacés vos: aprobar el diseño (el conector de Figma ya está en esta PC).
  - Cómo lo pruebo: capturas de Figma al lado de cada referencia.
  - Prompt: G1 de PROMPTS-SECTORES.md

- [ ] **G2 · HUD v3 en el juego** (necesita G1 aprobado)
  - Qué se hace: el HUD del juego igual al de Figma, con la animación de botones; no cambia lo que hace cada botón.
  - Qué hacés vos: subir imágenes si no puedo por MCP.
  - Cómo lo pruebo: lado a lado Figma | juego | referencia, en compu y celular.
  - Prompt: G2 de PROMPTS-SECTORES.md

- [ ] **G3 · Menús con el mismo estilo** (necesita G2)
  - Qué se hace: los 11 menús con el estilo v3, de a uno, commit por menú.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: lado a lado Figma | juego por menú.
  - Prompt: G3 de PROMPTS-SECTORES.md

- [ ] **G4 · Repaso final contra las referencias**
  - Qué se hace: repetir el diagnóstico de D1, arreglar lo chico y sumar acá lo grande.
  - Qué hacés vos: nada.
  - Cómo lo pruebo: todo junto con 2 o 3 jugadores y emulador de celular; FPS, consola sin rojo, copia .rbxl.
  - Prompt: G4 de PROMPTS-SECTORES.md
