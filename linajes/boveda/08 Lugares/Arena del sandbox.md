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
3 matones con vida de 120 en `Config.Combate.Matones`. Te buscan fuera de la zona segura, avisan y pegan. Reaparecen a los 6 s y dan 40 de experiencia. Usan el cuerpo común: todavía no el modelo de matón de `arte/exports/enemigo-maton/`.
