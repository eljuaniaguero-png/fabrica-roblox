# Linajes del Eclipse: análisis de referencias, cómo usar el sistema de diseño y todos los prompts en orden

30 oct 2026 · Para Juani · Ficha: `rpg-linajes-ficha-v2-superheroes-2026-10-30.md` · Sistema de diseño: https://claude.ai/artifact/WJxLkCEZEGJWzWzuyeU49y

---

## Parte 1. Qué dicen tus 25 referencias

Las capturas de `Descargas\referencias` son de 4 tipos. De cada una tomamos **la idea**, nunca personajes, logos ni nombres.

| Capturas | Qué muestran | Qué tomamos |
|---|---|---|
| 154230 a 154315 (Bloodlines: menú, lista de linajes, árbol, barras, lista de pueblos) | Menús oscuros con marcos ornamentados | Menú de 3 espacios, lista con %, árbol de nodos, barras con escudo, lista por bando (ya está en la ficha) |
| 155302 a 155744 (Bloodlines: mundo) | Ruinas con niebla verde-gris, texturas de piedra y óxido, telarañas, un cristal azul brillante que se junta | **Niebla** que tapa el fondo (barato para el celular y da clima), texturas sucias de piedra y óxido para Puerto Óxido y Ciudad Vórtice, **objetos brillantes** en el piso para juntar (fragmentos, chatarra) |
| 155741 a 155901 (juego de velocista) | Calle de ciudad con senda peatonal y semáforos, estela de rayos amarilla, **flechas rojas en el piso** antes de un ataque, barra azul y verde con un rombo en el centro, medidor de velocidad, íconos de habilidad abajo (C, R), aviso "tenés 5 puntos de habilidad" | Ciudad con calles reales (Distrito Corona), estelas de poder con partículas, **los avisos rojos en el piso que ya tiene la ficha**, HUD de barras con emblema al centro, aviso de puntos de árbol |
| 155926, 155943 (menú de trajes) | Elegir traje sobre fondo degradado violeta, personaje girando | **Pantalla de trajes**: cada héroe tiene varios trajes que se desbloquean (gran motivo para volver) |
| 155952 (Batman en Roblox) | Cuerpo de avatar de Roblox con capa, orejas y traje con textura | **Estilo de personaje**: el cuerpo es de bloques de Roblox y **el detalle va en el traje** (capa, casco, placas, texturas) |
| 160000 a 160014 (portadas de juegos de DC en Roblox) | Grupo de héroes en pose, Batman en techo bajo la lluvia, Superman volando | Cómo hacer el **ícono y las miniaturas** del juego: personajes en pose, luz dramática, título grande |
| 160025, 160028 (ciudades) | Ciudad brillante junto al agua / ciudad de cómic de noche con luna | **Distrito Corona** (rascacielos de día, agua) y **Ciudad Vórtice** (torres altas de noche, luna, reflectores) |
| 160339, 160342 (Bloodlines: diálogo con NPC) | Recuadro con el nombre del NPC, texto en cursiva, 4 respuestas abajo ("¿Qué te pasó?", "Adiós") | **El sistema de diálogo** para hablar con NPCs, pedir trabajo y ayuda (ya está en la ficha) |

### El cambio importante que sale de las referencias
En todos los juegos que mandaste, **el cuerpo es de avatar de Roblox (bloques)** y lo que impresiona es **el traje**: capa con pliegues, casco con detalle, placas, líneas que brillan. Por eso actualicé el sistema de diseño:
- Héroes y villanos jugables o NPC: **cuerpo de avatar de Roblox + traje de piezas 3D con mucho detalle** (20.000 a 40.000 triángulos entre todas las piezas).
- Jefes gigantes que no son humanos (El Eclipsador, robots, criaturas): **modelo completo** de hasta 60.000 triángulos en varias mallas.
Así se ve como lo que te gusta, tiene muchos triángulos donde se notan, y los jugadores pueden usar los trajes sobre su propio avatar.

---

## Parte 2. Cómo usar el sistema de diseño (paso a paso)

El sistema de diseño ya está hecho y guardado en tu cuenta: **Linajes del Eclipse 3D**.

### Dónde mirarlo
1. Abrí https://claude.ai/artifact/WJxLkCEZEGJWzWzuyeU49y. Arriba ves la portada; en las pestañas, **Colores**, **Tipografía**, el **README** (las reglas) y **Modelos** (la lista de todo lo que hay que modelar).
2. Para no perderlo: pedime "fijá el sistema de diseño" y lo fijo en tu barra lateral.
3. Vos no tenés que diseñar nada: Claude lo lee y hace los modelos en Blender siguiendo esas reglas. Vos aprobás los renders.

### En tu PC (para que Claude Code lo respete siempre)
Pegale a Claude Code en `fabrica-roblox` el **Prompt 1**: copia las reglas del sistema de diseño a `linajes/arte/GUIA-ESTILO.md` y le agrega una línea a `CLAUDE.md` para que las lea antes de cada modelo.

### Si querés cambiar algo del estilo
Decímelo acá ("más oscuro", "cambiá el color de la Liga", "subí los triángulos de los jefes") y actualizo el sistema de diseño. Todo lo que se haga después ya sale con el cambio.

---

## Parte 3. Todos los prompts en orden (versión detallada)

**Cambios de Juani (30 oct, 20:00):** el juego no explica lo que conlleva lo que elegís; el Linaje te toca y la rama la elegís a ciegas; los Rasgos salen de tus estadísticas de juego; las Variantes se consiguen con condiciones secretas (prompts 36, 37, 37b, 37c y 39).

**Cambios de Juani (30 oct, 19:56):** los principales son NPCs; el jugador se arma su propio héroe; poderes con Variantes, Rasgos, ramas de evolución, segundo poder y técnicas combinadas; todo muy personalizable y cada partida distinta (prompts 20b, 36, 36b, 37, 37b, 39, 41b y 42).

**Cambios de Juani (30 oct, 19:12):**
- **Todos los diseños los hace Claude, en Blender.** No se usan ForgeGUI ni Gemini para modelos.
- **Los sonidos y la música los hace ForgeGUI.**
- **Los prompts tienen que ser muy específicos** y **se hacen animaciones** de todo.

**Dónde va cada uno:** todos en 💻 **Claude Code en tu PC** (`C:\Users\eljua\fabrica-roblox`).
- Para modelos y animaciones: abrí **Blender** con el conector de Claude prendido.
- Para importar y código: abrí **Roblox Studio** y, cuando haga falta, `rojo serve linajes`.
- **Un prompt por sesión.** Cuando termina, mirás los renders o probás lo que te diga, y recién ahí pasás al siguiente.
- Si un prompt dice "mostrame para aprobar", Claude se frena ahí y espera tu OK.

**Reglas que valen para todos los prompts** (Claude las tiene en `GUIA-ESTILO.md`, pero se repiten adentro de cada prompt para que no se pierdan):
- 1 stud = 0,28 m en Blender. Pivote en el centro de la base. Frente hacia -Y en Blender (queda -Z en Roblox).
- Cada malla ≤ 20.000 triángulos, un material por malla, UV dentro de 0-1, normales hacia afuera, normal map OpenGL.
- Texturas: 1024 px trajes y edificios importantes, 512 px casi todo, 256 px props chicos.
- Nada de logos, emblemas, trajes, colores exactos, frases ni música de DC. Los nombres de DC son de trabajo.
- Guardar el `.blend` antes de cada cambio grande. Todo modelo y animación se hace con un **script** en `linajes/arte/scripts/` para poder rehacerlo.
- Commit en español y push al terminar.

**NIVEL DE DETALLE OBLIGATORIO (PASO 2 de todo modelo).** El PASO 1 es un boceto de bloques a propósito: sirve solo para aprobar la forma y SIEMPRE se ve simple. El PASO 2 tiene que cumplir todo esto, si no, no se aprueba:
- **Bisel en todos los bordes** (0,02 a 0,05 studs, 2 segmentos): nada de cajas con aristas filosas.
- **Capas**: cada placa de armadura es una pieza encima de otra, con grosor y borde levantado, nunca un color pintado sobre una caja.
- **Líneas de panel, costuras, remaches y tornillos** modelados o en el normal map (mínimo 10 detalles chicos por pieza grande).
- **Formas curvas** donde corresponde (hombreras, cascos, peto con músculos marcados), con subdivisión antes de reducir al presupuesto.
- **Telas** (capas, bufandas, faldas) con simulación de tela en Blender, horneada con pliegues reales.
- **Alto y bajo poligonaje**: se esculpe una versión con mucho detalle, se hornea su normal map (OpenGL, 1024 px) sobre la versión del presupuesto de triángulos.
- **Texturas con desgaste**: rayones en metal, bordes más claros, suciedad en las juntas (ambient occlusion horneado). Nada de colores planos sin textura.
- **Comparación**: el render del PASO 2 va al lado del boceto del PASO 1 y tiene que verse claramente distinto.

### Colores de la guía (para copiar en los prompts)
| Token | Hex | Uso |
|---|---|---|
| fondo | #0e1016 | Negro azulado de la noche |
| superficie | #1b1f2a | Gris muy oscuro de paneles |
| eclipse | #f2652b | Naranja del eclipse |
| corona | #ffb347 | Borde dorado del eclipse, luz |
| asfalto | #3a3f4b | Calles, techos |
| ladrillo | #6e3b2e | Fachadas viejas |
| acero | #8a94a6 | Metal, implantes |
| neon-cian | #3fe0f0 | Luces de tecnología |
| liga | #2f6fdb | Acento Liga de Guardianes |
| cofradia | #c2213a | Acento Cofradía Carmesí |
| vigilantes | #6b5ba8 | Acento Vigilantes |
| neutral | #b8bcc6 | Acento Neutral |
| rareza: común / poco común / raro / épico / legendario / mítico | #9aa3ad / #4ed68a / #4fb3f2 / #a15cf0 / #f2a23a / #ff4d6d | Color del poder |
| aviso | #ff2a2a | Zonas rojas de ataque |

---

### Fase A. Preparar

#### Prompt 1 💻 Carpeta del juego y reglas de estilo
```
Hola. Arrancamos el juego nuevo "Linajes del Eclipse": RPG de superhéroes, combate en tiempo real,
multijugador, ambientado en una ciudad propia muy parecida al mundo de DC (nombres de DC solo de trabajo).
Seguí GUIA-PARA-CLAUDE.md. Los juegos viejos están en archivo/ (ver archivo/README.md): NO los toques.

1. Si existe ideas/rpg-linajes.md ("Herederos del Eco"), movelo con git mv a archivo/ideas-descartadas/.
2. Creá esta estructura:
   linajes/linajes.project.json  (Rojo: ReplicatedStorage/Shared, ServerScriptService/Server,
                                  StarterPlayerScripts/Client, ServerStorage/ServerPackages)
   linajes/src/shared/  linajes/src/server/  linajes/src/client/
   linajes/ideas/  linajes/arte/referencias/  linajes/arte/scripts/  linajes/arte/blender/
   linajes/arte/exports/  linajes/arte/renders/  linajes/arte/animaciones/  linajes/arte/sonidos/
3. Copiá TODAS las imágenes de C:\Users\eljua\Downloads\referencias a linajes/arte/referencias/
   (son de otros juegos: solo para ideas, nunca se suben a Roblox ni se copian).
4. Escribí linajes/ideas/ficha.md con la ficha que pego abajo, entera.
5. Escribí linajes/arte/GUIA-ESTILO.md con las reglas del sistema de diseño "Linajes del Eclipse 3D"
   (README + lista de Modelos, pegados abajo) y la tabla de colores con sus hex.
6. En CLAUDE.md: sacá la tabla de juegos viejos (dejá una línea: "Los juegos viejos están en archivo/"),
   poné "Juego activo: linajes/" y agregá estas reglas:
   - "Antes de cualquier modelo o animación, leé linajes/arte/GUIA-ESTILO.md."
   - "Los modelos y animaciones los hace Claude en Blender. Los sonidos y la música, ForgeGUI."
   - "Los nombres de DC son nombres de trabajo: nunca van en el juego publicado. Ningún modelo copia logos,
     emblemas, trajes ni colores exactos de DC."
7. Commit "Linajes: carpeta, ficha y guía de estilo" y push. Decime qué quedó.

[PEGAR ACÁ: la ficha rpg-linajes-ficha-v2-superheroes-2026-10-30.md]
[PEGAR ACÁ: el README y la sección Modelos del sistema de diseño]
```
(Si preferís no pegar nada, decime "arrancá" y lo lanzo yo en tu PC con todo adentro.)

