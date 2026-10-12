# Mutant Lab — pedidos para hacer el arte en Blender

Una sesión nueva por cada pedido, en orden. Todos leen primero `ideas/mutant-lab-arte.md`, que tiene el diseño completo.
El pedido 0 es obligatorio: prueba el camino entero con un solo objeto antes de fabricar cientos.
Conviene hacerlos después de 7b, 7c, 7d y 7e de ORDEN-PEDIDOS.md, porque esos agregan huevos, incubadoras, frutas y decoración al juego.

Lo que hace el usuario: instalar Blender si falta, importar los modelos en Studio con el importador 3D (Claude da la lista y los pasos), y subir los íconos con el importador masivo del Asset Manager.

## 0 — Preparar y probar el camino completo

```
Juego: Mutant Lab (carpeta mutant-lab/). Vamos a hacer el arte en Blender. Leé ideas/mutant-lab-arte.md entero. En esta sesión solo preparamos y probamos el camino con un objeto.

1. Fijate si Blender está instalado y encontrá su ruta. Si no está, decime que lo instale con: winget install BlenderFoundation.Blender
2. Creá mutant-lab/arte/ con scripts/, export/, renders/ e iconos/.
3. Armá mutant-lab/arte/scripts/comun.py, reutilizable, que: limpie la escena, cree materiales de vista previa con los colores de shared/Paleta.luau, aplique bisel y sombreado suave, ponga el origen donde corresponde, convierta los ejes para que el frente llegue a Roblox mirando a -Z, exporte cada objeto en FBX y saque un render PNG con fondo transparente y la misma luz siempre.
4. Corré Blender en segundo plano para hacer UN objeto de prueba: el Catalizador Slime (frasco que gotea), con sus mallas separadas como dice el documento.
5. Mirá el render vos mismo, corregí lo que esté mal y mostrámelo.
6. Decime paso a paso cómo lo importo en Studio con el importador 3D, con qué escala y con qué nombre.
7. Cuando te avise que lo importé, buscalo por MCP, revisá escala, pivote y orientación, pintalo desde Paleta y sacá una captura al lado de una criatura.
8. Anotá en la sección "Registro" de ideas/mutant-lab-arte.md la escala real, la conversión de ejes y los pasos de importación que funcionaron.

No hagas ningún otro objeto en esta sesión.
```

## 1 — Mapa: plaza central y Jardín Salvaje

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab-arte.md, sobre todo las secciones 2, 7 y 8 y el Registro. Usá mutant-lab/arte/scripts/comun.py.

1. Hacé las piezas de la plaza central (sección 7) y del Jardín Salvaje (sección 8), como kit de módulos, no como una sola malla.
2. Primero 3 piezas de la plaza y 3 del Jardín. Renders juntos y esperá mi OK.
3. Con el OK, hacé todo. Armá en Blender una vista de la plaza completa y otra de un tramo del Jardín, y mostrámelas.
4. Pasá la lista de aprobación (sección 12) para cada objeto.
5. Exportá y dame la lista de importación en orden, con el nombre de cada uno en Roblox.
6. Cuando te avise que los importé: guardalos en ReplicatedStorage/Arte/Plaza y ReplicatedStorage/Arte/Jardin, armá la plaza y el Jardín en Studio con estas piezas reemplazando las de partes básicas, pintá desde Paleta y poné colisiones simples. En el Jardín, revisá que los caminos se lean, que los saltos se puedan hacer y que las frutas tengan por dónde escapar.
7. Capturas desde arriba y a la altura del jugador. Anotá en el Registro qué hiciste.
```

## 2 — Personajes: criaturas, huevos, frutas y clientes

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab-arte.md (secciones 3, 4, 5 y 9, clientes de pedidos), shared/Piezas.luau y shared/Generador.luau. Usá mutant-lab/arte/scripts/comun.py.

MUY IMPORTANTE: las criaturas se arman por piezas. No modeles criaturas enteras. Respetá los enchufes de la sección 3, para que el sistema de fusión siga funcionando igual.

BLOQUE 1 - Criaturas
1. Hacé las piezas de 2 especies (por ejemplo Glupona y Chisparo) y el kit de ojos. Armá en Blender las 2 criaturas y una fusión entre ellas. Renders y esperá mi OK.
2. Con el OK, hacé las 10 especies, los ojos de las 8 personalidades y los extras. Armá una hoja con las 10 bases y 10 fusiones de ejemplo y mostrámela.
3. Exportá y dame la lista de importación. Cuando te avise: guardalas en ReplicatedStorage/Arte/Criaturas y cambiá Generador.luau para usar las mallas, manteniendo colores por pieza, animación, silueta, personalidad en los ojos, mutantes y respaldo a la versión vieja.
4. Capturas de 10 bases, 10 fusiones, 3 de generación 3, 2 mutantes y una de nivel 10. Probá 20 criaturas en pantalla en celular.

BLOQUE 2 - Huevos y frutas
5. Huevos de los dos tamaños, con grietas en 3 etapas y fragmentos (sección 4). Las 5 frutas vivas, la Dorada, la Gigante, las semillas y las plantas de huerta (sección 5).
6. Renders, OK, exportación e importación como en el bloque 1. Conectalos con el código de huevos y del Jardín, manteniendo las animaciones.

BLOQUE 3 - Clientes de pedidos
7. Los 6 clientes de la sección 9. Renders de los 6 juntos y OK. Importación y conexión con el tablero de pedidos.

Anotá en el Registro qué hiciste en cada bloque.
```

