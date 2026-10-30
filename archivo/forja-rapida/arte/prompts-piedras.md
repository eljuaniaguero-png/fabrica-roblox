# Forja Rápida: prompts de las piedras que te pueden tocar (16 oct 2026, actualizado 17 oct)

Para Juani. 12 piedras por zona, 2 por rareza, 60 en total. Las hace Claude en Blender, en el mismo estilo de bloques que el resto.

## Las 6 rarezas

| Rareza | Cómo se ve | Alto | Triángulos |
|---|---|---|---|
| Común | piedra en bruto de cubitos, con grietas y cristalitos asomando | 2,5 studs | ≤ 1.500 |
| Rara | 3 a 5 columnas de cubitos en punta sobre roca, con centro que brilla | 3 studs | ≤ 2.500 |
| Épica | gema de cubitos "tallada", con engarce de metal y corazón que brilla | 3,5 studs | ≤ 4.000 |
| Legendaria | forma especial, adornos de oro y gemitas cuadradas engarzadas | 4 studs | ≤ 6.000 |
| Mítica | en capas: cáscara de cubitos transparentes y núcleo de otro color, anillo que gira | 4,5 studs | ≤ 8.000 |
| Celestial | la más rara: flota sobre un pedestal chiquito, con halo y gemitas que orbitan | 5 studs | ≤ 10.000 |

Cada rareza es más grande, más detallada y brilla más que la anterior, así el jugador se da cuenta de un vistazo de qué le tocó.

**Actualizado el 17 oct:** todas son **cuadradas, hechas de cubitos** como las geodas (nada redondo ni liso). El detalle sale de usar cubitos más chicos y muchos, con 2 o 3 tonos por color y detalles hechos con cubitos. Son **más grandes** (de 2,5 a 5 studs) para que luzcan en la exhibición, y todas entran en la tapa de un pedestal de 4 x 4 studs.

## Ojo: esto cambia el juego

Hoy el juego tiene **5 gemas por zona con 5 rarezas** (Común, Rara, Épica, Legendaria y Mítica) y 6 minerales secretos. Hacer los modelos no cambia nada del juego. Para que de verdad salgan estas 60, usá el prompt del final ("Pasar el juego a 12 piedras por zona"). Los **minerales secretos** (Cuarzo Lunar, Ámbar Fósil, etc.) siguen aparte, como están.

## Cómo usarlo

- De a una piedra, con `/clear` entre una y otra. Blender abierto y el complemento de Claude conectado.
- Empezá por las de la Pradera, que son las primeras que ve todo jugador.
- Cada prompt también saca el ícono para el Museo, así no tenés que pedirlo aparte.

## Las 60 piedras

| Zona | Común | Rara | Épica | Legendaria | Mítica | Celestial |
|---|---|---|---|---|---|---|
| 1 · Pradera | Cuarzo, Jaspe | Amatista, Ágata Musgosa | Esmeralda, Turmalina Rosa | Corazón de Pradera, Diamante Floral | Jade Arcoíris, Trébol de Cristal | Aurora Verde, Semilla del Mundo |
| 2 · Dunas | Arenisca, Ámbar | Citrino, Ojo de Tigre | Topacio Imperial, Cornalina | Sol del Desierto, Escarabajo de Oro | Lágrima de Faraón, Espejismo | Corona del Sol, Reloj de Arena Eterno |
| 3 · Glaciar | Cristal de Roca, Piedra Escarcha | Aguamarina, Celestina | Zafiro, Piedra Luna | Corazón de Hielo, Diamante Polar | Aurora Boreal, Estrella de Escarcha | Copo Eterno, Trono de Hielo |
| 4 · Volcán | Obsidiana, Basalto Rojo | Granate, Cristal de Azufre | Rubí, Ópalo de Fuego | Núcleo de Magma, Piedra Fénix | Ojo de Dragón, Llama Viva | Corazón del Volcán, Corona Ígnea |
| 5 · Abismo | Meteorita, Polvo Estelar | Iolita, Fluorita Nocturna | Ópalo Negro, Alejandrita | Fragmento de Nebulosa, Ojo del Vacío | Cometa Errante, Galaxia Espiral | Supernova, Agujero Negro |

