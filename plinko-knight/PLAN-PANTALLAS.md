# Plinko Knight · Plan de mejora de pantallas (etapa 12, 27/10/2026)

Pedido de Juani: "todas las pantallas siguen viéndose feas; los bichos deberían ser más grandes; el selector de reliquias y pergaminos sigue feo, la tienda también; el HUD sigue feo; reutilizá cosas de Forja Rápida".

**Estado: plan para aprobar.** No se tocó código.

---

## 1. Qué está mal hoy (mirando las capturas de la etapa 11)

| Pantalla | Problema |
|---|---|
| **Pelea: monstruo** | El dibujo mide unos 140 × 170 px en una pantalla de 1292: es lo más chico de todo, y es el enemigo. La columna derecha queda casi vacía. La barra de vida es una tirita con letra chica. |
| **Pelea: maña del jefe** | Es una caja de texto rojo sobre negro, encima de la vida del jefe. Se lee como un cartel de error. |
| **Pelea: columna izquierda** | Hay 4 cajas apiladas con 3 tamaños de letra distintos. La lista de clavijas especiales ("4 Roja · Nv 4") se sale por abajo cuando hay 5 tipos. |
| **Bandeja de abajo** | Son 10 casilleros grises iguales. Los vacíos dicen "Pergamino" y "Libre", y esa letra chica es lo que más se ve. La bola es un texto en vez de un dibujo. Las reliquias no muestran su rareza. |
| **Tienda** | Las cartas son planas y del mismo gris. La 5.ª queda cortada en el borde. El precio es rojo cuando no alcanza, y queda feo. "Renovar" y "¿Qué sale?" son grises y chatos. El "Próximo: Slime Verde (90 de vida)" es texto suelto, sin dibujo. |
| **Cofre (elegir reliquia)** | Son 3 cartas iguales azul oscuro. La rareza es una palabra gris chica, sin color. Atrás se transparenta la tienda (el título queda encima de "TIENDA 9 oro…"). |
| **Ficha de reliquia y pergaminos** | Es un panel con letra chica y 4 botones del mismo tamaño ("◀ Mover", "Mover ▶", "Vender", "Cerrar"). Para usar un pergamino no hay ninguna ventana: se toca el casillero y listo. |
| **Inicio, derrota, victoria y ajustes** | Son un panel gris con texto y dos botones. No tienen dibujos ni color. |
| **Letra** | La pixel (Arcade) no tiene tildes: sale "ARRASTRA Y SOLTA" y "PRACTICA". |

**La causa de fondo:** el estilo pixel (etapa 10b) se armó con 8 imágenes y el resto se dibuja con cajas planas. Forja Rápida ya tiene un kit completo que funciona.

## 2. Qué se trae de Forja Rápida (sin gastar créditos)

Las imágenes de Forja están subidas a tu cuenta, así que **los mismos IDs sirven en Plinko Knight**. Se copia el código; nada se comparte entre los dos juegos (regla de CLAUDE.md: cada juego con su carpeta).

| De Forja | Qué es | Dónde va en Plinko |
|---|---|---|
| `Estilo.superficie` + `GameConfig.Gui` | Botones gordos con brillo en 9 colores, estirables sin deformar (9-slice), y blanco para teñir | Todos los botones: BAJAR, Comprar, Renovar, Volver a bajar, Usar, Vender |
| `Ventanas.luau` | Ventana con fondo oscurecido, cabecera de color con rayas, título grande con ícono, X roja, "pop" al abrir y una sola a la vez | Tienda, cofre, ficha de reliquia, pergamino, elegir bola, ajustes, derrota y victoria |
| `Estilo.pildora` | Píldora de HUD con ícono que salta cuando sube el número | Vida, oro y piso, arriba a la izquierda |
| `Estilo.barra` | Barra gorda con relleno de color y número adentro | Vida del monstruo y tu vida |
| `Estilo.baldosa` + `Estilo.Rarezas` | Baldosa con degradé del color de la rareza | Casilleros de reliquias, cartas de tienda y cofre (gris común, celeste rara, dorada legendaria) |
| `Estilo.marcar` / marco "Destacado" | Marco dorado con rayos | La reliquia legendaria del cofre y la tienda |
| `Estilo.globito` | Globito rojo con número o "!" | "!" en la bandeja si te alcanza para algo; cuántos pergaminos tenés |
| `Estilo.presionable` | El botón se achica al tocarlo y suena | Todos los botones |
| `MenuAjustes.luau` | 4 interruptores grandes | Ajustes (sonido, música y efectos reducidos) |
| `Avisos.luau` | Aviso que entra desde arriba con ícono | "¡Nueva reliquia!", "No te alcanza el oro" |
| Letra **FredokaOne** | Redonda y gorda, con tildes | Todo el texto. La pixel queda solo para los números del golpe y el COMBO, que no llevan tildes |