---

### Fase B. Kit base en Blender (una vez)

#### Prompt 2 💻 Maniquí R15, materiales, luz y scripts base
```
Leé linajes/arte/GUIA-ESTILO.md y mirá las imágenes de linajes/arte/referencias/.

PARTE 1 — Maniquí exacto de Roblox:
1. En Roblox Studio, por MCP, creá un Dummy R15 de bloques (Avatar > Rig Builder > R15 > Block Avatar)
   y exportalo a linajes/arte/blender/maniqui-r15.fbx (clic derecho > Export Selection).
   Si el export necesita que yo toque algo, decime exactamente qué botón.
2. En Blender, importá ese FBX (escala 1/0,28 para que 1 stud = 0,28 m), con su esqueleto (armature)
   de 15 partes: Head, UpperTorso, LowerTorso, LeftUpperArm, LeftLowerArm, LeftHand, RightUpperArm,
   RightLowerArm, RightHand, LeftUpperLeg, LeftLowerLeg, LeftFoot, RightUpperLeg, RightLowerLeg, RightFoot.
3. Material gris claro #b8bcc6 sin brillo. Guardá linajes/arte/blender/kit-base.blend.

PARTE 2 — Materiales de la guía (Principled BSDF, roughness indicada):
- asfalto #3a3f4b (0,9), ladrillo #6e3b2e (0,85), acero #8a94a6 (0,35, metallic 0,8),
  tela-oscura #1b1f2a (0,8), cuero #2a2018 (0,6), bronce #a0703a (0,4, metallic 0,9),
  oro #d9a441 (0,3, metallic 1), blanco-armadura #e8e6e0 (0,4),
  neon-cian #3fe0f0 (emission 5), neon-eclipse #f2652b (emission 5), neon-aviso #ff2a2a (emission 6),
  liga #2f6fdb, cofradia #c2213a, vigilantes #6b5ba8 (0,5 los tres).
  Un material por color. Nombres exactos: MAT_<nombre>.

PARTE 3 — Luz de render (para todos los renders de aprobación):
- Fondo #0e1016, luz principal fría (color #9fb4ff, fuerza 3) desde arriba-izquierda a 45°,
  luz de borde naranja #f2652b desde atrás-derecha (fuerza 4), niebla suave (volumen, densidad 0,02).
- Cámara 50 mm. Tres cámaras guardadas: Frente, Costado (90°), Espalda (180°), a la altura del pecho.
- Render Eevee 1600x1000.

PARTE 4 — Scripts reutilizables en linajes/arte/scripts/:
- base.py: funciones para cargar el kit, aplicar material, contar triángulos por objeto, renderizar las
  3 vistas en una sola imagen (linajes/arte/renders/<nombre>_vistas.png) y exportar FBX por pieza.
- trajes.py: funciones para crear piezas de traje pegadas a un hueso del maniquí (casco en Head,
  peto en UpperTorso, hombreras en UpperArm, guantes en Hand, botas en Foot, capa en UpperTorso
  con simulación de tela horneada a malla con pliegues), cada una como objeto separado.
- ciudad.py y props.py vacíos con la estructura para usarlos después.

Render del maniquí en las 3 vistas y mostramelo. Commit "Linajes: kit base de Blender" y push.
```

---

### Fase C. Trajes de los personajes (uno por sesión)

Cada prompt sigue el mismo orden: **1) boceto de bloques → aprobar silueta, 2) detalle → aprobar, 3) exportar**. No se pasa al detalle sin tu OK.

#### Prompt 3 💻 Cuervo (DC de trabajo: Batman) · Vigilantes
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí linajes/arte/blender/kit-base.blend y guardalo como
linajes/arte/blender/cuervo.blend antes de tocar nada. Usá trajes.py y base.py.

PERSONAJE: Cuervo. Detective vigilante de Ciudad Vórtice, ex policía que perdió a su compañero.
Tema CUERVO (no murciélago). Diseño propio: nada de orejas de murciélago, capa con puntas de murciélago,
emblema de murciélago ni cinturón amarillo.

SILUETA (de lejos tiene que leerse así): hombros anchos por la capa de plumas, cabeza con pico corto,
capa larga hasta los tobillos que se abre en V hacia abajo.