---

## Zona 1 · Pradera

Todas van a `arte/fbx/Gemas_Zona1.fbx` y sus íconos a `arte/iconos/gemas/`.

### Cuarzo (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Cuarzo" de la zona Pradera, rareza Común:
cuarzo blanco lechoso con reflejos lila. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Cuarzo.png. No toques el código del juego.
```

### Jaspe (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Jaspe" de la zona Pradera, rareza Común:
jaspe rojo ladrillo con vetas crema. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Jaspe.png. No toques el código del juego.
```

### Amatista (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Amatista" de la zona Pradera, rareza Rara:
racimo de 3 puntas de amatista violeta. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Amatista.png. No toques el código del juego.
```

### Ágata Musgosa (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "AgataMusgosa" de la zona Pradera, rareza Rara:
ágata verde clara con manchitas verde oscuro como musgo. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/AgataMusgosa.png. No toques el código del juego.
```

### Esmeralda (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Esmeralda" de la zona Pradera, rareza Épica:
esmeralda verde intensa tallada rectangular. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Esmeralda.png. No toques el código del juego.
```

### Turmalina Rosa (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "TurmalinaRosa" de la zona Pradera, rareza Épica:
turmalina alargada rosa con la punta verde. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/TurmalinaRosa.png. No toques el código del juego.
```

### Corazón de Pradera (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CorazondePradera" de la zona Pradera, rareza Legendaria:
gema verde con forma de corazón de bloques, con hojitas doradas alrededor. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CorazondePradera.png. No toques el código del juego.
```

### Diamante Floral (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "DiamanteFloral" de la zona Pradera, rareza Legendaria:
diamante blanco con una flor de pétalos rosas de bloques adentro, que brilla. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/DiamanteFloral.png. No toques el código del juego.
```

### Jade Arcoíris (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "JadeArcoiris" de la zona Pradera, rareza Mítica:
jade tallado que pasa por todos los colores del arcoíris. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/JadeArcoiris.png. No toques el código del juego.
```

### Trébol de Cristal (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "TreboldeCristal" de la zona Pradera, rareza Mítica:
trébol de cuatro hojas de cristal verde con borde dorado. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/TreboldeCristal.png. No toques el código del juego.
```

### Aurora Verde (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "AuroraVerde" de la zona Pradera, rareza Celestial:
cristal verde claro con cintas de luz verde y celeste alrededor. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/AuroraVerde.png. No toques el código del juego.
```

### Semilla del Mundo (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "SemilladelMundo" de la zona Pradera, rareza Celestial:
semilla dorada gigante con un brote de hojas de cristal verde que brillan. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona1.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/SemilladelMundo.png. No toques el código del juego.
```

---

## Zona 2 · Dunas

Todas van a `arte/fbx/Gemas_Zona2.fbx` y sus íconos a `arte/iconos/gemas/`.

### Arenisca (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Arenisca" de la zona Dunas, rareza Común:
trozo de arenisca en capas arena, naranja y crema. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Arenisca.png. No toques el código del juego.
```

### Ámbar (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Ambar" de la zona Dunas, rareza Común:
gota de ámbar naranja translúcido. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Ambar.png. No toques el código del juego.
```

### Citrino (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Citrino" de la zona Dunas, rareza Rara:
punta de citrino amarillo dorado. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Citrino.png. No toques el código del juego.
```

### Ojo de Tigre (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "OjodeTigre" de la zona Dunas, rareza Rara:
piedra pulida marrón dorada con rayas brillantes. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/OjodeTigre.png. No toques el código del juego.
```

### Topacio Imperial (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "TopacioImperial" de la zona Dunas, rareza Épica:
topacio naranja dorado tallado en óvalo. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/TopacioImperial.png. No toques el código del juego.
```

### Cornalina (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Cornalina" de la zona Dunas, rareza Épica:
cornalina roja anaranjada tallada en gota. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Cornalina.png. No toques el código del juego.
```

