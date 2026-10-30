# Forja Rápida · Prompts por sector (25/10/2026)

Correr en vez de dash, animaciones nuevas (correr, picar, eclosión de la geoda y ruleta), arte y luz como las referencias, que no se vea afuera del mapa, candados en las puertas y HUD nuevo diseñado en Figma.

## Cómo usarlo (Juani)

1. Abrí Roblox Studio con Forja Rápida, conectá Rojo (Plugins → Rojo → Connect) y, para los prompts de modelos, abrí Blender con el complemento de Claude.
2. En Claude Code, en `fabrica-roblox`, pegá primero el **Prompt 0**. Suma todos estos pedidos a tu lista `forja-rapida/PENDIENTES.md`, así el **Prompt 2 de ayer** ("hacer el próximo pedido") los va haciendo de a uno.
3. Si preferís ir directo a un sector, hacé `/clear` y pegá el prompt de ese sector. **Uno por sesión**, y esperá que te muestre las capturas antes del siguiente.
4. Si algo no te gusta: "Esto no me gusta: …" y lo arregla antes de seguir.

Una copia de este archivo está en tu PC en `forja-rapida/PROMPTS-SECTORES.md`. Todos los prompts le piden a Claude que lea la sección **Reglas** de ese archivo, así no se repiten en cada uno. También copié a `forja-rapida/arte/referencias/` las 3 referencias que te faltaban ahí (`lobby-1.png`, `lobby-2.png`, `mapa-4.png`).

### Lo que vi hoy en tu juego (por qué la luz se ve rara)

- **Luz:** el 19/10 el juego pasó a usar la luz que dejaste en Studio: **"Realistic Sky"** (cielo de foto) con **Ambient #464646** (sombras muy oscuras). La referencia es lo contrario: cielo de dibujo celeste con nubes gordas y arcoíris, sombras claras y colores muy saturados. Ese choque, un mundo de juguete con cielo y sombras de foto, es la "rareza". El sector D lo arregla y deja tu luz guardada como otro estilo, por si la querés volver a usar.
- **Dash:** hoy Shift (y Q) hace un envión con espera (`Dash.client.luau` y `server/Dash.luau`). El sector A lo cambia por correr.
- **Puertas entre zonas:** hoy son un campo de fuerza celeste (`GeneradorMapa`, tipo `PuertaZona`), sin candado.
- **Pico:** hoy se anima girando el brazo con código (`Golpes.client.luau`). No hay animaciones de Roblox de verdad en el juego.
- **Ruleta:** la nueva de los prompts de las 13 piezas todavía no está hecha (`Lobby.fbx` es del 17/10). El prompt C1 la reemplaza con una versión más ambiciosa.
- **HUD:** ya hay un archivo de Figma ("Forja Rápida · HUD y menús", figma.com/design/DZ114Em8TCx2WZPzRiPAeL) con v1 y v2. El sector G hace una v3 copiada de las referencias.
- **No encontré `PENDIENTES.md`** en tu carpeta, así que el Prompt 1 de ayer todavía no se usó. Si querés, pegá primero ese y después el Prompt 0 de acá.

### Orden recomendado

| # | Sector | Por qué en este orden |
|---|---|---|
| 1 | **D · Arte y luz** | Es lo que más cambia cómo se ve todo, y lo demás se juzga con la luz buena |
| 2 | **E · Bordes del mapa** | Va junto con el arte: es parte de "que no se vea raro" |
| 3 | **A · Correr** | Es corto y cambia cómo se juega |
| 4 | **B · Animaciones** (correr, picar, eclosión) | Necesita A hecho para la de correr |
| 5 | **F · Candados** | Modelo y animación chicos |
| 6 | **C · Ruleta** | Modelo grande y animación larga |
| 7 | **G · HUD en Figma** y después en el juego | Al final, para diseñar sobre el juego ya lindo |

---

## Reglas (Claude: leelas antes de cada prompt de este archivo)

```
REGLAS DE LOS PROMPTS POR SECTOR
1. Mandan CLAUDE.md y GUIA-PARA-CLAUDE.md. Nada de worktrees ni de setup/new-system de roblox-dev.
2. Antes de tocar nada: git status. Si hay cambios sin commit, decime qué son en 3 líneas y, si
   el juego arranca sin rojo en Play, commit. Después commit "antes de <pedido>".
3. MIRAR LAS REFERENCIAS ES OBLIGATORIO, no opcional. Están en forja-rapida/arte/referencias/
   (estilo-1..4, mapa-1..4, lobby-1..2, geodas-gemini.jpg y las capturas de pantalla).
   a) Antes de empezar, abrí con la herramienta de leer imágenes TODAS las referencias que nombra
      el prompt (no te alcanza con el nombre del archivo) y escribime 8 a 12 observaciones
      concretas: colores, tamaños relativos, grosores de borde, cuánto se ven los studs, qué hay
      de fondo, cómo cae la luz.
   b) Los colores no se adivinan: medilos con un script de Python (promedio de un cuadrado de
      9 x 9 px en varias partes de la imagen) y anotá los hex que uses en GameConfig.
   c) Al terminar, sacá capturas del juego con la MISMA cámara que la referencia (misma altura,
      mismo ángulo, mismo encuadre) y armá una imagen lado a lado (referencia | juego) en
      forja-rapida/arte/comparaciones/<pedido>-<n>.png.
   d) Con eso, haceme una tabla de diferencias (qué, cómo está, cómo debería estar). Corregí y
      repetí c) y d) hasta 3 veces. Pará cuando las diferencias que quedan sean de detalle, y
      decime cuáles quedaron y por qué (por ejemplo, límite de Roblox o del celular).
   e) Se copia el ESTILO, no el contenido: nada de nombres, personajes ni logos de ese juego.
4. El servidor decide todo (validá tipos, distancia, frecuencia). Números, IDs de assets y de
   animaciones en GameConfig.luau. Piezas con función marcadas con tags o atributos.
5. Studs siempre como textura (MaterialVariant), nunca como geometría. Triángulos según la GUIA,
   sección 5. Guardá el .blend antes de cada cambio grande en Blender.
6. Animaciones: ver la sección "Cómo se hacen las animaciones" de este archivo.
7. Celular: todo se prueba también en el emulador de celular de Studio y tiene que andar a 30 FPS
   o más en un celular medio. Respetá "Efectos reducidos" de Ajustes.
8. Si algo me toca a mí (publicar una animación, importar un .fbx, subir una imagen), primero
   probá hacerlo vos por MCP; si no se puede, decime exactamente qué botón tocar, uno por uno.
9. Nada con Robux. Si un pedido cambia lo que se guarda, subí VERSION en Guardado.luau con su
   migración. Si cambia la economía, plan con números primero y esperá mi "dale".
10. Al terminar: Play por MCP con consola sin rojo, capturas en compu y celular, la imagen lado a
   lado, commit en español, actualizar ideas/forja-rapida.md, tachar el pedido en PENDIENTES.md
   y copia .rbxl en backups/ si cambió el mundo.
```

