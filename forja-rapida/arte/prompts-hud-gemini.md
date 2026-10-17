# Forja Rápida · prompts del HUD para Gemini (estilo más colorido)

16/10/2026. Hecho a partir de las 4 imágenes que mandaste (la hoja de íconos y la tienda "Exclusive Store") y de lo que el juego usa de verdad hoy (`GameConfig.Iconos` y `GameConfig.Gui` en `forja-rapida/src/shared/GameConfig.luau`).

**Qué cambia respecto de los íconos que ya tenés:** mismo dibujo gordito con borde oscuro, pero con colores más saturados, degradés más vivos, un resplandor de color y destellos. Las piezas (botones, ventanas, barras) llevan una textura sutil de studs tipo Lego, como la cabecera amarilla de tu captura y el mapa del juego.

Se toma el **estilo**, no los dibujos: no le pidas a Gemini que copie los íconos de la captura (son de otro juego).

## Cómo usarlo

1. Entrá a **gemini.google.com** con tu cuenta de Google y elegí **Crear imagen**.
2. En el primer mensaje del chat adjuntá la hoja de íconos de referencia y escribí: *"Usá esta imagen solo como referencia de estilo, no copies ninguno de estos dibujos."* Después pegá el prompt 1 (la Moneda).
3. Seguí en **el mismo chat**, un prompt por mensaje, en orden. Cada prompt ya trae la frase de estilo completa.
4. Si un ícono sale con otro estilo, adjuntá el primero que te gustó y agregá adelante: *"Mismo estilo exacto que esta imagen."*
5. Guardá cada imagen con el **nombre de archivo** que dice arriba de su prompt, en `forja-rapida/arte/iconos-gemini/` (carpeta nueva, así no pisás los íconos que ya andan).
6. Cuando tengas una tanda, decile a Claude: *"Pasá los íconos de iconos-gemini al juego."* Claude saca el fondo verde (o magenta), los achica, arma la hoja, los sube y los pone en el juego.

**Por qué el fondo verde o magenta:** Gemini casi nunca da fondo transparente de verdad. Con un color liso Claude lo recorta perfecto. Los objetos verdes (trébol, tienda, misiones, amuleto, botón verde) van en magenta para que no se borren al recortar.

**Sin texto, siempre.** Los nombres ("Tienda", "Vender todo", los números) los pone el juego encima, así se pueden traducir y cambiar.

---

## Parte 1 · Íconos que el juego ya usa (26)

Son los que hoy están en la hoja de íconos. Cada uno reemplaza al que tiene el mismo nombre.


### A. Arriba a la derecha: contadores y botones chicos

**1. Moneda (contador de Monedas)** · `Moneda.png`

```
Ícono de juego: una moneda de oro gorda y brillante vista de frente, con un rombo en relieve en el centro, borde con relieve dorado más oscuro y reflejos amarillos muy vivos. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**2. Trébol (contador de Suerte)** · `Trebol.png`

```
Ícono de juego: un trébol de cuatro hojas verde lima eléctrico, hojas infladas y brillantes con una vena más clara en cada hoja, tallito curvo, con chispitas doradas. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color magenta puro #FF00FF, sin degradé, sin sombra y sin nada más en el fondo.
```

**3. Pesa (contador de Fuerza)** · `Fuerza.png`

```
Ícono de juego: una mancuerna de gimnasio horizontal con discos gorditos rojo cereza brillante y barra plateada cromada en el medio. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**4. Gota de Esencia (moneda del Renacer)** · `Esencia.png`

```
Ícono de juego: una gota mágica de energía con degradé de rosa fucsia arriba a naranja y dorado abajo, una llamita brillante adentro y resplandor rosado. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**5. Banco (botón Vender todo)** · `Banco.png`

```
Ícono de juego: un edificio de banco clásico con techo triangular y columnas blancas con detalles dorados, y adelante una pila de monedas de oro brillantes. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**6. Engranaje (botón Ajustes)** · `Engranaje.png`

```
Ícono de juego: un engranaje gordito plateado con reflejos celestes y un círculo azul brillante en el centro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```


### B. Botones grandes de los menús (izquierda)

**7. Tienda** · `Tienda.png`

```
Ícono de juego: un puestito de mercado con toldo a rayas verde lima y blanco, mostrador de madera color miel y una gema violeta brillando en el centro del mostrador. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color magenta puro #FF00FF, sin degradé, sin sombra y sin nada más en el fondo.
```

**8. Mochila** · `Mochila.png`

