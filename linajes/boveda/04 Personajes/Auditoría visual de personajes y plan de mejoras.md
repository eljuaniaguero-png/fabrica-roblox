---
tags: [personajes, auditoria, arte, blender, comic]
fecha: 2026-11-14
estado: propuesta-para-claude
---
# Auditoría visual de modelos de personajes y plan de mejoras

> [!check] Estado (15 nov 2026)
> **Fase 0 hecha** (14 nov, commit `fd6297f`): sin rayas horizontales y neones sin quemar. Fases 1 y 2 pendientes; el arte está frenado hasta que el sandbox ande ([[Plan por etapas]]).

> [!danger] Regla absoluta de este documento
> **ESTÁ PROHIBIDO bajar triángulos porque sí.** Ningún problema estético actual se resuelve recortando geometría. Todos los modelos respetan el límite técnico de Roblox (`<= 20.000` triángulos por `MeshPart`) y sus presupuestos vigentes en [[Personajes]] y [[Nivel de detalle]]. El objetivo de cada cambio es **subir drásticamente la belleza, la lectura de silueta, el acabado cómic real (`estilo-02-protagonista.png`, `estilo-03-personajes.png`, `estilo-08-remache.png`) y la coherencia con [[Guía de estilo]]**, reasignando detalles dentro del presupuesto o usando mejor el relieve, las UV, los materiales y las proporciones.

---

## 1. Qué se cambió hoy (14 nov 2026)

Durante la jornada de hoy se empujaron 4 commits sobre el elenco de personajes y el sistema de materiales en Blender:

1. **`1215781` — Paso de Cuervo, Centinela, Atalanta y Remache a modo `comic=True`:**
   - [detalle.py](../../arte/scripts/detalle.py): `copia_alta(..., comic=True)` desactiva la subdivisión suave ("sin almohadones"), apaga grano fino/ruido de estática y remaches procedurales, aplica piso mínimo de luminancia `#1D2230` (`color_con_piso`) y pinta tinta `#0E1016` más aristas aclaradas.
   - [trajes.py](../../arte/scripts/trajes.py): introduce `RADIO_MINIMO` (oculta remaches diminutos), `REDONDEZ_MAXIMA` (para evitar bloques inflados) y `CAPA_ANGULAR` (zigzag rígido en capas).
2. **`7444efa` — Refactor de `cuervo.py` (`cuervo_v2`):** tres tonos (ropa oscura, acero claro mate, bronce), rejilla facial cerrada, emblema en placa hexagonal y penacho de 3 plumas.
3. **`432ae00` — Albatros, Estela, Mascarada y Tano al modo `comic=True`, más capa continua (`tiras=1`) en Centinela.**
4. **`6a74858` — Ajuste del elenco a sus fichas (`07 NPCs/*.md`) + `render_neutro.py`:**
   - **Cuervo:** acentos violeta `#6B5BA8`, boca/mentón con piel en la mitad inferior, ojos blancos sin pupila, pico corto, gancho pasado al antebrazo izquierdo, bombas de humo en el cinturón, capa más angosta.
   - **Centinela:** sin emblema solar en el pecho, juntas azules de la Liga en cuello/cintura, capa larga hasta tobillos.
   - **Atalanta:** coraza modificada con dos placas de pecho y quiebre de cintura, mangas azules plisadas (`d_mangas`), manzana y hoja más grandes en el escudo, lanza alargada a `7.4` studs.
   - **Remache:** careta separada (`Remache_Careta`), torso trapezoidal en V cambiado a acero, correas al frente/espalda y dos tanques rojos en la espalda.
   - **El Albatros:** abrigo abierto en V adelante con tajo atrás, pantalón azul marino oscuro, oro envejecido (`#C9962E`).
   - **Estela:** esqueleto escalado en Blender (`ESCALA = (0.85, 0.9, 1.0)`).
   - **Mascarada:** mangas y pantalón negros (`d_mangas_pantalon`) y reemplazo de `MascaraNinguna` por `MascaraFuria`.
   - **Tano:** antebrazos y manos color piel (`arremangado`), llave en mano derecha, manchas grandes en `"mameluco"`.
   - **`render_neutro.py`:** renders con luz blanca pareja (`elenco_neutra_frente.png` y `*_neutra_vistas.png`) que dejaron expuestos con total claridad los problemas reales sin el maquillaje naranja de la contraluz anterior.

---

## 2. Diagnóstico transversal (por qué todavía no se ven como los conceptos)

Al comparar `elenco_neutra_frente.png` y cada `*_neutra_vistas.png` contra las láminas aprobadas (`estilo-02-protagonista.png`, `estilo-03-personajes.png`, `estilo-08-remache.png` y `cuerpo-comic-hoja.png`), aparecen **5 fallas estructurales repetidas en casi todo el elenco**:

### A. Rayado horizontal ciego en `_material_comic` ([detalle.py](../../arte/scripts/detalle.py))
- **Qué pasa:** `_material_comic` usa `N.linea(z, pz * 2.5, 0.0016)` y `N.linea(z, pz * 1.5, 0.0013)`. Eso traza **líneas horizontales paralelas tipo persiana cada pocos centímetros sobre el eje `Z` de TODO objeto** (atraviesan la capa dorada de Centinela, los pectorales, las dos colas del saco de Mascarada, el delantal de Tano, todo el traje de Estela y las polleras del abrigo de Albatros).
- **Por qué arruina el arte:** destruye la lectura de tela, hace que capas y chalecos parezcan persianas o bloques apilados, y no marca las aristas donde realmente doblan las piezas.
- **Qué hacer en `detalle.py`:**
  1. Eliminar o restringir al mínimo la grilla por coordenada `Z` mundial en telas, capas y torsos orgánicos.
  2. Reemplazar esa tinta genérica por **tinta cómic real por curvatura cóncava + `Mark Sharp` + AO direccional**: donde dos placas o solapas se encuentran (aristas marcadas con `crease`/`sharp` o ángulo `< 145°` / `Bevel` invertido), pintar línea limpia `#0E1016` (`2–4 px` en mapa `1024 px`), y en aristas convexas el aclarado `+12%` para que recorte volumen.
  3. Las costuras reales de tela van alineadas a **costuras UV / dobladillos** (borde de capa, puños, solapas, bolsillo), jamás cruzando horizontalmente el medio de una prenda entera.

