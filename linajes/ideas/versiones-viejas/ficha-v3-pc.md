# Linajes del Eclipse: documento del juego (ficha v3)

30 oct 2026 · Junta en un solo documento todo lo aprobado por Juani (ficha v2, cambios de las 19:56 y 20:00, mundo abierto y reputación de las 22:35) y suma la ciudad viva (policía, crimen, atracos y noticias) pedida a las 22:41. Las versiones anteriores quedan en el historial de git. Sigue `GUIA-PARA-CLAUDE.md` y `ideas/monetizacion.md`.

---

## 1. El juego en pocas líneas
Un eclipse cubre la región y despierta poderes en parte de la gente: los **Linajes**. Te armás **tu propio héroe o villano**, con poderes que no elegís y caminos que descubrís a ciegas, en un **mundo abierto con 3 ciudades** compartido con otros jugadores. Lo que hacés queda anotado en tu **reputación**: la policía te persigue o te pide ayuda, los diarios hablan de vos, los barrios cambian de dueño y las historias se abren según quién confía en vos.

**Pilares**
1. **Nada es una fila**: vas a donde quieras, hacés las historias en cualquier orden.
2. **La reputación manda**: cada acción mueve tu Fama y lo que la ciudad piensa de vos.
3. **La ciudad está viva**: civiles que llaman a la policía, ladrones, atracos, noticias con nombres de jugadores.
4. **Cada personaje es distinto**: poder al azar, Variantes secretas, Rasgos que salen de cómo jugás.
5. **Combate en tiempo real que se siente bien** (si el graybox no es divertido, no se sigue).

## 2. Sobre DC y el elenco
DC es de Warner Bros: un juego **publicado** con sus nombres, personajes, logos o trajes se puede bajar y sancionar la cuenta. Por eso **copiamos el tipo de personaje, no el personaje**: cada uno cambia nombre + tema visual + origen + debilidad. Mientras diseñamos usamos los nombres de DC como **nombres de trabajo**; nunca van en el juego publicado. Ningún modelo copia logos, emblemas, trajes ni colores exactos de DC.

| DC (de trabajo) | Nombre final | Qué lo hace distinto |
|---|---|---|
| Batman | **Cuervo** | Tema cuervo (no murciélago), ex policía, capa de plumas metálicas, gancho y bombas de humo |
| Superman | **Centinela Solar** | Último de un pueblo nacido dentro de una estrella. Se debilita en la oscuridad del eclipse. Blanco y dorado, sin letra en el pecho |
| Wonder Woman | **Atalanta** | De las Hespérides (mito griego). Lanza y escudo, sin lazo ni tiara |
| Flash | **Estela** | Velocidad del rayo del eclipse. Violeta, estelas de luz |
| Green Lantern | **Arquitecto** | Guantelete tecnológico propio |
| Aquaman | **Heredero Abisal** | Príncipe de la ciudad hundida bajo Puerto Óxido |
| Cyborg | **Bastión** | Héroe con implantes |
| Joker | **Mascarada** | Villano teatral de máscaras; nada de payaso |
| Bane | **Remache** | Matón con pistones hidráulicos |
| Pingüino | **El Albatros** | Jefe del contrabando del puerto |
| Dos Caras | **Dualidad** | Puede terminar aliado o enemigo |
| Lex Luthor | **Víctor Halden** | Dueño de Corona Corp, vende implantes ilegales |
| Darkseid | **El Eclipsador** | Causó el eclipse, quiere juntar todos los Linajes |
| Amanda Waller / Gordon / Lois / Alfred / Lucius / Oráculo | **Directora Brandt / Comisaria Rivas / Lucía Vega / Tano / Ingeniera Okafor / Señal** | NPCs de trabajo y ayuda |
| Liga de la Justicia / Legión del Mal | **Liga de Guardianes / Cofradía Carmesí** | Bandos |
| Gotham / Metrópolis / Daily Planet / Arkham | **Ciudad Vórtice / Corona / El Faro / Penal Islaroca** | Lugares |

**Todos los del elenco son NPCs**: dan misiones, entrenan, pelean a tu lado o en contra, y algunos son jefes. Nadie juega "de Cuervo". De ellos se ganan **piezas de traje inspiradas** (la capa de plumas, la corona solar) al terminar su cadena de misiones.

---