```
Ícono de juego: una mochila de aventurero gordita color naranja y marrón caramelo, con bolsillo adelante, correas y una gema violeta cosida en la tapa. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**9. Libro (Museo)** · `Libro.png`

```
Ícono de juego: un libro grueso cerrado con tapa fucsia brillante, esquinas doradas y un cristal celeste brillante en el centro de la tapa. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**10. Corona (Mi Vitrina)** · `Corona.png`

```
Ícono de juego: una corona real violeta con borde dorado y tres joyas redondas: una celeste en el centro, una rosa y una verde a los costados. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**11. Trofeo (Ranking)** · `Trofeo.png`

```
Ícono de juego: una copa de trofeo dorada brillante con dos asas, base gruesa y una estrella blanca en el frente. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**12. Cronómetro (Eventos)** · `Reloj.png`

```
Ícono de juego: un cronómetro redondo azul eléctrico con botón arriba, cara blanca y una aguja roja. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**13. Portapapeles (Misiones)** · `Mision.png`

```
Ícono de juego: un portapapeles celeste con clip plateado arriba, una hoja blanca con dos rayitas grises y un tilde verde gordo y brillante encima. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color magenta puro #FF00FF, sin degradé, sin sombra y sin nada más en el fondo.
```

**14. Patita (Mascotas)** · `Mascota.png`

```
Ícono de juego: una huella de patita de mascota rosa chicle brillante, almohadilla grande abajo y cuatro deditos redondos arriba. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**15. Flecha con llama (Renacer)** · `Renacer.png`

```
Ícono de juego: una flecha circular gorda naranja fuego que da casi una vuelta completa, con una llama amarilla y naranja en el centro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```


### C. Tienda, mochila y museo

**16. Pico (pestaña Picos)** · `Pico.png`

```
Ícono de juego: un pico de minero en diagonal con cabeza curva de acero celeste brillante y mango de madera marrón caramelo. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**17. Amuleto (pestaña Amuletos)** · `Amuleto.png`

```
Ícono de juego: un medallón redondo dorado colgando de un cordón, con un trébol verde brillante en el centro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color magenta puro #FF00FF, sin degradé, sin sombra y sin nada más en el fondo.
```

**18. Candado (cosas bloqueadas)** · `Candado.png`

```
Ícono de juego: un candado dorado gordito con arco plateado y ojo de cerradura oscuro en el frente. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**19. Gema** · `Gema.png`

```
Ícono de juego: una gema facetada tipo diamante, violeta brillante con caras más claras y más oscuras y reflejos blancos. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**20. Cristales (Lluvia de Cristales)** · `Cristal.png`

```
Ícono de juego: un grupo de tres cristales puntiagudos parados, celeste hielo y azul, el del medio más alto, muy brillantes. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**21. Destello (hallazgos y brillos)** · `Chispa.png`

```
Ícono de juego: un destello grande de cuatro puntas celeste muy claro casi blanco con una estrellita dorada chiquita al costado. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```


### D. Geodas exóticas y eventos

**22. Lava** · `Lava.png`

```
Ícono de juego: una llama de fuego gorda con degradé rojo, naranja y amarillo, centro amarillo claro, con dos brasas redondas flotando. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**23. Neón** · `Neon.png`

```
Ícono de juego: un rayo eléctrico en zigzag con degradé arcoíris neón (rosa, violeta, celeste, verde) y resplandor de colores. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**24. Dorada** · `Midas.png`

```
Ícono de juego: una estrella de cinco puntas dorada brillante, inflada, con motitas verdes y destellos dorados alrededor. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**25. Vacío** · `Vacio.png`

```
Ícono de juego: un orbe redondo violeta muy oscuro con una espiral de galaxia violeta clara adentro y estrellitas blancas. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**26. Jefe (Geoda Ancestral)** · `Jefe.png`

```
Ícono de juego: una roca gigante cúbica violeta hecha de cubitos, con runas doradas brillando en el frente y una corona dorada chiquita encima. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```


---

## Parte 2 · Piezas de la interfaz (botones, ventanas, barras)

Estas son las "cajas" donde va el texto y los íconos. Las blancas no son un error: el juego las pinta del color que haga falta, así una sola imagen sirve para todos los colores. Las piezas no llevan destellos alrededor porque el juego las estira y tienen que tener los bordes parejos.

**27. Botón blanco (el juego lo pinta del color que quiera)** · `BotonBlanco.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, blanco y gris muy claro (para poder teñirlo de cualquier color). Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**28. Botón verde** · `BotonVerde.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, verde lima brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color magenta puro #FF00FF, sin degradé ni sombra en el fondo.
```

**29. Botón amarillo** · `BotonAmarillo.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, amarillo dorado brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**30. Botón naranja** · `BotonNaranja.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, naranja mandarina brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**31. Botón rojo** · `BotonRojo.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, rojo cereza brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**32. Botón rosa** · `BotonRosa.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, rosa chicle brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**33. Botón violeta** · `BotonVioleta.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, violeta uva brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**34. Botón azul** · `BotonAzul.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, azul eléctrico brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**35. Botón celeste** · `BotonCian.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, celeste turquesa brillante. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**36. Botón gris (apagado, no alcanza la plata)** · `BotonGris.png`