### B. Cubos grises de maniquí `#B8BCC6` expuestos en caras, cuellos y manos
- **Qué pasa:** En los renders neutros, **Albatros, Centinela Solar, Tano, Matones y Civiles** muestran el cubo gris neutro del `maniqui-r15` (`#B8BCC6`) donde debería haber piel, sombra de visor o cuello oscuro; Cuervo muestra un rectángulo liso con 1 barrita negra como boca; y Mascarada conserva un bloque gris-blanco cortado con una ranura lateral en la cabeza.
- **Contraste con la referencia:** En `estilo-03-personajes.png` (Tano, Albatros, Remache, Protagonista), **la mitad de la personalidad visual viene del rostro cómic expresivo**, cejas, barba, cicatrices o del encastre limpio del casco/cuello.
- **Qué hacer:** Ningún personaje terminado puede mostrar el material base `maniqui` `#B8BCC6` en cabeza, cuello o manos. Todo hueco de cuello lleva interior oscuro `#1D2230` (o ropa), y todo personaje humano visible lleva cara pintada (`256–512 px` estilo `cuerpo-comic-hoja.png` / `estilo-03-personajes.png`) o rostro esculpido con ojos, cejas, nariz/barba coherentes con el cuerpo R15.

### C. "Efecto maqueta de placas flotantes" e intersecciones (`clipping`)
- **Qué pasa:** Muchas prendas se armaron poniendo cajitas independientes flotando sobre el bloque R15 sin integrar sus bordes ni resolver intersecciones:
  - En **Atalanta**, la manga/antebrazo izquierdo atraviesa por dentro la manzana dorada del escudo (`atalanta_escudo.png`).
  - En **Albatros**, los eslabones grises de la cadena del arpón atraviesan la hombrera (`albatros_baston.png`), la bufanda flota adelante como una U rígida con flecos en peine de plástico, y las piernas tienen dos varillas sueltas adelante.
  - En **Centinela Solar**, la corona de la espalda penetra el borde superior de la capa (`centinela_corona.png`).
  - En **Estela**, dos platillos semicirculares flotan pegados sobre la parte superior de ambos antebrazos/muñecas (`estela_neutra_vistas.png`) y el rombo del pecho se hunde torcido dentro del esternón (`estela_casco.png`).
  - En **Cuervo**, la placa hexagonal del pecho sobresale varios centímetros como un imán de heladera pegado sobre un pecho liso (`cuervo_v2_vs_v1_primeros_planos.png`).
- **Qué hacer:** Ajustar offsets reales y verificar en Cycles con cámara ortográfica cercana cada unión entre extremidad, accesorio y torso para tener **cero clipping** y piezas que parezcan fabricadas una sobre otra (con cuello, encastre o correa de unión).

### D. Siluetas "heladera" (proporciones idénticas en casi todo el elenco)
- **Qué pasa:** Cuervo, Estela, Atalanta, Mascarada y Tano mantienen casi la misma silueta rectangular frontal R15 en `elenco_neutra_frente.png`: hombros horizontales a la misma altura, cinturas sin quiebre real, brazos rectos colgando como tubos cuadrados y piernas juntas formando un solo bloque vertical abajo.
- **Qué hacer (manteniendo compatibilidad total con Motor6D R15):**
  - En personajes ágiles/femeninos (**Estela**, **Atalanta**), no alcanza con escalar el esqueleto entero `0.85`: hay que afinar la cintura en las mallas de `LowerTorso`/`UpperTorso`, biselar en V el torso, abrir apenas el espacio entre muslos y estirar las botas/pantorrillas hacia abajo para romper el bloque macizo.
  - En pesos pesados (**Remache**, **Albatros**), exagerar trapecios, cuello hundido en hombros/solapas y antebrazos anchos.
  - **En ropa holgada:** modelar puños doblados, cuellos levantados que enmarcan la cabeza (como el cuello rojo en `estilo-02-protagonista.png`), caídas limpias sobre botas y separación real entre piernas izquierda y derecha.

### E. Contorno cómic (`Outline`) y acabado de materiales en Roblox
- **Qué pasa:** Sin luz cálida de estudio, en Puerto Óxido de noche varias piezas oscuras o muy lisas pierden lectura o se ven plásticas (`estela_botas.png` brilla como acrílico negro en las rodillas; `atalanta_casco.png` brilla como bronce aceitado; `remache_columna.png` deja los tanques rosa salmón pastel en vez de rojo sangre `#C2213A`).
- **Qué hacer:**
  1. Ajustar los valores de `Roughness` en materiales metálicos y sintéticos cómic (evitar focos especulares aceitosos en rodilleras y cascos; controlar brillo con mapas pintados en las aristas).
  2. Probar contorno sutil estilo cómic (*inverted hull* muy fino o trazo de borde pintado en UV en zonas de contacto) en piezas clave de héroes y jefes, sin inflar siluetas.
  3. Unificar iluminación/emisión: los `neon-*` de ojos, tanques y detalles deben respetar el balance con `Bloom.Threshold >= 1.6` de la [[Guía de estilo]] para no virar a rosa pastel (`#FF8A80`) en los renders neutros.

---

## 3. Análisis y cambios detallados personaje por personaje

### 1. Cuervo (`cuervo.py` · Vigilantes · 35.140 / 36.000 tris)
**Lo hecho hoy (`1215781`, `7444efa`, `6a74858`):** Se pasó a modo cómic, se reemplazó la rejilla gris por piel + barra de boca abajo y ojos blancos sin pupila arriba, pico acortado, placa hexagonal morada en el pecho, 4 bombas de humo en cinturón, gancho pasado al brazo izquierdo, hombros y capa angostados, paleta blanco/gris acero `#8A94A6` + tela `#121216` + violeta `#6B5BA8`.

**Qué se ve mal hoy en `cuervo_v2_neutra_vistas.png` y `cuervo_v2_vs_v1_primeros_planos.png`:**
1. **Inversión de jerarquía cromática:** En la placa del pecho, brazos, guanteletes y canilleras domina tanto el gris claro `#8A94A6` que parece un soldado de hojalata gris claro con chaleco negro, perdiendo el carácter sigiloso de [[Cuervo]] ("negro `#121216` con reflejos `#8A94A6`" y "acento violeta `#6B5BA8` en las costuras").
2. **Capa trasera de "estalactitas / zanahorias":** En la vista trasera de `cuervo_v2_neutra_vistas.png`, las filas de plumas se ven como ~30 conos abultados y desordenados de gris claro colgados sobre un rectángulo negro, con aspecto tosco y desprolijo.
3. **Capucha cúbica + rostro inexpresivo:** La capucha sigue siendo un cubo redondeado con 3 púas sueltas en la coronilla; debajo del pico asoma un bloque de piel con una rayita horizontal como boca, sin sombra de nariz/mentón, ni ceño, ni cuello que conecte cabeza y peto.
4. **Placa del pecho y cinturón:** El hexágono violeta sobresale como un cartel grueso clavado sobre un pecho de cajas rectangulares; las 4 bombas del cinto se ven como mini botellas diminutas apiladas junto a un gancho lateral izquierdo demasiado delgado.