## 3. El mundo
### 3a. Las 3 ciudades
| Ciudad | Clima | Quién manda al empezar | Barrios (peligro) |
|---|---|---|---|
| **Ciudad Vórtice** | Noche y lluvia, ladrillo, escaleras de incendio, gárgolas | Vigilantes y pandillas | Centro (bajo), Barrio Viejo (medio), Los Callejones (alto), Costa del Penal (alto) |
| **Corona** | Torres de cristal, sol, drones, pantallas gigantes | Corona Corp y la Liga | Plaza Corona (bajo), Distrito Financiero (medio), Parque Industrial (medio), Bajo Corona (alto) |
| **Puerto Óxido** | Grúas, contenedores, óxido, neón, niebla verde-gris | Cofradía y contrabandistas | Feria del puerto (bajo), Muelles (medio), Mercado Negro (alto), Astillero hundido (alto) |

- **Entre las ciudades**: puente colgante (Vórtice–Corona), autopista elevada (Corona–Puerto) y **tren elevado** que une las tres. En el medio, zonas salvajes: **Refinería abandonada**, **Bosque de antenas** y la **Costa de chatarra**, con jefes errantes, Catalizadores y eventos.
- **Después**: Ciudad Hundida (bajo el puerto, se entra por las alcantarillas), Hespérides (isla) y Umbra (solo en el final).
- **Sin paredes invisibles**: podés ir a cualquier lado desde el principio; en los barrios de peligro alto te pueden destrozar.
- **Viajar**: a pie, gancho, vuelo o velocidad si tu poder lo da, vehículos (5d), tren (pagás boleto o te colás) y **viaje rápido** a escondites que abrís con reputación de esa ciudad.
- **Día y noche**: un día dura 24 minutos. De noche hay más crimen, menos policía en Vórtice y más daño para los Rasgos nocturnos. Clima que rota: lluvia, niebla, Apagón (evento).

### 3b. Lugares con interior (se puede entrar)
Las puertas que se abren tienen el tag `Entrada`; cada interior es un módulo aparte que se carga al entrar (bueno para el celular).

| Ciudad | Lugares |
|---|---|
| Vórtice | **Comisaría** (calabozo, sala de pruebas, oficina de Rivas), **El Faro** (redacción y terraza), **Bar La Gárgola** (información y contratos), **Casa de empeño** (vender lo robado), **Subte abandonado** (atajos y escondite), **Torre del reloj** (El Nido, base de los Vigilantes), departamento propio |
| Corona | **Banco Central Corona** (bóveda, atraco grande), **Joyería Aurora**, **Laboratorio de Kessler**, **Torre Halden** (pisos que se abren con la historia), **Estación del tren**, **Shopping Corona** (tiendas de trajes y gadgets), **Academia de la Liga** |
| Puerto Óxido | **Mercado Negro** (laberinto de contenedores), **Taller de Tano**, **Galpón del Albatros**, **Barco del Albatros**, **Aduana** (depósito de decomisos), **Alcantarillas** (entrada a Ciudad Hundida), **La Fundición** (base de la Cofradía) |
| Zonas del medio | Refinería (interior de tanques y caños), estación de servicio en la autopista, faro de la costa |

Cada lugar tiene algo que hacer: un NPC, una tienda, un trabajo, un crimen posible o un secreto.

---

## 4. Tu personaje
### 4a. Creador
Tu avatar de Roblox + piezas de traje para mezclar (8 cascos/máscaras, 8 capas, 8 petos, 6 hombreras, 6 guantes, 6 botas al empezar; se ganan más), **3 canales de color** por pieza, material (tela, cuero, metal, neón), largo de capa, **emblema propio** (20 formas, color, borde y brillo), **nombre de héroe + título** (los títulos se ganan), **estilo de pelea** (Puños, Espada, Bastón, Armas no letales, Gadgets), **base propia** decorable y **3 espacios de personaje** por cuenta.

### 4b. Cómo conseguís tus poderes
1. Creás tu personaje con ropa de civil.
2. **Origen al azar** (6 inicios, cada uno con su primera misión, su NPC y una ventaja chica):
   | Inicio | Dónde estabas | Primer NPC | Ventaja |
   |---|---|---|---|
   | Estibador | Puerto Óxido | El Albatros | +10 % vida |
   | Pasante | Laboratorio de Corona Corp | Ingeniera Okafor | Implantes -1 carga |
   | Repartidor | En moto por Vórtice | Comisaria Rivas | Dash -0,5 s |
   | Fotógrafo | Terraza de El Faro | Lucía Vega | +5 % crítico |
   | Preso | Celda del Penal Islaroca | Dra. Kessler | +15 % daño con poca vida |
   | Acróbata | Feria del puerto | Confeti | Doble salto |
