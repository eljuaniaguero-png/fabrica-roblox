# Cómo publicar (etapa 11, 27/10/2026)

Lo hace Juani. Claude no publica ni cambia el público.

## Archivos de esta carpeta

| Archivo | Para qué |
|---|---|
| `icono-512.png` | Ícono del juego (512 × 512) |
| `miniatura-1-tiro.png` | Un tiro contra el jefe: combo ×7, "¡BIEN!", Fuerza × Multi |
| `miniatura-2-jefe.png` | El Rey de los Huesos al lado del tablero de colores |
| `miniatura-3-mejoras.png` | Las 3 reliquias del cofre del jefe |
| `capturas/` | Las capturas de Studio de donde salen |
| `armar.py` | Vuelve a armar el ícono y las miniaturas (`python plinko-knight/publicar/armar.py`) |

Ninguna tiene texto agregado ni la cara de tu avatar (se tapó el busto del tablero).

## 0. Antes: el nombre

"Plinko" es marca registrada y además es el nombre de un juego de casinos online. **Hay que cambiarlo** antes de publicar (el juego hoy se llama "Caballero de Plinko" en Roblox y "Plinko Knight" adentro). El nombre de adentro se cambia en una sola línea: `Config.NombreJuego` en `plinko-knight/src/shared/Config.luau`.

## 1. Descripción para la página

> Bajá a la mazmorra y peleá tirando una bola por un tablero de clavijas. Cada clavija que toca suma FUERZA o MULTI, y al caer, FUERZA × MULTI es el golpe que recibe el monstruo. Entre peleas gastá tu oro en la tienda: clavijas de colores, pergaminos y reliquias que cambian las reglas. Armá una combinación que pase de golpes de 30 a golpes de 50.000 y ganale al Rey de los Huesos: 3 zonas y 9 peleas. Si caés, volvés a bajar con bolas y reliquias nuevas desbloqueadas. Gratis y sin compras con Robux.

En inglés (si querés llegar a más gente):

> Descend into the dungeon and fight by dropping a ball through a board of pegs. Every peg it hits adds STRENGTH or MULTI, and when it lands, STRENGTH × MULTI is the hit your monster takes. Between fights, spend your gold at the shop on colored pegs, scrolls and relics that change the rules. Build a combo that goes from 30-damage hits to 50,000 and defeat the King of Bones: 3 zones, 9 fights. If you fall, head back down with new balls and relics unlocked. Free, no Robux purchases.

Género: **RPG** (o Estrategia). Revisado: no dice casino, apuesta, ficha, jackpot, premio ni suerte.

## 2. Publicar desde Studio

1. Abrí el place del juego en Studio y conectá Rojo (que tenga el código último).
2. **Archivo → Publicar en Roblox** (Alt+P). Como el place ya está en Roblox, se actualiza el mismo juego.
3. En la ventana de detalles: **Nombre** (el nuevo), **Género**, **Descripción** (la de arriba), **Ícono** y **Miniaturas** (los PNG de esta carpeta) → **Guardar**.
4. Te pide la primera pregunta de madurez (ver punto 3) → **Publicar**.

También se puede cargar todo en Creator Hub: create.roblox.com → **Creaciones** → el juego → **Configuración** (nombre, descripción, ícono, miniaturas).

## 3. Edad: 16+ o para todos

Roblox ya **no tiene una opción "13+"** para un juego como este: las dos salidas son **16+** o **para todas las edades**. El cuestionario está en Creator Hub → **Creaciones** → el juego → **Público** → **Cuestionario de madurez y cumplimiento**.

**Opción A · 16+ (la más rápida, gratis):**
- Cuenta con más de 2 días y sin sanciones.
- Verificación de edad (selfie de estimación facial o documento).
- En la primera pregunta del cuestionario, respondé **No** → queda "El contenido puede variar" y se publica solo para usuarios de 16+ con edad verificada.

**Opción B · Para todos (más chicos también, más jugadores):**
- Todo lo de la opción A, más: cuenta verificada, **verificación en 2 pasos** activada.
- **Roblox Plus o Premium 2 meses seguidos, o pagar 1.000 Robux** de depósito para publicar (Roblox dice que se devuelve). **Eso cuesta Robux: lo decidís vos.**
- En la primera pregunta respondé **Sí** y completá el cuestionario entero. Con este juego debería salir **Mínimo** o **Leve** (hay monstruos de dibujo que pelean, sin sangre ni compras; el chat es el de Roblox).
- Pasa la revisión "Kids and Select" de Roblox.

## 4. Abrirlo al público

Creator Hub → el juego → **Configuración de publicación → Administrar público** → **Administrar acceso** (arriba a la derecha) → pestaña **Público**: apagá **Amigos** (así puede entrar cualquiera) → **Guardar cambios**.

## 5. Justo después de publicar

- **Game Settings → Security → Enable Studio Access to API Services** y probá salir y volver: el guardado de verdad recién se prueba con el juego publicado.
- **Tamaño del servidor: 1 jugador** (la sala es en solitario): Creator Hub → el juego → Places → el place → **Configurar lugar** → Máximo de jugadores = 1. Si lo dejás en más, igual anda (ver la prueba del punto 6), pero la pared de récords y la vitrina muestran los del primero que entró.
- La analítica aparece en Creator Hub → el juego → **Analytics** (Onboarding, Progression, Economy y Custom events) a las 24–48 h.

## 6. Prueba con 3 jugadores (la tenés que hacer vos: el MCP no puede abrir Local Server)

Studio → pestaña **Prueba** → en "Clientes y servidores" elegí **3** → **Iniciar**. Se abren 4 ventanas (servidor y 3 jugadores). En cada jugador: si es la primera vez se sienta solo; si no, caminá a la máquina y tocá E. Tirá en los 3 a la vez: cada uno tiene su tablero, su monstruo y su vida. Para cerrar: **Limpiar** en la ventana del servidor.

## 7. Prompt para Gemini (si querés otro ícono)

Pegalo tal cual y guardá el resultado en `plinko-knight/publicar/icono-gemini.png`:

> Square game icon, 512x512, cute chunky pixel-art style. A dark dungeon board full of glowing round pegs in neon blue, red, green, purple and gold, seen from the front. A bright white glowing ball bouncing between the pegs with a light trail. On the right, a cartoon skeleton king with a golden crown, purple cape and a bone staff, looking surprised. Dark purple background with magenta and cyan neon edges, strong contrast, readable at small size. No text, no letters, no numbers, no logo, no coins, no cards, no dice, no slot machine.