```
Pieza de interfaz: un botón rectangular ancho y vacío, gris azulado apagado, sin brillo fuerte. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 16:9 con el botón rectangular ancho (unas tres veces más ancho que alto) centrado ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**37. Botón cuadrado de menú (fondo de los 9 botones de la izquierda)** · `BotonMenu.png`

```
Pieza de interfaz: un botón cuadrado vacío con esquinas muy redondeadas, blanco y gris muy claro para poder teñirlo. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con el botón centrado ocupando casi toda la imagen, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**38. Botón de cerrar (X)** · `Cerrar.png`

```
Pieza de interfaz: un botón cuadrado rojo cereza brillante con esquinas redondeadas y una X blanca gorda con contorno oscuro en el centro (la X sí va, es un símbolo). Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con el botón centrado, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**39. Globito de aviso (ahí el juego pone el ! o el número)** · `Globito.png`

```
Pieza de interfaz: un círculo rojo brillante vacío con contorno oscuro grueso y brillo blanco arriba. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con el círculo centrado, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**40. Fondo de las ventanas** · `PanelOscuro.png`

```
Pieza de interfaz: un panel rectangular grande vacío, azul noche oscuro con un borde interior un poco más claro, esquinas redondeadas. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con el panel centrado ocupando casi toda la imagen, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**41. Cabecera de las ventanas (franja de arriba con el título)** · `Cabecera.png`

```
Pieza de interfaz: una franja horizontal larga y vacía, blanca y gris muy claro para teñirla, con tres rayas diagonales de brillo blanco semitransparente en la mitad derecha. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 21:9 con la franja centrada ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**42. Píldora de los contadores (Monedas, Suerte, Fuerza)** · `Pildora.png`

```
Pieza de interfaz: una barra horizontal vacía con puntas totalmente redondas tipo cápsula, blanca y gris muy claro para teñirla. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 21:9 con la cápsula centrada ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**43. Fondo de las barras de progreso** · `BarraFondo.png`

```
Pieza de interfaz: una barra horizontal vacía tipo cápsula, azul noche oscuro con sombra interior, como un canal hundido. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 21:9 con la barra centrada ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**44. Relleno de las barras de progreso** · `BarraRelleno.png`

```
Pieza de interfaz: una barra horizontal tipo cápsula, blanca y gris muy claro para teñirla, con una franja de brillo arriba. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen horizontal 21:9 con la barra centrada ocupando casi todo el ancho, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**45. Baldosa (cuadraditos de gemas, títulos y filas)** · `Baldosa.png`

```
Pieza de interfaz: una baldosa cuadrada vacía con esquinas redondeadas, blanca y gris muy claro para teñirla. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con la baldosa centrada ocupando casi toda la imagen, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```

**46. Marco dorado de "Destacado"** · `MarcoDestacado.png`

```
Pieza de interfaz: un marco rectangular hueco dorado brillante con esquinas redondeadas y cuatro remaches redondos en las esquinas; el centro del marco relleno del mismo color de fondo. Estilo: pieza de interfaz de juego para celular, tipo simulador de Roblox, formas gorditas con esquinas bien redondeadas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados tipo caramelo con degradé de arriba (más claro) hacia abajo (más oscuro), brillo blanco de plástico en la franja de arriba, borde inferior más oscuro que da efecto de botón 3D, textura muy sutil de studs redondos tipo Lego en la superficie, sin destellos alrededor, sin íconos, sin texto, sin letras, sin números, bordes parejos para poder estirarla. Imagen cuadrada 1:1 con el marco centrado ocupando casi toda la imagen, fondo liso de un solo color verde puro #00FF00, sin degradé ni sombra en el fondo.
```


---

## Parte 3 · Extras (todavía no aparecen en el HUD)

El juego tiene estas cosas pero hoy las muestra con un ícono genérico o con un dibujo hecho por código (por ejemplo, las gemas son un rombo de color). Si los hacés, Claude puede sumarlos después: llaves y cofres de las cámaras secretas, cada pico y cada amuleto en la Tienda, y una gema por rareza en la Mochila y el Museo. Hacelos solo cuando la Parte 1 y la 2 estén listas.

**47. Llave secreta** · `Llave.png`

```
Ícono de juego: una llave antigua dorada con cabeza redonda y una gema celeste en el centro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**48. Cofre del tesoro** · `Cofre.png`