## Cómo se hacen las animaciones (Claude: leelo antes de los sectores B, C y F)

```
CÓMO SE HACEN LAS ANIMACIONES EN FORJA RÁPIDA
- Personaje (correr, picar, festejar): animaciones de Roblox DE VERDAD, no giros de código.
  1) Fijate si el juego usa R15 o R6 (StarterPlayer y un personaje en Play) y hacelas para ese.
  2) Armalas vos por MCP como KeyframeSequence (Pose por hueso, con EasingStyle y
     EasingDirection en cada pose), guardadas en ServerStorage/Animaciones/<Nombre>.
     También dejá el script que las genera en forja-rapida/src/... o en arte/animaciones/ para
     que vivan en git.
  3) Para probarlas en Studio usá KeyframeSequenceProvider:RegisterKeyframeSequence (anda solo
     en Studio). Para el juego publicado hay que publicarlas: probá hacerlo vos; si no se puede,
     decime los pasos (Animation Editor → elegir el rig → Importar desde ServerStorage → ⋯ →
     Publish to Roblox) y después anotá el ID en GameConfig.Animaciones.
  4) Calidad que quiero ("muy complejas y muy buenas"): los 12 principios de animación.
     Anticipación antes de cada acción, aplastar y estirar donde se pueda, acción secundaria
     (cabeza, brazo libre, cadera), superposición (las partes no frenan todas a la vez),
     arcos en vez de líneas rectas, entradas y salidas suaves con EasingStyle distinto por pose,
     pesos claros (el cuerpo baja cuando pega fuerte). Nada de poses que atraviesen el cuerpo.
     Como mínimo 10 poses clave por ciclo en correr y 8 por golpe en picar.
  5) KeyframeMarkers en los momentos importantes ("Pisada", "Impacto", "Fin") para que los
     efectos y sonidos salgan justo ahí (GetMarkerReachedSignal).
  6) Prioridad: correr = Movement, picar = Action. Que se mezcle bien con caminar, saltar y
     quedarse quieto (sin saltos de pose; FadeTime 0,1 a 0,2).
  7) Mostrame cada animación con una tira de 8 capturas en secuencia, de costado y de frente,
     a velocidad normal y en cámara lenta (AdjustSpeed 0,25).
- Objetos (geoda, ruleta, candado): TweenService y código en el cliente, con la misma regla de
  calidad (anticipación, rebote, superposición). Lo que ve todo el servidor lo dispara el
  servidor con un remoto; el resultado lo decide siempre el servidor ANTES de animar.
- Efectos: ParticleEmitter, Beam, Trail, Highlight y luces, del color de la zona o la rareza.
  Pocas partículas en celular. Sonido sincronizado con los markers.
```

---

## Prompt 0 · Sumar todo a la lista

```
Juego: Forja Rápida (carpeta forja-rapida/). Leé forja-rapida/PROMPTS-SECTORES.md entero
(sobre todo las secciones "Reglas" y "Cómo se hacen las animaciones").
Si existe forja-rapida/PENDIENTES.md, agregale al final una sección "Sectores 25/10" con un
pedido por cada prompt de ese archivo (D1, D2, D3, E1, E2, A1, B1, B2, B3, B4, F1, F2, C1, C2,
G1, G2, G3, G4), en ese orden, cada uno con: qué se hace, qué tengo que hacer yo, cómo lo vas a
probar, y "Prompt: <código> de PROMPTS-SECTORES.md". Si un pedido de la lista vieja hace lo
mismo (por ejemplo la ruleta de las 13 piezas o la luz), uní los dos y dejá uno solo.
Si PENDIENTES.md no existe, crealo solo con estos pedidos.
Mostrame la lista y PARÁ. No arranques nada hasta que te diga "dale".
```

Después, para avanzar: `/clear` y el **Prompt 2** de `PROMPT-TERMINAR.md`. Cuando el pedido diga "Prompt: X de PROMPTS-SECTORES.md", Claude usa el texto de ese prompt.

---

## Sector D · Arte y luz como las referencias

### D1 · Diagnóstico lado a lado (no cambia nada)

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md.
El arte del juego "sigue siendo raro" y la luz también. Antes de cambiar nada quiero saber
exactamente por qué.
1) Abrí y mirá con atención estilo-1, estilo-2, estilo-4, mapa-1, mapa-2, mapa-3, mapa-4,
   lobby-1 y lobby-2 de arte/referencias/.