### Sol del Desierto (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "SoldelDesierto" de la zona Dunas, rareza Legendaria:
gema redonda dorada con rayos de bloques alrededor como un sol. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/SoldelDesierto.png. No toques el código del juego.
```

### Escarabajo de Oro (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "EscarabajodeOro" de la zona Dunas, rareza Legendaria:
escarabajo de oro de bloques con alas de gema turquesa. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/EscarabajodeOro.png. No toques el código del juego.
```

### Lágrima de Faraón (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "LagrimadeFaraon" de la zona Dunas, rareza Mítica:
gota de lapislázuli azul con borde de oro y un ojo dibujado de bloques. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/LagrimadeFaraon.png. No toques el código del juego.
```

### Espejismo (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Espejismo" de la zona Dunas, rareza Mítica:
cristal medio transparente, celeste y naranja como el calor del desierto. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Espejismo.png. No toques el código del juego.
```

### Corona del Sol (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CoronadelSol" de la zona Dunas, rareza Celestial:
corona de oro con una gema-sol naranja en el centro y rayos de luz. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CoronadelSol.png. No toques el código del juego.
```

### Reloj de Arena Eterno (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "RelojdeArenaEterno" de la zona Dunas, rareza Celestial:
reloj de arena de oro y cristal con arena dorada brillante adentro. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona2.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/RelojdeArenaEterno.png. No toques el código del juego.
```

---

## Zona 3 · Glaciar

Todas van a `arte/fbx/Gemas_Zona3.fbx` y sus íconos a `arte/iconos/gemas/`.

### Cristal de Roca (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CristaldeRoca" de la zona Glaciar, rareza Común:
punta transparente de cristal de roca. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CristaldeRoca.png. No toques el código del juego.
```

### Piedra Escarcha (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "PiedraEscarcha" de la zona Glaciar, rareza Común:
piedra blanca con escarcha celeste encima. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/PiedraEscarcha.png. No toques el código del juego.
```

### Aguamarina (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Aguamarina" de la zona Glaciar, rareza Rara:
punta de aguamarina celeste verdoso. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Aguamarina.png. No toques el código del juego.
```

### Celestina (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Celestina" de la zona Glaciar, rareza Rara:
racimo de cristalitos celeste pálido. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Celestina.png. No toques el código del juego.
```

### Zafiro (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Zafiro" de la zona Glaciar, rareza Épica:
zafiro azul intenso tallado en óvalo. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Zafiro.png. No toques el código del juego.
```

### Piedra Luna (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "PiedraLuna" de la zona Glaciar, rareza Épica:
piedra luna redonda blanca con reflejo azul por dentro. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/PiedraLuna.png. No toques el código del juego.
```

### Corazón de Hielo (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CorazondeHielo" de la zona Glaciar, rareza Legendaria:
corazón de hielo azul con esquirlas blancas que salen y escarcha flotando. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CorazondeHielo.png. No toques el código del juego.
```

### Diamante Polar (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "DiamantePolar" de la zona Glaciar, rareza Legendaria:
diamante grande blanco celeste con forma de copo de nieve de bloques. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/DiamantePolar.png. No toques el código del juego.
```

### Aurora Boreal (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "AuroraBoreal" de la zona Glaciar, rareza Mítica:
cristal transparente con franjas verde, celeste y violeta como la aurora. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/AuroraBoreal.png. No toques el código del juego.
```

### Estrella de Escarcha (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "EstrelladeEscarcha" de la zona Glaciar, rareza Mítica:
estrella de 6 puntas de hielo celeste con centro blanco brillante. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/EstrelladeEscarcha.png. No toques el código del juego.
```

### Copo Eterno (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CopoEterno" de la zona Glaciar, rareza Celestial:
copo de nieve grande de cristal azul y blanco con luz celeste. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CopoEterno.png. No toques el código del juego.
```

### Trono de Hielo (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "TronodeHielo" de la zona Glaciar, rareza Celestial:
cristal de hielo con forma de trono chiquito y una gema azul flotando arriba. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona3.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/TronodeHielo.png. No toques el código del juego.
```