```
Ícono de juego: un cofre de tesoro de madera color miel con bordes dorados, entreabierto, con luz dorada y gemas de colores asomando. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**49. Altar** · `Altar.png`

```
Ícono de juego: un altar de piedra gris claro con runas celestes brillando y una gema flotando encima. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**50. Portal dimensional** · `Portal.png`

```
Ícono de juego: un portal redondo con marco de piedra y un remolino arcoíris brillante adentro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**51. Ruleta de Mascotas** · `Ruleta.png`

```
Ícono de juego: una ruleta redonda de premios con porciones de colores vivos (rosa, amarillo, celeste, verde, violeta) y una flechita blanca arriba. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**52. Árbol de Esencia** · `Arbol.png`

```
Ícono de juego: un arbolito mágico con tronco marrón y copa redonda rosa fucsia brillante con gotitas doradas. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**53. Pico de Madera** · `Pico_Madera.png`

```
Ícono de juego: un pico de minero en diagonal todo de madera marrón clara, simple. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**54. Pico de Piedra** · `Pico_Piedra.png`

```
Ícono de juego: un pico de minero en diagonal con cabeza de piedra gris y mango de madera. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**55. Pico de Hierro** · `Pico_Hierro.png`

```
Ícono de juego: un pico de minero en diagonal con cabeza de hierro plateado brillante y mango de madera. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**56. Pico de Oro** · `Pico_Oro.png`

```
Ícono de juego: un pico de minero en diagonal con cabeza de oro brillante y mango rojo oscuro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**57. Pico Cósmico** · `Pico_Cosmico.png`

```
Ícono de juego: un pico de minero en diagonal con cabeza violeta galáctica llena de estrellitas y mango azul oscuro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**58. Trébol de Hierro** · `Amuleto_Trebol.png`

```
Ícono de juego: un trébol de cuatro hojas de metal gris plateado brillante. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**59. Herradura de Cobre** · `Amuleto_Herradura.png`

```
Ícono de juego: una herradura de cobre naranja brillante con clavitos dorados, abierta hacia arriba. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**60. Estrella Fugaz** · `Amuleto_Estrella.png`

```
Ícono de juego: una estrella amarilla con cola de estela celeste y rosa, en diagonal. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**61. Ojo de Dragón** · `Amuleto_Dragon.png`

```
Ícono de juego: una gema redonda roja con pupila de reptil dorada, en un engarce dorado. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**62. Corona Cósmica** · `Amuleto_Corona.png`

```
Ícono de juego: una corona violeta galáctica con estrellas brillando y gemas arcoíris. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**63. Gema Común** · `Gema_Comun.png`

```
Ícono de juego: una gema facetada tipo diamante gris perla claro. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**64. Gema Rara** · `Gema_Rara.png`

```
Ícono de juego: una gema facetada tipo diamante azul eléctrico #3FA9FF. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**65. Gema Épica** · `Gema_Epica.png`

```
Ícono de juego: una gema facetada tipo diamante violeta #B04DFF. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**66. Gema Legendaria** · `Gema_Legendaria.png`

```
Ícono de juego: una gema facetada tipo diamante dorado naranja #FFB21E, con rayos de luz detrás. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```

**67. Gema Mítica** · `Gema_Mitica.png`

```
Ícono de juego: una gema facetada tipo diamante rosa fucsia #FF3D7F con reflejos arcoíris y rayos de luz detrás. Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```


---

## Si querés cambiar el estilo de todo junto

La frase de estilo es la misma en todos los prompts. Si querés, por ejemplo, borde violeta en vez de azul marino, cambialo igual en todos (o pedile a Claude que regenere este archivo con el cambio), así todo sigue combinando.

Frase de estilo de los íconos (para copiar sola):

```
Estilo: ícono de juego para celular, tipo simulador de Roblox, caricatura gordita y redondeada con formas infladas, contorno grueso azul marino casi negro del mismo ancho en todo el borde, colores súper saturados y brillantes tipo caramelo con degradés vivos, brillo blanco de plástico arriba a la izquierda, sombra suave adentro en la parte de abajo, un leve resplandor de color alrededor y dos o tres destellos de estrella chiquitos cerca del objeto, se entiende al primer vistazo aunque se vea chiquito, sin texto, sin letras, sin números. Un solo objeto centrado con margen alrededor, imagen cuadrada 1:1, fondo liso de un solo color verde puro #00FF00, sin degradé, sin sombra y sin nada más en el fondo.
```