3. Cae el eclipse, una esquirla de luz negra te atraviesa, te despertás con un NPC al lado.
4. **El Linaje te toca** con la ruleta (probabilidades siempre a la vista, suman 100 %):
   | Rareza | % | Linajes |
   |---|---|---|
   | Común | 55 % | Fuerza Bruta, Reflejos, Piroquinesis |
   | Poco común | 28 % | Electro, Criogenia, Telequinesis |
   | Raro | 12 % | Velocista Cinético, Sombra Viva, Sangre Abisal |
   | Legendario | 4 % | Origen Estelar, Herencia Olímpica |
   | Mítico | 1 % | Eclipse |
   Seguro de mala suerte: cada 40 tiradas sin Raro o mejor, la siguiente lo es. Las tiradas (**Fichas de Eclipse**) se ganan jugando. **Sin poder también se puede**: con tecnología e implantes, un Común es fuerte igual.
5. Elegís bando al terminar el prólogo.

### 4c. El juego no te explica lo que elegís
Ramas, caminos al segundo poder, decisiones de historia y Rasgos se muestran solo con **nombre, símbolo y una frase misteriosa** del NPC (Fénix: "Lo que arde, vuelve." / Infierno: "Que no quede nada."). En el menú, lo nuevo aparece como "???" hasta que lo usás por primera vez.

### 4d. Partes de un poder
| Parte | Qué es | Cómo se consigue |
|---|---|---|
| **Linaje** | El tipo de poder | Ruleta |
| **Variante** | Cómo se manifiesta; cambia efectos y abre 2 habilidades | Todos empiezan en **Normal**. Las otras 3 de cada Linaje se consiguen con una **condición secreta** (lugar + acción + Catalizador). Mutar a otra reemplaza la anterior |
| **Rasgos** | Modificador chico | **Salen de cómo jugás**: en cada Despertar y cada 10 niveles te da el Rasgo que más se ganó tu forma de jugar. No se tiran |
| **Rama de evolución** | En qué se convierte tu poder | La elegís a ciegas en el Despertar 1 (2 opciones) |
| **Chips de técnica** | Cambian una habilidad | Caen de jefes y eventos |
| **Segundo poder** | Otro Linaje completo | Despertar 2, por uno de 3 caminos |
| **Técnica combinada** | Habilidad que solo existe con 2 Linajes compatibles | Automática (12 al principio, algunas secretas) |

**Variantes secretas (ejemplos)**: Llama azul = Catalizador "Gas de Corona" + 50 enemigos con fuego en Corona · Brasa lenta = quemar 200 veces sin matar en Puerto Óxido de noche · Fuego sombrío = "Ceniza de Umbra" + caer 3 veces en un Apagón · Gigante = tirar 100 objetos pesados · Densidad = bloquear 300 golpes con "Granito del penal" · Furia roja = ganar 20 peleas con menos de 15 % de vida · Eco = 100 parry seguidos en el Penal · Precisión = 500 críticos con "Lente de Okafor" · Tiempo lento = parry al mismo tiempo que otro jugador en un evento. Los Catalizadores caen muy poco y se intercambian; los NPCs y El Faro dan pistas a medias.

**Rasgos por estadísticas (ejemplos de 30)**: muchos dash → Pies ligeros · muchos parry → Precisión · ganás con poca vida → Calle · jugás de noche → Nocturno · trabajos técnicos → Mente técnica · frenás crímenes → Protector · ayudás criminales → Despiadado · una sola habilidad → Especialista · todas parejo → Versátil · te derrotan mucho → Terco · hablás con muchos NPCs → Carismático · recorrés el mapa → Explorador · **nuevos con la ciudad viva**: te escapás de la policía muchas veces → Escurridizo (la Búsqueda baja más rápido) · atrapás a muchos buscados → Cazador (ves a los buscados de más lejos) · salís mucho en las noticias → Celebridad (más Fama, pero los ladrones te eligen) · hacés atracos en silencio → Fantasma (los testigos tardan más en llamar).

**Ramas (Despertar 1, nivel 25)**: Piroquinesis → Fénix o Infierno · Fuerza Bruta → Coloso o Demoledor · Reflejos → Sombra o Maestro. Abre la definitiva (V).