2) En Play por MCP, sacá capturas del juego con las mismas cámaras: entrada de la Pradera
   mirando hacia el fondo (como estilo-1), Dunas (estilo-2), vista alta de un pasillo (mapa-4),
   lobby con parcelas (lobby-2), un puesto de venta de cerca (lobby-1) y una geoda de cerca
   (estilo-4).
3) Armá las imágenes lado a lado en arte/comparaciones/diagnostico-<n>.png.
4) Haceme una tabla por categoría con lo que está distinto y qué lo causa (propiedad, archivo,
   valor): luz y cielo; colores (medidos); materiales y studs (tamaño, contraste, brillo);
   tamaños y proporciones (geodas, árboles, paredes, personaje); densidad de decoración;
   fondo y horizonte; carteles flotantes; HUD.
5) Ordená las diferencias de la que más se nota a la que menos, y decime cuáles arreglan D2,
   D3, E1 y G, y si alguna no entra en ninguno.
Fijate en especial: hoy Iluminacion.luau usa el estilo con "Realistic Sky" y Ambient #464646
(CieloDeFabrica = false). La referencia tiene cielo de dibujo con nubes y arcoíris, sombras
claras y colores muy saturados.
No cambies nada. Mostrame las imágenes y la tabla y esperá.
```

### D2 · Luz y cielo

Reemplaza al prompt A del archivo "mapa como la referencia" del 18/10.

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md y lo que salió en D1.
Quiero la luz y el cielo IGUAL que en estilo-1, mapa-1, mapa-3 y lobby-2.
1) En GameConfig.Luz.Estilos dejá el estilo actual como "Juani" (no lo borres) y creá
   "Referencia". Elegido = "Referencia".
2) Arrancá con estos valores y ajustalos comparando lado a lado (Reglas, punto 3):
   - Lighting: Technology ShadowMap, ClockTime 13,5, Brightness 2,5 a 3,
     Ambient #9A9A9A, OutdoorAmbient #B4B4B4 (la referencia casi no tiene sombras negras),
     EnvironmentDiffuseScale 0,4, EnvironmentSpecularScale 0,1 (sin brillos de plástico),
     GlobalShadows true, ShadowSoftness 0,15, ExposureCompensation 0,1.
   - ColorCorrection: Saturation 0,3, Contrast 0,08, Brightness 0,03, Tint blanco.
   - Bloom: Intensity 0,4, Size 20, Threshold 1,6 (solo brilla el Neon).
   - Atmosphere: Density 0,28, Offset 0,05, Color #CFE8FF, Decay #A7D3FF, Glare 0, Haze 1,2
     (el fondo se aclara y se pone celeste lejos, como en mapa-1).
   - SunRays apagados o casi (0,02).
3) Cielo: sacá el "Realistic Sky". Quiero cielo celeste fuerte (medilo en estilo-1 arriba) con
   nubes blancas gordas tipo algodón. Opciones, en orden: a) un Sky con texturas de cielo de
   dibujo (CelestialBodiesShown false); si no hay uno que se vea como la referencia, b) armá
   las 6 caras del Sky vos (degradé celeste + nubes dibujadas) con un script de Python en
   arte/texturas/cielo/ y decime cómo las subo; c) nubes 3D de bloques blancos en el fondo,
   fuera del alcance del jugador.
4) Arcoíris como en estilo-1 y mapa-3: 2 arcos de bloques de colores (rojo, naranja,
   amarillo, verde, celeste, violeta) con nubes en las puntas, muy lejos y altos, uno a cada
   lado del pasillo. Modelo en Blender (Arcoiris_Nubes, ≤ 3.000 triángulos), sin colisión,
   Material Neon apagado o SmoothPlastic con colores bien saturados.
5) Los eventos que tiñen la luz tienen que seguir andando.
Probalo con Play: capturas y lado a lado con estilo-1, mapa-3 y lobby-2. Repetí hasta 3 veces.
Si te lo apruebo, commit "luz y cielo como la referencia".
```

### D3 · Colores, studs y materiales de todo el mapa

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md y la tabla de D1.
Con la luz nueva (D2), quiero que las superficies se vean como la referencia.
1) Medí con un script los colores de las referencias: pasto cerca y lejos (estilo-1 y lobby-2),
   paredes de ladrillo de la Pradera (estilo-1, terracota), arena y paredes de Dunas (estilo-2),
   nieve y piso rosa (mapa-4), caminos naranjas y madera (lobby-2), troncos y copas de árboles,
   cactus. Escribilos en GameConfig.Paleta con nombre.
2) Studs como la referencia: en estilo-1 y lobby-2 cada stud se ve como un cuadradito con un
   borde apenas más oscuro, bien parejo, chico respecto del personaje (unos 4 por cada ancho de
   hombros). Compará el tamaño y el contraste de tu MaterialVariant Studs_Liso y de los pisos
   y ajustalos (StudsPerTile y la textura) hasta que coincidan en la captura lado a lado.
3) Que TODO lo opaco use studs: piso, paredes, árboles, rocas, cercas, puestos, geodas y nido,
   como dice la guía de estilo del 18/10. Listame las piezas que hoy no los tienen y arreglalas.
4) Sacá lo que hace ver "raro" comparado con la referencia: brillo de plástico
   (Reflectance 0, Material sin specular), grises apagados, colores sin saturar, transparencias
   que no están en la referencia, Neon donde la referencia no brilla.
5) Proporciones: compará con el personaje el tamaño de geodas, árboles, cactus, paredes y
   puestos en estilo-1, estilo-2 y lobby-1, y decime qué está más chico o más grande. No lo
   cambies sin mostrarme antes la lista.
