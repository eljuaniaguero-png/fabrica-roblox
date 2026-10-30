# Pesca al Compás — ficha

> Elegida el 19/10/2026 en modo autónomo (pedido de Juani: "busquen ideas con /tendencias, elijan la mejor en rentabilidad, dopamina y tiempo de juego, ejecútenla").
> Base: informe [2026-10-11-tendencias.md](2026-10-11-tendencias.md). **El 19/10 no hubo permiso para buscar en la web**, así que los números son del 11/10 (8 días). Hay que actualizarlos antes de invertir más.
> **Estado: prototipo en código, sin probar en Studio.** Falta el OK de Juani (punto de control 1 de CLAUDE.md).

## Por qué esta y no las otras dos del radar

| Idea | Plata | Dopamina | Tiempo de sesión | Decisión |
|---|---|---|---|---|
| **Pesca al Compás** | Alta: cañas, carnadas, zonas, pases | Alta: la picada sorpresa y el pez raro | **La más alta del radar** (Fish It! ~91 min por sesión) | ✅ Elegida |
| Rebote Afinado | Media | Muy alta | Corta (tiros de 5 s) | ❌ Compite con Pisada Sonora |
| Corral Blindado | Muy alta | Alta | Alta | ❌ Género saturado y difícil para 1 persona |

Además usa la ventaja de Juani (música/ritmo) y reusa el guardado de Forja Rápida.

## Mecánica

Pesca con progresión: tirar → esperar la picada → **mini-juego de ritmo** → pez al balde → vender → mejor caña → zonas nuevas.
**Giro propio:** cada pez tiene su ritmo (lento en negras, nervioso en corcheas, jefe que cambia de tempo). Las notas caen a una línea; tocás en el beat y cada acierto suena como la nota siguiente de una melodía. Mejor caña = ventana de acierto más grande.

## Loop de 30 segundos

Tocás **Lanzar** → 2 a 6 s de espera con la boya → **¡PICÓ!** → 6 a 12 notas al ritmo del pez → si acertás el % que pide el pez, lo sacás → al balde → vendés o seguís buscando el raro.

## Alcance del prototipo (lo que está programado)

> 19/10, tarea 3 del modo autónomo: el loop se pasó a la **ficha v2 de la bóveda** (`Juegos/Pesca al Compás/Ficha de Pesca al Compás.md`). Lo de abajo reemplaza la versión anterior (5 peces, cañas que subían la suerte). **Sin probar en Studio todavía.**

1. Muelle gris generado por código (`Mundo.luau`), solo si no hay una carpeta `Muelle` en Workspace: agua, 3 `PuntoPesca` y el puesto `Vendedor`.
2. Lanzar: mantener y soltar. Más carga = boya más lejos = pez más pesado. **La rareza no cambia.**
3. Picada a los 2 a 5 s (1 s la primera vez). El servidor sortea rareza (60/25/10/4/1) y pez en ese momento.
4. Ritmo: 7 peces de la isla 1 con patrón fijo cada uno, más la Ballena jefe, que todavía no sale. Barra de tensión, Perfecto/Bien/Error, racha +10% y Afinado x2. El servidor juzga con la misma función que usa el cliente para el feedback.
5. Primeros 5 minutos: la primera tirada es la Mojarra (la más fácil), la tercera es un Raro garantizado.
6. Venta del balde en el puesto, mejoras de caña (ventana) y balde (capacidad), nivel por XP.
7. Calibración obligatoria la primera vez (8 golpes) y botón para repetirla. El desfase se guarda en el perfil.
8. Vigilancia de bots: marca en la consola, sin baneo.

Guardado con ProfileStore (`PescaAlCompas_Jugadores_v1`), mismo patrón que Forja Rápida.
**Falta para probar:** correr `wally install` dentro de `pesca-compas/` (crea `ServerPackages/ProfileStore`), después `rojo serve pesca-compas` en un place vacío.

## Decisiones que tomé solo (cambiables)

- Juego aparte en `pesca-compas/`, no modo de otro juego.
- Controles: tocar la pantalla, clic o barra espaciadora; todo sirve.
- Probabilidades fijas y visibles en el HUD. Ninguna mejora ni compra las cambia (ficha v2).
- Melodía: inventada, escala pentatónica (siempre suena bien aunque falles).
- Anti-trampa del prototipo: el servidor sortea el pez antes del ritmo, exige que haya pasado el tiempo real del patrón y que los toques sean posibles (no más de 2N+4 y separados por al menos 60 ms). Un tramposo todavía puede mandar toques perfectos y sacar siempre Afinados; la vigilancia lo marca para revisarlo a mano.

## Monetización pensada (NO programada, necesita OK)

- Pase **Caña Dorada** (cosmético + ventana +10 %).
- Pase **Balde Gigante** (más lugar en el balde).
- ~~Producto **Carnada Brillante** (30 min de suerte x2)~~: descartado el 19/10, porque vende suerte con Robux. La monetización vigente es la de la sección 8 de la ficha v2.
- Nada de vender la suerte en forma de cajas.

## Riesgo principal

La **latencia del audio en celular**. Por eso el ritmo lo mide el cliente con su propio reloj y el servidor juzga con margen. Hay que probar en celular antes de seguir.

## Pendiente

- [ ] OK de Juani a la ficha.
- [ ] Probar en Studio (`rojo serve pesca-compas`) + captura.
- [ ] 3 opciones de estilo visual para que Juani elija (Gemini propone y arma prompts de imágenes).
- [ ] Sonidos propios (marcados con `-- SONIDO:`).

#ideas #pesca-al-compas