**Cambios específicos propuestos:**
- **Capucha y cabeza (`d_capucha`):**
  - Dar corte anguloso real al capuchón: marcar la línea de la frente en V descendente hacia el pico (efecto ceño agresivo) y sacar las orejeras laterales ligeramente hacia el cuello en lugar de un cubo recto.
  - Hacer las **3 plumas del penacho** como láminas afiladas prismáticas planas (`Mark Sharp` en lomo) naciendo integradas desde la cresta del capuchón hacia atrás en escalón limpio, no como 3 cuernos cilíndricos clavados encima.
  - En el hueco inferior de la cara (`cara` + `boca`): pintar o modelar sombra de pómulos/mentón en el tono piel + barbilla definida + cuello cerrado negro `#1D2230` detrás para que no parezca una caja de cartón color durazno metida en un buzón. Bajar apenitas la línea de boca con gesto firme/serio.
- **Paleta y peto (`d_peto`, `_paleta_cuervo`):**
  - Devolver la dominancia a **`#1D2230` (negro portuario legible) / `#252A38` en el traje y placas principales**, dejando el acero `#8A94A6` **solo como biseles, filo de placas, garras y reflejo metálico de las plumas**, y `#6B5BA8` estrictamente en costuras finas, cintas de bombas y vivo del emblema (siguiendo 60% oscuro / 30% pizarra / 10% violeta+blanco).
  - Rebajar el espesor del soporte del **emblema dorsal/pectoral**: integrarlo a ras del peto con un bisel limpio de `0.015` m integrado entre dos placas pectorales angulares en V, no como un escudo hexagonal salido hacia adelante.
- **Capa de plumas (`d_capa`):**
  - Reemplazar esos conos cilíndricos abultados por **láminas planas biseladas con nervio central (`Mark Sharp`)** en 3 niveles escalonados que cubran hombro-hombro como un manto alado ordenado (`#1D2230` en cuerpo de pluma y filo/raquis pintado en `#8A94A6`), abriéndose en puntas irregulares solo en el dobladillo inferior. Desde atrás debe leerse un manto emplumado épico e intimidante, jamás racimos grises colgando.
- **Gancho y cinturón (`d_antebrazos`, `d_cinturon`):**
  - Engrosar la carcasa del lanzador de gancho izquierdo y su garra triple para que la silueta del brazo izquierdo se diferencie claramente del derecho a distancia de juego.
  - En el cinturón, mantener las **4 bombas de humo** más limpias y espaciadas (esferas/cápsulas facetadas con banda `#6B5BA8` bien nítida) en lugar de cilindros pegados al hebijón.

---

### 2. Centinela Solar (`centinela.py` · Liga · 35.266 / 38.000 tris)
**Lo hecho hoy (`1215781`, `432ae00`, `6a74858`):** Pasado a modo cómic, capa cambiada a continua (`tiras=1`) y alargada hasta tobillos, quitado el sol del pecho, agregadas juntas azules `#2F6FDB` de la Liga en cuello y cintura.

**Qué se ve mal hoy en `centinela_neutra_vistas.png` y `centinela_corona.png`:**
1. **Rostro borrado detrás del visor:** Tiene la cabeza completamente gris `#B8BCC6` del maniquí R15 sin cara ni mandíbula detrás de una banda cilíndrica dorada que parece una latita atada a la frente.
2. **Abdominales tipo "cartón de huevos" + rayas horizontales:** Pese a cambiar el torso, mantiene 6 rectángulos inflados en la panza + pectoral cuadrado, todo rayado horizontalmente por `N.linea(z, ...)` en blanco armadura y en toda la capa dorada (`centinela_neutra_vistas.png` derecha).
3. **Corona solar flotando y mordiendo la capa (`centinela_corona.png`):** En la vista lateral la corona es un aro suelto paralelo a la espalda sin soporte mecánico ni anclaje al cuello/hombros; de atrás los rayos inferiores de la corona **atraviesan el borde superior de la capa dorada**.
4. **Botas enormes en bloque:** Las grebas/botas inferiores forman un solo bloque blanco grueso casi fusionado que quita porte heroico al personaje.

**Cambios específicos propuestos:**
- **Cabeza / Casco o rostro noble (`d_casco` / rostro):**
  - Definir según su identidad: o bien mostrar rostro noble/severo cómic en tono piel cálida (ojos firmes blancos/dorados o azules, ceño sereno, mandíbula marcada con sombra) enmarcado por una **diadema/visor abierta en V** (sin cilindro grueso que parezca venda metálica), o bien un **yelmo cerrado heroico blanco `#E8E6E0` + oro `#D9A441`** con mentonera esculpida que tape por completo el `#B8BCC6` gris del maniquí. **Cero gris de maniquí expuesto.**
- **Peto heroico sin "almohadones" (`d_peto`):**
  - Reemplazar las 6 pastillas abdominales salientes por una **coraza torácica en V limpia** de dos planos blancos inclinados con fileteado dorado `#D9A441` geométrico en V (marcando el pecho heroico por plano angulado, sin cubitos de abdomen) y cintura estilizada dejando más visible la franja azul `#2F6FDB` de la Liga bajo el cinturón y en el cuello.
- **Corona solar (`d_corona`):**
  - Subir la corona `+0.08–0.12` m e inclinarla sutilmente (`~8°`) con **dos varillas/anclajes dorados al cuello de la coraza** (o un arco cervical) para que nazca físicamente de la armadura, **corrigiendo el clipping con la capa**. Hacer los rayos prismáticos de sección romboidal con `Mark Sharp` en la arista central.
- **Capa larga y calzado (`d_capa`, `d_botas`):**
  - Quitar las rayas horizontales de `N.linea(z)` sobre la capa dorada (`tela-dorada`) y trabajar **pliegues verticales en abanico más orgánicos/heroicos** que caigan detrás de los hombros con caída en V abierta abajo (mostrando apenas los talones blancos), más un cuello alto/broches firmes integrados a las hombreras.
  - Afinar los tobillos y separar claramente bota izquierda de bota derecha para evitar el bloque macizo inferior.

---

### 3. Atalanta (`atalanta.py` · Liga · 31.326 / 32.000 tris)
**Lo hecho hoy (`1215781`, `6a74858`):** Pasado a modo cómic, coraza rehecha en dos bloques con placas de pecho altas y quiebre de cintura, mangas plisadas azul Liga (`d_mangas`), manzana y hoja ampliadas en el escudo, lanza alargada a `7.4` studs.