**Segundo poder (Despertar 2, nivel 60)**: **Transferencia** (Brandt: el Linaje de un jefe que venciste) · **Resonancia** (Señal + Atalanta: ruleta entre Linajes afines) · **Núcleo artificial** (Kessler + Okafor: implante que hace de poder, ocupa toda la Carga Cibernética). Con 2 poderes equipás 4 habilidades y, si son compatibles, la **Técnica combinada** (B): Vapor (fuego + hielo), Plasma (fuego + electro), Meteoro (fuerza + telequinesis), Asesino fantasma (reflejos + sombra), Tormenta en movimiento, Glaciar, Supernova, Sobrecarga.

---

## 5. Combate y progresión
### 5a. Combate en tiempo real
Combo de 4 golpes (clic), bloqueo y parry (F), dash (Q), 3 habilidades (Z, X, C), gadget (G), definitiva (V), técnica combinada (B). Botones para celular. Los enemigos avisan con zonas rojas en el piso. **El servidor decide los golpes** (hitbox en el servidor, distancia, recargas, energía, límite de pedidos). **Derribar sin matar**: a los civiles y a la policía se los deja fuera de combate (nada de muertes ni sangre; apto para todo público).

### 5b. Niveles y árbol
1 punto por nivel, 3 ramas por Linaje (Poder, Cuerpo, Técnica). Despertar 1 (nivel 25) y Despertar 2 (nivel 60), cada uno con misión y jefe.

### 5c. Tecnología e implantes
- **Tecnología** (Taller): Traje (vida y escudo), Gadget (gancho, humo, dron, inhibidor de cámaras, esposas de energía...), cada uno de Mk I a Mk V con chatarra, chips y materiales.
- **Implantes** (Dra. Kessler): Brazo, Ojos, Columna. Usan **Carga Cibernética**; si te pasás perdés Sincronía con tu Linaje. Más máquina o más poder.
- **Transferencias**: los jefes con Linaje sueltan un **Fragmento**; transferido te da 1 habilidad extra (1 ranura, después 3). Se puede pasar parte del árbol entre tus espacios. No se venden.

### 5d. Vehículos
Moto, auto y camioneta (se fabrican o se compran), más los del mundo: autos civiles (se pueden robar: baja la Fama y sube la Búsqueda), patrulleros (solo con el trabajo de Patrullero), tren elevado. El auto robado tiene **rastreador**: si no lo llevás al desarmadero del puerto en 3 minutos, la policía sabe dónde está.

---

## 6. Bandos y reputación (la estadística que más importa)
**Bandos**: Liga de Guardianes (proteger, rescatar), Cofradía Carmesí (robar, sabotear), Vigilantes (investigar, de noche) y Neutral (todos empiezan así). La lista de jugadores se agrupa por bando con su rango (Novato → C → B → A → S).

| Reputación | Rango | Sube con | Baja con | Qué cambia |
|---|---|---|---|---|
| **Fama** (héroe ↔ villano) | −1000 a +1000 | Rescatar, frenar crímenes, atrapar buscados, ayudar jugadores, salir bien en las noticias | Robar, atracos, derribar policías, lastimar civiles, salir mal en las noticias | Tu **título** visible (Promesa → Héroe de Vórtice / Matón → Azote del Puerto), cómo te tratan civiles y policía, qué bandos te aceptan |
| **Por ciudad** (3) | 0 a 1000 | Trabajos, misiones y eventos en esa ciudad | Abandonar eventos, crímenes contra sus vecinos | NPCs, tiendas, escondites, viaje rápido y el arco de historia de esa ciudad |
| **De bando** | 0 a 1000 | Misiones de bando | Atacar a jugadores de tu bando | Rango; para subir, además, prueba con el líder |
| **De grupo** (Policía, Prensa, Corona Corp, Pandillas, Contrabandistas) | −500 a +500 | Trabajos para ellos | Trabajar para sus rivales | Precios, información, si te persiguen o te ayudan. Subir con uno baja con su rival |
| **Confianza con NPCs** | 0 a 100 | Hablar, ayudarlos, sus cadenas | Elegir en contra | Mentores, refuerzos, aliado o villano |

Se muestran como **barras con un título**, sin números exactos. Los números viven en `Config.luau`.

---

