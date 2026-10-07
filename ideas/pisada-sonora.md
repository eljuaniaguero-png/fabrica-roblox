# Pisada Sonora — ficha del prototipo

Origen: [2026-10-06-tendencias.md](2026-10-06-tendencias.md), idea 1.
Estado: **aprobada (2026-10-06)**, versión 2, con los cambios del usuario: melodía clásica de dominio público, checkpoints, consecuencia al caer, consumibles, tienda y conversión de velocidad a monedas.
Versión 3 (2026-10-06): OK del usuario + **nota desafinada al caer** + orden por etapas. Estilo elegido: **A — Neón nocturno**.
Próximo punto de control: **prototipo jugable terminado**.

## Etapa 1 (núcleo) — se prueba primero

1. Las baldosas tocan una melodía clásica de dominio público, nota por nota, con un solo sample de piano.
2. Un checkpoint después de cada puerta.
3. Al caerte: suena una nota desafinada (mismo sample, tono corrido medio semitono), perdés 10% de la velocidad y reaparecés en el último checkpoint.

Lo demás (rebirth, tienda, consumibles, guardado) es la Etapa 2: ya está escrito y se prueba después del núcleo.

## Concepto en una línea

Obby incremental: cada paso te da +1 de velocidad y cada baldosa que pisás toca la siguiente nota de una melodía clásica. La velocidad se puede gastar en un rebirth (multiplicador permanente) o convertir en monedas para la tienda.

## Loop de 30 segundos

1. Corrés por el anillo: cada paso suma velocidad y la melodía avanza nota por nota.
2. Llegás a una puerta que pide una velocidad mínima; si te falta, das otra vuelta.
3. Pasás, tocás el checkpoint y encarás el tramo de saltos. Si te caés, perdés un poco de velocidad y volvés al checkpoint.
4. En el camino agarrás consumibles (Turbo, Escudo, Resorte).
5. Decidís: ¿convierto velocidad en monedas para comprar mejoras, o la junto para un rebirth?

## Sistemas

| # | Sistema | Dónde | Qué hace |
|---|---|---|---|
| 1 | **Velocidad por paso** | servidor + UI | Cuenta pasos por distancia (validada en el servidor) y suma `PuntosPorPaso × multiplicador de rebirth × bonus de zapatillas × turbo`. Ajusta `WalkSpeed` con un tope. |
| 2 | **Baldosas con melodía** | cliente | Cada baldosa nueva que pisás toca **la siguiente nota** de la melodía (Oda a la Alegría, Beethoven, 1824, de dominio público) con **un solo sample de piano**, cambiando el tono con `PlaybackSpeed`. La melodía da la vuelta sola al terminar. |
| 3 | **Puertas, checkpoints y caídas** | servidor | Puertas por velocidad mínima (colisión por jugador). Un checkpoint detrás de cada puerta. **Al caer**: volvés al último checkpoint y perdés el 10% de la velocidad, salvo que tengas un Escudo (se gasta solo). |
| 4 | **Rebirth** | servidor + UI | Cuesta 500 de velocidad: te deja en 0, vuelve el checkpoint a 0 y sube el multiplicador. |
| 5 | **Economía y tienda** | servidor + UI | Botón **Convertir**: toda tu velocidad pasa a monedas (1 a 1) y la velocidad queda en 0. La **tienda** vende consumibles y la mejora permanente **Zapatillas** (+25% de velocidad por paso en cada nivel, el precio sube por nivel). El servidor valida cada compra. |
| 6 | **Consumibles** | servidor + UI | **Turbo**: el doble de velocidad ganada durante 30 s. **Resorte**: salto alto durante 30 s. **Escudo**: la próxima caída no te quita velocidad. Se compran en la tienda o se agarran en el mapa (reaparecen cada 30 s). Turbo y Resorte se usan con un botón del HUD; el Escudo se usa solo. |
| 7 | **Guardado** | servidor | Velocidad, rebirths, checkpoint, monedas, zapatillas e inventario. DataStore solo funciona en lugares publicados: mientras tanto se guarda en memoria y avisa por consola. |