**Qué se ve mal hoy en `atalanta_neutra_vistas.png`, `atalanta_casco.png`, `atalanta_escudo.png` y `atalanta_lanza.png`:**
1. **Clipping grave en el escudo (`atalanta_escudo.png`):** La placa del antebrazo/brazalete **atraviesa por dentro el escudo y parte por la mitad la manzana dorada**. Además, todavía quedan bolitas/remaches en el borde del escudo con ruido especular alrededor del relieve de la manzana.
2. **Corte negro/UV en la lanza (`atalanta_lanza.png`):** Hay una línea negra horizontal nítida cortando la hoja de bronce de la lanza en dos mitades (costura de UV/normal invertida o hueco entre caras).
3. **Pecho en "estantes" y mangas cuadradas (`atalanta_neutra_vistas.png`):** Las placas pectorales parecen dos cajones horizontales pegados adelante; el laurel de la cintura parece un alambre doblado; las `d_mangas` azules parecen dos columnas acanaladas rígidas del ancho completo de un hombre fuerte; y el casco es un buzón marrón oscuro cerrado que oculta por completo su rostro y pone encima un cepillo azul rígido.
4. **Capa corta rígida (`atalanta_neutra_vistas.png` derecha):** La capa azul corta sobresale recta hacia los costados más ancha que las caderas, pareciendo un techo de chapa pintado de celeste.

**Cambios específicos propuestos:**
- **Arreglo urgente de clipping y seams (`d_escudo`, `d_lanza`):**
  - Desplazar el escudo `+0.06–0.09` m hacia afuera (`afuera` del brazo izquierdo) o adelgazar el `porpax` y separarlo del antebrazo/brazalete para que la manzana dorada quede **100% libre e intacta**. Reemplazar la manzana esférica aceitosa por una manzana cómic facetada/chaflanada limpia sobre fondo mate oscuro dentro del borde dorado.
  - Revisar `d_lanza`: soldar vértices duplicados y revisar la costura UV horizontal a mitad de la punta de lanza para eliminar la línea negra de `atalanta_lanza.png`.
- **Casco hoplita con rostro visible (`d_casco`):**
  - Seguir el estilo de casco abierto griego (`Corinthian/Chalcidian` estilizado R15): abrir el frente en T para **mostrar ojos cómic decididos, cejas, puente nasal en piel cálida y labios/mentón**, enmarcado por carrilleras de bronce `#A0703A` con acento dorado `#D9A441`.
  - Rediseñar la crinera/penacho azul para que tenga forma fluida curvada hacia la nuca (con mechones o crestas en cuña como `pelo_comic`), no un bloque cepillo rectangular parado verticalmente.
- **Coraza femenina estilizada + quitón (`d_coraza`, `d_mangas`, `d_capa`):**
  - Suavizar el ángulo y profundidad de la coraza pectoral integrando un único peto esculpido con curva limpia en V hacia la cintura (sin dos ladrillos sueltos), rematado con cintura angosta y una **falda de pteruges (tiras hoplitas) ordenada con espacio entre piernas**.
  - Cambiar las mangas azules de bloque gigante por **hombreras de bronce cortas sobre un quitón azul `#2F6FDB` ceñido** que deje ver parte del brazo en tono piel antes del brazalete de bronce: instantáneamente se volverá femenina, atlética y mucho menos cuadrada.
  - Afinar la capa corta (`ancho` menor que los hombros, caída pegada a la espalda, con borde inferior acabado en doble punta o corte griego suave), sin sobresalir hacia los costados.
  - Subir la claridad/calidez del bronce en zonas altas (`#B58246` / `#D9A441` en bordes) para evitar el aspecto chocolate oscuro de `atalanta_casco.png`.

---

### 4. Remache (`remache.py` · Cofradía · Jefe de la Beta · 29.222 / 37.000 tris)
**Lo hecho hoy (`1215781`, `6a74858`):** Pasado a modo cómic, torso en V en acero, correas separadas en cuero, `Remache_Careta` separada sobre bisagras, dos tanques con visor rojo en la espalda.

**Qué se ve mal hoy en `remache_neutra_vistas.png`, `remache_brazo.png`, `remache_columna.png`:**
1. **Muy lejos del concepto épico `estilo-08-remache.png`:** En `estilo-08-remache.png` es un coloso aterrador con chaleco abierto sobre torso herido/cicatrizado (o armadura pesada brutal) y brazos hidráulicos enormes cargados de engranajes y desgaste industrial. En el render actual parece una **caja marrón cuadrada con tirantes sueltos y dos mini-pistones de escritorio pegados a los codos**.
2. **Tanques rosados pastel (`remache_columna.png`) y tubos desconectados:** El líquido rojo `#C2213A` emite tanta luz naranja/blanca bajo iluminación neutra que se vuelve **rosa pastel**, y las mangueras de salida entran al cuello sin racores ni collarines mecánicos.
3. **Correas frontales e `Head` de soldador:** Las dos placas marrones clavadas diagonalmente en las clavículas flotan separadas del pecho (`remache_brazo.png`), los hombros flotan inclinados sin conectarse a los brazos, y el casco parece una caja marrón con una bandita rosa pegada por delante y micro-tornillos en los bordes de la muñeca.

**Cambios específicos propuestos (respetando su ficha en [[Remache]]):**
- **Brazos hidráulicos pesados (`d_brazos`):**
  - Hacer honor a sus **brazos hidráulicos robados de Corona Corp** y puños-martillo: reemplazar los bloques marrones genéricos de hombro/bíceps por **hombreras acorazadas gris acero `#4A5560` con engranajes/ejes visibles en las juntas**, antebrazos macizos poligonales con **doble pistón real integrado en la estructura del brazo** (no un cilindrito suelto flotando al frente) y **puños-martillo gigantes** de acero y óxido `#6E4A35` con dedos blindados articulados en nudillos.
- **Torso en V brutal + contraste acero/cuero (`d_arnes`):**
  - El torso en acero + cuero necesita **anatomía de tanque industrial**: ensanchar trapecios reales que unan pecho y cabeza sin placas flotantes en el aire, ajustar las correas en X pegadas al cuerpo (`offset` cero) con **hebilla pectoral gruesa**, y oscurecer/patinar el acero con óxido pintado en juntas y borde metálico aclarado (estilo `pintura.py`), evitando franjas horizontales de `detalle.py`.
- **Casco y careta de soldador (`Remache_Casco`, `Remache_Careta`):**
  - Hacer la careta de soldador ancha, angular y agresiva (con visera inclinada hacia adelante, respiraderos laterales metálicos con rejilla y marco oscuro hundido `#1D2230` alrededor del visor) para que al levantarse en fase 2 se entienda como máscara industrial real y no como 3 placas cuadradas pegadas.
  - Bajar el brillo emisivo del visor y de los **tanques de líquido en la espalda** para que se lean **`#C2213A` rojo sangre intenso y oscuro** (con burbujas/reflejo de vidrio tintado encima) en lugar de rosa salmón, y agregar collarines metálicos de acople donde entran los tubos a la columna/brazos.

---

