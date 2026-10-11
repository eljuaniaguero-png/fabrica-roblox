# Mutant Lab — pedidos para hacer el arte en Blender

Una sesión nueva por cada pedido, en orden. El pedido 0 es obligatorio: prueba que todo el camino funcione con un solo objeto antes de fabricar cientos.
Conviene hacerlos después de los pedidos 1 a 3 de ORDEN-PEDIDOS.md (menús, pedidos y profundidad), porque cambian qué objetos hacen falta.

## Reglas comunes (están repetidas dentro de cada pedido)

- Blender lo maneja Claude con scripts de Python, en segundo plano. Los scripts quedan en mutant-lab/arte/scripts/ y los archivos exportados en mutant-lab/arte/export/.
- Estilo: la guía visual de ideas/mutant-lab.md. Formas redondas y gruesas, pocos polígonos, nada realista.
- Una malla por zona de color, sin texturas. El color se pone en Roblox desde shared/Paleta.luau, así se sigue pudiendo cambiar desde el código.
- Subir los modelos a Roblox lo hace el usuario con el importador 3D de Studio. Claude prepara los archivos, la lista de qué subir y después acomoda y conecta lo importado.

## 0 — Preparar y probar el camino completo

```
Juego: Mutant Lab (carpeta mutant-lab/). Vamos a hacer el arte en Blender. En esta sesión solo preparamos y probamos el camino con un objeto.

1. Fijate si Blender está instalado y encontrá su ruta. Si no está, decime que lo instale con: winget install BlenderFoundation.Blender
2. Creá mutant-lab/arte/scripts/ y mutant-lab/arte/export/. Los scripts .py van a git; los .blend y los exportados también, salvo que pesen mucho.
3. Armá un script base reutilizable (mutant-lab/arte/scripts/comun.py) que: limpie la escena, cree materiales con los colores de shared/Paleta.luau, aplique bordes redondeados (bevel) y suavizado, ponga el origen de cada pieza donde corresponda, exporte en FBX y saque un render de vista previa en PNG con fondo transparente y luz de tres puntos.
4. Corré Blender en segundo plano con ese script para hacer UN objeto de prueba: un frasco de laboratorio con líquido verde, en dos mallas (vidrio y líquido).
5. Mirá el render vos mismo y corregí lo que esté mal. Mostrámelo.
6. Decime exactamente cómo lo importo en Studio (paso a paso con el importador 3D), con qué escala, y qué nombre ponerle.
7. Cuando te avise que lo importé, buscalo por MCP, revisá que la escala, el pivote y la colisión estén bien, ponele los colores desde Paleta, y sacá una captura al lado de una criatura para comparar tamaños.
8. Anotá en la ficha, en una sección "Arte en Blender", la escala, la convención de nombres, el límite de polígonos que usaste y los pasos de importación que funcionaron.

No hagas ningún otro modelo en esta sesión.
```

## 1 — Mapa: plaza central y kit de decoración

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md, sobre todo la guía visual y la sección "Arte en Blender". Hacé el mapa en Blender usando mutant-lab/arte/scripts/comun.py.

QUÉ HACER
1. No un mapa entero de una sola pieza: un kit de piezas que se combinan. Así se puede reacomodar, anda mejor en celular y respeta los límites de Roblox.
2. Plaza central: piso circular por partes, borde con franjas de seguridad, faroles verdes, bancos, carteles de neón con flecha, la máquina de fusión en equipo grande con su tubo de luz, el tablero del experimento del día y el soporte de la tabla de posiciones.
3. Kit de decoración: tubos rectos, codos y con burbujas, cables gruesos, frascos y matraces de tres tamaños, estantes, pantallas con marco, barriles con símbolo de peligro, cajas, plantas mutantes en macetas.
4. Una pieza = un objeto con nombre claro (por ejemplo Deco_Tubo_Codo). Una malla por zona de color.
5. Poco detalle y formas redondeadas. Respetá el límite de polígonos de la ficha.

PROCESO
6. Primero hacé 5 piezas representativas, sacá renders y mostrámelos juntos. Esperá mi OK antes de hacer el resto.
7. Con el OK, hacé todo el kit y armá en Blender una vista de la plaza completa para ver el conjunto. Mostrame ese render.
8. Exportá cada pieza en FBX y dame la lista de archivos a importar, en orden, con su nombre en Roblox.
9. Cuando te avise que los importé: guardalos en ReplicatedStorage/Arte/Mapa, armá la plaza en Studio con esas piezas reemplazando las de partes básicas, poné colores desde Paleta y colisiones simples. Capturas desde arriba y a la altura del jugador.
```

## 2 — Personajes: piezas de criaturas

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md (guía visual, especies, piezas y "Arte en Blender") y shared/Piezas.luau y shared/Generador.luau. Hacé las criaturas en Blender usando mutant-lab/arte/scripts/comun.py.

MUY IMPORTANTE
Las criaturas se arman combinando piezas, y eso hace que existan 50 especies (y más con variantes). NO modeles criaturas enteras: modelá las piezas que ya usa el generador, con los mismos puntos de unión, para que el sistema de fusión siga funcionando igual.

QUÉ HACER
1. Leé en Piezas.luau qué piezas tiene cada una de las 10 especies base (cabeza, cuerpo, patas, cola o alas, rasgo especial) y dónde se une cada una.
2. Modelá cada pieza como malla separada, estilo chibi de la guía: redondeada, gruesa, exagerada. Una malla por zona de color, para que el color lo siga poniendo el código (cada pieza conserva el color de su padre).
3. Ojos aparte y reutilizables: ojo base, párpado y ceja, con las variantes de cada personalidad de la guía (alegre, vaga, peleadora, miedosa, curiosa y las demás).
4. Piezas extra de generación 3 (corona, aura, segundo par de alas) y la pieza de elemento brillante.
5. Cada pieza con su origen en el punto de unión, para que el generador la coloque igual que hoy.

PROCESO
6. Primero hacé las piezas de 2 especies, armá en Blender esas 2 criaturas y una fusión entre ellas, y mostrame los renders. Esperá mi OK.
7. Con el OK, hacé las 10 especies. Armá en Blender una hoja con las 10 bases y 10 fusiones de ejemplo y mostrámela.
8. Exportá y dame la lista de importación.
9. Cuando te avise que los importé: guardalos en ReplicatedStorage/Arte/Criaturas y cambiá Generador.luau para que use las mallas en lugar de partes básicas, manteniendo colores, animación, silueta y versión mutante. Si una pieza no está importada, que use la versión vieja en vez de fallar.
10. Revisá con capturas las 10 bases, 10 fusiones, 3 de generación 3 y 2 mutantes, y que el Mutadex y los paneles las muestren bien. Probá rendimiento con 20 criaturas en pantalla.
```