Capturas lado a lado de Pradera, Dunas, Glaciar y lobby. Si te lo apruebo, commit
"colores y studs como la referencia". Si falta decoración, usá el prompt E del archivo
"mapa como la referencia" del 18/10 (forja-rapida/arte/ o pedímelo).
```

---

## Sector E · Que no se vea afuera del mapa

### E1 · Bordes cerrados en todo el mapa

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md.
Quiero que desde ningún lugar se vea "afuera del mapa": ni el vacío, ni el borde del piso, ni
la placa base, ni piezas sueltas, ni el cielo por debajo del horizonte.
Mirá cómo lo hace la referencia (estilo-1, mapa-1, mapa-2, mapa-4): cada zona es un pasillo
encerrado entre paredes altas de ladrillo con pasto y árboles arriba (la "cresta"); detrás de
la cresta hay más pasto con árboles que se pierden en la neblina celeste, y adelante se ve la
zona siguiente más alta. Nunca se ve un borde.
1) Revisión primero: en Play, recorré el borde de cada zona y del lobby y sacá capturas desde
   8 puntos por zona (las 4 esquinas, el medio de cada pared), con la cámara alejada al máximo
   y mirando hacia afuera y hacia arriba. Marcame cada lugar donde se ve afuera.
2) Arreglo, en mapa.py / GeneradorMapa (cambio mínimo, que quede en git):
   - Paredes de cada zona y del lobby con altura suficiente para que con el zoom máximo no se
     vea por encima (calculalo con CameraMaxZoomDistance). Si hace falta, bajá
     CameraMaxZoomDistance (por ejemplo 40) y decime el número.
   - "Cresta" arriba de cada pared: franja de pasto de 30 a 60 studs de ancho con árboles de
     Deco_ZonaN en grupos, como en mapa-4.
   - Afuera: un anillo de terreno decorativo (meseta de pasto o arena o nieve según la zona,
     con árboles y rocas) hasta donde la Atmosphere ya lo tapa. Sin colisión, anclado,
     CanQuery false, pocos triángulos (puede ser muy simple lejos).
   - Lo que esté abajo del mapa: un piso de color de la zona muy abajo, así nunca se ve el vacío.
   - Paredes invisibles arriba de las paredes y de la cresta para que no se pueda salir ni
     trepar; si alguien se cae, vuelve al último lugar seguro.
   - Lobby: cerrado como lobby-2 (paredes altas de studs color durazno) con el arco a la
     Pradera como única salida.
3) Rendimiento: StreamingEnabled ya está; marcá el anillo de afuera como decoración de bajo
   detalle (RenderFidelity Performance, sin sombras) y medí FPS en el emulador de celular.
Repetí las capturas de los 8 puntos por zona y mostrame que ya no se ve afuera, más el lado a
lado con mapa-1 y mapa-4. Si te lo apruebo, commit "bordes cerrados" y copia .rbxl.
```

### E2 · La zona siguiente se ve atrás

Solo si después de E1 todavía no se ve la zona siguiente como en `mapa-1` y `mapa-3`. Usá el **prompt C** del archivo "mapa como la referencia" del 18/10, que ya hace eso (escalón entre zonas y montañas de fondo).

---

## Sector A · Correr con Shift en vez del dash

### A1 · Sacar el dash y poner correr

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md.
Quiero sacar el dash y que Shift sea CORRER.
Hoy: client/Dash.client.luau (Shift, Q o botón B: envión de GameConfig.Dash.Distancia con
espera), server/Dash.luau (revisa la espera) y Golpes.client usa el atributo "UltimoDash" para
que el primer golpe suene más fuerte. Server/Velocidad.luau pone el WalkSpeed según
GameConfig.Velocidad y los bonos (Paso Ligero, Brasita).
Cómo lo quiero:
1) Compu: mantener Shift = correr; soltar = caminar. Joystick: apretar el stick izquierdo
   (L3). Celular: un botón redondo con ícono de zapatilla, del estilo del HUD (Estilo.luau),
   que se prende y se apaga (toggle) y se pone de color cuando está prendido. Que no tape el
   salto ni el joystick.
2) Velocidad al correr = velocidad de caminar del jugador × GameConfig.Correr.Multiplicador
   (arrancá con 1,6). Los bonos se siguen sumando y el tope GameConfig.Velocidad.Maxima se
   aplica a caminar; elegí un tope para correr y anotalo.
3) Sin barra de energía (es lo más simple). Si al probar ves que correr rompe algo (por ejemplo
   llegar demasiado rápido a las geodas de otros), decímelo y vemos.
4) No se corre mientras está abierta La Forja (atributo EnForja) ni con un menú que bloquee.
5) Al empezar a correr: un FOV que sube apenas (70 → 78, tween 0,25 s) y una estela de polvo
   chiquita en los pies cada tanto (del color del piso de la zona). Respetá "Efectos reducidos".
6) Servidor: el cliente avisa "corro / no corro" con un remoto, con límite de frecuencia; el
   servidor guarda el estado y es el que dice la velocidad permitida (atributo en el jugador).
   Sumá un control simple: si un jugador se mueve más rápido que lo permitido de forma
   sostenida (medido cada 1 s, con margen), se lo vuelve a la última posición buena.
7) Sacá Dash.client.luau, server/Dash.luau, Remotos.Dash, GameConfig.Dash y lo de
   "UltimoDash" en Golpes. Si alguna pantalla, tutorial o la ficha habla del dash, cambialo a
   correr. El botón B del joystick queda libre.
