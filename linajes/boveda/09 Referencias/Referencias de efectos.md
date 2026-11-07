# Referencias de efectos (7 nov 2026)

Solo ideas: ninguna imagen ni textura de otro juego va a Roblox.

## Por qué los nuestros se ven baratos
- Usamos una textura de humo genérica, cilindros Neon y cubos: son formas de bloque, no dibujos.
- Todo aparece y se apaga parejo. No hay un instante fuerte y un final distinto.
- Cada efecto tiene 2 o 3 capas. Las vitrinas buenas apilan 6 a 8 durante menos de medio segundo.

## Qué hacen los efectos buenos (visto cuadro por cuadro)
Vitrinas: [Frigid Rush](https://www.youtube.com/watch?v=2fwT64lFtao), [Naoya's Rushdown](https://www.youtube.com/watch?v=e8qRthFY-gs).
1. Destello blanco de 1 o 2 cuadros en el punto del golpe, con estrella de puntas finas.
2. Arcos finos y curvos, con punta afilada, que siguen la dirección del golpe.
3. Anillos finos con borde de color y centro blanco, nunca discos llenos.
4. Líneas de velocidad que salen del golpe, oscuras sobre cielo claro.
5. Humo dibujado con bordes definidos, que queda después del destello.
6. Chispas chicas que salen lejos y remolinos en el piso que tardan en irse.
7. Blanco en el centro y color en el borde: el color del Linaje queda en el contorno.

## Recetas técnicas
- Tres tiempos: aviso, impacto (máximo contraste) y salida suave ([80 Level](https://80.lv/articles/vfx-staples-shape-color-and-motion/)).
- Texturas animadas (flipbook) de 4x4 u 8x8, en una sola pasada, con textura blanca teñida por `Color`. 512 px alcanza para chispas; 1024 para lo grande.
- Golpes de 6 a 8 studs, especiales de 15 a 25. `LightEmission` 1 para energía, 0 en fondos muy claros. `ZOffset` 1 o 2 ([ParticleFX, página de vendedor](https://particlefx.studio/roblox/anime-vfx)).
- Se pueden hacer en Blender: forma, ruido, cuadros sobre negro y hoja de cuadros ([DevForum](https://devforum.roblox.com/t/how-to-make-animated-slash-effects-with-only-blender/1794034)).
- Disparar el efecto con un evento dentro de la animación, en el cuadro exacto del golpe ([tutorial](https://www.youtube.com/watch?v=TkNZETIu0CM)).
- `LightEmission` negativo da un contorno oscuro.

## Cómo hace buenos juegos la gente con Claude
Fuentes flojas: casi todo son anécdotas de creadores y resúmenes automáticos. No encontré datos de juegos exitosos hechos así.
- Darle referencias reales (videos y capturas) antes de construir, y que pregunte ([Mobile Legends en 3 prompts](https://www.youtube.com/watch?v=jLPJGc1thYs)).
- El primer arte sale mal: hay que iterar con referencias ([Steal a Vehicle](https://sozai.app/transcript/viral-steal-egg-ripoff-claude/index.md)).
- Código en archivos con Rojo, reglas en datos, revisores automáticos ([tutorial](https://sozai.app/transcript/make-roblox-game-ai-tutorial/index.md)).
- Convertir cada error en una regla escrita, con su motivo.
- Juzgar efectos congelando inicio, medio y final, no con una sola captura.
- Probar en Play y leer la consola tras cada cambio ([Luis Mori](https://luismori.dev/article/roblox-game-development-with-mcp/)). La prueba automática no reemplaza jugar.
- Los anuncios no salvan un juego flojo: 10.000 Robux dieron 410 visitas en el caso de Steal a Vehicle.

## Plan propuesto
Hacer en Blender un paquete propio: destello, estrella, arco, anillo, humo y chispa. Usarlo primero en el golpe común y mostrarlo antes de pasarlo a los 9 poderes.