## 7. Ley y crimen: la ciudad viva
### 7a. Testigos y llamadas a la policía
- Los civiles tienen **ojos**: si ven un crimen (robo, pelea con policía, auto robado, vidriera rota), dudan 1 s, salen corriendo y **llaman a la policía** con el celular (4 s, animación visible y un ícono de teléfono arriba de la cabeza).
- Podés **frenar la llamada**: asustarlo (grito, sin daño), taparte la cara (máscara puesta = solo te sube la Búsqueda, no tu Fama personal) o hacerlo sin que te vean. Un héroe cerca puede proteger al testigo.
- **Teléfonos públicos y botones de alarma** en negocios: los civiles corren hacia ellos si no tienen señal.
- **Tiempo de respuesta** por barrio: centro 15 s, medio 30 s, Callejones y Mercado Negro 60 s o más (o nunca, si las Pandillas te quieren).

### 7b. Vigilancia
- **Cámaras de seguridad**: muchas en Corona, algunas en Vórtice, casi ninguna en el puerto. Si te graban cometiendo un crimen, la Búsqueda sube aunque no haya testigos y la policía tiene tu **descripción** (color del traje). Se pueden apagar con el gadget inhibidor, hackear (Mente técnica) o romper (eso también es un crimen).
- **Drones de Corona Corp** que patrullan Corona y siguen a los buscados.
- **Reflector de la comisaría** en Vórtice: de noche barre el cielo y marca a los buscados que vuelan.
- **Informantes**: algunos civiles del bar La Gárgola venden dónde está un buscado (a héroes) o dónde hay un atraco fácil (a villanos).

### 7c. Búsqueda (1 a 5 estrellas, por ciudad)
| Estrellas | Qué pasa |
|---|---|
| 1 | Un patrullero viene a mirar; si te ve, te pide que te frenes |
| 2 | 2 patrulleros te persiguen |
| 3 | Policía con escudos y drones. **Los jugadores de la Liga y los Vigilantes ven tu zona en el mapa** y ganan Fama y recompensa si te atrapan |
| 4 | Helicóptero con reflector, cortes de calle, tu posición exacta para los héroes |
| 5 | Unidad Brandt (agentes con Linaje) y aviso en todas las pantallas de la ciudad |

- Baja sola si nadie te ve (más rápido en escondites, en el subte o cambiando de traje en tu base).
- **Te atrapan**: derrotado por policía o jugador → vas al **calabozo** (comisaría) o al **Penal Islaroca** con 4-5 estrellas. Perdés parte del **dinero en mano** (no el del banco ni objetos). Salís esperando (30 a 120 s), pagando fianza o **escapándote** (minijuego corto; otros jugadores pueden ayudarte desde afuera = evento).
- **Policía corrupta**: con mucha reputación de Pandillas, la policía del puerto "no ve" algunos crímenes; con soborno (dinero) se borra 1 estrella una vez por día.

### 7d. Callejones peligrosos
- Zonas marcadas por la luz: sin farolas, vapor, grafitis, sin cámaras. De noche aparecen **emboscadas** (2 a 5 matones) y **asaltantes** que te quieren sacar el dinero en mano.
- Riesgo y premio: más botín, Catalizadores raros, contratos del bar y **atajos** (escaleras de incendio, techos, subte).
- Algunos tienen dueño: si tenés buena reputación con las Pandillas, te dejan pasar; si no, cobran peaje o atacan.
- Eventos propios: "Callejón del Cuervo" (Cuervo NPC aparece de noche y te pone a prueba), "Fiesta clandestina" (redada de policía al azar).

### 7e. Ladrones (NPC y jugadores)
| Tipo | Qué hace | Cómo se lo frena |
|---|---|---|
| **Carterista** | En multitudes (Plaza Corona, Feria), te roba dinero en mano si te quedás quieto | Lo ves por el brillo de la mano; lo perseguís y recuperás el doble |
| **Motochorro** | Arrebata a civiles y escapa en moto | Persecución; dejarlo pasar da Fama 0, frenarlo +Fama y noticia |
| **Asaltante de callejón** | Te encara y te pide el dinero | Pelear, pagar, o escapar por los techos |
| **Ladrón de autos** | Se lleva autos estacionados (también el tuyo si lo dejás afuera) | Rastreador del auto, persecución |
| **Banda de vidrieras** | Rompen una vidriera y cargan bolsos (crimen al azar) | Evento chico de 2-3 jugadores |