8) La animación de correr la hace B1; por ahora usá la de Roblox.
Probalo en Play: caminar, correr, soltar, saltar corriendo, correr con bonos, celular con el
botón, y con 2 jugadores en Local Server que el otro te vea correr. Commit "correr en vez de
dash" y actualizá la ficha.
```

---

## Sector B · Animaciones

### B1 · Correr

```
Juego: Forja Rápida. Leé las Reglas y "Cómo se hacen las animaciones" de
forja-rapida/PROMPTS-SECTORES.md. Necesita A1 hecho.
Quiero una animación de correr propia, muy buena y con mucha personalidad, para el
personaje del jugador. Estilo: caricatura con energía, como un personaje de juego de
plataformas, no realista.
- Ciclo de 0,5 a 0,6 s a la velocidad de correr (que los pies no patinen: medí cuánto avanza
  por ciclo y ajustá la velocidad de la animación con AdjustSpeed según la velocidad real).
- Cuerpo inclinado hacia adelante 12 a 15°, la cadera sube y baja (punto más bajo al pisar,
  más alto en el vuelo), la cadera gira un poco contra los hombros.
- Brazos en arco, codos doblados; si tiene el pico en la mano, el brazo del pico va más quieto
  y el pico se balancea con retraso (superposición).
- La cabeza estable, con un pequeño rebote atrasado.
- Pisada con aplastar y estirar sutil en la pierna de apoyo.
- Markers "Pisada_Izq" y "Pisada_Der": polvo chiquito del color del piso y sonido de pisada
  según el piso (pasto, arena, nieve, piedra, cristal).
- Transiciones: arranque (2 o 3 pasos de aceleración con el cuerpo más inclinado), frenada
  (derrape corto con polvo si venía corriendo más de 1 s) y salto desde correr.
Reemplazá la animación "run" del Animate por defecto solo mientras corre (caminar sigue con la
de Roblox o con una nueva si te queda tiempo, decime). Mostrame las tiras de capturas
(costado, frente, cámara lenta) y un lado a lado en el juego. Si te lo apruebo, publicala o
decime cómo, anotá el ID y commit "animación de correr".
```

### B2 · Picar

Construye sobre el prompt 1 de "animaciones del pico y apertura" del 18/10, pero ahora con una animación de Roblox de verdad.

```
Juego: Forja Rápida. Leé las Reglas y "Cómo se hacen las animaciones" de
forja-rapida/PROMPTS-SECTORES.md.
Hoy el pico se anima girando el hombro con código (Golpes.client.luau, "Animación del pico",
PreSimulation sobre las uniones). Quiero reemplazarlo por animaciones de Roblox completas,
de cuerpo entero, muy buenas, sin perder lo que ya anda: que los demás vean tu golpe, que
mantener apretado siga pegando, el golpe fuerte cada 3 y que el pico nunca atraviese la geoda.
Animaciones (todas Action, con marker "Impacto" en el contacto):
1) Golpe A (derecha a izquierda), Golpe B (izquierda a derecha) y Golpe C fuerte (por arriba
   de la cabeza, con salto chiquito y las dos manos). Se alternan A, B, C, así nunca se ve
   igual dos veces seguidas.
   - Anticipación: se carga hacia atrás, rota la cadera, el peso pasa al pie de atrás.
   - Golpe: rápido, el cuerpo baja, el peso pasa al pie de adelante, el pico sigue un arco.
   - Contacto: 2 o 3 cuadros de pausa (hit-stop) y rebote del pico hacia arriba.
   - Recuperación: vuelve a la pose de guardia con superposición (brazo, después pico, después
     cabeza).
   - Duración total menor al intervalo entre golpes (GameConfig.Golpe.PorSegundo) para que no
     se corte; si se corta, que mezcle bien con el siguiente.
2) Pose de guardia con el pico (idle) con respiración y el pico que se mueve apenas.
3) Al soltar después de picar mucho: se apoya el pico en el hombro (0,6 s).
Efectos en el marker "Impacto" (la parte de chispas, grietas y número ya existe en Golpes y
Geodas.client, solo sincronizala): micro temblor de cámara (más fuerte en C), una estela
(Trail) en la punta del pico durante el golpe, color según el pico (Madera, Piedra, Hierro,
Oro, Cósmico), y un destello en el punto de contacto.
Tiene que andar igual con los 5 picos (si los Pico_*.fbx ya están en uso, ajustá el agarre).
Mostrame las 3 tiras de capturas, un lado a lado con estilo-4 (la geoda con el nido) y probalo
en celular y con 2 jugadores. Si te lo apruebo: publicalas o decime cómo, IDs en
GameConfig.Animaciones, sacá el giro de código viejo y commit "animación de picar".
```

### B3 · Eclosión de la geoda (modelo para romper)

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md. Guardá el .blend.
Para que la geoda se abra "de verdad" al romperse necesito sus pedazos. En
arte/scripts/rocas.py (o un script nuevo rocas_pedazos.py que lo use), para cada roca 1 a 5 de
cada zona en tamaño Mediana (y la Jefe):
- Partí la malla Roca en 8 a 12 pedazos con forma de cascarón de bloques (cortes en escalón,
  no planos lisos), que juntos se vean igual que la roca entera. Llamalos Pedazo1..PedazoN,
  cada uno con su pivote en su centro.
- Una malla "Interior": la cara de adentro de la geoda llena de cristales chiquitos del color
  de la zona (como geodas-gemini.jpg abierta), que se ve cuando caen los pedazos.
- Studs como textura, ≤ 6.000 triángulos por juego de pedazos.
Render de una geoda por zona entera y "explotada" (pedazos separados). Si te lo apruebo,
exportá Geodas_ZonaN_Pedazos.fbx a arte/fbx/ y decime cómo los importo (o hacelo vos por MCP)
a ServerStorage.Modelos.Geodas.ZonaN.<tamaño>.Pedazos. Si un tamaño no tiene pedazos, el
juego usa los de la Mediana escalados.
```