**Lo que no cambia:** los dibujos de monstruos, reliquias y bolas (ya son de dibujo animado y van bien con este kit), el tablero, el fondo violeta y cian, Fuerza azul × Multi rojo, y todo lo de "sensación" de la etapa 10.

**Decisión que hay que tomar:** esto **reemplaza el estilo pixel de la etapa 10b** (marcos de piedra, casilleros pixel). Mezclar los dos se vería peor que cualquiera de los dos solos. Por eso arrancamos con maquetas (paso 12a) para que lo veas antes de cambiar el juego.

## 3. Pantalla por pantalla

Medidas en el lienzo de 960 × 480 (en celular horizontal, 1 unidad ≈ 1 px).

### Pelea (la que más se ve)
```
┌───────────────────────────────────────────────────────────────────┐
│ [♥ 42/50] [● 12] [JEFE 9/9]      COMBO ×7           [🚪] [⚙]      │ ← píldoras de Forja
│ ┌─────────────┐  ┌─────────────────┐   ╔═ RABIA ═══════════╗      │
│ │ FUERZA│MULTI│  │                 │   ║ te pega el doble  ║      │ ← cinta roja, no caja
│ │  144  │ 20  │  │     tablero     │   ╚═══════════════════╝      │
│ │  = 2.916    │  │   (sin cambios) │      ┌──────────────┐       │
│ └─────────────┘  │                 │      │              │       │
│ ● ● ● ● ●        │                 │      │   MONSTRUO   │       │ ← 260 × 260 (hoy ~110)
│ 4 4 4 4 4        │                 │      │   (×2,3)     │       │
│                  │                 │      └──────────────┘       │
│                  │                 │      Rey de los Huesos      │
│                  │                 │   [████████░░ 4126/4500]    │ ← barra gorda de Forja
├──────────────────┴─────────────────┴─────────────────────────────┤
│ (bola)  [📜2] [📜]   │  [💎][💎][💎][  ][  ]                       │ ← baldosas por rareza
└───────────────────────────────────────────────────────────────────┘
```
- **Monstruo ×2,3:** 260 × 260 en vez de unos 110. Va sin recuadro negro: el dibujo flota sobre un brillo del color de la zona. Más grande cuando respira, se sacude y se rompe (ya está en la etapa 10). **El jefe va todavía más grande (300)** y con corona de luz.
- **Vida del monstruo:** barra gorda de Forja, de 260 de ancho, con el número adentro en letra grande.
- **Maña del jefe:** cinta roja de Forja (cabecera con rayas) arriba del jefe, con el nombre grande ("RABIA") y la regla corta abajo.
- **Arriba a la izquierda, 3 píldoras de Forja:** vida, oro y "PELEA 3/9" (o "JEFE"). Reemplazan las 3 cajas apiladas. Saltan cuando cambian.
- **Panel Fuerza × Multi:** queda igual de lugar, pero las cajas pasan a baldosas brillantes azul y roja de Forja, con borde oscuro.
- **Clavijas especiales:** una fila de bolitas del color de cada tipo con el número abajo (●4 ●4 ●4), en vez de la lista de texto. El nivel aparece como estrellitas al pasar el mouse o tocar.
- **Bandeja de abajo, más baja y sin letras:**
  - La **bola** es su dibujo, redondo.
  - Los **2 pergaminos** son baldosas con el dibujo del pergamino; vacíos, son un hueco oscuro sin texto.
  - Las **5 reliquias** son baldosas del color de su rareza con el ícono grande; vacías, son un hueco punteado sin texto. Se nota cuál está "apagada" por el Silencio del jefe (gris y tachada).

### Tienda (ventana de Forja, cabecera verde "Tienda" con ícono)
- **3 pestañas como en Forja:** Reliquias · Clavijas · Pergaminos. Así no hay 5 cartas apretadas: cada pestaña muestra 2 o 3 cartas grandes.
- **Carta =** baldosa del color de la rareza. Adentro: ícono de 96 px, nombre grande y qué hace en 2 líneas como máximo. Abajo, el **botón verde de Forja con la moneda y el precio**. Si no te alcanza, el botón queda gris con candado (no rojo).
- **Columna derecha (como "Próxima zona" de Forja):** el **próximo monstruo dibujado** a 140 px, con su vida en barra, y si es jefe, su maña. Debajo, "Renovar · 2" (botón azul) y "¿Qué sale?" (botón chico con ícono de lupa).
- **BAJAR:** botón amarillo enorme de Forja, abajo a la derecha, que late.
- **Oro:** la píldora de Forja en la cabecera, con "+3 por ganar" en verde al lado.
- Comprar una clavija sigue igual: la ventana se corre y tocás el tablero.