---

## Zona 4 · Volcán

Todas van a `arte/fbx/Gemas_Zona4.fbx` y sus íconos a `arte/iconos/gemas/`.

### Obsidiana (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Obsidiana" de la zona Volcán, rareza Común:
trozo de obsidiana negra brillante con filo. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Obsidiana.png. No toques el código del juego.
```

### Basalto Rojo (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "BasaltoRojo" de la zona Volcán, rareza Común:
piedra de basalto gris con puntitos rojos. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/BasaltoRojo.png. No toques el código del juego.
```

### Granate (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Granate" de la zona Volcán, rareza Rara:
granate rojo oscuro redondeado de bloques. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Granate.png. No toques el código del juego.
```

### Cristal de Azufre (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CristaldeAzufre" de la zona Volcán, rareza Rara:
racimo de cristales amarillo limón. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CristaldeAzufre.png. No toques el código del juego.
```

### Rubí (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Rubi" de la zona Volcán, rareza Épica:
rubí rojo intenso tallado en gota. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Rubi.png. No toques el código del juego.
```

### Ópalo de Fuego (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "OpalodeFuego" de la zona Volcán, rareza Épica:
ópalo naranja con destellos rojos y amarillos por dentro. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/OpalodeFuego.png. No toques el código del juego.
```

### Núcleo de Magma (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "NucleodeMagma" de la zona Volcán, rareza Legendaria:
esfera de bloques negra con grietas de lava naranja que laten y un centro amarillo. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/NucleodeMagma.png. No toques el código del juego.
```

### Piedra Fénix (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "PiedraFenix" de la zona Volcán, rareza Legendaria:
gema roja y naranja con alas de bloques como un fénix, que brilla fuerte. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/PiedraFenix.png. No toques el código del juego.
```

### Ojo de Dragón (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "OjodeDragon" de la zona Volcán, rareza Mítica:
gema roja con pupila amarilla de dragón y escamas de bloques alrededor. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/OjodeDragon.png. No toques el código del juego.
```

### Llama Viva (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "LlamaViva" de la zona Volcán, rareza Mítica:
cristal con forma de llama naranja y amarilla que parece moverse. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/LlamaViva.png. No toques el código del juego.
```

### Corazón del Volcán (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CorazondelVolcan" de la zona Volcán, rareza Celestial:
corazón de roca negra con lava que late y anillos de fuego. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CorazondelVolcan.png. No toques el código del juego.
```

### Corona Ígnea (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CoronaIgnea" de la zona Volcán, rareza Celestial:
corona de obsidiana con puntas de fuego y un rubí gigante. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona4.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CoronaIgnea.png. No toques el código del juego.
```

---

## Zona 5 · Abismo

Todas van a `arte/fbx/Gemas_Zona5.fbx` y sus íconos a `arte/iconos/gemas/`.

### Meteorita (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Meteorita" de la zona Abismo, rareza Común:
trozo de meteorito gris oscuro con puntitos metálicos. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Meteorita.png. No toques el código del juego.
```

### Polvo Estelar (Común)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "PolvoEstelar" de la zona Abismo, rareza Común:
piedrita violeta oscuro con brillitos blancos. Forma de su rareza: piedra en bruto: trozo de mineral de cubitos con forma irregular en escalones, grietas hechas con cubitos más oscuros, 2 o 3 cristalitos cuadrados asomando y cubitos de tierra o roca pegados en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 2,5 studs
de alto, ≤ 1.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/PolvoEstelar.png. No toques el código del juego.
```

### Iolita (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Iolita" de la zona Abismo, rareza Rara:
punta de iolita azul violeta. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Iolita.png. No toques el código del juego.
```

### Fluorita Nocturna (Rara)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "FluoritaNocturna" de la zona Abismo, rareza Rara:
cubo de fluorita con franjas violeta y verde. Forma de su rareza: cristal: 3 a 5 columnas de cubitos de distintas alturas que terminan en punta escalonada, saliendo de una base de roca de cubitos, con cubitos más claros en el centro que brillan suave y un par de cubitos sueltos en la base.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3 studs
de alto, ≤ 2.500 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/FluoritaNocturna.png. No toques el código del juego.
```