Pasamos de 5 a 7 sistemas porque el usuario agregó tienda, consumibles y economía.

## Decisiones tomadas (eran ambiguas, elegí la más simple)

- "Al caerte pase algo" → perdés el 10% de la velocidad, con un aviso en pantalla. El Escudo te salva.
- La melodía avanza por pasos, no por baldosa fija: camines para donde camines, suena la melodía en orden. El ritmo lo ponés vos con tu velocidad.
- Convertir se hace desde un botón del HUD, en cualquier lugar.
- Los consumibles del mapa son para todos: cuando alguien agarra uno, desaparece y reaparece a los 30 s.
- Inventario: máximo 9 de cada consumible.
- Comprar y agarrar consumibles es determinista: nada de cajas ni azar.

## Mundo

- Anillo 1 (36 baldosas) con el spawn al sur.
- Camino → Puerta 1 (100) → Checkpoint 1.
- Tramo de saltos (5 plataformas).
- Anillo 2 (28 baldosas).
- Camino → Puerta 2 (300) → Checkpoint 2 → Meta.
- Consumibles: un Turbo en el anillo 1, un Escudo antes de los saltos y un Resorte en el anillo 2.
- El trazado está pintado con el estilo Neón nocturno (2026-10-06). HUD completo en `StarterGui.HUD` con fuente Michroma.

## Audio (todo en `Config.luau`)

- Nota de piano: "Piano Note C4", gratuita en la Creator Store (ID 96243649310055). Reemplazable.
- Melodía: Oda a la Alegría (Beethoven), escrita en semitonos dentro de `Config.Melodia`.

## Queda AFUERA del prototipo

- Más de una zona o melodía.
- Mascotas, Robux, gamepasses, tablas de posiciones.
- Efectos visuales elaborados.

## Pregunta que tiene que responder el prototipo

¿Escuchar la melodía mientras corrés, y elegir entre rebirth y tienda, dan ganas de dar "una vuelta más"?

## Guía de estilo

**Elegida: A — Neón nocturno.** Respetarla en todo el juego:

- Paleta: #FF3CAC rosa, #2BD2FF cian, #7B2FF7 violeta, #FFE45E amarillo, #14112B fondo.
- Baldosas: cuadradas y finas, material Neon sobre base de vidrio oscuro.
- Puertas y checkpoints: marcos de neón (puertas rosa, checkpoints cian, meta amarilla).
- Luz: noche (ClockTime 0), bruma violeta, mucho bloom.
- Fuente de la UI: Michroma.

Las muestras quedaron guardadas en `ServerStorage.MuestrasEstilo` (fuera del mapa). Puertas: rosa si te falta velocidad, cian si ya pasás. Bases de vidrio oscuro debajo de cada baldosa en `Pista.Bases`.

Propuestas:

| | A — Neón nocturno | B — Pastel de día | C — Madera al atardecer |
|---|---|---|---|
| Paleta | #FF3CAC rosa, #2BD2FF cian, #7B2FF7 violeta, #FFE45E amarillo, #14112B fondo | #4FCFA8 menta, #FF9461 durazno, #9C7DFF lila, #FFD43B manteca, #2E3A59 azul marino | #D9643A terracota, #E8B23A mostaza, #6B8F3E oliva, #F2E3C6 crema, #3B2A20 marrón |
| Materiales | Neon sobre base de vidrio oscuro | SmoothPlastic mate | WoodPlanks sobre marco de Wood |
| Luz | Noche (ClockTime 0), bruma violeta, mucho bloom | Mediodía, cielo celeste, bruma suave | Atardecer, bruma naranja cálida |
| Formas | Baldosas cuadradas finas, marcos de neón | Discos redondos con borde azul, postes con bolitas | Tablones cuadrados gruesos, marcos de madera |
| Fuente | Michroma | FredokaOne | Bangers |
