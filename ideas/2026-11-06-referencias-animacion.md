# Referencias de animación, golpes, efectos y FBX (6 nov 2026)

Solo se toman técnicas. Personajes, efectos y animaciones de otros juegos no se copian.
Muestra chica: 4 videos leídos en parte, 2 tiras de imágenes y 5 búsquedas web. Los datos de foros no son reglas oficiales.

## Golpes

- **Congelar el impacto (hit stop):** un ejemplo oficial de Capcom usa 8, 12 y 16 cuadros para golpes livianos, medios y fuertes. A 60 cuadros por segundo son unos 0,13, 0,20 y 0,27 s. Es un ejemplo de ese juego, no una regla.
- **La pausa va aparte:** no cuenta como inicio, golpe activo ni recuperación. No debería cambiar los tiempos que decide el servidor.
- **Golpes múltiples:** conviene acortar la pausa para que no se sientan pesados.
- **Proyectiles:** por lo general no frenan a quien dispara.
- **Lo que ya hacemos bien:** el plan de Animaciones tiene anticipación, acción, impacto, recuperación y un marcador `Impacto` para sincronizar todo.

**Para Linajes:** pausa visual solo en el cliente, frenando las animaciones de los dos personajes un instante. Los valores irían en `Config.luau`: empezar más cortos que el ejemplo y probar en una pelea real.

## Efectos

- **Corte en tres capas:** base (la forma grande), brillo (más chico y fuerte) y apoyo (chispas y detalles).
- **Cómo desaparece:** puede seguir el movimiento, bajar la opacidad o erosionarse. Una salida prolija ayuda tanto como la entrada.
- **La forma dice qué arma es:** un brillo fino parece un desgarro y uno afilado, un tajo largo.
- **Cuadro de impacto:** uno o más dibujos de alto contraste, hasta un color liso, antes o durante el golpe. Combina con el corte de contraste que ya está "a probar".
- **Beams de Roblox:** muestran una textura entre dos puntos, con color, brillo, velocidad y curva. Sirven para rayos, láseres y estelas sin modelos.
- **Estela de velocidad:** en un video de tu carpeta de referencias, la estela queda en el piso y sigue las curvas del recorrido, con chispas alrededor del corredor. Se entiende la ruta aunque el personaje se vea chico.
- **Efecto 2D sobre 3D:** el arte de un juego de héroes mezcla pintura con líneas y brillos planos. Es una dirección posible para nuestros efectos, no una decisión.

## FBX y bibliotecas

La regla del proyecto sigue igual: **las animaciones las hace Claude en Blender**. Esto sirve como consulta o base solo si Juani lo aprueba.

| Fuente | Licencia que encontré | Uso posible | A revisar |
|---|---|---|---|
| **Quaternius UAL 1 y 2** | CC0 según su página | La mejor opción gratis: más de 120 y 130 animaciones en FBX y glTF | Parte es paga. Confirmar la licencia de cada paquete y adaptar a R15 |
| **Kenney** | CC0 según una guía de terceros | Personajes simples | Confirmar en kenney.nl |
| **Mixamo** | Foros de Adobe: juegos comerciales sí, redistribuir archivos no | Referencia o base | Nada oficial sobre Roblox. Subir una animación puede contar como distribuirla |
| **Reallusion Free Fight** | Paquete pago, sin regalías según la tienda | 71 movimientos de pelea | Cuesta plata: necesita OK |
| **MoCap Online** | Pago desde USD 2,99 | Golpes y reacciones | Cuesta plata: necesita OK |
| **Rapamotion y kevdev** | Por paquete | Muestras de pelea | Revisar cada licencia antes de usar |

Importar a Roblox, según foros, no documentación oficial: revisar huesos y jerarquía, aplicar transformaciones, exportar con armature y animación horneada, y controlar la escala.

## Qué haría primero

1. Sumar la pausa visual al combo de Puños y comparar con y sin ella.
2. Hacer un efecto de golpe en tres capas para Fuerza Bruta.
3. Hacer una estela de Beam para el Velocista.
4. Probar un paquete CC0 solo para comparar movimientos, sin subirlo.

## Faltó

YouTube bloqueó por límite dos videos: daño de personajes de Masahiro Sakurai y un tutorial de ataque en Roblox con Blender. No analicé golpes reales cuadro por cuadro de esos videos.

## Fuentes

- [Capcom: hit stop](https://game.capcom.com/cfn/sfv/column/131545?lang=en)
- [Source Gaming: Sakurai sobre hit stop](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/)
- [Dustloop: glosario técnico](https://dustloop.com/w/BBCF/Esoterica)
- [onetupthree: Anatomy Of A Slash](https://www.youtube.com/watch?v=QyI8ZS-G9nw)
- [Zane Little: cuadros de impacto](https://www.youtube.com/watch?v=jW0lT1kZlWA)
- [Paul1Rb: Beams en Roblox](https://www.youtube.com/watch?v=yK_BSF3p8sk)
- [Thom O'Clock: estilo de arte de héroes](https://www.youtube.com/watch?v=PROaGYk19WY)
- [Quaternius UAL](https://quaternius.com/packs/universalanimationlibrary.html) y [UAL 2](https://quaternius.com/packs/universalanimationlibrary2.html)
- [Cinevva: alternativas gratis](https://app.cinevva.com/es/guides/free-character-animations-rigging)
- [Adobe: preguntas sobre licencia de Mixamo](https://community.adobe.com/questions-696/mixamo-faq-licensing-royalties-ownership-eula-and-tos-589400)
- [Reallusion Free Fight](https://discussions.reallusion.com/t/studio-mocap-series-free-fight-now-available/13716)
- [MoCap Online](https://mocaponline.itch.io/punch-starter-animation-pack/purchase)
- [DevForum: animación Blender a Studio](https://devforum.roblox.com/t/how-can-i-animate-skinned-mesh-r15-in-blender-and-import-into-studio/2962873)
- [DevForum: exportar FBX R15](https://devforum.roblox.com/t/is-there-any-way-to-export-the-roblox-r15-rig-as-an-fbx-without-messing-up-the-rig/2640687)