### Ópalo Negro (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "OpaloNegro" de la zona Abismo, rareza Épica:
ópalo negro con destellos de todos los colores. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/OpaloNegro.png. No toques el código del juego.
```

### Alejandrita (Épica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Alejandrita" de la zona Abismo, rareza Épica:
gema tallada que es verde de un lado y violeta del otro. Forma de su rareza: gema tallada de cubitos: forma de gema (ancha arriba y en punta escalonada abajo) hecha de cubitos, con cubitos claros en las 'caras' para que parezca tallada, un engarce cuadrado de metal con 4 garras de cubitos, un corazón de cubitos que brilla adentro (pieza aparte) y una base de roca con cristalitos.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 3,5 studs
de alto, ≤ 4.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Alejandrita.png. No toques el código del juego.
```

### Fragmento de Nebulosa (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "FragmentodeNebulosa" de la zona Abismo, rareza Legendaria:
cristal transparente con una nube rosa y violeta adentro y estrellitas. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/FragmentodeNebulosa.png. No toques el código del juego.
```

### Ojo del Vacío (Legendaria)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "OjodelVacio" de la zona Abismo, rareza Legendaria:
gema negra redonda con un aro violeta brillante y un centro blanco como un ojo. Forma de su rareza: gema legendaria de cubitos: forma especial, adornos de oro de cubitos con relieve (bordes, remaches), 2 o 3 gemitas cuadradas engarzadas alrededor, un corazón que brilla fuerte (pieza aparte) y cristales cuadrados que crecen de la base (las chispitas van como efecto de Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4 studs
de alto, ≤ 6.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/OjodelVacio.png. No toques el código del juego.
```

### Cometa Errante (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "CometaErrante" de la zona Abismo, rareza Mítica:
cristal celeste con forma de cometa y una cola de cubitos que brillan. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/CometaErrante.png. No toques el código del juego.
```

### Galaxia Espiral (Mítica)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "GalaxiaEspiral" de la zona Abismo, rareza Mítica:
disco de cristal violeta con una galaxia en espiral de estrellitas adentro. Forma de su rareza: gema mítica de cubitos: forma única en capas, una cáscara de cubitos transparentes y un núcleo de cubitos de otro color adentro, colores en degradé o arcoíris cubito por cubito, adornos de oro o plata y un anillo cuadrado de cubitos alrededor (pieza aparte para que gire); las partículas van como efecto.

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 4,5 studs
de alto, ≤ 8.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/GalaxiaEspiral.png. No toques el código del juego.
```

### Supernova (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "Supernova" de la zona Abismo, rareza Celestial:
esfera blanca brillante que explota en rayos rosa, violeta y dorados. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/Supernova.png. No toques el código del juego.
```

### Agujero Negro (Celestial)

```
Leé forja-rapida/arte/estilo-bloques.md si existe y mirá forja-rapida/arte/referencias/.
Guardá el .blend antes de empezar.

En Blender, con forja-rapida/arte/scripts/gemas.py (si no existe, crealo con el mismo
estilo que modelos.py), armá la piedra "AgujeroNegro" de la zona Abismo, rareza Celestial:
esfera negra con un anillo de luz violeta y naranja que gira alrededor. Forma de su rareza: gema celestial de cubitos, la más rara del juego: una gema principal en capas con núcleo que brilla y adornos, que flota sobre un pedestal chiquito de cubitos de su zona con escalones y cristales; un halo cuadrado de luz atrás, 2 o 3 gemitas de cubitos que orbitan y un anillo grande cuadrado (cada pieza que se mueve va separada para animarla en Roblox).

Estilo: que siga siendo CUADRADA, hecha de cubitos como las geodas del juego (nada redondo,
nada liso, sin biselado). La complejidad sale de usar cubitos más chicos (unos 0,15 a 0,2 studs)
y muchos: 2 o 3 tonos del mismo color cubito por cubito (más claro arriba, más oscuro abajo),
cubitos transparentes con otro color adentro cuando tenga sentido, y detalles chicos hechos
con cubitos (grietas, vetas, cristalitos, adornos). Juntá las caras que no se ven para no
pasarte de triángulos.