### Elegir reliquia (cofre del jefe)
- Ventana de Forja con cabecera **dorada** "¡Cofre del jefe!" y un cofre abierto de ícono.
- **3 cartas grandes de baldosa de rareza** que entran de a una con rebote (ya existe el whoosh). Las raras brillan celeste. **La legendaria lleva el marco "Destacado" con rayos que giran.**
- En cada carta: ícono de 120 px, nombre, rareza en una píldora de su color y qué hace. Botón verde "Elegir".
- "Más tarde" pasa a botón gris chico, abajo.
- **Fondo opaco** (no se transparenta la tienda).

### Ficha de reliquia (al tocar una de la bandeja)
- Ventana chica de Forja con cabecera del color de la rareza: ícono grande, nombre, qué hace y lo que juntó (ej.: "Callo: +12 Fuerza").
- En la tienda: **flechas ◀ ▶ redondas a los costados del ícono** (mover), botón rojo "Vender · +3 oro", X para cerrar. Afuera de la tienda solo se ve la información.

### Pergaminos (hoy no tienen ventana)
- Tocar un pergamino abre una **ventana chica violeta**: dibujo grande, qué hace, botón verde "Usar" y X. Si pide tocar clavijas, dice "Después tocá 2 clavijas" y se corre como la tienda.
- Así no se usa un pergamino sin querer, como pasa ahora.

### Inicio / elegir bola (en la máquina y en el mostrador)
- Ventana de Forja con cabecera azul. Las 3 bolas son **baldosas grandes con su dibujo** y lo que hacen. Las bloqueadas aparecen oscuras, con candado y "Llegá a la zona 2".
- Tu mejor marca va en 3 píldoras (mejor piso, jefes, mazmorras).
- Botón amarillo grande "¡A la mazmorra!".

### Derrota y victoria
- **Derrota:** cabecera roja "Caíste en el piso 4", el **monstruo que te ganó dibujado grande** y la barra "Llegaste a 4 de 9" con tu récord marcado. Botón verde enorme "Volver a bajar" y gris chico "Salir".
- **Victoria:** cabecera dorada con rayos, el Rey de los Huesos roto y confeti. Lo que desbloqueaste aparece como baldosas con ícono, no en una lista de texto.

### Ajustes
- Se copia `MenuAjustes` de Forja: interruptores verdes y grises grandes para Sonido, Música y Efectos reducidos.

### Avisos y tutorial
- Avisos de Forja (entran desde arriba con ícono): nueva reliquia o bola, "No te alcanza el oro", "Más despacio".
- La mano del tutorial va con FredokaOne: "¡ARRASTRÁ Y SOLTÁ!", con tildes.

## 4. Orden de trabajo (un bloque por vez, con capturas)

| Paso | Qué | Costo | Control |
|---|---|---|---|
| **12a** | Copiar el kit de Forja a `plinko-knight/src/client/` (`Estilo`, `Ventanas`, IDs en `Config.Gui`) y armar **3 maquetas PNG** con Python (pelea, tienda, cofre), como `forja-rapida/arte/gui/maqueta_*.png` | 0 créditos | **Elegís: OK o qué cambio** |
| 12b | Pelea: monstruo grande, barras, píldoras, cinta de maña, panel y clavijas | 0 | Capturas |
| 12c | Bandeja: bola, pergaminos y reliquias en baldosas; ficha de reliquia; ventana de pergamino | 0 | Capturas |
| 12d | Tienda con pestañas, cartas de rareza y próximo monstruo | 0 | Capturas |
| 12e | Cofre, inicio, derrota, victoria, ajustes, avisos y tutorial | 0 | Capturas |
| 12f | Repaso: compu y emulador de celular a 30 FPS o más, botones de 44 px o más, "Efectos reducidos". Rehacer ícono y miniaturas con las pantallas nuevas | 0 | **Probalo 5 minutos** |

**Opcional, con créditos de ForgeGUI (aviso antes de generar):** 10 íconos de pergamino si los actuales no se leen grandes, un cofre abierto y una cinta de jefe. Serían unas 12 imágenes. Si no, se usan los dibujos que ya hay y los de Forja.