**El jugador ladrón**: puede robar carteras (minijuego de tiempo, sin pelear), cajeros, autos y vidrieras. Todo baja Fama, sube Búsqueda y da **dinero sucio**.

**Dinero**: en mano (lo perdés si te atrapan o te asaltan), en el banco (seguro; se deposita en cajeros) y **sucio** (de crímenes; hay que lavarlo en el Mercado Negro o la casa de empeño, que se queda un porcentaje). Comprar cosas caras con dinero sucio sube la Búsqueda.

### 7f. Atracos
| Tamaño | Dónde | Jugadores | Cada cuánto |
|---|---|---|---|
| Chico | Kiosco, cajero, camión de caudales chico, casa de empeño | 1-2 | Siempre que quieras (con recarga por jugador) |
| Mediano | Joyería Aurora, Aduana del puerto, oficina de Corona Corp | 2-4 | Recarga de 20 min por lugar en el servidor |
| Grande | **Banco Central Corona**, **Tren blindado** entre ciudades, **Cargamento del Albatros** | 4-8 | 1 por hora en el servidor, con aviso 2 min antes a los héroes |

**Fases**
1. **Preparación** (opcional, da ventajas): planos (del Albatros o del bar), reconocimiento con cámara de fotos, conseguir herramientas (taladro, inhibidor, explosivo de pintura), elegir **sigiloso o ruidoso**.
2. **Entrada**: guardias, cámaras, testigos. Sigiloso = alarma más tarde, menos Búsqueda.
3. **Bóveda**: un rol por jugador, cada poder ayuda distinto: hackear (Electro, Mente técnica), taladrar (cualquiera, con minijuego de temperatura), forzar (Fuerza Bruta), abrir cerradura de lejos (Telequinesis), vigilar (Reflejos, Sombra).
4. **Escape**: la alarma pone la Búsqueda en 4; hay que llegar a un escondite o al Mercado Negro. **Los héroes del servidor reciben la alerta** y pueden defender el lugar o cortar el escape: el atraco grande es un evento **jugadores contra jugadores + NPCs**.
5. **Reparto**: el botín se divide en partes iguales; si caés, perdés tu parte en mano.

**Del lado héroe**: defender un atraco, recuperar el botín y devolverlo da Fama, reputación de ciudad y de Policía, y una **noticia**. Así villanos y héroes se necesitan.

Reglas: **nada de Robux en los atracos**; el botín es dinero del juego y piezas cosméticas (máscaras de atraco). Sin armas letales ni sangre: los guardias quedan "fuera de combate".

---

## 8. Noticias: El Faro
- **Dónde se ven**: el diario en kioscos (se agarra y se lee), **pantallas gigantes** en Corona, la **radio de Señal** en autos y escondites, y la app **Noticias** del celular del jugador.
- **De qué hablan** (se generan solas con lo que pasa en el servidor):
  - Titulares con **nombres de jugadores** (nombre de héroe, filtrado con el filtro de texto de Roblox): "Promesa de Vórtice frena el atraco al Banco Central", "Azote del Puerto escapa con el botín del tren".
  - Avisos de buscados con su descripción y recompensa.
  - Control de barrios, ranking semanal de bandos, eventos que vienen (Apagón esta noche).
  - **Rumores** de El Faro: misiones cortas del día y pistas a medias de Variantes y Técnicas secretas.
- **Las noticias mueven la reputación**: salir en un titular multiplica la Fama ganada (x1,5) o perdida. Por eso importan los **fotógrafos**: un jugador con el trabajo de Reportero que saca la foto de un crimen o un rescate gana dinero y hace que la noticia salga (con su nombre al pie).
- **Tapar una noticia**: la Cofradía puede pagarle a un editor corrupto para que una noticia mala no salga (una vez por día, caro). Los Vigilantes pueden filtrar pruebas para que salga igual.
- **Edición del domingo** (una vez por semana real): resumen con los 3 mejores héroes, los 3 más buscados y el barrio más peleado.

---

## 9. NPCs: trabajos y ayuda
La historia se cuenta **hablando con NPCs** (diálogo con recuadro y 4 respuestas). No hay flechas mágicas.