### B4 · Eclosión de la geoda (animación)

Construye sobre los prompts 2 y 4 de "animaciones del pico y apertura" del 18/10. La Forja (la escena con las monedas "?") ya está hecha y no se toca: esto es lo que pasa **en el mundo**, antes.

```
Juego: Forja Rápida. Leé las Reglas y "Cómo se hacen las animaciones" de
forja-rapida/PROMPTS-SECTORES.md. Necesita B3.
Mirá Geodas.client.luau (aplastón y grietas por vida), Revelacion.client.luau y
Forja.client.luau (la escena de La Forja, aprobada: no la cambies) y GeodeServerService (el
servidor decide la gema al romper).
Quiero una eclosión de la geoda espectacular, en el mundo, que la vean todos los que están
cerca, en 5 tiempos:
1) Aviso (0,4 s): en el último golpe, la geoda se infla (1 → 1,15) temblando cada vez más
   rápido, las grietas se encienden del color de la RAREZA que salió (el servidor ya la sabe:
   mandala en el evento), y salen 3 o 4 rayos de luz (Beam) por las grietas.
2) Grieta (0,3 s): se abre una grieta grande de arriba abajo con un "crack" fuerte, la luz
   sale más, hit-stop de 0,08 s y temblor de cámara a los cercanos.
3) Explosión (0,5 s): los Pedazos de B3 salen volando en arco (con giro y rebote en el piso,
   que se vean de bloques), queda el Interior con los cristales brillando y el nido, polvo y
   cubitos del color de la zona, y un anillo de onda en el piso.
4) La gema (0,8 s): sube flotando desde el interior girando, con un pilar de luz del color de
   la rareza (arcoíris en Mítica y Celestial), y se detiene a la altura de los ojos. Rareza
   escrita arriba con el estilo de los carteles.
5) Cierre: los pedazos se hunden en el piso y desaparecen, el nido queda 1 s y se va. Si es
   Rara o mejor, recién acá arranca La Forja como hoy (sin repetir el destello blanco).
Común: versión corta de 1 s (sin pilar, menos pedazos). Toque largo o "Abrir rápido" la salta.
"Efectos reducidos": sin rayos ni temblor y con 4 pedazos.
Los demás jugadores ven 1 a 4 (sin la parte de pantalla). Rendimiento: medí con 5 geodas
rompiéndose a la vez en el emulador de celular.
Mostrame tiras de capturas por rareza (Común, Rara, Mítica) y un lado a lado con estilo-4
(la geoda en blanco brillando). Si te lo apruebo, commit "eclosión de geoda".
```

---

## Sector F · Candados en las puertas cerradas

### F1 · Modelo del candado

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md. Guardá el .blend.
En arte/scripts/piezas_juego.py armá:
- "Candado_Grande": candado de bloques gigante (8 studs de alto), cuerpo dorado con borde más
  oscuro, cerradura con forma de gema (como el ícono Candado.png de arte/iconos, copiá su
  forma y colores) y el arco (malla aparte "Candado_Arco", con el pivote en su bisagra para
  que el juego lo abra).
- "Cadena_Tramo": tramo de cadena de eslabones de bloques, para cruzar la puerta en X de
  esquina a esquina (dos cadenas que se juntan en el candado).
- "Candado_Pedazos": el cuerpo del candado partido en 6 pedazos, para cuando se rompe.
Studs como textura, ≤ 3.000 triángulos el candado y ≤ 800 cada tramo de cadena.
Render del candado puesto en el portón de una zona (si el portón nuevo de las 13 piezas ya
está, sobre ese; si no, sobre una puerta de prueba de 20 x 20). Si te lo apruebo, exportá a
Piezas_Juego.fbx e importalo (o decime cómo).
```

### F2 · Candado en el juego y animación de abrir

```
Juego: Forja Rápida. Leé las Reglas y "Cómo se hacen las animaciones" de
forja-rapida/PROMPTS-SECTORES.md. Necesita F1.
Hoy las puertas entre zonas son un campo de fuerza celeste (GeneradorMapa, tipo PuertaZona,
tag "PuertaZona" con atributo Zona). La zona se abre para cada jugador cuando su Fuerza llega.
Quiero:
1) En cada puerta de una zona que TODAVÍA NO desbloqueaste: el candado grande en el medio con
   las dos cadenas en X, y arriba el cartel "Necesitás X de Fuerza" con el ícono del candado
   (estilo de los carteles, se ve de lejos). Es por jugador: cada uno ve candado solo en las
   puertas que tiene cerradas (lo arma el cliente según las zonas abiertas que manda el
   servidor). El bloqueo de verdad lo sigue haciendo el servidor como hoy.
2) Candado quieto: se balancea apenas, y la gema de la cerradura late suave.
3) Si te acercás a una puerta cerrada: el candado tiembla, suena un "clank" y el cartel salta
   mostrando cuánto te falta.
4) Al desbloquear (la Fuerza llega): si estás cerca, la cámara mira la puerta 1,5 s; la
   cerradura brilla, el arco salta para arriba con un "clic" grande, el candado cae, rebota y
   se rompe en Candado_Pedazos con cubitos dorados; las cadenas se aflojan y caen; la barrera
   se apaga y suena una fanfarria corta. Después sigue el cartel "¡Zona nueva!" que ya existe.
   Si estás lejos, se ve igual cuando llegás (sin la cámara).
5) Las puertas de zonas ya abiertas no tienen candado ni barrera.
6) Puertas secretas y Santuario del Renacer: mismo candado más chico (escala 0,5) si están
   cerrados para vos.
