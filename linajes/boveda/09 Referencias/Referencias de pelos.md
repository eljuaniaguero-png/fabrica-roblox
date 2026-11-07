# Referencias de pelos

> Solo para ideas: no se copia ningún peinado ni se sube ninguna imagen a Roblox. Las imágenes están en `imagenes/pelos/` y no van a git.

Revisión del 7 de noviembre de 2026, después de rechazar `PeloSolido`.

## Qué se miró

- 110 pelos del catálogo de Roblox, con 8 búsquedas (puntas, desordenado, shonen, capas, wolf cut). Hojas: `hoja-catalogo-1.jpg` y `hoja-catalogo-2.jpg`.
- 6 videos: 2 de Shindo Life, 2 de Deepwoken y 2 tutoriales de pelo para Roblox.
- De Blox Fruits y Bloodlines no apareció material útil de pelo. Los videos de juego muestran al personaje lejos, sirven poco para ver construcción.

## Qué hacen bien los pelos buenos

1. **Muchos mechones finos y largos**, no pocas puntas gordas. Cada uno termina en punta aguda.
2. **Capas:** una base tipo gorro abajo y mechones superpuestos encima.
3. **La textura hace gran parte del trabajo:** raíz oscura, punta clara y líneas de hebras. Sin textura se ve como plástico.
4. **Punto de nacimiento:** los mechones salen de una coronilla o raya y caen desde ahí.
5. **Silueta irregular:** largos distintos, algunas hebras sueltas que escapan del volumen.
6. **Más grande que la cabeza:** el volumen se separa del cráneo.
7. **Línea de frente hecha aparte:** mechones chicos en fila, que tapan la unión con la piel.

## Cómo se construyen

- Cada mechón es una curva con forma de hoja que se convierte en malla.
- Se deja espacio entre las raíces y la parte de arriba de la cabeza, porque la cabeza de Roblox es plana.
- El video de consejos pide no usar Decimate: arruina la textura. Baja triángulos con menos resolución de curva, disolviendo aristas y borrando caras que no se ven.
- Ese video trabaja con un tope de unos 4.000 triángulos para pelos de catálogo. Es dato del video, sin confirmar en la documentación de Roblox.

## Por qué fallaron los nuestros

- Las puntas eran pocas y gruesas, y el color era uno solo.
- `PeloSolido` cerró los huecos pero perdió mechones: quedó como casco.
- Fue un error tratar el pelo como un solo color: una MeshPart admite textura.

## Método propuesto

Gorro base oscuro + 60 a 100 mechones finos en capas + fila de frente + textura con degradé y hebras. Los mechones nacen dentro del gorro, así no hay huecos aunque sean piezas distintas. Se juntan en una sola malla con una sola textura.

## Fuentes

- [Roblox UGC Hair tips](https://www.youtube.com/watch?v=7OTce0LaXFg)
- [Ultimate Guide Anime Hair](https://www.youtube.com/watch?v=zC24wFJ5Zjg)
- [Hair Showcase, Shindo Life](https://www.youtube.com/watch?v=QjPqx1nvaMg)
- [Customizing your character, Shindo Life](https://www.youtube.com/watch?v=nMTmit_Wuw0)
- [Make any character in Deepwoken](https://www.youtube.com/watch?v=vNrtODEo-Bk)
- [How to edit your character in Deepwoken](https://www.youtube.com/watch?v=i2ocgVnx9ls)
