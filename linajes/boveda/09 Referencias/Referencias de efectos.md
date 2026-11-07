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

## Más creadores (segunda búsqueda)

### deadj.rodev (TikTok, Roblox con Claude y ForgeGUI)
[Canal](https://www.tiktok.com/@deadj.rodev). Sin canal de YouTube con ese nombre. Vi 3 videos en hojas de cuadros y leí 1 guía; los videos no tienen subtítulos. El video más visto: 286.500 vistas, sobre mapas.
- Mapas en 3 pasos: definir el estilo, juntar referencias de ese estilo, escribir el prompt.
- "Hacé un bioma de selva" no sirve: hay que decir qué, dónde, por qué y cómo, sin relleno.
- Le pasa unas 10 fotos numeradas y explica cada una ("la cuarta muestra..."), con partes marcadas en rojo.
- Usa una foto de otra cosa para explicar movimiento: un velocista real para la carrera.
- Guía del dragón, en 8 partes: tarea y qué no tocar, función en el juego, aspecto, quieto, mecánica, controles, calidad de movimiento y pruebas.
- Sus escenas funcionan por el texto grande, los cortes de cámara y el premio final, no por modelos complejos.

### Otros
- [Develuper](https://www.youtube.com/watch?v=KdARoj-IWds): el peso empieza en la animación. Eventos de balanceo e impacto, congelar animaciones un instante, sacudida suave, destello blanco y silueta en blanco y negro con ColorCorrection.
- [IndividualKex](https://www.youtube.com/watch?v=FpGgpUWEb_k): la reacción del golpeado dura una décima de segundo. Efectos simples y coherentes valen más que muchos detalles; el sonido es lo que más conviene pagar con calidad.
- [YorusDevs](https://www.youtube.com/watch?v=LWx1TePJU84): primero arte conceptual, una cosa por imagen sobre fondo blanco, y que la IA copie la imagen. Después jugar, decir qué se siente mal y repetir cientos de veces.
- [Ludius](https://www.youtube.com/watch?v=QPNniezfQVA): compara los tipos de combate de Roblox y cuándo conviene cada uno.
- [MajesticDev](https://www.youtube.com/watch?v=ZGfGIxwx1w4): su juego mejoró con animadores, artistas de efectos y sonidistas de su comunidad.

### Qué cambia para Linajes
- Cada pedido de efecto lleva imágenes numeradas y explicadas, con la parte buena marcada.
- Primero una imagen del efecto; después lo construimos copiando esa imagen propia.
- El golpe se arregla como conjunto: animación, pausa, sonido y efecto. Hoy no tiene sonido, y eso también lo hace sentir barato.