### 5. El Albatros (`albatros.py` · Cofradía · NPC de la Beta · 23.002 / 23.500 tris)
**Lo hecho hoy (`432ae00`, `6a74858`):** Pasado a modo cómic, abrigo abierto en V adelante con tajo atrás y grosor real (`solidify`), agregado pantalón azul marino oscuro, oro ajustado a `#C9962E` y azul marino aclarado a `#28344A`.

**Qué se ve mal hoy en `albatros_neutra_vistas.png`, `albatros_gorra.png`, `albatros_baston.png`:**
1. **Cabeza muda gris de maniquí (`#B8BCC6`):** Es un NPC central de la Beta (habla con el jugador, jefe futuro) y tiene un cubo gris vacío debajo de la gorra sin ojos, nariz, ceño ni barba — comparado con su referencia directa en `estilo-03-personajes.png` (capitán duro con barba canosa/gris, ceño pesado y cicatriz).
2. **Bufanda tipo "peine lego" (`albatros_gorra.png`):** El bloque cuadrado del nudo + dos cintas geométricas rectas + palitos blancos colgando como un peine quedan toscos y rígidos encima del pecho.
3. **Cuello de piel gris en gusanos + faldón rígido abajo:** El cuello de piel (`PielGris`) atrás parece una cadena de bolitas de plastilina; el abrigo de `d_abrigo` se abre como una **campana cónica muy ancha rígida**, atravesada adelante por 2 palos largos finos de cierre, mientras las mangas muestran 3 escalones cuadrados en bloques horizontales.
4. **Cadenas del bastón-arpón clippeando (`albatros_baston.png`):** Varios eslabones metálicos sueltos del bastón flotan y atraviesan el borde superior de la hombrera derecha.

**Cambios específicos propuestos:**
- **Rostro de capitán cómic (`Head`):**
  - Sacar el gris de maniquí urgentemente: aplicar **piel cómic curtida**, **ojos entornados de mirada calculadora con cejas pobladas**, nariz ancha y **barba/bigote esculpido o pintado con trazo de tinta `#0E1016`** coherente con `estilo-03-personajes.png` (respetando su ficha en [[El Albatros]]: sin monóculo ni smoking).
- **Bufanda, cuello de piel y solapas del abrigo (`d_bufanda`, `d_abrigo`, `d_mangas`):**
  - Reemplazar el cubo+peine de `d_bufanda` por **un pañuelo/bufanda cruzado en dos paños angulares bien asentados bajo el mentón** con doblez limpio (flecos como lámina dentada biselada pintada, no 6 cilindros separados).
  - Esculpir el **cuello de piel gris** con mechones planos angulares estilizados estilo pelo cómic (`Mark Sharp`), en forma de cuello alto envolvente, en lugar de bolitas pegadas atrás.
  - Hacer la abertura frontal del abrigo con **dos solapas reales con botones dorados `#C9962E` visibles en el pecho** (sin varillas colgando al vacío en la abertura), ajustar el vuelo de las faldas para que caigan más rectas/pesadas de capitán (menos campana de vestido), eliminar los escalones raros de las mangas y resaltar el **Albatros dorado de la espalda** con bisel plano limpio y tinta `#0E1016`.
- **Bastón-arpón (`d_baston`):**
  - Recolocar/tensear la cadena enrollada exclusivamente alrededor del fuste del bastón para que **ningún eslabón toque ni atraviese el hombro o brazo**. Dar punta de arpón facetada con desgaste metálico afilado en los filos.

---

### 6. Estela (`estela.py` · Liga · Mentora de Velocista Cinético)
*(Nota: no figura aún en el índice [[Personajes]]; conviene agregarla ahí también al cerrar su modelo.)*

**Lo hecho hoy (`432ae00`, `6a74858`):** Pasada a modo cómic, esqueleto escalado en Blender (`ESCALA = (0.85, 0.9, 1.0)`).

**Qué se ve mal hoy en `estela_neutra_vistas.png`, `estela_casco.png`, `estela_botas.png`:**
1. **Proporción de robot cuadrado pese a `ESCALA = 0.85`:** Sigue viéndose pesada y cúbica porque el traje copia cajas rectas sobre hombros anchos, las piernas forman un único pilar morado pegado con 0 separación de muslos/rodillas y el casco es un cubo vertical enorme.
2. **Casco confuso con círculo marrón en la oreja (`estela_casco.png`):** Lleva un disco marrón-cobre estriado en la oreja (parece tapa de alcantarilla desentonando totalmente con la paleta violeta `#5A3FA0` + cian `#3FE0F0`), una línea finita cian en la boca que parece alambre suelto, dos bloques celestes pegados en sienes y frente, y **dos tablas rectangulares planas clavadas en la nuca** que de frente ni se entienden y de costado parecen antenas de caja.
3. **Emblema flotando torcido y platillos en los codos/muñecas:** En `estela_casco.png`, el rombo morado del pecho está **inclinado hacia afuera clavándose de pico en el pecho**, y en ambos brazos lleva **dos platillos semicirculares horizontales inexplicables** (`estela_neutra_vistas.png` y `estela_botas.png`) sobre las muñecas/brazos.
4. **Rodilleras gigantes negras brillosas y rayas horizontales (`estela_botas.png`):** Las rodilleras parecen pantallas negras lustrosas reflejando focos blancos de techo, las zapatillas tienen 2 tacos grises pesados al frente y todo el cuerpo violeta está surcado por líneas horizontales continuas de `detalle.py`.

**Cambios específicos propuestos:**
- **Silueta realmente femenina y aerodinámica (`afinar` + `d_traje`):**
  - Además de escalar el rig `0.85`, biselar y **afinar cintura (`LowerTorso`) y caderas**, inclinar los hombros hacia abajo en línea aerodinámica (`10–12°` en lugar de cajas cuadradas) y **separar visiblemente los muslos y pantorrillas** moldeando mallas ajustadas de velocista en cada pierna con tobillos delgados.
- **Casco aerodinámico de velocista (`d_casco`):**
  - Afilar el casco biselando más los planos laterales y superiores de la nuca; reemplazar las dos tablas traseras planas por **aletas aerodinámicas afiladas integradas en continuidad con el visor cian lateral** (forma de cuña progresiva hacia atrás).
  - Cambiar el círculo marrón-bronce de la oreja por **carcasa auricular grafito oscuro `#1D2230` + aro fino `#3FE0F0`**, unificar la mentonera cerrada sin el hilito cian flotante, y modelar el visor frontal en curva angular limpia (expresión veloz enfocada).