Probalo con un jugador nuevo (todas cerradas menos la primera), subile la Fuerza con
HerramientasPrueba y mirá la animación. Tira de capturas, celular y 2 jugadores con zonas
distintas abiertas. Si te lo apruebo, commit "candados en las puertas".
```

---

## Sector C · Ruleta de Mascotas

### C1 · Modelo nuevo de la ruleta

Reemplaza al prompt 1 de "13 piezas" del 18/10 (si ya lo hiciste, este lo mejora).

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md. Guardá el .blend.
Mirá lobby-1, lobby-2, estilo-1 y estilo-2 (bloques con studs, madera, colores saturados,
techitos con tejas de bloques) y el render de las 8 mascotas en arte/renders/.
Quiero una Ruleta de Mascotas grande, la pieza más llamativa del lobby, toda de bloques:
- Escenario redondo de 24 studs con 3 escalones, de madera y violeta, con un borde de
  bloquecitos que se prenden (malla aparte "Luces", 24 bloques separados Luz1..Luz24 para que el
  juego los encienda en cadena).
- La rueda parada, de 18 studs, en un marco de madera con dos columnas y un techito de tejas
  rojas como lobby-1. La rueda ("Rueda", pivote en el eje) tiene 8 gajos ("Gajo1".."Gajo8",
  pivote en el eje) de distintos tamaños: proporcionales a las chances de GameConfig
  (Topito 30 %, Piedrín 30 %, Chispa 14 %, Musgo 14 %, Cuarcito 4,5 %, Glaciel 4,5 %,
  Magmo 2,6 %, Nébula 0,4 %; leelas de GameConfig por si cambiaron). Para que Nébula se vea,
  su gajo puede tener un mínimo visual de 4°, pero el cartel de chances muestra la real.
  Cada gajo con un marco para la cara de la mascota (el juego pone la imagen) y su color de
  rareza.
- Centro: una geoda dorada de bloques que gira aparte ("Centro").
- Arriba: la lengüeta que marca el ganador ("Lengueta", pivote arriba), que golpea contra 8
  clavitos dorados del borde de la rueda ("Clavos") para el "tic-tic".
- Al costado derecho: una palanca grande ("Palanca", pivote abajo) con bola roja.
- Adelante: un pedestal chiquito de bloques ("Pedestal_Premio") donde aparece la mascota que
  salió.
- Atrás de la rueda: un cartel liso ("Cartel_Chances") para que el juego escriba las chances.
Pivote general en el centro de la base, frente hacia -Z, ≤ 12.000 triángulos.
Render de frente, de 3/4 y de cerca de la lengüeta, y lado a lado con lobby-1. Si te la
apruebo, reemplazá Ruleta_Mascotas en Lobby.fbx y decime cómo la importo (o hacelo vos).
```

### C2 · Animación de la ruleta

```
Juego: Forja Rápida. Leé las Reglas y "Cómo se hacen las animaciones" de
forja-rapida/PROMPTS-SECTORES.md. Necesita C1 en Studio.
Mirá cómo funciona hoy la ruleta (GeneradorMapa grupo 4, el servidor de mascotas y
MenuMascotas): el servidor cobra y elige la mascota. Eso no cambia: el servidor decide ANTES
de que empiece la animación y la animación solo lo muestra.
Quiero la animación más emocionante del juego, en 6 tiempos:
1) Palanca (0,5 s): la palanca baja con anticipación (sube un poquito antes), rebota, y las
   Luces se prenden en cadena alrededor del escenario.
2) Arranque (0,4 s): la rueda retrocede un poco (anticipación) y arranca de golpe; el Centro
   gira al revés.
3) Giro (2,5 a 3 s): rápido, desacelerando con una curva tipo rueda de verdad (Quint o una
   curva propia), 4 a 6 vueltas. La lengüeta golpea cada clavo con un "tic" y se dobla
   (superposición) y el tic se hace más lento con la rueda. Las luces corren en la misma
   dirección y a la misma velocidad que la rueda.
4) Suspenso (0,8 s): los últimos 2 o 3 gajos pasan muy lento; a veces (no siempre) se frena
   justo en el borde de un gajo raro y lo pasa por poquito. El lugar final lo calculás desde
   el resultado del servidor (un punto al azar DENTRO del gajo que salió).
5) Premio (1 s): el gajo ganador brilla con su color, las luces parpadean todas juntas, sale
   confeti de bloques del color de la rareza, y la mascota aparece en el Pedestal_Premio con
   un "pop" (escala 0 → 1,2 → 1) y hace su animación de festejo (MascotasRig). Arriba, el
   nombre y la rareza.
6) Final (0,8 s): la mascota salta hacia el jugador y se suma a las que lo siguen. Legendaria y
   Mítica: rayos de luz desde atrás, temblor de cámara y anuncio a todos (ya existe).
- Cámara: al tirar, la cámara del que tira se acomoda de frente a la ruleta (tween 0,5 s) y
  vuelve al final. Los demás ven la rueda girar y el premio sin que les muevan la cámara.
- "Tirar de nuevo" y "x3" si ya existen en el menú: la segunda tirada arranca sin la palanca.
- "Abrir rápido": todo en 1 s. "Efectos reducidos": sin confeti ni temblor.
- El cartel de chances atrás de la rueda muestra las chances reales en %, que suman 100.
Probalo con muchas tiradas (HerramientasPrueba) y fijate que el gajo donde frena siempre
coincida con la mascota que entrega el servidor. Tira de capturas, celular y 2 jugadores
mirando. Si te lo apruebo, commit "ruleta nueva animada".
```

---

## Sector G · HUD nuevo diseñado en Figma

Para la Claude de tu PC. Necesita el conector de Figma. Si no lo tiene, te lo dice y te explica cómo agregarlo (en la app de Claude: Settings → Connectors → Figma).

