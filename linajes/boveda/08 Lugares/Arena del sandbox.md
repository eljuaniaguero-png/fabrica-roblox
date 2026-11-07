# Arena del sandbox

Primera versión, 7 nov 2026. Se genera con `linajes/src/server/ArenaMapa.server.luau`. Los números están en `Config.Arena.Mapa`.

- **Lugar:** Puerto Óxido, frente a las grúas. Mide 288 x 260 studs y tiene paredes invisibles.
- **Zona segura:** esquina suroeste, con el maniquí al lado.
- **Centro:** círculo celeste de 26 studs, pensado para el evento Rey del muelle.
- **Cobertura:** cuatro grupos de contenedores, cajas, barriles y barreras de hormigón.
- **Altura:** dos torres con rampa, unidas por una pasarela a 18 studs.
- **Bordes:** contenedores dobles al sur, este y oeste; baranda al mar al norte.

Pendiente: piso y objetos que se rompan, eventos, y cambiar las piezas de bloques por los modelos de `arte/exports/puerto-oxido/`.

## Luz (7 nov)
Por horas en `Config.Mundo.Luz`; se mezcla en `Clima.client.luau`. Noche azul y legible, con faroles de sodio como luz principal. Niebla más baja dentro de la arena para ver al rival.

Referencias: [Develuper](https://www.youtube.com/watch?v=vkEXLmRAQgs), [DevForum, paso a paso](https://devforum.roblox.com/t/improve-lighting-step-by-step/1387033). Regla que tomamos: la noche se resuelve con luces locales, no con oscuridad.

Para probar una hora: atributo `HoraPrueba` en Lighting.

## Matones de práctica (7 nov)
3 matones en `Config.Combate.Matones`, con modelo propio sin pañuelo ni cadena. Te buscan fuera de la zona segura, embisten desde lejos, hacen combos de 2 o 3 golpes y a veces se cubren. Reaparecen a los 6 s y dan 60 de experiencia.

## Kit y noche (7 nov)
Las piezas viven en `ServerStorage.ArenaKit` (asset 80380787186308) y se colocan con `ArenaMapa.server.luau`. Valores de luz: `src/shared/Iluminacion.luau`. La arena queda siempre de noche; fuera de ella sigue el ciclo por horas.

## Rincón lindo (7 nov)
Prueba de la dirección de arte en `ArenaRincon.server.luau`, valores en `Iluminacion.luau` (`Rincon`). Si Juani lo aprueba, la receta pasa al resto del mapa.