- **Emblema, brazos y botas (`d_emblema`, `d_guantes_botas`):**
  - Asentar el **rombo del emblema totalmente paralelo y encastrado en el pecho** con sus 3 trazos inclinados en relieve limpio.
  - **Eliminar esos dos platillos semicirculares flotantes en las muñecas** y reemplazarlos por **guanteletes aerodinámicos pegados al antebrazo** con filo hacia atrás hacia el codo.
  - Hacer las **rodilleras y punteras en grafito cómic mate (`Roughness 0.58–0.68`, nunca espejo brillante)** siguiendo líneas diagonales de velocidad, y **pintar las líneas cian `#3FE0F0` en ángulo aerodinámico** a lo largo de costados, espalda y suelas en lugar de las rayas horizontales de `Z`.

---

### 7. Mascarada (`mascarada.py` · Cofradía · Jefe 3 fases · 30.552 / 32.000 tris)
**Lo hecho hoy (`432ae00`, `6a74858`):** Pasado a modo cómic (adiós brillo espejo del charol), mangas y pantalón negros añadidos (`d_mangas_pantalon`), y reemplazo de `MascaraNinguna` por `MascaraFuria` (`mascarada_mascaras.png`). Además lleva galera, carta de diamante y bastón dorado.

**Qué se ve mal hoy en `mascarada_neutra_vistas.png` y `mascarada_mascaras.png`:**
1. **Es uno de los mejores cuerpos base del elenco, pero las 3 máscaras se ven toscas (`mascarada_mascaras.png`):**
   - **Comedia** tiene dos cubos cuadrados salidos en las mejillas que parecen muelas o ladrillos debajo de los ojos y una sonrisa demasiado gruesa pegada en tubo negro.
   - **Tragedia** tiene el bigote/boca caído con una gota negra pegada de costado que confunde lectura con una mancha o derrame.
   - **Furia** tiene cejas tipo "salchicha en V" y un tubo grueso blanco/gris rodeando un agujero rectangular negro como boca de robot.
   - En la vista lateral/trasera, la máscara flota por delante de una cabeza bloque gris con un **corte horizontal raro** en los costados y detrás (`mascarada_neutra_vistas.png`).
2. **Cola trasera de levita rayada horizontalmente y sin corte dramático:** Las dos faldillas traseras del saco carmesí (`d_saco`) están rayadas horizontalmente de arriba a abajo por `detalle.py`, y el saco no tiene **cuello alto teatral ni solapas marcadas**.
3. **Manos/cuffs raros:** Igual que en Estela, aparece un reborde/platito extraño encima del puño izquierdo blanco, y las manos son cubos blancos planos casi sin separación de pulgar o guante cosido.

**Cambios específicos propuestos:**
- **Esculpido teatral fino de las 3 máscaras (`d_mascaras`):**
  - Unificar los rasgos faciales usando **relieves angulares cómic limpios y vaciados en la placa de porcelana blanca `#E8E6E0`** (en vez de cilindros gruesos pegados encima):
    - **Tragedia:** quitar la gota/baba lateral oscura del bigote; definir cejas tristes angulares finas, comisuras bajas netas y una lágrima pequeña estilizada bajo un ojo pintada/relieve en carmesí `#C2213A` o tinta.
    - **Comedia:** eliminar los dos cuadraditos salidos debajo de los ojos; moldear pómulos suaves oblicuos, ojos arqueados alegres y sonrisa afilada cómic (sin tubo grueso).
    - **Furia:** reemplazar el marco de tubo grueso en la boca por una **boca abierta dentada o en ángulo agresivo tallada directamente en la máscara**, cejas afiladas en cuña (con `Mark Sharp`) y ojos carmesí rasgados estrechos.
  - Hacer la parte trasera de la cabeza **capucha/cráneo negro mate elegante** (`#1D2230`, eliminando la cabeza gris cuadrada con ranura lateral) con correa negra limpia sujetando la máscara al frente.
- **Saco de frac teatral (`d_saco`, `d_chaleco`, `d_guantes`):**
  - Quitar las franjas horizontales de `Z` en la cola roja carmesí y dar corte largo asimétrico / puntas de frac elegantes que se abren atrás con filo `#0E1016` y forro interior más oscuro `#6B1220`.
  - Añadir **cuello alto carmesí/negro** bordeando la nuca y **corbatín limpio** sin encimarse con los picos del cuello blanco.
  - Reemplazar ese aro raro sobre el puño por un **puño blanco de camisa nítido saliendo de la manga negra** y guantes blancos con línea de costura de nudillos en `#0E1016`.

---

### 8. Tano (`tano.py` · Civil / Mecánico del puerto · NPC de la Beta · 19.579 / 20.000 tris)
**Lo hecho hoy (`432ae00`, `6a74858`):** Pasado a modo cómic, agregados antebrazos y manos en piel (`arremangado`), llave inglesa girada dentro de la mano derecha, y `"manchas": 1.0` agregadas al shader `"mameluco"`.

**Qué se ve mal hoy en `npc-tano_neutra_vistas.png` y `npc-tano_cara.png`:**
1. **Rostro de cemento gris con bigote en escalera (`npc-tano_cara.png`):** Tano tiene **antebrazos piel cálida y CARA GRIS PIEDRA `#B8BCC6`** — parece una estatua con brazo humano, sin ojos, sin cejas, sin nariz y con 7 cubos blancos pixelados puestos abajo como "bigote". Compararlo con su propio diseño en **`estilo-03-personajes.png`** (2º personaje desde la izquierda: bigote/barba canosa limpia, ceño bondadoso pero duro, antiparras levantadas en la gorra, piel curtida) muestra una brecha gigantesca.
2. **Manchas de "vaca / camuflaje" en gorra y hombro (`npc-tano_neutra_vistas.png`):** El nodo `Noise` con `Scale: 3.5` y corte duro (`"manchas": 1.0`) genera manchas negras redondas enormes aleatorias en la frente de la gorra, en la espalda y en el hombro derecho que parecen manchas de dálmata o camuflaje militar, no grasa de taller.
3. **Bolsillos y herramientas demasiado planos / pegados en `Z`:** El trapo rojo trasero queda tieso como tabla lisa, las herramientas delante del delantal de cuero están pegadas como iconos muy finos y las rayas horizontales cruzan el delantal.

**Cambios específicos propuestos (llevándolo directo hacia `estilo-03-personajes.png`):**
- **Cabeza con rostro cómic completo (`Head` + cara + gorra):**
  - Aplicar **el mismo tono de piel curtida de los antebrazos a toda la cara**, con **expresión cómic `256/512 px`** (ojos firmes cansados pero cálidos, cejas canosas gruesas `#C9C6C0`, arruga de entrecejo y nariz corta cómic).
  - Reemplazar los 7 ladrillos escalonados del bigote por **bigote y barba corta canosa `#C9C6C0` con mechones biselados limpios (`Mark Sharp`) y contorno `#0E1016`**, integrados a la mandíbula (ver `estilo-03-personajes.png`).
  - Sumar sus características **antiparras de taller con marco oscuro y vidrio tintado apoyadas sobre la visera de la gorra** (o gorra con visera marcada sin arrugas de costura mal alineadas en la curva, como se ve en `npc-tano_cara.png`).
