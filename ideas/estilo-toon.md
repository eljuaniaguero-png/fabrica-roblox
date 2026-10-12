# Mutant Lab — estilo toon (guía)

Este es el estilo visual de todo el juego. Reemplaza a la guía anterior de "laboratorio de caricatura de noche" en todo lo que choque.
Referencia: la imagen del personaje triangular amarillo sobre pedestal crema con anillo rosa y fondo violeta, que el usuario eligió el 12 oct.

## Las seis reglas

1. **Contorno grueso** violeta casi negro alrededor de cada forma, como un dibujo animado.
2. **Colores planos y saturados.** Sin reflejos de plástico, sin texturas realistas. Como mucho una sombra de un solo escalón.
3. **Brillante y alegre.** El mundo es un atardecer violeta y rosa, no una noche oscura. Todo se ve claro y con color.
4. **Formas geométricas simples** combinadas: bolas, triángulos, rectángulos redondeados, óvalos. Gracioso por la forma, no por el detalle.
5. **Todo lo vivo tiene ojos enormes:** blanco, pupila gigante violeta oscura, un puntito de brillo y párpados de color.
6. **Lo importante resalta por color y contorno,** no por oscuridad alrededor.

## Paleta nueva (punto de partida; ajustar en la sala de muestra)

| Uso | Color | Hex |
|---|---|---|
| Contorno de todo | Violeta casi negro | #241A3A |
| Pupilas | Violeta oscuro | #2B1B4A |
| Cielo arriba | Violeta azulado | #3B3A9E |
| Cielo abajo | Violeta rosado | #7A4FB0 |
| Horizonte y niebla | Rosa atardecer | #F2A3C7 |
| Pisos claros y pedestales | Crema durazno | #FFC9A3 |
| Detalle rosa (anillos, bordes) | Rosa chicle | #FF6FA8 |
| Amarillo principal | Amarillo sol | #FFC93A |
| Naranja | Naranja | #FF7A2E |
| Rojo (narices, alertas) | Rojo tomate | #FF3B3B |
| Lo del laboratorio y el ADN | Verde menta ácido | #5CF0A0 |
| Agua y vidrio | Celeste | #5CC8FF |
| Paredes y metal | Lila grisáceo | #9C8FD0 |
| Texto e interfaz claro | Blanco | #FFFFFF |

Los colores de elemento se mantienen pero un punto más claros y saturados, para que lean sobre el fondo violeta.

## Cómo se logra en Roblox

- **Materiales:** SmoothPlastic en casi todo. Neon solo en detalles chicos que tengan que brillar.
- **Iluminación:** luz ambiente alta, reflejos especulares en cero o casi, sombras suaves, ColorCorrection con más saturación y brillo. Cielo con degradé violeta a rosa y una luna grande de caricatura.
- **Contorno:** el sistema que se elija en la sala de muestra (casco invertido o Highlight), aplicado por un solo módulo (por ejemplo shared/Toon.luau) que cualquier modelo pueda usar. Highlight tiene un límite de cuántos se ven a la vez, así que para cosas numerosas se usa casco invertido.
- **Rendimiento:** el contorno duplica piezas. Usarlo en criaturas, comida, objetos interactivos y siluetas grandes del escenario; en decoración chica y lejana, se puede omitir.
- **Todo pasa por Paleta.luau y Toon.luau.** Nada de colores ni contornos sueltos en otros archivos.

## En Blender (más adelante)

Cada pieza se exporta con su malla de contorno, y los renders usan sombreado plano con contorno, para que se vean igual que en el juego.

## Decisiones de la base (pedido T0, 12 oct)

- **Contorno: casco invertido.** Prueba en el laboratorio lleno (20 criaturas, 915 cascos): el casco no sumó llamadas de dibujo (126 contra 124 sin contorno) ni tiempo de la placa de video; el Highlight duplicó las llamadas (269), subió un 35 % el tiempo de la placa, dibuja una raya finita solo alrededor de la silueta y Roblox no muestra más de 31 a la vez. El casco suma triángulos (de unos 200.000 a 310.000), por eso la esfera del casco tiene pocas caras.
- **Cómo se usa:** `shared/Toon.luau`. El servidor llama a `Toon.aplicar(modelo)` o `Toon.marcar(modelo)` y cada cliente le pone los cascos (`client/Contornos.client.luau`), así no viajan por la red. Grosores en `Config.Toon`: 0,12 studs en criaturas, comida y objetos, 0,22 en escenario; las piezas chicas (ojos, párpados, manchas) llevan una raya más fina. Sin contorno: lo transparente (vidrio), lo muy chico y lo que tenga el atributo `SinContorno` (dibujos del piso).
- **Mallas del casco:** esfera, caja, cilindro y cuña en `mutant-lab/arte/export/Toon/_PaqueteToon.obj`. Hasta que se importen a `ReplicatedStorage > Arte > Toon`, el juego las arma por código (EditableMesh), que en el juego publicado solo anda con "Enable Mesh / Image APIs" prendido. Las MeshParts de Blender todavía no llevan contorno: su casco va a venir de Blender.
- **Sin reflejos:** un MaterialVariant "Toon" bien rugoso reemplaza a todo el SmoothPlastic del juego (`Toon.iluminar`).
- **Cielo:** imágenes propias con el degradé y la luna dibujada (con contorno y cráteres), hechas por `mutant-lab/arte/scripts/toon_base.py`. La luna está hacia +Z. Hora fija de día (14:30), así el cielo se ve con sus colores.
- **Paleta:** los nombres viejos se mantienen (el código, los scripts de Blender y `ArteColores.luau` los buscan por nombre) y apuntan a los colores nuevos; los colores base de la guía están en `Paleta.Toon`. `Paleta.Noche` quedó solo para el fondo de los renders de Blender. Los colores de las especies todavía no cambiaron (pedido T1).
- **Interfaz:** ventanas violeta azulado (#3B3A9E) con texto blanco y contorno violeta casi negro.