| Trabajo | NPC | Qué hacés | Qué te da |
|---|---|---|---|
| Reportero | Lucía Vega, El Faro | Fotos de crímenes, rescates y atracos | Dinero, noticias con tu nombre, rumores |
| Mecánico | Tano, taller del puerto | Arreglar autos y gadgets | Chatarra y chips |
| Patrullero | Comisaria Rivas | Patrullas, **esposar a buscados** (jugadores incluidos), usar patrullero | Reputación de Policía y Liga, información |
| Ayudante de laboratorio | Ingeniera Okafor | Probar prototipos | Planos de trajes y gadgets |
| Contrabandista | El Albatros | Llevar paquetes sin que te vean | Reputación de Contrabandistas y Cofradía, implantes baratos |
| **Guardia de seguridad** (nuevo) | Jefe de seguridad del Banco | Turnos en el banco o la joyería; si hay atraco, sos el primero en defender | Dinero limpio, reputación de Corona Corp |
| **Informante** (nuevo) | Dueña del bar La Gárgola | Escuchar conversaciones, seguir sospechosos | Pistas de atracos y buscados para vender a cualquier bando |

Cada trabajo sube de nivel (Aprendiz → Experto) y abre misiones. **Pedir ayuda**: mentores (te enseñan nodos), pistas (Señal por radio), refuerzos (un NPC héroe te acompaña con buena confianza), implantes y transferencias (solo si trabajaste para Kessler o Brandt).

---

## 10. Historia sin fila
- **Prólogo: Noche del Eclipse** (igual para todos, centro de Vórtice): despertás tu Linaje, Señal te guía, elegís a quién seguir.
- **3 arcos de ciudad, en el orden que quieras** (se abren con reputación de esa ciudad; los enemigos se ajustan a tu nivel):
  | Arco | Ciudad | Qué pasa | Jefes | En grupo |
  |---|---|---|---|---|
  | Ciudad en llamas | Puerto Óxido | Una pandilla con implantes robados toma el puerto; los implantes salen de Corona Corp | Remache, El Albatros | Asalto al barco (hasta 8) |
  | La torre de cristal | Corona | Halden presenta implantes "para todos"; Centinela Solar desaparece; te infiltrás en Corona Corp | Robot centinela gigante, Halden | Raid: fuga del Penal (4-8) |
  | Las caras de la ciudad | Vórtice | Mascarada juega con la ciudad; Dualidad duda de qué lado está | Mascarada, Dualidad | Persecución por los techos (4) |
- **Lo que hay abajo** (Ciudad Hundida y Hespérides, Despertar 1 en el medio), **Eclipse total** (arranca cuando terminaste 2 de 3 arcos o cuando el servidor completó suficientes), **Umbra** (raid final, Despertar 2) y **Ciudad rota** (después del final: versiones malvadas de los héroes, temporadas).
- **Decisiones grandes** en cada arco (ej.: entregar a Remache a la policía o dejar que Brandt lo use): cambian qué NPC te ayuda, quién controla la ciudad para vos, quién se vuelve villano y qué final ves. **3 finales por bando.**
- **Misiones de bando** (3 a 5 por arco y bando), **misiones de personaje** (cadena de 3 por NPC principal, con confianza), **Rumores** diarios.

## 11. Varios jugadores en el mismo mapa
- Servidores de **hasta 30 jugadores**, todos en el mismo mundo.
- **Control de barrios**: cada barrio tiene un medidor por bando que se mueve con lo que hacen todos (misiones, crímenes frenados o cometidos, atracos, eventos). El bando que controla un barrio tiene descuentos y un bono chico ahí. Ranking semanal por ciudad.
- **Crímenes al azar** cada 3 a 5 minutos en barrios al azar (robo, rehenes, pelea de pandillas, villano chico con modificadores): unos lo frenan, otros lo ayudan.
- **Recompensas por buscados** (7c) y **atracos** (7f): el PvP pasa ahí, en las guerras de bandos y en zonas marcadas. **Nadie te ataca de la nada en una zona segura** (plazas, bases, interiores con NPC de trabajo).
- **Eventos de servidor** que rotan: Apagón (ciudad a oscuras, se apagan cámaras y farolas, más crimen), Lluvia de esquirlas, Fuga del penal, Tren blindado, Invasión de Umbra (desde Eclipse total).
- **Grupos** de hasta 4 para misiones; ayudar a otro jugador da reputación de ciudad.

## 12. Que cada partida sea distinta
6 inicios, Linaje al azar, Variantes secretas, Rasgos por estadísticas, decisiones con 3 finales por bando, crímenes y atracos que cambian, enemigos de élite con modificadores al azar (Rápido, Blindado, Explota al morir, Invoca drones), rumores diarios y **Renacer** al terminar la historia (nuevo inicio y Linaje; te quedás piezas de traje, títulos, base y un bono de Legado).

