# Plinko Knight · Idea de arte (25/10/2026)

Solo la idea. El juego sigue en gris hasta la etapa 8. Ahí esta idea pasa a ser una de las 3 muestras y Juani elige.
Las referencias están en `plinko-knight/Referencias/`. De ellas se toma **cómo se ordena y se lee la pantalla**, no los dibujos, nombres ni personajes.

---

## 1. Qué hay en cada captura

| Archivo | Qué muestra | Qué tomamos | Qué NO |
|---|---|---|---|
| 01-plinko-clasico-lo-que-NO-hacemos | Tablero triangular con casilleros de colores abajo | Clavijas chicas y blancas que se leen bien sobre fondo oscuro | **Los casilleros de abajo.** Es lo que hace que parezca de apuestas (regla 5) |
| 02-tablero-delante-de-un-monstruo | Clavijas por delante de un monstruo grande en sombra | El monstruo se ve detrás o al lado del tablero, así cada tiro "le pega" | Los casilleros de abajo, el contador de plata |
| 03-cartas-elegir-1-de-3 | 3 cartas grandes con dibujo, título y una frase, y un botón Saltar | La pantalla de mejoras: 3 cartas con costo arriba, ícono grande, una línea de texto, fondo oscurecido | Sus nombres y dibujos |
| 04 / 05 / 06-panel-objetivo-y-total | Panel lateral: objetivo arriba y total de la ronda en dos cajas (azul × rojo) | El panel de la izquierda: vida del monstruo arriba, daño del tiro abajo en números enormes | El símbolo de fichas y el "Reward $$$" |
| 07-panel-jefe-total-en-llamas | El mismo panel, pero en la pelea del jefe y con el total en llamas | Con el jefe, el panel cambia de color y el número grande "se prende fuego" cuando pasa cierto valor | — |
| 08 / 09-numero-de-toque | "+1" y "+2" blancos con brillo azul, chiquitos | El número que salta de cada clavija: corto, con brillo y borde oscuro | — |
| 10 / 11-multiplicador | "×3.6" y "×1.5" en rojo y blanco | El "×2" de la clavija roja: más grande que el "+2" y en rojo, para que se note | Decimales: nosotros usamos solo ×2 |
| 12-lanzador-arriba-clavijas-dos-colores | Lanzador arriba al centro, línea de puntería corta y clavijas redondas en dos colores sobre un paisaje | Lanzador fijo arriba; línea de puntos corta; clavijas de dos colores (normal y especial) que brillan sobre un fondo frío | El paisaje |
| 13-pelea-completa-tres-columnas | Pantalla entera: enemigos arriba con su vida, tablero al centro, paneles a los costados | El orden en 3 columnas para pantalla horizontal (ver sección 2) | El pixel art, los rieles curvos |
| 14-numero-de-dano-grande-sobre-enemigo | Un "565" enorme y blanco encima del enemigo cuando le pega | Al final del tiro, el total vuela al monstruo y aparece gigante encima | — |
| 15-carta-de-bola-en-panel-lateral | Columna de íconos (reliquias) y la carta de la bola actual con su efecto | Columna de mejoras que ya tenés, con la bola actual arriba | — |
| 16-jefe-grande-a-la-derecha | Enemigos chicos en cuadros con su vida arriba, y el jefe mucho más grande a la derecha | El jefe ocupa toda la columna derecha y es el doble de alto que un monstruo normal | El personaje |
| 17-linea-de-punteria-curva | Tablero muy lleno y una línea de puntos blanca que hace la curva de la caída | Línea de puntería con curva (ya cae con gravedad), pero **corta**, como dice el plan | El tablero tan lleno: el nuestro tiene unas 52 clavijas |
| 18-clavijas-especiales-con-numero | Clavijas grandes de colores con un número adentro, entre muchas chicas, y fuego violeta abajo | La clavija roja es un poco más grande que las normales y lleva "×2" escrito adentro. Fuego o niebla de color abajo de todo como piso | Las bombas, el contador de vida 999.999 |
| 19-pelea-completa-tres-columnas-grande | La misma de la 13, más grande | Confirma el orden en 3 columnas | — |
| 20-numeros-amontonados-lo-que-NO-hacemos | Varios números de daño encimados que no se leen | **Lo que no hay que hacer:** cada número nuevo sale un poco corrido y se va rápido, para que nunca se encimen | — |
| 21-cartas-con-cartel-de-titulo | Las 3 cartas con un cartel de tela arriba que dice "elegí una carta", y una barra fina arriba de todo con vida, oro y piso | Cartel arriba de las cartas ("Elegí una mejora") y barra fina arriba con vida y piso | Sus textos y dibujos |
| 22-cartas-con-brillo-por-tipo | Las cartas con un brillo alrededor de distinto color según el tipo | Cada carta brilla con el color de su tipo, y la que tocás brilla más | — |

---

## 2. Cómo se ordena la pantalla (celular en horizontal)

Las referencias 04 y 13 usan bien el ancho: **3 columnas**. El plan ponía el monstruo abajo del tablero, pero en un celular horizontal no entra alto. Propuesta:

```
┌───────────────┬──────────────────────────┬───────────────┐
│ ♥ 42/50       │      🛡 caballero         │  PELEA 3 de 7 │
│               │         ▼ lanzador        │               │
│ ┌───────────┐ │         · · ·            │   ┌───────┐   │
│ │ MONSTRUO  │ │   ●   ●   ●   ●   ●   ●  │   │       │   │
│ │ 60 / 85   │ │     ●   ●   ◉   ●   ●    │   │ 👹    │   │
│ └───────────┘ │   ●   ●   ●   ●   ●   ●  │   │       │   │
│               │     ●   ◉   ●   ●   ●    │   └───────┘   │
│  DAÑO DEL TIRO│   ●   ●   ●   ●   ●   ●  │   ████░░ 60   │
│ ┌─────┬─────┐ │     ●   ●   ●   ●   ●    │               │
│ │ 34  │ ×2  │ │   ●   ●   ●   ●   ●   ●  │  ⚙            │
│ └─────┴─────┘ │                          │               │
│ 🔥 ✖2 ✂        │   (sin casilleros abajo) │               │
└───────────────┴──────────────────────────┴───────────────┘
   izquierda          centro: tablero          derecha: monstruo
```

- **Izquierda (panel, refs 04-07 y 15):** tu vida, la vida del monstruo en número y el **daño del tiro** en grande. Abajo, los íconos de las mejoras que tenés.
- **Centro (refs 12 y 13):** el tablero ocupa todo el alto. El caballero y el lanzador van arriba. Abajo **no hay nada**: la bola cae a un piso liso.
- **Derecha (refs 02 y 14):** el monstruo grande en su cartel, con la barra de vida. Al terminar el tiro, el número vuela del panel al monstruo y aparece gigante encima (ref 14).

---

## 3. Paleta (va con la muestra "B · Cripta azul" del Prompt 8)

Las referencias que mejor se leen tienen **fondo frío y oscuro** con clavijas y números que brillan (01, 12, 13). Es la muestra B del plan. Igual en la etapa 8 se arman las 3 y elegís vos.

| Uso | Color |
|---|---|
| Fondo de la mazmorra | `#151B2E` azul noche |
| Piedra y paneles | `#2F3B57` gris azulado |
| Clavija normal | `#F5C542` dorado (ya decidido) |
| Clavija que duplica | `#E2323F` rojo rubí |
| Números de toque | `#E8FF3A` amarillo flúor, borde `#151B2E` |
| Toques de magia (velas, cristales, bola partida) | `#4FE3F0` cian |

---

## 4. Cada pieza

- **Clavijas (ref 12):** redondas, con brillo suave. Cuando las toca la bola se prenden más fuerte y quedan prendidas hasta el final del tiro, así se ve el camino.
- **Clavija roja (ref 18):** un poco más grande que las normales, con "×2" escrito adentro, así se entiende sin explicar.
- **Línea de puntería (ref 17):** puntos blancos que siguen la curva de la caída, pero solo el primer tramo.
- **Piso del tablero (ref 18):** niebla cian que se mueve abajo de todo. Es solo decoración: no tiene casilleros ni números.
- **Bola:** blanca y brillante. Bola de fuego con estela naranja; bola partida con una raya cian.
- **Números de toque (refs 08-09 y 20):** "+2" chico en amarillo flúor que sube y se va en medio segundo. Cada número sale un poco corrido del anterior para que no se encimen (la 20 muestra el error). El "×2" de la clavija roja (refs 10-11) es el doble de grande y rojo, con una sacudida corta.
- **Panel de daño (refs 04-07):** dos cajas grandes. Izquierda: el daño que se va sumando (cuando toca una roja, ese número se duplica ahí mismo). Derecha: cuántos ×2 hubo en el tiro, en rojo y con un salto cada vez que suma uno. **Con el jefe** el panel pasa a violeta y, si el daño supera 100, el número se prende fuego (ref 07).
- **Monstruo (refs 02 y 14):** imagen plana de Gemini en un cartel de piedra con su nombre y barra de vida. Cuando le pegan, el cartel se inclina, se pone blanco un instante y aparece el número gigante encima.
- **Jefe (ref 16):** ocupa toda la columna derecha, el doble de alto que un monstruo normal, con su nombre en un cartel.
- **Barra de arriba (ref 21):** una franja fina con vida, piso y ajustes. Va igual en la pelea y en las mejoras.
- **Cartas de mejora (refs 03, 21 y 22):** cartel arriba que dice "Elegí una mejora" y 3 cartas grandes sobre el fondo oscurecido. Cada carta brilla con el color de su tipo, y la que tocás brilla más y se agranda. Arriba el nombre, en el medio el ícono de Gemini y abajo una sola línea ("+1 de daño por clavija"). El borde es de un color por tipo: fuego naranja, duplica rojo, divide cian. Sin botón Saltar: siempre elegís una, como dice el plan.
- **Columna de mejoras (ref 15):** íconos chicos uno abajo del otro. Si tocás uno, se ve qué hace.
- **Fondo:** pared de piedra azulada, dos velas o cristales cian a los costados del tablero y niebla baja. Va oscuro y sin detalle en el centro, para que las clavijas resalten.

---

## 5. Lo que no se copia

Nada de dibujos, nombres, personajes, íconos ni marcos de los juegos de las capturas. Tampoco las fichas, el signo $, la plata ni los casilleros con números abajo del tablero. Las referencias quedan en git solo como guía para Claude y no se suben a Roblox.

---

## 6. Decisiones aprobadas por Juani (25/10/2026)

1. **Pantalla en 3 columnas:** panel a la izquierda, tablero al centro y monstruo a la derecha. Reemplaza al dibujo del plan que ponía el monstruo abajo del tablero.
2. **Panel de daño en dos cajas** (daño | ×2), como en las refs 04-07. La clavija roja no cambia: duplica lo que llevás. El panel solo lo muestra separado.
3. **Paleta B "Cripta azul"** como favorita. En la etapa 8 se arman igual las 3 muestras, y Juani elige la final.
