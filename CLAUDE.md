# Fábrica de juegos de Roblox

Proyecto para detectar tendencias de Roblox y construir prototipos de juegos en Roblox Studio.
Hablale al usuario en español rioplatense, corto y claro. Está aprendiendo: explicá en una línea qué hiciste y por qué.

## Saludo de control (obligatorio)

Empezá SIEMPRE cada respuesta al usuario con la frase "Hola Juani, ahora " seguida de lo que vas a hacer o acabás de hacer en esa respuesta, en una sola línea. Por ejemplo: "Hola Juani, ahora armo las puertas de velocidad."

Esto vale para todas las respuestas, también las cortas, las preguntas y los informes finales. El usuario usa esta frase para comprobar que seguís leyendo este archivo: si falta, entiende que perdiste las reglas.

## Cómo está armado

- `src/server` -> ServerScriptService.Server (lógica del juego, datos, economía)
- `src/client` -> StarterPlayer.StarterPlayerScripts.Client (input, UI, efectos)
- `src/shared` -> ReplicatedStorage.Shared (módulos y configuración compartidos)
- `ideas/` -> informes de tendencias y fichas de diseño (un .md por idea)
- `default.project.json` -> mapeo de Rojo

Herramientas (instaladas con Rokit): `rojo`, `selene`, `stylua`.

## Regla de oro: quién toca qué

- **Código**: siempre como archivos `.luau` en `src/`. Rojo los sincroniza a Studio. Nunca edites con el MCP un script que vive en `src/` (se pisan los cambios).
- **Mundo** (mapa, modelos, luces, UI visual, assets): con las herramientas MCP de Roblox Studio.
- **Pruebas**: con el MCP (playtest, consola, capturas, simular input).

## Flujo de trabajo

1. Antes de construir, tiene que existir una ficha en `ideas/` aprobada por el usuario.
2. Escribí el código en `src/`, después corré `stylua src` y `selene src`. Arreglá todo lo que marque Selene.
3. Pedile al usuario que tenga `rojo serve` corriendo y el plugin de Rojo conectado en Studio. Si las herramientas MCP no aparecen, avisale que revise Assistant > Manage MCP Servers.
4. Construí el mundo por MCP, arrancá el playtest, leé la consola y sacá una captura. No digas que algo funciona sin haberlo probado.
5. Hacé un commit de git por cada avance que funcione, con mensaje en español.

## Estilo de código

- Luau con `--!strict` arriba de cada archivo.
- Toda la lógica que importa (monedas, daño, compras) va en el servidor. El cliente solo pide; el servidor valida.
- Números de balance en `src/shared/Config.luau`, no sueltos en el código.
- Módulos chicos, un tema por archivo.

## Límites (no negociables)

- Nunca publiques el juego ni cambies su audiencia. Subir versiones lo decide y lo hace el usuario.
- No copies nombres, personajes, mapas ni assets de otros juegos o marcas. De las tendencias se toma la mecánica, no el contenido.
- Assets de la Creator Store: solo gratuitos, y revisá que no traigan scripts raros adentro antes de insertarlos.
- Nada de mecánicas de apuestas, cajas de botín pagas ni contenido que no sea apto para todo público.
- Nunca escribas claves de API ni contraseñas en archivos del proyecto.

## Modo de trabajo: máxima automatización

El usuario quiere dar el OK o proponer cambios, no dirigir cada paso. Entonces:

- Avanzá solo por toda la lista de sistemas de la ficha, sin preguntar entre uno y otro. Si algo es ambiguo, elegí la opción más simple, anotala en la ficha y seguí.
- Frená solo en estos puntos de control: (1) ficha del juego, (2) elección de estilo visual, (3) prototipo jugable terminado, (4) cualquier cosa que no se pueda deshacer o que cueste Robux.
- En cada punto de control mostrá una captura del juego y un resumen de tres líneas. Preguntá "¿OK o qué cambio?".
- Si un playtest falla, arreglalo vos y volvé a probar antes de avisar. Avisá recién si no lo lográs en tres intentos.

## Estilo visual (lo decidís vos, el usuario elige)

El usuario no quiere diseñar. Antes de construir el mundo:

1. Armá 3 propuestas de estilo bien distintas entre sí (paleta de 5 colores, materiales, iluminación, forma de las piezas).
2. Construí una muestra chica de cada una en Studio (unas pocas baldosas, una puerta y el cielo) y sacá una captura de cada una.
3. Mostrale las 3 capturas y que elija una. Guardá la elegida en la ficha como "Guía de estilo" y respetala en todo el juego.

Reglas de diseño: pocos colores, mucho contraste entre piso y fondo, formas simples, que se lea bien en pantalla de celular. Usá Lighting, Atmosphere y materiales antes que modelos complejos.

## Audio

- No uses canciones ni grabaciones con derechos de autor, aunque estén en la Creator Store subidas por otros usuarios.
- Para notas musicales: un solo sample corto (por ejemplo una nota de piano gratuita de la Creator Store) y cambiá el tono con `PlaybackSpeed`.
- Para melodías: solo composiciones de dominio público (por ejemplo clásicas de autores muertos hace más de 100 años) tocadas nota por nota con ese sample, o melodías inventadas.
- Dejá cada punto de sonido marcado con un comentario `-- SONIDO:` y los IDs en `Config.luau`, para que el usuario pueda cambiarlos por sonidos propios.
