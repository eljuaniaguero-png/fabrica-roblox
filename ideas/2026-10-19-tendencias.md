# Radar de tendencias — 2026-10-19

> Base: [2026-10-11-tendencias.md](2026-10-11-tendencias.md) (8 días). **Hoy no pude consultar la web** (los permisos de búsqueda y de descarga quedaron sin aprobar en modo autónomo), así que los números son del 11/10. Hay que volver a revisarlos antes de arrancar a construir.
> Pedido de esta vuelta: 5 ideas en lugar de 3, y elegir la más rentable y dopamínica.

## Errores nuestros que esta elección tiene en cuenta

Salen de [revision-2026-10-11.md](revision-2026-10-11.md), de la ficha de Mutant Lab y de "Cambios 19-10-2026" de Forja Rápida.

1. **Tres juegos en paralelo y ninguno publicado.** Un cuarto juego no sale hasta que Forja Rápida esté publicada.
2. **Premios que no se pueden conseguir**: al sacar las misiones, las Runas Mágicas y parte de las Monedas de Forja quedaron sin forma de ganarse. Cada premio tiene que tener una fuente anotada en la ficha desde el día 1.
3. **El guardado de Pisada Sonora puede perder progreso.** ProfileStore desde el primer commit, reusando el de Forja Rápida.
4. **La monetización se decidió tarde** (ADN por Robux + fusión al azar = ítem aleatorio pagado). Se define antes de programar: nada que dé un resultado al azar se compra con Robux, ni directo ni con moneda comprable.
5. **Modelos pesados**: criaturas de 25 a 40 partes, cuando la guía pide 12 como máximo. Tope de partes por modelo desde la ficha.
6. **Trabajo repartido en worktrees.** Un solo árbol de trabajo.

## Las 5 ideas

Puntaje del 1 al 5. "Reuso" es cuánto código sale de Forja Rápida o Mutant Lab (inventario, ProfileStore, tienda, índice/museo, analítica).

| # | Idea | Tendencia (11/10) | Rentable | Dopamina | Fácil (1 persona) | Reuso | Saturación (5 = poca) | **Total** |
|---|---|---|---|---|---|---|---|---|
| 1 | **Pesca al Compás** | Heavyweight Fishing 19K y #1 en Trending; Fish It! ~74,9K | 5 | 5 | 3 | 5 | 3 | **21** |
| 2 | Rebote Afinado | +1 Stone Skipping ~37K en un mes | 3 | 4 | 5 | 3 | 4 | 19 |
| 3 | Corral Blindado | Steal An Egg ~1,11M; Break and Steal an Egg ~98,7K | 5 | 4 | 2 | 4 | 1 | 16 |
| 4 | Eco Escondido | Search For The Needle ~19,1K | 2 | 3 | 5 | 3 | 4 | 17 |
| 5 | Brigada Toon | Firefighting Sim ~17,2K | 3 | 3 | 3 | 2 | 4 | 15 |

---

### 1. Pesca al Compás ⭐ ELEGIDA
- **Mecánica que funciona**: pesca con progresión (tirar, sacar, vender, mejorar la caña, zonas con peces raros). Es el género que más se sostiene en el tiempo y el de sesiones más largas.
- **Giro propio (música)**: cada pez se saca siguiendo su ritmo. Acertar el beat tira y errar afloja; los peces raros cambian de tempo. Las mejores cañas agrandan el margen de error.
- **Loop de 30 segundos**: tirás → picada → 5 a 10 s de ritmo → revelación del pez con su rareza → al balde → vendés o seguís buscando el raro.
- **Alcance del prototipo**: muelle + agua; lanzar y esperar la picada; ritmo con 3 patrones validado en el servidor; venta; una mejora de caña.
- **Riesgo principal**: desfase entre el audio y el toque en celular. Se prueba el primer día.

