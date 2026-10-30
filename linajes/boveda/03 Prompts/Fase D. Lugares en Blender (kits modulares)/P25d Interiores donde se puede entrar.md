---
tags: [prompt]
prompt: "25d"
estado: pendiente
---
# Prompt 25d Interiores donde se puede entrar (uno por sesión)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y la sección "Calle viva > Lugares donde se puede entrar" de
linajes/ideas/ficha.md. Guardá kit-base.blend como linajes/arte/blender/interior-[archivo].blend.
REGLAS DE INTERIORES: van dentro del mismo mapa (sin pantalla de carga), así que la fachada del Prompt 21 a
25 tiene que coincidir con la puerta y las ventanas de este interior. Puertas de 4 x 7 studs, techos de
12 studs (24 en halls grandes), pasillos de 6 studs de ancho mínimo para pelear. Kit modular en grilla de
4 studs: pared, pared con ventana, pared con puerta, piso, techo, escalera, baranda. Luces de interior
cálidas salvo donde diga. Cada interior ≤ 60.000 tris en mallas de ≤ 20.000, más sus props.
Marcá con Parts vacíos llamados "Spawn_Guardia", "Spawn_Civil", "Camara", "Botin" y "Salida" los lugares
que va a usar el código.
INTERIOR: [pegá una fila]
PASO 1: boceto de bloques de toda la planta + vista desde arriba, mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO + 4 renders del interior con luz, mi OK.
PASO 3: exportá a linajes/arte/exports/interior-[archivo]/, script scripts/interiores/[archivo].py,
commit y push.
```
| Archivo | Interior | Ciudad | Qué tiene adentro |
|---|---|---|---|
| banco | Banco Central Corona | Corona | Hall de mármol blanco con columnas y 6 ventanillas con vidrio, oficinas arriba, escalera a la bóveda subterránea, puerta de bóveda redonda de 8 studs con mecanismo (malla aparte que gira y se abre), bóveda con cajas de seguridad y pilas de lingotes, 6 cámaras, sala de seguridad con monitores |
| joyeria | Joyería Aurora | Corona | Local chico con 5 vitrinas de vidrio (rompibles: versión entera y rota), caja fuerte chica en la trastienda, alarma roja en la pared, 2 cámaras |
| museo | Museo de la Ciudad | Corona | Hall con esqueleto de criatura abisal, 3 salas (historia de la bahía, Hespérides, el eclipse) con vitrinas y piezas en pedestales con láser rojo, techo de vidrio por donde se entra en silencio |
| faro | Redacción de El Faro | Corona | Escritorios con computadoras, pared de pantallas con noticias (SurfaceGui), oficina de Lucía Vega, cuarto oscuro de fotos, terraza con el faro de luz |
| corona-lobby | Torre Corona Corp: lobby y laboratorio | Corona | Lobby blanco y dorado con molinetes y recepción, ascensor de vidrio, piso de laboratorio con cápsulas de implantes, oficina de Halden con ventanal (acceso por reputación) |
| hospital | Hospital Santa Lumen | Corona | Entrada con camillas, sala de espera, punto de reaparición con luz suave, consultorios |
| comisaria | Comisaría central | Vórtice | Mostrador con policía, tablero de recompensas (pared de corcho con carteles BUSCADO que cambian por código), 4 celdas con rejas, sala de pruebas, oficina de Rivas, escalera al techo con el reflector |
| gargola | Bar La Gárgola | Vórtice | Barra larga de madera oscura, boxes, rockola, TV con noticias, gárgola de piedra sobre la barra, escalera al sótano con ring de peleas clandestinas iluminado desde arriba |
| empeno | Casa de empeño | Vórtice | Mostrador con reja, estantes llenos de cosas viejas (guitarras, relojes, cámaras), caja fuerte, trastienda donde se vende botín |
| teatro | Teatro Ópalo (abandonado) | Vórtice | Sala de butacas rotas, escenario con telón rojo raído, palcos, camarines con máscaras colgadas, fosa de orquesta; luz de escenario fría |
| subte | Subte abandonado | Vórtice | Andén con azulejos rotos, vías, túneles en grilla de 8 studs con 3 bifurcaciones, campamento de pandilla con barriles de fuego, vagón descarrilado |
| mercado-negro | Mercado negro | Puerto | Bajo el mercado de pescado: entrada por cámara frigorífica, 6 puestos con lonas, puesto del Reducidor, mesa de implantes ilegales con luces neon-aviso |
| taller | Taller de Tano | Puerto | Galpón con elevador de autos, banco de trabajo con gadgets a medio armar, pared de herramientas, mesa de fabricación con pantalla |
| clinica | Clínica de la Dra. Kessler | Puerto | Quirófano clandestino con camilla, brazo robótico de cirugía, frascos con implantes, luz verde fría |
| albatros | Galpón del Albatros (interior) | Puerto | Oficina arriba con ventanal, tablero de golpes, mesa de cartas, cajas de contrabando, sala de guarida con sillones (baja la búsqueda) |
| aduana | Bodegas de aduana | Puerto | Depósito de techo alto con contenedores apilados, puente grúa interior, oficina de control, cámaras |
| refugio | Refugio del jugador (3 tipos) | Todas | Departamento de ladrillo (Vórtice), loft de vidrio (Corona), galpón chico (Puerto): perchero de trajes, cofre, mesa de taller chica, pared de trofeos, cama |
| estacion | Estación de subte | Todas | Andén limpio, molinetes, mapa de las líneas en la pared, escaleras a la calle |
| tienda | Tiendas chicas (kiosco, farmacia, ropa) | Todas | Kit de local de 12 x 16 studs: mostrador, caja registradora, estantes, heladera; 3 decoraciones distintas |
| penal | Penal Islaroca (interior) | Penal | Bloque de celdas de 2 pisos, patio con tareas (pesas, lavar), comedor, túnel de escape secreto tras una pared rompible |

---
[[P22-25 Los otros lugares|← P22-25 Los otros lugares]]   ·   [[Todos los prompts]]   ·   [[P26 Animaciones base del jugador|P26 Animaciones base del jugador →]]