Reglas: 5 studs
de alto, ≤ 10.000 triángulos, pivote en el centro de la base. Tiene que entrar en
la tapa de un pedestal de exhibición (4 x 4 studs): como máximo 3,5 studs de ancho. Que se
distinga de las otras piedras de la zona aunque se vea chiquita en el celular.
Comprobación: render de frente y de costado (y encima del Pedestal_Exhibicion si ya existe),
y triángulos. Si te la apruebo, sumala a
arte/fbx/Gemas_Zona5.fbx y sacá un render cuadrado de 512 px con fondo transparente para el
ícono del Museo en arte/iconos/gemas/AgujeroNegro.png. No toques el código del juego.
```

---

## Pasar el juego a 12 piedras por zona (cuando tengas los modelos)

```
Leé ideas/forja-rapida.md. Abajo te pego la tabla de las 60 piedras. Quiero que cada zona
tenga 12 gemas: 2 por rareza, con 6 rarezas (Común, Rara, Épica, Legendaria, Mítica y
Celestial, la nueva y más rara), con estos nombres. Los minerales secretos quedan como están.
Primero plan, sin cambiar nada: qué cambia en GameConfig (gemas, rarezas, valores,
probabilidades), en la revelación (la Celestial con algo más grande que la Mítica), en el
Museo y las colecciones, en las misiones, en los avisos al servidor y en lo que ya tienen
guardado los jugadores. Las probabilidades tienen que seguir sumando 100 % (GUIA, sección 6).
Cuando apruebe el plan, hacelo, que use los modelos de arte/fbx/Gemas_Zona1..5.fbx si están
importados y si no la gema de ahora, y probalo con Play rompiendo geodas en la zona 1.
Actualizá ideas/forja-rapida.md.

[acá pegá la tabla "Las 60 piedras" de arriba]
```

---

## Efectos para las piedras sin rehacer los modelos (oro, arcoíris…)

Los efectos no van en el modelo: el juego los pone encima, cambiando color y material, y sumando partículas, luz y contorno. Es lo mismo que ya hace con las geodas exóticas (Lava, Neón, Dorada, Vacío). Así una sola gema sirve para todas sus versiones. No hace falta Blender.

```
Leé ideas/forja-rapida.md (la parte de los modificadores exóticos de las geodas: Lava, Neón, Dorada y Vacío).
Quiero lo mismo para las gemas: variantes con efecto que se ponen ENCIMA del modelo que ya existe, sin cambiar ni rehacer ningún modelo.
Variantes:
- Oro: todo dorado brillante (material metálico), destellos que aparecen y desaparecen y una luz amarilla suave.
- Arcoíris: el color va cambiando por todos los colores de a poco, con chispitas de colores.
- Diamante: transparente y brillante como vidrio, con destellos blancos.
- Sombra: negra con borde violeta que brilla y humito violeta que sube.
- Fuego: borde naranja que late, chispas que suben y luz naranja.
Cómo: un módulo de efectos que recibe cualquier modelo de gema y le aplica la variante cambiando color y material de sus partes, sumando partículas, luz y contorno (Highlight). Que funcione con todas las gemas, las de ahora y las nuevas. La variante es un atributo que pone el servidor.
Primero plan, sin cambiar nada: qué tan seguido sale cada variante, cuánto más vale (Oro x3, Arcoíris x5, Diamante x10, Sombra x15, Fuego x8 como punto de partida), cómo se muestra en la revelación, en la mochila, en el Museo y en la exhibición, y que las probabilidades sigan sumando 100 % (GUIA, sección 6). Con "Efectos reducidos" que se vea solo el color, sin partículas.
Cuando apruebe el plan, hacelo y probalo con Play. Mostrame una captura de la misma gema en sus 6 versiones (normal y las 5 variantes) una al lado de la otra. Actualizá ideas/forja-rapida.md.
```