### 2. Rebote Afinado
- **Mecánica**: "+1" con lanzamiento: cada rebote de la piedra suma un stat y con más stat llegás más lejos.
- **Giro**: cada rebote toca la nota siguiente de una melodía, y soltar justo en el beat da un rebote extra.
- **Loop**: cargar → soltar en el beat → rebotes con notas → +1 → boya → premio / rebirth.
- **Prototipo**: lanzamiento calculado en el servidor; notas por rebote; stat +1; 3 boyas; rebirth.
- **Riesgo**: es casi la misma fórmula que Pisada Sonora y se comerían entre sí. Mejor como modo dentro de Pisada Sonora.

### 3. Corral Blindado
- **Mecánica**: juntar huevos que generan plata en tu base y robar de bases ajenas.
- **Giro**: tu base se defiende con trampas que ubicás vos, así que cada robo es un mini-atraco con puzzle. Puede usar las criaturas de Mutant Lab.
- **Loop**: juntar → incubar → elegir una base ajena → esquivar trampas → mejorar tus trampas.
- **Prototipo**: 4 bases; huevos en el mapa; monedas por segundo; robo validado en el servidor; 1 trampa.
- **Riesgo**: es el género más saturado y el más difícil de proteger contra exploits. Además, los huevos al azar chocan con la regla 4.

### 4. Eco Escondido
- **Mecánica**: búsqueda relajada de objetos escondidos en mapas grandes.
- **Giro (sonido)**: cada objeto emite un sonido que se vuelve más agudo y más fuerte a medida que te acercás. Se juega con el oído, y en grupo cada uno escucha una pista distinta.
- **Loop**: escuchar → seguir el sonido → encontrar → tachar del álbum → mapa nuevo.
- **Prototipo**: 1 mapa; 10 objetos con sonido 3D; álbum; contador por mapa; premio por completar.
- **Riesgo**: monetiza poco (cosméticos y pistas) y el contenido se agota rápido.

### 5. Brigada Toon
- **Mecánica**: simulador de oficio cooperativo (apagar incendios, rescatar, mejorar el equipo).
- **Giro**: incendios con forma de criaturas toon que se deforman al apagarlas, con el estilo de Mutant Lab.
- **Loop**: alarma → llegar → apagar → rescatar → cobrar → mejorar la manguera.
- **Prototipo**: 1 barrio; incendio que aparece; manguera; cobro; 1 mejora.
- **Riesgo**: necesita vehículos y física de agua, que es lo más caro de construir. La tendencia es chica.

---

## Por qué Pesca al Compás

- **Rentable sin azar pago**: se monetiza con gamepasses fijos (balde +50, auto-venta, cañas y botes cosméticos, zona VIP con peces propios pero con las mismas probabilidades) y con developer products que no dan nada al azar (pack de slots, revivir una racha). Ningún cebo ni moneda que dé resultados al azar se vende por Robux (error 4).
- **Dopamina doble**: el acierto rítmico (feedback cada medio segundo) y la revelación de rareza al final. Son dos picos por ciclo de 30 s, cuando la pesca común tiene uno solo.
- **Retención**: un índice de peces (el Museo de Forja Rápida, reusado) más eventos de horario ("hora del jefe") que hacen volver.
- **Es la ventaja de Juani**: la música es el diferencial que nadie copia fácil.
- **Reuso alto**: ProfileStore, inventario, tienda, museo y analítica ya están hechos en Forja Rápida.

**Condición**: se empieza recién cuando Forja Rápida esté publicada (error 1). Mientras tanto, lo único que se hace es esta ficha y el prototipo del ritmo para probar la latencia en celular.

## Datos que no pude verificar
- Los números son del 11/10; hoy no hubo acceso a la web.
- No sé si en esta semana apareció algún juego de pesca con ritmo (sería un competidor directo). Es lo primero que hay que chequear.
- Si un gamepass de "zona VIP" con peces exclusivos cuenta como azar pago: lo diseñé con las mismas probabilidades para no entrar en la política, pero conviene confirmarlo en la política vigente.

## Fuentes
Las mismas del informe del 11/10 (LevelUpPlay Trending, Rotrends Up-and-Coming, Dexerto, TryHard Guides, Bo3.gg, Playnews). Ver [2026-10-11-tendencias.md](2026-10-11-tendencias.md).