- **Grasa y delantal realistas en clave cómic (`detalle.py` + `d_delantal`):**
  - Quitar `"manchas": 1.0` aleatorio en gorra/espalda. Ubicar la **suciedad/grasa por máscara de altura y contacto (AO)**: solo en el bajo del delantal de cuero, puños arremangados, bolsillo trasero donde va el trapo rojo y rodillas del mameluco (`altura < cintura` y centro del delantal), nunca en la gorra ni el hombro superior.
  - Darle mayor volumen/relieve real al trapo rojo trasero (pliegue diagonal más natural) y herramientas (llave inglesa en mano bien apoyada contra los dedos cerrados, no flotando contra la palma abierta).

---

### 9. Protagonista / Cuerpo propio (`cuerpo.py`, `cuerpo_comic.py`, `pelo_comic.py`, `caras_comic.py` · Beta)
**Estado hoy:** No recibió commits de modelado hoy, pero en juego actual (`StarterCharacter`) y en `cuerpo_vistas.png` vs `cuerpo-comic-hoja.png` vs `estilo-02-protagonista.png` sigue habiendo diferencia visual grande entre el concepto del héroe y la malla/textura cargada.

**Qué se ve hoy en `cuerpo_vistas.png`, `cuerpo-comic-hoja.png`, `cuerpo_peinados_v2.png` y en Playtest:**
1. En `cuerpo_vistas.png` (que sigue en `04 Personajes/Cuerpo propio/`), los cuerpos base se ven con bordes de "muñeco inflado liso" y pelos aún con forma de gota en varios estilos (`cuerpo_peinados_v2.png`).
2. En `cuerpo-comic-hoja.png` se dio un salto enorme hacia `estilo-02-protagonista.png`, **pero comparado lado a lado con `estilo-02-protagonista.png` todavía falta:**
   - **Cuello levantado con interior rojo** bien abierto en V (ahora son dos tiritas rojas rectas pegadas en plano).
   - **Bolsillos inclinados, solapas, puños doblados en antebrazos y cinturón con hebilla roja metálica** bien separados de la remera blanca (en `cuerpo-comic-hoja.png` el cuerpo sigue siendo un prisma recto con franjas de textura sin corte de campera).
   - **Zapatillas blancas y rojas con lengüeta alta y suela gruesa bicolor** (hoy tiene tacos planos pegados abajo).
   - El pelo `CuerpoComic` ya tiene mechones en cuña geniales, pero en vista trasera (`cuerpo-comic-hoja.png` abajo) conviene suavizar la unión de la nuca para que no muestre huequitos grises entre mechones al mirar desde atrás (es lo que ve el jugador 100% del tiempo en cámara tercera persona).

**Cambios específicos propuestos:**
- Actualizar los archivos y exportaciones de `Cuerpo propio` para que la prenda base jugable tenga **geometría de campera urbana real** (cuello levantado en V con forro rojo, dobladillo inferior despegado sobre el cinturón, puños doblados y zapatillas estilizadas como en `estilo-02-protagonista.png`), sin depender únicamente de líneas planas pintadas en un cubo.
- Cerrar la nuca de los peinados `pelo_comic` asegurando **cero huecos hacia `Head`** desde atrás y manteniendo las líneas de tinta entre grandes mechones en `512 px`.

---

### 10. Matón del puerto (`maton.py` · Cofradía · Enemigo de la Beta · 7.770 / 8.000 tris)
**Estado hoy:** **Aún NO fue migrado a `comic=True`** hoy (a diferencia del elenco de jefes/NPCs), y **es el enemigo que el jugador pelea todo el tiempo en Puerto Óxido**.

**Qué se ve mal hoy en `enemigo-maton_vistas.png`:**
1. **`Subdivision` almohadón + estática granulada:** Tanto la campera como el jean están cubiertos por ruido procedural granuloso ("estática de TV") y almohadones abultados en brazos y panza.
2. **Micro-remaches e invisibilidad nocturna:** Hileras diminutas de tachas en los cierres pectorales (`< RADIO_MINIMO`); cuero `#121216` demasiado negro en Puerto Óxido noche (`< #1D2230`).
3. **Cabeza gris maniquí + cadena flotante:** Sobre el pañuelo asoma la parte superior de la cabeza gris `#B8BCC6` sin ojos ni cejas pintadas (solo una rayita horizontal como visera/vendaje), y la cadena larga de la mano derecha cuelga en el aire por fuera del borde del pantalón con eslabones sueltos muy finos.

**Cambios específicos propuestos:**
- Pasarlo a **`comic=True`** con `trajes.py` (`RADIO_MINIMO = 0.01`, `REDONDEZ_MAXIMA = 0.12`): eliminar la estática granulada y las micro-tachas de cremallera.
- Subir la campera de cuero a **`#262B36`** con bordes desgastados aclarados (`#3C4454`) y **línea cómic en solapa, bolsillos, codos y rodilleras del jean** (siguiendo exactamente [[Guía de estilo]] §2.4).
- Dar **ojos cómic entornados y piel cálida real en la franja descubierta de la frente/ojos** sobre el pañuelo (eliminando el bloque gris de maniquí) + gorro de lana tejido con borde doblado limpio en colores gastados (rojo Cofradía `#8E2A22`, verde musgo `#3B5A46`, gris `#565E6D`).
- Pegar mejor el enrollado de la cadena al puño/antebrazo derecho y compactar el tramo colgante (`0.25–0.35` m, eslabones más gruesos y biselados) para que no traspase la pierna ni parezca un hilito al correr.

---

### 11. Matón con implantes (`maton_implantes.py` · Cofradía · Enemigo de la Beta · 9.728 / 10.000 tris)
**Estado hoy:** **Tampoco fue pasado a `comic=True` hoy.** Comparte cuerpo/grano con `Matón del puerto` más brazo biónico derecho y ojo rojo.

**Qué se ve mal hoy en `enemigo-maton-implantes_vistas.png`:**
1. Hereda los mismos problemas de tela granulada, cara gris de maniquí y cadena flotante en la mano izquierda.
2. **Brazo implante "lata apilada" con remaches microscópicos:** El brazo derecho mecánico tiene decenas de micro-remaches diminutos en rejilla y placas cilíndricas estriadas llenas de ruido metálico, muy lejos de la nitidez brutal del brazo implante que muestra `estilo-03-personajes.png` (6º personaje desde la izquierda: **hombro biselado limpio, placas articuladas grandes en antebrazo, cable grueso único de acento y un solo ojo rojo biónico en cara humana cómic**).
3. **Ojo biónico gigante tipo pegatina salmón:** Un disco brillante plano del tamaño de media mejilla pegado encima de la frente gris sin cuenca metálica.