## 13. Monetización (resumen; manda `ideas/monetizacion.md`)
- Fichas de Eclipse se ganan jugando. Si algún día se venden por Robux: probabilidades a la vista con botón con texto antes de comprar y `PolicyService`; si no, no se venden. Nada de casino.
- Nada de Robux en atracos, Búsqueda, fianza ni reputación (no se compra Fama). Lo pago es cosmético (trajes, emblemas, decoración de base) y comodidad que no rompe el juego.

## 14. Arte y sonido
- Estilo: cuerpo de avatar de Roblox (bloques R15) y **el detalle va en el traje** (`arte/GUIA-ESTILO.md`, nivel de detalle obligatorio). Cada ciudad con su paleta: Vórtice (ladrillo, violeta, luna), Corona (vidrio, blanco, oro, azul Liga), Puerto Óxido (óxido, verde-gris, neón naranja).
- **Modelos y animaciones: Claude en Blender** (`ideas/PROMPTS.md`). **Sonidos y música: ForgeGUI**.
- Lo que se ve de lejos (policía, ladrones, testigos) tiene que **leerse en el celular**: luces azul y roja en patrulleros, ícono de teléfono sobre el testigo, bolso brillante en el ladrón.

## 15. Técnico (lo más simple, anotado)
- Un solo place con `StreamingEnabled`, las 3 ciudades a ~1 km; interiores como módulos que se cargan al entrar. Si no rinde en celular, cada ciudad pasa a su propio place con teletransporte.
- Todo lo importante en el servidor: daño, Búsqueda, testigos (el servidor decide qué ve cada civil), dinero, botín, reputación, noticias.
- Guardado con **ProfileStore** (bloqueo de sesión, autoguardado, `BindToClose`): nivel, espacios, Linajes, Variantes, Rasgos, estadísticas, reputaciones, dinero en mano/banco/sucio, trajes, base. El control de barrios y el ranking semanal van en un DataStore aparte por bando.
- Los titulares con nombres de jugadores pasan por el filtro de texto de Roblox.

## 16. Plan por etapas
**Primero los modelos, después el código** (pedido de Juani). Modelos en el orden de `PROMPTS.md`: trajes principales → NPCs y civiles → policía y ladrones → vehículos → las 3 ciudades (una calle de muestra de cada una) → interiores → props de vigilancia y noticias → animaciones.

| Etapa | Qué queda andando |
|---|---|
| 0 | Carpeta, Rojo, ProfileStore, Config.luau |
| 1 | Combate graybox. **Si no es divertido, no se sigue.** |
| 2 | Menú con 3 espacios + ruleta de Linaje + 3 Linajes comunes |
| 3 | Niveles, árbol, guardado |
| 4 | Prólogo + bando + **reputación** (Fama, ciudad, bando, grupos) con títulos |
| 4b | Graybox del mapa abierto: 3 ciudades, caminos, barrios de peligro, viaje rápido, interiores básicos. Probado con 3 jugadores y en celular |
| 5 | **Ley y crimen**: civiles con testigos y llamadas, Búsqueda, policía, cámaras, calabozo |
| 6 | Ladrones, callejones, dinero en mano/banco/sucio |
| 7 | **Atracos** (uno chico, la joyería y el Banco Central) con alerta a los héroes |
| 8 | **Noticias** (El Faro, pantallas, app) |
| 9 | Tecnología, implantes, vehículos |
| 10 | Primer arco de ciudad (Puerto Óxido) + control de barrios |
| 11 | Despertar 1 |
| 12 | Arte final, sonidos (ForgeGUI) y prueba con amigos |
| 13 | Analytics, celular, publicar beta (lo publica Juani) |

## 17. Decisiones simples tomadas (se pueden cambiar)
- Un día del juego = 24 min. Búsqueda por ciudad, no global. Máscara puesta protege tu Fama personal pero no la Búsqueda.
- Al ser atrapado se pierde el 25 % del dinero en mano.
- Atraco grande: 1 por hora por servidor, aviso 2 min antes a los héroes.
- Lavado de dinero: el Mercado Negro se queda el 30 %, la casa de empeño el 20 % pero con tope diario.
- Noticias: máximo 1 titular por jugador por hora (para que no se llene de lo mismo).