PIEZAS (cada una objeto separado, pegada a su hueso):
1. Capucha-máscara (Head) — 8.000 tris: capucha de tela-oscura que cubre cabeza y frente; máscara de
   acero en la parte de arriba de la cara con un pico corto de 0,4 studs hacia adelante; dos ranuras de
   ojos con neon-cian (#3fe0f0) finas. Costuras visibles en la capucha.
2. Capa de plumas (UpperTorso) — 8.000 tris: 5 filas de plumas metálicas superpuestas (acero, roughness
   0,35) que bajan de los hombros hasta los tobillos; las de abajo más largas y separadas.
   Pliegues de tela horneados. Borde inferior irregular (plumas sueltas), NO en puntas de murciélago.
3. Peto (UpperTorso + LowerTorso) — 7.000 tris: armadura de placas de tela-oscura con bordes de acero;
   en el centro, el EMBLEMA PROPIO: una pluma de cuervo estilizada vertical de 0,6 studs en vigilantes
   (#6b5ba8) con borde neon-cian finito.
4. Hombreras (UpperArms) — 3.000 tris el par: tres plumas de acero en abanico cada una.
5. Antebrazos (LowerArms) — 3.000 tris el par: brazaletes de acero con 3 púas cortas hacia atrás;
   en el derecho, el lanzador de gancho (cilindro de acero con punta de 3 garras).
6. Guantes (Hands) — 2.000 tris el par: cuero negro con nudillos de acero.
7. Cinturón (LowerTorso) — 2.000 tris: cuero con 6 bolsillos de acero oscuro y hebilla con la pluma.
8. Botas (Feet) — 3.000 tris el par: botas altas de cuero con placas de acero en la canilla.
TOTAL ≤ 36.000 tris. Colores: 80 % tela-oscura/cuero, 15 % acero, 5 % vigilantes y neon-cian.

PASO 1: armá un boceto de bloques de todas las piezas (sin detalle) y renderizá las 3 vistas.
Mostramelo y esperá mi OK.
PASO 2: con mi OK, hacé el detalle completo cumpliendo el NIVEL DE DETALLE OBLIGATORIO de la guía. Renderizá las 3 vistas + primeros planos de capucha,
emblema y gancho. Tabla de triángulos por pieza. Mostramelo y esperá mi OK.
PASO 3: exportá cada pieza a linajes/arte/exports/cuervo/<pieza>.fbx. Guardá el script en
linajes/arte/scripts/personajes/cuervo.py. Commit "Linajes: traje de Cuervo" y push.
```

#### Prompt 4 💻 Centinela Solar (DC de trabajo: Superman) · Liga
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/centinela.blend.

PERSONAJE: Centinela Solar. Último de un pueblo que nació dentro de una estrella. Vuela, tiene superfuerza
y dispara rayos de luz. Se debilita en la oscuridad del eclipse. Diseño propio: SIN letra ni escudo en el
pecho, SIN la combinación azul-rojo-amarillo, SIN rulo en la frente.

SILUETA: armadura heroica clara, una corona de rayos solares flotando detrás de la cabeza, capa corta.

PIEZAS:
1. Casco abierto (Head) — 7.000 tris: diadema de oro que rodea la frente con 3 placas finas hacia atrás;
   la cara queda libre.
2. Corona solar (flota detrás de Head, a 0,5 studs) — 4.000 tris: anillo de 12 rayos de oro de largos
   alternados (0,6 y 0,9 studs), con un aro interior de neon-eclipse (#f2652b). Se anima girando lento.
3. Peto (UpperTorso + LowerTorso) — 9.000 tris: placas de blanco-armadura con bordes de oro; en el centro,
   EMBLEMA PROPIO: un sol de 8 puntas de 0,7 studs en relieve, oro, con centro neon-eclipse.
4. Hombreras (UpperArms) — 4.000 tris el par: placas redondeadas de blanco-armadura con borde de oro.
5. Capa corta (UpperTorso) — 6.000 tris: tela dorada (#d9a441, roughness 0,6) hasta las rodillas,
   cortada en 3 tiras que se separan abajo, pliegues horneados.
6. Brazaletes y guantes (LowerArms + Hands) — 4.000 tris el par: blanco-armadura con líneas de oro.
7. Grebas y botas (LowerLegs + Feet) — 4.000 tris el par: blanco-armadura, rodilleras de oro.
TOTAL ≤ 38.000 tris. Colores: 60 % blanco-armadura, 30 % oro, 10 % liga (#2f6fdb) en las líneas de las
grebas y neon-eclipse.

PASO 1: boceto de bloques, 3 vistas, esperá mi OK.
PASO 2: detalle completo con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + primeros planos de corona, emblema y capa. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/centinela/, script en scripts/personajes/centinela.py,
commit "Linajes: traje de Centinela Solar" y push.
```

#### Prompt 5 💻 Mascarada (DC de trabajo: Joker) · Cofradía · jefe
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/mascarada.blend.

PERSONAJE: Mascarada. Villano teatral y caótico que cambia de "personaje" en cada fase de pelea.
Diseño propio: SIN maquillaje de payaso, SIN pelo verde, SIN traje violeta, SIN sonrisa pintada.

SILUETA: saco largo de teatro con cola, sombrero de copa torcido, una máscara distinta por fase.

PIEZAS:
1. Sombrero de copa torcido (Head) — 3.000 tris: negro con cinta cofradia (#c2213a).
2. Máscara 1 "Tragedia" (Head) — 3.000 tris: blanco-armadura, ceño triste, ojos neon-aviso.
3. Máscara 2 "Comedia" (Head) — 3.000 tris: blanco-armadura con grietas, sonrisa tallada, ojos neon-eclipse.
4. Máscara 3 "Ninguna" (Head) — 3.000 tris: espejo partido (acero, roughness 0,1) con grietas neon-aviso.
   Las 3 máscaras como objetos separados en el mismo lugar; solo una visible a la vez.
5. Saco de teatro (UpperTorso + LowerTorso) — 10.000 tris: tela cofradia oscura (#7a1424) con solapas
   negras, 6 botones de oro, cola larga partida en dos hasta las pantorrillas, pliegues horneados.
6. Chaleco y corbata de moño (UpperTorso) — 3.000 tris: chaleco negro a rayas finas, moño blanco.
7. Guantes blancos (Hands) — 2.000 tris el par.
8. Bastón con naipe gigante (RightHand) — 3.000 tris: bastón negro con punta de oro con forma de máscara.
9. Zapatos de charol (Feet) — 2.000 tris el par.
TOTAL ≤ 35.000 tris. Colores: 50 % negro, 35 % cofradia, 15 % blanco-armadura, oro y neon.

PASO 1: boceto, 3 vistas con la máscara 1, esperá mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + un render por máscara. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/mascarada/, script en scripts/personajes/mascarada.py,
commit "Linajes: traje de Mascarada" y push.
```

#### Prompt 6 💻 Remache (DC de trabajo: Bane) · Cofradía · jefe del Acto 1
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/remache.blend.

PERSONAJE: Remache. Matón enorme del puerto con implantes hidráulicos robados de Corona Corp.
Diseño propio: SIN máscara de luchador, SIN tubos en la cabeza, SIN tanque de "veneno" en la espalda.
ESCALA: el maniquí escalado a 1,6x (es un jefe grande). Las piezas se hacen para ese tamaño.

SILUETA: torso enorme en forma de V, brazos gigantes de pistones, cabeza chica con casco de soldador.

PIEZAS:
1. Casco de soldador (Head) — 5.000 tris: acero oxidado (#6e4a35 mezclado con acero), visor rectangular
   neon-aviso (#ff2a2a), remaches en el borde.
2. Arnés de implantes (UpperTorso) — 9.000 tris: placas de acero sobre musculosa de cuero, columna
   mecánica en la espalda de 6 vértebras con luces neon-cian, 2 tubos con líquido rojo (#c2213a, emission 2)
   que van de la espalda a los hombros.
3. Brazos hidráulicos (UpperArms + LowerArms) — 12.000 tris el par: 2 pistones por brazo (cilindros de
   acero que se van a animar), mangueras negras, codo con engranaje.
4. Puños-martillo (Hands) — 5.000 tris el par: bloques de acero con 4 remaches grandes en los nudillos.
5. Pantalón de trabajo y botas con punta de acero (Legs + Feet) — 6.000 tris.
TOTAL ≤ 37.000 tris. Colores: 50 % acero oxidado, 30 % cuero oscuro, 20 % cofradia y neon.

PASO 1: boceto, 3 vistas al lado del maniquí normal (para ver el tamaño), esperá mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + primeros planos de brazo hidráulico y columna. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/remache/, script en scripts/personajes/remache.py,
commit "Linajes: traje de Remache" y push.
```

#### Prompts 7 a 18 💻 El resto de los personajes (mismo formato, ya completos)
Cada uno se pega igual que los de arriba (PASO 2 siempre con el NIVEL DE DETALLE OBLIGATORIO): el encabezado con `Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/<archivo>.blend.`, después esta ficha, y al final los mismos **PASO 1, 2 y 3** (boceto → detalle → exportar a `exports/<archivo>/`, script en `scripts/personajes/<archivo>.py`, commit y push).

**Prompt 7 · Estela** (DC de trabajo: Flash) · Liga · archivo `estela`
```
PERSONAJE: Estela. Velocista: el rayo del eclipse le dio velocidad. Diseño propio: SIN rojo, SIN rayo en el
pecho ni en las orejas, SIN alas en la cabeza.
SILUETA: traje ajustado y aerodinámico, visor alargado hacia atrás, líneas de luz que recorren el cuerpo.
PIEZAS:
1. Casco con visor (Head) — 7.000 tris: violeta oscuro (#3d2a6b), visor cian translúcido que se alarga 0,5
   studs hacia atrás, aletas finas en las sienes.
2. Traje ajustado (Torso + brazos + piernas, una pieza por parte del cuerpo) — 14.000 tris total:
   violeta (#5a3fa0) con placas finas en pecho, hombros y muslos; LÍNEAS DE LUZ neon-cian de 0,05 studs
   que bajan por los costados, brazos y piernas como circuitos.
3. EMBLEMA PROPIO en el pecho — 1.000 tris: tres líneas paralelas inclinadas (estela de velocidad)
   neon-cian sobre un rombo violeta claro.
4. Guantes y botas aerodinámicos (Hands + Feet) — 6.000 tris: suela gruesa con 3 ranuras neon-cian.
5. Mochila-condensador chica (UpperTorso, espalda) — 3.000 tris: acero con anillo neon-cian.
TOTAL ≤ 31.000 tris. Colores: 70 % violetas, 20 % acero, 10 % neon-cian.
Primeros planos del PASO 2: casco, emblema, botas.
```

**Prompt 8 · Atalanta** (DC de trabajo: Wonder Woman) · Liga · archivo `atalanta`
```
PERSONAJE: Atalanta. Guerrera de las Hespérides, isla griega oculta. Diseño propio: SIN tiara con
estrella, SIN lazo, SIN águila ni "W", SIN combinación rojo-azul-dorado de bustier.
SILUETA: armadura griega de hoplita, escudo redondo grande, lanza más alta que ella.
PIEZAS:
1. Casco corintio abierto (Head) — 7.000 tris: bronce con cresta de crin azul liga (#2f6fdb) de punta a nuca.
2. Coraza musculada (UpperTorso + LowerTorso) — 8.000 tris: bronce con grabado de ramas de olivo; falda de
   tiras de cuero (pteruges) en 2 filas.
3. Capa corta (UpperTorso) — 4.000 tris: azul liga hasta la cintura, prendida con 2 broches de oro.
4. Brazaletes (LowerArms) — 2.000 tris el par: bronce con meandro griego.
5. Grebas y sandalias (LowerLegs + Feet) — 4.000 tris el par: bronce.
6. Escudo redondo (LeftHand) — 5.000 tris: 1,8 studs de diámetro, bronce con EMBLEMA PROPIO: una manzana
   dorada con una hoja (las Hespérides) en relieve, borde de oro.
7. Lanza (RightHand) — 2.000 tris: 6 studs de largo, asta de madera oscura, punta de bronce en hoja de laurel.
TOTAL ≤ 32.000 tris. Colores: 60 % bronce, 20 % cuero, 20 % liga y oro.
Primeros planos: casco, escudo, punta de lanza.
```

**Prompt 9 · Arquitecto** (DC de trabajo: Green Lantern) · Liga · archivo `arquitecto`
```
PERSONAJE: Arquitecto. Ingeniero que se fabricó un guantelete que convierte luz en objetos sólidos.
Diseño propio: SIN anillo, SIN verde, SIN linterna, SIN juramento, SIN cuerpo de policía espacial.
SILUETA: traje de obrero espacial con casco de visera, un guantelete enorme en el brazo derecho.
PIEZAS:
1. Casco con visera rebatible (Head) — 6.000 tris: blanco-armadura con franja liga, visera neon-cian.
2. Mameluco técnico (Torso + piernas) — 9.000 tris: gris (#5a606e) con bolsillos, rodilleras, arnés de
   herramientas en la cintura con 4 herramientas chicas.
3. GUANTELETE (RightLowerArm + RightHand) — 9.000 tris: acero, 3 veces más grueso que el brazo, 5 placas
   que se abren (se animan), núcleo prismático neon-cian en el dorso, cables que van al hombro.
4. Guante izquierdo simple (LeftHand) — 1.000 tris.
5. Mochila-generador (UpperTorso, espalda) — 4.000 tris: caja de acero con 2 aletas de disipación y luces cian.
6. EMBLEMA PROPIO en el hombro — 500 tris: un cubo de líneas (estructura de alambre) neon-cian.
7. Botas de obra (Feet) — 2.500 tris el par.
TOTAL ≤ 32.000 tris. Colores: 50 % gris, 30 % acero, 20 % neon-cian y liga.
Primeros planos: guantelete abierto y cerrado, casco, mochila.
```

**Prompt 10 · Bastión** (DC de trabajo: Cyborg) · Liga · archivo `bastion`
```
PERSONAJE: Bastión. Ex guardia de seguridad reconstruido con implantes después del eclipse.
Diseño propio: SIN ojo rojo único, SIN el patrón de placas plateadas de Cyborg; mitad máquina asimétrica.
SILUETA: lado izquierdo humano con ropa táctica, lado derecho todo de placas con un cañón en el brazo.
PIEZAS:
1. Media cabeza de placas (Head) — 6.000 tris: lado derecho de acero con 3 lentes neon-cian en triángulo.
2. Torso mitad placas (UpperTorso + LowerTorso) — 9.000 tris: lado derecho placas de acero con
   rejillas neon-cian; lado izquierdo chaleco táctico liga con bolsillos.
3. Brazo-cañón derecho (RightUpperArm + RightLowerArm + RightHand) — 9.000 tris: cilindro de 3 anillos que
   se separan (se anima), boca con neon-cian.
4. Brazo izquierdo con guante táctico (LeftArm) — 3.000 tris.
5. Pierna derecha mecánica y bota (RightLeg + RightFoot) — 5.000 tris: pistones visibles.
6. Pierna izquierda pantalón táctico y bota (LeftLeg + LeftFoot) — 3.000 tris.
7. EMBLEMA PROPIO en el chaleco — 500 tris: escudo de muralla (una torre) en liga.
TOTAL ≤ 36.000 tris. Colores: 45 % acero, 35 % tela táctica oscura, 20 % liga y neon-cian.
Primeros planos: cabeza, cañón abierto, pierna mecánica.
```

**Prompt 11 · Heredero Abisal** (DC de trabajo: Aquaman) · Liga · archivo `heredero`
```
PERSONAJE: Heredero Abisal. Príncipe de la Ciudad Hundida bajo Puerto Óxido. Controla presión y corrientes.
Diseño propio: SIN escamas naranjas, SIN pantalón verde, SIN tridente de 3 puntas (usa arpón de 2 puntas).
SILUETA: armadura de coral oscuro con aletas en antebrazos, pelo largo atado, arpón doble.
PIEZAS:
1. Corona de coral (Head) — 4.000 tris: coral negro-azulado (#1f3a4a) con puntas y bioluminiscencia
   neon-cian en las puntas.
2. Coraza de escamas (Torso) — 10.000 tris: escamas superpuestas azul petróleo (#22505e, roughness 0,3)
   con placas de coral en hombros.
3. Aletas de antebrazo (LowerArms) — 4.000 tris el par: membrana translúcida con nervaduras.
4. Cinturón de conchas (LowerTorso) — 2.000 tris.
5. Grebas de coral y pies descalzos con aletas cortas (Legs + Feet) — 5.000 tris.
6. Arpón de dos puntas (RightHand) — 3.000 tris: 5 studs, asta de hueso, dos puntas de coral negro.
7. EMBLEMA PROPIO en el cinturón — 500 tris: una ola encerrada en un círculo.
TOTAL ≤ 29.000 tris. Colores: 60 % azul petróleo, 30 % coral oscuro, 10 % neon-cian.
Primeros planos: corona, aleta, arpón.
```

**Prompt 12 · Víctor Halden** (DC de trabajo: Lex Luthor) · Cofradía · archivo `halden`
```
PERSONAJE: Víctor Halden. Dueño de Corona Corp, vende implantes ilegales. Dos versiones del mismo
personaje: traje de empresario (NPC) y exoarmadura (jefe). Diseño propio: SIN armadura verde y violeta
de Luthor; la exoarmadura es negra y dorada con líneas cofradia.
PIEZAS VERSIÓN EMPRESARIO (≤ 15.000 tris): traje de tres piezas gris grafito, corbata cofradia, anteojos
finos de oro, reloj, bastón con mango de sol (logo de Corona Corp: una corona de 5 puntas sobre un anillo).
PIEZAS VERSIÓN EXOARMADURA (escala 1,3x, ≤ 38.000 tris):
1. Casco cerrado (Head) — 7.000 tris: negro brillante con visor horizontal de oro.
2. Torso blindado (Torso) — 10.000 tris: placas negras con bordes de oro, reactor en el pecho con la corona
   de Corona Corp en neon-eclipse.
3. Brazos con lanzamisiles en los antebrazos (Arms) — 10.000 tris: 4 tubos por brazo que se abren.
4. Piernas con propulsores en los tobillos (Legs + Feet) — 8.000 tris.
5. Capa corta de placas (espalda) — 3.000 tris.
Primeros planos: casco, reactor, lanzamisiles abiertos. Renderizá las dos versiones lado a lado.
```

**Prompt 13 · El Albatros** (DC de trabajo: Pingüino) · Cofradía · archivo `albatros`
```
PERSONAJE: El Albatros. Jefe mafioso de Puerto Óxido, dueño del contrabando. Diseño propio: SIN smoking con
frac, SIN monóculo, SIN paraguas, SIN nariz ganchuda.
SILUETA: bajo y ancho, abrigo largo de capitán de barco, bastón-arpón, gorra de capitán.
PIEZAS:
1. Gorra de capitán (Head) — 3.000 tris: azul marino oscuro con ancla de oro.
2. Abrigo de capitán (Torso + hasta las pantorrillas) — 11.000 tris: azul marino #1c2433 con cuello de
   piel gris, 2 filas de botones de oro, charreteras con flecos.
3. Bufanda blanca (Head/UpperTorso) — 2.000 tris.
4. Bastón-arpón (RightHand) — 3.000 tris: madera con punta de arpón de acero y cadena enrollada.
5. Guantes de cuero y botas de marinero (Hands + Feet) — 4.000 tris.
6. EMBLEMA PROPIO en la gorra y el abrigo — 500 tris: un albatros con alas abiertas en oro.
Escala del maniquí 0,9x de alto y 1,2x de ancho. TOTAL ≤ 24.000 tris.
Primeros planos: gorra, bastón-arpón, emblema.
```

**Prompt 14 · Zarpa** (DC de trabajo: Catwoman) · Neutral · archivo `zarpa`
```
PERSONAJE: Zarpa. Ladrona que trabaja para quien pague más. Diseño propio: SIN orejas de gato, SIN látigo,
SIN traje de cuero negro brillante entero.
SILUETA: ladrona ágil con capucha corta, antiparras grandes, garras retráctiles en los guantes.
PIEZAS:
1. Capucha corta y antiparras (Head) — 6.000 tris: capucha gris neutral, antiparras de 2 lentes redondas
   ámbar (#f2a23a, emission 1) con correa.
2. Chaqueta corta con bufanda (UpperTorso) — 7.000 tris: gris oscuro con parches, bufanda larga que flota.
3. Guantes con garras (Hands) — 4.000 tris el par: 4 garras de acero retráctiles (se animan).
4. Pantalón con rodilleras y riñonera de herramientas de ladrón (LowerTorso + Legs) — 6.000 tris.
5. Botas silenciosas (Feet) — 2.000 tris el par.
6. EMBLEMA PROPIO en la riñonera — 500 tris: tres arañazos paralelos.
TOTAL ≤ 26.000 tris. Primeros planos: antiparras, garras afuera, bufanda.
```

**Prompt 15 · Confeti** (DC de trabajo: Harley Quinn) · Cofradía · archivo `confeti`
```
PERSONAJE: Confeti. Acróbata de feria que se unió a Mascarada. Diseño propio: SIN rombos rojo y negro,
SIN coletas bicolores, SIN bate de béisbol, SIN gorro de bufón.
SILUETA: acróbata con chaqueta de feria, mazo enorme de resorte, rodete alto.
PIEZAS:
1. Pelo en rodete alto con cintas (Head) — 4.000 tris: rubio con cintas turquesa y rosa.
2. Chaqueta de domadora de circo (UpperTorso) — 7.000 tris: turquesa (#2bb3a6) y rosa (#e05a8a) con
   botones dorados y hombreras con flecos.
3. Short y medias rayadas horizontales (LowerTorso + Legs) — 5.000 tris.
4. Mazo de resorte (RightHand) — 6.000 tris: mango largo, cabeza de mazo de feria con un resorte gigante
   entre mango y cabeza (se anima), pintado con estrellas.
5. Botas de acróbata (Feet) — 2.000 tris.
6. EMBLEMA PROPIO en la chaqueta — 500 tris: un confeti de 5 papelitos en estrella.
TOTAL ≤ 25.000 tris. Primeros planos: mazo, rodete, chaqueta.
```

**Prompt 16 · Dualidad** (DC de trabajo: Dos Caras) · Cofradía · archivo `dualidad`
```
PERSONAJE: Dualidad. Ex fiscal partido por un experimento del eclipse: cada mitad es de un material.
Diseño propio: SIN cara quemada, SIN moneda, SIN traje blanco y negro mitad y mitad clásico.
SILUETA: traje partido en vertical: mitad izquierda traje de fiscal azul marino, mitad derecha cristal
oscuro facetado con grietas de luz.
PIEZAS:
1. Cabeza (Head) — 5.000 tris: mitad izquierda pelo peinado, mitad derecha facetas de cristal negro
   (#1a1530, roughness 0,1) con grietas neon-eclipse.
2. Traje partido (Torso + brazos + piernas) — 15.000 tris: mitad tela azul marino, mitad cristal facetado.
3. Dado de dos caras (LeftHand) — 1.500 tris: un octaedro de cristal con un ojo grabado en cada mitad.
4. Zapatos (Feet) — 2.000 tris: uno de cuero, uno de cristal.
TOTAL ≤ 24.000 tris. Primeros planos: cara de frente, dado, línea de corte en el pecho.
```

**Prompt 17 · Gorrión** (DC de trabajo: Robin) · Vigilantes · archivo `gorrion`
```
PERSONAJE: Gorrión. Aprendiz de Cuervo, chico de la calle. Diseño propio: SIN "R" en el pecho, SIN capa
amarilla, SIN traje rojo-verde.
SILUETA: ágil, capa corta de plumas pardas, antifaz, boleadoras en el cinturón.
PIEZAS:
1. Antifaz y capucha corta (Head) — 4.000 tris: antifaz de acero oscuro, ojos neon-cian.
2. Chaqueta de plumas pardas (#7a5a3a) con capa corta (UpperTorso) — 8.000 tris.
3. Pantalón con rodilleras y cinturón con boleadoras (LowerTorso + Legs) — 5.000 tris: 3 bolas de acero
   unidas con cuerdas.
4. Guantes sin dedos y zapatillas (Hands + Feet) — 3.000 tris.
5. EMBLEMA PROPIO — 500 tris: una pluma chica de gorrión en vigilantes.
TOTAL ≤ 21.000 tris. Primeros planos: antifaz, boleadoras, capa.
```

**Prompt 18 · El Eclipsador** (DC de trabajo: Darkseid) · jefe final · archivo `eclipsador`
```
PERSONAJE: El Eclipsador. Tirano de Umbra, causó el eclipse. MODELO COMPLETO CON RIG PROPIO (no es un
traje sobre el maniquí). Diseño propio: SIN cara de piedra gris con ojos rojos de Darkseid, SIN falda
azul, SIN "rayos omega" rojos (sus rayos son negros con borde naranja).
ESCALA: 3x el maniquí (≈ 15 studs de alto).
SILUETA: gigante de roca negra volcánica con un eclipse ardiendo en el pecho y una corona de rayos negros.
PIEZAS (cada malla ≤ 20.000 tris, total ≤ 60.000):
1. Cabeza y corona (≤ 12.000): cráneo de roca negra (#15141a) facetada, sin boca visible, 2 ojos neon-eclipse,
   corona de 7 rayos de obsidiana con borde corona (#ffb347).
2. Torso (≤ 18.000): roca con grietas de lava naranja, en el centro un EMBLEMA PROPIO: disco negro con aro
   neon-eclipse (un eclipse), 1,5 studs, que late.
3. Brazos (≤ 14.000 los dos): roca con placas de obsidiana, manos de 4 dedos con garras.
4. Piernas (≤ 12.000 las dos): columnas de roca, pies anchos.
5. Manto de humo sólido (≤ 4.000): tiras de tela negra rígida que caen de los hombros.
RIG: esqueleto propio compatible con Animation Editor de Roblox (raíz HumanoidRootPart, 15 huesos con los
mismos nombres que R15). Pesos limpios en codos, rodillas y cuello.
PASO 1: boceto de bloques al lado del maniquí, esperá mi OK. PASO 2: detalle + 3 vistas + primeros planos
de cara, eclipse del pecho y manos. Probá el rig doblando brazos y piernas en un render. Esperá mi OK.
PASO 3: exportá con el rig a linajes/arte/exports/eclipsador/, commit y push.
```

#### Prompt 19 💻 NPCs (uno por sesión, mismo formato)
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/npc-[archivo].blend.
Modelá la ropa de este NPC sobre el maniquí R15 (es civil, no superhéroe), 12.000 a 20.000 tris total,
cada malla ≤ 20.000, un material por malla. PASO 1 boceto → mi OK → PASO 2 detalle + 3 vistas → mi OK →
PASO 3 exportar a linajes/arte/exports/npc-[archivo]/, script en scripts/npcs/[archivo].py, commit y push.
NPC: [pegá una fila de la tabla]
```
| Archivo | NPC (DC de trabajo → final) | Ropa y detalles |
|---|---|---|
| rivas | Gordon → Comisaria Rivas | Gabardina beige larga, camisa celeste, placa de policía de oro en el cinturón, anteojos rectangulares, pelo canoso corto, radio en el hombro |
| vega | Lois Lane → Lucía Vega | Saco rojo ladrillo, camisa blanca, credencial de El Faro colgada, cámara de fotos al cuello, libreta en la mano |
| tano | Alfred → Tano | Mameluco azul engrasado, delantal de cuero, trapo en el bolsillo, gorra, bigote canoso, llave inglesa |
| okafor | Lucius Fox → Ingeniera Okafor | Guardapolvo blanco largo con logo de Corona Corp, anteojos de seguridad en la frente, tablet, guantes de laboratorio |
| kessler | (propio) → Dra. Kessler | Delantal quirúrgico verde oscuro manchado, lupa de joyero en un ojo, brazo izquierdo con implante de acero, barbijo bajado |
| brandt | Amanda Waller → Directora Brandt | Traje sastre negro, auricular, carpeta con sello de agencia (ojo dentro de un triángulo invertido), pelo corto |
| senal | Oráculo → Señal | Campera de jean con parches, auriculares grandes, micrófono, rodeada de 3 pantallas chicas (props aparte) |

#### Prompt 20 💻 Enemigos comunes (uno por sesión)
```
Leé linajes/arte/GUIA-ESTILO.md. Guardá kit-base.blend como linajes/arte/blender/enemigo-[archivo].blend.
Modelá este enemigo sobre el maniquí R15 (o con rig propio si no es humano), [TRIS] tris total,
3 VARIANTES de color (cambiá solo materiales, no mallas). Boceto → mi OK → detalle + 3 vistas de cada
variante → mi OK → exportar a linajes/arte/exports/enemigo-[archivo]/, commit y push.
ENEMIGO: [pegá una fila]
```
| Archivo | Enemigo | Tris | Detalles y variantes |
|---|---|---|---|
| maton | Matón del puerto | 8.000 | Campera de cuero, gorro de lana, pañuelo en la cara, cadena. Variantes: gorro rojo, verde, gris |
| maton-implantes | Matón con implantes | 10.000 | Igual que el matón + brazo de acero con pistón y ojo neon-aviso. Variantes por color del brazo |
| dron | Dron de seguridad Corona | 6.000 | Esfera de 1,5 studs blanca con 4 hélices en anillo, ojo neon-cian, logo de Corona Corp. Rig propio (hélices giran) |
| robot | Robot centinela Corona | 10.000 | Humanoide de 7 studs blanco y oro, cabeza de visor, escudo en el brazo izquierdo. Rig R15 escalado |
| preso | Preso fugado | 8.000 | Mameluco naranja apagado con número, esposas rotas, pelo rapado. Variantes: con casco de guardia robado, con barra de hierro, sin nada |
| soldado-umbra | Soldado de Umbra | 10.000 | Armadura de obsidiana con grietas naranjas, casco sin cara, lanza negra |
| criatura | Criatura abisal | 10.000 | Cuadrúpedo de 4 studs, piel petróleo con escamas, boca de anguila con luces cian. Rig propio de 4 patas |

---

#### Prompt 20b 💻 Piezas del creador de personaje (para los jugadores)
```
Leé linajes/arte/GUIA-ESTILO.md y la sección 0c de linajes/ideas/ficha.md. Los personajes principales son NPCs:
los jugadores se arman SU PROPIO héroe con piezas que se mezclan. Guardá kit-base.blend como
linajes/arte/blender/creador.blend.
Modelá, sobre el maniquí R15, piezas genéricas (no copias de ningún personaje) que encajen entre sí:
- 8 cascos/máscaras (≤ 6.000 tris c/u): antifaz, capucha, casco cerrado con visor, casco abierto con cresta,
  máscara de placas, gorra con antiparras, yelmo con cuernos cortos, media máscara de respirador.
- 8 capas (≤ 6.000): corta, larga, partida en 2, en tiras, con cuello alto, bufanda larga, gabardina, ninguna (solo cuello).
- 8 petos (≤ 7.000): tela simple, placas, chaleco táctico, armadura ligera, traje ajustado con líneas,
  cota de escamas, chaqueta de cuero, uniforme con cinturón cruzado.
- 6 hombreras, 6 guantes, 6 botas (≤ 3.000 el par).
REGLAS: cada pieza con 3 canales de color (3 materiales separados llamados Color1, Color2, Color3, para
cambiarlos por código) y un hueco plano de 0,6 studs en el pecho del peto y en la capa para el emblema.
Todas tienen que verse bien combinadas con cualquiera de las otras.
PASO 1: bocetos de todas en una grilla, mi OK. PASO 2: detalle y 6 combinaciones de ejemplo armadas,
mi OK. PASO 3: exportá a linajes/arte/exports/creador/<tipo>/<pieza>.fbx. Además, 20 formas de emblema en
2D (SVG simple, una sola tinta) en linajes/arte/emblemas/. Commit y push.
```

---

### Fase D. Lugares en Blender (kits modulares)

#### Prompt 21 💻 Puerto Óxido (primer lugar del juego)
```
Leé linajes/arte/GUIA-ESTILO.md. Mirá en linajes/arte/referencias/ las capturas de mundo de Bloodlines
(155302 a 155744: niebla, piedra, óxido) y la de ciudad de noche (160028). Guardá kit-base.blend como
linajes/arte/blender/puerto-oxido.blend. Usá ciudad.py y props.py.

KIT MODULAR (cada pieza encaja en una grilla de 8 studs):
1. Muelle de madera recto 8x8 (≤ 1.500 tris) y esquina (≤ 1.500): tablones con huecos, postes con soga.
2. Pared de galpón 8x12 de chapa ondulada oxidada (≤ 1.200) + versión con portón corredizo (≤ 2.000)
   + versión con ventanas rotas (≤ 2.000).
3. Techo de galpón a dos aguas 8x8 (≤ 1.000).
4. Calle de adoquines 8x8 (≤ 800) con charcos (material espejo suave) y versión con vías de tren (≤ 1.200).
5. Grúa portuaria gigante (≤ 18.000, en 2 mallas): estructura de vigas en X amarillo apagado (#a08a3a)
   y óxido, cabina, gancho con cadena.
6. Contenedores 4x4x10 (≤ 600 cada uno), 4 colores apagados (rojo óxido, azul petróleo, verde musgo, gris).
7. Props (≤ 500 cada uno): farola de puerto con luz naranja, bita de amarre, pila de cajones, barril,
   red de pesca colgada, cartel roto "PUERTO ÓXIDO" (texto en una textura aparte), bote volcado.
8. EDIFICIO IMPORTANTE: Galpón del Albatros (≤ 25.000 en 2 mallas): galpón doble con letrero neon de un
   albatros (cofradia), oficina en el piso de arriba con ventanal.
9. EDIFICIO IMPORTANTE: Barco del Albatros (≤ 30.000 en 2 mallas): carguero viejo de 60 studs de largo,
   casco oxidado, puente de mando, cubierta con contenedores (escenario del evento de 8 jugadores).

CLIMA: niebla verde-gris (#7f9a96), luz de luna fría, charcos que reflejan las farolas naranjas, lluvia
fina (partículas en Roblox, no en Blender).

PASO 1: bocetos de bloques de todas las piezas en una grilla + una calle armada de muestra. Mi OK.
PASO 2: detalle de todo, render de la calle de muestra con la luz de noche, tabla de tris. Mi OK.
PASO 3: exportá cada pieza a linajes/arte/exports/puerto-oxido/<pieza>.fbx, commit y push.
```

#### Prompts 22 a 25 💻 Los otros lugares (mismo formato que el 21)
| Prompt | Lugar (DC de trabajo) | Kit modular | Edificios importantes | Clima |
|---|---|---|---|---|
| 22 | Ciudad Vórtice (Gotham) | Fachadas de ladrillo de 3 a 6 pisos con escaleras de incendio, callejón con contenedores de basura y vapor, techos con tanques de agua y antenas, gárgolas de cuervo, calle con alcantarillas | Comisaría (≤ 30.000), Torre del reloj (≤ 30.000), azotea con reflector que proyecta una pluma (≤ 8.000) | Noche cerrada, lluvia, luna grande atrás, niebla baja violeta (#2a2440) |
| 23 | Distrito Corona (Metrópolis) | Rascacielos de vidrio modulares (bloques de 8 pisos apilables), vereda con senda peatonal, semáforos, líneas amarillas, árboles en canteros, paradas de colectivo | Torre Corona Corp (≤ 60.000 en 3 mallas, corona de 5 puntas arriba), edificio de El Faro con un faro de luz en la terraza (≤ 30.000), plaza central con fuente (≤ 10.000) | Día de sol con nubes, agua azul al costado, reflejos en los vidrios |
| 24 | Penal Islaroca (Arkham) | Muros de piedra con alambre, torres de guardia, celdas con rejas, pasillos con luces de emergencia | Bloque central de celdas (≤ 40.000), muelle del ferry (≤ 10.000) | Noche de tormenta, relámpagos, mar picado |
| 25 | Bases de bando | — | El Nido (Batcueva → cueva bajo la torre del reloj con computadora gigante y perchas de cuervos), Faro Orbital (Atalaya → estación con ventanal a la Tierra), La Fundición (Salón del Mal → fundición abandonada con lava y trono) | Interior, luces del color del bando |

---

### Fase E. Animaciones (las hace Claude en Blender)

**Cómo se hacen:** Claude anima en Blender sobre el esqueleto R15 del maniquí (o el rig propio del jefe), a **30 cuadros por segundo**, con un script por animación en `linajes/arte/scripts/animaciones/`. Exporta FBX a `linajes/arte/animaciones/`. Después, en Studio: **Animation Editor → ⋯ → Import → From FBX Animation**, y **Publish to Roblox**. Ese último botón lo tenés que tocar vos (Roblox lo pide desde tu cuenta); Claude te dice cuál en cada caso y anota los IDs en `Config.luau`.

**Reglas de todas las animaciones:**
- Exageradas, estilo cómic: anticipación (se carga hacia atrás), golpe rápido, pausa corta en el final del golpe, recuperación.
- Las que se repiten (quieto, caminar, correr) terminan igual que empiezan (loop perfecto).
- Prioridades de Roblox: quieto/caminar/correr = Core; combate = Action; definitiva = Action4.
- Cada golpe marca el **cuadro de impacto** con un marcador (Animation Event) llamado `Impacto`, para que el código haga el daño justo ahí.

#### Prompt 26 💻 Animaciones base del jugador (las usan todos)
```
Leé linajes/arte/GUIA-ESTILO.md. Abrí linajes/arte/blender/kit-base.blend y guardalo como
linajes/arte/blender/animaciones-base.blend. Animá el esqueleto R15 del maniquí a 30 fps.
Cada animación es una Action separada, con su script en linajes/arte/scripts/animaciones/base.py.

LOCOMOCIÓN (loops):
1. Quieto (60 cuadros): respiración lenta, hombros suben 0,03 studs, peso en una pierna, mira a los costados
   una vez.
2. Caminar (32 cuadros): paso firme, brazos opuestos a las piernas, leve balanceo del torso.
3. Correr (20 cuadros): torso inclinado 15° hacia adelante, brazos doblados a 90°, rodillas altas.
4. Correr rápido / velocista (14 cuadros): torso a 30°, brazos hacia atrás rectos.
5. Saltar (inicio 8 + aire loop 20 + caer 10): se agacha, se estira, rodillas arriba en el aire, amortigua.
6. Trepar (24 cuadros, loop) para paredes con gancho.
7. Volar quieto (60, loop) y volar avanzando (30, loop): cuerpo horizontal, un brazo adelante.

COMBATE (no loop, marcador Impacto donde se indica):
8. Combo golpe 1 (14 cuadros): jab derecho. Anticipación 0-4, Impacto en 6, recuperación 7-14.
9. Combo golpe 2 (14): cross izquierdo. Impacto en 6.
10. Combo golpe 3 (18): gancho ascendente derecho. Impacto en 8.
11. Combo golpe 4 (24): patada giratoria que empuja. Anticipación 0-8, Impacto en 12, cae en guardia.
12. Bloqueo (inicio 4 + loop 30): antebrazos cruzados delante de la cara, rodillas flexionadas.
13. Parry (12): golpe seco con el antebrazo hacia afuera, Impacto en 3, queda abierto y seguro.
14. Dash adelante / atrás / izquierda / derecha (8 cada uno): cuerpo inclinado en la dirección, sin pasos.
15. Recibir golpe liviano (10) y fuerte (18, retrocede 2 studs).
16. Aturdido (loop 40): tambalea, cabeza gira.
17. Derrota (40): cae de rodillas y después de costado. Levantarse (30).

INTERACCIÓN:
18. Hablar con NPC (loop 60): gestos de manos suaves. 19. Recoger del piso (20). 20. Abrir menú de taller (24).
21. Celebrar (40): puño arriba. 22. Saludo (30).

Para cada animación: render de 3 cuadros clave en una tira (linajes/arte/renders/anim-<nombre>.png).
Mostrame una hoja con todas las tiras y esperá mi OK. Con mi OK: exportá cada Action a
linajes/arte/animaciones/base/<nombre>.fbx, importalas en Studio sobre un Dummy R15 y decime exactamente
qué tengo que tocar para publicarlas. Anotá los IDs en Config.luau. Commit y push.
```

#### Prompt 27 💻 Animaciones de los 3 primeros Linajes
```
Abrí animaciones-base.blend y guardalo como linajes/arte/blender/animaciones-linajes-1.blend.
30 fps, marcador Impacto en cada golpe, script en linajes/arte/scripts/animaciones/linajes.py.

FUERZA BRUTA (común):
- Z "Pisotón" (30): levanta la rodilla alto (0-10), pisa fuerte (Impacto 14), onda de choque, se recupera.
- X "Embestida" (24): agacha el hombro y carga 12 studs hacia adelante (Impacto 10 al chocar).
- C "Levantar y tirar" (40): agarra (Impacto 8), levanta sobre la cabeza (8-24), lanza (Impacto 28).
REFLEJOS (común):
- Z "Ráfaga" (20): 3 golpes rapidísimos alternados (Impactos 4, 9, 14).
- X "Contraataque" (16 + 20): pose de espera; si lo golpean, gira y patea (Impacto 8 de la segunda parte).
- C "Paso sombra" (18): desaparece hacia un costado (dash largo) y patea por detrás (Impacto 14).
PIROQUINESIS (común):
- Z "Bola de fuego" (22): junta las manos en la cadera (0-10), empuja hacia adelante (Impacto 12).
- X "Muro de fuego" (30): barre el brazo de izquierda a derecha a ras del piso (Impacto 16).
- C "Explosión" (40): brazos cruzados (0-14), los abre de golpe hacia los costados (Impacto 18).
DEFINITIVA genérica (V, después del Despertar) (60): se eleva 1 stud, energía se carga (0-30), descarga
con los brazos abiertos (Impacto 36), aterriza.

Mismo cierre que el Prompt 26: tiras de cuadros → mi OK → exportar a linajes/arte/animaciones/linajes/ →
importar en Studio → decime qué publicar → IDs en Config.luau → commit y push.
```
Para cada Linaje nuevo (Electro, Criogenia, Telequinesis, Velocista Cinético, Sombra Viva, Sangre Abisal, Origen Estelar, Herencia Olímpica, Eclipse) se usa el mismo prompt cambiando el bloque: **3 habilidades (Z, X, C), cada una con cuadros de anticipación, Impacto y recuperación, y qué hace el cuerpo**.

#### Prompt 28 💻 Animaciones de un jefe (uno por jefe)
```
Abrí linajes/arte/blender/[jefe].blend. Animá su esqueleto a 30 fps, marcador Impacto en cada golpe y
marcador Aviso [N] cuadros antes de cada Impacto (es cuando el piso se pone rojo, 0,4 s = 12 cuadros).
Script en linajes/arte/scripts/animaciones/[jefe].py.
ANIMACIONES: quieto amenazante (loop 60), caminar pesado (loop 40), entrada (90, presentación del jefe),
3 ataques (abajo), recibir golpe fuerte (20), aturdido (loop 40), cambio de fase (60), derrota (90).
ATAQUES DE [JEFE]: [pegá la fila de la tabla]
Cierre igual que el Prompt 26.
```
| Jefe | Ataque 1 | Ataque 2 | Ataque 3 | Cambio de fase |
|---|---|---|---|---|
| Remache | Martillazo doble: levanta los dos puños (Aviso), golpea el piso, círculo de 10 studs (Impacto 30) | Carga hidráulica: los pistones se cargan, embiste en línea recta 30 studs | Tira un contenedor: lo levanta (40 cuadros), lo lanza a una zona marcada | Los tubos rojos se rompen, se pone más rápido y los pistones echan vapor |
| El Albatros | Arponazo: tira el arpón en línea recta y tira de la cadena hacia él | Barrido con el bastón en círculo de 6 studs | Llama a 3 matones con un silbido | Se sube a la grúa y tira barriles |
| Mascarada | Fase 1 Tragedia: lanza 3 naipes en abanico | Fase 2 Comedia: se ríe, se duplica en 3 copias (una es real) | Fase 3 Ninguna: explota la máscara-espejo, rayos en cruz por el piso | Cambia de máscara girando el sombrero (por eso cada fase tiene su animación de cambio) |
| Víctor Halden (exoarmadura) | Lluvia de misiles a 6 zonas marcadas | Puñetazo propulsado: vuela hasta un jugador | Escudo del reactor: se cubre y descarga una onda | Se saca la capa y los propulsores quedan siempre prendidos |
| El Eclipsador | Rayos negros desde los ojos que barren el piso | Puño gigante al piso, onda en anillo | Abre el eclipse del pecho: atrae a todos al centro | Crece y la corona se prende fuego (fase final) |

#### Prompt 29 💻 Animaciones de NPCs y enemigos
```
Abrí animaciones-base.blend y guardalo como animaciones-npcs.blend. A 30 fps, sobre el esqueleto R15:
NPCs (loops de 60 a 120 cuadros): Rivas toma café y mira papeles; Vega saca fotos; Tano ajusta algo con
la llave inglesa; Okafor toca la tablet; Kessler limpia una herramienta; Brandt habla por el auricular;
Señal teclea y mira pantallas. Cada uno además: "saludar al jugador" (30) y "hablar" (loop 60).
ENEMIGOS: matón (quieto, perseguir, 2 golpes con Impacto y Aviso, recibir golpe, derrota),
dron (flotar loop, disparar), robot centinela (caminar pesado, escudo, golpe), criatura abisal (gatear,
saltar y morder). Cierre igual que el Prompt 26.
```

#### Prompt 30 💻 Animaciones de objetos (con código, no Blender)
```
En Studio, por código (TweenService o bucle en el cliente, un solo bucle para todo, pausado si no se ve):
- Corona solar de Centinela girando lento (1 vuelta cada 12 s).
- Pistones de Remache que se mueven en cada golpe.
- Placas del guantelete de Arquitecto que se abren al usar una habilidad.
- Anillos del cañón de Bastión que se separan al disparar.
- Garras de Zarpa que salen y entran.
- Resorte del mazo de Confeti que se estira.
- Hélices del dron.
- Objetos para juntar: girar y subir-bajar 0,3 studs con columna de luz.
- Ruleta de Linaje: giro que frena despacio y rebota en el resultado.
Probá cada una con Play. Commit y push.
```

---

### Fase F. Sonidos y música (ForgeGUI)

#### Prompt 31 💻 Sonidos de combate y menús
```
Con ForgeGUI generá estos efectos de sonido para Linajes del Eclipse. Estilo: superhéroe de cómic,
golpes con cuerpo y un toque metálico, nada caricaturesco. Nada que imite sonidos de DC.
Guardá cada uno en linajes/arte/sonidos/<nombre>.ogg y una tabla en linajes/arte/sonidos/LISTA.md
(nombre, duración, descripción).
COMBATE: golpe-1, golpe-2, golpe-3 (0,3 s cada uno, golpes secos de puño con eco corto, distintos),
golpe-4-patada (0,5 s, más grave con barrido), bloqueo (0,3 s, impacto apagado), parry (0,4 s, clank
metálico agudo con brillo), dash (0,3 s, whoosh), recibir-golpe (0,3 s), aturdido (1 s, zumbido),
derrota (1,2 s, caída pesada), aviso-jefe (0,4 s, alarma grave que crece).
LINAJES: por cada uno de Fuerza Bruta, Reflejos y Piroquinesis: Z, X y C con carga (0,3 a 0,8 s) y
disparo/impacto (0,4 a 1,2 s) según la animación (pisotón con temblor, embestida, lanzamiento;
ráfaga de 3 golpes, contraataque, paso sombra; bola de fuego, muro de fuego, explosión).
MENÚS: botón (0,1 s), abrir-menú (0,3 s), cerrar-menú (0,2 s), ruleta-girando (loop 2 s, clicks que se
frenan), resultado-comun, resultado-poco-comun, resultado-raro, resultado-epico, resultado-legendario,
resultado-mitico (1 a 3 s, cada uno más épico que el anterior), subir-nivel (1,5 s), punto-habilidad
(0,6 s), dialogo-npc (0,2 s, blip suave), mision-completa (1,5 s), recoger-objeto (0,3 s).
Después subilos a Roblox (decime si necesito tocar algo) y anotá los IDs en linajes/src/shared/Config.luau.
Commit y push.
```

#### Prompt 32 💻 Ambientes y música
```
Con ForgeGUI generá (nada que imite música de películas o juegos de DC):
AMBIENTES (loops de 60 s sin corte): ciudad-vortice-noche (lluvia, sirenas lejos, viento entre edificios),
puerto-oxido (olas contra el muelle, gaviotas, cadenas, bocina de barco lejos, niebla), distrito-corona-dia
(tráfico, gente, viento alto), penal-islaroca (tormenta, rejas, alarma lejana), umbra (zumbido grave,
fuego, viento).
MÚSICA (loops de 90 a 120 s): menu-principal (orquesta oscura épica, tambores lentos, coro grave),
exploracion-noche (sintetizadores oscuros con cuerdas, tranquila pero tensa), pelea (percusión rápida,
cuerdas en staccato, bronces), jefe-remache (industrial pesado, martillazos rítmicos), jefe-mascarada
(vals de circo oscuro que se distorsiona por fase), jefe-final (orquesta y coro a todo volumen),
victoria (fanfarria corta de 8 s).
Guardá en linajes/arte/sonidos/, agregá a LISTA.md, subilos y anotá los IDs. Commit y push.
```

---

### Fase G. Pantallas (las hace Claude en Studio)

#### Prompt 33 💻 HUD y menús
```
Leé linajes/arte/GUIA-ESTILO.md (colores y letras: títulos Saira Condensed, texto Barlow; en Roblox usá
las fuentes más parecidas disponibles en Font.new). Armá en Studio, para compu y celular (probá 1920x1080
y 844x390):
1. MENÚ PRINCIPAL: fondo #0e1016 con un eclipse grande atrás (disco negro con aro #f2652b y brillo #ffb347
   que late cada 4 s). Personaje al centro girando lento. "Espacio 1/2/3" con flechas. Datos: Nombre,
   Linaje (en el color de su rareza), Bando (en su color), Rango, Nivel. Botones a la izquierda: Jugar,
   Servidores, Códigos, Controles, Créditos.
2. RULETA DE LINAJE: lista a la derecha por rareza con su % (Común 55, Poco común 28, Raro 12,
   Legendario 4, Mítico 1), cada título en su color. Contador "Seguro: N/40". Botón "Tirar (1 ficha)".
   Animación de giro (Prompt 30) y sonido por rareza.
3. HUD DE PELEA: abajo al centro, barra de vida #d23a4a (derecha) y energía #2c7be5 (izquierda) con un
   rombo al centro con el emblema del bando; escudo #3fc1b0 arriba de la vida; nombre arriba; íconos de
   Z X C V con recarga (se oscurecen y cuentan segundos); G (gadget), Q (dash), F (bloqueo).
   En celular: botones redondos grandes abajo a la derecha (ataque el más grande).
   Aviso "Tenés N puntos de habilidad" arriba a la derecha, que se va solo a los 4 s.
4. ÁRBOL: 3 ramas (Poder, Cuerpo, Técnica) en columnas, nodos cuadrados con borde #8a94a6 apagados y
   #3fe0f0 encendidos, líneas entre nodos, descripción al pasar el mouse o tocar, botón "Desbloquear".
5. DIÁLOGO CON NPC: recuadro abajo, nombre del NPC en una pestaña arriba a la izquierda, texto con efecto
   máquina de escribir, hasta 4 respuestas en botones debajo, la última siempre "Adiós".
6. TRAJES: personaje girando sobre degradado de #0e1016 a #6b5ba8, flechas para cambiar de traje,
   nombre del traje arriba en título grande, botón "Ponerse" o "Bloqueado: cómo conseguirlo".
7. LISTA DE JUGADORES: arriba a la derecha, agrupada por bando con cabecera en su color (Liga, Cofradía,
   Vigilantes, Neutral), cada jugador con su rango debajo en chico.
Captura de cada pantalla en compu y celular. Mostramelas y esperá mi OK. Commit y push.
```

---

### Fase H. Código (después de los modelos y animaciones)

Todos empiezan con: `Leé linajes/ideas/ficha.md, linajes/arte/GUIA-ESTILO.md y GUIA-PARA-CLAUDE.md.` Todos terminan con: `Play por MCP, consola sin rojo, captura. Commit en español y push. Decime qué tengo que probar yo y cómo.`

#### Prompt 34 💻 Base y guardado
```
Copiá el guardado con ProfileStore del juego archivado más completo (ver archivo/README.md) y adaptalo.
DATOS por jugador: espacioActivo (1-3), fichasEclipse, seguroContador, compras (PurchaseIds entregados).
DATOS por espacio: nombre, nivel, xp, linaje, linajeSecundario, rareza, bando, rango, reputacion
{liga, cofradia, vigilantes}, reputacionNPC {rivas, vega, tano, okafor, kessler, brandt, senal},
trabajos {reportero, mecanico, patrullero, laboratorio, contrabandista} con nivel y xp,
puntosArbol, nodos[], despertar (0-2), implantes {brazo, ojos, columna}, cargaCibernetica,
tecnologia {traje: MkN, gadget: nombre y MkN}, trajes desbloqueados[], trajePuesto, fragmentos[],
misiones {activas, completas}, acto, dinero, chatarra, chips.
SchemaVersion 1. Autoguardado (ProfileStore), guardado al salir, en BindToClose y al recibir
ServerRestartScheduled. Si falla la carga, avisarle al jugador y no dejarlo jugar sin guardar.
Config.luau con TODOS los números de balance de los prompts siguientes.
Probá: entrar, cambiar cosas, salir, volver a entrar; y simular una falla de carga.
```

#### Prompt 35 💻 Combate
```
Usá el traje de Cuervo y las animaciones base (IDs en Config.luau).
NÚMEROS (en Config.luau): combo 4 golpes de 8, 8, 10 y 14 de daño; 0,35 s entre golpes; el combo se
corta si pasan 1,0 s; el golpe 4 empuja 6 studs. Bloqueo: reduce 80 % del daño, no podés atacar
mientras bloqueás. Parry: si bloqueás en los 0,2 s antes de un golpe, el atacante queda aturdido 1,2 s.
Dash: 14 studs en 0,25 s, recarga 2,5 s, invulnerable los primeros 0,15 s. Vida 100, energía 100,
energía vuelve 8 por segundo.
REGLAS: el cliente reproduce la animación y el sonido al instante; el SERVIDOR decide el golpe en el
marcador Impacto: hitbox con GetPartBoundsInBox de 5x5x6 studs delante del atacante, chequea distancia
(máx. 8 studs), recargas, energía, y un límite de 10 pedidos por segundo por jugador.
ENEMIGOS DE PRUEBA: un maniquí con vida infinita que muestra el número de daño flotando; un matón del
puerto (modelo + animaciones) con 120 de vida que te persigue a 14 studs/s, y antes de pegar muestra
flechas rojas #ff2a2a en el piso 0,4 s (marcador Aviso), pega 12.
CELULAR: botones del HUD del Prompt 33.
Si pelear no se siente bien, decime qué ajustarías antes de seguir.
```

#### Prompt 36 💻 Ruleta: Linaje, Variante y Rasgos
```
Leé la sección 0c de linajes/ideas/ficha.md. Conectá la ruleta del Prompt 33 al guardado.
TODO LO ALEATORIO LO TIRA EL SERVIDOR, nunca el cliente, y las probabilidades se ven siempre en pantalla.
1. LINAJE: Común 55, Poco común 28, Raro 12, Legendario 4, Mítico 1. Seguro: 40 tiradas sin Raro o mejor ⇒
   la siguiente es Raro o mejor. Fichas de Eclipse: 3 al empezar, 1 por nivel, 1 por misión, 3 por jefe.
2. VARIANTE: todos empiezan con la Variante Normal de su Linaje (NO hay ruleta de Variante).
   Las otras Variantes se consiguen por condiciones secretas (Prompt 37c).
3. RASGOS: NO se tiran. Salen de cómo jugás (Prompt 37c).
4. NADA DE EXPLICAR LO QUE CONLLEVA UNA ELECCIÓN: habilidades y Rasgos nuevos aparecen como "???" en el menú
   hasta que los usás por primera vez.
Sin compras con Robux de nada aleatorio.
LINAJES INICIALES con sus Variantes (habilidades base del Prompt 27 + 2 habilidades propias por Variante,
según la tabla de la ficha): Fuerza Bruta, Reflejos, Piroquinesis. Números base:
- Fuerza Bruta: Z Pisotón 25 daño círculo 8 studs, 30 energía, 6 s · X Embestida 20 + empuje, 25, 5 s ·
  C Levantar y tirar 35, 40, 10 s.
- Reflejos: Z Ráfaga 3x8, 20, 4 s · X Contraataque 30 si te pegan en 1 s, 25, 8 s · C Paso sombra 12 studs +
  patada 22, 30, 7 s.
- Piroquinesis: Z Bola de fuego 20 + quemadura 3/s 3 s, 25, 3 s · X Muro de fuego 8/s 4 s, 35, 9 s ·
  C Explosión 40 círculo 10 studs, 50, 14 s.
- Habilidades de Variante (se usan cuando la consigas): 15 a 45 de daño según recarga (4 a 14 s); Claude propone los números en
  Config.luau y me muestra la tabla.
Todo validado en el servidor igual que el combo. Probá 1.000 tiradas simuladas y mostrame que los % dan bien.
```

#### Prompt 36b 💻 Creador de personaje y personalización
```
Leé la sección 0c de linajes/ideas/ficha.md. Usá las piezas del Prompt 20b.
1. CREADOR (al crear un espacio y después en tu base): elegir casco, capa, peto, hombreras, guantes, botas
   sobre tu avatar de Roblox; 3 colores por pieza con selector libre (rueda de color + 12 colores de la guía);
   material por pieza (tela, cuero, metal, neon); largo de capa; vista girando.
2. EMBLEMA: 20 formas, color, borde y brillo; se ve en el peto, la capa y la bandera de la base.
3. NOMBRE DE HÉROE + TÍTULO (lista de títulos ganados).
4. ESTILO DE PELEA: Puños, Espada, Bastón, Armas no letales, Gadgets; cada uno cambia el combo de 4 golpes
   (daño en Config.luau: Puños rápido y bajo, Espada medio, Bastón con alcance, Armas a distancia,
   Gadgets con efectos). Cada estilo necesita su set de 4 animaciones (pedírselas al Prompt 26 con el
   mismo formato).
5. ARMADO DE HABILIDADES: pantalla con todas las habilidades abiertas; arrastrar a Z, X, C, V (y B si hay
   Técnica combinada). Guardado por espacio.
6. BASE PROPIA: elegir escondite (galpón, azotea, cueva), colocar 20 muebles y trofeos de jefes en una
   grilla, colgar trajes guardados. Privada por jugador (PersistentPerPlayer).
Guardar todo en el perfil. Commit y push.
```

#### Prompt 37 💻 Niveles, árbol y Despertar 1 con ramas
```
XP: matón 15, matón con implantes 25, élite 60, jefe 300, misión 50 a 200, crimen al azar 40.
Nivel siguiente = 100 x nivel^1,4. Niveles 1-60 (el contenido llega al 20 por ahora). 1 punto por nivel.
ÁRBOL por Linaje: 3 ramas (Poder, Cuerpo, Técnica) x 4 nodos, en orden dentro de cada rama.
Los nodos de Técnica cambian cómo funciona una habilidad (ejemplos en la ficha).
DESPERTAR 1 (nivel 25): misión con el mentor → elegir UNA de 2 ramas de evolución de tu Linaje
(Piroquinesis: Fénix o Infierno; Fuerza Bruta: Coloso o Demoledor; Reflejos: Sombra o Maestro).
Cada rama: 4 nodos nuevos, una definitiva V propia y cambio de color del poder.
LA ELECCIÓN ES A CIEGAS: la pantalla muestra solo el nombre de cada rama, su símbolo y una frase misteriosa
del mentor (ej. Fénix: "Lo que arde, vuelve." / Infierno: "Que no quede nada."). Nada de números ni
descripciones. Solo avisa que no se puede deshacer. Los nodos nuevos aparecen como "???" hasta usarlos.
Aviso "Tenés N puntos de habilidad". Reinicio gratis del árbol (no de la rama) hablando con Tano.
```

#### Prompt 37b 💻 Chips de técnica, segundo poder y técnicas combinadas
```
Leé la sección 0c de linajes/ideas/ficha.md.
1. CHIPS DE TÉCNICA: caen de jefes, élites y eventos. Cada chip tiene un efecto y un valor al azar dentro
   de un rango (ej: "+1 proyectil", "rebota 1-3 veces", "deja charco 2-4 s", "-10 a -25 % recarga",
   "+15 a +35 % área"). 2 ranuras por habilidad equipada. 30 efectos en Config.luau. Se pueden desarmar
   en chips de chatarra.
2. DESPERTAR 2 (nivel 60): elegir camino para el SEGUNDO PODER, A CIEGAS (cada NPC lo ofrece con una
   frase, sin decir qué da):
   - Transferencia (Directora Brandt): elegís un fragmento de jefe que tengas → ese Linaje, Variante al azar.
   - Resonancia (Señal + Atalanta): ruleta solo entre Linajes compatibles con el tuyo (tabla en Config.luau).
   - Núcleo artificial (Kessler + Okafor): poder tecnológico (Láser, Escudo de energía o Drones) que ocupa
     toda la Carga Cibernética.
   El segundo poder tiene su propio árbol (empieza en 0) y su Variante.
3. TÉCNICAS COMBINADAS: tabla de 12 combinaciones en Config.luau (las de la ficha + Claude propone el resto).
   Si tenés las dos, se abre la tecla B. 3 son secretas: el primero del servidor que la consigue dispara
   un aviso para todos ("¡X descubrió Supernova!").
Mostrame la tabla completa de chips y combinaciones antes de programar. Commit y push.
```

#### Prompt 37c 💻 Rasgos por estadísticas y Variantes secretas
```
Leé la sección 0c de linajes/ideas/ficha.md, sobre todo "Cambios de Juani (30 oct, 20:00)".
1. ESTADÍSTICAS DE PARTIDA (guardadas por espacio, solo en el servidor): dash, esquives, parry, golpes
   recibidos, peleas ganadas con <15 % de vida, minutos de noche, trabajos por tipo, crímenes ayudados
   (de cada lado), uso de cada habilidad, derrotas, NPCs hablados, distancia recorrida, enemigos vencidos
   por lugar y por tipo de daño, quemaduras, objetos lanzados, bloqueos, críticos.
2. RASGOS: en el Despertar 1, el Despertar 2 y cada 10 niveles, el servidor compara tus estadísticas con
   las reglas de los 30 Rasgos (Config.luau; la tabla de la ficha + Claude propone el resto) y te da el que
   más te ganaste que no tengas. Máximo 4 Rasgos. Escena corta: "Algo cambió en vos..." y aparece como
   "???" hasta que se activa por primera vez. No se tiran, no se re-tiran, no se compran.
3. VARIANTES SECRETAS: tabla de condiciones en Config.luau (lugar + acción + Catalizador, la de la ficha
   para los 3 primeros Linajes; Claude propone las de los demás). El servidor revisa las condiciones; cuando
   se cumplen, escena de mutación de 10 s y el poder cambia de color y abre sus 2 habilidades.
   Si ya tenías otra Variante, la nueva la reemplaza.
4. CATALIZADORES: 9 objetos raros (1 % a 3 % en su lugar), intercambiables entre jugadores, se ven brillando
   en el piso como los objetos para juntar.
5. PISTAS: cada NPC tiene 1 o 2 líneas de diálogo con pistas a medias de una Variante; El Faro publica un
   rumor de Variante cada 3 días reales. Nunca se dice la condición completa.
6. Primer jugador del servidor que consigue una Variante: aviso para todos ("Alguien despertó Llama azul").
Mostrame la tabla de Rasgos y de condiciones antes de programar. Probá con un jugador de prueba forzando
estadísticas. Commit y push.
```

#### Prompt 38 💻 Diálogos con NPCs, trabajos y reputación
```
SISTEMA DE DIÁLOGO (pantalla del Prompt 33): los diálogos viven en linajes/src/shared/Dialogos/<npc>.luau
como datos (nodos con texto, respuestas, condiciones y acciones), nunca mezclados en el código.
Condiciones posibles: nivel, bando, rango, reputación, trabajo y nivel de trabajo, misión activa o completa.
Acciones: dar misión, completar misión, dar trabajo, dar dinero/objetos, sumar reputación, enseñar nodo,
abrir tienda (taller, clínica), mover al jugador.
TRABAJOS (cada uno con una tarea corta repetible de 1 a 3 minutos, 5 niveles Aprendiz → Experto):
- Reportero con Lucía Vega: sacar 3 fotos de peleas o crímenes marcados (botón de cámara, la foto vale si
  el objetivo está en cuadro y a menos de 30 studs). Paga 40 + 10 por nivel. Da rumores = misiones.
- Mecánico con Tano: arreglar un auto (minijuego: tocar 5 piezas en orden antes de 15 s). Paga chatarra.
- Patrullero con Comisaria Rivas: recorrer 4 puntos y detener 3 matones. +20 reputación Liga.
- Laboratorio con Ingeniera Okafor: probar un prototipo (llegar a 3 blancos con el gancho). Da planos.
- Contrabandista con El Albatros: llevar un paquete a un punto sin que te vea un dron. +20 Cofradía.
PEDIR AYUDA: "¿Qué hago ahora?" en Señal y en la comisaría dice la próxima misión y a quién ir;
Tano y Atalanta enseñan un nodo extra si cumplís su prueba; con reputación ≥ 300 con un héroe, podés
pedirle que te acompañe en una misión (NPC aliado que pelea).
REPUTACIÓN Y RANGO: 0 a 1000 por bando. Rangos: Novato (0), Clase C (150), B (350), A (600), S (900).
Para subir hay que tener la reputación Y hablar con el líder del bando (Liga: Centinela Solar;
Cofradía: Mascarada; Vigilantes: Cuervo), que da una prueba (pelea o misión corta).
```

#### Prompt 39 💻 Prólogo: tu origen y la Noche del Eclipse
```
Leé la sección 0c de linajes/ideas/ficha.md.
1. Creador de personaje (Prompt 36b) con ropa de civil.
2. ORIGEN AL AZAR (servidor): uno de 6 inicios (Estibador, Pasante, Repartidor, Fotógrafo, Preso, Acróbata),
   cada uno en su lugar del mapa, con 1 tarea corta de su vida normal (descargar 3 cajas, ordenar el
   laboratorio, entregar 2 paquetes, sacar 2 fotos, salir al patio, hacer un salto en la feria) y su
   primer NPC. El inicio no da Rasgo: suma estadísticas de arranque (ej. el Acróbata empieza con saltos
   anotados) que pesan en el primer Rasgo.
3. EL ECLIPSE: cámara cinemática de 15 s: la luna se tapa, la ciudad se apaga, una esquirla de luz negra
   cae y te atraviesa, te desmayás (animación) y la pantalla se va a negro.
4. DESPERTAR: abrís los ojos en otro lugar con un NPC al lado (distinto por inicio). Ruleta de Linaje
   (Prompt 36) como "visión" del poder. Empezás con su Variante Normal y sin Rasgos (salen jugando).
5. Señal por radio: "Si me escuchás, no estás solo." Pelea guiada contra 3 matones (combo, bloqueo, dash, Z).
6. En la plaza, Centinela Solar, Mascarada y Cuervo (NPCs) ofrecen reclutarte, cada uno con 3 líneas propias
   que cambian según tu inicio. Elegís bando o seguís Neutral.
7. Te manda con tu primer NPC de trabajo según el bando.
Probá los 6 inicios. Commit y push.
```

#### Prompt 40 💻 Tecnología e implantes
```
TALLER DE TANO: traje (Mk I a Mk V: +10 escudo por nivel, cuesta 50/120/250/500/900 chatarra) y gadget
gancho (Mk I a V: alcance 30 a 60 studs, recarga 6 a 3 s). Botón G usa el gadget.
CLÍNICA DE LA DRA. KESSLER (solo si hiciste 3 trabajos para ella o reputación Cofradía ≥ 150):
3 ranuras. Brazo: Puño hidráulico (+20 % daño del combo, carga 3) o Cañón de muñeca (disparo 15 daño,
carga 4). Ojos: Analizador (ves la vida del enemigo, carga 2) o Visión nocturna (carga 1).
Columna: Doble salto (carga 2) o Reflejos rápidos (recargas -10 %, carga 4).
Carga Cibernética máxima = 3 + nivel/10 + nodos de Cuerpo. Si te pasás, Sincronía baja: tus habilidades
de Linaje recargan +25 % más lento. Instalar cuesta chips y dinero; sacar es gratis.
Los implantes se ven en el personaje (modelos chicos hechos en Blender con el mismo formato).
```

#### Prompt 41 💻 Acto 1 completo
```
ACTO 1 "Ciudad en llamas" (niveles 5-20) en Puerto Óxido, con los modelos de los Prompts 6, 13, 20 y 21:
MISIONES DE HISTORIA (todas empiezan y terminan hablando con un NPC):
1. Rivas: "Algo pasa en el puerto" → investigar 3 galpones (pistas: cajas con logo de Corona Corp).
2. Vega: fotos del cargamento ilegal → descubrís implantes robados.
3. Señal: rescatar a un mecánico secuestrado (pelea contra 6 matones con implantes).
4. Tano: arreglar el gancho para subir a la grúa.
5. Jefe 1: Remache (2 fases, 2.000 de vida, ataques del Prompt 28, arena del muelle).
6. Brandt te ofrece la Transferencia del fragmento de Remache (Linaje secundario: 1 habilidad de
   Fuerza Bruta) si aceptás un trabajo para ella.
7. Evento de grupo: Asalto al barco del Albatros (1 a 8 jugadores, la vida de los enemigos escala con
   la cantidad), oleadas de matones en la cubierta y jefe El Albatros (3.000 de vida, 2 fases).
8. Final del acto: aparece Mascarada en una pantalla gigante y anuncia el Acto 2.
MISIONES DE BANDO (3 por bando): Liga rescata trabajadores; Cofradía roba un cargamento para Mascarada;
Vigilantes sigue a un informante de noche sin ser visto.
Recompensas: XP, dinero, chatarra, fichas de Eclipse, el traje "Cuervo del puerto" para el que termine el acto.
```

#### Prompt 41b 💻 Que cada partida sea distinta
```
Leé la sección 0c de linajes/ideas/ficha.md.
1. CRÍMENES AL AZAR: cada 3 a 5 min, en un distrito al azar: robo a banco, rehenes, pelea de pandillas,
   villano chico con modificadores. Marcador en el mapa, recompensa para todos los que ayudan, cuenta para
   la reputación (la Cofradía gana por ayudar al robo, la Liga por frenarlo).
2. ÉLITES: 10 % de los enemigos salen con 1 o 2 modificadores (Rápido, Blindado, Explota al morir,
   Invoca drones, Regenera, Invisible a ratos), nombre en color y mejor botín.
3. RUMORES DE EL FARO: cada día real, 5 misiones generadas (tipo + distrito + objetivo + recompensa).
4. EVENTOS DE SERVIDOR que rotan cada 40 min: Apagón, Lluvia de esquirlas, Fuga del penal (desde Acto 2).
5. DECISIONES: sistema de decisiones guardadas por espacio (lista en linajes/src/shared/Decisiones.luau).
   Acto 1: entregar a Remache a Rivas o dejar que Brandt lo use (cambia quién te ayuda en el Acto 2 y si
   Remache vuelve como aliado). Los diálogos leen estas decisiones.
6. RENACER (al terminar la historia, por ahora al llegar a nivel 20 para probar): reinicia el espacio con nuevo
   inicio y nuevo Linaje; conserva piezas de traje, títulos, base y suma 1 Legado (+2 % a todo, máx. 10).
Commit y push.
```

#### Prompt 42 💻 Piezas de traje de los NPCs y pantalla de trajes
```
Las piezas inspiradas en cada NPC principal (capa de plumas de Cuervo, corona solar de Centinela, etc.)
se ganan completando su cadena de 3 misiones y aparecen en el creador (Prompt 36b) para mezclar.
Pantalla de trajes del Prompt 33: guardar hasta 10 trajes armados por espacio y cambiar en la base.
Los trajes se ponen sobre el avatar del jugador, cada pieza soldada a su hueso del avatar R15.
```

#### Prompt 43 💻 Probar, medir y publicar la beta
```
1. AnalyticsService: embudo de los primeros 10 pasos (entrar, tirar Linaje, primera pelea, elegir bando,
   primer trabajo, nivel 5, primera misión del Acto 1, Remache, evento del barco, nivel 20), fuentes y
   gastos de dinero, chatarra y fichas.
2. Celular: probá todo en 844x390, botones de 48 px mínimo, sin texto cortado.
3. Rendimiento: 10 jugadores de prueba en Puerto Óxido, triángulos en pantalla ≤ 500.000, StreamingEnabled
   activado, ModelStreamingMode Atomic en jefes y PersistentPerPlayer en lo del jugador.
4. Guardado: simulá caídas de DataStore y servidor que se cierra.
5. NOMBRES: buscá en todo linajes/ (código, diálogos, Config, nombres de modelos y animaciones) cualquier
   nombre de DC (Batman, Superman, Joker, Gotham, Arkham, Krypton, Liga de la Justicia, etc.) y
   reemplazalo por el nombre final de la ficha. Pasame la lista de lo que cambiaste.
6. Ícono 512x512 y 3 miniaturas 1920x1080: renders de Blender de nuestros personajes en pose dramática
   (Cuervo en una azotea con lluvia; Centinela Solar volando sobre Distrito Corona; los 3 líderes de bando
   juntos frente al eclipse), con el título "Linajes del Eclipse" en Saira Condensed.
7. Decime paso a paso qué tengo que tocar en Creator Hub para publicar (privado primero, después
   público para 16+ o todas las edades).
```

#### Después de la beta (un prompt por acto)
```
Hacé el Acto [N] de linajes/ideas/ficha.md:
1. Modelos que falten (prompts 3 a 25 con el mismo detalle), animaciones (26 a 30) y sonidos (31 y 32).
2. Misiones de historia (todas por NPC), 3 misiones por bando, jefes con avisos y fases, el evento o raid
   en grupo que dice la ficha, y lo que se desbloquea (Linajes, nodos, trajes, Despertar).
3. Números en Config.luau. Commit y push por cada parte que funcione.
```
Orden: Acto 2 (Distrito Corona, Halden, Dualidad, raid del Penal Islaroca) → Acto 3 (Ciudad Hundida, Hespérides, Despertar 1 de los héroes, guerra de bandos opcional) → Acto 4 (invasión del Eclipsador cada 2 horas) → Acto 5 (Umbra, Despertar 2, raid final de 8) → Acto 6 (Ciudad rota y temporadas).