## 3 — Menús: íconos

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab-arte.md (sección 11) y client/UI/Iconos.luau. Los menús se arman en Roblox con código; de Blender solo salen íconos como imágenes.

1. Armá la lista completa de íconos: los de la sección 11 más los que use Iconos.luau.
2. Modelalos con comun.py en el estilo del juego, con la misma cámara, luz y contorno para todos.
3. Renderizá cada uno en PNG de 512x512 con fondo transparente, más la versión gris.
4. Mostrame una hoja con todos juntos y esperá mi OK.
5. Guardalos en mutant-lab/arte/iconos/ y dame los pasos para subirlos juntos con el importador masivo del Asset Manager.
6. Cuando te pase los IDs, o los encuentres por MCP, cargalos en un módulo de datos y cambiá UI/Iconos.luau para usar las imágenes, con los íconos dibujados de hoy como respaldo.
7. Capturas del HUD, la tienda, el Mutadex y el inventario de comida en computadora y celular.
```

## 4 — Bases: el laboratorio de cada jugador

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab-arte.md (sección 6) y server/Laboratorios.luau. Usá comun.py y el estilo de la plaza.

1. Primero la máquina de fusión sola, con renders desde varios ángulos. Esperá mi OK.
2. Después el resto de la sección 6: sala, corrales, incubadoras, huerta, nido, mostrador, robot vendedor, tablero de pedidos, pantalla del Mutadex y estante de trofeos. Render del laboratorio completo armado en Blender y esperá mi OK.
3. Exportá y dame la lista de importación.
4. Cuando te avise: guardalos en ReplicatedStorage/Arte/Laboratorio y cambiá Laboratorios.luau para armar cada laboratorio con estas piezas. Mantené los nombres que usa el código (ranuras, corrales, incubadoras, macetas, mostrador, tablero) y conectá las partes _Anim con sus animaciones.
5. Probá con 2 jugadores: cada uno con su laboratorio, fusión con su animación, huevos en incubadoras, huerta y corrales que se abren. Capturas y anotación en el Registro.
```

## 5 — Decoración y todo lo que falte

```
Juego: Mutant Lab (carpeta mutant-lab/). Leé ideas/mutant-lab-arte.md (secciones 9 y 10) y revisá el place por MCP.

BLOQUE 1 - Catálogo de decoración
1. Hacé el catálogo de la sección 10 con comun.py: módulos de los temas de sala, decoraciones sueltas y aspectos de corral, máquina y arco.
2. Renders por grupo y esperá mi OK en cada grupo.
3. Importación y conexión con el modo decorar y el catálogo de la tienda. Probá decorar un laboratorio completo y que otro jugador lo vea al visitarlo.

BLOQUE 2 - Lo que falte
4. Buscá todo lo que siga hecho con partes básicas y no tenga versión en ReplicatedStorage/Arte (catalizadores, residuo, ADN, pista, trofeos, pedestales y lo que encuentres). Mostrame la lista ordenada de lo que más se ve a lo que menos, y esperá mi OK.
5. Hacelos, con renders para aprobar, importación y conexión con respaldo.

REVISIÓN FINAL
6. Recorré todo el juego con capturas y buscá cosas que no combinen con el resto.
7. Medí rendimiento en celular con 2 jugadores, 20 criaturas y una ronda del Jardín. Si algo lo baja, simplificalo.
8. Completá el Registro de ideas/mutant-lab-arte.md con la lista de todo lo que existe y cómo se importa.
```