## 5. Reglas que se mantienen

- Solo se toca `plinko-knight/`. Lo de Forja **se copia**: `forja-rapida/` no se toca.
- Todo número (tamaños, colores, IDs) va en `Config.luau`, y todo lo visual queda en `client/Estilo.luau`.
- Nada de casino: no hay monedas cayendo de una bandeja, ni "premio", ni rayos de "jackpot" en cosas compradas. Los rayos van solo en la reliquia legendaria del cofre, que es gratis y se ve antes de elegir.
- Sin emojis en el juego (los de este plan son solo para el dibujo). La mano del tutorial pasa a imagen.

## Avance

### 12a · Kit y maquetas (27/10/2026)
- **Kit copiado de Forja:** `client/Kit.luau` (botones, superficie 9-slice, píldora, barra, baldosa, marco Destacado, X, globito, rayas, íconos de la hoja de Forja o cualquier `rbxassetid://`, textos con FredokaOne), `client/Ventanas.luau` (ventana con cabecera, pestañas, lista con scroll, panel) y los IDs y medidas en `Config.Kit`. Todavía no lo usa ninguna pantalla: `client/Estilo` sigue mandando hasta el paso 12b.
- **Probado en Studio** (`arte/maquetas/12a-kit-en-studio.jpg`): una ventana de prueba con botones, baldosa con el jefe y barra se ve igual que en Forja, sin errores.
- **Maquetas** (`arte/maquetas/12a-pelea.png`, `12a-tienda.png`, `12a-cofre.png`), armadas con `arte/maquetas/maquetas.py` y las piezas reales. Cambios respecto del plan que salieron armándolas:
  - **Paneles con el centro oscuro:** el Panel de Forja es celeste brillante; entero, en la mazmorra se ve pesado. Queda el borde celeste con brillo y adentro un degradé "Noche".
  - **El marco "Destacado" va detrás de la carta**, porque encima la tapa.
  - En la píldora de la pelea va la **Corona** de la hoja de Forja (el ícono "Jefe" es otro dibujo).
  - Los nombres largos ("Corona del Rey Caído") se achican para entrar.
- **Para 12b en adelante:** la mano del tutorial (DisplayOrder 40) queda encima de las ventanas (30), así que hay que bajarla. El corazón de la píldora de vida es el pixel de 10b; si se nota, se pide uno nuevo a ForgeGUI.

### 12b · Pelea (27/10/2026)
- **Monstruo** (`client/Monstruo.luau`): sigue en 3D, así los números del golpe, la luz que vuela y el estallido salen delante. Ahora el cartel es transparente y mide 21 × 28 (antes 10 × 12): el dibujo pasó de unos 110 a unos 240 px en una pantalla de 1292. En su cara van, de arriba a abajo, la **cinta roja de la maña** (nombre grande y la regla), el dibujo sobre un halo de su color, el **nombre** (dorado si es jefe) y la **barra de Forja** con "654 / 750". El jefe va un 12 % más grande y con **rayos dorados que giran** (`Config.Feel.GiroRayos`). Cuando se rompe, los pedazos son del color del monstruo.
- **Columna izquierda** (`client/Pantallas.luau`): 3 **píldoras** del kit (vida con el corazón, oro con la moneda de Forja y "PELEA 3/9" / "JEFE 9/9" / "PRÁCTICA" con la corona) que **saltan cuando cambian**, la zona debajo, el **panel** con borde celeste y centro oscuro, y las clavijas especiales como **bolitas de color** con cuántas hay y un **globito rojo con el nivel**.
- **Panel FUERZA × MULTI** (`client/Numeros.luau`): cajas azul y roja con degradé y brillo, letra redonda con borde oscuro. Se juntan y chocan igual que antes.
- **Salir y Ajustes:** botones del kit (rojo con la puerta, gris con el engranaje).
- **Arreglo del kit:** las esquinas de las piezas salían dobles con el lienzo de Plinko (×2 en 1080p). `Kit` ahora calcula el 9-slice con el tamaño propio del objeto.
- **Probado en Play** (`arte/comparaciones/v5/12b-*.jpg`): práctica, jefe de zona 2 con Rabia (el golpe baja la barra y el contraataque pega el doble) y jefe final con Cristal Maldito. La consola no tiene errores.
- **Queda para los pasos que siguen:** la bandeja de abajo (12c) y la letra pixel del tutorial y de "COMBO" (12e).