## 3 — Menús: íconos y gráficos

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y client/UI (Iconos.luau y Tema.luau). Los menús se arman en Roblox con código, así que de Blender solo sacamos imágenes: íconos con aspecto 3D que reemplacen a los dibujados con formas.

QUÉ HACER
1. Hacé la lista de todos los íconos que usa la interfaz: ADN, pistas, catalizadores (los 5), residuos, mejoras de la tienda, misiones, ajustes, Mutadex, tienda, pedidos, trofeos, candado, monedas premium y los 5 elementos.
2. Modelá cada uno en Blender en el estilo de la guía, con la misma cámara, luz y contorno oscuro para todos, así se ven como un juego de íconos.
3. Renderizá cada uno en PNG de 512x512 con fondo transparente, y una versión gris para cuando está bloqueado o no alcanza.
4. Mostrame una hoja con todos juntos y esperá mi OK.
5. Guardalos en mutant-lab/arte/iconos/ y dame instrucciones para subirlos todos juntos con el importador masivo del Asset Manager de Studio.
6. Cuando te pase los IDs (o los encuentres por MCP), cargalos en un módulo de datos y cambiá UI/Iconos.luau para usar las imágenes, con los íconos dibujados de hoy como respaldo si falta alguno.
7. Capturas del HUD, la tienda y el Mutadex en computadora y celular.
```

## 4 — Bases: el laboratorio de cada jugador

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md (guía visual, sección del laboratorio y "Arte en Blender") y server/Laboratorios.luau. Hacé el laboratorio de cada jugador en Blender usando mutant-lab/arte/scripts/comun.py y el kit de decoración del pedido 1.

QUÉ HACER
1. Sala redonda por partes: piso, paredes curvas, arco de entrada con lugar para el nombre del jugador, techo con claraboya.
2. Máquina de fusión: cápsula de vidrio, dos ranuras laterales para los padres, ranura de catalizador arriba, tubos con líquido. Mallas separadas para lo que se anima (líquido, luces, tapa) y nombres claros, para que EfectosMaquina.luau las pueda mover.
3. Corrales hexagonales con cúpula de vidrio y borde de neón, en versión abierta y cerrada con candado.
4. Mostrador de la tienda y el robot vendedor, el tablero de pedidos con lugar para los clientes, la pantalla gigante del Mutadex y el estante de trofeos.
5. Mismo estilo y escala que el mapa.

PROCESO
6. Primero la máquina de fusión sola, con renders desde varios ángulos. Esperá mi OK.
7. Después el resto, y un render del laboratorio completo armado en Blender. Esperá mi OK.
8. Exportá y dame la lista de importación.
9. Cuando te avise que los importé: guardalos en ReplicatedStorage/Arte/Laboratorio y cambiá Laboratorios.luau para armar cada laboratorio con estas piezas. Mantené los nombres que usa el código (ranuras, corrales, mostrador, tablero) para que todo siga funcionando.
10. Probá con 2 jugadores: que cada uno reciba su laboratorio, que la máquina y la animación de fusión anden, y que los corrales se abran. Capturas.
```

## 5 — Todo lo que falte

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab.md y revisá el place por MCP. Buscá todo lo que todavía esté hecho con partes básicas y no tenga versión en ReplicatedStorage/Arte.

1. Hacé la lista: por ejemplo los catalizadores como objetos, los residuos, los clientes de los pedidos, los trofeos, los objetos que flotan en las animaciones, carteles y lo que encuentres.
2. Mostrámela ordenada de lo que más se ve a lo que menos, y esperá mi OK sobre qué hacer.
3. Hacelos en Blender con comun.py, en el mismo estilo, con renders para aprobar.
4. Exportá, dame la lista de importación y, cuando te avise, conectalos en el juego con respaldo a la versión vieja si falta alguno.
5. Revisión final: recorré todo el juego con capturas, buscá cosas que no combinen con el resto, y medí rendimiento en celular con 2 jugadores y 20 criaturas. Si algo baja el rendimiento, simplificalo.
6. Actualizá la sección "Arte en Blender" de la ficha con la lista de todo lo que existe y cómo se importa.
```