### G1 · Diseño en Figma copiando las referencias

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md.
Primero fijate si tenés las herramientas de Figma (MCP de Figma). Si no las tenés, PARÁ y
decime exactamente cómo conectarlo; no hagas el HUD sin Figma.
Archivo: "Forja Rápida · HUD y menús" (https://www.figma.com/design/DZ114Em8TCx2WZPzRiPAeL).
Ya tiene v1 y "v2 · Eventos y social". No los borres: creá la página "v3 · Como las
referencias".
1) Abrí y mirá con mucha atención el HUD de estilo-1, estilo-2, mapa-1, mapa-3 y las capturas
   de pantalla de arte/referencias/ que muestren menús. Escribime 12 observaciones exactas, por
   ejemplo:
   - A la izquierda, botones anchos de color plano (verde lima "Tienda", celeste "Índice")
     con borde negro grueso, ícono blanco con contorno a la izquierda y texto blanco grueso con
     contorno negro; globito rojo con "!" arriba a la derecha.
   - A la derecha, botones cuadrados con ícono grande y borde oscuro (el huevo rojo, la pata).
   - Abajo a la izquierda, contadores enormes en letra gruesa en cursiva con contorno negro,
     con ícono a la izquierda y el "+X" en verde al lado.
   - Abajo al centro, un botón rojo grande con ícono y dos líneas de texto.
   - Arriba al centro, el nombre de la zona y debajo "Recomendado: …" con ícono.
   Medí colores (script), grosor de bordes y de contornos en px, y tamaños relativos a la
   pantalla. Anotá todo en un marco "Medidas" en la página.
2) Fuente: la más parecida que haya en Roblox (FredokaOne o Lilita One si está; probá en
   Studio cuál se parece más a la referencia y usá esa misma en Figma).
3) Componentes con variantes (normal, apretado, con aviso, desactivado): BotonAncho,
   BotonCuadrado, Contador, BotonGrande, TituloZona, Globito, BarraProgreso, Ventana (panel con
   cabecera y X), Tarjeta (para tienda, mochila y mascotas). Usá los íconos de
   forja-rapida/arte/iconos/ y las piezas de arte/gui/listas/ (subilas al archivo). Sin
   emojis. Sin texto dentro de las imágenes.
4) Pantallas: HUD de compu 1920 x 1080 y de celular 844 x 390 (sin tapar el joystick, el
   salto, el botón de correr ni el menú de Roblox arriba a la izquierda) con los botones que
   el juego tiene HOY (leé Hud.client.luau: Tienda, Mochila, Viajar, Más con su despliegue,
   misión seguida, Fuerza, Suerte, Monedas, barra Próxima zona, nombre de zona). Después:
   Tienda, Mochila/Banco, Viajar, Mascotas + Ruleta (con las chances), La Forja y la tarjeta de
   la gema, Ajustes.
5) Poné una captura de la referencia al lado de cada pantalla en Figma y armá el lado a lado
   (Reglas, punto 3) con capturas de Figma.
Mostrame capturas de las pantallas y el link. Esperá mi OK antes de pasar al juego.
```

### G2 · Pasar el HUD de Figma al juego

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md. Necesita G1 aprobado.
Leé la página "v3 · Como las referencias" del archivo de Figma (contexto de diseño y capturas
de cada marco) y reconstruí el HUD en el juego, en Hud.client.luau y Estilo.luau:
- Mismas posiciones, tamaños relativos (Scale + UIAspectRatioConstraint, UISizeConstraint para
  que no quede gigante en monitores grandes), colores, bordes (UIStroke) y contornos del texto.
- Las piezas nuevas que haga falta exportar de Figma (botones, paneles): exportalas a PNG en
  arte/gui/v3/, subilas (probá vos con el MCP de Studio; si no, decime cómo) y anotá IDs en
  GameConfig.Gui. Íconos: los de HojaIconos que ya existen.
- No cambies lo que hace cada botón, solo cómo se ve. Mantené los avisos "!" y el menú "Más".
- Animación de botones: al pasar el mouse crecen 1,06; al apretar se hunden 0,94 y rebotan;
  el "+X" de los contadores salta y se desvanece; el globito "!" late.
- Celular: el diseño de 844 x 390 de Figma.
Lado a lado: Figma | juego | referencia, en compu y celular. Corregí hasta 3 veces.
Si te lo apruebo, commit "HUD v3".
```

### G3 · Menús con el mismo estilo

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md. Necesita G2.
Pasá al estilo v3 de Figma los menús, de a uno, en este orden: Tienda, Mochila/Banco, Viajar,
Mascotas (y la ventana de la ruleta con chances), Museo, Misiones, Eventos, Vitrina, Ranking,
Renacer y Ajustes. Mismos componentes (Ventana, Tarjeta, BotonAncho) y la misma animación de
abrir (crece de 0,9 a 1 con rebote, fondo que se oscurece). No cambies lo que hace cada menú.
Lado a lado Figma | juego por menú. Commit por menú ("menú Tienda v3", etc.).
```

### G4 · Repaso final contra las referencias

```
Juego: Forja Rápida. Leé las Reglas de forja-rapida/PROMPTS-SECTORES.md.
Con todo lo de los sectores D, E, A, B, F, C y G hecho, repetí el diagnóstico de D1 (mismas
cámaras, mismas referencias) y armá la tabla de diferencias otra vez. Arreglá las que se
puedan en este pedido si son chicas; si alguna es grande, sumala a PENDIENTES.md con su
prompt. Probá todo junto con 2 o 3 jugadores en Local Server y en el emulador de celular:
correr, picar, eclosión, candado al abrir zona, ruleta y HUD. Consola sin rojo, FPS en celular,
capturas, copia .rbxl en backups/ y commit "repaso contra las referencias".
```