**Cambios específicos propuestos:**
- Aplicar base cómic del nuevo `Matón` (cero grano, piel y ceño en el ojo izquierdo sano, ropa `#262B36`).
- Rediseñar el **brazo derecho biónico** con **3–4 placas grandes limpias en cuña metálica** (`acero` mate `#6A7485` / `oxido` `#6E4A35` / `bronce` `#B07A3C`, según variante), bisel seco, juntas oscuras en codo/muñeca y **1 cable grueso amarillo/cobre o cian oscuro** recorriendo el lateral — eliminando la nube de micro-tornillos de la textura.
- Encajar el **ojo biónico rojo (`#E03A3E`)** dentro de una **placa metálica facial angular de medio rostro derecho** (inspirada directo en `estilo-03-personajes.png`) en lugar de un círculo rojo flotante sobre piel gris.

---

### 12. Civiles de Calle viva (`civiles.py` · 1.000 – 3.246 tris)
**Estado hoy:** En el juego, modelo en `civiles_ejemplos.png` con ropa limpia tintable `_C1`/`_C2`, sin pasar por caras cómic.

**Qué se ve mal hoy en `civiles_ejemplos.png`:**
1. Todas las cabezas muestran cubos grises `#B8BCC6` completamente planos o con micro-antifaces raros sin rostro humano.
2. Varios torsos/pantalones tienen cero bisel ni quiebre (`civiles_ejemplos.png` fila completa se lee como bloques puros de Roblox 2012 al lado de héroes de `35.000` tris con chaflán).

**Cambios específicos propuestos (manteniendo el tope de rendimiento por multitud):**
- Reemplazar la cabeza gris `#B8BCC6` por **tonos de piel humana variados** + `Decal` reutilizable de **cara cómic neutra limpia** (mismo sistema que jugador en `Cuerpo propio`, `256 x 256` RGBA, `0` triángulos extra).
- Aplicar un **chaflán único seco (`0.02` studs)** + `Auto Smooth 35°` en prendas `_C1`/`_C2` y separar claramente puños/zapatos/cabello dentro de su presupuesto (`1.000–3.246` tris actuales sin problema) para que la calle de Puerto Óxido pertenezca al mismo juego que el protagonista y Tano.

---

## 4. Orden recomendado de ejecución para Claude

> [!tip] Prioridad práctica
> Arreglar primero lo que **afecta a todos los modelos juntos** y después **los personajes que el jugador ya ve y pelea en la Beta** antes de seguir refinando los de actos posteriores.

1. **Fase 0 — Arreglar la base en `detalle.py` y `trajes.py` (afecta a todo el elenco):**
   - Sacar la grilla horizontal ciega `N.linea(z, ...)` de `_material_comic` en telas, capas y petos; reemplazar por tinta en juntas/aristas `Mark Sharp` + AO direccional + bordes claros.
   - Asegurar que `SIN_HORNEAR` / `neon-*` mantengan saturación fiel bajo luz blanca neutra (especialmente rojo `#C2213A` de Remache para que no vire a rosa pastel).
2. **Fase 1 — Personajes ya activos en la Beta Jugable (Puerto Óxido):**
   1. **Protagonista (`Cuerpo propio`):** chaqueta con cuello abierto en V real, nuca de pelos cerrada y zapatillas cómic estilo `estilo-02-protagonista.png`.
   2. **Tano (`tano.py`):** rostro piel + ojos/cejas + bigote canoso cómic + antiparras en gorra, y borrar manchas aleatorias de vaca (`"manchas": 1.0`) poniéndolas solo en delantal y parte baja.
   3. **El Albatros (`albatros.py`):** rostro curtido de capitán (adiós maniquí gris), bufanda bien plegada (adiós peine), abrigo menos acampanado con solapas reales y quitar clipping cadena/hombrera.
   4. **Remache (`remache.py`):** brazo-pistón hidráulico integrado con puño-martillo real, hombros conectados al trapecio en V, careta estilizada y tanques rojo sangre con acoples.
   5. **Matón del puerto + Matón con implantes (`maton.py`, `maton_implantes.py`):** pasarlos a `comic=True`, cara con piel/ojos en frente descubierta, brazo biónico limpio sin micro-tornillos y cadena pegada al brazo.
3. **Fase 2 — Jefes y mentores de actos siguientes + Civiles:**
   6. **Cuervo (`cuervo.py`):** volver al 60% negro legible `#1D2230`, capa trasera en láminas de pluma ordenadas (adiós racimo gris), capucha angular con rostro inferior sombreado y emblema integrado al peto.
   7. **Centinela Solar (`centinela.py`):** cara o yelmo real (adiós cubo gris), peto en V limpio sin pastillas infladas de abdomen, corona elevada e integrada con soporte para no cortar la capa, capa sin rayas horizontales.
   8. **Atalanta (`atalanta.py`):** arreglar clipping del antebrazo con la manzana del escudo, arreglar corte UV de lanza, abrir casco hoplita con cara cómic, suavizar coraza + mangas sin bloque ancho.
   9. **Estela (`estela.py`):** silueta afinada real en malla (hombros caídos, cintura y piernas separadas), quitar círculos marrones de oreja y platillos en muñecas, visor/aletas integradas y emblema al ras del pecho.
   10. **Mascarada (`mascarada.py`):** afinar esculpido cómic de las 3 máscaras (sin muelas cuadradas en Comedia ni gota rara en Tragedia ni boca tubo en Furia), cabeza cubierta en negro detrás de la máscara y frac sin rayas horizontales.
   11. **Civiles (`civiles.py`):** piel + cara `Decal` reutilizable + chaflán seco único para integrarlos al estilo visual.

---

## 5. Criterio de aprobación antes de re-exportar `.fbx` / `.glb`

Para dar por terminado cada modelo, validar **siempre** con `render_neutro.py` (`*_neutra_vistas.png`) + primer plano de rostro/arma/accesorio:
1. **Cero gris `maniqui` `#B8BCC6`** visible en cara, cuello, manos o piernas.
2. **Cero rayas horizontales automáticas de `Z`** cruzando capas, chaquetas o pecheras.
3. **Cero clipping** entre armas, escudos, cadenas, coronas, correas y extremidades.
4. **Cero reducción arbitraria de triángulos:** los totales siguen dentro de [[Nivel de detalle]] y cada `MeshPart` debajo de `20.000` triángulos.
5. **Lectura a distancia y silueta negra:** la pose neutral en negro sólido debe identificar al personaje al instante frente a los otros 11.

---

**Referencias conectadas:** [[Guía de estilo]] · [[Nivel de detalle]] · [[Personajes]] · [[Cuervo]] · [[Centinela Solar]] · [[Atalanta]] · [[Remache]] · [[El Albatros]] · [[Estela]] · [[Mascarada]] · [[Tano]]
